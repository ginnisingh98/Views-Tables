--------------------------------------------------------
--  DDL for Package Body OKS_MISC_UTIL_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_MISC_UTIL_WEB" AS
/* $Header: OKSJMUTB.pls 120.30 2006/08/29 04:54:42 vjramali noship $ */
----------------------------------------------------------------------------
  l_api_version   CONSTANT NUMBER      := 1.0;
  l_init_msg_list CONSTANT VARCHAR2(1) := 'F';



  FUNCTION duration_unit(
    p_start_date IN  DATE,
    p_end_date   IN  DATE
  )
  RETURN VARCHAR2
  IS
    l_duration        NUMBER;
    l_timeunit        VARCHAR2(25);
    l_return_status   VARCHAR2(100);

    BEGIN
      OKC_TIME_UTIL_PUB.get_duration(
        p_start_date,
        p_end_date,
        l_duration,
        l_timeunit,
        l_return_status
      );


    RETURN l_timeunit;
  END duration_unit;
---------------------------------------------------------------------

  FUNCTION duration_period(
    p_start_date IN  DATE,
    p_end_date   IN  DATE
  )
  RETURN NUMBER
  IS
    l_duration        NUMBER;
    l_timeunit        VARCHAR2(25);
    l_return_status   VARCHAR2(100);

    BEGIN
      OKC_TIME_UTIL_PUB.get_duration(
        p_start_date,
        p_end_date,
        l_duration,
        l_timeunit,
        l_return_status
      );


    RETURN l_duration;
  END duration_period;
------------------------------------------------------------------------------

  FUNCTION adjusted_discount(
    p_contract_id IN  NUMBER,
    p_line_id     IN  NUMBER
  )
  RETURN NUMBER
  IS
    l_api_version   CONSTANT NUMBER      := 1.0;
    l_init_msg_list CONSTANT VARCHAR2(1) := 'F';
    l_return_status VARCHAR2(100);
    l_discount      NUMBER;
    l_line_id       VARCHAR2(100);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(100);
    l_modifiers_tbl OKS_QP_INT_PVT.price_modifiers_tbl;

    BEGIN
      l_line_id := to_char(p_line_id);

      OKS_QP_INT_PVT.GET_MODIFIER_DETAILS(
                 l_api_version,
                 l_init_msg_list,
                 p_contract_id,
                 l_line_id,
                 l_modifiers_tbl,
                 l_return_status,
                 l_msg_count,
                 l_msg_data);
       IF l_modifiers_tbl.count > 0 THEN
         l_discount := l_modifiers_tbl(1).discount;
       END IF;

      RETURN l_discount;
  END adjusted_discount;
------------------------------------------------------------------------------

  FUNCTION adjusted_surcharge(
    p_contract_id IN  NUMBER,
    p_line_id     IN  NUMBER
  )
  RETURN NUMBER
  IS
    l_api_version   CONSTANT NUMBER      := 1.0;
    l_init_msg_list CONSTANT VARCHAR2(1) := 'F';
    l_return_status VARCHAR2(100);
    l_surcharge      NUMBER;
    l_line_id       VARCHAR2(100);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(100);
    l_modifiers_tbl OKS_QP_INT_PVT.price_modifiers_tbl;

    BEGIN
      l_line_id := to_char(p_line_id);

      OKS_QP_INT_PVT.GET_MODIFIER_DETAILS(
                 l_api_version,
                 l_init_msg_list,
                 p_contract_id,
                 l_line_id,
                 l_modifiers_tbl,
                 l_return_status,
                 l_msg_count,
                 l_msg_data);
       IF l_modifiers_tbl.count > 0 THEN
         l_surcharge := l_modifiers_tbl(1).surcharge;
       END IF;

      RETURN l_surcharge;
  END adjusted_surcharge;
------------------------------------------------------------------------------

  FUNCTION adjusted_total(
    p_contract_id IN  NUMBER,
    p_line_id     IN  NUMBER
  )
  RETURN NUMBER
  IS
    l_api_version   CONSTANT NUMBER      := 1.0;
    l_init_msg_list CONSTANT VARCHAR2(1) := 'F';
    l_return_status VARCHAR2(100);
    l_total         NUMBER;
    l_line_id       VARCHAR2(100);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(100);
    l_modifiers_tbl OKS_QP_INT_PVT.price_modifiers_tbl;

    BEGIN
      l_line_id := to_char(p_line_id);

      OKS_QP_INT_PVT.GET_MODIFIER_DETAILS(
                 l_api_version,
                 l_init_msg_list,
                 p_contract_id,
                 l_line_id,
                 l_modifiers_tbl,
                 l_return_status,
                 l_msg_count,
                 l_msg_data);
       IF l_modifiers_tbl.count > 0 THEN
         l_total := l_modifiers_tbl(1).total;
       END IF;

      RETURN l_total;
  END adjusted_total;
------------------------------------------------------------------------------

  FUNCTION get_terminated_amount(
   p_level   IN VARCHAR2,
   p_id      IN NUMBER
  ) RETURN NUMBER IS
  l_unbilled    NUMBER;
  l_credited    NUMBER;
  l_suppressed  NUMBER;
  l_overridden  NUMBER;
  l_billed      NUMBER;
  l_return_status VARCHAR2(20);

  BEGIN
    oks_bill_rec_pub.get_termination_details( p_level     =>  p_level,
                                              p_id        =>  p_id,
                                              x_unbilled  =>  l_unbilled,
                                              x_credited  =>  l_credited,
                                              x_suppressed => l_suppressed,
                                              x_overridden => l_overridden,
                                              x_billed     => l_billed,
                                              x_return_status => l_return_status
                                              );

  return (l_unbilled + l_credited + l_suppressed);
  END get_terminated_amount;

 --------------------------------------------------------------------------------
  FUNCTION get_adjustment_amount(p_chr_id   IN NUMBER DEFAULT NULL,
                                 p_cle_id      IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_return_status VARCHAR2(20);
    l_amount        NUMBER;
    l_modifiers_tbl oks_qp_int_pvt.price_modifiers_tbl;
  BEGIN
      l_amount := 0;
      oks_qp_int_pvt.get_modifier_details(p_api_version   => l_api_version,
                                           p_init_msg_list => l_init_msg_list,
                                           p_chr_id        => p_chr_id,
                                           p_cle_id        => p_cle_id,
                                           x_modifiers_tbl => l_modifiers_tbl,
                                           x_return_status => l_return_status,
                                           x_msg_count     => l_msg_count,
                                           x_msg_data      => l_msg_data    );

  IF (l_modifiers_tbl.count > 0 ) THEN
      l_amount := l_modifiers_tbl(l_modifiers_tbl.first).total;
      RETURN l_amount;
  ELSE
      RETURN l_amount;
  END IF;


  END get_adjustment_amount;


FUNCTION get_total_amount
(
 p_chr_id              IN NUMBER
) RETURN NUMBER AS

l_api_name               CONSTANT VARCHAR2(30) := 'get_total_amount';
l_subtotal_amount                 NUMBER;
l_tax_amount                      NUMBER;
l_total_amount                    NUMBER := 0;


CURSOR c_subtotal_amount IS
SELECT nvl(sum(lines.price_negotiated),0)
FROM okc_k_lines_b lines
WHERE lines.dnz_chr_id = p_chr_id
AND lines.cle_id IS NULL;

CURSOR c_tax_amount IS   -- Bug 5490811
SELECT nvl(shdr.tax_amount,0) AS tax_amount
FROM oks_k_headers_b shdr
WHERE shdr.chr_id = p_chr_id;

BEGIN
  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  OPEN c_subtotal_amount;
    FETCH c_subtotal_amount INTO l_subtotal_amount;
  CLOSE c_subtotal_amount;

  OPEN c_tax_amount;
    FETCH c_tax_amount INTO l_tax_amount;
  CLOSE c_tax_amount;

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  l_total_amount := l_subtotal_amount + l_tax_amount;

  RETURN l_total_amount;


EXCEPTION
  WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

  RETURN l_total_amount;

END get_total_amount;


/**
 * Addded function to retrieve Line Billed Amount for HTML Inquiry Line Billing Details Page
 * @param p_line_id Line or Sub Line Id
 * @param p_line_level line level character "L" for Line, "SL" for Sub Line
 * @return total billed amount
 */
 FUNCTION get_line_billed_amount
 (p_line_id   IN NUMBER,
  p_line_level IN VARCHAR2
 ) RETURN NUMBER AS

    CURSOR line_billed_amount_curr (l_line_id IN NUMBER) IS
SELECT
        NVL(SUM(btl.trx_amount), 0) + NVL(SUM(btl.trx_line_tax_amount), 0) trx_amount
        FROM
        oks_bill_transactions btr
        , oks_bill_txn_lines btl
        , oks_bill_cont_lines bcl
        WHERE
        bcl.cle_id = l_line_id
        and btr.ID = bcl.BTN_ID
        and btl.btn_id = btr.id
        and btl.BCL_ID = bcl.id
        AND bcl.bill_action = 'RI'
	and (btl.trx_number <> -99 OR btr.trx_number <> -99)
        GROUP BY bcl.cle_id

	UNION

	SELECT
               (nvl (sum (decode(raTrxLineSelect.r, 1, lineamt, 0)), 0) + nvl (sum (taxamt), 0)) trx_amount
           FROM
           (
    select uniqueOrderLineSelect.id,
        ra.trx_number,
        ra.trx_date,
        ratax.extended_amount taxamt,
        ral.extended_amount lineamt,
        ral.customer_trx_id,
        uniqueOrderLineSelect.bill_action,
        uniqueOrderLineSelect.bill_from_date,
        uniqueOrderLineSelect.bill_to_date,
        rank() over (partition by ral.customer_trx_line_id order by ratax.customer_trx_line_id) r
    from (
        select /*+ no_merge */ distinct rel.object1_id1, subline.cle_id id,
        bcl.bill_action,
        bcl.date_billed_from bill_from_date,
        bcl.date_billed_to bill_to_date
          from okc_k_rel_objs rel,
               okc_k_lines_b subline,
               oks_bill_cont_lines bcl
         where subline.cle_id =  l_line_id
           and subline.lse_id in (9,18,25)
           and subline.cle_id = bcl.cle_id
           AND bcl.btn_id = - 44
           AND bcl.bill_action = 'RI'
           and subline.id = rel.cle_id
           and rel.jtot_object1_code = 'OKX_ORDERLINE') uniqueOrderLineSelect,

        oe_order_lines_all oel,
        oe_order_headers_all oe,
        ra_customer_trx_lines_all ral,
        ra_customer_trx_all ra,
        ra_customer_trx_lines_all ratax
    where
    uniqueOrderLineSelect.object1_id1 = oel.line_id
    and oel.header_id = oe.header_id
    and to_char (oe.order_number) = ral.sales_order
    and to_char (oel.line_id) = ral.interface_line_attribute6
    and ral.customer_trx_id = ra.customer_trx_id
    and ratax.link_to_cust_trx_line_id (+) = ral.customer_trx_line_id
    and ratax.line_type (+) = 'TAX') raTrxLineSelect
  GROUP BY raTrxLineSelect.id;

    CURSOR sub_line_billed_amount_curr (l_line_id IN NUMBER) IS
	SELECT
        NVL(SUM(btl.trx_amount), 0) + NVL(SUM(btl.trx_line_tax_amount), 0) trx_amount
            FROM
            oks_bill_txn_lines btl
            , oks_bill_cont_lines bcl
            , oks_bill_sub_lines bsl
	    , oks_bill_transactions btr
            WHERE
            bsl.cle_id = l_line_id
            AND btl.BSL_ID = bsl.id
            AND btl.btn_id = btr.id
            AND bcl.id = bsl.bcl_id
            AND bcl.BTN_ID = btr.ID
            AND bcl.bill_action = 'RI'
        AND (btl.trx_number <> -99 OR btr.trx_number <> -99)
            GROUP BY bsl.cle_id

	UNION

	SELECT (nvl (sum (decode(raTrxLineSelect.r, 1, lineamt, 0)), 0) + nvl (sum (taxamt), 0)) trx_amount
		FROM
		    (
	select      subline.cle_id id,
		    ra.trx_number,
		    ra.trx_date,
		    ratax.extended_amount taxamt,
		    ral.extended_amount lineamt,
		    ral.customer_trx_id,
		    rank() over (partition by ral.customer_trx_line_id order by ratax.customer_trx_line_id) r
	    from
		  okc_k_lines_b subline,
		  okc_k_rel_objs rel,
		  oe_order_lines_all oel,
		  oe_order_headers_all oe,
		  ra_customer_trx_lines_all ral,
		  ra_customer_trx_all ra,
		  ra_customer_trx_lines_all ratax
	     where subline.id = l_line_id
	     and subline.lse_id in (9,18,25)
	     and subline.id = rel.cle_id
	     and rel.jtot_object1_code = 'OKX_ORDERLINE'
	     and rel.object1_id1 = oel.line_id
	     and oel.header_id = oe.header_id
	     and to_char (oe.order_number) = ral.sales_order
	     and to_char (oel.line_id) = ral.interface_line_attribute6
	     and ral.customer_trx_id = ra.customer_trx_id
	     and ratax.link_to_cust_trx_line_id (+) = ral.customer_trx_line_id
	     and ratax.line_type (+) = 'TAX') raTrxLineSelect,

	  oks_bill_cont_lines bcl
	  WHERE raTrxLineSelect.id = bcl.cle_id
	  AND bcl.btn_id = - 44
	  AND bcl.bill_action = 'RI'
	  GROUP BY raTrxLineSelect.id;

	l_api_name      CONSTANT VARCHAR2(30) :='get_line_billed_amount';
	l_amount        NUMBER;

 BEGIN

 	IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside get_line_billed_amount');
    END IF;

    IF p_line_level = 'L' THEN
	    OPEN line_billed_amount_curr(p_line_id);
	    FETCH line_billed_amount_curr INTO l_amount;
	    CLOSE line_billed_amount_curr;
    END IF;

    IF p_line_level = 'SL' THEN
	    OPEN sub_line_billed_amount_curr(p_line_id);
	    FETCH sub_line_billed_amount_curr INTO l_amount;
	    CLOSE sub_line_billed_amount_curr;
    END IF;


	IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'101: get_line_billed_amount');
	END IF;

    return l_amount;

 EXCEPTION
	 WHEN OTHERS THEN
		 IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	         FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving get_line_billed_amount because of EXCEPTION: '||sqlerrm);
		 END IF;
         IF line_billed_amount_curr %ISOPEN THEN
            CLOSE line_billed_amount_curr ;
         END IF;

         IF sub_line_billed_amount_curr %ISOPEN THEN
            CLOSE sub_line_billed_amount_curr ;
         END IF;

     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
	     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
     END IF;

     return null;

 END get_line_billed_amount;

/**
 * Addded function to retrieve Line Billed Amount for HTML Inquiry Line Billing Details Page
 * @param p_line_id Line or Sub Line Id
 * @param p_line_level line level character "L" for Line, "SL" for Sub Line
 * @return pending invoice amount
 */
 FUNCTION get_line_unbilled_amount
 (p_line_id   			   IN NUMBER,
  p_line_level IN VARCHAR2
 ) RETURN NUMBER AS

   CURSOR line_unbilled_amount_curr (l_line_id IN NUMBER) IS
	SELECT
	(
	NVL(KLINES.price_negotiated, 0)
	+
	NVL(KSLINES.credit_amount, 0)
	+
	NVL(KSLINES.suppressed_credit, 0)
	)

	-
	(NVL(OKS_BILLED_LINES.BILLED_AMOUNT,0) + NVL(OM_ORIGINATED_BILLED_LINES.BILLED_AMOUNT,0)) unbilled_amount

	FROM
	OKC_K_LINES_B KLINES
	,OKS_K_LINES_B KSLINES

	,
	(
        SELECT
                NVL(SUM(btl.trx_amount), 0) BILLED_AMOUNT
        FROM
        oks_bill_transactions btr
        ,oks_bill_txn_lines btl
        ,OKS_BILL_CONT_LINES BCL

        WHERE
        BCL.cle_id = l_line_id
        AND BCL.bill_action = 'RI'
        AND btr.ID = bcl.BTN_ID
        AND btl.btn_id = btr.id
        AND btl.BCL_ID = bcl.id
        AND (btl.trx_number <> -99 OR btr.trx_number <> -99)
	) OKS_BILLED_LINES

	,
	(
           select NVL(SUM(ral.extended_amount), 0) BILLED_AMOUNT
            from (
	        select /*+ no_merge */ distinct rel.object1_id1
	          from okc_k_rel_objs rel,
	               okc_k_lines_b subline,
	               oks_bill_cont_lines bcl
	         where subline.cle_id =  l_line_id
	           and subline.lse_id in (9,18,25)
	           and subline.cle_id = bcl.cle_id
	           AND bcl.btn_id = - 44
	           AND bcl.bill_action = 'RI'
	           and subline.id = rel.cle_id
	           and rel.jtot_object1_code = 'OKX_ORDERLINE') uniqueOrderLineSelect,

	        oe_order_lines_all oel,
                oe_order_headers_all oe,
                ra_customer_trx_lines_all ral
            where
	        uniqueOrderLineSelect.object1_id1 = oel.line_id
                and oel.header_id = oe.header_id
	        and to_char (oe.order_number) = ral.sales_order
	        and to_char (oel.line_id) = ral.interface_line_attribute6
	) OM_ORIGINATED_BILLED_LINES

	WHERE
	KLINES.id = l_line_id
	AND KSLINES.cle_id = KLINES.id
	AND (KSLINES.usage_type IS NULL OR KSLINES.usage_type = 'NPR');



   CURSOR sub_line_unbilled_amount_curr (l_line_id IN NUMBER) IS
	SELECT
	(
	NVL(KLINES.price_negotiated, 0)
	+
	NVL(KSLINES.credit_amount, 0)
	+
	NVL(KSLINES.suppressed_credit, 0)
	)
	-
	(NVL(OKS_BILLED_LINES.BILLED_AMOUNT,0) + NVL(OM_ORIGINATED_BILLED_LINES.BILLED_AMOUNT,0)) unbilled_amount

	FROM
	OKC_K_LINES_B KLINES
	,OKS_K_LINES_B KSLINES
	,
	(
      SELECT
         NVL(SUM(btl.trx_amount), 0) BILLED_AMOUNT
         FROM
         OKS_BILL_SUB_LINES BSL
        ,oks_bill_txn_lines btl
        ,oks_bill_transactions btr
        ,OKS_BILL_CONT_LINES BCL
        WHERE
        BSL.cle_id = l_line_id
        AND BCL.id = BSL.bcl_id
        AND BCL.bill_action = 'RI'
        AND btl.BSL_ID = bsl.id
        AND btl.btn_id = btr.id
        AND bcl.BTN_ID = btr.ID
        AND (btl.trx_number <> -99 OR btr.trx_number <> -99)	) OKS_BILLED_LINES
	,

	(
        SELECT
                NVL(SUM(ral.extended_amount), 0) BILLED_AMOUNT
         FROM
         ra_customer_trx_lines_all ral
        ,oks_bill_cont_lines   bcl
        ,oe_order_headers_all  oe
        ,oe_order_lines_all    oel
        ,okc_k_rel_objs        rel
        ,okc_k_lines_b         subline
         WHERE
         subline.id = l_line_id
         AND subline.lse_id in (9,18,25)
         AND rel.cle_id = subline.id
         AND rel.jtot_object1_code = 'OKX_ORDERLINE'
         AND oel.line_id = rel.object1_id1
         AND oe.header_id = oel.header_id
         AND ral.sales_order = TO_CHAR(oe.order_number)
         AND ral.interface_line_attribute1 = TO_CHAR(oe.order_number)
         AND ral.interface_line_attribute6 = TO_CHAR(oel.line_id)
         AND bcl.cle_id = subline.cle_id
         AND bcl.btn_id = -44
         AND bcl.bill_action = 'RI'
	) OM_ORIGINATED_BILLED_LINES

	WHERE
	KLINES.id = l_line_id
	AND KSLINES.cle_id = KLINES.id;


	l_api_name      CONSTANT VARCHAR2(30) :='get_line_unbilled_amount';

	l_unbilled_amount    	NUMBER;

 BEGIN

 	IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside get_line_unbilled_amount');
	END IF;


    IF p_line_level = 'L' THEN
	    OPEN line_unbilled_amount_curr(p_line_id);
	    FETCH line_unbilled_amount_curr INTO l_unbilled_amount;
	    CLOSE line_unbilled_amount_curr;
    END IF;

    IF p_line_level = 'SL' THEN
	    OPEN sub_line_unbilled_amount_curr(p_line_id);
	    FETCH sub_line_unbilled_amount_curr INTO l_unbilled_amount;
	    CLOSE sub_line_unbilled_amount_curr;
    END IF;


	IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'101: get_line_unbilled_amount');
	END IF;

    return l_unbilled_amount;

 EXCEPTION
	 WHEN OTHERS THEN
		 IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	         FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving get_line_unbilled_amount because of EXCEPTION: '||sqlerrm);
		 END IF;

         IF line_unbilled_amount_curr %ISOPEN THEN
            CLOSE line_unbilled_amount_curr ;
         END IF;

         IF sub_line_unbilled_amount_curr %ISOPEN THEN
            CLOSE sub_line_unbilled_amount_curr ;
         END IF;

     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
	     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
     END IF;

     return null;

 END get_line_unbilled_amount;



-- Function to retrieve unbilled amount for a contract
-- Parameters: contract id

FUNCTION get_header_unbilled_amount (p_chr_id  IN NUMBER )
 RETURN NUMBER AS

CURSOR C_HEADER_UNBILLED_AMOUNT (P_CHR_ID IN NUMBER) IS
SELECT (
        (SELECT  SUM(
                 NVL(KLINES.PRICE_NEGOTIATED, 0) +
                 NVL(KSLINES.CREDIT_AMOUNT, 0) +
                 NVL(KSLINES.SUPPRESSED_CREDIT, 0)
                 )
          FROM
              OKC_K_LINES_B KLINES
             ,OKS_K_LINES_B KSLINES
         WHERE
              KLINES.CHR_ID = P_CHR_ID
         AND  KLINES.ID = KSLINES.CLE_ID
         AND (KSLINES.USAGE_TYPE IS NULL OR KSLINES.USAGE_TYPE = 'NPR')
        )
        -
        (
              ( SELECT
                   NVL(SUM(BTL.TRX_AMOUNT),0) BILLED_AMOUNT
                FROM
                   OKC_K_LINES_B LINE
                  ,OKS_K_LINES_B KSLINES
                  ,OKS_BILL_TRANSACTIONS BTR
                  ,OKS_BILL_TXN_LINES BTL
                  ,OKS_BILL_CONT_LINES BCL
               WHERE
                  LINE.CHR_ID = P_CHR_ID
              AND LINE.ID = KSLINES.CLE_ID
              AND (KSLINES.USAGE_TYPE IS NULL OR KSLINES.USAGE_TYPE = 'NPR') -- Bug 5484219 Filter out non NPR lines
              AND LINE.ID = BCL.CLE_ID
              AND BCL.bill_action = 'RI'
              AND BTR.ID = BCL.BTN_ID
              AND BTL.BTN_ID = BTR.ID
              AND BTL.BCL_ID = BCL.ID
              AND (BTL.TRX_NUMBER <> -99 OR BTR.TRX_NUMBER <> -99)
              )
              +
              (
                SELECT
                     NVL(SUM(RAL.EXTENDED_AMOUNT), 0) BILLED_AMOUNT
                FROM (
                          SELECT /*+ NO_MERGE */ DISTINCT REL.OBJECT1_ID1, SUBLINE.CHR_ID
                          FROM OKC_K_REL_OBJS REL,
                    	       OKC_K_LINES_B SUBLINE,
                    	       OKS_BILL_CONT_LINES BCL
                         WHERE
                               SUBLINE.DNZ_CHR_ID = P_CHR_ID
                           AND SUBLINE.LSE_ID IN (9,18,25)
                           AND SUBLINE.CLE_ID = BCL.CLE_ID
                           AND BCL.BTN_ID = - 44
                           AND BCL.BILL_ACTION = 'RI'
                           AND SUBLINE.ID = REL.CLE_ID
                           AND REL.JTOT_OBJECT1_CODE = 'OKX_ORDERLINE') UNIQUEORDERLINESELECT,
                     OE_ORDER_LINES_ALL OEL,
                     OE_ORDER_HEADERS_ALL OE,
                     RA_CUSTOMER_TRX_LINES_ALL RAL
                WHERE
                	 UNIQUEORDERLINESELECT.OBJECT1_ID1 = OEL.LINE_ID
                 AND OEL.HEADER_ID = OE.HEADER_ID
                 AND TO_CHAR (OE.ORDER_NUMBER) = RAL.SALES_ORDER
                 AND TO_CHAR (OEL.LINE_ID) = RAL.INTERFACE_LINE_ATTRIBUTE6
              )
        )
       ) UNBILLED_AMOUNT FROM DUAL;

	l_api_name      CONSTANT VARCHAR2(30) :='get_header_unbilled_amount';
	l_unbilled_amount        NUMBER := 0;

 BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside get_header_unbilled_amount');
    END IF;

    OPEN c_header_unbilled_amount(p_chr_id);
    FETCH c_header_unbilled_amount INTO l_unbilled_amount;
    CLOSE c_header_unbilled_amount;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'101: get_header_unbilled_amount');
    END IF;

    return l_unbilled_amount;

 EXCEPTION
	 WHEN OTHERS THEN
		 IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	         FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving due EXCEPTION: '||sqlerrm);
		 END IF;
         IF c_header_unbilled_amount %ISOPEN THEN
            CLOSE c_header_unbilled_amount ;
         END IF;

     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
	     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
     END IF;

     return null;

 END get_header_unbilled_amount;



-- Function to retrieve billed amount for a contract
-- Parameters: p_chr_id (Identifier of the contract)
--             Returns the billed amount for a contract


FUNCTION get_header_billed_amount (p_chr_id  IN NUMBER)
 RETURN NUMBER AS

    CURSOR C_HEADER_BILLED_AMOUNT (P_CHR_ID IN NUMBER) IS
        SELECT
           NVL(SUM(BTL.TRX_AMOUNT), 0) + NVL(SUM(BTL.TRX_LINE_TAX_AMOUNT), 0) TRX_AMOUNT
        FROM
            OKC_K_LINES_B LINE
           ,OKS_BILL_TRANSACTIONS BTR
           ,OKS_BILL_TXN_LINES BTL
           ,OKS_BILL_CONT_LINES BCL
        WHERE
            LINE.CHR_ID = P_CHR_ID
        AND LINE.ID = BCL.CLE_ID
        AND BTR.ID = BCL.BTN_ID
        AND BTL.BTN_ID = BTR.ID
        AND BTL.BCL_ID = BCL.ID
        AND BCL.bill_action = 'RI'
	    AND (BTL.TRX_NUMBER <> -99 OR BTR.TRX_NUMBER <> -99)
        GROUP BY LINE.CHR_ID

	UNION

	SELECT
               (NVL (SUM (DECODE(RATRXLINESELECT.R, 1, LINEAMT, 0)), 0) + NVL (SUM (TAXAMT), 0)) TRX_AMOUNT
           FROM
           (
    SELECT UNIQUEORDERLINESELECT.ID,
        UNIQUEORDERLINESELECT.CHR_ID,
        RA.TRX_NUMBER,
        RA.TRX_DATE,
        RATAX.EXTENDED_AMOUNT TAXAMT,
        RAL.EXTENDED_AMOUNT LINEAMT,
        RAL.CUSTOMER_TRX_ID,
        UNIQUEORDERLINESELECT.BILL_ACTION,
        UNIQUEORDERLINESELECT.BILL_FROM_DATE,
        UNIQUEORDERLINESELECT.BILL_TO_DATE,
        RANK() OVER (PARTITION BY RAL.CUSTOMER_TRX_LINE_ID ORDER BY RATAX.CUSTOMER_TRX_LINE_ID) R
    FROM (
        SELECT /*+ NO_MERGE */ DISTINCT REL.OBJECT1_ID1,
               SUBLINE.CLE_ID ID,
	       SUBLINE.DNZ_CHR_ID CHR_ID,
               BCL.BILL_ACTION,
               BCL.DATE_BILLED_FROM BILL_FROM_DATE,
               BCL.DATE_BILLED_TO BILL_TO_DATE
          FROM OKC_K_REL_OBJS REL,
               OKC_K_LINES_B SUBLINE,
               OKS_BILL_CONT_LINES BCL
         WHERE
               SUBLINE.DNZ_CHR_ID = P_CHR_ID
           AND SUBLINE.LSE_ID IN (9,18,25)
           AND SUBLINE.CLE_ID = BCL.CLE_ID
           AND BCL.BTN_ID = - 44
           AND BCL.BILL_ACTION = 'RI'
           AND SUBLINE.ID = REL.CLE_ID
           AND REL.JTOT_OBJECT1_CODE = 'OKX_ORDERLINE') UNIQUEORDERLINESELECT,

        OE_ORDER_LINES_ALL OEL,
        OE_ORDER_HEADERS_ALL OE,
        RA_CUSTOMER_TRX_LINES_ALL RAL,
        RA_CUSTOMER_TRX_ALL RA,
        RA_CUSTOMER_TRX_LINES_ALL RATAX
    WHERE
    UNIQUEORDERLINESELECT.OBJECT1_ID1 = OEL.LINE_ID
    AND OEL.HEADER_ID = OE.HEADER_ID
    AND TO_CHAR (OE.ORDER_NUMBER) = RAL.SALES_ORDER
    AND TO_CHAR (OEL.LINE_ID) = RAL.INTERFACE_LINE_ATTRIBUTE6
    AND RAL.CUSTOMER_TRX_ID = RA.CUSTOMER_TRX_ID
    AND RATAX.LINK_TO_CUST_TRX_LINE_ID (+) = RAL.CUSTOMER_TRX_LINE_ID
    AND RATAX.LINE_TYPE (+) = 'TAX') RATRXLINESELECT
  GROUP BY RATRXLINESELECT.CHR_ID;

	l_api_name      CONSTANT VARCHAR2(30) :='get_header_billed_amount';
	l_billed_amount        NUMBER := 0;

 BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside get_header_billed_amount');
    END IF;

    OPEN c_header_billed_amount(p_chr_id);
    FETCH c_header_billed_amount INTO l_billed_amount;
    CLOSE c_header_billed_amount;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'101: get_header_billed_amount');
    END IF;

    return l_billed_amount;

 EXCEPTION
	 WHEN OTHERS THEN
		 IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	         FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving due EXCEPTION: '||sqlerrm);
		 END IF;
         IF c_header_billed_amount %ISOPEN THEN
            CLOSE c_header_billed_amount ;
         END IF;

     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
	     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
     END IF;

     return null;
 END get_header_billed_amount;



-- Function to get Duration and Period for a given Strat Date and End Date ( ex: 1 Year)
 FUNCTION get_duration_period (p_start_date DATE,
                                p_end_date   DATE)
                                RETURN VARCHAR2 AS

  l_api_name        CONSTANT VARCHAR2(30) :='get_duration_period';
  l_period_meaning  VARCHAR2(25);

  CURSOR get_period_maening (p_unit_of_measure VARCHAR2) IS
         SELECT  unit_of_measure_tl
         FROM   mtl_units_of_measure_tl
         WHERE  uom_code = p_unit_of_measure
         AND    language = userenv('LANG');

  BEGIN

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Inside get_duration_period');
       END IF;

       OPEN  get_period_maening(duration_unit(p_start_date,p_end_date));
       FETCH get_period_maening INTO l_period_meaning;
       CLOSE get_period_maening;

       return    duration_period(p_start_date,p_end_date) || ' ' || l_period_meaning ;

       EXCEPTION
         WHEN OTHERS THEN
              IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'EXCEPTION: '||sqlerrm);
              END IF;
  END  get_duration_period;

  -- Function to get the covered level name (Service).
  FUNCTION get_covlvl_name(p_jtot_object1_code IN VARCHAR2,
                           p_object1_id1       IN VARCHAR2,
                           p_object1_id2       IN VARCHAR2)
                           RETURN VARCHAR2 IS

   l_name     VARCHAR2(2000);
   l_chr_id   NUMBER;
   l_api_name CONSTANT VARCHAR2(30) := 'get_covlvl_name';

   CURSOR get_prod_name_csr IS
          SELECT decode(fnd_profile.value('OKS_ITEM_DISPLAY_PREFERENCE'), 'DISPLAY_DESC'
                        , mtl.description,mtl.concatenated_segments)
          FROM   mtl_system_items_kfv mtl
                ,okc_k_items itm
                ,csi_item_instances csi
          WHERE itm.object1_id1       = p_object1_id1
          AND   itm.jtot_object1_code = p_jtot_object1_code
          AND   csi.instance_id       = itm.object1_id1
          AND   csi.inventory_item_id = mtl.inventory_item_id
          AND   mtl.organization_id   = csi.inv_master_organization_id
          AND   rownum < 2;

   CURSOR get_item_name_csr IS
          SELECT decode(fnd_profile.value('OKS_ITEM_DISPLAY_PREFERENCE'), 'DISPLAY_DESC'
                        , mtl.description,mtl.concatenated_segments)
          FROM   mtl_system_items_kfv mtl
          WHERE  mtl.inventory_item_id = to_number(p_object1_id1)
          AND    mtl.organization_id   = p_object1_id2;

   CURSOR get_party_name_csr IS
          SELECT party.party_name
          FROM hz_parties party
          WHERE party.party_id = p_object1_id1;

   CURSOR get_system_name_csr IS
          SELECT systl.name
          FROM   csi_systems_tl systl
          WHERE  systl.system_id = to_number(p_object1_id1)
          AND    systl.language = userenv('LANG');

   CURSOR get_account_name_csr IS
          SELECT decode (ca.account_name, null, p.party_name,ca.account_name)
          FROM hz_cust_accounts ca
              ,hz_parties p
          WHERE ca.cust_account_id = to_number(p_object1_id1)
          AND   p.party_id = ca.party_id;

   CURSOR get_site_name_csr IS
          SELECT DECODE(site.party_site_name,NULL,site.party_site_number
                                            ,site.party_site_number || '-' ||
                                             site.party_site_name  ) NAME
          FROM   hz_party_sites site
          WHERE  site.party_site_id = to_number(p_object1_id1);

  BEGIN

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Inside get_covdlvl_name ' ||
 	                   'p_jtot_object1_code is : ' || p_jtot_object1_code ||
 	                   'p_object1_id1       is : ' || p_object1_id1       ||
 	                   'p_object1_id2       is : ' || p_object1_id2);
       END IF;

       -- Get Covered Item Name
       IF    ( p_jtot_object1_code = 'OKX_COVITEM'  ) THEN
              OPEN  get_item_name_csr;
              FETCH get_item_name_csr INTO l_name;
              CLOSE get_item_name_csr;
       -- Get Covered Product Name
       ELSIF ( p_jtot_object1_code = 'OKX_CUSTPROD' ) THEN
              OPEN  get_prod_name_csr;
              FETCH get_prod_name_csr INTO l_name;
              CLOSE get_prod_name_csr;
       -- Get Covered Party Site Number - Site Name
       ELSIF ( p_jtot_object1_code = 'OKX_PARTYSITE') THEN
              OPEN  get_site_name_csr;
              FETCH get_site_name_csr INTO l_name;
              CLOSE get_site_name_csr;
       -- Get Covered Party Name
       ELSIF ( p_jtot_object1_code = 'OKX_PARTY'    ) THEN
              OPEN  get_party_name_csr;
              FETCH get_party_name_csr INTO l_name;
              CLOSE get_party_name_csr;
       -- Get Covered Customer Name
       ELSIF ( p_jtot_object1_code = 'OKX_CUSTACCT' ) THEN
              OPEN  get_account_name_csr;
              FETCH get_account_name_csr INTO l_name;
              CLOSE get_account_name_csr;
       -- Get Covered System Name
       ELSIF ( p_jtot_object1_code = 'OKX_COVSYST'  ) THEN
              OPEN  get_system_name_csr;
              FETCH get_system_name_csr INTO l_name;
              CLOSE get_system_name_csr;
       END IF;

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Exit get_covdlvl_name ' ||
 	                   'l_name is : ' || l_name);
       END IF;

       RETURN (l_name);

  EXCEPTION
       WHEN OTHERS THEN
         IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	         FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'EXCEPTION: '||sqlerrm);
         END IF;
         IF get_item_name_csr%ISOPEN THEN
            CLOSE get_item_name_csr ;
         ELSIF get_account_name_csr%ISOPEN THEN
            CLOSE get_account_name_csr;
         ELSIF get_site_name_csr%ISOPEN THEN
            CLOSE get_site_name_csr;
         ELSIF get_system_name_csr%ISOPEN THEN
            CLOSE get_system_name_csr;
         ELSIF get_party_name_csr%ISOPEN THEN
            CLOSE get_party_name_csr;
         ELSIF get_prod_name_csr%ISOPEN THEN
            CLOSE get_prod_name_csr;
         END IF;
       return null;

  END  get_covlvl_name;

  FUNCTION get_name (p_line_id IN NUMBER,
                     p_lse_id  IN NUMBER
                     )
                   RETURN VARCHAR2 IS

   l_name                VARCHAR2(2000);
   l_jtot_object1_code   VARCHAR2(30);
   l_object1_id1         VARCHAR2(40);
   l_object1_id2         VARCHAR2(200);

   l_api_name CONSTANT VARCHAR2(30) := 'get_name';

   CURSOR get_objec_rel_csr(p_line_id NUMBER) IS
          SELECT jtot_object1_code,
                 object1_id1,
                 object1_id2
          FROM   OKC_K_ITEMS
          WHERE  CLE_ID = p_line_id;

   CURSOR get_name_csr (p_object1_id1 VARCHAR2) IS
          SELECT fnd_flex_server.get_kfv_concat_segs_by_rowid('COMPACT', 401, 'SERV', 101,  sysitems.rowid)name
          FROM   MTL_SYSTEM_ITEMS_B sysitems
          WHERE  sysitems.inventory_item_id = to_number(p_object1_id1)
          AND    rownum < 2;
   BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Inside get_covdlvl_name ' ||
 	                   'p_line_id is : ' || p_line_id ||
 	                   'p_lse_id  is : ' || p_lse_id);

    END IF;

    OPEN  get_objec_rel_csr(p_line_id);
    FETCH get_objec_rel_csr INTO l_jtot_object1_code,l_object1_id1,l_object1_id2;
    CLOSE get_objec_rel_csr;

    IF  p_lse_id IN (1,12,14,19,46) THEN
        OPEN  get_name_csr(l_object1_id1);
        FETCH get_name_csr INTO l_name;
        CLOSE get_name_csr;
    ELSE
        l_name := get_covlvl_name (l_jtot_object1_code,l_object1_id1,l_object1_id2);

    END IF;

    RETURN (l_name);

    EXCEPTION
       WHEN OTHERS THEN
         IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	         FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'EXCEPTION: '||sqlerrm);
         END IF;

         IF get_objec_rel_csr%ISOPEN THEN
            CLOSE get_objec_rel_csr;
         END IF;

         IF get_name_csr%ISOPEN THEN
            CLOSE get_name_csr ;
         END IF;
         return null;
END get_name;

-- Function to get the commitment number
-- Parameters: p_commitment_id: Commitment ID
FUNCTION get_commiment_number(p_commitment_id NUMBER
                              ,p_org_id        NUMBER)
         RETURN NUMBER IS

 l_api_name CONSTANT VARCHAR2(30) := 'get_commiment_number';
 l_commitment_number NUMBER;

 CURSOR get_commitment_number_csr(p_commitment_id NUMBER,
                                  p_org_id        NUMBER) IS
          SELECT trx_number
          FROM   ra_customer_trx_all rah
          WHERE rah.customer_trx_id  = p_commitment_id
          AND   nvl(rah.org_id,-99)  = p_org_id;

  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Inside GET_COMMITMENT_NUMBER ' ||
 	                   'p_commitment_id is : ' || p_commitment_id ||
 	                   ' p_org_id is: ' || p_org_id);

    END IF;

    OPEN  get_commitment_number_csr(p_commitment_id,p_org_id);
    FETCH get_commitment_number_csr INTO l_commitment_number;
    CLOSE get_commitment_number_csr;
    return l_commitment_number;

 EXCEPTION
	 WHEN OTHERS THEN
		 IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	         FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'EXCEPTION: ' || sqlerrm);
		 END IF;
         IF get_commitment_number_csr %ISOPEN THEN
            CLOSE get_commitment_number_csr ;
         END IF;

     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
	     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
     END IF;

     return null;

END get_commiment_number;

 -- Function to validate whether the covered level is a standard item or a component.
 -- Parameter: p_line_id - Sub line ID.
 FUNCTION validate_component_yn(p_line_id IN NUMBER)
                                RETURN VARCHAR2 AS

 l_api_name         CONSTANT VARCHAR2(30) := 'validate_component_yn';
 l_component_yn     VARCHAR2(5);

CURSOR is_component_yn_cur(l_line_id IN NUMBER) IS
SELECT
 (CASE WHEN oel1.inventory_item_id = csi.inventory_item_id THEN
  'N'
  ELSE
  'Y'
  END) isComponentFlag
FROM okc_k_items itm
     ,csi_item_instances csi
     ,oe_order_lines_all oel
     ,oe_order_lines_all oel1
     ,(SELECT rel.object1_id1,
         rel.cle_id
       FROM okc_k_rel_objs rel
       WHERE rel.cle_id = l_line_id
       AND rel.jtot_object1_code = 'OKX_ORDERLINE' ) x
WHERE itm.cle_id = x.cle_id
AND itm.object1_id1 = csi.instance_id
AND x.object1_id1 = oel.line_id
AND oel.service_reference_line_id = oel1.line_id (+)
AND oel.service_reference_type_code = 'ORDER';

 BEGIN

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'Entered '||G_PKG_NAME ||'.'||l_api_name);
   END IF;

   OPEN is_component_yn_cur(p_line_id);
   FETCH is_component_yn_cur INTO l_component_yn;
   IF is_component_yn_cur%NOTFOUND THEN
      l_component_yn := 'N';
   END IF;
   CLOSE is_component_yn_cur;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name);
   END IF;

   RETURN l_component_yn;

 EXCEPTION
   WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        'Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;
      IF is_component_yn_cur%ISOPEN THEN
            CLOSE is_component_yn_cur ;
      END IF;
      l_component_yn := 'N';
      RETURN l_component_yn;
 END validate_component_yn;


END OKS_MISC_UTIL_WEB;

/
