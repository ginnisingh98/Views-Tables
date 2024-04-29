--------------------------------------------------------
--  DDL for Package Body OKS_BILL_REC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_BILL_REC_PUB" AS
 /* $Header: OKSPBRCB.pls 120.56.12010000.3 2010/01/20 13:42:55 harlaksh ship $ */


--------------------------------------------
-- Global Variable to store terminated amount
--------------------------------------------
g_bcl_id        NUMBER;
g_bsl_id        NUMBER;
g_credit_amount NUMBER;
G_MODULE_CURRENT   CONSTANT VARCHAR2(255) := 'oks.plsql.oks_bill_rec_pub';
------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 27-MAY-2005
-- DESCRIPTION:
-- This procedure will calculate the credit amount used for previewing
-- if the period start and period type are not null.
-------------------------------------------------------------------------
Procedure  Terminate_PPC
(
                           P_called_from          IN NUMBER DEFAULT NULL,
                           P_end_date             IN DATE,
                           P_termination_date     IN DATE,
                           P_top_line_id          IN NUMBER,
                           P_cp_line_id           IN NUMBER,
                           P_suppress_credit      IN VARCHAR2,
                           P_period_type          IN VARCHAR2,
                           P_period_start         IN VARCHAR2,
                           P_override_amount      IN NUMBER,
                           P_con_terminate_amount IN NUMBER,
                           X_return_status        OUT NOCOPY VARCHAR2
);
------------------------------------------------------------------------
-- End partial period computation logic
-------------------------------------------------------------------------

------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 27-MAY-2005
-- DESCRIPTION:
-- This procedure will calculate the credit amount used for previewing
-- if the period start and period type are not null.
-------------------------------------------------------------------------
Procedure get_term_amt_ppc
(
P_called_from IN NUMBER DEFAULT NULL,
P_line_id IN NUMBER ,
P_cov_line IN VARCHAR2,
P_termination_date IN DATE,
P_period_type   VARCHAR2,
P_period_start  VARCHAR2,
X_amount OUT NOCOPY NUMBER,
X_return_status OUT NOCOPY VARCHAR2
);
------------------------------------------------------------------------
-- End partial period computation logic
-------------------------------------------------------------------------

------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 27-MAY-2005
-- DESCRIPTION:
-- This new procedure will calculate the partial termination amount between
-- termination date and the billing period end using Time measure APIs for USAGE only.
---------------------------------------------------------------------------
Function Get_partial_term_amount
                       (
                       p_start_date        IN DATE,
                       p_end_date          IN DATE,
                       P_termination_date  IN DATE,
                       P_amount            IN NUMBER,
                       P_uom               IN VARCHAR2,
                       P_period_start      IN VARCHAR2,
                       P_period_type       IN VARCHAR2
                       )
RETURN NUMBER;


------------------------------------------------------------------------
  -- FUNCTION to get message
------------------------------------------------------------------------

PROCEDURE get_message(l_msg_cnt  IN            NUMBER,
                      l_msg_data IN OUT NOCOPY VARCHAR) IS
l_msg_index_out    NUMBER;
BEGIN
  IF (l_msg_cnt > 0)      THEN
    FOR i in 1..l_msg_cnt LOOP
      FND_MSG_PUB.GET
        (p_msg_index     => -1,
         p_encoded       => 'F',
         p_data          => l_msg_data,
         p_msg_index_out => l_msg_index_out);

       FND_FILE.PUT_LINE(FND_FILE.LOG,'Error Message = '||l_msg_data);
     END LOOP;
   END IF;
END get_message;

------------------------------------------------------------------------
  -- FUNCTION to generate id
------------------------------------------------------------------------

FUNCTION get_seq_id RETURN NUMBER IS
BEGIN
  RETURN(okc_p_util.raw_to_number(sys_guid()));
END get_seq_id;


------------------------------------------------------------------------
  -- FUNCTION to set top line for billing report
------------------------------------------------------------------------
 PROCEDURE Set_Top_line(
 P_PROCESSED_LINES_TBL          IN OUT    NOCOPY LINE_REPORT_TBL_TYPE,
 P_PROCESSED_SUB_LINES_TBL      IN OUT    NOCOPY LINE_REPORT_TBL_TYPE,
 P_ERROR_MESSAGE                IN               VARCHAR2,
 P_TOP_LINE                     IN               NUMBER) IS
 BEGIN
  FOR i in P_PROCESSED_LINES_TBL.FIRST..P_PROCESSED_LINES_TBL.LAST
  LOOP
    IF (P_PROCESSED_LINES_TBL(i).Line_id = p_top_line) THEN
      P_PROCESSED_LINES_TBL(i).Billed_YN := 'N';
      P_PROCESSED_LINES_TBL(i).Error_Message := P_ERROR_MESSAGE;
    END IF;
  END LOOP;
 END Set_top_line;

------------------------------------------------------------------------
  -- FUNCTION to set sub line for billing report
------------------------------------------------------------------------
PROCEDURE Set_sub_line(
 P_PROCESSED_LINES_TBL          IN OUT NOCOPY    LINE_REPORT_TBL_TYPE,
 P_PROCESSED_SUB_LINES_TBL      IN OUT NOCOPY    LINE_REPORT_TBL_TYPE,
 P_ERROR_MESSAGE                IN               VARCHAR2,
 P_TOP_LINE                     IN               NUMBER) IS
 BEGIN
   FOR i in P_PROCESSED_SUB_LINES_TBL.FIRST..P_PROCESSED_SUB_LINES_TBL.LAST
   LOOP
     IF (P_PROCESSED_SUB_LINES_TBL(i).Line_id = p_top_line) THEN
       P_PROCESSED_SUB_LINES_TBL(i).Billed_YN := 'N';
       P_PROCESSED_SUB_LINES_TBL(i).Error_Message := P_ERROR_MESSAGE;
     END IF;
   END LOOP;
 END Set_sub_line;



 ------------------------------------------------------------------------
  -- FUNCTION get_term_end_date
------------------------------------------------------------------------

FUNCTION get_term_end_date (
        p_cle_id           IN NUMBER,
        p_termination_date IN DATE
  ) RETURN Date IS
   Cursor check_hold(p_cle_id IN NUMBER) Is
     SELECT hold_billing
          FROM oks_k_headers_b   hdr,
               okc_k_lines_b     line
          WHERE line.id = p_cle_id
          AND   line.dnz_chr_id = hdr.chr_id;


  Cursor Termination_csr(p_cle_id NUMBER,p_termination_date DATE) IS
    SELECT lvl.date_end FROM oks_level_elements lvl
      WHERE lvl.cle_id = p_cle_id
      AND   trunc(p_termination_date ) BETWEEN trunc(lvl.date_start) AND
                                                    trunc(lvl.date_end);

l_ret_date   DATE;
l_hold       VARCHAR2(10);
BEGIN
  OPEN  check_hold(p_cle_id);
  FETCH check_hold into l_hold;
  CLOSE check_hold;
  IF (nvl(l_hold,'N') = 'Y') THEN
    OPEN  Termination_csr( p_cle_id,p_termination_date);
    FETCH Termination_csr into l_ret_date;
    -- BUG FIX 3450592 .  L_rel_date is populated with null
    IF (Termination_csr%NOTFOUND) THEN
      l_ret_date := NULL ;     --sysdate;
    END IF;
    CLOSE Termination_csr;
  ELSE
    l_ret_date := NULL ;       --sysdate;
  END IF;
  Return (l_ret_date);
END get_term_end_date;

-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 11-JUN-2005
-- Added period start and period type parameters
-------------------------------------------------------------------------
PROCEDURE Create_trx_records(
                             p_called_from          IN   NUMBER   DEFAULT Null ,
                             p_top_line_id          IN   NUMBER,
                             p_cov_line_id          IN   NUMBER,
                             p_date_from            IN   DATE,
                             p_date_to              IN   DATE,
                             p_amount               IN   NUMBER,
                             p_override_amount      IN   NUMBER,
                             p_suppress_credit      IN   VARCHAR2,
                             p_con_terminate_amount IN   NUMBER,
                             --p_existing_credit      IN   NUMBER,
                             p_bill_action          IN   VARCHAR2,
                             p_period_start         IN   VARCHAR2 DEFAULT NULL,
                             p_period_type          IN   VARCHAR2 DEFAULT NULL,
                             x_return_status        OUT  NOCOPY VARCHAR2
                             )
IS
 CURSOR bcl_cur (p_date_from IN DATE,
                 p_date_to   IN DATE ) IS
  SELECT  bcl.id                    bcl_bcl_id
         ,bcl.cle_id                bcl_cle_id
         ,bcl.btn_id                bcl_btn_id
         ,bcl.Date_Billed_from      bcl_date_billed_from
         ,bcl.Date_Billed_to        bcl_date_billed_to
         ,bcl.date_next_invoice     bcl_date_next_invoice
         ,bcl.amount                bcl_amount
         ,bcl.bill_action           bcl_bill_action
         ,bcl.Attribute_category    bcl_attribute_category
         ,bcl.Attribute1            bcl_attribute1
         ,bcl.Attribute2            bcl_attribute2
         ,bcl.Attribute3            bcl_attribute3
         ,bcl.Attribute4            bcl_attribute4
         ,bcl.Attribute5            bcl_attribute5
         ,bcl.Attribute6            bcl_attribute6
         ,bcl.Attribute7            bcl_attribute7
         ,bcl.Attribute8            bcl_attribute8
         ,bcl.Attribute9            bcl_attribute9
         ,bcl.Attribute10           bcl_attribute10
         ,bcl.Attribute11           bcl_attribute11
         ,bcl.Attribute12           bcl_attribute12
         ,bcl.Attribute13           bcl_attribute13
         ,bcl.Attribute14           bcl_attribute14
         ,bcl.Attribute15           bcl_attribute15
         ,bsl.id                    bsl_bsl_id
         ,bsl.cle_id                bsl_cle_id
         ,bsl.average               bsl_average
         ,bsl.amount                bsl_amount
         ,bsl.Date_Billed_from      bsl_date_billed_From
         ,bsl.Date_Billed_to        bsl_date_billed_to
         ,bsl.date_to_interface     bsl_date_to_interface
         ,bsl.Attribute_category    bsl_attribute_category
         ,bsl.Attribute1            bsl_attribute1
         ,bsl.Attribute2            bsl_attribute2
         ,bsl.Attribute3            bsl_attribute3
         ,bsl.Attribute4            bsl_attribute4
         ,bsl.Attribute5            bsl_attribute5
         ,bsl.Attribute6            bsl_attribute6
         ,bsl.Attribute7            bsl_attribute7
         ,bsl.Attribute8            bsl_attribute8
         ,bsl.Attribute9            bsl_attribute9
         ,bsl.Attribute10           bsl_attribute10
         ,bsl.Attribute11           bsl_attribute11
         ,bsl.Attribute12           bsl_attribute12
         ,bsl.Attribute13           bsl_attribute13
         ,bsl.Attribute14           bsl_attribute14
         ,bsl.Attribute15           bsl_attribute15
         --,bsl.manual_credit         line_existing_credit
         ,line.start_date           cov_start_date
         ,line.end_date             cov_end_date
         ,line.price_negotiated     cov_price_negotiated
   FROM
         okc_k_lines_b       line,
         oks_bill_cont_lines bcl,
         oks_bill_sub_lines  bsl
   WHERE bcl.Cle_id = p_top_line_id
   AND   bsl.cle_id = nvl(p_cov_line_id,bsl.cle_id)
   AND   bcl.id     = bsl.bcl_id
   AND   bcl.bill_action = 'RI'
   AND   bsl.amount > 0                      -- Added to avoid -ve inv rec generated during settlement cycle
   --09-FEB mchoudha changed from bcl to bsl
   --For OM contracts if the subline end date is less than the top line end date then the termination records
   --were no getting created because of the bcl condition.
   AND   trunc(bsl.date_billed_to) <= trunc(p_date_to)
   AND   trunc(bsl.date_billed_to) >= trunc(p_date_from)
   AND   line.id    =   bsl.cle_id
   AND   line.date_Terminated is NULL
/*
   and   not exists
         (select 1 from oks_bill_cont_lines bclsub
          where bclsub.cle_id = bcl.cle_id
          and  trunc(bclsub.date_billed_from) = trunc(bcl.date_billed_from)
          and  bclsub.bill_action = 'AV')
*/
   ORDER  by bcl.Date_billed_from, bcl.id desc;

CURSOR bsd_cur(p_bsl_id IN NUMBER) IS
   SELECT  bsl_id_averaged
          ,bsd_id
          ,bsd_id_applied
          ,ccr_id
          ,cgr_id
          ,start_reading
          ,end_reading
          ,unit_of_measure
          ,fixed
          ,actual
          ,default_default
          ,amcv_yn
          ,adjustment_level
          ,adjustment_minimum
          ,result
          ,amount
          ,Attribute_category
          ,Attribute1
          ,Attribute2
          ,Attribute3
          ,Attribute4
          ,Attribute5
          ,Attribute6
          ,Attribute7
          ,Attribute8
          ,Attribute9
          ,Attribute10
          ,Attribute11
          ,Attribute12
          ,Attribute13
          ,Attribute14
          ,Attribute15
    FROM  Oks_bill_sub_line_dtls
    WHERE bsl_id = p_bsl_id;

Cursor check_bcl(p_date_billed_from   IN   DATE
                ,p_date_billed_to     IN   DATE
                ,p_bill_action        IN   VARCHAR2)
     IS
    SELECT id
          ,amount
     FROM oks_bill_cont_lines
     WHERE cle_id = p_top_line_id
     AND   bill_Action = p_bill_Action
     AND   trunc(date_billed_from) = trunc(p_date_billed_from)
     AND   trunc(date_billed_to )  = trunc(p_date_billed_to)
     AND   btn_id is null;

Cursor hdr_cur (p_cle_id  IN  NUMBER) IS
    SELECT  line.Start_date
           ,line.End_date
           ,line.Date_Terminated
           ,line.dnz_chr_id
           ,line.sts_code
           ,line.lse_id
           ,line.line_number
           ,hdr.currency_code
           ,hdr.id
         FROM    okc_k_headers_b hdr ,
                 okc_k_lines_B   line
         WHERE   line.id = p_cle_id
         AND     line.dnz_chr_id = hdr.id;

Cursor qty_uom_csr(p_cle_id  IN NUMBER) Is
     SELECT  okc.Number_of_items
            ,tl.Unit_of_measure uom_code
     FROM   okc_k_items OKC
           ,mtl_units_of_measure_tl tl
     WHERE  okc.cle_id = P_cle_id
     AND    tl.uom_code = OKC.uom_code
     AND    tl.language = USERENV('LANG');

CURSOR inv_item_csr(p_cle_id IN NUMBER) Is
  SELECT  primary_uom_code
  FROM   Okc_K_items Item
        ,mtl_system_items mtl
        ,okc_k_lines_b      line
        ,okc_k_headers_b    hdr
  WHERE  item.cle_id = p_cle_id
  AND    line.id     = item.cle_id
  AND    hdr.id      = line.dnz_chr_id
  AND    mtl.inventory_item_id = item.object1_id1
  ---AND    mtl.organization_id = hdr.authoring_org_id;
  AND    mtl.organization_id = hdr.inv_organization_id;

Cursor bill_instance_csr (p_bcl_id in NUMBER,
                          p_bsl_id in NUMBER) is
       SELECT txn.bill_instance_number from oks_bill_txn_lines txn
       WHERE bcl_id = p_bcl_id
       AND   nvl(bsl_id,-1) = decode(bsl_id,NULL,-1,p_bsl_id);
      /*nvl condition added in above to take care of summary billing records.
        in case of summary billing bsl_id is null in above table*/

Cursor rules_csr(l_termination_date IN DATE,p_cov_line_id IN NUMBER) IS
    SELECT  str.uom_code      l_freq
      FROM oks_stream_levels_b str,
           oks_level_elements  lvl
      WHERE lvl.cle_id = p_cov_line_id
      AND   lvl.rul_id = str.id
      AND   l_termination_date between lvl.date_start and lvl.date_end;

Cursor avg_csr_bsl_amt(p_cle_id IN NUMBER, p_date_from IN DATE) IS
    SELECT sum(amount)
      FROM oks_bill_sub_lines
      WHERE cle_id =  p_cle_id
      AND   date_billed_from = p_date_from;

SUBTYPE l_bclv_tbl_type_in  is OKS_bcl_PVT.bclv_tbl_type;
  l_bclv_tbl_in   l_bclv_tbl_type_in;
  l_bclv_tbl_out  l_bclv_tbl_type_in;

SUBTYPE l_bslv_tbl_type_in  is OKS_bsl_PVT.bslv_tbl_type;
  l_bslv_tbl_in   l_bslv_tbl_type_in;
  l_bslv_tbl_out   l_bslv_tbl_type_in;

SUBTYPE l_bsdv_tbl_type_in  is OKS_bsd_PVT.bsdv_tbl_type;
  l_bsdv_tbl_in   l_bsdv_tbl_type_in;
  l_bsdv_tbl_out   l_bsdv_tbl_type_in;

bcl_rec                               BCL_CUR%ROWTYPE;
hdr_rec                               HDR_CUR%ROWTYPE;
inv_rec                               INV_ITEM_CSR%ROWTYPE;
rules_rec                             RULES_CSR%ROWTYPE;


l_cov_tbl                             OKS_BILL_REC_PUB.COVERED_TBL;
l_return_status                       VARCHAR2(20);
l_msg_data                            VARCHAR2(2000);
l_freq                                VARCHAR2(20);
l_temp_bcl_id_ri                      NUMBER := -11;  -- stores the bcl_id for invoice line
l_temp_bcl_id_tr                      NUMBER := -11;  -- stores the bcl_id for Credit line
l_msg_cnt                             NUMBER;
l_amount                              NUMBER;
l_bcl_id                              NUMBER;
l_bill_instance_number                NUMBER;
l_bill_amount                         NUMBER;
term_bsl_amount                       NUMBER;
l_diff                                NUMBER;
l_api_version         CONSTANT        NUMBER     := 1.0;
l_init_msg_list       CONSTANT        VARCHAR2(1):= 'F';
--l_bill_instance_number NUMBER;
l_termination_date                    DATE;



BEGIN

  l_return_status := OKC_API.G_RET_STS_SUCCESS;


  DBMS_TRANSACTION.SAVEPOINT('BEFORE_TRANSACTION');

  IF (p_bill_action in ('RI','SRI')) THEN


    OKS_BILL_REC_PUB.INSERT_BCL
     (
       P_CALLEDFROM        => 1,
       X_RETURN_STAT       => l_return_status,
       P_CLE_ID            => p_top_line_id,
       P_DATE_BILLED_FROM  => p_date_from,
       P_DATE_BILLED_TO    => p_date_to,
       P_DATE_NEXT_INVOICE => trunc(sysdate),
       P_BILL_ACTION       => p_bill_action ,
       P_OKL_FLAG          => 2,
       P_PRV               => 1,
       P_MSG_COUNT         => l_msg_cnt,
       P_MSG_DATA          => l_msg_data,
       X_BCL_ID            => l_bcl_id
       );

    OPEN  INV_ITEM_CSR(p_top_line_id);
    FETCH INV_ITEM_CSR into inv_rec;
    CLOSE INV_ITEM_CSR;


    OPEN  hdr_cur(p_top_line_id);
    FETCH hdr_cur into hdr_rec;
    CLOSE hdr_cur;


    l_cov_tbl(1).flag              := Null;
    l_cov_tbl(1).id                := p_cov_line_id ;
    l_cov_tbl(1).bcl_id            := l_bcl_id;
    l_cov_tbl(1).date_billed_from  := p_date_from;
    l_cov_tbl(1).date_billed_to    := p_date_to;
    l_cov_tbl(1).amount            := p_con_terminate_amount; --p_amount;
    l_cov_tbl(1).sign              := 1;
    l_cov_tbl(1).average           := 0;
    l_cov_tbl(1).unit_of_measure   := inv_rec.primary_uom_code;
    l_cov_tbl(1).fixed             := 0;
    l_cov_tbl(1).actual            := p_amount;
    l_cov_tbl(1).default_default   := 0;
    l_cov_tbl(1).amcv_yn           := 'N';
    l_cov_tbl(1).adjustment_level  := 0 ;
    l_cov_tbl(1).adjustment_minimum:= 0 ;
    l_cov_tbl(1).result            := p_amount ;
    l_cov_tbl(1).estimated_quantity:= 0;
    l_cov_tbl(1).x_stat            := Null ;
    l_cov_tbl(1).amount            := p_con_terminate_amount;  --p_amount;
    l_cov_tbl(1).bcl_amount        := p_con_terminate_amount;  --p_amount;
    l_cov_tbl(1).date_to_interface := sysdate;

    OKS_BILL_REC_PUB.Insert_all_subline
           (
            P_CALLEDFROM     => 1,
            X_RETURN_STAT    => l_return_status,
            P_COVERED_TBL    => l_cov_tbl,
            P_CURRENCY_CODE  => hdr_rec.currency_code,
            P_DNZ_CHR_ID     => hdr_rec.id,
            P_PRV            => 1,
            P_MSG_COUNT      => l_msg_cnt,
            P_MSG_DATA       => l_msg_data
            );

  --for ppc bug#4638641
  --The following logic is called only during
  --termination after repricing when the unbilled amount is
  --greater than the termination amount and termination date
  --is less than or equal to the max billed to date
  IF  p_period_start is NOT NULL and p_period_type IS NOT NULL
  THEN
        UPDATE oks_level_elements
        SET date_completed = p_date_to,
            amount = p_con_terminate_amount
        WHERE cle_id = p_cov_line_id
        AND   date_completed is null
        AND   date_start = p_date_from
        AND   date_end = p_date_to;

        UPDATE oks_level_elements
        SET date_completed = p_date_to,
        amount = amount-p_amount+p_con_terminate_amount
        WHERE cle_id = p_top_line_id
        AND   date_completed is null
        AND   date_start = p_date_from
        AND   date_end = p_date_to;

  END IF;

  ELSIF ( p_bill_action in ('AV','TR','STR')) THEN


    FOR bcl_rec in bcl_cur(p_date_from,p_date_to)
    LOOP
      OPEN  hdr_cur(bcl_rec.bsl_cle_id);
      FETCH hdr_cur into hdr_rec;
      CLOSE hdr_cur;

      OPEN  rules_csr(p_date_from,bcl_rec.bsl_cle_id);
      FETCH rules_csr into rules_rec;
      CLOSE rules_csr;

      l_bclv_tbl_in.delete;
      l_bclv_tbl_out.delete;
      l_bslv_tbl_in.delete;
      l_bslv_tbl_out.delete;


      IF ( bcl_rec.bcl_date_billed_from < p_date_from ) THEN
        l_bclv_tbl_in(1).DATE_BILLED_FROM   := p_date_from;
      ELSE
        l_bclv_tbl_in(1).DATE_BILLED_FROM   := bcl_rec.bcl_date_billed_from;
      END IF;

      l_bclv_tbl_in(1).DATE_BILLED_TO     := bcl_rec.bcl_date_billed_to;

/*****
            OPEN check_bcl(l_bclv_tbl_in(1).date_billed_from,
                     l_bclv_tbl_in(1).date_billed_to,
                     p_bill_action);
            FETCH check_bcl into l_bclv_tbl_in(1).id,
                           l_bclv_tbl_in(1).AMOUNT ;

      IF (check_bcl%NOTFOUND) THEN
**/

/***
    The above cursor is commented to fix bug# 4243931. the below if clause check is
    used to create credit bcl's for its corresponding invoice bcl's
***/
      if ( l_temp_bcl_id_ri <> bcl_rec.bcl_bcl_id) Then

        l_bclv_tbl_in(1).CLE_ID             := bcl_rec.bcl_cle_id;
        l_bclv_tbl_in(1).BTN_ID             := Null;
        l_bclv_tbl_in(1).SENT_YN            :=  'N';

        l_bclv_tbl_in(1).DATE_NEXT_INVOICE  := bcl_rec.bcl_date_next_invoice;
        l_bclv_tbl_in(1).ATTRIBUTE_CATEGORY := bcl_rec.bcl_attribute_category;
        l_bclv_tbl_in(1).ATTRIBUTE1         := bcl_rec.bcl_attribute1;
        l_bclv_tbl_in(1).ATTRIBUTE2         := bcl_rec.bcl_attribute2;
        l_bclv_tbl_in(1).ATTRIBUTE3         := bcl_rec.bcl_attribute3;
        l_bclv_tbl_in(1).ATTRIBUTE4         := bcl_rec.bcl_attribute4;
        l_bclv_tbl_in(1).ATTRIBUTE5         := bcl_rec.bcl_attribute5;
        l_bclv_tbl_in(1).ATTRIBUTE6         := bcl_rec.bcl_attribute6;
        l_bclv_tbl_in(1).ATTRIBUTE7         := bcl_rec.bcl_attribute7;
        l_bclv_tbl_in(1).ATTRIBUTE8         := bcl_rec.bcl_attribute8;
        l_bclv_tbl_in(1).ATTRIBUTE9         := bcl_rec.bcl_attribute9;
        l_bclv_tbl_in(1).ATTRIBUTE10        := bcl_rec.bcl_attribute10;
        l_bclv_tbl_in(1).ATTRIBUTE11        := bcl_rec.bcl_attribute11;
        l_bclv_tbl_in(1).ATTRIBUTE12        := bcl_rec.bcl_attribute12;
        l_bclv_tbl_in(1).ATTRIBUTE13        := bcl_rec.bcl_attribute13;
        l_bclv_tbl_in(1).ATTRIBUTE14        := bcl_rec.bcl_attribute14;
        l_bclv_tbl_in(1).ATTRIBUTE15        := bcl_rec.bcl_attribute15;
        l_bclv_tbl_in(1).BILL_ACTION        := p_bill_action;
        l_bclv_tbl_in(1).CURRENCY_CODE      := hdr_rec.currency_code;
        l_bclv_tbl_in(1).AMOUNT             := 0;

        IF (nvl(p_suppress_credit,'N') = 'Y') THEN
          l_bclv_tbl_in(1).BTN_ID             := -44;
        END IF;

        OKS_BILLCONTLINE_PUB.insert_Bill_Cont_Line
              (
               p_api_version                  =>  1.0,
               p_init_msg_list                =>  'T',
               x_return_status                =>   l_return_status,
               x_msg_count                    =>   l_msg_cnt,
               x_msg_data                     =>   l_msg_data,
               p_bclv_tbl                     =>   l_bclv_tbl_in,
               x_bclv_tbl                     =>   l_bclv_tbl_out
               );

        /* These statements are added to get the id of new record
             which is inserted in bcl*/
        l_bclv_tbl_in(1).ID         := l_bclv_tbl_out(1).ID;

        --- the temp variable assignment holds the current invoice bcl
        l_temp_bcl_id_ri := bcl_rec.bcl_bcl_id;
        --- the temp variable assignment holds the current credit bcl
        l_temp_bcl_id_tr := l_bclv_tbl_out(1).ID;

        IF not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
          x_return_status := l_return_status;
          Raise G_EXCEPTION_HALT_VALIDATION;
        END IF;

      END IF;
/****
      commented to fix bug# 4243931
      CLOSE Check_bcl;
***/

      ---l_bslv_tbl_in(1).BCL_ID  := l_bclv_tbl_in(1).id;
      l_bslv_tbl_in(1).CLE_ID := bcl_rec.bsl_cle_id;
      l_bslv_tbl_in(1).BCL_ID  := l_temp_bcl_id_tr;

      /*Average field is used to store bill_instance_number
        of the parent. It is used to populate referenc_line_id in
        AR Feeder
      */
      OPEN  bill_instance_csr(bcl_rec.bcl_bcl_id, bcl_rec.bsl_bsl_id);
      FETCH bill_instance_csr into l_bill_instance_number;
      CLOSE bill_instance_csr;


      l_bslv_tbl_in(1).AVERAGE := l_bill_instance_number;
      --l_bslv_tbl_in(1).AVERAGE := l_bill_instance_number;


      IF ( bcl_rec.bsl_date_billed_from < p_date_From ) THEN
        l_bslv_tbl_in(1).DATE_BILLED_FROM := p_date_From;
      ELSE
        l_bslv_tbl_in(1).DATE_BILLED_FROM := bcl_rec.bsl_date_billed_from;
      END IF;

      l_bslv_tbl_in(1).DATE_BILLED_TO := bcl_rec.bsl_date_billed_to;
      l_bslv_tbl_in(1).ATTRIBUTE_CATEGORY := bcl_rec.bsl_attribute_category;
      l_bslv_tbl_in(1).ATTRIBUTE1 := bcl_rec.bsl_attribute1;
      l_bslv_tbl_in(1).ATTRIBUTE2 := bcl_rec.bsl_attribute2;
      l_bslv_tbl_in(1).ATTRIBUTE3 := bcl_rec.bsl_attribute3;
      l_bslv_tbl_in(1).ATTRIBUTE4 := bcl_rec.bsl_attribute4;
      l_bslv_tbl_in(1).ATTRIBUTE5 := bcl_rec.bsl_attribute5;
      l_bslv_tbl_in(1).ATTRIBUTE6 := bcl_rec.bsl_attribute6;
      l_bslv_tbl_in(1).ATTRIBUTE7 := bcl_rec.bsl_attribute7;
      l_bslv_tbl_in(1).ATTRIBUTE8 := bcl_rec.bsl_attribute8;
      l_bslv_tbl_in(1).ATTRIBUTE9 := bcl_rec.bsl_attribute9;
      l_bslv_tbl_in(1).ATTRIBUTE10 := bcl_rec.bsl_attribute10;
      l_bslv_tbl_in(1).ATTRIBUTE11 := bcl_rec.bsl_attribute11;
      l_bslv_tbl_in(1).ATTRIBUTE12 := bcl_rec.bsl_attribute12;
      l_bslv_tbl_in(1).ATTRIBUTE13 := bcl_rec.bsl_attribute13;
      l_bslv_tbl_in(1).ATTRIBUTE14 := bcl_rec.bsl_attribute14;
      l_bslv_tbl_in(1).ATTRIBUTE15 := bcl_rec.bsl_attribute15;
      l_bslv_tbl_in(1).date_to_interface := get_term_end_date (bcl_rec.bsl_cle_id , p_date_from );

     if ( hdr_rec.lse_id in (12,13)) Then
           OPEN  avg_csr_bsl_amt(bcl_rec.bsl_cle_id, bcl_rec.bsl_date_billed_from);
           FETCH avg_csr_bsl_amt into term_bsl_amount;
           CLOSE avg_csr_bsl_amt;
     else
           term_bsl_amount := bcl_rec.bsl_amount;
     End if; --- ( hdr_rec.lse_id in (12,13)) Then


      IF (trunc(p_date_from) > trunc(bcl_rec.bsl_date_billed_from)) THEN
        /*For termination of contract create from OKS */

        IF (p_called_from = 1) THEN
         -------------------------------------------------------------------------
         -- Begin partial period computation logic
         -- Developer Mani Choudhary
         -- Date 15-JUN-2005
         -------------------------------------------------------------------------
         IF p_period_type IS NOT NULL AND
            p_period_start IS NOT NULL AND
            hdr_rec.lse_id in (12,13)
         THEN
           l_amount:= Get_partial_term_amount(
                                    p_start_date        => bcl_rec.bsl_date_billed_from,
                                    p_end_date          => bcl_rec.bsl_date_billed_to,
                                    P_termination_date  => p_date_from,
                                    ---P_amount            => bcl_rec.bsl_amount,
                                    P_amount            => term_bsl_amount,
                                    P_uom               => rules_rec.l_freq,
                                    P_period_start      => P_period_start,
                                    P_period_type       => P_period_type
                                    );

            IF l_amount is NULL THEN
               RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
         ELSE

            get_bill_amount_period(
                  -99,
                  hdr_rec.start_date , --p_con_start_date,
                  bcl_rec.bsl_date_billed_from, --p_con_end_date,
                  rules_rec.l_freq,
                  ---bcl_rec.bsl_amount,--p_con_amount,
                  term_bsl_amount,
                  bcl_rec.bsl_date_billed_to,
                  p_date_from,         -- termination_date
                  G_NONREGULAR,
                  l_amount);
         END IF;
        /*For termination of contract create from OM */
        ELSIF (p_called_from = 2) THEN
          l_diff :=abs(TRUNC(bcl_rec.cov_end_date - bcl_rec.cov_start_date)+1);
          l_bill_amount := bcl_rec.cov_price_negotiated/l_diff;
          l_diff := abs(trunc((bcl_rec.cov_end_date + 1 ) - p_date_from));
          l_amount :=  l_bill_amount * l_diff;
        ELSIF (p_called_from = 3) THEN
          l_amount :=  p_con_terminate_amount;
        END IF;

        --dbms_output.put_line('Amount credited '|| l_amount);
        IF (nvl(l_amount,0) > 0) THEN
          l_amount := OKS_EXTWAR_UTIL_PVT.round_currency_amt(abs(l_amount), hdr_rec.currency_code );
        END IF;

        l_bslv_tbl_in(1).AMOUNT := -1 * (l_amount );
      ELSE
        IF (p_called_from = 3) THEN
          l_amount :=  p_con_terminate_amount;
        ELSE
          ---l_bslv_tbl_in(1).AMOUNT := -1 * (bcl_rec.bsl_amount );
          ---l_amount    := bcl_rec.bsl_amount;
          l_bslv_tbl_in(1).AMOUNT := -1 * (term_bsl_amount );
          l_amount    := term_bsl_amount;
        END IF;
      END IF;

      IF (p_override_amount is not null) THEN
        l_amount :=  abs((p_override_amount * (l_amount ))/ (p_con_terminate_amount));
      END IF;

      --IF (bcl_rec.bsl_amount - abs(nvl(bcl_rec.line_existing_credit,0)) < l_amount) THEN
      --  l_amount :=  abs(bcl_rec.bsl_amount - abs(nvl(bcl_rec.line_existing_credit,0)));
      --END IF;

     --rounded for bug # 2791940
     l_amount                := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_amount, hdr_rec.currency_code );
     l_bslv_tbl_in(1).AMOUNT :=  -1 * l_amount;
      --dbms_output.put_line('Amount credited after if'|| l_amount);


     OKS_BILLSUBLINE_PUB.insert_Bill_subLine_Pub
              (
              p_api_version                  =>  1.0,
              p_init_msg_list                =>  'T',
              x_return_status                =>   l_return_status,
              x_msg_count                    =>   l_msg_cnt,
              x_msg_data                     =>   l_msg_data,
              p_bslv_tbl                     =>   l_bslv_tbl_in,
              x_bslv_tbl                     =>   l_bslv_tbl_out
              );


     IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS)  THEN
       x_return_status := l_return_status;
       Raise G_EXCEPTION_HALT_VALIDATION;
     END IF;

     g_credit_amount := nvl(g_credit_amount,0) + l_amount;

     g_bcl_id := l_bslv_tbl_in(1).BCL_ID;
     g_bsl_id := l_bslv_tbl_out(1).id;
      FOR bsd_rec IN bsd_cur(bcl_rec.bsl_bsl_id)
      LOOP
        l_bsdv_tbl_in.delete;
        l_bsdv_tbl_out.delete;

        l_bsdv_tbl_in(1).BSL_ID              := l_bslv_tbl_out(1).id;
        l_bsdv_tbl_in(1).BSL_ID_AVERAGED     := bsd_rec.bsl_id_averaged;
        l_bsdv_tbl_in(1).BSD_ID              := bsd_rec.bsd_id;
        l_bsdv_tbl_in(1).BSD_ID_APPLIED      := bsd_rec.bsd_id_applied;
        l_bsdv_tbl_in(1).UNIT_OF_MEASURE     := bsd_rec.unit_of_measure;
        l_bsdv_tbl_in(1).FIXED               := bsd_rec.fixed;
        l_bsdv_tbl_in(1).ACTUAL              := bsd_rec.actual;
        l_bsdv_tbl_in(1).DEFAULT_DEFAULT     := bsd_rec.default_default;
        l_bsdv_tbl_in(1).ESTIMATED_QUANTITY  := 0;
        l_bsdv_tbl_in(1).AMCV_YN             := bsd_rec.amcv_yn;
        l_bsdv_tbl_in(1).ADJUSTMENT_LEVEL    := bsd_rec.adjustment_level;
        l_bsdv_tbl_in(1).ADJUSTMENT_MINIMUM  := bsd_rec.adjustment_minimum;
        IF (P_amount IS NOT NULL) THEN
          l_bsdv_tbl_in(1).RESULT              := p_amount;
        ELSE
          l_bsdv_tbl_in(1).RESULT              := bsd_rec.result;
        END IF;
        l_bsdv_tbl_in(1).ATTRIBUTE_CATEGORY  := bsd_rec.attribute_category;
        l_bsdv_tbl_in(1).ATTRIBUTE1          := bsd_rec.attribute1;
        l_bsdv_tbl_in(1).ATTRIBUTE2          := bsd_rec.attribute2;
        l_bsdv_tbl_in(1).ATTRIBUTE3          := bsd_rec.attribute3;
        l_bsdv_tbl_in(1).ATTRIBUTE4          := bsd_rec.attribute4;
        l_bsdv_tbl_in(1).ATTRIBUTE5          := bsd_rec.attribute5;
        l_bsdv_tbl_in(1).ATTRIBUTE6          := bsd_rec.attribute6;
        l_bsdv_tbl_in(1).ATTRIBUTE7          := bsd_rec.attribute7;
        l_bsdv_tbl_in(1).ATTRIBUTE8          := bsd_rec.attribute8;
        l_bsdv_tbl_in(1).ATTRIBUTE9          := bsd_rec.attribute9;
        l_bsdv_tbl_in(1).ATTRIBUTE10         := bsd_rec.attribute10;

        l_bsdv_tbl_in(1).ATTRIBUTE11         := bsd_rec.attribute11;
        l_bsdv_tbl_in(1).ATTRIBUTE12         := bsd_rec.attribute12;
        l_bsdv_tbl_in(1).ATTRIBUTE13         := bsd_rec.attribute13;
        l_bsdv_tbl_in(1).ATTRIBUTE14         := bsd_rec.attribute14;
        l_bsdv_tbl_in(1).ATTRIBUTE15         := bsd_rec.attribute15;
        l_bsdv_tbl_in(1).AMOUNT              := -1 * l_amount;


        OKS_BSL_det_PUB.insert_bsl_det_Pub
                 (
                    p_api_version                  =>  1.0,
                    p_init_msg_list                =>  'T',
                    x_return_status                =>   l_return_status,
                    x_msg_count                    =>   l_msg_cnt,
                    x_msg_data                     =>   l_msg_data,
                    p_bsdv_tbl                     =>   l_bsdv_tbl_in,
                    x_bsdv_tbl                     =>   l_bsdv_tbl_out
                 );



        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          x_return_status := l_return_status;
          Raise G_EXCEPTION_HALT_VALIDATION;
        END IF;
      END LOOP;    --bsd cursor loop

      --l_bclv_tbl_in(1).AMOUNT := (l_bclv_tbl_in(1).amount - nvl(l_amount,0));
      --rounded for bug # 2791940
/*
      l_bclv_tbl_in(1).AMOUNT := OKS_EXTWAR_UTIL_PVT.round_currency_amt(
         (nvl(l_bclv_tbl_in(1).amount,0) - nvl(abs(l_amount),0)),
                                                    hdr_rec.currency_code);
*/


     ---commented the above since the rounded value is stored in bsl amount
      UPDATE oks_bill_cont_lines
      SET    amount = nvl(amount,0) + l_bslv_tbl_in(1).AMOUNT
      WHERE  id     = l_temp_bcl_id_tr;

    l_temp_bcl_id_ri := bcl_rec.bcl_bcl_id;

    END LOOP;  --bcl cursor loop

  END IF;  -- p_bill_action = 'RI'

    x_return_status := l_return_status;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
        x_return_status := OKC_API.G_RET_STS_ERROR ;
  WHEN  OTHERS THEN
          OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN,SQLERRM);

END Create_trx_records;



Procedure terminate_amount(
    P_CALLEDFROM          IN         NUMBER   DEFAULT Null ,
    P_TOP_LINE_ID         IN         NUMBER,
    P_COVLVL_ID           IN         NUMBER,
    P_TERMINATION_DATE    IN         DATE,
    P_USAGE_TYPE          IN         VARCHAR2,
    P_USAGE_PERIOD        IN         VARCHAR2,
    X_AMOUNT              OUT NOCOPY NUMBER,
    X_QUANTITY            OUT NOCOPY NUMBER
  ) IS
CURSOR l_uom_csr Is
  SELECT uom_code
  FROM   Okc_time_code_units_v
  WHERE  tce_code = 'DAY'
  AND    quantity = 1;


CURSOR l_inv_item_csr(p_cle_id Number) Is
  SELECT mtl.primary_uom_code,
         line.dnz_chr_id
  FROM   Okc_K_items Item
        ,mtl_system_items_b   mtl  --Okx_system_items_v mtl
        ,okc_k_headers_b      hdr
        ,okc_k_lines_b   line
  WHERE  item.cle_id = line.id     --p_cle_id
  AND    line.id     = p_cle_id
  AND    line.dnz_chr_id = hdr.id
  --AND    mtl.id1 = item.object1_id1
  AND    mtl.inventory_item_id = item.object1_id1
  AND    mtl.organization_id = hdr.inv_organization_id;   --p_org_id;



CURSOR covlvl_line(p_top_id IN   NUMBER,
                   p_cov_id IN   NUMBER) is
  SELECT line.id,
         line.start_date,
         line.end_date,
         rline.usage_est_yn,
         rline.usage_est_method,
         rline.default_quantity,
         rline.usage_est_start_date    usage_est_start_date
   FROM  okc_k_lines_b   line,
         oks_k_lines_b   rline
   WHERE line.cle_id = p_top_id
   AND   line.id     = nvl(p_cov_id,line.id)
   AND   line.lse_id = 13
   AND   line.date_cancelled is null --LLC BUG FIX 4742661
   AND   rline.cle_id = line.id;

--Cursor declaration for partial periods
------------------------------------------------
CURSOR l_period_type_csr(p_hdr_id IN NUMBER) IS
SELECT period_type,period_start
FROM   oks_k_headers_b
WHERE  chr_id = p_hdr_id;
-------------------------------------------------

l_return_status          VARCHAR2(10);
l_counter_uom_code       VARCHAR2(10);
l_flag                   VARCHAR2(10);
l_uom_code               VARCHAR2(25);
l_primary_uom_code       VARCHAR2(25);
l_qty                    NUMBER;
l_est_qty                NUMBER;
l_actual_qty             NUMBER;
l_amt                    NUMBER;
l_tot_billed_amount      NUMBER;
l_amt_before_term        NUMBER;
l_start_reading          NUMBER;
l_end_reading            NUMBER;
l_base_reading           NUMBER;
l_counter_value_id       NUMBER;
l_counter_grp_id         NUMBER;

l_msg_cnt                NUMBER;
l_msg_data               VARCHAR2(2000);
l_api_version   CONSTANT NUMBER     := 1.0;
l_init_msg_list CONSTANT VARCHAR2(1):= 'F';

--local variables for partial periods
----------------------------------------------------------
l_period_type            OKS_K_HEADERS_B.period_type%TYPE;
l_period_start           OKS_K_HEADERS_B.period_start%TYPE;
l_hdr_id                 NUMBER;
----------------------------------------------------------
l_line_rec               OKS_QP_PKG.Input_details ;
l_price_rec              OKS_QP_PKG.Price_Details ;
l_modifier_details       QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
l_price_break_details    OKS_QP_PKG.G_PRICE_BREAK_TBL_TYPE;
BEGIN
  OPEN  l_uom_csr;
  FETCH l_uom_csr into l_uom_code;
  CLOSE l_uom_csr;


  OPEN  l_inv_item_csr(p_top_line_id);
  FETCH l_inv_item_csr into l_primary_uom_code,l_hdr_id;
  CLOSE l_inv_item_csr;

  --Mani 12-JUN-2005
  --fetch the period type for partial period calculation
  ---------------------------------------------
  OPEN l_period_type_csr(l_hdr_id);
  FETCH l_period_type_csr INTO l_period_type,l_period_start;
  CLOSE l_period_type_csr;
  ---------------------------------------------

  FOR cur in covlvl_line(p_top_line_id,p_covlvl_id)
  LOOP
    -------------------------------------------------------------------------
    -- Begin partial period computation logic
    -- Developer Mani Choudhary
    -- Date 11-JUN-2005
    -- Added additional period_type parameter
    -------------------------------------------------------------------------
    OKS_BILL_REC_PUB.Usage_qty_to_bill
                (
                P_calledfrom            => 3,  --1 for normal , 2 for preview,
                P_cle_id                => cur.id,
                P_Usage_type            => p_usage_type,
                P_estimation_flag       => cur.usage_est_yn,
                P_estimation_method     => cur.usage_est_method,
                P_default_qty           => cur.default_quantity,
                P_cov_start_date        => cur.start_date,
                P_cov_end_date          => cur.end_date,
                P_cov_prd_start_date    => cur.start_date,
                P_cov_prd_end_date      => p_termination_date,
                p_usage_period          => p_usage_period,
                p_time_uom_code         => l_uom_code,
                p_settle_interval       => NULL,
                p_minimum_quantity      => 0,
                p_usg_est_start_date    => cur.usage_est_start_date,
                p_period_type           => l_period_type, -- period type
                p_period_start          => l_period_start, -- period start
                X_qty                   => l_qty,
                X_Uom_Code              => l_counter_uom_code,
                X_flag                  => l_flag,
                X_end_reading           => l_end_reading,
                X_start_reading         => l_start_reading,
                X_base_reading          => l_base_reading,
                X_estimated_qty         => l_est_qty,
                X_actual_qty            => l_actual_qty,
                X_counter_value_id      => l_counter_value_id,
                X_counter_group_id      => l_counter_grp_id,
                X_return_status         => l_return_status
                  );



    l_line_rec.line_id          := p_top_line_id;
    l_line_rec.intent           := 'USG';
    l_line_rec.usage_qty        := l_qty;
    l_line_rec.usage_uom_code   := l_primary_uom_code; --qty_uom_rec.uom_code;

    X_QUANTITY := l_qty;

    OKS_QP_PKG.CALC_PRICE
                (
                 P_DETAIL_REC          => l_line_rec,
                 X_PRICE_DETAILS       => l_price_rec,
                 X_MODIFIER_DETAILS    => l_modifier_details,
                 X_PRICE_BREAK_DETAILS => l_price_break_details,
                 X_RETURN_STATUS       => l_return_status,
                 X_MSG_COUNT           => l_msg_cnt,
                 X_MSG_DATA            => l_msg_data
                );

    X_amount :=  l_price_rec.PROD_EXT_AMOUNT;
    --X_amount :=  l_amt_before_term + l_price_rec.PROD_EXT_AMOUNT;


  END LOOP;

END terminate_amount;

------------------------------------------------------------------------
  -- FUNCTION pre_vol_based_terminate
------------------------------------------------------------------------
 PROCEDURE  pre_vol_based_terminate(
   P_CALLEDFROM                IN         NUMBER   DEFAULT Null ,
   P_API_VERSION               IN         NUMBER   ,
   P_INIT_MSG_LIST             IN         VARCHAR2 DEFAULT OKC_API.G_FALSE   ,
   X_RETURN_STATUS             OUT NOCOPY VARCHAR2   ,
   X_MSG_COUNT                 OUT NOCOPY NUMBER   ,
   X_MSG_DATA                  OUT NOCOPY VARCHAR2   ,
   P_K_LINE_ID                 IN         NUMBER   ,
   P_CP_LINE_ID                IN         NUMBER   ,
   P_TERMINATION_DATE          IN         DATE   ,
   P_TERMINATION_AMOUNT        IN         NUMBER   ,
   P_CON_TERMINATION_AMOUNT    IN         NUMBER   ,
   --P_EXISTING_CREDIT           IN         NUMBER   ,
   P_SUPPRESS_CREDIT           IN         VARCHAR2  ,
   P_USAGE_TYPE                IN         VARCHAR2,
   P_USAGE_PERIOD              IN         VARCHAR2,
   X_AMOUNT                    IN         NUMBER )
IS
 CURSOR covlvl_line(p_cle_id IN   NUMBER,p_cp_line_id IN NUMBER) is
  SELECT line.id,
         line.start_date,
         rline.usage_est_yn,
         rline.usage_est_method
   FROM  okc_k_lines_b   line,
         oks_k_lines_b   rline
   WHERE line.cle_id = p_cle_id
   AND   line.lse_id = 13
   AND   line.id     = nvl(p_cp_line_id,line.id)
   AND   line.date_cancelled is NULL --LLC BUG FIX 4742661
   AND   rline.cle_id = line.id;



Cursor total_billed_qty (p_cle_id   IN NUMBER)
IS
SELECT sum(bsd.result) ,
       sum(bsl.amount) ,
       max(bsl.date_billed_From),
       max(bsl.date_billed_to)
   FROM oks_bill_sub_line_dtls      bsd,
        oks_bill_sub_lines          bsl
   WHERE bsl.cle_id = p_cle_id
   AND   bsd.bsl_id = bsl.id;


Cursor bsl_cur (p_cle_id IN NUMBER)
IS
SELECT bsl.id,
       bsl.date_billed_from,
       bsl.date_billed_to,
       bsl.amount,
       bsd.result
  FROM oks_bill_cont_lines    bcl,
       oks_bill_sub_lines     bsl,
       oks_bill_sub_line_dtls bsd
  WHERE bcl.id  =  bsl.bcl_id
  AND   bsl.cle_id = p_cle_id
  AND   bsd.bsl_id = bsl.id
 ORDER by bsl.date_billed_to desc;


l_qty                   NUMBER;
l_amt                   NUMBER;
l_credit_amount         NUMBER;
l_credit_qty            NUMBER;
l_total_term_qty        NUMBER;
l_term_amount           NUMBER;
l_term_qty              NUMBER;
l_term_bcl_id           NUMBER;
l_term_bsl_id           NUMBER;
l_billed_qty            NUMBER;
l_billed_amt            NUMBER;
l_max_date_billed_from  DATE;
l_max_date_billed_to    DATE;
l_term_period_bill_qty  NUMBER;
l_term_period_cre_qty   NUMBER;
l_return_status         VARCHAR2(10);
l_uom_code              VARCHAR2(25);
l_term_prd_date_from    DATE;
p_date                  DATE;

l_msg_cnt                NUMBER;
l_msg_data               VARCHAR2(2000);
l_api_version   CONSTANT NUMBER     := 1.0;
l_init_msg_list CONSTANT VARCHAR2(1):= 'F';



BEGIN

  FOR cur in covlvl_line(p_k_line_id,p_cp_line_id)
  LOOP
    Terminate_amount(
       P_CALLEDFROM       => 1,
       P_TOP_LINE_ID      => p_k_line_id   ,
       P_COVLVL_ID        => cur.id   ,
       P_TERMINATION_DATE => p_termination_date   ,
       P_USAGE_TYPE       => p_usage_type   ,
       P_USAGE_PERIOD     => p_usage_period   ,
       X_AMOUNT           => l_amt   ,
       X_QUANTITY         => l_qty
        );

    OPEN   total_billed_qty(cur.id);
    FETCH  total_billed_qty into l_billed_qty,l_billed_amt,
                                 l_max_date_billed_from,l_max_date_billed_to;
    CLOSE  total_billed_qty;

    IF (l_billed_amt <  l_amt) THEN
       --create invoice as already billed amount is lesser than total amount to be charged till termination date
      l_term_amount := l_amt - l_billed_amt;
      Create_trx_records(
               p_called_from           => 1,
               p_top_line_id           => p_k_line_id,
               p_cov_line_id           => cur.id,
               p_date_from             => l_max_date_billed_from,
               p_date_to               => l_max_date_billed_to,
               p_amount                => l_qty - l_billed_qty,
               p_override_amount       => 0,
             --p_suppress_credit       => 'N',
               p_suppress_credit       => P_SUPPRESS_CREDIT,  --  Bug Fix 5062595 maanand --
               p_con_terminate_amount  => l_term_amount ,
               --p_existing_credit       => p_existing_credit,
               p_bill_action           => 'RI',
               x_return_status         => l_return_status
               );

    ELSE
      -- Create credits  as already billed amount is greater than total amount to be charged till termination date
      /* BUG 3343780 fix. L_credit_qty is prorated so that total terminated qty can be viewed from billing history */
      l_credit_amount := l_billed_amt - l_amt;
      l_credit_qty    := l_billed_qty - l_qty;

      FOR bsl_rec in bsl_cur(cur.id)
      LOOP
        IF (l_credit_amount <= 0) THEN
          EXIT;
        END IF;

        IF (l_credit_amount >= bsl_rec.amount) THEN
          l_term_amount :=  bsl_rec.amount;
          --l_term_qty    :=  bsl_rec.result;
          IF (l_credit_qty <= bsl_rec.result) THEN
            l_term_qty := l_credit_qty;
          ELSE
            l_term_qty := bsl_rec.result;
          END IF;
        ELSE
          l_term_amount :=  l_credit_amount;
          l_term_qty    :=  l_credit_qty   ;
        END IF;

        Create_trx_records(
               p_called_from           => 1,
               p_top_line_id           => p_k_line_id,
               p_cov_line_id           => cur.id,
               p_date_from             => bsl_rec.date_billed_from,
               p_date_to               => bsl_rec.date_billed_to,
               p_amount                => l_term_qty,
               p_override_amount       => l_term_amount,
             --p_suppress_credit       => 'N',
               p_suppress_credit       => P_SUPPRESS_CREDIT, ----  Bug Fix 5062595 maanand --
               p_con_terminate_amount  => bsl_rec.amount,
               --p_existing_credit       => p_existing_credit,
               p_bill_action           => 'TR',
               x_return_status         => l_return_status
               );

        l_credit_amount := l_credit_amount - bsl_rec.amount;
        --l_credit_qty    := l_credit_qty    - bsl_rec.result;
        IF (l_credit_qty > bsl_rec.result ) THEN
          l_credit_qty    := l_credit_qty    - bsl_rec.result;
        ELSE
          l_credit_qty := 0;
        END IF;
      END LOOP;


    END IF;


  END LOOP;

END;

------------------------------------------------------------------------
  -- FUNCTION pre_terminate_amount
------------------------------------------------------------------------
  PROCEDURE pre_terminate_amount
  (
    P_CALLEDFROM                   IN         NUMBER DEFAULT Null,
    p_id                           IN         NUMBER,
    p_terminate_date               IN         DATE,
    p_flag                         IN         NUMBER,
    X_Amount                      OUT NOCOPY  NUMBER,
    --X_manual_credit               OUT NOCOPY  NUMBER,
    X_return_status               OUT NOCOPY  VARCHAR2)IS
Cursor line_cur(p_hdr_id IN NUMBER) is
SELECT okl.id ,
       okl.lse_id ,
       okl.price_negotiated,
       okh.currency_code,
       okh.contract_number,
       okh.contract_number_modifier
  FROM okc_k_lines_b okl,
       okc_k_headers_b  okh
  WHERE okh.id = p_hdr_id
  AND   okl.dnz_chr_id = okh.id
  AND   okl.cle_id is null
  AND   okl.date_cancelled is null --LLC BUG FIX 4742661
  AND   okl.date_terminated is null;
 -- AND   okl.sts_code in ('ACTIVE','SIGNED') ;

  -------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 30-MAY-2005
-- Added header id in the select clause
-------------------------------------------------------------------------
Cursor hdr_currency_code_cur(p_id IN NUMBER) is
SELECT okh.currency_code,
       okh.id header_id,
       okl.lse_id  ,
       okl.cle_id  ,
       okl.price_negotiated,
       okh.contract_number,
       okh.contract_number_modifier,
       okh.billed_at_source
   FROM okc_k_headers_all_b okh,
        okc_k_lines_b    okl
   WHERE  okl.id = p_id
   AND    okh.id = okl.dnz_chr_id;


Cursor line_billed_cur (p_id IN NUMBER) is
SELECT bcl.id ,rline.termn_method,
       rline.usage_type, rline.usage_period
   FROM oks_bill_cont_lines  bcl,
        oks_k_lines_b        rline
   WHERE bcl.cle_id = p_id
   AND   rline.cle_id = bcl.cle_id
   AND   bcl.bill_action = 'RI';

Cursor subscr_line_bill_cur (p_cle_id IN NUMBER) is
SELECT nvl(sum(nvl(amount,0)),0),max(date_billed_To)
    FROM oks_bill_cont_lines
    WHERE cle_id = p_cle_id
    AND   bill_action = 'RI';

Cursor subscr_line_ship_cur (p_id IN NUMBER) is
SELECT nvl(sum(nvl(amount,0)),0),max(end_date)
    FROM oks_subscr_elements
    WHERE dnz_cle_id = p_id
    AND   order_header_id is not null;

Cursor sub_line_billed_cur (p_id IN NUMBER) is
SELECT bsl.id ,rline.TERMN_METHOD ,bcl.cle_id,
       rline.usage_type, rline.usage_period
   FROM oks_bill_sub_lines bsl,
        oks_bill_cont_lines bcl,
        oks_k_lines_b       rline
   WHERE bsl.cle_id = p_id
   AND   bsl.bcl_id = bcl.id
   AND   rline.cle_id = bcl.cle_id
   AND   bcl.bill_action = 'RI';


Cursor tot_sub_line_billed( p_cle_id IN NUMBER) is
SELECT sum(amount)
   FROM oks_bill_sub_lines
   WHERE cle_id = p_cle_id;


Cursor tot_line_billed( p_cle_id IN NUMBER) is
SELECT sum(amount)
   FROM oks_bill_cont_lines
   WHERE cle_id = p_cle_id;


cursor l_calc_bill_amount_csr (p_line_id number ) is
SELECT sum(amount) FROM
oks_bill_cont_lines
WHERE cle_id = p_line_id ;

l_billed_amount        NUMBER ;
final_amount           NUMBER;
l_lse_id               NUMBER;
l_cov_id               NUMBER;
l_top_id               NUMBER;
l_number               NUMBER;
l_bill_amount          NUMBER;
l_ship_amount          NUMBER;
l_bill_qty             NUMBER;
l_quantity             NUMBER;
l_cov_line             VARCHAR2(2);
l_return_status        VARCHAR2(5);
l_fulfillment_channel  VARCHAR2(10);
l_term_method          VARCHAR2(10);
l_usage_type           VARCHAR2(10);
l_usage_period         VARCHAR2(10);
----Hari fix for bug 5667743
l_contract_number      OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
l_contract_modifier    OKC_K_HEADERS_B.CONTRACT_NUMBER_MODIFIER%TYPE;
l_billed_at_source     OKC_K_HEADERS_ALL_B.BILLED_AT_SOURCE%TYPE;
l_term_date            DATE;
l_max_bill_date        DATE;
l_max_ship_date        DATE;
l_billed               BOOLEAN ;
l_tang                 BOOLEAN ;
l_currency_code        okc_k_headers_b.currency_code%TYPE;
l_orig_price           NUMBER;
-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 30-MAY-2005
-- local variables for partal periods
-------------------------------------------------------------------------
l_hdr_id              NUMBER;
l_price_uom           OKS_K_HEADERS_B.PRICE_UOM%TYPE;
l_period_start        OKS_K_HEADERS_B.PERIOD_START%TYPE;
l_period_type         OKS_K_HEADERS_B.PERIOD_TYPE%TYPE;
l_pricing_method      VARCHAR2(30);
-------------------------------------------------------------------------


BEGIN

  IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_procedure,G_MODULE_CURRENT||'.pre_terminate_amount.p_flag',
    'Entering pre_terminate_amount with input parameters  p_flag ' ||p_flag||' ,p_id '||p_id||' ,p_terminate_date '||to_char(p_terminate_date));
  END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS ;
  l_billed        := FALSE;
  l_term_method   := 'AMOUNT';
  IF (p_flag in  (1,3)) THEN -- p_id is line_id

    l_cov_line  := 'N';

-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 30-MAY-2005
-- Added l_hdr_id
-------------------------------------------------------------------------

    OPEN  hdr_currency_code_cur(p_id);
    FETCH hdr_currency_code_cur into l_currency_code,l_hdr_id,l_lse_id,l_top_id,l_orig_price,
                                     l_contract_number,
                                     l_contract_modifier,
				     l_billed_at_source;
    CLOSE hdr_currency_code_cur;

   IF l_billed_at_source = 'Y' THEN
         X_Amount := 0;
	 RETURN;
   END IF;
-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 30-MAY-2005
-- Call oks_renew_util_pub.get_period_defaults to fetch period start and period type
-------------------------------------------------------------------------
    IF l_hdr_id IS NOT NULL THEN

      OKS_RENEW_UTIL_PUB.Get_Period_Defaults
                (
                 p_hdr_id        => l_hdr_id,
                 p_org_id        => NULL,
                 x_period_start  => l_period_start,
                 x_period_type   => l_period_type,
                 x_price_uom     => l_price_uom,
                 x_return_status => l_return_status);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.pre_terminate_amount.line_termination.ppc_defaults',
          'After calling OKS_RENEW_UTIL_PUB.Get_Period_Defaults l_period_start ' ||l_period_start||' ,l_period_type '||l_period_type);
      END IF;
      IF l_return_status <> 'S' THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

    --mchoudha bug fix 4732550
    --Added condition lse_id 13 for subline case
    IF l_lse_id in (12,46,13) AND l_period_start IS NOT NULL THEN
      l_period_start:= 'SERVICE';
    END IF;
-------------------------------------------------------------------------
-- End partial period computation logic
--------------------------------------------------------------------------
    IF (p_flag = 3) THEN
      l_cov_line := 'Y';
      l_cov_id   := p_id;

      IF (l_lse_id = 13) THEN
        OPEN  Sub_line_billed_cur(p_id);
        FETCH sub_line_billed_cur into l_number,l_term_method,l_top_id,
                                        l_usage_type, l_usage_period;
        IF (sub_line_billed_cur%FOUND) THEN
          l_billed := TRUE;
        ELSE
          l_billed := FALSE;
        END IF;
        CLOSE sub_line_billed_cur;
      END IF;

    ELSIF (p_flag = 1) THEN
      l_top_id := p_id;
      IF (l_lse_id = 46 ) THEN
        l_tang := OKS_SUBSCRIPTION_PUB.IS_SUBS_TANGIBLE(P_ID) ;
      END IF;

      IF (l_lse_id = 12) THEN
        OPEN line_billed_cur(p_id);
        FETCH line_billed_cur into l_number,l_term_method,
                                   l_usage_type, l_usage_period;
        IF (line_billed_cur%FOUND) THEN
          l_billed := TRUE;
        ELSE
          l_billed := FALSE;
        END IF;
        CLOSE line_billed_cur;
      ELSIF ((l_lse_id = 46) AND (l_tang)) THEN
        OPEN subscr_line_bill_cur(p_id);
        FETCH subscr_line_bill_cur into l_bill_amount,l_max_bill_date;
        CLOSE subscr_line_bill_cur;

        OPEN subscr_line_ship_cur(p_id);
        FETCH subscr_line_ship_cur into l_ship_amount,l_max_ship_date;
        CLOSE subscr_line_ship_cur;

      END IF;
    END IF;  -- p_flag


    l_term_date := p_terminate_date;


    IF (l_lse_id = 46)  THEN

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.pre_terminate_amount.line_termination','Calling Subscription_termination');
      END IF;

      IF l_tang  THEN

        get_subscr_terminate_amount
           ( P_CALLEDFROM         => p_calledfrom,
             P_LINE_ID            => p_id,
             P_TERMINATE_DATE     => l_term_date,
             P_BILLED_AMOUNT      => l_bill_amount,
             P_SHIPPED_AMOUNT     => l_ship_amount,
             P_MAX_BILL_DATE      => l_max_bill_date,
             P_MAX_SHIP_DATE      => l_max_ship_date,
             X_AMOUNT             => X_amount,
             X_RETURN_STATUS      => X_return_status ) ;
        If x_amount < 0 then
           x_amount := 0;
        End If;
      ELSE
        OPEN  l_calc_bill_amount_csr ( p_id );
        FETCH l_calc_bill_amount_csr into l_billed_amount ;
        CLOSE l_calc_bill_amount_csr;
        --mchoudha fix for bug#4729993
      /*  l_pricing_method :=FND_PROFILE.value('OKS_SUBS_PRICING_METHOD');
        IF l_period_start IS NOT NULL AND
           l_period_type IS NOT NULL AND
           l_pricing_method = 'EFFECTIVITY' THEN
          x_amount :=  l_billed_amount - l_orig_price +
                             OKS_SUBSCRIPTION_PUB.subs_termn_amount(
                                           p_cle_id     =>p_id ,
                                           p_termn_date =>l_term_date );
        ELSE*/
          x_amount :=  l_billed_amount -
                             OKS_SUBSCRIPTION_PUB.subs_termn_amount(
                                           p_cle_id     =>p_id ,
                                           p_termn_date =>l_term_date );
        --END IF;
        If x_amount < 0 then
           x_amount := 0 ;
        End If;
      END IF;
    ELSE
      IF (l_term_method = 'VOLUME') THEN

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.pre_terminate_amount.line_termination.Volume_termination',
          'usage period '||l_usage_period);
        END IF;

        terminate_amount(
             P_CALLEDFROM          => 2,
             P_TOP_LINE_ID         => l_top_id,
             P_COVLVL_ID           => l_cov_id,
             P_TERMINATION_DATE    => l_term_date,
             P_USAGE_TYPE          => l_usage_type,
             P_USAGE_PERIOD        => l_usage_period,
             X_AMOUNT              => X_amount,
             X_QUANTITY            => l_quantity
           );

        IF (l_lse_id = 12) THEN
          OPEN  tot_line_billed(p_id);
          FETCH tot_line_billed into l_bill_Qty;
          CLOSE tot_line_billed;
        ELSIF (l_lse_id = 13) THEN
          OPEN  tot_sub_line_billed(p_id);
          FETCH tot_sub_line_billed into l_bill_Qty;
          CLOSE tot_sub_line_billed;
        END IF;

        X_AMOUNT := l_bill_qty - X_amount;

      ELSE
         -------------------------------------------------------------------------
         -- Begin partial period computation logic
         -- Developer Mani Choudhary
         -- Date 30-MAY-2005
         -- Call the procedure Get_Term_Amt_Ppc for partial periods
         -------------------------------------------------------------------------
        IF l_period_start IS NOT NULL AND
           l_period_type IS NOT NULL
        THEN
          IF l_lse_id in (12,13) THEN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.pre_terminate_amount.line_termination.PPC',
               'Calling Get_Terminate_Amount for usage with l_cov_line '||l_cov_line);
            END IF;

            Get_Terminate_Amount
            (
             P_CALLEDFROM       => p_calledfrom     ,
             P_LINE_ID          => p_id             ,
             P_COV_LINE         => l_cov_line       ,
             P_TERMINATE_DATE   => l_term_date      ,
             P_PERIOD_START     => l_period_start   ,
             P_PERIOD_TYPE      => l_period_type    ,
             X_AMOUNT           => X_amount         ,
             X_RETURN_STATUS    => X_return_status
             );
             IF X_return_status <> 'S' THEN
               RAISE G_EXCEPTION_HALT_VALIDATION;
             END IF;
          ELSE

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.pre_terminate_amount.line_termination.PPC',
               'Calling Get_Term_Amt_Ppc for service  with l_cov_line '||l_cov_line);
            END IF;

            Get_Term_Amt_Ppc
               (P_termination_date => l_term_date,
                P_line_id          => p_id,
                P_cov_line         => l_cov_line,
                p_period_start     => l_period_start,
                p_period_type      => l_period_type,
                X_amount           => x_amount,
                x_return_status    => l_return_status);

                IF l_return_status <> 'S' THEN
                  RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;
          END IF;
        ELSE

          Get_Terminate_Amount
           (
            P_CALLEDFROM       => p_calledfrom     ,
            P_LINE_ID          => p_id             ,
            P_COV_LINE         => l_cov_line       ,
            P_TERMINATE_DATE   => l_term_date      ,
            X_AMOUNT           => X_amount         ,
            X_RETURN_STATUS    => X_return_status
            );
          IF X_return_status <> 'S' THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
        END IF;
      END IF;
    END IF;

    final_amount := X_Amount;


   ELSIF (p_flag = 2) Then -- p_id is hdr_id
    --Mani R12 PPC
    OKS_RENEW_UTIL_PUB.Get_Period_Defaults
                (
                 p_hdr_id        => p_id,
                 p_org_id        => NULL,
                 x_period_start  => l_period_start,
                 x_period_type   => l_period_type,
                 x_price_uom     => l_price_uom,
                 x_return_status => l_return_status);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.pre_terminate_amount.hdr_termination.ppc_defaults',
         ' After calling OKS_RENEW_UTIL_PUB.Get_Period_Defaults l_period_start ' ||l_period_start||' ,l_period_type '||l_period_type);
      END IF;

      IF l_return_status <> 'S' THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

     --Mani R12 PPC
     final_amount := 0;
     X_amount     := 0;
     l_cov_line   := 'N';
     FOR line_rec in line_cur(p_id)
     LOOP
       --Mani R12 PPC
       IF line_rec.lse_id = 12 AND l_period_start IS NOT NULL THEN
         l_period_start:= 'SERVICE';
       END IF;
       --Mani R12 PPC
       l_currency_code := line_rec.currency_code;
       l_billed        := FALSE;
       X_amount     := 0;

       IF (line_rec.lse_id = 46 ) THEN
         l_tang := OKS_SUBSCRIPTION_PUB.IS_SUBS_TANGIBLE(line_rec.id) ;
       END IF;

       IF (line_rec.lse_id = 12)  THEN
         OPEN  line_billed_cur(line_rec.id);
         FETCH line_billed_cur into l_number,l_term_method,
                                    l_usage_type, l_usage_period;
         IF (line_billed_cur%FOUND) THEN
           l_billed := TRUE;
         ELSE
           l_billed := FALSE;
         END IF;
         CLOSE line_billed_cur;
       ELSIF ((line_rec.lse_id = 46) AND (l_tang)) THEN
         OPEN subscr_line_bill_cur(line_rec.id);
         FETCH subscr_line_bill_cur into l_bill_amount,l_max_bill_date;
         CLOSE subscr_line_bill_cur;

         OPEN subscr_line_ship_cur(line_rec.id);
         FETCH subscr_line_ship_cur into l_ship_amount,l_max_ship_date;
         CLOSE subscr_line_ship_cur;
       END IF;

       l_term_date := p_terminate_date;

       IF (line_rec.lse_id = 46)  THEN
         IF l_tang THEN
           get_subscr_terminate_amount
            (
              P_CALLEDFROM         => p_calledfrom,
              P_LINE_ID            => line_rec.id,
              P_TERMINATE_DATE     => l_term_date,
              P_BILLED_AMOUNT      => l_bill_amount,
              P_SHIPPED_AMOUNT     => l_ship_amount,
              P_MAX_BILL_DATE      => l_max_bill_date,
              P_MAX_SHIP_DATE      => l_max_ship_date,
              X_AMOUNT             => X_amount,
              X_RETURN_STATUS      => X_return_status
             ) ;
            If x_amount < 0 then
               x_amount := 0;
            End If;
         ELSE
           OPEN  l_calc_bill_amount_csr ( line_rec.id );
           FETCH l_calc_bill_amount_csr into l_billed_amount ;
           CLOSE l_calc_bill_amount_csr;
          /* l_pricing_method :=FND_PROFILE.value('OKS_SUBS_PRICING_METHOD');
           IF l_period_start IS NOT NULL AND
              l_period_type IS NOT NULL AND
              l_pricing_method = 'EFFECTIVITY' THEN
              x_amount := x_amount + l_billed_amount - line_rec.price_negotiated +
                                 OKS_SUBSCRIPTION_PUB.subs_termn_amount(
                                             p_cle_id     =>line_rec.id ,
                                             p_termn_date =>l_term_date );
           ELSE*/
             x_amount := x_amount + l_billed_amount -
                                 OKS_SUBSCRIPTION_PUB.subs_termn_amount(
                                             p_cle_id     =>line_rec.id ,
                                             p_termn_date =>l_term_date );
           --END IF;

           If x_amount < 0 then
              x_amount := 0;
           End If;
         END IF;

       ELSE

         l_top_id   := line_rec.id;
         l_cov_id   := NULL;

         IF (l_term_method = 'VOLUME') THEN
           terminate_amount(
             P_CALLEDFROM          => 2,
             P_TOP_LINE_ID         => l_top_id,
             P_COVLVL_ID           => l_cov_id,
             P_TERMINATION_DATE    => l_term_date,
             P_USAGE_TYPE          => l_usage_type,
             P_USAGE_PERIOD        => l_usage_period,
             X_AMOUNT              => X_amount,
             X_QUANTITY            => l_quantity
             );

           IF (line_rec.lse_id = 12) THEN
             OPEN  tot_line_billed(line_rec.id);
             FETCH tot_line_billed into l_bill_Qty;
             CLOSE tot_line_billed;
           END IF;

           X_AMOUNT := l_bill_qty - X_amount;

         ELSE
           -------------------------------------------------------------------------
           -- Begin partial period computation logic
           -- Developer Mani Choudhary
           -- Date 30-MAY-2005
           -- Call the procedure Get_Term_Amt_Ppc for partial periods
           -------------------------------------------------------------------------
           IF l_period_start IS NOT NULL AND
              l_period_type IS NOT NULL
           THEN
             IF line_rec.lse_id in (12,13) THEN
               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.pre_terminate_amount.hdr_termination.PPC',
                  'Calling Get_Terminate_Amount for usage with l_cov_line '||l_cov_line);
               END IF;
               Get_Terminate_Amount
               (
                P_CALLEDFROM       => p_calledfrom     ,
                P_LINE_ID          => line_rec.id             ,
                P_COV_LINE         => l_cov_line       ,
                P_TERMINATE_DATE   => l_term_date      ,
                P_PERIOD_START     => l_period_start   ,
                P_PERIOD_TYPE      => l_period_type    ,
                X_AMOUNT           => X_amount         ,
                X_RETURN_STATUS    => X_return_status
               );
               IF X_return_status <> 'S' THEN
                 RAISE G_EXCEPTION_HALT_VALIDATION;
               END IF;
             ELSE
               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.pre_terminate_amount.hdr_termination.PPC',
                  'Calling Get_Term_Amt_Ppc for service  with l_cov_line '||l_cov_line);
               END IF;
               Get_Term_Amt_Ppc
                 (P_termination_date => l_term_date,
                  P_line_id          => line_rec.id,
                  P_cov_line         => l_cov_line,
                  p_period_start     => l_period_start,
                  p_period_type      => l_period_type,
                  X_amount           => x_amount,
                  x_return_status    => l_return_status);
                IF l_return_status <> 'S' THEN
                  RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;

             END IF;
           ELSE
             Get_Terminate_Amount
              (
              P_CALLEDFROM       => p_calledfrom     ,
              P_LINE_ID          => line_rec.id      ,
              P_COV_LINE         => l_cov_line       ,
              P_TERMINATE_DATE   => l_term_date      ,
              X_AMOUNT           => X_amount         ,
              X_RETURN_STATUS    => X_return_status
              );
             IF X_return_status <> 'S' THEN
               RAISE G_EXCEPTION_HALT_VALIDATION;
             END IF;
           END IF;
         END IF;
       END IF;
       final_amount := nvl(final_amount,0) + nvl(X_amount,0);


     END LOOP;
   END IF;
   X_Amount :=  OKS_EXTWAR_UTIL_PVT.round_currency_amt(final_amount ,
                                                         l_currency_code);
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.pre_terminate_amount',
     'Returning Credit amount X_Amount '||X_Amount);
   END IF;
EXCEPTION
   WHEN G_EXCEPTION_HALT_VALIDATION THEN
     x_return_status := l_return_status ;
   WHEN OTHERS THEN
     x_return_status := OKC_API.G_RET_STS_ERROR ;

END pre_terminate_amount;


------------------------------------------------------------------------
  -- FUNCTION get_subscr_terminate_amount
------------------------------------------------------------------------
 PROCEDURE get_subscr_terminate_amount
   (
    P_CALLEDFROM                   IN        NUMBER DEFAULT Null,
    p_line_id                      IN        NUMBER,
    p_terminate_date               IN        DATE,
    p_billed_amount                IN        NUMBER,
    p_shipped_amount               IN        NUMBER,
    p_max_bill_date                IN        DATE,
    p_max_ship_date                IN        DATE,
    X_amount                      OUT NOCOPY NUMBER,
    X_return_status               OUT NOCOPY VARCHAR2
    )
    IS
 Cursor bill_amount_cur(p_line_id in number,p_term_date in DATE) is
 SELECT nvl(sum(amount),0) FROM oks_bill_cont_lines
   WHERE cle_id = p_line_id
   AND   bill_action = 'RI';

 Cursor ship_amount_cur(p_line_id in number,p_term_date in DATE) is
 SELECT nvl(sum(amount),0) FROM oks_subscr_elements
   WHERE dnz_cle_id = p_line_id
   AND   trunc(start_date) < trunc(p_term_date);

 l_ship_amount        NUMBER;
 l_bill_amount        NUMBER;
 l_amount             NUMBER;


 BEGIN
   x_return_status := OKC_API.G_RET_STS_SUCCESS ;

   IF (p_billed_amount <= p_shipped_amount ) THEN
      X_amount := 0;
   ELSE
     IF ((TRUNC(p_terminate_date) <  trunc(p_max_bill_date))
               AND (trunc(p_terminate_date) > trunc(p_max_ship_date) or (p_max_ship_date is null) )) THEN
       /* Two cursor are added because
          billing schedule and shipping schedule can be diiferent from
          each other. Contracts can have one period of 1 year billing schedule
          but monthly shipping schedule  */

       OPEN bill_amount_cur( p_line_id,p_terminate_date);
       FETCH bill_amount_cur into l_bill_amount;
       CLOSE bill_amount_cur;

       OPEN ship_amount_cur( p_line_id,p_terminate_date);
       FETCH ship_amount_cur into l_ship_amount;
       CLOSE ship_amount_cur;

        X_amount := l_bill_amount - l_ship_amount;
     ELSIF (trunc(p_terminate_date) <= trunc(p_max_ship_date)) THEN
        X_amount := p_billed_amount - p_shipped_amount;
     ELSIF (trunc(p_terminate_date) >=  trunc(p_max_bill_date))  THEN
        --OR (trunc(p_terminate_date) <=  trunc(p_max_ship_date))) THEN
        X_amount := 0;
     END IF;
   END IF;
 END;

------------------------------------------------------------------------
  -- FUNCTION get_terminate_amount
------------------------------------------------------------------------
  PROCEDURE get_terminate_amount
  (
    P_CALLEDFROM                   IN        NUMBER DEFAULT Null,
    p_line_id                      IN        NUMBER,
    p_cov_line                     IN        VARCHAR2,
    p_terminate_date               IN        DATE,
    p_period_start                 IN        VARCHAR2 DEFAULT NULL,
    p_period_type                  IN        VARCHAR2 DEFAULT NULL,
    X_amount                      OUT NOCOPY NUMBER,
    X_return_status               OUT NOCOPY VARCHAR2
  )IS

 Cursor get_future_period_amount is
  SELECT nvl(sum(bsl.amount),0) amount
        FROM
            okc_k_lines_b       okl2,
            oks_bill_sub_lines  bsl,
            oks_bill_cont_lines bcl,
            okc_k_lines_b       okl1
        WHERE   okl1.id = p_line_id
        AND     bcl.cle_id = okl1.id
        AND     bsl.bcl_id = bcl.id
        AND     bsl.cle_id = okl2.id
        AND     okl2.date_terminated is NULL
        AND     trunc(bsl.date_billed_from) > trunc(p_terminate_date);

  Cursor get_future_prd_amt_covlvl is
  SELECT nvl(sum(bsl.amount),0) amount
         FROM
                 okc_k_lines_b       okl,
                 oks_bill_sub_lines  bsl
          WHERE   okl.id = p_line_id
          AND     bsl.cle_id = okl.id
          AND     okl.date_terminated is NULL
          AND     trunc(bsl.date_billed_from) > trunc(p_terminate_date);

 Cursor get_cur_prd_amt_covlvl is
     SELECT nvl(bsl.amount,0)  amount,
            bsl.date_billed_from date_billed_from,
            bsl.date_billed_to   date_billed_to,
            okl.start_date       start_date,
            okl.end_date         end_date,
            okl.id               id
            FROM
                 oks_bill_sub_lines  bsl,
                 okc_k_lines_b       okl
           WHERE   okl.id     = p_line_id
           AND     okl.id = bsl.cle_id
           AND     okl.date_terminated is null
           AND     trunc(bsl.date_billed_to)   >= trunc(p_terminate_date)
           AND     trunc(bsl.date_billed_from) <= trunc(p_terminate_date);

 Cursor get_current_period_amount is
     SELECT nvl(bsl.amount,0)  amount,
            bcl.date_billed_from date_billed_from,
            bcl.date_billed_to   date_billed_to,
            okl1.start_date       start_date,
            okl1.end_date         end_date,
            okl1.id               id
            FROM
                 okc_k_lines_b       okl2,
                 oks_bill_sub_lines  bsl,
                 oks_bill_cont_lines bcl,
                 okc_k_lines_b       okl1
           WHERE   okl1.id     = p_line_id
           AND     bcl.cle_id = okl1.id
           AND     bsl.bcl_id = bcl.id
           AND     okl2.id = bsl.cle_id
           AND     okl2.date_terminated is null
           AND     trunc(bcl.date_billed_to)   >= trunc(p_terminate_date)
           AND     trunc(bcl.date_billed_from) <= trunc(p_terminate_date);

  Cursor rules_csr(p_line_id in number,p_termination_date in  Date) Is
       SELECT  str.uom_code l_freq
           FROM oks_stream_levels_b   str,
                oks_level_elements    lvl
           WHERE lvl.cle_id =  p_line_id
           AND   p_termination_date BETWEEN lvl.date_start AND lvl.date_end
           AND   lvl.rul_id = str.id;



Cursor l_rel_csr_cov (p_line_id in NUMBER) Is
   SELECT id FROM   OKC_K_REL_OBJS_V
         WHERE  cle_id = p_line_id;

Cursor l_rel_csr (p_line_id in NUMBER) Is
    SELECT obj.id FROM   OKC_K_REL_OBJS_V obj,
                         OKC_K_LINES_B  ln
        WHERE  obj.cle_id = ln.id
        AND    ln.cle_id =  p_line_id;

Cursor line_extwar_cur( p_line_id in NUMBER) is
  SELECT price_negotiated
        ,start_date
        ,end_date
        ,dnz_chr_id
    FROM   Okc_k_lines_b
    WHERE  cle_id = p_line_id
    AND    lse_id = 25
    AND    date_cancelled is NULL --LLC BUG FIX 4742661
    AND    date_terminated is NULL;


Cursor subline_extwar_cur( p_line_id in NUMBER) is
  SELECT     price_negotiated
            ,start_date
            ,end_date
            ,dnz_chr_id
    FROM   Okc_k_lines_b
    WHERE  id = p_line_id
    AND    lse_id = 25
    AND    date_cancelled is NULL --LLC BUG FIX 4742661
    AND    date_terminated is NULL;

Cursor line_lse_id_cur (p_id IN NUMBER) is
SELECT lse_id
      FROM okc_k_lines_b
      WHERE id = p_id;


 cur_rec       get_current_period_amount%ROWTYPE;
 p_freq        okc_rules_b.object1_id1%TYPE;

 l_amount      NUMBER;
 l_diff        NUMBER;
 l_id          NUMBER;
 l_lse_id      NUMBER;
 final_amount  NUMBER;
 l_ctr         BOOLEAN;

 BEGIN
   final_amount := 0;

   x_return_status := OKC_API.G_RET_STS_SUCCESS ;


   OPEN  line_lse_id_cur(p_line_id);
   FETCH line_lse_id_cur into l_lse_id;
   CLOSE line_lse_id_cur;

   l_ctr  := TRUE ; -- NORMAL PROCESSING

   IF (p_cov_line = 'N') THEN
     IF (l_lse_id = 19) THEN
       OPEN l_rel_csr(p_line_id) ;
       FETCH l_rel_csr into l_id;
       IF (l_rel_csr%FOUND ) THEN
         l_ctr := FALSE; --FOR EXT WAR BILLED FROM OM
       ELSE
         l_ctr := TRUE;  --FOR EXT WAR BILLED IN SC
       END IF;
       CLOSE l_rel_csr;
     END IF;

     IF (l_ctr = TRUE) THEN
       OPEN get_current_period_amount;
       FETCH get_current_period_amount into cur_rec;

       OPEN  rules_csr(cur_rec.id ,p_terminate_date);
       FETCH rules_csr into p_freq;
       CLOSE rules_csr;

       LOOP
         EXIT WHEN get_current_period_amount%NOTFOUND;
         -------------------------------------------------------------------------
         -- Begin partial period computation logic
         -- Developer Mani Choudhary
         -- Date 15-JUN-2005
         -------------------------------------------------------------------------
         IF p_period_type IS NOT NULL AND
            p_period_start IS NOT NULL AND
            l_lse_id = 12
         THEN
           l_amount:= Get_partial_term_amount(
                                    p_start_date        => cur_rec.date_billed_from,
                                    p_end_date          => cur_rec.date_billed_to,
                                    P_termination_date  => p_terminate_date,
                                    P_amount            => cur_rec.amount,
                                    P_uom               => p_freq,
                                    P_period_start      => P_period_start,
                                    P_period_type       => P_period_type
                                    );
            IF l_amount is NULL THEN
               RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
         ELSE
           get_bill_amount_period(
                                -99,
                                cur_rec.start_date,
                                cur_rec.date_billed_from,
                                --p_con_end_date,
                                p_freq,
                                cur_rec.amount,--p_con_amount,
                                cur_rec.date_billed_to,
                                p_terminate_date,
                                G_NONREGULAR,
                                l_amount);
         END IF;
         Final_amount := nvl(Final_Amount,0) + nvl(l_amount,0);

         FETCH get_current_period_amount into cur_rec;
       END LOOP;

       CLOSE get_current_period_amount;

       OPEN get_future_period_amount;
       FETCH get_future_period_amount into l_amount;
       CLOSE get_future_period_amount;

       Final_amount := Final_Amount + l_amount;

     ELSE
       Final_amount := 0;
       l_amount := 0;

       FOR line_extwar_Rec in line_extwar_cur(p_line_id)
       LOOP
         l_diff := abs(TRUNC(line_extwar_Rec.end_date - line_extwar_Rec.start_date) + 1);
         l_amount := line_extwar_Rec.PRICE_NEGOTIATED/l_diff;

         IF (trunc(p_terminate_date) < trunc(line_extwar_Rec.start_date)) THEN
           l_diff :=  abs(trunc((line_extwar_Rec.end_date + 1 ) -
                                        trunc(line_extwar_Rec.start_date)));
         ELSE
           l_diff :=  abs(trunc((line_extwar_Rec.end_date + 1 ) -
                                        p_terminate_date));
         END IF;

         l_amount := (l_amount * l_diff);
         Final_amount := nvl(Final_Amount,0) + nvl(l_amount,0);

       END LOOP;
     END IF;

     x_amount     := Final_Amount;
   ELSE
     l_ctr := TRUE;

     IF (l_lse_id = 25) THEN
       OPEN l_rel_csr_cov(p_line_id) ;
       FETCH l_rel_csr_cov into l_id;
       IF (l_rel_csr_cov%FOUND ) THEN
         l_ctr := FALSE; --FOR EXT WAR BILLED FROM OM
       ELSE
         l_ctr := TRUE;  --FOR EXT WAR BILLED IN SC
       END IF;
       CLOSE l_rel_csr_cov;
     END IF;

     IF (l_ctr = TRUE) THEN
       OPEN get_cur_prd_amt_covlvl;
       FETCH get_cur_prd_amt_covlvl into cur_rec;

       OPEN  rules_csr(cur_rec.id ,p_terminate_date);
       FETCH rules_csr into p_freq;
       CLOSE rules_csr;

       LOOP
         EXIT WHEN get_cur_prd_amt_covlvl%NOTFOUND;
         -------------------------------------------------------------------------
         -- Begin partial period computation logic
         -- Developer Mani Choudhary
         -- Date 15-JUN-2005
         -------------------------------------------------------------------------
         IF p_period_type IS NOT NULL AND
            p_period_start IS NOT NULL AND
            l_lse_id = 13
         THEN
           l_amount:= Get_partial_term_amount(
                                    p_start_date        => cur_rec.date_billed_from,
                                    p_end_date          => cur_rec.date_billed_to,
                                    P_termination_date  => p_terminate_date,
                                    P_amount            => cur_rec.amount,
                                    P_uom               => p_freq,
                                    P_period_start      => P_period_start,
                                    P_period_type       => P_period_type
                                    );
            IF l_amount is NULL THEN
               RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
         ELSE

           get_bill_amount_period(
                                 -99,
                                cur_rec.start_date,
                                cur_rec.date_billed_from,
                                --p_con_end_date,
                                p_freq,
                                cur_rec.amount,--p_con_amount,
                                cur_rec.date_billed_to,
                                p_terminate_date,
                                G_NONREGULAR,
                                l_amount);
         END IF;
         Final_amount := Final_Amount + nvl(l_amount,0);

         FETCH get_cur_prd_amt_covlvl into cur_rec;
       END LOOP;
       CLOSE get_cur_prd_amt_covlvl;

       OPEN get_future_prd_amt_covlvl;
       FETCH get_future_prd_amt_covlvl into l_amount;
       CLOSE get_future_prd_amt_covlvl;

       Final_amount := Final_Amount + l_amount;
     ELSE
       Final_amount := 0;
       l_amount := 0;
       l_diff := 0;

       FOR subline_extwar_Rec in subline_extwar_cur(p_line_id)
       LOOP
         l_diff := abs(TRUNC(subline_extwar_Rec.end_date - subline_extwar_Rec.start_date) + 1);
         l_amount := subline_extwar_Rec.PRICE_NEGOTIATED/l_diff;

         IF (trunc(p_terminate_date)< trunc(subline_extwar_Rec.start_date)) THEN

           l_diff :=  abs(trunc((subline_extwar_Rec.end_date + 1 ) -
                                        trunc(subline_extwar_Rec.start_date)));
         ELSE
           l_diff :=  abs(trunc((subline_extwar_Rec.end_date + 1 ) -
                                        p_terminate_date));
         END IF;

         l_amount := (l_amount * l_diff);
         Final_amount := nvl(Final_Amount,0) + nvl(l_amount,0);
       END LOOP;
     END IF;

     x_amount     := Final_Amount;
   END IF;



 EXCEPTION
   WHEN G_EXCEPTION_HALT_VALIDATION THEN
        x_return_status := OKC_API.G_RET_STS_ERROR ;
   WHEN OTHERS THEN
     x_return_status := OKC_API.G_RET_STS_ERROR ;
 END;





------------------------------------------------------------------------
  -- FUNCTION create_term_recs
------------------------------------------------------------------------
  FUNCTION create_term_recs (
    P_CALLEDFROM                   IN         NUMBER,
    p_bcl_id_new                   IN         NUMBER,
    p_bcl_id                       IN         NUMBER,
    p_con_start_date               IN         DATE,
    p_con_end_date                 IN         DATE,
    p_freq                         IN         VARCHAR2,
    p_con_amount                   IN         NUMBER,
    p_term_date                    IN         DATE,
    p_term_amt                     IN         NUMBER,
    p_con_termination_amount       IN         NUMBER,
    p_stat                         IN         NUMBER,
    p_currency_code                IN         VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2

  ) RETURN NUMBER IS

   SUBTYPE l_bslv_tbl_type_in  is OKS_bsl_PVT.bslv_tbl_type;
   l_bslv_tbl_in   l_bslv_tbl_type_in;
   l_bslv_tbl_out   l_bslv_tbl_type_in;
   SUBTYPE l_bsdv_tbl_type_in  is OKS_bsd_PVT.bsdv_tbl_type;
   l_bsdv_tbl_in   l_bsdv_tbl_type_in;
   l_bsdv_tbl_out   l_bsdv_tbl_type_in;

  CURSOR bsl_cur(id_in IN NUMBER) IS
         SELECT  bsl.id
                ,bsl.cle_id
                ,bsl.average
                ,bsl.amount
                ,bsl.Date_Billed_from
                ,bsl.Date_Billed_to
                ,bsl.Attribute_category
                ,bsl.Attribute1
                ,bsl.Attribute2
                ,bsl.Attribute3
                ,bsl.Attribute4
                ,bsl.Attribute5
                ,bsl.Attribute6
                ,bsl.Attribute7
                ,bsl.Attribute8
                ,bsl.Attribute9
                ,bsl.Attribute10
                ,bsl.Attribute11
                ,bsl.Attribute12
                ,bsl.Attribute13
                ,bsl.Attribute14
                ,bsl.Attribute15
         FROM   oks_bill_sub_lines bsl,
                okc_k_lines_b      okl
         WHERE  bcl_id = id_in
         AND    bsl.cle_id = okl.id
         AND    okl.date_cancelled is null --LLC BUG FIX 4742661
         AND    okl.date_terminated is null;

  CURSOR bsd_cur(id_in IN NUMBER) IS
         SELECT  bsl_id_averaged
                ,bsd_id
                ,bsd_id_applied
                ,unit_of_measure
                ,fixed
                ,actual
                ,default_default
                ,amcv_yn
                ,adjustment_level
                ,adjustment_minimum
                ,result
                ,amount
                ,start_reading
                ,end_reading
                ,ccr_id
                ,cgr_id
                ,Attribute_category
                ,Attribute1
                ,Attribute2
                ,Attribute3
                ,Attribute4
                ,Attribute5
                ,Attribute6
                ,Attribute7
                ,Attribute8
                ,Attribute9
                ,Attribute10
                ,Attribute11
                ,Attribute12
                ,Attribute13
                ,Attribute14
                ,Attribute15
         FROM   oks_bill_sub_line_dtls
         WHERE  bsl_id = id_in;

   Cursor Bcl_Csr Is
         SELECT  Id
                 ,OBJECT_VERSION_NUMBER
                 ,CLE_ID
                 ,BTN_ID
                 ,DATE_BILLED_FROM
                 ,DATE_BILLED_TO
                 ,DATE_NEXT_INVOICE
                 ,AMOUNT
                 ,BILL_ACTION
                 ,ATTRIBUTE_CATEGORY
                 ,ATTRIBUTE1
                 ,ATTRIBUTE2
                 ,ATTRIBUTE3
                 ,ATTRIBUTE4
                 ,ATTRIBUTE5
                 ,ATTRIBUTE6
                 ,ATTRIBUTE7
                 ,ATTRIBUTE8
                 ,ATTRIBUTE9
                 ,ATTRIBUTE10
                 ,ATTRIBUTE11
                 ,ATTRIBUTE12
                 ,ATTRIBUTE13
                 ,ATTRIBUTE14
                 ,ATTRIBUTE15
         FROM  OKS_BILL_CONT_LINES_V
         WHERE  ID = p_bcl_id_new;

 Cursor cur_billinstance_sum (p_bcl_id IN NUMBER) is
  SELECT bill_instance_number ,bsl_id
  FROM  OKS_BILL_TXN_LINES txn
  WHERE bcl_id = p_bcl_id
  AND   bsl_id is null;

 Cursor cur_billinstance_dtl (p_bcl_id IN NUMBER,
                              p_cle_id IN NUMBER) is
  SELECT bill_instance_number ,bsl_id
  FROM  OKS_BILL_TXN_LINES txn
       ,OKS_BILL_SUB_LINES bsl
  WHERE txn.bcl_id     = p_bcl_id
  AND   bsl.cle_id = p_cle_id
  AND   bsl.id     = txn.bsl_id;



   bsl_rec bsl_cur%ROWTYPE;
   bsd_rec bsd_cur%ROWTYPE;
   bcl_rec bcl_csr%rowtype;

   bill_inst_rec_sum  cur_billinstance_sum%ROWTYPE;
   bill_inst_rec_dtl  cur_billinstance_dtl%ROWTYPE;

   l_ret_stat         VARCHAR2(20);
   l_msg_data         VARCHAR2(2000);
   l_msg_cnt          NUMBER;
   l_stat             NUMBER;
   l_amount           NUMBER ;
   l_round_amt        NUMBER ;
   l_return_status    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN


    X_return_status := l_return_status;

    FOR bsl_rec IN bsl_cur(p_bcl_id)
    LOOP

      IF (trunc(p_term_date) <= trunc(bsl_rec.date_billed_to)) THEN

        IF (trunc(p_term_date) <= trunc(bsl_rec.date_billed_to)
           AND   trunc(p_term_date) <= trunc(bsl_rec.date_billed_from) ) THEN
          --errorout('SERVICE :- CREATE TERM G-REGULAR');

          l_stat := G_REGULAR;
        ELSE
          --errorout('SERVICE :- CREATE TERM G-NONREGULAR');

          l_stat := G_NONREGULAR;
        END IF;

        OPEN  bcl_csr;
        FETCH bcl_csr into bcl_rec;
        CLOSE bcl_csr;

        --l_bslv_tbl_in(1).OBJECT_VERSION_NUMBER:=bsl_rec.object_version_number;
        l_bslv_tbl_in(1).BCL_ID  := p_bcl_id_new;
        l_bslv_tbl_in(1).CLE_ID := bsl_rec.cle_id;

        /*Average field is used to store bill_instance_number
          of the parent. It is used to populate referenc_line_id in
          AR Feeder
        */
        OPEN  cur_billinstance_sum(p_bcl_id);
        FETCH cur_billinstance_sum into  bill_inst_rec_sum;

        IF (cur_billinstance_sum%FOUND) THEN --Summary billing for parent
          CLOSE cur_billinstance_sum;
          l_bslv_tbl_in(1).AVERAGE:= bill_inst_rec_sum.bill_instance_number;
        ELSE   --Detailed billing for parent
          CLOSE cur_billinstance_sum;
          OPEN  cur_billinstance_dtl(p_bcl_id,bsl_rec.cle_id);
          FETCH cur_billinstance_dtl into  bill_inst_rec_dtl;

          l_bslv_tbl_in(1).AVERAGE:= bill_inst_rec_dtl.bill_instance_number;
          CLOSE cur_billinstance_dtl;
        END IF;


        --l_bslv_tbl_in(1).AVERAGE := bsl_rec.average;

        IF ( bsl_rec.date_billed_from < p_term_date ) THEN
          l_bslv_tbl_in(1).DATE_BILLED_FROM := p_term_date;
        ELSE
          l_bslv_tbl_in(1).DATE_BILLED_FROM := bsl_rec.date_billed_from;
        END IF;

        l_bslv_tbl_in(1).DATE_BILLED_TO := bsl_rec.date_billed_to;
        l_bslv_tbl_in(1).ATTRIBUTE_CATEGORY := bsl_rec.attribute_category;
        l_bslv_tbl_in(1).ATTRIBUTE1 := bsl_rec.attribute1;
        l_bslv_tbl_in(1).ATTRIBUTE2 := bsl_rec.attribute2;
        l_bslv_tbl_in(1).ATTRIBUTE3 := bsl_rec.attribute3;
        l_bslv_tbl_in(1).ATTRIBUTE4 := bsl_rec.attribute4;
        l_bslv_tbl_in(1).ATTRIBUTE5 := bsl_rec.attribute5;
        l_bslv_tbl_in(1).ATTRIBUTE6 := bsl_rec.attribute6;
        l_bslv_tbl_in(1).ATTRIBUTE7 := bsl_rec.attribute7;
        l_bslv_tbl_in(1).ATTRIBUTE8 := bsl_rec.attribute8;
        l_bslv_tbl_in(1).ATTRIBUTE9 := bsl_rec.attribute9;
        l_bslv_tbl_in(1).ATTRIBUTE10 := bsl_rec.attribute10;
        l_bslv_tbl_in(1).ATTRIBUTE11 := bsl_rec.attribute11;
        l_bslv_tbl_in(1).ATTRIBUTE12 := bsl_rec.attribute12;
        l_bslv_tbl_in(1).ATTRIBUTE13 := bsl_rec.attribute13;
        l_bslv_tbl_in(1).ATTRIBUTE14 := bsl_rec.attribute14;
        l_bslv_tbl_in(1).ATTRIBUTE15 := bsl_rec.attribute15;
        l_bslv_tbl_in(1).date_to_interface :=  get_term_end_date (bcl_rec.cle_id , p_term_date );

        IF (l_stat = G_REGULAR) THEN
          IF (p_term_amt is not null) THEN
            l_amount := OKS_EXTWAR_UTIL_PVT.round_currency_amt(
                                ((p_term_amt * bsl_rec.amount)/
                                  p_con_termination_amount),p_currency_code);
            l_round_amt := l_amount;
            l_bslv_tbl_in(1).AMOUNT := -1 * l_amount;
          ELSE
            l_bslv_tbl_in(1).AMOUNT := -1 * (bsl_rec.amount );
            l_amount    := bsl_rec.amount;
            l_round_amt := bsl_rec.amount;
          END IF;
        ELSE
          get_bill_amount_period(
                                     -99,
                                     p_con_start_date,
                                     bsl_rec.date_billed_from,
                                     --p_con_end_date,
                                     p_freq,
                                     bsl_rec.amount,--p_con_amount,
                                     bsl_rec.date_billed_to,
                                     p_term_date,
                                     G_NONREGULAR,
                                     l_amount);

          IF (p_term_amt is not null) Then
            l_amount :=  OKS_EXTWAR_UTIL_PVT.round_currency_amt(
                                ((p_term_amt * l_amount)/
                                  p_con_termination_amount),p_currency_code);
            l_round_amt := l_amount;
            l_bslv_tbl_in(1).AMOUNT := -1 * l_amount;

          ELSE
            l_amount := OKS_EXTWAR_UTIL_PVT.round_currency_amt(
                                         l_amount, p_currency_code );
            l_round_amt := l_amount;
            l_bslv_tbl_in(1).AMOUNT := -1 * (l_amount );
          END IF;

        END IF;

        OKS_BILLSUBLINE_PUB.insert_Bill_subLine_Pub
            (
            p_api_version                  =>  1.0,
            p_init_msg_list                =>  'T',
            x_return_status                =>   l_return_status,
            x_msg_count                    =>   l_msg_cnt,
            x_msg_data                     =>   l_msg_data,
            p_bslv_tbl                     =>   l_bslv_tbl_in,
            x_bslv_tbl                     =>   l_bslv_tbl_out
            );

        --errorout('SERVICE :- CREATE TERM RECS INSERT BSL' || l_return_status);


        IF not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
          x_return_status := l_return_status;
          Raise G_EXCEPTION_HALT_VALIDATION;
        END IF;

        g_credit_amount := nvl(g_credit_amount,0) + l_amount;
        g_bsl_id        := l_bslv_tbl_out(1).id;
        g_bcl_id        := p_bcl_id_new;

        FOR bsd_rec IN bsd_cur(bsl_rec.id)
        LOOP

          l_bsdv_tbl_in(1).BSL_ID  := l_bslv_tbl_out(1).id;
          l_bsdv_tbl_in(1).BSL_ID_AVERAGED  := bsd_rec.bsl_id_averaged;
          l_bsdv_tbl_in(1).BSD_ID  := bsd_rec.bsd_id;
          l_bsdv_tbl_in(1).BSD_ID_APPLIED  := bsd_rec.bsd_id_applied;
          l_bsdv_tbl_in(1).UNIT_OF_MEASURE := bsd_rec.unit_of_measure;
          l_bsdv_tbl_in(1).FIXED := bsd_rec.fixed;
          l_bsdv_tbl_in(1).ACTUAL := bsd_rec.actual;
          l_bsdv_tbl_in(1).DEFAULT_DEFAULT := bsd_rec.default_default;
          l_bsdv_tbl_in(1).AMCV_YN := bsd_rec.amcv_yn;
          l_bsdv_tbl_in(1).ADJUSTMENT_LEVEL := bsd_rec.adjustment_level;
          l_bsdv_tbl_in(1).ADJUSTMENT_MINIMUM := bsd_rec.adjustment_minimum;
          l_bsdv_tbl_in(1).RESULT := bsd_rec.result;
          l_bsdv_tbl_in(1).ATTRIBUTE_CATEGORY := bsd_rec.attribute_category;
          l_bsdv_tbl_in(1).ATTRIBUTE1 := bsd_rec.attribute1;
          l_bsdv_tbl_in(1).ATTRIBUTE2 := bsd_rec.attribute2;
          l_bsdv_tbl_in(1).ATTRIBUTE3 := bsd_rec.attribute3;
          l_bsdv_tbl_in(1).ATTRIBUTE4 := bsd_rec.attribute4;
          l_bsdv_tbl_in(1).ATTRIBUTE5 := bsd_rec.attribute5;
          l_bsdv_tbl_in(1).ATTRIBUTE6 := bsd_rec.attribute6;
          l_bsdv_tbl_in(1).ATTRIBUTE7 := bsd_rec.attribute7;
          l_bsdv_tbl_in(1).ATTRIBUTE8 := bsd_rec.attribute8;
          l_bsdv_tbl_in(1).ATTRIBUTE9 := bsd_rec.attribute9;
          l_bsdv_tbl_in(1).ATTRIBUTE10 := bsd_rec.attribute10;
          l_bsdv_tbl_in(1).ATTRIBUTE11 := bsd_rec.attribute11;
          l_bsdv_tbl_in(1).ATTRIBUTE12 := bsd_rec.attribute12;
          l_bsdv_tbl_in(1).ATTRIBUTE13 := bsd_rec.attribute13;
          l_bsdv_tbl_in(1).ATTRIBUTE14 := bsd_rec.attribute14;
          l_bsdv_tbl_in(1).ATTRIBUTE15 := bsd_rec.attribute15;
          l_bsdv_tbl_in(1).start_reading := bsd_rec.start_reading;
          l_bsdv_tbl_in(1).end_reading := bsd_rec.end_reading;
          l_bsdv_tbl_in(1).ccr_id := bsd_rec.ccr_id;
          l_bsdv_tbl_in(1).cgr_id := bsd_rec.cgr_id;

          l_bsdv_tbl_in(1).AMOUNT := -1 * (l_round_amt );

          OKS_BSL_det_PUB.insert_bsl_det_Pub
               (
                  p_api_version                  =>  1.0,
                  p_init_msg_list                =>  'T',
                  x_return_status                =>   l_ret_stat,
                  x_msg_count                    =>   l_msg_cnt,
                  x_msg_data                     =>   l_msg_data,
                  p_bsdv_tbl                     =>   l_bsdv_tbl_in,
                  x_bsdv_tbl                     =>   l_bsdv_tbl_out
               );

          --errorout('SERVICE :- CREATE TERM RECS INSERT BSL DET ' || l_return_status);

          IF not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            Raise G_EXCEPTION_HALT_VALIDATION;
          END IF;

          UPDATE oks_bill_cont_lines
            SET amount = bcl_rec.amount - nvl(l_round_amt,0)
            WHERE id   = bcl_rec.id;


        END LOOP; -- LOOP for BSD
      END If; -- p_termination_date <= bsl_rec.date_billed_to
         --exit;
    END LOOP;
    return 0;

  EXCEPTION
    WHEN  G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status   :=   l_return_status;
    WHEN  OTHERS THEN
      x_return_status   :=   OKC_API.G_RET_STS_UNEXP_ERROR;
      OKC_API.set_message(G_APP_NAME,G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE,G_SQLERRM_TOKEN, SQLERRM);

  END create_term_recs;



/*****
Procedure create_bank_Account(
     p_dnz_chr_id      IN               NUMBER,
     p_bill_start_date IN               DATE,
     p_currency_code   IN               VARCHAR2,
     x_status         OUT NOCOPY        VARCHAR2,
     l_msg_count   IN OUT NOCOPY        NUMBER,
     l_msg_data    IN OUT NOCOPY        VARCHAR2)
  IS
Cursor ccr_rule_csr(p_hdr_id IN NUMBER) Is
   SELECT rhdr.cc_no         ,
          rhdr.cc_expiry_date,
          rhdr.cc_bank_acct_id,
          hdr.bill_to_site_use_id
   FROM   oks_k_headers_b  rhdr,
          okc_k_headers_b  hdr
   WHERE  rhdr.chr_id   = hdr.id
   AND    hdr.id        = p_hdr_id;

Cursor line_grp_csr(p_hdr_id IN NUMBER) Is
   SELECT  line.id                    line_id,
           rline.cc_no                line_cc_number,
           rline.cc_expiry_date       line_cc_exp_date,
           rline.cc_bank_acct_id      line_bank_number,
           line.bill_to_site_use_id   site_use_id
   FROM
             oks_k_lines_b      rline,
             okc_k_lines_b      line
   WHERE line.dnz_chr_id = p_hdr_id
   AND   line.lse_id  in (1,12,19)
   AND   line.date_cancelled is NULL --LLC BUG FIX 4742661
   AND   line.id = rline.cle_id;




Cursor cust_acct_csr(p_object1_id1 IN  NUMBER) Is
  SELECT ca.cust_account_id
  FROM  hz_cust_acct_sites_all ca,
        hz_cust_site_uses_all cs
  WHERE ca.cust_acct_site_id = cs.cust_acct_site_id
  AND   cs.site_use_id = p_object1_id1;


rule_bank_id              VARCHAR2(30);
cc_number                 VARCHAR2(30);
line_cc_number            VARCHAR2(30);
cc_exp_date               DATE;
cc_rule_id                NUMBER;
cust_account_id           NUMBER;
site_use_id               NUMBER;
x_bank_account_id         NUMBER;
x_bank_account_uses_id    NUMBER;
l_api_version   CONSTANT  NUMBER      := 1.0;
l_init_msg_list CONSTANT  VARCHAR2(1) := 'F';
l_return_status           VARCHAR2(1);

BEGIN


  cc_rule_id := NULL;
  rule_bank_id := NULL;
  x_status     := 'S';

  OPEN  ccr_rule_csr(p_dnz_chr_id);
  FETCH ccr_rule_csr into
                cc_number, cc_exp_date,
                rule_bank_id,
                site_use_id;
  CLOSE ccr_rule_csr;


  IF (rule_bank_id is NULL) AND (cc_number is NOT NULL)  THEN


    OPEN  cust_acct_csr(site_use_id);
    FETCH cust_acct_csr into cust_account_id;
    CLOSE cust_acct_csr;

    x_bank_account_id := NULL;

    arp_bank_pkg.process_cust_bank_account
          (
           p_trx_date             => p_bill_start_date,
           p_currency_code        => p_currency_code,
           p_cust_id              => cust_account_id,
           p_site_use_id          => site_use_id,
           p_credit_card_num      => cc_number,
           p_exp_date             => cc_exp_date,
           p_bank_account_id      => x_bank_account_id,
           p_bank_account_uses_id => x_bank_account_uses_id
           );



    IF (x_bank_account_id IS NULL) THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'AR API returns with failure');
      x_status := 'E';
      Raise G_EXCEPTION_HALT_VALIDATION;
    ELSE

      UPDATE oks_k_headers_b
      SET cc_bank_acct_id  = x_bank_account_id
      WHERE chr_id =  p_dnz_chr_id;

    END IF; -- check null for bank account id

  END IF; -- for bank account id

  FOR line_cur in line_grp_csr(p_dnz_chr_id)
  LOOP
    IF ((line_cur.line_bank_number is NULL) AND
           (line_cur.line_cc_number is NOT NULL)) THEN
      site_use_id := NULL;
      cust_account_id := NULL;
      x_bank_account_id := NULL;


      OPEN  cust_acct_csr(line_cur.site_use_id);
      FETCH cust_acct_csr into cust_account_id;
      CLOSE cust_acct_csr;

      arp_bank_pkg.process_cust_bank_account
            (
             p_trx_date             => p_bill_start_date,
             p_currency_code        => p_currency_code,
             p_cust_id              => cust_account_id,
             p_site_use_id          => line_cur.site_use_id,
             p_credit_card_num      => line_cur.line_cc_number,
             p_exp_date             => line_cur.line_cc_exp_date,
             p_bank_account_id      => x_bank_account_id,
             p_bank_account_uses_id => x_bank_account_uses_id
            );

      IF (x_bank_account_id IS NULL) THEN
        FND_FILE.PUT_LINE( FND_FILE.LOG, 'Error in getting bank account  for line '||line_cur.line_id);
        x_status := 'E';
        Raise G_EXCEPTION_HALT_VALIDATION;
      ELSE
        UPDATE oks_k_lines_b
        SET cc_bank_acct_id = x_bank_account_id,
            cc_no           = line_cur.line_cc_number,
            cc_expiry_date  = line_Cur.line_cc_exp_date
        WHERE cle_id = line_cur.line_id;
      END IF;


    END IF; -- Check for cc number null or changed
  END LOOP;


EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
    l_return_status   :=   OKC_API.G_RET_STS_UNEXP_ERROR;
    OKC_API.set_message(G_APP_NAME,G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE,G_SQLERRM_TOKEN, SQLERRM);
 WHEN OTHERS THEN
    l_return_status   :=   OKC_API.G_RET_STS_UNEXP_ERROR;
    OKC_API.set_message(G_APP_NAME,G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE,G_SQLERRM_TOKEN, SQLERRM);

END create_bank_Account;
***/



--------------------------------------------------------------------------------------------------------------------
                     -- Pre_terminate_extwar
-------------------------------------------------------------------------------------------------------------------
Procedure Pre_terminate_extwar
(
    P_calleDfrom                 IN           NUMBER,
    p_line_id                    IN           NUMBER,
    p_termination_date           IN           DATE,
    p_suppress_credit            IN           VARCHAR2,
    p_termination_amount         IN           NUMBER,
    p_con_termination_amount     IN           NUMBER,
    p_cov_line                   IN           VARCHAR2,
    p_full_credit                IN           VARCHAR2,
    --p_existing_credit            IN           NUMBER,
    x_amount                     OUT  NOCOPY  NUMBER,
    X_return_status              OUT  NOCOPY  VARCHAR2
  )
IS


Cursor l_covlvl_csr (p_line_id in number,p_cov_line in Varchar)Is
      SELECT cle.Id
              ,cle.start_date
              ,cle.end_date
              ,cle.price_negotiated
              ,cle.cle_id
              ,TO_NUMBER(cim.object1_id1) instance_id
        FROM  Okc_k_lines_b cle,
                 okc_k_items cim
        WHERE cle.id = p_line_id
        AND  cle.lse_id = 25
        AND  cle.id = cim.cle_id;

Cursor l_cov_csr (p_line_id in number,p_cov_line in Varchar)Is
       SELECT  Id
              ,start_date
              ,end_date
              ,price_negotiated
              ,cle_id
        FROM  Okc_k_lines_b
        WHERE (cle_id = p_line_id
               And  lse_id = 25
               AND  date_cancelled is null --LLC BUG FIX 4742661
               And  date_terminated is null) OR
              (id  = p_line_id
               And  lse_id = 25
               AND  date_cancelled is null --LLC BUG FIX 4742661
               And  date_terminated is null);


Cursor l_extwar_csr(p_line_id in number) Is
       SELECT okl1.price_negotiated
              ,okl1.start_date
              ,okl1.end_date
              ,okl1.dnz_chr_id
              ,okl1.id
       FROM   Okc_k_lines_b     okl1
       WHERE  okl1.id = p_line_id
       AND    okl1.lse_id = 19
       AND    exists (Select 1 from okc_k_lines_b okl2
                      Where  okl2.cle_id = okl1.id
                      And    okl2.lse_id = 25
                      AND    okl2.date_cancelled is null --LLC BUG FIX 4742661
                      And    okl2.date_terminated is null);





Cursor l_curr_csr(p_chr_id number) is
       SELECT  currency_code
       FROM okc_k_headers_b
       WHERE id = p_chr_id;

Cursor qty_uom_csr(p_cle_id  Number) Is
     SELECt  okc.Number_of_items
            ,tl.Unit_of_measure uom_code
     FROM   OKC_K_ITEMS OKC
           ,mtl_units_of_measure_tl tl
     WHERE  okc.cle_id = P_cle_id
     AND    tl.uom_code = OKC.uom_code
     AND    tl.language = USERENV('LANG');

-- BUG#3312595 mchoudha: Cursor to check for service request
-- against the subline

Cursor cur_subline_sr(p_id IN NUMBER,p_cp_id IN NUMBER) IS
SELECT 'x'
FROM CS_INCIDENTS_ALL_B  sr
where sr.contract_service_id = p_id
AND   sr.customer_product_id = p_cp_id
and   sr.status_flag = 'O';

Cursor cur_lineno(p_id IN NUMBER) IS
SELECT p.line_number||'.'||s.line_number,
       hdr.contract_number
FROM   okc_k_lines_b p,
       okc_k_lines_b s,
       okc_k_headers_b hdr
WHERE  s.id=p_id
AND    p.id=s.cle_id
AND    hdr.id=p.dnz_chr_id;



-- End BUG#3312595 mchoudha


   CURSOR  l_hdr_csr(p_id in NUMBER ) is
  SELECT dnz_chr_id
    FROM OKC_K_LINES_B
   WHERE id = p_id;


l_extwar_rec   l_extwar_csr%rowtype;
l_cov_rec      l_covlvl_csr%rowtype;

SUBTYPE l_bclv_tbl_type_in  is OKS_bcl_PVT.bclv_tbl_type;
l_bclv_tbl_in   l_bclv_tbl_type_in;
l_bclv_tbl_out   l_bclv_tbl_type_in;
SUBTYPE l_bslv_tbl_type_in  is OKS_bsl_PVT.bslv_tbl_type;
l_bslv_tbl_in   l_bslv_tbl_type_in;
l_bslv_tbl_out   l_bslv_tbl_type_in;

SUBTYPE l_bsdv_tbl_type_in  is OKS_bsd_PVT.bsdv_tbl_type;

 L_BSDV_TBL_IN           L_BSDV_TBL_TYPE_IN;
 L_BSDV_TBL_OUT          L_BSDV_TBL_TYPE_IN;
 L_RET_STAT              VARCHAR2(1);
 L_MSG_CNT               NUMBER;
 L_MSG_DATA              VARCHAR2(2000);
 L_BILL_AMOUNT           NUMBER ;
 L_DIFF                  NUMBER;
 L_INDEX                 NUMBER;
 L_CURRENCY_CODE         VARCHAR2(15);
 L_ROUND_AMT             NUMBER;
 L_TOP_LINE_ID           NUMBER;
 L_COV_LINE_ID           NUMBER;
 --L_MANUAL_CREDIT         NUMBER;
 L_PROCESS_FLAG          BOOLEAN;
 L_RETURN_STATUS         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
 QTY_UOM_REC             QTY_UOM_CSR%ROWTYPE;
 L_TERMINATION_DATE      DATE;
 L_MAX_DATE_BILLED_FROM  DATE;
 L_MAX_DATE_BILLED_TO    DATE;
 l_status_flag           VARCHAR2(1);
 l_line_number           VARCHAR2(500);
 l_contract_number       VARCHAR2(120);

-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 30-MAY-2005
-- local variables for partal periods
-------------------------------------------------------------------------

l_hdr_id              NUMBER;
l_price_uom VARCHAR2(10);
l_period_start VARCHAR2(30);
l_period_type VARCHAR2(10);


BEGIN

  X_return_status := l_return_status;

  l_process_flag  := TRUE;

   OPEN l_hdr_csr(p_line_id);
   FETCH l_hdr_csr into l_hdr_id;
   Close l_hdr_csr;

-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 30-MAY-2005
-- Call oks_renew_util_pub.get_period_defaults to fetch period start and period type
-- 1)For extended warranty , period start will be 'SERVICE'
-------------------------------------------------------------------------
   IF l_hdr_id IS NOT NULL THEN

    OKS_RENEW_UTIL_PUB.Get_Period_Defaults
                (
                 p_hdr_id =>l_hdr_id,
                 p_org_id => NULL,    --p_org_id
                 x_period_start => l_period_start,
                 x_period_type => l_period_type,
                 x_price_uom => l_price_uom,
                 x_return_status => l_return_status);

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Pre_terminate_extwar.ppc_defaults',
    'After calling OKS_RENEW_UTIL_PUB.Get_Period_Defaults l_period_start ' ||l_period_start||' ,l_period_type '||l_period_type);
    END IF;

    IF l_return_status <> 'S' THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

   END IF;
   --mchoudha commented as per CR-001
   --IF l_period_start IS NOT NULL THEN
  --   l_period_start := 'SERVICE';
  -- END IF;
-------------------------------------------------------------------------
-- End partial period computation logic
--------------------------------------------------------------------------


  -- BUG FIX 3438281. Added nvl to take care of contract created from OM.
  -- P_con_termination_amount is null when product is returned in OM
  IF (nvl(p_con_termination_amount,1)  > 0) THEN
    IF (p_cov_line = 'Y') THEN

      OPEN  l_covlvl_csr(p_line_id,p_cov_line);
      FETCH l_covlvl_csr into l_cov_rec;
      CLOSE l_covlvl_csr;

      -- BUG#3312595 mchoudha: Checking for service request
      -- against the subline

     -- Open Service Request Check should not be done for
     -- P_CALLEDFROM = -1. -1 is used for IB Integration
     -- No Other Callers should pass -1 as P_CALLEDFROM

     IF NVL(P_CALLEDFROM, 0) <> -1
     THEN

     OPEN  cur_subline_sr(l_cov_rec.cle_id,l_cov_rec.instance_id);
     FETCH cur_subline_sr into l_status_flag;
     CLOSE cur_subline_sr;

     IF(l_status_flag = 'x') THEN

       OPEN  cur_lineno(p_line_id);
       FETCH cur_lineno into l_line_number,l_contract_number;
       CLOSE cur_lineno;


       OKC_API.set_message(p_app_name      => g_app_name,
                        p_msg_name      => 'OKC_SR_PENDING',
                        p_token1        => 'NUMBER',
                        p_token1_value  => l_contract_number,
                        p_token2        => 'LINENO',
                        p_token2_value  =>  l_line_number);

       l_return_status := okc_api.g_ret_sts_error;
       raise  G_EXCEPTION_HALT_VALIDATION;
     END IF;

     END IF; --FOR P_CALLEDFROM

     -- END BUG#3312595 mchoudha


      l_cov_line_id   := p_line_id;
      l_top_line_id   := l_cov_rec.cle_id;
      --l_max_date_billed_from := l_cov_rec.start_date;
      --l_max_date_billed_to   := l_cov_rec.end_date;


      OPEN  l_extwar_csr(l_cov_rec.cle_id);
      FETCH l_extwar_csr into l_extwar_rec;
      IF (l_extwar_csr%NOTFOUND) THEN
        l_process_flag := FALSE;
      ELSE
        l_max_date_billed_from := l_extwar_rec.start_date;
        l_max_date_billed_to   := l_extwar_rec.end_date;
      END IF;
      CLOSE l_extwar_csr;

      IF p_full_credit = 'Y' then
        l_termination_date := l_cov_rec.start_date ;
      ELSIF p_full_credit = 'N' then
        l_termination_date := p_termination_date ;
      END IF;
    ELSE

      l_top_line_id   :=  p_line_id;
      l_cov_line_id   :=  NULL;

      OPEN  l_extwar_csr(p_line_id);
      FETCH l_extwar_csr into l_extwar_rec;
      IF (l_extwar_csr%NOTFOUND) THEN
        l_process_flag := FALSE;
      ELSE
        l_max_date_billed_from := l_extwar_rec.start_date;
        l_max_date_billed_to   := l_extwar_rec.end_date;
      END IF;
      CLOSE l_extwar_csr;

      IF p_full_credit = 'Y' then
        l_termination_date := l_extwar_rec.start_date ;
      ELSIF p_full_credit = 'N' then
        l_termination_date := p_termination_date ;
      END IF;

    END IF;

    IF (l_process_flag = TRUE) THEN
      IF (trunc(l_termination_date) >  trunc(l_max_date_billed_from)) THEN
          --(trunc(l_termination_date) >  trunc(l_cov_rec.start_date))) THEN
        l_max_date_billed_from :=  l_termination_date;
      END IF;
     -------------------------------------------------------------------------
      -- Begin partial period computation logic
      -- Developer Mani Choudhary
      -- Date 30-MAY-2005
     -------------------------------------------------------------------------
      IF l_period_start is not null AND
         l_period_type is not null
      THEN
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Pre_Terminate_Extwar',
            'calling OKS_BILL_REC_PUB.Terminate_PPC with parameters  P_period_start '||l_period_start||', P_period_type '||l_period_type
            ||' P_override_amount ' ||p_termination_amount||'p_con_terminate_amount '||p_con_termination_amount||' ,P_suppress_credit'||P_suppress_credit);
        END IF;
        OKS_BILL_REC_PUB.Terminate_PPC
               (P_termination_date => l_max_date_billed_from,
                p_end_date         => l_max_date_billed_to,
                P_top_line_id      => l_top_line_id,
                P_cp_line_id       => l_cov_line_id,  --01-APR-2006 mchoudha passing l_cov_line_id
                P_period_start     => l_period_start,
                P_period_type      => l_period_type,
                P_suppress_credit  => p_suppress_credit,
                P_override_amount  => p_termination_amount,
                p_con_terminate_amount => p_con_termination_amount,
                x_return_status    => l_return_status);
        IF  l_return_status <> 'S' THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      ELSE

          Create_trx_records(
                 P_CALLED_FROM           => 2,
                 P_TOP_LINE_ID           => l_top_line_id ,
                 P_COV_LINE_ID           => l_cov_line_id,
                 P_DATE_FROM             => l_max_date_billed_from,
                 P_DATE_TO               => l_max_date_billed_to,
                 P_AMOUNT                => 0,
                 P_OVERRIDE_AMOUNT       => p_termination_amount,
                 P_SUPPRESS_CREDIT       => p_suppress_credit,
                 P_CON_TERMINATE_AMOUNT  => p_con_termination_amount ,
                   --P_EXISTING_CREDIT       => p_existing_credit,
                 P_BILL_ACTION           => 'TR',
                 X_RETURN_STATUS         => l_return_status
                 );
          IF  l_return_status <> 'S' THEN
             RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
      END IF;
    END IF;  -- if  l_process_flag = true
  END IF;  --
EXCEPTION
   WHEN  G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status   :=   l_return_status;
   WHEN  OTHERS THEN
      x_return_status   :=   OKC_API.G_RET_STS_UNEXP_ERROR;
      OKC_API.set_message(G_APP_NAME,G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE,G_SQLERRM_TOKEN, SQLERRM);
END;





--================================================================================
                           --pre_terminate_srvc
--=====================================================================================
 PROCEDURE pre_terminate_srvc
  (
    P_CALLEDFROM                   IN           NUMBER DEFAULT Null,
    p_k_line_id                    IN           NUMBER,
    p_termination_date             IN           DATE,
    p_flag                         IN           NUMBER, -- 1 - regular, 2- simu
    p_termination_amount           IN           NUMBER,
    p_con_termination_amount       IN           NUMBER,
    --p_existing_credit              IN                 NUMBER,
    p_suppress_credit              IN           VARCHAR2,
    p_full_credit                  IN           VARCHAR2,
    x_amount                       OUT NOCOPY   NUMBER,
    X_return_status                OUT NOCOPY   VARCHAR2
  )
  Is

   CURSOR kline_cur IS
           Select  Start_date
                ,End_date
                ,Price_negotiated
                ,Date_terminated
         From   Okc_k_lines_b
         Where  cle_id = p_k_line_id
         And    date_cancelled is null --LLC BUG FIX 4742661
         And    date_terminated IS NULL
         And    lse_id in (7,8,9,10,11,13,35,25);



   Cursor l_date_csr Is
         SELECT  line.Start_date
                ,line.End_date
                ,line.Date_Terminated
                ,line.dnz_chr_id
                ,line.lse_id
                ,hdr.currency_code
         FROM    Okc_k_lines_B  line,
                 okc_k_headers_b hdr
         WHERE   line.Cle_id = p_k_line_id
         AND     line.dnz_chr_id = hdr.id;



  CURSOR l_start_date_csr(p_id in NUMBER ) is
  SELECT start_date,lse_id
    FROM OKC_K_LINES_B
   WHERE id = p_k_line_id;


   CURSOR  l_hdr_csr(p_id in NUMBER ) is
  SELECT dnz_chr_id
    FROM OKC_K_LINES_B
   WHERE id = p_id;

  --mchoudha 10-FEB
  Cursor l_usage_csr(p_id in NUMBER) is
   SELECT usage_type
   FROM oks_k_lines_b
   WHERE cle_id = p_id ;

  l_start_date_rec  l_start_date_csr%ROWTYPE;

  l_date_rec l_date_csr%rowtype;

  kline_rec  kline_cur%ROWTYPE;

  SUBTYPE l_bclv_tbl_type_in  is OKS_bcl_PVT.bclv_tbl_type;
  l_bclv_tbl_in   l_bclv_tbl_type_in;
  l_bclv_tbl_out  l_bclv_tbl_type_in;

  l_return_status    Varchar2(20);
  l_msg_cnt     Number;
  l_msg_data    Varchar2(2000);
   l_billed_amount          NUMBER ;
   l_term_amount            NUMBER ;
   l_term_amount_temp       NUMBER ;
   l_termination_date       DATE;

   -----------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 30-MAY-2005
-- local variables for partal periods
-------------------------------------------------------------------------
l_hdr_id              NUMBER;
l_price_uom           OKS_K_HEADERS_B.PRICE_UOM%TYPE;
l_period_start        OKS_K_HEADERS_B.PERIOD_START%TYPE;
l_period_type         OKS_K_HEADERS_B.PERIOD_TYPE%TYPE;
l_usage_type          VARCHAR2(10);
--------------------------------------------------------------------------

 BEGIN


   x_return_status := OKC_API.G_RET_STS_SUCCESS;
   x_amount        := 0;

   OPEN l_hdr_csr(p_k_line_id);
   FETCH l_hdr_csr into l_hdr_id;
   Close l_hdr_csr;

-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 30-MAY-2005
-- Call oks_renew_util_pub.get_period_defaults to fetch period start and period type
-------------------------------------------------------------------------
   IF l_hdr_id IS NOT NULL THEN

      OKS_RENEW_UTIL_PUB.Get_Period_Defaults
                (
                 p_hdr_id        => l_hdr_id,
                 p_org_id        => NULL,
                 x_period_start  => l_period_start,
                 x_period_type   => l_period_type,
                 x_price_uom     => l_price_uom,
                 x_return_status => l_return_status);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.pre_terminate_srvc.ppc_defaults',
         'After calling OKS_RENEW_UTIL_PUB.Get_Period_Defaults l_period_start ' ||l_period_start||' ,l_period_type '||l_period_type);
      END IF;

      IF l_return_status <> 'S' THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

   END IF;
-------------------------------------------------------------------------
-- End partial period computation logic
-------------------------------------------------------------------------
   IF (p_flag = 2) THEN

     --errorout('SERVICE :- SIMULATION  ');


     SELECT nvl(sum(nvl(amount,0)),0)
      INTO l_billed_amount
      FROM oks_bill_cont_lines
      WHERE cle_id = p_k_line_id
      GROUP by cle_id;

     FOR kline_rec IN kline_cur
     LOOP
        get_bill_amount_period(
                             -99,
                             kline_rec.start_date,
                             kline_rec.end_date,
                             Null,
                             kline_rec.PRICE_NEGOTIATED,
                             kline_rec.start_date,
                             kline_rec.DATE_TERMINATED,
                             G_NONREGULAR,
                             l_term_amount_temp);
        l_term_amount := nvl(l_term_amount,0) + nvl(l_term_amount_temp,0);
     END LOOP;
     x_amount := nvl(l_term_amount,0) - nvl(l_billed_amount,0);
   ELSE
     IF p_full_credit = 'Y' then
        OPEN  l_start_date_csr(p_k_line_id);
        FETCH l_start_date_csr into l_start_date_rec;
        CLOSE l_start_date_csr;
        l_termination_date := l_start_date_rec.start_date;
     ELSIF p_full_credit = 'N' then
        l_termination_date := p_termination_date;
     END IF;

     OPEN  l_date_csr;
     FETCH l_date_csr into l_date_rec;
     CLOSE l_date_csr;
     -------------------------------------------------------------------------
      -- Begin partial period computation logic
      -- Developer Mani Choudhary
      -- Date 30-MAY-2005
     -------------------------------------------------------------------------

     OPEN  l_usage_csr(p_k_line_id);
     FETCH l_usage_csr into l_usage_type;
     CLOSE l_usage_csr;

     IF l_period_start IS NOT NULL AND
        l_period_type IS NOT NULL  AND
        p_termination_amount  is NULL --- Bug# 5005401 Overiding the credit amount must overide PPC
     THEN
        IF l_date_rec.lse_id <> 13 OR nvl(l_usage_type,'XYZ') = 'NPR' THEN
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Pre_Terminate_srvc.Service',
             'calling OKS_BILL_REC_PUB.Terminate_PPC with parameters  l_period_start '||l_period_start||', l_period_type '||l_period_type
             ||' P_override_amount ' ||p_termination_amount||'p_con_terminate_amount '||p_con_termination_amount||' ,P_suppress_credit'||P_suppress_credit);
          END IF;

          OKS_BILL_REC_PUB.Terminate_PPC
               (P_termination_date => l_termination_date,
                p_end_date         => l_date_rec.end_date,
                P_top_line_id      => p_k_line_id,
                P_cp_line_id       => NULL,
                P_period_start     => l_period_start,
                P_period_type      => l_period_type,
                P_suppress_credit  => p_suppress_credit,
                P_override_amount  => p_termination_amount,
                p_con_terminate_amount => p_con_termination_amount,
                x_return_status    => l_return_status);

          IF l_return_status <> 'S' THEN
             RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
        ELSE
          --For usage , period start should be SERVICE
          -- and amount based termination will be based on billing not on price uom
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Pre_Terminate_srvc.Usage',
             'calling OKS_BILL_REC_PUB.Create_trx_records with parameters  l_period_start '||l_period_start||', l_period_type '||l_period_type
             ||' P_override_amount ' ||p_termination_amount||'p_con_terminate_amount '||p_con_termination_amount||' ,P_suppress_credit'||P_suppress_credit);
          END IF;

          l_period_start := 'SERVICE';
          Create_trx_records(
                P_CALLED_FROM          => 1 ,
                P_TOP_LINE_ID          => p_k_line_id,
                P_COV_LINE_ID          => null,
                P_DATE_FROM            => l_termination_date,
                P_DATE_TO              => l_date_rec.end_date,
                P_AMOUNT               => 0,
                P_OVERRIDE_AMOUNT      => p_termination_amount,
                P_SUPPRESS_CREDIT      => p_suppress_credit,
                P_CON_TERMINATE_AMOUNT => p_con_termination_amount,
                --P_EXISTING_CREDIT      => p_existing_credit,
                P_BILL_ACTION          => 'TR',
                P_PERIOD_START         => l_period_start,
                P_PERIOD_TYPE          => l_period_type,
                X_RETURN_STATUS        => l_return_status
                );
          IF l_return_status <> 'S' THEN
             RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
        END IF;
     ELSE
       Create_trx_records(
          P_CALLED_FROM          => 1 ,
          P_TOP_LINE_ID          => p_k_line_id,
          P_COV_LINE_ID          => null,
          P_DATE_FROM            => l_termination_date,
          P_DATE_TO              => l_date_rec.end_date,
          P_AMOUNT               => 0,
          P_OVERRIDE_AMOUNT      => p_termination_amount,
          P_SUPPRESS_CREDIT      => p_suppress_credit,
          P_CON_TERMINATE_AMOUNT => p_con_termination_amount,
          --P_EXISTING_CREDIT      => p_existing_credit,
          P_BILL_ACTION          => 'TR',
          X_RETURN_STATUS        => l_return_status
          );
          IF l_return_status <> 'S' THEN
             RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
     END IF;
   END IF;
EXCEPTION
  WHEN  G_EXCEPTION_HALT_VALIDATION THEN
    x_return_status   :=   l_return_status;
  WHEN  OTHERS THEN
    x_return_status   :=   OKC_API.G_RET_STS_UNEXP_ERROR;
    OKC_API.set_message(G_APP_NAME,G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE,G_SQLERRM_TOKEN, SQLERRM);

END pre_terminate_srvc;

PROCEDURE terminate_subscribtion_line
  (
    P_CALLEDFROM                   IN         NUMBER DEFAULT NULL,
    p_api_version                  IN         NUMBER,
    p_init_msg_list                IN         VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_line_id                      IN         NUMBER,
    p_termination_date             IN         DATE,
    p_termination_amount           IN         NUMBER DEFAULT NULL,
    p_con_termination_amount       IN         NUMBER DEFAULT NULL,
    p_billed_amount                IN         NUMBER,
    p_shipped_amount               IN         NUMBER,
    p_next_ship_date               IN         DATE,
    --p_existing_credit              IN         NUMBER,
    p_suppress_credit              IN         VARCHAR2 DEFAULT 'N',
    p_tang                         IN         BOOLEAN ,
    p_full_credit                  IN         VARCHAR2
  )  IS

 l_elems_tbl_del_in OKS_SUBSCR_ELEMS_PVT.scev_tbl_type;

 CURSOR del_fulfillment_schedule(p_id in number) is
  SELECT id from oks_subscr_elements
   where dnz_cle_id = p_id
   and   order_header_id is null
   and   start_date >= p_termination_date;

 CURSOR billed_cur (p_id in number,l_termination_date in DATE,
                                   l_next_ship_date in DATE) is
 SELECT * from oks_bill_cont_lines
  WHERE cle_id = p_id
    AND bill_action = 'RI'
    --AND date_billed_to >= l_termination_date
  ORDER BY DATE_BILLED_FROM DESC;

/*************************************************************
 CURSOR billed_cur (p_id in number,l_termination_date in DATE,
                                   l_next_ship_date in DATE) is
 SELECT * from oks_bill_cont_lines
  WHERE cle_id = p_id
    AND bill_action = 'RI'
    AND (( date_billed_from >= l_termination_date
    AND    date_billed_to >= nvl(l_next_ship_date,date_billed_to))
        OR
        (l_termination_date between date_billed_from and date_billed_to
    AND nvl(l_next_ship_date,date_billed_from) between date_billed_from and date_billed_to))
  ORDER BY DATE_BILLED_FROM DESC;
**************************************************************/

 Cursor bsl_cur (p_id in number) is
 SELECT bsl.*
 FROM oks_bill_sub_lines bsl
 WHERE bsl.bcl_id = p_id;

 Cursor bsd_cur (p_id in number) is
 Select * from oks_bill_sub_line_dtls
 where   bsl_id = p_id;


 Cursor check_bcl(p_id in Number,
                  p_date_billed_from IN Date,
                  p_date_billed_to In Date) is
      Select id
      from oks_bill_cont_lines
      where cle_id = p_id
      and   bill_Action = 'TR'
      and   trunc(date_billed_from) = trunc(p_date_billed_from)
      and   trunc(date_billed_to )  = trunc(p_date_billed_to);

 Cursor fullfilled_subscr_amount(p_id IN NUMBER) is
 Select nvl(sum(nvl(amount,0)),0)
 From oks_subscr_elements
 Where dnz_cle_id = p_id
 and start_date <= p_termination_date;

 Cursor bill_amount_cur(p_line_id in number,p_term_date in DATE) is
 Select nvl(sum(amount),0) from oks_bill_cont_lines
   Where cle_id = p_line_id
   and   bill_action = 'RI'
   and   trunc(date_billed_From) <= trunc(p_term_date);

 Cursor ship_amount_cur(p_line_id in number,p_term_date in DATE) is
 Select nvl(sum(amount),0) from oks_subscr_elements
   Where dnz_cle_id = p_line_id;
   --and   trunc(start_date) < trunc(p_term_date);

 Cursor l_get_bcl_count(l_termination_date in date, l_next_ship_date in date, l_line_id in NUMBER ) is
 select count(*)
  from oks_bill_cont_lines
 where cle_id = l_line_id
   and trunc(date_billed_to) >=  trunc(l_next_ship_date)
   and trunc(date_billed_to) >=  trunc(l_termination_date);

 CURSOR l_lines_csr( p_id NUMBER ) is
 SELECT start_date
   FROM okc_k_lines_b
  WHERE id = p_id ;

 SUBTYPE l_bclv_tbl_type_in  is OKS_bcl_PVT.bclv_tbl_type;
  l_bclv_tbl_in   l_bclv_tbl_type_in;
  l_bclv_tbl_out  l_bclv_tbl_type_in;

 SUBTYPE l_bslv_tbl_type_in  is OKS_bsl_PVT.bslv_tbl_type;
  l_bslv_tbl_in   l_bslv_tbl_type_in;
  l_bslv_tbl_out  l_bslv_tbl_type_in;

 SUBTYPE l_bsdv_tbl_type_in  is OKS_bsd_PVT.bsdv_tbl_type;
  l_bsdv_tbl_in   l_bsdv_tbl_type_in;
  l_bsdv_tbl_out  l_bsdv_tbl_type_in;

--  Bug Fix 5062595 maanand --

  Cursor l_get_bcl_count_intang(l_termination_date in date, l_line_id in NUMBER ) is
  select count(*)
  from oks_bill_cont_lines
  where cle_id = l_line_id
  and trunc(date_billed_to) >=  trunc(l_termination_date);

--  End Bug Fix 5062595 --

--  Bug Fix 5236358  Hari --

Cursor bill_instance_csr (p_bcl_id in NUMBER) is
       SELECT txn.bill_instance_number from oks_bill_txn_lines txn
       WHERE bcl_id = p_bcl_id;


 i                     NUMBER;
 l_id                  NUMBER;
 l_sum_billed_amount   NUMBER;
 l_sum_ship_amount     NUMBER;
 l_quantity            NUMBER;
 l_round_amount        NUMBER;
 l_amount              NUMBER;
 l_return_status       VARCHAR2(1);
 l_msg_count           NUMBER;
 l_msg_data            VARCHAR2(2000):=null;
 l_ship_amount         NUMBER;
 l_bill_amount         NUMBER;
 l_termination_date    DATE;
 l_next_ship_date      DATE;
 l_lines_rec           l_lines_csr%ROWTYPE;
 l_termination_amount  number;
 l_con_termination_amount number ;
 l_bcl_count           number;
 l_amount_per_period   number;

 NEGATIVE_TERM_AMOUNT  EXCEPTION;

 BEGIN
   IF p_full_credit = 'Y' then
     OPEN l_lines_csr(p_line_id);
     FETCH l_lines_csr into l_lines_rec;
     CLOSE l_lines_csr;
     l_termination_date := l_lines_rec.start_date;
     l_next_ship_date   := l_lines_rec.start_date;
   ELSE
     l_termination_date := p_termination_date;
     l_next_ship_date   := p_next_ship_date;
   END IF;

   IF (p_shipped_amount >= p_billed_amount  and p_full_credit <> 'Y' ) THEN

    ---Changed for bug#3514292
    --if p_tang is false then ship amount is always 0 and if it is not at billed then billed amt is
    ---also 0. so p_tang condition moved inside if.

       IF p_tang THEN
         OKS_SUBSCRIPTION_PUB.recreate_schedule
         ( p_api_version     => 1.0,
           p_init_msg_list   => 'T',
           x_return_status   => l_return_status,
           x_msg_count       => l_msg_count,
           x_msg_data        => l_msg_data,
           p_cle_id          => p_line_id,
           p_intent          => NULL,
           x_quantity        => l_quantity );
       END IF;

       OKS_BILL_SCH.Create_Subcription_bs
         ( p_top_line_id     => p_line_id,
           p_full_credit     => p_full_credit,
           x_return_status   => l_return_status,
           x_msg_count       => l_msg_count,
           x_msg_data        => l_msg_data);
   ELSE
      IF p_tang  then
         OKS_SUBSCRIPTION_PUB.recreate_schedule
            (p_api_version     => 1.0,
             p_init_msg_list   => 'T',
             x_return_status   => l_return_status,
             x_msg_count       => l_msg_count,
             x_msg_data        => l_msg_data,
             p_cle_id          => p_line_id,
             p_intent          => NULL,
             x_quantity        => l_quantity );
      END IF;
      OKS_BILL_SCH.Create_Subcription_bs
          ( p_top_line_id     => p_line_id,
            p_full_credit     => p_full_credit,
            x_return_status   => l_return_status,
            x_msg_count       => l_msg_count,
            x_msg_data        => l_msg_data);

      l_termination_amount     := p_termination_amount;

      OKS_BILL_REC_PUB.Pre_Terminate_Amount
       ( p_id             => p_line_id,
         p_terminate_date => l_termination_date,
         p_flag           => 1,
         X_Amount         => l_con_termination_amount,
         X_return_status  => l_return_status);

      If p_termination_amount is not null then
         l_con_termination_amount := l_con_termination_amount*(nvl(p_termination_amount,p_con_termination_amount)/p_con_termination_amount);
      End If;

      If l_termination_amount is not null then

         --  Bug Fix 5062595 maanand --
         IF p_tang  then
                 Open  l_get_bcl_count(l_termination_date , l_next_ship_date , p_line_id );
                 Fetch l_get_bcl_count into l_bcl_count;
                 close l_get_bcl_count ;
        ELSE
                 Open  l_get_bcl_count_intang(l_termination_date , p_line_id );
                 Fetch l_get_bcl_count_intang into l_bcl_count;
                 close l_get_bcl_count_intang ;
        END IF;
        --  End Bug Fix 5062595 --

         If (l_bcl_count = 0 or l_bcl_count is null ) then
            l_bcl_count := 1 ;
         end If;
         l_amount_per_period := l_con_termination_amount /l_bcl_count;

      End If;

      <<A>>
      FOR bcl_rec in billed_cur(p_line_id,l_termination_date,l_next_ship_date )
      LOOP
      BEGIN
        EXIT A WHEN (l_termination_amount <= 0 OR l_con_termination_amount <= 0  and p_full_credit <> 'Y' );
        DBMS_TRANSACTION.SAVEPOINT('BEFORE_TRANSACTION');
        l_bclv_tbl_in.delete;
        l_bclv_tbl_out.delete;
        l_bslv_tbl_in.delete;
        l_bslv_tbl_out.delete;
        l_bsdv_tbl_in.delete;
        l_bsdv_tbl_out.delete;
        OPEN check_bcl(bcl_rec.cle_id,
                       bcl_rec.date_billed_From,
                       bcl_rec.date_billed_to);
        FETCH check_bcl into l_id;
        IF (check_bcl%NOTFOUND) THEN
            --OPEN fullfilled_subscr_amount(bcl_rec.cle_id);
            --FETCH fullfilled_subscr_amount into l_sum_ship_amount;
            --CLOSE fullfilled_subscr_amount;

            l_bclv_tbl_in(1).CLE_ID             := bcl_rec.cle_id;
            l_bclv_tbl_in(1).BTN_ID             := Null;
            l_bclv_tbl_in(1).SENT_YN            :=  'N';
          --l_bclv_tbl_in(1).DATE_BILLED_FROM   := bcl_rec.date_billed_from;

            --bug#5245918 is Forward port fix for bug#5245719 (bug#5245719 is fix for bug#5239335)
            IF p_termination_date >= bcl_rec.date_billed_from and  p_termination_date <= bcl_rec.date_billed_to and not(p_tang) THEN
                l_bclv_tbl_in(1).DATE_BILLED_FROM   := p_termination_date;
            ELSE
                l_bclv_tbl_in(1).DATE_BILLED_FROM   := bcl_rec.date_billed_from;
           END IF;

            l_bclv_tbl_in(1).DATE_BILLED_TO     := bcl_rec.date_billed_to;
            l_bclv_tbl_in(1).DATE_NEXT_INVOICE  := bcl_rec.date_next_invoice;
            l_bclv_tbl_in(1).ATTRIBUTE_CATEGORY := bcl_rec.attribute_category;
            l_bclv_tbl_in(1).ATTRIBUTE1         := bcl_rec.attribute1;
            l_bclv_tbl_in(1).ATTRIBUTE2         := bcl_rec.attribute2;
            l_bclv_tbl_in(1).ATTRIBUTE3         := bcl_rec.attribute3;
            l_bclv_tbl_in(1).ATTRIBUTE4         := bcl_rec.attribute4;
            l_bclv_tbl_in(1).ATTRIBUTE5         := bcl_rec.attribute5;
            l_bclv_tbl_in(1).ATTRIBUTE6         := bcl_rec.attribute6;
            l_bclv_tbl_in(1).ATTRIBUTE7         := bcl_rec.attribute7;
            l_bclv_tbl_in(1).ATTRIBUTE8         := bcl_rec.attribute8;
            l_bclv_tbl_in(1).ATTRIBUTE9         := bcl_rec.attribute9;
            l_bclv_tbl_in(1).ATTRIBUTE10        := bcl_rec.attribute10;
            l_bclv_tbl_in(1).ATTRIBUTE11        := bcl_rec.attribute11;
            l_bclv_tbl_in(1).ATTRIBUTE12        := bcl_rec.attribute12;
            l_bclv_tbl_in(1).ATTRIBUTE13        := bcl_rec.attribute13;
            l_bclv_tbl_in(1).ATTRIBUTE14        := bcl_rec.attribute14;
            l_bclv_tbl_in(1).ATTRIBUTE15        := bcl_rec.attribute15;
            l_bclv_tbl_in(1).BILL_ACTION        := G_BILLACTION_TR;
            l_bclv_tbl_in(1).CURRENCY_CODE      := bcl_rec.currency_code;
            l_bclv_tbl_in(1).AMOUNT             :=  0;
            IF (nvl(p_suppress_credit,'N') = 'Y') THEN
               l_bclv_tbl_in(1).BTN_ID          := -44;
            END IF;
            OKS_BILLCONTLINE_PUB.insert_Bill_Cont_Line
                 ( p_api_version                => 1.0,
                   p_init_msg_list              => 'T',
                   x_return_status              => l_return_status,
                   x_msg_count                  => l_msg_count,
                   x_msg_data                   => l_msg_data,
                   p_bclv_tbl                   => l_bclv_tbl_in,
                   x_bclv_tbl                   => l_bclv_tbl_out);

           l_bclv_tbl_in(1).id      :=  l_bclv_tbl_out(1).id;
           l_bclv_tbl_in(1).amount  :=  l_bclv_tbl_out(1).amount;
           l_round_amount := 0;

           FOR bsl_rec in bsl_cur(bcl_rec.id)
           LOOP
              l_bslv_tbl_in(1).BCL_ID  := l_bclv_tbl_out(1).id;
              l_bslv_tbl_in(1).CLE_ID := bsl_rec.cle_id;
              l_bslv_tbl_in(1).AVERAGE := bsl_rec.average;
            --l_bslv_tbl_in(1).DATE_BILLED_FROM := bsl_rec.date_billed_from;

            --bug#5245918 is Forward port fix for bug#5245719 (bug#5245719 is fix for bug#5239335)
            IF p_termination_date >= bsl_rec.date_billed_from and  p_termination_date <= bsl_rec.date_billed_to and not(p_tang) THEN
                l_bslv_tbl_in(1).DATE_BILLED_FROM   := p_termination_date;
             ELSE
                l_bslv_tbl_in(1).DATE_BILLED_FROM   := bsl_rec.date_billed_from;
            END IF;

              l_bslv_tbl_in(1).DATE_BILLED_TO := bsl_rec.date_billed_to;
              l_bslv_tbl_in(1).ATTRIBUTE_CATEGORY :=bsl_rec.attribute_category;
              l_bslv_tbl_in(1).ATTRIBUTE1 := bsl_rec.attribute1;
              l_bslv_tbl_in(1).ATTRIBUTE2 := bsl_rec.attribute2;
              l_bslv_tbl_in(1).ATTRIBUTE3 := bsl_rec.attribute3;
              l_bslv_tbl_in(1).ATTRIBUTE4 := bsl_rec.attribute4;
              l_bslv_tbl_in(1).ATTRIBUTE5 := bsl_rec.attribute5;
              l_bslv_tbl_in(1).ATTRIBUTE6 := bsl_rec.attribute6;
              l_bslv_tbl_in(1).ATTRIBUTE7 := bsl_rec.attribute7;
              l_bslv_tbl_in(1).ATTRIBUTE8 := bsl_rec.attribute8;
              l_bslv_tbl_in(1).ATTRIBUTE9 := bsl_rec.attribute9;
              l_bslv_tbl_in(1).ATTRIBUTE10 := bsl_rec.attribute10;
              l_bslv_tbl_in(1).ATTRIBUTE11 := bsl_rec.attribute11;
              l_bslv_tbl_in(1).ATTRIBUTE12 := bsl_rec.attribute12;
              l_bslv_tbl_in(1).ATTRIBUTE13 := bsl_rec.attribute13;
              l_bslv_tbl_in(1).ATTRIBUTE14 := bsl_rec.attribute14;
              l_bslv_tbl_in(1).ATTRIBUTE15 := bsl_rec.attribute15;
              l_bslv_tbl_in(1).date_to_interface :=
              get_term_end_date (bsl_rec.cle_id , p_termination_date );

   If p_full_credit = 'Y' then
      If p_termination_amount is null then
         l_bslv_tbl_in(1).AMOUNT   :=  -1* bsl_rec.amount;
         l_amount                  := l_bslv_tbl_in(1).AMOUNT;
      Else
         --l_amount := p_termination_amount *(bsl_rec.amount/p_con_termination_amount);
         l_amount :=  l_amount_per_period;
         l_amount :=  OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_amount, bcl_rec.currency_code);
         l_round_amount := l_round_amount + l_amount ;
         l_bslv_tbl_in(1).AMOUNT   :=  -1* l_amount;
         l_amount                  := l_bslv_tbl_in(1).AMOUNT;
      End If;
   Else
      If p_termination_amount is null then
         If (l_con_termination_amount - bsl_rec.amount ) < 0 then
            If l_con_termination_amount < 0 then
               l_bslv_tbl_in(1).AMOUNT   := 0;
            Else
               l_bslv_tbl_in(1).AMOUNT   := -1*l_con_termination_amount ;
            End If;
            l_con_termination_amount  := l_con_termination_amount - l_con_termination_amount;
            l_amount := l_bslv_tbl_in(1).AMOUNT;
         Else
            l_bslv_tbl_in(1).AMOUNT   := -1 * bsl_rec.amount ;
            l_con_termination_amount  := l_con_termination_amount - bsl_rec.amount;
            l_amount := l_bslv_tbl_in(1).AMOUNT;
         End If;
      Else
         --l_amount :=  p_termination_amount *(bsl_rec.amount/p_con_termination_amount);
         l_amount :=  l_amount_per_period;
         l_amount :=  OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_amount, bcl_rec.currency_code);
         --l_termination_amount := l_termination_amount - l_amount ;
         l_con_termination_amount := l_con_termination_amount - l_amount ;
         l_round_amount := l_round_amount + l_amount ;
         l_bslv_tbl_in(1).AMOUNT   :=  -1* l_amount;
         l_amount                  := l_bslv_tbl_in(1).AMOUNT;
      End If;
   End If;

/****************************************************************************************************************
              IF ((l_termination_date between bcl_rec.date_billed_From and bcl_rec.date_billed_to)
                 AND (l_next_ship_date  between bcl_rec.date_billed_From and bcl_rec.date_billed_to)
                      AND p_full_credit <> 'Y')  THEN
                      IF (p_termination_amount is NULL) THEN
                          OPEN  bill_amount_cur( p_line_id,l_termination_date);
                          FETCH bill_amount_cur into l_bill_amount;
                          CLOSE bill_amount_cur;

                          OPEN  ship_amount_cur( p_line_id,l_termination_date);
                          FETCH ship_amount_cur into l_ship_amount;
                          CLOSE ship_amount_cur;

                         l_amount  := OKS_EXTWAR_UTIL_PVT.round_currency_amt( l_bill_amount - l_ship_amount,
                                                                              bcl_rec.currency_code) ;
                         l_round_amount :=  l_round_amount +  l_amount;
                         l_bslv_tbl_in(1).AMOUNT   :=  -1* l_amount ;
                      ELSE
                         l_amount := OKS_EXTWAR_UTIL_PVT.round_currency_amt(( p_termination_amount *
                                                                              bsl_rec.amount  ) / p_con_termination_amount  ,
                                                                               bcl_rec.currency_code);
                         l_round_amount :=  l_round_amount +  l_amount;
                         l_bslv_tbl_in(1).AMOUNT   :=  -1* l_amount ;
                     END IF;
             ELSE
                     IF (p_termination_amount is NULL) THEN
                        l_amount  := OKS_EXTWAR_UTIL_PVT.round_currency_amt(( bsl_rec.amount -
                                                                    OKS_SUBSCRIPTION_PUB.subs_termn_amount
                                                                    ( p_cle_id     =>p_line_id ,
                                                                      p_termn_date =>p_termination_date )),
                                                                      bcl_rec.currency_code) ;
                        l_round_amount :=  l_round_amount +  l_amount;
                        l_bslv_tbl_in(1).AMOUNT   :=  -1* l_amount ;
                     ELSE
                        l_amount:= OKS_EXTWAR_UTIL_PVT.round_currency_amt
                                   ((p_termination_amount *(( bsl_rec.amount - OKS_SUBSCRIPTION_PUB.subs_termn_amount
                                                                                           ( p_cle_id     =>p_line_id ,
                                                                                             p_termn_date =>p_termination_date ))
                                                                                             ))/
                                                                                             p_con_termination_amount  ,
                                                                                             bcl_rec.currency_code) ;
                        l_round_amount :=  l_round_amount +  l_amount;
                        l_bslv_tbl_in(1).AMOUNT   :=  -1* l_amount ;
                     END IF;

                     IF ( l_AMOUNT  <= 0) THEN
                          DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
                          RAISE NEGATIVE_TERM_AMOUNT;
                     END IF;
             END IF;
***********************************************************************************************************************/


      /*Average field is used to store bill_instance_number
        of the parent. It is used to populate referenc_line_id in
        AR Feeder
      */
      OPEN  bill_instance_csr(bcl_rec.id);
      FETCH bill_instance_csr into l_bslv_tbl_in(1).AVERAGE;
      CLOSE bill_instance_csr;

         OKS_BILLSUBLINE_PUB.insert_Bill_subLine_Pub
               (
               p_api_version                  =>  1.0,
               p_init_msg_list                =>  'T',
               x_return_status                =>   l_return_status,
               x_msg_count                    =>   l_msg_count,
               x_msg_data                     =>   l_msg_data,
               p_bslv_tbl                     =>   l_bslv_tbl_in,
               x_bslv_tbl                     =>   l_bslv_tbl_out
               );

         IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS)  THEN
           x_return_status := l_return_status;
           Raise G_EXCEPTION_HALT_VALIDATION;
         END IF;
         g_credit_amount := nvl(g_credit_amount,0) + (-1*l_amount);
         g_bsl_id := l_bslv_tbl_out(1).id;
         g_bcl_id := l_bslv_tbl_in(1).BCL_ID;


         FOR bsd_rec in bsd_cur(bsl_rec.id)
         LOOP
           l_bsdv_tbl_in(1).BSL_ID              := l_bslv_tbl_out(1).id;
           l_bsdv_tbl_in(1).BSL_ID_AVERAGED     := bsd_rec.bsl_id_averaged;
           l_bsdv_tbl_in(1).BSD_ID              := bsd_rec.bsd_id;
           l_bsdv_tbl_in(1).BSD_ID_APPLIED      := bsd_rec.bsd_id_applied;
           l_bsdv_tbl_in(1).UNIT_OF_MEASURE     := bsd_rec.unit_of_measure;
           l_bsdv_tbl_in(1).FIXED               := bsd_rec.fixed;
           l_bsdv_tbl_in(1).ACTUAL              := bsd_rec.actual;
           l_bsdv_tbl_in(1).DEFAULT_DEFAULT     := bsd_rec.default_default;
           l_bsdv_tbl_in(1).AMCV_YN             := bsd_rec.amcv_yn;
           l_bsdv_tbl_in(1).ADJUSTMENT_LEVEL    := bsd_rec.adjustment_level;
           l_bsdv_tbl_in(1).ADJUSTMENT_MINIMUM  := bsd_rec.adjustment_minimum;
           l_bsdv_tbl_in(1).RESULT              := bsd_rec.result;
           l_bsdv_tbl_in(1).ATTRIBUTE_CATEGORY  := bsd_rec.attribute_category;
           l_bsdv_tbl_in(1).ATTRIBUTE1          := bsd_rec.attribute1;
           l_bsdv_tbl_in(1).ATTRIBUTE2          := bsd_rec.attribute2;
           l_bsdv_tbl_in(1).ATTRIBUTE3          := bsd_rec.attribute3;
           l_bsdv_tbl_in(1).ATTRIBUTE4          := bsd_rec.attribute4;
           l_bsdv_tbl_in(1).ATTRIBUTE5          := bsd_rec.attribute5;
           l_bsdv_tbl_in(1).ATTRIBUTE6          := bsd_rec.attribute6;
           l_bsdv_tbl_in(1).ATTRIBUTE7          := bsd_rec.attribute7;
           l_bsdv_tbl_in(1).ATTRIBUTE8          := bsd_rec.attribute8;
           l_bsdv_tbl_in(1).ATTRIBUTE9          := bsd_rec.attribute9;
           l_bsdv_tbl_in(1).ATTRIBUTE10         := bsd_rec.attribute10;
           l_bsdv_tbl_in(1).ATTRIBUTE11         := bsd_rec.attribute11;
           l_bsdv_tbl_in(1).ATTRIBUTE12         := bsd_rec.attribute12;
           l_bsdv_tbl_in(1).ATTRIBUTE13         := bsd_rec.attribute13;
           l_bsdv_tbl_in(1).ATTRIBUTE14         := bsd_rec.attribute14;
           l_bsdv_tbl_in(1).ATTRIBUTE15         := bsd_rec.attribute15;
           l_bsdv_tbl_in(1).AMOUNT              := l_amount;

           OKS_BSL_det_PUB.insert_bsl_det_Pub
                  (
                     p_api_version                  =>  1.0,
                     p_init_msg_list                =>  'T',
                     x_return_status                =>   l_return_status,
                     x_msg_count                    =>   l_msg_count,
                     x_msg_data                     =>   l_msg_data,
                     p_bsdv_tbl                     =>   l_bsdv_tbl_in,
                     x_bsdv_tbl                     =>   l_bsdv_tbl_out
                  );


           IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             x_return_status := l_return_status;
             Raise G_EXCEPTION_HALT_VALIDATION;
           END IF;


         END LOOP;

       END LOOP;

       --l_bclv_tbl_in(1).AMOUNT :=  -1 * nvl(l_round_amount,0);
       l_bclv_tbl_in(1).AMOUNT :=  l_amount ;

       UPDATE oks_bill_cont_lines
             SET amount = l_bclv_tbl_in(1).AMOUNT
             WHERE  id  = l_bclv_tbl_in(1).id;


     END IF;  --check_bcl

     CLOSE check_bcl;

   EXCEPTION
     WHEN NEGATIVE_TERM_AMOUNT THEN
       NULL;
   END;
   END LOOP;
 END IF;
END terminate_subscribtion_line;



PROCEDURE pre_terminate
  (P_CALLEDFROM                   IN         NUMBER DEFAULT Null,
   x_return_status                OUT NOCOPY VARCHAR2,
   p_terminate_tbl                IN         TERMINATE_TBL
   ) IS
 BEGIN
   FOR i in 1..p_terminate_tbl.count
    LOOP
       pre_terminate
        (P_CALLEDFROM               => P_CALLEDFROM    ,
        x_return_status             => x_return_status,
        p_id                        => p_terminate_tbl(i).p_id,
        p_termination_date          => p_terminate_tbl(i).p_termination_date,
        p_termination_amount        => p_terminate_tbl(i).p_termination_amount,
        p_con_termination_amount    => p_terminate_tbl(i).p_con_termination_amount,
        p_reason_code               => p_terminate_tbl(i).p_reason_code ,
        p_flag                      => p_terminate_tbl(i).p_flag,
        p_termination_flag          => p_terminate_tbl(i).p_termination_flag,
        p_suppress_credit           => p_terminate_tbl(i).p_suppress_credit,
        p_full_credit               => p_terminate_tbl(i).p_full_credit,
        P_Term_Date_flag            => p_terminate_tbl(i).P_Term_Date_flag,
        P_Term_Cancel_source        => p_terminate_tbl(i).P_Term_Cancel_source
        );

    END LOOP;
 END;

PROCEDURE pre_terminate
(P_CALLEDFROM                   IN            NUMBER   DEFAULT Null,
 x_return_status                OUT NOCOPY    VARCHAR2,
 p_id                           IN            NUMBER,
 p_termination_date             IN            DATE,
 p_termination_amount           IN            NUMBER   ,-- user input for termination
 p_con_termination_amount       IN            NUMBER   DEFAULT NULL,-- actual value to be terminated
 p_reason_code                  IN            VARCHAR2 DEFAULT NULL,
 p_flag                         IN            NUMBER   DEFAULT NULL,
 p_termination_flag             IN            NUMBER   DEFAULT 1,
 p_suppress_credit              IN            VARCHAR2 DEFAULT 'N',
 p_full_credit                  IN            VARCHAR2,
P_Term_Date_flag   IN varchar2 default 'N',
P_Term_Cancel_source in Varchar2 default NULL
)
IS
/*******************Modified this cursor as below for BUG # 3029249 ***
Cursor line_cur(p_hdr_id IN NUMBER) is
  SELECT id,
         lse_id
  FROM okc_k_lines_b
  WHERE dnz_chr_id = p_hdr_id
  AND   cle_id is null
  AND   date_terminated is null --Sts_cd can be active for future terminate
  AND   sts_code in ('ACTIVE','SIGNED');
*******************Modified this cursor as below for BUG # 3029249 ***/

Cursor line_cur(p_hdr_id IN NUMBER) is
SELECT lines.id,
       lines.lse_id,
       /* Start Addition for bug fix 6012384 (FP for 5469820) */
       lines.end_date
       /* End Addition for bug fix 6012384 (FP for 5469820) */
  FROM okc_k_lines_b lines,
       okc_k_headers_b  hdr
 WHERE hdr.id  =  p_hdr_id
   AND lines.dnz_chr_id = hdr.id
   AND lines.date_cancelled is null --LLC BUG FIX 4742661
   And lines.date_terminated is null
   And lines.cle_id is null
   And hdr.sts_code <> 'QA_HOLD'
   AND (exists ( SELECT 1 from okc_assents a
                 where Hdr.scs_code = a.scs_code
                   and lines.sts_code = a.sts_code
                   and lines.sts_code <> 'HOLD'
                   and a.opn_code = 'INVOICE'
                   and a.allowed_yn = 'Y')
        OR
        (lines.sts_code = 'HOLD'));
                   --And exists (Select 1 from okc_statuses_b osb,
                   --                          okc_k_headers_b hdr
                   --             Where osb.ste_code <> 'HOLD'
                   --               and osb.code =   Hdr.sts_code ));

Cursor line_Det (p_line_id IN NUMBER) is
  SELECT lines.dnz_chr_id,
         lines.sts_code,
         lines.end_date,
         lines.lse_id,
         lines.line_number,
         lines.date_terminated
   FROM  okc_k_headers_b  hdr,
         okc_k_lines_b  lines
   WHERE lines.id = p_line_id
   AND   hdr.id  = lines.dnz_chr_id
   AND   hdr.sts_code <> 'QA_HOLD'
   AND  (exists ( SELECT 1 from okc_assents a
                 where Hdr.scs_code = a.scs_code
                   and lines.sts_code = a.sts_code
                   and lines.sts_code <> 'HOLD'
                   and a.opn_code = 'INVOICE'
                   and a.allowed_yn = 'Y')
         OR
         (lines.sts_code = 'HOLD'));


Cursor hdr_Det (p_hdr_id IN NUMBER) is
  SELECT end_date,
         contract_number,
         contract_number_modifier
   FROM okc_k_headers_b
   WHERE id = p_hdr_id;

Cursor fullfilled_subscr_amount(p_id IN NUMBER) is
Select nvl(sum(nvl(amount,0)),0),max(end_date)
 From oks_subscr_elements
 Where dnz_cle_id = p_id
 And   order_header_id is not null;

Cursor fullfilled_subscr_date(p_id IN NUMBER,p_termination_date IN date) is
Select max(end_date)
 From oks_subscr_elements
 Where dnz_cle_id = p_id
   and start_date <= p_termination_date - 1 ;


Cursor billed_subscr_amount(p_id IN NUMBER) is
Select nvl(sum(nvl(bcl.amount,0)),0)
         from oks_bill_cont_lines bcl
         where bcl.cle_id = p_id
         and   bcl.bill_action = 'RI';

Cursor unbilled_subscr_date (p_id in NUMBER) is
 Select min(om_interface_date)
    from oks_subscr_elements
    Where dnz_Cle_id = p_id
    and   order_header_id is null;


Cursor line_billed_cur (p_id IN NUMBER) is
Select id from oks_bill_cont_lines
         where cle_id = p_id
         and   bill_action = 'RI';

Cursor sub_line_billed_cur (p_id IN NUMBER) is
Select bsl.id from oks_bill_sub_lines bsl,
                        oks_bill_cont_lines bcl
         where bsl.cle_id = p_id
         and   bsl.bcl_id = bcl.id
         and   bcl.bill_action = 'RI';

Cursor sub_fullfilment_channel(p_id IN NUMBER) is
Select fulfillment_channel from oks_subscr_header_b
    where cle_id = p_id;

Cursor bcl_amount(p_bcl_id in number) is
 Select nvl(amount,0),cle_id ,btn_id,bill_action
 from oks_bill_cont_lines
   where id = p_bcl_id;

Cursor bsl_amount (p_bsl_id in number) is
 Select nvl(amount,0),cle_id
 from oks_bill_sub_lines
   where id = p_bsl_id;

Cursor sub_line_tax(p_sub_line_id in number ) is
Select tax_amount
  from oks_k_lines_b
 where cle_id = p_sub_line_id;

 CURSOR l_line_max_bill_date( p_line_id in NUMBER ) is
 SELECT max(bsl.date_billed_to) max_bill_date
   FROM oks_bill_cont_lines bcl
      , oks_bill_sub_lines bsl
  WHERE bcl.cle_id = p_line_id
    AND bcl.bill_action = 'RI'
    AND bcl.id = bsl.bcl_id ;

 CURSOR l_get_line_start_date(p_id in number ) is
 SELECT start_date
   FROM okc_k_lines_b
  WHERE id = p_id ;


/* Added for BUG 3364773 */
Cursor check_all_sublines_terminated(p_cle_id IN NUMBER) is
 SELECT id
 FROM okc_k_lines_b
 WHERE cle_id  = p_cle_id
 AND   lse_id in  (7,8,9,10,11,13,35,25)
  /* Start changes For bug fix 6012384 (FP for 5990067) */
 AND   sts_code IN(SELECT code FROM okc_statuses_b where ste_code NOT IN('TERMINATED','EXPIRED'));
 --AND   sts_code <> 'TERMINATED';
 /* End changes for bug fix 6012384 (FP for 5990067) */

/* Added for BUG 3364773 */
Cursor check_all_lines_terminated(p_hdr_id IN NUMBER) is
 SELECT id
 FROM okc_k_lines_b
 WHERE dnz_chr_id = p_hdr_id
  /* Start changes For bug fix 6012384 (FP for 5990067) */
  AND   lse_id in (1,12,14,19,46)
  --AND   lse_id in (1,12,14,19)
  /* End changes for bug fix 6012384 (FP for 5990067) */
  AND   cle_id is null
  /* Start changes For bug fix 6012384 (FP for 5990067) */
  AND   sts_code IN(SELECT code FROM okc_statuses_b where ste_code NOT IN('TERMINATED','EXPIRED'));
  --AND   sts_code <> 'TERMINATED';
  /* End changes for bug fix 6012384 (FP for 5990067) */

-- BUG#3312595 mchoudha: Cursor to check for service request
-- against the line

Cursor cur_line_sr(p_id IN NUMBER) IS
SELECT 'x'
FROM CS_INCIDENTS_ALL_B  sr
WHERE sr.contract_service_id = p_id
AND   sr.status_flag = 'O';

Cursor cur_lineno(p_id IN NUMBER) IS
SELECT lin.line_number,hdr.contract_number
FROM   okc_k_lines_b lin,
       okc_k_headers_b hdr
WHERE  lin.id=p_id
AND    hdr.id=lin.dnz_chr_id;

-- End BUG#3312595 mchoudha

-- Bug 4354983 TAKINTOY
Cursor cur_hdr_sr IS
SELECT 'x'
FROM CS_INCIDENTS_ALL_B  sr
WHERE sr.contract_id = p_id
AND   sr.status_flag = 'O';

Cursor cur_contract_num IS
select contract_number
from okc_k_headers_b
where id=p_id;
--END Bug 4354983

Cursor avg_bcl_amount_partial (p_cle_id in number) is
 Select sum(bsl.amount)
   from oks_bill_cont_lines bcl,
        oks_bill_sub_lines  bsl
   where bcl.cle_id = p_cle_id
   and   bsl.bcl_id = bcl.id
   and   bcl.bill_action <> 'TR'
   and   trunc(bcl.date_billed_from) >= trunc(p_termination_date);

Cursor avg_bcl_amount_full (p_cle_id in number) is
 Select sum(bsl.amount)
   from oks_bill_cont_lines bcl,
        oks_bill_sub_lines  bsl
   where bcl.cle_id = p_cle_id
   and   bsl.bcl_id = bcl.id
   and   bcl.bill_action <> 'TR';


Cursor neg_bcl_amount_line (p_cle_id in number) is
 Select nvl(sum(decode(sign(trunc(bsl.date_billed_from) -   trunc(p_termination_date))  ,-1,
           ((trunc(bsl.date_billed_to) -  trunc(p_termination_date) + 1) * bsl.amount) /
            (trunc(bsl.date_billed_to) - trunc(bsl.date_billed_from) + 1) ,bsl.amount      )),0)
   -- nvl(sum(bsl.amount),0)
   from oks_bill_cont_lines bcl,
        oks_bill_sub_lines  bsl
   where bcl.cle_id = p_cle_id
   and   bsl.bcl_id = bcl.id
   and   bcl.bill_action <> 'TR'
   and   trunc(bsl.date_billed_from) >= trunc(p_termination_date)
   and   bsl.amount < 0;

Cursor pos_bcl_amount_line (p_cle_id in number) is
 Select nvl(sum(decode(sign(trunc(bsl.date_billed_from) -   trunc(p_termination_date))  ,-1,
           ((trunc(bsl.date_billed_to) -  trunc(p_termination_date) + 1) * bsl.amount) /
            (trunc(bsl.date_billed_to) - trunc(bsl.date_billed_from) + 1) ,bsl.amount      )),0)
   from oks_bill_cont_lines bcl,
        oks_bill_sub_lines  bsl
   where bcl.cle_id = p_cle_id
   and   bsl.bcl_id = bcl.id
   and   bcl.bill_action <> 'TR'
   and   trunc(bsl.date_billed_from) >= trunc(p_termination_date)
   and   bsl.amount > 0;

Cursor check_avg_csr(p_cle_id in number) is
 Select 1 from oks_bill_cont_lines
  where cle_id = p_cle_id
  and   bill_action = 'AV';

Cursor neg_bcl_amount_hdr (p_hdr_id in number) is
 Select nvl(sum(decode(sign(trunc(bsl.date_billed_from) -   trunc(p_termination_date))  ,-1,
           ((trunc(bsl.date_billed_to) -  trunc(p_termination_date) + 1) * bsl.amount) /
            (trunc(bsl.date_billed_to) - trunc(bsl.date_billed_from) + 1) ,bsl.amount      )),0)
   from oks_bill_cont_lines bcl,
        oks_bill_sub_lines  bsl,
        okc_k_lines_b       line
   where bsl.bcl_id = bcl.id
   and   line.id = bcl.cle_id
   and   bcl.bill_action <> 'TR'
   and   line.dnz_chr_id = p_hdr_id
   and   line.lse_id = 12
   and   trunc(bsl.date_billed_from) >= trunc(p_termination_date)
   and   bsl.amount < 0;


Cursor pos_bcl_amount_hdr (p_hdr_id in number) is
 Select nvl(sum(decode(sign(trunc(bsl.date_billed_from) -   trunc(p_termination_date))  ,-1,
           ((trunc(bsl.date_billed_to) -  trunc(p_termination_date) + 1) * bsl.amount) /
            (trunc(bsl.date_billed_to) - trunc(bsl.date_billed_from) + 1) ,bsl.amount      )),0)
   from oks_bill_cont_lines bcl,
        oks_bill_sub_lines  bsl,
        okc_k_lines_b       line
   where bsl.bcl_id = bcl.id
   and   line.id = bcl.cle_id
   and   bcl.bill_action <> 'TR'
   and   line.dnz_chr_id = p_hdr_id
   and   line.lse_id = 12
   and   trunc(bsl.date_billed_from) >= trunc(p_termination_date)
   and   bsl.amount > 0;

l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(2000);
l_fulfillment_channel      VARCHAR2(10);
l_termn_method             VARCHAR2(10);
l_usage_type               VARCHAR2(10);
l_usage_period             VARCHAR2(10);
l_amount                   NUMBER;
l_chr_id                   NUMBER;
l_number                   NUMBER;
l_billed_amount            NUMBER;
l_shipped_amount           NUMBER;
l_termination_amount       NUMBER;
l_con_termination_amount   NUMBER;
l_dummy                    NUMBER;
l_billed                   BOOLEAN;
l_term_date                DATE;
l_next_ship_date           DATE;
l_max_term_date            DATE;
l_credit_amount            NUMBER;
--l_manual_credit          NUMBER;
l_line_parameter_rec       OKC_TERMINATE_PVT.terminate_in_cle_rec;
l_hdr_parameter_rec        OKC_TERMINATE_PVT.terminate_in_parameters_rec;
l_tang                     BOOLEAN ;
l_terminate                BOOLEAN ;
l_line_failed              BOOLEAN ;
l_sub_termn_amount         NUMBER;
l_neg_amount               NUMBER;
l_return_status            VARCHAR2(1);
l_allowed_date             DATE;
l_subscr_term_date         DATE;
l_okc_status               VARCHAR2(10);
l_status_flag              VARCHAR2(1);
l_lineno                   VARCHAR2(150);
l_contract_number          VARCHAR2(120);
l_bcl_credit_amount        NUMBER;
l_bsl_credit_amount        NUMBER;
l_bcl_update_id            NUMBER;
l_bsl_update_id            NUMBER;
l_bcl_cle_id               NUMBER;
l_bsl_cle_id               NUMBER;
l_bcl_btn_id               NUMBER;
l_bcl_bill_action          VARCHAR2(9);
l_sub_line_tax_amount      NUMBER;
G_RAIL_REC                 OKS_TAX_UTIL_PVT.ra_rec_type;


SUBTYPE l_bclv_tbl_type_in  is OKS_bcl_PVT.bclv_tbl_type;
   l_bclv_tbl_in   l_bclv_tbl_type_in;
   l_bclv_tbl_out   l_bclv_tbl_type_in;
SUBTYPE l_bslv_tbl_type_in  is OKS_bsl_PVT.bslv_tbl_type;
   l_bslv_tbl_in   l_bslv_tbl_type_in;
   l_bslv_tbl_out   l_bslv_tbl_type_in;
   l_true_value_tbl L_TRUE_VAL_TBL  ;

 LINE_FAILED  EXCEPTION;
 /* Start Addition for bug fix 6012384 (FP for 5990067) */
  SKIP_THIS_LINE   EXCEPTION;
 /* End Addition for bug fix 6012384 (FP for 5990067) */
BEGIN
 DBMS_TRANSACTION.SAVEPOINT('BEFORE_PRE_TERMINATE');
 x_return_status := OKC_API.G_RET_STS_SUCCESS ;
 l_billed        := FALSE;
 l_terminate     := FALSE;
 l_termination_amount := p_termination_amount;
 l_con_termination_amount := p_con_termination_amount;
 g_bsl_id := NULL;
 g_bcl_id := NULL;
 g_credit_amount := 0;


  --dbms_output.put_line ('p_termination_amount ='||p_termination_amount);
  --dbms_output.put_line ('p_con_termination_amount ='||p_con_termination_amount);
 IF (p_flag = 1) Then -- p_id is line_id

    -- BUG#3312595 mchoudha:  checking for service request
    -- against the line

    OPEN cur_line_sr(p_id);
    FETCH cur_line_sr into l_status_flag;
    CLOSE cur_line_sr;


    IF (l_status_flag = 'x') THEN

      OPEN cur_lineno(p_id);
      FETCH cur_lineno into l_lineno,l_contract_number;
      CLOSE cur_lineno;

      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => 'OKC_SR_PENDING',
                          p_token1        => 'NUMBER',
                          p_token1_value  => l_contract_number,
                          p_token2        => 'LINENO',
                          p_token2_value  =>  l_lineno);

      x_return_status := okc_api.g_ret_sts_error;
      raise  G_EXCEPTION_HALT_VALIDATION;
    end if;

   -- END BUG#3312595 mchoudha


   OPEN  line_det(p_id);
   FETCH line_det into  l_line_parameter_rec.p_dnz_chr_id,
                        l_line_parameter_rec.p_sts_code,
                        l_line_parameter_rec.p_orig_end_date ,
                        l_line_parameter_rec.p_lse_id ,
                        l_line_parameter_rec.p_line_number ,
                        l_line_parameter_rec.p_date_terminated;

   IF  (line_det%FOUND) THEN
     l_line_parameter_rec.p_cle_id   := p_id;
     l_line_parameter_rec.p_termination_reason := p_reason_code;
     l_terminate := TRUE;


     IF (l_line_parameter_rec.p_lse_id = 12) THEN
       IF ( p_termination_amount IS NULL) THEN

        l_neg_amount := 0;
        OPEN  check_avg_csr(p_id);
        FETCH check_avg_csr into l_neg_amount;
        close check_avg_csr;

        if l_neg_amount <> 1  Then

          OPEN  neg_bcl_amount_line(p_id);
          FETCH neg_bcl_amount_line into l_neg_amount;
          IF (nvl(l_neg_amount,0) < 0) THEN
              OPEN  pos_bcl_amount_line(p_id);
              FETCH pos_bcl_amount_line into l_termination_amount;
              CLOSE pos_bcl_amount_line;
              l_termination_amount := nvl(l_con_termination_amount,0) +  nvl(l_neg_amount,0) ;
          END IF;
          CLOSE neg_bcl_amount_line;

        Else
            l_termination_amount := l_con_termination_amount;
        End if;
       END IF;

       OPEN line_billed_cur(p_id);
       FETCH line_billed_cur into l_number;
       IF (line_billed_cur%FOUND) THEN
         l_billed := TRUE;
       ELSE
         l_billed := FALSE;
       END IF;
       CLOSE line_billed_cur;
     ELSIF (l_line_parameter_rec.p_lse_id = 13) THEN
       OPEN sub_line_billed_cur(p_id);
       FETCH sub_line_billed_cur into l_number;
       IF (sub_line_billed_cur%FOUND) THEN
         l_billed := TRUE;
       ELSE
         l_billed := FALSE;
       END IF;
       CLOSE sub_line_billed_cur;
     ELSIF (l_line_parameter_rec.p_lse_id = 46) THEN
       OPEN billed_subscr_amount(p_id);
       FETCH billed_subscr_amount into l_billed_amount;
       IF (l_billed_amount  >  0) THEN
         l_billed := TRUE;
       ELSE
         l_billed := FALSE;
       END IF;
       CLOSE billed_subscr_amount;

       l_tang := OKS_SUBSCRIPTION_PUB.IS_SUBS_TANGIBLE(P_ID);
       IF l_tang THEN
         OPEN fullfilled_subscr_amount(p_id);
         FETCH fullfilled_subscr_amount into l_shipped_amount,l_next_ship_date;
         CLOSE fullfilled_subscr_amount;
         IF (l_next_ship_date is null) THEN
           OPEN  fullfilled_subscr_date (p_id , p_termination_date );
           FETCH fullfilled_subscr_date into l_next_ship_date;
           CLOSE fullfilled_subscr_date ;
         END IF;
       ELSE
         l_shipped_amount := 0;
         l_next_ship_date := NULL;
       END IF;

     END IF;


     IF l_line_parameter_rec.p_lse_id  = 46 THEN  -- Subscribtion line
       IF ((l_shipped_amount > l_billed_amount) AND
             (p_termination_date < l_next_ship_date))   THEN
         l_term_date := l_next_ship_date;
         l_line_parameter_rec.p_termination_date := l_next_ship_date;
       ELSE
         l_line_parameter_rec.p_termination_date := p_termination_date;
         l_term_date := p_termination_date;
       END IF;
     ELSE
       l_term_date := p_termination_date;
       l_line_parameter_rec.p_termination_date := p_termination_date;
     END IF;

     /*
     IF (l_line_parameter_rec.p_orig_end_date < l_term_date ) THEN
       l_line_parameter_rec.p_termination_date  := p_termination_date;
     ELSE
       l_line_parameter_rec.p_termination_date  := l_term_date;
     END IF;
     */

     IF (l_line_parameter_rec.p_lse_id = 46 )  THEN
       IF (p_full_credit = 'Y')  THEN
          OPEN  l_get_line_start_date(p_id);
          FETCH l_get_line_start_date into l_subscr_term_date;
          CLOSE l_get_line_start_date;
       ELSE
          l_subscr_term_date := l_term_date ;
       END IF;

       PRE_TERMINATE_AMOUNT
           ( P_CALLEDFROM     => 1.0 ,
             P_ID             => p_id,
             P_TERMINATE_DATE => l_subscr_term_date,
             P_FLAG           => 1 ,
             X_AMOUNT         => l_sub_termn_amount ,
             --X_MANUAL_CREDIT  => l_manual_credit,
             X_RETURN_STATUS  => l_return_status );

       IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         raise G_EXCEPTION_HALT_VALIDATION;
       END IF;

       OKC_TERMINATE_PVT.terminate_cle
           ( P_API_VERSION                 => 1.0,
             P_INIT_MSG_LIST               => OKC_API.G_FALSE,
             X_RETURN_STATUS               => x_return_status,
             X_MSG_COUNT                   => l_msg_count,
             X_MSG_DATA                    => l_msg_data,
             P_TERMINATE_IN_PARAMETERS_REC => l_line_parameter_rec);

       ---For BUG#3372535 check for status S and W
        l_okc_status  := x_return_status;

        IF x_return_status NOT IN ( OKC_API.G_RET_STS_SUCCESS, 'W') Then
          raise G_EXCEPTION_HALT_VALIDATION;
        END IF;

       terminate_subscribtion_line
            (P_CALLEDFROM                   => p_calledfrom,
             P_API_VERSION                  => 1,
             P_INIT_MSG_LIST                => OKC_API.G_FALSE,
             X_RETURN_STATUS                => x_return_status,
             X_MSG_COUNT                    => l_msg_count,
             X_MSG_DATA                     => l_msg_data,
             P_LINE_ID                      => p_id,
             P_TERMINATION_DATE             => l_term_date,
             P_TERMINATION_AMOUNT           => l_termination_amount,
             P_CON_TERMINATION_AMOUNT       => l_con_termination_amount,
             P_BILLED_AMOUNT                => l_billed_amount,
             P_SHIPPED_AMOUNT               => l_shipped_amount,
             P_NEXT_SHIP_DATE               => l_next_ship_date,
             --P_EXISTING_CREDIT              => p_existing_credit,
             P_SUPPRESS_CREDIT              => p_suppress_credit ,
             P_TANG                         => l_tang,
             P_FULL_CREDIT                  => P_FULL_CREDIT );

       IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         raise G_EXCEPTION_HALT_VALIDATION;
       END IF;
     IF ((l_termination_amount is NOT NULL) and (g_credit_amount <> l_termination_amount)) THEN
         OPEN  bsl_amount(g_bsl_id);
         FETCH bsl_amount into l_bsl_credit_amount,l_bsl_cle_id;
         CLOSE bsl_amount ;

         OPEN  bcl_amount(g_bcl_id);
         FETCH bcl_amount into l_bcl_credit_amount,l_bcl_cle_id,l_bcl_btn_id,l_bcl_bill_action;
         CLOSE bcl_amount ;

         If g_credit_amount < l_termination_amount then
            l_bsl_credit_amount :=  l_bsl_credit_amount +
                              ((-1)*(l_termination_amount - g_credit_amount)) ;
            l_bsl_update_id := g_bsl_id;

            UPDATE oks_bill_sub_lines
               SET amount = l_bsl_credit_amount
             WHERE id = l_bsl_update_id ;

            l_bcl_credit_amount :=  l_bcl_credit_amount +
                               ((-1)*(l_termination_amount - g_credit_amount)) ;
            l_bcl_update_id := g_bcl_id;

            UPDATE oks_bill_cont_lines
               SET amount = l_bcl_credit_amount
             WHERE id = l_bcl_update_id ;

         Elsif g_credit_amount > l_termination_amount then

            l_bsl_credit_amount :=  l_bsl_credit_amount + (g_credit_amount - l_termination_amount ) ;
            l_bsl_update_id := g_bsl_id;

            UPDATE oks_bill_sub_lines
               SET amount = l_bsl_credit_amount
             WHERE id  = l_bsl_update_id;

            l_bcl_credit_amount :=  l_bcl_credit_amount + (g_credit_amount - l_termination_amount) ;
            l_bcl_update_id := g_bcl_id;

            UPDATE oks_bill_cont_lines
               SET amount = l_bcl_credit_amount
             WHERE id    = l_bcl_update_id;

         End If;
     END IF;
     g_credit_amount := 0;
     g_bcl_id := null;
     g_bsl_id := null;

       l_true_value_tbl(1).p_cp_line_id           := 0;
       l_true_value_tbl(1).p_top_line_id          := p_id;
       l_true_value_tbl(1).p_hdr_id               := 0 ;
       l_true_value_tbl(1).p_termination_date     := p_termination_date;
       l_true_value_tbl(1).p_terminate_reason     := p_reason_code;
       l_true_value_tbl(1).p_override_amount      := l_termination_amount;
       l_true_value_tbl(1).p_con_terminate_amount := l_sub_termn_amount;
       l_true_value_tbl(1).p_termination_amount   := l_termination_amount;
       l_true_value_tbl(1).p_suppress_credit      := p_suppress_credit;
       l_true_valUe_tbl(1).p_full_credit          := p_full_credit ;
       True_value(l_true_value_tbl , x_return_status );

       IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         raise G_EXCEPTION_HALT_VALIDATION;
       END IF;

     ELSE
       pre_terminate_service
          ( P_CALLEDFROM                   => p_calledfrom,
            P_API_VERSION                  => 1,
            X_RETURN_STATUS                => x_return_status,
            X_MSG_COUNT                    => l_msg_count,
            X_MSG_DATA                     => l_msg_data,
            P_K_LINE_ID                    => p_id,
            P_TERMINATION_DATE             => l_term_date,
            P_TERMINATION_AMOUNT           => l_termination_amount,  -- user input for termination
            P_CON_TERMINATION_AMOUNT       => l_con_termination_amount,  -- actual value to be terminated
            --P_EXISTING_CREDIT              => p_existing_credit,
            P_TERMINATION_FLAG             => p_termination_flag ,-- 1 - regular, 2- simulation
            P_SUPPRESS_CREDIT              => p_suppress_credit,
            P_FULL_CREDIT                  => P_FULL_CREDIT,
            X_AMOUNT                       => l_amount);

       IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         raise G_EXCEPTION_HALT_VALIDATION;
       END IF;

       IF ((l_termination_amount is NOT NULL) AND
           (g_credit_amount <> l_termination_amount)) THEN
         OPEN  bsl_amount(g_bsl_id);
         FETCH bsl_amount into l_bsl_credit_amount,l_bsl_cle_id;
         CLOSE bsl_amount ;

         OPEN  bcl_amount(g_bcl_id);
         FETCH bcl_amount into l_bcl_credit_amount,l_bcl_cle_id,
                               l_bcl_btn_id,l_bcl_bill_action;
         CLOSE bcl_amount ;

         IF (g_credit_amount < l_termination_amount) THEN
           l_bsl_credit_amount :=  l_bsl_credit_amount +
                               ((-1)*(l_termination_amount - g_credit_amount)) ;
           l_bsl_update_id := g_bsl_id;

           UPDATE oks_bill_sub_lines
             SET amount = l_bsl_credit_amount
             WHERE id = l_bsl_update_id ;

           l_bcl_credit_amount :=  l_bcl_credit_amount +
                               ((-1)*(l_termination_amount - g_credit_amount));
           l_bcl_update_id := g_bcl_id;

           UPDATE oks_bill_cont_lines
             SET amount = l_bcl_credit_amount
             WHERE id = l_bcl_update_id ;

         ELSIF (g_credit_amount > l_termination_amount) THEN

           l_bsl_credit_amount :=  l_bsl_credit_amount +
                                 (g_credit_amount - l_termination_amount ) ;
           l_bsl_update_id := g_bsl_id;

           UPDATE oks_bill_sub_lines
             SET amount = l_bsl_credit_amount
             WHERE id  = l_bsl_update_id;

           l_bcl_credit_amount :=  l_bcl_credit_amount +
                                 (g_credit_amount - l_termination_amount) ;
           l_bcl_update_id := g_bcl_id;

           UPDATE oks_bill_cont_lines
             SET amount = l_bcl_credit_amount
             WHERE id    = l_bcl_update_id;

         END IF;
       END IF;
       g_credit_amount := 0;
       g_bcl_id := null;
       g_bsl_id := null;
     END IF;

     /* The following If Statement was added to take care of rounding problem in case of termination.
        If user inputs the termination amount ,program should give credits for the exact amount. There
         should not be any rounding errors */
-- Code below is moved to call it before call to procedure true_value
/************************************************
     IF ((l_termination_amount is NOT NULL) and (g_credit_amount <> l_termination_amount)) THEN
         OPEN  bsl_amount(g_bsl_id);
         FETCH bsl_amount into l_bsl_credit_amount,l_bsl_cle_id;
         CLOSE bsl_amount ;

         OPEN  bcl_amount(g_bcl_id);
         FETCH bcl_amount into l_bcl_credit_amount,l_bcl_cle_id,l_bcl_btn_id,l_bcl_bill_action;
         CLOSE bcl_amount ;

         If g_credit_amount < l_termination_amount then
            l_bsl_credit_amount :=  l_bsl_credit_amount +
                               ((-1)*(l_termination_amount - g_credit_amount)) ;
            l_bsl_update_id := g_bsl_id;

            UPDATE oks_bill_sub_lines
               SET amount = l_bsl_credit_amount
             WHERE id = l_bsl_update_id ;

            l_bcl_credit_amount :=  l_bcl_credit_amount +
                               ((-1)*(l_termination_amount - g_credit_amount)) ;
            l_bcl_update_id := g_bcl_id;

            UPDATE oks_bill_cont_lines
               SET amount = l_bcl_credit_amount
             WHERE id = l_bcl_update_id ;

         Elsif g_credit_amount > l_termination_amount then

            l_bsl_credit_amount :=  l_bsl_credit_amount + (g_credit_amount - l_termination_amount ) ;
            l_bsl_update_id := g_bsl_id;

            UPDATE oks_bill_sub_lines
               SET amount = l_bsl_credit_amount
             WHERE id  = l_bsl_update_id;

            l_bcl_credit_amount :=  l_bcl_credit_amount + (g_credit_amount - l_termination_amount) ;
            l_bcl_update_id := g_bcl_id;

            UPDATE oks_bill_cont_lines
               SET amount = l_bcl_credit_amount
             WHERE id    = l_bcl_update_id;

         End If;
     END IF;
*/
     g_credit_amount := 0;
     g_bcl_id := null;
     g_bsl_id := null;



   END IF ;  -- line_det%FOUND
   CLOSE line_det;

   IF (l_line_parameter_rec.p_lse_id <> 46 ) THEN

      /* Added for BUG 3364773.If all sublines  are already in TERMINATED
         status , then change the line status to terminate too
      */
     OPEN  check_all_sublines_terminated(p_id);
     FETCH check_all_sublines_terminated into l_dummy;
     IF (( l_terminate = TRUE) OR
        ((l_terminate = FALSE) AND (check_all_sublines_terminated%NOTFOUND))) THEN

       l_true_value_tbl(1).p_cp_line_id           := 0;
       l_true_value_tbl(1).p_top_line_id          := p_id;
       l_true_value_tbl(1).p_hdr_id               := 0 ;
       l_true_value_tbl(1).p_termination_date     := p_termination_date;
       l_true_value_tbl(1).p_terminate_reason     := p_reason_code;
       l_true_value_tbl(1).p_override_amount      := l_termination_amount;
       l_true_value_tbl(1).p_con_terminate_amount := l_con_termination_amount;
       l_true_value_tbl(1).p_termination_amount   := l_termination_amount;
       l_true_value_tbl(1).p_suppress_credit      := p_suppress_credit;
       l_true_valUe_tbl(1).p_full_credit          := p_full_credit ;
       True_value(l_true_value_tbl , x_return_status );

       IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         raise G_EXCEPTION_HALT_VALIDATION;
       END IF;


       OKC_TERMINATE_PVT.terminate_cle
           ( P_API_VERSION                 => 1.0,
             P_INIT_MSG_LIST               => OKC_API.G_FALSE,
             X_RETURN_STATUS               => x_return_status,
             X_MSG_COUNT                   => l_msg_count,
             X_MSG_DATA                    => l_msg_data,
             P_TERMINATE_IN_PARAMETERS_REC => l_line_parameter_rec
            );
       -----for bug#3377509 check for S and W
        l_okc_status := x_return_status;

        IF x_return_status NOT IN (OKC_API.G_RET_STS_SUCCESS,'W') Then
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
     END IF;
     CLOSE  check_all_sublines_terminated;
   END IF;

   update oks_k_lines_b topline set topline.tax_amount =  ( select sum(tax_amount) from
                  oks_k_lines_b oksline, okc_k_lines_b okcline
                  where okcline.id = oksline.cle_id
                    and okcline.cle_id = p_id
                    and okcline.date_cancelled is null )
   where  topline.cle_id = p_id;

   update oks_k_headers_b hdr set hdr.tax_amount =  ( select sum(tax_amount) from
                  oks_k_lines_b oksline, okc_k_lines_b okcline
                  where okcline.id = oksline.cle_id
                  and okcline.dnz_chr_id = l_line_parameter_rec.p_dnz_chr_id
                  and okcline.date_cancelled is null
                  and lse_id in (1,12,19,46) )
   where  hdr.chr_id = l_line_parameter_rec.p_dnz_chr_id;

 ELSIF  (p_flag = 2) Then -- p_id is hdr_id

 --Bug 4354983 check if there is any open Service request for the contract

    OPEN cur_hdr_sr;
    FETCH cur_hdr_sr into l_status_flag;
    CLOSE cur_hdr_sr;


    IF (l_status_flag = 'x') THEN

      OPEN cur_contract_num;
      FETCH cur_contract_num into l_contract_number;
      CLOSE cur_contract_num;

      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => 'OKC_SR_PENDING',
                          p_token1        => 'NUMBER',
                          p_token1_value  => l_contract_number);
      x_return_status := okc_api.g_ret_sts_error;
      raise  G_EXCEPTION_HALT_VALIDATION;
    end if;
-- Bug 4354983 End

/****
   IF ( p_termination_amount IS NULL) THEN

     OPEN  neg_bcl_amount_hdr(p_id);
     FETCH neg_bcl_amount_hdr into l_neg_amount;
     IF (nvl(l_neg_amount,0) <0 ) THEN
       OPEN  pos_bcl_amount_hdr(p_id);
       FETCH pos_bcl_amount_hdr into l_con_termination_amount;
       CLOSE pos_bcl_amount_hdr;
       l_termination_amount := nvl(l_con_termination_amount,0) +  nvl(l_neg_amount,0) ;
     END IF;
     CLOSE neg_bcl_amount_hdr;

   END IF;
****/

   l_line_failed := FALSE;
   l_max_term_date := p_termination_date;

   FOR line_rec in line_cur(p_id)
   LOOP
   BEGIN
   /* Start Addition for bug fix 6012384 (FP for 5990067) */
   	IF line_rec.end_date < p_termination_date AND p_full_credit = 'N' /* Modified for Bug# 7013317 */
   	THEN
   		RAISE SKIP_THIS_LINE;
   	END IF;
   /* End Addition for bug fix 6012384 (FP for 5990067) */
     l_billed     := FALSE;
     l_terminate  := TRUE;



     l_termination_amount := p_termination_amount;
     l_con_termination_amount := p_con_termination_amount;

     IF (line_rec.lse_id = 12) THEN
       OPEN line_billed_cur(p_id);
       FETCH line_billed_cur into l_number;
       IF (line_billed_cur%FOUND) THEN
         l_billed := TRUE;
       ELSE
         l_billed := FALSE;
       END IF;
       CLOSE line_billed_cur;
     ELSIF (line_rec.lse_id = 46) THEN
       OPEN billed_subscr_amount(line_rec.id);
       FETCH billed_subscr_amount into l_billed_amount;
       IF (l_billed_amount  >  0) THEN
         l_billed := TRUE;
       ELSE
         l_billed := FALSE;
       END IF;
       CLOSE billed_subscr_amount;

       l_tang := OKS_SUBSCRIPTION_PUB.IS_SUBS_TANGIBLE(line_rec.id);

       IF l_tang THEN
         OPEN fullfilled_subscr_amount(line_rec.id);
         FETCH fullfilled_subscr_amount into l_shipped_amount,l_next_ship_date;
         CLOSE fullfilled_subscr_amount;

         IF (l_next_ship_date is null) THEN
           OPEN  fullfilled_subscr_date (line_rec.id , p_termination_date );
           FETCH fullfilled_subscr_date into l_next_ship_date;
           CLOSE fullfilled_subscr_date ;
         END IF;
       ELSE
         l_shipped_amount := 0;
         l_next_ship_date := NULL;
       END IF;

     END IF;

     ----l_line_parameter_rec changed to line_rec for bug#3514292

     IF line_rec.lse_id  = 46 THEN  -- Subscribtion line
       IF ((l_shipped_amount > l_billed_amount) AND
               (p_termination_date < l_next_ship_date))   THEN
         l_term_date := l_next_ship_date;
       ELSE
         l_term_date := p_termination_date;
       END IF;
     ELSE
       l_term_date := p_termination_date;
     END IF;

     l_fulfillment_channel := NULL;

     IF (line_rec.lse_id = 46 ) THEN
       If p_full_credit = 'Y' then
          open  l_get_line_start_date(line_rec.id);
          fetch l_get_line_start_date into l_subscr_term_date;
          close l_get_line_start_date;
       Else
          l_subscr_term_date := l_term_date ;
       End If;

       PRE_TERMINATE_AMOUNT
           ( p_calledfrom     => 1.0 ,
             p_id             => line_rec.id,
             p_terminate_date => l_subscr_term_date,
             p_flag           => 1 ,
             x_amount         => l_sub_termn_amount ,
             --x_manual_credit  => l_manual_credit,
             x_return_status  => l_return_status );

       IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         raise G_EXCEPTION_HALT_VALIDATION;
       END IF;

       OPEN  line_det(line_rec.id);
       FETCH line_det into     l_line_parameter_rec.p_dnz_chr_id,
                               l_line_parameter_rec.p_sts_code,
                               l_line_parameter_rec.p_orig_end_date ,
                               l_line_parameter_rec.p_lse_id ,
                               l_line_parameter_rec.p_line_number ,
                               l_line_parameter_rec.p_date_terminated;
       CLOSE line_det;
       l_line_parameter_rec.p_cle_id   := line_rec.id;
       l_line_parameter_rec.p_termination_reason := p_reason_code;
       l_line_parameter_rec.p_termination_date  := l_term_date;

       /*
       IF (l_line_parameter_rec.p_orig_end_date < l_term_date ) THEN
         l_line_parameter_rec.p_termination_date  := p_termination_date;
       ELSE
         l_line_parameter_rec.p_termination_date  := l_term_date;
       END IF;
       */

       IF (l_max_term_date < l_term_date) THEN
         l_max_term_date := l_term_date;
       END IF;

       OKC_TERMINATE_PVT.terminate_cle
              ( P_API_VERSION               => 1.0,
                P_INIT_MSG_LIST               => OKC_API.G_FALSE,
                X_RETURN_STATUS               => x_return_status,
                X_MSG_COUNT                   => l_msg_count,
                X_MSG_DATA                    => l_msg_data,
                P_TERMINATE_IN_PARAMETERS_REC => l_line_parameter_rec
                );

       ---For BUG#3372535 check for status S and W
        l_okc_status  := x_return_status;

        IF x_return_status NOT IN ( OKC_API.G_RET_STS_SUCCESS, 'W') Then
          raise G_EXCEPTION_HALT_VALIDATION;
        END IF;

       terminate_subscribtion_line
           ( P_CALLEDFROM                   => p_calledfrom,
             P_API_VERSION                  => 1,
             P_INIT_MSG_LIST                => OKC_API.G_FALSE,
             X_RETURN_STATUS                => x_return_status,
             X_MSG_COUNT                    => l_msg_count,
             X_MSG_DATA                     => l_msg_data,
             P_LINE_ID                      => line_rec.id,
             P_TERMINATION_DATE             => l_term_date,
             P_TERMINATION_AMOUNT           => l_termination_amount,
             P_CON_TERMINATION_AMOUNT       => l_con_termination_amount,
             P_BILLED_AMOUNT                => l_billed_amount,
             P_SHIPPED_AMOUNT               => l_shipped_amount,
             P_NEXT_SHIP_DATE               => l_next_ship_date,
             --P_EXISTING_CREDIT              => p_existing_credit,
             P_SUPPRESS_CREDIT              => p_suppress_credit ,
             P_TANG                         => l_tang ,
             P_FULL_CREDIT                  => P_FULL_CREDIT);

       l_true_value_tbl(1).p_cp_line_id           := 0;
       l_true_value_tbl(1).p_top_line_id          := line_rec.id;
       l_true_value_tbl(1).p_hdr_id               := p_id ;
       l_true_value_tbl(1).p_termination_date     := p_termination_date;
       l_true_value_tbl(1).p_terminate_reason     := p_reason_code;
       l_true_value_tbl(1).p_override_amount      := l_termination_amount;
       l_true_value_tbl(1).p_con_terminate_amount := l_sub_termn_amount;
       l_true_value_tbl(1).p_termination_amount   := l_termination_amount;
       l_true_value_tbl(1).p_suppress_credit      := p_suppress_credit;
       l_true_valUe_tbl(1).p_full_credit          := p_full_credit ;
       True_value(l_true_value_tbl , x_return_status );

       IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         raise G_EXCEPTION_HALT_VALIDATION;
       END IF;

   --ELSE

     ELSE
       pre_terminate_service
            (
            P_CALLEDFROM                   => p_calledfrom,
            P_API_VERSION                  => 1,
            P_INIT_MSG_LIST                => OKC_API.G_FALSE,
            X_RETURN_STATUS                => x_return_status,
            X_MSG_COUNT                    => l_msg_count,
            X_MSG_DATA                     => l_msg_data,
            P_K_LINE_ID                    => line_rec.id,
            P_TERMINATION_DATE             => l_term_date,
            P_TERMINATION_AMOUNT           => l_termination_amount,  -- user input for termination
            P_CON_TERMINATION_AMOUNT       => l_con_termination_amount,  -- actual value to be terminated
            P_TERMINATION_FLAG             => p_termination_flag ,-- 1 - regular, 2- simulation
            P_SUPPRESS_CREDIT              => p_suppress_credit,
            P_FULL_CREDIT                  => P_FULL_CREDIT,
            X_AMOUNT                       => l_amount
            );
           IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
              raise G_EXCEPTION_HALT_VALIDATION;
           END IF;

           l_true_value_tbl(1).p_cp_line_id           := 0;
           l_true_value_tbl(1).p_top_line_id          := line_rec.id;
           l_true_value_tbl(1).p_hdr_id               := p_id ;
           l_true_value_tbl(1).p_termination_date     := p_termination_date;
           l_true_value_tbl(1).p_terminate_reason     := p_reason_code;
           l_true_value_tbl(1).p_override_amount      := l_termination_amount;
           l_true_value_tbl(1).p_con_terminate_amount := l_con_termination_amount;
           l_true_value_tbl(1).p_termination_amount   := l_termination_amount;
           l_true_value_tbl(1).p_suppress_credit      := p_suppress_credit;
           l_true_valUe_tbl(1).p_full_credit          := p_full_credit ;
           True_value(l_true_value_tbl , x_return_status );
           IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
              raise G_EXCEPTION_HALT_VALIDATION;
           END IF;

     END IF;

   update oks_k_lines_b topline set topline.tax_amount =  ( select sum(tax_amount) from
                  oks_k_lines_b oksline, okc_k_lines_b okcline
                  where okcline.id = oksline.cle_id
                    and okcline.cle_id = line_rec.id
                    and okcline.date_cancelled is null )
   where  topline.cle_id = line_rec.id;

   EXCEPTION
     WHEN LINE_FAILED THEN
        l_line_failed := TRUE;
     /* Start Addition for bug fix 6012384 (FP for 5990067) */
     WHEN SKIP_THIS_LINE THEN
     	NULL;
     /* End Addition for bug fix 6012384 (FP for 5990067) */
   END;
   END LOOP;

   IF (l_terminate = TRUE ) THEN

       /* The following If Statement was added to take care of rounding problem in case of termination.
          If user inputs the termination amount ,program should give credits for the exact amount. There
          should not be any rounding errors */


       IF ((l_termination_amount is NOT NULL) AND (g_credit_amount <> l_termination_amount)) THEN

          OPEN  bsl_amount(g_bsl_id);
          FETCH bsl_amount into l_bsl_credit_amount,l_bsl_cle_id;
          CLOSE bsl_amount ;

          OPEN  bcl_amount(g_bcl_id);
          FETCH bcl_amount into l_bcl_credit_amount,l_bcl_cle_id,l_bcl_btn_id,l_bcl_bill_action;
          CLOSE bcl_amount ;

          If g_credit_amount < l_termination_amount then
              l_bsl_credit_amount :=  l_bsl_credit_amount +
                               ((-1)*(l_termination_amount - g_credit_amount)) ;
              l_bsl_update_id := g_bsl_id;

              UPDATE oks_bill_sub_lines
                 SET amount = l_bsl_credit_amount
               WHERE id = l_bsl_update_id ;

              l_bcl_credit_amount :=  l_bcl_credit_amount +
                              ((-1)*(l_termination_amount - g_credit_amount)) ;
              l_bcl_update_id := g_bcl_id;

              UPDATE oks_bill_cont_lines
                 SET amount = l_bcl_credit_amount
               WHERE id = l_bcl_update_id ;
              If l_bcl_btn_id = -44 and l_bcl_bill_action = 'TR' then
                 update oks_k_lines_b
                    set suppressed_credit = suppressed_credit + (l_termination_amount - g_credit_amount)
                      , override_amount = override_amount - (l_termination_amount - g_credit_amount)
                 where cle_id = l_bsl_cle_id;
                 If l_bcl_cle_id <> l_bsl_cle_id then
                    update oks_k_lines_b
                       set suppressed_credit = suppressed_credit + (l_termination_amount - g_credit_amount)
                         , override_amount = override_amount - (l_termination_amount - g_credit_amount)
                     where cle_id = l_bcl_cle_id;
                 End If;
              Elsif l_bcl_btn_id is null and l_bcl_bill_action = 'TR' then
                 update oks_k_lines_b
                    set credit_amount = credit_amount + (l_termination_amount - g_credit_amount)
                      , override_amount = override_amount - (l_termination_amount - g_credit_amount)
                 where cle_id = l_bsl_cle_id;
                 If l_bcl_cle_id <> l_bsl_cle_id then
                    update oks_k_lines_b
                       set credit_amount = credit_amount + (l_termination_amount - g_credit_amount)
                         , override_amount = override_amount - (l_termination_amount - g_credit_amount)
                     where cle_id = l_bcl_cle_id;
                 End If;
              End If;
              update okc_k_lines_b
                 set price_negotiated = price_negotiated - ( l_termination_amount - g_credit_amount )
              where id = l_bcl_cle_id
                and lse_id <> 12;
              If l_bsl_cle_id <> l_bcl_cle_id then
                 update okc_k_lines_b
                    set price_negotiated = price_negotiated - ( l_termination_amount - g_credit_amount )
                  where id = l_bsl_cle_id
                    and lse_id <>13;
              End If;
              If sql%rowcount > 0 then
              update okc_k_headers_b
                 set estimated_amount = estimated_amount - ( l_termination_amount - g_credit_amount )
               where id =  p_id;
              End if;
              open sub_line_tax(l_bsl_cle_id);
              fetch sub_line_tax into l_sub_line_tax_amount;
              close sub_line_tax;
              If l_sub_line_tax_amount > 0 then
                    OKS_TAX_UTIL_PVT.Get_Tax
                     ( p_api_version      => 1.0,
                       p_init_msg_list    => OKC_API.G_TRUE,
                       p_chr_id           => p_id,
                       p_cle_id           => l_bsl_cle_id,
                       px_rail_rec        => G_RAIL_REC,
                       x_msg_count        => l_msg_count,
                       x_msg_data         => l_msg_data,
                       x_return_status    => l_return_status);
                    IF ( x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                       RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;
                    If G_RAIL_REC.AMOUNT_INCLUDES_TAX_FLAG = 'N' then
                       update oks_k_lines_b
                          set tax_amount = G_RAIL_REC.tax_value
                        where cle_id = l_bsl_cle_id;

                    End If;
              End If;
          Elsif g_credit_amount > l_termination_amount then
              l_bsl_credit_amount :=  l_bsl_credit_amount + (g_credit_amount - l_termination_amount ) ;
              l_bsl_update_id := g_bsl_id;

              UPDATE oks_bill_sub_lines
                 SET amount = l_bsl_credit_amount
               WHERE id  = l_bsl_update_id ;

              l_bcl_credit_amount :=  l_bcl_credit_amount + (g_credit_amount - l_termination_amount) ;
              l_bcl_update_id := g_bcl_id;

              UPDATE oks_bill_cont_lines
                 SET amount = l_bcl_credit_amount
               WHERE id    = l_bcl_update_id ;
              If l_bcl_btn_id = -44 and l_bcl_bill_action = 'TR' then
                 update oks_k_lines_b
                    set suppressed_credit = suppressed_credit + (l_termination_amount - g_credit_amount)
                      , override_amount = override_amount - (l_termination_amount - g_credit_amount)
                 where cle_id = l_bsl_cle_id;
                 If l_bcl_cle_id <> l_bsl_cle_id then
                    update oks_k_lines_b
                       set suppressed_credit = suppressed_credit + (l_termination_amount - g_credit_amount)
                      , override_amount = override_amount - (l_termination_amount - g_credit_amount)
                     where cle_id = l_bcl_cle_id;
                 End If;
              Elsif l_bcl_btn_id is null and l_bcl_bill_action = 'TR' then
                 update oks_k_lines_b
                    set credit_amount = credit_amount + (l_termination_amount - g_credit_amount)
                      , override_amount = override_amount - (l_termination_amount - g_credit_amount)
                 where cle_id = l_bsl_cle_id;
                 If l_bcl_cle_id <> l_bsl_cle_id then
                    update oks_k_lines_b
                       set credit_amount = credit_amount + (l_termination_amount - g_credit_amount)
                         , override_amount = override_amount - (l_termination_amount - g_credit_amount)
                     where cle_id = l_bcl_cle_id;
                 End If;
              End If;
              update okc_k_lines_b
                 set price_negotiated = price_negotiated + (  g_credit_amount - l_termination_amount )
               where id = l_bcl_cle_id
                 and lse_id <> 12;
              If l_bsl_cle_id <> l_bcl_cle_id then
                 update okc_k_lines_b
                    set price_negotiated = price_negotiated + (  g_credit_amount - l_termination_amount )
                  where id = l_bsl_cle_id
                    and lse_id <>13;
              End If;
              If sql%rowcount > 0 then
              update okc_k_headers_b
                 set estimated_amount = estimated_amount + (  g_credit_amount -  l_termination_amount )
               where id =  p_id;
              End if;
              open sub_line_tax(l_bsl_cle_id);
              fetch sub_line_tax into l_sub_line_tax_amount;
              close sub_line_tax;
              If l_sub_line_tax_amount > 0 then
                    OKS_TAX_UTIL_PVT.Get_Tax
                     ( p_api_version      => 1.0,
                       p_init_msg_list    => OKC_API.G_TRUE,
                       p_chr_id           => p_id,
                       p_cle_id           => l_bsl_cle_id,
                       px_rail_rec        => G_RAIL_REC,
                       x_msg_count        => l_msg_count,
                       x_msg_data         => l_msg_data,
                       x_return_status    => l_return_status);
                    IF ( x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                       RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;
                    If G_RAIL_REC.AMOUNT_INCLUDES_TAX_FLAG = 'N' then
                       update oks_k_lines_b
                          set tax_amount = G_RAIL_REC.tax_value
                        where cle_id = l_bsl_cle_id;

                    End If;
              End If;
          End If;
       END IF;

   update oks_k_lines_b topline set topline.tax_amount =  ( select sum(tax_amount) from
                  oks_k_lines_b oksline, okc_k_lines_b okcline
                  where okcline.id = oksline.cle_id
                    and okcline.cle_id = l_bcl_cle_id
                    and okcline.date_cancelled is null )
   where  topline.cle_id = l_bcl_cle_id;

   END IF ;  -- l_terminate = TRUE

   g_credit_amount :=0;
   g_bsl_id := null;
   g_bcl_id := null;

   /* Added for BUG 3364773.If all lines  are already in TERMINATED
      status , then change the hdr status to terminate too
   */
   OPEN  check_all_lines_terminated(p_id);
   FETCH check_all_lines_terminated into l_dummy;

   IF (l_line_failed = FALSE)  AND
      ((( l_terminate = TRUE) OR
      ((l_terminate = FALSE) AND (check_all_lines_terminated%NOTFOUND)))) THEN


     OPEN hdr_det(p_id);
     FETCH hdr_det into l_hdr_parameter_rec.p_orig_end_date,
                        l_hdr_parameter_rec.p_contract_number,
                        l_hdr_parameter_rec.p_contract_modifier;
     CLOSE hdr_det;

     l_hdr_parameter_rec.p_contract_id := p_id;
     l_hdr_parameter_rec.p_termination_date := p_termination_date;
     l_hdr_parameter_rec.p_termination_reason := p_reason_code;

     IF (p_termination_date < l_max_term_date) THEN
       l_hdr_parameter_rec.p_termination_date := l_max_term_date;
     END IF;

     --dbms_output.put_line ('before terminate_hdr ');
     OKC_TERMINATE_PVT.terminate_chr
               ( p_api_version                 => 1.0,
                 p_init_msg_list               => OKC_API.G_FALSE,
                 x_return_status               => x_return_status,
                 x_msg_count                   => l_msg_count,
                 x_msg_data                    => l_msg_data,
                 p_terminate_in_parameters_rec => l_hdr_parameter_rec
                 );

     ---For BUG#3372535 check for status S and W
     l_okc_status  := x_return_status;

     IF x_return_status NOT IN ( OKC_API.G_RET_STS_SUCCESS, 'W') Then
       raise G_EXCEPTION_HALT_VALIDATION;
     END IF;

     l_true_value_tbl(1).p_cp_line_id       := 0;
     l_true_value_tbl(1).p_top_line_id      := 0;
     l_true_value_tbl(1).p_hdr_id           := p_id ;
     l_true_value_tbl(1).p_termination_date := p_termination_date;
     l_true_value_tbl(1).p_terminate_reason := p_reason_code;
     l_true_value_tbl(1).p_override_amount  := l_termination_amount;
     l_true_value_tbl(1).p_con_terminate_amount := l_con_termination_amount;
     l_true_value_tbl(1).p_termination_amount   := l_termination_amount;
     l_true_value_tbl(1).p_suppress_credit      := p_suppress_credit;
     l_true_valUe_tbl(1).p_full_credit          := p_full_credit ;

     True_value(l_true_value_tbl , x_return_status );

     IF x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
       raise G_EXCEPTION_HALT_VALIDATION;
     END IF;

   END IF ;  -- l_terminate = TRUE|| ((l_terminate = FALSE) AND (check_all_lines_terminated%NOTFOUND)))

   update oks_k_headers_b hdr set hdr.tax_amount =  ( select sum(tax_amount) from
                  oks_k_lines_b oksline, okc_k_lines_b okcline
                  where okcline.id = oksline.cle_id
                  and okcline.dnz_chr_id = p_id
                  and okcline.date_cancelled is null
                  and lse_id in (1,12,19,46) )
   where  hdr.chr_id = p_id;

 END IF;    --End of Main IF Statement


 ----this is added if okc passes status as 'W' , form based on status oly shows the warning.
 ---without this statment x_return_status returned from okc is overridden by next sub program.
 ---added for bug#3372535

 x_return_status := nvl(l_okc_status, 'S');

EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
    DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_PRE_TERMINATE');
 WHEN OTHERS THEN
    x_return_status   :=   OKC_API.G_RET_STS_UNEXP_ERROR;
    OKC_API.set_message(G_APP_NAME,G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE,G_SQLERRM_TOKEN, SQLERRM);
END;


PROCEDURE pre_terminate_service
  ( P_CALLEDFROM                   IN         NUMBER   DEFAULT Null,
    p_api_version                  IN         NUMBER,
    p_init_msg_list                IN         VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_k_line_id                    IN         NUMBER,
    p_termination_date             IN         DATE,
    p_termination_amount           IN         NUMBER   DEFAULT NULL,  -- user input for termination
    p_con_termination_amount       IN         NUMBER   DEFAULT NULL,  -- actual value to be terminated
    --p_existing_credit              IN         NUMBER   DEFAULT NULL,
    p_termination_flag             IN         NUMBER   DEFAULT NULL, -- 1 - regular, 2- simulation
    p_suppress_credit              IN         VARCHAR2,
    p_full_credit                  IN         VARCHAR2,
    x_amount                       OUT NOCOPY NUMBER )

IS

CURSOR l_lse_csr Is
SELECT LIne.lse_id,
       rline.termn_method,
       rline.usage_type,
       rline.usage_period
  FROM okc_k_lines_b  line,
       oks_k_lines_b  rline
 WHERE line.id = p_k_line_id
   AND rline.cle_id = line.id;

CURSOR l_rel_csr Is
SELECT obj.id
  From OKC_K_REL_OBJS_V obj,
       OKC_K_LINES_B  ln
 Where obj.cle_id = ln.id
   And ln.cle_id =  p_k_line_id;

CURSOR l_line_csr (p_id in NUMBER ) is
 SELECT start_date
 FROM  okc_k_lines_b
 WHERE id = p_id ;


l_lse_id                 NUMBER;
l_amount                 NUMBER ;
l_id                     NUMBER;
l_msg_cnt                NUMBER;
l_msg_data               VARCHAR2(2000);
l_termination_method     VARCHAR2(20);
l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_usage_type             VARCHAR2(10);
l_usage_period           VARCHAR2(10);
l_termination_date       DATE;
l_sub_line_id            NUMBER ;



BEGIN

  IF ((nvl(p_termination_amount,1) > 0) OR
          (nvl(p_con_termination_amount,1) > 0)) THEN

    OPEN  l_lse_csr ;
    FETCH l_lse_csr into l_lse_id,l_termination_method,
                         l_usage_type,l_usage_period ;
    CLOSE l_lse_csr;

    IF (l_lse_id = 19) THEN
      OPEN  l_rel_csr;
      FETCH l_rel_csr into l_id;

      IF (l_rel_csr%found) THEN

       --errorout('EXTD. WARRANTY ROUTINE');

        Pre_terminate_extwar
            (
              P_CALLEdFROM             => p_calledfrom,
              P_LINE_ID                => p_k_line_id,
              P_TERMINATION_DATE       => p_termination_date,
              P_SUPPRESS_CREDIT        => p_suppress_credit,
              P_TERMINATION_AMOUNT     => p_termination_amount,
              P_CON_TERMINATION_AMOUNT => p_con_termination_amount,
              P_COV_LINE               => 'N'  ,         -- NOT a coverage line
              P_FULL_CREDIT            => p_full_credit,
              --P_EXISTING_CREDIT        => p_existing_credit,
              X_AMOUNT                 => l_amount,
              X_RETURN_STATUS          => l_return_status
             );

      ELSE
        --errorout('SERVICE ROUTINE');

         Pre_terminate_srvc
           (
             P_CALLEDFROM             => p_calledfrom,
             P_K_LINE_ID              => p_k_line_id,
             P_TERMINATION_DATE       => p_termination_date,
             P_FLAG                   => p_termination_flag, -- 1 - regular, 2- simulation
             P_TERMINATION_AMOUNT     => p_termination_amount,
             P_CON_TERMINATION_AMOUNT => p_con_termination_amount,
             --P_EXISTING_CREDIT        => p_existing_credit,
             P_SUPPRESS_CREDIT        => p_suppress_credit,
             P_FULL_CREDIT            => P_FULL_CREDIT,
             X_AMOUNT                 => l_amount,
             X_RETURN_STATUS          => l_return_status
            );


      END IF;
      CLOSE l_rel_csr;

    ELSIF (l_lse_id = 12) THEN
      IF ( l_termination_method = 'VOLUME') THEN
         pre_vol_based_terminate(
            P_CALLEDFROM                   => p_calledfrom,
            P_API_VERSION                  => 1,
            P_INIT_MSG_LIST                => OKC_API.G_FALSE,
            X_RETURN_STATUS                => l_return_status,
            X_MSG_COUNT                    => l_msg_cnt,
            X_MSG_DATA                     => l_msg_data,
            P_K_LINE_ID                    => p_k_line_id,
            P_CP_LINE_ID                   => NULL,
            P_TERMINATION_DATE             => p_termination_date,
            P_TERMINATION_AMOUNT           => p_termination_amount,  --user i/p
            P_CON_TERMINATION_AMOUNT       => p_con_termination_amount,-- actual
            --P_EXISTING_CREDIT              => p_existing_credit,
            P_SUPPRESS_CREDIT              => p_suppress_credit,
            P_USAGE_TYPE                   => l_usage_type,
            P_USAGE_PERIOD                 => l_usage_period,
            X_AMOUNT                       => l_amount);

      ELSE
        Pre_terminate_srvc
           (
             P_CALLEDFROM             => p_calledfrom,
             P_K_LINE_ID              => p_k_line_id,
             P_TERMINATION_DATE       => p_termination_date,
             P_FLAG                   => p_termination_flag,
             P_TERMINATION_AMOUNT     => p_termination_amount,
             P_CON_TERMINATION_AMOUNT => p_con_termination_amount,
             --P_EXISTING_CREDIT        => p_existing_credit,
             P_SUPPRESS_CREDIT        => p_suppress_credit,
             P_FULL_CREDIT            => p_full_credit,
             X_AMOUNT                 => l_amount,
             X_RETURN_STATUS          => l_return_status
            );

      END IF;
    ELSE
      Pre_terminate_srvc
           (
             P_CALLEDFROM             => p_calledfrom,
             P_K_LINE_ID              => p_k_line_id,
             P_TERMINATION_DATE       => p_termination_date,
             P_FLAG                   => p_termination_flag, -- 1 - regular, 2-simulation
             P_TERMINATION_AMOUNT     => p_termination_amount,
             P_CON_TERMINATION_AMOUNT => p_con_termination_amount,
             --P_EXISTING_CREDIT        => p_existing_credit,
             P_SUPPRESS_CREDIT        => p_suppress_credit,
             P_FULL_CREDIT            => p_full_credit,
             X_AMOUNT                 => l_amount,
             X_RETURN_STATUS          => l_return_status
            );

    END IF;
   END IF;
/************************************
  IF p_full_credit = 'Y' then
     OPEN  l_line_csr(p_k_line_id);
     Fetch l_line_csr into l_termination_date;
     CLOSE l_line_csr;
  ELSE
     l_termination_date := p_termination_date ;
  END IF;
*************************************/
  If p_full_credit = 'Y' then
     l_sub_line_id := -100 ;
  Else
     l_sub_line_id := NULL;
  End If;


   OKS_BILL_SCH.Terminate_bill_sch(
          P_TOP_LINE_ID         => p_k_line_id,
          P_SUB_LINE_ID         => l_sub_line_id,
          P_TERM_DT             => p_termination_date,
          X_RETURN_STATUS       => l_return_status,
          X_MSG_COUNT           => l_msg_cnt,
          X_MSG_DATA            => l_msg_data);


x_amount := nvl(l_amount,0);

X_return_status := l_return_status;
EXCEPTION
  WHEN  G_EXCEPTION_HALT_VALIDATION THEN
    x_return_status   :=   l_return_status;
  WHEN  Others THEN
    x_return_status   :=   OKC_API.G_RET_STS_UNEXP_ERROR;
    OKC_API.set_message(G_APP_NAME,G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE,G_SQLERRM_TOKEN, SQLERRM);

END ;

/* Procedure to calculate AMCV */

-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 12-JUN-2005
-- Added parameters p_period_type and p_period_start
-------------------------------------------------------------------------
PROCEDURE OKS_REG_GET_AMCV
 (
  P_CALLEDFROM      IN           NUMBER    DEFAULT NULL,
  X_RETURN_STATUS  OUT   NOCOPY  VARCHAR2,
  P_CLE_ID          IN           NUMBER,
  P_COV_START_DATE  IN           DATE,
  P_COV_END_DATE    IN           DATE,
  P_COUNTER_DATE    IN           DATE,
  P_COUNTER_VALUE   IN           NUMBER,
  P_PERIOD_TYPE     IN           VARCHAR2,
  P_PERIOD_START    IN           VARCHAR2,
  P_USAGE_PERIOD    IN           VARCHAR2,
  X_VOLUME         OUT   NOCOPY  NUMBER
 )
 IS
l_mth                NUMBER := 1;
l_prddays            NUMBER;
l_TotVol             NUMBER;
l_Date_Billed_From   DATE;
l_Date_Billed_To     DATE;

Cursor l_date_csr Is
  SELECT  Min(bsl.DATE_BILLED_FROM)
         ,Max(bsl.DATE_BILLED_TO)
  FROM  oks_bill_cont_lines bcl  ,
        oks_bill_sub_lines  bsl
  WHERE  bsl.cle_id = p_cle_id
  AND    bsl.bcl_id = bcl.id
  AND    bcl.bill_action  = 'RI';

Cursor l_tot_csr Is
  SELECT NVL(Sum(NVL(bsd.Result,0)),0)
  FROM   oks_bill_cont_lines    bcl,
         oks_bill_sub_lines     bsl,
         oks_bill_sub_line_dtls bsd
  WHERE  bsl.cle_id = p_cle_id
  AND    bsl.bcl_id = bcl.id
  AND    bcl.bill_action ='RI'
  AND    bsd.bsl_id = bsl.id;

BEGIN
  x_Volume        := 0;
  l_totvol := 0;
  x_Return_Status := OKC_API.G_RET_STS_SUCCESS;

  IF ((p_calledfrom <> 3) OR
     ((p_calledfrom = 3) AND ( p_counter_date IS NULL))) THEN  -- Ignore for termination if counter is captured
    OPEN  l_tot_csr;
    FETCH l_tot_csr into l_totvol;
    CLOSE l_tot_csr;
  END IF;

  IF (p_counter_date IS NULL) THEN
    OPEN  l_date_csr;
    FETCH l_date_csr into l_date_billed_from,l_date_billed_to;
    CLOSE l_date_csr;

  ELSE
    l_date_billed_from := p_cov_start_date;
    l_date_billed_to   := p_counter_date;
    l_totvol           := l_totvol + p_counter_value;
  END IF;


  --x_Volume := Round(l_TotVol / l_prddays,0);

  -------------------------------------------------------------------------
  -- Begin partial period computation logic
  -- Developer Mani Choudhary
  -- Date 12-JUN-2005
  -- Calling get_target_qty_service to consider the period type
  -------------------------------------------------------------------------
  IF p_period_type IS NOT NULL AND
     p_period_start IS NOT NULL AND
     l_date_billed_from IS NOT NULL AND   --mchoudha Fix for bug#5166216
     l_date_billed_to IS NOT NULL
  THEN
     l_prddays :=  OKS_TIME_MEASURES_PUB.get_target_qty_service (
                                                        p_start_date   => l_Date_Billed_From,
                                                        p_end_date     => l_Date_Billed_To,
                                                        p_price_uom    => p_usage_period,
                                                        p_period_type  => p_period_type,
                                                        p_round_dec    => 18
                                                        );
      IF nvl(l_prddays,0) = 0 THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

  ELSE
    l_prddays := trunc(l_Date_Billed_To) - trunc(l_Date_Billed_From) + 1;
  END IF;

  x_Volume := l_TotVol / l_prddays;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'Error in OKS_REG_GET_AMCV -- G_Exception_halt_validation raised' );
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'Error in OKS_REG_GET_AMCV -- Others Exception raised' );
    OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,
                        G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END  OKS_REG_GET_AMCV;

--------------------------------------------------------------------------------
                           --Usage_qty_to_bill
-------------------------------------------------------------------------------
-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 11-JUN-2005
-- Added additional period_type period_start parameters
-------------------------------------------------------------------------
Procedure Usage_qty_to_bill
(
  P_calledfrom            IN                NUMBER DEFAULT NULL,
  P_cle_id                IN                NUMBER,
  P_Usage_type            IN                VARCHAR2,
  P_estimation_flag       IN                VARCHAR2,
  P_estimation_method     IN                VARCHAR2,
  P_default_qty           IN                NUMBER,
  P_cov_start_date        IN                DATE,
  P_cov_end_date          IN                DATE,
  P_cov_prd_start_date    IN                DATE,
  P_cov_prd_end_date      IN                DATE,
  p_usage_period          IN                VARCHAR2,
  p_time_uom_code         IN                VARCHAR2,
  p_settle_interval       IN                VARCHAR2,
  p_minimum_quantity      IN                NUMBER,
  p_usg_est_start_date    IN                DATE,
  p_period_type           IN                VARCHAR2, --period type
  p_period_start          IN                VARCHAR2, --period start
  X_qty                   OUT        NOCOPY NUMBER,
  X_Uom_Code              OUT        NOCOPY VARCHAR2,
  X_flag                  OUT        NOCOPY VARCHAR2,
  X_end_reading           OUT        NOCOPY NUMBER,
  X_start_reading         OUT        NOCOPY NUMBER,
  X_base_reading          OUT        NOCOPY NUMBER,
  X_estimated_qty         OUT        NOCOPY NUMBER,
  X_actual_qty            OUT        NOCOPY NUMBER,
  X_counter_value_id      OUT        NOCOPY NUMBER,
  X_counter_group_id      OUT        NOCOPY NUMBER,
  X_return_status         OUT        NOCOPY VARCHAR2
)
IS
/* ONE is added to count to consider the unbilled current period */
CURSOR billed_period_csr (p_cle_id   IN   NUMBER) IS
 SELECT count(*) + 1
    FROM   oks_bill_sub_lines
    WHERE  cle_id = p_cle_id;

CURSOR  total_billed_qty (p_cle_id   IN  NUMBER)  IS
  SELECT sum(result)
    FROM oks_bill_sub_line_dtls bsd,
         oks_bill_sub_lines     bsl
    WHERE bsl.cle_id = p_cle_id
    AND   bsd.bsl_id = bsl.id;

CURSOR l_max_date_end (p_cle_id IN NUMBER, p_date  IN DATE) IS
  SELECT MAX(date_end)
    FROM oks_level_elements
    WHERE cle_id = p_cle_id
    AND   trunc(date_end) < trunc(p_date)
    AND   date_completed is NOT NULL;


CURSOR l_min_date_start (p_cle_id IN NUMBER, p_date  IN DATE) IS
  SELECT MIN(date_start)
    FROM oks_level_elements
    WHERE cle_id = p_cle_id
    AND   trunc(date_start) >  trunc(p_date)
    AND   date_completed is NOT NULL;

--Added this cursor to fetch uom code.
--Will be used for partial periods
-------------------------------------------
 CURSOR l_Billuom_csr(p_date IN DATE) IS
 SELECT UOM_CODE
 FROM   oks_stream_levels_b
 WHERE  cle_id = p_cle_id
 AND    trunc(p_date) >= START_DATE
 AND    trunc(p_date) <= END_DATE;
---------------------------------------------


  l_uom_code              VARCHAR2(30);
  l_return_status         VARCHAR2(10);
  l_billing_based_on      VARCHAR2(10);
  l_msg_data              VARCHAR2(2000);
  l_qty                   NUMBER;
  l_est_reading           NUMBER;
  l_estimated_qty         NUMBER;
  l_end_reading           NUMBER;
  l_start_reading         NUMBER;
  l_base_reading          NUMBER;
  l_counter_value_id      NUMBER;
  l_counter_group_id      NUMBER;
  l_temp                  NUMBER;
  l_bsl_count             NUMBER;
  l_total_min_qty         NUMBER;
  l_total_bill_qty        NUMBER;
  l_called_From           NUMBER;
  l_counter_value         NUMBER;
  l_counter_id            NUMBER;
  l_msg_cnt               NUMBER;
  l_est_period_start_rdg  NUMBER;
  l_counter_date          DATE;
  l_cov_start_date        DATE;
  l_cov_end_date          DATE;
  l_cov_prd_start_date    DATE;
  l_cov_prd_end_date      DATE;
  l_temp_qty              NUMBER;
BEGIN

/******
  ------------commented as part of bug# 5178204
  IF (p_settle_interval = 'BILLING PERIOD') THEN
    l_called_From := 3;  --call counter api for settlement
  ELSE
    l_called_From := 1;  --call counter api for settlement
  END IF;
****/

  IF (p_calledfrom = 3) THEN
    l_cov_prd_end_date    := p_cov_prd_end_date - 1  ;
    l_cov_prd_start_date  := p_cov_prd_start_date    ;
  ELSE
    l_cov_prd_end_date    := p_cov_prd_end_date     ;
    l_cov_prd_start_date  := p_cov_prd_start_date   ;
  END IF;

  X_estimated_qty   := 0;
  l_qty             := 0;


  IF (p_calledfrom <> 3) OR
     ((p_calledfrom = 3) AND (l_cov_prd_start_date < l_cov_prd_end_date)) THEN

           ------------commented as part of bug# 5178204
           -------------P_CALLEDFROM        => l_called_from,
    COUNTER_VALUES
          (
           P_CALLEDFROM        => p_calledfrom,
           P_START_DATE        => l_cov_prd_start_date,
           P_END_DATE          => l_cov_prd_end_date,
           P_CLE_ID            => p_cle_id,
           P_USAGE_TYPE        => p_usage_type,
           X_VALUE             => l_qty,
           X_COUNTER_VALUE     => l_counter_value,
           X_COUNTER_DATE      => l_counter_date,
           X_UOM_CODE          => l_uom_code,
           X_END_READING       => l_end_reading,
           X_START_READING     => l_start_Reading,
           X_BASE_READING      => l_base_Reading,
           X_COUNTER_VALUE_ID  => l_counter_value_id,
           X_COUNTER_GROUP_ID  => l_counter_group_id,
           X_COUNTER_ID        => l_counter_id,
           X_RETURN_STATUS     => l_return_status
           );
  END IF;

  X_actual_qty  :=  nvl(l_qty,0);
  IF (p_usage_type = 'VRT') THEN
    /*
    IF  (nvl(p_estimation_flag,'N') = 'N' )
                                    AND (p_estimation_method is NULL) THEN
     Above condition is not required as it is defaulted if any of the below
     conditions are not satisfied.
    */

    IF (nvl(p_estimation_flag,'N') = 'N')
                                    AND (p_estimation_method = 'AMCV') THEN

      -------------------------------------------------------------------------
      -- Begin partial period computation logic
      -- Developer Mani Choudhary
      -- Date 12-JUN-2005
      -- Added parameters p_period_type and p_period_start
      -------------------------------------------------------------------------
      OKS_REG_GET_AMCV
        (
         P_CALLEDFROM     => p_calledfrom ,
         X_RETURN_STATUS  => l_return_status,
         P_CLE_ID         => p_cle_id,
         P_COV_START_DATE => p_cov_start_date,
         P_COV_END_DATE   => p_cov_end_date,
         P_COUNTER_DATE   => l_counter_date ,
         P_COUNTER_VALUE  => l_qty,
         P_PERIOD_TYPE    => p_period_type,
         P_PERIOD_START   => p_period_start,
         P_USAGE_PERIOD   => p_usage_period,
         X_VOLUME         => l_estimated_qty
        );
        IF l_return_status <> 'S'  THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      IF ((nvl(l_qty,0) = 0) AND (p_calledfrom in (1,2))) THEN
        --partial periods estimation AMCV
        --------------------------
        IF p_period_type IS NOT NULL AND
           p_period_start IS NOT NULL
        THEN
          l_qty := OKS_TIME_MEASURES_PUB.get_target_qty_service (
                                                        p_start_date   => p_cov_prd_start_date,
                                                        p_end_date     => p_cov_prd_end_date,
                                                        p_price_uom    => p_usage_period,
                                                        p_period_type  => p_period_type,
                                                        p_round_dec    => 18
                                                        );
          --for bug#5334983: no exception needs to be raised-the quantity will be zero
          --IF nvl(l_qty,0) = 0 THEN
          --  RAISE G_EXCEPTION_HALT_VALIDATION;
          --END IF;
          l_qty := Round(l_qty*l_estimated_qty,0);
        ELSE
          l_qty := Round((trunc(p_cov_prd_end_date) -
                        trunc(p_cov_prd_start_date) + 1) * (l_estimated_qty) ,0) ;
        END IF;
        --------------------------
        X_estimated_qty  := l_qty;
      ELSIF  (p_calledfrom = 3 ) THEN
        --IF (l_counter_date is NULL) THEN
        --  l_cov_start_date := p_cov_prd_start_date;
        --  OPEN   l_max_date_end(p_cle_id,p_cov_prd_end_date);
        --  FETCH  l_max_date_end into l_cov_end_date;
        --  CLOSE  l_max_date_end;
        IF (l_counter_date is NOT NULL) THEN
          --l_cov_end_date := p_cov_prd_end_date;
          OPEN   l_min_date_start(p_cle_id,l_counter_date);
          FETCH  l_min_date_start into l_cov_start_date;
          CLOSE  l_min_date_start;

          OPEN   l_max_date_end(p_cle_id,p_cov_prd_end_date);
          FETCH  l_max_date_end into l_cov_end_date;
          CLOSE  l_max_date_end;
          --Partial periods for estimation AMCV
          ---------------------------------
          IF p_period_type IS NOT NULL AND
             p_period_start IS NOT NULL
          THEN
            l_temp_qty := OKS_TIME_MEASURES_PUB.get_target_qty_service (
                                                        p_start_date   => l_cov_start_date,
                                                        p_end_date     => l_cov_end_date,
                                                        p_price_uom    => p_usage_period,
                                                        p_period_type  => p_period_type,
                                                        p_round_dec    => 18
                                                        );
            --for bug#5334983: no exception needs to be raised-the quantity will be zero
            --IF nvl(l_temp_qty,0) = 0 THEN
            --  RAISE G_EXCEPTION_HALT_VALIDATION;
            --END IF;
            l_estimated_qty := Round(l_temp_qty*l_estimated_qty,0);
          ELSE

            l_estimated_qty := Round((trunc(l_cov_end_date) -
                        trunc(l_cov_start_date) + 1) * (l_estimated_qty) ,0) ;
          END IF;
          ---------------------------------
          IF (l_estimated_qty < 0) THEN
            l_estimated_qty := 0;
          END IF;
          l_qty := l_qty + l_estimated_qty;
        END IF;
      END IF;

      x_flag := 'M';

      --X_estimated_qty  := l_qty;

    ELSIF (nvl(p_estimation_flag,'N') = 'N')
                                    AND (p_estimation_method = 'CSR' ) THEN
      IF ((nvl(l_qty,0) = 0) AND (p_calledfrom in (1,2))) THEN
       --CALL COUNTER API HERE to get the estimated qty for the entire period
        CSI_CTR_EST_CTR_READING_GRP.ESTIMATE_COUNTER_READING(
           P_API_VERSION_NUMBER           => 1.0,
           P_INIT_MSG_LIST                => FND_API.G_FALSE,
           P_COMMIT                       => FND_API.G_FALSE,
           P_VALIDATION_LEVEL             => FND_API.G_VALID_LEVEL_FULL,
           P_COUNTER_ID                   => l_counter_id,
           P_ESTIMATION_PERIOD_START_DATE => p_cov_prd_start_date,
           P_ESTIMATION_PERIOD_END_DATE   => p_cov_prd_end_date,
           P_AVG_CALCULATION_START_DATE   => p_usg_est_start_date,
           P_NUMBER_OF_READINGS           => NULL,
           X_ESTIMATED_USAGE_QTY          => l_qty,
           X_ESTIMATED_METER_READING      => l_est_reading,
           X_ESTIMATED_PERIOD_START_RDG   => l_est_period_start_rdg,
           X_RETURN_STATUS                => l_return_status,
           X_MSG_COUNT                    => l_msg_cnt,
           X_MSG_DATA                     => l_msg_data
            );
        X_estimated_qty  := l_qty;
      ELSIF (p_calledfrom = 3) THEN
        /* This elsif is required to estimated during termination */
        IF (l_counter_date is NULL) THEN
          l_cov_start_date := p_cov_prd_start_date;
          OPEN   l_max_date_end(p_cle_id,p_cov_prd_end_date);
          FETCH  l_max_date_end into l_cov_end_date;
          CLOSE  l_max_date_end;
        ELSIF (l_counter_date is NOT NULL) THEN
          --l_cov_end_date := p_cov_prd_end_date;
          OPEN   l_min_date_start(p_cle_id,l_counter_date);
          FETCH  l_min_date_start into l_cov_start_date;
          CLOSE  l_min_date_start;

          OPEN   l_max_date_end(p_cle_id,p_cov_prd_end_date);
          FETCH  l_max_date_end into l_cov_end_date;
          CLOSE  l_max_date_end;

          IF ((l_cov_start_date <  p_usg_est_start_date) AND
            (p_usg_est_start_date <= l_cov_end_date)) THEN
            l_cov_start_date := p_usg_est_start_date + 1 ;
          END IF;
        END IF;


        CSI_CTR_EST_CTR_READING_GRP.ESTIMATE_COUNTER_READING(
           P_API_VERSION_NUMBER           => 1.0,
           P_INIT_MSG_LIST                => FND_API.G_FALSE,
           P_COMMIT                       => FND_API.G_FALSE,
           P_VALIDATION_LEVEL             => FND_API.G_VALID_LEVEL_FULL,
           P_COUNTER_ID                   => l_counter_id,
           P_ESTIMATION_PERIOD_START_DATE => l_cov_start_date,
           P_ESTIMATION_PERIOD_END_DATE   => l_cov_end_date,
           P_AVG_CALCULATION_START_DATE   => p_usg_est_start_date,
           P_NUMBER_OF_READINGS           => NULL,
           X_ESTIMATED_USAGE_QTY          => l_estimated_qty,
           X_ESTIMATED_METER_READING      => l_est_reading,
           X_ESTIMATED_PERIOD_START_RDG   => l_est_period_start_rdg,
           X_RETURN_STATUS                => l_return_status,
           X_MSG_COUNT                    => l_msg_cnt,
           X_MSG_DATA                     => l_msg_data
            );

        X_estimated_qty  := l_estimated_qty;
        l_qty  := nvl(l_qty,0)  +  nvl(l_estimated_qty,0);


      END IF;

    ELSIF (nvl(p_estimation_flag,'N')='Y')
                                    AND (p_estimation_method = 'AMCV') THEN
      IF (nvl(l_qty,0) = 0) THEN
      -------------------------------------------------------------------------
      -- Begin partial period computation logic
      -- Developer Mani Choudhary
      -- Date 12-JUN-2005
      -- Added parameters p_period_type and p_period_start
      -------------------------------------------------------------------------
        OKS_REG_GET_AMCV
          (
           P_CALLEDFROM     => p_calledfrom ,
           X_RETURN_STATUS  => l_return_status,
           P_CLE_ID         => p_cle_id,
           P_COV_START_DATE => p_cov_start_date,
           P_COV_END_DATE   => p_cov_end_date,
           P_COUNTER_DATE   => l_counter_date ,
           P_COUNTER_VALUE  => l_qty,
           P_PERIOD_TYPE    => p_period_type,
           P_PERIOD_START   => p_period_start,
           P_USAGE_PERIOD   => p_usage_period,
           X_VOLUME         => l_estimated_qty
          );
        IF l_return_status <> 'S'  THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

      -- IF called from termination then replace p_cov_end_date by x_counter_date

        IF (p_calledfrom in (1,2)) THEN
          --partial periods estimation AMCV
          --------------------------
          IF p_period_type IS NOT NULL AND
             p_period_start IS NOT NULL
          THEN
            l_qty := OKS_TIME_MEASURES_PUB.get_target_qty_service (
                                                        p_start_date   => p_cov_prd_start_date,
                                                        p_end_date     => p_cov_prd_end_date,
                                                        p_price_uom    => p_usage_period,
                                                        p_period_type  => p_period_type,
                                                        p_round_dec    => 18
                                                        );
            --for bug#5334983: no exception needs to be raised-the quantity will be zero
            --IF nvl(l_qty,0) = 0 THEN
            --  RAISE G_EXCEPTION_HALT_VALIDATION;
            --END IF;
            l_qty := Round(l_qty*l_estimated_qty,0);
          ELSE

            l_qty := Round((trunc(p_cov_prd_end_date) -
                      trunc(p_cov_prd_start_date) + 1) * (l_estimated_qty) ,0) ;
          END IF;
          ------------------------
          X_estimated_qty := l_qty;
        END IF;
      ELSIF (l_counter_date < p_cov_end_date) THEN
      -------------------------------------------------------------------------
      -- Begin partial period computation logic
      -- Developer Mani Choudhary
      -- Date 12-JUN-2005
      -- Added parameters p_period_type and p_period_start
      -------------------------------------------------------------------------
        OKS_REG_GET_AMCV
          (
           P_CALLEDFROM     => p_calledfrom ,
           X_RETURN_STATUS  => l_return_status,
           P_CLE_ID         => p_cle_id,
           P_COV_START_DATE => p_cov_start_date,
           P_COV_END_DATE   => p_cov_end_date,
           P_COUNTER_DATE   => l_counter_date ,
           P_COUNTER_VALUE  => l_qty , --l_counter_value,
           P_PERIOD_TYPE    => p_period_type,
           P_PERIOD_START   => p_period_start,
           P_USAGE_PERIOD   => p_usage_period,
           X_VOLUME         => l_estimated_qty
          );
        IF l_return_status <> 'S'  THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;


        IF (p_calledfrom = 3) THEN
          --Partial periods for estimation AMCV
          ---------------------------------
          IF p_period_type IS NOT NULL AND
             p_period_start IS NOT NULL
          THEN
            --mchoudha fix for bug#5207605
            --Est Start date has to be counter date + 1
            --Est end date has to be termination date -1
            l_temp_qty := OKS_TIME_MEASURES_PUB.get_target_qty_service (
                                                        p_start_date   => l_counter_date+1,
                                                        p_end_date     => p_cov_prd_end_date-1,
                                                        p_price_uom    => p_usage_period,
                                                        p_period_type  => p_period_type,
                                                        p_round_dec    => 18
                                                        );
            --for bug#5334983: no exception needs to be raised-the quantity will be zero
            --IF nvl(l_temp_qty,0) = 0 THEN
            --  RAISE G_EXCEPTION_HALT_VALIDATION;
            --END IF;
            l_estimated_qty := Round(l_temp_qty*l_estimated_qty,0);
          ELSE


            l_estimated_qty := Round( (trunc(p_cov_prd_end_date - 1) -
                        trunc(l_counter_date)  ) * (l_estimated_qty) ,0) ;
          END IF;
          ------------------------------------
          /*
             Est qty cannot be -ve.This may happen if
             counter capture date and termn date is same
          */
          IF (l_estimated_qty < 0) THEN
            l_estimated_qty := 0;
          END IF;
        ELSE
          --Partial periods for estimation AMCV
          ---------------------------------
          IF p_period_type IS NOT NULL AND
             p_period_start IS NOT NULL
          THEN
            --mchoudha fix for bug#5207605
            --Est Start date has to be counter date + 1
            l_temp_qty := OKS_TIME_MEASURES_PUB.get_target_qty_service (
                                                        p_start_date   => l_counter_date+1,
                                                        p_end_date     => p_cov_prd_end_date,
                                                        p_price_uom    => p_usage_period,
                                                        p_period_type  => p_period_type,
                                                        p_round_dec    => 18
                                                        );
            --for bug#5334983: no exception needs to be raised-the quantity will be zero
            --IF nvl(l_temp_qty,0) = 0 THEN
            --  RAISE G_EXCEPTION_HALT_VALIDATION;
            --END IF;

            l_estimated_qty := Round(l_temp_qty*l_estimated_qty,0);
          ELSE


            l_estimated_qty := Round( (trunc(p_cov_prd_end_date  ) -
                        trunc(l_counter_date)  ) * (l_estimated_qty) ,0) ;
          END IF;
          ---------------------------------------
        END IF;
        l_qty :=  nvl(l_qty,0) + nvl(l_estimated_qty,0) ;
        X_estimated_qty := l_estimated_qty;
        x_flag := 'M';

      END IF;
    ELSIF (nvl(p_estimation_flag,'N')='Y')
                                    AND (p_estimation_method = 'CSR') THEN
      IF (P_calledfrom = 3 ) THEN
        l_cov_end_date := p_cov_prd_end_date - 1;   -- Estimation not req for Termination Date
        l_cov_start_date := l_counter_date+ 1;
        IF ((l_cov_start_date <  p_usg_est_start_date) AND
            (p_usg_est_start_date <= l_cov_end_date)) THEN
          l_cov_start_date := p_usg_est_start_date + 1 ;
        END IF;
      ELSE
        l_cov_start_date := l_counter_date+ 1;
        l_cov_end_date   := p_cov_prd_end_date;
      END IF;

      IF (nvl(l_qty,0) = 0) THEN
        CSI_CTR_EST_CTR_READING_GRP.ESTIMATE_COUNTER_READING(
           P_API_VERSION_NUMBER           => 1.0,
           P_INIT_MSG_LIST                => FND_API.G_FALSE,
           P_COMMIT                       => FND_API.G_FALSE,
           P_VALIDATION_LEVEL             => FND_API.G_VALID_LEVEL_FULL,
           P_COUNTER_ID                   => l_counter_id,
           P_ESTIMATION_PERIOD_START_DATE => p_cov_prd_start_date,
           P_ESTIMATION_PERIOD_END_DATE   => l_cov_end_date,
           P_AVG_CALCULATION_START_DATE   => p_usg_est_start_date,
           P_NUMBER_OF_READINGS           => NULL,
           X_ESTIMATED_USAGE_QTY          => l_qty,
           X_ESTIMATED_METER_READING      => l_est_reading,
           X_ESTIMATED_PERIOD_START_RDG   => l_est_period_start_rdg,
           X_RETURN_STATUS                => l_return_status,
           X_MSG_COUNT                    => l_msg_cnt,
           X_MSG_DATA                     => l_msg_data
            );

        X_estimated_qty  := l_qty;
       --CALL COUNTER API HERE to get the estimated qty for the entire period
      ELSIF (l_counter_date < p_cov_end_date) THEN
        CSI_CTR_EST_CTR_READING_GRP.ESTIMATE_COUNTER_READING(
           P_API_VERSION_NUMBER           => 1.0,
           P_INIT_MSG_LIST                => FND_API.G_FALSE,
           P_COMMIT                       => FND_API.G_FALSE,
           P_VALIDATION_LEVEL             => FND_API.G_VALID_LEVEL_FULL,
           P_COUNTER_ID                   => l_counter_id,
           P_ESTIMATION_PERIOD_START_DATE => l_cov_start_date,
           P_ESTIMATION_PERIOD_END_DATE   => l_cov_end_date,
           P_AVG_CALCULATION_START_DATE   => p_usg_est_start_date,
           P_NUMBER_OF_READINGS           => NULL,
           X_ESTIMATED_USAGE_QTY          => l_estimated_qty,
           X_ESTIMATED_METER_READING      => l_est_reading,
           X_ESTIMATED_PERIOD_START_RDG   => l_est_period_start_rdg,
           X_RETURN_STATUS                => l_return_status,
           X_MSG_COUNT                    => l_msg_cnt,
           X_MSG_DATA                     => l_msg_data
            );

        l_qty := nvl(l_qty,0) + nvl(l_estimated_qty,0);
        X_estimated_qty  := l_estimated_qty;
       --CALL COUNTER API HERE to get the estimated qty for the partial period
       -- Add estimated partial qty to l_qty
      END IF;
    END IF;

    /*Doing Settlement Here in Billing*/
    IF ((p_settle_interval = 'BP') AND (nvl(x_actual_qty,0) <> 0)) THEN
      OPEN   billed_period_csr(p_cle_id);
      FETCH  billed_period_csr  INTO l_bsl_count;
      CLOSE  billed_period_csr;

      l_total_min_qty := l_bsl_count * p_minimum_quantity;

      OPEN  total_billed_qty(p_cle_id);
      FETCH total_billed_qty  INTO l_total_bill_qty;
      CLOSE total_billed_qty;

      --IF (nvl(l_total_min_qty,0) > nvl(l_counter_value,0)  ) THEN
      IF (l_end_reading < l_base_reading) THEN
        X_flag := 'S';
        IF ( l_total_min_qty > l_base_reading) THEN
          l_qty  := l_total_min_qty - l_base_reading;
          X_flag := 'S';
          --l_end_reading := l_base_reading;
        ELSE
          --IF (l_base_reading < l_total_min_qty) THEN
          --  l_qty  :=  l_base_reading - l_total_min_qty;
          --  X_flag := 'S';
          --ELSE
            --l_qty  :=  l_end_reading - l_base_reading;
          IF (l_end_reading < l_total_min_qty) THEN
            l_qty  :=  l_total_min_qty - l_base_reading;
            X_flag := 'S';
          END IF;
          --l_end_reading := l_base_reading;
          --END IF;
        END IF;
      END IF;
      --END IF;
    END IF;
  END IF;

  /*
    If l_qty is zero after doing estimation and reading counter , then
    set l_qty to default_qty
  */
  -- BUG FIX 3519287 .Added QTY condition
  IF (nvl(l_qty,0) = 0) THEN
    IF((l_counter_date IS NULL) OR (p_usage_type = 'QTY')) THEN
      l_qty  := nvl(p_default_qty,0);
      x_flag := 'D';
    ELSE
      l_qty := 0;
    END IF;
  END IF;

  --IF ((p_calledfrom = 1) OR
  --   ((p_calledfrom = 3) AND ( x_flag = 'D'))) THEN

  IF ( x_flag = 'D') THEN
    -------------------------------------------------------------------------
    -- Begin partial period computation logic
    -- Developer Mani Choudhary
    -- Date 11-JUN-2005
    -- call oks_bill_rec_pub.Get_prorated_Usage_Qty to get the prorated usage
    -------------------------------------------------------------------------
    IF p_period_type IS NOT NULL AND
       p_period_start IS NOT NULL
    THEN
        OPEN l_Billuom_csr(p_cov_prd_end_date);
        FETCH l_Billuom_csr INTO l_uom_code;
        CLOSE l_Billuom_csr;
        IF (p_calledfrom = 3) THEN

          l_qty := OKS_BILL_REC_PUB.Get_Prorated_Usage_Qty
                       (
                       p_start_date  => p_cov_prd_start_date,
                       p_end_date    => p_cov_prd_end_date-1,
                       p_qty         => l_qty,
                       p_usage_uom   => p_usage_period,
                       p_billing_uom => l_uom_code,
                       p_period_type => p_period_type
                               );
          --for bug#5334983: no exception needs to be raised-the quantity will be zero
          --IF nvl(l_qty,0) = 0 THEN
          --  RAISE G_EXCEPTION_HALT_VALIDATION;
          --END IF;
        ELSE
          l_qty := OKS_BILL_REC_PUB.Get_Prorated_Usage_Qty
                       (
                       p_start_date  => p_cov_prd_start_date,
                       p_end_date    => p_cov_prd_end_date,
                       p_qty         => l_qty,
                       p_usage_uom   => p_usage_period,
                       p_billing_uom => l_uom_code,
                       p_period_type => p_period_type
                               );
          --for bug#5334983: no exception needs to be raised-the quantity will be zero
          --IF nvl(l_qty,0) = 0 THEN
          --  RAISE G_EXCEPTION_HALT_VALIDATION;
          --END IF;

        END IF;

        l_qty:= Round(l_qty,0);
    ELSE
        --Existing logic
        l_temp := OKS_TIME_MEASURES_PUB.GET_TARGET_QTY
                               (
                               p_start_date  => p_cov_prd_start_date,
                               p_source_qty  => 1,
                               p_source_uom  => p_usage_period,
                               p_target_uom  => p_time_uom_code,
                               p_round_dec   => 0
                               );
/* Added p_calledfrom =2 by sjanakir as part of Bug# 6697952 */
       IF (p_calledfrom = 1 OR p_calledfrom =2) THEN

         l_qty := Round((l_qty * (p_cov_prd_end_date -
                             p_cov_prd_start_date + 1))/l_temp ,0) ;

       ELSIF (p_calledfrom = 3) THEN

         l_qty := Round((l_qty * (p_cov_prd_end_date -
                             p_cov_prd_start_date ))/l_temp ,0) ;
       END IF;
    END IF;  --period type and period start are not NULL
  END IF;

  l_billing_based_on  := fnd_profile.value('OKS_USAGE_BILLING_BASED_ON');

  X_qty               :=  nvl(l_qty,0);
  x_start_reading     := l_start_reading;
  IF(l_billing_based_on  = 'A') THEN
    x_end_reading       := nvl(l_end_reading,0)+ nvl(x_estimated_qty,0);
  ELSE
    x_end_reading       := nvl(l_end_reading,0);
  END IF;
  x_counter_value_id  := l_counter_value_id;
  x_counter_group_id  := l_counter_group_id;
  x_base_reading      := nvl(l_base_Reading,0);

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    x_return_status := OKC_API.G_RET_STS_ERROR ;
  WHEN OTHERS THEN
     x_return_status := OKC_API.G_RET_STS_ERROR ;
END Usage_qty_to_bill;

--------------------------------------------------------------------------------
                           -- COunter_values
-------------------------------------------------------------------------------
Procedure Counter_Values
 (
  P_calledfrom        IN                NUMBER DEFAULT NULL,
  P_start_date        IN                DATE,
  P_end_date          IN                DATE,
  P_cle_id            IN                NUMBER,
  P_Usage_type        IN                VARCHAR2,
  X_Value            OUT        NOCOPY  NUMBER,
  X_Counter_Value    OUT        NOCOPY  NUMBER,
  X_Counter_Date     OUT        NOCOPY  DATE,
  X_Uom_Code         OUT        NOCOPY  VARCHAR2,
  X_end_reading      OUT        NOCOPY  NUMBER,
  X_start_reading    OUT        NOCOPY  NUMBER,
  X_base_reading     OUT        NOCOPY  NUMBER,
  X_counter_value_id OUT        NOCOPY  NUMBER,
  X_counter_group_id OUT        NOCOPY  NUMBER,
  X_counter_id       OUT        NOCOPY  NUMBER,
  X_return_status    OUT        NOCOPY  VARCHAR2
 )
 Is
Cursor l_ctr_csr(p_counter_id Number,p_override_valid_flag VARCHAR)  Is
  SELECT  net_reading
         ,value_timestamp
         ,counter_value_id
         ,counter_group_id
       FROM   Cs_ctr_counter_values_v
       WHERE  counter_id = p_counter_id
       AND    decode(p_override_valid_flag,'YES',nvl(override_valid_flag,'N'),'1') = decode(p_override_valid_flag,'YES','Y','1')
       AND    nvl(valid_flag,'N') = 'N'
       /* Modified by sjanakir for Bug # 7168765
       Order by value_timestamp desc; */
       ORDER BY counter_value_id DESC;


 l_ctr_rec    l_ctr_csr%rowtype;

Cursor l_actual_counter_csr(p_cle_id IN NUMBER) Is
  SELECT  nvl(end_reading,0)  qty
        FROM    Oks_bill_sub_line_dtls ldtl
                ,oks_bill_sub_lines line
        WHERE   line.cle_id = p_cle_id
        AND     ldtl.bsl_id = line.id
        AND     nvl(end_reading,0) > 0
        AND     trunc(date_billed_from) < trunc(p_start_date)
        Order By date_billed_to desc ;

Cursor l_actual_counter_csr_prv (p_cle_id IN NUMBER , p_start_date IN DATE) IS
  SELECT  nvl(end_reading,0) qty
       FROM    Oks_bsd_pr ldtl
              ,oks_bsl_pr line
       WHERE   line.cle_id = p_cle_id
       AND     ldtl.bsl_id = line.id
       AND     nvl(end_reading,0) > 0
       AND     trunc(date_billed_from) < trunc(p_start_date)
       Order By date_billed_to desc ,ldtl.creation_date  desc ;


Cursor l_actual_csr(p_cle_id IN NUMBER) Is
  SELECT NVL(sign(ldtl.amount)*Result,0) + nvl(base_reading,0)  qty
       FROM    Oks_bill_sub_line_dtls ldtl
              ,oks_bill_sub_lines line
       WHERE   line.cle_id = p_cle_id
       AND     ldtl.bsl_id = line.id
       ORDER BY date_billed_to desc  ;



Cursor l_actual_csr_prv(p_cle_id IN NUMBER) Is
  SELECT  NVL(sign(ldtl.amount)*Result,0) +  nvl(base_reading,0)  qty
       FROM    Oks_bsd_pr         ldtl
              ,oks_bsl_pr         line
       WHERE   line.cle_id = p_cle_id
       AND     ldtl.bsl_id = line.id
       ORDER BY date_billed_to desc;


Cursor l_ccr_id_csr Is
  SELECT end_reading read,ccr_id,cgr_id
       FROM    Oks_bill_sub_line_dtls ldtl
                ,oks_bill_sub_lines line
        WHERE   line.cle_id = p_cle_id
        AND     ldtl.bsl_id = line.id
-- Bug#4730007 nechatur 1-Dec-2005
       -- Order By ldtl.id desc;
          Order By date_billed_to desc ;
-- End Bug#4730007


Cursor l_ccr_id_csr_prv (p_cle_id IN NUMBER , p_start_date IN DATE) IS
  SELECT end_reading read,ccr_id,cgr_id
      FROM    Oks_bsd_pr ldtl
                   ,oks_bsl_pr line
      WHERE   line.cle_id = p_cle_id
      AND     ldtl.bsl_id = line.id
      AND     trunc(line.date_billed_from) < trunc(p_start_date)
-- Bug#4730007 nechatur 1-Dec-2005
       -- Order By ldtl.id desc;
          Order By date_billed_to desc ;
-- End Bug#4730007


Cursor l_initial_csr Is
  SELECT nvl(base_Reading,0)  Base_reading
     FROM oks_k_lines_b
     WHERE cle_id = p_cle_id;


Cursor l_ctr_value_csr(p_counter_id Number,p_override_valid_flag Varchar) Is
  SELECT  Max(ccr.counter_value_id)
       FROM   Cs_ctr_counter_values_v ccr
       WHERE  ccr.counter_id = p_counter_id
       AND     trunc(ccr.Value_timestamp)  Between trunc(P_start_date) And trunc(P_end_date)
       AND    decode(p_override_valid_flag,'YES',ccr.override_valid_flag,'1') =
              decode(p_override_valid_flag,'YES','Y','1')
       AND    nvl(valid_flag,'N') = 'N';


Cursor l_value_csr(p_max_ctr_id Number) Is
   SELECT  net_reading
          ,counter_group_id
          ,value_timestamp
       FROM   Cs_ctr_counter_values_v
       WHERE  counter_value_id = p_max_ctr_id
       AND    nvl(valid_flag,'N') = 'N';




Cursor l_ctr_daily_csr(p_counter_id Number,p_override_valid_flag Varchar)  Is
    SELECT  Max(ccr.counter_value_id)
       FROM   Cs_ctr_counter_values_v ccr
       WHERE  ccr.counter_id = p_counter_id
       AND     trunc(ccr.Value_timestamp) = trunc(P_start_date)
       AND    decode(p_override_valid_flag,'YES',ccr.override_valid_flag,'1') =
              decode(p_override_valid_flag,'YES','Y','1')
       AND    nvl(valid_flag,'N') = 'N';

Cursor inv_item_csr Is
    SELECT item.object1_id1
    FROM   OKC_K_ITEMS item
    WHERE  item.cle_id = p_cle_id;

Cursor uom_csr(p_counter_id Number) Is
    SELECT uom_code
    FROM   CSI_COUNTERS_BC_V             /*Added for bug:9226166*/
    WHERE counter_id = p_counter_id;

 --Bug#5235116

Cursor l_actual_term_csr(p_cle_id IN NUMBER) Is
  SELECT NVL(sign(ldtl.amount)*Result,0) + nvl(base_reading,0)  qty
       FROM    Oks_bill_sub_line_dtls ldtl
              ,oks_bill_sub_lines line
       WHERE   line.cle_id = p_cle_id
       AND     ldtl.bsl_id = line.id
       AND    trunc(date_billed_from) < trunc(p_start_date)
       ORDER BY date_billed_to desc;

 --End Bug#5235116

 l_counter_qty             NUMBER;
 l_qty                     NUMBER;
 l_init                    NUMBER;
 l_inv_rec                 INV_ITEM_CSR%ROWTYPE;
 l_max_ctr_id              NUMBER;
 l_ctr_grp_id              NUMBER;
 l_end_read                NUMBER;
 l_ccr_id                  NUMBER;
 l_cgr_id                  NUMBER;
 l_counter_validate_flag   VARCHAR2(4);
 l_billing_based_on        VARCHAR2(15);
 l_value_timestamp         DATE;
BEGIN
  X_return_status := OKC_API.G_RET_STS_SUCCESS;

  l_counter_validate_flag := fnd_profile.value('OKS_COUNTER_VALIDATE');
  l_billing_based_on      := fnd_profile.value('OKS_USAGE_BILLING_BASED_ON');

  OPEN  inv_item_csr;
  FETCH inv_item_csr into l_inv_rec;
  CLOSE inv_item_csr;

  x_counter_id  := l_inv_rec.object1_id1;

  --Bug#5235116
 /*****************************
  IF (p_calledfrom = 3) THEN
    --Called from Settlement
    OPEN  l_actual_csr(p_cle_id);
    FETCH l_actual_csr into l_qty;
    CLOSE l_actual_csr;

    OPEN  l_ccr_id_csr;
    FETCH l_ccr_id_csr into l_end_read,l_ccr_id,l_cgr_id;
    CLOSE l_ccr_id_csr;

    OPEN  l_initial_csr;
    FETCH l_initial_csr into l_init;
    CLOSE l_initial_csr;

*******************************/

  IF (p_calledfrom = 4) THEN  -- Changed '3' to '4' -- '3' refers to termination and '4' refers to settlement
    /* Called from Settlement */
    OPEN  l_actual_csr(p_cle_id);
    FETCH l_actual_csr into l_qty;
    CLOSE l_actual_csr;

    OPEN  l_ccr_id_csr;
    FETCH l_ccr_id_csr into l_end_read,l_ccr_id,l_cgr_id;
    CLOSE l_ccr_id_csr;

    OPEN  l_initial_csr;
    FETCH l_initial_csr into l_init;
    CLOSE l_initial_csr;

  ELSIF (p_calledfrom = 3) THEN
   --Called from termination
    OPEN  l_actual_term_csr(p_cle_id);
    FETCH l_actual_term_csr into l_qty;
    CLOSE l_actual_term_csr;

    OPEN  l_ccr_id_csr;
    FETCH l_ccr_id_csr into l_end_read,l_ccr_id,l_cgr_id;
    CLOSE l_ccr_id_csr;

    OPEN  l_initial_csr;
    FETCH l_initial_csr into l_init;
    CLOSE l_initial_csr;

 --End Bug#5235116

  ELSIF (p_calledfrom = 1) THEN
    IF ( nvl(l_billing_based_on,'X') = 'A') THEN
      OPEN  l_actual_csr(p_cle_id);
      FETCH l_actual_csr into l_qty;
      CLOSE l_actual_csr;
    ELSE
      OPEN  l_actual_counter_csr(p_cle_id);
      FETCH l_actual_counter_csr into l_qty;
      CLOSE l_actual_counter_csr;
    END IF;

    OPEN  l_ccr_id_csr;
    FETCH l_ccr_id_csr into l_end_read,l_ccr_id,l_cgr_id;
    CLOSE l_ccr_id_csr;

    OPEN  l_initial_csr;
    FETCH l_initial_csr into l_init;
    CLOSE l_initial_csr;

  ELSIF (P_calledfrom = 2) THEN
    /* l_actual_csr and l_ccr_id_csr of normal mode is required to be called
       in preview mode also.This is necessary because user may run JAN
       billing in actual mode and then run feb billing in preview mode.
       If the call to l_actual_csr and l_ccr_id_csr is not made then preview
       mode does not reflect proper reading
     */

    IF ( nvl(l_billing_based_on,'X') = 'A') THEN
      OPEN  l_actual_csr_prv(p_cle_id);
      FETCH l_actual_csr_prv into l_qty;
      CLOSE l_actual_csr_prv;
    ELSE
      OPEN  l_actual_counter_csr_prv(p_cle_id,p_start_date);
      FETCH l_actual_counter_csr_prv into l_qty;
      CLOSE l_actual_counter_csr_prv;
    END IF;

    IF (l_qty is NULL) THEN
      IF ( nvl(l_billing_based_on,'X') = 'A') THEN
        OPEN  l_actual_csr(p_cle_id);
        FETCH l_actual_csr into l_qty;
        CLOSE l_actual_csr;
      ELSE
        OPEN  l_actual_counter_csr(p_cle_id);
        FETCH l_actual_counter_csr into l_qty;
        CLOSE l_actual_counter_csr;
      END IF;
    END IF;

    OPEN  l_ccr_id_csr_prv (p_cle_id,p_start_date);
    FETCH l_ccr_id_csr_prv into l_end_read,l_ccr_id,l_cgr_id;
    CLOSE l_ccr_id_csr_prv;

    IF (l_end_read is NULL) THEN
      OPEN  l_ccr_id_csr ;
      FETCH l_ccr_id_csr INTO l_end_read,l_ccr_id ,l_cgr_id;
      CLOSE l_ccr_id_csr;
    END IF;

    OPEN  l_initial_csr;
    FETCH l_initial_csr into l_init;
    CLOSE l_initial_csr;

  END IF;


  OPEN  uom_csr(l_inv_rec.object1_id1);
  FETCH uom_csr into X_uom_code;
  CLOSE Uom_csr;

  IF (P_Usage_type = 'QTY') THEN

    OPEN  l_ctr_csr(l_inv_rec.object1_id1,l_counter_validate_flag);
    FETCH l_ctr_csr into l_ctr_rec;
    CLOSE l_ctr_csr;

    IF (l_ctr_rec.net_reading Is Null) THEN
      X_Value := 0; -- Null;

    ELSE
      IF ( l_ccr_id Is Not Null) THEN
        IF l_ctr_rec.counter_value_id = l_ccr_id THEN
          X_value := 0 ;
          IF ( nvl(l_qty,0) = 0  ) THEN
            X_base_reading     := nvl(l_init,0) ;
          ELSE
            X_base_reading     := nvl(l_qty,0) ;
          END IF;
        ELSE
          --IF ( l_qty is NULL) THEN
          IF ( nvl(l_qty,0) = 0 ) THEN
            X_value := nvl(l_ctr_rec.net_reading,0)  -  nvl(l_init,0);
            X_base_reading     := nvl(l_init,0) ;
          ELSE
            X_value := nvl(l_ctr_rec.net_reading,0)  - nvl(l_qty,0);
            X_base_reading     := nvl(l_qty,0) ;
          END IF;
        END IF;
      ELSE
        --IF ( l_qty is NULL) THEN
        IF ( nvl(l_qty,0) = 0 ) THEN
          X_value := nvl(l_ctr_rec.net_reading,0) -  nvl(l_init,0);
          X_base_reading     := nvl(l_init,0) ;
        ELSE
          X_value := nvl(l_ctr_rec.net_reading,0) - nvl(l_qty,0);
          X_base_reading     := nvl(l_qty,0) ;
        END IF;

      END IF;
    END IF;

    X_start_reading    := nvl(l_end_read,l_init);
    X_end_reading      := nvl(l_ctr_rec.net_reading,nvl(l_end_read,l_init));
    X_counter_value_id := nvl(l_ctr_rec.counter_value_id,l_ccr_id);
    X_counter_group_id := nvl(l_ctr_rec.counter_group_id,l_cgr_id);
    X_Counter_Date     := l_ctr_rec.value_timestamp;
    X_Counter_Value    := nvl(l_ctr_rec.net_reading,0);

  ELSIF (P_Usage_type = 'VRT')  Then

    IF (Trunc(P_start_date) = Trunc(P_end_date))  THEN
      OPEN  l_ctr_daily_csr(l_inv_rec.object1_id1,l_counter_validate_flag);
      FETCH l_ctr_daily_csr into l_max_ctr_id;
      IF (l_ctr_daily_csr%notfound) THEN
        l_max_ctr_id := Null;
      END IF;
      CLOSE l_ctr_daily_csr;
      IF (l_max_ctr_id is not null)  THEN
        OPEN  l_value_csr(l_max_ctr_id);
        FETCH l_value_csr into l_counter_qty ,l_ctr_grp_id,l_value_timestamp;
        CLOSE l_value_csr;
      END IF;

    ELSE
      l_max_ctr_id := NULL;
      OPEN  l_ctr_value_csr(l_inv_rec.object1_id1,l_counter_validate_flag);
      FETCH l_ctr_value_csr into l_max_ctr_id;
      IF (l_ctr_value_csr%notfound)  THEN
        l_max_ctr_id := Null;
      END IF;
      CLOSE l_ctr_value_csr;

      IF (l_max_ctr_id is not null)  THEN
        OPEN  l_value_csr(l_max_ctr_id);
        FETCH l_value_csr into l_counter_qty ,l_ctr_grp_id,l_value_timestamp;
        CLOSE l_value_csr;
      END IF;
    END IF;

    IF (l_max_ctr_id Is Null) THEN
      X_value := 0 ;
      IF ( nvl(l_qty,0) = 0  ) THEN
        X_base_reading     := nvl(l_init,0) ;
      ELSE
        X_base_reading     := nvl(l_qty,0) ;
      END IF;
    ELSE
      --IF (l_qty is NULL ) THEN
      IF ( nvl(l_qty,0) = 0 ) THEN
        X_value := nvl(l_counter_qty,0)  - nvl(l_init,0);
        X_base_reading     := nvl(l_init,0) ;
      ELSE
        X_value := nvl(l_counter_qty,0)  - nvl(l_qty,0);
        X_base_reading     := nvl(l_qty,0) ;
      END IF;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'counter '||l_counter_qty);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_qty '||l_qty);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_init '||l_init);
    X_start_reading := nvl(l_end_read,l_init);
    /* Counter values should not be honored till it is greater than intial reading */
    IF ( nvl(l_counter_qty,0) < nvl(l_init,0)) THEN
      X_end_reading   := nvl(l_end_read,nvl(l_init,0));
      X_Value         := 0;
    ELSE
      X_end_reading   := nvl(l_counter_qty,nvl(l_end_read,l_init));
    END IF;
    X_counter_value_id := nvl(l_max_ctr_id,l_ccr_id);
    X_counter_group_id := nvl(l_ctr_grp_id , l_cgr_id);
    X_Counter_Date     := l_value_timestamp;
    X_Counter_Value    := nvl(l_counter_qty,0);

  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
END counter_values;



  ---------------------------------------------------------------------------
  -- FUNCTION get_bill_amount_period
  ---------------------------------------------------------------------------

  PROCEDURE get_bill_amount_period (
    P_CALLEDFROM                   IN          NUMBER,
    p_con_start_date               IN          DATE,
    p_con_end_date                 IN          DATE,
    p_bill_calc_period             IN          VARCHAR2,
    p_con_amount                   IN          NUMBER,
    p_bill_start_date              IN          DATE,
    p_bill_end_date                IN          DATE,
    p_stat                         IN          NUMBER,
    x_amount                       OUT NOCOPY  NUMBER
  ) IS
    l_bill_amount           NUMBER ;
    l_bill_amount1          NUMBER ;
    l_diff                  NUMBER;
    l_diff1                 NUMBER;
    l_bill_calc_period      VARCHAR2(20);
    l_num_of_full_periods   NUMBER := 0;
    l_remainder             NUMBER;
    l_prorate_amount        NUMBER;

Cursor l_uom_csr(p_code Varchar2) Is
      Select tce_code
             ,quantity
      From   Okc_time_code_units_v
      Where  uom_code = p_code
      And    active_flag = 'Y';

l_tce_code   varchar2(10);
l_qty        number;

BEGIN
  OPEN  l_uom_csr(p_bill_calc_period);
  FETCH l_uom_csr into l_tce_code,l_qty;
  CLOSE l_uom_csr;

  IF ( p_stat = G_NONREGULAR)  THEN
    l_tce_code  := 'DAY';
    l_qty := 1;
  END IF;

  IF( p_bill_calc_period is Null) THEN
    l_diff := 1;

  ELSE
    IF ((UPPER(l_tce_code) = 'MONTH') And (l_qty = 1)) THEN
      l_num_of_full_periods := trunc(Months_between((p_con_end_date+1),p_bill_start_date));
      l_diff := abs(trunc((p_con_end_date+1) - add_months(p_bill_start_date,l_num_of_full_periods)));
    ELSIF ((UPPER(l_tce_code) = 'DAY')   and (l_qty = 7)) THEN
      l_num_of_full_periods := TRUNC(((p_con_end_date+1) - p_bill_start_date)/l_qty);
      l_diff := abs(trunc((p_con_end_date + 1) -(p_bill_start_date + (l_num_of_full_periods*l_qty))));
    ELSIF ((UPPER(l_tce_code) = 'DAY') and (l_qty = 1)) THEN
      l_num_of_full_periods := 0;
      l_diff := abs(TRUNC(p_con_end_date - p_bill_start_date)) + 1;
    ELSIF ((UPPER(l_tce_code) = 'MONTH') And (l_qty = 3)) THEN
      l_num_of_full_periods := TRUNC(TRUNC(Months_between(p_con_end_date+1,p_bill_start_date))/l_qty);
      l_diff := abs(trunc((p_con_end_date+1) - add_months(p_bill_start_date,(l_num_of_full_periods*l_qty))));

    ELSIF (( UPPER(l_tce_code) = 'YEAR') And (l_qty = 1)) THEN
      l_num_of_full_periods := TRUNC(TRUNC(Months_between((p_con_end_date+1),p_bill_start_date))/12);
      l_diff := abs(trunc((p_con_end_date+1) - add_months(p_bill_start_date,(l_num_of_full_periods*12))));
    END IF;
  END IF;


  IF ( nvl(P_CALLEDFROM,0) = -99)  THEN   --- for termination
    l_prorate_amount :=p_con_amount/abs(trunc((p_bill_start_date - p_con_end_date ) +1));
  ELSE
    l_prorate_amount :=p_con_amount/abs(trunc((p_con_end_date - p_bill_start_date) +1));
  END IF;

  IF (l_num_of_full_periods = 0) THEN
    l_diff :=  abs(trunc((p_bill_end_date  -  p_bill_start_date) )) + 1;
    l_bill_amount := (l_prorate_amount * l_diff);
  ELSE
    l_bill_amount := (p_con_amount - (l_prorate_amount * l_diff))/l_num_of_full_periods;
  END IF;

    --FND_FILE.PUT_LINE(FND_FILE.LOG,'bill_amount '||l_bill_amount);

  IF (p_stat = Null)  THEN
    x_amount := Null;
  END If;

  x_amount := l_bill_amount;

EXCEPTION
   WHEN  OTHERS THEN
    Null;
    OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN,SQLERRM);
END get_bill_amount_period;


------------------------------------------------------------------------
  -- FUNCTION update_bsl
------------------------------------------------------------------------
PROCEDURE update_bsl
(
   x_ret_stat       OUT NOCOPY  VARCHAR2,
   p_dnz_chr_id     IN          NUMBER,
   p_bsl_id         IN          NUMBER,
   p_bcl_id         IN          NUMBER,
   P_AMOUNT         IN          NUMBER,
   P_currency_code  IN          Varchar2,
   P_PRV            IN          NUMBER
) IS

l_amount_holder      NUMBER       := 0;
l_cur_holder         VARCHAR2(10) ;

round_amount NUMBER  := 0;
l_euro_conversion    VARCHAR2(10);
l_euro_currency_code VARCHAR2(10);
l_con_rate           NUMBER;
l_con_date           DATE;
l_con_type           VARCHAR2(20);
cvn_not_found        EXCEPTION;

Cursor l_get_conversion_rule (p_chr_id IN NUMBER) is
 SELECT conversion_rate        con_rate,
        conversion_rate_date   con_date,
        conversion_type        con_type
    FROM okc_k_headers_b
    WHERE id = p_chr_id;


BEGIN

  x_ret_stat := 'S';

  l_euro_conversion := okc_currency_api.IS_EURO_CONVERSION_NEEDED
                                                   (p_currency_code);

  IF (l_euro_conversion = 'Y') Then
    OPEN  l_get_conversion_rule(p_dnz_chr_id);
    FETCH l_get_conversion_rule into l_con_rate,l_con_date,l_con_type;
    IF (l_get_conversion_rule%NOTFOUND) THEN
      RAISE  cvn_not_found;
    END IF;
    CLOSE l_get_conversion_rule;

    l_euro_currency_code :=okc_currency_api.GET_EURO_CURRENCY_CODE
                                                   (p_currency_code);
  END IF;

  round_amount := 0;

  IF (l_euro_conversion = 'Y') THEN

    l_cur_holder   := l_euro_currency_code;
    okc_currency_api.CONVERT_AMOUNT
           (P_FROM_CURRENCY         => p_currency_code,
            P_TO_CURRENCY           => l_euro_currency_code,
            P_CONVERSION_DATE       => l_con_date,
            P_CONVERSION_TYPE       => l_con_type,
            P_AMOUNT                => abs(P_AMOUNT) ,
            X_CONVERSION_RATE       => l_con_rate   ,
            X_CONVERTED_AMOUNT      => l_amount_holder
            );


      ---Added as passing abs val to convert_amount
        IF nvl(p_AMOUNT,0) < 0  Then
           l_amount_holder := -1 * l_amount_holder;
        END IF;

  ELSE
    l_amount_holder :=   P_AMOUNT;
    l_cur_holder    :=   p_currency_code;
  END IF;

  /**
            * function added to round off the amount depending on the
            * precision set in fnd_currency  -- Hari 08/03/2001
  **/

  round_amount := OKS_EXTWAR_UTIL_PVT.round_currency_amt(
                                                 l_amount_holder,
                                                 l_cur_holder );


  IF (P_PRV = 1 ) THEN

    UPDATE oks_bill_cont_lines
    SET    amount = nvl(amount,0) + round_amount,
           currency_code = l_cur_holder
    WHERE id = p_bcl_id;

    UPDATE oks_bill_sub_lines
    SET    amount = round_amount,
           average = 0
    WHERE id = p_bsl_id;

    UPDATE oks_bill_sub_line_dtls
    SET    amount = round_amount
    WHERE bsl_id = p_bsl_id;

  ELSIF (P_PRV = 2) THEN

    UPDATE oks_bcl_pr
    SET    amount = nvl(amount,0) + round_amount,
           currency_code = l_cur_holder
    WHERE id = p_bcl_id;

    UPDATE oks_bsl_pr
    SET    amount = round_amount,
           average = 0
    WHERE id = p_bsl_id;

    UPDATE oks_bsd_pr
    SET    amount = round_amount
    WHERE bsl_id = p_bsl_id;

  END IF;

EXCEPTION
 WHEN  cvn_not_found  THEN
   x_ret_stat := 'E';
 WHEN  OTHERS THEN
   x_ret_stat := 'E';
   OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN,SQLERRM);

END update_bsl;


------------------------------------------------------------------------
  -- FUNCTION update_bcl
------------------------------------------------------------------------
PROCEDURE update_bcl
(
   P_CALLEDFROM     IN          NUMBER,
   x_ret_stat       OUT NOCOPY  VARCHAR2,
   p_bcl_id         IN          NUMBER,
   P_SENT_YN        IN          VARCHAR2,
   P_BILL_ACTION    IN          VARCHAR2,
   P_AMOUNT         IN          NUMBER,
   P_CURRENCY_CODE  IN          VARCHAR2,
   P_PRV            IN          NUMBER
) IS

SUBTYPE l_bclv_tbl_type_in  is OKS_bcl_PVT.bclv_tbl_type;
l_bclv_tbl_in    l_bclv_tbl_type_in;
l_bclv_tbl_out   l_bclv_tbl_type_in;

SUBTYPE l_bcl_pr_tbl_type  is OKS_BCL_PRINT_PREVIEW_PVT.bcl_pr_tbl_type;
l_bcl_pr_tbl_in    l_bcl_pr_tbl_type;
l_bcl_pr_tbl_out   l_bcl_pr_tbl_type;

l_ret_stat       Varchar2(20);
l_msg_cnt        Number;
l_msg_data       Varchar2(2000);

BEGIN


  IF (P_PRV = 1 ) THEN
    l_bclv_tbl_in(1).ID                    := p_bcl_id;
    l_bclv_tbl_in(1).currency_code         := p_currency_code;

    IF (p_amount IS not Null) THEN
      l_bclv_tbl_in(1).AMOUNT := nvl(p_amount,0);
    END If;
    IF (p_bill_action IS not Null) THEN
      l_bclv_tbl_in(1).bill_action := G_billaction_tr;
    END If;
    IF (p_sent_yn IS not Null)  THEN
      l_bclv_tbl_in(1).sent_yn := p_sent_yn;
    END If;

    UPDATE oks_bill_cont_lines
    SET    amount = nvl(p_amount,0) + nvl(amount,0),
           bill_Action = nvl(p_bill_action,bill_action) ,
           currency_code = p_currency_code,
           sent_yn     = nvl(p_sent_yn , sent_yn)
      WHERE id = l_bclv_tbl_in(1).ID   ;


  ELSIF (P_PRV = 2) THEN
    l_bcl_pr_tbl_in(1).ID                    := p_bcl_id;

    IF (p_amount IS not Null)  THEN
      l_bcl_pr_tbl_in(1).AMOUNT := nvl(p_amount,0);
    END If;
    IF (p_bill_action IS not Null)  THEN
      l_bcl_pr_tbl_in(1).bill_action := G_billaction_tr;
    END If;
    IF (p_sent_yn IS not Null)  THEN
      l_bcl_pr_tbl_in(1).sent_yn := p_sent_yn;
    END If;

    UPDATE oks_bcl_pr
    SET    amount = nvl(p_amount,0) + nvl(amount,0),
           bill_Action = nvl(p_bill_action,bill_action) ,
           currency_code = p_currency_code,
           sent_yn     = nvl(p_sent_yn , sent_yn)
      WHERE id = l_bcl_pr_tbl_in(1).ID   ;



  END IF;
              x_ret_stat := l_ret_stat;
     EXCEPTION
           When  Others Then
               Null;
               OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN,SQLERRM);
 END update_bcl;


------------------------------------------------------------------------
  -- FUNCTION Insert_bcl
------------------------------------------------------------------------
PROCEDURE insert_bcl
(
 P_CALLEDFROM        IN NUMBER,
 x_return_stat      OUT     NOCOPY VARCHAR2,
 p_CLE_ID            IN            NUMBER,
 p_DATE_BILLED_FROM  IN            DATE,
 P_DATE_BILLED_TO    IN            DATE,
 P_DATE_NEXT_INVOICE IN            DATE,
 P_BILL_ACTION       IN            VARCHAR2 ,
 P_OKL_FLAG          IN            NUMBER,
 P_PRV               IN            NUMBER,
 P_MSG_COUNT         IN OUT NOCOPY NUMBER,
 P_MSG_DATA          IN OUT NOCOPY VARCHAR2,
 X_BCL_ID            IN OUT NOCOPY NUMBER
 )IS
SUBTYPE l_bclv_tbl_type_in  is OKS_bcl_PVT.bclv_tbl_type;
   l_bclv_tbl_in   l_bclv_tbl_type_in;
   l_bclv_tbl_out   l_bclv_tbl_type_in;

SUBTYPE l_bcl_pr_tbl_type is OKS_BCL_PRINT_PREVIEW_PVT.bcl_pr_tbl_type;
   l_bcl_pr_tbl_in  l_bcl_pr_tbl_type;
   l_bcl_pr_tbl_out l_bcl_pr_tbl_type;

l_ret_stat    Varchar2(20);
l_msg_cnt  Number;
l_msg_data Varchar2(2000);

l_bcl_id   NUMBER;

--- -55 check for OKL issue raise on bug # 4634345
Cursor l_bcl_csr(p_cle_id_in Number,p_date_billed_from_in date,p_date_billed_to_in date) Is
  Select  Id
         From    Oks_bill_cont_lines
         Where   Cle_id = p_cle_id_in
         And trunc(date_billed_from) = trunc(p_date_billed_from_in)
         And trunc(date_billed_to)   = trunc(p_date_billed_to_in)
            And bill_action = p_bill_action
         And (btn_id is null OR btn_id = -55)
         Order by Date_billed_from desc;

Cursor l_bcl_pr_csr(p_cle_id_in Number,p_date_billed_from_in date,p_date_billed_to_in date) Is
  Select  Id
         From    Oks_bcl_pr
         Where   Cle_id = p_cle_id_in
         And     trunc(date_billed_from) = trunc(p_date_billed_from_in)
         And     trunc(date_billed_to)   = trunc(p_date_billed_to_in)
            And     bill_action = p_bill_action
         And (btn_id is null OR btn_id = -55)
         Order by Date_billed_from desc;

BEGIN

 IF (P_PRV = 1 ) THEN   --NORMAL PROCESSING
   l_bclv_tbl_in(1).CLE_ID  := p_cle_id;
   l_bclv_tbl_in(1).DATE_BILLED_FROM := p_DATE_BILLED_FROM;
   l_bclv_tbl_in(1).DATE_BILLED_TO := P_DATE_BILLED_TO;
   l_bclv_tbl_in(1).Date_Next_Invoice := p_date_next_invoice;
   l_bclv_tbl_in(1).BILL_ACTION := p_bill_action;
   l_bclv_tbl_in(1).sent_yn := 'N';

   IF (P_OKL_FLAG = 1 ) THEN   --Check for OKL contract
     l_bclv_tbl_in(1).BTN_ID  := -55;
   END IF;

   OPEN  l_bcl_csr(p_cle_id ,p_date_billed_from ,p_date_billed_to );
   FETCH l_bcl_csr into l_bcl_id;

   IF (l_bcl_csr%NOTFOUND) THEN
     OKS_BILLCONTLINE_PUB.insert_Bill_Cont_Line(
       P_API_VERSION                  =>  1.0,
       P_INIT_MSG_LIST                =>  'T',
       X_RETURN_STATUS                =>   l_ret_stat,
       X_MSG_COUNT                    =>   l_msg_cnt,
       X_MSG_DATA                     =>   l_msg_data,
       P_BCLV_TBL                     =>   l_bclv_tbl_in,
       X_BCLV_TBL                     =>   l_bclv_tbl_out
       );

      x_bcl_id := l_bclv_tbl_out(1).id;
   ELSE
      x_bcl_id := l_bcl_id;
   END IF;
   CLOSE l_bcl_csr;
 ELSIF (P_PRV = 2) THEN
   l_bcl_pr_tbl_in(1).ID      := get_seq_id;
   l_bcl_pr_tbl_in(1).CLE_ID  := p_cle_id;
   l_bcl_pr_tbl_in(1).DATE_BILLED_FROM := p_DATE_BILLED_FROM;
   l_bcl_pr_tbl_in(1).DATE_BILLED_TO := P_DATE_BILLED_TO;
   l_bcl_pr_tbl_in(1).Date_Next_Invoice := p_date_next_invoice;
   l_bcl_pr_tbl_in(1).BILL_ACTION := p_bill_action;
   l_bcl_pr_tbl_in(1).sent_yn := 'N';
   l_bcl_pr_tbl_in(1).created_by := FND_GLOBAL.user_id;
   l_bcl_pr_tbl_in(1).last_updated_by := FND_GLOBAL.user_id;
   l_bcl_pr_tbl_in(1).creation_date  := sysdate;
   l_bcl_pr_tbl_in(1).last_update_date := sysdate;
   l_bcl_pr_tbl_in(1).object_version_number := 1;
   l_bcl_pr_tbl_in(1).amount := 0;
   l_bcl_pr_tbl_in(1).date_next_invoice  := NULL;
   l_bcl_pr_tbl_in(1).last_update_login  := NULL;
   l_bcl_pr_tbl_in(1).attribute_category  := NULL;
   l_bcl_pr_tbl_in(1).attribute1  := NULL;
   l_bcl_pr_tbl_in(1).attribute2  := NULL;
   l_bcl_pr_tbl_in(1).attribute3  := NULL;
   l_bcl_pr_tbl_in(1).attribute4  := NULL;
   l_bcl_pr_tbl_in(1).attribute5  := NULL;
   l_bcl_pr_tbl_in(1).attribute6  := NULL;
   l_bcl_pr_tbl_in(1).attribute7  := NULL;
   l_bcl_pr_tbl_in(1).attribute8  := NULL;
   l_bcl_pr_tbl_in(1).attribute9  := NULL;
   l_bcl_pr_tbl_in(1).attribute10  := NULL;
   l_bcl_pr_tbl_in(1).attribute11  := NULL;
   l_bcl_pr_tbl_in(1).attribute12  := NULL;
   l_bcl_pr_tbl_in(1).attribute13  := NULL;
   l_bcl_pr_tbl_in(1).attribute14  := NULL;
   l_bcl_pr_tbl_in(1).attribute15  := NULL;
   l_bcl_pr_tbl_in(1).security_group_id  := NULL;

   IF (P_OKL_FLAG = 1 ) THEN   --Check for OKL contract
     l_bcl_pr_tbl_in(1).BTN_ID  := -55;
   ELSE
     l_bcl_pr_tbl_in(1).BTN_ID  := NULL;
   END IF;

   OPEN  l_bcl_pr_csr(p_cle_id ,p_date_billed_from ,p_date_billed_to );
   FETCH l_bcl_pr_csr into l_bcl_id;

   IF (l_bcl_pr_csr%NOTFOUND)  THEN
     OKS_BCL_PRINT_PREVIEW_PUB.insert_bcl_pr(
       P_API_VERSION          => 1.0,
       P_INIT_MSG_LIST        => 'T',
       X_RETURN_STATUS        => l_ret_stat,
       X_MSG_COUNT            => l_msg_cnt,
       X_MSG_DATA             => l_msg_data,
       P_BCL_PR_TBL           => l_bcl_pr_tbl_in,
       X_BCL_PR_TBL           => l_bcl_pr_tbl_out);

       x_bcl_id := l_bcl_pr_tbl_out(1).id;
   ELSE
      x_bcl_id := l_bcl_id;
   END IF;
   CLOSE l_bcl_pr_csr;
 END IF;
 IF (l_ret_stat <> 'S' ) THEN
      get_message(l_msg_cnt  => l_msg_cnt,
                  l_msg_data => l_msg_data);
      p_msg_count := l_msg_cnt;
      p_msg_data  := l_msg_data;
 END IF;

   x_return_stat := l_ret_stat;
EXCEPTION
   When  Others Then
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN,SQLERRM);

END insert_bcl;



PROCEDURE get_bcl_id
(
 P_CALLEDFROM       IN           NUMBER,
 X_RETURN_STAT     OUT   NOCOPY  VARCHAR2,
 P_CLE_ID           IN           NUMBER,
 P_DATE_BILLED_FROM IN           DATE,
 P_DATE_BILLED_TO   IN           DATE,
 P_BILL_ACTION      IN           VARCHAR2 ,
 X_BCL_ID          OUT   NOCOPY  NUMBER,
 X_BCL_AMOUNT      OUT   NOCOPY  NUMBER,
 P_PRV              IN           NUMBER
 )IS
SUBTYPE l_bclv_tbl_type_in  is OKS_bcl_PVT.bclv_tbl_type;
   l_bclv_tbl_in   l_bclv_tbl_type_in;
   l_bclv_tbl_out   l_bclv_tbl_type_in;

SUBTYPE l_bcl_pr_tbl_type is OKS_BCL_PRINT_PREVIEW_PVT.bcl_pr_tbl_type;
   l_bcl_pr_tbl_in  l_bcl_pr_tbl_type;
   l_bcl_pr_tbl_out l_bcl_pr_tbl_type;

l_ret_stat    Varchar2(20);
l_msg_cnt  Number;
l_msg_data Varchar2(2000);

Cursor l_bcl_csr(p_cle_id_in Number,p_date_billed_from_in date,p_date_billed_to_in date) Is
  Select  Id,amount
         From    Oks_bill_cont_lines
         Where   Cle_id = p_cle_id_in
         And trunc(date_billed_from) = trunc(p_date_billed_from_in)
         And trunc(date_billed_to)   = trunc(p_date_billed_to_in)
            And     bill_Action = p_bill_action
         And ( btn_id is null or btn_id = -55)
         Order by Date_billed_from desc;

Cursor l_bcl_pr_csr(p_cle_id_in Number,p_date_billed_from_in date,p_date_billed_to_in date) Is
  Select  Id,amount
         From    Oks_bcl_pr
         Where   Cle_id = p_cle_id_in
         And     trunc(date_billed_from) = trunc(p_date_billed_from_in)
         And     trunc(date_billed_to)   = trunc(p_date_billed_to_in)
         And     bill_Action = p_bill_action
         And ( btn_id is null or btn_id = -55)
         Order by Date_billed_from desc;

BEGIN

 IF (P_PRV = 1 ) THEN
   open  l_bcl_csr(p_cle_id ,p_date_billed_from ,p_date_billed_to );
   Fetch l_bcl_csr into x_bcl_id,x_bcl_amount;
   close l_bcl_csr;
 ELSIF (P_PRV = 2) THEN
   open  l_bcl_pr_csr(p_cle_id ,p_date_billed_from ,p_date_billed_to );
   Fetch l_bcl_pr_csr into x_bcl_id,x_bcl_amount;
   close l_bcl_pr_csr;
 END IF;

   x_return_stat := OKC_API.G_RET_STS_SUCCESS;
EXCEPTION
   When  Others Then
          Null;
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN,SQLERRM);
   x_return_stat := OKC_API.G_RET_STS_ERROR;
END get_bcl_id;



------------------------------------------------------------------------
  -- FUNCTION Insert_all_subline
------------------------------------------------------------------------
PROCEDURE insert_all_subline
(
 P_CALLEDFROM        IN             NUMBER,
 X_RETURN_STAT      OUT     NOCOPY  VARCHAR2,
 P_COVERED_TBL       IN OUT NOCOPY  COVERED_TBL,
 P_CURRENCY_CODE     IN             VARCHAR2,
 P_DNZ_CHR_ID        IN             NUMBER,
 P_PRV               IN             NUMBER,
 P_MSG_COUNT         IN OUT NOCOPY  NUMBER,
 P_MSG_DATA          IN OUT NOCOPY  VARCHAR2
 )
 IS
Cursor l_get_conversion_rule (p_chr_id IN NUMBER) is
 SELECT conversion_rate          con_rate,
        conversion_rate_date     con_date,
        conversion_type          con_type
   FROM okc_k_headers_b
   WHERE  id = p_chr_id;




SUBTYPE l_bclv_tbl_type_in  is OKS_bcl_PVT.bclv_tbl_type;
   l_bclv_tbl_in   l_bclv_tbl_type_in;
   l_bclv_tbl_out   l_bclv_tbl_type_in;
SUBTYPE l_bslv_tbl_type_in  is OKS_bsl_PVT.bslv_tbl_type;
   l_bslv_tbl_in   l_bslv_tbl_type_in;
   l_bslv_tbl_out   l_bslv_tbl_type_in;
SUBTYPE l_bsdv_tbl_type_in  is OKS_bsd_PVT.bsdv_tbl_type;
   l_bsdv_tbl_in   l_bsdv_tbl_type_in;
   l_bsdv_tbl_out   l_bsdv_tbl_type_in;


SUBTYPE l_bcl_pr_tbl_type  is OKS_BCL_PRINT_PREVIEW_PVT.bcl_pr_tbl_type;
   l_bcl_pr_tbl_in   l_bcl_pr_tbl_type;
   l_bcl_pr_tbl_out  l_bcl_pr_tbl_type;
SUBTYPE l_bsl_pr_tbl_type  is OKS_BSL_PRINT_PREVIEW_PVT.bsl_pr_tbl_type;
   l_bsl_pr_tbl_in   l_bsl_pr_tbl_type;
   l_bsl_pr_tbl_out  l_bsl_pr_tbl_type;
SUBTYPE l_bsd_pr_tbl_type  is OKS_BSD_PRINT_PREVIEW_PVT.bsd_pr_tbl_type;
   l_bsd_pr_tbl_in   l_bsd_pr_tbl_type;
   l_bsd_pr_tbl_out  l_bsd_pr_tbl_type;


l_ret_stat    Varchar2(20) := OKC_API.G_RET_STS_SUCCESS;
l_msg_cnt  Number;
l_msg_data Varchar2(2000);

l_amount NUMBER      := 0;
l_amount_holder      NUMBER       := 0;
l_cur_holder         VARCHAR2(10) ;

round_amount NUMBER  := 0;
l_cntr NUMBER;
l_ret_stat_buf VARCHAR2(20) := 'S';
l_index number;
l_euro_conversion    VARCHAR2(10);
l_euro_currency_code VARCHAR2(10);
l_con_rate           NUMBER;
l_con_date           DATE;
l_con_type           VARCHAR2(20);
cvn_not_found        EXCEPTION;


BEGIN
  x_return_stat   := l_ret_stat;
  l_cntr := 0;

  l_euro_conversion := okc_currency_api.IS_EURO_CONVERSION_NEEDED
                                                   (p_currency_code);


  IF (l_euro_conversion = 'Y') THEN
    OPEN  l_get_conversion_rule(p_dnz_chr_id);
    FETCH l_get_conversion_rule into l_con_rate,l_con_date,l_con_type;
    IF (l_get_conversion_rule%NOTFOUND) THEN
      RAISE  cvn_not_found;
    END IF;
    CLOSE l_get_conversion_rule;

    l_euro_currency_code :=okc_currency_api.GET_EURO_CURRENCY_CODE
                                                   (p_currency_code);
  END IF;

  FOR l_cntr IN 1..p_covered_tbl.count
  LOOP

    round_amount := 0;

    ----for bug#3544124 commented if condition
    ----IF nvl(p_covered_tbl(l_cntr).AMOUNT,0) > 0  Then

      IF (l_euro_conversion = 'Y') Then

       l_cur_holder   := l_euro_currency_code;
       okc_currency_api.CONVERT_AMOUNT
           (P_FROM_CURRENCY         => p_currency_code,
            P_TO_CURRENCY           => l_euro_currency_code,
            P_CONVERSION_DATE       => l_con_date,
            P_CONVERSION_TYPE       => l_con_type,
            P_AMOUNT                => abs(p_covered_tbl(l_cntr).AMOUNT) ,
            X_CONVERSION_RATE       => l_con_rate   ,
            X_CONVERTED_AMOUNT      => l_amount_holder
            );

        ---Added as passing abs val to convert_amount
        IF nvl(p_covered_tbl(l_cntr).AMOUNT,0) < 0  Then
           l_amount_holder := -1 * l_amount_holder;
        END IF;

      ELSE
        l_amount_holder :=   p_covered_tbl(l_cntr).AMOUNT;
        l_cur_holder    :=   p_currency_code;
      END IF;

      /**
            * function added to round off the amount depending on the
            * precision set in fnd_currency  -- Hari 08/03/2001
       **/

      round_amount := OKS_EXTWAR_UTIL_PVT.round_currency_amt(
                                                 l_amount_holder,
                                                 l_cur_holder );

    -----END IF;---- for amount > 0

    IF (P_PRV = 1 ) THEN
      l_bslv_tbl_in(1).CLE_ID          :=p_covered_tbl(l_cntr).id;
      l_bslv_tbl_in(1).bcl_id          :=p_covered_tbl(l_cntr).bcl_id;
      l_bslv_tbl_in(1).DATE_BILLED_FROM:=p_covered_tbl(l_cntr).DATE_BILLED_FROM;
      l_bslv_tbl_in(1).DATE_BILLED_TO  :=p_covered_tbl(l_cntr).DATE_BILLED_TO;
      l_bslv_tbl_in(1).AMOUNT          :=round_amount;
      l_bslv_tbl_in(1).AVERAGE         :=p_covered_tbl(l_cntr).AVERAGE;

      OKS_BILLSUBLINE_PUB.insert_Bill_subLine_Pub
        (
          P_API_VERSION                  =>  1.0,
          P_INIT_MSG_LIST                =>  'T',
          X_RETURN_STATUS                =>   l_ret_stat,
          X_MSG_COUNT                    =>   l_msg_cnt,
          X_MSG_DATA                     =>   l_msg_data,
          P_BSLV_TBL                     =>   l_bslv_tbl_in,
          X_BSLV_TBL                     =>   l_bslv_tbl_out
         );


      IF (l_ret_stat = 'S') THEN
        l_bsdv_tbl_in(1).bsl_id         := l_bslv_tbl_out(1).id;
        l_bsdv_tbl_in(1).amount         := round_amount;
        l_bsdv_tbl_in(1).unit_of_measure:= p_covered_tbl(l_cntr).UNIT_OF_MEASURE;
        l_bsdv_tbl_in(1).amcv_yn        := p_covered_tbl(l_cntr).AMCV_YN;
        l_bsdv_tbl_in(1).result         := p_covered_tbl(l_cntr).RESULT;
        l_bsdv_tbl_in(1).fixed          := p_covered_tbl(l_cntr).FIXED;
        l_bsdv_tbl_in(1).actual         := p_covered_tbl(l_cntr).ACTUAL;
        l_bsdv_tbl_in(1).default_default:=p_covered_tbl(l_cntr).DEFAULT_DEFAULT;
        l_bsdv_tbl_in(1).adjustment_level:= p_covered_tbl(l_cntr).ADJUSTMENT_LEVEL;
        l_bsdv_tbl_in(1).adjustment_minimum:= p_covered_tbl(l_cntr).ADJUSTMENT_MINIMUM;
        l_bsdv_tbl_in(1).bsl_id_averaged:=p_covered_tbl(l_cntr).BSL_ID_AVERAGED;
        l_bsdv_tbl_in(1).bsd_id         := p_covered_tbl(l_cntr).BSD_ID;
        l_bsdv_tbl_in(1).bsd_id_applied := p_covered_tbl(l_cntr).BSD_ID_APPLIED;
        l_bsdv_tbl_in(1).start_reading  := p_covered_tbl(l_cntr).start_reading;
        l_bsdv_tbl_in(1).end_reading    := p_covered_tbl(l_cntr).end_reading;
        l_bsdv_tbl_in(1).base_reading   := p_covered_tbl(l_cntr).base_reading;
        l_bsdv_tbl_in(1).estimated_quantity:= p_covered_tbl(l_cntr).estimated_quantity;
        l_bsdv_tbl_in(1).ccr_id         := p_covered_tbl(l_cntr).ccr_id;
        l_bsdv_tbl_in(1).cgr_id         := p_covered_tbl(l_cntr).cgr_id;


        OKS_BSL_det_PUB.insert_bsl_det_Pub
          (
            P_API_VERSION                  =>  1.0,
            P_INIT_MSG_LIST                =>  'T',
            X_RETURN_STATUS                =>   l_ret_stat,
            X_MSG_COUNT                    =>   l_msg_cnt,
            X_MSG_DATA                     =>   l_msg_data,
            P_BSDV_TBL                     =>   l_bsdv_tbl_in,
            X_BSDV_TBL                     =>   l_bsdv_tbl_out
           );
       END If;

       p_covered_tbl(l_cntr).x_stat := l_ret_stat;

       IF ( l_ret_stat <> 'S') THEN
         l_ret_stat_buf := l_ret_stat;
         get_message(l_msg_cnt  => l_msg_cnt,
                     l_msg_data => l_msg_data);
         p_msg_count := l_msg_cnt;
         p_msg_data  := l_msg_data;
       ELSE
         l_amount := nvl(l_amount,0) + nvl(round_amount,0);
       END If;

     ELSIF (P_PRV = 2 ) THEN
       l_bsl_pr_tbl_in(1).id                    := get_seq_id;
       l_bsl_pr_tbl_in(1).CLE_ID                := p_covered_tbl(l_cntr).id;
       l_bsl_pr_tbl_in(1).bcl_id                := p_covered_tbl(l_cntr).bcl_id;
       l_bsl_pr_tbl_in(1).DATE_BILLED_FROM      := p_covered_tbl(l_cntr).DATE_BILLED_FROM;
       l_bsl_pr_tbl_in(1).DATE_BILLED_TO        := p_covered_tbl(l_cntr).DATE_BILLED_TO;
       l_bsl_pr_tbl_in(1).AMOUNT                := nvl(round_amount,0);
       l_bsl_pr_tbl_in(1).AVERAGE               := nvl(p_covered_tbl(l_cntr).AVERAGE,0);
       l_bsl_pr_tbl_in(1).OBJECT_VERSION_NUMBER := 1;
       l_bsl_pr_tbl_in(1).CREATED_BY := FND_GLOBAL.user_id;
       l_bsl_pr_tbl_in(1).LAST_UPDATED_BY := FND_GLOBAL.user_id;
       l_bsl_pr_tbl_in(1).CREATION_DATE := sysdate;
       l_bsl_pr_tbl_in(1).LAST_UPDATE_DATE := sysdate;
       l_bsl_pr_tbl_in(1).LAST_UPDATE_LOGIN := NULL;
       l_bsl_pr_tbl_in(1).ATTRIBUTE_CATEGORY := NULL;
       l_bsl_pr_tbl_in(1).ATTRIBUTE1 := NULL;
       l_bsl_pr_tbl_in(1).ATTRIBUTE2 := NULL;
       l_bsl_pr_tbl_in(1).ATTRIBUTE3 := NULL;
       l_bsl_pr_tbl_in(1).ATTRIBUTE4 := NULL;
       l_bsl_pr_tbl_in(1).ATTRIBUTE5 := NULL;
       l_bsl_pr_tbl_in(1).ATTRIBUTE6 := NULL;
       l_bsl_pr_tbl_in(1).ATTRIBUTE7 := NULL;
       l_bsl_pr_tbl_in(1).ATTRIBUTE8 := NULL;
       l_bsl_pr_tbl_in(1).ATTRIBUTE9 := NULL;
       l_bsl_pr_tbl_in(1).ATTRIBUTE10 := NULL;
       l_bsl_pr_tbl_in(1).ATTRIBUTE11 := NULL;
       l_bsl_pr_tbl_in(1).ATTRIBUTE12 := NULL;
       l_bsl_pr_tbl_in(1).ATTRIBUTE13 := NULL;
       l_bsl_pr_tbl_in(1).ATTRIBUTE14 := NULL;
       l_bsl_pr_tbl_in(1).ATTRIBUTE15 := NULL;
       l_bsl_pr_tbl_in(1).SECURITY_GROUP_ID := NULL;
       l_bsl_pr_tbl_in(1).DATE_TO_INTERFACE := NULL;

       OKS_BILLSubLINE_PRV_PUB.insert_bsl_pr
        (
          P_API_VERSION                  =>  1.0,
          P_INIT_MSG_LIST                =>  'T',
          X_RETURN_STATUS                =>   l_ret_stat,
          X_MSG_COUNT                    =>   l_msg_cnt,
          X_MSG_DATA                     =>   l_msg_data,
          P_BSL_PR_TBL                   =>   l_bsl_pr_tbl_in,
          X_BSL_PR_TBL                   =>   l_bsl_pr_tbl_out
         );

         IF (l_ret_stat = 'S') THEN
           l_bsd_pr_tbl_in(1).id                    := get_seq_id;
           l_bsd_pr_tbl_in(1).bsl_id                := l_bsl_pr_tbl_out(1).id;
           l_bsd_pr_tbl_in(1).AMOUNT                := round_amount;
           l_bsd_pr_tbl_in(1).UNIT_OF_MEASURE       := p_covered_tbl(l_cntr).UNIT_OF_MEASURE;
           l_bsd_pr_tbl_in(1).AMCV_YN               := p_covered_tbl(l_cntr).AMCV_YN;
           l_bsd_pr_tbl_in(1).RESULT                := p_covered_tbl(l_cntr).RESULT;
           l_bsd_pr_tbl_in(1).FIXED                 := p_covered_tbl(l_cntr).FIXED;
           l_bsd_pr_tbl_in(1).ACTUAL                := p_covered_tbl(l_cntr).ACTUAL;
           l_bsd_pr_tbl_in(1).DEFAULT_DEFAULT       := p_covered_tbl(l_cntr).DEFAULT_DEFAULT;
           l_bsd_pr_tbl_in(1).ADJUSTMENT_LEVEL      := p_covered_tbl(l_cntr).ADJUSTMENT_LEVEL;
           l_bsd_pr_tbl_in(1).ADJUSTMENT_MINIMUM    := p_covered_tbl(l_cntr).ADJUSTMENT_MINIMUM;
           l_bsd_pr_tbl_in(1).BSL_ID_AVERAGED       := l_bsl_pr_tbl_out(1).id; --p_covered_tbl(l_cntr).BSL_ID_AVERAGED;
           l_bsd_pr_tbl_in(1).BSD_ID                := p_covered_tbl(l_cntr).BSD_ID;
           l_bsd_pr_tbl_in(1).BSD_ID_APPLIED        := p_covered_tbl(l_cntr).BSD_ID_APPLIED;
           l_bsd_pr_tbl_in(1).start_reading         := p_covered_tbl(l_cntr).start_reading;
           l_bsd_pr_tbl_in(1).end_reading           := p_covered_tbl(l_cntr).end_reading;
           l_bsd_pr_tbl_in(1).base_reading          := p_covered_tbl(l_cntr).base_reading;
           l_bsd_pr_tbl_in(1).ccr_id                := p_covered_tbl(l_cntr).ccr_id;
           l_bsd_pr_tbl_in(1).cgr_id                := p_covered_tbl(l_cntr).cgr_id;
           l_bsd_pr_tbl_in(1).OBJECT_VERSION_NUMBER := 1;
           l_bsd_pr_tbl_in(1).created_by := FND_GLOBAL.user_id;
           l_bsd_pr_tbl_in(1).last_updated_by := FND_GLOBAL.user_id;
           l_bsd_pr_tbl_in(1).last_update_date := sysdate;
           l_bsd_pr_tbl_in(1).creation_date := sysdate;
           l_bsd_pr_tbl_in(1).last_update_login := NULL;
           l_bsd_pr_tbl_in(1).attribute_category := NULL;
           l_bsd_pr_tbl_in(1).attribute1 := NULL;
           l_bsd_pr_tbl_in(1).attribute2 := NULL;
           l_bsd_pr_tbl_in(1).attribute3 := NULL;
           l_bsd_pr_tbl_in(1).attribute4 := NULL;
           l_bsd_pr_tbl_in(1).attribute5 := NULL;
           l_bsd_pr_tbl_in(1).attribute6 := NULL;
           l_bsd_pr_tbl_in(1).attribute7 := NULL;
           l_bsd_pr_tbl_in(1).attribute8 := NULL;
           l_bsd_pr_tbl_in(1).attribute9 := NULL;
           l_bsd_pr_tbl_in(1).attribute10 := NULL;
           l_bsd_pr_tbl_in(1).attribute11 := NULL;
           l_bsd_pr_tbl_in(1).attribute12 := NULL;
           l_bsd_pr_tbl_in(1).attribute13 := NULL;
           l_bsd_pr_tbl_in(1).attribute14 := NULL;
           l_bsd_pr_tbl_in(1).attribute15 := NULL;
           l_bsd_pr_tbl_in(1).security_group_id := NULL;


           OKS_BSD_PRV_PUB.insert_bsd_pr
           (
            P_API_VERSION                  =>  1.0,
            P_INIT_MSG_LIST                =>  'T',
            X_RETURN_STATUS                =>   l_ret_stat,
            X_MSG_COUNT                    =>   l_msg_cnt,
            X_MSG_DATA                     =>   l_msg_data,
            P_BSD_PR_TBL                   =>   l_bsd_pr_tbl_in,
            X_BSD_PR_TBL                   =>   l_bsd_pr_tbl_out
            );
         END IF;
         p_covered_tbl(l_cntr).x_stat := l_ret_stat;

         IF (l_ret_stat <> 'S') THEN
           l_ret_stat_buf := l_ret_stat;
           get_message(l_msg_cnt  => l_msg_cnt,
                       l_msg_data => l_msg_data);
           p_msg_count := l_msg_cnt;
           p_msg_data := l_msg_data;
         ELSE
           l_amount := nvl(l_amount,0) + nvl(round_amount,0);
         END If;
       END IF;
     END LOOP;

     --l_amount := nvl(l_amount,0) + nvl(p_covered_tbl(1).bcl_amount,0);

    --- to fix bug# 1716684
     IF(l_ret_stat_buf = 'S' and p_covered_tbl.count > 0) THEN

     ---for bug#3544124 removed condition from if statment   l_amount > 0 )

       Update_bcl
        (
          P_CALLEDFROM,
          l_ret_stat,
          p_covered_tbl(1).bcl_id,
          Null,
          Null,
          l_amount,
          l_cur_holder,
          P_PRV
        );
       IF (l_ret_stat <> 'S') THEN
         l_ret_stat_buf := l_ret_stat;
         get_message(l_msg_cnt  => l_msg_cnt,
                     l_msg_data => l_msg_data);
       END If;
     END If;

     p_covered_tbl.delete;
     x_return_stat := l_ret_stat_buf;

EXCEPTION
   WHEN  cvn_not_found  THEN
         x_return_stat := 'E';
   WHEN  OTHERS THEN
          Null;
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN,SQLERRM);

END insert_all_subline;

---------------------------------------------------------------------------------------
           -- Get_bill_profile
------------------------------------------------------------------------------------
PROCEDURE Get_Bill_profile
( p_dnz_chr_id   IN          NUMBER,
  x_bill_profile OUT NOCOPY  VARCHAR2
) IS

Cursor l_bill_profile_id_csr(id_in IN Number) IS
       Select rule_information1 profile_id
       From   OKC_RULES_B  RL
             ,OKC_RULE_GROUPS_B RG
       Where   RG.dnz_chr_id = id_in
       And     RG.cle_id Is Null
       And     RG.id = RL.rgp_id
       And     rule_information_category = 'BPF';

Cursor l_bill_profile_csr(id_in Number) Is
       Select Summarised_yn
       From   OKS_BILLING_PROFILES_V
       Where  id = id_in;
l_profile_id NUMBER;

BEGIN
     OPEN l_bill_profile_id_csr(p_dnz_chr_id);
     FETCH l_bill_profile_id_csr into l_profile_id;
     Close l_bill_profile_id_csr;

     OPEN l_bill_profile_csr(l_profile_id);
     FETCH l_bill_profile_csr into x_bill_profile;
     Close l_bill_profile_csr;

EXCEPTION
   When  Others Then
          Null;
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN,SQLERRM);

END Get_Bill_profile;


/*================================================================================
Adjust_Neg_Price -- API to reconcile for the Service Billing and Usage Type 'NPR'
after the Negotiated Price has been changed
==================================================================================*/

Procedure Adjust_Negotiated_Price
(
        p_calledfrom             IN             NUMBER,
        p_contract_id            IN             NUMBER,
        x_msg_count             OUT     NOCOPY  NUMBER,
        x_msg_data              OUT     NOCOPY  VARCHAR2,
        x_return_status         OUT     NOCOPY  VARCHAR2
)

IS

Cursor  l_bill_line_csr
IS
Select  line.id,
                line.dnz_chr_id,
                line.cle_id,
                line.lse_id,
                line.start_date,
                line.end_date,
                line.price_negotiated,
                line.date_terminated,
                hdr.currency_code,
                rules.rule_information2 Billing_freq,
                rules.rule_information4 First_inv_dt,
                rules.rule_information3  First_billto_dt,
                rules.rule_information5  Primary_dur,
                rules.rule_information7  Secondary_dur,
                rules.rule_information6 Primary_period,
                rules.rule_information8 Secondary_period

From            OKC_K_LINES_B   line,
                OKC_K_HEADERS_B Hdr,
                OKC_RULES_B             rules,
                OKC_RULE_GROUPS_B       rlgrp

Where           line.lse_id in (1,12)
And             line.dnz_chr_id = Hdr.id
And             rlgrp.cle_id  = line.id
And             rules.rgp_id = rlgrp.id
And             rules.rule_information_category = 'SBG'
And             (Hdr.scs_code = 'SERVICE' OR
            /* This code is added for warranty lines that are renewed */
            (Hdr.scs_code = 'WARRANTY' AND Hdr.chr_id_renewed IS not Null))
And             Hdr.Template_yn = 'N'
And             OKC_ASSENT_PUB.line_operation_allowed(line.id,'INVOICE')= 'T'
And             Hdr.id = p_contract_id
--And           Hdr.Contract_number = NVL(p_contract_number,hdr.contract_number)

For Update;

-- This cursor gives all the covered lines of service or usage lines
CURSOR  l_subline_Csr(p_cle_id  Number)
IS
Select  id,
                cle_id,
                price_negotiated,
                start_date,
                end_date,
                date_terminated
From            OKC_K_LINES_B
Where           cle_id = p_cle_id
And             lse_id in (8,7,9,10,11,13,35);

CURSOR  l_billed_csr (p_cle_id IN NUMBER)
IS
Select  *
From            oks_bill_cont_lines
where           cle_id = p_cle_id
and             bill_action in ('RI', 'AD')
order   by cle_id, date_billed_from;

CURSOR  l_amount_csr(id_in  Number)
IS
Select  nvl(sum(NVL(amount,0)),0)  amount_billed
From            oks_bill_sub_lines
Where           cle_id = id_in;

Cursor  l_inv_item_csr(p_cle_id Number)
Is
Select  item.Object1_id1,
        mtl.usage_item_flag,
        mtl.service_item_flag
From    Okc_K_items Item,
        mtl_system_items_b  mtl
Where   item.cle_id = p_cle_id
And     mtl.inventory_item_id = item.object1_id1;

Cursor  l_usage_csr(p_id Number)
Is
Select  Rule_information10 Usage_Type
From            OKC_RULES_B RL,
                OKC_RULE_GROUPS_B RG
Where           RG.cle_id = p_id
And             RG.id = RL.rgp_id
And             rule_information_category = 'QRE';

Cursor  qty_uom_csr(p_cle_id  Number)
Is
Select   okc.Number_of_items,
         tl.Unit_of_measure uom_code
From   OKC_K_ITEMS_V OKC,
       mtl_units_of_measure_tl tl
Where  okc.cle_id = P_cle_id
And    tl.uom_code = OKC.uom_code
AND    tl.language = USERENV('LANG');


Cursor l_okl_contract_csr(p_chr_id IN NUMBER) is
  Select 1 from okc_k_rel_objs
  where  rty_code in ('OKLSRV','OKLUBB')
  and    jtot_object1_code = 'OKL_SERVICE'
  and    object1_id1 = to_char(p_chr_id);

Cursor  get_bcl_id_cur(p_bcl_rec_cle_id IN NUMBER, p_bcl_rec_date_billed_to IN DATE)
IS
Select  id
From            OKS_BILL_CONT_LINES
Where           cle_id = p_bcl_rec_cle_id
And             date_billed_to = p_bcl_rec_date_billed_to
And             bill_action = 'AD';

l_bill_rec                      l_bill_line_csr%rowtype;
l_billed_rec            l_billed_csr%rowtype;
l_amount_rec            l_amount_csr%rowtype;
qty_uom_rec                     qty_uom_csr%rowtype;
l_item_rec                      l_inv_item_csr%rowtype;
l_cov_tbl                       OKS_BILL_REC_PUB.COVERED_TBL;


l_date_billed_from      DATE;
l_date_billed_to        DATE;
l_date_next_invoice     DATE;
l_stat                  NUMBER;
l_error                 Varchar2(1) := 'F';
l_status                Varchar2(1);
l_usage_type            Varchar2(10);
l_msg_data              Varchar2(2000);
l_msg_count             NUMBER;
l_msg_cnt               NUMBER;
l_amount_billed         NUMBER := 0;
l_inv_item_id           NUMBER;
l_billed_cle_id         NUMBER;
l_st_bcl_id                     NUMBER;
l_billed_cnt            NUMBER := 0;
l_ad_cnt                        NUMBER := 0;
l_okl_flag                      NUMBER := 0;
l_bcl_id                NUMBER;
l_line_cnt                      NUMBER := 1;
l_ptr                   NUMBER := 1;
l_return_status         Varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
l_api_name                      CONSTANT VARCHAR2(30) := 'Adjust_Negotiated_Price';

BEGIN

        x_return_status := 'S';

        FOR l_bill_rec in l_bill_line_csr
        LOOP
                DBMS_TRANSACTION.SAVEPOINT('BEFORE_TRANSACTION');

                If l_error = 'T' Then
                        Fetch l_bill_line_csr Into l_bill_rec;
                        Exit WHEN l_bill_line_csr%notFOUND;
                End If;


                l_okl_flag := 0; --- check for OKL contract
                Open l_okl_contract_csr (l_bill_rec.dnz_chr_id);
                Fetch l_okl_contract_csr into l_okl_flag;
                Close l_okl_contract_csr;

                l_billed_cnt :=1;
                For l_billed_rec in l_billed_csr(l_bill_rec.id)
                Loop
                        If l_billed_cnt = 1 Then
                                l_billed_cle_id := l_billed_rec.cle_id;
                                l_date_billed_from := l_billed_rec.date_billed_from;
                        End If;

                        l_date_billed_to := l_billed_rec.date_billed_to;
                        l_date_next_invoice :=  l_billed_rec.date_next_invoice;
                        l_billed_cnt := l_billed_cnt + 1;

                End Loop;

                Open l_usage_csr(l_bill_rec.id);
                Fetch l_usage_csr into l_usage_type;
                Close l_usage_csr;

                Open l_inv_item_csr(l_bill_rec.id);
                Fetch l_inv_item_csr into l_item_rec;
                Close l_inv_item_csr;

                l_ptr := 1;
                l_ad_cnt := 0;
                l_cov_tbl.delete;

                For l_covlvl_rec in l_subline_csr(l_bill_rec.id)
                Loop  -- subline loop
                        Exit WHEN l_subline_csr%notFOUND;

                        If l_date_billed_to < l_covlvl_rec.end_date Then
                                goto end_of_process;
                        END If;

                        --Gets the calculation period for the covered level
                        Open qty_uom_csr(l_bill_rec.id);
                        Fetch qty_uom_csr into qty_uom_rec;
                        Close qty_uom_csr;


                        Select count(*) into l_ad_cnt
                        From OKS_BILL_CONT_LINES
                        Where cle_id = l_billed_cle_id
                        And     Bill_Action = 'AD';


                        If l_ad_cnt = 0 Then

                                OKS_BILL_REC_PUB.Insert_bcl
                                (
                                        p_calledfrom            => p_calledfrom,
                                        x_return_stat           => l_return_status,
                                        p_cle_id                => l_billed_cle_id,
                                        p_date_billed_from      => l_date_billed_from,
                                        p_date_billed_to        => l_date_billed_to,
                                        p_date_next_invoice     => l_date_next_invoice,
                                        p_bill_action           => 'AD',
                                        p_okl_flag             => l_okl_flag,
                                        p_prv                   => 1,
                                        p_msg_count            => l_msg_count,
                                        p_msg_data             => l_msg_data,
                                        x_bcl_id               => l_bcl_id
                                );

                                x_return_status := l_return_status;

                                If (l_return_status <> OKC_API.G_RET_STS_SUCCESS) Then
                                      If (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) Then
                                          x_return_status := l_return_status;
                                          raise G_EXCEPTION_HALT_VALIDATION;
                                      ELSE
                                                x_return_status := l_return_status;
                                                FOR I IN 1..FND_MSG_PUB.Count_Msg
                                                LOOP
                                                        FND_FILE.PUT_LINE( FND_FILE.LOG,(FND_MSG_PUB.Get(p_encoded =>FND_API.G_FALSE )));
                                                END LOOP;
                                        END If;
                                ELSIf l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                                        Open get_bcl_id_cur(l_billed_cle_id, l_date_billed_to) ;
                                        Fetch get_bcl_id_cur into l_st_bcl_id;
                                        Close get_bcl_id_cur;
                                END If;


                        END If; -- l_ad_cnt = 0

                        /* Starting from Regular Service Billing */
                        If      (l_item_rec.usage_item_flag = 'N')
                                OR (l_item_rec.service_item_flag = 'Y')
                                OR (l_item_rec.usage_item_flag = 'Y' AND l_usage_type = 'NPR')
                        Then

                                Open l_amount_csr(l_covlvl_rec.id);
                                Fetch l_amount_csr into l_amount_rec;
                                Close l_amount_csr;

                                /* The above cursor is for get the billed amount so far.
                                To support , middle of the contract amount changes.
                                select sum(amount) into l_amount_billed
                                oks_bill_sub_lines_v
                                cle_id = l_covlvl_rec.id;
                                */


                                l_cov_tbl(l_ptr).id                 := l_covlvl_rec.id;
                                l_cov_tbl(l_ptr).bcl_id             := l_st_bcl_id;
                                l_cov_tbl(l_ptr).date_billed_from   := l_covlvl_rec.start_date;
                                l_cov_tbl(l_ptr).date_billed_to     := l_covlvl_rec.end_date;
                                l_cov_tbl(l_ptr).average            := 0;
                                l_cov_tbl(l_ptr).unit_of_measure    := qty_uom_rec.uom_code;
                                l_cov_tbl(l_ptr).fixed              := 0 ;
                                l_cov_tbl(l_ptr).actual             := Null;
                                l_cov_tbl(l_ptr).default_default    := 0;
                                l_cov_tbl(l_ptr).amcv_yn            := 'N';
                                l_cov_tbl(l_ptr).adjustment_level   := 0 ;
                                l_cov_tbl(l_ptr).result             := qty_uom_rec.number_of_items;
                                l_cov_tbl(l_ptr).x_stat             := Null;
                                l_cov_tbl(l_ptr).amount                 := 0;

                                /* End of Adjust Regular Service and Usage NPR Billing*/
                                If l_amount_rec.amount_billed <> l_covlvl_rec.price_negotiated Then
                                        l_amount_billed := (l_covlvl_rec.price_negotiated - nvl(l_amount_rec.amount_billed, 0));
                                        l_cov_tbl(l_ptr).amount := nvl(l_amount_billed,0);
                                END If;
                        END If; -- l_item_rec.usage_item_flag = 'N'

                        l_ptr := l_ptr + 1;

                End Loop; -- subline loop

                OKS_BILL_REC_PUB.Insert_all_subline
                (
                        p_calledfrom    => p_calledfrom,
                        x_return_stat   => l_return_status,
                        p_covered_tbl   => l_cov_tbl,
                        p_currency_code => l_bill_rec.currency_code,
                     p_dnz_chr_id    => l_bill_rec.dnz_chr_id,
               p_prv           => 1,
               p_msg_count     => l_msg_count   ,
               p_msg_data      => l_msg_data
                );

                FND_FILE.PUT_LINE( FND_FILE.LOG, 'after insert into sublines '||'        '||l_return_status );

                If (l_return_status <> OKC_API.G_RET_STS_SUCCESS) Then
                        If (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) Then
                                x_return_status := l_return_status;
                                FND_FILE.PUT_LINE( FND_FILE.LOG, 'insert into table failed  Contract line id :'||'  '||l_bill_rec.id);
                                l_error := 'T';
                                DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
                                raise G_EXCEPTION_HALT_VALIDATION;
                        ELSE
                                x_return_status := l_return_status;
                                FOR I IN 1..FND_MSG_PUB.Count_Msg
                                LOOP
                                        FND_FILE.PUT_LINE( FND_FILE.LOG,(FND_MSG_PUB.Get(p_encoded =>FND_API.G_FALSE )));
                                END LOOP;

                                FND_FILE.PUT_LINE( FND_FILE.LOG, 'insert into table failed  Contract line id :'||'  '||l_bill_rec.id);
                                l_error := 'T';
                                DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
                        END If;
                End If;

                <<end_of_process>>
                l_line_cnt := l_line_cnt + 1;
        END LOOP;

EXCEPTION

WHEN    OKC_API.G_EXCEPTION_ERROR       Then
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
                                (
                                        l_api_name,
                                        G_PKG_NAME,
                                        'OKC_API.G_RET_STS_ERROR',
                                        x_msg_count,
                                        x_msg_data,
                                        '_PUB'
                                );

WHEN    OKC_API.G_EXCEPTION_UNEXPECTED_ERROR    Then
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
                                (
                                        l_api_name,
                                        G_PKG_NAME,
                                        'OKC_API.G_RET_STS_UNEXP_ERROR',
                                        x_msg_count,
                                        x_msg_data,
                                        '_PUB');
WHEN    OTHERS  Then
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
                                (
                                        l_api_name,
                                        G_PKG_NAME,
                                        'OTHERS',
                                        x_msg_count,
                                        x_msg_data,
                                        '_PUB'
                                );

END Adjust_Negotiated_Price;




PROCEDURE pre_terminate_cp
   (
    P_CALLEDFROM                  IN          NUMBER DEFAULT NUll,
    P_CLE_ID                      IN          NUMBER,
    P_TERMINATION_DATE            IN          DATE,
    P_TERMINATE_REASON            IN          VARCHAR2,
    P_OVERRIDE_AMOUNT             IN          NUMBER,
    P_CON_TERMINATE_AMOUNT        IN          NUMBER,
    --P_EXISTING_CREDIT           IN          NUMBER,
    P_TERMINATION_AMOUNT          IN          NUMBER,
    P_SUPPRESS_CREDIT             IN          VARCHAR2,
    P_FULL_CREDIT                 IN          VARCHAR2,
    P_Term_Date_flag              IN          VARCHAR2,
    P_Term_Cancel_source          IN          VARCHAR2,
    X_RETURN_STATUS               OUT NOCOPY  VARCHAR2
  )IS

 Cursor l_rel_csr (p_line_id in Number) Is
   SELECT id FROM   OKC_K_REL_OBJS_V
   WHERE  cle_id = p_line_id ;

 Cursor check_term_cur(p_cle_id NUMBER) is
  SELECT   bsl.id,
              bcl.cle_id  top_line_id
  FROM oks_bill_cont_lines bcl,
       oks_bill_sub_lines  bsl
  WHERE bsl.bcl_id = bcl.id
  AND   bcl.bill_action  = 'TR'
  AND   bsl.cle_id = p_cle_id;

 Cursor check_lse_id(p_cle_id in NUMBER) is
  SELECT  line1.lse_id, line1.cle_id ,rline.termn_method,
          rline.usage_type, rline.usage_period,
          line1.end_date,line1.sts_code,
          hdr.id
   FROM     okc_k_lines_b line2,
            okc_k_lines_b line1,
            okc_k_headers_b  hdr,
            oks_k_lines_b rline
   WHERE line1.id = p_cle_id
   AND   line2.id = line1.cle_id
   AND   rline.cle_id = line2.id
   AND   hdr.id = line1.dnz_chr_id
   AND   hdr.sts_code <> 'QA_HOLD'
   AND   (exists ( SELECT 1 from okc_assents a
                    where Hdr.scs_code = a.scs_code
                      and line1.sts_code = a.sts_code
                      and line1.sts_code <> 'HOLD'
                      and a.opn_code = 'INVOICE'
                      and a.allowed_yn = 'Y')
           OR
          (line1.sts_code = 'HOLD'));


 Cursor sub_line_billed_cur (p_id IN NUMBER) is
   SELECT bsl.id FROM oks_bill_sub_lines bsl,
                      oks_bill_cont_lines bcl
   WHERE bsl.cle_id = p_id
   AND   bsl.bcl_id = bcl.id
   AND   bcl.bill_action = 'RI';

 Cursor bcl_amount (p_bcl_id in number) is
 Select amount from oks_bill_cont_lines
  where id = p_bcl_id;

 Cursor bsl_amount (p_bsl_id in number) is
 Select amount from oks_bill_sub_lines
  where id = p_bsl_id;

 --04-JAN-2006 mchoudha for bug#4738970
 --Added this cursor to fetch the ste_code
 CURSOR cur_status (p_code in varchar2) is
 SELECT ste_code
 FROM okc_statuses_b
 WHERE code = p_code;


 --Bug#5276678
 Cursor neg_bcl_amount_line (p_cle_id in number) is
 Select nvl(sum(decode(sign(trunc(bsl.date_billed_from) -   trunc(p_termination_date))  ,-1,
           ((trunc(bsl.date_billed_to) -  trunc(p_termination_date) + 1) * bsl.amount) /
            (trunc(bsl.date_billed_to) - trunc(bsl.date_billed_from) + 1) ,bsl.amount      )),0)
   -- nvl(sum(bsl.amount),0)
   from oks_bill_cont_lines bcl,
        oks_bill_sub_lines  bsl
   where bcl.cle_id = p_cle_id
   and   bsl.bcl_id = bcl.id
   and   bcl.bill_action <> 'TR'
 --and   trunc(bsl.date_billed_from) >= trunc(p_termination_date)
   and   trunc(bsl.date_billed_to) >= trunc(p_termination_date)		--bug#5276678
   and   bsl.amount < 0;

Cursor pos_bcl_amount_line (p_cle_id in number) is
 Select nvl(sum(decode(sign(trunc(bsl.date_billed_from) -   trunc(p_termination_date))  ,-1,
           ((trunc(bsl.date_billed_to) -  trunc(p_termination_date) + 1) * bsl.amount) /
            (trunc(bsl.date_billed_to) - trunc(bsl.date_billed_from) + 1) ,bsl.amount      )),0)
   from oks_bill_cont_lines bcl,
        oks_bill_sub_lines  bsl
   where bcl.cle_id = p_cle_id
   and   bsl.bcl_id = bcl.id
   and   bcl.bill_action <> 'TR'
 --and   trunc(bsl.date_billed_from) >= trunc(p_termination_date)
   and   trunc(bsl.date_billed_to) >= trunc(p_termination_date)		--bug#5276678
   and   bsl.amount > 0;

--End bug#5276678


Cursor check_avg_csr(p_cle_id in number) is
 Select 1 from oks_bill_cont_lines
  where cle_id = p_cle_id
  and   bill_action = 'AV';

 l_bcl_credit_amount            NUMBER;
 l_bsl_credit_amount            NUMBER;
 l_bsl_id                       NUMBER;
 l_bcl_id                       NUMBER;

 l_clev_tbl_in                  OKC_CONTRACT_PUB.clev_tbl_type;
 l_clev_tbl_out                 OKC_CONTRACT_PUB.clev_tbl_type;
 l_api_version     CONSTANT     NUMBER     := 1.0;
 l_init_msg_list   CONSTANT     VARCHAR2(1):= 'F';
 l_msg_cnt                      NUMBER;
 l_msg_data                     VARCHAR2(2000);
 l_return_status                VARCHAR2(10);

 l_check_term_cur               CHECK_TERM_CUR%ROWTYPE;
 l_lse_id                       OKC_K_LINES_B.lse_id%TYPE;
 l_id                           NUMBER;
 l_amount                       NUMBER;
 l_term_date                    DATE;
 l_ctr                          BOOLEAN;
 l_billed                       BOOLEAN;
 l_number                       NUMBER;
 l_con_terminate_amount         NUMBER;
 l_termination_amount           NUMBER;
 l_top_line_id                  NUMBER;
 l_hdr_id                      NUMBER;
 l_term_method                  VARCHAR2(20);
 l_usage_type                   VARCHAR2(10);
 l_usage_period                 VARCHAR2(10);
 l_last_day_term        date;
 l_true_value_tbl               L_TRUE_VAL_TBL  ;
 --04-JAN-2006 mchoudha for bug#4738970
 --Added these variables
 l_ter_status_code              varchar2(30);
 l_status                       fnd_lookups.lookup_code%type;
 l_status_code                  varchar2(30);
 l_can_status_code              varchar2(30);

 --bug#5276678

 l_override_amount              NUMBER;
 l_con_termination_amount       NUMBER;
 l_neg_amount                   NUMBER;

 --End bug#5276678


BEGIN
  X_return_status := 'S';
  l_ctr           := TRUE;


  IF nvl( P_Term_Date_flag,'N') = 'Y' Then
    l_CON_TERMINATE_AMOUNT       := 0;
    l_TERMINATION_AMOUNT         := 0;
  else
    l_CON_TERMINATE_AMOUNT       := P_CON_TERMINATE_AMOUNT;
    l_TERMINATION_AMOUNT         := P_TERMINATION_AMOUNT;
  End if;

  --bug#5276678

  l_override_amount := p_override_amount;

  --End bug#5276678

  OPEN check_term_cur(p_cle_id);
  FETCH check_term_cur into l_check_term_cur;

  IF check_term_cur%NOTFOUND THEN
    OPEN  check_lse_id(p_cle_id);
    FETCH check_lse_id into l_lse_id,l_top_line_id ,l_term_method,
                            l_usage_type,l_usage_period,l_last_day_term,l_status_code,
                            l_hdr_id;
    IF (check_lse_id%FOUND) THEN
      IF (l_lse_id = 25) THEN
        OPEN  l_rel_csr(p_cle_id);
        FETCH l_rel_csr into l_id;
        IF (l_rel_csr%FOUND) THEN
          l_ctr := FALSE;
        ELSE
          l_ctr := TRUE;
        END IF;
        CLOSE l_rel_csr;
      END IF;


      IF (l_ctr = FALSE) THEN
        Pre_terminate_extwar (
          P_CALLEDFROM             => p_calledfrom,
          P_LINE_ID                => p_cle_id,
          P_TERMINATION_DATE       => p_termination_date,
          P_SUPPRESS_CREDIT        => p_suppress_credit,
          P_TERMINATION_AMOUNT     => p_override_amount,
          P_CON_TERMINATION_AMOUNT => l_con_terminate_amount,
          P_COV_LINE               => 'Y',-- IS a coverage line
          P_FULL_CREDIT            => p_full_credit,
          --P_EXISTING_CREDIT        => p_existing_credit,
          X_AMOUNT                 => l_amount,
          X_RETURN_STATUS          => X_return_status
          );

        IF x_return_status <> 'S' THEN
          Raise G_EXCEPTION_HALT_VALIDATION;
        END IF;
    -- Added code for Bug # 3666203
       IF ((p_override_amount  is NOT NULL) and (g_credit_amount <> p_override_amount )) THEN
           OPEN  bsl_amount(g_bsl_id);
           FETCH bsl_amount into l_bsl_credit_amount;
           CLOSE bsl_amount ;

           OPEN  bcl_amount(g_bcl_id);
           FETCH bcl_amount into l_bcl_credit_amount;
           CLOSE bcl_amount ;
           If g_credit_amount < p_override_amount then
              l_bsl_credit_amount :=  l_bsl_credit_amount + ((-1)*(p_override_amount - g_credit_amount)) ;
              l_bsl_id := g_bsl_id;

              UPDATE oks_bill_sub_lines
                 SET amount = l_bsl_credit_amount
               WHERE id = l_bsl_id ;

              l_bcl_credit_amount :=  l_bcl_credit_amount + ((-1)*(p_override_amount - g_credit_amount)) ;
              l_bcl_id := g_bcl_id;

              UPDATE oks_bill_cont_lines
                 SET amount = l_bcl_credit_amount
               WHERE id = l_bcl_id ;
              g_credit_amount := 0;
           Elsif g_credit_amount > p_override_amount then

              l_bsl_credit_amount :=  l_bsl_credit_amount + (g_credit_amount - p_override_amount ) ;
              l_bsl_id := g_bsl_id;

              UPDATE oks_bill_sub_lines
                 SET amount = l_bsl_credit_amount
               WHERE id  = l_bsl_id ;

              l_bcl_credit_amount :=  l_bcl_credit_amount + (g_credit_amount - p_override_amount) ;
              l_bcl_id := g_bcl_id;

              UPDATE oks_bill_cont_lines
                 SET amount = l_bcl_credit_amount
               WHERE id    = l_bcl_id ;
              g_credit_amount := 0;
           End If;
       END IF;
    -- End of code for Bug # 3666203
       --04-JAN-2006 mchoudha for bug#4738970
       -- bug#5210918. Changed l_status to l_status_code

        IF l_status_code in ('ACTIVE','HOLD','SIGNED','ENTERED','EXPIRED')
            --bug#5135382: added 1 to l_last_day_term to take care of expired status
            AND (p_termination_date <= Nvl(l_last_day_term+1,p_termination_date))
            AND p_termination_date <= sysdate THEN

             IF l_status_code in ('ACTIVE','HOLD','SIGNED','EXPIRED') then
                OKC_ASSENT_PUB.get_default_status( x_return_status => l_return_status,
                                                     p_status_type   => 'TERMINATED',
                                                     x_status_code   => l_ter_status_code );

                IF l_return_status <> 'S' THEN
                   Raise G_EXCEPTION_HALT_VALIDATION;
                END IF;


                l_clev_tbl_in(1).sts_code := l_ter_status_code;
             ELSIF l_status_code = 'ENTERED' then
                OKC_ASSENT_PUB.get_default_status( x_return_status => l_return_status,
                                                    p_status_type   => 'CANCELLED',
                                                    x_status_code   => l_can_status_code);

                IF l_return_status <> 'S' THEN
                  Raise G_EXCEPTION_HALT_VALIDATION;
                END IF;
                l_clev_tbl_in(1).sts_code := l_can_status_code;
             END IF;
        END IF;

        --END added by mchoudha

        -- Code change for bug # 3393329 starts  --
        -- The following code was added as part of bug #3393329.Since
        -- the direct update was done before , the minor version number
        -- were not getting updated in contract. Before this code was added
        -- update to okc_k_lines_b was done directly.
        l_clev_tbl_in( 1 ).id              := p_cle_id;
        l_clev_tbl_in( 1 ).date_terminated := p_termination_date;
        l_clev_tbl_in( 1 ).trn_code        := p_terminate_reason;
        l_clev_tbl_in( 1 ).term_cancel_source  :=  P_Term_Cancel_source;
        okc_contract_pub.update_contract_line(
               p_api_version                   => l_api_version,
               p_init_msg_list                 => l_init_msg_list,
               p_restricted_update             => okc_api.g_true,
               x_return_status                 => l_return_status,
               x_msg_count                     => l_msg_cnt,
               x_msg_data                      => l_msg_data,
               p_clev_tbl                      => l_clev_tbl_in,
               x_clev_tbl                      => l_clev_tbl_out);

/* Modified by sjanakir for Bug#6912454 */

        IF l_return_status <> 'S' THEN
           Raise G_EXCEPTION_HALT_VALIDATION;
        END IF;
        -- Code change for bug # 3393329 ends  --

       -- Added true value code for order originated contracts.----
       --xyz
       l_true_value_tbl(1).p_cp_line_id           := p_cle_id; --Sub line id
       l_true_value_tbl(1).p_top_line_id          := 0;        --Top line id
       l_true_value_tbl(1).p_hdr_id               := 0 ;       --Header id ;
       l_true_value_tbl(1).p_termination_date     := p_termination_date;
       l_true_value_tbl(1).p_terminate_reason     := p_terminate_reason;
       l_true_value_tbl(1).p_override_amount      := p_override_amount;
       l_true_value_tbl(1).p_con_terminate_amount := l_con_terminate_amount;
       l_true_value_tbl(1).p_termination_amount   := l_termination_amount;
       l_true_value_tbl(1).p_suppress_credit      := p_suppress_credit;
       l_true_valUe_tbl(1).p_full_credit          := p_full_credit ;

/* Modified by sjanakir for Bug#6912454 */
       True_value(l_true_value_tbl , l_return_status );
       x_return_status := l_return_status;
       ------------------------------------------------------------
      ELSE

        l_billed := FALSE;

        IF (l_lse_id = 13) THEN
          OPEN sub_line_billed_cur(p_cle_id);
          FETCH sub_line_billed_cur into l_number;
          IF (sub_line_billed_cur%FOUND) THEN
            l_billed := TRUE;
          ELSE
            l_billed := FALSE;
          END IF;
          CLOSE sub_line_billed_cur;

           --bug#5276678
	   -- bug#5276678 commenting IF condition

           IF ( p_override_amount IS NULL) THEN

	     l_termination_amount := nvl(l_con_termination_amount,0);


/*
            OPEN  neg_bcl_amount_line(l_top_line_id);
            FETCH neg_bcl_amount_line into l_neg_amount;
	    CLOSE neg_bcl_amount_line;

           --IF (nvl(l_neg_amount,0) < 0) THEN

	     OPEN  pos_bcl_amount_line(l_top_line_id);
             FETCH pos_bcl_amount_line into l_con_termination_amount;
             CLOSE pos_bcl_amount_line;

	     l_override_amount := nvl(l_con_termination_amount,0) +  nvl(l_neg_amount,0) ;

	   --END IF;
*/

           END IF;

         --End bug#5276678

        END IF;

        l_term_date := p_termination_date;

        Terminate_cp(
           P_CALLEDFROM           => p_calledfrom,
           P_TOP_LINE_ID          => l_top_line_id,
           P_CP_LINE_ID           => p_cle_id,
           P_TERMINATION_DATE     => l_term_date,--p_termination_date
           P_TERMINATE_REASON     => p_terminate_reason,
         --P_OVERRIDE_AMOUNT      => p_override_amount,
           P_OVERRIDE_AMOUNT      => l_override_amount, --bug#5276678
           P_CON_TERMINATE_AMOUNT => l_con_terminate_amount,
           --P_EXISTING_CREDIT      => p_existing_credit,
           P_TERMINATION_AMOUNT   => l_termination_amount ,
           P_SUPPRESS_CREDIT      => p_suppress_credit,
           P_FULL_CREDIT          => p_full_credit,
           P_TERM_METHOD          => l_term_method,
           P_USAGE_TYPE           => l_usage_type,
           P_USAGE_PERIOD         => l_usage_period,
           P_Term_Cancel_source   => P_Term_Cancel_source,
           X_RETURN_STATUS        => X_return_status);

        IF x_return_status <> 'S' Then
          Raise G_EXCEPTION_HALT_VALIDATION;
        END IF;
      END IF;
    END IF;
    CLOSE check_lse_id;

  END IF;  -- check_term_cur%NOTFOUND
  CLOSE check_term_cur;

   update oks_k_lines_b topline set topline.tax_amount =  ( select sum(tax_amount) from
                  oks_k_lines_b oksline, okc_k_lines_b okcline
                  where okcline.id = oksline.cle_id
                    and okcline.cle_id = l_top_line_id
                    and okcline.date_cancelled is null )
   where  topline.cle_id = l_top_line_id;

   update oks_k_headers_b hdr set hdr.tax_amount =  ( select sum(tax_amount) from
                  oks_k_lines_b oksline, okc_k_lines_b okcline
                  where okcline.id = oksline.cle_id
                  and okcline.dnz_chr_id = l_hdr_id
                  and okcline.date_cancelled is null
                  and lse_id in (1,12,19,46) )
   where  hdr.chr_id =  l_hdr_id;

-- BUG#3312595 mchoudha : added exception to catch any
 --exceptions raised


EXCEPTION
   WHEN G_EXCEPTION_HALT_VALIDATION THEN
   NULL;

END pre_terminate_cp;


PROCEDURE terminate_cp
  (
    P_CALLEDFROM                  IN          NUMBER DEFAULT Null,
    P_TOP_LINE_ID                 IN          NUMBER,
    P_CP_LINE_ID                  IN          NUMBER,
    P_TERMINATION_DATE            IN          DATE,
    P_TERMINATE_REASON            IN          VARCHAR2,
    P_OVERRIDE_AMOUNT             IN          NUMBER,
    P_CON_TERMINATE_AMOUNT        IN          NUMBER,
    --P_EXISTING_CREDIT             IN          NUMBER,
    P_TERMINATION_AMOUNT          IN          NUMBER ,
    P_SUPPRESS_CREDIT             IN          VARCHAR2,
    P_FULL_CREDIT                 IN          VARCHAR2,
    P_TERM_METHOD                 IN          VARCHAR2,
    P_USAGE_TYPE                  IN          VARCHAR2,
    P_USAGE_PERIOD                IN          VARCHAR2,
    P_Term_Cancel_source          IN          VARCHAR2,
    X_RETURN_STATUS               OUT NOCOPY  VARCHAR2
  )IS

CURSOR max_date_billed_to_Cur (p_cle_id  IN  NUMBER)
IS
 SELECT max(date_billed_to)
  FROM oks_bill_sub_lines
  WHERE cle_id = p_cle_id;

Cursor l_line_csr(p_id in NUMBER) is
SELECT start_date,end_date,sts_code,
       lse_id,
       dnz_chr_id
  FROM okc_k_lines_b
  WHERE id = p_id ;


Cursor l_usage_csr(p_id in NUMBER) is
SELECT usage_type
FROM oks_k_lines_b
WHERE cle_id = p_id ;

-- BUG#3312595 mchoudha: Cursor to check for service request
-- against the subline

/***************************************************
Cursor cur_subline_sr(p_id IN NUMBER) IS
SELECT 'x'
FROM CS_INCIDENTS_ALL_B  sr,
     okc_k_items cim
where cim.cle_id = p_id
and   sr.customer_product_id =  cim.object1_id1
and   sr.status_flag = 'O';
***************************************************/

Cursor cur_subline_sr(p_id IN NUMBER) IS
SELECT 'x'
FROM  okc_k_items cim,
      CS_INCIDENTS_ALL_B  sr
where cim.cle_id = p_cp_line_id
and   sr.contract_service_id = p_top_line_id
and   sr.customer_product_id = to_number(cim.object1_id1)
and   sr.status_flag = 'O' ;

Cursor cur_lineno(p_id IN NUMBER) IS
SELECT p.line_number||'.'||s.line_number,
       hdr.contract_number
FROM   okc_k_lines_b p,
       okc_k_lines_b s,
       okc_k_headers_b hdr
WHERE  s.id=p_id
AND    p.id=s.cle_id
AND    hdr.id=p.dnz_chr_id;


-- End BUG#3312595 mchoudha


 Cursor bcl_amount (p_bcl_id in number) is
 Select amount from oks_bill_cont_lines
  where id = p_bcl_id;

 Cursor bsl_amount (p_bsl_id in number) is
 Select amount from oks_bill_sub_lines
  where id = p_bsl_id;

 l_bcl_credit_amount            NUMBER;
 l_bsl_credit_amount            NUMBER;
 l_bsl_id                       NUMBER;
 l_bcl_id                       NUMBER;

l_return_status                       VARCHAR2(20);
l_msg_cnt                             NUMBER;
l_msg_data                            VARCHAR2(2000);
l_amount                              NUMBER;
l_api_version         CONSTANT        NUMBER     := 1.0;
l_init_msg_list       CONSTANT        VARCHAR2(1):= 'F';
l_termination_date                    DATE;
l_termn_date                    DATE;
l_lse_id                              NUMBER;
l_max_date                            DATE;
l_status_flag                         VARCHAR2(1);
l_line_number                         VARCHAR2(500);
l_contract_number                     VARCHAR2(120);
 --04-JAN-2006 mchoudha for bug#4738970
 --Added these variables
 l_ter_status_code              varchar2(30);
 l_status                       fnd_lookups.lookup_code%type;
 l_can_status_code              varchar2(30);
 l_last_day_term                        DATE;
 l_usage_type                          VARCHAR2(10);

l_true_value_tbl                      L_TRUE_VAL_TBL  ;
l_clev_tbl_in                  OKC_CONTRACT_PUB.clev_tbl_type;
l_clev_tbl_out                 OKC_CONTRACT_PUB.clev_tbl_type;


   -------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 30-MAY-2005
-- local variables for partal periods
-------------------------------------------------------------------------
l_hdr_id              NUMBER;
l_price_uom           OKS_K_HEADERS_B.PRICE_UOM%TYPE;
l_period_start        OKS_K_HEADERS_B.PERIOD_START%TYPE;
l_period_type         OKS_K_HEADERS_B.PERIOD_TYPE%TYPE;


BEGIN

-- BUG#3312595 mchoudha: Checking for service request
-- against the subline

    OPEN l_line_csr(p_cp_line_id);
    FETCH l_line_csr into l_termn_date,l_last_day_term,l_status,l_lse_id,l_hdr_id ;
    CLOSE l_line_csr ;

    -- Open Service Request Check should not be done for
    -- P_CALLEDFROM = -1. -1 is used for IB Integration
    -- No Other Callers should pass -1 as P_CALLEDFROM

    IF NVL(P_CALLEDFROM,0) <> -1
    THEN

    --BUG 4477943 IF condition to check lse_id for products only
    IF l_lse_id IN(9,18,25)
    THEN

    OPEN cur_subline_sr(p_top_line_id);
    FETCH cur_subline_sr into l_status_flag;
    CLOSE cur_subline_sr;

    if(l_status_flag = 'x') THEN

      OPEN cur_lineno(p_cp_line_id);
      FETCH cur_lineno into l_line_number,l_contract_number;
      CLOSE cur_lineno;


      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => 'OKC_SR_PENDING',
                          p_token1        => 'NUMBER',
                          p_token1_value  => l_contract_number,
                          p_token2        => 'LINENO',
                          p_token2_value  =>  l_line_number);

      l_return_status := okc_api.g_ret_sts_error;
      raise  G_EXCEPTION_HALT_VALIDATION;
    end if;

    END IF; -- if lse_id in(9,18,25)

    END IF; -- For P_CALLEDFROM

-- END BUG#3312595 mchoudha

    -------------------------------------------------------------------------
    -- Begin partial period computation logic
    -- Developer Mani Choudhary
    -- Date 30-MAY-2005
    -- Call oks_renew_util_pub.get_period_defaults to fetch period start and period type
    -------------------------------------------------------------------------
    IF l_hdr_id IS NOT NULL  and p_full_credit <> 'Y' THEN
      OKS_RENEW_UTIL_PUB.Get_Period_Defaults
                (
                 p_hdr_id        =>l_hdr_id,
                 p_org_id        => NULL,
                 x_period_start  => l_period_start,
                 x_period_type   => l_period_type,
                 x_price_uom     => l_price_uom,
                 x_return_status => l_return_status);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Terminate_cp.ppc_defaults',
         'After calling OKS_RENEW_UTIL_PUB.Get_Period_Defaults l_period_start ' ||l_period_start||' ,l_period_type '||l_period_type);
      END IF;


      IF l_return_status <> 'S' THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

    END IF;
    --For usage , the period start should be SERVICE
    IF l_lse_id = 13 AND l_period_start is NOT NULL THEN
      l_period_start := 'SERVICE';
      l_usage_type := NULL;
      Open l_usage_csr(P_TOP_LINE_ID);
      Fetch l_usage_csr into l_usage_type;
      Close l_usage_csr;
    END IF;
    -------------------------------------------------------------------------
    -- End partial period computation logic
    -------------------------------------------------------------------------
    IF (p_full_credit = 'Y') THEN
      l_termination_date := l_termn_date ;
    ELSIF (p_full_credit = 'N')  THEN
      l_termination_date := p_termination_date;
    END IF;

    l_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_term_method = 'VOLUME') THEN
      pre_vol_based_terminate(
             P_CALLEDFROM               => 1 ,
             P_API_VERSION              => 1.0,
             P_INIT_MSG_LIST            => l_init_msg_list ,
             X_RETURN_STATUS            => l_return_status ,
             X_MSG_COUNT                => l_msg_cnt ,
             X_MSG_DATA                 => l_msg_data ,
             P_K_LINE_ID                => p_top_line_id ,
             P_CP_LINE_ID               => p_cp_line_id,
             P_TERMINATION_DATE         => l_termination_date ,
             P_TERMINATION_AMOUNT       => p_termination_amount ,
             P_CON_TERMINATION_AMOUNT   => p_con_terminate_amount ,
             --P_EXISTING_CREDIT          => p_existing_credit ,
             P_SUPPRESS_CREDIT          => p_suppress_credit ,
             P_USAGE_TYPE               => p_usage_type ,
             P_USAGE_PERIOD             => p_usage_period ,
             X_AMOUNT                   => l_amount ) ;
    ELSE

      OPEN  max_date_billed_to_Cur(p_cp_line_id);
      FETCH max_date_billed_to_Cur into l_max_date;
      CLOSE max_date_billed_to_Cur;
      IF l_period_start IS NOT NULL AND
         l_period_type IS NOT NULL
     THEN
        IF l_lse_id <> 13 OR nvl(l_usage_type,'XYZ') = 'NPR' THEN
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Terminate_cp.Service',
             'calling OKS_BILL_REC_PUB.Terminate_PPC with parameters  l_period_start '||l_period_start||', l_period_type '||l_period_type
             ||' P_override_amount ' ||p_override_amount||'p_con_terminate_amount '||p_con_terminate_amount||' ,P_suppress_credit'||P_suppress_credit);
          END IF;
          OKS_BILL_REC_PUB.Terminate_PPC
               (P_termination_date => l_termination_date,
                p_end_date         => l_max_date,
                P_top_line_id      => p_top_line_id,
                P_cp_line_id       => p_cp_line_id,
                P_period_start     => l_period_start,
                P_period_type      => l_period_type,
                P_suppress_credit  => p_suppress_credit,
                P_override_amount  => p_override_amount,
                p_con_terminate_amount => p_con_terminate_amount,
                x_return_status    => l_return_status);
          IF l_return_status <> 'S' THEN
             RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
        ELSE
          --This procedure will be called for usage amount based termination
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Terminate_cp.Usage',
             'calling OKS_BILL_REC_PUB.Create_trx_records with parameters  l_period_start '||l_period_start||', l_period_type '||l_period_type
             ||' P_override_amount ' ||p_override_amount||'p_con_terminate_amount '||p_con_terminate_amount||' ,P_suppress_credit'||P_suppress_credit);
          END IF;
          Create_trx_records(
                p_called_from          => 1,
                p_top_line_id          => p_top_line_id,
                p_cov_line_id          => p_cp_line_id,
                p_date_from            => l_termination_date,
                p_date_to              => l_max_date,
                p_amount               => 0,
                p_override_amount      => p_override_amount,
                p_suppress_credit      => p_suppress_credit,
                p_con_terminate_amount => p_con_terminate_amount,
                --p_existing_credit      => p_existing_credit,
                p_bill_action          => 'TR',
                p_period_start         => l_period_start,
                p_period_type          => l_period_type,
                x_return_status        => l_return_status
                );
           IF l_return_status <> 'S' THEN
             RAISE G_EXCEPTION_HALT_VALIDATION;
           END IF;
        END IF;
      ELSE

        Create_trx_records(
           p_called_from          => 1,
           p_top_line_id          => p_top_line_id,
           p_cov_line_id          => p_cp_line_id,
           p_date_from            => l_termination_date,
           p_date_to              => l_max_date,
           p_amount               => 0,
           p_override_amount      => p_override_amount,
           p_suppress_credit      => p_suppress_credit,
           p_con_terminate_amount => p_con_terminate_amount,
           --p_existing_credit      => p_existing_credit,
           p_bill_action          => 'TR',
           x_return_status        => l_return_status
             );
         IF l_return_status <> 'S' THEN
           RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;
      END IF;
    END IF;




    OKS_BILL_SCH.terminate_bill_sch(
          P_TOP_LINE_ID         => p_top_line_id,
          P_SUB_LINE_ID         => p_cp_line_id,
          P_TERM_DT             => l_termination_date,
          X_RETURN_STATUS       => l_return_status,
          X_MSG_COUNT           => l_msg_cnt,
          X_MSG_DATA            => l_msg_data);

    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
      Raise G_EXCEPTION_HALT_VALIDATION;
    END IF;


       --04-JAN-2006 mchoudha for bug#4738970

        IF l_status in ('ACTIVE','HOLD','SIGNED','ENTERED','EXPIRED')
            --bug#5135382 added 1 to l_last_day_term to take care of expired status
            AND (p_termination_date <= Nvl(l_last_day_term+1,p_termination_date))
            AND p_termination_date <= sysdate THEN

             IF l_status in ('ACTIVE','HOLD','SIGNED','EXPIRED') then
                OKC_ASSENT_PUB.get_default_status( x_return_status => l_return_status,
                                                     p_status_type   => 'TERMINATED',
                                                     x_status_code   => l_ter_status_code );

                IF l_return_status <> 'S' THEN
                   Raise G_EXCEPTION_HALT_VALIDATION;
                END IF;


                l_clev_tbl_in(1).sts_code := l_ter_status_code;
             ELSIF l_status = 'ENTERED' then
                OKC_ASSENT_PUB.get_default_status( x_return_status => l_return_status,
                                                    p_status_type   => 'CANCELLED',
                                                    x_status_code   => l_can_status_code);

                IF l_return_status <> 'S' THEN
                  Raise G_EXCEPTION_HALT_VALIDATION;
                END IF;
                l_clev_tbl_in(1).sts_code := l_can_status_code;
             END IF;
        END IF;

        --END added by mchoudha

     -- Code change for bug # 3393329 starts  --
     -- The following code was added as part of bug #3393329.Since
     -- the direct update was done before , the minor version number
     -- were not getting updated in contract. Before this code was added
     -- update to okc_k_lines_b was done directly.
     l_clev_tbl_in( 1 ).id              := p_cp_line_id;
     l_clev_tbl_in( 1 ).date_terminated := p_termination_date;
     l_clev_tbl_in( 1 ).trn_code        := p_terminate_reason;
     l_clev_tbl_in( 1 ).term_cancel_source  :=  P_Term_Cancel_source;
     okc_contract_pub.update_contract_line(
               p_api_version                   => l_api_version,
               p_init_msg_list                 => l_init_msg_list,
               p_restricted_update             => okc_api.g_true,
               x_return_status                 => l_return_status,
               x_msg_count                     => l_msg_cnt,
               x_msg_data                      => l_msg_data,
               p_clev_tbl                      => l_clev_tbl_in,
               x_clev_tbl                      => l_clev_tbl_out);

/* Modified by sjanakir for Bug#6912454 */
    IF l_return_status <> 'S' THEN
       Raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- Code change for bug # 3393329 ends  --

    -- Added code for Bug # 3666203
       IF ((p_override_amount  is NOT NULL) and (g_credit_amount <> p_override_amount )) THEN
           OPEN  bsl_amount(g_bsl_id);
           FETCH bsl_amount into l_bsl_credit_amount;
           CLOSE bsl_amount ;

           OPEN  bcl_amount(g_bcl_id);
           FETCH bcl_amount into l_bcl_credit_amount;
           CLOSE bcl_amount ;
           If g_credit_amount < p_override_amount then
              l_bsl_credit_amount :=  l_bsl_credit_amount + ((-1)*(p_override_amount - g_credit_amount)) ;
              l_bsl_id := g_bsl_id;

              UPDATE oks_bill_sub_lines
                 SET amount = l_bsl_credit_amount
               WHERE id = l_bsl_id ;

              l_bcl_credit_amount :=  l_bcl_credit_amount + ((-1)*(p_override_amount - g_credit_amount)) ;
              l_bcl_id := g_bcl_id;

              UPDATE oks_bill_cont_lines
                 SET amount = l_bcl_credit_amount
               WHERE id = l_bcl_id ;
              g_credit_amount := 0;
           Elsif g_credit_amount > p_override_amount then

              l_bsl_credit_amount :=  l_bsl_credit_amount + (g_credit_amount - p_override_amount ) ;
              l_bsl_id := g_bsl_id;

              UPDATE oks_bill_sub_lines
                 SET amount = l_bsl_credit_amount
               WHERE id  = l_bsl_id ;

              l_bcl_credit_amount :=  l_bcl_credit_amount + (g_credit_amount - p_override_amount) ;
              l_bcl_id := g_bcl_id;

              UPDATE oks_bill_cont_lines
                 SET amount = l_bcl_credit_amount
               WHERE id    = l_bcl_id ;
              g_credit_amount := 0;
           End If;
       END IF;
      g_bsl_id := 0;
      g_bcl_id := 0;
    -- End of code for Bug # 3666203
    --mchoudha 11510+ Usage Tax and Price Display
    --added the condition P_USAGE_TYPE = 'NPR'
    If l_lse_id <> 13 OR P_USAGE_TYPE = 'NPR' then
       l_true_value_tbl(1).p_cp_line_id       := p_cp_line_id;
       l_true_value_tbl(1).p_top_line_id      := 0;   --Top line id
       l_true_value_tbl(1).p_hdr_id           := 0 ;  --Header id ;
       l_true_value_tbl(1).p_termination_date := p_termination_date;
       l_true_value_tbl(1).p_terminate_reason := p_terminate_reason;
       l_true_value_tbl(1).p_override_amount  := p_override_amount;
       l_true_value_tbl(1).p_con_terminate_amount := p_con_terminate_amount;
       l_true_value_tbl(1).p_termination_amount   := p_termination_amount;
       l_true_value_tbl(1).p_suppress_credit      := p_suppress_credit;
       l_true_valUe_tbl(1).p_full_credit          := p_full_credit ;
       /* Modified by sjanakir for Bug#6912454 */
       True_value(l_true_value_tbl , l_return_status );
    End IF;

     x_return_status := l_return_status;

  EXCEPTION
   WHEN  G_EXCEPTION_HALT_VALIDATION THEN
          x_return_status := l_return_status;
   WHEN  OTHERS THEN
          OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN,SQLERRM);
  END terminate_cp;

Procedure get_termination_details ( p_level IN VARCHAR2 ,
                                    p_id IN NUMBER ,
                                    x_unbilled OUT NOCOPY NUMBER ,
                                    x_credited OUT NOCOPY NUMBER ,
                                    x_suppressed OUT NOCOPY NUMBER ,
                                    x_overridden OUT NOCOPY NUMBER ,
                                    x_billed OUT NOCOPY NUMBER ,
                                    x_return_status OUT NOCOPY VARCHAR2 ) is

--mchoudha 11510+ Usage Tax and Price Display
--added NOT Exists clause and lse_id 13
CURSOR l_HDR_CSR IS
SELECT nvl(SUM(ubt_amount),0) unbilled
      ,nvl(SUM(credit_amount),0) credited
      ,nvl(SUM(suppressed_credit),0) suppressed
      ,nvl(SUM(override_amount),0) overridden
  FROM OKC_K_LINES_B OKCL
      ,OKS_K_LINES_B OKSL
 WHERE OKCL.dnz_chr_id = p_id
   AND OKCL.lse_id in ( 7,8,9,10,11,13,25,35,46)
   AND OKCL.id = OKSL.cle_id
   AND NOT exists (select 'x' from okc_k_lines_b cle,
                                   oks_k_lines_b kln
                   where cle.id = OKCL.cle_id
                   and   kln.cle_id = cle.id
                   and   kln.usage_type in ('VRT','QTY','FRT'));

--mchoudha 11510+ Usage Tax and Price Display
--added NOT Exists clause and lse_id 13
CURSOR L_HDR_BILLED_CSR IS
SELECT nvl(SUM(BSL.amount),0) billed
FROM OKC_K_LINES_B OKCL
    ,OKS_BILL_CONT_LINES BCL
    ,OKS_BILL_SUB_LINES BSL
WHERE OKCL.dnz_chr_id = p_id
  AND OKCL.lse_id in ( 7,8,9,10,11,13,25,35,46)
  AND OKCL.id = BSL.cle_id
  AND BSL.bcl_id = BCL.id
  AND BCL.bill_action = 'RI'
  AND NOT exists (select 'x' from okc_k_lines_b cle,
                                  oks_k_lines_b kln
                   where cle.id = OKCL.cle_id
                   and   kln.cle_id = cle.id
                   and   kln.usage_type in ('VRT','QTY','FRT'));



--mchoudha 11510+ Usage Tax and Price Display
--added NOT Exists clause and lse_id 13
CURSOR l_TOP_LINE_CSR IS
SELECT nvl(SUM(ubt_amount),0) unbilled
      ,nvl(SUM(credit_amount),0) credited
      ,nvl(SUM(suppressed_credit),0) suppressed
      ,nvl(SUM(override_amount),0) overridden
  FROM OKC_K_LINES_B OKCL
      ,OKS_K_LINES_B OKSL
 WHERE (    OKCL.cle_id = p_id
        OR (OKCL.id = p_id and OKCL.lse_id = 46 ))
   AND OKCL.lse_id in ( 7,8,9,10,11,13,25,35,46)
   AND OKCL.id = OKSL.cle_id
   AND NOT exists (select 'x' from okc_k_lines_b cle,
                                  oks_k_lines_b kln
                   where cle.id = OKCL.cle_id
                   and   kln.cle_id = cle.id
                   and   kln.usage_type in ('VRT','QTY','FRT'));


--mchoudha 11510+ Usage Tax and Price Display
--added NOT Exists clause and lse_id 13
CURSOR l_TOP_LINE_BILLED_CSR IS
SELECT nvl(SUM(BSL.amount),0) billed
FROM OKC_K_LINES_B OKCL
    ,OKS_BILL_CONT_LINES BCL
    ,OKS_BILL_SUB_LINES BSL
WHERE ( OKCL.cle_id = p_id
      OR ( OKCL.ID = p_id and OKCL.lse_id = 46))
  AND OKCL.lse_id in ( 7,8,9,10,11,13,25,35,46)
  AND OKCL.id = BSL.cle_id
  AND BSL.bcl_id = BCL.id
  AND BCL.bill_action = 'RI'
  AND NOT exists (select 'x' from okc_k_lines_b cle,
                                  oks_k_lines_b kln
                   where cle.id = OKCL.cle_id
                   and   kln.cle_id = cle.id
                   and   kln.usage_type in ('VRT','QTY','FRT'));



CURSOR l_SUB_LINE_CSR IS
SELECT nvl(SUM(ubt_amount),0) unbilled
      ,nvl(SUM(credit_amount),0) credited
      ,nvl(SUM(suppressed_credit),0) suppressed
      ,nvl(SUM(override_amount),0) overridden
  FROM OKS_K_LINES_B OKSL
 WHERE OKSL.cle_id = p_id;

CURSOR l_SUB_LINE_BILLED_CSR IS
SELECT nvl(SUM(BSL.amount),0) billed
FROM OKS_BILL_CONT_LINES BCL
    ,OKS_BILL_SUB_LINES BSL
WHERE BSL.cle_id = p_id
  AND BSL.bcl_id = BCL.id
  AND BCL.bill_action = 'RI';
l_unbilled NUMBER ;
l_credited NUMBER ;
l_suppressed NUMBER ;
l_overridden NUMBER ;
l_billed NUMBER ;
l_return_status varchar2(10);

BEGIN
x_return_status := 'S';
 If p_level = 'H' then
    Open l_HDR_CSR;
    Fetch l_HDR_CSR into l_unbilled , l_credited, l_suppressed,l_overridden ;
    Close l_HDR_CSR;
    Open L_HDR_BILLED_CSR;
    Fetch L_HDR_BILLED_CSR into l_billed ;
    Close L_HDR_BILLED_CSR;
 Elsif p_level = 'T' then
    Open l_TOP_LINE_CSR;
    Fetch l_TOP_LINE_CSR into l_unbilled , l_credited, l_suppressed,l_overridden ;
    Close l_TOP_LINE_CSR ;
    Open l_TOP_LINE_BILLED_CSR;
    Fetch l_TOP_LINE_BILLED_CSR into l_billed ;
    Close l_TOP_LINE_BILLED_CSR;
 Elsif p_level = 'S' then
    Open l_SUB_LINE_CSR;
    Fetch l_SUB_LINE_CSR into l_unbilled , l_credited, l_suppressed,l_overridden ;
    Close l_SUB_LINE_CSR;
    Open l_SUB_LINE_BILLED_CSR;
    Fetch l_SUB_LINE_BILLED_CSR into l_billed ;
    Close l_SUB_LINE_BILLED_CSR;
 End If;
 x_unbilled   := l_unbilled ;
 x_credited   := l_credited ;
 x_suppressed := l_suppressed;
 x_overridden := l_overridden;
 x_billed     := l_billed ;
END get_termination_details ;

PROCEDURE TRUE_VALUE ( p_true_value_tbl   IN            L_TRUE_VAL_TBL ,
                       x_return_status   OUT  NOCOPY    VARCHAR2 )Is

 CURSOR l_hdr_csr (p_top_line_id in NUMBER ) is
 SELECT id top_line_id ,
        dnz_chr_id hdr_id,
        lse_id lse_id,
        price_negotiated price_negotiated
   FROM okc_k_lines_b okcl
  WHERE dnz_chr_id = p_top_line_id
    AND okcl.lse_id in (1,12,14,19,46)
    AND okcl.date_cancelled is null --LLC BUG FIX 4742661
    AND okcl.date_terminated is null ;

--mchoudha 11510+ Usage Tax and Price Display
--added for usage lines lse_id 13
 CURSOR l_top_line_csr (p_top_line_id in NUMBER ) is
 SELECT id          sub_line_id ,
        dnz_chr_id  hdr_id,
        start_date  start_date
   FROM okc_k_lines_b okcl
  WHERE cle_id = p_top_line_id
    AND okcl.lse_id in (7,8,9,10,11,13,35,25)
    AND okcl.date_cancelled is NULL --LLC BUG FIX 4742661
    AND okcl.date_terminated is null ;

 CURSOR l_sub_line_csr (p_sub_line_id in NUMBER ) is
 SELECT Price_negotiated orginal_amount ,
        cle_id top_line_id ,
        dnz_chr_id hdr_id
   FROM okc_k_lines_b okcl
  WHERE id = p_sub_line_id ;

 CURSOR l_bill_amount_csr(p_sub_line_id in NUMBER ) is
 SELECT sum(nvl(amount,0)) bill_amount
   FROM oks_level_elements
  WHERE cle_id = p_sub_line_id ;

 CURSOR l_credit_csr(p_sub_line_id in NUMBER ) is
 SELECT sum(bsl.amount) suppressed_credit
   FROM oks_bill_sub_lines bsl,
        oks_bill_cont_lines bcl
  WHERE bsl.cle_id = p_sub_line_id
    AND bcl.id = bsl.bcl_id
    AND btn_id is null
    AND bcl.bill_action = 'TR';

 CURSOR l_suppressed_credit_csr(p_sub_line_id in NUMBER )  is
 SELECT sum(bsl.amount) suppressed_credit
   FROM oks_bill_sub_lines bsl,
        oks_bill_cont_lines bcl
  WHERE bsl.cle_id = p_sub_line_id
    AND bcl.id = bsl.bcl_id
    AND btn_id = -44
    AND bcl.bill_action = 'TR';

 CURSOR l_lse_id_csr (p_id IN number )is
 SELECT lse_id ,
        price_negotiated,
        dnz_chr_id
   FROM OKC_K_LINES_B OKCL
  WHERE OKCL.id = p_id ;

 CURSOR L_HDR_CURR_CODE (p_id in number ) is
 SELECT currency_code
   FROM okc_k_headers_b
  WHERE id = p_id;

 CURSOR l_line_curr_code (p_id in number ) is
 SELECT hdr.currency_code ,hdr.id
   FROM okc_k_lines_b lines,
        okc_k_headers_b hdr
  WHERE lines.id = p_id
    AND hdr.id = lines.dnz_chr_id;

 CURSOR l_check_for_full_credit(p_top_line_id in NUMBER ) is
 SELECT count(oks.full_credit)
   FROM OKC_K_LINES_B OKC,
        OKS_K_LINES_B OKS
  WHERE OKC.cle_ID = p_top_line_id
    AND OKC.id = OKS.CLE_id
    and OKC.lse_id in (7,8,9,10,11,13,18,25,35)
    and OKC.date_cancelled is NULL --LLC BUG FIX 4742661
    and OKC.date_terminated is not null
    and ( oks.full_credit is null
          OR oks.full_credit = 'N' );

--mchoudha 11510+ Usage Tax and Price Display
--added the following two cursors to retrieve the usage type
Cursor l_usage_type_csr(p_sub_line_id in number) Is
Select kln.usage_type
from   okc_k_lines_b cle1,
       okc_k_lines_b cle2,
       oks_k_lines_b kln
where  cle1.id = p_sub_line_id
and    cle2.id = cle1.cle_id
and    kln.cle_id = cle2.id;

Cursor l_usage_type_csr1(p_top_line_id in number) Is
Select usage_type
from   oks_k_lines_b
where  cle_id = p_top_line_id;

Cursor l_ubt_csr(p_id in number) IS
SELECT ubt_amount
FROM   OKS_K_LINES_B
WHERE  cle_id = p_id;



 l_top_line_rec           l_top_line_csr%ROWTYPE;
 l_hdr_rec                l_hdr_csr%ROWTYPE;
 l_lse_id_rec             l_lse_id_csr%ROWTYPE;
 l_original_amt           NUMBER ;
 l_bill_amt               NUMBER ;
 l_credit                 NUMBER ;
 l_suppressed_credit      NUMBER ;
 l_overridden             NUMBER ;
 l_true_value             NUMBER ;
 l_terminated_amt         NUMBER ;
 l_ubt_amount             NUMBER ;
 l_top_line_id            NUMBER ;
 l_hdr_id                 NUMBER ;
 l_termn_level            VARCHAR2(10);
 l_return_status          VARCHAR2(1) := 'S';
 l_amount                 NUMBER := 0;
 l_tot_bill_amt           NUMBER ;
 l_tot_ubt_amount         NUMBER :=0 ;
 l_tot_credit             NUMBER :=0 ;
 l_tot_suppressed_credit  NUMBER :=0 ;
 l_tot_overridden         NUMBER :=0 ;
 l_tot_true_value         NUMBER ;
 l_lse_id                 NUMBER :=0 ;
 l_price_negotiated       NUMBER :=0 ;
 G_RAIL_REC               OKS_TAX_UTIL_PVT.ra_rec_type;
 x_msg_count              NUMBER;
 x_msg_data               VARCHAR2(2000);
 l_currency_code          Varchar2(15);
 l_full_yn                Varchar2(3);
 l_full_count             Varchar2(3);
 l_tax_value              NUMBER;
 l_tot_tax_value          NUMBER := 0;
 l_process                BOOLEAN;
 --mchoudha 11510+ Usage Tax and Price Display
 l_usage_type             VARCHAR2(3);
 l_header_id              NUMBER;
 -------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 04-MAY-2005
-------------------------------------------------------------------------
l_price_uom         OKS_K_HEADERS_B.PRICE_UOM%TYPE;
l_period_start      OKS_K_HEADERS_B.PERIOD_START%TYPE;
l_period_type       OKS_K_HEADERS_B.PERIOD_TYPE%TYPE;
-------------------------------------------------------------------------
BEGIN

 x_return_status := 'S';
--mchoudha 11510+ Usage Tax and Price Display
 l_usage_type    := NULL;

 IF p_true_value_tbl(1).p_cp_line_id  > 0 and
    p_true_value_tbl(1).p_top_line_id = 0 and
    p_true_value_tbl(1).p_hdr_id      = 0 then
      l_termn_level := 'CP' ;
      open  l_line_curr_code(p_true_value_tbl(1).p_cp_line_id);
      fetch l_line_curr_code into l_currency_code,l_header_id;
      close l_line_curr_code ;
 ELSIF p_true_value_tbl(1).p_cp_line_id = 0 and
    p_true_value_tbl(1).p_top_line_id   > 0 and
    p_true_value_tbl(1).p_hdr_id        = 0 then
      l_termn_level := 'TL' ;
      open  l_line_curr_code(p_true_value_tbl(1).p_top_line_id);
      fetch l_line_curr_code into l_currency_code,l_header_id;
      close l_line_curr_code ;
 ELSIF p_true_value_tbl(1).p_cp_line_id = 0 and
    p_true_value_tbl(1).p_top_line_id   > 0 and
    p_true_value_tbl(1).p_hdr_id        > 0 then
      l_termn_level := 'TL' ;
      open  l_hdr_curr_code(p_true_value_tbl(1).p_hdr_id);
      fetch l_hdr_curr_code into l_currency_code;
      close l_hdr_curr_code ;
      l_header_id:= p_true_value_tbl(1).p_hdr_id;
 ELSIF p_true_value_tbl(1).p_cp_line_id = 0 and
    p_true_value_tbl(1).p_top_line_id   = 0 and
    p_true_value_tbl(1).p_hdr_id        > 0 then
      l_termn_level := 'HD' ;
      open  l_hdr_curr_code(p_true_value_tbl(1).p_hdr_id);
      fetch l_hdr_curr_code into l_currency_code;
      close l_hdr_curr_code ;
      l_header_id:= p_true_value_tbl(1).p_hdr_id;
 END IF;

 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.TRUE_VALUE',
   ' l_termn_level = ' || l_termn_level);
 END IF;

 --npalepu removed the following code for bug # 5335312.
 --Reverted back the changes made for the bug # 5161038
 /* --mchoudha Fix for bug#5161038
 okc_context.set_okc_org_context(p_chr_id =>l_header_id ); */

 OKS_RENEW_UTIL_PUB.Get_Period_Defaults
                (
                 p_hdr_id        => l_header_id,
                 p_org_id        => NULL,
                 x_period_start  => l_period_start,
                 x_period_type   => l_period_type,
                 x_price_uom     => l_price_uom,
                 x_return_status => x_return_status);

 IF x_return_status <> 'S' THEN
   RAISE G_EXCEPTION_HALT_VALIDATION;
 END IF;

 IF l_termn_level = 'CP' then
    OPEN  l_lse_id_csr (p_true_value_tbl(1).p_cp_line_id);
    FETCH l_lse_id_csr into l_lse_id_rec;
    CLOSE l_lse_id_csr;
    --mchoudha 11510+ Usage Tax and Price Display
    if(l_lse_id_rec.lse_id = 13) Then
      Open l_usage_type_csr(p_true_value_tbl(1).p_cp_line_id);
      Fetch l_usage_type_csr into l_usage_type;
      Close l_usage_type_csr;
    End If;
    --mchoudha 11510+ Usage Tax and Price Display
    --added the condition l_usage_type='NPR'
    IF l_lse_id_rec.lse_id <>13 OR l_usage_type='NPR' then
      -------------------------------------------------------------------------
      --        True value processing for Covered Product Termination        --
      -------------------------------------------------------------------------
      OPEN  l_sub_line_csr(p_true_value_tbl(1).p_cp_line_id ) ;
      FETCH l_sub_line_csr into l_original_amt , l_top_line_id , l_hdr_id ;
      CLOSE l_sub_line_csr ;

      OPEN l_bill_amount_csr(p_true_value_tbl(1).p_cp_line_id ) ;
      FETCH l_bill_amount_csr into l_bill_amt ;
      CLOSE l_bill_amount_csr  ;

      OPEN l_credit_csr(p_true_value_tbl(1).p_cp_line_id ) ;
      FETCH l_credit_csr into l_credit ;
      CLOSE l_credit_csr ;

      OPEN l_suppressed_credit_csr(p_true_value_tbl(1).p_cp_line_id ) ;
      FETCH l_suppressed_credit_csr into l_suppressed_credit ;
      CLOSE l_suppressed_credit_csr ;

      l_true_value := nvl(l_bill_amt,0) +
                      nvl(l_credit,0)   + nvl(l_suppressed_credit,0) ;

      l_ubt_amount := nvl(l_original_amt,0)  - nvl(l_bill_amt,0) ;

      IF l_period_type is not null and l_period_start is not null THEN
         OPEN l_ubt_csr(p_true_value_tbl(1).p_cp_line_id);
         FETCH l_ubt_csr into l_ubt_amount;
         CLOSE l_ubt_csr;
      END IF;
--takintoy bug 4293344
--Changed if condition operator to >= instead of =
      IF p_true_value_tbl(1).p_override_amount >= 0 then
         l_overridden := nvl(p_true_value_tbl(1).p_con_terminate_amount,0)
                      - nvl(p_true_value_tbl(1).p_termination_amount,0);
      ELSE
         l_overridden := 0;
      END IF;

      l_true_value := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_true_value,l_currency_code);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.TRUE_VALUE',
         'Before updating okc_k_lines_b for subline l_true_value = ' || l_true_value);
      END IF;

      UPDATE OKC_K_LINES_B
         SET price_negotiated = l_true_value
       WHERE id = p_true_value_tbl(1).p_cp_line_id;
      If l_credit < 0 then
         l_credit := l_credit * -1;
      End IF;
      If l_suppressed_credit < 0 then
         l_suppressed_credit := l_suppressed_credit * -1 ;
      End if;

      G_RAIL_REC.AMOUNT := l_true_value;
      G_RAIL_REC.AMOUNT_INCLUDES_TAX_FLAG := null;

      OKS_TAX_UTIL_PVT.Get_Tax
         ( p_api_version      => 1.0,
           p_init_msg_list    => OKC_API.G_TRUE,
           p_chr_id           => l_hdr_id,
           p_cle_id           => p_true_value_tbl(1).p_cp_line_id,
           px_rail_rec        => G_RAIL_REC,
           x_msg_count        => x_msg_count,
           x_msg_data         => x_msg_data,
           x_return_status    => l_return_status);
/* Modified by sjanakir for Bug#6912454 */
      IF ( l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      If G_RAIL_REC.AMOUNT_INCLUDES_TAX_FLAG = 'N' then
         l_tax_value := G_RAIL_REC.TAX_VALUE;
      Else
         l_tax_value := 0;
      End If;

      l_ubt_amount := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_ubt_amount,
                                                             l_currency_code);
      l_credit := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_credit,
                                                         l_currency_code);
      l_suppressed_credit :=
                  OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_suppressed_credit,
                                                         l_currency_code);
      l_overridden := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_overridden,
                                                             l_currency_code);

      UPDATE OKS_K_LINES_B
         SET UBT_AMOUNT        = l_ubt_amount ,
             CREDIT_AMOUNT     = l_credit ,
             SUPPRESSED_CREDIT = l_suppressed_credit ,
             OVERRIDE_AMOUNT   = l_overridden ,
             TAX_AMOUNT        = l_tax_value,
             FULL_CREDIT       = nvl(p_true_value_tbl(1).p_full_credit,'N')
       WHERE cle_id = p_true_value_tbl(1).p_cp_line_id;

      UPDATE OKC_K_LINES_B
         SET price_negotiated=(SELECT SUM(price_negotiated)
                                FROM okc_k_lines_b
                               WHERE cle_id = l_top_line_id
                               AND   date_cancelled is null) --LLC BUG FIX 4742661
       WHERE id = l_top_line_id ;

    ---if only subline is terminated, then also update top line ubt, credit_amt,suppressed_credit field
    --so that actual line amt can be found.

     Update OKS_K_lines_b
         set ubt_amount = nvl(ubt_amount,0) + nvl(l_ubt_amount,0),
             CREDIT_AMOUNT     = nvl(CREDIT_AMOUNT,0) + nvl(l_credit,0) ,
             SUPPRESSED_CREDIT = nvl(SUPPRESSED_CREDIT,0) + nvl(l_suppressed_credit,0)
     WHERE cle_id = l_top_line_id;

      UPDATE OKC_K_HEADERS_B
         SET estimated_amount=(SELECT SUM(price_negotiated)
                                 FROM OKC_K_LINES_B
                                WHERE dnz_chr_id = l_hdr_id
                                  AND lse_id in ( 1,12,14,19,46))
       WHERE id = l_hdr_id ;
      End If;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.TRUE_VALUE',
         'After updating all tables for true values in case of cp');
      END IF;
 ELSIF l_termn_level = 'TL' then
      -------------------------------------------------------------------------
      --           True value processing for Top Line Termination            --
      -------------------------------------------------------------------------
      l_usage_type:= NULL;
      OPEN  l_lse_id_csr(p_true_value_tbl(1).p_top_line_id);
      FETCH l_lse_id_csr into l_lse_id_rec ;
      CLOSE l_lse_id_csr;
      l_process := FALSE;
    --mchoudha 11510+ Usage Tax and Price Display
      If l_lse_id_rec.lse_id = 12 Then
        OPEN l_usage_type_csr1(p_true_value_tbl(1).p_top_line_id);
        Fetch l_usage_type_csr1 into l_usage_type;
        Close l_usage_type_csr1;
      End If;
    --mchoudha 11510+ Usage Tax and Price Display
    --added the condition l_usage_type='NPR'
      IF (l_lse_id_rec.lse_id in (1,19))  OR (l_usage_type='NPR' AND l_lse_id_rec.lse_id = 12) then
         FOR l_top_line_rec in l_top_line_csr(p_true_value_tbl(1).p_top_line_id)
         LOOP
            l_process := TRUE;

            OPEN  l_sub_line_csr(l_top_line_rec.sub_line_id) ;
            FETCH l_sub_line_csr into l_original_amt , l_top_line_id ,
                  l_hdr_id ;
            CLOSE l_sub_line_csr ;

            OPEN  l_bill_amount_csr(l_top_line_rec.sub_line_id) ;
            FETCH l_bill_amount_csr into l_bill_amt ;
            CLOSE l_bill_amount_csr  ;

            OPEN  l_credit_csr(l_top_line_rec.sub_line_id) ;
            FETCH l_credit_csr into l_credit ;
            CLOSE l_credit_csr ;

            OPEN  l_suppressed_credit_csr(l_top_line_rec.sub_line_id) ;
            FETCH l_suppressed_credit_csr into l_suppressed_credit ;
            CLOSE l_suppressed_credit_csr ;

            l_true_value := nvl(l_bill_amt,0) +
                            nvl(l_credit,0)   + nvl(l_suppressed_credit,0) ;

            l_ubt_amount := nvl(l_original_amt,0)  - nvl(l_bill_amt,0) ;

            IF l_period_type is not null and l_period_start is not null THEN
              OPEN l_ubt_csr(l_top_line_rec.sub_line_id);
              FETCH l_ubt_csr into l_ubt_amount;
              CLOSE l_ubt_csr;
            END IF;

            IF p_true_value_tbl(1).p_full_credit ='Y' then
                 PRE_TERMINATE_AMOUNT
                   (p_calledfrom     => 1.0 ,
                    p_id             => l_top_line_rec.sub_line_id ,
                    p_terminate_date => l_top_line_rec.start_date,
                    p_flag           => 3 ,
                    x_amount         => l_amount ,
                    --x_manual_credit  => l_manual_credit,
                    x_return_status  => l_return_status );
            ELSIF p_true_value_tbl(1).p_full_credit ='N' then
                 PRE_TERMINATE_AMOUNT
                   (p_calledfrom     => 1.0 ,
                    p_id             => l_top_line_rec.sub_line_id ,
                    p_terminate_date => p_true_value_tbl(1).p_termination_date ,
                    p_flag           => 3 ,
                    x_amount         => l_amount ,
                    --x_manual_credit  => l_manual_credit,
                    x_return_status  => l_return_status );
            END IF;

    --takintoy bug 4293344
    --Changed if condition operator to >= instead of =
            IF p_true_value_tbl(1).p_override_amount >= 0 then
               l_overridden := l_amount ;
            ELSE
               l_overridden := 0;
            END IF;

            l_true_value :=OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_true_value,
                                                               l_currency_code);
            UPDATE OKC_K_LINES_B
               SET price_negotiated = l_true_value
             WHERE id = l_top_line_rec.sub_line_id;

            G_RAIL_REC.AMOUNT := l_true_value;
            G_RAIL_REC.AMOUNT_INCLUDES_TAX_FLAG := null;

            OKS_TAX_UTIL_PVT.Get_Tax
                 ( p_api_version      => 1.0,
                   p_init_msg_list    => OKC_API.G_TRUE,
                   p_chr_id           => l_hdr_id,
                   p_cle_id           => l_top_line_rec.sub_line_id,
                   px_rail_rec        => G_RAIL_REC,
                   x_msg_count        => x_msg_count,
                   x_msg_data         => x_msg_data,
                   x_return_status    => l_return_status);
/* Modified by sjanakir for Bug#6912454 */
            IF ( l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

            If G_RAIL_REC.AMOUNT_INCLUDES_TAX_FLAG = 'N' then
               l_tax_value     := G_RAIL_REC.tax_value ;
               l_tot_tax_value := nvl(l_tax_value,0) + l_tot_tax_value;
            Else
               l_tax_value     := 0 ;
               l_tot_tax_value := nvl(l_tax_value,0) + l_tot_tax_value;
            End If;


            If l_credit < 0 then
               l_credit := l_credit * -1;
            End IF;
            If l_suppressed_credit < 0 then
               l_suppressed_credit := l_suppressed_credit * -1 ;
            End if;

            l_ubt_amount :=OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_ubt_amount,l_currency_code);
            l_credit := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_credit,
                                                              l_currency_code);
            l_suppressed_credit :=
                   OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_suppressed_credit,
                                                          l_currency_code);
            l_overridden := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_overridden,
                                                               l_currency_code);

            UPDATE OKS_K_LINES_B
               SET UBT_AMOUNT       = l_ubt_amount ,
                   CREDIT_AMOUNT    = l_credit ,
                   SUPPRESSED_CREDIT= l_suppressed_credit ,
                   OVERRIDE_AMOUNT  = l_overridden,
                   TAX_AMOUNT       = l_tax_value,
                   FULL_CREDIT      = nvl(p_true_value_tbl(1).p_full_credit,'N')
            WHERE cle_id = l_top_line_rec.sub_line_id;

            l_tot_ubt_amount        := l_tot_ubt_amount + nvl(l_ubt_amount,0) ;
            l_tot_credit            := l_tot_credit + nvl(l_credit,0);
            l_tot_suppressed_credit := l_tot_suppressed_credit +
                                       nvl(l_suppressed_credit,0);
            l_tot_overridden        := l_tot_overridden + nvl(l_overridden,0);

         END LOOP;

         If l_process then
            UPDATE OKC_K_LINES_B
               SET price_negotiated=(SELECT SUM(price_negotiated)
                                       FROM okc_k_lines_b
                                      WHERE cle_id = l_top_line_id
                                      AND   date_cancelled is null) --LLC BUG FIX 4742661
             WHERE id = p_true_value_tbl(1).p_top_line_id ;

            l_tot_ubt_amount := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_tot_ubt_amount,
                                                           l_currency_code);
            l_tot_credit := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_tot_credit,
                                                           l_currency_code);
            l_tot_suppressed_credit :=
                 OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_tot_suppressed_credit,
                                                        l_currency_code);
            l_tot_overridden := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_tot_overridden,
                                                        l_currency_code);

            open l_check_for_full_credit(p_true_value_tbl(1).p_top_line_id);
            fetch l_check_for_full_credit into l_full_count;
            close l_check_for_full_credit;
            If l_full_count >  0 then
               l_full_yn := 'N';
            else
               l_full_yn := nvl(p_true_value_tbl(1).p_full_credit,'N');
            End If;

            -- Update of tax amount for top line is comented out as part of BUG#3278807
            --changed for copy bug.
             UPDATE OKS_K_LINES_B
               SET UBT_AMOUNT        = nvl(UBT_AMOUNT,0) + nvl(l_tot_ubt_amount,0) ,
                   CREDIT_AMOUNT     = nvl(CREDIT_AMOUNT,0) + nvl(l_tot_credit,0) ,
                   SUPPRESSED_CREDIT = nvl(SUPPRESSED_CREDIT,0) + nvl(l_tot_suppressed_credit,0) ,
                   OVERRIDE_AMOUNT   = l_tot_overridden,
                   FULL_CREDIT       = l_full_yn
                   --TAX_AMOUNT        = l_tot_tax_value
             WHERE cle_id = p_true_value_tbl(1).p_top_line_id ;

        End If;
      ELSIF l_lse_id_rec.lse_id = 46 then
         l_original_amt := l_lse_id_rec.price_negotiated;
         l_hdr_id := l_lse_id_rec.dnz_chr_id;

         OPEN  l_bill_amount_csr(p_true_value_tbl(1).p_top_line_id) ;
         FETCH l_bill_amount_csr into l_tot_bill_amt ;
         CLOSE l_bill_amount_csr  ;

         OPEN  l_credit_csr(p_true_value_tbl(1).p_top_line_id) ;
         FETCH l_credit_csr into l_tot_credit ;
         CLOSE l_credit_csr ;

         OPEN  l_suppressed_credit_csr(p_true_value_tbl(1).p_top_line_id) ;
         FETCH l_suppressed_credit_csr into l_tot_suppressed_credit ;
         CLOSE l_suppressed_credit_csr ;

         l_tot_true_value:=nvl(l_tot_bill_amt,0) +
                           nvl(l_tot_credit,0)+nvl(l_tot_suppressed_credit,0) ;

         If l_tot_credit < 0 then
              l_tot_credit := l_tot_credit * -1 ;
         End If;

         If l_tot_suppressed_credit < 0 then
              l_tot_suppressed_credit := l_tot_suppressed_credit * -1 ;
         End If;

         l_tot_ubt_amount := nvl(l_lse_id_rec.price_negotiated,0) -
                             nvl(l_tot_bill_amt,0) ;

         l_tot_overridden :=p_true_value_tbl(1).p_con_terminate_amount -
                            nvl(l_tot_credit,0) -  nvl(l_tot_suppressed_credit,0);

         l_tot_true_value:=OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_tot_true_value,
                                                             l_currency_code);
         UPDATE OKC_K_LINES_B
            SET price_negotiated = l_tot_true_value
          WHERE id = p_true_value_tbl(1).p_top_line_id;

         G_RAIL_REC.AMOUNT := l_true_value;
         G_RAIL_REC.AMOUNT_INCLUDES_TAX_FLAG := null;

         OKS_TAX_UTIL_PVT.Get_Tax
               ( p_api_version      => 1.0,
                 p_init_msg_list    => OKC_API.G_TRUE,
                 p_chr_id           => l_hdr_id,
                 p_cle_id           => p_true_value_tbl(1).p_top_line_id,
                 px_rail_rec        => G_RAIL_REC,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data,
                 x_return_status    => l_return_status);
/* Modified by sjanakir for Bug#6912454 */
         IF ( l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;

         If G_RAIL_REC.AMOUNT_INCLUDES_TAX_FLAG = 'N' then
            l_tax_value     := G_RAIL_REC.tax_value ;
            l_tot_tax_value := nvl(l_tax_value,0) + l_tot_tax_value;
         Else
            l_tax_value     := 0 ;
            l_tot_tax_value := nvl(l_tax_value,0) + l_tot_tax_value;
         End If;

         l_tot_ubt_amount := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_tot_ubt_amount,
                                                          l_currency_code);
         l_tot_credit := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_tot_credit,
                                                          l_currency_code);
         l_tot_suppressed_credit :=
              OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_tot_suppressed_credit,
                                                     l_currency_code);
         l_tot_overridden := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_tot_overridden,
                                                     l_currency_code);


         UPDATE OKS_K_LINES_B
            SET UBT_AMOUNT        = l_tot_ubt_amount ,
                CREDIT_AMOUNT     = l_tot_credit ,
                SUPPRESSED_CREDIT = l_tot_suppressed_credit ,
                OVERRIDE_AMOUNT   = l_tot_overridden,
                FULL_CREDIT       = nvl(p_true_value_tbl(1).p_full_credit,'N'),
                TAX_AMOUNT        = l_tot_tax_value
          WHERE cle_id = p_true_value_tbl(1).p_top_line_id;

      END IF;

    --mchoudha 11510+ Usage Tax and Price Display
    --added lse_id 12
      IF p_true_value_tbl(1).p_hdr_id = 0 then
         IF l_lse_id_rec.lse_id in ( 1,12,19,46 ) then
            UPDATE OKC_K_HEADERS_B
               SET estimated_amount=(SELECT SUM(price_negotiated)
                                       FROM OKC_K_LINES_B
                                      WHERE dnz_chr_id = l_hdr_id
                                        AND lse_id in ( 1,12,14,19,46))
                                      WHERE id = l_hdr_id ;
         END IF;
      END IF;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.TRUE_VALUE',
         'After updating all tables for true values in case of top line');
      END IF;

 ELSIF l_termn_level = 'HD' then
      -------------------------------------------------------------------------
      --             True value processing for Header Termination            --
      -------------------------------------------------------------------------
      UPDATE OKC_K_HEADERS_B
         SET estimated_amount=(SELECT SUM(price_negotiated)
                                 FROM OKC_K_LINES_B
                                WHERE dnz_chr_id = p_true_value_tbl(1).p_hdr_id
                                  AND lse_id in ( 1,12,14,19,46))
                                WHERE id = p_true_value_tbl(1).p_hdr_id ;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.TRUE_VALUE',
         'After updating all tables for true values in case of header');
      END IF;

 END IF;


 EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
       NULL;
 WHEN OTHERS THEN
     x_return_status := OKC_API.G_RET_STS_ERROR ;

END TRUE_VALUE ;

 Procedure prorate_price_breaks ( P_BSL_ID        IN         NUMBER,
                                  P_BREAK_AMOUNT  IN         NUMBER,
                                  P_TOT_AMOUNT    IN         NUMBER,
                                  X_RETURN_STATUS OUT NOCOPY VARCHAR2 ) is
 CURSOR price_break_csr (P_BSL_ID  IN  NUMBER) is
  SELECT pb.id, pb.amount,pb.unit_price , pb.quantity ,
         hdr.currency_code
  FROM OKS_PRICE_BREAKS  pb,
       OKC_K_HEADERS_B   hdr
  WHERE  pb.bsl_id = P_BSL_ID
  AND    pb.chr_id = hdr.id
  ORDER BY pb.quantity_from;

  l_amount        NUMBER;
  l_unit_price    NUMBER;
  l_id            NUMBER;
  l_running_total NUMBER;
  l_currency_code VARCHAR2(10);
 BEGIN
   l_running_total := 0;
   FOR cur in price_break_csr(p_bsl_id)
   LOOP
     l_amount := OKS_EXTWAR_UTIL_PVT.round_currency_amt(((p_tot_amount * cur.amount) / p_break_amount),cur.currency_code);
     l_unit_price := round((l_amount / cur.quantity) ,29);

     l_running_total := l_running_total + l_amount;
     l_id            := cur.id;
     l_currency_code := cur.currency_code;

     UPDATE oks_price_breaks
     SET amount = l_amount,
         unit_price = l_unit_price
     WHERE id = cur.id;
   END LOOP;

   IF ( l_running_total  <>  P_TOT_AMOUNT) THEN
     UPDATE oks_price_breaks
     SET amount = OKS_EXTWAR_UTIL_PVT.round_currency_amt(amount + (P_TOT_AMOUNT - l_running_total),l_currency_code),
         unit_price =  round((amount + (P_TOT_AMOUNT - l_running_total)) / quantity,29)
     WHERE id = l_id;
   END IF;
 END prorate_price_breaks ;


------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 27-MAY-2005
-- DESCRIPTION:
--This procedure calculates the termination amount between the termination date
--and the subline end date and also creates the credit or invoicing transactions
--by calling create_trx_records. Calculate the unbilled amount and the subline
--new extended price. Compare the unbilled amount with termination amount and
--subline new extended price with the billed amount. If the unbilled amount <
--termination amount , then the difference is issued as credit.If the subline
--new extended price is greater than the billed amount , then  the difference
--is issued as the invoice amount from the line start date to termination date-1.
---------------------------------------------------------------------------------
Procedure  Terminate_Ppc
(
                           P_called_from          IN NUMBER DEFAULT NULL,
                           P_end_date             IN DATE,
                           P_termination_date     IN DATE,
                           P_top_line_id          IN NUMBER,
                           P_cp_line_id           IN NUMBER,
                           P_suppress_credit      IN VARCHAR2,
                           P_period_type          IN VARCHAR2,
                           P_period_start         IN VARCHAR2,
                           P_override_amount      IN NUMBER,
                           P_con_terminate_amount IN NUMBER,
                           X_return_status        OUT NOCOPY VARCHAR2
)
IS

  --Cursor to get the details of the subline
 CURSOR covlvl_line(p_cle_id IN   NUMBER,p_cp_line_id IN NUMBER) is
  SELECT line.id,
         line.start_date,
         line.end_date,
         line.lse_id,
         line.cle_id,
         line.dnz_chr_id,
         line.price_unit*itm.number_of_items unit_price,
         rline.price_uom,
         line.price_negotiated total_amount,
         rline.toplvl_uom_code
   FROM  okc_k_lines_b   line,
         oks_k_lines_b   rline,
         okc_k_items     itm
   WHERE line.cle_id = p_cle_id
   AND   line.lse_id in (7,8,9,10,11,13,25,35)
   AND   line.id     = nvl(p_cp_line_id,line.id)
   AND   rline.cle_id    = line.id
   AND   itm.cle_id = line.id
   AND   line.date_cancelled is NULL --LLC BUG FIX 4742661
   AND   line.date_terminated IS NULL;

--Cursor to fetch the total Billed amount,maximum date Billed
-- to and maximum date billed from
Cursor total_billed_csr (p_cle_id   IN NUMBER)
IS
SELECT sum(bsl.amount) ,
       max(bsl.date_billed_From),
       max(bsl.date_billed_to)
   FROM  oks_bill_sub_lines bsl
   WHERE bsl.cle_id = p_cle_id;

--Cursor to get the billing details for the subline
Cursor bsl_cur (p_cle_id IN NUMBER)
IS
SELECT bsl.id,
       bsl.date_billed_from,
       bsl.date_billed_to,
       bsl.amount,
       bsd.result
  FROM oks_bill_cont_lines    bcl,
       oks_bill_sub_lines     bsl,
       oks_bill_sub_line_dtls bsd
  WHERE bcl.id  =  bsl.bcl_id
  AND   bsl.cle_id = p_cle_id
  AND   bsd.bsl_id = bsl.id
 ORDER by bsl.date_billed_to desc;

Cursor max_billto_date_csr(p_cle_id   IN NUMBER)
IS
SELECT max(TRUNC(lvl.date_end))
FROM   oks_level_elements lvl
WHERE  cle_id = p_cle_id;

 CURSOR L_HDR_CURR_CODE (p_id in number ) is
 SELECT currency_code
   FROM okc_k_headers_b
  WHERE id = p_id;

CURSOR l_line_BS_csr(p_line_id  NUMBER,p_date in date) IS
  SELECT id,trunc(date_start) date_start,
         amount,trunc(date_end) date_end
         FROM oks_level_elements
         WHERE cle_id = p_line_id
         AND   TRUNC(date_start) > p_date
         ORDER BY date_start;

CURSOR om_period_csr(p_id IN NUMBER) IS
select oel.service_period,oel.service_duration,
       oel.ordered_quantity
from   okc_k_rel_objs rel,
       oe_order_lines_all oel
where  rel.cle_id = p_id
and    oel.line_id  = rel.object1_id1;


l_unbilled_amount      NUMBER;
l_new_price            NUMBER;
l_termination_amount   NUMBER;
l_quantity             NUMBER;
l_billed_amount        NUMBER;
l_credit_amount        NUMBER;
l_term_amount          NUMBER;
l_max_date_billed_from DATE;
l_max_date_billed_to   DATE;
l_duration             NUMBER;
l_uom                  VARCHAR2(30);
l_unit_price           NUMBER;
l_line_end_date        DATE;
l_termination_date     DATE;
l_currency_code        Varchar2(15);
l_ubt_amount           NUMBER;
l_invoice_amount       NUMBER;
l_inv_amount           NUMBER;
 l_source_uom_quantity      NUMBER;
 l_source_tce_code          VARCHAR2(30);
 l_target_uom_quantity      NUMBER;
 l_target_tce_code          VARCHAR2(30);
 l_return_status     VARCHAR2(1);
l_service_period          VARCHAR2(30);
l_service_duration        NUMBER;
l_ordered_quantity        NUMBER;

BEGIN

x_return_status := 'S';
--If the override amount is not null then create termination records with
--override amount
IF  p_override_amount is NOT NULL THEN

      Create_trx_records(
         p_called_from          => p_called_from,
         p_top_line_id          => p_top_line_id,
         p_cov_line_id          => p_cp_line_id,
         p_date_from            => P_termination_date,
         p_date_to              => p_end_date,
         p_amount               => 0,
         p_override_amount      => p_override_amount,
         p_suppress_credit      => p_suppress_credit,
         p_con_terminate_amount => p_con_terminate_amount,
         p_bill_action          => 'TR',
         x_return_status        => x_return_status);

      IF x_return_status <> 'S' THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

ELSE --p_override_amount is null

 --Loop through the sublines and find the subline details

  FOR cur in covlvl_line(p_top_line_id,p_cp_line_id) LOOP

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Terminate_Ppc',
     'p_top_line_id '||p_top_line_id||' ,p_cp_line_id '||p_cp_line_id);
   END IF;

   IF p_termination_date < cur.start_date THEN
      l_termination_date := cur.start_date;
   ELSE
      l_termination_date :=  p_termination_date;
   END IF;
   Open max_billto_date_csr(cur.id);
   Fetch max_billto_date_csr into l_line_end_date;
   Close max_billto_date_csr;
   IF (l_line_end_date >= l_termination_date) THEN

   --If price uom is null then fetch the uom based on effective dates
   --IF (cur.price_uom IS NULL) THEN
     OKC_TIME_UTIL_PUB.Get_Duration(cur.start_date,l_line_end_date,l_duration,l_uom,x_return_status);

     IF x_return_status <> 'S' THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
   --END IF;
   --mchoudha Added for partial periods CR-003
   Open om_period_csr(cur.id);
   Fetch om_period_csr into l_service_period,l_service_duration,l_ordered_quantity;
   Close om_period_csr;
   IF  l_service_period IS  NULL THEN  --OKS case

    -- IF cur.Unit_Price IS NULL THEN
    --   l_unit_price := cur.total_amount/l_duration;
    -- ELSE
      --mchoudha for bug#4961636
      --The unit price will be directly picked from the DB for the product/item
      IF cur.lse_id in (7,9,25) THEN
        --commenting this for bug#5306921
        --The conversion from pricelist uom to price uom is not required as per bug#4686993
       /* IF cur.toplvl_uom_code <> nvl(cur.price_uom,l_uom) THEN
          l_unit_price := OKS_BILL_SCH.Get_Converted_price(
                                            p_price_uom        =>nvl(cur.price_uom,l_uom),
                                            p_pl_uom           =>cur.toplvl_uom_code ,
                                            p_period_start     =>p_period_start,
                                            p_period_type      =>p_period_type,
                                            p_price_negotiated =>cur.total_amount,
                                            p_unit_price       =>cur.unit_price,
                                            p_start_date       =>cur.start_date,
                                            p_end_date         =>l_line_end_date
                                            );
          IF l_unit_price is NULL THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
        ELSE*/
        --Fix for bug#5623498 unit price will be recalculated based on duration based uom if pricelist is not present
        l_quantity := OKS_TIME_MEASURES_PUB.get_quantity
                       (p_start_date   => cur.start_date,
                        p_end_date     => l_line_end_date,
                        p_source_uom   => nvl(cur.toplvl_uom_code,l_uom),
                        p_period_type  => p_period_type,
                        p_period_start => p_period_start);
        l_unit_price := cur.total_amount / l_quantity;
       -- END IF;
       -- Calculation of Termination amount using Partial Periods Method
       -- Termination Period Start Date  = l_termination_date
       -- Termination Period End of date = p_line_end_date
       -- Determine the termination duration quantity in terms of price list uom for bug#5306921
        l_quantity:= OKS_TIME_MEASURES_PUB.get_quantity(p_start_date   => l_termination_date,
                                                  p_end_date     => l_line_end_date,
                                                  p_source_uom   => nvl(cur.toplvl_uom_code,l_uom),
                                                  p_period_type  => p_period_type,
                                                  p_period_start => p_period_start);

      ELSE  --for manual covered levels added for bug#4961636
        l_quantity := OKS_TIME_MEASURES_PUB.get_quantity
                       (p_start_date   => cur.start_date,
                        p_end_date     => l_line_end_date,
                        p_source_uom   => l_uom,
                        p_period_type  => p_period_type,
                        p_period_start => p_period_start);

        l_unit_price := cur.total_amount/l_quantity;
     -- Calculation of Termination amount using Partial Periods Method
     -- Termination Period Start Date  = l_termination_date
     -- Termination Period End of date = p_line_end_date
     -- Determine the termination duration quantity in terms of effectivity uom for bug#5306921
     l_quantity:= OKS_TIME_MEASURES_PUB.get_quantity(p_start_date   => l_termination_date,
                                                  p_end_date     => l_line_end_date,
                                                  p_source_uom   => l_uom,
                                                  p_period_type  => p_period_type,
                                                  p_period_start => p_period_start);

      END IF;

    -- END IF;
   ELSE
        l_quantity := OKS_TIME_MEASURES_PUB.get_quantity
                       (p_start_date   => cur.start_date,
                        p_end_date     => l_line_end_date,
                        p_source_uom   => nvl(cur.toplvl_uom_code,l_uom),
                        p_period_type  => p_period_type,
                        p_period_start => p_period_start);
        l_unit_price := cur.total_amount / l_quantity;

     -- Calculation of Termination amount using Partial Periods Method
     -- Termination Period Start Date  = l_termination_date
     -- Termination Period End of date = p_line_end_date
     -- Determine the termination duration quantity in terms of price list uom for bug#5306921
     l_quantity:= OKS_TIME_MEASURES_PUB.get_quantity(p_start_date   => l_termination_date,
                                                  p_end_date     => l_line_end_date,
                                                  p_source_uom   => nvl(cur.toplvl_uom_code,l_uom),
                                                  p_period_type  => p_period_type,
                                                  p_period_start => p_period_start);

   END IF;

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Terminate_Ppc',
       'After calling OKS_TIME_MEASURES_PUB.get_quantity with end date '||l_line_end_date||' ,p_source_uom '
       ||nvl(cur.price_uom,l_uom)||' p_period_start ' ||p_period_start||' ,p_period_type '||p_period_type
       ||' l_termination_date '||to_char(l_termination_date)||'result l_quantity '||l_quantity);
     END IF;

-- Get the total billed amount and max date Billed to and
-- max date billed from of the subline

  IF nvl(l_quantity,0) = 0 THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

  l_termination_amount := l_quantity * l_unit_price;

  IF l_termination_amount > cur.total_amount THEN
    l_termination_amount :=  cur.total_amount;
  END IF;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Terminate_Ppc',
       ' l_termination_amount '||l_termination_amount);
  END IF;

  OPEN   total_billed_csr(cur.id);
  FETCH  total_billed_csr into  l_billed_amount,
                                l_max_date_billed_from,
                                l_max_date_billed_to;
  CLOSE  total_billed_csr;

-- Calculate the unbilled amount
  l_unbilled_amount := cur.total_Amount - l_billed_Amount ;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Terminate_Ppc',
     ' l_unbilled_amount '||l_unbilled_amount);
   END IF;

   open  l_hdr_curr_code(cur.dnz_chr_id);
   fetch l_hdr_curr_code into l_currency_code;
   close l_hdr_curr_code ;
--Calculate the new subline extended amount
  l_new_price := cur.total_amount - l_termination_amount;
  IF l_termination_amount >= l_unbilled_amount THEN
   l_ubt_amount := l_unbilled_amount;
  ELSE
   l_ubt_amount := cur.total_amount - l_new_price;
  END IF;

  l_new_price := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_new_price,l_currency_code);
  l_ubt_amount := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_ubt_amount,l_currency_code);

  UPDATE OKC_K_LINES_B
  SET price_negotiated = l_new_price
  WHERE id = cur.id;

  UPDATE OKS_K_LINES_B
  SET UBT_AMOUNT = l_ubt_amount
  WHERE cle_id = cur.id;


  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Terminate_Ppc',
     ' l_new_price '||l_new_price);
  END IF;

  IF l_termination_amount > l_unbilled_amount THEN
   l_credit_amount := l_termination_amount -  l_unbilled_amount;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Terminate_Ppc',
     ' l_credit_amount '||l_credit_amount);
   END IF;

      --Loop through All the sublines and tie the credit amount
      --starting from the last billed period  upwards.
      FOR bsl_rec in bsl_cur(cur.id)
      LOOP
        IF (l_credit_amount <= 0) THEN
          EXIT;
        END IF;

        IF (l_credit_amount >= bsl_rec.amount) THEN
          l_term_amount :=  bsl_rec.amount;
        ELSE
          --last iteration: This is a partial amount
          l_term_amount :=  l_credit_amount;
        END IF;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Terminate_Ppc',
           ' l_credit_amount '||l_term_amount);
        END IF;
        Create_trx_records(
               p_called_from           => p_called_from,
               p_top_line_id           => P_top_line_id,
               p_cov_line_id           => cur.id,
               p_date_from             => bsl_rec.date_billed_from,
               p_date_to               => bsl_rec.date_billed_to,
               p_amount                => NULL,
               p_override_amount       => l_term_amount,
               p_suppress_credit       => p_suppress_credit,
               p_con_terminate_amount  => bsl_rec.amount,
               p_bill_action           => 'TR',
               x_return_status         => x_return_status
               );

        IF x_return_status <> 'S' THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        l_credit_amount := l_credit_amount - bsl_rec.amount;

      END LOOP;

     ELSIF l_termination_amount < l_unbilled_amount AND
           l_termination_date <= nvl(l_max_date_billed_to,cur.start_date-1) THEN

      l_invoice_amount := l_unbilled_amount - l_termination_amount;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Terminate_Ppc',
           ' l_invoice_amount '||l_invoice_amount);
      END IF;
      FOR bs_rec in l_line_BS_csr(cur.id,l_max_date_billed_to)
      LOOP
        IF (l_invoice_amount <= 0) THEN
          EXIT;
        END IF;

        IF (l_invoice_amount >= bs_rec.amount) THEN
          l_inv_amount :=  bs_rec.amount;
        ELSE
          --last iteration: This is a partial amount
          l_inv_amount :=  l_invoice_amount;
        END IF;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Terminate_Ppc',
           ' l_inv_amount '||l_inv_amount);
        END IF;
       Create_trx_records(
               p_called_from           => 1,
               p_top_line_id           => P_top_line_id,
               p_cov_line_id           => cur.id,
               p_date_from             => bs_rec.date_start,
               p_date_to               => bs_rec.date_end,
               p_amount                => bs_rec.amount,
               p_override_amount       => 0,
               p_suppress_credit       => 'N',
               p_con_terminate_amount  => l_inv_amount ,
               p_period_type           => p_period_type,
               p_period_start          => p_period_start,
               p_bill_action           => 'RI',
               x_return_status         => x_return_status
               );
        IF x_return_status <> 'S' THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        l_invoice_amount := l_invoice_amount - bs_rec.amount;

      END LOOP;

    END IF;

    END IF; -- l_line_end_date >= l_termination_date
  END LOOP;

END IF; --p_override_amount is not null

EXCEPTION
   WHEN G_EXCEPTION_HALT_VALIDATION THEN
        x_return_status := OKC_API.G_RET_STS_ERROR ;
   WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);


END Terminate_Ppc;

------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 27-MAY-2005
-- DESCRIPTION:
-- This procedure will calculate the credit amount used for previewing
-- if the period start and period type are not null.
-------------------------------------------------------------------------
Procedure Get_Term_Amt_Ppc (
                             P_called_from       IN NUMBER DEFAULT NULL,
                             P_line_id           IN NUMBER,
                             P_cov_line          IN VARCHAR2,
                             P_termination_date  IN DATE,
                             p_period_type       IN VARCHAR2,
                             p_period_start      IN VARCHAR2,
                             x_amount            OUT NOCOPY NUMBER,
                             x_return_status     OUT NOCOPY VARCHAR2
                           )
IS

CURSOR covlvl_csr(p_id IN   NUMBER) is
SELECT line.id,
       line.lse_id,
       line.start_date,
       line.end_date,
       line.price_unit*itm.number_of_items unit_price,
       rline.price_uom,
       rline.toplvl_uom_code,
       line.price_negotiated total_amount
FROM   okc_k_lines_b   line,
       oks_k_lines_b   rline,
       okc_k_items     itm
WHERE  line.id = p_id
  AND  rline.cle_id = line.id
  AND  itm.cle_id = line.id
  AND  line.date_cancelled is NULL --LLC BUG FIX 4742661
  AND  line.date_terminated is NULL;

CURSOR line_csr(p_cle_id IN   NUMBER) is
SELECT line.id,
       line.lse_id,
       line.start_date,
       line.end_date,
       line.price_unit*itm.number_of_items unit_price,
       rline.price_uom,
       rline.toplvl_uom_code,
       line.price_negotiated total_amount
FROM   okc_k_lines_b   line,
       oks_k_lines_b   rline,
       okc_k_items     itm
WHERE  line.cle_id = p_cle_id
  AND  itm.cle_id = line.id
  AND  rline.cle_id = line.id
  AND  line.date_cancelled is NULL --LLC BUG FIX 4742661
  AND  line.date_terminated is NULL;

Cursor total_billed_csr (p_cle_id   IN NUMBER)
IS
SELECT sum(bsl.amount) ,
       max(bsl.date_billed_From),
       max(bsl.date_billed_to)
  FROM oks_bill_sub_lines bsl
 WHERE bsl.cle_id = p_cle_id;

CURSOR om_period_csr(p_id IN NUMBER) IS
select oel.service_period,oel.service_duration,
       oel.ordered_quantity
from   okc_k_rel_objs rel,
       oe_order_lines_all oel
where  rel.cle_id = p_id
and    oel.line_id  = rel.object1_id1;

Cursor max_billto_date_csr(p_cle_id   IN NUMBER)
IS
SELECT max(TRUNC(lvl.date_end))
FROM   oks_level_elements lvl
WHERE  cle_id = p_cle_id;

l_quantity             NUMBER;
l_termination_amount   NUMBER;
covlvl_rec             covlvl_csr%rowtype;
l_billed_amount        NUMBER;
l_max_date_billed_from DATE;
l_max_date_billed_to   DATE;
l_unbilled_amount      NUMBER;
l_credit_amount        NUMBER;
l_duration             NUMBER;
l_uom                  VARCHAR2(30);
l_unit_price           NUMBER;
l_line_end_date        DATE;
l_termination_date     DATE;
 l_source_uom_quantity      NUMBER;
 l_source_tce_code          VARCHAR2(30);
 l_target_uom_quantity      NUMBER;
 l_target_tce_code          VARCHAR2(30);
 l_return_status     VARCHAR2(1);
l_service_period          VARCHAR2(30);
l_service_duration        NUMBER;
l_ordered_quantity        NUMBER;
BEGIN

x_return_status:='S';

IF  p_cov_line = 'Y'  THEN

   x_amount:= 0;

   Open covlvl_csr(p_line_id);
   Fetch covlvl_csr into covlvl_rec;
   Close covlvl_csr;

   IF p_termination_date < covlvl_rec.start_date THEN
      l_termination_date := covlvl_rec.start_date;
   ELSE
      l_termination_date :=  p_termination_date;
   END IF;

   Open max_billto_date_csr(p_line_id);
   Fetch max_billto_date_csr into l_line_end_date;
   Close max_billto_date_csr;
   IF (l_line_end_date >= l_termination_date) THEN
   --If price uom is null then fetch the uom based on effective dates
   --IF (covlvl_rec.price_uom IS NULL) THEN
     OKC_TIME_UTIL_PUB.Get_Duration(covlvl_rec.start_date,l_line_end_date,l_duration,l_uom,x_return_status);
     IF x_return_status <> 'S' THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
  -- END IF;
  --mchoudha Added for partial periods CR-003
   Open om_period_csr(covlvl_rec.id);
   Fetch om_period_csr into l_service_period,l_service_duration,l_ordered_quantity;
   Close om_period_csr;

   IF l_service_period IS NULL THEN
     --IF covlvl_rec.Unit_Price IS NULL THEN
     --  l_unit_price := covlvl_rec.total_amount/l_duration;
     --ELSE
    --mchoudha for bug#4961636
    --The unit price will be directly picked from the DB for the product/item
      IF covlvl_rec.lse_id in (7,9,25) THEN
        --commenting this for bug#5306921
        --The conversion from pricelist uom to price uom is not required as per bug#4686993
        /*IF covlvl_rec.toplvl_uom_code <> nvl(covlvl_rec.price_uom,l_uom) THEN
          l_unit_price := OKS_BILL_SCH.Get_Converted_price(
                                            p_price_uom        =>nvl(covlvl_rec.price_uom,l_uom),
                                            p_pl_uom           =>covlvl_rec.toplvl_uom_code ,
                                            p_period_start     =>p_period_start,
                                            p_period_type      =>p_period_type,
                                            p_price_negotiated =>covlvl_rec.total_amount,
                                            p_unit_price       =>covlvl_rec.unit_price,
                                            p_start_date       =>covlvl_rec.start_date,
                                            p_end_date         =>l_line_end_date
                                            );
          IF l_unit_price is NULL THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
        ELSE*/
        --Fix for bug#5623498 unit price will be recalculated based on
	--duration based uom if pricelist is not present
        l_quantity := OKS_TIME_MEASURES_PUB.get_quantity
                       (p_start_date   => covlvl_rec.start_date,
                        p_end_date     => l_line_end_date,
                        p_source_uom   => nvl(covlvl_rec.toplvl_uom_code,l_uom),
                        p_period_type  => p_period_type,
                        p_period_start => p_period_start);
        l_unit_price := covlvl_rec.total_amount / l_quantity;

        --END IF;
          --determine the termination duration  quantity based on price list uom for bug#5306921
          l_quantity:=OKS_TIME_MEASURES_PUB.get_quantity(p_start_date   => l_termination_date,
                                                         p_end_date     => l_line_end_date,
                                                         p_source_uom   => nvl(covlvl_rec.toplvl_uom_code,l_uom),
                                                         p_period_type  => p_period_type,
                                                         p_period_start => p_period_start);

      ELSE  --for manual covered levels added for bug#4961636
         l_quantity := OKS_TIME_MEASURES_PUB.get_quantity
                       (p_start_date   => covlvl_rec.start_date,
                        p_end_date     => l_line_end_date,
                        p_source_uom   => l_uom,
                        p_period_type  => p_period_type,
                        p_period_start => p_period_start);

        l_unit_price := covlvl_rec.total_amount/l_quantity;
        --determine the termination duration  quantity based on effectivity uom for bug#5306921
        l_quantity:=OKS_TIME_MEASURES_PUB.get_quantity(p_start_date   => l_termination_date,
                                                       p_end_date     => l_line_end_date,
                                                       p_source_uom   => l_uom,
                                                       p_period_type  => p_period_type,
                                                       p_period_start => p_period_start);

      END IF;

    --END IF;

   ELSE  --OM iStore  Case
        --The conversion from pricelist uom to price uom is not required as per bug#4686993
        --So deriving the quantity based on price list uom
        l_quantity := OKS_TIME_MEASURES_PUB.get_quantity
                       (p_start_date   => covlvl_rec.start_date,
                        p_end_date     => l_line_end_date,
                        p_source_uom   => nvl(covlvl_rec.toplvl_uom_code,l_uom),
                        p_period_type  => p_period_type,
                        p_period_start => p_period_start);
        l_unit_price := covlvl_rec.total_amount / l_quantity;
        --determine the termination duration  quantity based on price list uom for bug#5306921
        l_quantity:=OKS_TIME_MEASURES_PUB.get_quantity(p_start_date   => l_termination_date,
                                                         p_end_date     => l_line_end_date,
                                                         p_source_uom   => nvl(covlvl_rec.toplvl_uom_code,l_uom),
                                                         p_period_type  => p_period_type,
                                                         p_period_start => p_period_start);

   END IF;



     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Get_Term_Amt_Ppc.cov_line',
     'After calling OKS_TIME_MEASURES_PUB.get_quantity with p_source_uom '|| nvl(covlvl_rec.price_uom,l_uom)||' p_period_start ' ||p_period_start||' ,p_period_type '||p_period_type
     ||'result l_quantity '||l_quantity);
     END IF;

   IF nvl(l_quantity,0) = 0 THEN
    RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;
   l_termination_amount := l_quantity * l_unit_price;
   --Added for CR003
   IF l_termination_amount > covlvl_rec.total_amount THEN
     l_termination_amount :=  covlvl_rec.total_amount;
   END IF;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Get_Term_Amt_Ppc.cov_line',
     'l_termination_amount '||l_termination_amount);
   END IF;

   --Get the total billed amount and max date Billed to and max date billed from of the
   --subline
  OPEN total_billed_csr(covlvl_rec.id);
  FETCH total_billed_csr into l_billed_amount,
                              l_max_date_billed_from,
                              l_max_date_billed_to;
  CLOSE total_billed_csr;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Get_Term_Amt_Ppc.cov_line',
     'l_billed_Amount '||l_billed_Amount||', total amount = '||covlvl_rec.total_Amount);
   END IF;

  l_unbilled_amount := covlvl_rec.total_Amount - l_billed_Amount;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Get_Term_Amt_Ppc.cov_line',
     'l_unbilled_amount '||l_unbilled_amount);
   END IF;

  IF l_termination_amount > l_unbilled_amount THEN
    x_amount := l_termination_amount - l_unbilled_amount;
  END IF;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Get_Term_Amt_Ppc.cov_line',
     'x_amount '||x_amount);
  END IF;
  END IF; --l_line_end_date >= l_termination_date

ELSE  -- Check for p_cov_line = 'Y'
   x_amount:= 0;

   FOR cur in  line_csr(p_line_id) LOOP

   /* Added by sjanakir for Bug# 7210528 */
     l_credit_amount := 0;
     IF p_termination_date < cur.start_date THEN
       l_termination_date := cur.start_date;
     ELSE
       l_termination_date :=  p_termination_date;
     END IF;
     Open max_billto_date_csr(cur.id);
     Fetch max_billto_date_csr into l_line_end_date;
     Close max_billto_date_csr;
     IF (l_line_end_date >= l_termination_date) THEN

     --If price uom is null then fetch the uom based on effective dates
    -- IF (cur.price_uom IS NULL) THEN
       OKC_TIME_UTIL_PUB.Get_Duration(cur.start_date,l_line_end_date,l_duration,l_uom,x_return_status);

       IF x_return_status <> 'S' THEN
         RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;

    -- END IF;

   --mchoudha Added for partial periods CR-003
   Open om_period_csr(cur.id);
   Fetch om_period_csr into l_service_period,l_service_duration,l_ordered_quantity;
   Close om_period_csr;

   IF  l_service_period IS NULL THEN

     --IF cur.Unit_Price IS NULL THEN
     --  l_unit_price := cur.total_amount/l_duration;
     --ELSE
     --mchoudha for bug#4961636
     --The unit price will be directly picked from the DB for the product/item
     IF cur.lse_id in (7,9,25) THEN
       --commenting this for bug#5306921
       --The conversion from pricelist uom to price uom is not required as per bug#4686993
      /*IF cur.toplvl_uom_code <> nvl(cur.price_uom,l_uom) THEN
        l_unit_price := OKS_BILL_SCH.Get_Converted_price(
                                            p_price_uom        =>nvl(cur.price_uom,l_uom),
                                            p_pl_uom           =>cur.toplvl_uom_code ,
                                            p_period_start     =>p_period_start,
                                            p_period_type      =>p_period_type,
                                            p_price_negotiated =>cur.total_amount,
                                            p_unit_price       =>cur.unit_price,
                                            p_start_date       =>cur.start_date,
                                            p_end_date         =>l_line_end_date
                                            );
        IF l_unit_price is NULL THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      ELSE*/
        --Fix for bug#5623498 unit price will be recalculated based on duration based uom
	--if pricelist is not present
        l_quantity := OKS_TIME_MEASURES_PUB.get_quantity
                       (p_start_date   => cur.start_date,
                        p_end_date     => l_line_end_date,
                        p_source_uom   => nvl(cur.toplvl_uom_code,l_uom),
                        p_period_type  => p_period_type,
                        p_period_start => p_period_start);
        l_unit_price := cur.total_amount / l_quantity;

      --END IF;
        --determine the termination duration  quantity based on price list uom
        l_quantity:= OKS_TIME_MEASURES_PUB.get_quantity(
                                          p_start_date   => l_termination_date,
                                          p_end_date     => l_line_end_date,
                                          p_source_uom   => nvl(cur.toplvl_uom_code,l_uom),
                                          p_period_type  => p_period_type,
                                          p_period_start => p_period_start);

     ELSE  --for manual covered levels added for bug#4961636
        l_quantity := OKS_TIME_MEASURES_PUB.get_quantity
                       (p_start_date   => cur.start_date,
                        p_end_date     => l_line_end_date,
                        p_source_uom   => l_uom,
                        p_period_type  => p_period_type,
                        p_period_start => p_period_start);

        l_unit_price := cur.total_amount/l_quantity;
        --determine the termination duration  quantity based on effectivity uom
        l_quantity:= OKS_TIME_MEASURES_PUB.get_quantity(
                                          p_start_date   => l_termination_date,
                                          p_end_date     => l_line_end_date,
                                          p_source_uom   => l_uom,
                                          p_period_type  => p_period_type,
                                          p_period_start => p_period_start);

     END IF;
    --END IF;
   ELSE  --OM iStore  Case
        l_quantity := OKS_TIME_MEASURES_PUB.get_quantity
                       (p_start_date   => cur.start_date,
                        p_end_date     => l_line_end_date,
                        p_source_uom   => nvl(cur.toplvl_uom_code,l_uom),
                        p_period_type  => p_period_type,
                        p_period_start => p_period_start);
        l_unit_price := cur.total_amount / l_quantity;
        --determine the termination duration  quantity based on price list uom
        l_quantity:= OKS_TIME_MEASURES_PUB.get_quantity(
                                          p_start_date   => l_termination_date,
                                          p_end_date     => l_line_end_date,
                                          p_source_uom   => nvl(cur.toplvl_uom_code,l_uom),
                                          p_period_type  => p_period_type,
                                          p_period_start => p_period_start);

   END IF;


     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Get_Term_Amt_Ppc.line',
        'After calling OKS_TIME_MEASURES_PUB.get_quantity with p_source_uom '||nvl(cur.price_uom,l_uom)||' p_period_start ' ||p_period_start||' ,p_period_type '||p_period_type
        ||'result l_quantity '||l_quantity);
     END IF;


     IF nvl(l_quantity,0) = 0 THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
     l_termination_amount := l_quantity * l_unit_price;

     --Added for CR003
     IF l_termination_amount > cur.total_amount THEN
       l_termination_amount :=  cur.total_amount;
     END IF;


     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Get_Term_Amt_Ppc.line',
     'l_termination_amount '||l_termination_amount);
     END IF;
     --Get the total billed amount and max date Billed to and max date billed from of the
     --subline
     OPEN  total_billed_csr(cur.id);
     FETCH total_billed_csr into  l_billed_amount,
                                   l_max_date_billed_from,
                                   l_max_date_billed_to;
     CLOSE total_billed_csr;

     l_unbilled_amount := cur.total_Amount - nvl(l_billed_Amount,0);
     IF l_termination_amount > l_unbilled_amount THEN
       l_credit_amount := l_termination_amount -  l_unbilled_amount;
     END IF;
     --Sum of credit amounts for all the sublines of the topline
     x_amount:= nvl(x_amount,0) + nvl(l_credit_amount,0);
     END IF; --l_line_end_date >= l_termination_date
   END LOOP;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Get_Term_Amt_Ppc.line',
     'x_amount '||x_amount);
   END IF;

 END IF;

EXCEPTION
   WHEN G_EXCEPTION_HALT_VALIDATION THEN
         x_return_status := OKC_API.G_RET_STS_ERROR ;
   WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

END get_term_amt_ppc;

------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 27-MAY-2005
-- DESCRIPTION:
-- This function will be called for Usage Line Types of Fixed and to
-- compute Minimum and Default for Actual per Period and Actual by Quantity.
---------------------------------------------------------------------------
Function Get_Prorated_Usage_Qty
                       (
                       p_start_date  IN DATE,
                       p_end_date    IN DATE,
                       p_qty         IN NUMBER,
                       p_usage_uom   IN VARCHAR2,
                       p_billing_uom IN VARCHAR2,
                       p_period_type IN VARCHAR2
                       )
RETURN NUMBER
IS
/*Declaration Section*/
CURSOR cs_validate_uom(p_uom_code IN VARCHAR2)
 is
  SELECT 1
   FROM MTL_UNITS_OF_MEASURE_TL TL, okc_time_code_units_v okc
  WHERE TL.uom_code    = okc.uom_code
    AND TL.uom_code    = p_uom_code
    --AND TL.uom_class = 'Time'  commented for bug#5585356
    AND okc.active_flag = 'Y'
   AND TL.LANGUAGE = USERENV('LANG');


cr_validate_uom  cs_validate_uom%ROWTYPE;
l_prorated_qty     NUMBER;
l_usage_quantity   NUMBER;
l_bill_quantity    NUMBER;
x_msg_count        NUMBER;
x_msg_data         VARCHAR2(1000);

INVALID_PERIOD_TYPE_EXCEPTION  EXCEPTION;
INVALID_DATE_EXCEPTION         EXCEPTION;
INVALID_UOM_EXCEPTION          EXCEPTION;
G_EXCEPTION_HALT_VALIDATION    EXCEPTION;
BEGIN
    --Begin Validation
    --1) Validate dates
    IF (p_start_date IS NULL)OR(p_end_date IS NULL)OR(p_start_date > p_end_date)
    THEN
      RAISE INVALID_DATE_EXCEPTION;
    END IF;

    --2)Validate p_usage_uom
    OPEN cs_validate_uom(p_usage_uom);
    FETCH cs_validate_uom INTO cr_validate_uom;
    IF cs_validate_uom%NOTFOUND
    THEN
      RAISE INVALID_UOM_EXCEPTION;
    END IF;
    CLOSE cs_validate_uom;

    --3)Validate p_billing_uom
    OPEN cs_validate_uom(p_billing_uom);
    FETCH cs_validate_uom INTO cr_validate_uom;
    IF cs_validate_uom%NOTFOUND
    THEN
      RAISE INVALID_UOM_EXCEPTION;
    END IF;
    CLOSE cs_validate_uom;


    --4)Validate period type
    IF upper(p_period_type) NOT IN ('ACTUAL','FIXED')
    THEN
      RAISE INVALID_PERIOD_TYPE_EXCEPTION;
    END IF;

    --End Validation
    l_prorated_qty := 0;

    --Fetch the quantity wrt usage uom
    l_usage_quantity := OKS_TIME_MEASURES_PUB.get_target_qty_service (
                                                        p_start_date   => p_start_date,
                                                        p_end_date     => p_end_date,
                                                        p_price_uom    => p_usage_uom,
                                                        p_period_type  => p_period_type,
                                                        p_round_dec    => 18
                                                        );

    --FND_FILE.PUT_LINE( FND_FILE.LOG,'l_usage_quantity '||l_usage_quantity);
    IF l_usage_quantity <= 0 THEN
      RAISE  G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_prorated_qty := p_qty * l_usage_quantity;
    --FND_FILE.PUT_LINE( FND_FILE.LOG,'l_prorated_qty '||l_prorated_qty);
RETURN l_prorated_qty;

EXCEPTION
WHEN INVALID_PERIOD_TYPE_EXCEPTION THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Invalid Period type '||p_period_type);
      return NULL;
WHEN INVALID_UOM_EXCEPTION THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Invalid unit of measure code');
      IF cs_validate_uom%ISOPEN THEN
        CLOSE cs_validate_uom;
      END IF;
      return NULL;
WHEN INVALID_DATE_EXCEPTION THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Invalid Effective Dates');
      return NULL;
WHEN G_EXCEPTION_HALT_VALIDATION THEN
      FND_MSG_PUB.Count_And_Get
      (
        p_count =>      x_msg_count,
        p_data  =>      x_msg_data
      );
      FND_FILE.PUT_LINE( FND_FILE.LOG,'x_msg_count '||x_msg_count||'x_msg_data:  '||x_msg_data);
      RETURN NULL;
WHEN OTHERS THEN
        --set the error message and return with NULL to notify the
        --caller of error
      FND_FILE.PUT_LINE( FND_FILE.LOG,'sqlcode '||sqlcode||' with error message '||sqlerrm);
      RETURN NULL;
END Get_Prorated_Usage_Qty;
-------------------------------------------------------------------------

------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 27-MAY-2005
-- DESCRIPTION:
-- This new procedure will calculate the partial termination amount between
-- termination date and the billing period end using Time measure APIs for USAGE only.
---------------------------------------------------------------------------
Function Get_partial_term_amount
                       (
                       p_start_date        IN DATE,
                       p_end_date          IN DATE,
                       P_termination_date  IN DATE,
                       P_amount            IN NUMBER,
                       P_uom               IN VARCHAR2,
                       P_period_start      IN VARCHAR2,
                       P_period_type       IN VARCHAR2
                       )
RETURN NUMBER
IS
/*Declaration Section*/
CURSOR cs_validate_uom(p_uom_code IN VARCHAR2)
 is
  SELECT 1
   FROM MTL_UNITS_OF_MEASURE_TL TL, okc_time_code_units_v okc
  WHERE TL.uom_code    = okc.uom_code
    AND TL.uom_code    = p_uom_code
    --AND TL.uom_class = 'Time' commented for bug#5585356
    AND okc.active_flag = 'Y'
   AND TL.LANGUAGE = USERENV('LANG');

cr_validate_uom  cs_validate_uom%ROWTYPE;
l_quantity         NUMBER;
l_total_quantity   NUMBER;
x_amount           NUMBER;

INVALID_DATE_EXCEPTION         EXCEPTION;
INVALID_UOM_EXCEPTION          EXCEPTION;
BEGIN

    --Begin Validation
    --1) Validate dates
    IF (P_termination_date IS NULL)OR(P_termination_date > p_end_date)OR(P_termination_date < p_start_date)
    THEN
      RAISE INVALID_DATE_EXCEPTION;
    END IF;

    --2)Validate p_usage_uom
    OPEN cs_validate_uom(P_uom);
    FETCH cs_validate_uom INTO cr_validate_uom;
    IF cs_validate_uom%NOTFOUND
    THEN
      RAISE INVALID_UOM_EXCEPTION;
    END IF;
    CLOSE cs_validate_uom;



   --Get the partial period between p_termination_date and p_end_date
    l_quantity := OKS_TIME_MEASURES_PUB.get_quantity
                          (p_start_date   => p_termination_date,
                           p_end_date     => p_end_date,
                           p_source_uom   => P_uom,
                           p_period_type  => P_period_type,
                           p_period_start => p_period_start
                           );

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Get_partial_term_amount',
     'After calling OKS_TIME_MEASURES_PUB.get_quantity with p_source_uom'||P_uom||' p_period_start ' ||p_period_start||' ,p_period_type '||p_period_type||' P_termination_date '||to_char(P_termination_date)
     ||'result l_quantity '||l_quantity);
   END IF;

    IF nvl(l_quantity,0) = 0 THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_total_quantity := OKS_TIME_MEASURES_PUB.get_quantity
                          (p_start_date   => p_start_date,
                           p_end_date     => p_end_date,
                           p_source_uom   => P_uom,
                           p_period_type  => P_period_type,
                           p_period_start => p_period_start
                           );

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Get_partial_term_amount',
     'After calling OKS_TIME_MEASURES_PUB.get_quantity with p_source_uom'||P_uom||'  p_period_start ' ||p_period_start||' ,p_period_type '||p_period_type
     ||'result l_total_quantity '||l_total_quantity);
    END IF;

    IF nvl(l_total_quantity,0) = 0 THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    x_amount := l_quantity * p_amount / l_total_quantity;


    RETURN x_amount;

EXCEPTION
WHEN G_EXCEPTION_HALT_VALIDATION THEN
     RETURN NULL;
WHEN INVALID_UOM_EXCEPTION THEN
      OKC_API.SET_MESSAGE(p_app_name    => 'OKS',
                         p_msg_name     => 'OKS_INVD_UOM_CODE',
                         p_token1       => 'OKS_API_NAME',
                         p_token1_value => 'OKS_BILL_REC_PUB.Get_partial_term_amount',
                         p_token2       => 'UOM_CODE',
                         p_token2_value => P_uom);
      IF cs_validate_uom%ISOPEN THEN
        CLOSE cs_validate_uom;
      END IF;
      return NULL;
WHEN INVALID_DATE_EXCEPTION THEN
      OKC_API.set_message('OKS','OKS_INVALID_START_END_DATES');
      return NULL;
WHEN OTHERS THEN
        --set the error message and return with NULL to notify the
        --caller of error
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

       RETURN NULL;
END Get_partial_term_amount;


END OKS_BILL_REC_PUB ;



/
