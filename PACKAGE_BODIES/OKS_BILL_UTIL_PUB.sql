--------------------------------------------------------
--  DDL for Package Body OKS_BILL_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_BILL_UTIL_PUB" as
/* $Header: OKSBUTLB.pls 120.14 2006/10/06 09:40:07 mchoudha noship $ */

g_chr_id NUMBER;

Function CHECK_RULE_Group_EXISTS
(
                p_chr_id IN NUMBER,
                p_cle_id IN NUMBER
) Return NUMBER
Is
            v_id NUMBER;
Begin
        If (p_chr_id IS NOT NULL) Then
                SELECT ID INTO V_ID FROM OKC_RULE_GROUPS_V WHERE Dnz_CHR_ID = p_chr_id And cle_id Is Null;
                If V_ID IS NULL Then
                        return(NULL);
                Else
                        return(V_ID);
                End If;
        End If;

        If (p_cle_id IS NOT NULL) Then
                SELECT ID INTO V_ID FROM OKC_RULE_GROUPS_V WHERE CLE_ID = p_cle_id;
                If V_ID IS NULL Then
                        return(NULL);
                Else
                        return(V_ID);
                End If;
        End If;

        Exception
        When OTHERS Then
                RETURN(NULL);

End CHECK_RULE_Group_EXISTS;




Function Check_Rule_Exists
(
        p_rgp_id        IN NUMBER,
        p_rule_type IN VARCHAR2
)       Return NUMBER
Is
        v_id NUMBER;
Begin
        If p_rgp_id is null Then
                Return(null);
        Else
                Select ID Into V_ID From OKC_RULES_V
                Where  rgp_id = p_rgp_id
                And      Rule_information_category = p_rule_type;

                If v_id Is NULL Then
                        return(null);
                Else
                        return(V_ID);
                End If;
        End if;


Exception
  WHEN No_Data_Found Then
                     Return (null);

End Check_Rule_Exists;

-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 04-MAY-2005
-- Description:
--This new function will determine number of periods of SLL given
--the start date, end date,uom_per_period and uom of the SLL.
-------------------------------------------------------------------------

FUNCTION Get_Periods    (p_start_date    IN DATE,
                         p_end_date      IN DATE,
                         p_uom_code      IN VARCHAR2,
                         p_period_start  IN VARCHAR2
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
    --AND TL.uom_class = 'Time'       commented for bug#5585356
    AND okc.active_flag = 'Y'
   AND TL.LANGUAGE = USERENV('LANG');


cr_validate_uom  cs_validate_uom%ROWTYPE;
l_level_periods     NUMBER;
l_next_start_date   DATE;
l_temp_periods      NUMBER;
l_uom_quantity      NUMBER;
l_tce_code          VARCHAR2(30);
l_return_status     VARCHAR2(20);

INVALID_PERIOD_START_EXCEPTION EXCEPTION;
INVALID_DATE_EXCEPTION         EXCEPTION;
INVALID_UOM_EXCEPTION          EXCEPTION;
BEGIN
    --Begin Validation
    --1) Validate dates
    IF (p_start_date IS NULL)OR(p_end_date IS NULL)OR(p_start_date > p_end_date)
    THEN
      RAISE INVALID_DATE_EXCEPTION;
    END IF;

    --2)Validate uom
    OPEN cs_validate_uom(p_uom_code);
    FETCH cs_validate_uom INTO cr_validate_uom;
    IF cs_validate_uom%NOTFOUND
    THEN
      RAISE INVALID_UOM_EXCEPTION;
    END IF;
    CLOSE cs_validate_uom;

    --3)Validate period start
    IF upper(p_period_start) NOT IN ('CALENDAR','SERVICE')
    THEN
      RAISE INVALID_PERIOD_START_EXCEPTION;
    END IF;

    --End Validation
    l_level_periods := 0;

    IF p_uom_code ='DAY' THEN
      Return(TRUNC(p_end_date)-TRUNC(p_start_date)+1);
    END IF;

    IF (p_period_start = 'SERVICE') THEN
      l_next_start_date := TRUNC(p_start_date);
    ELSE
       --if the start date is not the start of CALENDAR
       IF(TRUNC(p_start_date,'MM')<> TRUNC(p_start_date))
       THEN
         l_next_start_date := last_day(TRUNC(p_start_date))+1;
         l_level_periods   := l_level_periods + 1;
       ELSE
         l_next_start_date := TRUNC(p_start_date);
       END IF;
    END IF;

    OKS_BILL_UTIL_PUB.Get_Seeded_Timeunit
                    (p_timeunit      => p_uom_code,
                     x_return_status => l_return_status,
                     x_quantity      => l_uom_quantity ,
                     x_timeunit      => l_tce_code);

    IF (l_tce_code = 'MONTH') THEN
      l_temp_periods := MONTHS_BETWEEN(p_end_date+1,l_next_start_date);

      l_level_periods:=ceil(l_temp_periods/l_uom_quantity)+l_level_periods;
    END IF;

    IF (l_tce_code = 'YEAR') THEN
      l_temp_periods := MONTHS_BETWEEN(p_end_date+1,l_next_start_date)/12;
      l_level_periods:=ceil(l_temp_periods/l_uom_quantity)+l_level_periods;
    END IF;

    IF l_tce_code ='DAY' THEN
      --14-NOV-2005 mchoudha fix for bug#4692372
      l_level_periods := ceil(((TRUNC(p_end_date)-TRUNC(p_start_date)+1))
                                            /l_uom_quantity);
    END IF;

RETURN l_level_periods;

EXCEPTION
WHEN INVALID_PERIOD_START_EXCEPTION THEN
      OKC_API.set_message('OKS','OKS_INVD_PERIOD_START_CODE');  --?? need to seed this message
      return NULL;
WHEN INVALID_UOM_EXCEPTION THEN
      OKC_API.SET_MESSAGE(p_app_name    => 'OKS',
                         p_msg_name     => 'OKS_INVD_UOM_CODE',
                         p_token1       => 'OKS_API_NAME',
                         p_token1_value => 'oks_bill_util_pub.Get_Periods',
                         p_token2       => 'UOM_CODE',
                         p_token2_value => p_uom_code);
      IF cs_validate_uom%ISOPEN THEN
        CLOSE cs_validate_uom;
      END IF;
      return NULL;
WHEN INVALID_DATE_EXCEPTION THEN
      OKC_API.set_message('OKS','OKS_INVALID_START_END_DATES'); --?? need to seed this message
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
END Get_Periods;

-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 04-MAY-2005
-- Description:
--This new function will determine the end date of the
--SLL in case of "CALENDAR" period start.
-------------------------------------------------------------------------
FUNCTION Get_Enddate_Cal(p_start_date    IN DATE,
                         p_uom_code      IN VARCHAR2,
                         p_duration      IN NUMBER,
                         p_level_periods IN NUMBER
                         )
RETURN DATE
IS

CURSOR cs_validate_uom(p_uom_code IN VARCHAR2)
 is
  SELECT 1
   FROM MTL_UNITS_OF_MEASURE_TL TL, okc_time_code_units_v okc
  WHERE TL.uom_code    = okc.uom_code
    AND TL.uom_code    = p_uom_code
   -- AND TL.uom_class = 'Time'  commednted for bug#5585356
    AND okc.active_flag = 'Y'
   AND TL.LANGUAGE = USERENV('LANG') ;

cr_validate_uom  cs_validate_uom%ROWTYPE;
l_level_periods     NUMBER;
l_next_start_date   DATE;
l_end_date          DATE;
l_duration          NUMBER;

INVALID_PERIOD_EXCEPTION       EXCEPTION;
INVALID_DATE_EXCEPTION         EXCEPTION;
INVALID_UOM_EXCEPTION          EXCEPTION;

BEGIN
    --Begin Validation
    --1) Validate start date
    IF (p_start_date IS NULL)
    THEN
      RAISE INVALID_DATE_EXCEPTION;
    END IF;

    --2)Validate uom
    OPEN cs_validate_uom(p_uom_code);
    FETCH cs_validate_uom INTO cr_validate_uom;
    IF cs_validate_uom%NOTFOUND
    THEN
      RAISE INVALID_UOM_EXCEPTION;
    END IF;
    CLOSE cs_validate_uom;

    --3)Validate period duration
    IF nvl(p_level_periods,0) = 0 OR nvl(p_duration,0) = 0
    THEN
      RAISE INVALID_PERIOD_EXCEPTION;
    END IF;

    --End Validation
    l_level_periods := p_level_periods;
    l_next_start_date := TRUNC(p_start_date);
    l_duration:=p_duration;

    --if the start date is not the start of CALENDAR

    IF TRUNC(p_start_date,'MM')<>TRUNC(p_start_date) THEN
        l_next_start_date := LAST_DAY(TRUNC(p_start_date))+1;
        l_level_periods := p_level_periods - 1;
    END IF;

    IF l_level_periods > 0 THEN
      l_end_date := OKC_TIME_UTIL_PUB.GET_ENDDATE
                        (p_start_date => l_next_start_date,
                         p_timeunit   => p_uom_code,
                         p_duration   => l_level_periods*l_duration
                         );
    ELSE
      l_end_date := l_next_start_date - 1;
    END IF;
    RETURN TRUNC(l_end_date);

EXCEPTION
WHEN INVALID_PERIOD_EXCEPTION THEN
      OKC_API.set_message('OKS','OKS_INVD_PERIOD');  --?? need to seed this message
      return NULL;
WHEN INVALID_UOM_EXCEPTION THEN
      OKC_API.SET_MESSAGE(p_app_name    => 'OKS',
                         p_msg_name     => 'OKS_INVD_UOM_CODE',
                         p_token1       => 'OKS_API_NAME',
                         p_token1_value => 'oks_bill_util_pub.Get_Enddate_Cal',
                         p_token2       => 'UOM_CODE',
                         p_token2_value => p_uom_code);
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
END Get_Enddate_Cal;
-------------------------------------------------------------------------
-- End partial period computation logic
-- Date 04-MAY-2005
-------------------------------------------------------------------------


/*** This procedure is to get the seeded time unit and quantity, when the UOM Code is given as input ***/


PROCEDURE Get_sll_amount( p_api_version    IN  NUMBER,
                          p_total_amount         IN  NUMBER,
                          p_init_msg_list        IN  VARCHAR2  DEFAULT OKC_API.G_FALSE,
                          x_return_status        OUT NOCOPY VARCHAR2 ,
                          x_msg_count            OUT NOCOPY NUMBER   ,
                          x_msg_data             OUT NOCOPY VARCHAR2,
                          p_currency_code        IN  VARCHAR2,
                          p_sll_prorated_tab     IN  OUT NOCOPY sll_prorated_tab_type
                         )
IS
l_sll_num               NUMBER;
i                       NUMBER;
j                       NUMBER;
l_sll_remain_amount  NUMBER;
l_currency_code   VARCHAR2(15);
l_round_sll_amount      NUMBER;

l_tuom_code     VARCHAR2(40);
l_tce_code      VARCHAR2(10);
l_uom_quantity         NUMBER;
l_curr_sll_start_date  DATE;
l_curr_sll_end_date    DATE;

l_next_sll_start_date  DATE;
l_next_sll_end_date    DATE;
l_sll_amount            NUMBER;

l_curr_frequency        NUMBER;
l_next_frequency        NUMBER;
l_tot_frequency         NUMBER;

l_return_status         VARCHAR2(1);

BEGIN
        l_sll_num := p_sll_prorated_tab.count;
      l_sll_remain_amount := p_total_amount;

        For i in 1 .. l_sll_num Loop
            l_tuom_code := p_sll_prorated_tab(i).sll_tuom ;
            oks_bill_util_pub.get_seeded_timeunit(p_timeunit     => l_tuom_code ,
                                                                  x_return_status => l_return_status,
                                                                x_quantity      => l_uom_quantity,
                                                                  x_timeunit      => l_tce_code
                                                                  );

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
                  l_tot_frequency := l_tot_frequency + l_curr_frequency + l_next_frequency;

                l_sll_amount := ( l_sll_remain_amount / nvl(l_tot_frequency,1)) * nvl(l_curr_frequency,0) ;
                    l_round_sll_amount := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_sll_amount, l_currency_code);
                    l_round_sll_amount := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_round_sll_amount, l_currency_code);

                l_sll_remain_amount := l_sll_remain_amount - l_round_sll_amount;

                           -- l_sll_remain_amount := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_sll_remain_amount, l_currency_code);

                p_sll_prorated_tab(i).sll_amount := l_round_sll_amount;
                l_curr_frequency := 0;
        END LOOP;



END;




PROCEDURE get_seeded_timeunit (  p_timeunit in varchar2,
                                 x_return_status out NOCOPY varchar2,
                                 x_quantity out NOCOPY number,
                                 x_timeunit out NOCOPY varchar2) IS

CURSOR time_code_unit_csr (p_uom_code IN varchar2) IS
SELECT tce_code, quantity
FROM   okc_time_code_units_b
WHERE uom_code = p_uom_code
AND active_flag = 'Y';

l_new_qty                  NUMBER;
time_code_unit_rec         time_code_unit_csr%ROWTYPE;
Item_not_found_error       EXCEPTION;

BEGIN
x_return_status         := OKC_API.G_RET_STS_SUCCESS;
OPEN time_code_unit_csr(p_timeunit);
FETCH time_code_unit_csr into time_code_unit_rec;

IF time_code_unit_csr%NOTFOUND THEN
   --    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'uom_code');
   CLOSE time_code_unit_csr;
   RAISE item_not_found_error;
 END IF;

 CLOSE time_code_unit_csr;

 IF time_code_unit_rec.tce_code = 'HOUR' THEN
    l_new_qty := nvl(time_code_unit_rec.quantity,0) / 24 ;   ---convert it in day
    IF l_new_qty = ceil(l_new_qty) THEN
       x_timeunit := 'DAY';
       x_quantity  := l_new_qty;
   ELSE
     RAISE item_not_found_error;
   END IF;
ELSE                          ----not hour

   x_timeunit := time_code_unit_rec.tce_code;
   x_quantity  := time_code_unit_rec.quantity;
END IF;

EXCEPTION

      WHEN item_not_found_error THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
   /*      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => 'uom_code',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);*/
      -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END get_seeded_timeunit;

/**** This procedure is to get prorated amount ****/

Procedure Get_prorate_amount
 ( p_api_version                  IN NUMBER,
   p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
   x_return_status                OUT NOCOPY VARCHAR2,
   x_msg_count                    OUT NOCOPY NUMBER,
   x_msg_data                     OUT NOCOPY VARCHAR2,
   p_invoicing_rule_id            IN  Number,
   p_bill_sch_detail_rec          IN  bill_det_inp_rec,
   x_bill_sch_detail_rec          OUT NOCOPY bill_sch_rec
 )
IS

/** Local input variables ***/
l_tuom_code              Varchar2(10);
l_tce_code                       Varchar2(10);
l_uom_quantity           Number;
l_total_amount           Number;
l_start_date             DATE;
l_end_date                       DATE;
l_cycle_start_date       DATE;
l_action_offset          Number;
l_interface_offset       Number;
l_tuom_per_period                Number;
l_return_status                  Varchar2(1) := 'S';

/*** Local output variables ***/
l_bill_amount            Number;
l_next_billing_date      DATE;
l_date_transaction       DATE;
l_date_to_interface      DATE;

/** local programming variables **/
l_frequency                     Number;
l_frequency_day         Number;
l_frequency_mth         Number;
l_frequency_yr          Number;
l_frequency_qtr         Number;
l_freq_descrep           Number;

BEGIN
/** Get next billing amount ***/
x_return_status := l_return_status;

        l_tuom_code        := p_bill_sch_detail_rec.tuom;
        l_tuom_per_period  := p_bill_sch_detail_rec.tuom_per_period;
        l_cycle_start_date := p_bill_sch_detail_rec.cycle_start_date;
        l_start_date       := p_bill_sch_detail_rec.line_start_date;
        l_end_date         := p_bill_sch_detail_rec.line_end_date;
        l_total_amount     := p_bill_sch_detail_rec.total_amount;

        get_seeded_timeunit(p_timeunit      => l_tuom_code,
                                  x_return_status => l_return_status,
                                  x_quantity      => l_uom_quantity ,
                                  x_timeunit      => l_tce_code);

        If l_end_date IS NULL or l_start_date IS NULL Then
                x_return_status := 'E';
                return;
        End if;

        l_next_billing_date := okc_time_util_pub.get_enddate
                                                ( p_start_date => l_cycle_start_date,
                                                  p_timeunit   => l_tuom_code,
                                                  p_duration   => l_tuom_per_period
                                                ) + 1 ;


/*** Line Start date is replaced by cycle start date, to get avoid proration of entire amount
     while calculating Bill amount ***/

        IF x_return_status = 'S' Then
           If l_next_billing_date <= l_start_date Then
                l_bill_amount := 0;
           Else
                IF l_tce_code = 'DAY' Then
                        l_frequency_day := (l_end_date - l_cycle_start_date) + 1;
                        l_frequency     := l_frequency_day;
                Elsif l_tce_code = 'MONTH' Then
                        l_frequency_mth := months_between(l_end_date + 1,l_cycle_start_date);
                        l_frequency         := l_frequency_mth;
                        IF NVL(l_uom_quantity,1) <> 1 Then              /* quarterly frequency */
                           l_frequency_qtr := l_frequency/l_uom_quantity;
                           l_frequency   := l_frequency_qtr;
                        end if;
                Elsif l_tce_code = 'YEAR' Then
                        l_frequency_yr := months_between(l_end_date + 1, l_cycle_start_date)/12;
                        l_frequency    := l_frequency_yr;
                End if;
                l_bill_amount := (nvl(l_total_amount,0)/nvl(l_frequency,1)) * nvl(l_tuom_per_period,0);

/*** This section has been added to check for cp lines ****/

                If l_start_date > l_cycle_start_date and l_start_date < l_next_billing_date Then
                If l_tce_code = 'DAY' Then
                 l_freq_descrep := l_next_billing_date - l_start_date;
                        Elsif l_tce_code = 'MONTH' Then
                           l_freq_descrep := months_between(l_next_billIng_date, l_start_date);
                           If nvl(l_uom_quantity,1) <> 1 then
                                l_freq_descrep := l_freq_descrep/l_uom_quantity;
                           End if;
                        Elsif l_tce_code = 'YEAR' Then
                           l_freq_descrep := months_between(l_next_billing_date, l_start_date)/12;
                        End if;
                l_bill_amount := (nvl(l_total_amount,0)/nvl(l_frequency,1)) * nvl(l_freq_descrep,0);
                End if;

          End if;
        End if;

        x_bill_sch_detail_rec.next_cycle_date    := l_next_billing_date;
--      x_bill_sch_detail_rec.date_transaction   := l_date_transaction;
--      x_bill_sch_detail_rec.date_to_interface  := l_date_to_interface;
        x_bill_sch_detail_rec.cycle_amount       := l_bill_amount;

        x_return_status := 'S';

EXCEPTION
        WHEN OTHERS THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;

END;

Function Get_frequency
(p_tce_code  IN VARCHAR2,
 p_fr_start_date  IN DATE,
 p_fr_end_date    IN DATE,
 p_uom_quantity   IN Number,
 x_return_status  OUT NOCOPY VARCHAR2
)  Return NUMBER
IS

l_frequency_day  NUMBER;
l_frequency_week  NUMBER;
l_frequency_mth  NUMBER;
l_frequency_yr  NUMBER;
l_frequency_qtr  NUMBER;
l_frequency  NUMBER;

BEGIN

                IF p_tce_code = 'DAY' Then
                        l_frequency_day := (p_fr_end_date - p_fr_start_date) + 1;
                        l_frequency     := l_frequency_day;
/*** This section has been modified to handle UOM = week ***/
/*** -- aiyengar,  10/01/2001    **/

                        IF NVL(p_uom_quantity,1) <> 1 Then
                           l_frequency_week := l_frequency / p_uom_quantity;
                           l_frequency  := l_frequency_week;
                        END IF;
                Elsif p_tce_code = 'MONTH' Then
                        l_frequency_mth := months_between(p_fr_end_date + 1,p_fr_start_date);
                        l_frequency         := l_frequency_mth;


                        IF NVL(p_uom_quantity,1) <> 1 Then              -- quarterly frequency

                           l_frequency_qtr := l_frequency/p_uom_quantity;
                           l_frequency   := l_frequency_qtr;

                  end if;
                Elsif p_tce_code = 'YEAR' Then
                        l_frequency_yr := months_between(p_fr_end_date + 1, p_fr_start_date)/12;
                        l_frequency    := l_frequency_yr;
                End if;
                x_return_status := 'S';
RETURN l_frequency;

EXCEPTION
     WHEN OTHERS THEN
     x_return_status := OKC_API.G_RET_STS_ERROR;
END ;

 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- Added two new parameters P_period_start,P_period_type
 -- Changed the logic for deriving l_next_billing_date
 -------------------------------------------------------------------------
Procedure Get_next_bill_sch
 ( p_api_version                  IN NUMBER,
   p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
   x_return_status                OUT NOCOPY VARCHAR2,
   x_msg_count                    OUT NOCOPY NUMBER,
   x_msg_data                     OUT NOCOPY VARCHAR2,
   p_invoicing_rule_id            IN  Number,
   p_bill_sch_detail_rec          IN  bill_det_inp_rec,
   x_bill_sch_detail_rec          OUT NOCOPY bill_sch_rec,
   P_period_start                 IN VARCHAR2,
   P_period_type                  IN VARCHAR2,
   -- Start - Added by PMALLARA - Bug #3992530
   Strm_Start_Date                IN DATE
   -- End - Added by PMALLARA - Bug #3992530
 )
IS

/** Local input variables ***/
l_tuom_code              Varchar2(10);
l_tce_code                       Varchar2(10);
l_uom_quantity           Number;
l_total_amount           Number;
l_start_date             DATE;
l_end_date                       DATE;
l_cycle_start_date       DATE;
l_action_offset          Number;
l_interface_offset       Number;
l_tuom_per_period                Number;
l_return_status                  Varchar2(1) := 'S';

/*** Local output variables ***/
l_bill_amount            Number;
l_next_billing_date      DATE;
l_date_transaction       DATE;
l_date_to_interface      DATE;

/** local programming variables **/
l_frequency                     Number;
l_frequency_day         Number;
l_frequency_mth         Number;
l_frequency_yr          Number;
l_frequency_qtr         Number;
l_freq_descrep           Number;
l_frequency_week        Number;
l_fr_start_date         Date;
l_fr_end_date           Date;
l_next_date             Date;
l_uom_per_period        Number;
BEGIN
/** Get next billing amount for refresh schedule ***/
x_return_status := l_return_status;

l_tuom_code        := p_bill_sch_detail_rec.tuom;
l_tuom_per_period  := p_bill_sch_detail_rec.tuom_per_period;
l_cycle_start_date := p_bill_sch_detail_rec.cycle_start_date;
l_start_date       := p_bill_sch_detail_rec.line_start_date;
l_end_date         := p_bill_sch_detail_rec.line_end_date;
l_total_amount     := p_bill_sch_detail_rec.total_amount;
l_uom_per_period   := p_bill_sch_detail_rec.uom_per_period;

get_seeded_timeunit(
                p_timeunit      => l_tuom_code,
                x_return_status => l_return_status,
                x_quantity      => l_uom_quantity ,
                x_timeunit      => l_tce_code);

If l_end_date IS NULL or l_start_date IS NULL Then
    x_return_status := 'E';
    return;
End if;

 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------
IF p_period_start IS NOT NULL        AND
   p_period_type IS NOT NULL         AND
   p_period_start = 'CALENDAR' AND
   l_tce_code not in ('DAY','HOUR','MINUTE')
THEN

--if stream start date not the start date of CALENDAR and cycle
--start date is equal to the stream start date then it is the first
--partial period


  IF TRUNC(Strm_Start_date,'MM') <> TRUNC(Strm_Start_date)  AND
     TRUNC(l_cycle_start_date) = TRUNC(Strm_Start_date)
  THEN

     l_next_billing_date := Last_day(TRUNC(Strm_Start_date))+ 1 ;

  ELSE
    IF TRUNC(Strm_Start_date,'MM') <> TRUNC(Strm_Start_date) THEN
       l_tuom_per_period := l_tuom_per_period - l_uom_per_period;
       l_next_date :=Last_day(TRUNC(Strm_Start_date))+ 1 ;
     ELSE
       l_next_date := Strm_Start_date;
     END IF;
     l_next_billing_date:= OKC_TIME_UTIL_PUB.GET_ENDDATE
                        (p_start_date => l_next_date,
                         p_timeunit   => l_tuom_code,
                         p_duration   => l_tuom_per_period
                         )+1;
  END IF;
-------------------------------------------------------------------------
-- End partial period computation logic
-------------------------------------------------------------------------
ELSE

-- Start - Modified by PMALLARA - Bug #3992530
l_next_billing_date := okc_time_util_pub.get_enddate
                        ( p_start_date => Strm_Start_Date,
                          p_timeunit   => l_tuom_code,
                          p_duration   => l_tuom_per_period
                        ) + 1 ;
-- End - Modified by PMALLARA - Bug #3992530
END IF;

/** Get transaction offset date ***/

    l_action_offset      := NVL(p_bill_sch_detail_rec.invoice_offset_days,0);

        If p_invoicing_rule_id = -2 Then  /*** For advance ****/

              l_date_transaction := l_cycle_start_date + l_action_offset;

                If l_date_transaction < SYSDATE Then
                   l_date_transaction := SYSDATE;
                End if;

        Elsif p_invoicing_rule_id = -3 Then             /*** For arrears ****/

                ---if not terminated subcription line .
                IF l_next_billing_date > l_end_date AND p_bill_sch_detail_rec.bill_type <> 'S' THEN
                   l_date_transaction := l_end_date + l_action_offset;
                ELSE

                   l_date_transaction := (l_next_billing_date - 1 ) + l_action_offset;
                END IF;

            ----l_date_transaction SHOULD not be less then bill from date and sysdate.

            IF l_date_transaction < l_cycle_start_date THEN
               l_date_transaction := l_cycle_start_date;
            END IF;

                If l_date_transaction < SYSDATE Then
                   l_date_transaction := SYSDATE;
                End if;

        End if;

/*** Get Interface offset date ***/

        l_interface_offset := nvl(p_bill_sch_detail_rec.interface_offset_days,0);

        If p_invoicing_rule_id = -2 Then   /*** advance ***/

                l_date_to_interface := l_cycle_start_date + l_interface_offset;
                IF l_date_to_interface > LEAST(l_date_transaction, l_cycle_start_date)  Then
                   l_date_to_interface := LEAST(l_date_transaction, l_cycle_start_date);
                End if;
                /* Commented for bug # 2359734 as told by hari and adas
                If l_date_to_interface < SYSDATE Then
                        l_date_to_interface := SYSDATE;
                End If;*/

        ELSIF p_invoicing_rule_id = -3 Then

                ---if not terminated subcription line .
                If l_next_billing_date > l_end_date AND p_bill_sch_detail_rec.bill_type <> 'S' Then
                   l_date_to_interface := (l_end_date + 1 )+ l_interface_offset  ;
                Else
                   l_date_to_interface := l_next_billing_date  + l_interface_offset;  /** Bill to date + 1 ***/
                End if;

                /* Commented for bug # 2359734 as told by hari and adas
                /* Added for bug 2115578.
                IF l_date_to_interface < SYSDATE THEN
                   l_date_to_interface := SYSDATE;
                END IF;*/

        END IF;

        x_bill_sch_detail_rec.next_cycle_date    := l_next_billing_date;
        x_bill_sch_detail_rec.date_transaction   := l_date_transaction;
        x_bill_sch_detail_rec.date_to_interface  := l_date_to_interface;
        x_bill_sch_detail_rec.cycle_amount       := l_bill_amount;

        x_return_status := 'S';

EXCEPTION
        WHEN OTHERS THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;

END;

Procedure Get_next_level_element
(  p_api_version          IN          NUMBER,
   p_id                   IN          NUMBER,
   p_covd_flag            IN          VARCHAR2,
   p_date                 IN          DATE,
   p_init_msg_list        IN          VARCHAR2 DEFAULT OKC_API.G_FALSE,
   x_return_status       OUT NOCOPY   VARCHAR2,
   x_msg_count           OUT NOCOPY   NUMBER,
   x_msg_data            OUT NOCOPY   VARCHAR2,
   x_next_level_element  OUT NOCOPY   LEVEL_ELEMENT_TAB
)
IS

l_bill_cycle_end_date  DATE := NULL;

Cursor l_csr_level_elements IS
SELECT le.date_start                       date_start,
       le.date_end                         date_end,
       le.id                               id,
       le.amount                           amount ,
       le.date_revenue_rule_start          date_revenue_rule_start,
       le.date_receivable_gl               date_receivable_gl,
       le.date_transaction                 date_transaction,
       nvl(le.date_to_interface,sysdate)   date_to_interface,
       le.date_due                         date_due,
       le.date_completed                   date_completed,
       le.rul_id                           rul_id,
       le.date_print                       date_print,
       le.sequence_number                  sequence_number,
       str.uom_code                        advance_period,
       str.uom_per_period                  tuom_per_period,
       str.start_date                      tp_start_date
 FROM oks_stream_levels_b str
     ,oks_level_elements le
WHERE le.cle_id = p_id
AND   le.rul_id = str.id
AND   le.date_completed IS NULL
AND   trunc(nvl(le.date_to_interface,sysdate)) <= trunc(p_date)
AND   not exists
        (select 1 from oks_bill_sub_lines bsl
	    where le.cle_id = bsl.cle_id
	    and trunc(le.date_start) >= trunc(bsl.date_billed_from)
	    and trunc(le.date_end) <= trunc(bsl.date_billed_to))
ORDER BY le.date_start;

----Exists clause is added as part of bug# 4915707 wherein skipped level elements have to be billed


Cursor l_next_level_element(p_cle_id in NUMBER,p_date in DATE) IS
SELECT lvl.date_start
   FROM oks_level_elements lvl
   WHERE  lvl.cle_id = p_cle_id
   AND    lvl.date_start > p_date
 ORDER BY lvl.date_start;

Cursor l_csr_get_enddate IS
SELECT date_terminated,end_date ,start_date
FROM okc_k_lines_b
WHERE id = p_id;

/**********
  These two selects were included  to ensure that
  there wont be any duplicate bills
  --- Hari  11/30/2001
********/
/*
Cursor l_bcl_csr(p_cle_id IN NUMBER) is
Select max(date_billed_to)
From oks_bill_cont_lines
WHERE cle_id = p_cle_id;
*/


Cursor l_bsl_csr(p_cle_id IN NUMBER) is
SELECT max(date_billed_to)
FROM oks_bill_sub_lines
WHERE cle_id = p_cle_id;

level_element_rec       L_CSR_LEVEL_ELEMENTS%ROWTYPE;
i                       NUMBER := 1;
l_advance_period        VARCHAR2(3);
l_tuom_quantity         NUMBER;
l_terminated_date       OKC_K_LINES_B.DATE_TERMINATED%TYPE;
l_end_date              OKC_K_LINES_B.END_DATE%TYPE;
l_start_date            OKC_K_LINES_B.START_DATE%TYPE;
l_bill_to_date          DATE;

BEGIN

  OPEN l_csr_level_elements;
  LOOP
    FETCH l_csr_level_elements into level_element_rec;
    IF (l_csr_level_elements%Notfound ) THEN
      Exit;
    ELSE
      l_advance_period  := level_element_rec.advance_period;
      l_tuom_quantity:= level_element_rec.tuom_per_period;
      x_next_level_element(i).id                   := level_element_rec.id;
      x_next_level_element(i).sequence_number    := level_element_rec.sequence_number;
      x_next_level_element(i).bill_from_date     := level_element_rec.date_start;
      x_next_level_element(i).bill_to_date       := level_element_rec.date_end;
      x_next_level_element(i).bill_amount          := level_element_rec.amount;
      x_next_level_element(i).date_to_interface  := level_element_rec.date_to_interface;
      x_next_level_element(i).date_receivable_gl := level_element_rec.date_receivable_gl;
      x_next_level_element(i).date_transaction   := level_element_rec.date_transaction;
      x_next_level_element(i).date_due           := level_element_rec.date_due;
      x_next_level_element(i).date_print           := level_element_rec.date_print;
      x_next_level_element(i).date_revenue_rule_start := level_element_rec.date_revenue_rule_start;
      x_next_level_element(i).date_completed     := level_element_rec.date_completed;
      x_next_level_element(i).rule_id      := level_element_rec.rul_id;


      /* This whole logic is required to get end_date of billing period
         if end_date is NULL. This is because end_date field is added in
         11.5.10 . However it was not migrated from previous version
         due to performance issue.
      */

      IF (x_next_level_element(i).bill_to_date iS NULL) THEN

        OPEN  l_csr_get_enddate;
        FETCH l_csr_get_enddate INTO l_terminated_date,
                                     l_end_date,
                                     l_start_date;
        CLOSE l_csr_get_enddate;

        OPEN  l_next_level_element(p_id,level_element_rec.date_start);
        FETCH l_next_level_element into l_bill_to_date;
        IF (l_next_level_element%FOUND ) THEN
          l_bill_to_date := l_bill_to_date - 1;
        ELSE
          IF(l_terminated_date is NULL) THEN
            l_bill_to_date := l_end_date;
          --ELSIF ((l_terminated_date is NOT NULL) AND
          -- (trunc(l_start_date) = trunc(level_element_rec.date_start) )) THEN
          --  l_bill_to_date       := okc_time_util_pub.get_enddate(
          --                          to_date(level_element_rec.tp_start_date),
          --                                    l_advance_period  ,
          --                                    l_tuom_quantity );
          ELSIF (l_terminated_date is NOT NULL) THEN
          -- (trunc(l_start_date) <> trunc(level_element_rec.date_start) )) THEN
            l_bill_to_date  :=    okc_time_util_pub.get_enddate
                                             (level_element_rec.date_start,
                                              l_advance_period  ,
                                              l_tuom_quantity );
          END IF;
        END IF;
        CLOSE l_next_level_element;


        IF (l_end_date) < l_bill_to_date Then
          l_bill_to_date := l_end_date;
        END IF;

        x_next_level_element(i).bill_to_date := l_bill_to_date;
      END IF;

      i := i + 1;
    END IF ;

  END LOOP;
  CLOSE l_csr_level_elements;
  x_return_status := OKC_API.G_RET_STS_SUCCESS ;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END;


Function Get_total_inv_billed(p_api_version     IN  Varchar2,
                              p_rule_id         IN  Number,
                              p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                              x_return_status   OUT NOCOPY Varchar2,
                              x_msg_count       OUT NOCOPY NUMBER,
                              x_msg_data        OUT NOCOPY VARCHAR2)
RETURN NUMBER

IS

l_total_inv_billed      Number;

Cursor l_csr_total_inv_billed IS
Select count(id)
From oks_level_elements
Where rul_id = p_rule_id
And date_completed IS NOT NULL;

Begin
Open l_csr_total_inv_billed;
Fetch l_csr_total_inv_billed INTO l_total_inv_billed;
Close l_csr_total_inv_billed;

Return l_total_inv_billed;
x_return_status := OKC_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    RAISE G_EXCEPTION_HALT_VALIDATION;
End Get_total_inv_billed;




Procedure delete_row_level_elements( p_rul_id IN Number,
                                    p_seq_no IN Number,
                                    x_return_status OUT NOCOPY Varchar2)
IS



Begin

--delete level elements for given sll id

DELETE from OKS_LEVEL_ELEMENTS
where rul_id = p_rul_id ;

--DELETE SLL
DELETE FROM oks_stream_levels_b
WHERE id = p_rul_id;

ExceptioN
        When Others then
                x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
End;

 PROCEDURE pre_del_level_elements(
    p_api_version       IN NUMBER,
    p_terminated_date   IN  DATE,
    p_id                IN NUMBER ,  --1 for line ,2 for covered level
    p_flag              IN NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2
)IS
CURSOR coverage (p_line_id IN NUMBER) is
 SELECT id from okc_k_lines_b
  WHERE cle_id = p_line_id
  AND   lse_id in (7,8,9,10,11,35,18,13,25);

l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);
 BEGIN
  x_return_status :=  OKC_API.G_RET_STS_SUCCESS;
  IF (p_flag = 1) THEN
      oks_bill_util_pub.delete_level_elements
     (
       p_api_version      => 1.0,
       p_terminated_date  => p_terminated_date,
       p_chr_id           => NULL,
       p_cle_id           => p_id,
       p_init_msg_list    => 'T',
       x_return_status    => x_return_status,
       x_msg_count        => l_msg_count,
       x_msg_data         => l_msg_data
     );
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise G_EXCEPTION_HALT_VALIDATION;
      END IF;

     FOR cov_cur in coverage(p_id)
      LOOP
         oks_bill_util_pub.delete_level_elements
         (
         p_api_version      => 1.0,
         p_terminated_date  => p_terminated_date,
         p_chr_id           => NULL,
         p_cle_id           => cov_cur.id,
         p_init_msg_list    => 'T',
         x_return_status    => x_return_status,
         x_msg_count        => l_msg_count,
         x_msg_data         => l_msg_data
         );
         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           raise G_EXCEPTION_HALT_VALIDATION;
         END IF;

      END LOOP;


  ELSIF (p_flag = 2) THEN
      oks_bill_util_pub.delete_level_elements
     (
       p_api_version      => 1.0,
       p_terminated_date  => p_terminated_date,
       p_chr_id           => NULL,
       p_cle_id           => p_id,
       p_init_msg_list    => 'T',
       x_return_status    => x_return_status,
       x_msg_count        => l_msg_count,
       x_msg_data         => l_msg_data
     );
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        raise G_EXCEPTION_HALT_VALIDATION;
      END IF;

  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status :=  OKC_API.G_RET_STS_ERROR;
END  pre_del_level_elements;


Procedure delete_level_elements (p_api_version   IN  NUMBER,
                                 p_rule_id       IN Number,
                                 p_init_msg_list IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2,
                                 x_return_status OUT NOCOPY Varchar2 )
IS

----modified by upma for rules re-arch.

/*** This cursor will get sll info */


Cursor l_get_line_sll_csr IS
Select id, cle_id , sequence_no
From Oks_stream_levels_b
where id = p_rule_id;


/*** This cursor will get the line_id for all sub lines of Top Line for which Rule id was passed, in
to the above cursor ***/

Cursor l_get_cp_csr(p_cle_id Number) IS
Select id
From Okc_k_lines_b
Where cle_id = p_cle_id
and lse_id in (35,7,8,9,10,11,13,18,25);


/** This cursor gets the rule id for covered products ****/

Cursor l_get_cp_sll_csr(p_cp_line_id Number, l_seq_no NUMBER) IS
Select id , sequence_no
From oks_stream_levels_b
Where cle_id = p_cp_line_id
And sequence_no = l_seq_no;

CURSOR l_bill_type_csr(p_line_id  NUMBER) IS
       SELECT nvl(billing_schedule_type,'T') billing_schedule_type
       FROM oks_k_lines_b
       WHERE cle_id = p_line_id;

l_get_line_sll_rec          l_get_line_sll_csr%ROWTYPE;
l_get_cp_rec                l_get_cp_csr%ROWTYPE;
l_get_cp_sll_rec            l_get_cp_sll_csr%ROWTYPE;
l_bill_type_rec             l_bill_type_csr%ROWTYPE;


Begin

x_return_status := OKC_API.G_RET_STS_SUCCESS;


  /*** get sll info for a given rule id**/

  Open l_get_line_sll_csr;
  Fetch l_get_line_sll_csr into l_get_line_sll_rec;

  IF  l_get_line_sll_csr%NOTFOUND Then
    CLOSE l_get_line_sll_csr;
    RETURN;
  END IF;

---get bill type details
Open l_bill_type_Csr(l_get_line_sll_rec.cle_id);
Fetch l_bill_type_Csr Into l_bill_type_Rec;

If l_bill_type_csr%Notfound then
    Close l_bill_type_Csr;
    x_return_status := 'E';
     OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'BILLING SCHEDULE TYPE NOT FOUND.');
    RAISE G_EXCEPTION_HALT_VALIDATION;
End If;
Close l_bill_type_Csr;


  IF l_bill_type_rec.billing_schedule_type <> 'P' Then
/** If rule type is 'P' then do not delete covered level rule sll level elements
    Else  Delete ***/

    FOR l_get_cp_rec IN l_get_cp_csr(l_get_line_sll_rec.cle_id)
    Loop
        Open l_get_cp_sll_csr(l_get_cp_rec.id,l_get_line_sll_rec.sequence_no) ;
        Fetch l_get_cp_sll_csr Into l_get_cp_sll_rec;

        If l_get_cp_sll_csr%Notfound then
           close l_get_cp_sll_csr;

      ELSE
         /*** Delete level elements ****/
          Delete_row_level_elements (l_get_cp_sll_rec.id,
                                   l_get_cp_sll_rec.sequence_no,
                                    x_return_status);


           close l_get_cp_sll_csr;
        End if;

    End loop;          ---sub line end loop
 END IF;      -- billing type <> 'P'



/*** Delete rule and level elements of the rule id that was passed ****/
Delete_row_level_elements (p_rule_id,
                                 l_get_line_sll_rec.cle_id,
                                 x_return_status);

CLOSE l_get_line_sll_csr;

EXCEPTION

WHEN OTHERS THEN
        x_return_status := 'E';

End Delete_level_elements;



 PROCEDURE delete_level_elements(
    p_api_version       IN NUMBER,
    p_terminated_date   IN  DATE,
    p_chr_id            IN NUMBER,
    p_cle_id            IN NUMBER ,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
 )

IS

---Modified by upma for re-arch.
--deltes lvl elements for line and sub line.

Cursor l_subLine_Csr(l_line_id number) Is
                     SELECT id , TRUNC(date_terminated) cp_term_dt
                     FROM okc_k_lines_b
                     WHERE cle_id = l_line_id
                     AND  lse_id in (35,7,8,9,10,11,13,18,25);

l_subline_rec        l_subline_csr%ROWTYPE;


BEGIN

x_return_status := OKC_API.G_RET_STS_SUCCESS;

IF  p_cle_id is NULL  THEN                        /* when input parm is p_chr_id */
       DELETE FROM   OKS_LEVEL_ELEMENTS
       WHERE  Date_Completed is NULL
       AND TRUNC(date_start) >= TRUNC(p_terminated_date)
       AND dnz_chr_id = p_chr_id;


ELSE

      DELETE FROM   OKS_LEVEL_ELEMENTS
       WHERE  Date_Completed is NULL
       AND TRUNC(date_start) >= TRUNC(p_terminated_date)
       AND cle_id = p_cle_id;

----DELETE lvl elements for subline

      FOR l_subline_rec IN l_subline_csr(p_cle_id)
      LOOP

        DELETE FROM   OKS_LEVEL_ELEMENTS
        WHERE  Date_Completed is NULL
        AND TRUNC(date_start) >= nvl(TRUNC(l_subline_rec.cp_term_dt),TRUNC(p_terminated_date))
        AND cle_id = l_subline_rec.id;
      END LOOP;


END IF;

EXCEPTION

WHEN OTHERS THEN
        x_return_status := 'E';


END delete_level_elements;


/*** deleting rules ***/
  PROCEDURE delete_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_chr_id                       IN NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2) IS


    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 1;

    cursor rule_csr Is
           select   rul.id
                    from   okc_rules_b rul
                    where  rul.rule_information_category in ('IRE') and
                    dnz_chr_id = p_chr_id;

    p_rulv_tbl       OKC_RULE_PUB.rulv_tbl_type;
    l_rule_id        number;

  BEGIN

    open rule_csr;

    LOOP
        Fetch rule_csr Into l_rule_id;
        EXIT WHEN rule_csr%NOTFOUND;
        p_rulv_tbl(i).id := l_rule_id;
        i := i + 1;

    END LOOP;

    close rule_csr;

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_rulv_tbl.COUNT > 0 THEN

       OKC_RULE_PUB.delete_rule(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rulv_tbl      => p_rulv_tbl);

        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;

    END IF;


  EXCEPTION

  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Delete_Rule;


/*** deleting rules ***/

  PROCEDURE delete_slh_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_cle_id                       IN NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2)
 IS
 BEGIN

x_return_status   := OKC_API.G_RET_STS_SUCCESS;

UPDATE oks_k_lines_b SET billing_schedule_type = NULL
WHERE cle_id =p_cle_id;

DELETE FROM oks_stream_levels_b where cle_id = P_CLE_ID;

EXCEPTION

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END Delete_SLH_Rule;




/** Code for changing/splitting service lines **/

  procedure get_rev_distr(p_cle_id  IN NUMBER,
                          x_rev_tbl OUT NOCOPY OKS_REV_DISTR_PUB.rdsv_tbl_type) IS
    cursor rev_cur is
    select
      chr_id, cle_id,
      account_class,
      code_combination_id,
      percent
    from oks_rev_distributions
    where cle_id = p_cle_id;
    i NUMBER := 1;
  begin
    for rev_rec in rev_cur
    loop
      x_rev_tbl(i).id                  := OKC_API.G_MISS_NUM;
      x_rev_tbl(i).chr_id              := rev_rec.chr_id;
      x_rev_tbl(i).account_class       := rev_rec.account_class;
      x_rev_tbl(i).code_combination_id := rev_rec.code_combination_id;
      x_rev_tbl(i).percent             := rev_rec.percent;
      x_rev_tbl(i).object_version_number := OKC_API.G_MISS_NUM;
      x_rev_tbl(i).created_by          := OKC_API.G_MISS_NUM;
      x_rev_tbl(i).creation_date       := OKC_API.G_MISS_DATE;
      x_rev_tbl(i).last_updated_by     := OKC_API.G_MISS_NUM;
      x_rev_tbl(i).last_update_date    := OKC_API.G_MISS_DATE;
      x_rev_tbl(i).last_update_login   := OKC_API.G_MISS_NUM;
      i := i + 1;
    end loop;
  end get_rev_distr;

  procedure create_rev_distr(p_cle_id  IN NUMBER,
                             p_rev_tbl IN OUT NOCOPY OKS_REV_DISTR_PUB.rdsv_tbl_type,
                             x_status  OUT NOCOPY VARCHAR2) IS
    l_api_version NUMBER := 1.0;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_rev_tbl OKS_REV_DISTR_PUB.rdsv_tbl_type;
    i NUMBER;
  begin
    i := p_rev_tbl.FIRST;
    Loop
      p_rev_tbl(i).cle_id := p_cle_id;
      exit when i = p_rev_tbl.LAST;
      i := p_rev_tbl.NEXT(i);
    End Loop;
    OKS_REV_DISTR_PUB.insert_Revenue_Distr(
                            p_api_version   => l_api_version,
                            x_return_status => x_status,
                            x_msg_count     => l_msg_count,
                            x_msg_data      => l_msg_data,
                            p_rdsv_tbl      => p_rev_tbl,
                            x_rdsv_tbl      => l_rev_tbl);
  end create_rev_distr;

  procedure get_sales_cred(p_cle_id  IN NUMBER,
                           x_scrv_tbl OUT NOCOPY OKS_SALES_CREDIT_PUB.scrv_tbl_type) IS
    cursor scrv_cur is
    select
      percent,
      chr_id,
      ctc_id,
      sales_credit_type_id1,
      sales_credit_type_id2
    from OKS_K_SALES_CREDITS
    where cle_id = p_cle_id;
    i NUMBER := 1;
  begin
    for scrv_rec in scrv_cur
    loop
      x_scrv_tbl(i).id                    := OKC_API.G_MISS_NUM;
      x_scrv_tbl(i).percent               := scrv_rec.percent;
      x_scrv_tbl(i).chr_id                := scrv_rec.chr_id;
      x_scrv_tbl(i).ctc_id                := scrv_rec.ctc_id;
      x_scrv_tbl(i).sales_credit_type_id1 := scrv_rec.sales_credit_type_id1;
      x_scrv_tbl(i).sales_credit_type_id2 := scrv_rec.sales_credit_type_id2;
      x_scrv_tbl(i).object_version_number := OKC_API.G_MISS_NUM;
      x_scrv_tbl(i).created_by            := OKC_API.G_MISS_NUM;
      x_scrv_tbl(i).creation_date         := OKC_API.G_MISS_DATE;
      x_scrv_tbl(i).last_updated_by       := OKC_API.G_MISS_NUM;
      x_scrv_tbl(i).last_update_date      := OKC_API.G_MISS_DATE;
      i := i + 1;
    end loop;
  end get_sales_cred;

  procedure create_sales_cred(p_cle_id   IN NUMBER,
                              p_scrv_tbl IN OUT NOCOPY OKS_SALES_CREDIT_PUB.scrv_tbl_type,
                              x_status   OUT NOCOPY VARCHAR2) IS
    l_api_version NUMBER := 1.0;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_scrv_tbl OKS_SALES_CREDIT_PUB.scrv_tbl_type;
    i NUMBER;
  begin
    i := p_scrv_tbl.FIRST;
    Loop
      p_scrv_tbl(i).cle_id := p_cle_id;
      exit when i = p_scrv_tbl.LAST;
      i := p_scrv_tbl.NEXT(i);
    End Loop;
    OKS_SALES_CREDIT_PUB.insert_Sales_credit(
             p_api_version   => l_api_version,
             x_return_status => x_status,
             x_msg_count     => l_msg_count,
             x_msg_data      => l_msg_data,
             p_scrv_tbl      => p_scrv_tbl,
             x_scrv_tbl      => l_scrv_tbl);
  end create_sales_cred;

  procedure update_line_item(p_cle_id   IN NUMBER,
                             p_item_id  IN VARCHAR2,
                             x_status   OUT NOCOPY VARCHAR2) IS
    l_api_version NUMBER := 1.0;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_cimv_rec_in  OKC_CONTRACT_ITEM_PUB.cimv_rec_type;
    l_cimv_rec_out OKC_CONTRACT_ITEM_PUB.cimv_rec_type;
    cursor item_cur is
    select id
    from okc_k_items_v
    where cle_id = p_cle_id;
  begin
    open item_cur;
    fetch item_cur into l_cimv_rec_in.id;
    close item_cur;
    l_cimv_rec_in.object1_id1 := p_item_id;
    OKC_CONTRACT_ITEM_PUB.update_contract_item(
                p_api_version   => l_api_version,
                x_return_status => x_status,
                x_msg_count     => l_msg_count,
                x_msg_data      => l_msg_data,
                p_cimv_rec      => l_cimv_rec_in,
                x_cimv_rec      => l_cimv_rec_out);
  end update_line_item;

  procedure prorate_amount(p_cle_id     IN NUMBER,
                           p_percent    IN NUMBER,
                           p_amount     IN NUMBER,
                           x_status     OUT NOCOPY VARCHAR2) IS
    cursor subline_count is
    select count(*)
    from okc_k_lines_b
    where cle_id = p_cle_id
    and lse_id in (7,8,9,10,11,35, 18,25);

    cursor subline_cur is
    select id, price_negotiated
    from okc_k_lines_b
    where cle_id = p_cle_id
    and lse_id in (7,8,9,10,11,35, 18,25);

    l_total_amt NUMBER := 0;
    l_count NUMBER;
    i NUMBER;
    l_api_version NUMBER := 1.0;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_clev_tbl_in  OKC_CONTRACT_PUB.clev_tbl_type;
    l_clev_tbl_out OKC_CONTRACT_PUB.clev_tbl_type;
  begin
    Open subline_count;
    Fetch subline_count into l_count;
    Close subline_count;
    If l_count = 0 Then
      x_status := OKC_API.G_RET_STS_SUCCESS;
      return;
    End If;
    i := 1;
    For subline in subline_cur
    Loop
      l_clev_tbl_in(i).id := subline.id;
      If i <> l_count Then
        l_clev_tbl_in(i).price_negotiated := subline.price_negotiated * p_percent / 100.0;
      Else
        l_clev_tbl_in(i).price_negotiated := p_amount - l_total_amt;
      End If;

      l_total_amt := l_total_amt + NVL(l_clev_tbl_in(i).price_negotiated,0);
      i := i + 1;
    End Loop;
    OKC_CONTRACT_PUB.update_contract_line(
           p_api_version        => l_api_version,
           x_return_status      => x_status,
           x_msg_count          => l_msg_count,
           x_msg_data           => l_msg_data,
           p_clev_tbl           => l_clev_tbl_in,
           x_clev_tbl           => l_clev_tbl_out);
  end prorate_amount;



procedure refresh_bill_sch(p_cle_id   IN NUMBER,
                             x_rgp_id   OUT NOCOPY NUMBER,
                             x_status   OUT NOCOPY VARCHAR2) IS

cursor l_line_csr is
    select id, dnz_chr_id, inv_rule_id
    from okc_k_lines_b
    where id = p_cle_id;

cursor l_sll_csr IS
    SELECT *
    FROM oks_stream_levels_b
    WHERE cle_id = p_cle_id;

CURSOR l_bill_type_csr IS
       SELECT nvl(billing_schedule_type,'T') billing_schedule_type
       FROM oks_k_lines_b
       WHERE cle_id = p_cle_id;


l_sll_tbl OKS_BILL_SCH.StreamLvl_tbl;
l_bill_sch_out_tbl OKS_BILL_SCH.ItemBillSch_tbl;
l_bill_type_rec    l_bill_type_csr%ROWTYPE;

l_line_rec          l_line_csr%ROWTYPE;
l_sll_rec           l_sll_csr%ROWTYPE;
l_index             NUMBER;

BEGIN


x_status := 'S';

   ---get line details
Open l_Line_Csr;
Fetch l_Line_Csr Into l_Line_Rec;

If l_Line_Csr%Notfound then
 Close l_Line_Csr;
 x_status := 'E';
 OKC_API.set_message(G_PKG_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'LINE NOT FOUND');
 RAISE G_EXCEPTION_HALT_VALIDATION;
End If;
Close l_Line_Csr;

---get bill type details
Open l_bill_type_Csr;
Fetch l_bill_type_Csr Into l_bill_type_Rec;

If l_bill_type_csr%Notfound then
   NULL;
End If;
Close l_bill_type_Csr;


l_sll_tbl.DELETE;
l_index := 1;
----make sll tbl

FOR l_SlL_rec IN l_SlL_Csr
LOOP
  l_sll_tbl(l_index).id                             := l_SlL_rec.id;
  l_sll_tbl(l_index).cle_id                         := l_SlL_rec.cle_id;
  l_sll_tbl(l_index).chr_id                         := l_SlL_rec.chr_id;
  l_sll_tbl(l_index).dnz_chr_id                     := l_SlL_rec.dnz_chr_id;
  l_sll_tbl(l_index).uom_code                       := l_SlL_rec.uom_code;
  l_sll_tbl(l_index).sequence_no                    := l_SlL_rec.sequence_no;
  l_sll_tbl(l_index).Start_Date                     := l_SlL_rec.Start_Date;
  l_sll_tbl(l_index).end_Date                       := l_SlL_rec.end_Date;
  l_sll_tbl(l_index).level_periods                  := l_SlL_rec.level_periods;
  l_sll_tbl(l_index).uom_per_period                 := l_SlL_rec.uom_per_period;
  l_sll_tbl(l_index).level_amount                   := l_SlL_rec.level_amount;
  l_sll_tbl(l_index).invoice_offset_days             := l_SlL_rec.invoice_offset_days;
  l_sll_tbl(l_index).interface_offset_days          := l_SlL_rec.interface_offset_days;

  l_index := l_index + 1;
END LOOP;

IF l_sll_tbl.COUNT = 0 THEN
   RETURN;
END IF;


OKS_BILL_SCH.Create_Bill_Sch_Rules
        (p_billing_type    => nvl(l_bill_type_rec.billing_schedule_type,'T'),
         p_sll_tbl         => l_sll_tbl,
         p_invoice_rule_id => l_line_rec.inv_rule_id,
         x_bil_sch_out_tbl => l_bill_sch_out_tbl,
         x_return_status   => x_status);


End refresh_bill_sch;


  procedure create_USV_rule(p_rgp_id IN NUMBER,
                            p_info1  IN VARCHAR2,
                            p_info2  IN VARCHAR2,
                            p_info3  IN NUMBER,
                            x_status OUT NOCOPY VARCHAR2) is
    cursor rule_cur is
    select id
    from okc_rules_b
    where rgp_id = p_rgp_id
      and rule_information_category = 'USV';
    l_rule_id NUMBER;
    l_rulv_tbl_in             okc_rule_pub.rulv_tbl_type;
    l_rulv_tbl_out            okc_rule_pub.rulv_tbl_type;
    l_create  BOOLEAN := TRUE;
    l_api_version NUMBER := 1.0;
    l_msg_count   NUMBER;
    l_msg_data    VARCHAR2(2000);
  begin
    l_rulv_tbl_in.DELETE;
    open rule_cur;
    fetch rule_cur into l_rule_id;
    If rule_cur%FOUND Then
      l_create := FALSE;
    End If;
    close rule_cur;
    If l_create Then
      l_rulv_tbl_in(1).rgp_id                    := p_rgp_id;
      l_rulv_tbl_in(1).sfwt_flag                 := 'N';
      l_rulv_tbl_in(1).std_template_yn           := 'N';
      l_rulv_tbl_in(1).warn_yn                   := 'N';
      l_rulv_tbl_in(1).rule_information_category := 'USV';
      l_rulv_tbl_in(1).rule_information1         := p_info1;
      l_rulv_tbl_in(1).rule_information2         := p_info2;
      l_rulv_tbl_in(1).rule_information3         := p_info3;
      l_rulv_tbl_in(1).dnz_chr_id                := g_chr_id;
      l_rulv_tbl_in(1).object_version_number     := OKC_API.G_MISS_NUM;
      l_rulv_tbl_in(1).created_by                := OKC_API.G_MISS_NUM;
      l_rulv_tbl_in(1).creation_date             := SYSDATE;
      l_rulv_tbl_in(1).last_updated_by           := OKC_API.G_MISS_NUM;
      l_rulv_tbl_in(1).last_update_date          := SYSDATE;
      OKC_RULE_PUB.create_rule(
               p_api_version      => l_api_version,
               x_return_status    => x_status,
               x_msg_count        => l_msg_count,
               x_msg_data         => l_msg_data,
               p_rulv_tbl         => l_rulv_tbl_in,
               x_rulv_tbl         => l_rulv_tbl_out);
    Else
      l_rulv_tbl_in(1).id                        := l_rule_id;
      l_rulv_tbl_in(1).rgp_id                    := OKC_API.G_MISS_NUM;
      l_rulv_tbl_in(1).sfwt_flag                 := OKC_API.G_MISS_CHAR;
      l_rulv_tbl_in(1).std_template_yn           := OKC_API.G_MISS_CHAR;
      l_rulv_tbl_in(1).warn_yn                   := OKC_API.G_MISS_CHAR;
      l_rulv_tbl_in(1).rule_information_category := OKC_API.G_MISS_CHAR;
      l_rulv_tbl_in(1).rule_information1         := p_info1;
      l_rulv_tbl_in(1).rule_information2         := p_info2;
      l_rulv_tbl_in(1).rule_information3         := p_info3;
      l_rulv_tbl_in(1).dnz_chr_id                := g_chr_id;
      l_rulv_tbl_in(1).object_version_number     := OKC_API.G_MISS_NUM;
      l_rulv_tbl_in(1).created_by                := OKC_API.G_MISS_NUM;
      l_rulv_tbl_in(1).creation_date             := OKC_API.G_MISS_DATE;
      l_rulv_tbl_in(1).last_updated_by           := OKC_API.G_MISS_NUM;
      l_rulv_tbl_in(1).last_update_date          := OKC_API.G_MISS_DATE;
      OKC_RULE_PUB.update_rule(
               p_api_version      => l_api_version,
               x_return_status    => x_status,
               x_msg_count        => l_msg_count,
               x_msg_data         => l_msg_data,
               p_rulv_tbl         => l_rulv_tbl_in,
               x_rulv_tbl         => l_rulv_tbl_out);
    End If;
  end create_USV_rule;

  procedure update_header_amount(p_cle_id IN NUMBER,
                                 x_status  OUT NOCOPY VARCHAR2) IS
    l_api_version  CONSTANT NUMBER := 1.0;
    l_init_msg_list VARCHAR2(2000) := OKC_API.G_FALSE;
    l_return_status VARCHAR2(1);
    l_msg_count  NUMBER;
    l_msg_data  VARCHAR2(2000);
    l_msg_index_out NUMBER;
    l_chrv_tbl_in             okc_contract_pub.chrv_tbl_type;
    l_chrv_tbl_out            okc_contract_pub.chrv_tbl_type;

    cursor total_amount(p_chr_id IN NUMBER) IS
    select sum(price_negotiated) sum
    from okc_k_lines_b
    where dnz_chr_id = p_chr_id
      and lse_id in (7,8,9,10,11,35,13,18,25);
  Begin
    x_status := OKC_API.G_RET_STS_SUCCESS;
    If p_cle_id IS NOT NULL Then
      For cur_total_amount IN total_amount(g_chr_id)
      loop
        l_chrv_tbl_in(1).id := g_chr_id;
        l_chrv_tbl_in(1).estimated_amount := cur_total_amount.sum;
        okc_contract_pub.update_contract_header (
                     p_api_version     => l_api_version,
                     p_init_msg_list   => l_init_msg_list,
                     x_return_status   => l_return_status,
                     x_msg_count       => l_msg_count,
                     x_msg_data        => l_msg_data,
                     p_chrv_tbl        => l_chrv_tbl_in,
                     x_chrv_tbl        => l_chrv_tbl_out );
        x_status := l_return_status;
      end loop;
    End If;
  End update_header_amount;

  PROCEDURE copy_service( p_api_version   IN  NUMBER,
                          p_init_msg_list IN  VARCHAR2,
                          p_source_rec    IN  copy_source_rec,
                          p_target_tbl    IN OUT NOCOPY copy_target_tbl,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2
                        ) IS

    cursor header_cur IS
    select dnz_chr_id
    from okc_k_lines_b
    where id = p_source_rec.cle_id;

    idx NUMBER;
    l_rgp_id NUMBER;
    l_return_status VARCHAR2(20);
    l_rev_tbl OKS_REV_DISTR_PUB.rdsv_tbl_type;
    l_salescr_tbl OKS_SALES_CREDIT_PUB.scrv_tbl_type;
    l_msg_index NUMBER;
    l_msg_data VARCHAR2(2000);
    l_total_pct NUMBER := 0;
    l_rev_found BOOLEAN := FALSE;
    l_scr_found BOOLEAN := FALSE;
    l_top_line_number NUMBER := 0;
    cursor rule_group_cur(p_cle_id IN NUMBER) is
    select id
    from okc_rule_groups_b
    where cle_id = p_cle_id;
    G_ERROR EXCEPTION;
  Begin
    If p_target_tbl.COUNT = 0 Then
      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      return;
    End If;
    Open header_cur;
    Fetch header_cur into g_chr_id;
    Close header_cur;
--errorout('g_chr_id '||g_chr_id);
    -- First copy the source line to create all target lines.
    idx := p_target_tbl.FIRST;
    -- The original source line will become the first target line.(so, don't copy)
    p_target_tbl(idx).cle_id := p_source_rec.cle_id;
    -- If there are more target lines then make copies of the source line for each
    -- and update the p_target_tbl with the new line id.
    If idx <> p_target_tbl.LAST Then
--errorout('MORE THAN ONE RECORD PASSED');
      idx := p_target_tbl.NEXT(idx);
      get_rev_distr(p_source_rec.cle_id, l_rev_tbl);
      if l_rev_tbl.COUNT > 0 then
        l_rev_found := TRUE;
--errorout('Revenue Distrib. Found');
      end if;
      get_sales_cred(p_source_rec.cle_id, l_salescr_tbl);
      if l_salescr_tbl.COUNT > 0 then
        l_scr_found := TRUE;
--errorout('Sales Cred. Found');
      end if;

 --Fix for bug#2221910 start.  Get Max Of Top Lines.

      Select nvl(max(to_number(line_number)),0)
      INTO   l_top_line_number
      FROM   OKC_K_LINES_B
      WHERE  dnz_chr_id = g_chr_id
      and    cle_id is null;
 --Fix for bug#2221910 end.

      LOOP
        OKC_COPY_CONTRACT_PUB.copy_contract_lines(
           p_api_version    => p_api_version,
           p_init_msg_list  => p_init_msg_list,
           x_return_status  => l_return_status,
           x_msg_count      => x_msg_count,
           x_msg_data       => x_msg_data,
           p_from_cle_id    => p_source_rec.cle_id,
           p_to_chr_id      => g_chr_id,
           x_cle_id         => p_target_tbl(idx).cle_id);
--errorout('Copy line status: '||x_return_status);
        If l_return_status  <> OKC_API.G_RET_STS_SUCCESS Then
          x_return_status := l_return_status;
          Raise G_ERROR;
        End If;

--Fix for bug#2221910 start.  Update Top Line Sequence number.
        l_top_line_number := l_top_line_number + 1;
        Update okc_k_lines_b Set line_number = l_top_line_number
        Where  id = p_target_tbl(idx).cle_id;
--Fix for bug#2221910 end.

        OKS_SETUP_UTIL_PUB.update_line_numbers(p_chr_id        => g_chr_id,
                                                p_cle_id        => p_target_tbl(idx).cle_id,
                                                x_return_status => l_return_status);
        If l_return_status  <> OKC_API.G_RET_STS_SUCCESS Then
          x_return_status := l_return_status;
          Raise G_ERROR;
        End If;
        If l_rev_found Then
          create_rev_distr(p_target_tbl(idx).cle_id, l_rev_tbl, l_return_status);
--errorout('Create_rev_distr status: '||l_return_status);
          If l_return_status  <> OKC_API.G_RET_STS_SUCCESS Then
            x_return_status := l_return_status;
            Raise G_ERROR;
          End If;
        End If;
        If l_scr_found Then
          create_sales_cred(p_target_tbl(idx).cle_id, l_salescr_tbl, l_return_status);
--errorout('create_sales_cred status: '||l_return_status);
          If l_return_status  <> OKC_API.G_RET_STS_SUCCESS Then
            x_return_status := l_return_status;
            Raise G_ERROR;
          End If;
        End If;
        EXIT When idx = p_target_tbl.LAST;
        idx := p_target_tbl.NEXT(idx);
      END LOOP;
    End If;
    -- Now update each target line with the new item id, amount et cetera.
    idx := p_target_tbl.FIRST;
    LOOP
--errorout('=====');
--errorout('Target Table('||idx||').cle_id : '||p_target_tbl(idx).cle_id);
--errorout('Target Table('||idx||').item_id: '||p_target_tbl(idx).item_id);
--errorout('Target Table('||idx||').amount : '||p_target_tbl(idx).amount);
--errorout('Target Table('||idx||').percent: '||p_target_tbl(idx).percentage);
--errorout('=====');
      update_line_item(p_target_tbl(idx).cle_id, p_target_tbl(idx).item_id, l_return_status);
--errorout('update_line_item status: '||l_return_status);
      If l_return_status  <> OKC_API.G_RET_STS_SUCCESS Then
        x_return_status := l_return_status;
        Raise G_ERROR;
      End If;
      If p_target_tbl(idx).percentage <> 100 Then
        prorate_amount(p_target_tbl(idx).cle_id, p_target_tbl(idx).percentage, p_target_tbl(idx).amount, l_return_status);
--errorout('prorate_amount status: '||l_return_status);
        If l_return_status  <> OKC_API.G_RET_STS_SUCCESS Then
          x_return_status := l_return_status;
          Raise G_ERROR;
        End If;
        refresh_bill_sch(p_target_tbl(idx).cle_id, l_rgp_id, l_return_status);
--errorout('refresh_bill_sch status: '||l_return_status);
--errorout('rgp_id: '||l_rgp_id);
        If l_return_status  <> OKC_API.G_RET_STS_SUCCESS Then
          x_return_status := l_return_status;
          Raise G_ERROR;
        End If;
      Else
        open rule_group_cur(p_target_tbl(idx).cle_id);
        fetch rule_group_cur into l_rgp_id;
        close rule_group_cur;
--errorout('rgp_id:(1) '||l_rgp_id);
      End If;
      create_USV_rule(l_rgp_id,
                      p_source_rec.item_id,
                      p_target_tbl(idx).item_id,
                      p_source_rec.cle_id,
                      l_return_status);
--errorout('create_USV_rule status: '||l_return_status);
      If l_return_status  <> OKC_API.G_RET_STS_SUCCESS Then
        x_return_status := l_return_status;
        Raise G_ERROR;
      End If;
      l_total_pct := l_total_pct + p_target_tbl(idx).percentage;
      EXIT When idx = p_target_tbl.LAST;
      idx := p_target_tbl.NEXT(idx);
    END LOOP;
    If l_total_pct <> 100 Then
      null;
      update_header_amount(p_source_rec.cle_id, l_return_status);
--errorout('update_header_amount status: '||l_return_status);
      If l_return_status  <> OKC_API.G_RET_STS_SUCCESS Then
        x_return_status := l_return_status;
        Raise G_ERROR;
      End If;
    End If;
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
--errorout('SUCCESS');
  Exception
    When G_ERROR Then
/*
        FOR i in 1..fnd_msg_pub.count_msg
        Loop
          fnd_msg_pub.get(p_msg_index     => i,
                          p_encoded       => 'F',
                          p_data          => l_msg_data,
                          p_msg_index_out => l_msg_index );
          ErrorOut ('SCRIPT ERROR ' || l_msg_data );
        End Loop;
*/
      Null;
    When Others Then
      OKC_API.set_message(OKC_API.G_APP_NAME,
                          'OKS_UNEXP_ERROR',
                          'SQLcode',
                          SQLCODE,
                          'SQLerrm',
                          SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  End copy_service;

/**  End of Code for changing/splitting service lines **/


/****FOR  USAGE BILLING*********/
Procedure Calculate_Bill_Amount (
    p_api_version        IN NUMBER,
    p_init_msg_list      IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_bill_tbl           IN OUT NOCOPY Bill_tbl_type,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2)

IS

Cursor l_ctr_csr(p_counter_id Number)  Is
        SELECT  ccr.net_reading last_reading
        FROM    Cs_ctr_counter_values_v ccr
        WHERE  ccr.counter_id = p_counter_id
        ORDER BY value_timestamp desc;

Cursor l_init_csr(p_counter_id Number)  Is
        SELECT  ccr.initial_reading last_reading
        FROM    cs_counters ccr
        WHERE  ccr.counter_id = p_counter_id;

Cursor l_usage_line_csr(p_counter_id Varchar2) Is
        Select itm.uom_code, line.cle_id usage_id
        From   Okc_K_items Itm, okc_k_lines_b line
        Where  itm.cle_id = line.id
        And    itm.object1_id1 = p_counter_id
        And    itm.jtot_object1_code = 'OKX_COUNTER';



l_usage_line_rec     l_usage_line_csr%ROWTYPE;
l_last_reading       NUMBER;
l_total_reading      NUMBER := 0;
l_lvl_reading        NUMBER := 0;
l_act_reading        NUMBER := 0;
v_index              NUMBER;


BEGIN
x_return_status := OKC_API.G_RET_STS_SUCCESS;

--------errorout_ad('count = ' || p_bill_tbl.COUNT);

IF p_bill_tbl.COUNT <= 0 THEN
   x_return_status := OKC_API.G_RET_STS_ERROR;
   OKC_API.set_message(G_APP_NAME,G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'NO RECORDS PASSED');
   Raise G_EXCEPTION_HALT_VALIDATION;
END IF;

---FIND OUT LAST READING from the table and clculate net reading for each record

FOR v_index IN p_bill_tbl.FIRST .. p_bill_tbl.LAST
LOOP

   l_last_reading := 0 ;
   OPEN l_ctr_csr(p_bill_tbl(v_index).counter_id);
   FETCH l_ctr_csr INTO l_last_reading;

   IF l_ctr_csr%NOTFOUND THEN
        OPEN l_init_csr(p_bill_tbl(v_index).counter_id);
        FETCH l_init_csr INTO l_last_reading;
	   Close l_init_csr;
   END IF;

   CLOSE l_ctr_csr;

   p_bill_tbl(v_index).net_reading := nvl(p_bill_tbl(v_index).meter_reading,0) - nvl(l_last_reading,0) ;

   --------errorout_ad('net_reading for ' || v_index || 'record = ' || p_bill_tbl(v_index).net_reading);

   l_total_reading :=  l_total_reading + nvl(p_bill_tbl(v_index).net_reading,0);

   --------errorout_ad('l_total_reading  = ' || l_total_reading);
END LOOP;

---level all readings.

l_lvl_reading := ROUND(nvl(l_total_reading,0)/(p_bill_tbl.count),0);
l_act_reading := nvl(l_total_reading,0)/(p_bill_tbl.count);

--------errorout_ad('l_lvl_reading  = ' || l_lvl_reading);

FOR v_index IN p_bill_tbl.FIRST .. p_bill_tbl.LAST
LOOP

  p_bill_tbl(v_index).level_reading := l_lvl_reading;

  --------errorout_ad('passed');

   OPEN l_usage_line_csr(TO_CHAR(p_bill_tbl(v_index).counter_id));
   FETCH l_usage_line_csr INTO l_usage_line_rec;

   IF l_usage_line_csr%NOTFOUND THEN
     CLOSE l_usage_line_csr;
     x_return_status := OKC_API.G_RET_STS_ERROR;
     OKC_API.set_message(G_APP_NAME,G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'USAGE LINE NOT FOUND FOR THE COUNTER');
     Raise G_EXCEPTION_HALT_VALIDATION;
   END IF;
   CLOSE l_usage_line_csr;
   --------errorout_ad('usage line id for ' || v_index || 'line = ' ||  l_usage_line_rec.usage_id);
   --------errorout_ad('uom code for ' || v_index || 'line = ' ||  l_usage_line_rec.uom_code);

   IF p_bill_tbl(v_index).level_reading IS NOT NULL AND
      p_bill_tbl(v_index).level_reading > 0 THEN

      l_line_rec.line_id          := l_usage_line_rec.usage_id;             ----usage line id;
      l_line_rec.intent           := 'USG';
      l_line_rec.usage_qty        := p_bill_tbl(v_index).level_reading ;           --level reading
      l_line_rec.usage_uom_code   := l_usage_line_rec.uom_code;
      l_line_rec.bsl_id           := -99;


      /*Pricing API to calculate amount */
      OKS_QP_PKG.CALC_PRICE
                (
                 P_DETAIL_REC          => l_line_rec,
                 X_PRICE_DETAILS       => l_price_rec,
                 X_MODIFIER_DETAILS    => l_modifier_details,
                 X_PRICE_BREAK_DETAILS => l_price_break_details,
                 X_RETURN_STATUS       => x_return_status,
                 X_MSG_COUNT           => x_msg_count,
                 X_MSG_DATA            => x_msg_data);


     IF x_return_status <> 'S' Then
        OKC_API.set_message(G_APP_NAME,'CALCULATE PRICE ERROR');
        Raise G_EXCEPTION_HALT_VALIDATION;
     End If;

	/*****
	  commented as part of bug 5068589

     p_bill_tbl(v_index).bill_amount  := l_price_rec.PROD_EXT_AMOUNT;
     p_bill_tbl(v_index).bill_amount  :=
	  nvl(l_price_rec.PROD_ADJ_UNIT_PRICE, l_price_rec.PROD_LIST_UNIT_PRICE ) * l_act_reading;
	  *****/

     p_bill_tbl(v_index).bill_amount  :=
	  nvl(l_price_rec.PROD_ADJ_UNIT_PRICE, l_price_rec.PROD_LIST_UNIT_PRICE ) *  p_bill_tbl(v_index).net_reading;

     --------errorout_ad('amount for ' || v_index || 'line = ' ||  p_bill_tbl(v_index).bill_amount );
   ELSE
     p_bill_tbl(v_index).bill_amount  := 0;
   END IF;



END LOOP;

EXCEPTION

      WHEN  G_EXCEPTION_HALT_VALIDATION Then
            NULL;
      WHEN  OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

END Calculate_Bill_Amount;

Function Get_Credit_Amount (p_api_version        IN  Varchar2,
                            p_cp_line_id         IN  Number,
                            p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            x_return_status      OUT NOCOPY VARCHAR2,
                            x_msg_count          OUT NOCOPY NUMBER,
                            x_msg_data           OUT NOCOPY VARCHAR2)
RETURN NUMBER
IS

CURSOR  l_credit_amt_csr IS
        SELECT nvl(SUM(bsl.amount),0) tot_credit_amt
        FROM   Oks_bill_cont_lines bcl, Oks_bill_sub_lines  bsl
        WHERE  bsl.Cle_id = p_cp_line_id
        AND    bcl.id     = bsl.bcl_id
        AND    bcl.bill_action = 'TR';

l_tot_credit_amt    NUMBER := 0;

BEGIN

OPEN  l_credit_amt_csr;
FETCH l_credit_amt_csr INTO l_tot_credit_amt;

IF l_credit_amt_csr%NOTFOUND THEN
   CLOSE l_credit_amt_csr;
   RETURN 0;
END IF;

CLOSE l_credit_amt_csr;

RETURN l_tot_credit_amt;

EXCEPTION

      WHEN  OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

END Get_Credit_Amount;

/* ****** ------------------- Procedures for creating Billing report ------------------------ ****** */
/* ************************************************************************************************* */


PROCEDURE delete_duplicate_lines (p_lines_table       IN  OKS_BILL_REC_PUB.line_report_tbl_type
                                  ,x_lines_table      OUT NOCOPY OKS_BILL_REC_PUB.line_report_tbl_type
                                  ,x_return_status    OUT NOCOPY Varchar2
                                 )  IS

  l_lines_rec_tmp           OKS_BILL_REC_PUB.line_report_rec_type;
  l_lines_tbl_tmp           OKS_BILL_REC_PUB.line_report_tbl_type DEFAULT p_lines_table ;

  l_tbl_idx            Binary_integer;
  l_line_id1           Varchar2(100) ;
  l_line_id2           Varchar2(100);

Begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  l_tbl_idx       := l_lines_tbl_tmp.FIRST;

  While l_tbl_idx Is Not Null
  Loop
        l_line_id1    := l_lines_tbl_tmp(l_tbl_idx).Line_id ;
        l_line_id2    := l_lines_rec_tmp.Line_Id;

        If l_line_id1  =  l_line_id2 Then
             l_lines_tbl_tmp.DELETE(l_tbl_idx) ;
        Else
             l_lines_rec_tmp   := l_lines_tbl_tmp(l_tbl_idx) ;
        End If;

       l_tbl_idx  := l_lines_tbl_tmp.NEXT(l_tbl_idx) ;
  End Loop;

  x_lines_table   := l_lines_tbl_tmp ;
  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  Exception When Others Then

      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      FND_FILE.PUT_LINE( FND_FILE.LOG, '*** Billing Report:: delete_duplicate_lines  Error   ' || sqlerrm);

      OKC_API.SET_MESSAGE
           (P_App_Name          => G_APP_NAME
              ,P_Msg_Name       => G_UNEXPECTED_ERROR
              ,P_Token1         => G_SQLCODE_TOKEN
              ,P_Token1_Value   => SQLCODE
              ,P_Token2         => G_SQLERRM_TOKEN
              ,P_Token2_Value   => SQLERRM);


End delete_duplicate_lines ;

/* *** --------------------------------------------- *** */

PROCEDURE delete_duplicate_sub_lines (p_sub_lines_table       IN  OKS_BILL_REC_PUB.line_report_tbl_type
                                     ,x_sub_lines_table       OUT NOCOPY OKS_BILL_REC_PUB.line_report_tbl_type
                                     ,x_return_status         OUT NOCOPY Varchar2
                                      )  IS

  l_sub_lines_rec_tmp           OKS_BILL_REC_PUB.line_report_rec_type;
  l_sub_lines_tbl_tmp           OKS_BILL_REC_PUB.line_report_tbl_type DEFAULT p_sub_lines_table ;

  l_tbl_idx            Binary_integer;
  l_line_id1           Varchar2(100) ;
  l_line_id2           Varchar2(100);

Begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  l_tbl_idx       := l_sub_lines_tbl_tmp.FIRST;

  While l_tbl_idx Is Not Null
  Loop
        l_line_id1    := l_sub_lines_tbl_tmp(l_tbl_idx).Sub_Line_id ;
        l_line_id2    := l_sub_lines_rec_tmp.Sub_Line_Id;

        If l_line_id1  =  l_line_id2 Then
             l_sub_lines_tbl_tmp.DELETE(l_tbl_idx) ;
        Else
             l_sub_lines_rec_tmp   := l_sub_lines_tbl_tmp(l_tbl_idx) ;
        End If;

       l_tbl_idx  := l_sub_lines_tbl_tmp.NEXT(l_tbl_idx) ;
  End Loop;

  x_sub_lines_table   := l_sub_lines_tbl_tmp ;
  x_return_status     := OKC_API.G_RET_STS_SUCCESS;

  Exception When Others Then

      FND_FILE.PUT_LINE( FND_FILE.LOG, '*** Billing Report:: delete_duplicate_sub_lines  Error   ' || sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

      OKC_API.SET_MESSAGE
           (P_App_Name         => G_APP_NAME
              ,P_Msg_Name      => G_UNEXPECTED_ERROR
              ,P_Token1        => G_SQLCODE_TOKEN
              ,P_Token1_Value  => SQLCODE
              ,P_Token2        => G_SQLERRM_TOKEN
              ,P_Token2_Value  => SQLERRM);

End delete_duplicate_sub_lines ;

/* *** --------------------------------------------- *** */


PROCEDURE sort_lines_table (p_lines_table           IN OKS_BILL_REC_PUB.line_report_tbl_type
                           ,x_lines_table           OUT NOCOPY OKS_BILL_REC_PUB.line_report_tbl_type
                           ,x_return_status         OUT NOCOPY Varchar2
                        )   IS

  l_lines_rec_tmp           OKS_BILL_REC_PUB.line_report_rec_type;
  l_lines_tbl_tmp           OKS_BILL_REC_PUB.line_report_tbl_type DEFAULT p_lines_table ;

  l_in_tbl_idx         Binary_integer;
  l_out_tbl_idx        Binary_integer;
  l_line_id1           Varchar2(95) ;
  l_line_id2           Varchar2(95);

Begin

  x_return_status   := OKC_API.G_RET_STS_SUCCESS;
  l_out_tbl_idx     := l_lines_tbl_tmp.FIRST;

  While l_out_tbl_idx is Not Null
  Loop
       l_in_tbl_idx  := l_out_tbl_idx ;

       While l_in_tbl_idx Is Not Null
       Loop
            l_line_id1     := lpad(to_char(l_lines_tbl_tmp(l_out_tbl_idx).dnz_chr_id),40,'0')
                                                ||lpad(to_char(l_lines_tbl_tmp(l_out_tbl_idx).Line_Id),40,'0');
            l_line_id2     := lpad(to_char(l_lines_tbl_tmp(l_in_tbl_idx).dnz_chr_id),40,'0')
                                                ||lpad(to_char(l_lines_tbl_tmp(l_in_tbl_idx).Line_Id),40,'0');

            IF l_line_id1  > l_line_id2 then
                 l_lines_rec_tmp                  := l_lines_tbl_tmp(l_out_tbl_idx) ;
                 l_lines_tbl_tmp(l_out_tbl_idx)   := l_lines_tbl_tmp(l_in_tbl_idx);
                 l_lines_tbl_tmp(l_in_tbl_idx)    := l_lines_rec_tmp ;
            End If;

            l_in_tbl_idx    := l_lines_tbl_tmp.NEXT(l_in_tbl_idx) ;
       End Loop;

       l_out_tbl_idx   := l_lines_tbl_tmp.NEXT(l_out_tbl_idx) ;


  End Loop ;

  x_lines_table     := l_lines_tbl_tmp ;
  x_return_status   := OKC_API.G_RET_STS_SUCCESS;

  Exception When Others Then
      FND_FILE.PUT_LINE( FND_FILE.LOG, '*** Billing Report:: sort_lines_table Error   ' || sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      OKC_API.SET_MESSAGE
           (P_App_Name          => G_APP_NAME
              ,P_Msg_Name       => G_UNEXPECTED_ERROR
              ,P_Token1         => G_SQLCODE_TOKEN
              ,P_Token1_Value   => SQLCODE
              ,P_Token2         => G_SQLERRM_TOKEN
              ,P_Token2_Value   => SQLERRM);


End sort_lines_table ;


/* **** --------------------------------------- *** */


PROCEDURE sort_sub_lines_table (p_sub_lines_table     IN OKS_BILL_REC_PUB.line_report_tbl_type
                                ,x_sub_lines_table    OUT NOCOPY OKS_BILL_REC_PUB.line_report_tbl_type
                                ,x_return_status      OUT NOCOPY Varchar2
                                )   IS

  l_sub_lines_rec_tmp           OKS_BILL_REC_PUB.line_report_rec_type;
  l_sub_lines_tbl_tmp           OKS_BILL_REC_PUB.line_report_tbl_type DEFAULT p_sub_lines_table ;

  l_in_tbl_idx         Binary_integer;
  l_out_tbl_idx        Binary_integer;
  l_sub_line_id1       Varchar2(135);
  l_sub_line_id2       Varchar2(135);

Begin

  x_return_status   := OKC_API.G_RET_STS_SUCCESS;
  l_out_tbl_idx     := l_sub_lines_tbl_tmp.FIRST;

  While l_out_tbl_idx is Not Null
  Loop
       l_in_tbl_idx  := l_out_tbl_idx ;

       While l_in_tbl_idx Is Not Null
       Loop
            l_sub_line_id1     := lpad(to_char(l_sub_lines_tbl_tmp(l_out_tbl_idx).dnz_chr_id),40,'0')
                                               ||lpad(to_char(l_sub_lines_tbl_tmp(l_out_tbl_idx).line_id),40,'0')
                                               ||lpad(to_char(l_sub_lines_tbl_tmp(l_out_tbl_idx).sub_line_id),40,'0');
            l_sub_line_id2     := lpad(to_char(l_sub_lines_tbl_tmp(l_in_tbl_idx).dnz_chr_id),40,'0')
                                               ||lpad(to_char(l_sub_lines_tbl_tmp(l_in_tbl_idx).line_id),40,'0')
                                               ||lpad(to_char(l_sub_lines_tbl_tmp(l_in_tbl_idx).sub_line_id),40,'0');

            IF l_sub_line_id1  > l_sub_line_id2 then
                 l_sub_lines_rec_tmp                  := l_sub_lines_tbl_tmp(l_out_tbl_idx) ;
                 l_sub_lines_tbl_tmp(l_out_tbl_idx)   := l_sub_lines_tbl_tmp(l_in_tbl_idx);
                 l_sub_lines_tbl_tmp(l_in_tbl_idx)    := l_sub_lines_rec_tmp ;
            End If;

            l_in_tbl_idx    := l_sub_lines_tbl_tmp.NEXT(l_in_tbl_idx) ;
       End Loop;

       l_out_tbl_idx   := l_sub_lines_tbl_tmp.NEXT(l_out_tbl_idx) ;


  End Loop ;

  x_sub_lines_table     := l_sub_lines_tbl_tmp ;
  x_return_status       := OKC_API.G_RET_STS_SUCCESS;

  Exception When Others Then
      FND_FILE.PUT_LINE( FND_FILE.LOG, '*** Billing Report:: sort_sub_lines_table Error   ' || sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      OKC_API.SET_MESSAGE
               (P_App_Name       => G_APP_NAME
               ,P_Msg_Name       => G_UNEXPECTED_ERROR
               ,P_Token1         => G_SQLCODE_TOKEN
               ,P_Token1_Value   => SQLCODE
               ,P_Token2         => G_SQLERRM_TOKEN
               ,P_Token2_Value   => SQLERRM);


End sort_sub_lines_table ;

/* *** --------------------------------------------- *** */

PROCEDURE sub_lines_bill_status (p_sub_lines_table     IN OKS_BILL_REC_PUB.line_report_tbl_type
                                ,x_sub_lines_table    OUT NOCOPY OKS_BILL_REC_PUB.line_report_tbl_type
                                ,x_return_status      OUT NOCOPY Varchar2
                                )   IS

  l_sub_lines_tbl_tmp           OKS_BILL_REC_PUB.line_report_tbl_type DEFAULT p_sub_lines_table ;

  l_tmp_tbl_idx        Binary_integer;
  l_in_tbl_idx         Binary_integer;
  l_line_id            Number := 0;

Begin

  x_return_status   := OKC_API.G_RET_STS_SUCCESS;
  l_in_tbl_idx      := p_sub_lines_table.FIRST ;

  While l_in_tbl_idx is Not Null
  Loop

       If p_sub_lines_table(l_in_tbl_idx).Billed_YN = 'N' then

            l_line_id       := p_sub_lines_table(l_in_tbl_idx).Line_Id ;
            l_tmp_tbl_idx   := l_sub_lines_tbl_tmp.FIRST;

            While l_tmp_tbl_idx is Not Null
            Loop
                 If l_sub_lines_tbl_tmp(l_tmp_tbl_idx).Line_ID = l_line_id then
                      l_sub_lines_tbl_tmp(l_tmp_tbl_idx).Billed_YN := 'N' ;
                 End If;

                 l_tmp_tbl_idx  := l_sub_lines_tbl_tmp.NEXT(l_tmp_tbl_idx) ;
            End Loop;

       End If;

       l_in_tbl_idx   := p_sub_lines_table.NEXT(l_in_tbl_idx) ;

  End Loop ;

  x_sub_lines_table     := l_sub_lines_tbl_tmp ;
  x_return_status       := OKC_API.G_RET_STS_SUCCESS;

  Exception When Others Then
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      FND_FILE.PUT_LINE( FND_FILE.LOG, '*** Billing Report:: sub_lines_bill_status Error   ' || sqlerrm);
      OKC_API.SET_MESSAGE
               (P_App_Name      => G_APP_NAME
               ,P_Msg_Name      => G_UNEXPECTED_ERROR
               ,P_Token1        => G_SQLCODE_TOKEN
               ,P_Token1_Value  => SQLCODE
               ,P_Token2        => G_SQLERRM_TOKEN
               ,P_Token2_Value  => SQLERRM);


End sub_lines_bill_status ;

/* *** --------------------------------------------- *** */


Function Get_Billig_Profile (p_dnz_chr_id Number
                            )Return Varchar2 IS

 Cursor l_hdr_sbg_csr(p_dnz_chr_id Number) Is
        Select nvl(rul.rule_information13,'N')
        From  okc_rules_b        rul
              ,okc_rule_groups_b rgp
        Where  rgp.dnz_chr_id = p_dnz_chr_id
          And  rgp.id         = rul.rgp_id
          And  rul.rule_information_category = 'SBG';

  l_summary_flag        Varchar2(100) := Null;
  l_bill_profile        Varchar2(100) := Null;

Begin
       l_summary_flag         := Null;
       l_bill_profile         := Null;

/* *** This is not required -- honor only  FND_PROFILE.VALUE to get billing profile

       Open l_hdr_sbg_csr(p_dnz_chr_id);
            Fetch l_hdr_sbg_csr into l_summary_flag ;
       Close l_hdr_sbg_csr ;
       If (l_summary_flag = 'Y') Then
            l_bill_profile := 'Y';
       Else
            l_summary_flag      := Null;
            OKS_BILL_REC_PUB.Get_Bill_profile(p_dnz_chr_id, l_summary_flag);
            If (l_summary_flag = 'N') THEN
                 l_bill_profile   := 'N';
            Elsif (l_summary_flag = 'Y') THEN
                 l_bill_profile   := 'Y';
            Else
                 l_summary_flag   := Null;
                 l_summary_flag   := FND_PROFILE.VALUE('OKS_AR_TRANSACTIONS_SUBMIT_SUMMARY_YN');
                 If (l_summary_flag = 'YES') Then
                   l_bill_profile := 'Y';
                 Else
                   l_bill_profile := 'N';
                 End If;
            End If;
       End if;
*** */

   l_summary_flag   := FND_PROFILE.VALUE('OKS_AR_TRANSACTIONS_SUBMIT_SUMMARY_YN');
   If (l_summary_flag = 'YES') Then
       l_bill_profile := 'Y';
   Else
       l_bill_profile := 'N';
   End If;

   Return (l_bill_profile);

   Exception When Others then
      FND_FILE.PUT_LINE( FND_FILE.LOG, '*** Billing Report:: Get_Billig_Profile Error   ' || sqlerrm);
      Return(OKC_API.G_RET_STS_UNEXP_ERROR );
      OKC_API.SET_MESSAGE
            (P_App_Name          => G_APP_NAME
               ,P_Msg_Name       => G_UNEXPECTED_ERROR
               ,P_Token1         => G_SQLCODE_TOKEN
               ,P_Token1_Value   => SQLCODE
               ,P_Token2         => G_SQLERRM_TOKEN
               ,P_Token2_Value   => SQLERRM);

End Get_Billig_Profile ;

/* *** --------------------------------------------- *** */

Procedure Set_Billing_Profile (
                        p_lines_table        IN  OKS_BILL_REC_PUB.line_report_tbl_type
                       ,p_sub_lines_table    IN  OKS_BILL_REC_PUB.line_report_tbl_type
                       ,x_lines_table        OUT  NOCOPY OKS_BILL_REC_PUB.line_report_tbl_type
                       ,x_sub_lines_table    OUT  NOCOPY OKS_BILL_REC_PUB.line_report_tbl_type
                       ,x_return_status      OUT NOCOPY Varchar2
                       )   IS

  l_lines_tbl_copy        OKS_BILL_REC_PUB.line_report_tbl_type DEFAULT p_lines_table;
  l_sub_lines_tbl_copy    OKS_BILL_REC_PUB.line_report_tbl_type DEFAULT p_sub_lines_table;
  l_lines_tbl_idx         Binary_integer;
  l_slines_tbl_idx        Binary_integer;

  l_bill_profile        Varchar2(100) := Null;

Begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;


/* **** set the billing profile value for Summary billing **** */

  l_lines_tbl_idx  := l_lines_tbl_copy.FIRST;   /* Main Line Table */
  While l_lines_tbl_idx Is Not Null
  Loop
       l_bill_profile   := Null;

       l_bill_profile   := Get_Billig_Profile(l_lines_tbl_copy(l_lines_tbl_idx).Dnz_Chr_Id );

       If l_bill_profile <> OKC_API.G_RET_STS_UNEXP_ERROR then
           If l_bill_profile = 'Y' then
               l_lines_tbl_copy(l_lines_tbl_idx).Summary_bill_YN := 'Y' ;
           Else
               l_lines_tbl_copy(l_lines_tbl_idx).Summary_bill_YN := 'N' ;
           End If;
       End If ;
       l_lines_tbl_idx   := l_lines_tbl_copy.NEXT(l_lines_tbl_idx) ;

   End Loop ;

  l_slines_tbl_idx  := l_sub_lines_tbl_copy.FIRST;   /* Sub Lines Table */
  While l_slines_tbl_idx Is Not Null
  Loop
       l_bill_profile   := Null;

       l_bill_profile   := Get_Billig_Profile(l_sub_lines_tbl_copy(l_slines_tbl_idx).Dnz_Chr_Id );

       If l_bill_profile <> OKC_API.G_RET_STS_UNEXP_ERROR then
           If l_bill_profile = 'Y' then
               l_sub_lines_tbl_copy(l_slines_tbl_idx).Summary_bill_YN := 'Y' ;
           Else
               l_sub_lines_tbl_copy(l_slines_tbl_idx).Summary_bill_YN := 'N' ;
           End If;
       End If ;
       l_slines_tbl_idx   := l_sub_lines_tbl_copy.NEXT(l_slines_tbl_idx) ;

   End Loop ;


        x_lines_table      := l_lines_tbl_copy ;
        x_sub_lines_table  := l_sub_lines_tbl_copy;


    Exception When Others Then
      x_return_status  :=  OKC_API.G_RET_STS_UNEXP_ERROR ;
      FND_FILE.PUT_LINE( FND_FILE.LOG, '*** Billing Report:: Set_Billing_Profile Error   ' || sqlerrm);
      OKC_API.SET_MESSAGE
           (P_App_Name         => G_APP_NAME
              ,P_Msg_Name      => G_UNEXPECTED_ERROR
              ,P_Token1        => G_SQLCODE_TOKEN
              ,P_Token1_Value  => SQLCODE
              ,P_Token2        => G_SQLERRM_TOKEN
              ,P_Token2_Value  => SQLERRM);

End Set_Billing_Profile ;


/* *** --------------------------------------------- *** */

Function Sub_line_Name (p_jtot_object1_code   IN Varchar2
                        ,p_object1_id1       IN Number
                        ,p_object1_id2       IN Varchar2
                          ) Return Varchar2 IS

  Cursor l_party(p_object1_id1 Number, p_object1_id2 Varchar2) IS
    Select name
      From OKX_PARTIES_V
     Where id1 = p_object1_id1
       And id2 = p_object1_id2 ;

  Cursor l_cust_acct(p_object1_id1 Number, p_object1_id2 Varchar2) IS
    Select name
      From OKX_CUSTOMER_ACCOUNTS_V
     Where id1 = p_object1_id1
       And id2 = p_object1_id2 ;

--start bug#4928081 mchoudha replaced this cursor with the following
/*  Cursor l_cust_prod(p_object1_id1 Number, p_object1_id2 Varchar2) IS
    Select name
      From OKX_CUSTOMER_PRODUCTS_V
     Where id1 = p_object1_id1
       and id2 = p_object1_id2
       and organization_id = SYS_CONTEXT('OKC_CONTEXT','ORGANIZATION_ID') ;*/

  Cursor l_cust_prod(p_object1_id1 Number, p_object1_id2 Varchar2) IS
    Select SIT.description
    FROM CSI_ITEM_INSTANCES cp,
        MTL_SYSTEM_ITEMS_TL SIT
    WHERE cp.instance_ID=p_object1_id1
      and SIT.inventory_item_id = cp.inventory_item_id
      and SIT.LANGUAGE = userenv('LANG')
      and SIT.organization_id = SYS_CONTEXT('OKC_CONTEXT','ORGANIZATION_ID');

--End bug#4928081

  Cursor l_item(p_object1_id1 Number, p_object1_id2 Varchar2) IS
    Select name
      From OKX_SYSTEM_ITEMS_V
     Where id1 = p_object1_id1
       and id2 = p_object1_id2
       and organization_id = SYS_CONTEXT('OKC_CONTEXT','ORGANIZATION_ID')
       and serviceable_product_flag='Y' ;

  Cursor l_site(p_object1_id1 Number, p_object1_id2 Varchar2) IS
    Select name
     From OKX_CUST_SITE_USES_V
    Where id1 = p_object1_id1
      and id2 = p_object1_id2
      and NVL(ORG_ID, -99) = SYS_CONTEXT('OKC_CONTEXT','ORG_ID') ;

  Cursor l_system(p_object1_id1 Number, p_object1_id2 Varchar2) IS
    Select name
      From OKX_SYSTEMS_V
     Where id1 = p_object1_id1
       and id2 = p_object1_id2
       and NVL(ORG_ID, -99) = SYS_CONTEXT('OKC_CONTEXT','ORG_ID') ;


  l_name   Varchar2(300) := Null;

Begin

   l_name := Null;

   If p_jtot_object1_code = 'OKX_PARTY' then
       Open l_party(p_object1_id1,p_object1_id2) ;
          Fetch l_party into l_name ;
       Close l_party;
   Elsif p_jtot_object1_code = 'OKX_CUSTACCT' then
       Open l_cust_acct(p_object1_id1,p_object1_id2) ;
          Fetch l_cust_acct into l_name ;
       Close l_cust_acct;
   Elsif  p_jtot_object1_code = 'OKX_CUSTPROD' then
      Open l_cust_prod(p_object1_id1,p_object1_id2 );
         Fetch l_cust_prod into l_name;
      Close l_cust_prod ;
   Elsif p_jtot_object1_code = 'OKX_COVITEM' then
      Open l_item(p_object1_id1,p_object1_id2);
          Fetch l_item into l_name;
      Close l_item;
   Elsif p_jtot_object1_code = 'OKX_COVSITE' then
      Open l_site(p_object1_id1,p_object1_id2);
         Fetch l_site into l_name ;
      Close l_site ;
   Elsif p_jtot_object1_code  = 'OKX_COVSYST' then
      Open l_system(p_object1_id1,p_object1_id2);
         Fetch l_system into l_name;
      Close l_system ;
   Else
      l_name := p_jtot_object1_code ;
   End If;

   Return(l_name);


   Exception When Others then
      FND_FILE.PUT_LINE( FND_FILE.LOG, '*** Billing Report:: Sub_Line_Name Error   ' || sqlerrm);
      Return(OKC_API.G_RET_STS_UNEXP_ERROR );
      OKC_API.SET_MESSAGE
            (P_App_Name         => G_APP_NAME
               ,P_Msg_Name      => G_UNEXPECTED_ERROR
               ,P_Token1        => G_SQLCODE_TOKEN
               ,P_Token1_Value  => SQLCODE
               ,P_Token2        => G_SQLERRM_TOKEN
               ,P_Token2_Value  => SQLERRM);

End Sub_Line_Name ;


/* *** --------------------------------------------- *** */


PROCEDURE delete_duplicate_currency_code (p_currency_table   IN  OKS_BILL_REC_PUB.line_report_tbl_type
                                         ,x_currency_table   OUT NOCOPY OKS_BILL_REC_PUB.line_report_tbl_type
                                         ,x_return_status    OUT NOCOPY Varchar2
                                         )  IS

  l_currency_rec_tmp           OKS_BILL_REC_PUB.line_report_rec_type;
  l_currency_table_tmp         OKS_BILL_REC_PUB.line_report_tbl_type DEFAULT p_currency_table ;

  l_tbl_idx            Binary_integer;
  l_currency_cd1       Varchar2(15) ;
  l_currency_cd2       Varchar2(15);

Begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  l_tbl_idx       := l_currency_table_tmp.FIRST;

  While l_tbl_idx Is Not Null
  Loop
        l_currency_cd1    := l_currency_table_tmp(l_tbl_idx).currency_code ;
        l_currency_cd2    := l_currency_rec_tmp.currency_code;

        If l_currency_cd1  =  l_currency_cd2 Then
             l_currency_table_tmp.DELETE(l_tbl_idx) ;
        Else
             l_currency_rec_tmp   := l_currency_table_tmp(l_tbl_idx) ;
        End If;

       l_tbl_idx  := l_currency_table_tmp.NEXT(l_tbl_idx) ;
  End Loop;

  x_currency_table   := l_currency_table_tmp ;
  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  Exception When Others Then

      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      FND_FILE.PUT_LINE( FND_FILE.LOG, '*** Billing Report:: delete_duplicate_currency_code  Error   ' || sqlerrm);

      OKC_API.SET_MESSAGE
           (P_App_Name          => G_APP_NAME
              ,P_Msg_Name       => G_UNEXPECTED_ERROR
              ,P_Token1         => G_SQLCODE_TOKEN
              ,P_Token1_Value   => SQLCODE
              ,P_Token2         => G_SQLERRM_TOKEN
              ,P_Token2_Value   => SQLERRM);


End delete_duplicate_currency_code ;



/* *** --------------------------------------------- *** */


PROCEDURE sort_currency_table (p_currency_table         IN OKS_BILL_REC_PUB.line_report_tbl_type
                               ,x_currency_table        OUT NOCOPY OKS_BILL_REC_PUB.line_report_tbl_type
                               ,x_return_status         OUT NOCOPY Varchar2
                               )   IS

  l_currency_rec_tmp           OKS_BILL_REC_PUB.line_report_rec_type;
  l_currency_tbl_tmp           OKS_BILL_REC_PUB.line_report_tbl_type DEFAULT p_currency_table ;

  l_in_tbl_idx         Binary_integer;
  l_out_tbl_idx        Binary_integer;
  l_currency_cd1       Varchar2(15) ;
  l_currency_cd2       Varchar2(15);

Begin

  x_return_status   := OKC_API.G_RET_STS_SUCCESS;
  l_out_tbl_idx     := l_currency_tbl_tmp.FIRST;

  While l_out_tbl_idx is Not Null
  Loop
       l_in_tbl_idx  := l_out_tbl_idx ;

       While l_in_tbl_idx Is Not Null
       Loop
            l_currency_cd1     := l_currency_tbl_tmp(l_out_tbl_idx).Currency_code ;
            l_currency_cd2     := l_currency_tbl_tmp(l_in_tbl_idx).Currency_code ;

            IF l_currency_cd1  > l_currency_cd2 then
                 l_currency_rec_tmp                  := l_currency_tbl_tmp(l_out_tbl_idx) ;
                 l_currency_tbl_tmp(l_out_tbl_idx)   := l_currency_tbl_tmp(l_in_tbl_idx);
                 l_currency_tbl_tmp(l_in_tbl_idx)    := l_currency_rec_tmp ;
            End If;

            l_in_tbl_idx    := l_currency_tbl_tmp.NEXT(l_in_tbl_idx) ;
       End Loop;

       l_out_tbl_idx   := l_currency_tbl_tmp.NEXT(l_out_tbl_idx) ;


  End Loop ;

  x_currency_table     := l_currency_tbl_tmp ;
  x_return_status      := OKC_API.G_RET_STS_SUCCESS;

  Exception When Others Then
      FND_FILE.PUT_LINE( FND_FILE.LOG, '*** Billing Report:: sort_currency_table Error   ' || sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      OKC_API.SET_MESSAGE
           (P_App_Name          => G_APP_NAME
              ,P_Msg_Name       => G_UNEXPECTED_ERROR
              ,P_Token1         => G_SQLCODE_TOKEN
              ,P_Token1_Value   => SQLCODE
              ,P_Token2         => G_SQLERRM_TOKEN
              ,P_Token2_Value   => SQLERRM);


End sort_currency_table ;


/* *** --------------------------------------------- *** */
Procedure Get_Currency_code(p_lines_table             IN  OKS_BILL_REC_PUB.line_report_tbl_type
                            ,p_sub_lines_table        IN  OKS_BILL_REC_PUB.line_report_tbl_type
                            ,x_currency_table_out     OUT NOCOPY OKS_BILL_REC_PUB.line_report_tbl_type
                            ,x_return_status          OUT NOCOPY Varchar2
                           ) IS

 l_currency_table_tmp    OKS_BILL_REC_PUB.line_report_tbl_type ;
 l_currency_table_in     OKS_BILL_REC_PUB.line_report_tbl_type ;
 l_lines_table_tmp       OKS_BILL_REC_PUB.line_report_tbl_type DEFAULT  p_lines_table ;
 l_sub_lines_table_tmp   OKS_BILL_REC_PUB.line_report_tbl_type DEFAULT  p_sub_lines_table;

 l_line_tbl_idx          Binary_Integer ;
 l_sub_line_tbl_idx      Binary_Integer ;

 l_currency_tbl_idx      Binary_integer ;

 l_curreny_code          Varchar(15) := Null;
 l_return_status         Varchar2(30) ;

Begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  l_line_tbl_idx      := l_lines_table_tmp.FIRST;
  l_curreny_code      := 'X';
  l_currency_tbl_idx  := 1 ;

  While l_line_tbl_idx IS NOT NULL
  Loop
      If l_curreny_code <> l_lines_table_tmp(l_line_tbl_idx).Currency_Code then

           l_currency_table_tmp(l_currency_tbl_idx).currency_code := l_lines_table_tmp(l_line_tbl_idx).Currency_Code ;
           l_currency_tbl_idx  := l_currency_tbl_idx + 1;
           l_curreny_code      := l_lines_table_tmp(l_line_tbl_idx).Currency_Code ;

      End If;
      l_line_tbl_idx  := l_lines_table_tmp.NEXT(l_line_tbl_idx);
  End Loop ;

   l_sub_line_tbl_idx    := l_sub_lines_table_tmp.FIRST;

  While l_sub_line_tbl_idx IS NOT NULL
  Loop
      If l_curreny_code  <> l_sub_lines_table_tmp(l_sub_line_tbl_idx).currency_code Then

            l_currency_table_tmp(l_currency_tbl_idx).currency_code := l_sub_lines_table_tmp(l_sub_line_tbl_idx).currency_code ;
            l_currency_tbl_idx  := l_currency_tbl_idx + 1;
            l_curreny_code      := l_sub_lines_table_tmp(l_sub_line_tbl_idx).currency_code;

      End If;
      l_sub_line_tbl_idx   := l_sub_lines_table_tmp.NEXT(l_sub_line_tbl_idx) ;
  End Loop;



  /* *** Sort Currency Table *** */

  l_currency_table_in   := l_currency_table_tmp ;
  l_currency_table_tmp.DELETE ;
/*
  SORT_CURRENCY_TABLE (p_currency_table    => l_currency_table_in
                       ,x_currency_table   => l_currency_table_tmp
                       ,x_return_status    => l_return_status
                       )  ;

  If l_return_status = OKC_API.G_RET_STS_SUCCESS  Then


        l_currency_table_in   := l_currency_table_tmp ;
        l_currency_table_tmp.DELETE ;*/

        DELETE_DUPLICATE_CURRENCY_CODE (p_currency_table   => l_currency_table_in
                                        ,x_currency_table  => l_currency_table_tmp
                                        ,x_return_status   => l_return_status
                                        )  ;
                    x_return_status  := l_return_status ;
     /*   If l_return_status <>  OKC_API.G_RET_STS_SUCCESS Then
            x_return_status  := l_return_status ;
        End If;
  Else
        x_return_status  := l_return_status ;
  End If;*/


        x_currency_table_out  := l_currency_table_tmp ;

   Exception When Others then
      FND_FILE.PUT_LINE( FND_FILE.LOG, '*** Billing Report:: Get_Currency_code Error   ' || sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      OKC_API.SET_MESSAGE
            (P_App_Name         => G_APP_NAME
               ,P_Msg_Name      => G_UNEXPECTED_ERROR
               ,P_Token1        => G_SQLCODE_TOKEN
               ,P_Token1_Value  => SQLCODE
               ,P_Token2        => G_SQLERRM_TOKEN
               ,P_Token2_Value  => SQLERRM);

End Get_Currency_code;


/* *** --------------------------------------------- *** */


Procedure Print_currency_break ( p_currency_code      IN VARCHAR2
                           ,p_contracts_processed     IN NUMBER
                           ,p_lines_processed         IN NUMBER
                           ,p_lines_total             IN NUMBER
                           ,p_lines_success           IN NUMBER
                           ,p_lines_successtot        IN NUMBER
                           ,p_lines_rejected          IN NUMBER
                           ,p_rejected_lines_total    IN NUMBER
                           ,p_slines_processed        IN NUMBER
                           ,p_slines_total            IN NUMBER
                           ,p_slines_success          IN NUMBER
                           ,p_slines_successtot       IN NUMBER
                           ,p_slines_rejected         IN NUMBER
                           ,p_rejected_slines_total   IN NUMBER
                           ,x_return_status           OUT NOCOPY VARCHAR2
                           )  IS



  CURSOR l_currency (p_currency_code IN VARCHAR) is
  SELECT name FROM fnd_currencies_tl
  WHERE  currency_code = p_currency_code
  AND    language      = USERENV('LANG');


  l_dnz_chr_id            NUMBER    := 0;
  l_line_id               NUMBER    := 0;
  l_contracts_total       NUMBER    := 0;
  l_rejected_con_total    NUMBER    := 0;
  l_length                NUMBER    := 0;

  l_msg                   VARCHAR2(2000);
  l_cur_msg               VARCHAR2(2000);

  l_currency_desc         VARCHAR2(100);

Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  fnd_message.set_name ('OKS','OKS_BILLREP_CURRSUMM');
  l_msg := fnd_message.get;
  fnd_message.set_name ('OKS','OKS_BILLREP_CURVAL');
  l_cur_msg := fnd_message.get;

  OPEN  l_currency(p_currency_code);
  FETCH l_currency into l_currency_desc;
  CLOSE l_currency;


  l_contracts_total    := nvl(p_lines_total,0) + nvl(p_slines_total,0)  ;
  l_rejected_con_total := nvl(p_rejected_lines_total,0) + nvl(p_rejected_slines_total,0) ;
  l_length := length(l_currency_desc||l_msg);

 FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '               ' ) ;
 FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '               ' ) ;
 FND_FILE.PUT_LINE( FND_FILE.OUTPUT, l_msg||' '||l_currency_desc ) ;
 FND_FILE.PUT_LINE( FND_FILE.OUTPUT, rpad('====',l_length,'===' )) ;
 FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '               ' ) ;


 fnd_message.set_name ('OKS','OKS_BILLREP_CON_PROC');
 l_msg := fnd_message.get;

  fnd_message.set_name ('OKS','OKS_BILLREP_CON_PROC');
 l_msg := fnd_message.get;

--bug#4323607 maanand

 FND_FILE.PUT_LINE( FND_FILE.OUTPUT, rpad(l_msg||':',30,' ')||rpad(to_char(p_contracts_processed),10,' ')||' '||l_cur_msg||':  '||  to_char (l_contracts_total, fnd_currency.get_format_mask(p_currency_code, 50)));



 fnd_message.set_name ('OKS','OKS_BILLREP_LINE_PROC');
 l_msg := fnd_message.get;
 FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '                                    ') ;
 FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '                                    ') ;
 FND_FILE.PUT_LINE( FND_FILE.OUTPUT, rpad(l_msg||':',30,' ')||rpad(to_char(p_lines_processed),10,' ')||' '||l_cur_msg||':  '|| to_char (p_lines_total, fnd_currency.get_format_mask(p_currency_code, 50)));
 fnd_message.set_name ('OKS','OKS_BILLREP_LINE_SUCC');
 l_msg := fnd_message.get;
 FND_FILE.PUT_LINE( FND_FILE.OUTPUT, rpad(l_msg||':',30,' ')||rpad(to_char(p_lines_success),10,' ')||' '||l_cur_msg||':  '|| to_char (p_lines_successtot, fnd_currency.get_format_mask(p_currency_code, 50)));
 fnd_message.set_name ('OKS','OKS_BILLREP_LINE_REJ');
 l_msg := fnd_message.get;
 FND_FILE.PUT_LINE( FND_FILE.OUTPUT, rpad(l_msg||':',30,' ')||rpad(to_char(p_lines_rejected),10,' ')||' '||l_cur_msg||':  '||  to_char (p_rejected_lines_total, fnd_currency.get_format_mask(p_currency_code, 50)));


 FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '                                    ') ;
 FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '                                    ') ;
 fnd_message.set_name ('OKS','OKS_BILLREP_SUBLINE_PROC');
 l_msg := fnd_message.get;
 FND_FILE.PUT_LINE( FND_FILE.OUTPUT, rpad(l_msg||':',30,' ')||rpad(to_char(p_slines_processed),10,' ')||' '||l_cur_msg||':  '|| to_char (p_slines_total, fnd_currency.get_format_mask(p_currency_code, 50)));
 fnd_message.set_name ('OKS','OKS_BILLREP_SUBLINE_SUCC');
 l_msg := fnd_message.get;
 FND_FILE.PUT_LINE( FND_FILE.OUTPUT, rpad(l_msg||':',30,' ')||rpad(to_char(p_slines_success),10,' ')||' '||l_cur_msg||':  '|| to_char (p_slines_successtot, fnd_currency.get_format_mask(p_currency_code, 50)));
 fnd_message.set_name ('OKS','OKS_BILLREP_SUBLINE_REJ');
 l_msg := fnd_message.get;
 FND_FILE.PUT_LINE( FND_FILE.OUTPUT, rpad(l_msg||':',30,' ')||rpad(to_char(p_slines_rejected),10,' ')||' '||l_cur_msg||':  '|| to_char (p_rejected_slines_total, fnd_currency.get_format_mask(p_currency_code, 50)));


 FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '               ' ) ;
 FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '               ' ) ;
 FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '               ' ) ;

 Exception When Others Then
      x_return_status  :=  OKC_API.G_RET_STS_UNEXP_ERROR ;
      FND_FILE.PUT_LINE( FND_FILE.LOG, '*** Billing Report:: Print_currency_break Error   ' || sqlerrm);
      OKC_API.SET_MESSAGE
        (P_App_Name       => G_APP_NAME
        ,P_Msg_Name       => G_UNEXPECTED_ERROR
        ,P_Token1         => G_SQLCODE_TOKEN
        ,P_Token1_Value   => SQLCODE
        ,P_Token2         => G_SQLERRM_TOKEN
        ,P_Token2_Value   => SQLERRM);

End Print_currency_break;


/* *** --------------------------------------------- *** */


Procedure Print_Error_Report ( p_billrep_error_tbl      IN OKS_BILL_REC_PUB.billrep_error_tbl_type
                              ,p_lines_rejected         IN  Number
                              ,p_slines_rejected        IN  Number
                              ,x_return_status          OUT NOCOPY Varchar2
                             ) IS

  Cursor l_details_csr(p_line_id IN number) IS
    SELECT Hdr.Contract_number
         ,Hdr.Contract_number_modifier
         ,Hdr.Currency_code
         ,Hdr.Inv_organization_id
         ,Hdr.authoring_org_id
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
    FROM
          OKC_K_PARTY_ROLES_B  okp
         ,OKC_K_LINES_B  line
         ,OKC_K_HEADERS_B Hdr
  WHERE  Hdr.id          =  line.dnz_chr_id
  AND    line.id         =  p_line_id
  AND    okp.dnz_chr_id  =  hdr.id
  AND    okp.rle_code    in ( 'CUSTOMER','SUBSCRIBER');


  Cursor l_customer_csr(p_object1_id1 Number,p_object1_id2 Varchar2) IS
  Select cst.PARTY_NUMBER
         ,cst.NAME
  From OKX_PARTIES_V cst
  Where cst.id1 = p_object1_id1
    and cst.id2 = p_object1_id2 ;

  Cursor l_cont_group_csr(p_dnz_chr_id Number) IS
  Select grp.name
  From OKC_K_GROUPS_V grp
      ,OKC_K_GRPINGS gpg
  Where gpg.included_chr_id = p_dnz_chr_id
    and grp.id              = gpg.cgp_parent_id
    and rownum < 2 ;

  Cursor l_service_account_csr (p_line_id Number ) IS
   Select cst.PARTY_ID||' - '||cst.NAME ServiceAccount
   From OKC_RULE_GROUPS_V rgp
       ,OKC_RULES_V rul
       ,OKX_CUSTOMER_ACCOUNTS_V cst
   Where rgp.CLE_ID   = p_line_id
     and rgp.ID       = rul.RGP_ID
     and rul.RULE_INFORMATION_CATEGORY = 'CAN'
     and cst.ID1      = rul.OBJECT1_ID1
     and cst.ID2      = rul.OBJECT1_ID2 ;


  Cursor l_line_name_csr (p_line_id Number,p_organization_id Number) IS
  Select sys.NAME LineName
  From OKX_SYSTEM_ITEMS_V sys
      ,OKC_K_ITEMS itm
  Where itm.CLE_ID           =  p_line_id
    and sys.ID1              = itm.OBJECT1_ID1
    and sys.ID2              = itm.OBJECT1_ID2;


   Cursor l_sub_line_name_csr(p_sub_line_id Number) IS
    Select decode(itm.JTOT_OBJECT1_CODE,
                 'OKX_CUSTPROD',  'Covered Product',
                 'OKX_COVITEM',   'Covered Item',
                 'OKX_COVSITE',   'Covered Site',
                 'OKX_COVSYST',   'Covered System',
                 'OKX_CUSTACCT',  'Customer Account',
                 'OKX_PARTY',     'Covered Party',
                 itm.JTOT_OBJECT1_CODE) CoveredLine
            ,itm.JTOT_OBJECT1_CODE
            ,itm.object1_id1
            ,itm.object1_id2
  From OKC_K_ITEMS itm
  Where itm.CLE_ID = p_sub_line_id;

  l_line_idx              Binary_Integer;
  l_sub_line_idx          Binary_Integer;

  l_customer_number       Varchar2(30)  := Null;
  l_customer_name         Varchar2(360) := Null;
  l_group_name            Varchar2(150) := Null;
  l_service_account       Varchar2(360) := Null;
  l_line_name             Varchar2(360) := Null;
  l_covered_level         Varchar2(50)  := Null;
  l_sub_line_name         Varchar2(370) := Null;
  l_subline_obj1_id1      Varchar2(40)  := 0 ;
  l_subline_obj1_id2      Varchar2(3)   := Null;
  l_subline_jtot_code     Varchar2(30)  := Null;
  l_dnz_chr_id            Number        := 0;
  l_line_id               Number        := 0;
  l_contracts_total       Number        := 0;
  l_rejected_con_total    Number        := 0;

  l_cont_num              OKC_K_HEADERS_B.CONTRACT_NUMBER%type          := Null;
  l_cont_num_mod          OKC_K_HEADERS_B.CONTRACT_NUMBER_MODIFIER%type := Null ;
  l_bil_amt               Varchar2(16)  := Null ;
  l_line_num              Varchar2(300) := Null;

  l_string                 Varchar2(2000) := '    ' ;
  l_error_string1          Varchar2(2000) := Null;
  l_error_string2          Varchar2(2000) := Null;
  l_error_string3          Varchar2(2000) := Null;
  l_error_string4          Varchar2(2000) := Null;
  l_error_string5          Varchar2(2000) := Null;
  l_error_string6          Varchar2(2000) := Null;
  l_error_string7          Varchar2(2000) := Null;

  l_obj_id1                Number := 0;
  l_obj_id2                Varchar2(3) := Null;
  l_header_id              Number;

  detail_rec              l_details_csr%rowtype;


Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;


 /* *** ---- Print the error message ---- *** */

 If ((p_lines_rejected >= 1 AND p_billrep_error_tbl.count > 0 )or  (p_slines_rejected >= 1 AND p_billrep_error_tbl.count > 0) ) then

          FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '                                    ') ;
          FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '                                    ') ;
          FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '                                    ') ;
          FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '          Following are the Lines Rejected by Billing Program ') ;
          FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '          *************************************************** ') ;
          FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '                                    ') ;
          FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '                                    ') ;

 End If;


 If (p_lines_rejected >= 1 AND p_billrep_error_tbl.count > 0) then

          l_line_idx  := p_billrep_error_tbl.FIRST;
          l_dnz_chr_id   := 0;

          Loop

               If (p_billrep_error_tbl(l_line_idx).Sub_line_id is NULL)  then

                 OPEN  l_details_csr(p_billrep_error_tbl(l_line_idx).Top_Line_id);
                 FETCH l_details_csr INTO detail_rec;
                 CLOSE l_details_csr;


                 If l_dnz_chr_id <> detail_rec.dnz_chr_id then

                          Open l_customer_csr(detail_rec.object1_id1,detail_rec.object1_id2) ;
                          Fetch l_customer_csr into l_customer_number, l_customer_name ;
                          Close l_customer_csr ;

                          Open l_cont_group_csr(detail_rec.dnz_chr_id) ;
                          Fetch l_cont_group_csr into l_group_name ;
                          Close l_cont_group_csr ;

                          l_dnz_chr_id      := detail_rec.dnz_chr_id ;
                          l_cont_num        := detail_rec.Contract_number ;
                          l_cont_num_mod    := detail_rec.Contract_number_modifier ;

                          FND_FILE.PUT_LINE( FND_FILE.OUTPUT,'Contract: '||l_cont_num||' - '||l_cont_num_mod||'  Group:  '||l_group_name|| '  Customer:  '||l_customer_number||' - '||l_customer_name);

                    End If;

                    Open l_line_name_csr (p_billrep_error_tbl(l_line_idx).Top_Line_id,detail_rec.Inv_organization_id );
                    Fetch l_line_name_csr into l_line_name ;
                    Close l_line_name_csr;
                    Open l_service_account_csr (p_billrep_error_tbl(l_line_idx).Top_Line_id) ;
                    Fetch l_service_account_csr into l_service_account ;
                    Close l_service_account_csr;

                     l_bil_amt     := detail_rec.price_negotiated ;
                     l_line_num    := detail_rec.line_number ;

		    --  bug#4323607 maanand

		    FND_FILE.PUT_LINE( FND_FILE.OUTPUT,l_string||'Service Line: '||l_line_num||'  '||l_line_name||'   Service Account: '||l_service_account||'   For Amount: '|| to_char (l_bil_amt, fnd_currency.get_format_mask(detail_rec.currency_code, 50)));

                    l_error_string1  := 'Reason: '||substr(p_billrep_error_tbl(l_line_idx).Error_Message,1,50);
                    l_error_string2  := substr(p_billrep_error_tbl(l_line_idx).Error_Message,51,100);
                    l_error_string3  := substr(p_billrep_error_tbl(l_line_idx).Error_Message,101,150);
                    l_error_string4  := substr(p_billrep_error_tbl(l_line_idx).Error_Message,151,200);
                    l_error_string5  := substr(p_billrep_error_tbl(l_line_idx).Error_Message,201,250);
                    l_error_string6  := substr(p_billrep_error_tbl(l_line_idx).Error_Message,251,300);
                    l_error_string7  := substr(p_billrep_error_tbl(l_line_idx).Error_Message,301,350);

                    If length(l_error_string1) > 1 Then
                         FND_FILE.PUT_LINE( FND_FILE.OUTPUT,l_string||l_string||l_string||l_error_string1 );
                    End If;
                    If length(l_error_string2) > 1 Then
                         FND_FILE.PUT_LINE( FND_FILE.OUTPUT,l_string||l_string||l_string||l_error_string2);
                    End If;
                    If length(l_error_string3) > 1 Then
                         FND_FILE.PUT_LINE( FND_FILE.OUTPUT,l_string||l_string||l_string||l_error_string3);
                    End If;
                    If length(l_error_string4) > 1 Then
                         FND_FILE.PUT_LINE( FND_FILE.OUTPUT,l_string||l_string||l_string||l_error_string4);
                    End If;
                    If length(l_error_string5) > 1 Then
                         FND_FILE.PUT_LINE( FND_FILE.OUTPUT,l_string||l_string||l_string||l_error_string5);
                    End If;
                    If length(l_error_string6) > 1 Then
                         FND_FILE.PUT_LINE( FND_FILE.OUTPUT,l_string||l_string||l_string||l_error_string6);
                    End If;
                    If length(l_error_string7) > 1 Then
                         FND_FILE.PUT_LINE( FND_FILE.OUTPUT,l_string||l_string||l_string||l_error_string7);
                    End If;

               End If;
               EXIT WHEN l_line_idx = p_billrep_error_tbl.LAST;
               l_line_idx   := p_billrep_error_tbl.NEXT(l_line_idx) ;
          End Loop ;
 End If;

 If (p_slines_rejected >= 1 AND p_billrep_error_tbl.count > 0 ) then

          l_sub_line_idx    := p_billrep_error_tbl.FIRST;
          l_dnz_chr_id      := 0;
          l_line_id         := 0;
          l_line_name       := Null;
          l_service_account := Null;
          l_group_name      := Null;

          Loop

               If (p_billrep_error_tbl(l_sub_line_idx).Sub_line_id is NOT NULL)  then


                 OPEN  l_details_csr(p_billrep_error_tbl(l_sub_line_idx).Sub_line_id);
                 FETCH l_details_csr INTO detail_rec;
                 CLOSE l_details_csr;

                 /* *** Print Contract details *** */

                    If l_dnz_chr_id <> detail_rec.dnz_chr_id then


                          Open l_customer_csr(detail_rec.object1_id1 ,detail_rec.object1_id2);
                          Fetch l_customer_csr into l_customer_number, l_customer_name ;
                          Close l_customer_csr ;


                          Open l_cont_group_csr(detail_rec.dnz_chr_id) ;
                          Fetch l_cont_group_csr into l_group_name ;
                          Close l_cont_group_csr ;


                          l_dnz_chr_id     := detail_rec.dnz_chr_id ;
                          l_cont_num       := detail_rec.Contract_number ;
                          l_cont_num_mod   := detail_rec.Contract_number_modifier ;

                          FND_FILE.PUT_LINE( FND_FILE.OUTPUT,'Contract: '||l_cont_num||' - '||l_cont_num_mod||'  Group:  '||l_group_name||'  Customer: '||l_customer_number||' - '||l_customer_name);

                    End If;


                 /* *** Print Line details *** */

                    If l_line_id <>  p_billrep_error_tbl(l_sub_line_idx).Top_Line_id then

                          Open l_line_name_csr (p_billrep_error_tbl(l_sub_line_idx).Top_Line_id, detail_rec.Inv_organization_id);
                          Fetch l_line_name_csr into l_line_name ;
                          Close l_line_name_csr;

                           Open l_service_account_csr (p_billrep_error_tbl(l_sub_line_idx).Top_Line_id) ;
                           Fetch l_service_account_csr into l_service_account ;
                           Close l_service_account_csr;

                           l_bil_amt        := Null ;

                            select line_number into l_line_num from okc_k_lines_b
                            where id=p_billrep_error_tbl(l_sub_line_idx).Top_Line_id;

                           FND_FILE.PUT_LINE( FND_FILE.OUTPUT,l_string||'Service Line: '||l_line_num||'  '||l_line_name||'   Service Account: '||l_service_account ) ;

                          l_line_id  :=p_billrep_error_tbl(l_sub_line_idx).Top_Line_id;


                    End If;

                 /* *** Print Sub Line details *** */

                    Open l_sub_line_name_csr(p_billrep_error_tbl(l_sub_line_idx).Sub_line_id) ;
                         Fetch l_sub_line_name_csr into  l_covered_level
                                                        ,l_subline_jtot_code
                                                        ,l_subline_obj1_id1
                                                        ,l_subline_obj1_id2 ;
                    Close l_sub_line_name_csr;

                    l_sub_line_name  := '   Name: '||Sub_Line_Name (l_subline_jtot_code,to_number(l_subline_obj1_id1),l_subline_obj1_id2 );
                    l_bil_amt        := to_char(detail_rec.price_negotiated ) ;
                    l_line_num       := detail_rec.line_number;

                    FND_FILE.PUT_LINE( FND_FILE.OUTPUT,l_string||l_string||'Covered Line: '||l_line_num||'   '||l_covered_level||l_sub_line_name||' For Amount: '||l_bil_amt ) ;

                    l_error_string1  := 'Reason: '||substr(p_billrep_error_tbl(l_sub_line_idx).Error_Message,1,50);
                    l_error_string2  := substr(p_billrep_error_tbl(l_sub_line_idx).Error_Message,51,100);
                    l_error_string3  := substr(p_billrep_error_tbl(l_sub_line_idx).Error_Message,101,150);
                    l_error_string4  := substr(p_billrep_error_tbl(l_sub_line_idx).Error_Message,151,200);
                    l_error_string5  := substr(p_billrep_error_tbl(l_sub_line_idx).Error_Message,201,250);
                    l_error_string6  := substr(p_billrep_error_tbl(l_sub_line_idx).Error_Message,251,300);
                    l_error_string7  := substr(p_billrep_error_tbl(l_sub_line_idx).Error_Message,301,350);

                    If length(l_error_string1) > 1 Then
                         FND_FILE.PUT_LINE( FND_FILE.OUTPUT,l_string||l_string||l_string||l_error_string1 );
                    End If;
                    If length(l_error_string2) > 1 Then
                         FND_FILE.PUT_LINE( FND_FILE.OUTPUT,l_string||l_string||l_string||l_error_string2);
                    End If;
                    If length(l_error_string3) > 1 Then
                         FND_FILE.PUT_LINE( FND_FILE.OUTPUT,l_string||l_string||l_string||l_error_string3);
                    End If;
                    If length(l_error_string4) > 1 Then
                         FND_FILE.PUT_LINE( FND_FILE.OUTPUT,l_string||l_string||l_string||l_error_string4);
                    End If;
                    If length(l_error_string5) > 1 Then
                         FND_FILE.PUT_LINE( FND_FILE.OUTPUT,l_string||l_string||l_string||l_error_string5);
                    End If;
                    If length(l_error_string6) > 1 Then
                         FND_FILE.PUT_LINE( FND_FILE.OUTPUT,l_string||l_string||l_string||l_error_string6);
                    End If;
                    If length(l_error_string7) > 1 Then
                         FND_FILE.PUT_LINE( FND_FILE.OUTPUT,l_string||l_string||l_string||l_error_string7);
                    End If;

               End If;
               EXIT WHEN l_sub_line_idx = p_billrep_error_tbl.LAST;
               l_sub_line_idx  := p_billrep_error_tbl.NEXT(l_sub_line_idx) ;
          End Loop;
  End If;



   Exception When Others Then
      x_return_status  :=  OKC_API.G_RET_STS_UNEXP_ERROR ;
      FND_FILE.PUT_LINE( FND_FILE.LOG, '*** Billing Report:: Print_Error_Report    ' || sqlerrm);
      OKC_API.SET_MESSAGE
        (P_App_Name       => G_APP_NAME
        ,P_Msg_Name       => G_UNEXPECTED_ERROR
        ,P_Token1         => G_SQLCODE_TOKEN
        ,P_Token1_Value   => SQLCODE
        ,P_Token2         => G_SQLERRM_TOKEN
        ,P_Token2_Value   => SQLERRM);

End Print_Error_Report;


/* *** --------------------------------------------- *** */

Procedure Create_Report (
          p_billrep_table       IN OKS_BILL_REC_PUB.bill_report_tbl_type
         ,p_billrep_err_tbl     IN OKS_BILL_REC_PUB.billrep_error_tbl_type
         ,p_line_from           IN NUMBER
         ,p_line_to             IN NUMBER
         ,x_return_status      OUT NOCOPY Varchar2
         )   IS



  CURSOR Contract_Cnt_Csr(p_code in Varchar2,p_process_from IN NUMBER,p_process_to IN NUMBER) IS
  SELECT Count(Distinct Chr_id)
  FROM   oks_process_billing
  where currency_code= p_code
  and   line_no between p_process_from and p_process_to;

  l_return_status           Varchar2(100);

  l_Sublines_count          Number := 0;
  l_Sublines_value          Number := 0;

  l_lines_value             Number := 0;
  l_lines_count             Number := 0;

  l_lines_rejected          Number  := 0;
  l_slines_rejected         Number := 0;

  l_contracts_processed     Number := 0;

  i                         Number := 0;
  l_msg                     Varchar2(2000);
  l_curr_break_line         Varchar2(2000) := '==============================================================================================================';

  Create_Report_Exception  Exception ;

Begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  l_return_status := Null;



 fnd_message.set_name('OKS','OKS_BILLREP_TITLE');
 l_msg := fnd_message.get;
 FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '                                    ') ;
 FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '                                    ') ;
 FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '                                    ') ;
 FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '                                          '|| l_msg ||' ') ;
 FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '                                          **************************************** ') ;

 FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '                                    ') ;
 FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '                                    ') ;
   /* *** Print the currency break up for each currency  *** */


  --Start mchoudha Bug#3537100 17-APR-04
  --For Billing Report



    IF (p_billrep_table.count > 0) THEN
    i := p_billrep_table.FIRST;
    LOOP

      OPEN Contract_Cnt_Csr(p_billrep_table(i).Currency_code,p_line_from,p_line_to);
      FETCH Contract_Cnt_Csr into l_contracts_processed;
      CLOSE Contract_Cnt_Csr;


      l_Sublines_count := p_billrep_table(i).Successful_SubLines + p_billrep_table(i).Rejected_SubLines ;


      l_Sublines_value := p_billrep_table(i).Successful_SubLines_Value +
                                                    p_billrep_table(i).Rejected_SubLines_Value ;

      l_lines_value    := p_billrep_table(i).Successful_Lines_Value + p_billrep_table(i).Rejected_Lines_Value;

      l_lines_count    := p_billrep_table(i).Successful_Lines +  p_billrep_table(i).Rejected_Lines;

      l_slines_rejected := l_slines_rejected + p_billrep_table(i).Rejected_SubLines;
      l_lines_rejected := l_lines_rejected + p_billrep_table(i).Rejected_Lines;

      PRINT_CURRENCY_BREAK ( p_currency_code          => p_billrep_table(i).Currency_code
                             ,p_contracts_processed    => l_contracts_processed
                             ,p_lines_processed        =>l_lines_count
                             ,p_lines_total            => l_lines_value
                             ,p_lines_success          => p_billrep_table(i).Successful_Lines
                             ,p_lines_successtot       => p_billrep_table(i).Successful_Lines_Value
                             ,p_lines_rejected         => p_billrep_table(i).Rejected_Lines
                             ,p_rejected_lines_total   => p_billrep_table(i).Rejected_Lines_Value
                             ,p_slines_processed       => l_Sublines_count
                             ,p_slines_total           => l_Sublines_value
                             ,p_slines_success         => p_billrep_table(i).Successful_SubLines
                             ,p_slines_successtot      => p_billrep_table(i).Successful_SubLines_Value
                             ,p_slines_rejected        => p_billrep_table(i).Rejected_SubLines
                             ,p_rejected_slines_total  => p_billrep_table(i).Rejected_SubLines_Value
                              ,x_return_status          => l_return_status
                             )  ;

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        FND_FILE.PUT_LINE( FND_FILE.LOG, '*** Billing Report:: PRINT_CURRENCY_BREAK procedure failed for :  ' || p_billrep_table(i).Currency_code ||'   Error:  '||sqlerrm);
        x_return_status  := l_return_status ;
        Raise Create_Report_Exception ;
      END IF;

      EXIT WHEN i = p_billrep_table.LAST;
      i := p_billrep_table.NEXT(i);
    END LOOP;
    END IF;




 FND_FILE.PUT_LINE( FND_FILE.OUTPUT,l_curr_break_line); /* print a line after the currency summary */


 /* -- Procedure call to print the error report */

 --l_sub_lines_tbl_in := l_sub_lines_tbl_out ;
 --l_lines_tbl_in     := l_lines_tbl_out ;



  PRINT_ERROR_REPORT ( p_billrep_error_tbl        =>  p_billrep_err_tbl
                      ,p_lines_rejected         =>  l_lines_rejected
                      ,p_slines_rejected        =>  l_slines_rejected
                      ,x_return_status          =>  l_return_status
                      ) ;

  IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
    x_return_status  := l_return_status ;
    Raise Create_Report_Exception ;
  END IF;


  EXCEPTION

   WHEN Create_Report_Exception Then
      x_return_status  :=  OKC_API.G_RET_STS_UNEXP_ERROR ;
      FND_FILE.PUT_LINE( FND_FILE.LOG, '***** Billing Report has errors :: Report Exception *****    '||sqlerrm) ;
      FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '*** Billing Report has errors **** '||sqlerrm);
      OKC_API.SET_MESSAGE
           (P_App_Name         => G_APP_NAME
            ,P_Msg_Name      => G_UNEXPECTED_ERROR
            ,P_Token1        => G_SQLCODE_TOKEN
            ,P_Token1_Value  => SQLCODE
            ,P_Token2        => G_SQLERRM_TOKEN
            ,P_Token2_Value  => SQLERRM);

   WHEN Others Then
      x_return_status  :=  OKC_API.G_RET_STS_UNEXP_ERROR ;
      FND_FILE.PUT_LINE( FND_FILE.LOG, '***** Billing Report has errors :: When Others  *****    '||sqlerrm) ;
      FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '*** Billing Report has errors **** '||sqlerrm);
      OKC_API.SET_MESSAGE
           (P_App_Name       => G_APP_NAME
            ,P_Msg_Name      => G_UNEXPECTED_ERROR
            ,P_Token1        => G_SQLCODE_TOKEN
            ,P_Token1_Value  => SQLCODE
            ,P_Token2        => G_SQLERRM_TOKEN
            ,P_Token2_Value  => SQLERRM);

End Create_Report ;


/* *** --------------------------------------------- *** */


PROCEDURE UPDATE_OKS_LEVEL_ELEMENTS
    ( p_line_id IN number ,
      x_return_status OUT NOCOPY varchar2 ) IS

    CURSOR L_OKS_LEVEL_ELEMENTS_CSR ( P_LINE_ID in  NUMBER ) IS
    SELECT LEVL.ID
      FROM OKS_LEVEL_ELEMENTS LEVL ,
           OKC_RULES_B        RULES ,
           OKC_RULE_GROUPS_B  RGP
     WHERE LEVL.RUL_ID = RULES.ID
       AND RULES.RGP_ID = RGP.ID
       AND RULE_INFORMATION_CATEGORY = 'SLL'
       AND RGP.CLE_ID = P_LINE_ID
       AND LEVL.DATE_COMPLETED IS NULL ;

    CURSOR L_GET_SUB_LINES_CSR ( P_TOP_LINE_ID IN NUMBER ) IS
    SELECT LINES.ID
      FROM OKC_K_LINES_V LINES
     WHERE LINES.CLE_ID = P_TOP_LINE_ID
       AND LINES.LSE_ID in (9, 25 );

     L_OKS_LEVEL_ELEMENTS_REC  L_OKS_LEVEL_ELEMENTS_CSR%ROWTYPE ;
     L_GET_SUB_LINES_REC       L_GET_SUB_LINES_CSR%ROWTYPE ;

     SUBTYPE LEVEL_ID_TBL IS OKS_BILL_LEVEL_ELEMENTS_PVT.letv_tbl_type ;
     L_LEVEL_ID_TBL_IN   LEVEL_ID_TBL ;
     L_LEVEL_ID_TBL_OUT  LEVEL_ID_TBL ;
     l_return_status     Varchar2(1):= OKC_API.G_RET_STS_SUCCESS;
     l_msg_count         number;
     l_msg_data          Varchar2(2000);
     COUNTER             NUMBER := 0 ;
     G_EXCEPTION_HALT_VALIDATION exception ;


BEGIN


/*************************************************************************************
       --THIS WILL POPULATE THE TABLE WITH THE LEVEL ELEMENTS OF TOP LINE..
       FOR L_OKS_LEVEL_ELEMENTS_REC IN L_OKS_LEVEL_ELEMENTS_CSR ( P_LINE_ID )
       LOOP
           L_LEVEL_ID_TBL_IN(COUNTER).ID := L_OKS_LEVEL_ELEMENTS_REC.ID  ;
           L_LEVEL_ID_TBL_IN(COUNTER).DATE_COMPLETED := SYSDATE;
           COUNTER := COUNTER+1 ;
       END LOOP ;

       FOR L_GET_SUB_LINES_REC IN L_GET_SUB_LINES_CSR( P_LINE_ID )
       LOOP
           FOR L_OKS_LEVEL_ELEMENTS_REC IN L_OKS_LEVEL_ELEMENTS_CSR ( L_GET_SUB_LINES_REC.ID )
           LOOP
               L_LEVEL_ID_TBL_IN(COUNTER).ID := L_OKS_LEVEL_ELEMENTS_REC.ID  ;
               L_LEVEL_ID_TBL_IN(COUNTER).DATE_COMPLETED := SYSDATE;
               COUNTER := COUNTER+1 ;
           END LOOP ;
       END LOOP  ;



       IF ( L_LEVEL_ID_TBL_IN.COUNT > 0 ) THEN

           oks_bill_level_elements_pvt.update_row
             (p_api_version              => 1.0,
              p_init_msg_list            => 'T',
              x_return_status            => l_return_status,
              x_msg_count                => l_msg_count,
              x_msg_data                 => l_msg_data,
              p_letv_tbl                 => L_LEVEL_ID_TBL_IN,
              x_letv_tbl                 => L_LEVEL_ID_TBL_OUT);


           IF (l_return_status <> 'S') THEN
               x_return_status := l_return_status;
               Raise G_EXCEPTION_HALT_VALIDATION;
           END IF;
       END IF ;
***************************************************************************************/
 Update oks_level_elements
   set date_completed = SYSDATE
 where parent_cle_id = p_line_id
   and date_completed is null;


      X_RETURN_STATUS := L_RETURN_STATUS ;

   EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
        X_RETURN_STATUS  := L_RETURN_STATUS ;
      WHEN OTHERS THEN
        X_RETURN_STATUS := OKC_API.G_RET_STS_UNEXP_ERROR;
        OKC_API.SET_MESSAGE(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

END  UPDATE_OKS_LEVEL_ELEMENTS ;


PROCEDURE  CREATE_BCL_FOR_OM ( P_LINE_ID  IN  NUMBER ,
                               X_RETURN_STATUS  OUT NOCOPY VARCHAR2 ) IS

  CURSOR L_GET_OKS_LINES_CSR( P_LINE_ID NUMBER ) IS
         SELECT TRUNC(LINE.START_DATE) LINE_START_DATE
               ,TRUNC(LINE.END_DATE)   LINE_END_DATE
               ,LINE.ID
               ,LINE.DNZ_CHR_ID
           FROM OKC_K_LINES_B LINE
          WHERE LINE.ID = P_LINE_ID ;

  CURSOR L_GET_BCL_LINES_CSR ( P_LINE_ID NUMBER ) IS
         SELECT BCL.ID ,
                TRUNC(BCL.DATE_BILLED_FROM) DATE_BILLED_FROM ,
                TRUNC(BCL.DATE_BILLED_TO)   DATE_BILLED_TO,
                AMOUNT BCL_AMOUNT
           FROM OKS_BILL_CONT_LINES BCL
          WHERE BCL.CLE_ID = P_LINE_ID ;

  CURSOR l_hdr_csr(p_hdr_id  NUMBER) IS
       SELECT currency_code
       FROM okc_k_headers_b
       WHERE id = p_HDR_id;

  L_GET_OKS_LINES_REC       L_GET_OKS_LINES_CSR%ROWTYPE ;
  L_GET_BCL_LINES_REC       L_GET_BCL_LINES_CSR%ROWTYPE ;

  SUBTYPE BCLV_REC_TYPE IS OKS_BILLCONT_PVT.BCLV_REC_TYPE;
  L_BCLV_REC_IN   BCLV_REC_TYPE ;
  L_BCLV_REC_OUT  BCLV_REC_TYPE;

  L_BCLV_REC_UPD_IN   BCLV_REC_TYPE ;
  L_BCLV_REC_UPD_OUT  BCLV_REC_TYPE ;



  L_BCL_EXISTS BOOLEAN ;
  L_BCL_DATES_UPDATE BOOLEAN ;
  L_SUB_LINES_INSERTED  NUMBER ;
  L_RETURN_STATUS  VARCHAR2(4):= OKC_API.G_RET_STS_SUCCESS;
  L_MSG_CNT  NUMBER ;
  L_MSG_DATA VARCHAR2(2000);
  L_TOTAL_AMOUNT NUMBER := 0 ;
  L_LINE_ID NUMBER ;
  L_BCL_ID NUMBER ;
  l_Currency  VARCHAR2(15);


BEGIN
    OPEN  L_GET_OKS_LINES_CSR(P_LINE_ID ) ;
    FETCH L_GET_OKS_LINES_CSR INTO L_GET_OKS_LINES_REC ;
    CLOSE L_GET_OKS_LINES_CSR ;

    OPEN  L_GET_BCL_LINES_CSR(P_LINE_ID ) ;
    FETCH L_GET_BCL_LINES_CSR INTO L_GET_BCL_LINES_REC ;
    IF L_GET_BCL_LINES_CSR%FOUND THEN
       L_BCL_EXISTS := TRUE;
           IF ( L_GET_OKS_LINES_REC.LINE_START_DATE <> L_GET_BCL_LINES_REC.DATE_BILLED_FROM  OR
                L_GET_OKS_LINES_REC.LINE_END_DATE   <> L_GET_BCL_LINES_REC.DATE_BILLED_TO ) THEN
                L_BCL_DATES_UPDATE := TRUE ;
           ELSE
                 L_BCL_DATES_UPDATE := FALSE ;
           END IF ;
    ELSE
       L_BCL_EXISTS := FALSE;
    END IF ;
    CLOSE L_GET_BCL_LINES_CSR ;



    --THIS WILL CREATE BCL ENTRY IF ONE DOSENT EXISTS ..
    IF NOT L_BCL_EXISTS THEN
         OPEN l_hdr_csr(L_GET_OKS_LINES_REC.dnz_chr_id);
         FETCH l_hdr_csr INTO l_Currency;

         IF l_hdr_csr%NOTFOUND THEN
           l_Currency := NULL;
         END IF;
         CLOSE l_hdr_csr;


         L_BCLV_REC_IN.CLE_ID            := L_GET_OKS_LINES_REC.ID;
         L_BCLV_REC_IN.DATE_BILLED_FROM  := L_GET_OKS_LINES_REC.LINE_START_DATE;
         L_BCLV_REC_IN.DATE_BILLED_TO    := L_GET_OKS_LINES_REC.LINE_END_DATE ;
         L_BCLV_REC_IN.DATE_NEXT_INVOICE := NULL;
         L_BCLV_REC_IN.BILL_ACTION       := 'RI';
         L_BCLV_REC_IN.SENT_YN           := 'N';
         L_BCLV_REC_IN.BTN_ID            := -44;
         L_BCLV_REC_IN.currency_code     := l_Currency;

         OKS_BILLCONTLINE_PUB.INSERT_BILL_CONT_LINE(
             P_API_VERSION                  =>  1.0,
             P_INIT_MSG_LIST                =>  'T',
             X_RETURN_STATUS                =>   L_RETURN_STATUS,
             X_MSG_COUNT                    =>   L_MSG_CNT,
             X_MSG_DATA                     =>   L_MSG_DATA,
             P_BCLV_REC                     =>   L_BCLV_REC_IN,
             X_BCLV_REC                     =>   L_BCLV_REC_OUT
             );

         IF NOT L_RETURN_STATUS = OKC_API.G_RET_STS_SUCCESS THEN
                X_RETURN_STATUS := L_RETURN_STATUS;
                RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;
    END IF ;


    IF L_BCL_EXISTS THEN
       L_BCL_ID  := L_GET_BCL_LINES_REC.ID ;
    ELSE
       L_BCL_ID  := L_BCLV_REC_OUT.ID ;
    END IF ;


    IF L_RETURN_STATUS = OKC_API.G_RET_STS_SUCCESS THEN
         L_LINE_ID := P_LINE_ID ;
         CREATE_BSL_FOR_OM( P_LINE_ID            => L_LINE_ID ,
                            P_BCL_ID             => L_BCL_ID   ,
                            X_RETURN_STATUS      => L_RETURN_STATUS,
                            X_SUB_LINES_INSERTED => L_SUB_LINES_INSERTED,
                            X_TOTAL_AMOUNT       => L_TOTAL_AMOUNT) ;
         IF NOT L_RETURN_STATUS = OKC_API.G_RET_STS_SUCCESS THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF ;
    END IF ;


    --THIS WILL UPDATE THE BCL LINE ENTRY IF THE DATES DIFFER FROM THAT OF THE TOP LINE DATES..
    --OR FOR THE UPDATE OF AMOUNT IN BCL ..

    L_GET_BCL_LINES_REC.BCL_AMOUNT := NVL(L_GET_BCL_LINES_REC.BCL_AMOUNT , 0 ) ;
    L_TOTAL_AMOUNT                 := NVL(L_TOTAL_AMOUNT , 0 );

    IF L_SUB_LINES_INSERTED > 0 OR  L_BCL_DATES_UPDATE THEN
       IF L_SUB_LINES_INSERTED > 0 THEN
          L_BCLV_REC_UPD_IN.ID     := L_BCL_ID;
          L_BCLV_REC_UPD_IN.AMOUNT := L_TOTAL_AMOUNT + L_GET_BCL_LINES_REC.BCL_AMOUNT ;
          L_TOTAL_AMOUNT := 0 ;
       END IF ;
       IF L_BCL_DATES_UPDATE THEN
          L_BCLV_REC_UPD_IN.DATE_BILLED_FROM    :=L_GET_OKS_LINES_REC.LINE_START_DATE;
          L_BCLV_REC_UPD_IN.DATE_BILLED_TO      :=L_GET_OKS_LINES_REC.LINE_END_DATE ;
       END IF ;


          OKS_BILLCONTLINE_PUB.UPDATE_BILL_CONT_LINE
            (
             P_API_VERSION                  =>  1.0,
             P_INIT_MSG_LIST                =>  'T',
             X_RETURN_STATUS                =>   L_RETURN_STATUS,
             X_MSG_COUNT                    =>   L_MSG_CNT,
             X_MSG_DATA                     =>   L_MSG_DATA,
             P_BCLV_REC                     =>   L_BCLV_REC_UPD_IN,
             X_BCLV_REC                     =>   L_BCLV_REC_UPD_OUT
            );
           IF NOT L_RETURN_STATUS = OKC_API.G_RET_STS_SUCCESS THEN
              X_RETURN_STATUS := L_RETURN_STATUS;
              RAISE G_EXCEPTION_HALT_VALIDATION;
           END IF;
    END IF ;

    IF L_RETURN_STATUS = OKC_API.G_RET_STS_SUCCESS THEN
         UPDATE_OKS_LEVEL_ELEMENTS(L_GET_OKS_LINES_REC.id ,
                                    X_RETURN_STATUS );
        IF (L_RETURN_STATUS <> 'S') THEN
            X_RETURN_STATUS := L_RETURN_STATUS;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
    END IF ;

   X_RETURN_STATUS := L_RETURN_STATUS;

EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
        X_RETURN_STATUS  := l_return_status ;
When Others Then
  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

END CREATE_BCL_FOR_OM ;


PROCEDURE CREATE_BSL_FOR_OM ( P_LINE_ID  IN NUMBER ,
                              P_BCL_ID   IN NUMBER ,
                              X_RETURN_STATUS OUT NOCOPY VARCHAR2 ,
                              X_SUB_LINES_INSERTED OUT NOCOPY NUMBER ,
                              X_TOTAL_AMOUNT  OUT NOCOPY NUMBER ) IS

  CURSOR L_GET_COVERED_LEVELS_CSR (P_LINE_ID NUMBER ) IS
         SELECT LINES.ID ,
                LINES.START_DATE COVERED_LEVEL_START_DATE,
                LINES.END_DATE COVERED_LEVEL_END_DATE,
                LINES.PRICE_NEGOTIATED
           FROM OKC_K_LINES_B LINES
          WHERE LINES.CLE_ID = P_LINE_ID
            AND LINES.LSE_ID in (9, 25) ;

 CURSOR l_get_itm_uom_csr(p_cp_id   NUMBER) IS
        SELECT uom_code
        FROM okc_k_items
        WHERE cle_id = p_cp_id;

 CURSOR L_GET_BSL_CSR ( P_ID NUMBER ) IS
        SELECT 1
          FROM OKS_BILL_SUB_LINES
         WHERE CLE_ID = P_ID ;

  l_get_itm_uom_rec         l_get_itm_uom_csr%ROWTYPE;
  L_GET_COVERED_LEVELS_REC  L_GET_COVERED_LEVELS_CSR%ROWTYPE ;
  L_GET_BSL_REC            L_GET_BSL_CSR%ROWTYPE ;

  SUBTYPE BSLV_REC_TYPE IS OKS_BILLSUBLINE_PVT.BSLV_REC_TYPE;
  L_BSLV_REC_IN   BSLV_REC_TYPE ;
  L_BSLV_REC_OUT  BSLV_REC_TYPE;

---for bill_sub_line_dtl
  SUBTYPE bsdv_rec_type IS OKS_BSL_DET_PVT.bsdv_rec_type;
  l_bsdv_rec_in    bsdv_rec_type;
  l_bsdv_rec_out   bsdv_rec_type;

  L_RETURN_STATUS VARCHAR2(4);
  L_MSG_CNT NUMBER ;
  L_MSG_DATA VARCHAR2(2000) ;
  L_SUB_LINES_INSERTED NUMBER := 0;
  L_TOTAL_AMOUNT  NUMBER := 0 ;



BEGIN
  X_RETURN_STATUS := OKC_API.G_RET_STS_SUCCESS ;
   FOR L_GET_COVERED_LEVELS_REC IN L_GET_COVERED_LEVELS_CSR(P_LINE_ID )
    LOOP
        OPEN L_GET_BSL_CSR( L_GET_COVERED_LEVELS_REC.ID );
        FETCH L_GET_BSL_CSR INTO L_GET_BSL_REC ;
        IF L_GET_BSL_CSR%NOTFOUND THEN
              L_BSLV_REC_IN.CLE_ID                := L_GET_COVERED_LEVELS_REC.ID;
              L_BSLV_REC_IN.BCL_ID                := P_BCL_ID;
              L_BSLV_REC_IN.DATE_BILLED_FROM      := L_GET_COVERED_LEVELS_REC.COVERED_LEVEL_START_DATE;
              L_BSLV_REC_IN.DATE_BILLED_TO        := L_GET_COVERED_LEVELS_REC.COVERED_LEVEL_END_DATE;
              L_BSLV_REC_IN.AMOUNT                := L_GET_COVERED_LEVELS_REC.PRICE_NEGOTIATED;
              L_BSLV_REC_IN.AVERAGE               := 0;
              ------------------------------------------------------------------------------
              --HERE ITS CALLS THE PROCEDURE TO INSERT LINES INTO OKS_BILL_SUB_LINES.
              ------------------------------------------------------------------------------
              OKS_BILLSUBLINE_PUB.INSERT_BILL_SUBLINE_PUB
              (
                P_API_VERSION                  =>  1.0,
                P_INIT_MSG_LIST                =>  'T',
                X_RETURN_STATUS                =>   L_RETURN_STATUS,
                X_MSG_COUNT                    =>   L_MSG_CNT,
                X_MSG_DATA                     =>   L_MSG_DATA,
                P_BSLV_REC                     =>   L_BSLV_REC_IN,
                X_BSLV_REC                     =>   L_BSLV_REC_OUT
              );

              IF NOT L_RETURN_STATUS = OKC_API.G_RET_STS_SUCCESS THEN
                 RAISE G_EXCEPTION_HALT_VALIDATION;
              ELSE
                 L_SUB_LINES_INSERTED := L_SUB_LINES_INSERTED + 1  ;
                 L_TOTAL_AMOUNT := L_TOTAL_AMOUNT + L_GET_COVERED_LEVELS_REC.PRICE_NEGOTIATED ;
              END IF;

              ---create rec in oks_subline_bill_dtl table.


              ----Get the item uom from okc_k_items
              OPEN L_GET_ITM_UOM_CSR( L_GET_COVERED_LEVELS_REC.ID );
              FETCH L_GET_ITM_UOM_CSR INTO L_GET_ITM_UOM_rec ;
              IF L_GET_ITM_UOM_CSR%NOTFOUND THEN
                 CLOSE L_GET_ITM_UOM_CSR;
                 l_return_status  :=  'E' ;
                 RAISE G_EXCEPTION_HALT_VALIDATION;
              ELSE
                 CLOSE L_GET_ITM_UOM_CSR;
              END IF;            --chk for rec found

              l_bsdv_rec_in.bsl_id            := L_BSLV_REC_OUT.id;
              l_bsdv_rec_in.amount            := L_BSLV_REC_IN.amount;
              l_bsdv_rec_in.unit_of_measure   := L_GET_ITM_UOM_rec.uom_code;
              l_bsdv_rec_in.amcv_yn           := 'N';
              l_bsdv_rec_in.result            := 1;


              OKS_BSL_det_PUB.insert_bsl_det_Pub
                       (
                      P_API_VERSION                  =>  1.0,
                      P_INIT_MSG_LIST                =>  'T',
                      X_RETURN_STATUS                =>   l_RETURN_STATUS,
                      X_MSG_COUNT                    =>   l_msg_cnt,
                      X_MSG_DATA                     =>   l_msg_data,
                      p_bsdv_rec                     =>   l_bsdv_rec_in,
                      x_bsdv_rec                     =>   l_bsdv_rec_out);

             IF NOT l_RETURN_STATUS = OKC_API.G_RET_STS_SUCCESS THEN
                 RAISE G_EXCEPTION_HALT_VALIDATION;
             END IF;          --chk for status


        END IF ;
        CLOSE L_GET_BSL_CSR ;
    END LOOP ;
    X_TOTAL_AMOUNT :=  L_TOTAL_AMOUNT ;
    X_SUB_LINES_INSERTED := L_SUB_LINES_INSERTED ;



EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
        X_RETURN_STATUS  := L_RETURN_STATUS ;
     When Others Then
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

END CREATE_BSL_FOR_OM ;

---This will give the billed qty for subcription line

Function Get_Billed_Qty ( p_line_id              IN  Number,
                         x_return_status   OUT NOCOPY VARCHAR2)
return Number

IS

l_tot_amt       NUMBER;
l_billed_amt    NUMBER;
l_tot_qty       Number;
l_billed_qty    NUMBER;


CURSOR l_line_amt_csr IS
       SELECT nvl(price_negotiated,0) amt
       FROM okc_k_lines_b
       WHERE id = p_line_id ;

CURSOR l_billed_amt_csr IS
       SELECT nvl(SUM(AMOUNT),0) tot_amt
       FROM OKS_BILL_CONT_LINES
       WHERE cle_id = p_line_id ;

CURSOR l_tot_Qty_csr IS
       SELECT SUM(QUANTITY) qty
       FROM OKS_SUBSCR_ELEMENTS
       WHERE dnz_cle_id = p_line_id ;

CURSOR l_subscription_type_csr IS
       SELECT item_type
       FROM OKS_SUBSCR_HEADER_B
       WHERE cle_id = p_line_id;

l_line_amt_rec           l_line_amt_csr%ROWTYPE;
l_billed_amt_rec         l_billed_amt_csr%ROWTYPE;
l_tot_Qty_rec            l_tot_Qty_csr%ROWTYPE;
l_subscription_type_rec  l_subscription_type_csr%ROWTYPE;
l_sub_item_type          VARCHAR2(10);


BEGIN

x_return_status := OKC_API.G_RET_STS_SUCCESS;

Open l_subscription_type_csr;
Fetch l_subscription_type_csr Into l_subscription_type_rec;

If l_subscription_type_csr%Notfound then
   Close l_subscription_type_csr;
   l_sub_item_type := 'NA';
End If;
Close l_subscription_type_csr;

l_sub_item_type := l_subscription_type_rec.item_type;

--if item_type <> 'ST' , total qty can not be found.
--for this release it will return null.

IF nvl(l_sub_item_type,'NA') <> 'ST' THEN
        RETURN NULL ;
END IF;


Open l_line_amt_csr;
Fetch l_line_amt_csr Into l_line_amt_rec;

If l_line_amt_csr%Notfound then
    Close l_line_amt_csr;
    x_return_status := 'E';
    RAISE G_EXCEPTION_HALT_VALIDATION;
end if;
l_tot_amt := l_line_amt_rec.amt;
Close l_line_amt_csr;

---ERROROUT_AD('l_tot_amt = '|| l_tot_amt);

Open l_billed_amt_csr;
Fetch l_billed_amt_csr Into l_billed_amt_rec;

If l_billed_amt_csr%Notfound then
    Close l_billed_amt_csr;
    x_return_status := 'E';
    RAISE G_EXCEPTION_HALT_VALIDATION;
end if;

l_billed_amt := l_billed_amt_rec.tot_amt;
Close l_billed_amt_csr;
---ERROROUT_AD('l_billed_amt = '|| l_billed_amt);

Open l_tot_Qty_csr;
Fetch l_tot_Qty_csr Into l_tot_Qty_rec;

If l_tot_Qty_csr%Notfound then
    Close l_tot_Qty_csr;
    x_return_status := 'E';
    RAISE G_EXCEPTION_HALT_VALIDATION;
end if;
l_tot_Qty := l_tot_Qty_REC.qty;
Close l_tot_Qty_csr;
---ERROROUT_AD('l_tot_Qty = '|| l_tot_Qty);

IF nvl(l_tot_amt,0) = 0 THEN
  l_billed_qty := 0;
ELSE
  l_billed_qty := ( nvl(l_tot_qty,0) * nvl(l_billed_amt,0) )/ l_tot_amt ;
END IF;

RETURN l_billed_qty;


EXCEPTION
 WHEN G_EXCEPTION_HALT_VALIDATION THEN
  RETURN NULL;

 WHEN OTHERS THEN
   OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
   RETURN NULL;
   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END Get_Billed_Qty;

  Function Get_Billed_Upto ( p_id      IN Number,
                             p_level   IN Varchar2
                           ) Return Date IS
    Cursor l_hdr_bill_cont_lines_csr IS
       Select Trunc(Max(date_billed_to))
       From oks_bill_cont_lines
       Where cle_id In
          ( Select id
            From okc_k_lines_b
            Where dnz_chr_id = p_id
            And lse_id In(1,12,14,19,46)
          );

    Cursor l_bill_cont_line_csr Is
       Select Trunc(Max(date_billed_to))
       From oks_bill_cont_lines
       Where cle_id = p_id;

    Cursor l_bill_sub_line_csr IS
       Select Trunc(Max(date_billed_to))
       From oks_bill_sub_lines
       Where cle_id = p_id;

    l_billed_upto Date := Null;
  Begin
    IF p_level = 'H' THEN    -- HEADER
      OPEN l_hdr_bill_cont_lines_csr;
      FETCH l_hdr_bill_cont_lines_csr INTO l_billed_upto;
      CLOSE l_hdr_bill_cont_lines_csr;
    ELSIF p_level = 'T' THEN -- TOP LINE
      OPEN l_bill_cont_line_csr;
      FETCH l_bill_cont_line_csr INTO l_billed_upto;
      CLOSE l_bill_cont_line_csr;
    ELSIF p_level = 'S' THEN -- SUB LINE
     OPEN l_bill_sub_line_csr;
     FETCH l_bill_sub_line_csr INTO l_billed_upto;
     CLOSE l_bill_sub_line_csr;
    END IF;
    return l_billed_upto;
  Exception
    WHEN OTHERS THEN
      Return Null;
  End Get_Billed_Upto;



FUNCTION Is_Sc_Allowed (p_org_id Number) RETURN BOOLEAN

IS

CURSOR l_sc_csr IS
    select nvl(allow_sales_credit_flag,'N') sc_flag
    FROM ra_batch_sources_All
    WHERE name = 'OKS_CONTRACTS'
    AND  org_id = p_org_id;

l_allowed_flag     BOOLEAN := FALSE;
l_sc_rec           l_sc_csr%ROWTYPE;

BEGIN

OPEN l_sc_csr;
FETCH l_sc_csr INTO l_sc_rec;

IF l_sc_csr%NOTFOUND THEN
   l_allowed_flag  := FALSE;
ELSE
   IF l_sc_rec.sc_flag = 'Y' THEN
      l_allowed_flag  := TRUE;
   ELSE
      l_allowed_flag  := FALSE;
   END IF;
END IF;
CLOSE l_sc_csr;

RETURN l_allowed_flag;


EXCEPTION
WHEN OTHERS THEN
  RETURN FALSE;
END Is_Sc_Allowed;


Function IS_Contract_billed (
                  p_header_id       IN  Number,
                  x_return_status   OUT NOCOPY VARCHAR2)
return Boolean

IS

CURSOR l_billed_rec_csr IS
       SELECT count(id)
       FROM oks_level_elements
       WHERE dnz_chr_id = p_header_id
       AND date_completed IS NOT NULL;

l_billed_count    NUMBER;

BEGIN

x_return_status := 'S';

OPEN l_billed_rec_csr;
FETCH l_billed_rec_csr INTO l_billed_count;

IF l_billed_count = 0 THEN
   RETURN FALSE;
ELSE
   RETURN TRUE;
END IF;
CLOSE l_billed_rec_csr;



EXCEPTION
WHEN OTHERS THEN
  x_return_status := 'E';
  RETURN FALSE;
END Is_Contract_billed;


PROCEDURE ADJUST_SPLIT_BILL_REC(p_old_cp_id        IN  NUMBER,
                                p_new_cp_id        IN  NUMBER,
                                p_rgp_id           IN  NUMBER,
                                p_currency_code    IN  VARCHAR2,
                                p_old_cp_lvl_tbl   IN  oks_bill_level_elements_pvt.letv_tbl_type,
                                p_new_cp_lvl_tbl   IN  oks_bill_level_elements_pvt.letv_tbl_type,
                                x_return_status    OUT   NOCOPY VARCHAR2,
                                x_msg_count        OUT   NOCOPY NUMBER,
                                x_msg_data         OUT   NOCOPY VARCHAR2)

IS

CURSOR l_bsl_csr IS
  SELECT id, cle_id, date_billed_from, date_billed_to,
         bcl_id, amount, average, date_to_interface,
         attribute_category,attribute1,attribute2,attribute3,attribute4 ,
        attribute5,attribute6,attribute7,attribute8,attribute9,
        attribute10,attribute11,attribute12,attribute13,attribute14,attribute15
  FROM oks_bill_sub_lines
  WHERE cle_id = p_old_cp_id
  ORDER BY date_billed_from;

CURSOR l_bsd_csr (p_bsl_id  NUMBER)IS

  SELECT  id, bsl_id, bsl_id_averaged, bsd_id, bsd_id_applied,
        unit_of_measure , amcv_yn, result, amount, fixed, actual,
        default_default , adjustment_level ,adjustment_minimum,
        start_reading, end_reading,ccr_id,cgr_id,
        attribute_category,attribute1,attribute2,attribute3,attribute4 ,
        attribute5,attribute6,attribute7,attribute8,attribute9,
        attribute10,attribute11,attribute12,attribute13,attribute14,attribute15
  FROM oks_bill_sub_line_dtls
  WHERE bsl_id = p_bsl_id;

CURSOR l_btl_csr(p_bcl_id   NUMBER, p_old_bsl_id  number) IS
  SELECT id ,btn_id, bsl_id,bcl_id,
        bill_instance_number, trx_line_tax_amount,
        trx_date, trx_number, trx_class, split_flag,
        attribute_category,attribute1,attribute2,attribute3,attribute4,
        attribute5,attribute6,attribute7,attribute8,attribute9,
        attribute10,attribute11,attribute12,attribute13,attribute14,attribute15,
        trx_amount,cycle_refrence
  FROM oks_bill_txn_lines
  WHERE bcl_id = p_bcl_id
  AND  bsl_id = p_old_bsl_id;


l_bsl_rec         l_bsl_csr%ROWTYPE;
l_bsd_rec         l_bsd_csr%ROWTYPE;
l_btl_rec         l_btl_csr%ROWTYPE;

SUBTYPE BSLV_REC_TYPE IS OKS_BILLSUBLINE_PVT.BSLV_REC_TYPE;
L_BSLV_REC_IN     BSLV_REC_TYPE ;
L_BSLV_REC_OUT    BSLV_REC_TYPE;


SUBTYPE l_bsdv_tbl_type_in  is OKS_bsd_PVT.bsdv_tbl_type;
l_bsdv_tbl_in     l_bsdv_tbl_type_in;
l_bsdv_tbl_out    l_bsdv_tbl_type_in;

l_btlv_tbl_in     OKS_BTL_PVT.btlv_tbl_type;
l_btlv_tbl_out    OKS_BTL_PVT.btlv_tbl_type;

l_index           NUMBER;
l_max_billed_dt   DATE;
l_tot_amt         NUMBER;
l_tot_tax         NUMBER;

BEGIN

/****This will add bsl,bsd for newly created cp after split and adjust the amount bsl, bsd for old cp.
----it will also add rec in btl with same bill_instance_number for new cp (for detail billing) and adjust
----btl amt for old cp********/

x_return_status := 'S';

l_index := p_new_cp_lvl_tbl.FIRST;

FOR l_bsl_rec IN l_bsl_csr
LOOP

  l_max_billed_dt  := l_bsl_rec.DATE_BILLED_TO;

  IF TRUNC(l_bsl_rec.date_billed_from) = TRUNC(p_new_cp_lvl_tbl(l_index).date_start ) THEN
    -----Add record for new line in bsl

     L_BSLV_REC_IN.cle_id               := p_new_cp_id;
     L_BSLV_REC_IN.bcl_id               := l_bsl_rec.bcl_id;
     L_BSLV_REC_IN.date_billed_from     := l_bsl_rec.date_billed_from;
     L_BSLV_REC_IN.date_billed_to       := l_bsl_rec.date_billed_to;
     L_BSLV_REC_IN.amount               := p_new_cp_lvl_tbl(l_index).amount;
     L_BSLV_REC_IN.average              := l_bsl_rec.average;
     L_BSLV_REC_IN.date_to_interface    := l_bsl_rec.date_to_interface;
     L_BSLV_REC_IN.attribute_category   := l_bsl_rec.attribute_category;
     L_BSLV_REC_IN.attribute1           := l_bsl_rec.attribute1;
     L_BSLV_REC_IN.attribute2           := l_bsl_rec.attribute2;
     L_BSLV_REC_IN.attribute3           := l_bsl_rec.attribute3;
     L_BSLV_REC_IN.attribute4           := l_bsl_rec.attribute4;
     L_BSLV_REC_IN.attribute5           := l_bsl_rec.attribute5;
     L_BSLV_REC_IN.attribute6           := l_bsl_rec.attribute6;
     L_BSLV_REC_IN.attribute7           := l_bsl_rec.attribute7;
     L_BSLV_REC_IN.attribute8           := l_bsl_rec.attribute8;
     L_BSLV_REC_IN.attribute9           := l_bsl_rec.attribute9;
     L_BSLV_REC_IN.attribute10          := l_bsl_rec.attribute10;
     L_BSLV_REC_IN.attribute11          := l_bsl_rec.attribute11;
     L_BSLV_REC_IN.attribute12          := l_bsl_rec.attribute12;
     L_BSLV_REC_IN.attribute13          := l_bsl_rec.attribute13;
     L_BSLV_REC_IN.attribute14          := l_bsl_rec.attribute14;
     L_BSLV_REC_IN.attribute15          := l_bsl_rec.attribute15;


     OKS_BILLSUBLINE_PUB.INSERT_BILL_SUBLINE_PUB
              (
                P_API_VERSION                  =>  1.0,
                P_INIT_MSG_LIST                =>  'T',
                X_RETURN_STATUS                =>   X_RETURN_STATUS,
                X_MSG_COUNT                    =>   X_MSG_COUNT,
                X_MSG_DATA                     =>   X_MSG_DATA,
                P_BSLV_REC                     =>   L_BSLV_REC_IN,
                X_BSLV_REC                     =>   L_BSLV_REC_OUT
              );



     IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.ADJUST_SPLIT_BILL_REC.create_bsl',
                       'oks_billsubline_pub.insert_bill_subline_pub(x_return_status = '||x_return_status
                       ||', bsl id = '|| L_BSLV_REC_OUT.id ||')');
     END IF;

     IF NVL(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;

     ---update old bsl record
     UPDATE oks_bill_sub_lines
     SET amount = nvl(amount,0) - nvl(p_new_cp_lvl_tbl(l_index).amount, 0)
     WHERE id = l_bsl_rec.id;

     IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.ADJUST_SPLIT_BILL_REC.update_bsl',
                       'update_old_bsl_amt id = ' || l_bsl_rec.id
                       );
     END IF;


     l_bsdv_tbl_in.DELETE;
     OPEN l_bsd_csr(l_bsl_rec.ID);
     FETCH l_bsd_csr INTO l_bsd_rec;
     IF l_bsd_csr%FOUND THEN

         ------ADD bsd for new cp


       l_bsdv_tbl_in(1).bsl_id             := L_BSLV_REC_OUT.id;
       l_bsdv_tbl_in(1).bsl_id_averaged    := l_bsd_rec.bsl_id_averaged;
       l_bsdv_tbl_in(1).bsd_id             := l_bsd_rec.bsd_id;
       l_bsdv_tbl_in(1).bsd_id_applied     := l_bsd_rec.bsd_id_applied;
       l_bsdv_tbl_in(1).unit_of_measure    := l_bsd_rec.unit_of_measure;
       l_bsdv_tbl_in(1).fixed              := l_bsd_rec.fixed;
       l_bsdv_tbl_in(1).actual             := l_bsd_rec.actual;
       l_bsdv_tbl_in(1).default_default    := l_bsd_rec.default_default;
       l_bsdv_tbl_in(1).amcv_yn            := l_bsd_rec.amcv_yn;
       l_bsdv_tbl_in(1).adjustment_level   := l_bsd_rec.adjustment_level;
       l_bsdv_tbl_in(1).adjustment_minimum := l_bsd_rec.adjustment_minimum;
       l_bsdv_tbl_in(1).result             := l_bsd_rec.result;
       l_bsdv_tbl_in(1).attribute_category := l_bsd_rec.attribute_category;
       l_bsdv_tbl_in(1).attribute1         := l_bsd_rec.attribute1;
       l_bsdv_tbl_in(1).attribute2         := l_bsd_rec.attribute2;
       l_bsdv_tbl_in(1).attribute3         := l_bsd_rec.attribute3;
       l_bsdv_tbl_in(1).attribute4         := l_bsd_rec.attribute4;
       l_bsdv_tbl_in(1).attribute5         := l_bsd_rec.attribute5;
       l_bsdv_tbl_in(1).attribute6         := l_bsd_rec.attribute6;
       l_bsdv_tbl_in(1).attribute7         := l_bsd_rec.attribute7;
       l_bsdv_tbl_in(1).attribute8         := l_bsd_rec.attribute8;
       l_bsdv_tbl_in(1).attribute9         := l_bsd_rec.attribute9;
       l_bsdv_tbl_in(1).attribute10        := l_bsd_rec.attribute10;
       l_bsdv_tbl_in(1).attribute11        := l_bsd_rec.attribute11;
       l_bsdv_tbl_in(1).attribute12        := l_bsd_rec.attribute12;
       l_bsdv_tbl_in(1).attribute13        := l_bsd_rec.attribute13;
       l_bsdv_tbl_in(1).attribute14        := l_bsd_rec.attribute14;
       l_bsdv_tbl_in(1).attribute15        := l_bsd_rec.attribute15;
       l_bsdv_tbl_in(1).start_reading      := l_bsd_rec.start_reading;
       l_bsdv_tbl_in(1).end_reading        := l_bsd_rec.end_reading;
       l_bsdv_tbl_in(1).ccr_id             := l_bsd_rec.ccr_id;
       l_bsdv_tbl_in(1).cgr_id             := l_bsd_rec.cgr_id;
       l_bsdv_tbl_in(1).amount             := p_new_cp_lvl_tbl(l_index).amount;

       OKS_BSL_det_PUB.insert_bsl_det_Pub
               (
                  p_api_version                  =>  1.0,
                  p_init_msg_list                =>  'T',
                  x_return_status                =>   x_return_status,
                  x_msg_count                    =>   x_msg_count,
                  x_msg_data                     =>   x_msg_data,
                  p_bsdv_tbl                     =>   l_bsdv_tbl_in,
                  x_bsdv_tbl                     =>   l_bsdv_tbl_out
               );

       IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.ADJUST_SPLIT_BILL_REC.create_bsd',
                       'OKS_BSL_det_PUB.insert_bsl_det_Pub(x_return_status = '||x_return_status
                       ||', bsd id = '|| l_bsdv_tbl_out(1).id ||')');
       END IF;

       IF NVL(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;

      -------update old bsd amount
      UPDATE oks_bill_sub_line_dtls
      set amount = nvl(amount,0) - p_new_cp_lvl_tbl(l_index).amount
      where id = l_bsd_rec.id;

      IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.ADJUST_SPLIT_BILL_REC.update_bsl',
                       'update_old_bsd_amt id = ' || l_bsd_rec.id
                       );
      END IF;

     END IF;          ------end of bsd csr found.
     CLOSE l_bsd_csr;

     l_btlv_tbl_in.DELETE;

     OPEN l_btl_csr(l_bsl_rec.BCL_ID, l_bsl_rec.ID);
     FETCH l_btl_csr INTO l_btl_rec;
     IF l_btl_csr%FOUND THEN

       l_tot_amt := nvl(p_new_cp_lvl_tbl(l_index).amount,0) + nvl(p_old_cp_lvl_tbl(l_index).amount,0);
       l_tot_tax := l_btl_rec.TRX_LINE_TAX_AMOUNT;



       l_btlv_tbl_in(1).btn_id                        := l_btl_rec.btn_id;
       l_btlv_tbl_in(1).bsl_id                        := l_bslv_rec_out.id;
       l_btlv_tbl_in(1).bcl_id                        := l_btl_rec.bcl_id;
       l_btlv_tbl_in(1).bill_instance_number          := l_btl_rec.bill_instance_number;

       IF l_tot_amt = 0 THEN
         l_btlv_tbl_in(1).trx_amount                  := 0;
       ELSE
         l_btlv_tbl_in(1).trx_amount                  := OKS_EXTWAR_UTIL_PVT.round_currency_amt(
                                                              ((nvl(l_btl_rec.trx_amount,0)/l_tot_amt ) *
                                                                nvl(p_new_cp_lvl_tbl(l_index).amount,0)),
                                                                p_currency_code) ;
       END IF;

       l_btlv_tbl_in(1).trx_line_amount               := l_btlv_tbl_in(1).trx_amount;
       IF l_tot_amt = 0 THEN
         l_btlv_tbl_in(1).trx_line_tax_amount         := 0;
       ELSIF l_btl_rec.trx_line_tax_amount IS NULL THEN
         l_btlv_tbl_in(1).trx_line_tax_amount :=       NULL;

       ELSE
         l_btlv_tbl_in(1).trx_line_tax_amount          := OKS_EXTWAR_UTIL_PVT.round_currency_amt(
                                                              ((nvl(l_btl_rec.trx_line_tax_amount,0)/l_tot_amt ) *
                                                                nvl(p_new_cp_lvl_tbl(l_index).amount,0)),
                                                                p_currency_code) ;
       END IF;


       l_btlv_tbl_in(1).split_flag                   := 'C';
       l_btlv_tbl_in(1).trx_number                   := l_btl_rec.trx_number ;
       l_btlv_tbl_in(1).trx_class                    := l_btl_rec.trx_class  ;
       l_btlv_tbl_in(1).trx_date                     := l_btl_rec.trx_date ;

       l_btlv_tbl_in(1).attribute_category           := l_btl_rec.attribute_category;
       l_btlv_tbl_in(1).attribute1                   := l_btl_rec.attribute1;
       l_btlv_tbl_in(1).attribute2                   := l_btl_rec.attribute2;
       l_btlv_tbl_in(1).attribute3                   := l_btl_rec.attribute3;
       l_btlv_tbl_in(1).attribute4                   := l_btl_rec.attribute4;
       l_btlv_tbl_in(1).attribute5                   := l_btl_rec.attribute5;
       l_btlv_tbl_in(1).attribute6                   := l_btl_rec.attribute6;
       l_btlv_tbl_in(1).attribute7                   := l_btl_rec.attribute7;
       l_btlv_tbl_in(1).attribute8                   := l_btl_rec.attribute8;
       l_btlv_tbl_in(1).attribute9                   := l_btl_rec.attribute9;
       l_btlv_tbl_in(1).attribute10                  := l_btl_rec.attribute10;
       l_btlv_tbl_in(1).attribute11                  := l_btl_rec.attribute11;
       l_btlv_tbl_in(1).attribute12                  := l_btl_rec.attribute12;
       l_btlv_tbl_in(1).attribute13                  := l_btl_rec.attribute13;
       l_btlv_tbl_in(1).attribute14                  := l_btl_rec.attribute14;
       l_btlv_tbl_in(1).attribute15                  := l_btl_rec.attribute15;
       l_btlv_tbl_in(1).cycle_refrence               := l_btl_rec.cycle_refrence;


       OKS_BILLTRAN_LINE_PUB.insert_Bill_Tran_Line_Pub
                       (
                        p_api_version                  =>  1.0,
                        p_init_msg_list                =>  'T',
                        x_return_status                =>   x_return_status,
                        x_msg_count                    =>   x_msg_count,
                        x_msg_data                     =>   x_msg_data,
                        p_btlv_tbl                     =>   l_btlv_tbl_in,
                        x_btlv_tbl                     =>   l_btlv_tbl_out
                        );

       IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.ADJUST_SPLIT_BILL_REC.create_btl',
                       'OKS_BILLTRAN_LINE_PUB.insert_Bill_Tran_Line_Pub(x_return_status = '||x_return_status
                       ||', btl id = '|| l_btlv_tbl_out(1).id ||')');
       END IF;

       IF NVL(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;

       IF l_btl_rec.split_flag IS NULL THEN

         UPDATE oks_bill_txn_lines
         SET trx_line_tax_amount = l_btl_rec.trx_line_tax_amount - l_btlv_tbl_in(1).trx_line_tax_amount,
             trx_amount = NVL(l_btl_rec.trx_amount,0) - NVL(l_btlv_tbl_in(1).trx_amount,0),
             trx_line_amount = NVL(l_btl_rec.trx_amount,0) - NVL(l_btlv_tbl_in(1).trx_amount,0),
             split_flag = 'P'
         WHERE id = l_btl_rec.id;
       ELSE
         UPDATE oks_bill_txn_lines
         SET trx_line_tax_amount = l_btl_rec.trx_line_tax_amount - l_btlv_tbl_in(1).trx_line_tax_amount,
             trx_amount = NVL(l_btl_rec.trx_amount,0) - NVL(l_btlv_tbl_in(1).trx_amount,0),
             trx_line_amount = NVL(l_btl_rec.trx_amount,0) - NVL(l_btlv_tbl_in(1).trx_amount,0)
         WHERE id = l_btl_rec.id;
       END IF;            ----chk for split_flag IS NULL

       IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.ADJUST_SPLIT_BILL_REC.update_btl',
                       'update_old_btl_amt id = ' || l_btl_rec.id
                       );
       END IF;

   END IF;             ----l_btl_csr%found chk
   CLOSE l_btl_csr;

  END IF;           ---date start chk
  l_index := p_new_cp_lvl_tbl.NEXT(l_index);

END LOOP;

IF l_max_billed_dt IS NOT NULL THEN
   UPDATE oks_level_elements
   SET date_completed = SYSDATE
   WHERE TRUNC(date_start) <= TRUNC(l_max_billed_dt)
     AND cle_id =p_new_cp_id ;

   IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_event,G_MODULE_CURRENT||'.ADJUST_SPLIT_BILL_REC.update_lvl_new',
                       'update date_completed of new cp level elements up to date = ' ||  l_max_billed_dt
                       );
   END IF;


END IF;


EXCEPTION

 WHEN OTHERS THEN
      IF FND_LOG.LEVEL_UNEXPECTED >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_unexpected,G_MODULE_CURRENT||'.Adjust_billed_lvl_element.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
      END IF;

      OKC_API.SET_MESSAGE(p_app_name       => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;


END ADJUST_SPLIT_BILL_REC;

Procedure Adjust_line_price(p_top_line_id      IN  NUMBER,
                            p_sub_line_id      IN  NUMBER,
                            p_end_date         IN  DATE,
                            p_amount           IN  NUMBER,
                            p_dnz_chr_id       IN  NUMBER,
                            x_amount           OUT NOCOPY NUMBER,
                            x_return_status    OUT NOCOPY VARCHAR2)

IS

CURSOR l_subline_csr IS
   SELECT id , TRUNC(end_date) end_dt,
          price_negotiated cp_amt
   FROM okc_k_lines_b
   WHERE cle_id = p_top_line_id
   AND lse_id in (35,7,8,9,10,11,13,18,25)
   AND date_terminated IS NULL;



CURSOR l_bsl_csr (p_cp_id   NUMBER) IS
   SELECT max(bsl.date_billed_to) max_billed_to , nvl(SUM(bsl.amount),0) bill_amt
   FROM oks_bill_sub_lines bsl, oks_bill_cont_lines bcl
   WHERE bsl.cle_id = p_cp_id
   AND   bsl.bcl_id = bcl.id
   AND   bcl.bill_action = 'RI';

CURSOR l_top_line_Amt_csr IS
  SELECT nvl(SUM(price_negotiated),0) tot_amt
  FROM okc_k_lines_b
  where cle_id = p_top_line_id
  and lse_id in (35,7,8,9,10,11,13,18,25);

CURSOR l_hdr_Amt_csr IS
  SELECT nvl(SUM(price_negotiated),0) tot_amount
  FROM okc_k_lines_b
  where dnz_chr_id = p_dnz_chr_id
  and lse_id in (35,7,8,9,10,11,13,18,25,46);

l_bsl_rec         l_bsl_csr%ROWTYPE;

l_subline_update  NUMBER;
l_top_line_amt    NUMBER;
l_hdr_amt         NUMBER;



BEGIN

---This proceudre will check if subline end date <= max billed date and billed amount <> line amt
---then it will update line amt to billed amt.
--if subline amt gets updated then top line and header amt will also get changed.
---this will be called from oks_bill_sch (cascade_dates_all and create_bill_sch_cp).

x_return_status := 'S';

l_subline_update := 0;

IF p_sub_line_id IS NULL THEN         ---called for top line

  FOR l_SubLine_rec IN l_SubLine_Csr
  LOOP

    OPEN l_bsl_csr(l_SubLine_rec.id);
    FETCH l_bsl_csr INTO l_bsl_rec;
    CLOSE l_bsl_csr;
    IF l_bsl_rec.max_billed_to IS NOT NULL AND TRUNC(l_bsl_rec.max_billed_to) = l_SubLine_rec.end_dt
       AND nvl(l_SubLine_rec.cp_amt,0) <> l_bsl_rec.bill_amt THEN

      UPDATE okc_k_lines_b SET price_negotiated = l_bsl_rec.bill_amt
      WHERE id = l_SubLine_rec.id;

      l_subline_update := l_subline_update + 1;
    END IF;          ---update decision chk

  END LOOP;            ---subline csr end

ELSIF p_sub_line_id IS NOT NULL THEN

  x_amount := nvl(p_amount,0);


  OPEN l_bsl_csr(p_sub_line_id);
  FETCH l_bsl_csr INTO l_bsl_rec;
  CLOSE l_bsl_csr;
  IF l_bsl_rec.max_billed_to IS NOT NULL AND TRUNC(l_bsl_rec.max_billed_to) = TRUNC(p_end_date)
     AND nvl(p_amount,0) <> l_bsl_rec.bill_amt THEN

     UPDATE okc_k_lines_b SET price_negotiated = l_bsl_rec.bill_amt
     WHERE id = p_sub_line_id;

     x_amount := l_bsl_rec.bill_amt;

     l_subline_update := l_subline_update + 1;

  END IF;     ---update decision chk

END IF;              ---chk for p_sub_line_id null



IF l_subline_update > 0 THEN            ---sub line updated

   OPEN l_top_line_Amt_csr;
   FETCH l_top_line_Amt_csr INTO l_top_line_amt ;
   CLOSE l_top_line_Amt_csr ;

   UPDATE okc_k_lines_b SET price_negotiated = l_top_line_amt
   WHERE id = p_top_line_id;

   OPEN l_hdr_Amt_csr;
   FETCH l_hdr_Amt_csr INTO l_hdr_amt ;
   CLOSE l_hdr_Amt_csr ;

   UPDATE okc_k_headers_b SET estimated_amount = l_hdr_amt
   WHERE id = p_dnz_chr_id;
END IF;

END Adjust_line_price;

End oks_bill_util_pub;

/
