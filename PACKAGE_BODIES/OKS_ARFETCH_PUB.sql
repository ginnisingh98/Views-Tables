--------------------------------------------------------
--  DDL for Package Body OKS_ARFETCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_ARFETCH_PUB" AS
/* $Header: OKSPARGB.pls 120.2.12010000.2 2008/10/22 12:50:11 ssreekum ship $ */

--  Global constant holding the package name
	G_PKG_NAME           CONSTANT VARCHAR2(30) := 'OKS_ARFETCH_PUB';

-- Global var holding the Current Error code for the error encountered
	Current_Error_Code   Varchar2(20) := NULL;

-- Global var holding the User Id
	user_id			NUMBER;

-- Global var to hold the ERROR value.
	ERROR			 NUMBER := 1;

-- Global var to hold the SUCCESS value.
	SUCCESS			 NUMBER := 0;

-- Global var to hold the commit size.
	COMMIT_SIZE		 NUMBER := 10;

-- Global var to hold the Concurrent Process return value
   conc_ret_code		 NUMBER := SUCCESS;


/*------------------------------------------------------------------
Concurrent Program Wrapper for AR Fetch Program
--------------------------------------------------------------------*/
PROCEDURE	ARFetch_Main
( 	ERRBUF     	OUT  NOCOPY VARCHAR2,
	RETCODE     	OUT  NOCOPY NUMBER	)
IS

CONC_STATUS		BOOLEAN;
l_return_status         VARCHAR2(10);
--l_retcode		NUMBER := SUCCESS;

BEGIN


  user_id    := FND_GLOBAL.USER_ID;
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'User_Id ='||to_char(user_id));

  OKS_ARFETCH_PUB.GET_AR_RECORD(l_return_status);
  --OKS_ARFETCH_PUB.GET_AR_RECORD(l_retcode);

  --l_retcode := SUCCESS;

  IF (l_return_status = 'S') THEN
	FND_FILE.PUT_LINE( FND_FILE.LOG,
		'ARFetch_Main IS successfully completed');
  ELSE
	FND_FILE.PUT_LINE( FND_FILE.LOG,
		'ARFetch_Main is NOT successfully completed' );
  END IF;


 --FND_FILE.PUT_LINE (FND_FILE.LOG,'RETCODE = ' || to_char(l_retcode));

  COMMIT;

  IF (conc_ret_code = SUCCESS) THEN
	RETCODE := 0;
  ELSE
	RETCODE := 1;
  END IF;


EXCEPTION

WHEN UTL_FILE.INVALID_PATH THEN
	--DBMS_OUTPUT.PUT_LINE ('FILE LOCATION OR NAME WAS INVALID');
	null;
WHEN UTL_FILE.INVALID_MODE THEN
	--DBMS_OUTPUT.PUT_LINE ('FILE OPEN MODE STRING WAS INVALID');
	null;
WHEN UTL_FILE.INVALID_FILEHANDLE THEN
	--DBMS_OUTPUT.PUT_LINE ('FILE HANDLE WAS INVALID');
	null;
WHEN UTL_FILE.INVALID_OPERATION THEN
	--DBMS_OUTPUT.PUT_LINE ('FILE IS NOT OPEN FOR WRITTING');
	null;
WHEN UTL_FILE.WRITE_ERROR THEN
	--DBMS_OUTPUT.PUT_LINE ('OS ERROR OCCURRED DURING WRITE OPERATION');
	null;

End ARFetch_Main;


---------------------------------------------------------------------------
-- PROCEDURE GET_AR_RECORD
---------------------------------------------------------------------------
PROCEDURE Get_AR_RECORD ( x_return_status OUT NOCOPY VARCHAR2) AS

TYPE btl_record IS RECORD
(txn_lines_id              NUMBER,
 bill_instance_number      NUMBER,
 btn_id                    NUMBER,
 bcl_id                    NUMBER,
 bsl_id                    NUMBER,
 trx_amount                NUMBER);

TYPE btl_tbl IS TABLE OF btl_record index by binary_integer;

 type l_number_tbl is table of number index by binary_integer ;
 type l_varchar2_tbl is table of varchar2(120) index by binary_integer;
 type l_date_tbl is table of date index by binary_integer;

 l_txn_id               l_number_tbl;
 l_txn_lines_id         l_number_tbl;
 l_bill_instance_number l_number_tbl;
 l_btn_id               l_number_tbl;
 l_bcl_id               l_number_tbl;
 l_bsl_id               l_number_tbl;
 l_split_flag           l_varchar2_tbl;
 l_Contract_number      l_varchar2_tbl;
 l_Contract_number_modifier l_varchar2_tbl;
 l_last_update_date     l_date_tbl;
 l_hdr_id               l_number_tbl;
 l_trx_number           l_varchar2_tbl;
 l_customer_trx_line_id l_number_tbl;
 l_customer_trx_id      l_number_tbl;
 l_extended_amount      l_number_tbl;
 l_type                 l_varchar2_tbl;
 l_trx_date             l_date_tbl;
 l_hdr_id_tmp           l_number_tbl;
 l_currency_code        l_varchar2_tbl;

 --Added leading, use_hash and swap_join_inputs along with the paralle.
 --Also changed the order of FROM clause
 --Above two changes were did for bug fix 5903326(FP bug for 5882789)
 --SQL has been modified after talking to performance team.
 --So Do not change the order of the from clause and the hints.

 --This FP fix is slightly different than the 11.5.10 fix due to the
 --MOAC functionality. Among all the MOAC enabled tables only one is with
 --the MOAC predicate and others are with the _ALL table(this is as per MOAC standard

 Cursor get_fetch_records_csr is
 SELECT /*+ leading(BTN,BTXNL,RALINES,HDR,RAHDR) use_nl(BTXNL,HDR,RAHDR) use_hash(RATYPES) swap_join_inputs(RATYPES) parallel(RALINES) */
       btn.id txn_id
      ,btn.currency_code
      ,btxnl.id txn_lines_id
      ,btxnl.bill_instance_number bill_instance_number
      ,btxnl.btn_id btn_id
      ,btxnl.bcl_id
      ,btxnl.bsl_id
      ,btxnl.split_flag
      ,hdr.Contract_number
      ,hdr.Contract_number_modifier
      ,hdr.last_update_date
      ,hdr.id hdr_id
      ,rahdr.trx_number
      ,ralines.customer_trx_line_id
      ,ralines.customer_trx_id
      ,ralines.extended_amount
      ,ratypes.type
      ,rahdr.trx_date
  From oks_bill_transactions btn
      ,oks_bill_txn_lines btxnl
      ,RA_CUSTOMER_TRX_LINES  RALINES
      ,okc_k_headers_all_b hdr
      ,RA_CUSTOMER_TRX_ALL RAHDR
      ,RA_CUST_TRX_TYPES_ALL RATYPES
 Where btxnl.btn_id = btn.id
   And btn.trx_number    = '-99'
   AND RALINES.line_type ='LINE'
   /* Commented by sjanakir for Bug#7190512
   And RAHDR.interface_header_attribute1 = hdr.contract_number
   And RAHDR.interface_header_attribute2 = NVL(hdr.contract_number_modifier,'-') */
   And RALINES.interface_line_attribute1 = hdr.contract_number
   And RALINES.interface_line_attribute2 = NVL(hdr.contract_number_modifier,'-')
   And RALINES.interface_line_attribute3 = to_char(btxnl.bill_instance_number)
   And RAHDR.customer_trx_id = RALINES.customer_trx_id
   And RATYPES.cust_trx_type_id = RAHDR.cust_trx_type_id
   And RALINES.interface_line_context = 'OKS CONTRACTS'
   And ralines.org_id = HDR.org_id
   And ralines.org_id = RAHDR.org_id
   And ralines.org_id = RATYPES.org_id
 ORDER BY btxnl.bill_instance_number ;

---DON'T REMOVE ORDER BY CLAUSE added for bug#4089706

 Cursor l_hdr_csr is
 Select distinct hdr_id
  From oks_ar_fetch_temp;

 CURSOR l_btl_csr(p_bill_instance_num   NUMBER) IS
  SELECT id txn_lines_id
        ,bill_instance_number
        ,btn_id
        ,bcl_id
        ,bsl_id
        ,trx_amount
   FROM oks_bill_txn_lines
  WHERE bill_instance_number = p_bill_instance_num;

CURSOR l_ra_tax_csr(p_id  NUMBER) IS
  SELECT nvl(sum(ctl.extended_amount),0 )
  FROM RA_CUSTOMER_TRX_LINES_ALL CTL
  WHERE CTL.LINK_TO_CUST_TRX_LINE_ID = p_id
  AND CTL.line_type = 'TAX';



l_btl_rec              l_btl_csr%ROWTYPE;
l_btl_tbl              btl_tbl;
l_tot_tax_amt          NUMBER;
l_remaining_trx_amt    NUMBER;
l_remaining_tax_amt    NUMBER;
l_line_trx_amt         NUMBER;
l_line_tax_amt         NUMBER;
l_total_amt            NUMBER;
l_index                NUMBER;
l_previous_btn         NUMBER;



 l_ret_stat           VARCHAR2(20);
 l_msg_cnt            NUMBER;
 l_msg_data           VARCHAR2(2000);

 l_cvmv_rec           OKC_CVM_PVT.cvmv_rec_type ;
 l_cvmv_out_rec       OKC_CVM_PVT.cvmv_rec_type ;

BEGIN
  DBMS_TRANSACTION.SAVEPOINT('BEFORE_TRANSACTION');
  x_return_status := 'S';
  Open get_fetch_records_csr;
  Loop
      Fetch get_fetch_records_csr bulk collect into l_txn_id
                                                   ,l_currency_code
                                                   ,l_txn_lines_id
                                                   ,l_bill_instance_number
                                                   ,l_btn_id
                                                   ,l_bcl_id
                                                   ,l_bsl_id
                                                   ,l_split_flag
                                                   ,l_Contract_number
                                                   ,l_Contract_number_modifier
                                                   ,l_last_update_date
                                                   ,l_hdr_id
                                                   ,l_trx_number
                                                   ,l_customer_trx_line_id
                                                   ,l_customer_trx_id
                                                   ,l_extended_amount
                                                   ,l_type
                                                   ,l_trx_date limit 1000;
      If l_txn_id.COUNT > 0 then
         Begin
           forall i in l_txn_id.FIRST..l_txn_id.LAST
	         update oks_bill_transactions
                 set trx_date   = l_trx_date(i)
                    ,trx_number = l_trx_number(i)
                    ,trx_amount = nvl(trx_amount,0) + l_extended_amount(i)
                    ,trx_class  = l_type(i)
                    ,last_updated_by  = user_id
                    ,last_update_date = sysdate
               where id = l_txn_id(i);
         Exception
	    When others then
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Update failed on OKS_BILL_TRANSACTIONS , SQLERRM = '|| SQLERRM);
            Raise;
         End;

         BEGIN
           FOR i in l_txn_lines_id.FIRST..l_txn_lines_id.LAST
           LOOP
             /*****chk the split flag ,if null just update as usual else if 'P' then
              retrieve all records from btl with same bill_instance_number and prorate the tax and inv amt.
             *******/

              IF l_split_flag(i) IS NULL THEN

                /*******Added for P1 bug#4089706. chk previous bill_instance_number if not same then
                     update trx_line_amt and tax_amt to 0 so that for the price break records
                     amt can be added.But later on we have to identify these records******/

                 IF l_txn_lines_id(i) <> nvl(l_previous_btn,0) then

                   UPDATE oks_bill_txn_lines
                   SET trx_line_tax_amount = 0
                    ,trx_amount = 0
                    ,trx_line_amount = 0
                   WHERE id = l_txn_lines_id(i);
                 END IF;

                 /***taking tax amt from cursor because of P1 bug#4125597.
                  before it been added directly from sql in update statment****/

                 l_tot_tax_amt := 0;

                 ---find the tax amt
                 OPEN l_ra_tax_csr(l_customer_trx_line_id(i));
                 FETCH l_ra_tax_csr INTO l_tot_tax_amt;
                 CLOSE l_ra_tax_csr;

                 UPDATE oks_bill_txn_lines
                 SET trx_class  = l_type(i)
                    ,trx_number = l_trx_number(i)
                    ,trx_date   = l_trx_date(i)
                    ,trx_line_tax_amount = nvl(trx_line_tax_amount,0) + nvl(l_tot_tax_amt,0)
                    ,trx_amount = nvl(trx_amount,0) + l_extended_amount(i)
                    ,trx_line_amount = nvl(trx_line_amount,0) + l_extended_amount(i)
                    ,last_updated_by  = user_id
	            ,last_update_date = sysdate
                WHERE id = l_txn_lines_id(i);

                l_previous_btn := l_txn_lines_id(i);

              ELSIF l_split_flag(i) = 'P' THEN
                ---Logic to update all records in btl with same bill_instance_number in loop

                l_total_amt := 0;
                l_tot_tax_amt := 0;

                ---find the tax amt
                OPEN l_ra_tax_csr(l_customer_trx_line_id(i));
                FETCH l_ra_tax_csr INTO l_tot_tax_amt;
                CLOSE l_ra_tax_csr;

                l_btl_tbl.DELETE;
                l_index := 1;

                FOR l_btl_rec IN l_btl_csr(l_bill_instance_number(i))
                LOOP

                  l_btl_tbl(l_index).txn_lines_id          := l_btl_rec.txn_lines_id;
                  l_btl_tbl(l_index).bill_instance_number  := l_btl_rec.bill_instance_number;
                  l_btl_tbl(l_index).btn_id                := l_btl_rec.btn_id ;
                  l_btl_tbl(l_index).bcl_id                := l_btl_rec.bcl_id ;
                  l_btl_tbl(l_index).bsl_id                := l_btl_rec.bsl_id ;
                  l_btl_tbl(l_index).trx_amount            := l_btl_rec.trx_amount;


                  l_total_amt := NVL( l_total_amt,0) +  l_btl_tbl(l_index).trx_amount;
                  l_index := l_index + 1;
                END LOOP;

                l_remaining_trx_amt := NVL(l_extended_amount(i),0);
                l_remaining_tax_amt := NVL(l_tot_tax_amt,0) ;

                IF l_btl_tbl.COUNT > 0 THEN

                  FOR l_index IN l_btl_tbl.FIRST .. l_btl_tbl.LAST
                  LOOP

                    IF l_index = l_btl_tbl.LAST THEN
                       l_line_trx_amt       := l_remaining_trx_amt;
                       l_line_tax_amt       := l_remaining_tax_amt;
                    ELSE         ---not last one

                      IF l_total_amt = 0 THEN
                        l_line_trx_amt := 0;
                        l_line_tax_amt := 0;
                      ELSE

                        l_line_trx_amt := OKS_EXTWAR_UTIL_PVT.round_currency_amt(
                                          (l_extended_amount(i)/l_total_amt) * l_btl_tbl(l_index).trx_amount,
                                          l_currency_code(i)) ;

                        l_line_tax_amt := OKS_EXTWAR_UTIL_PVT.round_currency_amt(
                                          (l_tot_tax_amt/l_total_amt) * l_btl_tbl(l_index).trx_amount,
                                          l_currency_code(i)) ;
                      END IF;
                      l_remaining_trx_amt := NVL(l_remaining_trx_amt,0) -  NVL(l_line_trx_amt,0);
                      l_remaining_tax_amt := NVL(l_remaining_tax_amt,0) -  NVL(l_line_tax_amt,0);
                    END IF;            ---last index chk



                     UPDATE oks_bill_txn_lines
                     SET trx_class  = l_type(i)
                        ,trx_number = l_trx_number(i)
                        ,trx_date   = l_trx_date(i)
                        ,trx_amount = l_line_trx_amt
                        ,trx_line_amount = l_line_trx_amt
                        ,trx_line_tax_amount = l_line_tax_amt
                        ,last_updated_by  = user_id
	                ,last_update_date = sysdate
                     WHERE id = l_btl_tbl(l_index).txn_lines_id;

                   END LOOP;             ---l_btl_tbl loop
                 END IF;            ---l_btl_tbl count chk

              END IF;        ---split_flag chk
           END LOOP;           ----end loop for l_txn_lines_id tbl



         EXCEPTION
	    WHEN OTHERS THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Update failed on OKS_BILL_TXN_LINES , SQLERRM = '|| SQLERRM);
            Raise;
         END;

         Begin
	      forall k in l_hdr_id.FIRST..l_hdr_id.LAST
		   insert into oks_ar_fetch_temp o
		          ( hdr_id )
             values ( l_hdr_id(k));
         Exception
	    When others then
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Insert  failed on OKS_AR_FETCH_TEMP , SQLERRM = '|| SQLERRM);
            Raise;
	    End ;
	End If;
	Exit when get_fetch_records_csr%NOTFOUND;
  End Loop;
  close get_fetch_records_csr;

  open l_hdr_csr;
  Loop
     fetch l_hdr_csr bulk collect into l_hdr_id_tmp limit 10000;
     If l_hdr_id_tmp.COUNT > 0 then
	     For i in l_hdr_id_tmp.FIRST..l_hdr_id_tmp.lAST
          Loop
            okc_cvm_pvt.g_trans_id := 'XXX';
            l_cvmv_rec.chr_id := l_hdr_id_tmp(i);
            OKC_CVM_PVT.update_contract_version( p_api_version    => 1.0,
                                                 p_init_msg_list  => 'T',
                                                 x_return_status  => l_ret_stat,
                                                 x_msg_count      => l_msg_cnt,
                                                 x_msg_data       => l_msg_data,
                                                 p_cvmv_rec       => l_cvmv_rec,
                                                 x_cvmv_rec       => l_cvmv_out_rec);
          End Loop;
     End If;
     Exit when l_hdr_csr%NOTFOUND;
  End loop;
  close l_hdr_csr;


EXCEPTION
  WHEN  OTHERS THEN
    x_return_status := 'E';
    DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error'||SQLCODE || '- '||SQLERRM);
END Get_AR_RECORD;

END OKS_ARFETCH_PUB;

/
