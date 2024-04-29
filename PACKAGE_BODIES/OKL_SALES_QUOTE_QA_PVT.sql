--------------------------------------------------------
--  DDL for Package Body OKL_SALES_QUOTE_QA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SALES_QUOTE_QA_PVT" AS
/* $Header: OKLRQQCB.pls 120.78 2008/01/04 19:39:51 rravikir noship $*/

 --Global Cursors
    CURSOR get_message_text(p_message_name VARCHAR2) IS
      SELECT MESSAGE_TEXT
      FROM FND_NEW_MESSAGES
      WHERE MESSAGE_NAME = p_message_name
      AND LANGUAGE_CODE = USERENV('LANG');


    CURSOR c_lq_fee_rec(p_parent_object_id NUMBER,p_fee_type VARCHAR2) IS
      select * from okl_fees_v ofv
      WHERE ofv.parent_object_id=p_parent_object_id
      AND ofv.fee_type=p_fee_type;

    CURSOR c_lq_cfl_line(p_source_id NUMBER,p_oty_code VARCHAR2) IS
      SELECT CFL.*
      FROM OKL_CASH_FLOW_OBJECTS CFO,OKL_CASH_FLOWS CAF,
           OKL_CASH_FLOW_LEVELS CFL
      WHERE CFO.ID=CAF.CFO_ID
      AND   CAF.ID=CFL.CAF_ID
      AND   CFO.oty_code=p_oty_code
      AND   CFO.source_id=p_source_id;



    CURSOR c_qq_header_rec(p_quote_id NUMBER) IS
      SELECT t1.* FROM OKL_QUICK_QUOTES_B t1
      WHERE t1.id = p_quote_id;

    CURSOR c_lq_header_rec(p_quote_id NUMBER) IS
      SELECT t1.* FROM OKL_LEASE_QUOTES_B t1
      WHERE t1.id = p_quote_id;

    lp_qq_header_rec  c_qq_header_rec%ROWTYPE;
    lp_lq_header_rec  c_lq_header_rec%ROWTYPE;

/*------------------------------------------------------------------------------
    -- PROCEDURE  set_fnd_message
  ------------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name   : set_fnd_message
    -- Description     : This Procedure sets the message name and tokens in
                         fnd_message and returns the retrieved message text.
    --
    -- Business Rules  :
    --
    -- Parameters      : p_msg_name   -- MESSAGE_NAME FROm FND_NEW_MESAGES

                        p_token1 -- Token Code for Message
                        p_value1 --> Value to be set in the Message for Token1

    -- Version         :
    -- History         :
    -- End of comments
------------------------------------------------------------------------------*/
  PROCEDURE set_fnd_message(p_msg_name  IN  varchar2
                           ,p_token1    IN  varchar2 DEFAULT NULL
                           ,p_value1    IN  varchar2 DEFAULT NULL
                           ,p_token2    IN  varchar2 DEFAULT NULL
                           ,p_value2    IN  varchar2 DEFAULT NULL
                           ,p_token3    IN  varchar2 DEFAULT NULL
                           ,p_value3    IN  varchar2 DEFAULT NULL
                           ,p_token4    IN  varchar2 DEFAULT NULL
                           ,p_value4    IN  varchar2 DEFAULT NULL) IS

    l_msg                          varchar2(2700);
    l_module              CONSTANT fnd_log_messages.module%TYPE := 'set_fnd_message';
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
                             ,'begin debug OKLRECUB.pls.pls call set_fnd_message');
    END IF;
    fnd_message.set_name(g_app_name, p_msg_name);

    IF (p_token1 IS NOT NULL) THEN
      fnd_message.set_token(token =>  p_token1, value =>  p_value1);
    END IF;

    IF (p_token2 IS NOT NULL) THEN
      fnd_message.set_token(token =>  p_token2, value =>  p_value2);
    END IF;

    IF (p_token3 IS NOT NULL) THEN
      fnd_message.set_token(token =>  p_token3, value =>  p_value3);
    END IF;

    IF (p_token4 IS NOT NULL) THEN
      fnd_message.set_token(token =>  p_token4, value =>  p_value4);
    END IF;

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug OKLRECUB.pls.pls call set_fnd_message');
    END IF;

  END set_fnd_message;
/*------------------------------------------------------------------------------
    -- PROCEDURE  populate_lq_rec_values
  ------------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name   : populate_lq_rec_values

    -- Description     :  This method will populate the Lease Quote Record
                          Structure in order to Pass all the Required Attributes
                          for Eligibility Criteria for Eligibility of SRT,LRS,VP,Product

    -- Business Rules  :Populate Header for Quick Quote for a Given Lease Quote id
    --
    -- Parameters      : p_object_id   -- Lease Quote id

                         x_okl_ec_rec --> Hold all the Eligibility criteria values
                        for a given Lease Quote

    -- Version         :
    -- History         :
    -- End of comments
------------------------------------------------------------------------------*/
  PROCEDURE populate_lq_rec_values(p_target_id number,
                                   l_okl_ec_rec_type IN OUT NOCOPY okl_ec_evaluate_pvt.okl_ec_rec_type) IS

       i                   INTEGER;
       l_module            CONSTANT fnd_log_messages.module%TYPE := 'lrs';
       l_debug_enabled                varchar2(10);
       is_debug_procedure_on          boolean;
       is_debug_statement_on          boolean;
       p_api_version         CONSTANT number := 1.0;
       x_return_status                varchar2(1) := okl_api.g_ret_sts_success;
       l_program_name      CONSTANT VARCHAR2(30) := 'populate';
       l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
       l_parent_object_id   NUMBER;
       l_parent_object_code VARCHAR2(30);
       l_expected_start_date DATE;
       l_term  NUMBER;
       l_validation_mode VARCHAR2(5):='LOV';
       --Bug # 5050143 ssdeshpa start
       l_deal_size NUMBER;
       l_adj_amount NUMBER;
       --Bug # 5050143 ssdeshpa end
       CURSOR c_lq_rec(p_lease_quote_id NUMBER) IS
         SELECT *
         FROM OKL_LEASE_QUOTES_B
         where id=p_lease_quote_id;
       l_lq_rec  c_lq_rec%ROWTYPE;

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
                lop.sales_territory_id
         from okl_lease_opportunities_b lop
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
                lapp.sales_territory_id
         from okl_lease_applications_b lapp
         where lapp.id=p_parent_object_id;

         l_lapp_rec  c_lapp_rec%ROWTYPE;
         --Bug # 5050143 ssdeshpa start

         --Added Cursors to get Deal Size of LQ
         CURSOR c_deal_size_cur(p_parent_object_id NUMBER) IS
           select SUM(OEC)
           FROM OKL_LEASE_QUOTES_B OLQ,OKL_ASSETS_B OAB
           where OAB.PARENT_OBJECT_ID = OLQ.ID
           AND OAB.PARENT_OBJECT_CODE='LEASEQUOTE'
           AND OLQ.ID= p_parent_object_id;
         --Added Cursors to get Adjustment(DN,Trade In Subsidy) for LQ
         cursor c_lq_cost_adj_rec(p_quote_id NUMBER,p_adj_type VARCHAR2) IS
           SELECT SUM(VALUE)
           FROM OKL_COST_ADJUSTMENTS_B OCA,
                OKL_ASSETS_B OAB
           where OAB.PARENT_OBJECT_CODE = 'LEASEQUOTE'
           AND OCA.PARENT_OBJECT_CODE='ASSET'
           AND OCA.PARENT_OBJECT_ID=OAB.ID
           and ADJUSTMENT_SOURCE_TYPE =p_adj_type
           AND OAB.PARENT_OBJECT_ID = p_quote_id;
         --Addes cursor to get Item For LQ
         CURSOR c_cost_comp_cur(p_quote_id NUMBER) IS
           select OAC.INV_ITEM_ID
           from OKL_ASSET_COMPONENTS_B OAC,
               OKL_ASSETS_B OAB
           WHERE OAC.ASSET_ID = OAB.ID
           AND OAB.PARENT_OBJECT_CODE = 'LEASEQUOTE'
           AND PRIMARY_COMPONENT='YES'
           AND OAB.PARENT_OBJECT_ID = p_quote_id;
         --Bug # 5050143 ssdeshpa end

        BEGIN

        OPEN  c_lq_rec(p_target_id);
        FETCH c_lq_rec INTO l_lq_rec;
        CLOSE c_lq_rec;
        l_okl_ec_rec_type.target_id := p_target_id;
        l_okl_ec_rec_type.target_eff_from:=l_lq_rec.expected_start_date;
        l_okl_ec_rec_type.term:=l_lq_rec.term;
        l_okl_ec_rec_type.validation_mode := l_validation_mode;

         --Bug 5050143 ssdeshpa start
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
         IF(l_lq_rec.parent_object_code = 'LEASEOPP') THEN
            OPEN c_lop_rec(l_parent_object_id);
            FETCH c_lop_rec INTO l_lop_rec;
            l_okl_ec_rec_type.territory:= l_lop_rec.sales_territory_id;
            l_okl_ec_rec_type.customer_credit_class:= l_lop_rec.customer_credit_class;
            CLOSE c_lop_rec;
         ELSIF(l_lq_rec.parent_object_code = 'LEASEAPP') THEN
            OPEN c_lapp_rec(l_parent_object_id);
            FETCH c_lapp_rec INTO l_lapp_rec;
            l_okl_ec_rec_type.territory:= l_lapp_rec.sales_territory_id;
            l_okl_ec_rec_type.customer_credit_class:= l_lapp_rec.customer_credit_class;
            CLOSE c_lapp_rec;
         END IF;

        EXCEPTION
        WHEN OTHERS THEN
             OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_DB_ERROR,
                                  p_token1       => G_PROG_NAME_TOKEN,
                                  p_token1_value => l_api_name,
                                  p_token2       => G_SQLCODE_TOKEN,
                                  p_token2_value => sqlcode,
                                  p_token3       => G_SQLERRM_TOKEN,
                                  p_token3_value => sqlerrm);
   END populate_lq_rec_values;
--------------------------------------------------------------------------------
/** obsolete Method **/
/*     PROCEDURE check_srt_effective_rate(p_srt_version_id NUMBER,
                                        p_quote_id NUMBER,
                                        x_qa_result_tbl IN OUT NOCOPY qa_results_tbl_type) IS
         l_msg_count        NUMBER;
         l_module            CONSTANT fnd_log_messages.module%TYPE := 'srt';
         l_debug_enabled                varchar2(10);
         is_debug_procedure_on          boolean;
         is_debug_statement_on          boolean;
         p_api_version         CONSTANT number := 1.0;
         x_return_status     VARCHAR2(1);
         l_program_name      CONSTANT VARCHAR2(30) := 'p_srtlq';
         l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
         l_okl_ec_rec_type  okl_ec_evaluate_pvt.okl_ec_rec_type;
         l_ac_rec_type     okl_ec_evaluate_pvt.okl_ac_rec_type;
         l_adj_factor           NUMBER;
         l_srt_effective_rate   NUMBER;
         l_srt_valid boolean := FALSE;
         i           INTEGER;
         CURSOR c_srt_rec(srt_id number) IS
	          select srt.template_name as name,
                     srv.std_rate_tmpl_ver_id,
	                 srv.version_number,
	                 srv.effective_from_date effective_from,
	                 srv.effective_to_date effective_to,
	                 srv.srt_rate,
	                 srv.sts_code,
	                 srv.day_convention_code,
	                 srv.spread spread,
                     srv.adj_mat_version_id adj_mat_version_id,
                     srv.min_adj_rate,
                     srv.max_adj_rate
	          from
	                  okl_fe_std_rt_tmp_vers srv,
	                  okl_fe_std_rt_tmp_v srt
	          where
	                  srv.std_rate_tmpl_ver_id= p_srt_version_id
              AND     srt.std_rate_tmpl_id=srv.std_rate_tmpl_id;

	          l_srt_rec         c_srt_rec%ROWTYPE;

         BEGIN
           OPEN  c_srt_rec(p_srt_version_id);
           FETCH c_srt_rec INTO l_srt_rec;
           CLOSE c_srt_rec;
            l_okl_ec_rec_type.target_id:= p_quote_id;
            l_okl_ec_rec_type.target_type:= 'LEASEQUOTE';

     -------------------------------------------------------------------------------------
            populate_lq_rec_values(p_quote_id,l_okl_ec_rec_type);
    --------------------------------------------------------------------------------------
           -- Populate the Adjustment mat. rec.
           l_ac_rec_type.src_id := l_srt_rec.adj_mat_version_id; -- Pricing adjustment matrix ID
           l_ac_rec_type.source_name := NULL; -- NOT Mandatory Pricing Adjustment Matrix Name !
           l_ac_rec_type.target_id := p_quote_id ; -- Quote ID
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
                      x_msg_count         => l_msg_count,
                      x_msg_data          => x_msg_data,
                      p_okl_ac_rec        => l_ac_rec_type,
                      x_adjustment_factor => l_adj_factor );
                IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
                --Calculate Effective Rate
                l_srt_effective_rate := l_srt_rec.srt_rate + nvl(l_srt_rec.spread,0) + nvl(l_adj_factor,0); -- Rate is being stored as Percentage
             --l_okl_srt_table(i).srt_rate := l_okl_srt_rec.srt_rate + nvl(l_okl_srt_rec.spread,0) + nvl(l_adj_factor,0); -- Rate is being stored as Percentage
               IF(l_srt_effective_rate IS NOT NULL) THEN
                  IF(nvl(l_srt_rec.max_adj_rate,l_srt_effective_rate) < l_srt_effective_rate )THEN
                    set_fnd_message(p_msg_name  => 'OKL_QA_SRT_MAX_RATE_VALID'
                           ,p_token1    =>  'SRT_NAME'
                           ,p_value1    =>  l_srt_rec.name
                           ,p_token2    =>  'EFF_RATE'
                           ,p_value2    =>  l_srt_effective_rate
                           ,p_token3    =>  'MAX_ADJ_RATE'
                           ,p_value3    =>  l_srt_rec.max_adj_rate
                           ,p_token4    =>  NULL
                           ,p_value4    =>  NULL);
                     i:=x_qa_result_tbl.COUNT;
                     i:=i+1;
                     x_qa_result_tbl(i).check_code:='check_srt_effective_rate';
                     x_qa_result_tbl(i).check_meaning:='SRT_EFF_RATE_IS_INVALID';
                     x_qa_result_tbl(i).result_code:='ERROR';
                     x_qa_result_tbl(i).result_meaning:='ERROR';
                     x_qa_result_tbl(i).message_code:= 'OKL_QA_SRT_MAX_RATE_VALID';
                     x_qa_result_tbl(i).message_text:= fnd_message.get;

                  ELSIF(nvl(l_srt_rec.min_adj_rate,l_srt_effective_rate) > l_srt_effective_rate) THEN
                     set_fnd_message(p_msg_name  => 'OKL_QA_SRT_MIN_RATE_VALID'
                           ,p_token1    =>  'SRT_NAME'
                           ,p_value1    =>  l_srt_rec.name
                           ,p_token2    =>  'EFF_RATE'
                           ,p_value2    =>  l_srt_effective_rate
                           ,p_token3    =>  'MIN_ADJ_RATE'
                           ,p_value3    =>  l_srt_rec.min_adj_rate
                           ,p_token4    =>  NULL
                           ,p_value4    =>  NULL);
                     i:=x_qa_result_tbl.COUNT;
                     i:=i+1;
                     x_qa_result_tbl(i).check_code:='check_srt_effective_rate';
                     x_qa_result_tbl(i).check_meaning:='SRT_EFF_RATE_IS_INVALID';
                     x_qa_result_tbl(i).result_code:='ERROR';
                     x_qa_result_tbl(i).result_meaning:='ERROR';
                     x_qa_result_tbl(i).message_code:= 'OKL_QA_SRT_MIN_RATE_VALID';
                     x_qa_result_tbl(i).message_text:= fnd_message.get;
                  END IF;
               END IF;

               EXCEPTION
               WHEN OTHERS THEN
                 OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME,
                               p_msg_name     => G_DB_ERROR,
                               p_token1       => G_PROG_NAME_TOKEN,
                               p_token1_value => l_api_name,
                               p_token2       => G_SQLCODE_TOKEN,
                               p_token2_value => sqlcode,
                               p_token3       => G_SQLERRM_TOKEN,
                               p_token3_value => sqlerrm);

     END check_srt_effective_rate; */
/*------------------------------------------------------------------------------
    -- PROCEDURE  execute_system_validation
  ------------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name   : execute_system_validation
    -- Description     :  This will executes the Validation Listed in the
                          System Level Validation Set
    --
    -- Business Rules  :
    --
    -- Parameters      : p_function_name   -- Function Name to be Execute

                         x_value -- Valid Values are 0 or 1
                                   If 1 function executed successfully
                                   If 0 function not executed successfully

    -- Version         :
    -- History         :
    -- End of comments
------------------------------------------------------------------------------*/
    PROCEDURE execute_system_validation(p_api_version       IN  NUMBER
                                       ,p_init_msg_list     IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                                       ,x_return_status     OUT NOCOPY VARCHAR2
                                       ,x_msg_count         OUT NOCOPY NUMBER
                                       ,x_msg_data          OUT NOCOPY VARCHAR2
                                       ,p_function_name     IN  okl_data_src_fnctns_v.name%TYPE
                                       ,x_value             OUT NOCOPY NUMBER
                                       ) IS

     -- Exception declarations
     FUNCTION_DATA_INVALID      EXCEPTION;
     FUNCTION_RETURNS_NULL      EXCEPTION;

    --  Local Variable Declarations
    l_value                NUMBER;
    l_evaluated_string     okl_formulae_v.formula_string%TYPE;
    l_no_dml_message       VARCHAR2(200) := 'OKL_FORMULAE_NO_DML';
    l_function_name        okl_data_src_fnctns_v.name%TYPE;
    l_function_source      okl_data_src_fnctns_v.source%TYPE;


    l_program_name      CONSTANT VARCHAR2(30) := 'exc_sys_vldtion';
    l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
    l_flag                 BOOLEAN DEFAULT FALSE;

    CURSOR data_src_fnctns_csr(cp_function_name IN okl_data_src_fnctns_v.name%TYPE)
    IS
      SELECT source
        FROM okl_data_src_fnctns_v
       WHERE name = cp_function_name
       AND fnctn_code = 'VALIDATION';

  BEGIN


    l_function_name  := p_function_name;

    FOR l_data_src_fnctns_csr IN data_src_fnctns_csr(cp_function_name => l_function_name)
    LOOP
      l_flag := TRUE;
      l_function_source := l_data_src_fnctns_csr.source;
      EXIT;
    END LOOP;


    IF l_flag THEN
      l_flag := FALSE;
    ELSE
      RAISE NO_DATA_FOUND;
    END IF;

    l_evaluated_string := l_function_source;

   IF l_evaluated_string IS NULL THEN
     RAISE FUNCTION_DATA_INVALID;
   ELSE
     l_evaluated_string  := 'SELECT '||l_evaluated_string ||' FROM dual';
   END IF;

   EXECUTE IMMEDIATE l_evaluated_string
                INTO l_value;

   IF l_value IS NULL THEN
    RAISE FUNCTION_RETURNS_NULL;
   ELSE
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     x_value := l_value;
  END IF;

 EXCEPTION
    WHEN FUNCTION_RETURNS_NULL THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => 'OKL_FUNCTION_RETURNS_NULL'
                         ,p_token1            => 'FUNCTION'
                         ,p_token1_value      => l_function_name );
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN FUNCTION_DATA_INVALID THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_function_data_invalid
                         ,p_token1            => 'FUNCTION'
                         ,p_token1_value      => l_function_name );
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN NO_DATA_FOUND THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_invalid_function
                         ,p_token1            => 'FUNCTION'
                         ,p_token1_value      => l_function_name );
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
       okl_api.set_message(p_app_name         =>  g_app_name
                         ,p_msg_name          =>  'OKL_SYSTEM_VALIDATION_FAILED'
                         ,p_token1            =>  'NAME'
                         ,p_token1_value      =>  l_function_name);

      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END execute_system_validation;
/*------------------------------------------------------------------------------
    -- PROCEDURE  populate_result_table
  ------------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name   :  populate_result_table
    -- Description     :  This will populate the Database with QA Results for
                          Lease Quote
    --
    -- Business Rules  :
    --
    -- Parameters      : p_object_id   -- Lease Quote Id

                        p_object_type -- valid values are  'LEASEQUOTE'
                        hold which type of object this method is calling

                        x_qa_result_tbl --> Hold all the QA Results for Object

    -- Version         :
    -- History         :
    -- End of comments
------------------------------------------------------------------------------*/
   procedure populate_result_table(p_api_version      IN NUMBER
                                  ,p_init_msg_list    IN VARCHAR2
                                  ,p_object_type      IN VARCHAR2
                                  ,p_object_id        IN NUMBER
                                  ,x_return_status    OUT NOCOPY VARCHAR2
                                  ,x_msg_count        OUT NOCOPY NUMBER
                                  ,x_msg_data         OUT NOCOPY VARCHAR2
                                  ,x_qa_result_tbl    IN OUT NOCOPY OKL_SALES_QUOTE_QA_PVT.qa_results_tbl_type) IS

       l_validation_set_id           NUMBER;
       lp_vlrv_tbl  OKL_VLR_PVT.vlrv_tbl_type;
       lx_vlrv_tbl  OKL_VLR_PVT.vlrv_tbl_type;
       i                              INTEGER;
       ret                            boolean;
       fun_ret                        number;
       call_user                      boolean;
       l_function_name                okl_data_src_fnctns_v.name%TYPE;
       l_source_name                  okl_data_src_fnctns_v.source%TYPE;
       l_failure_severity             VARCHAR2(30);
       l_module              CONSTANT fnd_log_messages.module%TYPE := 'OKLRQQCB.pls.run_qa';
       l_debug_enabled                varchar2(10);
       is_debug_procedure_on          boolean;
       is_debug_statement_on          boolean;
       cursor c_sys_opt_vls IS
         select validation_set_id
         FROM OKL_SYSTEM_PARAMS_ALL;
        BEGIN
          OPEN c_sys_opt_vls;
          FETCH c_sys_opt_vls INTO l_validation_set_id;
          CLOSE c_sys_opt_vls;
          IF(l_validation_set_id IS NULL) THEN
             l_validation_set_id := -1;
          END IF;
          IF(x_qa_result_tbl.COUNT > 0) THEN
            FOR i IN x_qa_result_tbl.FIRST..x_qa_result_tbl.LAST LOOP
              IF(x_qa_result_tbl.exists(i)) THEN
                lp_vlrv_tbl(i).parent_object_code := p_object_type;
                lp_vlrv_tbl(i).parent_object_id := p_object_id;
                lp_vlrv_tbl(i).validation_id := l_validation_set_id;
                lp_vlrv_tbl(i).result_code := x_qa_result_tbl(i).result_code;
                lp_vlrv_tbl(i).validation_text := x_qa_result_tbl(i).message_text;
              END IF;
            END LOOP;
          END IF;
          OKL_VLR_PVT.insert_row( p_api_version   => p_api_version,
                                  p_init_msg_list => p_init_msg_list,
                                  x_return_status => x_return_status,
                                  x_msg_count     => x_msg_count,
                                  x_msg_data      => x_msg_data,
                                  p_vlrv_tbl     =>  lp_vlrv_tbl,
                                  x_vlrv_tbl     =>  lx_vlrv_tbl);

           IF (nvl(l_debug_enabled, 'N') = 'Y' AND is_debug_statement_on) THEN
               okl_debug_pub.log_debug(fnd_log.level_statement
                                      ,l_module
                                      ,'okl_sales_quote_pvt.populate_result_table returned with status ' ||
                                       x_return_status ||
                                       ' x_msg_data ' ||
                                       x_msg_data);
           END IF;  -- end of NVL(l_debug_enabled,'N')='Y'
           IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
               RAISE okl_api.g_exception_unexpected_error;
           ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
               RAISE okl_api.g_exception_unexpected_error;
           END IF;

      EXCEPTION
       WHEN okl_api.g_exception_unexpected_error THEN
          x_return_status := okl_api.g_ret_sts_unexp_error;
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => G_DB_ERROR,
                               p_token1       => G_PROG_NAME_TOKEN,
                               p_token1_value => 'OKLRQQCB.pls.populate_result_table',
                               p_token2       => G_SQLCODE_TOKEN,
                               p_token2_value => sqlcode,
                               p_token3       => G_SQLERRM_TOKEN,
                               p_token3_value => sqlerrm);

     WHEN OTHERS THEN
       -- unexpected error
       x_return_status := okl_api.g_ret_sts_unexp_error;
       OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => G_DB_ERROR,
                               p_token1       => G_PROG_NAME_TOKEN,
                               p_token1_value => 'OKLRQQCB.pls.populate_result_table',
                               p_token2       => G_SQLCODE_TOKEN,
                               p_token2_value => sqlcode,
                               p_token3       => G_SQLERRM_TOKEN,
                               p_token3_value => sqlerrm);

  END populate_result_table;
 /*-----------------------------------------------------------------------------
    -- FUNCTION get_msg_text
   -----------------------------------------------------------------------------
    -- Start of comments
    --
    -- Function Name   : get_msg_text
    -- Description     : Return Message text for a given message code
                         If message text is null then it will return Message code
    --
    -- Business Rules  : If message text is null then it will return Message code
    --
    -- Parameters      :
    -- Version         :
    -- History         :
    -- End of comments
------------------------------------------------------------------------------*/
    FUNCTION get_msg_text(p_message_name VARCHAR2) RETURN VARCHAR2 IS
       l_msg_text VARCHAR2(2000);
       BEGIN

       OPEN get_message_text(p_message_name);
       FETCH get_message_text INTO l_msg_text;
       CLOSE get_message_text;
       IF(l_msg_text IS NULL) THEN
          l_msg_text :=p_message_name;
       END IF;
       RETURN l_msg_text;
       EXCEPTION
       WHEN OTHERS THEN

        IF get_message_text%ISOPEN THEN
           CLOSE get_message_text;
         END IF;
         -- unexpected error
         OKL_API.SET_MESSAGE (p_app_name        => G_APP_NAME,
                              p_msg_name     => G_DB_ERROR,
                              p_token1       => G_PROG_NAME_TOKEN,
                              p_token1_value => 'OKLRQQCB.pls.get_msg_text',
                              p_token2       => G_SQLCODE_TOKEN,
                              p_token2_value => sqlcode,
                              p_token3       => G_SQLERRM_TOKEN,
                              p_token3_value => sqlerrm);
   END get_msg_text;
--------------------------------------------------------------------------------
  /**
  This procedure will validate all cash flows for Asset/Quote
  **/
   PROCEDURE validate_cashflows(p_quote_id number
                               ,p_oty_code VARCHAR2
                               ,p_pricing_method VARCHAR2
                               ,x_qa_result_tbl IN OUT NOCOPY qa_results_tbl_type
                               ,x_return_status OUT NOCOPY VARCHAR2) IS
    -- Variables Declarations
    p_api_version CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name    CONSTANT VARCHAR2(30) DEFAULT 'validate_cashflows';
    i                      NUMBER;
--Bug 6359406 PAGARG initialising the counter to check cfl count, which is used
--to set error message if count is zero
    l_cfl_count            INTEGER := 0;
    CURSOR c_cash_flow_cur(p_quote_id NUMBER,
                           p_oty_code VARCHAR2) IS
       SELECT CFO.ID CFO_ID,
              CAF.ID CAF_ID,
              CAF.STY_ID,
              CAF.cft_code,
              CAF.due_arrears_yn
        FROM OKL_CASH_FLOW_OBJECTS CFO,OKL_CASH_FLOWS CAF
        WHERE CAF.cfo_id = CFO.ID
        AND CFO.OTY_CODE =  p_oty_code
        AND   CFO.SOURCE_ID = p_quote_id;

    CURSOR c_cash_flow_level_cur(p_source_id NUMBER,p_oty_code VARCHAR2) IS
        SELECT CFL.id,
               CFL.amount,
               CFL.number_of_periods,
               CFL.stub_days,
               CFL.stub_amount
        FROM OKL_CASH_FLOW_OBJECTS CFO,OKL_CASH_FLOWS CAF,
             OKL_CASH_FLOW_LEVELS CFL
        WHERE CFO.ID=CAF.CFO_ID
        AND   CAF.ID=CFL.CAF_ID
        AND   CFO.oty_code=p_oty_code
        AND   CFO.source_id=p_source_id;

    BEGIN

    FOR cash_flow_cur_rec IN c_cash_flow_cur(p_quote_id,p_oty_code) LOOP
        IF(cash_flow_cur_rec.STY_ID IS NULL) THEN
          i:=x_qa_result_tbl.COUNT;
          i:=i+1;
          x_qa_result_tbl(i).check_code:='validate_payment_options';
          x_qa_result_tbl(i).check_meaning:='ARREARS IS NOT FOUND FOR QUOTE';
          x_qa_result_tbl(i).result_code:='ERROR';
          x_qa_result_tbl(i).result_meaning:='ERROR';
          x_qa_result_tbl(i).message_code:= 'OKL_QA_CFL_STRM_NOT_FOUND';
          x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_CFL_STRM_NOT_FOUND');
          EXIT;
        END IF;/*
        IF(cash_flow_cur_rec.due_arrears_yn IS NULL) THEN
         i:=x_qa_result_tbl.COUNT;
         i:=i+1;
         x_qa_result_tbl(i).check_code:='validate_payment_options';
         x_qa_result_tbl(i).check_meaning:='ARREARS IS NOT FOUND FOR QUOTE';
         x_qa_result_tbl(i).result_code:='ERROR';
         x_qa_result_tbl(i).result_meaning:='ERROR';
         x_qa_result_tbl(i).message_code:= 'OKL_QA_ARR_NOT_FOUND';
         x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_ARR_NOT_FOUND');
         EXIT;
        END IF;*/
    END LOOP;
    FOR cash_flow_level_rec IN c_cash_flow_level_cur(p_quote_id,p_oty_code) LOOP
        l_cfl_count := l_cfl_count + 1;
        IF((p_pricing_method <> 'SP') AND
           ((cash_flow_level_rec.amount IS NULL AND cash_flow_level_rec.number_of_periods IS NULL) AND
           (cash_flow_level_rec.stub_days IS NULL AND cash_flow_level_rec.stub_amount IS NULL))) THEN
	        i:=x_qa_result_tbl.COUNT;
	        i:=i+1;
	        x_qa_result_tbl(i).check_code:='check_payments';
	        x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_FOR_QUOTE';
	        x_qa_result_tbl(i).result_code:='ERROR';
	        x_qa_result_tbl(i).result_meaning:='ERROR';
	        x_qa_result_tbl(i).message_code:= 'OKL_QA_MISSING_PAY_LEVEL';
	        x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_MISSING_PAY_LEVEL');

	        EXIT;
	    END IF;

   END LOOP;
   IF(l_cfl_count = 0) THEN
      i:=x_qa_result_tbl.COUNT;
	  i:=i+1;
	  x_qa_result_tbl(i).check_code:='validate_cashflows';
	  x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_FOR_QUOTE';
	  x_qa_result_tbl(i).result_code:='ERROR';
	  x_qa_result_tbl(i).result_meaning:='ERROR';
	  x_qa_result_tbl(i).message_code:= 'OKL_QA_MISSING_PAY_LEVEL';
	  x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_MISSING_PAY_LEVEL');

   END IF;

   EXCEPTION
      WHEN OTHERS THEN
      -- unexpected error
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => 'OKLRQQCB.pls.validate_cashflows',
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);
   END validate_cashflows;

  ------------------------------------------------------------------------------
  /** This function validates Pricing Option for Quote/Asset when SP='N'
  **/
  PROCEDURE validate_payment_options(p_srt_version_id NUMBER,
                                     p_arrears VARCHAR2,
                                     p_pricing_method VARCHAR2,
                                     p_periodic_amt NUMBER,
                                     x_qa_result_tbl IN OUT NOCOPY qa_results_tbl_type,
                                     x_return_status OUT NOCOPY VARCHAR2) IS

    -- Variables Declarations
    p_api_version CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name    CONSTANT VARCHAR2(30) DEFAULT 'val_pay_options';
    i                      NUMBER;

    BEGIN
    IF(p_srt_version_id IS NULL) THEN
      i:=x_qa_result_tbl.COUNT;
      i:=i+1;
      x_qa_result_tbl(i).check_code:='validate_payment_options';
      x_qa_result_tbl(i).check_meaning:='SRT IS NOT FOUND FOR QUOTE';
      x_qa_result_tbl(i).result_code:='ERROR';
      x_qa_result_tbl(i).result_meaning:='ERROR';
      x_qa_result_tbl(i).message_code:= 'OKL_QA_SRT_NOT_FOUND';
      x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SRT_NOT_FOUND');

    END IF;
   -- pricing treats areears = null as N . So need to do the validation . FOr bug 5172808
   /*
    IF(p_pricing_method <> 'SM' AND p_arrears IS NULL) THEN
      i:=x_qa_result_tbl.COUNT;
      i:=i+1;
      x_qa_result_tbl(i).check_code:='validate_payment_options';
      x_qa_result_tbl(i).check_meaning:='ARREARS IS NOT FOUND FOR QUOTE';
      x_qa_result_tbl(i).result_code:='ERROR';
      x_qa_result_tbl(i).result_meaning:='ERROR';
      x_qa_result_tbl(i).message_code:= 'OKL_QA_ARR_NOT_FOUND';
      x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_ARR_NOT_FOUND');

    END IF;
    */
    IF((p_pricing_method <> 'SM' AND p_pricing_method <> 'SP') AND p_periodic_amt IS NULL) THEN
      i:=x_qa_result_tbl.COUNT;
      i:=i+1;
      x_qa_result_tbl(i).check_code:='validate_payment_options';
      x_qa_result_tbl(i).check_meaning:='PERIODIC AMOUNT IS NOT FOUND FOR SRT';
      x_qa_result_tbl(i).result_code:='ERROR';
      x_qa_result_tbl(i).result_meaning:='ERROR';
      x_qa_result_tbl(i).message_code:= 'OKL_QA_SRT_AMT_NOT_FOUND';
      x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SRT_AMT_NOT_FOUND');

    END IF;

    EXCEPTION
       -- other appropriate handlers
       WHEN OTHERS THEN
         -- store SQL error message on message stack
         OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => 'OKLRQQCB.pls.val_pay_opt',
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);
       -- notify  UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_payment_options;
--------------------------------------------------------------------------------
  /**
   This function Check whether the Quote Level Payments Options Enterd or Not
  **/
  FUNCTION are_qte_pricing_opts_entered(p_lease_qte_rec    IN  lp_lq_header_rec%TYPE
                                       ,p_payment_count    IN  NUMBER
                                       ,x_return_status    OUT NOCOPY VARCHAR2)
    RETURN VARCHAR2 IS
    -- Variables Declarations
    p_api_version CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name    CONSTANT VARCHAR2(30) DEFAULT 'qte_pr_entr';
    l_falg                 VARCHAR2(3) := 'N';
  BEGIN
    IF p_lease_qte_rec.pricing_method = 'SY' THEN
       IF  p_payment_count <> 0 THEN
         return 'Y';
       END IF;
    ELSIF p_lease_qte_rec.pricing_method = 'RC' THEN
       IF p_lease_qte_rec.structured_pricing = 'N' AND  p_lease_qte_rec.rate_card_id IS NOT NULL
          OR p_lease_qte_rec.structured_pricing = 'Y' AND  p_lease_qte_rec.lease_rate_factor IS NOT NULL
       THEN
         return 'Y';
       END IF;
    ELSIF p_lease_qte_rec.pricing_method = 'SM' THEN
       IF (p_lease_qte_rec.structured_pricing = 'N' AND  ( p_lease_qte_rec.rate_template_id IS NOT NULL OR p_payment_count <> 0 ) )
          OR ( p_lease_qte_rec.structured_pricing = 'Y' AND  p_payment_count <> 0 )
       THEN
         return 'Y';
       END IF;
    ELSIF p_lease_qte_rec.pricing_method <> 'TR' THEN
       IF p_lease_qte_rec.structured_pricing = 'N' AND  p_lease_qte_rec.rate_template_id IS NOT NULL
          OR p_lease_qte_rec.structured_pricing = 'Y' AND  p_payment_count <> 0
       THEN
         return 'Y';
       END IF;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;
    RETURN 'N';

  EXCEPTION
       -- other appropriate handlers
       WHEN OTHERS THEN
         -- store SQL error message on message stack
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => 'OKLRQQCB.pls.are_qte_op_enter',
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);
       -- notify  UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END are_qte_pricing_opts_entered;
--------------------------------------------------------------------------------
   /**
  This function returns 'Y' when all the Asset on Quote Overriden Completely
  else Returns 'N'
  **/
  FUNCTION are_all_lines_overriden(p_quote_id           IN  NUMBER
                                  ,p_pricing_method     IN  VARCHAR2
                                  ,p_line_level_pricing IN VARCHAR2
                                  ,x_return_status      OUT NOCOPY VARCHAR2)
    RETURN VARCHAR2 IS
    -- Variables Declarations
    p_api_version CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name    CONSTANT VARCHAR2(30) DEFAULT 'all_lns_ovr';
    l_all_lines_overriden                 VARCHAR2(3) := 'N';
    l_ovr_cnt                           NUMBER;
    l_ast_cnt                           NUMBER;
    CURSOR llo_flag_csr IS
     SELECT count(*) overriden_assets_count
     FROM OKL_LEASE_QUOTES_B QTE,
          OKL_ASSETS_B AST
     WHERE AST.PARENT_OBJECT_ID = QTE.ID
     AND   (    AST.RATE_TEMPLATE_ID IS NOT NULL
             OR AST.STRUCTURED_PRICING = 'Y' )
     AND   QTE.ID = p_quote_id
     AND   p_line_level_pricing = 'Y';

    CURSOR rc_llo_flag_csr IS
     SELECT count(*) overriden_assets_count
     FROM OKL_LEASE_QUOTES_B QTE,
          OKL_ASSETS_B AST
     WHERE AST.PARENT_OBJECT_ID = QTE.ID
     AND   (    AST.RATE_CARD_ID IS NOT NULL
             OR AST.LEASE_RATE_FACTOR IS NOT NULL )
     AND   QTE.ID = p_quote_id
     AND   p_line_level_pricing = 'Y';

    CURSOR sy_llo_flag_csr IS
     SELECT count(*) overriden_assets_count
     FROM OKL_LEASE_QUOTES_B QTE,
          OKL_ASSETS_B AST
     WHERE AST.PARENT_OBJECT_ID = QTE.ID
     AND   (  AST.STRUCTURED_PRICING = 'Y')
     AND   QTE.ID = p_quote_id
     AND   p_line_level_pricing = 'Y';

    CURSOR ast_cnt_csr IS
     SELECT count(*) assets_count
     FROM OKL_LEASE_QUOTES_B QTE,
          OKL_ASSETS_B AST
     WHERE AST.PARENT_OBJECT_ID = QTE.ID
     AND   QTE.ID = p_quote_id;

  BEGIN
    IF p_pricing_method = 'SY' THEN
       OPEN sy_llo_flag_csr;
       FETCH sy_llo_flag_csr INTO l_ovr_cnt;
       CLOSE sy_llo_flag_csr;
    ELSIF p_pricing_method = 'RC' THEN
       OPEN rc_llo_flag_csr;
       FETCH rc_llo_flag_csr INTO l_ovr_cnt;
       CLOSE rc_llo_flag_csr;
    ELSIF p_pricing_method <> 'TR' THEN
       OPEN llo_flag_csr;
       FETCH llo_flag_csr INTO l_ovr_cnt;
       CLOSE llo_flag_csr;
    END IF;
    OPEN ast_cnt_csr;
    FETCH ast_cnt_csr INTO l_ast_cnt;
    CLOSE ast_cnt_csr;
    IF l_ast_cnt = 0 THEN
     l_all_lines_overriden := 'N';
    ELSIF l_Ast_cnt = l_ovr_cnt THEN
     l_all_lines_overriden := 'Y';
    ELSE
     l_all_lines_overriden := 'N';
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
    RETURN l_all_lines_overriden;

  EXCEPTION
   -- other appropriate handlers
   WHEN OTHERS THEN
     -- store SQL error message on message stack
     OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => 'OKLRQQCB.pls.all_lns_over',
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);
   -- notify  UNEXPECTED error
   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END are_all_lines_overriden;

/*------------------------------------------------------------------------------
    -- PROCEDURE validate_cost_adjustments
  ------------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name   : validate_cost_adjustments
    -- Description     :  Validate the Various Objects Under Adjustment Tab
                          Associated with Quote and distributed assets.
    --
    -- Business Rules  : Validate Down Payment/Subsidy/Trade-In of Quote
    --
    -- Parameters      : p_object_id   -- Lease Quote

                        p_object_type -- valid values are  'LEASEQUOTE'
                        hold which type of object this method is calling

                         x_qa_result_tbl --> Hold all the QA Results for Object

    -- Version         :
    -- History         :
    -- End of comments
------------------------------------------------------------------------------*/
   PROCEDURE validate_cost_adjustments(p_api_version      IN NUMBER
                                       ,p_init_msg_list    IN VARCHAR2
                                       ,p_object_type      IN VARCHAR2
                                       ,p_object_id        IN NUMBER
                                       ,x_return_status    OUT NOCOPY VARCHAR2
                                       ,x_msg_count        OUT NOCOPY NUMBER
                                       ,x_msg_data         OUT NOCOPY VARCHAR2
                                       ,x_qa_result_tbl    IN OUT NOCOPY OKL_SALES_QUOTE_QA_PVT.qa_results_tbl_type
                                       ,x_qa_result       IN  OUT NOCOPY VARCHAR2) IS
       i                 INTEGER;
       x                 VARCHAR2(2);
       lp_object_type    VARCHAR2(30);
       lp_quote_id       NUMBER;
       lp_asset_id       NUMBER;
       lp_asset_cost     INTEGER:=0;
       lp_cost_adj_total INTEGER:=0;
       lp_qq_lines_cost  INTEGER:=0;
       lp_rec_flag       VARCHAR2(1);
       l_flag  boolean:= FALSE;
       l_module            CONSTANT fnd_log_messages.module%TYPE := 'val_c_ad';
       l_debug_enabled     varchar2(10);
       is_debug_procedure_on boolean;
       is_debug_statement_on boolean;
       l_program_name        CONSTANT VARCHAR2(30) := 'val_c_ad';
       l_api_name            CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
       --Fetch Cost Adj For a Quote
       CURSOR c_okl_cost_adj_rec(p_quote_id NUMBER,
                                 p_adj_source_type VARCHAR2) IS
              SELECT OCA.id,OCA.adjustment_source_id
              FROM OKL_COST_ADJUSTMENTS_B OCA,OKL_ASSETS_B OAB
              WHERE OCA.PARENT_OBJECT_CODE = 'ASSET'
              AND   OCA.PARENT_OBJECT_ID = OAB.ID
              AND OAB.PARENT_OBJECT_CODE='LEASEQUOTE'
              AND OAB.PARENT_OBJECT_ID = p_quote_id
              AND OCA.ADJUSTMENT_SOURCE_TYPE= p_adj_source_type;
       lp_okl_cost_adj_rec c_okl_cost_adj_rec%ROWTYPE;
       BEGIN
       l_debug_enabled := okl_debug_pub.check_log_enabled;
       is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
        				   ,fnd_log.level_procedure);


       IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
         okl_debug_pub.log_debug(fnd_log.level_procedure
        			,l_module
        			,'begin debug OKLRQQCB.pls.validate_cost_adjustments call validate_cost_adjustments');
       END IF;  -- check for logging on STATEMENT level
       is_debug_statement_on := okl_debug_pub.check_log_on(l_module
        						  ,fnd_log.level_statement);

        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list

       x_return_status := okl_api.start_activity(p_api_name=>l_api_name
                            					,p_pkg_name=>G_PKG_NAME
        				                    	,p_init_msg_list=>p_init_msg_list
        					                    ,p_api_version=>p_api_version
        					                    ,l_api_version=>p_api_version
        					                    ,p_api_type=>G_API_TYPE
        					                    ,x_return_status=>x_return_status);  -- check if activity started successfully

       IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
       ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
       END IF;
       lp_object_type:= p_object_type;
       --start added abhsaxen for bug #5257890
       lp_quote_id := p_object_id;
       --end added abhsaxen for bug # 5257890
       IF(lp_quote_id IS NOT NULL) THEN
          IF(p_object_type='LEASEQUOTE') THEN
              OPEN c_lq_header_rec(lp_quote_id);
              FETCH c_lq_header_rec INTO lp_lq_header_rec;
              CLOSE c_lq_header_rec;
              --Check for Down Payment on a Quote Having payment Method 'SD'
              --It should not exist
              IF(lp_lq_header_rec.pricing_method = 'SD') THEN
                 OPEN c_okl_cost_adj_rec(lp_quote_id,'DOWN_PAYMENT');
                 FETCH c_okl_cost_adj_rec INTO lp_okl_cost_adj_rec;
                 IF(c_okl_cost_adj_rec%FOUND) THEN
                    i:=x_qa_result_tbl.COUNT;
                    i:=i+1;
                    x_qa_result_tbl(i).check_code:='validate_cost_adjustments';
                    x_qa_result_tbl(i).check_meaning:='DOWN_PAYMENT_ADJ_SPECIFIED_FOR_QUOTE';
                    x_qa_result_tbl(i).result_code:='ERROR';
                    x_qa_result_tbl(i).result_meaning:='ERROR';
                    x_qa_result_tbl(i).message_code:= 'OKL_QA_DN_ADJ_EXIST';
                    x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_DN_ADJ_EXIST');
                    x_qa_result := okl_api.g_ret_sts_error;
                 END IF;
                 CLOSE c_okl_cost_adj_rec;
              END IF;--End of Checking for Down Payment (SD method)
              --Check for Trade In Adj on a Quote Having payment Method 'SI'
              --It should not exist
             IF(lp_lq_header_rec.pricing_method = 'SI') THEN
                OPEN c_okl_cost_adj_rec(lp_quote_id,'TRADEIN');
                FETCH c_okl_cost_adj_rec INTO lp_okl_cost_adj_rec;
                IF(c_okl_cost_adj_rec%FOUND) THEN
                    i:=x_qa_result_tbl.COUNT;
                    i:=i+1;
                    x_qa_result_tbl(i).check_code:='validate_cost_adjustments';
                    x_qa_result_tbl(i).check_meaning:='TRADE_IN_ADJ_SPECIFIED_FOR_QUOTE';
                    x_qa_result_tbl(i).result_code:='ERROR';
                    x_qa_result_tbl(i).result_meaning:='ERROR';
                    x_qa_result_tbl(i).message_code:= 'OKL_QA_TRDIN_ADJ_EXIST';
                    x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_TRDIN_ADJ_EXIST');
                    x_qa_result := okl_api.g_ret_sts_error;
                END IF;
                CLOSE c_okl_cost_adj_rec;
             END IF;--End of Checking for Trade In (SI method)

             --Check for Subsidy Adj on a Quote Having payment Method 'SS'
             --if the Subsidy Id in okl_cost_adjustments_b is not null
             --then It should not exist else it can exist(Calculated by ISG)
             IF(lp_lq_header_rec.pricing_method = 'SS') THEN
                OPEN c_okl_cost_adj_rec(lp_quote_id,'SUBSIDY');
                FETCH c_okl_cost_adj_rec INTO lp_okl_cost_adj_rec;
		--start modified for bug#5257890
		IF(c_okl_cost_adj_rec%FOUND)  THEN
		--end modified for bug#5257890
                    i:=x_qa_result_tbl.COUNT;
                    i:=i+1;
                    x_qa_result_tbl(i).check_code:='validate_cost_adjustments';
                    x_qa_result_tbl(i).check_meaning:='SUBSIDY_ADJ_SPECIFIED_FOR_QUOTE';
                    x_qa_result_tbl(i).result_code:='ERROR';
                    x_qa_result_tbl(i).result_meaning:='ERROR';
                    x_qa_result_tbl(i).message_code:= 'OKL_QA_SUBSIDY_ADJ_EXIST';
                    x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SUBSIDY_ADJ_EXIST');
                    x_qa_result := okl_api.g_ret_sts_error;
                END IF;
                CLOSE c_okl_cost_adj_rec;
             END IF;--End of Checking for Trade In (SI method)
           END IF;--LQ End
          IF(p_object_type='QUICKQUOTE') THEN
             null;
          END IF;--QQ End
        END IF;--If Quote id Is NOT NULL:

        okl_api.end_activity(x_msg_count => x_msg_count
        		    ,x_msg_data  => x_msg_data);

        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
            okl_debug_pub.log_debug(fnd_log.level_procedure
        			    ,l_module
        			    ,'end debug okl_sales_quote_qa_pvt.validate_cost_adjustments call validate_cost_adjustments');
        END IF;


        EXCEPTION
        WHEN okl_api.g_exception_error THEN

           x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
        					       ,p_pkg_name  =>G_PKG_NAME
        					       ,p_exc_name  =>'OKL_API.G_RET_STS_ERROR'
        					       ,x_msg_count =>x_msg_count
        					       ,x_msg_data  =>x_msg_data
        					       ,p_api_type  =>G_API_TYPE);

         WHEN okl_api.g_exception_unexpected_error THEN

           x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
        					       ,p_pkg_name  =>G_PKG_NAME
        					       ,p_exc_name  =>'OKL_API.G_RET_STS_UNEXP_ERROR'
        					       ,x_msg_count =>x_msg_count
        					       ,x_msg_data  =>x_msg_data
        					       ,p_api_type  =>G_API_TYPE);

         WHEN OTHERS THEN

           x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
        					       ,p_pkg_name  =>G_PKG_NAME
        					       ,p_exc_name  =>'OTHERS'
        					       ,x_msg_count =>x_msg_count
        					       ,x_msg_data  =>x_msg_data
        					       ,p_api_type  =>G_API_TYPE);
       END validate_cost_adjustments;

/*------------------------------------------------------------------------------
    -- PROCEDURE validate_system_validations
---------------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name  : validate_system_validations
    -- Description     : This procedure will executes all the Validation under
                         Validation Set created for Particular ORG in Setup.
    --
    -- Business Rules  : Fetch all the System validation Listed under the System
                         Validation Set and executes it
    --
    -- Parameters      : p_object_id   -- Lease Quote Id

                        p_object_type -- valid values are  'LEASEQUOTE'
                        hold which type of object this method is calling

                         x_qa_result_tbl -- Hold all the QA Results for Object

    -- Version         : 1.0
    -- History         :
    -- End of comments
------------------------------------------------------------------------------*/
   PROCEDURE validate_system_validations(p_api_version      IN NUMBER
                                        ,p_init_msg_list    IN VARCHAR2
                                        ,p_object_type      IN VARCHAR2
                                        ,p_object_id        IN NUMBER
                                        ,x_return_status    OUT NOCOPY VARCHAR2
                                        ,x_msg_count        OUT NOCOPY NUMBER
                                        ,x_msg_data         OUT NOCOPY VARCHAR2
                                        ,x_qa_result_tbl    IN OUT NOCOPY OKL_SALES_QUOTE_QA_PVT.qa_results_tbl_type
                                        ,x_qa_result       IN  OUT NOCOPY VARCHAR2) IS

       i                              INTEGER;
       ret                            boolean;
       fun_ret                        number;
       call_user                      boolean;
       l_function_name                okl_data_src_fnctns_v.name%TYPE;
       l_source_name                  okl_data_src_fnctns_v.source%TYPE;
       l_failure_severity             VARCHAR2(30);
       l_module              CONSTANT fnd_log_messages.module%TYPE := 'OKL_SALES_QUOTE_QA_PVT.validate_system_validation';
       l_debug_enabled                varchar2(10);
       is_debug_procedure_on          boolean;
       is_debug_statement_on          boolean;
       l_message_name                varchar2(2000);
       l_program_name      CONSTANT VARCHAR2(30) := 'run_qa_qq';
       l_api_name          CONSTANT VARCHAR2(61) := l_program_name;

       --Cursor will get validation Set Id from a Setup table
       CURSOR c_sys_opt_vls IS
         select validation_set_id
         FROM OKL_SYSTEM_PARAMS;
       --Cursor will fetch all the Validation for a validation Set
       CURSOR c_validation_func(p_vls_id NUMBER) IS
          SELECT VLD.failure_severity,FUNCTNS.NAME,FUNCTNS.SOURCE
          FROM OKL_VALIDATIONS_B VLD,OKL_DATA_SRC_FNCTNS_B FUNCTNS
          WHERE FUNCTNS.ID=VLD.FUNCTION_ID
          AND   VLD.VALIDATION_SET_ID =p_vls_id;

       l_validation_set_id   NUMBER;

       BEGIN
       l_debug_enabled := okl_debug_pub.check_log_enabled;
       is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
        				   ,fnd_log.level_procedure);


       IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
           okl_debug_pub.log_debug(fnd_log.level_procedure
        			,l_module
        			,'begin debug OKLRQQCB.pls call validate_system_validations');
       END IF;  -- check for logging on STATEMENT level
       is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                						  ,fnd_log.level_statement);

       -- call START_ACTIVITY to create savepoint, check compatibility
       -- and initialize message list

        x_return_status := okl_api.start_activity(p_api_name => l_api_name
        					,p_pkg_name => G_PKG_NAME
        					,p_init_msg_list => p_init_msg_list
        					,p_api_version => p_api_version
        					,l_api_version => p_api_version
        					,p_api_type => G_API_TYPE
        					,x_return_status => x_return_status);  -- check if activity started successfully

       IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
            RAISE okl_api.g_exception_unexpected_error;
       ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
            RAISE okl_api.g_exception_error;
       END IF;

       fun_ret := 1;
       OPEN c_sys_opt_vls;
       FETCH c_sys_opt_vls INTO l_validation_set_id;
       CLOSE c_sys_opt_vls;

       IF(l_validation_set_id IS NOT NULL) THEN
          FOR validation_func_rec IN c_validation_func(l_validation_set_id) LOOP
              execute_system_validation(p_api_version   => p_api_version,
                                        p_init_msg_list => p_init_msg_list,
                                        x_return_status => x_return_status,
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_function_name => validation_func_rec.NAME,
                                        x_value         => fun_ret);
              IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
                  RAISE okl_api.g_exception_unexpected_error;
              ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
                  RAISE okl_api.g_exception_error;
              END IF;

             IF(fun_ret IS NULL OR fun_ret = 0) THEN
                i:=x_qa_result_tbl.COUNT;
                i:=i+1;
                x_qa_result_tbl(i).check_code:='validate_system_validations';
                x_qa_result_tbl(i).check_meaning:=validation_func_rec.name;
                x_qa_result_tbl(i).result_code:=nvl(validation_func_rec.failure_severity,'WARNING');
                x_qa_result_tbl(i).result_meaning:= nvl(validation_func_rec.failure_severity,'WARNING');
                x_qa_result_tbl(i).message_code:= 'OKL_QA_VLD_ERR';
                x_qa_result_tbl(i).message_text:= get_msg_text('OKL_QA_VLD_ERR')||validation_func_rec.name;
                IF(nvl(validation_func_rec.failure_severity,'WARNING')='ERROR') THEN
                   x_qa_result := okl_api.g_ret_sts_error;
                ELSE
                   x_qa_result := okl_api.g_ret_sts_warning;
                END IF;
             END IF;
           END LOOP;
         END IF;
         okl_api.end_activity(x_msg_count =>  x_msg_count
                            ,x_msg_data  => x_msg_data);
        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
            okl_debug_pub.log_debug(fnd_log.level_procedure
                 		    ,l_module
        			    ,'end debug okl_sales_quote_qa_pvt call validate_system_validation');
        END IF;
        EXCEPTION
          WHEN okl_api.g_exception_error THEN
           IF c_validation_func%ISOPEN THEN
             CLOSE c_validation_func;
           END IF;
           IF c_sys_opt_vls%ISOPEN THEN
             CLOSE c_sys_opt_vls;
           END IF;

           x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
					                                   ,p_pkg_name  =>G_PKG_NAME
					                                   ,p_exc_name  =>'OKL_API.G_RET_STS_ERROR'
					                                   ,x_msg_count =>x_msg_count
					                                   ,x_msg_data  =>x_msg_data
					                                   ,p_api_type  =>G_API_TYPE);

           WHEN okl_api.g_exception_unexpected_error THEN
            IF c_validation_func%ISOPEN THEN
             CLOSE c_validation_func;
           END IF;
           IF c_sys_opt_vls%ISOPEN THEN
             CLOSE c_sys_opt_vls;
           END IF;
           x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
					       ,p_pkg_name  =>G_PKG_NAME
					       ,p_exc_name  =>'OKL_API.G_RET_STS_UNEXP_ERROR'
					       ,x_msg_count =>x_msg_count
					       ,x_msg_data  =>x_msg_data
					       ,p_api_type  =>G_API_TYPE);

         WHEN OTHERS THEN
           IF c_validation_func%ISOPEN THEN
             CLOSE c_validation_func;
           END IF;
           IF c_sys_opt_vls%ISOPEN THEN
             CLOSE c_sys_opt_vls;
           END IF;
           x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
					                                   ,p_pkg_name  =>G_PKG_NAME
					                                   ,p_exc_name  =>'OTHERS'
					                                   ,x_msg_count =>x_msg_count
					                                   ,x_msg_data  =>x_msg_data
					                                   ,p_api_type  =>G_API_TYPE);

       END validate_system_validations;
/*------------------------------------------------------------------------------
    -- PROCEDURE  validate_pricing_values
  ------------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name   : validate_pricing_values
    -- Description     : Validation Related to Pricing Values for Quote
    --
    -- Business Rules  :
    --
    -- Parameters      : p_object_id   -- Lease Quote Id

                        p_object_type -- valid values are  'LEASEQUOTE'
                        hold which type of object this method is calling

                         x_qa_result_tbl --> Hold all the QA Results for Object

    -- Version         :
    -- History         :
    -- End of comments
------------------------------------------------------------------------------*/
   PROCEDURE validate_pricing_values(p_api_version      IN NUMBER
                                     ,p_init_msg_list    IN VARCHAR2
                                     ,p_object_type      IN VARCHAR2
                                     ,p_object_id        IN NUMBER
                                     ,x_return_status    OUT NOCOPY VARCHAR2
                                     ,x_msg_count        OUT NOCOPY NUMBER
                                     ,x_msg_data         OUT NOCOPY VARCHAR2
                                     ,x_qa_result_tbl    IN OUT NOCOPY OKL_SALES_QUOTE_QA_PVT.qa_results_tbl_type
                                     ,x_qa_result       IN  OUT NOCOPY VARCHAR2) IS
       lp_object_type VARCHAR2(30);
       lp_quote_id NUMBER;
       lp_asset_id NUMBER;
       lp_asset_cost INTEGER:=0;
       lp_cost_adj_total INTEGER:=0;
       lp_qq_lines_cost INTEGER:=0;
       lp_lq_lines_cost INTEGER:=0;
       lp_rec_flag VARCHAR2(1);
       i  INTEGER;
       l_flag  boolean:= FALSE;
       -----------------------------------------------------------------------
       l_program_name      CONSTANT VARCHAR2(30) := 'val_pri';
       l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
       l_validation_mode   VARCHAR2(3):='LOV';
       x_okl_lrs_table     OKL_EC_UPTAKE_PVT.okl_lease_rate_set_tbl_type;
       l_debug_enabled                varchar2(10);
       is_debug_procedure_on          boolean;
       is_debug_statement_on          boolean;
       cursor c_lq_asset_lines_rec(p_lease_quote_id NUMBER) IS
         --select SUM(NVL(OEC_PERCENTAGE,0))
         select oec_percentage
         from OKL_LEASE_QUOTES_B OLQ,OKL_ASSETS_B OAB
         WHERE OLQ.PRICING_METHOD= 'SF'
         AND OAB.parent_object_code='LEASEQUOTE'
         AND OAB.parent_object_id = OLQ.id
         AND OLQ.id= p_lease_quote_id;
       --Fix Bug # 4898499 Start
       cursor c_lq_asset_comp_rec(p_lease_quote_id NUMBER) IS
         select oac.unit_cost
         from okl_assets_b oab,
              okl_asset_components_b oac
         where oab.parent_object_code='LEASEQUOTE'
         AND   oab.id=oac.asset_id
         AND   oac.primary_component='YES'
         AND   oab.parent_object_id=p_lease_quote_id;
       --Fix Bug # 4898499 End
       cursor c_qq_asset_lines_rec(p_quick_quote_id NUMBER,p_pricing_method VARCHAR2,p_type VARCHAR2) IS
         select t2.* from OKL_QUICK_QUOTES_B t1,OKL_QUICK_QUOTE_LINES_B t2
         WHERE t1.PRICING_METHOD=p_pricing_method
         AND t2.type=p_type
         AND t1.id=p_quick_quote_id
         AND t2.quick_quote_id=t1.id;

    -----------------------------------------------------------------------
       BEGIN
       l_debug_enabled := okl_debug_pub.check_log_enabled;
       is_debug_procedure_on := okl_debug_pub.check_log_on(l_api_name
        				   ,fnd_log.level_procedure);


       IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
            okl_debug_pub.log_debug(fnd_log.level_procedure
            			,l_api_name
            			,'begin debug OKLRQQCB.pls call validating_pricing_values');
       END IF;  -- check for logging on STATEMENT level
       is_debug_statement_on := okl_debug_pub.check_log_on(l_api_name
          						  ,fnd_log.level_statement);

       -- call START_ACTIVITY to create savepoint, check compatibility
       -- and initialize message list
       x_return_status := okl_api.start_activity(p_api_name=>l_api_name
                               				   ,p_pkg_name=>G_PKG_NAME
           					                   ,p_init_msg_list=>p_init_msg_list
           					                   ,p_api_version=>p_api_version
           					                   ,l_api_version=>p_api_version
           					                   ,p_api_type=>G_API_TYPE
           					                   ,x_return_status=>x_return_status);  -- check if activity started successfully

        IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
             RAISE okl_api.g_exception_unexpected_error;
        ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
             RAISE okl_api.g_exception_error;
        END IF;

        lp_quote_id:=p_object_id;
        lp_object_type:= p_object_type;
        IF(lp_quote_id IS NOT NULL) THEN
          IF(p_object_type='LEASEQUOTE') THEN
            --All the OEC % must be entered  of Total Assets Cost
            --should be 100% for Lease Quote having pricing method 'SF'

             FOR lp_lq_asset_lines_rec IN c_lq_asset_lines_rec(lp_quote_id) LOOP
                 --l_flag := TRUE;
                 if(lp_lq_asset_lines_rec.oec_percentage IS NULL) THEN
                    l_flag := false;
                    i:=x_qa_result_tbl.COUNT;
                    i:=i+1;
                    x_qa_result_tbl(i).check_code:='validate_pricing_values';
                    x_qa_result_tbl(i).check_meaning:='TOTAL_COST_PER_NOT_MATCH ';
                    x_qa_result_tbl(i).result_code:='ERROR';
                    x_qa_result_tbl(i).result_meaning:='ERROR';
                    x_qa_result_tbl(i).message_code:= 'OKL_QA_TC_PER_INVALID';
                    x_qa_result_tbl(i).message_text:= get_msg_text('OKL_QA_TC_PER_INVALID');
                    x_qa_result := okl_api.G_RET_STS_ERROR;
                    EXIT;
                 ELSE
                    l_flag := TRUE;
                    lp_lq_lines_cost := lp_lq_lines_cost + NVL(lp_lq_asset_lines_rec.OEC_PERCENTAGE,0);
                 END IF;
             END LOOP;
             IF(l_flag AND lp_lq_lines_cost <> 100) THEN
                 i:=x_qa_result_tbl.COUNT;
                 i:=i+1;
                 x_qa_result_tbl(i).check_code:='validate_pricing_values';
                 x_qa_result_tbl(i).check_meaning:='TOTAL_COST_PER_NOT_MATCH ';
                 x_qa_result_tbl(i).result_code:='ERROR';
                 x_qa_result_tbl(i).result_meaning:='ERROR';
                 x_qa_result_tbl(i).message_code:= 'OKL_QA_TC_PER_INVALID';
                 x_qa_result_tbl(i).message_text:= get_msg_text('OKL_QA_TC_PER_INVALID');
                 x_qa_result := okl_api.G_RET_STS_ERROR;
             END IF;
             --Fix Bug # 4898499 Start
             ---Check when Pricing Method is not SF
             --Then  Assets Should Have the Unit Cost Defined on it
         OPEN c_lq_header_rec(lp_quote_id);
	     FETCH c_lq_header_rec INTO lp_lq_header_rec;
	     CLOSE c_lq_header_rec;
	     IF(lp_lq_header_rec.pricing_method <> 'SF') THEN
	        FOR lp_lq_asset_comp_rec IN c_lq_asset_comp_rec(lp_quote_id) LOOP
	            IF(lp_lq_asset_comp_rec.unit_cost IS NULL) THEN
	               l_flag := TRUE;
	               EXIT;
	            END IF;
	        END LOOP;
	        IF(l_flag) THEN
	          i:=x_qa_result_tbl.COUNT;
                  i:=i+1;
                  x_qa_result_tbl(i).check_code:='validate_pricing_values';
                  x_qa_result_tbl(i).check_meaning:='NO_UNIT_COST_DEFINED_FOR_ASSETS ';
                  x_qa_result_tbl(i).result_code:='ERROR';
                  x_qa_result_tbl(i).result_meaning:='ERROR';
                  x_qa_result_tbl(i).message_code:= 'OKL_QA_ASS_UC_REQ';
                  x_qa_result_tbl(i).message_text:= get_msg_text('OKL_QA_ASS_UC_REQ');
                  x_qa_result := okl_api.G_RET_STS_ERROR;
	        END IF;
	     END IF;
             --Fix Bug # 4898499 End
          END IF;--LQ End
          IF(p_object_type='QUICKQUOTE') THEN
              FOR l_qq_header_rec IN c_qq_header_rec(lp_quote_id) LOOP

             IF((l_qq_header_rec.pricing_method='TR')
                 AND (l_qq_header_rec.target_rate_type IS NULL OR l_qq_header_rec.target_rate IS NULL)) THEN
                  i:=x_qa_result_tbl.COUNT;
                  i:=i+1;
                  x_qa_result_tbl(i).check_code:='validate_pricing_values';
                  x_qa_result_tbl(i).check_meaning:='TARGET_TYPE_AND_VALUE_NOT_SPECIFIED_FOR_QUOTE';
                  x_qa_result_tbl(i).result_code:='ERROR';
                  x_qa_result_tbl(i).result_meaning:='ERROR';
                  x_qa_result_tbl(i).message_code:= 'OKL_QA_TARGET_TYPE_VALUE_REQ';
                  x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_TARGET_TYPE_VALUE_REQ');
                   x_qa_result := okl_api.g_ret_sts_error;
             END IF;
            END LOOP;
            FOR lp_qq_asset_lines_rec IN c_qq_asset_lines_rec(lp_quote_id,'RC','SUBSIDY') LOOP
                IF((lp_qq_asset_lines_rec.basis IS NOT NULL) AND (lp_qq_asset_lines_rec.basis <> 'FIXED' AND lp_qq_asset_lines_rec.basis <> 'ASSET_COST')) THEN
                    i:=x_qa_result_tbl.COUNT;
                    i:=i+1;
                    x_qa_result_tbl(i).check_code:='validate_pricing_values';
                    x_qa_result_tbl(i).check_meaning:='SUBSIDY BASIS NOT VALID';
                    x_qa_result_tbl(i).result_code:='ERROR';
                    x_qa_result_tbl(i).result_meaning:='ERROR';
                    x_qa_result_tbl(i).message_code:= 'OKL_QA_SUBSIDY_BASIS_NOT_VALID';
                    x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SUBSIDY_BASIS_NOT_VALID');
                    x_qa_result := okl_api.g_ret_sts_error;
                    EXIT;
                  END IF;
            END LOOP;
            FOR lp_qq_asset_lines_rec IN c_qq_asset_lines_rec(lp_quote_id,'SF','ITEM_CATEGORY') LOOP
                l_flag := TRUE;
                lp_qq_lines_cost := lp_qq_lines_cost + NVL(lp_qq_asset_lines_rec.PERCENTAGE_OF_TOTAL_COST,0);
            END LOOP;
            IF(l_flag AND lp_qq_lines_cost <> 100) THEN
               i:=x_qa_result_tbl.COUNT;
               i:=i+1;
               x_qa_result_tbl(i).check_code:='validate_pricing_values';
               x_qa_result_tbl(i).check_meaning:='TOTAL_COST_PER_NOT_MATCH ';
               x_qa_result_tbl(i).result_code:='ERROR';
               x_qa_result_tbl(i).result_meaning:='ERROR';
               x_qa_result_tbl(i).message_code:= 'OKL_QA_TC_PER_INVALID';
               x_qa_result_tbl(i).message_text:= get_msg_text('OKL_QA_TC_PER_INVALID');
               x_qa_result := okl_api.G_RET_STS_ERROR;
            END IF;

          END IF;--End OF QQ
        END IF;-----Quote ID Is not null

        okl_api.end_activity(x_msg_count => x_msg_count
            		    ,x_msg_data  => x_msg_data);

        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
                okl_debug_pub.log_debug(fnd_log.level_procedure
    			                       ,l_api_name
    			                       ,'end debug okl_sales_quote_qa_pvt call validating_pricing_values');
        END IF;
        EXCEPTION
         WHEN OTHERS THEN
          x_return_status := okl_api.G_RET_STS_ERROR;
          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => G_DB_ERROR,
                               p_token1       => G_PROG_NAME_TOKEN,
                               p_token1_value => 'OKLRQQCB.pls.val_pric_val',
                               p_token2       => G_SQLCODE_TOKEN,
                               p_token2_value => sqlcode,
                               p_token3       => G_SQLERRM_TOKEN,
                               p_token3_value => sqlerrm);
    END validate_pricing_values;
/*------------------------------------------------------------------------------
    -- PROCEDURE  populate_qq_rec_values
  ------------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name   : populate_qq_rec_values
    -- Description     :  Populate the Header Rec for Quick Quote
    --
    -- Business Rules  :Populate Header for Quick Quote for a Given Quick Quote id
    --
    -- Parameters      : p_object_id   -- Quick Quote id

                        lp_qq_header_rec - Header Rec structure for Quick Quote

                        x_okl_ec_rec --> Hold all the Eligibility criteria values
                        for a given Quick Quote

    -- Version         :
    -- History         :
    -- End of comments
------------------------------------------------------------------------------*/
   procedure populate_qq_rec_values(p_quick_quote_id NUMBER,
                                    lp_qq_header_rec OUT NOCOPY c_qq_header_rec%ROWTYPE,
                                    x_okl_ec_rec  IN OUT NOCOPY okl_ec_evaluate_pvt.okl_ec_rec_type) IS

       l_validation_mode   VARCHAR2(3):='LOV';
       l_item_cat_id       NUMBER;
       i                   INTEGER;
       lp_line_amt         NUMBER;

       cursor c_qq_assets_cost(p_quick_quote_id NUMBER) IS
        select ITEM_CATEGORY_ID
        FROM OKL_QUICK_QUOTE_LINES_B
   	    WHERE type='ITEM_CATEGORY'
   	    AND   quick_quote_id=p_quick_quote_id;

   	   cursor c_payment_lines_types(p_quick_quote_id NUMBER,p_payment_type VARCHAR2) IS
        select t2.value
   	    from  OKL_QUICK_QUOTE_LINES_B t2
        WHERE t2.type = p_payment_type
        and t2.QUICK_QUOTE_ID = p_quick_quote_id;

       BEGIN
         i := 1;
         OPEN c_qq_header_rec(p_quick_quote_id);
         FETCH c_qq_header_rec INTO lp_qq_header_rec;
         CLOSE c_qq_header_rec;
         OPEN c_qq_assets_cost(p_quick_quote_id);
         FETCH c_qq_assets_cost INTO l_item_cat_id;
         WHILE c_qq_assets_cost%FOUND LOOP

           x_okl_ec_rec.item_categories_table(i):= l_item_cat_id;
           i := i+1;
           FETCH c_qq_assets_cost INTO l_item_cat_id;
         END LOOP;
         CLOSE c_qq_assets_cost;
       /*
       Check Source Type and value range
       */
       x_okl_ec_rec.target_id := p_quick_quote_id;
       x_okl_ec_rec.target_eff_from := lp_qq_header_rec.expected_start_date;
       x_okl_ec_rec.term := lp_qq_header_rec.term;
       x_okl_ec_rec.territory :=  lp_qq_header_rec.sales_territory_id;

       OPEN c_payment_lines_types(p_quick_quote_id,'DOWN_PAYMENT');
       FETCH c_payment_lines_types INTO lp_line_amt;
       CLOSE c_payment_lines_types;
       x_okl_ec_rec.down_payment := lp_line_amt;

       OPEN c_payment_lines_types(p_quick_quote_id,'TRADEIN');
       FETCH c_payment_lines_types INTO lp_line_amt;
       CLOSE c_payment_lines_types;
       x_okl_ec_rec.trade_in_value :=lp_line_amt;
       x_okl_ec_rec.validation_mode := l_validation_mode;
       EXCEPTION
        WHEN OTHERS THEN

         OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                   p_msg_name     => G_DB_ERROR,
                                   p_token1       => G_PROG_NAME_TOKEN,
                                   p_token1_value => 'VALIDATION_SET_QA',
                                   p_token2       => G_SQLCODE_TOKEN,
                                   p_token2_value => sqlcode,
                                   p_token3       => G_SQLERRM_TOKEN,
                                   p_token3_value => sqlerrm);

   END populate_qq_rec_values;
/*------------------------------------------------------------------------------
    -- PROCEDURE  validate_ec_criteria
  ------------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name   : validate_ec_criteria
    -- Description     : Procedure will Validate the EC Criteria for SRT/LRS/Product
                         VPA
    --
    -- Business Rules  : Inputs for EC criteria will be taken from Quote Attributes
    --
    -- Parameters      : p_object_id   -- Lease Quote /Quick Quote Id.

                        p_object_type -- valid values are  'LEASEQUOTE'/'QUICK QUOTE'
                        hold which type of object this method is calling

                         x_qa_result_tbl --> Hold all the QA Results for Object

    -- Version         :
    -- History         :
    -- End of comments
------------------------------------------------------------------------------*/
   PROCEDURE validate_ec_criteria(p_api_version      IN NUMBER
                                 ,p_init_msg_list    IN VARCHAR2
                                 ,p_object_type      IN VARCHAR2
                                 ,p_object_id        IN NUMBER
                                 ,x_return_status    OUT NOCOPY VARCHAR2
                                 ,x_msg_count        OUT NOCOPY NUMBER
                                 ,x_msg_data         OUT NOCOPY VARCHAR2
                                 ,x_qa_result_tbl    IN OUT NOCOPY OKL_SALES_QUOTE_QA_PVT.qa_results_tbl_type
                                 ,x_qa_result       IN  OUT NOCOPY VARCHAR2) IS
       lp_object_type VARCHAR2(30);
       lp_quote_id NUMBER;
       lp_asset_id NUMBER;
       lp_asset_cost INTEGER:=0;
       lp_cost_adj_total INTEGER:=0;
       lp_rec_flag VARCHAR2(1);
       i  INTEGER;
       l_api_name          CONSTANT VARCHAR2(61) := 'v_ec_crt';
       l_module            CONSTANT fnd_log_messages.module%TYPE := 'v_ec_crt';
       l_debug_enabled                varchar2(10);
       is_debug_procedure_on          boolean;
       is_debug_statement_on          boolean;
       l_validation_mode   VARCHAR2(3):='LOV';

       l_okl_ec_rec_type   okl_ec_evaluate_pvt.okl_ec_rec_type;
       x_okl_ec_rec        okl_ec_evaluate_pvt.okl_ec_rec_type;
       l_item_cat_id       NUMBER;
       lp_vp_id            NUMBER;
       l_check_ec_flag     boolean:=FALSE;
       x_eligible          boolean;
       l_obj_name          okl_fe_std_rt_tmp_v.template_name%TYPE;
       l_message_name      VARCHAR2(30);
       cursor c_qq_header_rec(p_quote_id NUMBER) IS
              SELECT t1.* FROM OKL_QUICK_QUOTES_B t1
              WHERE t1.id = p_quote_id;
       lp_qq_header_rec  c_qq_header_rec%ROWTYPE;

       cursor c_qq_assets_cost(p_quick_quote_id NUMBER) IS
       select ITEM_CATEGORY_ID
       FROM OKL_QUICK_QUOTE_LINES_B
   	   WHERE type='ITEM_CATEGORY'
   	   AND   quick_quote_id=p_quick_quote_id;

       --Bug # 5050143 ssdeshpa start
       cursor c_config_fee_rec(p_quote_id NUMBER) IS
       select ofv.id,
              ofv.rate_card_id,
	          ofv.rate_template_id,
	          'QUOTED_FEES' oty_code
       from okl_fees_b ofv
       where ofv.parent_object_code='LEASEQUOTE'
       AND ofv.parent_object_id=p_quote_id
       AND ofv.fee_type IN ('FINANCED','ROLLOVER')
	   UNION
       select oab.id,
               oab.rate_card_id,
               oab.rate_template_id,
               'QUOTED_ASSET' oty_code
       from okl_assets_b oab
       where oab.parent_object_code='LEASEQUOTE'
       AND oab.parent_object_id=p_quote_id;

       --Cursor to fetch LRS Name
       CURSOR c_lrs_rec(p_srt_ver_id NUMBER) IS
          select lrs.name
          from okl_ls_rt_fctr_sets_v lrs,okl_fe_rate_set_versions_v lrv
          where lrs.id=lrv.rate_set_id
          and lrv.rate_set_version_id = p_srt_ver_id;
       --Cursor to Fetch SRT Name
       CURSOR c_srt_rec(p_srt_ver_id NUMBER) IS
          select srt.template_name as name
          from
                 okl_fe_std_rt_tmp_v srt,
                 okl_fe_std_rt_tmp_vers srv
          where  srt.std_rate_tmpl_id=srv.std_rate_tmpl_id
          AND srv.std_rate_tmpl_ver_id = p_srt_ver_id;
       --Bug # 5050143 ssdeshpa end
       BEGIN
       l_debug_enabled := okl_debug_pub.check_log_enabled;
     is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
        				   ,fnd_log.level_procedure);


     IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
         okl_debug_pub.log_debug(fnd_log.level_procedure
        			,l_module
        			,'begin debug OKLRQQCB.pls call validate_ec_criteria');
     END IF;  -- check for logging on STATEMENT level
     is_debug_statement_on := okl_debug_pub.check_log_on(l_module
        						  ,fnd_log.level_statement);

     -- call START_ACTIVITY to create savepoint, check compatibility
     -- and initialize message list
     x_return_status := okl_api.start_activity(p_api_name=>l_api_name
                            				   ,p_pkg_name=>G_PKG_NAME
         					                   ,p_init_msg_list=>p_init_msg_list
        					                   ,p_api_version=>p_api_version
        					                   ,l_api_version=>p_api_version
        					                   ,p_api_type=>G_API_TYPE
        					                   ,x_return_status=>x_return_status);  -- check if activity started successfully

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;

       lp_object_type:= p_object_type;
       lp_quote_id:=p_object_id;
       IF(lp_quote_id IS NOT NULL) THEN
         IF(p_object_type='LEASEQUOTE') THEN

           lp_vp_id := OKL_EC_UPTAKE_PVT.get_vp_id(lp_quote_id);
           --Bug # 5050143 ssdeshpa start
           populate_lq_rec_values(lp_quote_id,x_okl_ec_rec);

           OPEN c_lq_header_rec(lp_quote_id);
           FETCH c_lq_header_rec INTO lp_lq_header_rec;
           CLOSE c_lq_header_rec;
           --Bug # 5050143 ssdeshpa end
           IF(lp_lq_header_rec.RATE_CARD_ID IS NOT NULL) THEN
              x_okl_ec_rec.src_id := lp_lq_header_rec.RATE_CARD_ID;
              x_okl_ec_rec.src_type := 'LRS';
              l_check_ec_flag := TRUE;

           ELSIF (lp_lq_header_rec.RATE_TEMPLATE_ID IS NOT NULL) THEN
              x_okl_ec_rec.src_id := lp_lq_header_rec.RATE_TEMPLATE_ID;
              x_okl_ec_rec.src_type := 'SRT';
              l_check_ec_flag := TRUE;
           END IF;

           IF(l_check_ec_flag) THEN
              OKL_ECC_PUB.evaluate_eligibility_criteria(p_api_version
                                                       ,p_init_msg_list
                                                       ,x_return_status
                                                       ,x_msg_count
                                                       ,x_msg_data
                                                       ,x_okl_ec_rec
                                                       ,x_eligible);
           IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
              RAISE okl_api.g_exception_unexpected_error;
           ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
              RAISE okl_api.g_exception_error;
           END IF;
              IF( NOT x_eligible) THEN
              --Set Message According to the Source Type
                  i:=x_qa_result_tbl.COUNT;
                  i:=i+1;
                  x_qa_result_tbl(i).check_code:='validate_lrs_ec';
                  x_qa_result_tbl(i).check_meaning:='LRS/SRT_IS_NOT_VALID_FOR_EC';
                  x_qa_result_tbl(i).result_code:='ERROR';
                  x_qa_result_tbl(i).result_meaning:='ERROR';
                  IF( x_okl_ec_rec.src_type = 'SRT') THEN
                       OPEN  c_srt_rec(lp_lq_header_rec.RATE_TEMPLATE_ID);
                       FETCH c_srt_rec INTO l_obj_name;
                       CLOSE c_srt_rec;
                       l_message_name := 'OKL_QA_SRT_TMPL_NOT_VALID';
                  ELSIF( x_okl_ec_rec.src_type = 'LRS') THEN
                         OPEN  c_lrs_rec(lp_lq_header_rec.RATE_CARD_ID);
                         FETCH c_lrs_rec INTO l_obj_name;
                         CLOSE c_lrs_rec;
                         l_message_name := 'OKL_QA_LRS_TMPL_NOT_VALID';
                  END IF;
                  x_qa_result_tbl(i).message_code:= l_message_name;
                  set_fnd_message(p_msg_name  => l_message_name
                       ,p_token1    =>  'NAME'
                       ,p_value1    =>  l_obj_name
                       ,p_token2    =>  NULL
                       ,p_value2    =>  NULL
                       ,p_token3    =>  NULL
                       ,p_value3    =>  NULL
                       ,p_token4    =>  NULL
                       ,p_value4    =>  NULL);
                  x_qa_result_tbl(i).message_text:= fnd_message.get;
                  x_qa_result := okl_api.G_RET_STS_ERROR;
              END IF;
           END IF;
           --Bug # 5050143 ssdeshpa start
           --Check EC Criteria for Assets and Config Fees
           FOR l_config_fee_rec IN c_config_fee_rec(lp_quote_id) LOOP
               l_check_ec_flag := FALSE;

               IF(l_config_fee_rec.RATE_CARD_ID IS NOT NULL) THEN
                  x_okl_ec_rec.src_id := l_config_fee_rec.RATE_CARD_ID;
                  x_okl_ec_rec.src_type := 'LRS';
                  l_check_ec_flag := TRUE;

               ELSIF (l_config_fee_rec.RATE_TEMPLATE_ID IS NOT NULL) THEN
                  x_okl_ec_rec.src_id := l_config_fee_rec.RATE_TEMPLATE_ID;
                  x_okl_ec_rec.src_type := 'SRT';
                  l_check_ec_flag := TRUE;
               END IF;

               IF(l_check_ec_flag) THEN
                  OKL_ECC_PUB.evaluate_eligibility_criteria(p_api_version
                                                           ,p_init_msg_list
                                                           ,x_return_status
                                                           ,x_msg_count
                                                           ,x_msg_data
                                                           ,x_okl_ec_rec
                                                           ,x_eligible);
                  IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
                      RAISE okl_api.g_exception_unexpected_error;
                  ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
                      RAISE okl_api.g_exception_error;
                  END IF;
                  IF( NOT x_eligible) THEN
                  --Set Message According to the Source Type
                    i:=x_qa_result_tbl.COUNT;
                    i:=i+1;
                    x_qa_result_tbl(i).check_code:='validate_lrs_ec';
                    x_qa_result_tbl(i).check_meaning:='LRS/SRT_IS_NOT_VALID_FOR_EC';
                    x_qa_result_tbl(i).result_code:='ERROR';
                    x_qa_result_tbl(i).result_meaning:='ERROR';
                    IF( x_okl_ec_rec.src_type = 'SRT') THEN
                       OPEN  c_srt_rec(l_config_fee_rec.RATE_TEMPLATE_ID);
                       FETCH c_srt_rec INTO l_obj_name;
                       CLOSE c_srt_rec;
                       l_message_name := 'OKL_QA_SRT_TMPL_NOT_VALID';
                    ELSIF( x_okl_ec_rec.src_type = 'LRS') THEN
                         OPEN  c_lrs_rec(l_config_fee_rec.RATE_CARD_ID);
                         FETCH c_lrs_rec INTO l_obj_name;
                         CLOSE c_lrs_rec;
                         l_message_name := 'OKL_QA_LRS_TMPL_NOT_VALID';
                    END IF;
                    x_qa_result_tbl(i).message_code:= l_message_name;
                    set_fnd_message(p_msg_name  => l_message_name
                       ,p_token1    =>  'NAME'
                       ,p_value1    =>  l_obj_name
                       ,p_token2    =>  NULL
                       ,p_value2    =>  NULL
                       ,p_token3    =>  NULL
                       ,p_value3    =>  NULL
                       ,p_token4    =>  NULL
                       ,p_value4    =>  NULL);
                    x_qa_result_tbl(i).message_text:= fnd_message.get;
                    x_qa_result := okl_api.G_RET_STS_ERROR;
                    EXIT;
                  END IF;
               END IF;
           END LOOP;
           --Bug # 5050143 ssdeshpa end;
           IF(lp_vp_id IS NOT NULL) THEN
              x_okl_ec_rec.src_id := lp_vp_id;
              x_okl_ec_rec.src_type := 'VENDOR_PROGRAM';
              OKL_ECC_PUB.evaluate_eligibility_criteria(p_api_version
                                                       ,p_init_msg_list
                                                       ,x_return_status
                                                       ,x_msg_count
                                                       ,x_msg_data
                                                       ,x_okl_ec_rec
                                                       ,x_eligible);
           IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
              RAISE okl_api.g_exception_unexpected_error;
           ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
              RAISE okl_api.g_exception_error;
           END IF;
           IF( NOT x_eligible) THEN
              --Set Message According to the Source Type
                  i:=x_qa_result_tbl.COUNT;
                  i:=i+1;
                  x_qa_result_tbl(i).check_code:='validate_lrs_ec';
                  x_qa_result_tbl(i).check_meaning:='VPA_IS_NOT_VALID_FOR_EC';
                  x_qa_result_tbl(i).result_code:='ERROR';
                  x_qa_result_tbl(i).result_meaning:='ERROR';
                  x_qa_result_tbl(i).message_code:= 'OKL_QA_VPA_NOT_VALID';
                  x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_VPA_NOT_VALID');
                  x_qa_result := okl_api.G_RET_STS_ERROR;
              END IF;
           END IF;

           IF(lp_lq_header_rec.PRODUCT_ID IS NOT NULL) THEN
              x_okl_ec_rec.src_id := lp_lq_header_rec.PRODUCT_ID;
              x_okl_ec_rec.src_type := 'PRODUCT';
              OKL_ECC_PUB.evaluate_eligibility_criteria(p_api_version
                                                       ,p_init_msg_list
                                                       ,x_return_status
                                                       ,x_msg_count
                                                       ,x_msg_data
                                                       ,x_okl_ec_rec
                                                       ,x_eligible);
              IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
                 RAISE okl_api.g_exception_unexpected_error;
              ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
                RAISE okl_api.g_exception_error;
              END IF;
              IF( NOT x_eligible) THEN
              --Set Message According to the Source Type
                  i:=x_qa_result_tbl.COUNT;
                  i:=i+1;
                  x_qa_result_tbl(i).check_code:='validate_lrs_ec';
                  x_qa_result_tbl(i).check_meaning:='PRODUCT_IS_INVALID_FOR_EC';
                  x_qa_result_tbl(i).result_code:='ERROR';
                  x_qa_result_tbl(i).result_meaning:='ERROR';
                  x_qa_result_tbl(i).message_code:= 'OKL_QA_PRODUCT_NOT_VALID';
                  x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_PRODUCT_NOT_VALID');
                  x_qa_result := okl_api.G_RET_STS_ERROR;
              END IF;
           END IF;

          END IF;--End OF LQ
          IF(p_object_type='QUICKQUOTE') THEN

              populate_qq_rec_values(lp_quote_id,
                                     lp_qq_header_rec,
                                     x_okl_ec_rec);


               IF(lp_qq_header_rec.RATE_CARD_ID IS NOT NULL) THEN
                  x_okl_ec_rec.src_id := lp_qq_header_rec.RATE_CARD_ID;
                  x_okl_ec_rec.src_type := 'LRS';
                  l_check_ec_flag := TRUE;
               ELSIF (lp_qq_header_rec.RATE_TEMPLATE_ID IS NOT NULL) THEN
                  x_okl_ec_rec.src_id := lp_qq_header_rec.RATE_TEMPLATE_ID;
                  x_okl_ec_rec.src_type := 'SRT';
                  l_check_ec_flag := TRUE;
               END IF;
               IF(l_check_ec_flag) THEN
                  OKL_ECC_PUB.evaluate_eligibility_criteria(p_api_version
                                                           ,p_init_msg_list
                                                           ,x_return_status
                                                           ,x_msg_count
                                                           ,x_msg_data
                                                           ,x_okl_ec_rec
                                                           ,x_eligible);
                  IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
                      RAISE okl_api.g_exception_unexpected_error;
                  ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
                      RAISE okl_api.g_exception_error;
                  END IF;
                  IF( NOT x_eligible) THEN
                  --Set Message According to the Source Type
                      i:=x_qa_result_tbl.COUNT;
                      i:=i+1;
                      x_qa_result_tbl(i).check_code:='validate_lrs_ec';
                      x_qa_result_tbl(i).check_meaning:='LRS_IS_NOT_VALID_FOR_EC';
                      x_qa_result_tbl(i).result_code:='ERROR';
                      x_qa_result_tbl(i).result_meaning:='ERROR';
                      x_qa_result_tbl(i).message_code:= 'OKL_QA_TMPL_IS_NOT_VALID';
                      x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_TMPL_IS_NOT_VALID');
                      x_qa_result := okl_api.G_RET_STS_ERROR;
                  END IF;
               END IF;
               IF(lp_qq_header_rec.PROGRAM_AGREEMENT_ID IS NOT NULL) THEN
                  x_okl_ec_rec.src_id := lp_qq_header_rec.PROGRAM_AGREEMENT_ID;
                  x_okl_ec_rec.src_type := 'VENDOR_PROGRAM';
                  OKL_ECC_PUB.evaluate_eligibility_criteria(p_api_version
                                                           ,p_init_msg_list
                                                           ,x_return_status
                                                           ,x_msg_count
                                                           ,x_msg_data
                                                           ,x_okl_ec_rec
                                                           ,x_eligible);
                  IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
                      RAISE okl_api.g_exception_unexpected_error;
                  ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
                      RAISE okl_api.g_exception_error;
                  END IF;
                  IF(NOT x_eligible) THEN
                  --Set Message According to the Source Type
                      i:=x_qa_result_tbl.COUNT;
                      i:=i+1;
                      x_qa_result_tbl(i).check_code:='validate_lrs_ec';
                      x_qa_result_tbl(i).check_meaning:='VPA_IS_NOT_VALID_FOR_EC';
                      x_qa_result_tbl(i).result_code:='ERROR';
                      x_qa_result_tbl(i).result_meaning:='ERROR';
                      x_qa_result_tbl(i).message_code:= 'OKL_QA_VPA_NOT_VALID';
                      x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_VPA_NOT_VALID');
                      x_qa_result := okl_api.G_RET_STS_ERROR;
                  END IF;
               END IF;

              END IF;--End OF QQ
           END IF;--quote_id is not null
           okl_api.end_activity(x_msg_count => x_msg_count
                		    ,x_msg_data  => x_msg_data);

           IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
            okl_debug_pub.log_debug(fnd_log.level_procedure
        			    ,l_module
        			    ,'end debug okl_sales_quote_qa_pvt call validate_ec_criteria');
           END IF;
           EXCEPTION
            WHEN okl_api.g_exception_error THEN
            x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
                                                           ,p_pkg_name  =>G_PKG_NAME
                                                           ,p_exc_name  =>'OKL_API.G_RET_STS_ERROR'
                                                           ,x_msg_count =>x_msg_count
                                                           ,x_msg_data  =>x_msg_data
                                                           ,p_api_type  =>G_API_TYPE);

             WHEN okl_api.g_exception_unexpected_error THEN

               x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
                                                           ,p_pkg_name  =>G_PKG_NAME
                                                           ,p_exc_name  =>'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                           ,x_msg_count =>x_msg_count
                                                           ,x_msg_data  =>x_msg_data
                                                           ,p_api_type  =>G_API_TYPE);



         END validate_ec_criteria;
/*------------------------------------------------------------------------------
    -- PROCEDURE  validate_financial_product
  ------------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name   : validate_financial_product
    -- Description     : Validation Related to Product selected on a Quote
    --
    -- Business Rules  :
    --
    -- Parameters      : p_object_id   -- Lease Quote /Quick Quote Id.

                        p_object_type -- valid values are  'LEASEQUOTE'/'QUICKQUOTE'
                        hold which type of object this method is calling

                         x_qa_result_tbl --> Hold all the QA Results for Object

    -- Version         :
    -- History         :
    -- End of comments
------------------------------------------------------------------------------*/
   PROCEDURE validate_financial_product(p_api_version      IN NUMBER
                                        ,p_init_msg_list    IN VARCHAR2
                                        ,p_object_type      IN VARCHAR2
                                        ,p_object_id        IN NUMBER
                                        ,x_return_status    OUT NOCOPY VARCHAR2
                                        ,x_msg_count        OUT NOCOPY NUMBER
                                        ,x_msg_data         OUT NOCOPY VARCHAR2
                                        ,x_qa_result_tbl    IN OUT NOCOPY OKL_SALES_QUOTE_QA_PVT.qa_results_tbl_type
                                        ,x_qa_result       IN  OUT NOCOPY VARCHAR2) IS

       lp_quote_id NUMBER;
       lp_asset_id NUMBER;
       lp_asset_cost INTEGER:=0;
       lp_cost_adj_total1 INTEGER:= 0;
       lp_cost_adj_total2 INTEGER:= 0;
       lp_cost_adj_total  INTEGER:= 0;
       lp_rec_flag VARCHAR2(1);
       i  INTEGER;

       cursor c_qq_header_rec(p_quick_quote_id NUMBER) IS
          SELECT t1.* FROM OKL_QUICK_QUOTES_B t1
          WHERE t1.id = p_quick_quote_id;
       lp_qq_header_rec c_qq_header_rec%ROWTYPE;

       cursor c_qq_assets_cost(p_quick_quote_id NUMBER) IS
          SELECT  SUM(NVL(VALUE,0))
          FROM OKL_QUICK_QUOTE_LINES_B
   	      WHERE type='ITEM_CATEGORY'
   	      AND   quick_quote_id=p_quick_quote_id;

   	   cursor c_qq_cost_adj_total_rec1(p_quick_quote_id NUMBER) IS
   	     select SUM(NVL(VALUE,0))
   	     from  OKL_QUICK_QUOTE_LINES_B t2
         WHERE t2.type IN('DOWN_PAYMENT','TRADEIN','SUBSIDY')
         and   t2.basis = 'FIXED'
         and t2.QUICK_QUOTE_ID=p_quick_quote_id;

       cursor c_qq_cost_adj_total_rec2(p_quick_quote_id NUMBER) IS
         select SUM(NVL(VALUE,0))
         from  OKL_QUICK_QUOTE_LINES_B t2
         WHERE t2.type IN('DOWN_PAYMENT','TRADEIN','SUBSIDY')
         and t2.basis = 'ASSET_COST'
         and t2.QUICK_QUOTE_ID=p_quick_quote_id;

       cursor c_lq_cost_adj_rec(p_asset_id NUMBER) IS
         SELECT SUM(NVL(VALUE,0)) FROM OKL_COST_ADJUSTMENTS_B
         where PARENT_OBJECT_CODE='ASSET'
         and ADJUSTMENT_SOURCE_TYPE IN('DOWN_PAYMENT','TRADEIN','SUBSIDY')
         AND  PARENT_OBJECT_ID=p_asset_id;

       cursor c_lq_asset_lines_rec(p_quote_id NUMBER) IS
         SELECT t2.id,t2.oec
         FROM OKL_ASSETS_B t2
         where t2.parent_object_code='LEASEQUOTE'
         and t2.parent_object_id=p_quote_id;

       BEGIN
       lp_quote_id := p_object_id;
       IF(lp_quote_id IS NOT NULL) THEN
          IF(p_object_type='LEASEQUOTE') THEN
             --Down Payment, Subsidy or Trade In Value cannot exceed
             --asset cost total (OEC)
             FOR lq_asset_lines_rec IN c_lq_asset_lines_rec(lp_quote_id) LOOP
               OPEN c_lq_cost_adj_rec(lq_asset_lines_rec.id);
               FETCH c_lq_cost_adj_rec INTO lp_cost_adj_total;

               IF(lq_asset_lines_rec.oec < lp_cost_adj_total) THEN
                  i:=x_qa_result_tbl.COUNT;
                  i:=i+1;
                  x_qa_result_tbl(i).check_code:='validate_fin_product';
                  x_qa_result_tbl(i).check_meaning:='CAPITAL_REDUCTION_GREATER_THAN_OEC';
                  x_qa_result_tbl(i).result_code:='ERROR';
                  x_qa_result_tbl(i).result_meaning:='ERROR';
                  x_qa_result_tbl(i).message_code:= 'OKL_QA_CPTR_GT_OEC';
                  x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_CPTR_GT_OEC');
                  x_qa_result := okl_api.G_RET_STS_ERROR;
                  EXIT;
               END IF;
               CLOSE c_lq_cost_adj_rec;
             END LOOP;
             IF (c_lq_asset_lines_rec%ISOPEN ) THEN
                 CLOSE c_lq_asset_lines_rec;
             END IF;
          END IF;--End Of LQ

          IF(p_object_type='QUICKQUOTE') THEN
           OPEN c_qq_header_rec(lp_quote_id);
           FETCH c_qq_header_rec INTO lp_qq_header_rec;
           CLOSE c_qq_header_rec;
           --Down Payment, Subsidy or Trade In Value cannot exceed
           --asset cost total (OEC)
           IF(lp_qq_header_rec.pricing_method <> 'SF') THEN

             OPEN c_qq_assets_cost(lp_quote_id);
             FETCH c_qq_assets_cost INTO lp_asset_cost;
             CLOSE c_qq_assets_cost;


             OPEN c_qq_cost_adj_total_rec1(lp_quote_id);
             FETCH c_qq_cost_adj_total_rec1 INTO lp_cost_adj_total1;
             CLOSE c_qq_cost_adj_total_rec1;

             OPEN c_qq_cost_adj_total_rec2(lp_quote_id);
             --Bug Fix 4731208  Start
             FETCH c_qq_cost_adj_total_rec2 INTO lp_cost_adj_total2;
             --Bug Fix 4731208  End
             CLOSE c_qq_cost_adj_total_rec2;

             lp_cost_adj_total := lp_cost_adj_total1 + ((lp_cost_adj_total2 * lp_asset_cost) / 100 );

             IF(lp_asset_cost < lp_cost_adj_total) THEN
                 i:=x_qa_result_tbl.COUNT;
                 i:=i+1;
                 x_qa_result_tbl(i).check_code:='validate_fin_product';
                 x_qa_result_tbl(i).check_meaning:='CAPITAL_REDUCTION_GREATER_THAN_OEC';
                 x_qa_result_tbl(i).result_code:='ERROR';
                 x_qa_result_tbl(i).result_meaning:='ERROR';
                 x_qa_result_tbl(i).message_code:= 'OKL_QA_CPTR_GT_OEC';
                 x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_CPTR_GT_OEC');
                 x_qa_result := okl_api.G_RET_STS_ERROR;
             END IF;
           END IF;--Pricing Method is Not SF
          END IF;--End OF QQ
       END IF;-- lp_quote_id is Not Null
       EXCEPTION
         WHEN OTHERS THEN
         OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                   p_msg_name     => G_DB_ERROR,
                                   p_token1       => G_PROG_NAME_TOKEN,
                                   p_token1_value => 'OKLRQQCB.pls.val_fin_prod',
                                   p_token2       => G_SQLCODE_TOKEN,
                                   p_token2_value => sqlcode,
                                   p_token3       => G_SQLERRM_TOKEN,
                                   p_token3_value => sqlerrm);
       END validate_financial_product;

/*------------------------------------------------------------------------------
    -- PROCEDURE extended_validations
---------------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name   : extended_validations
    -- Description     : Perform extended validation on Quote
    --
    -- Business Rules  : Perform extended validation on Quote
    --
    -- Parameters      : p_object_id   -- Lease Quote/Quick Quote Id

                        p_object_type -- valid values are  'LEASEQUOTE'/QUICKQUOTE'
                        hold which type of object this method is calling

                        x_qa_result_tbl --> Hold all the QA Results for Object

    -- Version         :
    -- History         :
    -- End of comments
------------------------------------------------------------------------------*/
   PROCEDURE extended_validations(p_api_version      IN NUMBER
                                  ,p_init_msg_list    IN VARCHAR2
                                  ,p_object_type      IN VARCHAR2
                                  ,p_object_id        IN NUMBER
                                  ,x_return_status    OUT NOCOPY VARCHAR2
                                  ,x_msg_count        OUT NOCOPY NUMBER
                                  ,x_msg_data         OUT NOCOPY VARCHAR2
                                  ,x_qa_result_tbl    IN OUT NOCOPY OKL_SALES_QUOTE_QA_PVT.qa_results_tbl_type
                                  ,x_qa_result       IN  OUT NOCOPY VARCHAR2) IS
      lp_quote_id NUMBER;
      lp_asset_id NUMBER;
      lp_rec_flag VARCHAR2(1);
      x           VARCHAR2(1);
      i  INTEGER;
      l_module            CONSTANT fnd_log_messages.module%TYPE := 'ext_val';
      l_debug_enabled                varchar2(10);
      is_debug_procedure_on          boolean;
      is_debug_statement_on          boolean;
      l_program_name      CONSTANT VARCHAR2(30) := 'ext_val';
      l_api_name          CONSTANT VARCHAR2(61) := l_program_name;

       CURSOR c_lq_asset_rec(p_quote_id NUMBER) IS
         SELECT * from okl_assets_b
         where PARENT_OBJECT_CODE='LEASEQUOTE'
         AND PARENT_OBJECT_ID=p_quote_id;

       CURSOR c_qq_lines_rec(p_quote_id NUMBER) IS
         select t2.*
   	     from  OKL_QUICK_QUOTE_LINES_b t2
         WHERE t2.quick_quote_id=p_quote_id
         AND t2.type='ITEM_CATEGORY';
        --Define Local Rec variables
       lp_qq_header_rec c_qq_header_rec%ROWTYPE;
       lp_lq_asset_rec c_lq_asset_rec%ROWTYPE;
       lp_qq_lines_rec c_qq_lines_rec%ROWTYPE;

        --Bug 4713705 SSDESHPA--->Fix Start
        --Checking Valid Stream generation Template for Eot Selected
        --on a Quote
        CURSOR c_qq_valid_sgt_eot(p_eotv_id    IN NUMBER,
                                  p_start_date IN DATE) IS
             SELECT 'x'
             FROM OKL_PRODUCTS PDT,
                  OKL_AE_TMPT_SETS AES,
                  OKL_ST_GEN_TMPT_SETS GTS,
                  OKL_ST_GEN_TEMPLATES GTT,
                  OKL_FE_EO_TERMS_V ETO,
                  OKL_FE_EO_TERM_VERS ETV
             WHERE ETV.END_OF_TERM_VER_ID=p_eotv_id
             AND ETV.END_OF_TERM_ID = ETO.END_OF_TERM_ID
             AND PDT.ID = ETO.PRODUCT_ID
             AND PDT.AES_ID = AES.ID
             AND AES.GTS_ID = GTS.ID
             AND GTT.GTS_ID = GTS.ID
             AND GTT.START_DATE <= P_START_DATE
             AND NVL(GTT.END_DATE, P_START_DATE) >= P_START_DATE
             AND PDT.PRODUCT_STATUS_CODE = 'APPROVED'
             AND GTT.TMPT_STATUS = 'ACTIVE';
             --Check for valid Stream Generation Template for product for quote
             CURSOR c_lq_valid_sgt_prod(pdt_id    IN NUMBER,
                                     p_start_date IN DATE) IS
             SELECT 'x'
             FROM OKL_PRODUCTS PDT,
                  OKL_AE_TMPT_SETS AES,
                  OKL_ST_GEN_TMPT_SETS GTS,
                  OKL_ST_GEN_TEMPLATES GTT
             WHERE PDT.ID = pdt_id
             AND PDT.AES_ID = AES.ID
             AND AES.GTS_ID = GTS.ID
             AND GTT.GTS_ID = GTS.ID
             AND GTT.START_DATE <= p_start_date
             AND nvl(GTT.END_DATE, p_start_date) >= p_start_date
             AND PDT.PRODUCT_STATUS_CODE = 'APPROVED'
             AND GTT.TMPT_STATUS = 'ACTIVE';
     --Bug 4713705 SSDESHPA---->Fix End
     --Added Bug # 5647107 ssdeshpa start
     CURSOR  l_systemparams_csr IS
      SELECT NVL(tax_upfront_yn,'N')
      FROM   OKL_SYSTEM_PARAMS;
     l_ou_tax_upfront_yn VARCHAR2(1);
     l_err_msg           VARCHAR2(80);
     --Added Bug # 5647107 ssdeshpa end
     BEGIN
       l_debug_enabled := okl_debug_pub.check_log_enabled;
       is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
        				   ,fnd_log.level_procedure);


       IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
         okl_debug_pub.log_debug(fnd_log.level_procedure
        			,l_module
        			,'begin debug OKLRQQCB.pls call extended_validations');
       END IF;  -- check for logging on STATEMENT level
       is_debug_statement_on := okl_debug_pub.check_log_on(l_module
        						  ,fnd_log.level_statement);

        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list

        x_return_status := okl_api.start_activity(p_api_name=>l_api_name
        					,p_pkg_name=>G_PKG_NAME
        					,p_init_msg_list=> p_init_msg_list
        					,p_api_version=>p_api_version
        					,l_api_version=>p_api_version
        					,p_api_type=>G_API_TYPE
        					,x_return_status=>x_return_status);  -- check if activity started successfully

        IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
        ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
        END IF;

       lp_quote_id := p_object_id;
       IF(lp_quote_id IS NOT NULL) THEN
          IF(p_object_type='LEASEQUOTE') THEN
             OPEN c_lq_asset_rec(lp_quote_id);
             FETCH c_lq_asset_rec INTO lp_lq_asset_rec;
             WHILE c_lq_asset_rec%FOUND
             LOOP
             IF(nvl(lp_lq_asset_rec.end_of_term_value,0) > lp_lq_asset_rec.oec) THEN
                 i:=x_qa_result_tbl.COUNT;
                 i:=i+1;
                 x_qa_result_tbl(i).check_code:='extended_validations';
                 x_qa_result_tbl(i).check_meaning:='EOT_VALUE_GREATER_THAN_OEC';
                 x_qa_result_tbl(i).result_code:='ERROR';
                 x_qa_result_tbl(i).result_meaning:='ERROR';
                 x_qa_result_tbl(i).message_code:= 'OKL_QA_EOT_GT_OEC';
                 x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_EOT_GT_OEC');
                 x_qa_result := okl_api.G_RET_STS_ERROR;
                 EXIT;
             END IF;
             FETCH c_lq_asset_rec INTO lp_lq_asset_rec;
             END LOOP;
             CLOSE c_lq_asset_rec;

             --Bug 4713705 SSDESHPA--->Start
	         --Check whether the Product Id selected on Quote is having
	         --Active Stream Generation template's effective start dates between the
	         --Quote Expected Start dates
	         OPEN c_lq_header_rec(lp_quote_id);
	         FETCH c_lq_header_rec INTO lp_lq_header_rec;
	         CLOSE c_lq_header_rec;

             OPEN c_lq_valid_sgt_prod(lp_lq_header_rec.product_id,lp_lq_header_rec.expected_start_date);
             FETCH c_lq_valid_sgt_prod INTO x;
             CLOSE c_lq_valid_sgt_prod;
             --Check for Validity of Product
             IF(nvl(x,'y') <>'x') THEN
                i:=x_qa_result_tbl.COUNT;
                i:=i+1;
                x_qa_result_tbl(i).check_code:='extended_validations';
                x_qa_result_tbl(i).check_meaning:='PRDT_SGT_NOT_ACTIVE';
                x_qa_result_tbl(i).result_code:='ERROR';
                x_qa_result_tbl(i).result_meaning:='ERROR';
                x_qa_result_tbl(i).message_code:= 'OKL_QA_SGT_PRD_INVALID';
                x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SGT_PRD_INVALID');
                x_qa_result := okl_api.G_RET_STS_ERROR;
             END IF;
          --Bug 4713705 SSDESHPA--->End
          --Added for Legal Entity Validation
          OPEN l_systemparams_csr;
          FETCH l_systemparams_csr INTO l_ou_tax_upfront_yn;
          CLOSE l_systemparams_csr;
          IF(l_ou_tax_upfront_yn = 'Y' AND lp_lq_header_rec.legal_entity_id IS NULL) THEN
            IF(lp_lq_header_rec.parent_object_code = 'LEASEAPP') THEN
               l_err_msg := 'OKL_SO_LSE_APP_LE_ERR';
            ELSE
               l_err_msg := 'OKL_LEASE_QUOTE_LE_ERR';
            END IF;
            i:=x_qa_result_tbl.COUNT;
            i:=i+1;
            x_qa_result_tbl(i).check_code:='extended_validations';
            x_qa_result_tbl(i).check_meaning:= l_err_msg;
            x_qa_result_tbl(i).result_code:='ERROR';
            x_qa_result_tbl(i).result_meaning:='ERROR';
            x_qa_result_tbl(i).message_code:= l_err_msg;
            x_qa_result_tbl(i).message_text:=get_msg_text(l_err_msg);
            x_qa_result := okl_api.G_RET_STS_ERROR;
          END IF;
        END IF;---LQ

          IF(p_object_type='QUICKQUOTE') THEN
          --Residual value cannot exceed OEC
           OPEN c_qq_header_rec(lp_quote_id);
           FETCH c_qq_header_rec INTO lp_qq_header_rec;
           CLOSE c_qq_header_rec;
           IF(lp_qq_header_rec.pricing_method <> 'SF') THEN

             OPEN c_qq_lines_rec(lp_quote_id);
             FETCH c_qq_lines_rec INTO lp_qq_lines_rec;
             WHILE c_qq_lines_rec%FOUND
             LOOP
               IF(nvl(lp_qq_lines_rec.end_of_term_value,0) > lp_qq_lines_rec.value) THEN
                 i:=x_qa_result_tbl.COUNT;
                 i:=i+1;
                 x_qa_result_tbl(i).check_code:='extended_validations';
                 x_qa_result_tbl(i).check_meaning:='EOT_VALUE_GREATER_THAN_OEC';
                 x_qa_result_tbl(i).result_code:='ERROR';
                 x_qa_result_tbl(i).result_meaning:='ERROR';
                 x_qa_result_tbl(i).message_code:= 'OKL_QA_EOT_GT_OEC';
                 x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_EOT_GT_OEC');
                 x_qa_result := okl_api.G_RET_STS_ERROR;
                 EXIT;
               END IF;
               FETCH c_qq_lines_rec INTO lp_qq_lines_rec;
             END LOOP;
             CLOSE c_qq_lines_rec;
           END IF;

           --Bug fix 4713705 Start
	       --Check whether the Product Id associated with EOT selected on Quote is having
	       --Active Stream Generation template having effective start dates between the
	       --Quote Expected Start dates
           OPEN c_qq_header_rec(lp_quote_id);
           FETCH c_qq_header_rec INTO lp_qq_header_rec;
           CLOSE c_qq_header_rec;

           OPEN c_qq_valid_sgt_eot(lp_qq_header_rec.end_of_term_option_id,lp_qq_header_rec.expected_start_date);
           FETCH c_qq_valid_sgt_eot INTO x;
           CLOSE c_qq_valid_sgt_eot;
           --Check for Validity of EOT
           IF(nvl(x,'y') <>'x') THEN
              i:=x_qa_result_tbl.COUNT;
              i:=i+1;
              x_qa_result_tbl(i).check_code:='extended_validations';
              x_qa_result_tbl(i).check_meaning:='EOT_PRDT_SGT_NOT_ACTIVE';
              x_qa_result_tbl(i).result_code:='ERROR';
              x_qa_result_tbl(i).result_meaning:='ERROR';
              x_qa_result_tbl(i).message_code:= 'OKL_QA_SGT_EOT_INVALID';
              x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SGT_EOT_INVALID');
              x_qa_result := okl_api.G_RET_STS_ERROR;
           END IF;
           --Bug fix 4713705 End
         END IF;--End OF QQ

       END IF;---End OF If quote Id IS Not Null

       okl_api.end_activity(x_msg_count => x_msg_count
                            ,x_msg_data  => x_msg_data);

       IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
            okl_debug_pub.log_debug(fnd_log.level_procedure
                        		    ,l_module
                    			    ,'end debug okl_sales_quote_qa_pvt call extended_validations');
       END IF;

       EXCEPTION
        WHEN okl_api.g_exception_error THEN

           x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
        					       ,p_pkg_name  =>G_PKG_NAME
        					       ,p_exc_name  =>'OKL_API.G_RET_STS_ERROR'
        					       ,x_msg_count =>x_msg_count
        					       ,x_msg_data  =>x_msg_data
        					       ,p_api_type  =>G_API_TYPE);

         WHEN okl_api.g_exception_unexpected_error THEN

           x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
        					       ,p_pkg_name  =>G_PKG_NAME
        					       ,p_exc_name  =>'OKL_API.G_RET_STS_UNEXP_ERROR'
        					       ,x_msg_count =>x_msg_count
        					       ,x_msg_data  =>x_msg_data
        					       ,p_api_type  =>G_API_TYPE);

         WHEN OTHERS THEN

           x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
        					       ,p_pkg_name  =>G_PKG_NAME
        					       ,p_exc_name  =>'OTHERS'
        					       ,x_msg_count =>x_msg_count
        					       ,x_msg_data  =>x_msg_data
        					       ,p_api_type  =>G_API_TYPE);

     END extended_validations;

/*------------------------------------------------------------------------------
    -- PROCEDURE check_subsidies
  ------------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name   : check_subsidies
    -- Description     : Check Subsidy Related Validations
    --
    -- Business Rules  :
    --
    -- Parameters      : p_object_id   -- Lease Quote /Quick Quote Id.

                        p_object_type -- valid values are  'LEASEQUOTE'/'QUICKQUOTE'
                        hold which type of object this method is calling

                         x_qa_result_tbl --> Hold all the QA Results for Object

    -- Version         :
    -- History         :
    -- End of comments
------------------------------------------------------------------------------*/
     PROCEDURE check_subsidies(p_api_version      IN NUMBER
                                        ,p_init_msg_list    IN VARCHAR2
                                        ,p_object_type      IN VARCHAR2
                                        ,p_object_id        IN NUMBER
                                        ,x_return_status    OUT NOCOPY VARCHAR2
                                        ,x_msg_count        OUT NOCOPY NUMBER
                                        ,x_msg_data         OUT NOCOPY VARCHAR2
                                        ,x_qa_result_tbl    IN OUT NOCOPY OKL_SALES_QUOTE_QA_PVT.qa_results_tbl_type
                                        ,x_qa_result       IN  OUT NOCOPY VARCHAR2) IS

       lp_quote_id NUMBER;
       lp_asset_id NUMBER;
       lp_subsidy_calc_basis VARCHAR2(30);
       lp_rec_flag VARCHAR2(1);
       i  INTEGER;
       l_module            CONSTANT fnd_log_messages.module%TYPE := 'chk_ss';
       l_debug_enabled                varchar2(10);
       is_debug_procedure_on          boolean;
       is_debug_statement_on          boolean;
       l_program_name      CONSTANT VARCHAR2(30) := 'chk_ss';
       l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

       cursor c_qq_asset_lines_rec(p_quick_quote_id NUMBER) IS
         select t2.* from OKL_QUICK_QUOTES_B t1,OKL_QUICK_QUOTE_LINES_B t2
         WHERE t1.PRICING_METHOD='SF'
         AND t2.type='SUBSIDY'
         AND t1.id=p_quick_quote_id
         AND t2.quick_quote_id=t1.id;

       lp_qq_asset_lines_rec c_qq_asset_lines_rec%ROWTYPE;

       cursor c_lq_asset_lines_rec(p_quote_id NUMBER) IS
         SELECT t2.*
         FROM OKL_LEASE_QUOTES_B t1,OKL_ASSETS_B t2
         where t1.id=p_quote_id
         AND t1.pricing_method='SF'
         and t2.parent_object_code='LEASEQUOTE'
         and t2.parent_object_id=t1.id;

       lp_lq_asset_lines_rec c_lq_asset_lines_rec%ROWTYPE;

       cursor c_lq_cost_adj_rec(p_asset_id NUMBER) IS
         SELECT BASIS FROM OKL_COST_ADJUSTMENTS_B
         where PARENT_OBJECT_CODE='ASSET'
         and ADJUSTMENT_SOURCE_TYPE='SUBSIDY'
         AND  PARENT_OBJECT_ID=p_asset_id;

       lp_lq_cost_adj_rec c_lq_cost_adj_rec%ROWTYPE;

     BEGIN
     l_debug_enabled := okl_debug_pub.check_log_enabled;
     is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
        				   ,fnd_log.level_procedure);


     IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
         okl_debug_pub.log_debug(fnd_log.level_procedure
        			,l_module
        			,'begin debug OKLRQQCB.pls call check_subsidies');
     END IF;  -- check for logging on STATEMENT level
     is_debug_statement_on := okl_debug_pub.check_log_on(l_module
        						  ,fnd_log.level_statement);

     -- call START_ACTIVITY to create savepoint, check compatibility
     -- and initialize message list
     x_return_status := okl_api.start_activity(p_api_name=>l_api_name
                            				   ,p_pkg_name=>G_PKG_NAME
         					                   ,p_init_msg_list=>p_init_msg_list
        					                   ,p_api_version=>p_api_version
        					                   ,l_api_version=>p_api_version
        					                   ,p_api_type=>G_API_TYPE
        					                   ,x_return_status=>x_return_status);  -- check if activity started successfully

      IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
      ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
      END IF;
      lp_quote_id := p_object_id;
      IF(lp_quote_id IS NOT NULL) THEN
           IF(p_object_type='LEASEQUOTE') THEN
              --Check that Subsidy types must be FIXED or RATE for SFFA Pricing Methods
              OPEN c_lq_asset_lines_rec(lp_quote_id);
              FETCH c_lq_asset_lines_rec INTO lp_lq_asset_lines_rec;
              WHILE c_lq_asset_lines_rec%FOUND
              LOOP
                OPEN c_lq_cost_adj_rec(lp_lq_asset_lines_rec.id);
                FETCH c_lq_cost_adj_rec INTO lp_lq_cost_adj_rec;
                IF((c_lq_cost_adj_rec%FOUND) AND(lp_lq_cost_adj_rec.basis IS NOT NULL) AND (lp_lq_cost_adj_rec.basis <> 'FIXED' AND lp_lq_cost_adj_rec.basis <> 'RATE') ) THEN
                   i:=x_qa_result_tbl.COUNT;
                   i:=i+1;
                   x_qa_result_tbl(i).check_code:='check_subsidies';
                   x_qa_result_tbl(i).check_meaning:='SUBSIDY BASIS NOT VALID';
                   x_qa_result_tbl(i).result_code:='ERROR';
                   x_qa_result_tbl(i).result_meaning:='ERROR';
                   x_qa_result_tbl(i).message_code:= 'OKL_QA_SUB_BASIS_NOT_VALID_SF';
                   x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SUB_BASIS_NOT_VALID_SF');
                   x_qa_result := okl_api.G_RET_STS_ERROR;
                   EXIT;
                END IF;
                CLOSE c_lq_cost_adj_rec;
              FETCH c_lq_asset_lines_rec INTO lp_lq_asset_lines_rec;
              END LOOP;
              CLOSE c_lq_asset_lines_rec;
           END IF;--End OF LQ

           IF(p_object_type='QUICKQUOTE') THEN
           --Check that Subsidy types must be FIXED or RATE for SFFA Pricing Methods
             OPEN c_qq_asset_lines_rec(lp_quote_id);
             FETCH c_qq_asset_lines_rec INTO lp_qq_asset_lines_rec;
             WHILE c_qq_asset_lines_rec%FOUND
             LOOP
             IF((lp_qq_asset_lines_rec.basis IS NOT NULL) AND (lp_qq_asset_lines_rec.basis <> 'FIXED' AND lp_qq_asset_lines_rec.basis <> 'RATE')) THEN
                i:=x_qa_result_tbl.COUNT;
                i:=i+1;
                x_qa_result_tbl(i).check_code:='check_subsidies';
                x_qa_result_tbl(i).check_meaning:='SUBSIDY BASIS NOT VALID';
                x_qa_result_tbl(i).result_code:='ERROR';
                x_qa_result_tbl(i).result_meaning:='ERROR';
                 x_qa_result_tbl(i).message_code:= 'OKL_QA_SUB_BASIS_NOT_VALID_SF';
                x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SUB_BASIS_NOT_VALID_SF');
                x_qa_result := okl_api.G_RET_STS_ERROR;
                EXIT;
             END IF;
             FETCH c_qq_asset_lines_rec INTO lp_qq_asset_lines_rec;
             END LOOP;
             CLOSE c_qq_asset_lines_rec;
           END IF;--End OF QQ
       END IF;---End OF If quote Id IS Not Null

       okl_api.end_activity(x_msg_count => x_msg_count
                		    ,x_msg_data  => x_msg_data);

       IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
            okl_debug_pub.log_debug(fnd_log.level_procedure
        			    ,l_module
        			    ,'end debug okl_sales_quote_qa_pvt call check_subsidies');
       END IF;
       EXCEPTION
         WHEN okl_api.g_exception_error THEN
           x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
        					       ,p_pkg_name  =>G_PKG_NAME
        					       ,p_exc_name  =>'OKL_API.G_RET_STS_ERROR'
        					       ,x_msg_count =>x_msg_count
        					       ,x_msg_data  =>x_msg_data
        					       ,p_api_type  =>G_API_TYPE);

          WHEN okl_api.g_exception_unexpected_error THEN
            x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
        					                            ,p_pkg_name  =>G_PKG_NAME
        					                            ,p_exc_name  =>'OKL_API.G_RET_STS_UNEXP_ERROR'
        					                            ,x_msg_count =>x_msg_count
        					                            ,x_msg_data  =>x_msg_data
        					                            ,p_api_type  =>G_API_TYPE);

         WHEN OTHERS THEN
            x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
        					                             ,p_pkg_name  =>G_PKG_NAME
        					                             ,p_exc_name  =>'OTHERS'
        					                             ,x_msg_count =>x_msg_count
        					                             ,x_msg_data  =>x_msg_data
        					                             ,p_api_type  =>G_API_TYPE);
     END check_subsidies;

/*------------------------------------------------------------------------------
    -- PROCEDURE check_configuration
---------------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name   : check_configuration
    -- Description     :  Check Attributes for Configuration Objects(Assets/Config
                          Fees /capitalized Fees/Rollover Fees)
    --
    -- Business Rules  : Various checks related to Configuration Tab Objects.
                         Assets/Financed Fee/Rollover Fees/Capitalized fees.
    --
    -- Parameters      : p_object_id   -- Lease Quote /Quick Quote Id.

                        p_object_type -- valid values are  'LEASEQUOTE'/'QUICKQUOTE'
                        hold which type of object this method is calling

                         x_qa_result_tbl --> Hold all the QA Results for Object

    -- Version         : 1.0
    -- History         :
    -- End of comments
------------------------------------------------------------------------------*/
   PROCEDURE check_configuration(p_api_version      IN NUMBER
                                 ,p_init_msg_list    IN VARCHAR2
                                 ,p_object_type      IN VARCHAR2
                                 ,p_object_id        IN NUMBER
                                 ,x_return_status    OUT NOCOPY VARCHAR2
                                 ,x_msg_count        OUT NOCOPY NUMBER
                                 ,x_msg_data         OUT NOCOPY VARCHAR2
                                 ,x_qa_result_tbl    IN OUT NOCOPY OKL_SALES_QUOTE_QA_PVT.qa_results_tbl_type
                                 ,x_qa_result       IN  OUT NOCOPY VARCHAR2) IS

       -- bug 5048183 ssdeshpa Start
       -- Get all the Info abt the Assets for Quote
       CURSOR c_lq_asset_rec(p_quote_id NUMBER) IS
	      SELECT ID,END_OF_TERM_VALUE_DEFAULT,END_OF_TERM_VALUE
	      FROM OKL_ASSETS_B OLA
	      WHERE OLA.PARENT_OBJECT_ID=p_quote_id
          AND   OLA.PARENT_OBJECT_CODE='LEASEQUOTE';
       -- bug 5048183 ssdeshpa End
       --Fetch Quick Quote Item categories
       CURSOR c_qq_asset_rec(p_quote_id NUMBER) IS
          SELECT 'x'
          FROM OKL_QUICK_QUOTE_LINES_B OAL
          WHERE OAL.QUICK_QUOTE_ID=p_quote_id
          AND   OAL.TYPE='ITEM_CATEGORY';

       lp_quote_id NUMBER;
       lp_asset_id NUMBER;
       lp_rec_flag VARCHAR2(1);
       l_asset_count INTEGER := 0;
       i  INTEGER;
       l_module            CONSTANT fnd_log_messages.module%TYPE := 'chk_cnfg';
       l_debug_enabled                varchar2(10);
       is_debug_procedure_on          boolean;
       is_debug_statement_on          boolean;
       l_program_name      CONSTANT VARCHAR2(30) := 'chk_cnfg';
       l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

       BEGIN
       l_debug_enabled := okl_debug_pub.check_log_enabled;
       is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
        				   ,fnd_log.level_procedure);


       IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
         okl_debug_pub.log_debug(fnd_log.level_procedure
        			            ,l_module
        			            ,'begin debug OKLRQQCB.pls call check_configuration');
       END IF;  -- check for logging on STATEMENT level
       is_debug_statement_on := okl_debug_pub.check_log_on(l_module
        						  ,fnd_log.level_statement);

        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list

       x_return_status := okl_api.start_activity(p_api_name=>l_api_name
        					,p_pkg_name=>G_PKG_NAME
        					,p_init_msg_list=>p_init_msg_list
        					,p_api_version=>p_api_version
        					,l_api_version=>p_api_version
        					,p_api_type=>G_API_TYPE
        					,x_return_status=>x_return_status);  -- check if activity started successfully

       IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
       ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
       END IF;

       lp_quote_id := p_object_id;
       IF(lp_quote_id IS NOT NULL) THEN
          IF(p_object_type='LEASEQUOTE') THEN
            -- bug 5048183 ssdeshpa Start
            -- Check for EOT Value/EOT Override Value for Asset
            --Both can not be null for a Quote
            FOR lp_lq_asset_rec IN c_lq_asset_rec(p_quote_id => lp_quote_id) LOOP
		        l_asset_count := l_asset_count + 1;
		        IF(lp_lq_asset_rec.END_OF_TERM_VALUE_DEFAULT IS NULL AND
		           lp_lq_asset_rec.END_OF_TERM_VALUE IS NULL) THEN
        		   i:=x_qa_result_tbl.COUNT;
        		   i:=i+1;
        		   x_qa_result_tbl(i).check_code:='check_configuration';
        		   x_qa_result_tbl(i).check_meaning:='NO_ASSETS_FOUND';
        		   x_qa_result_tbl(i).result_code:='ERROR';
        		   x_qa_result_tbl(i).result_meaning:='ERROR';
        		   x_qa_result_tbl(i).message_code:= 'OKL_QA_NO_EOT_FOR_ASSET';
        		   x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_NO_EOT_FOR_ASSET');
        		   x_qa_result := okl_api.G_RET_STS_ERROR;
        		   EXIT;
        		END IF;
        	END LOOP;
        	--For a Quote Atlease One Asset Should be there
        	--At least one asset line must exist.
	        IF(l_asset_count = 0) THEN
    	       i:=x_qa_result_tbl.COUNT;
    	       i:=i+1;
    	       x_qa_result_tbl(i).check_code:='check_configuration';
    	       x_qa_result_tbl(i).check_meaning:='NO_ASSETS_FOUND';
    	       x_qa_result_tbl(i).result_code:='ERROR';
    	       x_qa_result_tbl(i).result_meaning:='ERROR';
    	       x_qa_result_tbl(i).message_code:= 'OKL_QA_NO_ASSETS_FOUND';
    	       x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_NO_ASSETS_FOUND');
    	       x_qa_result := okl_api.G_RET_STS_ERROR;
    	    END IF;
         END IF;--for LQ
         -- bug 5048183 ssdeshpa End
         IF(p_object_type='QUICKQUOTE') THEN
            OPEN c_qq_asset_rec(p_quote_id => lp_quote_id);
            FETCH c_qq_asset_rec INTO lp_rec_flag;
            CLOSE c_qq_asset_rec;
            --For a Quote Atlease One Asset Should be there
        	--At least one asset line must exist.
            IF(lp_rec_flag IS NULL) THEN
               i:=x_qa_result_tbl.COUNT;
               i:=i+1;
               x_qa_result_tbl(i).check_code:='check_configuration';
               x_qa_result_tbl(i).check_meaning:='NO_ASSETS_FOUND';
               x_qa_result_tbl(i).result_code:='ERROR';
               x_qa_result_tbl(i).result_meaning:='ERROR';
               x_qa_result_tbl(i).message_code:= 'OKL_QA_NO_ASSETS_FOUND';
               x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_NO_ASSETS_FOUND');
               x_qa_result := okl_api.G_RET_STS_ERROR;
            END IF;
         END IF;--End of QQ
       ELSE
         i:=x_qa_result_tbl.COUNT;
         i:=i+1;
         x_qa_result_tbl(i).check_code:='check_configuration';
         x_qa_result_tbl(i).check_meaning:='NO_QUOTE_FOUND';
         x_qa_result_tbl(i).result_code:='ERROR';
         x_qa_result_tbl(i).result_meaning:='ERROR';
         x_qa_result_tbl(i).message_code:= 'OKL_QA_NO_QUOTE_FOUND';
         x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_NO_QUOTE_FOUND');
         x_qa_result := okl_api.G_RET_STS_ERROR;
      END IF;
      okl_api.end_activity(x_msg_count => x_msg_count
    			    ,x_msg_data  => x_msg_data);

    	IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
    	    okl_debug_pub.log_debug(fnd_log.level_procedure
    				    ,l_module
    				    ,'end debug okl_sales_quote_qa_pvt call check_configuration ');
    	END IF;

   EXCEPTION
        WHEN okl_api.g_exception_error THEN
          x_return_status := okl_api.handle_exceptions(p_api_name  => l_api_name
    					       ,p_pkg_name  => G_PKG_NAME
    					       ,p_exc_name  => 'OKL_API.G_RET_STS_ERROR'
    					       ,x_msg_count => x_msg_count
    					       ,x_msg_data  => x_msg_data
    					       ,p_api_type  => G_API_TYPE);

         WHEN okl_api.g_exception_unexpected_error THEN

           x_return_status := okl_api.handle_exceptions(p_api_name  => l_api_name
        					       ,p_pkg_name  => G_PKG_NAME
        					       ,p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR'
        					       ,x_msg_count => x_msg_count
        					       ,x_msg_data  => x_msg_data
        					       ,p_api_type  => G_API_TYPE);

         WHEN OTHERS THEN

           x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
        					       ,p_pkg_name  => G_PKG_NAME
        					       ,p_exc_name  =>'OTHERS'
        					       ,x_msg_count => x_msg_count
        					       ,x_msg_data  => x_msg_data
        					       ,p_api_type  => G_API_TYPE);

  END check_configuration;
/*------------------------------------------------------------------------------
    -- PROCEDURE check_fees_and_services
  ------------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name   : check_fees_and_services
    -- Description     :  Check Fees and Services Associated with Quote
    --
    -- Business Rules  :  Fees and Services Objects associated with Quote will
                          be checked for Validity.
    --
    -- Parameters      : p_object_id   -- Lease Quote /Quick Quote Id.

                        p_object_type -- valid values are  'LEASEQUOTE'/'QUICKQUOTE'
                        hold which type of object this method is calling

                         x_qa_result_tbl --> Hold all the QA Results for Object

    -- Version         : 1.0
    -- History         :
    -- End of comments
------------------------------------------------------------------------------*/
    PROCEDURE check_fees_and_services(p_api_version      IN NUMBER
                                        ,p_init_msg_list    IN VARCHAR2
                                        ,p_object_type      IN VARCHAR2
                                        ,p_object_id        IN NUMBER
                                        ,x_return_status    OUT NOCOPY VARCHAR2
                                        ,x_msg_count        OUT NOCOPY NUMBER
                                        ,x_msg_data         OUT NOCOPY VARCHAR2
                                        ,x_qa_result_tbl    IN OUT NOCOPY OKL_SALES_QUOTE_QA_PVT.qa_results_tbl_type
                                        ,x_qa_result       IN  OUT NOCOPY VARCHAR2) IS
        lp_quote_id NUMBER;
        lp_asset_id NUMBER;
        lp_service_line_id NUMBER;
        lp_capital_fee_type CONSTANT varchar2(30):='CAPITALIZED';
        lp_sec_dep_fee_type CONSTANT varchar2(30):='SEC_DEPOSIT';
        lp_rec_flag VARCHAR2(1);
        i  INTEGER;
        total_line_amount INTEGER:=0;
        lp_fee_amount INTEGER:=0;
        lp_service_line_total INTEGER:=0;

        l_module            CONSTANT fnd_log_messages.module%TYPE := 'chk_fees_and_services';
        l_debug_enabled                varchar2(10);
        is_debug_procedure_on          boolean;
        is_debug_statement_on          boolean;
        l_program_name      CONSTANT VARCHAR2(30) := 'chck_fee';
        l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
        --Fetch all the Configuration Fees For Quote
        cursor c_config_fee_rec(p_quote_id NUMBER) IS
        select ofv.*
        from okl_fees_v ofv
        where ofv.parent_object_code='LEASEQUOTE'
        AND ofv.parent_object_id=p_quote_id
        AND	ofv.fee_type IN ('FINANCED','ROLLOVER');

        --Tune The Query and Remove Extra Columns
        --cursor can fetch multiple Records
        cursor c_lq_asset_line(p_parent_object_id NUMBER,p_fee_id NUMBER) IS
        select olr.*
        from okl_line_relationships_b olr,
             okl_fees_b ofv
        where ofv.FEE_TYPE='CAPITALIZED'
        AND olr.related_line_id = p_fee_id
        AND olr.related_line_id = ofv.id      	-- Added by rravikir for Bug 4736523
        AND olr.related_line_type = 'CAPITALIZED';

        lp_lq_fee_rec  c_lq_fee_rec%ROWTYPE;
        lp_lq_asset_line  c_lq_asset_line%ROWTYPE;
    BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
    				   ,fnd_log.level_procedure);


    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(fnd_log.level_procedure
    			,l_module
    			,'begin debug OKLRQQCB.pls.check_fees_and_services call ');
    END IF;  -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
    						  ,fnd_log.level_statement);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    x_return_status := okl_api.start_activity(p_api_name=>l_api_name
    					,p_pkg_name=>G_PKG_NAME
    					,p_init_msg_list=>p_init_msg_list
    					,p_api_version=>p_api_version
    					,l_api_version=>p_api_version
    					,p_api_type=>G_API_TYPE
    					,x_return_status=>x_return_status);  -- check if activity started successfully

    IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
     RAISE okl_api.g_exception_unexpected_error;
    ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
     RAISE okl_api.g_exception_error;
    END IF;

     lp_quote_id := p_object_id;
     IF(lp_quote_id IS NOT NULL) THEN
        IF(p_object_type='LEASEQUOTE' OR p_object_type='LEASEAPP' OR p_object_type='LEASEOPP') THEN
          --When defining capitalized fees, the total amount applied to
          --each associated asset must be equal to the fee line total
           FOR lp_lq_fee_rec IN c_lq_fee_rec(lp_quote_id,lp_capital_fee_type) LOOP
                ---calculate the Total Fee Amount
                lp_fee_amount:=lp_lq_fee_rec.fee_amount;

                --Bug # 6697231 :Initialized total amount
                total_line_amount:=0;
                --Bug # 6697231:End
                ----------
                OPEN c_lq_asset_line(lp_quote_id ,lp_lq_fee_rec.id);
                FETCH c_lq_asset_line INTO lp_lq_asset_line;
                IF(c_lq_asset_line%NOTFOUND) THEN
                   i:=x_qa_result_tbl.COUNT;
                   i:=i+1;
                   x_qa_result_tbl(i).check_code:='check_fees_and_services';
                   x_qa_result_tbl(i).check_meaning:='NO_ASSETS_FOUND_FOR_FEE';
                   x_qa_result_tbl(i).result_code:='ERROR';
                   x_qa_result_tbl(i).result_meaning:='ERROR';
                   x_qa_result_tbl(i).message_code:= 'OKL_QA_NO_ASSETS_FOR_FEE';
                   x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_NO_ASSETS_FOR_FEE');
                   x_qa_result := okl_api.G_RET_STS_ERROR;
                 ELSE
                 /* Keep fetching until no more records are FOUND */
                   WHILE c_lq_asset_line%FOUND LOOP
                     total_line_amount:=total_line_amount + nvl(lp_lq_asset_line.amount,0);
                     FETCH c_lq_asset_line INTO lp_lq_asset_line;
                   END LOOP;
                 END IF;
                 IF  c_lq_asset_line%ISOPEN THEN
                    CLOSE c_lq_asset_line;
                 END IF;
                 IF(lp_fee_amount <> total_line_amount) THEN
                     i:=x_qa_result_tbl.COUNT;
                     i:=i+1;
                     x_qa_result_tbl(i).check_code:='check_fees_and_services';
                     x_qa_result_tbl(i).check_meaning:='FEE_LINE_TOTAL_NOT_MATCH ';
                     x_qa_result_tbl(i).result_code:='ERROR';
                     x_qa_result_tbl(i).result_meaning:='ERROR';
                     x_qa_result_tbl(i).message_code:= 'OKL_QA_FEE_TOTAL_NOT_MATCH';
                     x_qa_result_tbl(i).message_text:= get_msg_text('OKL_QA_FEE_TOTAL_NOT_MATCH');
                     x_qa_result := okl_api.G_RET_STS_ERROR;
                  END IF;
           END LOOP;
           --Check Whether the Quote Have Only One SECURITY_DEPOSIT Fee Defined on it
           OPEN c_lq_fee_rec(lp_quote_id,lp_sec_dep_fee_type);
           i:=0;
           FETCH c_lq_fee_rec INTO lp_lq_fee_rec;
           WHILE c_lq_fee_rec%FOUND LOOP
                i:=i+1;
                FETCH c_lq_fee_rec INTO lp_lq_fee_rec;
           END LOOP;
           CLOSE c_lq_fee_rec;
           IF(i > 1) THEN
              i:=x_qa_result_tbl.COUNT;
              i:=i+1;
              x_qa_result_tbl(i).check_code:='check_fees_and_services';
              x_qa_result_tbl(i).check_meaning:='ONLY_ONE_SEC_DEP_FOR_QUOTE ';
              x_qa_result_tbl(i).result_code:='ERROR';
              x_qa_result_tbl(i).result_meaning:='ERROR';
              x_qa_result_tbl(i).message_code:= 'OKL_QA_SINGLE_SEC_DEP_REQ';
              x_qa_result_tbl(i).message_text:= get_msg_text('OKL_QA_SINGLE_SEC_DEP_REQ');
              x_qa_result := okl_api.G_RET_STS_ERROR;
           END IF;

        END IF;--End For LQ
        IF(p_object_type='QUICKQUOTE') THEN
           return;
        END IF;--End OF QQ

     END IF;---End OF If quote Id IS NOt Null
     okl_api.end_activity(x_msg_count => x_msg_count
    		    ,x_msg_data  => x_msg_data);

     IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
    			               ,l_module
    			               ,'end debug okl_sales_quote_qa_pvt.check_fees_and_services call');
     END IF;

     EXCEPTION
        WHEN okl_api.g_exception_error THEN
           x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
        					       ,p_pkg_name  =>G_PKG_NAME
        					       ,p_exc_name  =>'OKL_API.G_RET_STS_ERROR'
        					       ,x_msg_count =>x_msg_count
        					       ,x_msg_data  =>x_msg_data
        					       ,p_api_type  =>G_API_TYPE);

         WHEN okl_api.g_exception_unexpected_error THEN
            x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
        					       ,p_pkg_name  =>G_PKG_NAME
        					       ,p_exc_name  =>'OKL_API.G_RET_STS_UNEXP_ERROR'
        					       ,x_msg_count =>x_msg_count
        					       ,x_msg_data  =>x_msg_data
        					       ,p_api_type  =>G_API_TYPE);

         WHEN OTHERS THEN
            x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
        					       ,p_pkg_name  =>G_PKG_NAME
        					       ,p_exc_name  =>'OTHERS'
        					       ,x_msg_count =>x_msg_count
        					       ,x_msg_data  =>x_msg_data
        					       ,p_api_type  =>G_API_TYPE);
   END check_fees_and_services;
/*------------------------------------------------------------------------------
    -- PROCEDURE check_payments
  ------------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name   : check_payments
    -- Description     : Check the Payment/Pricing data For Quote
    --
    -- Business Rules  : Check the Payment/Pricing data For Quote so that Pricing
                         Engine go smooth without errors
    --
    -- Parameters      : p_object_id   -- Lease Quote /Quick Quote Id.

                        p_object_type -- valid values are  'LEASEQUOTE'/'QUICKQUOTE'
                        hold which type of object this method is calling

                        x_qa_result_tbl --> Hold all the QA Results for Object

    -- Version         :
    -- History         :
    -- End of comments
------------------------------------------------------------------------------*/
   PROCEDURE check_payments(p_api_version      IN NUMBER
                                        ,p_init_msg_list    IN VARCHAR2
                                        ,p_object_type      IN VARCHAR2
                                        ,p_object_id        IN NUMBER
                                        ,x_return_status    OUT NOCOPY VARCHAR2
                                        ,x_msg_count        OUT NOCOPY NUMBER
                                        ,x_msg_data         OUT NOCOPY VARCHAR2
                                        ,x_qa_result_tbl    IN OUT NOCOPY OKL_SALES_QUOTE_QA_PVT.qa_results_tbl_type
                                        ,x_qa_result        IN OUT NOCOPY VARCHAR2) IS
        lp_quote_id NUMBER;
        lp_service_line_id NUMBER;
        lp_vp_id  NUMBER;
        lp_sec_dep_fee_type CONSTANT varchar2(30):='SEC_DEPOSIT';
        lp_rec_flag VARCHAR2(1);
        lp_cont_start_date DATE;
        lp_payment_start_date DATE;
        i  INTEGER;
        x  varchar2(1);
        l_cnt NUMBER;
        l_found boolean := false;
        l_amt_null_count INTEGER := 0;
        l_total_caf INTEGER := 0;
        l_no_qte_payment boolean := false;

        l_missing_pmts INTEGER := 0;
        l_cfl_count INTEGER := 0;
        l_no_missing_rate boolean := FALSE;
        l_total_missing_pmts INTEGER := 0;
        l_total_cfl_count INTEGER := 0;
        l_no_missing_rate_count INTEGER := 0;

        l_are_all_lines_overriden VARCHAR2(1);
        l_qte_pric_opts_entered VARCHAR2(1);
        l_cashflow_count INTEGER := 0;
        l_fees_count INTEGER := 0;
        l_module            CONSTANT fnd_log_messages.module%TYPE := 'chek_pay';
        l_debug_enabled                varchar2(10);
        is_debug_procedure_on          boolean;
        is_debug_statement_on          boolean;
        l_program_name      CONSTANT VARCHAR2(30) := 'chek_pay';
        l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
        --Get data for Configuration Fees(Financed and Rollover)
	    cursor c_configuration_fee_rec(p_quote_id NUMBER) IS
	       select ofv.id,
	              ofv.rate_card_id,
		          ofv.rate_template_id,
		          ofv.structured_pricing,
		          ofv.lease_rate_factor,
		          'QUOTED_FEE' oty_code,
		          ofv.target_arrears,
		          ofv.target_amount,
		          STYT.NAME NAME
		   from okl_fees_b ofv,
		        OKL_STRM_TYPE_B STY,
                OKL_STRM_TYPE_TL STYT
	       where ofv.parent_object_code='LEASEQUOTE'
	       AND ofv.parent_object_id=p_quote_id
	       AND ofv.fee_type IN ('FINANCED','ROLLOVER')
           AND ofv.STREAM_TYPE_ID = STY.ID
           AND STY.ID = STYT.ID
           AND STYT.LANGUAGE = USERENV('LANG');

        --Get data for Assets on Quote
	    cursor c_configuration_asset_rec(p_quote_id NUMBER) IS
            select oab.id,
	        oab.rate_card_id,
	        oab.rate_template_id,
	        oab.structured_pricing,
	        oab.lease_rate_factor,
	        'QUOTED_ASSET' oty_code,
	        oab.target_arrears,
	        oab.target_amount
	       from okl_assets_b oab
	       where oab.parent_object_code='LEASEQUOTE'
	       AND oab.parent_object_id=p_quote_id;

	    -----------------------------
	    cursor c_config_fee_rec(p_quote_id NUMBER) IS
	       select ofv.id,
	              ofv.rate_card_id,
		      ofv.rate_template_id,
		      ofv.structured_pricing,
		      ofv.lease_rate_factor,
		      'QUOTED_FEE' oty_code
	       from okl_fees_b ofv
	       where ofv.parent_object_code='LEASEQUOTE'
	       AND ofv.parent_object_id=p_quote_id
	       AND ofv.fee_type IN ('FINANCED','ROLLOVER')
	    UNION
	        select oab.id,
	        oab.rate_card_id,
	        oab.rate_template_id,
	        oab.structured_pricing,
	        oab.lease_rate_factor,
	        'QUOTED_ASSET' oty_code
	       from okl_assets_b oab
	       where oab.parent_object_code='LEASEQUOTE'
	       AND oab.parent_object_id=p_quote_id;

        CURSOR c_payment_level_rec(p_quote_id NUMBER) IS
        SELECT TRUNC(CFL.start_date)
        FROM  OKL_CASH_FLOWS CAF,OKL_CASH_FLOW_LEVELS CFL
        WHERE CAF.ID=CFL.CAF_ID
        AND   CAF.dnz_qte_id=p_quote_id;
        ---Check the Date Condition
        CURSOR c_vp_rec(p_vp_id NUMBER,p_contract_start_date DATE) IS
         select 'x'
         from okc_k_headers_v  tbl
         where tbl.id=p_vp_id
         AND p_contract_start_date between tbl.start_date and NVL(tbl.end_date,p_contract_start_date)
         AND tbl.SCS_CODE='PROGRAM'
         AND tbl.STS_CODE='ACTIVE'
         AND tbl.template_yn='N';

       CURSOR is_rc_valid_csr(p_lrs_version_id IN NUMBER,p_exp_start_date IN DATE) IS
        SELECT 'Y'
        FROM okl_fe_rate_set_versions
        WHERE rate_set_version_id = p_lrs_version_id
        AND  effective_from_date <= p_exp_start_date
        AND  nvl(effective_to_date,p_exp_start_date) >= p_exp_start_date;

       CURSOR is_srt_valid_csr(p_srt_version_id IN NUMBER,p_exp_start_date IN DATE) IS
        SELECT 'Y'
        FROM okl_fe_std_rt_tmp_vers
        WHERE std_rate_tmpl_ver_id = p_srt_version_id
        AND  effective_from_date <= p_exp_start_date
        AND  nvl(effective_to_date,p_exp_start_date) >= p_exp_start_date;

        --Get the Cash Flow Count for Quote/Asset/Config Fees
       CURSOR c_cash_flow_level_count(p_source_id NUMBER,p_oty_code VARCHAR2) IS
        SELECT count(*) cfl_count
        FROM OKL_CASH_FLOW_OBJECTS CFO,OKL_CASH_FLOWS CAF,
             OKL_CASH_FLOW_LEVELS CFL
        WHERE CFO.ID=CAF.CFO_ID
        AND   CAF.ID=CFL.CAF_ID
        AND   CFO.oty_code=p_oty_code
        AND   CFO.source_id=p_source_id;

        l_valid            VARCHAR2(3):= 'N';
        lp_lq_service_fee  c_lq_fee_rec%ROWTYPE;
        lp_lq_cfl_line    c_lq_cfl_line%ROWTYPE;
        lp_payment_level_rec c_payment_level_rec%ROWTYPE;
        BEGIN
        l_debug_enabled := okl_debug_pub.check_log_enabled;
        is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
        				   ,fnd_log.level_procedure);


        IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
         okl_debug_pub.log_debug(fnd_log.level_procedure
        			,l_module
        			,'begin debug OKLRQQCB.pls call check_payments');
        END IF;  -- check for logging on STATEMENT level
        is_debug_statement_on := okl_debug_pub.check_log_on(l_module
        						  ,fnd_log.level_statement);

        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list

        x_return_status := okl_api.start_activity(p_api_name => l_api_name
        					                      ,p_pkg_name => G_PKG_NAME
        					                      ,p_init_msg_list => p_init_msg_list
        					                      ,p_api_version => p_api_version
        					                      ,l_api_version => p_api_version
        					                      ,p_api_type => G_API_TYPE
        					                      ,x_return_status => x_return_status);  -- check if activity started successfully

        IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
        ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
        END IF;

        lp_quote_id:=p_object_id;
        IF(lp_quote_id IS NOT NULL) THEN
           IF(p_object_type='LEASEQUOTE' OR p_object_type='LEASEAPP' OR p_object_type='LEASEOPP') THEN
              lp_vp_id := OKL_EC_UPTAKE_PVT.get_vp_id(lp_quote_id);
              ---Exception Thrown if There are more than One Sec Deposit Defined on the Quote
              --Check It
              OPEN c_lq_fee_rec(lp_quote_id,lp_sec_dep_fee_type);
              i:=0;
              FETCH c_lq_fee_rec INTO lp_lq_service_fee;
              WHILE c_lq_fee_rec%FOUND LOOP
                    i:=i+1;
                    FETCH c_lq_fee_rec INTO lp_lq_service_fee;
              END LOOP;
              CLOSE c_lq_fee_rec;
              --More Than One Sec Deposit At Contract Level
              --Already thrown out by the Check_fees_and _services() method
              IF(i > 1) THEN
                 return;
              END IF;
              IF(lp_lq_service_fee.id is NOT NULL) THEN
                 open c_lq_cfl_line(lp_service_line_id,'QUOTED_FEE');
                 FETCH c_lq_cfl_line INTO lp_lq_cfl_line;
                     IF(lp_lq_cfl_line.stub_amount IS NOT NULL) THEN
                        i:=x_qa_result_tbl.COUNT;
                        i:=i+1;
                        x_qa_result_tbl(i).check_code:='check_payments';
                        x_qa_result_tbl(i).check_meaning:='SEC_DEPOSIT_HAS_STUB_AMOUNT_DEFINED';
                        x_qa_result_tbl(i).result_code:='ERROR';
                        x_qa_result_tbl(i).result_meaning:='ERROR';
                        x_qa_result_tbl(i).message_code:= 'OKL_QA_SEC_DEP_STUB_AMT_DEF';
                        x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SEC_DEP_STUB_AMT_DEF');
                        x_qa_result := okl_api.G_RET_STS_ERROR;
                     END IF;
                     CLOSE c_lq_cfl_line;
               END IF;
        ----------------------------------------------------------------------
        --get quote rec
        --Filter 'Check For Quote Level Payment' check for pricing methods
        OPEN c_lq_header_rec(lp_quote_id);
        FETCH c_lq_header_rec INTO lp_lq_header_rec;
        CLOSE c_lq_header_rec;
	   --------------------------------------------------------------
        FOR l_cfl_cnt_rec IN c_cash_flow_level_count(lp_quote_id ,'LEASE_QUOTE') LOOP
	        l_cashflow_count := l_cfl_cnt_rec.cfl_count;
	    END LOOP;
        IF l_cashflow_count = 0 THEN
           l_no_qte_payment := TRUE;
        ELSE
           l_no_qte_payment := FALSE;
        END IF;
      --------------------------------------------------------------
      l_are_all_lines_overriden :=
          are_all_lines_overriden(p_quote_id => lp_quote_id,
                                  p_pricing_method => lp_lq_header_rec.pricing_method,
                                  p_line_level_pricing => lp_lq_header_rec.line_level_pricing,
                                  x_return_status => x_return_status);

      --------------------------------------------------------------
      /* l_qte_pric_opts_entered :=
       are_qte_pricing_opts_entered(p_lease_qte_rec => lp_lq_header_rec
                                   ,p_payment_count => l_cashflow_count
                                   ,x_return_status => x_return_status);*/
      --------------------------------------------------------------

      IF(lp_lq_header_rec.pricing_method IN('SD','SF', 'SI', 'SS','SP','SY')) THEN
         IF((l_are_all_lines_overriden='N') OR  NVL(lp_lq_header_rec.line_level_pricing , 'N') ='N') THEN
            IF((NVL(lp_lq_header_rec.STRUCTURED_PRICING, 'N') = 'N')) THEN
              -- validate srt, arrears, and pa(not for SP) from lp_lq_header_rec
              validate_payment_options(lp_lq_header_rec.RATE_TEMPLATE_ID
                                       ,lp_lq_header_rec.TARGET_ARREARS_YN
                                       ,lp_lq_header_rec.PRICING_METHOD
                                       ,lp_lq_header_rec.TARGET_AMOUNT
                                       ,x_qa_result_tbl
                                       ,x_return_status);

            ELSIF((NVL(lp_lq_header_rec.STRUCTURED_PRICING, 'N') = 'Y')) THEN
                 --validate LEASE_QUOTE cash flows for presence of
                 --payment type , arrears, freq and cash flow level > 0
                 validate_cashflows(lp_lq_header_rec.ID
                                   ,'LEASE_QUOTE'
                                   ,lp_lq_header_rec.PRICING_METHOD
                                   ,x_qa_result_tbl
                                   ,x_return_status);

            END IF;
            --Add Asset Level Validation When LLO='Y' and not all lines are overriden
            IF((l_are_all_lines_overriden='N') AND  NVL(lp_lq_header_rec.line_level_pricing , 'N') ='Y') THEN
               FOR lp_config_asset_rec IN c_configuration_asset_rec(lp_quote_id) LOOP
                  --is asset is overriden
                 IF lp_config_asset_rec.STRUCTURED_PRICING IS NOT NULL THEN
                   IF((NVL(lp_config_asset_rec.STRUCTURED_PRICING, 'N') = 'N')) THEN
                    -- validate srt, arrears, and pa(not for SP) from lp_lq_header_rec
                      validate_payment_options(lp_config_asset_rec.RATE_TEMPLATE_ID
                                             ,lp_config_asset_rec.target_arrears
                                             ,lp_lq_header_rec.PRICING_METHOD
                                             ,lp_config_asset_rec.TARGET_AMOUNT
                                             ,x_qa_result_tbl
                                             ,x_return_status);

                   ELSIF((NVL(lp_config_asset_rec.STRUCTURED_PRICING, 'N') = 'Y')) THEN
                    --validate LEASE_QUOTE cash flows for presence of
                    --payment type , arrears, freq and cash flow level > 0
                    validate_cashflows(lp_config_asset_rec.ID
                                       ,'QUOTED_ASSET'
                                       ,lp_lq_header_rec.PRICING_METHOD
                                       ,x_qa_result_tbl
                                       ,x_return_status);
                   END IF;
                 END IF;
               END LOOP;
            END IF;
         ELSIF(l_are_all_lines_overriden='Y' AND NVL(lp_lq_header_rec.line_level_pricing , 'N') ='Y') THEN
            FOR lp_config_asset_rec IN c_configuration_asset_rec(lp_quote_id) LOOP
               IF((NVL(lp_config_asset_rec.STRUCTURED_PRICING, 'N') = 'N')) THEN
                -- validate srt, arrears, and pa(not for SP) from lp_lq_header_rec
                  validate_payment_options(lp_config_asset_rec.RATE_TEMPLATE_ID
                                         ,lp_config_asset_rec.target_arrears
                                         ,lp_lq_header_rec.PRICING_METHOD
                                         ,lp_config_asset_rec.TARGET_AMOUNT
                                         ,x_qa_result_tbl
                                         ,x_return_status);

               ELSIF((NVL(lp_config_asset_rec.STRUCTURED_PRICING, 'N') = 'Y')) THEN
                --validate LEASE_QUOTE cash flows for presence of
                --payment type , arrears, freq and cash flow level > 0
                validate_cashflows(lp_config_asset_rec.ID
                                   ,'QUOTED_ASSET'
                                   ,lp_lq_header_rec.PRICING_METHOD
                                   ,x_qa_result_tbl
                                   ,x_return_status);
               END IF;
            END LOOP;
         END IF;
      END IF;
 -------------------------------------------------------------------------------

   --Check If Rate Type ,Rate ,Periods,Frequency is Entered for
   --Quote having Pricing Method 'Target Rate'
   IF(lp_lq_header_rec.pricing_method = 'TR') THEN
      IF(lp_lq_header_rec.TARGET_RATE_TYPE IS NULL OR
         lp_lq_header_rec.TARGET_FREQUENCY IS NULL OR
         lp_lq_header_rec.TARGET_RATE IS NULL OR
         lp_lq_header_rec.TARGET_PERIODS IS NULL ) THEN
           i:=x_qa_result_tbl.COUNT;
           i:=i+1;
           x_qa_result_tbl(i).check_code:='check_payments';
           x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_FOR_QUOTE';
           x_qa_result_tbl(i).result_code:='ERROR';
           x_qa_result_tbl(i).result_meaning:='ERROR';
           x_qa_result_tbl(i).message_code:= 'OKL_QA_TR_MISS_PAY_ERROR';
           x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_TR_MISS_PAY_ERROR');
           x_qa_result := okl_api.G_RET_STS_ERROR;
      END IF;
   END IF;
--------------------------------------------------------------------------------
  --Check for Payment Method 'RC'
  IF((lp_lq_header_rec.pricing_method = 'RC') AND
       ( NVL(lp_lq_header_rec.LINE_LEVEL_PRICING,'N')='N')) THEN
          IF ( (lp_lq_header_rec.RATE_CARD_ID IS NULL) AND
              NVL(lp_lq_header_rec.structured_pricing , 'N') = 'N') THEN
              i:=x_qa_result_tbl.COUNT;
              i:=i+1;
              x_qa_result_tbl(i).check_code:='check_payments';
              x_qa_result_tbl(i).check_meaning:='PRICING_NOT_DONE_FOR_LINE ';
              x_qa_result_tbl(i).result_code:='ERROR';
              x_qa_result_tbl(i).result_meaning:='ERROR';
              x_qa_result_tbl(i).message_code:= 'OKL_QA_LRS_NOT_FOUND';
              x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_LRS_NOT_FOUND');
              x_qa_result := okl_api.G_RET_STS_ERROR;
          ELSIF(( NVL( lp_lq_header_rec.structured_pricing, 'N') = 'Y'  AND
                 lp_lq_header_rec.LEASE_RATE_FACTOR IS NULL) ) THEN
                  i:=x_qa_result_tbl.COUNT;
                  i:=i+1;
                  x_qa_result_tbl(i).check_code:='check_fees_and_services';
                  x_qa_result_tbl(i).check_meaning:='PRICING_NOT_DONE_FOR_LINE ';
                  x_qa_result_tbl(i).result_code:='ERROR';
                  x_qa_result_tbl(i).result_meaning:='ERROR';
                  x_qa_result_tbl(i).message_code:= 'OKL_QA_RC_MISS_PAY_ERROR';
                  x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_RC_MISS_PAY_ERROR');
                  x_qa_result := okl_api.G_RET_STS_ERROR;
          END IF;
    ELSIF((lp_lq_header_rec.pricing_method = 'RC') AND
         ( NVL(lp_lq_header_rec.LINE_LEVEL_PRICING,'N')='Y')) THEN
            FOR lp_config_fee_rec IN c_config_fee_rec(lp_quote_id) LOOP
              IF ( (lp_config_fee_rec.RATE_CARD_ID IS NULL) AND
                   (lp_lq_header_rec.RATE_CARD_ID IS NULL AND lp_lq_header_rec.LEASE_RATE_FACTOR IS NULL) AND
                    NVL(lp_config_fee_rec.structured_pricing , 'N') = 'N') THEN
                        i:=x_qa_result_tbl.COUNT;
                        i:=i+1;
                        x_qa_result_tbl(i).check_code:='check_payments';
                        x_qa_result_tbl(i).check_meaning:='PRICING_NOT_DONE_FOR_LINE ';
                        x_qa_result_tbl(i).result_code:='ERROR';
                        x_qa_result_tbl(i).result_meaning:='ERROR';
                        x_qa_result_tbl(i).message_code:= 'OKL_QA_LRS_NOT_FOUND';
                        x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_LRS_NOT_FOUND');
                        x_qa_result := okl_api.G_RET_STS_ERROR;
              ELSIF(( NVL( lp_config_fee_rec.structured_pricing, 'N') = 'Y') AND
                    ( lp_config_fee_rec.LEASE_RATE_FACTOR IS NULL) AND
                     (lp_lq_header_rec.RATE_CARD_ID IS NULL AND lp_lq_header_rec.LEASE_RATE_FACTOR IS NULL)) THEN
                     i:=x_qa_result_tbl.COUNT;
                     i:=i+1;
                     x_qa_result_tbl(i).check_code:='check_fees_and_services';
                     x_qa_result_tbl(i).check_meaning:='PRICING_NOT_DONE_FOR_LINE ';
                     x_qa_result_tbl(i).result_code:='ERROR';
                     x_qa_result_tbl(i).result_meaning:='ERROR';
                     x_qa_result_tbl(i).message_code:= 'OKL_QA_RC_MISS_PAY_ERROR';
                     x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_RC_MISS_PAY_ERROR');
                     x_qa_result := okl_api.G_RET_STS_ERROR;
                     EXIT;
              END IF;
            END LOOP;
    END IF;
--------------------------------------------------------------------------------
     --check if rate card version selected is valid
    IF lp_lq_header_rec.pricing_method = 'RC'  THEN
          IF  NVL(lp_lq_header_rec.structured_pricing , 'N') = 'N'
          AND lp_lq_header_rec.RATE_CARD_ID IS NOT NULL THEN
            l_valid := 'N';
            OPEN is_rc_valid_csr(lp_lq_header_rec.RATE_CARD_ID,lp_lq_header_rec.expected_start_date);
            FETCH is_rc_valid_csr INTO l_valid;
            CLOSE is_rc_valid_csr;
            IF l_valid = 'N' THEN
                 i:=x_qa_result_tbl.COUNT;
                 i:=i+1;
                 x_qa_result_tbl(i).check_code:='check_fees_and_services';
                 x_qa_result_tbl(i).check_meaning:='PRICING_NOT_DONE_FOR_LINE ';
                 x_qa_result_tbl(i).result_code:='ERROR';
                 x_qa_result_tbl(i).result_meaning:='ERROR';
                 x_qa_result_tbl(i).message_code:= 'OKL_QA_RCHDR_NOT_VALID';
                 x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_RCHDR_NOT_VALID');
                 x_qa_result := okl_api.G_RET_STS_ERROR;

            END IF;
          END IF;
          IF  NVL(lp_lq_header_rec.LINE_LEVEL_PRICING,'N')='Y' THEN
             FOR lp_config_fee_rec IN c_config_fee_rec(lp_quote_id) LOOP
                IF NVL(lp_config_fee_rec.structured_pricing , 'N') = 'N'
                AND lp_config_fee_rec.RATE_CARD_ID IS NOT NULL THEN
                  l_valid := 'N';
                  OPEN is_rc_valid_csr(lp_config_fee_rec.RATE_CARD_ID,lp_lq_header_rec.expected_start_date);
                  FETCH is_rc_valid_csr INTO l_valid;
                  CLOSE is_rc_valid_csr;
                  IF l_valid = 'N' THEN
                     i:=x_qa_result_tbl.COUNT;
                     i:=i+1;
                     x_qa_result_tbl(i).check_code:='check_fees_and_services';
                     x_qa_result_tbl(i).check_meaning:='PRICING_NOT_DONE_FOR_LINE ';
                     x_qa_result_tbl(i).result_code:='ERROR';
                     x_qa_result_tbl(i).result_meaning:='ERROR';
                     x_qa_result_tbl(i).message_code:= 'OKL_QA_RCLINE_NOT_VALID';
                     x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_RCLINE_NOT_VALID');
                     x_qa_result := okl_api.G_RET_STS_ERROR;
                     EXIT;
                  END IF;
                END IF;
             END LOOP;
          END IF;
    END IF;
    --check if the srt version selected is valid
    IF lp_lq_header_rec.pricing_method IN ('SD','SF', 'SI', 'SS','SP','SM')  THEN
          IF  NVL(lp_lq_header_rec.structured_pricing , 'N') = 'N'
          AND lp_lq_header_rec.RATE_TEMPLATE_ID IS NOT NULL THEN
            l_valid := 'N';
            OPEN is_srt_valid_csr(lp_lq_header_rec.RATE_TEMPLATE_ID,lp_lq_header_rec.expected_start_date);
            FETCH is_srt_valid_csr INTO l_valid;
            CLOSE is_srt_valid_csr;
            IF l_valid = 'N' THEN
                 i:=x_qa_result_tbl.COUNT;
                 i:=i+1;
                 x_qa_result_tbl(i).check_code:='check_fees_and_services';
                 x_qa_result_tbl(i).check_meaning:='PRICING_NOT_DONE_FOR_LINE ';
                 x_qa_result_tbl(i).result_code:='ERROR';
                 x_qa_result_tbl(i).result_meaning:='ERROR';
                 x_qa_result_tbl(i).message_code:= 'OKL_QA_SRTHDR_NOT_VALID';
                 x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SRTHDR_NOT_VALID');
                 x_qa_result := okl_api.G_RET_STS_ERROR;
            /*ELSE
                 check_srt_effective_rate(lp_lq_header_rec.RATE_TEMPLATE_ID,
                                          lp_lq_header_rec.ID,
                                          x_qa_result_tbl);*/
            END IF;
          END IF;
          IF  NVL(lp_lq_header_rec.LINE_LEVEL_PRICING,'N')='Y' THEN
             FOR lp_config_fee_rec IN c_config_fee_rec(lp_quote_id) LOOP
                IF NVL(lp_config_fee_rec.structured_pricing , 'N') = 'N'
                AND lp_config_fee_rec.RATE_TEMPLATE_ID IS NOT NULL THEN
                  l_valid := 'N';
                  OPEN is_srt_valid_csr(lp_config_fee_rec.RATE_TEMPLATE_ID,lp_lq_header_rec.expected_start_date);
                  FETCH is_srt_valid_csr INTO l_valid;
                  CLOSE is_srt_valid_csr;
                  IF l_valid = 'N' THEN
                     i:=x_qa_result_tbl.COUNT;
                     i:=i+1;
                     x_qa_result_tbl(i).check_code:='check_fees_and_services';
                     x_qa_result_tbl(i).check_meaning:='PRICING_NOT_DONE_FOR_LINE ';
                     x_qa_result_tbl(i).result_code:='ERROR';
                     x_qa_result_tbl(i).result_meaning:='ERROR';
                     x_qa_result_tbl(i).message_code:= 'OKL_QA_SRTLINE_NOT_VALID';
                     x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SRTLINE_NOT_VALID');
                     x_qa_result := okl_api.G_RET_STS_ERROR;
                     EXIT;
                  /*ELSE
                     check_srt_effective_rate(lp_config_fee_rec.RATE_TEMPLATE_ID,
                                              lp_lq_header_rec.ID,
                                              x_qa_result_tbl);*/
                  END IF;
                END IF;
             END LOOP;
          END IF;
    END IF;
--------------------------------------------------------------------------------
    IF(lp_lq_header_rec.pricing_method = 'SM' ) THEN
     IF((l_are_all_lines_overriden='N') OR  NVL(lp_lq_header_rec.line_level_pricing , 'N') ='N') THEN
       IF((NVL(lp_lq_header_rec.STRUCTURED_PRICING, 'N') = 'N')) THEN
         FOR l_cfl_line_rec IN c_lq_cfl_line(lp_quote_id ,'LEASE_QUOTE') LOOP
	       l_cfl_count := l_cfl_count + 1;
	       IF ((l_cfl_line_rec.stub_days > 0 AND l_cfl_line_rec.stub_amount IS NULL ) OR
	       ( l_cfl_line_rec.number_of_periods > 0 AND l_cfl_line_rec.amount IS NULL ))THEN
		      l_missing_pmts := l_missing_pmts + 1;
	       END IF;
         END LOOP;
         IF (l_missing_pmts <> 1) THEN
	       i:=x_qa_result_tbl.COUNT;
	       i:=i+1;
	       x_qa_result_tbl(i).check_code:='check_payments';
	       x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
	       x_qa_result_tbl(i).result_code:='ERROR';
	       x_qa_result_tbl(i).result_meaning:='ERROR';
	       x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_MISS_PAY_ERROR';
	       x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_MISS_PAY_ERROR');
	       x_qa_result := okl_api.G_RET_STS_ERROR;
         END IF;
         IF(l_cfl_count <= 1) THEN
	       i:=x_qa_result_tbl.COUNT;
	       i:=i+1;
	       x_qa_result_tbl(i).check_code:='check_payments';
	       x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
	       x_qa_result_tbl(i).result_code:='ERROR';
	       x_qa_result_tbl(i).result_meaning:='ERROR';
	       x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_QTE_PAY_ERROR';
	       x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_QTE_PAY_ERROR');
	       x_qa_result := okl_api.G_RET_STS_ERROR;
         END IF;
         IF(( lp_lq_header_rec.RATE_TEMPLATE_ID IS NULL)) THEN
	       i:=x_qa_result_tbl.COUNT;
	       i:=i+1;
	       x_qa_result_tbl(i).check_code:='check_payments';
	       x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_FOR_QUOTE';
	       x_qa_result_tbl(i).result_code:='ERROR';
	       x_qa_result_tbl(i).result_meaning:='ERROR';
	       x_qa_result_tbl(i).message_code:= 'OKL_QA_SRT_NOT_FOUND';
	       x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SRT_NOT_FOUND');
	       x_qa_result := okl_api.G_RET_STS_ERROR;
         END IF;
     ELSIF((NVL(lp_lq_header_rec.STRUCTURED_PRICING, 'N') = 'Y')) THEN

    	 FOR l_cfl_line_rec IN c_lq_cfl_line(lp_quote_id ,'LEASE_QUOTE') LOOP
        	l_cfl_count := l_cfl_count + 1;
	        IF ((l_cfl_line_rec.stub_days > 0 AND l_cfl_line_rec.stub_amount IS NULL ) OR
	           ( l_cfl_line_rec.number_of_periods > 0 AND l_cfl_line_rec.amount IS NULL ))THEN
		       l_missing_pmts := l_missing_pmts + 1;
	        END IF;
	     END LOOP;
	     IF(l_missing_pmts <> 1) THEN
	        i:=x_qa_result_tbl.COUNT;
	        i:=i+1;
	        x_qa_result_tbl(i).check_code:='check_payments';
	        x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
	        x_qa_result_tbl(i).result_code:='ERROR';
	        x_qa_result_tbl(i).result_meaning:='ERROR';
	        x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_MISS_PAY_ERROR';
	        x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_MISS_PAY_ERROR');
	        x_qa_result := okl_api.G_RET_STS_ERROR;
	     END IF;
	     IF (l_cfl_count <= 1) THEN
	        i:=x_qa_result_tbl.COUNT;
	        i:=i+1;
	        x_qa_result_tbl(i).check_code:='check_payments';
	        x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
	        x_qa_result_tbl(i).result_code:='ERROR';
	        x_qa_result_tbl(i).result_meaning:='ERROR';
	        x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_QTE_PAY_ERROR';
	        x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_QTE_PAY_ERROR');
	        x_qa_result := okl_api.G_RET_STS_ERROR;
	     END IF;
     END IF;
     l_total_missing_pmts := l_total_missing_pmts + l_missing_pmts;
     l_total_cfl_count := l_total_cfl_count + l_cfl_count;
     IF((l_are_all_lines_overriden='N') AND  NVL(lp_lq_header_rec.line_level_pricing , 'N') ='Y') THEN
         l_missing_pmts := 0;
         l_cfl_count := 0;
         l_no_missing_rate := FALSE;
         FOR configuration_asset_rec IN c_configuration_asset_rec(lp_quote_id) LOOP
           --if asset is overriden
           IF configuration_asset_rec.STRUCTURED_PRICING IS NOT NULL THEN

        	   IF((NVL(configuration_asset_rec.STRUCTURED_PRICING, 'N')) = 'N') THEN
        	   -- validate srt, arrears, and pa(not for SP) from lp_lq_header_rec
        	    l_missing_pmts := 0;
        	    l_cfl_count := 0;
        	    l_no_missing_rate := FALSE;
        	    FOR l_cfl_line_rec IN c_lq_cfl_line(configuration_asset_rec.id ,configuration_asset_rec.oty_code) LOOP
        	       l_cfl_count := l_cfl_count + 1;
        	       IF ((l_cfl_line_rec.stub_days > 0 AND l_cfl_line_rec.stub_amount IS NULL ) OR
        		   (l_cfl_line_rec.number_of_periods > 0 AND l_cfl_line_rec.amount IS NULL )) THEN
        		       l_missing_pmts := l_missing_pmts + 1;
        	       END IF;
        	       IF(l_cfl_line_rec.rate IS NOT NULL ) THEN
        		       l_no_missing_rate := TRUE;
        	       END IF;
        	    END LOOP;

                IF(l_missing_pmts > 1) THEN
        	      i:=x_qa_result_tbl.COUNT;
        	      i:=i+1;
        	      x_qa_result_tbl(i).check_code:='check_payments';
        	      x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
        	      x_qa_result_tbl(i).result_code:='ERROR';
        	      x_qa_result_tbl(i).result_meaning:='ERROR';
        	      x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_MISS_PAY_ERROR';
        	      x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_MISS_PAY_ERROR');
        	      x_qa_result := okl_api.G_RET_STS_ERROR;
        	      EXIT;
        	    END IF;
        	    IF(l_missing_pmts = 0 AND configuration_asset_rec.RATE_TEMPLATE_ID IS NOT NULL) THEN
        	       i:=x_qa_result_tbl.COUNT;
        	       i:=i+1;
        	       x_qa_result_tbl(i).check_code:='check_payments';
        	       x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
        	       x_qa_result_tbl(i).result_code:='ERROR';
        	       x_qa_result_tbl(i).result_meaning:='ERROR';
        	       x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_ASSET_SRT_FOUND';
                   set_fnd_message( p_msg_name  =>  'OKL_QA_SM_ASSET_SRT_FOUND'
                                    ,p_token1    => 'NAME'
                                    ,p_value1    =>  configuration_asset_rec.ID
                                    ,p_token2    =>  NULL
                                    ,p_value2    =>  NULL
                                    ,p_token3    =>  NULL
                                    ,p_value3    =>  NULL
                                    ,p_token4    =>  NULL
                                    ,p_value4    =>  NULL);
                   x_qa_result_tbl(i).message_text:= fnd_message.get;
        	       x_qa_result := okl_api.G_RET_STS_ERROR;
        	    END IF;

        	    IF(l_missing_pmts > 0 AND (l_cfl_count = 1)) THEN
                       i:=x_qa_result_tbl.COUNT;
        		       i:=i+1;
        		       x_qa_result_tbl(i).check_code:='check_payments';
        		       x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
        		       x_qa_result_tbl(i).result_code:='ERROR';
        		       x_qa_result_tbl(i).result_meaning:='ERROR';
        		       x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_CONFIG_PAY_ERROR';
        		       x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_CONFIG_PAY_ERROR');
        		       x_qa_result := okl_api.G_RET_STS_ERROR;
                       EXIT;
                END IF;
        	    l_total_missing_pmts := l_total_missing_pmts + l_missing_pmts;
        	    l_total_cfl_count := l_total_cfl_count + l_cfl_count;

        	 ELSIF((NVL(configuration_asset_rec.STRUCTURED_PRICING, 'N') = 'Y')) THEN
        	 --validate LEASE_QUOTE cash flows for presence of
        	 --payment type , arrears, freq and cash flow level > 0
        	    l_missing_pmts := 0;
        	    l_cfl_count := 0;
        	    l_no_missing_rate := FALSE;
        	    l_no_missing_rate_count := 0;
        	    FOR l_cfl_line_rec IN c_lq_cfl_line(configuration_asset_rec.id ,configuration_asset_rec.oty_code) LOOP
            		l_cfl_count := l_cfl_count + 1;
        	    	IF ((l_cfl_line_rec.stub_days > 0 AND l_cfl_line_rec.stub_amount IS NULL ) OR
        		       (l_cfl_line_rec.number_of_periods > 0 AND l_cfl_line_rec.amount IS NULL )) THEN
        		        l_missing_pmts := l_missing_pmts + 1;
        		    END IF;
        		    IF( l_cfl_line_rec.rate IS NOT NULL ) THEN
        		      l_no_missing_rate := TRUE;
        		      l_no_missing_rate_count := l_no_missing_rate_count + 1;
        		    END IF;
        	    END LOOP;
        	    IF (l_missing_pmts = 0 AND l_no_missing_rate) THEN
                  i:=x_qa_result_tbl.COUNT;
        	      i:=i+1;
        	      x_qa_result_tbl(i).check_code:='check_payments';
        	      x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_FOR_QUOTE';
        	      x_qa_result_tbl(i).result_code:='ERROR';
        	      x_qa_result_tbl(i).result_meaning:='ERROR';
        	      x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_QTE_RATE_ERROR';
        	      x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_QTE_RATE_ERROR');
        	      x_qa_result := okl_api.G_RET_STS_ERROR;
        		  EXIT;
                END IF;
        	    IF(l_missing_pmts > 1) THEN
        		  i:=x_qa_result_tbl.COUNT;
        		  i:=i+1;
        		  x_qa_result_tbl(i).check_code:='check_payments';
        		  x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
        		  x_qa_result_tbl(i).result_code:='ERROR';
        		  x_qa_result_tbl(i).result_meaning:='ERROR';
        		  x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_MISS_PAY_ERROR';
        		  x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_MISS_PAY_ERROR');
        		  x_qa_result := okl_api.G_RET_STS_ERROR;
        		  EXIT;
                END IF;
                ---- ???????
        	    IF(l_missing_pmts > 0 AND (l_cfl_count <> l_no_missing_rate_count)) THEN
        		  i:=x_qa_result_tbl.COUNT;
        		  i:=i+1;
        		  x_qa_result_tbl(i).check_code:='check_payments';
        		  x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
        		  x_qa_result_tbl(i).result_code:='ERROR';
        		  x_qa_result_tbl(i).result_meaning:='ERROR';
        		  x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_MISS_PAY_ERROR';
        		  x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_MISS_RATE_ERROR');
        		  x_qa_result := okl_api.G_RET_STS_ERROR;
        		  EXIT;
        	    END IF;
        	    ---- ???????
        	    IF(l_missing_pmts > 0 AND (l_cfl_count = 1)) THEN
                       i:=x_qa_result_tbl.COUNT;
        		       i:=i+1;
        		       x_qa_result_tbl(i).check_code:='check_payments';
        		       x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
        		       x_qa_result_tbl(i).result_code:='ERROR';
        		       x_qa_result_tbl(i).result_meaning:='ERROR';
        		       x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_CONFIG_PAY_ERROR';
        		       x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_CONFIG_PAY_ERROR');
        		       x_qa_result := okl_api.G_RET_STS_ERROR;
                       EXIT;
                END IF;
        	    l_total_missing_pmts := l_total_missing_pmts + l_missing_pmts;
        	    l_total_cfl_count := l_total_cfl_count + l_cfl_count;

        	 END IF;
            END IF;
          END LOOP;

     END IF;
  ELSIF (l_are_all_lines_overriden='Y' AND NVL(lp_lq_header_rec.line_level_pricing , 'N') ='Y') THEN
     l_missing_pmts := 0;
     l_cfl_count := 0;
     l_no_missing_rate := FALSE;
     FOR configuration_asset_rec IN c_configuration_asset_rec(lp_quote_id) LOOP
	   IF((NVL(configuration_asset_rec.STRUCTURED_PRICING, 'N')) = 'N') THEN
	    l_missing_pmts := 0;
	    l_cfl_count := 0;
	    l_no_missing_rate := FALSE;
	    FOR l_cfl_line_rec IN c_lq_cfl_line(configuration_asset_rec.id ,configuration_asset_rec.oty_code) LOOP
	       l_cfl_count := l_cfl_count + 1;
	       IF ((l_cfl_line_rec.stub_days > 0 AND l_cfl_line_rec.stub_amount IS NULL ) OR
		   (l_cfl_line_rec.number_of_periods > 0 AND l_cfl_line_rec.amount IS NULL )) THEN
		       l_missing_pmts := l_missing_pmts + 1;
	       END IF;
	       IF(l_cfl_line_rec.rate IS NOT NULL ) THEN
		       l_no_missing_rate := TRUE;
	       END IF;
	    END LOOP;
	    IF(l_missing_pmts > 1) THEN
	      i:=x_qa_result_tbl.COUNT;
	      i:=i+1;
	      x_qa_result_tbl(i).check_code:='check_payments';
	      x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
	      x_qa_result_tbl(i).result_code:='ERROR';
	      x_qa_result_tbl(i).result_meaning:='ERROR';
	      x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_MISS_PAY_ERROR';
	      x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_MISS_PAY_ERROR');
	      x_qa_result := okl_api.G_RET_STS_ERROR;
	      EXIT;
	    END IF;
	    IF(l_missing_pmts = 0 AND configuration_asset_rec.RATE_TEMPLATE_ID IS NOT NULL) THEN
	       i:=x_qa_result_tbl.COUNT;
	       i:=i+1;
	       x_qa_result_tbl(i).check_code:='check_payments';
	       x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
	       x_qa_result_tbl(i).result_code:='ERROR';
	       x_qa_result_tbl(i).result_meaning:='ERROR';
	       x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_ASSET_SRT_FOUND';
           set_fnd_message( p_msg_name  =>  'OKL_QA_SM_ASSET_SRT_FOUND'
                            ,p_token1    => 'NAME'
                            ,p_value1    =>  configuration_asset_rec.ID
                            ,p_token2    =>  NULL
                            ,p_value2    =>  NULL
                            ,p_token3    =>  NULL
                            ,p_value3    =>  NULL
                            ,p_token4    =>  NULL
                            ,p_value4    =>  NULL);
           x_qa_result_tbl(i).message_text:= fnd_message.get;
	       x_qa_result := okl_api.G_RET_STS_ERROR;
	    END IF;
	    --For line level override, if SRT is entered at the asset level, and no
        --missing payment is defined, There should be an error stating that the
        --SRT should be removed, as no missing payment is defined and vice-versa.
	    IF(l_missing_pmts > 0 AND configuration_asset_rec.RATE_TEMPLATE_ID IS NULL ) THEN
	       i:=x_qa_result_tbl.COUNT;
	       i:=i+1;
	       x_qa_result_tbl(i).check_code:='check_payments';
	       x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
	       x_qa_result_tbl(i).result_code:='ERROR';
	       x_qa_result_tbl(i).result_meaning:='ERROR';
	       x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_ASSET_SRT_REQ';
           set_fnd_message( p_msg_name  =>  'OKL_QA_SM_ASSET_SRT_REQ'
                            ,p_token1    => 'NAME'
                            ,p_value1    =>  configuration_asset_rec.ID
                            ,p_token2    =>  NULL
                            ,p_value2    =>  NULL
                            ,p_token3    =>  NULL
                            ,p_value3    =>  NULL
                            ,p_token4    =>  NULL
                            ,p_value4    =>  NULL);
           x_qa_result_tbl(i).message_text:= fnd_message.get;
	       x_qa_result := okl_api.G_RET_STS_ERROR;

	    END IF;
	    IF(l_missing_pmts > 0 AND (l_cfl_count = 1)) THEN
               i:=x_qa_result_tbl.COUNT;
		       i:=i+1;
		       x_qa_result_tbl(i).check_code:='check_payments';
		       x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
		       x_qa_result_tbl(i).result_code:='ERROR';
		       x_qa_result_tbl(i).result_meaning:='ERROR';
		       x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_CONFIG_PAY_ERROR';
		       x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_CONFIG_PAY_ERROR');
		       x_qa_result := okl_api.G_RET_STS_ERROR;
               EXIT;
        END IF;
	    l_total_missing_pmts := l_total_missing_pmts + l_missing_pmts;
	    l_total_cfl_count := l_total_cfl_count + l_cfl_count;

	 ELSIF((NVL(configuration_asset_rec.STRUCTURED_PRICING, 'N') = 'Y')) THEN
	 --validate LEASE_QUOTE cash flows for presence of
	 --payment type , arrears, freq and cash flow level > 0
	    l_missing_pmts := 0;
	    l_cfl_count := 0;
	    l_no_missing_rate := FALSE;
	    l_no_missing_rate_count := 0;
	    FOR l_cfl_line_rec IN c_lq_cfl_line(configuration_asset_rec.id ,configuration_asset_rec.oty_code) LOOP
    		l_cfl_count := l_cfl_count + 1;
	    	IF ((l_cfl_line_rec.stub_days > 0 AND l_cfl_line_rec.stub_amount IS NULL ) OR
		       (l_cfl_line_rec.number_of_periods > 0 AND l_cfl_line_rec.amount IS NULL )) THEN
		        l_missing_pmts := l_missing_pmts + 1;
		    END IF;
		    IF( l_cfl_line_rec.rate IS NOT NULL ) THEN
		      l_no_missing_rate := TRUE;
		      l_no_missing_rate_count := l_no_missing_rate_count + 1;
		    END IF;
	    END LOOP;
	    IF (l_missing_pmts = 0 AND l_no_missing_rate) THEN
          i:=x_qa_result_tbl.COUNT;
	      i:=i+1;
	      x_qa_result_tbl(i).check_code:='check_payments';
	      x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_FOR_QUOTE';
	      x_qa_result_tbl(i).result_code:='ERROR';
	      x_qa_result_tbl(i).result_meaning:='ERROR';
	      x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_QTE_RATE_ERROR';
	      x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_QTE_RATE_ERROR');
	      x_qa_result := okl_api.G_RET_STS_ERROR;
		  EXIT;
        END IF;
	    IF(l_missing_pmts > 1) THEN
		  i:=x_qa_result_tbl.COUNT;
		  i:=i+1;
		  x_qa_result_tbl(i).check_code:='check_payments';
		  x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
		  x_qa_result_tbl(i).result_code:='ERROR';
		  x_qa_result_tbl(i).result_meaning:='ERROR';
		  x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_MISS_PAY_ERROR';
		  x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_MISS_PAY_ERROR');
		  x_qa_result := okl_api.G_RET_STS_ERROR;
		  EXIT;
        END IF;
	    IF(l_missing_pmts > 0 AND (l_cfl_count <> l_no_missing_rate_count)) THEN
		  i:=x_qa_result_tbl.COUNT;
		  i:=i+1;
		  x_qa_result_tbl(i).check_code:='check_payments';
		  x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
		  x_qa_result_tbl(i).result_code:='ERROR';
		  x_qa_result_tbl(i).result_meaning:='ERROR';
		  x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_MISS_PAY_ERROR';
		  x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_MISS_RATE_ERROR');
		  x_qa_result := okl_api.G_RET_STS_ERROR;
		  EXIT;
	    END IF;
	    /*IF(l_missing_pmts > 0 AND (l_cfl_count = 1)) THEN
               i:=x_qa_result_tbl.COUNT;
		       i:=i+1;
		       x_qa_result_tbl(i).check_code:='check_payments';
		       x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
		       x_qa_result_tbl(i).result_code:='ERROR';
		       x_qa_result_tbl(i).result_meaning:='ERROR';
		       x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_CONFIG_PAY_ERROR';
		       x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_CONFIG_PAY_ERROR');
		       x_qa_result := okl_api.G_RET_STS_ERROR;
               EXIT;
        END IF;*/
	    l_total_missing_pmts := l_total_missing_pmts + l_missing_pmts;
	    l_total_cfl_count := l_total_cfl_count + l_cfl_count;

	 END IF;
   END LOOP;
   IF(l_total_missing_pmts > 0 AND (l_total_cfl_count = 1)) THEN
               i:=x_qa_result_tbl.COUNT;
		       i:=i+1;
		       x_qa_result_tbl(i).check_code:='check_payments';
		       x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
		       x_qa_result_tbl(i).result_code:='ERROR';
		       x_qa_result_tbl(i).result_meaning:='ERROR';
		       x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_CONFIG_PAY_ERROR';
		       x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_CONFIG_PAY_ERROR');
		       x_qa_result := okl_api.G_RET_STS_ERROR;

    END IF;
   -- ???????????????????
   IF(l_total_missing_pmts = 0) THEN
     i:=x_qa_result_tbl.COUNT;
	 i:=i+1;
	 x_qa_result_tbl(i).check_code:='check_payments';
	 x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
	 x_qa_result_tbl(i).result_code:='ERROR';
	 x_qa_result_tbl(i).result_meaning:='ERROR';
	 x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_MISS_PAY_ERROR';
	 x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_MISS_PAY_ERROR');
	 x_qa_result := okl_api.G_RET_STS_ERROR;
   END IF;
   -- ????????????????????
   /*IF(l_total_cfl_count <= 1 and l_total_missing_pmts <> 0 ) THEN
      i:=x_qa_result_tbl.COUNT;
      i:=i+1;
      x_qa_result_tbl(i).check_code:='check_payments';
      x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
      x_qa_result_tbl(i).result_code:='ERROR';
      x_qa_result_tbl(i).result_meaning:='ERROR';
	  x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_CONFIG_PAY_ERROR';
	  x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_CONFIG_PAY_ERROR');
	  x_qa_result := okl_api.G_RET_STS_ERROR;
   END IF;*/
  END IF;--
 END IF;--Pricing Method is 'SM'

--------------------------------------------------------------------------------
  /* --Bug # 5021838 ssdeshpa start
   IF(l_are_all_lines_overriden='N') THEN
     --Bug # 5036739 ssdeshpa start
     IF((lp_lq_header_rec.pricing_method ='SM') AND
        NVL(lp_lq_header_rec.structured_pricing,'N')='N') THEN
        FOR l_cfl_line_rec IN c_lq_cfl_line(lp_quote_id ,'LEASE_QUOTE') LOOP
	       l_cfl_count := l_cfl_count + 1;
           IF ((l_cfl_line_rec.stub_days > 0 AND l_cfl_line_rec.stub_amount IS NULL ) OR
	    	  ( l_cfl_line_rec.number_of_periods > 0 AND l_cfl_line_rec.amount IS NULL ))THEN
			   l_missing_pmts := l_missing_pmts + 1;
	       END IF;
	    END LOOP;

	    IF (l_missing_pmts <> 1) THEN
	      i:=x_qa_result_tbl.COUNT;
		  i:=i+1;
		  x_qa_result_tbl(i).check_code:='check_payments';
		  x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
		  x_qa_result_tbl(i).result_code:='ERROR';
		  x_qa_result_tbl(i).result_meaning:='ERROR';
		  x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_MISS_PAY_ERROR';
		  x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_MISS_PAY_ERROR');
		  x_qa_result := okl_api.G_RET_STS_ERROR;
		END IF;
	    IF(l_cfl_count <= 1) THEN
	         i:=x_qa_result_tbl.COUNT;
		     i:=i+1;
		     x_qa_result_tbl(i).check_code:='check_payments';
		     x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
		     x_qa_result_tbl(i).result_code:='ERROR';
		     x_qa_result_tbl(i).result_meaning:='ERROR';
		     x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_QTE_PAY_ERROR';
		     x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_QTE_PAY_ERROR');
		     x_qa_result := okl_api.G_RET_STS_ERROR;
		END IF;
		IF(( lp_lq_header_rec.RATE_TEMPLATE_ID IS NULL)) THEN
		     i:=x_qa_result_tbl.COUNT;
		     i:=i+1;
		     x_qa_result_tbl(i).check_code:='check_payments';
		     x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_FOR_QUOTE';
		     x_qa_result_tbl(i).result_code:='ERROR';
		     x_qa_result_tbl(i).result_meaning:='ERROR';
		     x_qa_result_tbl(i).message_code:= 'OKL_QA_SRT_NOT_FOUND';
		     x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SRT_NOT_FOUND');
		     x_qa_result := okl_api.G_RET_STS_ERROR;
		  END IF;
     ELSIF((lp_lq_header_rec.pricing_method ='SM') AND
	       NVL(lp_lq_header_rec.structured_pricing,'N')='Y') THEN
	       FOR l_cfl_line_rec IN c_lq_cfl_line(lp_quote_id ,'LEASE_QUOTE') LOOP
	           l_cfl_count := l_cfl_count + 1;
		       IF ((l_cfl_line_rec.stub_days > 0 AND l_cfl_line_rec.stub_amount IS NULL ) OR
	              ( l_cfl_line_rec.number_of_periods > 0 AND l_cfl_line_rec.amount IS NULL ))THEN
    		      l_missing_pmts := l_missing_pmts + 1;
	           END IF;
	       END LOOP;
           IF (l_missing_pmts <> 1) THEN
	            i:=x_qa_result_tbl.COUNT;
		        i:=i+1;
		        x_qa_result_tbl(i).check_code:='check_payments';
		        x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
		        x_qa_result_tbl(i).result_code:='ERROR';
		        x_qa_result_tbl(i).result_meaning:='ERROR';
		        x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_MISS_PAY_ERROR';
		        x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_MISS_PAY_ERROR');
		        x_qa_result := okl_api.G_RET_STS_ERROR;
	       END IF;
	       IF (l_cfl_count <= 1) THEN
	             i:=x_qa_result_tbl.COUNT;
		         i:=i+1;
		         x_qa_result_tbl(i).check_code:='check_payments';
		         x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
		         x_qa_result_tbl(i).result_code:='ERROR';
		         x_qa_result_tbl(i).result_meaning:='ERROR';
		         x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_QTE_PAY_ERROR';
		         x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_QTE_PAY_ERROR');
		         x_qa_result := okl_api.G_RET_STS_ERROR;
		   END IF;
      END IF;--
    END IF;--l_are_all_lines_overriden='N'

    --Check For Asset Level
    IF(( NVL(lp_lq_header_rec.line_level_pricing , 'N') ='Y') AND--Main Loop Start
       ( lp_lq_header_rec.pricing_method ='SM')) THEN
       l_missing_pmts := 0;
       l_cfl_count := 0;
       l_no_missing_rate := FALSE;
       FOR configuration_asset_rec IN c_configuration_asset_rec(lp_quote_id) LOOP
           IF ( NVL(configuration_asset_rec.STRUCTURED_PRICING, 'N') <> 'N')THEN
                 l_missing_pmts := 0;
                 l_cfl_count := 0;
                 l_no_missing_rate := FALSE;
                 l_no_missing_rate_count := 0;
                 FOR l_cfl_line_rec IN c_lq_cfl_line(configuration_asset_rec.id ,configuration_asset_rec.oty_code) LOOP
                     l_cfl_count := l_cfl_count + 1;
                     IF ((l_cfl_line_rec.stub_days > 0 AND l_cfl_line_rec.stub_amount IS NULL ) OR
                         (l_cfl_line_rec.number_of_periods > 0 AND l_cfl_line_rec.amount IS NULL )) THEN
                          l_missing_pmts := l_missing_pmts + 1;
                     END IF;
                     IF( l_cfl_line_rec.rate IS NOT NULL ) THEN
                         l_no_missing_rate := TRUE;
                         l_no_missing_rate_count := l_no_missing_rate_count + 1;
                     END IF;
                 END LOOP;

                 IF (l_missing_pmts = 0 AND l_no_missing_rate) THEN
                     i:=x_qa_result_tbl.COUNT;
                   i:=i+1;
                   x_qa_result_tbl(i).check_code:='check_payments';
                   x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_FOR_QUOTE';
                   x_qa_result_tbl(i).result_code:='ERROR';
                   x_qa_result_tbl(i).result_meaning:='ERROR';
                   x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_QTE_RATE_ERROR';
                   x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_QTE_RATE_ERROR');
                   x_qa_result := okl_api.G_RET_STS_ERROR;
                     EXIT;
                 ELSIF(l_missing_pmts > 1) THEN
                       i:=x_qa_result_tbl.COUNT;
                     i:=i+1;
                     x_qa_result_tbl(i).check_code:='check_payments';
                     x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
                     x_qa_result_tbl(i).result_code:='ERROR';
                     x_qa_result_tbl(i).result_meaning:='ERROR';
                     x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_MISS_PAY_ERROR';
                     x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_MISS_PAY_ERROR');
                     x_qa_result := okl_api.G_RET_STS_ERROR;
                       EXIT;
                 ELSIF(l_missing_pmts > 0 AND (l_cfl_count <> l_no_missing_rate_count)) THEN
                     i:=x_qa_result_tbl.COUNT;
                     i:=i+1;
                     x_qa_result_tbl(i).check_code:='check_payments';
                     x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
                     x_qa_result_tbl(i).result_code:='ERROR';
                     x_qa_result_tbl(i).result_meaning:='ERROR';
                     x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_MISS_PAY_ERROR';
                     x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_MISS_RATE_ERROR');
                     x_qa_result := okl_api.G_RET_STS_ERROR;
                     EXIT;
                 END IF;
                 l_total_missing_pmts := l_total_missing_pmts + l_missing_pmts;
                 l_total_cfl_count := l_total_cfl_count + l_cfl_count;

          ELSIF( NVL(configuration_asset_rec.structured_pricing , 'N') ='N')THEN
                IF((configuration_asset_rec.RATE_TEMPLATE_ID IS NULL) AND
                   (lp_lq_header_rec.RATE_TEMPLATE_ID IS NULL AND l_no_qte_payment))
                THEN
                i:=x_qa_result_tbl.COUNT;
                i:=i+1;
                x_qa_result_tbl(i).check_code:='check_fees_and_services';
                x_qa_result_tbl(i).check_meaning:='PRICING_NOT_DONE_FOR_LINE ';
                x_qa_result_tbl(i).result_code:='ERROR';
                x_qa_result_tbl(i).result_meaning:='ERROR';
                x_qa_result_tbl(i).message_code:= 'OKL_QA_SRT_NOT_FOUND';
                x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SRT_NOT_FOUND');
                x_qa_result := okl_api.G_RET_STS_ERROR;
                EXIT;
              END IF;
              l_missing_pmts := 0;
              l_cfl_count := 0;
              l_no_missing_rate := FALSE;
              FOR l_cfl_line_rec IN c_lq_cfl_line(configuration_asset_rec.id ,configuration_asset_rec.oty_code) LOOP
                  l_cfl_count := l_cfl_count + 1;
                  IF ((l_cfl_line_rec.stub_days > 0 AND l_cfl_line_rec.stub_amount IS NULL ) OR
                      (l_cfl_line_rec.number_of_periods > 0 AND l_cfl_line_rec.amount IS NULL )) THEN
                      l_missing_pmts := l_missing_pmts + 1;
                  END IF;
                  IF(l_cfl_line_rec.rate IS NOT NULL ) THEN
                      l_no_missing_rate := TRUE;
                  END IF;
              END LOOP;

              IF (l_missing_pmts = 0 AND l_no_missing_rate) THEN
                   i:=x_qa_result_tbl.COUNT;
                   i:=i+1;
                   x_qa_result_tbl(i).check_code:='check_payments';
                   x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_FOR_QUOTE';
                   x_qa_result_tbl(i).result_code:='ERROR';
                   x_qa_result_tbl(i).result_meaning:='ERROR';
                   x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_QTE_RATE_ERROR';
                   x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_QTE_RATE_ERROR');
                   x_qa_result := okl_api.G_RET_STS_ERROR;
                     EXIT;
               ELSIF(l_missing_pmts > 1) THEN
                   i:=x_qa_result_tbl.COUNT;
                   i:=i+1;
                   x_qa_result_tbl(i).check_code:='check_payments';
                   x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
                   x_qa_result_tbl(i).result_code:='ERROR';
                   x_qa_result_tbl(i).result_meaning:='ERROR';
                   x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_MISS_PAY_ERROR';
                   x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_MISS_PAY_ERROR');
                   x_qa_result := okl_api.G_RET_STS_ERROR;
                   EXIT;
               END IF;

        END IF;
        l_total_missing_pmts := l_total_missing_pmts + l_missing_pmts;
        l_total_cfl_count := l_total_cfl_count + l_cfl_count;
      END LOOP;
      IF(l_total_cfl_count <= 1 and l_total_missing_pmts <> 0 ) THEN
         i:=x_qa_result_tbl.COUNT;
         i:=i+1;
         x_qa_result_tbl(i).check_code:='check_payments';
         x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
         x_qa_result_tbl(i).result_code:='ERROR';
		 x_qa_result_tbl(i).result_meaning:='ERROR';
		 x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_CONFIG_PAY_ERROR';
         x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_CONFIG_PAY_ERROR');
         x_qa_result := okl_api.G_RET_STS_ERROR;

      END IF;
  END IF;
--Bug # 5036739 ssdeshpa end */
-------------------------------------------------------------------------------

 -------------------------------------------------------------------------------
 --Bug # 5070686 ssdeshpa start
 /**Quote Level should only apply to configuration lines that are leasing Assets.
    Quote Level Payments should be distributed among Asset Lines only.
    Rollover and Finance Fees always require line level payments, even if Lines
    Override box is unchecked.  Exception to this rule are in Target Rate and
    Solve for Payment Pricing Method, where payments are not required as inputs
    and where a quote level (other than a line level) Interest Rate can be used
    to calculate line level payments for Financed and Rollover Fees.

 **/
   IF(lp_lq_header_rec.pricing_method NOT IN('SP','TR','SM','RC')) THEN
      FOR configuration_fee_rec IN c_configuration_fee_rec(lp_quote_id) LOOP
        IF((NVL(configuration_fee_rec.STRUCTURED_PRICING, 'N') = 'N')) THEN
           -- validate srt, arrears, and pa(not for SP) from lp_lq_header_rec
           validate_payment_options(configuration_fee_rec.RATE_TEMPLATE_ID
                                   ,configuration_fee_rec.target_arrears
                                   ,lp_lq_header_rec.PRICING_METHOD
                                   ,configuration_fee_rec.TARGET_AMOUNT
                                   ,x_qa_result_tbl
                                   ,x_return_status);
        ELSIF((NVL(configuration_fee_rec.STRUCTURED_PRICING, 'N') = 'Y')) THEN
            --validate LEASE_QUOTE cash flows for presence of
            --payment type , arrears, freq and cash flow level > 0
            validate_cashflows(configuration_fee_rec.ID
                              ,'QUOTED_FEE'
                              ,lp_lq_header_rec.PRICING_METHOD
                              ,x_qa_result_tbl
                              ,x_return_status);
        END IF;
      END LOOP;
   END IF;
   -----------------------------------------------------------------------------
   --Checking config Fees for Pricing Method='SM'
   IF(lp_lq_header_rec.pricing_method = 'SM') THEN
      l_total_missing_pmts :=0;
      l_total_cfl_count:=0;
      l_missing_pmts := 0;
	  l_cfl_count := 0;
	  l_no_missing_rate := FALSE;
      FOR configuration_fee_rec IN c_configuration_fee_rec(lp_quote_id) LOOP
        --Count toatal no Fin. or Rollover Fees
        l_fees_count := l_fees_count + 1;
        IF((NVL(configuration_fee_rec.STRUCTURED_PRICING, 'N') = 'Y')) THEN
           l_missing_pmts := 0;
		   l_cfl_count := 0;
		   l_no_missing_rate := FALSE;
		   l_no_missing_rate_count := 0;
		   FOR l_cfl_line_rec IN c_lq_cfl_line(configuration_fee_rec.id ,configuration_fee_rec.oty_code)
           LOOP
		       l_cfl_count := l_cfl_count + 1;
		       IF ((l_cfl_line_rec.stub_days > 0 AND l_cfl_line_rec.stub_amount IS NULL ) OR
		           (l_cfl_line_rec.number_of_periods > 0 AND l_cfl_line_rec.amount IS NULL )) THEN
		           l_missing_pmts := l_missing_pmts + 1;
		       END IF;
		       IF(l_cfl_line_rec.rate IS NOT NULL ) THEN
		          l_no_missing_rate := TRUE;
		          l_no_missing_rate_count := l_no_missing_rate_count + 1;
		       END IF;
		   END LOOP;
           IF (l_missing_pmts = 0 AND l_no_missing_rate) THEN
		       i:=x_qa_result_tbl.COUNT;
		  	   i:=i+1;
		  	   x_qa_result_tbl(i).check_code:='check_payments';
		  	   x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_FOR_QUOTE';
		  	   x_qa_result_tbl(i).result_code:='ERROR';
		  	   x_qa_result_tbl(i).result_meaning:='ERROR';
		  	   x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_QTE_RATE_ERROR';
		  	   x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_QTE_RATE_ERROR');
		  	   x_qa_result := okl_api.G_RET_STS_ERROR;
		       EXIT;
		     ELSIF(l_missing_pmts > 1) THEN
		       i:=x_qa_result_tbl.COUNT;
		       i:=i+1;
		       x_qa_result_tbl(i).check_code:='check_payments';
		       x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
		       x_qa_result_tbl(i).result_code:='ERROR';
		       x_qa_result_tbl(i).result_meaning:='ERROR';
		       x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_MISS_PAY_ERROR';
		       x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_MISS_PAY_ERROR');
		       x_qa_result := okl_api.G_RET_STS_ERROR;
		       EXIT;
		   ELSIF(l_missing_pmts > 0 AND (l_cfl_count <> l_no_missing_rate_count)) THEN
               i:=x_qa_result_tbl.COUNT;
		       i:=i+1;
		       x_qa_result_tbl(i).check_code:='check_payments';
		       x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
		       x_qa_result_tbl(i).result_code:='ERROR';
		       x_qa_result_tbl(i).result_meaning:='ERROR';
		       x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_MISS_PAY_ERROR';
		       x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_MISS_RATE_ERROR');
		       x_qa_result := okl_api.G_RET_STS_ERROR;
               EXIT;
            /*ELSIF(l_missing_pmts > 0 AND (l_cfl_count = 1)) THEN
               i:=x_qa_result_tbl.COUNT;
		       i:=i+1;
		       x_qa_result_tbl(i).check_code:='check_payments';
		       x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
		       x_qa_result_tbl(i).result_code:='ERROR';
		       x_qa_result_tbl(i).result_meaning:='ERROR';
		       x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_CONFIG_PAY_ERROR';
		       x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_CONFIG_PAY_ERROR');
		       x_qa_result := okl_api.G_RET_STS_ERROR;
               EXIT;*/
		   END IF;
		   l_total_missing_pmts := l_total_missing_pmts + l_missing_pmts;
		   l_total_cfl_count := l_total_cfl_count + l_cfl_count;

         ELSIF( NVL(configuration_fee_rec.structured_pricing , 'N') ='N')THEN
               /* IF(configuration_fee_rec.RATE_TEMPLATE_ID IS NULL)THEN
		  		   i:=x_qa_result_tbl.COUNT;
		  		   i:=i+1;
		  		   x_qa_result_tbl(i).check_code:='check_fees_and_services';
		  		   x_qa_result_tbl(i).check_meaning:='PRICING_NOT_DONE_FOR_LINE ';
		  		   x_qa_result_tbl(i).result_code:='ERROR';
		  		   x_qa_result_tbl(i).result_meaning:='ERROR';
		  		   x_qa_result_tbl(i).message_code:= 'OKL_QA_SRT_NOT_FOUND';
		  		   x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SRT_NOT_FOUND');
		  		   x_qa_result := okl_api.G_RET_STS_ERROR;
		  		   EXIT;
		  		END IF; */
		  		l_missing_pmts := 0;
		        l_cfl_count := 0;
		        l_no_missing_rate := FALSE;
                FOR l_cfl_line_rec IN c_lq_cfl_line(configuration_fee_rec.id ,configuration_fee_rec.oty_code) LOOP
                    l_cfl_count := l_cfl_count + 1;
                    IF ((l_cfl_line_rec.stub_days > 0 AND l_cfl_line_rec.stub_amount IS NULL ) OR
                        (l_cfl_line_rec.number_of_periods > 0 AND l_cfl_line_rec.amount IS NULL )) THEN
                        l_missing_pmts := l_missing_pmts + 1;
                    END IF;
                    IF(l_cfl_line_rec.rate IS NOT NULL ) THEN
                       l_no_missing_rate := TRUE;
		            END IF;
		        END LOOP;
                IF (l_missing_pmts = 0 AND l_no_missing_rate) THEN
		            i:=x_qa_result_tbl.COUNT;
		  		    i:=i+1;
		  		    x_qa_result_tbl(i).check_code:='check_payments';
		  		    x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_FOR_QUOTE';
		  		    x_qa_result_tbl(i).result_code:='ERROR';
		  		    x_qa_result_tbl(i).result_meaning:='ERROR';
		  		    x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_QTE_RATE_ERROR';
		  		  	x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_QTE_RATE_ERROR');
		  		  	x_qa_result := okl_api.G_RET_STS_ERROR;
		            EXIT;
		         ELSIF(l_missing_pmts > 1) THEN
		              i:=x_qa_result_tbl.COUNT;
		  		      i:=i+1;
		  		      x_qa_result_tbl(i).check_code:='check_payments';
		  		      x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
		  		      x_qa_result_tbl(i).result_code:='ERROR';
		  		      x_qa_result_tbl(i).result_meaning:='ERROR';
		  		  	  x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_MISS_PAY_ERROR';
		  		  	  x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_MISS_PAY_ERROR');
		  		  	  x_qa_result := okl_api.G_RET_STS_ERROR;
		              EXIT;
		          --For line level override, if SRT is entered at the asset level, and no
                  --missing payment is defined, There should be an error stating that the
                  --SRT should be removed, as no missing payment is defined and vice-versa.
	             ELSIF(l_missing_pmts > 0 AND configuration_fee_rec.RATE_TEMPLATE_ID IS NULL ) THEN
            	       i:=x_qa_result_tbl.COUNT;
            	       i:=i+1;
            	       x_qa_result_tbl(i).check_code:='check_payments';
            	       x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
            	       x_qa_result_tbl(i).result_code:='ERROR';
            	       x_qa_result_tbl(i).result_meaning:='ERROR';
            	       x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_FEE_SRT_REQ';
                       set_fnd_message( p_msg_name  =>  'OKL_QA_SM_FEE_SRT_REQ'
                                        ,p_token1    => 'NAME'
                                        ,p_value1    =>  configuration_fee_rec.name
                                        ,p_token2    =>  NULL
                                        ,p_value2    =>  NULL
                                        ,p_token3    =>  NULL
                                        ,p_value3    =>  NULL
                                        ,p_token4    =>  NULL
                                        ,p_value4    =>  NULL);
                       x_qa_result_tbl(i).message_text:= fnd_message.get;
            	       x_qa_result := okl_api.G_RET_STS_ERROR;

	             ELSIF(l_missing_pmts = 0 AND configuration_fee_rec.RATE_TEMPLATE_ID IS NOT NULL) THEN
                   i:=x_qa_result_tbl.COUNT;
                   i:=i+1;
                   x_qa_result_tbl(i).check_code:='check_payments';
                   x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
                   x_qa_result_tbl(i).result_code:='ERROR';
                   x_qa_result_tbl(i).result_meaning:='ERROR';
                   x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_FEE_SRT_FOUND';
                   set_fnd_message( p_msg_name  =>  'OKL_QA_SM_FEE_SRT_FOUND'
                                    ,p_token1    => 'NAME'
                                    ,p_value1    =>  configuration_fee_rec.name
                                    ,p_token2    =>  NULL
                                    ,p_value2    =>  NULL
                                    ,p_token3    =>  NULL
                                    ,p_value3    =>  NULL
                                    ,p_token4    =>  NULL
                                    ,p_value4    =>  NULL);
                   x_qa_result_tbl(i).message_text:= fnd_message.get;
                   x_qa_result := okl_api.G_RET_STS_ERROR;

                 END IF;
                 l_total_missing_pmts := l_total_missing_pmts + l_missing_pmts;
		         l_total_cfl_count := l_total_cfl_count + l_cfl_count;
             END IF;

          END LOOP;--For each config fees
          --check only if There are Fin. or Rollover Fees
          IF(l_fees_count > 0 AND l_total_missing_pmts = 0) THEN
             i:=x_qa_result_tbl.COUNT;
        	 i:=i+1;
        	 x_qa_result_tbl(i).check_code:='check_payments';
        	 x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
        	 x_qa_result_tbl(i).result_code:='ERROR';
        	 x_qa_result_tbl(i).result_meaning:='ERROR';
        	 x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_MISS_PAY_ERROR';
        	 x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_MISS_PAY_ERROR');
        	 x_qa_result := okl_api.G_RET_STS_ERROR;
          END IF;
          IF(l_fees_count > 0 AND l_total_missing_pmts > 0 AND (l_total_cfl_count = 1)) THEN
                   i:=x_qa_result_tbl.COUNT;
    		       i:=i+1;
    		       x_qa_result_tbl(i).check_code:='check_payments';
    		       x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
    		       x_qa_result_tbl(i).result_code:='ERROR';
    		       x_qa_result_tbl(i).result_meaning:='ERROR';
    		       x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_CONFIG_PAY_ERROR';
    		       x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_CONFIG_PAY_ERROR');
    		       x_qa_result := okl_api.G_RET_STS_ERROR;
           END IF;

		/*  IF(l_fees_count > 0 AND l_total_cfl_count <= 1 and l_total_missing_pmts <> 0 ) THEN
		     i:=x_qa_result_tbl.COUNT;
		     i:=i+1;
			 x_qa_result_tbl(i).check_code:='check_payments';
			 x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_NOT_FOUND';
			 x_qa_result_tbl(i).result_code:='ERROR';
			 x_qa_result_tbl(i).result_meaning:='ERROR';
			 x_qa_result_tbl(i).message_code:= 'OKL_QA_SM_CONFIG_PAY_ERROR';
			 x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_SM_CONFIG_PAY_ERROR');
			 x_qa_result := okl_api.G_RET_STS_ERROR;
		  END IF;*/
        END IF;

       --Bug # 5070686 ssdeshpa end;
 -------------------------------------------------------------------------------
      --Any Payment should not have start date earlier than the Quote Expected Start Date
       select TRUNC(EXPECTED_START_DATE) INTO lp_cont_start_date
       from OKL_LEASE_QUOTES_B
       WHERE ID=lp_quote_id;
      ---Check for the VPA Effective Dates Fall within the Expected Start Date
       IF(lp_vp_id IS NOT NULL) THEN
         OPEN c_vp_rec(lp_vp_id ,lp_cont_start_date);
         FETCH c_vp_rec INTO x;
         CLOSE c_vp_rec;
         IF(nvl(x,'y') <>'x') THEN
            i:=x_qa_result_tbl.COUNT;
            i:=i+1;
            x_qa_result_tbl(i).check_code:='check_quote_values';
            x_qa_result_tbl(i).check_meaning:='VENDOR_PROGRAM_AGRREMENT_IS_INVALID';
            x_qa_result_tbl(i).result_code:='ERROR';
            x_qa_result_tbl(i).result_meaning:='ERROR';
            x_qa_result_tbl(i).message_code:= 'OKL_QA_VPA_INVALID_DATES';
            x_qa_result_tbl(i).message_text:= get_msg_text('OKL_QA_VPA_INVALID_DATES');
            x_qa_result := okl_api.G_RET_STS_ERROR;
          END IF;
       END IF;
   END IF;--End OF LQ

   IF(p_object_type='QUICKQUOTE') THEN
     --Check Payment For SFFA,SFY and SFS Methods
     SELECT count(1) INTO l_cnt
     from OKL_QUICK_QUOTES_B
     WHERE ID=lp_quote_id
     AND   PRICING_METHOD IN('SF','SS','SY');
     IF(l_cnt >= 1) THEN
        OPEN c_lq_cfl_line(lp_quote_id ,'QUICK_QUOTE');
        FETCH c_lq_cfl_line INTO lp_lq_cfl_line;
        WHILE c_lq_cfl_line%FOUND
        LOOP
        ---Clarify what is mean by Number;
	    -- schodava: Modified If condition to cater to stub payments
             IF(lp_lq_cfl_line.amount IS NULL OR lp_lq_cfl_line.number_of_periods IS NULL)
             AND (lp_lq_cfl_line.stub_days IS NULL OR lp_lq_cfl_line.stub_amount IS NULL)THEN
                  i:=x_qa_result_tbl.COUNT;
                  i:=i+1;
                  x_qa_result_tbl(i).check_code:='check_payments';
                  x_qa_result_tbl(i).check_meaning:='MISSING_PAYMENT_LEVEL_FOR_QUOTE';
                  x_qa_result_tbl(i).result_code:='ERROR';
                  x_qa_result_tbl(i).result_meaning:='ERROR';
                  x_qa_result_tbl(i).message_code:= 'OKL_QA_MISSING_PAY_LEVEL';
                  x_qa_result_tbl(i).message_text:=get_msg_text('OKL_QA_MISSING_PAY_LEVEL');
                  x_qa_result := okl_api.G_RET_STS_ERROR;
                  EXIT;
             END IF;
             FETCH c_lq_cfl_line INTO lp_lq_cfl_line;
         END LOOP;
         CLOSE c_lq_cfl_line;

      END IF;

      SELECT TRUNC(EXPECTED_START_DATE) INTO lp_cont_start_date
      FROM OKL_QUICK_QUOTES_B
      WHERE ID=lp_quote_id;

      ---Check for the VPA Effective Dates Fall within the Expected Start Date
       select TRUNC(EXPECTED_START_DATE),PROGRAM_AGREEMENT_ID INTO lp_cont_start_date,lp_vp_id
       from OKL_QUICK_QUOTES_B
       WHERE ID=lp_quote_id;

       IF(lp_vp_id IS NOT NULL) THEN
          OPEN c_vp_rec(lp_vp_id ,lp_cont_start_date);
          FETCH c_vp_rec INTO x;
          CLOSE c_vp_rec;
          IF(nvl(x,'y') <>'x') THEN
            i:=x_qa_result_tbl.COUNT;
            i:=i+1;
            x_qa_result_tbl(i).check_code:='check_quote_values';
            x_qa_result_tbl(i).check_meaning:='VENDOR_PROGRAM_AGRREMENT_IS_INVALID';
            x_qa_result_tbl(i).result_code:='ERROR';
            x_qa_result_tbl(i).result_meaning:='ERROR';
            x_qa_result_tbl(i).message_code:= 'OKL_QA_VPA_INVALID_DATES';
            x_qa_result_tbl(i).message_text:= get_msg_text('OKL_QA_VPA_INVALID_DATES');
            x_qa_result := okl_api.G_RET_STS_ERROR;
          END IF;
       END IF;

     END IF;--End OF QQ
   END IF;--Quote id Not null

   okl_api.end_activity(x_msg_count => x_msg_count
            		    ,x_msg_data  => x_msg_data);

   IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
    			    ,l_module
    			    ,'end debug okl_sales_quote_qa_pvt call check_payment');
   END IF;

   EXCEPTION
    WHEN okl_api.g_exception_error THEN
       x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
    					       ,p_pkg_name  =>G_PKG_NAME
    					       ,p_exc_name  =>'OKL_API.G_RET_STS_ERROR'
    					       ,x_msg_count =>x_msg_count
    					       ,x_msg_data  =>x_msg_data
    					       ,p_api_type  =>G_API_TYPE);
     WHEN okl_api.g_exception_unexpected_error THEN
       x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
    					       ,p_pkg_name  =>G_PKG_NAME
    					       ,p_exc_name  =>'OKL_API.G_RET_STS_UNEXP_ERROR'
    					       ,x_msg_count =>x_msg_count
    					       ,x_msg_data  =>x_msg_data
    					       ,p_api_type  =>G_API_TYPE);
     WHEN OTHERS THEN
       x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
    					       ,p_pkg_name  =>G_PKG_NAME
    					       ,p_exc_name  =>'OTHERS'
    					       ,x_msg_count =>x_msg_count
    					       ,x_msg_data  =>x_msg_data
    					       ,p_api_type  =>G_API_TYPE);
 END check_payments;
/*------------------------------------------------------------------------------
    -- PROCEDURE run_qa_checker
  ------------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name   : run_qa_checker
    -- Description      : This procedure will be called as a wrapper by Lease
                          Quote and Lease App For QA Validation run_qa_checker3

    -- Business Rules  : This procedure will validate the Lease Quote and Quick
                         Quote for General ,Configuration, Pricing parameters
    --
    -- Parameters      : p_object_id   -- Lease Quote /Lease App Id.

                         p_object_type -- valid values are  'LEASEQUOTE'/'LEASEAPP'
                         hold which type of object this method is calling

                         x_qa_result_tbl --> Hold all the QA Results for Object

    -- Version         : 1.1
    -- History         :
    -- End of comments
------------------------------------------------------------------------------*/
  PROCEDURE run_qa_checker (p_api_version                  IN NUMBER
                           ,p_init_msg_list                IN VARCHAR2
                           ,p_object_type                  IN VARCHAR2
                           ,p_object_id                    IN NUMBER
                           ,x_return_status                OUT NOCOPY VARCHAR2
                           ,x_msg_count                    OUT NOCOPY NUMBER
                           ,x_msg_data                     OUT NOCOPY VARCHAR2
                           ,x_qa_result_tbl                OUT NOCOPY OKL_SALES_QUOTE_QA_PVT.qa_results_tbl_type) IS
       l_program_name      CONSTANT VARCHAR2(30) := 'run_qa';
       l_api_name          CONSTANT VARCHAR2(61) := l_program_name;
       i                   INTEGER;
       l_module            CONSTANT fnd_log_messages.module%TYPE := 'SALE_QA_PVT';
       l_debug_enabled                varchar2(10);
       is_debug_procedure_on          boolean;
       is_debug_statement_on          boolean;

       l_qa_results_tbl               qa_results_tbl_type;
       lp_quote_id                    NUMBER; --Fix for bug #4735811
       lp_object_type                 VARCHAR2(20);
       x_qa_result           VARCHAR2(3);
       b_tax_call BOOLEAN := TRUE;--Added for bug # 5647107
       --Added Bug # 5647107 ssdeshpa start
       CURSOR  l_systemparams_csr IS
       SELECT NVL(tax_upfront_yn,'N')
       FROM   OKL_SYSTEM_PARAMS;

        l_ou_tax_upfront_yn VARCHAR2(1);
        --Added Bug # 5647107 ssdeshpa end

       CURSOR c_get_lq_rec(p_parent_object_id NUMBER,
                    p_object_type VARCHAR2) IS
         SELECT OLQ.ID
         FROM OKL_LEASE_QUOTES_B OLQ
         WHERE PARENT_OBJECT_ID=p_parent_object_id
         AND   PARENT_OBJECT_CODE=p_object_type
         AND   PRIMARY_QUOTE='Y';

       BEGIN
       l_debug_enabled := okl_debug_pub.check_log_enabled;
       is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                           ,fnd_log.level_procedure);


       IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
         okl_debug_pub.log_debug(fnd_log.level_procedure
                                ,l_module
                                ,'begin debug OKLRQQCB.pls call run_qa3');
       END IF;  -- check for logging on STATEMENT level
       is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                          ,fnd_log.level_statement);
       -- call START_ACTIVITY to create savepoint, check compatibility
       -- and initialize message list

       x_return_status := okl_api.start_activity(p_api_name=>l_api_name
                                                ,p_pkg_name=>G_PKG_NAME
                                                ,p_init_msg_list=>p_init_msg_list
                                                ,p_api_version=>p_api_version
                                                ,l_api_version=>p_api_version
                                                ,p_api_type=>G_API_TYPE
                                                ,x_return_status=>x_return_status);
       -- check if activity started successfully

       IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
       ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
       END IF;

    ---------------Check for Valid Parent Object type----------------------

    --Fix Bug no 4735811 Start
    --Validation Tab Showing the Older values for Validation Results in case of
    --Lease Application.
    --Get Lease Quote Id for Lease Application which is havinf Primary Quote as
    -- 'Y'
    lp_object_type := p_object_type;
    lp_quote_id := p_object_id;
    IF(p_object_type='LEASEAPP' OR p_object_type='LEASEOPP') THEN
        OPEN c_get_lq_rec(p_parent_object_id => p_object_id,
                          p_object_type => p_object_type);
        FETCH c_get_lq_rec INTO lp_quote_id;
        CLOSE c_get_lq_rec;
        lp_object_type :='LEASEQUOTE';
    END IF;

    --Delete Validation Results
    DELETE OKL_VALIDATION_RESULTS_TL
    WHERE  ID IN (SELECT  ID
                 FROM  OKL_VALIDATION_RESULTS_B
                 WHERE PARENT_OBJECT_CODE = lp_object_type
                 AND   PARENT_OBJECT_ID = lp_quote_id);

    DELETE OKL_VALIDATION_RESULTS_B
    WHERE PARENT_OBJECT_CODE = lp_object_type
    AND   PARENT_OBJECT_ID = lp_quote_id;
    --Fix Bug no 4735811 End

    -------QA Checker Starts
    --Check System Validation Set Validations
    x_qa_result := OKL_API.G_RET_STS_SUCCESS;
    validate_system_validations(p_api_version    => p_api_version,
                                p_init_msg_list  => G_FALSE,
                                p_object_id      => lp_quote_id,
                                p_object_type    => lp_object_type,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                x_qa_result_tbl => l_qa_results_tbl,
                                x_qa_result      => x_qa_result);
    IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
    ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
    END IF;
    IF(x_qa_result= OKL_API.G_RET_STS_SUCCESS) THEN
        i:=l_qa_results_tbl.COUNT;
        i:=i+1;
        l_qa_results_tbl(i).check_code:='check_fees_and_services';
        l_qa_results_tbl(i).check_meaning:='check_fees_and_services';
        l_qa_results_tbl(i).result_code:='SUCCESS';
        l_qa_results_tbl(i).result_meaning:='Passed';
        l_qa_results_tbl(i).message_code:= 'OKL_QA_CHK_VLS';
        l_qa_results_tbl(i).message_text:= get_msg_text('OKL_QA_CHK_VLS');
    END IF;
    --Check misc/extended validations
    x_qa_result := OKL_API.G_RET_STS_SUCCESS;
    extended_validations(p_api_version    => p_api_version,
                         p_init_msg_list  => G_FALSE,
                         p_object_id      => lp_quote_id,
                         p_object_type    => lp_object_type,
                         x_return_status  => x_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         x_qa_result_tbl => l_qa_results_tbl,
                         x_qa_result      => x_qa_result);
    IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
    ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
    END IF;
    IF(x_qa_result = OKL_API.G_RET_STS_SUCCESS) THEN
       i:=l_qa_results_tbl.COUNT;
       i:=i+1;
       l_qa_results_tbl(i).check_code:='extended_validation';
       l_qa_results_tbl(i).check_meaning:='extended_validation';
       l_qa_results_tbl(i).result_code:='SUCCESS';
       l_qa_results_tbl(i).result_meaning:='Passed';
       l_qa_results_tbl(i).message_code:= 'OKL_QA_CHK_QUOTE_EXTN';
       l_qa_results_tbl(i).message_text:= get_msg_text('OKL_QA_CHK_QUOTE_EXTN');
    END IF;
    --check Quote Configuration
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    check_configuration(p_api_version    => p_api_version,
                        p_init_msg_list  => G_FALSE,
                        p_object_id      => lp_quote_id,
                        p_object_type    => lp_object_type,
                        x_return_status  => x_return_status,
                        x_msg_count      => x_msg_count,
                        x_msg_data       => x_msg_data,
                        x_qa_result_tbl => l_qa_results_tbl,
                        x_qa_result      => x_qa_result);

    IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
    ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
    END IF;

    IF(x_qa_result = OKL_API.G_RET_STS_SUCCESS) THEN
       i:=l_qa_results_tbl.COUNT;
       i:=i+1;
       l_qa_results_tbl(i).check_code:='check_configuration';
       l_qa_results_tbl(i).check_meaning:='check_configuration';
       l_qa_results_tbl(i).result_code:='SUCCESS';
       l_qa_results_tbl(i).result_meaning:='Passed';
       l_qa_results_tbl(i).message_code:= 'OKL_QA_CHK_QUOTE_CONFIG';
       l_qa_results_tbl(i).message_text:= get_msg_text('OKL_QA_CHK_QUOTE_CONFIG');
     END IF;
     --check fees/services for quote
     x_qa_result := OKL_API.G_RET_STS_SUCCESS;
     check_fees_and_services(p_api_version    => p_api_version,
                             p_init_msg_list  => G_FALSE,
                             p_object_id      => lp_quote_id,
                             p_object_type    => lp_object_type,
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             x_qa_result_tbl => l_qa_results_tbl,
                             x_qa_result      => x_qa_result);

     IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
    ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
    END IF;

    IF(x_qa_result = OKL_API.G_RET_STS_SUCCESS) THEN
        i:=l_qa_results_tbl.COUNT;
        i:=i+1;
        l_qa_results_tbl(i).check_code:='check_fees_and_services';
        l_qa_results_tbl(i).check_meaning:='check_fees_and_services';
        l_qa_results_tbl(i).result_code:='SUCCESS';
        l_qa_results_tbl(i).result_meaning:='Passed';
        l_qa_results_tbl(i).message_code:= 'OKL_QA_CHK_FEE_SERVICE';
        l_qa_results_tbl(i).message_text:= get_msg_text('OKL_QA_CHK_FEE_SERVICE');
    END IF;
     --Check for cost adjustment for Quote
     x_qa_result := OKL_API.G_RET_STS_SUCCESS;
     validate_cost_adjustments(p_api_version    => p_api_version,
                               p_init_msg_list  => G_FALSE,
                               p_object_id      => lp_quote_id,
                               p_object_type    => lp_object_type,
                               x_return_status  => x_return_status,
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data,
                               x_qa_result_tbl => l_qa_results_tbl,
                               x_qa_result      => x_qa_result);
     IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
     ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
     END IF;
     IF(x_qa_result = OKL_API.G_RET_STS_SUCCESS) THEN
        i:=l_qa_results_tbl.COUNT;
        i:=i+1;
        l_qa_results_tbl(i).check_code:='validate_cost_adjustments';
        l_qa_results_tbl(i).check_meaning:='validate_cost_adjustments';
        l_qa_results_tbl(i).result_code:='SUCCESS';
        l_qa_results_tbl(i).result_meaning:='Passed';
        l_qa_results_tbl(i).message_code:= 'OKL_QA_CHK_COST_ADJ';
        l_qa_results_tbl(i).message_text:= get_msg_text('OKL_QA_CHK_COST_ADJ');
     END IF;
     --check_payment_options for Quote
     x_qa_result := OKL_API.G_RET_STS_SUCCESS;
     check_payments(p_api_version    => p_api_version,
                    p_init_msg_list  => G_FALSE,
                    p_object_id      => lp_quote_id,
                    p_object_type    => lp_object_type,
                    x_return_status  => x_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data,
                    x_qa_result_tbl => l_qa_results_tbl,
                    x_qa_result      => x_qa_result);
     IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
     ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
     END IF;
     IF(x_qa_result = OKL_API.G_RET_STS_SUCCESS) THEN
        i:=l_qa_results_tbl.COUNT;
        i:=i+1;
        l_qa_results_tbl(i).check_code:='check_payments';
        l_qa_results_tbl(i).check_meaning:='check_payments';
        l_qa_results_tbl(i).result_code:='SUCCESS';
        l_qa_results_tbl(i).result_meaning:='Passed';
        l_qa_results_tbl(i).message_code:= 'OKL_QA_CHK_PAYMENT';
        l_qa_results_tbl(i).message_text:= get_msg_text('OKL_QA_CHK_PAYMENT');
     END IF;
     --Check Subsidies for Quote
     x_qa_result := OKL_API.G_RET_STS_SUCCESS;
     check_subsidies(p_api_version    => p_api_version,
                     p_init_msg_list  => G_FALSE,
                     p_object_id      => lp_quote_id,
                     p_object_type    => lp_object_type,
                     x_return_status  => x_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data,
                     x_qa_result_tbl => l_qa_results_tbl,
                     x_qa_result      => x_qa_result);
     IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
     ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
     END IF;
     IF(x_qa_result = OKL_API.G_RET_STS_SUCCESS) THEN
        i:=l_qa_results_tbl.COUNT;
        i:=i+1;
        l_qa_results_tbl(i).check_code:='check_subsidies';
        l_qa_results_tbl(i).check_meaning:='check_subsidies';
        l_qa_results_tbl(i).result_code:='SUCCESS';
        l_qa_results_tbl(i).result_meaning:='Passed';
        l_qa_results_tbl(i).message_code:= 'OKL_QA_CHK_SUBSIDY';
        l_qa_results_tbl(i).message_text:= get_msg_text('OKL_QA_CHK_SUBSIDY');
     END IF;
     --check financial Product for Quote
     x_qa_result := OKL_API.G_RET_STS_SUCCESS;
     validate_financial_product(p_api_version    => p_api_version,
                         p_init_msg_list  => G_FALSE,
                         p_object_id      => lp_quote_id,
                         p_object_type    => lp_object_type,
                         x_return_status  => x_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         x_qa_result_tbl => l_qa_results_tbl,
                         x_qa_result      => x_qa_result);
     IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
     ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
     END IF;
     IF(x_qa_result=OKL_API.G_RET_STS_SUCCESS) THEN
        i:=l_qa_results_tbl.COUNT;
        i:=i+1;
        l_qa_results_tbl(i).check_code:='validate_financial_product';
        l_qa_results_tbl(i).check_meaning:='validate_financial_product';
        l_qa_results_tbl(i).result_code:='SUCCESS';
        l_qa_results_tbl(i).result_meaning:='Passed';
        l_qa_results_tbl(i).message_code:= 'OKL_QA_CHK_FIN_PRODUCT';
        l_qa_results_tbl(i).message_text:= get_msg_text('OKL_QA_CHK_FIN_PRODUCT');
     END IF;
     --Check pricing values for Quote
     x_qa_result := OKL_API.G_RET_STS_SUCCESS;
     validate_pricing_values(p_api_version    => p_api_version,
                         p_init_msg_list  => G_FALSE,
                         p_object_id      => lp_quote_id,
                         p_object_type    => lp_object_type,
                         x_return_status  => x_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         x_qa_result_tbl => l_qa_results_tbl,
                         x_qa_result      => x_qa_result);
     IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
     ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
     END IF;
     IF(x_qa_result= OKL_API.G_RET_STS_SUCCESS) THEN
        i:=l_qa_results_tbl.COUNT;
        i:=i+1;
        l_qa_results_tbl(i).check_code:='validate_pricing_values';
        l_qa_results_tbl(i).check_meaning:='validate_pricing_values';
        l_qa_results_tbl(i).result_code:='SUCCESS';
        l_qa_results_tbl(i).result_meaning:='Passed';
        l_qa_results_tbl(i).message_code:= 'OKL_QA_CHK_PRICING';
        l_qa_results_tbl(i).message_text:= get_msg_text('OKL_QA_CHK_PRICING');
     END IF;
     --Check Eligibility Criteria for Quote Attrb such as LRS ,SRT,Product VPA
     x_qa_result := OKL_API.G_RET_STS_SUCCESS;
     validate_ec_criteria(p_api_version    => p_api_version,
                         p_init_msg_list  => G_FALSE,
                         p_object_id      => lp_quote_id,
                         p_object_type    => lp_object_type,
                         x_return_status  => x_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         x_qa_result_tbl => l_qa_results_tbl,
                         x_qa_result      => x_qa_result);
     IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
     ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
     END IF;
     IF(x_qa_result= OKL_API.G_RET_STS_SUCCESS) THEN
        i:=l_qa_results_tbl.COUNT;
        i:=i+1;
        l_qa_results_tbl(i).check_code:='validate_ec_criteria';
        l_qa_results_tbl(i).check_meaning:='validate_ec_criteria';
        l_qa_results_tbl(i).result_code:='SUCCESS';
        l_qa_results_tbl(i).result_meaning:='Passed';
        l_qa_results_tbl(i).message_code:= 'OKL_QA_CHK_EC';
        l_qa_results_tbl(i).message_text:= get_msg_text('OKL_QA_CHK_EC');
     END IF;
     x_qa_result_tbl := l_qa_results_tbl;

     --Added ssdeshpa Bug #5647107 start
     FOR i IN x_qa_result_tbl.FIRST..x_qa_result_tbl.LAST LOOP
        IF(x_qa_result_tbl(i).result_code ='ERROR') THEN
           b_tax_call := false;
           exit;
        END IF;
     END LOOP;

     IF(b_tax_call AND p_object_type <> 'QUICKQUOTE') THEN -- Fix for Bug 5908845
        OPEN l_systemparams_csr;
        FETCH l_systemparams_csr INTO l_ou_tax_upfront_yn;
        CLOSE l_systemparams_csr;
        IF(l_ou_tax_upfront_yn = 'Y') THEN

           OKL_LEASE_QUOTE_PVT.calculate_sales_tax(p_api_version          => p_api_version,
 						                           p_init_msg_list        => G_FALSE,
						                           x_return_status        => x_return_status,
						                           x_msg_count            => x_msg_count,
						                           x_msg_data             => x_msg_data,
                                                   p_transaction_control  => 'T',
						                           p_quote_id             => lp_quote_id);

	       IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
	  	      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	       ELSIF x_return_status = G_RET_STS_ERROR THEN
	   	      RAISE OKL_API.G_EXCEPTION_ERROR;
	       END IF;
	    END IF;
     END IF;
    --Added Bug # 5647107 ssdeshpa end
     x_return_status := OKL_API.G_RET_STS_SUCCESS;

     okl_api.end_activity(x_msg_count =>  x_msg_count
                         ,x_msg_data  => x_msg_data);
     IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
           okl_debug_pub.log_debug(fnd_log.level_procedure
                                  ,l_module
                                  ,'end debug okl_sales_quote_qa_pvt.run_qa3 call run_qa3');
     END IF;
     EXCEPTION
         WHEN okl_api.g_exception_error THEN

           x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
                                                       ,p_pkg_name  =>G_PKG_NAME
                                                       ,p_exc_name  =>'OKL_API.G_RET_STS_ERROR'
                                                       ,x_msg_count =>x_msg_count
                                                       ,x_msg_data  =>x_msg_data
                                                       ,p_api_type  =>G_API_TYPE);

         WHEN okl_api.g_exception_unexpected_error THEN

           x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
                                                       ,p_pkg_name  =>G_PKG_NAME
                                                       ,p_exc_name  =>'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                       ,x_msg_count =>x_msg_count
                                                       ,x_msg_data  =>x_msg_data
                                                       ,p_api_type  =>G_API_TYPE);

         WHEN OTHERS THEN

           x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
                                                       ,p_pkg_name  =>G_PKG_NAME
                                                       ,p_exc_name  =>'OTHERS'
                                                       ,x_msg_count =>x_msg_count
                                                       ,x_msg_data  =>x_msg_data
                                                       ,p_api_type  =>G_API_TYPE);
      END run_qa_checker;

/*------------------------------------------------------------------------------
    -- PROCEDURE run_qa_checker
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : run_qa_checker
  -- Description      : This procedure will be called a by Quick Quote
                        For QA Validation

  -- Business Rules  : This procedure will validate the Quick Quote for
                       General ,Configuration, Pricing parameters

  -- Parameters      : p_object_id   -- LQuick Quote Id

                       p_object_type -- valid values are  'QUICKQUOTE'
                       hold which type of object this method is calling

                       x_qa_result_tbl --> Hold all the QA Results for Object

                       x_qa_result --'E'/'S' for Overall Success/Failure for QA

  -- Version         : 1.1
  -- History         :
  -- End of comments
 -----------------------------------------------------------------------------*/
   --QA Checker API Called by the Quick Quote Validate Method
    PROCEDURE run_qa_checker(p_api_version                  IN NUMBER
                             ,p_init_msg_list                IN VARCHAR2
                             ,p_object_type                  IN VARCHAR2
                             ,p_object_id                    IN NUMBER
                             ,x_return_status                OUT NOCOPY VARCHAR2
                             ,x_msg_count                    OUT NOCOPY NUMBER
                             ,x_msg_data                     OUT NOCOPY VARCHAR2
                             ,x_qa_result                    OUT NOCOPY VARCHAR2
                             ,x_qa_result_tbl                IN OUT NOCOPY OKL_SALES_QUOTE_QA_PVT.qa_results_tbl_type) IS


       l_program_name      CONSTANT VARCHAR2(30) := 'run_qa_qq';
       l_api_name          CONSTANT VARCHAR2(61) := l_program_name;
       i                   INTEGER;
       l_module            CONSTANT fnd_log_messages.module%TYPE := 'OKL_SALE_QUOTE_QA_PVT.run_qa_checker2';
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
                                ,'begin debug OKLRQQCB.pls call run_qa_checker');
       END IF;  -- check for logging on STATEMENT level
       is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                          ,fnd_log.level_statement);

       -- call START_ACTIVITY to create savepoint, check compatibility
       -- and initialize message list

       x_return_status := okl_api.start_activity(p_api_name=>l_api_name
                                                ,p_pkg_name=>G_PKG_NAME
                                                ,p_init_msg_list=>p_init_msg_list
                                                ,p_api_version=>p_api_version
                                                ,l_api_version=>p_api_version
                                                ,p_api_type=>G_API_TYPE
                                                ,x_return_status=>x_return_status);
       -- check if activity started successfully

       IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
       ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
       END IF;
       ---------------Check for Valid Parent Object type----------------------
       IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_SALES_QUOTE_QA_PVT.run_qa_checker'
                                  ,'begin debug call run_qa_checker');
       END IF;
       --Call wrapper run_qa_checker for QA Validations
       run_qa_checker (p_api_version     => p_api_version
                      ,p_init_msg_list   => p_init_msg_list
                      ,p_object_type     => p_object_type
                      ,p_object_id       => p_object_id
                      ,x_return_status   => x_return_status
                      ,x_msg_count       => x_msg_count
                      ,x_msg_data        => x_msg_data
                      ,x_qa_result_tbl   => x_qa_result_tbl);

       IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_SALES_QUOTE_QA_PVT.run_qa_checker'
                                  ,'end debug call run_qa_checker');
       END IF;
       IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
       ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
       END IF;

       x_qa_result := okl_api.g_ret_sts_success;
       FOR i IN x_qa_result_tbl.FIRST..x_qa_result_tbl.LAST LOOP
           IF(x_qa_result_tbl(i).result_code ='ERROR') THEN
              x_qa_result := OKL_API.g_ret_sts_error;
              exit;
           END IF;
       END LOOP;

       x_return_status := G_RET_STS_SUCCESS;


       okl_api.end_activity(x_msg_count =>  x_msg_count
                           ,x_msg_data  => x_msg_data);
       IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
            okl_debug_pub.log_debug(fnd_log.level_procedure
                                   ,l_module
                                   ,'end debug okl_sales_quote_qa_pvt.run_qa2 call run_qa2');
       END IF;

       EXCEPTION
         WHEN okl_api.g_exception_error THEN

           x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
                                                       ,p_pkg_name  =>G_PKG_NAME
                                                       ,p_exc_name  =>'OKL_API.G_RET_STS_ERROR'
                                                       ,x_msg_count =>x_msg_count
                                                       ,x_msg_data  =>x_msg_data
                                                       ,p_api_type  =>G_API_TYPE);

         WHEN okl_api.g_exception_unexpected_error THEN

           x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
                                                       ,p_pkg_name  =>G_PKG_NAME
                                                       ,p_exc_name  =>'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                       ,x_msg_count =>x_msg_count
                                                       ,x_msg_data  =>x_msg_data
                                                       ,p_api_type  =>G_API_TYPE);

         WHEN OTHERS THEN

           x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
                                                       ,p_pkg_name  =>G_PKG_NAME
                                                       ,p_exc_name  =>'OTHERS'
                                                       ,x_msg_count =>x_msg_count
                                                       ,x_msg_data  =>x_msg_data
                                                       ,p_api_type  =>G_API_TYPE);


   END run_qa_checker;

/*------------------------------------------------------------------------------
    -- PROCEDURE run_qa_checker
--------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : run_qa_checker
  -- Description      : This procedure will be called a by Lease
                        Quote and Lease App For QA Validation

  -- Business Rules  : This procedure will validate the Lease Quote and Quick
                       Quote for General ,Configuration, Pricing parameters

  -- Parameters      : p_object_id   -- Lease Quote Id

                       p_object_type -- valid values are  'LEASEQUOTE'
                       hold which type of object this method is calling

                       x_qa_result --'E'/'S' for Overall Success/Failure for QA

  -- Version         : 1.1
  -- History         :
  -- End of comments
 -----------------------------------------------------------------------------*/
 --QA Checker API Called by the Lease Quote Validate Method

   PROCEDURE run_qa_checker (p_api_version                  IN  NUMBER
                             ,p_init_msg_list               IN  VARCHAR2
                             ,p_object_type                 IN  VARCHAR2
                             ,p_object_id                   IN  NUMBER
                             ,x_qa_result                   OUT NOCOPY VARCHAR2
                             ,x_return_status               OUT NOCOPY VARCHAR2
                             ,x_msg_count                   OUT NOCOPY NUMBER
                             ,x_msg_data                    OUT NOCOPY VARCHAR2) IS

       l_program_name      CONSTANT VARCHAR2(30) := 'run_qa3';
       l_api_name          CONSTANT VARCHAR2(61) := l_program_name;
       i                   INTEGER;
       l_module            CONSTANT fnd_log_messages.module%TYPE := 'OKLRQQCB.pls.run_qa3';
       l_debug_enabled                varchar2(10);
       is_debug_procedure_on          boolean;
       is_debug_statement_on          boolean;
       x_qa_result_tbl               qa_results_tbl_type;
       lp_quote_id                    NUMBER;

       CURSOR get_lq_rec(p_parent_object_id NUMBER,
                    p_object_type VARCHAR2) IS
        SELECT OLQ.ID
        FROM OKL_LEASE_QUOTES_B OLQ
        WHERE PARENT_OBJECT_ID=p_parent_object_id
        AND   PARENT_OBJECT_CODE=p_object_type
        AND   PRIMARY_QUOTE='Y';

       BEGIN

       l_debug_enabled := okl_debug_pub.check_log_enabled;
       is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                           ,fnd_log.level_procedure);


       IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
         okl_debug_pub.log_debug(fnd_log.level_procedure
                                ,l_module
                                ,'begin debug OKLRQQCB.pls call run_qa3');
       END IF;  -- check for logging on STATEMENT level
       is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                          ,fnd_log.level_statement);

       -- call START_ACTIVITY to create savepoint, check compatibility
       -- and initialize message list

       x_return_status := okl_api.start_activity(p_api_name=>l_api_name
                                                ,p_pkg_name=>G_PKG_NAME
                                                ,p_init_msg_list=>p_init_msg_list
                                                ,p_api_version=>p_api_version
                                                ,l_api_version=>p_api_version
                                                ,p_api_type=>G_API_TYPE
                                                ,x_return_status=>x_return_status);  -- check if activity started successfully

       IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
       ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
       END IF;
    --------------------------------------------------------------------------------
       --Call QA Checker To Test
       --Call the wrapper run_qa_checker
       run_qa_checker (p_api_version     => p_api_version
                      ,p_init_msg_list   => p_init_msg_list
                      ,p_object_type     => p_object_type
                      ,p_object_id       => p_object_id
                      ,x_return_status   => x_return_status
                      ,x_msg_count       => x_msg_count
                      ,x_msg_data        => x_msg_data
                      ,x_qa_result_tbl   => x_qa_result_tbl);
       IF(l_debug_enabled='Y') THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_SALES_QUOTE_QA_PVT.run_qa_checker'
                                    ,'end debug call run_qa_checker');
       END IF;
       IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
         RAISE okl_api.g_exception_unexpected_error;
       ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
         RAISE okl_api.g_exception_error;
       END IF;
       --Lease Quote id treated as Primary Quote on Lease Application or
       --Lease Opportunity should go to the Database
       lp_quote_id := p_object_id;
       IF(p_object_type='LEASEAPP' OR p_object_type='LEASEOPP') THEN
               OPEN get_lq_rec(p_parent_object_id => p_object_id,
                             p_object_type => p_object_type);
               FETCH get_lq_rec INTO lp_quote_id;
               CLOSE get_lq_rec;
       END IF;

       --Populate the QA table Result into Database.
       IF(x_qa_result_tbl IS NOT NULL) THEN
          IF(x_qa_result_tbl.COUNT > 0) THEN
             populate_result_table(p_api_version    => p_api_version,
                                   p_init_msg_list  => G_FALSE,
                                   p_object_id      => lp_quote_id,
                                   p_object_type    => 'LEASEQUOTE',
                                   x_return_status  => x_return_status,
                                   x_msg_count      => x_msg_count,
                                   x_msg_data       => x_msg_data,
                                   x_qa_result_tbl => x_qa_result_tbl);

             IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
                 RAISE okl_api.g_exception_unexpected_error;
             ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
                 RAISE okl_api.g_exception_error;
             END IF;
          END IF;
       END IF;

       x_qa_result := okl_api.g_ret_sts_success;
       --See if Table contains any error
       FOR i IN x_qa_result_tbl.FIRST..x_qa_result_tbl.LAST LOOP

          IF(x_qa_result_tbl.exists(i))THEN
            IF(x_qa_result_tbl(i).result_code ='ERROR') THEN
              x_qa_result := OKL_API.g_ret_sts_error;
              EXIT;
            END IF;
          END IF;
       END LOOP;

       x_return_status := G_RET_STS_SUCCESS;

       okl_api.end_activity(x_msg_count =>  x_msg_count
                           ,x_msg_data  => x_msg_data);

      IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
          okl_debug_pub.log_debug(fnd_log.level_procedure
                                 ,l_module
                                 ,'end debug okl_sales_quote_qa_pvt call run_qa3');
      END IF;

      EXCEPTION
         WHEN okl_api.g_exception_error THEN

           x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
                                                       ,p_pkg_name  =>G_PKG_NAME
                                                       ,p_exc_name  =>'OKL_API.G_RET_STS_ERROR'
                                                       ,x_msg_count =>x_msg_count
                                                       ,x_msg_data  =>x_msg_data
                                                       ,p_api_type  =>G_API_TYPE);

         WHEN okl_api.g_exception_unexpected_error THEN

           x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
                                                       ,p_pkg_name  =>G_PKG_NAME
                                                       ,p_exc_name  =>'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                       ,x_msg_count =>x_msg_count
                                                       ,x_msg_data  =>x_msg_data
                                                       ,p_api_type  =>G_API_TYPE);

         WHEN OTHERS THEN

           x_return_status := okl_api.handle_exceptions(p_api_name  =>l_api_name
                                                       ,p_pkg_name  =>G_PKG_NAME
                                                       ,p_exc_name  =>'OTHERS'
                                                       ,x_msg_count =>x_msg_count
                                                       ,x_msg_data  =>x_msg_data
                                                       ,p_api_type  =>G_API_TYPE);
    END run_qa_checker;
 -------------------------------------------------------------------------------
END OKL_SALES_QUOTE_QA_PVT;

/
