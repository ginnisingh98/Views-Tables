--------------------------------------------------------
--  DDL for Package Body OKL_EC_UPTAKE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_EC_UPTAKE_PVT" AS
/* $Header: OKLRECXB.pls 120.25 2006/09/26 07:24:23 varangan noship $*/
  ---------------------------------------------------------------------------
  --Added by ssdeshpa to have EC uptakes on LRs,SRT of Lease Quote
  ---------------------------------------------------------------------------


    PROCEDURE populate_lq_attributes(l_okl_ec_rec_type IN OUT NOCOPY okl_ec_evaluate_pvt.okl_ec_rec_type ,
                                     p_target_id number
                                     ,x_return_status OUT NOCOPY VARCHAR2) IS

        i                   INTEGER;
        l_msg_count         NUMBER;
        l_module            CONSTANT fnd_log_messages.module%TYPE := 'ECUPTAKE';
        l_debug_enabled                varchar2(10);
        is_debug_procedure_on          boolean;
        is_debug_statement_on          boolean;
        x_msg_data                     VARCHAR2(2000);
        l_api_version         CONSTANT number := 1.0;
        l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
        l_program_name        CONSTANT VARCHAR2(30) := 'populate';
        l_api_name            CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
        l_init_msg_list       VARCHAR2(3);
        l_parent_object_id    NUMBER;
        l_parent_object_code  VARCHAR2(30);
        l_expected_start_date DATE;
        l_term  NUMBER;
        l_deal_size NUMBER;
        l_adj_amount NUMBER;

        CURSOR c_lq_rec(p_lease_quote_id NUMBER) IS
          SELECT PARENT_OBJECT_ID,PARENT_OBJECT_CODE,EXPECTED_START_DATE,TERM
          FROM OKL_LEASE_QUOTES_V
          where id=p_lease_quote_id;

        CURSOR c_lop_rec(p_parent_object_id NUMBER) IS
          select lop.id,
                 lop.reference_number,
                 lop.prospect_id,
                 lop.prospect_address_id,
                 lop.cust_acct_id,
                 OKL_LEASE_APP_PVT.get_credit_classfication(
                      lop.prospect_id,
                      lop.cust_acct_id,
                      NULL) as customer_credit_class,
                 lop.sales_rep_id,
                 lop.sales_territory_id,
                 lop.currency_code
          from okl_lease_opportunities_v lop
          where lop.id=p_parent_object_id;

          l_lop_rec  c_lop_rec%ROWTYPE;

          CURSOR c_lapp_rec(p_parent_object_id NUMBER) IS
          select lapp.id,
                 lapp.reference_number,
                 lapp.prospect_id,
                 lapp.prospect_address_id,
                 lapp.cust_acct_id,
                 OKL_LEASE_APP_PVT.get_credit_classfication(
                      lapp.prospect_id,
                      lapp.cust_acct_id,
                      NULL) as customer_credit_class,
                 lapp.sales_rep_id,
                 lapp.sales_territory_id,
                 lapp.currency_code
          from okl_lease_applications_v lapp
          where lapp.id=p_parent_object_id;

          l_lapp_rec  c_lapp_rec%ROWTYPE;
          --Bug 5045505 ssdeshpa start
          --Added Cursors to get Deal Size of LQ
          CURSOR c_deal_size_cur(p_parent_object_id NUMBER) IS
            select SUM(OEC)
            FROM OKL_LEASE_QUOTES_B OLQ,OKL_ASSETS_B OAB
            where OAB.PARENT_OBJECT_ID = OLQ.ID
            AND OAB.PARENT_OBJECT_CODE='LEASEQUOTE'
            AND OLQ.ID= p_parent_object_id;

          cursor c_lq_cost_adj_rec(p_quote_id NUMBER,p_adj_type VARCHAR2) IS
             SELECT SUM(NVL(VALUE,0))
             FROM OKL_COST_ADJUSTMENTS_B OCA,
                  OKL_ASSETS_B OAB
             where OAB.PARENT_OBJECT_CODE = 'LEASEQUOTE'
             AND OCA.PARENT_OBJECT_CODE='ASSET'
             AND OCA.PARENT_OBJECT_ID=OAB.ID
             and ADJUSTMENT_SOURCE_TYPE =p_adj_type
             AND OAB.PARENT_OBJECT_ID = p_quote_id;

          CURSOR c_cost_comp_cur(p_quote_id NUMBER) IS
              select OAC.INV_ITEM_ID
              from OKL_ASSET_COMPONENTS_B OAC,
                   OKL_ASSETS_B OAB
              WHERE OAC.ASSET_ID = OAB.ID
              AND OAB.PARENT_OBJECT_CODE = 'LEASEQUOTE'
              AND PRIMARY_COMPONENT='YES'
              AND OAB.PARENT_OBJECT_ID = p_quote_id;
          --Bug 5045505 ssdeshpa start
          BEGIN
             l_debug_enabled := okl_debug_pub.check_log_enabled;
             is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                    ,fnd_log.level_procedure);


             IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                 okl_debug_pub.log_debug(fnd_log.level_procedure
                                        ,l_module
                                         ,'begin debug OKLRECXB.pls call populate_lq_attributes');
             END IF;  -- check for logging on STATEMENT level
             is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                                   ,fnd_log.level_statement);
             -- call START_ACTIVITY to create savepoint, check compatibility
             -- and initialize message list
             l_return_status := okl_api.start_activity(p_api_name      => l_api_name
                                                      ,p_pkg_name      => G_PKG_NAME
                                                      ,p_init_msg_list => l_init_msg_list
                                                      ,l_api_version   => l_api_version
                                                      ,p_api_version   => l_api_version
                                                      ,p_api_type      => G_API_TYPE
                                                      ,x_return_status => x_return_status);  -- check if activity started successfully

             IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
                 RAISE okl_api.g_exception_unexpected_error;
             ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
                 RAISE okl_api.g_exception_error;
             END IF;

             OPEN  c_lq_rec(p_target_id);
             FETCH c_lq_rec INTO l_parent_object_id,l_parent_object_code,l_expected_start_date,l_term;
             CLOSE c_lq_rec;
             l_okl_ec_rec_type.target_eff_from:=l_expected_start_date;
             l_okl_ec_rec_type.term:=l_term;
             --Bug 5045505 ssdeshpa start
             --Get Total Down Payment For Quote
             OPEN  c_lq_cost_adj_rec(p_target_id,'DOWN_PAYMENT');
             FETCH c_lq_cost_adj_rec INTO l_adj_amount;
             CLOSE c_lq_cost_adj_rec;
             l_okl_ec_rec_type.down_payment := l_adj_amount;
             --Get Total Down Payment For Quote

             --Get Total Trade In For Quote
             OPEN  c_lq_cost_adj_rec(p_target_id,'TRADEIN');
             FETCH c_lq_cost_adj_rec INTO l_adj_amount;
             CLOSE c_lq_cost_adj_rec;
             l_okl_ec_rec_type.trade_in_value := l_adj_amount;
             --Get Total Trade In For Quote

             --Get Item Tables for LQ
             i := 1;
             FOR l_cost_comp_rec IN c_cost_comp_cur(p_target_id) LOOP
                 l_okl_ec_rec_type.item_table(i) := l_cost_comp_rec.INV_ITEM_ID;
                 i := i + 1;
             END LOOP;

             --End Get Items Table For LQ
             --Get Deal Size For LQ
             OPEN  c_deal_size_cur(p_target_id);
             FETCH c_deal_size_cur INTO l_deal_size;
             CLOSE c_deal_size_cur;
             l_okl_ec_rec_type.deal_size:=l_deal_size;
             --Bug 5045505 ssdeshpa end
             if(l_parent_object_code='LEASEOPP') THEN

             OPEN c_lop_rec(l_parent_object_id);
             FETCH c_lop_rec INTO l_lop_rec;
                l_okl_ec_rec_type.territory:= l_lop_rec.sales_territory_id;
                l_okl_ec_rec_type.customer_credit_class:= l_lop_rec.customer_credit_class;
                l_okl_ec_rec_type.currency_code := l_lop_rec.currency_code;
            CLOSE c_lop_rec;
            ELSIF(l_parent_object_code='LEASEAPP') THEN
              OPEN c_lapp_rec(l_parent_object_id);
             FETCH c_lapp_rec INTO l_lapp_rec;
                l_okl_ec_rec_type.territory:= l_lapp_rec.sales_territory_id;
                l_okl_ec_rec_type.customer_credit_class:= l_lapp_rec.customer_credit_class;
                l_okl_ec_rec_type.currency_code := l_lapp_rec.currency_code;
               CLOSE c_lapp_rec;
             END IF;

            IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
              okl_debug_pub.log_debug(fnd_log.level_statement
                                     ,l_module
                                     ,'okl_ec_uptake_pvt.populate_lq_attributes returned with status ' ||
                                     l_return_status ||
                                     ' x_msg_data ' ||
                                     x_msg_data);
            END IF;  -- end of NVL(l_debug_enabled,'N')='Y'

            IF (l_return_status = okl_api.g_ret_sts_error) THEN
              RAISE okl_api.g_exception_error;
            ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
              RAISE okl_api.g_exception_unexpected_error;
            END IF;
           okl_api.end_activity(x_msg_count =>  l_msg_count
                                ,x_msg_data  => x_msg_data);

            IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
              okl_debug_pub.log_debug(fnd_log.level_procedure
                                     ,l_module
                                     ,'end debug OKL_EC_UPTAKE_PVT.pls call populate_lq_attributes');
            END IF;
        EXCEPTION
         WHEN okl_api.g_exception_error THEN

            x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                        ,p_pkg_name  =>                G_PKG_NAME
                                                        ,p_exc_name  =>                'OKL_API.G_RET_STS_ERROR'
                                                        ,x_msg_count =>                l_msg_count
                                                        ,x_msg_data  =>                x_msg_data
                                                        ,p_api_type  =>                G_API_TYPE);

          WHEN okl_api.g_exception_unexpected_error THEN

            x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                        ,p_pkg_name  =>                G_PKG_NAME
                                                        ,p_exc_name  =>                'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                        ,x_msg_count =>                l_msg_count
                                                        ,x_msg_data  =>                x_msg_data
                                                        ,p_api_type  =>                G_API_TYPE);

          WHEN OTHERS THEN

            x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                        ,p_pkg_name  =>                G_PKG_NAME
                                                        ,p_exc_name  =>                'OTHERS'
                                                        ,x_msg_count =>                l_msg_count
                                                        ,x_msg_data  =>                x_msg_data
                                                        ,p_api_type  =>                G_API_TYPE);

      END populate_lq_attributes;


      FUNCTION get_vp_id(p_target_id number) RETURN NUMBER IS

        l_vendor_prog_id               NUMBER;
        l_module              CONSTANT fnd_log_messages.module%TYPE := 'lrs';
        l_debug_enabled                varchar2(10);
        is_debug_procedure_on          boolean;
        is_debug_statement_on          boolean;
        l_api_version         CONSTANT number := 1.0;
        l_program_name        CONSTANT VARCHAR2(30) := 'get_vp_id';
        l_api_name            CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
        l_parent_object_id    NUMBER;
        l_parent_object_code  VARCHAR2(30);

        CURSOR c_lq_rec(p_lease_quote_id NUMBER) IS
          SELECT PARENT_OBJECT_ID,PARENT_OBJECT_CODE
          FROM OKL_LEASE_QUOTES_b
          where id=p_lease_quote_id;
        CURSOR c_lop_rec(p_object_id NUMBER) IS
          select PROGRAM_AGREEMENT_ID
          from okl_lease_opportunities_b
          where id=p_object_id;
        CURSOR c_lap_rec(p_object_id NUMBER) IS
          select PROGRAM_AGREEMENT_ID
          from okl_lease_applications_b
          where id=p_object_id;

        BEGIN
          OPEN  c_lq_rec(p_target_id);
                FETCH c_lq_rec INTO l_parent_object_id,l_parent_object_code;
                CLOSE c_lq_rec;
          IF(l_parent_object_id IS NOT NULL AND l_parent_object_code IS NOT NULL) THEN
           if(l_parent_object_code='LEASEOPP') THEN
              OPEN c_lop_rec(l_parent_object_id);
              FETCH c_lop_rec INTO l_vendor_prog_id;
              CLOSE c_lop_rec;
           ELSIF(l_parent_object_code='LEASEAPP') THEN
              OPEN c_lap_rec(l_parent_object_id);
              FETCH c_lap_rec INTO l_vendor_prog_id;
              CLOSE c_lap_rec;
           END IF;
          END IF;
          return l_vendor_prog_id;
          EXCEPTION
          WHEN OTHERS THEN
            OKL_API.SET_MESSAGE(p_app_name  => G_APP_NAME,
                             p_msg_name     => G_DB_ERROR,
                             p_token1       => G_PROG_NAME_TOKEN,
                             p_token1_value => l_api_name,
                             p_token2       => G_SQLCODE_TOKEN,
                             p_token2_value => sqlcode,
                             p_token3       => G_SQLERRM_TOKEN,
                             p_token3_value => sqlerrm);
     END get_vp_id;
     -------------------------------------------------------------------------------
    --Populate Lease Rate Set For Quick Quote
    --------------------------------------------------------------------------------
     PROCEDURE populate_lease_rate_set(p_api_version            IN  NUMBER,
                                        p_init_msg_list         IN  VARCHAR2,
                                        p_target_id             IN  NUMBER,
                                        p_target_type               VARCHAR2,
                                        p_target_eff_from           DATE,
                                        p_term                      NUMBER,
                                        p_territory                 VARCHAR2,
                                        p_deal_size                 NUMBER,
                                        p_customer_credit_class     VARCHAR2,
                                        p_down_payment              NUMBER,
                                        p_advance_rent              NUMBER,
                                        p_trade_in_value            NUMBER,
                                        --Bug # 5045505 ssdeshpa start
                                        p_currency_code               VARCHAR2,
                                        --Bug # 5045505 ssdeshpa End
                                        p_item_table                okl_number_table_type,
                                        p_item_categories_table     okl_number_table_type,
                                        x_okl_lrs_table           OUT NOCOPY okl_lease_rate_set_tbl_type,
                                        x_return_status           OUT NOCOPY VARCHAR2,
                                        x_msg_count               OUT NOCOPY NUMBER,
                                        x_msg_data                OUT NOCOPY VARCHAR2) IS

        --l_return_status    VARCHAR2(1);
        l_program_name      CONSTANT VARCHAR2(30) := 'p_lrs';
        l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
        l_okl_lrs_rec       okl_lease_rate_set_rec_type;
        l_okl_ec_rec_type   okl_ec_evaluate_pvt.okl_ec_rec_type;
        l_okl_lrs_table     okl_lease_rate_set_tbl_type;
        i                   INTEGER;
        l_module            CONSTANT fnd_log_messages.module%TYPE := 'lrs1';
        l_debug_enabled     varchar2(10);
        is_debug_procedure_on          boolean;
        is_debug_statement_on          boolean;
        l_api_version         CONSTANT number := 1.0;
        l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
        x_eligible            boolean;
        l_validation_mode VARCHAR2(30);
        --Bug # 5045505 ssdeshpa Start
        --Modified Cursor in order to filtered the LRS on currency Code
        CURSOR c_lrs_rec(effective_start_date DATE,
                         p_currency_code VARCHAR2) IS
          select lrs.id,
                 lrv.rate_set_version_id,
                 lrv.version_number,
                 lrs.name,
                 lrs.description,
                 lrv.effective_from_date effective_from,
                 lrv.effective_to_date effective_to,
                 --Bug # 5050143 start
                 nvl(lrv.lrs_rate,lrv.standard_rate) lrs_rate,
                 --Bug # 5050143 End
                 lrv.sts_code,
                 lrs.frq_code
          from okl_ls_rt_fctr_sets_v lrs,okl_fe_rate_set_versions_v lrv
          where  effective_start_date between lrv.effective_from_date and NVL(lrv.effective_to_date,effective_start_date+1)
          and lrs.id=lrv.rate_set_id
          and lrv.sts_code='ACTIVE'
          and lrs.lrs_type_code='LEVEL'
          AND lrs.currency_code = p_currency_code;
      -- Bug # 5045505 ssdeshpa End;

      BEGIN
      l_debug_enabled := okl_debug_pub.check_log_enabled;
      is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                            ,fnd_log.level_procedure);


        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'begin debug OKLRECXB.pls call populate_lrs1');
        END IF;  -- check for logging on STATEMENT level
        is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                           ,fnd_log.level_statement);

        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list

        l_return_status := okl_api.start_activity(p_api_name      => l_api_name
                                                 ,p_pkg_name      => G_PKG_NAME
                                                 ,p_init_msg_list => p_init_msg_list
                                                 ,l_api_version   => l_api_version
                                                 ,p_api_version   => p_api_version
                                                 ,p_api_type      => G_API_TYPE
                                                 ,x_return_status => x_return_status);  -- check if activity started successfully

        IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        END IF;
       --Populate the Record Structure for the OKL_ECC_PUB.validate method
        --l_okl_ec_rec_type.target
        l_okl_ec_rec_type.src_type:='LRS';
        l_okl_ec_rec_type.target_id:= p_target_id;
        l_okl_ec_rec_type.target_type:= p_target_type;
        l_okl_ec_rec_type.target_eff_from:= P_target_eff_from;
        l_okl_ec_rec_type.term:= p_term;
        l_okl_ec_rec_type.territory:= p_territory;
        l_okl_ec_rec_type.deal_size:= p_deal_size;
        l_okl_ec_rec_type.customer_credit_class:= p_customer_credit_class;
        l_okl_ec_rec_type.down_payment:= p_down_payment;
        l_okl_ec_rec_type.advance_rent:= p_advance_rent;
        l_okl_ec_rec_type.trade_in_value:= p_trade_in_value;
        l_okl_ec_rec_type.validation_mode:= 'LOV';
        --Bug # 5045505 ssdeshpa start
        l_okl_ec_rec_type.currency_code := p_currency_code;
        --Bug # 5045505 ssdeshpa End
        --Bug # 5050143 ssdeshpa start
        FOR i IN p_item_categories_table.FIRST..p_item_categories_table.LAST LOOP
            IF p_item_categories_table.EXISTS(i) THEN
               l_okl_ec_rec_type.item_categories_table(i) := p_item_categories_table(i);
            END IF;
        END LOOP;
        --Bug # 5050143 ssdeshpa end
        i:=1;
        FOR l_okl_lrs_rec IN c_lrs_rec(p_target_eff_from,p_currency_code)LOOP
           l_okl_ec_rec_type.src_id:=l_okl_lrs_rec.rate_set_version_id;
           l_okl_ec_rec_type.source_name:=l_okl_lrs_rec.name;

           OKL_ECC_PUB.evaluate_eligibility_criteria(p_api_version
                                                    ,p_init_msg_list
                                                    ,x_return_status
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,l_okl_ec_rec_type
                                                    ,x_eligible);

           IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
             RAISE okl_api.g_exception_unexpected_error;
           ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
              RAISE okl_api.g_exception_error;
           END IF;
           IF(x_eligible) THEN
              l_okl_lrs_table(i).id:=l_okl_lrs_rec.id;
              l_okl_lrs_table(i).name:=l_okl_lrs_rec.name;
              l_okl_lrs_table(i).rate_set_version_id:=l_okl_lrs_rec.rate_set_version_id;
              l_okl_lrs_table(i).version_number:=l_okl_lrs_rec.version_number;
              l_okl_lrs_table(i).description:=l_okl_lrs_rec.description;
              l_okl_lrs_table(i).effective_from:=l_okl_lrs_rec.effective_from;
              l_okl_lrs_table(i).effective_to:=l_okl_lrs_rec.effective_to;
              l_okl_lrs_table(i).lrs_rate:=l_okl_lrs_rec.lrs_rate;
              l_okl_lrs_table(i).sts_code:=l_okl_lrs_rec.sts_code;
              l_okl_lrs_table(i).frq_code:=l_okl_lrs_rec.frq_code;
              l_okl_lrs_table(i).frq_meaning:= OKL_ACCOUNTING_UTIL.get_lookup_meaning('OKL_FREQUENCY',l_okl_lrs_rec.frq_code);
              i:=i+1;
           END IF;
        END LOOP;

        x_okl_lrs_table:=l_okl_lrs_table;

        IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_statement
                                 ,l_module
                                 ,'okl_ec_uptake_pvt.populate_lease_rate_set returned with status ' ||
                                  l_return_status ||
                                  ' x_msg_data ' ||
                                  x_msg_data);
        END IF;  -- end of NVL(l_debug_enabled,'N')='Y'

        IF (l_return_status = okl_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        END IF;  --Copy value of OUT variable in the IN rvldrd type
       okl_api.end_activity(x_msg_count =>  x_msg_count
                            ,x_msg_data  => x_msg_data);

        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'end debug OKL_EC_UPTAKE_PVT.pls call populate_lease_rate_set');
        END IF;
       EXCEPTION

          WHEN okl_api.g_exception_error THEN

            x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                        ,p_pkg_name  =>                G_PKG_NAME
                                                        ,p_exc_name  =>                'OKL_API.G_RET_STS_ERROR'
                                                        ,x_msg_count =>                x_msg_count
                                                        ,x_msg_data  =>                x_msg_data
                                                        ,p_api_type  =>                G_API_TYPE);

          WHEN okl_api.g_exception_unexpected_error THEN

            x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                        ,p_pkg_name  =>                G_PKG_NAME
                                                        ,p_exc_name  =>                'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                        ,x_msg_count =>                x_msg_count
                                                        ,x_msg_data  =>                x_msg_data
                                                        ,p_api_type  =>                G_API_TYPE);

          WHEN OTHERS THEN

            x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                        ,p_pkg_name  =>                G_PKG_NAME
                                                        ,p_exc_name  =>                'OTHERS'
                                                        ,x_msg_count =>                x_msg_count
                                                        ,x_msg_data  =>                x_msg_data
                                                        ,p_api_type  =>                G_API_TYPE);
      END populate_lease_rate_set;


    -------------------------------------------------------------------------------
    --Populate Standard Rate Template For Quick Quote
    --------------------------------------------------------------------------------
      PROCEDURE populate_std_rate_tmpl(p_api_version             IN  NUMBER,
                                        p_init_msg_list          IN  VARCHAR2,
                                        p_target_id              IN  NUMBER,
                                        p_target_type                VARCHAR2,
                                        P_target_eff_from            DATE,
                                        p_term                       NUMBER,
                                        p_territory                  VARCHAR2,
                                        p_deal_size                  NUMBER,
                                        p_customer_credit_class      VARCHAR2,
                                        p_down_payment               NUMBER,
                                        p_advance_rent               NUMBER,
                                        p_trade_in_value             NUMBER,
                                        --Bug # 5045505 ssdeshpa start
                                        p_currency_code               VARCHAR2,
                                        --Bug # 5045505 ssdeshpa End
                                        p_item_table                 okl_number_table_type,
                                        p_item_categories_table      okl_number_table_type,
                                        x_okl_srt_table           OUT NOCOPY okl_std_rate_tmpl_tbl_type,
                                        x_return_status           OUT NOCOPY VARCHAR2,
                                        x_msg_count               OUT NOCOPY NUMBER,
                                        x_msg_data                OUT NOCOPY VARCHAR2) IS

        l_program_name      CONSTANT VARCHAR2(30) := 'p_srt';
        l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
        l_okl_srt_rec       okl_std_rate_tmpl_rec_type;
        l_okl_ec_rec_type   okl_ec_evaluate_pvt.okl_ec_rec_type;
        l_okl_srt_table     okl_std_rate_tmpl_tbl_type;
        l_api_version         CONSTANT number := 1.0;
        l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
        l_module              CONSTANT fnd_log_messages.module%TYPE := 'lrs';
        l_debug_enabled                varchar2(10);
        is_debug_procedure_on          boolean;
        is_debug_statement_on          boolean;
        i                     INTEGER;
        x_eligible            boolean;
        l_ac_rec_type     okl_ec_evaluate_pvt.okl_ac_rec_type;
        l_adj_factor           NUMBER;
        l_srt_effective_rate             NUMBER;

        -- SCHODAVA Bug #4747677
	-- Modified cursor to pick up SRTs which are created
	-- with Rate_Card_Yn flag as No.
	--Fixed # 5047718 ssdeshpa Start
	--Modified SRT selection To include Valid Index Rate Type SRT
	--Bug # 5045505 ssdeshpa start
    --Modified To inlude more Attribute Selection
    --Issue # 9 Modified to Filter SRT on the Basis of Currency Code Passed
        CURSOR c_srt_rec(effective_start_date DATE,
                         p_currency_code VARCHAR2) IS
	          select srt.std_rate_tmpl_id as id,
	                 srv.std_rate_tmpl_ver_id,
	                 srv.version_number,
	                 srt.template_name as name,
	                 srt.template_desc as description,
	                 srt.frequency_code as frq_code,
	                 srv.effective_from_date effective_from,
	                 srv.effective_to_date effective_to,
	                 srv.srt_rate,
	                 srv.sts_code,
	                 srv.day_convention_code,
	                 ----------
	                 srt.pricing_engine_code pricing_engine_code,
                     srt.rate_type_code rate_type_code,
                     srt.index_id index_id,
                     srv.spread spread,
                     srt.frequency_code frequency_code,
                     srv.adj_mat_version_id adj_mat_version_id,
                     srv.max_adj_rate,
                     srv.min_adj_rate
                     ---
	          from
	                   okl_fe_std_rt_tmp_v srt,
	                   okl_fe_std_rt_tmp_vers srv
	          where
	                   effective_start_date between srv.effective_from_date and NVL(srv.effective_to_date,effective_start_date+1)
	                   AND srt.std_rate_tmpl_id=srv.std_rate_tmpl_id
	                   AND srv.sts_code='ACTIVE'
		           AND srt.rate_card_yn = 'N'
		           AND srt.RATE_TYPE_CODE = 'BASE_RATE'
		           AND srt.currency_code = p_currency_code
		  UNION
		   select srt.std_rate_tmpl_id as id,
	                 srv.std_rate_tmpl_ver_id,
	                 srv.version_number,
	                 srt.template_name as name,
	                 srt.template_desc as description,
	                 srt.frequency_code as frq_code,
	                 srv.effective_from_date effective_from,
	                 srv.effective_to_date effective_to,
	                 srv.srt_rate,
	                 srv.sts_code,
	                 srv.day_convention_code,
	                 ----------
	                 srt.pricing_engine_code pricing_engine_code,
                     srt.rate_type_code rate_type_code,
                     srt.index_id index_id,
                     srv.spread spread,
                     srt.frequency_code frequency_code,
                     srv.adj_mat_version_id adj_mat_version_id,
                     srv.max_adj_rate,
                     srv.min_adj_rate
                     ---
		  from
		       okl_fe_std_rt_tmp_v srt,
			   okl_fe_std_rt_tmp_vers srv,
			   okl_index_values oiv
		  where
		           effective_start_date between srv.effective_from_date and NVL(srv.effective_to_date,effective_start_date+1)
		           and srt.std_rate_tmpl_id=srv.std_rate_tmpl_id
		           and srv.sts_code='ACTIVE'
		           AND srt.rate_card_yn = 'N'
		           AND srt.index_id = oiv.idx_id
	               AND effective_start_date BETWEEN oiv.datetime_valid AND nvl(oiv.datetime_invalid, effective_start_date + 1)
	               AND srt.RATE_TYPE_CODE = 'INDEX_RATE'
                   AND srt.currency_code = p_currency_code;

	                   --Fixed # 5047718 ssdeshpa End
	                   --Bug # 5045505 ssdeshpa End

      BEGIN

        l_debug_enabled := okl_debug_pub.check_log_enabled;
        is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                           ,fnd_log.level_procedure);

        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'begin debug OKLRECXB.pls call populate_srt');
        END IF;  -- check for logging on STATEMENT level
        is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                            ,fnd_log.level_statement);
        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list

        l_return_status := okl_api.start_activity(p_api_name       => l_api_name
                                                 ,p_pkg_name       => G_PKG_NAME
                                                 ,p_init_msg_list  => p_init_msg_list
                                                 ,l_api_version    => l_api_version
                                                 ,p_api_version    => p_api_version
                                                 ,p_api_type       => G_API_TYPE
                                                 ,x_return_status  => x_return_status);  -- check if activity started successfully

        IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        END IF;
      --Populate the Record Structure for the OKL_ECC_PUB.validate method
        --l_okl_ec_rec_type.target
        l_okl_ec_rec_type.src_type:='SRT';
        l_okl_ec_rec_type.target_id:= p_target_id;
        l_okl_ec_rec_type.target_type:= p_target_type;
        l_okl_ec_rec_type.target_eff_from:= P_target_eff_from;
        l_okl_ec_rec_type.term:= p_term;
        l_okl_ec_rec_type.territory:= p_territory;
        l_okl_ec_rec_type.deal_size:= p_deal_size;
        l_okl_ec_rec_type.customer_credit_class:= p_customer_credit_class;
        l_okl_ec_rec_type.down_payment:= p_down_payment;
        l_okl_ec_rec_type.advance_rent:= p_advance_rent;
        l_okl_ec_rec_type.trade_in_value:= p_trade_in_value;
        l_okl_ec_rec_type.validation_mode:='LOV';
        --Bug # 5045505 ssdeshpa start
        l_okl_ec_rec_type.currency_code := p_currency_code;
        --Bug # 5045505 ssdeshpa End
        --Bug # 5050143 ssdeshpa start
        FOR i IN p_item_categories_table.FIRST..p_item_categories_table.LAST LOOP
            IF p_item_categories_table.EXISTS(i) THEN
               l_okl_ec_rec_type.item_categories_table(i) := p_item_categories_table(i);
            END IF;
        END LOOP;
        --Bug # 5050143 ssdeshpa end
        i:=1;
        FOR l_okl_srt_rec IN c_srt_rec(p_target_eff_from,p_currency_code)
        LOOP
           l_okl_ec_rec_type.src_id:=l_okl_srt_rec.std_rate_tmpl_ver_id;
           l_okl_ec_rec_type.source_name:=l_okl_srt_rec.name;
           OKL_ECC_PUB.evaluate_eligibility_criteria(p_api_version
                                                    ,p_init_msg_list
                                                    ,x_return_status
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,l_okl_ec_rec_type
                                                    ,x_eligible);

            IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
               RAISE okl_api.g_exception_unexpected_error;
            ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
              RAISE okl_api.g_exception_error;
            END IF;
             IF(x_eligible) THEN
             ----------------------------------------------------------------
                --Bug # 5045505 ssdeshpa start
                -- Populate the Adjustment mat. rec.
                l_ac_rec_type.src_id := l_okl_srt_rec.adj_mat_version_id; -- Pricing adjustment matrix ID
                l_ac_rec_type.source_name := NULL; -- NOT Mandatory Pricing Adjustment Matrix Name !
                l_ac_rec_type.target_id := p_target_id ; -- Quote ID
                l_ac_rec_type.src_type := 'PAM'; -- Lookup Code
                l_ac_rec_type.target_type := 'QUOTE'; -- Same for both Quick Quote and Standard Quote
                l_ac_rec_type.target_eff_from  := P_target_eff_from; -- Quote effective From
                l_ac_rec_type.term  := p_term; -- Remaining four will be from teh business object like QQ / LQ
                l_ac_rec_type.territory := p_territory;
                l_ac_rec_type.deal_size := p_deal_size;
                l_ac_rec_type.customer_credit_class := p_customer_credit_class; -- Not sure how to pass this even ..
                -- Calling the API to get the adjustment factor ..
                okl_ec_evaluate_pvt.get_adjustment_factor(
                      p_api_version       => p_api_version,
                      p_init_msg_list     => p_init_msg_list,
                      x_return_status     => x_return_status,
                      x_msg_count         => x_msg_count,
                      x_msg_data          => x_msg_data,
                      p_okl_ac_rec        => l_ac_rec_type,
                      x_adjustment_factor => l_adj_factor );
                IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                         RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
             --Calculate Effective Rate
             l_srt_effective_rate := l_okl_srt_rec.srt_rate + nvl(l_okl_srt_rec.spread,0) + nvl(l_adj_factor,0); -- Rate is being stored as Percentage
             --Bug # 5045505
             /*If the calculated Rate is below the Minimum Rate, the Minimum Rate becomes
               the Effective Rate that must be displayed in QQ and Sales Quote and be used
               for pricing.  Conversely, if the calculated rate is above the Maximum Rate,
               the Maximum Rate becomes the Effective Rate.
             */
              IF(l_okl_srt_rec.max_adj_rate IS NOT NULL AND l_okl_srt_rec.max_adj_rate < l_srt_effective_rate) THEN
                 l_okl_srt_table(i).srt_rate := l_okl_srt_rec.max_adj_rate;
              ELSIF(l_okl_srt_rec.min_adj_rate IS NOT NULL AND l_okl_srt_rec.min_adj_rate > l_srt_effective_rate) THEN
                 l_okl_srt_table(i).srt_rate := l_okl_srt_rec.min_adj_rate;
              ELSE
                 l_okl_srt_table(i).srt_rate := l_srt_effective_rate;
              END IF;
             l_okl_srt_table(i).id:=l_okl_srt_rec.id;
             l_okl_srt_table(i).name:=l_okl_srt_rec.name;
             l_okl_srt_table(i).description:=l_okl_srt_rec.description;
             l_okl_srt_table(i).frq_code:=l_okl_srt_rec.frq_code;
             l_okl_srt_table(i).frq_meaning:= OKL_ACCOUNTING_UTIL.get_lookup_meaning('OKL_FREQUENCY',l_okl_srt_rec.frq_code);
             l_okl_srt_table(i).std_rate_tmpl_ver_id:=l_okl_srt_rec.std_rate_tmpl_ver_id;
             l_okl_srt_table(i).version_number:=l_okl_srt_rec.version_number;
             l_okl_srt_table(i).effective_from:=l_okl_srt_rec.effective_from;
             l_okl_srt_table(i).effective_to:=l_okl_srt_rec.effective_to;
             l_okl_srt_table(i).sts_code:=l_okl_srt_rec.sts_code;
             l_okl_srt_table(i).day_convention_code:=l_okl_srt_rec.day_convention_code;
             i:=i+1;
           END IF;
        END LOOP;
        --Bug # 5045505 ssdeshpa end
        x_okl_srt_table:=l_okl_srt_table;
        IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_statement
                                 ,l_module
                                 ,'okl_ec_uptake_pvt.populate_standard_rate_template returned with status ' ||
                                  l_return_status ||
                                  ' x_msg_data ' ||
                                  x_msg_data);
        END IF;  -- end of NVL(l_debug_enabled,'N')='Y'

        IF (l_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
        END IF;  --Copy value of OUT variable in the IN rvldrd type
       okl_api.end_activity(x_msg_count => x_msg_count
                            ,x_msg_data => x_msg_data);

        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'end debug OKL_EC_UPTAKE_PVT.pls call populate_standard_rate_template');
        END IF;
       EXCEPTION
          WHEN okl_api.g_exception_error THEN

            x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                        ,p_pkg_name  =>                G_PKG_NAME
                                                        ,p_exc_name  =>                'OKL_API.G_RET_STS_ERROR'
                                                        ,x_msg_count =>                x_msg_count
                                                        ,x_msg_data  =>                x_msg_data
                                                        ,p_api_type  =>                G_API_TYPE);

          WHEN okl_api.g_exception_unexpected_error THEN

            x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                        ,p_pkg_name  =>                G_PKG_NAME
                                                        ,p_exc_name  =>                'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                        ,x_msg_count =>                x_msg_count
                                                        ,x_msg_data  =>                x_msg_data
                                                        ,p_api_type  =>                G_API_TYPE);

          WHEN OTHERS THEN

            x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                        ,p_pkg_name  =>                G_PKG_NAME
                                                        ,p_exc_name  =>                'OTHERS'
                                                        ,x_msg_count =>                x_msg_count
                                                        ,x_msg_data  =>                x_msg_data
                                                        ,p_api_type  =>                G_API_TYPE);
      END populate_std_rate_tmpl;
    -----------------------------------------------------------------------------------------------------
    -----------------------------------------------------------------------------------------------------
    --Populate Lease Rate Set For Lease Quote

      PROCEDURE populate_lease_rate_set(p_api_version             IN  NUMBER,
                                        p_init_msg_list           IN  VARCHAR2,
                                        p_target_id                     number,
                                        p_target_type             IN  varchar2,
                                        x_okl_lrs_table           OUT NOCOPY okl_lease_rate_set_tbl_type,
                                        x_return_status           OUT NOCOPY VARCHAR2,
                                        x_msg_count               OUT NOCOPY NUMBER,
                                        x_msg_data                OUT NOCOPY VARCHAR2)IS

        l_return_status    VARCHAR2(1);
        l_program_name     CONSTANT VARCHAR2(30) := 'p_lrslq';
        l_api_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
        l_okl_lrs_rec       okl_lease_rate_set_rec_type;
        l_okl_ec_rec_type   okl_ec_evaluate_pvt.okl_ec_rec_type;
        l_okl_lrs_table     okl_lease_rate_set_tbl_type;
        i                   INTEGER;
        x_eligible          boolean;
        l_validation_mode   VARCHAR2(30);
        l_module            CONSTANT fnd_log_messages.module%TYPE := 'lrs';
        l_debug_enabled                varchar2(10);
        is_debug_procedure_on          boolean;
        is_debug_statement_on          boolean;
        l_api_version        CONSTANT number := 1.0;
         -- Bug # 5045505 ssdeshpa start
         --Filtering the LRS on the Basis of Currency_code
         CURSOR c_lrs_rec(effective_start_date DATE,
                          p_currency_code VARCHAR2) IS
          select lrs.id,
                 lrv.rate_set_version_id,
                 lrv.version_number,
                 lrs.name,
                 lrs.description,
                 lrv.effective_from_date effective_from,
                 lrv.effective_to_date effective_to,
                 --Bug # 5050143 start
                 nvl(lrv.lrs_rate,lrv.standard_rate) lrs_rate,
                 --Bug # 5050143 start
                 lrv.sts_code,
                 lrs.frq_code
          from okl_ls_rt_fctr_sets_v lrs,okl_fe_rate_set_versions_v lrv
          where
          effective_start_date between lrv.effective_from_date and NVL(lrv.effective_to_date,effective_start_date+1)
          AND lrs.id=lrv.rate_set_id
          and lrv.sts_code='ACTIVE'
          AND lrs.currency_code = p_currency_code;

      BEGIN
        l_debug_enabled := okl_debug_pub.check_log_enabled;
        is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                           ,fnd_log.level_procedure);


        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'begin debug OKLRECXB.pls.pls call populate_lease_rate_set2');
        END IF;  -- check for logging on STATEMENT level
        is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                           ,fnd_log.level_statement);

        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list

        l_return_status := okl_api.start_activity(p_api_name      => l_api_name
                                                 ,p_pkg_name      => G_PKG_NAME
                                                 ,p_init_msg_list => p_init_msg_list
                                                 ,l_api_version   => l_api_version
                                                 ,p_api_version   => p_api_version
                                                 ,p_api_type      => G_API_TYPE
                                                 ,x_return_status => l_return_status);  -- check if activity started successfully

        IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        END IF;
      --Populate the Record Structure for the OKL_ECC_PUB.validate method
        --l_okl_ec_rec_type.target
          l_okl_ec_rec_type.src_type := 'LRS';
          l_okl_ec_rec_type.target_id := p_target_id;
          l_okl_ec_rec_type.target_type := p_target_type;
          l_okl_ec_rec_type.validation_mode := 'LOV';

     -------------------------------------------------------------------------------------
          populate_lq_attributes(l_okl_ec_rec_type
                                 ,p_target_id
                                 ,x_return_status);
           IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
               RAISE okl_api.g_exception_unexpected_error;
           ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
               RAISE okl_api.g_exception_error;
           END IF;
    --------------------------------------------------------------------------------------
        i := 1;
        FOR l_okl_lrs_rec IN c_lrs_rec(l_okl_ec_rec_type.target_eff_from,l_okl_ec_rec_type.currency_code)LOOP
           l_okl_ec_rec_type.src_id := l_okl_lrs_rec.rate_set_version_id;
           l_okl_ec_rec_type.source_name := l_okl_lrs_rec.name;
           OKL_ECC_PUB.evaluate_eligibility_criteria(p_api_version
                                                    ,p_init_msg_list
                                                    ,x_return_status
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,l_okl_ec_rec_type
                                                    ,x_eligible);
           IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
             RAISE okl_api.g_exception_unexpected_error;
           ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
              RAISE okl_api.g_exception_error;
           END IF;

           IF(x_eligible) THEN
              l_okl_lrs_table(i).id:=l_okl_lrs_rec.id;
              l_okl_lrs_table(i).name:=l_okl_lrs_rec.name;
              l_okl_lrs_table(i).rate_set_version_id:=l_okl_lrs_rec.rate_set_version_id;
              l_okl_lrs_table(i).version_number:=l_okl_lrs_rec.version_number;
              l_okl_lrs_table(i).description:=l_okl_lrs_rec.description;
              l_okl_lrs_table(i).effective_from:=l_okl_lrs_rec.effective_from;
              l_okl_lrs_table(i).effective_to:=l_okl_lrs_rec.effective_to;
              l_okl_lrs_table(i).lrs_rate:=l_okl_lrs_rec.lrs_rate;
              l_okl_lrs_table(i).sts_code:=l_okl_lrs_rec.sts_code;
              l_okl_lrs_table(i).frq_code:= l_okl_lrs_rec.frq_code;
              l_okl_lrs_table(i).frq_meaning:= OKL_ACCOUNTING_UTIL.get_lookup_meaning('OKL_FREQUENCY',l_okl_lrs_rec.frq_code);
              i:=i+1;
           END IF;
        END LOOP;
        x_okl_lrs_table:=l_okl_lrs_table;
        IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_statement
                                 ,l_module
                                 ,'OKLRECXB.pls.pls call populate_lease_rate_set2 returned with status ' ||
                                 l_return_status ||
                                 ' x_msg_data ' ||
                                 x_msg_data);
        END IF;  -- end of NVL(l_debug_enabled,'N')='Y'

        IF (l_return_status = okl_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        END IF;  --Copy value of OUT variable in the IN rvldrd type
       okl_api.end_activity(x_msg_count => x_msg_count
                            ,x_msg_data => x_msg_data);

        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'end debug OKLRECXB.pls call populate_lease_rate_set2');
        END IF;
      EXCEPTION
          WHEN okl_api.g_exception_error THEN

            x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                        ,p_pkg_name  =>                G_PKG_NAME
                                                        ,p_exc_name  =>                'OKL_API.G_RET_STS_ERROR'
                                                        ,x_msg_count =>                x_msg_count
                                                        ,x_msg_data  =>                x_msg_data
                                                        ,p_api_type  =>                G_API_TYPE);

          WHEN okl_api.g_exception_unexpected_error THEN

            x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                        ,p_pkg_name  =>                G_PKG_NAME
                                                        ,p_exc_name  =>                'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                        ,x_msg_count =>                x_msg_count
                                                        ,x_msg_data  =>                x_msg_data
                                                        ,p_api_type  =>                G_API_TYPE);

          WHEN OTHERS THEN

            x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                        ,p_pkg_name  =>                G_PKG_NAME
                                                        ,p_exc_name  =>                'OTHERS'
                                                        ,x_msg_count =>                x_msg_count
                                                        ,x_msg_data  =>                x_msg_data
                                                        ,p_api_type  =>                G_API_TYPE);
      END populate_lease_rate_set;
    --------------------------------------------------------------------------------------------------------

    -------------------------------------------------------------------------------------------------

    --To Populate the SRT for Lease Quote
      PROCEDURE populate_std_rate_tmpl(p_api_version             IN  NUMBER,
                                       p_init_msg_list           IN  VARCHAR2,
                                       p_target_id               IN  NUMBER,
                                       p_target_type                 VARCHAR2,
                                       x_okl_srt_table           OUT NOCOPY okl_std_rate_tmpl_tbl_type,
                                       x_return_status           OUT NOCOPY VARCHAR2,
                                       x_msg_count               OUT NOCOPY NUMBER,
                                       x_msg_data                OUT NOCOPY VARCHAR2) IS

        l_return_status     VARCHAR2(1);
        l_program_name      CONSTANT VARCHAR2(30) := 'p_srtlq';
        l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
        l_okl_srt_rec       okl_std_rate_tmpl_rec_type;
        l_okl_ec_rec_type   okl_ec_evaluate_pvt.okl_ec_rec_type;
        l_okl_srt_table     okl_std_rate_tmpl_tbl_type;
        l_validation_mode   VARCHAR2(30);
        l_module            CONSTANT fnd_log_messages.module%TYPE := 'srt';
        l_debug_enabled                varchar2(10);
        is_debug_procedure_on          boolean;
        is_debug_statement_on          boolean;
        l_api_version         CONSTANT number := 1.0;
        i                   INTEGER;
        x_eligible          boolean;
        l_ac_rec_type     okl_ec_evaluate_pvt.okl_ac_rec_type;
        l_adj_factor           NUMBER;
        l_srt_effective_rate   NUMBER;
        -- SCHODAVA Bug #4747677
	    -- Modified cursor to pick up SRTs which are created
	    -- with Rate_Card_Yn flag as No.
	    --Fixed # 5047718 ssdeshpa Start
	    --Modified SRT selection To include Valid Index Rate Type SRT
    	--Bug # 5045505 ssdeshpa start
        --Modified To inlude more Attribute Selection
        CURSOR c_srt_rec(effective_start_date DATE,
                         p_currency_code VARCHAR2) IS
	           select srt.std_rate_tmpl_id as id,
	                 srv.std_rate_tmpl_ver_id,
	                 srv.version_number,
	                 srt.template_name as name,
	                 srt.template_desc as description,
	                 srt.frequency_code as frq_code,
	                 srv.effective_from_date effective_from,
	                 srv.effective_to_date effective_to,
	                 srv.srt_rate,
	                 srv.sts_code,
	                 srv.day_convention_code,
	                 ----------
	                 srt.pricing_engine_code pricing_engine_code,
                     srt.rate_type_code rate_type_code,
                     srt.index_id index_id,
                     srv.spread spread,
                     srt.frequency_code frequency_code,
                     srv.adj_mat_version_id adj_mat_version_id,
                     srv.max_adj_rate,
                     srv.min_adj_rate
                     ---
	          from
	                   okl_fe_std_rt_tmp_v srt,
	                   okl_fe_std_rt_tmp_vers srv
	          where
	                   effective_start_date between srv.effective_from_date and NVL(srv.effective_to_date,effective_start_date+1)
	                   AND srt.std_rate_tmpl_id=srv.std_rate_tmpl_id
	                   AND srv.sts_code='ACTIVE'
		           AND srt.rate_card_yn = 'N'
		           AND srt.RATE_TYPE_CODE = 'BASE_RATE'
		           AND srt.currency_code = p_currency_code
		  UNION
		   select srt.std_rate_tmpl_id as id,
	                 srv.std_rate_tmpl_ver_id,
	                 srv.version_number,
	                 srt.template_name as name,
	                 srt.template_desc as description,
	                 srt.frequency_code as frq_code,
	                 srv.effective_from_date effective_from,
	                 srv.effective_to_date effective_to,
	                 srv.srt_rate,
	                 srv.sts_code,
	                 srv.day_convention_code,
	                 ----------
	                 srt.pricing_engine_code pricing_engine_code,
                     srt.rate_type_code rate_type_code,
                     srt.index_id index_id,
                     srv.spread spread,
                     srt.frequency_code frequency_code,
                     srv.adj_mat_version_id adj_mat_version_id,
                     srv.max_adj_rate,
                     srv.min_adj_rate
                     ---
		  from
		       okl_fe_std_rt_tmp_v srt,
			   okl_fe_std_rt_tmp_vers srv,
			   okl_index_values oiv
		  where
		           effective_start_date between srv.effective_from_date and NVL(srv.effective_to_date,effective_start_date+1)
		           and srt.std_rate_tmpl_id=srv.std_rate_tmpl_id
		           and srv.sts_code='ACTIVE'
		           AND srt.rate_card_yn = 'N'
		           AND srt.index_id = oiv.idx_id
	               AND effective_start_date BETWEEN oiv.datetime_valid AND nvl(oiv.datetime_invalid, effective_start_date + 1)
	               AND srt.RATE_TYPE_CODE = 'INDEX_RATE'
                   AND srt.currency_code = p_currency_code;

	                   --Fixed # 5047718 ssdeshpa End
	                   --Bug # 5045505 ssdeshpa End


      BEGIN
        l_debug_enabled := okl_debug_pub.check_log_enabled;
        is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                            ,fnd_log.level_procedure);


        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'begin debug OKLRECXB.pls call populate_standard_rate_template2');
        END IF;  -- check for logging on STATEMENT level
        is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                           ,fnd_log.level_statement);

        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list

        l_return_status := okl_api.start_activity(p_api_name      => l_api_name
                                                 ,p_pkg_name      => G_PKG_NAME
                                                 ,p_init_msg_list => p_init_msg_list
                                                 ,l_api_version   => l_api_version
                                                 ,p_api_version   => p_api_version
                                                 ,p_api_type      => G_API_TYPE
                                                 ,x_return_status => x_return_status);  -- check if activity started successfully

        IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        END IF;
        --Populate the Record Structure for the OKL_ECC_PUB.validate method
        --l_okl_ec_rec_type.target
        l_okl_ec_rec_type.src_type:='SRT';
        l_okl_ec_rec_type.target_id:= p_target_id;
        l_okl_ec_rec_type.target_type:= p_target_type;
        l_okl_ec_rec_type.validation_mode:='LOV';

     -------------------------------------------------------------------------------------
        populate_lq_attributes(l_okl_ec_rec_type
                                 ,p_target_id
                                 ,x_return_status);
        IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
        ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
        END IF;
    --------------------------------------------------------------------------------------

        i := 1;
        FOR l_okl_srt_rec IN c_srt_rec(l_okl_ec_rec_type.target_eff_from,l_okl_ec_rec_type.currency_code)
        LOOP
           l_okl_ec_rec_type.src_id:=l_okl_srt_rec.std_rate_tmpl_ver_id;
           l_okl_ec_rec_type.source_name:=l_okl_srt_rec.name;
           OKL_ECC_PUB.evaluate_eligibility_criteria(p_api_version
                                                    ,p_init_msg_list
                                                    ,x_return_status
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,l_okl_ec_rec_type
                                                    ,x_eligible);
           IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
             RAISE okl_api.g_exception_unexpected_error;
           ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
              RAISE okl_api.g_exception_error;
           END IF;

           IF(x_eligible) THEN
             ----------------------------------------------------------------
                 --Bug # 5045505 ssdeshpa start
                -- Populate the Adjustment mat. rec.
                l_ac_rec_type.src_id := l_okl_srt_rec.adj_mat_version_id; -- Pricing adjustment matrix ID
                l_ac_rec_type.source_name := NULL; -- NOT Mandatory Pricing Adjustment Matrix Name !
                l_ac_rec_type.target_id := p_target_id ; -- Quote ID
                l_ac_rec_type.src_type := 'PAM'; -- Lookup Code
                l_ac_rec_type.target_type := 'QUOTE'; -- Same for both Quick Quote and Standard Quote
                l_ac_rec_type.target_eff_from  := l_okl_ec_rec_type.target_eff_from; -- Quote effective From
                l_ac_rec_type.term  := l_okl_ec_rec_type.term; -- Remaining four will be from teh business object like QQ / LQ
                l_ac_rec_type.territory :=  l_okl_ec_rec_type.territory;
                l_ac_rec_type.deal_size := l_okl_ec_rec_type.deal_size;
                l_ac_rec_type.customer_credit_class := l_okl_ec_rec_type.customer_credit_class; -- Not sure how to pass this even ..
                -- Calling the API to get the adjustment factor ..
                okl_ec_evaluate_pvt.get_adjustment_factor(
                      p_api_version       => p_api_version,
                      p_init_msg_list     => p_init_msg_list,
                      x_return_status     => x_return_status,
                      x_msg_count         => x_msg_count,
                      x_msg_data          => x_msg_data,
                      p_okl_ac_rec        => l_ac_rec_type,
                      x_adjustment_factor => l_adj_factor );
                IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                         RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
              --Calculate Effective Rate

             l_srt_effective_rate := l_okl_srt_rec.srt_rate + nvl(l_okl_srt_rec.spread,0) + nvl(l_adj_factor,0); -- Rate is being stored as Percentage
             --Bug # 5045505
             /*If the calculated Rate is below the Minimum Rate, the Minimum Rate becomes
               the Effective Rate that must be displayed in QQ and Sales Quote and be used
               for pricing.  Conversely, if the calculated rate is above the Maximum Rate,
               the Maximum Rate becomes the Effective Rate.
             */
              IF(l_okl_srt_rec.max_adj_rate IS NOT NULL AND l_okl_srt_rec.max_adj_rate < l_srt_effective_rate) THEN
                 l_okl_srt_table(i).srt_rate := l_okl_srt_rec.max_adj_rate;
              ELSIF(l_okl_srt_rec.min_adj_rate IS NOT NULL AND l_okl_srt_rec.min_adj_rate > l_srt_effective_rate) THEN
                 l_okl_srt_table(i).srt_rate := l_okl_srt_rec.min_adj_rate;
              ELSE
                 l_okl_srt_table(i).srt_rate := l_srt_effective_rate;
              END IF;

             l_okl_srt_table(i).id:=l_okl_srt_rec.id;
             l_okl_srt_table(i).name:=l_okl_srt_rec.name;
             l_okl_srt_table(i).description:=l_okl_srt_rec.description;
             l_okl_srt_table(i).frq_code:= l_okl_srt_rec.frq_code;
             l_okl_srt_table(i).frq_meaning:= OKL_ACCOUNTING_UTIL.get_lookup_meaning('OKL_FREQUENCY',l_okl_srt_rec.frq_code);
             l_okl_srt_table(i).std_rate_tmpl_ver_id:=l_okl_srt_rec.std_rate_tmpl_ver_id;
             l_okl_srt_table(i).version_number:=l_okl_srt_rec.version_number;
             l_okl_srt_table(i).effective_from:=l_okl_srt_rec.effective_from;
             l_okl_srt_table(i).effective_to:=l_okl_srt_rec.effective_to;
             l_okl_srt_table(i).sts_code:=l_okl_srt_rec.sts_code;
             l_okl_srt_table(i).day_convention_code:=l_okl_srt_rec.day_convention_code;
             i := i+1;
           END IF;
           --Bug # 5045505 ssdeshpa End;
        END LOOP;
        x_okl_srt_table:=l_okl_srt_table;
        IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_statement
                                 ,l_module
                                 ,'OKL_EC_UPTAKE_PVT.populate_standard_rate_template2 returned with status ' ||
                                  l_return_status ||
                                  ' x_msg_data ' ||
                                  x_msg_data);
        END IF;  -- end of NVL(l_debug_enabled,'N')='Y'

        IF (l_return_status = okl_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        END IF;  --Copy value of OUT variable in the IN rvldrd type
       okl_api.end_activity(x_msg_count =>                x_msg_count
                            ,x_msg_data  =>                x_msg_data);

        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'end debug OKL_EC_UPTAKE_PVT.populate_standard_rate_template2 call create_vls');
        END IF;
      EXCEPTION

          WHEN okl_api.g_exception_error THEN

            x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                        ,p_pkg_name  =>                G_PKG_NAME
                                                        ,p_exc_name  =>                'OKL_API.G_RET_STS_ERROR'
                                                        ,x_msg_count =>                x_msg_count
                                                        ,x_msg_data  =>                x_msg_data
                                                        ,p_api_type  =>                G_API_TYPE);

          WHEN okl_api.g_exception_unexpected_error THEN

            x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                        ,p_pkg_name  =>                G_PKG_NAME
                                                        ,p_exc_name  =>                'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                        ,x_msg_count =>                x_msg_count
                                                        ,x_msg_data  =>                x_msg_data
                                                        ,p_api_type  =>                G_API_TYPE);

          WHEN OTHERS THEN

            x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                        ,p_pkg_name  =>                G_PKG_NAME
                                                        ,p_exc_name  =>                'OTHERS'
                                                        ,x_msg_count =>                x_msg_count
                                                        ,x_msg_data  =>                x_msg_data
                                                        ,p_api_type  =>                G_API_TYPE);
      END populate_std_rate_tmpl;
      -------------------------------------------------------------------------------------

     PROCEDURE populate_product(p_api_version             IN  NUMBER,
                                p_init_msg_list           IN  VARCHAR2,
                                p_target_id                   NUMBER,
                                p_target_type             IN  VARCHAR2,
                                x_okl_prod_table          OUT NOCOPY okl_prod_tbl_type,
                                x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2) IS
        l_vendor_prog_id    NUMBER;
        l_return_status     VARCHAR2(1);
        l_program_name      CONSTANT VARCHAR2(30) := 'p_pdt';
        l_module            CONSTANT fnd_log_messages.module%TYPE := 'lrs';
        l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
        l_okl_prod_rec      okl_prod_rec_type;
        l_okl_ec_rec_type   okl_ec_evaluate_pvt.okl_ec_rec_type;
        l_okl_prod_table    okl_prod_tbl_type;
        i                   INTEGER;
        x_eligible          boolean;
        l_debug_enabled     varchar2(10);
        is_debug_procedure_on          boolean;
        is_debug_statement_on          boolean;
        l_api_version         CONSTANT number := 1.0;

        CURSOR c_product_rec1(effective_start_date DATE) IS
        -- Updated the sql for performance issue bug#5484903
        -- varangan - 26-9-06
	 SELECT pdt.id ID,
	pdt.name NAME,
	pqy.name PRODUCT_SUBCLASS,
	pdt.version VERSION,
	pdt.description DESCRIPTION,
	pdt.PRODUCT_STATUS_CODE PRODUCT_STATUS_CODE,
	qve.VALUE Deal_Type,
	Okl_Accounting_Util.Get_Lookup_Meaning('OKL_SECURITIZATION_TYPE',      		 qve.VALUE) Deal_Type_meaning
	FROM OKL_PRODUCTS PDT,
	OKL_PQY_VALUES qve,
	OKL_PDT_QUALITYS PQY,
	OKL_PDT_PQY_VALS PQV
	where
	pdt.id = pqv.pdt_id
	and qve.pqy_id = pqy.id
	AND pqv.qve_id = qve.id
	AND pqy.name In ('INVESTOR','LEASE')
	and effective_start_date BETWEEN pdt.from_date
	and NVL(pdt.to_date,SYSDATE)
	and pdt.product_status_code='APPROVED';

         CURSOR c_product_rec2(l_vendor_prog_id number) IS
            select prod.id,
            prod.name,
            prod.product_subclass,
            prod.version,
            prod.description,
            prod.product_status_code,
            prod.deal_type,
            prod.deal_type_meaning
         from okl_product_parameters_v prod,OKL_VP_ASSOCIATIONS vp
         where
          --effective_start_date BETWEEN prod.from_date and NVL(prod.to_date,SYSDATE)
          --and
          vp.ASSOC_OBJECT_TYPE_CODE='LA_FINANCIAL_PRODUCT'
          and prod.id =vp.ASSOC_OBJECT_ID
          and vp.chr_id=l_vendor_prog_id
          AND prod.product_status_code='APPROVED';



      BEGIN
        l_debug_enabled := okl_debug_pub.check_log_enabled;
        is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                            ,fnd_log.level_procedure);


        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'begin debug OKLRECXB.pls call populate_product');
        END IF;  -- check for logging on STATEMENT level
        is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                           ,fnd_log.level_statement);

        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list

        l_return_status := okl_api.start_activity(p_api_name      => l_api_name
                                                 ,p_pkg_name      => G_PKG_NAME
                                                 ,p_init_msg_list => p_init_msg_list
                                                 ,l_api_version   => l_api_version
                                                 ,p_api_version   => p_api_version
                                                 ,p_api_type      => G_API_TYPE
                                                 ,x_return_status => x_return_status);  -- check if activity started successfully

        IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        END IF;
        --Populate the Record Structure for the OKL_ECC_PUB.validate method
        --l_okl_ec_rec_type.target
        l_okl_ec_rec_type.src_type:='PRODUCT';
        l_okl_ec_rec_type.target_id:= p_target_id;
        l_okl_ec_rec_type.target_type:= p_target_type;
        l_okl_ec_rec_type.validation_mode:='LOV';

        populate_lq_attributes(l_okl_ec_rec_type
                               ,p_target_id
                               ,x_return_status);
           IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
               RAISE okl_api.g_exception_unexpected_error;
           ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
               RAISE okl_api.g_exception_error;
           END IF;
        ------------------------------------------------------------------------
        l_vendor_prog_id:=get_vp_id(p_target_id);
        ------------------------------------------------------------------------
        i:=1;
        if(l_vendor_prog_id IS NULL) THEN
          FOR l_okl_prod_rec IN c_product_rec1(l_okl_ec_rec_type.target_eff_from)
            LOOP
               l_okl_ec_rec_type.src_id:=l_okl_prod_rec.id;
               l_okl_ec_rec_type.source_name:=l_okl_prod_rec.name;
               OKL_ECC_PUB.evaluate_eligibility_criteria(p_api_version
                                                    ,p_init_msg_list
                                                    ,x_return_status
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,l_okl_ec_rec_type
                                                    ,x_eligible);

              IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
                 RAISE okl_api.g_exception_unexpected_error;
              ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
                RAISE okl_api.g_exception_error;
              END IF;
               IF(x_eligible) THEN
                   l_okl_prod_table(i).id:=l_okl_prod_rec.id;
                   l_okl_prod_table(i).name:=l_okl_prod_rec.name;
                   i:=i+1;
               END IF;
           END LOOP;

        else
          FOR l_okl_prod_rec IN c_product_rec2(l_vendor_prog_id)
            LOOP
               l_okl_ec_rec_type.src_id:=l_okl_prod_rec.id;
               l_okl_ec_rec_type.source_name:=l_okl_prod_rec.name;
               OKL_ECC_PUB.evaluate_eligibility_criteria(p_api_version
                                                    ,p_init_msg_list
                                                    ,x_return_status
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,l_okl_ec_rec_type
                                                    ,x_eligible);
               IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
                    RAISE okl_api.g_exception_unexpected_error;
               ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
                RAISE okl_api.g_exception_error;
               END IF;
               IF(x_eligible) THEN
                   l_okl_prod_table(i).id:=l_okl_prod_rec.id;
                   l_okl_prod_table(i).name:=l_okl_prod_rec.name;
                   i:=i+1;
              END IF;
          END LOOP;

        end if;
        x_okl_prod_table:=l_okl_prod_table;

        IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_statement
                                 ,l_module
                                 ,'OKL_EC_UPTAKE_PVT.populate_product returned with status ' ||
                                  l_return_status ||
                                  ' x_msg_data ' ||
                                  x_msg_data);
        END IF;  -- end of NVL(l_debug_enabled,'N')='Y'

        IF (l_return_status = okl_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        END IF;
       okl_api.end_activity(x_msg_count =>                x_msg_count
                            ,x_msg_data  =>                x_msg_data);

        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'end debug OKL_EC_UPTAKE_PVT.populate_product ');
        END IF;
      EXCEPTION
          WHEN okl_api.g_exception_error THEN

            x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                        ,p_pkg_name  =>                G_PKG_NAME
                                                        ,p_exc_name  =>                'OKL_API.G_RET_STS_ERROR'
                                                        ,x_msg_count =>                x_msg_count
                                                        ,x_msg_data  =>                x_msg_data
                                                        ,p_api_type  =>                G_API_TYPE);

          WHEN okl_api.g_exception_unexpected_error THEN

            x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                        ,p_pkg_name  =>                G_PKG_NAME
                                                        ,p_exc_name  =>                'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                        ,x_msg_count =>                x_msg_count
                                                        ,x_msg_data  =>                x_msg_data
                                                        ,p_api_type  =>                G_API_TYPE);

          WHEN OTHERS THEN

            x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                        ,p_pkg_name  =>                G_PKG_NAME
                                                        ,p_exc_name  =>                'OTHERS'
                                                        ,x_msg_count =>                x_msg_count
                                                        ,x_msg_data  =>                x_msg_data
                                                        ,p_api_type  =>                G_API_TYPE);      END populate_product;

    ----------------------------------------------------------------------------------------
      PROCEDURE populate_vendor_program(p_api_version             IN  NUMBER,
                                        p_init_msg_list           IN  VARCHAR2,
                                        p_target_id                   number,
                                        p_target_type             IN  varchar2,
                                        p_target_eff_from             date,
                                        p_term                        NUMBER,
                                        p_territory                   VARCHAR2,
                                        p_deal_size                   number,
                                        p_customer_credit_class       VARCHAR2,
                                        p_down_payment                number,
                                        p_advance_rent                number,
                                        p_trade_in_value              number,
                                        p_item_table                  okl_number_table_type,
                                        p_item_categories_table       okl_number_table_type,
                                        x_okl_vp_table            OUT NOCOPY okl_vp_tbl_type,
                                        x_return_status           OUT NOCOPY VARCHAR2,
                                        x_msg_count               OUT NOCOPY NUMBER,
                                        x_msg_data                OUT NOCOPY VARCHAR2) IS


        l_program_name      CONSTANT VARCHAR2(30) := 'vp_p';
        l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
        l_okl_vp_rec        okl_vp_rec_type;
        l_okl_ec_rec_type   okl_ec_evaluate_pvt.okl_ec_rec_type;
        l_okl_vp_table      okl_vp_tbl_type;
        i                   INTEGER;
        l_api_version         CONSTANT number := 1.0;
        l_return_status                varchar2(1) := okl_api.g_ret_sts_success;
        x_eligible            boolean;
        l_debug_enabled     varchar2(10);
        is_debug_procedure_on          boolean;
        is_debug_statement_on          boolean;

        l_module            CONSTANT fnd_log_messages.module%TYPE := 'VPA';



        CURSOR c_vp_rec(effective_start_date DATE) IS
          select tbl.id,
           tbl.contract_number,
           tbl.start_date,
           tbl.end_date
          from okc_k_headers_v  tbl
          where effective_start_date between tbl.start_date and NVL(tbl.end_date,effective_start_date+1)
          AND tbl.SCS_CODE='PROGRAM'
          AND tbl.STS_CODE='ACTIVE'
          AND tbl.template_yn='N';

      BEGIN
        l_debug_enabled := okl_debug_pub.check_log_enabled;
        is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                            ,fnd_log.level_procedure);


        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'begin debug OKLRECXB.pls call populate_vendor_program');
        END IF;  -- check for logging on STATEMENT level
        is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                           ,fnd_log.level_statement);

        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list

        l_return_status := okl_api.start_activity(p_api_name      => l_api_name
                                                 ,p_pkg_name      => G_PKG_NAME
                                                 ,p_init_msg_list => p_init_msg_list
                                                 ,l_api_version   => l_api_version
                                                 ,p_api_version   => p_api_version
                                                 ,p_api_type      => G_API_TYPE
                                                 ,x_return_status => x_return_status);  -- check if activity started successfully

        IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        END IF;
       --Populate the Record Structure for the OKL_ECC_PUB.validate method
        --l_okl_ec_rec_type.target
        l_okl_ec_rec_type.src_type:='VENDOR_PROGRAM';
        l_okl_ec_rec_type.target_id:= p_target_id;
        l_okl_ec_rec_type.target_type:= p_target_type;
        l_okl_ec_rec_type.target_eff_from:= P_target_eff_from;
        l_okl_ec_rec_type.term:= p_term;
        l_okl_ec_rec_type.territory:= p_territory;
        l_okl_ec_rec_type.deal_size:= p_deal_size;
        l_okl_ec_rec_type.customer_credit_class:= p_customer_credit_class;
        l_okl_ec_rec_type.down_payment:= p_down_payment;
        l_okl_ec_rec_type.advance_rent:= p_advance_rent;
        l_okl_ec_rec_type.trade_in_value:= p_trade_in_value;
        l_okl_ec_rec_type.validation_mode:='LOV';

        i := 1;
        FOR l_okl_vp_rec IN c_vp_rec(p_target_eff_from)LOOP
           l_okl_ec_rec_type.src_id:=l_okl_vp_rec.id;
           l_okl_ec_rec_type.source_name:=l_okl_vp_rec.contract_number;

           OKL_ECC_PUB.evaluate_eligibility_criteria(p_api_version
                                                    ,p_init_msg_list
                                                    ,x_return_status
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,l_okl_ec_rec_type
                                                    ,x_eligible);

           IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
             RAISE okl_api.g_exception_unexpected_error;
           ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
              RAISE okl_api.g_exception_error;
           END IF;
           IF(x_eligible) THEN
              l_okl_vp_table(i).id:=l_okl_vp_rec.id;
              l_okl_vp_table(i).contract_number:=l_okl_vp_rec.contract_number;
              i:=i+1;
           END IF;
        END LOOP;
        x_okl_vp_table:=l_okl_vp_table;
        IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_statement
                                 ,l_module
                                 ,'OKL_EC_UPTAKE_PVT.populate_vpa returned with status ' ||
                                  l_return_status ||
                                  ' x_msg_data ' ||
                                  x_msg_data);
        END IF;  -- end of NVL(l_debug_enabled,'N')='Y'

        IF (l_return_status = okl_api.g_ret_sts_error) THEN
          RAISE okl_api.g_exception_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
          RAISE okl_api.g_exception_unexpected_error;
        END IF;
       okl_api.end_activity(x_msg_count =>                x_msg_count
                            ,x_msg_data  =>                x_msg_data);

        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'end debug OKL_EC_UPTAKE_PVT.populate_vpa ');
        END IF;

    EXCEPTION
          WHEN okl_api.g_exception_error THEN

            x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                        ,p_pkg_name  =>                G_PKG_NAME
                                                        ,p_exc_name  =>                'OKL_API.G_RET_STS_ERROR'
                                                        ,x_msg_count =>                x_msg_count
                                                        ,x_msg_data  =>                x_msg_data
                                                        ,p_api_type  =>                G_API_TYPE);

          WHEN okl_api.g_exception_unexpected_error THEN

            x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                        ,p_pkg_name  =>                G_PKG_NAME
                                                        ,p_exc_name  =>                'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                        ,x_msg_count =>                x_msg_count
                                                        ,x_msg_data  =>                x_msg_data
                                                        ,p_api_type  =>                G_API_TYPE);

          WHEN OTHERS THEN

            x_return_status := okl_api.handle_exceptions(p_api_name  =>                l_api_name
                                                        ,p_pkg_name  =>                G_PKG_NAME
                                                        ,p_exc_name  =>                'OTHERS'
                                                        ,x_msg_count =>                x_msg_count
                                                        ,x_msg_data  =>                x_msg_data
                                                        ,p_api_type  =>                G_API_TYPE);
     END populate_vendor_program;
------------------------------------------------------------------------------------
END OKL_EC_UPTAKE_PVT;

/
