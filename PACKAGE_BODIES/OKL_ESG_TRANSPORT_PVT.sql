--------------------------------------------------------
--  DDL for Package Body OKL_ESG_TRANSPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ESG_TRANSPORT_PVT" AS
/* $Header: OKLESTRB.pls 120.0.12010000.3 2009/07/29 10:08:07 racheruv ship $ */

  ---------------------------------------------------------------------------
  -- PRIVATE MEMBER VARIABLES
  ---------------------------------------------------------------------------
  G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
  G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  G_IS_DEBUG_EXCEPTION_ON BOOLEAN;
  G_IS_DEBUG_ERROR_ON BOOLEAN;
  G_IS_DEBUG_PROCEDURE_ON BOOLEAN;

  PROCEDURE transport(p_transaction_number  IN NUMBER)
  IS
    request   utl_http.req;
    response  utl_http.resp;

    CURSOR c_tp IS
    SELECT p.party_id, tp.tp_header_id, tp.party_site_id, tp.party_type
      FROM ecx_tp_headers tp
         , hz_parties p
     WHERE tp.party_id = p.party_id
       AND p.party_name = 'SuperTrump';

    CURSOR c_tt (b_transaction_number NUMBER) is
    SELECT t.ext_subtype, t.protocol_address, t.username, t.password,
           t.protocol_type   -- added bug8209104
      FROM ecx_tp_details_v t
         , okl_stream_interfaces si
     WHERE t.transaction_type = 'OKL_ST'
       AND t.transaction_subtype = si.deal_type
       AND si.transaction_number = b_transaction_number;

    rec  c_tp%ROWTYPE;
    rec2 c_tt%ROWTYPE;

    l_url VARCHAR2(255);
    l_path VARCHAR2(255);
    l_password VARCHAR2(255);

    l_max_timeout NUMBER := 3600; -- seconds
    inbound_buffer VARCHAR2(32767);
    l_parameter_data VARCHAR2(4096);

    ctime DATE;

    l_api_name CONSTANT VARCHAR2(30) := 'transport';
    l_module VARCHAR2(255) := G_MODULE||'.'||l_api_name||'.'||p_transaction_number;
  BEGIN
    IF(G_IS_DEBUG_PROCEDURE_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, l_module, p_transaction_number||': begin okl_esg_transport_pvt.transport');
    END IF;

    OPEN c_tp;
    FETCH c_tp INTO rec;
    CLOSE c_tp;

    OPEN c_tt(p_transaction_number);
    FETCH c_tt INTO rec2;
    CLOSE c_tt;

    l_url := rec2.protocol_address;

    l_parameter_data :=
             'TRANSACTION_TYPE=OKL_ST'||
             '&'||'TRANSACTION_SUBTYPE='||rec2.ext_subtype||
             '&'||'DOCUMENT_NUMBER='||p_transaction_number||
             '&'||'PARTYID='||rec.party_id||
             '&'||'PARTY_SITE_ID='||rec.party_site_id||
             '&'||'PARTY_TYPE='||rec.party_type||
             '&'||'PROTOCOL_TYPE='||rec2.protocol_type||
             '&'||'PROTOCOL_ADDRESS='||rec2.protocol_address||
             '&'||'USERNAME='||rec2.username||
             '&'||'PASSWORD=XXXX'||'&';

    ----------------------------------------------------------------------------------
    -- 1. Send the outbound xml to Proxy Server
    ----------------------------------------------------------------------------------
    utl_http.set_transfer_timeout(l_max_timeout);
   -- bug8209104 start
    IF upper(rec2.protocol_type) = 'HTTPS' THEN
       IF(G_IS_DEBUG_PROCEDURE_ON) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, l_module, p_transaction_number||': calling UTL_HTTP.SET_WALLET');
         END IF;

      l_path :=  'file:' || fnd_profile.value('FND_DB_WALLET_DIR');
      l_password := fnd_preference.eget('#INTERNAL','WF_WEBSERVICES','EWALLETPWD', 'WFWS_PWD');

      UTL_HTTP.SET_WALLET (l_path, l_password);

    END IF;
   -- bug8209104 end

    -- request := utl_http.begin_request(l_url, 'POST', 'HTTP/1.0');  -- commented bug8209104
IF(G_IS_DEBUG_PROCEDURE_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, l_module, p_transaction_number||': calling utl_http.begin_request');
END IF;
    request := utl_http.begin_request(url=>l_url,  method=>'POST');   -- added bug8209104
IF(G_IS_DEBUG_PROCEDURE_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, l_module, p_transaction_number||': calling utl_http.set_header');
END IF;
    utl_http.set_header(request, 'Content-Type', 'application/x-www-form-urlencoded');
    utl_http.set_header(request, 'Content-Length', lengthb(l_parameter_data));
    utl_http.write_text(request, l_parameter_data);

    ----------------------------------------------------------------------------------
    -- 2. Get response from Proxy Server
    ----------------------------------------------------------------------------------
    response := utl_http.get_response(request);
    utl_http.read_text(response, inbound_buffer);
    utl_http.end_response(response);

    IF(G_IS_DEBUG_PROCEDURE_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, l_module, p_transaction_number||': end okl_esg_transport_pvt.transport');
    END IF;
  END transport;

  PROCEDURE store_outxml(p_transaction_number IN NUMBER, p_xml IN CLOB)
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    l_api_name CONSTANT VARCHAR2(30) := 'store_outxml';
    l_module VARCHAR2(255) := G_MODULE||'.'||l_api_name||'.'||p_transaction_number;

	-- temp clob to store corrected out_xml. remove the CDATA formating by ECX
	l_temp_clob        CLOB;
	l_contract_id      number;
	l_orig_contract_id number;
	l_trx_reference    number;

    CURSOR get_orig_contract_csr( p_khr_id    IN NUMBER)
    IS
    SELECT rbk_chr.orig_system_id1    original_chr_id
      FROM okc_k_headers_all_b rbk_chr,
           okl_trx_contracts_all trx
     WHERE trx.khr_id_new = rbk_chr.id
       AND trx.tsu_code = 'ENTERED'
       AND trx.tcn_type = 'TRBK'
       AND rbk_chr.id = p_khr_id
       AND rbk_chr.orig_system_source_code = 'OKL_REBOOK'
    UNION
    SELECT orig_chr.id                original_chr_id
      FROM okc_k_headers_all_b orig_chr,
           okl_trx_contracts_all trx
     WHERE  orig_chr.id    =  p_khr_id
      AND  trx.khr_id     =  orig_chr.id
      AND  trx.tsu_code   = 'ENTERED'
      AND  trx.tcn_type   = 'TRBK'
      AND  EXISTS
           (
            SELECT '1'
              FROM okl_rbk_selected_contract rbk_chr
             WHERE rbk_chr.khr_id = orig_chr.id
               AND rbk_chr.status <> 'PROCESSED'
            );

   cursor get_purpose_code(p_transaction_number number) IS
   select NVL(purpose_code, 'PRIMARY') purpose_code
     from okl_stream_interfaces
    where transaction_number = p_transaction_number;

   cursor get_trx_reference(p_khr_id number, p_purpose_code varchar2) IS
   select a.transaction_number
     from okl_stream_trx_data a, okl_stream_interfaces b
    where a.orig_khr_id = p_khr_id
	  and a.last_trx_state = 'Y'
	  and a.transaction_number = b.transaction_number
	  and NVL(b.purpose_code, 'PRIMARY') = p_purpose_code;

	l_purpose_code  varchar2(20);

  BEGIN
    IF(G_IS_DEBUG_PROCEDURE_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, l_module, p_transaction_number||': begin okl_esg_transport_pvt.store_outxml');
    END IF;

    -- remove the extraneous tags added by ECX formatting for the former transaction state.

	l_temp_clob := p_xml;

	if instr(p_xml, '<![CDATA[') > 0 then
	  l_temp_clob := substr(p_xml, 1, instr(p_xml, '<![CDATA[') -1);
	  l_temp_clob := l_temp_clob || substr(p_xml, instr(p_xml, '<![CDATA[', 1) + length('<![CDATA['),
	                       instr(p_xml, ']]>')  - instr(p_xml, '<![CDATA[', 1) - length('<![CDATA['));
	  l_temp_clob := l_temp_clob || substr(p_xml, instr(p_xml, ']]></FormerTransactionState>') + length(']]>'));
    end if;

	-- get the current contract_id. this could be a copy_contract_id
	select khr_id
	  into l_contract_id
	  from okl_stream_interfaces
     where transaction_number = p_transaction_number;

	-- based on the above contract_id, get the original contract_id.
	-- this is applicable to online rebooks.
	open get_orig_contract_csr(l_contract_id);
	fetch get_orig_contract_csr into l_orig_contract_id;
	close get_orig_contract_csr;

	if l_orig_contract_id is null then
       l_orig_contract_id := l_contract_id;
	end if;

	open get_purpose_code(p_transaction_number);
	fetch get_purpose_code into l_purpose_code;
	close get_purpose_code;

	open get_trx_reference(l_orig_contract_id, l_purpose_code);
	fetch get_trx_reference into l_trx_reference;
	close get_trx_reference;

    INSERT INTO OKL_STREAM_TRX_DATA
    (id,
	 transaction_number,
	 out_xml,
	 khr_id,
	 orig_khr_id,
	 last_trx_state,
	 trx_reference)
    VALUES
    (p_transaction_number
    ,p_transaction_number
    ,l_temp_clob
	,l_contract_id
	,l_orig_contract_id
	,NULL
	,l_trx_reference
    );

    COMMIT;

    IF(G_IS_DEBUG_PROCEDURE_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, l_module, p_transaction_number||': end okl_esg_transport_pvt.store_outxml');
    END IF;

  END store_outxml;

  PROCEDURE process_esg(p_transaction_number  IN NUMBER
                       ,x_return_status      OUT NOCOPY VARCHAR2)
  IS
    l_api_name CONSTANT VARCHAR2(30) := 'process_esg';
    l_outbound_xml CLOB;
    l_inbound_xml CLOB;

    l_resultout VARCHAR2(1);
    amount     Binary_integer := 0;

    l_return_status VARCHAR2(1);
    l_timeout NUMBER;

    ctime DATE;

    l_module VARCHAR2(255) := G_MODULE||'.'||l_api_name||'.'||p_transaction_number;
  BEGIN
    x_return_status := G_RET_STS_SUCCESS;

    IF(G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_EXCEPTION_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_EXCEPTION);
    END IF;

    IF(G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_PROCEDURE);
    END IF;

    IF(G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_ERROR_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_ERROR);
    END IF;

    IF(G_IS_DEBUG_PROCEDURE_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, l_module, p_transaction_number||': begin okl_esg_transport_pvt.process_esg');
    END IF;

    ----------------------------------------------------------------------------------
    -- 1. Generate an outbound xml document from XML Gateway
    ----------------------------------------------------------------------------------
    l_outbound_xml := okl_xmlgen_pvt.generate_xmldocument(p_transaction_number);

    ----------------------------------------------------------------------------------
    -- 2. Store the outbound xml into OKL_STREAM_TRX_DATA table
    ----------------------------------------------------------------------------------
    store_outxml(p_transaction_number, l_outbound_xml);

    ----------------------------------------------------------------------------------
    -- 3. Transporting outbound xml to Proxy Server
    ----------------------------------------------------------------------------------
    transport(p_transaction_number);

    IF(G_IS_DEBUG_PROCEDURE_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, l_module, p_transaction_number||': end okl_esg_transport_pvt.process_esg');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF(G_IS_DEBUG_ERROR_ON) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_ERROR, l_module, p_transaction_number||': '||SQLERRM(SQLCODE));
      END IF;

      OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM
                         );
      x_return_status := G_RET_STS_UNEXP_ERROR;
  END process_esg;

END OKL_ESG_TRANSPORT_PVT;

/
