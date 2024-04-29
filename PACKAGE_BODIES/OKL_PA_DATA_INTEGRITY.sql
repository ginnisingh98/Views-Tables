--------------------------------------------------------
--  DDL for Package Body OKL_PA_DATA_INTEGRITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PA_DATA_INTEGRITY" AS
/* $Header: OKLRPAQB.pls 120.11.12010000.2 2009/12/10 19:55:40 gkadarka ship $ */

  G_TOT_RESIDU_INC_MSG CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_VN_INCORRECT_RESIDUAL';
  G_RESIDU_NOT_POS_MSG CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_VN_INCORRECT_PERCENT';

  -- this function ensures that the sum of residual share percent on the program agreement is 100%
  -- and is distributed among the parties of the PA
  FUNCTION validate_total_residual(p_chr_id okc_k_headers_b.id%TYPE) RETURN VARCHAR2 IS
    -- rule group VGLRS, rule information categor VGLRSP
    CURSOR c_get_total_share(cp_chr_id okc_k_headers_b.id%TYPE)IS
    SELECT NVL(SUM(to_number(rules.rule_information2)),0) total_share
      FROM okc_rules_b rules
          ,okc_rule_groups_b rule_group
     WHERE rule_group.id = rules.rgp_id
       AND rules.rule_information_category = 'VGLRSP'
       AND rule_group.rgd_code = 'VGLRS'
       AND rule_group.dnz_chr_id = cp_chr_id;
    lv_total_share NUMBER;
    lv_return_status VARCHAR2(1);
  BEGIN
    lv_return_status := 'S';
    OPEN c_get_total_share(cp_chr_id => p_chr_id); FETCH c_get_total_share INTO lv_total_share;
    CLOSE c_get_total_share;
    -- the total residual share cannot be more than 100 or less than 100. it has to be always sum up to 100
    IF(lv_total_share > 100 OR lv_total_share < 100)THEN
      lv_return_status := 'E';
      okl_api.set_message(G_APP_NAME, G_TOT_RESIDU_INC_MSG);
    END IF;
    RETURN lv_return_status;
  EXCEPTION WHEN OTHERS THEN
    lv_return_status := 'E';
    okl_api.set_message(G_APP_NAME, G_TOT_RESIDU_INC_MSG);
    RETURN lv_return_status;
  END validate_total_residual;

  -- this function ensures that each residual share percent defined against the party in the Terms and Conditions page is a positive number
  FUNCTION validate_residual_positive(p_chr_id okc_k_headers_b.id%TYPE) RETURN VARCHAR2 IS
    CURSOR c_get_residual_share(cp_chr_id okc_k_headers_b.id%TYPE)IS
    SELECT rules.rule_information2 share_percent
      FROM okc_rules_b rules
          ,okc_rule_groups_b rule_group
     WHERE rule_group.id = rules.rgp_id
       AND rules.rule_information_category = 'VGLRSP'
       AND rule_group.rgd_code = 'VGLRS'
       AND rule_group.dnz_chr_id = cp_chr_id;
    lv_return_status VARCHAR2(1);
  BEGIN
    lv_return_status := 'S';
    FOR each_row IN c_get_residual_share(cp_chr_id => p_chr_id) LOOP
      IF(to_number(each_row.share_percent) < 0)THEN
        lv_return_status := 'E';
        okl_api.set_message(G_APP_NAME, G_RESIDU_NOT_POS_MSG);
      END IF;
    END LOOP;
    RETURN lv_return_status;
  EXCEPTION WHEN OTHERS THEN
    lv_return_status := 'E';
    okl_api.set_message(G_APP_NAME, G_RESIDU_NOT_POS_MSG);
    RETURN lv_return_status;
  END validate_residual_positive;

  -- this function ensures that the pary information on the residual share terms and conditions page are valid parties on the program agreement
  FUNCTION validate_residual_parties(p_chr_id okc_k_headers_b.id%TYPE) RETURN VARCHAR2 IS
    lv_return_status VARCHAR2(1);
  BEGIN
    lv_return_status := 'S';
    RETURN lv_return_status;
  END validate_residual_parties;

  -- This function validates, the effective dates of all the associated objects of the same type
  -- to an agreement should not overlap.
  FUNCTION validate_date_overlap(p_id IN NUMBER, p_chr_id IN NUMBER, p_assoc_obj_id IN NUMBER, p_start_date IN DATE, p_end_date IN DATE)
      RETURN VARCHAR2 IS

    -- Cursor to fetch the effective dates of all the associated objects of same type
    -- keeping one object as the reference.
    CURSOR get_assoc_rec(cp_id okl_vp_associations.id%TYPE)
     IS
       SELECT start_date,
              end_date
             ,chr_id
             ,crs_id
             ,assoc_object_id
             ,assoc_object_version
             ,assoc_object_type_code
       FROM OKL_VP_ASSOCIATIONS
       WHERE id = cp_id;
     cv_get_assoc_rec get_assoc_rec%ROWTYPE;

    -- find out all objects with similar id (and optional version) which on the same association and with overlap dates
    -- assoc_object_type would not make a difference here
    CURSOR c_get_dup_obj_assoc (cp_object_id okl_vp_associations.assoc_object_id%TYPE
                               ,cp_crs_id okl_vp_change_requests.id%TYPE
                               ,cp_start_date okl_vp_associations.start_date%TYPE
                               ,cp_end_date okl_vp_associations.end_date%TYPE
                               ,cp_object_version okl_vp_associations.assoc_object_version%TYPE
                               ,cp_id okl_vp_associations.id%TYPE
                               )IS
    SELECT 'X'
      FROM okl_vp_associations
     WHERE crs_id = cp_crs_id
       AND chr_id IS NULL
       AND id <> cp_id
       AND assoc_object_id = cp_object_id
       AND (assoc_object_version = cp_object_version OR assoc_object_version IS NULL)
       AND (
             (trunc(start_date) BETWEEN trunc(cp_start_date) AND trunc(nvl(cp_end_date,okl_accounting_util.g_final_date))) OR
             (trunc(cp_start_date) BETWEEN trunc(start_date) AND trunc(nvl(end_date,okl_accounting_util.g_final_date)))
           );

    CURSOR c_get_dup_obj_agr (cp_object_id okl_vp_associations.assoc_object_id%TYPE
                             ,cp_chr_id okc_k_headers_b.id%TYPE
                             ,cp_start_date okl_vp_associations.start_date%TYPE
                             ,cp_end_date okl_vp_associations.end_date%TYPE
                             ,cp_object_version okl_vp_associations.assoc_object_version%TYPE
                             ,cp_id okl_vp_associations.id%TYPE
                             )IS
    SELECT 'X'
      FROM okl_vp_associations
     WHERE chr_id = cp_chr_id
       AND crs_id IS NULL
       AND id <> cp_id
       AND assoc_object_id = cp_object_id
       AND (assoc_object_version = cp_object_version OR assoc_object_version IS NULL)
       AND (
             (trunc(start_date) BETWEEN trunc(cp_start_date) AND trunc(nvl(cp_end_date,okl_accounting_util.g_final_date))) OR
             (trunc(cp_start_date) BETWEEN trunc(start_date) AND trunc(nvl(end_date,okl_accounting_util.g_final_date)))
           );

    l_return_value VARCHAR2(1) ;
    lv_dummy VARCHAR2(1);

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_pa_data_integrity.validate_date_overlap';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRPAQB.pls.pls call validate_date_overlap');
    END IF;

    l_return_value := 'S';

    OPEN get_assoc_rec(cp_id => p_id); FETCH get_assoc_rec INTO cv_get_assoc_rec;
    CLOSE get_assoc_rec;
    IF(cv_get_assoc_rec.chr_id IS NULL AND cv_get_assoc_rec.crs_id IS NOT NULL)THEN
      -- this is the case of ASSOCIATION record
      -- find all such associated objects on the ASSOCIATION which have overlap dates
      OPEN c_get_dup_obj_assoc(cp_object_id => cv_get_assoc_rec.assoc_object_id
                              ,cp_crs_id => cv_get_assoc_rec.crs_id
                              ,cp_start_date => cv_get_assoc_rec.start_date
                              ,cp_end_date =>  cv_get_assoc_rec.end_date
                              ,cp_object_version => cv_get_assoc_rec.assoc_object_version
                              ,cp_id => p_id
                               );
      LOOP
        FETCH c_get_dup_obj_assoc INTO lv_dummy;
        IF(NVL(lv_dummy,'Y') = 'X')THEN
          l_return_value := 'E';
        END IF;
        EXIT WHEN (c_get_dup_obj_assoc%NOTFOUND OR l_return_value = 'E');
      END LOOP;
      CLOSE c_get_dup_obj_assoc;
    ELSIF(cv_get_assoc_rec.chr_id IS NOT NULL AND cv_get_assoc_rec.crs_id IS NULL)THEN
      -- this is the case of AGREEMENT type of change request or record on original PA
      -- find all such objects on the change request or pa which have overlapping dates
      OPEN c_get_dup_obj_agr(cp_object_id => cv_get_assoc_rec.assoc_object_id
                            ,cp_chr_id => cv_get_assoc_rec.chr_id
                            ,cp_start_date => cv_get_assoc_rec.start_date
                            ,cp_end_date =>  cv_get_assoc_rec.end_date
                            ,cp_object_version => cv_get_assoc_rec.assoc_object_version
                            ,cp_id => p_id
                            );
      LOOP
        FETCH c_get_dup_obj_agr INTO lv_dummy;
        IF(NVL(lv_dummy,'Y') = 'X')THEN
          l_return_value := 'E';
        END IF;
        EXIT WHEN (c_get_dup_obj_agr%NOTFOUND OR l_return_value = 'E');
      END LOOP;
      CLOSE c_get_dup_obj_agr;
    END IF;

/*
    -- For all the records found, except the reference associated object.
    FOR each_row IN get_assoc_rec(p_id, p_chr_id, p_assoc_obj_id)
     LOOP
       -- If the reference objects end date and the records end date is not null then
       -- check if reference objects start date is not between records effective date and
       -- the records end date is not between reference effective date then return status as 'S' else as 'E'
       IF(p_end_date IS NOT NULL)THEN
         IF(each_row.end_date IS NOT NULL)THEN
           IF((each_row.start_date NOT BETWEEN p_start_date AND p_end_date) AND (p_start_date NOT BETWEEN each_row.start_date AND each_row.end_date))THEN
             l_return_value := 'S';
           ELSE
             l_return_value := 'E';
           END IF;
         -- if records end date is null, check for the reference end date should be less than the
         -- records start date.
         ELSE
           IF(p_end_date < each_row.start_date) THEN
             l_return_value := 'S';
           ELSE
             l_return_value := 'E';
           END IF;
         END IF;
       -- If reference end date is null, check for the record end date should be less than the reference start date.
       ELSIF(each_row.end_date IS NOT NULL)THEN
         IF(each_row.end_date < p_start_date) THEN
           l_return_value := 'S';
         ELSE
           l_return_value := 'E';
         END IF;
       -- If both the reference and record end date are null, return status as 'E'.
       ELSE
         l_return_value := 'E';
       END IF;
       EXIT WHEN l_return_value = 'E';
     END LOOP;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRPAQB.pls.pls call validate_date_overlap');
    END IF;
*/
    return l_return_value;

  END validate_date_overlap;

  -- This function validates the association end date should lie in between the agreements effective dates.
  FUNCTION validate_end_date(p_assoc_end_date IN DATE, p_agrmnt_start_date IN DATE, p_agrmnt_end_date IN DATE) RETURN VARCHAR2 IS


    l_return_value VARCHAR2(1) ;

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_pa_data_integrity.validate_end_date';
    l_debug_enabled VARCHAR2(10);

  BEGIN

    l_debug_enabled := okl_debug_pub.check_log_enabled;
    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRPAQB.pls.pls call validate_end_date');
    END IF;

    l_return_value := 'S';

    --If agreement end date and the association end date are not null.
    IF(p_agrmnt_end_date IS NOT NULL) THEN
      IF(p_assoc_end_date IS NOT NULL) THEN
        -- If the association end date does not lie in between the agreement effective dates, return 'E'.
        IF(p_assoc_end_date NOT BETWEEN p_agrmnt_start_date AND p_agrmnt_end_date) THEN
          l_return_value := 'E';
        ELSE
          l_return_value := 'S';
        END IF;
      ELSE
        l_return_value := 'E';
      END IF;
    -- If agreement end date is null, check if the association end date is less than agreement start date return 'E'.
    ELSE
      IF(p_assoc_end_date IS NOT NULL) THEN
        IF(p_assoc_end_date < p_agrmnt_start_date)THEN
          l_return_value := 'E';
        ELSE
          l_return_value := 'S';
        END IF;
      ELSE
        l_return_value := 'S';
      END IF;
    END IF;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRPAQB.pls.pls call validate_end_date');
    END IF;

    return l_return_value;

  END validate_end_date;

  -- This function validates for association start date should lie between agreement effective dates.
  FUNCTION validate_start_date(p_assoc_start_date IN DATE, p_agrmnt_start_date IN DATE, p_agrmnt_end_date IN DATE) RETURN VARCHAR2 IS

    l_return_value VARCHAR2(1) ;

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_pa_data_integrity.validate_start_date';
    l_debug_enabled VARCHAR2(10);

  BEGIN

    l_debug_enabled := okl_debug_pub.check_log_enabled;
    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRPAQB.pls.pls call validate_start_date');
    END IF;

    l_return_value := 'S';

    -- If agreement end date is not null, check if association start date lies between agreement effective dates.
    IF(p_agrmnt_end_date IS NOT NULL) THEN
      IF(p_assoc_start_date NOT BETWEEN p_agrmnt_start_date AND p_agrmnt_end_date) THEN
        l_return_value := 'E';
      ELSE
        l_return_value := 'S';
      END IF;
    -- If agreement end date is null, check if association start date is less than agreement effective dates return 'E'.
    ELSE
      IF(p_assoc_start_date < p_agrmnt_start_date)THEN
        l_return_value := 'E';
      ELSE
        l_return_value := 'S';
      END IF;
    END IF;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRPAQB.pls.pls call validate_start_date');
    END IF;

    return l_return_value;

  END validate_start_date;


  -- THis function validates the stauts of the lease contract template or the lease application template attched to the agreement.
  FUNCTION validate_status(p_status IN VARCHAR2) RETURN VARCHAR2 IS

    l_return_value VARCHAR2(1) ;

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_pa_data_integrity.validate_status';
    l_debug_enabled VARCHAR2(10);

  BEGIN

    l_debug_enabled := okl_debug_pub.check_log_enabled;
    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRPAQB.pls.pls call validate_status');
    END IF;

    l_return_value := 'S';
    -- if the status of lease agreement template or the lease application template attached to the agreement is not in
    -- status "Active", return the status as 'E'.
    IF(p_status <> 'ACTIVE')THEN
      l_return_value := 'E';
    ELSE
      l_return_value := 'S';
    END IF;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRPAQB.pls.pls call validate_status');
    END IF;

    return l_return_value;

  END validate_status;

  -- This function returns the lookup meaning of the lookup code and lookup type passed to the function.
  FUNCTION get_lookup_meaning( p_lookup_type FND_LOOKUPS.LOOKUP_TYPE%TYPE
                              ,p_lookup_code FND_LOOKUPS.LOOKUP_CODE%TYPE)
     RETURN VARCHAR2
     IS
     CURSOR fnd_lookup_csr(  p_lookup_type fnd_lookups.lookup_type%type
                           ,p_lookup_code fnd_lookups.lookup_code%type)
     IS
       SELECT MEANING
       FROM  FND_LOOKUPS FND
       WHERE FND.LOOKUP_TYPE = p_lookup_type
         AND FND.LOOKUP_CODE = p_lookup_code;

    l_return_value fnd_lookups.meaning%TYPE;

    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_pa_data_integrity.get_lookup_meaning';
    l_debug_enabled VARCHAR2(10);

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRPAQB.pls.pls call get_lookup_meaning');
    END IF;

    IF (  p_lookup_type IS NOT NULL AND p_lookup_code IS NOT NULL )
    THEN
        OPEN fnd_lookup_csr( p_lookup_type, p_lookup_code );
        FETCH fnd_lookup_csr INTO l_return_value;
        CLOSE fnd_lookup_csr;
    END IF;
    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRPAQB.pls.pls call evaluate_territory');
    END IF;
    return l_return_value;
  END get_lookup_meaning;

  -- This function validates all the records and throws an error for all the validation failures.
  PROCEDURE check_functional_constraints( x_return_status   OUT NOCOPY VARCHAR2,
                                          p_chr_id          IN  NUMBER
                                        ) IS

    -- Cursor to fetch the agreement record.
    CURSOR get_agreement_rec(cp_chr_id IN NUMBER) IS
       SELECT start_date,
              end_date,
              contract_number,
              inv_organization_id,
              sts_code
       FROM   OKC_K_HEADERS_B
       WHERE  id = cp_chr_id;

    -- Cursor to fetch lease application template record.
    -- Manu 01-Sep-2005 Change reference_number to name
    CURSOR get_application_template_rec(cp_id IN NUMBER, cp_version IN NUMBER)IS
      SELECT temp.name, --temp.reference_number,
             vers.version_status
      FROM   OKL_LEASEAPP_TMPLS temp,
             okl_leaseapp_templ_versions_v vers
      WHERE  temp.id =  cp_id
      AND    vers.leaseapp_template_id = temp.id
      -- Manu 02-Sep-2005 version changed to version_number
      AND    vers.version_number = cp_version ;

    -- Cursor to fetch the associated object details.
    -- for normal agreement
    CURSOR get_association_rec(cp_chr_id IN NUMBER) IS
      SELECT vp_assoc.id,
             vp_assoc.start_date,
             vp_assoc.end_date,
             vp_assoc.assoc_object_type_code,
             vp_assoc.assoc_object_id,
             vp_assoc.assoc_object_version
      FROM   okl_vp_associations vp_assoc
            ,okc_k_headers_b chr
            ,okc_statuses_b sts
      WHERE  vp_assoc.chr_id = cp_chr_id
         AND vp_assoc.chr_id = chr.id
         AND sts.code = chr.sts_code
         AND sts.ste_Code = 'ENTERED'
      UNION
      -- for association type of change request
      SELECT vpa.id,
             vpa.start_date,
             vpa.end_date,
             vpa.assoc_object_type_code,
             vpa.assoc_object_id,
             vpa.assoc_object_version
      FROM   okl_vp_associations vpa,
             okl_vp_change_requests creq
      WHERE  creq.chr_id = cp_chr_id
      AND    vpa.crs_id = creq.id
      AND    creq.status_code in ('PASSED','NEW','INCOMPLETE');
      -- sjalasut, commented as the following sql is inconsequential
      /*
      UNION
      -- for agreement type of change request
      SELECT vpa.id,
             vpa.start_date,
             vpa.end_date,
             vpa.assoc_object_type_code,
             vpa.assoc_object_id,
             vpa.assoc_object_version
      FROM   okl_vp_associations vpa,
             okl_vp_change_requests creq
      WHERE  vpa.crs_id = (select crs_id from okl_k_headers where id = cp_chr_id)
      AND    vpa.crs_id = creq.id
      AND    creq.status_code in ('PASSED','NEW','INCOMPLETE')
      */


    -- Cursor to fetch the items name, associated to an agreement.
    CURSOR get_item_name(p_org_id IN NUMBER, p_item_id IN NUMBER) IS
      SELECT description
      FROM   MTL_SYSTEM_ITEMS_VL
      WHERE  organization_id = p_org_id
      AND    inventory_item_id = p_item_id;

    -- Cursor to fetch the item categories name, associated to an agreement.
    CURSOR get_item_catg_name(p_item_catg_id IN NUMBER)IS
      SELECT CATEGORY_CONCAT_SEGS
      FROM   MTL_CATEGORIES_V
      WHERE  CATEGORY_ID = p_item_catg_id;

    -- Cursor to fetch the end of terms name, associated to an agreement.
    CURSOR get_eot_name(p_eot_id IN NUMBER)IS
      SELECT end_of_term_name
      FROM   OKL_FE_EO_TERMS_V
      WHERE  end_of_term_id = p_eot_id;

    -- Cursor to fetch the item products name, associated to an agreement.
    CURSOR get_product_name(p_prod_id IN NUMBER)IS
      SELECT name
      FROM   OKL_PRODUCTS
      WHERE id =  p_prod_id;

    -- Cursor to fetch the parent agreement record.
    CURSOR get_parent_rec(cp_chr_id IN NUMBER)IS
      SELECT chrb.contract_number,
             chrb.sts_code,
             chrb.start_date,
             chrb.end_date
      FROM   OKC_GOVERNANCES govb,
             OKC_K_HEADERS_B chrb
      WHERE  govb.chr_id = cp_chr_id
      AND    govb.chr_id_referred = chrb.id;

    -- Cursor to fetch the lease application template parameters.
    -- Manu 01-Sep-2005 Change reference_number to name and sic_code to industry_code
    -- Manu 02-Sep-2005 remove references to APPLICATION_TYPE
    CURSOR get_la_rec(cp_assoc_id IN NUMBER) IS
      SELECT cust_credit_classification,
             credit_review_purpose,
             industry_code,
             name,
             industry_class
      FROM   OKL_LEASEAPP_TMPLS
      WHERE  id = cp_assoc_id;

    -- Cursor to find the duplicate record of lease application template with the combination of the parameters
    -- application_type, cust_credit_classification, credit_review_purpose, sic_code.

    -- Manu 01-Sep-2005 Change sic_code to industry_code
    -- Manu 02-Sep-2005 remove references to APPLICATION_TYPE
    CURSOR get_la_assoc_rec_param(cp_id IN NUMBER,
                                  cp_object_id IN NUMBER,
                                  cp_chr_id IN NUMBER,
                                  cp_credit_class IN VARCHAR2,
                                  cp_credit_review IN VARCHAR2,
                                  cp_sic_code IN VARCHAR2,
                                  cp_industry_class IN VARCHAR2,
                                  cp_start_date IN DATE,
                                  cp_end_date IN DATE)IS
      SELECT lat.name
      FROM   OKL_LEASEAPP_TMPLS lat,
             okl_vp_associations_v vpa,
             okc_k_headers_b chr,
             okc_statuses_b sts
      WHERE  lat.id = vpa.assoc_object_id
      AND    chr.id = vpa.chr_id
      AND    chr.sts_code = sts.code
      AND    sts.ste_code = 'ENTERED'
      AND    vpa.assoc_object_type_code = 'LA_TEMPLATE'
      AND    vpa.chr_id = cp_chr_id
      AND    lat.cust_credit_classification = cp_credit_class
      AND    lat.credit_review_purpose = cp_credit_review
      AND    NVL(lat.industry_code, OKL_API.G_MISS_CHAR) = NVL(cp_sic_code,OKL_API.G_MISS_CHAR)
      AND    NVL(lat.industry_class,OKL_API.G_MISS_CHAR) = NVL(cp_industry_class, OKL_API.G_MISS_CHAR)
      AND    vpa.id <> cp_id
      AND    vpa.assoc_object_id <> cp_object_id
      AND    (
              (trunc(cp_start_date) BETWEEN trunc(vpa.start_date) AND TRUNC(NVL(vpa.end_date,okl_accounting_util.g_final_date))) OR
              (trunc(NVL(cp_end_date,okl_accounting_util.g_final_date)) BETWEEN trunc(vpa.start_date) AND TRUNC(NVL(vpa.end_date,okl_accounting_util.g_final_date)))
             )
      UNION
      SELECT lat.name
      FROM   OKL_LEASEAPP_TMPLS lat,
             okl_vp_associations_v vpa,
             okl_vp_change_requests chreq
      WHERE  lat.id = vpa.assoc_object_id
      AND    vpa.assoc_object_type_code = 'LA_TEMPLATE'
      AND    chreq.chr_id = cp_chr_id
      AND    vpa.crs_id = chreq.id
      AND    lat.cust_credit_classification = cp_credit_class
      AND    lat.credit_review_purpose = cp_credit_review
      AND    NVL(lat.industry_code, OKL_API.G_MISS_CHAR) = NVL(cp_sic_code,OKL_API.G_MISS_CHAR)
      AND    NVL(lat.industry_class,OKL_API.G_MISS_CHAR) = NVL(cp_industry_class, OKL_API.G_MISS_CHAR)
      AND    vpa.id <> cp_id
      AND    vpa.assoc_object_id <> cp_object_id
      AND    (
              (trunc(cp_start_date) BETWEEN trunc(vpa.start_date) AND TRUNC(NVL(vpa.end_date,okl_accounting_util.g_final_date))) OR
              (trunc(NVL(cp_end_date,okl_accounting_util.g_final_date)) BETWEEN trunc(vpa.start_date) AND TRUNC(NVL(vpa.end_date,okl_accounting_util.g_final_date)))
             )
      AND    chreq.status_code in ('PASSED','NEW','INCOMPLETE')
      UNION
      SELECT lat.name
      FROM   OKL_LEASEAPP_TMPLS lat,
             okl_vp_associations_v vpa,
             okl_vp_change_requests chreq,
             okl_k_headers okl
      WHERE  lat.id = vpa.assoc_object_id
      AND    vpa.assoc_object_type_code = 'LA_TEMPLATE'
      AND    okl.id =    cp_chr_id
      AND    vpa.crs_id = okl.crs_id
      AND    lat.cust_credit_classification = cp_credit_class
      AND    lat.credit_review_purpose = cp_credit_review
      AND    NVL(lat.industry_code, OKL_API.G_MISS_CHAR) = NVL(cp_sic_code,OKL_API.G_MISS_CHAR)
      AND    NVL(lat.industry_class,OKL_API.G_MISS_CHAR) = NVL(cp_industry_class, OKL_API.G_MISS_CHAR)
      AND    vpa.id <> cp_id
      AND    vpa.assoc_object_id <> cp_object_id
      AND    (
              (trunc(cp_start_date) BETWEEN trunc(vpa.start_date) AND TRUNC(NVL(vpa.end_date,okl_accounting_util.g_final_date))) OR
              (trunc(NVL(cp_end_date,okl_accounting_util.g_final_date)) BETWEEN trunc(vpa.start_date) AND TRUNC(NVL(vpa.end_date,okl_accounting_util.g_final_date)))
             )
      AND    chreq.id = vpa.crs_id
      AND    chreq.status_code in ('PASSED','NEW','INCOMPLETE');

    CURSOR c_get_criteria_csr(cp_chr_id okc_k_headers_b.id%TYPE)IS
    SELECT crit.effective_from_date
          ,crit.effective_to_date
          ,crit.match_criteria_code
          ,cdef.crit_cat_name
      FROM okl_fe_criteria crit
          ,okl_fe_criteria_set cset
          ,okl_fe_Crit_cat_def_v cdef
     WHERE crit.criteria_set_id = cset.criteria_set_id
       AND cdef.crit_cat_def_id = crit.crit_cat_def_id
       AND source_id = cp_chr_id
       AND source_object_code = 'VENDOR_PROGRAM';

    l_return_status	      VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_start_date          OKC_K_HEADERS_B.START_DATE%TYPE;
    l_end_date            OKC_K_HEADERS_B.END_DATE%TYPE;
    l_agrmnt_number       OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
    l_inv_org_id          OKC_K_HEADERS_B.INV_ORGANIZATION_ID%TYPE;
    l_sts_code            OKC_K_HEADERS_B.STS_CODE%TYPE;
    l_assoc_start_date    OKC_K_HEADERS_B.START_DATE%TYPE;
    l_assoc_end_date      OKC_K_HEADERS_B.END_DATE%TYPE;
    l_assoc_agrmnt_number OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
    l_assoc_inv_org_id    OKC_K_HEADERS_B.INV_ORGANIZATION_ID%TYPE;
    l_assoc_sts_code      OKC_K_HEADERS_B.STS_CODE%TYPE;
    l_assoc_name          VARCHAR2(2000);
    p_api_version     NUMBER;
    p_init_msg_list   VARCHAR2(256) DEFAULT OKC_API.G_FALSE;
    x_msg_count       NUMBER;
    x_msg_data        VARCHAR2(256);
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_pa_data_integrity.check_functional_constraints';
    l_debug_enabled VARCHAR2(10);

    l_dummy             VARCHAR2(1);
    -- Manu 02-Sep-2005 remove references to APPLICATION_TYPE
    -- l_application_type  OKL_LEASEAPP_TEMPLATES_V.APPLICATION_TYPE%TYPE;
    l_credit_class	     OKL_LEASEAPP_TMPLS.CUST_CREDIT_CLASSIFICATION%TYPE;
    l_credit_purpose    OKL_LEASEAPP_TMPLS.CREDIT_REVIEW_PURPOSE%TYPE;
    l_sic_code          OKL_LEASEAPP_TMPLS.INDUSTRY_CODE%TYPE;
    -- Manu 01-Sep-2005 Change REFERENCE_NUMBER to NAME
    -- l_appl_temp_name    OKL_LEASEAPP_TEMPLATES_V.REFERENCE_NUMBER%TYPE;
    l_appl_temp_name    OKL_LEASEAPP_TMPLS.NAME%TYPE;
    lv_industry_class OKL_LEASEAPP_TMPLS.industry_class%TYPE;
    lv_leaseapp_tmpt_name OKL_LEASEAPP_TMPLS.name%TYPE;
  BEGIN

    l_debug_enabled := okl_debug_pub.check_log_enabled;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRPAQB.pls.pls call get_lookup_meaning');
    END IF;
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    OPEN  get_agreement_rec(p_chr_id);
    FETCH get_agreement_rec INTO l_start_date, l_end_date, l_agrmnt_number, l_inv_org_id, l_sts_code;
    CLOSE get_agreement_rec;

    -- Check the agreements effective dates should be between the parent agreements effective dates and the parent
    -- agreement attached to the agreement must be in status "Active".
    FOR parent_rec IN get_parent_rec(p_chr_id)
     LOOP
       -- Check if the agreements start date lies between the parent agreements effective dates, else throw an error.
       l_return_status := validate_start_date(l_start_date,
                                              parent_rec.start_date,
                                              parent_rec.end_date
                                             );
       IF(l_return_status = 'E')THEN
          OKL_API.set_message(G_APP_NAME,
                              'OKL_VN_AGR_INV_START_DATE',
                              'AGR_NUMBER',
                              l_agrmnt_number,
                              'PARENT_AGR_NUMBER',
                              parent_rec.contract_number
                             );
          x_return_status := OKL_API.G_RET_STS_ERROR;
       END IF;
       -- Check if the agreements end date lies between the parent agreements effective dates, else throw an error.
       l_return_status := validate_end_date(l_end_date,
                                            parent_rec.start_date,
                                            parent_rec.end_date
                                           );
       IF(l_return_status = 'E')THEN
          OKL_API.set_message(G_APP_NAME,
                              'OKL_VN_AGR_INV_END_DATE',
                              'AGR_NUMBER',
                              l_agrmnt_number,
                              'PARENT_AGR_NUMBER',
                              parent_rec.contract_number
                             );
          x_return_status := OKL_API.G_RET_STS_ERROR;
       END IF;
       -- Check the parent agreement must be in status "Active", else throw an error.
       l_return_status := validate_status(parent_rec.sts_code);
       IF(l_return_status = 'E')THEN
          OKL_API.set_message(G_APP_NAME,
                              'OKL_VN_AGR_INV_STATUS',
                              'PARENT_AGR_NUMBER',
                              l_agrmnt_number,
                              'AGR_NUMBER',
                              parent_rec.contract_number
                             );
          x_return_status := OKL_API.G_RET_STS_ERROR;
       END IF;
     END LOOP;

    --For each row found in the association records, validate each record, and raise arrors, if the validation fails.
    FOR each_row IN get_association_rec(p_chr_id)
     LOOP

       -- For lease contract template, validate that the associated templates status should be active,
       -- The association effective dates should lie in between the agreements effective dates. If any of the validation
       -- fails throw an error.
       IF(each_row.assoc_object_type_code = 'LC_TEMPLATE') THEN
         OPEN  get_agreement_rec(each_row.assoc_object_id);
         FETCH get_agreement_rec INTO l_assoc_start_date, l_assoc_end_date, l_assoc_agrmnt_number, l_assoc_inv_org_id, l_assoc_sts_code;
         CLOSE get_agreement_rec;
         l_return_status := validate_start_date(each_row.start_date,
                                                l_start_date,
                                                l_end_date
                                               );
         IF(l_return_status = 'E')THEN
            OKL_API.set_message(G_APP_NAME,
                                'OKL_VN_INV_ASSOC_START_DATE',
                                'ASSOC_TYPE',
                                get_lookup_meaning('OKL_VP_ASSOC_OBJECT_TYPES', each_row.assoc_object_type_code),
                                'ASSOC_NAME',
                                l_assoc_agrmnt_number,
                                'AGR_NUMBER',
                                l_agrmnt_number
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;
         l_return_status := validate_end_date(each_row.end_date,
                                              l_start_date,
                                              l_end_date
                                             );
         IF(l_return_status = 'E')THEN
            OKL_API.set_message(G_APP_NAME,
                                'OKL_VN_INV_ASSOC_END_DATE',
                                'ASSOC_TYPE',
                                get_lookup_meaning('OKL_VP_ASSOC_OBJECT_TYPES', each_row.assoc_object_type_code),
                                'ASSOC_NAME',
                                l_assoc_agrmnt_number,
                                'AGR_NUMBER',
                                l_agrmnt_number
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;
         -- l_return_status := validate_status(l_assoc_sts_code);
         -- sjalasut, Lease Contract Temaplates are PASSED and Lease Application Templates are ACTIVE
         -- so one common method to validate their statuses is not correct.
         -- Bug 6642645: LC_TEMPLATE entities final status is PASSED, but not BOOKED as assumed.
         IF((each_row.assoc_object_type_code = 'LC_TEMPLATE' AND l_assoc_sts_code <> 'BOOKED') OR
            (each_row.assoc_object_type_code = 'LA_TEMPLATE' AND l_assoc_sts_code <> 'ACTIVE')
           )THEN
           OKL_API.set_message(G_APP_NAME,
                               'OKL_VN_INV_ASSOC_STATUS',
                               'ASSOC_TYPE',
                               get_lookup_meaning('OKL_VP_ASSOC_OBJECT_TYPES', each_row.assoc_object_type_code),
                               'ASSOC_NAME',
                               l_assoc_agrmnt_number,
                               'AGR_NUMBER',
                               l_agrmnt_number
                              );
           x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;

       -- For lease application template, validate that the associated templates status should be active,
       -- The association effective dates should lie in between the agreements effective dates. If any of the validation fails throw an error.
       ELSIF(each_row.assoc_object_type_code = 'LA_TEMPLATE') THEN
         l_dummy := null;
         lv_leaseapp_tmpt_name := null;
         OPEN  get_application_template_rec(each_row.assoc_object_id, each_row.assoc_object_version);
         FETCH get_application_template_rec INTO l_assoc_agrmnt_number, l_assoc_sts_code;
         CLOSE get_application_template_rec;

         OPEN get_la_rec(each_row.assoc_object_id);
         -- Manu 02-Sep-2005 remove references to APPLICATION_TYPE
         FETCH get_la_rec INTO  l_credit_class, l_credit_purpose, l_sic_code, l_appl_temp_name,lv_industry_class;
         CLOSE get_la_rec;

         -- Manu 02-Sep-2005 remove references to APPLICATION_TYPE
         OPEN get_la_assoc_rec_param(each_row.id,
                                     each_row.assoc_object_id,
                                     p_chr_id,
                                     l_credit_class,
                                     l_credit_purpose,
                                     l_sic_code,
                                     lv_industry_class,
                                     each_row.start_date,
                                     each_row.end_date);
         FETCH get_la_assoc_rec_param INTO lv_leaseapp_tmpt_name;
         CLOSE get_la_assoc_rec_param;

         IF (lv_leaseapp_tmpt_name IS NOT NULL) THEN
           OKL_API.SET_MESSAGE( G_APP_NAME,
                                'OKL_VP_DUPLICATE_ASSOCIATION',
                                'FIRST',
                                l_appl_temp_name,
                                'SECOND',
                                l_assoc_agrmnt_number,
                                'AGR_NUMBER',
                                l_agrmnt_number
                              );
           x_return_status := OKL_API.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;

         l_return_status := validate_start_date(each_row.start_date,
                                                l_start_date,
                                                l_end_date
                                               );
         IF(l_return_status = 'E')THEN
            OKL_API.set_message(G_APP_NAME,
                                'OKL_VN_INV_ASSOC_START_DATE',
                                'ASSOC_TYPE',
                                get_lookup_meaning('OKL_VP_ASSOC_OBJECT_TYPES', each_row.assoc_object_type_code),
                                'ASSOC_NAME',
                                l_assoc_agrmnt_number,
                                'AGR_NUMBER',
                                l_agrmnt_number
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;
         l_return_status := validate_end_date(each_row.end_date,
                                              l_start_date,
                                              l_end_date
                                             );
         IF(l_return_status = 'E')THEN
            OKL_API.set_message(G_APP_NAME,
                                'OKL_VN_INV_ASSOC_END_DATE',
                                'ASSOC_TYPE',
                                get_lookup_meaning('OKL_VP_ASSOC_OBJECT_TYPES', each_row.assoc_object_type_code),
                                'ASSOC_NAME',
                                l_assoc_agrmnt_number,
                                'AGR_NUMBER',
                                l_agrmnt_number
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;
         l_return_status := validate_status(l_assoc_sts_code);
         IF(l_return_status = 'E')THEN
            OKL_API.set_message(G_APP_NAME,
                                'OKL_VN_INV_ASSOC_STATUS',
                                'ASSOC_TYPE',
                                get_lookup_meaning('OKL_VP_ASSOC_OBJECT_TYPES', each_row.assoc_object_type_code),
                                'ASSOC_NAME',
                                l_assoc_agrmnt_number,
                                'AGR_NUMBER',
                                l_agrmnt_number
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;

       -- For each of the items associated to the agreement, the association dates should lie between the agreement effective dates,
       -- For all the items of same type associated to the agreement, check no effective date of the items should be overlaping.
       -- If any of the validation fails throw error.
       ELSIF(each_row.assoc_object_type_code = 'LA_ITEMS')THEN
         OPEN get_item_name(l_inv_org_id, each_row.assoc_object_id);
         FETCH get_item_name INTO l_assoc_name;
         CLOSE get_item_name;
         l_return_status := validate_start_date(each_row.start_date,
                                                l_start_date,
                                                l_end_date
                                               );
         IF(l_return_status = 'E')THEN
            OKL_API.set_message(G_APP_NAME,
                                'OKL_VN_INV_ITEM_START_DATE',
                                'ASSOC_NAME',
                                l_assoc_name,
                                'AGR_NUMBER',
                                l_agrmnt_number
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;
         l_return_status := validate_end_date(each_row.end_date,
                                              l_start_date,
                                              l_end_date
                                             );
         IF(l_return_status = 'E')THEN
            OKL_API.set_message(G_APP_NAME,
                                'OKL_VN_INV_ITEM_END_DATE',
                                'ASSOC_NAME',
                                l_assoc_name,
                                'AGR_NUMBER',
                                l_agrmnt_number
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;
         l_return_status := validate_date_overlap(each_row.id,
                                                  p_chr_id,
                                                  each_row.assoc_object_id,
                                                  each_row.start_date,
                                                  each_row.end_date
                                                 );
         IF(l_return_status = 'E')THEN
            OKL_API.set_message(G_APP_NAME,
                                'OKL_VN_OVERLAP_DATE',
                                'ASSOC_TYPE',
                                get_lookup_meaning('OKL_VP_ASSOC_OBJECT_TYPES', each_row.assoc_object_type_code),
                                'AGR_NUMBER',
                                l_agrmnt_number
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;

       -- For each of the item categories associated to the agreement, the association dates should lie between the agreement effective
       -- dates. For all the item categories of same type associated to the agreement, check no effective date of the item categories
       -- should be overlaping. If any of the validation fails throw error.
       ELSIF(each_row.assoc_object_type_code = 'LA_ITEM_CATEGORIES')THEN
         OPEN get_item_catg_name(each_row.assoc_object_id);
         FETCH get_item_catg_name INTO l_assoc_name;
         CLOSE get_item_catg_name;
         l_return_status := validate_start_date(each_row.start_date,
                                                l_start_date,
                                                l_end_date
                                               );
         IF(l_return_status = 'E')THEN
            OKL_API.set_message(G_APP_NAME,
                                'OKL_VN_INV_ITEMCAT_START_DATE',
                                'ASSOC_NAME',
                                l_assoc_name,
                                'AGR_NUMBER',
                                l_agrmnt_number
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;
         l_return_status := validate_end_date(each_row.end_date,
                                              l_start_date,
                                              l_end_date
                                             );
         IF(l_return_status = 'E')THEN
            OKL_API.set_message(G_APP_NAME,
                                'OKL_VN_INV_ITEMCAT_END_DATE',
                                'ASSOC_NAME',
                                l_assoc_name,
                                'AGR_NUMBER',
                                l_agrmnt_number
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;
         l_return_status := validate_date_overlap(each_row.id,
                                                  p_chr_id,
                                                  each_row.assoc_object_id,
                                                  each_row.start_date,
                                                  each_row.end_date
                                                 );
         IF(l_return_status = 'E')THEN
            OKL_API.set_message(G_APP_NAME,
                                'OKL_VN_OVERLAP_DATE',
                                'ASSOC_TYPE',
                                get_lookup_meaning('OKL_VP_ASSOC_OBJECT_TYPES', each_row.assoc_object_type_code),
                                'AGR_NUMBER',
                                l_agrmnt_number
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;

       -- For each of the end-of-terms associated to the agreement, the association dates should lie between the agreement effective
       -- dates. For all the end-of-terms of same type associated to the agreement, check no effective date of the end-of-terms should
       -- be overlaping. If any of the validation fails throw error.
       ELSIF(each_row.assoc_object_type_code = 'LA_EOT_VALUES')THEN
         OPEN get_eot_name(each_row.assoc_object_id);
         FETCH get_eot_name INTO l_assoc_name;
         CLOSE get_eot_name;
         l_return_status := validate_start_date(each_row.start_date,
                                                l_start_date,
                                                l_end_date
                                               );
         IF(l_return_status = 'E')THEN
            OKL_API.set_message(G_APP_NAME,
                                'OKL_VN_INV_EOT_START_DATE',
                                'ASSOC_NAME',
                                l_assoc_name,
                                'AGR_NUMBER',
                                l_agrmnt_number
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;
         l_return_status := validate_end_date(each_row.end_date,
                                              l_start_date,
                                              l_end_date
                                             );
         IF(l_return_status = 'E')THEN
            OKL_API.set_message(G_APP_NAME,
                                'OKL_VN_INV_EOT_END_DATE',
                                'ASSOC_NAME',
                                l_assoc_name,
                                'AGR_NUMBER',
                                l_agrmnt_number
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;
         l_return_status := validate_date_overlap(each_row.id,
                                                  p_chr_id,
                                                  each_row.assoc_object_id,
                                                  each_row.start_date,
                                                  each_row.end_date
                                                 );
         IF(l_return_status = 'E')THEN
            OKL_API.set_message(G_APP_NAME,
                                'OKL_VN_OVERLAP_DATE',
                                'ASSOC_TYPE',
                                get_lookup_meaning('OKL_VP_ASSOC_OBJECT_TYPES', each_row.assoc_object_type_code),
                                'AGR_NUMBER',
                                l_agrmnt_number
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;

       -- For each of the products associated to the agreement, the association dates should lie between the agreement effective
       -- dates. For all the products of same type associated to the agreement, check no effective date of the products should
       -- be overlaping. If any of the validation fails throw error.
       ELSIF(each_row.assoc_object_type_code = 'LA_FINANCIAL_PRODUCT')THEN
         OPEN get_product_name(each_row.assoc_object_id);
         FETCH get_product_name INTO l_assoc_name;
         CLOSE get_product_name;
         l_return_status := validate_start_date(each_row.start_date,
                                                l_start_date,
                                                l_end_date
                                               );
         IF(l_return_status = 'E')THEN
            OKL_API.set_message(G_APP_NAME,
                                'OKL_VN_INV_PDT_START_DATE',
                                'ASSOC_NAME',
                                l_assoc_name,
                                'AGR_NUMBER',
                                l_agrmnt_number
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;
         l_return_status := validate_end_date(each_row.end_date,
                                              l_start_date,
                                              l_end_date
                                             );
         IF(l_return_status = 'E')THEN
            OKL_API.set_message(G_APP_NAME,
                                'OKL_VN_INV_PDT_END_DATE',
                                'ASSOC_NAME',
                                l_assoc_name,
                                'AGR_NUMBER',
                                l_agrmnt_number
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;
         l_return_status := validate_date_overlap(each_row.id,
                                                  p_chr_id,
                                                  each_row.assoc_object_id,
                                                  each_row.start_date,
                                                  each_row.end_date
                                                 );
         IF(l_return_status = 'E')THEN
            OKL_API.set_message(G_APP_NAME,
                                'OKL_VN_OVERLAP_DATE',
                                'ASSOC_TYPE',
                                get_lookup_meaning('OKL_VP_ASSOC_OBJECT_TYPES', each_row.assoc_object_type_code),
                                'AGR_NUMBER',
                                l_agrmnt_number
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;
       END IF;
     END LOOP;

    -- sjalasut, added validations to check the effective dates of the criteria fall within the effective dates of the PA
    -- START of code changes
    FOR c_get_criteria_rec IN c_get_criteria_csr(cp_chr_id => p_chr_id) LOOP
      IF((TRUNC(c_get_criteria_rec.effective_from_date) NOT BETWEEN TRUNC(l_start_date) AND TRUNC(NVL(l_end_date,okl_accounting_util.g_final_date))) OR
         (TRUNC(NVL(c_get_criteria_rec.effective_to_date,okl_accounting_util.g_final_date)) NOT BETWEEN TRUNC(l_start_date) AND TRUNC(NVL(l_end_date,okl_accounting_util.g_final_date)))
        )THEN
        fnd_message.set_name(G_APP_NAME, 'OKL_ELIGIBILITY_CRIT_CAT');
        okl_api.set_message(p_app_name     =>  G_APP_NAME
                           ,p_msg_name     =>  'OKL_INVALID_EFFECTIVE_DATES'
                           ,p_token1       =>  'CRIT_CAT'
                           ,p_token1_value =>  fnd_message.get
                           ,p_token2       =>  'NAME'
                           ,p_token2_value =>  c_get_criteria_rec.crit_cat_name);
        x_return_status := OKL_API.G_RET_STS_ERROR;
      END IF;
    END LOOP;
    -- END of code changes

    -- sjalasut, added more validations as part of the vendor residual share enhancement.START
    l_return_status := validate_residual_positive(p_chr_id => p_chr_id);
    IF(l_return_status = 'E')THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;

    l_return_status := validate_residual_parties(p_chr_id => p_chr_id);
    IF(l_return_status = 'E')THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;

    l_return_status := validate_total_residual(p_chr_id => p_chr_id);
    IF(l_return_status = 'E')THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    -- sjalasut, added more validations as part of the vendor residual share enhancement.END

    IF x_return_status = OKL_API.G_RET_STS_SUCCESS THEN
        OKL_API.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRPAQB.pls.pls call evaluate_territory');
    END IF;

    EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary; validation can continue with next column
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack
      OKL_API.SET_MESSAGE( p_app_name        => G_APP_NAME,
                           p_msg_name        => G_UNEXPECTED_ERROR,
                           p_token1	        => G_SQLCODE_TOKEN,
                           p_token1_value    => SQLCODE,
                           p_token2          => G_SQLERRM_TOKEN,
                           p_token2_value    => SQLERRM);
      -- notify caller of an error as UNEXPETED error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END check_functional_constraints;

END OKL_PA_DATA_INTEGRITY;

/
