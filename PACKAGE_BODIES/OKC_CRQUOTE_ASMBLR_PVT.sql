--------------------------------------------------------
--  DDL for Package Body OKC_CRQUOTE_ASMBLR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CRQUOTE_ASMBLR_PVT" AS
/* $Header: OKCRCQKB.pls 120.0 2005/05/25 18:38:07 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

--  g_pkg_name     CONSTANT varchar2(100) := 'OKC_CRQUOTE_ASMBLR_PVT';

  PROCEDURE acn_assemble(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
--
    p_contract_id                  IN NUMBER,
    p_quote_number                 IN NUMBER ) IS
--
    l_api_name            CONSTANT VARCHAR2(30) := 'ACN_ASSEMBLE';
    l_api_version         NUMBER := 1.0;
    l_init_msg_list       VARCHAR2(1) ;
    l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
--
    CURSOR k_cur IS
    SELECT k.contract_number contract_number
	  ,k.contract_number_modifier contract_number_modifier
	  ,k.estimated_amount estimated_amount
	  ,k.sts_code sts_code
	  ,c.cls_code cls_code
	  ,c.code subcls_code
    FROM  okc_k_headers_b k,
          okc_subclasses_v c
    WHERE k.scs_code = c.code
    AND   k.id = p_contract_id;
    k_rec k_cur%ROWTYPE;

    CURSOR acn_cur IS
    SELECT aae.element_name element_name,
	       aae.format_mask format_mask
    FROM   okc_actions_b acn,
           okc_action_attributes_b aae
    WHERE  acn.id = aae.acn_id
    AND    acn.correlation = 'KCRQUOTE';
    acn_rec acn_cur%ROWTYPE;

   l_contract_id              varchar2(120) := to_char(p_contract_id);
   l_contract_number          varchar2(120);
   l_contract_number_modifier varchar2(120);
   l_quote_number             varchar2(120) := to_char(p_quote_number);
--
   l_rec okc_aq_pvt.corrid_rec_typ;
   l_tbl okc_aq_pvt.msg_tab_typ;
   i  NUMBER := 1;
--
    BEGIN
    -- call start_activity to create savepoint, check comptability
    -- and initialize message list
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,l_init_msg_list
                                                ,'_PVT'
                                                ,x_return_status
                                                );
    -- check if activity started successfully
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

    l_rec.corrid := 'KCRQUOTE';
 -- check if action is enabled
  IF OKC_K_SIGN_ASMBLR_PVT.isActionEnabled(l_rec.corrid) = 'Y' THEN
    l_tbl := okc_aq_pvt.msg_tab_typ();

    FOR acn_rec IN acn_cur LOOP
      OPEN k_cur;
      FETCH k_cur INTO k_rec;
        IF acn_rec.element_name = 'K_ID' THEN
          l_tbl.extend;
          l_tbl(i).element_name := acn_rec.element_name;
          l_tbl(i).element_value := p_contract_id;
        ELSIF acn_rec.element_name = 'K_NUMBER' THEN
          l_tbl.extend;
          l_tbl(i).element_name := 'K_NUMBER';
          l_tbl(i).element_value := k_rec.contract_number;
        ELSIF acn_rec.element_name = 'K_NBR_MOD' THEN
          l_tbl.extend;
          l_tbl(i).element_name := 'K_NBR_MOD';
          l_tbl(i).element_value := k_rec.contract_number_modifier;
        ELSIF acn_rec.element_name = 'K_CLASS' THEN
          l_tbl.extend;
          l_tbl(i).element_name := 'K_CLASS';
          l_tbl(i).element_value := k_rec.cls_code;
        ELSIF acn_rec.element_name = 'K_SUBCLASS' THEN
          l_tbl.extend;
          l_tbl(i).element_name := 'K_SUBCLASS';
          l_tbl(i).element_value := k_rec.subcls_code;
        ELSIF acn_rec.element_name = 'ESTIMATED_AMOUNT' THEN
          l_tbl.extend;
          l_tbl(i).element_name := 'ESTIMATED_AMOUNT';
          l_tbl(i).element_value := k_rec.estimated_amount;
       ELSIF acn_rec.element_name = 'QUOTE_NUMBER' THEN
          l_tbl.extend;
          l_tbl(i).element_name := 'QUOTE_NUMBER';
          l_tbl(i).element_value := P_QUOTE_NUMBER;
       END IF;
       i := i+1;
      CLOSE k_cur;
     END LOOP;

    okc_aq_pvt.send_message(p_api_version   =>  l_api_version
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,x_return_status => x_return_status
                            ,p_corrid_rec    => l_rec
                            ,p_msg_tab       => l_tbl
                            ,p_queue_name    => okc_aq_pvt.g_event_queue_name
                            );
    -- check if activity started successfully
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
END IF; -- OKC_K_SIGN_ASMBLR_PVT.isActionEnabled
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    EXCEPTION
       WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT');
       WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT');
       WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT');
    END acn_assemble;

END OKC_CRQUOTE_ASMBLR_PVT;

/
