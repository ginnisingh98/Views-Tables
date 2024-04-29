--------------------------------------------------------
--  DDL for Package Body PA_DEDUCTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_DEDUCTIONS_PUB" AS
-- /* $Header: PADCTNPB.pls 120.2.12010000.3 2010/04/15 07:25:23 vchilla noship $ */

  G_PKG_NAME      CONSTANT VARCHAR2(30) := 'PA_DEDUCTIONS_PUB';

  Procedure Create_Deduction_Hdr( p_api_version_number     IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                 ,p_commit                 IN VARCHAR2 := FND_API.G_FALSE
                                 ,p_init_msg_list          IN VARCHAR2 := FND_API.G_FALSE
                                 ,p_pm_product_code        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                                 ,p_msg_count              OUT NOCOPY NUMBER
                                 ,p_msg_data               OUT NOCOPY VARCHAR2
                                 ,p_return_status          OUT NOCOPY VARCHAR2
                                 ,p_project_id             IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                 ,p_vendor_id              IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                 ,p_vendor_site_id         IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                 ,p_ci_id                  IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                 ,p_po_header_id           IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                 ,p_deduction_req_num      IN OUT NOCOPY VARCHAR2
                                 ,p_debit_memo_num         IN OUT NOCOPY VARCHAR2
                                 ,p_currency_code          IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                                 ,p_conversion_ratetype    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                                 ,p_conversion_ratedate    IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
                                 ,p_conversion_rate        IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                 ,p_deduction_req_date     IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
                                 ,p_debit_memo_date        IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
                                 ,p_description            IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                                 ,p_status                 IN OUT NOCOPY VARCHAR2
                                 ,p_org_id                 IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                ) IS
    l_ded_req_id      NUMBER;
    l_dctn_hdrtbl     g_pub_dctn_hdr_tbl%TYPE;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(4000);
    l_return_status   VARCHAR2(1);
    l_function_allowed VARCHAR2(1);
    l_api_name        VARCHAR2(30) :=  'CREATE_DEDUCTION_HDR';

    -- bug 9052223 start
    v_converted_amount            NUMBER;
    v_denominator            	  NUMBER;
    v_numerator                   NUMBER;
    v_rate                        NUMBER;
    v_status	      		      Varchar2(100);
    v_proj_func_cur               VARCHAR2(10);
    v_proj_func_rate              VARCHAR2(10);
    l_conversion_ratetype        VARCHAR2(50);
    l_conversion_ratedate        DATE;
    l_conversion_rate            NUMBER;
    -- bug 9052223 end

    CURSOR C1 IS
        SELECT segment1
        FROM   PO_HEADERS_ALL
        WHERE  PO_HEADER_ID = p_po_header_id;

    CURSOR C2 IS
        SELECT ci_number,
               DECODE(ci_type_class_code,'CHANGE_ORDER', 'Change Order',
                                         'CHANGE_REQUEST', 'Change Request') document_type
        FROM   PA_CONTROL_ITEMS citem,
               PA_CI_TYPES_VL ctype
        WHERE  citem.ci_type_id = ctype.ci_type_id
        AND    citem.ci_id = p_ci_id;

  Begin

        l_conversion_ratetype        := p_conversion_ratetype;
        l_conversion_ratedate        := p_conversion_ratedate;
        l_conversion_rate            := p_conversion_rate;

        p_return_status := 'S';
        SAVEPOINT create_deduction_hdr;   --bug9052223

        IF NOT FND_API.Compatible_API_Call ( g_api_version_number  ,
                                             p_api_version_number  ,
                                             l_api_name            ,
                                             G_PKG_NAME         )
        THEN

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END IF;

        PA_PM_FUNCTION_SECURITY_PUB.check_function_security
             (p_api_version_number => p_api_version_number,
              p_responsibility_id  => g_resp_id,
              p_function_name      => 'PA_UPD_SBMT_DEDUCTIONS',
              p_msg_count          => l_msg_count,
              p_msg_data           => l_msg_data,
              p_return_status      => l_return_status,
              p_function_allowed   => l_function_allowed
             );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_function_allowed = 'N' THEN
            pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_FUNCTION_SECURITY_ENFORCED'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'Y'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');

                p_return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
        END IF;

        SELECT PA_DEDUCTIONS_S.nextval
        INTO   l_ded_req_id
        FROM   DUAL;

        l_dctn_hdrtbl(1).deduction_req_id    :=  l_ded_req_id           ;
        l_dctn_hdrtbl(1).project_id          :=  p_project_id           ;
        l_dctn_hdrtbl(1).vendor_id           :=  p_vendor_id            ;
        l_dctn_hdrtbl(1).vendor_site_id      :=  p_vendor_site_id       ;
        l_dctn_hdrtbl(1).ci_id               :=  p_ci_id                ;
        l_dctn_hdrtbl(1).po_header_id        :=  p_po_header_id         ;


        -- bug 9052223 start

            pa_multi_Currency_txn.get_def_ProjFunc_Cst_Rate_Type(
            0 ,
            v_proj_func_cur,
            v_proj_func_rate);

        if p_currency_code <> v_proj_func_cur then

           if p_conversion_ratetype is null or p_conversion_ratedate is null then

                      pa_utils.add_message
                             ( p_app_short_name   => 'PA'
                              ,p_msg_name         => 'PA_MISS_CURR_CONV_INFO'
                             );
                      RAISE FND_API.G_EXC_ERROR;

           else

              pa_multi_currency.convert_amount (  P_from_currency => v_proj_func_cur,
		      P_to_currency           => p_currency_code,
		      P_conversion_date       => l_conversion_ratedate,
		      P_conversion_type       => l_conversion_ratetype,
		      P_amount                => 0,
		      P_user_validate_flag    => 'N',
		      P_handle_exception_flag => 'N',
		      P_converted_amount      => v_converted_amount,
		      P_denominator           => v_denominator,
		      P_numerator             => v_numerator,
		      P_rate                  => v_rate,
              X_status                => v_status);

              IF v_status is not null then
                 pa_utils.add_message
                             ( p_app_short_name   => 'PA'
                              ,p_msg_name         => v_status
                             );
                 RAISE FND_API.G_EXC_ERROR;
              end if;

           end if;

        end if;


        IF l_dctn_hdrtbl(1).po_header_id IS NOT NULL THEN
           OPEN C1;
           FETCH C1 INTO l_dctn_hdrtbl(1).po_number;
           CLOSE C1;
        END IF;

        IF l_dctn_hdrtbl(1).ci_Id IS NOT NULL THEN
           OPEN C2;
           FETCH C2 INTO l_dctn_hdrtbl(1).change_doc_num,
                         l_dctn_hdrtbl(1).change_doc_type;
           CLOSE C2;
        END IF;

        IF p_deduction_req_num IS NULL THEN
           p_deduction_req_num:=l_ded_req_id;
        END IF;

        l_dctn_hdrtbl(1).deduction_req_num   :=  p_deduction_req_num    ;
        l_dctn_hdrtbl(1).debit_memo_num      :=  p_debit_memo_num       ;

        IF p_currency_code IS NULL THEN
       /*    p_msg_data:='PA_DCTN_DMEMO_CURR_NULL'; --  bug9052223
           p_return_status := 'E';
           p_msg_count :=1;
           return;*/

        pa_utils.add_message
        ( p_app_short_name   => 'PA'
         ,p_msg_name         => 'PA_DCTN_DMEMO_CURR_NULL'
        );
        RAISE FND_API.G_EXC_ERROR;

        END IF;


        l_dctn_hdrtbl(1).currency_code       :=  p_currency_code        ;

        l_dctn_hdrtbl(1).conversion_ratetype :=  l_conversion_ratetype  ;
        l_dctn_hdrtbl(1).conversion_ratedate :=  l_conversion_ratedate  ;
        l_dctn_hdrtbl(1).conversion_rate     :=  l_conversion_rate      ;

        IF p_deduction_req_date IS NULL THEN
         /*  p_msg_data:='PA_DCTN_REQ_DATE_NULL'; --  bug9052223
           p_return_status := 'E';
           p_msg_count :=1;
           return;*/

        pa_utils.add_message
        ( p_app_short_name   => 'PA'
         ,p_msg_name         => 'PA_DCTN_REQ_DATE_NULL'
        );
        RAISE FND_API.G_EXC_ERROR;

        END IF;

        l_dctn_hdrtbl(1).deduction_req_date  :=  p_deduction_req_date   ;

        l_dctn_hdrtbl(1).debit_memo_date     :=  p_debit_memo_date      ;
        l_dctn_hdrtbl(1).description         :=  p_description          ;
        l_dctn_hdrtbl(1).status              :=  'WORKING'              ;

        l_dctn_hdrtbl(1).org_id              :=  p_org_id               ;

        PA_DEDUCTIONS.Create_Deduction_Hdr( l_dctn_hdrtbl
                                           ,l_msg_count
                                           ,l_msg_data
                                           ,l_return_status
                                           ,'PUB');

        IF l_return_status = 'S' AND p_commit ='T' THEN -- Added p_commit check for bug 9052223
           Commit;
	   p_return_status :='S';
        ELSIF l_return_status <> 'S' THEN
           p_msg_data := l_msg_data;
           p_return_status := 'E';
        END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO create_deduction_hdr;
       p_return_status := FND_API.G_RET_STS_ERROR;

       FND_MSG_PUB.Count_And_Get
          (   p_count    =>  p_msg_count  ,
              p_data    =>  p_msg_data  );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_deduction_hdr;
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get
            (   p_count    =>  p_msg_count  ,
                p_data     =>  p_msg_data  );

     WHEN OTHERS THEN
        ROLLBACK TO create_deduction_hdr;
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)   THEN
          FND_MSG_PUB.add_exc_msg
            ( p_pkg_name    => G_PKG_NAME
             ,p_procedure_name  => l_api_name  );
       END IF;

	FND_MSG_PUB.Count_And_Get
          (   p_count    =>  p_msg_count  ,
              p_data    =>  p_msg_data  );
  End;

  Procedure Create_Deduction_Txn( p_api_version_number     IN NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                 ,p_commit                 IN VARCHAR2 := FND_API.G_FALSE
                                 ,p_init_msg_list          IN VARCHAR2 := FND_API.G_FALSE
                                 ,p_pm_product_code        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                                 ,p_msg_count              OUT NOCOPY NUMBER
                                 ,p_msg_data               OUT NOCOPY VARCHAR2
                                 ,p_return_status          OUT NOCOPY VARCHAR2
                                 ,p_deduction_req_num          IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                                 ,p_task_id                    IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                 ,p_expenditure_type           IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                                 ,p_expenditure_item_date      IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
                                 ,p_gl_date                    IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
                                 ,p_expenditure_org_id         IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                 ,p_quantity                   IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                -- ,p_override_quantity          IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM -- bug9052223
                                 ,p_expenditure_item_id        IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                               --  ,p_projfunc_currency_code     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                                 ,p_orig_projfunc_amount       IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                -- ,p_override_projfunc_amount   IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM -- bug9052223
                                 ,p_conversion_ratetype        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                                 ,p_conversion_ratedate        IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
                                 ,p_conversion_rate            IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                               --  ,p_amount                     IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM -- bug9052223
                                 ,p_description                IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                                ) IS

    l_dctn_txntbl g_pub_dctn_txn_tbl%TYPE;

    CURSOR C1(c_deduction_req_num PA_DEDUCTIONS_ALL.deduction_req_num%TYPE) IS
      SELECT *
      FROM   PA_DEDUCTIONS_ALL
      WHERE  deduction_req_num = c_deduction_req_num
      AND    status = 'WORKING';


    cur_dctn_hdr C1%ROWTYPE;
    l_deduction_req_tran_id PA_DEDUCTION_TRANSACTIONS_ALL.deduction_req_tran_id%TYPE;

    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(4000);
    l_return_status   VARCHAR2(1);
    l_function_allowed VARCHAR2(1);
    l_api_name         VARCHAR2(30) :=  'CREATE_DEDUCTION_TXN';

   -- bug 9052223 start
    v_converted_amount            NUMBER;
    v_denominator            	  NUMBER;
    v_numerator                   NUMBER;
    v_rate                        NUMBER;
    v_status	      		      Varchar2(100);
    v_proj_func_cur               VARCHAR2(10);
    v_proj_func_rate              VARCHAR2(10);
    -- bug 9052223 end

    l_conversion_ratetype        VARCHAR2(50);
    l_conversion_ratedate        DATE;
    l_conversion_rate            NUMBER;

  Begin
        p_return_status :='S';
        SAVEPOINT create_deduction_txn;   --bug9052223

        l_conversion_ratetype        :=p_conversion_ratetype        ;
        l_conversion_ratedate        :=p_conversion_ratedate        ;
        l_conversion_rate            :=p_conversion_rate            ;

        IF NOT FND_API.Compatible_API_Call ( g_api_version_number  ,
                                             p_api_version_number  ,
                                             l_api_name            ,
                                             G_PKG_NAME         )
        THEN

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END IF;

        PA_PM_FUNCTION_SECURITY_PUB.check_function_security
             (p_api_version_number => p_api_version_number,
              p_responsibility_id  => g_resp_id,
              p_function_name      => 'PA_UPD_SBMT_DEDUCTIONS',
              p_msg_count          => l_msg_count,
              p_msg_data           => l_msg_data,
              p_return_status      => l_return_status,
              p_function_allowed   => l_function_allowed
             );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_function_allowed = 'N' THEN
            pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_FUNCTION_SECURITY_ENFORCED'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'Y'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
           p_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;


       IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
       END IF;

        OPEN C1(p_deduction_req_num);
        FETCH C1 INTO cur_dctn_hdr;
        IF C1%NOTFOUND THEN
           /* p_msg_data := 'PA_DCTN_HDR_NOT_EXISTS'; -- bug9052223
            p_return_status :='E';
            p_msg_count :=1;*/

        pa_utils.add_message
        ( p_app_short_name   => 'PA'
         ,p_msg_name         => 'PA_DCTN_HDR_NOT_EXISTS'
        );

            CLOSE C1;
            RAISE FND_API.G_EXC_ERROR;

        END IF;
        CLOSE C1;

        SELECT PA_DEDUCTION_TXNS_S.nextval
        INTO   l_deduction_req_tran_id
        FROM   DUAL;

            pa_multi_Currency_txn.get_def_ProjFunc_Cst_Rate_Type(
            0 ,
            v_proj_func_cur,
            v_proj_func_rate);

        if cur_dctn_hdr.currency_code <> v_proj_func_cur then

           if p_conversion_ratetype is null or p_conversion_ratedate is null then

                      pa_utils.add_message
                             ( p_app_short_name   => 'PA'
                              ,p_msg_name         => 'PA_MISS_CURR_CONV_INFO'
                             );
                      RAISE FND_API.G_EXC_ERROR;

           else


              pa_multi_currency.convert_amount (  P_from_currency => v_proj_func_cur,
		      P_to_currency           => cur_dctn_hdr.currency_code,
		      P_conversion_date       => l_conversion_ratedate,
		      P_conversion_type       => l_conversion_ratetype,
		      P_amount                => p_orig_projfunc_amount,
		      P_user_validate_flag    => 'N',
		      P_handle_exception_flag => 'Y',
		      P_converted_amount      => v_converted_amount,
		      P_denominator           => v_denominator,
		      P_numerator             => v_numerator,
		      P_rate                  => v_rate,
              X_status                => v_status);

              IF v_status is not null then
                            pa_utils.add_message
                             ( p_app_short_name   => 'PA'
                              ,p_msg_name         => v_status
                             );
                      RAISE FND_API.G_EXC_ERROR;
              end if;

           end if;
        ELSE
          v_converted_amount:=p_orig_projfunc_amount;
        end if;


        l_dctn_txntbl(1).deduction_req_id          := cur_dctn_hdr.deduction_req_id;
        l_dctn_txntbl(1).deduction_req_tran_id     := l_deduction_req_tran_id   ;
        l_dctn_txntbl(1).project_id                := cur_dctn_hdr.project_id   ;
        l_dctn_txntbl(1).task_id                   := p_task_id                 ;
        l_dctn_txntbl(1).expenditure_type          := p_expenditure_type        ;
        l_dctn_txntbl(1).expenditure_item_date     := p_expenditure_item_date   ;
        l_dctn_txntbl(1).gl_date                   := p_gl_date                 ;
        l_dctn_txntbl(1).expenditure_org_id        := p_expenditure_org_id      ;
        l_dctn_txntbl(1).quantity                  := p_quantity                ;
      --  l_dctn_txntbl(1).override_quantity         := p_override_quantity       ;  --bug9052223
        l_dctn_txntbl(1).expenditure_item_id       := p_expenditure_item_id     ;
        l_dctn_txntbl(1).projfunc_currency_code    := v_proj_func_cur  ;
        l_dctn_txntbl(1).orig_projfunc_amount      := p_orig_projfunc_amount    ;
       -- l_dctn_txntbl(1).override_projfunc_amount  := p_override_projfunc_amount;  --bug9052223
        l_dctn_txntbl(1).conversion_ratetype       := l_conversion_ratetype     ;
        l_dctn_txntbl(1).conversion_ratedate       := l_conversion_ratedate     ;
        l_dctn_txntbl(1).conversion_rate           := l_conversion_rate         ;
         l_dctn_txntbl(1).amount                   := v_converted_amount;    --bug9052223
        l_dctn_txntbl(1).description               := p_description             ;


        PA_DEDUCTIONS.Create_Deduction_Txn( l_dctn_txntbl
                                           ,l_msg_count
                                           ,l_msg_data
                                           ,l_return_status
                                           ,'PUB');

	IF l_return_status = 'S' AND p_commit ='T' THEN -- Added p_commit check for bug 9052223
           Commit;
	   p_return_status :='S';
        ELSIF l_return_status <> 'S' THEN
           p_msg_data := l_msg_data;
           p_return_status := 'E';
        END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO create_deduction_txn;
       p_return_status := FND_API.G_RET_STS_ERROR;

       FND_MSG_PUB.Count_And_Get
          (   p_count    =>  p_msg_count  ,
              p_data    =>  p_msg_data  );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_deduction_txn;
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get
            (   p_count    =>  p_msg_count  ,
                p_data     =>  p_msg_data  );

     WHEN OTHERS THEN
        ROLLBACK TO create_deduction_txn;
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)   THEN
          FND_MSG_PUB.add_exc_msg
            ( p_pkg_name    => G_PKG_NAME
             ,p_procedure_name  => l_api_name  );
       END IF;

       FND_MSG_PUB.Count_And_Get
         ( p_count    =>  p_msg_count,
           p_data    =>   p_msg_data  );

  End;

END PA_DEDUCTIONS_PUB;

/
