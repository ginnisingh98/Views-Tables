--------------------------------------------------------
--  DDL for Package Body OKS_CCMIGRATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_CCMIGRATE_PVT" AS
 /* $Header: OKSCMIGB.pls 120.9 2006/06/28 23:51:40 hvaladip noship $ */


-- Global vars to hold the min and max hdr_id for each sub-request range
 type range_rec is record (
 	lo number,
	hi number,
	jobno number);
 type rangeArray is VARRAY(100) of range_rec;
 range_arr rangeArray;
   Type l_num_tbl is table of NUMBER index  by BINARY_INTEGER ;
  Type l_date_tbl is table of DATE  index  by BINARY_INTEGER ;
  Type l_chr_tbl is table of Varchar2(4000) index  by BINARY_INTEGER ;
--------------------------------------------------------------------------------------------
--             Generate Range and Split Function.                                         --
--------------------------------------------------------------------------------------------

procedure split_range (
 p_lo number,
 p_hi number,
 p_buckets number) is
 -- splits range (p_lo=>p_hi) into p_buckets pieces and appends to VArrays.
 l_lo number := p_lo;
 l_idx1 number := range_arr.count + 1;
 l_idx2 number := range_arr.count + p_buckets;
 l_bucket_width integer;
begin
  FND_FILE.PUT_LINE (FND_FILE.LOG, 'p_lo = '||p_lo );
  FND_FILE.PUT_LINE (FND_FILE.LOG, 'p_hi = '||p_hi );
  FND_FILE.PUT_LINE (FND_FILE.LOG, 'p_buckets = '||p_buckets );

  If p_buckets = 0 then
     return;
  End if;
  if range_arr.count > 0 then
     -- so we don't overlap high value of previous range
     l_lo := p_lo + 1;
  end if;

  l_bucket_width := (p_hi - l_lo) / p_buckets;

  range_arr.extend(p_buckets);

  for idx in l_idx1..l_idx2 loop
      range_arr(idx).lo := l_lo + ((idx - l_idx1) * l_bucket_width);
      if idx < l_idx2 then
	 range_arr(idx).hi := range_arr(idx).lo + l_bucket_width -1;
      else
	range_arr(idx).hi := p_hi;
      end if;
  end loop;
end split_range;

function generate_ranges (
     p_lo  IN number,
     p_hi  IN number,
     p_avg In number,
     p_stddev IN number,
     p_total  IN number,
     p_sub_requests IN number) return integer is

 l_total_buckets integer := 0;
 l_stdlo number := greatest(round(p_avg - p_stddev), p_lo);
 l_stdhi number := least(round(p_avg + p_stddev), p_hi);
 l_stddev_percent number   := 0.66;  -- the area covered by +/-1 stddev


 l_outlier_buckets integer := 0;
 l_std_buckets integer     := 0;
 l_lo_buckets integer      := 0;
 l_hi_buckets integer      := 0;
 l_outlier_entries_per_bucket number := 0;
 modidx integer;
begin
  range_arr := rangeArray();

  --l_total_buckets := greatest(nvl(p_sub_requests,3), least(p_total/MAX_SINGLE_REQUEST, MAX_JOBS));
    l_total_buckets := greatest(p_sub_requests,2);
  l_outlier_buckets := l_total_buckets * (1 - l_stddev_percent);
  if l_outlier_buckets > 0 then
     l_outlier_entries_per_bucket := p_total * (1 - l_stddev_percent)
                                                  / l_outlier_buckets ;
  end if;

  for idx in 1..l_outlier_buckets
  loop
       modidx := mod(idx,2);
       -- alternate assignment between hi and lo buckets
       if modidx = 1
          AND (p_hi - (l_hi_buckets+1) * l_outlier_entries_per_bucket)
          > l_stdhi then
               -- allocate buckets for positive outliers
               l_hi_buckets := l_hi_buckets + 1;
       elsif modidx = 0
          AND (p_lo + (l_lo_buckets+1) * l_outlier_entries_per_bucket)
          < l_stdlo then
               -- allocate buckets for negative outliers
               l_lo_buckets := l_lo_buckets + 1;
          -- else min or max has been consumed, save bucket for middle
      end if;
  end loop;

  -- compute middle buckets
  l_std_buckets := l_total_buckets - l_lo_buckets - l_hi_buckets;

  -- in case low-high allocations yielded zero buckets.
  -- i.e., outliers were folded into middle buckets.
  if l_lo_buckets = 0 then
       l_stdlo := p_lo;
  end if;
  if l_hi_buckets = 0 then
       l_stdhi := p_hi;
  end if;

  -- ranges for negative outliers
  split_range(p_lo, l_stdlo, l_lo_buckets);
  -- ranges for +/-1 stddev from mean
  split_range(l_stdlo, l_stdhi, l_std_buckets);
  -- ranges for positive outliers
  split_range(l_stdhi, p_hi, l_hi_buckets);

  return l_total_buckets;
end generate_ranges;

PROCEDURE MIGRATE_CC (
    ERRBUF            OUT  NOCOPY VARCHAR2,
    RETCODE           OUT  NOCOPY NUMBER,
    P_SUB_REQUESTS    IN NUMBER,
    P_BATCH_SIZE      IN NUMBER ) IS

cursor l_hdr_ranges(l_bucket_size number) is
   SELECT /*+ parallel(WBR) */
            WB_Low
            ,WB_High,rownum num
      FROM
      (SELECT /*+ no_merge parallel(WB) */ MIN(ID) WB_Low, MAX(ID) WB_High
         FROM
           (SELECT /*+ no_merge parallel(khdr) */ ID, FLOOR((ROWNUM-1)/l_bucket_size) Worker_Bucket
            FROM
			 ( SELECT id
			    FROM oks_k_headers_b okshdr
			    WHERE okshdr.cc_no IS NOT NULL
			     AND okshdr.payment_type = 'CCR'
			     AND okshdr.trxn_extension_id is null
			     order by id) KHDR) WB GROUP BY Worker_Bucket) WBR;

cursor l_line_ranges(l_bucket_size number) is
   SELECT /*+ parallel(WBR) */
            WB_Low
            ,WB_High,rownum num
      FROM
      (SELECT /*+ no_merge parallel(WB) */ MIN(ID) WB_Low, MAX(ID) WB_High
         FROM
           (SELECT /*+ no_merge parallel(kln) */ ID, FLOOR((ROWNUM-1)/l_bucket_size) Worker_Bucket
            FROM
			 ( SELECT oksline.id
			    FROM oks_k_lines_b oksline, okc_k_lines_b okcline
			    WHERE oksline.cle_id=okcline.id
                and oksline.cc_no IS NOT NULL
			     AND oksline.payment_type = 'CCR'
			     AND oksline.trxn_extension_id is null
			     and okcline.lse_id in (1,12,19,46)
			     order by id) KLN) WB GROUP BY Worker_Bucket) WBR;

Cursor l_hdr_agg_csr1 IS

  Select /*+ PARALLEL(okshdr) */
         min(okshdr.id) minid,
         max(okshdr.id) maxid,
         avg(okshdr.id) avgid,
         stddev(okshdr.id) stdid,
         count(*) total
    From OKS_K_HEADERS_B okshdr ;
Cursor l_hdr_agg_csr2 IS

  Select /*+ PARALLEL(okshdrh) */
         min(okshdrh.id) minid,
         max(okshdrh.id) maxid,
         avg(okshdrh.id) avgid,
         stddev(okshdrh.id) stdid,
         count(*) total
    From OKS_K_HEADERS_BH okshdrh ;

    Cursor l_line_agg_csr1 IS
  Select /*+ PARALLEL(oksline) */
         min(oksline.id) minid,
         max(oksline.id) maxid,
         avg(oksline.id) avgid,
         stddev(oksline.id) stdid,
         count(*) total
    From OKS_K_LINES_B oksline ;

Cursor l_line_agg_csr2 IS
  Select /*+ PARALLEL(okslineh) */
         min(okslineh.id) minid,
         max(okslineh.id) maxid,
         avg(okslineh.id) avgid,
         stddev(okslineh.id) stdid,
         count(*) total
    From OKS_K_LINES_BH okslineh ;

l_agg_rec l_line_agg_csr2%rowtype;
l_sub_requests number;
l_sub_req number;
l_batch_size   number;
l_ret number;

BEGIN

FND_FILE.PUT_LINE (FND_FILE.LOG, 'Start of migrate_cc'||P_SUB_REQUESTS||p_batch_size);

     IF P_SUB_REQUESTS IS NULL OR P_SUB_REQUESTS > 30 OR P_SUB_REQUESTS = 0 then
       l_sub_requests := 30 ;
     ELSE
       l_sub_requests := p_sub_requests ;
     END IF;

     IF p_batch_size is null or p_batch_size > 10000 or p_batch_size = 0 then
       l_batch_size := 10000;
     ELSE
       l_batch_size := p_batch_size;
     END IF;


 -----------------------------------------------------------------------------------------
   IF (FND_CONC_GLOBAL.request_data is null)  THEN
         -- The following csr is on OKS_K_HDRS_BH
            open  l_hdr_agg_csr2;
            fetch l_hdr_agg_csr2 into l_agg_rec;
            close l_hdr_agg_csr2;

            FND_FILE.PUT_LINE (FND_FILE.LOG, 'Cursor opened is l_hdr_agg_csr2' );
            FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_agg_rec.minid = '|| l_agg_rec.minid );
            FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_agg_rec.maxid = '|| l_agg_rec.maxid );
            FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_agg_rec.total = '|| l_agg_rec.total );



       l_ret := FND_REQUEST.submit_request('OKS',
                                             'OKS_MIGCC_HDRH',
                                              to_char(l_sub_requests), -- UI job display
                                              null,
                                              TRUE, -- TRUE means isSubRequest
                                              l_agg_rec.minid,
                                              l_agg_rec.maxid,nvl(l_batch_size,10000));

       IF (l_ret = 0) then
             errbuf := fnd_message.get;
             retcode := 2;
             FND_FILE.PUT_LINE (FND_FILE.LOG, 'Sub-request failed to submit: ' || errbuf);
             return;
       ELSE
             FND_FILE.PUT_LINE (FND_FILE.LOG, 'Sub-request '||to_char(l_ret)||' submitted');
             FND_FILE.PUT_LINE (FND_FILE.LOG, 'Sub-request '||to_char(l_ret)||' p_low_id ==> '|| l_agg_rec.minid || ' l_hig_id ==> '||l_agg_rec.maxid );
       END IF;



--    The following csr is on OKS_K_LINES_BH
            open  l_line_agg_csr2;
            fetch l_line_agg_csr2 into l_agg_rec;
            close l_line_agg_csr2;

            FND_FILE.PUT_LINE (FND_FILE.LOG, 'Cursor opened is l_line_agg_csr2' );
            FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_agg_rec.minid = '|| l_agg_rec.minid );
            FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_agg_rec.maxid = '|| l_agg_rec.maxid );
            FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_agg_rec.total = '|| l_agg_rec.total );



       l_ret := FND_REQUEST.submit_request  ('OKS',
                                             'OKS_MIGCC_LINH',
                                              to_char(l_sub_requests), -- UI job display
                                              null,
                                              TRUE, -- TRUE means isSubRequest
                                              l_agg_rec.minid,
                                              l_agg_rec.maxid,nvl(l_batch_size,10000));

       IF (l_ret = 0) then
             errbuf := fnd_message.get;
             retcode := 2;
             FND_FILE.PUT_LINE (FND_FILE.LOG, 'Sub-request Line History failed to submit: ' || errbuf);
             return;
       ELSE
             FND_FILE.PUT_LINE (FND_FILE.LOG, 'Sub-request '||to_char(l_ret)||' submitted');
             FND_FILE.PUT_LINE (FND_FILE.LOG, 'Sub-request '||to_char(l_ret)||' p_low_id ==> '|| l_agg_rec.minid || ' l_hig_id ==> '||l_agg_rec.maxid );
       END IF;


    /*   --now process the oks_k_hdr
        open  l_hdr_agg_csr1;
        fetch l_hdr_agg_csr1 into l_agg_rec;
        close l_hdr_agg_csr1;

        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Cursor opened is l_hdr_agg_csr1' );
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_agg_rec.minid = '|| l_agg_rec.minid );
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_agg_rec.maxid = '|| l_agg_rec.maxid );
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_agg_rec.total = '|| l_agg_rec.total );
       l_sub_req := generate_ranges(l_agg_rec.minid,
                                          l_agg_rec.maxid,
                                          l_agg_rec.avgid,
                                          l_agg_rec.stdid,
                                          l_agg_rec.total,
                                          nvl(l_sub_requests-1,30));
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_sub_requests = '|| l_sub_req );

    */

         FOR range_rec in l_hdr_ranges(l_batch_size)
         LOOP
            l_ret := FND_REQUEST.submit_request('OKS',
                                               'OKS_MIGCC_HDR',
                                              to_char(range_rec.num), -- UI job display
                                              null,
                                              TRUE, -- TRUE means isSubRequest
                                              range_rec.wb_low,
                                              range_rec.wb_high,
                                              nvl(l_batch_size,10000));

           IF (l_ret = 0) then
               errbuf := fnd_message.get;
               retcode := 2;
               FND_FILE.PUT_LINE (FND_FILE.LOG, 'Sub-request failed to submit: ' || errbuf);
               return;
           ELSE
               FND_FILE.PUT_LINE (FND_FILE.LOG, 'Sub-request '||to_char(l_ret)||' submitted');
               FND_FILE.PUT_LINE (FND_FILE.LOG, 'Sub-request '||to_char(l_ret)||' p_low_id ==> '|| range_rec.wb_low || ' l_hig_id ==> '||range_rec.wb_high );
           END IF;
         END LOOP;

       --- now process the lines

/*        open  l_line_agg_csr1;
        fetch l_line_agg_csr1 into l_agg_rec;
        close l_line_agg_csr1;

        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Cursor opened is l_line_agg_csr1' );
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_agg_rec.minid = '|| l_agg_rec.minid );
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_agg_rec.maxid = '|| l_agg_rec.maxid );
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_agg_rec.total = '|| l_agg_rec.total );
       l_sub_req := generate_ranges(l_agg_rec.minid,
                                          l_agg_rec.maxid,
                                          l_agg_rec.avgid,
                                          l_agg_rec.stdid,
                                          l_agg_rec.total,
                                          nvl(l_sub_requests-1,30));
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_sub_requests = '|| l_sub_req );
*/

         FOR range_rec in l_line_ranges(l_batch_size)
         LOOP
            l_ret := FND_REQUEST.submit_request('OKS',
                                                'OKS_MIGCC_LIN',
                                                range_rec.num, -- UI job display
                                                null,
                                                TRUE, -- TRUE means isSubRequest
                                               range_rec.wb_low,
                                              range_rec.wb_high,
                                              nvl(l_batch_size,10000));

           IF (l_ret = 0) then
               errbuf := fnd_message.get;
               retcode := 2;
               FND_FILE.PUT_LINE (FND_FILE.LOG, 'Sub-request failed to submit: ' || errbuf);
               return;
           ELSE
               FND_FILE.PUT_LINE (FND_FILE.LOG, 'Sub-request '||to_char(l_ret)||' submitted');
               FND_FILE.PUT_LINE (FND_FILE.LOG, 'Sub-request '||to_char(l_ret)||' p_low_id ==> '|| range_rec.wb_low || ' l_hig_id ==> '||range_rec.wb_high );
           END IF;
         END LOOP;


         FND_CONC_GLOBAL.set_req_globals(conc_status => 'PAUSED',
                                         request_data => to_char(l_sub_requests));
             errbuf := to_char(l_sub_requests) || ' sub-requests submitted';
             retcode := 0;
          return;


  END IF;

END MIGRATE_CC;

PROCEDURE MIGRATE_CC_LINEH(
    ERRBUF            OUT  NOCOPY VARCHAR2,
    RETCODE           OUT  NOCOPY NUMBER,
    p_id_low          IN NUMBER,
    p_id_high           IN NUMBER,
    p_batchsize       IN NUMBER ) IS



  l_user_id                   NUMBER;
  c_cc_trxn_id   l_num_tbl;
  c_cc_id        l_num_tbl;
  c_cc_number    l_chr_tbl;
  c_cc_code      l_chr_tbl;
  c_cc_exp_date  l_date_tbl;
  okcline_id     l_num_tbl;
  oksline_id     l_num_tbl;
  oksline_major_version     l_num_tbl;
  okchdr_id      l_num_tbl;
  c_customer_id  l_num_tbl;
  c_cust_account_id l_num_tbl;
  c_cust_site_use_id l_num_tbl;
  c_org_id          l_num_tbl;
  c_additional_info l_chr_tbl;
  c_trxn_entity_id  l_num_tbl;
  c_instr_assignment_id l_num_tbl;
  c_ext_payer_id        l_num_tbl;
  c_create_payer_flag   l_chr_tbl;
  c_hash1               l_chr_tbl;
  c_hash2               l_chr_tbl;
  c_card_range_id       l_num_tbl;
  c_sec_segment_id      l_num_tbl;
  c_cc_num_length       l_num_tbl;
  c_cc_range_length     l_num_tbl;
  c_cc_unmask_digits    l_chr_tbl;
  c_cc_masked_num       l_chr_tbl;


  -- Cursor that queries all transactions needed to be migrated with encryption enabled

  -- Note: 1. This table is out-joined with the table IBY_EXTERNAL_PAYERS_ALL so that
  --          the party contexts that are not in the external payer table can be identified.
  --       2. The credit card number needs to be numeric.
cursor oksline_cur_sec is
      select
          oksline.id oksline_id,
          oksline.major_version oksline_major_version,
          TRANSLATE(oksline.cc_no,'0: -_', '0'),
          'UNKNOWN',
          oksline.cc_expiry_date,
          IV.hdr_id okchdr_id,
          IV.line_id okcline_id,
          IV.party_id,
          IV.cust_acct_id,
          IV.bill_to_site_use_id,
          IV.authoring_org_id,
          iby_fndcpt_tx_extensions_s.nextval,  -- the new transaction extension ID
          iby_instr_s.nextval,                 -- the new credit card id
          DECODE(PAYER.EXT_PAYER_ID, null, IBY_EXTERNAL_PAYERS_ALL_S.nextval,
                                           PAYER.EXT_PAYER_ID),
          DECODE(PAYER.EXT_PAYER_ID, null,'Y', 'N'),  -- this flag determines whether we
                                                      -- should create new external payer
          IBY_PMT_INSTR_USES_ALL_S.nextval,     -- the new instrument use id
          SEC.cc_number_hash1,
          SEC.cc_number_hash2,
          SEC.cc_issuer_range_id,
          SEC.sec_segment_id,
          SEC.cc_number_length,
          SEC.cc_unmask_digits,
          LPAD(sec.cc_unmask_digits, NVL(range.card_number_length, length(oksline.cc_no)),'X')
      from  OKS_K_LINES_BH oksline,
            (select hz.party_id, hdr.authoring_org_id, hdr.id hdr_id, line.cust_acct_id,
                    line.bill_to_site_use_id, line.id line_id
             from okc_k_lines_b line, okc_k_headers_all_b hdr, hz_cust_accounts_all hz
             where line.dnz_chr_id = hdr.id
             and   line.lse_id in (1,12,19,46)
             and   hz.cust_account_id = line.cust_acct_id) IV,
            IBY_EXTERNAL_PAYERS_ALL payer,
            IBY_SECURITY_SEGMENTS sec,
            IBY_CC_ISSUER_RANGES rangE
      where  IV.line_id = oksline.cle_id
      and    oksline.cc_no is not null
      and    oksline.payment_type = 'CCR'
      and    oksline.cc_bank_acct_id is null
      and    oksline.trxn_extension_id is null
      ---and    IV.party_id = PAYER.PARTY_ID (+)
      and    IV.cust_acct_id = PAYER.CUST_ACCOUNT_ID(+)
      and    IV.bill_to_site_use_id = PAYER.ACCT_SITE_USE_ID(+)
      ---and    IV.authoring_org_id = PAYER.ORG_ID(+)
      and   'OPERATING_UNIT' = PAYER.ORG_TYPE(+)
      and   'CUSTOMER_PAYMENT' = PAYER.PAYMENT_FUNCTION(+)
      and    sec.sec_segment_id =  IBY_CC_SECURITY_PUB.get_segment_id(oksline.cc_no)
      and    sec.CC_ISSUER_RANGE_ID = RANGE.CC_ISSUER_RANGE_ID (+)
      and    oksline.id BETWEEN p_id_low AND p_id_high;

  -- Cursor that queries all transactions needed to be migrated with encryption disable

  -- Note: 1. This table is out-joined with the table IBY_EXTERNAL_PAYERS_ALL so that
  --          the party contexts that are not in the external payer table can be identified.
  --       2. The credit card number needs to be numeric.
cursor oksline_cur is
      select
          oksline.id oksline_id,
          oksline.major_version oksline_major_version,
          TRANSLATE(oksline.cc_no,'0: -_', '0'),
          'UNKNOWN',
          oksline.cc_expiry_date,
          IV.hdr_id okchdr_id,
          IV.line_id okcline_id,
          IV.party_id,
          IV.cust_acct_id,
          IV.bill_to_site_use_id,
          IV.authoring_org_id,
          IBY_FNDCPT_TX_EXTENSIONS_S.nextval,  -- the new transaction extension ID
          IBY_INSTR_S.nextval,                 -- the new credit card id
          DECODE(PAYER.EXT_PAYER_ID, null, IBY_EXTERNAL_PAYERS_ALL_S.nextval,
                                           PAYER.EXT_PAYER_ID),
          DECODE(PAYER.EXT_PAYER_ID, null,'Y', 'N'),  -- this flag determines whether we
                                                      -- should create new external payer
          IBY_PMT_INSTR_USES_ALL_S.nextval,     -- the new instrument use id
          ----iby_fndcpt_setup_pub.get_hash(oksline.cc_no, FND_API.G_FALSE) cc_number_hash1,
          ----iby_fndcpt_setup_pub.get_hash(oksline.cc_no, FND_API.G_TRUE) cc_number_hash2,
          iby_fndcpt_setup_pub.get_hash(oksline.cc_no, 'F') cc_number_hash1,
          iby_fndcpt_setup_pub.get_hash(oksline.cc_no, 'T') cc_number_hash2,
          IBY_CC_VALIDATE.Get_CC_Issuer_Range(oksline.cc_no) cc_issuer_range_id,
          Null sec_segment_id,
          DECODE(IBY_CC_VALIDATE.Get_CC_Issuer_Range(oksline.cc_no), NULL,LENGTH(oksline.cc_no), NULL) cc_number_length,
          SUBSTR(oksline.cc_no,GREATEST(-4,-LENGTH(oksline.cc_no))) cc_unmask_digits,
          LPAD(SUBSTR(oksline.cc_no,  GREATEST(-4,-LENGTH(oksline.cc_no))),
 				       LENGTH(oksline.cc_no),
			   'X' ) masked_cc_number
      from  oks_k_lines_bh oksline,
            (select hz.party_id, hdr.authoring_org_id, hdr.id hdr_id, line.cust_acct_id,
                    line.bill_to_site_use_id, line.id line_id
             from okc_k_lines_b line, okc_k_headers_all_b hdr, hz_cust_accounts_all hz
             where line.dnz_chr_id = hdr.id
             and   line.lse_id in (1,12,19,46)
             and   hz.cust_account_id = line.cust_acct_id) IV,
            IBY_EXTERNAL_PAYERS_ALL payer
      where  IV.line_id = oksline.cle_id
      and    oksline.cc_no is not null
      and    oksline.payment_type = 'CCR'
      and    oksline.cc_bank_acct_id is null
      and    oksline.trxn_extension_id is null
      ---and    IV.party_id = PAYER.PARTY_ID (+)
      and    IV.cust_acct_id = PAYER.CUST_ACCOUNT_ID(+)
      and    IV.bill_to_site_use_id = PAYER.ACCT_SITE_USE_ID(+)
      ---and    IV.authoring_org_id = PAYER.ORG_ID(+)
      and   'OPERATING_UNIT' = PAYER.ORG_TYPE(+)
      and   'CUSTOMER_PAYMENT' = PAYER.PAYMENT_FUNCTION(+)
      and    oksline.id BETWEEN p_id_low AND p_id_high;

    l_return_status    VARCHAR2(1);
    l_msg_data         VARCHAR2(2000);
    l_msg_count        NUMBER;

BEGIN


--open the cursor and migrate the stuff

  l_user_id := NVL(fnd_global.user_id, -1);

  IF (iby_cc_security_pub.encryption_enabled()) THEN
       -- security enabled
          OPEN oksline_cur_sec;
  Else
          OPEN oksline_cur;
  End if;

  LOOP
  IF (iby_cc_security_pub.encryption_enabled()) THEN
    FETCH oksline_cur_sec BULK COLLECT INTO
    oksline_id, oksline_major_version, c_cc_number, c_cc_code, c_cc_exp_date,
    okcline_id, okchdr_id, c_customer_id, c_cust_account_id,
    c_cust_site_use_id, c_org_id, c_trxn_entity_id, c_cc_id, c_ext_payer_id,
    c_create_payer_flag, c_instr_assignment_id, c_hash1, c_hash2, c_card_range_id,
    c_sec_segment_id, c_cc_num_length, c_cc_unmask_digits, c_cc_masked_num
    limit p_batchsize;

  ELSE
          FETCH oksline_cur BULK COLLECT INTO
    oksline_id, oksline_major_version, c_cc_number, c_cc_code, c_cc_exp_date,
    okcline_id, okchdr_id, c_customer_id, c_cust_account_id,
    c_cust_site_use_id, c_org_id, c_trxn_entity_id, c_cc_id, c_ext_payer_id,
    c_create_payer_flag, c_instr_assignment_id, c_hash1, c_hash2, c_card_range_id,
    c_sec_segment_id, c_cc_num_length, c_cc_unmask_digits, c_cc_masked_num
    limit p_batchsize;

   END IF;


   EXIT WHEN c_trxn_entity_id.count = 0 ;

   IF c_trxn_entity_id.count > 0 Then

    FND_FILE.PUT_LINE (FND_FILE.LOG, 'count  = '||c_trxn_entity_id.count );
    -- create new credit cards with single use only
   Begin

    FORALL i IN  c_trxn_entity_id.first..c_trxn_entity_id.last
    INSERT INTO  IBY_CREDITCARD
       (CARD_OWNER_ID,
	INSTRUMENT_TYPE,
	PURCHASECARD_FLAG,
	CARD_ISSUER_CODE,
	ACTIVE_FLAG,
	SINGLE_USE_FLAG,
	EXPIRYDATE,
	CHNAME,
	CCNUMBER,
	INSTRID,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
        ENCRYPTED,
        CC_NUMBER_HASH1,
        CC_NUMBER_HASH2,
        CC_ISSUER_RANGE_ID,
        CC_NUM_SEC_SEGMENT_ID,
        CARD_MASK_SETTING,
        CARD_UNMASK_LENGTH,
        CC_NUMBER_LENGTH,
        MASKED_CC_NUMBER,
        OBJECT_VERSION_NUMBER

 )
    VALUES(
        c_customer_id(i),
        'CREDITCARD',
        'N',
        c_cc_code(i),
        'Y',
        'Y',
        c_cc_exp_date(i),
        null,
        DECODE(c_sec_segment_id(i), NULL,c_cc_number(i), c_cc_unmask_digits(i)),
        c_cc_id(i),
        l_user_id,
	 sysdate,
	 l_user_id,
	 sysdate,
        l_user_id,
        DECODE(c_sec_segment_id(i), NULL,'N','Y'),
        c_hash1(i),
        c_hash2(i),
        c_card_range_id(i),
        c_sec_segment_id(i),
       'DISPLAY_LAST',
         4,
         c_cc_num_length(i),
         c_cc_masked_num(i),
         1
);

        -- Now insert into the instrument use table

    FORALL i IN  c_trxn_entity_id.first..c_trxn_entity_id.last
    INSERT INTO  IBY_PMT_INSTR_USES_ALL
        (INSTRUMENT_PAYMENT_USE_ID,
	EXT_PMT_PARTY_ID,
	INSTRUMENT_TYPE,
	INSTRUMENT_ID,
	PAYMENT_FUNCTION,
	PAYMENT_FLOW,
	ORDER_OF_PREFERENCE,
	START_DATE,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
        object_version_number)
     SELECT
        c_instr_assignment_id(i),
        EXT_PAYER_ID,
        'CREDITCARD',
        c_cc_id(i),
        'CUSTOMER_PAYMENT',
        'FUNDS_CAPTURE',
        1,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        1
	FROM IBY_EXTERNAL_PAYERS_ALL payer
	WHERE  payer.PAYMENT_FUNCTION = 'CUSTOMER_PAYMENT'
	AND    payer.PARTY_ID = c_customer_id(i)
	AND    payer.ORG_TYPE = 'OPERATING_UNIT'
	AND    payer.ORG_ID = c_org_id(i)
	AND    payer.CUST_ACCOUNT_ID = c_cust_account_id(i)
	AND    payer.ACCT_SITE_USE_ID = c_cust_site_use_id(i)
	AND    ROWNUM = 1;


    -- insert the transactions into IBY transaction extension table
    FORALL i IN  c_trxn_entity_id.first..c_trxn_entity_id.last
    INSERT INTO  IBY_FNDCPT_TX_EXTENSIONS
       (TRXN_EXTENSION_ID,
	PAYMENT_CHANNEL_CODE,
	INSTR_ASSIGNMENT_ID,
        ENCRYPTED,
        ORIGIN_APPLICATION_ID,
	ORDER_ID,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
	OBJECT_VERSION_NUMBER)
    VALUES
       (c_trxn_entity_id(i),
        'CREDIT_CARD',
        c_instr_assignment_id(i),
        'N',
        515,
        oksline_id(i),
        l_user_id,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        1);

 -- update the foreign key relationship

      FORALL i in c_trxn_entity_id.first..c_trxn_entity_id.last
      UPDATE oks_k_lines_bh
      SET    TRXN_EXTENSION_ID = c_trxn_entity_id(i)
      WHERE  id = oksline_id(i)
      AND    major_version = oksline_major_version(i);

   Exception
     WHEN OTHERS THEN
       FND_FILE.PUT_LINE (FND_FILE.LOG, 'error in line history  '||sqlerrm );
       For i IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
               insert into  oks_rule_error( chr_id,
                    cle_id , attribute_name, attribute_value,
                    major_version, rule_information_category )
	       values (okchdr_id(i), okcline_id(i), 'CC_NO', c_cc_number(i),
                       oksline_major_version(i), 'R12CC');
       End Loop;

   End;

   End If; ----IF c_trxn_entity_id.count > 0 Then

  COMMIT;
    oksline_id.delete;
    oksline_major_version.delete;
    c_cc_number.delete;
    c_cc_code.delete;
    c_cc_exp_date.delete;
    okcline_id.delete;
    okchdr_id.delete;
    c_customer_id.delete;
    c_cust_account_id.delete;
    c_cust_site_use_id.delete;
    c_org_id.delete;
    c_trxn_entity_id.delete;
    c_cc_id.delete;
    c_ext_payer_id.delete;
    c_create_payer_flag.delete;
    c_instr_assignment_id.delete;
    c_hash1.delete;
    c_hash2.delete;
    c_card_range_id.delete;
    c_sec_segment_id.delete;
    c_cc_num_length.delete;
    c_cc_unmask_digits.delete;
    c_cc_masked_num.delete;

  END LOOP;

  IF (iby_cc_security_pub.encryption_enabled()) THEN
    CLOSE oksline_cur_sec;
  ELSE
     CLOSE oksline_cur;
  End if;

  COMMIT;
    ----
  Exception
      when others Then
       FND_FILE.PUT_LINE (FND_FILE.LOG, 'main error line history'||sqlerrm );
       null;

END MIGRATE_CC_LINEH;

PROCEDURE MIGRATE_CC_LINE(
    ERRBUF            OUT  NOCOPY VARCHAR2,
    RETCODE           OUT  NOCOPY NUMBER,
    p_id_low          IN NUMBER,
    p_id_high           IN NUMBER,
    p_batchsize       IN NUMBER) IS

  l_user_id                   NUMBER;
  c_cc_trxn_id   l_num_tbl;
  c_cc_id        l_num_tbl;
  c_cc_number    l_chr_tbl;
  c_cc_code      l_chr_tbl;
  c_cc_exp_date  l_date_tbl;
  okcline_id     l_num_tbl;
  oksline_id     l_num_tbl;
  okchdr_id      l_num_tbl;
  c_customer_id  l_num_tbl;
  c_cust_account_id l_num_tbl;
  c_cust_site_use_id l_num_tbl;
  c_org_id          l_num_tbl;
  c_additional_info l_chr_tbl;
  c_trxn_entity_id  l_num_tbl;
  c_instr_assignment_id l_num_tbl;
  c_ext_payer_id        l_num_tbl;
  c_create_payer_flag   l_chr_tbl;
  c_hash1               l_chr_tbl;
  c_hash2               l_chr_tbl;
  c_card_range_id       l_num_tbl;
  c_sec_segment_id      l_num_tbl;
  c_cc_num_length       l_num_tbl;
  c_cc_range_length     l_num_tbl;
  c_cc_unmask_digits    l_chr_tbl;
  c_cc_masked_num       l_chr_tbl;


  -- Cursor that queries all transactions needed to be migrated with encryption enabled

  -- Note: 1. This table is out-joined with the table IBY_EXTERNAL_PAYERS_ALL so that
  --          the party contexts that are not in the external payer table can be identified.
  --       2. The credit card number needs to be numeric.
cursor oksline_cur_sec is
      select
          oksline.id oksline_id,
          TRANSLATE(oksline.cc_no,'0: -_', '0'),
          'UNKNOWN',
          oksline.cc_expiry_date,
          IV.hdr_id okchdr_id,
          IV.line_id okcline_id,
          IV.party_id,
          IV.cust_acct_id,
          IV.bill_to_site_use_id,
          IV.authoring_org_id,
          iby_fndcpt_tx_extensions_s.nextval,  -- the new transaction extension ID
          iby_instr_s.nextval,                 -- the new credit card id
          DECODE(PAYER.EXT_PAYER_ID, null, IBY_EXTERNAL_PAYERS_ALL_S.nextval,
                                           PAYER.EXT_PAYER_ID),
          DECODE(PAYER.EXT_PAYER_ID, null,'Y', 'N'),  -- this flag determines whether we
                                                      -- should create new external payer
          IBY_PMT_INSTR_USES_ALL_S.nextval,     -- the new instrument use id
          SEC.cc_number_hash1,
          SEC.cc_number_hash2,
          SEC.cc_issuer_range_id,
          SEC.sec_segment_id,
          SEC.cc_number_length,
          SEC.cc_unmask_digits,
          LPAD(sec.cc_unmask_digits, NVL(range.card_number_length, length(oksline.cc_no)),'X')
      from  OKS_K_LINES_B oksline,
            (select hz.party_id, hdr.authoring_org_id, hdr.id hdr_id, line.cust_acct_id,
                    line.bill_to_site_use_id, line.id line_id
             from okc_k_lines_b line, okc_k_headers_all_b hdr, hz_cust_accounts_all hz
             where line.dnz_chr_id = hdr.id
             and   line.lse_id in (1,12,19,46)
             and   hz.cust_account_id = line.cust_acct_id) IV,
            IBY_EXTERNAL_PAYERS_ALL payer,
            IBY_SECURITY_SEGMENTS sec,
            IBY_CC_ISSUER_RANGES rangE
      where  IV.line_id = oksline.cle_id
      and    oksline.cc_no is not null
      and    oksline.payment_type = 'CCR'
      and    oksline.cc_bank_acct_id is null
      and    oksline.trxn_extension_id is null
      ---and    IV.party_id = PAYER.PARTY_ID (+)
      and    IV.cust_acct_id = PAYER.CUST_ACCOUNT_ID(+)
      and    IV.bill_to_site_use_id = PAYER.ACCT_SITE_USE_ID(+)
      ---and    IV.authoring_org_id = PAYER.ORG_ID(+)
      and   'OPERATING_UNIT' = PAYER.ORG_TYPE(+)
      and   'CUSTOMER_PAYMENT' = PAYER.PAYMENT_FUNCTION(+)
      and    sec.sec_segment_id =  IBY_CC_SECURITY_PUB.get_segment_id(oksline.cc_no)
      and    sec.CC_ISSUER_RANGE_ID = RANGE.CC_ISSUER_RANGE_ID (+)
      and    oksline.id BETWEEN p_id_low AND p_id_high;

  -- Cursor that queries all transactions needed to be migrated with encryption disable

  -- Note: 1. This table is out-joined with the table IBY_EXTERNAL_PAYERS_ALL so that
  --          the party contexts that are not in the external payer table can be identified.
  --       2. The credit card number needs to be numeric.
cursor oksline_cur is
      select
          oksline.id oksline_id,
          TRANSLATE(oksline.cc_no,'0: -_', '0'),
          'UNKNOWN',
          oksline.cc_expiry_date,
          IV.hdr_id okchdr_id,
          IV.line_id okcline_id,
          IV.party_id,
          IV.cust_acct_id,
          IV.bill_to_site_use_id,
          IV.authoring_org_id,
          IBY_FNDCPT_TX_EXTENSIONS_S.nextval,  -- the new transaction extension ID
          IBY_INSTR_S.nextval,                 -- the new credit card id
          DECODE(PAYER.EXT_PAYER_ID, null, IBY_EXTERNAL_PAYERS_ALL_S.nextval,
                                           PAYER.EXT_PAYER_ID),
          DECODE(PAYER.EXT_PAYER_ID, null,'Y', 'N'),  -- this flag determines whether we
                                                      -- should create new external payer
          IBY_PMT_INSTR_USES_ALL_S.nextval,     -- the new instrument use id
          ----iby_fndcpt_setup_pub.get_hash(oksline.cc_no, FND_API.G_FALSE) cc_number_hash1,
          ----iby_fndcpt_setup_pub.get_hash(oksline.cc_no, FND_API.G_TRUE) cc_number_hash2,
          iby_fndcpt_setup_pub.get_hash(oksline.cc_no, 'F') cc_number_hash1,
          iby_fndcpt_setup_pub.get_hash(oksline.cc_no, 'T') cc_number_hash2,
          IBY_CC_VALIDATE.Get_CC_Issuer_Range(oksline.cc_no) cc_issuer_range_id,
          Null sec_segment_id,
          DECODE(IBY_CC_VALIDATE.Get_CC_Issuer_Range(oksline.cc_no), NULL,LENGTH(oksline.cc_no), NULL) cc_number_length,
          SUBSTR(oksline.cc_no,GREATEST(-4,-LENGTH(oksline.cc_no))) cc_unmask_digits,
          LPAD(SUBSTR(oksline.cc_no,  GREATEST(-4,-LENGTH(oksline.cc_no))),
 				       LENGTH(oksline.cc_no),
			   'X' ) masked_cc_number
      from  oks_k_lines_b oksline,
            (select hz.party_id, hdr.authoring_org_id, hdr.id hdr_id, line.cust_acct_id,
                    line.bill_to_site_use_id, line.id line_id
             from okc_k_lines_b line, okc_k_headers_all_b hdr, hz_cust_accounts_all hz
             where line.dnz_chr_id = hdr.id
             and   line.lse_id in (1,12,19,46)
             and   hz.cust_account_id = line.cust_acct_id) IV,
            IBY_EXTERNAL_PAYERS_ALL payer
      where  IV.line_id = oksline.cle_id
      and    oksline.cc_no is not null
      and    oksline.payment_type = 'CCR'
      and    oksline.cc_bank_acct_id is null
      and    oksline.trxn_extension_id is null
      ---and    IV.party_id = PAYER.PARTY_ID (+)
      and    IV.cust_acct_id = PAYER.CUST_ACCOUNT_ID(+)
      and    IV.bill_to_site_use_id = PAYER.ACCT_SITE_USE_ID(+)
      ---and    IV.authoring_org_id = PAYER.ORG_ID(+)
      and   'OPERATING_UNIT' = PAYER.ORG_TYPE(+)
      and   'CUSTOMER_PAYMENT' = PAYER.PAYMENT_FUNCTION(+)
      and    oksline.id BETWEEN p_id_low AND p_id_high;

    l_return_status    VARCHAR2(1);
    l_msg_data         VARCHAR2(2000);
    l_msg_count        NUMBER;

BEGIN


--open the cursor and migrate the stuff

  l_user_id := NVL(fnd_global.user_id, -1);

  IF (iby_cc_security_pub.encryption_enabled()) THEN
       -- security enabled
          OPEN oksline_cur_sec;
  Else
          OPEN oksline_cur;
  End if;

  LOOP
  IF (iby_cc_security_pub.encryption_enabled()) THEN
    FETCH oksline_cur_sec BULK COLLECT INTO
    oksline_id, c_cc_number, c_cc_code, c_cc_exp_date,
    okcline_id, okchdr_id, c_customer_id, c_cust_account_id,
    c_cust_site_use_id, c_org_id, c_trxn_entity_id, c_cc_id, c_ext_payer_id,
    c_create_payer_flag, c_instr_assignment_id, c_hash1, c_hash2, c_card_range_id,
    c_sec_segment_id, c_cc_num_length, c_cc_unmask_digits, c_cc_masked_num
    limit p_batchsize;

  ELSE
          FETCH oksline_cur BULK COLLECT INTO
    oksline_id, c_cc_number, c_cc_code, c_cc_exp_date,
    okcline_id, okchdr_id, c_customer_id, c_cust_account_id,
    c_cust_site_use_id, c_org_id, c_trxn_entity_id, c_cc_id, c_ext_payer_id,
    c_create_payer_flag, c_instr_assignment_id, c_hash1, c_hash2, c_card_range_id,
    c_sec_segment_id, c_cc_num_length, c_cc_unmask_digits, c_cc_masked_num
    limit p_batchsize;

   END IF;


   EXIT WHEN c_trxn_entity_id.count = 0 ;

   IF c_trxn_entity_id.count > 0 Then

    FND_FILE.PUT_LINE (FND_FILE.LOG, 'count  = '||c_trxn_entity_id.count );
    -- create new credit cards with single use only
   Begin

    FORALL i IN  c_trxn_entity_id.first..c_trxn_entity_id.last
    INSERT INTO  IBY_CREDITCARD
       (CARD_OWNER_ID,
	INSTRUMENT_TYPE,
	PURCHASECARD_FLAG,
	CARD_ISSUER_CODE,
	ACTIVE_FLAG,
	SINGLE_USE_FLAG,
	EXPIRYDATE,
	CHNAME,
	CCNUMBER,
	INSTRID,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
        ENCRYPTED,
        CC_NUMBER_HASH1,
        CC_NUMBER_HASH2,
        CC_ISSUER_RANGE_ID,
        CC_NUM_SEC_SEGMENT_ID,
        CARD_MASK_SETTING,
        CARD_UNMASK_LENGTH,
        CC_NUMBER_LENGTH,
        MASKED_CC_NUMBER,
        OBJECT_VERSION_NUMBER

 )
    VALUES(
        c_customer_id(i),
        'CREDITCARD',
        'N',
        c_cc_code(i),
        'Y',
        'Y',
        c_cc_exp_date(i),
        null,
        DECODE(c_sec_segment_id(i), NULL,c_cc_number(i), c_cc_unmask_digits(i)),
        c_cc_id(i),
        l_user_id,
	 sysdate,
	 l_user_id,
	 sysdate,
        l_user_id,
        DECODE(c_sec_segment_id(i), NULL,'N','Y'),
        c_hash1(i),
        c_hash2(i),
        c_card_range_id(i),
        c_sec_segment_id(i),
       'DISPLAY_LAST',
         4,
         c_cc_num_length(i),
         c_cc_masked_num(i),
         1
);

        -- Now insert into the instrument use table

    FORALL i IN  c_trxn_entity_id.first..c_trxn_entity_id.last
    INSERT INTO  IBY_PMT_INSTR_USES_ALL
        (INSTRUMENT_PAYMENT_USE_ID,
	EXT_PMT_PARTY_ID,
	INSTRUMENT_TYPE,
	INSTRUMENT_ID,
	PAYMENT_FUNCTION,
	PAYMENT_FLOW,
	ORDER_OF_PREFERENCE,
	START_DATE,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
        object_version_number)
     SELECT
        c_instr_assignment_id(i),
        EXT_PAYER_ID,
        'CREDITCARD',
        c_cc_id(i),
        'CUSTOMER_PAYMENT',
        'FUNDS_CAPTURE',
        1,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        1
	FROM IBY_EXTERNAL_PAYERS_ALL payer
	WHERE  payer.PAYMENT_FUNCTION = 'CUSTOMER_PAYMENT'
	AND    payer.PARTY_ID = c_customer_id(i)
	AND    payer.ORG_TYPE = 'OPERATING_UNIT'
	AND    payer.ORG_ID = c_org_id(i)
	AND    payer.CUST_ACCOUNT_ID = c_cust_account_id(i)
	AND    payer.ACCT_SITE_USE_ID = c_cust_site_use_id(i)
	AND    ROWNUM = 1;


    -- insert the transactions into IBY transaction extension table
    FORALL i IN  c_trxn_entity_id.first..c_trxn_entity_id.last
    INSERT INTO  IBY_FNDCPT_TX_EXTENSIONS
       (TRXN_EXTENSION_ID,
	PAYMENT_CHANNEL_CODE,
	INSTR_ASSIGNMENT_ID,
        ENCRYPTED,
        ORIGIN_APPLICATION_ID,
	ORDER_ID,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
	OBJECT_VERSION_NUMBER)
    VALUES
       (c_trxn_entity_id(i),
        'CREDIT_CARD',
        c_instr_assignment_id(i),
        'N',
        515,
        oksline_id(i),
        l_user_id,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        1);

 -- update the foreign key relationship

      FORALL i in c_trxn_entity_id.first..c_trxn_entity_id.last
      UPDATE oks_k_lines_b
      SET    TRXN_EXTENSION_ID = c_trxn_entity_id(i)
      WHERE  id = oksline_id(i);

   Exception
     WHEN OTHERS THEN
       FND_FILE.PUT_LINE (FND_FILE.LOG, 'error in insert  lines '||sqlerrm );
       For i IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
               insert into  oks_rule_error( chr_id,
                    cle_id , attribute_name, attribute_value,
                    major_version, rule_information_category )
	       values (okchdr_id(i), okcline_id(i), 'CC_NO', c_cc_number(i),
                       NULL, 'R12CC');
       End Loop;

   End;

   COMMIT;
   --
   End If; ----IF c_trxn_entity_id.count > 0 Then

    oksline_id.delete;
    c_cc_number.delete;
    c_cc_code.delete;
    c_cc_exp_date.delete;
    okcline_id.delete;
    okchdr_id.delete;
    c_customer_id.delete;
    c_cust_account_id.delete;
    c_cust_site_use_id.delete;
    c_org_id.delete;
    c_trxn_entity_id.delete;
    c_cc_id.delete;
    c_ext_payer_id.delete;
    c_create_payer_flag.delete;
    c_instr_assignment_id.delete;
    c_hash1.delete;
    c_hash2.delete;
    c_card_range_id.delete;
    c_sec_segment_id.delete;
    c_cc_num_length.delete;
    c_cc_unmask_digits.delete;
    c_cc_masked_num.delete;

  END LOOP;

  IF (iby_cc_security_pub.encryption_enabled()) THEN
    CLOSE oksline_cur_sec;
  ELSE
     CLOSE oksline_cur;
  End if;

  COMMIT;
    ----
  Exception
      when others Then
       FND_FILE.PUT_LINE (FND_FILE.LOG, 'main error in lines '||sqlerrm );
       null;

END MIGRATE_CC_LINE;

PROCEDURE MIGRATE_CC_HDRH(
    ERRBUF            OUT  NOCOPY VARCHAR2,
    RETCODE           OUT  NOCOPY NUMBER,
    p_id_low          IN NUMBER,
    p_id_high           IN NUMBER,
    p_batchsize       IN NUMBER ) IS

  l_user_id                   NUMBER;
  c_cc_trxn_id   l_num_tbl;
  c_cc_id        l_num_tbl;
  c_cc_number    l_chr_tbl;
  c_cc_code      l_chr_tbl;
  c_cc_exp_date  l_date_tbl;
  okcline_id     l_num_tbl;
  okshdr_id      l_num_tbl;
  oksline_major_version     l_num_tbl;
  okchdr_id      l_num_tbl;
  c_customer_id  l_num_tbl;
  c_cust_account_id l_num_tbl;
  c_cust_site_use_id l_num_tbl;
  c_org_id          l_num_tbl;
  c_additional_info l_chr_tbl;
  c_trxn_entity_id  l_num_tbl;
  c_instr_assignment_id l_num_tbl;
  c_ext_payer_id        l_num_tbl;
  c_create_payer_flag   l_chr_tbl;
  c_hash1               l_chr_tbl;
  c_hash2               l_chr_tbl;
  c_card_range_id       l_num_tbl;
  c_sec_segment_id      l_num_tbl;
  c_cc_num_length       l_num_tbl;
  c_cc_range_length     l_num_tbl;
  c_cc_unmask_digits    l_chr_tbl;
  c_cc_masked_num       l_chr_tbl;


  -- Cursor that queries all transactions needed to be migrated with encryption enabled

  -- Note: 1. This table is out-joined with the table IBY_EXTERNAL_PAYERS_ALL so that
  --          the party contexts that are not in the external payer table can be identified.
  --       2. The credit card number needs to be numeric.

cursor okshdr_cur_sec is
      select
          okshdr.id okshdr_id,
          okshdr.major_version okshdr_major_version,
          TRANSLATE(okshdr.cc_no,'0: -_', '0'),
          'UNKNOWN',
          okshdr.cc_expiry_date,
          IV.hdr_id okchdr_id,
          IV.party_id,
          IV.cust_account_id,
          IV.bill_to_site_use_id,
          IV.authoring_org_id,
          iby_fndcpt_tx_extensions_s.nextval,  -- the new transaction extension ID
          iby_instr_s.nextval,                 -- the new credit card id
          DECODE(PAYER.EXT_PAYER_ID, null, IBY_EXTERNAL_PAYERS_ALL_S.nextval,
                                           PAYER.EXT_PAYER_ID),
          DECODE(PAYER.EXT_PAYER_ID, null,'Y', 'N'),  -- this flag determines whether we
                                                      -- should create new external payer
          IBY_PMT_INSTR_USES_ALL_S.nextval,     -- the new instrument use id
          SEC.cc_number_hash1,
          SEC.cc_number_hash2,
          SEC.cc_issuer_range_id,
          SEC.sec_segment_id,
          SEC.cc_number_length,
          SEC.cc_unmask_digits,
          LPAD(sec.cc_unmask_digits, NVL(range.card_number_length, length(okshdr.cc_no)),'X')
      from  OKS_K_HEADERS_BH okshdr,
            (select hz.party_id, hdr.authoring_org_id, hdr.id hdr_id, hz.cust_account_id,
                    hdr.bill_to_site_use_id
             from okc_k_headers_all_b hdr, hz_cust_accounts_all hz,
                  hz_cust_site_uses_all site, hz_cust_acct_sites_all acct
             where hdr.bill_to_site_use_id = site.site_use_id
             and   site.cust_acct_site_id = acct.cust_acct_site_id
             and   acct.cust_account_id = hz.cust_account_id
             and   site.site_use_code = 'BILL_TO' ) IV,
            IBY_EXTERNAL_PAYERS_ALL payer,
            IBY_SECURITY_SEGMENTS sec,
            IBY_CC_ISSUER_RANGES rangE
      where  IV.hdr_id = okshdr.chr_id
      and    okshdr.cc_no is not null
      and    okshdr.payment_type = 'CCR'
      and    okshdr.cc_bank_acct_id is null
      and    okshdr.trxn_extension_id is null
      ---and    IV.party_id = PAYER.PARTY_ID (+)
      and    IV.cust_account_id = PAYER.CUST_ACCOUNT_ID(+)
      and    IV.bill_to_site_use_id = PAYER.ACCT_SITE_USE_ID(+)
      ---and    IV.authoring_org_id = PAYER.ORG_ID(+)
      and   'OPERATING_UNIT' = PAYER.ORG_TYPE(+)
      and   'CUSTOMER_PAYMENT' = PAYER.PAYMENT_FUNCTION(+)
      and    sec.sec_segment_id =  IBY_CC_SECURITY_PUB.get_segment_id(okshdr.cc_no)
      and    sec.CC_ISSUER_RANGE_ID = RANGE.CC_ISSUER_RANGE_ID (+)
      and    okshdr.id BETWEEN p_id_low AND p_id_high;

  -- Cursor that queries all transactions needed to be migrated with encryption disable

  -- Note: 1. This table is out-joined with the table IBY_EXTERNAL_PAYERS_ALL so that
  --          the party contexts that are not in the external payer table can be identified.
  --       2. The credit card number needs to be numeric.
cursor okshdr_cur is
      select
          okshdr.id okshdr_id,
          okshdr.major_version okshdr_major_version,
          TRANSLATE(okshdr.cc_no,'0: -_', '0'),
          'UNKNOWN',
          okshdr.cc_expiry_date,
          IV.hdr_id okchdr_id,
          IV.party_id,
          IV.cust_account_id,
          IV.bill_to_site_use_id,
          IV.authoring_org_id,
          IBY_FNDCPT_TX_EXTENSIONS_S.nextval,  -- the new transaction extension ID
          IBY_INSTR_S.nextval,                 -- the new credit card id
          DECODE(PAYER.EXT_PAYER_ID, null, IBY_EXTERNAL_PAYERS_ALL_S.nextval,
                                           PAYER.EXT_PAYER_ID),
          DECODE(PAYER.EXT_PAYER_ID, null,'Y', 'N'),  -- this flag determines whether we
                                                      -- should create new external payer
          IBY_PMT_INSTR_USES_ALL_S.nextval,     -- the new instrument use id
          ----iby_fndcpt_setup_pub.get_hash(okshdr.cc_no, FND_API.G_FALSE) cc_number_hash1,
          ----iby_fndcpt_setup_pub.get_hash(okshdr.cc_no, FND_API.G_TRUE) cc_number_hash2,
          iby_fndcpt_setup_pub.get_hash(okshdr.cc_no, 'F') cc_number_hash1,
          iby_fndcpt_setup_pub.get_hash(okshdr.cc_no, 'T') cc_number_hash2,
          IBY_CC_VALIDATE.Get_CC_Issuer_Range(okshdr.cc_no) cc_issuer_range_id,
          Null sec_segment_id,
          DECODE(IBY_CC_VALIDATE.Get_CC_Issuer_Range(okshdr.cc_no), NULL,LENGTH(okshdr.cc_no), NULL) cc_number_length,
          SUBSTR(okshdr.cc_no,GREATEST(-4,-LENGTH(okshdr.cc_no))) cc_unmask_digits,
          LPAD(SUBSTR(okshdr.cc_no,  GREATEST(-4,-LENGTH(okshdr.cc_no))),
 				       LENGTH(okshdr.cc_no),
			   'X' ) masked_cc_number
      from  oks_k_headers_bh okshdr,
            (select hz.party_id, hdr.authoring_org_id, hdr.id hdr_id, hz.cust_account_id,
                    hdr.bill_to_site_use_id
             from okc_k_headers_all_b hdr, hz_cust_accounts_all hz,
                  hz_cust_site_uses_all site, hz_cust_acct_sites_all acct
             where hdr.bill_to_site_use_id = site.site_use_id
             and   site.cust_acct_site_id = acct.cust_acct_site_id
             and   acct.cust_account_id = hz.cust_account_id
             and   site.site_use_code = 'BILL_TO') IV,
            IBY_EXTERNAL_PAYERS_ALL payer
      where  IV.hdr_id = okshdr.chr_id
      and    okshdr.cc_no is not null
      ---and    okshdr.id = 317191029854960778512632995409857241499
      and    okshdr.payment_type = 'CCR'
      and    okshdr.cc_bank_acct_id is null
      and    okshdr.trxn_extension_id is null
      ---and    IV.party_id = PAYER.PARTY_ID (+)
      and    IV.cust_account_id = PAYER.CUST_ACCOUNT_ID(+)
      and    IV.bill_to_site_use_id = PAYER.ACCT_SITE_USE_ID(+)
      ---and    IV.authoring_org_id = PAYER.ORG_ID(+)
      and   'OPERATING_UNIT' = PAYER.ORG_TYPE(+)
      and   'CUSTOMER_PAYMENT' = PAYER.PAYMENT_FUNCTION(+)
      and    okshdr.id BETWEEN p_id_low AND p_id_high;

    l_return_status    VARCHAR2(1);
    l_msg_data         VARCHAR2(2000);
    l_msg_count        NUMBER;

BEGIN


--open the cursor and migrate the stuff

  l_user_id := NVL(fnd_global.user_id, -1);

  IF (iby_cc_security_pub.encryption_enabled()) THEN
       -- security enabled
          OPEN okshdr_cur_sec;
  Else
          OPEN okshdr_cur;
  End if;

  LOOP
  IF (iby_cc_security_pub.encryption_enabled()) THEN
    FETCH okshdr_cur_sec BULK COLLECT INTO
    okshdr_id, oksline_major_version, c_cc_number, c_cc_code, c_cc_exp_date,
    okchdr_id, c_customer_id, c_cust_account_id,
    c_cust_site_use_id, c_org_id, c_trxn_entity_id, c_cc_id, c_ext_payer_id,
    c_create_payer_flag, c_instr_assignment_id, c_hash1, c_hash2, c_card_range_id,
    c_sec_segment_id, c_cc_num_length, c_cc_unmask_digits, c_cc_masked_num
    limit p_batchsize;

  ELSE
          FETCH okshdr_cur BULK COLLECT INTO
    okshdr_id, oksline_major_version, c_cc_number, c_cc_code, c_cc_exp_date,
    okchdr_id, c_customer_id, c_cust_account_id,
    c_cust_site_use_id, c_org_id, c_trxn_entity_id, c_cc_id, c_ext_payer_id,
    c_create_payer_flag, c_instr_assignment_id, c_hash1, c_hash2, c_card_range_id,
    c_sec_segment_id, c_cc_num_length, c_cc_unmask_digits, c_cc_masked_num
    limit p_batchsize;

   END IF;


   EXIT WHEN c_trxn_entity_id.count = 0 ;

   IF c_trxn_entity_id.count > 0 Then

    FND_FILE.PUT_LINE (FND_FILE.LOG, 'count  = '||c_trxn_entity_id.count );
    -- create new credit cards with single use only
   Begin

    FORALL i IN  c_trxn_entity_id.first..c_trxn_entity_id.last
    INSERT INTO  IBY_CREDITCARD
       (CARD_OWNER_ID,
	INSTRUMENT_TYPE,
	PURCHASECARD_FLAG,
	CARD_ISSUER_CODE,
	ACTIVE_FLAG,
	SINGLE_USE_FLAG,
	EXPIRYDATE,
	CHNAME,
	CCNUMBER,
	INSTRID,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
        ENCRYPTED,
        CC_NUMBER_HASH1,
        CC_NUMBER_HASH2,
        CC_ISSUER_RANGE_ID,
        CC_NUM_SEC_SEGMENT_ID,
        CARD_MASK_SETTING,
        CARD_UNMASK_LENGTH,
        CC_NUMBER_LENGTH,
        MASKED_CC_NUMBER,
        OBJECT_VERSION_NUMBER

 )
    VALUES(
        c_customer_id(i),
        'CREDITCARD',
        'N',
        c_cc_code(i),
        'Y',
        'Y',
        c_cc_exp_date(i),
        null,
        DECODE(c_sec_segment_id(i), NULL,c_cc_number(i), c_cc_unmask_digits(i)),
        c_cc_id(i),
        l_user_id,
	 sysdate,
	 l_user_id,
	 sysdate,
        l_user_id,
        DECODE(c_sec_segment_id(i), NULL,'N','Y'),
        c_hash1(i),
        c_hash2(i),
        c_card_range_id(i),
        c_sec_segment_id(i),
       'DISPLAY_LAST',
         4,
         c_cc_num_length(i),
         c_cc_masked_num(i),
         1
);

        -- Now insert into the instrument use table

    FORALL i IN  c_trxn_entity_id.first..c_trxn_entity_id.last
    INSERT INTO  IBY_PMT_INSTR_USES_ALL
        (INSTRUMENT_PAYMENT_USE_ID,
	EXT_PMT_PARTY_ID,
	INSTRUMENT_TYPE,
	INSTRUMENT_ID,
	PAYMENT_FUNCTION,
	PAYMENT_FLOW,
	ORDER_OF_PREFERENCE,
	START_DATE,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
        object_version_number)
     SELECT
        c_instr_assignment_id(i),
        EXT_PAYER_ID,
        'CREDITCARD',
        c_cc_id(i),
        'CUSTOMER_PAYMENT',
        'FUNDS_CAPTURE',
        1,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        1
	FROM IBY_EXTERNAL_PAYERS_ALL payer
	WHERE  payer.PAYMENT_FUNCTION = 'CUSTOMER_PAYMENT'
	AND    payer.PARTY_ID = c_customer_id(i)
	AND    payer.ORG_TYPE = 'OPERATING_UNIT'
	AND    payer.ORG_ID = c_org_id(i)
	AND    payer.CUST_ACCOUNT_ID = c_cust_account_id(i)
	AND    payer.ACCT_SITE_USE_ID = c_cust_site_use_id(i)
	AND    ROWNUM = 1;


    -- insert the transactions into IBY transaction extension table
    FORALL i IN  c_trxn_entity_id.first..c_trxn_entity_id.last
    INSERT INTO  IBY_FNDCPT_TX_EXTENSIONS
       (TRXN_EXTENSION_ID,
	PAYMENT_CHANNEL_CODE,
	INSTR_ASSIGNMENT_ID,
        ENCRYPTED,
        ORIGIN_APPLICATION_ID,
	ORDER_ID,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
	OBJECT_VERSION_NUMBER)
    VALUES
       (c_trxn_entity_id(i),
        'CREDIT_CARD',
        c_instr_assignment_id(i),
        'N',
        515,
        okshdr_id(i),
        l_user_id,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        1);

 -- update the foreign key relationship

      FORALL i in c_trxn_entity_id.first..c_trxn_entity_id.last
      UPDATE oks_k_headers_bh
      SET    TRXN_EXTENSION_ID = c_trxn_entity_id(i)
      WHERE  id = okshdr_id(i)
      AND    major_version = oksline_major_version(i);

   Exception
     WHEN OTHERS THEN
       FND_FILE.PUT_LINE (FND_FILE.LOG, 'error in hdr history  '||sqlerrm );
       For i IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
               insert into  oks_rule_error( chr_id,
                    cle_id , attribute_name, attribute_value,
                    major_version, rule_information_category )
	       values (okchdr_id(i), NULL, 'CC_NO', c_cc_number(i),
                       oksline_major_version(i), 'R12CC');
       End Loop;

   End;

   End If; ----IF c_trxn_entity_id.count > 0 Then

  COMMIT;
    okshdr_id.delete;
    oksline_major_version.delete;
    c_cc_number.delete;
    c_cc_code.delete;
    c_cc_exp_date.delete;
    okcline_id.delete;
    okchdr_id.delete;
    c_customer_id.delete;
    c_cust_account_id.delete;
    c_cust_site_use_id.delete;
    c_org_id.delete;
    c_trxn_entity_id.delete;
    c_cc_id.delete;
    c_ext_payer_id.delete;
    c_create_payer_flag.delete;
    c_instr_assignment_id.delete;
    c_hash1.delete;
    c_hash2.delete;
    c_card_range_id.delete;
    c_sec_segment_id.delete;
    c_cc_num_length.delete;
    c_cc_unmask_digits.delete;
    c_cc_masked_num.delete;

  END LOOP;

  IF (iby_cc_security_pub.encryption_enabled()) THEN
    CLOSE okshdr_cur_sec;
  ELSE
     CLOSE okshdr_cur;
  End if;

  COMMIT;
    ----
  Exception
      when others Then
       FND_FILE.PUT_LINE (FND_FILE.LOG, 'main error hdr history'||sqlerrm );
       null;

END MIGRATE_CC_HDRH;

PROCEDURE MIGRATE_CC_HDR(
    ERRBUF            OUT  NOCOPY VARCHAR2,
    RETCODE           OUT  NOCOPY NUMBER,
    p_id_low          IN NUMBER,
    p_id_high           IN NUMBER,
    p_batchsize       IN NUMBER) IS

  l_user_id                   NUMBER;
  c_cc_trxn_id   l_num_tbl;
  c_cc_id        l_num_tbl;
  c_cc_number    l_chr_tbl;
  c_cc_code      l_chr_tbl;
  c_cc_exp_date  l_date_tbl;
  okcline_id     l_num_tbl;
  okshdr_id      l_num_tbl;
  okchdr_id      l_num_tbl;
  c_customer_id  l_num_tbl;
  c_cust_account_id l_num_tbl;
  c_cust_site_use_id l_num_tbl;
  c_org_id          l_num_tbl;
  c_additional_info l_chr_tbl;
  c_trxn_entity_id  l_num_tbl;
  c_instr_assignment_id l_num_tbl;
  c_ext_payer_id        l_num_tbl;
  c_create_payer_flag   l_chr_tbl;
  c_hash1               l_chr_tbl;
  c_hash2               l_chr_tbl;
  c_card_range_id       l_num_tbl;
  c_sec_segment_id      l_num_tbl;
  c_cc_num_length       l_num_tbl;
  c_cc_range_length     l_num_tbl;
  c_cc_unmask_digits    l_chr_tbl;
  c_cc_masked_num       l_chr_tbl;


  -- Cursor that queries all transactions needed to be migrated with encryption enabled

  -- Note: 1. This table is out-joined with the table IBY_EXTERNAL_PAYERS_ALL so that
  --          the party contexts that are not in the external payer table can be identified.
  --       2. The credit card number needs to be numeric.

cursor okshdr_cur_sec  is
      select
          okshdr.id okshdr_id,
          TRANSLATE(okshdr.cc_no,'0: -_', '0'),
          'UNKNOWN',
          okshdr.cc_expiry_date,
          IV.hdr_id okchdr_id,
          IV.party_id,
          IV.cust_account_id,
          IV.bill_to_site_use_id,
          IV.authoring_org_id,
          iby_fndcpt_tx_extensions_s.nextval,  -- the new transaction extension ID
          iby_instr_s.nextval,                 -- the new credit card id
          DECODE(PAYER.EXT_PAYER_ID, null, IBY_EXTERNAL_PAYERS_ALL_S.nextval,
                                           PAYER.EXT_PAYER_ID),
          DECODE(PAYER.EXT_PAYER_ID, null,'Y', 'N'),  -- this flag determines whether we
                                                      -- should create new external payer
          IBY_PMT_INSTR_USES_ALL_S.nextval,     -- the new instrument use id
          SEC.cc_number_hash1,
          SEC.cc_number_hash2,
          SEC.cc_issuer_range_id,
          SEC.sec_segment_id,
          SEC.cc_number_length,
          SEC.cc_unmask_digits,
          LPAD(sec.cc_unmask_digits, NVL(range.card_number_length, length(okshdr.cc_no)),'X')
      from  OKS_K_HEADERS_B okshdr,
            (select hz.party_id, hdr.authoring_org_id, hdr.id hdr_id, hz.cust_account_id,
                    hdr.bill_to_site_use_id
             from okc_k_headers_all_b hdr, hz_cust_accounts_all hz,
                  hz_cust_site_uses_all site, hz_cust_acct_sites_all acct
             where hdr.bill_to_site_use_id = site.site_use_id
             and   site.cust_acct_site_id = acct.cust_acct_site_id
             and   acct.cust_account_id = hz.cust_account_id
             and   site.site_use_code = 'BILL_TO') IV,
            IBY_EXTERNAL_PAYERS_ALL payer,
            IBY_SECURITY_SEGMENTS sec,
            IBY_CC_ISSUER_RANGES rangE
      where  IV.hdr_id = okshdr.chr_id
      and    okshdr.cc_no is not null
      and    okshdr.payment_type = 'CCR'
      and    okshdr.cc_bank_acct_id is null
      and    okshdr.trxn_extension_id is null
      ---and    IV.party_id = PAYER.PARTY_ID (+)
      and    IV.cust_account_id = PAYER.CUST_ACCOUNT_ID(+)
      and    IV.bill_to_site_use_id = PAYER.ACCT_SITE_USE_ID(+)
      ---and    IV.authoring_org_id = PAYER.ORG_ID(+)
      and   'OPERATING_UNIT' = PAYER.ORG_TYPE(+)
      and   'CUSTOMER_PAYMENT' = PAYER.PAYMENT_FUNCTION(+)
      and    sec.sec_segment_id =  IBY_CC_SECURITY_PUB.get_segment_id(okshdr.cc_no)
      and    sec.CC_ISSUER_RANGE_ID = RANGE.CC_ISSUER_RANGE_ID (+)
      and    okshdr.id BETWEEN p_id_low AND p_id_high;

  -- Cursor that queries all transactions needed to be migrated with encryption disable

  -- Note: 1. This table is out-joined with the table IBY_EXTERNAL_PAYERS_ALL so that
  --          the party contexts that are not in the external payer table can be identified.
  --       2. The credit card number needs to be numeric.
cursor okshdr_cur is
      select
          okshdr.id okshdr_id,
          TRANSLATE(okshdr.cc_no,'0: -_', '0'),
          'UNKNOWN',
          okshdr.cc_expiry_date,
          IV.hdr_id okchdr_id,
          IV.party_id,
          IV.cust_account_id,
          IV.bill_to_site_use_id,
          IV.authoring_org_id,
          IBY_FNDCPT_TX_EXTENSIONS_S.nextval,  -- the new transaction extension ID
          IBY_INSTR_S.nextval,                 -- the new credit card id
          DECODE(PAYER.EXT_PAYER_ID, null, IBY_EXTERNAL_PAYERS_ALL_S.nextval,
                                           PAYER.EXT_PAYER_ID),
          DECODE(PAYER.EXT_PAYER_ID, null,'Y', 'N'),  -- this flag determines whether we
                                                      -- should create new external payer
          IBY_PMT_INSTR_USES_ALL_S.nextval,     -- the new instrument use id
          ----iby_fndcpt_setup_pub.get_hash(okshdr.cc_no, FND_API.G_FALSE) cc_number_hash1,
          ----iby_fndcpt_setup_pub.get_hash(okshdr.cc_no, FND_API.G_TRUE) cc_number_hash2,
          iby_fndcpt_setup_pub.get_hash(okshdr.cc_no, 'F') cc_number_hash1,
          iby_fndcpt_setup_pub.get_hash(okshdr.cc_no, 'T') cc_number_hash2,
          IBY_CC_VALIDATE.Get_CC_Issuer_Range(okshdr.cc_no) cc_issuer_range_id,
          Null sec_segment_id,
          DECODE(IBY_CC_VALIDATE.Get_CC_Issuer_Range(okshdr.cc_no), NULL,LENGTH(okshdr.cc_no), NULL) cc_number_length,
          SUBSTR(okshdr.cc_no,GREATEST(-4,-LENGTH(okshdr.cc_no))) cc_unmask_digits,
          LPAD(SUBSTR(okshdr.cc_no,  GREATEST(-4,-LENGTH(okshdr.cc_no))),
 				       LENGTH(okshdr.cc_no),
			   'X' ) masked_cc_number
      from  oks_k_headers_b okshdr,
            (select hz.party_id, hdr.authoring_org_id, hdr.id hdr_id, hz.cust_account_id,
                    hdr.bill_to_site_use_id
             from okc_k_headers_all_b hdr, hz_cust_accounts_all hz,
                  hz_cust_site_uses_all site, hz_cust_acct_sites_all acct
             where hdr.bill_to_site_use_id = site.site_use_id
             and   site.cust_acct_site_id = acct.cust_acct_site_id
             and   acct.cust_account_id = hz.cust_account_id
             and   site.site_use_code = 'BILL_TO') IV,
            IBY_EXTERNAL_PAYERS_ALL payer
      where  IV.hdr_id = okshdr.chr_id
      and    okshdr.cc_no is not null
      ---and    okshdr.id = 317191029854960778512632995409857241499
      and    okshdr.payment_type = 'CCR'
      and    okshdr.cc_bank_acct_id is null
      and    okshdr.trxn_extension_id is null
      ---and    IV.party_id = PAYER.PARTY_ID (+)
      and    IV.cust_account_id = PAYER.CUST_ACCOUNT_ID(+)
      and    IV.bill_to_site_use_id = PAYER.ACCT_SITE_USE_ID(+)
      ---and    IV.authoring_org_id = PAYER.ORG_ID(+)
      and   'OPERATING_UNIT' = PAYER.ORG_TYPE(+)
      and   'CUSTOMER_PAYMENT' = PAYER.PAYMENT_FUNCTION(+)
      and    okshdr.id BETWEEN p_id_low AND p_id_high;
    l_return_status    VARCHAR2(1);
    l_msg_data         VARCHAR2(2000);
    l_msg_count        NUMBER;

BEGIN


--open the cursor and migrate the stuff

  l_user_id := NVL(fnd_global.user_id, -1);

  IF (iby_cc_security_pub.encryption_enabled()) THEN
       -- security enabled
          OPEN okshdr_cur_sec;
  Else
          OPEN okshdr_cur;
  End if;

  LOOP
  IF (iby_cc_security_pub.encryption_enabled()) THEN
    FETCH okshdr_cur_sec BULK COLLECT INTO
    okshdr_id, c_cc_number, c_cc_code, c_cc_exp_date,
    okchdr_id, c_customer_id, c_cust_account_id,
    c_cust_site_use_id, c_org_id, c_trxn_entity_id, c_cc_id, c_ext_payer_id,
    c_create_payer_flag, c_instr_assignment_id, c_hash1, c_hash2, c_card_range_id,
    c_sec_segment_id, c_cc_num_length, c_cc_unmask_digits, c_cc_masked_num
    limit p_batchsize;

  ELSE
          FETCH okshdr_cur BULK COLLECT INTO
    okshdr_id, c_cc_number, c_cc_code, c_cc_exp_date,
    okchdr_id, c_customer_id, c_cust_account_id,
    c_cust_site_use_id, c_org_id, c_trxn_entity_id, c_cc_id, c_ext_payer_id,
    c_create_payer_flag, c_instr_assignment_id, c_hash1, c_hash2, c_card_range_id,
    c_sec_segment_id, c_cc_num_length, c_cc_unmask_digits, c_cc_masked_num
    limit p_batchsize;

   END IF;


   EXIT WHEN c_trxn_entity_id.count = 0 ;

   IF c_trxn_entity_id.count > 0 Then

    FND_FILE.PUT_LINE (FND_FILE.LOG, 'count  = '||c_trxn_entity_id.count );
    -- create new credit cards with single use only
   Begin

    FORALL i IN  c_trxn_entity_id.first..c_trxn_entity_id.last
    INSERT INTO  IBY_CREDITCARD
       (CARD_OWNER_ID,
	INSTRUMENT_TYPE,
	PURCHASECARD_FLAG,
	CARD_ISSUER_CODE,
	ACTIVE_FLAG,
	SINGLE_USE_FLAG,
	EXPIRYDATE,
	CHNAME,
	CCNUMBER,
	INSTRID,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
        ENCRYPTED,
        CC_NUMBER_HASH1,
        CC_NUMBER_HASH2,
        CC_ISSUER_RANGE_ID,
        CC_NUM_SEC_SEGMENT_ID,
        CARD_MASK_SETTING,
        CARD_UNMASK_LENGTH,
        CC_NUMBER_LENGTH,
        MASKED_CC_NUMBER,
        OBJECT_VERSION_NUMBER

 )
    VALUES(
        c_customer_id(i),
        'CREDITCARD',
        'N',
        c_cc_code(i),
        'Y',
        'Y',
        c_cc_exp_date(i),
        null,
        DECODE(c_sec_segment_id(i), NULL,c_cc_number(i), c_cc_unmask_digits(i)),
        c_cc_id(i),
        l_user_id,
	 sysdate,
	 l_user_id,
	 sysdate,
        l_user_id,
        DECODE(c_sec_segment_id(i), NULL,'N','Y'),
        c_hash1(i),
        c_hash2(i),
        c_card_range_id(i),
        c_sec_segment_id(i),
       'DISPLAY_LAST',
         4,
         c_cc_num_length(i),
         c_cc_masked_num(i),
         1
);

        -- Now insert into the instrument use table

    FORALL i IN  c_trxn_entity_id.first..c_trxn_entity_id.last
    INSERT INTO  IBY_PMT_INSTR_USES_ALL
        (INSTRUMENT_PAYMENT_USE_ID,
	EXT_PMT_PARTY_ID,
	INSTRUMENT_TYPE,
	INSTRUMENT_ID,
	PAYMENT_FUNCTION,
	PAYMENT_FLOW,
	ORDER_OF_PREFERENCE,
	START_DATE,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
        object_version_number)
     SELECT
        c_instr_assignment_id(i),
        EXT_PAYER_ID,
        'CREDITCARD',
        c_cc_id(i),
        'CUSTOMER_PAYMENT',
        'FUNDS_CAPTURE',
        1,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        1
	FROM IBY_EXTERNAL_PAYERS_ALL payer
	WHERE  payer.PAYMENT_FUNCTION = 'CUSTOMER_PAYMENT'
	AND    payer.PARTY_ID = c_customer_id(i)
	AND    payer.ORG_TYPE = 'OPERATING_UNIT'
	AND    payer.ORG_ID = c_org_id(i)
	AND    payer.CUST_ACCOUNT_ID = c_cust_account_id(i)
	AND    payer.ACCT_SITE_USE_ID = c_cust_site_use_id(i)
	AND    ROWNUM = 1;


    -- insert the transactions into IBY transaction extension table
    FORALL i IN  c_trxn_entity_id.first..c_trxn_entity_id.last
    INSERT INTO  IBY_FNDCPT_TX_EXTENSIONS
       (TRXN_EXTENSION_ID,
	PAYMENT_CHANNEL_CODE,
	INSTR_ASSIGNMENT_ID,
        ENCRYPTED,
        ORIGIN_APPLICATION_ID,
	ORDER_ID,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
	OBJECT_VERSION_NUMBER)
    VALUES
       (c_trxn_entity_id(i),
        'CREDIT_CARD',
        c_instr_assignment_id(i),
        'N',
        515,
        okshdr_id(i),
        l_user_id,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        1);

 -- update the foreign key relationship

      FORALL i in c_trxn_entity_id.first..c_trxn_entity_id.last
      UPDATE oks_k_lines_b
      SET    TRXN_EXTENSION_ID = c_trxn_entity_id(i)
      WHERE  id = okshdr_id(i);

   Exception
     WHEN OTHERS THEN
       FND_FILE.PUT_LINE (FND_FILE.LOG, 'error in insert  hdr '||sqlerrm );
       For i IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
               insert into  oks_rule_error( chr_id,
                    cle_id , attribute_name, attribute_value,
                    major_version, rule_information_category )
	       values (okchdr_id(i), NULL, 'CC_NO', c_cc_number(i),
                       NULL, 'R12CC');
       End Loop;

   End;

   COMMIT;
   --
   End If; ----IF c_trxn_entity_id.count > 0 Then

    okshdr_id.delete;
    c_cc_number.delete;
    c_cc_code.delete;
    c_cc_exp_date.delete;
    okcline_id.delete;
    okchdr_id.delete;
    c_customer_id.delete;
    c_cust_account_id.delete;
    c_cust_site_use_id.delete;
    c_org_id.delete;
    c_trxn_entity_id.delete;
    c_cc_id.delete;
    c_ext_payer_id.delete;
    c_create_payer_flag.delete;
    c_instr_assignment_id.delete;
    c_hash1.delete;
    c_hash2.delete;
    c_card_range_id.delete;
    c_sec_segment_id.delete;
    c_cc_num_length.delete;
    c_cc_unmask_digits.delete;
    c_cc_masked_num.delete;

  END LOOP;

  IF (iby_cc_security_pub.encryption_enabled()) THEN
    CLOSE okshdr_cur_sec;
  ELSE
     CLOSE okshdr_cur;
  End if;

  COMMIT;
    ----
  Exception
      when others Then
       FND_FILE.PUT_LINE (FND_FILE.LOG, 'main error in hdr '||sqlerrm );
       null;

END MIGRATE_CC_HDR;


 PROCEDURE generate_report (
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER
  )
  IS
     CURSOR get_hdr_csr
     IS
        SELECT okh.chr_id,
               kh.contract_number ||' ' ||kh.contract_number_modifier
                                                             contract_number,
               kh.start_date start_date,
               kh.end_date end_date,
               kh.date_terminated date_terminated,
               st.meaning status,
               ore.attribute_value cc_no,
               ore.cc_expiry_date cc_exp_date,
              (SELECT party_name
                       FROM hz_parties a,
                            hz_cust_accounts b
                      WHERE a.party_id = b.party_id
                        AND b.cust_account_id = cust_acct_id) party_name
          FROM oks_rule_error ore,
               oks_k_headers_b okh,
               okc_k_headers_all_b kh,
               okc_statuses_v st
         WHERE ore.RULE_INFORMATION_CATEGORY = 'R12CC'
           AND ore.chr_id = kh.ID
           AND ore.cle_id IS NULL
           AND kh.ID = okh.chr_id
           AND st.code = kh.sts_code;

     CURSOR get_hdr_hist_csr
     IS
        SELECT kh.ID,
               kh.contract_number||' '||kh.contract_number_modifier contract_number,
               kh.major_version,
               kh.start_date start_date,
               kh.end_date end_date,
               kh.date_terminated date_terminated,
               st.meaning status,
               ore.attribute_value cc_no,
               ore.cc_expiry_date cc_exp_date,
              (SELECT party_name
                       FROM hz_parties a,
                            hz_cust_accounts b
                      WHERE a.party_id = b.party_id
                       AND b.cust_account_id = cust_acct_id) party_name
          FROM oks_rule_error ore,
               okc_k_headers_all_bh kh,
               okc_statuses_v st
         WHERE ore.RULE_INFORMATION_CATEGORY = 'R12CC'
           AND ore.chr_id = kh.ID
           AND ore.cle_id IS NULL
           AND ore.major_version IS NOT NULL
           AND st.code = kh.STS_CODE;

     CURSOR get_Line_csr
     IS
        SELECT ore.cle_id,
               kh.contract_number ||' ' ||kh.contract_number_modifier
                                                             contract_number,
               lc.line_number,
               lc.start_date start_date,
               lc.end_date end_date,
               lc.date_terminated date_terminated,
               st.meaning status,
               ore.attribute_value cc_no,
               ore.cc_expiry_date cc_exp_date,
              (SELECT party_name
                       FROM hz_parties a,
                            hz_cust_accounts b
                      WHERE a.party_id = b.party_id
                        AND b.cust_account_id = lc.cust_acct_id) party_name,
              (SELECT decode(fnd_profile.value('OKS_ITEM_DISPLAY_PREFERENCE'),'DISPLAY_DESC',
                     B.CONCATENATED_SEGMENTS ,T.DESCRIPTION )
               FROM   MTL_SYSTEM_ITEMS_B_KFV B,
                      MTL_SYSTEM_ITEMS_TL T
               WHERE  B.INVENTORY_ITEM_ID = T.INVENTORY_ITEM_ID
               AND    B.ORGANIZATION_ID = T.ORGANIZATION_ID
               AND    T.LANGUAGE = userenv('LANG')
               AND    B.INVENTORY_ITEM_ID = object1_id1
               AND    ROWNUM < 2) service_name

          FROM oks_rule_error ore,
               okc_k_headers_all_b kh,
               okc_statuses_v st,
               oks_k_lines_b  ls,
               okc_k_lines_b  lc,
               okc_k_items  it
         WHERE ore.RULE_INFORMATION_CATEGORY = 'R12CC'
           AND ore.cle_id = ls.cle_ID
           AND ore.CHR_id = ls.DNZ_CHR_ID
           AND ls.cle_id = lc.ID
           AND ls.dnz_chr_id = kh.id
           AND lc.STS_CODE = st.code
           AND it.cle_id = lc.ID
           AND it.jtot_object1_code = 'OKX_SERVICE';

     CURSOR get_Line_hist_csr
     IS
        SELECT ore.cle_id,
               kh.contract_number ||' ' ||kh.contract_number_modifier
                                                             contract_number,
               lc.major_version,
               lc.line_number,
               lc.start_date start_date,
               lc.end_date end_date,
               lc.date_terminated date_terminated,
               st.meaning status,
               ore.attribute_value cc_no,
               ore.cc_expiry_date cc_exp_date,
              (SELECT party_name
                       FROM hz_parties a,
                            hz_cust_accounts b
                      WHERE a.party_id = b.party_id
                        AND b.cust_account_id = lc.cust_acct_id) party_name,
              (SELECT decode(fnd_profile.value('OKS_ITEM_DISPLAY_PREFERENCE'),'DISPLAY_DESC',
                     B.CONCATENATED_SEGMENTS ,T.DESCRIPTION )
               FROM   MTL_SYSTEM_ITEMS_B_KFV B,
                      MTL_SYSTEM_ITEMS_TL T
               WHERE  B.INVENTORY_ITEM_ID = T.INVENTORY_ITEM_ID
               AND    B.ORGANIZATION_ID = T.ORGANIZATION_ID
               AND    T.LANGUAGE = userenv('LANG')
               AND    B.INVENTORY_ITEM_ID = object1_id1
               AND    ROWNUM < 2) service_name

          FROM oks_rule_error ore,
               okc_k_headers_all_b kh,
               okc_statuses_v st,
               okc_k_lines_bh lc,
               okc_k_items  it
         WHERE ore.RULE_INFORMATION_CATEGORY = 'R12CC'
           AND ore.cle_id = lc.id
           AND kh.id = lc.dnz_chr_id
           AND lc.STS_CODE = st.code
           AND it.cle_id = lc.ID
           AND it.jtot_object1_code = 'OKX_SERVICE';

     contract_number   okc_datatypes.var240tabtyp;
     contract_id       okc_datatypes.numbertabtyp;
     contract_version  okc_datatypes.numbertabtyp;
     line_version      okc_datatypes.numbertabtyp;
     contract_sdate    okc_datatypes.datetabtyp;
     contract_edate    okc_datatypes.datetabtyp;
     date_terminated   okc_datatypes.datetabtyp;
     contract_status   okc_datatypes.var30tabtyp;
     cc_number         okc_datatypes.var120tabtyp;
     cc_exp_date       okc_datatypes.datetabtyp;
     party_name        okc_datatypes.var450tabtyp;
     line_number       okc_datatypes.numbertabtyp;
     service_name      okc_datatypes.var240tabtyp;
     line_id           okc_datatypes.numbertabtyp;
     line_sdate        okc_datatypes.datetabtyp;
     line_edate        okc_datatypes.datetabtyp;
     line_status       okc_datatypes.var30tabtyp;
     l_cont_length     NUMBER;
     l_party_length    NUMBER;
     l_service_length  NUMBER;
     l_max_length      NUMBER;
     l_rel_name        VARCHAR2(60);
     l_other           VARCHAR2(60);
     l_ret_val         BOOLEAN;
     l_dash_string     VARCHAR2(500) := '----------';
     l_empty_string    VARCHAR2(500) := '          ';
  BEGIN
     l_ret_val := FND_RELEASE.get_release(
     RELEASE_NAME       => l_rel_name,
     OTHER_RELEASE_INFO => l_other);

     IF NOT l_ret_val THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;

     --DBMS_OUTPUT.put_line('release =  '|| l_rel_name);
     --DBMS_OUTPUT.put_line(substr('Value of l_other='||l_other,1,255));

     FND_FILE.put_line(FND_FILE.OUTPUT,'                                        Credit Card Migration Error Report                                                ');
     FND_FILE.put_line(FND_FILE.OUTPUT,'                                        **********************************                                                ');
     FND_FILE.put_line(FND_FILE.OUTPUT,' ');
--    FND_FILE.put_line(FND_FILE.OUTPUT,'Contract Headers');
     fnd_file.put_line(FND_FILE.OUTPUT,FND_MESSAGE.get_string('OKS','OKS_RR_CONTRACT_HDR'));
     FND_FILE.put_line(FND_FILE.OUTPUT,l_dash_string
                                       || SUBSTR(l_dash_string,1,6));

     FND_FILE.put_line(FND_FILE.OUTPUT,' ');
--    FND_FILE.put_line(FND_FILE.OUTPUT,'Contract Number          Billto                   Status    Start Date    End Date     Date Terminated   Credit Card Number  Expiration Date');
     FND_FILE.put_line(FND_FILE.OUTPUT,
                       RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_CONTRACT_NUM'),25)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_BILL_TO'),25)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_STATUS'),10)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_START_DATE'),14)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_END_DATE'),13)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_DATE_TERM'),18)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_CCR_NUM'),20)
                     ||FND_MESSAGE.get_string('OKS','OKS_RR_EXP_DATE'));
     FND_FILE.put_line(FND_FILE.OUTPUT,l_dash_string||l_dash_string||l_dash_string
                                     ||l_dash_string||l_dash_string||l_dash_string
                                     ||l_dash_string||l_dash_string||l_dash_string
                                     ||l_dash_string||l_dash_string||l_dash_string
                                     ||l_dash_string||l_dash_string);

     OPEN get_hdr_csr;

     FETCH get_hdr_csr
     BULK COLLECT INTO contract_id,
            contract_number,
            contract_sdate,
            contract_edate,
            date_terminated,
            contract_status,
            cc_number,
            cc_exp_date,
            party_name;

     CLOSE get_hdr_csr;

     IF contract_id.COUNT > 0
     THEN
        FOR i IN 1 .. contract_id.COUNT
        LOOP
               FND_FILE.put(FND_FILE.OUTPUT,RPAD (SUBSTR(contract_number (i),1, 20),25,' ' ));
               IF party_name (i) IS NOT NULL
               THEN
                   FND_FILE.put(FND_FILE.OUTPUT,RPAD(SUBSTR (party_name (i), 1, 20),25, ' '));
               ELSE

                   FND_FILE.put(FND_FILE.OUTPUT,l_empty_string||l_empty_string
                                              ||SUBSTR(l_empty_string,1,5));
               END IF;
               FND_FILE.put(FND_FILE.OUTPUT,RPAD(contract_status (i),10, ' '));
               FND_FILE.put(FND_FILE.OUTPUT,RPAD(contract_sdate (i), 14, ' '));
               FND_FILE.put(FND_FILE.OUTPUT,RPAD(contract_edate (i), 13, ' '));
               IF date_terminated(i) IS NOT  NULL
               THEN
                   FND_FILE.put(FND_FILE.OUTPUT,RPAD(date_terminated(i),18, ' '));
               ELSE
                   FND_FILE.put(FND_FILE.OUTPUT,l_empty_string||SUBSTR(l_empty_string,1,8));
               END IF;
               FND_FILE.put(FND_FILE.OUTPUT,RPAD(cc_number(i), 20,' '));
               FND_FILE.put(FND_FILE.OUTPUT,RPAD(cc_exp_date(i), 15, ' '));

               l_cont_length    := LENGTH (contract_number(i));
               l_party_length   := NVL(LENGTH (party_name(i)),0);

               IF l_cont_length  >= l_party_length
               THEN
                   l_max_length := l_cont_length;
               ELSE
                   l_max_length := l_party_length;
               END IF;

               FOR j IN 1 ..FLOOR (l_max_length / 20)
               LOOP
                 FND_FILE.put_line(FND_FILE.OUTPUT,' ');
                 IF contract_number(i) IS NOT NULL AND (SUBSTR (contract_number (i), (j*20+1),20)) IS NOT NULL
                 THEN
                    FND_FILE.put(FND_FILE.OUTPUT,RPAD(SUBSTR (contract_number (i), (j*20+1),20),25, ' '));
                 ELSE
                    FND_FILE.put(FND_FILE.OUTPUT,l_empty_string||l_empty_string
                                                 ||SUBSTR(l_empty_string,1,5));
                 END IF;
                 IF party_name(i) IS NOT NULL AND (SUBSTR (party_name (i), (j*20+1),20)) IS NOT NULL
                 THEN
                    FND_FILE.put(FND_FILE.OUTPUT,RPAD(SUBSTR (party_name (i), (j*20+1),20),25, ' '));
                 ELSE
                    FND_FILE.put(FND_FILE.OUTPUT,l_empty_string||l_empty_string
                                                 ||SUBSTR(l_empty_string,1,5));
                 END IF;
               END LOOP;
         FND_FILE.put_line(FND_FILE.OUTPUT,' ');
        END LOOP;
     ELSE
         fnd_file.put_line(FND_FILE.OUTPUT,FND_MESSAGE.get_string('OKS','OKS_RR_MIG_SUCCESS'));
     END IF;

     FND_FILE.put_line(FND_FILE.OUTPUT,' ');
--    FND_FILE.put_line(FND_FILE.OUTPUT,'Contract Headers History');
     FND_FILE.put_line(FND_FILE.OUTPUT,FND_MESSAGE.get_string('OKS','OKS_RR_HDR_HIST'));
     FND_FILE.put_line(FND_FILE.OUTPUT,l_dash_string||l_dash_string
                                     ||SUBSTR(l_dash_string,1,4));
     FND_FILE.put_line(FND_FILE.OUTPUT,' ');
--    FND_FILE.put_line(FND_FILE.OUTPUT,'Contract Number          Major Version    Billto                   Status    Start Date    End Date     Date Terminated   Credit Card Number  Expiration Date');
     FND_FILE.put_line(FND_FILE.OUTPUT,
                       RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_CONTRACT_NUM'),25)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_MAJOR_VER'),17)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_BILL_TO'),25)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_STATUS'),10)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_START_DATE'),14)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_END_DATE'),13)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_DATE_TERM'),18)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_CCR_NUM'),20)
                     ||FND_MESSAGE.get_string('OKS','OKS_RR_EXP_DATE'));
     FND_FILE.put_line(FND_FILE.OUTPUT,l_dash_string||l_dash_string||l_dash_string
                                     ||l_dash_string||l_dash_string||l_dash_string
                                     ||l_dash_string||l_dash_string||l_dash_string
                                     ||l_dash_string||l_dash_string||l_dash_string
                                     ||l_dash_string||l_dash_string||l_dash_string
                                     ||SUBSTR(l_dash_string,1,7));
     FND_FILE.put_line(FND_FILE.OUTPUT,' ');

     OPEN get_hdr_hist_csr;
     FETCH get_hdr_hist_csr
     BULK COLLECT INTO contract_id,
            contract_number,
            contract_version,
            contract_sdate,
            contract_edate,
            date_terminated,
            contract_status,
            cc_number,
            cc_exp_date,
            party_name;

     CLOSE get_hdr_hist_csr;

     IF contract_id.COUNT > 0
     THEN
        FOR i IN 1 .. contract_id.COUNT
        LOOP
               FND_FILE.put(FND_FILE.OUTPUT,RPAD (SUBSTR(contract_number (i),1, 20),25,' ' ));
               FND_FILE.put(FND_FILE.OUTPUT,RPAD (contract_version (i),17, ' '));
               IF party_name (i) IS NOT NULL
               THEN
                   FND_FILE.put(FND_FILE.OUTPUT,RPAD(SUBSTR (party_name (i), 1, 20),25, ' '));
               ELSE
                    FND_FILE.put(FND_FILE.OUTPUT,l_empty_string||l_empty_string
                                                 ||SUBSTR(l_empty_string,1,5));
               END IF;
               FND_FILE.put(FND_FILE.OUTPUT,RPAD(contract_status (i),10, ' '));
               FND_FILE.put(FND_FILE.OUTPUT,RPAD(contract_sdate (i), 14, ' '));
               FND_FILE.put(FND_FILE.OUTPUT,RPAD(contract_edate (i), 13, ' '));
               IF date_terminated(i) IS NOT  NULL
               THEN
                   FND_FILE.put(FND_FILE.OUTPUT,RPAD(date_terminated(i),18, ' '));
               ELSE
                   FND_FILE.put(FND_FILE.OUTPUT,l_empty_string||SUBSTR(l_empty_string,1,8));
               END IF;
               FND_FILE.put(FND_FILE.OUTPUT,RPAD(cc_number(i), 20,' '));
               FND_FILE.put(FND_FILE.OUTPUT,RPAD(cc_exp_date(i), 15, ' '));

               l_cont_length    := LENGTH (contract_number(i));
               l_party_length   := NVL(LENGTH (party_name(i)),0);

               IF l_cont_length  >= l_party_length
               THEN
                   l_max_length := l_cont_length;
               ELSE
                   l_max_length := l_party_length;
               END IF;

               FOR j IN 1 ..FLOOR (l_max_length / 20)
               LOOP
                 FND_FILE.put_line(FND_FILE.OUTPUT,' ');
                 IF contract_number(i) IS NOT NULL AND (SUBSTR (contract_number (i), (j*20+1),20)) IS NOT NULL
                 THEN
                    FND_FILE.put(FND_FILE.OUTPUT,RPAD(SUBSTR (contract_number (i), (j*20+1),20),25, ' '));
                 ELSE
                    FND_FILE.put(FND_FILE.OUTPUT,l_empty_string||l_empty_string
                                                 ||SUBSTR(l_empty_string,1,5));
                 END IF;
                 FND_FILE.put(FND_FILE.OUTPUT,l_empty_string||SUBSTR(l_empty_string,1,7));
                 IF party_name(i) IS NOT NULL AND (SUBSTR (party_name (i), (j*20+1),20)) IS NOT NULL
                 THEN
                    FND_FILE.put(FND_FILE.OUTPUT,RPAD(SUBSTR (party_name (i), (j*20+1),20),25, ' '));
                 ELSE
                    FND_FILE.put(FND_FILE.OUTPUT,l_empty_string||l_empty_string
                                                 ||SUBSTR(l_empty_string,1,5));
                 END IF;
               END LOOP;
         FND_FILE.put_line(FND_FILE.OUTPUT,' ');
        END LOOP;
     ELSE
         fnd_file.put_line(FND_FILE.OUTPUT,FND_MESSAGE.get_string('OKS','OKS_RR_MIG_SUCCESS'));
     END IF;

--    FND_FILE.put_line(FND_FILE.OUTPUT,'Contract Lines');
     FND_FILE.put_line(FND_FILE.OUTPUT,FND_MESSAGE.get_string('OKS','OKS_RR_CONTRACT_LINES'));
     FND_FILE.put_line(FND_FILE.OUTPUT,l_dash_string|| SUBSTR(l_dash_string,1,4));
     FND_FILE.put_line(FND_FILE.OUTPUT,' ');
--    FND_FILE.put_line(FND_FILE.OUTPUT,'Contract Number          Line Number   Billto                   Service Name             Status    Start Date    End Date     Date Terminated   Credit Card Number  Expiration Date ');
     FND_FILE.put_line(FND_FILE.OUTPUT,
                       RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_CONTRACT_NUM'),25)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_LINE_NUMBER'),14)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_BILL_TO'),25)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_SRV_NAME'),25)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_STATUS'),10)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_START_DATE'),14)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_END_DATE'),13)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_DATE_TERM'),18)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_CCR_NUM'),20)
                     ||FND_MESSAGE.get_string('OKS','OKS_RR_EXP_DATE'));
     FND_FILE.put_line(FND_FILE.OUTPUT,l_dash_string||l_dash_string||l_dash_string
                                     ||l_dash_string||l_dash_string||l_dash_string
                                     ||l_dash_string||l_dash_string||l_dash_string
                                     ||l_dash_string||l_dash_string||l_dash_string
                                     ||l_dash_string||l_dash_string||l_dash_string
                                     ||l_dash_string||l_dash_string||SUBSTR(l_dash_string,1,9));
     FND_FILE.put_line(FND_FILE.OUTPUT,' ');

      line_id.DELETE;
      contract_number.DELETE;
      line_number.DELETE;
      line_sdate.DELETE;
      line_edate.DELETE;
      date_terminated.DELETE;
      line_status.DELETE;
      cc_number.DELETE;
      cc_exp_date.DELETE;
      party_name.DELETE;
      service_name.DELETE;

     OPEN get_line_csr;
     FETCH get_line_csr
     BULK COLLECT INTO line_id,
            contract_number,
            line_number,
            line_sdate,
            line_edate,
            date_terminated,
            line_status,
            cc_number,
            cc_exp_date,
            party_name,
            service_name;

     CLOSE get_line_csr;

     IF line_id.COUNT > 0
     THEN
        FOR i IN 1 .. line_id.COUNT
        LOOP
               FND_FILE.put(FND_FILE.OUTPUT,RPAD (SUBSTR(contract_number (i),1,20), 25,' ' ));
               FND_FILE.put(FND_FILE.OUTPUT,RPAD (line_number (i),14, ' '));
               IF party_name (i) IS NOT NULL
               THEN
                   IF LENGTH(party_name(i)) > 20 THEN
                       FND_FILE.put(FND_FILE.OUTPUT,RPAD(SUBSTR (party_name (i), 1, 20),25, ' '));
                   ELSE
                       FND_FILE.put(FND_FILE.OUTPUT,RPAD(party_name (i), 25, ' ' ));
                   END IF;
               ELSE
                   FND_FILE.put(FND_FILE.OUTPUT,l_empty_string||l_empty_string
                                                 ||SUBSTR(l_empty_string,1,5));
               END IF;

               IF Service_name (i) IS NOT NULL
               THEN
                   IF LENGTH(Service_name(i)) > 20 THEN
                       FND_FILE.put(FND_FILE.OUTPUT,RPAD(SUBSTR (Service_name (i), 1, 20),25, ' '));
                   ELSE
                       FND_FILE.put(FND_FILE.OUTPUT,RPAD(service_name (i), 25, ' ' ));
                   END IF;
               ELSE
                    FND_FILE.put(FND_FILE.OUTPUT,l_empty_string||l_empty_string
                                                 ||SUBSTR(l_empty_string,1,5));
               END IF;

               FND_FILE.put(FND_FILE.OUTPUT,RPAD(line_status (i),10, ' '));
               FND_FILE.put(FND_FILE.OUTPUT,RPAD(line_sdate (i), 14, ' '));
               FND_FILE.put(FND_FILE.OUTPUT,RPAD(line_edate (i), 13, ' '));
               IF date_terminated(i) IS NOT  NULL
               THEN
                   FND_FILE.put(FND_FILE.OUTPUT,RPAD(date_terminated(i),18, ' '));
               ELSE
                    FND_FILE.put(FND_FILE.OUTPUT,l_empty_string
                                                 ||SUBSTR(l_empty_string,1,8));
               END IF;
               FND_FILE.put(FND_FILE.OUTPUT,RPAD(cc_number(i), 20,' '));
               FND_FILE.put(FND_FILE.OUTPUT,RPAD(cc_exp_date(i), 15, ' '));

               l_cont_length    := LENGTH (contract_number(i));
               l_party_length   := LENGTH (party_name(i));
               l_service_length := LENGTH (service_name(i));

               IF l_cont_length  >= l_party_length
               AND l_cont_length >= l_service_length
               THEN
                   l_max_length := l_cont_length;
               ELSIF l_party_length >= l_cont_length
               AND l_party_length   >= l_service_length
               THEN
                   l_max_length := l_party_length;
               ELSIF l_service_length >= l_cont_length
               AND l_service_length   >= l_service_length
               THEN
                   l_max_length := l_service_length;
               END IF;

               FOR j IN 1 ..FLOOR (l_max_length / 20)
               LOOP
                 FND_FILE.put_line(FND_FILE.OUTPUT,' ');
                 IF contract_number(i) IS NOT NULL AND (SUBSTR (contract_number (i), (j*20+1),20)) IS NOT NULL
                 THEN
                    FND_FILE.put(FND_FILE.OUTPUT,RPAD(SUBSTR (contract_number (i), (j*20+1),20),25, ' '));
                 ELSE
                    FND_FILE.put(FND_FILE.OUTPUT,l_empty_string||l_empty_string
                                                 ||SUBSTR(l_empty_string,1,5));
                 END IF;
                 FND_FILE.put(FND_FILE.OUTPUT,l_empty_string||SUBSTR(l_empty_string,1,4));
                 IF party_name(i) IS NOT NULL AND (SUBSTR (party_name (i), (j*20+1),20)) IS NOT NULL
                 THEN
                    FND_FILE.put(FND_FILE.OUTPUT,RPAD(SUBSTR (party_name (i), (j*20+1),20),25, ' '));
                 ELSE
                    FND_FILE.put(FND_FILE.OUTPUT,l_empty_string||l_empty_string
                                                 ||SUBSTR(l_empty_string,1,5));
                 END IF;
                 IF service_name(i) IS NOT NULL AND (SUBSTR (service_name (i), (j*20+1),20)) IS NOT null
                 THEN
                    FND_FILE.put(FND_FILE.OUTPUT,RPAD(SUBSTR (service_name (i), (j*20+1),20),25, ' '));
                 ELSE
                    FND_FILE.put(FND_FILE.OUTPUT,l_empty_string||l_empty_string
                                                 ||SUBSTR(l_empty_string,1,5));
                 END IF;
               END LOOP;
         FND_FILE.put_line(FND_FILE.OUTPUT,' ');
        END LOOP;
     ELSE
         fnd_file.put_line(FND_FILE.OUTPUT,FND_MESSAGE.get_string('OKS','OKS_RR_MIG_SUCCESS'));
     END IF;

     FND_FILE.put_line(FND_FILE.OUTPUT,' ');
--    FND_FILE.put_line(FND_FILE.OUTPUT,'Contract Lines History');
     FND_FILE.put_line(FND_FILE.OUTPUT,FND_MESSAGE.get_string('OKS','OKS_RR_LINE_HIST'));
     FND_FILE.put_line(FND_FILE.OUTPUT,l_dash_string||l_dash_string
                                      ||SUBSTR(l_dash_string,1,2));
     FND_FILE.put_line(FND_FILE.OUTPUT,' ');
--    FND_FILE.put_line(FND_FILE.OUTPUT,'Contract Number          Major Version   Line Number   Billto                   Service Name             Status    Start Date     End Date   Date Terminated    Credit Card Number  Expiration Date');
     FND_FILE.put_line(FND_FILE.OUTPUT,
                       RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_CONTRACT_NUM'),25)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_MAJOR_VER'),16)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_LINE_NUMBER'),14)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_BILL_TO'),25)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_SRV_NAME'),25)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_STATUS'),10)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_START_DATE'),14)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_END_DATE'),13)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_DATE_TERM'),18)
                     ||RPAD(FND_MESSAGE.get_string('OKS','OKS_RR_CCR_NUM'),20)
                     ||FND_MESSAGE.get_string('OKS','OKS_RR_EXP_DATE'));
     FND_FILE.put_line(FND_FILE.OUTPUT,l_dash_string||l_dash_string||l_dash_string
                                     ||l_dash_string||l_dash_string||l_dash_string
                                     ||l_dash_string||l_dash_string||l_dash_string
                                     ||l_dash_string||l_dash_string||l_dash_string
                                     ||l_dash_string||l_dash_string||l_dash_string
                                     ||l_dash_string||l_dash_string||l_dash_string
                                     ||l_dash_string||SUBSTR(l_dash_string,1,5));
     FND_FILE.put_line(FND_FILE.OUTPUT,' ');

      line_id.DELETE;
      contract_number.DELETE;
      line_number.DELETE;
      line_sdate.DELETE;
      line_edate.DELETE;
      date_terminated.DELETE;
      line_status.DELETE;
      cc_number.DELETE;
      cc_exp_date.DELETE;
      party_name.DELETE;
      service_name.DELETE;

     OPEN get_line_hist_csr;
     FETCH get_line_hist_csr
     BULK COLLECT INTO line_id,
            contract_number,
            line_version,
            line_number,
            line_sdate,
            line_edate,
            date_terminated,
            line_status,
            cc_number,
            cc_exp_date,
            party_name,
            service_name;

     CLOSE get_line_hist_csr;

     IF line_id.COUNT > 0
     THEN
        FOR i IN 1 .. line_id.COUNT
        LOOP
               FND_FILE.put(FND_FILE.OUTPUT,RPAD (SUBSTR(contract_number (i),1,20), 25,' ' ));
               FND_FILE.put(FND_FILE.OUTPUT,RPAD(line_version(i),16));
               FND_FILE.put(FND_FILE.OUTPUT,RPAD (line_number (i),14, ' '));
               IF party_name (i) IS NOT NULL
               THEN
                   IF LENGTH(party_name(i)) > 20 THEN
                       FND_FILE.put(FND_FILE.OUTPUT,RPAD(SUBSTR (party_name (i), 1, 20),25, ' '));
                   ELSE
                       FND_FILE.put(FND_FILE.OUTPUT,RPAD(party_name (i), 25, ' ' ));
                   END IF;
               ELSE
                       FND_FILE.put(FND_FILE.OUTPUT,l_empty_string
                                    ||l_empty_string ||SUBSTR(l_empty_string,1,5));
               END IF;

               IF Service_name (i) IS NOT NULL
               THEN
                   IF LENGTH(Service_name(i)) > 20 THEN
                       FND_FILE.put(FND_FILE.OUTPUT,RPAD(SUBSTR (Service_name (i), 1, 20),25, ' '));
                   ELSE
                       FND_FILE.put(FND_FILE.OUTPUT,RPAD(service_name (i), 25, ' ' ));
                   END IF;
               ELSE
                    FND_FILE.put(FND_FILE.OUTPUT,l_empty_string||l_empty_string
                                                 ||SUBSTR(l_empty_string,1,5));
               END IF;

               FND_FILE.put(FND_FILE.OUTPUT,RPAD(line_status (i),10, ' '));
               FND_FILE.put(FND_FILE.OUTPUT,RPAD(line_sdate (i), 14, ' '));
               FND_FILE.put(FND_FILE.OUTPUT,RPAD(line_edate (i), 13, ' '));
               IF date_terminated(i) IS NOT  NULL
               THEN
                   FND_FILE.put(FND_FILE.OUTPUT,RPAD(date_terminated(i),18, ' '));
               ELSE
                    FND_FILE.put(FND_FILE.OUTPUT,l_empty_string
                                                 ||SUBSTR(l_empty_string,1,8));
               END IF;
               FND_FILE.put(FND_FILE.OUTPUT,RPAD(cc_number(i), 20,' '));
               FND_FILE.put(FND_FILE.OUTPUT,RPAD(cc_exp_date(i), 15, ' '));

               l_cont_length    := LENGTH (contract_number(i));
               l_party_length   := LENGTH (party_name(i));
               l_service_length := LENGTH (service_name(i));

               IF l_cont_length  >= l_party_length
               AND l_cont_length >= l_service_length
               THEN
                   l_max_length := l_cont_length;
               ELSIF l_party_length >= l_cont_length
               AND l_party_length   >= l_service_length
               THEN
                   l_max_length := l_party_length;
               ELSIF l_service_length >= l_cont_length
               AND l_service_length   >= l_service_length
               THEN
                   l_max_length := l_service_length;
               END IF;

               FOR j IN 1 ..FLOOR (l_max_length / 20)
               LOOP
                 FND_FILE.put_line(FND_FILE.OUTPUT,' ');
                 IF contract_number(i) IS NOT NULL AND (SUBSTR (contract_number (i), (j*20+1),20)) IS NOT NULL
                 THEN
                    FND_FILE.put(FND_FILE.OUTPUT,RPAD(SUBSTR (contract_number (i), (j*20+1),20),25, ' '));
                 ELSE
                    FND_FILE.put(FND_FILE.OUTPUT,l_empty_string||l_empty_string
                                                 ||SUBSTR(l_empty_string,1,5));
                 END IF;
                 FND_FILE.put(FND_FILE.OUTPUT,l_empty_string||l_empty_string ||l_empty_string);
                 IF party_name(i) IS NOT NULL AND (SUBSTR (party_name (i), (j*20+1),20)) IS NOT NULL
                 THEN
                    FND_FILE.put(FND_FILE.OUTPUT,RPAD(SUBSTR (party_name (i), (j*20+1),20),25, ' '));
                 ELSE
                    FND_FILE.put(FND_FILE.OUTPUT,l_empty_string||l_empty_string
                                                 ||SUBSTR(l_empty_string,1,5));
                 END IF;
                 IF service_name(i) IS NOT NULL AND (SUBSTR (service_name (i), (j*20+1),20)) IS NOT null
                 THEN
                    FND_FILE.put(FND_FILE.OUTPUT,RPAD(SUBSTR (service_name (i), (j*20+1),20),25, ' '));
                 ELSE
                    FND_FILE.put(FND_FILE.OUTPUT,l_empty_string||l_empty_string
                                                 ||SUBSTR(l_empty_string,1,5));
                 END IF;

               END LOOP;
         FND_FILE.put_line(FND_FILE.OUTPUT,' ');
        END LOOP;
     ELSE
         fnd_file.put_line(FND_FILE.OUTPUT,FND_MESSAGE.get_string('OKS','OKS_RR_MIG_SUCCESS'));
     END IF;
  END;



Procedure Purge_CC_Number
(
	ERRBUF	OUT NOCOPY VARCHAR2,
	RETCODE	OUT NOCOPY NUMBER,
    P_BATCH_SIZE      IN NUMBER
)
Is
cursor l_hdr_ranges(l_bucket_size number) is
   SELECT /*+ parallel(WBR) */
            WB_Low
            ,WB_High,rownum num
      FROM
      (SELECT /*+ no_merge parallel(WB) */ MIN(ID) WB_Low, MAX(ID) WB_High
         FROM
           (SELECT /*+ no_merge parallel(khdr) */ ID, FLOOR((ROWNUM-1)/l_bucket_size) Worker_Bucket
            FROM
			 ( SELECT id
			    FROM oks_k_headers_b okshdr
			    WHERE ((okshdr.cc_no IS NOT NULL
			            AND okshdr.payment_type = 'CCR'
			            AND okshdr.trxn_extension_id is not null)
                            OR
                            (okshdr.trxn_extension_id is null
                             AND okshdr.chr_id in (select chr_id from oks_rule_error))

                           )
			     order by id) KHDR) WB GROUP BY Worker_Bucket) WBR;

cursor l_hdr_rule_ranges(l_bucket_size number) is
   SELECT /*+ parallel(WBR) */
            WB_Low
            ,WB_High,rownum num
      FROM
      (SELECT /*+ no_merge parallel(WB) */ MIN(ID) WB_Low, MAX(ID) WB_High
         FROM
           (SELECT /*+ no_merge parallel(khdr) */ ID, FLOOR((ROWNUM-1)/l_bucket_size) Worker_Bucket
            FROM
			 (       Select  rl.Id
                     From   okc_rules_b rl
                          , okc_rule_groups_b rg
                          , Oks_k_headers_b Kh
                     Where rl.rgp_id = rg.id
                     And   rl.rule_information_category = 'CCR'
                     And   rl.rule_information1 is not null
                     And   ((rg.chr_id = Kh.chr_id
                           And   Kh.trxn_extension_id  is not null)
                           Or
                           (rg.chr_id in (select chr_id from oks_rule_error))
                           )
			     order by id) KHDR) WB GROUP BY Worker_Bucket) WBR;

cursor l_line_ranges(l_bucket_size number) is
   SELECT /*+ parallel(WBR) */
            WB_Low
            ,WB_High,rownum num
      FROM
      (SELECT /*+ no_merge parallel(WB) */ MIN(ID) WB_Low, MAX(ID) WB_High
         FROM
           (SELECT /*+ no_merge parallel(kln) */ ID, FLOOR((ROWNUM-1)/l_bucket_size) Worker_Bucket
            FROM
			 ( SELECT oksline.id
			    FROM oks_k_lines_b oksline, okc_k_lines_b okcline
			    WHERE oksline.cle_id=okcline.id
                      and okcline.lse_id in (1,12,19,46)
                      and ((oksline.cc_no IS NOT NULL
			         AND oksline.payment_type = 'CCR'
			         AND oksline.trxn_extension_id is not null)
                           OR
                          (oksline.trxn_extension_id is null
                           AND oksline.cle_id in (select cle_id from oks_rule_error))
                          )
			     order by id) KLN) WB GROUP BY Worker_Bucket) WBR;






Cursor l_hdr_hist_agg_csr IS

  Select /*+ PARALLEL(okshdrh) */
         min(okshdrh.id) minid,
         max(okshdrh.id) maxid,
         avg(okshdrh.id) avgid,
         stddev(okshdrh.id) stdid,
         count(*) total
    From OKS_K_HEADERS_BH okshdrh ;

Cursor l_line_hist_agg_csr IS
  Select /*+ PARALLEL(okslineh) */
         min(okslineh.id) minid,
         max(okslineh.id) maxid,
         avg(okslineh.id) avgid,
         stddev(okslineh.id) stdid,
         count(*) total
    From OKS_K_LINES_BH okslineh ;

l_agg_rec l_line_hist_agg_csr%rowtype;
l_sub_requests number;
l_sub_req number;
l_batch_size   number;
l_ret number;


Begin

     FND_FILE.PUT_LINE (FND_FILE.LOG, 'Start of OKS_CREDIT_CARD_PURGE ');


 IF (FND_CONC_GLOBAL.request_data is null)  THEN
        -- The following csr gets records from Header history table
            Open  l_hdr_hist_agg_csr;
            Fetch l_hdr_hist_agg_csr into l_agg_rec;
            Close l_hdr_hist_agg_csr;

            FND_FILE.PUT_LINE (FND_FILE.LOG, 'Cursor opened is l_hdr_hist_agg_csr');
            FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_agg_rec.minid = '|| l_agg_rec.minid );
            FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_agg_rec.maxid = '|| l_agg_rec.maxid );
            FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_agg_rec.total = '|| l_agg_rec.total );



       l_ret := FND_REQUEST.submit_request('OKS',
                                             'OKS_UPDCC_HDRH',
                                              to_char(l_sub_requests), -- UI job display
                                              null,
                                              TRUE, -- TRUE means isSubRequest
                                              l_agg_rec.minid,
                                              l_agg_rec.maxid,nvl(l_batch_size,10000));

       IF (l_ret = 0) then
             errbuf := fnd_message.get;
             retcode := 2;
             FND_FILE.PUT_LINE (FND_FILE.LOG, 'Sub-request failed to submit: ' || errbuf);
             return;
       ELSE
             FND_FILE.PUT_LINE (FND_FILE.LOG, 'Sub-request '||to_char(l_ret)||' submitted');
             FND_FILE.PUT_LINE (FND_FILE.LOG, 'Sub-request '||to_char(l_ret)||' p_low_id ==> '|| l_agg_rec.minid || ' l_hig_id ==> '||l_agg_rec.maxid );
       END IF;



--    The following csr gets records from Line history table
            open  l_line_hist_agg_csr;
            fetch l_line_hist_agg_csr into l_agg_rec;
            close l_line_hist_agg_csr;

            FND_FILE.PUT_LINE (FND_FILE.LOG, 'Cursor opened is l_line_hist_agg_csr' );
            FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_agg_rec.minid = '|| l_agg_rec.minid );
            FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_agg_rec.maxid = '|| l_agg_rec.maxid );
            FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_agg_rec.total = '|| l_agg_rec.total );



           l_ret := FND_REQUEST.submit_request  ('OKS',
                                             'OKS_UPDCC_LINEH',
                                              to_char(l_sub_requests), -- UI job display
                                              null,
                                              TRUE, -- TRUE means isSubRequest
                                              l_agg_rec.minid,
                                              l_agg_rec.maxid,nvl(l_batch_size,10000));

       IF (l_ret = 0) then
             errbuf := fnd_message.get;
             retcode := 2;
             FND_FILE.PUT_LINE (FND_FILE.LOG, 'Sub-request Line History failed to submit: ' || errbuf);
             return;
       ELSE
             FND_FILE.PUT_LINE (FND_FILE.LOG, 'Sub-request '||to_char(l_ret)||' submitted');
             FND_FILE.PUT_LINE (FND_FILE.LOG, 'Sub-request '||to_char(l_ret)||' p_low_id ==> '|| l_agg_rec.minid || ' l_hig_id ==> '||l_agg_rec.maxid );
       END IF;

       -- Process the header records
        ---errorout_n(p_batch_size);
         FOR range_rec in l_hdr_ranges(p_batch_size)
         LOOP
            --FND_FILE.PUT_LINE (FND_FILE.LOG, 'Submitting Header CC no request');
            ---errorout_n('in hdr range');
            l_ret := FND_REQUEST.submit_request('OKS',
                                               'OKS_UPDCC_HDR',
                                              to_char(range_rec.num), -- UI job display
                                              null,
                                              TRUE, -- TRUE means isSubRequest
                                              range_rec.wb_low,
                                              range_rec.wb_high,
                                              nvl(l_batch_size,10000));

           IF (l_ret = 0) then
               errbuf := fnd_message.get;
               retcode := 2;
               FND_FILE.PUT_LINE (FND_FILE.LOG, 'Sub-request failed to submit: ' || errbuf);
               return;
           ELSE
               FND_FILE.PUT_LINE (FND_FILE.LOG, 'Sub-request '||to_char(l_ret)||' submitted');
               FND_FILE.PUT_LINE (FND_FILE.LOG, 'Sub-request '||to_char(l_ret)||' p_low_id ==> '|| range_rec.wb_low || ' l_hig_id ==> '||range_rec.wb_high );
           END IF;

         END LOOP;

         -- Process the line records
         FOR range_rec in l_line_ranges(l_batch_size)
         LOOP
         ---errorout_n('in line range');

               FND_FILE.PUT_LINE (FND_FILE.LOG, 'Submitting Header CC no request');
            l_ret := FND_REQUEST.submit_request('OKS',
                                                'OKS_UPDCC_LINE',
                                                range_rec.num, -- UI job display
                                                null,
                                                TRUE, -- TRUE means isSubRequest
                                               range_rec.wb_low,
                                              range_rec.wb_high,
                                              nvl(l_batch_size,10000));

           IF (l_ret = 0) then
               errbuf := fnd_message.get;
               retcode := 2;
               FND_FILE.PUT_LINE (FND_FILE.LOG, 'Sub-request failed to submit: ' || errbuf);
               return;
           ELSE
               FND_FILE.PUT_LINE (FND_FILE.LOG, 'Sub-request '||to_char(l_ret)||' submitted');
               FND_FILE.PUT_LINE (FND_FILE.LOG, 'Sub-request '||to_char(l_ret)||' p_low_id ==> '|| range_rec.wb_low || ' l_hig_id ==> '||range_rec.wb_high );
           END IF;

         END LOOP;

         FND_CONC_GLOBAL.set_req_globals(conc_status => 'PAUSED',
                                         request_data => to_char(l_sub_requests));
             errbuf := to_char(l_sub_requests) || ' sub-requests submitted';
             retcode := 0;
          return;


  END IF;

End Purge_CC_Number;

PROCEDURE UPDATE_CC_LINEH(
    ERRBUF            OUT  NOCOPY VARCHAR2,
    RETCODE           OUT  NOCOPY NUMBER,
    p_id_low          IN NUMBER,
    p_id_high           IN NUMBER,
    p_batchsize       IN NUMBER ) IS


Cursor l_line_hist_csr Is
Select Ks.id
From   oks_k_lines_bh ks
where  Ks.cc_no is not null
And    Ks.trxn_extension_id is not null
And    Ks.id between p_id_low and p_id_high;

l_line_id               l_num_tbl;
Begin

      Open l_line_hist_csr;
      Loop
          Fetch l_line_hist_csr bulk collect into l_line_id
          limit p_batchsize;
          EXIT WHEN l_line_id.count = 0 ;


          -- Update Line history table

          Forall i in l_line_id.first..l_line_id.last
          Update Oks_k_Lines_bh
          Set cc_no = null,
          cc_bank_acct_id = null,
          cc_expiry_date = null,
          cc_auth_code  = null
          Where id = l_line_id(i);

       End Loop;

       Close l_line_hist_csr;


End UPDATE_CC_LINEH;

PROCEDURE UPDATE_CC_HEADERH(
    ERRBUF            OUT  NOCOPY VARCHAR2,
    RETCODE           OUT  NOCOPY NUMBER,
    p_id_low          IN NUMBER,
    p_id_high           IN NUMBER,
    p_batchsize       IN NUMBER ) IS


Cursor l_hdr_hist_csr Is
Select id, chr_id
From   oks_k_headers_bh
Where  cc_no is not null
And    trxn_extension_id is not null
And    id between p_id_low and p_id_high;

l_hdr_id               l_num_tbl;
l_chr_id               l_num_tbl;

Begin

      Open l_hdr_hist_csr;
      Loop
          Fetch l_hdr_hist_csr bulk collect into l_hdr_id, l_chr_id
          limit p_batchsize;

          EXIT WHEN l_hdr_id.count = 0 ;


          -- Update Header history table

          Forall i in l_hdr_id.first..l_hdr_id.last
          Update Oks_k_headers_bh
          Set cc_no = null,
          cc_bank_acct_id = null,
          cc_expiry_date = null,
          cc_auth_code  = null
          Where id = l_hdr_id(i);

          Forall i in l_chr_id.first..l_chr_id.last
          Update okc_rules_bh
          Set rule_information1 = null,
          rule_information2 = null,
          rule_information3 = null,
          rule_information4  = null
          Where dnz_chr_id = l_chr_id(i)
          and rule_information_category = 'CCR';

       End Loop;

       Close l_hdr_hist_csr;


End UPDATE_CC_HEADERH;


PROCEDURE UPDATE_CC_HEADER(
    ERRBUF            OUT  NOCOPY VARCHAR2,
    RETCODE           OUT  NOCOPY NUMBER,
    p_id_low          IN NUMBER,
    p_id_high           IN NUMBER,
    p_batchsize       IN NUMBER ) IS


Cursor l_hdr_csr Is
Select id, chr_id
From   oks_k_headers_b
Where  cc_no is not null
And    trxn_extension_id is not null
And    id between p_id_low and p_id_high;

l_hdr_id               l_num_tbl;
l_chr_id               l_num_tbl;

Begin

      Open l_hdr_csr;
      Loop
          Fetch l_hdr_csr bulk collect into l_hdr_id, l_chr_id
          limit p_batchsize;

          EXIT WHEN l_hdr_id.count = 0 ;


          -- Update Header  table

          Forall i in l_hdr_id.first..l_hdr_id.last
          Update Oks_k_headers_b
          Set cc_no = null,
          cc_bank_acct_id = null,
          cc_expiry_date = null,
          cc_auth_code  = null
          Where id = l_hdr_id(i);

          Forall i in l_chr_id.first..l_chr_id.last
          Update okc_rules_b
          Set rule_information1 = null,
          rule_information2 = null,
          rule_information3 = null,
          rule_information4  = null
          Where dnz_chr_id = l_chr_id(i)
          and rule_information_category = 'CCR';

       End Loop;

       Close l_hdr_csr;



End UPDATE_CC_HEADER;

PROCEDURE UPDATE_CC_HEADER_RULE(
    ERRBUF            OUT  NOCOPY VARCHAR2,
    RETCODE           OUT  NOCOPY NUMBER,
    p_id_low          IN NUMBER,
    p_id_high           IN NUMBER,
    p_batchsize       IN NUMBER ) IS


Cursor l_hdr_rule_csr Is
Select rl.Id
From   okc_rules_b rl
     , okc_rule_groups_b rg
     , Oks_k_headers_b Kh
Where rl.rgp_id = rg.id
And   rl.rule_information_category = 'CCR'
And   rl.rule_information1 is not null
And   ((rg.chr_id = Kh.chr_id
        And   Kh.trxn_extension_id  is not null)
      Or
       (rg.chr_id in (select chr_id from oks_rule_error))
       )
And    rl.id between p_id_low and p_id_high;

l_hdr_id               l_num_tbl;
Begin

      Open l_hdr_rule_csr ;
      Loop
          Fetch l_hdr_rule_csr bulk collect into l_hdr_id
          limit p_batchsize;

          EXIT WHEN l_hdr_id.count = 0 ;


          -- Update Header Rule  table

          Forall i in l_hdr_id.first..l_hdr_id.last
          Update okc_rules_b
          Set rule_information1 = null
          Where id = l_hdr_id(i);

       End Loop;

      Close l_hdr_rule_csr ;



End UPDATE_CC_HEADER_RULE;


PROCEDURE UPDATE_CC_LINE(
    ERRBUF            OUT  NOCOPY VARCHAR2,
    RETCODE           OUT  NOCOPY NUMBER,
    p_id_low          IN NUMBER,
    p_id_high           IN NUMBER,
    p_batchsize       IN NUMBER ) IS


Cursor l_line_csr Is
Select Ks.id
From   oks_k_lines_b ks
Where  Ks.cc_no is not null
And    Ks.trxn_extension_id is not null
And    Ks.id between p_id_low and p_id_high;

l_line_id               l_num_tbl;

Begin

      Open l_line_csr;
      Loop
          Fetch l_line_csr bulk collect into l_line_id
          limit p_batchsize;
          EXIT WHEN l_line_id.count = 0 ;


          -- Update Line table

          Forall i in l_line_id.first..l_line_id.last
          Update Oks_k_Lines_b
          Set cc_no = null,
          cc_bank_acct_id = null,
          cc_expiry_date = null,
          cc_auth_code  = null
          Where id = l_line_id(i);

       End Loop;

       Close l_line_csr;


End UPDATE_CC_LINE;


END OKS_CCMIGRATE_PVT;

/
