--------------------------------------------------------
--  DDL for Package Body OKL_CONTRACT_APP_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CONTRACT_APP_WF" AS
/* $Header: OKLRQAXB.pls 120.2 2006/07/21 13:14:03 akrangan noship $ */


  -------------------------------------------------------------------------------
  -- PROCEDURE l_change_k_status
  -------------------------------------------------------------------------------
  PROCEDURE l_change_k_status(p_chr_id         IN  NUMBER,
                              p_khr_status     IN  VARCHAR2,
                              x_return_status  OUT NOCOPY VARCHAR2) IS

    lx_return_status  VARCHAR2(1);
    lx_msg_count      NUMBER;
    lx_msg_data       VARCHAR2(4000);

  BEGIN

    okl_contract_status_pub.update_contract_status(p_api_version   => G_API_VERSION,
                                                   p_init_msg_list => G_FALSE,
                                                   p_khr_status    => p_khr_status,
                                                   p_chr_id        => p_chr_id,
                                                   x_return_status => lx_return_status,
                                                   x_msg_count     => lx_msg_count,
                                                   x_msg_data      => lx_msg_data);

    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    okl_contract_status_pub.cascade_lease_status(p_api_version   => G_API_VERSION,
                                                 p_init_msg_list => G_FALSE,
                                                 p_chr_id        => p_chr_id,
                                                 x_return_status => lx_return_status,
                                                 x_msg_count     => lx_msg_count,
                                                 x_msg_data      => lx_msg_data);

    IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status :=  lx_return_status;


  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => sqlcode,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END l_change_k_status;


  -------------------------------------------------------------------------------
  -- PROCEDURE raise_contract_approval_event
  -------------------------------------------------------------------------------
  PROCEDURE raise_contract_approval_event (p_contract_id   IN NUMBER,
                                           x_return_status OUT NOCOPY VARCHAR2) IS

    l_parameter_list        wf_parameter_list_t;
    l_key                   VARCHAR2(240);
    l_event_name            VARCHAR2(240) := 'oracle.apps.okl.so.acceptquote';
    l_seq                   NUMBER;

    CURSOR okl_key_csr IS
    SELECT okl_wf_item_s.nextval
    FROM  dual;

  BEGIN

    OPEN okl_key_csr;
    FETCH okl_key_csr INTO l_seq;
    CLOSE okl_key_csr;

    l_key := l_event_name ||l_seq;

    wf_event.AddParameterToList('QUOTE_NUM', p_contract_id, l_parameter_list);
    --added by akrangan
    wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);

--DBMS_OUTPUT.PUT_LINE('Calling wf_event.raise');
--DBMS_OUTPUT.PUT_LINE('l_key '||l_key);

    wf_event.raise(p_event_name => l_event_name,
                   p_event_key  => l_key,
                   p_parameters => l_parameter_list);

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

  END raise_contract_approval_event;



  -------------------------------------------------------------------------------
  -- PROCEDURE populate_attributes
  -------------------------------------------------------------------------------
  PROCEDURE populate_attributes(itemtype   IN  VARCHAR2,
                                itemkey    IN  VARCHAR2,
                                actid      IN  NUMBER,
                                funcmode   IN  VARCHAR2,
                                resultout  OUT NOCOPY VARCHAR2) IS

    l_api_name          CONSTANT VARCHAR2(30)  := 'populate_attributes';

    l_contract_num      OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE;
    l_chrv_id           OKC_K_HEADERS_V.ID%TYPE;

    CURSOR c_fetch_k_number(p_contract_id OKC_K_HEADERS_V.ID%TYPE)
    IS
    SELECT chrv.contract_number
    FROM okc_k_headers_v chrv
    WHERE chrv.id = p_contract_id;

    lx_return_status  VARCHAR2(1);

  BEGIN

--DBMS_OUTPUT.PUT_LINE('BEGIN populate_attributes '||'funcmode '||funcmode);

    IF (funcmode = 'RUN') THEN

      l_chrv_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'QUOTE_NUM');

--DBMS_OUTPUT.PUT_LINE('l_chrv_id '||l_chrv_id);

      OPEN  c_fetch_k_number(l_chrv_id);
      FETCH c_fetch_k_number INTO l_contract_num;
      CLOSE c_fetch_k_number;

      wf_engine.SetItemAttrText (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'QUOTE_NUM',
                                 avalue   => l_contract_num);

      l_change_k_status(p_khr_status    => 'ACCEPTED',
                        p_chr_id        => l_chrv_id,
                        x_return_status => lx_return_status);

--DBMS_OUTPUT.PUT_LINE('Back from  l_change_k_status '||lx_return_status);

      IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF lx_return_status = G_RET_STS_ERROR THEN
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

END OKL_CONTRACT_APP_WF;

/
