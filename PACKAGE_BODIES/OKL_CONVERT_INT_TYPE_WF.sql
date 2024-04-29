--------------------------------------------------------
--  DDL for Package Body OKL_CONVERT_INT_TYPE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CONVERT_INT_TYPE_WF" as
  /* $Header: OKLRITWB.pls 120.4 2006/07/21 13:10:58 akrangan noship $ */

--rkuttiya added for fixing problem identified during bug:2923037
l_ntf_result    VARCHAR2(30);

-----get messages from the server side-----------------
PROCEDURE Get_Messages (
p_message_count IN  NUMBER,
x_msgs          OUT NOCOPY VARCHAR2)
IS
      l_msg_list        VARCHAR2(5000) := '';
      l_temp_msg        VARCHAR2(2000);
      l_appl_short_name  VARCHAR2(50) ;
      l_message_name    VARCHAR2(30) ;
      l_id              NUMBER;
      l_message_num     NUMBER;
  	  l_msg_count       NUMBER;
	  l_msg_data        VARCHAR2(2000);

      Cursor Get_Appl_Id (x_short_name VARCHAR2) IS
        SELECT  application_id
        FROM    fnd_application_vl
        WHERE   application_short_name = x_short_name;

      Cursor Get_Message_Num (x_msg VARCHAR2, x_id NUMBER, x_lang_id NUMBER) IS
        SELECT  msg.message_number
        FROM    fnd_new_messages msg, fnd_languages_vl lng
        WHERE   msg.message_name = x_msg
          and   msg.application_id = x_id
          and   lng.LANGUAGE_CODE = msg.language_code
          and   lng.language_id = x_lang_id;
BEGIN
      FOR l_count in 1..p_message_count LOOP

          l_temp_msg := fnd_msg_pub.get(fnd_msg_pub.g_next, fnd_api.g_true);
          fnd_message.parse_encoded(l_temp_msg, l_appl_short_name, l_message_name);
          OPEN Get_Appl_Id (l_appl_short_name);
          FETCH Get_Appl_Id into l_id;
          CLOSE Get_Appl_Id;
          l_message_num := NULL;

          IF l_id is not NULL
          THEN
              OPEN Get_Message_Num (l_message_name, l_id,
                        to_number(NVL(FND_PROFILE.Value('LANGUAGE'), '0')));
              FETCH Get_Message_Num into l_message_num;
              CLOSE Get_Message_Num;
          END IF;

          l_temp_msg := fnd_msg_pub.get(fnd_msg_pub.g_previous, fnd_api.g_true);

          IF NVL(l_message_num, 0) <> 0
          THEN
            l_temp_msg := 'APP-' || to_char(l_message_num) || ': ';
          ELSE
            l_temp_msg := NULL;
          END IF;

          IF l_count = 1
          THEN
              l_msg_list := l_msg_list || l_temp_msg ||
                        fnd_msg_pub.get(fnd_msg_pub.g_first, fnd_api.g_false);
          ELSE
              l_msg_list := l_msg_list || l_temp_msg ||
                        fnd_msg_pub.get(fnd_msg_pub.g_next, fnd_api.g_false);
          END IF;

          l_msg_list := l_msg_list || '';

      END LOOP;

      x_msgs := l_msg_list;
END Get_Messages;

--------------------------------------------------------------------------------------------------
----------------------------------Rasing Business Event ------------------------------------------
--------------------------------------------------------------------------------------------------
  PROCEDURE raise_convert_interest_event (p_request_id IN NUMBER,
                                          p_contract_id IN NUMBER,
                                          x_return_status OUT NOCOPY VARCHAR2) AS
    l_parameter_list        wf_parameter_list_t;
    l_key                   varchar2(240);
    l_event_name            varchar2(240) := 'oracle.apps.okl.cs.convertinteresttype';

    l_seq                   NUMBER;
    l_return_status         VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    CURSOR okl_key_csr IS
    SELECT okl_wf_item_s.nextval
    FROM  dual;
  BEGIN
    SAVEPOINT raise_convert_interest_event;
    OPEN okl_key_csr;
    FETCH okl_key_csr INTO l_seq;
    CLOSE okl_key_csr;
    l_key := l_event_name ||l_seq;
    wf_event.AddParameterToList('TAS_ID',p_request_id,l_parameter_list);
    wf_event.AddParameterToList('CONTRACT_ID',p_contract_id,l_parameter_list);
    --added by akrangan
    wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);

    -- Raise Event
    wf_event.raise(p_event_name => l_event_name
                   ,p_event_key   => l_key
                   ,p_parameters  => l_parameter_list);
    x_return_status := l_return_status;
    l_parameter_list.DELETE;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('OKL', 'OKL_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;
      ROLLBACK TO raise_convert_interest_event;
  END raise_convert_interest_event;

  --------------------------------------------------------------------------------------------------
  ----------------------------Main Populate Notification  ------------------------------------------
  --------------------------------------------------------------------------------------------------
    procedure populate_attributes(itemtype  in varchar2,
                                  itemkey   in varchar2,
                                  actid     in number,
                                  funcmode  in varchar2,
                                  resultout out nocopy varchar2)
    AS
      l_return_status	VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
      l_api_version       NUMBER	:= 1.0;
      l_msg_count		NUMBER;
      l_init_msg_list     VARCHAR2(10) := OKL_API.G_FALSE;
      l_msg_data		VARCHAR2(2000);

      l_request_num      OKL_TRX_REQUESTS.REQUEST_NUMBER%TYPE;
      l_contract_num      OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE;
      l_trx_id          NUMBER;
      l_chrv_id          NUMBER;
      l_request_details  OKL_TRX_REQUESTS%ROWTYPE;
      l_cit_details      OKL_CONVERT_INT_RATE_REQUEST_V%ROWTYPE;
      l_int_details      OKL_K_RATE_PARAMS_V%ROWTYPE;
      l_var_method	     VARCHAR2(30);
      l_int_method	     VARCHAR2(30);
      l_calc_method	     VARCHAR2(30);
      l_adj_freq	     VARCHAR2(30);
      l_approver         VARCHAR2(100);
      l_index_name       VARCHAR2(150);
      l_days_in_year     VARCHAR2(80);
      l_days_in_month    VARCHAR2(80);
      l_principal_basis  VARCHAR2(80);
      l_interest_basis   VARCHAR2(80);
      l_rate_delay       VARCHAR2(80);
      l_comp_frequency   VARCHAR2(80);
      l_catchup_stlmnt   VARCHAR2(80);
      l_catchup_basis    VARCHAR2(80);
      l_conversion_type  VARCHAR2(80);
      l_conversion_option VARCHAR2(80);
      l_formula_name     VARCHAR2(150);


      CURSOR c_fetch_k_number(p_contract_id OKC_K_HEADERS_V.ID%TYPE)
      IS
      SELECT chrv.contract_number
      FROM okc_k_headers_v chrv
      WHERE chrv.id = p_contract_id;

      CURSOR c_fetch_req_details(p_request_id OKL_TRX_REQUESTS.ID%TYPE)
      IS
      SELECT *
      FROM okl_trx_requests trx
      WHERE trx.id = p_request_id;

      CURSOR c_cit_details(p_request_id IN NUMBER)
      IS
      SELECT *
      FROM OKL_CONVERT_INT_RATE_REQUEST_V
      WHERE TRQ_ID = p_request_id;

      CURSOR c_int_details(p_contract_id         IN NUMBER,
                           p_effective_date      IN DATE,
                           p_parameter_type_code IN VARCHAR2)
      IS
      SELECT *
      FROM OKL_K_RATE_PARAMS_V
      WHERE KHR_ID = p_contract_id
      AND   EFFECTIVE_FROM_DATE = p_effective_date
      AND   PARAMETER_TYPE_CODE = p_parameter_type_code;

      CURSOR c_get_index(p_index_id  IN NUMBER)
      IS
      SELECT NAME
      FROM OKL_INDICES
      WHERE ID = p_index_id;

      CURSOR c_formula(p_formula_id IN NUMBER)
      IS
      SELECT NAME
      FROM OKL_FORMULAE_V
      WHERE ID = p_formula_id;


      CURSOR c_get_lkp_meaning(p_lookup_type VARCHAR2,p_lookup_code VARCHAR2)
      IS
      SELECT meaning
      FROM fnd_lookups
      WHERE lookup_type = p_lookup_type
      AND lookup_code = p_lookup_code;

    BEGIN

      IF (funcmode = 'RUN') THEN
    --rkuttiya added for bug:2923037
        l_approver	:=	fnd_profile.value('OKL_BILL_REQ_REP');
	IF l_approver IS NULL THEN
            l_approver        := 'SYSADMIN';
         END IF;
         wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'APPROVER_ROLE',
                                   avalue   => l_approver);
        l_trx_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'TAS_ID');
        l_chrv_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'CONTRACT_ID');

        OPEN  c_fetch_req_details(l_trx_id);
        FETCH c_fetch_req_details INTO l_request_details;
        CLOSE c_fetch_req_details;

        OPEN  c_fetch_k_number(l_chrv_id);
        FETCH c_fetch_k_number INTO l_contract_num;
        CLOSE c_fetch_k_number;

        OPEN c_cit_details(l_trx_id);
        FETCH c_cit_details INTO l_cit_details ;
        CLOSE c_cit_details;

        OPEN c_int_details(l_chrv_id,
                           l_cit_details.effective_from_date,
                           l_cit_details.parameter_type_code);
        FETCH c_int_details INTO l_int_details;
        CLOSE c_int_details;

        OPEN c_get_index(l_int_details.interest_index_id);
        FETCH c_get_index INTO l_index_name;
        CLOSE c_get_index;

        OPEN c_formula(l_int_details.calculation_formula_id);
        FETcH c_formula INTO l_formula_name;
        CLOSE c_formula;

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'REQUEST_NUMBER',
                                   avalue   => l_request_details.request_number);
        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'CONTRACT_NUMBER',
                                   avalue   => l_contract_num);
        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'EFFECTIVE_DATE',
                                   avalue   => l_int_details.effective_from_date);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'INDEX_NAME',
                                   avalue   => l_index_name);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'BASE_RATE',
                                   avalue   => l_int_details.base_rate);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'ADDER',
                                   avalue   => l_int_details.adder_rate);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'MIN_RATE',
                                   avalue   => l_int_details.minimum_rate);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'MAX_RATE',
                                   avalue   => l_int_details.maximum_rate);

--commented out for 11i OKL.H Variable Rate
       /* wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'TOLERANCE',
                                   avalue   => l_request_details.tolerance);*/

        OPEN c_get_lkp_meaning('OKL_YEAR_TYPE',l_int_details.days_in_a_year_code);
        FETCH c_get_lkp_meaning INTO l_days_in_year;
        CLOSE c_get_lkp_meaning;

        OPEN c_get_lkp_meaning('OKL_MONTH_TYPE',l_int_details.days_in_a_month_code);
        FETCH c_get_lkp_meaning INTO l_days_in_month;
        CLOSE c_get_lkp_meaning;

        OPEN c_get_lkp_meaning('OKL_PRINCIPAL_BASIS_CODE',l_int_details.principal_basis_code);
        FETCH c_get_lkp_meaning INTO l_principal_basis;
        CLOSE c_get_lkp_meaning;

        OPEN c_get_lkp_meaning('OKL_VAR_INTCALC',l_int_details.interest_basis_code);
        FETCH c_get_lkp_meaning INTO l_interest_basis;
        CLOSE c_get_lkp_meaning;

        OPEN c_get_lkp_meaning('OKL_RATE_DELAY_CODE',l_int_details.rate_delay_code);
        FETCH c_get_lkp_meaning INTO l_rate_delay;
        CLOSE c_get_lkp_meaning;

        OPEN c_get_lkp_meaning('OKL_COMPOUNDING_FREQUENCY_CODE',l_int_details.compounding_frequency_code);
        FETCH c_get_lkp_meaning INTO l_comp_frequency;
        CLOSE c_get_lkp_meaning;

        OPEN c_get_lkp_meaning('OKL_CATCHUP_SETTLEMENT_CODE',l_int_details.catchup_settlement_code);
        FETCH c_get_lkp_meaning INTO l_catchup_stlmnt;
        CLOSE c_get_lkp_meaning;

        OPEN c_get_lkp_meaning('OKL_CATCHUP_BASIS_CODE',l_int_details.catchup_basis_code);
        FETCH c_get_lkp_meaning INTO l_catchup_basis;
        CLOSE c_get_lkp_meaning;

        OPEN c_get_lkp_meaning('OKL_CONVERT_TYPE',l_int_details.conversion_type_code);
        FETCH c_get_lkp_meaning INTO l_conversion_type;
        CLOSE c_get_lkp_meaning;

        OPEN c_get_lkp_meaning('OKL_CONVERSION_OPTION_CODE',l_int_details.conversion_option_code);
        FETCH c_get_lkp_meaning INTO l_conversion_option;
        CLOSE c_get_lkp_meaning;


        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'DAYS_IN_YEAR',
                                   avalue   => l_days_in_year);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'DAYS_IN_MONTH',
                                   avalue   => l_days_in_month);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'INTEREST_START_DATE',
                                   avalue   => l_int_details.interest_start_date);

         wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PRINCIPAL_BASIS',
                                   avalue   => l_principal_basis);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'INTEREST_BASIS',
                                   avalue   => l_interest_basis);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'RATE_DELAY',
                                   avalue   => l_rate_delay);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'COMP_FREQ',
                                   avalue   => l_comp_frequency);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'FORMULA_NAME',
                                   avalue   => l_formula_name);

         wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'RATE_DELAY_FREQ',
                                   avalue   => l_int_details.rate_delay_frequency);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'CATCHUP_START_DT',
                                   avalue   => l_int_details.catchup_start_date);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'CATCHUP_STLMNT',
                                   avalue   => l_catchup_stlmnt);

         wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'RATE_CHNG_START_DT',
                                   avalue   => l_int_details.rate_change_start_date);

         wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'RATE_CHNG_VALUE',
                                   avalue   => l_int_details.rate_change_value);

         wf_engine.SetItemAttrText (itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'CATCHUP_BASIS',
                                    avalue   => l_catchup_basis);

          wf_engine.SetItemAttrText (itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'CONVERT_TYPE',
                                    avalue   => l_conversion_type);

         wf_engine.SetItemAttrText (itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'NEXT_CONVERSION_DT',
                                    avalue   => l_int_details.next_conversion_date);

         wf_engine.SetItemAttrText (itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'CONVERT_OPTION',
                                    avalue   => l_conversion_option);


--populate the proposed interest rate parameters
       OPEN c_get_lkp_meaning('OKL_DAYS_IN_A_YEAR_CODE',l_cit_details.days_in_a_year_code);
        FETCH c_get_lkp_meaning INTO l_days_in_year;
        CLOSE c_get_lkp_meaning;

        OPEN c_get_lkp_meaning('OKL_DAYS_IN_A_MONTH_CODE',l_cit_details.days_in_a_month_code);
        FETCH c_get_lkp_meaning INTO l_days_in_month;
        CLOSE c_get_lkp_meaning;

        OPEN c_get_lkp_meaning('OKL_PRINCIPAL_BASIS_CODE',l_cit_details.principal_basis_code);
        FETCH c_get_lkp_meaning INTO l_principal_basis;
        CLOSE c_get_lkp_meaning;

        OPEN c_get_lkp_meaning('OKL_VAR_INTCALC',l_cit_details.interest_basis_code);
        FETCH c_get_lkp_meaning INTO l_interest_basis;
        CLOSE c_get_lkp_meaning;

        OPEN c_get_lkp_meaning('OKL_RATE_DELAY_CODE',l_cit_details.rate_delay_code);
        FETCH c_get_lkp_meaning INTO l_rate_delay;
        CLOSE c_get_lkp_meaning;

        OPEN c_get_lkp_meaning('OKL_COMPOUNDING_FREQUENCY_CODE',l_cit_details.compound_frequency_code);
        FETCH c_get_lkp_meaning INTO l_comp_frequency;
        CLOSE c_get_lkp_meaning;

        OPEN c_get_lkp_meaning('OKL_CATCHUP_SETTLEMENT_CODE',l_cit_details.catchup_settlement_code);
        FETCH c_get_lkp_meaning INTO l_catchup_stlmnt;
        CLOSE c_get_lkp_meaning;

        OPEN c_get_lkp_meaning('OKL_CATCHUP_BASIS_CODE',l_cit_details.catchup_basis_code);
        FETCH c_get_lkp_meaning INTO l_catchup_basis;
        CLOSE c_get_lkp_meaning;

        OPEN c_get_lkp_meaning('OKL_CONVERT_TYPE',l_cit_details.conversion_type_code);
        FETCH c_get_lkp_meaning INTO l_conversion_type;
        CLOSE c_get_lkp_meaning;

        OPEN c_get_lkp_meaning('OKL_CONVERSION_OPTION_CODE',l_cit_details.conversion_option_code);
        FETCH c_get_lkp_meaning INTO l_conversion_option;
        CLOSE c_get_lkp_meaning;

        OPEN c_get_index(l_cit_details.interest_index_id);
        FETCH c_get_index INTO l_index_name;
        CLOSE c_get_index;



        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PROP_EFFECTIVE_DATE',
                                   avalue   => l_cit_details.proposed_effective_date);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PROP_INDEX_NAME',
                                   avalue   => l_index_name);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PROP_BASE_RATE',
                                   avalue   => l_cit_details.base_rate);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PROP_ADDER',
                                   avalue   => l_cit_details.adder_rate);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PROP_MIN_RATE',
                                   avalue   => l_cit_details.minimum_rate);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PROP_MAX_RATE',
                                   avalue   => l_cit_details.maximum_rate);

       wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PROP_DAYS_YR',
                                   avalue   => l_days_in_year);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PROP_DAYS_MONTH',
                                   avalue   => l_days_in_month);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PROP_INT_START_DT',
                                   avalue   => l_cit_details.conversion_date);

         wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PROP_PRINC_BASIS',
                                   avalue   => l_principal_basis);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PROP_INT_BASIS',
                                   avalue   => l_interest_basis);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PROP_RATE_DELAY',
                                   avalue   => l_rate_delay);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PROP_COMP_FREQ',
                                   avalue   => l_comp_frequency);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PROP_FORMULA_NAME',
                                   avalue   => l_cit_details.calculation_formula_name);

         wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PROP_RATE_DELAY_FREQ',
                                   avalue   => l_cit_details.rate_delay_frequency);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PROP_CATCHUP_START_DT',
                                   avalue   => l_cit_details.catchup_start_date);

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PROP_CATCHUP_STLMNT',
                                   avalue   => l_catchup_stlmnt);

         wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PROP_RATE_CHNG_ST_DT',
                                   avalue   => l_cit_details.rate_change_start_date);

         wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PROP_RATE_CHNG_VAL',
                                   avalue   => l_cit_details.rate_change_value);

         wf_engine.SetItemAttrText (itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'PROP_CATCHUP_BASIS',
                                    avalue   => l_catchup_basis);

          wf_engine.SetItemAttrText (itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'PROP_CONVERT_TYPE',
                                    avalue   => l_conversion_type);

         wf_engine.SetItemAttrText (itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'PROP_NEXT_CONV_DT',
                                    avalue   => l_cit_details.next_conversion_date);

         wf_engine.SetItemAttrText (itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'PROP_CONVERT_OPTION',
                                    avalue   => l_conversion_option);



--ommented out by rkuttiya for 11i OKL.H Variable Rate
      /*  OPEN  c_get_lkp_meaning('OKL_VARIABLE_METHOD',l_request_details.variable_method_code);
        FETCH c_get_lkp_meaning INTO l_var_method;
        CLOSE c_get_lkp_meaning;

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'VARIABLE_METHOD',
                                   avalue   => l_var_method);

        OPEN  c_get_lkp_meaning('OKL_ADJ_FREQUENCY',l_request_details.adjustment_frequency_code);
        FETCH c_get_lkp_meaning INTO l_adj_freq;
        CLOSE c_get_lkp_meaning;

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'ADJ_FREQ',
                                   avalue   => l_adj_freq);

        OPEN  c_get_lkp_meaning('OKL_VAR_INTCALC',l_request_details.interest_method_code);
        FETCH c_get_lkp_meaning INTO l_int_method;
        CLOSE c_get_lkp_meaning;

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'INTEREST_METHOD',
                                   avalue   => l_int_method);

        OPEN  c_get_lkp_meaning('OKL_CALC_METHOD',l_request_details.method_of_calculation_code);
        FETCH c_get_lkp_meaning INTO l_calc_method;
        CLOSE c_get_lkp_meaning;

        wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'CALC_METHOD',
                                   avalue   => l_calc_method); */
        resultout := 'COMPLETE:';
        return;
      END IF;
      -- CANCEL mode
      IF (funcmode = 'CANCEL') then
        resultout := 'COMPLETE:';
        return;
      END IF;
      -- TIMEOUT mode
      IF (funcmode = 'TIMEOUT') then
        resultout := 'COMPLETE:';
        return;
      END IF;
    EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
        wf_core.context('OKL_CONVERT_INT_TYPE_WF',
                        'Convert_Interest_Type',
                         itemtype,
                         itemkey,
                         to_char(actid),
                         funcmode);
  	  RAISE;
      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        wf_core.context('OKL_CONVERT_INT_TYPE_WF',
                        'Convert_Interest_Type',
                         itemtype,
                         itemkey,
                         to_char(actid),
                         funcmode);
  	  RAISE;
      WHEN OTHERS THEN
        wf_core.context('OKL_CONVERT_INT_TYPE_WF',
                        'Convert_Interest_Type',
                         itemtype,
                         itemkey,
                         to_char(actid),
                         funcmode);
  	  RAISE;
    END populate_attributes;



    --------------------------------------------------------------------------------------------------
    ----------------------------------Main Approval Process ------------------------------------------
    --------------------------------------------------------------------------------------------------
      PROCEDURE contract_approval(itemtype  in varchar2,
                                  itemkey   in varchar2,
                                  actid     in number,
                                  funcmode  in varchar2,
                                  resultout out nocopy varchar2) AS

        l_return_status	VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
        l_api_version       NUMBER	:= 1.0;
        l_msg_count		NUMBER;
        l_init_msg_list     VARCHAR2(10) := OKL_API.G_FALSE;
        l_msg_data		VARCHAR2(2000);

        l_request_num      OKL_TRX_REQUESTS.REQUEST_NUMBER%TYPE;
        l_trx_id           NUMBER;
        l_nid               NUMBER;
        l_trq_rec          okl_trq_pvt.trqv_rec_type;
        lx_trq_rec         okl_trq_pvt.trqv_rec_type;

       --rkuttiya changed for fixing problem identified during bug:2923037
       -- l_ntf_result        VARCHAR2(30);
        l_ntf_comments      VARCHAR2(4000);
        l_sts_code          VARCHAR2(30);

        l_error             VARCHAR2(2000);

      BEGIN
        -- We getting the request_Id from WF
        l_trx_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'TAS_ID');
        -- We need to status to Approved Pending since We are sending for approval
        IF (funcmode = 'RESPOND') THEN
          --get notification id from wf_engine context
          l_nid := WF_ENGINE.CONTEXT_NID;
          l_ntf_result := wf_notification.GetAttrText(l_nid,'RESULT');

          IF l_ntf_result = 'APPROVED' THEN
             l_sts_code := 'APPROVED';
          ELSIF l_ntf_result = 'REJECTED' THEN
             l_sts_code := 'REJECTED';
          END IF;

          l_trq_rec.id :=  l_trx_id;
          l_trq_rec.request_status_code := l_sts_code;
          okl_trx_requests_pub.update_trx_requests(
                                           p_api_version         => l_api_version,
                                           p_init_msg_list       => l_init_msg_list,
                                           x_return_status       => l_return_status,
                                           x_msg_count           => l_msg_count,
                                           x_msg_data            => l_msg_data,
                                           p_trqv_rec            => l_trq_rec,
                                           x_trqv_rec            => lx_trq_rec);
      IF l_return_status <> 'S' THEN
		   FND_MSG_PUB.Count_And_Get
               		      (  p_count          =>   l_msg_count,
               		         p_data           =>   l_msg_data);
       	Get_Messages(l_msg_count,l_error);

        wf_engine.SetItemAttrText(itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'TOLERANCE',
                                   avalue    => l_error);

         resultout := 'COMPLETE:N';
      ELSE
        IF l_ntf_result = 'REJECTED' THEN
          resultout := 'COMPLETE:REJECTED';
          return;
        ELSIF l_ntf_result = 'APPROVED' THEN
          resultout := 'COMPLETE:APPROVED';
         return;
        END IF;
      END IF;

      --rkuttiya commented for fixing problem identified during bug:2923037
         -- resultout := 'COMPLETE:YES';
         -- return;
        END IF;
        --Run Mode
      --rkuttiya added for fixing problem identified during bug:2923037
        IF funcmode = 'RUN' THEN
           resultout := 'COMPLETE:'||l_ntf_result;
          return;
        END IF;
        --Transfer Mode
        IF funcmode = 'TRANSFER' THEN
          resultout := wf_engine.eng_null;
          return;
        END IF;
        -- CANCEL mode
        IF (funcmode = 'CANCEL') THEN
          resultout := 'COMPLETE:NO';
          return;
        END IF;
        -- TIMEOUT mode
        IF (funcmode = 'TIMEOUT') THEN
          resultout := 'COMPLETE:NO';
          return;
        END IF;
      EXCEPTION
        WHEN OKL_API.G_EXCEPTION_ERROR THEN
          wf_core.context('OKL_CONVERT_INT_TYPE_WF',
                          'Convert_Interest_Type',
                           itemtype,
                           itemkey,
                           to_char(actid),
                           funcmode);
    	  RAISE;
        WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
          wf_core.context('OKL_CONVERT_INT_TYPE_WF',
                          'Convert_Interest_Type',
                           itemtype,
                           itemkey,
                           to_char(actid),
                           funcmode);
    	  RAISE;
        WHEN OTHERS THEN
          wf_core.context('OKL_CONVERT_INT_TYPE_WF',
                          'Convert_Interest_Type',
                           itemtype,
                           itemkey,
                           to_char(actid),
                           funcmode);
    	  RAISE;
  END contract_approval;


END okl_convert_int_TYPE_wf;


/
