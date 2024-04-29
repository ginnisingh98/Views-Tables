--------------------------------------------------------
--  DDL for Package Body OKL_PAYMENT_PLAN_APP_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PAYMENT_PLAN_APP_WF" AS
/* $Header: OKLRQPSB.pls 120.2 2006/07/21 13:14:21 akrangan noship $ */


  ----------------------------------------------------------------------------------
  -- PROCEDURE raise_payment_plan_app_event
  ----------------------------------------------------------------------------------
  PROCEDURE raise_payment_plan_app_event (p_rul_id        IN  NUMBER,
                                          x_return_status OUT NOCOPY VARCHAR2) AS

    CURSOR okl_key_csr IS
    SELECT okl_wf_item_s.nextval
    FROM  dual;

    l_parameter_list    wf_parameter_list_t;
    l_key               VARCHAR2(240);
    l_event_name        CONSTANT VARCHAR2(100) := 'oracle.apps.okl.so.approvepayment';
    l_seq               NUMBER;

    lx_return_status    VARCHAR2(1);

  BEGIN

    OPEN okl_key_csr;
    FETCH okl_key_csr INTO l_seq;
    CLOSE okl_key_csr;

    l_key := l_event_name ||l_seq;

    wf_event.AddParameterToList('RULE_ID',p_rul_id,l_parameter_list);

--DBMS_OUTPUT.PUT_LINE('Calling wf_event.raise    l_key '||l_key);
    --added by akrangan
     wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);

    -- Raise Event
    wf_event.raise(p_event_name  => l_event_name,
                   p_event_key   => l_key,
                   p_parameters  => l_parameter_list);

    l_parameter_list.DELETE;
    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => sqlcode,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END raise_payment_plan_app_event;



  ----------------------------------------------------------------------------------
  -- PROCEDURE populate_attributes
  ----------------------------------------------------------------------------------
  PROCEDURE populate_attributes(itemtype  IN VARCHAR2,
                                itemkey   IN VARCHAR2,
                                actid     IN NUMBER,
                                funcmode  IN VARCHAR2,
                                resultout OUT NOCOPY VARCHAR2) AS

    l_api_name          CONSTANT VARCHAR2(30)  := 'populate_attributes';

    l_rulv_rec          okc_rule_pub.rulv_rec_type;
    lx_rulv_rec         okc_rule_pub.rulv_rec_type;

    lx_return_status    VARCHAR2(1);
    lx_msg_count        NUMBER;
    lx_msg_data         VARCHAR2(4000);

  BEGIN

--DBMS_OUTPUT.PUT_LINE('BEGIN populate_attributes funcmode - '||funcmode);

    IF (funcmode = 'RUN') THEN

      l_rulv_rec.id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                 itemkey  => itemkey,
                                                 aname    => 'RULE_ID');

      l_rulv_rec.rule_information1 := 'APPROVED';

      okc_rule_pub.update_rule(p_api_version   => G_API_VERSION,
                               p_init_msg_list => G_FALSE,
                               p_rulv_rec      => l_rulv_rec,
                               x_rulv_rec      => lx_rulv_rec,
                               x_return_status => lx_return_status,
                               x_msg_count     => lx_msg_count,
                               x_msg_data      => lx_msg_data);

--DBMS_OUTPUT.PUT_LINE('Back from update of SOPSST rule '||lx_return_status);

      IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      resultout := 'COMPLETE:';
      RETURN;

    END IF;

    -- CANCEL mode
    IF (funcmode = 'CANCEL') then
      resultout := 'COMPLETE:';
      RETURN;
    END IF;

    -- TIMEOUT mode
    IF (funcmode = 'TIMEOUT') then
      resultout := 'COMPLETE:';
      RETURN;
    END IF;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      wf_core.context(G_PKG_NAME, l_api_name, itemtype, itemkey, actid, funcmode);
      RAISE;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      wf_core.context(G_PKG_NAME, l_api_name, itemtype, itemkey, actid, funcmode);
      RAISE;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => sqlcode,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => sqlerrm);

      wf_core.context(G_PKG_NAME, l_api_name, itemtype, itemkey, actid, funcmode);
      RAISE;

  END populate_attributes;

END okl_payment_plan_app_wf;

/
