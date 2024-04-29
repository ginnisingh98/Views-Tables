--------------------------------------------------------
--  DDL for Package Body OKS_BILLING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_BILLING_PUB" as
/* $Header: OKSPBILB.pls 120.24.12010000.2 2008/12/25 08:04:51 harlaksh ship $ */


 /*
     This Procedure is used for billing
     of Service / Usage / Subscription lines either
     of a single contract or all the contract lines eligibile for billing.
 */

-- Global var holding the User Id
         user_id          NUMBER;

-- Global var to hold the ERROR value.
         ERROR            NUMBER := 0;

-- Global var to hold the SUCCESS value.
         SUCCESS          NUMBER := 1;
         WARNING          NUMBER := 1;


-- Global var to hold the Concurrent Process return value
         conc_ret_code   NUMBER := SUCCESS;

-- Global constant for the threshold count before splitting into sub-requests
         MAX_SINGLE_REQUEST     NUMBER := 500;

-- Global constant for the maximum allowed sub-requests (parallel workers)
         MAX_JOBS               NUMBER := 30;

-- Global vars to hold the min and max hdr_id for each sub-request range
         type range_rec is record (
              lo number,
              hi number);
         type rangeArray is VARRAY(50) of range_rec;
         range_arr rangeArray;

/* *** PL/sql tables and variables for report **** */

  l_processed_lines_tbl           OKS_BILL_REC_PUB.line_report_tbl_type;
  l_processed_sub_lines_tbl       OKS_BILL_REC_PUB.line_report_tbl_type;

  l_pr_tbl_idx               Number := 0; /* Lines table */
  l_prs_tbl_idx              Number := 0; /* Sub Lines table */

-- Global table  for holding number of periods to process
  level_elements_tab Oks_bill_util_pub.level_element_tab;
  level_coverage     Oks_bill_util_pub.level_element_tab;
  -- Variables to control log writing and report generation.
/*****
  l_write_log              BOOLEAN;
  l_write_report           BOOLEAN;
  l_yes_no                 VARCHAR2(10);
*****/

 /*
    Procedure LEVEL is for levelling across cps
    of usage items if level flag is set to 'Y'.
    It is done only if usage type is Actual per period.
 */

-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 10-JUN-2005
-- Added  parameters p_period_type,p_period_start to the procedure level.
-------------------------------------------------------------------------
Procedure level
 (
  P_level_qty          IN                  NUMBER,
  P_cov_tbl            IN OUT      NOCOPY  OKS_BILL_REC_PUB.COVERED_TBL,
  P_qty                IN                  NUMBER,
  --P_line_tbl           IN OUT      NOCOPY  OKS_QP_INT_PVT.G_SLINE_TBL_TYPE ,
  p_usage_period       IN                  VARCHAR2,
  p_time_uom_code      IN                  VARCHAR2,
  p_uom_code           IN                  VARCHAR2,
  p_period_type        IN                  VARCHAR2,
  p_period_start       IN                  VARCHAR2,
  X_return_status      OUT         NOCOPY  VARCHAR2
 )
 IS
Cursor l_bill_qty_csr (p_id IN NUMBER) IS
SELECT fixed_quantity         fixed_qty
      ,minimum_quantity       minimum_qty
      ,default_quantity       default_qty
      ,amcv_flag              amcv_flag
      ,usage_period           usage_period
      ,usage_duration         usage_duration
      ,level_yn               level_yn
      ,base_reading           base_reading
      ,usage_type             usage_Type
  FROM oks_k_lines_b
  WHERE cle_id = p_id ;

l_bill_qty_rec               l_bill_qty_csr%rowtype;
l_from_date                  DATE;
l_to_date                    DATE;
l_minimum                    NUMBER;
l_temp                       NUMBER;
l_temp_qty                   NUMBER;
l_negative_yn                VARCHAR2(10);

BEGIN

  X_return_status := 'S';
  l_negative_yn := NVL(FND_PROFILE.VALUE('OKS_NEGATIVE_BILLING_YN'),'NO');
  FOR l_ptr in 1..p_cov_tbl.count
  LOOP
    OPEN  l_bill_qty_csr(p_cov_tbl(l_ptr).id);
    FETCH l_bill_qty_csr into l_bill_qty_rec;
    CLOSE l_bill_qty_csr;

    l_minimum := NVL(l_bill_qty_rec.Minimum_qty,0) ;
    l_temp_qty := p_cov_tbl(l_ptr).result ;  --used to temp storage of result
    l_from_date := p_cov_tbl(l_ptr).date_billed_from;
    l_to_date   := p_cov_tbl(l_ptr).date_billed_to;

    IF (l_minimum > 0) THEN
      -------------------------------------------------------------------------
      -- Begin partial period computation logic
      -- Developer Mani Choudhary
      -- Date 11-JUN-2005
      -- call oks_bill_rec_pub.Get_prorated_Usage_Qty to get the prorated usage
      -------------------------------------------------------------------------
      IF p_period_type IS NOT NULL AND
         p_period_start IS NOT NULL
      THEN
        l_minimum := OKS_BILL_REC_PUB.Get_Prorated_Usage_Qty
                       (
                       p_start_date  => l_from_date,
                       p_end_date    => l_to_date,
                       p_qty         => l_minimum,
                       p_usage_uom   => p_usage_period,
                       p_billing_uom => p_uom_code,
                       p_period_type => p_period_type
                       );
        IF Nvl(l_minimum,0) = 0 THEN
          FND_FILE.PUT_LINE( FND_FILE.LOG, 'Error OKS_BILL_REC_PUB.Get_Prorated_Usage_Qty returns l_minimum as '||l_minimum);
          Raise G_EXCEPTION_HALT_VALIDATION;
        END IF;
        l_minimum := Round(l_minimum,0);
      ELSE
        --Existing logic
        l_temp := OKS_TIME_MEASURES_PUB.GET_TARGET_QTY
                   (
                    p_start_date  => l_from_date,
                    p_source_qty  => 1,
                    p_source_uom  => p_usage_period,
                    p_target_uom  => p_time_uom_code,
                    p_round_dec   => 0
                   );

        IF Nvl(l_temp,0) = 0 THEN
          FND_FILE.PUT_LINE( FND_FILE.LOG, 'Error Get_target_qty returns Zero');
          Raise G_EXCEPTION_HALT_VALIDATION;
        END IF;
        l_minimum  := Round((trunc(l_to_date) - trunc(l_from_date) + 1)
                                * (l_minimum /l_temp) ,0) ;
      END IF;
      ------------------------------------------------------------------------------
    END IF;

    IF (l_bill_qty_rec.level_yn = 'Y') THEN
      p_cov_tbl(l_ptr).result :=  nvl(p_level_qty, 0);
      IF (p_level_qty = 0)  THEN
        p_cov_tbl(l_ptr).adjustment_level := 0;
      ELSE
        p_cov_tbl(l_ptr).adjustment_level := p_cov_tbl(l_ptr).result - p_qty;
      END IF;

      p_cov_tbl(l_ptr).adjustment_minimum := 0;
      --p_line_tbl(l_ptr).item_qty := nvl(p_level_qty, 0);

      IF ((p_level_qty < l_minimum) AND (nvl(p_cov_tbl(l_ptr).flag,'X') <> 'S')) THEN
        p_cov_tbl(l_ptr).result := l_minimum;
        -- BUG FIX 3402724.
        -- populate adjustment_minimum with L_minimum
        p_cov_tbl(l_ptr).adjustment_minimum := l_minimum ; -- p_level_qty;
      END IF;

    ELSIF (nvl(p_cov_tbl(l_ptr).flag,'X') not in ('D','S')) THEN
      IF ((p_cov_tbl(l_ptr).result < l_minimum) AND  (l_bill_qty_rec.Minimum_qty is NOT NULL)) THEN
        p_cov_tbl(l_ptr).result :=  l_minimum;
        -- BUG FIX 3402724.
        -- populate adjustment_minimum with L_minimum
        p_cov_tbl(l_ptr).adjustment_minimum := l_minimum ; -- p_level_qty;
      END IF;


    END IF;

    /* If flag is Default */
    -- BUG FIX 3443896.Default qty in billing history not populated properly
    IF ( p_cov_tbl(l_ptr).flag = 'D') THEN
      p_cov_tbl(l_ptr).default_default := p_cov_tbl(l_ptr).result;  -- p_qty ;
    /* If flag is AMCV */
    ELSIF (p_cov_tbl(l_ptr).flag = 'M')  THEN
      p_cov_tbl(l_ptr).amcv_yn := 'Y';
      --p_cov_tbl(l_ptr).default_default := p_qty ;
    END IF;

    IF ( sign(p_cov_tbl(l_ptr).result) = -1) THEN

      IF (l_negative_yn = 'YES') THEN
        p_cov_tbl(l_ptr).sign := -1;
        p_cov_tbl(l_ptr).result := abs(p_cov_tbl(l_ptr).result);
        --p_line_tbl(l_ptr).item_qty  :=  abs(p_line_tbl(l_ptr).item_qty );

      ELSE
        p_cov_tbl(l_ptr).sign := 1;
        p_cov_tbl(l_ptr).result := nvl(l_minimum,0);
        --p_line_tbl(l_ptr).item_qty  :=  0;
      END IF;
    ELSE
      p_cov_tbl(l_ptr).sign := 1;
    END IF ;


    /****
     added this code for new pricing API to retain the Quantity and
     to be passed as a parameter to pricing API
    ****/
     p_cov_tbl(l_ptr).average := nvl(p_cov_tbl(l_ptr).result, 0);

  END LOOP;

EXCEPTION
  WHEN  G_EXCEPTION_HALT_VALIDATION THEN
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'Error in Level Procedure --G_exception_halt_validation raised' || sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'Error in Level Procedure --OTHERS Exception raised' || sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

END level;


/* Procedure to calculate AMCV */
PROCEDURE OKS_REG_GET_AMCV
 (
  X_Return_Status  OUT   NOCOPY  VARCHAR2,
  P_cle_id          IN           NUMBER,
  X_Volume         OUT   NOCOPY  NUMBER
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
  AND    bcl.bill_action <> 'AVG';

Cursor l_tot_csr Is
  SELECT NVL(Sum(NVL(bsd.Result,0)),0)
  FROM   oks_bill_cont_lines    bcl,
         oks_bill_sub_lines     bsl,
         oks_bill_sub_line_dtls bsd
  WHERE  bsl.cle_id = p_cle_id
  AND    bsl.bcl_id = bcl.id
  AND    bcl.bill_action <> 'AVG'
  AND    bsd.bsl_id = bsl.id;



BEGIN
   x_Volume        := 0;
   l_totvol := 0;
   x_Return_Status := OKC_API.G_RET_STS_SUCCESS;


   OPEN  l_date_csr;
   FETCH l_date_csr into l_date_billed_from,l_date_billed_to;
   CLOSE l_date_csr;

   OPEN  l_tot_csr;
   FETCH l_tot_csr into l_totvol;
   CLOSE l_tot_csr;

   l_prddays := trunc(l_Date_Billed_To) - trunc(l_Date_Billed_From) + 1;


   x_Volume := Round(l_TotVol / l_prddays,0);


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

/*Procedure Create_line_for_report is for billing Output report.
  It copies each processed line in table
*/
Procedure Create_line_for_report(
             P_L_PR_TBL_IDX               IN NUMBER,
             P_DNZ_CHR_ID                 IN NUMBER,
             P_CONTRACT_NUMBER            IN VARCHAR2,
             P_CONTRACT_NUMBER_MODIFIER   IN VARCHAR2,
             P_CURRENCY_CODE              IN VARCHAR2,
             P_INV_ORGANIZATION_ID        IN NUMBER,
             P_ID                         IN NUMBER,
             P_LINE_NUMBER                IN VARCHAR2,
             P_CLE_ID                     IN NUMBER,
             P_LSE_ID                     IN NUMBER,
             P_OBJECT1_ID1                IN VARCHAR2,
             P_OBJECT1_ID2                IN VARCHAR2,
             P_SUMMARY_YN                 IN VARCHAR2)
IS
BEGIN
 l_processed_lines_tbl(l_pr_tbl_idx).dnz_chr_id      := p_dnz_chr_id ;
 l_processed_lines_tbl(l_pr_tbl_idx).Contract_number := p_Contract_number ;
 l_processed_lines_tbl(l_pr_tbl_idx).Contract_number_modifier := p_Contract_number_modifier ;
 l_processed_lines_tbl(l_pr_tbl_idx).Currency_code   := p_Currency_code;
 l_processed_lines_tbl(l_pr_tbl_idx).Organization_id := p_Inv_Organization_id;
 l_processed_lines_tbl(l_pr_tbl_idx).Line_id         := p_id ;
 l_processed_lines_tbl(l_pr_tbl_idx).Line_Number     := p_Line_Number ;
 l_processed_lines_tbl(l_pr_tbl_idx).Cle_id          := p_cle_id ;
 l_processed_lines_tbl(l_pr_tbl_idx).Lse_Id          := p_lse_id ;
 l_processed_lines_tbl(l_pr_tbl_idx).Sub_line_id     := Null ;
 l_processed_lines_tbl(l_pr_tbl_idx).Sub_line_Number := Null ;
 l_processed_lines_tbl(l_pr_tbl_idx).Pty_object1_id1 := p_object1_id1 ;
 l_processed_lines_tbl(l_pr_tbl_idx).Pty_object1_id2 := p_object1_id2 ;
 l_processed_lines_tbl(l_pr_tbl_idx).record_type     := 'LINE' ;
 l_processed_lines_tbl(l_pr_tbl_idx).Billed_YN       := 'Y' ;
 l_processed_lines_tbl(l_pr_tbl_idx).Bill_Amount     := 0 ;
 l_processed_lines_tbl(l_pr_tbl_idx).Line_Type       := Null ;

 IF (l_processed_lines_tbl(l_pr_tbl_idx).lse_id = 12) THEN
   l_processed_lines_tbl(l_pr_tbl_idx).Summary_bill_YN := 'N';
 ELSIF (l_processed_lines_tbl(l_pr_tbl_idx).lse_id = 46) THEN
   l_processed_lines_tbl(l_pr_tbl_idx).Summary_bill_YN := 'Y';
 ELSE
   IF (p_summary_yn = 'Y') THEN
     l_processed_lines_tbl(l_pr_tbl_idx).Summary_bill_YN := 'Y';
   ELSE
     IF ( FND_PROFILE.VALUE('OKS_AR_TRANSACTIONS_SUBMIT_SUMMARY_YN') = 'YES') THEN
       l_processed_lines_tbl(l_pr_tbl_idx).Summary_bill_YN := 'Y';
     ELSE
       l_processed_lines_tbl(l_pr_tbl_idx).Summary_bill_YN := 'N';
     END IF;
   END IF;
 END IF;
END;


/*Procedure Create_subline_for_report is for billing Output report.
  It copies each processed subline in table
*/
Procedure Create_subline_for_report(
                l_prs_tbl_idx              IN     NUMBER ,
                p_dnz_chr_id               IN     NUMBER,
                p_contract_number          IN     VARCHAR2,
                p_con_num_modifier         IN     VARCHAR2,
                p_currency_code            IN     VARCHAR2,
                p_inv_organization_id      IN     NUMBER,
                p_line_id                  IN     NUMBER,
                p_line_number              IN     VARCHAR2,
                p_lse_id                   IN     NUMBER,
                p_cov_id                   IN     NUMBER,
                p_cov_line_number          IN     VARCHAR2,
                p_object1_id1              IN     VARCHAR2,
                p_object1_id2              IN     VARCHAR2,
                p_line_type                IN     VARCHAR2,
                p_amount                   IN     NUMBER,
                p_summary_yn               IN     VARCHAR2
                )
IS
BEGIN
  l_processed_sub_lines_tbl(l_prs_tbl_idx).dnz_chr_id := p_dnz_chr_id ;
  l_processed_sub_lines_tbl(l_prs_tbl_idx).Contract_number := p_Contract_number ;
  l_processed_sub_lines_tbl(l_prs_tbl_idx).Contract_number_modifier := p_con_num_modifier ;
  l_processed_sub_lines_tbl(l_prs_tbl_idx).Currency_code := p_Currency_code;
  l_processed_sub_lines_tbl(l_prs_tbl_idx).Organization_id := p_Inv_Organization_id;
  l_processed_sub_lines_tbl(l_prs_tbl_idx).Line_id := p_line_id ;
  l_processed_sub_lines_tbl(l_prs_tbl_idx).Line_Number := p_line_Number ;
  l_processed_sub_lines_tbl(l_prs_tbl_idx).Cle_id := p_line_id ;
  l_processed_sub_lines_tbl(l_prs_tbl_idx).Lse_Id := p_lse_id ;
  l_processed_sub_lines_tbl(l_prs_tbl_idx).Sub_line_id := p_cov_id ;
  l_processed_sub_lines_tbl(l_prs_tbl_idx).Sub_line_Number := p_Line_Number||'.'||p_cov_line_number ;
  l_processed_sub_lines_tbl(l_prs_tbl_idx).Pty_object1_id1 := p_object1_id1 ;
  l_processed_sub_lines_tbl(l_prs_tbl_idx).Pty_object1_id2 := p_object1_id2 ;
  l_processed_sub_lines_tbl(l_prs_tbl_idx).record_type := 'SUB_LINE' ;
  l_processed_sub_lines_tbl(l_prs_tbl_idx).Billed_YN := 'Y' ;
  --l_processed_sub_lines_tbl(l_prs_tbl_idx).Bill_Amount := 0 ;
  l_processed_sub_lines_tbl(l_prs_tbl_idx).Line_Type := p_line_type ;

  IF (l_processed_sub_lines_tbl(l_prs_tbl_idx).lse_id = 12) THEN
    l_processed_sub_lines_tbl(l_prs_tbl_idx).Summary_bill_YN := 'N';
  ELSIF (l_processed_sub_lines_tbl(l_prs_tbl_idx).lse_id = 46) THEN
    l_processed_sub_lines_tbl(l_prs_tbl_idx).Summary_bill_YN := 'Y';
  ELSE
    IF (p_summary_yn = 'Y') THEN
      l_processed_sub_lines_tbl(l_prs_tbl_idx).Summary_bill_YN := 'Y';
    ELSE
      IF ( FND_PROFILE.VALUE('OKS_AR_TRANSACTIONS_SUBMIT_SUMMARY_YN') = 'YES') THEN
        l_processed_sub_lines_tbl(l_prs_tbl_idx).Summary_bill_YN := 'Y';
      ELSE
        l_processed_sub_lines_tbl(l_prs_tbl_idx).Summary_bill_YN := 'N';
      END IF;
    END IF;
  END IF;


END Create_subline_for_report;

-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 10-JUN-2005
-- Added  parameters p_period_type,p_period_start
-------------------------------------------------------------------------
Procedure Bill_usage_item(
               p_dnz_chr_id              IN            NUMBER,
               p_contract_number         IN            VARCHAR2,
               p_con_num_modifier        IN            VARCHAR2,
               p_line_number             IN            NUMBER,
               p_lse_id                  IN            NUMBER,
               p_object1_id1             IN            VARCHAR2,
               p_object1_id2             IN            VARCHAR2,
               p_top_line_id             IN            NUMBER,
               p_top_line_start_date     IN            DATE,
               p_top_line_term_date      IN            DATE,
               p_top_line_end_date       IN            DATE,
               p_inv_organization_id     IN            NUMBER,
               p_currency_code           IN            VARCHAR2,
               p_settlement_interval     IN            VARCHAR2,
               p_uom_code                IN            VARCHAR2,
               p_time_uom_code           IN            VARCHAR2,
               p_okl_flag                IN            NUMBER,
               p_prv                     IN            NUMBER,
               p_date                    IN            DATE,
               p_billrep_tbl             IN OUT NOCOPY OKS_BILL_REC_PUB.bill_report_tbl_type,
               p_billrep_tbl_idx         IN            NUMBER,
               p_billrep_err_tbl         IN OUT NOCOPY OKS_BILL_REC_PUB.billrep_error_tbl_type,
               p_billrep_err_tbl_idx     IN OUT NOCOPY NUMBER,
               p_ar_feeder_ctr           IN OUT NOCOPY NUMBER,
               p_period_type             IN            VARCHAR2,
               p_period_start            IN            VARCHAR2,
               p_return_status           IN OUT NOCOPY VARCHAR2
               )
IS
l_usage_type                VARCHAR2(10);
l_usage_period              VARCHAR2(10);
l_counter_uom_code          VARCHAR2(30);
l_flag                      VARCHAR2(10);
l_prorate                   VARCHAR2(10);
l_break_uom_code            VARCHAR2(10);
e_ptr                       NUMBER;
l_ptr                       NUMBER;
l_qty                       NUMBER;
l_level_qty                 NUMBER;
l_break_amount              NUMBER;
l_temp                      NUMBER;
l_sign                      NUMBER;
no_of_cycles                NUMBER;
l_line_total                NUMBER;
l_total                     NUMBER;
l_final_qty                 NUMBER;
l_bcl_id                    NUMBER;
l_amount                    NUMBER;
l_init_value                NUMBER;
l_final_value               NUMBER;
l_base_reading              NUMBER;
l_counter_value_id          NUMBER;
l_counter_grp_id            NUMBER;
l_sub_id                    NUMBER;
l_tsub_id                   NUMBER;
l_estimated_qty             NUMBER;
l_actual_qty                NUMBER;
l_quantity_ordered          NUMBER;
l_locked_price_list_id      NUMBER;
l_locked_price_list_line_id NUMBER;
i                           NUMBER;
l_inv_date                  DATE;
l_ar_inv_date               DATE;
l_bill_start_date           DATE;
l_bill_end_date             DATE;
l_exception_amount          NUMBER;
l_subline_count             NUMBER := 0;
l_counter_id                NUMBER;
l_lock_id                   NUMBER;
l_object_version            NUMBER;
l_lock_date                 DATE;


/* Variable for calling std API*/
l_api_version      CONSTANT NUMBER      := 1.0;
l_called_from      CONSTANT NUMBER      := 1;
l_init_msg_list    CONSTANT VARCHAR2(1) := 'F';
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2000);
l_return_status             VARCHAR2(1);


l_counter_reading_lock_rec  csi_ctr_datastructures_pub.ctr_reading_lock_rec;

l_pbr_rec_in                OKS_PBR_PVT.pbrv_rec_type;
l_pbr_rec_out               OKS_PBR_PVT.pbrv_rec_type;
-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 11-JUN-2005
-- local variables and cursors declared
-------------------------------------------------------------------------
l_rule_id                    NUMBER;
l_uom_code                   VARCHAR2(30);
CURSOR  l_billing_uom_csr(p_rul_id IN NUMBER) IS
SELECT  uom_code
FROM    oks_stream_levels_b
WHERE   id = p_rul_id;
-------------------------------------------------------------------------

CURSOR l_inv_item_csr(p_cle_id Number,p_org_id Number) Is
  SELECT item.Object1_id1
        ,mtl.usage_item_flag
        ,mtl.service_item_flag
        ,mtl.primary_uom_code
  FROM   Okc_K_items Item
        ,mtl_system_items_b   mtl  --Okx_system_items_v mtl
  WHERE  item.cle_id = p_cle_id
  --AND    mtl.id1 = item.object1_id1
  AND    mtl.inventory_item_id = item.object1_id1
  AND    mtl.organization_id = p_org_id;


CURSOR l_usage_csr (p_cle_id IN NUMBER) IS
  SELECT  usage_type                   Usage_Type,
          usage_period                 Usage_period,
          prorate                      Prorate,
          locked_price_list_id         locked_price_list_id,
          locked_price_list_line_id    locked_price_list_line_id
  FROM    OKS_K_LINES_B
  WHERE   cle_id = p_cle_id ;

Cursor qty_uom_csr_sub(p_cle_id  Number) Is
   SELECT  okc.Number_of_items
            ,tl.Unit_of_measure uom_code
     FROM   okc_k_items okc
           ,mtl_units_of_measure_tl tl
     WHERE  okc.cle_id = p_cle_id
     AND    tl.uom_code = okc.uom_code
     AND    tl.language = USERENV('LANG');

  /*
  SELECT  Number_of_items
         ,OKX.Unit_of_measure uom_code
  FROM   OKC_K_ITEMS OKC
        ,OKX_UNITS_OF_MEASURE_V OKX
  WHERE  cle_id = P_cle_id
  AND    Okx.uom_code = OKC.uom_code ;
  */

Cursor bsl_price_csr(p_bcl_id IN NUMBER, p_prv  IN   NUMBER) is
  SELECT bsl.id bsl_id, bsl.average average, bsd.unit_of_measure uom_code,
         bsl.date_billed_from ,bsl.date_billed_to,
         bsl.cle_id, rline.prorate,
         rline.locked_price_list_id,
         rline.locked_price_list_line_id,
         rline.dnz_chr_id
  FROM
        oks_k_lines_b           rline,
        oks_bill_sub_lines      bsl,
        oks_bill_sub_line_dtls  bsd
  WHERE bsl.bcl_id = p_bcl_id
  AND   bsl.id     = bsd.bsl_id
  AND   rline.cle_id = bsl.cle_id
  AND   p_prv      = 1
  UNION
  SELECT bsl.id bsl_id, bsl.average average, bsd.unit_of_measure uom_code,
         bsl.date_billed_from ,bsl.date_billed_to,
         bsl.cle_id , rline.prorate,
         rline.LOCKED_PRICE_LIST_ID,
         rline.locked_price_list_line_id,
         rline.dnz_chr_id
  FROM
        oks_k_lines_b   rline,
        oks_bsl_pr      bsl,
        oks_bsd_pr      bsd
  WHERE bsl.bcl_id = p_bcl_id
  AND   bsl.id     = bsd.bsl_id
  AND   rline.cle_id = bsl.cle_id
  AND   p_prv      = 2;


CURSOR l_subline_Csr(p_cle_id  Number) Is
   SELECT
      sub_line.id                                        id
     ,sub_line.cle_id                                    cle_id
     ,sub_line.dnz_chr_id                                dnz_chr_id
     ,sub_line.price_negotiated                          price_negotiated
     ,sub_line.start_date                                start_date
     ,sub_line.end_date                                  end_date
     ,sub_line.date_terminated                           date_terminated
     ,sub_line.line_number                               line_number
     ,rul.fixed_quantity                                 fixed_qty
     ,rul.minimum_quantity                               minimum_qty
     ,rul.default_quantity                               default_qty
     ,rul.amcv_flag                                      amcv_flag
     ,rul.usage_period                                   usage_period
     ,rul.usage_duration                                 usage_duration
     ,rul.level_yn                                       level_yn
     ,rul.base_reading                                   base_reading
     ,rul.usage_type                                     usage_Type
     ,rul.usage_est_yn                                   usage_est_yn
     ,rul.usage_est_method                               usage_est_method
     ,rul.usage_est_start_date                           usage_est_start_date
   FROM   OKC_K_LINES_B sub_line ,
          OKS_K_LINES_B rul
   WHERE  sub_line.cle_id = p_cle_id
   AND    sub_line.date_cancelled is NULL               --[llc]
   AND    sub_line.id = rul.cle_id
   AND    sub_line.lse_id in (8,7,9,10,11,13,25,35)
   AND    not  exists ( select 1 from okc_k_rel_objs rel
                        WHERE rel.cle_id = sub_line.id );


/*FOR BILLING REPORT*/

Cursor subline_count(p_cle_id  Number) Is
        SELECT count(sub_line.id)
        FROM   OKC_K_LINES_B sub_line
        WHERE  sub_line.cle_id = p_cle_id
        AND    sub_line.lse_id in (8,7,9,10,11,13,25,35)
        AND    sub_line.date_cancelled is NULL               --[llc]
        AND    not  exists ( select 1 from okc_k_rel_objs rel
                             where rel.cle_id = sub_line.id );


Cursor get_counter_qty(p_cle_id Number, p_lock_read number) IS
        select value_timestamp, counter_id
        from cs_counter_values, okc_k_items
        where cle_id = p_cle_id
        and   to_char(counter_id) = object1_id1
        and   counter_reading = p_lock_read;

Cursor get_counter_vrt(p_cle_id Number) IS
        select to_number(object1_id1)
        from okc_k_items
        where cle_id = p_cle_id;


--23-DEC-2005 mchoudha fix for bug#4915367
Cursor bill_amount_npr (p_id IN NUMBER,p_hdr_id IN NUMBER,p_date_start IN DATE,p_date_end IN DATE) IS
SELECT lvl.amount
FROM   oks_level_elements lvl
WHERE  lvl.cle_id = p_id
And    lvl.dnz_chr_id = p_hdr_id
And    lvl.date_start = p_date_start
And    lvl.date_end = p_date_end;


l_item_rec         l_inv_item_csr%ROWTYPE;
l_qty_uom_sub_rec  qty_uom_csr_sub%ROWTYPE;
l_subline_id       NUMBER;

usage_exception EXCEPTION;

BEGIN
  If l_write_log then
     FND_FILE.PUT_LINE(FND_FILE.LOG,'***Processing Usage Item ***');
     FND_FILE.PUT_LINE(FND_FILE.LOG,' Top Line Id:  ' || p_top_line_id);
     FND_FILE.PUT_LINE(FND_FILE.LOG,' Top Line Start Date: ' || p_top_line_start_date);
     FND_FILE.PUT_LINE(FND_FILE.LOG,' Top Line Termination Date/End date: ' || nvl(p_top_line_term_date,p_top_line_end_date));
  End If;


  p_return_status := 'S';
  l_prorate  := '';
  l_locked_price_list_id:= '';
  l_locked_price_list_line_id:= '';

  --Start mchoudha Bug#3537100 22-APR-04
  --For Billing Report
  OPEN  subline_count(p_top_line_id);
  FETCH subline_count into l_subline_count;
  CLOSE subline_count;
  --End  mchoudha Bug#3537100


  OPEN  l_inv_item_csr(p_top_line_id,p_inv_organization_id);
  FETCH l_inv_item_csr into l_item_rec;
  CLOSE l_inv_item_csr;

  OPEN  l_usage_csr(p_top_line_id);
  FETCH l_usage_csr into l_usage_type, l_usage_period , l_prorate ,
        l_locked_price_list_id, l_locked_price_list_line_id;
  CLOSE l_usage_csr;

  l_processed_lines_tbl(l_pr_tbl_idx).record_type  := 'Usage' ;
  level_elements_tab.delete;

  OKS_BILL_UTIL_PUB.get_next_level_element(
        P_API_VERSION        => l_api_version,
        P_ID                 => p_top_line_id,
        P_COVD_FLAG          => 'N',     ---- flag to indicate Top line
        P_DATE               => p_date,
        P_INIT_MSG_LIST      => l_init_msg_list,
        X_RETURN_STATUS      => l_return_status,
        X_MSG_COUNT          => l_msg_count,
        X_MSG_DATA           => l_msg_data,
        X_NEXT_LEVEL_ELEMENT => level_elements_tab );

  IF (l_return_status <> 'S')  THEN
    oks_bill_rec_pub.get_message(
                l_msg_cnt  => l_msg_count,
                l_msg_data => l_msg_data);
    l_processed_lines_tbl(l_pr_tbl_idx).Billed_YN     := 'N' ;
    l_processed_lines_tbl(l_pr_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;

    FND_FILE.PUT_LINE( FND_FILE.LOG, 'Failed in getting next level ');

    /*Needs to determine or revisited */
    --DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
    Raise USAGE_EXCEPTION;
   END IF;

   IF (level_elements_tab.count < 1)  THEN
     l_processed_lines_tbl.DELETE(l_pr_tbl_idx) ;
   END IF;

   e_ptr := 1;
   no_of_cycles := level_elements_tab.count;
   l_tsub_id := l_prs_tbl_idx;

   WHILE (e_ptr <= no_of_cycles)
   LOOP
     l_line_total      := l_line_total + level_elements_tab(e_ptr).bill_amount ;

     l_inv_date        := level_elements_tab(e_ptr).date_to_interface;
     l_ar_inv_date     := level_elements_tab(e_ptr).date_transaction;
     l_bill_start_date := level_elements_tab(e_ptr).bill_from_date;
     l_bill_end_date   := level_elements_tab(e_ptr).bill_to_date;
     -------------------------------------------------------------------------
     -- Begin partial period computation logic
     -- Developer Mani Choudhary
     -- Date 11-JUN-2005
     -- get the rul_id for oks_level_elements
     -------------------------------------------------------------------------
     IF p_period_type IS NOT NULL AND
        p_period_start IS NOT NULL
     THEN
       l_rule_id         := level_elements_tab(e_ptr).rule_id;
       OPEN l_billing_uom_csr(l_rule_id);
       FETCH l_billing_uom_csr INTO l_uom_code;
       CLOSE l_billing_uom_csr;
     END IF;
     --------------------------------------------------------------------------
     /* Date_billed_to of top line should be manipulated if
        termination_date lies between start_date and end_date
        of billing period
     */

     IF ( ( p_top_line_term_date  >= l_bill_start_date) AND
          ( p_top_line_term_date <= l_bill_end_date)  ) THEN
       l_bill_end_date := p_top_line_term_date - 1 ;
     END IF;

     If l_write_log then
        FND_FILE.PUT_LINE( FND_FILE.LOG,'Line Interface Date :' ||l_inv_date );
        FND_FILE.PUT_LINE( FND_FILE.LOG,'Billing Period Start_date: ' || l_bill_start_date||' To '||l_bill_end_date);
     End If;

     l_ptr       := 0;
     l_total     := 0;
     l_final_qty := 0;

     l_cov_tbl.delete;

     IF (trunc(l_inv_date) <= trunc(p_date)) THEN

/*******
     create bank account is no longer needed as part of R12 Bank account
    consolidation project

       OKS_BILL_REC_PUB.create_bank_Account(
                    p_dnz_chr_id      => p_dnz_chr_id,
                    p_bill_start_date => p_top_line_start_date,
                    p_currency_code   => p_currency_code,
                    x_status          => l_return_status,
                    l_msg_count       => l_msg_count,
                    l_msg_data        => l_msg_data
                    );

       IF (l_return_status <> 'S') THEN
         OKS_BILL_REC_PUB.get_message
                   (l_msg_cnt  => l_msg_count,
                    l_msg_data => l_msg_data);
         l_processed_lines_tbl(l_pr_tbl_idx).Billed_YN     := 'N';
         l_processed_lines_tbl(l_pr_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;

         FND_FILE.PUT_LINE( FND_FILE.LOG, 'Failed in creating account');



         --DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION') ;
         Raise USAGE_EXCEPTION;
       END IF;

*******/

       FOR l_covlvl_rec in l_subline_csr(p_top_line_id)
       LOOP

         IF ( ((l_covlvl_rec.date_terminated is not null) and
                (l_covlvl_rec.date_terminated > l_bill_start_date)) --l_inv_date))
                OR
                (l_covlvl_rec.date_terminated is  null))THEN
           IF  ((l_ar_inv_date is not null)
                 And (trunc(l_ar_inv_date) < trunc(sysdate)))  THEN
             l_ar_inv_date := sysdate;
           END IF;

              /*FOR BILLING REPORT*/
              l_subline_id := l_covlvl_rec.id;

           OKS_BILL_REC_PUB.Insert_bcl
               (P_CALLEDFROM        => l_called_from,
                X_RETURN_STAT       => l_return_status,
                P_CLE_ID            => p_top_line_id,
                P_DATE_BILLED_FROM  => l_bill_start_date,
                P_DATE_BILLED_TO    => l_bill_end_date,
                P_DATE_NEXT_INVOICE => l_ar_inv_date,
                P_BILL_ACTION       => 'RI',
                P_OKL_FLAG          => p_okl_flag,
                P_PRV               => p_prv,
                P_MSG_COUNT         => l_msg_count,
                P_MSG_DATA          => l_msg_data,
                X_BCL_ID            => l_bcl_id);

           IF (l_return_status <> 'S')  THEN
             oks_bill_rec_pub.get_message
                   (l_msg_cnt  => l_msg_count,
                    l_msg_data => l_msg_data);
             l_processed_lines_tbl(l_pr_tbl_idx).Billed_YN     := 'N' ;
             l_processed_lines_tbl(l_pr_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;
             FND_FILE.PUT_LINE( FND_FILE.LOG, 'Failed in insert bcl');

             --DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
             Raise USAGE_EXCEPTION;
           END IF;

           IF (p_prv <> 2) THEN
             UPDATE oks_level_elements
             SET date_completed = l_bill_end_date
             WHERE id =  level_elements_tab(e_ptr).id;
           END IF;

           l_ptr := l_ptr + 1;
           level_coverage.delete;

           OKS_BILL_UTIL_PUB.get_next_level_element(
               P_API_VERSION        => l_api_version,
               P_ID                 => l_covlvl_rec.id,
               P_COVD_FLAG          => 'Y', -- flag to indicate Covered level
               P_DATE               => l_inv_date ,      --l_bill_end_date,
               P_INIT_MSG_LIST      => l_init_msg_list,
               X_RETURN_STATUS      => l_return_status,
               X_MSG_COUNT          => l_msg_count,
               X_MSG_DATA           => l_msg_data,
               X_NEXT_LEVEL_ELEMENT => level_coverage );

           IF ((l_return_status <> 'S')
                   OR (level_coverage.count = 0)) THEN
             OKS_BILL_REC_PUB.get_message
                 (l_msg_cnt  => l_msg_count,
                  l_msg_data => l_msg_data);
             l_processed_lines_tbl(l_pr_tbl_idx).Billed_YN     := 'N' ;
             l_processed_lines_tbl(l_pr_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;
             l_processed_sub_lines_tbl(l_prs_tbl_idx).Billed_YN := 'N' ;
             l_processed_sub_lines_tbl(l_prs_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;
             FND_FILE.PUT_LINE( FND_FILE.LOG, 'Failed in get next level of coverage ');
             --DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
             Raise USAGE_EXCEPTION;
           END IF;

           /*Update date completed in coverage line */
           IF (P_PRV <> 2) THEN
             UPDATE oks_level_elements
             SET date_completed = l_bill_end_date
             WHERE id = level_coverage(1).id;
           END IF;

           l_amount                := nvl(level_coverage(1).bill_amount,0);
           l_calc_rec.l_calc_sdate := level_coverage(1).bill_from_date;
           l_calc_rec.l_calc_edate := level_coverage(1).bill_to_date;

           IF (l_write_log) THEN
             FND_FILE.PUT_LINE( FND_FILE.LOG,' Coverage amount    : '||l_amount);
             FND_FILE.PUT_LINE( FND_FILE.LOG,' Coverage start_date: '||l_calc_rec.l_calc_sdate);
             FND_FILE.PUT_LINE( FND_FILE.LOG,' Coverage end_date  : '||l_calc_rec.l_calc_edate);
           END IF;

           IF (  l_covlvl_rec.date_terminated is not null)  AND
               ( trunc(l_calc_rec.l_calc_edate) >=
                              trunc(l_covlvl_rec.date_terminated)) THEN
             l_calc_rec.l_calc_edate := l_covlvl_rec.date_terminated - 1;
           END IF;

           l_cov_tbl(l_ptr).flag              := Null;
           l_cov_tbl(l_ptr).id                := l_covlvl_rec.id ;
           l_cov_tbl(l_ptr).bcl_id            := l_bcl_id;
           l_cov_tbl(l_ptr).date_billed_from  := l_calc_rec.l_calc_sdate;
           l_cov_tbl(l_ptr).date_billed_to    := l_calc_rec.l_calc_edate;

           IF (p_prv = 2) THEN  -- FIX for BUG# 2998682
             l_cov_tbl(l_ptr).date_billed_from
                               := level_elements_tab(e_ptr).bill_from_date;
             l_cov_tbl(l_ptr).date_billed_to
                               := level_elements_tab(e_ptr).bill_to_date;

             ----for bug 4455174
             l_calc_rec.l_calc_sdate :=level_elements_tab(e_ptr).bill_from_date;
             l_calc_rec.l_calc_edate :=level_elements_tab(e_ptr).bill_to_date;

	     --23-DEC-2005 mchoudha  Fix for bug#4915367
             --fetching amount in case of negotiated usage type
             IF l_usage_type = 'NPR' THEN
               Open bill_amount_npr(l_covlvl_rec.id,l_covlvl_rec.dnz_chr_id,l_cov_tbl(l_ptr).date_billed_from,
	                             l_cov_tbl(l_ptr).date_billed_to);
               Fetch bill_amount_npr into l_amount;
               Close bill_amount_npr;
             END IF;

           END IF;

           l_cov_tbl(l_ptr).amount            := 0;
           l_cov_tbl(l_ptr).average           := 0;
           l_cov_tbl(l_ptr).unit_of_measure   := p_uom_code;
           l_cov_tbl(l_ptr).fixed             := 0;
           l_cov_tbl(l_ptr).actual            := null;
           l_cov_tbl(l_ptr).default_default   := 0;
           l_cov_tbl(l_ptr).amcv_yn      := NVL(l_covlvl_rec.amcv_flag,'N');
           l_cov_tbl(l_ptr).adjustment_level  := 0 ;
           l_cov_tbl(l_ptr).adjustment_minimum:= 0 ;
           l_cov_tbl(l_ptr).result            := 1 ;--0 ; --check it out
           l_cov_tbl(l_ptr).x_stat            := Null ;
           l_cov_tbl(l_ptr).amount            := l_amount;
           l_cov_tbl(l_ptr).bcl_amount        :=nvl(l_calc_rec.l_bcl_amount,0);
           l_cov_tbl(l_ptr).date_to_interface := sysdate;

           IF  (l_usage_type = 'NPR') THEN
             IF (l_write_log) THEN
               FND_FILE.PUT_LINE( FND_FILE.LOG, 'USAGE_TYPE of subline = NPR' );
             END IF;

             OPEN  qty_uom_csr_sub(l_covlvl_rec.id);
             FETCH qty_uom_csr_sub into l_qty_uom_sub_rec;
             CLOSE qty_uom_csr_sub;

             l_cov_tbl(l_ptr).result             := 0; --l_qty_uom_sub_rec.number_of_items;
             l_cov_tbl(l_ptr).actual             := 0;
             l_cov_tbl(l_ptr).estimated_quantity := 0;
             l_cov_tbl(l_ptr).x_stat             := null;
             l_cov_tbl(l_ptr).unit_of_measure    := l_qty_uom_sub_rec.uom_code;
             l_cov_tbl(l_ptr).amount             := l_amount;


           ELSIF (l_usage_type = 'FRT')  THEN
             IF (l_write_log) THEN
               FND_FILE.PUT_LINE( FND_FILE.LOG, 'USAGE_TYPE of subline = FRT');
             END IF;

             l_qty := l_covlvl_rec.fixed_qty;

             IF (nvl(l_qty,0) <> 0) THEN
               -------------------------------------------------------------------------
               -- Begin partial period computation logic
               -- Developer Mani Choudhary
               -- Date 11-JUN-2005
               -- call oks_bill_rec_pub.Get_prorated_Usage_Qty to get the prorated usage
               -------------------------------------------------------------------------
               IF p_period_type IS NOT NULL AND
                  p_period_start IS NOT NULL
               THEN

                 l_qty := OKS_BILL_REC_PUB.Get_Prorated_Usage_Qty
                       (
                       p_start_date  => l_calc_rec.l_calc_sdate,
                       p_end_date    => l_calc_rec.l_calc_edate,
                       p_qty         => l_qty,
                       p_usage_uom   => l_usage_period,
                       p_billing_uom => l_uom_code,
                       p_period_type => p_period_type
                       );
                 IF (Nvl(l_qty,0) = 0)  THEN
                   l_processed_lines_tbl(l_pr_tbl_idx).Billed_YN := 'N' ;
                   l_processed_lines_tbl(l_pr_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||' Target Quantity is zero ';
                   l_processed_sub_lines_tbl(l_prs_tbl_idx).Billed_YN     := 'N' ;
                   l_processed_sub_lines_tbl(l_prs_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||' Target Quantity is zero';
                   FND_FILE.PUT_LINE( FND_FILE.LOG, 'Error Get_Prorated_Usage_Qty returns l_qty as '||l_qty);

                  --DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
                   Raise USAGE_EXCEPTION;
                 END IF;
                 l_qty := Round(l_qty,0);
               ELSE
                 --Existing logic
                 l_temp := OKS_TIME_MEASURES_PUB.GET_TARGET_QTY
                            (p_start_date  => l_calc_rec.l_calc_sdate,
                             p_source_qty  => 1,
                             p_source_uom  => l_usage_period,
                             p_target_uom  => p_time_uom_code,
                             p_round_dec   => 0
                             );

                 IF (Nvl(l_temp,0) = 0)  THEN
                   l_processed_lines_tbl(l_pr_tbl_idx).Billed_YN := 'N' ;
                   l_processed_lines_tbl(l_pr_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||' Target Quantity is zero ';
                   l_processed_sub_lines_tbl(l_prs_tbl_idx).Billed_YN     := 'N' ;
                   l_processed_sub_lines_tbl(l_prs_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||' Target Quantity is zero';
                   FND_FILE.PUT_LINE( FND_FILE.LOG, 'Error Get_target_qty returns Zero');

                  --DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
                   Raise USAGE_EXCEPTION;
                 END IF;

                 l_qty := Round((l_qty * (l_calc_rec.l_calc_edate -
                                l_calc_rec.l_calc_sdate + 1))/l_temp ,0) ;

               END IF; --p_period_type IS NOT NULL
             END IF;   --IF (nvl(l_qty,0) <> 0)
             l_cov_tbl(l_ptr).unit_of_measure    := p_uom_code;
             l_cov_tbl(l_ptr).fixed              := l_qty;
             l_cov_tbl(l_ptr).result             := l_qty;
             l_cov_tbl(l_ptr).actual             := 0;
             l_cov_tbl(l_ptr).estimated_quantity := 0;
             l_cov_tbl(l_ptr).sign               := 1;
             l_cov_tbl(l_ptr).average            := l_qty;
             l_cov_tbl(l_ptr).unit_of_measure    :=l_item_rec.primary_uom_code;

           ELSIF (l_usage_type in ('VRT','QTY')) THEN
             -------------------------------------------------------------------------
             -- Begin partial period computation logic
             -- Developer Mani Choudhary
             -- Date 11-JUN-2005
             -- Added additional period_type, period start parameters
             -------------------------------------------------------------------------
             OKS_BILL_REC_PUB.Usage_qty_to_bill
                (
                P_calledfrom            => p_prv, --1 for normal ,2 for preview,
                P_cle_id                => l_covlvl_rec.id,
                P_Usage_type            => l_usage_type,
                P_estimation_flag       => l_covlvl_rec.usage_est_yn,
                P_estimation_method     => l_covlvl_rec.usage_est_method,
                p_default_qty           => l_covlvl_rec.Default_qty,
                P_cov_start_date        => l_covlvl_rec.start_date,
                P_cov_end_date          => l_covlvl_rec.end_date,
                P_cov_prd_start_date    => l_calc_rec.l_calc_sdate,
                P_cov_prd_end_date      => l_calc_rec.l_calc_edate,
                p_usage_period          => l_usage_period,
                p_time_uom_code         => p_time_uom_code,
                p_settle_interval       => p_settlement_interval,
                p_minimum_quantity      => l_covlvl_rec.minimum_qty,
                p_usg_est_start_date    => l_covlvl_rec.usage_est_start_date,
                p_period_type           => p_period_type, --period type
                p_period_start          => p_period_start, --period start
                X_qty                   => l_qty,
                X_Uom_Code              => l_counter_uom_code,
                X_flag                  => l_flag,
                X_end_reading           => l_final_value,
                X_start_reading         => l_init_value,
                X_base_reading          => l_base_reading,
                X_estimated_qty         => l_estimated_qty,
                X_actual_qty            => l_actual_qty,
                X_counter_value_id      => l_counter_value_id,
                X_counter_group_id      => l_counter_grp_id,
                X_return_status         => l_return_status
                  );


             IF (l_return_status <> 'S') THEN
               oks_bill_rec_pub.get_message
                       (l_msg_cnt  => l_msg_count,
                        l_msg_data => l_msg_data);
               l_processed_lines_tbl(l_pr_tbl_idx).Billed_YN := 'N' ;
               l_processed_lines_tbl(l_pr_tbl_idx).Error_Message:= 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;
               l_processed_sub_lines_tbl(l_prs_tbl_idx).Billed_YN := 'N' ;
               l_processed_sub_lines_tbl(l_prs_tbl_idx).Error_Message:= 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;

               Raise USAGE_EXCEPTION;
             END IF;


            IF (l_write_log) THEN
               FND_FILE.PUT_LINE( FND_FILE.LOG, 'After counter values X_value'||' '||l_qty);
            END IF;

            l_cov_tbl(l_ptr).result             :=nvl(l_qty, 0);
            l_cov_tbl(l_ptr).actual             :=l_actual_qty ;
            l_cov_tbl(l_ptr).unit_of_measure    :=l_item_rec.primary_uom_code;
            l_cov_tbl(l_ptr).start_reading      :=l_init_value;
            l_cov_tbl(l_ptr).end_reading        :=l_final_value;
            l_cov_tbl(l_ptr).base_reading       :=l_base_reading;
            l_cov_tbl(l_ptr).ccr_id             :=l_counter_value_id;
            l_cov_tbl(l_ptr).cgr_id             :=l_counter_grp_id;
            l_cov_tbl(l_ptr).flag               :=l_flag;
            l_cov_tbl(l_ptr).estimated_quantity :=l_estimated_qty;

/******
     code changes for R12 project IB Counters Uptake.
     The below code is to lock the counter for Actual Per Period and Actual By Qty
*****/

          if p_prv = 1 Then
            IF nvl(l_actual_qty,0) > 0 Then   ---- reading captured for the billed period
                open get_counter_qty(l_covlvl_rec.id,l_final_value);
	        fetch get_counter_qty into l_lock_date, l_counter_id;
	        close get_counter_qty;

               IF (l_write_log) THEN
                   FND_FILE.PUT_LINE( FND_FILE.LOG, 'Cll IB Lock '||l_lock_date||', Counter id '||l_counter_id);
               END IF;

               l_counter_reading_lock_rec.reading_lock_date := l_lock_date;
               l_counter_reading_lock_rec.counter_id := l_counter_id;
               l_counter_reading_lock_rec.source_line_ref_id := l_covlvl_rec.id;
               l_counter_reading_lock_rec.source_line_ref := 'CONTRACT_LINE';

               Csi_Counter_Pub.create_reading_lock
               (
                    p_api_version          => 1.0,
                    p_commit               => 'F',
                    p_init_msg_list        => 'T',
                    p_validation_level     => 100,
                    p_ctr_reading_lock_rec => l_counter_reading_lock_rec,
                    x_return_status       => l_return_status,
                    x_msg_count           => l_msg_count,
                    x_msg_data            => l_msg_data,
                    x_reading_lock_id     => l_lock_id
		);

            End If; --- for actual qty check
          End if;


         END IF;  -- l_usage_type = NPR

         IF (l_covlvl_rec.level_yn = 'Y') THEN
             l_final_qty := nvl(l_final_qty,0) + nvl(l_qty,0);
             l_total := nvl(l_total,0) + 1;
           END IF;

           l_cov_tbl(l_ptr).average := nvl(l_qty, 0);

         END IF;
         l_tsub_id := l_tsub_id +1;
       END LOOP;  --Covered level for loop

       IF (l_cov_tbl.count > 0) THEN
         IF (l_usage_type in ('VRT','QTY')) THEN
           IF (( nvl(l_total,0) <> 0) and (nvl(l_final_qty,0) <> 0) ) THEN
             l_level_qty := Round(l_final_qty/l_total);
           END IF;

           -------------------------------------------------------------------------
           -- Begin partial period computation logic
           -- Developer Mani Choudhary
           -- Date 12-JUN-2005
           -- Added two parameters p_period_start and p_period_type
           -------------------------------------------------------------------------
           level
             (
              P_LEVEL_QTY     => l_level_qty,
              P_COV_TBL       => l_cov_tbl,
              P_QTY           => l_qty,
              --P_LINE_TBL      => l_line_tbl,
              P_USAGE_PERIOD  => l_usage_period,
              P_TIME_UOM_CODE => p_time_uom_code,
              P_UOM_CODE      => l_uom_code,
              P_PERIOD_TYPE   => P_PERIOD_TYPE,
              P_PERIOD_START  => P_PERIOD_START,
              X_RETURN_STATUS => l_return_status
              );

           IF (l_write_log) THEN
              FND_FILE.PUT_LINE( FND_FILE.LOG, 'Level '||'  '||l_return_status);
           END IF;

           IF (l_return_status <> 'S') THEN
             l_processed_lines_tbl(l_pr_tbl_idx).Billed_YN     := 'N' ;
             l_processed_lines_tbl(l_pr_tbl_idx).Error_Message:= 'Error: '|| sqlerrm||'. Error Message:' ;

             FND_FILE.PUT_LINE( FND_FILE.LOG, 'Error in LEVEL ') ;
             --DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
             Raise USAGE_EXCEPTION;
           END IF;
         END IF; -- l_usage_type in 'VRT','QTY'

         p_ar_feeder_ctr := 1;
         l_sign := l_cov_tbl(l_ptr).sign;

         OKS_BILL_REC_PUB.Insert_all_subline
           (
            P_CALLEDFROM     => l_called_from,
            X_RETURN_STAT    => l_return_status,
            P_COVERED_TBL    => l_cov_tbl,
            P_CURRENCY_CODE  => p_currency_code,
            P_DNZ_CHR_ID     => p_dnz_chr_id,
            P_PRV            => p_prv,
            P_MSG_COUNT      => l_msg_count,
            P_MSG_DATA       => l_msg_data
            );

         IF (l_usage_type <> 'NPR') THEN
            l_sub_id := l_prs_tbl_idx;

            FOR bsl_price_rec in bsl_price_csr(l_bcl_id,p_prv)
            LOOP
              l_price_break_details.delete;

              l_line_rec.line_id          := p_top_line_id;
              l_line_rec.intent           := 'USG';
              l_line_rec.usage_qty        := bsl_price_rec.average; -- qty
              l_line_rec.usage_uom_code   := bsl_price_rec.uom_code;
              l_line_rec.bsl_id           := bsl_price_rec.bsl_id;
              l_line_rec.subline_id       := bsl_price_rec.cle_id;

              IF ( nvl(bsl_price_rec.prorate,l_prorate) = 'ALL') THEN
                l_line_rec.bill_from_date := bsl_price_rec.date_billed_from;
                l_line_rec.bill_to_date   := bsl_price_rec.date_billed_to;


                OKS_TIME_MEASURES_PUB.get_duration_uom
                   ( P_START_DATE    => bsl_price_rec.date_billed_from,
                     P_END_DATE      => bsl_price_rec.date_billed_to,
                     X_DURATION      => l_quantity_ordered,
                     X_TIMEUNIT      => l_break_uom_code,
                     X_RETURN_STATUS => l_return_status
                   );

                l_line_rec.break_uom_code   := l_break_uom_code;

              ELSE
                l_line_rec.bill_from_date := '';
                l_line_rec.bill_to_date   := '';
		--mchoudha bug#4128070 22-JAN-2005
                l_line_rec.break_uom_code   := NULL;
              END IF;


              l_line_rec.price_list
               :=nvl(bsl_price_rec.LOCKED_PRICE_LIST_ID,l_locked_price_list_id);
              l_line_rec.price_list_line_id
               :=nvl(bsl_price_rec.locked_price_list_line_id,l_locked_price_list_line_id);


              /*Pricing API to calculate amount */
              OKS_QP_PKG.CALC_PRICE
                (
                 P_DETAIL_REC          => l_line_rec,
                 X_PRICE_DETAILS       => l_price_rec,
                 X_MODIFIER_DETAILS    => l_modifier_details,
                 X_PRICE_BREAK_DETAILS => l_price_break_details,
                 X_RETURN_STATUS       => l_return_status,
                 X_MSG_COUNT           => l_msg_count,
                 X_MSG_DATA            => l_msg_data
                );


              IF (l_write_log) THEN
                FND_FILE.PUT_LINE( FND_FILE.LOG, 'Price Calculated:  '||l_price_rec.PROD_EXT_AMOUNT);
              END IF;

              /*FOR BILLING REPORT*/
                 l_exception_amount := l_price_rec.PROD_EXT_AMOUNT;

              IF (l_return_status <> 'S') THEN
                oks_bill_rec_pub.get_message
                   (l_msg_cnt  => l_msg_count,
                    l_msg_data => l_msg_data);

                FND_FILE.PUT_LINE( FND_FILE.LOG, 'Calculate Price Error'||'  '||l_return_status);

                --DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
                Raise USAGE_EXCEPTION;
              END IF;

              l_price_rec.PROD_EXT_AMOUNT:=l_price_rec.PROD_EXT_AMOUNT*l_sign;

              OKS_BILL_REC_PUB.update_bsl
                  (
                   X_RET_STAT     => l_return_status,
                   P_DNZ_CHR_ID   => p_dnz_chr_id,
                   P_BSL_ID       => bsl_price_rec.bsl_id,
                   P_BCL_ID       => l_bcl_id,
                   P_AMOUNT       => l_price_rec.PROD_EXT_AMOUNT,
                   P_CURRENCY_CODE=> p_currency_code,
                   P_PRV          => p_prv
                   );

              IF (l_return_status <> 'S') THEN
                oks_bill_rec_pub.get_message
                   (l_msg_cnt  => l_msg_count,
                    l_msg_data => l_msg_data);

                FND_FILE.PUT_LINE( FND_FILE.LOG, 'Error update bsl'||'  '||l_return_status);
                --DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
                Raise USAGE_EXCEPTION;
              END IF;

              l_break_amount := 0;
              /* Populate Price Break Record here and Insert Price Breaks
                 Details
              */
              --FOR i in l_price_break_details.first..l_price_break_details.last
              IF (l_price_break_details.COUNT)  > 0 THEN
                i := l_price_break_details.FIRST;
                LOOP

                  l_pbr_rec_in.bcl_id     := l_bcl_id;
                  l_pbr_rec_in.bsl_id     := bsl_price_rec.bsl_id;
                  l_pbr_rec_in.cle_id     := bsl_price_rec.cle_id;
                  l_pbr_rec_in.chr_id     := bsl_price_rec.dnz_chr_id;
                  l_pbr_rec_in.unit_price := l_price_break_details(i).unit_price;
                  l_pbr_rec_in.amount     := l_price_break_details(i).amount;


                  l_pbr_rec_in.amount  :=
                    OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_price_break_details(i).amount, p_currency_code);

                  l_pbr_rec_in.quantity_from
                           := l_price_break_details(i).quantity_from;
                           --:= l_price_break_details(i).pricing_attr_value_from;
                  l_pbr_rec_in.quantity_to
                           := l_price_break_details(i).quantity_to;
                  l_pbr_rec_in.quantity
                           := l_price_break_details(i).quantity;
                  l_pbr_rec_in.prorate := nvl(bsl_price_rec.prorate,l_prorate);
                  --l_pbr_rec_in.lock_flag
                  --           := l_price_break_details(i).lock_flag;
                  --l_pbr_rec_in.locked_price_list_id
                  --           := l_price_break_details(i).locked_price_list_id;
                  --l_pbr_rec_in.locked_price_list_line_id
                  --          := l_price_break_details(i).locked_price_list_line_id;
                  --l_pbr_rec_in.price_list_id
                  --          := l_price_break_details(i).price_list_id;
                  --l_pbr_rec_in.price_list_line_id
                  --           := l_price_break_details(i).price_list_line_id;


                  l_break_amount := nvl(l_break_amount,0) + nvl(l_pbr_rec_in.amount,0) ;

                  IF ( nvl(l_pbr_rec_in.quantity,0)  > 0) THEN
                    OKS_PBR_PVT.insert_row(
                       P_API_VERSION       => 1,
                       P_INIT_MSG_LIST     => l_init_msg_list,
                       X_RETURN_STATUS     => l_return_status,
                       X_MSG_COUNT         => l_msg_count,
                       X_MSG_DATA          => l_msg_data,
                       P_PBRV_REC          => l_pbr_rec_in,
                       X_PBRV_REC          => l_pbr_rec_out) ;

                  END IF;
                  EXIT WHEN i = l_price_break_details.LAST;
                  i := l_price_break_details.NEXT(i);
                END LOOP;
              END IF; --  l_price_break_details.COUNT > 0


              IF ( l_break_amount <> abs(l_price_rec.PROD_EXT_AMOUNT)) THEN
                OKS_BILL_REC_PUB.prorate_price_breaks (
                       P_BSL_ID        =>      bsl_price_rec.bsl_id,
                       P_BREAK_AMOUNT  =>      l_break_amount,
                       P_TOT_AMOUNT    =>      l_price_rec.PROD_EXT_AMOUNT   ,
                       X_RETURN_STATUS =>      l_return_status) ;
              END IF;


              l_sub_id := l_sub_id + 1;
            END LOOP; --FOR bsl_price_rec in bsl_price_csr(l_bcl_id)

         END IF;   -- (l_usage_type <> 'NPR')

       END IF;

     END IF;  -- l_inv_date <= p_date


     e_ptr  :=  e_ptr  + 1;
     l_tsub_id := l_prs_tbl_idx;

   END LOOP;  --While eptr < no_of_cycles




EXCEPTION
  WHEN USAGE_EXCEPTION THEN
  /*FOR BILLING REPORT*/
  p_billrep_tbl(p_billrep_tbl_idx).Rejected_SubLines := p_billrep_tbl(p_billrep_tbl_idx).Rejected_SubLines + l_subline_count;
  p_billrep_tbl(p_billrep_tbl_idx).Rejected_SubLines_Value := p_billrep_tbl(p_billrep_tbl_idx).Rejected_SubLines_Value + nvl(l_amount,0) + nvl(l_exception_amount,0) ;
  /*FOR ERROR REPORT*/
  p_billrep_err_tbl_idx := p_billrep_err_tbl_idx + 1;
  p_billrep_err_tbl(p_billrep_err_tbl_idx).Top_Line_id := p_top_line_id;
  p_billrep_err_tbl(p_billrep_err_tbl_idx).Lse_Id := 12;
  p_billrep_err_tbl(p_billrep_err_tbl_idx).Sub_line_id :=  l_subline_id ;
  p_billrep_err_tbl(p_billrep_err_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;

  p_return_status := 'E';
  WHEN OTHERS THEN
  /*FOR BILLING REPORT*/
  p_billrep_tbl(p_billrep_tbl_idx).Rejected_SubLines := p_billrep_tbl(p_billrep_tbl_idx).Rejected_SubLines + l_subline_count;
  p_billrep_tbl(p_billrep_tbl_idx).Rejected_SubLines_Value := p_billrep_tbl(p_billrep_tbl_idx).Rejected_SubLines_Value + nvl(l_amount,0) + nvl(l_exception_amount,0) ;
  /*FOR ERROR REPORT*/
  p_billrep_err_tbl_idx := p_billrep_err_tbl_idx + 1;
  p_billrep_err_tbl(p_billrep_err_tbl_idx).Top_Line_id := p_top_line_id;
  p_billrep_err_tbl(p_billrep_err_tbl_idx).Lse_Id := 12;
  p_billrep_err_tbl(p_billrep_err_tbl_idx).Sub_line_id :=  l_subline_id ;
  p_billrep_err_tbl(p_billrep_err_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;


  p_return_status := 'E';
END  Bill_usage_item;

Procedure Bill_Service_Item (
                             p_dnz_chr_id              IN            NUMBER,
                             p_contract_number         IN            VARCHAR2,
                             p_con_num_modifier        IN            VARCHAR2,
                             p_line_number             IN            VARCHAR2,
                             p_lse_id                  IN            NUMBER,
                             p_inv_org_id              IN            NUMBER,
                             p_top_line_id             IN            NUMBER,
                             p_top_line_start_date     IN            DATE,
                             p_top_line_term_date      IN            DATE,
                             p_top_line_end_date       IN            DATE,
                             p_currency_code           IN            VARCHAR2,
                             p_object1_id1             IN            VARCHAR2,
                             p_object1_id2             IN            VARCHAR2,
                             p_okl_flag                IN            NUMBER,
                             p_prv                     IN            NUMBER,
                             p_date                    IN            DATE,
                             p_summary_yn              IN            VARCHAR2,
                             p_ar_feeder_ctr           IN OUT NOCOPY NUMBER,
                             p_billrep_tbl             IN OUT NOCOPY OKS_BILL_REC_PUB.bill_report_tbl_type,
                             p_billrep_tbl_idx         IN            NUMBER,
                             p_billrep_err_tbl         IN OUT NOCOPY OKS_BILL_REC_PUB.billrep_error_tbl_type,
                             p_billrep_err_tbl_idx     IN OUT NOCOPY NUMBER,
                             p_return_status           IN OUT NOCOPY VARCHAR2
                             )
IS


/* -- This cursor gives all the covered lines of service or usage lines */
CURSOR l_subline_csr(p_cle_id  Number) Is
        SELECT sub_line.id                id
              ,sub_line.cle_id            cle_id
              ,sub_line.price_negotiated  price_negotiated
              ,sub_line.start_date        start_date
              ,sub_line.end_date          end_date
              ,sub_line.date_terminated   date_terminated
              ,sub_line.line_number       line_number /* Report */
        FROM   OKC_K_LINES_B sub_line
        WHERE  sub_line.cle_id = p_cle_id
        AND    sub_line.date_cancelled is NULL          -- [llc]
        AND    sub_line.lse_id in (8,7,9,10,11,13,25,35)
        AND    not  exists ( select 1 from okc_k_rel_objs rel
                             where rel.cle_id = sub_line.id );

Cursor qty_uom_csr(p_cle_id  Number) Is
    SELECT  okc.Number_of_items
            ,tl.Unit_of_measure uom_code
     FROM   okc_k_items okc
           ,mtl_units_of_measure_tl tl
     WHERE  okc.cle_id = p_cle_id
     AND    tl.uom_code = okc.uom_code
     AND    tl.language = USERENV('LANG');

    /*
     Select  Number_of_items
            ,OKX.Unit_of_measure uom_code
     From   OKC_K_ITEMS OKC
            ,OKX_UNITS_OF_MEASURE_V OKX
     Where  cle_id = P_cle_id
     And    Okx.uom_code = OKC.uom_code ;
     */

/*FOR BILLING REPORT*/
Cursor subline_count(p_cle_id  Number) Is
        SELECT count(sub_line.id)
        FROM   OKC_K_LINES_B sub_line
        WHERE  sub_line.cle_id = p_cle_id
        AND    sub_line.date_cancelled is NULL          -- [llc]
        AND    sub_line.lse_id in (8,7,9,10,11,13,25,35)
        AND    not  exists ( select 1 from okc_k_rel_objs rel
                             where rel.cle_id = sub_line.id );
/*FOR BILLING REPORT*/
Cursor top_line_amount(p_cle_id NUMBER) Is
    Select sum(AMOUNT)
    FROM oks_level_elements
    where CLE_ID= p_cle_id
    AND DATE_TO_INTERFACE <= p_date
    AND DATE_COMPLETED IS NULL;



l_ptr                    NUMBER;
e_ptr                    NUMBER;
no_of_cycles             NUMBER;
l_sub_line_total         NUMBER;
l_line_total             NUMBER;
l_level_elements_count   NUMBER;
l_amount                 NUMBER;
l_bcl_id                 NUMBER;
l_inv_date               DATE;
l_ar_inv_date            DATE;

l_summary_yn             VARCHAR2(1);
l_subline_count          NUMBER := 0;
l_subline_id             NUMBER;
l_errep_amount           NUMBER;

/* Variable for calling std API*/
l_api_version      CONSTANT NUMBER      := 1.0;
l_called_from      CONSTANT NUMBER      := 1;
l_init_msg_list    CONSTANT VARCHAR2(1) := 'F';
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2000);
l_return_status             VARCHAR2(1);
qty_uom_rec                 QTY_UOM_CSR%rowtype;

service_exception           EXCEPTION;
sub_service_exception       EXCEPTION;
BEGIN
  IF (l_write_log) THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG,'***Processing Service/Ext Warranty Item Starts***');
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Bill_Service_Item => Top Line Id:  ' || p_top_line_id);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Bill_Service_Item => Top Line Start Date: ' || p_top_line_start_date);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Bill_Service_Item => Top Line Termination Date/End date: ' || nvl(p_top_line_term_date,p_top_line_end_date));
  END IF;

  p_return_status        := 'S';
  l_level_elements_count := 0;
  l_line_total           := 0;

  --Start mchoudha Bug#3537100 17-APR-04
  --For Billing Report
  OPEN  subline_count(p_top_line_id);
  FETCH subline_count into l_subline_count;
  CLOSE subline_count;

  IF (p_summary_yn = 'Y') THEN
    l_summary_yn := 'Y';
  ELSE
    IF ( FND_PROFILE.VALUE('OKS_AR_TRANSACTIONS_SUBMIT_SUMMARY_YN') = 'YES') THEN
      l_summary_yn := 'Y';
    ELSE
      l_summary_yn := 'N';
    END IF;
  END IF;

  --End mchoudha Bug#3537100
  IF (l_write_log) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Bill_Service_Item => Going to process all sublines for top line '||p_top_line_id);
  END IF;

  FOR l_covlvl_rec in l_subline_csr(p_top_line_id )
  LOOP
  BEGIN

    /*FOR BILLING REPORT*/
    l_subline_id := l_covlvl_rec.id;
    IF (l_write_log)  THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Bill_Service_Item => inside FOR l_covlvl_rec Processing Coverage Id: '||l_covlvl_rec.id);
    END IF;

    level_elements_tab.delete;

    OKS_BILL_UTIL_PUB.get_next_level_element(
        P_API_VERSION        => l_api_version,
        P_ID                 => l_covlvl_rec.id,
        P_COVD_FLAG          => 'Y',     ---- flag to indicate covered level
        P_DATE               => p_date,
        P_INIT_MSG_LIST      => l_init_msg_list,
        X_RETURN_STATUS      => l_return_status,
        X_MSG_COUNT          => l_msg_count,
        X_MSG_DATA           => l_msg_data,
        X_NEXT_LEVEL_ELEMENT => level_elements_tab );

    IF (l_write_log) THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Bill_Service_Item => After calling OKS_BILL_UTIL_PUB.get_next_level_element l_return_status '||l_return_status);
    END IF;

    IF (l_return_status <> 'S') THEN
      oks_bill_rec_pub.get_message
          (l_msg_cnt  => l_msg_count,
           l_msg_data  => l_msg_data);

      l_processed_lines_tbl(l_pr_tbl_idx).Billed_YN     := 'N' ;
      l_processed_lines_tbl(l_pr_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;
      l_processed_sub_lines_tbl(l_prs_tbl_idx).Billed_YN     := 'N' ;
      l_processed_sub_lines_tbl(l_prs_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;

      FND_FILE.PUT_LINE( FND_FILE.LOG,'Bill_Service_Item =>   Failed in Creation of get_next_level_element  For coverage Id: '||l_covlvl_rec.id );
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Bill_Service_Item =>  Rolling Back the Whole Service With Top Line ID: '||p_top_line_id );

      --DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');

      RAISE sub_service_exception;
    END IF;

    IF (level_elements_tab.count < 1)  THEN
      l_processed_sub_lines_tbl.DELETE(l_prs_tbl_idx) ;
    END IF;

    e_ptr := 1;
    no_of_cycles := level_elements_tab.count;

    l_sub_line_total := 0;

    l_level_elements_count := l_level_elements_count + level_elements_tab.count;

    IF (l_write_log)  THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'No of Period for coverage: ' || no_of_cycles);
    END IF;

    OPEN  qty_uom_csr(l_covlvl_rec.id);
    FETCH qty_uom_csr into qty_uom_rec;
    CLOSE qty_uom_csr;

    IF (l_write_log) THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Bill_Service_Item => Going inside  WHILE (e_ptr <= no_of_cycles) ');
    END IF;

    WHILE (e_ptr <= no_of_cycles)
    LOOP

      l_cov_tbl.delete;
      l_sub_line_total        :=nvl(l_sub_line_total,0)
                                    + level_elements_tab(e_ptr).bill_amount ;
      l_line_total            := nvl(l_line_total,0) +
                                    + level_elements_tab(e_ptr).bill_amount ;
      l_inv_date              := level_elements_tab(e_ptr).date_to_interface;
      l_ar_inv_date           := level_elements_tab(e_ptr).date_transaction;
      l_amount                := level_elements_tab(e_ptr).bill_amount;
      l_calc_rec.l_calc_sdate := level_elements_tab(e_ptr).bill_from_date ;
      l_calc_rec.l_calc_edate := level_elements_tab(e_ptr).bill_to_date;

      IF (  l_covlvl_rec.date_terminated is not null)  AND
         ( trunc(l_calc_rec.l_calc_edate) >=
                                   trunc(l_covlvl_rec.date_terminated)) THEN
        l_calc_rec.l_calc_edate := l_covlvl_rec.date_terminated - 1;
      END IF;

      IF (l_write_log)  THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Bill_Service_Item => Coverage Interface Date: '||l_inv_date);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Bill_Service_Item => Coverage Amount        : ' || l_amount);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Bill_Service_Item => Coverage Start Date    : '||l_calc_rec.l_calc_sdate);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Bill_Service_Item => Coverage End Date      : '||l_calc_rec.l_calc_edate);
      END IF;

      IF (trunc(l_inv_date)  <= trunc(p_date)) THEN

        IF ((l_ar_inv_date is not null) And
            (l_ar_inv_date < sysdate))  THEN
          l_ar_inv_date := sysdate;
        END IF;

        IF (l_write_log)  THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Bill_Service_Item => l_ar_inv_date '||l_ar_inv_date);
        END IF;

        l_ptr :=  1;

/*******
     create bank account is no longer needed as part of R12 Bank account
    consolidation project

        OKS_BILL_REC_PUB.create_bank_Account(
             P_DNZ_CHR_ID      => p_dnz_chr_id,
             P_BILL_START_DATE => p_top_line_start_date,
             P_CURRENCY_CODE   => p_currency_code,
             X_STATUS          => l_return_status,
             L_MSG_COUNT       => l_msg_count,
             L_MSG_DATA        => l_msg_data
             );

        IF (l_write_log) THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Bill_Service_Item => After calling OKS_BILL_REC_PUB.create_bank_Account l_return_status '||l_return_status);
        END IF;

        IF (l_return_status <> 'S') THEN
          oks_bill_rec_pub.get_message
                (l_msg_cnt  => l_msg_count,
                 l_msg_data  => l_msg_data);

          l_processed_lines_tbl(l_pr_tbl_idx).Billed_YN     := 'N' ;
          l_processed_lines_tbl(l_pr_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;
          l_processed_sub_lines_tbl(l_prs_tbl_idx).Billed_YN     := 'N' ;
          l_processed_sub_lines_tbl(l_prs_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;

          FND_FILE.PUT_LINE( FND_FILE.LOG,'Bill_Service_Item =>   Failed in Creation of bank account For coverage Id: '||l_covlvl_rec.id );
          FND_FILE.PUT_LINE( FND_FILE.LOG,'Bill_Service_Item =>  Rolling Back the Whole Service With Top Line ID: '||p_top_line_id );

          --DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');

          RAISE sub_service_exception;
        END IF;
*****/

        OKS_BILL_REC_PUB.Insert_bcl
             (
              P_CALLEDFROM        => l_called_from,
              X_RETURN_STAT       => l_return_status,
              P_CLE_ID            => p_top_line_id,
              P_DATE_BILLED_FROM  => l_calc_rec.l_calc_sdate,
              P_DATE_BILLED_TO    => l_calc_rec.l_calc_edate,
              P_DATE_NEXT_INVOICE => l_ar_inv_date,
              P_BILL_ACTION       => 'RI',
              P_OKL_FLAG          => p_okl_flag,
              P_PRV               => p_prv,
              P_MSG_COUNT         => l_msg_count,
              P_MSG_DATA          => l_msg_data,
              X_BCL_ID            => l_bcl_id
             );

        IF (l_write_log)  THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Bill_Service_Item => After calling OKS_BILL_REC_PUB.Insert_bcl l_return_status '||l_return_status);
        END IF;

        IF (l_return_status <> 'S') THEN
          oks_bill_rec_pub.get_message(
               l_msg_cnt  => l_msg_count,
               l_msg_data  => l_msg_data);
          l_processed_lines_tbl(l_pr_tbl_idx).Billed_YN     := 'N' ;
          l_processed_lines_tbl(l_pr_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;
          l_processed_sub_lines_tbl(l_prs_tbl_idx).Billed_YN     := 'N' ;
          l_processed_sub_lines_tbl(l_prs_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;

          FND_FILE.PUT_LINE( FND_FILE.LOG,'Bill_Service_Item => Failed in Insert BCL For coverage Id: ' ||l_covlvl_rec.id );
          FND_FILE.PUT_LINE( FND_FILE.LOG,'Bill_Service_Item => Rolling Back the Whole Service With Top Line ID: '||p_top_line_id );

          RAISE sub_service_exception;
        END IF;

        IF (p_prv <> 2) THEN

          UPDATE oks_level_elements
          SET date_Completed = l_calc_rec.l_calc_edate
          WHERE  id = level_elements_tab(e_ptr).id;

        END IF;

        l_cov_tbl(l_ptr).id                 := l_covlvl_rec.id;
        l_cov_tbl(l_ptr).bcl_id             := l_bcl_id;
        l_cov_tbl(l_ptr).date_billed_from   := l_calc_rec.l_calc_sdate;
        l_cov_tbl(l_ptr).date_billed_to     := l_calc_rec.l_calc_edate;
        l_cov_tbl(l_ptr).average            := 0;
        l_cov_tbl(l_ptr).unit_of_measure    := qty_uom_rec.uom_code;
        l_cov_tbl(l_ptr).fixed              := 0 ;
        l_cov_tbl(l_ptr).actual             := null;
        l_cov_tbl(l_ptr).default_default    := 0;
        l_cov_tbl(l_ptr).amcv_yn            := 'N';
        l_cov_tbl(l_ptr).adjustment_level   := 0 ;
        l_cov_tbl(l_ptr).result             := qty_uom_rec.number_of_items ;
        l_cov_tbl(l_ptr).x_stat             := null;
        l_cov_tbl(l_ptr).amount             := l_amount;
        l_cov_tbl(l_ptr).bcl_amount         := nvl(l_calc_rec.l_bcl_amount,0);
        l_cov_tbl(l_ptr).date_to_interface  := sysdate;

      END IF; -- (trunc(l_inv_date)  <= trunc(p_date))

      IF ( l_write_log) THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Bill_Service_Item => l_cov_tbl.count '||l_cov_tbl.count);
      END IF;

      IF (l_cov_tbl.count > 0) THEN
        p_ar_feeder_ctr := 1;
        OKS_BILL_REC_PUB.Insert_all_subline
             (
              P_CALLEDFROM     => l_called_from,
              X_RETURN_STAT    => l_return_status,
              P_COVERED_TBL    => l_cov_tbl,
              P_CURRENCY_CODE  => p_currency_code,
              P_DNZ_CHR_ID     => p_dnz_chr_id,
              P_PRV            => p_prv,
              P_MSG_COUNT      => l_msg_count,
              P_MSG_DATA       => l_msg_data
              );

      END IF;

      IF (l_write_log) THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Bill_Service_Item => After calling OKS_BILL_REC_PUB.Insert_all_subline l_return_status '||l_return_status);
      END IF;

      IF (l_return_status <> 'S')  THEN
        oks_bill_rec_pub.get_message(
               l_msg_cnt  => l_msg_count,
               l_msg_data => l_msg_data);
        l_processed_lines_tbl(l_pr_tbl_idx).Billed_YN     := 'N' ;
        l_processed_lines_tbl(l_pr_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;
        l_processed_sub_lines_tbl(l_prs_tbl_idx).Billed_YN     := 'N' ;
        l_processed_sub_lines_tbl(l_prs_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;

        FND_FILE.PUT_LINE( FND_FILE.LOG, 'Bill_Service_Item => Insert into sublines table failed Contract line id :'||p_top_line_id);
        FND_FILE.PUT_LINE( FND_FILE.LOG,'Bill_Service_Item =>  Rolling Back the Whole Service With Top Line ID: '||p_top_line_id );
        --DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
        RAISE sub_service_exception;
      END IF;

      /* Following code is to update the date_completed field of top line  */

      IF (p_prv <> 2) THEN
        UPDATE oks_level_elements
        SET date_completed = l_calc_rec.l_calc_edate
        WHERE cle_id = p_top_line_id
        AND   date_completed is null
        AND   date_start <= l_calc_rec.l_calc_sdate;
      END IF;

      IF (l_write_log) THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Bill_Service_Item => After updating oks_level_elements ');
      END IF;

      e_ptr := e_ptr + 1;

    END LOOP; -- While eptr loop

    l_processed_sub_lines_tbl(l_prs_tbl_idx).Bill_Amount  := l_sub_line_total;




  EXCEPTION
    WHEN sub_service_exception THEN
      p_return_status := 'E';

      /* FOR BILLING REPORT */
      Open top_line_amount(p_top_line_id);
      Fetch top_line_amount into l_errep_amount;
      Close top_line_amount;
      IF (l_summary_yn = 'N') THEN
        p_billrep_tbl(p_billrep_tbl_idx).Rejected_SubLines := p_billrep_tbl(p_billrep_tbl_idx).Rejected_SubLines + l_subline_count;
        p_billrep_tbl(p_billrep_tbl_idx).Rejected_SubLines_Value := p_billrep_tbl(p_billrep_tbl_idx).Rejected_SubLines_Value
                                                                                                       + nvl(l_errep_amount,0);

        /*FOR ERROR REPORT*/
        p_billrep_err_tbl_idx := p_billrep_err_tbl_idx + 1;
        p_billrep_err_tbl(p_billrep_err_tbl_idx).Top_Line_id := p_top_line_id;
        p_billrep_err_tbl(p_billrep_err_tbl_idx).Lse_Id := 1;
        p_billrep_err_tbl(p_billrep_err_tbl_idx).Sub_line_id :=l_subline_id ;
        p_billrep_err_tbl(p_billrep_err_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;


      ELSE
        /*FOR ERROR REPORT*/
        p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines := p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines + 1;
        p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines_Value := p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines_Value
                                                                                                       + nvl(l_errep_amount,0);

        p_billrep_err_tbl_idx := p_billrep_err_tbl_idx + 1;
        p_billrep_err_tbl(p_billrep_err_tbl_idx).Top_Line_id := p_top_line_id;
        p_billrep_err_tbl(p_billrep_err_tbl_idx).Lse_Id := 1;
        p_billrep_err_tbl(p_billrep_err_tbl_idx).Sub_line_id :=NULL;
       p_billrep_err_tbl(p_billrep_err_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;

      END IF;

      FND_FILE.PUT_LINE( FND_FILE.LOG,'Bill_Service_Item => Failed- sub_service_exception exception raised for coverage:  '||l_covlvl_rec.id||' With Error: '||sqlerrm );
      EXIT;
    WHEN OTHERS THEN
      --DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
      /* FOR BILLING REPORT */
      Open top_line_amount(p_top_line_id);
      Fetch top_line_amount into l_errep_amount;
      Close top_line_amount;
      IF (l_summary_yn = 'N') THEN
        p_billrep_tbl(p_billrep_tbl_idx).Rejected_SubLines := p_billrep_tbl(p_billrep_tbl_idx).Rejected_SubLines + l_subline_count;
        p_billrep_tbl(p_billrep_tbl_idx).Rejected_SubLines_Value := p_billrep_tbl(p_billrep_tbl_idx).Rejected_SubLines_Value + nvl(l_errep_amount,0);

        /*FOR ERROR REPORT*/
        p_billrep_err_tbl_idx := p_billrep_err_tbl_idx + 1;
        p_billrep_err_tbl(p_billrep_err_tbl_idx).Top_Line_id := p_top_line_id;
        p_billrep_err_tbl(p_billrep_err_tbl_idx).Lse_Id := 1;
        p_billrep_err_tbl(p_billrep_err_tbl_idx).Sub_line_id :=l_subline_id ;
        p_billrep_err_tbl(p_billrep_err_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;


      ELSE
        /*FOR ERROR REPORT*/
        p_billrep_err_tbl_idx := p_billrep_err_tbl_idx + 1;
        p_billrep_err_tbl(p_billrep_err_tbl_idx).Top_Line_id := p_top_line_id;
        p_billrep_err_tbl(p_billrep_err_tbl_idx).Lse_Id := 1;
        p_billrep_err_tbl(p_billrep_err_tbl_idx).Sub_line_id :=NULL;
        p_billrep_err_tbl(p_billrep_err_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;

      END IF;
      p_return_status := 'E';
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Bill_Service_Item => Failed- when others  exception raised for coverage '||l_covlvl_rec.id||' With Error: '||sqlerrm );
      EXIT;
  END;
  END LOOP;  -- FOR loop for covered level

  --l_processed_lines_tbl(l_pr_tbl_idx).Bill_Amount       := l_line_total ;

  /* FOR BILLING REPORT */
 -- IF (l_summary_yn = 'Y' AND p_return_status <> 'E') THEN
 --   p_billrep_tbl(p_billrep_tbl_idx).Successful_Lines := p_billrep_tbl(p_billrep_tbl_idx).Successful_Lines + 1;
 --   p_billrep_tbl(p_billrep_tbl_idx).Successful_Lines_Value := p_billrep_tbl(p_billrep_tbl_idx).Successful_Lines_Value + nvl(l_line_total,0);
 -- END IF;

  IF (l_summary_yn = 'Y' AND p_return_status = 'E') THEN
    p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines := p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines + 1;
    p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines_Value := p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines_Value + nvl(l_line_total,0);
  END IF;



  /* ** Delete the record from billing report table if no subline is billed***/

  IF (l_level_elements_count <= 0)  THEN
    l_processed_lines_tbl.DELETE(l_pr_tbl_idx) ;
  END IF;

  IF (l_write_log) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'***Processing Service/Ext Warranty Item Ends ***');
  END IF;


EXCEPTION
 WHEN SERVICE_EXCEPTION THEN
   p_return_status := 'E';
  /* FOR BILLING REPORT */
  IF (l_summary_yn = 'Y') THEN
    p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines := p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines + 1;
    p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines_Value := p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines_Value + nvl(l_line_total,0);
  END IF;
  FND_FILE.PUT_LINE( FND_FILE.LOG,'Bill_Service_Item => Failed- when SERVICE_EXCEPTION  exception raised '||sqlerrm );
 WHEN OTHERS THEN
   p_return_status := 'E';
  /* FOR BILLING REPORT */
  IF (l_summary_yn = 'Y') THEN
    p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines := p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines + 1;
    p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines_Value := p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines_Value + nvl(l_line_total,0);
  END IF;
  FND_FILE.PUT_LINE( FND_FILE.LOG,'Bill_Service_Item => Failed-outside  when OTHERS  exception raised '||sqlerrm );
END Bill_Service_Item;


Procedure Bill_Subscription_item(
                     p_dnz_chr_id          IN            NUMBER,
                     p_top_line_id         IN            NUMBER,
                     p_top_line_start_date IN            DATE,
                     p_top_line_term_date  IN            DATE,
                     p_top_line_end_date   IN            DATE,
                     p_currency_code       IN            VARCHAR2,
                     p_okl_flag            IN            NUMBER,
                     p_nos_of_items        IN            NUMBER,
                     p_uom_code            IN            VARCHAR2,
                     p_prv                 IN            NUMBER,
                     p_date                IN            DATE,
                     p_billrep_tbl         IN OUT NOCOPY OKS_BILL_REC_PUB.bill_report_tbl_type,
                     p_billrep_tbl_idx     IN            NUMBER,
                                 p_billrep_err_tbl     IN OUT NOCOPY OKS_BILL_REC_PUB.billrep_error_tbl_type,
                                 p_billrep_err_tbl_idx IN OUT NOCOPY NUMBER,
                     p_ar_feeder_ctr       IN OUT NOCOPY NUMBER,
                                 p_return_status       IN OUT NOCOPY VARCHAR2)
IS
l_ptr                       NUMBER    := 0;
e_ptr                       NUMBER;
no_of_elements              NUMBER;
l_amount                    NUMBER;
l_bcl_id                    NUMBER;
l_line_total                NUMBER;
l_inv_date                  DATE;
l_ar_inv_date               DATE;
l_bill_start_date           DATE;
l_bill_end_date             DATE;


/* Variable for calling std API*/
l_api_version      CONSTANT NUMBER      := 1.0;
l_called_from      CONSTANT NUMBER      := 1;
l_init_msg_list    CONSTANT VARCHAR2(1) := 'F';
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2000);
l_return_status             VARCHAR2(1);

/*Exception Definition */
SUBSRIPTION_EXCEPTION       EXCEPTION;

BEGIN
  p_return_status  :=  'S';
  level_elements_tab.delete;

  IF (l_write_log) THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'***Processing Subscription Item ***');
    FND_FILE.PUT_LINE(FND_FILE.LOG,' Top Line Id:  ' || p_top_line_id);
    FND_FILE.PUT_LINE(FND_FILE.LOG,' Top Line Start Date: ' || p_top_line_start_date);
    FND_FILE.PUT_LINE(FND_FILE.LOG,' Top Line Termination Date/End date: ' || nvl(p_top_line_term_date,p_top_line_end_date));
  END IF;

  oks_bill_util_pub.get_next_level_element(
           p_api_version        => l_api_version,
           p_id                 => p_top_line_id,
           p_covd_flag          => 'N',     ---- flag to indicate Top line
           p_date               => p_date,
           p_init_msg_list      => l_init_msg_list,
           x_return_status      => l_return_status,
           x_msg_count          => l_msg_count,
           x_msg_data           => l_msg_data,
           x_next_level_element => level_elements_tab );

  IF (l_return_status <> 'S') Then
    oks_bill_rec_pub.get_message(
               l_msg_cnt  => l_msg_count,
               l_msg_data => l_msg_data);
    l_processed_lines_tbl(l_pr_tbl_idx).Billed_YN     := 'N' ;
    l_processed_lines_tbl(l_pr_tbl_idx).Error_Message := 'Error: '||
sqlerrm||'. Error Message: '||l_msg_data ;

    FND_FILE.PUT_LINE( FND_FILE.LOG, 'Failed in getting next level ');

    Raise SUBSRIPTION_EXCEPTION;
  END IF;

  e_ptr           := 1;
  no_of_elements  := level_elements_tab.count;
  l_line_total    := 0;

  WHILE (e_ptr <= no_of_elements)
  LOOP
    l_inv_date          := level_elements_tab(e_ptr).date_to_interface;
    l_ar_inv_date       := level_elements_tab(e_ptr).date_transaction;
    l_amount            := level_elements_tab(e_ptr).bill_amount;
    l_bill_start_date   := level_elements_tab(e_ptr).bill_from_date;
    l_bill_end_date     := level_elements_tab(e_ptr).bill_to_date;
    l_line_total        := l_line_total+level_elements_tab(e_ptr).bill_amount;

    l_ptr := 1;
    l_cov_tbl.delete;


    IF (trunc(l_inv_date)  <= trunc(p_date)) THEN
      IF ((l_ar_inv_date is not null) AND
            (l_ar_inv_date < sysdate))  THEN
        l_ar_inv_date := sysdate;
      END IF;

/*******
     create bank account is no longer needed as part of R12 Bank account
    consolidation project

      OKS_BILL_REC_PUB.create_bank_Account(
             P_DNZ_CHR_ID      => p_dnz_chr_id,
             P_BILL_START_DATE => p_top_line_start_date,
             P_CURRENCY_CODE   => p_currency_code,
             X_STATUS          => l_return_status,
             L_MSG_COUNT       => l_msg_count,
             L_MSG_DATA        => l_msg_data
             );

      IF (l_return_status <> 'S') THEN
        oks_bill_rec_pub.get_message(
                   l_msg_cnt  => l_msg_count,
                   l_msg_data => l_msg_data);
        l_processed_lines_tbl(l_pr_tbl_idx).Billed_YN     := 'N' ;
        l_processed_lines_tbl(l_pr_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;

        --DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
        FND_FILE.PUT_LINE( FND_FILE.LOG,' Failed in Creation of bank account');
        FND_FILE.PUT_LINE( FND_FILE.LOG,' Rolling Back the Whole Service '||p_top_line_id );

        RAISE SUBSRIPTION_EXCEPTION;
      END IF;
***/

       /*This procedure insert the into bill_con_lines,
         if the record is not already present for the same period.
         Since the out table returns the row_id of the inserted row, get_bcl_id
         which was present in earliar version is now  removed*/
      OKS_BILL_REC_PUB.Insert_bcl
             (
             P_CALLEDFROM        => l_called_from,
             X_RETURN_STAT       => l_return_status,
             P_CLE_ID            => p_top_line_id,
             P_DATE_BILLED_FROM  => l_bill_start_date,
             P_DATE_BILLED_TO    => l_bill_end_date,
             P_DATE_NEXT_INVOICE => l_ar_inv_date,
             P_BILL_ACTION       => 'RI',
             P_OKL_FLAG          => p_okl_flag,
             P_PRV               => p_prv,
             P_MSG_COUNT         => l_msg_count,
             P_MSG_DATA          => l_msg_data,
             X_BCL_ID            => l_bcl_id
             );

       IF (l_return_status <> 'S')  THEN
         oks_bill_rec_pub.get_message(
                   l_msg_cnt  => l_msg_count,
                   l_msg_data => l_msg_data);
         l_processed_lines_tbl(l_pr_tbl_idx).Billed_YN     := 'N' ;
         l_processed_lines_tbl(l_pr_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;

         FND_FILE.PUT_LINE( FND_FILE.LOG, 'Failed in insert bcl ');
         Raise SUBSRIPTION_EXCEPTION;
       END IF;

       IF (p_prv <> 2)  THEN

         UPDATE oks_level_elements
          SET date_completed = l_bill_end_date
          WHERE id = level_elements_tab(e_ptr).id;

       END IF;

       l_cov_tbl(l_ptr).flag               := Null;
       l_cov_tbl(l_ptr).id                 := p_top_line_id ;
       l_cov_tbl(l_ptr).bcl_id             := l_bcl_id;
       l_cov_tbl(l_ptr).date_billed_from   := l_bill_start_date;
       l_cov_tbl(l_ptr).date_billed_to     := l_bill_end_date;
       l_cov_tbl(l_ptr).amount             := l_amount;
       l_cov_tbl(l_ptr).average            := 0;
       l_cov_tbl(l_ptr).unit_of_measure    := p_uom_code;
       l_cov_tbl(l_ptr).fixed              := 0;
       l_cov_tbl(l_ptr).actual             := null;
       l_cov_tbl(l_ptr).default_default    := 0;
       l_cov_tbl(l_ptr).amcv_yn            := 'N';
       l_cov_tbl(l_ptr).adjustment_level   := 0 ;
       l_cov_tbl(l_ptr).adjustment_minimum := 0 ;
       l_cov_tbl(l_ptr).result             := 1 ;
       l_cov_tbl(l_ptr).x_stat             := Null ;
       l_cov_tbl(l_ptr).bcl_amount         := 0;--nvl(l_calc_rec.l_bcl_amount,0);
       l_cov_tbl(l_ptr).date_to_interface  := sysdate;

       IF (l_cov_tbl.count > 0) THEN
          /* check if this is to be passed back to main api */
         p_ar_feeder_ctr := 1;
         OKS_BILL_REC_PUB.Insert_all_subline
                (
                P_CALLEDFROM     => l_called_from,
                X_RETURN_STAT    => l_return_status,
                P_COVERED_TBL    => l_cov_tbl,
                P_CURRENCY_CODE  => p_currency_code,
                P_DNZ_CHR_ID     => p_dnz_chr_id,
                P_PRV            => p_prv,
                P_MSG_COUNT      => l_msg_count,
                P_MSG_DATA       => l_msg_data
                );

         IF (l_write_log) THEN
           FND_FILE.PUT_LINE( FND_FILE.LOG, 'Status after insert into sublines '||l_return_status );
         END IF;

         IF (l_return_status <> 'S') THEN
           oks_bill_rec_pub.get_message(
                   l_msg_cnt  => l_msg_count,
                   l_msg_data => l_msg_data);
           l_processed_lines_tbl(l_pr_tbl_idx).Billed_YN     := 'N ' ;
           l_processed_lines_tbl(l_pr_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;
           FND_FILE.PUT_LINE( FND_FILE.LOG, 'Insert into sublines table failed  Contract line id : '||p_top_line_id);
           --DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION ');
           Raise SUBSRIPTION_EXCEPTION;
         END IF;

       END IF; -- l_cov_tbl.count > 0
     END IF;  -- l_inv_date <= p_date
     e_ptr := e_ptr + 1 ;

  END LOOP;



EXCEPTION
 WHEN SUBSRIPTION_EXCEPTION THEN
   /*FOR BILLING REPORT*/
    p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines := p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines + 1;
    p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines_Value := p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines_Value + nvl(l_line_total,0);
    /*FOR ERROR REPORT*/
    p_billrep_err_tbl_idx := p_billrep_err_tbl_idx + 1;
    p_billrep_err_tbl(p_billrep_err_tbl_idx).Top_Line_id := p_top_line_id;
    p_billrep_err_tbl(p_billrep_err_tbl_idx).Lse_Id := 46;
    p_billrep_err_tbl(p_billrep_err_tbl_idx).Sub_line_id := NULL;
    p_billrep_err_tbl(p_billrep_err_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;
    p_return_status := 'E';
 WHEN OTHERS THEN
    /*FOR BILLING REPORT*/
    p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines := p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines + 1;
    p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines_Value := p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines_Value + nvl(l_line_total,0);
    /*FOR ERROR REPORT*/
    p_billrep_err_tbl_idx := p_billrep_err_tbl_idx + 1;
    p_billrep_err_tbl(p_billrep_err_tbl_idx).Top_Line_id := p_top_line_id;
    p_billrep_err_tbl(p_billrep_err_tbl_idx).Lse_Id := 46;
    p_billrep_err_tbl(p_billrep_err_tbl_idx).Sub_line_id := NULL;
    p_billrep_err_tbl(p_billrep_err_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;
   p_return_status := 'E';
END Bill_Subscription_item;



procedure update_version (
     p_dnz_chr_id  IN NUMBER
) IS  pragma autonomous_transaction;

 l_con_update_date  date;
 l_chrv_rec         OKC_CONTRACT_PUB.chrv_rec_type;
 l_chrv_out_rec     OKC_CONTRACT_PUB.chrv_rec_type;
 l_cvmv_rec         OKC_CVM_PVT.cvmv_rec_type ;
 l_cvmv_out_rec     OKC_CVM_PVT.cvmv_rec_type ;
 l_return_status               VARCHAR2(1);
 l_msg_data                    VARCHAR2(2000);
 l_msg_cnt                     NUMBER;
 l_api_version      CONSTANT   NUMBER      := 1.0;
 l_init_msg_list    CONSTANT   VARCHAR2(1) := 'F';

Cursor l_contract_update_date(p_chr_id IN NUMBER) is
  SELECT last_update_date from okc_k_headers_b
  WHERE id = p_chr_id;


  BEGIN

	   OPEN  l_contract_update_date(p_dnz_chr_id);
	   FETCH l_contract_update_date into l_con_update_date;
	   CLOSE l_contract_update_date;

	   IF (trunc(l_con_update_date) <> trunc(sysdate)) THEN
	     okc_cvm_pvt.g_trans_id := 'XXX';
	     l_cvmv_rec.chr_id := p_dnz_chr_id;

          OKC_CVM_PVT.update_contract_version(
	       P_API_VERSION    => l_api_version,
	       P_INIT_MSG_LIST  => l_init_msg_list,
	       X_RETURN_STATUS  => l_return_status,
	       X_MSG_COUNT      => l_msg_cnt,
	       X_MSG_DATA       => l_msg_data,
	       P_CVMV_REC       => l_cvmv_rec,
	       X_CVMV_REC       => l_cvmv_out_rec);

          IF l_write_log THEN
            FND_FILE.PUT_LINE( FND_FILE.LOG, 'OKS_BILLING_PUB.Calculate_bill => After calling OKC_CVM_PVT.update_contract_version l_return_status '||l_return_status);
          END IF;

          l_chrv_rec.id := p_dnz_chr_id;
	     l_chrv_rec.last_update_date := sysdate;

	     OKC_CONTRACT_PUB.update_contract_header(
	       P_API_VERSION       => l_api_version,
	       X_RETURN_STATUS     => l_return_status,
	       P_INIT_MSG_LIST     => OKC_API.G_TRUE,
	       X_MSG_COUNT         => l_msg_cnt,
	       X_MSG_DATA          => l_msg_data,
	       P_RESTRICTED_UPDATE => OKC_API.G_TRUE,
	       P_CHRV_REC          => l_chrv_rec,
	       X_CHRV_REC          => l_chrv_out_rec);

          IF l_write_log THEN
             FND_FILE.PUT_LINE( FND_FILE.LOG, 'OKS_BILLING_PUB.Calculate_bill => After calling OKC_CONTRACT_PUB.update_contract_header l_return_status '||l_return_status);
          END IF;

		COMMIT;

        END IF;

    EXCEPTION
        WHEN  OTHERS THEN
        FND_FILE.PUT_LINE( FND_FILE.LOG,'OKS_BILLING_PUB.Calculate_bill => Failed- updating version'||sqlerrm );

End update_version;



 Procedure Calculate_bill
 (
  ERRBUF                     OUT  NOCOPY VARCHAR2
 ,RETCODE                    OUT  NOCOPY NUMBER
 ,P_calledfrom                IN         NUMBER
 ,P_flag                      IN         NUMBER
 ,P_date                      IN         DATE
 ,P_process_from              IN         NUMBER
 ,P_process_to                IN         NUMBER
 ,P_Prv                       IN         NUMBER
 )


 Is
 Cursor billing_process (p_line_from     IN     NUMBER,
                         p_line_to       IN     NUMBER) IS
 SELECT chr_id,cle_id,line_no
   FROM oks_process_billing
   WHERE line_no between p_line_from and p_line_to;

 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 11-JUN-2005
 -- Added period_start,period_type and price_uom in the select clause
 -- This is done to avoid calling oks_renew_util_pub.get_period_defaults
 -- so avoind hitting the database once more
 -------------------------------------------------------------------------
 Cursor l_bill_line_csr(p_hdr_id  IN NUMBER,
                        p_line_id IN NUMBER) IS
        SELECT line.id
              ,Hdr.Contract_number
              ,Hdr.Contract_number_modifier
              ,Hdr.Currency_code
              ,Hdr.Inv_organization_id
              ,Hdr.authoring_org_id
              ,Hdr.org_id
              ,line.dnz_chr_id
              ,line.cle_id
              ,line.lse_id
              ,line.start_date
              ,line.end_date
              ,line.price_negotiated
              ,line.date_terminated
              ,okp.object1_id1
              ,okp.object1_id2
              ,line.line_number
              ,rul.ar_interface_yn
              ,rul.period_start
              ,rul.period_type
              ,rul.price_uom
              ,nvl(rul.summary_trx_yn,'N') summary_yn
              ,rline.settlement_interval
       FROM
               OKC_K_PARTY_ROLES_B  okp
              ,OKC_K_LINES_B  line
              ,OKS_K_LINES_B  rline
              ,OKC_K_HEADERS_B Hdr
              ,OKS_K_HEADERS_B rul
        WHERE  Hdr.id          = p_hdr_id
        AND    line.id         = p_line_id
        AND    rline.cle_id    = line.id
        AND    rul.chr_id      = Hdr.id
        AND    line.dnz_chr_id = Hdr.id
        AND    line.lse_id in (1,12,19,46)
        AND    okp.dnz_chr_id  =  hdr.id
        AND    okp.rle_code    in ( 'CUSTOMER','SUBSCRIBER');



 Cursor l_inv_item_csr(p_cle_id Number,p_org_id Number) Is
     SELECT item.Object1_id1
        ,mtl.usage_item_flag
        ,mtl.service_item_flag
        ,mtl.primary_uom_code
  FROM   Okc_K_items Item
        ,mtl_system_items_b   mtl  --Okx_system_items_v mtl
  WHERE  item.cle_id = p_cle_id
  --AND    mtl.id1 = item.object1_id1
  AND    mtl.inventory_item_id = item.object1_id1
  AND    mtl.organization_id = p_org_id;

Cursor qty_uom_csr(p_cle_id  Number) Is
     SELECT  okc.Number_of_items
            ,tl.Unit_of_measure uom_code
     FROM   okc_k_items okc
           ,mtl_units_of_measure_tl tl
     WHERE  okc.cle_id = p_cle_id
     AND    tl.uom_code = okc.uom_code
     AND    tl.language = USERENV('LANG');

     /*
     SELECT  Number_of_items
            ,OKX.Unit_of_measure uom_code
     FROM   OKC_K_ITEMS OKC
            ,OKX_UNITS_OF_MEASURE_V OKX
     WHERE  cle_id = P_cle_id
     AND    Okx.uom_code = OKC.uom_code ;
     */

Cursor l_uom_csr Is
      SELECT uom_code
      FROM   Okc_time_code_units_v
      WHERE  tce_code = 'DAY'
      AND    quantity = 1
      AND    active_flag = 'Y';


Cursor l_okl_contract_csr(p_chr_id IN NUMBER) is
  SELECT 1 from okc_k_rel_objs
  WHERE  rty_code in ('OKLSRV','OKLUBB')
  AND    jtot_object1_code = 'OKL_SERVICE'
  AND    object1_id1 = to_char(p_chr_id);


Cursor l_contract_update_date(p_chr_id IN NUMBER) is
  SELECT last_update_date from okc_k_headers_b
  WHERE id = p_chr_id;




 X_return_status    Varchar2(1); -- was a parameter until subrequest impl.
 l_cvmv_rec         OKC_CVM_PVT.cvmv_rec_type ;
 l_cvmv_out_rec     OKC_CVM_PVT.cvmv_rec_type ;
 l_chrv_rec         OKC_CONTRACT_PUB.chrv_rec_type;
 l_chrv_out_rec     OKC_CONTRACT_PUB.chrv_rec_type;
 qty_uom_rec        QTY_UOM_CSR%rowtype;
 l_bill_rec         L_BILL_LINE_CSR%rowtype;
 l_item_rec         L_INV_ITEM_CSR%rowtype;

 l_return_status               VARCHAR2(1);
 l_msg_count                   NUMBER;
 l_msg_data                    VARCHAR2(2000);
 l_okl_flag                    NUMBER := 0;
 l_msg_cnt                     NUMBER;
 l_api_version      CONSTANT   NUMBER      := 1.0;
 l_init_msg_list    CONSTANT   VARCHAR2(1) := 'F';
 l_uom_code                    VARCHAR2(25);
 l_select_counter              NUMBER   := 0;
 l_reject_counter              NUMBER   := 0;
 l_process_counter             NUMBER   := 0;
 l_ar_feeder_ctr               NUMBER   := 0;
 l_con_update_date             DATE  ;

 sub_line_exception            EXCEPTION ;
 Main_line_exception           EXCEPTION ;

SUBTYPE l_bclv_tbl_type_in  is OKS_bcl_PVT.bclv_tbl_type;

 l_bclv_tbl_in   l_bclv_tbl_type_in;
 l_bclv_tbl_out   l_bclv_tbl_type_in;

Type l_num_tbl is table of NUMBER index  by BINARY_INTEGER ;
chr_id              l_num_tbl;
cle_id              l_num_tbl;
l_line_no           l_num_tbl;

  l_sign                     Number;
  l_line_total               Number := 0;
  l_level_elements_count     Number := 0;
  l_sub_line_total           Number := 0;
  l_sub_line_total_tmp       Number := 0;
  l_g_ptr                    Number := 0 ;
  l_g_tbl_count              Number := 0 ;


  --Start mchoudha Bug#3537100 17-APR-04
  --For Billing Report

  l_billrep_tbl            OKS_BILL_REC_PUB.bill_report_tbl_type;
  l_billrep_tbl_idx        NUMBER;
  l_billrep_found          BOOLEAN;
  j                        NUMBER;
  l_billrep_err_tbl        OKS_BILL_REC_PUB.billrep_error_tbl_type;
  l_billrep_errtbl_idx     NUMBER;

  --End mchoudha Bug#3537100

--Bug#5378184
l_err_code varchar2(10);

 BEGIN

   RETCODE := 0;
   X_return_status := 'S';

   --mchoudha Fix for bug#4198616
   --initializing the variables in case of parallel workers
   l_yes_no :=  Fnd_profile.value('OKS_BILLING_REPORT_AND_LOG');
   FND_FILE.PUT_LINE( FND_FILE.LOG, 'OKS_BILLING_PUB.Calculate_bill => OKS: Billing Report And Log is set to '||l_yes_no);

   If l_write_log then
     FND_FILE.PUT_LINE( FND_FILE.LOG, 'OKS_BILLING_PUB.Calculate_bill processing starts ');
   End If;

   If l_yes_no = 'YES' then
      l_write_log       := TRUE;
      l_write_report    := TRUE;
   Else
      l_write_log       := FALSE;
      l_write_report    := FALSE;
   End If;


   OPEN  l_uom_csr;
   FETCH l_uom_csr into l_uom_code;
   CLOSE l_uom_csr;

   IF l_uom_code Is Null Then
     FND_FILE.PUT_LINE( FND_FILE.LOG, 'Time Units Of measure not set for DAY');
     Raise G_EXCEPTION_HALT_VALIDATION;
   END IF;

   --/*Set The p_date which is used to control the program*/
   --p_date := nvl(P_Default_Date,sysdate);

   --Start by mchoudha Bug#3537100 17-APR-04
   --For Billing Report
   /*
   l_pr_tbl_idx      := 0 ;
   l_prs_tbl_idx     := 0 ;
   */

   l_billrep_tbl_idx    := -1 ;
   l_billrep_errtbl_idx := -1 ;
   --End mchoudha Bug#3537100

   If l_write_log then
     FND_FILE.PUT_LINE( FND_FILE.LOG, 'OKS_BILLING_PUB.Calculate_bill => Opening billing_process cursor from '||p_process_from||' to '||p_process_to);
   End If;




   OPEN billing_process(p_process_from , p_process_to) ;
   LOOP
   FETCH billing_process bulk collect
                   INTO chr_id, cle_id,l_line_no LIMIT 10000;

     If l_write_log then
       FND_FILE.PUT_LINE( FND_FILE.LOG, 'OKS_BILLING_PUB.Calculate_bill => After Fetch billing_process cursor count of line ids fetched '||cle_id.count);
     End If;

     IF cle_id.COUNT > 0 THEN          --chk for count


       FOR i in  cle_id.FIRST..cle_id.LAST
       LOOP

       BEGIN

         DBMS_TRANSACTION.SAVEPOINT('BEFORE_TRANSACTION');

            IF l_write_log THEN
           FND_FILE.PUT_LINE( FND_FILE.LOG, 'OKS_BILLING_PUB.Calculate_bill => B4 opening cursor l_bill_line_csr line id '||cle_id(i)||' header ID '||chr_id(i)||' line number '||l_line_no(i));
         END IF;

         /*****
         The policy context is set to multiple for Bug# 6158988
         This is because context is set for a particular org
         down the code and need to reset it back
         *****/
         mo_global.set_policy_context('M', Null);


         OPEN  l_bill_line_csr (chr_id(i),cle_id(i));
         FETCH l_bill_line_csr into l_bill_rec  ;
         IF (l_bill_line_csr%notfound) THEN
           FND_FILE.PUT_LINE(FND_FILE.LOG,'not found l_bill_line_csr for line id '||cle_id(i)||' for contract id '||chr_id(i));
           CLOSE l_bill_line_csr;
           RAISE MAIN_LINE_EXCEPTION;
         END IF;
         CLOSE l_bill_line_csr;


         l_select_counter := l_select_counter + 1;
         l_ar_Feeder_ctr  := 0;

         IF l_write_log THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_BILLING_PUB.Calculate_bill => Contract# : '||l_bill_rec.Contract_number);
            FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_BILLING_PUB.Calculate_bill => Modifier: '||l_bill_rec.Contract_number_modifier);
            FND_FILE.PUT_LINE( FND_FILE.LOG,'OKS_BILLING_PUB.Calculate_bill => Parameter Default Date ' || P_date);
            FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_BILLING_PUB.Calculate_bill => Period Start# : '||l_bill_rec.period_start);
            FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_BILLING_PUB.Calculate_bill =>  Period Type: '||l_bill_rec.period_type);
            FND_FILE.PUT_LINE( FND_FILE.LOG,'OKS_BILLING_PUB.Calculate_bill => Price_uom ' ||l_bill_rec.price_uom);
         END IF;

         -- Commented as part of R12. Authoring org id changed to org_id (MOAC)
         -- okc_context.set_okc_org_context(l_bill_Rec.authoring_org_id, Null);
         okc_context.set_okc_org_context(l_bill_Rec.org_id, Null);

            IF l_write_log THEN
           FND_FILE.PUT_LINE( FND_FILE.LOG, 'OKS_BILLING_PUB.Calculate_bill => After setting okc_context.set_okc_org_context for org '||l_bill_Rec.org_id);
         END IF;


         l_okl_flag := 0; --- check for OKL contract

         OPEN  l_okl_contract_csr (l_bill_rec.dnz_chr_id);
         FETCH l_okl_contract_csr into l_okl_flag;
         CLOSE l_okl_contract_csr;

            If l_write_log then
           FND_FILE.PUT_LINE( FND_FILE.LOG, 'OKS_BILLING_PUB.Calculate_bill => B4 opening cursor l_bill_line_csr l_okl_flag '||l_okl_flag);
         End If;

         /*Invoices are to be generated only for contracts whose
         AR_interface_flag = 'Y'
         */
            If l_write_log then
           FND_FILE.PUT_LINE( FND_FILE.LOG, 'OKS_BILLING_PUB.Calculate_bill => l_bill_rec.ar_interface_yn '||Nvl(l_bill_rec.ar_interface_yn,'Y'));
         End If;

         IF Nvl(l_bill_rec.ar_interface_yn,'Y') = 'Y'   THEN -- {

         --Start mchoudha Bug#3537100 17-APR-04
         --For Billing Report

         /* *** Insert the lines to a PL/SQL table   ** */
          -- l_pr_tbl_idx      := l_pr_tbl_idx + 1;



         If l_write_log then
             FND_FILE.PUT_LINE( FND_FILE.LOG, 'OKS_BILLING_PUB.Calculate_bill => B4 initializing Billing Report ');
           End If;

              l_billrep_found          := FALSE;

           IF (l_billrep_tbl.count > 0) THEN
             j := l_billrep_tbl.FIRST;
             LOOP
                  IF(l_billrep_tbl(j).Currency_code = l_bill_rec.Currency_code) THEN
                       l_billrep_found := TRUE;
                 l_billrep_tbl_idx := j;         --point to the index containing the currency code
                 EXIT;
               END IF;
               EXIT WHEN j = l_billrep_tbl.LAST;
               j := l_billrep_tbl.NEXT(j);
             END LOOP;
           END IF;


           IF (l_billrep_found = FALSE) THEN
          l_billrep_tbl_idx      := l_billrep_tbl_idx + 1;
             l_billrep_tbl(l_billrep_tbl_idx).Currency_code := l_bill_rec.Currency_code;
             l_billrep_tbl(l_billrep_tbl_idx).Successful_Lines := 0;
             l_billrep_tbl(l_billrep_tbl_idx).Rejected_Lines := 0;
             l_billrep_tbl(l_billrep_tbl_idx).Successful_SubLines := 0;
             l_billrep_tbl(l_billrep_tbl_idx).Rejected_SubLines := 0;
          l_billrep_tbl(l_billrep_tbl_idx).Successful_Lines_Value := 0;
          l_billrep_tbl(l_billrep_tbl_idx).Rejected_Lines_Value := 0;
             l_billrep_tbl(l_billrep_tbl_idx).Successful_SubLines_Value := 0;
             l_billrep_tbl(l_billrep_tbl_idx).Rejected_SubLines_Value := 0;
           END IF;

           If l_write_log then
             FND_FILE.PUT_LINE( FND_FILE.LOG, 'OKS_BILLING_PUB.Calculate_bill => After initializing Billing Report ');
           End If;

           --End mchoudha Bug#3537100

           OPEN  qty_uom_csr(l_bill_rec.id);
           FETCH qty_uom_csr into qty_uom_rec;
           CLOSE qty_uom_csr;

         If l_write_log then
             FND_FILE.PUT_LINE( FND_FILE.LOG, 'OKS_BILLING_PUB.Calculate_bill => After opening qty_uom_csr uom_code '||qty_uom_rec.uom_code);
           End If;


           IF (l_bill_rec.lse_id = 46) THEN
      -----------------------------------------------------------------
           If l_write_log then
               FND_FILE.PUT_LINE( FND_FILE.LOG, 'OKS_BILLING_PUB.Calculate_bill => B4 calling Bill_Subscription_item for '||l_bill_rec.id);
             End If;

             Bill_Subscription_item(
                                 l_bill_rec.dnz_chr_id,
                                 l_bill_rec.id,
                                 l_bill_rec.start_date,
                                 l_bill_rec.date_terminated,
                                 l_bill_rec.end_date,
                                 l_bill_rec.currency_code,
                                 l_okl_flag,
                                 qty_uom_rec.number_of_items,
                                 qty_uom_rec.uom_code,
                                 p_prv,
                                 p_date,
                                 l_billrep_tbl,
                                 l_billrep_tbl_idx,
                                             l_billrep_err_tbl,
                                             l_billrep_errtbl_idx,
                                 l_ar_feeder_ctr,
                                 l_return_status);


             IF (l_return_status <> 'S') THEN
               ---DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
               RAISE MAIN_LINE_EXCEPTION;
             END IF;
      -----------------------------------------------------------------
           ELSIF (l_bill_rec.lse_id in (1,19)) Then
             --Process_service_items
      -----------------------------------------------------------------
             If l_write_log then
               FND_FILE.PUT_LINE( FND_FILE.LOG, 'OKS_BILLING_PUB.Calculate_bill => B4 calling Bill_Service_item for '||l_bill_rec.id);
             End If;

             Bill_Service_item(
                            l_bill_rec.dnz_chr_id,
                            l_bill_rec.contract_number,
                            l_bill_rec.Contract_number_modifier   ,
                            l_bill_rec.line_number,
                            l_bill_rec.lse_id   ,
                            l_bill_rec.inv_organization_id,
                            l_bill_rec.id,
                            l_bill_rec.start_date,
                            l_bill_rec.date_terminated,
                            l_bill_rec.end_date,
                            l_bill_rec.currency_code,
                            l_bill_rec.object1_id1,
                            l_bill_rec.object1_id2,
                            l_okl_flag,
                            --qty_uom_rec.number_of_items,
                            --qty_uom_rec.uom_code,
                            p_prv,
                            p_date,
                            l_bill_rec.summary_yn,
                            l_ar_feeder_ctr,
                            l_billrep_tbl,
                            l_billrep_tbl_idx,
                            l_billrep_err_tbl,
                                     l_billrep_errtbl_idx,
                            l_return_status
                            );

             IF (l_return_status <> 'S') THEN
               ----DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
               RAISE MAIN_LINE_EXCEPTION;
             END IF;
      -----------------------------------------------------------------

           ELSIF (l_bill_rec.lse_id = 12) THEN
             -- Process_usage_items
             If l_write_log then
               FND_FILE.PUT_LINE( FND_FILE.LOG, 'OKS_BILLING_PUB.Calculate_bill => B4 calling Bill_Usage_Item for '||l_bill_rec.id);
             End If;
             -------------------------------------------------------------------------
             -- Begin partial period computation logic
             -- Developer Mani Choudhary
             -- Date 12-JUN-2005
             -- added period type and period start as two parameters
             -------------------------------------------------------------------------
             Bill_Usage_Item(
                        l_bill_rec.dnz_chr_id,
                        l_bill_rec.contract_number,
                        l_bill_rec.Contract_number_modifier  ,
                        l_bill_rec.line_number,
                        l_bill_rec.lse_id   ,
                        l_bill_rec.object1_id1,
                        l_bill_rec.object1_id2,
                        l_bill_rec.id,
                        l_bill_rec.start_date,
                        l_bill_rec.date_terminated,
                        l_bill_rec.end_date,
                        l_bill_rec.inv_organization_id,
                        l_bill_rec.currency_code,
                        l_bill_rec.settlement_interval,
                        qty_uom_rec.uom_code,
                        l_uom_code,
                        l_okl_flag,
                        p_prv,
                        p_date,
                        l_billrep_tbl,
                        l_billrep_tbl_idx,
                        l_billrep_err_tbl,
                        l_billrep_errtbl_idx,
                        l_ar_feeder_ctr,
                        l_bill_rec.period_type,
                        l_bill_rec.period_start,
                        l_return_status
                        );
             IF (l_return_status <> 'S') THEN
               ----DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
               RAISE MAIN_LINE_EXCEPTION;
             END IF;

        --------------------------------------------------------
           END IF; --lse_id if stmt

         END IF; -- }  end if for Bill Yes / No


         IF (l_ar_feeder_ctr = 1 ) THEN
           If l_write_log then
             FND_FILE.PUT_LINE( FND_FILE.LOG, 'OKS_BILLING_PUB.Calculate_bill => B4 calling OKS_ARFEEDER_PUB.Get_REC_FEEDER for '||l_bill_rec.id);
           End If;

           OKS_ARFEEDER_PUB.Get_REC_FEEDER
                        (
                         X_RETURN_STATUS            => l_return_status,
                         X_MSG_COUNT                => l_msg_cnt,
                         X_MSG_DATA                 => l_msg_data,
                         P_FLAG                     => p_flag,  -- checkout
                         P_CALLED_FROM              => p_calledfrom,
                         P_DATE                     => p_date,
                         P_CLE_ID                   => l_bill_Rec.id,
                         P_PRV                      => p_prv,
                         P_BILLREP_TBL              => l_billrep_tbl,
                         P_BILLREP_TBL_IDX          => l_billrep_tbl_idx,
                      P_BILLREP_ERR_TBL          => l_billrep_err_tbl,
                      P_BILLREP_ERR_TBL_IDX      => l_billrep_errtbl_idx
                        );

           IF (l_return_status   <>  OKC_API.G_RET_STS_SUCCESS) Then
                oks_bill_rec_pub.get_message (
                  l_msg_cnt  => l_msg_count,
                     l_msg_data => l_msg_data);
             l_processed_lines_tbl(l_pr_tbl_idx).Billed_YN     := 'N' ;
             l_processed_lines_tbl(l_pr_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;

                oks_bill_Rec_pub.Set_sub_line(
                   P_PROCESSED_LINES_TBL      => l_processed_lines_tbl,
                   P_PROCESSED_SUB_LINES_TBL  => l_processed_sub_lines_tbl,
                   P_ERROR_MESSAGE => l_processed_lines_tbl(l_pr_tbl_idx).Error_Message,
                   P_TOP_LINE                 => l_bill_rec.id) ;

             FND_FILE.PUT_LINE( FND_FILE.LOG, 'OKS_BILLING_PUB.Calculate_bill => Failed in AR FEEDER :'||'  '||l_bill_rec.id);

             ---DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
             Raise Main_Line_Exception;
           END IF;


	    /*
	     Contract version updates is done for OKI.
	     OKI pulls data depending upon minor version change.
		Bug# 5637820 - This procedure is made as an autonomous transaction
	   */

		 update_version(p_dnz_chr_id => l_bill_rec.dnz_chr_id);


      END IF;  -- l_ar_Feeder = 1


      l_process_counter := l_process_counter + 1;

      EXCEPTION
         WHEN MAIN_LINE_EXCEPTION THEN
         --Added by pmallara  begin exception block to fix bug#3961046
            BEGIN
           l_reject_counter := l_reject_counter + 1;
           DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
           FND_FILE.PUT_LINE( FND_FILE.LOG, 'OKS_BILLING_PUB.Calculate_bill => MAIN LINE EXCEPTION RAISE'||'        '||sqlerrm);
                 RETCODE := 1;
            EXCEPTION
             WHEN  OTHERS THEN
           FND_FILE.PUT_LINE( FND_FILE.LOG,'OKS_BILLING_PUB.Calculate_bill => Failed- when trying to rollback inside MAIN_LINE_EXCEPTION  '||sqlerrm );
           exit;
            END;

         WHEN OTHERS THEN
         --Added by pmallara  begin exception block to fix bug#3961046
            BEGIN
           l_processed_lines_tbl(l_pr_tbl_idx).Billed_YN     := 'N' ;
           l_processed_lines_tbl(l_pr_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||' Main Loop - When others ' ;

           /*FOR ERROR REPORT*/
            l_billrep_errtbl_idx := l_billrep_errtbl_idx + 1;
            l_billrep_err_tbl(l_billrep_errtbl_idx).Top_Line_id := l_bill_rec.id;
            l_billrep_err_tbl(l_billrep_errtbl_idx).Lse_Id :=l_bill_rec.lse_id ;
            l_billrep_err_tbl(l_billrep_errtbl_idx).Sub_line_id := NULL;
            l_billrep_err_tbl(l_billrep_errtbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;

            l_reject_counter := l_reject_counter + 1;
            DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
            FND_FILE.PUT_LINE( FND_FILE.LOG,'OKS_BILLING_PUB.Calculate_bill => Failed- when others  exception raised in Mainline loop '||sqlerrm );
                  RETCODE := 1;

	    --Bug#5378184
	     l_err_code := substr(sqlerrm,instr(sqlerrm,'-')+1,5);
	     if (l_err_code = '01555') then
		raise;
	     end if;
	    --End Bug#5378184

         EXCEPTION
              WHEN OTHERS THEN
           FND_FILE.PUT_LINE( FND_FILE.LOG,'OKS_BILLING_PUB.Calculate_bill => Failed- when trying to rollback inside WHEN OTHERS exception'||sqlerrm );
              exit;
         END;
       END;
     END LOOP;            --end of loop for cle_id tbl

     --Added to clear pl/sql tables after processing records
     cle_id.delete;
     chr_id.delete;
     l_line_no.delete;
   END IF;              ----end of count for cle_id tbl

     EXIT WHEN billing_process%NOTFOUND ;
 END LOOP;   --MAIN LOOP END for billing_process cursor

   /*  *** Create the output file for Billing program.  ***  */

   If l_write_report then
      OKS_BILL_UTIL_PUB.CREATE_REPORT
         ( p_billrep_table      => l_billrep_tbl
          ,p_billrep_err_tbl    => l_billrep_err_tbl
          ,p_line_from          => P_process_from
          ,p_line_to            => P_process_to
          ,x_return_status      => l_return_status);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_BILLING_PUB.Calculate_bill => *** Failed to create Billing Report ***' );
      END IF;
   End If;

   If l_write_log then
     FND_FILE.PUT_LINE( FND_FILE.LOG, 'OKS_BILLING_PUB.Calculate_bill processing Ends ');
   End If;

   ---- Added if clause to issue warning for any data related issue
   IF (RETCODE <> 1) THEN
        RETCODE := 0;
   End if;

 EXCEPTION

   WHEN  G_EXCEPTION_HALT_VALIDATION THEN
     x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
     RETCODE := 2;
     FND_FILE.PUT_LINE( FND_FILE.LOG, 'OKS_BILLING_PUB.Calculate_bill => when g_exception_rollback  raised'||sqlerrm);
     DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
   WHEN G_EXCEPTION_ROLLBACK THEN
     FND_FILE.PUT_LINE( FND_FILE.LOG, 'OKS_BILLING_PUB.Calculate_bill => when g_exception_rollback  raised'||sqlerrm);
     DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');

   WHEN  OTHERS THEN
     x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
     RETCODE := 2;
     FND_FILE.PUT_LINE( FND_FILE.LOG, 'OKS_BILLING_PUB.Calculate_bill => when others raised'||sqlerrm);
     OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,
                         G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
     DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');

 END Calculate_bill;

/*----------------------------------------------------------------------
Concurrent Program Wrapper for Regular Service and Usage Billing Program
------------------------------------------------------------------------*/


PROCEDURE  Billing_Main
(
ERRBUF            OUT      NOCOPY VARCHAR2,
RETCODE           OUT      NOCOPY NUMBER,
P_CONTRACT_HDR_ID IN              NUMBER,
-- nechatur 29-Nov-2005 bug#4459229 changing type of P_DEFAULT_TYPE to VARCHAR2
--P_DEFAULT_DATE    IN              DATE,
P_DEFAULT_DATE    IN             VARCHAR2,
--end bug#4459229
P_ORG_ID          IN              NUMBER,
P_CUSTOMER_ID     IN              NUMBER,
P_CATEGORY        IN              VARCHAR2,
P_GRP_ID          IN              NUMBER,
P_PROCESS         IN              VARCHAR2   --No for Normal processing,Yes for Preview Processing
)
IS


CONC_STATUS             BOOLEAN;
l_ret                   INTEGER;
l_subrequests           INTEGER;
l_errbuf                VARCHAR2(240);
l_msg_data              VARCHAR2(2000);
l_return_status         VARCHAR2(1);
v_truncstring           VARCHAR2(500);
l_view_by_org           VARCHAR2(10);
l_dummy                 VARCHAR2(1);
l_statement             VARCHAR2(30000);
p_date                  DATE;
l_line_no               NUMBER;
l_max_boundary          NUMBER;
l_min_boundary          NUMBER;
l_slot_size             NUMBER;
l_retcode               NUMBER;
l_msg_count             NUMBER;
p_prv                   NUMBER;
l_org_id                NUMBER;
l_flag                  NUMBER  := 0;
v_cursor                NUMBER;

l_billrep_tbl           OKS_BILL_REC_PUB.bill_report_tbl_type;
l_billrep_tbl_idx       NUMBER;
l_billrep_err_tbl       OKS_BILL_REC_PUB.billrep_error_tbl_type;
l_billrep_errtbl_idx    NUMBER;
/*added for bug7668259*/
l_hook                  NUMBER;
l_date_interface_start  DATE;
l_hint                  VARCHAR2(50);

BEGIN

  FND_FILE.PUT_LINE( FND_FILE.LOG,'OKS_BILLING_PUB.Billing_Main  Starts');

   l_yes_no :=  Fnd_profile.value('OKS_BILLING_REPORT_AND_LOG');

  FND_FILE.PUT_LINE( FND_FILE.LOG,'OKS_BILLING_PUB.Billing_Main => OKS: Billing Report And Log is set to '||l_yes_no);

   If l_yes_no = 'YES' then
      l_write_log       := TRUE;
      l_write_report    := TRUE;
   Else
      l_write_log       := FALSE;
      l_write_report    := FALSE;
   End If;

  l_org_id := p_org_id;

  --mchoudha fixed bug#4729936
  --IF (nvl(fnd_profile.value('OKC_VIEW_K_BY_ORG'),'N') = 'Y' ) THEN
  --  l_org_id := fnd_profile.value('ORG_ID');
  If l_write_log then
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'OKS_BILLING_PUB.Billing_Main => parameter Org ID is '||l_org_id);
  End If;
 -- END IF;

  If l_write_log then
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'OKS_BILLING_PUB.Billing_Main => Preview Y/N ='||P_process);
  End If;

  /* Set p_prv flag, which is used to in calls to AR Feeder.
     p_prv = 2  -- preview billing
  */
  IF (P_PROCESS = 'Y') then
   P_PRV := 2;
  ELSE
   P_PRV := 1;
  END IF;

  user_id    := FND_GLOBAL.USER_ID;
  If l_write_log then
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'OKS_BILLING_PUB.Billing_Main => User_Id ='||to_char(user_id));
  End If;

--nechatur 29-Nov-2005 for bug#4459229
--p_date := nvl(trunc(p_default_date),trunc(sysdate));
----p_date := nvl(trunc(TO_DATE(p_default_date, 'yyyy/mm/dd hh24:mi:ss')),trunc(sysdate));
-- end bug#4459229

----Hari bug# 5704211
    p_date := nvl(fnd_date.canonical_to_date(p_default_date), trunc(sysdate));

  --Added this If condition so that the table does not get
  --truncated during the restart of the parent
  If(FND_CONC_GLOBAL.request_data is null) THEN

    If l_write_log then
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'OKS_BILLING_PUB.Billing_Main => Truncating oks_process_billing');
    End If;

    v_cursor := DBMS_SQL.OPEN_CURSOR;
    /*Following line is required to avoid GSCC errors at ARU creation.
      Concatination of string is required to avoid run time error.
      Ampersand 1 is taking value from un_oks param in dbdrv command line.*/
    --v_truncstring := 'Truncate Table oks';
    --v_truncstring := v_truncstring||'.oks_process_billing';
    v_truncstring := 'Truncate Table OKS'||'.oks_process_billing';
    DBMS_SQL.PARSE(v_cursor,v_truncstring,DBMS_SQL.V7);
    DBMS_SQL.CLOSE_CURSOR(v_cursor);
  END IF;


  /* This call to AR Feeder is done to process any termination records.
     It is kept in the begining of the code with purpose. In case of parallel
     run of billing program , this api may not get executed if placed at the
     end of api. This is because there is return statement in parallel worker
     code. This is fix for  bug # 2963174
  */
  IF (FND_CONC_GLOBAL.request_data is null) THEN -- not a restart of parent

  If l_write_log then
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'OKS_BILLING_PUB.Billing_Main => Call to OKS_ARFEEDER_PUB.Get_REC_FEEDER to interface termination records');
  End If;

    OKS_ARFEEDER_PUB.Get_REC_FEEDER
     (
       x_return_status             => l_return_status,
       x_msg_count                 => l_msg_count,
       x_msg_data                  => l_msg_data,
       p_flag                      => l_flag,
       p_called_from               => 1,
       p_date                      => p_date,
       p_cle_id                    => NULL,
       p_prv                       => 3,   --to interface termination records and any stray records
       p_billrep_tbl               => l_billrep_tbl,
       p_billrep_tbl_idx           => l_billrep_tbl_idx,
       p_billrep_err_tbl          => l_billrep_err_tbl,
       p_billrep_err_tbl_idx      => l_billrep_errtbl_idx
     ) ;

  If l_write_log then
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'OKS_BILLING_PUB.Billing_Main => After Call to OKS_ARFEEDER_PUB.Get_REC_FEEDER to interface termination records l_return_status '||l_return_status);
  End If;


  -- We need to see if we should spawn sub-requests;
  -- i.e., the number of contract lines that qualify is > MAX_SINGLE_REQUEST.

    DBMS_TRANSACTION.SAVEPOINT('BEFORE_MAIN_BILLING');


    l_line_no   := 0;
    /*Code hook to get interface start_date for bug7668259*/
   oks_code_hook.billing_interface_st_date(l_hook,l_date_interface_start,l_hint);

    IF (p_grp_id is not null) or (p_customer_id is not null) or
       (p_category is not null) or (l_org_id is not null)    or
       (p_contract_hdr_id is not null)  Then
      If l_write_log then
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Parameters Passed => Contract Id '||p_contract_hdr_id);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Customer '||P_customer_id|| ' Category '||p_category);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Org '||l_org_id|| ' Group '||p_grp_id);
      End If;

    End If;


    IF (p_grp_id is null) and (p_customer_id is null) and
       (p_category is null) and (l_org_id is null)    and
       (p_contract_hdr_id is null)  Then

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Blind Query ' || ': with date '||p_date);

        /*code hook is used as part of bug7668259*/
   IF l_hook = 1 AND l_date_interface_start IS NOT NULL THEN

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Using Serial plan as l_hook value is 1 with
       date_interface_start as: '|| l_date_interface_start );

	  INSERT /*+ append */ into oks_process_billing (chr_id,cle_id,line_no,currency_code)
           SELECT /*+ leading(lvl,line,as1,hdr,sts)
 	            use_nl(line,hdr) use_hash(as1,sts) swap_join_inputs(as1)
 	            swap_join_inputs(sts) */
             hdr.id hdr_id, line.id line_id, rownum, hdr.currency_code
                from   (
                          Select distinct lvl.parent_cle_id
                          from oks_level_elements lvl
 	                   where lvl.date_completed is null
 	                   and   (lvl.date_to_interface > trunc(l_date_interface_start) -1 and lvl.date_to_interface <  trunc(p_date)+1)
 	                   )  lvl,
 	                   okc_k_lines_b   line,
 	                   (
 	                   Select  distinct scs_code,sts_code
 	                   from okc_assents a
 	                   where a.opn_code = 'INVOICE'
 	                   and a.allowed_yn = 'Y'
 	                   ) as1,
 	                   okc_k_headers_b hdr,
 	                   (
 	                   Select  distinct code
 	                   from okc_statuses_b osb
 	                   where osb.ste_code <> 'HOLD'
 	                   ) sts
 	            WHERE Hdr.id = line.dnz_chr_id
 	            AND   Hdr.scs_code in ('SERVICE','WARRANTY','SUBSCRIPTION')
 	            AND   Hdr.Template_yn = 'N'
 	            AND   line.id = lvl.parent_cle_id
 	            AND   line.lse_id     in (1,12,19,46)
 	            AND   line.sts_code = as1.sts_code
 	            AND   as1.scs_code =  Hdr.scs_code
 	            AND   sts.code =   Hdr.sts_code
 	            AND   line.id not in ( Select   rel.cle_id
 	                                    From okc_k_rel_objs rel
 	                                    Where rel.cle_id is not null
 	                                 );
 	         /*added for bug7668259*/
 	         ELSIF l_hint = 'FULL' THEN /*full parallel processing of data*/

 	           FND_FILE.PUT_LINE(FND_FILE.LOG, 'Using FULL Parallel plan as l_hint value is FULL');

 	           INSERT /*+ append */ into oks_process_billing
 	        (chr_id,cle_id,line_no,currency_code)
 	         SELECT /*+ leading(lvl,line,as1,hdr,sts)
 	            use_nl(line,hdr) use_hash(as1,sts) swap_join_inputs(as1)
 	           swap_join_inputs(sts)
 	            parallel(line) parallel(hdr)
 	         */
 	           hdr.id hdr_id, line.id line_id, rownum, hdr.currency_code
 	            from   (
 	                   Select  /*+ parallel(lvl) no_merge */ distinct
 	          lvl.parent_cle_id
                  from oks_level_elements lvl
                  where lvl.date_completed is null
                  and   trunc(lvl.date_to_interface) <=  trunc(p_date)
                  )  lvl,
                  okc_k_lines_b   line,
                  (
                  Select distinct scs_code,sts_code
                  from okc_assents a
                  where a.opn_code = 'INVOICE'
                  and a.allowed_yn = 'Y'
                  ) as1,
                  okc_k_headers_b hdr,
                  (
                  Select distinct code
                  from okc_statuses_b osb
                  where osb.ste_code <> 'HOLD'
                  ) sts
           WHERE Hdr.id = line.dnz_chr_id
           AND   Hdr.scs_code in ('SERVICE','WARRANTY','SUBSCRIPTION')
           AND   Hdr.Template_yn = 'N'
           AND   line.id = lvl.parent_cle_id
           AND   line.lse_id     in (1,12,19,46)
           AND   line.sts_code = as1.sts_code
           AND   as1.scs_code =  Hdr.scs_code
           AND   sts.code =   Hdr.sts_code
           AND   line.id not in ( Select  rel.cle_id
                                   From okc_k_rel_objs rel
                                   Where rel.cle_id is not null
                                );
         /*modified for bug7668259*/
 	         ELSE    /*Semi parallel processing of data */

 	         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Using Semi Parallel plan as l_hook value is 0');

 	         INSERT /*+ append */ into oks_process_billing(chr_id,cle_id,line_no,currency_code)
 	         SELECT /*+ leading(lvl,line,as1,hdr,sts) use_nl(line,hdr) use_hash(as1,sts) swap_join_inputs(as1) swap_join_inputs(sts) */
 	           hdr.id hdr_id, line.id line_id, rownum, hdr.currency_code
 	            from   (Select  /*+ parallel(lvl) no_merge */ distinct lvl.parent_cle_id
 	                   from oks_level_elements lvl
 	                   where lvl.date_completed is null
 	                   and   trunc(lvl.date_to_interface) <=  trunc(p_date)
 	                   )  lvl,
 	                   okc_k_lines_b   line,
 	                   (
 	                   Select  distinct scs_code,sts_code
 	                   from okc_assents a
 	                   where a.opn_code = 'INVOICE'
 	                   and a.allowed_yn = 'Y'
 	                   ) as1,
 	                   okc_k_headers_b hdr,
 	                   (
 	                   Select  distinct code
 	                   from okc_statuses_b osb
 	                   where osb.ste_code <> 'HOLD'
 	                   ) sts
 	            WHERE Hdr.id = line.dnz_chr_id
 	            AND   Hdr.scs_code in ('SERVICE','WARRANTY','SUBSCRIPTION')
 	            AND   Hdr.Template_yn = 'N'
 	            AND   line.id = lvl.parent_cle_id
 	            AND   line.lse_id     in (1,12,19,46)
 	            AND   line.sts_code = as1.sts_code
 	            AND   as1.scs_code =  Hdr.scs_code
 	            AND   sts.code =   Hdr.sts_code
 	            AND   line.id not in ( Select   rel.cle_id
 	                                    From okc_k_rel_objs rel
 	                                    Where rel.cle_id is not null
 	                                 );
 	         END IF;
    Elsif
       (p_grp_id is null) and (p_customer_id is null) and
       (p_category is null) and (l_org_id is not null)  and
       (p_contract_hdr_id is null)  Then

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Query for Org id');

          /*modified for bug7668259*/
 	         IF l_hook = 1 AND l_date_interface_start IS NOT NULL THEN

 	           FND_FILE.PUT_LINE(FND_FILE.LOG, 'Using Serial plan as l_hook value is 1 with date_interface_start as: '||l_date_interface_start);

 	           INSERT into oks_process_billing (chr_id,cle_id,line_no,currency_code)
 	            SELECT hdr.id hdr_id, line.id line_id, rownum, hdr.currency_code
 	            from   (
 	                   Select distinct lvl.parent_cle_id
 	                   from oks_level_elements lvl
 	                   where lvl.date_completed is null
 	                   and   (lvl.date_to_interface > TRUNC(l_date_interface_start) -1 and lvl.date_to_interface < trunc(p_date)+1)
 	                   )  lvl,
 	                   okc_k_lines_b   line,
 	                   (
 	                   Select  distinct scs_code,sts_code
 	                   from okc_assents a
 	                   where a.opn_code = 'INVOICE'
 	                   and a.allowed_yn = 'Y'
 	                   ) as1,
 	                   okc_k_headers_b hdr,
 	                   (
 	                   Select  distinct code
 	                   from okc_statuses_b osb
 	                   where osb.ste_code <> 'HOLD'
 	                   ) sts
 	            WHERE Hdr.id = line.dnz_chr_id
 	            AND   Hdr.scs_code in ('SERVICE','WARRANTY','SUBSCRIPTION')
 	            AND   Hdr.Authoring_Org_Id = l_org_id
 	            AND   Hdr.Template_yn = 'N'
 	            AND   line.id = lvl.parent_cle_id
 	            AND   line.lse_id     in (1,12,19,46)
 	            AND   line.sts_code = as1.sts_code
 	            AND   as1.scs_code =  Hdr.scs_code
 	            AND   sts.code =   Hdr.sts_code
 	            AND   line.id not in ( Select  rel.cle_id
 	                                    From okc_k_rel_objs rel
 	                                    Where rel.cle_id is not null
 	                                 );
 	         /*modified for bug7668259*/
 	         ELSE   /*l_hook = 0, so parallel processing of data*/

 	         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Using Parallel plan as l_hook value is 0');

	  INSERT  into oks_process_billing (chr_id,cle_id,line_no,currency_code)
           SELECT hdr.id hdr_id, line.id line_id, rownum, hdr.currency_code
           from   (
                  Select  /*+ parallel(lvl)*/ distinct lvl.parent_cle_id
                  from oks_level_elements lvl
                  where lvl.date_completed is null
                  and   trunc(lvl.date_to_interface) <=  trunc(p_date)
                  )  lvl,
                  okc_k_lines_b   line,
                  (
                  Select  distinct scs_code,sts_code
                  from okc_assents a
                  where a.opn_code = 'INVOICE'
                  and a.allowed_yn = 'Y'
                  ) as1,
                  okc_k_headers_b hdr,
                  (
                  Select distinct code
                  from okc_statuses_b osb
                  where osb.ste_code <> 'HOLD'
                  ) sts
           WHERE Hdr.id = line.dnz_chr_id
           AND   Hdr.scs_code in ('SERVICE','WARRANTY','SUBSCRIPTION')
           AND   Hdr.Authoring_Org_Id = l_org_id
           AND   Hdr.Template_yn = 'N'
           AND   line.id = lvl.parent_cle_id
           AND   line.lse_id     in (1,12,19,46)
           AND   line.sts_code = as1.sts_code
           AND   as1.scs_code =  Hdr.scs_code
           AND   sts.code =   Hdr.sts_code
           AND   line.id not in ( Select rel.cle_id
                                   From okc_k_rel_objs rel
                                   Where rel.cle_id is not null
                                );
     END IF;
    Elsif
       (p_contract_hdr_id is not null)  Then

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Query for Contract id');

	  INSERT into oks_process_billing (chr_id,cle_id,line_no,currency_code)

        SELECT  hdr.id hdr_id,line.id line_id,rownum,hdr.currency_code
		 from   okc_k_headers_b hdr, okc_k_lines_b   line
        WHERE Hdr.id = line.dnz_chr_id
        AND   Hdr.scs_code in ('SERVICE','WARRANTY','SUBSCRIPTION')
        AND   Hdr.Template_yn = 'N'
        AND   Hdr.id = p_contract_hdr_id
        AND   line.id IN (Select  lvl.parent_cle_id
				          from oks_level_elements lvl
                              where lvl.date_completed is null
                              and   trunc(lvl.date_to_interface) <=  trunc(p_date) )
        AND exists (Select  1 from okc_statuses_b osb
                                  where osb.ste_code <> 'HOLD'
                                  and   osb.code =   Hdr.sts_code )
        AND exists ( SELECT 1 from okc_assents a
                                   where line.sts_code = a.sts_code
                                   and a.scs_code =  Hdr.scs_code
                                   and a.opn_code = 'INVOICE'
                                   and a.allowed_yn = 'Y' )
        AND    line.lse_id     in (1,12,19,46)
		 AND    line.id not in ( Select  rel.cle_id
		                         From okc_k_rel_objs rel
                                   Where rel.cle_id is not null );

    Elsif
       (p_grp_id is not null) and (p_customer_id is null) and
       (p_category is null) and (l_org_id is not null)  and
       (p_contract_hdr_id is null)  Then

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Query for contract group and org id');
         /*modified for bug7668259*/
 	         IF l_hook = 1 AND l_date_interface_start IS NOT NULL THEN

 	           FND_FILE.PUT_LINE(FND_FILE.LOG, 'Using Serial plan as l_hook value is 1 with date_interface_start as: '||l_date_interface_start);

 	         INSERT /*+ append */ into oks_process_billing (chr_id,cle_id,line_no,currency_code)
 	            SELECT  /*+ leading(lvl) ORDERED USE_HASH(line hdr sts as1 cgp)
 	                        swap_join_inputs(hdr) swap_join_inputs(sts) swap_join_inputs(cgp) */
 	                       hdr.id hdr_id, line.id line_id, rownum, hdr.currency_code
 	            from   (
 	                   Select  distinct lvl.parent_cle_id
 	                   from oks_level_elements lvl
 	                   where lvl.date_completed is null
 	                   and   (lvl.date_to_interface > TRUNC(l_date_interface_start) -1 AND lvl.date_to_interface <  trunc(p_date) +1)
 	                   )  lvl,
 	                   okc_k_lines_b   line,
 	                   (
 	                   Select  /*+ FULL (a) no_merge */ distinct scs_code,sts_code
 	                   from okc_assents a
 	                   where a.opn_code = 'INVOICE'
 	                   and a.allowed_yn = 'Y'
 	                   ) as1,
 	                   okc_k_headers_b hdr,
 	                   (
 	                   Select  /*+ FULL (osb) no_merge */ distinct code
 	                   from okc_statuses_b osb
 	                   where osb.ste_code <> 'HOLD'
 	                   ) sts,
 	                   (
 	                   Select  /*+ FULL (grp) no_merge */ distinct included_chr_id
 	                   from OKC_K_GRPINGS grp
 	                            where grp.cgp_parent_id = p_grp_id
 	                         ) cgp
 	            WHERE Hdr.id = line.dnz_chr_id
 	            AND   Hdr.scs_code in ('SERVICE','WARRANTY','SUBSCRIPTION')
 	            AND   Hdr.Template_yn = 'N'
 	            AND   Hdr.Authoring_Org_Id = l_org_id
 	            AND   line.id = lvl.parent_cle_id
 	            AND   line.lse_id     in (1,12,19,46)
 	            AND   line.sts_code = as1.sts_code
 	            AND   as1.scs_code =  Hdr.scs_code
 	            AND   sts.code =   Hdr.sts_code
 	                  AND   cgp.included_chr_id = Hdr.id
 	            AND   line.id not in ( Select  /*+ index_ffs (rel) HASH_AJ  */ rel.cle_id
 	                                    From okc_k_rel_objs rel
 	                                    Where rel.cle_id is not null
 	                                 );
 	         /*modified for bug7668259*/
 	         ELSE /*l_hook = 0, so normal processing of data*/

 	         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Using Normal Plan as l_hook value is 0');
	  INSERT /*+ append */ into oks_process_billing (chr_id,cle_id,line_no,currency_code)
           SELECT  /*+ leading(lvl) ORDERED USE_HASH(line hdr sts as1 cgp)
                       swap_join_inputs(hdr) swap_join_inputs(sts) swap_join_inputs(cgp) */
                      hdr.id hdr_id, line.id line_id, rownum, hdr.currency_code
           from   (
                  Select  /*+ FULL (lvl) no_merge */ distinct lvl.parent_cle_id
                  from oks_level_elements lvl
                  where lvl.date_completed is null
                  and   (lvl.date_to_interface) <  trunc(p_date)+1
                  )  lvl,
                  okc_k_lines_b   line,
                  (
                  Select  /*+ FULL (a) no_merge */ distinct scs_code,sts_code
                  from okc_assents a
                  where a.opn_code = 'INVOICE'
                  and a.allowed_yn = 'Y'
                  ) as1,
                  okc_k_headers_b hdr,
                  (
                  Select  /*+ FULL (osb) no_merge */ distinct code
                  from okc_statuses_b osb
                  where osb.ste_code <> 'HOLD'
                  ) sts,
                  (
                  Select  /*+ FULL (grp) no_merge */ distinct included_chr_id
                  from OKC_K_GRPINGS grp
			   where grp.cgp_parent_id = p_grp_id
		        ) cgp
           WHERE Hdr.id = line.dnz_chr_id
           AND   Hdr.scs_code in ('SERVICE','WARRANTY','SUBSCRIPTION')
           AND   Hdr.Template_yn = 'N'
           AND   Hdr.Authoring_Org_Id = l_org_id
           AND   line.id = lvl.parent_cle_id
           AND   line.lse_id     in (1,12,19,46)
           AND   line.sts_code = as1.sts_code
           AND   as1.scs_code =  Hdr.scs_code
           AND   sts.code =   Hdr.sts_code
		 AND   cgp.included_chr_id = Hdr.id
           AND   line.id not in ( Select  /*+ index_ffs (rel) HASH_AJ  */ rel.cle_id
                                   From okc_k_rel_objs rel
                                   Where rel.cle_id is not null
                                );
        END IF;
    ELSIF
 	        (p_grp_id is null) and (p_customer_id is null) and
 	        (p_category is not null) and (l_org_id is not null)  and
 	        (p_contract_hdr_id is null)  Then

                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Query for category and org id');
                 /*modified for bug7668259*/
 	         IF l_hook = 1 AND l_date_interface_start IS NOT NULL THEN

 	           FND_FILE.PUT_LINE(FND_FILE.LOG, 'Using Serial plan as l_hook value is 1 with date_interface_start as: '||l_date_interface_start);

                  INSERT into oks_process_billing (chr_id,cle_id,line_no,currency_code)
 	            SELECT  hdr.id hdr_id,line.id line_id,rownum,hdr.currency_code
 	            from   okc_k_headers_b hdr, okc_k_lines_b   line
 	            WHERE Hdr.id = line.dnz_chr_id
 	            AND   Hdr.scs_code in ('SERVICE','WARRANTY','SUBSCRIPTION')
 	            AND   Hdr.Template_yn = 'N'
 	            AND   Hdr.Authoring_Org_Id = l_org_id
 	            AND   Hdr.Scs_code = p_category
 	            AND   line.id IN (Select lvl.parent_cle_id
 	                               from oks_level_elements lvl
 	                               where lvl.date_completed is null
 	                                and   (lvl.date_to_interface > TRUNC(l_date_interface_start) -1 AND
                                        lvl.date_to_interface <  trunc(p_date) +1))
 	            AND exists (Select  1 from okc_statuses_b osb
 	                                   where osb.ste_code <> 'HOLD'
 	                                   and   osb.code =   Hdr.sts_code )
 	            AND exists ( SELECT 1 from okc_assents a
 	                                    where line.sts_code = a.sts_code
 	                                    and a.scs_code =  Hdr.scs_code
 	                                    and a.opn_code = 'INVOICE'
 	                                    and a.allowed_yn = 'Y' )
 	            AND    line.lse_id     in (1,12,19,46)
 	             AND    line.id not in ( Select  rel.cle_id
 	                                     From okc_k_rel_objs rel
 	                                    Where rel.cle_id is not null );

                /*modified for bug7668259*/
 	         ELSE /*l_hook = 0, so normal processing of data*/

 	         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Using Normal plan as l_hook value is 0');

 	           INSERT into oks_process_billing (chr_id,cle_id,line_no,currency_code)
 	            SELECT  hdr.id hdr_id,line.id line_id,rownum,hdr.currency_code
 	                  from   okc_k_headers_b hdr, okc_k_lines_b   line
 	            WHERE Hdr.id = line.dnz_chr_id
 	            AND   Hdr.scs_code in ('SERVICE','WARRANTY','SUBSCRIPTION')
 	            AND   Hdr.Template_yn = 'N'
 	            AND   Hdr.Authoring_Org_Id = l_org_id
 	            AND   Hdr.Scs_code = p_category
 	            AND   line.id IN (Select lvl.parent_cle_id
 	                                           from oks_level_elements lvl
 	                               where lvl.date_completed is null
 	                               and   lvl.date_to_interface <  trunc(p_date) +1)
 	            AND exists (Select  1 from okc_statuses_b osb
 	                                   where osb.ste_code <> 'HOLD'
 	                                   and   osb.code =   Hdr.sts_code )
 	            AND exists ( SELECT 1 from okc_assents a
 	                                    where line.sts_code = a.sts_code
 	                                    and a.scs_code =  Hdr.scs_code
 	                                    and a.opn_code = 'INVOICE'
 	                                    and a.allowed_yn = 'Y' )
 	            AND    line.lse_id     in (1,12,19,46)
 	                  AND    line.id not in ( Select  rel.cle_id
 	                                          From okc_k_rel_objs rel
 	                                    Where rel.cle_id is not null );
 	         END IF;
    Else

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Query for rest of the parameters');

	  INSERT into oks_process_billing (chr_id,cle_id,line_no,currency_code)

           SELECT  hdr.id hdr_id,line.id line_id,rownum,hdr.currency_code
		 from   okc_k_headers_b hdr, okc_k_lines_b   line
           WHERE Hdr.id = line.dnz_chr_id
           AND   Hdr.scs_code in ('SERVICE','WARRANTY','SUBSCRIPTION')
           AND   Hdr.Template_yn = 'N'
           AND   Hdr.Authoring_Org_Id = nvl(l_org_id, hdr.authoring_org_id)
           AND   Hdr.Scs_code = nvl(p_category, hdr.scs_code)
		 AND  exists
		       (select 1 from OKC_K_PARTY_ROLES_B okp
			   where okp.dnz_chr_id  =  hdr.id
			   and   okp.rle_code    in ('CUSTOMER','SUBSCRIBER')
			   and   okp.object1_id1 = nvl(P_customer_id, okp.object1_id1) )
		 AND  exists
		       (select 1 from OKC_K_GRPINGS okg
			   where okg.included_chr_id  =  hdr.id
			   and   okg.cgp_parent_id = nvl(p_grp_id, okg.cgp_parent_id) )
           AND   line.id IN (Select  lvl.parent_cle_id
				          from oks_level_elements lvl
                              where lvl.date_completed is null
                              and   trunc(lvl.date_to_interface) <=  trunc(p_date) )
           AND exists (Select  1 from okc_statuses_b osb
                                  where osb.ste_code <> 'HOLD'
                                  and   osb.code =   Hdr.sts_code )
           AND exists ( SELECT 1 from okc_assents a
                                   where line.sts_code = a.sts_code
                                   and a.scs_code =  Hdr.scs_code
                                   and a.opn_code = 'INVOICE'
                                   and a.allowed_yn = 'Y' )
           AND    line.lse_id     in (1,12,19,46)
		 AND    line.id not in ( Select  rel.cle_id
		                         From okc_k_rel_objs rel
                                   Where rel.cle_id is not null );

    End if;   --   End if clause for null parameters check

    ---this commit is required for the oks_process_billing table. should not be commented:
    commit;
    select count(*) into l_line_no from oks_process_billing;

  If l_write_log then
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'OKS_BILLING_PUB.Billing_Main => Number of records in oks_process_billing is '||l_line_no);
  End If;


  END IF;


  IF (p_contract_hdr_id is null) AND -- not a specific contract
     (FND_CONC_GLOBAL.request_data is null) AND -- not a restart of parent
     (nvl(FND_PROFILE.VALUE('OKS_PARALLEL_WORKER'),'NO') = 'YES') THEN

    -- l_line_no represent total records to be processed here
    If l_write_log then
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'OKS_BILLING_PUB.Billing_Main => Profile option  OKS: Parallel Worker is set to YES');
    End If;

    IF (l_line_no > MAX_SINGLE_REQUEST )  THEN
      -- populate lo,hi varrays

      l_subrequests := 30;   --  hard coded.
      l_slot_size :=  ceil(l_line_no / l_subrequests);

      --SELECT ceil(count(*)/10) into l_slot_size  from oks_process_billing;
      l_min_boundary  := 1;
      l_max_boundary  := l_slot_size;
      FOR idx in 1..l_subrequests
      LOOP
        l_ret := FND_REQUEST.submit_request
                      ('OKS','OKS_BILLING_SUB',
                                 to_char(idx), -- UI job display
                                 null, TRUE, -- TRUE means isSubRequest
                                 1, l_flag, p_date,
                                 l_min_boundary, l_max_boundary,
                        p_prv);





        IF (l_ret = 0) THEN
          errbuf := fnd_message.get;
       retcode := 2;
          FND_FILE.PUT_LINE (FND_FILE.LOG,'Sub-request failed to submit: '
                                                                     || errbuf);
          return;
        ELSE
          FND_FILE.PUT_LINE (FND_FILE.LOG,'Sub-request '||to_char(l_ret)||
                             ' submitted for line numbers '||l_min_boundary||' to '||l_max_boundary);
        END IF;

        IF (l_max_boundary >= l_line_no) THEN
          EXIT;
        END IF;

        l_min_boundary  := l_max_boundary + 1;
        l_max_boundary  := l_max_boundary + l_slot_size;
      END LOOP;
        -- after submitting sub-requests, set the parent status to PAUSED
        -- and set the request_data to a non-null value to detect restart
      FND_CONC_GLOBAL.set_req_globals
                       (conc_status => 'PAUSED',
                                 request_data => to_char(l_subrequests));
      errbuf := to_char(l_subrequests) || ' sub-requests submitted';
      retcode := 0;
      return; -- parent exits and waits for children to finish before restart
    END IF; -- l_agg_rec.total

  ELSIF ((FND_CONC_GLOBAL.request_data is not null ) AND
        (nvl(FND_PROFILE.VALUE('OKS_PARALLEL_WORKER'),'NO') = 'YES')) THEN
    -- restart detected (sub-requests finished)...cleanup and exit.
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'OKS_BILLING_PUB.Billing_Main => Commiting here');
    COMMIT;

    v_cursor := DBMS_SQL.OPEN_CURSOR;
    /* Following line is required to avoid GSCC errors at ARU creation.
       Concatination of string is required to avoid run time error         */
    -- v_truncstring := 'Truncate Table oks';
    -- v_truncstring := v_truncstring||'.oks_process_billing';
    v_truncstring := 'Truncate Table OKS'||'.oks_process_billing';
    DBMS_SQL.PARSE(v_cursor,v_truncstring,DBMS_SQL.V7);
    DBMS_SQL.CLOSE_CURSOR(v_cursor);


    retcode := 0;
    return;
  END IF; -- parent test

  If l_write_log then
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'OKS_BILLING_PUB.Billing_Main => B4 Calling OKS_BILLING_PUB.CALCULATE_BILL for sequential run');
  End If;

  OKS_BILLING_PUB.CALCULATE_BILL
            (l_errbuf, l_retcode, 1, l_flag,
             p_date,1 ,l_line_no,
             p_prv);

  If l_write_log then
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'OKS_BILLING_PUB.Billing_Main => After Calling OKS_BILLING_PUB.CALCULATE_BILL for sequential run');
  End If;

  IF (l_retcode = 0)  THEN
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'Billing Main is successfully completed');
    conc_ret_code := SUCCESS;
    RETCODE := 0;
  ELSIF (l_retcode = 1)  THEN
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'Billing Main is successfully completed with warnings');
    conc_ret_code := WARNING;
    RETCODE := 1;
  ELSE
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'Billing Main completed with errors');
     conc_ret_code := ERROR;
     RETCODE := 2;
     DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_MAIN_BILLING');
  END IF;


  COMMIT;

   v_cursor := DBMS_SQL.OPEN_CURSOR;
  /* Following line is required to avoid GSCC errors at ARU creation.
     Concatination of string is required to avoid run time error     */
  --v_truncstring := 'Truncate Table oks';
  --v_truncstring := v_truncstring||'.oks_process_billing';
  v_truncstring := 'Truncate Table OKS'||'.oks_process_billing';
  DBMS_SQL.PARSE(v_cursor,v_truncstring,DBMS_SQL.V7);
  DBMS_SQL.CLOSE_CURSOR(v_cursor);

  FND_FILE.PUT_LINE( FND_FILE.LOG,'OKS_BILLING_PUB.Billing_Main  Ends');

EXCEPTION
  WHEN UTL_FILE.INVALID_PATH THEN
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'FILE LOCATION OR NAME WAS INVALID');
  WHEN UTL_FILE.INVALID_MODE THEN
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'FILE OPEN MODE STRING WAS INVALID');
  WHEN UTL_FILE.INVALID_FILEHANDLE THEN
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'FILE HANDLE WAS INVALID');
  WHEN UTL_FILE.INVALID_OPERATION THEN
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'FILE IS NOT OPEN FOR WRITTING');
  WHEN UTL_FILE.WRITE_ERROR THEN
    FND_FILE.PUT_LINE (FND_FILE.LOG,'OS ERROR OCCURRED DURING WRITE OPERATION');

END Billing_Main;


PROCEDURE  Process_Suppress_Credits
 (
 ERRBUF            OUT NOCOPY VARCHAR2,
 RETCODE           OUT NOCOPY NUMBER,
 P_CONTRACT_HDR_ID IN         NUMBER,
 P_ORG_ID          IN         NUMBER,
 P_CATEGORY        IN         VARCHAR2
 )
 IS


 l_bclv_tbl_in                        OKS_bcl_PVT.bclv_tbl_type;
 l_bclv_tbl_out                       OKS_bcl_PVT.bclv_tbl_type;
 l_return_status                      VARCHAR2(10);
 l_msg_cnt                            NUMBER;
 l_msg_data                           VARCHAR2(2000);

 l_org_id                             NUMBER;
 l_retcode               NUMBER;

--Bug # 4928184	19-JAN-2006	maanand
/* Commenting code as this is giving perf. issue for condition
	 AND   hdr.id = nvl(p_contract_hdr_id,hdr.id)
   Hence, breaking this cursor into two cursors depeding on condition
   process_cur into process_cur_hdr_id and process_cur
*/

/*
CURSOR process_cur(p_contract_hdr_id IN NUMBER,
                   p_category        IN VARCHAR2,
                   p_org_id          IN NUMBER)   is
  SELECT bcl.cle_id       bcl_cle_id,
         bsl.cle_id       bsl_cle_id,
         abs(bsl.amount)  bsl_amount,
         line.lse_id      bcl_lse_id
  FROM okc_k_headers_b      hdr,
       oks_bill_sub_lines   bsl,
       oks_bill_cont_lines  bcl,
       okc_k_lines_b        line
   WHERE line.id = bcl.cle_id
   AND   hdr.id = line.dnz_chr_id
   AND   hdr.id = nvl(p_contract_hdr_id,hdr.id) --Full Table Scan due to nvl condition
   AND   hdr.scs_code = nvl(p_category,hdr.scs_code)
   --AND   hdr.authoring_org_id = nvl(p_org_id,hdr.authoring_org_id)
   AND   hdr.org_id = nvl(p_org_id,hdr.org_id)
   AND   bcl.cle_id = line.id
   AND   bsl.bcl_id = bcl.id
   AND   bcl.bill_action = 'TR'
   AND   bcl.btn_id      = -44;
*/

--Cursor to consider when p_contract_hdr_id is not null

CURSOR process_cur_hdr_id (p_contract_hdr_id IN NUMBER,
                           p_category        IN VARCHAR2,
                           p_org_id          IN NUMBER)   is

  SELECT bcl.cle_id       bcl_cle_id,
         bsl.cle_id       bsl_cle_id,
         abs(bsl.amount)  bsl_amount,
         line.lse_id      bcl_lse_id
  FROM okc_k_headers_b      hdr,
       oks_bill_sub_lines   bsl,
       oks_bill_cont_lines  bcl,
       okc_k_lines_b        line
   WHERE line.id = bcl.cle_id
   AND   hdr.id = line.dnz_chr_id
   AND   hdr.id = p_contract_hdr_id
   AND   hdr.scs_code = nvl(p_category,hdr.scs_code)
   AND   hdr.org_id = nvl(p_org_id,hdr.org_id)
   AND   bcl.cle_id = line.id
   AND   bsl.bcl_id = bcl.id
   AND   bcl.bill_action = 'TR'
   AND   bcl.btn_id      = -44;


--Cursor to consider when p_contract_hdr_id is NULL

CURSOR process_cur  (p_category        IN VARCHAR2,
                     p_org_id          IN NUMBER)   is

  SELECT bcl.cle_id       bcl_cle_id,
         bsl.cle_id       bsl_cle_id,
         abs(bsl.amount)  bsl_amount,
         line.lse_id      bcl_lse_id
  FROM okc_k_headers_b      hdr,
       oks_bill_sub_lines   bsl,
       oks_bill_cont_lines  bcl,
       okc_k_lines_b        line
   WHERE line.id = bcl.cle_id
   AND   hdr.id = line.dnz_chr_id
   AND   hdr.scs_code = nvl(p_category,hdr.scs_code)
   AND   hdr.org_id = nvl(p_org_id,hdr.org_id)
   AND   bcl.cle_id = line.id
   AND   bsl.bcl_id = bcl.id
   AND   bcl.bill_action = 'TR'
   AND   bcl.btn_id      = -44;



l_billrep_tbl           OKS_BILL_REC_PUB.bill_report_tbl_type;
l_billrep_tbl_idx       NUMBER;
l_billrep_err_tbl       OKS_BILL_REC_PUB.billrep_error_tbl_type;
l_billrep_errtbl_idx    NUMBER;


BEGIN

    l_retcode := 0;

    ----DBMS_TRANSACTION.SAVEPOINT('BEFORE_TRANSACTION');

    l_org_id := p_org_id;

    --mchoudha fixed bug#4729936
    --IF (nvl(fnd_profile.value('OKC_VIEW_K_BY_ORG'),'N') = 'Y' ) THEN
    --  l_org_id := fnd_profile.value('ORG_ID');
    --END IF;

--Bug # 4928184	19-JAN-2006	maanand

IF (p_contract_hdr_id is not null) THEN

    FOR cur in process_cur_hdr_id(p_contract_hdr_id ,
                                  p_category        ,
                                  l_org_id          )
    LOOP

      /*Update subline info*/
      IF (cur.bcl_lse_id <> 46) THEN
        UPDATE oks_k_lines_b
        SET credit_amount = nvl(credit_amount,0) +  nvl(cur.bsl_amount,0) ,
          suppressed_credit = nvl(suppressed_credit,0) - nvl(cur.bsl_amount,0)
        WHERE cle_id = cur.bsl_cle_id;
      END IF;

      /*Update topline info*/
      UPDATE oks_k_lines_b
      SET credit_amount = nvl(credit_amount,0) + nvl(cur.bsl_amount,0) ,
          suppressed_credit = nvl(suppressed_credit,0) - nvl(cur.bsl_amount,0)
      WHERE cle_id = cur.bcl_cle_id;

    END LOOP;

    /*
	BTN_ID is updated to null for Each record which qualifies the user inputs.
	Order management orginated line can have btn_id = -44.
	To avoid process these records bill_action = 'TR' condition is added
	in below where clause
    */

    UPDATE oks_bill_cont_lines bcl
    SET    bcl.btn_id = NULL
    WHERE  bcl.btn_id = -44
    AND    bcl.bill_Action = 'TR'
    AND    EXISTS
        (SELECT 1 from okc_k_headers_b hdr,
                    okc_k_lines_b   line
         WHERE line.id = bcl.cle_id
		 AND   hdr.id = line.dnz_chr_id
         AND   hdr.id = p_contract_hdr_id
         AND   hdr.scs_code = nvl(p_category,hdr.scs_code)
         AND   hdr.org_id = nvl(l_org_id,hdr.org_id));


 ELSE --p_contract_hdr_id is NULL

	 FOR cur in process_cur(p_category ,
                                l_org_id          )
     LOOP

      /*Update subline info*/
      IF (cur.bcl_lse_id <> 46) THEN
        UPDATE oks_k_lines_b
        SET credit_amount = nvl(credit_amount,0) +  nvl(cur.bsl_amount,0) ,
          suppressed_credit = nvl(suppressed_credit,0) - nvl(cur.bsl_amount,0)
        WHERE cle_id = cur.bsl_cle_id;
      END IF;

      /*Update topline info*/
      UPDATE oks_k_lines_b
      SET credit_amount = nvl(credit_amount,0) + nvl(cur.bsl_amount,0) ,
          suppressed_credit = nvl(suppressed_credit,0) - nvl(cur.bsl_amount,0)
      WHERE cle_id = cur.bcl_cle_id;

    END LOOP;

    /*
	BTN_ID is updated to null for Each record which qualifies the user inputs.
	Order management orginated line can have btn_id = -44.
	To avoid process these records bill_action = 'TR' condition is added
	in below where clause
    */

	UPDATE oks_bill_cont_lines bcl
    SET    bcl.btn_id = NULL
    WHERE  bcl.btn_id = -44
    AND    bcl.bill_Action = 'TR'
    AND    EXISTS
        (SELECT 1 from okc_k_headers_b hdr,
                    okc_k_lines_b   line
         WHERE line.id = bcl.cle_id
		 AND   hdr.id = line.dnz_chr_id
         AND   hdr.scs_code = nvl(p_category,hdr.scs_code)
         AND   hdr.org_id = nvl(l_org_id,hdr.org_id));

END IF; --p_contract_hdr_id is not null


	--Bug # 4928184	19-JAN-2006	maanand
	--Commented this code
    /*
    --BTN_ID is updated to null for Each record which qualifies the user inputs.
    --Order management orginated line can have btn_id = -44.
    --To avoid process these records bill_action = 'TR' condition is added
    --in below where clause


    UPDATE oks_bill_cont_lines bcl
    SET    bcl.btn_id = NULL
    WHERE  bcl.btn_id = -44
    AND    bcl.bill_Action = 'TR'
    AND    EXISTS
        (SELECT 1 from okc_k_headers_b hdr,
                    okc_k_lines_b   line
         WHERE line.id = bcl.cle_id
      AND   hdr.id = line.dnz_chr_id
         AND   hdr.id = nvl(p_contract_hdr_id,hdr.id)
         AND   hdr.scs_code = nvl(p_category,hdr.scs_code)
         --AND   hdr.authoring_org_id = nvl(l_org_id,hdr.authoring_org_id));
         AND   hdr.org_id = nvl(l_org_id,hdr.org_id));



      --Once Btn_id is update as null. Calling AR Feeder to process termination
      --records. These records are now processed as normal termination records
      --in AR Feeder. Calling AR Feeder with P_Prv =3 to process remaing
      --termination records
   */

--END Bug # 4928184	19-JAN-2006	maanand

    OKS_ARFEEDER_PUB.Get_REC_FEEDER
       (
            x_return_status             => l_return_status,
            x_msg_count                 => l_msg_cnt,
            x_msg_data                  => l_msg_data,
            p_flag                      => 2,
            p_called_from               => 1,
            p_date                      => trunc(sysdate),
            p_cle_id                    => NULL,
            p_prv                       => 3, -- to interface termination records
         p_billrep_tbl               => l_billrep_tbl,
         p_billrep_tbl_idx           => l_billrep_tbl_idx,
         p_billrep_err_tbl           => l_billrep_err_tbl,
         p_billrep_err_tbl_idx       => l_billrep_errtbl_idx
       ) ;

    IF (l_return_status <> 'S') THEN
      OKS_BILL_REC_PUB.GET_MESSAGE(
             l_msg_cnt  => l_msg_cnt,
             l_msg_data => l_msg_data);
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Error: Failed in AR FEEDER');
      ---DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_TRANSACTION');
      l_retcode := 1;
    END IF;

  IF (l_retcode = 0)  THEN
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'Supress credit is successfully completed');
    conc_ret_code := SUCCESS;
    RETCODE := 0;
  END IF;

  COMMIT;

EXCEPTION
 WHEN OTHERS THEN
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'Supress credit completed with Errors');
    conc_ret_code := ERROR;
    RETCODE := 2;
    OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,
                        G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
End  Process_Suppress_Credits;

End OKS_BILLING_PUB;

/
