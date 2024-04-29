--------------------------------------------------------
--  DDL for Package Body OKL_CURE_CALC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CURE_CALC_PVT" AS
/* $Header: OKLRCURB.pls 120.9 2007/10/17 17:39:20 vdamerla noship $ */

---------------------------------------------------------------------------
-- PROCEDURE POPULATE_QTE_TABLE
-- This procedue populates the necessary PL/SQL table for quote
-- mandatory fields. It also populates the contract ID, quote type and
-- quote reason.
---------------------------------------------------------------------------
PROCEDURE populate_qte_rec( p_contract_id   IN NUMBER
                           ,p_quot_rec_type IN OUT NOCOPY okl_trx_quotes_pub.qtev_rec_type )
IS
cursor c_get_quote_type (p_contract_id IN NUMBER ) is
select  RULE_INFORMATION3
from okc_rules_b rul,
      okl_k_headers khr
where rul.dnz_chr_id =khr.khr_id
and khr.id =p_contract_id
and  RULE_INFORMATION_CATEGORY ='CORPUR';
l_type okl_trx_quotes_b.qtp_code%TYPE;

BEGIN

  okl_debug_pub.logmessage('populate_qte_rec : START ');

  p_quot_rec_type.khr_id                     := p_contract_id;

  -- QUOTE Type from vendor agreement
  -- cannot use okl_contract_info.get_rule value, since it returns
  -- the description for the quote type
  --09/17/03

  OPEN  c_get_quote_type (p_contract_id);
  FETCH c_get_quote_type INTO l_type;
  CLOSE c_get_quote_type;

  p_quot_rec_type.qtp_code := nvl(l_type,'TER_RECOURSE');


  p_quot_rec_type.qrs_code                   := 'RES_DELINQUENCY';
  p_quot_rec_type.comments                   := 'Requesting Repurchase Amount'||
                                                'From Collections for Vendor Cure Request';

  okl_debug_pub.logmessage('populate_qte_rec : l_type : '|| l_type);

  okl_debug_pub.logmessage('populate_qte_rec : END ');

END populate_qte_rec;

---------------------------------------------------------------------------
-- PROCEDURE POPULATE_ASSET_TABLE
-- Populate the asset PL/SQL table, this is required for getting the
-- quote amount for individual asset, the Repurhcase amount procedure
-- will add up the values for obtaining repurchase amount for the entire
-- contract.
---------------------------------------------------------------------------
PROCEDURE populate_asset_table(
       p_contract_id     IN NUMBER
       ,p_assn_tbl       IN OUT NOCOPY OKL_AM_CREATE_QUOTE_PUB.assn_tbl_type)
IS

  CURSOR asset_line_dur (p_contract_id IN NUMBER) IS
  --  SELECT asset_id, asset_number
  -- according to ravi M , we have to pass ID1 as the assest ID
  --also the line sts_code should be same as contract sts_code
  -- and should be from TOP lines
  --01/21/03
  SELECT kle.id kle_id, kle.name asset_number
  FROM okc_k_lines_v kle, okc_k_headers_v khr,
       OKC_LINE_STYLES_V LSE
  WHERE kle.chr_id = khr.id
  AND kle.lse_id = LSE.id
  AND lse.lty_code = 'FREE_FORM1' --This is the TOP LINE for Financial Assets
  AND khr.sts_code = kle.sts_code
  AND khr.id = p_contract_id;

l_counter Number :=1;
BEGIN

  okl_debug_pub.logmessage('populate_asset_table : START ');

  FOR i IN asset_line_dur (p_contract_id)
  LOOP
    p_assn_tbl(l_counter).p_asset_id      := i.kle_id;
    p_assn_tbl(l_counter).p_asset_number  := i.asset_number;
    l_counter :=l_counter + 1;

  END LOOP;

  okl_debug_pub.logmessage('populate_asset_table : END ');

END populate_asset_table;

PROCEDURE get_error_message(p_all_message
               OUT nocopy error_message_type)
  IS
    l_msg_text VARCHAR2(32627);
    l_msg_count NUMBER ;
  BEGIN
    l_msg_count := fnd_msg_pub.count_msg;
    FOR i IN 1..l_msg_count
	LOOP
      fnd_msg_pub.get
        (p_data => p_all_message(i),
        p_msg_index_out => l_msg_count,
	    p_encoded => fnd_api.g_false,
	    p_msg_index => fnd_msg_pub.g_next
        );
    END LOOP;
 EXCEPTION
    WHEN OTHERS THEN
	  NULL;
 END get_error_message;

 Procedure Update_cure_amounts(
                p_contract_id     IN NUMBER
               ,x_return_status  OUT NOCOPY VARCHAR2
               ,x_msg_count      OUT NOCOPY NUMBER
               ,x_msg_data       OUT NOCOPY VARCHAR2 ) IS

Cursor c_get_cure_amts (p_contract_id IN NUMBER) IS
Select cure_amount_id,object_version_number,negotiated_amount
from okl_cure_amounts
where chr_id =p_contract_id
and SHOW_ON_REQUEST ='Y';

-- while creating cure invoices, it should show only the details of a
--cure request, if a new contract is created, we should null out the crt id
--of the previous contract if negotiated amount is zero or null
--otherwise, okl_cure_invoices_uv will show all the contracts.

 l_camv_tbl                 OKL_cure_amounts_pub.camv_tbl_type;
 x_camv_tbl                 OKL_cure_amounts_pub.camv_tbl_type;
 l_msg_count                NUMBER;
 l_msg_data                 VARCHAR2(32627);
 l_return_status            VARCHAR2(1) :=FND_API.G_RET_STS_SUCCESS;
 next_row                   INTEGER;
 l_error_msg_tbl error_message_type;


-- ASHIM CHANGE - START



 /*cursor c_get_received_amounts (p_cure_amount_id IN NUMBER) is
 select sum(ara.amount_applied)
 from ar_payment_schedules ps1,
      okl_cnsld_ar_strms_b st1
     ,ar_receivable_applications ara
     ,okl_xtl_sell_invs_v  xls
     ,okl_txl_ar_inv_lns_v til
     ,okl_trx_ar_invoices_v tai
where st1.receivables_invoice_id = ps1.customer_trx_id
     and ara.applied_payment_schedule_id = ps1.payment_schedule_id
     and st1.id =xls.lsm_id
     and tai.id = til.tai_id
     and til.id = xls.til_id
     and tai.cpy_id =p_cure_amount_id
     and st1.khr_id =tai.khr_id;*/

 cursor c_get_received_amounts (p_cure_amount_id IN NUMBER) is
 select sum(ara.amount_applied)
 from ar_payment_schedules ps1,
      okl_bpd_tld_ar_lines_v st1
     ,ar_receivable_applications ara
     --,okl_xtl_sell_invs_v  xls
     ,okl_txl_ar_inv_lns_v til
     ,okl_trx_ar_invoices_v tai
where st1.customer_trx_id = ps1.customer_trx_id
     and ara.applied_payment_schedule_id = ps1.payment_schedule_id
     --and st1.id =xls.lsm_id
     and tai.id = til.tai_id
     --and til.id = xls.til_id
     and tai.cpy_id =p_cure_amount_id
     and st1.khr_id =tai.khr_id
     and st1.til_id_details = til.id
     and til.tai_id = tai.id;


-- ASHIM CHANGE - END


 BEGIN


         SAVEPOINT UPDATE_CURE_AMOUNTS;
         FND_MSG_PUB.initialize;
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Calling Cure Amount Update Api');

         okl_debug_pub.logmessage('Update_cure_amounts : START ');

        --update cure amounts table
         FOR i in c_get_cure_amts (p_contract_id)
         LOOP
             next_row := nvl(l_camv_tbl.LAST,0) +1;
             l_camv_tbl(next_row).cure_amount_id        :=i.cure_amount_id;
             l_camv_tbl(next_row).object_version_number :=i.object_version_number;
             l_camv_tbl(next_row).SHOW_ON_REQUEST :='N';
             OPEN c_get_received_amounts(i.cure_amount_id);
             FETCH c_get_received_amounts INTO
                    l_camv_tbl(next_row).received_amount;
                   write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'cure_amount id '||i.cure_amount_id ||
                  'recevied_amount '||l_camv_tbl(next_row).received_amount);

               okl_debug_pub.logmessage('Update_cure_amounts : i.cure_amount_id '|| i.cure_amount_id);
               okl_debug_pub.logmessage('Update_cure_amounts : l_camv_tbl(next_row).received_amount '|| l_camv_tbl(next_row).received_amount);
             CLOSE c_get_received_amounts;

             --commented out on 09/23 , requested by pdeveraj
            /* If nvl(i.negotiated_amount,0) = 0 THEN
                l_camv_tbl(next_row).crt_id :=NULL;
             END if;
            */

         END LOOP;

         write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'no of records to be updated in Cure amounts '||
                   l_camv_tbl.COUNT);
        IF l_camv_tbl.COUNT > 0 THEN
           OKL_cure_amounts_pub.update_cure_amounts
                         (  p_api_version    => 1
                           ,p_init_msg_list  => 'T'
                           ,x_return_status  => l_return_status
                           ,x_msg_count      => l_msg_count
                           ,x_msg_data       => l_msg_data
                           ,p_camv_tbl       => l_camv_tbl
                           ,x_camv_tbl       => x_camv_tbl
                         );

         okl_debug_pub.logmessage('Update_cure_amounts : OKL_cure_amounts_pub.update_cure_amounts : '||l_return_status);

          IF (l_return_status  <> FND_Api.G_RET_STS_SUCCESS ) THEN
             RAISE Fnd_Api.G_EXC_ERROR;
          ELSE
             write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM,
               'Updation of cure amounts is Successful');
         END IF;
         x_return_status  := l_return_status;
         FND_MSG_PUB.Count_And_Get ( p_count =>   x_msg_count,
                                     p_data   =>   x_msg_data );
      END IF;

      okl_debug_pub.logmessage('Update_cure_amounts : END ');

EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_CURE_AMOUNTS;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_CURE_AMOUNTS;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO UPDATE_CURE_AMOUNTS;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CURE_CALC_PVT','UPDATE_CURE_AMOUNTS');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);


End update_cure_amounts;



  ---------------------------------------------------------------------------
  -- PROCEDURE GET_REPURCHASE_AMT
  ---------------------------------------------------------------------------
  PROCEDURE GET_REPURCHASE_AMT(
	 p_contract_id	       IN NUMBER
	 ,x_repurchase_amt       OUT NOCOPY NUMBER
	 ,x_return_status        OUT NOCOPY VARCHAR2
	 ,x_msg_count            OUT NOCOPY NUMBER
	 ,x_msg_data             OUT NOCOPY VARCHAR2
     ,x_qte_id               OUT NOCOPY NUMBER )
  IS

  l_repurchase_amount		NUMBER;
  l_api_version               CONSTANT NUMBER := 1;
  l_api_name                  CONSTANT VARCHAR2(30) := 'OKL_CURE_CALC_PVT';
  l_return_status             VARCHAR2(1) := fnd_api.G_RET_STS_SUCCESS;

  l_quot_rec              OKL_AM_CREATE_QUOTE_PUB.quot_rec_type;
  l_assn_tbl		      OKL_AM_CREATE_QUOTE_PUB.assn_tbl_type;
  l_qpyv_tbl              OKL_AM_CREATE_QUOTE_Pub.qpyv_tbl_type;


  l_qtev_rec OKL_AM_PARTIES_PVT.qtev_rec_type;
  x_q_party_uv_tbl OKL_AM_PARTIES_PVT.q_party_uv_tbl_type;
  l_record_count NUMBER;


  x_quot_rec              OKL_AM_CREATE_QUOTE_PUB.quot_rec_type;
  x_tqlv_tbl		      OKL_AM_CREATE_QUOTE_PUB.tqlv_tbl_type;
  x_assn_tbl	          OKL_AM_CREATE_QUOTE_PUB.assn_tbl_type;

  l_counter 			NUMBER := 1;
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(32627);
  l_error_msg_tbl error_message_type;
  l_msg_index_out number;

  l_cpl_id    NUMBER;
  l_qtp_code  okl_trx_quotes_b.qtp_code%TYPE;

   Cursor c_get_cpl_id(p_contract_id IN NUMBER) is
    SELECT  party.id
      FROM okl_am_k_party_roles_uv party,
           okl_k_headers khr
      WHERE party.dnz_chr_id =khr.khr_id
      and khr.id=p_contract_id
      AND party.rle_code = 'OKL_VENDOR';

/*
REVERTING back to the previous correct query
Performance issue will be addressed later

--Updated the cursor sql statement for performance issue - bug#5484903
   Cursor c_get_cpl_id(p_contract_id IN NUMBER) is
   select CPLB.ID id
   FROM OKC_K_PARTY_ROLES_B CPLB
   where CPLB.DNZ_CHR_ID=p_contract_id
   and CPLB.RLE_CODE= 'OKL_VENDOR';
*/

  BEGIN

       SAVEPOINT GET_REPURCHASE_AMT;

       okl_debug_pub.logmessage('GET_REPURCHASE_AMT : START ');

       populate_qte_rec( p_contract_id
                        ,l_quot_rec );

       populate_asset_table( p_contract_id
                         ,l_assn_tbl );


 -- Populate receipent table
/*    l_qtev_rec.KHR_ID :=p_contract_id;
    l_qtev_rec.QTP_CODE :=l_quot_rec.qtp_code;


  OKL_AM_PARTIES_PVT.fetch_rule_quote_parties
                                (p_api_version =>1.0
                                 ,p_init_msg_list  =>FND_API.G_TRUE
                                 ,x_return_status  =>l_return_status
                                 ,x_msg_count      =>l_msg_count
                                 ,x_msg_data       =>l_msg_data
                             	 ,p_qtev_rec	   =>L_qtev_rec
	                             ,x_qpyv_tbl	   =>l_qpyv_tbl
                             	,x_q_party_uv_tbl  =>x_q_party_uv_tbl
                             	,x_record_count	   =>l_record_count
                                );

*/

      OPEN c_get_cpl_id (p_contract_id);
      FETCH c_get_cpl_id INTO l_cpl_id;
      CLOSE c_get_cpl_id;

      l_qpyv_tbl(1).cpl_id   := l_cpl_id;
      l_qpyv_tbl(1).qpt_code := 'RECIPIENT';


      write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CPL ID' ||  l_cpl_id );

      okl_debug_pub.logmessage('GET_REPURCHASE_AMT : l_cpl_id : '|| l_cpl_id);

      -- Call the Asset Management Quote Creation API to get
      -- Repurchase amount for the contract

      OKL_AM_CREATE_QUOTE_PUB.create_terminate_quote(
					 p_api_version 	=> 1.0
			   	     ,p_init_msg_list  => 'T'
			    	 ,x_return_status  => l_return_status
					,x_msg_count      => l_msg_count
					,x_msg_data       => l_msg_data
					,p_quot_rec       => l_quot_rec
					,p_assn_tbl		  => l_assn_tbl
                   ,p_qpyv_tbl		  => l_qpyv_tbl
					,x_quot_rec       => x_quot_rec
					,x_tqlv_tbl		=> x_tqlv_tbl
					,x_assn_tbl		=> x_assn_tbl);

    okl_debug_pub.logmessage('GET_REPURCHASE_AMT : OKL_AM_CREATE_QUOTE_PUB.create_terminate_quote : '|| l_return_status);

    if l_return_status <> FND_Api.G_RET_STS_SUCCESS THEN
       fnd_msg_pub.get (p_msg_index => 1,
                      p_encoded => 'F',
                      p_data => l_msg_data,
                      p_msg_index_out => l_msg_index_out);
       write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH,'error after calling create terminate quote '||
                        ' is ' || l_msg_data);
       RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    l_repurchase_amount := 0;
    FOR i in x_tqlv_tbl.FIRST..x_tqlv_tbl.LAST LOOP
        l_repurchase_amount := l_repurchase_amount + x_tqlv_tbl(i).amount;
    END LOOP;

   -- get quote id
   --09/17/2003

    x_qte_id :=x_quot_rec.id;
    x_repurchase_amt := l_repurchase_amount;
    x_return_status  := l_return_status;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;


    write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Repurchase Amount is '
                      ||l_repurchase_amount
                      || 'and Quote id is '||x_qte_id);



      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
       okl_debug_pub.logmessage('GET_REPURCHASE_AMT : l_repurchase_amount : '|| l_repurchase_amount);
       okl_debug_pub.logmessage('GET_REPURCHASE_AMT : END ');

    EXCEPTION
      WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO GET_REPURCHASE_AMT;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO GET_REPURCHASE_AMT;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CURE_CALC_PVT','GET_REPURCHASE_AMT');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END GET_REPURCHASE_AMT;

  ---------------------------------------------------------------------------
  -- FUNCTION GET_CURE_AMT
  -- This function calculates and returns the cure amount for a contract
  -- It accepts contract ID and cure type as parameters
  -- cure types may be FULL or INTEREST.
  -- currently the formula for FULL CURE is:
  -- (net rent past due excluding current months due and any cures received
  -- thus far for the contract)
  -- The formula for INTEREST CURE is:
  -- (net investment * contract rate)/12 * no of months requiring cures
  ---------------------------------------------------------------------------
PROCEDURE    GET_CURE_AMT( p_contract_id    IN  NUMBER
                          ,p_program_id     IN  NUMBER
                          ,p_cure_type	    IN  VARCHAR2
                          ,x_cure_amount    OUT NOCOPY NUMBER
                          ,x_return_status  OUT NOCOPY VARCHAR2
                          ,x_msg_count      OUT NOCOPY NUMBER
                          ,x_msg_data       OUT NOCOPY VARCHAR2 )

IS

  l_current_due_amount          NUMBER := 0;
  l_days_past_due               NUMBER;
  l_current_due_date            DATE;
  l_contract_rate               NUMBER;
  l_months_requiring_cure       NUMBER := 0;
  l_net_investment              NUMBER := 0;
  l_return_status               VARCHAR2(1) := FND_Api.G_RET_STS_SUCCESS;
  l_last_due_date               DATE;
  l_sysdate                     DATE := TRUNC(SYSDATE);
  l_id1                         VARCHAR2(40);
  l_id2                         VARCHAR2(200);
  l_rule_value                  VARCHAR2(2000);

 cursor c_cures_in_possession (p_contract_id IN NUMBER ) IS
 select refund_amount_due
 from okl_cure_refunds_dtls_uv
 where contract_id =p_contract_id;

  l_contract_number okc_k_headers_b.contract_number%TYPE;


-- ASHIM CHANGE - START


  /*CURSOR c_amount_past_due(p_contract_id IN NUMBER,
                           p_grace_days  IN NUMBER) IS
    SELECT SUM(NVL(aps.amount_due_remaining, 0)) past_due_amount
    FROM   okl_cnsld_ar_strms_b ocas
           ,ar_payment_schedules aps
    WHERE  ocas.khr_id = p_contract_id
    AND    ocas.receivables_invoice_id = aps.customer_trx_id
    AND    aps.class ='INV'
    AND    (aps.due_date + p_grace_days) < sysdate
    AND    NVL(aps.amount_due_remaining, 0) > 0
    and not exists
          (select xls1.lsm_id from
              okl_xtl_sell_invs_v xls1
              ,okl_txl_ar_inv_lns_v til1
              ,okl_trx_ar_invoices_v tai1 where
              tai1.id = til1.tai_id and
              til1.id = xls1.til_id and
              tai1.cpy_id IS NOT NULL and
              xls1.lsm_id =ocas.id
           ); */

  CURSOR c_amount_past_due(p_contract_id IN NUMBER,
                           p_grace_days  IN NUMBER) IS
    SELECT SUM(NVL(aps.amount_due_remaining, 0)) past_due_amount
    FROM   okl_bpd_tld_ar_lines_v ocas
           ,ar_payment_schedules aps
    WHERE  ocas.khr_id = p_contract_id
    AND    ocas.customer_trx_id = aps.customer_trx_id
    AND    aps.class ='INV'
    AND    (aps.due_date + p_grace_days) < sysdate
    AND    NVL(aps.amount_due_remaining, 0) > 0
    and not exists
          (select tld.id from
              --okl_xtl_sell_invs_v xls1
               okl_txd_ar_ln_dtls_b tld
              ,okl_txl_ar_inv_lns_v til1
              ,okl_trx_ar_invoices_v tai1 where
              tai1.id = til1.tai_id and
              --til1.id = xls1.til_id and
              til1.id = tld.til_id_details and
              tai1.cpy_id IS NOT NULL and
              --xls1.lsm_id =ocas.id
              tld.id =ocas.tld_id
           );


-- ASHIM CHANGE - END



  l_cures_in_possession  NUMBER := 0;
  l_amount_past_due      NUMBER   :=0;
  l_days_allowed         NUMBER   :=0;

  BEGIN

    -- Process Full Cure Payment
    write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
     'Getting cure amounts' || ' and cure_type is ' ||p_cure_type);

    okl_debug_pub.logmessage('GET_CURE_AMT : START ');

    IF (p_cure_type = 'Full Cure') THEN
      -- Get Contract allowed value for days past due from rules
      l_return_status := okl_contract_info.get_rule_value(
                              p_contract_id     => p_program_id
                             ,p_rule_group_code => 'COCURP'
                             ,p_rule_code		=> 'COCURE'
                             ,p_segment_number	=> 3
                             ,x_id1             => l_id1
                             ,x_id2             => l_id2
                             ,x_value           => l_rule_value);

     okl_debug_pub.logmessage('GET_CURE_AMT : okl_contract_info.get_rule_value : '||l_return_status);

      IF l_return_status =FND_Api.G_RET_STS_SUCCESS THEN
        l_days_allowed :=nvl(l_rule_value,0);
        write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                 'l_days allowed for days past due ' || l_days_allowed);
      END IF;

      okl_debug_pub.logmessage('GET_CURE_AMT : l_days_allowed : '||l_days_allowed);

      -- Get Past Due Amount
      OPEN  c_amount_past_due (p_contract_id,l_days_allowed);
      FETCH c_amount_past_due INTO l_amount_past_due;
      CLOSE c_amount_past_due;

      okl_debug_pub.logmessage('GET_CURE_AMT : l_amount_past_due : '||l_amount_past_due);

      -- cures in possession
      OPEN  c_cures_in_possession (p_contract_id);
      FETCH c_cures_in_possession INTO l_cures_in_possession;
      CLOSE c_cures_in_possession;
      x_cure_amount :=nvl(l_amount_past_due,0)-nvl(l_cures_in_possession,0);

    ELSIF  (p_cure_type = 'Interest Cure') THEN
      x_cure_amount := OKL_seeded_functions_pvt.contract_interest_cure (p_contract_id);
    END IF;

    okl_debug_pub.logmessage('GET_CURE_AMT : x_cure_amount : '||x_cure_amount);
    okl_debug_pub.logmessage('GET_CURE_AMT : END ');

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CURE_CALC_PVT','GET_CURE_AMT');
    Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count
                              ,p_data    => x_msg_data);
END GET_CURE_AMT;


Procedure Calculate_CAM_COLUMNS ( p_contract_id IN NUMBER,
                                  p_program_id  IN NUMBER,
                                  x_cures_in_possession OUT NOCOPY NUMBER,
                                  x_effective_date      OUT NOCOPY DATE,
                                  x_payments_remaining  OUT NOCOPY NUMBER,
                                  x_outstanding_amount  OUT NOCOPY NUMBER,
                                  x_delinquent_amount   OUT NOCOPY NUMBER)IS


 cursor c_cures_in_possession (p_contract_id IN NUMBER ) IS
  select refund_amount_due
  from okl_cure_refunds_dtls_uv
  where contract_id =p_contract_id;


-- ASHIM CHANGE - START


  /*CURSOR c_amount_past_due(p_contract_id IN NUMBER,
                           p_grace_days  IN NUMBER) IS
    SELECT SUM(NVL(aps.amount_due_remaining, 0)) past_due_amount
    FROM   okl_cnsld_ar_strms_b ocas
           ,ar_payment_schedules aps
    WHERE  ocas.khr_id = p_contract_id
    AND    ocas.receivables_invoice_id = aps.customer_trx_id
    AND    aps.class ='INV'
    AND    (aps.due_date + p_grace_days) < sysdate
    AND    NVL(aps.amount_due_remaining, 0) > 0
    and not exists
          (select xls1.lsm_id from
              okl_xtl_sell_invs_v xls1
              ,okl_txl_ar_inv_lns_v til1
              ,okl_trx_ar_invoices_v tai1 where
              tai1.id = til1.tai_id and
              til1.id = xls1.til_id and
              tai1.cpy_id IS NOT NULL and
              xls1.lsm_id =ocas.id
           ); */

  CURSOR c_amount_past_due(p_contract_id IN NUMBER,
                           p_grace_days  IN NUMBER) IS
    SELECT SUM(NVL(aps.amount_due_remaining, 0)) past_due_amount
    FROM   okl_bpd_tld_ar_lines_v ocas
           ,ar_payment_schedules aps
    WHERE  ocas.khr_id = p_contract_id
    AND    ocas.customer_trx_id = aps.customer_trx_id
    AND    aps.class ='INV'
    AND    (aps.due_date + p_grace_days) < sysdate
    AND    NVL(aps.amount_due_remaining, 0) > 0
    and not exists
          (select tld.id from
              okl_txd_ar_ln_dtls_b tld
              ,okl_txl_ar_inv_lns_v til1
              ,okl_trx_ar_invoices_v tai1 where
              tai1.id = til1.tai_id and
              til1.id = tld.til_id_details and
              tai1.cpy_id IS NOT NULL and
              tld.id =ocas.tld_id
           );


-- ASHIM CHANGE - END


  l_contract_number okc_k_headers_b.contract_number%TYPE;
  l_rule_name     VARCHAR2(200);
  l_rule_value    VARCHAR2(2000);
  l_return_Status VARCHAR2(1):=FND_Api.G_RET_STS_SUCCESS;
  l_id1           VARCHAR2(40);
  l_id2           VARCHAR2(200);
  l_days_allowed  NUMBER :=0;

BEGIN

      ----------------------------------------------------------
      -- Get Effective Date for the Vendor Program
      -- Used to caculate the Cure Amount
      ----------------------------------------------------------

/*       l_rule_value :=NULL;
       l_return_status := okl_contract_info.get_rule_value(
                            p_contract_id     => p_program_id
                           ,p_rule_group_code => 'COCURP'
                           ,p_rule_code		  => 'COCURE'
                           ,p_segment_number  => 5
                           ,x_id1             => l_id1
                           ,x_id2             => l_id2
                           ,x_value           => l_rule_value );


       IF l_rule_value is NOT NULL  THEN
          x_effective_date := to_date(l_rule_value ||
                  to_char(SYSDATE,'-MM-RRRR'),'DD-MM-RRRR');
       ELSE
           x_effective_date := last_day(sysdate);
       END IF;
     */

       x_effective_date :=SYSDATE;

       write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, ' Effective Day ' ||
                       ' is ' ||x_effective_date );

       okl_debug_pub.logmessage('Calculate_CAM_COLUMNS : START ');

       -- Get remaining payments
        l_return_status := okl_contract_info.get_remaining_payments
                                             (  p_contract_id
                                               ,x_payments_remaining );

       okl_debug_pub.logmessage('Calculate_CAM_COLUMNS : okl_contract_info.get_remaining_payments : '||l_return_status);

       IF (l_return_status  <> FND_Api.G_RET_STS_SUCCESS ) THEN
           x_payments_remaining :=0;
      END IF;
      write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Remaining_payments is '
                                               ||x_payments_remaining);

     -- cures in possession
     OPEN  c_cures_in_possession (p_contract_id);
     FETCH c_cures_in_possession INTO x_cures_in_possession;
     CLOSE c_cures_in_possession;

     write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Cures in possession is '
                                                ||x_cures_in_possession);

     okl_debug_pub.logmessage('Calculate_CAM_COLUMNS : x_cures_in_possession : '||x_cures_in_possession);

     l_return_status := okl_contract_info.get_rule_value(
                              p_contract_id     => p_program_id
                             ,p_rule_group_code => 'COCURP'
                             ,p_rule_code		=> 'COCURE'
                             ,p_segment_number	=> 3
                             ,x_id1             => l_id1
                             ,x_id2             => l_id2
                             ,x_value           => l_rule_value);

     IF l_return_status =FND_Api.G_RET_STS_SUCCESS THEN
         l_days_allowed :=nvl(l_rule_value,0);
         write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                 'days allowed for days past due ' || l_days_allowed);
    END IF;

    okl_debug_pub.logmessage('Calculate_CAM_COLUMNS : l_days_allowed : '||l_days_allowed);

        -- Get Past Due Amount
    OPEN  c_amount_past_due (p_contract_id,0);
    FETCH c_amount_past_due INTO x_outstanding_amount;
    CLOSE c_amount_past_due;

    okl_debug_pub.logmessage('Calculate_CAM_COLUMNS : x_outstanding_amount : '||x_outstanding_amount);

    -- Get Past Due Amount with maximium days allowed
    OPEN  c_amount_past_due (p_contract_id,l_days_allowed);
    FETCH c_amount_past_due INTO x_delinquent_amount;
    CLOSE c_amount_past_due;

    write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Amount past due '
                                  || ' is ' ||x_outstanding_amount);

    write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Amount past due with maximum day allowed'
                                  || ' is ' ||x_delinquent_amount);
    okl_debug_pub.logmessage('Calculate_CAM_COLUMNS : x_delinquent_amount : '||x_delinquent_amount);
    okl_debug_pub.logmessage('Calculate_CAM_COLUMNS : END ');

END Calculate_CAM_COLUMNS;



---------------------------------------------------------------------------
-- PROCEDURE CALC_CURE_REPURCHASE
---------------------------------------------------------------------------
PROCEDURE CALC_CURE_REPURCHASE(
  p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT FND_api.G_FALSE,
  p_contract_id			      IN NUMBER,
  p_contract_number           IN VARCHAR2,
  p_program_id                IN NUMBER,
  p_rule_group_code           IN VARCHAR2,
  p_cure_calc_flag            IN VARCHAR2,
  p_process                   IN VARCHAR2,
  x_repurchase_amount         OUT NOCOPY NUMBER,
  x_cure_amount               OUT NOCOPY NUMBER,
  x_return_status             OUT NOCOPY VARCHAR2,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2
)
IS


  l_return_status             VARCHAR2(1)  := FND_Api.G_RET_STS_SUCCESS;
  l_repurchase_amount         NUMBER := 0;
  l_cure_amount               NUMBER := 0;
  l_payments_remaining        NUMBER := 0;
  l_effective_date            DATE;
  l_negotiated_amount         NUMBER := 0;
  l_outstanding_amount        NUMBER := 0;
  l_delinquent_amount         NUMBER := 0;
  l_cures_in_possession       NUMBER := 0;
  l_camv_rec                 OKL_cure_amounts_pub.camv_rec_type;
  x_camv_rec                 OKL_cure_amounts_pub.camv_rec_type;
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(32627);
  l_error_msg_tbl error_message_type;

  Cursor c_get_negoiated_amt (p_contract_id IN NUMBER) is
  select nvl(sum(negotiated_amount),0)+ nvl(sum(short_fund_amount),0)
  from  okl_cure_amounts
  where chr_id =p_contract_id
  and   status ='CURESINPROGRESS';

  --dkagrawa added following cursor to get the org_id MOAC Issue
  CURSOR c_get_org_id (p_contract_id IN NUMBER) IS
  SELECT org_id
  FROM okc_k_headers_b
  WHERE id = p_contract_id;

  l_qte_id okl_cure_amounts.qte_id%TYPE;

BEGIN

      SAVEPOINT CALC_CURE_REPURCHASE;

      okl_debug_pub.logmessage('CALC_CURE_REPURCHASE : START ');
      okl_debug_pub.logmessage('CALC_CURE_REPURCHASE : p_cure_calc_flag : '||p_cure_calc_flag);
      okl_debug_pub.logmessage('CALC_CURE_REPURCHASE : p_process : '||p_process);

      write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Calc repurchase started for ' || p_contract_number);

      Calculate_CAM_COLUMNS ( p_contract_id       =>p_contract_id,
                            p_program_id          =>p_program_id,
                            x_effective_date      =>l_effective_date,
                            x_payments_remaining  =>l_payments_remaining,
                            x_cures_in_possession =>l_cures_in_possession,
                            x_outstanding_amount  =>l_outstanding_amount,
                            x_delinquent_amount   =>l_delinquent_amount);

     SELECT DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, Fnd_Global.CONC_REQUEST_ID),
          DECODE(Fnd_Global.PROG_APPL_ID, -1, NULL, Fnd_Global.PROG_APPL_ID),
          DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL, Fnd_Global.CONC_PROGRAM_ID),
          DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, SYSDATE)
    INTO l_camv_rec.request_id,
         l_camv_rec.program_application_id,
         l_camv_rec.program_id,
         l_camv_rec.program_update_date
    FROM DUAL;


   --09/26
   -- calculate both cure
   -- and repurchase

   IF p_process IN ( 'BOTH', 'REPURCHASE') THEN
       -- Get Repurchase Amount
       GET_REPURCHASE_AMT( p_contract_id	=> p_contract_id,
 	                       x_repurchase_amt => l_repurchase_amount,
                   	       x_return_status  => l_return_status,
                   	       x_msg_count      => l_msg_count,
                   	       x_msg_data       => l_msg_data
                          ,x_qte_id         => l_qte_id );

      okl_debug_pub.logmessage('CALC_CURE_REPURCHASE : GET_REPURCHASE_AMT : '||l_return_status);

      IF (l_return_status  <> FND_Api.G_RET_STS_SUCCESS ) THEN
          RAISE Fnd_Api.G_EXC_ERROR;
      ELSE
           x_repurchase_amount :=l_repurchase_amount;
      END IF;

      write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Repurchase  amount Is '
                    ||l_repurchase_amount);

      okl_debug_pub.logmessage('CALC_CURE_REPURCHASE : GET_REPURCHASE_AMT : l_repurchase_amount : '||l_repurchase_amount);

    END IF;

    IF p_process IN ('CURE','BOTH') AND p_cure_calc_flag = 'Interest Cure' THEN
        l_cure_amount := OKL_seeded_functions_pvt.contract_interest_cure(p_contract_id);
        x_cure_amount := l_cure_amount;

        write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Interest Cure Amount Is '
                      ||l_cure_amount);

        okl_debug_pub.logmessage('CALC_CURE_REPURCHASE : Interest Cure Amount : '||l_cure_amount);

    END IF;

    IF p_process IN('CURE','BOTH') AND p_cure_calc_flag = 'Full Cure' THEN
         -- for full cure
         --formula is Delinquent_amount -Sum (negotiated_Amount) + Short_Fund_amount)
         -- for records from cure amounts where chr_id =p_contract_id
         -- and status ='CURESINPROGRESS''
            Okl_Execute_Formula_Pub.EXECUTE(p_api_version =>1.0
                                 ,p_init_msg_list       =>p_init_msg_list
                                 ,x_return_status       =>l_return_status
                                 ,x_msg_count           =>l_msg_count
                                 ,x_msg_data            =>l_msg_data
                                 ,p_formula_name        => 'CONTRACT_FULL_CURE_AMOUNT'
                                ,p_contract_id          => p_contract_id
                                ,x_value                => l_cure_amount
                                );

          okl_debug_pub.logmessage('CALC_CURE_REPURCHASE : Okl_Execute_Formula_Pub : '||l_return_status);

         IF (l_return_status  <> FND_Api.G_RET_STS_SUCCESS ) THEN
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
         x_cure_amount := l_cure_amount;  -- Bug 6487958

        write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Cure Amount Is '
                      ||l_cure_amount);

        okl_debug_pub.logmessage('CALC_CURE_REPURCHASE : Full Cure : l_cure_amount : '||l_cure_amount);

  END IF; -- p_process ='CURE'


  -- Populate the data in OKL_cure_amounts entity for the contract.
  l_camv_rec.chr_id                := p_contract_id;

  IF p_process <> 'BOTH' THEN
    l_camv_rec.cure_type             := p_Process;
  END IF;
  l_camv_rec.cure_type             :=p_cure_calc_flag;
  l_camv_rec.cure_amount           := l_cure_amount;
  l_camv_rec.repurchase_amount     := l_repurchase_amount;
  l_camv_rec.effective_date        := l_effective_date;
  l_camv_rec.cures_in_possession   := l_cures_in_possession;
  l_camv_rec.status                := 'CURESINPROGRESS';
  l_camv_rec.object_version_number := 1.0;
  l_camv_rec.show_on_request       := 'Y';
  l_camv_rec.selected_on_request   := 'Y';
  --this is the lessee invoice amount
  --past due amount <sysdate
   l_camv_rec.outstanding_amount    := l_outstanding_amount;
  --this is the delinquent amount after maximium due days allowed
   l_camv_rec.delinquent_amount  := l_delinquent_amount;
   l_camv_rec.qte_id             :=l_qte_id;
   --dkagrawa added following for MOAC Issue
   OPEN c_get_org_id(p_contract_id);
   FETCH c_get_org_id INTO l_camv_rec.org_id;
   CLOSE c_get_org_id;

   write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Before updating Cure Amounts');
--   IF (l_negotiated_amount > 0)  THEN


     IF (l_cure_amount > 0 or l_repurchase_amount > 0) THEN
       -- Update SHOW_ON_REQUEST to 'N' FOR previous contracts.
           Update_cure_amounts(
                                 p_contract_id    =>p_contract_id,
                                 x_return_status  =>l_return_status,
                                 x_msg_count      =>l_msg_count,
                                 x_msg_data       =>l_msg_data );

           okl_debug_pub.logmessage('CALC_CURE_REPURCHASE : Update_cure_amounts : '||l_return_status);

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW ,
                     'Error Updating Cure amounts Table for contract '
                      || p_contract_number );
                GET_ERROR_MESSAGE(l_error_msg_tbl);
                IF (l_error_msg_tbl.COUNT > 0) THEN
                   FOR i IN l_error_msg_tbl.FIRST..l_error_msg_tbl.LAST
                   LOOP
                       write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH,
                                   l_error_msg_tbl(i));
                   END LOOP;
               END IF; --end of l_error_msg_tbl
            END IF; --  update_cure_amounts
 --   END IF; --negotiated _amount;

     write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Before Inserting Cure Amounts');

     -- Populate null for repurchase amount and cure amount if =0
     --requested by pdevaraj for UI purposes
     --09/17/2003
       IF l_cure_amount = 0 THEN
          l_camv_rec.cure_amount :=NULL;
       ELSIF l_camv_rec.repurchase_amount =0 THEN
          l_camv_rec.repurchase_amount :=NULL;
       END IF;

       OKL_cure_amounts_pub.insert_cure_amounts
                         (
                            p_api_version    => p_api_version
                           ,p_init_msg_list  => p_init_msg_list
                           ,x_return_status  => l_return_status
                           ,x_msg_count      => l_msg_count
                           ,x_msg_data       => l_msg_data
                           ,p_camv_rec       => l_camv_rec
                           ,x_camv_rec       => x_camv_rec
                         );

       okl_debug_pub.logmessage('CALC_CURE_REPURCHASE : OKL_cure_amounts_pub.insert_cure_amounts : '||l_return_status);

        IF (l_return_status  <> FND_Api.G_RET_STS_SUCCESS ) THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        ELSE
              write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM,
              ' Cure amount  is '||x_cure_amount ||
              ' Repurchase Amount is '||x_repurchase_amount);
        END IF;
  ELSE
       write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM,
          ' Cure amount or repurchase amount= 0 , so cure amount record is not created');
  END IF;


  x_return_status  := l_return_status;
  FND_MSG_PUB.Count_And_Get ( p_count =>   x_msg_count,
                             p_data   =>   x_msg_data );

  okl_debug_pub.logmessage('CALC_CURE_REPURCHASE : END ');

EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO CALC_CURE_REPURCHASE;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CALC_CURE_REPURCHASE;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO CALC_CURE_REPURCHASE;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CURE_CALC_PVT','CALC_CURE_REPURCHASE');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END CALC_CURE_REPURCHASE ;

PROCEDURE POPULATE_LOG_TBL(
                   p_contract_number IN VARCHAR2,
                   p_cure_flag       IN VARCHAR2,
                   p_cure_amount     IN NUMBER,
                   P_type            IN VARCHAR2) IS

BEGIN

      If p_type = 'ERROR' THEN
         l_error_idx := nvl(l_error_tbl.LAST,0) + 1;
         l_error_tbl(l_error_idx).contract_number :=p_contract_number;
         l_error_tbl(l_error_idx).cure_type   :=p_cure_flag;
         l_error_tbl(l_error_idx).cure_amount := p_cure_amount;
      ELSE
          l_success_idx := nvl(l_success_tbl.LAST,0) + 1;
          l_success_tbl(l_success_idx).contract_number :=p_contract_number;
          l_success_tbl(l_success_idx).cure_type   :=p_cure_flag;
          l_success_tbl(l_success_idx).cure_amount := p_cure_amount;
      END IF;


END POPULATE_LOG_TBL;

PROCEDURE write_log(mesg_level IN NUMBER, mesg IN VARCHAR2) is
BEGIN
     if (mesg_level >= l_msgLevel) then
        fnd_file.put_line(FND_FILE.LOG, mesg);
    end if;


END;

Procedure print_log
                (p_contract_number VARCHAR2) IS
BEGIN

          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'OKL Generate Cure Amounts');
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Program Run Date:'||SYSDATE);
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'PARAMETERS');
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Contract Number = ' ||p_contract_number);
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');

       IF l_success_tbl.COUNT > 0 THEN
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Cure Amounts Generated for '||
                                                l_success_tbl.COUNT || ' Contracts ');
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');
          FOR i in l_success_tbl.FIRST..l_success_tbl.LAST LOOP
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT ,'Contract Number ' ||
                  l_success_tbl(i).contract_number  || ' Cure Type is '||
                  l_success_tbl(i).cure_type        || ' Cure Amount '||
                  l_success_tbl(i).cure_amount       );
          END LOOP;
        END IF;

        IF l_error_tbl.COUNT > 0 THEN
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Cure Amounts Not Generated For '||
                                                 l_error_tbl.COUNT || ' Contracts ');
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');
          FOR i in l_error_tbl.FIRST..l_error_tbl.LAST LOOP
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT ,'  Contract Number  ' ||
                  l_error_tbl(i).contract_number  );

          END LOOP;
       END IF;

END print_log;

PROCEDURE check_contract(p_contract_id       IN NUMBER
                         ,p_program_id       IN NUMBER
                         ,p_contract_number  IN VARCHAR2
                        ,x_return_status     OUT NOCOPY VARCHAR2) IS


l_id1                  VARCHAR2(40);
l_id2                  VARCHAR2(200);
l_rule_value           VARCHAR2(2000);
l_days_allowed         NUMBER   :=0;
l_return_status VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;



-- ASHIM CHANGE - START


/*CURSOR c_amount_past_due(p_contract_id IN NUMBER,
                         p_grace_days  IN NUMBER) IS
    SELECT SUM(NVL(aps.amount_due_remaining, 0)) past_due_amount
    FROM   okl_cnsld_ar_strms_b ocas
          ,ar_payment_schedules aps
    WHERE  ocas.khr_id = p_contract_id
    AND    ocas.receivables_invoice_id = aps.customer_trx_id
    AND    aps.class ='INV'
    AND    (aps.due_date + p_grace_days) < sysdate
    AND    NVL(aps.amount_due_remaining, 0) > 0
    AND  not exists
          (select xls1.lsm_id from
              okl_xtl_sell_invs_v xls1
              ,okl_txl_ar_inv_lns_v til1
              ,okl_trx_ar_invoices_v tai1 where
              tai1.id = til1.tai_id and
              til1.id = xls1.til_id and
              tai1.cpy_id IS NOT NULL and
              xls1.lsm_id =ocas.id);*/


CURSOR c_amount_past_due(p_contract_id IN NUMBER,
                         p_grace_days  IN NUMBER) IS
    SELECT SUM(NVL(aps.amount_due_remaining, 0)) past_due_amount
    FROM   okl_bpd_tld_ar_lines_v ocas
          ,ar_payment_schedules aps
    WHERE  ocas.khr_id = p_contract_id
    AND    ocas.customer_trx_id = aps.customer_trx_id
    AND    aps.class ='INV'
    AND    (aps.due_date + p_grace_days) < sysdate
    AND    NVL(aps.amount_due_remaining, 0) > 0
    AND  not exists
          --(select xls1.lsm_id from
          (select tld.id from
              --okl_xtl_sell_invs_v xls1
              okl_txd_ar_ln_dtls_b tld
              ,okl_txl_ar_inv_lns_v til1
              ,okl_trx_ar_invoices_v tai1 where
              tai1.id = til1.tai_id and
              --til1.id = xls1.til_id and
              til1.id = tld.til_id_details and
              tai1.cpy_id IS NOT NULL and
              --xls1.lsm_id =ocas.id);
              tld.id =ocas.tld_id);

-- ASHIM CHANGE - END


l_idx INTEGER;
l_amount_past_due NUMBER :=0;

BEGIN

       x_return_status := FND_API.G_RET_STS_SUCCESS;
       write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Start of check_contract Procedure' );

       okl_debug_pub.logmessage('check_contract : START ');

       -- Get Contract allowed value for days past due from rules
          l_return_status := okl_contract_info.get_rule_value(
                              p_contract_id     => p_program_id
                             ,p_rule_group_code => 'COCURP'
                             ,p_rule_code		=> 'COCURE'
                             ,p_segment_number	=> 3
                             ,x_id1             => l_id1
                             ,x_id2             => l_id2
                             ,x_value           => l_rule_value);

       okl_debug_pub.logmessage('check_contract : okl_contract_info.get_rule_value : '||l_return_status);

        IF l_return_status =FND_Api.G_RET_STS_SUCCESS THEN
           l_days_allowed :=nvl(l_rule_value,0);
           write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                 'No of Past due days allowed from Rule is ' || l_days_allowed);
        END IF;

         okl_debug_pub.logmessage('check_contract : l_days_allowed : '||l_days_allowed);

         -- Get Past Due Amount
         OPEN  c_amount_past_due (p_contract_id,l_days_allowed);
         FETCH c_amount_past_due INTO l_amount_past_due;
         CLOSE c_amount_past_due;
         write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                 'Amount Past due with grace days is ' || nvl(l_days_allowed,0));

         IF nvl(l_amount_past_due,0) > 0 THEN
             write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Contract'
                         ||p_contract_number || ' is delinquent');
            x_return_status  := FND_API.G_RET_STS_ERROR;
        END IF;

       okl_debug_pub.logmessage('check_contract : l_amount_past_due : '||l_amount_past_due);
       okl_debug_pub.logmessage('check_contract : END ');

END check_contract;



---------------------------------------------------------------------------
-- PROCEDURE GENERATE_CURE_AMOUNT
-- This procedure starts the process for all contracts. It starts off by
-- validating if the contract has cure applicable and call populates cure
-- amount. If the contract does not have applicable cure, it is ignored
---------------------------------------------------------------------------
PROCEDURE GENERATE_CURE_AMOUNT(
   errbuf              OUT NOCOPY VARCHAR2,
   retcode             OUT NOCOPY NUMBER,
   p_contract_number     IN VARCHAR2
)
IS
  l_api_version               CONSTANT NUMBER := 1.0;
  l_api_name                  CONSTANT VARCHAR2(30) := 'OKL_CURE_CALC_PVT';
  l_return_status             VARCHAR2(1) := fnd_api.G_RET_STS_SUCCESS;
  l_msg_count                 NUMBER ;
  l_msg_data                  VARCHAR2(32627);
  l_init_msg_list             VARCHAR2(1) DEFAULT fnd_api.g_false;

  l_cure_flag 			VARCHAR2(1);
  l_rule_group_code           VARCHAR2(30) := 'COCURP';
  l_rule_code                 VARCHAR2(30) := 'COCURE';
  l_rule_name                 VARCHAR2(200);
  l_rule_value                VARCHAR2(2000);
  l_cure_past_due_allowed     NUMBER ;
  l_days_past_due             NUMBER ;
  l_no_of_cures               NUMBER :=0;
  l_no_of_cures_allowed       NUMBER :=0;
  l_repurchase_days_past_allowed NUMBER := -999;
  l_cure_calc_flag            VARCHAR2(30);

  l_id1                      VARCHAR2(40);
  l_id2                      VARCHAR2(200);

  -- Cursor fetches the contracts for processing
  CURSOR contract_csr( p_contract_number IN VARCHAR2) IS
    SELECT   prog.id program_id
            ,prog.contract_number program_number
            ,lease.id contract_id
            ,lease.contract_number contract_number
            ,rgp.rgd_code
    FROM    okc_k_headers_b prog,
            okc_k_headers_b lease,
            okl_k_headers   khr,
            okc_rule_groups_b rgp
    WHERE   khr.id = lease.id
    AND     khr.khr_id = prog.id
    AND     prog.scs_code = 'PROGRAM'
    AND     lease.scs_code in ('LEASE','LOAN')
    AND     rgp.rgd_code = 'COCURP'
    AND     rgp.dnz_chr_id = prog.id
    AND     lease.contract_number =nvl(p_contract_number,lease.contract_number) ;

   l_cure_amount okl_cure_amounts.cure_amount%type;



/*if the cure invoice is paid in full (i.e remaining_amount =0)
 then it is considered to be cured */

-- ASHIM CHANGE - START


 /*cursor c_get_noof_cures(p_contract_id IN NUMBER) is
 select count( ps.payment_schedule_id)
 from ar_payment_schedules ps
     ,okl_cnsld_ar_strms_b stream
     ,okl_xtl_sell_invs_v  xls
     ,okl_txl_ar_inv_lns_v til
     ,okl_trx_ar_invoices_v tai
 where ps.class ='INV'
      and ps.amount_due_remaining = 0
      and stream.receivables_invoice_id = ps.customer_trx_id
      and stream.id =xls.lsm_id
      and tai.id    = til.tai_id
      and til.id    = xls.til_id
      and tai.cpy_id IS NOT NULL
      and tai.khr_id =p_contract_id;*/

 cursor c_get_noof_cures(p_contract_id IN NUMBER)
 is
 select count( ps.payment_schedule_id)
 from   ar_payment_schedules ps
        ,okl_bpd_tld_ar_lines_v stream
        --,okl_xtl_sell_invs_v  xls
        ,okl_txd_ar_ln_dtls_b  tld
        ,okl_txl_ar_inv_lns_v til
        ,okl_trx_ar_invoices_v tai
 where  ps.class ='INV'
 and    ps.amount_due_remaining = 0
 and    stream.customer_trx_id = ps.customer_trx_id
 --and stream.id =xls.lsm_id
 and    stream.tld_id =tld.id
 and    tai.id    = til.tai_id
 --and til.id    = xls.til_id
 and    til.id    = tld.til_id_details
 and    tai.cpy_id IS NOT NULL
 and    tai.khr_id =p_contract_id;

-- ASHIM CHANGE - END


  l_error_msg_tbl error_message_type;

 /* Get min due date for the contract */

-- ASHIM CHANGE - START


  /*cursor  l_days_past_due_cur (p_contract_id IN NUMBER) is
        SELECT  min(aps.due_date)
        FROM    okl_cnsld_ar_strms_b ocas
               ,ar_payment_schedules aps
               ,okc_k_headers_b chr
               ,OKL_STRM_TYPE_TL SM
        WHERE
               ocas.khr_id = p_contract_id
          AND  ocas.receivables_invoice_id = aps.customer_trx_id
          AND  aps.class = 'INV'
          AND  aps.due_date < sysdate
          AND  NVL(aps.amount_due_remaining, 0) > 0
          AND  ocas.khr_id=chr.id
          AND sm.ID = ocas.STY_ID and sm.name <> 'CURE'    ;*/

  cursor  l_days_past_due_cur (p_contract_id IN NUMBER)
  is
  SELECT  min(aps.due_date)
  FROM    okl_bpd_tld_ar_lines_v ocas
          ,ar_payment_schedules aps
          ,okc_k_headers_b chr
          ,OKL_STRM_TYPE_TL SM
  WHERE   ocas.khr_id = p_contract_id
  AND     ocas.customer_trx_id = aps.customer_trx_id
  AND     aps.class = 'INV'
  AND     aps.due_date < sysdate
  AND     NVL(aps.amount_due_remaining, 0) > 0
  AND     ocas.khr_id=chr.id
  AND     sm.ID = ocas.STY_ID and sm.name <> 'CURE'    ;

-- ASHIM CHANGE - END



x_contract_number okc_k_headers_b.contract_number%TYPE;

l_default_date DATE :=TRUNC(SYSDATE);
l_days_past    DATE ;

l_process VARCHAR2(50);
l_process1 VARCHAR2(50);
l_process2 VARCHAR2(50);
l_repurchase_amount NUMBER;

BEGIN

  okl_debug_pub.logmessage('GENERATE_CURE_AMOUNT: START');
  okl_debug_pub.logmessage('GENERATE_CURE_AMOUNT: p_contract_number : ' || p_contract_number);

        write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH, 'OKL Generate Cure Amounts');
        write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH, 'Program Run Date:'||SYSDATE);
        write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH, '***********************************************');
        write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH, 'PARAMETERS');
        write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH, 'Contract Number = ' ||p_contract_number);
        write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH, '***********************************************');

    -- Open the contract cursor for process
    FOR i IN contract_csr(p_contract_number)
    LOOP
         write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM, '***********************************************');
         write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM,' Processing: Contract Number=> '
                                ||i.contract_number);
         write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM, ' Program number is ' ||i.program_number);
         write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM, ' Contract Id    is ' ||i.contract_id);

      okl_debug_pub.logmessage('GENERATE_CURE_AMOUNT: p_contract_number : ' || i.program_number);
      okl_debug_pub.logmessage('GENERATE_CURE_AMOUNT: p_contract_number : ' || i.contract_id);

      --need to process other contract if the first one errors out
      --so introducing this while loop

      WHILE TRUE LOOP
         -- Initialize the variables
         l_rule_value := NULL;
         l_cure_past_due_allowed := 0;
         l_days_past_due := 0;
         l_no_of_cures := 0;
         l_no_of_cures_allowed := 0;
         l_repurchase_days_past_allowed := 0;
         l_cure_calc_flag := NULL;
         l_return_status :=FND_Api.G_RET_STS_SUCCESS;
         l_days_past :=SYSDATE;
        -----------------------------------------------------------------
        -- CHECK IF THE CONTRACT HAS CURE RULE - WE DO NOT GENERATE CURES
        -- FOR CONTRACT THAT DOES NOT HAVE CURE AGREEMENT
        -- we need to the pass the vendor program id to get the
        -- cure rule values.
        -----------------------------------------------------------------
         l_return_status := okl_contract_info.get_rule_value(
                              p_contract_id     => i.program_id
                             ,p_rule_group_code => l_rule_group_code
                             ,p_rule_code		=> l_rule_code
                             ,p_segment_number	=> 1
                             ,x_id1             => l_id1
                             ,x_id2             => l_id2
                             ,x_value           => l_rule_value);

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW ,
               'Did not return a value for cure applicable Rule ');
             POPULATE_LOG_TBL(
                  p_contract_number =>i.contract_number,
                  p_cure_flag       =>NULL,
                  p_cure_amount     =>NULL,
                  P_type            =>'ERROR');
             EXIT;
          ELSE
              write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW ,
                     'Is Cure Applicable and rule value is ' || l_rule_value);
          END IF;

          okl_debug_pub.logmessage('GENERATE_CURE_AMOUNT: Cure Applicable rule value : ' || l_rule_value);

          IF (l_rule_value <> 'Yes') THEN
              write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW ,
                       'Is not cure applicable ');
             POPULATE_LOG_TBL(
                  p_contract_number =>i.contract_number,
                  p_cure_flag       =>NULL,
                  p_cure_amount     =>NULL,
                  P_type            =>'ERROR');
             EXIT;
          END IF;

          ------------------------------------------------------------------
          --check if the contract is come out of delinquency
          --if so, update cure amounts table SHOW_ON_REQUEST 'N' for the given
          --contract.
          --Check if any of the contracts are in delinquency
          --We are going to check if the contract has any delinquent
          --invoices.(due_date + gracedays(from rule) < SYSDATE )
         --Alternate way was to check if the case with the contract
         --is in was in Delinquency or not. ( this would not consider
         --                                    the grace days)
         ------------------------------------------------------------------

         CHECK_CONTRACT(i.contract_id,
                        i.program_id,
                        i.contract_number,
                        l_return_status);


         IF l_return_status = FND_API.G_RET_STS_SUCCESS  THEN

             write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW ,
                      'Contract  ' || i.contract_number ||
                      'is Not Delinquent ');

             okl_debug_pub.logmessage('GENERATE_CURE_AMOUNT: Contract ' || i.contract_number || ' is Not Delinquent');

             Update_cure_amounts(
                                 p_contract_id    =>i.contract_id,
                                 x_return_status  =>l_return_status,
                                 x_msg_count      =>l_msg_count,
                                 x_msg_data       =>l_msg_data );

             IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW ,
                     'Error Updating Cure amounts Table for contract '
                      || i.contract_number );
                GET_ERROR_MESSAGE(l_error_msg_tbl);
                IF (l_error_msg_tbl.COUNT > 0) THEN
                   FOR i IN l_error_msg_tbl.FIRST..l_error_msg_tbl.LAST
                   LOOP
                       write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH,
                                   l_error_msg_tbl(i));
                   END LOOP;
               END IF; --end of l_error_msg_tbl
            END IF; --  update_cure_amounts
            POPULATE_LOG_TBL(
                  p_contract_number =>i.contract_number,
                  p_cure_flag       =>NULL,
                  p_cure_amount     =>NULL,
                  P_type            =>'ERROR');
            EXIT;
         END IF; -- end of check_contract

          ------------------------------------------------------------------
          --check if the contract is already there in the cure amount table
          -- and also the negotiated amount is populated
          --(this indicates that a cure invoice was created for that contract)
          -- and status ='CURESINPROGRESS'
          --this is because the concurrent program can be run more than once
          -- in a month.
         ------------------------------------------------------------------


           OPEN  l_days_past_due_cur(i.contract_id);
           FETCH l_days_past_due_cur INTO l_days_past;
           CLOSE l_days_past_due_cur;

         l_days_past_due := l_default_date - nvl(TRUNC(l_days_past),
                                                   l_default_date);

         write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'Days past due  is ' ||l_days_past_due);

         okl_debug_pub.logmessage('GENERATE_CURE_AMOUNT: Days past due : ' || l_days_past_due);
          ----------------------------------------------------------
          -- Get Contract allowed value for days past due from rules
          --For Cure
          ----------------------------------------------------------
          l_rule_value := NULL;
          l_return_status := okl_contract_info.get_rule_value(
                              p_contract_id     => i.program_id
                             ,p_rule_group_code => l_rule_group_code
                             ,p_rule_code		=> l_rule_code
                             ,p_segment_number		=> 3
                             ,x_id1             => l_id1
                             ,x_id2             => l_id2
                             ,x_value           => l_rule_value);

         IF (l_return_status <> fnd_api.G_RET_STS_SUCCESS) THEN
            write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW ,
                     'Did not return a value for days past due ');

             POPULATE_LOG_TBL(
                  p_contract_number =>i.contract_number,
                  p_cure_flag       =>NULL,
                  p_cure_amount     =>NULL,
                  P_type            =>'ERROR');
             EXIT;
          ELSE
              write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW ,'Days past '||
                      'due allowed from rule is '
                                    || l_rule_value);
               l_cure_past_due_allowed :=nvl(l_rule_value,0);
          END IF;

         okl_debug_pub.logmessage('GENERATE_CURE_AMOUNT: Days past due allowed for Cure : ' || l_cure_past_due_allowed);

          ----------------------------------------------------------
          -- Get Contract allowed value for days past due from rules
          -- For repurchase
          ----------------------------------------------------------

            l_rule_value := NULL;
            l_return_status := okl_contract_info.get_rule_value(
                              p_contract_id     => i.program_id
                             ,p_rule_group_code => l_rule_group_code
                             ,p_rule_code		=> 'CORPUR'
                             ,p_segment_number  => 1
                             ,x_id1             => l_id1
                             ,x_id2             => l_id2
                             ,x_value           => l_rule_value);

            IF (l_return_status <> fnd_api.G_RET_STS_SUCCESS) THEN
              write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW ,
                'Did not return a value for days past due allowed for Repurchase'  );
              POPULATE_LOG_TBL(
                  p_contract_number =>i.contract_number,
                  p_cure_flag       =>NULL,
                  p_cure_amount     =>NULL,
                  P_type            =>'ERROR');
              EXIT;
            ELSE
              write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                 'Days_past due_allowed for repurchase is  ' || l_rule_value);
                 l_repurchase_days_past_allowed := nvl(l_rule_value,0);
           END IF;

           okl_debug_pub.logmessage('GENERATE_CURE_AMOUNT: Days past due allowed for repurchase : ' || l_repurchase_days_past_allowed);

          ----------------------------------------------------------
          -- Get no of cures made against contract
          -- For repurchase
          ----------------------------------------------------------

            l_no_of_cures := 0;
            OPEN  c_get_noof_cures(i.contract_id);
            FETCH c_get_noof_cures INTO l_no_of_cures;
            CLOSE c_get_noof_cures;

            write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, ' No of cures  is '
                                                          ||l_no_of_cures);

            okl_debug_pub.logmessage('GENERATE_CURE_AMOUNT: No of cures from cursor : ' || l_no_of_cures);

            -- Now get the no of cures allowed value from Rule
            l_rule_value := NULL;
            l_return_status := okl_contract_info.get_rule_value(
                              p_contract_id     => i.program_id
                             ,p_rule_group_code => l_rule_group_code
                             ,p_rule_code		=> 'CORPUR'
                             ,p_segment_number	=> 2
                             ,x_id1             => l_id1
                             ,x_id2             => l_id2
                             ,x_value           => l_rule_value);

            IF (l_return_status <> fnd_api.G_RET_STS_SUCCESS) THEN
              write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW ,
                        'Did not return a value for no of cures allowed ');
              POPULATE_LOG_TBL(
                  p_contract_number =>i.contract_number,
                  p_cure_flag       =>NULL,
                  p_cure_amount     =>NULL,
                  P_type            =>'ERROR');
              EXIT;
            ELSE
              write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW ,
                      'No of cures allowed before Repurchase is ' || l_rule_value);
              l_no_of_cures_allowed := nvl(l_rule_value,0);
            END IF;

            okl_debug_pub.logmessage('GENERATE_CURE_AMOUNT: No of cures from rule : ' || l_no_of_cures_allowed);

            /* If days past due is more than days past due allowed
               and number of cures received is more than number of
               cures allowed for repurchase, ask for repurchase, else
               cure
               --09/26 logic has been changed ,we could have CURE and repurchase
               -- for the same record, so introducing a new field -Process
            */


           --1) if   l_days_past_due  > l_cure_past_due_allowed -- CURE
           --2) if    l_days_past_due  > l_repurchase_days_past_allowed
                      --and l_no_of_cures > l_no_of_cures_allowed -- REPURCHASE


            IF  l_days_past_due >  l_cure_past_due_allowed THEN
                l_process1 := 'CURE';
            END IF;

            IF  l_days_past_due >  l_repurchase_days_past_allowed
                 and l_no_of_cures > l_no_of_cures_allowed THEN
                 l_process2 := 'REPURCHASE';
            END IF;

            IF  l_process1 IS NOT NULL and l_process2 is NOT NULL  THEN
                  l_process  := 'BOTH' ;
            ELSIF l_process1 IS NOT NULL THEN
                  l_process  := l_process1;
            ELSIF  l_process2 IS NOT NULL THEN
                  l_process  := l_process2;
            ELSE
                 write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW ,
                         'Did not Satisfy The Rule Values ');
                 POPULATE_LOG_TBL(
                  p_contract_number =>i.contract_number,
                  p_cure_flag       =>NULL,
                  p_cure_amount     =>NULL,
                  P_type            =>'ERROR');
              EXIT;
          END IF;

           write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM, ' Contract '||
                   i.contract_number || ' will be in ' ||l_process);

           okl_debug_pub.logmessage('GENERATE_CURE_AMOUNT: Contract '||  i.contract_number || ' is processed for ' ||l_process);

            /* Check if the contract is in litigation
               The code will be added once the source is finalized
               The code will check if the contract is in litigation,
               if so, we will utilize the cure type set up for contract
               under litigation otherwise use the default cure type
               (FULL, INTEREST)
            */

            IF l_process IN ('CURE','BOTH')THEN

                  -- add litigation check here
                   ----------------------------------------------------------
                  -- Get Contract cure type from rules
                  ----------------------------------------------------------
                  l_rule_value := NULL;
                  l_return_status := okl_contract_info.get_rule_value(
                                   p_contract_id     => i.program_id
                                  ,p_rule_group_code => l_rule_group_code
                                  ,p_rule_code	     => l_rule_code
                                  ,p_segment_number  => 2
                                  ,x_id1             => l_id1
                                  ,x_id2             => l_id2
                                  ,x_value           => l_rule_value );

                 IF (l_return_status <> fnd_api.G_RET_STS_SUCCESS) THEN
                     write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW ,
                       'Did not return a value for Type of Cure '  );
                     POPULATE_LOG_TBL(
                       p_contract_number =>i.contract_number,
                       p_cure_flag       =>NULL,
                       p_cure_amount     =>NULL,
                       P_type            =>'ERROR');
                    EXIT;
                 ELSE
                     write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW ,
                       'Type of Cure is ' || l_rule_value);
                 END IF;
                 l_cure_calc_flag := l_rule_value;

            END IF; --(l_cure_calc_flag = 'CURE')


            CALC_CURE_REPURCHASE( p_api_version       =>l_api_version,
                                  p_init_msg_list     =>l_init_msg_list,
 				                  p_contract_id       =>i.contract_id,
                                  p_contract_number   =>i.contract_number,
                                  p_program_id        =>i.program_id,
                                  p_rule_group_code   =>l_rule_group_code,
                                  p_cure_calc_flag    =>l_cure_calc_flag,
                                  p_process           =>l_process,
                                  x_repurchase_amount =>l_repurchase_amount,
                                  x_cure_amount       =>l_cure_amount,
                                  x_return_status     =>l_return_status,
                                  x_msg_count         =>l_msg_count,
                                  x_msg_data          =>l_msg_data );

              okl_debug_pub.logmessage('GENERATE_CURE_AMOUNT: after CALC_CURE_REPURCHASE : '|| l_return_status);

              write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM,
              'Result of Cure or Repurchase for contract_number '||
                i.contract_number || ' is ' ||l_return_status);

            IF (l_return_status <> fnd_api.G_RET_STS_SUCCESS) THEN
              GET_ERROR_MESSAGE(l_error_msg_tbl);
              IF (l_error_msg_tbl.COUNT > 0) THEN
                 write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH,' Error in calculating repurchase');
                FOR i IN l_error_msg_tbl.FIRST..l_error_msg_tbl.LAST
                LOOP
                  write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH,
                                   l_error_msg_tbl(i));
                END LOOP;
              END IF;
              POPULATE_LOG_TBL(
                     p_contract_number =>i.contract_number,
                     p_cure_flag       =>l_cure_calc_flag,
                     p_cure_amount     =>l_cure_amount,
                     P_type            =>'ERROR');
            ELSE
                  POPULATE_LOG_TBL(
                     p_contract_number =>i.contract_number,
                     p_cure_flag       =>l_cure_calc_flag,
                     p_cure_amount     =>l_cure_amount,
                     P_type            =>'SUCCESS');
            END IF;

          EXIT; --for while loop
       END LOOP; --end of while loop
    END LOOP;
    Print_log (p_contract_number);
    retcode :=0; --success

  okl_debug_pub.logmessage('GENERATE_CURE_AMOUNT: END');

  EXCEPTION
  WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (OTHERS)IN OKL_CURE_CALC_PVT => '||SQLERRM);
        retcode :=2;
        errbuf :=SQLERRM;

END GENERATE_CURE_AMOUNT;

END OKL_CURE_CALC_PVT;

/
