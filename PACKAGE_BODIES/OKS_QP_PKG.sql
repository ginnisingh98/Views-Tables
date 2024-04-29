--------------------------------------------------------
--  DDL for Package Body OKS_QP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_QP_PKG" AS
/* $Header: OKSRAQPB.pls 120.13.12010000.2 2009/11/24 12:23:36 harlaksh ship $ */
 ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
   g_module                       CONSTANT VARCHAR2 (250)
                                         := 'oks.plsql.pricing.' ||
                                            g_pkg_name ||
                                            '.';

   FUNCTION check_hdr_discount (
      p_chr_id                        IN       NUMBER
   )
      RETURN BOOLEAN
   IS
      l_api_name                     CONSTANT VARCHAR2 (30)
                                                      := 'Check_hdr_discount';
      l_found                                 NUMBER;
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

      SELECT COUNT (1)
        INTO l_found
        FROM okc_price_adjustments
       WHERE chr_id = p_chr_id;

      IF l_found > 0
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

         RETURN TRUE;
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

         RETURN FALSE;
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
         RETURN FALSE;
   END check_hdr_discount;

   PROCEDURE modifier_4_usg (
      p_bsl_id                        IN       NUMBER,
      p_modifier_details              IN       qp_preq_grp.line_detail_tbl_type,
      x_return_status                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name                     CONSTANT VARCHAR2 (30)
                                                          := 'modifier_4_usg';
      i                                       NUMBER;
      l_in_tbl                                okc_price_adjustment_pub.patv_tbl_type;
      l_out_tbl                               okc_price_adjustment_pub.patv_tbl_type;
      l_return_status                         VARCHAR2 (1) := 'S';
      l_msg_count                             NUMBER;
      l_msg_data                              VARCHAR2 (2000) := NULL;
      l_api_version                  CONSTANT NUMBER := 1.0;
      l_init_msg_list                CONSTANT VARCHAR2 (1) := 'F';
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

      i                          := p_modifier_details.FIRST;

      IF i IS NOT NULL
      THEN
         LOOP
            l_in_tbl (1).bsl_id        := p_bsl_id;
            l_in_tbl (1).list_line_id  := p_modifier_details (i).list_line_id;
            l_in_tbl (1).adjusted_amount :=
                                     p_modifier_details (i).adjustment_amount;
            l_in_tbl (1).operand       :=
                                         p_modifier_details (i).operand_value;
            l_in_tbl (1).arithmetic_operator :=
                              p_modifier_details (i).operand_calculation_code;
            l_in_tbl (1).accrual_conversion_rate :=
                               p_modifier_details (i).accrual_conversion_rate;
            l_in_tbl (1).accrual_flag  := p_modifier_details (i).accrual_flag;
            l_in_tbl (1).applied_flag  := p_modifier_details (i).applied_flag;
            l_in_tbl (1).automatic_flag :=
                                        p_modifier_details (i).automatic_flag;
            l_in_tbl (1).benefit_qty   := p_modifier_details (i).benefit_qty;
            l_in_tbl (1).benefit_uom_code :=
                                      p_modifier_details (i).benefit_uom_code;
            l_in_tbl (1).charge_subtype_code :=
                                   p_modifier_details (i).charge_subtype_code;
            l_in_tbl (1).charge_type_code :=
                                      p_modifier_details (i).charge_type_code;
            l_in_tbl (1).expiration_date :=
                                       p_modifier_details (i).expiration_date;
            l_in_tbl (1).include_on_returns_flag :=
                               p_modifier_details (i).include_on_returns_flag;
            l_in_tbl (1).list_header_id :=
                                        p_modifier_details (i).list_header_id;
            l_in_tbl (1).list_line_no  := p_modifier_details (i).list_line_no;
            l_in_tbl (1).list_line_type_code :=
                                   p_modifier_details (i).list_line_type_code;
            l_in_tbl (1).modifier_level_code :=
                                   p_modifier_details (i).modifier_level_code;
            l_in_tbl (1).modifier_mechanism_type_code :=
                           p_modifier_details (i).created_from_list_type_code;
            l_in_tbl (1).price_break_type_code :=
                                 p_modifier_details (i).price_break_type_code;
            l_in_tbl (1).pricing_group_sequence :=
                                p_modifier_details (i).pricing_group_sequence;
            l_in_tbl (1).pricing_phase_id :=
                                      p_modifier_details (i).pricing_phase_id;
            l_in_tbl (1).proration_type_code :=
                                   p_modifier_details (i).proration_type_code;
            l_in_tbl (1).rebate_transaction_type_code :=
                          p_modifier_details (i).rebate_transaction_type_code;
            l_in_tbl (1).source_system_code :=
                                    p_modifier_details (i).source_system_code;
            l_in_tbl (1).substitution_attribute :=
                                p_modifier_details (i).substitution_attribute;
            l_in_tbl (1).update_allowed :=
                                         p_modifier_details (i).override_flag;
            l_in_tbl (1).updated_flag  := p_modifier_details (i).updated_flag;
            okc_price_adjustment_pub.create_price_adjustment
                                         (p_api_version                      => 1.0,
                                          p_init_msg_list                    => okc_api.g_false,
                                          x_return_status                    => l_return_status,
                                          x_msg_count                        => l_msg_count,
                                          x_msg_data                         => l_msg_data,
                                          p_patv_tbl                         => l_in_tbl,
                                          x_patv_tbl                         => l_out_tbl
                                         );

            IF l_return_status <> 'S'
            THEN
               x_return_status            := l_return_status;
               okc_api.set_message
                                  (g_app_name,
                                   g_required_value,
                                   g_col_name_token,
                                   'Usage Modifier creation Error bsl id ' ||
                                   p_bsl_id ||
                                   ' Modifier ' ||
                                   p_modifier_details (i).list_line_id
                                  );
               RAISE fnd_api.g_exc_error;
            END IF;

            EXIT WHEN i = p_modifier_details.LAST;
            i                          := p_modifier_details.NEXT (i);
         END LOOP;
      END IF;                                                       -- i check

      x_return_status            := l_return_status;

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
   END modifier_4_usg;

   PROCEDURE modifier_handling (
      p_cle_id                                 NUMBER,
      p_modifier_details              IN       qp_preq_grp.line_detail_tbl_type,
      x_return_status                 OUT NOCOPY VARCHAR2
   )
   IS
      CURSOR cur_price (
         p_cle_id                        IN       NUMBER,
         p_list_line_id                  IN       NUMBER
      )
      IS
         SELECT *
           FROM okc_price_adjustments
          WHERE cle_id = p_cle_id             AND
                list_line_id = p_list_line_id;

      CURSOR chk_price (
         p_cle_id                        IN       NUMBER
      )
      IS
         SELECT *
           FROM okc_price_adjustments
          WHERE cle_id = p_cle_id;

      l_api_name                     CONSTANT VARCHAR2 (30)
                                                        := 'modifier_handling';
      price_rec                               cur_price%ROWTYPE;
      l_flag                                  BOOLEAN;
      l_in_tbl                                okc_price_adjustment_pub.patv_tbl_type;
      l_out_tbl                               okc_price_adjustment_pub.patv_tbl_type;
      l_in_rec                                okc_pat_pvt.patv_rec_type;
      l_out_rec                               okc_pat_pvt.patv_rec_type;
      l_return_status                         VARCHAR2 (1);
      l_msg_count                             NUMBER;
      l_msg_data                              VARCHAR2 (2000) := NULL;
      l_api_version                  CONSTANT NUMBER := 1.0;
      l_init_msg_list                CONSTANT VARCHAR2 (1) := 'F';
      i                                       NUMBER;

      FUNCTION modifier_exists (
         p_subline_id                    IN       NUMBER,
         p_list_line_id                  IN       NUMBER
      )
         RETURN BOOLEAN
      IS
-- Find topline and header id for given subline
         CURSOR cs_topline_hdr (
            cp_subline_id                            NUMBER
         )
         IS
            SELECT cle_id,
                   dnz_chr_id
              FROM okc_k_lines_b
             WHERE ID = cp_subline_id;

--- find modifier for top line
         CURSOR cs_topline_mod (
            cp_topline_id                            NUMBER
         )
         IS
            SELECT 1
              FROM okc_price_adjustments
             WHERE cle_id = cp_topline_id        AND
                   list_line_id = p_list_line_id;

--- find modifier for header
         CURSOR cs_hdr_mod (
            cp_hdr_id                                NUMBER
         )
         IS
            SELECT 1
              FROM okc_price_adjustments
             WHERE chr_id = cp_hdr_id            AND
                   cle_id IS NULL                AND
                   list_line_id = p_list_line_id;

         l_topline_id                            NUMBER;
         l_hdr_id                                NUMBER;
         l_dummy                                 NUMBER;
         l_api_name                     CONSTANT VARCHAR2 (30)
                                                          := 'MODIFIER_EXISTS';
      -- Declare program variables as shown above
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

         OPEN cs_topline_hdr (p_subline_id);

         FETCH cs_topline_hdr
          INTO l_topline_id,
               l_hdr_id;

         CLOSE cs_topline_hdr;

         OPEN cs_topline_mod (l_topline_id);

         FETCH cs_topline_mod
          INTO l_dummy;

         IF cs_topline_mod%FOUND
         THEN
            CLOSE cs_topline_mod;

            RETURN TRUE;
         END IF;

         CLOSE cs_topline_mod;

         OPEN cs_hdr_mod (l_hdr_id);

         FETCH cs_hdr_mod
          INTO l_dummy;

         IF cs_hdr_mod%FOUND
         THEN
            CLOSE cs_hdr_mod;

            RETURN TRUE;
         END IF;

         CLOSE cs_hdr_mod;

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

         RETURN FALSE;
      END;
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

      i                          := p_modifier_details.FIRST;

      IF i IS NOT NULL
      THEN
         LOOP
            IF NOT modifier_exists (p_cle_id,
                                    p_modifier_details (i).list_line_id)
            THEN
               OPEN cur_price (p_cle_id, p_modifier_details (i).list_line_id);

               FETCH cur_price
                INTO price_rec;

               IF (cur_price%FOUND)
               THEN
                  UPDATE okc_price_adjustments
                     SET adjusted_amount =
                                      p_modifier_details (i).adjustment_amount,
                         arithmetic_operator =
                               p_modifier_details (i).operand_calculation_code,
                         operand = p_modifier_details (i).operand_value,
                         update_allowed = p_modifier_details (i).override_flag
                   WHERE cle_id = p_cle_id                     AND
                         list_line_id =
                                       p_modifier_details (i).list_line_id;
               ELSE
                  l_in_tbl (1).cle_id        := p_cle_id;
                  l_in_tbl (1).list_line_id  :=
                                          p_modifier_details (i).list_line_id;
                  l_in_tbl (1).adjusted_amount :=
                                     p_modifier_details (i).adjustment_amount;
                  l_in_tbl (1).operand       :=
                                         p_modifier_details (i).operand_value;
                  l_in_tbl (1).arithmetic_operator :=
                              p_modifier_details (i).operand_calculation_code;
                  l_in_tbl (1).accrual_conversion_rate :=
                               p_modifier_details (i).accrual_conversion_rate;
                  l_in_tbl (1).accrual_flag  :=
                                          p_modifier_details (i).accrual_flag;
                  l_in_tbl (1).applied_flag  :=
                                          p_modifier_details (i).applied_flag;
                  l_in_tbl (1).automatic_flag :=
                                        p_modifier_details (i).automatic_flag;
                  l_in_tbl (1).benefit_qty   :=
                                           p_modifier_details (i).benefit_qty;
                  l_in_tbl (1).benefit_uom_code :=
                                      p_modifier_details (i).benefit_uom_code;
                  l_in_tbl (1).charge_subtype_code :=
                                   p_modifier_details (i).charge_subtype_code;
                  l_in_tbl (1).charge_type_code :=
                                      p_modifier_details (i).charge_type_code;
                  l_in_tbl (1).expiration_date :=
                                       p_modifier_details (i).expiration_date;
                  l_in_tbl (1).include_on_returns_flag :=
                               p_modifier_details (i).include_on_returns_flag;
                  l_in_tbl (1).list_header_id :=
                                        p_modifier_details (i).list_header_id;
                  l_in_tbl (1).list_line_no  :=
                                          p_modifier_details (i).list_line_no;
                  l_in_tbl (1).list_line_type_code :=
                                   p_modifier_details (i).list_line_type_code;
                  l_in_tbl (1).modifier_level_code :=
                                   p_modifier_details (i).modifier_level_code;
                  l_in_tbl (1).modifier_mechanism_type_code :=
                           p_modifier_details (i).created_from_list_type_code;
                  l_in_tbl (1).price_break_type_code :=
                                 p_modifier_details (i).price_break_type_code;
                  l_in_tbl (1).pricing_group_sequence :=
                                p_modifier_details (i).pricing_group_sequence;
                  l_in_tbl (1).pricing_phase_id :=
                                      p_modifier_details (i).pricing_phase_id;
                  l_in_tbl (1).proration_type_code :=
                                   p_modifier_details (i).proration_type_code;
                  l_in_tbl (1).rebate_transaction_type_code :=
                          p_modifier_details (i).rebate_transaction_type_code;
                  l_in_tbl (1).source_system_code :=
                                    p_modifier_details (i).source_system_code;
                  l_in_tbl (1).substitution_attribute :=
                                p_modifier_details (i).substitution_attribute;
                  l_in_tbl (1).update_allowed :=
                                         p_modifier_details (i).override_flag;
                  l_in_tbl (1).updated_flag  :=
                                          p_modifier_details (i).updated_flag;
                  okc_price_adjustment_pub.create_price_adjustment
                                         (p_api_version                      => 1.0,
                                          p_init_msg_list                    => okc_api.g_false,
                                          x_return_status                    => l_return_status,
                                          x_msg_count                        => l_msg_count,
                                          x_msg_data                         => l_msg_data,
                                          p_patv_tbl                         => l_in_tbl,
                                          x_patv_tbl                         => l_out_tbl
                                         );
                  x_return_status            := l_return_status;
               END IF;

               CLOSE cur_price;
            END IF;

            EXIT WHEN i = p_modifier_details.LAST;
            i                          := p_modifier_details.NEXT (i);
         END LOOP;
      END IF;                                                       -- I Check

      /*FOR DELETION  */
      FOR cur IN chk_price (p_cle_id)
      LOOP
         l_flag                     := FALSE;
         i                          := p_modifier_details.FIRST;

         IF i IS NOT NULL
         THEN
            LOOP
               IF (cur.list_line_id = p_modifier_details (i).list_line_id)
               THEN
                  l_flag                     := TRUE;
                  EXIT;
               END IF;

               EXIT WHEN i = p_modifier_details.LAST;
               i                          := p_modifier_details.NEXT (i);
            END LOOP;
         END IF;                                                     --I Check

         IF (l_flag = FALSE)
         THEN
            DELETE FROM okc_price_adjustments
                  WHERE cle_id = p_cle_id               AND
                        list_line_id = cur.list_line_id;
         END IF;
      END LOOP;

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
   END;

   PROCEDURE build_top_qa (
      p_cle_id                        IN       NUMBER,
      p_item_id                       IN       NUMBER,
      p_service_index                 IN       NUMBER,
      p_line_qual_tbl_ctr             IN OUT NOCOPY NUMBER,
      p_req_qual_tbl                  IN OUT NOCOPY qp_preq_grp.qual_tbl_type
   )
   IS
      l_line_qual_tbl_ctr                     NUMBER;
      l_req_qual_rec2                         qp_preq_grp.qual_rec_type;
      l_req_qual_tbl                          qp_preq_grp.qual_tbl_type;
      l_api_name                     CONSTANT VARCHAR2 (30) := 'BUILD_TOP_QA';

      CURSOR l_qual_csr
      IS
         SELECT qualifier_context,
                qualifier_attribute,
                qualifier_attr_value,
                comparison_operator_code
           FROM oks_qualifiers
          WHERE list_line_id = p_cle_id;

      l_qual_rec                              l_qual_csr%ROWTYPE;
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

      l_line_qual_tbl_ctr        := p_line_qual_tbl_ctr;
      l_req_qual_tbl             := p_req_qual_tbl;

      IF p_item_id IS NOT NULL
      THEN
         l_line_qual_tbl_ctr        := l_line_qual_tbl_ctr +
                                       1;
         l_req_qual_rec2.line_index := p_service_index;
         l_req_qual_rec2.qualifier_context := 'MODLIST';
         l_req_qual_rec2.qualifier_attribute := 'QUALIFIER_ATTRIBUTE4';
         l_req_qual_rec2.qualifier_attr_value_from := p_item_id;
         l_req_qual_rec2.comparison_operator_code := '=';
         l_req_qual_rec2.validated_flag := 'Y';
         l_req_qual_tbl (l_line_qual_tbl_ctr) := l_req_qual_rec2;
      END IF;

      FOR l_qual_rec IN l_qual_csr
      LOOP
         l_line_qual_tbl_ctr        := l_line_qual_tbl_ctr +
                                       1;
         l_req_qual_rec2.line_index := p_service_index;
         l_req_qual_rec2.qualifier_context := l_qual_rec.qualifier_context;
         l_req_qual_rec2.qualifier_attribute := l_qual_rec.qualifier_attribute;
         l_req_qual_rec2.qualifier_attr_value_from :=
                                               l_qual_rec.qualifier_attr_value;
         l_req_qual_rec2.comparison_operator_code :=
                                           l_qual_rec.comparison_operator_code;
         l_req_qual_rec2.validated_flag := 'N';
         l_req_qual_tbl (l_line_qual_tbl_ctr) := l_req_qual_rec2;
      END LOOP;

      p_line_qual_tbl_ctr        := l_line_qual_tbl_ctr;
      p_req_qual_tbl             := l_req_qual_tbl;

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
   END;

   PROCEDURE build_hdr_adj (
      p_chr_id                        IN       NUMBER,
      p_item_id                       IN       NUMBER,
      p_service_index                 IN       NUMBER,
      p_line_detl_tbl_ctr             IN OUT NOCOPY NUMBER,
      p_req_line_detail_tbl           IN OUT NOCOPY qp_preq_grp.line_detail_tbl_type
   )
   IS
      l_req_line_detail_tbl                   qp_preq_grp.line_detail_tbl_type;
      l_line_detl_tbl_ctr                     NUMBER;
      l_api_name                     CONSTANT VARCHAR2 (30)
                                                           := 'BUILD_HDR_ADJ';

      CURSOR l_adj_csr
      IS
         SELECT list_header_id,
                list_line_id,
                list_line_type_code,
                modifier_mechanism_type_code,
                automatic_flag,
                arithmetic_operator,
                operand
           FROM okc_price_adjustments
          WHERE chr_id = p_chr_id              AND
                cle_id IS NULL                 AND
                NVL (automatic_flag, 'N') = 'N';

      l_req_line_detail_rec2                  qp_preq_grp.line_detail_rec_type;
      l_adj_rec                               l_adj_csr%ROWTYPE;

      CURSOR l_qp_hdr_csr (
         p_list_header_id                         NUMBER
      )
      IS
         SELECT list_type_code
           FROM qp_list_headers_vl
          WHERE list_header_id = p_list_header_id;

      CURSOR l_qp_lin_csr (
         p_list_line_id                           NUMBER
      )
      IS
         SELECT list_line_no,
                list_line_type_code,
                modifier_level_code,
                pricing_phase_id,
                pricing_group_sequence,
                automatic_flag,
                override_flag,
                arithmetic_operator,
                charge_type_code,
                charge_subtype_code,
                include_on_returns_flag
           FROM qp_list_lines
          WHERE list_line_id = p_list_line_id;

      l_qp_lin_rec                            l_qp_lin_csr%ROWTYPE;
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

      l_req_line_detail_tbl      := p_req_line_detail_tbl;
      l_line_detl_tbl_ctr        := p_line_detl_tbl_ctr;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '201:*********************************************************************'
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '202:**************** WITHIN HDR ADJ RECORD *********************** '
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '203:*************** P-REQ-LINE-DETAIL-TBL COUNT******************* ' ||
             p_req_line_detail_tbl.COUNT
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '204:*************** P-REQ-LINE-DETAIL-TBL CTR  ******************* ' ||
             p_line_detl_tbl_ctr
            );
      END IF;

      --dbms_output.put_line ('*********************************************************************');
      --dbms_output.put_line ('**************** WITHIN HDR ADJ RECORD *********************** ');
      --dbms_output.put_line ('*************** P-REQ-LINE-DETAIL-TBL COUNT******************* ' || p_req_line_detail_tbl.count);
      --dbms_output.put_line ('*************** P-REQ-LINE-DETAIL-TBL CTR  ******************* ' || p_line_detl_tbl_ctr);
      FOR l_adj_rec IN l_adj_csr
      LOOP
         OPEN l_qp_hdr_csr (l_adj_rec.list_header_id);

         FETCH l_qp_hdr_csr
          INTO l_req_line_detail_rec2.created_from_list_type_code;

         CLOSE l_qp_hdr_csr;

         OPEN l_qp_lin_csr (l_adj_rec.list_line_id);

         FETCH l_qp_lin_csr
          INTO l_qp_lin_rec;

         CLOSE l_qp_lin_csr;

         l_line_detl_tbl_ctr        := l_line_detl_tbl_ctr +
                                       1;
         l_req_line_detail_rec2.line_detail_index := l_line_detl_tbl_ctr;
         l_req_line_detail_rec2.line_index := p_service_index;
         l_req_line_detail_rec2.inventory_item_id := p_item_id;
         l_req_line_detail_rec2.list_header_id := l_adj_rec.list_header_id;
         l_req_line_detail_rec2.list_line_id := l_adj_rec.list_line_id;
         l_req_line_detail_rec2.applied_flag := 'Y';

         -- Added to fix bug 3480973
         IF NVL (l_qp_lin_rec.override_flag, 'N') = 'Y' OR
            NVL (l_qp_lin_rec.automatic_flag, 'N') = 'N'
         THEN
            l_req_line_detail_rec2.updated_flag := 'Y';
         END IF;

         l_req_line_detail_rec2.operand_value := l_adj_rec.operand;
         l_req_line_detail_rec2.list_line_no := l_qp_lin_rec.list_line_no;
         l_req_line_detail_rec2.list_line_type_code :=
                                              l_qp_lin_rec.list_line_type_code;
         l_req_line_detail_rec2.modifier_level_code :=
                                              l_qp_lin_rec.modifier_level_code;
         l_req_line_detail_rec2.pricing_phase_id :=
                                                 l_qp_lin_rec.pricing_phase_id;
         l_req_line_detail_rec2.pricing_group_sequence :=
                                           l_qp_lin_rec.pricing_group_sequence;
         l_req_line_detail_rec2.automatic_flag := l_qp_lin_rec.automatic_flag;
         l_req_line_detail_rec2.override_flag := l_qp_lin_rec.override_flag;
         l_req_line_detail_rec2.operand_calculation_code :=
                                              l_qp_lin_rec.arithmetic_operator;
         l_req_line_detail_rec2.charge_type_code :=
                                                 l_qp_lin_rec.charge_type_code;
         l_req_line_detail_rec2.charge_subtype_code :=
                                              l_qp_lin_rec.charge_subtype_code;
         l_req_line_detail_rec2.include_on_returns_flag :=
                                          l_qp_lin_rec.include_on_returns_flag;
         l_req_line_detail_rec2.line_detail_type_code := 'NULL';
         l_req_line_detail_tbl (l_line_detl_tbl_ctr) := l_req_line_detail_rec2;
      END LOOP;

      p_req_line_detail_tbl      := l_req_line_detail_tbl;
      p_line_detl_tbl_ctr        := l_line_detl_tbl_ctr;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
          -- if p_req_line_detail_tbl.count is 0 then the below debug will throw a no data exception
        IF p_req_line_detail_tbl.count > 0 THEN
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '301:******************************************************************'
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '302:*************** P-REQ-LINE-DETAIL-TBL COUNT****************** ' ||
             p_req_line_detail_tbl.COUNT
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '303:*************** P-REQ-LINE-DETAIL-TBL CTR  ****************** ' ||
             p_line_detl_tbl_ctr
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '304:******************************************************************'
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '305:************ p_req_line_detail_tbl(1).created_from_list_type_code **** ' ||
             p_req_line_detail_tbl (1).created_from_list_type_code
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '306:************ p_req_line_detail_tbl(1).line_detail_index **** ' ||
             p_req_line_detail_tbl (1).line_detail_index
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '307:************ p_req_line_detail_tbl(1).line_index        **** ' ||
             p_req_line_detail_tbl (1).line_index
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '308:************ p_req_line_detail_tbl(1).inventory item_id **** ' ||
             p_req_line_detail_tbl (1).inventory_item_id
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '309:************ p_req_line_detail_tbl(1).list_header_id    **** ' ||
             p_req_line_detail_tbl (1).list_header_id
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '310:************ p_req_line_detail_tbl(1).list_line_id      **** ' ||
             p_req_line_detail_tbl (1).list_line_id
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '311:************ p_req_line_detail_tbl(1).applied_flag      **** ' ||
             p_req_line_detail_tbl (1).applied_flag
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '312:************ p_req_line_detail_tbl(1).updated_flag      **** ' ||
             p_req_line_detail_tbl (1).updated_flag
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '313:************ p_req_line_detail_tbl(1).operand_value     **** ' ||
             p_req_line_detail_tbl (1).operand_value
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '314:************ p_req_line_detail_tbl(1).list_line_no      **** ' ||
             p_req_line_detail_tbl (1).list_line_no
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '315:************ p_req_line_detail_tbl(1).list_line_type_code      **** ' ||
             p_req_line_detail_tbl (1).list_line_type_code
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '316:************ p_req_line_detail_tbl(1).modifier_level_code      **** ' ||
             p_req_line_detail_tbl (1).modifier_level_code
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '317:************ p_req_line_detail_tbl(1).pricing_phase_id        **** ' ||
             p_req_line_detail_tbl (1).pricing_phase_id
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '318:************ p_req_line_detail_tbl(1).pricing_group_sequence  **** ' ||
             p_req_line_detail_tbl (1).pricing_group_sequence
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '319:************ p_req_line_detail_tbl(1).automatic_flag          **** ' ||
             p_req_line_detail_tbl (1).automatic_flag
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '320:************ p_req_line_detail_tbl(1).override_flag        **** ' ||
             p_req_line_detail_tbl (1).override_flag
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '321:************ p_req_line_detail_tbl(1).operand_calculation_code **** ' ||
             p_req_line_detail_tbl (1).operand_calculation_code
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '322:************ p_req_line_detail_tbl(1).charge_type_code         **** ' ||
             p_req_line_detail_tbl (1).charge_type_code
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '323:************ p_req_line_detail_tbl(1).charge_subtype_code      **** ' ||
             p_req_line_detail_tbl (1).charge_subtype_code
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '324:************ p_req_line_detail_tbl(1).include_on_returns_flag  **** ' ||
             p_req_line_detail_tbl (1).include_on_returns_flag
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '325:************ p_req_line_detail_tbl(1).line_detail_type_code      **** ' ||
             p_req_line_detail_tbl (1).line_detail_type_code
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '326:***********************************************************************'
            );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '327:*******************END HEADER ADJUSTMENT RECORD*****************************'
            );
       END IF; -- IF p_req_line_detail_tbl.count > 0
      END IF;

      --dbms_output.put_line ('******************************************************************');
      --dbms_output.put_line ('*************** P-REQ-LINE-DETAIL-TBL COUNT****************** ' || p_req_line_detail_tbl.count);
      --dbms_output.put_line ('*************** P-REQ-LINE-DETAIL-TBL CTR  ****************** ' || p_line_detl_tbl_ctr);
      --dbms_output.put_line ('******************************************************************');
      --dbms_output.put_line ('************ p_req_line_detail_tbl(1).created_from_list_type_code **** ' || p_req_line_detail_tbl(1).created_from_list_type_code );
      --dbms_output.put_line ('************ p_req_line_detail_tbl(1).line_detail_index **** ' || p_req_line_detail_tbl(1).line_detail_index);
      --dbms_output.put_line ('************ p_req_line_detail_tbl(1).line_index        **** ' || p_req_line_detail_tbl(1).line_index);
      --dbms_output.put_line ('************ p_req_line_detail_tbl(1).inventory item_id **** ' || p_req_line_detail_tbl(1).inventory_item_id);
      --dbms_output.put_line ('************ p_req_line_detail_tbl(1).list_header_id    **** ' || p_req_line_detail_tbl(1).list_header_id);
      --dbms_output.put_line ('************ p_req_line_detail_tbl(1).list_line_id      **** ' || p_req_line_detail_tbl(1).list_line_id);
      --dbms_output.put_line ('************ p_req_line_detail_tbl(1).applied_flag      **** ' || p_req_line_detail_tbl(1).applied_flag);
      --dbms_output.put_line ('************ p_req_line_detail_tbl(1).updated_flag      **** ' || p_req_line_detail_tbl(1).updated_flag);
      --dbms_output.put_line ('************ p_req_line_detail_tbl(1).operand_value     **** ' || p_req_line_detail_tbl(1).operand_value);
      --dbms_output.put_line ('************ p_req_line_detail_tbl(1).list_line_no      **** ' || p_req_line_detail_tbl(1).list_line_no);

      --dbms_output.put_line ('************ p_req_line_detail_tbl(1).list_line_type_code      **** ' || p_req_line_detail_tbl(1).list_line_type_code);
      --dbms_output.put_line ('************ p_req_line_detail_tbl(1).modifier_level_code      **** ' || p_req_line_detail_tbl(1).modifier_level_code);
      --dbms_output.put_line ('************ p_req_line_detail_tbl(1).pricing_phase_id        **** ' || p_req_line_detail_tbl(1).pricing_phase_id);

      --dbms_output.put_line ('************ p_req_line_detail_tbl(1).pricing_group_sequence  **** ' || p_req_line_detail_tbl(1).pricing_group_sequence);
      --dbms_output.put_line ('************ p_req_line_detail_tbl(1).automatic_flag          **** ' || p_req_line_detail_tbl(1).automatic_flag);
      --dbms_output.put_line ('************ p_req_line_detail_tbl(1).override_flag        **** ' || p_req_line_detail_tbl(1).override_flag);
      --dbms_output.put_line ('************ p_req_line_detail_tbl(1).operand_calculation_code **** ' || p_req_line_detail_tbl(1).operand_calculation_code);

      --dbms_output.put_line ('************ p_req_line_detail_tbl(1).charge_type_code         **** ' || p_req_line_detail_tbl(1).charge_type_code         );
      --dbms_output.put_line ('************ p_req_line_detail_tbl(1).charge_subtype_code      **** ' || p_req_line_detail_tbl(1).charge_subtype_code      );
      --dbms_output.put_line ('************ p_req_line_detail_tbl(1).include_on_returns_flag  **** ' || p_req_line_detail_tbl(1).include_on_returns_flag);
      --dbms_output.put_line ('************ p_req_line_detail_tbl(1).line_detail_type_code      **** ' || p_req_line_detail_tbl(1).line_detail_type_code    );
      --dbms_output.put_line ('***********************************************************************');
      --dbms_output.put_line ('*******************END HEADER ADJUSTMENT RECORD*****************************');

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
   END;

   PROCEDURE build_top_adj (
      p_cle_id                        IN       NUMBER,
      p_item_id                       IN       NUMBER,
      p_service_index                 IN       NUMBER,
      p_line_detl_tbl_ctr             IN OUT NOCOPY NUMBER,
      p_req_line_detail_tbl           IN OUT NOCOPY qp_preq_grp.line_detail_tbl_type
   )
   IS
      l_req_line_detail_tbl                   qp_preq_grp.line_detail_tbl_type;
      l_line_detl_tbl_ctr                     NUMBER;
      l_api_name                     CONSTANT VARCHAR2 (30)
                                                           := 'BUILD_TOP_ADJ';

      CURSOR l_adj_csr
      IS
         SELECT list_header_id,
                list_line_id,
                list_line_type_code,
                modifier_mechanism_type_code,
                automatic_flag,
                arithmetic_operator,
                operand
           FROM okc_price_adjustments
          WHERE cle_id = p_cle_id              AND
                NVL (automatic_flag, 'N') = 'N';

      l_req_line_detail_rec2                  qp_preq_grp.line_detail_rec_type;
      l_adj_rec                               l_adj_csr%ROWTYPE;

      CURSOR l_qp_hdr_csr (
         p_list_header_id                         NUMBER
      )
      IS
         SELECT list_type_code
           FROM qp_list_headers_vl
          WHERE list_header_id = p_list_header_id;

      CURSOR l_qp_lin_csr (
         p_list_line_id                           NUMBER
      )
      IS
         SELECT list_line_no,
                list_line_type_code,
                modifier_level_code,
                pricing_phase_id,
                pricing_group_sequence,
                automatic_flag,
                override_flag,
                arithmetic_operator,
                charge_type_code,
                charge_subtype_code,
                include_on_returns_flag
           FROM qp_list_lines
          WHERE list_line_id = p_list_line_id;

      l_qp_lin_rec                            l_qp_lin_csr%ROWTYPE;
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

      l_req_line_detail_tbl      := p_req_line_detail_tbl;
      l_line_detl_tbl_ctr        := p_line_detl_tbl_ctr;

      FOR l_adj_rec IN l_adj_csr
      LOOP
         OPEN l_qp_hdr_csr (l_adj_rec.list_header_id);

         FETCH l_qp_hdr_csr
          INTO l_req_line_detail_rec2.created_from_list_type_code;

         CLOSE l_qp_hdr_csr;

         OPEN l_qp_lin_csr (l_adj_rec.list_line_id);

         FETCH l_qp_lin_csr
          INTO l_qp_lin_rec;

         CLOSE l_qp_lin_csr;

         l_line_detl_tbl_ctr        := l_line_detl_tbl_ctr +
                                       1;
         l_req_line_detail_rec2.line_detail_index := l_line_detl_tbl_ctr;
         l_req_line_detail_rec2.line_index := p_service_index;
         l_req_line_detail_rec2.inventory_item_id := p_item_id;
         l_req_line_detail_rec2.list_header_id := l_adj_rec.list_header_id;
         l_req_line_detail_rec2.list_line_id := l_adj_rec.list_line_id;
         l_req_line_detail_rec2.applied_flag := 'Y';

         -- Added to fix bug 3480973
         IF NVL (l_qp_lin_rec.override_flag, 'N') = 'Y' OR
            NVL (l_qp_lin_rec.automatic_flag, 'N') = 'N'
         THEN
            l_req_line_detail_rec2.updated_flag := 'Y';
         END IF;

         l_req_line_detail_rec2.operand_value := l_adj_rec.operand;
         l_req_line_detail_rec2.list_line_no := l_qp_lin_rec.list_line_no;
         l_req_line_detail_rec2.list_line_type_code :=
                                              l_qp_lin_rec.list_line_type_code;
         l_req_line_detail_rec2.modifier_level_code :=
                                              l_qp_lin_rec.modifier_level_code;
         l_req_line_detail_rec2.pricing_phase_id :=
                                                 l_qp_lin_rec.pricing_phase_id;
         l_req_line_detail_rec2.pricing_group_sequence :=
                                           l_qp_lin_rec.pricing_group_sequence;
         l_req_line_detail_rec2.automatic_flag := l_qp_lin_rec.automatic_flag;
         l_req_line_detail_rec2.override_flag := l_qp_lin_rec.override_flag;
         l_req_line_detail_rec2.operand_calculation_code :=
                                              l_qp_lin_rec.arithmetic_operator;
         l_req_line_detail_rec2.charge_type_code :=
                                                 l_qp_lin_rec.charge_type_code;
         l_req_line_detail_rec2.charge_subtype_code :=
                                              l_qp_lin_rec.charge_subtype_code;
         l_req_line_detail_rec2.include_on_returns_flag :=
                                          l_qp_lin_rec.include_on_returns_flag;
         l_req_line_detail_rec2.line_detail_type_code := 'LINE';
         l_req_line_detail_tbl (l_line_detl_tbl_ctr) := l_req_line_detail_rec2;
      END LOOP;

      p_req_line_detail_tbl      := l_req_line_detail_tbl;
      p_line_detl_tbl_ctr        := l_line_detl_tbl_ctr;

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
   END;

   FUNCTION get_cp_inv_id (
      p_id                                     NUMBER
   )
      RETURN NUMBER
   IS
      l_id                                    NUMBER;
      l_api_name                     CONSTANT VARCHAR2 (30)
                                                           := 'get_cp_inv_id';
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

      SELECT inventory_item_id
        INTO l_id
        FROM csi_item_instances
       WHERE instance_id = p_id;

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

      RETURN l_id;
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
         RETURN NULL;
   END;

   PROCEDURE build_cp_pa (
      p_inst_id                       IN       NUMBER,
      p_service_index                 IN       NUMBER,
      px_line_attr_tbl_ctr            IN OUT NOCOPY NUMBER,
      px_req_line_attr_tbl            IN OUT NOCOPY qp_preq_grp.line_attr_tbl_type
   )
   IS
      CURSOR l_topline_pa_csr
      IS
         SELECT pricing_context,
                pricing_attribute1,
                pricing_attribute2,
                pricing_attribute3,
                pricing_attribute4,
                pricing_attribute5,
                pricing_attribute6,
                pricing_attribute7,
                pricing_attribute8,
                pricing_attribute9,
                pricing_attribute10,
                pricing_attribute11,
                pricing_attribute12,
                pricing_attribute13,
                pricing_attribute14,
                pricing_attribute15,
                pricing_attribute16,
                pricing_attribute17,
                pricing_attribute18,
                pricing_attribute19,
                pricing_attribute20,
                pricing_attribute21,
                pricing_attribute22,
                pricing_attribute23,
                pricing_attribute24,
                pricing_attribute25,
                pricing_attribute26,
                pricing_attribute27,
                pricing_attribute28,
                pricing_attribute29,
                pricing_attribute30,
                pricing_attribute31,
                pricing_attribute32,
                pricing_attribute33,
                pricing_attribute34,
                pricing_attribute35,
                pricing_attribute36,
                pricing_attribute37,
                pricing_attribute38,
                pricing_attribute39,
                pricing_attribute40,
                pricing_attribute41,
                pricing_attribute42,
                pricing_attribute43,
                pricing_attribute44,
                pricing_attribute45,
                pricing_attribute46,
                pricing_attribute47,
                pricing_attribute48,
                pricing_attribute49,
                pricing_attribute50,
                pricing_attribute51,
                pricing_attribute52,
                pricing_attribute53,
                pricing_attribute54,
                pricing_attribute55,
                pricing_attribute56,
                pricing_attribute57,
                pricing_attribute58,
                pricing_attribute59,
                pricing_attribute60,
                pricing_attribute61,
                pricing_attribute62,
                pricing_attribute63,
                pricing_attribute64,
                pricing_attribute65,
                pricing_attribute66,
                pricing_attribute67,
                pricing_attribute68,
                pricing_attribute69,
                pricing_attribute70,
                pricing_attribute71,
                pricing_attribute72,
                pricing_attribute73,
                pricing_attribute74,
                pricing_attribute75,
                pricing_attribute76,
                pricing_attribute77,
                pricing_attribute78,
                pricing_attribute79,
                pricing_attribute80,
                pricing_attribute81,
                pricing_attribute82,
                pricing_attribute83,
                pricing_attribute84,
                pricing_attribute85,
                pricing_attribute86,
                pricing_attribute87,
                pricing_attribute88,
                pricing_attribute89,
                pricing_attribute90,
                pricing_attribute91,
                pricing_attribute92,
                pricing_attribute93,
                pricing_attribute94,
                pricing_attribute95,
                pricing_attribute96,
                pricing_attribute97,
                pricing_attribute98,
                pricing_attribute99,
                pricing_attribute100
           FROM csi_i_pricing_attribs a
          WHERE a.instance_id = p_inst_id;

      l_line_attr_tbl_ctr                     NUMBER;
      l_srv_csrrec                            l_topline_pa_csr%ROWTYPE;
      l_req_line_attr_rec2                    qp_preq_grp.line_attr_rec_type;
      l_api_name                     CONSTANT VARCHAR2 (30) := 'BUILD_CP_PA';
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

      l_line_attr_tbl_ctr        := px_line_attr_tbl_ctr;

      --myerror('CTR VALUE IN SUB PROCEDURE IS ' || l_line_attr_tbl_ctr);
      FOR l_srv_csrrec IN l_topline_pa_csr
      LOOP
         IF l_srv_csrrec.pricing_attribute1 IS NOT NULL
         THEN
            --myerror('1 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute1);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE1';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                               l_srv_csrrec.pricing_attribute1;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute2 IS NOT NULL
         THEN
            --myerror('2 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute2);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE2';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                               l_srv_csrrec.pricing_attribute2;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute3 IS NOT NULL
         THEN
            --myerror('3 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute3);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE3';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                               l_srv_csrrec.pricing_attribute3;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute4 IS NOT NULL
         THEN
            --myerror('4 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute4);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE4';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                               l_srv_csrrec.pricing_attribute4;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute5 IS NOT NULL
         THEN
            --myerror('5 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute5);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE5';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                               l_srv_csrrec.pricing_attribute5;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute6 IS NOT NULL
         THEN
            --myerror('6 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute6);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE6';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                               l_srv_csrrec.pricing_attribute6;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute7 IS NOT NULL
         THEN
            --myerror('7 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute7);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE7';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                               l_srv_csrrec.pricing_attribute7;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute8 IS NOT NULL
         THEN
            --myerror('8 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute8);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE8';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                               l_srv_csrrec.pricing_attribute8;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute9 IS NOT NULL
         THEN
            --myerror('9 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute9);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE9';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                               l_srv_csrrec.pricing_attribute9;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute10 IS NOT NULL
         THEN
            --myerror('10 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute10);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE10';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute10;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute11 IS NOT NULL
         THEN
            --myerror('11 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute11);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE11';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute11;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute12 IS NOT NULL
         THEN
            --myerror('12 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute12);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE12';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute12;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute13 IS NOT NULL
         THEN
            --myerror('13 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute13);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE13';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute13;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute14 IS NOT NULL
         THEN
            --myerror('14 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute14);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE14';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute14;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute15 IS NOT NULL
         THEN
            --myerror('15 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute15);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE15';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute15;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

--***** ADDED 10/25
         IF l_srv_csrrec.pricing_attribute16 IS NOT NULL
         THEN
            --myerror('16 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute16);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE16';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute16;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute17 IS NOT NULL
         THEN
            --myerror('17 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute17);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE17';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute17;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute18 IS NOT NULL
         THEN
            --myerror('18 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute18);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE18';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute18;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute19 IS NOT NULL
         THEN
            --myerror('19 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute19);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE19';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute19;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute20 IS NOT NULL
         THEN
            --myerror('20 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute20);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE20';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute20;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute21 IS NOT NULL
         THEN
            --myerror('21 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute21);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE21';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute21;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute22 IS NOT NULL
         THEN
            --myerror('22 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute22);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE22';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute22;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute23 IS NOT NULL
         THEN
            --myerror('23 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute23);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE23';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute23;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute24 IS NOT NULL
         THEN
            --myerror('24 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute24);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE24';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute24;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute25 IS NOT NULL
         THEN
            --myerror('25 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute25);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE25';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute25;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute26 IS NOT NULL
         THEN
            --myerror('26 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute26);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE26';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute26;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute27 IS NOT NULL
         THEN
            --myerror('27 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute27);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE27';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute27;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute28 IS NOT NULL
         THEN
            --myerror('28 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute28);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE28';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute28;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute29 IS NOT NULL
         THEN
            --myerror('29 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute29);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE29';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute29;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute30 IS NOT NULL
         THEN
            --myerror('30 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute30);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE30';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute30;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute31 IS NOT NULL
         THEN
            --myerror('31 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute31);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE31';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute31;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute32 IS NOT NULL
         THEN
            --myerror('32 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute32);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE32';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute32;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute33 IS NOT NULL
         THEN
            --myerror('33 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute33);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE33';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute33;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute34 IS NOT NULL
         THEN
            --myerror('34 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute34);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE34';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute34;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute35 IS NOT NULL
         THEN
            --myerror('35 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute35);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE35';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute35;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute36 IS NOT NULL
         THEN
            --myerror('36 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute36);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE36';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute36;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute37 IS NOT NULL
         THEN
            --myerror('37 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute37);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE37';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute37;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute38 IS NOT NULL
         THEN
            --myerror('38 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute38);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE38';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute38;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute39 IS NOT NULL
         THEN
            --myerror('39 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute39);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE39';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute39;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute40 IS NOT NULL
         THEN
            --myerror('40 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute40);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE40';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute40;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute41 IS NOT NULL
         THEN
            --myerror('41 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute41);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE41';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute41;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute42 IS NOT NULL
         THEN
            --myerror('42 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute42);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE42';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute42;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute43 IS NOT NULL
         THEN
            --myerror('43 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute43);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE43';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute43;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute44 IS NOT NULL
         THEN
            --myerror('44 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute44);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE44';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute44;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute45 IS NOT NULL
         THEN
            --myerror('45 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute45);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE45';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute45;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute46 IS NOT NULL
         THEN
            --myerror('46 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute46);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE46';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute46;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute47 IS NOT NULL
         THEN
            --myerror('47 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute47);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE47';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute47;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute48 IS NOT NULL
         THEN
            --myerror('48 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute48);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE48';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute48;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute49 IS NOT NULL
         THEN
            --myerror('49 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute49);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE49';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute49;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute50 IS NOT NULL
         THEN
            --myerror('50 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute50);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE50';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute50;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute51 IS NOT NULL
         THEN
            --myerror('51 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute51);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE51';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute51;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute52 IS NOT NULL
         THEN
            --myerror('52 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute52);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE52';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute52;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute53 IS NOT NULL
         THEN
            --myerror('53 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute53);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE53';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute53;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute54 IS NOT NULL
         THEN
            --myerror('54 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute54);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE54';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute54;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute55 IS NOT NULL
         THEN
            --myerror('55 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute55);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE55';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute55;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute56 IS NOT NULL
         THEN
            --myerror('56 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute56);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE56';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute56;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute57 IS NOT NULL
         THEN
            --myerror('57 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute57);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE57';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute57;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute58 IS NOT NULL
         THEN
            --myerror('58 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute58);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE58';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute58;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute59 IS NOT NULL
         THEN
            --myerror('59 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute59);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE59';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute59;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute60 IS NOT NULL
         THEN
            --myerror('60 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute60);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE60';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute60;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute61 IS NOT NULL
         THEN
            --myerror('61 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute61);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE61';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute61;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute62 IS NOT NULL
         THEN
            --myerror('62 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute62);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE62';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute62;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute63 IS NOT NULL
         THEN
            --myerror('63 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute63);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE63';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute63;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute64 IS NOT NULL
         THEN
            --myerror('64 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute64);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE64';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute64;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute65 IS NOT NULL
         THEN
            --myerror('65 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute65);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE65';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute65;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute66 IS NOT NULL
         THEN
            --myerror('66 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute66);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE66';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute66;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute67 IS NOT NULL
         THEN
            --myerror('67 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute67);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE67';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute67;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute68 IS NOT NULL
         THEN
            --myerror('68 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute68);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE68';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute68;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute69 IS NOT NULL
         THEN
            --myerror('69 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute69);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE69';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute69;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute70 IS NOT NULL
         THEN
            --myerror('70 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute70);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE70';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute70;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute71 IS NOT NULL
         THEN
            --myerror('71 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute71);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE71';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute71;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute72 IS NOT NULL
         THEN
            --myerror('72 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute72);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE72';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute72;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute73 IS NOT NULL
         THEN
            --myerror('73 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute73);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE73';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute73;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute74 IS NOT NULL
         THEN
            --myerror('74 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute74);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE74';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute74;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute75 IS NOT NULL
         THEN
            --myerror('75 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute75);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE75';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute75;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute76 IS NOT NULL
         THEN
            --myerror('76 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute76);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE76';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute76;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute77 IS NOT NULL
         THEN
            --myerror('77 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute77);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE77';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute77;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute78 IS NOT NULL
         THEN
            --myerror('78 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute78);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE78';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute78;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute79 IS NOT NULL
         THEN
            --myerror('79 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute79);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE79';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute79;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute80 IS NOT NULL
         THEN
            --myerror('80 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute80);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE80';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute80;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute81 IS NOT NULL
         THEN
            --myerror('81 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute81);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE81';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute81;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute82 IS NOT NULL
         THEN
            --myerror('82 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute82);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE82';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute82;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute83 IS NOT NULL
         THEN
            --myerror('83 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute83);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE83';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute83;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute84 IS NOT NULL
         THEN
            --myerror('84 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute84);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE84';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute84;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute85 IS NOT NULL
         THEN
            --myerror('85 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute85);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE85';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute85;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute86 IS NOT NULL
         THEN
            --myerror('86 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute86);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE86';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute86;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute87 IS NOT NULL
         THEN
            --myerror('87 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute87);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE87';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute87;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute88 IS NOT NULL
         THEN
            --myerror('88 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute88);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE88';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute88;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute89 IS NOT NULL
         THEN
            --myerror('89 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute89);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE89';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute89;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute90 IS NOT NULL
         THEN
            --myerror('90 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute90);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE90';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute90;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute91 IS NOT NULL
         THEN
            --myerror('91 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute91);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE91';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute91;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute92 IS NOT NULL
         THEN
            --myerror('92 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute92);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE92';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute92;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute93 IS NOT NULL
         THEN
            --myerror('93 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute93);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE93';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute93;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute94 IS NOT NULL
         THEN
            --myerror('94 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute94);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE94';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute94;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute95 IS NOT NULL
         THEN
            --myerror('95 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute95);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE95';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute95;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute96 IS NOT NULL
         THEN
            --myerror('96 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute96);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE96';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute96;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute97 IS NOT NULL
         THEN
            --myerror('97 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute97);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE97';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute97;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute98 IS NOT NULL
         THEN
            --myerror('98 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute98);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE98';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute98;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute99 IS NOT NULL
         THEN
            --myerror('99 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute99);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE99';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute99;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute100 IS NOT NULL
         THEN
            --myerror('100 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute100);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE100';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                             l_srv_csrrec.pricing_attribute100;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;
--***** ADDED 10/25
      END LOOP;

      px_line_attr_tbl_ctr       := l_line_attr_tbl_ctr;

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
   END;                                                          --BUILD_CP_PA

   PROCEDURE build_top_pa (
      p_cle_id                        IN       NUMBER,
      p_service_index                 IN       NUMBER,
      px_line_attr_tbl_ctr            IN OUT NOCOPY NUMBER,
      px_req_line_attr_tbl            IN OUT NOCOPY qp_preq_grp.line_attr_tbl_type
   )
   IS
  -- bug 4650072 (forward port bug 4884329), added function trim for all attributes as null was saved as a space character
      CURSOR l_topline_pa_csr
      IS
         SELECT pricing_context,
                TRIM(pricing_attribute1) pricing_attribute1,
                TRIM(pricing_attribute2) pricing_attribute2,
                TRIM(pricing_attribute3) pricing_attribute3,
                TRIM(pricing_attribute4) pricing_attribute4,
                TRIM(pricing_attribute5) pricing_attribute5,
                TRIM(pricing_attribute6) pricing_attribute6,
                TRIM(pricing_attribute7) pricing_attribute7,
                TRIM(pricing_attribute8) pricing_attribute8,
                TRIM(pricing_attribute9) pricing_attribute9,
                TRIM(pricing_attribute10) pricing_attribute10,
                TRIM(pricing_attribute11) pricing_attribute11,
                TRIM(pricing_attribute12) pricing_attribute12,
                TRIM(pricing_attribute13) pricing_attribute13,
                TRIM(pricing_attribute14) pricing_attribute14,
                TRIM(pricing_attribute15) pricing_attribute15,
                TRIM(pricing_attribute16) pricing_attribute16,
                TRIM(pricing_attribute17) pricing_attribute17,
                TRIM(pricing_attribute18) pricing_attribute18,
                TRIM(pricing_attribute19) pricing_attribute19,
                TRIM(pricing_attribute20) pricing_attribute20,
                TRIM(pricing_attribute21) pricing_attribute21,
                TRIM(pricing_attribute22) pricing_attribute22,
                TRIM(pricing_attribute23) pricing_attribute23,
                TRIM(pricing_attribute24) pricing_attribute24,
                TRIM(pricing_attribute25) pricing_attribute25,
                TRIM(pricing_attribute26) pricing_attribute26,
                TRIM(pricing_attribute27) pricing_attribute27,
                TRIM(pricing_attribute28) pricing_attribute28,
                TRIM(pricing_attribute29) pricing_attribute29,
                TRIM(pricing_attribute30) pricing_attribute30,
                TRIM(pricing_attribute31) pricing_attribute31,
                TRIM(pricing_attribute32) pricing_attribute32,
                TRIM(pricing_attribute33) pricing_attribute33,
                TRIM(pricing_attribute34) pricing_attribute34,
                TRIM(pricing_attribute35) pricing_attribute35,
                TRIM(pricing_attribute36) pricing_attribute36,
                TRIM(pricing_attribute37) pricing_attribute37,
                TRIM(pricing_attribute38) pricing_attribute38,
                TRIM(pricing_attribute39) pricing_attribute39,
                TRIM(pricing_attribute40) pricing_attribute40,
                TRIM(pricing_attribute41) pricing_attribute41,
                TRIM(pricing_attribute42) pricing_attribute42,
                TRIM(pricing_attribute43) pricing_attribute43,
                TRIM(pricing_attribute44) pricing_attribute44,
                TRIM(pricing_attribute45) pricing_attribute45,
                TRIM(pricing_attribute46) pricing_attribute46,
                TRIM(pricing_attribute47) pricing_attribute47,
                TRIM(pricing_attribute48) pricing_attribute48,
                TRIM(pricing_attribute49) pricing_attribute49,
                TRIM(pricing_attribute50) pricing_attribute50,
                TRIM(pricing_attribute51) pricing_attribute51,
                TRIM(pricing_attribute52) pricing_attribute52,
                TRIM(pricing_attribute53) pricing_attribute53,
                TRIM(pricing_attribute54) pricing_attribute54,
                TRIM(pricing_attribute55) pricing_attribute55,
                TRIM(pricing_attribute56) pricing_attribute56,
                TRIM(pricing_attribute57) pricing_attribute57,
                TRIM(pricing_attribute58) pricing_attribute58,
                TRIM(pricing_attribute59) pricing_attribute59,
                TRIM(pricing_attribute60) pricing_attribute60,
                TRIM(pricing_attribute61) pricing_attribute61,
                TRIM(pricing_attribute62) pricing_attribute62,
                TRIM(pricing_attribute63) pricing_attribute63,
                TRIM(pricing_attribute64) pricing_attribute64,
                TRIM(pricing_attribute65) pricing_attribute65,
                TRIM(pricing_attribute66) pricing_attribute66,
                TRIM(pricing_attribute67) pricing_attribute67,
                TRIM(pricing_attribute68) pricing_attribute68,
                TRIM(pricing_attribute69) pricing_attribute69,
                TRIM(pricing_attribute70) pricing_attribute70,
                TRIM(pricing_attribute71) pricing_attribute71,
                TRIM(pricing_attribute72) pricing_attribute72,
                TRIM(pricing_attribute73) pricing_attribute73,
                TRIM(pricing_attribute74) pricing_attribute74,
                TRIM(pricing_attribute75) pricing_attribute75,
                TRIM(pricing_attribute76) pricing_attribute76,
                TRIM(pricing_attribute77) pricing_attribute77,
                TRIM(pricing_attribute78) pricing_attribute78,
                TRIM(pricing_attribute79) pricing_attribute79,
                TRIM(pricing_attribute80) pricing_attribute80,
                TRIM(pricing_attribute81) pricing_attribute81,
                TRIM(pricing_attribute82) pricing_attribute82,
                TRIM(pricing_attribute83) pricing_attribute83,
                TRIM(pricing_attribute84) pricing_attribute84,
                TRIM(pricing_attribute85) pricing_attribute85,
                TRIM(pricing_attribute86) pricing_attribute86,
                TRIM(pricing_attribute87) pricing_attribute87,
                TRIM(pricing_attribute88) pricing_attribute88,
                TRIM(pricing_attribute89) pricing_attribute89,
                TRIM(pricing_attribute90) pricing_attribute90,
                TRIM(pricing_attribute91) pricing_attribute91,
                TRIM(pricing_attribute92) pricing_attribute92,
                TRIM(pricing_attribute93) pricing_attribute93,
                TRIM(pricing_attribute94) pricing_attribute94,
                TRIM(pricing_attribute95) pricing_attribute95,
                TRIM(pricing_attribute96) pricing_attribute96,
                TRIM(pricing_attribute97) pricing_attribute97,
                TRIM(pricing_attribute98) pricing_attribute98,
                TRIM(pricing_attribute99) pricing_attribute99,
                TRIM(pricing_attribute100) pricing_attribute100
           FROM okc_price_att_values_v a
          WHERE a.cle_id = p_cle_id;

      l_line_attr_tbl_ctr                     NUMBER;
      l_srv_csrrec                            l_topline_pa_csr%ROWTYPE;
      l_req_line_attr_rec2                    qp_preq_grp.line_attr_rec_type;
      l_api_name                     CONSTANT VARCHAR2 (30) := 'BUILD_TOP_PA';
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

      l_line_attr_tbl_ctr        := px_line_attr_tbl_ctr;

      FOR l_srv_csrrec IN l_topline_pa_csr
      LOOP
         IF l_srv_csrrec.pricing_attribute1 IS NOT NULL
         THEN
            --myerror('1 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute1);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE1';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                               l_srv_csrrec.pricing_attribute1;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute2 IS NOT NULL
         THEN
            --myerror('2 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute2);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE2';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                               l_srv_csrrec.pricing_attribute2;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute3 IS NOT NULL
         THEN
            --myerror('3 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute3);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE3';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                               l_srv_csrrec.pricing_attribute3;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute4 IS NOT NULL
         THEN
            --myerror('4 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute4);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE4';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                               l_srv_csrrec.pricing_attribute4;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute5 IS NOT NULL
         THEN
            --myerror('5 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute5);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE5';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                               l_srv_csrrec.pricing_attribute5;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute6 IS NOT NULL
         THEN
            --myerror('6 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute6);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE6';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                               l_srv_csrrec.pricing_attribute6;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute7 IS NOT NULL
         THEN
            --myerror('7 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute7);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE7';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                               l_srv_csrrec.pricing_attribute7;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute8 IS NOT NULL
         THEN
            --myerror('8 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute8);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE8';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                               l_srv_csrrec.pricing_attribute8;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute9 IS NOT NULL
         THEN
            --myerror('9 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute9);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE9';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                               l_srv_csrrec.pricing_attribute9;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute10 IS NOT NULL
         THEN
            --myerror('10 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute10);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE10';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute10;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute11 IS NOT NULL
         THEN
            --myerror('11 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute11);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE11';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute11;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute12 IS NOT NULL
         THEN
            --myerror('12 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute12);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE12';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute12;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute13 IS NOT NULL
         THEN
            --myerror('13 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute13);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE13';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute13;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute14 IS NOT NULL
         THEN
            --myerror('14 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute14);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE14';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute14;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute15 IS NOT NULL
         THEN
            --myerror('15 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute15);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE15';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute15;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

--***** ADDED 10/25
         IF l_srv_csrrec.pricing_attribute16 IS NOT NULL
         THEN
            --myerror('16 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute16);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE16';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute16;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute17 IS NOT NULL
         THEN
            --myerror('17 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute17);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE17';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute17;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute18 IS NOT NULL
         THEN
            --myerror('18 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute18);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE18';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute18;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute19 IS NOT NULL
         THEN
            --myerror('19 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute19);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE19';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute19;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute20 IS NOT NULL
         THEN
            --myerror('20 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute20);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE20';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute20;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute21 IS NOT NULL
         THEN
            --myerror('21 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute21);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE21';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute21;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute22 IS NOT NULL
         THEN
            --myerror('22 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute22);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE22';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute22;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute23 IS NOT NULL
         THEN
            --myerror('23 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute23);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE23';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute23;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute24 IS NOT NULL
         THEN
            --myerror('24 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute24);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE24';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute24;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute25 IS NOT NULL
         THEN
            --myerror('25 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute25);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE25';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute25;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute26 IS NOT NULL
         THEN
            --myerror('26 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute26);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE26';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute26;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute27 IS NOT NULL
         THEN
            --myerror('27 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute27);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE27';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute27;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute28 IS NOT NULL
         THEN
            --myerror('28 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute28);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE28';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute28;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute29 IS NOT NULL
         THEN
            --myerror('29 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute29);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE29';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute29;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute30 IS NOT NULL
         THEN
            --myerror('30 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute30);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE30';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute30;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute31 IS NOT NULL
         THEN
            --myerror('31 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute31);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE31';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute31;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute32 IS NOT NULL
         THEN
            --myerror('32 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute32);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE32';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute32;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute33 IS NOT NULL
         THEN
            --myerror('33 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute33);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE33';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute33;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute34 IS NOT NULL
         THEN
            --myerror('34 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute34);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE34';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute34;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute35 IS NOT NULL
         THEN
            --myerror('35 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute35);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE35';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute35;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute36 IS NOT NULL
         THEN
            --myerror('36 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute36);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE36';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute36;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute37 IS NOT NULL
         THEN
            --myerror('37 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute37);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE37';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute37;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute38 IS NOT NULL
         THEN
            --myerror('38 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute38);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE38';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute38;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute39 IS NOT NULL
         THEN
            --myerror('39 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute39);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE39';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute39;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute40 IS NOT NULL
         THEN
            --myerror('40 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute40);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE40';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute40;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute41 IS NOT NULL
         THEN
            --myerror('41 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute41);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE41';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute41;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute42 IS NOT NULL
         THEN
            --myerror('42 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute42);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE42';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute42;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute43 IS NOT NULL
         THEN
            --myerror('43 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute43);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE43';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute43;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute44 IS NOT NULL
         THEN
            --myerror('44 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute44);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE44';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute44;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute45 IS NOT NULL
         THEN
            --myerror('45 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute45);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE45';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute45;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute46 IS NOT NULL
         THEN
            --myerror('46 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute46);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE46';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute46;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute47 IS NOT NULL
         THEN
            --myerror('47 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute47);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE47';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute47;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute48 IS NOT NULL
         THEN
            --myerror('48 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute48);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE48';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute48;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute49 IS NOT NULL
         THEN
            --myerror('49 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute49);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE49';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute49;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute50 IS NOT NULL
         THEN
            --myerror('50 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute50);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE50';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute50;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute51 IS NOT NULL
         THEN
            --myerror('51 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute51);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE51';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute51;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute52 IS NOT NULL
         THEN
            --myerror('52 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute52);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE52';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute52;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute53 IS NOT NULL
         THEN
            --myerror('53 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute53);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE53';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute53;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute54 IS NOT NULL
         THEN
            --myerror('54 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute54);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE54';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute54;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute55 IS NOT NULL
         THEN
            --myerror('55 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute55);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE55';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute55;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute56 IS NOT NULL
         THEN
            --myerror('56 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute56);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE56';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute56;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute57 IS NOT NULL
         THEN
            --myerror('57 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute57);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE57';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute57;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute58 IS NOT NULL
         THEN
            --myerror('58 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute58);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE58';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute58;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute59 IS NOT NULL
         THEN
            --myerror('59 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute59);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE59';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute59;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute60 IS NOT NULL
         THEN
            --myerror('60 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute60);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE60';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute60;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute61 IS NOT NULL
         THEN
            --myerror('61 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute61);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE61';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute61;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute62 IS NOT NULL
         THEN
            --myerror('62 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute62);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE62';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute62;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute63 IS NOT NULL
         THEN
            --myerror('63 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute63);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE63';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute63;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute64 IS NOT NULL
         THEN
            --myerror('64 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute64);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE64';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute64;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute65 IS NOT NULL
         THEN
            --myerror('65 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute65);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE65';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute65;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute66 IS NOT NULL
         THEN
            --myerror('66 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute66);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE66';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute66;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute67 IS NOT NULL
         THEN
            --myerror('67 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute67);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE67';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute67;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute68 IS NOT NULL
         THEN
            --myerror('68 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute68);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE68';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute68;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute69 IS NOT NULL
         THEN
            --myerror('69 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute69);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE69';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute69;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute70 IS NOT NULL
         THEN
            --myerror('70 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute70);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE70';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute70;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute71 IS NOT NULL
         THEN
            --myerror('71 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute71);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE71';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute71;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute72 IS NOT NULL
         THEN
            --myerror('72 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute72);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE72';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute72;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute73 IS NOT NULL
         THEN
            --myerror('73 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute73);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE73';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute73;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute74 IS NOT NULL
         THEN
            --myerror('74 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute74);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE74';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute74;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute75 IS NOT NULL
         THEN
            --myerror('75 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute75);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE75';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute75;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute76 IS NOT NULL
         THEN
            --myerror('76 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute76);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE76';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute76;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute77 IS NOT NULL
         THEN
            --myerror('77 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute77);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE77';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute77;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute78 IS NOT NULL
         THEN
            --myerror('78 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute78);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE78';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute78;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute79 IS NOT NULL
         THEN
            --myerror('79 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute79);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE79';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute79;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute80 IS NOT NULL
         THEN
            --myerror('80 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute80);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE80';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute80;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute81 IS NOT NULL
         THEN
            --myerror('81 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute81);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE81';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute81;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute82 IS NOT NULL
         THEN
            --myerror('82 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute82);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE82';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute82;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute83 IS NOT NULL
         THEN
            --myerror('83 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute83);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE83';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute83;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute84 IS NOT NULL
         THEN
            --myerror('84 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute84);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE84';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute84;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute85 IS NOT NULL
         THEN
            --myerror('85 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute85);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE85';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute85;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute86 IS NOT NULL
         THEN
            --myerror('86 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute86);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE86';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute86;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute87 IS NOT NULL
         THEN
            --myerror('87 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute87);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE87';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute87;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute88 IS NOT NULL
         THEN
            --myerror('88 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute88);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE88';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute88;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute89 IS NOT NULL
         THEN
            --myerror('89 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute89);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE89';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute89;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute90 IS NOT NULL
         THEN
            --myerror('90 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute90);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE90';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute90;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute91 IS NOT NULL
         THEN
            --myerror('91 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute91);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE91';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute91;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute92 IS NOT NULL
         THEN
            --myerror('92 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute92);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE92';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute92;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute93 IS NOT NULL
         THEN
            --myerror('93 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute93);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE93';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute93;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute94 IS NOT NULL
         THEN
            --myerror('94 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute94);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE94';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute94;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute95 IS NOT NULL
         THEN
            --myerror('95 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute95);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE95';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute95;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute96 IS NOT NULL
         THEN
            --myerror('96 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute96);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE96';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute96;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute97 IS NOT NULL
         THEN
            --myerror('97 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute97);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE97';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute97;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute98 IS NOT NULL
         THEN
            --myerror('98 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute98);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE98';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute98;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute99 IS NOT NULL
         THEN
            --myerror('99 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute99);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE99';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                              l_srv_csrrec.pricing_attribute99;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;

         IF l_srv_csrrec.pricing_attribute100 IS NOT NULL
         THEN
            --myerror('100 ' || l_srv_csrrec.pricing_context || ' - ' || l_srv_csrrec.pricing_attribute100);
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec2.line_index := p_service_index;
            l_req_line_attr_rec2.pricing_context :=
                                                  l_srv_csrrec.pricing_context;
            l_req_line_attr_rec2.pricing_attribute := 'PRICING_ATTRIBUTE100';
            l_req_line_attr_rec2.pricing_attr_value_from :=
                                             l_srv_csrrec.pricing_attribute100;
            l_req_line_attr_rec2.validated_flag := 'N';
            px_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec2;
         END IF;
--***** ADDED 10/25
      END LOOP;

      px_line_attr_tbl_ctr       := l_line_attr_tbl_ctr;

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
   END build_top_pa;

   FUNCTION get_uom (
      p_id                                     NUMBER,
      p_inv_org                                NUMBER
   )
      RETURN VARCHAR2
   IS
      l_ret_value                             VARCHAR2 (1000);
      l_api_name                     CONSTANT VARCHAR2 (30) := 'get_uom';
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

      SELECT DISTINCT primary_uom_code
                 INTO l_ret_value
                 FROM mtl_system_items
                WHERE inventory_item_id = p_id    AND
                      organization_id = p_inv_org;

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

      RETURN l_ret_value;
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
         RETURN 'Ea';
   END;

   PROCEDURE calc_price (
      p_detail_rec                    IN       input_details,
      x_price_details                 OUT NOCOPY price_details,
      x_modifier_details              OUT NOCOPY qp_preq_grp.line_detail_tbl_type,
      x_price_break_details           OUT NOCOPY g_price_break_tbl_type,
      x_return_status                 OUT NOCOPY VARCHAR2,
      x_msg_count                     OUT NOCOPY NUMBER,
      x_msg_data                      OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name                     CONSTANT VARCHAR2 (30) := 'CALC_PRICE';
--QP Variables
      l_control_rec                           qp_preq_grp.control_record_type;
      l_req_line_tbl                          qp_preq_grp.line_tbl_type;
      l_req_line_detail_tbl                   qp_preq_grp.line_detail_tbl_type;
      l_req_related_lines_tbl                 qp_preq_grp.related_lines_tbl_type;
      l_req_qual_tbl                          qp_preq_grp.qual_tbl_type;
      l_req_line_attr_tbl                     qp_preq_grp.line_attr_tbl_type;
      l_req_line_detail_qual_tbl              qp_preq_grp.line_detail_qual_tbl_type;
      l_req_line_detail_attr_tbl              qp_preq_grp.line_detail_attr_tbl_type;
      l_req_line_rec                          qp_preq_grp.line_rec_type;
      l_req_line_rec2                         qp_preq_grp.line_rec_type;
      l_req_line_rec3                         qp_preq_grp.line_rec_type;
      l_req_line_rec4                         qp_preq_grp.line_rec_type;
      l_req_qual_rec                          qp_preq_grp.qual_rec_type;
      l_req_line_attr_rec                     qp_preq_grp.line_attr_rec_type;
      l_req_line_detail_rec                   qp_preq_grp.line_detail_rec_type;
      l_req_line_detail_rec2                  qp_preq_grp.line_detail_rec_type;
      l_req_related_lines_rec                 qp_preq_grp.related_lines_rec_type;
      lx_req_line_tbl                         qp_preq_grp.line_tbl_type;
      lx_req_qual_tbl                         qp_preq_grp.qual_tbl_type;
      lx_req_line_attr_tbl                    qp_preq_grp.line_attr_tbl_type;
      lx_req_line_detail_tbl                  qp_preq_grp.line_detail_tbl_type;
      lx_req_line_detail_qual_tbl             qp_preq_grp.line_detail_qual_tbl_type;
      lx_req_line_detail_attr_tbl             qp_preq_grp.line_detail_attr_tbl_type;
      lx_req_related_lines_tbl                qp_preq_grp.related_lines_tbl_type;
      lx_return_status                        VARCHAR2 (1);
      lx_return_status_text                   VARCHAR2 (2000);
--General Variables;
      l_ctr                                   NUMBER;
      l_top_ctr                               NUMBER;
      i                                       NUMBER;
      i2                                      NUMBER;
      l_return_status                         VARCHAR2 (200);
      l_msg_count                             NUMBER;
      l_msg_data                              VARCHAR2 (2000);
      l_index                                 NUMBER;
      l_line_tbl_ctr                          NUMBER := 0;
      l_line_detl_tbl_ctr                     NUMBER := 0;
      l_line_attr_tbl_ctr                     NUMBER := 0;
      l_line_qual_tbl_ctr                     NUMBER := 0;
      l_line_rela_tbl_ctr                     NUMBER := 0;
      l_product_index                         NUMBER := 0;
      l_product_hdr_index                     NUMBER := 0;
      l_service_index                         NUMBER := 0;
      l_service_hdr_index                     NUMBER := 0;
      l_pricing_event                         VARCHAR2 (20);
      l_request_type_code                     VARCHAR2 (20);
      l_line_type_code                        VARCHAR2 (20);
      l_price_id                              NUMBER;
      l_def_pricing_date                      DATE;
      l_def_pricing_profile                   VARCHAR2 (240);
      l_currency                              VARCHAR2 (240);
      l_qpprod_inv_id                         NUMBER;
      l_qpprod_quantity                       NUMBER;
      l_qpprod_uom_code                       VARCHAR2 (240);
      l_qpserv_inv_id                         NUMBER;
      l_qpserv_quantity                       NUMBER;
      l_qpserv_uom_code                       VARCHAR2 (240);
      l_tangible                              BOOLEAN;
      p                                       NUMBER; -- fnd_debug variable bug 5069673
--Table Handler Variables
      l_rule_rec                              okc_rule_pvt.rulv_rec_type;
      l_patv_tbl                              okc_price_adjustment_pub.patv_tbl_type;
      lx_patv_tbl                             okc_price_adjustment_pub.patv_tbl_type;
--Variables for Price Break
      l_price_break_tbl                       g_price_break_tbl_type;
      l_rel_index                             NUMBER;
      l_lin_index                             NUMBER;
      l_party_id                              NUMBER;
      l_customer_id                           NUMBER;
      l_pricing_contexts_tbl                  qp_attr_mapping_pub.contexts_result_tbl_type;
      l_qual_contexts_tbl                     qp_attr_mapping_pub.contexts_result_tbl_type;
--variables for partial periods logic
      l_period_type                           VARCHAR2 (30);
      l_period_start                          VARCHAR2 (30);
      l_price_uom                             VARCHAR2 (30);
      l_chr_id                                NUMBER;
      invalid_hdr_id_exception                EXCEPTION;

--Cursor Variables
      CURSOR l_skg_csr
      IS
         SELECT kh.ID kh_id,
                kh.start_date kh_start_date,
                kh.date_signed kh_signed_date,
                kh.currency_code kh_currency_code,
                kh.authoring_org_id kh_auth_org,
                kh.inv_organization_id inv_org,
                kh.price_list_id price_list_id,
                kh.bill_to_site_use_id kh_bill_to,
                kh.ship_to_site_use_id kh_ship_to,
                kh.payment_term_id kh_payment_term_id
           FROM okc_k_headers_all_b kh
          WHERE kh.ID = p_detail_rec.chr_id;

      l_skg_rec                               l_skg_csr%ROWTYPE;

      -- GCHADHA --
      -- 20 OCT 2004  --
      -- MULTI CURRENCY PRICELIST --
      --  Added Conversion_type and conversion_rate in the cursor
      CURSOR l_hdrtop_csr
      IS
         SELECT kh.ID kh_id,
                kh.start_date kh_start_date,
                kh.date_signed kh_signed_date,
                kh.currency_code kh_currency_code,
                kh.conversion_type kh_conversion_type,                  -- new
                kh.conversion_rate kh_conversion_rate,                  -- new
                kh.authoring_org_id kh_auth_org,
                kh.inv_organization_id inv_org,
                NVL (kl.price_list_id, kh.price_list_id) price_list_id,
                kh.bill_to_site_use_id kh_bill_to,
                kh.ship_to_site_use_id kh_ship_to,
                kh.payment_term_id kh_payment_term_id,
                kl.ID tl_id,
                kl.start_date tl_start_date,
                kl.end_date tl_end_date,
                kl.lse_id tl_line_style,
                kl.bill_to_site_use_id tl_bill_to,
                kl.ship_to_site_use_id tl_ship_to,
                kl.payment_term_id tl_payment_term_id,
                ki.object1_id1 tl_object_id,
                ki.number_of_items tl_qty,
                ki.uom_code tl_uom_code
           FROM okc_k_headers_all_b kh,
                okc_k_lines_b kl,
                okc_k_items ki
          WHERE kh.ID = kl.chr_id            AND
                kl.ID = p_detail_rec.line_id AND
                ki.cle_id = kl.ID;

      l_hdrtop_rec                            l_hdrtop_csr%ROWTYPE;

      CURSOR l_subline_csr
      IS
         SELECT kl.ID sl_id,
                kl.start_date sl_start_date,
                kl.end_date sl_end_date,
                kl.lse_id sl_line_style,
                ki.object1_id1 sl_object_id,
                ki.number_of_items sl_qty,
                ki.uom_code sl_uom_code,
                ks.price_uom sl_price_uom
           FROM okc_k_lines_b kl,
                okc_k_items ki,
                oks_k_lines_b ks
          WHERE kl.ID = p_detail_rec.subline_id AND
                ks.cle_id = kl.ID               AND
                ki.cle_id = kl.ID;

      l_subline_rec                           l_subline_csr%ROWTYPE;

      CURSOR l_get_hdrid_csr (
         p_cle_id                                 NUMBER
      )
      IS
         SELECT dnz_chr_id
           FROM okc_k_lines_b
          WHERE ID = p_cle_id;

      FUNCTION get_customer_id (
         p_chr_id                        IN       NUMBER,
         p_cle_id                        IN       NUMBER
      )
         RETURN NUMBER
      IS
         l_cust_id                               NUMBER;
         l_api_name                     CONSTANT VARCHAR2 (30)
                                                         := 'get_customer_id';
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

/*
      Select object1_id1 Into l_cust_id
      From OKC_RULE_GROUPS_B rgp,
         OKC_RULES_B rl
      Where rgp.dnz_chr_id = p_chr_id  and
         rgp.cle_id     = p_cle_id  and
         rgp.id         = rl.rgp_id and
         rl.rule_information_category = 'CAN';
*/
         SELECT cust_acct_id
           INTO l_cust_id
           FROM okc_k_lines_b
          WHERE ID = p_cle_id;

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

         RETURN l_cust_id;
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

            RETURN NULL;
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
            RETURN NULL;
      END;

      FUNCTION get_customer_from_siteuse (
         p_site_use_id                   IN       NUMBER
      )
         RETURN NUMBER
      IS
         l_cust_id                               NUMBER;
         l_api_name                     CONSTANT VARCHAR2 (30)
                                               := 'get_customer_from_siteuse';
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

         SELECT cust_account_id
           INTO l_cust_id
           FROM hz_cust_site_uses_all cs,
                hz_cust_acct_sites_all ca
          WHERE site_use_id = p_site_use_id                 AND
                ca.cust_acct_site_id = cs.cust_acct_site_id;

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

         RETURN l_cust_id;
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

            RETURN NULL;
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
            RETURN NULL;
      END;

      FUNCTION get_agreement_id (
         p_chr_id                        IN       NUMBER
      )
         RETURN NUMBER
      IS
         l_id                                    NUMBER;
         l_api_name                     CONSTANT VARCHAR2 (30)
                                                        := 'get_agreement_id';
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

         SELECT isa_agreement_id
           INTO l_id
           FROM okc_governances
          WHERE chr_id = p_chr_id;

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

         RETURN l_id;
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

            RETURN NULL;
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

            RETURN NULL;
      END;

      FUNCTION get_party_id (
         p_chr_id                        IN       NUMBER
      )
         RETURN NUMBER
      IS
         l_id                                    NUMBER;
         l_api_name                     CONSTANT VARCHAR2 (30)
                                                            := 'get_party_id';
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

         SELECT object1_id1
           INTO l_id
           FROM okc_k_party_roles_b
          WHERE chr_id = p_chr_id                      AND
                dnz_chr_id = p_chr_id                  AND
                cle_id IS NULL                         AND
                rle_code IN ('CUSTOMER', 'SUBSCRIBER');

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

         RETURN l_id;
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

            RETURN NULL;
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
            RETURN NULL;
      END;
-- CALC PROCEDURE STARTS
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

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '401:******** INTENT ***************** ' ||
                         p_detail_rec.intent
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '402:******** CHR ID         ********* ' ||
                         p_detail_rec.chr_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '403:******** LINE_ID **************** ' ||
                         p_detail_rec.line_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '404:******** SUB_LINE_ID************* ' ||
                         p_detail_rec.subline_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '405:******** PRICE LIST     ********* ' ||
                         p_detail_rec.price_list
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '406:******** PRICE LIST LINE ID   *** ' ||
                         p_detail_rec.price_list_line_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '407:******** CURRENCY       ********* ' ||
                         p_detail_rec.currency
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '408:******** BCL ID         ********* ' ||
                         p_detail_rec.bcl_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '409:******** BSL ID         ********* ' ||
                         p_detail_rec.bsl_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '410:******** USAGE QTY      ********* ' ||
                         p_detail_rec.usage_qty
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '411:******** USAGE UOM      ********* ' ||
                         p_detail_rec.usage_uom_code
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '412:******** BREAK UOM      ********* ' ||
                         p_detail_rec.break_uom_code
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '413:******** PRORATION YN   ********* ' ||
                         p_detail_rec.proration_yn
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '414:******** PRORATION YN   ********* ' ||
                         p_detail_rec.proration_yn
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '415:******** BILL FROM DT   ********* ' ||
                         p_detail_rec.bill_from_date
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '416:******** BILL TO   DT   ********* ' ||
                         p_detail_rec.bill_to_date
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '417:******** ASKING_UNIT_PRICE ****** ' ||
                         p_detail_rec.asking_unit_price
                        );
      END IF;

--dbms_output.put_line ('******** INTENT ***************** ' || p_detail_rec.intent);
--dbms_output.put_line ('******** CHR ID         ********* ' || p_detail_rec.chr_id);
--dbms_output.put_line ('******** LINE_ID **************** ' || p_detail_rec.line_id);
--dbms_output.put_line ('******** SUB_LINE_ID************* ' || p_detail_rec.subline_id);
--dbms_output.put_line ('******** PRICE LIST     ********* ' || p_detail_rec.price_list);
--dbms_output.put_line ('******** PRICE LIST LINE ID   *** ' || p_detail_rec.price_list_line_id);
--dbms_output.put_line ('******** CURRENCY       ********* ' || p_detail_rec.currency);
--dbms_output.put_line ('******** BCL ID         ********* ' || p_detail_rec.bcl_id);
--dbms_output.put_line ('******** BSL ID         ********* ' || p_detail_rec.bsl_id);
--dbms_output.put_line ('******** USAGE QTY      ********* ' || p_detail_rec.usage_qty);
--dbms_output.put_line ('******** USAGE UOM      ********* ' || p_detail_rec.usage_uom_code);
--dbms_output.put_line ('******** BREAK UOM      ********* ' || p_detail_rec.break_uom_code);
--dbms_output.put_line ('******** PRORATION YN   ********* ' || p_detail_rec.proration_yn);
--dbms_output.put_line ('******** PRORATION YN   ********* ' || p_detail_rec.proration_yn);
--dbms_output.put_line ('******** BILL FROM DT   ********* ' || p_detail_rec.bill_from_date);
--dbms_output.put_line ('******** BILL TO   DT   ********* ' || p_detail_rec.bill_to_date);
--dbms_output.put_line ('******** ASKING_UNIT_PRICE ****** ' || p_detail_rec.asking_unit_price);

      --Hdr-TopLine Cursor
      x_return_status            := 'S';

      OPEN l_hdrtop_csr;

      FETCH l_hdrtop_csr
       INTO l_hdrtop_rec;

      CLOSE l_hdrtop_csr;

--SubLine Cursor
      OPEN l_subline_csr;

      FETCH l_subline_csr
       INTO l_subline_rec;

      CLOSE l_subline_csr;

-- GCHADHA --
-- 20 OCT 2004 --
-- MULTI CURRENCY PRICELIST --
      l_control_rec.user_conversion_type := l_hdrtop_rec.kh_conversion_type;
      -- Get the Functional currency  --
      l_control_rec.function_currency :=
                   okc_currency_api.get_ou_currency (l_hdrtop_rec.kh_auth_org);

      -- If conversion type is 'USER' pass conversion rate to QP
      IF UPPER (NVL (l_hdrtop_rec.kh_conversion_type, '!')) = 'USER'
      THEN
         l_control_rec.user_conversion_rate :=
                                              l_hdrtop_rec.kh_conversion_rate;
      ELSE
         l_control_rec.user_conversion_rate := NULL;
      END IF;

      -- END GCHADHA --

      --TOP LINE REC DISPLAY
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '501:*** TL-CONTRACT ID **** ' ||
                         l_hdrtop_rec.kh_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '502:*** TL-KH STRT  DT **** ' ||
                         l_hdrtop_rec.kh_start_date
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '503:*** TL-KH SIGN  DT **** ' ||
                         l_hdrtop_rec.kh_signed_date
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '504:*** TL-KH CURR  CD **** ' ||
                         l_hdrtop_rec.kh_currency_code
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '505:*** TL-TL LINE  ID **** ' ||
                         l_hdrtop_rec.tl_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '506:*** TL-TL START DT **** ' ||
                         l_hdrtop_rec.tl_start_date
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '507:*** TL-TL END   DT **** ' ||
                         l_hdrtop_rec.tl_end_date
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '508:*** TL-TL LINE STY **** ' ||
                         l_hdrtop_rec.tl_line_style
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '509:*** TL-TL OBJ1_ID1 **** ' ||
                         l_hdrtop_rec.tl_object_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '510:*** TL-TL OBJ  QTY **** ' ||
                         l_hdrtop_rec.tl_qty
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '511:*** TL-TL OBJ  UOM **** ' ||
                         l_hdrtop_rec.tl_uom_code
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '511:*** TL-TL PRICE LIST **** ' ||
                         l_hdrtop_rec.price_list_id
                        );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '512:*************************************************************************'
            );
      END IF;

--dbms_output.put_line ('*** TL-CONTRACT ID **** ' ||l_hdrtop_rec.kh_id);
--dbms_output.put_line ('*** TL-KH STRT  DT **** ' ||l_hdrtop_rec.kh_start_date);
--dbms_output.put_line ('*** TL-KH SIGN  DT **** ' ||l_hdrtop_rec.kh_signed_date);
--dbms_output.put_line ('*** TL-KH CURR  CD **** ' ||l_hdrtop_rec.kh_currency_code);
--dbms_output.put_line ('*** TL-TL LINE  ID **** ' ||l_hdrtop_rec.tl_id);
--dbms_output.put_line ('*** TL-TL START DT **** ' ||l_hdrtop_rec.tl_start_date);
--dbms_output.put_line ('*** TL-TL END   DT **** ' ||l_hdrtop_rec.tl_end_date);
--dbms_output.put_line ('*** TL-TL LINE STY **** ' ||l_hdrtop_rec.tl_line_style);
--dbms_output.put_line ('*** TL-TL OBJ1_ID1 **** ' ||l_hdrtop_rec.tl_object_id);
--dbms_output.put_line ('*** TL-TL OBJ  QTY **** ' ||l_hdrtop_rec.tl_qty);
--dbms_output.put_line ('*** TL-TL OBJ  UOM **** ' ||l_hdrtop_rec.tl_uom_code);

      --dbms_output.put_line ('*************************************************************************');

      --SUB LINE REC DISPLAY
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '601:*** SL-SL LINE  ID **** ' ||
                         l_subline_rec.sl_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '602:*** SL-SL START DT **** ' ||
                         l_subline_rec.sl_start_date
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '603:*** SL-SL END   DT **** ' ||
                         l_subline_rec.sl_end_date
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '604:*** SL-SL LINE STY **** ' ||
                         l_subline_rec.sl_line_style
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '605:*** SL-SL OBJ1_ID1 **** ' ||
                         l_subline_rec.sl_object_id
                        );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '606:*************************************************************************'
            );
      END IF;

--dbms_output.put_line ('*** SL-SL LINE  ID **** ' ||l_subline_rec.sl_id);
--dbms_output.put_line ('*** SL-SL START DT **** ' ||l_subline_rec.sl_start_date);
--dbms_output.put_line ('*** SL-SL END   DT **** ' ||l_subline_rec.sl_end_date);
--dbms_output.put_line ('*** SL-SL LINE STY **** ' ||l_subline_rec.sl_line_style);
--dbms_output.put_line ('*** SL-SL OBJ1_ID1 **** ' ||l_subline_rec.sl_object_id);

      --dbms_output.put_line ('*************************************************************************');

      --Ctr Variables for pricing tables
      l_product_index            := 1;
      l_service_index            := 2;
      l_line_tbl_ctr             := 0;
      l_line_attr_tbl_ctr        := 0;
      l_line_detl_tbl_ctr        := 0;
      l_line_qual_tbl_ctr        := 0;
--Variables to be populated
      l_pricing_event            := 'BATCH';

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '701:*** INTENT *********** ' ||
                         p_detail_rec.intent
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '702:*** PRICING EVENT **** ' ||
                         l_pricing_event
                        );
      END IF;

--dbms_output.put_line ('*** INTENT *********** ' || p_detail_rec.intent);
--dbms_output.put_line ('*** PRICING EVENT **** ' || l_pricing_event);
      l_request_type_code        := 'ONT';

      IF NVL (p_detail_rec.intent, 'JA') = 'HM'
      THEN
         l_line_type_code           := 'ORDER';
      ELSE
         l_line_type_code           := 'LINE';
      END IF;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '801:*** LINE_TYPE_CODE **** ' ||
                         l_line_type_code
                        );
      END IF;

--dbms_output.put_line ('*** LINE_TYPE_CODE **** ' || l_line_type_code);
      l_def_pricing_profile      := fnd_profile.VALUE ('OKS_DEF_PRICING_DATE');

      IF l_def_pricing_profile = 'KSDT'
      THEN
         l_def_pricing_date         := l_hdrtop_rec.kh_start_date;
      ELSIF l_def_pricing_profile = 'SYDT'
      THEN
         l_def_pricing_date         := SYSDATE;
      ELSIF l_def_pricing_profile = 'TSDT'
      THEN
         l_def_pricing_date         := l_hdrtop_rec.tl_start_date;
      ELSIF l_def_pricing_profile = 'KGDT'
      THEN
         l_def_pricing_date         := l_hdrtop_rec.kh_signed_date;
      ELSIF l_def_pricing_profile = 'CSDT'
      THEN
         IF l_hdrtop_rec.tl_line_style IN (12, 46)
         THEN
            l_def_pricing_date         := l_hdrtop_rec.tl_start_date;
         ELSE
            l_def_pricing_date         := l_subline_rec.sl_start_date;
         END IF;
      END IF;

      l_def_pricing_date         := NVL (l_def_pricing_date, SYSDATE);

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '901:*** DEF PRICING PROFILE **** ' ||
                         l_def_pricing_profile
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '902:*** PRICING DATE **** ' ||
                         l_def_pricing_date
                        );
      END IF;

--dbms_output.put_line ('*** DEF PRICING PROFILE **** ' || l_def_pricing_profile);
--dbms_output.put_line ('*** PRICING DATE **** ' || l_def_pricing_date);
      IF NVL (p_detail_rec.intent, 'JA') = 'HM'
      THEN
         l_currency                 := p_detail_rec.currency;
      ELSE
         l_currency                 := l_hdrtop_rec.kh_currency_code;
      END IF;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '1001:*** CURRENCY CODE **** ' ||
                         l_currency
                        );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '1002:************************** SET GLOBAL VARIABLES ********************************************'
            );
      END IF;

--dbms_output.put_line ('*** CURRENCY CODE **** ' || l_currency);

      --dbms_output.put_line ('************************** SET GLOBAL VARIABLES ********************************************');

      --Assemble variables
      l_customer_id              :=
                      get_customer_id (l_hdrtop_rec.kh_id, l_hdrtop_rec.tl_id);

      BEGIN
         SELECT party_id
           INTO l_party_id
           FROM hz_cust_accounts_all
          WHERE cust_account_id = l_customer_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_party_id                 := NULL;

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
         WHEN OTHERS
         THEN
            l_party_id                 := NULL;

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
      END;

      IF p_detail_rec.intent = 'HM'
      THEN
         OPEN l_skg_csr;

         FETCH l_skg_csr
          INTO l_skg_rec;

         CLOSE l_skg_csr;

         oks_qpattrib_pvt.g_contract_hdrrec.chr_id := l_skg_rec.kh_id;
         oks_qpattrib_pvt.g_contract_hdrrec.top_line_id := NULL;
         oks_qpattrib_pvt.g_contract_hdrrec.cov_line_id := NULL;
         oks_qpattrib_pvt.g_contract_hdrrec.inventory_item_id := NULL;
         oks_qpattrib_pvt.g_contract_hdrrec.invt_org_id := l_skg_rec.inv_org;
         oks_qpattrib_pvt.g_contract_hdrrec.auth_org_id :=
                                                         l_skg_rec.kh_auth_org;
         oks_qpattrib_pvt.g_contract_hdrrec.pricing_date := l_def_pricing_date;
         oks_qpattrib_pvt.g_contract_hdrrec.party_id :=
                                                get_party_id (l_skg_rec.kh_id);
         oks_qpattrib_pvt.g_contract_hdrrec.customer_id :=
                              get_customer_from_siteuse (l_skg_rec.kh_bill_to);
         oks_qpattrib_pvt.g_contract_hdrrec.agreement_id :=
                                            get_agreement_id (l_skg_rec.kh_id);
         oks_qpattrib_pvt.g_contract_hdrrec.bill_to := l_skg_rec.kh_bill_to;
         oks_qpattrib_pvt.g_contract_hdrrec.ship_to := l_skg_rec.kh_ship_to;
         oks_qpattrib_pvt.g_contract_hdrrec.payment_term_id :=
                                                  l_skg_rec.kh_payment_term_id;
         oks_qpattrib_pvt.g_contract_linrec.chr_id := NULL;
         oks_qpattrib_pvt.g_contract_linrec.top_line_id := NULL;
         oks_qpattrib_pvt.g_contract_linrec.cov_line_id := NULL;
         oks_qpattrib_pvt.g_contract_linrec.inventory_item_id := NULL;
         oks_qpattrib_pvt.g_contract_linrec.invt_org_id := NULL;
         oks_qpattrib_pvt.g_contract_linrec.auth_org_id := NULL;
         oks_qpattrib_pvt.g_contract_linrec.pricing_date := NULL;
         oks_qpattrib_pvt.g_contract_linrec.party_id := NULL;
         oks_qpattrib_pvt.g_contract_linrec.customer_id := NULL;
         oks_qpattrib_pvt.g_contract_linrec.bill_to := NULL;
         oks_qpattrib_pvt.g_contract_linrec.ship_to := NULL;
         oks_qpattrib_pvt.g_contract_linrec.payment_term_id := NULL;
      ELSE
         oks_qpattrib_pvt.g_contract_hdrrec.chr_id := l_hdrtop_rec.kh_id;
         oks_qpattrib_pvt.g_contract_hdrrec.top_line_id := l_hdrtop_rec.tl_id;
         oks_qpattrib_pvt.g_contract_hdrrec.cov_line_id :=
                                                          l_subline_rec.sl_id;
         oks_qpattrib_pvt.g_contract_hdrrec.inventory_item_id :=
                                                    l_hdrtop_rec.tl_object_id;
         oks_qpattrib_pvt.g_contract_hdrrec.invt_org_id :=
                                                         l_hdrtop_rec.inv_org;
         oks_qpattrib_pvt.g_contract_hdrrec.auth_org_id :=
                                                     l_hdrtop_rec.kh_auth_org;
         oks_qpattrib_pvt.g_contract_hdrrec.pricing_date :=
                                                           l_def_pricing_date;
         oks_qpattrib_pvt.g_contract_hdrrec.party_id :=
                                            get_party_id (l_hdrtop_rec.kh_id);
         oks_qpattrib_pvt.g_contract_hdrrec.customer_id :=
                          get_customer_from_siteuse (l_hdrtop_rec.kh_bill_to);
         oks_qpattrib_pvt.g_contract_hdrrec.agreement_id :=
                                        get_agreement_id (l_hdrtop_rec.kh_id);
         oks_qpattrib_pvt.g_contract_hdrrec.bill_to :=
                                                      l_hdrtop_rec.kh_bill_to;
         oks_qpattrib_pvt.g_contract_hdrrec.ship_to :=
                                                      l_hdrtop_rec.kh_ship_to;
         oks_qpattrib_pvt.g_contract_hdrrec.payment_term_id :=
                                              l_hdrtop_rec.kh_payment_term_id;
         oks_qpattrib_pvt.g_contract_linrec.chr_id := l_hdrtop_rec.kh_id;
         oks_qpattrib_pvt.g_contract_linrec.top_line_id := l_hdrtop_rec.tl_id;
         oks_qpattrib_pvt.g_contract_linrec.cov_line_id :=
                                                          l_subline_rec.sl_id;
         oks_qpattrib_pvt.g_contract_linrec.inventory_item_id :=
                                                    l_hdrtop_rec.tl_object_id;
         oks_qpattrib_pvt.g_contract_linrec.invt_org_id :=
                                                         l_hdrtop_rec.inv_org;
         oks_qpattrib_pvt.g_contract_linrec.auth_org_id :=
                                                     l_hdrtop_rec.kh_auth_org;
         oks_qpattrib_pvt.g_contract_linrec.pricing_date :=
                                                           l_def_pricing_date;
         oks_qpattrib_pvt.g_contract_linrec.party_id := l_party_id;
         oks_qpattrib_pvt.g_contract_linrec.customer_id := l_customer_id;
         oks_qpattrib_pvt.g_contract_linrec.bill_to :=
                                                      l_hdrtop_rec.tl_bill_to;
         oks_qpattrib_pvt.g_contract_linrec.ship_to :=
                                                      l_hdrtop_rec.tl_ship_to;
         oks_qpattrib_pvt.g_contract_linrec.payment_term_id :=
                                              l_hdrtop_rec.tl_payment_term_id;
      END IF;

      IF p_detail_rec.break_uom_code IS NOT NULL
      THEN
         oks_qpattrib_pvt.g_contract_linrec.break_uom :=
                                                  p_detail_rec.break_uom_code;
      ELSE
         oks_qpattrib_pvt.g_contract_linrec.break_uom := NULL;
      END IF;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2001:*** GLOBAL VARIABLE - CHR-ID        **** ' ||
                         oks_qpattrib_pvt.g_contract_hdrrec.chr_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2002:*** GLOBAL VARIABLE - TOP-LINE ID   **** ' ||
                         oks_qpattrib_pvt.g_contract_hdrrec.top_line_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2003:*** GLOBAL VARIABLE - COV-LINE-ID   **** ' ||
                         oks_qpattrib_pvt.g_contract_hdrrec.cov_line_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2004:*** GLOBAL VARIABLE - INV-ITEM-ID   **** ' ||
                         oks_qpattrib_pvt.g_contract_hdrrec.inventory_item_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2005:*** GLOBAL VARIABLE - INV- ORG-ID   **** ' ||
                         oks_qpattrib_pvt.g_contract_hdrrec.invt_org_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2006:*** GLOBAL VARIABLE - AUT- ORG-ID   **** ' ||
                         oks_qpattrib_pvt.g_contract_hdrrec.auth_org_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2007:*** GLOBAL VARIABLE - PRICE -DATE   **** ' ||
                         oks_qpattrib_pvt.g_contract_hdrrec.pricing_date
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2008:*** GLOBAL VARIABLE - PARTY -  ID   **** ' ||
                         oks_qpattrib_pvt.g_contract_hdrrec.party_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2009:*** GLOBAL VARIABLE - CUST  -  ID   **** ' ||
                         oks_qpattrib_pvt.g_contract_hdrrec.customer_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2010:*** GLOBAL VARIABLE - AGREEM-  ID   **** ' ||
                         oks_qpattrib_pvt.g_contract_hdrrec.agreement_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2011:*** GLOBAL VARIABLE - BILL  -  TO   **** ' ||
                         oks_qpattrib_pvt.g_contract_hdrrec.bill_to
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2012:*** GLOBAL VARIABLE - SHIP  -  TO   **** ' ||
                         oks_qpattrib_pvt.g_contract_hdrrec.ship_to
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2013:*** GLOBAL VARIABLE - PAYMENT  ID   **** ' ||
                         oks_qpattrib_pvt.g_contract_hdrrec.payment_term_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2014:*** GLOBAL VARIABLE - BREAK UOM     **** ' ||
                         oks_qpattrib_pvt.g_contract_hdrrec.break_uom
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2015:*** GLOBAL VARIABLE - CHR-ID        **** ' ||
                         oks_qpattrib_pvt.g_contract_linrec.chr_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2016:*** GLOBAL VARIABLE - TOP-LINE ID   **** ' ||
                         oks_qpattrib_pvt.g_contract_linrec.top_line_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2017:*** GLOBAL VARIABLE - COV-LINE-ID   **** ' ||
                         oks_qpattrib_pvt.g_contract_linrec.cov_line_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2018:*** GLOBAL VARIABLE - INV-ITEM-ID   **** ' ||
                         oks_qpattrib_pvt.g_contract_linrec.inventory_item_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2019:*** GLOBAL VARIABLE - INV- ORG-ID   **** ' ||
                         oks_qpattrib_pvt.g_contract_linrec.invt_org_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2020:*** GLOBAL VARIABLE - AUT- ORG-ID   **** ' ||
                         oks_qpattrib_pvt.g_contract_linrec.auth_org_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2021:*** GLOBAL VARIABLE - PRICE -DATE   **** ' ||
                         oks_qpattrib_pvt.g_contract_linrec.pricing_date
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2022:*** GLOBAL VARIABLE - PARTY -  ID   **** ' ||
                         oks_qpattrib_pvt.g_contract_linrec.party_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2023:*** GLOBAL VARIABLE - CUST  -  ID   **** ' ||
                         oks_qpattrib_pvt.g_contract_linrec.customer_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2024:*** GLOBAL VARIABLE - BREAK UOM     **** ' ||
                         oks_qpattrib_pvt.g_contract_linrec.break_uom
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2025:*** GLOBAL VARIABLE - BILL  -  TO   **** ' ||
                         oks_qpattrib_pvt.g_contract_linrec.bill_to
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2026:*** GLOBAL VARIABLE - SHIP  -  TO   **** ' ||
                         oks_qpattrib_pvt.g_contract_linrec.ship_to
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2027:*** GLOBAL VARIABLE - PAYMENT  ID   **** ' ||
                         oks_qpattrib_pvt.g_contract_linrec.payment_term_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '2028:*** GLOBAL VARIABLE - BREAK UOM     **** ' ||
                         oks_qpattrib_pvt.g_contract_linrec.break_uom
                        );
      END IF;

--dbms_output.put_line ('*** GLOBAL VARIABLE - CHR-ID        **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_HDRREC.CHR_ID);
--dbms_output.put_line ('*** GLOBAL VARIABLE - TOP-LINE ID   **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_HDRREC.TOP_LINE_ID);
--dbms_output.put_line ('*** GLOBAL VARIABLE - COV-LINE-ID   **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_HDRREC.COV_LINE_ID);
--dbms_output.put_line ('*** GLOBAL VARIABLE - INV-ITEM-ID   **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_HDRREC.INVENTORY_ITEM_ID);
--dbms_output.put_line ('*** GLOBAL VARIABLE - INV- ORG-ID   **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_HDRREC.INVT_ORG_ID);
--dbms_output.put_line ('*** GLOBAL VARIABLE - AUT- ORG-ID   **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_HDRREC.AUTH_ORG_ID);
--dbms_output.put_line ('*** GLOBAL VARIABLE - PRICE -DATE   **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_HDRREC.PRICING_DATE);
--dbms_output.put_line ('*** GLOBAL VARIABLE - PARTY -  ID   **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_HDRREC.PARTY_ID);
--dbms_output.put_line ('*** GLOBAL VARIABLE - CUST  -  ID   **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_HDRREC.CUSTOMER_ID);
--dbms_output.put_line ('*** GLOBAL VARIABLE - AGREEM-  ID   **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_HDRREC.AGREEMENT_ID);
--dbms_output.put_line ('*** GLOBAL VARIABLE - BILL  -  TO   **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_HDRREC.BILL_TO);
--dbms_output.put_line ('*** GLOBAL VARIABLE - SHIP  -  TO   **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_HDRREC.SHIP_TO);
--dbms_output.put_line ('*** GLOBAL VARIABLE - PAYMENT  ID   **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_HDRREC.PAYMENT_TERM_ID);
--dbms_output.put_line ('*** GLOBAL VARIABLE - BREAK UOM     **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_HDRREC.BREAK_UOM);

      --dbms_output.put_line ('*** GLOBAL VARIABLE - CHR-ID        **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_LINREC.CHR_ID);
--dbms_output.put_line ('*** GLOBAL VARIABLE - TOP-LINE ID   **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_LINREC.TOP_LINE_ID);
--dbms_output.put_line ('*** GLOBAL VARIABLE - COV-LINE-ID   **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_LINREC.COV_LINE_ID);
--dbms_output.put_line ('*** GLOBAL VARIABLE - INV-ITEM-ID   **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_LINREC.INVENTORY_ITEM_ID);
--dbms_output.put_line ('*** GLOBAL VARIABLE - INV- ORG-ID   **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_LINREC.INVT_ORG_ID);
--dbms_output.put_line ('*** GLOBAL VARIABLE - AUT- ORG-ID   **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_LINREC.AUTH_ORG_ID);
--dbms_output.put_line ('*** GLOBAL VARIABLE - PRICE -DATE   **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_LINREC.PRICING_DATE);
--dbms_output.put_line ('*** GLOBAL VARIABLE - PARTY -  ID   **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_LINREC.PARTY_ID);
--dbms_output.put_line ('*** GLOBAL VARIABLE - CUST  -  ID   **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_LINREC.CUSTOMER_ID);
--dbms_output.put_line ('*** GLOBAL VARIABLE - BREAK UOM     **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_LINREC.BREAK_UOM);
--dbms_output.put_line ('*** GLOBAL VARIABLE - BILL  -  TO   **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_LINREC.BILL_TO);
--dbms_output.put_line ('*** GLOBAL VARIABLE - SHIP  -  TO   **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_LINREC.SHIP_TO);
--dbms_output.put_line ('*** GLOBAL VARIABLE - PAYMENT  ID   **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_LINREC.PAYMENT_TERM_ID);
--dbms_output.put_line ('*** GLOBAL VARIABLE - BREAK UOM     **** ' || OKS_QPATTRIB_PVT.G_CONTRACT_LINREC.BREAK_UOM);

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.STRING (fnd_log.level_statement,g_module ||l_api_name,
                         '2029:*** Calling qp_attr_mapping_pub.build_contexts **** '
                        );
      END IF;

      qp_attr_mapping_pub.build_contexts
                       (p_request_type_code                => 'OKS',
                        p_pricing_type                     => 'H',
                        x_price_contexts_result_tbl        => l_pricing_contexts_tbl,
                        x_qual_contexts_result_tbl         => l_qual_contexts_tbl
                       );

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.STRING (fnd_log.level_statement,g_module ||l_api_name,
                         '2030:*** After Calling qp_attr_mapping_pub.build_contexts **** '
                        );
      END IF;

--dbms_output.put_line ('*** BUILD CONTEXT HDR  LEVEL - PRICING TBL   **** ' || l_pricing_contexts_tbl.count);
--dbms_output.put_line ('*** BUILD CONTEXT HDR  LEVEL - QUALIFY TBL   **** ' || l_qual_contexts_tbl.count);

      IF NOT NVL (p_detail_rec.intent, 'JA') = 'HM'
      THEN
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.STRING (fnd_log.level_statement,g_module ||l_api_name,
                         '2031:*** Calling qp_attr_mapping_pub.build_contexts **** '
                        );
          END IF;
         qp_attr_mapping_pub.build_contexts
                      (p_request_type_code                => 'OKS',
                       p_pricing_type                     => 'L',
                       x_price_contexts_result_tbl        => l_pricing_contexts_tbl,
                       x_qual_contexts_result_tbl         => l_qual_contexts_tbl
                      );
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.STRING (fnd_log.level_statement,g_module ||l_api_name,
                         '2032:*** After Calling qp_attr_mapping_pub.build_contexts **** '
                        );
          END IF;
      END IF; -- IF NOT NVL (p_detail_rec.intent, 'JA') = 'HM'

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                (fnd_log.level_procedure,
                 g_module ||
                 l_api_name,
                 '3001:*** BUILD CONTEXT LINE LEVEL - PRICING TBL   **** ' ||
                 l_pricing_contexts_tbl.COUNT
                );
         fnd_log.STRING
                 (fnd_log.level_procedure,
                  g_module ||
                  l_api_name,
                  '3002:*** BUILD CONTEXT LINE LEVEL - QUALIFY TBL   **** ' ||
                  l_qual_contexts_tbl.COUNT
                 );
      END IF;

--dbms_output.put_line ('*** BUILD CONTEXT LINE LEVEL - PRICING TBL   **** ' || l_pricing_contexts_tbl.count);
--dbms_output.put_line ('*** BUILD CONTEXT LINE LEVEL - QUALIFY TBL   **** ' || l_qual_contexts_tbl.count);
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '4001:************************** ASSEMBLING ********************************************'
            );
      END IF;

--dbms_output.put_line ('************************** ASSEMBLING ********************************************');

      --GROUP I.I
      l_control_rec.pricing_event := l_pricing_event;
      l_control_rec.calculate_flag := 'Y';
      l_control_rec.simulation_flag := 'Y';
      l_control_rec.rounding_flag := 'N';
      l_control_rec.source_order_amount_flag := 'Y';
      l_control_rec.temp_table_insert_flag := 'Y';

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '4002:*************************************************************************'
            );
      END IF;

--dbms_output.put_line ('*************************************************************************');

      --GROUP I.II
      l_line_tbl_ctr             := l_line_tbl_ctr +
                                    1;
      l_req_line_rec.request_type_code := l_request_type_code;

--get line_id for product
      IF l_hdrtop_rec.tl_line_style IN (12, 46)
      THEN
         l_req_line_rec.line_id     := p_detail_rec.line_id;
      ELSE
         l_req_line_rec.line_id     := p_detail_rec.subline_id;
      END IF;

      l_req_line_rec.line_index  := 1;
      l_req_line_rec.line_type_code := l_line_type_code;
      l_req_line_rec.pricing_effective_date := l_def_pricing_date;

--Get Lineqty/Lineuom
      IF l_hdrtop_rec.tl_line_style = 46
      THEN
         oks_subscription_pub.get_subs_qty
                                         (p_cle_id                           => p_detail_rec.line_id,
                                          x_return_status                    => l_return_status,
                                          x_quantity                         => l_qpprod_quantity,
                                          x_uom_code                         => l_qpprod_uom_code
                                         );

         IF l_return_status <> 'S'
         THEN
            okc_api.set_message
                           (g_app_name,
                            g_required_value,
                            g_col_name_token,
                            'JA-J-is returning error on subscription qty-uom'
                           );
            RAISE fnd_api.g_exc_error;
         END IF;
      ELSIF l_hdrtop_rec.tl_line_style = 12
      THEN
         l_req_line_rec.usage_pricing_type := 'REGULAR';

         IF NVL (p_detail_rec.intent, 'JA') IN ('PB', 'LM', 'SM')
         THEN
            l_qpprod_quantity          := 1;
            l_qpprod_uom_code          :=
               get_uom (p_id                               => l_hdrtop_rec.tl_object_id,
                        p_inv_org                          => l_hdrtop_rec.inv_org);
         ELSE
            l_qpprod_quantity          := p_detail_rec.usage_qty;
            l_qpprod_uom_code          := p_detail_rec.usage_uom_code;
         END IF;
      ELSE
         l_qpprod_quantity          := l_subline_rec.sl_qty;
         l_qpprod_uom_code          := l_subline_rec.sl_uom_code;
      END IF;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '5001:*************************************************************************'
            );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '5002:*** QPPROD-LINE UOM CODE **** ' ||
                         l_qpprod_uom_code
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '5003:*** QPPROD-LINE QUANTITY **** ' ||
                         l_qpprod_quantity
                        );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '5004:*************************************************************************'
            );
      END IF;

--dbms_output.put_line ('*************************************************************************');
--dbms_output.put_line ('*** QPPROD-LINE UOM CODE **** ' ||l_qpprod_uom_code);
--dbms_output.put_line ('*** QPPROD-LINE QUANTITY **** ' ||l_qpprod_quantity);
--dbms_output.put_line ('*************************************************************************');
      l_req_line_rec.line_quantity := l_qpprod_quantity;
      l_req_line_rec.line_uom_code := l_qpprod_uom_code;
      l_req_line_rec.currency_code := l_currency;
      l_req_line_rec.price_flag  := 'Y';

      IF NVL (p_detail_rec.intent, 'JA') = 'SB_O'
      THEN
         l_req_line_rec.updated_adjusted_unit_price :=
                                               p_detail_rec.asking_unit_price;
      END IF;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '6001:*** QPPROD-ADJUSTED AMOUNT **** ' ||
                         l_req_line_rec.updated_adjusted_unit_price
                        );
      END IF;

--dbms_output.put_line ('*** QPPROD-ADJUSTED AMOUNT **** ' ||l_req_line_rec.updated_adjusted_unit_price);
      IF p_detail_rec.bill_from_date IS NOT NULL AND
         p_detail_rec.bill_to_date IS NOT NULL
      THEN
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                  (fnd_log.level_procedure,
                   g_module ||
                   l_api_name,
                   '7001:*** BILL FROM DATES POPULATED IN PARENT ITEM ** ' ||
                   l_req_line_rec.updated_adjusted_unit_price
                  );
         END IF;

--dbms_output.put_line ('*** BILL FROM DATES POPULATED IN PARENT ITEM ** ' ||l_req_line_rec.updated_adjusted_unit_price);
         l_req_line_rec.contract_start_date := p_detail_rec.bill_from_date;
         l_req_line_rec.contract_end_date := p_detail_rec.bill_to_date;
      END IF;

      l_req_line_tbl (l_line_tbl_ctr) := l_req_line_rec;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '8001:*************************************************************************'
            );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '8002:*** QPPROD-LINE TBL COUNT **** ' ||
                         l_req_line_tbl.COUNT ||
                         ' ***** LINE TBL CTR ' ||
                         l_line_tbl_ctr
                        );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '8003:*************************************************************************'
            );
      END IF;

--dbms_output.put_line ('*************************************************************************');
--dbms_output.put_line ('*** QPPROD-LINE TBL COUNT **** ' ||l_req_line_tbl.count || ' ***** LINE TBL CTR '|| l_line_tbl_ctr);
--dbms_output.put_line ('*************************************************************************');

      --GROUP I.III
-- /*
-- bug 5069673
--Product Context
    l_line_attr_tbl_ctr                      := l_line_attr_tbl_ctr + 1;

    l_req_line_attr_rec.LINE_INDEX           := 1;
    l_req_line_attr_rec.PRICING_CONTEXT      :='ITEM';
    l_req_line_attr_rec.PRICING_ATTRIBUTE    :='PRICING_ATTRIBUTE3';
    l_req_line_attr_rec.PRICING_ATTR_VALUE_FROM  := 'ALL';
    l_req_line_attr_rec.VALIDATED_FLAG       :='N';

    l_req_line_attr_tbl(l_line_attr_tbl_ctr) := l_req_line_attr_rec;
-- */
-- end bug 5069673

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '9001:*************************************************************************'
            );
      END IF;

--dbms_output.put_line ('*************************************************************************');

      --GROUP I.III.A
      IF NVL (p_detail_rec.intent, 'JA') IN ('PB', 'USG') AND
         p_detail_rec.price_list_line_id IS NOT NULL
      THEN
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                    (fnd_log.level_procedure,
                     g_module ||
                     l_api_name,
                     '9002:*** GROUP I - INSIDE LOCK LIST LINE BUILD   **** '
                    );
         END IF;

--dbms_output.put_line ('*** GROUP I - INSIDE LOCK LIST LINE BUILD   **** ' );
         l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                       1;
         l_req_line_attr_rec.line_index := 1;
         l_req_line_attr_rec.pricing_context := 'QP_INTERNAL';
         l_req_line_attr_rec.pricing_attribute := 'PRICING_ATTRIBUTE1';
         l_req_line_attr_rec.pricing_attr_value_from :=
                                               p_detail_rec.price_list_line_id;
         l_req_line_attr_rec.validated_flag := 'N';
         l_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec;
      END IF;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '9003:*************************************************************************'
            );
      END IF;

--dbms_output.put_line ('*************************************************************************');

      --GROUP I.IV
      l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                    1;
      l_req_line_attr_rec.line_index := 1;
      l_req_line_attr_rec.pricing_context := 'ITEM';
      l_req_line_attr_rec.pricing_attribute := 'PRICING_ATTRIBUTE1';

      IF l_hdrtop_rec.tl_line_style IN (12, 46)
      THEN
         l_qpprod_inv_id            := l_hdrtop_rec.tl_object_id;
      ELSE
         IF l_subline_rec.sl_line_style IN (9, 25)
         THEN
            l_qpprod_inv_id            :=
                                   get_cp_inv_id (l_subline_rec.sl_object_id);
         ELSIF l_subline_rec.sl_line_style = 7
         THEN
            l_qpprod_inv_id            := l_subline_rec.sl_object_id;
         END IF;
      END IF;

      IF NVL (p_detail_rec.intent, 'JA') = 'HM'
      THEN
         l_req_line_attr_rec.pricing_attr_value_from := 99;
      ELSE
         IF NVL (p_detail_rec.intent, 'JA') = 'LM'
         THEN
            IF l_hdrtop_rec.tl_line_style IN (12, 46)
            THEN
               l_req_line_attr_rec.pricing_attr_value_from := l_qpprod_inv_id;
            ELSE
               l_req_line_attr_rec.pricing_attr_value_from := 99;
            END IF;
         ELSE
            l_req_line_attr_rec.pricing_attr_value_from := l_qpprod_inv_id;
         END IF;
      END IF;

      l_req_line_attr_rec.validated_flag := 'N';
      l_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '9101:*** PASSED QPPROD-INVENTORY ITEM ID **** ' ||
                         l_req_line_attr_rec.pricing_attr_value_from
                        );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '9102:*************************************************************************'
            );
      END IF;

--dbms_output.put_line ('*** PASSED QPPROD-INVENTORY ITEM ID **** ' ||l_req_line_attr_rec.pricing_attr_Value_from);
--dbms_output.put_line ('*************************************************************************');

      --GROUP I.V
      l_line_qual_tbl_ctr        := l_line_qual_tbl_ctr +
                                    1;
      l_req_qual_rec.line_index  := 1;
      l_req_qual_rec.qualifier_context := 'MODLIST';
      l_req_qual_rec.qualifier_attribute := 'QUALIFIER_ATTRIBUTE4';

      IF p_detail_rec.price_list IS NOT NULL
      THEN
         l_price_id                 := p_detail_rec.price_list;
      ELSE
         l_price_id                 := l_hdrtop_rec.price_list_id;
      END IF;

      IF NVL (p_detail_rec.intent, 'JA') = 'HM'
      THEN
         l_req_qual_rec.qualifier_attr_value_from := 99;
      ELSE
         l_req_qual_rec.qualifier_attr_value_from := l_price_id;
      END IF;

      l_req_qual_rec.comparison_operator_code := '=';
      l_req_qual_rec.validated_flag := 'Y';
      l_req_qual_tbl (l_line_qual_tbl_ctr) := l_req_qual_rec;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '9201:*** QPPROD-PRICE LIST ID **** ' ||
                         l_req_qual_rec.qualifier_attr_value_from
                        );
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '9202:*************************************************************************'
            );
      END IF;

--dbms_output.put_line ('*** QPPROD-PRICE LIST ID **** ' ||l_req_qual_rec.QUALIFIER_ATTR_VALUE_FROM );
--dbms_output.put_line ('*************************************************************************');

      --START p_detail_rec.intent CHECK
      IF NOT NVL (p_detail_rec.intent, 'JA') = 'HM'
      THEN
--GROUP I.VI
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                    (fnd_log.level_procedure,
                     g_module ||
                     l_api_name,
                     '9301:*** BEFORE PA (REQ_LINE_ATTR_TBL_COUNT ) **** ' ||
                     l_req_line_attr_tbl.COUNT
                    );
         END IF;

         --dbms_output.put_line ('*** BEFORE PA (REQ_LINE_ATTR_TBL_COUNT ) **** ' ||l_req_line_attr_tbl.count);
         IF l_hdrtop_rec.tl_line_style IN (12, 46)
         THEN
--ADDED FOR AICPA
            IF l_pricing_contexts_tbl.COUNT > 0
            THEN
               IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING
                     (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '9401:*** GROUP I.VI - INSIDE PRICING CONTEXT BUILD ROUTINE   **** '
                     );
               END IF;

--dbms_output.put_line ('*** GROUP I.VI - INSIDE PRICING CONTEXT BUILD ROUTINE   **** ' );
               l_ctr                      := l_pricing_contexts_tbl.FIRST;

               LOOP
                  l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                                1;
                  l_req_line_attr_tbl (l_line_attr_tbl_ctr).line_index := 1;
                  l_req_line_attr_tbl (l_line_attr_tbl_ctr).validated_flag :=
                                                                           'N';
                  l_req_line_attr_tbl (l_line_attr_tbl_ctr).pricing_context :=
                                   l_pricing_contexts_tbl (l_ctr).context_name;
                  l_req_line_attr_tbl (l_line_attr_tbl_ctr).pricing_attribute :=
                                 l_pricing_contexts_tbl (l_ctr).attribute_name;
                  l_req_line_attr_tbl (l_line_attr_tbl_ctr).pricing_attr_value_from :=
                                l_pricing_contexts_tbl (l_ctr).attribute_value;
                  EXIT WHEN l_pricing_contexts_tbl.LAST = l_ctr;
                  l_ctr                      :=
                                           l_pricing_contexts_tbl.NEXT (l_ctr);
               END LOOP;
            END IF;

            build_top_pa (p_cle_id                           => p_detail_rec.line_id,
                          p_service_index                    => 1,
                          px_line_attr_tbl_ctr               => l_line_attr_tbl_ctr,
                          px_req_line_attr_tbl               => l_req_line_attr_tbl
                         );
         ELSIF l_subline_rec.sl_line_style IN (9, 25)
         THEN
            build_cp_pa (p_inst_id                          => l_subline_rec.sl_object_id,
                         p_service_index                    => 1,
                         px_line_attr_tbl_ctr               => l_line_attr_tbl_ctr,
                         px_req_line_attr_tbl               => l_req_line_attr_tbl
                        );
         END IF;

         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                    (fnd_log.level_procedure,
                     g_module ||
                     l_api_name,
                     '9501:*** AFTER  PA (REQ_LINE_ATTR_TBL_COUNT ) **** ' ||
                     l_req_line_attr_tbl.COUNT
                    );
            fnd_log.STRING
               (fnd_log.level_procedure,
                g_module ||
                l_api_name,
                '9502:*************************************************************************'
               );
         END IF;

         --dbms_output.put_line ('*** AFTER  PA (REQ_LINE_ATTR_TBL_COUNT ) **** ' ||l_req_line_attr_tbl.count);
         --dbms_output.put_line ('*************************************************************************');

         --GROUP I.VII
         IF l_hdrtop_rec.tl_line_style IN (12, 46)
         THEN                              --Check for Usage/Subscription Only
--For Order Type
            IF check_hdr_discount (p_chr_id                           => l_hdrtop_rec.kh_id)
            THEN
               l_line_tbl_ctr             := l_line_tbl_ctr +
                                             1;
               l_req_line_rec3.request_type_code := 'ONT';
               l_req_line_rec3.line_index := l_line_tbl_ctr;
               l_req_line_rec3.line_type_code := 'ORDER';
               l_req_line_rec3.pricing_effective_date := l_def_pricing_date;
               l_req_line_rec3.currency_code := l_currency;
               l_req_line_rec3.price_flag := 'Y';
               l_req_line_tbl (l_line_tbl_ctr) := l_req_line_rec3;

               IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING (fnd_log.level_procedure,
                                  g_module ||
                                  l_api_name,
                                  '9601:*** QPPROD-LINE TBL COUNT **** ' ||
                                  l_req_line_tbl.COUNT ||
                                  ' ***** LINE TBL CTR ' ||
                                  l_line_tbl_ctr
                                 );
                  fnd_log.STRING
                     (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '9602:*************************************************************************'
                     );
                  fnd_log.STRING
                     (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '9603:*** BEFORE HDR ADJ (REQ LINE_DETL_TBL_COUNT) **** ' ||
                      l_req_line_detail_tbl.COUNT
                     );
               END IF;

               --dbms_output.put_line ('*** QPPROD-LINE TBL COUNT **** ' ||l_req_line_tbl.count || ' ***** LINE TBL CTR '|| l_line_tbl_ctr);
               --dbms_output.put_line ('*************************************************************************');

               --dbms_output.put_line ('*** BEFORE HDR ADJ (REQ LINE_DETL_TBL_COUNT) **** ' ||l_req_line_detail_tbl.count);
               build_hdr_adj (p_chr_id                           => l_hdrtop_rec.kh_id,
                              p_item_id                          => l_qpprod_inv_id,
                              p_service_index                    => l_line_tbl_ctr,
                              p_line_detl_tbl_ctr                => l_line_detl_tbl_ctr,
                              p_req_line_detail_tbl              => l_req_line_detail_tbl
                             );

               IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING
                     (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '9701:*** AFTER  HDR ADJ (REQ LINE_DETL_TBL_COUNT) **** ' ||
                      l_req_line_detail_tbl.COUNT
                     );
                  fnd_log.STRING
                     (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '9702:*** BEFORE LIN ADJ (REQ LINE_DETL_TBL_COUNT) **** ' ||
                      l_req_line_detail_tbl.COUNT
                     );
               END IF;
            --dbms_output.put_line ('*** AFTER  HDR ADJ (REQ LINE_DETL_TBL_COUNT) **** ' ||l_req_line_detail_tbl.count);

            --dbms_output.put_line ('*** BEFORE LIN ADJ (REQ LINE_DETL_TBL_COUNT) **** ' ||l_req_line_detail_tbl.count);
            END IF;

            build_top_adj (p_cle_id                           => p_detail_rec.line_id,
                           p_item_id                          => l_qpprod_inv_id,
                           p_service_index                    => 1,
                           p_line_detl_tbl_ctr                => l_line_detl_tbl_ctr,
                           p_req_line_detail_tbl              => l_req_line_detail_tbl
                          );
            build_top_adj (p_cle_id                           => p_detail_rec.subline_id,
                           p_item_id                          => l_qpprod_inv_id,
                           p_service_index                    => 1,
                           p_line_detl_tbl_ctr                => l_line_detl_tbl_ctr,
                           p_req_line_detail_tbl              => l_req_line_detail_tbl
                          );

            IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                  (fnd_log.level_procedure,
                   g_module ||
                   l_api_name,
                   '9801:*** AFTER  LIN ADJ (REQ LINE_DETL_TBL_COUNT) **** ' ||
                   l_req_line_detail_tbl.COUNT
                  );
               fnd_log.STRING
                  (fnd_log.level_procedure,
                   g_module ||
                   l_api_name,
                   '9802:*************************************************************************'
                  );
            END IF;

            --dbms_output.put_line ('*** AFTER  LIN ADJ (REQ LINE_DETL_TBL_COUNT) **** ' ||l_req_line_detail_tbl.count);
            --dbms_output.put_line ('*************************************************************************');

            --GROUP I.VIII
            IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                    (fnd_log.level_procedure,
                     g_module ||
                     l_api_name,
                     '9901:*** *** BEFORE QUAL (REQ QUAL_TBL_COUNT) **** ' ||
                     l_req_qual_tbl.COUNT
                    );
            END IF;

            --dbms_output.put_line ('*** BEFORE QUAL (REQ QUAL_TBL_COUNT) **** ' ||l_req_qual_tbl.count);

            --removing from xxx

            --ADDED FOR AICPA
            IF l_qual_contexts_tbl.COUNT > 0
            THEN
               l_ctr                      := l_qual_contexts_tbl.FIRST;

               LOOP
                  l_line_qual_tbl_ctr        := l_line_qual_tbl_ctr +
                                                1;
                  l_req_qual_tbl (l_line_qual_tbl_ctr).line_index := 1;
                  l_req_qual_tbl (l_line_qual_tbl_ctr).qualifier_context :=
                                      l_qual_contexts_tbl (l_ctr).context_name;
                  l_req_qual_tbl (l_line_qual_tbl_ctr).qualifier_attribute :=
                                    l_qual_contexts_tbl (l_ctr).attribute_name;
                  l_req_qual_tbl (l_line_qual_tbl_ctr).qualifier_attr_value_from :=
                                   l_qual_contexts_tbl (l_ctr).attribute_value;
                  l_req_qual_tbl (l_line_qual_tbl_ctr).validated_flag := 'N';
                  EXIT WHEN l_qual_contexts_tbl.LAST = l_ctr;
                  l_ctr                      :=
                                              l_qual_contexts_tbl.NEXT (l_ctr);
               END LOOP;
            END IF;

--removing from xxx
            build_top_qa (p_cle_id                           => p_detail_rec.line_id,
                          p_item_id                          => NULL,
                          p_service_index                    => 1,
                          p_line_qual_tbl_ctr                => l_line_qual_tbl_ctr,
                          p_req_qual_tbl                     => l_req_qual_tbl
                         );

            IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                       (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '10001:*** AFTER  QUAL (REQ QUAL_TBL_COUNT) **** ' ||
                        l_req_qual_tbl.COUNT
                       );
               fnd_log.STRING
                  (fnd_log.level_procedure,
                   g_module ||
                   l_api_name,
                   '10002:*************************************************************************'
                  );
            END IF;
         --dbms_output.put_line ('*** AFTER  QUAL (REQ QUAL_TBL_COUNT) **** ' ||l_req_qual_tbl.count);
         --dbms_output.put_line ('*************************************************************************');
         END IF;                           --Check for Usage/Subscription Only

         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
               (fnd_log.level_procedure,
                g_module ||
                l_api_name,
                '11001:*************************************************************************'
               );
         END IF;

         --dbms_output.put_line ('*************************************************************************');

         --START DEPENDENT CONDITION
         IF l_hdrtop_rec.tl_line_style IN (1, 19)
         THEN
            IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                  (fnd_log.level_procedure,
                   g_module ||
                   l_api_name,
                   '12001:*************************************************************************'
                  );
               fnd_log.STRING
                  (fnd_log.level_procedure,
                   g_module ||
                   l_api_name,
                   '12002:*******************ENTERING DEPENDENT MODULE*****************************'
                  );
               fnd_log.STRING
                  (fnd_log.level_procedure,
                   g_module ||
                   l_api_name,
                   '12003:*************************************************************************'
                  );
            END IF;

            --dbms_output.put_line ('*************************************************************************');
            --dbms_output.put_line ('*******************ENTERING DEPENDENT MODULE*****************************');
            --dbms_output.put_line ('*************************************************************************');

            ---DURATION DERIVE
            IF NVL (p_detail_rec.intent, 'JA') = 'LM'
            THEN
               okc_time_util_pub.get_duration
                          (p_start_date                       => TRUNC
                                                                    (l_hdrtop_rec.tl_start_date),
                           p_end_date                         => TRUNC
                                                                    (l_hdrtop_rec.tl_end_date),
                           x_duration                         => l_qpserv_quantity,
                           x_timeunit                         => l_qpserv_uom_code,
                           x_return_status                    => l_return_status
                          );

               IF l_return_status <> 'S'
               THEN
                  okc_api.set_message
                                (g_app_name,
                                 g_required_value,
                                 g_col_name_token,
                                 '(1) Service get_duration Fails -StDate ' ||
                                 l_hdrtop_rec.tl_start_date ||
                                 ' EndDate ' ||
                                 l_hdrtop_rec.tl_end_date
                                );
                  RAISE fnd_api.g_exc_error;
               END IF;
            ELSE
               --begin new logic for partial periods
               OPEN l_get_hdrid_csr (l_subline_rec.sl_id);

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

                  IF x_return_status <> 'S'
                  THEN
                     RAISE fnd_api.g_exc_error;
                  END IF;
               ELSE
                  RAISE invalid_hdr_id_exception;
               END IF;

               --End  logic for Partial Periods
               IF l_subline_rec.sl_price_uom IS NOT NULL
               THEN
                  l_qpserv_uom_code          := l_subline_rec.sl_price_uom;
                  l_qpserv_quantity          :=
                     oks_time_measures_pub.get_quantity
                                                (l_subline_rec.sl_start_date,
                                                 l_subline_rec.sl_end_date,
                                                 l_subline_rec.sl_price_uom,
                                                 l_period_type,
                                                 l_period_start
                                                );
               ELSE
                  IF (fnd_log.level_procedure >=
                                               fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                        (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '13001:*************************************************************************'
                        );
                     fnd_log.STRING (fnd_log.level_procedure,
                                     g_module ||
                                     l_api_name,
                                     '13002:*** QPSERV-SL_START_DATE **** ' ||
                                     l_subline_rec.sl_start_date
                                    );
                     fnd_log.STRING (fnd_log.level_procedure,
                                     g_module ||
                                     l_api_name,
                                     '13003:*** QPSERV-SL_END  _DATE **** ' ||
                                     l_subline_rec.sl_end_date
                                    );
                     fnd_log.STRING
                        (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '13004:*************************************************************************'
                        );
                  END IF;

                  --dbms_output.put_line ('*************************************************************************');
                  --dbms_output.put_line ('*** QPSERV-SL_START_DATE **** ' ||l_subline_rec.sl_start_date);
                  --dbms_output.put_line ('*** QPSERV-SL_END  _DATE **** ' ||l_subline_rec.sl_end_date);
                  --dbms_output.put_line ('*************************************************************************');
                  okc_time_util_pub.get_duration
                          (p_start_date                       => TRUNC
                                                                    (l_subline_rec.sl_start_date),
                           p_end_date                         => TRUNC
                                                                    (l_subline_rec.sl_end_date),
                           x_duration                         => l_qpserv_quantity,
                           x_timeunit                         => l_qpserv_uom_code,
                           x_return_status                    => l_return_status
                          );

                  IF l_return_status <> 'S'
                  THEN
                     okc_api.set_message
                                (g_app_name,
                                 g_required_value,
                                 g_col_name_token,
                                 '(2) Service get_duration Fails -StDate ' ||
                                 l_hdrtop_rec.tl_start_date ||
                                 ' EndDate ' ||
                                 l_hdrtop_rec.tl_end_date
                                );
                     RAISE fnd_api.g_exc_error;
                  END IF;
               END IF;
            END IF;                                     -- END LM INTENT CHECK

---DURATION DERIVE

            --GROUP II.I
            l_line_tbl_ctr             := l_line_tbl_ctr +
                                          1;
            l_req_line_rec2.request_type_code := l_request_type_code;
            l_req_line_rec2.line_index := 2;
            l_req_line_rec2.line_type_code := l_line_type_code;
            l_req_line_rec2.pricing_effective_date := l_def_pricing_date;
            l_req_line_rec2.line_quantity := l_qpserv_quantity;
            l_req_line_rec2.line_uom_code := l_qpserv_uom_code;
            l_req_line_rec2.currency_code := l_currency;
            l_req_line_rec2.contract_start_date := l_subline_rec.sl_start_date;
            l_req_line_rec2.contract_end_date := l_subline_rec.sl_end_date;
            l_req_line_rec2.price_flag := 'Y';

            IF NVL (p_detail_rec.intent, 'JA') = 'OA'
            THEN
               l_req_line_rec2.updated_adjusted_unit_price :=
                                               p_detail_rec.asking_unit_price;
            END IF;

            l_req_line_tbl (l_line_tbl_ctr) := l_req_line_rec2;

            IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                  (fnd_log.level_procedure,
                   g_module ||
                   l_api_name,
                   '14001:*************************************************************************'
                  );
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '14002:*** QPSERV-LINE UOM CODE **** ' ||
                               l_qpserv_uom_code
                              );
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '14003:*** QPSERV-LINE QUANTITY **** ' ||
                               l_qpserv_quantity
                              );
               fnd_log.STRING
                  (fnd_log.level_procedure,
                   g_module ||
                   l_api_name,
                   '14004:*************************************************************************'
                  );
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '14005:*** QPPROD-LINE TBL COUNT **** ' ||
                               l_req_line_tbl.COUNT ||
                               ' ***** LINE TBL CTR ' ||
                               l_line_tbl_ctr
                              );
               fnd_log.STRING
                  (fnd_log.level_procedure,
                   g_module ||
                   l_api_name,
                   '14006:*************************************************************************'
                  );
            END IF;

--dbms_output.put_line ('*************************************************************************');
--dbms_output.put_line ('*** QPSERV-LINE UOM CODE **** ' ||l_qpserv_uom_code);
--dbms_output.put_line ('*** QPSERV-LINE QUANTITY **** ' ||l_qpserv_quantity);
--dbms_output.put_line ('*************************************************************************');

            --dbms_output.put_line ('*** QPPROD-LINE TBL COUNT **** ' ||l_req_line_tbl.count || ' ***** LINE TBL CTR '|| l_line_tbl_ctr);
--dbms_output.put_line ('*************************************************************************');

            --GROUP II.II
--/*
-- bug 5069673
--Product Context
         l_line_attr_tbl_ctr                          := l_line_attr_tbl_ctr + 1;

         l_req_line_attr_rec.LINE_INDEX               := 2;
         l_req_line_attr_rec.PRICING_CONTEXT          :='ITEM';
         l_req_line_attr_rec.PRICING_ATTRIBUTE        :='PRICING_ATTRIBUTE3';
         l_req_line_attr_rec.PRICING_ATTR_VALUE_FROM  := 'ALL';
         l_req_line_attr_rec.VALIDATED_FLAG           :='N';
         l_req_line_attr_tbl(l_line_attr_tbl_ctr)     := l_req_line_attr_rec;

--*/
-- end bug 5069673

--GROUP II.III
            l_qpserv_inv_id            := l_hdrtop_rec.tl_object_id;
            l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                          1;
            l_req_line_attr_rec.line_index := 2;
            l_req_line_attr_rec.pricing_context := 'ITEM';
            l_req_line_attr_rec.pricing_attribute := 'PRICING_ATTRIBUTE1';
            l_req_line_attr_rec.pricing_attr_value_from := l_qpserv_inv_id;
            l_req_line_attr_rec.validated_flag := 'N';
            l_req_line_attr_tbl (l_line_attr_tbl_ctr) := l_req_line_attr_rec;

            IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                  (fnd_log.level_procedure,
                   g_module ||
                   l_api_name,
                   '15001:*************************************************************************'
                  );
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '15002:*** QPSERV-INVENTORY ID **** ' ||
                               l_req_line_attr_rec.pricing_attr_value_from
                              );
               fnd_log.STRING
                  (fnd_log.level_procedure,
                   g_module ||
                   l_api_name,
                   '15003:*************************************************************************'
                  );
            END IF;

--dbms_output.put_line ('*************************************************************************');
--dbms_output.put_line ('*** QPSERV-INVENTORY ID **** ' || l_req_line_attr_rec.PRICING_ATTR_VALUE_FROM  );
--dbms_output.put_line ('*************************************************************************');

            --GROUP II.IV
            l_line_qual_tbl_ctr        := l_line_qual_tbl_ctr +
                                          1;
            l_req_qual_rec.line_index  := 2;
            l_req_qual_rec.qualifier_context := 'MODLIST';
            l_req_qual_rec.qualifier_attribute := 'QUALIFIER_ATTRIBUTE4';

            IF NVL (p_detail_rec.intent, 'JA') = 'HM'
            THEN
               l_req_qual_rec.qualifier_attr_value_from := 99;
            ELSE
               l_req_qual_rec.qualifier_attr_value_from := l_price_id;
            END IF;

            l_req_qual_rec.comparison_operator_code := '=';
            l_req_qual_rec.validated_flag := 'Y';
            l_req_qual_tbl (l_line_qual_tbl_ctr) := l_req_qual_rec;

            IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING
                  (fnd_log.level_procedure,
                   g_module ||
                   l_api_name,
                   '16001:*************************************************************************'
                  );
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '16002:*** QPSERV-PRICE LIST ID **** ' ||
                               l_req_qual_rec.qualifier_attr_value_from
                              );
               fnd_log.STRING
                  (fnd_log.level_procedure,
                   g_module ||
                   l_api_name,
                   '16003:*************************************************************************'
                  );
            END IF;

--dbms_output.put_line ('*************************************************************************');
--dbms_output.put_line ('*** QPSERV-PRICE LIST ID **** ' || l_req_qual_rec.QUALIFIER_ATTR_VALUE_FROM);
--dbms_output.put_line ('*************************************************************************');
            IF NOT NVL (p_detail_rec.intent, 'JA') = 'LM'
            THEN                                              --LM CHECK START
--GROUP II.V

               --ADDED FOR AICPA
               IF l_pricing_contexts_tbl.COUNT > 0
               THEN
                  l_ctr                      := l_pricing_contexts_tbl.FIRST;

                  LOOP
                     l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                                   1;
                     l_req_line_attr_tbl (l_line_attr_tbl_ctr).line_index := 2;
                     l_req_line_attr_tbl (l_line_attr_tbl_ctr).validated_flag :=
                                                                           'N';
                     l_req_line_attr_tbl (l_line_attr_tbl_ctr).pricing_context :=
                                   l_pricing_contexts_tbl (l_ctr).context_name;
                     l_req_line_attr_tbl (l_line_attr_tbl_ctr).pricing_attribute :=
                                 l_pricing_contexts_tbl (l_ctr).attribute_name;
                     l_req_line_attr_tbl (l_line_attr_tbl_ctr).pricing_attr_value_from :=
                                l_pricing_contexts_tbl (l_ctr).attribute_value;
                     EXIT WHEN l_pricing_contexts_tbl.LAST = l_ctr;
                     l_ctr                      :=
                                           l_pricing_contexts_tbl.NEXT (l_ctr);
                  END LOOP;
               END IF;

               IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING
                     (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '17001:*************************************************************************'
                     );
                  fnd_log.STRING
                     (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '17002:*** SERV BEFORE PA (REQ_LINE_ATTR_TBL_COUNT ) **** ' ||
                      l_req_line_attr_tbl.COUNT
                     );
               END IF;

               --dbms_output.put_line ('*************************************************************************');
               --dbms_output.put_line ('*** SERV BEFORE PA (REQ_LINE_ATTR_TBL_COUNT ) **** ' ||l_req_line_attr_tbl.count);
               build_top_pa (p_cle_id                           => p_detail_rec.subline_id,
                             p_service_index                    => 2,
                             px_line_attr_tbl_ctr               => l_line_attr_tbl_ctr,
                             px_req_line_attr_tbl               => l_req_line_attr_tbl
                            );

               IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING
                     (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '17003:*** SERV AFTER  PA (REQ_LINE_ATTR_TBL_COUNT ) **** ' ||
                      l_req_line_attr_tbl.COUNT
                     );
                  fnd_log.STRING
                     (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '17004:*************************************************************************'
                     );
               END IF;

               --dbms_output.put_line ('*** SERV AFTER  PA (REQ_LINE_ATTR_TBL_COUNT ) **** ' ||l_req_line_attr_tbl.count);
               --dbms_output.put_line ('*************************************************************************');

               --GROUP II.VI
               IF check_hdr_discount (p_chr_id                           => l_hdrtop_rec.kh_id)
               THEN
--For Order Type
                  l_line_tbl_ctr             := l_line_tbl_ctr +
                                                1;
                  l_req_line_rec4.request_type_code := 'ONT';
                  l_req_line_rec4.line_index := l_line_tbl_ctr;
                  l_req_line_rec4.line_type_code := 'ORDER';
                  l_req_line_rec4.pricing_effective_date := l_def_pricing_date;
                  l_req_line_rec4.currency_code := l_currency;
                  l_req_line_rec4.price_flag := 'Y';
                  l_req_line_tbl (l_line_tbl_ctr) := l_req_line_rec4;

                  IF (fnd_log.level_procedure >=
                                               fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                        (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '17001:*************************************************************************'
                        );
                     fnd_log.STRING
                            (fnd_log.level_procedure,
                             g_module ||
                             l_api_name,
                             '17002:******** SERV HDR ADJUST CURRENCY *** ' ||
                             l_currency ||
                             ' PRICING DATE ' ||
                             l_def_pricing_date
                            );
                     fnd_log.STRING
                        (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '17003:*************************************************************************'
                        );
                     fnd_log.STRING
                                   (fnd_log.level_procedure,
                                    g_module ||
                                    l_api_name,
                                    '17004:*** QPPROD-LINE TBL COUNT **** ' ||
                                    l_req_line_tbl.COUNT ||
                                    ' ***** LINE TBL CTR ' ||
                                    l_line_tbl_ctr
                                   );
                     fnd_log.STRING
                        (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '17005:*************************************************************************'
                        );
                     fnd_log.STRING
                        (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '17006:*************************************************************************'
                        );
                     fnd_log.STRING
                        (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '17007:*** SERV BEFORE HDR ADJ (REQ LINE_DETL_TBL_COUNT) **** ' ||
                         l_req_line_detail_tbl.COUNT
                        );
                  END IF;

--dbms_output.put_line ('*************************************************************************');
--dbms_output.put_line ('******** SERV HDR ADJUST CURRENCY *** ' || l_currency || ' PRICING DATE ' || l_def_pricing_date);
--dbms_output.put_line ('*************************************************************************');
--dbms_output.put_line ('*** QPPROD-LINE TBL COUNT **** ' ||l_req_line_tbl.count || ' ***** LINE TBL CTR '|| l_line_tbl_ctr);
--dbms_output.put_line ('*************************************************************************');

                  --dbms_output.put_line ('*************************************************************************');
                  --dbms_output.put_line ('*** SERV BEFORE HDR ADJ (REQ LINE_DETL_TBL_COUNT) **** ' ||l_req_line_detail_tbl.count);
                  build_hdr_adj
                               (p_chr_id                           => l_hdrtop_rec.kh_id,
                                p_item_id                          => l_qpserv_inv_id,
                                p_service_index                    => l_line_tbl_ctr,
                                p_line_detl_tbl_ctr                => l_line_detl_tbl_ctr,
                                p_req_line_detail_tbl              => l_req_line_detail_tbl
                               );

                  IF (fnd_log.level_procedure >=
                                               fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING
                        (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '18001:*** SERV AFTER  HDR ADJ REQ LINE_DETL_TBL_COUNT **** ' ||
                         l_req_line_detail_tbl.COUNT
                        );
                     fnd_log.STRING
                        (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '18002:*************************************************************************'
                        );
                  END IF;
               --dbms_output.put_line ('*** SERV AFTER  HDR ADJ REQ LINE_DETL_TBL_COUNT **** ' ||l_req_line_detail_tbl.count);
               --dbms_output.put_line ('*************************************************************************');
               END IF;

--GROUP II.VII
               IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING
                     (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '19001:*************************************************************************'
                     );
                  fnd_log.STRING
                     (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '19002:*** SERV BEFORE LIN ADJ (REQ LINE_DETL_TBL_COUNT) **** ' ||
                      l_req_line_detail_tbl.COUNT
                     );
               END IF;

               --dbms_output.put_line ('*************************************************************************');
               --dbms_output.put_line ('*** SERV BEFORE LIN ADJ (REQ LINE_DETL_TBL_COUNT) **** ' ||l_req_line_detail_tbl.count);
               build_top_adj (p_cle_id                           => p_detail_rec.line_id,
                              p_item_id                          => l_qpserv_inv_id,
                              p_service_index                    => 2,
                              p_line_detl_tbl_ctr                => l_line_detl_tbl_ctr,
                              p_req_line_detail_tbl              => l_req_line_detail_tbl
                             );

               IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING
                     (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '19003:*** SERV AFTER LIN ADJ (REQ LINE_DETL_TBL_COUNT) **** ' ||
                      l_req_line_detail_tbl.COUNT
                     );
                  fnd_log.STRING
                     (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '19004:*************************************************************************'
                     );
               END IF;

               --dbms_output.put_line ('*** SERV AFTER LIN ADJ (REQ LINE_DETL_TBL_COUNT) **** ' ||l_req_line_detail_tbl.count);
               --dbms_output.put_line ('*************************************************************************');

               --GROUP II.VIII
               IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING
                     (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '19005:*************************************************************************'
                     );
                  fnd_log.STRING
                     (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '19006:*** SERV BEFORE SUB LINE ADJ (REQ LINE_DETL_TBL_COUNT) **** ' ||
                      l_req_line_detail_tbl.COUNT
                     );
               END IF;

               --dbms_output.put_line ('*************************************************************************');
               --dbms_output.put_line ('*** SERV BEFORE SUB LINE ADJ (REQ LINE_DETL_TBL_COUNT) **** ' ||l_req_line_detail_tbl.count);
               build_top_adj (p_cle_id                           => p_detail_rec.subline_id,
                              p_item_id                          => l_qpserv_inv_id,
                              p_service_index                    => 2,
                              p_line_detl_tbl_ctr                => l_line_detl_tbl_ctr,
                              p_req_line_detail_tbl              => l_req_line_detail_tbl
                             );

               IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING
                     (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '19007:*** SERV BEFORE SUB LINE ADJ (REQ LINE_DETL_TBL_COUNT) **** ' ||
                      l_req_line_detail_tbl.COUNT
                     );
                  fnd_log.STRING
                     (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '19008:*************************************************************************'
                     );
               END IF;

               --dbms_output.put_line ('*** SERV BEFORE SUB LINE ADJ (REQ LINE_DETL_TBL_COUNT) **** ' ||l_req_line_detail_tbl.count);
               --dbms_output.put_line ('*************************************************************************');

               --GROUP II.IX

               --ADDED FOR AICPA
               IF l_qual_contexts_tbl.COUNT > 0
               THEN
                  l_ctr                      := l_qual_contexts_tbl.FIRST;

                  LOOP
                     l_line_qual_tbl_ctr        := l_line_qual_tbl_ctr +
                                                   1;
                     l_req_qual_tbl (l_line_qual_tbl_ctr).line_index := 2;
                     l_req_qual_tbl (l_line_qual_tbl_ctr).qualifier_context :=
                                      l_qual_contexts_tbl (l_ctr).context_name;
                     l_req_qual_tbl (l_line_qual_tbl_ctr).qualifier_attribute :=
                                    l_qual_contexts_tbl (l_ctr).attribute_name;
                     l_req_qual_tbl (l_line_qual_tbl_ctr).qualifier_attr_value_from :=
                                   l_qual_contexts_tbl (l_ctr).attribute_value;
                     l_req_qual_tbl (l_line_qual_tbl_ctr).validated_flag :=
                                                                           'N';
                     EXIT WHEN l_qual_contexts_tbl.LAST = l_ctr;
                     l_ctr                      :=
                                              l_qual_contexts_tbl.NEXT (l_ctr);
                  END LOOP;
               END IF;

               IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING
                     (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '19009:*************************************************************************'
                     );
                  fnd_log.STRING
                     (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '19010:*** SERV BEFORE QUAL (REQ QUAL_TBL_COUNT) **** ' ||
                      l_req_qual_tbl.COUNT
                     );
               END IF;

               --dbms_output.put_line ('*************************************************************************');
               --dbms_output.put_line ('*** SERV BEFORE QUAL (REQ QUAL_TBL_COUNT) **** ' ||l_req_qual_tbl.count);
               build_top_qa (p_cle_id                           => p_detail_rec.line_id,
                             p_item_id                          => NULL,
                             p_service_index                    => 2,
                             p_line_qual_tbl_ctr                => l_line_qual_tbl_ctr,
                             p_req_qual_tbl                     => l_req_qual_tbl
                            );

               IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING
                     (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '19011:*************************************************************************'
                     );
                  fnd_log.STRING
                     (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '19012:*** SERV AFTER QUAL (REQ QUAL_TBL_COUNT) **** ' ||
                      l_req_qual_tbl.COUNT
                     );
               END IF;
            --dbms_output.put_line ('*************************************************************************');
            --dbms_output.put_line ('*** SERV AFTER QUAL (REQ QUAL_TBL_COUNT) **** ' ||l_req_qual_tbl.count);
            ELSE
               IF l_pricing_contexts_tbl.COUNT > 0
               THEN
                  l_ctr                      := l_pricing_contexts_tbl.FIRST;

                  LOOP
                     l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                                   1;
                     l_req_line_attr_tbl (l_line_attr_tbl_ctr).line_index := 2;
                     l_req_line_attr_tbl (l_line_attr_tbl_ctr).validated_flag :=
                                                                           'N';
                     l_req_line_attr_tbl (l_line_attr_tbl_ctr).pricing_context :=
                                   l_pricing_contexts_tbl (l_ctr).context_name;
                     l_req_line_attr_tbl (l_line_attr_tbl_ctr).pricing_attribute :=
                                 l_pricing_contexts_tbl (l_ctr).attribute_name;
                     l_req_line_attr_tbl (l_line_attr_tbl_ctr).pricing_attr_value_from :=
                                l_pricing_contexts_tbl (l_ctr).attribute_value;
                     EXIT WHEN l_pricing_contexts_tbl.LAST = l_ctr;
                     l_ctr                      :=
                                           l_pricing_contexts_tbl.NEXT (l_ctr);
                  END LOOP;
               END IF;

               IF l_qual_contexts_tbl.COUNT > 0
               THEN
                  l_ctr                      := l_qual_contexts_tbl.FIRST;

                  LOOP
                     l_line_qual_tbl_ctr        := l_line_qual_tbl_ctr +
                                                   1;
                     l_req_qual_tbl (l_line_qual_tbl_ctr).line_index := 2;
                     l_req_qual_tbl (l_line_qual_tbl_ctr).qualifier_context :=
                                      l_qual_contexts_tbl (l_ctr).context_name;
                     l_req_qual_tbl (l_line_qual_tbl_ctr).qualifier_attribute :=
                                    l_qual_contexts_tbl (l_ctr).attribute_name;
                     l_req_qual_tbl (l_line_qual_tbl_ctr).qualifier_attr_value_from :=
                                   l_qual_contexts_tbl (l_ctr).attribute_value;
                     l_req_qual_tbl (l_line_qual_tbl_ctr).validated_flag :=
                                                                           'N';
                     EXIT WHEN l_qual_contexts_tbl.LAST = l_ctr;
                     l_ctr                      :=
                                              l_qual_contexts_tbl.NEXT (l_ctr);
                  END LOOP;
               END IF;
            END IF;                                             --LM CHECK END

--GROUP II.X
            l_line_rela_tbl_ctr        := l_line_rela_tbl_ctr +
                                          1;
            l_req_related_lines_rec.line_index := 1;
            l_req_related_lines_rec.relationship_type_code := 'SERVICE_LINE';
            l_req_related_lines_rec.related_line_index := 2;
            l_req_related_lines_tbl (l_line_rela_tbl_ctr) :=
                                                       l_req_related_lines_rec;
         END IF;
--END DEPENDENT CONDITION
      ELSE
         IF l_pricing_contexts_tbl.COUNT > 0
         THEN
            l_ctr                      := l_pricing_contexts_tbl.FIRST;

            LOOP
               l_line_attr_tbl_ctr        := l_line_attr_tbl_ctr +
                                             1;
               l_req_line_attr_tbl (l_line_attr_tbl_ctr).line_index := 1;
               l_req_line_attr_tbl (l_line_attr_tbl_ctr).validated_flag := 'N';
               l_req_line_attr_tbl (l_line_attr_tbl_ctr).pricing_context :=
                                   l_pricing_contexts_tbl (l_ctr).context_name;
               l_req_line_attr_tbl (l_line_attr_tbl_ctr).pricing_attribute :=
                                 l_pricing_contexts_tbl (l_ctr).attribute_name;
               l_req_line_attr_tbl (l_line_attr_tbl_ctr).pricing_attr_value_from :=
                                l_pricing_contexts_tbl (l_ctr).attribute_value;
               EXIT WHEN l_pricing_contexts_tbl.LAST = l_ctr;
               l_ctr                      :=
                                           l_pricing_contexts_tbl.NEXT (l_ctr);
            END LOOP;
         END IF;

         IF l_qual_contexts_tbl.COUNT > 0
         THEN
            l_ctr                      := l_qual_contexts_tbl.FIRST;

            LOOP
               l_line_qual_tbl_ctr        := l_line_qual_tbl_ctr +
                                             1;
               l_req_qual_tbl (l_line_qual_tbl_ctr).line_index := 1;
               l_req_qual_tbl (l_line_qual_tbl_ctr).qualifier_context :=
                                      l_qual_contexts_tbl (l_ctr).context_name;
               l_req_qual_tbl (l_line_qual_tbl_ctr).qualifier_attribute :=
                                    l_qual_contexts_tbl (l_ctr).attribute_name;
               l_req_qual_tbl (l_line_qual_tbl_ctr).qualifier_attr_value_from :=
                                   l_qual_contexts_tbl (l_ctr).attribute_value;
               l_req_qual_tbl (l_line_qual_tbl_ctr).validated_flag := 'N';
               EXIT WHEN l_qual_contexts_tbl.LAST = l_ctr;
               l_ctr                      := l_qual_contexts_tbl.NEXT (l_ctr);
            END LOOP;
         END IF;
      END IF;

--END p_detail_rec.intent CHECK

-- SKEKKAR
-- Added debug statements to print all the parameters that we pass and get back from QP
-- bug 5069673
--
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)   THEN
    --
    -- Input Parameter 1: l_control_rec
    --
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************'
                               );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ************* Input Parameter l_control_rec *************'
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************'
                               );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_control_rec.PRICING_EVENT : '|| l_control_rec.PRICING_EVENT
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_control_rec.CALCULATE_FLAG : '|| l_control_rec.CALCULATE_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_control_rec.SIMULATION_FLAG : '|| l_control_rec.SIMULATION_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_control_rec.ROUNDING_FLAG : '|| l_control_rec.ROUNDING_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_control_rec.GSA_CHECK_FLAG : '|| l_control_rec.GSA_CHECK_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_control_rec.GSA_DUP_CHECK_FLAG : '|| l_control_rec.GSA_DUP_CHECK_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_control_rec.TEMP_TABLE_INSERT_FLAG : '|| l_control_rec.TEMP_TABLE_INSERT_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_control_rec.MANUAL_DISCOUNT_FLAG : '|| l_control_rec.MANUAL_DISCOUNT_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_control_rec.DEBUG_FLAG : '|| l_control_rec.DEBUG_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_control_rec.SOURCE_ORDER_AMOUNT_FLAG : '|| l_control_rec.SOURCE_ORDER_AMOUNT_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_control_rec.PUBLIC_API_CALL_FLAG : '|| l_control_rec.PUBLIC_API_CALL_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_control_rec.MANUAL_ADJUSTMENTS_CALL_FLAG : '|| l_control_rec.MANUAL_ADJUSTMENTS_CALL_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_control_rec.GET_FREIGHT_FLAG : '|| l_control_rec.GET_FREIGHT_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_control_rec.REQUEST_TYPE_CODE : '|| l_control_rec.REQUEST_TYPE_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_control_rec.VIEW_CODE : '|| l_control_rec.VIEW_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_control_rec.CHECK_CUST_VIEW_FLAG : '|| l_control_rec.CHECK_CUST_VIEW_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_control_rec.FULL_PRICING_CALL : '|| l_control_rec.FULL_PRICING_CALL
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_control_rec.USE_MULTI_CURRENCY : '|| l_control_rec.USE_MULTI_CURRENCY
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_control_rec.USER_CONVERSION_RATE : '|| l_control_rec.USER_CONVERSION_RATE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_control_rec.USER_CONVERSION_TYPE : '|| l_control_rec.USER_CONVERSION_TYPE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_control_rec.FUNCTION_CURRENCY : '|| l_control_rec.FUNCTION_CURRENCY
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_control_rec.ORG_ID : '|| l_control_rec.ORG_ID
                                );

    --
    -- Input Parameter 2: l_req_line_tbl
    --
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ********** Input Parameter 2: l_req_line_tbl ****************');
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl.COUNT '|| l_req_line_tbl.COUNT
                        );
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');
        IF l_req_line_tbl.COUNT > 0 THEN
            p := l_req_line_tbl.FIRST;
                LOOP
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ************* Parameter l_req_line_tbl('|| p ||') *************'
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').REQUEST_TYPE_CODE : '|| l_req_line_tbl(p).REQUEST_TYPE_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').PRICING_EVENT : '|| l_req_line_tbl(p).PRICING_EVENT
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').HEADER_ID : '|| l_req_line_tbl(p).HEADER_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').LINE_INDEX : '|| l_req_line_tbl(p).LINE_INDEX
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').LINE_ID : '|| l_req_line_tbl(p).LINE_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').LINE_TYPE_CODE : '|| l_req_line_tbl(p).LINE_TYPE_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').PRICING_EFFECTIVE_DATE : '|| l_req_line_tbl(p).PRICING_EFFECTIVE_DATE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').ACTIVE_DATE_FIRST : '|| l_req_line_tbl(p).ACTIVE_DATE_FIRST
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').ACTIVE_DATE_FIRST_TYPE : '|| l_req_line_tbl(p).ACTIVE_DATE_FIRST_TYPE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').ACTIVE_DATE_SECOND : '|| l_req_line_tbl(p).ACTIVE_DATE_SECOND
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').ACTIVE_DATE_FIRST_TYPE : '|| l_req_line_tbl(p).ACTIVE_DATE_FIRST_TYPE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').ACTIVE_DATE_SECOND : '|| l_req_line_tbl(p).ACTIVE_DATE_SECOND
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').ACTIVE_DATE_SECOND_TYPE : '|| l_req_line_tbl(p).ACTIVE_DATE_SECOND_TYPE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').LINE_QUANTITY : '|| l_req_line_tbl(p).LINE_QUANTITY
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').LINE_UOM_CODE : '|| l_req_line_tbl(p).LINE_UOM_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').UOM_QUANTITY : '|| l_req_line_tbl(p).UOM_QUANTITY
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').PRICED_QUANTITY : '|| l_req_line_tbl(p).PRICED_QUANTITY
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').PRICED_UOM_CODE : '|| l_req_line_tbl(p).PRICED_UOM_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').CURRENCY_CODE : '|| l_req_line_tbl(p).CURRENCY_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').UNIT_PRICE : '|| l_req_line_tbl(p).UNIT_PRICE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').PERCENT_PRICE : '|| l_req_line_tbl(p).PERCENT_PRICE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').ADJUSTED_UNIT_PRICE : '|| l_req_line_tbl(p).ADJUSTED_UNIT_PRICE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').UPDATED_ADJUSTED_UNIT_PRICE : '|| l_req_line_tbl(p).UPDATED_ADJUSTED_UNIT_PRICE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').PARENT_PRICE : '|| l_req_line_tbl(p).PARENT_PRICE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').PARENT_QUANTITY : '|| l_req_line_tbl(p).PARENT_QUANTITY
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').ROUNDING_FACTOR : '|| l_req_line_tbl(p).ROUNDING_FACTOR
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').PARENT_UOM_CODE : '|| l_req_line_tbl(p).PARENT_UOM_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').PRICING_PHASE_ID : '|| l_req_line_tbl(p).PRICING_PHASE_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').PRICE_FLAG : '|| l_req_line_tbl(p).PRICE_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').PROCESSED_CODE : '|| l_req_line_tbl(p).PROCESSED_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').PRICE_REQUEST_CODE : '|| l_req_line_tbl(p).PRICE_REQUEST_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').HOLD_CODE : '|| l_req_line_tbl(p).HOLD_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').HOLD_TEXT : '|| l_req_line_tbl(p).HOLD_TEXT
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').STATUS_CODE : '|| l_req_line_tbl(p).STATUS_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').STATUS_TEXT : '|| l_req_line_tbl(p).STATUS_TEXT
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').USAGE_PRICING_TYPE : '|| l_req_line_tbl(p).USAGE_PRICING_TYPE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').LINE_CATEGORY : '|| l_req_line_tbl(p).LINE_CATEGORY
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').CONTRACT_START_DATE : '|| l_req_line_tbl(p).CONTRACT_START_DATE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').CONTRACT_END_DATE : '|| l_req_line_tbl(p).CONTRACT_END_DATE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').LINE_UNIT_PRICE : '|| l_req_line_tbl(p).LINE_UNIT_PRICE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').EXTENDED_PRICE : '|| l_req_line_tbl(p).EXTENDED_PRICE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').LIST_PRICE_OVERRIDE_FLAG : '|| l_req_line_tbl(p).LIST_PRICE_OVERRIDE_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_tbl('|| p ||').CHARGE_PERIODICITY_CODE : '|| l_req_line_tbl(p).CHARGE_PERIODICITY_CODE
                                );
                EXIT WHEN l_req_line_tbl.LAST = p;
                p := l_req_line_tbl.NEXT(p);
            END LOOP;
        END IF; -- l_req_line_tbl.COUNT > 0

    --
    -- Input Parameter 3: l_req_qual_tbl
    --
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ************** Input Parameter 3: l_req_qual_tbl ******************');
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_qual_tbl.COUNT '|| l_req_qual_tbl.COUNT
                        );
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');
        IF l_req_qual_tbl.COUNT > 0 THEN
            p := l_req_qual_tbl.FIRST;
                LOOP
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ************* Parameter l_req_qual_tbl('|| p ||') *************'
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_qual_tbl('|| p ||').LINE_INDEX : '|| l_req_qual_tbl(p).LINE_INDEX
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_qual_tbl('|| p ||').QUALIFIER_CONTEXT : '|| l_req_qual_tbl(p).QUALIFIER_CONTEXT
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_qual_tbl('|| p ||').QUALIFIER_ATTRIBUTE : '|| l_req_qual_tbl(p).QUALIFIER_ATTRIBUTE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_qual_tbl('|| p ||').QUALIFIER_ATTR_VALUE_FROM : '|| l_req_qual_tbl(p).QUALIFIER_ATTR_VALUE_FROM
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_qual_tbl('|| p ||').QUALIFIER_ATTR_VALUE_TO : '|| l_req_qual_tbl(p).QUALIFIER_ATTR_VALUE_TO
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_qual_tbl('|| p ||').COMPARISON_OPERATOR_CODE : '|| l_req_qual_tbl(p).COMPARISON_OPERATOR_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_qual_tbl('|| p ||').VALIDATED_FLAG : '|| l_req_qual_tbl(p).VALIDATED_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_qual_tbl('|| p ||').STATUS_CODE : '|| l_req_qual_tbl(p).STATUS_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_qual_tbl('|| p ||').STATUS_TEXT : '|| l_req_qual_tbl(p).STATUS_TEXT
                                );
                EXIT WHEN l_req_qual_tbl.LAST = p;
                p := l_req_qual_tbl.NEXT(p);
            END LOOP;
        END IF; -- l_req_qual_tbl.COUNT > 0
    --
    -- Input Parameter 4: l_req_line_attr_tbl
    --
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ***************** Input Parameter 4: l_req_line_attr_tbl ******************');
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_attr_tbl.COUNT '|| l_req_line_attr_tbl.COUNT
                        );
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');
        IF l_req_line_attr_tbl.COUNT > 0 THEN
           p := l_req_line_attr_tbl.FIRST;
                LOOP
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ************* Parameter l_req_line_attr_tbl('|| p ||') *************'
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_attr_tbl('|| p ||').LINE_INDEX : '|| l_req_line_attr_tbl(p).LINE_INDEX
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_attr_tbl('|| p ||').PRICING_CONTEXT : '|| l_req_line_attr_tbl(p).PRICING_CONTEXT
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_attr_tbl('|| p ||').PRICING_ATTRIBUTE : '|| l_req_line_attr_tbl(p).PRICING_ATTRIBUTE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_attr_tbl('|| p ||').PRICING_ATTR_VALUE_FROM : '|| l_req_line_attr_tbl(p).PRICING_ATTR_VALUE_FROM
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_attr_tbl('|| p ||').PRICING_ATTR_VALUE_TO : '|| l_req_line_attr_tbl(p).PRICING_ATTR_VALUE_TO
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_attr_tbl('|| p ||').VALIDATED_FLAG : '|| l_req_line_attr_tbl(p).VALIDATED_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_attr_tbl('|| p ||').STATUS_CODE : '|| l_req_line_attr_tbl(p).STATUS_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_attr_tbl('|| p ||').STATUS_TEXT : '|| l_req_line_attr_tbl(p).STATUS_TEXT
                                );
                EXIT WHEN l_req_line_attr_tbl.LAST = p;
                p := l_req_line_attr_tbl.NEXT(p);
            END LOOP;
        END IF; -- l_req_line_attr_tbl.COUNT > 0

    --
    -- Input Parameter 5: l_req_line_detail_tbl
    --
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ***************** Input Parameter 5: l_req_line_detail_tbl ******************');
            fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl.COUNT '|| l_req_line_detail_tbl.COUNT
                        );
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');

        IF l_req_line_detail_tbl.COUNT > 0 THEN
            p := l_req_line_detail_tbl.FIRST;
                LOOP
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ************* Parameter l_req_line_detail_tbl('|| p ||') *************'
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').LINE_DETAIL_INDEX : '|| l_req_line_detail_tbl(p).LINE_DETAIL_INDEX
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').LINE_DETAIL_ID : '|| l_req_line_detail_tbl(p).LINE_DETAIL_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').LINE_DETAIL_TYPE_CODE : '|| l_req_line_detail_tbl(p).LINE_DETAIL_TYPE_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').LINE_INDEX : '|| l_req_line_detail_tbl(p).LINE_INDEX
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').LIST_HEADER_ID : '|| l_req_line_detail_tbl(p).LIST_HEADER_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').LIST_LINE_ID : '|| l_req_line_detail_tbl(p).LIST_LINE_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').LIST_LINE_TYPE_CODE : '|| l_req_line_detail_tbl(p).LIST_LINE_TYPE_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').SUBSTITUTION_TYPE_CODE : '|| l_req_line_detail_tbl(p).SUBSTITUTION_TYPE_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').SUBSTITUTION_FROM : '|| l_req_line_detail_tbl(p).SUBSTITUTION_FROM
                                );
                        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').SUBSTITUTION_TO : '|| l_req_line_detail_tbl(p).SUBSTITUTION_TO
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').AUTOMATIC_FLAG : '|| l_req_line_detail_tbl(p).AUTOMATIC_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').OPERAND_CALCULATION_CODE : '|| l_req_line_detail_tbl(p).OPERAND_CALCULATION_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').OPERAND_VALUE : '|| l_req_line_detail_tbl(p).OPERAND_VALUE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').PRICING_GROUP_SEQUENCE : '|| l_req_line_detail_tbl(p).PRICING_GROUP_SEQUENCE
                                );
                        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').PRICE_BREAK_TYPE_CODE : '|| l_req_line_detail_tbl(p).PRICE_BREAK_TYPE_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').CREATED_FROM_LIST_TYPE_CODE : '|| l_req_line_detail_tbl(p).CREATED_FROM_LIST_TYPE_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').PRICING_PHASE_ID : '|| l_req_line_detail_tbl(p).PRICING_PHASE_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').LIST_PRICE : '|| l_req_line_detail_tbl(p).LIST_PRICE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').LINE_QUANTITY : '|| l_req_line_detail_tbl(p).LINE_QUANTITY
                                );
                        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').ADJUSTMENT_AMOUNT : '|| l_req_line_detail_tbl(p).ADJUSTMENT_AMOUNT
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').APPLIED_FLAG : '|| l_req_line_detail_tbl(p).APPLIED_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').MODIFIER_LEVEL_CODE : '|| l_req_line_detail_tbl(p).MODIFIER_LEVEL_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').STATUS_CODE : '|| l_req_line_detail_tbl(p).STATUS_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').STATUS_TEXT : '|| l_req_line_detail_tbl(p).STATUS_TEXT
                                );
                        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').SUBSTITUTION_ATTRIBUTE : '|| l_req_line_detail_tbl(p).SUBSTITUTION_ATTRIBUTE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').ACCRUAL_FLAG : '|| l_req_line_detail_tbl(p).ACCRUAL_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').LIST_LINE_NO : '|| l_req_line_detail_tbl(p).LIST_LINE_NO
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').ESTIM_GL_VALUE : '|| l_req_line_detail_tbl(p).ESTIM_GL_VALUE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').ACCRUAL_CONVERSION_RATE : '|| l_req_line_detail_tbl(p).ACCRUAL_CONVERSION_RATE
                                );
                        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').OVERRIDE_FLAG : '|| l_req_line_detail_tbl(p).OVERRIDE_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').PRINT_ON_INVOICE_FLAG : '|| l_req_line_detail_tbl(p).PRINT_ON_INVOICE_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').INVENTORY_ITEM_ID : '|| l_req_line_detail_tbl(p).INVENTORY_ITEM_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').ORGANIZATION_ID : '|| l_req_line_detail_tbl(p).ORGANIZATION_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').RELATED_ITEM_ID : '|| l_req_line_detail_tbl(p).RELATED_ITEM_ID
                                );
                        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').RELATIONSHIP_TYPE_ID : '|| l_req_line_detail_tbl(p).RELATIONSHIP_TYPE_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').ESTIM_ACCRUAL_RATE : '|| l_req_line_detail_tbl(p).ESTIM_ACCRUAL_RATE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').EXPIRATION_DATE : '|| l_req_line_detail_tbl(p).EXPIRATION_DATE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').BENEFIT_PRICE_LIST_LINE_ID : '|| l_req_line_detail_tbl(p).BENEFIT_PRICE_LIST_LINE_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').RECURRING_FLAG : '|| l_req_line_detail_tbl(p).RECURRING_FLAG
                                );
                        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').RECURRING_VALUE : '|| l_req_line_detail_tbl(p).RECURRING_VALUE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').BENEFIT_LIMIT : '|| l_req_line_detail_tbl(p).BENEFIT_LIMIT
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').CHARGE_TYPE_CODE : '|| l_req_line_detail_tbl(p).CHARGE_TYPE_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').CHARGE_SUBTYPE_CODE : '|| l_req_line_detail_tbl(p).CHARGE_SUBTYPE_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').INCLUDE_ON_RETURNS_FLAG : '|| l_req_line_detail_tbl(p).INCLUDE_ON_RETURNS_FLAG
                                );
                        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').BENEFIT_QTY : '|| l_req_line_detail_tbl(p).BENEFIT_QTY
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').BENEFIT_UOM_CODE : '|| l_req_line_detail_tbl(p).BENEFIT_UOM_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').PRORATION_TYPE_CODE : '|| l_req_line_detail_tbl(p).PRORATION_TYPE_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').SOURCE_SYSTEM_CODE : '|| l_req_line_detail_tbl(p).SOURCE_SYSTEM_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').REBATE_TRANSACTION_TYPE_CODE : '|| l_req_line_detail_tbl(p).REBATE_TRANSACTION_TYPE_CODE
                                );
                        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').SECONDARY_PRICELIST_IND : '|| l_req_line_detail_tbl(p).SECONDARY_PRICELIST_IND
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').GROUP_VALUE : '|| l_req_line_detail_tbl(p).GROUP_VALUE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').COMMENTS : '|| l_req_line_detail_tbl(p).COMMENTS
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').UPDATED_FLAG : '|| l_req_line_detail_tbl(p).UPDATED_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').PROCESS_CODE : '|| l_req_line_detail_tbl(p).PROCESS_CODE
                                );
                        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').LIMIT_CODE : '|| l_req_line_detail_tbl(p).LIMIT_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').LIMIT_TEXT : '|| l_req_line_detail_tbl(p).LIMIT_TEXT
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').FORMULA_ID : '|| l_req_line_detail_tbl(p).FORMULA_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').CALCULATION_CODE : '|| l_req_line_detail_tbl(p).CALCULATION_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').ROUNDING_FACTOR : '|| l_req_line_detail_tbl(p).ROUNDING_FACTOR
                                );
                        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').currency_detail_id : '|| l_req_line_detail_tbl(p).currency_detail_id
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').currency_header_id : '|| l_req_line_detail_tbl(p).currency_header_id
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').selling_rounding_factor : '|| l_req_line_detail_tbl(p).selling_rounding_factor
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').order_currency : '|| l_req_line_detail_tbl(p).order_currency
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').pricing_effective_date : '|| l_req_line_detail_tbl(p).pricing_effective_date
                                );
                        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').base_currency_code : '|| l_req_line_detail_tbl(p).base_currency_code
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').change_reason_code : '|| l_req_line_detail_tbl(p).change_reason_code
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').change_reason_text : '|| l_req_line_detail_tbl(p).change_reason_text
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').break_uom_code : '|| l_req_line_detail_tbl(p).break_uom_code
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').break_uom_context : '|| l_req_line_detail_tbl(p).break_uom_context
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_tbl('|| p ||').break_uom_attribute : '|| l_req_line_detail_tbl(p).break_uom_attribute
                                );
                EXIT WHEN l_req_line_detail_tbl.LAST = p;
                p := l_req_line_detail_tbl.NEXT(p);
            END LOOP;
        END IF; -- l_req_line_detail_tbl.COUNT > 0
    --
    -- Input Parameter 6: l_req_line_detail_qual_tbl
    --
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ***************** Input Parameter 6: l_req_line_detail_qual_tbl ******************');
            fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_qual_tbl.COUNT '|| l_req_line_detail_qual_tbl.COUNT
                        );
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');

        IF l_req_line_detail_qual_tbl.COUNT > 0 THEN
           p := l_req_line_detail_qual_tbl.FIRST;
                LOOP
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ************* Parameter l_req_line_detail_qual_tbl('|| p ||') *************'
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_qual_tbl('|| p ||').LINE_DETAIL_INDEX : '|| l_req_line_detail_qual_tbl(p).LINE_DETAIL_INDEX
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_qual_tbl('|| p ||').QUALIFIER_CONTEXT : '|| l_req_line_detail_qual_tbl(p).QUALIFIER_CONTEXT
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_qual_tbl('|| p ||').QUALIFIER_ATTRIBUTE : '|| l_req_line_detail_qual_tbl(p).QUALIFIER_ATTRIBUTE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_qual_tbl('|| p ||').QUALIFIER_ATTR_VALUE_FROM : '|| l_req_line_detail_qual_tbl(p).QUALIFIER_ATTR_VALUE_FROM
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_qual_tbl('|| p ||').QUALIFIER_ATTR_VALUE_TO : '|| l_req_line_detail_qual_tbl(p).QUALIFIER_ATTR_VALUE_TO
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_qual_tbl('|| p ||').COMPARISON_OPERATOR_CODE : '|| l_req_line_detail_qual_tbl(p).COMPARISON_OPERATOR_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_qual_tbl('|| p ||').VALIDATED_FLAG : '|| l_req_line_detail_qual_tbl(p).VALIDATED_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_qual_tbl('|| p ||').STATUS_CODE : '|| l_req_line_detail_qual_tbl(p).STATUS_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_qual_tbl('|| p ||').STATUS_TEXT : '|| l_req_line_detail_qual_tbl(p).STATUS_TEXT
                                );
                EXIT WHEN l_req_line_detail_qual_tbl.LAST = p;
                p := l_req_line_detail_qual_tbl.NEXT(p);
            END LOOP;
        END IF; -- l_req_line_detail_qual_tbl.COUNT > 0
    --
    -- Input Parameter 7: l_req_line_detail_attr_tbl
    --
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ***************** Input Parameter 7: l_req_line_detail_attr_tbl ******************');
            fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_attr_tbl.COUNT '|| l_req_line_detail_attr_tbl.COUNT
                        );
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');

        IF l_req_line_detail_attr_tbl.COUNT > 0 THEN
           p := l_req_line_detail_attr_tbl.FIRST;
                LOOP
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ************* Parameter l_req_line_detail_attr_tbl('|| p ||') *************'
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_attr_tbl('|| p ||').LINE_DETAIL_INDEX : '|| l_req_line_detail_attr_tbl(p).LINE_DETAIL_INDEX
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_attr_tbl('|| p ||').LINE_INDEX : '|| l_req_line_detail_attr_tbl(p).LINE_INDEX
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_attr_tbl('|| p ||').PRICING_CONTEXT : '|| l_req_line_detail_attr_tbl(p).PRICING_CONTEXT
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_attr_tbl('|| p ||').PRICING_ATTRIBUTE : '|| l_req_line_detail_attr_tbl(p).PRICING_ATTRIBUTE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_attr_tbl('|| p ||').PRICING_ATTR_VALUE_FROM : '|| l_req_line_detail_attr_tbl(p).PRICING_ATTR_VALUE_FROM
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_attr_tbl('|| p ||').PRICING_ATTR_VALUE_TO : '|| l_req_line_detail_attr_tbl(p).PRICING_ATTR_VALUE_TO
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_attr_tbl('|| p ||').VALIDATED_FLAG : '|| l_req_line_detail_attr_tbl(p).VALIDATED_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_attr_tbl('|| p ||').STATUS_CODE : '|| l_req_line_detail_attr_tbl(p).STATUS_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_line_detail_attr_tbl('|| p ||').STATUS_TEXT : '|| l_req_line_detail_attr_tbl(p).STATUS_TEXT
                                );
                EXIT WHEN l_req_line_detail_attr_tbl.LAST = p;
                p := l_req_line_detail_attr_tbl.NEXT(p);
            END LOOP;
        END IF; -- l_req_line_detail_attr_tbl.COUNT > 0

    --
    -- Input Parameter 8: l_req_related_lines_tbl
    --
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ***************** Input Parameter 8: l_req_related_lines_tbl ******************');
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_related_lines_tbl.COUNT '|| l_req_related_lines_tbl.COUNT
                        );
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');

        IF l_req_related_lines_tbl.COUNT > 0 THEN
           p := l_req_related_lines_tbl.FIRST;
                LOOP
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ************* Parameter l_req_related_lines_tbl('|| p ||') *************'
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_related_lines_tbl('|| p ||').LINE_INDEX : '|| l_req_related_lines_tbl(p).LINE_INDEX
                                );
                 fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_related_lines_tbl('|| p ||').LINE_DETAIL_INDEX : '|| l_req_related_lines_tbl(p).LINE_DETAIL_INDEX
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_related_lines_tbl('|| p ||').RELATIONSHIP_TYPE_CODE : '|| l_req_related_lines_tbl(p).RELATIONSHIP_TYPE_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_related_lines_tbl('|| p ||').RELATED_LINE_INDEX : '|| l_req_related_lines_tbl(p).RELATED_LINE_INDEX
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_related_lines_tbl('|| p ||').RELATED_LINE_DETAIL_INDEX : '|| l_req_related_lines_tbl(p).RELATED_LINE_DETAIL_INDEX
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_related_lines_tbl('|| p ||').STATUS_CODE : '|| l_req_related_lines_tbl(p).STATUS_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: l_req_related_lines_tbl('|| p ||').STATUS_TEXT : '|| l_req_related_lines_tbl(p).STATUS_TEXT
                                );
                EXIT WHEN l_req_related_lines_tbl.LAST = p;
                p := l_req_related_lines_tbl.NEXT(p);
            END LOOP;
        END IF; -- l_req_related_lines_tbl.COUNT > 0

    END IF; -- SKEKKAR end Added debug statements to print all the parameters bug 5069673


      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '19013:*** BEFORE QP CALL STATUS **** ' ||
                         lx_return_status
                        );
         fnd_log.STRING (fnd_log.level_procedure,g_module ||l_api_name,
                         '19013: **** Calling qp_preq_pub.price_request *****'
                        );
         fnd_log.STRING (fnd_log.level_procedure,g_module ||l_api_name,
                         '19013: qp_preq_pub.price_request Start Time : '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SSSS')
                        );
      END IF;

--dbms_output.put_line ('*** BEFORE QP CALL STATUS **** ' ||lx_return_status);

      --Pricing Engine Call
      qp_preq_pub.price_request
                       (p_control_rec                      => l_control_rec,
                        p_line_tbl                         => l_req_line_tbl,
                        p_qual_tbl                         => l_req_qual_tbl,
                        p_line_attr_tbl                    => l_req_line_attr_tbl,
                        p_line_detail_tbl                  => l_req_line_detail_tbl,
                        p_line_detail_qual_tbl             => l_req_line_detail_qual_tbl,
                        p_line_detail_attr_tbl             => l_req_line_detail_attr_tbl,
                        p_related_lines_tbl                => l_req_related_lines_tbl,
                        x_line_tbl                         => lx_req_line_tbl,
                        x_line_qual                        => lx_req_qual_tbl,
                        x_line_attr_tbl                    => lx_req_line_attr_tbl,
                        x_line_detail_tbl                  => lx_req_line_detail_tbl,
                        x_line_detail_qual_tbl             => lx_req_line_detail_qual_tbl,
                        x_line_detail_attr_tbl             => lx_req_line_detail_attr_tbl,
                        x_related_lines_tbl                => lx_req_related_lines_tbl,
                        x_return_status                    => lx_return_status,
                        x_return_status_text               => lx_return_status_text
                       );

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,g_module ||l_api_name,
                         '19014: **** After Calling qp_preq_pub.price_request ***** Status : '||lx_return_status
                        );
         fnd_log.STRING (fnd_log.level_procedure,g_module ||l_api_name,
                         '19014: qp_preq_pub.price_request End Time : '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SSSS')
                        );

         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '19014:*** AFTER QP CALL STATUS **** ' ||
                         lx_return_status
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '19014:*** AFTER QP CALL STATUS TEXT **** ' ||
                         lx_return_status_text
                        );
      END IF;

-- SKEKKAR
-- Added debug statements to print all the parameters that we pass and get back from QP
-- bug 5069673
--
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)   THEN
    --
    -- Output Parameter 1: lx_req_line_tbl
    --
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl.COUNT '|| lx_req_line_tbl.COUNT
                        );
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');
        IF lx_req_line_tbl.COUNT > 0 THEN
            p := lx_req_line_tbl.FIRST;
                LOOP
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ************* Parameter lx_req_line_tbl('|| p ||') *************'
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').REQUEST_TYPE_CODE : '|| lx_req_line_tbl(p).REQUEST_TYPE_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').PRICING_EVENT : '|| lx_req_line_tbl(p).PRICING_EVENT
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').HEADER_ID : '|| lx_req_line_tbl(p).HEADER_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').LINE_INDEX : '|| lx_req_line_tbl(p).LINE_INDEX
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').LINE_ID : '|| lx_req_line_tbl(p).LINE_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').LINE_TYPE_CODE : '|| lx_req_line_tbl(p).LINE_TYPE_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').PRICING_EFFECTIVE_DATE : '|| lx_req_line_tbl(p).PRICING_EFFECTIVE_DATE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').ACTIVE_DATE_FIRST : '|| lx_req_line_tbl(p).ACTIVE_DATE_FIRST
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').ACTIVE_DATE_FIRST_TYPE : '|| lx_req_line_tbl(p).ACTIVE_DATE_FIRST_TYPE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').ACTIVE_DATE_SECOND : '|| lx_req_line_tbl(p).ACTIVE_DATE_SECOND
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').ACTIVE_DATE_FIRST_TYPE : '|| lx_req_line_tbl(p).ACTIVE_DATE_FIRST_TYPE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').ACTIVE_DATE_SECOND : '|| lx_req_line_tbl(p).ACTIVE_DATE_SECOND
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').ACTIVE_DATE_SECOND_TYPE : '|| lx_req_line_tbl(p).ACTIVE_DATE_SECOND_TYPE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').LINE_QUANTITY : '|| lx_req_line_tbl(p).LINE_QUANTITY
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').LINE_UOM_CODE : '|| lx_req_line_tbl(p).LINE_UOM_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').UOM_QUANTITY : '|| lx_req_line_tbl(p).UOM_QUANTITY
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').PRICED_QUANTITY : '|| lx_req_line_tbl(p).PRICED_QUANTITY
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').PRICED_UOM_CODE : '|| lx_req_line_tbl(p).PRICED_UOM_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').CURRENCY_CODE : '|| lx_req_line_tbl(p).CURRENCY_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').UNIT_PRICE : '|| lx_req_line_tbl(p).UNIT_PRICE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').PERCENT_PRICE : '|| lx_req_line_tbl(p).PERCENT_PRICE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').ADJUSTED_UNIT_PRICE : '|| lx_req_line_tbl(p).ADJUSTED_UNIT_PRICE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').UPDATED_ADJUSTED_UNIT_PRICE : '|| lx_req_line_tbl(p).UPDATED_ADJUSTED_UNIT_PRICE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').PARENT_PRICE : '|| lx_req_line_tbl(p).PARENT_PRICE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').PARENT_QUANTITY : '|| lx_req_line_tbl(p).PARENT_QUANTITY
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').ROUNDING_FACTOR : '|| lx_req_line_tbl(p).ROUNDING_FACTOR
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').PARENT_UOM_CODE : '|| lx_req_line_tbl(p).PARENT_UOM_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').PRICING_PHASE_ID : '|| lx_req_line_tbl(p).PRICING_PHASE_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').PRICE_FLAG : '|| lx_req_line_tbl(p).PRICE_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').PROCESSED_CODE : '|| lx_req_line_tbl(p).PROCESSED_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').PRICE_REQUEST_CODE : '|| lx_req_line_tbl(p).PRICE_REQUEST_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').HOLD_CODE : '|| lx_req_line_tbl(p).HOLD_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').HOLD_TEXT : '|| lx_req_line_tbl(p).HOLD_TEXT
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').STATUS_CODE : '|| lx_req_line_tbl(p).STATUS_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').STATUS_TEXT : '|| lx_req_line_tbl(p).STATUS_TEXT
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').USAGE_PRICING_TYPE : '|| lx_req_line_tbl(p).USAGE_PRICING_TYPE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').LINE_CATEGORY : '|| lx_req_line_tbl(p).LINE_CATEGORY
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').CONTRACT_START_DATE : '|| lx_req_line_tbl(p).CONTRACT_START_DATE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').CONTRACT_END_DATE : '|| lx_req_line_tbl(p).CONTRACT_END_DATE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').LINE_UNIT_PRICE : '|| lx_req_line_tbl(p).LINE_UNIT_PRICE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').EXTENDED_PRICE : '|| lx_req_line_tbl(p).EXTENDED_PRICE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').LIST_PRICE_OVERRIDE_FLAG : '|| lx_req_line_tbl(p).LIST_PRICE_OVERRIDE_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_tbl('|| p ||').CHARGE_PERIODICITY_CODE : '|| lx_req_line_tbl(p).CHARGE_PERIODICITY_CODE
                                );
                EXIT WHEN lx_req_line_tbl.LAST = p;
                p := lx_req_line_tbl.NEXT(p);
            END LOOP;
        END IF; -- lx_req_line_tbl.COUNT > 0

    --
    -- Output Parameter 2: lx_req_qual_tbl
    --
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ************* Output Parameter 2: lx_req_qual_tbl ************');
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_qual_tbl.COUNT '|| lx_req_qual_tbl.COUNT
                        );
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');
        IF lx_req_qual_tbl.COUNT > 0 THEN
            p := lx_req_qual_tbl.FIRST;
                LOOP
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ************* Parameter lx_req_qual_tbl('|| p ||') *************'
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_qual_tbl('|| p ||').LINE_INDEX : '|| lx_req_qual_tbl(p).LINE_INDEX
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_qual_tbl('|| p ||').QUALIFIER_CONTEXT : '|| lx_req_qual_tbl(p).QUALIFIER_CONTEXT
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_qual_tbl('|| p ||').QUALIFIER_ATTRIBUTE : '|| lx_req_qual_tbl(p).QUALIFIER_ATTRIBUTE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_qual_tbl('|| p ||').QUALIFIER_ATTR_VALUE_FROM : '|| lx_req_qual_tbl(p).QUALIFIER_ATTR_VALUE_FROM
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_qual_tbl('|| p ||').QUALIFIER_ATTR_VALUE_TO : '|| lx_req_qual_tbl(p).QUALIFIER_ATTR_VALUE_TO
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_qual_tbl('|| p ||').COMPARISON_OPERATOR_CODE : '|| lx_req_qual_tbl(p).COMPARISON_OPERATOR_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_qual_tbl('|| p ||').VALIDATED_FLAG : '|| lx_req_qual_tbl(p).VALIDATED_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_qual_tbl('|| p ||').STATUS_CODE : '|| lx_req_qual_tbl(p).STATUS_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_qual_tbl('|| p ||').STATUS_TEXT : '|| lx_req_qual_tbl(p).STATUS_TEXT
                                );
                EXIT WHEN lx_req_qual_tbl.LAST = p;
                p := lx_req_qual_tbl.NEXT(p);
            END LOOP;
        END IF; -- lx_req_qual_tbl.COUNT > 0
    --
    -- Output Parameter 3: lx_req_line_attr_tbl
    --
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ****************** Output Parameter 3: lx_req_line_attr_tbl ************');
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_attr_tbl.COUNT '|| lx_req_qual_tbl.COUNT
                        );
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');
        IF lx_req_line_attr_tbl.COUNT > 0 THEN
            p := lx_req_line_attr_tbl.FIRST;
                LOOP
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ************* Parameter lx_req_line_attr_tbl('|| p ||') *************'
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_attr_tbl('|| p ||').LINE_INDEX : '|| lx_req_line_attr_tbl(p).LINE_INDEX
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_attr_tbl('|| p ||').PRICING_CONTEXT : '|| lx_req_line_attr_tbl(p).PRICING_CONTEXT
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_attr_tbl('|| p ||').PRICING_ATTRIBUTE : '|| lx_req_line_attr_tbl(p).PRICING_ATTRIBUTE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_attr_tbl('|| p ||').PRICING_ATTR_VALUE_FROM : '|| lx_req_line_attr_tbl(p).PRICING_ATTR_VALUE_FROM
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_attr_tbl('|| p ||').PRICING_ATTR_VALUE_TO : '|| lx_req_line_attr_tbl(p).PRICING_ATTR_VALUE_TO
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_attr_tbl('|| p ||').VALIDATED_FLAG : '|| lx_req_line_attr_tbl(p).VALIDATED_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_attr_tbl('|| p ||').STATUS_CODE : '|| lx_req_line_attr_tbl(p).STATUS_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_attr_tbl('|| p ||').STATUS_TEXT : '|| lx_req_line_attr_tbl(p).STATUS_TEXT
                                );
                EXIT WHEN lx_req_line_attr_tbl.LAST = p;
                p := lx_req_line_attr_tbl.NEXT(p);
            END LOOP;
        END IF; -- lx_req_line_attr_tbl.COUNT > 0

    --
    -- Output Parameter 4: lx_req_line_detail_tbl
    --
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ****************** Output Parameter 4: lx_req_line_detail_tbl ************');
            fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl.COUNT '|| lx_req_line_detail_tbl.COUNT
                        );
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');

        IF lx_req_line_detail_tbl.COUNT > 0 THEN
            p := lx_req_line_detail_tbl.FIRST;
                LOOP
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ************* Parameter lx_req_line_detail_tbl('|| p ||') *************'
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').LINE_DETAIL_INDEX : '|| lx_req_line_detail_tbl(p).LINE_DETAIL_INDEX
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').LINE_DETAIL_ID : '|| lx_req_line_detail_tbl(p).LINE_DETAIL_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').LINE_DETAIL_TYPE_CODE : '|| lx_req_line_detail_tbl(p).LINE_DETAIL_TYPE_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').LINE_INDEX : '|| lx_req_line_detail_tbl(p).LINE_INDEX
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').LIST_HEADER_ID : '|| lx_req_line_detail_tbl(p).LIST_HEADER_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').LIST_LINE_ID : '|| lx_req_line_detail_tbl(p).LIST_LINE_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').LIST_LINE_TYPE_CODE : '|| lx_req_line_detail_tbl(p).LIST_LINE_TYPE_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').SUBSTITUTION_TYPE_CODE : '|| lx_req_line_detail_tbl(p).SUBSTITUTION_TYPE_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').SUBSTITUTION_FROM : '|| lx_req_line_detail_tbl(p).SUBSTITUTION_FROM
                                );
                        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').SUBSTITUTION_TO : '|| lx_req_line_detail_tbl(p).SUBSTITUTION_TO
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').AUTOMATIC_FLAG : '|| lx_req_line_detail_tbl(p).AUTOMATIC_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').OPERAND_CALCULATION_CODE : '|| lx_req_line_detail_tbl(p).OPERAND_CALCULATION_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').OPERAND_VALUE : '|| lx_req_line_detail_tbl(p).OPERAND_VALUE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').PRICING_GROUP_SEQUENCE : '|| lx_req_line_detail_tbl(p).PRICING_GROUP_SEQUENCE
                                );
                        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').PRICE_BREAK_TYPE_CODE : '|| lx_req_line_detail_tbl(p).PRICE_BREAK_TYPE_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').CREATED_FROM_LIST_TYPE_CODE : '|| lx_req_line_detail_tbl(p).CREATED_FROM_LIST_TYPE_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').PRICING_PHASE_ID : '|| lx_req_line_detail_tbl(p).PRICING_PHASE_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').LIST_PRICE : '|| lx_req_line_detail_tbl(p).LIST_PRICE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').LINE_QUANTITY : '|| lx_req_line_detail_tbl(p).LINE_QUANTITY
                                );
                        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').ADJUSTMENT_AMOUNT : '|| lx_req_line_detail_tbl(p).ADJUSTMENT_AMOUNT
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').APPLIED_FLAG : '|| lx_req_line_detail_tbl(p).APPLIED_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').MODIFIER_LEVEL_CODE : '|| lx_req_line_detail_tbl(p).MODIFIER_LEVEL_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').STATUS_CODE : '|| lx_req_line_detail_tbl(p).STATUS_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').STATUS_TEXT : '|| lx_req_line_detail_tbl(p).STATUS_TEXT
                                );
                        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').SUBSTITUTION_ATTRIBUTE : '|| lx_req_line_detail_tbl(p).SUBSTITUTION_ATTRIBUTE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').ACCRUAL_FLAG : '|| lx_req_line_detail_tbl(p).ACCRUAL_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').LIST_LINE_NO : '|| lx_req_line_detail_tbl(p).LIST_LINE_NO
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').ESTIM_GL_VALUE : '|| lx_req_line_detail_tbl(p).ESTIM_GL_VALUE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').ACCRUAL_CONVERSION_RATE : '|| lx_req_line_detail_tbl(p).ACCRUAL_CONVERSION_RATE
                                );
                        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').OVERRIDE_FLAG : '|| lx_req_line_detail_tbl(p).OVERRIDE_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').PRINT_ON_INVOICE_FLAG : '|| lx_req_line_detail_tbl(p).PRINT_ON_INVOICE_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').INVENTORY_ITEM_ID : '|| lx_req_line_detail_tbl(p).INVENTORY_ITEM_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').ORGANIZATION_ID : '|| lx_req_line_detail_tbl(p).ORGANIZATION_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').RELATED_ITEM_ID : '|| lx_req_line_detail_tbl(p).RELATED_ITEM_ID
                                );
                        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').RELATIONSHIP_TYPE_ID : '|| lx_req_line_detail_tbl(p).RELATIONSHIP_TYPE_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').ESTIM_ACCRUAL_RATE : '|| lx_req_line_detail_tbl(p).ESTIM_ACCRUAL_RATE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').EXPIRATION_DATE : '|| lx_req_line_detail_tbl(p).EXPIRATION_DATE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').BENEFIT_PRICE_LIST_LINE_ID : '|| lx_req_line_detail_tbl(p).BENEFIT_PRICE_LIST_LINE_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').RECURRING_FLAG : '|| lx_req_line_detail_tbl(p).RECURRING_FLAG
                                );
                        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').RECURRING_VALUE : '|| lx_req_line_detail_tbl(p).RECURRING_VALUE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').BENEFIT_LIMIT : '|| lx_req_line_detail_tbl(p).BENEFIT_LIMIT
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').CHARGE_TYPE_CODE : '|| lx_req_line_detail_tbl(p).CHARGE_TYPE_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').CHARGE_SUBTYPE_CODE : '|| lx_req_line_detail_tbl(p).CHARGE_SUBTYPE_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').INCLUDE_ON_RETURNS_FLAG : '|| lx_req_line_detail_tbl(p).INCLUDE_ON_RETURNS_FLAG
                                );
                        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').BENEFIT_QTY : '|| lx_req_line_detail_tbl(p).BENEFIT_QTY
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').BENEFIT_UOM_CODE : '|| lx_req_line_detail_tbl(p).BENEFIT_UOM_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').PRORATION_TYPE_CODE : '|| lx_req_line_detail_tbl(p).PRORATION_TYPE_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').SOURCE_SYSTEM_CODE : '|| lx_req_line_detail_tbl(p).SOURCE_SYSTEM_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').REBATE_TRANSACTION_TYPE_CODE : '|| lx_req_line_detail_tbl(p).REBATE_TRANSACTION_TYPE_CODE
                                );
                        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').SECONDARY_PRICELIST_IND : '|| lx_req_line_detail_tbl(p).SECONDARY_PRICELIST_IND
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').GROUP_VALUE : '|| lx_req_line_detail_tbl(p).GROUP_VALUE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').COMMENTS : '|| lx_req_line_detail_tbl(p).COMMENTS
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').UPDATED_FLAG : '|| lx_req_line_detail_tbl(p).UPDATED_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').PROCESS_CODE : '|| lx_req_line_detail_tbl(p).PROCESS_CODE
                                );
                        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').LIMIT_CODE : '|| lx_req_line_detail_tbl(p).LIMIT_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').LIMIT_TEXT : '|| lx_req_line_detail_tbl(p).LIMIT_TEXT
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').FORMULA_ID : '|| lx_req_line_detail_tbl(p).FORMULA_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').CALCULATION_CODE : '|| lx_req_line_detail_tbl(p).CALCULATION_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').ROUNDING_FACTOR : '|| lx_req_line_detail_tbl(p).ROUNDING_FACTOR
                                );
                        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').currency_detail_id : '|| lx_req_line_detail_tbl(p).currency_detail_id
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').currency_header_id : '|| lx_req_line_detail_tbl(p).currency_header_id
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').selling_rounding_factor : '|| lx_req_line_detail_tbl(p).selling_rounding_factor
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').order_currency : '|| lx_req_line_detail_tbl(p).order_currency
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').pricing_effective_date : '|| lx_req_line_detail_tbl(p).pricing_effective_date
                                );
                        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').base_currency_code : '|| lx_req_line_detail_tbl(p).base_currency_code
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').change_reason_code : '|| lx_req_line_detail_tbl(p).change_reason_code
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').change_reason_text : '|| lx_req_line_detail_tbl(p).change_reason_text
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').break_uom_code : '|| lx_req_line_detail_tbl(p).break_uom_code
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').break_uom_context : '|| lx_req_line_detail_tbl(p).break_uom_context
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_tbl('|| p ||').break_uom_attribute : '|| lx_req_line_detail_tbl(p).break_uom_attribute
                                );
                EXIT WHEN lx_req_line_detail_tbl.LAST = p;
                p := lx_req_line_detail_tbl.NEXT(p);
            END LOOP;
        END IF; -- lx_req_line_detail_tbl.COUNT > 0

    --
    -- Output Parameter 5: lx_req_line_detail_qual_tbl
    --
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ***************** Output Parameter 5: lx_req_line_detail_qual_tbl ******************');
            fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_qual_tbl.COUNT '|| lx_req_line_detail_qual_tbl.COUNT
                        );
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');

        IF lx_req_line_detail_qual_tbl.COUNT > 0 THEN
            p := lx_req_line_detail_qual_tbl.FIRST;
                LOOP
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ************* Parameter lx_req_line_detail_qual_tbl('|| p ||') *************'
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_qual_tbl('|| p ||').LINE_DETAIL_INDEX : '|| lx_req_line_detail_qual_tbl(p).LINE_DETAIL_INDEX
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_qual_tbl('|| p ||').QUALIFIER_CONTEXT : '|| lx_req_line_detail_qual_tbl(p).QUALIFIER_CONTEXT
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_qual_tbl('|| p ||').QUALIFIER_ATTRIBUTE : '|| lx_req_line_detail_qual_tbl(p).QUALIFIER_ATTRIBUTE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_qual_tbl('|| p ||').QUALIFIER_ATTR_VALUE_FROM : '|| lx_req_line_detail_qual_tbl(p).QUALIFIER_ATTR_VALUE_FROM
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_qual_tbl('|| p ||').QUALIFIER_ATTR_VALUE_TO : '|| lx_req_line_detail_qual_tbl(p).QUALIFIER_ATTR_VALUE_TO
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_qual_tbl('|| p ||').COMPARISON_OPERATOR_CODE : '|| lx_req_line_detail_qual_tbl(p).COMPARISON_OPERATOR_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_qual_tbl('|| p ||').VALIDATED_FLAG : '|| lx_req_line_detail_qual_tbl(p).VALIDATED_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_qual_tbl('|| p ||').STATUS_CODE : '|| lx_req_line_detail_qual_tbl(p).STATUS_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_qual_tbl('|| p ||').STATUS_TEXT : '|| lx_req_line_detail_qual_tbl(p).STATUS_TEXT
                                );
                EXIT WHEN lx_req_line_detail_qual_tbl.LAST = p;
                p := lx_req_line_detail_qual_tbl.NEXT(p);
            END LOOP;
        END IF; -- lx_req_line_detail_qual_tbl.COUNT > 0
    --
    -- Output Parameter 6: lx_req_line_detail_attr_tbl
    --
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ***************** Output Parameter 6: lx_req_line_detail_attr_tbl ******************');
            fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_attr_tbl.COUNT '|| lx_req_line_detail_attr_tbl.COUNT
                        );
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');

        IF lx_req_line_detail_attr_tbl.COUNT > 0 THEN
            p := lx_req_line_detail_attr_tbl.FIRST;
                LOOP
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ************* Parameter lx_req_line_detail_attr_tbl('|| p ||') *************'
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_attr_tbl('|| p ||').LINE_DETAIL_INDEX : '|| lx_req_line_detail_attr_tbl(p).LINE_DETAIL_INDEX
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_attr_tbl('|| p ||').LINE_INDEX : '|| lx_req_line_detail_attr_tbl(p).LINE_INDEX
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_attr_tbl('|| p ||').PRICING_CONTEXT : '|| lx_req_line_detail_attr_tbl(p).PRICING_CONTEXT
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_attr_tbl('|| p ||').PRICING_ATTRIBUTE : '|| lx_req_line_detail_attr_tbl(p).PRICING_ATTRIBUTE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_attr_tbl('|| p ||').PRICING_ATTR_VALUE_FROM : '|| lx_req_line_detail_attr_tbl(p).PRICING_ATTR_VALUE_FROM
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_attr_tbl('|| p ||').PRICING_ATTR_VALUE_TO : '|| lx_req_line_detail_attr_tbl(p).PRICING_ATTR_VALUE_TO
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_attr_tbl('|| p ||').VALIDATED_FLAG : '|| lx_req_line_detail_attr_tbl(p).VALIDATED_FLAG
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_attr_tbl('|| p ||').STATUS_CODE : '|| lx_req_line_detail_attr_tbl(p).STATUS_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_line_detail_attr_tbl('|| p ||').STATUS_TEXT : '|| lx_req_line_detail_attr_tbl(p).STATUS_TEXT
                                );
                EXIT WHEN lx_req_line_detail_attr_tbl.LAST = p;
                p := lx_req_line_detail_attr_tbl.NEXT(p);
            END LOOP;
        END IF; -- lx_req_line_detail_attr_tbl.COUNT > 0

    --
    -- Output Parameter 7: lx_req_related_lines_tbl
    --
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ***************** Output Parameter 7: lx_req_related_lines_tbl ******************');
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_related_lines_tbl.COUNT '|| lx_req_related_lines_tbl.COUNT
                        );
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');

        IF lx_req_related_lines_tbl.COUNT > 0 THEN
            p := lx_req_related_lines_tbl.FIRST;
                LOOP
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ************* Parameter lx_req_related_lines_tbl('|| p ||') *************'
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_related_lines_tbl('|| p ||').LINE_INDEX : '|| lx_req_related_lines_tbl(p).LINE_INDEX
                                );
                 fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_related_lines_tbl('|| p ||').LINE_DETAIL_INDEX : '|| lx_req_related_lines_tbl(p).LINE_DETAIL_INDEX
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_related_lines_tbl('|| p ||').RELATIONSHIP_TYPE_CODE : '|| lx_req_related_lines_tbl(p).RELATIONSHIP_TYPE_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_related_lines_tbl('|| p ||').RELATED_LINE_INDEX : '|| lx_req_related_lines_tbl(p).RELATED_LINE_INDEX
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_related_lines_tbl('|| p ||').RELATED_LINE_DETAIL_INDEX : '|| lx_req_related_lines_tbl(p).RELATED_LINE_DETAIL_INDEX
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_related_lines_tbl('|| p ||').STATUS_CODE : '|| lx_req_related_lines_tbl(p).STATUS_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_req_related_lines_tbl('|| p ||').STATUS_TEXT : '|| lx_req_related_lines_tbl(p).STATUS_TEXT
                                );
                EXIT WHEN lx_req_related_lines_tbl.LAST = p;
                p := lx_req_related_lines_tbl.NEXT(p);
            END LOOP;
        END IF; -- lx_req_related_lines_tbl.COUNT > 0
    --
    -- Output Parameter 8: lx_return_status
    --
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ************* Parameter lx_return_status *************'
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_return_status '||lx_return_status
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');
    --
    -- Output Parameter 9: lx_return_status_text
    --
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ************* Parameter lx_return_status_text *************'
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: lx_return_status_text '||lx_return_status_text
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');

    END IF; -- SKEKKAR end Added debug statements to print all the parameters bug 5069673

      IF NVL (lx_return_status, 'S') <> 'S'
      THEN
         okc_api.set_message (g_app_name,
                              G_QP_ENGINE_ERROR,
                              'ERROR_MESSAGE',
                              lx_return_status_text
                             );
         RAISE fnd_api.g_exc_error;
      END IF;

--dbms_output.put_line ('*** AFTER QP CALL STATUS **** ' ||lx_return_status);
--dbms_output.put_line ('*** AFTER QP CALL STATUS TEXT **** ' ||lx_return_status_text);

      --**************************************************************************************************************

      --START BLIND (REQ_LINE_DETAIL_TBL) DISPLAY
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '20000:***********************OKS_QP_PKG BLING REQ_LINE_DETAIL TBL DISPLAY *********************'
            );
--dbms_output.put_line ('***********************OKS_QP_PKG BLING REQ_LINE_DETAIL TBL DISPLAY *********************');
         i                          := lx_req_line_detail_tbl.FIRST;

         IF i IS NOT NULL
         THEN
            LOOP
               fnd_log.STRING
                  (fnd_log.level_procedure,
                   g_module ||
                   l_api_name,
                   '20001:*************************************************************************'
                  );
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '20002:LIST/DISCOUNT Modifier L: ' ||
                               lx_req_line_detail_tbl (i).modifier_level_code
                              );
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '20003:LIST/DISCOUNT Line Index: ' ||
                               lx_req_line_detail_tbl (i).line_index
                              );
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '20004:LIST/DISCOUNT Line Detail Index: ' ||
                               lx_req_line_detail_tbl (i).line_detail_index
                              );
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '20005:LIST/DISCOUNT Line Detail Type:' ||
                               lx_req_line_detail_tbl (i).line_detail_type_code
                              );
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '20006:LIST/DISCOUNT List Header Id: ' ||
                               lx_req_line_detail_tbl (i).list_header_id
                              );
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '20007:LIST/DISCOUNT List Line Id: ' ||
                               lx_req_line_detail_tbl (i).list_line_id
                              );
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '20008:LIST/DISCOUNT List Line Type Code: ' ||
                               lx_req_line_detail_tbl (i).list_line_type_code
                              );
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '20009:LIST/DISCOUNT Adjustment Amount : ' ||
                               lx_req_line_detail_tbl (i).adjustment_amount
                              );
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '20010:LIST/DISCOUNT Line Quantity : ' ||
                               lx_req_line_detail_tbl (i).line_quantity
                              );
               fnd_log.STRING
                          (fnd_log.level_procedure,
                           g_module ||
                           l_api_name,
                           '20011:LIST/DISCOUNT Operand Calculation Code: ' ||
                           lx_req_line_detail_tbl (i).operand_calculation_code
                          );
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '20012:LIST/DISCOUNT Operand value: ' ||
                               lx_req_line_detail_tbl (i).operand_value
                              );
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '20013:LIST/DISCOUNT Applied   Flag: ' ||
                               lx_req_line_detail_tbl (i).applied_flag
                              );
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '20014:LIST/DISCOUNT Automatic Flag: ' ||
                               lx_req_line_detail_tbl (i).automatic_flag
                              );
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '20015:LIST/DISCOUNT Override Flag: ' ||
                               lx_req_line_detail_tbl (i).override_flag
                              );
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '20016:LIST/DISCOUNT Update   Flag: ' ||
                               lx_req_line_detail_tbl (i).modifier_level_code
                              );
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '20017:LIST/DISCOUNT status_code: ' ||
                               lx_req_line_detail_tbl (i).status_code
                              );
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '20018:LIST/DISCOUNT status text: ' ||
                               lx_req_line_detail_tbl (i).status_text
                              );
               fnd_log.STRING
                          (fnd_log.level_procedure,
                           g_module ||
                           l_api_name,
                           '20019:-------------------------------------------'
                          );
               fnd_log.STRING
                  (fnd_log.level_procedure,
                   g_module ||
                   l_api_name,
                   '20020:*************************************************************************'
                  );
               --dbms_output.put_line ('*************************************************************************');
               --dbms_output.put_line ('LIST/DISCOUNT Modifier L: '||lx_req_line_detail_tbl(I).modifier_level_code);
               --dbms_output.put_line ('LIST/DISCOUNT Line Index: '||lx_req_line_detail_tbl(I).line_index);
               --dbms_output.put_line ('LIST/DISCOUNT Line Detail Index: '||lx_req_line_detail_tbl(I).line_detail_index);
               --dbms_output.put_line ('LIST/DISCOUNT Line Detail Type:'||lx_req_line_detail_tbl(I).line_detail_type_code);
               --dbms_output.put_line ('LIST/DISCOUNT List Header Id: '||lx_req_line_detail_tbl(I).list_header_id);
               --dbms_output.put_line ('LIST/DISCOUNT List Line Id: '||lx_req_line_detail_tbl(I).list_line_id);
               --dbms_output.put_line ('LIST/DISCOUNT List Line Type Code: '||lx_req_line_detail_tbl(I).list_line_type_code);
               --dbms_output.put_line ('LIST/DISCOUNT Adjustment Amount : '||lx_req_line_detail_tbl(I).adjustment_amount);
               --dbms_output.put_line ('LIST/DISCOUNT Line Quantity : '||lx_req_line_detail_tbl(I).line_quantity);
               --dbms_output.put_line ('LIST/DISCOUNT Operand Calculation Code: '||lx_req_line_detail_tbl(I).Operand_calculation_code);
               --dbms_output.put_line ('LIST/DISCOUNT Operand value: '||lx_req_line_detail_tbl(I).operand_value);
               --dbms_output.put_line ('LIST/DISCOUNT Applied   Flag: '||lx_req_line_detail_tbl(I).applied_flag);
               --dbms_output.put_line ('LIST/DISCOUNT Automatic Flag: '||lx_req_line_detail_tbl(I).automatic_flag);
               --dbms_output.put_line ('LIST/DISCOUNT Override Flag: '||lx_req_line_detail_tbl(I).override_flag);
               --dbms_output.put_line ('LIST/DISCOUNT Update   Flag: '||lx_req_line_detail_tbl(I).modifier_level_code);
               --dbms_output.put_line ('LIST/DISCOUNT status_code: '||lx_req_line_detail_tbl(I).status_code);
               --dbms_output.put_line ('LIST/DISCOUNT status text: '||lx_req_line_detail_tbl(I).status_text);
               --dbms_output.put_line ('-------------------------------------------');
               --dbms_output.put_line ('*************************************************************************');
               EXIT WHEN i = lx_req_line_detail_tbl.LAST;
               i                          := lx_req_line_detail_tbl.NEXT (i);
            END LOOP;
         END IF;

         fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '20021:***********************OKS_QP_PKG BLING REQ_LINE_DETAIL TBL DISPLAY *********************'
            );
      END IF;

--dbms_output.put_line ('***********************OKS_QP_PKG BLING REQ_LINE_DETAIL TBL DISPLAY *********************');

      --END BLIND (REQ_LINE_DETAIL_TBL) DISPLAY

      --**************************************************************************************************************

      --**************************************************************************************************************
--APPLY MODIFIERS
      IF NOT NVL (p_detail_rec.intent, 'JA') IN ('HM', 'LM', 'SM')
      THEN                                      --Apply Modifiers Intent Check
         i                          := lx_req_line_detail_tbl.FIRST;

         IF i IS NOT NULL
         THEN
            LOOP
               IF lx_req_line_detail_tbl (i).applied_flag = 'Y'          AND
                  (lx_req_line_detail_tbl (i).list_line_type_code = 'DIS' OR
                   lx_req_line_detail_tbl (i).list_line_type_code = 'SUR'
                  )
               THEN
                  IF (lx_req_line_detail_tbl (i).line_index = 1 AND
                      l_hdrtop_rec.tl_line_style IN (12, 46)
                     )                                              OR
                     (lx_req_line_detail_tbl (i).line_index = 2 AND
                      l_hdrtop_rec.tl_line_style IN (1, 19)
                     )
--Or       (lx_req_line_detail_tbl(I).line_index          = 2 and l_hdrtop_rec.tl_line_style = 46 and
--          lx_req_line_detail_tbl(I).modifier_level_code = 'ORDER'                                    ) Or
--         (lx_req_line_detail_tbl(I).line_index          = 3 and l_hdrtop_rec.tl_line_style in (1,19) and
--          lx_req_line_detail_tbl(I).modifier_level_code = 'ORDER'                                    )
                  THEN
                     x_modifier_details (i)     := lx_req_line_detail_tbl (i);
                  END IF;                                   --line_style Check
               END IF;                                         --DIS/SUR check

               EXIT WHEN i = lx_req_line_detail_tbl.LAST;
               i                          := lx_req_line_detail_tbl.NEXT (i);
            END LOOP;
         END IF;                                         --End of I loop Check

         l_return_status            := NULL;

         IF l_hdrtop_rec.tl_line_style = 46
         THEN
            modifier_handling (p_cle_id                           => p_detail_rec.line_id,
                               p_modifier_details                 => x_modifier_details,
                               x_return_status                    => l_return_status
                              );

            IF l_return_status <> 'S'
            THEN
               okc_api.set_message (g_app_name,
                                    g_required_value,
                                    g_col_name_token,
                                    'Modifier Creation Error - Subscription '
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;
         ELSIF l_hdrtop_rec.tl_line_style = 12
         THEN
            modifier_4_usg (p_bsl_id                           => p_detail_rec.bsl_id,
                            p_modifier_details                 => x_modifier_details,
                            x_return_status                    => l_return_status
                           );

            IF l_return_status <> 'S'
            THEN
               okc_api.set_message (g_app_name,
                                    g_required_value,
                                    g_col_name_token,
                                    'Modifier Creation Error - Usage'
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;
         ELSIF l_hdrtop_rec.tl_line_style IN (1, 19)
         THEN
            modifier_handling (p_cle_id                           => p_detail_rec.subline_id,
                               p_modifier_details                 => x_modifier_details,
                               x_return_status                    => l_return_status
                              );

            IF l_return_status <> 'S'
            THEN
               okc_api.set_message
                               (g_app_name,
                                g_required_value,
                                g_col_name_token,
                                'Modifier Creation Error - Service/Warranty '
                               );
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      END IF;                                   --Apply Modifiers Intent Check

--APPLY MODIFIERS --END
--**************************************************************************************************************

      --**************************************************************************************************************
--Modifiers
-- below modifiers will be used to build the dynamic LOV in Adjustments form
-- HM : Header Adjustment, LM: Line Adjustment, SM : Subline Adjustment
-- At Header and Subline, override modifiers are Allowed, while at Line override modifier
-- are NOT allowed as Line Price is protected from update
-- Even for Sublines, intent will be SM BUT we look at the modifier at line_index = 2 i.e
-- modifier for service for product

      IF NVL (p_detail_rec.intent, 'JA') IN ('HM', 'LM', 'SM')
      THEN
         i                          := lx_req_line_detail_tbl.FIRST;

         IF i IS NOT NULL
         THEN
            LOOP
               IF (NVL (p_detail_rec.intent, 'JA') = 'HM'         OR
                   (lx_req_line_detail_tbl (i).line_index = 2 AND
                    l_hdrtop_rec.tl_line_style IN (1, 19)
                   )                                              OR
                   (lx_req_line_detail_tbl (i).line_index = 1 AND
                    l_hdrtop_rec.tl_line_style IN (12, 46)
                   )
                  )                                                   AND
                  lx_req_line_detail_tbl (i).list_line_type_code IN
                                                           ('DIS', 'SUR') AND
                  lx_req_line_detail_tbl (i).automatic_flag <> 'Y'
               THEN
                  IF NVL (p_detail_rec.intent, 'JA') = 'LM'
                  THEN
                    -- At Line Level, Only modifiers allowed are with override_flag as N
                     IF NVL (lx_req_line_detail_tbl (i).override_flag, 'N') =
                                                                          'N'
                     THEN
                        x_modifier_details (i)     :=
                                                   lx_req_line_detail_tbl (i);
                     ELSE
                        -- either HM or SM
                        IF l_hdrtop_rec.tl_line_style IN (46, 12)
                        THEN
                           x_modifier_details (i)     :=
                                                   lx_req_line_detail_tbl (i);
                        END IF;
                     END IF;
                  ELSE
                     x_modifier_details (i)     := lx_req_line_detail_tbl (i);
                  END IF;
               END IF;

               EXIT WHEN i = lx_req_line_detail_tbl.LAST;
               i                          := lx_req_line_detail_tbl.NEXT (i);
            END LOOP;
         END IF;
      END IF;

--End For ('HM','LM','SM') Check
--**************************************************************************************************************

      --**************************************************************************************************************
--Pricing Details
      i                          := lx_req_line_tbl.FIRST;

      IF i IS NOT NULL
      THEN
         LOOP
            IF MOD (i, 2) = 1 AND
               i IN (1, 2)
            THEN
               -- MOD (i, 2) = 1  means its Product Line or Usage / Subscription Line
               x_price_details.prod_qty   :=
                                            lx_req_line_tbl (i).line_quantity;
               x_price_details.prod_qty_uom :=
                                            lx_req_line_tbl (i).line_uom_code;
               x_price_details.prod_list_unit_price :=
                                   ROUND (lx_req_line_tbl (i).unit_price, 29);
               x_price_details.prod_adj_unit_price :=
                          ROUND (lx_req_line_tbl (i).adjusted_unit_price, 29);
               x_price_details.prod_ext_amount :=
                  ROUND (NVL (lx_req_line_tbl (i).adjusted_unit_price,
                              lx_req_line_tbl (i).unit_price) *
                         lx_req_line_tbl (i).priced_quantity,
                         29);

               IF x_price_details.prod_ext_amount IS NULL
               THEN
                  x_price_details.prod_ext_amount := 0;
               END IF;

               x_price_details.prod_priced_qty :=
                                           lx_req_line_tbl (i).priced_quantity;
               x_price_details.prod_priced_uom :=
                                           lx_req_line_tbl (i).priced_uom_code;

               IF l_hdrtop_rec.tl_line_style IN (1, 19)
               THEN
                  x_price_details.serv_qty   :=
                                        lx_req_line_tbl (i +
                                                         1).line_quantity;
                  x_price_details.serv_qty_uom :=
                                         lx_req_line_tbl (i +
                                                          1).line_uom_code;
                  x_price_details.serv_list_unit_price :=
                                ROUND (lx_req_line_tbl (i +
                                                        1).unit_price, 29);
                  x_price_details.serv_adj_unit_price :=
                       ROUND (lx_req_line_tbl (i +
                                               1).adjusted_unit_price, 29);
                  x_price_details.serv_priced_qty :=
                           ROUND (lx_req_line_tbl (i +
                                                   1).priced_quantity, 29);
                  x_price_details.serv_priced_uom :=
                                       lx_req_line_tbl (i +
                                                        1).priced_uom_code;
                  x_price_details.serv_ext_amount :=
                     ROUND (NVL (lx_req_line_tbl (i +
                                                  1).adjusted_unit_price,
                                 lx_req_line_tbl (i +
                                                  1).unit_price) *
                            lx_req_line_tbl (i).line_quantity *
                            lx_req_line_tbl (i +
                                             1).priced_quantity,
                            29);

                  IF x_price_details.serv_ext_amount IS NULL
                  THEN
                     x_price_details.serv_ext_amount := 0;
                  END IF;
               END IF;

               -- populate SL status text when error else TL status text
               IF lx_req_line_tbl (i).status_text IS NOT NULL
               THEN
                  x_price_details.status_code :=
                                              lx_req_line_tbl (i).status_code;
                  x_price_details.status_text :=
                                              lx_req_line_tbl (i).status_text;
               ELSIF l_hdrtop_rec.tl_line_style IN (1, 19)
               THEN
                  IF lx_req_line_tbl (i +
                                      1).status_text IS NOT NULL
                  THEN
                     x_price_details.status_code :=
                                          lx_req_line_tbl (i +
                                                           1).status_code;
                     x_price_details.status_text :=
                                           lx_req_line_tbl (i +
                                                            1).status_text;
                  END IF;
               END IF;

               -- Bug fix for 3641535. Depending on this status code, Authoring decides whether or not to call Pricebreaks form.
               IF NVL (x_price_details.status_code, qp_preq_grp.g_status_new) IN
                     (qp_preq_grp.g_status_updated,
                      qp_preq_grp.g_status_system_generated,
                      qp_preq_grp.g_by_engine,
                      qp_preq_grp.g_status_unchanged,
                      qp_preq_grp.g_status_new
                     )
               THEN
                  x_price_details.status_code := 'OKS_S';
               ELSE
                  x_price_details.status_code := 'OKS_E';
               END IF;

               i2                         := lx_req_line_detail_tbl.FIRST;

               IF i2 IS NOT NULL
               THEN
                  LOOP                                              --I2 LOOP
                     IF lx_req_line_detail_tbl (i2).line_index = i    AND
                        ((lx_req_line_detail_tbl (i2).list_line_type_code =
                                                                     'PLL'   AND
                          lx_req_line_detail_tbl (i2).applied_flag = 'Y'
                         )                                              OR
                         (lx_req_line_detail_tbl (i2).list_line_type_code =
                                                                     'PBH'   AND
                          lx_req_line_detail_tbl (i2).applied_flag = 'Y'
                         )
                        ) AND
                          lx_req_line_detail_tbl (i2).created_from_list_type_code IN ('PRL', 'AGR') --bug 5069673
                     THEN
                        x_price_details.prod_price_list_id :=
                                   lx_req_line_detail_tbl (i2).list_header_id;
                        x_price_details.prod_price_list_line_id :=
                                     lx_req_line_detail_tbl (i2).list_line_id;
                     ELSIF lx_req_line_detail_tbl (i2).line_index = i +
                                                                    1         AND
                           lx_req_line_detail_tbl (i2).list_line_type_code =
                                                                     'PLL'    AND
                           lx_req_line_detail_tbl (i2).applied_flag = 'Y'
                     THEN
                        x_price_details.serv_price_list_id :=
                                   lx_req_line_detail_tbl (i2).list_header_id;
                        x_price_details.serv_price_list_line_id :=
                                     lx_req_line_detail_tbl (i2).list_line_id;
                        x_price_details.serv_operand :=
                           ROUND (lx_req_line_detail_tbl (i2).operand_value,
                                  29);
                        x_price_details.serv_operator :=
                           lx_req_line_detail_tbl (i2).operand_calculation_code;
                     END IF;

                     EXIT WHEN i2 = lx_req_line_detail_tbl.LAST;
                     i2                         :=
                                              lx_req_line_detail_tbl.NEXT (i2);
                  END LOOP;                                     --I2 END LOOP;
               END IF;
            END IF;

            EXIT WHEN i = lx_req_line_tbl.LAST;
            i                          := lx_req_line_tbl.NEXT (i);
         END LOOP;
      END IF;

--Pricing Details
--**************************************************************************************************************
-- SKEKKAR
-- Added debug statements to print all the OUT parameter x_price_details
-- bug 5069673
--
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)   THEN
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ***************** OKS Price Calculations : x_price_details ******************');
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');

                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: x_price_details.PROD_QTY : '|| x_price_details.PROD_QTY
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: x_price_details.PROD_QTY_UOM : '|| x_price_details.PROD_QTY_UOM
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: x_price_details.SERV_QTY : '|| x_price_details.SERV_QTY
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: x_price_details.SERV_QTY_UOM : '|| x_price_details.SERV_QTY_UOM
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: x_price_details.PROD_PRICE_LIST_ID : '|| x_price_details.PROD_PRICE_LIST_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: x_price_details.SERV_PRICE_LIST_ID : '|| x_price_details.SERV_PRICE_LIST_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: x_price_details.PROD_PRICE_LIST_LINE_ID : '|| x_price_details.PROD_PRICE_LIST_LINE_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: x_price_details.SERV_PRICE_LIST_LINE_ID : '|| x_price_details.SERV_PRICE_LIST_LINE_ID
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: x_price_details.PROD_LIST_UNIT_PRICE : '|| x_price_details.PROD_LIST_UNIT_PRICE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: x_price_details.SERV_LIST_UNIT_PRICE : '|| x_price_details.SERV_LIST_UNIT_PRICE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: x_price_details.PROD_ADJ_UNIT_PRICE : '|| x_price_details.PROD_ADJ_UNIT_PRICE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: x_price_details.SERV_ADJ_UNIT_PRICE : '|| x_price_details.SERV_ADJ_UNIT_PRICE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: x_price_details.PROD_PRICED_QTY : '|| x_price_details.PROD_PRICED_QTY
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: x_price_details.PROD_PRICED_UOM : '|| x_price_details.PROD_PRICED_UOM
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: x_price_details.PROD_EXT_AMOUNT : '|| x_price_details.PROD_EXT_AMOUNT
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: x_price_details.SERV_PRICED_QTY : '|| x_price_details.SERV_PRICED_QTY
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: x_price_details.SERV_PRICED_UOM : '|| x_price_details.SERV_PRICED_UOM
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: x_price_details.SERV_EXT_AMOUNT : '|| x_price_details.SERV_EXT_AMOUNT
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: x_price_details.SERV_OPERAND : '|| x_price_details.SERV_OPERAND
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: x_price_details.SERV_OPERATOR : '|| x_price_details.SERV_OPERATOR
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: x_price_details.STATUS_CODE : '|| x_price_details.STATUS_CODE
                                );
                fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: x_price_details.STATUS_TEXT : '|| x_price_details.STATUS_TEXT
                                );

        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: ***************** END OKS Price Calculations : x_price_details ******************');
        fnd_log.STRING (fnd_log.level_statement, g_module || l_api_name,'QP_CALL: *********************************************************');

    END IF;-- end Added debug statements to print x_price_details bug 5069673

      --**************************************************************************************************************
--Price Breaks
      IF l_hdrtop_rec.tl_line_style IN (12, 46)
      THEN
         l_top_ctr                  := lx_req_related_lines_tbl.FIRST;

         IF l_top_ctr IS NOT NULL
         THEN
            LOOP
               IF lx_req_related_lines_tbl (l_top_ctr).relationship_type_code =
                                                       qp_preq_grp.g_pbh_line
               THEN
                  l_rel_index                :=
                     lx_req_related_lines_tbl (l_top_ctr).related_line_detail_index;
                  l_lin_index                :=
                       lx_req_related_lines_tbl (l_top_ctr).line_detail_index;
                  l_ctr                      :=
                                            lx_req_line_detail_attr_tbl.FIRST;

                  LOOP
                     IF lx_req_line_detail_attr_tbl (l_ctr).line_detail_index =
                                                                  l_rel_index
                     THEN
                        --MCHOUDHA Fix for BUG#5341559
                        --used fnd_number.canonical_to_number to convert the price break value_from
                        --into number format which is returned in canonical format by pricing engine
                        l_price_break_tbl (l_top_ctr).quantity_from :=
                           fnd_number.canonical_to_number(lx_req_line_detail_attr_tbl (l_ctr).pricing_attr_value_from);
                        l_price_break_tbl (l_top_ctr).quantity_to :=
                           fnd_number.canonical_to_number(lx_req_line_detail_attr_tbl (l_ctr).pricing_attr_value_to);
                     END IF;

                     EXIT WHEN l_ctr = lx_req_line_detail_attr_tbl.LAST;
                     l_ctr                      :=
                                      lx_req_line_detail_attr_tbl.NEXT (l_ctr);
                  END LOOP;

                  l_ctr                      := lx_req_line_detail_tbl.FIRST;

                  LOOP
                     IF lx_req_line_detail_tbl (l_ctr).line_detail_index =
                                                                  l_rel_index
                     THEN
                        -- skekkar forward port Bug 4534076 added 'AGR'
                        IF lx_req_line_detail_tbl (l_ctr).created_from_list_type_code IN
                                                              ('PRL', 'AGR')
                        THEN
                           -- end FP Bug 4534076
                           l_price_break_tbl (l_top_ctr).list_price :=
                                 lx_req_line_detail_tbl (l_ctr).operand_value;
                           l_price_break_tbl (l_top_ctr).break_method :=
                              lx_req_line_detail_tbl (l_ctr).price_break_type_code;

                           IF lx_req_line_detail_tbl (l_ctr).created_from_list_type_code =
                                                                        'PBH'
                           THEN
                              IF p_detail_rec.break_uom_code IS NULL
                              THEN
                                 l_price_break_tbl (l_top_ctr).break_uom_code :=
                                    lx_req_line_detail_tbl (l_ctr).break_uom_code;
                                 l_price_break_tbl (l_top_ctr).break_uom_context :=
                                    lx_req_line_detail_tbl (l_ctr).break_uom_context;
                                 l_price_break_tbl (l_top_ctr).break_uom_attribute :=
                                    lx_req_line_detail_tbl (l_ctr).break_uom_attribute;
                              ELSE
                                 l_price_break_tbl (l_top_ctr).break_uom_code :=
                                                  p_detail_rec.break_uom_code;
                                 l_price_break_tbl (l_top_ctr).break_uom_context :=
                                                                         NULL;
                                 l_price_break_tbl (l_top_ctr).break_uom_attribute :=
                                                                         NULL;
                              END IF;
                           END IF;

                           l_price_break_tbl (l_top_ctr).unit_price :=
                              NVL
                                 (lx_req_line_detail_tbl (l_ctr).adjustment_amount,
                                  lx_req_line_detail_tbl (l_ctr).list_price);
                           l_price_break_tbl (l_top_ctr).quantity :=
                                  lx_req_line_detail_tbl (l_ctr).line_quantity;
/*Added for bug:8884393*/ IF (lx_req_line_detail_tbl(l_ctr).OPERAND_CALCULATION_CODE='BLOCK_PRICE') AND (l_hdrtop_rec.tl_line_style = 12) THEN
                              l_price_break_tbl (l_top_ctr).amount :=
                              l_price_break_tbl (l_top_ctr).unit_price;
                          else
                               l_price_break_tbl (l_top_ctr).amount :=
                              l_price_break_tbl (l_top_ctr).unit_price *
                              l_price_break_tbl (l_top_ctr).quantity;
                          END IF;
                          /* l_price_break_tbl (l_top_ctr).amount :=
                              l_price_break_tbl (l_top_ctr).unit_price *
                              l_price_break_tbl (l_top_ctr).quantity;*/
                        ELSE
                           l_price_break_tbl.DELETE (l_top_ctr);
                        END IF;
                     END IF;

                     EXIT WHEN l_ctr = lx_req_line_detail_tbl.LAST;
                     l_ctr                      :=
                                           lx_req_line_detail_tbl.NEXT (l_ctr);
                  END LOOP;

--BREAK UOM
                  l_ctr                      := lx_req_line_detail_tbl.FIRST;

                  LOOP
                     IF lx_req_line_detail_tbl (l_ctr).line_detail_index =
                                                                  l_lin_index
                     THEN
                        -- skekkar forward port Bug 4534076 added 'AGR'
                        IF lx_req_line_detail_tbl (l_ctr).created_from_list_type_code IN
                                                              ('PRL', 'AGR')
                        THEN
                           -- end FP Bug 4534076
                           IF p_detail_rec.break_uom_code IS NOT NULL
                           THEN
                              l_price_break_tbl (l_top_ctr).break_uom_code :=
                                                  p_detail_rec.break_uom_code;
                              l_price_break_tbl (l_top_ctr).break_uom_context :=
                                                                         NULL;
                              l_price_break_tbl (l_top_ctr).break_uom_attribute :=
                                                                         NULL;
                           ELSE
                              l_price_break_tbl (l_top_ctr).break_uom_code :=
                                 lx_req_line_detail_tbl (l_ctr).break_uom_code;
                              l_price_break_tbl (l_top_ctr).break_uom_context :=
                                 lx_req_line_detail_tbl (l_ctr).break_uom_context;
                              l_price_break_tbl (l_top_ctr).break_uom_attribute :=
                                 lx_req_line_detail_tbl (l_ctr).break_uom_attribute;
                           END IF;
                        ELSE
                           l_price_break_tbl.DELETE (l_top_ctr);
                        END IF;
                     END IF;

                     EXIT WHEN l_ctr = lx_req_line_detail_tbl.LAST;
                     l_ctr                      :=
                                           lx_req_line_detail_tbl.NEXT (l_ctr);
                  END LOOP;
--END BREAK UOM
               END IF;

               EXIT WHEN l_top_ctr = lx_req_related_lines_tbl.LAST;
               l_top_ctr                  :=
                                     lx_req_related_lines_tbl.NEXT (l_top_ctr);
            END LOOP;

            x_price_break_details      := l_price_break_tbl;
         END IF;
      END IF;
--**************************************************************************************************************
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status            := okc_api.g_ret_sts_error;

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
      WHEN invalid_hdr_id_exception
      THEN
         okc_api.set_message (p_app_name                         => g_app_name,
                              p_msg_name                         => g_invalid_value,
                              p_token1                           => g_col_name_token,
                              p_token1_value                     => 'Header ID'
                             );

         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '6000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;
      WHEN OTHERS
      THEN
         x_return_status            := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );

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
   END;                                            --CALC_PRICE PROCEDURE ENDS

   PROCEDURE delete_locked_pricebreaks (
      p_api_version                   IN       NUMBER,
      p_list_line_id                  IN       NUMBER,
      p_init_msg_list                 IN       VARCHAR2,
      x_return_status                 IN OUT NOCOPY VARCHAR2,
      x_msg_count                     IN OUT NOCOPY NUMBER,
      x_msg_data                      IN OUT NOCOPY VARCHAR2
   )
   IS
      gpr_return_status                       VARCHAR2 (1) := NULL;
      gpr_msg_count                           NUMBER := 0;
      gpr_msg_data                            VARCHAR2 (2000);
      gpr_price_list_line_tbl                 qp_price_list_pub.price_list_line_tbl_type;
      gpr_price_list_line_val_tbl             qp_price_list_pub.price_list_line_val_tbl_type;
      ppr_price_list_rec                      qp_price_list_pub.price_list_rec_type;
      ppr_price_list_val_rec                  qp_price_list_pub.price_list_val_rec_type;
      ppr_price_list_line_tbl                 qp_price_list_pub.price_list_line_tbl_type;
      ppr_price_list_line_val_tbl             qp_price_list_pub.price_list_line_val_tbl_type;
      ppr_qualifiers_tbl                      qp_qualifier_rules_pub.qualifiers_tbl_type;
      ppr_qualifiers_val_tbl                  qp_qualifier_rules_pub.qualifiers_val_tbl_type;
      ppr_pricing_attr_tbl                    qp_price_list_pub.pricing_attr_tbl_type;
      ppr_pricing_attr_val_tbl                qp_price_list_pub.pricing_attr_val_tbl_type;
      k                                       NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2 (30)
                                               := 'Delete_locked_pricebreaks';
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

       /* Populate the list_line_id (PK) of the price list line whose list_price
      is to be updated, the operation and the columns to be updated with the
      new values. All other values are not required to be populated.*/
      k                          := 1;
      gpr_price_list_line_tbl (k).list_line_id := p_list_line_id;
      -- Corresponds to a the item 'dw01' on Price List 'Testing 1023'
      gpr_price_list_line_tbl (k).operation := qp_globals.g_opr_delete;
      gpr_price_list_line_tbl (k).operand := 25;

      -- The operand column corresponds to the listprice on a pricelist line.
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '21000:before process price list '
                        );
      END IF;

      --dbms_output.put_line('before process price list ');
      qp_price_list_pub.process_price_list
                    (p_api_version_number               => 1,
                     p_init_msg_list                    => fnd_api.g_false,
                     p_return_values                    => fnd_api.g_false,
                     p_commit                           => fnd_api.g_false,
                     x_return_status                    => gpr_return_status,
                     x_msg_count                        => gpr_msg_count,
                     x_msg_data                         => gpr_msg_data,
                     p_price_list_line_tbl              => gpr_price_list_line_tbl,
                     x_price_list_rec                   => ppr_price_list_rec,
                     x_price_list_val_rec               => ppr_price_list_val_rec,
                     x_price_list_line_tbl              => ppr_price_list_line_tbl,
                     x_price_list_line_val_tbl          => ppr_price_list_line_val_tbl,
                     x_qualifiers_tbl                   => ppr_qualifiers_tbl,
                     x_qualifiers_val_tbl               => ppr_qualifiers_val_tbl,
                     x_pricing_attr_tbl                 => ppr_pricing_attr_tbl,
                     x_pricing_attr_val_tbl             => ppr_pricing_attr_val_tbl
                    );

      IF gpr_return_status <> fnd_api.g_ret_sts_success
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      ELSE
         x_return_status            := gpr_return_status;
      END IF;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '21001:after process price list '
                        );
      END IF;
   --dbms_output.put_line('after process price list ');
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         gpr_return_status          := fnd_api.g_ret_sts_error;

         --  Get message count and data
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '22001:err msg 1 is : ' ||
                            gpr_msg_data
                           );
         END IF;

         --dbms_output.put_line('err msg 1 is : ' || gpr_msg_data);

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
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         gpr_return_status          := fnd_api.g_ret_sts_unexp_error;

         --dbms_output.put_line(' msg count 2 is : ' || gpr_msg_count);

         /*   for k in 1 .. gpr_msg_count loop
            gpr_msg_data := oe_msg_pub.get( p_msg_index => k,
                p_encoded => 'F'
                      );
                   oe_msg_pub.Count_And_Get
             (   p_count                       => gpr_msg_count
             ,   p_data                        => gpr_msg_data
             );

                --  Get message count and data
                --dbms_output.put_line('err msg ' || k ||'is:  ' || gpr_msg_data);
                  null;
            end loop; */

         -- end debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '3000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;
      WHEN OTHERS
      THEN
         gpr_return_status          := fnd_api.g_ret_sts_unexp_error;

               --  Get message count and data
               --dbms_output.put_line('err msg 3 is : ' || gpr_msg_data);
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
   END;
END oks_qp_pkg;

/
