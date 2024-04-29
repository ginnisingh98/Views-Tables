--------------------------------------------------------
--  DDL for Package Body OKL_PROCESS_PPD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PROCESS_PPD_PVT" AS
/* $Header: OKLRPPNB.pls 120.2 2006/08/11 10:47:13 gboomina noship $*/

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;

--Global Variables
  G_INIT_NUMBER NUMBER := -9999;
  G_PKG_NAME    CONSTANT VARCHAR2(200) := 'OKL_PPD_PVT';
  G_APP_NAME    CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PVT';

PROCEDURE validate_parameters(
    p_chr_id             IN  OKC_K_HEADERS_V.ID%TYPE,
    p_kle_tbl            IN  OKL_MASS_REBOOK_PVT.kle_tbl_type,
    p_transaction_date   IN  OKL_TRX_CONTRACTS.DATE_TRANSACTION_OCCURRED%TYPE,
    p_ppd_amount         IN  NUMBER,
    p_ppd_reason_code    IN  FND_LOOKUPS.LOOKUP_CODE%TYPE,
    p_payment_struc      IN  okl_mass_rebook_pvt.strm_lalevl_tbl_type,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2
)
IS
type asset_rec_type is record (
  cle_id okc_rule_groups_v.cle_id%type,
  rent_ppd_type VARCHAR2(30),
  laslh_count number,
  lasll_count number,
  other_count number
);

type validate_rec_type is RECORD (
  chr_id  OKC_K_HEADERS_V.ID%TYPE,
  asset_rec asset_rec_type
);
type val_rec_tbl is table of validate_rec_type index by binary_integer;

l_api_name varchar2(100) := 'OKL_PROCESS_PPD_PVT.VALIDATE_PARAMETERS';
missing_parameters exception;
invalid_payment_structure exception;
l_missing_parameters BOOLEAN := FALSE;
l_object1_id1 number;
l_lalsh_id number;
l_prev_chr_id number;
l_curr_chr_id number;
l_curr_cle_id number;
l_prev_cle_id number;
l_prev_category okc_rules_v.rule_information_category%type;
l_curr_category okc_rules_v.rule_information_category%type;
BEGIN
  -- Check if all parameters are not null
  -- Validate if
  -- 1. SLH is there but no SLL
  -- 2. starts with SLL and SLH follows
  null;
  x_msg_count := 0;
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In validate_parameters ...x_msg_count='||x_msg_count);
  END IF;
  IF (p_chr_id is null) THEN
    fnd_message.set_name('OKL', 'OKL_API_ALL_MISSING_PARAM');
    fnd_message.set_token('API_NAME', l_api_name);
    fnd_message.set_token('MISSING_PARAM', 'p_chr_id');
    x_msg_count:= x_msg_count + 1;
    l_missing_parameters := TRUE;
    fnd_msg_pub.add;
  END IF;

  IF ((p_kle_tbl is null) or (p_kle_tbl.COUNT=0)) THEN
    fnd_message.set_name('OKL', 'OKL_API_ALL_MISSING_PARAM');
    fnd_message.set_token('API_NAME', l_api_name);
    fnd_message.set_token('MISSING_PARAM', 'p_kle_tbl');
    x_msg_count:= x_msg_count + 1;
    l_missing_parameters := TRUE;
    fnd_msg_pub.add;
  END IF;

  IF (p_transaction_date is null) THEN
    fnd_message.set_name('OKL', 'OKL_API_ALL_MISSING_PARAM');
    fnd_message.set_token('API_NAME', l_api_name);
    fnd_message.set_token('MISSING_PARAM', 'p_transaction_date');
    x_msg_count:= x_msg_count + 1;
    l_missing_parameters := TRUE;
    fnd_msg_pub.add;
  END IF;

  IF (p_ppd_amount is null) THEN
    fnd_message.set_name('OKL', 'OKL_API_ALL_MISSING_PARAM');
    fnd_message.set_token('API_NAME', l_api_name);
    fnd_message.set_token('MISSING_PARAM', 'p_ppd_amount');
    x_msg_count:= x_msg_count + 1;
    l_missing_parameters := TRUE;
    fnd_msg_pub.add;
  END IF;

  IF (p_ppd_reason_code is null) THEN
    fnd_message.set_name('OKL', 'OKL_API_ALL_MISSING_PARAM');
    fnd_message.set_token('API_NAME', l_api_name);
    fnd_message.set_token('MISSING_PARAM', 'p_ppd_reason_code');
    x_msg_count:= x_msg_count + 1;
    l_missing_parameters := TRUE;
    fnd_msg_pub.add;
  END IF;

  IF (p_payment_struc is null) or (p_payment_struc.COUNT=0) THEN
    fnd_message.set_name('OKL', 'OKL_API_ALL_MISSING_PARAM');
    fnd_message.set_token('API_NAME', l_api_name);
    fnd_message.set_token('MISSING_PARAM', 'p_payment_struc');
    x_msg_count:= x_msg_count + 1;
    l_missing_parameters := TRUE;
    fnd_msg_pub.add;
  END IF;

  for i in p_payment_struc.first .. p_payment_struc.last loop
    if (p_payment_struc(i).chr_id is null or p_payment_struc(i).cle_id is null)
    then
      l_missing_parameters := true;
      exit;
    end if;
  end loop;

  IF l_missing_parameters then
    raise missing_parameters;
    RETURN;
  END IF;

  x_msg_count := 0;
  x_msg_data := '';
  l_prev_category := '';
  l_prev_chr_id := -1;
  l_prev_cle_id := -1;
  /*FOR i IN 1..p_kle_tbl.COUNT
  LOOP
    l_slh_count   := 0;
    l_sll_count   := 0;
    l_oth_count   := 0; */
    FOR j IN 1..p_payment_struc.COUNT
    LOOP
      -- Whenever you get an SLH record, create an asset record
      -- Whenever you get an SLL record, create an asset record if current
      -- asset id does not match or if object1_id1 does not match prev SLH ID
      -- Whenever you get an OTH record, create an asset record if current
      -- asset id does not match

      --IF (p_kle_tbl(i).id = p_payment_struc(j).cle_id) THEN

         l_curr_chr_id := p_payment_struc(j).chr_id ;
         l_curr_cle_id := p_payment_struc(j).cle_id;
         l_curr_category := p_payment_struc(j).rule_information_category;

         /*if (l_curr_category = 'LASLL') then
           -- hardcode values without which update fails : DEBUG
           p_payment_struc(j).jtot_object2_code := 'OKL_STRMHDR';
         end if;*/

         if ((l_curr_category = 'LASLH') and (l_prev_category = 'LASLH'))
         THEN
           null;
           x_msg_count := x_msg_count + 1;
           x_msg_data := 'Contract: ' || l_prev_chr_id || ' Asset: ' ||
                       l_prev_cle_id || ' contains no LASLL records';
           --okl_debug_pub.logmessage('x_msg_data=' || x_msg_data);
           raise invalid_payment_structure;
           -- raise no SLL record found for SLH
         END IF;
         --IF ( ((l_curr_chr_id <> l_prev_chr_id) and (l_prev_chr_id <> -1)) or
             --((l_curr_cle_id <> l_prev_cle_id) and (l_prev_cle_id <> -1)) )
         IF ( (l_curr_chr_id <> l_prev_chr_id) or
              (l_curr_cle_id <> l_prev_cle_id) )
         THEN
           null;
           --Change of asset or contract or both
           IF (p_payment_struc(j).rule_information_category <> 'LASLH') THEN
             null;
             x_msg_count := x_msg_count + 1;
             x_msg_data := 'Contract ' || l_curr_chr_id || ' Asset ' ||
                       l_curr_cle_id || ' begins with non LASLH category';
             raise invalid_payment_structure;
             -- Begins with invalid category (<> LASLH)
             -- Raise exception
           END IF;
         END IF;
         /*
         IF (p_payment_struc(j).rule_information_category = 'LASLH') THEN
           null;
           l_slh_count := l_slh_count + 1;
           begin
             l_object1_id1 := p_payment_struc(j).object1_id1;
             l_laslh_id := p_payment_struc(j).id;
             select name into l_ppd_rent from okl_strm_type_v
             where  id = l_object1_id1;
             exception when others then
               l_ppd_rent := 'OTHER';
           end;
         ELSIF (p_payment_struc(j).rule_information_category = 'LASLL') THEN
           null;
         ELSE
           null;
         END IF;
         */
       --END IF;
       l_prev_chr_id := l_curr_chr_id;
       l_prev_cle_id := l_curr_cle_id;
       l_prev_category := l_curr_category;
    END LOOP;
END;

PROCEDURE apply_ppd
   (
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2,
    p_chr_id             IN  OKC_K_HEADERS_V.ID%TYPE,
    p_kle_tbl            IN  OKL_MASS_REBOOK_PVT.kle_tbl_type,
    p_transaction_date   IN  OKL_TRX_CONTRACTS.DATE_TRANSACTION_OCCURRED%TYPE,
    p_ppd_amount         IN  NUMBER,
    p_ppd_reason_code    IN  FND_LOOKUPS.LOOKUP_CODE%TYPE,
    p_payment_struc      IN  okl_mass_rebook_pvt.strm_lalevl_tbl_type,
    p_ppd_txn_id         IN  NUMBER
   )
IS
missing_parameters exception;
l_api_version CONSTANT NUMBER := 1;
l_api_name                   VARCHAR2(35) := 'apply_ppd';
l_proc_name                  VARCHAR2(35) := 'APPLY_PPD';
l_ppd_txn_id                 NUMBER;
l_return_status              VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
l_mass_rebook_trx_id         NUMBER;
l_tcnv_rec                   OKL_TRX_CONTRACTS_PVT.tcnv_rec_type;
l_msg_index_out number;
BEGIN

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In apply_ppd');
     END IF;
     -- DEBUG
     -- call START_ACTIVITY to create savepoint, check compatibility
     -- and initialize message list
     x_return_status := OKL_API.START_ACTIVITY(
                                        p_api_name      => l_api_name,
                                        p_pkg_name      => G_PKG_NAME,
                                        p_init_msg_list => p_init_msg_list,
                                        l_api_version   => l_api_version,
                                        p_api_version   => p_api_version,
                                        p_api_type      => G_API_TYPE,
                                        x_return_status => x_return_status);

     -- check if activity started successfully
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

  begin
  x_msg_count := 0;
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'apply_ppd:x_msg_count=' || x_msg_count);
  END IF;
  validate_parameters(
    p_chr_id,
    p_kle_tbl,
    p_transaction_date,
    p_ppd_amount,
    p_ppd_reason_code,
    p_payment_struc,
    x_msg_count,
    x_msg_data
  );
    exception when others then
      raise missing_parameters;
  end;

  /* PPD Transaction creation is handled by forms
  okl_debug_pub.logmessage('Before call to okl_transaction_pvt.create_ppd_transaction');
  -- DEBUG: Replace this API by actual API to create ppd transaction
   okl_transaction_pvt.create_ppd_transaction(
         p_api_version        => p_api_version,
         p_init_msg_list      => p_init_msg_list,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data,
         p_chr_id             => p_chr_id,
         p_trx_date           => p_transaction_date,
         p_trx_type           => 'PDN',
         p_reason_code        => p_ppd_reason_code,
         x_tcnv_rec           => l_tcnv_rec
   );

   if (x_return_status <> OKL_API.G_RET_STS_SUCCESS) then
     okl_debug_pub.logmessage('Error occurred from okl_transaction_pvt.create_ppd_transaction');
     okl_debug_pub.logmessage('x_msg_data=' || x_msg_data);
   end if;
   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
   END IF;
   */

   --x_ppd_txn_id := l_tcnv_rec.id;
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_ppd_txn_id=' || p_ppd_txn_id);
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_chr_id=' || p_chr_id);
   END IF;


   OKL_MASS_REBOOK_PVT.apply_mass_rebook(
                              p_api_version        => p_api_version,
                              p_init_msg_list      => OKC_API.G_FALSE,
                              x_return_status      => x_return_status,
                              x_msg_count          => x_msg_count,
                              x_msg_data           => x_msg_data,
                              p_chr_id             => p_chr_id,
                              p_kle_tbl            => p_kle_tbl,
                              p_source_trx_id      => p_ppd_txn_id,
                              p_source_trx_type    => 'PPD',
                              p_transaction_date   => p_transaction_date,
                              x_mass_rebook_trx_id => l_mass_rebook_trx_id,
                              p_ppd_amount         => p_ppd_amount,
                              p_ppd_reason_code    => p_ppd_reason_code,
                              p_payment_struc      => p_payment_struc
                              --p_ppd_payment_struc  => p_ppd_payment_struc
                            );

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKLRPPNB:After apply_mass_rebook: x_return_status=' || x_return_status);
     END IF;
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when missing_parameters then
        x_return_status := OKL_API.G_RET_STS_ERROR;

        /* okl_debug_pub.logmessage('apply_ppd:x_msg_count=' || x_msg_count);
        IF (x_msg_count > 0 ) THEN
         FOR i in 1..x_msg_count
         LOOP
           FND_MSG_PUB.GET(
                           p_msg_index     => i,
                           p_encoded       => FND_API.G_FALSE,
                           p_data          => x_msg_data,
                           p_msg_index_out => l_msg_index_out
                          );

           okl_debug_pub.logmessage('l_msg_index_out='||l_msg_index_out);
           okl_debug_pub.logmessage('Error '||to_char(i)||': '||x_msg_data);
         END LOOP;
         END IF; */

        --fnd_msg_pub.Reset;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Missing Parameters...');
        END IF;
        raise;

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
END;

END OKL_PROCESS_PPD_PVT;

/
