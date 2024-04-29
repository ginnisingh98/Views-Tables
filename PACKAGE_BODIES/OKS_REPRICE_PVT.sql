--------------------------------------------------------
--  DDL for Package Body OKS_REPRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_REPRICE_PVT" AS
  /* $Header: OKSRRPRB.pls 120.31.12000000.4 2007/06/06 17:19:55 skekkar ship $*/

  ------------------------------------------------------------------------------
-- GLOBAL CONSTANTS
------------------------------------------------------------------------------
  g_module                       CONSTANT VARCHAR2 (250)
                                 := 'oks.plsql.pricing.' ||
                                    g_pkg_name ||
                                    '.';

     -- 08/05/2005 -- JVORUGAN R12 Partial Period Project
  -- This procedure will update Price UOM at line and subline levels when the
  -- Renewal Pricing type is Price List and Period Type and Period Start are not null
  -- for the contract.
  PROCEDURE update_price_uom (
    p_chr_id                         IN       NUMBER,
    p_price_uom                      IN       VARCHAR2,  -- Bug 5139658
    x_return_status                  OUT NOCOPY VARCHAR2
  ) IS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                                        := 'update_price_uom';
    l_kln_rec_in                            oks_contract_line_pub.klnv_rec_type;
    l_kln_rec_out                           oks_contract_line_pub.klnv_rec_type;
    l_k_det_rec                             oks_qp_int_pvt.k_details_rec;
    l_return_status                         VARCHAR2 (1)
                                                 := okc_api.g_ret_sts_success;
    l_msg_count                             NUMBER;
    l_msg_data                              VARCHAR2 (2000);
    l_price_uom                             oks_k_headers_b.price_uom%TYPE;
    invalid_uom_exception                   EXCEPTION;

    CURSOR cur_get_lines IS
      SELECT oks.ID,
             oks.cle_id,
             oks.object_version_number                          -- bug 4638902
        FROM okc_k_lines_b okc,
             oks_k_lines_b oks
       WHERE okc.dnz_chr_id = p_chr_id
         AND okc.lse_id IN (1, 7, 9, 25, 19)
         AND okc.ID = oks.cle_id;

    CURSOR cur_hdr_uom IS
      SELECT price_uom
        FROM oks_k_headers_b
       WHERE chr_id = p_chr_id;
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

-- Bug 5139658

/*
    OPEN cur_hdr_uom;

    FETCH cur_hdr_uom
     INTO l_price_uom;

    IF cur_hdr_uom%NOTFOUND THEN
      CLOSE cur_hdr_uom;

      RAISE invalid_uom_exception;
    END IF;

    CLOSE cur_hdr_uom;

*/

    FOR cur_rec IN cur_get_lines LOOP
      l_kln_rec_in.ID            := cur_rec.ID;
      l_kln_rec_in.cle_id        := cur_rec.cle_id;
      l_kln_rec_in.dnz_chr_id    := p_chr_id;

      l_kln_rec_in.price_uom     := p_price_uom;  -- Bug 5139658
      -- bug 4638902
      l_kln_rec_in.object_version_number := cur_rec.object_version_number;
      -- bug 4638902
      oks_contract_line_pub.update_line (p_api_version                     => 1.0,
                                         p_init_msg_list                   => 'T',
                                         x_return_status                   => l_return_status,
                                         x_msg_count                       => l_msg_count,
                                         x_msg_data                        => l_msg_data,
                                         p_klnv_rec                        => l_kln_rec_in,
                                         x_klnv_rec                        => l_kln_rec_out,
                                         p_validate_yn                     => 'N'
                                        );

      IF l_return_status <> okc_api.g_ret_sts_success THEN
        RAISE g_error;
      END IF;
    END LOOP;

    x_return_status            := l_return_status;

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
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
    WHEN invalid_uom_exception THEN
      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '9500: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      x_return_status            := g_ret_sts_unexp_error;
      OKC_API.SET_MESSAGE(p_app_name    => 'OKS',
                         p_msg_name     => 'OKS_INVD_UOM_CODE',
                         p_token1       => 'OKS_API_NAME',
                         p_token1_value => 'oks_reprice_pvt.update_price_uom',
                         p_token2       => 'UOM_CODE',
                         p_token2_value => p_price_uom);
    WHEN OTHERS THEN
      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
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
      okc_api.set_message (p_app_name                        => g_app_name_oks,
                           p_msg_name                        => g_unexpected_error,
                           p_token1                          => g_sqlcode_token,
                           p_token1_value                    => SQLCODE,
                           p_token2                          => g_sqlerrm_token,
                           p_token2_value                    => SQLERRM
                          );
  END update_price_uom;

  FUNCTION do_prorating (
    p_old_start_date                 IN       DATE,
    p_old_end_date                   IN       DATE,
    p_new_start_date                 IN       DATE,
    p_new_end_date                   IN       DATE,
    p_amount                         IN       NUMBER
  )
    RETURN NUMBER IS
    l_api_name                     CONSTANT VARCHAR2 (30) := 'do_prorating';
    l_old_duration                          NUMBER;
    l_new_duration                          NUMBER;
    l_prorated_amount                       NUMBER;
    l_duration                              NUMBER;
    l_period                                VARCHAR2 (10);
    l_return_status                         VARCHAR2 (1);
    l_old_start_date                        DATE;
    l_old_end_date                          DATE;
    l_new_start_date                        DATE;
    l_new_end_date                          DATE;

    CURSOR l_time_csr (
      l_uom_code                                VARCHAR2
    ) IS
      SELECT tce_code
        FROM okc_time_code_units_v
       WHERE uom_code = l_uom_code
         AND quantity = 1;

    CURSOR l_time_csr_noqty (
      l_uom_code                                VARCHAR2
    ) IS
      SELECT tce_code
        FROM okc_time_code_units_v
       WHERE uom_code = l_uom_code;

    l_old_tce_code                          VARCHAR2 (25);
    l_new_tce_code                          VARCHAR2 (25);
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    --------- Truncation of start date and end date added for bug # 2660399 ------
    l_old_start_date           := TRUNC (p_old_start_date);
    l_old_end_date             := TRUNC (p_old_end_date);
    l_new_start_date           := TRUNC (p_new_start_date);
    l_new_end_date             := TRUNC (p_new_end_date);
    --------------- End truncation ------------------------------------------
   -- bug 4919612  SKEKKAR
   -- okc_time_util_pub.get_duration (p_start_date                      => l_old_start_date,
    okc_time_util_pvt.get_pricing_duration (p_start_date              => l_old_start_date,
                                    p_end_date                        => l_old_end_date,
                                    x_duration                        => l_old_duration, -- bug 4895901
                                    x_timeunit                        => l_old_tce_code, -- bug 5230438
                                    x_return_status                   => l_return_status
                                   );

/*   bug 5230438
    OPEN l_time_csr (l_period);
    FETCH l_time_csr
     INTO l_old_tce_code;
    CLOSE l_time_csr;
*/

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '100:Old Tce Code: ' ||
                      l_old_tce_code
                     );
    END IF;

    ------------errorout_ad('Old Tce Code: ' || l_old_tce_Code);
    -- bug 4919612  SKEKKAR
    -- okc_time_util_pub.get_duration (p_start_date                      => l_new_start_date,
    okc_time_util_pvt.get_pricing_duration (p_start_date              => l_new_start_date,
                                    p_end_date                        => l_new_end_date,
                                    x_duration                        => l_new_duration, -- bug 4895901
                                    x_timeunit                        => l_new_tce_code,  --bug 5230438
                                    x_return_status                   => l_return_status
                                   );

/* bug 5230438
    OPEN l_time_csr (l_period);
    FETCH l_time_csr
     INTO l_new_tce_code;
    IF l_time_csr%NOTFOUND THEN
      OPEN l_time_csr_noqty (l_period);
      FETCH l_time_csr_noqty
       INTO l_new_tce_code;
      CLOSE l_time_csr_noqty;
    END IF;
    CLOSE l_time_csr;
*/

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '101:New Tce Code: ' ||
                      l_new_tce_code
                     );
    END IF;

    ------------errorout_ad('New Tce Code: ' || l_new_tce_Code);
    IF     l_old_tce_code = 'YEAR'
       AND l_new_tce_code = 'YEAR' THEN
       -- bug 4895901 skekkar
       l_old_duration := l_old_duration * 12;
       l_new_duration := l_new_duration * 12;
           /*
      l_old_duration             :=
                TRUNC (MONTHS_BETWEEN (l_old_end_date +
                                       1, l_old_start_date));
      l_new_duration             :=
                 TRUNC (MONTHS_BETWEEN (l_new_end_date +
                                        1, l_new_start_date));
                                        */
    ELSIF     l_old_tce_code = 'MONTH'
          AND l_new_tce_code = 'MONTH' THEN
       -- bug 4895901 skekkar
        null;
                /*
      l_old_duration             :=
                TRUNC (MONTHS_BETWEEN (l_old_end_date +
                                       1, l_old_start_date));
      l_new_duration             :=
                 TRUNC (MONTHS_BETWEEN (l_new_end_date +
                                        1, l_new_start_date));
                                        */
    ELSIF     l_old_tce_code = 'MONTH'
          AND l_new_tce_code = 'YEAR' THEN
       -- bug 4895901 skekkar
       l_new_duration :=  l_new_duration * 12;
           /*
      l_old_duration             :=
                TRUNC (MONTHS_BETWEEN (l_old_end_date +
                                       1, l_old_start_date));
      l_new_duration             :=
                 TRUNC (MONTHS_BETWEEN (l_new_end_date +
                                        1, l_new_start_date));
                                        */
    ELSIF     l_old_tce_code = 'YEAR'
          AND l_new_tce_code = 'MONTH' THEN
       -- bug 4895901 skekkar
       l_old_duration := l_old_duration * 12;
           /*
      l_old_duration             :=
                TRUNC (MONTHS_BETWEEN (l_old_end_date +
                                       1, l_old_start_date));
      l_new_duration             :=
                 TRUNC (MONTHS_BETWEEN (l_new_end_date +
                                        1, l_new_start_date));
                                        */
    ELSE
      l_old_duration             := l_old_end_date -
                                    l_old_start_date +
                                    1;
      l_new_duration             := l_new_end_date -
                                    l_new_start_date +
                                    1;
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '102:Amount: ' ||
                      p_amount
                     );
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '103:Old Duration: ' ||
                      l_old_duration
                     );
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '104:New Duration: ' ||
                      l_new_duration
                     );
    END IF;

    ------------errorout_ad('Amount: ' || p_amount);
    ------------errorout_ad('Old Duration: ' || l_old_duration);
    ------------errorout_ad('New Duration: ' || l_new_duration);
    l_prorated_amount          :=
                (l_new_duration *
                 NVL (p_amount, 0)) /
                NVL (l_old_duration, 1);

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '105:Prorated Amount' ||
                      l_prorated_amount
                     );
    END IF;

    ------------errorout_ad('Prorated Amount' || l_prorated_amount);

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '1000: Leaving ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    RETURN (l_prorated_amount);
  END do_prorating;

  -- Added by JVORUGAN
  -- In Do_Prorating_pp Proration is done based on  new partial period logic
  FUNCTION do_prorating_pp (
    p_id                             IN       NUMBER DEFAULT NULL,
    p_lse_id                         IN       NUMBER DEFAULT NULL,
    p_unit_price                     IN       NUMBER DEFAULT NULL,
    p_old_start_date                 IN       DATE,
    p_old_end_date                   IN       DATE,
    p_new_start_date                 IN       DATE,
    p_new_end_date                   IN       DATE,
    p_amount                         IN       NUMBER,
    p_period_type                    IN       VARCHAR2,
    p_period_start                   IN       VARCHAR2
  )
    RETURN NUMBER IS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                                         := 'do_prorating_pp';

    CURSOR l_oks_elements (p_line_id   NUMBER) IS
     SELECT itm.number_of_items,kln.toplvl_uom_code,lin.date_terminated
        FROM oks_k_lines_b kln,
             okc_k_items itm,
             okc_k_lines_b lin
       WHERE kln.cle_id = p_line_id
       and   itm.cle_id = kln.cle_id
       and   lin.id = p_line_id;

    Cursor check_sub_instance IS
    select 'Y'
    from   okc_k_items itm,
           oks_subscr_header_b sub
    where  itm.cle_id = p_id
    and    sub.instance_id = itm.object1_id1;

      CURSOR get_orig_system_id1 IS
      SELECT orig_system_id1
        FROM okc_k_lines_b
       WHERE ID = p_id;

    l_oks_elements_rec                      l_oks_elements%ROWTYPE;
    l_old_duration                          NUMBER;
    l_new_duration                          NUMBER;
    l_prorated_amount                       NUMBER;
    l_period                                VARCHAR2 (30);
    l_return_status                         VARCHAR2 (1);
    l_old_start_date                        DATE;
    l_old_end_date                          DATE;
    l_new_start_date                        DATE;
    l_new_end_date                          DATE;
    l_quantity                              NUMBER;
    l_unit_price                            NUMBER;
    l_sub_instance_check                    VARCHAR2(1);
    l_orig_system_id                        NUMBER;

  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    --------- Truncation of start date and end date ------
    l_old_start_date           := TRUNC (p_old_start_date);
    l_old_end_date             := TRUNC (p_old_end_date);
    l_new_start_date           := TRUNC (p_new_start_date);
    l_new_end_date             := TRUNC (p_new_end_date);
    --------------- End truncation -----------------------
    okc_time_util_pub.get_duration (p_start_date                      => l_old_start_date,
                                    p_end_date                        => l_old_end_date,
                                    x_duration                        => l_old_duration,
                                    x_timeunit                        => l_period,
                                    x_return_status                   => l_return_status
                                   );

   l_sub_instance_check := NULL;
   --subscription instance can only be attached as service product/Exntended warranty product
   IF p_lse_id in (9,25) THEN
    Open check_sub_instance;
    Fetch check_sub_instance into l_sub_instance_check;
    Close check_sub_instance;
   END IF;

   IF p_lse_id in (7,9,25) AND (nvl(l_sub_instance_check,'X') <> 'Y') THEN
              open l_oks_elements(p_id);
              fetch l_oks_elements into l_oks_elements_rec;
              close l_oks_elements;
              okc_time_util_pub.get_duration (p_start_date                      => l_new_start_date,
                                              p_end_date                        => l_new_end_date,
                                              x_duration                        => l_new_duration,
                                              x_timeunit                        => l_period,
                                              x_return_status                   => l_return_status
                                             );
              l_new_duration :=
                            oks_time_measures_pub.get_quantity (p_start_date => l_new_start_date,
                                          p_end_date                        => l_new_end_date,
					  ----Fix for bug#5623498 added duration based uom in the nvl condition
                                          p_source_uom                      => nvl(l_oks_elements_rec.toplvl_uom_code,l_period),
                                          p_period_type                     => p_period_type,
                                          p_period_start                    => p_period_start
                                         );
          --    IF p_lse_id in (7,9) THEN
          --      l_unit_price := p_unit_price;
          --    ELSE
                     l_quantity := OKS_TIME_MEASURES_PUB.get_quantity
                       (p_start_date   => l_old_start_date,
                        p_end_date     => nvl(l_oks_elements_rec.date_terminated-1,l_old_end_date),
    		        ----Fix for bug#5623498 added duration based uom in the nvl condition
                        p_source_uom   => nvl(l_oks_elements_rec.toplvl_uom_code,l_period),
                        p_period_type  => p_period_type,
                        p_period_start => p_period_start);
                   l_unit_price := p_amount / l_quantity;
          --   END IF;
              l_prorated_amount :=(l_unit_price)*l_new_duration; --(l_unit_price)*l_oks_elements_rec.number_of_items*l_new_duration;  --Bug 5337890
   ELSIF p_lse_id =46 THEN
                        Open get_orig_system_id1;
			Fetch get_orig_system_id1 into l_orig_system_id;
			Close get_orig_system_id1;
                        oks_subscription_pub.get_subs_qty
                                          (p_cle_id                           => l_orig_system_id,
                                           x_return_status                    => l_return_status,
                                           x_quantity                         => l_quantity,
                                           x_uom_code                         => l_period
                                          );
                       l_unit_price := p_amount / l_quantity;
                        oks_subscription_pub.get_subs_qty
                                          (p_cle_id                           => p_id,
                                           x_return_status                    => l_return_status,
                                           x_quantity                         => l_quantity,
                                           x_uom_code                         => l_period
                                          );
		       l_prorated_amount := l_unit_price*l_quantity;
   ELSE

    l_new_duration             :=
      oks_time_measures_pub.get_quantity (p_start_date                      => l_new_start_date,
                                          p_end_date                        => l_new_end_date,
                                          p_source_uom                      => l_period,
                                          p_period_type                     => p_period_type,
                                          p_period_start                    => p_period_start
                                         );
    l_prorated_amount          :=
                (l_new_duration *
                 NVL (p_amount, 0)) /
                NVL (l_old_duration, 1);
    END IF;
    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '1000: Leaving ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    RETURN (l_prorated_amount);
  END do_prorating_pp;

  PROCEDURE get_oldcontractline_dates (
    p_cle_id                         IN       NUMBER,
    p_opn_code                       IN       VARCHAR2,
    x_old_start_date                 OUT NOCOPY DATE,
    x_old_end_date                   OUT NOCOPY DATE
  ) IS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                               := 'get_oldcontractline_dates';

    CURSOR l_olddates_csr IS
      SELECT start_date,
             end_date
        FROM okc_k_lines_b
       WHERE ID =
               (SELECT ool.object_cle_id
                  FROM okc_operation_lines ool,
                       okc_operation_instances oie,
                       okc_class_operations cop
                 WHERE cop.ID = oie.cop_id
                   AND cop.opn_code = p_opn_code
                   AND oie.ID = ool.oie_id
                   AND ool.subject_cle_id = p_cle_id
                   AND ROWNUM < 2);
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    OPEN l_olddates_csr;

    FETCH l_olddates_csr
     INTO x_old_start_date,
          x_old_end_date;

    CLOSE l_olddates_csr;

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '1000: Leaving ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;
  END get_oldcontractline_dates;

  PROCEDURE update_header (
    p_chrv_rec                       IN       okc_contract_pub.chrv_rec_type,
    x_return_status                  OUT NOCOPY VARCHAR2
  ) IS
    l_api_name                     CONSTANT VARCHAR2 (30) := 'update_header';
    l_chrv_rec                              okc_contract_pub.chrv_rec_type
                                                                := p_chrv_rec;
    x_chrv_rec                              okc_contract_pub.chrv_rec_type;
    l_api_version                           NUMBER := 1.0;
    l_init_msg_list                         VARCHAR2 (1) := okc_api.g_false;
    l_return_status                         VARCHAR2 (1)
                                                 := okc_api.g_ret_sts_success;
    l_msg_count                             NUMBER;
    l_msg_data                              VARCHAR2 (2000);
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    okc_contract_pub.update_contract_header
                                          (p_api_version                     => l_api_version,
                                           p_init_msg_list                   => l_init_msg_list,
                                           x_return_status                   => l_return_status,
                                           x_msg_count                       => l_msg_count,
                                           x_msg_data                        => l_msg_data,
                                           p_restricted_update               => 'F',
                                           p_chrv_rec                        => l_chrv_rec,
                                           x_chrv_rec                        => x_chrv_rec
                                          );

    IF l_return_status <> g_ret_sts_success THEN
      RAISE g_error;
    END IF;

    x_return_status            := l_return_status;

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
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
    WHEN g_error THEN
      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '2500: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      x_return_status            := l_return_status;
    WHEN OTHERS THEN
      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
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
      okc_api.set_message (p_app_name                        => g_app_name_oks,
                           p_msg_name                        => g_unexpected_error,
                           p_token1                          => g_sqlcode_token,
                           p_token1_value                    => SQLCODE,
                           p_token2                          => g_sqlerrm_token,
                           p_token2_value                    => SQLERRM
                          );
  END update_header;

  PROCEDURE update_line (
    p_clev_rec                       IN       okc_contract_pub.clev_rec_type,
    x_return_status                  OUT NOCOPY VARCHAR2
  ) IS
    l_api_name                     CONSTANT VARCHAR2 (30) := 'update_line';
    l_clev_rec                              okc_contract_pub.clev_rec_type
                                                                := p_clev_rec;
    x_clev_rec                              okc_contract_pub.clev_rec_type;
    l_api_version                           NUMBER := 1.0;
    l_init_msg_list                         VARCHAR2 (1) := okc_api.g_false;
    l_return_status                         VARCHAR2 (1)
                                                 := okc_api.g_ret_sts_success;
    l_msg_count                             NUMBER;
    l_msg_data                              VARCHAR2 (2000);
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    okc_contract_pub.update_contract_line (p_api_version                     => l_api_version,
                                           p_init_msg_list                   => l_init_msg_list,
                                           x_return_status                   => l_return_status,
                                           x_msg_count                       => l_msg_count,
                                           x_msg_data                        => l_msg_data,
                                           p_restricted_update               => 'F',
                                           p_clev_rec                        => l_clev_rec,
                                           x_clev_rec                        => x_clev_rec
                                          );

    IF l_return_status = g_ret_sts_success THEN
      RAISE g_error;
    END IF;

    x_return_status            := l_return_status;

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
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
    WHEN g_error THEN
      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '2500: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      x_return_status            := l_return_status;
    WHEN OTHERS THEN
      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
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
      okc_api.set_message (p_app_name                        => g_app_name_oks,
                           p_msg_name                        => g_unexpected_error,
                           p_token1                          => g_sqlcode_token,
                           p_token1_value                    => SQLCODE,
                           p_token2                          => g_sqlerrm_token,
                           p_token2_value                    => SQLERRM
                          );
  END update_line;

  PROCEDURE update_amounts (
    p_chr_id                         IN       NUMBER,
    x_return_status                  OUT NOCOPY VARCHAR2
  ) IS
    l_api_name                     CONSTANT VARCHAR2 (30) := 'update_amounts';

    CURSOR l_topline_csr IS
      SELECT ID
        FROM okc_k_lines_b
       WHERE dnz_chr_id = p_chr_id
         AND cle_id IS NULL
         AND lse_id IN (1, 12, 19);

    CURSOR l_sublineamt_csr (
      c_cle_id                         IN       NUMBER
    ) IS
      SELECT SUM (NVL (price_negotiated, 0)) topline_amt
        FROM okc_k_lines_b
       WHERE dnz_chr_id = p_chr_id
         AND cle_id = c_cle_id
         AND lse_id IN (7, 8, 9, 10, 11, 18, 25, 35) -- added skekkar
         AND date_cancelled IS NULL;  -- added skekkar

    CURSOR l_toplineamt_csr IS
      SELECT SUM (NVL (price_negotiated, 0)) header_amt
        FROM okc_k_lines_b
       WHERE dnz_chr_id = p_chr_id
         AND cle_id IS NULL
         AND lse_id IN (1, 12, 19, 46)
         AND date_cancelled IS NULL;  -- added skekkar

    -- added skekkar to update tax amount for top lines
    CURSOR l_sublinetax_csr (
      c_cle_id                         IN       NUMBER
    ) IS
      SELECT SUM (NVL (tax_amount, 0)) topline_tax
        FROM oks_k_lines_b
       WHERE dnz_chr_id = p_chr_id
         AND cle_id IN (  SELECT id
                            FROM okc_k_lines_b
                           WHERE dnz_chr_id = p_chr_id
                             AND cle_id = c_cle_id
                             AND lse_id IN (7, 8, 9, 10, 11, 18, 25, 35)
                             AND date_cancelled IS NULL
                       );

    -- added skekkar to update tax amount for header
    CURSOR l_toplinetax_csr IS
      SELECT SUM (NVL (tax_amount, 0)) header_tax
        FROM oks_k_lines_b
       WHERE dnz_chr_id = p_chr_id
         AND cle_id IN ( SELECT id
                           FROM okc_k_lines_b
                          WHERE dnz_chr_id = p_chr_id
                            AND cle_id IS NULL
                            AND lse_id IN (1, 12, 19, 46)
                            AND date_cancelled IS NULL
                       );

    l_line_id                               NUMBER;
    l_tot_subline_amt                       NUMBER;
    l_tot_topline_amt                       NUMBER;
    l_chrv_rec                              okc_contract_pub.chrv_rec_type;
    l_clev_rec                              okc_contract_pub.clev_rec_type;
    l_return_status                         VARCHAR2 (1) := g_ret_sts_success;

    l_tot_subline_tax                       NUMBER;
    l_tot_topline_tax                       NUMBER;

  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    OPEN l_topline_csr;

    LOOP
      FETCH l_topline_csr
       INTO l_line_id;

      EXIT WHEN l_topline_csr%NOTFOUND;

      OPEN l_sublineamt_csr (l_line_id);

      FETCH l_sublineamt_csr
       INTO l_tot_subline_amt;

      CLOSE l_sublineamt_csr;

      --Update Line With the Amounts from Pricing Engine(Price Negotiated and Unit Price)
      l_clev_rec.ID              := l_line_id;
      l_clev_rec.price_negotiated := l_tot_subline_amt;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '106:In Update Amounts: TopLine Id: ' ||
                        l_line_id
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '107:In Update Amounts: Total Of Subline Amount: ' ||
                        l_tot_subline_amt
                       );
      END IF;

      --errorout_urp('In Update Amounts: TopLine Id: ' || l_line_id);
      --errorout_urp('In Update Amounts: Total Of Subline Amount: ' || l_tot_subline_amt);
      update_line (p_clev_rec                        => l_clev_rec,
                   x_return_status                   => l_return_status);

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING
                      (fnd_log.level_statement,
                       g_module ||
                       l_api_name,
                       '108:In Update Amounts After Update Line: Status: ' ||
                       l_return_status
                      );
      END IF;

      --errorout_urp('In Update Amounts After Update Line: Status: ' || l_return_status);
      IF l_return_status <> g_ret_sts_success THEN
        CLOSE l_topline_csr;

        RAISE g_error;
      END IF;

      l_line_id                  := NULL;
      l_tot_subline_amt          := NULL;
    --Update Line With the Amounts from Pricing Engine(Price Negotiated and Unit Price)

      /*  Not required as done in oks_renew_contract_pvt
     -- added skekkar to update topline tax amount
        OPEN l_sublinetax_csr (l_line_id);
          FETCH l_sublinetax_csr INTO l_tot_subline_tax;
        CLOSE l_sublinetax_csr;

        UPDATE oks_k_lines_b
          SET tax_amount = l_tot_subline_tax
        WHERE cle_id = l_line_id;
     -- end added skekkar
     */

    END LOOP;

    CLOSE l_topline_csr;

    OPEN l_toplineamt_csr;

    FETCH l_toplineamt_csr
     INTO l_tot_topline_amt;

    CLOSE l_toplineamt_csr;

    --UPDATE HEADER;
    l_chrv_rec.ID              := p_chr_id;
    l_chrv_rec.estimated_amount := l_tot_topline_amt;
    --errorout_urp('Header Amount: ' || l_chrv_rec.estimated_amount);
    update_header (p_chrv_rec                        => l_chrv_rec,
                   x_return_status                   => l_return_status);

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING
                    (fnd_log.level_statement,
                     g_module ||
                     l_api_name,
                     '109:In Update Amounts After Update Header: Status: ' ||
                     l_return_status
                    );
    END IF;

    --errorout_urp('In Update Amounts After Update Header: Status: ' || l_return_status);
    IF l_return_status <> g_ret_sts_success THEN
      RAISE g_error;
    END IF;

    --UPDATE HEADER;
    x_return_status            := l_return_status;

     /*  Not required as done in oks_renew_contract_pvt
     -- added skekkar to update header tax amount
       OPEN l_toplinetax_csr;
         FETCH l_toplinetax_csr INTO l_tot_topline_tax;
       CLOSE l_toplinetax_csr;

       UPDATE oks_k_headers_b
          SET tax_amount = l_tot_topline_tax
        WHERE chr_id = p_chr_id;
     -- end added skekkar to update header tax amount
     */


    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
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
    WHEN g_error THEN
      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '2500: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      x_return_status            := l_return_status;
    WHEN OTHERS THEN
      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
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
      okc_api.set_message (p_app_name                        => g_app_name_oks,
                           p_msg_name                        => g_unexpected_error,
                           p_token1                          => g_sqlcode_token,
                           p_token1_value                    => SQLCODE,
                           p_token2                          => g_sqlerrm_token,
                           p_token2_value                    => SQLERRM
                          );
  END update_amounts;

  PROCEDURE calculate_tax (
    p_chr_id                         IN       NUMBER,
    p_cle_id                         IN       NUMBER,
    p_amount                         IN       NUMBER,
    x_return_status                  OUT NOCOPY VARCHAR2
  ) IS
    l_api_name                     CONSTANT VARCHAR2 (30) := 'calculate_tax';
    l_kln_rec_in                            oks_contract_line_pub.klnv_rec_type;
    l_kln_rec_out                           oks_contract_line_pub.klnv_rec_type;
    l_exception                             EXCEPTION;
    l_rail_rec                              oks_tax_util_pvt.ra_rec_type;
    l_tax_value                             NUMBER;
    l_tax_flag                              VARCHAR2 (3);
    l_total_amount                          NUMBER;
    l_k_det_rec                             oks_qp_int_pvt.k_details_rec;
    l_return_status                         VARCHAR2 (1) := g_ret_sts_success;
    l_msg_count                             NUMBER;
    l_msg_data                              VARCHAR2 (2000);
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    -- bug 5138920 Call to calculate_tax should not error out even if tax is not setup correctly
    -- initialize x_return_status to success
       x_return_status := g_ret_sts_success;

    l_rail_rec.amount          := p_amount;
    oks_tax_util_pvt.get_tax (p_api_version                     => 1.0,
                              p_init_msg_list                   => okc_api.g_true,
                              p_chr_id                          => p_chr_id,
                              p_cle_id                          => p_cle_id,
                              px_rail_rec                       => l_rail_rec,
                              x_msg_count                       => l_msg_count,
                              x_msg_data                        => l_msg_data,
                              x_return_status                   => l_return_status
                             );

    IF l_return_status <> g_ret_sts_success THEN
       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.STRING (fnd_log.level_statement, g_module ||l_api_name,
                         '105: Call to oks_tax_util_pvt.get_tax  FAILED, l_return_status: ' ||l_return_status
                        );
         fnd_log.STRING (fnd_log.level_statement, g_module ||l_api_name,
                         '105:  l_msg_data '||l_msg_data
                        );
       END IF;
     -- bug 5001677 even if tax api has error, proceed with renewal
     -- RAISE g_error;
       l_tax_value                :=  0;
       l_tax_flag                 := 'N';

     -- bug 5138920, reset l_return_status to success
       l_return_status := g_ret_sts_success;
    END IF;

    l_tax_value                := l_rail_rec.tax_value;
    l_tax_flag                 := l_rail_rec.amount_includes_tax_flag;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '110:Inside Calculate Tax: l_tax_value: ' ||
                      l_tax_value
                     );
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '111:Inside Calculate Tax: l_tax_flag: ' ||
                      l_tax_flag
                     );
    END IF;

    --errorout_urp('Inside Calculate Tax: l_tax_value: ' || l_tax_value);
    --errorout_urp('Inside Calculate Tax: l_tax_flag: ' || l_tax_flag);
    l_kln_rec_in.cle_id        := p_cle_id;
    l_kln_rec_in.dnz_chr_id    := p_chr_id;
    l_kln_rec_in.tax_inclusive_yn := l_tax_flag;

    IF l_tax_flag = 'N' THEN
      l_kln_rec_in.tax_amount    := NVL (l_tax_value, 0);
    ELSE
      l_kln_rec_in.tax_amount    := 0;
    END IF;

    oks_qp_int_pvt.get_k_details (p_id                              => p_cle_id,
                                  p_type                            => oks_qp_int_pvt.g_oks_line,
                                  x_k_det_rec                       => l_k_det_rec
                                 );
    l_kln_rec_in.ID            := l_k_det_rec.ID;
    l_kln_rec_in.object_version_number := l_k_det_rec.object_version_number;

   -- bug 4865683 SKEKKAR
   -- update column clvl_extended_amt in oks_k_lines_b with price_negotiated
    l_kln_rec_in.clvl_extended_amt  := NVL(p_amount,0) ;
   -- end added

    oks_contract_line_pub.update_line (p_api_version                     => 1.0,
                                       p_init_msg_list                   => 'F',
                                       x_return_status                   => l_return_status,
                                       x_msg_count                       => l_msg_count,
                                       x_msg_data                        => l_msg_data,
                                       p_klnv_rec                        => l_kln_rec_in,
                                       x_klnv_rec                        => l_kln_rec_out,
                                       p_validate_yn                     => 'N'
                                      );

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '112:Status AFter update rule in calculate_tax: ' ||
                      l_return_status
                     );
    END IF;

    --errorout_urp('Status AFter update rule in calculate_tax: ' || l_return_status);
    -- IF x_return_status <> g_ret_sts_success THEN
    IF l_return_status <> g_ret_sts_success THEN  -- bug 5138920
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '113:Update line details at Calc Tax'
                       );
      END IF;

      -- errorout_urp('Update line details at Calc Tax');
      RAISE g_error;
    END IF;

    x_return_status            := l_return_status;

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
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
    WHEN g_error THEN
      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '2500: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      x_return_status            := l_return_status;
    WHEN OTHERS THEN
      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
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
      okc_api.set_message (p_app_name                        => g_app_name_oks,
                           p_msg_name                        => g_unexpected_error,
                           p_token1                          => g_sqlcode_token,
                           p_token1_value                    => SQLCODE,
                           p_token2                          => g_sqlerrm_token,
                           p_token2_value                    => SQLERRM
                          );
  END calculate_tax;

  PROCEDURE update_price_info (
    p_chr_id                         IN       NUMBER,
    p_cle_id                         IN       NUMBER,
    p_lse_id                         IN       NUMBER,
    p_price_type                     IN       VARCHAR2,
    p_price_details                  IN       oks_qp_pkg.price_details,
    x_return_status                  OUT NOCOPY VARCHAR2
  ) IS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                                      := 'update_price_info ';
    l_kln_rec_in                            oks_contract_line_pub.klnv_rec_type;
    l_kln_rec_out                           oks_contract_line_pub.klnv_rec_type;
    l_k_det_rec                             oks_qp_int_pvt.k_details_rec;
    l_return_status                         VARCHAR2 (1) := g_ret_sts_success;
    l_msg_count                             NUMBER;
    l_msg_data                              VARCHAR2 (2000);
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    oks_qp_int_pvt.get_k_details (p_id                              => p_cle_id,
                                  p_type                            => oks_qp_int_pvt.g_oks_line,
                                  x_k_det_rec                       => l_k_det_rec
                                 );
    l_kln_rec_in.ID            := l_k_det_rec.ID;
    l_kln_rec_in.object_version_number := l_k_det_rec.object_version_number;
    l_kln_rec_in.cle_id        := p_cle_id;
    l_kln_rec_in.dnz_chr_id    := p_chr_id;
    l_kln_rec_in.status_text   := p_price_details.status_text;

    IF p_price_type = 'MAN' THEN
      l_kln_rec_in.clvl_list_price := NULL;
      l_kln_rec_in.clvl_quantity := NULL;
      l_kln_rec_in.clvl_extended_amt := NULL;
      -- l_kln_rec_in.clvl_uom_code := NULL; -- Bug 5129965
      l_kln_rec_in.toplvl_operand_code := NULL;
      l_kln_rec_in.toplvl_operand_val := NULL;
      l_kln_rec_in.toplvl_quantity := NULL;
      -- l_kln_rec_in.toplvl_uom_code := NULL; --Bug 5129965
      l_kln_rec_in.toplvl_adj_price := NULL;
      l_kln_rec_in.toplvl_price_qty := NULL; --uncommented for Bug#5359739
      --l_kln_rec_in.rule_information11      := p_price_details.serv_ext_amount;
      l_kln_rec_in.prod_price    := NULL;
      l_kln_rec_in.service_price := NULL;
    ELSE
      --l_kln_rec_in.status_text        := 'Price Derived Using Price Index';
      IF p_lse_id = 46 THEN
        --l_kln_rec_in.rule_information4   := p_price_details.prod_list_unit_price;
        l_kln_rec_in.toplvl_quantity := p_price_details.prod_qty;
        -- bug 5129965
        IF p_price_details.prod_priced_uom IS NOT NULL THEN
          l_kln_rec_in.toplvl_uom_code := p_price_details.prod_priced_uom;
        END IF;
        l_kln_rec_in.toplvl_adj_price := p_price_details.prod_adj_unit_price;
        --l_kln_rec_in.rule_information11    := p_price_details.prod_ext_amount;
        --Removed the IF condition for Bug#5359739
        --IF p_price_details.serv_priced_qty IS NOT NULL THEN
          -- l_kln_rec_in.toplvl_price_qty := p_price_details.serv_priced_qty;
          -- bug 5511211, for subscription lines look at p_price_details.prod_priced_qty
          l_kln_rec_in.toplvl_price_qty := p_price_details.prod_priced_qty;
        --END IF;
        l_kln_rec_in.service_price := p_price_details.prod_price_list_id;
      ELSE
        l_kln_rec_in.clvl_list_price := p_price_details.prod_list_unit_price;
        l_kln_rec_in.clvl_quantity := p_price_details.prod_priced_qty;
        l_kln_rec_in.clvl_extended_amt := p_price_details.prod_ext_amount;
        --l_kln_rec_in.rule_information4     := p_price_details.serv_list_unit_price;
        l_kln_rec_in.toplvl_operand_code := p_price_details.serv_operator;
        l_kln_rec_in.toplvl_operand_val := p_price_details.serv_operand;
        -- bug 5129965
        IF p_price_details.prod_priced_uom IS NOT NULL THEN
          l_kln_rec_in.clvl_uom_code := p_price_details.prod_priced_uom;
        END IF;
        l_kln_rec_in.toplvl_quantity := p_price_details.serv_qty;
        -- bug 5129965
        IF p_price_details.serv_priced_uom IS NOT NULL THEN
          l_kln_rec_in.toplvl_uom_code := p_price_details.serv_priced_uom;
        END IF;
        l_kln_rec_in.toplvl_adj_price := p_price_details.serv_adj_unit_price;
        --l_kln_rec_in.rule_information11    := p_price_details.serv_ext_amount;
        --Removed the IF condition for Bug#5359739
        --IF p_price_details.serv_priced_qty IS NOT NULL THEN
          l_kln_rec_in.toplvl_price_qty := p_price_details.serv_priced_qty;
        --END IF;
        l_kln_rec_in.prod_price    := p_price_details.prod_price_list_id;
        l_kln_rec_in.service_price := p_price_details.serv_price_list_id;
      END IF;
    END IF;

    oks_contract_line_pub.update_line (p_api_version                     => 1.0,
                                       p_init_msg_list                   => 'F',
                                       x_return_status                   => l_return_status,
                                       x_msg_count                       => l_msg_count,
                                       x_msg_data                        => l_msg_data,
                                       p_klnv_rec                        => l_kln_rec_in,
                                       x_klnv_rec                        => l_kln_rec_out,
                                       p_validate_yn                     => 'N'
                                      );

    IF l_return_status <> g_ret_sts_success THEN
      RAISE g_error;
    END IF;

    x_return_status            := l_return_status;

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
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
    WHEN g_error THEN
      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '2500: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      x_return_status            := l_return_status;
    WHEN OTHERS THEN
      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
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
      okc_api.set_message (p_app_name                        => g_app_name_oks,
                           p_msg_name                        => g_unexpected_error,
                           p_token1                          => g_sqlcode_token,
                           p_token1_value                    => SQLCODE,
                           p_token2                          => g_sqlerrm_token,
                           p_token2_value                    => SQLERRM
                          );
  END update_price_info;

  PROCEDURE calculate_price (
    p_chr_id                         IN       NUMBER,
    p_line_id                        IN       NUMBER,
    p_linecle_id                     IN       NUMBER,
    p_lse_id                         IN       NUMBER,
    p_intent                         IN       VARCHAR2,
    p_price_type                     IN       VARCHAR2,
    p_price_list                     IN       NUMBER,
    p_amount                         IN       NUMBER,
    x_return_status                  OUT NOCOPY VARCHAR2
  ) IS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                                         := 'calculate_price';

    CURSOR l_subs_elements_csr (
      p_line_id                                 NUMBER
    ) IS
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

    l_new_amount                            NUMBER;
    l_clev_rec                              okc_contract_pub.clev_rec_type;
    l_price_type                            VARCHAR2 (10);
    l_detail_rec                            oks_qp_pkg.input_details;
    l_price_details                         oks_qp_pkg.price_details;
    l_modifier_details                      qp_preq_grp.line_detail_tbl_type;
    l_price_break_details                   oks_qp_pkg.g_price_break_tbl_type;
    l_scev_rec_in                           oks_subscr_elems_pub.scev_rec_type;
    l_scev_rec_out                          oks_subscr_elems_pub.scev_rec_type;
    l_api_version                           NUMBER := 1.0;
    l_init_msg_list                         VARCHAR2 (1) := okc_api.g_false;
    l_return_status                         VARCHAR2 (1) := g_ret_sts_success;
    l_msg_count                             NUMBER;
    l_msg_data                              VARCHAR2 (2000);
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    l_detail_rec.line_id       := NVL (p_linecle_id, p_line_id);

    IF p_linecle_id IS NULL THEN
      l_detail_rec.subline_id    := NULL;
    ELSE
      l_detail_rec.subline_id    := p_line_id;
    END IF;

    l_detail_rec.intent        := p_intent;
    l_detail_rec.price_list    := p_price_list;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '114:l_detail_rec.line_id: ' ||
                      l_detail_rec.line_id
                     );
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '115:l_detail_rec.subline_id: ' ||
                      l_detail_rec.subline_id
                     );
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '116:l_detail_rec.intent: ' ||
                      l_detail_rec.intent
                     );
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '117:l_detail_rec.price_list: ' ||
                      l_detail_rec.price_list
                     );
    END IF;

    --errorout_urp('l_detail_rec.line_id: ' || l_detail_rec.line_id);
    --errorout_urp('l_detail_rec.subline_id: ' || l_detail_rec.subline_id);
    --errorout_urp('l_detail_rec.intent: ' || l_detail_rec.intent);
    --errorout_urp('l_detail_rec.price_list: ' || l_detail_rec.price_list);
    oks_qp_pkg.calc_price (p_detail_rec                      => l_detail_rec,
                           x_price_details                   => l_price_details,
                           x_modifier_details                => l_modifier_details,
                           x_price_break_details             => l_price_break_details,
                           x_return_status                   => l_return_status,
                           x_msg_count                       => l_msg_count,
                           x_msg_data                        => l_msg_data
                          );

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING
            (fnd_log.level_statement,
             g_module ||
             l_api_name,
             '118:In Calculate Price Status after OKS_QP_PKG.calc_price: ' ||
             l_return_status
            );
    END IF;

    --errorout_urp('In Calculate Price Status after OKS_QP_PKG.calc_price: ' || l_return_status);
    IF l_return_status <> g_ret_sts_success THEN
      RAISE g_error;
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '119:Markup/down amount: ' ||
                      p_amount
                     );
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '120:l_price_details.serv_ext_amount: ' ||
                      l_price_details.serv_ext_amount
                     );
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '120:l_price_details.prod_ext_amount: ' ||
                      l_price_details.serv_ext_amount
                     );
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '121:l_price_details.status_text: ' ||
                      l_price_details.status_text
                     );
    END IF;

    --errorout_urp('Markup/down amount: ' || p_amount);
    --errorout_urp('l_price_details.serv_ext_amount: ' || l_price_details.serv_ext_amount);
    --errorout_urp('l_price_details.status_text: ' || l_price_details.status_text);
/*
 * Bug 5511211
 * In case of subscription pricing, QP populates l_price_details.prod_ext_amount
 * For lse_id = 46 , compare amount with l_price_details.prod_ext_amount
*/

    --p_amount is markedup/down amount. This is already calculated by the caller.
    IF p_lse_id = 46 THEN
      -- bug 5511211
         IF l_price_details.prod_ext_amount <= p_amount THEN
           l_new_amount               := l_price_details.prod_ext_amount;
           l_price_type               := 'PCT';
         ELSE
           l_new_amount               := p_amount;
           l_price_type               := 'MAN';
         END IF;
    ELSE
      -- old logic
         IF l_price_details.serv_ext_amount <= p_amount THEN
           l_new_amount               := l_price_details.serv_ext_amount;
           l_price_type               := 'PCT';
         ELSE
           l_new_amount               := p_amount;
           l_price_type               := 'MAN';
         END IF;
    END IF; -- bug 5511211, p_lse_id=46

    l_price_details.status_text :=
             l_price_details.status_text ||
             ' Price derived using price index';

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '122:In Calulate Price : l_price_type: ' ||
                      l_price_type
                     );
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '123:Amount Goes to OKC_K_LINES_B: ' ||
                      l_new_amount
                     );
    END IF;

    --errorout_urp('In Calulate Price : l_price_type: ' || l_price_type);
    --errorout_urp('Amount Goes to OKC_K_LINES_B: ' || l_new_amount);
    l_clev_rec.ID              := p_line_id;
    l_clev_rec.price_negotiated := l_new_amount;

   -- bug 5511211
   -- for subscription lines, look at l_price_details.prod_adj_unit_price for unit price
    IF p_lse_id = 46 THEN
        IF l_price_type = 'PCT' THEN
          l_clev_rec.price_unit      := l_price_details.prod_adj_unit_price;
        END IF;
    ELSE
       -- old logic
        IF l_price_type = 'PCT' THEN
          l_clev_rec.price_unit      := l_price_details.serv_adj_unit_price;
        END IF;
    END IF; -- bug 5511211, p_lse_id = 46

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING
             (fnd_log.level_statement,
              g_module ||
              l_api_name,
              '124:Before update line in calculate_price: l_clev_rec.id: ' ||
              l_clev_rec.ID
             );
      fnd_log.STRING
        (fnd_log.level_statement,
         g_module ||
         l_api_name,
         '125:Before update line in calculate_price: l_clev_rec.price_negotiated: ' ||
         l_clev_rec.price_negotiated
        );
      fnd_log.STRING
        (fnd_log.level_statement,
         g_module ||
         l_api_name,
         '126:Before update line in calculate_price: l_clev_rec.price_unit: ' ||
         l_clev_rec.price_unit
        );
    END IF;

    --errorout_urp('Before update line in calculate_price: l_clev_rec.id: ' || l_clev_rec.id);
    --errorout_urp('Before update line in calculate_price: l_clev_rec.price_negotiated: ' || l_clev_rec.price_negotiated);
    --errorout_urp('Before update line in calculate_price: l_clev_rec.price_unit: ' || l_clev_rec.price_unit);
    update_line (p_clev_rec                        => l_clev_rec,
                 x_return_status                   => l_return_status);

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '127:Status after update line in calculate_price: ' ||
                      l_return_status
                     );
    END IF;

    --errorout_urp('Status after update line in calculate_price: ' || l_return_status);
    IF l_return_status <> g_ret_sts_success THEN
      RAISE g_error;
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING
                  (fnd_log.level_statement,
                   g_module ||
                   l_api_name,
                   '128:In Calulate Price : l_price_details.status_text: ' ||
                   l_price_details.status_text
                  );
    END IF;

    --errorout_urp('In Calulate Price : l_price_details.status_text: ' || l_price_details.status_text);
    update_price_info (p_chr_id                          => p_chr_id,
                       p_cle_id                          => p_line_id,
                       p_lse_id                          => p_lse_id,
                       p_price_type                      => l_price_type,
                       p_price_details                   => l_price_details,
                       x_return_status                   => l_return_status
                      );

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING
                  (fnd_log.level_statement,
                   g_module ||
                   l_api_name,
                   '129:Status after Handle Pdl Rule in calculate_price: ' ||
                   l_return_status
                  );
    END IF;

    --errorout_urp('Status after Handle Pdl Rule in calculate_price: ' || l_return_status);
    IF l_return_status <> g_ret_sts_success THEN
      RAISE g_error;
    END IF;

    -- Update Subsciption elements
    IF p_lse_id = 46 THEN
      FOR l_subs_elements_rec IN l_subs_elements_csr (l_detail_rec.line_id) LOOP
        l_scev_rec_in.ID           := l_subs_elements_rec.ID;
        l_scev_rec_in.amount       :=
           l_subs_elements_rec.quantity *
           l_price_details.serv_adj_unit_price;
        l_scev_rec_in.object_version_number :=
                                     l_subs_elements_rec.object_version_number;
        oks_subscr_elems_pub.update_row (p_api_version                     => l_api_version,
                                         p_init_msg_list                   => l_init_msg_list,
                                         x_return_status                   => l_return_status,
                                         x_msg_count                       => l_msg_count,
                                         x_msg_data                        => l_msg_data,
                                         p_scev_rec                        => l_scev_rec_in,
                                         x_scev_rec                        => l_scev_rec_out
                                        );

        IF l_return_status <> g_ret_sts_success THEN
          RAISE g_error;
        END IF;
      END LOOP;
    END IF;

    --Calculate Tax For Toplines(All Covered Levels for Service and Extended Warranty)
    calculate_tax (p_chr_id                          => p_chr_id,
                   p_cle_id                          => p_line_id,
                   p_amount                          => l_new_amount,
                   x_return_status                   => l_return_status
                  );

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING
                    (fnd_log.level_statement,
                     g_module ||
                     l_api_name,
                     '130:Status after calculate_tax in calculate_price: ' ||
                     l_return_status
                    );
    END IF;

    --errorout_urp('Status after calculate_tax in calculate_price: ' || l_return_status);
    IF l_return_status <> g_ret_sts_success THEN
      RAISE g_error;
    END IF;

    x_return_status            := l_return_status;

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
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
    WHEN g_error THEN
      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '2500: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      x_return_status            := l_return_status;
    WHEN OTHERS THEN
      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
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
      okc_api.set_message (p_app_name                        => g_app_name_oks,
                           p_msg_name                        => g_unexpected_error,
                           p_token1                          => g_sqlcode_token,
                           p_token1_value                    => SQLCODE,
                           p_token2                          => g_sqlerrm_token,
                           p_token2_value                    => SQLERRM
                          );
  END calculate_price;

  PROCEDURE call_pricing_api (
    p_api_version                    IN       NUMBER,
    p_init_msg_list                  IN       VARCHAR2,
    p_id                             IN       NUMBER,
    p_id_type                        IN       VARCHAR2,
    x_return_status                  OUT NOCOPY VARCHAR2,
    x_msg_count                      OUT NOCOPY NUMBER,
    x_msg_data                       OUT NOCOPY VARCHAR2
  ) IS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                                        := 'call_pricing_api';
    l_detail_rec                            oks_qp_pkg.input_details;
    l_price_details                         oks_qp_pkg.price_details;
    l_modifier_details                      qp_preq_grp.line_detail_tbl_type;
    l_price_break_details                   oks_qp_pkg.g_price_break_tbl_type;
    l_return_status                         VARCHAR2 (1) := g_ret_sts_success;
    l_msg_count                             NUMBER;
    l_msg_data                              VARCHAR2 (2000);
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    IF p_id_type IS NULL THEN
      okc_api.set_message (g_app_name_oks,
                           g_required_value,
                           g_col_name_token,
                           'P_Id_Type'
                          );
      x_return_status            := g_ret_sts_error;
      RAISE g_error;
    END IF;

    IF p_id IS NOT NULL THEN
      IF p_id_type = 'CHR' THEN
        l_detail_rec.chr_id        := p_id;
        l_detail_rec.intent        := 'HP';
        oks_qp_int_pvt.compute_price
                             (p_api_version                     => p_api_version,
                              p_init_msg_list                   => p_init_msg_list,
                              p_detail_rec                      => l_detail_rec,
                              x_price_details                   => l_price_details,
                              x_modifier_details                => l_modifier_details,
                              x_price_break_details             => l_price_break_details,
                              x_return_status                   => l_return_status,
                              x_msg_count                       => l_msg_count,
                              x_msg_data                        => l_msg_data
                             );

        IF l_return_status <> g_ret_sts_success THEN
          RAISE g_error;
        END IF;
      ELSIF p_id_type = 'CLE' THEN
        NULL;
      END IF;
    END IF;

    x_return_status            := l_return_status;

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
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
    WHEN g_error THEN
      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '2500: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      x_return_status            := l_return_status;
    WHEN OTHERS THEN
      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
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
      okc_api.set_message (p_app_name                        => g_app_name_oks,
                           p_msg_name                        => g_unexpected_error,
                           p_token1                          => g_sqlcode_token,
                           p_token1_value                    => SQLCODE,
                           p_token2                          => g_sqlerrm_token,
                           p_token2_value                    => SQLERRM
                          );
      x_return_status            := g_ret_sts_unexp_error;
  END call_pricing_api;

  --Called from renewal.
  PROCEDURE call_pricing_api (
    p_api_version                    IN       NUMBER,
    p_init_msg_list                  IN       VARCHAR2,
    p_reprice_rec                    IN       reprice_rec_type,
    x_return_status                  OUT NOCOPY VARCHAR2,
    x_msg_count                      OUT NOCOPY NUMBER,
    x_msg_data                       OUT NOCOPY VARCHAR2
  ) IS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                                        := 'call_pricing_api';
  -- Bug 5139658
     l_orig_system_id1                   okc_k_headers_all_b.orig_system_id1%type;
     l_org_id                                okc_k_headers_all_b.org_id%type;

      CURSOR get_orig_system_id1 (
      p_chr_id                                  NUMBER
    ) IS
      SELECT orig_system_id1
        FROM okc_k_headers_all_b
       WHERE ID = p_chr_id;


     CURSOR get_org_id_csr (
      p_hdr_id                                  NUMBER
    ) IS
      SELECT org_id
        FROM okc_k_headers_all_b
       WHERE ID = p_hdr_id;

 -- End Bug 5139658

    CURSOR l_pricelist_csr (
      p_chr_id                                  NUMBER
    ) IS
      SELECT price_list_id
        FROM okc_k_headers_all_b
       WHERE ID = p_chr_id;

    -- Bug Fix 4291565
    CURSOR l_line_csr IS
      SELECT ID,
             start_date,
             end_date,
             lse_id,
             price_negotiated,
             price_unit,
             cle_id,
             dnz_chr_id
        FROM okc_k_lines_b
       WHERE dnz_chr_id = p_reprice_rec.contract_id
         AND lse_id IN (7, 8, 9, 10, 11, 13, 25, 35, 46);

    -- Bug Fix 4291565
    CURSOR l_usage_type_csr (
      p_cle_id                                  NUMBER
    ) IS
      SELECT usage_type
        FROM oks_k_lines_b
       WHERE cle_id = p_cle_id;

    CURSOR l_subs_elements_csr (
      p_line_id                                 NUMBER
    ) IS
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

    l_new_duration                             NUMBER;
    l_tangible        BOOLEAN;
    l_pricing_method Varchar2(30);




    l_chr_rec_in                            okc_contract_pub.chrv_rec_type;
    l_chr_rec_out                           okc_contract_pub.chrv_rec_type;
    l_scev_rec_in                           oks_subscr_elems_pub.scev_rec_type;
    l_scev_rec_out                          oks_subscr_elems_pub.scev_rec_type;
    l_pricelist_id                          NUMBER;
    l_line_rec                              l_line_csr%ROWTYPE;
    l_old_start_date                        DATE;
    l_old_end_date                          DATE;
    l_prorated_price_neg                    NUMBER;
    l_prorated_unit_price                   NUMBER;
    l_intent                                VARCHAR2 (10);
    l_detail_rec                            oks_qp_pkg.input_details;
    l_price_details                         oks_qp_pkg.price_details := NULL;
    l_modifier_details                      qp_preq_grp.line_detail_tbl_type;
    l_price_break_details                   oks_qp_pkg.g_price_break_tbl_type;
    l_api_version                           NUMBER := 1.0;
    l_init_msg_list                         VARCHAR2 (1) := okc_api.g_false;
    l_return_status                         VARCHAR2 (1) := g_ret_sts_success;
    l_msg_count                             NUMBER;
    l_msg_data                              VARCHAR2 (2000);
    l_clev_rec                              okc_contract_pub.clev_rec_type;

    CURSOR l_currcode_csr (
      p_hdr_id                                  NUMBER
    ) IS
      SELECT currency_code
        FROM okc_k_headers_all_b
       WHERE ID = p_hdr_id;

    l_currency                              VARCHAR2 (15);
    l_usage_type                            VARCHAR2 (10);
    --New variables for partial periods
    l_period_type                           VARCHAR2 (30);
    l_period_start                          VARCHAR2 (30);
    l_period_type_orig                      VARCHAR2 (30);
    l_period_start_orig                     VARCHAR2 (30);
    l_price_uom                             VARCHAR2 (30);
    l_partial_period_flag                   VARCHAR2 (10);
    l_period_type_old                           VARCHAR2 (30);
    l_period_start_old                          VARCHAR2 (30);
    l_price_uom_old                             VARCHAR2 (30);

    -- Bug Fix 4363689
/*
  Manually priced lines
  8  :   Party
  10 :   Site
  11 :   System
  13 :   Usage Counter (NPR only)
  35 :   Customer
*/
    CURSOR l_man_priced_lines_csr IS
      SELECT ID,
             start_date,
             end_date,
             lse_id,
             price_negotiated,
             price_unit,
             cle_id,
             dnz_chr_id
        FROM okc_k_lines_b
       WHERE dnz_chr_id = p_reprice_rec.contract_id
         AND lse_id  IN (8, 10, 11, 13, 35); -- Bug fix 4769124
    l_man_priced_line_rec                 l_man_priced_lines_csr%ROWTYPE;


  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    oks_renew_pvt.debug_log (p_program_name                    => 'Reprice',
                             p_perf_msg                        => 'Inside Reprice Api');
    oks_renew_pvt.debug_log (p_program_name                    => 'Reprice',
                             p_perf_msg                        => 'Contract Id: ' ||
                                                                  p_reprice_rec.contract_id);
    oks_renew_pvt.debug_log (p_program_name                    => 'Reprice',
                             p_perf_msg                        => 'Price List Id: ' ||
                                                                  p_reprice_rec.price_list_id);
    oks_renew_pvt.debug_log (p_program_name                    => 'Reprice',
                             p_perf_msg                        => 'Price Type: ' ||
                                                                  p_reprice_rec.price_type);
    oks_renew_pvt.debug_log (p_program_name                    => 'Reprice',
                             p_perf_msg                        => 'Markup Percent: ' ||
                                                                  p_reprice_rec.markup_percent);
    -- Make a save point, in case of error rollback
    DBMS_TRANSACTION.SAVEPOINT ('REPRICE_OKS');
    --Added by jvorugan begin new logic for Partial Periods

    -- Bug 5139658

    -- Bug 5337890

   -- l_orig_system_id1 - refers to source contract id
   -- p_reprice_rec.contract_id - refers to target contract id

    oks_renew_util_pub.get_period_defaults
                                       (p_hdr_id                          => p_reprice_rec.contract_id,
                                        p_org_id                          => NULL,
                                        x_period_type                     => l_period_type_orig,
                                        x_period_start                    => l_period_start_orig,
                                        x_price_uom                       => l_price_uom,
                                        x_return_status                   => l_return_status
                                       );

    IF l_return_status <> g_ret_sts_success THEN
      RAISE g_error;
    END IF;


    IF     l_period_start_orig IS NOT NULL
       AND l_period_type_orig IS NOT NULL THEN
      l_partial_period_flag      := 'TRUE';
    ELSE
      l_partial_period_flag      := 'FALSE';
    END IF;

    Open get_orig_system_id1 (p_reprice_rec.contract_id);
    Fetch get_orig_system_id1 into l_orig_system_id1;
    Close get_orig_system_id1;

    oks_renew_util_pub.get_period_defaults
                                       (p_hdr_id                          => l_orig_system_id1,
                                        p_org_id                          => NULL,
                                        x_period_type                     => l_period_type_old,
                                        x_period_start                    => l_period_start_old,
                                        x_price_uom                       => l_price_uom_old,
                                        x_return_status                   => l_return_status
                                       );

    IF l_return_status <> g_ret_sts_success THEN
      RAISE g_error;
    END IF;

    -- End Bug 5337890

    --end  new logic for Partial Periods
    IF p_reprice_rec.price_type = 'LST' THEN
      OPEN l_pricelist_csr (p_reprice_rec.contract_id);

      FETCH l_pricelist_csr
       INTO l_pricelist_id;

      CLOSE l_pricelist_csr;

      --Added by jvorugan begin new logic for Partial Periods
      IF     l_period_type_old IS NOT NULL
         AND l_period_start_old IS NOT NULL
         AND l_price_uom_old IS NOT NULL THEN   -- Bug 5139658

        update_price_uom (p_chr_id                          => p_reprice_rec.contract_id,
                          p_price_uom                       => l_price_uom_old,
                          x_return_status                   => l_return_status);

      -- Bug 5139658
      ELSE

        Open get_org_id_csr (l_orig_system_id1);
        Fetch get_org_id_csr into l_org_id;
        Close get_org_id_csr;

              oks_renew_util_pub.get_period_defaults
                (   p_hdr_id                          => NULL,
                    p_org_id                          => l_org_id,
                    x_period_type                     => l_period_type_orig,
                    x_period_start                    => l_period_start_orig,
                    x_price_uom                       => l_price_uom_old,
                    x_return_status                   => l_return_status
                );

      IF l_return_status <> g_ret_sts_success THEN
        RAISE g_error;
      END IF;

        IF (l_price_uom_old is not null) THEN

                update_price_uom (
                                p_chr_id                  => p_reprice_rec.contract_id,
                                p_price_uom               => l_price_uom_old,
                                x_return_status           => l_return_status);
        END IF;

      END IF; -- l_period_type IS NOT NULL


      IF l_return_status <> okc_api.g_ret_sts_success THEN
        RAISE g_error;
      END IF;

      --End new logic for Partial Periods
      oks_renew_pvt.debug_log (p_program_name                    => 'Reprice',
                               p_perf_msg                        => 'Derived PriceList Id: ' ||
                                                                    l_pricelist_id);

      -- Bug 4628808
      IF p_reprice_rec.price_list_id <> NVL (l_pricelist_id, -9999) THEN
        l_chr_rec_in.ID            := p_reprice_rec.contract_id;
        l_chr_rec_in.price_list_id := p_reprice_rec.price_list_id;
        okc_contract_pub.update_contract_header
                                         (p_api_version                     => l_api_version,
                                          p_init_msg_list                   => l_init_msg_list,
                                          x_return_status                   => l_return_status,
                                          x_msg_count                       => l_msg_count,
                                          x_msg_data                        => l_msg_data,
                                          p_restricted_update               => 'N',
                                          p_chrv_rec                        => l_chr_rec_in,
                                          x_chrv_rec                        => l_chr_rec_out
                                         );
        oks_renew_pvt.debug_log
                          (p_program_name                    => 'Reprice',
                           p_perf_msg                        => 'Status After Price List Update: ' ||
                                                                l_return_status);

        IF l_return_status <> g_ret_sts_success THEN
          RAISE g_error;
        END IF;
      END IF;

      l_detail_rec.chr_id        := p_reprice_rec.contract_id;
      l_detail_rec.intent        := 'HP';
      oks_renew_pvt.debug_log
                          (p_program_name                    => 'Reprice',
                           p_perf_msg                        => 'Calling Pricing Api with intent ' ||
                                                                l_detail_rec.intent);
      --This api will take care about updating the amounts of the contract.
      oks_qp_int_pvt.compute_price
                              (p_api_version                     => p_api_version,
                               p_init_msg_list                   => p_init_msg_list,
                               p_detail_rec                      => l_detail_rec,
                               x_price_details                   => l_price_details,
                               x_modifier_details                => l_modifier_details,
                               x_price_break_details             => l_price_break_details,
                               x_return_status                   => l_return_status,
                               x_msg_count                       => l_msg_count,
                               x_msg_data                        => l_msg_data
                              );
      oks_renew_pvt.debug_log (p_program_name                    => 'Reprice',
                               p_perf_msg                        => 'Status After Compute Price: ' ||
                                                                    l_return_status);

      IF l_return_status <> g_ret_sts_success THEN
        RAISE g_error;
      END IF;

      -- Bug Fix 4363689
      -- added SKEKKAR to prorate manually priced lines
      OPEN l_currcode_csr (p_reprice_rec.contract_id);

      FETCH l_currcode_csr
       INTO l_currency;

      CLOSE l_currcode_csr;

      l_period_type := l_period_type_orig;

      OPEN l_man_priced_lines_csr;

      LOOP
        FETCH l_man_priced_lines_csr
         INTO l_man_priced_line_rec;

        EXIT WHEN l_man_priced_lines_csr%NOTFOUND;

        BEGIN
               -- Step 1 : Skip Usage lines if not NPR
          -- Check if the line is usage and of type negotiated price
          IF l_man_priced_line_rec.lse_id = 13 THEN
            -- Initialize local variable so that it'll not mess up while looping
            l_usage_type               := NULL;

            --added by mchoudha for bug#5191528
            --for usage the period start should always be 'SERVICE'

            IF NVL (l_partial_period_flag, '!') = 'TRUE' THEN
              l_period_start             := 'SERVICE';
            END IF;


            OPEN l_usage_type_csr (l_man_priced_line_rec.cle_id);

            FETCH l_usage_type_csr
             INTO l_usage_type;

            CLOSE l_usage_type_csr;

            -- Prorate only if it is negotaietd price
            IF NVL (l_usage_type, '-99') <> 'NPR' THEN
              RAISE g_skip_proration;
            END IF;
          END IF;

          -- Step 2: Prorate all other manually priced lines
          get_oldcontractline_dates (p_cle_id                          => l_man_priced_line_rec.ID,
                                     p_opn_code                        => 'RENEWAL',
                                     x_old_start_date                  => l_old_start_date,
                                     x_old_end_date                    => l_old_end_date
                                    );

          --begin new logic for Partial Periods
          --If Partial period flag set,then calculate l_proprated_price_neg based on partial period logic
          IF NVL (l_partial_period_flag, '!') = 'TRUE' THEN
            l_prorated_price_neg       :=
              do_prorating_pp
                       (p_new_start_date                  => l_man_priced_line_rec.start_date,
                        p_new_end_date                    => l_man_priced_line_rec.end_date,
                        p_old_start_date                  => l_old_start_date,
                        p_old_end_date                    => l_old_end_date,
                        p_amount                          => l_man_priced_line_rec.price_negotiated,
                        p_period_type                     => l_period_type,
                        p_period_start                    => l_period_start
                       );
          ELSE
            l_prorated_price_neg       :=
              do_prorating
                       (p_new_start_date                  => l_man_priced_line_rec.start_date,
                        p_new_end_date                    => l_man_priced_line_rec.end_date,
                        p_old_start_date                  => l_old_start_date,
                        p_old_end_date                    => l_old_end_date,
                        p_amount                          => l_man_priced_line_rec.price_negotiated
                       );
          END IF;

          --end new logic for Partial Periods
          l_prorated_price_neg       :=  ROUND(l_prorated_price_neg,29); -- bug 5018782
          /*
            oks_extwar_util_pvt.round_currency_amt
                                            (p_amount                          => l_prorated_price_neg,
                                             p_currency_code                   => l_currency);
          */
          oks_renew_pvt.debug_log
                               (p_program_name                    => 'Reprice',
                                p_perf_msg                        => 'Prorated Negotiated Price: ' ||
                                                                     l_prorated_price_neg);
          --Update Manually priced Lines With the Prorated Amounts(Price Negotiated and Unit Price)
          l_clev_rec.ID              := l_man_priced_line_rec.ID;
          l_clev_rec.price_negotiated := l_prorated_price_neg;
          -- Update line's price negotiated only, unit price remains same.
          update_line (p_clev_rec                        => l_clev_rec,
                       x_return_status                   => l_return_status);
          oks_renew_pvt.debug_log
                              (p_program_name                    => 'Reprice',
                               p_perf_msg                        => 'Status after line updation: ' ||
                                                                    l_return_status);

          IF l_return_status <> g_ret_sts_success THEN
            RAISE g_error;
          END IF;

          calculate_tax (p_chr_id                          => p_reprice_rec.contract_id,
                         p_cle_id                          => l_man_priced_line_rec.ID,
                         p_amount                          => l_prorated_price_neg,
                         x_return_status                   => l_return_status
                        );
          oks_renew_pvt.debug_log (p_program_name                    => 'Reprice',
                                   p_perf_msg                        => 'Status after Tax: ' ||
                                                                        l_return_status);

          IF l_return_status <> g_ret_sts_success THEN
            RAISE g_error;
          END IF;
        EXCEPTION
          WHEN g_skip_proration THEN
            NULL;
        END;
      END LOOP;
      CLOSE l_man_priced_lines_csr;
         -- l_man_priced_lines_csr
    -- end added SKEKKAR to prorate manually priced lines
    ELSE
      -- price_type in 'MAN' or 'PCT'
      OPEN l_currcode_csr (p_reprice_rec.contract_id);

      FETCH l_currcode_csr
       INTO l_currency;

      CLOSE l_currcode_csr;

      OPEN l_line_csr;

      LOOP
        FETCH l_line_csr
         INTO l_line_rec;

        EXIT WHEN l_line_csr%NOTFOUND;

        BEGIN
          --added by mchoudha for bug#5191528
          --for usage the period start should always be 'SERVICE'
          --for effectivity based intnagible subscriptions period start should always be 'SERVICE'
          --for tangible subscriptions and subscription based intangible subscriptions
          --partial periods should be ignored as per CR1
          l_period_start := l_period_start_orig;
          l_period_type := l_period_type_orig;
          IF NVL (l_partial_period_flag, '!') = 'TRUE' THEN
            IF l_line_rec.lse_id = 12 THEN
              l_period_start := 'SERVICE';
            END IF;
            IF l_line_rec.lse_id = 46 THEN
              l_tangible  := OKS_SUBSCRIPTION_PUB.is_subs_tangible (l_line_rec.id);
              IF l_tangible THEN
                l_period_start := NULL;
                l_period_type := NULL;
              ELSE
                l_pricing_method :=FND_PROFILE.value('OKS_SUBS_PRICING_METHOD');
                IF nvl(l_pricing_method,'SUBSCRIPTION') <> 'EFFECTIVITY' THEN
                   l_period_start := NULL;
                   l_period_type := NULL;
                ELSE
                   l_period_start := 'SERVICE';
                END IF;  -- l_pricing_method <> 'EFFECTIVITY'
              END IF;    -- IF l_tangible
            END IF;      -- l_Line_Csr_Rec.lse_id = 46
          END IF;


          -- Check if the line is usage and of type negotiated price
          IF l_line_rec.lse_id = 13 THEN
            -- Initialize local variable so that it'll not mess up while looping
            l_usage_type               := NULL;

            OPEN l_usage_type_csr (l_line_rec.cle_id);

            FETCH l_usage_type_csr
             INTO l_usage_type;

            CLOSE l_usage_type_csr;

            -- Prorate only if it is negotaietd price
            IF NVL (l_usage_type, '-99') <> 'NPR' THEN
              RAISE g_skip_proration;
            END IF;
          END IF;

          --PRORATE AND OTHER STUFFS
          get_oldcontractline_dates (p_cle_id                          => l_line_rec.ID,
                                     p_opn_code                        => 'RENEWAL',
                                     x_old_start_date                  => l_old_start_date,
                                     x_old_end_date                    => l_old_end_date
                                    );
          oks_renew_pvt.debug_log (p_program_name                    => 'Reprice',
                                   p_perf_msg                        => 'Old Start Date: ' ||
                                                                        l_old_start_date ||
                                                                        ' Old End Date: ' ||
                                                                        l_old_end_date);

               --begin new logic for Partial Periods
          --If Partial period flag set,then calculate l_proprated_price_neg based on partial period logic
          IF NVL (l_partial_period_flag, '!') = 'TRUE' THEN
               --mchoudha for bug#5488312
               l_prorated_price_neg       :=
                  do_prorating_pp (
                               p_id                              => l_line_rec.id,
                               p_lse_id                          => l_line_rec.lse_id,
                               p_unit_price                      => l_line_rec.price_unit,
                               p_new_start_date                  => l_line_rec.start_date,
                               p_new_end_date                    => l_line_rec.end_date,
                               p_old_start_date                  => l_old_start_date,
                               p_old_end_date                    => l_old_end_date,
                               p_amount                          => l_line_rec.price_negotiated,
                               p_period_type                     => l_period_type,
                               p_period_start                    => l_period_start
                              );
          ELSE
            l_prorated_price_neg       :=
              do_prorating (p_new_start_date                  => l_line_rec.start_date,
                            p_new_end_date                    => l_line_rec.end_date,
                            p_old_start_date                  => l_old_start_date,
                            p_old_end_date                    => l_old_end_date,
                            p_amount                          => l_line_rec.price_negotiated
                           );
          END IF;

          --end new logic for Partial Periods
          l_prorated_price_neg       :=  ROUND(l_prorated_price_neg,29); -- bug 5018782
           /*
            oks_extwar_util_pvt.round_currency_amt
                                            (p_amount                          => l_prorated_price_neg,
                                             p_currency_code                   => l_currency);
            */
          oks_renew_pvt.debug_log
                               (p_program_name                    => 'Reprice',
                                p_perf_msg                        => 'Prorated Negotiated Price: ' ||
                                                                     l_prorated_price_neg);

          IF p_reprice_rec.price_type = 'MAN' THEN
            --Update Line With the Prorated Amounts(Price Negotiated and Unit Price)
            l_clev_rec.ID              := l_line_rec.ID;
            l_clev_rec.price_negotiated := l_prorated_price_neg;
            -- Update line's price negotiated only, unit price remains same.
            update_line (p_clev_rec                        => l_clev_rec,
                         x_return_status                   => l_return_status);
            oks_renew_pvt.debug_log
                             (p_program_name                    => 'Reprice',
                              p_perf_msg                        => 'Status after line updation: ' ||
                                                                   l_return_status);

            IF l_return_status <> g_ret_sts_success THEN
              RAISE g_error;
            END IF;

            calculate_tax (p_chr_id                          => p_reprice_rec.contract_id,
                           p_cle_id                          => l_line_rec.ID,
                           p_amount                          => l_prorated_price_neg,
                           x_return_status                   => l_return_status
                          );
            oks_renew_pvt.debug_log (p_program_name                    => 'Reprice',
                                     p_perf_msg                        => 'Status after Tax: ' ||
                                                                          l_return_status);

            IF l_return_status <> g_ret_sts_success THEN
              RAISE g_error;
            END IF;

            IF l_line_rec.lse_id IN (7, 9, 25, 46) THEN
              l_price_details.serv_ext_amount := l_prorated_price_neg;
              l_price_details.status_text :=
                                         'Price derived using manual pricing';

              IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level
                 ) THEN
                fnd_log.STRING (fnd_log.level_statement,
                                g_module ||
                                l_api_name,
                                '131:l_price_details.status_text: ' ||
                                l_price_details.status_text
                               );
                fnd_log.STRING (fnd_log.level_statement,
                                g_module ||
                                l_api_name,
                                '132:l_price_details.serv_ext_amount: ' ||
                                l_price_details.serv_ext_amount
                               );
              END IF;

              --errorout_urp('l_price_details.status_text: '     || l_price_details.status_text);
              --errorout_urp('l_price_details.serv_ext_amount: ' || l_price_details.serv_ext_amount);
              update_price_info (p_chr_id                          => p_reprice_rec.contract_id,
                                 p_cle_id                          => l_line_rec.ID,
                                 p_lse_id                          => l_line_rec.lse_id,
                                 p_price_type                      => p_reprice_rec.price_type,
                                 p_price_details                   => l_price_details,
                                 x_return_status                   => l_return_status
                                );
              oks_renew_pvt.debug_log
                      (p_program_name                    => 'Reprice',
                       p_perf_msg                        => 'Status after updating pricing info: ' ||
                                                            l_return_status);

              IF l_return_status <> g_ret_sts_success THEN
                RAISE g_error;
              END IF;
            END IF;
          ELSE                              -- Process PCT - Markup percentage
              -- bug 4886923 (forward port 4887983) skekkar
              -- prorate Unit price only if the subline is not item, product , subscription
              -- for any pricelist subline, unit price should NOT be prorated
           IF l_line_rec.lse_id IN(7,9,25,46) THEN
               -- unit price is same as the original contract
                l_prorated_unit_price:=  l_line_rec.price_unit;
           ELSE
             --begin new logic for Partial Periods
            --If Partial period flag set,then calculate l_proprated_unit_price based on partial period logic
            IF NVL (l_partial_period_flag, '!') = 'TRUE' THEN
              l_prorated_unit_price      :=
                do_prorating_pp (p_new_start_date                  => l_line_rec.start_date,
                                 p_new_end_date                    => l_line_rec.end_date,
                                 p_old_start_date                  => l_old_start_date,
                                 p_old_end_date                    => l_old_end_date,
                                 p_amount                          => l_line_rec.price_unit,
                                 p_period_type                     => l_period_type,
                                 p_period_start                    => l_period_start
                                );
            ELSE
              l_prorated_unit_price      :=
                do_prorating (p_new_start_date                  => l_line_rec.start_date,
                              p_new_end_date                    => l_line_rec.end_date,
                              p_old_start_date                  => l_old_start_date,
                              p_old_end_date                    => l_old_end_date,
                              p_amount                          => l_line_rec.price_unit
                             );
            END IF; -- partial_period_flag
          END IF; -- end added bug 4886923 (forward port 4887983) don't prorate unit price for pricelist items

            --end new logic for Partial Periods

            -- added skekkar
            -- PCT was NOT prorating manually priced lines with markup percentage
            -- IF l_line_rec.lse_id NOT IN (7, 9, 25, 46) THEN
            IF l_line_rec.lse_id IN (8, 10, 11, 13, 35) THEN  -- bug 4769124
              --for non priced lines, compute Prorated Amout and update
              --price negotiated
              l_prorated_price_neg       :=
                NVL (l_prorated_price_neg, 0) +
                ((NVL (l_prorated_price_neg, 0) *
                  NVL (p_reprice_rec.markup_percent, 0)
                 ) /
                 100
                );
              l_prorated_price_neg       :=  ROUND(l_prorated_price_neg,29); -- bug 5018782
               /*
                oks_extwar_util_pvt.round_currency_amt
                                            (p_amount                          => l_prorated_price_neg,
                                             p_currency_code                   => l_currency);
               */
            END IF;                --  l_line_rec.lse_id IN (8, 10, 11, 13, 35)

            -- end added skekkar

            --Update Line With the Prorated Amounts(Price Negotiated and Unit Price)
            l_clev_rec.ID              := l_line_rec.ID;
            l_clev_rec.price_negotiated := l_prorated_price_neg;
            l_clev_rec.price_unit      := l_prorated_unit_price;
            oks_renew_pvt.debug_log (p_program_name                    => 'Reprice',
                                     p_perf_msg                        => 'Prorated unit price: ' ||
                                                                          l_clev_rec.price_negotiated);
            update_line (p_clev_rec                        => l_clev_rec,
                         x_return_status                   => l_return_status);
            oks_renew_pvt.debug_log
                              (p_program_name                    => 'Reprice',
                               p_perf_msg                        => 'Status after updating line: ' ||
                                                                    l_return_status);

            IF l_return_status <> g_ret_sts_success THEN
              RAISE g_error;
            END IF;

            IF l_line_rec.lse_id IN (7, 9, 25, 46) THEN
              --Prorated Amout should markedup/down then pass to find the actual
              --price negotiated
              l_prorated_price_neg       :=
                NVL (l_prorated_price_neg, 0) +
                ((NVL (l_prorated_price_neg, 0) *
                  NVL (p_reprice_rec.markup_percent, 0)
                 ) /
                 100
                );
              l_prorated_price_neg       := ROUND(l_prorated_price_neg,29); -- bug 5018782
               /*
                oks_extwar_util_pvt.round_currency_amt
                                            (p_amount                          => l_prorated_price_neg,
                                             p_currency_code                   => l_currency);
                */
              oks_renew_pvt.debug_log (p_program_name                    => 'Reprice',
                                       p_perf_msg                        => 'Prorated price: ' ||
                                                                            l_prorated_price_neg);

              IF p_reprice_rec.price_list_id IS NOT NULL THEN
                IF l_line_rec.lse_id = 46 THEN
                  l_intent                   := 'LM';
                ELSE
                  l_intent                   := 'SM';
                END IF;

                calculate_price (p_chr_id                          => p_reprice_rec.contract_id,
                                 p_line_id                         => l_line_rec.ID,
                                 p_linecle_id                      => l_line_rec.cle_id,
                                 p_lse_id                          => l_line_rec.lse_id,
                                 p_intent                          => l_intent,
                                 p_price_type                      => 'PCT',
                                 p_price_list                      => p_reprice_rec.price_list_id,
                                 p_amount                          => l_prorated_price_neg,
                                 x_return_status                   => l_return_status
                                );
                oks_renew_pvt.debug_log
                            (p_program_name                    => 'Reprice',
                             p_perf_msg                        => 'Status after calculate_price: ' ||
                                                                  l_return_status);

                IF l_return_status <> g_ret_sts_success THEN
                  RAISE g_error;
                END IF;
              ELSE
                --Update Line With the Prorated Amounts(Price Negotiated and Unit Price)
                l_clev_rec.ID              := l_line_rec.ID;
                l_clev_rec.price_negotiated := l_prorated_price_neg;
                update_line (p_clev_rec                        => l_clev_rec,
                             x_return_status                   => l_return_status);
                oks_renew_pvt.debug_log
                             (p_program_name                    => 'Reprice',
                              p_perf_msg                        => 'Status after updating line: ' ||
                                                                   l_return_status);

                IF l_return_status <> g_ret_sts_success THEN
                  RAISE g_error;
                END IF;

                l_price_details.serv_ext_amount := l_prorated_price_neg;
                l_price_details.status_text :=
                                          'Price derived using markup pricing';

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level
                   ) THEN
                  fnd_log.STRING (fnd_log.level_statement,
                                  g_module ||
                                  l_api_name,
                                  '133:l_price_details.status_text: ' ||
                                  l_price_details.status_text
                                 );
                  fnd_log.STRING (fnd_log.level_statement,
                                  g_module ||
                                  l_api_name,
                                  '134:l_price_details.serv_ext_amount: ' ||
                                  l_price_details.serv_ext_amount
                                 );
                END IF;

                --errorout_urp('l_price_details.status_text: '     || l_price_details.status_text);
                --errorout_urp('l_price_details.serv_ext_amount: ' || l_price_details.serv_ext_amount);
                update_price_info (p_chr_id                          => p_reprice_rec.contract_id,
                                   p_cle_id                          => l_line_rec.ID,
                                   p_lse_id                          => l_line_rec.lse_id,
                                   p_price_type                      => p_reprice_rec.price_type,
                                   p_price_details                   => l_price_details,
                                   x_return_status                   => l_return_status
                                  );
                oks_renew_pvt.debug_log
                  (p_program_name                    => 'Reprice',
                   p_perf_msg                        => 'Status in CP2 API in PCT where PL is NULL: ' ||
                                                        l_return_status);

                IF l_return_status <> g_ret_sts_success THEN
                  RAISE g_error;
                END IF;

                -- Update Subsciption elements
                IF l_line_rec.lse_id = 46 THEN
                  FOR l_subs_elements_rec IN
                    l_subs_elements_csr (NVL (l_line_rec.cle_id,
                                              l_line_rec.ID)) LOOP
                    l_scev_rec_in.ID           := l_subs_elements_rec.ID;
                    l_scev_rec_in.amount       :=
                         l_subs_elements_rec.quantity *
                         l_prorated_unit_price;
                    l_scev_rec_in.object_version_number :=
                                     l_subs_elements_rec.object_version_number;
                    oks_subscr_elems_pub.update_row
                                          (p_api_version                     => l_api_version,
                                           p_init_msg_list                   => l_init_msg_list,
                                           x_return_status                   => l_return_status,
                                           x_msg_count                       => l_msg_count,
                                           x_msg_data                        => l_msg_data,
                                           p_scev_rec                        => l_scev_rec_in,
                                           x_scev_rec                        => l_scev_rec_out
                                          );
                    oks_renew_pvt.debug_log
                      (p_program_name                    => 'Reprice',
                       p_perf_msg                        => 'Status after updating Subscription elements: ' ||
                                                            l_return_status);

                    IF l_return_status <> g_ret_sts_success THEN
                      RAISE g_error;
                    END IF;
                  END LOOP;
                END IF;

                --Calculate Tax For Toplines(All Covered Levels for Service
                --and Extended Warranty)
                calculate_tax (p_chr_id                          => p_reprice_rec.contract_id,
                               p_cle_id                          => l_line_rec.ID,
                               p_amount                          => l_prorated_price_neg,
                               x_return_status                   => l_return_status
                              );
                oks_renew_pvt.debug_log
                                       (p_program_name                    => 'Reprice',
                                        p_perf_msg                        => 'Status after Tax - ' ||
                                                                             l_return_status);

                IF l_return_status <> g_ret_sts_success THEN
                  RAISE g_error;
                END IF;
              END IF;
            ELSE
              calculate_tax (p_chr_id                          => p_reprice_rec.contract_id,
                             p_cle_id                          => l_line_rec.ID,
                             p_amount                          => l_prorated_price_neg,
                             x_return_status                   => l_return_status
                            );
              oks_renew_pvt.debug_log (p_program_name                    => 'Reprice',
                                       p_perf_msg                        => 'Status after Tax = ' ||
                                                                            l_return_status);

              IF l_return_status <> g_ret_sts_success THEN
                RAISE g_error;
              END IF;                           -- Status Check after Tax Call
            END IF;                 -- Lse If check within price type <> 'MAN'
          END IF;                                                -- Price Type

          -- end debug log
          IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
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
          WHEN g_skip_proration THEN
            -- end debug log
            IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
              fnd_log.STRING (fnd_log.level_procedure,
                              g_module ||
                              l_api_name,
                              '9200: Leaving ' ||
                              g_pkg_name ||
                              '.' ||
                              l_api_name
                             );
            END IF;

            NULL;
        END;
      END LOOP;                                         -- Loop For linecursor

      CLOSE l_line_csr;

      --FOR MAN and PCT the simple api is called and it will not update the amounts of the contract
      --Because of this update_amounts need to be called....
      update_amounts (p_chr_id                          => p_reprice_rec.contract_id,
                      x_return_status                   => l_return_status);
      oks_renew_pvt.debug_log
                           (p_program_name                    => 'Reprice',
                            p_perf_msg                        => 'Status after updating amounts: ' ||
                                                                 l_return_status);

      IF l_return_status <> g_ret_sts_success THEN
        RAISE g_error;
      END IF;
    END IF;                                              --For Price List(LST)

    x_return_status            := l_return_status;
    oks_renew_pvt.debug_log (p_program_name                    => 'Reprice',
                             p_perf_msg                        => 'Final Status: ' ||
                                                                  l_return_status);

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
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
    WHEN g_error THEN
      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '2500: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      DBMS_TRANSACTION.rollback_savepoint ('REPRICE_OKS');

      IF l_line_csr%ISOPEN THEN
        CLOSE l_line_csr;
      END IF;

      x_return_status            := l_return_status;
    WHEN OTHERS THEN
      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
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
      DBMS_TRANSACTION.rollback_savepoint ('REPRICE_OKS');
      okc_api.set_message (p_app_name                        => g_app_name_oks,
                           p_msg_name                        => g_unexpected_error,
                           p_token1                          => g_sqlcode_token,
                           p_token1_value                    => SQLCODE,
                           p_token2                          => g_sqlerrm_token,
                           p_token2_value                    => SQLERRM
                          );
      x_return_status            := g_ret_sts_unexp_error;
  END call_pricing_api;

  -- Pricing API for Renewal consolidation
  PROCEDURE call_pricing_api (
    p_api_version                    IN       NUMBER,
    p_init_msg_list                  IN       VARCHAR2,
    x_return_status                  OUT NOCOPY VARCHAR2,
    x_msg_count                      OUT NOCOPY NUMBER,
    x_msg_data                       OUT NOCOPY VARCHAR2,
    p_subject_chr_id                 IN       NUMBER,
    p_subject_top_line_id            IN       NUMBER,
    p_subject_sub_line_tbl           IN       sub_line_tbl_type
  ) IS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                                        := 'call_pricing_api';

    CURSOR l_k_details_csr (
      p_chr_id                                  NUMBER
    ) IS
      SELECT currency_code,
             price_list_id
        FROM okc_k_headers_all_b
       WHERE ID = p_chr_id;

    CURSOR l_srv_k_details_csr (
      p_chr_id                                  NUMBER
    ) IS
      SELECT renewal_price_list,
             'LST' AS renewal_pricing_type, -- Bug 6016714
             renewal_markup_percent,
             chr_id,
             ID
        FROM oks_k_headers_b
       WHERE chr_id = p_chr_id;

    CURSOR l_line_csr (
      p_line_id                                 NUMBER
    ) IS
      SELECT ID,
             start_date,
             end_date,
             lse_id,
             price_negotiated,
             price_unit,
             cle_id,
             dnz_chr_id
        FROM okc_k_lines_b
       WHERE ID = p_line_id;

    CURSOR l_usage_type_csr (
      p_cle_id                                  NUMBER
    ) IS
      SELECT usage_type
        FROM oks_k_lines_b
       WHERE cle_id = p_cle_id;

    CURSOR l_subs_elements_csr (
      p_line_id                                 NUMBER
    ) IS
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
    -- Added by Jvorugan

    -- Bug 5337890

    l_new_duration                             NUMBER;
    l_tangible        BOOLEAN;
    l_pricing_method Varchar2(30);

-- End of changes by Jvorugan


    l_prorated_price_neg                    NUMBER;
    l_prorated_unit_price                   NUMBER;
    l_msg_count                             NUMBER;
    l_index_sub_line_tbl                    NUMBER;
    l_api_version                           NUMBER := 1.0;
    l_msg_data                              VARCHAR2 (2000);
    l_usage_type                            VARCHAR2 (10);
    l_currency                              VARCHAR2 (15);
    l_intent                                VARCHAR2 (10);
    l_init_msg_list                         VARCHAR2 (1) := okc_api.g_false;
    l_return_status                         VARCHAR2 (1) := g_ret_sts_success;
    l_old_start_date                        DATE;
    l_old_end_date                          DATE;
    l_clev_rec                              okc_contract_pub.clev_rec_type;
    l_chr_rec_in                            okc_contract_pub.chrv_rec_type;
    l_chr_rec_out                           okc_contract_pub.chrv_rec_type;
    l_scev_rec_in                           oks_subscr_elems_pub.scev_rec_type;
    l_scev_rec_out                          oks_subscr_elems_pub.scev_rec_type;
    l_modifier_details                      qp_preq_grp.line_detail_tbl_type;
    l_detail_rec                            oks_qp_pkg.input_details;
    l_price_break_details                   oks_qp_pkg.g_price_break_tbl_type;
    l_price_details                         oks_qp_pkg.price_details := NULL;
    l_k_details_rec                         l_k_details_csr%ROWTYPE;
    l_srv_k_details_rec                     l_srv_k_details_csr%ROWTYPE;
    l_line_rec                              l_line_csr%ROWTYPE;
    --new variables for partial periods
    l_period_type                           VARCHAR2 (30);
    l_period_start                          VARCHAR2 (30);
    l_price_uom                             VARCHAR2 (30);
    l_partial_period_flag                   VARCHAR2 (10);
    l_period_type_orig                      VARCHAR2 (30);
    l_period_start_orig                     VARCHAR2 (30);
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    fnd_file.put_line(FND_FILE.LOG,'  ');
    fnd_file.put_line(FND_FILE.LOG,'********************************************************** ');
    fnd_file.put_line(FND_FILE.LOG,'---------------------------------------------------------- ');
    fnd_file.put_line(FND_FILE.LOG,'Inside PROCEDURE call_pricing_api for Renewal consolidation');
    fnd_file.put_line(FND_FILE.LOG,'p_subject_chr_id : '||p_subject_chr_id);
    fnd_file.put_line(FND_FILE.LOG,'p_subject_top_line_id : '||p_subject_top_line_id);
    fnd_file.put_line(FND_FILE.LOG,'p_subject_sub_line_tbl.COUNT : '||p_subject_sub_line_tbl.COUNT);
    fnd_file.put_line(FND_FILE.LOG,'---------------------------------------------------------- ');
    fnd_file.put_line(FND_FILE.LOG,'  ');

    DBMS_TRANSACTION.SAVEPOINT ('REPRICE_OKS');

    OPEN l_k_details_csr (p_subject_chr_id);
    FETCH l_k_details_csr
     INTO l_k_details_rec;
    CLOSE l_k_details_csr;

    fnd_file.put_line(FND_FILE.LOG,'l_k_details_rec.price_list_id : '||l_k_details_rec.price_list_id);
    fnd_file.put_line(FND_FILE.LOG,'l_k_details_rec.currency_code : '||l_k_details_rec.currency_code);

    OPEN l_srv_k_details_csr (p_subject_chr_id);
    FETCH l_srv_k_details_csr
     INTO l_srv_k_details_rec;
    CLOSE l_srv_k_details_csr;

    fnd_file.put_line(FND_FILE.LOG,'l_srv_k_details_rec.renewal_pricing_type : '||l_srv_k_details_rec.renewal_pricing_type);
    fnd_file.put_line(FND_FILE.LOG,'l_srv_k_details_rec.renewal_price_list : '||l_srv_k_details_rec.renewal_price_list);
    fnd_file.put_line(FND_FILE.LOG,'l_srv_k_details_rec.renewal_markup_percent : '||l_srv_k_details_rec.renewal_markup_percent);

    oks_renew_pvt.debug_log
                       (p_program_name                    => 'Renewal Consolidation Reprice::',
                        p_perf_msg                        => 'PRICING TYPE = ' ||
                                                             l_srv_k_details_rec.renewal_pricing_type);
    oks_renew_pvt.debug_log
                         (p_program_name                    => 'Renewal Consolidation Reprice::',
                          p_perf_msg                        => 'PRICE LIST = ' ||
                                                               l_srv_k_details_rec.renewal_price_list);
    oks_renew_pvt.debug_log
                     (p_program_name                    => 'Renewal Consolidation Reprice::',
                      p_perf_msg                        => 'MARKUP = ' ||
                                                           l_srv_k_details_rec.renewal_markup_percent);

    IF l_srv_k_details_rec.renewal_pricing_type = 'LST' THEN
      l_chr_rec_in.ID            := p_subject_chr_id;
      l_chr_rec_in.price_list_id := l_k_details_rec.price_list_id;
      l_currency                 := l_k_details_rec.currency_code;
      oks_renew_pvt.debug_log
                  (p_program_name                    => 'Renewal Consolidation Reprice::',
                   p_perf_msg                        => 'Pricing type - Price List - Header Pricing');

      fnd_file.put_line(FND_FILE.LOG,'renewal_pricing_type = LST, Calling okc_contract_pub.update_contract_header');

      okc_contract_pub.update_contract_header
                                         (p_api_version                     => l_api_version,
                                          p_init_msg_list                   => l_init_msg_list,
                                          x_return_status                   => l_return_status,
                                          x_msg_count                       => l_msg_count,
                                          x_msg_data                        => l_msg_data,
                                          p_restricted_update               => 'N',
                                          p_chrv_rec                        => l_chr_rec_in,
                                          x_chrv_rec                        => l_chr_rec_out
                                         );

      fnd_file.put_line(FND_FILE.LOG,'AFTER Calling okc_contract_pub.update_contract_header x_return_status= '||l_return_status);

      oks_renew_pvt.debug_log
                         (p_program_name                    => 'Renewal Consolidation Reprice::',
                          p_perf_msg                        => 'UPDATE CONTRACT HDR - RETURN = ' ||
                                                               l_return_status);

      IF l_return_status <> g_ret_sts_success THEN
        RAISE g_error;
      END IF;

      l_detail_rec.chr_id        := p_subject_chr_id;
      -- bug 6114024 , changed the intent to HP as before as the call
      -- to pricing api will be done once for the whole contract in OKS_RENCON_PVT

      l_detail_rec.intent        := 'HP';

      -- Bug 6016714
      -- l_detail_rec.line_id       := p_subject_top_line_id;
      -- l_detail_rec.intent        := 'LP';
      -- end added bug 6016714

      oks_renew_pvt.debug_log
                         (p_program_name                    => 'Renewal Consolidation Reprice::',
                          p_perf_msg                        => 'HDR PRICING - CONTRACT ID= ' ||
                                                               l_detail_rec.chr_id);

      fnd_file.put_line(FND_FILE.LOG,'Calling oks_qp_int_pvt.compute_price ');

      --This api will take care about updating the amounts of the contract.
      oks_qp_int_pvt.compute_price
                              (p_api_version                     => p_api_version,
                               p_init_msg_list                   => p_init_msg_list,
                               p_detail_rec                      => l_detail_rec,
                               x_price_details                   => l_price_details,
                               x_modifier_details                => l_modifier_details,
                               x_price_break_details             => l_price_break_details,
                               x_return_status                   => l_return_status,
                               x_msg_count                       => l_msg_count,
                               x_msg_data                        => l_msg_data
                              );

      fnd_file.put_line(FND_FILE.LOG,'AFTER Calling oks_qp_int_pvt.compute_price x_return_status= '||l_return_status);

      oks_renew_pvt.debug_log
                         (p_program_name                    => 'Renewal Consolidation Reprice::',
                          p_perf_msg                        => 'HDR REPRICE - RETURN = ' ||
                                                               l_return_status);

      IF l_return_status <> g_ret_sts_success THEN
        RAISE g_error;
      END IF;
    ELSE
      -- Renewal Price type is Manual or Markup. Each line has price to be updated individually.
     fnd_file.put_line(FND_FILE.LOG,'Renewal Price type is Manual or Markup');

      oks_renew_pvt.debug_log
           (p_program_name                    => 'Renewal Consolidation Reprice::',
            p_perf_msg                        => 'NON PRICE LIST REPRICE - LINE/SUBLINE COUNT = ' ||
                                                 p_subject_sub_line_tbl.COUNT);
      --begin new logic for Partial Periods
      oks_renew_util_pub.get_period_defaults
                                           (p_hdr_id                          => p_subject_chr_id,
                                            p_org_id                          => NULL,
                                            x_period_type                     => l_period_type_orig,
                                            x_period_start                    => l_period_start_orig,
                                            x_price_uom                       => l_price_uom,
                                            x_return_status                   => l_return_status
                                           );

     fnd_file.put_line(FND_FILE.LOG,'After Calling oks_renew_util_pub.get_period_defaults ');
     fnd_file.put_line(FND_FILE.LOG,' x_return_status = '||l_return_status);
     fnd_file.put_line(FND_FILE.LOG,' x_period_type = '||l_period_type_orig);
     fnd_file.put_line(FND_FILE.LOG,' x_period_start = '||l_period_start_orig);
     fnd_file.put_line(FND_FILE.LOG,' x_price_uom = '||l_price_uom);

      IF l_return_status <> g_ret_sts_success THEN
        RAISE g_error;
      END IF;

      IF     l_period_start_orig IS NOT NULL
         AND l_period_type_orig IS NOT NULL THEN
        l_partial_period_flag      := 'TRUE';
      ELSE
        l_partial_period_flag      := 'FALSE';
      END IF;

      --end  new logic for Partial Periods
      l_index_sub_line_tbl       := p_subject_sub_line_tbl.FIRST;

      IF p_subject_sub_line_tbl.COUNT > 0 THEN
        LOOP
          BEGIN
            OPEN l_line_csr (p_subject_sub_line_tbl (l_index_sub_line_tbl));

            FETCH l_line_csr
             INTO l_line_rec;

            CLOSE l_line_csr;

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'---------------------------------------------------------- ');
            fnd_file.put_line(FND_FILE.LOG,'l_line_rec.ID : '||l_line_rec.ID);
            fnd_file.put_line(FND_FILE.LOG,'l_line_rec.start_date : '||l_line_rec.start_date);
            fnd_file.put_line(FND_FILE.LOG,'l_line_rec.end_date : '||l_line_rec.end_date);
            fnd_file.put_line(FND_FILE.LOG,'l_line_rec.lse_id : '||l_line_rec.lse_id);
            fnd_file.put_line(FND_FILE.LOG,'l_line_rec.price_negotiated : '||l_line_rec.price_negotiated);
            fnd_file.put_line(FND_FILE.LOG,'l_line_rec.price_unit : '||l_line_rec.price_unit);
            fnd_file.put_line(FND_FILE.LOG,'l_line_rec.cle_id : '||l_line_rec.cle_id);
            fnd_file.put_line(FND_FILE.LOG,'l_line_rec.dnz_chr_id : '||l_line_rec.dnz_chr_id);
            fnd_file.put_line(FND_FILE.LOG,'---------------------------------------------------------- ');
            fnd_file.put_line(FND_FILE.LOG,'  ');

            oks_renew_pvt.debug_log
               (p_program_name                    => 'Renewal Consolidation Reprice::',
                p_perf_msg                        => 'NON PRICE LIST REPRICE - LINE/SUBLINE ID = ' ||
                                                     l_line_rec.ID);
            oks_renew_pvt.debug_log
              (p_program_name                    => 'Renewal Consolidation Reprice::',
               p_perf_msg                        => 'NON PRICE LIST REPRICE - LINE/SUBLINE LSE ID = ' ||
                                                    l_line_rec.lse_id);
            --added by mchoudha for bug#5191528
            --for usage the period start should always be 'SERVICE'
            --for effectivity based intnagible subscriptions period start should always be 'SERVICE'
            --for tangible subscriptions and subscription based intangible subscriptions
            --partial periods should be ignored as per CR1
            l_period_start := l_period_start_orig;
            l_period_type := l_period_type_orig;
            IF NVL (l_partial_period_flag, '!') = 'TRUE' THEN
              IF l_line_rec.lse_id = 12 THEN
                l_period_start := 'SERVICE';
              END IF;
              IF l_line_rec.lse_id = 46 THEN
                l_tangible  := OKS_SUBSCRIPTION_PUB.is_subs_tangible (l_line_rec.id);
                IF l_tangible THEN

                  l_period_start := NULL;
                  l_period_type := NULL;
                ELSE
                  l_pricing_method :=FND_PROFILE.value('OKS_SUBS_PRICING_METHOD');
                  IF nvl(l_pricing_method,'SUBSCRIPTION') <> 'EFFECTIVITY' THEN
                    l_period_start := NULL;
                    l_period_type := NULL;
                  ELSE
                    l_period_start := 'SERVICE';
                  END IF;  -- l_pricing_method <> 'EFFECTIVITY'
                END IF;    -- IF l_tangible
              END IF;      -- l_Line_Csr_Rec.lse_id = 46
            END IF;


            -- Check if the line is usage and of type negotiated price
            IF l_line_rec.lse_id = 13 THEN
              -- Initialize local variable so that it'll not mess up while looping
              l_usage_type               := NULL;

              OPEN l_usage_type_csr (l_line_rec.cle_id);

              FETCH l_usage_type_csr
               INTO l_usage_type;

              CLOSE l_usage_type_csr;

              -- Prorate only if it is negotaietd price
              IF NVL (l_usage_type, '-99') <> 'NPR' THEN
                oks_renew_pvt.debug_log
                  (p_program_name                    => 'Renewal Consolidation Reprice::',
                   p_perf_msg                        => 'Usage Line of type non negotiated - so no proration');
                RAISE g_skip_proration;
              END IF;
            END IF;

            --PRORATE AND OTHER STUFFS
            get_oldcontractline_dates (p_cle_id                          => l_line_rec.ID,
                                       p_opn_code                        => 'REN_CON',
                                       x_old_start_date                  => l_old_start_date,
                                       x_old_end_date                    => l_old_end_date
                                      );

            fnd_file.put_line(FND_FILE.LOG,'l_old_start_date= '||l_old_start_date);
            fnd_file.put_line(FND_FILE.LOG,'l_old_end_date= '||l_old_end_date);

            oks_renew_pvt.debug_log
                         (p_program_name                    => 'Renewal Consolidation Reprice::',
                          p_perf_msg                        => 'LINE OLD START DATE = ' ||
                                                               l_old_start_date);
            oks_renew_pvt.debug_log
                         (p_program_name                    => 'Renewal Consolidation Reprice::',
                          p_perf_msg                        => 'LINE OLD END DATE = ' ||
                                                               l_old_end_date);
            oks_renew_pvt.debug_log
                         (p_program_name                    => 'Renewal Consolidation Reprice::',
                          p_perf_msg                        => 'LINE START DATE = ' ||
                                                               l_line_rec.start_date);
            oks_renew_pvt.debug_log
                         (p_program_name                    => 'Renewal Consolidation Reprice::',
                          p_perf_msg                        => 'LINE END DATE = ' ||
                                                               l_line_rec.end_date);

                 --begin new logic for Partial Periods
            --If Partial period flag set,then calculate l_proprated_price_neg based on partial period logic
            IF NVL (l_partial_period_flag, '!') = 'TRUE' THEN

                fnd_file.put_line(FND_FILE.LOG,'Calling do_prorating_pp');
	        --mchoudha for bug#5488312
                l_prorated_price_neg       :=
                do_prorating_pp (p_id                              => l_line_rec.id,
                                 p_lse_id                          => l_line_rec.lse_id,
                                 p_unit_price                      => l_line_rec.price_unit,
                                 p_new_start_date                  => l_line_rec.start_date,
                                 p_new_end_date                    => l_line_rec.end_date,
                                 p_old_start_date                  => l_old_start_date,
                                 p_old_end_date                    => l_old_end_date,
                                 p_amount                          => l_line_rec.price_negotiated,
                                 p_period_type                     => l_period_type,
                                 p_period_start                    => l_period_start
                                );

              fnd_file.put_line(FND_FILE.LOG,'AFTER Calling do_prorating_pp l_prorated_price_neg = '||l_prorated_price_neg);
            ELSE

                fnd_file.put_line(FND_FILE.LOG,'Calling do_prorating');

              l_prorated_price_neg       :=
                do_prorating (p_new_start_date                  => l_line_rec.start_date,
                              p_new_end_date                    => l_line_rec.end_date,
                              p_old_start_date                  => l_old_start_date,
                              p_old_end_date                    => l_old_end_date,
                              p_amount                          => l_line_rec.price_negotiated
                             );
              fnd_file.put_line(FND_FILE.LOG,'AFTER Calling do_prorating l_prorated_price_neg = '||l_prorated_price_neg);
            END IF;

            -- end new logic for partial periods
            oks_renew_pvt.debug_log
                         (p_program_name                    => 'Renewal Consolidation Reprice::',
                          p_perf_msg                        => 'PRORATED AMOUNT = ' ||
                                                               l_prorated_price_neg);
            oks_renew_pvt.debug_log
                         (p_program_name                    => 'Renewal Consolidation Reprice::',
                          p_perf_msg                        => 'MULTI CURRENCY CODE = ' ||
                                                               l_currency);
            l_prorated_price_neg       :=  ROUND(l_prorated_price_neg,29); -- bug 5018782

            fnd_file.put_line(FND_FILE.LOG,'Round l_prorated_price_neg = '||l_prorated_price_neg);

             /*
              oks_extwar_util_pvt.round_currency_amt
                                            (p_amount                          => l_prorated_price_neg,
                                             p_currency_code                   => l_currency);
              */
            oks_renew_pvt.debug_log
              (p_program_name                    => 'Renewal Consolidation Reprice::',
               p_perf_msg                        => 'PRORATED AMOUNT FOR MULTI CURRENCY CURRENCY = ' ||
                                                    l_prorated_price_neg);

            IF l_srv_k_details_rec.renewal_pricing_type = 'MAN' THEN
              fnd_file.put_line(FND_FILE.LOG,'l_srv_k_details_rec.renewal_pricing_type = MANUAL');
              oks_renew_pvt.debug_log
                        (p_program_name                    => 'Renewal Consolidation Reprice::',
                         p_perf_msg                        => 'Pricing type is manual');
              --Update Line With the Prorated Amounts(Price Negotiated and Unit Price)
              l_clev_rec.ID              := l_line_rec.ID;
              l_clev_rec.price_negotiated := l_prorated_price_neg;
              -- Update line's price negotiated only, unit price remains same.
              update_line (p_clev_rec                        => l_clev_rec,
                           x_return_status                   => l_return_status);

              fnd_file.put_line(FND_FILE.LOG,'After update_line l_return_status = '||l_return_status);

              oks_renew_pvt.debug_log
                        (p_program_name                    => 'Renewal Consolidation Reprice::',
                         p_perf_msg                        => 'UPDATE LINE (MAN) - RETURN = ' ||
                                                              l_return_status);

              IF l_return_status <> g_ret_sts_success THEN
                RAISE g_error;
              END IF;

              calculate_tax (p_chr_id                          => l_line_rec.dnz_chr_id,
                             p_cle_id                          => l_line_rec.ID,
                             p_amount                          => l_prorated_price_neg,
                             x_return_status                   => l_return_status
                            );
              oks_renew_pvt.debug_log
                         (p_program_name                    => 'Renewal Consolidation Reprice::',
                          p_perf_msg                        => 'CALCUALTE TAX - RETURN = ' ||
                                                               l_return_status);

              fnd_file.put_line(FND_FILE.LOG,'After calculate_tax l_return_status = '||l_return_status);

              IF l_return_status <> g_ret_sts_success THEN
                RAISE g_error;
              END IF;

              IF l_line_rec.lse_id IN (7, 9, 25, 46) THEN
                oks_renew_pvt.debug_log
                  (p_program_name                    => 'Renewal Consolidation Reprice::',
                   p_perf_msg                        => 'Covered Item, Product or Subscription (man)');
                l_price_details.serv_ext_amount := l_prorated_price_neg;
                l_price_details.status_text :=
                                         'Price derived using manual pricing';
                update_price_info
                   (p_chr_id                          => l_line_rec.dnz_chr_id,
                    p_cle_id                          => l_line_rec.ID,
                    p_lse_id                          => l_line_rec.lse_id,
                    p_price_type                      => l_srv_k_details_rec.renewal_pricing_type,
                    p_price_details                   => l_price_details,
                    x_return_status                   => l_return_status
                   );
                oks_renew_pvt.debug_log
                         (p_program_name                    => 'Renewal Consolidation Reprice::',
                          p_perf_msg                        => 'UPDATE PRICE INFO - RETURN = ' ||
                                                               l_return_status);

                fnd_file.put_line(FND_FILE.LOG,'After update_price_info l_return_status = '||l_return_status);

                IF l_return_status <> g_ret_sts_success THEN
                  RAISE g_error;
                END IF;
              END IF;
            ELSE                            -- Process PCT - Markup percentage
              fnd_file.put_line(FND_FILE.LOG,'Renewal Process PCT - Markup percentage');
              oks_renew_pvt.debug_log
                        (p_program_name                    => 'Renewal Consolidation Reprice::',
                         p_perf_msg                        => 'Pricing type is manual');

               --begin new logic for Partial Periods
              --If Partial period flag set,then calculate l_prorated_unit_price based on partial period logic
              IF NVL (l_partial_period_flag, '!') = 'TRUE' THEN
                fnd_file.put_line(FND_FILE.LOG,'Calling do_prorating_pp');
                l_prorated_unit_price      :=
                  do_prorating_pp (p_new_start_date                  => l_line_rec.start_date,
                                   p_new_end_date                    => l_line_rec.end_date,
                                   p_old_start_date                  => l_old_start_date,
                                   p_old_end_date                    => l_old_end_date,
                                   p_amount                          => l_line_rec.price_unit,
                                   p_period_type                     => l_period_type,
                                   p_period_start                    => l_period_start
                                  );
               fnd_file.put_line(FND_FILE.LOG,'AFTER Calling do_prorating_pp l_prorated_unit_price = '||l_prorated_unit_price);
              ELSE
                fnd_file.put_line(FND_FILE.LOG,'Calling do_prorating');
                l_prorated_unit_price      :=
                  do_prorating (p_new_start_date                  => l_line_rec.start_date,
                                p_new_end_date                    => l_line_rec.end_date,
                                p_old_start_date                  => l_old_start_date,
                                p_old_end_date                    => l_old_end_date,
                                p_amount                          => l_line_rec.price_unit
                               );
               fnd_file.put_line(FND_FILE.LOG,'AFTER Calling do_prorating l_prorated_unit_price = '||l_prorated_unit_price);
              END IF;

              --End new logic for partial periods
              oks_renew_pvt.debug_log
                         (p_program_name                    => 'Renewal Consolidation Reprice::',
                          p_perf_msg                        => 'PRORATED UNIT PRICE = ' ||
                                                               l_prorated_unit_price);
              --Update Line With the Prorated Amounts(Price Negotiated and Unit Price)
              l_clev_rec.ID              := l_line_rec.ID;
              l_clev_rec.price_negotiated := l_prorated_price_neg;
              l_clev_rec.price_unit      := l_prorated_unit_price;
              update_line (p_clev_rec                        => l_clev_rec,
                           x_return_status                   => l_return_status);
              fnd_file.put_line(FND_FILE.LOG,'After update_line l_return_status = '||l_return_status);
              oks_renew_pvt.debug_log
                         (p_program_name                    => 'Renewal Consolidation Reprice::',
                          p_perf_msg                        => 'UPDATE LINE (PCT) - RETURN = ' ||
                                                               l_return_status);

              IF l_return_status <> g_ret_sts_success THEN
                RAISE g_error;
              END IF;

              IF l_line_rec.lse_id IN (7, 9, 25, 46) THEN
                              -- if covered item is item, product, suscription
                oks_renew_pvt.debug_log
                  (p_program_name                    => 'Renewal Consolidation Reprice::',
                   p_perf_msg                        => 'Covered Item, Product or Subscription (pct)');
                --Prorated Amout should markedup/down then pass to find the actual
                --price negotiated
                l_prorated_price_neg       :=
                  NVL (l_prorated_price_neg, 0) +
                  ((NVL (l_prorated_price_neg, 0) *
                    NVL (l_srv_k_details_rec.renewal_markup_percent, 0)
                   ) /
                   100
                  );
                oks_renew_pvt.debug_log
                         (p_program_name                    => 'Renewal Consolidation Reprice::',
                          p_perf_msg                        => 'MARKED UP PRICE = ' ||
                                                               l_prorated_price_neg);
                l_prorated_price_neg       :=  ROUND(l_prorated_price_neg,29); -- bug 5018782

                fnd_file.put_line(FND_FILE.LOG,'Round l_prorated_price_neg = '||l_prorated_price_neg);
                /*
                  oks_extwar_util_pvt.round_currency_amt
                                            (p_amount                          => l_prorated_price_neg,
                                             p_currency_code                   => l_currency);
                 */
                oks_renew_pvt.debug_log
                    (p_program_name                    => 'Renewal Consolidation Reprice::',
                     p_perf_msg                        => 'MARKED UP PRICE MULTI CURRENCY CODE = ' ||
                                                          l_currency);

                IF l_srv_k_details_rec.renewal_price_list IS NOT NULL THEN
                  fnd_file.put_line(FND_FILE.LOG,'l_srv_k_details_rec.renewal_price_list IS NOT NULL');
                  oks_renew_pvt.debug_log
                        (p_program_name                    => 'Renewal Consolidation Reprice::',
                         p_perf_msg                        => 'Renewal PL is null (pct)');

                  IF l_line_rec.lse_id = 46 THEN
                    l_intent                   := 'LM';
                  ELSE
                    l_intent                   := 'SM';
                  END IF;

                 fnd_file.put_line(FND_FILE.LOG,'Calling calculate_price');
                  calculate_price
                      (p_chr_id                          => l_line_rec.dnz_chr_id,
                       p_line_id                         => l_line_rec.ID,
                       p_linecle_id                      => l_line_rec.cle_id,
                       p_lse_id                          => l_line_rec.lse_id,
                       p_intent                          => l_intent,
                       p_price_type                      => 'PCT',
                       p_price_list                      => l_srv_k_details_rec.renewal_price_list,
                       p_amount                          => l_prorated_price_neg,
                       x_return_status                   => l_return_status
                      );

                 fnd_file.put_line(FND_FILE.LOG,'AFTER Calling calculate_price l_return_status = '||l_return_status);

                  oks_renew_pvt.debug_log
                    (p_program_name                    => 'Renewal Consolidation Reprice::',
                     p_perf_msg                        => 'CALC PRICE FOR MARKUP WITH PL - RETURN = ' ||
                                                          l_return_status);
                  oks_renew_pvt.debug_log
                    (p_program_name                    => 'Renewal Consolidation Reprice::',
                     p_perf_msg                        => 'CALC PRICE FOR MARKUP WITH PL - AMOUNT = ' ||
                                                          l_prorated_price_neg);

                  IF l_return_status <> g_ret_sts_success THEN
                    RAISE g_error;
                  END IF;
                ELSE                          -- if renewal price list is null
                  --Update Line With the Prorated Amounts(Price Negotiated and Unit Price)
                  l_clev_rec.ID              := l_line_rec.ID;
                  l_clev_rec.price_negotiated := l_prorated_price_neg;
                  update_line (p_clev_rec                        => l_clev_rec,
                               x_return_status                   => l_return_status);
                  fnd_file.put_line(FND_FILE.LOG,'AFTER Calling update_line l_return_status = '||l_return_status);
                  oks_renew_pvt.debug_log
                    (p_program_name                    => 'Renewal Consolidation Reprice::',
                     p_perf_msg                        => 'UPDATE LINE (PCT) WITH NULL PL - RETURN = ' ||
                                                          l_return_status);

                  IF l_return_status <> g_ret_sts_success THEN
                    RAISE g_error;
                  END IF;

                  l_price_details.serv_ext_amount := l_prorated_price_neg;
                  l_price_details.status_text :=
                                          'Price derived using markup pricing';
                  update_price_info
                    (p_chr_id                          => l_line_rec.dnz_chr_id,
                     p_cle_id                          => l_line_rec.ID,
                     p_lse_id                          => l_line_rec.lse_id,
                     p_price_type                      => l_srv_k_details_rec.renewal_pricing_type,
                     p_price_details                   => l_price_details,
                     x_return_status                   => l_return_status
                    );

                  fnd_file.put_line(FND_FILE.LOG,'AFTER Calling update_price_info l_return_status = '||l_return_status);
                  oks_renew_pvt.debug_log
                    (p_program_name                    => 'Renewal Consolidation Reprice::',
                     p_perf_msg                        => 'UPDATE PRICE INFO (PCT) WITH NULL PL - RETURN = ' ||
                                                          l_return_status);

                  IF l_return_status <> g_ret_sts_success THEN
                    RAISE g_error;
                  END IF;

                  -- Update Subsciption elements
                  IF l_line_rec.lse_id = 46 THEN
                    oks_renew_pvt.debug_log
                      (p_program_name                    => 'Renewal Consolidation Reprice::',
                       p_perf_msg                        => 'Subscription line for pct with null PL');

                    FOR l_subs_elements_rec IN
                      l_subs_elements_csr (NVL (l_line_rec.cle_id,
                                                l_line_rec.ID)) LOOP
                      l_scev_rec_in.ID           := l_subs_elements_rec.ID;
                      l_scev_rec_in.amount       :=
                         l_subs_elements_rec.quantity *
                         l_prorated_unit_price;
                      l_scev_rec_in.object_version_number :=
                                     l_subs_elements_rec.object_version_number;
                      oks_renew_pvt.debug_log
                         (p_program_name                    => 'Renewal Consolidation Reprice::',
                          p_perf_msg                        => 'SUBSCR ELE ID = ' ||
                                                               l_scev_rec_in.ID);
                      oks_renew_pvt.debug_log
                         (p_program_name                    => 'Renewal Consolidation Reprice::',
                          p_perf_msg                        => 'SUBSCR ELE AMOUNT = ' ||
                                                               l_scev_rec_in.amount);
                      oks_subscr_elems_pub.update_row
                                          (p_api_version                     => l_api_version,
                                           p_init_msg_list                   => l_init_msg_list,
                                           x_return_status                   => l_return_status,
                                           x_msg_count                       => l_msg_count,
                                           x_msg_data                        => l_msg_data,
                                           p_scev_rec                        => l_scev_rec_in,
                                           x_scev_rec                        => l_scev_rec_out
                                          );
                  fnd_file.put_line(FND_FILE.LOG,'AFTER Calling oks_subscr_elems_pub.update_row l_return_status = '||l_return_status);
                      oks_renew_pvt.debug_log
                         (p_program_name                    => 'Renewal Consolidation Reprice::',
                          p_perf_msg                        => 'UPDATE SUBSCR ELE - AMOUNT = ' ||
                                                               l_return_status);

                      IF l_return_status <> g_ret_sts_success THEN
                        RAISE g_error;
                      END IF;
                    END LOOP;
                  END IF;

                  --Calculate Tax For Toplines(All Covered Levels for Service
                  --and Extended Warranty)
                  calculate_tax (p_chr_id                          => l_line_rec.dnz_chr_id,
                                 p_cle_id                          => l_line_rec.ID,
                                 p_amount                          => l_prorated_price_neg,
                                 x_return_status                   => l_return_status
                                );
                    fnd_file.put_line(FND_FILE.LOG,' 1 AFTER Calling calculate_tax l_return_status = '||l_return_status);
                  oks_renew_pvt.debug_log
                    (p_program_name                    => 'Renewal Consolidation Reprice::',
                     p_perf_msg                        => 'CALC TAX (PCT) WITH NULL PL - RETURN = ' ||
                                                          l_return_status);
                  oks_renew_pvt.debug_log
                    (p_program_name                    => 'Renewal Consolidation Reprice::',
                     p_perf_msg                        => 'CALC TAX (PCT) WITH NULL PL - AMOUNT = ' ||
                                                          l_prorated_price_neg);

                  IF l_return_status <> g_ret_sts_success THEN
                    RAISE g_error;
                  END IF;
                END IF;
              ELSE         --if covered item is NOT item, product, suscription
                calculate_tax (p_chr_id                          => l_line_rec.dnz_chr_id,
                               p_cle_id                          => l_line_rec.ID,
                               p_amount                          => l_prorated_price_neg,
                               x_return_status                   => l_return_status
                              );
                fnd_file.put_line(FND_FILE.LOG,' 2 AFTER Calling calculate_tax l_return_status = '||l_return_status);
                oks_renew_pvt.debug_log
                      (p_program_name                    => 'Renewal Consolidation Reprice::',
                       p_perf_msg                        => 'CALC TAX (PCT) FOR PARTY - RETURN = ' ||
                                                            l_return_status);
                oks_renew_pvt.debug_log
                      (p_program_name                    => 'Renewal Consolidation Reprice::',
                       p_perf_msg                        => 'CALC TAX (PCT) FOR PARTY - AMOUNT = ' ||
                                                            l_prorated_price_neg);

                IF l_return_status <> g_ret_sts_success THEN
                  RAISE g_error;
                END IF;                         -- Status Check after Tax Call
              END IF;               -- Lse If check within price type <> 'MAN'
            END IF;                                 -- Price Type Check End IF


            -- end debug log
            IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
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
            WHEN g_skip_proration THEN
              -- end debug log
              IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level
                 ) THEN
                fnd_log.STRING (fnd_log.level_procedure,
                                g_module ||
                                l_api_name,
                                '9200: Leaving ' ||
                                g_pkg_name ||
                                '.' ||
                                l_api_name
                               );
              END IF;

              NULL;
          END;

          EXIT WHEN l_index_sub_line_tbl = p_subject_sub_line_tbl.LAST;
          l_index_sub_line_tbl       :=
                            p_subject_sub_line_tbl.NEXT (l_index_sub_line_tbl);
        END LOOP;                           -- End loop for all the sub lines.
      END IF;                            -- Sub line table count check end if.

      --FOR MAN and PCT the simple api is called and it will not update the amounts of the contract
      --Because of this update_amounts need to be called....
      update_amounts (p_chr_id                          => p_subject_chr_id,
                      x_return_status                   => l_return_status);
      oks_renew_pvt.debug_log
                         (p_program_name                    => 'Renewal Consolidation Reprice::',
                          p_perf_msg                        => 'UPDATE CONTRACT AMOUNT = ' ||
                                                               l_return_status);

      IF l_return_status <> g_ret_sts_success THEN
        RAISE g_error;
      END IF;
    END IF;                  --End of check if the Price type is of Price List

    x_return_status            := l_return_status;

    fnd_file.put_line(FND_FILE.LOG,'  ');
    fnd_file.put_line(FND_FILE.LOG,'----- Leaving call_pricing_api ----------------------------- ');
    fnd_file.put_line(FND_FILE.LOG,'------------------------------------------------------------ ');
    fnd_file.put_line(FND_FILE.LOG,'------------------------------------------------------------ ');
    fnd_file.put_line(FND_FILE.LOG,'********************************************************** ');
    fnd_file.put_line(FND_FILE.LOG,'  ');

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
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
    WHEN g_error THEN
      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '2500: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      DBMS_TRANSACTION.rollback_savepoint ('REPRICE_OKS');
      x_return_status            := l_return_status;
    WHEN OTHERS THEN
      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
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
      okc_api.set_message (p_app_name                        => g_app_name_oks,
                           p_msg_name                        => g_unexpected_error,
                           p_token1                          => g_sqlcode_token,
                           p_token1_value                    => SQLCODE,
                           p_token2                          => g_sqlerrm_token,
                           p_token2_value                    => SQLERRM
                          );
      x_return_status            := g_ret_sts_unexp_error;
  END call_pricing_api;
END oks_reprice_pvt;

/
