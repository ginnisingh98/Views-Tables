--------------------------------------------------------
--  DDL for Package Body OKS_BILL_SCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_BILL_SCH" AS
/*  $Header: OKSBLSHB.pls 120.45.12010000.2 2009/07/02 08:26:11 vgujarat ship $ */


l_strm_lvl_tbl_in         oks_sll_pvt.sllv_tbl_type;
l_strm_lvl_tbl_out        oks_sll_pvt.sllv_tbl_type;
l_lvl_ele_tbl_in          oks_bill_level_elements_pvt.letv_tbl_type;
l_lvl_ele_tbl_out         oks_bill_level_elements_pvt.letv_tbl_type;
l_fnd_lvl_in_rec          oks_bill_util_pub.bill_det_inp_rec;
l_fnd_lvl_out_rec         oks_bill_util_pub.bill_sch_rec;
l_api_version             number := 1.0;

--Bug Fix 5185658
pkg_cascade_billing_hdr   varchar2(1) := 'N';


TYPE Top_Line_BS_Type  IS RECORD
(
  id            NUMBER,
  Start_dt      NUMBER,
  End_dt        DATE,
  tot_Amount    NUMBER);


Type Top_Line_BS_tbl is TABLE of Top_Line_BS_type index by binary_integer;

TYPE Contract_Rec_Type IS RECORD
(
     ID                   NUMBER,
     Start_dt             DATE,
     End_dt               DATE);


TYPE StrmLvl_Out_Type Is Record
(
     Id                         Number,
     cle_id                     NUMBER,
     chr_id                     number,
     dnz_chr_id                 number,
     Seq_no                     NUMBER,
     Dt_start                   DATE,
     end_date                   DATE,
     Level_Period               NUMBER,
     uom_Per_Period             NUMBER,
     uom                        Varchar2 (3),
     Amount                     NUMBER,
     invoice_offset_days         NUMBER,
     Interface_offset_days      NUMBER

);

Type StrmLvl_Out_tbl is TABLE of StrmLvl_Out_Type index by binary_integer;

Type sll_prorated_rec_type IS RECORD
( sll_seq_num           Number,
  sll_start_date        DATE,
  sll_end_date          DATE,
  sll_tuom              VARCHAR2(40),
  sll_period            Number,
  sll_uom_per_period    Number,
  sll_amount            Number
);

Type sll_prorated_tab_type is Table of sll_prorated_rec_type index by binary_integer;


TYPE Line_Det_Type IS RECORD
(   chr_id               Number,
    dnz_chr_id           Number,
    id                   Number,
    cle_id               NUMBER,
    lse_id               Number,
    price_uom            VARCHAR2(10),
    line_start_dt        Date,
    line_end_dt          Date,
    line_amt             Number
);
------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 17-MAY-2005
 -- Added cp_price_uom and cp_lse_id
 -------------------------------------------------------------------------

TYPE Prod_Det_Type IS RECORD
(   cp_id             Number,
    cp_start_dt       Date,
    cp_end_dt         Date,
    cp_lse_id         Number,
    cp_price_uom      VARCHAR2(10),
    cp_amt            Number,
    dnz_chr_id        number
);

 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 31-MAY-2005
 -- Added two new parameters P_period_start,P_period_type
 -------------------------------------------------------------------------

PROCEDURE Calculate_sll_amount( p_api_version       IN      NUMBER,
                                p_total_amount      IN      NUMBER,
                                p_currency_code     IN      VARCHAR2,
                                p_period_start      IN      VARCHAR2,
                                p_period_type       IN      VARCHAR2,
                                p_sll_prorated_tab  IN  OUT NOCOPY sll_prorated_tab_type,
                                x_return_status     OUT     NOCOPY VARCHAR2
);


Procedure Create_Stream_Level
(     p_billing_type              IN    VARCHAR2
,     p_strm_lvl_tbl              IN    StreamLvl_tbl
,     p_dnz_chr_id                IN    NUMBER
,     p_subline_call              IN    VARCHAR2
,     p_line_amt                  IN    NUMBER
,     p_subline_amt               IN    NUMBER
,     p_sll_start_dt              IN    DATE
,     p_end_dt                    IN    DATE
,     p_period_start              IN    VARCHAR2
,     p_period_type               IN    VARCHAR2
,     x_sll_out_tbl               OUT   NOCOPY StrmLvl_Out_tbl
,     x_return_status             OUT   NOCOPY Varchar2
);

 -------------------------------------------------------------------------
 -- End partial period computation logic
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------

FUNCTION chk_Sll_Exists(p_id IN NUMBER) return number ;



PROCEDURE Check_Existing_Lvlelement
(
              p_sll_id          IN  Number,
              p_sll_dt_start    IN  Date,
              p_uom            IN  VARCHAR2,
              p_uom_per_period IN  NUMBER,
              p_cp_end_dt       IN  DATE,
              x_next_cycle_dt   OUT NOCOPY DATE,
              x_last_cycle_dt   out NOCOPY Date,
              x_period_counter  out NOCOPY Number,
              x_sch_amt         IN OUT NOCOPY NUMBER,
              x_top_line_bs     IN OUT NOCOPY oks_bill_level_elements_pvt.letv_tbl_type,
              x_return_status   out NOCOPY Varchar2
);


FUNCTION Cal_Hdr_Amount
(
              p_contract_id  IN Number
)             Return NUMBER;

FUNCTION Find_Adjusted_Amount
(
       p_line_id    IN Number,
       p_total_amt  IN Number,
       p_cycle_amt  IN Number
) RETURN Number;

 --------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- Added two new parameters P_period_start,P_period_type in procedural call
 ---------------------------------------------------------------------------
PROCEDURE Create_Level_elements
(         p_billing_type     IN    VARCHAR2,
          p_sll_tbl          IN    StrmLvl_Out_tbl,
          p_line_rec         IN    Line_Det_Type,
          p_invoice_ruleid   IN    Number,
          p_term_dt          IN    DATE,
          p_period_start      IN   VARCHAR2,
          p_period_type       IN   VARCHAR2,
          x_return_status    OUT   NOCOPY Varchar2
);

FUNCTION get_unit_price_per_uom(
P_cle_id IN NUMBER,
P_billing_uom IN VARCHAR2,
P_period_start IN VARCHAR2,
P_period_type IN VARCHAR2,
P_duration    IN NUMBER,
p_end_date   IN DATE,
p_term_date  IN DATE
)RETURN NUMBER;


 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------
PROCEDURE Create_cp_lvl_elements
(           p_billing_type      IN    VARCHAR2,
            p_cp_sll_tbl        IN   StrmLvl_Out_tbl,
            p_Line_Rec          IN   Line_Det_Type,
            p_SubLine_rec       IN   Prod_Det_Type,
            p_invoice_rulid     IN   Number,
            p_top_line_bs       IN   OUT NOCOPY oks_bill_level_elements_pvt.letv_tbl_type,
            p_term_dt           IN   DATE,
            p_period_start      IN   VARCHAR2,
            p_period_type       IN   VARCHAR2,
            x_return_status     OUT  NOCOPY Varchar2
);

 --------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- Added two new parameters P_period_start,P_period_type in procedural call
 ---------------------------------------------------------------------------
PROCEDURE Bill_Sch_Cp
(           p_billing_type      IN    VARCHAR2,
            p_bsll_tbl          IN   StreamLvl_tbl,
            p_Line_Rec          IN   Line_Det_Type,
            p_SubLine_rec       IN   Prod_Det_Type,
            p_invoice_rulid     IN   Number,
            p_top_line_bs       IN OUT NOCOPY oks_bill_level_elements_pvt.letv_tbl_type,
            p_term_dt           IN   DATE,
            p_period_start      IN   VARCHAR2,
            p_period_type       IN   VARCHAR2,
            x_return_status     OUT  NOCOPY Varchar2
);

FUNCTION Find_Currency_Code
(        p_cle_id  NUMBER,
         p_chr_id  NUMBER
) RETURN VARCHAR2;


FUNCTION Find_Sll_Count(
                       p_subline_id   NUMBER)
RETURN NUMBER;

 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- Added two new parameters p_period_start and p_period_type
 -------------------------------------------------------------------------
PROCEDURE Create_Hdr_Level_elements(p_billing_type IN    VARCHAR2,
                                p_sll_tbl          IN    StrmLvl_Out_tbl,
                                p_hdr_rec          IN    Contract_Rec_Type,
                                p_invoice_ruleid   IN    Number,
                                p_called_from      IN    NUMBER,            --(1 - form, 2- copy,renew)
                                p_period_start     IN   VARCHAR2,
                                p_period_type      IN   VARCHAR2,
                                x_return_status    OUT   NOCOPY Varchar2);


PROCEDURE Delete_lvl_element(p_cle_id          IN  NUMBER,
                             x_return_status   OUT NOCOPY VARCHAR2);


PROCEDURE Del_hdr_lvl_element(p_hdr_id         IN  NUMBER,
                             x_return_status  OUT NOCOPY VARCHAR2);

PROCEDURE Get_Constant_sll_Amount(p_line_start_date       IN DATE,
                                 p_line_end_date         IN DATE,
                                 p_cycle_start_date      IN DATE,
                                 p_remaining_amount      IN NUMBER,
                                 P_uom_quantity          IN NUMBER,
                                 P_tce_code              IN VARCHAR2,
                                 x_constant_sll_amt      OUT NOCOPY NUMBER,
                                 x_return_status         OUT NOCOPY VARCHAR2);


PROCEDURE Get_Period_Frequency(p_line_start_date      IN  DATE,
                              p_line_end_date         IN  DATE,
                              p_cycle_start_date      IN  DATE,
                              p_next_billing_date     IN  DATE,
                              P_uom_quantity          IN  NUMBER,
                              P_tce_code              IN  VARCHAR2,
                              p_uom_per_period       IN  NUMBER,
                              x_period_freq           OUT NOCOPY NUMBER,
                              x_return_status         OUT NOCOPY VARCHAR2);



PROCEDURE Adjust_top_BS_Amt(
                        p_Line_Rec          IN     Line_Det_Type,
                        p_SubLine_rec       IN     Prod_Det_Type,
                        p_top_line_bs       IN OUT NOCOPY oks_bill_level_elements_pvt.letv_tbl_type,
                        x_return_status     OUT    NOCOPY VARCHAR2);

PROCEDURE Del_sll_lvlelement(p_top_line_id          IN  NUMBER,
                             x_return_status        OUT NOCOPY VARCHAR2,
                             x_msg_count            OUT NOCOPY  NUMBER,
                             x_msg_data             OUT NOCOPY VARCHAR2);


Procedure Adjust_interface_date(p_line_id           IN  NUMBER,
                                p_invoice_rule_id   IN  Number,
                                p_line_end_date     IN  DATE,
                                p_lse_id            IN  NUMBER,
                                x_bs_tbl            OUT NOCOPY oks_bill_level_elements_pvt.letv_tbl_type,
                                x_return_status     OUT NOCOPY VARCHAR2,
                                x_msg_count         OUT NOCOPY NUMBER,
                                x_msg_data          OUT NOCOPY VARCHAR2);


 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------
PROCEDURE  Create_Subcription_LvlEle
         (p_billing_type     IN    VARCHAR2,
          p_sll_tbl          IN    StrmLvl_Out_tbl,
          p_line_rec         IN    Line_Det_Type,
          p_term_dt          IN    DATE,
          p_invoice_ruleid   IN    Number,
          p_period_start     IN    VARCHAR2,
          p_period_type      IN    VARCHAR2,
          x_return_status    OUT  NOCOPY Varchar2);
 -------------------------------------------------------------------------
 -- End partial period computation logic
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------

FUNCTION Find_term_amt(p_cycle_st_dt  IN  DATE,
              p_term_dt      IN  DATE,
              p_cycle_end_dt IN  DATE,
              p_amount       IN  NUMBER) RETURN NUMBER;

PROCEDURE Get_SLL_info(p_top_line_id      IN  NUMBER,
                       p_line_id          IN  NUMBER,
                       x_sll_tbl          OUT NOCOPY StrmLvl_Out_tbl,
                       x_sll_db_tbl       OUT NOCOPY OKS_BILL_SCH.StreamLvl_tbl,
                       x_return_status    OUT NOCOPY VARCHAR2);

PROCEDURE Del_line_sll_lvl(p_line_id          IN  NUMBER,
                           x_return_status    OUT NOCOPY VARCHAR2,
                           x_msg_count        OUT NOCOPY NUMBER,
                           x_msg_data         OUT NOCOPY VARCHAR2);



Procedure Populate_end_date(p_line_id             IN NUMBER,
                            p_end_date            IN DATE,
                            p_term_date           IN DATE,
                            p_lse_id              IN NUMBER,
                            x_return_status       OUT NOCOPY VARCHAR2);

PROCEDURE Rollup_lvl_amt(
                   p_Line_Rec          IN     Line_Det_Type,
                   p_SubLine_rec       IN     Prod_Det_Type,
                   p_top_line_bs       IN OUT NOCOPY oks_bill_level_elements_pvt.letv_tbl_type,
                   x_return_status     OUT    NOCOPY VARCHAR2);

PROCEDURE Adjust_cp_trx_inv_dt(
                        p_top_bs_tbl        IN     oks_bill_level_elements_pvt.letv_tbl_type,
                        p_SubLine_id        IN     NUMBER,
                        x_cp_line_bs        OUT NOCOPY oks_bill_level_elements_pvt.letv_tbl_type,
                        x_return_status     OUT    NOCOPY VARCHAR2);

PROCEDURE Adjust_billed_lvl_element(p_new_cp_id     IN NUMBER,
                                    P_old_cp_bs_tbl IN OUT NOCOPY oks_bill_level_elements_pvt.letv_tbl_type,
                                    x_new_cp_bs_tbl OUT NOCOPY oks_bill_level_elements_pvt.letv_tbl_type,
                                    x_return_status OUT NOCOPY VARCHAR2);

Procedure Prorate_sll_amt(
                  p_old_cp_amt     IN NUMBER,
                  p_new_cp_amt     IN NUMBER,
                  p_total_amt      IN NUMBER,
                  p_new_sll_tbl    IN OUT NOCOPY oks_bill_sch.StreamLvl_tbl,
                  p_old_sll_tbl    IN OUT NOCOPY oks_bill_sch.StreamLvl_tbl,
                  x_return_status  OUT NOCOPY  VARCHAR2);


l_currency_code    Varchar2(15);
l_header_billing   NUMBER;
---------------end of local package declaration---------------

 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- This Function will calculate the converted unit price from price_uom
 -- to Billing_uom for covered product and covered item. For covered levels
 -- other than covered product and covered item, it will calculate the unit
 -- price per Billing uom using Time Measure APIs.
 -------------------------------------------------------------------------
FUNCTION Get_Unit_Price_Per_Uom (
                                  P_cle_id       IN NUMBER,
                                  P_billing_uom  IN VARCHAR2,
                                  P_period_start IN VARCHAR2,
                                  P_period_type  IN VARCHAR2,
                                  P_duration     IN NUMBER,
                                  p_end_date     IN DATE,
                                  p_term_date    IN DATE
)
RETURN NUMBER
AS
--Declare variables or cursors
Cursor line_dtl_csr(p_cle_id in NUMBER) IS
SELECT lin.start_date,
       Lin.end_date,
       Lin.price_negotiated,
       lin.price_unit*itm.number_of_items unit_price,
       Lin.lse_id,
       --lin.price_unit*itm.number_of_items*kln.toplvl_price_qty total_amount,  --bug#5359695 commented
       nvl(Lin.price_negotiated,0) total_amount,   --bug#5359695
       kln.price_uom,
       kln.toplvl_uom_code,
       nvl(kln.ubt_amount,0)  ubt_amount --bug#5359695
FROM   okc_k_lines_b lin,
       Oks_k_lines_b kln,
       Okc_k_items itm
WHERE  kln.cle_id = lin.id and
       itm.cle_id = lin.id and
       lin.id = p_cle_id;

--Total already billed amount in case of partially billed case
Cursor total_billed_csr (p_cle_id   IN NUMBER) IS
SELECT nvl(sum(bsl.amount),0) amount,
       max(bsl.date_billed_From) date_billed_From,
       max(bsl.date_billed_to) date_billed_to
FROM  oks_bill_sub_lines bsl
WHERE bsl.cle_id = p_cle_id;


Cursor check_sub_instance IS
SELECT 'Y'
FROM   okc_k_items itm,
       oks_subscr_header_b sub
WHERE  itm.cle_id = P_cle_id
AND    sub.instance_id = itm.object1_id1;

CURSOR om_period_csr IS
select oel.service_period
from   okc_k_rel_objs rel,
       oe_order_lines_all oel
where  rel.cle_id = P_cle_id
and    oel.line_id  = rel.object1_id1;


l_sub_instance_check                    VARCHAR2(1);
l_duration NUMBER;
l_uom VARCHAR2(30);
l_start_date DATE;
l_unit_price NUMBER;
l_quantity NUMBER;
l_target_quantity NUMBER;
l_source_quantity NUMBER;
l_conversion_factor NUMBER;
x_return_status VARCHAR2(1);
l_price_negotiated NUMBER;
lin_det_rec line_dtl_csr%rowtype;
total_billed_rec total_billed_csr%rowtype;
l_amount  NUMBER;
l_source_unit_price NUMBER;

BEGIN
--Fetch the line details.
  Open line_dtl_csr(p_cle_id);
  Fetch line_dtl_csr into lin_det_rec;
  Close line_dtl_csr;

  --Fix for bug#5623498 unit price will be recalculated based on
  --duration based uom if pricelist is not present
  okc_time_util_pub.get_duration(lin_det_rec.start_date,p_end_date,l_duration,l_uom,x_return_status);
  --errorout_ad(' l_uom '||l_uom);
  --errorout_ad(' l_duration '||l_duration);
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Get_Unit_Price_Per_Uom.product_pricing.price_uom_is_null',
    'after calling okc_time_util_pub.get_duration  '
    ||' result l_duration = ' || l_duration||',l_uom = '||l_uom);
  END IF;


  l_source_unit_price := lin_det_rec.unit_price;

-- get total billed amount
  Open total_billed_csr(p_cle_id);
  Fetch total_billed_csr into total_billed_rec;
  Close total_billed_csr;

  --changed for bug#5359695
  l_price_negotiated := lin_det_rec.total_amount;




  IF p_term_date IS NOT NULL THEN
     IF  lin_det_rec.total_amount <= total_billed_rec.amount THEN
       l_price_negotiated := total_billed_rec.amount + lin_det_rec.ubt_amount;
     ELSE
       l_price_negotiated := lin_det_rec.total_amount + lin_det_rec.ubt_amount;
     END IF;
  END IF;

  --end changes for bug#5359695

   -- recalculate the unit price
  IF lin_det_rec.lse_id in (7,9,25) THEN
        l_duration := OKS_TIME_MEASURES_PUB.get_quantity (
                                                        p_start_date   => lin_det_rec.start_date,
                                                        p_end_date     => lin_det_rec.end_date,
                                                        p_source_uom   => nvl(lin_det_rec.toplvl_uom_code,l_uom),
                                                        p_period_type  => p_period_type,
                                                        p_period_start => p_period_start
                                                        );
        l_source_unit_price := l_price_negotiated/l_duration;
  END IF;

   l_sub_instance_check := NULL;
   --subscription instance can only be attached as service product/Exntended warranty product
   IF lin_det_rec.lse_id in (9,25) THEN
    Open check_sub_instance;
    Fetch check_sub_instance into l_sub_instance_check;
    Close check_sub_instance;
   END IF;

  --For the following lse_ids, QP is invoked for pricing.
  --lse_id 7 is item
  --lse_id 9 is product
  --lse_id 25 is product for extended warranty
  IF lin_det_rec.lse_id in (7,9,25) AND (nvl(l_sub_instance_check,'X') <> 'Y') THEN

   --errorout_ad(' max date '||to_char(total_billed_rec.date_billed_to));
    --mchoudha fix for bug#5158185
    --added the condition p_term_date is null so that the following logic doesn't get called
    --in case of termination
    IF (total_billed_rec.date_billed_to is not null)
       AND p_term_date is null THEN
      IF (total_billed_rec.date_billed_to < p_end_date)
      THEN --  partially Billed cases
        l_amount := lin_det_rec.price_negotiated - total_billed_rec.amount;
        l_duration := OKS_TIME_MEASURES_PUB.get_quantity (
                                                        p_start_date   => total_billed_rec.date_billed_to+1,
                                                        p_end_date     => p_end_date,
                                                        p_source_uom   => P_billing_uom,--nvl(lin_det_rec.price_uom,l_uom), --target uom
                                                        p_period_type  => p_period_type,
                                                        p_period_start => p_period_start
                                                        );
       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Get_Unit_Price_Per_Uom.product_pricing.partially_billed_cases',
         'after calling OKS_TIME_MEASURES_PUB.get_quantity with parameters p_period_type '||p_period_type||' p_period_start '||p_period_start
        ||' result l_duration = ' || l_duration);
       END IF;

        IF nvl(l_duration,0) = 0 THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
        l_unit_price := l_amount/l_duration; -- recalculaing unit price
        l_start_date := total_billed_rec.date_billed_to+1;
       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Get_Unit_Price_Per_Uom.product_pricing.partially_billed_cases',
         ' recalculated unit price  l_unit_price = ' || l_unit_price);
       END IF;

      ELSE      -- billed to => l end date, 100% billed cases
        RETURN(0);
      END IF;
    ELSE        --billed to is null = never billed cases
      IF nvl(lin_det_rec.toplvl_uom_code,l_uom) <> P_billing_uom THEN
        l_unit_price := OKS_BILL_SCH.Get_Converted_price(
                                            p_price_uom        =>P_billing_uom,
                                            p_pl_uom           =>nvl(lin_det_rec.toplvl_uom_code,l_uom),
                                            p_period_start     =>p_period_start,
                                            p_period_type      =>p_period_type,
                                            p_price_negotiated =>l_price_negotiated,
                                            p_unit_price       =>l_source_unit_price,
                                            p_start_date       =>lin_det_rec.start_date,
                                            p_end_date         =>lin_det_rec.end_date
                                            );
        IF l_unit_price is NULL THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      ELSE
        l_unit_price := l_source_unit_price;
      END IF;
      l_start_date := lin_det_rec.start_date;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Get_Unit_Price_Per_Uom.product_pricing.unbilled_case',
         ' l_unit_price = ' || l_unit_price);
      END IF;

    END IF;
--


        Return nvl(l_unit_price*p_duration,0);


  ELSE -- Manual pricing for other covered levels for subline and for negotiated price Usage)
    IF(total_billed_rec.date_billed_to is not null)
    THEN        -- partial billed cases
      IF (total_billed_rec.date_billed_to < p_end_date)
      THEN
        l_amount := lin_det_rec.price_negotiated - total_billed_rec.amount;
        l_duration :=OKS_TIME_MEASURES_PUB.get_quantity(
                               p_start_date   => total_billed_rec.date_billed_to+1,
                               p_end_date     => p_end_date,
                               p_source_uom   => p_billing_uom,
                               p_period_type  => p_period_type,
                               p_period_start => p_period_start
                               );
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Get_Unit_Price_Per_Uom.manual_pricing.partially_billed_cases',
          'after calling OKS_TIME_MEASURES_PUB.get_quantity with parameters p_period_type '||p_period_type||' p_period_start '||p_period_start
          ||' result l_duration = ' || l_duration);
        END IF;
        IF nvl(l_duration,0) = 0 THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
        --changed from l_quantity to l_duration
        l_unit_price := l_amount/l_duration;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Get_Unit_Price_Per_Uom.manual_pricing.partailly_billed_cases',
           ' returned unit price =  ' || l_unit_price);
        END IF;
        Return nvl(l_unit_price*p_duration,0);
      ELSE      -- billed to >= l end date, 100% billed cases
        RETURN(0);
      END IF;

    ELSE -- unbilled cases
      l_amount := lin_det_rec.price_negotiated;
      l_start_date := lin_det_rec.start_date;

      l_quantity := OKS_TIME_MEASURES_PUB.get_quantity
                       (p_start_date   => l_start_date,
                        p_end_date     => p_end_date,
                        p_source_uom   => p_billing_uom,
                        p_period_type  => p_period_type,
                        p_period_start => p_period_start);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Get_Unit_Price_Per_Uom.manual_pricing.unbilled_cases',
          'after calling OKS_TIME_MEASURES_PUB.get_quantity with parameters p_period_type '||p_period_type||' p_period_start '||p_period_start
          ||' result l_quantity = ' || l_quantity);
      END IF;

      IF nvl(l_quantity,0) = 0 THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
        --errorout_ad(' l_quantity '||l_quantity);
        --errorout_ad(' l_amount '||l_amount);
      l_unit_price := l_amount/l_quantity;
         --errorout_ad(' l_unit_price '||l_unit_price);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Get_Unit_Price_Per_Uom.manual_pricing.unbilled_cases',
         ' returned unit price =  ' || l_unit_price);
      END IF;

        Return nvl(l_unit_price*p_duration,0);
   END IF;
END IF;

EXCEPTION
WHEN G_EXCEPTION_HALT_VALIDATION THEN
       RETURN NULL;
WHEN OTHERS THEN
        --set the error message and return with NULL to notify the
        --caller of error
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

       RETURN NULL;

END get_unit_price_per_uom;

 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 18-SEP-2005
 -- This Function will calculate the converted  price from price_list_uom
 -- to price_uom for covered product and covered item.
 -------------------------------------------------------------------------
FUNCTION Get_Converted_price (
                              p_price_uom        IN VARCHAR2,
                              p_pl_uom           IN VARCHAR2,
                              p_period_start     IN VARCHAR2,
                              p_period_type      IN VARCHAR2,
                              p_price_negotiated IN NUMBER,
                              p_unit_price       IN NUMBER,
                              p_start_date       IN DATE,
                              p_end_date         IN DATE

)
RETURN NUMBER
AS
--Declare variables or cursors
l_quantity          NUMBER;
l_return_status     VARCHAR2(1);
l_source_uom_quantity      NUMBER;
l_source_tce_code          VARCHAR2(30);
l_target_uom_quantity      NUMBER;
l_target_tce_code          VARCHAR2(30);
l_target_qty               NUMBER;

BEGIN
   OKS_BILL_UTIL_PUB.Get_Seeded_Timeunit
                    (p_timeunit      => p_price_uom,
                     x_return_status => l_return_status,
                     x_quantity      => l_target_uom_quantity ,
                     x_timeunit      => l_target_tce_code);

    IF l_return_status <> 'S' THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

   OKS_BILL_UTIL_PUB.Get_Seeded_Timeunit
                    (p_timeunit      => p_pl_uom,
                     x_return_status => l_return_status,
                     x_quantity      => l_source_uom_quantity ,
                     x_timeunit      => l_source_tce_code);

    IF l_return_status <> 'S' THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

IF p_period_type = 'FIXED' THEN

    --When source uom is seeded in terms of DAY
    IF l_source_tce_code ='DAY' THEN
      IF l_target_tce_code ='YEAR' THEN
        l_target_qty:= p_unit_price*((360*l_target_uom_quantity)/l_source_uom_quantity);
      ELSIF l_target_tce_code ='MONTH' THEN
        l_target_qty:= p_unit_price*((30*l_target_uom_quantity)/l_source_uom_quantity);
      ELSIF l_target_tce_code ='DAY' THEN
        l_target_qty:= p_unit_price*(l_target_uom_quantity/l_source_uom_quantity);
      END IF;
    --When source uom is seeded in terms of MONTH
    ELSIF l_source_tce_code ='MONTH' THEN
      IF l_target_tce_code ='YEAR' THEN
        l_target_qty:= p_unit_price*((12*l_target_uom_quantity)/l_source_uom_quantity);
      ELSIF l_target_tce_code ='MONTH' THEN
        l_target_qty:= p_unit_price*(l_target_uom_quantity/l_source_uom_quantity);
      ELSIF l_target_tce_code ='DAY' THEN
        l_target_qty:= p_unit_price*(l_target_uom_quantity/(l_source_uom_quantity*30));
      END IF;
    --When source uom is seeded in terms of YEAR
    ELSIF l_source_tce_code ='YEAR' THEN
      IF l_target_tce_code ='YEAR' THEN
        l_target_qty:= p_unit_price*(l_target_uom_quantity/l_source_uom_quantity);
      ELSIF l_target_tce_code ='MONTH' THEN
        l_target_qty:= p_unit_price*(l_target_uom_quantity/(l_source_uom_quantity*12));
      ELSIF l_target_tce_code ='DAY' THEN
        l_target_qty:= p_unit_price*(l_target_uom_quantity/(l_source_uom_quantity*360));
      END IF;

    END IF;
return (l_target_qty);
END IF;

l_quantity := OKS_TIME_MEASURES_PUB.get_quantity
                       (p_start_date   => p_start_date,
                        p_end_date     => p_end_date,
                        p_source_uom   => p_price_uom,
                        p_period_type  => p_period_type,
                        p_period_start => p_period_start);

RETURN p_price_negotiated/l_quantity;

EXCEPTION
WHEN G_EXCEPTION_HALT_VALIDATION THEN
       RETURN NULL;
WHEN OTHERS THEN
        --set the error message and return with NULL to notify the
        --caller of error
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

       RETURN NULL;

END Get_Converted_price;


Procedure Create_Header_Bill_Sch
(
      p_billing_type         IN    Varchar2
,     p_sll_tbl              IN    StreamLvl_tbl
,     p_invoice_rule_id      IN    Number
,     x_bil_sch_out_tbl      OUT   NOCOPY ItemBillSch_tbl
,     x_return_status        OUT   NOCOPY Varchar2
)
IS

  Cursor l_contract_Csr(l_contract_id number) Is
          SELECT id, TRUNC(start_date) start_dt,
          nvl(trunc(date_terminated - 1) ,TRUNC(end_date)) end_dt
          FROM   okc_k_headers_b
          WHERE  Id =  l_contract_id ;

  Cursor l_top_line_Csr(l_contract_id number, l_hdr_date date) Is
          SELECT line.id id, line.inv_rule_id inv_rule_id, line.lse_id lse_id,
           det.usage_type usage_type
          FROM   OKC_K_LINES_b line, oks_k_lines_b det
          WHERE  line.dnz_chr_id =  l_contract_id
          AND line.lse_id IN (1, 12, 14, 19, 46)
          AND line.id = det.cle_id;





  l_Top_Line_Rec           l_Top_Line_Csr%Rowtype;
  l_Contract_Rec           l_contract_Csr%Rowtype;
  l_sll_out_tbl            StrmLvl_Out_tbl;
  l_sll_count              NUMBER;
  l_bil_sch_out_tbl        ItemBillSch_tbl;
  l_sll_tbl                OKS_BILL_SCH.StreamLvl_tbl;
  l_line_inv_id            NUMBER;
  --

   l_init_msg_list      VARCHAR2(2000) := OKC_API.G_FALSE;
   l_return_status      VARCHAR2(10);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);
   l_msg_index_out      NUMBER;
   l_msg_index  NUMBER;
--

-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 04-MAY-2005
-------------------------------------------------------------------------
l_price_uom         OKS_K_HEADERS_B.PRICE_UOM%TYPE;
l_period_start      OKS_K_HEADERS_B.PERIOD_START%TYPE;
l_period_type       OKS_K_HEADERS_B.PERIOD_TYPE%TYPE;
-------------------------------------------------------------------------
 /* Start Addition for bug fix 5945006 (FP Bug for 5926840) */
 	   CURSOR c_khr_csr(c_chr_id IN NUMBER) IS
 	           SELECT khr.acct_rule_id acct_rule_id
 	           FROM   oks_k_headers_b khr
 	           WHERE  khr.chr_id = c_chr_id;

 	   l_acct_rule_id    NUMBER;

 	   CURSOR c_subline_csr(c_topline_id IN NUMBER) IS
 	           SELECT cle.id
 	           FROM   okc_k_lines_b cle
 	           WHERE  cle.cle_id = c_topline_id
 	           AND    cle.lse_id IN(7,8,9,10,11,13,25,35);
 	   /* End Addition for bug fix 5945006 (FP Bug for 5926840) */


Begin
  x_return_status := 'S';

  IF p_sll_tbl.count = 0  THEN
    x_return_status := 'S';
    l_header_billing := null;
    RETURN;
  END IF;

  l_header_billing := p_sll_tbl(p_sll_tbl.FIRST).chr_id;
-------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------
   OKS_RENEW_UTIL_PUB.Get_Period_Defaults
                (
                 p_hdr_id        => l_header_billing,
                 p_org_id        => NULL,
                 x_period_start  => l_period_start,
                 x_period_type   => l_period_type,
                 x_price_uom     => l_price_uom,
                 x_return_status => x_return_status);

   IF x_return_status <> 'S' THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;


 -------------------------------------------------------------------------
 -- End partial period computation logic
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------


 IF p_billing_type IS NULL THEN
     OKC_API.set_message(G_PKG_NAME,'BILLING SCHEDULE TYPE');
     x_return_status := 'E';
     RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;



  IF p_invoice_rule_id IS NULL THEN
     OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'INVOICE ID NULL.');
     x_return_status := 'E';
     IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,G_MODULE_CURRENT||'.create_header_bill_sch.EXCEPTION',
             'p_invoice_rule_id null');
     END IF;
     RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;


  ------------find out the line details

  Open l_contract_Csr(p_sll_tbl(p_sll_tbl.FIRST).chr_id);
  Fetch l_contract_Csr Into l_contract_Rec;

  If l_contract_Csr%Notfound then
    Close l_contract_Csr;
    x_return_status := 'E';
    IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,G_MODULE_CURRENT||'.create_header_bill_sch.EXCEPTION',
             'contract dtls not found. = ' || p_sll_tbl(p_sll_tbl.FIRST).chr_id);
    END IF;
    RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;
  Close l_contract_Csr;

/* Start Addition for bug fix 5945006 (FP Bug for 5926840) */
 	   OPEN c_khr_csr(p_sll_tbl(p_sll_tbl.FIRST).chr_id);
 	   FETCH c_khr_csr INTO l_acct_rule_id;
 	   IF c_khr_csr%NOTFOUND
 	   THEN
 	     CLOSE c_khr_csr;
 	     IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level
 	     THEN
 	       fnd_log.string(fnd_log.level_exception,G_MODULE_CURRENT||'.create_header_bill_sch.EXCEPTION',
 	              'Accounting rule id not found for header id = ' || p_sll_tbl(p_sll_tbl.FIRST).chr_id);
 	     END IF;
 	     RAISE G_EXCEPTION_HALT_VALIDATION;
 	   END IF;
 	   CLOSE c_khr_csr;
 	   /* End Addition for bug fix 5945006 (FP Bug for 5926840) */


  l_currency_code := Find_Currency_Code(
                                    p_cle_id  => NULL,
                                    p_chr_id  => p_sll_tbl(p_sll_tbl.FIRST).chr_id);
  IF l_currency_code IS NULL THEN
        OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'CURRENCY CODE NOT FOUND.');
        x_return_status := 'E';
        IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,G_MODULE_CURRENT||'.create_header_bill_sch.EXCEPTION',
             'currency code not found.');
        END IF;
        RETURN;
  END IF;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

   fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.create_header_bill_sch.dtls',
                      'currency_code = ' || l_currency_code
                   || ', p_invoice_rule_id = ' || p_invoice_rule_id
                   || ', p_billing_type = ' || p_billing_type
                  );
  END IF;

  /*UPDATE OKS_K_HEADERS_B SET billing_schedule_type = p_billing_type
  WHERE chr_id = l_Contract_Rec.id;*/

  -----create  'SLL' REC
   -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- Added two new parameters P_period_start,P_period_type in procedural call
 -------------------------------------------------------------------------
 --Bug Fix 5185658
  pkg_cascade_billing_hdr := 'Y';

  Create_Stream_Level (p_billing_type          => p_billing_type,
                         p_strm_lvl_tbl          => p_sll_tbl,
                         p_dnz_chr_id            => l_Contract_Rec.id,
                         p_subline_call          => 'H',
                         p_line_amt              => NULL,
                         p_subline_amt           => NULL,
                         p_sll_start_dt          => l_contract_rec.start_dt,
                         p_end_dt                => l_contract_rec.end_dt,
                         p_period_start          => l_period_start,
                         p_period_type           => l_period_type,
                         x_sll_out_tbl           => l_sll_out_tbl,
                         x_return_status         => x_return_status);
 -------------------------------------------------------------------------
 -- End partial period computation logic
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------

  -----errorout_ad('Create_Stream_Level status = ' || x_return_status);
  -----errorout_ad('TOTAL SLL COUNT for line'|| TO_CHAR(l_sll_out_tbl.COUNT));

  IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_header_bill_sch.create_hdr_sll',
                      'Create_Stream_Level(x_return_status = '||x_return_status
                      ||', sll tbl out count = '||l_sll_out_tbl.count||')');
  END IF;

  IF x_return_status <> 'S' THEN
    RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

  ----if l_sll_out_tbl.count > 0 then insert lines into oks_level_elements
  IF l_sll_out_tbl.count > 0 then
 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- Added two new parameters p_period_start and p_period_type
 -------------------------------------------------------------------------
     Create_Hdr_Level_elements(
                      p_billing_type     => p_billing_type,
                      p_sll_tbl          => l_sll_out_tbl,
                      p_hdr_rec          => l_contract_rec,
                      p_invoice_ruleid   => p_invoice_rule_id,
                      p_called_from      => 1,
                      p_period_start     =>  l_period_start,
                      p_period_type      =>  l_period_type,
                      x_return_status    => x_return_status);

     -----errorout_ad('Create_Hdr_Level_elements status = ' || x_return_status);

     IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_header_bill_sch.create_hdr_lvl',
                      'Create_Hdr_Level_elements(x_return_status = '||x_return_status
                      ||', sll tbl out count passed = '||l_sll_out_tbl.count||')');
     END IF;

     IF x_return_status <> 'S' THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
  ELSE
     -----errorout_ad('sll count = ' || to_char(0));
     x_return_status := 'E';
     RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF ;

----create schedule for all lines.

FOR l_top_line_rec IN l_top_line_csr(l_contract_rec.id, l_contract_rec.start_dt)
LOOP

   IF l_top_line_rec.lse_id = 12 AND l_top_line_rec.usage_type in ('VRT', 'QTY')
      AND p_invoice_rule_id = -2 THEN

      l_line_inv_id := -3;
   ELSE
      l_line_inv_id := NULL;

   END IF;


   IF (nvl(l_top_line_rec.inv_rule_id , 0 ) <> p_invoice_rule_id ) OR l_line_inv_id IS NOT NULL THEN

        UPDATE okc_k_lines_b SET inv_rule_id = nvl(l_line_inv_id,p_invoice_rule_id)
        WHERE id = l_top_line_rec.id;


    END IF;
 /* Start Addition for bug fix 5945006 (FP Bug for 5926840) */
 	     UPDATE oks_k_lines_b
 	     SET    acct_rule_id = l_acct_rule_id
 	     WHERE  cle_id = l_top_line_rec.id;
 	     /* End Addition for bug fix 5945006 (FP Bug for 5926840) */



     l_sll_tbl := p_sll_tbl;

     ---chnage the sll tbl to call for line

     FOR l_index IN l_sll_tbl.FIRST .. l_sll_tbl.LAST
     LOOP

       l_sll_tbl(l_index).id           := NULL;
       l_sll_tbl(l_index).cle_id       := l_top_line_rec.id;
       l_sll_tbl(l_index).chr_id       := NULL;
       l_sll_tbl(l_index).dnz_chr_id   := l_contract_rec.id;
       --Start 25-APR-2005 mchoudha Fix for bug#4306152
       IF nvl(l_line_inv_id,p_invoice_rule_id) = -3 THEN
         l_sll_tbl(l_index).invoice_offset_days := NULL;
       END IF;
       --End 25-APR-2005 mchoudha Fix for bug#4306152
     END LOOP;


     Create_Bill_Sch_Rules(
        p_billing_type     => p_billing_type,
        p_sll_tbl          => l_sll_tbl,
        p_invoice_rule_id  => nvl(l_line_inv_id,p_invoice_rule_id),
        x_bil_sch_out_tbl  => l_bil_sch_out_tbl,
        x_return_status    => x_return_status);

    IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_header_bill_sch.create_line_bs',
                      'Create_Bill_Sch_Rules(x_return_status = '||x_return_status
                      ||', line id = '||l_sll_tbl(l_sll_tbl.first).cle_id||')');
    END IF;

    -----errorout_ad('Create_Bill_Sch_Rules status = ' || x_return_status);
    IF x_return_status <> 'S' THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
/* Start Addition for bug fix 5945006 (FP Bug for 5926840) */
 	     FOR c_subline_rec IN c_subline_csr(l_top_line_rec.id)
 	     LOOP
 	       UPDATE oks_k_lines_b
 	       SET acct_rule_id = l_acct_rule_id
 	       WHERE cle_id = c_subline_rec.id;
 	     END LOOP;
 	    /* End Addition for bug fix 5945006 (FP Bug for 5926840) */

END LOOP;

Copy_Bill_Sch(
           p_chr_id        => l_contract_rec.id,
           p_cle_id        => NULL,
           x_copy_bill_sch => x_bil_sch_out_tbl,
           x_return_status => x_return_status);

IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
   fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_header_bill_sch.hdr_bs_return',
                      'Copy_Bill_Sch(x_return_status = '||x_return_status
                      ||', level element count = '|| x_bil_sch_out_tbl.count ||')');
END IF;

-----errorout_ad('Copy_Bill_Sch = ' || x_return_status);

EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
  IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,G_MODULE_CURRENT||'.create_header_bill_sch.EXCEPTION',
                    'G_EXCEPTION_HALT_VALIDATION');
  END IF;

  l_currency_code := NULL;
  l_header_billing := NULL;

 WHEN OTHERS THEN

   IF FND_LOG.LEVEL_UNEXPECTED >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_unexpected,G_MODULE_CURRENT||'.create_header_bill_sch.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
   END IF;
   l_currency_code := NULL;
   l_header_billing := NULL;
   OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                       p_msg_name     => G_UNEXPECTED_ERROR,
                       p_token1       => G_SQLCODE_TOKEN,
                       p_token1_value => sqlcode,
                       p_token2       => G_SQLERRM_TOKEN,
                       p_token2_value => sqlerrm);

   x_return_status := G_RET_STS_UNEXP_ERROR;

END Create_Header_Bill_Sch;




Procedure Create_Bill_Sch_Rules
(     p_billing_type         IN    VARCHAR2
,     p_sll_tbl              IN    StreamLvl_tbl
,     p_invoice_rule_id      IN    Number
,     x_bil_sch_out_tbl      OUT   NOCOPY ItemBillSch_tbl
,     x_return_status        OUT   NOCOPY Varchar2
)

IS
------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 17-MAY-2005
 -- Added price_uom and lse_id in the select clause
 -------------------------------------------------------------------------
    Cursor l_subLine_Csr(l_line_id number, l_style_id number) Is
               SELECT line.id subline_id, TRUNC(line.start_date) cp_start_dt,
                      TRUNC(line.end_date) cp_end_dt, line.dnz_chr_id dnz_chr_id,
                      TRUNC(line.date_terminated) cp_term_dt,
                      price_UOM,lse_id cp_lse_id,
                      dtl.billing_schedule_type billing_schedule_type,
                      dtl.full_credit full_credit,
                      (nvl(line.price_negotiated,0) +  nvl(dtl.ubt_amount,0) +
                       nvl(dtl.credit_amount,0) +  nvl(dtl.suppressed_credit,0) ) subline_amt
               FROM okc_k_lines_b line, oks_k_lines_b dtl
               WHERE line.cle_id = l_line_id
               AND line.date_cancelled is NULL
               AND line.id = dtl.cle_id
               AND ((l_style_id = 1 and line.lse_id in (35,7,8,9,10,11))
                OR (l_style_id = 12 and line.lse_id = 13)
                OR (l_style_id = 14 and line.lse_id = 18)
                OR (l_style_id = 19 and line.lse_id = 25));
------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 17-MAY-2005
 -- Added price_uom in the select clause
 -------------------------------------------------------------------------
  Cursor l_Line_Csr(l_line_id number) Is
               SELECT line.chr_id chr_id, line.dnz_chr_id dnz_chr_id, line.id id, line.lse_id lse_id,
                      TRUNC(line.start_date) line_start_dt, TRUNC(line.end_date) line_end_dt,
                      line.cle_id cle_id,TRUNC(date_terminated) line_term_dt,
                      dtl.full_credit full_credit,
                      price_uom,
                      (nvl(line.price_negotiated,0) +  nvl(dtl.ubt_amount,0) +
                       nvl(dtl.credit_amount,0) +  nvl(dtl.suppressed_credit,0) ) line_amt
               FROM okc_k_lines_b line, oks_k_lines_b dtl
               WHERE  line.id = dtl.cle_id AND line.Id =  l_line_id
               AND   line.date_cancelled is NULL;

  CURSOR l_line_BS_csr(p_line_id  NUMBER) IS

         SELECT id,trunc(date_start) date_start,
         amount,trunc(date_end) date_end,object_version_number,
         date_to_interface, date_transaction
         FROM oks_level_elements
         WHERE cle_id = p_line_id
         ORDER BY date_start;


Cursor  l_line_amt_csr (p_id in number) IS
Select  line.price_negotiated
from    okc_k_lines_b line
where   line.id = p_id;



  l_Line_Csr_Rec           l_Line_Csr%Rowtype;
  l_SubLine_Csr_Rec        l_subLine_Csr%Rowtype;
  l_sll_out_tbl            StrmLvl_Out_tbl;
  l_top_bs_tbl             oks_bill_level_elements_pvt.letv_tbl_type;
  l_line_BS_rec            l_line_BS_csr%rowtype;
  l_sll_tbl                OKS_BILL_SCH.StreamLvl_tbl;


  l_dnz_chr_id            Number;
  l_sll_count            NUMBER;
  l_index                NUMBER;
  l_line_rec             Line_Det_Type;
  l_cp_rec               Prod_Det_Type;
  l_sll_start_dT         DATE;
  l_cp_term_dt           DATE;
  l_line_term_dt           DATE;
  --
  l_api_version         CONSTANT        NUMBER  := 1.0;
  l_init_msg_list       VARCHAR2(2000) := OKC_API.G_FALSE;
  l_msg_count           NUMBER;
   l_msg_data           VARCHAR2(2000);
   l_msg_index_out      NUMBER;
   l_msg_index  NUMBER;
-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 04-MAY-2005
-------------------------------------------------------------------------
l_price_uom         OKS_K_HEADERS_B.PRICE_UOM%TYPE;
l_period_start      OKS_K_HEADERS_B.PERIOD_START%TYPE;
l_period_type       OKS_K_HEADERS_B.PERIOD_TYPE%TYPE;
l_return_status     VARCHAR2(30);
l_tangible          BOOLEAN;
l_pricing_method    VARCHAR2(30);
-------------------------------------------------------------------------
-- End partial period computation logic
-- Date 04-MAY-2005
-------------------------------------------------------------------------
--
Begin

  x_return_status := 'S';

  l_sll_tbl.delete;


  IF p_sll_tbl.count = 0  THEN
    x_return_status := 'S';
    RETURN;
  END IF;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

   fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.create_bill_sch_rules.passed_val',
                      'p_sll_tbl count = ' || p_sll_tbl.count
                   || ', p_invoice_rule_id = ' || p_invoice_rule_id
                   || ', p_billing_type = ' || p_billing_type
                  );
  END IF;

  IF p_invoice_rule_id IS NULL THEN
-- nechatur 23-DEC-2005 for bug#4684706
-- OKC_API.set_message(G_PKG_NAME,'OKS_INVD_COV_RULE','RULE_NAME','IRE');
   OKC_API.set_message(G_PKG_NAME,'OKS_INVOICING_RULE');
-- end bug#4684706
     x_return_status := 'E';
     RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

  IF p_billing_type IS NULL THEN
     OKC_API.set_message(G_PKG_NAME,'BILLING SCHEDULE TYPE');
     x_return_status := 'E';
     RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

/* Line and subline details are fetched in different cursor as some of the top line (46)don't have subline
   and same API is called for subline BS in case of P
  otherwise the sql will have outer join*/

  ------------find out the line details

  Open l_Line_Csr(p_sll_tbl(p_sll_tbl.first).cle_id);
  Fetch l_Line_Csr Into l_Line_Csr_Rec;

  If l_Line_Csr%Notfound then
    Close l_Line_Csr;
    x_return_status := 'E';
    RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;
  l_dnz_chr_id := l_Line_Csr_Rec.dnz_chr_id;
  Close l_Line_Csr;

  l_line_rec.chr_id          :=  l_Line_Csr_Rec.chr_id;
  l_line_rec.dnz_chr_id      :=  l_Line_Csr_Rec.dnz_chr_id;
  l_line_rec.id              :=  l_Line_Csr_Rec.id ;
  l_line_rec.cle_id          :=  l_Line_Csr_Rec.cle_id ;
  l_line_rec.lse_id          :=  l_Line_Csr_Rec.lse_id;
  l_line_rec.line_start_dt   :=  l_Line_Csr_Rec.line_start_dt;
  l_line_rec.line_end_dt     :=  l_Line_Csr_Rec.line_end_dt;
  l_line_rec.line_amt        :=  l_Line_Csr_Rec.line_amt ;
  l_line_rec.price_uom       :=  l_Line_Csr_Rec.price_uom;

 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------

   OKS_RENEW_UTIL_PUB.Get_Period_Defaults
                (
                 p_hdr_id          => l_Line_Csr_Rec.dnz_chr_id,
                 p_org_id          => NULL,
                 x_period_start    => l_period_start,
                 x_period_type     => l_period_type,
                 x_price_uom       => l_price_uom,
                 x_return_status   => x_return_status);

   IF x_return_status <> 'S' THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;
  --Description in detail for the business rules for deriving the period start
  --1)For usage , period start  will always be 'SERVICE'
  --2)For Subscriptions, period start and period type will be NULL
  --  for tangible subscriptions as per CR1.For intangible subscriptions,
  --  if the profile OKS: Intangible Subscription Pricing Method
  --  is set to 'Subscription Based',then period start and period type will be NULL
  --  otherwise it will be 'SERVICE'
  --3) For Extended Warranty from OM, period start will always be 'SERVICE'

   IF l_period_start IS NOT NULL AND
      l_period_type IS NOT NULL
   THEN
     IF l_line_rec.lse_id =12 THEN
        l_period_start := 'SERVICE';
     END IF;
     IF l_line_rec.lse_id = 46 THEN
       --mchoudha fix for bug#5183011
       l_tangible  := OKS_SUBSCRIPTION_PUB.is_subs_tangible (l_line_rec.id);
       IF l_tangible THEN
         l_period_start := NULL;
         l_period_type := NULL;
       ELSE
         l_pricing_method :=FND_PROFILE.value('OKS_SUBS_PRICING_METHOD');
         IF nvl(l_pricing_method,'SUBSCRIPTION') <> 'EFFECTIVITY' THEN
           l_period_start := NULL;
           l_period_type := NULL;
         ELSE
           l_period_start := 'SERVICE';
         END IF;   -- l_pricing_method <> 'EFFECTIVITY'
       END IF;     -- IF l_tangible THEN
     END IF;       -- IF l_Line_Csr_Rec.lse_id = 46
   END IF;         -- period start and period type are not NULL
 -------------------------------------------------------------------------
 -- End partial period computation logic
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

   fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.create_bill_sch_rules.line_dtls',
                      'dnz_chr_id = ' || l_line_rec.dnz_chr_id
                   || ', id = ' || l_line_rec.id
                   || ', lse_id = ' || l_line_rec.lse_id
                   || ', start dt = ' || l_line_rec.line_start_dt
                   || ', end dt = ' || l_line_rec.line_end_dt
                   || ', amt = ' || l_line_rec.line_amt
                   || ', full_credit flag = ' || l_Line_Csr_Rec.full_credit
                  );
  END IF;


  IF l_header_billing IS NULL THEN
     l_currency_code := Find_Currency_Code(
                                    p_cle_id  => p_sll_tbl(p_sll_tbl.first).cle_id,
                                    p_chr_id  => NULL);

     IF l_currency_code IS NULL THEN
        OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'CURRENCY CODE NOT FOUND.');
        x_return_status := 'E';
        RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
  END IF;

  ---FIND sll start date
  l_sll_start_dt := l_line_csr_rec.line_start_dt;


  -----create  'SLL'

  UPDATE oks_k_lines_b set billing_schedule_type = p_billing_type
  WHERE cle_id = l_line_csr_rec.id;

   -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- Added two new parameters P_period_start,P_period_type in procedural call
 -------------------------------------------------------------------------
  Create_Stream_Level
     (p_billing_type              =>  p_billing_type,
      p_strm_lvl_tbl              =>  p_sll_tbl,
      p_dnz_chr_id                =>  l_line_csr_rec.dnz_chr_id,
      p_subline_call              =>  'N',
      p_line_amt                  =>  l_Line_Csr_Rec.line_amt,
      p_subline_amt               =>  null,
      p_sll_start_dt              =>  l_sll_start_dt,
      p_end_dt                    =>  l_line_rec.line_end_dt,
      p_period_start              =>  l_period_start,
      p_period_type               =>  l_period_type,
      x_sll_out_tbl               =>  l_sll_out_tbl,
      x_return_status             =>  x_return_status);

   -----errorout_ad('TOTAL SLL COUNT for line'|| TO_CHAR(l_sll_out_tbl.COUNT));
  -----errorout_ad('Create_Stream_Level = ' || x_return_status);

 IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
   fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_bill_sch_rules.line_sll',
                       'Create_Stream_Level(x_return_status = '||x_return_status
                       ||', l_sll_out_tbl count = '||l_sll_out_tbl.count||')');
 END IF;

 IF x_return_status <> 'S' THEN
    RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

  ----if l_sll_out_tbl.count > 0 then insert lines into oks_level_elements
  IF l_sll_out_tbl.count <= 0 THEN
     -----errorout_ad('sll  count = ' || to_char(0));
     x_return_status := 'E';
     RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

   fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.create_bill_sch_rules.copy_flag',
                      'sll amt to be adjusted flag = ' || p_sll_tbl(p_sll_tbl.FIRST).comments
                  );
  END IF;

  ---Called from copy with flag to change lvl_amt of SLL for E and P billing type.
  IF p_sll_tbl(p_sll_tbl.FIRST).comments IS NOT NULL AND p_sll_tbl(p_sll_tbl.FIRST).comments = '99'
    AND p_billing_type IN ('E', 'P') THEN

    l_sll_tbl  := p_sll_tbl;

    for i IN l_sll_tbl.FIRST .. l_sll_tbl.LAST
    LOOP
      l_sll_tbl(i).level_amount  := l_sll_out_tbl(i).amount;
      l_sll_tbl(i).comments       := '' ;
    END LOOP;
  ELSE
     l_sll_tbl  := p_sll_tbl;
  END IF;        ---chk for flag passed from copy.

  IF l_period_type is not null AND l_period_start is not NULL THEN
    OPEN l_line_amt_csr(l_Line_Csr_Rec.id);
    FETCH l_line_amt_csr INTO l_line_rec.line_amt;
    CLOSE l_line_amt_csr;
  END IF;

  --FOR subcripTion line which is terminated

  IF l_Line_Csr_Rec.lse_id = 46 AND l_Line_Csr_Rec.line_term_dt is not null THEN

     --if full credit flag is 'Y' just delete the unbilled lvl elements

     IF  nvl(l_Line_Csr_Rec.full_credit, 'N') = 'Y' Then
       DELETE FROM OKS_LEVEL_ELEMENTS
       WHERE date_completed IS NULL
       AND cle_id = l_Line_Csr_Rec.id;


       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

        fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.create_bill_sch_rules.del_lvl_ele',
                      'unbilled lvl element deleted = ' || sql%rowcount
                  );
       END IF;

     ELSE
       -------------------------------------------------------------------------
       -- Begin partial period computation logic
       -- Developer Mani Choudhary
       -- Date 09-MAY-2005
       -------------------------------------------------------------------------
       Create_Subcription_LvlEle
            (p_billing_type    =>  p_billing_type,
             p_sll_tbl          => l_sll_out_tbl,
             p_line_rec         => l_Line_rec,
             p_term_dt          => l_Line_Csr_Rec.line_term_dt,
             p_invoice_ruleid   => p_invoice_rule_id,
             p_period_start     =>  l_period_start,
             p_period_type      =>  l_period_type,
             x_return_status    => x_return_status);
       -------------------------------------------------------------------------
       -- End partial period computation logic
       -- Date 09-MAY-2005
       -------------------------------------------------------------------------

       -----errorout_ad('Create_Subcription_LvlEle status = ' || x_return_status);

       IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_bill_sch_rules.lvl_ele',
                       'Create_Subcription_LvlEle(x_return_status = '||x_return_status
                       ||', l_sll_out_tbl passed = '||l_sll_out_tbl.count||')');
       END IF;

       IF x_return_status <> 'S' THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
     END IF;     ---chk for full credit
     RETURN;

  END IF;      ---chk for terminated subscription line

  --for billing type 'P' , terminated sub line with full credit 'Y' change the term dt to
  --its start dt.(as this API is also called for subline from form in case of 'P')

  IF p_billing_type = 'P' and l_Line_Csr_Rec.lse_id NOT IN (1, 12, 14, 19)
     AND l_line_csr_rec.line_term_dt IS NOT NULL AND nvl(l_line_csr_rec.full_credit, 'N') = 'Y' THEN

     l_line_term_dt :=  l_line_csr_rec.line_start_dt;
  ELSE
     l_line_term_dt := l_line_csr_rec.line_term_dt;
  END IF;         --chk for subline,billing type 'P' with full credit flag 'Y'

  ---for all other cases and also lse_id = 46 and not terminated.
 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- Added two new parameters p_period_start and p_period_type
 -------------------------------------------------------------------------
  Create_Level_elements
       (p_billing_type     => p_billing_type,
        p_sll_tbl          => l_sll_out_tbl,
        p_line_rec         => l_Line_rec,
        p_invoice_ruleid   => p_invoice_rule_id,
        p_term_dt          => l_line_term_dt,
        p_period_start     =>  l_period_start,
        p_period_type      =>  l_period_type,
        x_return_status    => x_return_status);

   -----errorout_ad('Create_Level_elements status = ' || x_return_status);

   IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_bill_sch_rules.lvl_ele',
                       'Create_Level_elements(x_return_status = '||x_return_status
                       ||', term dt passed = ' || l_line_term_dt
                       ||', l_sll_out_tbl passed = '||l_sll_out_tbl.count||')');
   END IF;

   IF x_return_status <> 'S' THEN
     RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

    l_top_bs_tbl.DELETE;
    l_index := 0;
    IF p_billing_type IN ('T','E') and l_Line_Csr_Rec.lse_id IN (1, 12, 14, 19) then       ---only for top line
       l_index := l_index +1;

       ---fecthing from db because if line is partially billed then billed lvl ele
       --don't get inserted again. for rollup amt all the lvl ele required.

       FOR l_line_BS_rec IN l_line_BS_csr(l_line_csr_rec.id)
       loop
          l_top_bs_tbl(l_index).id                     := l_line_BS_rec.id;
          l_top_bs_tbl(l_index).date_start             := l_line_BS_rec.date_start;
          l_top_bs_tbl(l_index).date_end               := l_line_BS_rec.date_end;
          l_top_bs_tbl(l_index).Amount                 := 0;
          l_top_bs_tbl(l_index).object_version_number  := l_line_BS_rec.object_version_number;
          l_top_bs_tbl(l_index).date_transaction       := l_line_BS_rec.date_transaction;
          l_top_bs_tbl(l_index).date_to_interface      := l_line_BS_rec.date_to_interface;


          l_index := l_index + 1;
          -------errorout_ad('l_top_bs_tbl count = ' || l_top_bs_tbl.count);
      END LOOP;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

        fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.create_bill_sch_rules.top_bs_count',
                      'l_top_bs_tblcount = ' || l_top_bs_tbl.count
                  );
       END IF;
    END IF;        --end of top line with billing 'E','T'

  --if schedule is for top level line then find sub line and repeat THE process.
  IF l_Line_Rec.chr_id is not null AND l_Line_Rec.lse_id IN (1, 12, 14, 19) then

     FOR l_SubLine_csr_rec IN l_SubLine_Csr(l_Line_Rec.id,l_Line_Rec.lse_id)
     LOOP

         l_cp_rec.cp_id          :=  l_SubLine_Csr_rec.subline_id ;
         l_cp_rec.cp_start_dt    :=  l_SubLine_Csr_rec.cp_start_dt;
         l_cp_rec.cp_end_dt      :=  l_SubLine_Csr_rec.cp_end_dt ;
         l_cp_rec.cp_amt         :=  l_SubLine_Csr_rec.subline_amt ;
         l_cp_rec.dnz_chr_id     :=  l_subline_csr_rec.dnz_chr_id;
         l_cp_rec.cp_price_uom   :=  l_subline_csr_rec.price_uom;
         l_cp_rec.cp_lse_id      :=  l_subline_csr_rec.cp_lse_id;


        IF l_period_type is not null AND l_period_start is not NULL THEN
          OPEN l_line_amt_csr(l_SubLine_Csr_rec.subline_id);
          FETCH l_line_amt_csr INTO l_cp_rec.cp_amt;
          CLOSE l_line_amt_csr;
        END IF;
         -----errorout_ad('_cp_rec.cp_id = ' || l_cp_rec.cp_id);

         ---if subline is terminated with full credit then pass
         ---term date to bill_sch_cp as cp start date so that
         --level element doesn't get created.

         IF l_subline_csr_rec.cp_term_dt IS NOT NULL AND
            nvl(l_subline_csr_rec.full_credit,'N') = 'Y' THEN

            l_cp_term_dt := l_subline_csr_rec.cp_start_dt;
         else
            l_cp_term_dt := l_subline_csr_rec.cp_term_dt;
         END IF;         ---end of full credit chk

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

                fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.create_bill_sch_rules.cp_dtls',
                      'l_cp_term_dt = ' || l_cp_term_dt
                   || ', id = ' || l_cp_rec.cp_id
                   || ', lse_id = ' || l_line_rec.lse_id
                   || ', start dt = ' || l_cp_rec.cp_start_dt
                   || ', end dt = ' || l_cp_rec.cp_end_dt
                   || ', amt = ' || l_cp_rec.cp_amt
                   || ', full_credit flag = ' || l_subline_csr_rec.full_credit
                   || ', cp bill type = ' || l_subline_csr_rec.billing_schedule_type
                  );
        END IF;

        ----if schedule type is P then create sub lines  only if effectivity is same
        ---- and sll count for the subline is 0.


        if p_billing_type = 'P' then

          l_sll_count := Find_Sll_Count(l_subline_csr_rec.subline_id);


          ---Chk same effectivity

          IF TRUNC(l_line_rec.line_start_dt) = TRUNC(l_subline_csr_rec.cp_start_dt) AND
             TRUNC(l_line_rec.line_end_dt) = TRUNC(l_subline_csr_rec.cp_end_dt) THEN

             IF l_sll_count > 0 then

              /* check the bill type if other then 'P' then delete schedule and sLL*/

               ---get bill type details


              IF nvl(l_subline_csr_rec.billing_schedule_type,'T') <> 'P' THEN
                 ----if line has sll with billtype <> 'P', delete sll and level elements
                 --- and updates l_sll_count value as in case of 'P' Bs will be cascaded to
                 ---only subline with same effectivity.

                 Del_line_sll_lvl(p_line_id       => l_subline_csr_rec.subline_id,
                                 x_return_status    => x_return_status,
                                 x_msg_count     => l_msg_count,
                                 x_msg_data      => l_msg_data);

                IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_bill_sch_rules.del_bs',
                       'Del_line_sll_lvl(x_return_status = '||x_return_status
                       ||', cp id passed = '||l_subline_csr_rec.subline_id ||')');
                END IF;


                IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;
                l_sll_count := 0;
               END IF;       ---existing bill type <> 'P'
             END IF;       --sll count > 0

             IF l_sll_count = 0 THEN

                  -----errorout_ad('CREATING FOR SUBLINES');
                  --------------------------------------------------------------------------
                  -- Begin partial period computation logic
                  -- Developer Mani Choudhary
                  -- Date 09-MAY-2005
                  -- Added two new parameters P_period_start,P_period_type in procedural call
                  ---------------------------------------------------------------------------
                  Bill_Sch_Cp(p_billing_type => p_billing_type,
                             p_bsll_tbl      => l_sll_tbl,
                             p_Line_Rec      => l_Line_Rec,
                             p_SubLine_rec   => l_cp_rec,
                             p_invoice_rulid => p_invoice_rule_id,
                             p_top_line_bs   => l_top_bs_tbl,
                             p_term_dt       => l_cp_term_dt,
                             p_period_start  => l_period_start,
                             p_period_type   => l_period_type,
                             x_return_status => x_return_status );

                  IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_bill_sch_rules.cp_bs',
                       'Bill_Sch_Cp(x_return_status = '||x_return_status
                       ||', cp id passed = '||l_subline_csr_rec.subline_id ||')');
                  END IF;

                  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                  END IF;

             END IF;     --sll count=0

          ELSIF ( trunc(l_line_rec.line_start_dt) <> TRUNC(l_subline_csr_rec.cp_start_dt) OR
             TRUNC(l_line_rec.line_end_dt) <> TRUNC(l_subline_csr_rec.cp_end_dt) ) THEN  --unequal effectivity

             IF l_sll_count > 0 then               ---unequal effectivity, with sll count > 0
               /* check the bill type if other then 'P' then delete schedule and sLL*/

               ---get bill type details


               IF nvl(l_subline_csr_rec.billing_schedule_type,'T') <> 'P' THEN
                  ----if line has sll with billtype <> 'P', delete sll and level elements

                  Del_line_sll_lvl(p_line_id       => l_subline_csr_rec.subline_id,
                                 x_return_status    => x_return_status,
                                 x_msg_count     => l_msg_count,
                                 x_msg_data      => l_msg_data);

                  IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_bill_sch_rules.del_bs',
                       'Del_line_sll_lvl(x_return_status = '||x_return_status
                       ||'sll count >0 and not same effectivity'
                       ||', cp id passed = '||l_subline_csr_rec.subline_id ||')');
                  END IF;


                  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                     RAISE G_EXCEPTION_HALT_VALIDATION;
                  END IF;

               END IF;        --- existing bill type <> P

             ELSE             ---unequal effectivity, with sll count = 0

               ----update billing type to 'P'

               UPDATE oks_k_lines_b
               SET billing_schedule_type = 'P'
               WHERE cle_id = l_subline_csr_rec.subline_id;

               IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_bill_sch_rules.update_billtype',
                       'sll count >0 and not same effectivity'
                       || 'updated sub line billing type to P = ' || sql%rowcount
                     );
               END IF;

             END IF;        -------unequal effectivity sll count

         end if;         ---CHK FOR EQUAL EFFECTIVITY

       ELSE                  ---for 'E','T'

          IF nvl(l_subline_csr_rec.billing_schedule_type,p_billing_type) <> p_billing_type THEN
             ---Delete all the sll and lvl element for the sub line as billing type from
             ---the form can only be changed if no records are billed.

             DELETE FROM oks_level_elements WHERE cle_id = l_subline_csr_rec.subline_id;

             DELETE FROM oks_stream_levels_b WHERE cle_id = l_subline_csr_rec.subline_id;
          END IF;          --if sub line billing type <> p_billing_type

          --------------------------------------------------------------------------
          -- Begin partial period computation logic
          -- Developer Mani Choudhary
          -- Date 09-MAY-2005
          -- Added two new parameters P_period_start,P_period_type in procedural call
          ---------------------------------------------------------------------------
          Bill_Sch_Cp(p_billing_type  => p_billing_type,
                      p_bsll_tbl      => l_sll_tbl,
                      p_Line_Rec      => l_Line_Rec,
                      p_SubLine_rec   => l_cp_rec,
                      p_invoice_rulid => p_invoice_rule_id,
                      p_top_line_bs   => l_top_bs_tbl,
                      p_term_dt       => l_cp_term_dt,
                      p_period_start  => l_period_start,
                      p_period_type   => l_period_type,
                      x_return_status => x_return_status );

          IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_bill_sch_rules.cp_bs',
                       'Bill_Sch_Cp(x_return_status = '||x_return_status
                       ||', cp id passed = '||l_subline_csr_rec.subline_id ||')');
          END IF;

           IF x_return_status <> 'S' THEN
             RAISE G_EXCEPTION_HALT_VALIDATION;
           END IF;


       end if;     ---chk for bill type
       -----errorout_ad('Bill_Sch_Cp status = ' || x_return_status);



   END LOOP;  ---subline loop end

  END IF;               ---just for top line



  IF l_top_bs_tbl.COUNT >0 THEN            ---only for type 'T' and  'E' l_top_bs_tbl will be having records
    OKS_BILL_LEVEL_ELEMENTS_PVT.update_row(
               p_api_version                  => l_api_version,
               p_init_msg_list                => l_init_msg_list,
               x_return_status                => x_return_status,
               x_msg_count                    => l_msg_count,
               x_msg_data                     => l_msg_data,
               p_letv_tbl                     => l_top_bs_tbl,
               x_letv_tbl                     => l_lvl_ele_tbl_out);

   IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_bill_sch_rules.update_top_bs',
                       'OKS_BILL_LEVEL_ELEMENTS_PVT.update_row(x_return_status = '||x_return_status
                       ||', tbl count = '||l_lvl_ele_tbl_out.count ||')');
   END IF;

    IF  x_return_status <> 'S' THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END IF;        ---l_top_bs_tbl count chk



EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN

  IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,G_MODULE_CURRENT||'.create_bill_sch_rules.EXCEPTION',
                    'G_EXCEPTION_HALT_VALIDATION');
  END IF;

  l_currency_code := NULL;
  l_header_billing := NULL;

 WHEN OTHERS THEN

   IF FND_LOG.LEVEL_UNEXPECTED >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_unexpected,G_MODULE_CURRENT||'.create_bill_sch_rules.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
   END IF;
   OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                       p_msg_name     => G_UNEXPECTED_ERROR,
                       p_token1       => G_SQLCODE_TOKEN,
                       p_token1_value => sqlcode,
                       p_token2       => G_SQLERRM_TOKEN,
                       p_token2_value => sqlerrm);

   x_return_status := G_RET_STS_UNEXP_ERROR;


END Create_Bill_Sch_Rules;


 --------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- Added two new parameters P_period_start,P_period_type in procedural call
 ---------------------------------------------------------------------------
Procedure Create_Stream_Level
(     p_billing_type              IN    VARCHAR2
,     p_strm_lvl_tbl              IN    StreamLvl_tbl
,     p_dnz_chr_id                IN    NUMBER
,     p_subline_call              IN    VARCHAR2
,     p_line_amt                  IN    NUMBER
,     p_subline_amt               IN    NUMBER
,     p_sll_start_dt              IN    DATE
,     p_end_dt                    IN    DATE
,     p_period_start              IN    VARCHAR2
,     p_period_type               IN    VARCHAR2
,     x_sll_out_tbl               OUT   NOCOPY StrmLvl_Out_tbl
,     x_return_status             OUT   NOCOPY Varchar2
)
Is

CURSOR l_subline_sll_csr(p_seq_no NUMBER, p_line_id NUMBER) IS
       SELECT id , object_version_number FROM oks_stream_levels_b
       WHERE sequence_no = p_seq_no
       AND cle_id = p_line_id;

l_subline_sll_rec   l_subline_sll_csr%ROWTYPE;
l_sll_prorate_tbl        sll_prorated_tab_type;

l_tbl_count         NUMBER;
l_sll_id           NUMBER;
l_start_date         DATE;
l_end_date          DATE;
l_subline_sll       NUMBER;
l_rul_status        VARCHAR2(100);
l_msg_count         NUMBER;
l_msg_data          VARCHAR2(2000);
l_init_msg_list     VARCHAR2(2000) := OKC_API.G_FALSE;
l_sll_amount        VARCHAR2(450);
l_amount            NUMBER;
l_tot_amt           NUMBER;
l_prior_index       NUMBER;
l_line_amt          NUMBER;
l_obj_version       NUMBER;
l_uom_quantity      NUMBER;
l_tce_code          VARCHAR2(30);

--Bug Fix 5185658

    Cursor get_lse_id_csr(p_cle_id number ) IS
    select lse_id
    from okc_k_lines_b
    where id = p_cle_id;

    l_lse_id number;

--End Bug Fix 5185658

BEGIN

/* In sll creation amount will be prorated for 'E' and 'P' type for subline
and top lines in case of hdr billing*/

------count the table of records and in for loop create records 'SLL'
--p_subline call can have 3 values Y for sub line, N - top line, H - header

-----errorout_ad('p_subline_call = ' || p_subline_call);

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

        fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.create_stream_level.called',
                      ' p_subline_call = ' || p_subline_call );
END IF;

x_return_status := 'S';

If p_strm_lvl_tbl.count <= 0 THEN
   RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;


IF p_billing_type <> 'T' THEN

    IF l_header_billing IS NOT NULL and p_subline_call = 'Y' THEN             ---sub line and hdr billing
       l_tot_amt  := Cal_hdr_Amount(l_header_billing);

    ELSIF l_header_billing IS NULL and p_subline_call = 'Y' THEN          --sub line and not hdr billing

       l_tot_amt := P_Line_Amt;                 ---USED IN CAL AMT FOR E and P

    ELSIF l_header_billing IS NOT NULL AND p_subline_call = 'N' THEN     ---top line

       l_tot_amt  := Cal_hdr_Amount(l_header_billing);
       l_line_amt := p_line_amt;
    END IF;   --chk for hdr billing and if called fro line/subline

END IF;   --end of p_billing_type <> 'T'

--Bug Fix 5185658

-- Bug fix for 5325152
--changed the idnex from 1 to p_strm_lvl_tbl.FIRST
open get_lse_id_csr (p_strm_lvl_tbl(p_strm_lvl_tbl.FIRST).cle_id);
Fetch get_lse_id_csr into l_lse_id;
Close get_lse_id_csr;

--End Bug Fix 5185658


FOR l_tbl_count IN p_strm_lvl_tbl.First .. p_strm_lvl_tbl.LAST
LOOP

   l_strm_lvl_tbl_in.DELETE;
   l_obj_version := NULL;

   IF p_subline_call IN ('N','H') THEN           ---if it is for top line/hdr
      IF p_billing_type = 'T' THEN
         l_sll_amount := NULL;
      ELSIF l_header_billing IS NOT NULL AND p_subline_call = 'N' THEN     --Top line in case of hdr billing

        IF  l_tot_amt = 0 or l_tot_amt IS NULL THEN
           l_amount := (l_Line_amt * p_strm_lvl_tbl(l_tbl_count).level_amount)/1;
        ELSE
           l_amount := (l_line_amt * p_strm_lvl_tbl(l_tbl_count).level_amount)/l_tot_amt;
        END IF;

        l_sll_amount := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_amount, l_currency_code);

      ELSE      ---caled for header or top ine in case of not hdr billing.
        l_sll_amount := p_strm_lvl_tbl(l_tbl_count).level_amount;
      END IF;


      IF l_header_billing IS NOT NULL AND p_subline_call <> 'H' THEN
        -----errorout_ad('p_subline_call <> H');
        l_sll_id := NULL;
      ELSE

        IF p_strm_lvl_tbl(l_tbl_count).Id IS NULL THEN                ---------FOR INSERT
          -----errorout_ad('null sll id');
          l_sll_id := NULL;
        ELSE                      --------FOR UPDATE
          -----errorout_ad('sll_id = ' || p_strm_lvl_tbl(l_tbl_count).Id);
          l_obj_version := chk_Sll_Exists(p_strm_lvl_tbl(l_tbl_count).Id);
          IF l_obj_version IS NOT NULL THEN
             l_sll_id := p_strm_lvl_tbl(l_tbl_count).Id;
          ELSE
             l_sll_id := null;
          END IF;
        END IF;
      END IF;

    ELSE          --CALLED FROM SUB LINE PROCEDURE
      IF p_billing_type = 'T' THEN
        l_sll_amount := NULL;
      ELSE
                                     ------FOR E and P
        IF  l_tot_amt = 0 or l_tot_amt IS NULL THEN
           l_amount := (p_SubLine_amt * p_strm_lvl_tbl(l_tbl_count).level_amount)/1;
        ELSE
           l_amount := (p_SubLine_amt * p_strm_lvl_tbl(l_tbl_count).level_amount)/l_tot_amt;
        END IF;

        l_sll_amount := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_amount, l_currency_code);
      END IF;

      IF l_header_billing IS NOT NULL AND p_subline_call <> 'H' THEN
         l_sll_id := NULL;
      ELSE

        IF p_strm_lvl_tbl(l_tbl_count).Id IS NULL THEN        -------FOR INSERT
          l_sll_id := NULL;

        ELSE                          ----FOR UPDATE
          -------FIND OUT SUBLINE sll ID FOR UPDATE MATCH THEM WITH SEQUENCE NUMBER
          OPEN l_subline_sll_csr(p_strm_lvl_tbl(l_tbl_count).sequence_no,p_strm_lvl_tbl(l_tbl_count).cle_id);
          FETCH l_subline_sll_csr INTO l_subline_sll_rec;
          IF l_subline_sll_csr%NOTFOUND THEN
            CLOSE l_subline_sll_csr;
            l_sll_id := NULL;

          ELSE
            CLOSE l_subline_sll_csr;
            l_sll_id := l_subline_sll_rec.id;
            l_obj_version := l_subline_sll_rec.object_version_number;
          END IF;
        END IF;                 ---------INSERT/UPDATE IF

      END IF;                -----l_header_billing IS NOT NULL AND p_subline_call <> 'H'


    END IF;           ------------LINE/SUBLINE IF

    -----errorout_ad('l_sll_id = ' || l_sll_id);
    -----errorout_ad('l_tbl_count = ' || l_tbl_count || 'and first sll index = ' ||  p_strm_lvl_tbl.First);

    IF l_tbl_count = p_strm_lvl_tbl.First THEN
       l_start_date := p_sll_start_dt;

    ELSE

       l_start_date :=  x_sll_out_tbl(l_tbl_count - 1).end_date + 1;

    END IF;
    -----errorout_ad('for SLL LINE : ' || TO_CHAR(l_tbl_count) || ' --DATE_START = ' || TO_DATE(l_next_date));

    -------------------------------------------------------------------------
    -- Begin partial period computation logic
    -- Developer Mani Choudhary
    -- Date 09-MAY-2005
    -- In case of calendar start , call the new funtion to derive the SLL end date
    -------------------------------------------------------------------------
    OKS_BILL_UTIL_PUB.Get_Seeded_Timeunit
                    (p_timeunit      => p_strm_lvl_tbl(l_tbl_count).uom_code,
                     x_return_status => x_return_status,
                     x_quantity      => l_uom_quantity ,
                     x_timeunit      => l_tce_code);
    IF x_return_status <> 'S' THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF p_period_start is not null        AND
       p_period_type is not null         AND
       p_period_start = 'CALENDAR'       AND
       l_tce_code not in ('DAY','HOUR','MINUTE')
    THEN
       l_end_date := OKS_BILL_UTIL_PUB.get_enddate_cal
                            (l_start_date,
                             p_strm_lvl_tbl(l_tbl_count).uom_code,
                             p_strm_lvl_tbl(l_tbl_count).uom_per_period,
                             p_strm_lvl_tbl(l_tbl_count).level_periods);

    ELSE
        --Existing Logic for calculating SLL end date

       l_end_date := OKC_TIME_UTIL_PUB.get_enddate(
                      l_start_date,
                      p_strm_lvl_tbl(l_tbl_count).uom_code,
                     (p_strm_lvl_tbl(l_tbl_count).level_periods * p_strm_lvl_tbl(l_tbl_count).uom_per_period));

    END IF;
       --If the sll end date and line end date  falls in the same month and
       --sll end date >  line end date , then assign line end date to sll emd date
    IF (l_end_date > p_end_dt AND p_period_start is not null
        AND  p_period_type is not null) THEN
         l_end_date := p_end_dt;
    END IF;

    -------------------------------------------------------------------------
    -- End partial period computation logic
    -- Date 09-MAY-2005
    -------------------------------------------------------------------------
    l_strm_lvl_tbl_in(1).chr_id                   :=  p_strm_lvl_tbl(l_tbl_count).chr_id;
    l_strm_lvl_tbl_in(1).cle_id                   :=  p_strm_lvl_tbl(l_tbl_count).cle_id;
    l_strm_lvl_tbl_in(1).dnz_chr_id               :=  p_dnz_chr_id;
    l_strm_lvl_tbl_in(1).sequence_no              :=  p_strm_lvl_tbl(l_tbl_count).sequence_no ;
    l_strm_lvl_tbl_in(1).uom_code                 :=  p_strm_lvl_tbl(l_tbl_count).uom_code;
    l_strm_lvl_tbl_in(1).start_date               :=  l_start_date;
    l_strm_lvl_tbl_in(1).end_date                 :=  l_end_date;
    l_strm_lvl_tbl_in(1).level_periods            :=  p_strm_lvl_tbl(l_tbl_count).level_periods;
    l_strm_lvl_tbl_in(1).uom_per_period           :=  p_strm_lvl_tbl(l_tbl_count).uom_per_period;
    l_strm_lvl_tbl_in(1).level_amount             :=  l_sll_amount;
    l_strm_lvl_tbl_in(1).invoice_offset_days      :=  p_strm_lvl_tbl(l_tbl_count).invoice_offset_days;
    l_strm_lvl_tbl_in(1).interface_offset_days    :=  p_strm_lvl_tbl(l_tbl_count).interface_offset_days;


    l_strm_lvl_tbl_in(1).object_version_number     := OKC_API.G_MISS_NUM;
    l_strm_lvl_tbl_in(1).created_by                := OKC_API.G_MISS_NUM;
    l_strm_lvl_tbl_in(1).creation_date             := SYSDATE;
    l_strm_lvl_tbl_in(1).last_updated_by           := OKC_API.G_MISS_NUM;
    l_strm_lvl_tbl_in(1).last_update_date           := SYSDATE;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

     fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.create_stream_level.sll_dtls',
                      ' line id = ' || l_strm_lvl_tbl_in(1).cle_id
                   || ', chr_id = ' || l_strm_lvl_tbl_in(1).chr_id
                   || ', start date = ' || l_strm_lvl_tbl_in(1).start_date
                   || ', end date = ' || l_strm_lvl_tbl_in(1).end_date
                   || ', amount = ' || l_strm_lvl_tbl_in(1).level_amount
                   || ', period = ' || l_strm_lvl_tbl_in(1).level_periods
                   || ', uom_per_period = ' || l_strm_lvl_tbl_in(1).uom_per_period
                   || ', uom = ' || l_strm_lvl_tbl_in(1).uom_code
                   || ', sequence = ' || l_strm_lvl_tbl_in(1).sequence_no
                   || ', inv-interface offset = ' || l_strm_lvl_tbl_in(1).invoice_offset_days
                   || ', ' || l_strm_lvl_tbl_in(1).interface_offset_days
                  );
    END IF;

    IF (l_sll_id IS NULL) THEN

       OKS_SLL_PVT.insert_row(
               p_api_version        => l_api_version,
               p_init_msg_list      => l_init_msg_list,
               x_return_status      => x_return_status,
               x_msg_count          => l_msg_count,
               x_msg_data           => l_msg_data,
               p_sllv_tbl           => l_strm_lvl_tbl_in,
               x_sllv_tbl           => l_strm_lvl_tbl_out);

       IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_stream_level.insert',
                      'OKS_SLL_PVT.insert_row(x_return_status = '||x_return_status
                      ||', sll id created = '||l_strm_lvl_tbl_out(1).id ||')');
       END IF;

      -----errorout_ad('SllCREATED : '|| x_return_status);
      -----errorout_ad('sll id = ' || l_strm_lvl_tbl_in(1));


      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

    ELSE            --sll id not null
      l_strm_lvl_tbl_in(1).id                           := l_sll_id;
      l_strm_lvl_tbl_in(1).object_version_number        := l_obj_version;

      OKS_SLL_PVT.update_row(
               p_api_version        => l_api_version,
               p_init_msg_list      => l_init_msg_list,
               x_return_status      => x_return_status,
               x_msg_count          => l_msg_count,
               x_msg_data           => l_msg_data,
               p_sllv_tbl           => l_strm_lvl_tbl_in,
               x_sllv_tbl           => l_strm_lvl_tbl_out);

       IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_stream_level.update',
                      'OKS_SLL_PVT.update_row(x_return_status = '||x_return_status
                      ||', sll id updated = '||l_strm_lvl_tbl_out(1).id ||')');
       END IF;

      -----errorout_ad('STREAM LEVEL RULE updated : '|| x_return_status);


      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    x_sll_out_tbl(l_tbl_count).chr_Id                := l_strm_lvl_tbl_out(1).chr_id;
    x_sll_out_tbl(l_tbl_count).cle_Id                := l_strm_lvl_tbl_out(1).cle_id;
    x_sll_out_tbl(l_tbl_count).dnz_chr_Id            := l_strm_lvl_tbl_out(1).dnz_chr_id;
    x_sll_out_tbl(l_tbl_count).Id                    := l_strm_lvl_tbl_out(1).id;
    x_sll_out_tbl(l_tbl_count).Seq_no                := l_strm_lvl_tbl_out(1).sequence_no;
    x_sll_out_tbl(l_tbl_count).Dt_start              := l_strm_lvl_tbl_out(1).start_date;
    x_sll_out_tbl(l_tbl_count).end_date              := l_strm_lvl_tbl_out(1).end_date;
    x_sll_out_tbl(l_tbl_count).Level_Period          := l_strm_lvl_tbl_out(1).level_periods;
    x_sll_out_tbl(l_tbl_count).uom_Per_Period        := l_strm_lvl_tbl_out(1).uom_per_period;
    x_sll_out_tbl(l_tbl_count).uom                   := l_strm_lvl_tbl_out(1).uom_code;
    x_sll_out_tbl(l_tbl_count).Amount                := l_strm_lvl_tbl_out(1).level_amount;
    x_sll_out_tbl(l_tbl_count).invoice_offset_days    := l_strm_lvl_tbl_out(1).invoice_offset_days;
    x_sll_out_tbl(l_tbl_count).Interface_offset_days := l_strm_lvl_tbl_out(1).interface_offset_days;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

     fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.create_stream_level.top_sll_dtls',
                      ' sll id = ' || x_sll_out_tbl(l_tbl_count).Id
                   || ', start date = ' || x_sll_out_tbl(l_tbl_count).Dt_start
                  );
    END IF;

End Loop;

--Bug Fix 5185658

--IF p_billing_type IN ('P','E') AND p_strm_lvl_tbl(p_strm_lvl_tbl.first).comments IS NOT NULL AND
--     p_strm_lvl_tbl(p_strm_lvl_tbl.first).comments = '99' AND p_subline_call = 'N' THEN

     IF (
          p_billing_type IN ('P','E') AND p_strm_lvl_tbl(p_strm_lvl_tbl.first).comments IS NOT NULL AND
          p_strm_lvl_tbl(p_strm_lvl_tbl.first).comments = '99' AND p_subline_call = 'N'
        )
        OR
        (
          l_lse_id = 46 AND p_period_start = 'SERVICE' AND p_billing_type = 'E' AND nvl(pkg_cascade_billing_hdr, 'N') = 'Y'
        )
    THEN

--End Bug Fix 5185658

     l_sll_prorate_tbl.DELETE;

     FOR l_index IN x_sll_out_tbl.FIRST .. x_sll_out_tbl.LAST
     LOOP
       l_sll_prorate_tbl(l_index).sll_seq_num := l_index;
       l_sll_prorate_tbl(l_index).sll_start_date := x_sll_out_tbl(l_index).Dt_start;
       l_sll_prorate_tbl(l_index).sll_end_date   := x_sll_out_tbl(l_index).end_Date;
       l_sll_prorate_tbl(l_index).sll_tuom       := x_sll_out_tbl(l_index).uom;
       l_sll_prorate_tbl(l_index).sll_period     := x_sll_out_tbl(l_index).level_period;
       --03-NOV-2005-mchoudha-Fix for bug#4691026
       l_sll_prorate_tbl(l_index).sll_uom_per_period  := x_sll_out_tbl(l_index).uom_per_period;
     END LOOP;


     Calculate_sll_amount(
                      p_api_version      => l_api_version,
                      p_total_amount     => p_line_amt,
                      p_currency_code    => l_currency_code,
                      p_period_start     => p_period_start,
                      p_period_type      => p_period_type,
                      p_sll_prorated_tab => l_sll_prorate_tbl,
                      x_return_status    => x_return_status);

    IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_stream_level.prorate',
                      'Calculate_sll_amount(x_return_status = '||x_return_status
                      ||', l_sll_prorate_tbl count = '|| l_sll_prorate_tbl.count ||')');
    END IF;


    -----errorout_ad  ('Get_sll_amount STATUS = ' ||  x_return_status);


    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    FOR l_index IN l_sll_prorate_tbl.FIRST .. l_sll_prorate_tbl.LAST
    LOOP
      UPDATE oks_stream_levels_b
      Set level_amount = l_sll_prorate_tbl(l_index).sll_amount
      WHERE id = x_sll_out_tbl(l_index).id;

      x_sll_out_tbl(l_index).amount  := l_sll_prorate_tbl(l_index).sll_amount;
    END LOOP;                  ---END OF UPDATE LOOP


END IF;                ----end for chk if proration required for copied.


EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,G_MODULE_CURRENT||'.create_stream_level.EXCEPTION',
                    'G_EXCEPTION_HALT_VALIDATION');
       END IF;
        x_return_status := 'E';

 WHEN OTHERS THEN
        IF FND_LOG.LEVEL_UNEXPECTED >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_unexpected,G_MODULE_CURRENT||'.Create_Stream_Level.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
        END IF;

        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;

End Create_Stream_Level;



FUNCTION chk_Sll_Exists(p_id IN NUMBER) return number IS

CURSOR l_sll_csr(p_sll_id NUMBER) IS
     SELECT id ,object_version_number
     FROM oks_stream_levels_b
     WHERE ID = p_sll_id;

l_sll_rec    l_sll_csr%ROWTYPE;
BEGIN

  IF p_id is null THEN
    return(null);
  ELSE
    OPEN l_sll_csr(p_id);
    FETCH l_sll_csr INTO l_sll_rec;

    IF l_sll_csr%NOTFOUND THEN
      CLOSE l_sll_csr;
      return(null);
    ELSE
      CLOSE l_sll_csr;
      return(l_sll_rec.object_version_number);
    END IF;
  END IF;


EXCEPTION
    WHEN OTHERS then
      RETURN(null);

END chk_Sll_Exists;



 --------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- Added two new parameters P_period_start,P_period_type in procedural call
 ---------------------------------------------------------------------------
PROCEDURE Bill_Sch_Cp
(           p_billing_type      IN   VARCHAR2,
            p_bsll_tbl          IN   StreamLvl_tbl,
            p_Line_Rec          IN   Line_Det_Type,
            p_SubLine_rec       IN   Prod_Det_Type,
            p_invoice_rulid     IN   Number,
            p_top_line_bs       IN   OUT NOCOPY oks_bill_level_elements_pvt.letv_tbl_type,
            p_term_dt           IN   DATE,
            p_period_start      IN   VARCHAR2,
            p_period_type       IN   VARCHAR2,
            x_return_status     OUT  NOCOPY Varchar2
)
IS

Cursor l_Line_Amt_Csr(p_line_id IN NUMBER) Is
 SELECT (nvl(line.price_negotiated,0) +  nvl(dtl.ubt_amount,0) +
         nvl(dtl.credit_amount,0) +  nvl(dtl.suppressed_credit,0) ) line_amt
 FROM okc_k_lines_b line, oks_k_lines_b dtl
 WHERE line.id = p_line_id
 AND line.id = dtl.cle_id;

l_cp_sll_out_tbl          StrmLvl_Out_tbl;
l_cp_sll_tbl              OKS_BILL_SCH.StreamLvl_tbl;
l_line_amt                NUMBER;
l_subline_amt             NUMBER;

BEGIN

---the procedure creates sll and level elements for subline.
  -----errorout_ad('in  bill_sch_cp');
x_return_status := 'S';

l_cp_sll_tbl := p_bsll_tbl;

FOR l_index IN l_cp_sll_tbl.FIRST .. l_cp_sll_tbl.LAST
LOOP
  l_cp_sll_tbl(l_index).cle_id := p_subline_rec.cp_id;
END LOOP;

UPDATE OKS_K_LINES_B SET billing_schedule_type = p_billing_type
WHERE cle_id = p_subline_rec.cp_id;

-----create  'SLL'RECORDS

 --------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- Added two new parameters P_period_start,P_period_type in procedural call
 ---------------------------------------------------------------------------

IF p_period_type is not null AND p_period_start is not NULL THEN
  OPEN l_Line_Amt_Csr(p_Line_Rec.id);
  FETCH l_Line_Amt_Csr INTO l_line_amt;
  CLOSE l_Line_Amt_Csr;
  OPEN l_Line_Amt_Csr(p_SubLine_rec.cp_id);
  FETCH l_Line_Amt_Csr INTO l_subline_amt;
  CLOSE l_Line_Amt_Csr;
ELSE
  l_line_amt := p_line_Rec.line_amt;
  l_subline_amt := p_subline_rec.cp_amt;
END IF;


Create_Stream_Level
     (p_billing_type              =>  p_billing_type,
      p_strm_lvl_tbl              =>  l_cp_sll_tbl,
      p_subline_call              =>  'Y',
      p_dnz_chr_id                =>  p_line_rec.dnz_chr_id,
      p_line_amt                  =>  l_line_amt,
      p_subline_amt               =>  l_subline_amt,
      p_sll_start_dt              =>  p_line_rec.line_start_dt,
      p_end_dt                    =>  p_line_rec.line_end_dt,
      p_period_start              =>  p_period_start,
      p_period_type               =>  p_period_type,
      x_sll_out_tbl               =>  l_cp_sll_out_tbl,
      x_return_status             =>  x_return_status);

 -------------------------------------------------------------------------
 -- End partial period computation logic
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------

IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.bill_sch_cp.sll',
                       'Create_Stream_Level(x_return_status = '||x_return_status
                       ||', l_cp_sll_out_tbl count = '|| l_cp_sll_out_tbl.count ||')');
END IF;

-------------errorout_ad('SLL Record FOR SUBLINE = ' || TO_CHAR(l_cp_sll_out_tbl.count));
----if l_cp_sll_out_tbl.count > 0 then insert lines into oks_level_elements_v
IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
    RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;



 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- Added two new parameters p_period_start and p_period_type
 -------------------------------------------------------------------------
Create_cp_lvl_elements(
            p_billing_type      =>   p_billing_type,
            p_cp_sll_tbl        =>   l_cp_sll_out_tbl,
            p_Line_Rec          =>   p_Line_Rec,
            p_SubLine_rec       =>   p_SubLine_rec,
            p_invoice_rulid     =>   p_invoice_rulid,
            p_top_line_bs       =>   p_top_line_bs,
            p_term_dt           =>   p_term_dt,
            p_period_start      =>   p_period_start,
            p_period_type       =>   p_period_type,
            x_return_status     =>   x_return_status);

IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.bill_sch_cp.lvl_ele',
                       'Create_cp_lvl_elements(x_return_status = '||x_return_status
                       ||', p_term_dt passed = '|| p_term_dt ||')');
END IF;

 IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
    RAISE G_EXCEPTION_HALT_VALIDATION;
 END IF;

EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,G_MODULE_CURRENT||'.bill_sch_cp.EXCEPTION',
                    'G_EXCEPTION_HALT_VALIDATION');
       END IF;

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
 WHEN OTHERS THEN

     IF FND_LOG.LEVEL_UNEXPECTED >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_unexpected,G_MODULE_CURRENT||'.bill_sch_Cp.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
      END IF;

      OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;
END Bill_Sch_Cp;



PROCEDURE Copy_Bill_Sch
(
           p_chr_id         IN    Number,
           p_cle_id         IN    Number,
           x_copy_bill_sch  OUT   NOCOPY ItemBillSch_tbl,
           x_return_status  OUT   NOCOPY Varchar2
)
IS
  Cursor l_LineSch_Csr is
                     SELECT sll.sequence_no,element.cle_id,
                            element.sequence_number, element.date_transaction,
                            element.date_start, element.date_to_interface,
                            element.date_completed, element.amount,element.date_end,
                            element.rul_id
                            FROM oks_level_elements element, oks_stream_levels_b sll
                            WHERE sll.id  = element.rul_id
                            AND sll.cle_id = p_cle_id
                            ORDER BY sll.sequence_no,to_number(element.sequence_number);

  Cursor l_ContractSch_Csr Is
                     SELECT sll.sequence_no,sll.chr_id,
                            element.sequence_number, element.date_transaction,
                            element.date_start, element.date_to_interface,
                            element.date_completed, element.amount, element.date_end,
                            element.rul_id
                            FROM oks_level_elements element, oks_stream_levels_b sll
                            WHERE sll.id  = element.rul_id
                            AND sll.chr_id = p_chr_id
                            ORDER BY sll.sequence_no,to_number(element.sequence_number);


  l_LineSch_rec           l_LineSch_Csr%ROWTYPE;
  l_ContractSch_rec       l_ContractSch_Csr%ROWTYPE;
  i                       number;

BEGIN
/* query the records from db for a line or contract and pass then in tbl format to form*/

     -----errorout_ad('Copy_Bill_Sch START');
x_return_status := 'S';

   IF p_chr_id IS NULL and p_cle_id IS NOT NULL THEN         --for line
     i := 1;

     FOR l_LineSch_rec IN l_LineSch_csr
     LOOP
       x_copy_bill_sch(i).Chr_Id                :=  NULL;
       x_copy_bill_sch(i).Cle_Id                :=  l_LineSch_rec.Cle_Id;
       x_copy_bill_sch(i).Strm_Lvl_Seq_Num      :=  l_LineSch_rec.sequence_no;
       x_copy_bill_sch(i).Lvl_Element_Seq_Num   :=  l_LineSch_rec.sequence_number;
       x_copy_bill_sch(i).Tx_Date               :=  l_LineSch_rec.date_transaction;
       x_copy_bill_sch(i).Bill_From_Date        :=  l_LineSch_rec.date_start;
       x_copy_bill_sch(i).Bill_to_Date          :=  l_LineSch_rec.date_end;
       x_copy_bill_sch(i).Interface_Date        :=  l_LineSch_rec.date_to_interface;
       x_copy_bill_sch(i).Date_Completed        :=  l_LineSch_rec.date_completed;
       x_copy_bill_sch(i).Amount                :=  l_LineSch_rec.amount;
       x_copy_bill_sch(i).Rule_Id               :=  l_LineSch_rec.rul_id;


       i := i + 1;
     END LOOP;



   ELSE             ---for contract
     i := 1;
     FOR l_ContractSch_rec IN l_ContractSch_Csr
     LOOP

       x_copy_bill_sch(i).Chr_Id                :=  l_ContractSch_rec.Chr_Id;
       x_copy_bill_sch(i).Strm_Lvl_Seq_Num      :=  l_ContractSch_rec.sequence_no;
       x_copy_bill_sch(i).Lvl_Element_Seq_Num   :=  l_ContractSch_rec.sequence_number;
       x_copy_bill_sch(i).Tx_Date               :=  l_ContractSch_rec.date_transaction;
       x_copy_bill_sch(i).Bill_From_Date        :=  l_ContractSch_rec.date_start;
       x_copy_bill_sch(i).Bill_to_Date          :=  l_contractsch_rec.date_end;
       x_copy_bill_sch(i).Interface_Date        :=  l_ContractSch_rec.date_to_interface;
       x_copy_bill_sch(i).Date_Completed        :=  l_ContractSch_rec.date_completed;
       x_copy_bill_sch(i).Amount                :=  l_ContractSch_rec.amount;
       x_copy_bill_sch(i).Rule_Id               :=  l_ContractSch_rec.rul_id;


       i := i + 1;
     END LOOP;

  END IF;            ---chk for line/subline

  l_currency_code := NULL;
  l_header_billing := NULL;

EXCEPTION
 WHEN OTHERS THEN
       x_return_status := G_RET_STS_UNEXP_ERROR;
END Copy_Bill_Sch;




PROCEDURE Check_Existing_Lvlelement
(
              p_sll_id          IN  Number,
              p_sll_dt_start    IN  Date,
              p_uom            IN  VARCHAR2,
              p_uom_per_period IN  NUMBER,
              p_cp_end_dt       IN  DATE,
              x_next_cycle_dt   OUT NOCOPY DATE,
              x_last_cycle_dt   out NOCOPY Date,
              x_period_counter  out NOCOPY Number,
              x_sch_amt         IN OUT NOCOPY NUMBER,
              x_top_line_bs     IN OUT NOCOPY oks_bill_level_elements_pvt.letv_tbl_type,
              x_return_status   out NOCOPY Varchar2
)

IS


CURSOR l_element_csr(p_sllid Number) IS
                    SELECT id ,date_start,amount,date_end
                    FROM oks_level_elements where rul_id = p_sllid
                    ORDER BY to_number(sequence_number);


----- Bug 5047257 Start
Cursor l_element_count(p_sll_id in number, last_start_date in Date) is
                    select count(a.id) periods from oks_level_elements a, oks_k_lines_b line
                    where a.cle_id = ( select max(parent_cle_id) from oks_level_elements b where rul_id = p_sll_id )
                    and a.date_start <= last_start_date
                    and Line.cle_id = a.cle_id
                    and Line.billing_schedule_type in ('T','E');
----- Bug 5047257 End

Cursor l_element_count1(p_sll_id in number, last_start_date in Date) is
                    select count(a.id) periods from oks_level_elements a, oks_k_lines_b line,
		    oks_stream_levels_b sll1,
                    oks_stream_levels_b sll2
                    where a.cle_id = ( select max(parent_cle_id) from oks_level_elements b where rul_id = p_sll_id )
                    and a.date_start <= last_start_date
                    and a.rul_id = sll1.id
                    and sll1.sequence_no = sll2.sequence_no
                    and sll2.id = p_sll_id
                    and Line.cle_id = a.cle_id
                    and Line.billing_schedule_type in ('T','E');

Cursor l_element_count2(p_sll_id in number, last_start_date in Date) is
                    select count(a.id) periods from oks_level_elements a, oks_k_lines_b line
                    where a.cle_id = ( select max(parent_cle_id) from oks_level_elements b where rul_id = p_sll_id )
                    and a.date_start <= last_start_date
                    and Line.cle_id = a.cle_id
                    and Line.billing_schedule_type in ('T','E');
----- Bug 5047257 End


Cursor date_check_csr(p_sub_cle_id in number) is
                    select count(id) from okc_k_lines_b lin
                    where lin.id = p_sub_cle_id
                    and lin.cle_id in (select top.id from okc_k_lines_b top
                                       where lin.start_date > top.start_date);

Cursor sll_csr(p_top_cle_id in number) is
                    select count(id) from oks_stream_levels_b strm
                    where strm.cle_id = p_top_cle_id;


l_bill_end_date           date;
l_billed_count            Number;
l_element_rec             l_element_csr%rowtype;
l_tbs_ind                 NUMBER;
l_next_cycle_dt           DATE;
l_element_end_dt          DATE;
l_date_start              DATE;
l_end_dt                  DATE;
l_cp_bs_tbl               oks_bill_level_elements_pvt.letv_tbl_type;
l_index                   number;
l_top_line_id             number;
l_sub_line_id             number;
l_line_ctr                number;
l_sll_ctr                 number;

BEGIN

--chk if any billed lvl elemnts exist if yes find the total amt and period counter to start with

l_billed_count := 0;
x_return_status := 'S';

x_period_counter  := 1;
x_return_status   := 'S';
x_last_cycle_dt  := NULL;
x_next_cycle_dt   := p_sll_dt_start;
l_index := 0;

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

   fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.Check_Existing_Lvlelement.dtls',
                      'sll id = ' || p_sll_id
                    ||', sll st dt = ' || p_sll_dt_start
                  );
END IF;
-----errorout_ad('p_sll_dt_start = ' || p_sll_dt_start);
FOR l_element_rec IN l_element_csr(p_sll_id)                   ---billed lvl element for sll
LOOP

   l_billed_count  := l_billed_count + 1;
   x_last_cycle_dt := l_element_rec.date_start;
   x_sch_amt       := nvl(x_sch_amt,0) + nvl(l_element_rec.amount,0);
   x_next_cycle_dt := l_element_rec.date_end + 1;


   IF x_top_line_bs.COUNT > 0 THEN           --tbl will have rec for 'E' and 'T'
     l_index := l_index + 1;

     l_cp_bs_tbl(l_index).id              := l_element_rec.id;
     l_cp_bs_tbl(l_index).date_start      := l_element_rec.date_start;
     l_cp_bs_tbl(l_index).date_end        := l_element_rec.date_end;
     l_cp_bs_tbl(l_index).Amount          := l_element_rec.amount;
   END IF;

END LOOP;
x_period_counter  := l_billed_count + 1;        ---LINE WILL BE INSERTED FROM THIS COUNTER.

   l_line_ctr := 0;
   l_sll_ctr := 0;

   open date_check_csr(l_sub_line_id);
   fetch date_check_csr into l_line_ctr;
   close date_check_csr;

   ---- The count cursor will be invoked only if sub line effectivity is different from Top line
   if l_line_ctr = 1 Then

      open sll_csr(l_top_line_id);
      fetch sll_csr into l_sll_ctr;
      close sll_csr;

	 ------for 2 or more streams
      if l_sll_ctr > 1 Then
         for l_element_rec in l_element_count1(p_sll_id, x_last_cycle_dt ) loop
               IF (l_element_rec.periods=0) THEN
                 exit;
               END IF;
               x_period_counter := l_element_rec.periods+1;
               exit;
          end loop;
      Else
	    ------for single stream only call for the sub line
	    If l_sub_line_id <> l_top_line_id then
            for l_element_rec in l_element_count2(p_sll_id, x_last_cycle_dt ) loop
               IF (l_element_rec.periods=0) THEN
                 exit;
               END IF;
               x_period_counter := l_element_rec.periods+1;
               exit;
            end loop;
		end if;
       END if; --- sll count

    End if;  ----l_line_count = 1 Then

-----errorout_ad('l_cp_bs_tbl.COUNT = '|| l_cp_bs_tbl.COUNT);


--if called from sub line routine then rollup the amount to top line BS tbl
---after matching period.

IF x_top_line_bs.COUNT > 0 AND l_cp_bs_tbl.COUNT > 0 THEN
   l_index := l_cp_bs_tbl.FIRST;


    l_tbs_ind := x_top_line_bs.FIRST;
    l_date_start := l_cp_bs_tbl(l_index ).DATE_START;


    -----errorout_ad('date start = ' || l_date_start);

    WHILE TRUNC(l_date_start) > trunc(x_top_line_bs(l_tbs_ind).DATE_START)
             AND l_tbs_ind < x_top_line_bs.LAST
    LOOP
       -----errorout_ad('TOP LINE BS DATE CHK = ' || x_top_line_bs(l_tbs_ind).DATE_START);
       l_tbs_ind := x_top_line_bs.NEXT(l_tbs_ind);
    END LOOP;

   -----errorout_ad('after while LOOP l_tbs_ind = ' || l_tbs_ind);


    ---chk l_next_cycle_dt if between previous and present record
    IF l_tbs_ind = x_top_line_bs.first THEN
       NULL;

    ELSIF  l_tbs_ind <= x_top_line_bs.LAST  THEN

       -----errorout_ad('COMING IN');
      l_tbs_ind := l_tbs_ind - 1;

      IF  x_top_line_bs(l_tbs_ind ).DATE_end IS NOT NULL THEN
        l_element_end_dt := x_top_line_bs(l_tbs_ind ).DATE_end;

      ELSE

       l_element_end_dt := OKC_TIME_UTIL_PUB.get_enddate
                                    (x_top_line_bs(l_tbs_ind ).DATE_START,
                                     p_uom,
                                     p_uom_Per_Period);
      END IF;


      IF TRUNC(l_date_start) >= TRUNC(x_top_line_bs(l_tbs_ind ).DATE_START)
           AND TRUNC(l_date_start) <= TRUNC(l_element_end_dt) THEN

          NULL;
       ELSE
           l_tbs_ind := l_tbs_ind + 1;
       END IF;

   elsif TRUNC(l_date_start) = TRUNC(x_top_line_bs(l_tbs_ind ).DATE_START) THEN
       l_tbs_ind := x_top_line_bs.first;
   END IF;


   -----errorout_ad('AFTER LOOP  = ' || l_tbs_ind);

   for l_index IN l_cp_bs_tbl.FIRST .. l_cp_bs_tbl.LAST
   LOOP

      IF l_tbs_ind  <= x_top_line_bs.LAST THEN

       IF l_tbs_ind  = x_top_line_bs.LAST THEN
          l_bill_end_date := p_cp_end_dt;
       ELSE

          IF x_top_line_bs(l_tbs_ind ).date_end IS NOT NULL THEN
            l_bill_end_date := x_top_line_bs(l_tbs_ind ).date_end;
          ELSE
            l_bill_end_date := x_top_line_bs(l_tbs_ind + 1).date_start - 1;
          END IF;
       END IF;

       IF x_top_line_bs(l_tbs_ind).date_start <= l_cp_bs_tbl(l_index).date_start
          AND (l_bill_end_date) >= l_cp_bs_tbl(l_index).date_start THEN

          x_top_line_bs(l_tbs_ind).amount := nvl(x_top_line_bs(l_tbs_ind).amount,0) +
                                             nvl(l_cp_bs_tbl(l_index).amount,0);

          l_tbs_ind := l_tbs_ind + 1;

          -----errorout_ad('amount = ' || x_top_line_bs(l_tbs_ind - 1).amount);
          -----errorout_ad('l_tbs_ind = ' || l_tbs_ind);
          -----errorout_ad('l_index = ' || l_index);
       ELSE

          NULL;
       END IF;
     END IF;   ---End of l_tbs_ind  <= x_top_line_bs.LAST condition  added for bug#2655416

 END LOOP;
END IF;                          ----end of both tbl count chk.

IF l_cp_bs_tbl.COUNT > 0 THEN
   x_next_cycle_dt := l_cp_bs_tbl(l_cp_bs_tbl.LAST ).date_end + 1;
   -----errorout_ad('NEXT DATE = ' || x_next_cycle_dt);
END IF;

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

   fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.Check_Existing_Lvlelement.out',
                      'x_next_cycle_dt = ' || x_next_cycle_dt);
END IF;

Exception

WHEN OTHERS then
  IF FND_LOG.LEVEL_UNEXPECTED >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_unexpected,G_MODULE_CURRENT||'.Check_Existing_Lvlelement.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
  END IF;
  x_return_status := 'E';

END Check_Existing_Lvlelement;



FUNCTION Cal_Hdr_Amount
(
              p_contract_id  IN Number
)             Return NUMBER
Is

CURSOR l_total_amt_csr IS
     select SUM(nvl(line.price_negotiated,0) +  nvl(dtl.ubt_amount,0) +
             nvl(dtl.credit_amount,0) +  nvl(dtl.suppressed_credit,0) ) tot_amt
     from oks_k_lines_b dtl, okc_k_lines_b line
     where line.id = dtl.cle_id
     AND line.dnz_chr_id = p_contract_id
     AND lse_id IN(1,12,14,19,46);


l_total_amt_rec        l_total_amt_csr%ROWTYPE;

BEGIN

--it will give the amount for hdr

OPEN l_total_amt_csr;
FETCH l_total_amt_csr INTO l_total_amt_rec;
IF l_total_amt_csr%NOTFOUND THEN
  CLOSE l_total_amt_csr;
  RETURN NULL;
ELSE
  CLOSE l_total_amt_csr;
  RETURN l_total_amt_rec.tot_amt;
end if;


EXCEPTION
 WHEN OTHERS then
   RETURN NULL;

END Cal_Hdr_Amount;


FUNCTION Find_Adjusted_Amount
(
       p_line_id    IN Number,
       p_total_amt  IN Number,
       p_cycle_amt  IN Number
) RETURN Number

IS

CURSOR l_tot_amt_csr IS
       SELECT nvl(SUM(amount),0) tot_amt
       FROM oks_level_elements
       WHERE cle_id = p_line_id;

l_adjusted_amount      number;
l_round_level_amt      number;
l_round_cycle_amt      number;
l_lvlelement_amt       number;
BEGIN

l_lvlelement_amt := 0;

Open l_tot_amt_csr;
Fetch l_tot_amt_csr Into l_lvlelement_amt;

If l_tot_amt_csr%Notfound then
   l_lvlelement_amt := 0;
End If;

Close l_tot_amt_csr;



  l_round_level_amt := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_lvlelement_amt, l_currency_code );
  l_round_cycle_amt := OKS_EXTWAR_UTIL_PVT.round_currency_amt(p_cycle_amt, l_currency_code );

  IF p_total_amt <> l_round_level_amt + l_round_cycle_amt THEN
     l_adjusted_amount := p_total_amt - l_round_level_amt;
  ELSE
     l_adjusted_amount := l_round_cycle_amt;
  END IF;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

        fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.Find_Adjusted_Amount.info',
                      'l_adjusted_amount = ' || l_adjusted_amount
                    ||', line id = ' || p_line_id
                  );
  END IF;

  RETURN l_adjusted_amount;

END Find_Adjusted_Amount;


 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- Added two new parameters p_period_start and p_period_type
 -------------------------------------------------------------------------
PROCEDURE Create_Level_elements(p_billing_type     IN    VARCHAR2,
                                p_sll_tbl          IN    StrmLvl_Out_tbl,
                                p_line_rec         IN    Line_Det_Type,
                                p_invoice_ruleid   IN    Number,
                                p_term_dt          IN    date,
                                p_period_start     IN    VARCHAR2,
                                p_period_type      IN    VARCHAR2,
                                x_return_status    OUT   NOCOPY Varchar2
)
IS

l_line_sll_counter       Number;
l_period_counter         Number;
l_next_cycle_dt          Date;
l_bill_type              Varchar2(10);
l_line_end_date          date;
l_line_amt               NUMBER;
l_chk_round_adjustment   NUMBER;
l_adjusted_amount        NUMBER;
l_lvl_loop_counter       NUMBER;
l_last_cycle_dt          Date;
l_bill_sch_amt           NUMBER := 0;
l_tbl_seq                NUMBER;
l_term_amt               NUMBER;
l_uom_quantity           NUMBER;
l_tce_code               VARCHAR2(100);
l_constant_sll_amt       NUMBER;
l_remaining_amt          NUMBER;
l_dummy_top_line_bs      oks_bill_level_elements_pvt.letv_tbl_type;
l_billed_at_source       OKC_K_HEADERS_ALL_B.BILLED_AT_SOURCE%TYPE;
------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 17-MAY-2005
 -- local variables
-------------------------------------------------------------------------
l_full_period_end_date   DATE;
l_quantity               NUMBER;
l_total_quantity         NUMBER;

l_last_cmp_date          DATE;
--------------------------------------------------------------------------
  --
l_api_version           CONSTANT        NUMBER  := 1.0;
l_init_msg_list         VARCHAR2(2000) := OKC_API.G_FALSE;
l_return_status         VARCHAR2(10);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_msg_index_out         NUMBER;
l_msg_index             NUMBER;

-- Start - Added by PMALLARA - Bug #3992530
Lvl_Element_cnt Number := 0;
Strm_Start_Date  Date;
-- End - Added by PMALLARA - Bug #3992530

BEGIN

  x_return_status := 'S';

  IF p_sll_tbl.COUNT <= 0 THEN
    RETURN;
  END IF;

  l_bill_type :=  p_billing_type;
  l_lvl_ele_tbl_in.delete;
  l_tbl_seq := 1;
  l_bill_sch_amt   := 0;

  l_line_sll_counter := p_sll_tbl.FIRST;

----for T and E, top line amt in lvl_element is always null,amt will be rolled up from sub line lvl elements
--in cp case or subscription line amount is at line lvl only.



  IF  l_bill_type IN ('T','E') AND p_line_rec.chr_id IS  NOT NULL
      AND p_line_rec.lse_id IN (1, 12, 14, 19) THEN

    l_line_amt := NULL;

  ELSIF p_line_rec.chr_id IS  NOT NULL AND p_line_rec.lse_id IN (1, 12, 14, 19) THEN
     l_line_amt :=  p_line_rec.line_amt;

  ELSE                       ----for cp and subscription line (lse_id =46)
     l_line_amt := p_line_rec.line_amt;
  END IF;             --chk for line type


  l_chk_round_adjustment := p_sll_tbl.LAST;

  IF TRUNC(nvl((p_term_dt - 1), p_line_rec.line_end_dt)) > p_line_rec.line_end_dt THEN
    l_line_end_date := p_line_rec.line_end_dt;
  ELSE
    l_line_end_date := TRUNC(nvl((p_term_dt - 1), p_line_rec.line_end_dt));
  END IF;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

        fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.Create_Level_elements.info',
                      'l_chk_round_adjustment = ' || l_chk_round_adjustment
                    ||', l_line_end_date (up to lvl ele)  = ' || l_line_end_date
                    ||', l_bill_type = ' || l_bill_type
                    ||', l_header_billing = ' || l_header_billing
                  );
  END IF;

  IF l_header_billing IS NULL THEN
    ---delete all unbilled elements for a line

    Delete_lvl_element(p_cle_id        => p_line_rec.id,
                     x_return_status => x_return_status);

    IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.Create_Level_elements.del_ele',
                       'Delete_lvl_element(x_return_status = '||x_return_status
                       ||', line id passed = '|| p_line_rec.id ||')');
    END IF;

    -----errorout_ad('Delete_lvl_element status = ' || x_return_status);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
  END IF;

 ---if (line terminated - 1) < line_start_dt
 IF TRUNC(p_line_rec.line_start_dt) > TRUNC(l_line_end_date) or
      TRUNC( p_line_rec.line_start_dt) > trunc(nvl((p_term_dt - 1),p_line_rec.line_end_dt))  THEN

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

        fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.Create_Level_elements.chk',
                      'BS not created as line start dt > line en dt');
     END IF;

     x_return_status := 'S';
     RETURN;
 END IF;

  LOOP                           ---sll rule loop
      -----errorout_ad('sll  start date : '||to_char(p_line_rec.line_start_dt));

    IF l_header_billing IS NOT NULL THEN           ----hdr lvl billing no old sll and lvl elements
       l_next_cycle_dt := TRUNC(p_sll_tbl(l_line_sll_counter).dt_start);
       l_lvl_loop_counter := 1;
       l_period_counter := 1;

    ELSE
       ---to get the counter

       Check_Existing_Lvlelement(
           p_sll_id              =>p_sll_tbl(l_line_sll_counter).id,
           p_sll_dt_start        =>TRUNC(p_sll_tbl(l_line_sll_counter).dt_start),
           p_uom                => null,
           p_uom_per_period     => null,
           p_cp_end_dt           => null,
           x_next_cycle_dt       => l_next_cycle_dt,
           x_last_cycle_dt       => l_last_cycle_dt,
           x_period_counter      => l_period_counter,
           x_sch_amt             => l_bill_sch_amt,
           x_top_line_bs         => l_dummy_top_line_bs,
           x_return_status       => x_return_status);

      -----errorout_ad('LEVEL ELEMENT COUNTER = ' || TO_CHAR(l_period_counter));
      -----errorout_ad('LEVEL ELEMENT START DATE = ' || to_char(l_next_cycle_dt));

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_lvl_loop_counter := l_period_counter;
   END IF;

    IF l_period_counter > to_number(p_sll_tbl(l_line_sll_counter).level_period) THEN

      IF l_line_sll_counter + 1 <= p_sll_tbl.LAST THEN
          l_next_cycle_dt := TRUNC(p_sll_tbl(l_line_sll_counter + 1).dt_start);
      ELSE

          l_next_cycle_dt := OKC_TIME_UTIL_PUB.get_enddate
                                          (TRUNC(p_sll_tbl(l_line_sll_counter).dt_start),
                                           p_sll_tbl(l_line_sll_counter).uom,
                                           (p_sll_tbl(l_line_sll_counter).uom_Per_Period *
                                            p_sll_tbl(l_line_sll_counter).level_period ));

           l_next_cycle_dt := l_next_cycle_dt + 1;
       END IF;        --if sll counter <= last

    ELSE                 --period counter <= lvl period

        -----errorout_ad('last date = ' || TO_CHAR(l_last_cycle_dt));
        -----errorout_ad('uom = ' || p_sll_tbl(l_line_sll_counter).uom);
        -----errorout_ad('uom = ' || p_sll_tbl(l_line_sll_counter).uom_Per_Period);
       IF L_next_cycle_dt IS null THEN


          L_next_cycle_dt := OKC_TIME_UTIL_PUB.get_enddate
                                           (l_last_cycle_dt,
                                            p_sll_tbl(l_line_sll_counter).uom,
                                            p_sll_tbl(l_line_sll_counter).uom_Per_Period);

        -----errorout_ad('next_cycle_date = ' || to_char(l_next_cycle_dt));

        l_next_cycle_dt := l_next_cycle_dt + 1;
       END IF;      --next cycle dt is null

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

        fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.Create_Level_elements.loop_info',
                      'L_next_cycle_dt = ' || L_next_cycle_dt
                    ||', last date = ' || l_last_cycle_dt
                    ||', uom = ' || p_sll_tbl(l_line_sll_counter).uom
                );
     END IF;

      IF TRUNC(l_next_cycle_dt) > l_line_end_date THEN
         x_return_status := 'S';
         RETURN;
      END IF;

       IF  l_bill_type = 'T' AND p_line_rec.lse_id = 46 THEN
          OKS_BILL_UTIL_PUB.get_seeded_timeunit(
                p_timeunit      => p_sll_tbl(l_line_sll_counter).uom,
                x_return_status => x_return_status,
                x_quantity      => l_uom_quantity ,
                x_timeunit      => l_tce_code);

          IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.Create_Level_elements.seed_time',
                       'OKS_BILL_UTIL_PUB.get_seeded_timeunit(x_return_status = '||x_return_status
                       ||', x_timeunit = ' || l_tce_code
                       ||', x_quantity = '|| l_uom_quantity ||')');
          END IF;

          IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
              RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;

             l_remaining_amt := nvl(l_line_amt,0) - nvl(l_bill_sch_amt,0);

             Get_Constant_sll_Amount(p_line_start_date      => p_line_rec.line_start_dt,
                                 p_line_end_date         => p_line_rec.line_end_dt,
                                 p_cycle_start_date      => l_next_cycle_dt,
                                 p_remaining_amount      => l_remaining_amt,
                                 P_uom_quantity          => l_uom_quantity,
                                 P_tce_code              => l_tce_code,
                                 x_constant_sll_amt      => l_constant_sll_amt,
                                 x_return_status         => x_return_status);

          --errorout_ad('shd not enter Get_Constant_sll_Amount = ' || x_return_status);


          IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.Create_Level_elements.sll_amt',
                       'Get_Constant_sll_Amount(x_return_status = '||x_return_status
                       ||', sll amt = ' || l_constant_sll_amt
                       ||', l_remaining_amt passed  = '|| l_remaining_amt ||')');
          END IF;

          IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
              RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
      END IF;              ---end of lse_id = 46

      OKS_BILL_UTIL_PUB.Get_Seeded_Timeunit
                    (p_timeunit      => p_sll_tbl(l_line_sll_counter).uom,
                     x_return_status => x_return_status,
                     x_quantity      => l_uom_quantity ,
                     x_timeunit      => l_tce_code);
     IF x_return_status <> 'S' THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;


-- Start - Added by PMALLARA - Bug #3992530
    Lvl_Element_cnt  :=   l_period_counter - 1;
    Strm_Start_Date  :=   p_sll_tbl(l_line_sll_counter).dt_start;
      LOOP                          -------------for level elements of one rule
    Lvl_Element_cnt  :=     Lvl_Element_cnt + 1;
-- End - Added by PMALLARA - Bug #3992530

        l_fnd_lvl_in_rec.line_start_date           := p_line_rec.line_start_dt;
        l_fnd_lvl_in_rec.line_end_date             := nvl((p_term_dt-1),p_line_rec.line_end_dt);
        l_fnd_lvl_in_rec.cycle_start_date          := l_next_cycle_dt;
-- Start - Modified by PMALLARA - Bug #3992530
        l_fnd_lvl_in_rec.tuom_per_period           := Lvl_Element_cnt * p_sll_tbl(l_line_sll_counter).uom_Per_Period;
-- End - Modified by PMALLARA - Bug #3992530
        l_fnd_lvl_in_rec.tuom                      := p_sll_tbl(l_line_sll_counter).uom;
        l_fnd_lvl_in_rec.total_amount              := nvl(l_line_amt,0) - nvl(l_bill_sch_amt,0);
        l_fnd_lvl_in_rec.invoice_offset_days        := p_sll_tbl(l_line_sll_counter).invoice_offset_days;
        l_fnd_lvl_in_rec.interface_offset_days     := p_sll_tbl(l_line_sll_counter).Interface_offset_days;
        l_fnd_lvl_in_rec.bill_type                 := l_bill_type;
        --mchoudha added this parameter
        l_fnd_lvl_in_rec.uom_per_period            := p_sll_tbl(l_line_sll_counter).uom_Per_Period;
        -----errorout_ad(' p_Line_rec.line_start_dt :' || to_char(p_line_rec.line_start_dt));
        -----errorout_ad(' p_Line_rec.line_end_dt :' || to_char(p_line_rec.line_end_dt));
        -----errorout_ad(' l_line_amt :' || l_line_amt);
        -----errorout_ad(' OKS_BILL_UTIL_PUB.Get_next_bill_sch for line passed period :' || to_char(l_fnd_lvl_in_rec.uom_per_period));
        -----errorout_ad(' OKS_BILL_UTIL_PUB.Get_next_bill_sch for line passed uom :' || l_fnd_lvl_in_rec.uom);
        -----errorout_ad(' OKS_BILL_UTIL_PUB.Get_next_bill_sch for line passed cycle_start_date:' || to_char(l_fnd_lvl_in_rec.cycle_start_date));

 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- Added two new parameters p_period_start and p_period_type
        -- Start - Modified by PMALLARA - Bug #3992530
        IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_procedure,G_MODULE_CURRENT||'.Create_Level_elements.lvl_loop',
                       'Calling oks_bill_util_pub.Get_next_bill_sch with parameters '
                       ||'period start = ' || p_period_start
                       ||', period type = ' || p_period_type);
        END IF;

        OKS_BILL_UTIL_PUB.Get_next_bill_sch
          (p_api_version             => l_api_version,
           x_return_status           => x_return_status,
           x_msg_count               => l_msg_count,
           x_msg_data                => l_msg_data,
           p_invoicing_rule_id       => p_invoice_ruleid,
           p_bill_sch_detail_rec     => l_fnd_lvl_in_rec,
           x_bill_sch_detail_rec     => l_fnd_lvl_out_rec,
           p_period_start            => p_period_start,
           p_period_type             => p_period_type,
           Strm_Start_Date           => Strm_Start_Date);
        -- End - Modified by PMALLARA - Bug #3992530


        IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.Create_Level_elements.lvl_loop',
                       'oks_bill_util_pub.Get_next_bill_sch(x_return_status = '||x_return_status
                       ||', next date = ' || l_fnd_lvl_out_rec.next_cycle_date
                       ||', tuom per period = ' || l_fnd_lvl_in_rec.tuom_per_period
                       ||', cycle_start_date  = '|| l_next_cycle_dt ||')');
        END IF;


        -----errorout_ad('LEVEL ELEMENT NEXT CYCLE DATE passed from Get_next_bill_sch = ' || TO_CHAR(l_fnd_lvl_out_rec.next_cycle_date));

        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -----errorout_ad(' OKS_BILL_UTIL_PUB.Get_next_bill_sch = ' || l_msg_data);
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          -----errorout_ad(' OKS_BILL_UTIL_PUB.Get_next_bill_sch = ' || l_msg_data);
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;


        IF p_period_start is not null AND
           p_period_type is not null  THEN
           l_last_cmp_date := l_line_end_date;
        ELSE
           l_last_cmp_date := p_line_rec.line_end_dt;
        END IF;

        IF TRUNC(l_fnd_lvl_out_rec.next_cycle_date) < p_Line_rec.line_start_dt then
          null;                       ---donot insert record in level element
        ELSE

          IF  l_bill_type IN ('T','E') AND p_line_rec.lse_id <> 46 THEN
             l_adjusted_amount := NULL;
          --errorout_ad('l_bill_type IN T,E AND p_line_rec.lse_id <> 46 ');
          ELSIF l_bill_type = 'T' AND p_line_rec.lse_id = 46 THEN
                   --errorout_ad('l_bill_type = T AND p_line_rec.lse_id = 46 ');
             IF (l_line_sll_counter = l_chk_round_adjustment AND
                l_lvl_loop_counter = p_sll_tbl(l_chk_round_adjustment).level_period) OR
                --Mani PPC changing p_line_rec.line_end_dt to l_last_cmp_date
                (TRUNC(l_fnd_lvl_out_rec.next_cycle_date) > l_last_cmp_date) THEN

               l_adjusted_amount  := nvl(l_line_amt,0) - nvl(l_bill_sch_amt,0);

             ELSE        --not adjustment round
               l_adjusted_amount  := l_constant_sll_amt;
             END IF;

          ELSIF (l_bill_type = 'E' AND p_line_rec.lse_id = 46)
               OR l_bill_type = 'P' THEN
             --errorout_ad('(l_bill_type = E AND p_line_rec.lse_id = 46          OR l_bill_type = P');
             IF (l_line_sll_counter = l_chk_round_adjustment AND
                l_lvl_loop_counter = p_sll_tbl(l_chk_round_adjustment).level_period) OR
                --Mani PPC changing p_line_rec.line_end_dt to l_last_cmp_date
                (TRUNC(l_fnd_lvl_out_rec.next_cycle_date) > l_last_cmp_date) THEN

               l_adjusted_amount  := nvl(l_line_amt,0) - nvl(l_bill_sch_amt,0);

             ELSE            --not adjustment round
               ------------------------------------------------------------------------
               -- Begin partial period computation logic
               -- Developer Mani Choudhary
               -- Date 17-MAY-2005
               -- For Covered level and subscription calculate the billing schedule amount
               -- for the first partial period.
               -------------------------------------------------------------------------

               IF  p_period_start = 'CALENDAR'                              AND
                   p_period_start IS NOT NULL                               AND
                   p_period_type IS NOT NULL                                AND
                   TRUNC(l_next_cycle_dt,'MM') <> TRUNC(l_next_cycle_dt)
               THEN
                   --New parameters in Bold
                  IF l_tce_code not in ('DAY','HOUR','MINUTE') THEN
                    l_quantity := OKS_TIME_MEASURES_PUB.get_quantity
                                              (p_start_date   => l_next_cycle_dt,
                                               p_end_date     => TRUNC(l_fnd_lvl_out_rec.next_cycle_date)-1,
                                               p_source_uom   => l_fnd_lvl_in_rec.tuom  ,
                                               p_period_type  => p_period_type,
                                               p_period_start => p_period_start);

                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                       fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Create_Level_elements.Calendar',
                       'after calling OKS_TIME_MEASURES_PUB.get_quantity with p_period_type '||p_period_type||' ,p_period_start '||p_period_start
                       ||' result l_quantity = ' || l_quantity);
                    END IF;

                     IF nvl(l_quantity,0) = 0 THEN
                       RAISE G_EXCEPTION_HALT_VALIDATION;
                     END IF;


                    l_adjusted_amount :=p_sll_tbl(l_line_sll_counter).amount*l_quantity/l_fnd_lvl_in_rec.uom_per_period; --bugfix 5485442

                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                       fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Create_Level_elements.Calendar',
                       'after calling OKS_TIME_MEASURES_PUB.get_quantity  '
                       ||' result l_adjusted_amount = ' || l_adjusted_amount);
                    END IF;
                   --mchoudha fix for bug#5200003
                   ELSE
                      l_adjusted_amount := nvl( p_sll_tbl(l_line_sll_counter).amount*((TRUNC(l_fnd_lvl_out_rec.next_cycle_date)-TRUNC(l_next_cycle_dt))/l_uom_quantity)/l_fnd_lvl_in_rec.uom_per_period,0); --bugfix 5485442

                   END IF;
                 ELSE
                    l_adjusted_amount  := p_sll_tbl(l_line_sll_counter).amount;
                 END IF; --period start and period type not null
             END IF;     --l_line_sll_counter = l_chk_round_adjustment
          END IF;        --IF TRUNC(l_fnd_lvl_out_rec.next_cycle_date) < p_Line_rec.line_start_dt

           --insert in lvl element tbl


          l_lvl_ele_tbl_in(l_tbl_seq).sequence_number        :=  to_char(l_period_counter);
          l_lvl_ele_tbl_in(l_tbl_seq).dnz_chr_id             :=  p_line_rec.dnz_chr_id;
          l_lvl_ele_tbl_in(l_tbl_seq).cle_id                 :=  p_line_rec.id;

          IF p_line_rec.lse_id IN (1,12,14,19,46) THEN
             l_lvl_ele_tbl_in(l_tbl_seq).parent_cle_id       :=  p_line_rec.id;
          ELSE             ---subline
             l_lvl_ele_tbl_in(l_tbl_seq).parent_cle_id       :=  p_line_rec.cle_id;
          END IF;


          IF l_next_cycle_dt < p_Line_rec.line_start_dt THEN
             l_lvl_ele_tbl_in(l_tbl_seq).date_start           :=   TRUNC(p_Line_rec.line_start_dt);
          ELSE
             l_lvl_ele_tbl_in(l_tbl_seq).date_start           :=   TRUNC(l_next_cycle_dt);
          END IF;
          l_lvl_ele_tbl_in(l_tbl_seq).date_end                := TRUNC(l_fnd_lvl_out_rec.next_cycle_date) - 1;


          IF l_bill_type IN ('T','E') AND p_Line_rec.lse_id <> 46 THEN
            ----FOR T,E AND TOP LINE amt should be null to shoW rollup amt

            IF p_Line_rec.chr_id IS  NOT NULL THEN    --top line
              l_lvl_ele_tbl_in(l_tbl_seq).amount             :=   NULL;
            ELSE                      ----cp level
              l_lvl_ele_tbl_in(l_tbl_seq).amount             :=  OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_adjusted_amount,l_currency_code );
            END IF;

          ELSE                     ----for billing type = p and lse_id = 46

            l_lvl_ele_tbl_in(l_tbl_seq).amount               := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_adjusted_amount,l_currency_code );
          END IF;


          l_lvl_ele_tbl_in(l_tbl_seq).date_receivable_gl     :=   l_fnd_lvl_out_rec.date_recievable_gl;
          l_lvl_ele_tbl_in(l_tbl_seq).date_transaction       :=   TRUNC(l_fnd_lvl_out_rec.date_transaction);
          l_lvl_ele_tbl_in(l_tbl_seq).date_due               :=   l_fnd_lvl_out_rec.date_due;
          l_lvl_ele_tbl_in(l_tbl_seq).date_print             :=   l_fnd_lvl_out_rec.date_print;
          l_lvl_ele_tbl_in(l_tbl_seq).date_to_interface      :=   TRUNC(l_fnd_lvl_out_rec.date_to_interface);

          SELECT nvl(BILLED_AT_SOURCE , 'N')
	    INTO l_billed_at_source
	    FROM OKC_K_HEADERS_ALL_B
	   WHERE id = p_line_rec.dnz_chr_id;

	   if l_billed_at_source = 'Y' Then
              l_lvl_ele_tbl_in(l_tbl_seq).date_completed  := sysdate;
           else
              l_lvl_ele_tbl_in(l_tbl_seq).date_completed := l_fnd_lvl_out_rec.date_completed;
           end if;

          l_lvl_ele_tbl_in(l_tbl_seq).rul_id                 :=   p_sll_tbl(l_line_sll_counter).id;

          l_lvl_ele_tbl_in(l_tbl_seq).object_version_number  := OKC_API.G_MISS_NUM;
          l_lvl_ele_tbl_in(l_tbl_seq).created_by             := OKC_API.G_MISS_NUM;
          l_lvl_ele_tbl_in(l_tbl_seq).creation_date          := SYSDATE;
          l_lvl_ele_tbl_in(l_tbl_seq).last_updated_by        := OKC_API.G_MISS_NUM;
          l_lvl_ele_tbl_in(l_tbl_seq).last_update_date       := SYSDATE;


          -----errorout_ad ('Amount for line lvl element = ' || to_char(l_lvl_ele_tbl_in(l_tbl_seq).amount ));
      IF p_period_start is  null OR
         p_period_type is  null THEN

          IF p_term_dt IS NOT NULL AND TRUNC(l_lvl_ele_tbl_in(l_tbl_seq).date_start) < TRUNC(p_term_dt) AND
            TRUNC(l_fnd_lvl_out_rec.next_cycle_date) > TRUNC(p_term_dt) AND
            p_term_dt <=  p_Line_rec.line_end_dt  THEN

            l_lvl_ele_tbl_in(l_tbl_seq).date_end              := (p_term_dt - 1);

            IF l_bill_type = 'P' OR  p_Line_rec.lse_id = 46 THEN

              -----errorout_ad('going to calculate l_term_amt');
              IF TRUNC(l_fnd_lvl_out_rec.next_cycle_date - 1 ) >  p_Line_rec.line_end_dt THEN

                      l_term_amt := Find_term_amt(p_cycle_st_dt  =>  l_lvl_ele_tbl_in(l_tbl_seq).date_start,
                                       p_term_dt      =>  p_term_dt,
                                       p_cycle_end_dt =>  p_Line_rec.line_end_dt,
                                       p_amount       =>  nvl(l_lvl_ele_tbl_in(l_tbl_seq).amount,0));


                      IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.Create_Level_elements.term_period',
                        'find_term_amt(x_return_status = '||x_return_status
                         ||', l_term_amt = ' || l_term_amt
                         ||', p_cycle_st_dt = ' || l_lvl_ele_tbl_in(l_tbl_seq).date_start
                         ||', p_term_dt = ' || p_Line_rec.line_end_dt
                         ||', lvl amt = ' || nvl(l_lvl_ele_tbl_in(l_tbl_seq).amount,0)
                         ||', p_cycle_end_dt  = '|| l_next_cycle_dt ||')');
                      END IF;

              ELSE
                       l_term_amt := Find_term_amt(p_cycle_st_dt  =>  l_lvl_ele_tbl_in(l_tbl_seq).date_start,
                                                   p_term_dt      =>  p_term_dt,
                                                   p_cycle_end_dt =>  l_fnd_lvl_out_rec.next_cycle_date - 1,
                                                   p_amount       =>  nvl(l_lvl_ele_tbl_in(l_tbl_seq).amount,0));

                       IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
                          fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.Create_Level_elements.term_period',
                           'find_term_amt(x_return_status = '||x_return_status
                           ||', l_term_amt = ' || l_term_amt
                           ||', p_cycle_st_dt = ' || l_lvl_ele_tbl_in(l_tbl_seq).date_start
                           ||', p_term_dt = ' || p_Line_rec.line_end_dt
                           ||', lvl amt = ' || nvl(l_lvl_ele_tbl_in(l_tbl_seq).amount,0)
                           ||', p_cycle_end_dt  = '|| l_fnd_lvl_out_rec.next_cycle_date - 1 ||')');
                       END IF;  -- fnd_log.level_event >= fnd_log.g_current_runtime_level
              END IF;           -- TRUNC(l_fnd_lvl_out_rec.next_cycle_date - 1 ) >  p_Line_rec.line_end_dt


              l_lvl_ele_tbl_in(l_tbl_seq).amount  := l_term_amt;
            END IF;       -----end of cal of term amt.
          END IF;             ----end of lvlelement end date assign
        END IF; --period start null or period type null

          l_period_counter := l_period_counter + 1;
          l_bill_sch_amt := nvl(l_bill_sch_amt,0) + nvl(l_lvl_ele_tbl_in(l_tbl_seq).amount,0);
          l_tbl_seq      := l_tbl_seq + 1;
        END IF;          -----end if for level element creation

        l_next_cycle_dt  := l_fnd_lvl_out_rec.next_cycle_date;

        EXIT WHEN (l_lvl_loop_counter = to_number(p_sll_tbl(l_line_sll_counter).level_period)) OR
                  (TRUNC(l_next_cycle_dt) > l_line_end_date);

        l_lvl_loop_counter := l_lvl_loop_counter + 1;

       END LOOP;                   ---loop for sll period counter

      END IF;                      ----Period counter checking before entering in loop for lvlelement

    -----errorout_ad('l_next_cycle_dt = ' || TO_CHAR(l_next_cycle_dt));
    -----errorout_ad('LINE END DATE = ' || TO_CHAR(p_Line_rec.line_end_dt));


    EXIT WHEN (l_line_sll_counter = p_sll_tbl.LAST) OR
              (TRUNC(l_next_cycle_dt) > l_line_end_date);

    l_line_sll_counter := p_sll_tbl.NEXT(l_line_sll_counter);

  END LOOP;                    -----loop for sll lines

  IF l_lvl_ele_tbl_in.COUNT > 0 THEN
     IF l_lvl_ele_tbl_in(l_lvl_ele_tbl_in.LAST).date_end > p_line_rec.line_end_dt THEN
       l_lvl_ele_tbl_in(l_lvl_ele_tbl_in.LAST).date_end := p_line_rec.line_end_dt;
     END IF;

     OKS_BILL_LEVEL_ELEMENTS_PVT.insert_row(
               p_api_version                  => l_api_version,
               p_init_msg_list                => l_init_msg_list,
               x_return_status                => x_return_status,
               x_msg_count                    => l_msg_count,
               x_msg_data                     => l_msg_data,
               p_letv_tbl                     => l_lvl_ele_tbl_in,
               x_letv_tbl                     => l_lvl_ele_tbl_out);

     IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.Create_Level_elements.insert',
                       'oks_bill_level_elements_pvt.insert_row(x_return_status = '||x_return_status
                       ||', l_lvl_ele_tbl_out  = '|| l_lvl_ele_tbl_out.count ||')');
     END IF;

    -----errorout_ad('LEVEL ELEMENT INSERT STATUS line = ' || x_return_status);


      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         -----errorout_ad('OKS_BILL_LEVEL_ELEMENTS_PVT.insert_row for line = ' || l_msg_data);
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         -----errorout_ad('OKS_BILL_LEVEL_ELEMENTS_PVT.insert_row for line = ' || l_msg_data);
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
   END IF;


EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
        x_return_status := G_RET_STS_ERROR;
 WHEN OTHERS THEN

     IF FND_LOG.LEVEL_UNEXPECTED >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_unexpected,G_MODULE_CURRENT||'.Create_Level_elements.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
      END IF;
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;
END Create_Level_elements;


 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- Added two new parameters p_period_start and p_period_type
 -------------------------------------------------------------------------
PROCEDURE Create_Hdr_Level_elements(
                                p_billing_type     IN    VARCHAR2,
                                p_sll_tbl          IN    StrmLvl_Out_tbl,
                                p_hdr_rec          IN    Contract_Rec_Type,
                                p_invoice_ruleid   IN    Number,
                                p_called_from      IN    NUMBER,
                                p_period_start     IN   VARCHAR2,
                                p_period_type      IN   VARCHAR2,
                                x_return_status    OUT   NOCOPY Varchar2
)
IS

l_sll_counter            Number;
l_tbl_seq                Number;
l_next_cycle_dt          Date;
l_lvl_loop_counter       NUMBER;
l_cycle_amt              number;
l_bill_type              VARCHAR2(10);

  --
l_api_version           CONSTANT        NUMBER  := 1.0;
l_init_msg_list         VARCHAR2(2000) := OKC_API.G_FALSE;
l_return_status         VARCHAR2(10);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_msg_index_out         NUMBER;
l_msg_index             NUMBER;
i                       number;

-- Start - Added by PMALLARA - Bug #3992530
Lvl_Element_cnt Number := 0;
Strm_Start_Date  Date;
-- End - Added by PMALLARA - Bug #3992530

BEGIN

  --l_hdr_end_date := p_hdr_rec.end_dt;
x_return_status := 'S';

  l_lvl_ele_tbl_in.delete;
  l_tbl_seq := 1;
  l_sll_counter := p_sll_tbl.FIRST;
  l_bill_type := p_billing_type;


IF p_called_from = 1 THEN
  --delete lvl lements for hdr and all (sll and lvl elemnts) of top lines and cp.

  Del_hdr_lvl_element(p_hdr_id        => p_hdr_rec.id,
                      x_return_status => x_return_status);


  IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.Create_Hdr_Level_elements.del_ele',
                       'Del_hdr_lvl_element(x_return_status = '||x_return_status
                       ||', p_hdr_id passed = '||p_hdr_rec.id ||')');
  END IF;

  -----errorout_ad('Del_hdr_lvl_element status = ' || x_return_status);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
     RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
END IF;


LOOP                           ---sll rule loop
      -----errorout_ad('sll rule start date : '||to_char(p_line_rec.line_start_dt));

    l_next_cycle_dt := p_sll_tbl(l_sll_counter).dt_start;
    l_lvl_loop_counter := 1;


-- Start - Added by PMALLARA - Bug #3992530
    Lvl_Element_cnt  := 0;
      LOOP                          -------------for level elements of one rule
    Lvl_Element_cnt  :=     Lvl_Element_cnt + 1;
    if Lvl_Element_cnt = 1 then
        Strm_Start_Date :=   l_next_cycle_dt;
    end if;
-- End - Added by PMALLARA - Bug #3992530

        l_fnd_lvl_in_rec.line_start_date           := p_hdr_rec.start_dt;
        l_fnd_lvl_in_rec.line_end_date             := p_hdr_rec.end_dt;
        l_fnd_lvl_in_rec.cycle_start_date          := l_next_cycle_dt;
-- Start - Modified by PMALLARA - Bug #3992530
        l_fnd_lvl_in_rec.tuom_per_period           := Lvl_Element_cnt * p_sll_tbl(l_sll_counter).uom_Per_Period;
-- End - Modified by PMALLARA - Bug #3992530
        l_fnd_lvl_in_rec.tuom                      := p_sll_tbl(l_sll_counter).uom;
        l_fnd_lvl_in_rec.total_amount              := 0;
        l_fnd_lvl_in_rec.invoice_offset_days        := p_sll_tbl(l_sll_counter).invoice_offset_days;
        l_fnd_lvl_in_rec.interface_offset_days     := p_sll_tbl(l_sll_counter).Interface_offset_days;
        l_fnd_lvl_in_rec.bill_type                 := l_bill_type;
        --mchoudha added this parameter
        l_fnd_lvl_in_rec.uom_per_period            := p_sll_tbl(l_sll_counter).uom_Per_Period;

 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- Added two new parameters p_period_start and p_period_type
        -- Start - Modified by PMALLARA - Bug #3992530
        OKS_BILL_UTIL_PUB.Get_next_bill_sch
          (p_api_version             => l_api_version,
           x_return_status           => x_return_status,
           x_msg_count               => l_msg_count,
           x_msg_data                => l_msg_data,
           p_invoicing_rule_id       => p_invoice_ruleid,
           p_bill_sch_detail_rec     => l_fnd_lvl_in_rec,
           x_bill_sch_detail_rec     => l_fnd_lvl_out_rec,
           p_period_start            =>  p_period_start,
           p_period_type             =>  p_period_type,
           Strm_Start_Date           => Strm_Start_Date);
        -- End - Modified by PMALLARA - Bug #3992530

       IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_hdr_level_elements.lvl_loop',
                       'oks_bill_util_pub.Get_next_bill_sch(x_return_status = '||x_return_status
                       ||', next date = ' || l_fnd_lvl_out_rec.next_cycle_date
                       ||', tuom per period = ' || l_fnd_lvl_in_rec.tuom_per_period
                       ||', cycle_start_date  = '|| l_next_cycle_dt ||')');
        END IF;

        -----errorout_ad('hdr Get_next_bill_sch status = ' || x_return_status);

        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -----errorout_ad(' OKS_BILL_UTIL_PUB.Get_next_bill_sch = ' || l_fnd_msg_data);
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          -----errorout_ad(' OKS_BILL_UTIL_PUB.Get_next_bill_sch = ' || l_fnd_msg_data);
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;



        IF TRUNC(l_fnd_lvl_out_rec.next_cycle_date) < p_hdr_rec.start_dt then
          NULL;                       ---donot insert record in level element
        ELSE

          -----errorout_ad('l_lvl_loop_counter = ' || l_lvl_loop_counter);
          -----errorout_ad('l_tbl_seq = ' || l_tbl_seq);

          l_lvl_ele_tbl_in(l_tbl_seq).sequence_number        :=   to_char(l_lvl_loop_counter);
          l_lvl_ele_tbl_in(l_tbl_seq).dnz_chr_id             :=   p_hdr_rec.id;
          l_lvl_ele_tbl_in(l_tbl_seq).date_start             :=   TRUNC(l_next_cycle_dt);
          l_lvl_ele_tbl_in(l_tbl_seq).date_end               :=   TRUNC(l_fnd_lvl_out_rec.next_cycle_date) - 1;

          IF l_bill_type = 'T' then
            ----FOR T amt should be null
            l_lvl_ele_tbl_in(l_tbl_seq).amount               :=   NULL;

          ELSE                     ----for E

            l_cycle_amt  := TO_NUMBER(p_sll_tbl(l_sll_counter).amount);
            l_lvl_ele_tbl_in(l_tbl_seq).amount               :=   OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_cycle_amt,l_currency_code );
          END IF;


          l_lvl_ele_tbl_in(l_tbl_seq).date_receivable_gl     :=   l_fnd_lvl_out_rec.date_recievable_gl;
          l_lvl_ele_tbl_in(l_tbl_seq).date_transaction       :=   TRUNC(l_fnd_lvl_out_rec.date_transaction);
          l_lvl_ele_tbl_in(l_tbl_seq).date_due               :=   l_fnd_lvl_out_rec.date_due;
          l_lvl_ele_tbl_in(l_tbl_seq).date_print             :=   l_fnd_lvl_out_rec.date_print;
          l_lvl_ele_tbl_in(l_tbl_seq).date_to_interface      :=   TRUNC(l_fnd_lvl_out_rec.date_to_interface);
          l_lvl_ele_tbl_in(l_tbl_seq).date_completed         :=   l_fnd_lvl_out_rec.date_completed;
          l_lvl_ele_tbl_in(l_tbl_seq).rul_id                 :=   p_sll_tbl(l_sll_counter).id;

          l_lvl_ele_tbl_in(l_tbl_seq).object_version_number  := OKC_API.G_MISS_NUM;
          l_lvl_ele_tbl_in(l_tbl_seq).created_by             := OKC_API.G_MISS_NUM;
          l_lvl_ele_tbl_in(l_tbl_seq).creation_date          := SYSDATE;
          l_lvl_ele_tbl_in(l_tbl_seq).last_updated_by        := OKC_API.G_MISS_NUM;
          l_lvl_ele_tbl_in(l_tbl_seq).last_update_date       := SYSDATE;

          l_tbl_seq := l_tbl_seq + 1;

        END IF;          -----end if for level element creation

        l_next_cycle_dt  := l_fnd_lvl_out_rec.next_cycle_date;

        EXIT WHEN (l_lvl_loop_counter = to_number(p_sll_tbl(l_sll_counter).level_period)) OR
                  (TRUNC(l_next_cycle_dt) > p_hdr_rec.end_dt);

        l_lvl_loop_counter := l_lvl_loop_counter + 1;

       END LOOP;                   ---loop for sll period counter


    EXIT WHEN (l_sll_counter = p_sll_tbl.LAST) OR
              (TRUNC(l_next_cycle_dt) > p_hdr_rec.end_dt);

    l_sll_counter := p_sll_tbl.NEXT(l_sll_counter);

  END LOOP;                    -----loop for sll lines

  IF l_lvl_ele_tbl_in.COUNT > 0 THEN

    OKS_BILL_LEVEL_ELEMENTS_PVT.insert_row(
               p_api_version                  => l_api_version,
               p_init_msg_list                => l_init_msg_list,
               x_return_status                => x_return_status,
               x_msg_count                    => l_msg_count,
               x_msg_data                     => l_msg_data,
               p_letv_tbl                     => l_lvl_ele_tbl_in,
               x_letv_tbl                     => l_lvl_ele_tbl_out);

    IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_hdr_level_elements.insert',
                       'oks_bill_level_elements_pvt.insert_row(x_return_status = '||x_return_status
                     ||', l_lvl_ele_tbl_out  = '|| l_lvl_ele_tbl_out.count ||')');
     END IF;


    -----errorout_ad('LEVEL ELEMENT INSERT STATUS = ' || x_return_status);


    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      -----errorout_ad('OKS_BILL_LEVEL_ELEMENTS_PVT.insert_row = ' || l__msg_data);
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      -----errorout_ad('OKS_BILL_LEVEL_ELEMENTS_PVT.insert_row = ' || l_msg_data);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
  END IF;



EXCEPTION
 WHEN OTHERS THEN
     IF FND_LOG.LEVEL_UNEXPECTED >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_unexpected,G_MODULE_CURRENT||'.create_hdr_level_elements.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
      END IF;
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;
END Create_Hdr_Level_elements;

FUNCTION Find_Currency_Code
(        p_cle_id  NUMBER,
         p_chr_id  NUMBER
)
RETURN VARCHAR2
IS

CURSOR l_line_cur IS
       SELECT contract.currency_code
       FROM okc_k_headers_b contract, okc_k_lines_b line
       WHERE contract.id = line.dnz_chr_id and line.id = p_cle_id;

CURSOR l_hdr_cur IS
       SELECT contract.currency_code
       FROM okc_k_headers_b contract
       WHERE contract.id = p_chr_id;


l_Currency  VARCHAR2(15);

BEGIN

IF p_chr_id IS NULL THEN       ---called for line
   OPEN l_line_cur;
   FETCH l_line_cur INTO l_currency;

   IF l_line_cur%NOTFOUND THEN
     l_Currency := NULL;
   END IF;

   Close l_line_cur;

ELSE                   ---FOR HEADER

   OPEN l_hdr_cur;
   FETCH l_hdr_cur INTO l_currency;

   IF l_hdr_cur%NOTFOUND THEN
     l_Currency := NULL;
   END IF;

   Close l_hdr_cur;

END IF;

RETURN l_Currency;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RETURN NULL;

END Find_Currency_Code;


Procedure Update_Sll_Amount
(
          p_line_id         IN    NUMBER,
          x_return_status   OUT   NOCOPY Varchar2
)
IS

Cursor l_Line_Csr Is
  SELECT line.chr_id chr_id, line.dnz_chr_id dnz_chr_id,  line.lse_id lse_id,
        TRUNC(line.start_date) line_start_dt, TRUNC(line.end_date) line_end_dt,
        (nvl(line.price_negotiated,0) +  nvl(dtl.ubt_amount,0) +
         nvl(dtl.credit_amount,0) +  nvl(dtl.suppressed_credit,0) ) line_amt
  FROM okc_k_lines_b line, oks_k_lines_b dtl
  WHERE  line.id = dtl.cle_id AND line.Id =  p_line_id ;

CURSOR l_Line_Sll_Csr IS
   SELECT  sll.Id , sll.sequence_no , sll.start_date, sll.level_periods,
           sll.uom_per_period, sll.uom_code, sll.level_amount, sll.invoice_offset_days,
           sll.interface_offset_days,  sll.cle_id, sll.chr_id,
           sll.dnz_chr_id, sll.end_date,sll.object_version_number
   FROM oks_stream_levels_b sll
   WHERE sll.cle_id = p_line_id
   ORDER BY sll.sequence_no;

   l_Line_Csr_Rec           l_Line_Csr%Rowtype;
   l_Line_Sll_Csr_Rec       l_Line_Sll_Csr%Rowtype;
   l_Line_Amount            NUMBER;
   l_Sll_Counter            NUMBER;
   l_remaining_amt          NUMBER;
   l_used_amt               NUMBER;
   l_total_period           NUMBER;
   l_prorate_counter        NUMBER;
   l_amt_counter            NUMBER;
   l_sll_index             NUMBER;
   l_sll_amt                NUMBER;
   l_period_sll_amount      NUMBER(20,2);

   l_return_status          VARCHAR2(10);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000);
   l_init_msg_list          VARCHAR2(2000) := OKC_API.G_FALSE;

   l_sll_prorate_tbl        sll_prorated_tab_type;
-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 04-MAY-2005
-------------------------------------------------------------------------
l_price_uom         OKS_K_HEADERS_B.PRICE_UOM%TYPE;
l_period_start      OKS_K_HEADERS_B.PERIOD_START%TYPE;
l_period_type       OKS_K_HEADERS_B.PERIOD_TYPE%TYPE;
l_tangible        BOOLEAN;
l_pricing_method Varchar2(30);
-------------------------------------------------------------------------
-- End partial period computation logic
-- Date 04-MAY-2005
-------------------------------------------------------------------------
----The procedure finds the amount for line . Then find the amount for sll rule from the given periods and
----line amount and update the sll rule.
BEGIN

    x_return_status := 'S';

   l_strm_lvl_tbl_in.DELETE;

   OPEN l_Line_Csr;
   FETCH l_Line_Csr INTO l_Line_Csr_Rec;

   IF l_Line_Csr%NOTFOUND THEN
      Close l_Line_Csr;
      x_return_status := 'E';
      RETURN;
   ELSE
      Close l_Line_Csr;
   END IF;

   -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------

   OKS_RENEW_UTIL_PUB.Get_Period_Defaults
                (
                 p_hdr_id        =>l_Line_Csr_Rec.dnz_chr_id,
                 p_org_id        => NULL,
                 x_period_start  => l_period_start,
                 x_period_type   => l_period_type,
                 x_price_uom     => l_price_uom,
                 x_return_status => x_return_status);

   IF x_return_status <> 'S' THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;
  --Description in detail for the business rules for deriving the period start
  --1)For usage , period start  will always be 'SERVICE'
  --2)For Subscriptions, period start and period type will be NULL
  --  for tangible subscriptions as per CR1.For intangible subscriptions,
  --  if the profile OKS: Intangible Subscription Pricing Method
  --  is set to 'Subscription Based',then period start and period type will be NULL
  --  otherwise it will be 'SERVICE'
  --3) For Extended Warranty from OM, period start will always be 'SERVICE'

 --mchoudha fix for bug#5183011
 IF l_period_start IS NOT NULL AND
    l_period_type IS NOT NULL
 THEN
   IF l_Line_Csr_Rec.lse_id = 12 THEN
     l_period_start := 'SERVICE';
   END IF;
   IF l_Line_Csr_Rec.lse_id = 46 THEN
     l_tangible  := OKS_SUBSCRIPTION_PUB.is_subs_tangible (p_line_id);
     IF l_tangible THEN
       l_period_start := NULL;
       l_period_type := NULL;
     ELSE
       l_pricing_method :=FND_PROFILE.value('OKS_SUBS_PRICING_METHOD');
       IF nvl(l_pricing_method,'SUBSCRIPTION') <> 'EFFECTIVITY' THEN
         l_period_start := NULL;
         l_period_type := NULL;
       ELSE
         l_period_start := 'SERVICE';
       END IF;  -- l_pricing_method <> 'EFFECTIVITY'
     END IF;    -- IF l_tangible
   END IF;      -- l_Line_Csr_Rec.lse_id = 46
 END IF;        -- period start and period type are not null
 -------------------------------------------------------------------------
 -- End partial period computation logic
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------


   IF l_currency_code IS NULL THEN
     l_currency_code := Find_Currency_Code(
                                    p_cle_id  => p_line_id,
                                    p_chr_id  => NULL);
     IF l_currency_code IS NULL THEN
        OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'CURRENCY CODE NOT FOUND.');
        x_return_status := 'E';
        RETURN;
     END IF;
   END IF;  ---currency code null

   l_Line_Amount := l_Line_Csr_Rec.line_amt;

   l_Sll_Counter := 1;
   l_used_amt := 0;
   l_prorate_counter := 0;

   FOR l_Line_Sll_Csr_REC IN l_Line_Sll_Csr
   LOOP

     IF l_Line_Sll_Csr_Rec.level_amount IS NOT NULL THEN           ---------calculate total sll amount

       l_sll_amt := (l_Line_Sll_Csr_Rec.level_amount * l_Line_Sll_Csr_Rec.level_periods);
       l_sll_amt := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_sll_amt, l_currency_code);
       l_used_amt := l_used_amt + l_sll_amt;

       -----errorout_ad('sll amount = ' || to_char(l_sll_amt));
       -----errorout_ad('total used  amount = ' || to_char(l_used_amt));

     ELSE

       l_prorate_counter :=  l_prorate_counter + 1;
       -----errorout_ad('prorate counter = ' || to_char(l_prorate_counter));

       l_sll_prorate_tbl(l_prorate_counter).sll_seq_num    := l_sll_counter;          ---index of sll table
       l_sll_prorate_tbl(l_prorate_counter).sll_start_date := l_line_sll_csr_rec.Start_Date;
       l_sll_prorate_tbl(l_prorate_counter).sll_end_date   := l_line_sll_csr_rec.end_Date;
       l_sll_prorate_tbl(l_prorate_counter).sll_tuom       := l_Line_Sll_Csr_Rec.uom_code;
       l_sll_prorate_tbl(l_prorate_counter).sll_period     := l_Line_Sll_Csr_Rec.level_periods;
       l_sll_prorate_tbl(l_prorate_counter).sll_uom_per_period := l_Line_Sll_Csr_Rec.uom_per_period;
     END IF;


     l_strm_lvl_tbl_in(l_Sll_Counter).id                        := l_Line_Sll_Csr_Rec.id;
     l_strm_lvl_tbl_in(l_Sll_Counter).cle_id                    := l_Line_Sll_Csr_Rec.cle_id;
     l_strm_lvl_tbl_in(l_Sll_Counter).chr_id                    := l_Line_Sll_Csr_Rec.chr_id;
     l_strm_lvl_tbl_in(l_Sll_Counter).dnz_chr_id                := l_Line_Sll_Csr_Rec.dnz_chr_id;
     l_strm_lvl_tbl_in(l_Sll_Counter).uom_code                  := l_Line_Sll_Csr_Rec.uom_code;
     l_strm_lvl_tbl_in(l_Sll_Counter).sequence_no               := l_Line_Sll_Csr_Rec.sequence_no;
     l_strm_lvl_tbl_in(l_Sll_Counter).start_date                := l_line_sll_csr_rec.Start_Date;
     l_strm_lvl_tbl_in(l_Sll_Counter).end_date                  := l_line_sll_csr_rec.end_Date;
     l_strm_lvl_tbl_in(l_Sll_Counter).level_periods             := l_Line_Sll_Csr_Rec.level_periods;
     l_strm_lvl_tbl_in(l_Sll_Counter).uom_per_period            := l_Line_Sll_Csr_Rec.uom_per_period;
     l_strm_lvl_tbl_in(l_Sll_Counter).level_amount              := l_Line_Sll_Csr_Rec.level_amount;
     l_strm_lvl_tbl_in(l_Sll_Counter).invoice_offset_days       := l_Line_Sll_Csr_Rec.invoice_offset_days;
     l_strm_lvl_tbl_in(l_Sll_Counter).interface_offset_days     := l_Line_Sll_Csr_Rec.interface_offset_days;
     l_strm_lvl_tbl_in(l_Sll_Counter).object_version_number     := l_Line_Sll_Csr_Rec.object_version_number;

     l_strm_lvl_tbl_in(l_Sll_Counter).created_by                := OKC_API.G_MISS_NUM;
     l_strm_lvl_tbl_in(l_Sll_Counter).creation_date             := SYSDATE;
     l_strm_lvl_tbl_in(l_Sll_Counter).last_updated_by           := OKC_API.G_MISS_NUM;
     l_strm_lvl_tbl_in(l_Sll_Counter).last_update_date          := SYSDATE;


     l_Sll_Counter := l_Sll_Counter + 1;


   END LOOP;       --sll loop


   -----errorout_ad('OUTSIDE LOOP');
   -----errorout_ad('l_sll_prorate_tbl.COUNT = '|| TO_CHAR(l_sll_prorate_tbl.COUNT));

   IF l_sll_prorate_tbl.COUNT >= 1 THEN             ----get sll amount only if atleast 1 sll is without amount.

     l_remaining_amt := l_Line_Amount - l_used_amt;
     -----errorout_ad('l_remaining_amt = ' || to_char(l_remaining_amt));
     -----errorout_ad('l_currency_code = ' || l_currency_code);

     Calculate_sll_amount(
                      p_api_version      => l_api_version,
                      p_total_amount     => l_remaining_amt,
                      p_currency_code    => l_currency_code,
                      p_sll_prorated_tab => l_sll_prorate_tbl,
                      p_period_start     => l_period_start,
                      p_period_type      => l_period_type,
                      x_return_status    => x_return_status);


    -----errorout_ad  ('Get_sll_amount STATUS = ' ||  x_return_status);


    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    ---- the output table has index number of sll table to be updated in sll_seq_num field,
    ----so just change the amount for the l_rulv_index .


    IF l_sll_prorate_tbl.COUNT > 0 THEN
      l_amt_counter := l_sll_prorate_tbl.FIRST;
      LOOP
        l_sll_index := l_sll_prorate_tbl(l_amt_counter).sll_seq_num;

        -----errorout_ad('sll index = '|| to_char(l_sll_index));
        -----errorout_ad('sll amount returned = '|| to_char(l_sll_prorate_tbl(l_amt_counter).sll_amount));

        l_period_sll_amount := OKS_EXTWAR_UTIL_PVT.round_currency_amt(
                                         l_sll_prorate_tbl(l_amt_counter).sll_amount, l_currency_code);

        l_strm_lvl_tbl_in(l_sll_index).level_amount  := l_period_sll_amount;

        EXIT WHEN l_amt_counter = l_sll_prorate_tbl.LAST;

        l_amt_counter := l_sll_prorate_tbl.NEXT(l_amt_counter);

      END LOOP;
    END IF;       --prorate tbl count chk

  END IF;                ----end of getting sll amount


IF l_strm_lvl_tbl_in.COUNT > 0 THEN
  FOR i IN l_strm_lvl_tbl_in.FIRST .. l_strm_lvl_tbl_in.LAST
  LOOP

    UPDATE oks_stream_levels_b
    set level_amount = l_strm_lvl_tbl_in(i).level_amount
    WHERE id = l_strm_lvl_tbl_in(i).id;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

        fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.update_sll_amount.update',
                      'update sll id = ' || l_strm_lvl_tbl_in(i).id
                    ||', amt = ' || l_strm_lvl_tbl_in(i).level_amount
                  );
     END IF;
  END LOOP;         --tbl for loop
END IF;           ---sll tbl count chk

EXCEPTION
 WHEN OTHERS THEN
        IF FND_LOG.LEVEL_UNEXPECTED >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_unexpected,G_MODULE_CURRENT||'.update_sll_amount.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
        END IF;
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END Update_Sll_Amount;

PROCEDURE Calculate_sll_amount( p_api_version       IN      NUMBER,
                                p_total_amount      IN      NUMBER,
                                p_currency_code     IN      VARCHAR2,
                                p_period_start      IN      VARCHAR2,
                                p_period_type       IN      VARCHAR2,
                                p_sll_prorated_tab  IN  OUT NOCOPY sll_prorated_tab_type,
                                x_return_status     OUT     NOCOPY VARCHAR2

)
IS
l_sll_num               NUMBER;
i                       NUMBER;
j                       NUMBER;
l_sll_remain_amount  NUMBER(20,2);
l_currency_code   VARCHAR2(15);
l_period_sll_amt        NUMBER(20,2);

l_uom_code     VARCHAR2(40);
l_tce_code      VARCHAR2(10);
l_uom_quantity         NUMBER;
l_curr_sll_start_date  DATE;
l_curr_sll_end_date    DATE;

l_next_sll_start_date  DATE;
l_next_sll_end_date    DATE;
l_tot_sll_amount       NUMBER(20,2);

l_curr_frequency        NUMBER;
l_next_frequency        NUMBER;
l_tot_frequency         NUMBER;
l_sll_period        NUMBER;
l_return_status         VARCHAR2(1);
l_uom_per_period         NUMBER;
l_temp                   NUMBER;

BEGIN
x_return_status := 'S';
l_sll_num := p_sll_prorated_tab.count;
l_sll_remain_amount := p_total_amount;
 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 31-MAY-2005
 -- Proration to consider period start and period type
 -------------------------------------------------------------------------
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
   fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Calculate_sll_amount.ppc',
  'input parameters period start  '||p_period_start
  ||' p_period_type = ' || p_period_type);
END IF;

IF p_period_start is NOT NULL AND
   p_period_type  is NOT NULL
THEN
  FOR i in 1 .. l_sll_num LOOP
    l_uom_code := p_sll_prorated_tab(i).sll_tuom ;
    l_uom_per_period := p_sll_prorated_tab(i).sll_uom_per_period ;
     --errorout_ad('l_uom_code '||l_uom_code);
    l_next_sll_end_date := NULL;
    l_curr_sll_start_date := p_sll_prorated_tab(i).sll_start_date;
    l_curr_sll_end_date   := p_sll_prorated_tab(i).sll_end_date;

    For j in i+1 .. l_sll_num Loop
          l_next_sll_start_date := p_sll_prorated_tab(j).sll_start_date;
          l_next_sll_end_date   := p_sll_prorated_tab(j).sll_end_date;
/*          l_temp:=NULL;
          l_temp:= OKS_TIME_MEASURES_PUB.get_quantity (
                                                        p_start_date   => l_next_sll_start_date,
                                                        p_end_date     => l_next_sll_end_date,
                                                        p_source_uom   => l_uom_code,
                                                        p_period_type  => p_period_type,
                                                        p_period_start => p_period_start
                                                        );
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Calculate_sll_amount.ppc',
            'afer calling OKS_TIME_MEASURES_PUB.get_quantity input parameters period start  '||p_period_start||' p_period_type = ' || p_period_type
            ||' result l_temp '||l_temp);
          END IF;

          IF nvl(l_temp,0) = 0 THEN
             RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;

          l_next_frequency :=l_next_frequency + l_temp;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Calculate_sll_amount.ppc',
            'afer calling OKS_TIME_MEASURES_PUB.get_quantity input parameters period start  '||p_period_start||' p_period_type = ' || p_period_type
            ||' result l_next_frequency '||l_next_frequency);
          END IF;

*/

     END LOOP;

    l_curr_frequency := OKS_TIME_MEASURES_PUB.get_quantity (
                                                        p_start_date   => l_curr_sll_start_date,
                                                        p_end_date     => l_curr_sll_end_date,
                                                        p_source_uom   => l_uom_code,
                                                        p_period_type  => p_period_type,
                                                        p_period_start => p_period_start
                                                        );
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Calculate_sll_amount.ppc',
       'afer calling OKS_TIME_MEASURES_PUB.get_quantity input parameters period start  '||p_period_start||' p_period_type = ' || p_period_type
       ||' result l_curr_frequency '||l_curr_frequency);
    END IF;

    IF nvl(l_curr_frequency,0) = 0 THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    l_tot_frequency := 0;

    l_tot_frequency := OKS_TIME_MEASURES_PUB.get_quantity (
                                                        p_start_date   => l_curr_sll_start_date,
                                                        p_end_date     => nvl(l_next_sll_end_date,l_curr_sll_end_date),
                                                        p_source_uom   => l_uom_code,
                                                        p_period_type  => p_period_type,
                                                        p_period_start => p_period_start
                                                        );

    IF nvl(l_tot_frequency,0) = 0 THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
        --errorout_ad('l_curr_frequency '||l_curr_frequency);

  --        l_next_frequency := 0;


  --      l_tot_frequency := l_tot_frequency + l_curr_frequency + l_next_frequency;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Calculate_sll_amount.ppc',
           ' result l_tot_frequency '||l_tot_frequency);
        END IF;

        --errorout_ad('l_tot_frequency '||l_tot_frequency);
       -- l_sll_period := p_sll_prorated_tab(i).sll_period;
        l_sll_period := l_curr_frequency/l_uom_per_period;

        l_period_sll_amt := ( l_sll_remain_amount /( nvl(l_tot_frequency,1) * nvl(l_sll_period,1))) * nvl(l_curr_frequency,0) ;

        l_period_sll_amt := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_period_sll_amt, l_currency_code);

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Calculate_sll_amount.ppc',
           ' result l_period_sll_amt '||l_period_sll_amt);
        END IF;


        l_sll_remain_amount := l_sll_remain_amount - (l_period_sll_amt * nvl(l_sll_period,1)) ;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Calculate_sll_amount.ppc',
           ' result l_sll_remain_amount '||l_sll_remain_amount);
        END IF;

        --errorout_ad('l_period_sll_amt '||l_period_sll_amt);
        --errorout_ad('l_sll_remain_amount '||l_sll_remain_amount);
        p_sll_prorated_tab(i).sll_amount := l_period_sll_amt;
        l_curr_frequency := 0;
  END LOOP;
 -------------------------------------------------------------------------
 -- End partial period computation logic
 -------------------------------------------------------------------------
ELSE
  For i in 1 .. l_sll_num Loop
    l_uom_code := p_sll_prorated_tab(i).sll_tuom ;
    oks_bill_util_pub.get_seeded_timeunit(
                             p_timeunit     => l_uom_code ,
                             x_return_status => l_return_status,
                             x_quantity      => l_uom_quantity,
                             x_timeunit      => l_tce_code);

    l_curr_sll_start_date := p_sll_prorated_tab(i).sll_start_date;
    l_curr_sll_end_date   := p_sll_prorated_tab(i).sll_end_date;

    IF l_tce_code = 'DAY' Then
        l_curr_frequency :=  l_curr_sll_end_date - l_curr_sll_start_date + 1;
    ELSIF l_tce_code = 'MONTH' Then
        l_curr_frequency :=  months_between(l_curr_sll_end_date + 1, l_curr_sll_start_date) ;
    ELSIF l_tce_code = 'YEAR' Then
        l_curr_frequency :=  months_between(l_curr_sll_end_date + 1, l_curr_sll_start_date) / 12 ;
    END IF;

    If NVL(l_uom_quantity,0) > 0 Then
        l_curr_frequency := l_curr_frequency / NVL(l_uom_quantity,1);
    END IF;
        --errorout_ad('l_curr_frequency '||l_curr_frequency);
        l_tot_frequency := 0;
        l_next_frequency := 0;

        For j in i+1 .. l_sll_num Loop
          l_next_sll_start_date := p_sll_prorated_tab(j).sll_start_date;
          l_next_sll_end_date   := p_sll_prorated_tab(j).sll_end_date;
          IF l_tce_code = 'DAY' Then
            l_next_frequency :=  l_next_frequency + (l_next_sll_end_date - l_next_sll_start_date + 1);
          ELSIF l_tce_code = 'MONTH' Then
            l_next_frequency :=  l_next_frequency + (months_between(l_next_sll_end_date + 1, l_next_sll_start_date)) ;
          ELSIF l_tce_code = 'YEAR' Then
            l_next_frequency :=  l_next_frequency + (months_between(l_next_sll_end_date + 1, l_next_sll_start_date) / 12) ;
         END IF;


        END LOOP;

        If NVL(l_uom_quantity,0) > 0 Then
           l_next_frequency := l_next_frequency / NVL(l_uom_quantity,1);
         END IF;

        l_tot_frequency := l_tot_frequency + l_curr_frequency + l_next_frequency;
        --errorout_ad('l_tot_frequency '||l_tot_frequency);
        l_sll_period := p_sll_prorated_tab(i).sll_period;


        l_period_sll_amt := ( l_sll_remain_amount /( nvl(l_tot_frequency,1) * nvl(l_sll_period,1))) * nvl(l_curr_frequency,0) ;

        l_period_sll_amt := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_period_sll_amt, l_currency_code);

        l_sll_remain_amount := l_sll_remain_amount - (l_period_sll_amt * nvl(l_sll_period,1)) ;
            --errorout_ad('l_period_sll_amt '||l_period_sll_amt);
                --errorout_ad('l_sll_remain_amount '||l_sll_remain_amount);
        p_sll_prorated_tab(i).sll_amount := l_period_sll_amt;
        l_curr_frequency := 0;
  END LOOP;
END IF;

EXCEPTION
WHEN G_EXCEPTION_HALT_VALIDATION THEN
   x_return_status := G_RET_STS_ERROR;
END Calculate_sll_amount;


FUNCTION Find_Sll_Count(
                       p_subline_id   NUMBER)
RETURN NUMBER

IS

l_sll_rule_count          NUMBER;

BEGIN

SELECT COUNT(id) INTO l_sll_rule_count
FROM oks_stream_levels_b
WHERE cle_id = p_subline_id ;

RETURN l_sll_rule_count;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;

END Find_Sll_Count;


PROCEDURE Delete_lvl_element(p_cle_id          IN  NUMBER,
                             x_return_status   OUT NOCOPY VARCHAR2)

IS

BEGIN

---it deletes the level elementwhich are not billed for the given line id.

x_return_status := 'S';

DELETE  FROM   OKS_LEVEL_ELEMENTS
WHERE  date_Completed is NULL
AND cle_id = p_cle_id;


EXCEPTION
  WHEN OTHERS THEN
    OKC_API.SET_MESSAGE(p_app_name         => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END Delete_lvl_element;



PROCEDURE Del_hdr_lvl_element(p_hdr_id         IN  NUMBER,
                             x_return_status  OUT NOCOPY VARCHAR2
)
IS


BEGIN

x_return_status := 'S';
---delete hdr , top line, cp lvl elements together

DELETE FROM OKS_LEVEL_ELEMENTS
WHERE rul_id IN
       (SELECT sll.id
       FROM OKS_STREAM_LEVELS_B sll
       WHERE sll.dnz_chr_id = p_hdr_id);



---delete sll  for line and cp.

DELETE FROM OKS_STREAM_LEVELS_B
WHERE dnz_chr_id = p_hdr_id
AND chr_id IS NULL;

EXCEPTION
  WHEN OTHERS THEN
    OKC_API.SET_MESSAGE(p_app_name         => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END Del_hdr_lvl_element;


Procedure Cal_hdr_Sll_Amount
(
          p_hdr_id          IN    NUMBER,
          x_return_status   OUT   NOCOPY Varchar2
)
IS

  Cursor l_hdr_Csr Is
         SELECT id, TRUNC(start_date) start_dt, TRUNC(end_date) end_dt
         FROM   OKC_K_HEADERS_b
         WHERE  id =  p_hdr_id ;


  CURSOR l_Sll_Csr IS
         SELECT  sll.Id , sll.sequence_no , sll.start_date, sll.level_periods,
         sll.uom_per_period, sll.uom_code, sll.level_amount, sll.invoice_offset_days,
         sll.interface_offset_days,  sll.cle_id, sll.chr_id,
         sll.dnz_chr_id, sll.end_date, sll.object_version_number
         FROM oks_stream_levels_b sll
         WHERE sll.chr_id = p_hdr_id
         ORDER BY sll.sequence_no;

   l_hdr_Csr_Rec            l_hdr_Csr%Rowtype;
   l_Sll_Csr_Rec            l_Sll_Csr%Rowtype;
   l_hdr_Amount             NUMBER;
   l_Sll_Counter            NUMBER;
   l_Cycle_Start_Date       DATE;
   l_Cycle_End_Date         DATE;
   l_remaining_amt          NUMBER;
   l_used_amt               NUMBER;
   l_total_period           NUMBER;
   l_prorate_counter        NUMBER;
   l_amt_counter            NUMBER;
   l_sll_index              NUMBER;
   l_sll_amt                NUMBER;
   l_period_sll_amount      NUMBER(20,2);

   l_return_status          VARCHAR2(10);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000);
   l_init_msg_list          VARCHAR2(2000) := OKC_API.G_FALSE;

   l_sll_prorate_tbl        sll_prorated_tab_type;
-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 04-MAY-2005
-------------------------------------------------------------------------
l_price_uom         OKS_K_HEADERS_B.PRICE_UOM%TYPE;
l_period_start      OKS_K_HEADERS_B.PERIOD_START%TYPE;
l_period_type       OKS_K_HEADERS_B.PERIOD_TYPE%TYPE;
-------------------------------------------------------------------------
-- End partial period computation logic
-- Date 04-MAY-2005
-------------------------------------------------------------------------

----The procedure finds the amount for hdr . Then find the amount for sll rule from the given periods and
----hdr amount and update the sll rule.
BEGIN
x_return_status := 'S';
   l_strm_lvl_tbl_in.DELETE;

   OPEN l_hdr_Csr;
   FETCH l_hdr_Csr INTO l_hdr_Csr_Rec;

   IF l_hdr_Csr%NOTFOUND THEN
      Close l_hdr_Csr;
      x_return_status := 'E';
      RETURN;
   ELSE
      Close l_hdr_Csr;
   END IF;
  -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------

   OKS_RENEW_UTIL_PUB.Get_Period_Defaults
                (
                 p_hdr_id        => p_hdr_id,
                 p_org_id        => NULL,
                 x_period_start  => l_period_start,
                 x_period_type   => l_period_type,
                 x_price_uom     => l_price_uom,
                 x_return_status => x_return_status);

   IF x_return_status <> 'S' THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;
 -------------------------------------------------------------------------
 -- End partial period computation logic
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------
   IF l_currency_code IS NULL THEN
     l_currency_code := Find_Currency_Code(
                                    p_cle_id  => NULL,
                                    p_chr_id  => p_hdr_id);

     IF l_currency_code IS NULL THEN
        OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'CURRENCY CODE NOT FOUND.');
        x_return_status := 'E';
        RETURN;
     END IF;
   END IF;


   l_hdr_Amount := Cal_Hdr_Amount(p_contract_id  => p_hdr_id);


   l_Sll_Counter := 1;
   l_used_amt := 0;
   l_prorate_counter := 0;

   FOR l_Sll_Csr_rec IN l_Sll_Csr
   LOOP


     IF l_Sll_Csr_Rec.level_amount IS NOT NULL THEN           ---------calculate total all amount

       l_sll_amt := to_number(l_Sll_Csr_Rec.level_amount) * to_number(l_Sll_Csr_Rec.level_periods);
       l_sll_amt := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_sll_amt, l_currency_code);
       l_used_amt := l_used_amt + l_sll_amt;

       -----errorout_ad('sll amount = ' || to_char(l_sll_amt));
       -----errorout_ad('total used  amount = ' || to_char(l_used_amt));

     ELSE

       l_prorate_counter :=  l_prorate_counter + 1;
       -----errorout_ad('prorate counter = ' || to_char(l_prorate_counter));

       l_sll_prorate_tbl(l_prorate_counter).sll_seq_num    := l_sll_counter;          ---index of rulv table
       l_sll_prorate_tbl(l_prorate_counter).sll_start_date := l_sll_csr_rec.Start_Date;
       l_sll_prorate_tbl(l_prorate_counter).sll_end_date   := l_sll_csr_rec.end_Date;
       l_sll_prorate_tbl(l_prorate_counter).sll_tuom        := l_Sll_Csr_Rec.uom_code;
       l_sll_prorate_tbl(l_prorate_counter).sll_period     := TO_NUMBER(l_Sll_Csr_Rec.level_periods);
       l_sll_prorate_tbl(l_prorate_counter).sll_uom_per_period := l_Sll_Csr_Rec.uom_per_period;

       -----errorout_ad('sll_seq_num = ' || TO_CHAR(l_sll_counter));
       -----errorout_ad('sll_start_date = ' || TO_CHAR(l_Cycle_Start_Date));
       -----errorout_ad('sll_start_date = ' || TO_CHAR(l_Cycle_End_Date));
       -----errorout_ad('sll_uom = ' || l_Sll_Csr_Rec.object1_id1);
     END IF;

     l_strm_lvl_tbl_in(l_Sll_Counter).id                        := l_Sll_Csr_Rec.id;
     l_strm_lvl_tbl_in(l_Sll_Counter).cle_id                    := l_Sll_Csr_Rec.cle_id;
     l_strm_lvl_tbl_in(l_Sll_Counter).chr_id                    := l_Sll_Csr_Rec.chr_id;
     l_strm_lvl_tbl_in(l_Sll_Counter).dnz_chr_id                := l_Sll_Csr_Rec.dnz_chr_id;
     l_strm_lvl_tbl_in(l_Sll_Counter).uom_code                  := l_Sll_Csr_Rec.uom_code;
     l_strm_lvl_tbl_in(l_Sll_Counter).sequence_no               := l_Sll_Csr_Rec.sequence_no;
     l_strm_lvl_tbl_in(l_Sll_Counter).start_date                := l_sll_csr_rec.Start_Date;
     l_strm_lvl_tbl_in(l_Sll_Counter).end_date                  := l_sll_csr_rec.end_Date;
     l_strm_lvl_tbl_in(l_Sll_Counter).level_periods             := l_Sll_Csr_Rec.level_periods;
     l_strm_lvl_tbl_in(l_Sll_Counter).uom_per_period            := l_Sll_Csr_Rec.uom_per_period;
     l_strm_lvl_tbl_in(l_Sll_Counter).level_amount              := l_Sll_Csr_Rec.level_amount;
     l_strm_lvl_tbl_in(l_Sll_Counter).invoice_offset_days       := l_Sll_Csr_Rec.invoice_offset_days;
     l_strm_lvl_tbl_in(l_Sll_Counter).interface_offset_days     := l_Sll_Csr_Rec.interface_offset_days;
     l_strm_lvl_tbl_in(l_Sll_Counter).object_version_number     := l_Sll_Csr_Rec.object_version_number;

     l_strm_lvl_tbl_in(l_Sll_Counter).created_by                := OKC_API.G_MISS_NUM;
     l_strm_lvl_tbl_in(l_Sll_Counter).creation_date             := SYSDATE;
     l_strm_lvl_tbl_in(l_Sll_Counter).last_updated_by           := OKC_API.G_MISS_NUM;
     l_strm_lvl_tbl_in(l_Sll_Counter).last_update_date          := SYSDATE;

     l_Sll_Counter := l_Sll_Counter + 1;


   END LOOP;


   -----errorout_ad('OUTSIDE LOOP');
   -----errorout_ad('l_sll_prorate_tbl.COUNT = '|| TO_CHAR(l_sll_prorate_tbl.COUNT));

   IF l_sll_prorate_tbl.COUNT >= 1 THEN             ----get sll amount only if atleast 1 sll is without amount.

     l_remaining_amt := l_hdr_amount - l_used_amt;
     -----errorout_ad('l_remaining_amt = ' || to_char(l_remaining_amt));
     -----errorout_ad('l_currency_code = ' || l_currency_code);

     Calculate_sll_amount(
                      p_api_version      => l_api_version,
                      p_total_amount     => l_remaining_amt,
                      p_currency_code    => l_currency_code,
                      p_period_start     => l_period_start,
                      p_period_type      => l_period_type,
                      p_sll_prorated_tab => l_sll_prorate_tbl,
                      x_return_status    => x_return_status);


    -----errorout_ad  ('Get_sll_amount STATUS = ' ||  x_return_status);


    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    ---- the output table has index number of sll rule table to be updated in sll_seq_num field,
    ----so just change the amount for the l_rulv_index .


    IF l_sll_prorate_tbl.COUNT > 0 THEN
      l_amt_counter := l_sll_prorate_tbl.FIRST;
      LOOP
        l_sll_index := l_sll_prorate_tbl(l_amt_counter).sll_seq_num;

        -----errorout_ad('sll index = '|| to_char(l_sll_index));
        -----errorout_ad('sll amount returned = '|| to_char(l_sll_prorate_tbl(l_amt_counter).sll_amount));

        l_period_sll_amount := OKS_EXTWAR_UTIL_PVT.round_currency_amt(
                                           l_sll_prorate_tbl(l_amt_counter).sll_amount, l_currency_code);

        l_strm_lvl_tbl_in(l_sll_index).level_amount  := TO_CHAR(l_period_sll_amount);

        EXIT WHEN l_amt_counter = l_sll_prorate_tbl.LAST;

        l_amt_counter := l_sll_prorate_tbl.NEXT(l_amt_counter);

      END LOOP;
    END IF;

  END IF;                ----end of getting sll amount

IF l_strm_lvl_tbl_in.COUNT > 0 THEN
  FOR i IN l_strm_lvl_tbl_in.FIRST .. l_strm_lvl_tbl_in.LAST
  LOOP

    UPDATE oks_stream_levels_b
    set level_amount = l_strm_lvl_tbl_in(i).level_amount
    WHERE id = l_strm_lvl_tbl_in(i).id;
  END LOOP;         --tbl for loop
END IF;           ---sll tbl count chk


EXCEPTION
 WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END Cal_hdr_Sll_Amount;

PROCEDURE Get_Constant_sll_Amount(p_line_start_date       IN DATE,
                                 p_line_end_date         IN DATE,
                                 p_cycle_start_date      IN DATE,
                                 p_remaining_amount      IN NUMBER,
                                 P_uom_quantity          IN NUMBER,
                                 P_tce_code              IN VARCHAR2,
                                 x_constant_sll_amt      OUT NOCOPY NUMBER,
                                 x_return_status         OUT NOCOPY VARCHAR2)
IS

l_frequency          NUMBER;

BEGIN
x_return_status := OKC_API.G_RET_STS_SUCCESS;
-----errorout_ad('p_tce_code = ' || p_tce_code);
-----errorout_ad('p_uom_quantity = ' || p_uom_quantity);

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

  fnd_log.STRING (fnd_log.level_statement,
            G_MODULE_CURRENT || '.get_constant_sll_amount.info',
               'p_tce_code = ' || p_tce_code
             ||', p_uom_quantity = ' || p_uom_quantity
             ||', p_remaining_amount = ' || p_remaining_amount
             ||', st-end dt = ' || p_line_start_date || '-' || p_line_end_date );
END IF;

If p_line_start_date > p_cycle_start_date then   ---and l_start_date < l_next_billing_date Then
    l_frequency  := OKS_BILL_UTIL_PUB.get_frequency
                (p_tce_code      => p_tce_code,
                 p_fr_end_date   => p_line_end_date ,
                 p_fr_start_date => p_line_start_date,       --this LINE st dt
                 p_uom_quantity  => p_uom_quantity,
                 x_return_status => X_return_status);


ELSE
   l_frequency  := OKS_BILL_UTIL_PUB.get_frequency
                (p_tce_code      => p_tce_code,
                 p_fr_end_date   => p_line_end_date ,
                 p_fr_start_date => p_cycle_start_date,       --this cycle st dt to find remaining period
                 p_uom_quantity  => p_uom_quantity,
                 x_return_status => x_return_status);

END IF;

IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.get_constant_sll_amount.freq',
                       'oks_bill_util_pub.get_frequency(x_return_status = '||x_return_status
                       ||', l_frequency = '|| l_frequency ||')');
END IF;

If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
  OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'GET_FREQUENCY FAILED.');
  x_return_status := OKC_API.G_RET_STS_ERROR;
  RETURN;
End if;

-----errorout_ad('p_remaining_amount = ' || p_remaining_amount);
-----errorout_ad('l_frequency = ' || l_frequency);

x_constant_sll_amt :=  (nvl(p_remaining_amount,0)/nvl(l_frequency,1)) ;

-----errorout_ad('x_constant_sll_amt  = ' || x_constant_sll_amt);
EXCEPTION
 WHEN OTHERS THEN

       IF FND_LOG.LEVEL_UNEXPECTED >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_unexpected,G_MODULE_CURRENT||'.get_constant_sll_amount.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
       END IF;
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;

END Get_Constant_sll_Amount;

PROCEDURE Get_Period_Frequency(p_line_start_date      IN  DATE,
                              p_line_end_date         IN  DATE,
                              p_cycle_start_date      IN  DATE,
                              p_next_billing_date     IN  DATE,
                              P_uom_quantity          IN  NUMBER,
                              P_tce_code              IN  VARCHAR2,
                              p_uom_per_period       IN  NUMBER,
                              x_period_freq           OUT NOCOPY NUMBER,
                              x_return_status         OUT NOCOPY VARCHAR2)
IS

BEGIN
x_return_status         := OKC_API.G_RET_STS_SUCCESS;
   If p_line_start_date > p_cycle_start_date and p_line_start_date < P_next_billing_date Then
           x_period_freq := OKS_BILL_UTIL_PUB.get_frequency
                               (p_tce_code      => p_tce_code,
                                p_fr_start_date => p_line_start_date,
                                p_fr_end_date   => p_next_billing_date - 1,
                                p_uom_quantity  => p_uom_quantity,
                                x_return_status => x_return_status);

   ElsiF( p_next_billing_date > p_line_end_date + 1) THEN
             x_period_freq:= OKS_BILL_UTIL_PUB.get_frequency
                              (p_tce_code      => p_tce_code,
                                p_fr_end_date   => p_line_end_date,
                                p_fr_start_date => p_cycle_start_date,
                                p_uom_quantity  => p_uom_quantity,
                                x_return_status => x_return_status);

     ELSE                          ----if everything is ok

             x_period_freq := p_uom_per_period;

     End If;


IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.get_period_frequency.freq',
                       'oks_bill_util_pub.get_frequency(x_return_status = '||x_return_status
                       ||', x_period_freq = '|| x_period_freq ||')');
END IF;

If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
   OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'GET_FREQUENCY FAILED.');
   x_return_status := OKC_API.G_RET_STS_ERROR;
   RETURN;
End if;

EXCEPTION
 WHEN OTHERS THEN

        IF FND_LOG.LEVEL_UNEXPECTED >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_unexpected,G_MODULE_CURRENT||'.get_period_frequency.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
        END IF;
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;

end Get_Period_Frequency;




Function Cal_Sllid_amount
(
          p_Sll_id              IN    NUMBER,
          x_return_status       OUT   NOCOPY Varchar2,
          x_msg_count           OUT   NOCOPY NUMBER,
          x_msg_data            OUT   NOCOPY VARCHAR2
)RETURN NUMBER
IS

l_sll_amt         NUMBER := 0;

BEGIN

x_return_status := OKC_API.G_RET_STS_SUCCESS;

SELECT NVL(SUM(AMOUNT),0) INTO l_sll_amt
FROM OKS_LEVEL_ELEMENTS
WHERE rul_id = p_Sll_id;

RETURN l_sll_amt;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := G_RET_STS_UNEXP_ERROR;
    RETURN NULL;

END Cal_Sllid_amount;

Procedure Create_Bill_Sch_CP
(
          p_top_line_id         IN    NUMBER,
          p_cp_line_id          IN    NUMBER,
          p_cp_new              IN    Varchar2,
          x_return_status       OUT   NOCOPY Varchar2,
          x_msg_count           OUT   NOCOPY NUMBER,
          x_msg_data             OUT  NOCOPY VARCHAR2)

IS

Cursor l_subLine_Csr Is
 SELECT line.id subline_id, TRUNC(line.start_date) cp_start_dt,
        TRUNC(line.end_date) cp_end_dt, TRUNC(line.date_terminated) cp_term_dt,
        dtl.full_credit full_credit,price_uom,lse_id cp_lse_id,
        (nvl(line.price_negotiated,0) +  nvl(dtl.ubt_amount,0) +
         nvl(dtl.credit_amount,0) +  nvl(dtl.suppressed_credit,0) ) subline_amt
 FROM okc_k_lines_b line, oks_k_lines_b dtl
 WHERE line.id = p_cp_line_id
   AND line.date_cancelled is NULL
 AND line.id = dtl.cle_id;


 Cursor l_Line_Csr Is
 SELECT line.chr_id chr_id, line.dnz_chr_id dnz_chr_id, line.id id, line.lse_id lse_id,
        TRUNC(line.start_date) line_start_dt, TRUNC(line.end_date) line_end_dt,
        line.inv_rule_id inv_id,
        nvl(dtl.billing_schedule_type,'T') billing_schedule_type,
        (nvl(line.price_negotiated,0) +  nvl(dtl.ubt_amount,0) +
         nvl(dtl.credit_amount,0) +  nvl(dtl.suppressed_credit,0) ) line_amt
 FROM okc_k_lines_b line, oks_k_lines_b dtl
 WHERE  line.id = dtl.cle_id AND line.Id =  p_top_line_id
           AND line.date_cancelled is NULL;

CURSOR l_line_sll_csr IS
         SELECT  sll.Id , sll.sequence_no , sll.start_date, sll.level_periods,
         sll.uom_per_period, sll.uom_code, sll.level_amount, sll.invoice_offset_days,
         sll.interface_offset_days, sll.cle_id, sll.chr_id,
         sll.dnz_chr_id,sll.end_date
         FROM oks_stream_levels_b sll
         WHERE sll.cle_id = p_top_line_id
         ORDER BY sll.sequence_no;

CURSOR l_line_BS_csr(p_line_id  NUMBER) IS
         SELECT id, trunc(date_start) date_start,
         amount,trunc(date_end) date_end,object_version_number,
         date_to_interface, date_transaction
         FROM oks_level_elements
         WHERE cle_id = p_line_id
         ORDER BY date_start;


Cursor  l_line_amt_csr (p_id in number) IS
Select  line.price_negotiated
from    okc_k_lines_b line
where   line.id = p_id;


l_index                   NUMBER;
l_init_msg_list VARCHAR2(2000) := OKC_API.G_FALSE;

l_Line_Sll_rec            l_Line_Sll_Csr%ROWTYPE;
l_line_BS_rec             l_line_BS_csr%ROWTYPE;
l_Line_Csr_Rec            l_Line_Csr%Rowtype;
l_SubLine_Rec             l_subLine_Csr%Rowtype;
l_cp_rec                  Prod_Det_Type;
l_line_rec                Line_Det_Type;


L_bil_sch_out_tbl         OKS_BILL_SCH.ItemBillSch_tbl;
l_top_bs_tbl              oks_bill_level_elements_pvt.letv_tbl_type;
l_sll_tbl                 OKS_BILL_SCH.StreamLvl_tbl;
l_update_required         VARCHAR2(1);
l_cp_term_dt              DATE;
l_amount                  NUMBER;

-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 04-MAY-2005
-------------------------------------------------------------------------
l_price_uom         OKS_K_HEADERS_B.PRICE_UOM%TYPE;
l_period_start      OKS_K_HEADERS_B.PERIOD_START%TYPE;
l_period_type       OKS_K_HEADERS_B.PERIOD_TYPE%TYPE;
l_return_status     VARCHAR2(30);
l_tangible          BOOLEAN;
l_pricing_method    VARCHAR2(30);
-------------------------------------------------------------------------
-- End partial period computation logic
-- Date 04-MAY-2005
-------------------------------------------------------------------------

BEGIN

---this is called for the new cp or existing cp which is updated and only for 'T'.
--p_cp_new is 'Y' for new subline, 'N' for updating schedule for existing subline

x_return_status := OKC_API.G_RET_STS_SUCCESS;
l_update_required := 'N';

---get line details
Open l_Line_Csr;
Fetch l_Line_Csr Into l_Line_Csr_Rec;

If l_Line_Csr%Notfound then
    Close l_Line_Csr;
    IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,G_MODULE_CURRENT||'.create_bill_sch_cp.EXCEPTION',
        'top line not found = ' || p_top_line_id );
    END IF;
    x_return_status := 'E';
     OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'LINE NOT FOUND');
    RAISE G_EXCEPTION_HALT_VALIDATION;
End If;
Close l_Line_Csr;

l_line_rec.chr_id          :=  l_Line_Csr_Rec.chr_id;
l_line_rec.dnz_chr_id      :=  l_Line_Csr_Rec.dnz_chr_id;
l_line_rec.id              :=  l_Line_Csr_Rec.id ;
l_line_rec.lse_id          :=  l_Line_Csr_Rec.lse_id;
l_line_rec.line_start_dt   :=  l_Line_Csr_Rec.line_start_dt;
l_line_rec.line_end_dt     :=  l_Line_Csr_Rec.line_end_dt;
l_line_rec.line_amt        :=  l_Line_Csr_Rec.line_amt ;
-----errorout_ad('line found');
 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------

   OKS_RENEW_UTIL_PUB.Get_Period_Defaults
                (
                 p_hdr_id        => l_Line_Csr_Rec.dnz_chr_id,
                 p_org_id        => NULL,
                 x_period_start  => l_period_start,
                 x_period_type   => l_period_type,
                 x_price_uom     => l_price_uom,
                 x_return_status => x_return_status);

   IF x_return_status <> 'S' THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;
  --Description in detail for the business rules for deriving the period start
  --1)For usage , period start  will always be 'SERVICE'
  --2)For Subscriptions, period start and period type will be NULL
  --  for tangible subscriptions as per CR1.For intangible subscriptions,
  --  if the profile OKS: Intangible Subscription Pricing Method
  --  is set to 'Subscription Based',then period start and period type will be NULL
  --  otherwise it will be 'SERVICE'
  --3) For Extended Warranty from OM, period start will always be 'SERVICE'
--mchoudha fix for bug#5183011
 IF l_period_start IS NOT NULL AND
    l_period_type IS NOT NULL
 THEN
   IF l_line_rec.lse_id = 12 THEN
     l_period_start := 'SERVICE';
   END IF;
   IF l_line_rec.lse_id = 46 THEN
     l_tangible  := OKS_SUBSCRIPTION_PUB.is_subs_tangible (l_line_rec.id);
     IF l_tangible THEN
         l_period_start := NULL;
         l_period_type := NULL;
     ELSE
       l_pricing_method :=FND_PROFILE.value('OKS_SUBS_PRICING_METHOD');
       IF nvl(l_pricing_method,'SUBSCRIPTION') <> 'EFFECTIVITY' THEN
         l_period_start := NULL;
         l_period_type := NULL;
       ELSE
         l_period_start := 'SERVICE';
       END IF;   -- l_pricing_method <> 'EFFECTIVITY'
     END IF;     -- IF l_tangible
   END IF;       -- l_line_rec.lse_id = 46
 END IF;         -- period start and period type are not null
 -------------------------------------------------------------------------
 -- End partial period computation logic
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------
  IF l_period_type is not null AND l_period_start is not NULL THEN
    OPEN l_line_amt_csr(l_Line_Csr_Rec.id);
    FETCH l_line_amt_csr INTO l_line_rec.line_amt;
    CLOSE l_line_amt_csr;
  END IF;

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

   fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.create_bill_sch_cp.line_dtls',
                      'dnz_chr_id = ' || l_line_rec.dnz_chr_id
                   || ', id = ' || l_line_rec.id
                   || ', lse_id = ' || l_line_rec.lse_id
                   || ', start dt = ' || l_line_rec.line_start_dt
                   || ', end dt = ' || l_line_rec.line_end_dt
                   || ', amt = ' || l_line_rec.line_amt
                   || ', bill_type = ' || l_Line_Csr_Rec.billing_schedule_type
                  );
END IF;


IF l_Line_Csr_Rec.billing_schedule_type <> 'T' THEN
   RETURN;
END IF;



l_index := 1;
----make sll tbl
l_sll_tbl.DELETE;

---make sll tbl

FOR l_Line_SlL_rec IN l_Line_SlL_Csr
LOOP
  l_sll_tbl(l_index).id                             := l_Line_SlL_rec.id;
  l_sll_tbl(l_index).cle_id                         := l_Line_SlL_rec.cle_id;

  l_sll_tbl(l_index).chr_id                         := l_Line_SlL_rec.chr_id;
  l_sll_tbl(l_index).dnz_chr_id                     := l_Line_SlL_rec.dnz_chr_id;
  l_sll_tbl(l_index).uom_code                       := l_Line_SlL_rec.uom_code;
  l_sll_tbl(l_index).sequence_no                    := l_Line_SlL_rec.sequence_no;
  l_sll_tbl(l_index).Start_Date                     := l_Line_SlL_rec.Start_Date;
  IF l_Line_SlL_rec.end_Date IS NOT NULL THEN
    l_sll_tbl(l_index).end_Date                     := l_Line_SlL_rec.end_Date;
  ELSE
    l_update_required := 'Y';

    l_sll_tbl(l_index).end_Date                     := OKC_TIME_UTIL_PUB.get_enddate(
                                                          l_Line_SlL_rec.Start_Date,
                                                          l_Line_SlL_rec.uom_code,
                                                          (l_Line_SlL_rec.level_periods *
                                                                   l_Line_SlL_rec.uom_per_period));
  END IF;

  l_sll_tbl(l_index).level_periods                  := l_Line_SlL_rec.level_periods;
  l_sll_tbl(l_index).uom_per_period                 := l_Line_SlL_rec.uom_per_period;
  l_sll_tbl(l_index).level_amount                   := l_Line_SlL_rec.level_amount;
  l_sll_tbl(l_index).invoice_offset_days            := l_Line_SlL_rec.invoice_offset_days;
  l_sll_tbl(l_index).interface_offset_days          := l_Line_SlL_rec.interface_offset_days;

  l_index := l_index + 1;
END LOOP;

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

        fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.create_bill_sch_cp.sll_tbl',
                      'top line sll tbl count = ' || l_sll_tbl.count
                  );
END IF;

IF l_sll_tbl.COUNT = 0 THEN
   RETURN;
END IF;

-----errorout_ad('SLL found');
---for migrated contracts without end date
IF l_update_required = 'Y' THEN
   OKS_BILL_SCH.UPDATE_BS_ENDDATE(p_line_id      => p_top_line_id,
                                 p_chr_id        => NULL,
                                 x_return_status => x_return_status);

   IF x_return_status <> 'S' then
     RETURN;
   END IF;
END IF;




--get currency
l_currency_code := Find_Currency_Code(
                                    p_cle_id  => p_top_line_id,
                                    p_chr_id  => NULL);

IF l_currency_code IS NULL THEN
        OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'CURRENCY CODE NOT FOUND.');
        x_return_status := 'E';
        RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

----get subline
Open l_SubLine_Csr;
FETCH l_SubLine_Csr Into l_SubLine_Rec;
If l_SubLine_Csr%Notfound then
    Close l_SubLine_Csr;
    x_return_status := 'E';
    OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'SUB LINE NOT FOUND');
    RAISE G_EXCEPTION_HALT_VALIDATION;
End If;
Close l_SubLine_Csr;

l_cp_rec.cp_id          :=  l_SubLine_rec.subline_id ;
l_cp_rec.cp_start_dt    :=  l_SubLine_rec.cp_start_dt;
l_cp_rec.cp_end_dt      :=  l_SubLine_rec.cp_end_dt ;
l_cp_rec.cp_amt         :=  l_SubLine_rec.subline_amt ;
l_cp_rec.cp_price_uom   :=  l_subline_rec.price_uom;
l_cp_rec.cp_lse_id      :=  l_subline_rec.cp_lse_id;


IF l_period_type is not null AND l_period_start is not NULL THEN
    OPEN l_line_amt_csr(l_SubLine_rec.subline_id);
    FETCH l_line_amt_csr INTO l_cp_rec.cp_amt;
    CLOSE l_line_amt_csr;
END IF;
-----if the subline is update then chk if max_bill_dt = end date and update the price.
IF nvl(p_cp_new,'Y') = 'N' AND l_cp_rec.cp_amt > 0 THEN

   OKS_BILL_UTIL_PUB.Adjust_line_price(
                               p_top_line_id   => p_top_line_id,
                               p_sub_line_id   => p_cp_line_id ,
                               p_end_date      => l_cp_rec.cp_end_dt,
                               p_amount        => l_cp_rec.cp_amt,
                               p_dnz_chr_id    => l_line_csr_rec.dnz_chr_id,
                               x_amount        => l_amount,
                               x_return_status => x_return_status);

   l_cp_rec.cp_amt  := l_amount;
END IF;

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

   fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.create_bill_sch_cp.cp_dtls',
                      'p_cp_new = ' || p_cp_new
                   || ', id = ' || l_cp_rec.cp_id
                   || ', start dt = ' || l_cp_rec.cp_start_dt
                   || ', end dt = ' || l_cp_rec.cp_end_dt
                   || ', amt = ' || l_cp_rec.cp_amt
                   || ', full credit flag = ' || l_subline_rec.full_credit
                  );
END IF;


-----errorout_ad('sub line found');
IF nvl(l_SubLine_rec.cp_term_dt,l_SubLine_rec.cp_start_dt) > l_SubLine_rec.cp_end_dt then
  RETURN;
END IF;

---if full credit flag 'Y',term date to bill_sch_cp as cp start date so that
--level element doesn't get created.

IF l_subline_rec.cp_term_dt IS NOT NULL AND
   nvl(l_subline_rec.full_credit,'N') = 'Y' THEN

   l_cp_term_dt := l_subline_rec.cp_start_dt;
else
   l_cp_term_dt := l_subline_rec.cp_term_dt;
END IF;         ---end of full credit chk


l_top_bs_tbl.DELETE;
l_index  := 1;

FOR l_line_BS_rec IN l_line_BS_csr(p_top_line_id)
LOOP
  l_top_bs_tbl(l_index).id                     := l_line_BS_rec.id;
  l_top_bs_tbl(l_index).date_start             := l_line_BS_rec.date_start;
  l_top_bs_tbl(l_index).date_end               := l_line_BS_rec.date_end;
  l_top_bs_tbl(l_index).Amount                 := l_line_BS_rec.amount;
  l_top_bs_tbl(l_index).object_version_number  := l_line_BS_rec.object_version_number;
  l_top_bs_tbl(l_index).date_transaction   := l_line_BS_rec.date_transaction;
  l_top_bs_tbl(l_index).date_to_interface  := l_line_BS_rec.date_to_interface;

  l_index := l_index + 1;
END LOOP;             --top line lvl element

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

        fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.create_bill_sch_cp.bs_tbl',
                      'top line bs tbl count = ' || l_top_bs_tbl.count
                  );
END IF;

-----errorout_ad('line bs found');

IF l_top_bs_tbl.COUNT = 0 THEN           ---BS NOT CREATED FOR TOP LINE
  OKS_BILL_SCH.Create_Bill_Sch_Rules
     (
      p_billing_type         => l_Line_Csr_Rec.billing_schedule_type,
      p_sll_tbl              => l_sll_tbl,
      p_invoice_rule_id      => l_line_csr_rec.inv_id,
      x_bil_sch_out_tbl      => l_bil_sch_out_tbl,
      x_return_status        => x_return_status);

  IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_bill_sch_cp.call_bs',
                       'Create_Bill_Sch_Rules(x_return_status = '||x_return_status ||')');
  END IF;

  IF x_return_status <> 'S' THEN
     RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

else       ----call for cp only

  IF nvl(p_cp_new,'Y') = 'N' THEN
     --if cp already has bs then before calling Bill_Sch_Cp, adjust the amt of
    ---top line levl elements.

     Adjust_top_BS_Amt( p_Line_Rec          => l_Line_Rec,
                        p_SubLine_rec       => l_cp_Rec,
                        p_top_line_bs       => l_top_bs_tbl,
                        x_return_status     => x_return_status);

    IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_bill_sch_cp.adjust',
                       'adjust_top_bs_amt(x_return_status = '||x_return_status ||')');
    END IF;


     IF x_return_status <> 'S' THEN
         RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;

  END IF;

  ----------errorout_ad('calling Bill_Sch_Cp');
 --------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- Added two new parameters P_period_start,P_period_type in procedural call
 ---------------------------------------------------------------------------
  Bill_Sch_Cp
      (     p_billing_type      => l_Line_Csr_Rec.billing_schedule_type,
            p_bsll_tbl          => l_sll_tbl,
            p_Line_Rec          => l_Line_Rec,
            p_SubLine_rec       => l_cp_Rec,
            p_invoice_rulid     => l_line_csr_rec.inv_id,
            p_top_line_bs       => l_top_bs_tbl,
            p_term_dt           => l_cp_term_dt,
            p_period_start      =>  l_period_start,
            p_period_type       =>  l_period_type,
            x_return_status     => x_return_status);

  IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_bill_sch_cp.cp_bs',
                       'Bill_Sch_Cp(x_return_status = '||x_return_status ||')');
  END IF;




  IF x_return_status = 'S' then
     OKS_BILL_LEVEL_ELEMENTS_PVT.update_row(
               p_api_version                  => l_api_version,
               p_init_msg_list                => l_init_msg_list,
               x_return_status                => x_return_status,
               x_msg_count                    => x_msg_count,
               x_msg_data                     => x_msg_data,
               p_letv_tbl                     => l_top_bs_tbl,
               x_letv_tbl                     => l_lvl_ele_tbl_out);

     IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_bill_sch_cp.update_top_bs',
                       'oks_bill_level_elements_pvt.update_row(x_return_status = '||x_return_status ||')');
     END IF;
  else

    RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

END IF;

EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,G_MODULE_CURRENT||'.create_bill_sch_cp.EXCEPTION',
        'G_EXCEPTION_HALT_VALIDATION');
      END IF;

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
 WHEN OTHERS THEN
      IF FND_LOG.LEVEL_UNEXPECTED >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_unexpected,G_MODULE_CURRENT||'.create_bill_sch_cp.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
      END IF;
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;

END Create_Bill_Sch_CP;

Procedure Cascade_Dates_SLL
(
          p_top_line_id         IN    NUMBER,
          x_return_status       OUT   NOCOPY Varchar2,
          x_msg_count           OUT   NOCOPY NUMBER,
          x_msg_data            OUT   NOCOPY VARCHAR2)
IS

CURSOR l_line_sll_csr IS
       SELECT  sll.Id , sll.sequence_no , sll.start_date, sll.level_periods,
       sll.uom_per_period, sll.uom_code, sll.level_amount, sll.invoice_offset_days,
       sll.interface_offset_days, sll.cle_id, sll.chr_id,
       sll.dnz_chr_id, sll.end_date
       FROM oks_stream_levels_b sll
       WHERE sll.cle_id = p_top_line_id
       ORDER BY sll.sequence_no;


Cursor l_Line_Csr Is
 SELECT line.chr_id chr_id, line.dnz_chr_id dnz_chr_id, line.id id, line.lse_id lse_id,
        TRUNC(line.start_date) start_dt, TRUNC(line.end_date) end_dt,
        line.inv_rule_id inv_id,
         nvl(dtl.billing_schedule_type,'T') billing_schedule_type,
        (nvl(line.price_negotiated,0) +  nvl(dtl.ubt_amount,0) +
         nvl(dtl.credit_amount,0) +  nvl(dtl.suppressed_credit,0) ) line_amt
 FROM okc_k_lines_b line, oks_k_lines_b dtl
 WHERE  line.id = dtl.cle_id AND line.Id =  p_top_line_id ;

-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 07-JUN-2005
-- For usage , usage UOM drives the pricing/billing,
-- so adding the usage period in the cursor
--------------------------------------------------------------------------
CURSOR l_usage_type_csr IS
       SELECT usage_type,usage_period
       FROM  oks_k_lines_b
       WHERE  cle_id = p_top_line_id;

-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 07-JUN-2005
-- defining a new cursor to fetch the price uom stored for the
-- top line . This is used as the default billing period for the service lines.
--------------------------------------------------------------------------
CURSOR Get_price_uom IS
SELECT price_uom
FROM   OKS_K_LINES_B
WHERE  cle_id = p_top_line_id;



l_sll_tbl                 OKS_BILL_SCH.StreamLvl_tbl;
L_BIL_SCH_OUT_TBL         OKS_BILL_SCH.ItemBillSch_tbl;


l_Line_Sll_rec            l_Line_Sll_Csr%ROWTYPE;
l_Line_csr_Rec                l_Line_Csr%Rowtype;
l_line_rec                Line_Det_Type;

l_period_freq             NUMBER;
l_actual_freq             NUMBER;
l_uom_qty                 NUMBER;
l_index                   NUMBER;
l_sll_tbl_index           NUMBER;
l_sll_start_date          DATE;
l_sll_end_date            DATE;
l_sequence                NUMBER;
l_factor                  NUMBER;
l_next_date               DATE;
l_sll_ind                NUMBER;
l_timeunit                VARCHAR2(20);
l_duration                NUMBER;
l_difference              NUMBER;
l_msg_list                VARCHAR2(1) DEFAULT OKC_API.G_FALSE;
L_UOM_QUANTITY            number;
l_tce_code                VARCHAR2(100);
l_update_end_date         VARCHAR2(1);
l_usage_type              VARCHAR2(40);
l_amount                  NUMBER;
 -------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 04-MAY-2005
-- Local variables and cursors defined here required for cascade
---------------------------------------------------------------------------
l_price_uom         OKS_K_HEADERS_B.PRICE_UOM%TYPE;
l_period_start      OKS_K_HEADERS_B.PERIOD_START%TYPE;
l_period_type       OKS_K_HEADERS_B.PERIOD_TYPE%TYPE;
l_level_periods     NUMBER;
---------------------------------------------------------------------------
BEGIN

--it adjusts the sll and lvl element according to new line start and end date.

x_return_status := OKC_API.G_RET_STS_SUCCESS;

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

   fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.cascade_dates_sll.line_passed',
                      'top line id passed = ' || p_top_line_id );
END IF;


l_update_end_date   := 'N';
--find billing type of line

---get line details
Open l_Line_Csr;
Fetch l_Line_Csr Into l_Line_csr_Rec;

If l_Line_Csr%Notfound then
    Close l_Line_Csr;
    x_return_status := 'E';
    OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'LINE NOT FOUND');
    RAISE G_EXCEPTION_HALT_VALIDATION;
End If;
Close l_Line_Csr;


l_line_rec.chr_id          :=  l_Line_Csr_Rec.chr_id;
l_line_rec.dnz_chr_id      :=  l_Line_Csr_Rec.dnz_chr_id;
l_line_rec.id              :=  l_Line_Csr_Rec.id ;
l_line_rec.lse_id          :=  l_Line_Csr_Rec.lse_id;
l_line_rec.line_start_dt   :=  l_Line_Csr_Rec.start_dt;
l_line_rec.line_end_dt     :=  l_Line_Csr_Rec.end_dt;
l_line_rec.line_amt        :=  l_Line_Csr_Rec.line_amt ;

------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 04-MAY-2005
-- Fetching the period start and the period type
-------------------------------------------------------------------------
--Fetch the period start and period type stored at the header
IF  l_Line_Csr_Rec.dnz_chr_id is NOT NULL THEN
      OKS_RENEW_UTIL_PUB.Get_Period_Defaults
                 (
                 p_hdr_id        => l_Line_Csr_Rec.dnz_chr_id,
                 p_org_id        => NULL,
                 x_period_start  => l_period_start,
                 x_period_type   => l_period_type,
                 x_price_uom     => l_price_uom,
                 x_return_status => x_return_status);
      IF x_return_status <> 'S' THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
END IF;

IF l_period_start IS NOT NULL AND
   l_period_type IS NOT NULL
THEN
  OPEN Get_price_uom;
  FETCH Get_price_uom into l_price_uom;
  CLOSE Get_price_uom;
END IF;

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

   fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.cascade_dates_sll.line_dtls',
                      'dnz_chr_id = ' || l_line_rec.dnz_chr_id
                   || ', id = ' || l_line_rec.id
                   || ', lse_id = ' || l_line_rec.lse_id
                   || ', start dt = ' || l_line_rec.line_start_dt
                   || ', end dt = ' || l_line_rec.line_end_dt
                   || ', amt = ' || l_line_rec.line_amt
                   || ', bill_type = ' || l_Line_Csr_Rec.billing_schedule_type
                  );
END IF;



IF nvl(l_Line_Csr_Rec.billing_schedule_type,'E') <> 'T' then
   RETURN;
END IF;


---Code is added to adjust price of sub line if line is shrinked.
--and max billed to = end date then price becomes billed amount

IF l_Line_Rec.lse_id = 12 THEN
   Open l_usage_type_csr;
   -------------------------------------------------------------------------
   -- Begin partial period computation logic
   -- Developer Mani Choudhary
   -- Date 07-JUN-2005
   -- For usage , usage UOM drives the pricing/billing, so using that
   -- period start for usage will be 'SERVICE'
   --------------------------------------------------------------------------
   Fetch l_usage_type_csr INTO l_usage_type,l_price_uom;
   l_period_start := 'SERVICE';
   --------------------------------------------------------------------------

   IF l_usage_type_csr%FOUND THEN



     IF l_usage_type = 'NPR' THEN
        OKS_BILL_UTIL_PUB.Adjust_line_price(
                            p_top_line_id      =>  p_top_line_id,
                            p_sub_line_id      =>  NULL,
                            p_end_date         =>  NULL,
                            p_amount           =>  NULL,
                            p_dnz_chr_id       =>  l_Line_Rec.dnz_chr_id,
                            x_amount           =>  l_amount,
                            x_return_status    =>  x_return_status);

     End If;     ------usage type NPR chk

   END IF;             ----  l_usage_type_csr data found chk
   Close l_usage_type_csr;

ELSE          --- LINE lse_id <> 12
   OKS_BILL_UTIL_PUB.Adjust_line_price(
                            p_top_line_id      =>  p_top_line_id,
                            p_sub_line_id      =>  NULL,
                            p_end_date         =>  NULL,
                            p_amount           =>  NULL,
                            p_dnz_chr_id       =>  l_Line_Rec.dnz_chr_id,
                            x_amount           =>  l_amount,
                            x_return_status    =>  x_return_status);
END IF;

----make sll tbl

l_index := 1;
l_sll_tbl.DELETE;

FOR l_Line_SlL_rec IN l_Line_SlL_Csr
LOOP
  l_sll_tbl(l_index).id                             := l_Line_SlL_rec.id;
  l_sll_tbl(l_index).cle_id                         := l_Line_SlL_rec.cle_id;
  l_sll_tbl(l_index).chr_id                         := l_Line_SlL_rec.chr_id;
  l_sll_tbl(l_index).dnz_chr_id                     := l_Line_SlL_rec.dnz_chr_id;
  l_sll_tbl(l_index).uom_code                       := l_Line_SlL_rec.uom_code;
  l_sll_tbl(l_index).sequence_no                    := l_Line_SlL_rec.sequence_no;
  l_sll_tbl(l_index).Start_Date                     := l_Line_SlL_rec.Start_Date;

  IF l_Line_SlL_rec.end_Date IS NOT NULL THEN
     l_sll_tbl(l_index).end_Date                    := l_Line_SlL_rec.end_Date;
  ELSE
     l_update_end_date   := 'Y';
     l_sll_tbl(l_index).end_Date                    := OKC_TIME_UTIL_PUB.get_enddate(
                                                          l_Line_SlL_rec.Start_Date,
                                                  l_Line_SlL_rec.uom_code,
                                               l_Line_SlL_rec.level_periods *  l_Line_SlL_rec.uom_per_period);
  END IF;



  l_sll_tbl(l_index).level_periods                  := l_Line_SlL_rec.level_periods;
  l_sll_tbl(l_index).uom_per_period                 := l_Line_SlL_rec.uom_per_period;
  l_sll_tbl(l_index).level_amount                   := l_Line_SlL_rec.level_amount;
  l_sll_tbl(l_index).invoice_offset_days             := l_Line_SlL_rec.invoice_offset_days;
  l_sll_tbl(l_index).interface_offset_days          := l_Line_SlL_rec.interface_offset_days;

  l_index := l_index + 1;
END LOOP;                   --sll csr end loop

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

        fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.cascade_dates_sll.sll_tbl',
                      'top line sll tbl count = ' || l_sll_tbl.count
                  );
END IF;

IF l_sll_tbl.COUNT = 0 THEN
   RETURN;
END IF;

IF l_update_end_date = 'Y' THEN          ---Migrated
   OKS_BILL_SCH.UPDATE_BS_ENDDATE(p_line_id         => p_top_line_id,
                                  p_chr_id          => NULL,
                                  x_return_status   => x_return_status);

   IF x_return_status <> 'S' THEN
      RETURN;
   END IF;
END IF;            ---chk for migrated


-----errorout_ad('SLL found');



l_sll_tbl_index := l_sll_tbl.FIRST;

l_sll_start_date := TRUNC(l_sll_tbl(l_sll_tbl_index).Start_date);

IF TRUNC(l_sll_start_date) <> l_line_rec.line_start_dt THEN

   ---delete lvl element at one shot as line is not billed if start dt is changing.
   Del_sll_lvlelement(
                      p_top_line_id          => p_top_line_id,
                      x_return_status        => x_return_status,
                      x_msg_count            => x_msg_count,
                      x_msg_data             => x_msg_data);

    IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_dates_sll.del_lvl_ele',
                       'Del_sll_lvlelement(x_return_status = '||x_return_status
                       ||', line passed = '|| p_top_line_id ||')');
    END IF;


   IF x_return_status <> 'S' THEN
     RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;
END IF;           ---sll start dt not same as line start dt

IF TRUNC(l_sll_start_date) > l_line_rec.line_start_dt THEN
  ---add one sll in the starting with uom code got from timeutil pub

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

        fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.cascade_dates_sll.if_stat',
                      'sll st dt > line st dt'
                      || ', sll st dt = ' || l_sll_start_date
                   );
   END IF;

   IF l_period_start IS NOT NULL AND
      l_period_type IS NOT NULL  AND
      l_period_start = 'CALENDAR'
   THEN
     -- IF(TRUNC(l_sll_start_date,'MM') = TRUNC(l_sll_start_date)) THEN
        l_level_periods:=OKS_BILL_UTIL_PUB.Get_Periods(p_start_date   => l_line_rec.line_start_dt,
                                                       p_end_date     => TRUNC(l_sll_tbl(l_sll_tbl_index).End_date),
                                                       p_uom_code     => l_sll_tbl(l_sll_tbl_index).uom_code,
                                                       p_period_start => l_period_start);

        l_sequence := l_sll_tbl(l_sll_tbl_index).sequence_no;
        l_sll_tbl(l_sll_tbl_index).cle_id           := p_top_line_id;
        l_sll_tbl(l_sll_tbl_index).chr_id           := NULL;
        l_sll_tbl(l_sll_tbl_index).dnz_chr_id       := l_line_rec.dnz_chr_id;
        l_sll_tbl(l_sll_tbl_index).sequence_no      := l_sequence;
        l_sll_tbl(l_sll_tbl_index).start_date       := l_line_rec.line_start_dt;
        l_sll_tbl(l_sll_tbl_index).end_date         := TRUNC(l_sll_tbl(l_sll_tbl_index).End_date);
        l_sll_tbl(l_sll_tbl_index).level_periods     := ceil(l_level_periods/l_sll_tbl(l_sll_tbl_index).uom_per_period);
        l_next_date := OKS_BILL_UTIL_PUB.Get_Enddate_Cal(
                         p_start_date    => l_sll_tbl(l_sll_tbl_index).start_date,
                         p_uom_code      => l_sll_tbl(l_sll_tbl_index).uom_code,
                         p_duration      => l_sll_tbl(l_sll_tbl_index).uom_per_period,
                         p_level_periods => l_sll_tbl(l_sll_tbl_index).level_periods);
        IF l_next_date < l_sll_tbl(l_sll_tbl_index).end_date THEN
           l_sll_tbl(l_sll_tbl_index).level_periods := l_sll_tbl(l_sll_tbl_index).level_periods  + 1;
        END IF;
        l_sll_tbl(l_sll_tbl_index).uom_per_period   := l_sll_tbl(l_sll_tbl_index).uom_per_period;
        l_sll_tbl(l_sll_tbl_index).uom_code         := l_sll_tbl(l_sll_tbl_index).uom_code;
        l_sll_tbl(l_sll_tbl_index).level_amount     :=
                                 l_sll_tbl(l_sll_tbl_index).level_amount;
        l_sll_tbl(l_sll_tbl_index).invoice_offset_days :=
                          l_sll_tbl(l_sll_tbl_index).invoice_offset_days ;
        l_sll_tbl(l_sll_tbl_index).interface_offset_days         :=
                       l_sll_tbl(l_sll_tbl_index).interface_offset_days ;

     -- ELSE --sll start date not first day of calendar month

   ELSE --period start and period type are null
      --existing logic
      OKC_TIME_UTIL_PUB.get_duration(
            p_start_date    => l_line_rec.line_start_dt,
            p_end_date      => l_sll_start_date - 1,
            x_duration      => l_duration,
            x_timeunit      => l_timeunit,
            x_return_status => x_return_status);

    --mchoudha bug#5076095 added to_char for the dates in the following
    --fnd_log statement
      IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.cascade_dates_sll.sll_duration',
                       'okc_time_util_pub.get_duration(x_return_status = '||x_return_status
                       ||', end date in MM/DD/YYYY HH24:MI:SS = ' || to_char(l_sll_start_date - 1,'MM/DD/YYYY HH24:MI:SS')
                      ||', st date MM/DD/YYYY HH24:MI:SS ='|| to_char(l_line_rec.line_start_dt,'MM/DD/YYYY HH24:MI:SS')
                       ||', returned timeunit and duration = ' ||l_duration || '-' || l_timeunit ||')');
      END IF;



      IF x_return_status <> 'S' THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      OKS_BILL_UTIL_PUB.get_seeded_timeunit(
             p_timeunit      => l_timeunit,
             x_return_status => x_return_status,
             x_quantity      => l_uom_quantity ,
             x_timeunit      => l_tce_code);

      IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.cascade_dates_sll.seeded',
                       'okc_time_util_pub.get_seeded_timeunit(x_return_status = '||x_return_status
                       ||', returned timeunit and qty = ' ||l_tce_code || '-' || l_uom_quantity ||')');
      END IF;

      l_sequence := l_sll_tbl(l_sll_tbl_index).sequence_no - 1;

      l_sll_tbl(0).cle_id                        := p_top_line_id;
      l_sll_tbl(0).chr_id                        := NULL;
      l_sll_tbl(0).dnz_chr_id                    := l_line_rec.dnz_chr_id;
      l_sll_tbl(0).sequence_no                   := l_sequence;
      l_sll_tbl(0).start_date                    := l_line_rec.line_start_dt;
      l_sll_tbl(0).end_date                      := TRUNC(l_sll_start_date) - 1;

      IF l_tce_code = 'DAY' AND l_uom_quantity = 1 THEN
         l_sll_tbl(0).level_periods                 := 1;
         l_sll_tbl(0).uom_per_period                := l_duration;
      ELSE
         l_sll_tbl(0).level_periods                 := l_duration;
         l_sll_tbl(0).uom_per_period                := 1;
      END IF;

      l_sll_tbl(0).uom_code                      := l_timeunit;
      l_sll_tbl(0).level_amount                  := l_sll_tbl(l_sll_tbl_index).level_amount;
      l_sll_tbl(0).invoice_offset_days            := l_sll_tbl(l_sll_tbl_index).invoice_offset_days ;
      l_sll_tbl(0).interface_offset_days         := l_sll_tbl(l_sll_tbl_index).interface_offset_days ;


   END IF; --period start and period type ar not null

   IF l_sequence < 1 then

      l_factor :=  -(l_sequence - 1);
      l_sequence := l_sequence + l_factor;

      FOR l_sll_tbl_index IN l_sll_tbl.FIRST .. l_sll_tbl.LAST
      LOOP
         l_sll_tbl(l_sll_tbl_index).sequence_no   := l_sequence;
         l_sequence := l_sequence + 1;
      END LOOP;
   END IF;

   l_next_date := l_line_rec.line_start_dt;

   -----errorout_ad('l_sll_tbl.FIRST = ' || l_sll_tbl.FIRST);

   FOR l_sll_tbl_index IN l_sll_tbl.FIRST .. l_sll_tbl.LAST
   LOOP
      l_sll_tbl(l_sll_tbl_index).start_date     := TRUNC(l_next_date);

     -------------------------------------------------------------------------
     -- Begin partial period computation logic
     -- Developer Mani Choudhary
     -- Date 08-JUN-2005
     -- Derive the next billing date by calling the get_enddate_cal
     -------------------------------------------------------------------------
     IF l_period_start IS NOT NULL   AND
        l_period_type  IS NOT NULL   AND
        l_period_start = 'CALENDAR'
     THEN
       l_next_date := OKS_BILL_UTIL_PUB.Get_Enddate_Cal(
                         p_start_date    => l_sll_tbl(l_sll_tbl_index).start_date,
                         p_uom_code      => l_sll_tbl(l_sll_tbl_index).uom_code,
                         p_duration      => l_sll_tbl(l_sll_tbl_index).uom_per_period,
                         p_level_periods => l_sll_tbl(l_sll_tbl_index).level_periods);

     ELSE
       --existing logic
       l_next_date := OKC_TIME_UTIL_PUB.get_enddate(
               l_sll_tbl(l_sll_tbl_index).start_date,
                    l_sll_tbl(l_sll_tbl_index).uom_code,
                  (l_sll_tbl(l_sll_tbl_index).level_periods * l_sll_tbl(l_sll_tbl_index).uom_per_period));
     END IF;
     --------------------------------------------------------------------------------
      l_sll_tbl(l_sll_tbl_index).end_date     := TRUNC(l_next_date);

      l_next_date := l_next_date + 1;
   END LOOP;


ELSIF TRUNC(l_sll_start_date) < l_line_rec.line_start_dt THEN        ---LINE START DATE is pushed forward

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

        fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.cascade_dates_sll.chk_sll_dt',
                      'sll st dt < line st dt - line start date is pushed forward'
                      || ', sll st dt = ' || l_sll_start_date
                   );
   END IF;

   l_strm_lvl_tbl_in.delete;
   l_sll_ind := 1;
   l_sll_tbl_index := l_sll_tbl.FIRST ;

   -----errorout_ad('l_sll_start_date = '|| l_sll_start_date);

   ----delete first sll till sll start dt >= line start dt

   WHILE TRUNC(l_sll_start_date) < l_line_rec.line_start_dt AND l_sll_tbl.count > 0
   LOOP

      ----GET END DATE FOR THE sll
      l_sll_tbl_index := l_sll_tbl.FIRST ;

      l_sll_start_date := TRUNC(l_sll_tbl(l_sll_tbl_index).end_date) + 1;

      IF TRUNC(l_sll_tbl(l_sll_tbl_index).end_date) < l_line_rec.line_start_dt THEN
         ---put the sll in the table for deletion
         -----errorout_ad('added in delete sll tbl');

         l_strm_lvl_tbl_in(l_sll_ind).id := l_sll_tbl(l_sll_tbl_index).id;
         l_sll_ind := l_sll_ind + 1;

         l_sll_tbl.DELETE(l_sll_tbl_index);

      END IF;
   END LOOP;       --while end loop

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

        fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.cascade_dates_sll.sll_after_delete',
                      'sll count after deleting sll where sll end date < line start date'
                      || ', sll count = ' || l_sll_tbl.count
                   );
   END IF;

   IF l_strm_lvl_tbl_in.COUNT > 0 THEN


     OKS_SLL_PVT.delete_row(
            p_api_version        => l_api_version,
            p_init_msg_list      => l_msg_list,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            p_sllv_tbl           => l_strm_lvl_tbl_in);

     IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_dates_sll.del_sll',
                       'oks_sll_pvt.delete_row(x_return_status = '||x_return_status
                       ||', sll passed for delete = '|| l_strm_lvl_tbl_in.count ||')');
     END IF;


     IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
   END IF;

   IF l_sll_tbl.count > 0 then


     l_sll_tbl_index := l_sll_tbl.FIRST;

     l_sll_start_date := l_sll_tbl(l_sll_tbl_index).start_date;
     -----errorout_ad('l_sll_start_date after deleting = ' || l_sll_start_date);
     -----errorout_ad('first sll st dt = ' || l_sll_start_date || ' and line st dt = ' || l_line_rec.line_start_dt);

     IF l_line_rec.line_start_dt > TRUNC(l_sll_start_date) THEN

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

           fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.cascade_dates_sll.after_sll_del',
                      'after sll  delete line start date > sll start date'
                      || ', sll dt = ' || l_sll_start_date
                   );
        END IF;


        l_sll_tbl_index := l_sll_tbl.FIRST ;

        l_sll_end_date := l_sll_tbl(l_sll_tbl_index).end_date ;

        -------------------------------------------------------------------------
        -- Begin partial period computation logic
        -- Developer Mani Choudhary
        -- Date 08-JUN-2005
        -- Modify the current SLL to have SLL start date as line start date and
        -- SLL end date as current end date of SLL
        -------------------------------------------------------------------------
        IF l_period_start IS NOT NULL   AND
           l_period_type  IS NOT NULL    AND
           l_period_start = 'CALENDAR'
        THEN
          l_level_periods:=OKS_BILL_UTIL_PUB.Get_Periods(p_start_date => l_line_rec.line_start_dt,
                                                       p_end_date     => l_sll_end_date,
                                                       p_uom_code     => l_sll_tbl(l_sll_tbl_index).uom_code,
                                                       p_period_start => l_period_start);

          l_sll_tbl(l_sll_tbl_index).start_date       := l_line_rec.line_start_dt;
          l_sll_tbl(l_sll_tbl_index).end_date         := l_sll_end_date;
          l_sll_tbl(l_sll_tbl_index).level_periods     := ceil(l_level_periods/l_sll_tbl(l_sll_tbl_index).uom_per_period);
          l_next_date := OKS_BILL_UTIL_PUB.Get_Enddate_Cal(
                         p_start_date    => l_sll_tbl(l_sll_tbl_index).start_date,
                         p_uom_code      => l_sll_tbl(l_sll_tbl_index).uom_code,
                         p_duration      => l_sll_tbl(l_sll_tbl_index).uom_per_period,
                         p_level_periods => l_sll_tbl(l_sll_tbl_index).level_periods);
          IF l_next_date < l_sll_tbl(l_sll_tbl_index).end_date THEN
             l_sll_tbl(l_sll_tbl_index).level_periods := l_sll_tbl(l_sll_tbl_index).level_periods  + 1;
          END IF;

        ELSE --existing logic in this else block
          ----in migration not migrating sll end date so chk for old data
          IF l_sll_end_date IS NULL THEN
             IF l_sll_tbl_index < l_sll_tbl.LAST THEN
                l_sll_end_date  := l_sll_tbl(l_sll_tbl_index + 1).start_date + 1;

             ELSE
               l_sll_end_date := OKC_TIME_UTIL_PUB.get_enddate(
                              l_sll_tbl(l_sll_tbl_index).start_date,
                              l_sll_tbl(l_sll_tbl_index).uom_code,
                              (l_sll_tbl(l_sll_tbl_index).level_periods * l_sll_tbl(l_sll_tbl_index).uom_per_period));
             END IF;      --- chk for last sll

          END IF;            ---end of sll end date null

           -----errorout_ad('l_sll_end_date = ' || l_sll_end_date);

           ----find out the periods between line start date and SLL end date

          OKS_BILL_UTIL_PUB.get_seeded_timeunit(
             p_timeunit      => l_sll_tbl(l_sll_tbl_index).uom_code,
             x_return_status => x_return_status,
             x_quantity      => l_uom_quantity ,
             x_timeunit      => l_tce_code);

          IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.cascade_dates_sll.seed',
                       'okc_time_util_pub.get_seeded_timeunit(x_return_status = '||x_return_status
                       ||', returned timeunit and qty = ' ||l_tce_code || '-' || l_uom_quantity ||')');
          END IF;

          IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
             RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
          --mchoudha for bug#4860210
          --  IF l_tce_code = 'DAY' THEN

          --   l_period_freq := (l_sll_end_date - l_line_rec.line_start_dt) + 1;

          --  IF nvl(l_sll_tbl(l_sll_tbl_index).uom_per_period,1) = 1 THEN
          --    l_sll_tbl(l_sll_tbl_index).uom_per_period   := l_period_freq;
          --  ELSE
          --    l_actual_freq := nvl(l_period_freq,0)/nvl(l_sll_tbl(l_sll_tbl_index).uom_per_period,1);

           --   l_actual_freq := ceil(l_actual_freq);

            --  l_sll_tbl(l_sll_tbl_index).level_periods  := l_actual_freq;

           -- END IF;

         -- ELSE         ----not day

            l_period_freq := OKS_BILL_UTIL_PUB.get_frequency
                            (p_tce_code      => l_tce_code,
                             p_fr_start_date => l_line_rec.line_start_dt,
                             p_fr_end_date   => l_sll_end_date,
                             p_uom_quantity  => l_uom_quantity,
                             x_return_status => x_return_status);

            IF x_return_status <> 'S' THEN
               RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
            -----errorout_ad('l_period_freq = ' || l_period_freq);
            l_actual_freq := nvl(l_period_freq,0)/nvl(l_sll_tbl(l_sll_tbl_index).uom_per_period,1);

           -- l_actual_freq := ceil(l_period_freq);
            l_actual_freq := ceil(l_actual_freq);
            -----errorout_ad('l_actual_freq = ' || l_actual_freq);
            -----errorout_ad('l_sll_tbl_index  of sll rec changing = ' || l_sll_tbl_index);
            l_sll_tbl(l_sll_tbl_index).level_periods  := l_actual_freq;


         -- END IF;         -------not day

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

           fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.cascade_dates_sll.sll_add',
                      'sll added after deleting sll where sll_end_dt < line_start_dt');
          END IF;

        END IF; --period type and period start are not null
     END IF; --l_line_rec.line_start_dt > TRUNC(l_sll_start_date)

     l_next_date := l_line_rec.line_start_dt;

     FOR l_sll_tbl_index IN l_sll_tbl.FIRST .. l_sll_tbl.LAST
     LOOP
        l_sll_tbl(l_sll_tbl_index).start_date     := TRUNC(l_next_date);
     -------------------------------------------------------------------------
     -- Begin partial period computation logic
     -- Developer Mani Choudhary
     -- Date 08-JUN-2005
     -- Derive the next billing date by calling the get_enddate_cal
     -------------------------------------------------------------------------
     IF l_period_start IS NOT NULL   AND
        l_period_type  IS NOT NULL   AND
        l_period_start = 'CALENDAR'
     THEN
       l_next_date := OKS_BILL_UTIL_PUB.Get_Enddate_Cal(
                         p_start_date    => l_sll_tbl(l_sll_tbl_index).start_date,
                         p_uom_code      => l_sll_tbl(l_sll_tbl_index).uom_code,
                         p_duration      => l_sll_tbl(l_sll_tbl_index).uom_per_period,
                         p_level_periods => l_sll_tbl(l_sll_tbl_index).level_periods);

     ELSE
        --Existing logic
        l_next_date := OKC_TIME_UTIL_PUB.get_enddate(
                l_sll_tbl(l_sll_tbl_index).start_date,
                l_sll_tbl(l_sll_tbl_index).uom_code,
                (l_sll_tbl(l_sll_tbl_index).uom_per_period * l_sll_tbl(l_sll_tbl_index).level_periods));

     END IF;
     ---------------------------------------------------------------------------------
        l_sll_tbl(l_sll_tbl_index).end_date     := TRUNC(l_next_date);
        l_next_date := l_next_date + 1;
     END LOOP;



  ELSE                    ---sll tbl count = 0 after deletion

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

           fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.cascade_dates_sll.sll_cnt',
                      'sll count zero after deleting sll where sll_end_dt < line_start_dt');
    END IF;



      OKC_TIME_UTIL_PUB.get_duration(
             p_start_date    => l_line_rec.line_start_dt,
             p_end_date      => l_line_rec.line_end_dt,
             x_duration      => l_duration,
             x_timeunit      => l_timeunit,
             x_return_status => x_return_status);

      IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_dates_sll.duration',
                       'okc_time_util_pub.get_duration(x_return_status = '||x_return_status
                       ||', l_duration = '|| l_duration
                       ||', l_timeunit = ' || l_timeunit ||')');
      END IF;

      IF x_return_status <> 'S' THEN
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      OKS_BILL_UTIL_PUB.get_seeded_timeunit(
                p_timeunit      => l_timeunit,
                x_return_status => x_return_status,
                x_quantity      => l_uom_quantity ,
                x_timeunit      => l_tce_code);

      IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_dates_sll.call_seed',
                       'okc_time_util_pub.get_seeded_timeunit(x_return_status = '||x_return_status
                       ||', l_uom_quantity = '|| l_uom_quantity
                       ||', l_tce_code = ' || l_tce_code ||')');
      END IF;

    -------------------------------------------------------------------------
    -- Begin partial period computation logic
    -- Developer Mani Choudhary
    -- Date 08-JUN-2005
    -- Create one SLL line start date to line end date
    -------------------------------------------------------------------------
    IF l_period_start IS NOT NULL   AND
       l_period_type  IS NOT NULL    AND
       l_period_start = 'CALENDAR'
    THEN
       IF l_price_uom IS NULL THEN
          l_price_uom := l_timeunit;
       END IF;
       l_level_periods:=OKS_BILL_UTIL_PUB.Get_Periods(p_start_date => l_line_rec.line_start_dt,
                                                      p_end_date     => l_line_rec.line_end_dt,
                                                      p_uom_code     => l_price_uom,
                                                      p_period_start => l_period_start);

       l_sll_tbl(1).cle_id           := p_top_line_id;
       l_sll_tbl(1).chr_id           := NULL;
       l_sll_tbl(1).dnz_chr_id       := l_line_rec.dnz_chr_id;
       l_sll_tbl(1).sequence_no      := 1;
       l_sll_tbl(1).start_date       := l_line_rec.line_start_dt;
       l_sll_tbl(1).end_date         := l_line_rec.line_end_dt;
       l_sll_tbl(1).level_periods     := l_level_periods;
       l_sll_tbl(1).uom_per_period   := 1;
       l_sll_tbl(1).uom_code         := l_price_uom;
       l_sll_tbl(1).level_amount     := NULL;
       l_sll_tbl(1).invoice_offset_days := NULL;
       l_sll_tbl(1).interface_offset_days := NULL;

    ELSE --existing logic in this else block

      l_sll_tbl(1).cle_id                        := p_top_line_id;
      l_sll_tbl(1).chr_id                        := NULL;
      l_sll_tbl(1).dnz_chr_id                    := l_line_rec.dnz_chr_id;
      l_sll_tbl(1).sequence_no                   := 1;
      l_sll_tbl(1).start_date                    := l_line_rec.line_start_dt;
      l_sll_tbl(1).end_date                      := l_line_rec.line_end_dt;

      IF l_tce_code = 'DAY' AND l_uom_quantity = 1 THEN
        l_sll_tbl(1).level_periods                 := 1;
        l_sll_tbl(1).uom_per_period                := l_duration;
      ELSE
        l_sll_tbl(1).level_periods                 := l_duration;
        l_sll_tbl(1).uom_per_period                := 1;
      END IF;

      l_sll_tbl(1).uom_code                      := l_timeunit;
      l_sll_tbl(1).level_amount                  := NULL;
      l_sll_tbl(1).invoice_offset_days           := NULL ;
      l_sll_tbl(1).interface_offset_days         := NULL ;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

         fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.cascade_dates_sll.sll_one',
                      'sll added count one');
      END IF;
    END IF;  --period start and period type not null
  END IF; --sll count = 0

END IF;



----find end date of last SLL

IF l_sll_tbl.COUNT > 0 THEN

  l_sll_tbl_index := l_sll_tbl.LAST;

  l_sll_start_date := l_sll_tbl(l_sll_tbl_index).start_date;
  l_sll_END_date := l_sll_tbl(l_sll_tbl_index).end_date;
  l_sll_start_date := l_sll_END_date + 1;
ELSE
  RETURN;

end if;



  IF TRUNC(l_sll_END_date) < l_line_rec.line_END_dt THEN          ---LINE date extended

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

      fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.cascade_dates_sll.chk_end_dt',
                      'sll end dt < line_end_dt'
                   || ', sl end dt = ' || l_sll_END_date);
    END IF;

    IF l_sll_tbl.COUNT > 0 THEN

        -------------------------------------------------------------------------
        -- Begin partial period computation logic
        -- Developer Mani Choudhary
        -- Date 08-JUN-2005
        -- Modify the current SLL to have SLL start date as line start date and
        -- SLL end date as current end date of SLL
        -------------------------------------------------------------------------
        IF l_period_start IS NOT NULL   AND
           l_period_type  IS NOT NULL    AND
           l_period_start = 'CALENDAR'
        THEN
          l_level_periods:=OKS_BILL_UTIL_PUB.Get_Periods(p_start_date => l_sll_tbl(l_sll_tbl_index).start_date,
                                                       p_end_date     => l_line_rec.line_END_dt,
                                                       p_uom_code     => l_sll_tbl(l_sll_tbl_index).uom_code,
                                                       p_period_start => l_period_start);

          l_sll_tbl(l_sll_tbl_index).cle_id           := p_top_line_id;
          l_sll_tbl(l_sll_tbl_index).chr_id           := NULL;
          l_sll_tbl(l_sll_tbl_index).dnz_chr_id       := l_line_rec.dnz_chr_id;
          l_sll_tbl(l_sll_tbl_index).sequence_no      := l_sll_tbl(l_sll_tbl_index).sequence_no;
          l_sll_tbl(l_sll_tbl_index).start_date       :=  l_sll_tbl(l_sll_tbl_index).start_date;
          l_sll_tbl(l_sll_tbl_index).end_date         := l_line_rec.line_END_dt;
          l_sll_tbl(l_sll_tbl_index).level_periods     := ceil(l_level_periods/l_sll_tbl(l_sll_tbl_index).uom_per_period);
          l_next_date := OKS_BILL_UTIL_PUB.Get_Enddate_Cal(
                         p_start_date    => l_sll_tbl(l_sll_tbl_index).start_date,
                         p_uom_code      => l_sll_tbl(l_sll_tbl_index).uom_code,
                         p_duration      => l_sll_tbl(l_sll_tbl_index).uom_per_period,
                         p_level_periods => l_sll_tbl(l_sll_tbl_index).level_periods);
          IF l_next_date < l_sll_tbl(l_sll_tbl_index).end_date THEN
             l_sll_tbl(l_sll_tbl_index).level_periods := l_sll_tbl(l_sll_tbl_index).level_periods  + 1;
          END IF;
        --  l_sll_tbl(l_sll_tbl_index).uom_per_period   := l_sll_tbl(l_sll_tbl_index).uom_per_period;
         -- l_sll_tbl(l_sll_tbl_index).uom_code         := l_price_uom;
          l_sll_tbl(l_sll_tbl_index).level_amount     :=
                                 l_sll_tbl(l_sll_tbl_index).level_amount;
          l_sll_tbl(l_sll_tbl_index).invoice_offset_days :=
                          l_sll_tbl(l_sll_tbl_index).invoice_offset_days ;
          l_sll_tbl(l_sll_tbl_index).interface_offset_days         :=
                       l_sll_tbl(l_sll_tbl_index).interface_offset_days ;

        ELSE --existing logic in this else block


          OKS_BILL_UTIL_PUB.get_seeded_timeunit(
                p_timeunit      => l_sll_tbl(l_sll_tbl_index).uom_code,
                x_return_status => x_return_status,
                x_quantity      => l_uom_quantity ,
                x_timeunit      => l_tce_code);

          IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_dates_sll.st_end_seed',
                       'okc_time_util_pub.get_seeded_timeunit(x_return_status = '||x_return_status
                       ||', l_uom_quantity = '|| l_uom_quantity
                       ||', l_tce_code = ' || l_tce_code ||')');
          END IF;



          IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
        --mchoudha for bug#4860210
        --  IF l_tce_code = 'DAY' AND nvl(l_uom_quantity,1) = 1 THEN

         --    l_period_freq := (l_line_rec.line_END_dt - l_sll_start_date) + 1;
         -- ELSE
          -----errorout_ad('l_sll_start_date of new sll to be inserted = '|| l_sll_start_date);

            l_uom_qty := nvl(l_sll_tbl(l_sll_tbl_index).uom_per_period,1) * nvl(l_uom_quantity,1);

            l_period_freq := OKS_BILL_UTIL_PUB.get_frequency
                               (p_tce_code      => l_tce_code,
                                p_fr_start_date => l_sll_start_date,
                                p_fr_end_date   => l_line_rec.line_END_dt,
                                p_uom_quantity  => l_uom_qty,
                                x_return_status => x_return_status);

            IF x_return_status <> 'S' THEN
              RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

            l_period_freq := ceil(l_period_freq);


         -- END IF;

          l_sequence := l_sll_tbl(l_sll_tbl_index).sequence_no + 1;

          -----errorout_ad('l_sequence of sll inserted = ' || l_sequence);
          -----errorout_ad('l_sll_tbl_index at time of inserting record = ' || l_sll_tbl_index );

          l_sll_tbl(l_sll_tbl_index + 1).sequence_no         := l_sequence;
          l_sll_tbl(l_sll_tbl_index + 1).start_date          := TRUNC(l_sll_start_date);



         -- IF l_tce_code = 'DAY' AND nvl(l_uom_quantity,1) = 1 THEN
         --   l_sll_tbl(l_sll_tbl_index + 1).level_periods      := '1';
         --   l_sll_tbl(l_sll_tbl_index + 1).uom_per_period     := l_period_freq;
         --   l_sll_tbl(l_sll_tbl_index + 1).end_date           := l_line_rec.line_end_dt;
         -- ELSE
            l_sll_tbl(l_sll_tbl_index + 1).level_periods      := l_period_freq;
            l_sll_tbl(l_sll_tbl_index + 1).uom_per_period     := l_sll_tbl(l_sll_tbl_index).uom_per_period;

            l_sll_tbl(l_sll_tbl_index + 1).end_date := OKC_TIME_UTIL_PUB.get_enddate(
                                                   l_sll_start_date,
                                                   l_sll_tbl(l_sll_tbl_index).uom_code,
                                                   l_period_freq * l_sll_tbl(l_sll_tbl_index).uom_per_period);

         -- END IF;

          l_sll_tbl(l_sll_tbl_index + 1).uom_code               := l_sll_tbl(l_sll_tbl_index).uom_code;
          l_sll_tbl(l_sll_tbl_index + 1).invoice_offset_days     := l_sll_tbl(l_sll_tbl_index).invoice_offset_days;
          l_sll_tbl(l_sll_tbl_index + 1).interface_offset_days  := l_sll_tbl(l_sll_tbl_index).interface_offset_days;
          l_sll_tbl(l_sll_tbl_index + 1).level_amount           := l_sll_tbl(l_sll_tbl_index).level_amount;
          l_sll_tbl(l_sll_tbl_index + 1).cle_id                 := l_sll_tbl(l_sll_tbl_index ).cle_id ;
          l_sll_tbl(l_sll_tbl_index + 1).chr_id                 := l_sll_tbl(l_sll_tbl_index ).chr_id  ;
          l_sll_tbl(l_sll_tbl_index + 1).dnz_chr_id             := l_sll_tbl(l_sll_tbl_index ).dnz_chr_id;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

           fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.cascade_dates_sll.all_sll_end',
                      'added sll when sll end dt < line_end_dt');
          END IF;

        END IF;    --period start and period type are not null
   ELSE            ---sll tbl count = 0


      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

        fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.cascade_dates_sll.sll_zero',
                      'sll count zero');
      END IF;


      OKC_TIME_UTIL_PUB.get_duration(
             p_start_date    => l_line_rec.line_start_dt,
             p_end_date      => l_line_rec.line_end_dt,
             x_duration      => l_duration,
             x_timeunit      => l_timeunit,
             x_return_status => x_return_status);

      IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_dates_sll.sll_duration',
                       'okc_time_util_pub.get_duration(x_return_status = '||x_return_status
                       ||', l_duration = '|| l_duration
                       ||', l_timeunit = ' || l_timeunit ||')');
      END IF;


      IF x_return_status <> 'S' THEN
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      OKS_BILL_UTIL_PUB.get_seeded_timeunit(
                p_timeunit      => l_timeunit,
                x_return_status => x_return_status,
                x_quantity      => l_uom_quantity ,
                x_timeunit      => l_tce_code);

      IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_dates_sll.end_seed',
                       'okc_time_util_pub.get_seeded_timeunit(x_return_status = '||x_return_status
                       ||', l_uom_quantity = '|| l_uom_quantity
                       ||', l_tce_code = ' || l_tce_code ||')');
       END IF;

    -------------------------------------------------------------------------
    -- Begin partial period computation logic
    -- Developer Mani Choudhary
    -- Date 08-JUN-2005
    -- Create one SLL line start date to line end date
    -------------------------------------------------------------------------
    IF l_period_start IS NOT NULL   AND
       l_period_type  IS NOT NULL    AND
       l_period_start = 'CALENDAR'
    THEN
       IF l_price_uom IS NULL THEN
          l_price_uom := l_timeunit;
       END IF;
       l_level_periods:=OKS_BILL_UTIL_PUB.Get_Periods(p_start_date => l_line_rec.line_start_dt,
                                                      p_end_date     => l_line_rec.line_end_dt,
                                                      p_uom_code     => l_price_uom,
                                                      p_period_start => l_period_start);

       l_sll_tbl(1).cle_id           := p_top_line_id;
       l_sll_tbl(1).chr_id           := NULL;
       l_sll_tbl(1).dnz_chr_id       := l_line_rec.dnz_chr_id;
       l_sll_tbl(1).sequence_no      := 1;
       l_sll_tbl(1).start_date       := l_line_rec.line_start_dt;
       l_sll_tbl(1).end_date         := l_line_rec.line_end_dt;
       l_sll_tbl(1).level_periods     := l_level_periods;
       l_sll_tbl(1).uom_per_period   := 1;
       l_sll_tbl(1).uom_code         := l_price_uom;
       l_sll_tbl(1).level_amount     := NULL;
       l_sll_tbl(1).invoice_offset_days := NULL;
       l_sll_tbl(1).interface_offset_days := NULL;

    ELSE --existing logic in this else block


      l_sequence := 1;
      l_sll_tbl_index := 0;


      l_sll_tbl(l_sll_tbl_index).sequence_no         := l_sequence;
      l_sll_tbl(l_sll_tbl_index).start_date          := l_line_rec.line_start_dt;
      l_sll_tbl(l_sll_tbl_index).end_date           := l_line_rec.line_end_dt;



      IF l_tce_code = 'DAY' AND nvl(l_uom_quantity,1) = 1 THEN
        l_sll_tbl(l_sll_tbl_index ).level_periods      := '1';
        l_sll_tbl(l_sll_tbl_index ).uom_per_period     := l_period_freq;

      ELSE
        l_sll_tbl(l_sll_tbl_index ).level_periods      := l_period_freq;
        l_sll_tbl(l_sll_tbl_index ).uom_per_period     := l_sll_tbl(l_sll_tbl_index).uom_per_period;


      END IF;

      l_sll_tbl(l_sll_tbl_index).uom_code               := l_timeunit;
      l_sll_tbl(l_sll_tbl_index).cle_id                 := l_line_rec.id ;
      l_sll_tbl(l_sll_tbl_index).chr_id                 := null;
      l_sll_tbl(l_sll_tbl_index).dnz_chr_id             := l_line_rec.dnz_chr_id;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

         fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.cascade_dates_sll.sll_one_end',
                      'sll added count one');
      END IF;

    END IF;         --period start and period type are not null
  END IF;           -----sll tbl count


--no changes for partial period calendar in this case
ELSIF TRUNC(l_sll_END_date) > l_line_rec.line_END_dt THEN          ---LINE END DATE SHRINKED.

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

         fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.cascade_dates_sll.chk_end_dt',
                      'sll end dt > line end dt'
                     ||', sll end dt = ' || l_sll_END_date );
   END IF;

   IF l_sll_tbl.count = 0 then
     RETURN;
   END IF;

   l_sll_tbl_index := l_sll_tbl.LAST;
   l_sll_start_date := l_sll_tbl(l_sll_tbl_index ).start_date;

   l_strm_lvl_tbl_in.DELETE;
   l_sll_ind := 1;

   WHILE l_line_rec.line_END_dt < TRUNC(l_sll_start_date) AND l_sll_tbl.COUNT > 0
   LOOP

      l_strm_lvl_tbl_in(l_sll_ind).id := l_sll_tbl(l_sll_tbl_index).id;
      l_sll_ind := l_sll_ind + 1;

      l_sll_tbl.DELETE(l_sll_tbl_index);

      l_sll_tbl_index := l_sll_tbl.LAST;
      l_sll_start_date := l_sll_tbl(l_sll_tbl_index ).start_date;
   END LOOP;

   IF l_strm_lvl_tbl_in.COUNT > 0 THEN
      FOR l_sll_ind IN l_strm_lvl_tbl_in.FIRST .. l_strm_lvl_tbl_in.LAST
      LOOP

         OKS_BILL_UTIL_PUB.delete_level_elements (
                                 p_api_version     => l_api_version,
                                 p_rule_id         => l_strm_lvl_tbl_in(l_sll_ind).id,
                                 p_init_msg_list   => l_msg_list,
                                 x_msg_count       => x_msg_count,
                                 x_msg_data        => x_msg_data,
                                 x_return_status   => x_return_status );

         IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_dates_sll.del_last_sll',
                       'oks_bill_util_pub.delete_level_elements(x_return_status = '||x_return_status
                       ||', sll id passed = '|| l_strm_lvl_tbl_in(l_sll_ind).id ||')');
         END IF;



      END LOOP;
      IF x_return_status <> 'S' THEN
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

   END IF;
END IF;

IF l_sll_tbl.COUNT > 0 THEN

  OKS_BILL_SCH.Create_Bill_Sch_Rules
     (p_billing_type         => l_line_csr_rec.billing_schedule_type,
      p_sll_tbl              => l_sll_tbl,
      p_invoice_rule_id      => l_line_csr_rec.inv_id,
      x_bil_sch_out_tbl      => l_bil_sch_out_tbl,
      x_return_status        => x_return_status);

  IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.create_dates_sll.call_bs',
                       'oks_bill_sch.Create_Bill_Sch_Rules(x_return_status = '||x_return_status ||')');
  END IF;

  IF x_return_status <> 'S' THEN
     RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;
END IF;



EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN

       IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,G_MODULE_CURRENT||'.create_dates_sll.EXCEPTION',
                    'G_EXCEPTION_HALT_VALIDATION');
       END IF;

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
 WHEN OTHERS THEN

       IF FND_LOG.LEVEL_UNEXPECTED >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_unexpected,G_MODULE_CURRENT||'.create_dates_sll.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
       END IF;

        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;

END Cascade_Dates_SLL;




PROCEDURE Del_sll_lvlelement(p_top_line_id          IN  NUMBER,
                             x_return_status        OUT NOCOPY VARCHAR2,
                             x_msg_count            OUT NOCOPY NUMBER,
                             x_msg_data             OUT NOCOPY VARCHAR2)

IS
----will delete all lvlelements for top and cp
---and delete sll of all cp.


BEGIN
x_return_status := 'S';


----delete lvl elements for cp
DELETE FROM   OKS_LEVEL_ELEMENTS
WHERE cle_id IN (SELECT id
       FROM  OKC_K_LINES_B cp
       WHERE cp.cle_id = p_top_line_id
       and cp.lse_id in (35,7,8,9,10,11,13,18,25));



--------delete lvl elemets for top line
DELETE FROM OKS_LEVEL_ELEMENTS
WHERE  cle_id  = p_top_line_id;


---delete sll of all cp

DELETE FROM OKS_STREAM_LEVELS_B
WHERE cle_id IN ( select id
                  FROM okc_k_lines_b cp
                  WHERE cp.cle_id = p_top_line_id
                  and cp.lse_id in (35,7,8,9,10,11,13,18,25));



EXCEPTION
  WHEN OTHERS THEN

    IF FND_LOG.LEVEL_UNEXPECTED >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_unexpected,G_MODULE_CURRENT||'.del_sll_lvlelement.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
    END IF;
    OKC_API.SET_MESSAGE(p_app_name         => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END Del_sll_lvlelement;


PROCEDURE Adjust_top_BS_Amt(
                        p_Line_Rec          IN     Line_Det_Type,
                        p_SubLine_rec       IN     Prod_Det_Type,
                        p_top_line_bs       IN OUT NOCOPY oks_bill_level_elements_pvt.letv_tbl_type,
                        x_return_status     OUT    NOCOPY VARCHAR2)
IS

CURSOR l_cp_BS_csr(p_cp_id  NUMBER) IS
         SELECT id, trunc(date_start) date_start,
         amount, trunc(date_end) date_end
         FROM oks_level_elements element
         WHERE cle_id = p_cp_id
         ORDER by date_start;

l_cp_BS_rec          l_cp_BS_csr%ROWTYPE;
l_cp_bs_tbl          oks_bill_level_elements_pvt.letv_tbl_type;
l_index              number;
l_top_bs_ind         number;
l_cp_bs_ind          number;


BEGIN
x_return_status := OKC_API.G_RET_STS_SUCCESS;

l_cp_bs_tbl.DELETE;
l_index  := 1;

FOR l_cp_BS_rec IN l_cp_BS_csr(p_SubLine_rec.cp_id)
LOOP
  l_cp_bs_tbl(l_index).id              := l_cp_BS_rec.id;
  l_cp_bs_tbl(l_index).date_start      := l_cp_BS_rec.date_start;
  l_cp_bs_tbl(l_index).date_end        := l_cp_BS_rec.date_end;
  l_cp_bs_tbl(l_index).Amount          := l_cp_BS_rec.amount;

  l_index := l_index + 1;
END LOOP;

IF l_cp_bs_tbl.COUNT <= 0 THEN
   RETURN;
END IF;

l_cp_bs_ind := l_cp_bs_tbl.FIRST;
l_top_bs_ind := p_top_line_bs.FIRST;
-----errorout_ad('top line bs first = ' || l_top_bs_ind);

WHILE TRUNC(l_cp_bs_tbl(l_cp_bs_ind).date_start) > TRUNC(p_top_line_bs(l_top_bs_ind).DATE_START) AND
             l_top_bs_ind < p_top_line_bs.LAST
LOOP
    l_top_bs_ind := p_top_line_bs.NEXT(l_top_bs_ind);
END LOOP;

-----errorout_ad('after while loop in adj = ' || l_top_bs_ind);
---chk first cp bs.st_dt if between previous and present record


IF l_top_bs_ind = p_top_line_bs.first THEN
   NULL;

ELSIF  l_top_bs_ind <= p_top_line_bs.LAST THEN

  l_top_bs_ind := l_top_bs_ind - 1;
  IF TRUNC(l_cp_bs_tbl(l_cp_bs_ind).date_start) >= p_top_line_bs(l_top_bs_ind  ).DATE_START
      AND TRUNC(l_cp_bs_tbl(l_cp_bs_ind).date_start) <= p_top_line_bs(l_top_bs_ind ).DATE_end THEN

                    NULL;
  ELSE
      l_top_bs_ind := l_top_bs_ind + 1;
  END IF;

elsif TRUNC(l_cp_bs_tbl(l_cp_bs_ind).date_start) = TRUNC(p_top_line_bs(l_top_bs_ind).DATE_START) THEN
       NULL;

end if;


FOR l_cp_bs_ind IN l_cp_bs_tbl.FIRST .. l_cp_bs_tbl.LAST
LOOP

 IF l_top_bs_ind  <= p_top_line_bs.LAST THEN

    p_top_line_bs(l_top_bs_ind).amount := nvl(p_top_line_bs(l_top_bs_ind).amount,0) - nvl(l_cp_bs_tbl(l_cp_bs_ind).amount,0);
    l_top_bs_ind  := l_top_bs_ind + 1;

 END IF;
END LOOP;


EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,G_MODULE_CURRENT||'.adjust_top_bs_amt.EXCEPTION',
                    'G_EXCEPTION_HALT_VALIDATION');
       END IF;

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
 WHEN OTHERS THEN

       IF FND_LOG.LEVEL_UNEXPECTED >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_unexpected,G_MODULE_CURRENT||'.adjust_top_bs_amt.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
       END IF;

        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;

end Adjust_top_BS_Amt;



Procedure Update_OM_SLL_Date
(
          p_top_line_id         IN    NUMBER,
          x_return_status       OUT   NOCOPY Varchar2,
          x_msg_count           OUT   NOCOPY NUMBER,
          x_msg_data            OUT   NOCOPY VARCHAR2)
IS

CURSOR l_line_sll_csr IS
       SELECT id, cle_id, chr_id, dnz_chr_id , uom_code,
              sequence_no, Start_Date, end_Date, level_periods,
              uom_per_period, level_amount, invoice_offset_days, interface_offset_days
       FROM OKs_stream_levels_b
       WHERE cle_id = p_top_line_id
       ORDER BY sequence_no;


Cursor l_Line_Csr Is
 SELECT line.chr_id chr_id, line.dnz_chr_id dnz_chr_id, line.id id, line.lse_id lse_id,
        TRUNC(line.start_date) start_dt,line.inv_rule_id inv_rule_id,
        nvl(trunc(line.date_terminated - 1),TRUNC(line.end_date)) end_dt,
        nvl(dtl.billing_schedule_type,'T') billing_schedule_type,
        (nvl(line.price_negotiated,0) +  nvl(dtl.ubt_amount,0) +
         nvl(dtl.credit_amount,0) +  nvl(dtl.suppressed_credit,0) ) line_amt
 FROM okc_k_lines_b line, oks_k_lines_b dtl
 WHERE  line.id = dtl.cle_id AND line.Id =  p_top_line_id ;




l_sll_tbl                 OKS_BILL_SCH.StreamLvl_tbl;
L_BIL_SCH_OUT_TBL         OKS_BILL_SCH.ItemBillSch_tbl;
l_inv_id                  number;

l_Line_Sll_rec            l_Line_Sll_Csr%ROWTYPE;
l_Line_Rec                l_Line_Csr%Rowtype;


l_index                   NUMBER;
l_sll_tbl_index           NUMBER;
l_timeunit                VARCHAR2(20);
l_duration                NUMBER;
L_UOM_QUANTITY            number;
l_tce_code                VARCHAR2(100);

l_msg_list                VARCHAR2(1) DEFAULT OKC_API.G_FALSE;



BEGIN

x_return_status := OKC_API.G_RET_STS_SUCCESS;

---get line details
Open l_Line_Csr;
Fetch l_Line_Csr Into l_Line_Rec;

If l_Line_Csr%Notfound then
    Close l_Line_Csr;
    x_return_status := 'E';
    OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'LINE NOT FOUND');
    RAISE G_EXCEPTION_HALT_VALIDATION;
End If;
Close l_Line_Csr;


IF l_line_rec.billing_schedule_type <> 'T' then
   RETURN;
END IF;

----make sll tbl

l_index := 1;
l_sll_tbl.DELETE;

FOR l_Line_SlL_rec IN l_Line_SlL_Csr
LOOP
  l_sll_tbl(l_index).id                             := l_Line_SlL_rec.id;
  l_sll_tbl(l_index).cle_id                         := l_Line_SlL_rec.cle_id;
  l_sll_tbl(l_index).chr_id                         := l_Line_SlL_rec.chr_id;
  l_sll_tbl(l_index).dnz_chr_id                     := l_Line_SlL_rec.dnz_chr_id;
  l_sll_tbl(l_index).uom_code                       := l_Line_SlL_rec.uom_code;
  l_sll_tbl(l_index).sequence_no                    := l_Line_SlL_rec.sequence_no;
  l_sll_tbl(l_index).Start_Date                     := l_Line_SlL_rec.Start_Date;
  l_sll_tbl(l_index).end_Date                       := l_Line_SlL_rec.end_Date;
  l_sll_tbl(l_index).level_periods                  := l_Line_SlL_rec.level_periods;
  l_sll_tbl(l_index).uom_per_period                 := l_Line_SlL_rec.uom_per_period;
  l_sll_tbl(l_index).level_amount                   := l_Line_SlL_rec.level_amount;
  l_sll_tbl(l_index).invoice_offset_days            := l_Line_SlL_rec.invoice_offset_days;
  l_sll_tbl(l_index).interface_offset_days          := l_Line_SlL_rec.interface_offset_days;

  l_index := l_index + 1;
END LOOP;


IF l_sll_tbl.COUNT = 0 THEN
   x_return_status := 'E';
    OKC_API.SET_MESSAGE (
             p_app_name        => G_PKG_NAME,
             p_msg_name        => 'OKS_SLL_NOT_EXISTS');

   RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;


-----errorout_ad('SLL found');




l_sll_tbl_index := l_sll_tbl.FIRST;

Del_sll_lvlelement(
                   p_top_line_id          => p_top_line_id,
                   x_return_status        => x_return_status,
                   x_msg_count            => x_msg_count,
                   x_msg_data             => x_msg_data);

IF x_return_status <> 'S' THEN
   RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

OKC_TIME_UTIL_PUB.get_duration(
           p_start_date    => l_line_rec.start_dt,
           p_end_date      => l_line_rec.end_dt,
           x_duration      => l_duration,
           x_timeunit      => l_timeunit,
           x_return_status => x_return_status);


IF x_return_status <> 'S' THEN
   RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

OKS_BILL_UTIL_PUB.get_seeded_timeunit(
              p_timeunit      => l_timeunit,
              x_return_status => x_return_status,
              x_quantity      => l_uom_quantity ,
              x_timeunit      => l_tce_code);

l_sll_tbl(l_sll_tbl_index).start_date           := l_line_rec.start_dt;
l_sll_tbl(l_sll_tbl_index).end_date             := l_line_rec.end_dt;
l_sll_tbl(l_sll_tbl_index).level_periods        := '1';
l_sll_tbl(l_sll_tbl_index).uom_per_period       := l_duration;
l_sll_tbl(l_sll_tbl_index).uom_code             := l_timeunit;




IF l_sll_tbl.COUNT > 0 THEN

  OKS_BILL_SCH.Create_Bill_Sch_Rules
     (p_billing_type         => l_line_rec.billing_schedule_type,
      p_sll_tbl              => l_sll_tbl,
      p_invoice_rule_id      => l_line_rec.inv_rule_id,
      x_bil_sch_out_tbl      => l_bil_sch_out_tbl,
      x_return_status        => x_return_status);

  IF x_return_status <> 'S' THEN
     RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;
END IF;



EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,G_MODULE_CURRENT||'.update_om_sll_date.EXCEPTION',
                    'G_EXCEPTION_HALT_VALIDATION');
      END IF;

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
 WHEN OTHERS THEN
      IF FND_LOG.LEVEL_UNEXPECTED >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_unexpected,G_MODULE_CURRENT||'.update_om_sll_date.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
       END IF;

        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;

END Update_OM_SLL_Date;

PROCEDURE Del_rul_elements(p_top_line_id          IN  NUMBER,
                             x_return_status      OUT NOCOPY VARCHAR2,
                             x_msg_count          OUT NOCOPY  NUMBER,
                             x_msg_data           OUT NOCOPY VARCHAR2)

IS


----will delete all lvlelements for top and cp
---and delete sll of top line and all cp.
---make billing schedule type null for all cp.



BEGIN
x_return_status := 'S';


----delete lvl elements for cp
DELETE FROM   OKS_LEVEL_ELEMENTS
WHERE  cle_id IN (SELECT cp.id
       FROM OKC_k_LINES_B cp
       WHERE cp.cle_id = p_top_line_id
       and cp.lse_id in (35,7,8,9,10,11,13,18,25));


--------delete lvl elemets for top line
DELETE FROM OKS_LEVEL_ELEMENTS
WHERE  cle_id = p_top_line_id;


---delete sll of cp

delete FROM OKS_STREAM_LEVELS_B
WHERE cle_id IN (SELECT id
       FROM OKC_k_LINES_B cp
       WHERE  cp.cle_id = p_top_line_id
       and cp.lse_id in (35,7,8,9,10,11,13,18,25));

--DELETE sll of top line

delete FROM OKS_STREAM_LEVELS_B
WHERE  cle_id = p_top_line_id;

--update billing type to null for cp
UPDATE oks_k_lines_b
set billing_schedule_type = NULL
WHERE cle_id IN (SELECT id
       FROM OKC_k_LINES_B cp
       WHERE  cp.cle_id = p_top_line_id
       and cp.lse_id in (35,7,8,9,10,11,13,18,25));



EXCEPTION
  WHEN OTHERS THEN
     IF FND_LOG.LEVEL_UNEXPECTED >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_unexpected,G_MODULE_CURRENT||'.del_rul_elements.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
     END IF;

    OKC_API.SET_MESSAGE(p_app_name         => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;


END Del_rul_elements;


---delete sll of subline and refresh the lvl amt of top line for 'Top Level' billing
PROCEDURE Del_subline_lvl_rule(p_top_line_id        IN  NUMBER,
                              p_sub_line_id         IN  NUMBER,
                              x_return_status       OUT NOCOPY VARCHAR2,
                              x_msg_count           OUT NOCOPY  NUMBER,
                              x_msg_data            OUT NOCOPY VARCHAR2)
IS
----will delete all lvlelements for  cp
---and delete sll of cp.
--update amount of lvl element of top line
--UPDATE billing type of subline to null.

CURSOR l_line_BS_csr IS
         SELECT id, trunc(date_start) date_start,
         amount, TRUNC(DATE_end) date_end, object_version_number
         FROM oks_level_elements
         WHERE cle_id = p_top_line_id
         ORDER BY date_start;

CURSOR l_cp_BS_csr IS
         SELECT id, trunc(date_start) date_start,
         amount
         FROM oks_level_elements
         WHERE cle_id = p_sub_line_id
         ORDER BY date_start;




CURSOR l_bill_type_csr IS
       SELECT nvl(billing_schedule_type,'T') billing_schedule_type
       FROM oks_k_lines_b
       WHERE cle_id = p_sub_line_id;




l_line_BS_rec        l_line_BS_csr%ROWTYPE;
l_cp_BS_rec          l_cp_BS_csr%ROWTYPE;
l_bill_type_rec      l_bill_type_csr%ROWTYPE;



l_top_bs_tbl         oks_bill_level_elements_pvt.letv_tbl_type;
l_cp_bs_tbl          oks_bill_level_elements_pvt.letv_tbl_type;
x_letv_tbl           oks_bill_level_elements_pvt.letv_tbl_type;


i                    NUMBER := 0;
l_index              NUMBER := 0;
l_cp_bs_ind          NUMBER;
l_top_bs_ind         NUMBER;

l_api_Version              Number      := 1;
l_init_msg_list            VARCHAR2(2000) := OKC_API.G_FALSE;
l_msg_list                 VARCHAR2(1) DEFAULT OKC_API.G_FALSE;
l_msg_count                Number;
l_msg_data                 Varchar2(2000) := NULL;

BEGIN
x_return_status := 'S';

---get bill type details
Open l_bill_type_Csr;
Fetch l_bill_type_Csr Into l_bill_type_Rec;

If l_bill_type_csr%Notfound then
    Close l_bill_type_Csr;
    x_return_status := 'E';
     OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'BILLING SCHEDULE TYPE NOT FOUND.');
    RAISE G_EXCEPTION_HALT_VALIDATION;
End If;
Close l_bill_type_Csr;

IF l_bill_type_rec.billing_schedule_type = 'T' then

  l_index  := 0;
  l_top_bs_tbl.DELETE;
  FOR l_line_BS_rec IN l_line_BS_csr
  LOOP
   l_top_bs_tbl(l_index).id                     := l_line_BS_rec.id;
   l_top_bs_tbl(l_index).date_start             := l_line_BS_rec.date_start;
   l_top_bs_tbl(l_index).Amount                 := l_line_BS_rec.amount;
   l_top_bs_tbl(l_index).date_end               := l_line_BS_rec.date_end;
   l_top_bs_tbl(l_index).object_version_number  := l_line_BS_rec.object_version_number;

   l_index := l_index + 1;
  END LOOP;

  l_index  := 0;
  l_cp_bs_tbl.DELETE;
  FOR l_cp_BS_rec IN l_cp_BS_csr
  LOOP
    l_cp_bs_tbl(l_index).id              := l_cp_BS_rec.id;
    l_cp_bs_tbl(l_index).date_start      := l_cp_BS_rec.date_start;
    l_cp_bs_tbl(l_index).Amount          := l_cp_BS_rec.amount;

    l_index := l_index + 1;
  END LOOP;

  IF l_cp_bs_tbl.COUNT > 0 THEN


     l_cp_bs_ind  := l_cp_bs_tbl.FIRST;
     l_top_bs_ind := l_top_bs_tbl.FIRST;

     WHILE l_cp_bs_tbl(l_cp_bs_ind).date_start > l_top_bs_tbl(l_top_bs_ind).DATE_START
             AND l_top_bs_ind < l_top_bs_tbl.LAST
     LOOP
       l_top_bs_ind := l_top_bs_tbl.NEXT(l_top_bs_ind);
     END LOOP;




   IF l_top_bs_ind = l_top_bs_tbl.first THEN
      NULL;

   ELSIF  l_top_bs_ind <= l_top_bs_tbl.LAST THEN

     l_top_bs_ind := l_top_bs_ind - 1;

     IF TRUNC(l_cp_bs_tbl(l_cp_bs_ind).date_start) >= l_top_bs_tbl(l_top_bs_ind  ).DATE_START
      AND TRUNC(l_cp_bs_tbl(l_cp_bs_ind).date_start) <= l_top_bs_tbl(l_top_bs_ind ).DATE_end THEN

          NULL;
     ELSE
         l_top_bs_ind := l_top_bs_ind + 1;
     END IF;

    elsif TRUNC(l_cp_bs_tbl(l_cp_bs_ind).date_start) = TRUNC(l_top_bs_tbl(l_top_bs_ind).DATE_START) THEN
       NULL;

   end if;




   FOR l_cp_bs_ind IN l_cp_bs_tbl.FIRST .. l_cp_bs_tbl.LAST
   LOOP

        l_top_bs_tbl(l_top_bs_ind).amount := nvl(l_top_bs_tbl(l_top_bs_ind).amount,0) - nvl(l_cp_bs_tbl(l_cp_bs_ind).amount,0);
        l_top_bs_ind  := l_top_bs_ind + 1;
   END LOOP;

   OKS_BILL_LEVEL_ELEMENTS_PVT.update_row(
               p_api_version                  => l_api_version,
               p_init_msg_list                => l_init_msg_list,
               x_return_status                => x_return_status,
               x_msg_count                    => l_msg_count,
               x_msg_data                     => l_msg_data,
               p_letv_tbl                     => l_top_bs_tbl,
               x_letv_tbl                     => l_lvl_ele_tbl_out);

     IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

  END IF;          ---l_cp_bs_tbl.COUNT > 0


END IF;      ---l_bill_type = 'T'


----delete lvl elements for cp
DELETE FROM   OKS_LEVEL_ELEMENTS
WHERE  cle_id = p_sub_line_id;


----Delete sll of cp

Delete oks_stream_levels_b
where cle_id = p_sub_line_id;





EXCEPTION
  WHEN OTHERS THEN
    OKC_API.SET_MESSAGE(p_app_name         => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END Del_subline_lvl_rule;




PROCEDURE update_bs_interface_date(p_top_line_id         IN    NUMBER,
                                   p_invoice_rule_id     IN    Number,
                                   x_return_status       OUT   NOCOPY VARCHAR2,
                                   x_msg_count           OUT   NOCOPY NUMBER,
                                   x_msg_data            OUT   NOCOPY VARCHAR2)

IS

CURSOR l_line_csr IS
       SELECT ln.id id, ln.lse_id lse_id, nvl(TRUNC(ln.date_terminated -1),ln.end_date) line_end_date,
              dtl.usage_type usage_type, dtl.billing_schedule_type billing_schedule_type
       FROM okc_k_lines_b ln, oks_k_lines_b dtl
       WHERE ln.id = p_top_line_id
       AND dtl.cle_id = ln.id;


Cursor l_subLine_Csr Is
        SELECT id ,nvl(TRUNC(date_terminated -1),end_date) cp_end_date, lse_id
        FROM okc_k_lines_b
        WHERE cle_id = p_top_line_id and lse_id in (35,7,8,9,10,11,13,18,25);

CURSOR l_Line_BS_csr IS
         SELECT id, trunc(date_start) date_start,
         date_to_interface, date_transaction, date_end
         FROM oks_level_elements
         WHERE cle_id = p_top_line_id
         AND date_completed IS NOT NULL
         ORDER BY date_start;



l_subLine_rec        l_subLine_Csr%ROWTYPE;
l_index              NUMBER := 0;
l_update_bs_tbl      oks_bill_level_elements_pvt.letv_tbl_type;
l_lvl_index          NUMBER := 0;
l_line_rec           l_line_csr%ROWTYPE;

l_cp_line_bs         oks_bill_level_elements_pvt.letv_tbl_type;
l_line_tbl_in        oks_bill_level_elements_pvt.letv_tbl_type;
l_top_index          NUMBER := 0;


l_init_msg_list VARCHAR2(2000) := OKC_API.G_FALSE;

BEGIN

x_return_status := OKC_API.G_RET_STS_SUCCESS;

IF p_invoice_rule_id IS NULL THEN
-- nechatur 23-DEC-2005 for bug#4684706
-- OKC_API.set_message(G_PKG_NAME,'OKS_INVD_COV_RULE','RULE_NAME','IRE');
   OKC_API.set_message(G_PKG_NAME,'OKS_INVOICING_RULE');
-- end bug#4684706
   x_return_status := 'E';
   RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

OPEN l_line_csr;
FETCH l_line_csr Into l_line_rec;

If l_line_csr%NOTFOUND THEN
    CLOSE l_line_csr;
    OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'LINE NOT FOUND');
    x_return_status := G_RET_STS_UNEXP_ERROR;
    RETURN;
ELSE
    Close l_line_csr;
END IF;

IF l_line_rec.lse_id = 12 AND NVL(l_line_rec.usage_type,1) IN ('VRT','QTY') THEN       ---A/P OR A/Q
   RETURN;
END IF;

l_lvl_ele_tbl_in.DELETE;

Adjust_interface_date(p_line_id           => p_top_line_id,
                      p_invoice_rule_id   => p_invoice_rule_id,
                      p_line_end_date     => l_line_rec.line_end_date,
                      p_lse_id            => l_line_rec.lse_id,
                      x_bs_tbl            => l_update_bs_tbl,
                      x_return_status     => x_return_status,
                      x_msg_count         => x_msg_count,
                      x_msg_data          => x_msg_data);

IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

IF l_update_bs_tbl.COUNT <= 0 THEN
   RETURN;
END IF;

FOR L_index IN l_update_bs_tbl.FIRST .. l_update_bs_tbl.LAST
LOOP

  l_lvl_ele_tbl_in(l_lvl_index).id                     := l_update_bs_tbl(l_index).id;
  l_lvl_ele_tbl_in(l_lvl_index).date_start             := l_update_bs_tbl(l_index).date_start;
  l_lvl_ele_tbl_in(l_lvl_index).date_to_interface      := l_update_bs_tbl(l_index).date_to_interface;
  l_lvl_ele_tbl_in(l_lvl_index).object_version_number  := l_update_bs_tbl(l_index).object_version_number;
  l_lvl_ele_tbl_in(l_lvl_index).date_to_interface      := l_update_bs_tbl(l_index).date_to_interface;
  l_lvl_ele_tbl_in(l_lvl_index).date_transaction       := l_update_bs_tbl(l_index).date_transaction;


  l_lvl_index  := l_lvl_index + 1;
END LOOP;

IF l_line_rec.billing_schedule_type = 'P' THEN
  ----Find subline and update interface date of sublines level elements

  For l_subLine_rec IN l_subLine_csr
  LOOP

    Adjust_interface_date(
                      p_line_id           => l_subLine_rec.id,
                      p_invoice_rule_id   => p_invoice_rule_id,
                      p_line_end_date     => l_subline_rec.cp_end_date,
                      p_lse_id            => l_subline_rec.lse_id,
                      x_bs_tbl            => l_update_bs_tbl,
                      x_return_status     => x_return_status,
                      x_msg_count         => x_msg_count,
                      x_msg_data          => x_msg_data);

   IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

   IF l_update_bs_tbl.COUNT > 0 THEN

     FOR L_index IN l_update_bs_tbl.FIRST .. l_update_bs_tbl.LAST
     LOOP

       l_lvl_ele_tbl_in(l_lvl_index).id                 := l_update_bs_tbl(l_index).id;
       l_lvl_ele_tbl_in(l_lvl_index).date_start         := l_update_bs_tbl(l_index).date_start;
       l_lvl_ele_tbl_in(l_lvl_index).date_to_interface  := l_update_bs_tbl(l_index).date_to_interface;
       l_lvl_ele_tbl_in(l_lvl_index).object_version_number  := l_update_bs_tbl(l_index).object_version_number;

       l_lvl_index  := l_lvl_index + 1;
     END LOOP;

   END IF;       ---- l_update_bs_tbl.COUNT > 0

  END LOOP;            ----subline csr

ELSE              ----billing type E and T

   ---interface/trx dt should be same for cp and top line. build tbl for billed lvl_element for top line
   ---and merge tbl with not billed. as some of the cp may be added later which are not billed yet.

   l_top_index := 1;
   l_line_tbl_in.DELETE;

   ---billed top line lvl element

   FOR l_Line_BS_rec IN l_Line_BS_csr
   LOOP

     l_line_tbl_in(l_top_index).id                 := l_Line_BS_rec.id;
     l_line_tbl_in(l_top_index).date_start         := l_Line_BS_rec.date_start;
     l_line_tbl_in(l_top_index).date_to_interface  := l_Line_BS_rec.date_to_interface;
     l_line_tbl_in(l_top_index).date_transaction   := l_Line_BS_rec.date_transaction;

     l_top_index  := l_top_index + 1;
   END LOOP;

   ----unbilled lvl element for top line added to l_line_tbl_in
   FOR L_index IN l_update_bs_tbl.FIRST .. l_update_bs_tbl.LAST
   LOOP

     l_line_tbl_in(l_top_index).id                 := l_update_bs_tbl(l_index).id;
     l_line_tbl_in(l_top_index).date_start         := l_update_bs_tbl(l_index).date_start;
     l_line_tbl_in(l_top_index).date_to_interface  := l_update_bs_tbl(l_index).date_to_interface;
     l_line_tbl_in(l_top_index).date_transaction   := l_update_bs_tbl(l_index).date_transaction;

     l_top_index  := l_top_index + 1;
   END LOOP;


  For l_subLine_rec IN l_subLine_csr
  LOOP

    Adjust_cp_trx_inv_dt(
                     p_top_bs_tbl        => l_line_tbl_in,
                     p_SubLine_id        => l_subLine_rec.id,
                     x_cp_line_bs        => l_cp_line_bs,
                     x_return_status     => x_return_status);

   IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

   IF l_cp_line_bs.COUNT > 0 THEN

     FOR L_index IN l_cp_line_bs.FIRST .. l_cp_line_bs.LAST
     LOOP

       l_lvl_ele_tbl_in(l_lvl_index).id                    := l_cp_line_bs(l_index).id;
       l_lvl_ele_tbl_in(l_lvl_index).date_start            := l_cp_line_bs(l_index).date_start;
       l_lvl_ele_tbl_in(l_lvl_index).date_to_interface     := l_cp_line_bs(l_index).date_to_interface;
       l_lvl_ele_tbl_in(l_lvl_index).date_transaction      := l_cp_line_bs(l_index).date_transaction;
       l_lvl_ele_tbl_in(l_lvl_index).object_version_number := l_cp_line_bs(l_index).object_version_number;

       l_lvl_index  := l_lvl_index + 1;
     END LOOP;

   END IF;       ---- l_cp_line_bs.COUNT > 0

  END LOOP;            ----subline csr

END IF;             ---chk billing schedule type



-----errorout_ad('l_lvl_ele_tbl_in.COUNT = ' || l_lvl_ele_tbl_in.COUNT );

IF l_lvl_ele_tbl_in.COUNT > 0 THEN
   OKS_BILL_LEVEL_ELEMENTS_PVT.update_row(
               p_api_version                  => l_api_version,
               p_init_msg_list                => l_init_msg_list,
               x_return_status                => x_return_status,
               x_msg_count                    => x_msg_count,
               x_msg_data                     => x_msg_data,
               p_letv_tbl                     => l_lvl_ele_tbl_in,
               x_letv_tbl                     => l_lvl_ele_tbl_out);

    IF  x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
END IF;


EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
  NULL;

 WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;


END update_bs_interface_date;


Procedure Adjust_interface_date(p_line_id           IN  NUMBER,
                                p_invoice_rule_id   IN  Number,
                                p_line_end_date     IN  DATE,
                                p_lse_id            IN  NUMBER,
                                x_bs_tbl            OUT NOCOPY oks_bill_level_elements_pvt.letv_tbl_type,
                                x_return_status     OUT NOCOPY VARCHAR2,
                                x_msg_count         OUT NOCOPY NUMBER,
                                x_msg_data          OUT NOCOPY VARCHAR2)
IS




Cursor l_Line_SLL_CSR(l_line_id NUMBER) is
        SELECT id, cle_id, chr_id, dnz_chr_id , uom_code,
              sequence_no, Start_Date, end_Date, level_periods,
              uom_per_period, level_amount, invoice_offset_days, interface_offset_days
        FROM OKS_STREAM_LEVELS_B
        WHERE  cle_id = l_line_id
        ORDER BY sequence_no;

CURSOR l_lvl_element_csr(l_sll_id  NUMBER) IS
       SELECT id,date_start, date_end, date_to_interface,
              date_transaction , object_version_number
       FROM oks_level_elements
       WHERE rul_id = l_sll_id AND date_completed IS NULL
       ORDER BY date_start;



l_Line_SLL_rec       l_Line_SLL_csr%ROWTYPE;
l_lvl_element_rec    l_lvl_element_csr%ROWTYPE;


l_index              NUMBER := 0;
l_bs_index           NUMBER := 0;
l_bs_tbl             oks_bill_level_elements_pvt.letv_tbl_type;
l_sll_end_date       DATE;
l_interface_offset   NUMBER;
l_date_to_interface  DATE;
l_out_index          NUMBER  := 0;

l_action_offset      NUMBER;
l_date_transaction   DATE;

BEGIN

x_return_status  := OKC_API.G_RET_STS_SUCCESS;


For l_Line_SLL_rec IN l_Line_SLL_csr(p_line_id)
LOOP

    l_bs_index  := 0;
    l_bs_tbl.delete;

    IF l_line_SLL_rec.end_date IS NOT NULL THEN

           l_sll_end_date  := l_line_SLL_rec.end_date;
    ELSE
           l_sll_end_date  := OKC_TIME_UTIL_PUB.get_enddate(
                                                        l_Line_SlL_rec.Start_Date,
                                                        l_Line_SlL_rec.UOM_CODE,
                                  l_Line_SlL_rec.uom_per_period * l_Line_SlL_rec.level_periods);
    END IF;




    FOR l_lvl_element_rec IN l_lvl_element_csr(l_Line_SLL_rec.id)
    LOOP
       l_bs_tbl(l_bs_index).id                      := l_lvl_element_rec.id;
       l_bs_tbl(l_bs_index).date_start              := l_lvl_element_rec.date_start;
       l_bs_tbl(l_bs_index).date_end                := l_lvl_element_rec.date_end;
       l_bs_tbl(l_bs_index).date_to_interface       := l_lvl_element_rec.date_to_interface;
       l_bs_tbl(l_bs_index).date_transaction        := l_lvl_element_rec.date_transaction;
       l_bs_tbl(l_bs_index).object_version_number   := l_lvl_element_rec.object_version_number;

       -----errorout_ad('before date_to_interface = ' || l_bs_tbl(l_bs_index).date_to_interface);

       l_bs_index := l_bs_index + 1;

    END LOOP;

    IF l_bs_tbl.COUNT > 0 THEN


       l_interface_offset  := NVL(TO_NUMBER(l_Line_SLL_rec.interface_offset_days),0);
       l_action_offset     := NVL(TO_NUMBER(l_Line_SLL_rec.invoice_offset_days),0);

       FOR l_index IN l_bs_tbl.FIRST .. l_bs_tbl.LAST
       LOOP

         ---calculate trx date

        If nvl(p_invoice_rule_id,-2) = -2 Then

          l_date_transaction := l_bs_tbl(l_index).date_start + l_action_offset;

          If l_date_transaction < SYSDATE Then
            l_date_transaction := SYSDATE;
          End if;

        Elsif nvl(p_invoice_rule_id,-2) = -3 Then

          IF l_bs_tbl(l_index ).date_end IS NOT NULL THEN

          l_date_transaction :=  l_bs_tbl(l_index ).date_end  + l_action_offset;

          ELSE           ---end dt null for migrated contracts

            IF l_index < l_bs_tbl.LAST THEN
              l_date_transaction := (l_bs_tbl(l_index + 1).date_start - 1 ) + l_action_offset;
            ELSE              ---not last
              IF p_lse_id <> 46  THEN
               l_date_transaction := LEAST(l_sll_end_date, p_line_end_date ) + l_action_offset;
              ELSE
               l_date_transaction := okc_time_util_pub.get_enddate
                        (l_bs_tbl(l_index).date_start,
                         l_Line_SLL_rec.uom_code,
                         l_Line_SLL_rec.uom_per_period) + l_action_offset;
              END IF;             ---chk for 46
             END IF;            ---chk for last

          END IF;              ---end date null chk

           ----l_date_transaction SHOULD not be less then bill from date and sysdate.
          IF l_date_transaction < l_bs_tbl(l_index).date_start  THEN
            l_date_transaction := l_bs_tbl(l_index).date_start ;
          END IF;

          If l_date_transaction < SYSDATE Then
            l_date_transaction := SYSDATE;
          End if;

        End if;        --chk for advance for trx date



         ---calculate inv date

         If nvl(p_invoice_rule_id,-2) = -2 Then   /*** advance ***/

            l_date_to_interface := l_bs_tbl(l_index).date_start  + NVL(l_interface_offset,0);

            IF l_date_to_interface > LEAST(l_date_transaction, l_bs_tbl(l_index).date_start)  Then

               l_date_to_interface := LEAST(l_date_transaction, l_bs_tbl(l_index).date_start);
            End if;

          ELSIF nvl(p_invoice_rule_id,-2) = -3 Then

            IF l_index <> l_bs_tbl.LAST THEN

               IF l_bs_tbl(l_index ).date_end IS NULL THEN
                 l_date_to_interface := l_bs_tbl(l_index + 1).date_start + NVL(l_interface_offset,0);  /** Bill to date + 1 ***/
               ELSE

                 l_date_to_interface := l_bs_tbl(l_index ).date_end + 1 + NVL(l_interface_offset,0);  /** Bill to date + 1 ***/
               END IF;

            ELSE

               IF l_sll_end_date > p_line_end_date THEN
                 l_date_to_interface := p_line_end_date + 1 + NVL(l_interface_offset,0);
               ELSE
                 l_date_to_interface := l_sll_end_date + 1 + NVL(l_interface_offset,0);
               END IF;
            END IF;
         END IF;             ---end of advance/arrears for inv

         ------Assign interface date in tbl
         IF l_date_to_interface IS NOT NULL THEN
           l_bs_tbl(l_index).date_to_interface  := l_date_to_interface;
         END IF;

         IF l_date_to_interface IS NOT NULL THEN
           l_bs_tbl(l_index).date_transaction  := l_date_transaction;
         END IF;

         x_bs_tbl(l_out_index).id                     :=  l_bs_tbl(l_index).id   ;
         x_bs_tbl(l_out_index).date_start             :=  l_bs_tbl(l_index).date_start ;
         x_bs_tbl(l_out_index).date_end               :=  l_bs_tbl(l_index).date_end ;
         x_bs_tbl(l_out_index).date_to_interface      :=  TRUNC(l_bs_tbl(l_index).date_to_interface);
         x_bs_tbl(l_out_index).object_version_number  :=  l_bs_tbl(l_index).object_version_number;
         x_bs_tbl(l_out_index).date_transaction       :=  TRUNC(l_bs_tbl(l_index).date_transaction);

         l_out_index  := l_out_index + 1;
       END LOOP;


   END IF;          ---end of l_bs_tbl.COUNT > 0
END LOOP;            ----SLL CSR


EXCEPTION

 WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;
END Adjust_interface_date;


Procedure Cascade_Dt_lines_SLL
(
          p_contract_id         IN    NUMBER,
          p_line_id             IN    NUMBER,
          x_return_status       OUT   NOCOPY Varchar2)

IS

CURSOR l_top_line_Csr Is
       SELECT id
       FROM   OKC_K_LINES_b
       WHERE  chr_id =  p_contract_id
       AND lse_id IN (1, 12, 14, 19, 46);

l_top_line_rec  l_top_line_Csr%ROWTYPE;
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);

BEGIN

x_return_status  := OKC_API.G_RET_STS_SUCCESS;


IF p_line_id IS NOT NULL THEN
   oks_bill_sch.Cascade_Dates_SLL
        (
          p_top_line_id         => p_line_id,
          x_return_status       => x_return_status,
          x_msg_count           => l_msg_count,
          x_msg_data            => l_msg_data);

ELSIF p_contract_id IS NOT NULL THEN

  FOR l_top_line_rec IN l_top_line_Csr
  LOOP

    oks_bill_sch.Cascade_Dates_SLL
        (
          p_top_line_id         => l_top_line_rec.id,
          x_return_status       => x_return_status,
          x_msg_count           => l_msg_count,
          x_msg_data            => l_msg_data);
  END LOOP;
END IF;

EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
 WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;
END Cascade_Dt_lines_SLL;

 -------------------------------------------------------------------------
 -- Partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------
PROCEDURE  Create_Subcription_LvlEle
         (p_billing_type     IN    VARCHAR2,
          p_sll_tbl          IN    StrmLvl_Out_tbl,
          p_line_rec         IN    Line_Det_Type,
          p_term_dt          IN    DATE,
          p_invoice_ruleid   IN    Number,
          p_period_start     IN    VARCHAR2,
          p_period_type      IN    VARCHAR2,
          x_return_status    OUT  NOCOPY Varchar2)

IS

CURSOR l_subcription_amt_csr(p_line_id NUMBER, p_term_dt DATE) IS
       SELECT nvl(SUM(amount) ,0) sub_amt
       FROM OKS_SUBSCR_ELEMENTS
       WHERE dnz_cle_id = p_line_id;

----commented for bug#3222008.terminate program first call recreate fulfillemt schedule so
----take amt from rest of fulfillemt sch.
      --- AND TRUNC(start_date) < TRUNC(p_term_dt);


l_subcription_amt_rec    l_subcription_amt_csr%ROWTYPE;




l_tangible               BOOLEAN;
l_line_sll_counter       Number;
l_period_counter         Number;
l_next_cycle_dt          Date;

l_line_end_date          date;
l_line_amt               NUMBER;

l_adjusted_amt           NUMBER;
l_lvl_loop_counter       NUMBER;
l_last_cycle_dt          Date;
l_bill_sch_amt           NUMBER := 0;
l_tbl_seq                NUMBER;
l_uom_quantity           NUMBER;
l_tce_code               VARCHAR2(100);
L_CONSTANT_SLL_AMT       NUMBER;
l_remaining_amt          NUMBER;
L_SLL_AMT                NUMBER;
l_dummy_top_line_bs      oks_bill_level_elements_pvt.letv_tbl_type;
l_bill_type              VARCHAR2(10);

  --
l_api_version           CONSTANT        NUMBER  := 1.0;
l_init_msg_list         VARCHAR2(2000) := OKC_API.G_FALSE;
l_return_status         VARCHAR2(10);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_msg_index_out         NUMBER;
l_msg_index             NUMBER;
-- Start - Added by PMALLARA - Bug #3992530
Lvl_Element_cnt Number := 0;
Strm_Start_Date  Date;
-- End - Added by PMALLARA - Bug #3992530
 -------------------------------------------------------------------------
 -- Partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------
 l_pricing_method Varchar2(30);
 l_period_start   OKS_K_HEADERS_B.PERIOD_START%TYPE;
 l_period_type    OKS_K_HEADERS_B.PERIOD_TYPE%TYPE;
BEGIN

x_return_status := OKC_API.G_RET_STS_SUCCESS;

l_tangible  := OKS_SUBSCRIPTION_PUB.is_subs_tangible (p_line_rec.id);



l_lvl_ele_tbl_in.delete;
l_tbl_seq := 1;
l_line_end_date := p_line_rec.line_end_dt;            ---termination dt
l_line_sll_counter := p_sll_tbl.FIRST;

IF p_term_dt IS NULL THEN
   l_line_end_date := p_line_rec.line_end_dt;
ELSE
   l_line_end_date  := p_term_dt;
END IF;


IF l_tangible THEN                    ----item is tangible (have fulfillment schedule)

   -----errorout_ad('l_tangible = true');

   OPEN l_subcription_amt_csr(p_line_rec.id,l_line_end_date) ;
   FETCH l_subcription_amt_csr INTO l_subcription_amt_rec;

   If l_subcription_amt_csr%NOTFOUND THEN
      l_line_amt  := 0;
      CLOSE l_subcription_amt_csr;
   ELSE
      l_line_amt  := l_subcription_amt_rec.sub_amt;
      Close l_subcription_amt_csr;
   END IF;
   ---l_line_amt := 400;

 -------------------------------------------------------------------------
 -- Partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- For tangible only service start will be honored
 -------------------------------------------------------------------------
  l_period_start := NULL;
  l_period_type := NULL;

ELSE             ----false

   -----errorout_ad('l_tangible = false');
  l_line_amt := OKS_SUBSCRIPTION_PUB.subs_termn_amount
                      ( p_cle_id      => p_line_rec.id,
                        p_termn_date  => l_line_end_date ) ;

  IF l_line_amt IS NULL THEN
     l_line_amt := 0;
  END IF;

 -------------------------------------------------------------------------
 -- Partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- If intangible and if the profile option OKS_SUBS_PRICING_METHO is subscription based
 -- then period start should be NULL and period type should also be NULL
 -- otherwise period start should be 'SERVICE' and period type will be whatever is set at GCD
 -------------------------------------------------------------------------
--mchoudha fix for bug#5183011
l_pricing_method :=FND_PROFILE.value('OKS_SUBS_PRICING_METHOD');
 if nvl(l_pricing_method,'SUBSCRIPTION') = 'EFFECTIVITY' then
   l_period_start := 'SERVICE';
 else
   l_period_start := NULL;
   l_period_type := NULL;
--     l_line_amt := p_line_rec.line_amt - l_line_amt;
 END IF;

END IF;
-----errorout_ad('LINE AMT = ' || l_line_amt);


IF l_header_billing IS NULL THEN

    Delete_lvl_element(p_cle_id        => p_line_rec.id,
                     x_return_status => x_return_status);

    -----errorout_ad('Delete_lvl_element status = ' || x_return_status);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
END IF;

IF p_line_rec.line_start_dt >= nvl(p_term_dt,l_line_end_date) AND l_line_amt = 0 THEN   ---if line terminated on the same dt.
     x_return_status := 'S';
     RETURN;
END IF;

l_bill_type := p_billing_type;



LOOP                           ---sll rule loop
      -----errorout_ad('sll rule start date : '||to_char(p_line_rec.line_start_dt));

    IF l_header_billing IS NOT NULL THEN           ----hdr lvl billing no old sll and lvl elements
       l_next_cycle_dt := p_sll_tbl(l_line_sll_counter).dt_start;
       l_lvl_loop_counter := 1;
       l_period_counter := 1;

    ELSE

    Check_Existing_Lvlelement(
                   p_sll_id              =>p_sll_tbl(l_line_sll_counter).id,
                   p_sll_dt_start        =>p_sll_tbl(l_line_sll_counter).dt_start,
                   p_uom                => null,
                   p_uom_per_period     => null,
                   p_cp_end_dt           => null,
                   x_next_cycle_dt       => l_next_cycle_dt,
                   x_last_cycle_dt       => l_last_cycle_dt,
                   x_period_counter      => l_period_counter,
                   x_sch_amt             => l_bill_sch_amt,
                   x_top_line_bs         => l_dummy_top_line_bs,
                   x_return_status       => x_return_status);

      -----errorout_ad('LEVEL ELEMENT COUNTER = ' || TO_CHAR(l_period_counter));
      -----errorout_ad('LEVEL ELEMENT START DATE = ' || to_char(l_next_cycle_dt));

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_lvl_loop_counter := l_period_counter;
   END IF;

    IF l_period_counter > to_number(p_sll_tbl(l_line_sll_counter).level_period) THEN
      ---It will not insert record in lvl ele for recent sll

      IF l_line_sll_counter + 1 <= p_sll_tbl.LAST THEN
          l_next_cycle_dt := p_sll_tbl(l_line_sll_counter + 1).dt_start;
      ELSE

          l_next_cycle_dt := OKC_TIME_UTIL_PUB.get_enddate
                                           (p_sll_tbl(l_line_sll_counter).dt_start,
                                            p_sll_tbl(l_line_sll_counter).uom,
                                            (p_sll_tbl(l_line_sll_counter).uom_Per_Period *
                                             p_sll_tbl(l_line_sll_counter).level_period));

           l_next_cycle_dt := l_next_cycle_dt + 1;
       END IF;

    ELSE

        -----errorout_ad('last date = ' || TO_CHAR(l_last_cycle_dt));
        -----errorout_ad('uom = ' || p_sll_tbl(l_line_sll_counter).uom);
        -----errorout_ad('uom = ' || p_sll_tbl(l_line_sll_counter).uom_Per_Period);
       IF L_next_cycle_dt IS null THEN


          L_next_cycle_dt := OKC_TIME_UTIL_PUB.get_enddate
                                           (l_last_cycle_dt,
                                            p_sll_tbl(l_line_sll_counter).uom,
                                            p_sll_tbl(l_line_sll_counter).uom_Per_Period);

        -----errorout_ad('next_cycle_date = ' || to_char(l_next_cycle_dt));

        l_next_cycle_dt := l_next_cycle_dt + 1;
       END IF;


       IF l_bill_type = 'T' THEN
          OKS_BILL_UTIL_PUB.get_seeded_timeunit(
                p_timeunit      => p_sll_tbl(l_line_sll_counter).uom,
                x_return_status => x_return_status,
                x_quantity      => l_uom_quantity ,
                x_timeunit      => l_tce_code);

          IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
              RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;

          l_remaining_amt := l_line_amt - nvl(l_bill_sch_amt,0);

          Get_Constant_sll_Amount(p_line_start_date      => p_line_rec.line_start_dt,
                                 p_line_end_date         => l_line_end_date,
                                 p_cycle_start_date      => l_next_cycle_dt,
                                 p_remaining_amount      => l_remaining_amt,
                                 P_uom_quantity          => l_uom_quantity,
                                 P_tce_code              => l_tce_code,
                                 x_constant_sll_amt      => l_constant_sll_amt,
                                 x_return_status         => x_return_status);

          -----errorout_ad('Get_Constant_sll_Amount = ' || x_return_status);

           IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
              RAISE G_EXCEPTION_HALT_VALIDATION;
           END IF;
       END IF;        ----end of bill type = 'T'

      IF l_line_amt <= nvl(l_bill_sch_amt,0) AND l_bill_type = 'E' THEN
          NULL;
      ELSE


-- Start - Added by PMALLARA - Bug #3992530
    Lvl_Element_cnt  :=   l_period_counter - 1;
    Strm_Start_Date  :=   p_sll_tbl(l_line_sll_counter).dt_start;
      LOOP                          -------------for level elements of one rule
    Lvl_Element_cnt  :=     Lvl_Element_cnt + 1;
-- End - Added by PMALLARA - Bug #3992530

        l_fnd_lvl_in_rec.line_start_date           := p_line_rec.line_start_dt;
        l_fnd_lvl_in_rec.line_end_date             := l_line_end_date;
        l_fnd_lvl_in_rec.cycle_start_date          := l_next_cycle_dt;
-- Start - Modified by PMALLARA - Bug #3992530
        l_fnd_lvl_in_rec.tuom_per_period           := Lvl_Element_cnt * p_sll_tbl(l_line_sll_counter).uom_Per_Period;
-- End - Modified by PMALLARA - Bug #3992530
        l_fnd_lvl_in_rec.tuom                      := p_sll_tbl(l_line_sll_counter).uom;
        l_fnd_lvl_in_rec.total_amount              := 0;
        l_fnd_lvl_in_rec.invoice_offset_days        := p_sll_tbl(l_line_sll_counter).invoice_offset_days;
        l_fnd_lvl_in_rec.interface_offset_days     := p_sll_tbl(l_line_sll_counter).Interface_offset_days;
        l_fnd_lvl_in_rec.bill_type                 := 'S';            ---passed 'S' for subcription terminated line.
        --mchoudha added this parameter
        l_fnd_lvl_in_rec.uom_per_period            := p_sll_tbl(l_line_sll_counter).uom_Per_Period;

 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- Added two new parameters p_period_start and p_period_type
 -------------------------------------------------------------------------
        -- Start - Modified by PMALLARA - Bug #3992530
        OKS_BILL_UTIL_PUB.Get_next_bill_sch
          (p_api_version             => l_api_version,
           x_return_status           => x_return_status,
           x_msg_count               => l_msg_count,
           x_msg_data                => l_msg_data,
           p_invoicing_rule_id       => p_invoice_ruleid,
           p_bill_sch_detail_rec     => l_fnd_lvl_in_rec,
           x_bill_sch_detail_rec     => l_fnd_lvl_out_rec,
           p_period_start            => l_period_start,
           p_period_type             =>  p_period_type,
           Strm_Start_Date           => Strm_Start_Date);
        -- End - Modified by PMALLARA - Bug #3992530

        -----errorout_ad('LEVEL ELEMENT NEXT CYCLE DATE passed from Get_next_bill_sch = ' || TO_CHAR(l_fnd_lvl_out_rec.next_cycle_date));

        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -----errorout_ad(' OKS_BILL_UTIL_PUB.Get_next_bill_sch = ' || l_msg_data);
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          -----errorout_ad(' OKS_BILL_UTIL_PUB.Get_next_bill_sch = ' || l_msg_data);
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;



        IF TRUNC(l_fnd_lvl_out_rec.next_cycle_date) < p_Line_rec.line_start_dt then
          null;                       ---donot insert record in level element
        ELSE
          l_lvl_ele_tbl_in(l_tbl_seq).sequence_number        :=   to_char(l_period_counter);
          l_lvl_ele_tbl_in(l_tbl_seq).cle_id                 :=   p_line_rec.id;
          l_lvl_ele_tbl_in(l_tbl_seq).parent_cle_id          :=   p_line_rec.id;
          l_lvl_ele_tbl_in(l_tbl_seq).dnz_chr_id             :=   p_line_rec.dnz_chr_id;

          l_lvl_ele_tbl_in(l_tbl_seq).date_start             :=   TRUNC(l_next_cycle_dt);
          l_lvl_ele_tbl_in(l_tbl_seq).date_end               :=   TRUNC(l_fnd_lvl_out_rec.next_cycle_date) - 1;


          IF l_bill_type = 'T' then
             --calculated sll amount
             l_lvl_ele_tbl_in(l_tbl_seq).amount             :=  OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_constant_sll_amt,l_currency_code );

          ELSE                     ----for E and  P
            ---sll amt entered by user

            l_sll_amt := TO_NUMBER(p_sll_tbl(l_line_sll_counter).amount);
            l_lvl_ele_tbl_in(l_tbl_seq).amount               :=  OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_sll_amt,l_currency_code );
          END IF;


          l_lvl_ele_tbl_in(l_tbl_seq).date_receivable_gl     :=   l_fnd_lvl_out_rec.date_recievable_gl;
          l_lvl_ele_tbl_in(l_tbl_seq).date_transaction       :=   TRUNC(l_fnd_lvl_out_rec.date_transaction);
          l_lvl_ele_tbl_in(l_tbl_seq).date_due               :=   l_fnd_lvl_out_rec.date_due;
          l_lvl_ele_tbl_in(l_tbl_seq).date_print             :=   l_fnd_lvl_out_rec.date_print;
          l_lvl_ele_tbl_in(l_tbl_seq).date_to_interface      :=   TRUNC(l_fnd_lvl_out_rec.date_to_interface);
          l_lvl_ele_tbl_in(l_tbl_seq).date_completed         :=   l_fnd_lvl_out_rec.date_completed;
          l_lvl_ele_tbl_in(l_tbl_seq).rul_id                 :=   p_sll_tbl(l_line_sll_counter).id;

          l_lvl_ele_tbl_in(l_tbl_seq).object_version_number  := OKC_API.G_MISS_NUM;
          l_lvl_ele_tbl_in(l_tbl_seq).created_by             := OKC_API.G_MISS_NUM;
          l_lvl_ele_tbl_in(l_tbl_seq).creation_date          := SYSDATE;
          l_lvl_ele_tbl_in(l_tbl_seq).last_updated_by        := OKC_API.G_MISS_NUM;
          l_lvl_ele_tbl_in(l_tbl_seq).last_update_date       := SYSDATE;


          -----errorout_ad ('Amount for line lvl element = ' || to_char(l_lvl_ele_tbl_in(l_tbl_seq).amount ));

          l_period_counter := l_period_counter + 1;
          l_bill_sch_amt := nvl(l_bill_sch_amt,0) + nvl(l_lvl_ele_tbl_in(l_tbl_seq).amount,0);
          l_tbl_seq      := l_tbl_seq + 1;
        END IF;          -----end if for level element creation

        l_next_cycle_dt  := l_fnd_lvl_out_rec.next_cycle_date;

        IF l_bill_type = 'T' then

           EXIT WHEN (l_lvl_loop_counter = p_sll_tbl(l_line_sll_counter).level_period) OR
                  (TRUNC(l_next_cycle_dt) > l_line_end_date);
        ELSE      ---'E'
           EXIT WHEN (l_line_amt <= l_bill_sch_amt) OR
                   (l_lvl_loop_counter = p_sll_tbl(l_line_sll_counter).level_period) ;
        END IF;

        l_lvl_loop_counter := l_lvl_loop_counter + 1;

       END LOOP;                   ---loop for sll period counter
      END IF;     ----l_line_amt <= nvl(l_bill_sch_amt,0) AND l_bill_type = 'E'

      END IF;                      ----Period counter checking before entering in loop for lvlelement



    IF l_bill_type = 'T' then
       EXIT WHEN (l_line_sll_counter = p_sll_tbl.LAST) OR
                 (TRUNC(l_next_cycle_dt) > l_line_end_date);
    ELSE    ---'E'
       EXIT WHEN (l_line_sll_counter = p_sll_tbl.LAST) OR
                 (l_line_amt <= l_bill_sch_amt);

    END IF;       ---End of 'T'
    l_line_sll_counter := p_sll_tbl.NEXT(l_line_sll_counter);

  END LOOP;                    -----loop for sll lines

  IF l_lvl_ele_tbl_in.COUNT > 0 THEN

    IF l_line_amt < l_bill_sch_amt THEN
       --adjust the last lvl elemnt amt

       l_adjusted_amt := (l_lvl_ele_tbl_in(l_lvl_ele_tbl_in.LAST).amount) - (l_bill_sch_amt - l_line_amt);
       l_lvl_ele_tbl_in(l_lvl_ele_tbl_in.LAST).amount := l_adjusted_amt;

    ELSIF l_line_amt > l_bill_sch_amt THEN
      --adjust the last lvl elemnt amt

       l_adjusted_amt := (l_lvl_ele_tbl_in(l_lvl_ele_tbl_in.LAST).amount) + (l_line_amt - l_bill_sch_amt);
       l_lvl_ele_tbl_in(l_lvl_ele_tbl_in.LAST).amount := l_adjusted_amt;
    END IF;

     OKS_BILL_LEVEL_ELEMENTS_PVT.insert_row(
               p_api_version                  => l_api_version,
               p_init_msg_list                => l_init_msg_list,
               x_return_status                => x_return_status,
               x_msg_count                    => l_msg_count,
               x_msg_data                     => l_msg_data,
               p_letv_tbl                     => l_lvl_ele_tbl_in,
               x_letv_tbl                     => l_lvl_ele_tbl_out);

    -----errorout_ad('LEVEL ELEMENT INSERT STATUS FOR SUBLINE = ' || x_return_status);


      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         -----errorout_ad('OKS_BILL_LEVEL_ELEMENTS_PVT.insert_row for sub line = ' || l_msg_data);
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         -----errorout_ad('OKS_BILL_LEVEL_ELEMENTS_PVT.insert_row for sub line = ' || l_msg_data);
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
   END IF;


EXCEPTION
 WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;
END Create_Subcription_LvlEle;

Procedure Create_Subcription_bs
(
          p_top_line_id         IN    NUMBER,
          p_full_credit         IN    VARCHAR2,
          x_return_status       OUT   NOCOPY Varchar2,
          x_msg_count           OUT   NOCOPY NUMBER,
          x_msg_data            OUT   NOCOPY VARCHAR2)

IS

CURSOR l_line_sll_csr IS
        SELECT id,sequence_no,TRUNC(start_date) start_date, level_periods,
               uom_per_period, uom_code, TRUNC(end_date) end_date,
               interface_offset_days, invoice_offset_days, cle_id, dnz_chr_id,
               chr_id, level_amount
        FROM OKS_STREAM_LEVELS_B
        WHERE  cle_id = p_top_line_id
        ORDER BY sequence_no;



Cursor l_Line_Csr Is
 SELECT line.chr_id chr_id, line.dnz_chr_id dnz_chr_id, line.id id, line.lse_id lse_id,
        TRUNC(line.start_date) line_start_dt, TRUNC(line.end_date) line_end_dt,
        TRUNC(line.date_terminated) line_term_dt, line.inv_rule_id inv_rule_id,
        nvl(dtl.billing_schedule_type,'E') billing_schedule_type,
        (nvl(line.price_negotiated,0) +  nvl(dtl.ubt_amount,0) +
         nvl(dtl.credit_amount,0) +  nvl(dtl.suppressed_credit,0) ) line_amt
 FROM okc_k_lines_b line, oks_k_lines_b dtl
 WHERE  line.id = dtl.cle_id AND line.Id =  p_top_line_id ;







l_index                   NUMBER;
l_sll_in_tbl                 StrmLvl_Out_tbl;

l_Line_Sll_rec            l_Line_Sll_Csr%ROWTYPE;
l_Line_Rec                l_Line_Csr%Rowtype;

L_BIL_SCH_OUT_TBL         OKS_BILL_SCH.ItemBillSch_tbl;
l_top_line_rec            Line_Det_Type;
l_update_end_date         VARCHAR2(1);


-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 04-MAY-2005
-------------------------------------------------------------------------
l_price_uom         OKS_K_HEADERS_B.PRICE_UOM%TYPE;
l_period_start      OKS_K_HEADERS_B.PERIOD_START%TYPE;
l_period_type       OKS_K_HEADERS_B.PERIOD_TYPE%TYPE;
l_return_status  VARCHAR2(30);
-------------------------------------------------------------------------
-- End partial period computation logic
-- Date 04-MAY-2005
-------------------------------------------------------------------------

BEGIN

x_return_status := OKC_API.G_RET_STS_SUCCESS;
l_update_end_date   := 'N';

IF nvl(p_full_credit, 'N') = 'Y' Then
   DELETE FROM OKS_LEVEL_ELEMENTS
   WHERE date_completed IS NULL
   AND cle_id = p_top_line_id;

   RETURN;
END IF;

---get line details
Open l_Line_Csr;
Fetch l_Line_Csr Into l_Line_Rec;

If l_Line_Csr%Notfound then
    Close l_Line_Csr;
    x_return_status := 'E';
    OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'LINE NOT FOUND');
    RAISE G_EXCEPTION_HALT_VALIDATION;
End If;
Close l_Line_Csr;

l_top_line_rec.chr_id          :=  l_Line_Rec.chr_id;
l_top_line_rec.dnz_chr_id      :=  l_Line_Rec.dnz_chr_id;
l_top_line_rec.id              :=  l_Line_Rec.id ;
l_top_line_rec.lse_id          :=  l_Line_Rec.lse_id;
l_top_line_rec.line_start_dt   :=  l_Line_Rec.line_start_dt;
l_top_line_rec.line_end_dt     :=  l_Line_Rec.line_end_dt;
l_top_line_rec.line_amt        :=  l_Line_Rec.line_amt ;


 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------

   OKS_RENEW_UTIL_PUB.Get_Period_Defaults
                (
                 p_hdr_id        => l_Line_Rec.dnz_chr_id,
                 p_org_id        => NULL,
                 x_period_start  => l_period_start,
                 x_period_type   => l_period_type,
                 x_price_uom     => l_price_uom,
                 x_return_status => x_return_status);

   IF x_return_status <> 'S' THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

 -------------------------------------------------------------------------
 -- End partial period computation logic
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------

IF l_line_rec.billing_schedule_type IS NULL then
   RETURN;
END IF;
----make sll tbl

l_index := 1;
l_sll_in_tbl.DELETE;

FOR l_Line_SlL_rec IN l_Line_SlL_Csr
LOOP
  l_sll_in_tbl(l_index).id                     := l_Line_SlL_rec.id;
  l_sll_in_tbl(l_index).cle_id                 := l_Line_SlL_rec.cle_id;

  l_sll_in_tbl(l_index).chr_id                 := l_Line_SlL_rec.chr_id;
  l_sll_in_tbl(l_index).dnz_chr_id             := l_Line_SlL_rec.dnz_chr_id;
  l_sll_in_tbl(l_index).uom                    := l_Line_SlL_rec.uom_code;
  l_sll_in_tbl(l_index).seq_no                 := l_Line_SlL_rec.sequence_no;
  l_sll_in_tbl(l_index).Dt_start               := l_Line_SlL_rec.Start_Date;
  IF l_Line_SlL_rec.end_Date IS NOT NULL THEN

     l_sll_in_tbl(l_index).end_Date                    := l_Line_SlL_rec.end_Date;
  ELSE
     l_update_end_date   := 'Y';
     l_sll_in_tbl(l_index).end_Date                    := OKC_TIME_UTIL_PUB.get_enddate(
                                                        l_Line_SlL_rec.Start_Date,
                                                        l_Line_SlL_rec.UOM_CODE,
                                  l_Line_SlL_rec.uom_per_period * l_Line_SlL_rec.level_periods);
  END IF;


  l_sll_in_tbl(l_index).level_period           := l_Line_SlL_rec.level_periods;
  l_sll_in_tbl(l_index).uom_per_period         := l_Line_SlL_rec.uom_per_period;
  l_sll_in_tbl(l_index).amount                 := l_Line_SlL_rec.level_amount;
  l_sll_in_tbl(l_index).invoice_offset_days     := l_Line_SlL_rec.invoice_offset_days;
  l_sll_in_tbl(l_index).interface_offset_days  := l_Line_SlL_rec.interface_offset_days;

  l_index := l_index + 1;
END LOOP;

IF l_sll_in_tbl.COUNT = 0 THEN
   RETURN;
END IF;

IF l_update_end_date = 'Y' THEN          ---Migrated
   OKS_BILL_SCH.UPDATE_BS_ENDDATE(p_line_id         => p_top_line_id,
                                  p_chr_id          => NULL,
                                  x_return_status   => x_return_status);

   IF x_return_status <> 'S' THEN
      RETURN;
   END IF;
END IF;

-----errorout_ad('SLL found');



 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------
Create_Subcription_LvlEle
         (p_billing_type     =>  l_line_rec.billing_schedule_type,
          p_sll_tbl          =>  l_sll_in_tbl,
          p_line_rec         =>  l_top_line_rec,
          p_term_dt          =>  l_line_rec.line_term_dt,
          p_invoice_ruleid   =>  l_line_rec.inv_rule_id,
          p_period_start     =>  l_period_start,
          p_period_type      =>  l_period_type,
          x_return_status    =>  x_return_status);

IF x_return_status <> 'S' THEN
     RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;



EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
 WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;

END Create_Subcription_bs;


FUNCTION Find_term_amt(p_cycle_st_dt  IN  DATE,
              p_term_dt      IN  DATE,
              p_cycle_end_dt IN  DATE,
              p_amount       IN  NUMBER) RETURN NUMBER


IS
l_cal_amt     NUMBER;
l_term_days   NUMBER;
l_cycle_days  NUMBER;


BEGIN

l_cal_amt := 0;

l_term_days     := trunc(p_term_dt) - TRUNC(p_cycle_st_dt);
l_cycle_days    := trunc(p_cycle_end_dt) - TRUNC(p_cycle_st_dt) + 1;

-----errorout_ad('l_term_days = ' || l_term_days);

l_cal_amt   := (NVL(p_amount,0) * l_term_days)/ NVL(l_cycle_days,1) ;

-----errorout_ad('l_cal_amt = ' || l_cal_amt);

RETURN OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_cal_amt, l_currency_code);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RETURN NULL;

END Find_term_amt;

PROCEDURE Get_SLL_info(p_top_line_id      IN  NUMBER,
                       p_line_id          IN  NUMBER,
                       x_sll_tbl          OUT NOCOPY StrmLvl_Out_tbl,
                       x_sll_db_tbl       OUT NOCOPY OKS_BILL_SCH.StreamLvl_tbl,
                       x_return_status    OUT NOCOPY VARCHAR2)

IS


CURSOR l_line_sll_csr IS
       SELECT id,sequence_no,TRUNC(start_date) start_date, level_periods,
               uom_per_period, uom_code, TRUNC(end_date) end_date,
               interface_offset_days, invoice_offset_days, cle_id, dnz_chr_id,
               chr_id, level_amount
       FROM OKS_STREAM_LEVELS_B
       WHERE  cle_id = p_line_id
       ORDER BY sequence_no;

l_sll_tbl                 OKS_BILL_SCH.StreamLvl_tbl;
l_index                   NUMBER;
l_Line_Sll_rec            l_Line_Sll_csr%ROWTYPE;
l_update_end_date         VARCHAR2(1)  := 'N';


BEGIN
l_update_end_date   := 'N';
l_sll_tbl.DELETE;
l_index := 1;
x_return_status := 'S';
----make sll tbl

FOR l_Line_SlL_rec IN l_Line_SlL_Csr
LOOP
  l_sll_tbl(l_index).id                             := l_Line_SlL_rec.id;
  l_sll_tbl(l_index).cle_id                         := l_Line_SlL_rec.cle_id;

  l_sll_tbl(l_index).chr_id                         := l_Line_SlL_rec.chr_id;
  l_sll_tbl(l_index).dnz_chr_id                     := l_Line_SlL_rec.dnz_chr_id;
  l_sll_tbl(l_index).uom_code                       := l_Line_SlL_rec.uom_code;
  l_sll_tbl(l_index).sequence_no                    := l_Line_SlL_rec.sequence_no;
  l_sll_tbl(l_index).Start_Date                     := l_Line_SlL_rec.Start_Date;

  IF l_Line_SlL_rec.end_Date IS NOT NULL THEN

     l_sll_tbl(l_index).end_Date                    := l_Line_SlL_rec.end_Date;
  ELSE
     l_update_end_date   := 'Y';
     l_sll_tbl(l_index).end_Date                    := OKC_TIME_UTIL_PUB.get_enddate(
                                                        l_Line_SlL_rec.Start_Date,
                                                        l_Line_SlL_rec.UOM_CODE,
                                                        l_Line_SlL_rec.uom_per_period * l_Line_SlL_rec.level_periods);
  END IF;

  l_sll_tbl(l_index).level_periods                  := l_Line_SlL_rec.level_periods;
  l_sll_tbl(l_index).uom_per_period                 := l_Line_SlL_rec.uom_per_period;
  l_sll_tbl(l_index).level_amount                   := l_Line_SlL_rec.level_amount;
  l_sll_tbl(l_index).invoice_offset_days             := l_Line_SlL_rec.invoice_offset_days;
  l_sll_tbl(l_index).interface_offset_days          := l_Line_SlL_rec.interface_offset_days;

  l_index := l_index + 1;
END LOOP;

IF l_sll_tbl.COUNT = 0 THEN
   RETURN;
END IF;

IF l_update_end_date = 'Y' THEN          ---Migrated
   OKS_BILL_SCH.UPDATE_BS_ENDDATE(p_line_id         => p_top_line_id,
                                  p_chr_id          => NULL,
                                  x_return_status   => x_return_status);

   IF x_return_status <> 'S' THEN
      RETURN;
   END IF;
END IF;


x_sll_db_tbl := l_sll_tbl;

l_index  := 0;
x_sll_tbl.delete ;


l_index  := 0;


FOR l_index IN l_sll_tbl.FIRST .. l_sll_tbl.LAST
LOOP

   x_sll_tbl(l_index).id                     := l_sll_tbl(l_index).id ;
   x_sll_tbl(l_index).cle_id                 := l_sll_tbl(l_index).cle_id;
   x_sll_tbl(l_index).chr_id                 := l_sll_tbl(l_index).chr_id ;
   x_sll_tbl(l_index).dnz_chr_id             := l_sll_tbl(l_index).dnz_chr_id;
   x_sll_tbl(l_index).uom                    := l_sll_tbl(l_index).uom_code ;
   x_sll_tbl(l_index).seq_no                 := l_sll_tbl(l_index).sequence_no;
   x_sll_tbl(l_index).Dt_start               := l_sll_tbl(l_index).Start_Date  ;
   x_sll_tbl(l_index).end_Date               := l_sll_tbl(l_index).end_Date  ;
   x_sll_tbl(l_index).level_period           := l_sll_tbl(l_index).level_periods ;
   x_sll_tbl(l_index).uom_per_period         := l_sll_tbl(l_index).uom_per_period ;
   x_sll_tbl(l_index).amount                 := l_sll_tbl(l_index).level_amount;
   x_sll_tbl(l_index).invoice_offset_days    := l_sll_tbl(l_index).invoice_offset_days;
   x_sll_tbl(l_index).interface_offset_days  := l_sll_tbl(l_index).interface_offset_days ;
END LOOP;



END Get_SLL_info;



Procedure Terminate_bill_sch
(
          p_top_line_id         IN    NUMBER,
          p_sub_line_id         IN    NUMBER,
          p_term_dt             IN    DATE,
          x_return_status       OUT   NOCOPY Varchar2,
          x_msg_count           OUT   NOCOPY NUMBER,
          x_msg_data            OUT   NOCOPY VARCHAR2)
IS

Cursor l_Line_Csr Is
 SELECT line.chr_id chr_id, line.dnz_chr_id dnz_chr_id, line.id id, line.lse_id lse_id,
        TRUNC(line.start_date) line_start_dt, TRUNC(line.end_date) line_end_dt,
        line.inv_rule_id inv_rule_id, line.cle_id cle_id,
        dtl.billing_schedule_type billing_schedule_type,
        (nvl(line.price_negotiated,0) +  nvl(dtl.ubt_amount,0) +
         nvl(dtl.credit_amount,0) +  nvl(dtl.suppressed_credit,0) ) line_amt
 FROM okc_k_lines_b line, oks_k_lines_b dtl
 WHERE  line.id = dtl.cle_id AND line.Id =  p_top_line_id
 AND    line.date_cancelled is null; -- 18-JAN-2006-maanand-Fixed Enhancement#4930700
                                     -- Ignore cancelled topline




Cursor l_all_subLine_Csr(l_line_id number, l_style_id number) Is
 SELECT line.id subline_id, TRUNC(line.start_date) cp_start_dt,
        TRUNC(line.end_date) cp_end_dt, TRUNC(line.date_terminated) cp_prev_term_dt,
        dtl.billing_schedule_type billing_schedule_type,
        dtl.full_credit full_credit,lse_id cp_lse_id,dtl.price_uom,
        (nvl(line.price_negotiated,0) +  nvl(dtl.ubt_amount,0) +
         nvl(dtl.credit_amount,0) +  nvl(dtl.suppressed_credit,0) ) subline_amt
        FROM okc_k_lines_b line, oks_k_lines_b dtl
        WHERE line.cle_id = l_line_id
        AND line.id = dtl.cle_id
        AND ((l_style_id = 1 and line.lse_id in (35,7,8,9,10,11))
         OR (l_style_id = 12 and line.lse_id = 13)
         OR (l_style_id = 14 and line.lse_id = 18)
         OR (l_style_id = 19 and line.lse_id = 25))
        AND line.date_cancelled is null; -- 18-JAN-2006-maanand-Fixed Enhancement#4930700
                                         -- Ignore cancelled subline


Cursor  l_subline_amt_csr (p_id in number) IS
Select  line.price_negotiated
from    okc_k_lines_b line
where   line.id = p_id;

CURSOR l_line_BS_csr(p_line_id  NUMBER) IS
         SELECT id, trunc(element.date_start) date_start,
         amount,trunc(date_end) date_end,
         object_version_number,date_transaction,date_to_interface
         FROM oks_level_elements element
         WHERE cle_id = p_line_id
         ORDER BY date_start;



Cursor l_SubLine_Csr Is
 SELECT line.id subline_id, TRUNC(line.start_date) cp_start_dt,
        TRUNC(line.end_date) cp_end_dt, dtl.billing_schedule_type billing_schedule_type,dtl.price_uom,
        (nvl(line.price_negotiated,0) +  nvl(dtl.ubt_amount,0) +
         nvl(dtl.credit_amount,0) +  nvl(dtl.suppressed_credit,0) ) subline_amt
 FROM okc_k_lines_b line, oks_k_lines_b dtl
 WHERE line.id = p_sub_line_id
 AND line.id = dtl.cle_id
 AND line.date_cancelled is null; -- 18-JAN-2006-maanand-Fixed Enhancement#4930700
                                  -- Ignore cancelled subline


l_Line_rec                l_Line_Csr%ROWTYPE;
l_all_subLine_rec         l_all_subLine_Csr%ROWTYPE;
l_subLine_rec             l_subLine_csr%ROWTYPE;
l_line_BS_rec             l_line_BS_csr%ROWTYPE;



l_index                   NUMBER;
l_top_line_rec            Line_Det_Type;
l_cp_rec                  Prod_Det_Type;
l_inv_id                  number;
l_prev_term_dt            date;

l_sll_in_tbl              StrmLvl_Out_tbl;
l_sll_db_tbl              oks_bill_sch.StreamLvl_tbl;
l_top_bs_tbl              oks_bill_level_elements_pvt.letv_tbl_type;

l_init_msg_list           VARCHAR2(2000) := OKC_API.G_FALSE;

-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 04-MAY-2005
-------------------------------------------------------------------------
l_price_uom         OKS_K_HEADERS_B.PRICE_UOM%TYPE;
l_period_start      OKS_K_HEADERS_B.PERIOD_START%TYPE;
l_period_type       OKS_K_HEADERS_B.PERIOD_TYPE%TYPE;
l_return_status     VARCHAR2(30);
l_tangible          BOOLEAN;
l_pricing_method    VARCHAR2(30);
-------------------------------------------------------------------------
-- End partial period computation logic
-- Date 04-MAY-2005
-------------------------------------------------------------------------


BEGIN


--if called for top line  p_sub_line_id is null or -100
--if  p_sub_line_id = -100 that means full credit, create top line bs upto term date
--and subline which are not already terminated, consider term dt as start dt of subline.
--so that subline will have only billed lvl elements.

--if called for subline termination,if full credit termination program will pass
--p_term_dt as start date otherwise actual term dt.


x_return_status := 'S';

IF p_term_dt IS NULL THEN
  RETURN;
END IF;

   ---get line details
Open l_Line_Csr;
Fetch l_Line_Csr Into l_Line_Rec;

If l_Line_Csr%Notfound then
 Close l_Line_Csr;
 x_return_status := 'E';
 OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'LINE NOT FOUND');
 RAISE G_EXCEPTION_HALT_VALIDATION;
End If;
Close l_Line_Csr;

l_top_line_rec.chr_id          :=  l_Line_Rec.chr_id;
l_top_line_rec.dnz_chr_id      :=  l_Line_Rec.dnz_chr_id;
l_top_line_rec.id              :=  l_Line_Rec.id ;
l_top_line_rec.cle_id          :=  l_Line_Rec.cle_id ;
l_top_line_rec.lse_id          :=  l_Line_Rec.lse_id;
l_top_line_rec.line_start_dt   :=  l_Line_Rec.line_start_dt;
l_top_line_rec.line_end_dt     :=  l_Line_Rec.line_end_dt;
l_top_line_rec.line_amt        :=  l_Line_Rec.line_amt ;
 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------


   OKS_RENEW_UTIL_PUB.Get_Period_Defaults
                (
                 p_hdr_id        => l_Line_Rec.dnz_chr_id,
                 p_org_id        => NULL,
                 x_period_start  => l_period_start,
                 x_period_type   => l_period_type,
                 x_price_uom     => l_price_uom,
                 x_return_status => x_return_status);

   IF x_return_status <> 'S' THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

  --Description in detail for the business rules for deriving the period start
  --1)For usage , period start  will always be 'SERVICE'
  --2)For Subscriptions, period start and period type will be NULL
  --  for tangible subscriptions as per CR1.For intangible subscriptions,
  --  if the profile OKS: Intangible Subscription Pricing Method
  --  is set to 'Subscription Based',then period start and period type will be NULL
  --  otherwise it will be 'SERVICE'
  --3) For Extended Warranty from OM, period start will always be 'SERVICE'
  --mchoudha fix for bug#5183011
 IF l_period_start IS NOT NULL AND
    l_period_type IS NOT NULL
 THEN
   IF l_top_line_rec.lse_id = 12 THEN
      l_period_start := 'SERVICE';
   END IF;
   IF l_top_line_rec.lse_id = 46 THEN
     l_tangible  := OKS_SUBSCRIPTION_PUB.is_subs_tangible (p_top_line_id);
     IF l_tangible THEN
       l_period_start := NULL;
       l_period_type := NULL;
     ELSE
       l_pricing_method :=FND_PROFILE.value('OKS_SUBS_PRICING_METHOD');
       IF nvl(l_pricing_method,'SUBSCRIPTION') <> 'EFFECTIVITY' THEN
         l_period_start := NULL;
         l_period_type := NULL;
       ELSE
         l_period_start := 'SERVICE';
       END IF;  --l_pricing_method <> 'EFFECTIVITY'
     END IF;    --IF l_tangible
   END IF;      --IF l_top_line_rec.lse_id = 46
 END IF;        --IF l_period_start IS NOT NULL
 -------------------------------------------------------------------------
 -- End partial period computation logic
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------
IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

   fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.terminate_bill_sch.line_dtls',
                      'dnz_chr_id = ' || l_line_rec.dnz_chr_id
                   || ', id = ' || l_line_rec.id
                   || ', lse_id = ' || l_line_rec.lse_id
                   || ', start dt = ' || l_line_rec.line_start_dt
                   || ', end dt = ' || l_line_rec.line_end_dt
                   || ', amt = ' || l_line_rec.line_amt
                   || ', p_sub_line_id = ' || p_sub_line_id
                   || ', p_term_dt = ' || p_term_dt
                   || ', bill type = '|| l_Line_Rec.billing_schedule_type
                   || ', inv rule = '|| l_line_rec.inv_rule_id
                  );
END IF;


 --get currency
l_currency_code := Find_Currency_Code(
                                    p_cle_id  => p_top_line_id,
                                    p_chr_id  => NULL);

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

   fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.terminate_bill_sch.line_dtls',
                      'l_currency_code = ' || l_currency_code);
END IF;

IF l_currency_code IS NULL THEN
      OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'CURRENCY CODE NOT FOUND.');
      x_return_status := 'E';
      RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;




--for top line first call create_lvl_ele only for top line
---and then in loop call for all subline.

IF p_sub_line_id IS NULL OR p_sub_line_id = -100 THEN
   l_sll_in_tbl.DELETE;
   l_index := 1;

   IF TRUNC(p_term_dt) > l_top_line_rec.line_end_dt THEN
     RETURN;
   END IF;

   Get_SLL_info(p_top_line_id      => p_top_line_id,
                p_line_id          => p_top_line_id,
                x_sll_tbl          => l_sll_in_tbl,
                x_sll_db_tbl       => l_sll_db_tbl,
                x_return_status    =>  x_return_status );

   IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.terminate_bill_sch.line_sll',
                       'Get_SLL_info(x_return_status = '||x_return_status
                       ||', sll tbl count = '||l_sll_in_tbl.count||')');
   END IF;


   IF x_return_status <> 'S' THEN
     RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;
   -----errorout_ad('l_sll_in_tbl count for top line  = ' || l_sll_in_tbl.count);

  IF l_sll_in_tbl.count= 0 OR l_line_rec.billing_schedule_type IS NULL THEN
    RETURN;
  END IF;

 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- Added two new parameters p_period_start and p_period_type
 -------------------------------------------------------------------------
    Create_Level_elements(p_billing_type     =>  NVL(l_line_rec.billing_schedule_type,'T'),
                          p_sll_tbl          =>  l_sll_in_tbl,
                          p_line_rec         =>  l_top_line_rec,
                          p_invoice_ruleid   =>  l_line_rec.inv_rule_id,
                          p_term_dt          =>  p_term_dt,
                          p_period_start     =>  l_period_start,
                          p_period_type      =>  l_period_type,
                          x_return_status    =>  x_return_status );

   IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.terminate_bill_sch.top_lvl_ele',
                       'Create_Level_elements(x_return_status = '||x_return_status
                       ||')');
   END IF;

   IF x_return_status <> 'S' THEN
     RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

   IF l_line_rec.billing_schedule_type IN ('T','E') THEN
      l_top_bs_tbl.DELETE;
      l_index  := 1;

      FOR l_line_BS_rec IN l_line_BS_csr(p_top_line_id)
      LOOP
        l_top_bs_tbl(l_index).id                     := l_line_BS_rec.id;
        l_top_bs_tbl(l_index).date_start             := l_line_BS_rec.date_start;
        l_top_bs_tbl(l_index).date_end               := l_line_bs_rec.date_end;
        l_top_bs_tbl(l_index).Amount                 := 0;
        l_top_bs_tbl(l_index).object_version_number  := l_line_BS_rec.object_version_number;
        l_top_bs_tbl(l_index).date_transaction   := l_line_BS_rec.date_transaction;
        l_top_bs_tbl(l_index).date_to_interface  := l_line_BS_rec.date_to_interface;

        l_index := l_index + 1;
      END LOOP;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

          fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.terminate_bill_sch.top_bs',
                      'top bs tbl count = ' || l_top_bs_tbl.count);
      END IF;
   END IF;       -----end of  'T'


   --if schedule is for top level line then find sub line and repeat THE process.
   IF l_Line_Rec.chr_id is not null AND l_Line_Rec.lse_id IN (1, 12, 14, 19) then

     FOR l_all_SubLine_rec IN l_all_SubLine_Csr(l_Line_Rec.id,l_Line_Rec.lse_id)
     LOOP

       l_cp_rec.cp_id          :=  l_all_SubLine_rec.subline_id ;
       l_cp_rec.cp_start_dt    :=  l_all_SubLine_rec.cp_start_dt;
       l_cp_rec.cp_end_dt      :=  l_all_SubLine_rec.cp_end_dt ;
       l_cp_rec.cp_amt         :=  l_all_SubLine_rec.subline_amt ;
       l_cp_rec.cp_price_uom   :=  l_all_SubLine_rec.price_uom;
       l_cp_rec.cp_lse_id      :=  l_all_SubLine_rec.cp_lse_id;
       l_cp_rec.cp_price_uom   :=  l_all_SubLine_rec.price_uom;

       IF l_period_type is not null AND l_period_start is not NULL THEN
          OPEN l_subline_amt_csr(l_all_SubLine_rec.subline_id);
          FETCH l_subline_amt_csr INTO l_cp_rec.cp_amt;
          CLOSE l_subline_amt_csr;
       END IF;
       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

           fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.terminate_bill_sch.loop_cp_dtl',
                      'id = ' || l_all_SubLine_rec.subline_id
                   || ', start dt = ' || l_all_SubLine_rec.cp_start_dt
                   || ', end dt = ' || l_all_SubLine_rec.cp_end_dt
                   || ', amt = ' || l_all_SubLine_rec.subline_amt
                   || ', previous cp_term_dt = ' || l_all_subline_rec.cp_prev_term_dt
                 );
       END IF;



      IF TRUNC(p_term_dt) > l_cp_rec.cp_end_dt THEN
        IF l_line_rec.billing_schedule_type IN ('T', 'E') and l_top_bs_tbl.count > 0 THEN

           Rollup_lvl_amt(
                   p_Line_Rec     =>l_top_line_rec,
                   p_SubLine_rec    => l_cp_rec,
                   p_top_line_bs    => l_top_bs_tbl,
                   x_return_status  => x_return_status);

          IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.terminate_bill_sch.adj_lvl_amt',
                       'Rollup_lvl_amt(x_return_status = '||x_return_status
                       ||')');
           END IF;

           IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
           END IF;
        END IF;

      ELSE    --term_dt < end date

       l_sll_in_tbl.DELETE;
       l_prev_term_dt := NULL;    ---for bug#3254423

       Get_SLL_info(p_top_line_id      => p_top_line_id,
                       p_line_id          => l_cp_rec.cp_id,
                       x_sll_tbl          => l_sll_in_tbl,
                       x_sll_db_tbl       => l_sll_db_tbl,
                       x_return_status    =>  x_return_status );

       IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.terminate_bill_sch.cp_sll',
                       'Get_SLL_info(x_return_status = '||x_return_status
                       ||', sll tbl count = '||l_sll_in_tbl.count||')');
       END IF;

       IF x_return_status <> 'S' THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;

       IF l_sll_in_tbl.count= 0  THEN
          RETURN;
       END IF;

       ---if sub line is already terminated
       IF l_all_subline_rec.cp_prev_term_dt IS NOT NULL THEN
         IF nvl(l_all_SubLine_rec.full_credit, 'N') = 'Y' THEN
           --with full credit change the term dt as subline start dt
           l_prev_term_dt := l_cp_rec.cp_start_dt;
         ELSE
           l_prev_term_dt := l_all_subline_rec.cp_prev_term_dt;
         END IF;
       ELSE           --sub line not terminated already

         IF nvl(p_sub_line_id, 100) =  -100 THEN         --full credit flag
           l_prev_term_dt := l_cp_rec.cp_start_dt;
         END IF;

       END IF;  ---chk subline already terminated

       -------------------------------------------------------------------------
       -- Begin partial period computation logic
       -- Developer Mani Choudhary
       -- Date 09-MAY-2005
       -- Added two new parameters p_period_start and p_period_type
       -------------------------------------------------------------------------
       Create_cp_lvl_elements
          ( p_billing_type      =>  NVL(l_line_rec.billing_schedule_type,'T'),
            p_cp_sll_tbl        => l_sll_in_tbl,
            p_Line_Rec          => l_top_line_rec,
            p_SubLine_rec       => l_cp_Rec,
            p_invoice_rulid     => l_line_rec.inv_rule_id,
            p_top_line_bs       => l_top_bs_tbl,
            p_term_dt           => nvl(l_prev_term_dt,p_term_dt),
            p_period_start      =>  l_period_start,
            p_period_type       =>  l_period_type,
            x_return_status     => x_return_status);

        IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.terminate_bill_sch.cp_lvl_ele',
                       'Create_cp_lvl_elements(x_return_status = '||x_return_status
                       ||', l_prev_term_dt = '||l_prev_term_dt
                       ||', p_term_dt = ' || p_term_dt ||' , l_period_start '||l_period_start||', l_period_type '||l_period_type||')');
        END IF;


       IF x_return_status <> 'S' THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
      END IF;           ----end of term_dt > end date
     END LOOP;
   END IF; ---END OF SUBLINE LOOP


   IF l_top_bs_tbl.COUNT >0 THEN            ---only for type 'T' l_top_bs_tbl will be having records
      OKS_BILL_LEVEL_ELEMENTS_PVT.update_row(
               p_api_version                  => l_api_version,
               p_init_msg_list                => l_init_msg_list,
               x_return_status                => x_return_status,
               x_msg_count                    => x_msg_count,
               x_msg_data                     => x_msg_data,
               p_letv_tbl                     => l_top_bs_tbl,
               x_letv_tbl                     => l_lvl_ele_tbl_out);

      IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.terminate_bill_sch.update_bs',
                       'oks_bill_level_elements_pvt.update_row(x_return_status = '||x_return_status
                       ||', top bs count = '||l_lvl_ele_tbl_out.count ||')');
      END IF;

      IF  x_return_status <> 'S' THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
   END IF;        ----end of  l_top_bs_tbl.COUNT >0

ELSE                 ---if only one subline is terminated

    ----get subline
   Open l_SubLine_Csr;
   FETCH l_SubLine_Csr Into l_SubLine_Rec;
   If l_SubLine_Csr%Notfound then
       Close l_SubLine_Csr;
       x_return_status := 'E';
       OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'SUB LINE NOT FOUND');
       RAISE G_EXCEPTION_HALT_VALIDATION;
   End If;
   Close l_SubLine_Csr;

   l_cp_rec.cp_id          :=  l_SubLine_rec.subline_id ;
   l_cp_rec.cp_start_dt    :=  l_SubLine_rec.cp_start_dt;
   l_cp_rec.cp_end_dt      :=  l_SubLine_rec.cp_end_dt ;
   l_cp_rec.cp_amt         :=  l_SubLine_rec.subline_amt ;
   l_cp_rec.cp_price_uom   :=  l_SubLine_rec.price_uom;
   IF l_period_type is not null AND l_period_start is not NULL THEN
      OPEN l_subline_amt_csr(l_SubLine_rec.subline_id);
      FETCH l_subline_amt_csr INTO l_cp_rec.cp_amt;
      CLOSE l_subline_amt_csr;
   END IF;
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

           fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.terminate_bill_sch.cp_dtl',
                      'id = ' || l_all_SubLine_rec.subline_id
                   || ', start dt = ' || l_SubLine_rec.cp_start_dt
                   || ', end dt = ' || l_SubLine_rec.cp_end_dt
                   || ', amt = ' || l_SubLine_rec.subline_amt
                 );
   END IF;


   IF TRUNC(p_term_dt) > l_cp_rec.cp_end_dt THEN
     RETURN;
   END IF;


  l_sll_in_tbl.DELETE;

  Get_SLL_info(p_top_line_id      => p_top_line_id,
               p_line_id          => p_sub_line_id,
               x_sll_tbl          => l_sll_in_tbl,
               x_sll_db_tbl       => l_sll_db_tbl,
               x_return_status    =>  x_return_status );

  IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.terminate_bill_sch.cp_sll',
                       'Get_SLL_info(x_return_status = '||x_return_status
                       ||', sll tbl count = '||l_sll_in_tbl.count||')');
  END IF;

  IF x_return_status <> 'S' THEN
     RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

  IF l_sll_in_tbl.count= 0 OR l_subline_rec.billing_schedule_type IS NULL THEN
          RETURN;
  END IF;

  IF l_subline_rec.billing_schedule_type IN ('T','E') THEN
   l_top_bs_tbl.DELETE;
   l_index  := 1;

   FOR l_line_BS_rec IN l_line_BS_csr(p_top_line_id)
   LOOP
     l_top_bs_tbl(l_index).id                     := l_line_BS_rec.id;
     l_top_bs_tbl(l_index).date_start             := l_line_BS_rec.date_start;
     l_top_bs_tbl(l_index).date_end               := l_line_bs_rec.date_end;
     l_top_bs_tbl(l_index).Amount                 := l_line_BS_rec.amount;
     l_top_bs_tbl(l_index).object_version_number  := l_line_BS_rec.object_version_number;
     l_top_bs_tbl(l_index).date_transaction       := l_line_BS_rec.date_transaction;
     l_top_bs_tbl(l_index).date_to_interface      := l_line_BS_rec.date_to_interface;


     l_index := l_index + 1;
   END LOOP;

   IF l_top_bs_tbl.COUNT > 0 THEN

     Adjust_top_BS_Amt( p_Line_Rec          => l_top_Line_Rec,
                        p_SubLine_rec       => l_cp_Rec,
                        p_top_line_bs       => l_top_bs_tbl,
                        x_return_status     => x_return_status);

     IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.terminate_bill_sch.adjust_cp_amt',
                       'Adjust_top_BS_Amt(x_return_status = '||x_return_status ||')');
     END IF;

     IF x_return_status <> 'S' THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
   END IF;

  END IF;      ---end of T

 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- Added two new parameters p_period_start and p_period_type
 -------------------------------------------------------------------------
  Create_cp_lvl_elements
          ( p_billing_type      => NVL(l_subline_rec.billing_schedule_type,'T'),
            p_cp_sll_tbl        => l_sll_in_tbl,
            p_Line_Rec          => l_top_line_rec,
            p_SubLine_rec       => l_cp_Rec,
            p_invoice_rulid     => l_line_rec.inv_rule_id,
            p_top_line_bs       => l_top_bs_tbl,
            p_term_dt           => p_term_dt,
            p_period_start              =>  l_period_start,
            p_period_type               =>  l_period_type,
            x_return_status     => x_return_status);

  IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.terminate_bill_sch.cp_bs',
                       'Create_cp_lvl_elements(x_return_status = '||x_return_status ||')');
  END IF;

  IF x_return_status <> 'S' THEN
     RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

  IF l_subline_rec.billing_schedule_type IN ('E','T') AND l_top_bs_tbl.COUNT > 0 then
     OKS_BILL_LEVEL_ELEMENTS_PVT.update_row(
               p_api_version                  => l_api_version,
               p_init_msg_list                => l_init_msg_list,
               x_return_status                => x_return_status,
               x_msg_count                    => x_msg_count,
               x_msg_data                     => x_msg_data,
               p_letv_tbl                     => l_top_bs_tbl,
               x_letv_tbl                     => l_lvl_ele_tbl_out);

     IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.terminate_bill_sch.update_bs',
                       'oks_bill_level_elements_pvt.update_row(x_return_status = '||x_return_status
                       ||', top bs count = '||l_lvl_ele_tbl_out.count ||')');
      END IF;

     IF x_return_status <> 'S' THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
  END IF;         ---END OF update of top line sch

end if;       ---end of p_sub_line_id null



EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
 WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;

END Terminate_bill_sch;


 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------
PROCEDURE Create_cp_lvl_elements
(           p_billing_type      IN   VARCHAR2,
            p_cp_sll_tbl        IN   StrmLvl_Out_tbl,
            p_Line_Rec          IN   Line_Det_Type,
            p_SubLine_rec       IN   Prod_Det_Type,
            p_invoice_rulid     IN   Number,
            p_top_line_bs       IN   OUT NOCOPY oks_bill_level_elements_pvt.letv_tbl_type,
            p_term_dt           IN   DATE,
            p_period_start      IN   VARCHAR2,
            p_period_type       IN   VARCHAR2,
            x_return_status     OUT  NOCOPY Varchar2
)
IS

l_cp_sll_countER          Number;
l_period_counter          Number;
l_next_cycle_dt           Date;
l_tot_amt                 Number;
l_cp_sll_last             Number;
l_lvl_amt                 Number;
l_adjusted_amt            Number;
l_lvl_loop_counter        Number;
l_last_cycle_dt           Date;
l_bill_sch_amt            NUMBER :=0;
l_uom_quantity            NUMBER;
l_tce_code                VARCHAR2(100) ;
l_period_freq             NUMBER;
l_constant_sll_amt        NUMBER;
l_tbl_seq                 number;
l_remaining_amt           number;
l_tbs_ind                 NUMBER;
l_bill_end_date           DATE;
l_element_end_dt          DATE;
l_term_amt                NUMBER;
l_compare_dt              DATE;
i                         number;
l_end_date                DATE;
l_billed_at_source       OKC_K_HEADERS_ALL_B.BILLED_AT_SOURCE%TYPE;
--
   l_init_msg_list      VARCHAR2(2000) := OKC_API.G_FALSE;
   l_return_status      VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);
   l_msg_index_out      NUMBER;
   l_msg_index  NUMBER;

-- Start - Added by PMALLARA - Bug #3992530
Lvl_Element_cnt Number := 0;
Strm_Start_Date  Date;
-- End - Added by PMALLARA - Bug #3992530
 ------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 17-MAY-2005
 -------------------------------------------------------------------------
 l_quantity NUMBER;
 l_total_quantity NUMBER;
 l_duration       NUMBER;
 l_uom            VARCHAR2(30);
 l_full_period_end_date DATE;
 l_last_cmp_date       DATE;
--
--22-MAR-2006 mchoudha Changes for Partial periods CR3
l_running_total  NUMBER;
/*bug8609599*/
l_subline_total  NUMBER;

BEGIN
  -----errorout_ad('in  bill_sch_cp');
  x_return_status := 'S';
  l_bill_sch_amt := 0;
  l_lvl_ele_tbl_in.delete;
  l_tbl_seq := 1;
  --22-MAR-2006 mchoudha Changes for Partial periods CR3
  l_running_total := p_SubLine_rec.cp_amt;
  /*bug8609599*/
  l_subline_total := p_SubLine_rec.cp_amt;
   ------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 17-MAY-2005
 -- If price UOM is NULL , then derive the  UOM based on the effective dates
 -- of the subline.
 -------------------------------------------------------------------------
  IF (p_SubLine_rec.cp_price_uom is null) THEN
    OKC_TIME_UTIL_PUB.Get_Duration(p_SubLine_rec.cp_start_dt,p_SubLine_rec.cp_end_dt,l_duration,l_uom,x_return_status);
  END IF;
 ------------------------------------------------------------------------
 -- End partial period computation logic
 -------------------------------------------------------------------------

 IF TRUNC(nvl((p_term_dt-1),p_SubLine_rec.cp_end_dt)) > p_SubLine_rec.cp_end_dt THEN
   l_end_date := p_SubLine_rec.cp_end_dt;
 ELSE
   l_end_date := TRUNC(nvl((p_term_dt-1),p_SubLine_rec.cp_end_dt)) ;
 END IF;


  IF l_header_billing IS NULL THEN
     Delete_lvl_element(p_cle_id        => p_SubLine_rec.cp_id,
                        x_return_status => x_return_status);

     IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
  END IF;

  ----(terminate dt - 1) < st dt then do not create lvl element.

 IF TRUNC(p_SubLine_rec.cp_start_dt)  > l_end_date THEN
     -----errorout_ad('p_top_line_bs COUNT = '|| p_top_line_bs.COUNT);
     IF  p_cp_sll_tbl.count > 0 AND p_top_line_bs.COUNT > 0THEN


       FOR l_cp_sll_counter IN p_cp_sll_tbl.first .. p_cp_sll_tbl.LAST
       LOOP

       Check_Existing_Lvlelement(
           p_sll_id              => p_cp_sll_tbl(l_cp_sll_counter).id,
           p_sll_dt_start        => p_cp_sll_tbl(l_cp_sll_counter).dt_start,
           p_uom                => p_cp_sll_tbl(l_cp_sll_counter).uom,
           p_uom_per_period     => p_cp_sll_tbl(l_cp_sll_counter).uom_per_period,
           p_cp_end_dt           => p_SubLine_rec.cp_end_dt,
           x_next_cycle_dt       => l_next_cycle_dt,
           x_last_cycle_dt       => l_last_cycle_dt,
           x_period_counter      => l_period_counter,
           x_sch_amt             => l_bill_sch_amt,
           x_top_line_bs         => p_top_line_bs,
           x_return_status       => x_return_status);

           -----errorout_ad('Check_Existing_Lvlelement 1 = '|| x_return_status);
           IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
              RAISE G_EXCEPTION_HALT_VALIDATION;
           END IF;
       END LOOP;
     END IF;     ---END OF p_cp_sll_tbl.count

     x_return_status := 'S';
     RETURN;
 END IF;

 IF p_cp_sll_tbl.count > 0 then

    l_cp_sll_counter := p_cp_sll_tbl.FIRST;
    L_cp_sll_last    := p_cp_sll_tbl.LAST;


    LOOP      ------LOOP for sll item
      -----errorout_ad('SUB LINE START DATE PASSED TO CHECK LEVELEMENT : '||to_char(p_SubLine_rec.cp_start_dt));
      -----errorout_ad('passed l_bill_sch_amt = ' || l_bill_sch_amt);

      IF l_header_billing IS NOT NULL THEN           ----hdr lvl billing no old sll and lvl elements
        l_next_cycle_dT := p_cp_sll_tbl(l_cp_sll_counter).dt_start;
        l_lvl_loop_counter := 1;
        l_period_counter := 1;
      ELSE
        Check_Existing_Lvlelement(
           p_sll_id              => p_cp_sll_tbl(l_cp_sll_counter).id,
           p_sll_dt_start        => p_cp_sll_tbl(l_cp_sll_counter).dt_start,
           p_uom                => p_cp_sll_tbl(l_cp_sll_counter).uom,
           p_uom_per_period     => p_cp_sll_tbl(l_cp_sll_counter).uom_per_period,
           p_cp_end_dt           => p_SubLine_rec.cp_end_dt,
           x_next_cycle_dt       => l_next_cycle_dt,
           x_last_cycle_dt       => l_last_cycle_dt,
           x_period_counter      => l_period_counter,
           x_sch_amt             => l_bill_sch_amt,
           x_top_line_bs         => p_top_line_bs,
           x_return_status       => x_return_status);

           -----errorout_ad('Check_Existing_Lvlelement 2= '|| x_return_status);

           IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                  RAISE G_EXCEPTION_HALT_VALIDATION;
           END IF;

        l_lvl_loop_counter := l_period_counter;


        -----errorout_ad('l_period_counter = '|| l_period_counter);
        -----errorout_ad('l_last_cycle_dt = ' || l_last_cycle_dt);
        -----errorout_ad('l_bill_sch_amt = ' || l_bill_sch_amt);
      END IF ;

      IF l_period_counter > to_number(p_cp_sll_tbl(l_cp_sll_counter).level_period) THEN

        IF l_cp_sll_counter + 1 <= p_cp_sll_tbl.LAST THEN
          l_next_cycle_dt := p_cp_sll_tbl(l_cp_sll_counter + 1).dt_start;
        ELSE
          l_next_cycle_dt := OKC_TIME_UTIL_PUB.get_enddate
                                   (p_cp_sll_tbl(l_cp_sll_counter).dt_start,
                                    p_cp_sll_tbl(l_cp_sll_counter).uom,
                                    (p_cp_sll_tbl(l_cp_sll_counter).uom_Per_Period *
                                            p_cp_sll_tbl(l_cp_sll_counter).level_period));

           l_next_cycle_dt := l_next_cycle_dt + 1;
        END IF;

      ELSE

           -----------errorout_ad('going in');
           -----------errorout_ad('l_last_cycle_dt = ' || l_last_cycle_dt);
        IF l_next_cycle_dt IS NULL THEN
           l_next_cycle_dt := OKC_TIME_UTIL_PUB.get_enddate
                                           (l_last_cycle_dt,
                                            p_cp_sll_tbl(l_cp_sll_counter).uom,
                                            p_cp_sll_tbl(l_cp_sll_counter).uom_Per_Period);

           l_next_cycle_dt := l_next_cycle_dt + 1;

        END IF;

        ---if cycle start dt is greater then cp end date then exit the procedure.

        -----errorout_ad('AFTER CHECK l_next_cycle_dt = '|| l_next_cycle_dt);

        IF TRUNC(l_next_cycle_dt) > l_end_date THEN

           IF l_cp_sll_counter < p_cp_sll_tbl.LAST AND p_top_line_bs.COUNT > 0 THEN

             l_cp_sll_counter := p_cp_sll_tbl.NEXT(l_cp_sll_counter);


             FOR i IN l_cp_sll_counter .. p_cp_sll_tbl.LAST
             LOOP

              Check_Existing_Lvlelement(
               p_sll_id              => p_cp_sll_tbl(i).id,
               p_sll_dt_start        => p_cp_sll_tbl(i).dt_start,
               p_uom                => p_cp_sll_tbl(i).uom,
               p_uom_per_period     => p_cp_sll_tbl(i).uom_per_period,
               p_cp_end_dt           => p_SubLine_rec.cp_end_dt,
               x_next_cycle_dt       => l_next_cycle_dt,
               x_last_cycle_dt       => l_last_cycle_dt,
               x_period_counter      => l_period_counter,
               x_sch_amt             => l_bill_sch_amt,
               x_top_line_bs         => p_top_line_bs,
               x_return_status       => x_return_status);

               -----errorout_ad('Check_Existing_Lvlelement 3= '|| x_return_status);

               IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                  RAISE G_EXCEPTION_HALT_VALIDATION;
               END IF;
            END LOOP;
           END IF;   ----END OF l_cp_sll_counter < p_cp_sll_tbl.LAST

           x_return_status := 'S';
           RETURN;

        END IF;
        IF l_cp_sll_counter  < p_cp_sll_tbl.LAST THEN

           l_compare_dt :=  TRUNC(p_cp_sll_tbl(l_cp_sll_counter + 1).dt_start);
        ELSE

           l_compare_dt := TRUNC( p_SubLine_rec.cp_end_dt) + 1;
        END IF;

        IF TRUNC(l_next_cycle_dt) >= l_compare_dt THEN

          NULL;
          -----------errorout_ad('COMING IN');
        ELSE

         IF p_billing_type = 'T' THEN
            OKS_BILL_UTIL_PUB.get_seeded_timeunit(
                p_timeunit      => p_cp_sll_tbl(l_cp_sll_counter).uom,
                x_return_status => x_return_status,
                x_quantity      => l_uom_quantity ,
                x_timeunit      => l_tce_code);

           IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
              RAISE G_EXCEPTION_HALT_VALIDATION;
           END IF;


          l_remaining_amt := nvl(p_SubLine_rec.cp_amt,0) - nvl(l_bill_sch_amt,0);

           -------------------------------------------------------------------------
           -- Begin partial period computation logic
           -- Developer Mani Choudhary
           -- Date 17-MAY-2005
           -- get the converted unit price per SLL UOM derived from the unit price stored at the
           -- subline.
           -------------------------------------------------------------------------


           IF p_period_start is not null  AND
              p_period_type is not null
           THEN
              --new procedure for CALENDAR START and service start
              --30-DEC-2005 mchoudha fixed bug#4895586
              --Added an extra parameter termination date to this API
              l_constant_sll_amt := OKS_BILL_SCH.Get_Unit_Price_Per_Uom
                                                      (p_SubLine_rec.cp_id,
                                                       p_cp_sll_tbl(l_cp_sll_counter).uom,
                                                       p_period_start,
                                                       p_period_type,
                                                       p_cp_sll_tbl(l_cp_sll_counter).uom_per_period,
                                                       l_end_date,
                                                       p_term_dt);

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Create_cp_lvl_elements',
                       'after calling OKS_BILL_SCH.Get_Unit_Price_Per_Uom  '
                     ||' result l_constant_sll_amt = ' || l_constant_sll_amt);
              END IF;
              IF l_constant_sll_amt IS NULL THEN
                x_return_status := G_RET_STS_ERROR;
                RAISE G_EXCEPTION_HALT_VALIDATION;
              END IF;
              --errorout_ad(' l_constant_sll_amt '||l_constant_sll_amt);
            ELSE



               Get_Constant_sll_Amount(p_line_start_date      => p_SubLine_rec.cp_start_dt,
                                 p_line_end_date         => p_SubLine_rec.cp_end_dt,
                                 p_cycle_start_date      => l_next_cycle_dt,
                                 p_remaining_amount      => l_remaining_amt,
                                 P_uom_quantity          => l_uom_quantity,
                                 P_tce_code              => l_tce_code,
                                 x_constant_sll_amt      => l_constant_sll_amt,
                                 x_return_status         => x_return_status);
            END IF;
          -----errorout_ad('Get_Constant_sll_Amount = ' || l_constant_sll_amt);

           IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
              RAISE G_EXCEPTION_HALT_VALIDATION;
           END IF;
        END IF;


        IF p_top_line_bs.COUNT > 0 THEN
           -----errorout_ad('IN SLL l_next_cycle_dt = ' || l_next_cycle_dt);
           l_tbs_ind := p_top_line_bs.FIRST;
           WHILE TRUNC(l_next_cycle_dt) > p_top_line_bs(l_tbs_ind).DATE_START AND l_tbs_ind < p_top_line_bs.LAST
           LOOP
              l_tbs_ind := p_top_line_bs.NEXT(l_tbs_ind);
           END LOOP;

           -----errorout_ad('after while LOOP l_tbs_ind = ' || l_tbs_ind);
           -------errorout_ad('last = '|| p_top_line_bs.LAST);

           ---chk l_next_cycle_dt if between previous and present record
           IF l_tbs_ind = p_top_line_bs.first THEN
              NULL;

           ELSIF  l_tbs_ind <= p_top_line_bs.LAST THEN
              -----errorout_ad('COMING IN');

              l_element_end_dt := TRUNC(p_top_line_bs(l_tbs_ind ).DATE_END);


              IF TRUNC(l_next_cycle_dt) >= p_top_line_bs(l_tbs_ind ).DATE_START
                     AND TRUNC(l_next_cycle_dt) <= l_element_end_dt THEN

                    NULL;
              ELSE
                    l_tbs_ind := l_tbs_ind + 1;
              END IF;
              -----errorout_ad('FINAL l_tbs_ind = '|| l_tbs_ind);



          elsif TRUNC(p_SubLine_rec.cp_start_dt) = p_top_line_bs(l_tbs_ind ).DATE_START THEN
              l_tbs_ind := p_top_line_bs.first;
          END IF;
           -----errorout_ad('IN sll LOOP l_tbs_ind = ' || l_tbs_ind);
       END IF;

       ------------------------------------------------------------------------
       -- Begin partial period computation logic
       -- Developer Mani Choudhary
       -- Date 17-MAY-2005
       -- For manual covered levels, should take the billing uom as honoured in Get_Unit_Price_Per_Uom
       -------------------------------------------------------------------------
       IF p_subline_rec.cp_lse_id in (8,10,11,35) THEN
          l_uom := p_cp_sll_tbl(l_cp_sll_counter).uom;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Create_cp_lvl_elements',
                 ' result l_uom = ' || l_uom);
          END IF;

       END IF;
       OKS_BILL_UTIL_PUB.Get_Seeded_Timeunit
                    (p_timeunit      => p_cp_sll_tbl(l_cp_sll_counter).uom,
                     x_return_status => x_return_status,
                     x_quantity      => l_uom_quantity ,
                     x_timeunit      => l_tce_code);
       IF x_return_status <> 'S' THEN
         RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
       ------------------------------------------------------------------------
       -- End partial period computation logic
       ------------------------------------------------------------------------

-- Start - Added by PMALLARA - Bug #3992530
    Lvl_Element_cnt  := l_period_counter - 1;
    Strm_Start_Date  :=   p_cp_sll_tbl(l_cp_sll_counter).dt_start;
      LOOP                          -------------for level elements of one rule
    Lvl_Element_cnt  :=     Lvl_Element_cnt + 1;
-- End - Added by PMALLARA - Bug #3992530
          -----errorout_ad ('INSIDE LVL ELEMENT l_next_cycle_dt = ' || TO_CHAR(l_next_cycle_dt));
          -----errorout_ad('INSIDE LVL ELEMENT l_tbs_ind = ' || l_tbs_ind);

          l_fnd_lvl_in_rec.line_start_date           := p_SubLine_rec.cp_start_dt;
          l_fnd_lvl_in_rec.line_end_date             := nvl((p_term_dt - 1),p_SubLine_rec.cp_end_dt);
          l_fnd_lvl_in_rec.cycle_start_date          := l_next_cycle_dt;
-- Start - Modified by PMALLARA - Bug #3992530
        l_fnd_lvl_in_rec.tuom_per_period           := Lvl_Element_cnt * p_cp_sll_tbl(l_cp_sll_counter).uom_Per_Period;
-- End - Modified by PMALLARA - Bug #3992530
          l_fnd_lvl_in_rec.tuom                      := p_cp_sll_tbl(l_cp_sll_counter).uom;
          l_fnd_lvl_in_rec.bill_type                 := p_billing_type;

          IF p_billing_type = 'T' THEN

            l_fnd_lvl_in_rec.total_amount            := nvl(p_SubLine_rec.cp_amt,0) - nvl(l_bill_sch_amt,0) ;

            -----errorout_ad('subline amount  :' || l_fnd_lvl_in_rec.total_amount ));

          ELSE             --(for E and P just pass 0 as for lvlelement l_lvl_amt will be passed)

            l_fnd_lvl_in_rec.total_amount            := 0;
          END IF;

          l_fnd_lvl_in_rec.invoice_offset_days        := p_cp_sll_tbl(l_cp_sll_counter).invoice_offset_days;
          l_fnd_lvl_in_rec.interface_offset_days     := p_cp_sll_tbl(l_cp_sll_counter).Interface_offset_days;
        --mchoudha added this parameter
        l_fnd_lvl_in_rec.uom_per_period            := p_cp_sll_tbl(l_cp_sll_counter).uom_Per_Period;

          -----errorout_ad(' l_fnd_lvl_in_rec.line_start_date = ' || l_fnd_lvl_in_rec.line_start_date);
          -----errorout_ad(' l_fnd_lvl_in_rec.line_end_date = ' || l_fnd_lvl_in_rec.line_end_date);
          -----errorout_ad(' l_fnd_lvl_in_rec.cycle_start_date = ' || to_char(l_fnd_lvl_in_rec.cycle_start_date));
          -----errorout_ad(' l_fnd_lvl_in_rec.uom_per_period = ' || l_fnd_lvl_in_rec.uom_per_period);
          -----errorout_ad(' l_fnd_lvl_in_rec.uom = ' || l_fnd_lvl_in_rec.uom);
 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- Added two new parameters p_period_start and p_period_type
 -------------------------------------------------------------------------

        -- Start - Modified by PMALLARA - Bug #3992530
         IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_procedure,G_MODULE_CURRENT||'.Create_cp_Lvl_elements.lvl_loop',
                       'Calling oks_bill_util_pub.Get_next_bill_sch with parameters '
                       ||'period start = ' || p_period_start
                       ||', period type = ' || p_period_type);
          END IF;
          OKS_BILL_UTIL_PUB.Get_next_bill_sch
              (p_api_version             => l_api_version,
               x_return_status           => x_return_status,
               x_msg_count               => l_msg_count,
               x_msg_data                => l_msg_data,
               p_invoicing_rule_id       => p_invoice_rulid,
               p_bill_sch_detail_rec     => l_fnd_lvl_in_rec,
               x_bill_sch_detail_rec     => l_fnd_lvl_out_rec,
               p_period_start              =>  p_period_start,
               p_period_type               =>  p_period_type,
               Strm_Start_Date => Strm_Start_Date);
        -- End - Modified by PMALLARA - Bug #3992530


          -----errorout_ad(' OKS_BILL_UTIL_PUB.Get_next_bill_sch l_fnd_next_cycle = ' || x_return_status);
          -----errorout_ad('l_fnd_lvl_out_rec.next_cycle_date = ' || l_fnd_lvl_out_rec.next_cycle_date );


          IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;


          -------Next cycle date given by Get_next_bill_sch is <= cp start date then do not create
          ------level element AND fro daily billing only chk Get_next_bill_sch is < cp start date.

          IF  TRUNC(l_fnd_lvl_out_rec.next_cycle_date) <= p_SubLine_rec.cp_start_dt THEN
            -----errorout_ad('going in null');
            l_adjusted_amt := 0;
            l_tbs_ind := l_tbs_ind + 1;
          ELSE
             -----errorout_ad('going not in null');
            -----level element amount rounding and adjustment for last line


             IF  p_billing_type = 'T' THEN         ----FOR TYPE 'T'

                 ------------------------------------------------------------------------
                 -- Begin partial period computation logic
                 -- Developer Mani Choudhary
                 -- Date 17-MAY-2005
                 -- Added two new parameters p_period_start and p_period_type
                 -------------------------------------------------------------------------

                  IF p_period_start is not null   AND
                     p_period_type is not null
                  THEN

                       --to check if  first partial period
                        IF TRUNC(l_fnd_lvl_out_rec.next_cycle_date) >
                           p_SubLine_rec.cp_start_dt     AND
                           TRUNC(l_next_cycle_dt)<
                           p_SubLine_rec.cp_start_dt
                        THEN
                          IF l_tce_code not in ('DAY','HOUR','MINUTE') THEN
                            l_quantity:= OKS_TIME_MEASURES_PUB.get_quantity
                                           (p_start_date   => p_SubLine_rec.cp_start_dt,
                                            p_end_date     => TRUNC(l_fnd_lvl_out_rec.next_cycle_date)-1,
                                            p_source_uom   => l_fnd_lvl_in_rec.tuom,--nvl(p_SubLine_rec.cp_price_uom,l_uom), --line price uom
                                            p_period_type  => p_period_type ,
                                            p_period_start => p_period_start);

                            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                               fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Create_cp_lvl_elements.top_level.Service',
                              'after calling OKS_TIME_MEASURES_PUB.get_quantity  with period start '||p_period_start||' ,p_period_type '||p_period_type
                               ||' result l_quantity = ' || l_quantity);
                            END IF;

                            IF nvl(l_quantity,0) = 0 THEN
                              x_return_status := G_RET_STS_ERROR;
                              RAISE G_EXCEPTION_HALT_VALIDATION;
                            END IF;

                            l_lvl_amt :=  nvl(l_constant_sll_amt*l_quantity/l_fnd_lvl_in_rec.uom_per_period,0); --bugfix 5485442

                            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                               fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Create_cp_lvl_elements.top_level.Service',
                               ' result l_lvl_amt = ' || l_lvl_amt);
                            END IF;
                          --mchoudha added else logic for WEEK kind of uoms
                          ELSE
                              l_lvl_amt := nvl(l_constant_sll_amt*((TRUNC(l_fnd_lvl_out_rec.next_cycle_date)-TRUNC(p_SubLine_rec.cp_start_dt))/l_uom_quantity)/l_fnd_lvl_in_rec.uom_per_period,0); --bugfix 5485442

                          END IF;

                           --errorout_ad(' l_quantity '||l_quantity);
                           --errorout_ad(' l_total_quantity '||l_total_quantity);
                           --errorout_ad(' l_lvl_amt '||l_lvl_amt);
                          ELSE

                            IF p_period_start = 'CALENDAR'  AND
                               p_period_start is not null         AND
                               p_period_type is not null          AND
                               TRUNC(l_next_cycle_dt,'MM') <> TRUNC(l_next_cycle_dt)
                            THEN

                              --errorout_ad(' uom '||nvl(p_SubLine_rec.cp_price_uom,l_uom));
                              --errorout_ad(' start date '||to_char(l_next_cycle_dt));
                              --errorout_ad(' start date '||to_char(TRUNC(l_fnd_lvl_out_rec.next_cycle_date)-1));
                              --errorout_ad('p_period_start '||p_period_start);
                              --errorout_ad('p_period_type '||p_period_type);
                              IF l_tce_code not in ('DAY','HOUR','MINUTE') THEN
                              l_quantity:= OKS_TIME_MEASURES_PUB.get_quantity
                                           (p_start_date   => l_next_cycle_dt,
                                            p_end_date     => TRUNC(l_fnd_lvl_out_rec.next_cycle_date)-1,
                                            p_source_uom   =>  l_fnd_lvl_in_rec.tuom,--nvl(p_SubLine_rec.cp_price_uom,l_uom), --line price uom
                                            p_period_type  => p_period_type,
                                            p_period_start => p_period_start);

                              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                                 fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Create_cp_lvl_elements.top_level.Calendar',
                                 'after calling OKS_TIME_MEASURES_PUB.get_quantity  with period start '||p_period_start||' ,p_period_type '||p_period_type
                                 ||' result l_quantity = ' || l_quantity);
                              END IF;

                             --errorout_ad(' l_quantity '||l_quantity);
                                                      --errorout_ad(' b4 calling quantity2');
                             IF nvl(l_quantity,0) = 0 THEN
                               x_return_status := G_RET_STS_ERROR;
                               RAISE G_EXCEPTION_HALT_VALIDATION;
                             END IF;


                             l_lvl_amt :=  nvl(l_constant_sll_amt*l_quantity/l_fnd_lvl_in_rec.uom_per_period,0); --bugfix 5485442

                             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                                fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Create_cp_lvl_elements.top_level.Calendar',
                                ' result l_lvl_amt = ' || l_lvl_amt);
                             END IF;

                          --mchoudha added else logic for WEEK kind of uoms
                          ELSE
                              l_lvl_amt := nvl(l_constant_sll_amt*((TRUNC(l_fnd_lvl_out_rec.next_cycle_date)-TRUNC(l_next_cycle_dt))/l_uom_quantity)/l_fnd_lvl_in_rec.uom_per_period,0);   --bugfix 5485442

                          END IF;
                             --errorout_ad(' l_lvl_amt '||l_lvl_amt);

                            ELSE
                                    l_lvl_amt :=  nvl(l_constant_sll_amt,0);
                                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                                       fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Create_cp_lvl_elements.top_level.full-period',
                                      '  l_lvl_amt = ' || l_lvl_amt);
                                    END IF;

                                    --errorout_ad(' l_lvl_amt in else '||l_lvl_amt);
                            END IF;
                          END IF;
                  ELSE    --period start and period type are not null

                      l_adjusted_amt := 0;
                      Get_Period_Frequency(p_line_start_date => p_SubLine_rec.cp_start_dt,
                              p_line_end_date         => p_SubLine_rec.cp_end_dt,
                              p_cycle_start_date      => l_next_cycle_dt,
                              p_next_billing_date     => trunc(l_fnd_lvl_out_rec.next_cycle_date),
                              P_uom_quantity          => l_uom_quantity,
                              P_tce_code              => l_tce_code,
                              p_uom_per_period       => p_cp_sll_tbl(l_cp_sll_counter).uom_Per_Period,
                              x_period_freq           => l_period_freq,
                              x_return_status         => x_return_status);


                         -----errorout_ad('Get_Period_Frequency = ' || x_return_status);
                      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                         RAISE G_EXCEPTION_HALT_VALIDATION;
                      END IF;

                      l_lvl_amt := (NVL(l_period_freq,0) * NVL(l_constant_sll_amt,0) );

                      --l_lvl_amt := l_fnd_lvl_out_rec.cycle_amount;

                  END IF;   --period start and period type are not null
            ELSE                          ------FOR E
                            IF p_period_start = 'CALENDAR'  AND
                               p_period_start is not null         AND
                               p_period_type is not null          AND
                               TRUNC(l_next_cycle_dt,'MM') <> TRUNC(l_next_cycle_dt)
                            THEN
                              --errorout_ad(' Equal uom '||l_fnd_lvl_in_rec.tuom);
                                 --errorout_ad(' start date '||to_char(l_next_cycle_dt));
                              --errorout_ad(' end date '||to_char(TRUNC(l_fnd_lvl_out_rec.next_cycle_date)-1));
                              --errorout_ad('p_period_start '||p_period_start);
                              --errorout_ad('p_period_type '||p_period_type);
                              IF l_tce_code not in ('DAY','HOUR','MINUTE') THEN
                                l_quantity:= OKS_TIME_MEASURES_PUB.get_quantity
                                           (p_start_date   => l_next_cycle_dt,
                                            p_end_date     => TRUNC(l_fnd_lvl_out_rec.next_cycle_date)-1,
                                            p_source_uom   => l_fnd_lvl_in_rec.tuom, --line price uom
                                            p_period_type  => p_period_type,
                                            p_period_start => p_period_start);

                                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                                   fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Create_cp_lvl_elements.Equal_amount.Calendar',
                                   'after calling OKS_TIME_MEASURES_PUB.get_quantity  with period start '||p_period_start||' ,p_period_type '||p_period_type
                                   ||' result l_quantity = ' || l_quantity);
                                END IF;

                               --errorout_ad(' l_quantity '||l_quantity);

                               IF nvl(l_quantity,0) = 0 THEN
                                 x_return_status := G_RET_STS_ERROR;
                                 RAISE G_EXCEPTION_HALT_VALIDATION;
                               END IF;
                               --determine  full period end date

                               l_lvl_amt :=  TO_NUMBER(p_cp_sll_tbl(l_cp_sll_counter).amount)*l_quantity/l_fnd_lvl_in_rec.uom_per_period; --bugfix 5485442


                               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                                 fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Create_cp_lvl_elements.Equal_amount.Calendar',
                                 ' result l_lvl_amt = ' || l_lvl_amt);
                               END IF;
                          --mchoudha added else logic for WEEK kind of uoms
                          ELSE
                              l_lvl_amt := nvl(TO_NUMBER(p_cp_sll_tbl(l_cp_sll_counter).amount)*((TRUNC(l_fnd_lvl_out_rec.next_cycle_date)-TRUNC(l_next_cycle_dt))/l_uom_quantity)/l_fnd_lvl_in_rec.uom_per_period,0);  --bugfix 5485442

                          END IF;

                        ELSE

                           l_lvl_amt :=  TO_NUMBER(p_cp_sll_tbl(l_cp_sll_counter).amount);
                        END IF;  --period start and period type are not null
            END IF;  --  IF  p_billing_type = 'T'
            -----if last level element to be inserted then find out the aDjusted amount

            IF p_period_start is not null AND
               p_period_type is not null  THEN
               l_last_cmp_date := l_end_date;
            ELSE
               l_last_cmp_date := p_SubLine_rec.cp_end_dt;
            END IF;

            ---start inserting in level element

            l_lvl_ele_tbl_in(l_tbl_seq).sequence_number        := to_char(l_period_counter);
            l_lvl_ele_tbl_in(l_tbl_seq).dnz_chr_id             := p_line_rec.dnz_chr_id;
            l_lvl_ele_tbl_in(l_tbl_seq).cle_id                 := p_subline_rec.cp_id;
            l_lvl_ele_tbl_in(l_tbl_seq).parent_cle_id          := p_line_rec.id;

            IF l_next_cycle_dt < p_SubLine_rec.cp_start_dt AND l_period_counter = 1 THEN
              l_lvl_ele_tbl_in(l_tbl_seq).date_start             :=  TRUNC( p_SubLine_rec.cp_start_dt);
            ELSE
              l_lvl_ele_tbl_in(l_tbl_seq).date_start             :=   TRUNC(l_next_cycle_dt);
            END IF;
                        --errorout_ad('date start'||TRUNC(l_next_cycle_dt));
            --errorout_ad('date end'||TRUNC(TRUNC(l_fnd_lvl_out_rec.next_cycle_date) - 1));

            l_lvl_ele_tbl_in(l_tbl_seq).date_END               :=   TRUNC(l_fnd_lvl_out_rec.next_cycle_date) - 1;
            --30-DEC-2005 mchoudha fixed bug#4895586
            IF (l_cp_sll_counter = l_cp_sll_last AND
                l_lvl_loop_counter = p_cp_sll_tbl(l_cp_sll_last).level_period) OR
                --Mani PPC changed p_SubLine_rec.cp_end_dt to l_last_cmp_date
                (TRUNC(l_fnd_lvl_out_rec.next_cycle_date) > l_last_cmp_date) THEN

               l_adjusted_amt  := nvl(p_SubLine_rec.cp_amt,0) - nvl(l_bill_sch_amt,0);
               ---errorout_bill('p_SubLine_rec.cp_amt = ' || p_SubLine_rec.cp_amt);
               l_lvl_ele_tbl_in(l_tbl_seq).date_END := l_last_cmp_date;

            ELSE
               l_adjusted_amt :=  OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_lvl_amt, l_currency_code );
            END IF;

            l_lvl_ele_tbl_in(l_tbl_seq).amount                 := l_adjusted_amt;

	    /*commented and modified below for bug8609599
            --22-MAR-2006 mchoudha Changes for Partial periods CR3
            IF l_running_total < 0 THEN
               l_lvl_ele_tbl_in(l_tbl_seq).amount := 0;
            ELSIF l_running_total < l_adjusted_amt THEN
               l_lvl_ele_tbl_in(l_tbl_seq).amount := l_running_total;
            ELSE
               l_lvl_ele_tbl_in(l_tbl_seq).amount := l_adjusted_amt;
            END IF;
            IF l_adjusted_amt < 0 THEN
               l_lvl_ele_tbl_in(l_tbl_seq).amount := 0;
            END IF;
           */--bug8609599
            IF l_subline_total >= 0 THEN
              IF l_running_total < 0 THEN
               l_lvl_ele_tbl_in(l_tbl_seq).amount := 0;
              ELSIF l_running_total < l_adjusted_amt THEN
               l_lvl_ele_tbl_in(l_tbl_seq).amount := l_running_total;
              ELSE
               l_lvl_ele_tbl_in(l_tbl_seq).amount := l_adjusted_amt;
              END IF;
              IF l_adjusted_amt < 0 THEN
               l_lvl_ele_tbl_in(l_tbl_seq).amount := 0;
              END IF;
	    ELSE
              IF l_running_total > 0 THEN
               l_lvl_ele_tbl_in(l_tbl_seq).amount := 0;
              ELSIF l_running_total > l_adjusted_amt THEN
               l_lvl_ele_tbl_in(l_tbl_seq).amount := l_running_total;
              ELSE
               l_lvl_ele_tbl_in(l_tbl_seq).amount := l_adjusted_amt;
              END IF;
              IF l_adjusted_amt > 0 THEN
               l_lvl_ele_tbl_in(l_tbl_seq).amount := 0;
              END IF;
             END IF;
             /*end of modification for bug8609599*/
            --
            l_running_total := l_running_total - l_lvl_ele_tbl_in(l_tbl_seq).amount;

            l_lvl_ele_tbl_in(l_tbl_seq).date_receivable_gl     :=   l_fnd_lvl_out_rec.date_recievable_gl;
            l_lvl_ele_tbl_in(l_tbl_seq).date_transaction       :=   TRUNC(l_fnd_lvl_out_rec.date_transaction);
            l_lvl_ele_tbl_in(l_tbl_seq).date_due               :=   l_fnd_lvl_out_rec.date_due;
            l_lvl_ele_tbl_in(l_tbl_seq).date_print             :=   l_fnd_lvl_out_rec.date_print;
            l_lvl_ele_tbl_in(l_tbl_seq).date_to_interface      :=   TRUNC(l_fnd_lvl_out_rec.date_to_interface);

	    SELECT nvl(BILLED_AT_SOURCE , 'N')
	      INTO l_billed_at_source
	      FROM OKC_K_HEADERS_ALL_B
	    WHERE id = p_Line_rec.dnz_chr_id;

	   if l_billed_at_source = 'Y' Then
              l_lvl_ele_tbl_in(l_tbl_seq).date_completed  := sysdate;
           else
              l_lvl_ele_tbl_in(l_tbl_seq).date_completed := l_fnd_lvl_out_rec.date_completed;
           end if;

            l_lvl_ele_tbl_in(l_tbl_seq).rul_id                 :=   p_cp_sll_tbl(l_cp_sll_counter).id;
            l_lvl_ele_tbl_in(l_tbl_seq).object_version_number  :=   OKC_API.G_MISS_NUM;
            l_lvl_ele_tbl_in(l_tbl_seq).created_by             :=   OKC_API.G_MISS_NUM;
            l_lvl_ele_tbl_in(l_tbl_seq).creation_date          :=   SYSDATE;
            l_lvl_ele_tbl_in(l_tbl_seq).last_updated_by        :=   OKC_API.G_MISS_NUM;
            l_lvl_ele_tbl_in(l_tbl_seq).last_update_date       :=   SYSDATE;

            -----errorout_ad ('Amount for subline lvl element = ' || to_char(l_lvl_ele_tbl_in(l_tbl_seq).amount ));

        IF p_period_start is  null OR
           p_period_type is  null THEN

           IF p_term_dt IS NOT NULL AND TRUNC(l_lvl_ele_tbl_in(l_tbl_seq).date_start) < TRUNC(p_term_dt) AND
                TRUNC(l_fnd_lvl_out_rec.next_cycle_date) > TRUNC(p_term_dt) AND
                p_term_dt <= p_SubLine_rec.cp_end_dt THEN

                -----errorout_ad('COMING IN');

               l_lvl_ele_tbl_in(l_tbl_seq).date_END               := (p_term_dt - 1);

               IF TRUNC(l_fnd_lvl_out_rec.next_cycle_date - 1 ) > p_SubLine_rec.cp_end_dt THEN

                    l_term_amt := Find_term_amt(p_cycle_st_dt  =>  l_lvl_ele_tbl_in(l_tbl_seq).date_start,
                                       p_term_dt         =>   p_term_dt,
                                       p_cycle_end_dt    =>   p_SubLine_rec.cp_end_dt,
                                       p_amount          =>  nvl(l_lvl_ele_tbl_in(l_tbl_seq).amount,0));

                ELSE

                    l_term_amt := Find_term_amt(p_cycle_st_dt  =>  l_lvl_ele_tbl_in(l_tbl_seq).date_start,
                                       p_term_dt         =>  p_term_dt,
                                       p_cycle_end_dt    =>  l_fnd_lvl_out_rec.next_cycle_date - 1,
                                       p_amount          =>  nvl(l_lvl_ele_tbl_in(l_tbl_seq).amount,0));

                END IF;              ---END OF NEXT CYCLE DT CHK


              l_lvl_ele_tbl_in(l_tbl_seq).amount  := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_term_amt, l_currency_code );
           END IF;
         END IF;

            IF p_top_line_bs.COUNT > 0  THEN

              IF l_tbs_ind  <= p_top_line_bs.LAST THEN

               IF l_tbs_ind  = p_top_line_bs.LAST THEN
                  l_bill_end_date := p_SubLine_rec.cp_end_dt;
               ELSE
                  l_bill_end_date := p_top_line_bs(l_tbs_ind).date_end;
               END IF;

               IF p_top_line_bs(l_tbs_ind).date_start <= l_lvl_ele_tbl_in(l_tbl_seq).date_start
                  AND (l_bill_end_date) >= l_lvl_ele_tbl_in(l_tbl_seq).date_start THEN

                  p_top_line_bs(l_tbs_ind).amount := nvl(p_top_line_bs(l_tbs_ind).amount,0) +
                                                     nvl(l_lvl_ele_tbl_in(l_tbl_seq).amount,0);

                  --added so that top line and subline interface/invoice dates are same

                  l_lvl_ele_tbl_in(l_tbl_seq).date_to_interface := p_top_line_bs(l_tbs_ind).date_to_interface;
                  l_lvl_ele_tbl_in(l_tbl_seq).date_transaction  := p_top_line_bs(l_tbs_ind).date_transaction;

                  l_tbs_ind := l_tbs_ind + 1;
               ELSE

                  NULL;
               END IF;
             END IF;   ---End of l_tbs_ind  <= p_top_line_bs.LAST condition  added for bug#2655416
            END IF;

          ---incremented here because if billing is DONE for last 6 months then
          ---sequence no. was starting from 7.

          l_period_counter := l_period_counter + 1;


          END IF;           ----end of check of next cycle dt <= line st_dt

          l_next_cycle_dt  := trunc(l_fnd_lvl_out_rec.next_cycle_date);
          l_bill_sch_amt := nvl(l_bill_sch_amt,0) + nvl(l_adjusted_amt,0);
          l_tbl_seq := l_tbl_seq + 1;

          -----errorout_ad('l_bill_sch_amt = ' || l_bill_sch_amt);
          -----errorout_ad('compared with ' || p_cp_sll_tbl(l_cp_sll_counter).level_period);

          EXIT WHEN (l_lvl_loop_counter = p_cp_sll_tbl(l_cp_sll_counter).level_period) OR
                    (TRUNC(l_next_cycle_dt) > l_end_date) OR
                    (TRUNC(l_next_cycle_dt) >= TRUNC(l_compare_dt));

          l_lvl_loop_counter := l_lvl_loop_counter + 1;

        END LOOP;                ----end of level element loop

      END IF;
      END IF ;      ------TRUNC(l_next_cycle_dt) >= l_compare_dt
                     ----if start of period counter < sll line period then only enter in lvl elemet loop
      EXIT WHEN (l_cp_sll_counter = p_cp_sll_tbl.LAST) OR
                (TRUNC(l_next_cycle_dt) > l_end_date);


      l_cp_sll_counter := p_cp_sll_tbl.NEXT(l_cp_sll_counter);
    END LOOP;                     ---- sll loop
  END IF ;

  IF l_cp_sll_counter < p_cp_sll_tbl.LAST AND p_top_line_bs.COUNT > 0 THEN

     l_cp_sll_counter := p_cp_sll_tbl.NEXT(l_cp_sll_counter);

     FOR i IN l_cp_sll_counter .. p_cp_sll_tbl.LAST
     LOOP

       Check_Existing_Lvlelement(
           p_sll_id              => p_cp_sll_tbl(i).id,
           p_sll_dt_start        => p_cp_sll_tbl(i).dt_start,
           p_uom                => p_cp_sll_tbl(i).uom,
           p_uom_per_period     => p_cp_sll_tbl(i).uom_per_period,
           p_cp_end_dt           => p_SubLine_rec.cp_end_dt,
           x_next_cycle_dt       => l_next_cycle_dt,
           x_last_cycle_dt       => l_last_cycle_dt,
           x_period_counter      => l_period_counter,
           x_sch_amt             => l_bill_sch_amt,
           x_top_line_bs         => p_top_line_bs,
           x_return_status       => x_return_status);
     END LOOP;

     -----errorout_ad('Check_Existing_Lvlelement5 = '|| x_return_status);
     IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
              RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
  END IF;     ---END OF l_cp_sll_counter < p_cp_sll_tbl.LAST



  IF l_lvl_ele_tbl_in.COUNT > 0 THEN

     IF l_lvl_ele_tbl_in(l_lvl_ele_tbl_in.LAST).date_end > p_subline_rec.cp_end_dt THEN
       l_lvl_ele_tbl_in(l_lvl_ele_tbl_in.LAST).date_end := p_subline_rec.cp_end_dt;
     END IF;

     OKS_BILL_LEVEL_ELEMENTS_PVT.insert_row(
               p_api_version                  => l_api_version,
               p_init_msg_list                => l_init_msg_list,
               x_return_status                => x_return_status,
               x_msg_count                    => l_msg_count,
               x_msg_data                     => l_msg_data,
               p_letv_tbl                     => l_lvl_ele_tbl_in,
               x_letv_tbl                     => l_lvl_ele_tbl_out);

     -----errorout_ad('LEVEL ELEMENT INSERT STATUS FOR SUBLINE = ' || x_return_status);


      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
  END IF;


EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
 WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;
END Create_cp_lvl_elements;

Procedure Create_hdr_schedule
(
          p_contract_id         IN    NUMBER,
          x_return_status       OUT   NOCOPY VARCHAR2,
          x_msg_count           OUT   NOCOPY NUMBER,
          x_msg_data            OUT   NOCOPY VARCHAR2)
IS

  Cursor l_contract_Csr Is
          SELECT hdr.id, TRUNC(hdr.start_date) start_dt,
          nvl(trunc(hdr.date_terminated - 1) ,TRUNC(hdr.end_date)) end_dt,
          hdr.inv_rule_id inv_rule_id, dtl.billing_schedule_type billing_schedule_type
          FROM   okc_k_headers_b hdr, oks_k_headers_b dtl
          WHERE  hdr.id = dtl.chr_id
          AND hdr.Id =  p_contract_id ;



  CURSOR l_hdr_sll_csr IS
       SELECT id,sequence_no,TRUNC(start_date) start_date, level_periods,
              uom_per_period, uom_code, TRUNC(end_date) end_date,
              interface_offset_days, invoice_offset_days, cle_id, dnz_chr_id,
              chr_id, level_amount
       FROM OKS_STREAM_LEVELS_B
       WHERE chr_id = p_contract_id
       ORDER BY sequence_no;



 l_hdr_sll_rec             l_hdr_sll_csr%ROWTYPE;
 l_Contract_Rec            l_contract_Csr%Rowtype;
 l_sll_tbl                 OKS_BILL_SCH.StreamLvl_tbl;
 l_hdr_rec                 contract_rec_type;


 L_SLL_OUT_TBl             StrmLvl_Out_tbl;
 l_sll_count              NUMBER;
 l_index                  NUMBER;


  --
   l_api_version                CONSTANT        NUMBER  := 1.0;
   l_init_msg_list      VARCHAR2(2000) := OKC_API.G_FALSE;
  --
-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 04-MAY-2005
-------------------------------------------------------------------------
l_price_uom         OKS_K_HEADERS_B.PRICE_UOM%TYPE;
l_period_start      OKS_K_HEADERS_B.PERIOD_START%TYPE;
l_period_type       OKS_K_HEADERS_B.PERIOD_TYPE%TYPE;
l_return_status  VARCHAR2(30);
-------------------------------------------------------------------------
-- End partial period computation logic
-- Date 04-MAY-2005
-------------------------------------------------------------------------

Begin
x_return_status := 'S';
  l_header_billing := p_contract_id;

  ------------find out the hdr details

  Open l_contract_Csr;
  Fetch l_contract_Csr Into l_contract_Rec;

  If l_contract_Csr%Notfound then
    Close l_contract_Csr;
    x_return_status := 'E';
    RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;
  Close l_contract_Csr;

  l_hdr_rec.id       := l_contract_rec.id;
  l_hdr_rec.start_dt := l_contract_rec.start_dt;
  l_hdr_rec.end_dt   := l_contract_rec.end_dt;


 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------


   OKS_RENEW_UTIL_PUB.Get_Period_Defaults
                (
                 p_hdr_id        => l_contract_rec.id,
                 p_org_id        => NULL,
                 x_period_start  => l_period_start,
                 x_period_type   => l_period_type,
                 x_price_uom     => l_price_uom,
                 x_return_status => x_return_status);

   IF x_return_status <> 'S' THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

 -------------------------------------------------------------------------
 -- End partial period computation logic
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------
l_sll_tbl.DELETE;
l_index := 1;
----make sll tbl

FOR l_hdr_SlL_rec IN l_hdr_sll_Csr
LOOP


  l_sll_tbl(l_index).id                             := l_hdr_SlL_rec.id;
  l_sll_tbl(l_index).cle_id                         := NULL;
  l_sll_tbl(l_index).chr_id                         := p_contract_id;
  l_sll_tbl(l_index).dnz_chr_id                     := p_contract_id;
  l_sll_tbl(l_index).uom_code                       := l_hdr_SlL_rec.uom_code;
  l_sll_tbl(l_index).sequence_no                    := l_hdr_SlL_rec.sequence_no;
  l_sll_tbl(l_index).Start_Date                     := l_hdr_SlL_rec.Start_Date;
  l_sll_tbl(l_index).end_Date                       := l_hdr_SlL_rec.end_Date;
  l_sll_tbl(l_index).level_periods                  := l_hdr_SlL_rec.level_periods;
  l_sll_tbl(l_index).uom_per_period                 := l_hdr_SlL_rec.uom_per_period;
  l_sll_tbl(l_index).level_amount                   := l_hdr_SlL_rec.level_amount;
  l_sll_tbl(l_index).invoice_offset_days            := l_hdr_SlL_rec.invoice_offset_days;
  l_sll_tbl(l_index).interface_offset_days          := l_hdr_SlL_rec.interface_offset_days;

  l_index := l_index + 1;
END LOOP;


IF l_sll_tbl.COUNT = 0 THEN
   RETURN;
END IF;



  -----create rules with category 'SLL'
 --------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- Added two new parameters P_period_start,P_period_type in procedural call
 ---------------------------------------------------------------------------
  Create_Stream_Level (  p_billing_type       => nvl(l_contract_rec.billing_schedule_type, 'T'),
                         p_strm_lvl_tbl       => l_sll_tbl,
                         p_dnz_chr_id         => l_Contract_Rec.id,
                         p_subline_call       => 'H',
                         p_line_amt           => NULL,
                         p_subline_amt        => NULL,
                         p_sll_start_dt       => l_contract_rec.start_dt,
                         p_end_dt             => l_contract_rec.end_dt,
                         p_period_start       =>  l_period_start,
                         p_period_type        =>  l_period_type,
                         x_sll_out_tbl        => l_sll_out_tbl,
                         x_return_status      => x_return_status);
 -------------------------------------------------------------------------
 -- End partial period computation logic
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------
  -----errorout_ad('Create_Stream_Level status = ' || x_return_status);
  -----errorout_ad('TOTAL SLL COUNT for line'|| TO_CHAR(l_sll_out_tbl.COUNT));

  IF x_return_status <> 'S' THEN
    RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

  ----if l_sll_out_tbl.count > 0 then insert lines into oks_level_elements
  IF l_sll_out_tbl.count > 0 then

     l_currency_code := Find_Currency_Code(
                                    p_cle_id  => NULL,
                                    p_chr_id  => p_contract_id);
     IF l_currency_code IS NULL THEN
        OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'CURRENCY CODE NOT FOUND.');
        x_return_status := 'E';
        RETURN;
     END IF;


     Create_Hdr_Level_elements(
                      p_billing_type     => nvl(l_contract_rec.billing_schedule_type, 'T'),
                      p_sll_tbl          => l_sll_out_tbl,
                      p_hdr_rec          => l_hdr_rec,
                      p_invoice_ruleid   => l_contract_rec.inv_rule_id,
                      p_called_from      => 2,
                      p_period_start       =>  l_period_start,
                      p_period_type        =>  l_period_type,
                      x_return_status    => x_return_status);

     -----errorout_ad('Create_Hdr_Level_elements status = ' || x_return_status);

     IF x_return_status <> 'S' THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
  ELSE
     -----errorout_ad('sll rule count = ' || to_char(0));
     x_return_status := 'E';
     RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF ;

l_header_billing := NULL;

EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
  l_currency_code := NULL;
  l_header_billing := NULL;

 WHEN OTHERS THEN
        l_currency_code := NULL;
        l_header_billing := NULL;
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;


END Create_hdr_schedule;


PROCEDURE Del_line_sll_lvl(p_line_id          IN  NUMBER,
                           x_return_status    OUT NOCOPY VARCHAR2,
                           x_msg_count        OUT NOCOPY NUMBER,
                           x_msg_data         OUT NOCOPY VARCHAR2)

IS
----will delete all lvlelements , sll for line if billing all sll billing type <> 'P'
---it will be called from create_bill_sch_rules.



BEGIN
x_return_status := 'S';


--------delete lvl elemets for line
DELETE FROM OKS_LEVEL_ELEMENTS
WHERE  rul_id IN (SELECT sll.id
       FROM OKS_STREAM_LEVELS_B sll
       WHERE  sll.cle_id = p_line_id);

---delete sll info
DELETE FROM OKS_STREAM_LEVELS_B
WHERE  cle_id = p_line_id;

----update billing type to 'P'

UPDATE oks_k_lines_b
SET billing_schedule_type = 'P'
WHERE cle_id = p_line_id;



EXCEPTION
  WHEN OTHERS THEN
    OKC_API.SET_MESSAGE(p_app_name         => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END Del_line_sll_lvl;


Procedure Delete_contract_bs_sll
(
          p_contract_id         IN    NUMBER,
          x_return_status       OUT   NOCOPY VARCHAR2,
          x_msg_count           OUT   NOCOPY NUMBER,
          x_msg_data            OUT   NOCOPY VARCHAR2)
IS
BEGIN
x_return_status := 'S';


--------delete lvl elemets for the whole contract
DELETE FROM OKS_LEVEL_ELEMENTS
WHERE  dnz_chr_id = p_contract_id;


---delete sll info for contract (header,line and subline)
DELETE FROM OKS_STREAM_LEVELS_B
WHERE  dnz_chr_id = p_contract_id;



EXCEPTION
  WHEN OTHERS THEN
    OKC_API.SET_MESSAGE(p_app_name         => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END Delete_contract_bs_sll;

Procedure Populate_end_date(p_line_id             IN NUMBER,
                            p_end_date            IN DATE,
                            p_term_date           IN DATE,
                            p_lse_id              IN NUMBER,
                            x_return_status       OUT NOCOPY VARCHAR2)

IS

 Cursor l_LineSch_Csr is
         SELECT sll.start_date,sll.uom_code, sll.uom_per_period,
                element.id,element.sequence_number,element.date_start,
                element.date_end,element.date_completed
                FROM oks_level_elements element, oks_stream_levels_b sll
                WHERE sll.id  = element.rul_id
                AND sll.cle_id = p_line_id
                ORDER BY element.date_start;

 CURSOR l_line_sll_csr IS
        SELECT id, start_date, OKC_TIME_UTIL_PUB.get_enddate(
                                      start_date,
                                  uom_code,
                                  uom_per_period * level_periods) sll_end_date
        FROM oks_stream_levels_b
        WHERE cle_id = p_line_id;

 CURSOR l_bcl_csr(p_line_id number, p_start_date date) IS
         SELECT date_billed_to
         FROM oks_bill_cont_lines
         WHERE cle_id = p_line_id
         AND TRUNC(date_billed_from) = TRUNC(p_start_date)
         AND bill_action = 'RI';

  CURSOR l_bsl_csr(p_line_id number, p_start_date date) IS
         SELECT bsl.date_billed_to
         FROM oks_bill_sub_lines bsl, oks_bill_cont_lines bcl
         WHERE bsl.cle_id = p_line_id
         AND TRUNC(bsl.date_billed_from) = TRUNC(p_start_date)
         AND bsl.bcl_id = bcl.id
         AND bcl.bill_action = 'RI';



 l_LineSch_rec           l_LineSch_Csr%ROWTYPE;
 l_line_sll_rec          l_line_sll_csr%ROWTYPE;
 i                       number;
 l_end_dt                Date;
 l_line_end_dt           date;
 l_uom_code              varchar2(3);
 l_uom_per_period        number;
l_period_end_dt           date;

BEGIN

--The procedure update the sll end date and level elements end date for a line and subline.
---this is written as end date in oks_stream_levels_b and oks_level_elements didn't get migrated .

x_return_status := 'S';
l_period_end_dt := null;

l_lvl_ele_tbl_in.DELETE;

FOR l_line_sll_rec IN l_line_sll_csr
LOOP
  update oks_stream_levels_b set end_date = l_line_sll_rec.sll_end_date
  WHERE id = l_line_sll_rec.id;
END LOOP;


i := 1;

FOR l_LineSch_rec IN l_LineSch_csr
LOOP

       if i > 1 then
          l_lvl_ele_tbl_in(i - 1).Date_end        :=  l_LineSch_rec.date_start - 1;
       END IF;

       l_lvl_ele_tbl_in(i).Id                :=  l_LineSch_rec.id;
       l_lvl_ele_tbl_in(i).date_start        :=  l_LineSch_rec.date_start;
       l_lvl_ele_tbl_in(i).date_completed    :=  l_LineSch_rec.date_completed;

       l_uom_code        := l_LineSch_rec.uom_code;
       l_uom_per_period  := l_LineSch_rec.uom_per_period;

       i := i + 1;
END LOOP;

IF l_lvl_ele_tbl_in.COUNT > 0 THEN

  l_end_dt := OKC_TIME_UTIL_PUB.get_enddate(
                   l_lvl_ele_tbl_in(i - 1).Date_start,
                   l_uom_code,
                   l_uom_per_period);

  -----errorout_ad('calculated date = '|| l_end_dt || ' start = '|| l_lvl_ele_tbl_in(i - 1).Date_start);

  ---IF CALCULATED end date > line end date then take line end date

  IF p_term_date IS NOT NULL THEN

      IF l_lvl_ele_tbl_in(i-1).date_completed IS NOT NULL THEN      --- for billed

         IF p_lse_id IN (1, 12, 14, 19, 46) THEN        ---top line
               ---get period end date bill_cont_lines
               OPEN l_bcl_Csr(p_line_id, l_lvl_ele_tbl_in(i-1).date_start );
               FETCH l_bcl_Csr INTO l_period_end_dt;
               IF l_bcl_Csr%NOTFOUND THEN
                 l_period_end_dt := null;
               END IF;
               CLOSE l_bcl_Csr;
          ELSE               ---sub line
               ---get period end date bill_sub _lines
               OPEN l_bsl_Csr(p_line_id, l_lvl_ele_tbl_in(i-1).date_start);
               FETCH l_bsl_Csr INTO l_period_end_dt;
               IF l_bsl_Csr%NOTFOUND THEN
                 l_period_end_dt := null;
               END IF;
               CLOSE l_bsl_Csr;
          END IF;              ---end of top line chk

      END IF;       ---end of bill chk

      IF l_period_end_dt IS NOT NULL THEN  ---rec in bill tbl
            l_lvl_ele_tbl_in(i-1).date_end :=  l_period_end_dt;
      ELSE

        IF l_end_dt > (p_term_date - 1) AND  l_lvl_ele_tbl_in(i-1).date_end < p_term_date  THEN

          l_lvl_ele_tbl_in(i-1).date_end     :=  (p_term_date - 1);
        ELSE
          l_lvl_ele_tbl_in(i-1).date_end :=  l_end_dt;
        END IF;
      END IF;           ----end of l_period_end_dt null chk

  ELSE               ---not terminated

     IF P_END_DATE IS NOT NULL AND l_end_dt > p_END_DATE THEN
       l_lvl_ele_tbl_in(i-1).date_end :=  p_END_DATE;
       -----errorout_ad('p_end_date = '|| p_end_date);
     ELSE
       l_lvl_ele_tbl_in(i-1).date_end :=  l_end_dt;
       -----errorout_ad('l_end_dt = '|| l_end_dt);
     END IF;
  end if;

  IF l_lvl_ele_tbl_in(i-1).date_end > p_END_DATE THEN
     l_lvl_ele_tbl_in(i-1).date_end := p_END_DATE;
  END IF;

  FOR i IN l_lvl_ele_tbl_in.FIRST .. l_lvl_ele_tbl_in.LAST
  LOOP

    UPDATE oks_level_elements SET date_end = TRUNC(l_lvl_ele_tbl_in(i).date_end)
    WHERE id = l_lvl_ele_tbl_in(i).id;
  END LOOP;
END IF;                  ---tbl count chk.




EXCEPTION
 WHEN OTHERS THEN
       x_return_status := G_RET_STS_UNEXP_ERROR;

END populate_end_date;



Procedure UPDATE_BS_ENDDATE(p_line_id         IN   NUMBER,
                            p_chr_id          IN   NUMBER,
                            x_return_status   OUT NOCOPY VARCHAR2)

IS


Cursor l_hdrSch_Csr Is
      SELECT sll.uom_code, sll.uom_per_period,
             element.id,element.date_start
       FROM oks_level_elements element, oks_stream_levels_b sll
       WHERE sll.id  = element.rul_id
       AND sll.chr_id = p_chr_id
       ORDER BY element.date_start;

CURSOR l_hdr_sll_csr IS
        SELECT id, start_date, OKC_TIME_UTIL_PUB.get_enddate(
                                  start_DATE,
                                  uom_code,
                                  uom_per_period * level_periods) sll_end_date
        FROM oks_stream_levels_b
        WHERE chr_id = p_chr_id;

CURSOR l_line_csr IS
         SELECT TRUNC(end_date) end_date, trunc(date_terminated) date_terminated, lse_id
         FROM okc_k_lines_b
         WHERE id = p_line_id;

CURSOR l_subline_csr IS
         SELECT ID,TRUNC(end_date) end_date, trunc(date_terminated) date_terminated
         FROM okc_k_lines_b
         WHERE cle_id = p_line_id
         AND lse_id in(35,7,8,9,10,11,13,18,25);

i             NUMBER;
l_end_dt         date;
l_line_rec     l_line_csr%ROWTYPE;
l_Subline_rec     l_subline_csr%ROWTYPE;
l_hdr_sll_rec     l_hdr_sll_csr%rowtype;
l_hdrSch_rec      l_hdrSch_Csr%rowtype;

 l_uom_code              varchar2(3);
 l_uom_per_period        number;



BEGIN

--The procedure update the sll end date and level elements end date for a hdr schedule.
---this is written as end date in oks_stream_levels_b and oks_level_elements didn't get migrated .



x_return_status := 'S';
l_lvl_ele_tbl_in.DELETE;

IF p_chr_id IS NOT NULL THEN
  FOR l_hdr_sll_rec IN l_hdr_sll_csr
  LOOP
    update oks_stream_levels_b set end_date = l_hdr_sll_rec.sll_end_date
     WHERE id = l_hdr_sll_rec.id;
  END LOOP;


  i := 1;

  FOR l_hdrSch_rec IN l_hdrsch_csr
  LOOP

       if i > 1 then
          l_lvl_ele_tbl_in(i - 1).Date_end        :=  l_hdrSch_rec.date_start - 1;
       END IF;

       l_lvl_ele_tbl_in(i).Id                :=  l_hdrSch_rec.id;
       l_lvl_ele_tbl_in(i).date_start        :=  l_hdrSch_rec.date_start;

        l_uom_code              := l_hdrSch_rec.uom_code;
        l_uom_per_period        := l_hdrSch_rec.uom_per_period;


       i := i + 1;
  END LOOP;

  IF l_lvl_ele_tbl_in.COUNT > 0 THEN
    l_end_dt := OKC_TIME_UTIL_PUB.get_enddate(
                   l_lvl_ele_tbl_in(i - 1).Date_start,
                   l_uom_code,
                   l_uom_per_period);

    l_lvl_ele_tbl_in(i-1).date_end :=  l_end_dt;


    FOR i IN l_lvl_ele_tbl_in.FIRST .. l_lvl_ele_tbl_in.LAST
    LOOP

      UPDATE oks_level_elements SET date_end = TRUNC(l_lvl_ele_tbl_in(i).date_end)
      WHERE id = l_lvl_ele_tbl_in(i).id;
    END LOOP;
  END IF;


ELSIF p_line_id IS NOT null THEN

    OPEN l_Line_Csr;
    FETCH l_Line_Csr INTO l_Line_rec;
    IF l_Line_Csr%NOTFOUND THEN
       CLOSE l_Line_Csr;
       RETURN;
    END IF;
    CLOSE l_Line_Csr;

    Populate_end_date(p_line_id            => p_line_id,
                      p_end_date           => l_line_rec.end_date,
                      p_term_date          => l_line_rec.date_terminated,
                      p_lse_id             => l_line_rec.lse_id,
                      x_return_status      => x_return_status);

    IF x_return_status <> 'S' THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


    IF l_line_rec.lse_id IN (1,12,14,19) THEN             ---if line is top line

       FOR l_subline_rec IN l_subline_csr
       LOOP

         Populate_end_date(p_line_id            => l_subline_rec.id,
                           p_end_date           => l_subline_rec.end_date,
                           p_term_date          => l_subline_rec.date_terminated,
                           p_lse_id             => 0,
                           x_return_status      => x_return_status);



         IF x_return_status <> 'S' THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;
       END LOOP;

     END IF;

END IF;            ---for line/hdr

COMMIT;
EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
        ROLLBACK;
        x_return_status := 'E';

 WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;


END update_bs_enddate;



PROCEDURE Rollup_lvl_amt(
                   p_Line_Rec          IN     Line_Det_Type,
                   p_SubLine_rec       IN     Prod_Det_Type,
                   p_top_line_bs       IN OUT NOCOPY oks_bill_level_elements_pvt.letv_tbl_type,
                   x_return_status     OUT    NOCOPY VARCHAR2)
IS

CURSOR l_cp_BS_csr(p_cp_id  NUMBER) IS
         SELECT id, trunc(date_start) date_start,
         amount, trunc(date_end) date_end
         FROM oks_level_elements element
         WHERE cle_id = p_cp_id
         ORDER by date_start;

l_cp_BS_rec          l_cp_BS_csr%ROWTYPE;
l_cp_bs_tbl          oks_bill_level_elements_pvt.letv_tbl_type;
l_index              number;
l_top_bs_ind         number;
l_cp_bs_ind          number;


BEGIN
x_return_status := OKC_API.G_RET_STS_SUCCESS;

l_cp_bs_tbl.DELETE;
l_index  := 1;

FOR l_cp_BS_rec IN l_cp_BS_csr(p_SubLine_rec.cp_id)
LOOP
  l_cp_bs_tbl(l_index).id              := l_cp_BS_rec.id;
  l_cp_bs_tbl(l_index).date_start      := l_cp_BS_rec.date_start;
  l_cp_bs_tbl(l_index).date_end        := l_cp_BS_rec.date_end;
  l_cp_bs_tbl(l_index).Amount          := l_cp_BS_rec.amount;

  l_index := l_index + 1;
END LOOP;

IF l_cp_bs_tbl.COUNT <= 0 THEN
   RETURN;
END IF;

l_cp_bs_ind := l_cp_bs_tbl.FIRST;
l_top_bs_ind := p_top_line_bs.FIRST;
-----errorout_ad('top line bs first = ' || l_top_bs_ind);

WHILE TRUNC(l_cp_bs_tbl(l_cp_bs_ind).date_start) > TRUNC(p_top_line_bs(l_top_bs_ind).DATE_START) AND
             l_top_bs_ind < p_top_line_bs.LAST
LOOP
    l_top_bs_ind := p_top_line_bs.NEXT(l_top_bs_ind);
END LOOP;

-----errorout_ad('after while loop in adj = ' || l_top_bs_ind);
---chk first cp bs.st_dt if between previous and present record


IF l_top_bs_ind = p_top_line_bs.first THEN
   NULL;

ELSIF  l_top_bs_ind <= p_top_line_bs.LAST THEN

  l_top_bs_ind := l_top_bs_ind - 1;
  IF TRUNC(l_cp_bs_tbl(l_cp_bs_ind).date_start) >= p_top_line_bs(l_top_bs_ind  ).DATE_START
      AND TRUNC(l_cp_bs_tbl(l_cp_bs_ind).date_start) <= p_top_line_bs(l_top_bs_ind ).DATE_end THEN

                    NULL;
  ELSE
      l_top_bs_ind := l_top_bs_ind + 1;
  END IF;

elsif TRUNC(l_cp_bs_tbl(l_cp_bs_ind).date_start) = TRUNC(p_top_line_bs(l_top_bs_ind).DATE_START) THEN
       NULL;

end if;


FOR l_cp_bs_ind IN l_cp_bs_tbl.FIRST .. l_cp_bs_tbl.LAST
LOOP

 IF l_top_bs_ind  <= p_top_line_bs.LAST THEN

    p_top_line_bs(l_top_bs_ind).amount := nvl(p_top_line_bs(l_top_bs_ind).amount,0) + nvl(l_cp_bs_tbl(l_cp_bs_ind).amount,0);
    l_top_bs_ind  := l_top_bs_ind + 1;

 END IF;
END LOOP;


EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
 WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;

end Rollup_lvl_amt;


/* Overloaded procedure for OKL bug# 3307323*/
Procedure Create_Bill_Sch_Rules
(
      p_slh_rec              IN    StreamHdr_Type
,     p_sll_tbl              IN    StreamLvl_tbl
,     p_invoice_rule_id      IN    Number
,     x_bil_sch_out_tbl      OUT   NOCOPY ItemBillSch_tbl
,     x_return_status        OUT   NOCOPY Varchar2
)

IS

BEGIN

x_return_status := 'S';

END Create_Bill_Sch_Rules;


PROCEDURE Adjust_cp_trx_inv_dt(
                        p_top_bs_tbl        IN     oks_bill_level_elements_pvt.letv_tbl_type,
                        p_SubLine_id        IN     NUMBER,
                        x_cp_line_bs        OUT NOCOPY oks_bill_level_elements_pvt.letv_tbl_type,
                        x_return_status     OUT    NOCOPY VARCHAR2)
IS

CURSOR l_cp_BS_csr IS
         SELECT id, trunc(date_start) date_start,
         date_to_interface, date_transaction, object_version_number
         FROM oks_level_elements
         WHERE cle_id = p_SubLine_id
         AND date_completed IS NULL
         ORDER BY date_start;

l_cp_BS_rec          l_cp_BS_csr%ROWTYPE;
l_cp_bs_tbl          oks_bill_level_elements_pvt.letv_tbl_type;
l_index              number;
l_top_bs_ind         number;
l_cp_bs_ind          number;


BEGIN
x_return_status := OKC_API.G_RET_STS_SUCCESS;

l_cp_bs_tbl.DELETE;
l_index  := 1;

FOR l_cp_BS_rec IN l_cp_BS_csr
LOOP
  l_cp_bs_tbl(l_index).id                    := l_cp_BS_rec.id;
  l_cp_bs_tbl(l_index).date_start            := l_cp_BS_rec.date_start;
  l_cp_bs_tbl(l_index).date_transaction      := l_cp_BS_rec.date_transaction;
  l_cp_bs_tbl(l_index).date_to_interface     := l_cp_BS_rec.date_to_interface;
  l_cp_bs_tbl(l_index).object_version_number := l_cp_BS_rec.object_version_number;


  l_index := l_index + 1;
END LOOP;

IF l_cp_bs_tbl.COUNT <= 0 THEN
   RETURN;
END IF;

l_cp_bs_ind := l_cp_bs_tbl.FIRST;
l_top_bs_ind := p_top_bs_tbl.FIRST;


WHILE l_cp_bs_tbl(l_cp_bs_ind).date_start > p_top_bs_tbl(l_top_bs_ind).DATE_START AND
      l_top_bs_ind < p_top_bs_tbl.LAST
LOOP
    l_top_bs_ind := p_top_bs_tbl.NEXT(l_top_bs_ind);
END LOOP;

---chk first cp bs.st_dt if between previous and present record

IF l_top_bs_ind = p_top_bs_tbl.first THEN
   NULL;

ELSIF l_cp_bs_tbl(l_cp_bs_ind).date_start >= p_top_bs_tbl(l_top_bs_ind - 1).DATE_START
     AND l_cp_bs_tbl(l_cp_bs_ind).date_start < p_top_bs_tbl(l_top_bs_ind ).DATE_START THEN

     l_top_bs_ind := l_top_bs_ind - 1;

elsif l_cp_bs_tbl(l_cp_bs_ind).date_start = p_top_bs_tbl(l_top_bs_ind).DATE_START THEN
     null;
END IF;

FOR l_cp_bs_ind IN l_cp_bs_tbl.FIRST .. l_cp_bs_tbl.LAST
LOOP

 IF l_top_bs_ind  <= p_top_bs_tbl.LAST THEN

    x_cp_line_bs(l_cp_bs_ind).id                    := l_cp_bs_tbl(l_cp_bs_ind).id;
    x_cp_line_bs(l_cp_bs_ind).date_start            := l_cp_bs_tbl(l_cp_bs_ind).date_start;
    x_cp_line_bs(l_cp_bs_ind).date_transaction      := p_top_bs_tbl(l_top_bs_ind).date_transaction;
    x_cp_line_bs(l_cp_bs_ind).date_to_interface     := p_top_bs_tbl(l_top_bs_ind).date_to_interface;
    x_cp_line_bs(l_cp_bs_ind).object_version_number := l_cp_bs_tbl(l_cp_bs_ind).object_version_number;

    l_top_bs_ind  := l_top_bs_ind + 1;

 END IF;
END LOOP;


EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
 WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;

end Adjust_cp_trx_inv_dt;



Procedure Preview_Subscription_Bs(p_sll_tbl              IN    StreamLvl_tbl,
                                  p_invoice_rule_id      IN    Number,
                                  p_line_detail          IN    LINE_TYPE,
                                  x_bil_sch_out_tbl      OUT   NOCOPY ItemBillSch_tbl,
                                  x_return_status        OUT   NOCOPY Varchar2)


IS
l_sll_tbl           OKS_BILL_SCH.StreamLvl_tbl;
l_index             NUMBER;
l_sll_prorate_tbl   sll_prorated_tab_type;
l_bill_sch_amt      NUMBER;
l_next_cycle_dt     DATE;
l_tbl_seq           NUMBER;
l_lvl_seq           NUMBER;
l_adjusted_amount   NUMBER;



l_api_version           CONSTANT        NUMBER  := 1.0;
l_init_msg_list         VARCHAR2(2000) := OKC_API.G_FALSE;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);

-- Start - Added by PMALLARA - Bug #3992530
Lvl_Element_cnt Number := 0;
Strm_Start_Date  Date;
-- End - Added by PMALLARA - Bug #3992530

l_period_start VARCHAR2(30);
l_period_type VARCHAR2(10);


BEGIN

x_return_status := 'S';

IF p_sll_tbl.count <= 0 THEN
  RETURN;
END IF;

l_sll_tbl  := p_sll_tbl;
l_sll_prorate_tbl.DELETE;

FOR l_index IN p_sll_tbl.FIRST .. p_sll_tbl.LAST
LOOP
  l_sll_prorate_tbl(l_index).sll_seq_num    := p_sll_tbl(l_index).Sequence_no;
  IF L_index = p_sll_tbl.FIRST THEN

    l_sll_prorate_tbl(l_index).sll_start_date := p_line_detail.start_dt;
  ELSE
    l_sll_prorate_tbl(l_index).sll_start_date := l_sll_prorate_tbl(l_sll_prorate_tbl.PRIOR(l_index)).sll_end_date + 1;
  END IF;

  l_sll_prorate_tbl(l_index).sll_end_date   := OKC_TIME_UTIL_PUB.get_enddate(
                                                  l_sll_prorate_tbl(l_index).sll_start_date,
                                                  p_sll_tbl(l_index).uom_code,
                                        (p_sll_tbl(l_index).level_periods * p_sll_tbl(l_index).uom_per_period));

  l_sll_prorate_tbl(l_index).sll_tuom       := p_sll_tbl(l_index).uom_code;
  l_sll_prorate_tbl(l_index).sll_period     := p_sll_tbl(l_index).level_periods;

END LOOP;


Calculate_sll_amount(
              p_api_version      => l_api_version,
              p_total_amount     => p_line_detail.amount,
              p_currency_code    => nvl(p_line_detail.currency_code,'USD'),
              p_period_start     => l_period_start,
              p_period_type      => l_period_type,
              p_sll_prorated_tab => l_sll_prorate_tbl,
              x_return_status    => x_return_status);


-----errorout_ad  ('Calculate_sll_amount STATUS = ' ||  x_return_status);


IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
   RAISE OKC_API.G_EXCEPTION_ERROR;
END IF;

FOR l_index IN l_sll_prorate_tbl.FIRST .. l_sll_prorate_tbl.LAST
LOOP
  l_sll_tbl(l_index).level_amount  := l_sll_prorate_tbl(l_index).sll_amount;
  l_sll_tbl(l_index).end_date      := l_sll_prorate_tbl(l_index).sll_end_date;
  l_sll_tbl(l_index).start_date      := l_sll_prorate_tbl(l_index).sll_start_date;

END LOOP;                  ---END OF sll tbl UPDATE LOOP


l_index  := l_sll_tbl.FIRST;
l_bill_sch_amt  := 0;
l_tbl_seq := 1;

LOOP                           ---sll tbl loop
  l_next_cycle_dt  := l_sll_tbl(l_index).start_date;
  l_lvl_seq := 1;

-- Start - Added by PMALLARA - Bug #3992530
    Lvl_Element_cnt  := 0;
      LOOP                          -------------for level elements of one rule
    Lvl_Element_cnt  :=     Lvl_Element_cnt + 1;
    if Lvl_Element_cnt = 1 then
        Strm_Start_Date :=   l_next_cycle_dt;
    end if;
-- End - Added by PMALLARA - Bug #3992530
    l_fnd_lvl_in_rec.line_start_date           := p_line_detail.start_dt;
    l_fnd_lvl_in_rec.line_end_date             := p_line_detail.end_dt;
    l_fnd_lvl_in_rec.cycle_start_date          := l_next_cycle_dt;
-- Start - Modified by PMALLARA - Bug #3992530
    l_fnd_lvl_in_rec.tuom_per_period           := Lvl_Element_cnt * l_sll_tbl(l_index).uom_Per_Period;
-- End - Modified by PMALLARA - Bug #3992530
    l_fnd_lvl_in_rec.tuom                      := l_sll_tbl(l_index).uom_code;
    l_fnd_lvl_in_rec.total_amount              := nvl(p_line_detail.amount,0) - nvl(l_bill_sch_amt,0);
    l_fnd_lvl_in_rec.invoice_offset_days       := l_sll_tbl(l_index).invoice_offset_days;
    l_fnd_lvl_in_rec.interface_offset_days     := l_sll_tbl(l_index).Interface_offset_days;
    l_fnd_lvl_in_rec.bill_type                 := 'E';
 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- Added two new parameters p_period_start and p_period_type
 -------------------------------------------------------------------------
-- Start - Modified by PMALLARA - Bug #3992530
    OKS_BILL_UTIL_PUB.Get_next_bill_sch
          (p_api_version             => l_api_version,
           x_return_status           => x_return_status,
           x_msg_count               => l_msg_count,
           x_msg_data                => l_msg_data,
           p_invoicing_rule_id       => NVL(p_invoice_rule_id,-2),
           p_bill_sch_detail_rec     => l_fnd_lvl_in_rec,
           x_bill_sch_detail_rec     => l_fnd_lvl_out_rec,
           p_period_start            =>  NULL,
           p_period_type             =>  NULL,
           Strm_Start_Date           => Strm_Start_Date);
-- End - Modified by PMALLARA - Bug #3992530


     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;



     IF TRUNC(l_fnd_lvl_out_rec.next_cycle_date) < p_Line_detail.start_dt then
          null;                       ---donot insert record in level element
     ELSE

         IF (l_index = l_sll_tbl.last AND
              l_lvl_seq = l_sll_tbl(l_sll_tbl.last).level_periods) OR
            (TRUNC(l_fnd_lvl_out_rec.next_cycle_date) > p_Line_detail.end_dt) THEN

            l_adjusted_amount  := nvl(p_Line_detail.amount,0) - nvl(l_bill_sch_amt,0);

         ELSE            --not adjustment round
            l_adjusted_amount  := l_sll_tbl(l_index).level_amount;
         END IF;



           --insert in lvl element preview tbl

           x_bil_sch_out_tbl(l_tbl_seq).Strm_Lvl_Seq_Num       := l_sll_tbl(l_index).sequence_no;
           x_bil_sch_out_tbl(l_tbl_seq).Lvl_Element_Seq_Num    := to_char(l_lvl_seq);
           IF l_next_cycle_dt < p_Line_detail.start_dt THEN
             x_bil_sch_out_tbl(l_tbl_seq).bill_from_date       :=   TRUNC(p_Line_detail.start_dt);
           ELSE
             x_bil_sch_out_tbl(l_tbl_seq).bill_from_date       :=   TRUNC(l_next_cycle_dt);
           END IF;

           x_bil_sch_out_tbl(l_tbl_seq).bill_to_date           :=   TRUNC(l_fnd_lvl_out_rec.next_cycle_date) - 1;

           x_bil_sch_out_tbl(l_tbl_seq).amount                 := OKS_EXTWAR_UTIL_PVT.round_currency_amt(
                                                                          l_adjusted_amount,NVL(p_line_detail.currency_code,'USD'));


           x_bil_sch_out_tbl(l_tbl_seq).tx_date                :=   TRUNC(l_fnd_lvl_out_rec.date_transaction);
           x_bil_sch_out_tbl(l_tbl_seq).interface_date         :=   TRUNC(l_fnd_lvl_out_rec.date_to_interface);

           l_bill_sch_amt := nvl(l_bill_sch_amt,0) + nvl(x_bil_sch_out_tbl(l_tbl_seq).amount,0);

           l_tbl_seq := l_tbl_seq + 1;
        END IF;          -----end if for level element creation

        l_next_cycle_dt  := l_fnd_lvl_out_rec.next_cycle_date;

        EXIT WHEN (l_lvl_seq = l_sll_tbl(l_index).level_periods) OR
                  (TRUNC(l_next_cycle_dt) > p_line_detail.end_dt) OR
                  (TRUNC(l_next_cycle_dt) > l_sll_tbl(l_index).end_date)
;

        l_lvl_seq      := l_lvl_seq + 1;

       END LOOP;                   ---loop for sll period counter

    EXIT WHEN (l_index = l_sll_tbl.LAST) OR
              (TRUNC(l_next_cycle_dt) > p_line_detail.end_dt);

    l_index  := l_sll_tbl.NEXT(l_index);

END LOOP;                    -----loop for sll tbl

EXCEPTION

 WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;


END Preview_Subscription_Bs;


PROCEDURE ADJUST_REPLACE_PRODUCT_BS(p_old_cp_id      IN    NUMBER,
                                    p_new_cp_id      IN    NUMBER,
                                    x_return_status  OUT   NOCOPY VARCHAR2,
                                    x_msg_count      OUT   NOCOPY NUMBER,
                                    x_msg_data       OUT   NOCOPY VARCHAR2)

IS

CURSOR l_old_sll_csr IS
  SELECT id , cle_id, dnz_chr_id ,
         sequence_no, uom_code,  start_date,
         end_date, uom_per_period,advance_periods,level_periods,
         level_amount, invoice_offset_days,interface_offset_days,
         comments, due_arr_yn,amount,
         lines_detailed_yn,  security_group_id
  FROM   OKS_STREAM_LEVELS_B
  WHERE  cle_id = p_old_cp_id
  ORDER BY START_DATE;

CURSOR l_old_bill_type_csr IS
  SELECT billing_schedule_type
  FROM OKS_K_LINES_B
  WHERE  cle_id = p_old_cp_id;

CURSOR l_new_cp_csr IS
  SELECT id,end_date
  FROM okc_k_lines_b
  WHERE id = p_new_cp_id;



l_old_sll_rec     l_old_sll_csr%ROWTYPE;
l_new_cp_rec      l_new_cp_csr%ROWTYPE;

l_old_bill_type   OKS_K_LINES_B.billing_schedule_type%TYPE;
l_sll_index       NUMBER;
l_index           NUMBER;
l_sll_end_date    DATE;

l_init_msg_list   VARCHAR2(2000) := OKC_API.G_FALSE;

BEGIN
x_return_status := 'S';



IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

   fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.adjust_replace_product_bs.line_details',
                   'old sub line id passed = ' || p_old_cp_id
                   || ', new sub line id passed = ' || p_new_cp_id
                   );
END IF;


OPEN l_old_bill_type_csr;
FETCH l_old_bill_type_csr INTO l_old_bill_type;
IF l_old_bill_type_csr%NOTFOUND THEN
   l_old_bill_type := 'T';
END IF;
CLOSE l_old_bill_type_csr;

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

   fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.adjust_replace_product_bs.billing_sch_type',
                   'old line billing scheduel type = ' || l_old_bill_type
                   );
END IF;

l_sll_index  := 0;
l_strm_lvl_tbl_in.DELETE;

FOR l_old_sll_rec IN l_old_sll_csr
LOOP

  l_sll_index := l_sll_index + 1;

  l_strm_lvl_tbl_in(l_sll_index).chr_id                   := NULL;
  l_strm_lvl_tbl_in(l_sll_index).cle_id                   := p_new_cp_id;
  l_strm_lvl_tbl_in(l_sll_index).dnz_chr_id               := l_old_sll_rec.dnz_chr_id;
  l_strm_lvl_tbl_in(l_sll_index).sequence_no              := l_old_sll_rec.sequence_no;
  l_strm_lvl_tbl_in(l_sll_index).uom_code                 := l_old_sll_rec.uom_code;
  l_strm_lvl_tbl_in(l_sll_index).start_date               := l_old_sll_rec.start_date;

  l_strm_lvl_tbl_in(l_sll_index).end_date                 := nvl(l_old_sll_rec.end_date,
                                                                 OKC_TIME_UTIL_PUB.get_enddate(
                                                                       l_old_sll_rec.start_date,
                                                                       l_old_sll_rec.uom_code,
                                                                      (l_old_sll_rec.level_periods *
                                                                        l_old_sll_rec.uom_per_period)) );


  l_strm_lvl_tbl_in(l_sll_index).level_periods            := l_old_sll_rec.level_periods;
  l_strm_lvl_tbl_in(l_sll_index).uom_per_period           := l_old_sll_rec.uom_per_period;
  l_strm_lvl_tbl_in(l_sll_index).level_amount             := l_old_sll_rec.level_amount;
  l_strm_lvl_tbl_in(l_sll_index).invoice_offset_days      := l_old_sll_rec.invoice_offset_days;
  l_strm_lvl_tbl_in(l_sll_index).interface_offset_days    := l_old_sll_rec.interface_offset_days;


  l_strm_lvl_tbl_in(l_sll_index).object_version_number     := OKC_API.G_MISS_NUM;
  l_strm_lvl_tbl_in(l_sll_index).created_by                := OKC_API.G_MISS_NUM;
  l_strm_lvl_tbl_in(l_sll_index).creation_date             := SYSDATE;
  l_strm_lvl_tbl_in(l_sll_index).last_updated_by           := OKC_API.G_MISS_NUM;
  l_strm_lvl_tbl_in(l_sll_index).last_update_date          := SYSDATE;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

   fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.adjust_replace_product_bs.new_sll_tbl_dtls',
                      'sll num = ' || l_sll_index
                   || ', sll start date = ' || l_strm_lvl_tbl_in(l_sll_index).start_date
                   || ', sll end date = ' || l_strm_lvl_tbl_in(l_sll_index).end_date
                   || ', sll uom_code = ' || l_strm_lvl_tbl_in(l_sll_index).uom_code
                   || ', sll uom_per_period = ' || l_strm_lvl_tbl_in(l_sll_index).uom_per_period
                   || ', sll sequence_no = ' || l_strm_lvl_tbl_in(l_sll_index).sequence_no
                   || ', sll cle id = ' || l_strm_lvl_tbl_in(l_sll_index).cle_id
                   );
  END IF;


END LOOP;

IF l_strm_lvl_tbl_in.COUNT > 0 THEN

  OKS_SLL_PVT.insert_row(
               p_api_version        => l_api_version,
               p_init_msg_list      => l_init_msg_list,
               x_return_status      => x_return_status,
               x_msg_count          => x_msg_count,
               x_msg_data           => x_msg_data,
               p_sllv_tbl           => l_strm_lvl_tbl_in,
               x_sllv_tbl           => l_strm_lvl_tbl_out);

  IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.adjust_replace_product_bs.insert_sll',
                         'OKS_SLL_PVT.insert_row(x_return_status = '||x_return_status
                         ||', sll tbl out count = '||l_strm_lvl_tbl_out.count||')');
  END IF;

  IF NVL(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS THEN
     RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

  OPEN l_new_cp_csr;
  FETCH l_new_cp_csr INTO l_new_cp_rec;
  IF l_new_cp_csr%NOTFOUND THEN
    CLOSE l_new_cp_csr;
    IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,G_MODULE_CURRENT||'.adjust_replace_product_bs.EXCEPTION',
        'new cp not found  = ' || p_new_cp_id);
    END IF;
    RAISE G_EXCEPTION_HALT_VALIDATION;

  END IF;
  CLOSE l_new_cp_csr;



  ----update the level elements of old line to new line.

  FOR l_sll_index IN l_strm_lvl_tbl_out.FIRST .. l_strm_lvl_tbl_out.LAST
  LOOP

    IF l_sll_index = l_strm_lvl_tbl_out.LAST THEN
       l_sll_end_date  := l_new_cp_rec.end_date;
    ELSE
       l_sll_end_date  := l_strm_lvl_tbl_out(l_sll_index).end_date;
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.adjust_replace_product_bs.update_lvl_elements',
                         'sll rule id = ' || l_strm_lvl_tbl_out(l_sll_index).id
                         ||', sll end date = '|| l_sll_end_date);
    END IF;

    UPDATE oks_level_elements
    SET rul_id = l_strm_lvl_tbl_out(l_sll_index).id,
        cle_id =  p_new_cp_id
    WHERE TRUNC(date_start) <= TRUNC(l_sll_end_date)
     AND  TRUNC(date_start) >= TRUNC(l_strm_lvl_tbl_out(l_sll_index).start_date)
     AND cle_id = p_old_cp_id;

   IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.adjust_replace_product_bs.update_lvl_amt',
                         'updated level elements = ' || sql%rowcount);
   END IF;


  END LOOP;            ---for loop for sll out tbl

  --update bill type of new line

  UPDATE oks_k_lines_b
  SET billing_schedule_type = l_old_bill_type
  WHERE cle_id = p_new_cp_id;

  IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
   fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.adjust_replace_product_bs.update_bill_type',
                         'update bill schedule type of new line to = ' || l_old_bill_type);
  END IF;



  IF l_old_bill_type IN ('E', 'P') THEN
  ---update lvl amount to 0 of old line sll

   UPDATE oks_stream_levels_b
   SET level_amount = 0
   WHERE cle_id = p_old_cp_id;

   IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.adjust_replace_product_bs.update_oldsll_amt',
                         'update lvl amt of old line to zero = ' || sql%rowcount );
   END IF;

  END IF;               ----chk for bill type E and P


  ------update oks_bill_sub_lines with new cle_id

  UPDATE oks_bill_sub_lines
  SET cle_id = p_new_cp_id
  WHERE cle_id = p_old_cp_id;


  IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.adjust_replace_product_bs.update_bcl',
                         'updated bcl count = ' || sql%rowcount );
  END IF;

END IF;               ----chk for sll count for old line



EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,G_MODULE_CURRENT||'.adjust_replace_product_bs.EXCEPTION',
        'G_EXCEPTION_HALT_VALIDATION');
      END IF;

 WHEN OTHERS THEN
      IF FND_LOG.LEVEL_UNEXPECTED >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_unexpected,G_MODULE_CURRENT||'.adjust_replace_product_bs.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
      END IF;

      OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;

END ADJUST_REPLACE_PRODUCT_BS;

Procedure ADJUST_SPLIT_BILL_SCH(p_old_cp_id      IN    NUMBER,
                                p_new_cp_tbl     IN    OKS_BILL_SCH.SUBLINE_ID_TBL,
                                x_return_status  OUT   NOCOPY VARCHAR2,
                                x_msg_count      OUT   NOCOPY NUMBER,
                                x_msg_data       OUT   NOCOPY VARCHAR2)

IS

CURSOR l_line_csr(p_line_id  NUMBER) IS
  SELECT line.id line_id, TRUNC(line.start_date) start_dt,
         TRUNC(line.end_date) end_dt, line.dnz_chr_id dnz_chr_id, line.lse_id,
         line.cle_id parent_id,line.inv_rule_id inv_rule_id,
         (nvl(line.price_negotiated,0) +  nvl(dtl.ubt_amount,0) +
          nvl(dtl.credit_amount,0) +  nvl(dtl.suppressed_credit,0) ) line_amt,
         dtl.billing_schedule_type billing_schedule_type
  FROM okc_k_lines_b line, oks_k_lines_b dtl
  WHERE line.id= p_line_id
  AND line.id = dtl.cle_id;

CURSOR l_line_BS_csr(p_line_id  NUMBER) IS

   SELECT id,trunc(date_start) date_start,
   amount,trunc(date_end) date_end,object_version_number,
   date_to_interface, date_transaction,date_completed
   FROM oks_level_elements
   WHERE cle_id = p_line_id
   ORDER BY date_start;


CURSOR chk_subline_bs_csr(p_line_id  NUMBER) IS
   SELECT id
   FROM oks_level_elements
   WHERE cle_id = p_line_id;

CURSOR l_amt_csr(p_line_id  NUMBER) IS

   SELECT SUM(NVL(amount,0)) tot_amt
   FROM oks_level_elements
   WHERE cle_id = p_line_id;

Cursor  l_line_amt_csr (p_id in number) IS
Select  line.price_negotiated
from    okc_k_lines_b line
where   line.id = p_id;

l_old_cp_rec           Prod_Det_Type;
l_new_cp_rec           Prod_Det_Type;
l_line_rec             l_line_csr%ROWTYPE;
l_line_BS_rec          l_line_BS_csr%ROWTYPE;
l_sll_in_tbl           StrmLvl_Out_tbl;
l_cp_sll_out_tbl       StrmLvl_Out_tbl;
l_sll_db_tbl           oks_bill_sch.StreamLvl_tbl;
l_top_bs_tbl           oks_bill_level_elements_pvt.letv_tbl_type;
l_new_sll_tbl          oks_bill_sch.StreamLvl_tbl;
l_cp_new_bs_tbl        oks_bill_level_elements_pvt.letv_tbl_type;
l_cp_old_bs_tbl        oks_bill_level_elements_pvt.letv_tbl_type;


l_top_line_rec         Line_Det_Type;
l_cp_rec               Prod_Det_Type;
-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 04-MAY-2005
-------------------------------------------------------------------------
l_price_uom         OKS_K_HEADERS_B.PRICE_UOM%TYPE;
l_period_start      OKS_K_HEADERS_B.PERIOD_START%TYPE;
l_period_type       OKS_K_HEADERS_B.PERIOD_TYPE%TYPE;
l_return_status     VARCHAR2(30);
l_tangible          BOOLEAN;
l_pricing_method    VARCHAR2(30);
-------------------------------------------------------------------------
-- End partial period computation logic
-- Date 04-MAY-2005
-------------------------------------------------------------------------

l_billing_type         oks_k_lines_b.billing_schedule_type%type;
l_inv_rule_id          number;
l_top_line_id          NUMBER;
l_bs_id                NUMBER;
l_index                NUMBER;
l_cp_bs_ind            NUMBER;
l_top_bs_ind           NUMBER;
l_total_amt            NUMBER;
l_init_msg_list        VARCHAR2(2000) := OKC_API.G_FALSE;
L_EXCEPTION_END    Exception;


BEGIN

x_return_status := 'S';


---- return with success if billing schedule doesnt exists for the lines which gets split in IB
Open chk_subline_bs_csr(p_old_cp_id);
Fetch chk_subline_bs_csr Into l_bs_id;
   If chk_subline_bs_csr%Notfound then
      Close chk_subline_bs_csr;
      x_return_status := 'S';
      Raise  L_EXCEPTION_END;
   END IF;

Close chk_subline_bs_csr;

------------find out the old subline details

Open l_Line_Csr(p_old_cp_id);
Fetch l_Line_Csr Into l_Line_Rec;

If l_Line_Csr%Notfound then
  Close l_Line_Csr;
  x_return_status := 'E';
  IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,G_MODULE_CURRENT||'.adjust_split_bill_sch.EXCEPTION',
        'old sub line not found = ' || p_old_cp_id );
   END IF;

End If;
Close l_Line_Csr;

 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------

   OKS_RENEW_UTIL_PUB.Get_Period_Defaults
                (
                 p_hdr_id          => l_Line_Rec.dnz_chr_id,
                 p_org_id          => NULL,
                 x_period_start    => l_period_start,
                 x_period_type     => l_period_type,
                 x_price_uom       => l_price_uom,
                 x_return_status   => x_return_status);

   IF x_return_status <> 'S' THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;
  --Description in detail for the business rules for deriving the period start
  --1)For usage , period start  will always be 'SERVICE'
  --2)For Subscriptions, period start and period type will be NULL
  --  for tangible subscriptions as per CR1.For intangible subscriptions,
  --  if the profile OKS: Intangible Subscription Pricing Method
  --  is set to 'Subscription Based',then period start and period type will be NULL
  --  otherwise it will be 'SERVICE'
  --3) For Extended Warranty from OM, period start will always be 'SERVICE'
  --mchoudha fix for bug#5183011
   IF l_period_start IS NOT NULL AND
      l_period_type IS NOT NULL
   THEN
     IF l_line_rec.lse_id =12 THEN
        l_period_start := 'SERVICE';
     END IF;
     IF l_line_rec.lse_id = 46 THEN
       l_tangible  := OKS_SUBSCRIPTION_PUB.is_subs_tangible (l_line_rec.line_id);
       IF l_tangible THEN
         l_period_start := NULL;
         l_period_type := NULL;
       ELSE
         l_pricing_method :=FND_PROFILE.value('OKS_SUBS_PRICING_METHOD');
         IF nvl(l_pricing_method,'SUBSCRIPTION') <> 'EFFECTIVITY' THEN
           l_period_start := NULL;
           l_period_type := NULL;
         ELSE
           l_period_start := 'SERVICE';
         END IF;   -- l_pricing_method <> 'EFFECTIVITY'
       END IF;     -- IF l_tangible THEN
     END IF;       -- IF l_Line_Csr_Rec.lse_id = 46
   END IF;         -- period start and period type are not NULL
 -------------------------------------------------------------------------
 -- End partial period computation logic
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------

l_old_cp_rec.cp_id          :=  l_line_rec.line_id ;
l_old_cp_rec.cp_start_dt    :=  l_line_rec.start_dt;
l_old_cp_rec.cp_end_dt      :=  l_line_rec.end_dt ;
l_old_cp_rec.cp_amt         :=  l_line_rec.line_amt ;

IF l_period_type is not null AND l_period_start is not NULL THEN
  OPEN l_line_amt_csr(p_old_cp_id);
  FETCH l_line_amt_csr INTO l_old_cp_rec.cp_amt ;
  CLOSE l_line_amt_csr;
END IF;
l_top_line_id  := l_line_rec.parent_id;


IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

   fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.adjust_split_bill_sch.old_cp_dtls',
                      'old subline id = ' || l_old_cp_rec.cp_id
                   || ', start date = ' || l_old_cp_rec.cp_start_dt
                   || ', end date = ' || l_old_cp_rec.cp_end_dt
                   || ', amount = ' || l_old_cp_rec.cp_amt
                   || ', top line id = ' || l_top_line_id  );
END IF;


------------find out the top line details

Open l_Line_Csr(l_top_line_id);
Fetch l_Line_Csr Into l_Line_Rec;

If l_Line_Csr%Notfound then
  Close l_Line_Csr;
  x_return_status := 'E';
  IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,G_MODULE_CURRENT||'.adjust_split_bill_sch.EXCEPTION',
        'top line not found = ' || l_top_line_id );
   END IF;

End If;
Close l_Line_Csr;

l_top_line_rec.chr_id          := l_line_rec.dnz_chr_id ;
l_top_line_rec.dnz_chr_id      := l_line_rec.dnz_chr_id;
l_top_line_rec.id              := l_line_rec.line_id ;
l_top_line_rec.lse_id          := l_line_rec.lse_id;
l_top_line_rec.line_start_dt   := l_line_rec.start_dt;
l_top_line_rec.line_end_dt     := l_line_rec.end_dt ;
l_top_line_rec.line_amt        := l_line_rec.line_amt ;

IF l_period_type is not null AND l_period_start is not NULL THEN
  OPEN l_line_amt_csr(l_top_line_id);
  FETCH l_line_amt_csr INTO l_top_line_rec.line_amt;
  CLOSE l_line_amt_csr;
END IF;

l_inv_rule_id  := l_line_rec.inv_rule_id;
l_billing_type := l_line_rec.billing_schedule_type;


IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

   fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.adjust_split_bill_sch.top_line_dtls',
                      'top line id = ' || l_top_line_rec.id
                   || ', start date = ' || l_top_line_rec.line_start_dt
                   || ', end date = ' || l_top_line_rec.line_start_dt
                   || ', amount = ' || l_top_line_rec.line_amt
                   || ', billing type = ' || l_billing_type
                   || ', inv rule = ' || l_inv_rule_id);
END IF;


----get currency
l_currency_code := Find_Currency_Code(
                                    p_cle_id  => null,
                                    p_chr_id  => l_top_line_rec.dnz_chr_id);

IF l_currency_code IS NULL THEN
      OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'CURRENCY CODE NOT FOUND.');
      x_return_status := 'E';
      IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,G_MODULE_CURRENT||'.adjust_split_bill_sch.EXCEPTION',
        'currency not found for contract id = ' || l_top_line_rec.dnz_chr_id );
      END IF;
      RETURN;
END IF;


IF l_billing_type IN ('T','E') THEN
  l_top_bs_tbl.DELETE;
  l_index  := 1;

  FOR l_line_BS_rec IN l_line_BS_csr(l_top_line_id)
  LOOP
    l_top_bs_tbl(l_index).id                     := l_line_BS_rec.id;
    l_top_bs_tbl(l_index).date_start             := l_line_BS_rec.date_start;
    l_top_bs_tbl(l_index).date_end               := l_line_bs_rec.date_end;
    l_top_bs_tbl(l_index).Amount                 := l_line_BS_rec.amount;
    l_top_bs_tbl(l_index).object_version_number  := l_line_BS_rec.object_version_number;
    l_top_bs_tbl(l_index).date_transaction       := l_line_BS_rec.date_transaction;
    l_top_bs_tbl(l_index).date_to_interface      := l_line_BS_rec.date_to_interface;

    l_total_amt := NVL(l_total_amt,0) + NVL(l_line_BS_rec.amount,0);

    l_index := l_index + 1;
  END LOOP;


  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

    fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.adjust_split_bill_sch.top_bs_tbl',
                    'top line lvl elements count = ' || l_top_bs_tbl.count
                  );
   END IF;

  ------old cp schedule

  l_cp_old_bs_tbl.DELETE;
  l_index  := 1;
  l_total_amt := 0;

  FOR l_line_BS_rec IN l_line_BS_csr(p_old_cp_id )
  LOOP
    l_cp_old_bs_tbl(l_index).id                     := l_line_BS_rec.id;
    l_cp_old_bs_tbl(l_index).date_start             := l_line_BS_rec.date_start;
    l_cp_old_bs_tbl(l_index).Amount                 := l_line_BS_rec.amount;
    l_cp_old_bs_tbl(l_index).date_transaction       := l_line_BS_rec.date_transaction;
    l_cp_old_bs_tbl(l_index).date_to_interface      := l_line_BS_rec.date_to_interface;
    l_cp_old_bs_tbl(l_index).date_completed         := l_line_BS_rec.date_completed;

    l_total_amt := NVL(l_total_amt,0) + NVL(l_line_BS_rec.amount, 0);

    l_index := l_index + 1;
  END LOOP;


  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

    fnd_log.STRING (fnd_log.level_statement,
                   G_MODULE_CURRENT || '.adjust_split_bill_sch.old_cp_bs_tbl',
                    'old cp lvl elements count = ' || l_cp_old_bs_tbl.count
                  );
  END IF;

  --------adjust top line bs amount as (top line bs amt - old cp bs amt)
  l_cp_bs_ind := l_cp_old_bs_tbl.FIRST;
  l_top_bs_ind := l_top_bs_tbl.FIRST;

  WHILE TRUNC(l_cp_old_bs_tbl(l_cp_bs_ind).date_start) > TRUNC(l_top_bs_tbl(l_top_bs_ind).DATE_START) AND
             l_top_bs_ind < l_top_bs_tbl.LAST
  LOOP
    l_top_bs_ind := l_top_bs_tbl.NEXT(l_top_bs_ind);
  END LOOP;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

    fnd_log.STRING (fnd_log.level_statement,
                 G_MODULE_CURRENT || '.Adjust_split_bill_sch.while_top_bs',
                  'after while loop in top bs index = ' || l_top_bs_ind
                || ' , date start = ' || l_top_bs_tbl(l_top_bs_ind ).DATE_START
                );
  END IF;

  ---chk first cp bs.st_dt if between previous and present record

  IF l_top_bs_ind = l_top_bs_tbl.first THEN
    NULL;

  ELSIF TRUNC(l_cp_old_bs_tbl(l_cp_bs_ind).date_start) >= TRUNC(l_top_bs_tbl(l_top_bs_ind - 1).DATE_START)
     AND TRUNC(l_cp_old_bs_tbl(l_cp_bs_ind).date_start) <= TRUNC(l_top_bs_tbl(l_top_bs_ind ).DATE_START) THEN

     l_top_bs_ind := l_top_bs_ind - 1;

  ELSIF l_cp_old_bs_tbl(l_cp_bs_ind).date_start = l_top_bs_tbl(l_top_bs_ind).DATE_START THEN
     null;
  END IF;



  FOR l_cp_bs_ind IN l_cp_old_bs_tbl.FIRST .. l_cp_old_bs_tbl.LAST
  LOOP

   IF l_top_bs_ind  <= l_top_bs_tbl.LAST THEN

     l_top_bs_tbl(l_top_bs_ind).amount := nvl(l_top_bs_tbl(l_top_bs_ind).amount,0) -
                                              nvl(l_cp_old_bs_tbl(l_cp_bs_ind).amount,0);
     l_top_bs_ind  := l_top_bs_ind + 1;

  END IF;
 END LOOP;

ELSE           -----bill type = P

 OPEN l_amt_csr(p_old_cp_id);
 FETCH  l_amt_csr INTO l_total_amt;
 CLOSE l_amt_csr;

END IF;       -----end of  'T' and E

------get sll for old sub line, so that sll amt can be prorated for new subline sll.

Get_SLL_info(p_top_line_id       => l_top_line_id,
              p_line_id          => l_old_cp_rec.cp_id ,
              x_sll_tbl          => l_sll_in_tbl,
              x_sll_db_tbl       => l_sll_db_tbl,
              x_return_status    => x_return_status );

IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
  fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.adjust_split_bill_sch.get_old_cp_sll',
                      'Get_SLL_info(x_return_status = '||x_return_status
                      ||', sll tbl out count = '||l_sll_db_tbl.count||')');
END IF;

IF x_return_status <> 'S' THEN
  RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;


IF l_sll_db_tbl.COUNT = 0 THEN
  RETURN;
END IF;

FOR i IN p_new_cp_tbl.FIRST .. p_new_cp_tbl.LAST
LOOP
   l_new_sll_tbl.DELETE;

   l_new_sll_tbl := l_sll_db_tbl;


   FOR l_index IN l_sll_db_tbl.FIRST .. l_sll_db_tbl.LAST
   LOOP

      l_new_sll_tbl(l_index).cle_id                    := p_new_cp_tbl(i).id;
      l_new_sll_tbl(l_index).id                        := NULL;
   END LOOP;


   ------------find out the new subline details

   Open l_Line_Csr(p_new_cp_tbl(i).id);
   Fetch l_Line_Csr Into l_Line_Rec;

   If l_Line_Csr%Notfound then
     Close l_Line_Csr;
     x_return_status := 'E';
     IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,G_MODULE_CURRENT||'.adjust_split_bill_sch.EXCEPTION',
        'new sub line not found = ' || p_new_cp_tbl(i).id );
      END IF;

   End If;
   Close l_Line_Csr;


   l_new_cp_rec.cp_id          :=  l_line_rec.line_id ;
   l_new_cp_rec.cp_start_dt    :=  l_line_rec.start_dt;
   l_new_cp_rec.cp_end_dt      :=  l_line_rec.end_dt ;
   l_new_cp_rec.cp_amt         :=  l_line_rec.line_amt ;

   IF l_period_type is not null AND l_period_start is not NULL THEN
     OPEN l_line_amt_csr(p_new_cp_tbl(i).id);
     FETCH l_line_amt_csr INTO l_new_cp_rec.cp_amt;
     CLOSE l_line_amt_csr;
   END IF;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

      fnd_log.STRING (fnd_log.level_statement,
                      G_MODULE_CURRENT || '.adjust_split_bill_sch.new_cp_dtls',
                         'new subline id = ' || l_new_cp_rec.cp_id
                      || ', start date = ' || l_new_cp_rec.cp_start_dt
                      || ', end date = ' || l_new_cp_rec.cp_end_dt
                      || ', amount = ' || l_new_cp_rec.cp_amt
                      || ', top line id = ' || l_top_line_id
                     );
   END IF;


   IF l_line_rec.billing_schedule_type IS NULL OR
      l_line_rec.billing_schedule_type <> l_billing_type THEN

     UPDATE OKS_K_LINES_B SET billing_schedule_type = l_billing_type
     WHERE cle_id = l_new_cp_rec.cp_id;


     IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.adjust_split_bill_sch.update_bill_type',
                            'updated new sub line billing type = ' || sql%rowcount);

     END IF;
   END IF;

   IF l_billing_type IN ('E', 'P') THEN
     Prorate_sll_amt(
                     p_old_cp_amt     => l_old_cp_rec.cp_amt,
                     p_new_cp_amt     => l_new_cp_rec.cp_amt,
                     p_total_Amt      => l_total_amt,
                     p_new_sll_tbl    => l_new_sll_tbl,
                     p_old_sll_tbl    => l_sll_db_tbl,
                     x_return_status  =>  x_return_status);

     IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.adjust_split_bill_sch.prorate_sll_amt',
                            'Prorate_sll_amt status = ' || x_return_status
                      );

     END IF;

     IF NVL(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
   END IF;

   l_strm_lvl_tbl_in.DELETE;
   l_index := 0;

   FOR l_index IN l_new_sll_tbl.FIRST .. l_new_sll_tbl.LAST
   LOOP

      l_strm_lvl_tbl_in(l_index).chr_id                   :=  l_new_sll_tbl(l_index).chr_id;
      l_strm_lvl_tbl_in(l_index).dnz_chr_id               :=  l_new_sll_tbl(l_index).dnz_chr_id;
      l_strm_lvl_tbl_in(l_index).sequence_no              :=  l_new_sll_tbl(l_index).sequence_no ;
      l_strm_lvl_tbl_in(l_index).uom_code                 :=  l_new_sll_tbl(l_index).uom_code;
      l_strm_lvl_tbl_in(l_index).start_date               :=  l_new_sll_tbl(l_index).start_date;
      l_strm_lvl_tbl_in(l_index).end_date                 :=  l_new_sll_tbl(l_index).end_date;
      l_strm_lvl_tbl_in(l_index).level_periods            :=  l_new_sll_tbl(l_index).level_periods;
      l_strm_lvl_tbl_in(l_index).uom_per_period           :=  l_new_sll_tbl(l_index).uom_per_period;
      l_strm_lvl_tbl_in(l_index).level_amount             :=  l_new_sll_tbl(l_index).level_amount;
      l_strm_lvl_tbl_in(l_index).invoice_offset_days      :=  l_new_sll_tbl(l_index).invoice_offset_days;
      l_strm_lvl_tbl_in(l_index).interface_offset_days    :=  l_new_sll_tbl(l_index).interface_offset_days;

      l_strm_lvl_tbl_in(l_index).id                        := NULL;
      l_strm_lvl_tbl_in(l_index).cle_id                    := p_new_cp_tbl(i).id;


      l_strm_lvl_tbl_in(l_index).object_version_number     := OKC_API.G_MISS_NUM;
      l_strm_lvl_tbl_in(l_index).created_by                := OKC_API.G_MISS_NUM;
      l_strm_lvl_tbl_in(l_index).creation_date             := SYSDATE;
      l_strm_lvl_tbl_in(l_index).last_updated_by           := OKC_API.G_MISS_NUM;
      l_strm_lvl_tbl_in(l_index).last_update_date          := SYSDATE;


   END LOOP;


   OKS_SLL_PVT.insert_row(
                  p_api_version        => l_api_version,
                  p_init_msg_list      => l_init_msg_list,
                  x_return_status      => x_return_status,
                  x_msg_count          => x_msg_count,
                  x_msg_data           => x_msg_data,
                  p_sllv_tbl           => l_strm_lvl_tbl_in,
                  x_sllv_tbl           => l_strm_lvl_tbl_out);

   IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.adjust_split_bill_sch.insert_sll',
                          'OKS_SLL_PVT.insert_row(x_return_status = '||x_return_status
                       ||', sll tbl out count = '||l_strm_lvl_tbl_out.count||')');
   END IF;

   IF NVL(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

   l_cp_sll_out_tbl.DELETE;

   FOR l_tbl_index IN l_strm_lvl_tbl_out.FIRST .. l_strm_lvl_tbl_out.LAST
   LOOP

       l_cp_sll_out_tbl(l_tbl_index).chr_Id                := l_strm_lvl_tbl_out(l_tbl_index).chr_id;
       l_cp_sll_out_tbl(l_tbl_index).cle_Id                := l_strm_lvl_tbl_out(l_tbl_index).cle_id;
       l_cp_sll_out_tbl(l_tbl_index).dnz_chr_Id            := l_strm_lvl_tbl_out(l_tbl_index).dnz_chr_id;
       l_cp_sll_out_tbl(l_tbl_index).Id                    := l_strm_lvl_tbl_out(l_tbl_index).id;
       l_cp_sll_out_tbl(l_tbl_index).Seq_no                := l_strm_lvl_tbl_out(l_tbl_index).sequence_no;
       l_cp_sll_out_tbl(l_tbl_index).Dt_start              := l_strm_lvl_tbl_out(l_tbl_index).start_date;
       l_cp_sll_out_tbl(l_tbl_index).end_date              := l_strm_lvl_tbl_out(l_tbl_index).end_date;
       l_cp_sll_out_tbl(l_tbl_index).Level_Period          := l_strm_lvl_tbl_out(l_tbl_index).level_periods;
       l_cp_sll_out_tbl(l_tbl_index).uom_Per_Period        := l_strm_lvl_tbl_out(l_tbl_index).uom_per_period;
       l_cp_sll_out_tbl(l_tbl_index).uom                   := l_strm_lvl_tbl_out(l_tbl_index).uom_code;
       l_cp_sll_out_tbl(l_tbl_index).Amount                := l_strm_lvl_tbl_out(l_tbl_index).level_amount;
       l_cp_sll_out_tbl(l_tbl_index).invoice_offset_days   := l_strm_lvl_tbl_out(l_tbl_index).invoice_offset_days;
       l_cp_sll_out_tbl(l_tbl_index).Interface_offset_days := l_strm_lvl_tbl_out(l_tbl_index).interface_offset_days;

   END LOOP;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

      fnd_log.STRING (fnd_log.level_statement,
                      G_MODULE_CURRENT || '.adjust_split_bill_sch.before_new_lvl_ele',
                       'sll count passed to Create_cp_lvl_elements = ' || l_cp_sll_out_tbl.count);
   END IF;

   ------create lvl elements for new cp level ele
 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- Added two new parameters p_period_start and p_period_type
 -------------------------------------------------------------------------
   Create_cp_lvl_elements(
               p_billing_type      =>   l_billing_type,
               p_cp_sll_tbl        =>   l_cp_sll_out_tbl,
               p_Line_Rec          =>   l_top_Line_Rec,
               p_SubLine_rec       =>   l_new_cp_rec,
               p_invoice_rulid     =>   l_inv_rule_id,
               p_top_line_bs       =>   l_top_bs_tbl,
               p_term_dt           =>   null,
               p_period_start      =>   l_period_start,
               p_period_type       =>   l_period_type,
               x_return_status     =>   x_return_status);


   IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.adjust_split_bill_sch.Create_cp_lvl_elements',
                          'Create_cp_lvl_elements(x_return_status = '||x_return_status
                          ||', l_top_bs_tbl count = '||l_top_bs_tbl.count||')');
   END IF;

   IF NVL(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

   ----adjust lvl element amt for old cp and top bs

   Adjust_billed_lvl_element(p_new_cp_id     => l_new_cp_rec.cp_id,
                             p_old_cp_bs_tbl => l_cp_old_bs_tbl,
                             x_new_cp_bs_tbl => l_cp_new_bs_tbl,
                             x_return_status => x_return_status);


   IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.adjust_split_bill_sch.Adjust_billed_lvl_element',
                          'Adjust_billed_lvl_element(x_return_status = '||x_return_status
                          ||', l_cp_old_bs_tbl count = '||l_cp_old_bs_tbl.count||')');
   END IF;

   IF NVL(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;


   ---add new bill records in billing tables

   OKS_BILL_UTIL_PUB.ADJUST_SPLIT_BILL_REC(p_old_cp_id     => l_old_cp_rec.cp_id,
                                        p_new_cp_id        => l_new_cp_rec.cp_id,
                                        p_currency_code    => l_currency_code,
                                        p_rgp_id           => NULL,
                                        p_old_cp_lvl_tbl   => l_cp_old_bs_tbl,
                                        p_new_cp_lvl_tbl   => l_cp_new_bs_tbl,
                                        x_return_status    => x_return_status,
                                        x_msg_count        => x_msg_count,
                                        x_msg_data         => x_msg_data);


   IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.adjust_split_bill_sch.bill_rec',
                       'oks_bill_util_pub.adjust_split_bill_rec(x_return_status = '||x_return_status
                       ||'old line id = ' || l_old_cp_rec.cp_id || ')');
   END IF;

   IF NVL(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS THEN
      ----errorout_aD('ADJUST_SPLIT_BILL_REC ststaus = ' || x_return_status);
      RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

   l_total_amt := NVL(l_total_amt,0) - NVL(l_new_cp_rec.cp_amt,0);

END LOOP;            ---loop for new sub line


---update old sll amount if billtype in E and P

l_cp_sll_out_tbl.DELETE;

FOR l_index in l_sll_db_tbl.FIRST .. l_sll_db_tbl.LAST
LOOP

  IF l_billing_type IN ('E', 'P') THEN

    UPDATE oks_stream_levels_b
    SET level_amount = l_sll_db_tbl(l_index).level_amount
    WHERE id = l_sll_db_tbl(l_index).id;


    IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.adjust_split_bill_sch.old_sll_amt_update',
                       'old sll amount update = '|| l_sll_db_tbl(l_index).level_amount
                       ||', sll id = '|| l_sll_db_tbl(l_index).id  );
    END IF;
  END IF;


  l_cp_sll_out_tbl(l_index).Id                    := l_sll_db_tbl(l_index).id;
  l_cp_sll_out_tbl(l_index).chr_Id                := NULL;
  l_cp_sll_out_tbl(l_index).cle_Id                := l_sll_db_tbl(l_index).cle_id;
  l_cp_sll_out_tbl(l_index).dnz_chr_Id            := l_sll_db_tbl(l_index).dnz_chr_Id;
  l_cp_sll_out_tbl(l_index).Seq_no                := l_sll_db_tbl(l_index).sequence_no;
  l_cp_sll_out_tbl(l_index).Dt_start              := l_sll_db_tbl(l_index).Start_Date;
  l_cp_sll_out_tbl(l_index).end_date              := l_sll_db_tbl(l_index).end_Date;
  l_cp_sll_out_tbl(l_index).Level_Period          := l_sll_db_tbl(l_index).level_periods;
  l_cp_sll_out_tbl(l_index).uom_Per_Period        := l_sll_db_tbl(l_index).uom_per_period;
  l_cp_sll_out_tbl(l_index).uom                   := l_sll_db_tbl(l_index).uom_code;
  l_cp_sll_out_tbl(l_index).Amount                := l_sll_db_tbl(l_index).level_amount;
  l_cp_sll_out_tbl(l_index).invoice_offset_days   := l_sll_db_tbl(l_index).invoice_offset_days;
  l_cp_sll_out_tbl(l_index).Interface_offset_days := l_sll_db_tbl(l_index).interface_offset_days;

END LOOP;


----refresh billing sch for old cp.
 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- Added two new parameters p_period_start and p_period_type
 -------------------------------------------------------------------------
Create_cp_lvl_elements(
               p_billing_type      =>   l_billing_type,
               p_cp_sll_tbl        =>   l_cp_sll_out_tbl,
               p_Line_Rec          =>   l_top_Line_Rec,
               p_SubLine_rec       =>   l_old_cp_rec,
               p_invoice_rulid     =>   l_inv_rule_id,
               p_top_line_bs       =>   l_top_bs_tbl,
               p_term_dt           =>   NULL,
               p_period_start      =>   l_period_start,   --mchoudha fix for bug#4998167 added l_period_start
               p_period_type       =>   l_period_type,    --mchoudha fix for bug#4998167 added l_period_type
               x_return_status     =>   x_return_status);

IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
   fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.adjust_split_bill_sch.refresh_old_cp_lvl',
                       'Create_cp_lvl_elements(x_return_status = '||x_return_status
                       ||', l_top_bs_tbl count = '||l_top_bs_tbl.count||')');
END IF;

IF NVL(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS THEN
   RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;


IF l_top_bs_tbl.COUNT > 0 THEN

 FOR l_index IN l_top_bs_tbl.FIRST .. l_top_bs_tbl.LAST
 LOOP

  UPDATE OKS_LEVEL_ELEMENTS
     SET amount = l_top_bs_tbl(l_index).amount
     WHERE id = l_top_bs_tbl(l_index).id;

     IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.Adjust_split_bill_sch.update_top_lvl_amt',
                         'updated level elemnets of top line= ' || sql%rowcount
                       || ' , id = ' || l_top_bs_tbl(l_index).id
                       || ' , amt = ' || l_top_bs_tbl(l_index).amount );
     END IF;
  END LOOP;
END IF;


EXCEPTION
 WHEN L_EXCEPTION_END THEN
      x_return_status := 'S';
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := 'E';
      IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,G_MODULE_CURRENT||'.adjust_split_bill_sch.EXCEPTION',
        'G_EXCEPTION_HALT_VALIDATION');
      END IF;

 WHEN OTHERS THEN
      IF FND_LOG.LEVEL_UNEXPECTED >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_unexpected,G_MODULE_CURRENT||'.adjust_split_bill_sch.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
      END IF;

      OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;
END adjust_split_bill_sch;



Procedure Prorate_sll_amt(
                  p_old_cp_amt     IN NUMBER,
                  p_new_cp_amt     IN NUMBER,
                  p_total_amt      IN NUMBER,
                  p_new_sll_tbl    IN OUT NOCOPY oks_bill_sch.StreamLvl_tbl,
                  p_old_sll_tbl    IN OUT NOCOPY oks_bill_sch.StreamLvl_tbl,
                  x_return_status  OUT NOCOPY  VARCHAR2)

IS
l_tot_amt    NUMBER;
l_amt        NUMBER;

BEGIN

x_return_status := OKC_API.G_RET_STS_SUCCESS;

IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

      fnd_log.STRING (fnd_log.level_statement,
                      G_MODULE_CURRENT || '.Prorate_sll_amt.passed_val',
                       'p_total_amt = ' || p_total_amt
                     ||', p_new_cp_amt = ' || p_new_cp_amt);
END IF;

l_tot_amt := nvl(p_total_amt,0);

FOR l_index IN p_old_sll_tbl.FIRST .. p_old_sll_tbl.LAST
LOOP

  IF l_tot_amt = 0 THEN
    l_amt := 0;
  ELSE

    l_Amt := (NVL(p_old_sll_tbl(l_index).level_amount,0)/l_tot_amt) * nvl(p_new_cp_amt,0);
  END IF;

  p_new_sll_tbl(l_index).level_amount := OKS_EXTWAR_UTIL_PVT.round_currency_amt
                                                   (l_Amt, l_currency_code);


  p_old_sll_tbl(l_index).level_amount := nvl(p_old_sll_tbl(l_index).level_amount,0) -
                                               p_new_sll_tbl(l_index).level_amount;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Prorate_sll_amt.lvl_amt',
                         'sll seq  = ' || p_old_sll_tbl(l_index).sequence_no
                         ||', old sll amt = '|| p_old_sll_tbl(l_index).level_amount
                         ||', new sll amt = '|| p_new_sll_tbl(l_index).level_amount
                         ||', total amt = '|| l_tot_amt
                    );
  END IF;

END LOOP;

EXCEPTION

 WHEN OTHERS THEN
      IF FND_LOG.LEVEL_UNEXPECTED >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_unexpected,G_MODULE_CURRENT||'.Prorate_sll_amt.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
      END IF;

      OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;

END Prorate_sll_amt;


PROCEDURE Adjust_billed_lvl_element(p_new_cp_id     IN NUMBER,
                                    p_old_cp_bs_tbl IN OUT NOCOPY oks_bill_level_elements_pvt.letv_tbl_type,
                                    x_new_cp_bs_tbl OUT NOCOPY oks_bill_level_elements_pvt.letv_tbl_type,
                                    x_return_status OUT NOCOPY VARCHAR2)
IS


CURSOR l_line_BS_csr(p_line_id  NUMBER) IS

   SELECT id,trunc(date_start) date_start,
   amount,trunc(date_end) date_end,date_completed
   FROM oks_level_elements
   WHERE cle_id = p_line_id
   ORDER BY date_start;

l_line_BS_rec      l_line_BS_csr%ROWTYPE;
l_index            NUMBER;

BEGIN

x_return_status  := OKC_API.G_RET_STS_SUCCESS;

l_index  := 1;
x_new_cp_bs_tbl.DELETE;

FOR l_line_BS_rec IN l_line_BS_csr(p_new_cp_id)
LOOP
  x_new_cp_bs_tbl(l_index).id                     := l_line_BS_rec.id;
  x_new_cp_bs_tbl(l_index).date_start             := l_line_BS_rec.date_start;
  x_new_cp_bs_tbl(l_index).date_end               := l_line_bs_rec.date_end;
  x_new_cp_bs_tbl(l_index).Amount                 := l_line_bs_rec.amount;
  x_new_cp_bs_tbl(l_index).date_completed         := l_line_BS_rec.date_completed;

  l_index := l_index + 1;
END LOOP;


IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

  fnd_log.STRING (fnd_log.level_statement,
                 G_MODULE_CURRENT || '.Adjust_billed_lvl_element.new_bs_tbl',
                 'new sub line lvl elements count = ' || x_new_cp_bs_tbl.count);
END IF;


-------adjust the old cp lvl element amt for billed records
-----as old cp lvl amount = old amt - new cp lvl amt.


FOR l_index IN p_old_cp_bs_tbl.FIRST .. p_old_cp_bs_tbl.LAST
LOOP

  IF TRUNC(p_old_cp_bs_tbl(l_index).date_start) = TRUNC(x_new_cp_bs_tbl(l_index).date_start) AND
     p_old_cp_bs_tbl(l_index).date_completed IS NOT NULL THEN

     p_old_cp_bs_tbl(l_index).amount  := p_old_cp_bs_tbl(l_index).amount - x_new_cp_bs_tbl(l_index).amount;
     x_new_cp_bs_tbl(l_index).date_completed  := sysdate;

     UPDATE OKS_LEVEL_ELEMENTS
     SET amount = p_old_cp_bs_tbl(l_index).amount
     WHERE id = p_old_cp_bs_tbl(l_index).id;

     IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.Adjust_billed_lvl_element.update_old_lvl_amt',
                         'updated level elemnets = ' || sql%rowcount
                       || ' , id = ' || p_old_cp_bs_tbl(l_index).id
                       || ' , amt = ' || p_old_cp_bs_tbl(l_index).amount );

     END IF;

  END IF;
END LOOP;

EXCEPTION

 WHEN OTHERS THEN
      IF FND_LOG.LEVEL_UNEXPECTED >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_unexpected,G_MODULE_CURRENT||'.Adjust_billed_lvl_element.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
      END IF;

      OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;

END Adjust_billed_lvl_element;


--[llc] Sts_change_subline_lvl_rule

/* This procedure updates the amount on the top line when the status of sub-line is
   changed from 'Entered' to 'Cancelled' or 'Cancelled' to 'Entered'.
*/

        PROCEDURE Sts_change_subline_lvl_rule(
                                               p_cle_id            IN  NUMBER,
                                               p_from_ste_code     IN VARCHAR2,
                                               p_to_ste_code       IN VARCHAR2,
                                                x_return_status    OUT NOCOPY VARCHAR2,
                                                x_msg_count        OUT NOCOPY  NUMBER,
                                                x_msg_data         OUT NOCOPY VARCHAR2)
        IS

        -- to get the top line details

        CURSOR l_line_BS_csr(l_top_line_id Number) IS
                 SELECT id, trunc(date_start) date_start,
                 amount, TRUNC(DATE_end) date_end, object_version_number
                 FROM oks_level_elements
                 WHERE cle_id = l_top_line_id
                 ORDER BY date_start;

        -- to get the sub-line details.
        CURSOR l_cp_BS_csr IS
                 SELECT id, trunc(date_start) date_start,
                 amount
                 FROM oks_level_elements
                 WHERE cle_id = p_cle_id
                 ORDER BY date_start;

        -- to get the billing schedule of the sub-line on which the status changes action is taken.

        CURSOR l_bill_type_csr IS
               SELECT nvl(billing_schedule_type,'T') billing_schedule_type
               FROM oks_k_lines_b
               WHERE cle_id = p_cle_id;


         CURSOR is_top_line_csr (p_cle_id number) IS
         select cle_id
         from okc_k_lines_b
         where id=p_cle_id;


-- 18-JAN-2006-maanand-Fixed Enhancement#4930700
-- CURSOR to check if price_negotiated of topline equals to total SLL amount for this topline
-- on billing form (table- oks_level_elements, column- amount)

        CURSOR csr_CheckBillSllAmount_PN (p_top_line_id number) IS
        SELECT  1
        FROM    okc_k_lines_b
        WHERE   id = p_top_line_id
        AND     price_negotiated = (select sum(amount) from oks_level_elements ole1
                                   where ole1.parent_cle_id = p_top_line_id
                                   and ole1.object_version_number = ( select max(object_version_number)
                                                                      from oks_level_elements ole2
                                                                      where ole2.parent_cle_id = p_top_line_id
                                                                    )
                                    );


        l_line_BS_rec        l_line_BS_csr%ROWTYPE;
        l_cp_BS_rec          l_cp_BS_csr%ROWTYPE;
        l_bill_type_rec      l_bill_type_csr%ROWTYPE;


        l_top_bs_tbl         oks_bill_level_elements_pvt.letv_tbl_type;
        l_cp_bs_tbl          oks_bill_level_elements_pvt.letv_tbl_type;
        x_letv_tbl           oks_bill_level_elements_pvt.letv_tbl_type;


        i                    NUMBER := 0;
        l_index              NUMBER := 0;
        l_cp_bs_ind          NUMBER;
        l_top_bs_ind         NUMBER;

        l_api_Version              Number      := 1;
        l_init_msg_list            VARCHAR2(2000) := OKC_API.G_FALSE;
        l_msg_list                 VARCHAR2(1) DEFAULT OKC_API.G_FALSE;
        l_msg_count                Number;
        l_msg_data                 Varchar2(2000) := NULL;

        l_top_line_id           Number;

        l_dummy                 NUMBER;


        BEGIN

        x_return_status := 'S';

        ---get bill type details

        Open is_top_line_csr(p_cle_id);
        Fetch is_top_line_csr Into l_top_line_id;
        Close is_top_line_csr;

        -- 18-JAN-2006-maanand-Fixed Enhancement#4930700

        IF (l_top_line_id is null) THEN

            IF ((p_from_ste_code = 'CANCELLED' ) AND (p_to_ste_code = 'ENTERED')) then

                 Open csr_CheckBillSllAmount_PN(p_cle_id);
                 Fetch csr_CheckBillSllAmount_PN into l_dummy;
                 Close csr_CheckBillSllAmount_PN;

                 -- If status of service line is changed from CANCELED TO ENTERED status, then
                 -- refresh the billing schedule. This will ensure that billing schedule
                 -- amount matches with that of the price_negotiated amount of the service line

                 IF (nvl(l_dummy, 2) <> 1 ) THEN

                        OKS_BILL_SCH.Cascade_Dates_SLL
                        (
                         p_top_line_id         => p_cle_id,
                         x_return_status       => x_return_status,
                         x_msg_count           => l_msg_count,
                         x_msg_data            => l_msg_data );

                 END IF;

            END IF; -- p_from_ste_code = 'CANCELLED'

          return;

         END IF; -- l_top_line_id is null


        Open l_bill_type_Csr;
        Fetch l_bill_type_Csr Into l_bill_type_Rec;

        If l_bill_type_csr%Notfound then
            Close l_bill_type_Csr;
            x_return_status := 'E';
             OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'BILLING SCHEDULE TYPE NOT FOUND.');
            RAISE G_EXCEPTION_HALT_VALIDATION;
        End If;

        Close l_bill_type_Csr;

        IF l_bill_type_rec.billing_schedule_type = 'T' then

          l_index  := 0;
          l_top_bs_tbl.DELETE;

          FOR l_line_BS_rec IN l_line_BS_csr(l_top_line_id)
          LOOP
           l_top_bs_tbl(l_index).id                     := l_line_BS_rec.id;
           l_top_bs_tbl(l_index).date_start             := l_line_BS_rec.date_start;
           l_top_bs_tbl(l_index).Amount                 := l_line_BS_rec.amount;
           l_top_bs_tbl(l_index).date_end               := l_line_BS_rec.date_end;
           l_top_bs_tbl(l_index).object_version_number  := l_line_BS_rec.object_version_number;

           l_index := l_index + 1;
          END LOOP;

        -- check there is any billing schedule exists for this sub-line
           If l_index = 0 then
                Return;
           End if;

          l_index  := 0;
          l_cp_bs_tbl.DELETE;

          FOR l_cp_BS_rec IN l_cp_BS_csr
          LOOP
            l_cp_bs_tbl(l_index).id              := l_cp_BS_rec.id;
            l_cp_bs_tbl(l_index).date_start      := l_cp_BS_rec.date_start;
            l_cp_bs_tbl(l_index).Amount          := l_cp_BS_rec.amount;

            l_index := l_index + 1;
          END LOOP;

          IF l_cp_bs_tbl.COUNT > 0 THEN


             l_cp_bs_ind  := l_cp_bs_tbl.FIRST;
             l_top_bs_ind := l_top_bs_tbl.FIRST;

             WHILE l_cp_bs_tbl(l_cp_bs_ind).date_start > l_top_bs_tbl(l_top_bs_ind).DATE_START
                     AND l_top_bs_ind < l_top_bs_tbl.LAST
             LOOP
               l_top_bs_ind := l_top_bs_tbl.NEXT(l_top_bs_ind);
             END LOOP;


           IF l_top_bs_ind = l_top_bs_tbl.first THEN
              NULL;

           ELSIF  l_top_bs_ind <= l_top_bs_tbl.LAST THEN

             l_top_bs_ind := l_top_bs_ind - 1;

             IF TRUNC(l_cp_bs_tbl(l_cp_bs_ind).date_start) >= l_top_bs_tbl(l_top_bs_ind  ).DATE_START
              AND TRUNC(l_cp_bs_tbl(l_cp_bs_ind).date_start) <= l_top_bs_tbl(l_top_bs_ind ).DATE_end THEN

                  NULL;
             ELSE
                 l_top_bs_ind := l_top_bs_ind + 1;
             END IF;

            elsif TRUNC(l_cp_bs_tbl(l_cp_bs_ind).date_start) = TRUNC(l_top_bs_tbl(l_top_bs_ind).DATE_START) THEN
               NULL;

           end if;


           FOR l_cp_bs_ind IN l_cp_bs_tbl.FIRST .. l_cp_bs_tbl.LAST
           LOOP
              IF ((p_from_ste_code = 'ENTERED' ) AND (p_to_ste_code = 'CANCELLED')) then
                l_top_bs_tbl(l_top_bs_ind).amount := nvl(l_top_bs_tbl(l_top_bs_ind).amount,0) - nvl(l_cp_bs_tbl(l_cp_bs_ind).amount,0);
             ElsIf ((p_from_ste_code = 'CANCELLED' ) AND (p_to_ste_code = 'ENTERED')) then
                l_top_bs_tbl(l_top_bs_ind).amount := nvl(l_top_bs_tbl(l_top_bs_ind).amount,0) + nvl(l_cp_bs_tbl(l_cp_bs_ind).amount,0);
              End if;
                l_top_bs_ind  := l_top_bs_ind + 1;
           END LOOP;

           OKS_BILL_LEVEL_ELEMENTS_PVT.update_row(
                       p_api_version                  => l_api_version,
                       p_init_msg_list                => l_init_msg_list,
                       x_return_status                => x_return_status,
                       x_msg_count                    => l_msg_count,
                       x_msg_data                     => l_msg_data,
                       p_letv_tbl                     => l_top_bs_tbl,
                       x_letv_tbl                     => l_lvl_ele_tbl_out);

             IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
             END IF;

          END IF;          ---l_cp_bs_tbl.COUNT > 0


        END IF;      ---l_bill_type = 'T'

END Sts_change_subline_lvl_rule;




END OKS_BILL_SCH;

/
