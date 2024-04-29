--------------------------------------------------------
--  DDL for Package Body OKL_LRF_GENERATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LRF_GENERATE_PVT" AS
/* $Header: OKLRRFGB.pls 120.6 2006/08/09 14:18:26 pagarg noship $ */

/**
  This procedure caculates the lease rate factor for a given term-value pair.
  RSDPV = ((residual_value/100)/((1+((rate/100)*day_convention))**term));
  DFi = (1+(rate/100*day_convention))**i;
  LRF = (1-RSDPV)/(SUMOFALL[1/DFi]) i varies from first payment   to last payment
**/

  PROCEDURE calculate_lrf(p_arrears            IN             number --=1=yes/0=no;
                         ,p_rate               IN             number  --in %
                         ,p_day_convention     IN             number  --30/360
                         ,p_deffered_payments  IN             number
                         ,p_advance_payments   IN             number
                         ,p_term               IN             number
                         ,p_value              IN             number  -- in %(residual value)
                         ,p_frequency          IN             number  -- monthly=1 quarterly=3 semi annual=6 annual=12
                         ,p_lrf                   OUT NOCOPY  number) IS
    l_rsdpv         number;
    l_error         number;
    l_df            number;
    l_df_last_added number;
    l_pv            number;
    i               number;
    l_arrear        number;
    l_rate          number;
    l_dc            number;
    l_def           number;
    l_def_pmts      number;
    l_adv           number;
    l_adv_loop      number;
    l_term          number;
    l_value         number;
    l_freq          number;
    l_lrf           number;
    l_sum_one_by_df number;

  BEGIN
    l_arrear := p_arrears;
    l_rate := p_rate;
    l_dc := p_day_convention;
    l_def := p_deffered_payments;
    l_def_pmts := p_deffered_payments;
    l_adv := p_advance_payments;
    l_adv_loop := p_advance_payments;
    l_term := p_term;
    l_value := p_value;
    l_freq := p_frequency;
    l_sum_one_by_df := 0;
    l_rsdpv := ((l_value / 100) / ((1 + ((l_rate / 100) * l_dc)) ** l_term));
    /*
    dbms_output.put_line('resd val df = ' ||
                         ((1 + ((l_rate / 100) * l_dc)) ** l_term));
    dbms_output.put_line('resd val sumpv = ' ||
                         l_rsdpv);
    */
    i := l_arrear;

    --

    WHILE(i <= l_term + l_arrear - 1 - l_adv_loop) LOOP
      /*
      dbms_output.put_line('Timing = ' ||
                           i);
      */
      /*i represents  timing*/

      l_df := (1 + (l_rate / 100 * l_dc)) ** i;
      --l_pv := (l_lrf / l_df);
      /*
      dbms_output.put_line('   DF =' ||
                           l_df);
      */
      --

      /*if this i is payment  and we do not want to deffer this
      payment then add 1/df to sum_one_by_df*/

      IF (i - l_arrear) MOD l_freq = 0 AND l_def = 0 THEN

        --  l_sumpv := l_sumpv+l_pv;
        -- l_df_last_added := l_df;

        l_sum_one_by_df := l_sum_one_by_df + (1 / l_df);
        --dbms_output.put_line('   1/l_df added in Timing =' || i);
      END IF;
      /*
         if this i is payment  and payments to deffer > 0 then reduce the
         payments to deffer l_def by 1
      */

      IF (l_def > 0 AND ((i - l_arrear) MOD l_freq = 0)) THEN
        l_def := l_def - 1;
      END IF;

      /*increment timing only if all advance payments have been taken care of*/

      IF (l_adv > 0) THEN
        l_adv := l_adv - 1;
      ELSE
        i := i + 1;
      END IF;
      /*
      dbms_output.put_line('At timing  ' ||
                           i ||
                           ' l_sum_one_by_df= ' ||
                           l_sum_one_by_df);
      */
    END LOOP;
    /*
    dbms_output.put_line('l_sum_one_by_df before l_lrf computation = ' ||
                         l_sum_one_by_df);
    */
    l_lrf := (1 - l_rsdpv) / l_sum_one_by_df;
    p_lrf := l_lrf;
  END calculate_lrf;


  /**
    This function validates the residual tolerance. The residual tolerance
    should not be greater than (min of difference between pairs of terms).
  **/

  FUNCTION is_residual_tolerance_valid(p_lrf_table            lease_rate_tbl_type
                                      ,p_residual_tolerance   number) RETURN boolean IS
    mindiff number;
    diffij  number;

  BEGIN

    IF p_residual_tolerance = 0 OR p_lrf_table.COUNT = 1 THEN
      RETURN true;
    END IF;
    mindiff := abs(p_lrf_table(1).residual_value_percent - p_lrf_table(2).residual_value_percent);

    --find the minimum difference between terms

    FOR i IN p_lrf_table.FIRST..p_lrf_table.LAST - 1 LOOP
      FOR j IN i + 1..p_lrf_table.LAST LOOP
        diffij := abs(p_lrf_table(i).residual_value_percent - p_lrf_table(j).residual_value_percent);

        IF diffij < mindiff THEN
          mindiff := diffij;
        END IF;

      END LOOP;
    END LOOP;

    IF p_residual_tolerance >= mindiff / 2 THEN
      RETURN false;
    ELSE
      RETURN true;
    END IF;

  END is_residual_tolerance_valid;
/**
    This procedures  derives the term-value pairs from end of term and generates the
    lease rate factors.
**/

  PROCEDURE generate_lease_rate_factors(p_api_version          IN             number
                                       ,p_init_msg_list        IN             varchar2                                          DEFAULT fnd_api.g_false
                                       ,x_return_status           OUT NOCOPY  varchar2
                                       ,x_msg_count               OUT NOCOPY  number
                                       ,x_msg_data                OUT NOCOPY  varchar2
                                       ,p_rate_set_version_id                 okl_fe_rate_set_versions.rate_set_version_id%TYPE) IS

    CURSOR c_rate_set(csr_rate_set_version_id  IN  number) IS
      SELECT decode(b.arrears_yn, 'Y', 1, 0) arrears
            ,decode(a.frq_code, 'M', 1, 'Q', 3, 'S', 6, 'A', 12, 0) frequency
            ,nvl(b.deferred_pmts, 0) deferred_pmts
            ,nvl(b.advance_pmts, 0) advance_pmts
            ,b.lrs_rate
            ,b.effective_from_date
            ,b.end_of_term_ver_id
            ,b.std_rate_tmpl_ver_id
            ,nvl(b.residual_tolerance, 0) residual_tolerance
            ,b.rate_set_id
            ,b.standard_rate
      FROM   okl_ls_rt_fctr_sets_v a
            ,okl_fe_rate_set_versions b
      WHERE  a.id = b.rate_set_id
         AND b.rate_set_version_id = csr_rate_set_version_id;
    c_rate_set_rec c_rate_set%ROWTYPE;

    CURSOR get_srt_type_rate(csr_std_rate_tmpl_ver_id  IN  number) IS
      SELECT a.rate_type_code
            ,(b.srt_rate+nvl(b.spread,0)) srt_rate
      FROM   okl_fe_std_rt_tmp_v a
            ,okl_fe_std_rt_tmp_vers b
      WHERE  a.std_rate_tmpl_id = b.std_rate_tmpl_id
         AND b.std_rate_tmpl_ver_id = csr_std_rate_tmpl_ver_id;

    CURSOR get_srt_index_rate(csr_std_rate_tmpl_ver_id  IN  number
                             ,lrs_eff_from              IN  date) IS
      SELECT (c.value+nvl(b.spread,0)) value
      FROM   okl_fe_std_rt_tmp_v a
            ,okl_fe_std_rt_tmp_vers b
            ,okl_index_values c
      WHERE  a.std_rate_tmpl_id = b.std_rate_tmpl_id AND a.index_id = c.idx_id
         AND b.std_rate_tmpl_ver_id = csr_std_rate_tmpl_ver_id
         AND lrs_eff_from BETWEEN c.datetime_valid AND nvl(c.datetime_invalid, lrs_eff_from + 1);

    CURSOR get_eot_resd_type(eot_version_id  IN  number) IS
      SELECT a.eot_type_code
      FROM   okl_fe_eo_terms_v a
            ,okl_fe_eo_term_vers b
      WHERE  a.end_of_term_id = b.end_of_term_id
         AND b.end_of_term_ver_id = eot_version_id;

    CURSOR get_eot_values(eot_version_id  IN  number) IS
      SELECT eot_term
            ,eot_value
      FROM   okl_fe_eo_term_values a
      WHERE  a.end_of_term_ver_id = eot_version_id;

    CURSOR get_eot_category_code(eot_version_id  IN  number) IS
      SELECT category_type_code
      FROM   okl_fe_eo_terms_v a
            ,okl_fe_eo_term_vers b
      WHERE  a.end_of_term_id = b.end_of_term_id
         AND b.end_of_term_ver_id = eot_version_id;

    CURSOR get_item_resd_vals(eot_version_id             IN  number
                             ,p_lrs_effective_from_date  IN  date) IS
      SELECT DISTINCT irsval.term_in_months term_in_months
            ,irsval.residual_value residual_value
      FROM   okl_fe_eo_terms_v eoth
            ,okl_fe_eo_term_vers eotv
            ,okl_fe_eo_term_objects eoto
            ,OKL_FE_ITEM_RESIDUAL irsh
            ,okl_itm_cat_rv_prcs irsv
            ,okl_fe_item_resdl_values irsval
      WHERE  eoth.eot_type_code = 'RESIDUAL_PERCENT'
         AND eotv.end_of_term_ver_id = eot_version_id
         AND eoth.end_of_term_id = eotv.end_of_term_id
         AND eotv.end_of_term_ver_id = eoto.end_of_term_ver_id
         AND eoth.category_type_code = irsh.category_type_code
         AND eoth.category_type_code = 'ITEM'
         AND irsh.category_type_code = 'ITEM'
         AND irsh.residual_type_code = 'PERCENT'
         AND eoto.inventory_item_id = irsh.inventory_item_id
         AND eoto.organization_id = irsh.organization_id
         AND eoto.category_set_id = irsh.category_set_id
         AND irsh.item_residual_id = irsv.item_residual_id
         AND irsv.sts_code = 'ACTIVE'
         AND p_lrs_effective_from_date BETWEEN irsv.start_date AND nvl(irsv.end_date, to_date('01-01-9999', 'dd-mm-yyyy'))
         AND irsv.id = irsval.item_resdl_version_id;

    CURSOR get_itemcat_resd_vals(eot_version_id             IN  number
                                ,p_lrs_effective_from_date  IN  date) IS
      SELECT DISTINCT irsval.term_in_months term_in_months
            ,irsval.residual_value residual_value
      FROM   okl_fe_eo_terms_v eoth
            ,okl_fe_eo_term_vers eotv
            ,okl_fe_eo_term_objects eoto
            ,OKL_FE_ITEM_RESIDUAL irsh
            ,okl_itm_cat_rv_prcs irsv
            ,okl_fe_item_resdl_values irsval
      WHERE  eoth.eot_type_code = 'RESIDUAL_PERCENT'
         AND eotv.end_of_term_ver_id = eot_version_id
         AND eoth.end_of_term_id = eotv.end_of_term_id
         AND eoth.category_type_code = 'ITEMCAT'
         AND eotv.end_of_term_ver_id = eoto.end_of_term_ver_id
         AND eoth.category_type_code = irsh.category_type_code
         AND eoto.category_id = irsh.category_id
         AND eoto.category_set_id = irsh.category_set_id
         AND irsh.category_type_code = 'ITEMCAT'
         AND irsh.residual_type_code = 'PERCENT'
         AND irsh.item_residual_id = irsv.item_residual_id
         AND irsv.sts_code = 'ACTIVE'
         AND p_lrs_effective_from_date BETWEEN irsv.start_date AND nvl(irsv.end_date, to_date('01-01-9999', 'dd-mm-yyyy'))
         AND irsv.id = irsval.item_resdl_version_id;

    CURSOR get_resdcat_resd_vals(eot_version_id             IN  number
                                ,p_lrs_effective_from_date  IN  date) IS
      SELECT DISTINCT f.term_in_months
            ,f.residual_value
      FROM   okl_fe_eo_terms_v a
            ,okl_fe_eo_term_vers b
            ,okl_fe_eo_term_objects c
            ,OKL_FE_ITEM_RESIDUAL d
            ,okl_itm_cat_rv_prcs e
            ,okl_fe_item_resdl_values f
      WHERE  b.end_of_term_ver_id = eot_version_id
         AND a.end_of_term_id = b.end_of_term_id
         AND b.end_of_term_ver_id = c.end_of_term_ver_id
         AND a.category_type_code = d.category_type_code
         AND a.category_type_code = 'RESCAT'
         AND d.residual_type_code = 'PERCENT'
         AND c.resi_category_set_id = d.resi_category_set_id
         AND d.item_residual_id = e.item_residual_id
         AND e.sts_code = 'ACTIVE'
         AND p_lrs_effective_from_date BETWEEN e.start_date AND nvl(e.end_date, p_lrs_effective_from_date + 1)
         AND e.id = f.item_resdl_version_id;
    l_rate                         number := NULL;
    l_srt_type                     varchar2(30);
    l_eot_resd_type                varchar2(30);
    l_lease_rate_tbl               lease_rate_tbl_type;
    l_gen_lrf_tbl                  lease_rate_tbl_type;
    l_lrlv_tbl                     okl_lrlv_tbl;
    l_lrfv_tbl                     lrfv_tbl_type;
    lx_lrlv_tbl                    okl_lrlv_tbl;
    lx_lrfv_tbl                    lrfv_tbl_type;
    i                              number;
    j                              number;
    l_eot_category_code            varchar2(30);
    x_lrf                          number;
    l_day_conv                     number;
    lx_return_status               varchar2(1);
    l_api_name            CONSTANT varchar2(30) := 'gen_lrf';
    l_api_version         CONSTANT number := 1.0;
    l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.okl_lrf_generate_pvt.generate_lease_rate_factors';
    l_debug_enabled                varchar2(10);
    is_debug_procedure_on          boolean;
    is_debug_statement_on          boolean;

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'begin debug OKLRRFGB.pls call generate_lease_rate_factors');
    END IF;

    -- check for logging on STATEMENT level

    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_statement);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := okl_api.start_activity(p_api_name      =>  l_api_name
                                             ,p_pkg_name      =>  g_pkg_name
                                             ,p_init_msg_list =>  p_init_msg_list
                                             ,l_api_version   =>  l_api_version
                                             ,p_api_version   =>  p_api_version
                                             ,p_api_type      =>  g_api_type
                                             ,x_return_status =>  x_return_status);

    -- check if activity started successfully

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    --IF G_CP_MODE = 'Y' then the procedure is called in Concurrent program
    IF g_cp_mode IS NOT NULL THEN
      IF g_cp_mode <> 'Y' THEN
        g_cp_mode := 'N';
      END IF;
    ELSE
      g_cp_mode := 'N';
    END IF;
    -- take the lrs version attributes
    OPEN c_rate_set(p_rate_set_version_id);
    FETCH c_rate_set INTO c_rate_set_rec ;
    CLOSE c_rate_set;
    l_rate := c_rate_set_rec.lrs_rate;
    --if rate is not defined on lrs version then take it from srt version
    IF l_rate IS NULL THEN
      /*OPEN get_srt_type_rate(c_rate_set_rec.std_rate_tmpl_ver_id);
      FETCH get_srt_type_rate INTO l_srt_type
                                  ,l_rate ;
      CLOSE get_srt_type_rate;
      --if srt is of index rate type take rate from okl_index_values for lrs version effective from
      IF l_srt_type = 'INDEX' THEN
        OPEN get_srt_index_rate(c_rate_set_rec.std_rate_tmpl_ver_id
                               ,c_rate_set_rec.effective_from_date);
        FETCH get_srt_index_rate INTO l_rate ;
        CLOSE get_srt_index_rate;
      END IF;*/
      IF c_rate_set_rec.std_rate_tmpl_ver_id IS NOT NULL THEN
        l_rate := c_rate_set_rec.standard_rate;
      END IF;
    END IF;
    --if rate is still null then throw error
    IF l_rate IS NULL THEN  --set message Rate cannot be determined for RATE_SET_VERSION_ID
      okl_api.set_message(p_app_name =>  okl_api.g_app_name
                         ,p_msg_name =>  'OKL_RATE_UNDETERMINED_FOR_LRS');
      RAISE okl_api.g_exception_error;
    END IF;

    --get the eot residual  type
    OPEN get_eot_resd_type(c_rate_set_rec.end_of_term_ver_id);
    FETCH get_eot_resd_type INTO l_eot_resd_type ;
    CLOSE get_eot_resd_type;
    --if resd type=PERCENT take term value pairs from EOT version
    IF l_eot_resd_type = 'PERCENT' THEN
      i := 1;

      FOR term_val_rec IN get_eot_values(c_rate_set_rec.end_of_term_ver_id) LOOP  --populate term_val_rec and l_rate into l_lease_rate_tbl(i)
        l_lease_rate_tbl(i).term_in_months := term_val_rec.eot_term;
        l_lease_rate_tbl(i).residual_value_percent := term_val_rec.eot_value;
        l_lease_rate_tbl(i).interest_rate := l_rate;
        i := i + 1;
      END LOOP;

    END IF;
    --if resd RESIDUAL_PERCENT take term value pairs from item residual
    IF l_eot_resd_type = 'RESIDUAL_PERCENT' THEN  --take the category_type from EOT header
      OPEN get_eot_category_code(c_rate_set_rec.end_of_term_ver_id);
      FETCH get_eot_category_code INTO l_eot_category_code ;
      CLOSE get_eot_category_code;
      --if category_code= ITEM then fetch term value pairs from item residual of category type=item
      IF l_eot_category_code = 'ITEM' THEN
        i := 1;

        FOR term_val_rec IN get_item_resd_vals(c_rate_set_rec.end_of_term_ver_id
                                              ,c_rate_set_rec.effective_from_date) LOOP  --populate term_val_rec and l_rate into l_lease_rate_tbl(i)
          l_lease_rate_tbl(i).term_in_months := term_val_rec.term_in_months;
          l_lease_rate_tbl(i).residual_value_percent := term_val_rec.residual_value;
          l_lease_rate_tbl(i).interest_rate := l_rate;
          i := i + 1;
        END LOOP;
      --if category_code= ITEMCAT then fetch term value pairs from item residual of category type=ITEMCAT
      ELSIF l_eot_category_code = 'ITEMCAT' THEN
        i := 1;

        FOR term_val_rec IN get_itemcat_resd_vals(c_rate_set_rec.end_of_term_ver_id
                                                 ,c_rate_set_rec.effective_from_date) LOOP  --populate term_val_rec and l_rate into l_lease_rate_tbl(i)
          l_lease_rate_tbl(i).term_in_months := term_val_rec.term_in_months;
          l_lease_rate_tbl(i).residual_value_percent := term_val_rec.residual_value;
          l_lease_rate_tbl(i).interest_rate := l_rate;
          i := i + 1;
        END LOOP;
      --if category_code= RESCAT then fetch term value pairs from item residual of category type=RESICAT
      ELSIF l_eot_category_code = 'RESCAT' THEN
        i := 1;

        FOR term_val_rec IN get_resdcat_resd_vals(c_rate_set_rec.end_of_term_ver_id
                                                 ,c_rate_set_rec.effective_from_date) LOOP  --populate term_val_rec and l_rate into l_lease_rate_tbl(i)
          l_lease_rate_tbl(i).term_in_months := term_val_rec.term_in_months;
          l_lease_rate_tbl(i).residual_value_percent := term_val_rec.residual_value;
          l_lease_rate_tbl(i).interest_rate := l_rate;
          i := i + 1;
        END LOOP;

      END IF;
    END IF;

    --end of If l_eot_type = 'RESIDUAL_PERCENT'
    --if l_lease_rate_tbl is empty then throw error

    IF l_lease_rate_tbl.COUNT = 0 THEN
      NULL;  -- NO Term value pairs to generate lrf
      okl_api.set_message(p_app_name =>  okl_api.g_app_name
                         ,p_msg_name =>  'OKL_NO_VALID_TERM_VALUE_PAIRS');
      RAISE okl_api.g_exception_error;
    END IF;

    --validate following
    --validate that term is exact multiple of payment frequency
    --and no. of deferred payments are not greater than or equal to total payments
    --and no. of advance payments are not greater than or equal to total payments
    --do not generate lrf for records failing the validation

    j := 1;

    FOR i IN l_lease_rate_tbl.FIRST..l_lease_rate_tbl.LAST LOOP

      IF NOT ((l_lease_rate_tbl(i).term_in_months MOD c_rate_set_rec.frequency <> 0)
              OR (c_rate_set_rec.deferred_pmts >= (l_lease_rate_tbl(i).term_in_months / c_rate_set_rec.frequency))
              OR (c_rate_set_rec.advance_pmts >= (l_lease_rate_tbl(i).term_in_months / c_rate_set_rec.frequency))) THEN
        l_gen_lrf_tbl(j) := l_lease_rate_tbl(i);
        j := j + 1;
      END IF;

    END LOOP;  --if all records are to be ignored then throw error

    IF l_gen_lrf_tbl.COUNT = 0 THEN  -- NO Term value pairs to generate lrf
      okl_api.set_message(p_app_name =>  okl_api.g_app_name
                         ,p_msg_name =>  'OKL_NO_VALID_TERM_VALUE_PAIRS');
      RAISE okl_api.g_exception_error;
    END IF;

    --validate the residual tolerance
    --residual tolerance should not be greater than (min of difference between pairs of residual values)

    IF NOT is_residual_tolerance_valid(l_gen_lrf_tbl
                                      ,c_rate_set_rec.residual_tolerance) THEN
      okl_api.set_message(p_app_name =>  okl_api.g_app_name
                         ,p_msg_name =>  'OKL_INVALID_RESIDUAL_TOLERANCE');
      RAISE okl_api.g_exception_error;
    END IF;
    --generate the lease rate factors for term-value pairs in l_gen_lrf_tbl
    FOR i IN l_gen_lrf_tbl.FIRST..l_gen_lrf_tbl.LAST LOOP
      l_day_conv := 30 / 360;
      calculate_lrf(c_rate_set_rec.arrears
                   ,l_rate
                   ,l_day_conv
                   ,c_rate_set_rec.deferred_pmts
                   ,c_rate_set_rec.advance_pmts
                   ,l_gen_lrf_tbl(i).term_in_months
                   ,l_gen_lrf_tbl(i).residual_value_percent
                   ,c_rate_set_rec.frequency
                   ,x_lrf);  --if not valid then raise error else populate lrf
      l_gen_lrf_tbl(i).lease_rate_factor := trunc(x_lrf, 4);
    END LOOP;
    --delete lrf lines and corressponding levels from the okl_ls_rt_fctr_ents_b and okl_fe_lrs_levels table for this lrs version
    okl_lease_rate_factors_pvt.delete_lease_rate_factors(p_api_version   =>  p_api_version
                                                     ,p_init_msg_list =>  okl_api.g_false
                                                     ,x_return_status =>  lx_return_status
                                                     ,x_msg_count     =>  x_msg_count
                                                     ,x_msg_data      =>  x_msg_data
                                                     ,p_lrv_id        =>  p_rate_set_version_id);

    IF lx_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF lx_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;
    j := 1;  --for each record in l_gen_lrf_tbl do

    FOR i IN l_gen_lrf_tbl.FIRST..l_gen_lrf_tbl.LAST LOOP  --populate okl_lrl_tbl
      l_lrfv_tbl(i).id := i;
      l_lrfv_tbl(i).is_new_flag := 'Y';  --new record
      l_lrfv_tbl(i).lrt_id := c_rate_set_rec.rate_set_id;
      l_lrfv_tbl(i).rate_set_version_id := p_rate_set_version_id;
      l_lrfv_tbl(i).term_in_months := l_gen_lrf_tbl(i).term_in_months;
      l_lrfv_tbl(i).residual_value_percent := l_gen_lrf_tbl(i).residual_value_percent;
      l_lrfv_tbl(i).interest_rate := l_gen_lrf_tbl(i).interest_rate;
      l_lrfv_tbl(i).lease_rate_factor := l_gen_lrf_tbl(i).lease_rate_factor;

      IF g_cp_mode = 'Y' THEN
        fnd_file.put_line(fnd_file.log
                         ,'Term In Months = ' ||
                          l_lrfv_tbl(i).term_in_months);
        fnd_file.put_line(fnd_file.log
                         ,'Residual Value  in percent = ' ||
                          l_lrfv_tbl(i).residual_value_percent);
        fnd_file.put_line(fnd_file.log
                         ,'Interest Rate = ' ||
                          l_lrfv_tbl(i).interest_rate);
        fnd_file.put_line(fnd_file.log
                         ,'Lease Rate Factor = ' ||
                          l_lrfv_tbl(i).lease_rate_factor);
        fnd_file.put_line(fnd_file.log, 'Lease Rate Factor Levels: ');
      END IF;

      --if deferred_pmts > 0 then
      --       okl_lrl_tbl(1).period=deferred_pmts
      --       okl_lrl_tbl(1).rate_factor = 0
      --       okl_lrl_tbl(2).period=term/freq - deferred_pmts
      --       okl_lrl_tbl(2).rate_factor = l_lease_rate_tbl(i).lease_rate_factor
      --       okl_lrl_tbl(1).rate_set_version_id=p_lrf_tbl(i).rate_set_version_id
      --       okl_lrl_tbl(2).rate_set_version_id=p_lrf_tbl(i).rate_set_version_id

      IF c_rate_set_rec.deferred_pmts > 0 THEN
        l_lrlv_tbl(j).rate_set_level_id := NULL;
        l_lrlv_tbl(j).rate_set_id := c_rate_set_rec.rate_set_id;
        l_lrlv_tbl(j).rate_set_version_id := p_rate_set_version_id;
        l_lrlv_tbl(j).rate_set_factor_id := i;
        l_lrlv_tbl(j).periods := c_rate_set_rec.deferred_pmts;
        l_lrlv_tbl(j).lease_rate_factor := 0;
        l_lrlv_tbl(j).sequence_number := 1;
        IF g_cp_mode = 'Y' THEN
          fnd_file.put_line(fnd_file.log
                           ,'   Periods = ' ||
                            l_lrlv_tbl(j).periods);
          fnd_file.put_line(fnd_file.log
                           ,'   Lease Rate Factor = ' ||
                            l_lrlv_tbl(j).lease_rate_factor);
        END IF;
        j := j + 1;
        l_lrlv_tbl(j).rate_set_level_id := NULL;
        l_lrlv_tbl(j).rate_set_id := c_rate_set_rec.rate_set_id;
        l_lrlv_tbl(j).rate_set_version_id := p_rate_set_version_id;
        l_lrlv_tbl(j).rate_set_factor_id := i;
        l_lrlv_tbl(j).periods := (l_lrfv_tbl(i).term_in_months / c_rate_set_rec.frequency) - c_rate_set_rec.deferred_pmts;
        l_lrlv_tbl(j).lease_rate_factor := l_lrfv_tbl(i).lease_rate_factor;
        l_lrlv_tbl(j).sequence_number := 2;
        IF g_cp_mode = 'Y' THEN
          fnd_file.put_line(fnd_file.log
                           ,'   Periods = ' ||
                            l_lrlv_tbl(j).periods);
          fnd_file.put_line(fnd_file.log
                           ,'   Lease Rate Factor = ' ||
                            l_lrlv_tbl(j).lease_rate_factor);
        END IF;
        j := j + 1;

      --else if advance_pmts > 0 then
      --       okl_lrl_tbl(1).period=term/freq - advance_pmts
      --       okl_lrl_tbl(1).rate_factor = l_lease_rate_tbl(i).lease_rate_factor
      --       okl_lrl_tbl(2).period=advance_pmts
      --       okl_lrl_tbl(2).rate_factor = 0
      --       okl_lrl_tbl(1).rate_set_version_id=p_lrf_tbl(i).rate_set_version_id
      --       okl_lrl_tbl(2).rate_set_version_id=p_lrf_tbl(i).rate_set_version_id

      ELSIF c_rate_set_rec.advance_pmts > 0 THEN
        l_lrlv_tbl(j).rate_set_level_id := NULL;
        l_lrlv_tbl(j).rate_set_id := c_rate_set_rec.rate_set_id;
        l_lrlv_tbl(j).rate_set_version_id := p_rate_set_version_id;
        l_lrlv_tbl(j).rate_set_factor_id := i;
        l_lrlv_tbl(j).periods := 1;
        l_lrlv_tbl(j).lease_rate_factor := l_lrfv_tbl(i).lease_rate_factor * (c_rate_set_rec.advance_pmts + 1) ;
        l_lrlv_tbl(j).sequence_number := 1;
        IF g_cp_mode = 'Y' THEN
          fnd_file.put_line(fnd_file.log
                           ,'   Periods = ' ||
                            l_lrlv_tbl(j).periods);
          fnd_file.put_line(fnd_file.log
                           ,'   Lease Rate Factor = ' ||
                            l_lrlv_tbl(j).lease_rate_factor);
        END IF;
        j := j + 1;
        l_lrlv_tbl(j).rate_set_level_id := NULL;
        l_lrlv_tbl(j).rate_set_id := c_rate_set_rec.rate_set_id;
        l_lrlv_tbl(j).rate_set_version_id := p_rate_set_version_id;
        l_lrlv_tbl(j).rate_set_factor_id := i;
        l_lrlv_tbl(j).periods := (l_lrfv_tbl(i).term_in_months / c_rate_set_rec.frequency) - c_rate_set_rec.advance_pmts -1;
        l_lrlv_tbl(j).lease_rate_factor := l_lrfv_tbl(i).lease_rate_factor;
        l_lrlv_tbl(j).sequence_number := 2;
        IF g_cp_mode = 'Y' THEN
          fnd_file.put_line(fnd_file.log
                           ,'   Periods = ' ||
                            l_lrlv_tbl(j).periods);
          fnd_file.put_line(fnd_file.log
                           ,'   Lease Rate Factor = ' ||
                            l_lrlv_tbl(j).lease_rate_factor);
        END IF;
        IF l_lrlv_tbl(j).periods > 0 THEN
         j := j + 1;
        END IF;
        l_lrlv_tbl(j).rate_set_level_id := NULL;
        l_lrlv_tbl(j).rate_set_id := c_rate_set_rec.rate_set_id;
        l_lrlv_tbl(j).rate_set_version_id := p_rate_set_version_id;
        l_lrlv_tbl(j).rate_set_factor_id := i;
        l_lrlv_tbl(j).periods := c_rate_set_rec.advance_pmts;
        l_lrlv_tbl(j).lease_rate_factor := 0;
        l_lrlv_tbl(j).sequence_number := 3;
        IF g_cp_mode = 'Y' THEN
          fnd_file.put_line(fnd_file.log
                           ,'   Periods = ' ||
                            l_lrlv_tbl(j).periods);
          fnd_file.put_line(fnd_file.log
                           ,'   Lease Rate Factor = ' ||
                            l_lrlv_tbl(j).lease_rate_factor);
        END IF;
        j := j + 1;

      --else (level)
      --       okl_lrl_tbl(1).period=term/freq
      --       okl_lrl_tbl(1).rate_factor = l_lease_rate_tbl(i).lease_rate_factor
      --       okl_lrl_tbl(1).rate_set_version_id=p_lrf_tbl(i).rate_set_version_id

      ELSE
        l_lrlv_tbl(j).rate_set_level_id := NULL;
        l_lrlv_tbl(j).rate_set_id := c_rate_set_rec.rate_set_id;
        l_lrlv_tbl(j).rate_set_version_id := p_rate_set_version_id;
        l_lrlv_tbl(j).rate_set_factor_id := i;
        l_lrlv_tbl(j).periods := (l_lrfv_tbl(i).term_in_months / c_rate_set_rec.frequency);
        l_lrlv_tbl(j).lease_rate_factor := l_lrfv_tbl(i).lease_rate_factor;
        l_lrlv_tbl(j).sequence_number := 1;
        IF g_cp_mode = 'Y' THEN
          fnd_file.put_line(fnd_file.log
                           ,'   Periods = ' ||
                            l_lrlv_tbl(j).periods);
          fnd_file.put_line(fnd_file.log
                           ,'   Lease Rate Factor = ' ||
                            l_lrlv_tbl(j).lease_rate_factor);
        END IF;
        j := j + 1;
      END IF;

    END LOOP;

    IF g_cp_mode = 'Y' THEN
      fnd_file.put_line(fnd_file.log, 'Inserting into okl_ls_rt_fctr_ents');
    END IF;
    --call handlelrf API  to insert levels and factors
    okl_lease_rate_factors_pvt.handle_lrf_ents(p_api_version   =>  p_api_version
                                           ,p_init_msg_list =>  okl_api.g_false
                                           ,x_return_status =>  lx_return_status
                                           ,x_msg_count     =>  x_msg_count
                                           ,x_msg_data      =>  x_msg_data
                                           ,p_lrfv_tbl      =>  l_lrfv_tbl
                                           ,x_lrfv_tbl      =>  lx_lrfv_tbl
                                           ,p_lrlv_tbl      =>  l_lrlv_tbl
                                           ,x_lrlv_tbl      =>  lx_lrlv_tbl);

    IF lx_return_status = g_ret_sts_error THEN
      RAISE okl_api.g_exception_error;
    ELSIF lx_return_status = g_ret_sts_unexp_error THEN
      RAISE okl_api.g_exception_unexpected_error;
    END IF;
    x_return_status := lx_return_status;
    okl_api.end_activity(x_msg_count =>  x_msg_count
                        ,x_msg_data  =>  x_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRRFGB.pls call generate_lease_rate_factors');
    END IF;

    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>  l_api_name
                                                    ,p_pkg_name  =>  g_pkg_name
                                                    ,p_exc_name  =>  'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count =>  x_msg_count
                                                    ,x_msg_data  =>  x_msg_data
                                                    ,p_api_type  =>  g_api_type);
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>  l_api_name
                                                    ,p_pkg_name  =>  g_pkg_name
                                                    ,p_exc_name  =>  'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count =>  x_msg_count
                                                    ,x_msg_data  =>  x_msg_data
                                                    ,p_api_type  =>  g_api_type);
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(p_api_name  =>  l_api_name
                                                    ,p_pkg_name  =>  g_pkg_name
                                                    ,p_exc_name  =>  'OTHERS'
                                                    ,x_msg_count =>  x_msg_count
                                                    ,x_msg_data  =>  x_msg_data
                                                    ,p_api_type  =>  g_api_type);
  END generate_lease_rate_factors;


/**
   This procedure is called from concurrent program to generate the lease rate factors.
**/
  PROCEDURE generate_lrf(errbuf                    OUT NOCOPY  varchar2
                        ,retcode                   OUT NOCOPY  varchar2
                        ,p_rate_set_version_id  IN             number
                        ,p_start_date           IN             varchar2
                        ,p_end_date             IN             varchar2) IS
    l_proc_name     CONSTANT varchar2(30) := 'generate_lrf';
    x_msg_count              number;
    x_msg_data               varchar2(2000);
    l_return_status          varchar2(1) := g_ret_sts_success;
    param_error EXCEPTION;
    l_rate_set_version_id number;
    l_start_date          date;
    l_end_date            date;
    l_data                varchar2(2000);
    l_msg_index_out       number;

    CURSOR get_lrs_versions(p_start_date  IN  date
                           ,p_end_date    IN  date) IS
      SELECT rate_set_version_id
      FROM   okl_fe_rate_set_versions
      WHERE  effective_from_date BETWEEN p_start_date AND nvl(p_end_date, to_date('01-01-9999', 'dd-mm-yyyy'))
         AND sts_code = 'NEW' AND rate_set_id NOT IN(SELECT id
             FROM   okl_ls_rt_fctr_sets_v WHERE  lrs_type_code = 'MANUAL');

  BEGIN

    -- The parameter retcode returns 0 for success,
    -- 1 for success with warnings, and 2 for error.

    retcode := 0;
    l_rate_set_version_id := p_rate_set_version_id;
    l_start_date := fnd_date.canonical_to_date(p_start_date);
    l_end_date := fnd_date.canonical_to_date(p_end_date);
    g_cp_mode := 'Y';
    fnd_file.put_line(fnd_file.log, 'OKL Generate Lease Rate Factors');
    fnd_file.put_line(fnd_file.log, '================================');
    fnd_file.put_line(fnd_file.log, ' ');

    IF l_rate_set_version_id IS NULL AND l_start_date IS NULL THEN
      fnd_file.put_line(fnd_file.log
                       ,'ERROR: Either of Rate Set Version Or Effective Dates must be entered');
      l_return_status := g_ret_sts_error;
      retcode := 2;
      RAISE param_error;
    END IF;

    IF l_rate_set_version_id IS NOT NULL THEN
      fnd_file.put_line(fnd_file.log
                       ,'Generating lease rate factors for Rate Set Version Id :' ||
                        l_rate_set_version_id);

      --generate lease rate factors

      okl_lrf_generate_pvt.generate_lease_rate_factors(p_api_version         =>  g_api_version
                                                      ,p_init_msg_list       =>  g_true
                                                      ,x_return_status       =>  l_return_status
                                                      ,x_msg_count           =>  x_msg_count
                                                      ,x_msg_data            =>  x_msg_data
                                                      ,p_rate_set_version_id =>  l_rate_set_version_id);
      IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
        fnd_file.put_line(fnd_file.log
                         ,'Unexpected error in call to okl_lrf_generate_pvt.generate_lease_rate_factors');
        RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
        fnd_file.put_line(fnd_file.log
                         ,'Error in call to okl_lrf_generate_pvt.generate_lease_rate_factors');
        RAISE okl_api.g_exception_error;
      END IF;
    ELSE

      FOR lrv IN get_lrs_versions(l_start_date, l_end_date) LOOP
        l_rate_set_version_id := lrv.rate_set_version_id;
        fnd_file.put_line(fnd_file.log
                         ,'Generating lease rate factors for Rate Set Version Id :' ||
                          l_rate_set_version_id);

        --generate lease rate factors

        okl_lrf_generate_pvt.generate_lease_rate_factors(p_api_version         =>  g_api_version
                                                        ,p_init_msg_list       =>  g_true
                                                        ,x_return_status       =>  l_return_status
                                                        ,x_msg_count           =>  x_msg_count
                                                        ,x_msg_data            =>  x_msg_data
                                                        ,p_rate_set_version_id =>  l_rate_set_version_id);
        IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
          fnd_file.put_line(fnd_file.log
                           ,'Unexpected error in call to okl_lrf_generate_pvt.generate_lease_rate_factors');
          RAISE okl_api.g_exception_unexpected_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
          fnd_file.put_line(fnd_file.log
                           ,'Error in call to okl_lrf_generate_pvt.generate_lease_rate_factors');

          -- RAISE OKL_API.G_EXCEPTION_ERROR;
          -- print the error message in the log file

          IF (fnd_msg_pub.count_msg > 0) THEN
            FOR l_counter IN 1..fnd_msg_pub.count_msg LOOP
              fnd_msg_pub.get(p_msg_index     =>  l_counter
                             ,p_encoded       =>  'F'
                             ,p_data          =>  l_data
                             ,p_msg_index_out =>  l_msg_index_out);
              fnd_file.put_line(fnd_file.log, l_data);
            END LOOP;
          END IF;
        END IF;
      END LOOP;

    END IF;
    fnd_file.put_line(fnd_file.log, ' ');
    fnd_file.put_line(fnd_file.log, '            End              ');
    fnd_file.put_line(fnd_file.log, '================================');
    fnd_file.close;
    EXCEPTION
      WHEN param_error THEN
        retcode := 0;
        fnd_file.put_line(fnd_file.log
                         ,'Generate Lease Rate Factors Concurrent program completed with errors.');

        --close all open cursors

        IF get_lrs_versions%ISOPEN THEN
          CLOSE get_lrs_versions;
        END IF;

      WHEN okl_api.g_exception_error THEN
        retcode := 2;

        --close all open cursors

        IF get_lrs_versions%ISOPEN THEN
          CLOSE get_lrs_versions;
        END IF;

        -- print the error message in the output file

        IF (fnd_msg_pub.count_msg > 0) THEN

          FOR l_counter IN 1..fnd_msg_pub.count_msg LOOP
            fnd_msg_pub.get(p_msg_index     =>  l_counter
                           ,p_encoded       =>  'F'
                           ,p_data          =>  l_data
                           ,p_msg_index_out =>  l_msg_index_out);
            fnd_file.put_line(fnd_file.log, l_data);
          END LOOP;

        END IF;

      WHEN okl_api.g_exception_unexpected_error THEN
        retcode := 2;

        --close all open cursors

        IF get_lrs_versions%ISOPEN THEN
          CLOSE get_lrs_versions;
        END IF;

        -- print the error message in the output file

        IF (fnd_msg_pub.count_msg > 0) THEN

          FOR l_counter IN 1..fnd_msg_pub.count_msg LOOP
            fnd_msg_pub.get(p_msg_index     =>  l_counter
                           ,p_encoded       =>  'F'
                           ,p_data          =>  l_data
                           ,p_msg_index_out =>  l_msg_index_out);
            fnd_file.put_line(fnd_file.log, l_data);
          END LOOP;

        END IF;

      WHEN OTHERS THEN
        retcode := 2;
        errbuf := sqlerrm;

        --close all open cursors

        IF get_lrs_versions%ISOPEN THEN
          CLOSE get_lrs_versions;
        END IF;

        -- print the error message in the output file

        IF (fnd_msg_pub.count_msg > 0) THEN

          FOR l_counter IN 1..fnd_msg_pub.count_msg LOOP
            fnd_msg_pub.get(p_msg_index     =>  l_counter
                           ,p_encoded       =>  'F'
                           ,p_data          =>  l_data
                           ,p_msg_index_out =>  l_msg_index_out);
            fnd_file.put_line(fnd_file.log, l_data);
          END LOOP;

        END IF;
        fnd_file.put_line(fnd_file.log, sqlerrm);
  END generate_lrf;
End OKL_LRF_GENERATE_PVT;

/
