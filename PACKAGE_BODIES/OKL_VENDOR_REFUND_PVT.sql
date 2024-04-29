--------------------------------------------------------
--  DDL for Package Body OKL_VENDOR_REFUND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VENDOR_REFUND_PVT" AS
/* $Header: OKLRRFDB.pls 120.5 2007/10/17 17:41:35 vdamerla ship $ */
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
               ,x_msg_data       OUT NOCOPY VARCHAR2 )
IS

CURSOR c_get_cure_amts (p_contract_id IN NUMBER)
IS
SELECT  cure_amount_id
       ,object_version_number
FROM    okl_cure_amounts
WHERE   chr_id = p_contract_id
AND     STATUS = 'CURESINPROGRESS';

l_camv_tbl       OKL_cure_amounts_pub.camv_tbl_type;
x_camv_tbl       OKL_cure_amounts_pub.camv_tbl_type;
l_msg_count      NUMBER;
l_msg_data       VARCHAR2(32627);
l_return_status  VARCHAR2(1) :=FND_API.G_RET_STS_SUCCESS;
next_row         INTEGER;
l_error_msg_tbl  error_message_type;

BEGIN
  okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : Update_cure_amounts : START ');
  okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : Update_cure_amounts : p_contract_id : '||p_contract_id);

  SAVEPOINT UPDATE_CURE_AMOUNTS;
  FND_MSG_PUB.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Calling Cure Amount Update Api');

  --update cure amounts table
  FOR i in c_get_cure_amts (p_contract_id)
  LOOP
    next_row := nvl(l_camv_tbl.LAST,0) +1;
    l_camv_tbl(next_row).cure_amount_id        := i.cure_amount_id;
    l_camv_tbl(next_row).object_version_number := i.object_version_number;
    l_camv_tbl(next_row).STATUS :='MOVED_TO_REFUNDS';

    okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : Update_cure_amounts : l_camv_tbl(next_row).cure_amount_id : '||l_camv_tbl(next_row).cure_amount_id);

    SELECT DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, Fnd_Global.CONC_REQUEST_ID),
           DECODE(Fnd_Global.PROG_APPL_ID, -1, NULL, Fnd_Global.PROG_APPL_ID),
	   DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL, Fnd_Global.CONC_PROGRAM_ID),
	   DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, SYSDATE)
    INTO   l_camv_tbl(next_row).request_id,
    	   l_camv_tbl(next_row).program_application_id,
    	   l_camv_tbl(next_row).program_id,
    	   l_camv_tbl(next_row).program_update_date
    FROM DUAL;

  END LOOP;
  write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'no of records to be updated in Cure amounts '||l_camv_tbl.COUNT);
  IF (l_camv_tbl.COUNT > 0)
  THEN
    OKL_cure_amounts_pub.update_cure_amounts
                         (  p_api_version    => 1
                           ,p_init_msg_list  => 'T'
                           ,x_return_status  => l_return_status
                           ,x_msg_count      => l_msg_count
                           ,x_msg_data       => l_msg_data
                           ,p_camv_tbl       => l_camv_tbl
                           ,x_camv_tbl       => x_camv_tbl
                         );
    okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : Update_cure_amounts : OKL_cure_amounts_pub.update_cure_amounts : '||l_return_status);

    IF (l_return_status  <> FND_Api.G_RET_STS_SUCCESS )
    THEN
      RAISE Fnd_Api.G_EXC_ERROR;
    ELSE
      write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM,
               'Updation of cure amounts is Successful');
    END IF;
    x_return_status  := l_return_status;
    FND_MSG_PUB.Count_And_Get ( p_count =>   x_msg_count,
                                p_data   =>   x_msg_data );
  END IF;

  okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : Update_cure_amounts : END ');

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
    Fnd_Msg_Pub.ADD_EXC_MSG('OKL_VENDOR_REFUND_PVT','UPDATE_CURE_AMOUNTS');
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
End update_cure_amounts;

---------------------------------------------------------------------------
-- PROCEDURE CALC_CURE_REFUND
---------------------------------------------------------------------------
PROCEDURE CALC_CURE_REFUND(
  p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT FND_api.G_FALSE,
  p_contract_id		      IN NUMBER,
  p_contract_number           IN VARCHAR2,
  p_program_id                IN NUMBER,
  p_rule_group_code           IN VARCHAR2,
  p_vendor_id                 IN VARCHAR2,
  p_times_cured               IN NUMBER,
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
  l_received_amount           NUMBER := 0;
  l_outstanding_amount        NUMBER := 0;
  l_delinquent_amount         NUMBER := 0;
  l_cures_in_possession       NUMBER := 0;

  l_camv_rec                 OKL_cure_amounts_pub.camv_rec_type;
  x_camv_rec                 OKL_cure_amounts_pub.camv_rec_type;
  l_crsv_rec                 OKL_cure_rfnd_stage_pub.crsv_rec_type;
  x_crsv_rec                 OKL_cure_rfnd_stage_pub.crsv_rec_type;
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(32627);
  l_error_msg_tbl 	     error_message_type;

  Cursor c_calc_refund_csr (p_contract_id IN NUMBER) is
  select nvl(sum(negotiated_amount),0), nvl(sum(received_amount),0)
  from  okl_cure_amounts
  where chr_id =p_contract_id
  and nvl(negotiated_amount,0) > 0
  and nvl(received_amount,0) > 0
  and   status ='CURESINPROGRESS';

BEGIN
  okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : CALC_CURE_REFUND : START ');
  okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : CALC_CURE_REFUND : p_contract_id : '||p_contract_id);
  okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : CALC_CURE_REFUND : p_contract_number : '||p_contract_number);
  okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : CALC_CURE_REFUND : p_program_id : '||p_program_id);
  okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : CALC_CURE_REFUND : p_rule_group_code : '||p_rule_group_code);
  okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : CALC_CURE_REFUND : p_vendor_id : '||p_vendor_id);
  okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : CALC_CURE_REFUND : p_times_cured : '||p_times_cured);

  SAVEPOINT CALC_CURE_REFUND;

  write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Calc refund started for ' || p_contract_number);
  write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Before Inserting Cure Amounts');

  OPEN  c_calc_refund_csr(p_contract_id);
  FETCH c_calc_refund_csr INTO l_negotiated_amount, l_received_amount;
  CLOSE c_calc_refund_csr;

  okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : CALC_CURE_REFUND : l_negotiated_amount : '||l_negotiated_amount);
  okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : CALC_CURE_REFUND : l_received_amount : '||l_received_amount);

  write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'l_negotiated_amount'||l_negotiated_amount);
  write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'l_received_amount'||l_received_amount);

  IF ((l_negotiated_amount > 0)
      AND
      (l_received_amount > 0)
      AND
      (l_received_amount  >= l_negotiated_amount))
  THEN
    -- Update status to 'MOVED_TO_REFUNDS' FOR previous contracts.
    Update_cure_amounts( p_contract_id    =>p_contract_id,
                         x_return_status  =>l_return_status,
                         x_msg_count      =>l_msg_count,
                         x_msg_data       =>l_msg_data );

    okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : CALC_CURE_REFUND : Update_cure_amounts : '||l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW ,
                'Error Updating Cure amounts Table for contract '|| p_contract_number );
      GET_ERROR_MESSAGE(l_error_msg_tbl);
      IF (l_error_msg_tbl.COUNT > 0)
      THEN
        FOR i IN l_error_msg_tbl.FIRST..l_error_msg_tbl.LAST
        LOOP
          write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH, l_error_msg_tbl(i));
        END LOOP;
      END IF; --end of l_error_msg_tbl
    END IF; --  update_cure_amounts

    -- Populate the data in OKL_cure_refunds_stage entity for the contract.
    l_crsv_rec.chr_id                   := p_contract_id;
    l_crsv_rec.status                   := 'ENTERED';
    l_crsv_rec.negotiated_amount        := l_negotiated_amount;
    l_crsv_rec.received_amount          := l_received_amount;
    l_crsv_rec.vendor_id                := p_vendor_id;
    l_crsv_rec.object_version_number    := 1.0;

    SELECT DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, Fnd_Global.CONC_REQUEST_ID),
           DECODE(Fnd_Global.PROG_APPL_ID, -1, NULL, Fnd_Global.PROG_APPL_ID),
           DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL, Fnd_Global.CONC_PROGRAM_ID),
           DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, SYSDATE)
    INTO   l_crsv_rec.request_id,
           l_crsv_rec.program_application_id,
           l_crsv_rec.program_id,
           l_crsv_rec.program_update_date
    FROM DUAL;

    write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Before Inserting Cure Refunds');

    OKL_cure_rfnd_stage_pub.insert_cure_refunds
                         (  p_api_version    => p_api_version
                           ,p_init_msg_list  => p_init_msg_list
                           ,x_return_status  => l_return_status
                           ,x_msg_count      => l_msg_count
                           ,x_msg_data       => l_msg_data
                           ,p_crsv_rec       => l_crsv_rec
                           ,x_crsv_rec       => x_crsv_rec);

    okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : CALC_CURE_REFUND : OKL_cure_rfnd_stage_pub.insert_cure_refunds : '||l_return_status);
    IF (l_return_status  <> FND_Api.G_RET_STS_SUCCESS )
    THEN
      write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM, ' Error Inserting Cure Refunds');
      RAISE Fnd_Api.G_EXC_ERROR;
    ELSE
      write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM,
      'Done inserting cure refunds, cure received amount  is '||l_received_amount || 'and negotiated amount is'||l_negotiated_amount);
      x_cure_amount:=l_received_amount; -- bug 6487958
    END IF;
  ELSE
       write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM,
          ' Cure refund received amount and negotiated amount not equal, cure refund record is not created');
  END IF;

  x_return_status  := l_return_status;

  FND_MSG_PUB.Count_And_Get ( p_count =>   x_msg_count, p_data   =>   x_msg_data );

  okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : CALC_CURE_REFUND : END ');

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    ROLLBACK TO CALC_CURE_REFUND;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO CALC_CURE_REFUND;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO CALC_CURE_REFUND;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    Fnd_Msg_Pub.ADD_EXC_MSG('OKL_VENDOR_REFUND_PVT','CALC_CURE_REFUND');
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END CALC_CURE_REFUND ;

PROCEDURE POPULATE_LOG_TBL(
                   p_contract_number IN VARCHAR2,
                   p_cure_flag       IN VARCHAR2,
                   p_cure_amount     IN NUMBER,
                   P_type            IN VARCHAR2)
IS
BEGIN
  IF p_type = 'ERROR'
  THEN
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

PROCEDURE write_log( mesg_level IN NUMBER
                    ,mesg       IN VARCHAR2)
IS
BEGIN
  IF (mesg_level >= l_msgLevel)
  THEN
    fnd_file.put_line(FND_FILE.LOG, mesg);
  END IF;
END;

PROCEDURE print_log (p_contract_number VARCHAR2)
IS
BEGIN
  FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'OKL Generate Cure Refund');
  FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Program Run Date:'||SYSDATE);
  FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');
  FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'PARAMETERS');
  FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Contract Number = ' ||p_contract_number);
  FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');

  IF l_success_tbl.COUNT > 0
  THEN
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                       'Cure Refund Generated for '||l_success_tbl.COUNT || ' Contracts ');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');
    FOR i in l_success_tbl.FIRST..l_success_tbl.LAST
    LOOP
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT ,'Contract Number ' ||
                         l_success_tbl(i).contract_number  || ' Cure Type is '||
                         l_success_tbl(i).cure_type        || ' Cure Amount '||
                         l_success_tbl(i).cure_amount       );
    END LOOP;
  END IF;

  IF l_error_tbl.COUNT > 0
  THEN
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,
                       'Cure Refund Not Generated For '||l_error_tbl.COUNT || ' Contracts ');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');
    FOR i in l_error_tbl.FIRST..l_error_tbl.LAST
    LOOP
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT ,
                         '  Contract Number  '||l_error_tbl(i).contract_number  );
    END LOOP;
  END IF;
END print_log;

PROCEDURE check_contract( p_contract_id      IN NUMBER
                         ,p_program_id       IN NUMBER
                         ,p_contract_number  IN VARCHAR2
                         ,x_return_status    OUT NOCOPY VARCHAR2)
IS
l_id1              VARCHAR2(40);
l_id2             VARCHAR2(200);
l_rule_value      VARCHAR2(2000);
l_days_allowed    NUMBER   :=0;
l_return_status   VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
l_idx             INTEGER;
l_amount_past_due NUMBER :=0;
l_non_del         NUMBER := null;

-- check for non-delinquent contracts
-- ASHIM CHANGE - START
/*CURSOR c_amount_past_due(p_contract_id IN NUMBER,
                         p_grace_days  IN NUMBER) IS
    SELECT count(*)
    FROM   okl_cnsld_ar_strms_b ocas
          ,ar_payment_schedules_all aps
    WHERE  ocas.khr_id = p_contract_id
    AND    ocas.receivables_invoice_id = aps.customer_trx_id
    AND    aps.class ='INV'
    AND    (aps.actual_date_closed + p_grace_days) < sysdate
    AND    NVL(aps.amount_due_remaining, 0) = 0
    AND    not exists
          (select xls1.lsm_id from
              okl_xtl_sell_invs_v xls1
              ,okl_txl_ar_inv_lns_v til1
              ,okl_trx_ar_invoices_v tai1 where
              tai1.id = til1.tai_id and
              til1.id = xls1.til_id and
              tai1.cpy_id IS NOT NULL and
              xls1.lsm_id =ocas.id);*/

CURSOR c_amount_past_due(p_contract_id IN NUMBER,
                         p_grace_days  IN NUMBER)
IS
SELECT  count(*)
FROM    okl_bpd_tld_ar_lines_v                  ocas
       ,ar_payment_schedules_all                aps
WHERE   ocas.khr_id                             = p_contract_id
AND     ocas.customer_trx_id                    = aps.customer_trx_id
AND     aps.class                               = 'INV'
AND     (aps.actual_date_closed + p_grace_days) < sysdate
AND     NVL(aps.amount_due_remaining, 0)        = 0
AND     NOT EXISTS
          --(select xls1.lsm_id from
          (SELECT  tld.id
           FROM   --okl_xtl_sell_invs_v xls1
                   okl_txd_ar_ln_dtls_b tld
                  ,okl_txl_ar_inv_lns_v til1
                  ,okl_trx_ar_invoices_v tai1
           WHERE  tai1.id   = til1.tai_id
           AND
              --til1.id = xls1.til_id and
                til1.id     = tld.til_id_details
           AND  tai1.cpy_id IS NOT NULL
           AND
              --xls1.lsm_id =ocas.id);
                tld.id      = ocas.tld_id);
-- ASHIM CHANGE - END
-- check if any pending cure invoives to be paid.
-- I guess, this is being taken care by
-- checking received amount  =  negotiated amount

BEGIN
  okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : check_contract : START ');
  okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : check_contract : p_contract_id : '||p_contract_id);
  okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : check_contract : p_program_id : '||p_program_id);
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Start of check_contract Procedure' );

  -- Get Contract allowed value for days past due from rules
  l_return_status := okl_contract_info.get_rule_value(
                              p_contract_id     => p_program_id
                             ,p_rule_group_code => 'COCURP'
                             ,p_rule_code	=> 'CORFND'
                             ,p_segment_number	=> 2
                             ,x_id1             => l_id1
                             ,x_id2             => l_id2
                             ,x_value           => l_rule_value);

  okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : check_contract : okl_contract_info.get_rule_value : '||l_return_status);

  IF l_return_status =FND_Api.G_RET_STS_SUCCESS
  THEN
    l_days_allowed :=nvl(l_rule_value,0);
    write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Days allowed before refund is issued from Rule is ' || l_days_allowed);
  END IF;
  okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : check_contract : l_days_allowed : '||l_days_allowed);

  l_non_del := null;
  OPEN  c_amount_past_due (p_contract_id,l_days_allowed);
  FETCH c_amount_past_due INTO l_non_del;
  CLOSE c_amount_past_due;
  okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : check_contract : l_non_del : '||l_non_del);

  write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Amount Past due with grace days is ' || nvl(l_days_allowed,0));

  IF (l_non_del > 0)
  THEN
    write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Contract'||p_contract_number || ' is not delinquent');
    x_return_status  := FND_API.G_RET_STS_ERROR;
  END IF;

  okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : check_contract : END ');
END check_contract;

---------------------------------------------------------------------------
-- PROCEDURE GENERATE_VENDOR_REFUND
-- This procedure starts the process for all contracts. It starts off by
-- validating if the contract is refund applicable and call populates refund
-- amount. If the contract does not have applicable refund, it is ignored
---------------------------------------------------------------------------
PROCEDURE GENERATE_VENDOR_REFUND(
   errbuf              OUT NOCOPY VARCHAR2,
   retcode             OUT NOCOPY NUMBER,
   p_contract_number     IN VARCHAR2
)
IS
  l_api_version               CONSTANT NUMBER := 1.0;
  l_api_name                  CONSTANT VARCHAR2(30) := 'OKL_VENDOR_REFUND_PVT';
  l_return_status             VARCHAR2(1) := fnd_api.G_RET_STS_SUCCESS;
  l_msg_count                 NUMBER ;
  l_msg_data                  VARCHAR2(32627);
  l_init_msg_list             VARCHAR2(1) DEFAULT fnd_api.g_false;

  l_cure_flag 		      VARCHAR2(1);
  l_rule_group_code           VARCHAR2(30) := 'COCURP';
  l_rule_code                 VARCHAR2(30) := 'CORFND';
  l_rule_name                 VARCHAR2(200);
  l_rule_value                VARCHAR2(2000);
  l_days_past_due_allowed     NUMBER ;
  l_days_past_due             NUMBER ;
  l_no_of_cures               NUMBER ;
  l_no_of_cures_allowed       NUMBER ;
  l_repurchase_days_past_allowed NUMBER := -999;
  l_cure_calc_flag            VARCHAR2(30);
  l_vendor_id                 VARCHAR2(40);

  l_negotiated_amount         NUMBER ;
  l_repurchased_amount        NUMBER ;

  l_id1                      VARCHAR2(40);
  l_id2                      VARCHAR2(200);

  -- Cursor fetches the contracts for processing
  CURSOR contract_csr( p_contract_number IN VARCHAR2) IS
    SELECT   prog.id program_id
            ,prog.contract_number program_number
            ,lease.id contract_id
            ,lease.contract_number contract_number
            ,rgp.rgd_code
            ,pty.object1_id1 vendor_id
    FROM    okc_k_headers_b prog,
            okc_k_headers_b lease,
            okl_k_headers   khr,
            okc_rule_groups_b rgp,
            okc_k_party_roles_v pty,
            OKX_VENDORS_V vnd
    WHERE   khr.id = lease.id
    AND     khr.khr_id = prog.id
    AND     prog.scs_code = 'PROGRAM'
    AND     lease.scs_code in ('LEASE','LOAN')
    AND     rgp.rgd_code = 'COCURP'
    AND     rgp.dnz_chr_id = prog.id
    AND     prog.id = pty.chr_id
    AND     pty.rle_code = 'OKL_VENDOR'
    AND     pty.object1_id1 = to_char(vnd.id1)
    AND     pty.object1_id2 = vnd.id2
    AND     lease.contract_number =nvl(p_contract_number,lease.contract_number)
    and     exists (select 1 from okl_cure_amounts cam
                where cam.chr_id = lease.id
                and cam.status = 'CURESINPROGRESS'
                and nvl(negotiated_amount,0) > 0);
/*
    and     exists (select 1 from okl_cure_reports cr
                    where cr.vendor_id = vnd.id1);
*/
   l_cure_amount okl_cure_amounts.cure_amount%type;

/*if the cure invoice is paid in full (i.e remaining_amount =0)
 then it is considered to be cured */

-- ASHIM CHANGE - START



 /*cursor c_get_noof_cures(p_contract_id IN NUMBER) is
 select count( ps.payment_schedule_id)
 from ar_payment_schedules_all ps
     ,okl_cnsld_ar_strms_b stream
     ,okl_xtl_sell_invs_v  xls
     ,okl_txl_ar_inv_lns_v til
     ,okl_trx_ar_invoices_v tai
 where ps.class ='INV'
      and ps.amount_due_remaining = 0
      and stream.receivables_invoice_id = ps.customer_trx_id
      and stream.id = xls.lsm_id
      and tai.id = til.tai_id
      and til.id = xls.til_id
      and tai.cpy_id IS NOT NULL
      and tai.khr_id = p_contract_id;*/


 cursor c_get_noof_cures(p_contract_id IN NUMBER) is
 select count( ps.payment_schedule_id)
 from ar_payment_schedules_all ps
     ,okl_bpd_tld_ar_lines_v stream
     --,okl_xtl_sell_invs_v  xls
     ,okl_txd_ar_ln_dtls_b  tld
     ,okl_txl_ar_inv_lns_v til
     ,okl_trx_ar_invoices_v tai
 where ps.class ='INV'
      and ps.amount_due_remaining = 0
      and stream.customer_trx_id = ps.customer_trx_id
      --and stream.id = xls.lsm_id
      and stream.tld_id = tld.id
      and tai.id = til.tai_id
      --and til.id = xls.til_id
      and til.id = tld.til_id_details
      and tai.cpy_id IS NOT NULL
      and tai.khr_id = p_contract_id;


-- ASHIM CHANGE - END


  l_error_msg_tbl error_message_type;

 /* Get min due date for the contract */

-- ASHIM CHANGE - START



  /*cursor  l_days_past_due_cur (p_contract_id IN NUMBER) is
        SELECT  min(aps.due_date)
        FROM    okl_cnsld_ar_strms_b ocas
               ,ar_payment_schedules_all aps
               ,okc_k_headers_b chr
        WHERE
               ocas.khr_id = p_contract_id
          AND  ocas.receivables_invoice_id = aps.customer_trx_id
          AND  aps.class = 'INV'
          AND  aps.due_date < sysdate
          AND  NVL(aps.amount_due_remaining, 0) = 0
          AND  ocas.khr_id=chr.id
          AND  not exists
               ( select xls1.lsm_id from
                 okl_xtl_sell_invs_v xls1
                 ,okl_txl_ar_inv_lns_v til1
                 ,okl_trx_ar_invoices_v tai1 where
                 tai1.id = til1.tai_id
                 and til1.id = xls1.til_id and
                 tai1.cpy_id IS NOT NULL and
                 xls1.lsm_id =ocas.id);*/

  cursor  l_days_past_due_cur (p_contract_id IN NUMBER) is
        SELECT  min(aps.due_date)
        FROM    okl_bpd_tld_ar_lines_v ocas
               ,ar_payment_schedules_all aps
               ,okc_k_headers_b chr
        WHERE
               ocas.khr_id = p_contract_id
          AND  ocas.customer_trx_id = aps.customer_trx_id
          AND  aps.class = 'INV'
          AND  aps.due_date < sysdate
          AND  NVL(aps.amount_due_remaining, 0) = 0
          AND  ocas.khr_id=chr.id
          AND  not exists
               --( select xls1.lsm_id from
               ( select tld.id from
                 --okl_xtl_sell_invs_v xls1
                 okl_txd_ar_ln_dtls_b tld
                 ,okl_txl_ar_inv_lns_v til1
                 ,okl_trx_ar_invoices_v tai1 where
                 tai1.id = til1.tai_id
                 --and til1.id = xls1.til_id and
                 and til1.id = tld.til_id_details and
                 tai1.cpy_id IS NOT NULL and
                 tld.id =ocas.tld_id);



-- ASHIM CHANGE - END


x_contract_number okc_k_headers_b.contract_number%TYPE;
l_default_date DATE :=TRUNC(SYSDATE);
l_days_past    DATE ;
BEGIN
  okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : GENERATE_VENDOR_REFUND : START ');
  okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : GENERATE_VENDOR_REFUND : p_contract_number : '||p_contract_number);

  write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH, 'OKL Generate Cure Refund');
  write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH, 'Program Run Date:'||SYSDATE);
  write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH, '***********************************************');
  write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH, 'PARAMETERS');
  write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH, 'Contract Number = ' ||p_contract_number);
  write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH, '***********************************************');

  -- Open the contract cursor for process
  FOR i IN contract_csr(p_contract_number)
  LOOP
    write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM,
              '***********************************************');
    write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM,
              ' Processing: Contract Number=> '||i.contract_number);
    write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM,
              ' Program number is ' ||i.program_number);
    write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM,
              ' Contract Id    is ' ||i.contract_id);
    --need to process other contract if the first one errors out
    --so introducing this while loop

    WHILE TRUE
    LOOP
      -- Initialize the variables
      l_rule_value := NULL;
      l_no_of_cures := 0;
      l_no_of_cures_allowed := 0;
      l_repurchase_days_past_allowed := 0;
      l_cure_calc_flag := NULL;
      l_return_status :=FND_Api.G_RET_STS_SUCCESS;
      l_days_past :=SYSDATE;
      l_vendor_id := null;
      -----------------------------------------------------------------
      -- CHECK IF THE CONTRACT HAS CURE RULE - WE DO NOT GENERATE CURES
      -- FOR CONTRACT THAT DOES NOT HAVE CURE AGREEMENT
      -- we need to the pass the vendor program id to get the
      -- cure rule values.
      -----------------------------------------------------------------
      l_return_status := okl_contract_info.get_rule_value(
                              p_contract_id     => i.program_id
                             ,p_rule_group_code => l_rule_group_code
                             ,p_rule_code	=> l_rule_code
                             ,p_segment_number	=> 2
                             ,x_id1             => l_id1
                             ,x_id2             => l_id2
                             ,x_value           => l_rule_value);
      okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : GENERATE_VENDOR_REFUND : okl_contract_info.get_rule_value : '||l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
        write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW ,
               'Did not return a value from rule for grace days allowed before cure refund starts');

        POPULATE_LOG_TBL(
                  p_contract_number =>i.contract_number,
                  p_cure_flag       =>NULL,
                  p_cure_amount     =>NULL,
                  P_type            =>'ERROR');
        EXIT;

      ELSE
        write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW ,
                  'Cure Refund grace days allowed rule exists and rule value is ' || l_rule_value);
      END IF;

      IF (l_rule_value is null and to_number(l_rule_value) < 0)
      THEN
        write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW ,
                 'Cure Refund grace days allowed rule segment value does not exist and rule value is '||l_rule_value);
        POPULATE_LOG_TBL(
                  p_contract_number =>i.contract_number,
                  p_cure_flag       =>NULL,
                  p_cure_amount     =>NULL,
                  P_type            =>'ERROR');
        EXIT;
      END IF;

      ------------------------------------------------------------------
      --check if the contract is come out of delinquency
      --if YES (due_date + gracedays(from rule) < SYSDATE )
      --then continue cure refund process
      ------------------------------------------------------------------

      CHECK_CONTRACT(i.contract_id,
                     i.program_id,
                     i.contract_number,
                     l_return_status);
      okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : GENERATE_VENDOR_REFUND : CHECK_CONTRACT : '||l_return_status);

      IF l_return_status = FND_API.G_RET_STS_SUCCESS
      THEN
        write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW ,
                  'Contract  ' || i.contract_number ||'is Delinquent ');
           --jsanju added this
        POPULATE_LOG_TBL(
                  p_contract_number =>i.contract_number,
                  p_cure_flag       =>NULL,
                  p_cure_amount     =>NULL,
                  P_type            =>'ERROR');
        EXIT;
      END IF; -- end of check_contract

      CALC_CURE_REFUND( p_api_version     =>l_api_version,
                        p_init_msg_list   =>l_init_msg_list,
                        p_contract_id     =>i.contract_id,
                        p_contract_number =>i.contract_number,
                        p_program_id      =>i.program_id,
                        p_rule_group_code =>l_rule_group_code,
                        p_vendor_id       =>i.vendor_id,
                        p_times_cured     =>l_no_of_cures,
                        x_return_status   =>l_return_status,
                        x_msg_count       =>l_msg_count,
                        x_msg_data        =>l_msg_data ,
                        x_cure_amount     =>l_cure_amount);
      okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : GENERATE_VENDOR_REFUND : CALC_CURE_REFUND : '||l_return_status);

      write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM,
                'Result of Cure Refund for contract_number '||
                 i.contract_number || ' is ' ||l_return_status);

      IF (l_return_status <> fnd_api.G_RET_STS_SUCCESS)
      THEN
        GET_ERROR_MESSAGE(l_error_msg_tbl);
        IF (l_error_msg_tbl.COUNT > 0)
        THEN
          write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH,' Error in calculating Cure Refund');
          FOR i IN l_error_msg_tbl.FIRST..l_error_msg_tbl.LAST
          LOOP
            write_log(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH,l_error_msg_tbl(i));
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

  okl_debug_pub.logmessage('OKL_VENDOR_REFUND_PVT : GENERATE_VENDOR_REFUND : END ');

EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (OTHERS)IN OKL_CURE_CALC_PVT => '||SQLERRM);
    retcode :=2;
    errbuf :=SQLERRM;

END GENERATE_VENDOR_REFUND;

END OKL_VENDOR_REFUND_PVT;

/
