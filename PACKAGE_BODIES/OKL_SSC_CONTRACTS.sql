--------------------------------------------------------
--  DDL for Package Body OKL_SSC_CONTRACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SSC_CONTRACTS" as
/* $Header: OKLSSCTB.pls 115.2 2003/05/21 11:06:06 arajagop noship $ */


procedure accept_asset ( headerId   in Number,
					   acceptance_date in Date )
IS

CURSOR acceptance_method IS
SELECT meaning from fnd_lookups
where lookup_type ='OKL_ACCEPTANCE_METHOD'
and lookup_code = 'SELF_SERVICE';

   l_api_version    NUMBER := 1.0;
   l_return_status  VARCHAR2(1);
   l_msg_count      NUMBER;
   l_msg_data       VARCHAR2(2000);
   l_chrv_rec       okl_okc_migration_pvt.chrv_rec_type;
   l_khrv_rec       okl_contract_pub.khrv_rec_type;
   lx_chrv_rec      okl_okc_migration_pvt.chrv_rec_type;
   lx_khrv_rec      okl_contract_pub.khrv_rec_type;
   l_msg_index_out  NUMBER;

   error_accepting_asset EXCEPTION;

begin
l_chrv_rec.id := headerId;
l_khrv_rec.id := l_chrv_rec.id;
l_khrv_rec.accepted_date := acceptance_date;


l_khrv_rec.AMD_CODE := 'SELF_SERVICE';


OKL_CONTRACT_PUB.update_contract_header(
    p_api_version       => l_api_version,
    p_init_msg_list     => OKL_API.G_FALSE,
    x_return_status     => l_return_status,
    x_msg_count         => l_msg_count,
    x_msg_data          => l_msg_data,
    p_restricted_update => OKL_API.G_FALSE,
    p_chrv_rec          => l_chrv_rec,
    p_khrv_rec          => l_khrv_rec,
    p_edit_mode         => 'N',
    x_chrv_rec          => lx_chrv_rec,
    x_khrv_rec          => lx_khrv_rec);

    IF l_return_status <> 'S' THEN
          RAISE error_accepting_asset;
      END IF;

end accept_asset;

END OKL_SSC_CONTRACTS;

/
