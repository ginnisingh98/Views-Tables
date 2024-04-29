--------------------------------------------------------
--  DDL for Package Body OKL_AM_CREATE_QUOTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_CREATE_QUOTE_PVT" AS
/* $Header: OKLRCQTB.pls 120.30.12010000.2 2009/06/15 22:00:33 sechawla ship $ */

-- GLOBAL VARIABLES
  G_LEVEL_PROCEDURE             CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT             CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_LEVEL_EXCEPTION		CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_MODULE_NAME                 CONSTANT VARCHAR2(500) := 'okl.am.plsql.okl_am_create_quote_pvt.';

  SUBTYPE rulv_rec_type  IS  OKL_RULE_PUB.rulv_rec_type;
 -- SUBTYPE asset_tbl_type IS  OKL_AM_CALCULATE_QUOTE_PVT.asset_tbl_type;

  -- Start of comments
  --
  -- Procedure Name	: asset_number_exists
  -- Desciption     : Returns via x_asset_exists if the asset_number exists in FA
  -- Business Rules	:
  -- Parameters	    :
  -- Version	    : 1.0
  -- History        : RMUNJULU 2757312  created
  --                : RMUNJULU 3241502 Added p_control + major revamp of the processing
  --                  IS NOW ALSO CALLED FROM OKL_AM_CNTRCT_LN_TRMNT_PVT
  --                : RMUNJULU 3241502 Added UPPER to asset_number
  --
  -- End of comments
  FUNCTION asset_number_exists(p_asset_number IN VARCHAR2,
                               p_control      IN VARCHAR2 DEFAULT NULL,
                               x_asset_exists OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS

        l_asset_exists VARCHAR2(1) DEFAULT 'N';
        l_return_status VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;

        --chk for asset in FA
	--Updated the sql statement for performance issue #5484903
	-- by excluding UPPER function to do Index scan
        CURSOR asset_chk_curs1 (p_asset_number IN VARCHAR2) IS
	SELECT 'Y' a
        FROM   okx_assets_v okx
        WHERE  UPPER(okx.asset_number) = p_asset_number
        and
	    ( okx.asset_number like Initcap(substr(p_asset_number,1,2))||'%'
               or
               okx.asset_number like lower(substr(p_asset_number,1))||Upper(substr(p_asset_number,2,1))||'%'
               or
               okx.asset_number like Upper(substr(p_asset_number,1,2))||'%'
               or
               okx.asset_number like lower(substr(p_asset_number,1,2))||'%'
             );



        --chk for asset on asset line
	--Updated the sql statement for performance issue #5484903
	-- by excluding UPPER function to do Index scan
        CURSOR asset_chk_curs2 (p_asset_number IN VARCHAR2) IS
        SELECT 'Y' a
        FROM   okc_k_lines_v kle,
               okc_line_styles_b  lse
        WHERE  kle.lse_id = lse.id
        AND    lse.lty_code = 'FREE_FORM1'
        AND  UPPER(kle.NAME) = p_asset_number  -- RMUNJULU 3241502
        AND ( kle.NAME like Initcap(substr(p_asset_number,1,2))||'%'
               or
               kle.NAME like lower(substr(p_asset_number,1))||Upper(substr(p_asset_number,2,1))||'%'
               or
               kle.NAME like Upper(substr(p_asset_number,1,2))||'%'
              or
               kle.NAME like lower(substr(p_asset_number,1,2))||'%'
             ) ;



        --check for asset on an split asset transaction
        CURSOR asset_chk_curs3 (p_asset_number IN VARCHAR2) is
        SELECT 'Y' a
        FROM   okl_txd_assets_b txd
        WHERE  NVL(UPPER(txd.asset_number),'-999999999999999') = UPPER(p_asset_number) -- RMUNJULU 3241502
        AND    EXISTS (SELECT NULL
                       FROM   okl_trx_Assets   trx,
                              okl_trx_types_tl ttyp,
                              okl_txl_assets_b txl
                       WHERE  trx.id        = txl.tas_id
                       AND    trx.try_id    = ttyp.id
                       AND    ttyp.name     = 'Split Asset'
                       AND    ttyp.language = 'US'
                       AND    txl.id        = txd.tal_id);

    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'asset_number_exists';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);


  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

     FOR asset_chk_rec1 IN asset_chk_curs1 (p_asset_number) LOOP
        l_asset_exists := asset_chk_rec1.a;
     END LOOP;
     IF l_asset_exists <> 'Y' THEN
        FOR asset_chk_rec2 IN asset_chk_curs2 (p_asset_number) LOOP
           l_asset_exists := asset_chk_rec2.a;
        END LOOP;
     END IF;
     IF p_control = 'QUOTE' THEN
        IF l_asset_exists <> 'Y' THEN
           FOR asset_chk_rec3 IN asset_chk_curs3 (p_asset_number) LOOP
              l_asset_exists := asset_chk_rec3.a;
           END LOOP;
        END IF;
     END IF;
     x_asset_exists := l_asset_exists;


   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

     RETURN(l_return_status);
  EXCEPTION
     WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKL_API.set_message(
                         p_app_name      => g_app_name,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
        l_return_status := OKL_API.G_RET_STS_ERROR;
        RETURN(l_return_status);
  END asset_number_exists;



  -------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : advance_contract_search
-- Description          : Procedure used for doing advance search on contract
--                        details
-- Business Rules       : The search critriea will be given thru achr_rec_type
--                        in the form either contract number,
--                        contract start date,contract end date,
--                        asset number,serial number or customer name.
--                        The output will PL/sql table of record of
--                        achr_rec_type and will contain contract number,
--                        chr_id, contract start date, contract end date,
--                        customer name,authoring org id of the contract
--                        or status of the contract.
--                        To avoid the performance problem we use
--                        this PKG instead of View.
-- Parameters           : IN record of achr_rec_type
--                        OUT PL/SQL Table of Record achr_tbl_type
--                        x_return_status OUT NOCOPY VARCHAR2
-- Version              : 1.0
-- History              : BAKUCHIB  28-DEC-2002 - 2699412 created
--                        SECHAWLA  02-JAN-03  - Moved this procedure from okl_am_util_pvt to this API
--                       GKADARKA  06-JAN-03  2736875 Added order by contract number asc  in advance_contract_search
--                                  porcedure cursor.
--                       BAKUCHIB 16-JAN-03 2748110
--                          Modified the Advance_contract_search procedure
--                          by checking for addtionaly Contract Status and
--                          Line Status. The Addional Contract Status and
--                          Line status are 'EVERGREEN','BANKRUPTCY_HOLD',
--                          'LITIGATION_HOLD','TERMINATION_HOLD' other than
--                          'BOOKED'.Also modified the queries by adding
--                           stripping by org_id.If the input org_id is null
--                           then we set the org_id with the client info
--                       BAKUCHIB 17-JAN-03 2748110
--                          Modified the Advance_contract_search procedure
--                          by removing Line Status checking.
--                       BAKUCHIB 04-FEB-03 2781134
--                          Modified the Advance_contract_search procedure
--                          by adding case insenstive search on columns contract
--                          number, asset number, start date, end date and party
--                          name.
--                       BAKUCHIB 19-Feb-2003 2807201
--                          Modified the advance serach by removing the upper
--                          in the where clause on start date and end date of all the cursors.
-- End of Commnets

  Procedure advance_contract_search(
            p_api_version          IN  NUMBER,
            p_init_msg_list        IN  VARCHAR2,
            x_return_status        OUT NOCOPY VARCHAR2,
            x_msg_count            OUT NOCOPY NUMBER,
            x_msg_data             OUT NOCOPY VARCHAR2,
            p_achr_rec             IN achr_rec_type,
            x_achr_tbl             OUT NOCOPY achr_tbl_type) IS
  l_api_version    CONSTANT NUMBER := 1;
  l_api_name       CONSTANT VARCHAR2(30) := 'ADVANCE_CONTRACT_SEARCH';
  i                         NUMBER := 0;
  l_achr_rec                achr_rec_type := p_achr_rec;
  l_achr_tbl                achr_tbl_type;

  -- Get the contract details
  CURSOR get_chr_dtls_csr(p_achr_rec IN achr_rec_type)
  IS
  SELECT chr.id chr_id,
         chr.contract_number contract_number,
         chr.start_date from_start_date,
         chr.end_date from_end_date,
         stl.code sts_code,
         stl.meaning sts_meaning,
         chr.authoring_org_id org_id,
         hp.party_name party_name
  FROM okc_statuses_tl stl,
       hz_parties hp,
       okc_k_party_roles_b cpl,
       okc_k_headers_b chr
-- BAKUCHIB 2781134 start
  WHERE upper(chr.contract_number) LIKE upper(nvl(p_achr_rec.contract_number,chr.contract_number))
-- BAKUCHIB 2807201 start
  AND nvl(chr.start_date,to_date('1111','yyyy')) BETWEEN nvl(p_achr_rec.from_start_date,nvl(chr.start_date,to_date('1111','yyyy'))) AND nvl(p_achr_rec.to_start_date,nvl(chr.start_date,to_date('1111','yyyy')))
  AND nvl(chr.end_date,to_date('1111','yyyy')) BETWEEN nvl(p_achr_rec.from_end_date,nvl(chr.end_date,to_date('1111','yyyy'))) AND nvl(p_achr_rec.to_end_date,nvl(chr.end_date,to_date('1111','yyyy')))
-- BAKUCHIB 2807201 end
-- BAKUCHIB 2781134 end
-- BAKUCHIB 2748110 Start
  AND chr.sts_code IN ('BOOKED','EVERGREEN','BANKRUPTCY_HOLD','LITIGATION_HOLD','TERMINATION_HOLD')
  AND chr.scs_code IN ('LEASE', 'LOAN')
  AND chr.authoring_org_id = p_achr_rec.org_id
-- BAKUCHIB 2748110 end
  AND chr.id = cpl.dnz_chr_id
  AND cpl.chr_id = cpl.dnz_chr_id
  AND cpl.object1_id1 = hp.party_id
  AND cpl.object1_id2 = '#'
  AND cpl.jtot_object1_code = 'OKX_PARTY'
  AND cpl.rle_code = 'LESSEE'
  AND cpl.cle_id IS NULL
-- BAKUCHIB 2781134 start
  AND upper(hp.party_name) LIKE upper(nvl(p_achr_rec.party_name,hp.party_name))
-- BAKUCHIB 2781134 end
  AND hp.party_type IN ( 'PERSON','ORGANIZATION')
  AND chr.sts_code = stl.code
  AND stl.LANGUAGE = userenv('LANG')
  ORDER BY contract_number ASC;

  -- Get the contract details for asset number
  CURSOR get_for_asset_csr(p_achr_rec IN achr_rec_type)
  IS
  SELECT chr.id chr_id,
         chr.contract_number contract_number,
         chr.start_date from_start_date,
         chr.end_date from_end_date,
         stl.code sts_code,
         stl.meaning sts_meaning,
         chr.authoring_org_id org_id,
         hp.party_name party_name
  FROM okc_statuses_tl stl,
       hz_parties hp,
       okc_k_party_roles_b cpl,
       okc_k_headers_b chr
-- BAKUCHIB 2781134 start
  WHERE upper(chr.contract_number) LIKE upper(nvl(p_achr_rec.contract_number,chr.contract_number))
-- BAKUCHIB 2781134 end
-- BAKUCHIB 2748110 Start
  AND chr.sts_code IN ('BOOKED','EVERGREEN','BANKRUPTCY_HOLD','LITIGATION_HOLD','TERMINATION_HOLD')
  AND chr.scs_code IN ('LEASE', 'LOAN')
  AND chr.authoring_org_id = p_achr_rec.org_id
-- BAKUCHIB 2748110 End
-- BAKUCHIB 2781134 start
-- BAKUCHIB 2807201 start
  AND nvl(chr.start_date,to_date('1111','yyyy')) BETWEEN nvl(p_achr_rec.from_start_date,nvl(chr.start_date,to_date('1111','yyyy'))) AND nvl(p_achr_rec.to_start_date,nvl(chr.start_date,to_date('1111','yyyy')))
  AND nvl(chr.end_date,to_date('1111','yyyy')) BETWEEN nvl(p_achr_rec.from_end_date,nvl(chr.end_date,to_date('1111','yyyy'))) AND nvl(p_achr_rec.to_end_date,nvl(chr.end_date,to_date('1111','yyyy')))
-- BAKUCHIB 2807201 end
-- BAKUCHIB 2781134 end
  AND chr.id = cpl.dnz_chr_id
  AND cpl.chr_id = cpl.dnz_chr_id
  AND cpl.object1_id1 = hp.party_id
  AND cpl.object1_id2 = '#'
  AND cpl.jtot_object1_code = 'OKX_PARTY'
  AND cpl.rle_code = 'LESSEE'
  AND cpl.cle_id IS NULL
-- BAKUCHIB 2781134 start
  AND upper(hp.party_name) LIKE upper(nvl(p_achr_rec.party_name,hp.party_name))
-- BAKUCHIB 2781134 end
  AND hp.party_type IN ( 'PERSON','ORGANIZATION')
  AND chr.sts_code = stl.code
  AND stl.LANGUAGE = userenv('LANG')
  AND chr.id IN (SELECT DISTINCT cle_fin.dnz_chr_id chr_id
                 FROM okc_line_styles_b lse_fin,
                      okc_k_lines_tl clet_fin,
                      okc_k_lines_b cle_fin,
                      okc_k_headers_b chr
                 WHERE cle_fin.cle_id IS NULL
                 AND cle_fin.chr_id = cle_fin.dnz_chr_id
                 AND cle_fin.dnz_chr_id = chr.id
                 AND cle_fin.id = clet_fin.id
                 AND clet_fin.LANGUAGE = userenv('LANG')
                 AND lse_fin.id = cle_fin.lse_id
                 AND lse_fin.lty_code = 'FREE_FORM1'
-- BAKUCHIB 2748110 Start
                 AND chr.sts_code IN ('BOOKED','EVERGREEN','BANKRUPTCY_HOLD','LITIGATION_HOLD','TERMINATION_HOLD')
                 AND chr.scs_code IN ('LEASE', 'LOAN')
                 AND chr.authoring_org_id = p_achr_rec.org_id
-- BAKUCHIB 2748110 End
-- BAKUCHIB 2781134 start
                 AND upper(nvl(clet_fin.name,'x')) LIKE upper(nvl(p_achr_rec.asset_number,nvl(clet_fin.name,'x'))))
-- BAKUCHIB 2781134 end
  ORDER BY contract_number ASC;

  -- Get the chr_id for serial number
  CURSOR get_for_sno_csr(p_achr_rec IN achr_rec_type)
  IS
  SELECT chr.id chr_id,
         chr.contract_number contract_number,
         chr.start_date from_start_date,
         chr.end_date from_end_date,
         stl.code sts_code,
         stl.meaning sts_meaning,
         chr.authoring_org_id org_id,
         hp.party_name party_name
  FROM okc_statuses_tl stl,
       hz_parties hp,
       okc_k_party_roles_b cpl,
       okc_k_headers_b chr
-- BAKUCHIB 2781134 start
  WHERE upper(chr.contract_number) LIKE upper(nvl(p_achr_rec.contract_number,chr.contract_number))
-- BAKUCHIB 2781134 end
-- BAKUCHIB 2748110 Start
  AND chr.sts_code IN ('BOOKED','EVERGREEN','BANKRUPTCY_HOLD','LITIGATION_HOLD','TERMINATION_HOLD')
  AND chr.scs_code IN ('LEASE', 'LOAN')
  AND chr.authoring_org_id = p_achr_rec.org_id
-- BAKUCHIB 2748110 End
-- BAKUCHIB 2781134 start
-- BAKUCHIB 2807201 start
  AND nvl(chr.start_date,to_date('1111','yyyy')) BETWEEN nvl(p_achr_rec.from_start_date,nvl(chr.start_date,to_date('1111','yyyy'))) AND nvl(p_achr_rec.to_start_date,nvl(chr.start_date,to_date('1111','yyyy')))
  AND nvl(chr.end_date,to_date('1111','yyyy')) BETWEEN nvl(p_achr_rec.from_end_date,nvl(chr.end_date,to_date('1111','yyyy'))) AND nvl(p_achr_rec.to_end_date,nvl(chr.end_date,to_date('1111','yyyy')))
-- BAKUCHIB 2807201 end
-- BAKUCHIB 2781134 end
  AND chr.id = cpl.dnz_chr_id
  AND cpl.chr_id = cpl.dnz_chr_id
  AND cpl.object1_id1 = hp.party_id
  AND cpl.object1_id2 = '#'
  AND cpl.jtot_object1_code = 'OKX_PARTY'
  AND cpl.rle_code = 'LESSEE'
  AND cpl.cle_id IS NULL
-- BAKUCHIB 2781134 start
  AND upper(hp.party_name) LIKE upper(nvl(p_achr_rec.party_name,hp.party_name))
-- BAKUCHIB 2781134 end
  AND hp.party_type IN ( 'PERSON','ORGANIZATION')
  AND chr.sts_code = stl.code
  AND stl.LANGUAGE = userenv('LANG')
  AND chr.id IN (SELECT DISTINCT cim_ib.dnz_chr_id chr_id
                 FROM csi_item_instances csi,
                      okc_k_items cim_ib,
                      okc_line_styles_b lse_ib,
                      okc_k_lines_b cle_ib,
                      okc_k_headers_b chr
                 WHERE cle_ib.lse_id = lse_ib.id
                 AND lse_ib.lty_code = 'INST_ITEM'
                 AND cim_ib.cle_id = cle_ib.id
                 AND cim_ib.dnz_chr_id = cle_ib.dnz_chr_id
                 AND cle_ib.dnz_chr_id = chr.id
-- BAKUCHIB 2748110 Start
                 AND chr.sts_code IN ('BOOKED','EVERGREEN','BANKRUPTCY_HOLD','LITIGATION_HOLD','TERMINATION_HOLD')
                 AND chr.scs_code IN ('LEASE', 'LOAN')
                 AND chr.authoring_org_id = p_achr_rec.org_id
-- BAKUCHIB 2748110 End
                 AND cim_ib.object1_id1 = csi.instance_id
                 AND cim_ib.object1_id2 = '#'
                 AND cim_ib.jtot_object1_code = 'OKX_IB_ITEM'
-- BAKUCHIB 2781134 start
                 AND upper(nvl(csi.serial_number,'x')) LIKE upper(nvl(p_achr_rec.serial_number,nvl(csi.serial_number,'x'))))
-- BAKUCHIB 2781134 end
  ORDER BY contract_number ASC;

  -- Get the chr_id for asset number and serial number
  CURSOR get_for_asset_sno_csr(p_achr_rec IN achr_rec_type)
  IS
  SELECT chr.id chr_id,
         chr.contract_number contract_number,
         chr.start_date from_start_date,
         chr.end_date from_end_date,
         stl.code sts_code,
         stl.meaning sts_meaning,
         chr.authoring_org_id org_id,
         hp.party_name party_name
  FROM okc_statuses_tl stl,
       hz_parties hp,
       okc_k_party_roles_b cpl,
       okc_k_headers_b chr
-- BAKUCHIB 2781134 start
  WHERE upper(chr.contract_number) LIKE upper(nvl(p_achr_rec.contract_number,chr.contract_number))
-- BAKUCHIB 2781134 end
-- BAKUCHIB 2748110 Start
  AND chr.sts_code IN ('BOOKED','EVERGREEN','BANKRUPTCY_HOLD','LITIGATION_HOLD','TERMINATION_HOLD')
  AND chr.scs_code IN ('LEASE', 'LOAN')
  AND chr.authoring_org_id = p_achr_rec.org_id
-- BAKUCHIB 2748110 End
-- BAKUCHIB 2781134 start
-- BAKUCHIB 2807201 start
  AND nvl(chr.start_date,to_date('1111','yyyy')) BETWEEN nvl(p_achr_rec.from_start_date,nvl(chr.start_date,to_date('1111','yyyy'))) AND nvl(p_achr_rec.to_start_date,nvl(chr.start_date,to_date('1111','yyyy')))
  AND nvl(chr.end_date,to_date('1111','yyyy')) BETWEEN nvl(p_achr_rec.from_end_date,nvl(chr.end_date,to_date('1111','yyyy'))) AND nvl(p_achr_rec.to_end_date,nvl(chr.end_date,to_date('1111','yyyy')))
-- BAKUCHIB 2807201 end
-- BAKUCHIB 2781134 end
  AND chr.id = cpl.dnz_chr_id
  AND cpl.chr_id = cpl.dnz_chr_id
  AND cpl.object1_id1 = hp.party_id
  AND cpl.object1_id2 = '#'
  AND cpl.jtot_object1_code = 'OKX_PARTY'
  AND cpl.rle_code = 'LESSEE'
  AND cpl.cle_id IS NULL
-- BAKUCHIB 2781134 start
  AND upper(hp.party_name)LIKE upper(nvl(p_achr_rec.party_name,hp.party_name))
-- BAKUCHIB 2781134 end
  AND hp.party_type IN ( 'PERSON','ORGANIZATION')
  AND chr.sts_code = stl.code
  AND stl.LANGUAGE = userenv('LANG')
  AND chr.id IN (SELECT DISTINCT cle_fin.dnz_chr_id chr_id
                 FROM csi_item_instances csi,
                      okc_k_items cim_ib,
                      okc_line_styles_b lse_ib,
                      okc_k_lines_b cle_ib,
                      okc_line_styles_b lse_inst,
                      okc_k_lines_b cle_inst,
                      okc_line_styles_b lse_fin,
                      okc_k_lines_tl clet_fin,
                      okc_k_lines_b cle_fin,
                      okc_k_headers_b chr
                 WHERE cle_fin.cle_id IS NULL
                 AND cle_fin.chr_id = cle_fin.dnz_chr_id
                 AND cle_fin.dnz_chr_id = chr.id
-- BAKUCHIB 2748110 Start
                 AND chr.sts_code IN ('BOOKED','EVERGREEN','BANKRUPTCY_HOLD','LITIGATION_HOLD','TERMINATION_HOLD')
                 AND chr.scs_code IN ('LEASE', 'LOAN')
                 AND chr.authoring_org_id = p_achr_rec.org_id
-- BAKUCHIB 2748110 End
                 AND cle_fin.id = clet_fin.id
                 AND clet_fin.LANGUAGE = userenv('LANG')
                 AND lse_fin.id = cle_fin.lse_id
                 AND lse_fin.lty_code = 'FREE_FORM1'
                 AND cle_inst.cle_id = cle_fin.id
                 AND cle_inst.dnz_chr_id = cle_fin.dnz_chr_id
                 AND cle_inst.lse_id = lse_inst.id
                 AND lse_inst.lty_code = 'FREE_FORM2'
                 AND cle_ib.cle_id = cle_inst.id
                 AND cle_ib.dnz_chr_id = cle_fin.dnz_chr_id
                 AND cle_ib.lse_id = lse_ib.id
                 AND lse_ib.lty_code = 'INST_ITEM'
                 AND cim_ib.cle_id = cle_ib.id
                 AND cim_ib.dnz_chr_id = cle_ib.dnz_chr_id
                 AND cim_ib.object1_id1 = csi.instance_id
                 AND cim_ib.object1_id2 = '#'
                 AND cim_ib.jtot_object1_code = 'OKX_IB_ITEM'
-- BAKUCHIB 2781134 start
                 AND upper(nvl(csi.serial_number,'x')) LIKE upper(nvl(p_achr_rec.serial_number,nvl(csi.serial_number,'x')))
                 AND upper(nvl(clet_fin.name,'x')) LIKE upper(nvl(p_achr_rec.asset_number,nvl(clet_fin.name,'x'))))
-- BAKUCHIB 2781134 end
  ORDER BY contract_number ASC;
  -- For debug logging
  L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'advance_contract_search';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

   IF (is_debug_procedure_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;
   IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_achr_rec.asset_number :'||p_achr_rec.asset_number);
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_achr_rec.serial_number :'||p_achr_rec.serial_number);
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_achr_rec.chr_id :'||p_achr_rec.chr_id);
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_achr_rec.contract_number:'||p_achr_rec.contract_number  );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_achr_rec.from_start_date:'||p_achr_rec.from_start_date  );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_achr_rec.to_start_date :'||p_achr_rec.to_start_date    );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_achr_rec.from_end_date :'||p_achr_rec.from_end_date    );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_achr_rec.to_end_date :'||p_achr_rec.to_end_date      );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_achr_rec.sts_code :'||p_achr_rec.sts_code         );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_achr_rec.sts_meaning :'||p_achr_rec.sts_meaning     );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_achr_rec.org_id :'||p_achr_rec.org_id           );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_achr_rec.party_name :'||p_achr_rec.party_name     );

   END IF;



    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    x_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
-- BAKUCHIB 2748110 Start
    -- Setting the org_id if the input org_id is null
    IF (l_achr_rec.org_id IS NULL OR
       l_achr_rec.org_id = OKL_API.G_MISS_NUM) THEN
         l_achr_rec.org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
    END IF;
-- BAKUCHIB 2748110 End
    -- If the asset number and serial number when not given.
    IF (l_achr_rec.asset_number = OKL_API.G_MISS_CHAR OR
       l_achr_rec.asset_number IS NULL) AND
       (l_achr_rec.serial_number = OKL_API.G_MISS_CHAR OR
       l_achr_rec.serial_number IS NULL) THEN
      -- Get the contract details
      FOR r_get_chr_dtls_csr IN get_chr_dtls_csr(p_achr_rec => l_achr_rec) LOOP
        IF get_chr_dtls_csr%NOTFOUND THEN
          IF (l_achr_rec.contract_number IS NOT NULL OR
             l_achr_rec.contract_number <> OKL_API.G_MISS_CHAR) THEN
            OKL_API.set_message(p_app_name      => G_APP_NAME,
                                p_msg_name      => G_INVALID_VALUE1,
                                p_token1        => 'COL_NAME',
                                p_token1_value  => 'Contract Number');
          END IF;
          IF (l_achr_rec.from_start_date IS NOT NULL OR
             l_achr_rec.from_start_date <> OKL_API.G_MISS_DATE) OR
             (l_achr_rec.to_start_date IS NOT NULL OR
             l_achr_rec.to_start_date <> OKL_API.G_MISS_DATE) THEN
            OKL_API.set_message(p_app_name      => G_APP_NAME,
                                p_msg_name      => G_INVALID_VALUE1,
                                p_token1        => 'COL_NAME',
                                p_token1_value  => 'Start Date');
          END IF;
          IF (l_achr_rec.from_end_date IS NOT NULL OR
             l_achr_rec.from_end_date <> OKL_API.G_MISS_DATE) OR
             (l_achr_rec.to_end_date IS NOT NULL OR
             l_achr_rec.to_end_date <> OKL_API.G_MISS_DATE) THEN
            OKL_API.set_message(p_app_name      => G_APP_NAME,
                                p_msg_name      => G_INVALID_VALUE1,
                                p_token1        => 'COL_NAME',
                                p_token1_value  => 'End Date');
          END IF;
          IF (l_achr_rec.party_name IS NOT NULL OR
             l_achr_rec.party_name <> OKL_API.G_MISS_CHAR) THEN
            OKL_API.set_message(p_app_name      => G_APP_NAME,
                                p_msg_name      => G_INVALID_VALUE1,
                                p_token1        => 'COL_NAME',
                                p_token1_value  => 'Party Name');
          END IF;
          x_return_status := OKL_API.G_RET_STS_ERROR;
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        x_achr_tbl(i).contract_number  := r_get_chr_dtls_csr.contract_number;
        x_achr_tbl(i).chr_id           := r_get_chr_dtls_csr.chr_id;
        x_achr_tbl(i).from_start_date  := r_get_chr_dtls_csr.from_start_date;
        x_achr_tbl(i).from_end_date    := r_get_chr_dtls_csr.from_end_Date;
        x_achr_tbl(i).sts_code         := r_get_chr_dtls_csr.sts_code;
        x_achr_tbl(i).sts_meaning      := r_get_chr_dtls_csr.sts_meaning;
        x_achr_tbl(i).org_id           := r_get_chr_dtls_csr.org_id;
        x_achr_tbl(i).party_name       := r_get_chr_dtls_csr.party_name;
        i := i + 1;
      END LOOP;
      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    -- If the asset number given and serial number when not given.
    ELSIF (l_achr_rec.asset_number <> OKL_API.G_MISS_CHAR OR
          l_achr_rec.asset_number IS NOT NULL) AND
          (l_achr_rec.serial_number = OKL_API.G_MISS_CHAR OR
          l_achr_rec.serial_number IS NULL) THEN
      -- Get the contract details for asset number
      FOR r_get_for_asset_csr IN get_for_asset_csr(p_achr_rec => l_achr_rec) LOOP
        IF get_for_asset_csr%NOTFOUND THEN
          OKL_API.set_message(p_app_name      => G_APP_NAME,
                              p_msg_name      => G_INVALID_VALUE1,
                              p_token1        => 'COL_NAME',
                              p_token1_value  => 'Asset Number');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        x_achr_tbl(i).contract_number  := r_get_for_asset_csr.contract_number;
        x_achr_tbl(i).chr_id           := r_get_for_asset_csr.chr_id;
        x_achr_tbl(i).from_start_date  := r_get_for_asset_csr.from_start_date;
        x_achr_tbl(i).from_end_date    := r_get_for_asset_csr.from_end_Date;
        x_achr_tbl(i).sts_code         := r_get_for_asset_csr.sts_code;
        x_achr_tbl(i).sts_meaning      := r_get_for_asset_csr.sts_meaning;
        x_achr_tbl(i).org_id           := r_get_for_asset_csr.org_id;
        x_achr_tbl(i).party_name       := r_get_for_asset_csr.party_name;
        i := i + 1;
      END LOOP;
      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    -- If the asset number not given and serial number given.
    ELSIF (l_achr_rec.asset_number = OKL_API.G_MISS_CHAR OR
          l_achr_rec.asset_number IS NULL) AND
          (l_achr_rec.serial_number <> OKL_API.G_MISS_CHAR OR
          l_achr_rec.serial_number IS NOT NULL) THEN
      -- Get the contract details for serial number
      FOR r_get_for_sno_csr IN get_for_sno_csr(p_achr_rec => l_achr_rec) LOOP
        IF get_for_sno_csr%NOTFOUND THEN
          OKL_API.set_message(p_app_name      => G_APP_NAME,
                              p_msg_name      => G_INVALID_VALUE1,
                              p_token1        => 'COL_NAME',
                              p_token1_value  => 'Serial Number');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        x_achr_tbl(i).contract_number  := r_get_for_sno_csr.contract_number;
        x_achr_tbl(i).chr_id           := r_get_for_sno_csr.chr_id;
        x_achr_tbl(i).from_start_date  := r_get_for_sno_csr.from_start_date;
        x_achr_tbl(i).from_end_date    := r_get_for_sno_csr.from_end_Date;
        x_achr_tbl(i).sts_code         := r_get_for_sno_csr.sts_code;
        x_achr_tbl(i).sts_meaning      := r_get_for_sno_csr.sts_meaning;
        x_achr_tbl(i).org_id           := r_get_for_sno_csr.org_id;
        x_achr_tbl(i).party_name       := r_get_for_sno_csr.party_name;
        i := i + 1;
      END LOOP;
      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    -- If the asset number and serial number when given.
    ELSIF (l_achr_rec.asset_number <> OKL_API.G_MISS_CHAR OR
          l_achr_rec.asset_number IS NOT NULL) AND
          (l_achr_rec.serial_number <> OKL_API.G_MISS_CHAR OR
          l_achr_rec.serial_number IS NOT NULL) THEN
      -- Get the contract details for asset number and serial number
      FOR r_get_for_asset_sno_csr IN get_for_asset_sno_csr(p_achr_rec => l_achr_rec) LOOP
        IF get_for_asset_sno_csr%NOTFOUND THEN
          OKL_API.set_message(p_app_name      => G_APP_NAME,
                              p_msg_name      => G_INVALID_VALUE1,
                              p_token1        => 'COL_NAME',
                              p_token1_value  => 'Asset Number or Serial Number');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        x_achr_tbl(i).contract_number  := r_get_for_asset_sno_csr.contract_number;
        x_achr_tbl(i).chr_id           := r_get_for_asset_sno_csr.chr_id;
        x_achr_tbl(i).from_start_date  := r_get_for_asset_sno_csr.from_start_date;
        x_achr_tbl(i).from_end_date    := r_get_for_asset_sno_csr.from_end_Date;
        x_achr_tbl(i).sts_code         := r_get_for_asset_sno_csr.sts_code;
        x_achr_tbl(i).sts_meaning      := r_get_for_asset_sno_csr.sts_meaning;
        x_achr_tbl(i).org_id           := r_get_for_asset_sno_csr.org_id;
        x_achr_tbl(i).party_name       := r_get_for_asset_sno_csr.party_name;
        i := i + 1;
      END LOOP;
      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,G_MODULE_NAME||'advance_contract_search','End(-)');
   END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF get_chr_dtls_csr%ISOPEN THEN
        CLOSE get_chr_dtls_csr;
      END IF;
      IF get_for_sno_csr%ISOPEN THEN
        CLOSE get_for_sno_csr;
      END IF;
      IF get_for_asset_csr%ISOPEN THEN
        CLOSE get_for_asset_csr;
      END IF;
      IF get_for_asset_sno_csr%ISOPEN THEN
        CLOSE get_for_asset_sno_csr;
      END IF;

     x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKL_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');


    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF get_chr_dtls_csr%ISOPEN THEN
        CLOSE get_chr_dtls_csr;
      END IF;
      IF get_for_sno_csr%ISOPEN THEN
        CLOSE get_for_sno_csr;
      END IF;
      IF get_for_asset_csr%ISOPEN THEN
        CLOSE get_for_asset_csr;
      END IF;
      IF get_for_asset_sno_csr%ISOPEN THEN
        CLOSE get_for_asset_sno_csr;
      END IF;
      IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
    WHEN OTHERS THEN
      IF get_chr_dtls_csr%ISOPEN THEN
        CLOSE get_chr_dtls_csr;
      END IF;
      IF get_for_sno_csr%ISOPEN THEN
        CLOSE get_for_sno_csr;
      END IF;
      IF get_for_asset_csr%ISOPEN THEN
        CLOSE get_for_asset_csr;
      END IF;
      IF get_for_asset_sno_csr%ISOPEN THEN
        CLOSE get_for_asset_sno_csr;
      END IF;
      IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
  END advance_contract_search;

  ------------------------------------------------------------------------
  -- PROCEDURE set_quote_defaults
  -- Default the values of parameters if the values are not passed to this API
  -- This assumption is necessary because this API can either be called from
  -- a screen or from some other process api
  -- rmunjulu EDT 3797384 made changes so that Quote Effective To Date is
  -- properly defaulted
  ------------------------------------------------------------------------
  PROCEDURE set_quote_defaults(
               px_quot_rec              IN OUT NOCOPY quot_rec_type,
               p_rule_chr_id            IN NUMBER,
               p_sys_date               IN DATE,
               x_return_status          OUT NOCOPY VARCHAR2)  IS

    l_quote_eff_days         NUMBER;
    l_quote_eff_max_days     NUMBER;
    l_quote_status           VARCHAR2(200) := 'DRAFTED';
    l_quote_reason           VARCHAR2(200) := 'EOT';
    l_sys_date               DATE;
    l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
        L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'set_quote_defaults';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN
   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    -- Get the sysdate
    l_sys_date := p_sys_date;

    -- Set the date_effective_from if null
    IF ((px_quot_rec.date_effective_from IS NULL) OR
        (px_quot_rec.date_effective_from = OKL_API.G_MISS_DATE)) THEN
      px_quot_rec.date_effective_from :=  l_sys_date ;
    END IF;

    -- Set the date_effective_to if null
    IF ((px_quot_rec.date_effective_to IS NULL) OR
        (px_quot_rec.date_effective_to = OKL_API.G_MISS_DATE)) THEN

      IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'before call to quote_effectivity :'||l_return_status);
      END IF;
      -- set the date eff to using rules
      quote_effectivity(
           p_quot_rec             => px_quot_rec,
           p_rule_chr_id          => p_rule_chr_id,
           x_quote_eff_days       => l_quote_eff_days,
           x_quote_eff_max_days   => l_quote_eff_max_days,
           x_return_status        => l_return_status);

      IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to quote_effectivity :'||l_return_status);
      END IF;

    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- Start ++++++++++++++++
        --rmunjulu EDT 3797384 removed and replaced with below logic
--      px_quot_rec.date_effective_to   :=  px_quot_rec.date_effective_from + l_quote_eff_days;

      -- rmunjulu EDT 3797384 logic for date_effective_to varies for pre and post
      IF trunc(l_sys_date) > trunc(px_quot_rec.date_effective_from) THEN -- pre dated
         -- PRE DATED QUOTE: effective_to = date_created + quote_eff_days
         px_quot_rec.date_effective_to   :=  l_sys_date + l_quote_eff_days;
      ELSIF trunc(l_sys_date) < trunc(px_quot_rec.date_effective_from) THEN -- post dated
         -- POST DATED QUOTE: effective_to = eff_from + quote_eff_days
         px_quot_rec.date_effective_to   :=  px_quot_rec.date_effective_from + l_quote_eff_days;
      ELSE -- current
         -- CURRENT DATED QUOTE: effective_to = eff_from + quote_eff_days
         px_quot_rec.date_effective_to   :=  px_quot_rec.date_effective_from + l_quote_eff_days;
      END IF;

    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- End ++++++++++++++++

    END IF;

    -- Set the qst_code if null
    IF ((px_quot_rec.qst_code IS NULL) OR
        (px_quot_rec.qst_code = OKL_API.G_MISS_CHAR)) THEN
      px_quot_rec.qst_code            :=  l_quote_status;
    END IF;

    -- Set the qrs_code if null
    IF ((px_quot_rec.qrs_code IS NULL) OR
        (px_quot_rec.qrs_code = OKL_API.G_MISS_CHAR)) THEN
      px_quot_rec.qrs_code            :=  l_quote_reason;
    END IF;

    -- Set the preproceeds_yn if null
    IF ((px_quot_rec.preproceeds_yn IS NULL) OR
        (px_quot_rec.preproceeds_yn = OKL_API.G_MISS_CHAR)) THEN
      px_quot_rec.preproceeds_yn      :=  G_NO;
    END IF;

    -- Set the summary_format_yn if null
    IF ((px_quot_rec.summary_format_yn IS NULL) OR
        (px_quot_rec.summary_format_yn = OKL_API.G_MISS_CHAR)) THEN
      px_quot_rec.summary_format_yn   :=  G_NO;
    END IF;

    -- Set the consolidated_yn if null
    IF ((px_quot_rec.consolidated_yn IS NULL) OR
        (px_quot_rec.consolidated_yn = OKL_API.G_MISS_CHAR)) THEN
      px_quot_rec.consolidated_yn     :=  G_NO;
    END IF;

    -- Set the approved_yn if null
    IF ((px_quot_rec.approved_yn IS NULL) OR
        (px_quot_rec.approved_yn = OKL_API.G_MISS_CHAR)) THEN
      px_quot_rec.approved_yn         :=  G_NO;
    END IF;

    -- Set the payment_received_yn if null
    IF ((px_quot_rec.payment_received_yn IS NULL) OR
        (px_quot_rec.payment_received_yn = OKL_API.G_MISS_CHAR)) THEN
      px_quot_rec.payment_received_yn :=  G_NO;
    END IF;

    -- Set the date_requested if null
    IF ((px_quot_rec.date_requested IS NULL) OR
        (px_quot_rec.date_requested = OKL_API.G_MISS_DATE)) THEN
      px_quot_rec.date_requested      :=  l_sys_date;
    END IF;

    -- Set the date_proposal if null
    IF ((px_quot_rec.date_proposal IS NULL) OR
        (px_quot_rec.date_proposal = OKL_API.G_MISS_DATE)) THEN
      px_quot_rec.date_proposal       :=  l_sys_date;
    END IF;

    -- Set the requested_by if null
    IF ((px_quot_rec.requested_by IS NULL) OR
        (px_quot_rec.requested_by = OKL_API.G_MISS_NUM)) THEN
      px_quot_rec.requested_by        :=  1;
    END IF;

-- Set the legal_entity_id if null ssiruvol(Nov 17th, 2006)
    IF ((px_quot_rec.legal_entity_id IS NULL) OR
        (px_quot_rec.legal_entity_id = OKL_API.G_MISS_NUM)) THEN
      px_quot_rec.legal_entity_id     :=  OKL_LEGAL_ENTITY_UTIL.get_khr_le_id (px_quot_rec.khr_id);
    END IF;

    -- Always NO during quote creation
    px_quot_rec.accepted_yn           :=  G_NO;

    -- For now *** -- OKL_QTE_PVT.Validate_Trn_Code() expects a value for trn_code
    px_quot_rec.trn_code              :=  'EXP';
    x_return_status                   :=   l_return_status;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
    WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END set_quote_defaults;




  -- Start of comments
  --
  -- Procedure Name : early_termination_allowed
  -- Description    : Gets early termination of contract rule
  -- Business Rules :
  -- Parameters     : quote rec, contract id, return status, rule found
  -- Version        : 1.0
  -- History        : RDRAGUIL 11-MAR-01 - changed from AMTQPR to AMTPAR rule group
  --                  RMUNJULU 11-DEC-02 - Bug # 2484327 Send FALSE to rule api
  --                  for p_message_yn
  -- End of comments
  PROCEDURE early_termination_allowed(
	p_quot_rec		IN quot_rec_type,
	p_rule_chr_id		IN NUMBER,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_rule_found		OUT NOCOPY BOOLEAN)  IS

	l_return_status		VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
	l_rule_found		BOOLEAN := FALSE;
	l_rulv_rec		rulv_rec_type;
	l_rule_code		CONSTANT VARCHAR2(30) := 'AMCTTA';
	l_rgd_code		VARCHAR2(30);

  L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'early_termination_allowed';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

     IF (is_debug_procedure_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

   IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_rule_chr_id : '||p_rule_chr_id     );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.id : '||p_quot_rec.id     );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.qrs_code : '||p_quot_rec.qrs_code    );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.qst_code : '||p_quot_rec.qst_code               );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.consolidated_qte_id : '||p_quot_rec.consolidated_qte_id     );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.khr_id : '||p_quot_rec.khr_id                 );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.art_id : '||p_quot_rec.art_id                 );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.qtp_code : '||p_quot_rec.qtp_code               );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.trn_code : '||p_quot_rec.trn_code                 );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.pdt_id : '||p_quot_rec.pdt_id                  );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.date_effective_from : '||p_quot_rec.date_effective_from     );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.quote_number : '||p_quot_rec.quote_number            );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.early_termination_yn : '||p_quot_rec.early_termination_yn       );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.approved_yn : '||p_quot_rec.approved_yn                  );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.accepted_yn : '||p_quot_rec.accepted_yn                   );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.org_id : '||p_quot_rec.org_id                        );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.legal_entity_id : '||p_quot_rec.legal_entity_id               );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.repo_quote_indicator_yn : '||p_quot_rec.repo_quote_indicator_yn       );

   END IF;

	IF p_quot_rec.qtp_code LIKE 'TER_RECOURSE%' THEN
		l_rgd_code := 'AVTQPR';
	ELSE
		l_rgd_code := 'AMTQPR';
	END IF;

      IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'before call to OKL_AM_UTIL_PVT.get_rule_record :'||l_return_status);
      END IF;


	OKL_AM_UTIL_PVT.get_rule_record(
		p_rgd_code	=> l_rgd_code,
		p_rdf_code	=> l_rule_code,
		p_chr_id	=> p_rule_chr_id,
		p_cle_id	=> NULL,
		x_rulv_rec	=> l_rulv_rec,
 		x_return_status	=> l_return_status,
		p_message_yn	=> FALSE); -- RMUNJULU 11-DEC-02 2484327 Send FALSE to rule api

      IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to OKL_AM_UTIL_PVT.get_rule_record :'||l_return_status);
      END IF;


	IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
		IF NVL (l_rulv_rec.rule_information1, '*') = 'Y' THEN
			l_rule_found := TRUE;
		END IF;
	END IF;

	x_return_status  := OKL_API.G_RET_STS_SUCCESS; -- Rule is optional
	x_rule_found     := l_rule_found;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
     IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
     END IF;

     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     OKL_API.set_message(p_app_name      => g_app_name,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
  END early_termination_allowed;





  -- Start of comments
  --
  -- Procedure Name : partial_termination_allowed
  -- Description    : Gets partial termination of contract rule
  -- Business Rules :
  -- Parameters     : quote rec, contract id, return status, rule found
  -- Version        : 1.0
  -- History        : RDRAGUIL 11-MAR-01 - changed from AMTQPR to AMTPAR rule group
  --                  RMUNJULU 11-DEC-02 - Bug # 2484327 Send FALSE to rule api
  --                  for p_message_yn
  -- End of comments
  PROCEDURE partial_termination_allowed(
	p_quot_rec		IN quot_rec_type,
	p_rule_chr_id		IN NUMBER,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_rule_found		OUT NOCOPY BOOLEAN)  IS

	l_return_status		VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
	l_rule_found		BOOLEAN := FALSE;
	l_rulv_rec		rulv_rec_type;
	l_rule_code		CONSTANT VARCHAR2(30) := 'AMPTQA';
	l_rgd_code		VARCHAR2(30);
	  L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'partial_termination_allowed';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

     IF (is_debug_procedure_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');

   END IF;

   IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_rule_chr_id : '||p_rule_chr_id     );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.id : '||p_quot_rec.id     );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.qrs_code : '||p_quot_rec.qrs_code    );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.qst_code : '||p_quot_rec.qst_code               );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.consolidated_qte_id : '||p_quot_rec.consolidated_qte_id     );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.khr_id : '||p_quot_rec.khr_id                 );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.art_id : '||p_quot_rec.art_id                 );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.qtp_code : '||p_quot_rec.qtp_code               );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.trn_code : '||p_quot_rec.trn_code                 );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.pdt_id : '||p_quot_rec.pdt_id                  );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.date_effective_from : '||p_quot_rec.date_effective_from     );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.quote_number : '||p_quot_rec.quote_number            );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.partial_yn : '||p_quot_rec.partial_yn            );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.approved_yn : '||p_quot_rec.approved_yn                  );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.accepted_yn : '||p_quot_rec.accepted_yn                   );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.org_id : '||p_quot_rec.org_id                        );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.legal_entity_id : '||p_quot_rec.legal_entity_id               );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.repo_quote_indicator_yn : '||p_quot_rec.repo_quote_indicator_yn       );

   END IF;

	IF p_quot_rec.qtp_code LIKE 'TER_RECOURSE%' THEN
		l_rgd_code := 'AVTPAR';
	ELSE
		l_rgd_code := 'AMTPAR';
	END IF;

      IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'before call to OKL_AM_UTIL_PVT.get_rule_record :'||l_return_status);
      END IF;

	OKL_AM_UTIL_PVT.get_rule_record(
		p_rgd_code	=> l_rgd_code,
		p_rdf_code	=> l_rule_code,
		p_chr_id	=> p_rule_chr_id,
		p_cle_id	=> NULL,
		x_rulv_rec	=> l_rulv_rec,
 		x_return_status	=> l_return_status,
		p_message_yn	=> FALSE); -- RMUNJULU 11-DEC-02 2484327 Send FALSE to rule api

      IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to OKL_AM_UTIL_PVT.get_rule_record :'||l_return_status);
      END IF;

	IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
		IF NVL (l_rulv_rec.rule_information1, '*') = 'Y' THEN
			l_rule_found := TRUE;
		END IF;
	END IF;

	x_return_status  := OKL_API.G_RET_STS_SUCCESS; -- Rule is optional
	x_rule_found     := l_rule_found;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End (-)');
   END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     OKL_API.set_message(p_app_name      => g_app_name,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
  END partial_termination_allowed;

  ------------------------------------------------------------------------
  -- PROCEDURE term_status
  -- gets the days before contract expiration
  ------------------------------------------------------------------------
  PROCEDURE term_status(
	p_quot_rec		IN quot_rec_type,
	p_rule_chr_id		IN NUMBER,
	x_days_before_k_exp	OUT NOCOPY NUMBER,
	x_return_status		OUT NOCOPY VARCHAR2)  IS

	l_return_status		VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
	l_rule_found		BOOLEAN := FALSE;
	l_rulv_rec		rulv_rec_type;
	l_rule_code		CONSTANT VARCHAR2(30) := 'AMTSET';
	l_rgd_code		VARCHAR2(30);
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'term_status.';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN
   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

	IF p_quot_rec.qtp_code LIKE 'TER_RECOURSE%' THEN
		l_rgd_code := 'AVTQPR';
	ELSE
		l_rgd_code := 'AMTQPR';
	END IF;

      IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'before call to OKL_AM_UTIL_PVT.get_rule_record :'||l_return_status);
      END IF;

	OKL_AM_UTIL_PVT.get_rule_record(
		p_rgd_code	=> l_rgd_code,
		p_rdf_code	=> l_rule_code,
		p_chr_id	=> p_rule_chr_id,
		p_cle_id	=> NULL,
		x_rulv_rec	=> l_rulv_rec,
 		x_return_status	=> l_return_status,
		p_message_yn	=> TRUE);

      IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to OKL_AM_UTIL_PVT.get_rule_record :'||l_return_status);
      END IF;

	IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
		IF NVL (l_rulv_rec.rule_information1, '-1') >= 0 THEN
			l_rule_found := TRUE;
		END IF;
	END IF;

	IF l_rule_found THEN
		x_days_before_k_exp   := l_rulv_rec.RULE_INFORMATION1;
	END IF;

	x_return_status := l_return_status;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN

    IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
    END IF;
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     OKL_API.set_message(p_app_name      => g_app_name,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
  END term_status;



    -- Start of comments
    --
    -- Procedure Name : quote_effectivity
    -- Description    : gets the quote effective dates
    -- Business Rules :
    -- Parameters     : quote header, contract id
    -- Version        : 1.0
    -- History        : SECHAWLA 25-NOV-02 - Bug 2680542 : Removed DEFAULT
    --                  from procedure parameters.
    -- End of comments
  PROCEDURE quote_effectivity(
	p_quot_rec		  IN quot_rec_type,
	p_rule_chr_id		  IN NUMBER,
	x_quote_eff_days	  OUT NOCOPY NUMBER,
	x_quote_eff_max_days      OUT NOCOPY NUMBER,
	x_return_status		  OUT NOCOPY VARCHAR2)  IS

	l_return_status		VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
	l_rule_found		BOOLEAN := FALSE;
	l_rulv_rec		rulv_rec_type;
	l_rule_code		CONSTANT VARCHAR2(30) := 'AMQTEF';
	l_rgd_code		VARCHAR2(30);
	l_rule_chr_id		NUMBER;
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'quote_effectivity';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN
   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

	IF p_quot_rec.qtp_code LIKE 'TER_RECOURSE%' THEN
		l_rgd_code := 'AVTQPR';
	ELSE
		l_rgd_code := 'AMTQPR';
	END IF;

	IF p_rule_chr_id IS NOT NULL
	OR p_rule_chr_id <> OKL_API.G_MISS_NUM THEN
		l_rule_chr_id := p_rule_chr_id;
	ELSE
		l_rule_chr_id := okl_am_util_pvt.get_rule_chr_id (p_quot_rec);
	END IF;

     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'Before call to OKL_AM_UTIL_PVT.get_rule_record :'||l_return_status);
      END IF;
	OKL_AM_UTIL_PVT.get_rule_record(
		p_rgd_code	=> l_rgd_code,
		p_rdf_code	=> l_rule_code,
		p_chr_id	=> l_rule_chr_id,
		p_cle_id	=> NULL,
		x_rulv_rec	=> l_rulv_rec,
 		x_return_status	=> l_return_status,
		p_message_yn	=> TRUE);

      IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to OKL_AM_UTIL_PVT.get_rule_record :'||l_return_status);
      END IF;

	IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
		IF NVL (l_rulv_rec.rule_information1, '-1') >= 0 THEN
 			l_rule_found := TRUE;
		END IF;
	END IF;

	IF l_rule_found THEN
		x_quote_eff_days      := l_rulv_rec.RULE_INFORMATION1;
		x_quote_eff_max_days  := l_rulv_rec.RULE_INFORMATION2;
	END IF;

	x_return_status := l_return_status;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     OKL_API.set_message(p_app_name      => g_app_name,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
  END quote_effectivity;



  -- Start of comments
  --
  -- Procedure Name : quote_type_check
  -- Description    : checks the quote type
  -- Business Rules :
  -- Parameters     : quote type code (input), flag indicating whether the
  --                  quote type changed from auto to manual
  -- Version        : 1.0
  -- History        : SECHAWLA 06-DEC-02 - Bug 2699412
  --                    Added logic to change the quote type from Auto to Manual,
  --                    if the request was to create an Auto Quote,
  --                    but Auto quotes are not allowed
  --                  SECHAWLA 02-JAN-03 - Bug 2699412
  --                    Added code to evaluate new rule to check if auto quotes are allowed
  -- End of comments
  PROCEDURE quote_type_check(
           p_qtp_code                    IN OUT NOCOPY VARCHAR2,  --SECHAWLA 2699412 changed from IN to IN OUT
           p_khr_id                      IN NUMBER,
           x_auto_to_manual              OUT NOCOPY BOOLEAN, -- SECHAWLA 2699412 added
           x_return_status               OUT NOCOPY VARCHAR2)  IS

     l_return_status               VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;

     l_new_quote_type              VARCHAR2(30); --SECHAWLA 2699412 added
     l_auto_to_manual              BOOLEAN := FALSE; --SECHAWLA 2699412 added

     -- SECHAWLA 02-JAN-03 2699412 new declarations
     l_auto_quotes_allowed         VARCHAR2(1);
     l_rulv_rec                    okl_rule_pub.rulv_rec_type;
     l_msg_count		           NUMBER		:= OKL_API.G_MISS_NUM;
	 l_msg_data	                   VARCHAR2(2000);
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'quote_type_check';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN
   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

    IF (p_qtp_code IS NOT NULL) AND (p_qtp_code LIKE 'TER%') THEN

     IF p_qtp_code NOT LIKE 'TER_MAN%' THEN  -- auto quotes

       --SECHAWLA Bug # 2699412 : Added the following code to change the quote
       -- type from Auto to Manual, if Auto quotes are not allowed

       --SECHAWLA Bug # 2699412 02-JAN-03 Added the following code to check if auto quoets are allowed

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'before call to okl_am_util_pvt.get_rule_record :'||l_return_status);
   END IF;
       --Check if auto quotes are allowed
       okl_am_util_pvt.get_rule_record( p_rgd_code         => 'AMTQPR'
                                     ,p_rdf_code         => 'AMCMTQ'
                                     ,p_chr_id           => p_khr_id
                                     ,p_cle_id           => NULL
                                     ,p_message_yn       => FALSE
                                     ,x_rulv_rec         => l_rulv_rec  -- hold a rule instance from okc_rules_b
                                     ,x_return_status    => l_return_status
                                     ,x_msg_count        => l_msg_count
                                     ,x_msg_data         => l_msg_data);

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to okl_am_util_pvt.get_rule_record :'||l_return_status);
   END IF;

      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
          -- Rule instance is found
          IF l_rulv_rec.rule_information1 IS NOT NULL AND l_rulv_rec.rule_information1 <> OKL_API.G_MISS_CHAR THEN
              IF l_rulv_rec.rule_information1 = 'Y' THEN
                 l_auto_quotes_allowed := 'N';
              ELSE
                 l_auto_quotes_allowed := 'Y';
              END IF;
          ELSE
              l_auto_quotes_allowed := 'Y';
          END IF;
      ELSE
          l_auto_quotes_allowed := 'Y';
      END IF;


      IF l_auto_quotes_allowed = 'N' THEN
         IF p_qtp_code IN ('TER_PURCHASE', 'TER_RECOURSE','TER_ROLL_PURCHASE') THEN
            l_new_quote_type := 'TER_MAN_PURCHASE';
         ELSE
            l_new_quote_type := 'TER_MAN_WO_PURCHASE';
         END IF;
         l_auto_to_manual := TRUE;
         p_qtp_code := l_new_quote_type;
      END IF;

     END IF;
     l_return_status       := OKL_API.G_RET_STS_SUCCESS;
   END IF;
    -- SECHAWLA 2699412 : Added a flag to indicate whether quote type changed
    -- from Auto to Manual
    x_auto_to_manual := l_auto_to_manual;
    x_return_status := l_return_status;

     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(+)');
   END IF;

  END quote_type_check;




  -- PROCEDURE validate_quote
  -- checks the validity of the quote
  -- History: RDRAGUIL 11-MAR-01 - added No Assets validation
  --          RMUNJULU 11-APR-02 - Added call to Validate_Contract, removed
  --                               check_contract_active_yn call
  --          SECHAWLA 25-NOV-02 - Bug # 2680542
  --                    1) Changed p_assn_tbl parameter type from IN to IN OUT
  --                    2) Added an out parameter x_partial_asset_line
  --                    to the procedure to indicate to the calling
  --                    procedure if the quote includes a partial asset line.
  --                    3) Moved all the line level validations towards the
  --                    end of the procedure, after contarct level validations.
  --                    4) Added cursor l_clines_csr to validate the asset id
  --                    and check if asset asset belongs to the passed contract.
  --                    5) Added cursor l_linesfull_csr to populate asset number
  --                    if it is null
  --                    6) Added validations for asset quantity and quote quantity

  --          SECHAWLA 06-DEC-02 - Bug # 2699412
  --                    1) Removed validation to check that already accepetd
  --                    quote exists for contract
  --                    2) Added a new validation to check if an already
  --                    accepted quote exists for contract line
  --                    3) Modified logic to check the quote type
  --                    4) Check for early and partial terminations only for
  --                    Auto quotes
  --                    5) Added a new parameter p_days_before_k_exp,
  --                    used to check if it is early termination
  --          RMUNJULU 11-DEC-02 - Bug # 2484327 --
  --                    Added code to check for accepted quote based
  --                    on asset level termination changes
  --          RMUNJULU 06-JAN-03 2736865 Date Eff From is now enterable changes
  --          SECHAWLA 17-FEB-03 Bug 2804703 : Added a validation to restrict the
  --                    creation of quote with partial asset line(s)
  --                    for an evergreen contract
  --          SECHAWLA 18-FEB-03 Bug # 2807201 : Moved the quote_type_check procedure call from this
  --                    procedure to create_termination_quote procedure. Removed x_new_quote_type and
  --                    x_auto_to_manual parameters
  --          SECHAWLA 28-FEB-03 Bug # 2757175 : Moved the validate contract validation from this procedure
  --                    to create_termination_quote procedure
  --          RMUNJULU 14-MAR-03 2854796 Error if quote qty less than equal to 0
  --          RMUNJULU 09-APR-03 2897523 Added code to check if OKS line exists for the asset
  --          RMUNJULU 10-APR-03 2900178 Changed cursor l_oks_lines_csr
  --          RMUNJULU 02-OCT-03 2757312 Added code to check for New Asset Number uniqueness
  --          RMUNJULU 3241502 Changed token value
  --          rmunjulu EDT 3797384 changed the check for early termination, check using eff_from_date
  --          rmunjulu EDAT Added code to check for prior dated qte not before k start date and for
  --                   evergreen contract not before k end date
  --                   Removed check for only sysdated and future dated quotes, as prior are now allowed
  --          rmunjulu EDAT Added code to check for FA transactions and fiscal year for prior dated terms
  --          rmunjulu PPD Added code to check for PPD transaction after quote eff date for prior dated quotes
  --          rmunjulu EDAT 17-Jan-2005 Raise proper exception
  --          rmunjulu Bug 4143251 Modified Check for PPD -- check for all quotes
  --                   Added check for BOOKED contract and Partial Quote with Quote Eff From Date after contract end date
  --                   Modified check for FA checks to check for PIOR and CURRENT quotes
  --          PAGARG   Bug 4299668 Move the cursor execution (to check whether
  --                   there is any OKS line attached to asset) inside
  --                   l_partial_asset_line check as OKS line needs to be checked
  --                   only in case of partial line termination
  --          rmunjulu LOANS_ENHANCEMENTS Termination with purchase not allowed for loans
  --                   Partial Line Termination not allowed for loans with actual/estimated actual
  --          rmunjulu LOANS_ENHANCEMENTS -- Check interest calculation done
  --          SECHAWLA 04-JAN-06 4915133 - partial quote (full and partial line) should not be allowed
  --                   for a loan contract with rev rec method 'ESTIMATED_AND_BILLED' or 'ACTUAL'
  PROCEDURE validate_quote(
  	p_api_version       	IN NUMBER,
  	p_init_msg_list     	IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
  	x_return_status     	OUT NOCOPY VARCHAR2,
  	x_msg_count         	OUT NOCOPY NUMBER,
  	x_msg_data	          OUT NOCOPY VARCHAR2,
  	p_quot_rec	          IN quot_rec_type,
  	p_assn_tbl	          IN OUT NOCOPY assn_tbl_type,  -- SECHAWLA 2680542 Changed from IN to IN OUT
  	p_k_end_date	        IN DATE,
  	p_no_of_assets      	IN NUMBER,
  	p_sys_date	          IN DATE,
  	p_rule_chr_id       	IN NUMBER,
    p_days_before_k_exp   IN NUMBER,  --SECHAWLA Bug # 2699412  -added
    x_partial_asset_line  OUT NOCOPY BOOLEAN

)  IS

    -- SECHAWLA 17-FEB-03 Bug 2804703 : replaced the usage of okl_k_headers_full_v
    -- with okc_k_keaders_b, added sts_code.
    -- Cursor to get the khr details for the k passed
    CURSOR k_details_for_qte_csr (p_khr_id IN NUMBER) IS
       SELECT K.contract_number, K.sts_code, K.start_date, K.end_date -- rmunjulu EDAT
       FROM   OKC_K_HEADERS_B  K
       WHERE  K.id     = p_khr_id;


    -- Cursor to get the quote details of a quote that is already accepted for
    -- the same contract for which this quote is being generated.
    CURSOR get_accepted_qte_details_csr( p_khr_id IN NUMBER) IS
       SELECT Q.quote_number, Q.qtp_code
       FROM   OKL_TRX_QUOTES_B Q
       WHERE  Q.khr_id  = p_khr_id
       AND    Q.accepted_yn = 'Y';

    -- This cursor is used to check if a particular asset belongs to a particular contract.
    -- RMUNJULU -- 11-DEC-02 Bug # 2484327 -- Changed cursor to also check for
    -- sts_code of line match with sts_code of contract
    CURSOR l_clines_csr (p_kle_id NUMBER ) IS
      SELECT  KLE.chr_id, KLE.start_date -- rmunjulu EDAT
      FROM    OKC_K_LINES_B   KLE,
              OKC_K_HEADERS_B KHR
      WHERE   KLE.id = p_kle_id
      AND     KLE.chr_id = KHR.id
      AND     KLE.sts_code = KHR.sts_code;


    -- This cursor is used to get the asset number
    CURSOR l_linesfull_csr(p_id NUMBER) IS
    SELECT name
    FROM   okl_k_lines_full_v
    WHERE  id = p_id;


    -- RMUNJULU 09-APR-03 2897523 Get the OKS lines if any linked to this covered asset
    -- RMUNJULU 10-APR-03 2900178 Changed the query from SELECT 1 to SELECT '1',
    -- and removed TO_CHAR conversion to krel.object1_id1
    CURSOR l_oks_lines_csr ( p_kle_id IN NUMBER) IS
    SELECT '1'
    FROM dual WHERE EXISTS (
               SELECT '1'
               FROM   okc_k_headers_b   oks_chrb,
                      okc_line_styles_b oks_cov_pd_lse,
                      okc_k_lines_b     oks_cov_pd_cleb,
                      okc_k_rel_objs    krel,
                      okc_line_styles_b lnk_srv_lse,
                      okc_statuses_b    lnk_srv_sts,
                      okc_k_lines_b     lnk_srv_cleb,
                      okc_k_items       lnk_srv_cim
               WHERE  oks_chrb.scs_code            = 'SERVICE'
               AND    oks_chrb.id                  = oks_cov_pd_cleb.dnz_chr_id
               AND    oks_cov_pd_cleb.lse_id       = oks_cov_pd_lse.id
               AND    oks_cov_pd_lse.lty_code      = 'COVER_PROD'
               AND    '#'                          = krel.object1_id2
               AND    oks_cov_pd_cleb.id           = krel.object1_id1
               AND    krel.rty_code                = 'OKLSRV'
               AND    krel.chr_id                  = lnk_srv_cleb.dnz_chr_id
               AND    krel.cle_id                  = lnk_srv_cleb.id
               AND    lnk_srv_cleb.lse_id          = lnk_srv_lse.id
               AND    lnk_srv_lse.lty_code         = 'LINK_SERV_ASSET'
               AND    lnk_srv_cleb.sts_code        = lnk_srv_sts.code
               AND    lnk_srv_sts.ste_code NOT IN ('HOLD','EXPIRED','TERMINATED','CANCELLED')
               AND    lnk_srv_cleb.dnz_chr_id       = lnk_srv_cim.dnz_chr_id
               AND    lnk_srv_cleb.id               = lnk_srv_cim.cle_id
               AND    lnk_srv_cim.jtot_object1_code = 'OKX_COVASST'
               AND    lnk_srv_cim.object1_id2       = '#'
               AND    lnk_srv_cim.object1_id1       = TO_CHAR(p_kle_id));

    -- Bug# 5998969 -- Start
    -- This cursor is used to get the asset auto range
    CURSOR l_asset_autorange_csr IS
    SELECT INITIAL_ASSET_ID
    FROM   FA_SYSTEM_CONTROLS;

    l_asset_init_number NUMBER :=0;
    l_temp_asset_number NUMBER :=0;
    is_number           NUMBER :=1;
    -- Bug# 5998969 -- End

    -- RMUNJULU 09-APR-03 2897523 Added variables
    l_oks_line_exists BOOLEAN := FALSE;

    -- RMUNJULU 10-APR-03 2900178 changed to VARCHAR2
    l_number VARCHAR2(3);


    l_no_of_assets             NUMBER := 0;
    l_k_end_date               DATE;
    l_rule_found               BOOLEAN := FALSE;
    l_return_status            VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
    l_contract_status          OKC_STATUSES_V.MEANING%TYPE;
    l_contract_number          OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE;
    l_missing_lines            BOOLEAN := FALSE;
    l_missing_asset_qty        BOOLEAN := FALSE;
    l_partial_asset_line       BOOLEAN := FALSE;
    l_invalid_lines            BOOLEAN := FALSE;
    l_contract_mismatch        BOOLEAN := FALSE;
    i                          NUMBER := 0;

    l_accepted_quote_number    NUMBER := -999;
    l_qtp_code                 VARCHAR2(30);
    l_quote_type               VARCHAR2(200);
    l_asset_qty                NUMBER;
    l_chr_id                   NUMBER;
    l_name                     VARCHAR2(150);

    -- RMUNJULU -- 11-DEC-02 Bug # 2484327 -- Added parameters for checking
    -- related to asset level termination
    lx_quote_tbl  OKL_AM_UTIL_PVT.quote_tbl_type;

    -- SECHAWLA 17-FEB-03 Bug 2804703 : new declarations
    l_sts_code                 okc_k_headers_b.sts_code%TYPE;

    -- RMUNJULU 2757312
    l_asset_exists VARCHAR2(1);

    -- rmunjulu EDAT
    l_k_start_date DATE;
    l_l_start_date DATE;

    -- rmunjulu PPD
    l_pdd_exists VARCHAR2(3);

    -- LOAN_ENHANCEMENTS
    l_deal_type VARCHAR2(300);
    l_rev_rec_method VARCHAR2(300);
	l_int_cal_basis VARCHAR2(300);
	l_tax_owner VARCHAR2(300);
	l_int_calc_done VARCHAR2(3);

  L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'validate_quote';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

   --Print Input Variables
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_api_version :'||p_api_version);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_init_msg_list :'||p_init_msg_list);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_k_end_date :'||p_k_end_date);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_no_of_assets :'||p_no_of_assets);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_sys_date :'||p_sys_date);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_rule_chr_id :'||p_rule_chr_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_days_before_k_exp :'||p_days_before_k_exp);
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.id : '||p_quot_rec.id     );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.qrs_code : '||p_quot_rec.qrs_code    );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.qst_code : '||p_quot_rec.qst_code               );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.consolidated_qte_id : '||p_quot_rec.consolidated_qte_id     );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.khr_id : '||p_quot_rec.khr_id                 );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.art_id : '||p_quot_rec.art_id                 );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.qtp_code : '||p_quot_rec.qtp_code               );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.trn_code : '||p_quot_rec.trn_code                 );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.pdt_id : '||p_quot_rec.pdt_id                  );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.date_effective_from : '||p_quot_rec.date_effective_from     );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.quote_number : '||p_quot_rec.quote_number            );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.early_termination_yn : '||p_quot_rec.early_termination_yn       );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.partial_yn : '||p_quot_rec.partial_yn            );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.preproceeds_yn : '||p_quot_rec.preproceeds_yn   );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.summary_format_yn : '||p_quot_rec.summary_format_yn     );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.consolidated_yn : '||p_quot_rec.consolidated_yn     );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.date_requested : '||p_quot_rec.date_requested   );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.date_proposal : '||p_quot_rec.date_proposal   );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.date_effective_to : '||p_quot_rec.date_effective_to    );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.date_accepted : '||p_quot_rec.date_accepted          );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.payment_received_yn : '||p_quot_rec.payment_received_yn      );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.requested_by : '||p_quot_rec.requested_by               );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.approved_yn : '||p_quot_rec.approved_yn                  );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.accepted_yn : '||p_quot_rec.accepted_yn                   );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.org_id : '||p_quot_rec.org_id                        );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.purchase_amount : '||p_quot_rec.purchase_amount               );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.purchase_formula : '||p_quot_rec.purchase_formula              );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.asset_value : '||p_quot_rec.asset_value                   );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.residual_value : '||p_quot_rec.residual_value                );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.unbilled_receivables : '||p_quot_rec.unbilled_receivables          );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.gain_loss : '||p_quot_rec.gain_loss                     );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.PERDIEM_AMOUNT : '||p_quot_rec.PERDIEM_AMOUNT                );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.currency_code : '||p_quot_rec.currency_code                 );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.currency_conversion_code : '||p_quot_rec.currency_conversion_code      );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.legal_entity_id : '||p_quot_rec.legal_entity_id               );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.repo_quote_indicator_yn : '||p_quot_rec.repo_quote_indicator_yn       );
   END IF;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- SECHAWLA Bug #2680542 : moved all contract level validations
    -- to the beginning of the procedure,  before line level validations.

    OPEN  k_details_for_qte_csr(p_quot_rec.khr_id);
    -- rmunjulu EDAT Added l_k_start_date, l_k_end_date
    FETCH k_details_for_qte_csr INTO l_contract_number, l_sts_code, l_k_start_date, l_k_end_date; -- SECHAWLA 17-FEB-03 Bug 2804703 : added l_sts_code
    CLOSE k_details_for_qte_csr;

    --SECHAWLA 28-FEB-03 Bug # 2757175 : Moved the following validation to the beginning of create_termination_quote procedure
   /*
     -- Call the validate contract to check contract status
    OKL_AM_LEASE_LOAN_TRMNT_PUB.validate_contract(
           p_api_version                 =>   p_api_version,
           p_init_msg_list               =>   p_init_msg_list,
           x_return_status               =>   l_return_status,
           x_msg_count                   =>   x_msg_count,
           x_msg_data                    =>   x_msg_data,
           p_contract_id                 =>   p_quot_rec.khr_id,
           p_control_flag                =>   'TRMNT_QUOTE_CREATE',
           x_contract_status             =>   lx_contract_status);

    -- If error then above api will set the message, so exit now
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
*/  --SECHAWLA 28-FEB-03 Bug # 2757175 : end code move


    ---SECHAWLA Bug # 2699412--------Check the following for the contract line--

    -- rmunjulu +++++++++ Effective Dated Terminations -- start  +++++++++++++++

    -- RMUNJULU EDAT Date Eff From can be future or past date so remove this check
/*
    -- RMUNJULU 06-JAN-03 2736865 Date Eff From is now enterable
    -- Check date_eff_from should be >= sysdate
    IF  p_quot_rec.date_effective_from IS NOT NULL
    AND p_quot_rec.date_effective_from <> OKL_API.G_MISS_DATE
    AND TRUNC(p_quot_rec.date_effective_from) < TRUNC(p_sys_date) THEN

       x_return_status := OKL_API.G_RET_STS_ERROR;

       -- Please enter the current or future date for the Effective From date.
       OKL_API.SET_MESSAGE(
                    p_app_name     => 'OKL',
 	                  p_msg_name	   => 'OKL_AM_DATE_EFF_FROM_PAST');

       RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;
*/

    -- rmunjulu EDAT Add check so that quote effective date which is a prior date
    -- is not before the contract start date
    IF  p_quot_rec.date_effective_from IS NOT NULL
    AND p_quot_rec.date_effective_from <> OKL_API.G_MISS_DATE
    AND TRUNC(p_quot_rec.date_effective_from) < TRUNC(l_k_start_date) THEN

       x_return_status := OKL_API.G_RET_STS_ERROR;

       -- Quote Effectivity Date cannot be before contract start date.
       OKL_API.SET_MESSAGE(
                    p_app_name   => 'OKL',
 	                p_msg_name   => 'OKL_AM_EDT_QTE_DATE_K');

       RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    -- rmunjulu EDAT check if contract EVERGREEN then quote effective date cannot
    -- be before contract end date
    IF  p_quot_rec.date_effective_from IS NOT NULL
    AND p_quot_rec.date_effective_from <> OKL_API.G_MISS_DATE
    AND l_sts_code = 'EVERGREEN'
    AND TRUNC(p_quot_rec.date_effective_from) <= TRUNC(l_k_end_date) THEN -- rmunjulu bug 6978124 For Evergreen K quote should not be allowed as of K end Date.

       x_return_status := OKL_API.G_RET_STS_ERROR;

       -- Quote Effectivity Date for an Evergreen contract cannot be before contract end date.
       OKL_API.SET_MESSAGE(
                    p_app_name   => 'OKL',
 	                p_msg_name   => 'OKL_AM_EDT_EVERGREEN_QTE_DATE');

       RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    -- Code for PPD check will come here

    -- rmunjulu +++++++++ Effective Dated Termination -- end    ++++++++++++++++

    -- Check date_eff_to >= date_eff_from
    IF  (p_quot_rec.date_effective_from IS NOT NULL)
    AND (p_quot_rec.date_effective_from <> OKL_API.G_MISS_DATE)
    AND (p_quot_rec.date_effective_to IS NOT NULL)
    AND (p_quot_rec.date_effective_to <> OKL_API.G_MISS_DATE) THEN
       IF (TRUNC(p_quot_rec.date_effective_to) <= TRUNC(p_quot_rec.date_effective_from)) THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;
         -- Message : Date Effective To DATE_EFFECTIVE_TO cannot be before
         -- Date Effective From DATE_EFFECTIVE_FROM.
         OKL_API.SET_MESSAGE(p_app_name    	 => 'OKL',
      			                 p_msg_name		   => 'OKL_AM_DATE_EFF_FROM_LESS_TO',
      			                 p_token1		     => 'DATE_EFFECTIVE_TO',
      			                 p_token1_value	 => p_quot_rec.date_effective_to,
      			                 p_token2		     => 'DATE_EFFECTIVE_FROM',
      			                 p_token2_value	 => p_quot_rec.date_effective_from);
         RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
    END IF;


    --SECHAWLA 18-FEB-03 Bug # 2807201 : Moved the quote_type_check procedure call from here to Create_termination quote procedure

   --IF l_new_quote_type NOT LIKE 'TER_MAN%' THEN ---SECHAWLA 18-FEB-03 Bug # 2807201
   IF p_quot_rec.qtp_code NOT LIKE 'TER_MAN%' THEN ---SECHAWLA 18-FEB-03 Bug # 2807201 : quote type passed to validate_quote is now the new quote type from create_termination_quote
        -- check if early termination
    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- Start ++++++++++++++++

--        IF TRUNC(p_k_end_date) - p_days_before_k_exp > TRUNC(p_sys_date) THEN
        -- rmunjulu EDT 3797384 check with date effective instead of sysdate
        IF TRUNC(p_k_end_date) - p_days_before_k_exp > TRUNC(p_quot_rec.date_effective_from) THEN

    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- End   ++++++++++++++++

    IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'before call to early_termination_allowed  :'||l_return_status);
    END IF;

            -- check if early termination allowed
            early_termination_allowed(
                p_quot_rec        => p_quot_rec,
                p_rule_chr_id     => p_rule_chr_id,
                x_return_status   => l_return_status,
                x_rule_found      => l_rule_found);

           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After call to early_termination_allowed  :'||l_return_status);
           END IF;

            IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                x_return_status := OKL_API.G_RET_STS_ERROR;
                RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSIF (l_rule_found = FALSE) THEN
                x_return_status := OKL_API.G_RET_STS_ERROR;
                -- Early Termination of Contract CONTRACT_NUMBER is not allowed.
                OKL_API.set_message( p_app_name      => 'OKL',
                             p_msg_name      => 'OKL_AM_CONTRACT_EARLY_TERM_NA',
                             p_token1        => 'CONTRACT_NUMBER',
                             p_token1_value  => l_contract_number);
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
        END IF;
   END IF;

   -- rmunjulu PPD
   -- do not allow creation of prior dated term quote before the principal paydown date.
   IF  p_quot_rec.date_effective_from IS NOT NULL
   AND p_quot_rec.date_effective_from <> OKL_API.G_MISS_DATE THEN
   --AND trunc(p_quot_rec.date_effective_from) < trunc(p_sys_date) THEN
   -- rmunjulu Bug 4143251 Removed above condition for PRIOR Dated Quotes, NOW check for all Quotes


    IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'before call to OKL_CS_PRINCIPAL_PAYDOWN_PVT.check_for_ppd  :'||l_return_status);
    END IF;

      -- Added code to check for PPD transaction after quote eff date
      l_pdd_exists := OKL_CS_PRINCIPAL_PAYDOWN_PVT.check_for_ppd(
                            p_khr_id         => p_quot_rec.khr_id,
                            p_effective_date => p_quot_rec.date_effective_from);

    IF (is_debug_statement_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
           'After call to OKL_CS_PRINCIPAL_PAYDOWN_PVT.check_for_ppd  :'||l_return_status);
    END IF;

	  IF l_pdd_exists = 'Y' THEN

         -- A principal paydown transaction exists for contract CONTRACT_NUMBER,
    	 -- can not create a quote with Effective From date before the principal
	     -- paydown transaction date.
         OKL_API.set_message(
	             p_app_name      => 'OKL',
                 p_msg_name      => 'OKL_AM_PPD_ERR',
                 p_token1        => 'CONTRACT_NUMBER',
                 p_token1_value  => l_contract_number);

         RAISE G_EXCEPTION_HALT_VALIDATION;
	  END IF;
   END IF;

   -- SECHAWLA Bug #2680542 : moved all line level validations towards the end,
   -- after contract level validations.

   -- Check that there are contract lines passed as parameters.
    IF (p_assn_tbl.COUNT > 0) THEN
      i := p_assn_tbl.FIRST;
      -- validate contract lines
      LOOP

      IF (is_debug_statement_on) THEN
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_assn_tbl('||i||').'||'p_asset_id   :'|| p_assn_tbl(i).p_asset_id   );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_assn_tbl('||i||').'||'p_asset_number   :'|| p_assn_tbl(i).p_asset_number      );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_assn_tbl('||i||').'||'p_asset_qty   :'|| p_assn_tbl(i).p_asset_qty         );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_assn_tbl('||i||').'||'p_quote_qty   :'|| p_assn_tbl(i).p_quote_qty         );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_assn_tbl('||i||').'||'p_split_asset_number   :'|| p_assn_tbl(i).p_split_asset_number);
      END IF;
        IF ((p_assn_tbl(i).p_asset_id IS NULL) OR
            (p_assn_tbl(i).p_asset_id = OKC_API.G_MISS_NUM)) THEN
                x_return_status := OKL_API.G_RET_STS_ERROR;
                --Quotes are not allowed for contracts without assets.
                OKC_API.SET_MESSAGE (
			      p_app_name	=> 'OKL'
			     ,p_msg_name	=> 'OKL_AM_NO_ASSETS_FOR_QUOTE');
                RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        -- SECHAWLA Bug #2680542 : Added validations to check if asset id is
        -- valid and belongs to the passed contract.
        l_chr_id := 1;

        OPEN l_clines_csr (p_assn_tbl(i).p_asset_id);
        FETCH l_clines_csr INTO l_chr_id, l_l_start_date; -- rmunjulu EDAT
        IF l_clines_csr%NOTFOUND THEN
           x_return_status := OKL_API.G_RET_STS_ERROR;
           -- invalid asset id
           OKC_API.SET_MESSAGE (
			     p_app_name	=> 'OKC'
     			,p_msg_name	=> G_INVALID_VALUE
    			,p_token1	=> G_COL_NAME_TOKEN
    			,p_token1_value	=> 'asset_id');
           RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSIF (l_chr_id <> p_quot_rec.khr_id) OR (l_chr_id = 1) THEN
           x_return_status := OKL_API.G_RET_STS_ERROR;
           --Asset ASSET_NUMBER does not belong to the contract CONTRACT_NUMBER.
           OKC_API.SET_MESSAGE (
			     p_app_name  	=> 'OKL'
     			,p_msg_name 	=> 'OKL_AM_CONTRACT_MISMATCH'
    			,p_token1	    => 'ASSET_NUMBER'
    			,p_token1_value	=> p_assn_tbl(i).p_asset_number,
                 p_token2       => 'CONTRACT_NUMBER',
                 p_token2_value => l_contract_number);
           RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
        CLOSE l_clines_csr;

        -- SECHAWLA Bug #2680542 : Added code to populate asset number if it is null
        IF p_assn_tbl(i).p_asset_number IS NULL
        OR p_assn_tbl(i).p_asset_number = OKC_API.G_MISS_CHAR THEN
           OPEN  l_linesfull_csr(p_assn_tbl(i).p_asset_id);
           FETCH l_linesfull_csr INTO l_name;
           CLOSE l_linesfull_csr;

           p_assn_tbl(i).p_asset_number := l_name;
        END IF;

        -- SECHAWLA Bug #2680542 : Added code to populate asset qty and quote qty, if null
        IF ((p_assn_tbl(i).p_asset_qty IS NULL) OR
            (p_assn_tbl(i).p_asset_qty = OKC_API.G_MISS_NUM)) THEN
            l_asset_qty :=  okl_am_util_pvt.get_asset_quantity(p_assn_tbl(i).p_asset_id);
            IF l_asset_qty IS NULL THEN
                x_return_status := OKL_API.G_RET_STS_ERROR;
                -- Can not create quote because the asset quantity is missing.
                OKC_API.SET_MESSAGE (
			      p_app_name	=> 'OKL'
			     ,p_msg_name	=> 'OKL_AM_NO_ASSET_QTY',
                  p_token1      => 'ASSET_NUMBER',
                  p_token1_value => p_assn_tbl(i).p_asset_number);
                RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
               p_assn_tbl(i).p_asset_qty := l_asset_qty;
            END IF;
        END IF;


        IF ((p_assn_tbl(i).p_quote_qty IS NULL) OR
            (p_assn_tbl(i).p_quote_qty = OKC_API.G_MISS_NUM)) THEN
                p_assn_tbl(i).p_quote_qty := p_assn_tbl(i).p_asset_qty;
        END IF;


        -- RMUNJULU 14-MAR-03 2854796 Error if quote qty less than equal to 0
        IF p_assn_tbl(i).p_quote_qty <= 0 THEN

            -- Please enter a value greater than zero for Units to Terminate of asset ASSET_NUMBER.
            OKL_API.SET_MESSAGE (
			              p_app_name  	 => 'OKL',
			              p_msg_name  	 => 'OKL_AM_QTE_QTY_LESS_THAN_ZERO',
                          p_token1       => 'ASSET_NUMBER',
                          p_token1_value => p_assn_tbl(i).p_asset_number);


            RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;


        -- SECHAWLA Bug #2680542 : Added code to validate quote quantity
        IF p_assn_tbl(i).p_quote_qty > p_assn_tbl(i).p_asset_qty THEN
            x_return_status := OKL_API.G_RET_STS_ERROR;
            -- Asset ASSET_NUMBER quantity is less than the specified quote quantity.
            OKC_API.SET_MESSAGE (
			 p_app_name  	=> 'OKL'
			,p_msg_name  	=> 'OKL_AM_INVALID_QUOTE_QTY',
             p_token1       => 'ASSET_NUMBER',
             p_token1_value => p_assn_tbl(i).p_asset_number);
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        -- SECHAWLA Bug #2680542 : Check if quote invloves a partial asset line.
        IF p_assn_tbl(i).p_quote_qty < p_assn_tbl(i).p_asset_qty THEN
           l_partial_asset_line := TRUE;
        END IF;



        -- RMUNJULU -- 11-DEC-02 Bug # 2484327 -- Added code to check for accepted
        -- quote based on asset level termination changes

    IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'before call to OKL_AM_UTIL_PVT.get_line_quotes  :'||l_return_status);
    END IF;

        -- Check if accepted quote exists for the asset
        OKL_AM_UTIL_PVT.get_line_quotes (
           p_kle_id        => p_assn_tbl(i).p_asset_id,
           x_quote_tbl     => lx_quote_tbl,
           x_return_status => x_return_status);

    IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After call to OKL_AM_UTIL_PVT.get_line_quotes  :'||l_return_status);
    END IF;

        -- Check the return status
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

            -- Error occured in util proc, message set by util proc raise exp
            RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;

        -- Check if accepted quote exists for the asset
        IF lx_quote_tbl.COUNT > 0 THEN

          IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'before call to OKL_AM_UTIL_PVT.get_lookup_meaning  :'||l_return_status);
           END IF;

            l_quote_type := OKL_AM_UTIL_PVT.get_lookup_meaning(
                                      'OKL_QUOTE_TYPE',
                                      lx_quote_tbl(lx_quote_tbl.FIRST).qtp_code,
                                      'Y');

           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'after call to OKL_AM_UTIL_PVT.get_lookup_meaning  :'||l_return_status);
           END IF;
            -- Accepted quote QUOTE_NUMBER of quote type QUOTE_TYPE exists for
            -- asset ASSET_NUMBER. Cannot create another quote for the same asset.
            OKL_API.set_message (
         			 p_app_name  	  => 'OKL',
         			 p_msg_name  	  => 'OKL_AM_ASSET_QTE_EXISTS_ERR',
               p_token1       => 'QUOTE_NUMBER',
               p_token1_value => lx_quote_tbl(lx_quote_tbl.FIRST).quote_number,
               p_token2       => 'QUOTE_TYPE',
               p_token2_value => l_quote_type,
               p_token3       => 'ASSET_NUMBER',
               p_token3_value => p_assn_tbl(i).p_asset_number);

            RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;

	      -- AKP:REPO-QUOTE-START Get the contract product details 6599890
              OKL_AM_UTIL_PVT.get_contract_product_details(
                      p_khr_id           => p_quot_rec.khr_id,
                      x_deal_type        => l_deal_type,
                      x_rev_rec_method   => l_rev_rec_method,
				      x_int_cal_basis    => l_int_cal_basis,
				      x_tax_owner        => l_tax_owner,
				      x_return_status    => l_return_status);


		   IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After call to OKL_AM_UTIL_PVT.get_contract_product_details  :'||l_return_status);
           END IF;


              -- If error then throw exception
              IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                 RAISE G_EXCEPTION_HALT_VALIDATION;

              END IF;
	      -- AKP:REPO-QUOTE-END Get the contract product details

        -- rmunjulu LOANS_ENHANCEMENTS Termination with purchase not allowed for loans
        IF  p_quot_rec.qtp_code IN (    'TER_PURCHASE',     -- Termination - With Purchase
		                                'TER_MAN_PURCHASE', -- Termination - Manual With Purchase
		   					            'TER_RECOURSE',     -- Termination - Recourse With Purchase
		 					        	'TER_ROLL_PURCHASE' -- Termination - Rollover To New Contract With Purchase
							          ) THEN

          IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'before call to OKL_AM_UTIL_PVT.get_contract_product_details  :'||l_return_status);
           END IF;

	      -- AKP:REPO-QUOTE-START  6599890
	/*		  -- Get the contract product details
              OKL_AM_UTIL_PVT.get_contract_product_details(
                      p_khr_id           => p_quot_rec.khr_id,
                      x_deal_type        => l_deal_type,
                      x_rev_rec_method   => l_rev_rec_method,
				      x_int_cal_basis    => l_int_cal_basis,
				      x_tax_owner        => l_tax_owner,
				      x_return_status    => l_return_status);


		   IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After call to OKL_AM_UTIL_PVT.get_contract_product_details  :'||l_return_status);
           END IF;


              -- If error then throw exception
              IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                 RAISE G_EXCEPTION_HALT_VALIDATION;

              END IF; */
	      -- AKP:REPO-QUOTE-END

              IF  l_deal_type LIKE 'LOAN%' THEN

                 -- Termination with purchase quote is not allowed for loan contract.
                 OKL_API.SET_MESSAGE(
                     p_app_name     => 'OKL',
 	                 p_msg_name     => 'OKL_AM_LOAN_PAR_ERR');

                 RAISE G_EXCEPTION_HALT_VALIDATION;

              END IF;
        END IF;

    -- AKP:REPO-QUOTE-START 6599890
    -- asahoo Changed the message, no token will be passed.
    IF (p_quot_rec.repo_quote_indicator_yn IS NOT NULL AND
        p_quot_rec.repo_quote_indicator_yn <> OKL_API.G_MISS_CHAR) THEN
      IF p_quot_rec.repo_quote_indicator_yn ='Y' AND l_deal_type NOT LIKE 'LOAN%'  THEN
         OKL_API.SET_MESSAGE(
                     p_app_name      => 'OKL',
      		     p_msg_name      => 'OKL_AM_REPO_LOAN_VALID');
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
    -- AKP:REPO-QUOTE-END

        IF  l_partial_asset_line = TRUE
        THEN
          -- Bug 4299668 PAGARG Moved the logic (to check whether there is any OKS
          -- line attached to asset) inside l_partial_asset_line condition as OKS
          -- line needs to be verified only in case of partial termination quote.
          -- RMUNJULU 09-APR-03 2897523 Added code to check if OKS line exists linked to covered
          -- asset and trying to create a partial line termination quote on that asset.
          OPEN l_oks_lines_csr ( p_assn_tbl(i).p_asset_id );
          FETCH l_oks_lines_csr INTO l_number;
          IF l_oks_lines_csr%FOUND THEN
             l_oks_line_exists := TRUE;
          END IF;
          CLOSE l_oks_lines_csr;

          IF l_oks_line_exists = TRUE THEN

            -- This asset is linked to a service contract. Assets linked to service contract can not be split.
            OKL_API.set_message (
         			 p_app_name     => 'OKL',
         			 p_msg_name     => 'OKL_LLA_SPA_SERVICE_LINKED');
/*
            -- Service line LINE_NUMBER linked to asset ASSET_NUMBER exists.
            -- Can not create partial asset termination quote for this asset.
            OKL_API.set_message (
         			 p_app_name     => 'OKL',
         			 p_msg_name     => 'OKL_AM_SERVICE_LINE_EXISTS',
                     p_token1       => 'LINE_NUMBER',
                     p_token1_value => l_number,
                     p_token2       => 'ASSET_NUMBER',
                     p_token2_value => p_assn_tbl(i).p_asset_number);
*/

            RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF; -- Bug 4299668


          /* SECHAWLA 04-JAN-06 4915133 ; Moved this piece later in the code : move begin
          -- rmunjulu LOANS_ENHANCEMENTS 13-oct-05 moved this logic here.
          -- rmunjulu LOANS_ENHANCEMENTS Partial line termination for loans with Actual/Estimated Actual not allowed
   	      -- Get the contract product details
          OKL_AM_UTIL_PVT.get_contract_product_details(
                      p_khr_id           => p_quot_rec.khr_id,
                      x_deal_type        => l_deal_type,
                      x_rev_rec_method   => l_rev_rec_method,
				      x_int_cal_basis    => l_int_cal_basis,
				      x_tax_owner        => l_tax_owner,
				      x_return_status    => l_return_status);

           -- If error then throw exception
           IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

              RAISE G_EXCEPTION_HALT_VALIDATION;

           END IF;

           IF  l_deal_type LIKE 'LOAN%'
           AND l_rev_rec_method IN ('ESTIMATED_AND_BILLED','ACTUAL') THEN

                 -- Termination of part of units of asset ASSET_NUMBER is not allowed for contract CONTRACT_NUMBER.
                 OKL_API.SET_MESSAGE(
                     p_app_name     => 'OKL',
 	                 p_msg_name     => 'OKL_AM_LOAN_PAR_LN_TRMNT',
                     p_token1       => 'ASSET_NUMBER',
                     p_token1_value => p_assn_tbl(i).p_asset_number,
                     p_token2       => 'CONTRACT_NUMBER',
                     p_token2_value => l_contract_number);

                 RAISE G_EXCEPTION_HALT_VALIDATION;

           END IF;
           */ -- SECHAWLA 04-JAN-06 4915133 : move end

        END IF;

        --SECHAWLA 04-JAN-06 4915133 : Partial termination quotes (full or partial line)
		--should not be permitted for contracts with revenue recognition method
		--'Estimated and Billed' or 'Actual'
        IF (p_assn_tbl.COUNT < p_no_of_assets) OR (l_partial_asset_line) THEN

           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'before call to OKL_AM_UTIL_PVT.get_contract_product_details  :'||l_return_status);
           END IF;

           -- Moved the above valdation here under this IF condition
           -- Get the contract product details
           OKL_AM_UTIL_PVT.get_contract_product_details(
                      p_khr_id           => p_quot_rec.khr_id,
                      x_deal_type        => l_deal_type,
                      x_rev_rec_method   => l_rev_rec_method,
				      x_int_cal_basis    => l_int_cal_basis,
				      x_tax_owner        => l_tax_owner,
				      x_return_status    => l_return_status);

            IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After call to OKL_AM_UTIL_PVT.get_contract_product_details  :'||l_return_status);
           END IF;

           -- If error then throw exception
           IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

              RAISE G_EXCEPTION_HALT_VALIDATION;

           END IF;

           IF  l_deal_type LIKE 'LOAN%'
           AND l_rev_rec_method IN ('ESTIMATED_AND_BILLED','ACTUAL') THEN

                 -- Termination of part of units of asset ASSET_NUMBER is not allowed for contract CONTRACT_NUMBER.
                 OKL_API.SET_MESSAGE(
                     p_app_name     => 'OKL',
 	                 p_msg_name     => 'OKL_AM_LOAN_PAR_LN_TRMNT');

                 RAISE G_EXCEPTION_HALT_VALIDATION;

           END IF;

        END IF;
        -- SECHAWLA 04-JAN-06 4915133 : end

        -- RMUNJULU 2757312 Added code to validate the new asset number -- START
        IF  p_assn_tbl(i).p_split_asset_number IS NOT NULL
        AND p_assn_tbl(i).p_split_asset_number <> OKL_API.G_MISS_CHAR THEN

            -- If partial Line
            IF  p_assn_tbl(i).p_asset_qty > p_assn_tbl(i).p_quote_qty THEN

           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'before call to asset_number_exists  :'||l_return_status);
           END IF;

                -- Check if Asset Number Unique --
                -- RMUNJULU 3241502 Added p_control
                l_return_status := asset_number_exists(
                                           p_asset_number => p_assn_tbl(i).p_split_asset_number,
                                           p_control      => 'QUOTE',
                                           x_asset_exists => l_asset_exists);

            IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'After call to asset_number_exists  :'||l_return_status);
            END IF;

                IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                    -- Message set in called proc
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;

                -- If Asset Number Entered is not unique raise error
                IF l_asset_exists = 'Y' THEN

                    -- Asset number ASSET_NUMBER already exists.
                    OKL_API.set_message (
             			 p_app_name     => 'OKL',
         			     p_msg_name     => 'OKL_AM_NEW_ASSET_EXISTS',
                         p_token1       => 'ASSET_NUMBER',
                         p_token1_value => p_assn_tbl(i).p_split_asset_number); -- RMUNJULU 3241502 Changed token value
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;

                -- Bug# 5998969 -- start
                OPEN l_asset_autorange_csr;
                FETCH  l_asset_autorange_csr INTO l_asset_init_number;
                CLOSE l_asset_autorange_csr;

                 BEGIN
                    l_temp_asset_number := TO_NUMBER(p_assn_tbl(i).p_split_asset_number);
                    is_number :=1;
                 EXCEPTION
                 WHEN OTHERS THEN
                  is_number :=0;
                 END;
                 IF (is_number = 1) THEN

                   IF (p_assn_tbl(i).p_split_asset_number > l_asset_init_number) THEN
                   -- The New Asset Number ASSET_NUMBER is reserved for automatic asset numbering.
                   -- Asset number beyond AUTO_RANGE  is reserved for automatic asset numbering.
                   --Please modify the New Asset Number.
                   OKL_API.set_message (
             			 p_app_name     => 'OKL',
         			     p_msg_name     => 'OKL_AM_NEW_ASSET_IN_AUOT_RANGE',
                         p_token1       => 'ASSET_NUMBER',
                         p_token1_value => p_assn_tbl(i).p_split_asset_number,
                         p_token2       => 'AUTO_RANGE',
                         p_token2_value => l_asset_init_number);

                    RAISE G_EXCEPTION_HALT_VALIDATION;
                  END IF;
                END IF;
                -- Bug# 5998969 -- end

            END IF;
        END IF;
        -- RMUNJULU 2757312 Added code to validate the new asset number -- END

    -- rmunjulu +++++++++ Effective Dated Termination -- start  ++++++++++++++++

        -- rmunjulu EDAT Check if any asset transactions exists in FA for the asset after quote effective date
        IF  p_quot_rec.date_effective_from IS NOT NULL
        AND p_quot_rec.date_effective_from <> OKL_API.G_MISS_DATE THEN

		   -- ++++++++++++ Same as in Accept Quote API ++++++++++++++++++++++---
           -- rmunjulu EDAT Add code for FA checks, do this only for prior dated terminations
           -- and termination with purchase (which is when we do asset disposal)
           -- rmunjulu Bug 4143251 Changed condition to check for FA Checks for PRE and CURRENT dated quotes
           IF  trunc(p_quot_rec.date_effective_from) <= trunc(p_sys_date)
    	   AND p_quot_rec.qtp_code IN ( 'TER_PURCHASE',     -- Termination - With Purchase
		                                'TER_MAN_PURCHASE', -- Termination - Manual With Purchase
		   					            'TER_RECOURSE',     -- Termination - Recourse With Purchase
		 					        	'TER_ROLL_PURCHASE' -- Termination - Rollover To New Contract With Purchase
							          ) THEN

              IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'before call to OKL_AM_TERMNT_QUOTE_PVT.check_asset_validity_in_fa  :'||l_return_status);
              END IF;

                 OKL_AM_TERMNT_QUOTE_PVT.check_asset_validity_in_fa(
                      p_kle_id          => p_assn_tbl(i).p_asset_id,
                      p_trn_date        => p_quot_rec.date_effective_from, -- quote eff from date will be passed
                      p_check_fa_year   => 'Y', -- do we need to check fiscal year
				      p_check_fa_trn    => 'Y', -- do we need to check fa transactions
				      p_contract_number => l_contract_number,
				      x_return_status   => l_return_status);

			  IF (is_debug_statement_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'After call to OKL_AM_TERMNT_QUOTE_PVT.check_asset_validity_in_fa  :'||l_return_status);
              END IF;

              -- If error in FA checks the throw exception, message set in above routine
              IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                 RAISE G_EXCEPTION_HALT_VALIDATION; -- rmunjulu EDAT 17-Jan-2005
              END IF;
           END IF;
		   -- ++++++++++++ Same as in Accept Quote API ++++++++++++++++++++++---
        END IF;

        -- rmunjulu EDAT Check if quote effectivity date before the asset start date for the quoted asset
        IF  p_quot_rec.date_effective_from IS NOT NULL
        AND p_quot_rec.date_effective_from <> OKL_API.G_MISS_DATE
        AND TRUNC(p_quot_rec.date_effective_from) < TRUNC(l_l_start_date) THEN

           x_return_status := OKL_API.G_RET_STS_ERROR;

           -- Quote Effectivity Date cannot be before asset start date.
           OKL_API.SET_MESSAGE(
                    p_app_name   => 'OKL',
 	                p_msg_name   => 'OKL_AM_EDT_QTE_DATE_ASSET');

           RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;

    -- rmunjulu +++++++++ Effective Dated Termination -- end    ++++++++++++++++


        EXIT WHEN (i = p_assn_tbl.LAST);
        i := p_assn_tbl.NEXT(i);
      END LOOP;
    ELSE
      x_return_status := OKL_API.G_RET_STS_ERROR;
      --Quotes are not allowed for contracts without assets.
      OKC_API.SET_MESSAGE (
			 p_app_name	=> 'OKL'
			,p_msg_name	=> 'OKL_AM_NO_ASSETS_FOR_QUOTE');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    --Bug# 5946411: Removed validation that prevents partial line
    --              termination quote creation for evergreen contracts
    /*
    --SECHAWLA 17-FEB-03 Bug 2804703 : Added the following validation
    IF l_sts_code = 'EVERGREEN' AND (l_partial_asset_line) THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
       -- Unable to create quote with partial asset quantities for Evergreen contract CONTRACT_NUMBER.
       OKC_API.SET_MESSAGE (
			 p_app_name	=> 'OKL'
			,p_msg_name	=> 'OKL_AM_PARTIAL_LINE_EVERGREEN',
             p_token1   => 'CONTRACT_NUMBER',
             p_token1_value => l_contract_number);
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    */

    -- rmunjulu 4143251 Added condition, if contract BOOKED and Partial Quote with
    -- Quote Effective From Date after contract end date then error
    IF  l_sts_code IN ('BOOKED')
	AND ((l_partial_asset_line) OR (p_assn_tbl.COUNT < p_no_of_assets))
	AND (p_quot_rec.date_effective_from IS NOT NULL
         AND p_quot_rec.date_effective_from <> OKL_API.G_MISS_DATE
         AND TRUNC(p_quot_rec.date_effective_from) > TRUNC(l_k_end_date)) THEN

       x_return_status := OKL_API.G_RET_STS_ERROR;


       -- Unable to create partial quote for contract CONTRACT_NUMBER with quote Effective From Date QUOTE_EFF_DATE
	   -- after contract End Date END_DATE.
       OKL_API.SET_MESSAGE (
			 p_app_name	    => 'OKL',
			 p_msg_name	    => 'OKL_AM_PARTIAL_BOOKED_K_ERR',
             p_token1       => 'CONTRACT_NUMBER',
             p_token1_value => l_contract_number,
             p_token2       => 'QUOTE_EFF_DATE',
             p_token2_value => TRUNC(p_quot_rec.date_effective_from),
             p_token3       => 'END_DATE',
             p_token3_value => TRUNC(l_k_end_date));

       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


            IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'before call to OKL_AM_LEASE_LOAN_TRMNT_PVT.check_int_calc_done  :'||l_return_status);
            END IF;
    -- rmunjulu LOANS_ENHANCEMENTS -- Check interest calculation done

    --SECHAWLA 20-JAN-06 4970009 : The following interest calculation check
    --will also be done for lease contracts, with interest calculation basis 'FLOAT_FACTORS','REAMORT'
    --modifying OKL_AM_LEASE_LOAN_TRMNT_PVT.check_int_calc_done
    --no code changes done in this file for bug 4970009
    l_int_calc_done :=  OKL_AM_LEASE_LOAN_TRMNT_PVT.check_int_calc_done(
                                   p_contract_id      => p_quot_rec.khr_id,
                                   p_contract_number  => l_contract_number,
                                   p_source           => 'CREATE',
                                   p_trn_date         => TRUNC(p_quot_rec.date_effective_from));
    IF (is_debug_statement_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
           'After call to OKL_AM_LEASE_LOAN_TRMNT_PVT.check_int_calc_done  :'||l_return_status);
     END IF;

    IF l_int_calc_done IS NULL OR l_int_calc_done = 'N' THEN

        -- Message will be set in called procedure
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    --IF l_new_quote_type NOT LIKE 'TER_MAN%' THEN -- SECHAWLA 18-FEB-03 Bug # 2807201
    IF p_quot_rec.qtp_code NOT LIKE 'TER_MAN%' THEN --SECHAWLA 18-FEB-03 Bug # 2807201 : quote_type passed to validate quote is now the new quote type from create_tyermination_quote

        -- SECHAWLA Bug #2680542 : Added the second condition to the following
        -- IF statement, to check if the quote is partial. A quote is partial
        -- if it has less than the total number of assets on the contract or
        -- has units less than the total number of units for one or more assets
        -- on the contract

        -- check if partial quote
        IF (p_assn_tbl.COUNT < p_no_of_assets)
        OR (l_partial_asset_line) THEN  -- added second condition

          IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
             'before call to partial_termination_allowed  :'||l_return_status);
          END IF;
            -- check partial termination allowed
            partial_termination_allowed(
                p_quot_rec        => p_quot_rec,
                p_rule_chr_id     => p_rule_chr_id,
                x_return_status   => l_return_status,
                x_rule_found      => l_rule_found);

          IF (is_debug_statement_on) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
             'After call to partial_termination_allowed  :'||l_return_status);
          END IF;


            IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                x_return_status := OKL_API.G_RET_STS_ERROR;
                RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSIF (l_rule_found = FALSE) THEN
                x_return_status := OKL_API.G_RET_STS_ERROR;
                --Partial quote for contract CONTRACT_NUMBER is not allowed.
                OKL_API.set_message( p_app_name      => 'OKL',
                             p_msg_name      => 'OKL_AM_PARTIAL_QUOTE_NA',
                             p_token1        => 'CONTRACT_NUMBER',
                             p_token1_value  => l_contract_number);
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
        END IF;
    END IF;

   -- SECHAWLA Bug #2680542 : set the out parameter x_partial_asset_line to
   -- indicate if quote involves a partial
   --   asset line.
   x_partial_asset_line := l_partial_asset_line; -- added

  IF (is_debug_statement_on) THEN
               -- OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               --       'x_partial_asset_line..'||x_partial_asset_line);

                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                      'x_msg_data..'||x_msg_data);

                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                      'x_msg_count..'||x_msg_count);

               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                      'ret status at the end.. '||x_return_status);

   END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,G_MODULE_NAME||'validate_quote ','End(-)');
   END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF k_details_for_qte_csr%ISOPEN THEN
         CLOSE k_details_for_qte_csr;
      END IF;

      IF get_accepted_qte_details_csr%ISOPEN THEN
         CLOSE get_accepted_qte_details_csr;
      END IF;

      IF l_clines_csr%ISOPEN THEN
         CLOSE l_clines_csr;
      END IF;

      IF l_linesfull_csr%ISOPEN THEN
         CLOSE l_linesfull_csr;
      END IF;

      -- RMUNJULU 09-APR-03 2897523
      IF l_oks_lines_csr%ISOPEN THEN
         CLOSE l_oks_lines_csr;
      END IF;

      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF k_details_for_qte_csr%ISOPEN THEN
         CLOSE k_details_for_qte_csr;
      END IF;

      IF get_accepted_qte_details_csr%ISOPEN THEN
         CLOSE get_accepted_qte_details_csr;
      END IF;

      IF l_clines_csr%ISOPEN THEN
         CLOSE l_clines_csr;
      END IF;

      IF l_linesfull_csr%ISOPEN THEN
         CLOSE l_linesfull_csr;
      END IF;

      -- RMUNJULU 09-APR-03 2897523
      IF l_oks_lines_csr%ISOPEN THEN
         CLOSE l_oks_lines_csr;
      END IF;

      IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

      -- unexpected error
      OKL_API.set_message(p_app_name     => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_quote;



  -- Start of comments
  --
  -- Function  Name  : set_currency_defaults
  -- Description     : This procedure Defaults the Multi-Currency Columns
  -- Business Rules  :
  -- Parameters      : Input parameters : px_quot_rec, p_sys_date
  -- Version         : 1.0
  -- History         : 23-DEC-02 RMUNJULU 2726739 Created
  -- End of comments
  PROCEDURE set_currency_defaults(
            px_quot_rec       IN OUT NOCOPY quot_rec_type,
            p_sys_date        IN DATE,
            x_return_status   OUT NOCOPY VARCHAR2) IS

       l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
       l_functional_currency_code VARCHAR2(15);
       l_contract_currency_code VARCHAR2(15);
       l_currency_conversion_type VARCHAR2(30);
       l_currency_conversion_rate NUMBER;
       l_currency_conversion_date DATE;

       l_org_id  NUMBER;
       l_converted_amount NUMBER;

       -- Since we do not use the amount or converted amount in TRX_Quotes table
       -- set a hardcoded value for the amount (and pass to to
       -- OKL_ACCOUNTING_UTIL.convert_to_functional_currency and get back
       -- conversion values )
       l_hard_coded_amount NUMBER := 100;


    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'set_currency_defaults';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begins(+)');
    END IF;

     -- Get the functional currency from AM_Util
     OKL_AM_UTIL_PVT.get_func_currency_org(
                                 x_org_id        => l_org_id,
                                 x_currency_code => l_functional_currency_code);

     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to OKL_AM_UTIL_PVT.get_func_currency_org :l_org_id :'||l_org_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to OKL_AM_UTIL_PVT.get_func_currency_org :l_functional_currency_code :'||l_functional_currency_code);
     END IF;


     -- Get the currency conversion details from ACCOUNTING_Util
     OKL_ACCOUNTING_UTIL.convert_to_functional_currency(
                     p_khr_id  		  	=> px_quot_rec.khr_id,
                     p_to_currency   		=> l_functional_currency_code,
                     p_transaction_date 	=> p_sys_date,
                     p_amount 			=> l_hard_coded_amount,
                     x_return_status            => l_return_status,
                     x_contract_currency	=> l_contract_currency_code,
                     x_currency_conversion_type	=> l_currency_conversion_type,
                     x_currency_conversion_rate	=> l_currency_conversion_rate,
                     x_currency_conversion_date	=> l_currency_conversion_date,
                     x_converted_amount 	=> l_converted_amount);

     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to OKL_ACCOUNTING_UTIL.convert_to_functional_currency :'||l_return_status);
     END IF;

     -- raise exception if error
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     px_quot_rec.currency_code := l_contract_currency_code;
     px_quot_rec.currency_conversion_code := l_functional_currency_code;

     -- If the functional currency is different from contract currency then set
     -- currency conversion columns
     IF l_functional_currency_code <> l_contract_currency_code THEN

        -- Set the currency conversion columns
        px_quot_rec.currency_conversion_type := l_currency_conversion_type;
        px_quot_rec.currency_conversion_rate := l_currency_conversion_rate;
        px_quot_rec.currency_conversion_date := l_currency_conversion_date;

     END IF;

   -- Set the return status
   x_return_status := l_return_status;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

  EXCEPTION

     WHEN OKL_API.G_EXCEPTION_ERROR THEN

         x_return_status := OKL_API.G_RET_STS_ERROR;

     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

     WHEN OTHERS THEN

         -- unexpected error
         OKL_API.set_message(
                         p_app_name      => 'OKC',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);

          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END set_currency_defaults;


 -- Start of comments
  --
  -- Procedure Name : get_net_gain_loss
  -- Description    : returns the net gain loss on a termination quote
  -- Business Rules :
  -- Parameters     :  IN  parameters  -  quote header, contract id
  --                :  OUT parameters  -  net gain loss, return status
  -- Version        : 1.0
  -- History        : rkuttiya created 15-SEP-2003  Bug: 2794685
  --                : RMUNJULU 2794685 Added comments
  --                : rmunjulu 3797384 Added code for passing quote_eff_from date
  --                  and quote_id to formula engine
  -- rmunjulu EDAT 29-Dec-04 did to_char to convert to right format

 PROCEDURE Get_Net_Gain_Loss(
	p_quote_rec	    IN quot_rec_type,
	p_chr_id	    IN NUMBER,
	x_return_status	    OUT NOCOPY VARCHAR2,
	x_net_gain_loss	    OUT NOCOPY NUMBER)   IS

    l_return_status	   VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
    l_rule_code		   CONSTANT VARCHAR2(30) := 'AMGALO';
    l_rgd_code		   VARCHAR2(30);
    l_qtev_rec             okl_trx_quotes_pub.qtev_rec_type;
    l_rule_khr_id          NUMBER;


    l_calc_option	   VARCHAR2(150);
    l_fixed_value	   NUMBER;
    l_formula_name	   VARCHAR2(150);

    l_rulv_rec	       OKL_RULE_PUB.rulv_rec_type;
    l_params	       OKL_EXECUTE_FORMULA_PUB.ctxt_val_tbl_type;
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'Get_Net_Gain_Loss';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
BEGIN

  IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
  END IF;

  l_qtev_rec.khr_id    := p_quote_rec.khr_id;
  l_qtev_rec.qtp_code  := p_quote_rec.qtp_code;

  IF l_qtev_rec.qtp_code LIKE 'TER_RECOURSE%' THEN
    l_rgd_code := 'AVTGAL';
  ELSE
    l_rgd_code := 'AMTGAL';
  END IF;

--get the rule attributes
  l_rule_khr_id := okl_am_util_pvt.get_rule_chr_id (l_qtev_rec);

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'Before call to OKL_AM_UTIL_PVT.get_rule_record :'||l_return_status);
  END IF;

  OKL_AM_UTIL_PVT.get_rule_record(
		p_rgd_code	=> l_rgd_code,
		p_rdf_code	=> l_rule_code,
		p_chr_id	=> l_rule_khr_id,
		p_cle_id	=> NULL,
		x_rulv_rec	=> l_rulv_rec,
 		x_return_status	=> l_return_status,
		p_message_yn	=> FALSE);

  IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to OKL_AM_UTIL_PVT.get_rule_record :'||l_return_status);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'l_rgd_code :'||l_rgd_code);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'l_rule_code :'||l_rule_code);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'l_rule_khr_id :'||l_rule_khr_id);
  END IF;

  IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
    l_calc_option	  := l_rulv_rec.rule_information1;
    l_fixed_value	  := NVL (To_Number (l_rulv_rec.rule_information2), 0);
    l_formula_name    := l_rulv_rec.rule_information3;
  END IF;

  IF l_calc_option = 'NOT_APPLICABLE' THEN -- Net Gain/Loss Option is NOT APPLICABLE

    x_net_gain_loss := 0;

  ELSIF l_calc_option = 'USE_FIXED_AMOUNT' THEN -- Net Gain/Loss Option is FIXED AMOUNT

    x_net_gain_loss := l_fixed_value;

  ELSIF l_calc_option = 'USE_FORMULA' THEN -- Net Gain/Loss Option is FORMULA

      l_params(1).name   := 'QUOTE_ID';
      l_params(1).value  := p_quote_rec.id;

      --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- Start ++++++++++++++++

      -- set the operands for formula engine with quote_effective_from date
      l_params(2).name := 'quote_effective_from_date';
      l_params(2).value := to_char(p_quote_rec.date_effective_from, 'MM/DD/YYYY'); -- rmunjulu EDAT 29-Dec-04 did to_char to convert to right format

      -- set the operands for formula engine with quote_id
      l_params(3).name := 'quote_id';
      l_params(3).value := to_char(p_quote_rec.id);

      --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- End   ++++++++++++++++
  IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'Before call to OKL_AM_UTIL_PVT.get_formula_value :'||l_return_status);
   END IF;
      -- Get the formula value for the formula for Net Gain/Loss Formula
      OKL_AM_UTIL_PVT.get_formula_value (
				p_formula_name	          => l_formula_name,
				p_chr_id	          => l_rule_khr_id,
				p_cle_id                  => NULL,
    				p_additional_parameters   => l_params,
				x_formula_value           => x_net_gain_loss,
				x_return_status	          => l_return_status);
  IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to OKL_AM_UTIL_PVT.get_formula_value :'||l_return_status);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'l_formula_name :'||l_formula_name);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'l_rule_khr_id :'||l_rule_khr_id);
  END IF;

      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
        x_net_gain_loss := 0;
	--RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
  ELSE
    x_net_gain_loss := 0;
  END IF;

IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
END IF;

EXCEPTION
   WHEN OKL_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
            IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     OKL_API.set_message(p_app_name      => g_app_name,
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
END Get_Net_Gain_Loss;


  -- Start of comments
  --
  -- Procedure Name : create_terminate_quote
  -- Description    : create the terminate quote
  -- Business Rules :
  -- Parameters     : quote header, quote lines
  -- Version        : 1.0
  -- History     : SECHAWLA 25-NOV-02 - Bug #2680542 :
  --               1) Added x_partial_asset_line out parameter to validate_quote
  --                  procedure call
  --               2) used x_partial_asset_line parameter later in the procedure
  --                  to check if quote includes partial asset line.
  --               3) removed the code to populate l_asset_tbl as it is no longer
  --                  required to be passed to calculate quote api.
  --               4) passed lp_assn_tbl instead of l_asset_tbl to calculate quote
  --                  api as the calculate quote api now uses the same asset
  --                  record structure as the create quote api.
  --               5) Removed DEFAULT from procedure parameters.
  --
  --             : SECHAWLA 06-DEC-02 - Bug # 2699412 :
  --               1) Change the quote type from Auto to Manual,
  --                  if Auto Quotes are not allowed
  --               2) Call send quote WF only for Auto Quotes
  --               3) If quote type changed from Auto to Manual, then
  --                  notify manual termination quotes REP
  --             : RMUNJULU 23-DEC-02 2726739 Multi-currency changes, default
  --               currency columns
  --             : SECHAWLA 02-JAN-03  2724951 : Changed the event name for
  --               Notify Manual Quote Rep WF
  --             : GKADARKA 06-JAN-03 2683876 Added code to check for non
  --               terminated assets in cursor
  --             : SECHAWLA 16-JAN-02 Bug # 2754280 : Changed the call to fn
  --               get_user_profile_option_name to refer it from am util
  --             : SECHAWLA 14-FEB-03 Bug 2749690 : Added code to update the
  --               quote header with total net investment,
  --               unbilled rec and residual value from all the quote lines
  --             : RMUNJULU 18-FEB-03 2804703 Chngd cursor to get active lines
  --             : SECHAWLA 18-FEB-03 2807201 Moved the check_quote_type procedure call from
  --               validate quote to the beginning if this procedure.
  --             : SECHAWLA 28-FEB-03 2757175 Modified the Manual Quote notification message to
  --               display the profile value and not the underlying ID.
  --             : SECHAWLA 14-APR-03 2902588 Changed the standard REQUIRED message to OKL_AM_NO_VENDOR_PROGRAM
  --               in the not null validation of l_rule_chr_id
  --             : SECHAWLA 15-APR-03 2902588 Changed the fetch order of columns in cur_k_end_date cursor.
  --             : SECHAWLA 03-OCT-03 ER 2777984 Calculate Quote Payments for a partial termination quote
  --             : RMUNJULU 3241502 Added code to set split_asset_number with UPPER CASE
  --             : rmunjulu 3842101 changed code so that gainloss is done after quote updated for net investment
  --             : RMUNJULU EDT 3797384 Added code to default eff_from_date and
  --               changed condition to check for early termination yn
  --             : RMUNJULU LOANS_ENHANCEMENTS Add code to evaluate and populate perdiem amount
  --             : SECHAWLA 15-Jun-09 7383445 Added new parameter p_term_from_intf
  -- End of comments
  PROCEDURE create_terminate_quote(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 ,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    p_quot_rec                  IN  quot_rec_type,
    p_assn_tbl			        IN  assn_tbl_type,
    p_qpyv_tbl			        IN  qpyv_tbl_type ,
    x_quot_rec                  OUT NOCOPY quot_rec_type,
    x_tqlv_tbl			        OUT NOCOPY tqlv_tbl_type,
    x_assn_tbl			        OUT NOCOPY assn_tbl_type,
	p_term_from_intf            IN VARCHAR2 DEFAULT 'N') AS

    -- SECHAWLA 14-APR-03 2902588 : Added contract_number in the SELECT clause. Changed FROM claue to use
    -- okc_k_headers_b instead of okc_k_headers_v
    -- Cursor to get the end date of the contract
    CURSOR cur_k_end_date ( p_chr_id NUMBER) IS
      SELECT  contract_number, end_date
      FROM    OKC_K_HEADERS_B
      WHERE   id = p_chr_id;

    -- Cursor to get the number of financial assets for the contract
    -- Outer join with line styles in UV... but gives error here in calculate quote
    -- GKADARKA 06-JAN-03 2683876 Added code to check for non terminated assets
    -- RMUNJULU 18-FEB-03 2804703 Changed cursor to check for active lines only
    CURSOR cur_k_assets ( p_chr_id NUMBER ) IS
      SELECT COUNT(OKLV.id )
      FROM   OKC_K_LINES_V       OKLV,
             OKC_LINE_STYLES_V   OLSV,
             OKC_K_HEADERS_V     KHR
      WHERE  OKLV.lse_id = OLSV.id
      AND    OLSV.lty_code = 'FREE_FORM1'
      AND    OKLV.chr_id = p_chr_id
      AND    OKLV.sts_code = KHR.sts_code
      AND    OKLV.chr_id = KHR.id;
      --AND    OKLV.date_terminated IS NULL; -- RMUNJULU 18-FEB-03 2804703 removed

    --SECHAWLA 28-FEB-03 Bug # 2757175 : Added the following cursor
    -- This cursor isused to get the display name for a role
    CURSOR l_wfroles_csr(p_name wf_roles.name%TYPE) IS
    SELECT display_name
    FROM   wf_roles
    WHERE  name = p_name;

    l_display_name           wf_roles.display_name%TYPE;
    lx_contract_status       VARCHAR2(200);
    --SECHAWLA 28-FEB-03 Bug # 2757175 : end new declarations

    lp_quot_rec              quot_rec_type := p_quot_rec;
    lx_quot_rec              quot_rec_type;
    lp_assn_tbl              assn_tbl_type := p_assn_tbl;
    lx_assn_tbl              assn_tbl_type := p_assn_tbl;
    lx_tqlv_tbl              tqlv_tbl_type;
    l_qpyv_tbl               qpyv_tbl_type;
    l_quote_eff_days         NUMBER;
    l_quote_eff_max_days     NUMBER;
    l_days_before_k_exp      NUMBER;
    l_api_version            CONSTANT NUMBER := 1;
    l_api_name               CONSTANT VARCHAR2(30) := 'create_terminate_quote';
    l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_no_of_assets           NUMBER := -1;
    l_k_end_date             DATE;
    l_sys_date               DATE;
    i                        NUMBER := 0;
    l_rule_chr_id            NUMBER;
    l_event_name             VARCHAR2(2000);
    lx_partial_asset_line    BOOLEAN;

    lx_auto_to_manual        BOOLEAN := FALSE; --added
    lx_new_quote_type        VARCHAR2(30); --added
    l_user_profile_name      VARCHAR2(240); --added
    l_manual_quote_rep       VARCHAR2(320); --added

    --SECHAWLA 14-FEB-03 Bug 2749690 : new declarations
    l_total_net_investment   NUMBER := 0;
    l_total_unbilled_rec     NUMBER := 0;
    l_total_residual_value   NUMBER := 0;
    lp_empty_quot_rec        quot_rec_type;

    -- SECHAWLA 14-APR-03 2902588 : New Declarations
    l_contract_number        okc_k_headers_b.contract_number%TYPE;

    --rkuttiya 15-SEP-2003 for bug: 2794685
    lx_net_gain_loss    NUMBER;

    -- rmunjulu LOANS_ENHANCEMENTS
    l_per_diem_amt NUMBER;
    l_params OKL_EXECUTE_FORMULA_PUB.ctxt_val_tbl_type;

    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'create_terminate_quote';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
  BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

   --Print Input Variables
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_api_version :'||p_api_version);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'p_init_msg_list :'||p_init_msg_list);
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.id : '||p_quot_rec.id     );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.qrs_code : '||p_quot_rec.qrs_code    );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.qst_code : '||p_quot_rec.qst_code               );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.consolidated_qte_id : '||p_quot_rec.consolidated_qte_id     );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.khr_id : '||p_quot_rec.khr_id                 );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.art_id : '||p_quot_rec.art_id                 );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.qtp_code : '||p_quot_rec.qtp_code               );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.trn_code : '||p_quot_rec.trn_code                 );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.pdt_id : '||p_quot_rec.pdt_id                  );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.date_effective_from : '||p_quot_rec.date_effective_from     );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.quote_number : '||p_quot_rec.quote_number            );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.early_termination_yn : '||p_quot_rec.early_termination_yn       );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.partial_yn : '||p_quot_rec.partial_yn            );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.preproceeds_yn : '||p_quot_rec.preproceeds_yn   );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.summary_format_yn : '||p_quot_rec.summary_format_yn     );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.consolidated_yn : '||p_quot_rec.consolidated_yn     );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.date_requested : '||p_quot_rec.date_requested   );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.date_proposal : '||p_quot_rec.date_proposal   );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.date_effective_to : '||p_quot_rec.date_effective_to    );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.date_accepted : '||p_quot_rec.date_accepted          );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.payment_received_yn : '||p_quot_rec.payment_received_yn      );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.requested_by : '||p_quot_rec.requested_by               );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.approved_yn : '||p_quot_rec.approved_yn                  );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.accepted_yn : '||p_quot_rec.accepted_yn                   );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.org_id : '||p_quot_rec.org_id                        );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.purchase_amount : '||p_quot_rec.purchase_amount               );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.purchase_formula : '||p_quot_rec.purchase_formula              );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.asset_value : '||p_quot_rec.asset_value                   );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.residual_value : '||p_quot_rec.residual_value                );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.unbilled_receivables : '||p_quot_rec.unbilled_receivables          );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.gain_loss : '||p_quot_rec.gain_loss                     );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.PERDIEM_AMOUNT : '||p_quot_rec.PERDIEM_AMOUNT                );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.currency_code : '||p_quot_rec.currency_code                 );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.currency_conversion_code : '||p_quot_rec.currency_conversion_code      );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.legal_entity_id : '||p_quot_rec.legal_entity_id               );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_quot_rec.repo_quote_indicator_yn : '||p_quot_rec.repo_quote_indicator_yn       );

      IF (p_assn_tbl.COUNT > 0) THEN
      FOR i IN p_assn_tbl.FIRST..p_assn_tbl.LAST LOOP

	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_assn_tbl('||i||').'||'p_asset_id   :'|| p_assn_tbl(i).p_asset_id   );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_assn_tbl('||i||').'||'p_asset_number   :'|| p_assn_tbl(i).p_asset_number      );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_assn_tbl('||i||').'||'p_asset_qty   :'|| p_assn_tbl(i).p_asset_qty         );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_assn_tbl('||i||').'||'p_quote_qty   :'|| p_assn_tbl(i).p_quote_qty         );
	OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'p_assn_tbl('||i||').'||'p_split_asset_number   :'|| p_assn_tbl(i).p_split_asset_number);
      End loop;
      END IF;

   END IF;


   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
              'before call to OKL_API.START_ACTIVITY :'||l_return_status);
   END IF;





    --Check API version, initialize message list and create savepoint.
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to OKL_API.START_ACTIVITY :'||l_return_status);
   END IF;

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    SELECT SYSDATE INTO l_sys_date FROM DUAL;

    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- Start ++++++++++++++++
    -- RMUNJULU EDT 3797384 default the date effective from in the beginning
    IF lp_quot_rec.date_effective_from IS NULL
    OR lp_quot_rec.date_effective_from = OKL_API.G_MISS_DATE THEN

       lp_quot_rec.date_effective_from := l_sys_date;

    END IF;
    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- End   ++++++++++++++++

    -- SECHAWLA 28-FEB-03 Bug # 2757175 : Moved the following validation from validate_contract procedure

    -- Call the validate contract to check contract status

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'before call to OKL_AM_LEASE_LOAN_TRMNT_PUB.validate_contract :'||l_return_status);
   END IF;


    OKL_AM_LEASE_LOAN_TRMNT_PUB.validate_contract(
           p_api_version                 =>   p_api_version,
           p_init_msg_list               =>   OKL_API.G_FALSE,
           x_return_status               =>   l_return_status,
           x_msg_count                   =>   x_msg_count,
           x_msg_data                    =>   x_msg_data,
           p_contract_id                 =>   lp_quot_rec.khr_id,
           p_control_flag                =>   'TRMNT_QUOTE_CREATE',
           x_contract_status             =>   lx_contract_status);

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to OKL_AM_LEASE_LOAN_TRMNT_PUB.validate_contract :'||l_return_status);
   END IF;

    -- If error then above api will set the message, so exit now
    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- SECHAWLA 28-FEB-03 Bug # 2757175 :end moved code

    OPEN cur_k_end_date(lp_quot_rec.khr_id);
    -- SECHAWLA 14-APR-03 2902588 : fetched the new column : contract_number
    FETCH cur_k_end_date INTO  l_contract_number, l_k_end_date ;  -- SECHAWLA 15-APR-03 2902588 : Changed the fetch order of columns
    IF cur_k_end_date%NOTFOUND THEN
      l_k_end_date := OKL_API.G_MISS_DATE;
    END IF;
    CLOSE cur_k_end_date;

    OPEN cur_k_assets (lp_quot_rec.khr_id);
    FETCH cur_k_assets INTO  l_no_of_assets;
    IF cur_k_assets%NOTFOUND THEN
      l_no_of_assets := -1;
    END IF;
    CLOSE cur_k_assets;

    -- SECHAWLA 18-FEB-03 Bug # 2807201 : Moved the quote_type_check procedure call here from vaidate_quote
    -- as we want to validate and change the quote type (if required) in the beginning, before any other processing
    -- check if quote type is valid
    lx_new_quote_type := lp_quot_rec.qtp_code; ---SECHAWLA 2699412 added

    -- rmunjulu 4923976 : added if check so that quote type check should not be done for TER_RELEASE_WO_PURCHASE quote
    IF lp_quot_rec.qtp_code <> 'TER_RELEASE_WO_PURCHASE' THEN

       IF (is_debug_statement_on) THEN
           OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
           'before call to quote_type_check :'||l_return_status);
       END IF;
    quote_type_check(
          -- p_qtp_code        =>  p_quot_rec.qtp_code, -- SECHAWLA 2699412
           p_qtp_code        =>  lx_new_quote_type, -- SECHAWLA 2699412 changed
           p_khr_id          =>  lp_quot_rec.khr_id, -- SECHAWLA 02-JAN-03 Added
           x_auto_to_manual  =>  lx_auto_to_manual, -- -SECHAWLA 2699412 added
           x_return_status   =>  l_return_status);

        IF (is_debug_statement_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
            'after call to quote_type_check :'||l_return_status);
        END IF;

    END IF;     -- rmunjulu 4923976

    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
      --Please select a valid Quote Type.
      OKL_API.set_message( p_app_name      => 'OKL',
                           p_msg_name      =>'OKL_AM_QTP_CODE_INVALID');
      RAISE OKL_API.G_EXCEPTION_ERROR; -- SECHAWLA 28-FEB-03 Bug 2757175 : Changed the exception name as a result
                                       -- of moving this procedure from validate_quote on 18-FEB-03 Bug # 2807201
    END IF;

       --SECHAWLA 06-DEC-02 - Bug # 2699412 -- Added
    IF (lx_auto_to_manual) THEN
      lp_quot_rec.qtp_code := lx_new_quote_type;
    END IF;

-- SECHAWLA 18-FEB-03 Bug # 2807201 : end moved code

    l_rule_chr_id := okl_am_util_pvt.get_rule_chr_id (lp_quot_rec);

    -- SECHAWLA 28-FEB-03 Bug # 2757175 : Added a not null validation for l_rule_chr_id
    IF l_rule_chr_id IS NULL THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
       -- SECHAWLA 14-APR-03 2902588 : Use the following message instead of the standard REQUIRED message

       --Unable to create quote because the contract CONTRACT_NUMBER does not have an associated vendor program.
       OKC_API.set_message( p_app_name      => 'OKL',
                            p_msg_name      => 'OKL_AM_NO_VENDOR_PROGRAM',
                            p_token1        => 'CONTRACT_NUMBER',
                            p_token1_value  => l_contract_number);
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- SECHAWLA  Bug # 2699412 : Moved the following code here so that
    -- l_days_before_k_exp can be passed to validate_quote
    -- to check for early terminations


        IF (is_debug_statement_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
            'before call to term_status :'||l_return_status);
        END IF;
   -- set term status from rules
    term_status(
           p_quot_rec             => lp_quot_rec,
           p_rule_chr_id          => l_rule_chr_id,
           x_days_before_k_exp    => l_days_before_k_exp,
           x_return_status        => l_return_status);

        IF (is_debug_statement_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
             'after call to term_status :'||l_return_status);
        END IF;

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- end moved code

    -- SECHAWLA Bug #2680542 : Added x_partial_asset_line parameter to
    -- validate_quote procedure call
    -- check if quote valid
     IF (is_debug_statement_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
            'before call to validate_quote :'||l_return_status);
     END IF;

    validate_quote(
    	p_api_version	       => p_api_version,
    	p_init_msg_list	     => OKL_API.G_FALSE,
    	x_return_status	     => l_return_status,
    	x_msg_count          => x_msg_count,
    	x_msg_data	         => x_msg_data,
    	p_quot_rec	         => lp_quot_rec,
    	p_assn_tbl	         => lp_assn_tbl,
    	p_k_end_date	       => l_k_end_date,
    	p_no_of_assets	     => l_no_of_assets,
    	p_sys_date	         => l_sys_date,
    	p_rule_chr_id        => l_rule_chr_id,
        p_days_before_k_exp  => l_days_before_k_exp,  --SECHAWLA 06-DEC-02 2699412 added
        x_partial_asset_line => lx_partial_asset_line);

     IF (is_debug_statement_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
            'after call to validate_quote :'||l_return_status);
     END IF;

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- RMUNJULU 3241502 Added code to set split_asset_number with UPPER CASE
    IF (lp_assn_tbl.COUNT > 0) THEN
      FOR i IN lp_assn_tbl.FIRST..lp_assn_tbl.LAST LOOP

        IF  lp_assn_tbl(i).p_split_asset_number IS NOT NULL
        AND lp_assn_tbl(i).p_split_asset_number <> OKL_API.G_MISS_CHAR THEN
           lp_assn_tbl(i).p_split_asset_number := UPPER(lp_assn_tbl(i).p_split_asset_number);
        END IF;
      END LOOP;
    END IF;

    IF (is_debug_statement_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
            'before call to quote_effectivity :'||l_return_status);
     END IF;
    -- set the date eff to from rules
    quote_effectivity(
           p_quot_rec             => lp_quot_rec,
           p_rule_chr_id          => l_rule_chr_id,
           x_quote_eff_days       => l_quote_eff_days,
           x_quote_eff_max_days   => l_quote_eff_max_days,
           x_return_status        => l_return_status);

      IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'after call to quote_effectivity :'||l_return_status);
     END IF;

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- check if early termination
    IF (lp_quot_rec.early_termination_yn IS NULL)
    OR (lp_quot_rec.early_termination_yn = OKL_API.G_MISS_CHAR) THEN
    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- Start ++++++++++++++++
--      IF (TRUNC(l_sys_date) < TRUNC(l_k_end_date) - l_days_before_k_exp) THEN
      -- rmunjulu EDT 3797384 changed check to check based on effective date
      IF (TRUNC(lp_quot_rec.date_effective_from) < TRUNC(l_k_end_date) - l_days_before_k_exp) THEN
        lp_quot_rec.early_termination_yn := 'Y';
      ELSE
        lp_quot_rec.early_termination_yn := 'N';
      END IF;
    --+++++++++ rmunjulu 3797384 Future Dated Term Qte -- End   ++++++++++++++++
    END IF;

    -- check if partial quote
    IF (lp_quot_rec.partial_yn IS NULL)
    OR (lp_quot_rec.partial_yn = OKL_API.G_MISS_CHAR) THEN
    -- SECHAWLA Bug #2680542 : Added (lx_partial_asset_line) condition to
    -- the following IF to check if the
    -- quote is a partial quote
      IF (p_assn_tbl.COUNT < l_no_of_assets)
      OR (lx_partial_asset_line) THEN -- added second condition
        lp_quot_rec.partial_yn :=  'Y';
      ELSE
        lp_quot_rec.partial_yn :=  'N';
      END IF;
    END IF;


     IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'before call to set_quote_defaults :'||l_return_status);
     END IF;

    -- Set the quote defaults
    set_quote_defaults(
         px_quot_rec              => lp_quot_rec,
         p_rule_chr_id            => l_rule_chr_id,
         p_sys_date               => l_sys_date,
         x_return_status          => l_return_status);

     IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'after call to set_quote_defaults :'||l_return_status);
     END IF;

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;



     IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'before call to set_currency_defaults :'||l_return_status);
     END IF;

    -- RMUNJULU 23-DEC-02 2726739 Multi-currency changes
    -- Default the Multi-Currency Columns
    set_currency_defaults(
         px_quot_rec              => lp_quot_rec,
         p_sys_date               => l_sys_date,
         x_return_status          => l_return_status);

     IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'after call to set_currency_defaults :'||l_return_status);
     END IF;

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'before call to OKL_TRX_QUOTES_PUB.insert_trx_quotes :'||l_return_status);
     END IF;

    -- call the pub tapi insert
    OKL_TRX_QUOTES_PUB.insert_trx_quotes (
         p_api_version      =>   p_api_version,
         p_init_msg_list    =>   OKL_API.G_FALSE,
         x_msg_count        =>   x_msg_count,
         x_msg_data         =>   x_msg_data,
         p_qtev_rec         =>   lp_quot_rec,
         x_qtev_rec         =>   lx_quot_rec,
         x_return_status    =>   l_return_status);

     IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'after call to OKL_TRX_QUOTES_PUB.insert_trx_quotes :'||l_return_status);
     END IF;

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


     IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'before call to OKL_AM_PARTIES_PVT.create_quote_parties :'||l_return_status);
     END IF;

    -- Create quote parties
    OKL_AM_PARTIES_PVT.create_quote_parties (
         p_qtev_rec         =>   lx_quot_rec,
         p_qpyv_tbl         =>   p_qpyv_tbl,
         x_qpyv_tbl         =>   l_qpyv_tbl,
         x_return_status    =>   l_return_status);

     IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'after call to OKL_AM_PARTIES_PVT.create_quote_parties :'||l_return_status);
     END IF;


    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- call quote calculation api (pass assets tbl)
    -- this will insert quote lines

     IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'before call to OKL_AM_CALCULATE_QUOTE_PVT.generate :'||l_return_status);
     END IF;

    OKL_AM_CALCULATE_QUOTE_PVT.generate(
         p_api_version      =>   p_api_version,
         p_init_msg_list    =>   OKL_API.G_FALSE,
         x_msg_count        =>   x_msg_count,
         x_msg_data         =>   x_msg_data,
         p_qtev_rec         =>   lx_quot_rec,
       --p_asset_tbl        =>   l_asset_tbl, -- SECHAWLA Bug #2680542 : calculate quote api now uses the same asset
         p_asset_tbl        =>   lp_assn_tbl,   -- record structure as the create quote api
         x_tqlv_tbl         =>   lx_tqlv_tbl,
         x_return_status    =>   l_return_status);

     IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'After call to OKL_AM_CALCULATE_QUOTE_PVT.generate :'||l_return_status);
     END IF;

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- SECHAWLA 14-FEB-03 2749690 : sum up the net investment, unbilled receivable and residual value amounts for
    -- the quote lines and store the total amounts at the quote header level
    IF lx_tqlv_tbl.COUNT > 0 THEN
       i := lx_tqlv_tbl.FIRST;
       LOOP
           IF lx_tqlv_tbl(i).qlt_code = 'AMCFIA' THEN
              l_total_net_investment := l_total_net_investment + lx_tqlv_tbl(i).asset_value;
              l_total_unbilled_rec := l_total_unbilled_rec + lx_tqlv_tbl(i).unbilled_receivables;
              l_total_residual_value := l_total_residual_value + lx_tqlv_tbl(i).residual_value;
           END IF;

           EXIT WHEN (i = lx_tqlv_tbl.LAST);
           i := lx_tqlv_tbl.NEXT(i);
       END LOOP;
    END IF;

    -- call the pub tapi update to update the above totals at the header level
    lp_quot_rec := lp_empty_quot_rec;
    lp_quot_rec.id := lx_quot_rec.id ;
    lp_quot_rec.asset_value := l_total_net_investment;
    lp_quot_rec.unbilled_receivables := l_total_unbilled_rec;
    lp_quot_rec.residual_value := l_total_residual_value;

    IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'before call to OKL_TRX_QUOTES_PUB.update_trx_quotes :'||l_return_status);
     END IF;

    OKL_TRX_QUOTES_PUB.update_trx_quotes (
         p_api_version      =>   p_api_version,
         p_init_msg_list    =>   OKL_API.G_FALSE,
         x_msg_count        =>   x_msg_count,
         x_msg_data         =>   x_msg_data,
         p_qtev_rec         =>   lp_quot_rec,
         x_qtev_rec         =>   lx_quot_rec,
         x_return_status    =>   l_return_status);

     IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'After call to OKL_TRX_QUOTES_PUB.update_trx_quotes :'||l_return_status);
     END IF;

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- end new code


    IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'before call to get_net_gain_loss :'||l_return_status);
     END IF;

   -- rmunjulu 3842101 moved net gain loss calculation here
     get_net_gain_loss(
                 p_quote_rec		    =>lx_quot_rec,
	             p_chr_id		        =>lx_quot_rec.khr_id,
	             x_return_status	    =>l_return_status,
	             x_net_gain_loss	    =>lx_net_gain_loss)  ;


	  IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'After call to get_net_gain_loss :'||l_return_status);
      END IF;

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- rmunjulu 3842101    added this code here so that formula uses calculation from quote
    lp_quot_rec := lp_empty_quot_rec;
    lp_quot_rec.id := lx_quot_rec.id ;
    lp_quot_rec.gain_loss := lx_net_gain_loss;

    l_params(1).name   := 'QUOTE_ID';
    l_params(1).value  := lp_quot_rec.id;

    IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'before call to OKL_AM_UTIL_PVT.get_formula_value :'||l_return_status);
     END IF;

    -- rmunjulu LOANS_ENHANCEMENTS Evaluate Quote perdiem amount formula and set quote perdiem value
    OKL_AM_UTIL_PVT.get_formula_value(
				p_formula_name	          => 'QUOTE_PERDIEM_AMOUNT',
				p_chr_id	              => lx_quot_rec.khr_id,
                p_cle_id                  => NULL,
    	        p_additional_parameters   => l_params,
				x_formula_value           => l_per_diem_amt,
				x_return_status	          => l_return_status);

     IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'After call to OKL_AM_UTIL_PVT.get_formula_value :'||l_return_status);
     END IF;

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    lp_quot_rec.perdiem_amount := l_per_diem_amt;


     IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'Before call to OKL_TRX_QUOTES_PUB.update_trx_quotes :'||l_return_status);
     END IF;

    -- rmunjulu 3842101 update the quote header again with GAIN LOSS + PERDIEM
    OKL_TRX_QUOTES_PUB.update_trx_quotes (
         p_api_version      =>   p_api_version,
         p_init_msg_list    =>   OKL_API.G_FALSE,
         x_msg_count        =>   x_msg_count,
         x_msg_data         =>   x_msg_data,
         p_qtev_rec         =>   lp_quot_rec,
         x_qtev_rec         =>   lx_quot_rec,
         x_return_status    =>   l_return_status);

     IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
         'After call to OKL_TRX_QUOTES_PUB.update_trx_quotes :'||l_return_status);
     END IF;

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- rmunjulu TNA 4059175 Brought this up above the workflow processing.
    -- SECHAWLA 03-OCT-2003 11i10 ER 2777984:Calculate Quote Payments for a partial termination quote
    IF lx_quot_rec.partial_yn = 'Y' THEN

     IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'Before call to OKL_AM_CALC_QUOTE_PYMNT_PVT.calc_quote_payments :'||l_return_status);
     END IF;

       OKL_AM_CALC_QUOTE_PYMNT_PVT.calc_quote_payments(
            p_api_version		=>   p_api_version,
            p_init_msg_list		=>   OKL_API.G_FALSE,
            x_return_status		=>   l_return_status,
            x_msg_count			=>   x_msg_count,
            x_msg_data			=>   x_msg_data,
            p_quote_id          =>   lx_quot_rec.id);

      IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'After call to OKL_AM_CALC_QUOTE_PYMNT_PVT.calc_quote_payments :'||l_return_status);
      END IF;

       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

    END IF;
    -- SECHAWLA 03-OCT-2003 11i10 ER : 2777984 end

/* -- rmunjulu messages come twice so this fix
    -- rmunjulu TNA 4059175 Added process message here to get the messages
    -- Save messages in database
    OKL_AM_UTIL_PVT.process_messages (
	      p_trx_source_table	=> 'OKL_TRX_QUOTES_V',
	      p_trx_id		=> lx_quot_rec.id,
	      x_return_status	=> l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
*/

    -- rmunjulu TNA 4059175 Added new IF to check for non Release quotes and DO send quote only for those
    -- sechawla bug 7383445 - Added p_term_from_intf check : raise sendquote evant for approval, only if
    -- auto_accept_yn is set to 'N' in termination interface table. If auto_accept_yn is set to 'Y', quote
    -- staus should get automatically changed to APPROVED, and approval is not needed
    IF (lx_new_quote_type <> 'TER_RELEASE_WO_PURCHASE' AND (p_term_from_intf = 'N')) THEN

       -- rmunjulu TNA By this time the quote is already switched to manual if needed so will not go into this if
       IF lx_new_quote_type NOT LIKE 'TER_MAN%' THEN -- SECHAWLA 06-DEC-02 - Bug # 2699412 -- added
            -- Request quote approval and notification

      IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'Before call to OKL_AM_WF.raise_business_event :'||l_return_status);
       END IF;

            OKL_AM_WF.raise_business_event (
                        p_transaction_id => lx_quot_rec.id,
                        p_event_name	   => 'oracle.apps.okl.am.sendquote');

       IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'After call to OKL_AM_WF.raise_business_event :'||l_return_status);
       END IF;

       END IF;

       -- SECHAWLA 06-DEC-02 - Bug # 2699412 -- Added the following program logic
       -- to send notification to the manual
       -- quote representative, if the quote type was changed from Auto to Manual
       IF (lx_auto_to_manual) THEN

          -- rmunjulu messages come twice so this fix
          -- rmunjulu TNA 4059175 Added process message here to get the messages
          -- Save messages in database

         IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
          'Before call to OKL_AM_UTIL_PVT.process_messages  :'||l_return_status);
         END IF;

          OKL_AM_UTIL_PVT.process_messages (
	        p_trx_source_table	=> 'OKL_TRX_QUOTES_V',
	        p_trx_id		=> lx_quot_rec.id,
	        x_return_status	=> l_return_status);

          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          -- clear the stack
          okl_api.init_msg_list ( p_init_msg_list  => OKL_API.G_TRUE);

          l_manual_quote_rep := fnd_profile.value('OKL_MANUAL_TERMINATION_QUOTE_REP');

          IF l_manual_quote_rep IS NULL THEN


            IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                'Before call to okl_am_util_pvt.get_user_profile_option_name  :'||l_return_status);
            END IF;

              l_user_profile_name := okl_am_util_pvt.get_user_profile_option_name(
                                       p_profile_option_name  => 'OKL_MANUAL_TERMINATION_QUOTE_REP',
                                       x_return_status        => l_return_status);

              IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
                  --Manual Quote Representative profile is missing.
                  OKL_API.set_message( p_app_name      => 'OKL',
                                       p_msg_name      => 'OKL_AM_NO_MQ_REP_PROFILE');

                  RAISE okl_api.G_EXCEPTION_ERROR;
              ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              END IF;

              x_return_status := OKL_API.G_RET_STS_ERROR;

              --Profile value not defined
              OKL_API.set_message(
                               p_app_name      => 'OKL',
                               p_msg_name      => 'OKL_AM_RMK_NO_PROFILE_VALUE',
                               p_token1        => 'PROFILE',
                               p_token1_value  => l_user_profile_name);

              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          --SECHAWLA 28-FEB-03 Bug # 2757175 : get the display name for a role
          OPEN   l_wfroles_csr(l_manual_quote_rep);
          FETCH  l_wfroles_csr INTO l_display_name;
          CLOSE  l_wfroles_csr;

          IF  l_display_name IS NULL THEN
              l_display_name := l_manual_quote_rep;
          END IF;

          -- Contract only allows for manual quotes. Manual quote request
          -- has been sent to MAN_QUOTE_REP.
          OKL_API.set_message(
		        p_app_name     => 'OKL',
                        p_msg_name     => 'OKL_AM_MAN_QUOTE_ALLOWED',
                        p_token1       => 'MAN_QUOTE_REP',
                        p_token1_value => l_display_name); --SECHAWLA 28-FEB-03 Bug # 2757175 : Changed to show display_name
                                                           -- instead of name

            IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                'Before call to OKL_AM_WF.raise_business_event p_event_name oracle.apps.okl.am.manualquote  :'||l_return_status);
            END IF;


          --SECHAWLA 28-FEB-03 Bug # 2757175 :  end modifications
          -- notify manual quote representative
          OKL_AM_WF.raise_business_event (
                   p_transaction_id => lx_quot_rec.id,
                   p_event_name	   => 'oracle.apps.okl.am.manualquote'); -- SECHAWLA 02-JAN-03  2724951  Changed the event name

          -- Save messages in database
          OKL_AM_UTIL_PVT.process_messages (
	        p_trx_source_table	=> 'OKL_TRX_QUOTES_V',
	        p_trx_id		=> lx_quot_rec.id,
	        x_return_status	=> l_return_status);

       ELSE -- if not auto to manual -- rmunjulu TNA 4059175 Added this if

          -- Save messages in database
          OKL_AM_UTIL_PVT.process_messages (
	         p_trx_source_table	=> 'OKL_TRX_QUOTES_V',
	         p_trx_id		=> lx_quot_rec.id,
	         x_return_status	=> l_return_status);

          --SECHAWLA 06-DEC-02 - Bug # 2699412 -- added the exception handling
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
       END IF;
       -- SECHAWLA 06-DEC-02 - Bug # 2699412 -- end new code
    ELSE -- Quote is Termination Release Without Purchase -- rmunjulu TNA 4059175

       -- Update the quote to approved directly
       lp_quot_rec := lp_empty_quot_rec;
       lp_quot_rec.id := lx_quot_rec.id ;
       lp_quot_rec.qst_code := 'APPROVED';
       lp_quot_rec.date_approved := sysdate;

	    IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                'Before call to OKL_TRX_QUOTES_PUB.update_trx_quotes'||l_return_status);
        END IF;

       -- rmunjulu TNA 4059175 update the quote header with status as APPROVED
       OKL_TRX_QUOTES_PUB.update_trx_quotes (
         p_api_version      =>   p_api_version,
         p_init_msg_list    =>   OKL_API.G_FALSE,
         x_msg_count        =>   x_msg_count,
         x_msg_data         =>   x_msg_data,
         p_qtev_rec         =>   lp_quot_rec,
         x_qtev_rec         =>   lx_quot_rec,
         x_return_status    =>   l_return_status);

        IF (is_debug_statement_on) THEN
                 OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                'After call to OKL_TRX_QUOTES_PUB.update_trx_quotes'||l_return_status);
        END IF;

       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       -- Save messages in database
       OKL_AM_UTIL_PVT.process_messages (
	      p_trx_source_table	=> 'OKL_TRX_QUOTES_V',
	      p_trx_id		=> lx_quot_rec.id,
	      x_return_status	=> l_return_status);

       --SECHAWLA 06-DEC-02 - Bug # 2699412 -- added the exception handling
       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    END IF;

    -- set the return status and out variables
    x_return_status := l_return_status;
    x_quot_rec      := lx_quot_rec;
    x_assn_tbl      := lx_assn_tbl;
    x_tqlv_tbl      := lx_tqlv_tbl;

    -- end the transaction
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);


   IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                      'x_return_status..'||x_return_status);
   END IF;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,G_MODULE_NAME||'create_terminate_quote. ','End(-)');
   END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF cur_k_assets%ISOPEN THEN
         CLOSE cur_k_assets;
      END IF;
      IF cur_k_end_date%ISOPEN THEN
         CLOSE cur_k_end_date;
      END IF;
      --SECHAWLA 28-FEB-03 Bug # 2757175 : Close the new cursor
      IF l_wfroles_csr%ISOPEN THEN
         CLOSE l_wfroles_csr;
      END IF;
      IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                      'EXCEPTION ERROR');
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
     (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF cur_k_assets%ISOPEN THEN
         CLOSE cur_k_assets;
      END IF;
      IF cur_k_end_date%ISOPEN THEN
         CLOSE cur_k_end_date;
      END IF;
      --SECHAWLA 28-FEB-03 Bug # 2757175 : Close the new cursor
      IF l_wfroles_csr%ISOPEN THEN
         CLOSE l_wfroles_csr;
      END IF;
      IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                      'UNEXPECTED EXCEPTION ERROR');
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
         (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      IF cur_k_assets%ISOPEN THEN
         CLOSE cur_k_assets;
      END IF;
      IF cur_k_end_date%ISOPEN THEN
         CLOSE cur_k_end_date;
      END IF;
      --SECHAWLA 28-FEB-03 Bug # 2757175 : Close the new cursor
      IF l_wfroles_csr%ISOPEN THEN
         CLOSE l_wfroles_csr;
      END IF;
      IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                      'OTHER EXCEPTION ERROR');
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END create_terminate_quote;

   FUNCTION check_repo_quote(p_quote_id     IN VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2)
                              RETURN VARCHAR2 IS
   l_repo_yn   VARCHAR2(1);

   CURSOR check_repo_csr(p_quote_id IN NUMBER) IS
   SELECT NVL(repo_quote_indicator_yn,'N')
   FROM OKL_TRX_QUOTES_B
   WHERE id = p_quote_id;

   BEGIN
     -- Check whether the quote is for Repossession
     OPEN check_repo_csr(p_quote_id);
     FETCH check_repo_csr INTO l_repo_yn;
     CLOSE check_repo_csr;

     x_return_status := OKL_API.G_RET_STS_SUCCESS;
     RETURN l_repo_yn;
   EXCEPTION
    WHEN OTHERS THEN

      IF check_repo_csr%ISOPEN THEN
        CLOSE check_repo_csr;
      END IF;
      x_return_status := OKL_API.G_RET_STS_ERROR;
   END;



END OKL_AM_CREATE_QUOTE_PVT;

/
