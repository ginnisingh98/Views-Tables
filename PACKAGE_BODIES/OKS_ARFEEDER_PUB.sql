--------------------------------------------------------
--  DDL for Package Body OKS_ARFEEDER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_ARFEEDER_PUB" AS
/* $Header: OKSPARFB.pls 120.27.12010000.8 2009/10/09 09:38:23 harlaksh ship $ */


Procedure Populate_TR_reference_fields(p_instance_number   IN   NUMBER,
                                       p_contract_number   IN   VARCHAR2,
                                       p_contract_modifier IN   VARCHAR2,
                                       x_return_status     OUT NOCOPY  VARCHAR2);

--mchoudha Fix for bug#4174921
--added parameter p_hdr_id
Procedure Set_Reference_PB_Value(
                           p_bsl_id         IN         NUMBER,
                           p_contract_no    IN         VARCHAR2,
                           p_contract_mod   IN         VARCHAR2,
                           p_bill_inst_no   IN         NUMBER,
                           p_amount         IN         NUMBER,
                           p_int_att10      IN         VARCHAR2,
                           p_bcl_cle_id     IN         NUMBER,
                           p_currency_code  IN         VARCHAR2,
                           p_hdr_id         IN         NUMBER,
                           x_msg_cnt        OUT NOCOPY NUMBER,
                           x_msg_data       OUT NOCOPY VARCHAR2,
                           x_return_status  OUT NOCOPY VARCHAR2
                           );
------------------------------------------


Function get_authoring_org_id (p_chrid NUMBER) Return NUMBER Is

Cursor l_hdrs_csr Is
 SELECT Authoring_Org_Id FROM OKC_K_HEADERS_B
 WHERE id = p_chrid;

l_orgid  NUMBER;
BEGIN

  OPEN  l_hdrs_csr;
  FETCH l_hdrs_csr Into l_orgid;
  CLOSE l_hdrs_csr;

  Return (l_orgid);

END get_authoring_org_id;


Function get_month Return Varchar2 Is
Cursor l_month_csr Is
 SELECT uom_code FROM okc_time_code_units_b
 WHERE  tce_code = 'MONTH'
 AND quantity = 1;

l_mnth varchar2(240);
BEGIN
  OPEN  l_month_csr;
  FETCH l_month_csr Into l_mnth;
  CLOSE l_month_csr;

  Return (l_mnth);

END get_month;


Function get_organization_id (p_chrid NUMBER) Return NUMBER Is

Cursor l_hdrs_csr Is
SELECT Org_Id FROM OKC_K_HEADERS_B
 WHERE id = p_chrid;

l_orgid           NUMBER;
l_organization_id NUMBER;
BEGIN

  OPEN  l_hdrs_csr;
  FETCH l_hdrs_csr Into l_orgid;
  CLOSE l_hdrs_csr;

  okc_context.set_okc_org_context(l_orgid, Null);
  l_organization_id := okc_context.get_okc_organization_id;

  Return (l_organization_id);

END get_organization_id;

FUNCTION get_acct_calender (p_set_of_books_id NUMBER) RETURN VARCHAR IS
 CURSOR l_calender (p_gl_set_of_books_id  IN  NUMBER) IS
  SELECT period_set_name FROM gl_sets_of_books
  WHERE set_of_books_id = p_gl_set_of_books_id;

 l_acct_cal    VARCHAR2(15);
BEGIN
  OPEN  l_calender(p_set_of_books_id);
  FETCH l_calender INTO l_acct_cal;
  CLOSE l_calender;

  RETURN(l_acct_cal);

END get_acct_calender;

Function get_set_of_books_id (p_chrid NUMBER) Return NUMBER Is

Cursor l_hdrs_csr Is Select Org_Id From OKC_K_HEADERS_B
                       Where id = p_chrid;

Cursor l_org_csr (p_org_id NUMBER)  Is
 SELECT OI2.ORG_INFORMATION3 set_of_books_id
  FROM
               HR_ORGANIZATION_INFORMATION OI2,
               HR_ORGANIZATION_INFORMATION OI1,
               HR_ALL_ORGANIZATION_UNITS OU
          WHERE oi1.organization_id = ou.organization_id
          AND   oi2.organization_id = ou.organization_id
          AND   oi1.org_information_context = 'CLASS'
          AND   oi1.org_information1 = 'OPERATING_UNIT'
          AND   oi2.org_information_context =  'Operating Unit Information'
          AND   ou.organization_id = p_org_id;

  /* Above select avoids OKX view usage
  SELECT set_of_books_id From OKX_ORGANIZATION_DEFS_V
  WHERE  organization_type = 'OPERATING_UNIT'
  AND    information_type  = 'Operating Unit Information'
  AND    organization_id   = p_org_id;
  */

l_orgid            NUMBER;
l_set_of_books_id  NUMBER;

BEGIN

  OPEN  l_hdrs_csr;
  FETCH l_hdrs_csr Into l_orgid;
  CLOSE l_hdrs_csr;

  OPEN  l_org_csr (l_orgid);
  FETCH l_org_csr Into l_set_of_books_id ;
  CLOSE l_org_csr;

  Return (l_set_of_books_id);

END get_set_of_books_id;

Procedure Set_line_attribute (p_cle_id                  IN   NUMBER,
                              p_date_billed_From        IN   DATE,
                              p_block23text             IN   VARCHAR2,
                              p_invoice_text            IN   VARCHAR2,
                              p_item_description        IN   VARCHAR2,
                              p_bill_instance_number    IN   NUMBER,
                              p_amount                  IN   NUMBER,
                              p_inv_print_flag          IN   VARCHAR2,
                              p_attribute1              IN   VARCHAR2,
                              p_attribute2              IN   VARCHAR2,
                              p_attribute3              IN   VARCHAR2,
                              p_attribute4              IN   VARCHAR2,
                              p_attribute5              IN   VARCHAR2,
                              p_attribute6              IN   VARCHAR2,
                              p_attribute7              IN   VARCHAR2,
                              p_attribute8              IN   VARCHAR2,
                              p_attribute9              IN   VARCHAR2,
                              p_attribute10             IN   VARCHAR2,
                              p_attribute11             IN   VARCHAR2,
                              p_attribute12             IN   VARCHAR2,
                              p_attribute13             IN   VARCHAR2,
                              p_attribute14             IN   VARCHAR2,
                              p_attribute15             IN   VARCHAR2,
                              p_attribute_category      IN   VARCHAR2)
IS
Cursor cur_line_sll_count (p_cle_id in NUMBER,p_date in Date) IS
 SELECT count(lvl.id) tot_no_of_lvl,sub.nos no_of_lvl
      from oks_level_elements  lvl,
           (select count(*) nos
             from oks_level_elements lev
             where lev.cle_id = p_cle_id
             and   trunc(lev.date_start) <=  trunc(p_date)
             ) sub
      WHERE   lvl.cle_id = p_cle_id
      GROUP BY sub.nos;

sll_rec                CUR_LINE_SLL_COUNT%ROWTYPE;
BEGIN


  OPEN  cur_line_sll_count(p_cle_id,
                           p_date_billed_from);
  FETCH cur_line_sll_count into  sll_rec;
  CLOSE cur_line_sll_count;

  G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE10 := to_char(sll_rec.no_of_lvl)||' of '||to_char(sll_rec.tot_no_of_lvl);

  G_RAIL_REC.PRINTING_OPTION :=  'PRI';

  IF ( p_inv_print_flag = 'N')  THEN
    G_RAIL_REC.PRINTING_OPTION :=  'NOT' ;
  END IF;

/* Modified by sjanakir for Bug#7234818 */
  G_RAIL_REC.DESCRIPTION := substrb(NVL(p_invoice_text, p_item_description)||':',1,240);
  G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE3 := TO_CHAR(p_bill_instance_number);
  G_RAIL_REC.AMOUNT                    := p_amount;
  G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE6 := to_char(p_amount);

  G_RAIL_REC.ATTRIBUTE1                := substrb(p_attribute1,0,150);
  G_RAIL_REC.ATTRIBUTE2                := substrb(p_attribute2,0,150);
  G_RAIL_REC.ATTRIBUTE3                := substrb(p_attribute3,0,150);
  G_RAIL_REC.ATTRIBUTE4                := substrb(p_attribute4,0,150);
  G_RAIL_REC.ATTRIBUTE5                := substrb(p_attribute5,0,150);
  G_RAIL_REC.ATTRIBUTE6                := substrb(p_attribute6,0,150);
  G_RAIL_REC.ATTRIBUTE7                := substrb(p_attribute7,0,150);
  G_RAIL_REC.ATTRIBUTE8                := substrb(p_attribute8,0,150);
  G_RAIL_REC.ATTRIBUTE9                := substrb(p_attribute9,0,150);
  G_RAIL_REC.ATTRIBUTE10               := substrb(p_attribute10,0,150);
  G_RAIL_REC.ATTRIBUTE11               := substrb(p_attribute11,0,150);
  G_RAIL_REC.ATTRIBUTE12               := substrb(p_attribute12,0,150);
  G_RAIL_REC.ATTRIBUTE13               := substrb(p_attribute13,0,150);
  G_RAIL_REC.ATTRIBUTE14               := substrb(p_attribute14,0,150);
  G_RAIL_REC.ATTRIBUTE15               := substrb(p_attribute15,0,150);
  G_RAIL_REC.ATTRIBUTE_CATEGORY        := substr(p_attribute_category,0,30);

END Set_line_attribute;


Procedure Set_ref_line_id(
                 p_bill_action       IN           VARCHAR2,
                 p_lse_id            IN           NUMBER,
                 p_cle_id            IN           NUMBER,
                 p_id                IN           NUMBER,
                 p_date_billed_From  IN           DATE,
                 p_date_billed_to    IN           DATE,
                 p_hdr_comm_id       IN           NUMBER,
                 p_line_comm_id      IN           NUMBER,
                 p_contract_number   IN           VARCHAR2,
                 p_con_modifier      IN           VARCHAR2,
                 p_average           IN           NUMBER,
                 p_top_line          IN           VARCHAR2,
                 p_line_payment_mth  IN           VARCHAR2,
                 p_return_status     IN OUT NOCOPY VARCHAR2
        --       x_cust_trx_id       OUT  NOCOPY  NUMBER,
        --       x_cust_trx_line_id  OUT  NOCOPY  NUMBER
                           )
IS
Cursor l_get_cov_lvl(p_cle_id IN NUMBER) IS SELECT id from okc_k_lines_b WHERE cle_id = p_cle_id AND   lse_id in (18,25); Cursor Cur_billinstance_hdr (p_date_billed_from   IN DATE, p_date_billed_to     IN DATE,
                             p_id                 IN NUMBER,
                             p_contract_number    IN VARCHAR2,
                             p_con_modifier       IN VARCHAR2)IS
 SELECT  c.Customer_trx_line_id,
         d.trx_date,
         d.exchange_rate_type,d.exchange_date, d.exchange_rate
   FROM    OKS_BILL_CONT_LINES a
         , oks_bill_txn_lines b
         , ra_customer_trx_all d  --Okx_customer_trx_v d
         , ra_customer_trx_lines_all c --Okx_cust_trx_lines_v c
   WHERE   a.date_billed_to = p_date_billed_to -- Bcl_rec.date_billed_to
   AND     a.cle_id = p_id -- Bcl_rec.cle_id
   AND     a.id = b.bcl_id
   AND     a.bill_action = 'RI'
   AND     c.sales_order = p_contract_number||
                                   decode(p_con_modifier,null,'','-'||p_con_modifier)
   AND     c.interface_line_attribute1 = p_contract_number
   AND     nvl(c.interface_line_attribute2,'-') = nvl(p_con_modifier ,'-')
   AND     c.Interface_line_attribute3 = b.bill_instance_number
   AND     c.Interface_line_context =  'OKS CONTRACTS'
   AND     c.customer_trx_id = d.customer_trx_id
   ORDER BY c.extended_amount ;

Cursor Cur_billinstance (
                             p_contract_number      IN VARCHAR2,
                             p_contract_modifier    IN VARCHAR2,
                             p_bill_instance_number IN NUMBER)IS
  SELECT  c.Customer_trx_line_id,
          --c.customer_trx_id,
          d.trx_date,
          d.exchange_rate_type,d.exchange_date, d.exchange_rate
       FROM  ra_customer_trx_all  d, --Okx_customer_trx_v d
             ra_customer_trx_lines_all c --Okx_cust_trx_lines_v c
       WHERE c.interface_line_attribute1 = p_contract_number
       AND  nvl(c.interface_line_attribute2,'-') = nvl(p_contract_modifier ,'-')
       AND  c.Interface_line_attribute3 = to_char(p_bill_instance_number)
       AND  c.sales_order = p_contract_number||
                               decode(p_contract_modifier,null,'','-'||p_contract_modifier)
       AND  c.Interface_line_context =  'OKS CONTRACTS'
       AND  c.customer_trx_id = d.customer_trx_id
       ORDER BY c.extended_amount ;

Cursor Cur_billinstance_dtl (p_date_from         IN DATE,
                             p_date_to           IN DATE,
                             p_id                IN NUMBER,
                             p_contract_number   IN VARCHAR2,
                             p_contract_modifier IN VARCHAR2)IS
       SELECT  c.Customer_trx_line_id,
               --c.customer_trx_id,
               d.trx_date,
               d.exchange_rate_type,d.exchange_date, d.exchange_rate
       FROM    OKS_BILL_SUB_LINES a
             , oks_bill_cont_lines e
             , oks_bill_txn_lines b
             , ra_customer_trx_all  d
             , ra_customer_trx_lines_all c
       WHERE   a.DATE_Billed_to = p_date_to -- Bsl_rec.date_billed_to
       AND     a.cle_id = p_id -- Bsl_rec.cle_id
       AND     a.id = b.bsl_id
       AND     a.bcl_id = e.id
       AND     e.bill_action = 'RI'
       AND     c.Interface_line_Attribute1 = p_contract_number
       AND     nvl(c.interface_line_attribute2,'-') = nvl(p_contract_modifier ,'-')
       AND     c.Interface_line_attribute3 = b.bill_instance_number
       AND     c.sales_order = p_contract_number||
                               decode(p_contract_modifier,null,'','-'||p_contract_modifier)
       AND     c.Interface_line_context =  'OKS CONTRACTS'
       AND     c.customer_trx_id = d.customer_trx_id
       ORDER BY c.extended_amount ;


Cursor bill_inst_number_cur(p_bcl_id in NUMBER) is
  SELECT average from oks_bill_sub_lines
  WHERE bcl_id = p_bcl_id;

Cursor l_get_order_line_id(p_cle_id IN NUMBER) IS
 SELECT object1_id1
  FROM okc_k_rel_objs
 WHERE cle_id = p_cle_id;

/***
   Bug# 4435961 -  serviceable item check to eliminate freight lines
   ***/
Cursor l_get_ref_id (p_line_id IN NUMBER) IS
 SELECT  txl.customer_trx_line_id ,txh.trx_date trx_date,
         txh.exchange_rate_type,txh.exchange_date, txh.exchange_rate
  FROM   ra_customer_trx_all txh ,
         ra_customer_trx_lines_all txl ,
	    mtl_system_items mtl
  WHERE txl.interface_line_attribute6 = to_char(p_line_id)
  AND   txl.interface_line_context = 'ORDER ENTRY'
  AND   txh.customer_trx_id = txl.customer_trx_id
  AND   txl.inventory_item_id = mtl.inventory_item_id
  AND   mtl.service_item_flag = 'Y';

Cursor  comm_id_cur (p_comm_id IN NUMBER)IS
  SELECT  rl.Customer_trx_line_id
    FROM  ra_customer_trx_lines_all   rl
   WHERE  rl.customer_trx_id = p_comm_id;



l_comm_id                  NUMBER;
l_sub_line_id              NUMBER;
l_order_line_id            NUMBER;
l_bill_instance_number     NUMBER;

l_CONVERSION_TYPE          VARCHAR2(30);
l_CONVERSION_DATE          DATE;
l_CONVERSION_RATE          NUMBER;
l_return_status            VARCHAR2(10) := 'S';

BEGIN

p_return_status    := 'S';

  -----IF (p_bill_action in ('AV','TR','STR')) THEN
IF (p_top_line = 'Y') THEN
  IF (p_bill_action in ('TR','STR')) THEN
    IF (p_lse_id in (14,19)) THEN
      OPEN  l_get_cov_lvl(p_cle_id);
      FETCH l_get_cov_lvl into l_sub_line_id;
      CLOSE l_get_cov_lvl;

      OPEN  l_get_order_line_id(l_sub_line_id);
      FETCH l_get_order_line_id INTO l_order_line_id;
      IF (l_get_order_line_id%NOTFOUND) THEN
        CLOSE l_get_order_line_id;
        OPEN  l_get_order_line_id(p_cle_id);
        FETCH l_get_order_line_id into l_order_line_id;
        IF (l_get_order_line_id%NOTFOUND) THEN
          CLOSE l_get_order_line_id;
          OPEN  bill_inst_number_cur(p_id);
          FETCH bill_inst_number_cur into l_bill_instance_number;
          CLOSE bill_inst_number_cur;

          /*Average field is used to stored
            bill_instance_number of parent INV record
          */

          IF (nvl(l_bill_instance_number,0) <> 0) THEN
            OPEN  Cur_billinstance(p_contract_number,
                                   p_con_modifier,
                                   l_bill_instance_number);

            FETCH Cur_billinstance INTO G_RAIL_REC.Reference_line_id,
                                        --x_cust_trx_id,
                                        G_RAIL_REC.TRX_DATE,
                                        l_CONVERSION_TYPE,
                                        l_CONVERSION_DATE,
                                        l_CONVERSION_RATE;

            IF Cur_billinstance%FOUND THEN
               G_RAIL_REC.CONVERSION_TYPE := l_CONVERSION_TYPE;
               G_RAIL_REC.CONVERSION_DATE := l_CONVERSION_DATE;
               G_RAIL_REC.CONVERSION_RATE := l_CONVERSION_RATE;
            END IF;

            CLOSE Cur_billinstance;

            IF G_RAIL_REC.Reference_line_id IS NULL THEN            ---autoinvoice not run

               Populate_TR_reference_fields(p_instance_number   => l_bill_instance_number,
                                            p_contract_number   => p_contract_number,
                                            p_contract_modifier => nvl(p_con_modifier,'-'),
                                            x_return_status     => l_return_status);

               IF ( l_return_status <> 'S') THEN
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Set_ref_line_id => Failed in populating refrence fields');
               END IF;

             END IF;

          /*Following if stat is for backward compatibility*/
          ELSE
            Open Cur_billinstance_hdr(
                                  p_date_billed_from,
                                  p_date_billed_to,
                                  p_cle_id,
                                  p_contract_number,
                                  p_con_modifier);

            Fetch Cur_billinstance_hdr INTO G_RAIL_REC.Reference_line_id,
                                            --x_cust_trx_id,
                                            G_RAIL_REC.TRX_DATE,
                                            l_CONVERSION_TYPE,
                                            l_CONVERSION_DATE,
                                            l_CONVERSION_RATE;

            IF Cur_billinstance_hdr%FOUND THEN
              G_RAIL_REC.CONVERSION_TYPE := l_CONVERSION_TYPE;
              G_RAIL_REC.CONVERSION_DATE := l_CONVERSION_DATE;
              G_RAIL_REC.CONVERSION_RATE := l_CONVERSION_RATE;
            END IF;

            Close Cur_billinstance_hdr;

            IF G_RAIL_REC.Reference_line_id IS NULL THEN            ---autoinvoice not run

              Populate_TR_reference_fields(p_instance_number   => NULL,
                                             p_contract_number   => p_contract_number,
                                             p_contract_modifier => nvl(p_con_modifier,'-'),
                                             x_return_status     => l_return_status);

               IF ( l_return_status <> 'S') THEN
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Set_ref_line_id => Failed in populating refrence fields');
               END IF;
            END IF;              ---Reference_line_id chk

          END IF;
          IF (trunc(G_RAIL_REC.TRX_DATE) < trunc(sysdate)) THEN
            G_RAIL_REC.TRX_DATE := sysdate;
          END IF;
        ELSE  -- l_get_order_line_id with line
          CLOSE l_get_order_line_id;
          G_RAIL_REC.CREDIT_METHOD_FOR_ACCT_RULE := 'LIFO';

          OPEN  l_get_ref_id(l_order_line_id);
          FETCH l_get_ref_id into G_RAIL_REC.Reference_line_id,
                                  G_RAIL_REC.TRX_DATE,
                                  l_CONVERSION_TYPE,
                                  l_CONVERSION_DATE,
                                  l_CONVERSION_RATE;

          IF l_get_ref_id%FOUND THEN
             G_RAIL_REC.CONVERSION_TYPE := l_CONVERSION_TYPE;
             G_RAIL_REC.CONVERSION_DATE := l_CONVERSION_DATE;
             G_RAIL_REC.CONVERSION_RATE := l_CONVERSION_RATE;
          END IF;

          CLOSE l_get_ref_id;

          IF (trunc(G_RAIL_REC.TRX_DATE) < trunc(sysdate)) Then
            G_RAIL_REC.TRX_DATE := sysdate;
          END IF;
        END IF; --l_get_order_line_id with line
      ELSE -- l_get_order_line_id with subline
        CLOSE l_get_order_line_id;
        G_RAIL_REC.CREDIT_METHOD_FOR_ACCT_RULE := 'LIFO';

        OPEN  l_get_ref_id(l_order_line_id);
        FETCH l_get_ref_id into G_RAIL_REC.Reference_line_id,
                                G_RAIL_REC.TRX_DATE,
                                l_CONVERSION_TYPE,
                                l_CONVERSION_DATE,
                                l_CONVERSION_RATE;

        IF l_get_ref_id%FOUND THEN
           G_RAIL_REC.CONVERSION_TYPE := l_CONVERSION_TYPE;
           G_RAIL_REC.CONVERSION_DATE := l_CONVERSION_DATE;
           G_RAIL_REC.CONVERSION_RATE := l_CONVERSION_RATE;
        END IF;
        CLOSE l_get_ref_id;

        IF (trunc(G_RAIL_REC.TRX_DATE) < trunc(sysdate)) THEN
          G_RAIL_REC.TRX_DATE := sysdate;
        END IF;
      END IF; --l_get_order_line_id with subline

    ELSE  --p_lse_id in 14,19
      OPEN  bill_inst_number_cur(p_id);
      FETCH bill_inst_number_cur into l_bill_instance_number;
      CLOSE bill_inst_number_cur;

      /*Average field is used to stored
        bill_instance_number of parent INV record
      */
      IF (nvl(l_bill_instance_number,0) <> 0) THEN
        OPEN Cur_billinstance (p_contract_number,
                               p_con_modifier,
                               l_bill_instance_number);

        FETCH Cur_billinstance INTO G_RAIL_REC.Reference_line_id,
                                    --x_cust_trx_id,
                                    G_RAIL_REC.TRX_DATE,
                                    l_CONVERSION_TYPE,
                                    l_CONVERSION_DATE,
                                    l_CONVERSION_RATE;

        IF Cur_billinstance%FOUND THEN
             G_RAIL_REC.CONVERSION_TYPE := l_CONVERSION_TYPE;
             G_RAIL_REC.CONVERSION_DATE := l_CONVERSION_DATE;
             G_RAIL_REC.CONVERSION_RATE := l_CONVERSION_RATE;
        END IF;
        CLOSE Cur_billinstance;

        IF G_RAIL_REC.Reference_line_id IS NULL THEN            ---autoinvoice not run

          Populate_TR_reference_fields(p_instance_number   => l_bill_instance_number,
                                       p_contract_number   => p_contract_number,
                                       p_contract_modifier => nvl(p_con_modifier,'-'),
                                       x_return_status     => l_return_status);

          IF ( l_return_status <> 'S') THEN
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Set_ref_line_id => Failed in populating refrence fields');
          END IF;
        END IF;



        /*Following if stat is for backward compatibility*/
      ELSE
        OPEN  Cur_billinstance_hdr(
                            p_date_billed_from,
                            p_date_billed_to,
                            p_cle_id,
                            p_contract_number,
                            p_con_modifier);
        FETCH Cur_billinstance_hdr INTO G_RAIL_REC.Reference_line_id,
                                        --x_cust_trx_id,
                                        G_RAIL_REC.TRX_DATE,
                                        l_CONVERSION_TYPE,
                                        l_CONVERSION_DATE,
                                        l_CONVERSION_RATE;

        IF Cur_billinstance_hdr%FOUND THEN
             G_RAIL_REC.CONVERSION_TYPE := l_CONVERSION_TYPE;
             G_RAIL_REC.CONVERSION_DATE := l_CONVERSION_DATE;
             G_RAIL_REC.CONVERSION_RATE := l_CONVERSION_RATE;
        END IF;
        CLOSE Cur_billinstance_hdr;

        IF G_RAIL_REC.Reference_line_id IS NULL THEN            ---autoinvoice not run

           Populate_TR_reference_fields(p_instance_number   => NULL,
                                        p_contract_number   => p_contract_number,
                                        p_contract_modifier => nvl(p_con_modifier,'-'),
                                        x_return_status     => l_return_status);

          IF ( l_return_status <> 'S') THEN
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Set_ref_line_id => Failed in populating refrence fields');
          END IF;
        END IF;              ---Reference_line_id chk
      END IF;

      IF (trunc(G_RAIL_REC.TRX_DATE) < trunc(sysdate)) Then
        G_RAIL_REC.TRX_DATE := sysdate;
      END IF;

    END IF; -- p_lse_id in 14,19


  END IF;  --p_bill_action = 'TR'
ELSE  --p_top_line = 'N'
  -----IF (p_bill_action in ('AV','TR','STR')) THEN
  IF (p_bill_action in ('TR','STR')) THEN

    OPEN  l_get_order_line_id(p_cle_id);
    FETCH l_get_order_line_id into l_order_line_id;
    IF (l_get_order_line_id%NOTFOUND) THEN
      CLOSE l_get_order_line_id;

      /*Average field is used to stored
        bill_instance_number of parent INV record
      */
      IF (nvl( p_average,0) <> 0) THEN
        OPEN Cur_billinstance (
                               p_contract_number,
                               p_con_modifier,
                               p_average);

        FETCH Cur_billinstance INTO G_RAIL_REC.Reference_line_id,
                                    --x_cust_trx_id,
                                    G_RAIL_REC.TRX_DATE,
                                    l_CONVERSION_TYPE,
                                    l_CONVERSION_DATE,
                                    l_CONVERSION_RATE;

        IF Cur_billinstance%FOUND THEN
             G_RAIL_REC.CONVERSION_TYPE := l_CONVERSION_TYPE;
             G_RAIL_REC.CONVERSION_DATE := l_CONVERSION_DATE;
             G_RAIL_REC.CONVERSION_RATE := l_CONVERSION_RATE;
        END IF;

        ClOSE Cur_billinstance;

        IF G_RAIL_REC.Reference_line_id IS NULL THEN            ---autoinvoice not run

          Populate_TR_reference_fields(
                              p_instance_number   => p_average,
                              p_contract_number   => p_contract_number,
                              p_contract_modifier => nvl(p_con_modifier,'-'),
                              x_return_status     => l_return_status);

          IF ( l_return_status <> 'S') THEN
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Set_ref_line_id Failed in populating refrence fields');
          END IF;
        END IF;              ---Reference_line_id chk

        /*Following if stat is for backward compatibility*/
      ELSE
        OPEN Cur_billinstance_dtl(
                                  p_date_billed_from,
                                  p_date_billed_to,
                                  p_cle_id,
                                  p_contract_number,
                                  p_con_modifier);
        FETCH Cur_billinstance_dtl INTO G_RAIL_REC.Reference_line_id,
                                        --x_cust_trx_id,
                                        G_RAIL_REC.TRX_DATE,
                                        l_CONVERSION_TYPE,
                                        l_CONVERSION_DATE,
                                        l_CONVERSION_RATE;

        IF Cur_billinstance_dtl%FOUND THEN
             G_RAIL_REC.CONVERSION_TYPE := l_CONVERSION_TYPE;
             G_RAIL_REC.CONVERSION_DATE := l_CONVERSION_DATE;
             G_RAIL_REC.CONVERSION_RATE := l_CONVERSION_RATE;
        END IF;
        CLOSE Cur_billinstance_dtl;

        IF G_RAIL_REC.Reference_line_id IS NULL THEN            ---autoinvoice not run

           Populate_TR_reference_fields(p_instance_number   => NULL,
                                        p_contract_number   => p_contract_number,
                                        p_contract_modifier => nvl(p_con_modifier,'-'),
                                        x_return_status     => l_return_status);

           IF ( l_return_status <> 'S') THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Set_ref_line_id Failed in populating refrence fields');
           END IF;
        END IF;              ---Reference_line_id chk

      END IF;

      IF (trunc(G_RAIL_REC.TRX_DATE) < trunc(sysdate)) Then
        G_RAIL_REC.TRX_DATE := sysdate;
      END IF;

    ELSE
      CLOSE  l_get_order_line_id;
      G_RAIL_REC.CREDIT_METHOD_FOR_ACCT_RULE := 'LIFO';
      OPEN  l_get_ref_id(l_order_line_id);
      FETCH l_get_ref_id into G_RAIL_REC.Reference_line_id,
                              G_RAIL_REC.TRX_DATE,
                              l_CONVERSION_TYPE,
                              l_CONVERSION_DATE,
                              l_CONVERSION_RATE;

      IF l_get_ref_id%FOUND THEN
          G_RAIL_REC.CONVERSION_TYPE := l_CONVERSION_TYPE;
          G_RAIL_REC.CONVERSION_DATE := l_CONVERSION_DATE;
          G_RAIL_REC.CONVERSION_RATE := l_CONVERSION_RATE;

      ELSE   --- skip and process after Auto Invoice run
	/****
	     Refer Bug# 4304841
	     The records are fetched from ra Interface Lines
	     if auto Invoice has not run for OM originated contracts
	****/

          FND_FILE.PUT_LINE(FND_FILE.LOG,'Auto Invoice not run for Order line '||l_order_line_id);
          p_return_status := 'E';
      END IF;

      CLOSE l_get_ref_id;


      IF (trunc(G_RAIL_REC.TRX_DATE) < trunc(sysdate)) Then
        G_RAIL_REC.TRX_DATE := sysdate;
      END IF;

    END IF;  --l_get_order_line_id

  /********
  ELSE


    G_RAIL_REC.reference_line_id := NULL;
    IF ( nvl(p_line_payment_mth,'XX') <> 'CCR') THEN
      l_comm_id := NULL;

      IF (p_line_comm_id IS NOT NULL) THEN

        l_comm_id := p_line_comm_id ;

        If G_LOG_YES_NO = 'YES' then
           FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Set_ref_line_id IPM:line_level '||l_comm_id);
        End If;

      ELSE

        l_comm_id := p_hdr_comm_id ;
        If G_LOG_YES_NO = 'YES' then
           FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Set_ref_line_id IPM:header_level '||l_comm_id);
        End If;

      END IF;

      IF (l_comm_id IS NOT NULL) THEN

        OPEN comm_id_cur(l_comm_id);
        FETCH comm_id_cur into G_RAIL_REC.reference_line_id;
        CLOSE comm_id_cur;
        If G_LOG_YES_NO = 'YES' then
           FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Set_ref_line_id IPM:reference_line_id '||G_RAIL_REC.reference_line_id);
        End If;
        G_RAIL_REC.CUSTOMER_BANK_ACCOUNT_ID  :=  NULL;
        G_RAIL_REC.RECEIPT_METHOD_NAME := NULL;
        G_RAIL_REC.RECEIPT_METHOD_ID   := NULL;


      ELSE

        G_RAIL_REC.reference_line_id := NULL;

      END IF;
    END IF;

*********/

  END IF;

END IF;
--x_cust_trx_line_id := G_RAIL_REC.reference_line_id;

END Set_ref_line_id;

Procedure Set_cust_trx_type(p_set_of_books_id          IN  NUMBER,
                            p_bill_action              IN  VARCHAR2,
                            p_hdr_sbg_object1_id1      IN  NUMBER,
                            p_authoring_org_id         IN  NUMBER)
IS

--19-NOV-2003 Bug#3266871   mchoudha
/*Changed this procedure Set_cust_trx_type
to include two cursors  Cur_custtrx_type_id1
and Cur_custtrx_type_id2 in place of
Cur_custtrx_type_id for performance
*/

Cursor  Cur_custtrx_type_id1 (p_id          IN NUMBER,
                            p_type        IN VARCHAR2,
                            p_object1_id1  IN NUMBER,
                            p_org_id      IN NUMBER) IS
    Select  decode(p_type,'INV',Cust_trx_type_id,'CM',credit_memo_type_id),
        post_to_gl
        From    RA_CUST_TRX_TYPES_ALL
        Where  SET_OF_BOOKS_ID = p_id
        And    org_id = p_org_id
      And    Cust_trx_type_id = p_object1_id1;


Cursor  Cur_custtrx_type_id2(p_id          IN NUMBER,
                            p_type        IN VARCHAR2,
                            p_org_id      IN NUMBER) IS

     Select  /*+  PARALLEL(a) */

       decode(p_type,'INV',Cust_trx_type_id,'CM',credit_memo_type_id),
       post_to_gl
        From    RA_CUST_TRX_TYPES_ALL a
        Where  a.SET_OF_BOOKS_ID = p_id
        And    a.org_id = p_org_id
        And  a.type = 'INV'
        And  a.name = 'Invoice-OKS';

l_post_to_gl                         VARCHAR2(1);

BEGIN
  -----IF (p_bill_action in ('AV','TR','STR')) THEN
  IF (p_bill_action in ('TR','STR')) THEN
    If (p_hdr_sbg_object1_id1 IS NOT NULL) Then
      Open Cur_custtrx_type_id1(p_set_of_books_id,
                                'CM',
                                p_hdr_sbg_object1_id1,
                                p_authoring_org_id);
      Fetch Cur_custtrx_type_id1 INTO G_RAIL_REC.CUST_TRX_TYPE_ID,l_post_to_gl;
      Close Cur_custtrx_type_id1;
    Else
      Open Cur_custtrx_type_id2(p_set_of_books_id,
                               'CM',
                                p_authoring_org_id);
      Fetch Cur_custtrx_type_id2 INTO G_RAIL_REC.CUST_TRX_TYPE_ID,l_post_to_gl;
      Close Cur_custtrx_type_id2;
    End If;

    G_RAIL_REC.CREDIT_METHOD_FOR_ACCT_RULE := 'UNIT';
  ELSE
    If (p_hdr_sbg_object1_id1 IS NOT NULL) Then
      Open Cur_custtrx_type_id1(p_set_of_books_id,
                                'INV',
                                p_hdr_sbg_object1_id1,
                                p_authoring_org_id);
      Fetch Cur_custtrx_type_id1 INTO G_RAIL_REC.CUST_TRX_TYPE_ID,l_post_to_gl;
      Close Cur_custtrx_type_id1;
    Else
      Open Cur_custtrx_type_id2(p_set_of_books_id,
                                'INV',
                                p_authoring_org_id);
      Fetch Cur_custtrx_type_id2 INTO G_RAIL_REC.CUST_TRX_TYPE_ID,l_post_to_gl;
      Close Cur_custtrx_type_id2;
    End If;
  END IF;

   ----added for bug#3902948 (FP:3873737).
  IF NVL(l_post_to_gl,'N') <> 'Y' THEN
     G_RAIL_REC.GL_DATE := NULL;
  END IF;

END Set_cust_trx_type;

/***************
  Procedure to set transaction ext. id for invoice lines if Extension is captured
  for the contract .
  Transaction ext. id will be cascaded from contract to lines only if the billto
  account matches for the Party
***************/


Procedure set_extn_id_at_party ( p_bill_to_site_use_id    IN     NUMBER,
                                 p_ext_id             IN     NUMBER,
                                 p_cust_account_id    IN     NUMBER,
		                 p_org_id             IN     NUMBER)

IS

Cursor  line_party_cur(p_cust_account IN NUMBER, p_org_id  IN NUMBER)IS
  SELECT  party_id
    FROM  hz_cust_accounts_all
   WHERE  cust_account_id = p_cust_account
   AND    nvl(org_id,p_org_id)  = p_org_id;

Cursor hdr_party_cur(p_bill_to_site_use_id  IN NUMBER,
                        p_org_id IN NUMBER) IS
  SELECT hz.party_id from hz_party_sites hz
  where  hz.party_site_id in (
          SELECT site.party_site_id from hz_cust_acct_sites_all site
          where site.cust_acct_site_id in
                                  ( select uses.cust_acct_site_id
                                    from hz_cust_site_uses_all uses
                                    where site_use_id = p_bill_to_site_use_id
				    and   site_use_code = 'BILL_TO')
          and nvl(site.org_id,p_org_id) = p_org_id);

l_line_party_id   number;
l_hdr_party_id   number;

BEGIN
         OPEN  line_party_cur(p_cust_account_id,p_org_id);
         FETCH line_party_cur into l_line_party_id;
         IF line_party_cur%FOUND THEN
              OPEN  hdr_party_cur(p_bill_to_site_use_id,p_org_id);
              FETCH hdr_party_cur into l_hdr_party_id;
              IF hdr_party_cur%FOUND THEN
	     /*Commented and Modified by sjanakir for Bug #6855301
                  IF l_line_party_id = l_line_party_id  THEN */
		  IF l_line_party_id = l_hdr_party_id  THEN
                        G_RAIL_REC.payment_trxn_extension_id  :=  p_ext_id;
		      	/* Commented by sjanakir for Bug #6855301
                        G_RAIL_REC.receipt_method_id :=  to_number(nvl(FND_PROFILE.VALUE_SPECIFIC('OKS_RECEIPT_METHOD_ID', NULL, NULL, NULL, p_org_id, NULL),'0')); */

                  Else
                       FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB. no Transaction Ext. Id for line  ');
                  End if;
              End If;
              Close hdr_party_cur;
         End If;

         CLOSE line_party_cur;


END set_extn_id_at_party;


/***************
  Procedure to set commitment for invoice lines if commitment number is captured
  for the top line.
  commitment for the header will be cascaded to lines only if the billto account
  matches for the customer
***************/

Procedure set_commitment (p_hdr_commitment     IN     NUMBER,
                          p_bill_to_site_use_id    IN     NUMBER,
                          p_line_commitment    IN     NUMBER,
                          p_line_id            IN     NUMBER,
                          p_dnz_chr_id         IN     NUMBER,
                          p_cust_account_id    IN     NUMBER,
		          p_org_id             IN     NUMBER)
IS

Cursor  comm_id_cur (p_comm_id IN NUMBER, p_org_id  IN NUMBER)IS
  SELECT  rl.Customer_trx_line_id
    FROM  ra_customer_trx_lines_all   rl
   WHERE  rl.customer_trx_id = p_comm_id
   AND    rl.org_id          = p_org_id;

Cursor cur_cust_account(p_bill_to_site_use_id  IN NUMBER,
                        p_org_id IN NUMBER) IS
  SELECT site.cust_account_id from hz_cust_acct_sites_all site
  where site.cust_acct_site_id in
                                  ( select uses.cust_acct_site_id
                                    from hz_cust_site_uses_all uses
                                    where site_use_id = p_bill_to_site_use_id
				    and   site_use_code = 'BILL_TO')
  and  nvl(site.org_id,p_org_id) = p_org_id;

l_cust_account   number;

BEGIN

     IF (p_line_commitment is not null) Then
         OPEN comm_id_cur(p_line_commitment,p_org_id);
         FETCH comm_id_cur into G_RAIL_REC.reference_line_id;
         CLOSE comm_id_cur;
         If G_LOG_YES_NO = 'YES' then
              FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Set_ref_line_id IPM:reference_line_id '||G_RAIL_REC.reference_line_id);
         End If;

-----check if hdr bill to account matches with the line bill to cascade commitment
     Elsif (p_hdr_commitment is not null) Then
         OPEN cur_cust_account(p_bill_to_site_use_id,p_org_id);
         FETCH cur_cust_account into l_cust_account;
         CLOSE cur_cust_account;

	 If l_cust_account = p_cust_account_id Then
             OPEN comm_id_cur(p_hdr_commitment,p_org_id);
             FETCH comm_id_cur into G_RAIL_REC.reference_line_id;
             CLOSE comm_id_cur;

             If G_LOG_YES_NO = 'YES' then
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Set_ref_line_id IPM:reference_line_id '||G_RAIL_REC.reference_line_id);
             End If;
         Else
              FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB. no commitment for line  ');
         End If;

      END IF;

END set_commitment;


 /* This procedure  is called twice in program.
    First time it is called with top_line_id and second time it
    is called with sub_line_id.
 */
Procedure Set_qty_and_uom(p_cle_id             IN     NUMBER,
                          p_dnz_chr_id         IN     NUMBER,
                          p_date_billed_from   IN     DATE,
                          p_date_billed_to     IN     DATE,
                          p_bill_action        IN     VARCHAR2,
                          p_lse_id             IN     NUMBER,
                          p_top_line           IN     VARCHAR2)
IS
Cursor Cur_item(p_id  IN NUMBER) IS
  SELECT  Object1_id1,
          Number_of_items,
          UOM_code,
          object1_id2
  FROM    OKC_K_ITEMS
  WHERE   CLE_ID = p_id;

Cursor Prim_uom_cur(p_id In NUMBER, p_org_id IN NUMBER) IS
  SELECT  primary_uom_code
   From   mtl_system_items_b
  WHERE   inventory_item_id = p_id
  AND     organization_id = p_org_id;


l_status               VARCHAR2(10);
item_rec               CUR_ITEM%ROWTYPE;
BEGIN
  OPEN  Cur_item(p_cle_id);
  FETCH Cur_item into item_rec;
  CLOSE Cur_item;


--  IF (p_top_line = 'Y') THEN

    ---IF (p_bill_action in ('AV','TR','STR')) THEN
    IF (p_bill_action in ('TR','STR')) THEN
      G_RAIL_REC.INVENTORY_ITEM_ID := NULL;
    ELSE
      G_RAIL_REC.INVENTORY_ITEM_ID := item_rec.Object1_id1;


  /********
        Bug# 4589116 : Hologic
        The profile option determines if contract line inventory org is used
        when calculating service line tax thorugh vertex.
  ****/
        G_RAIL_REC.WAREHOUSE_ID := NULL;
        if nvl(fnd_profile.value('OKS_INV_ORG_TAX_COMPUTE'),'NO') = 'YES'
                  Then
               G_RAIL_REC.WAREHOUSE_ID := item_rec.Object1_id2;
        End if;

    END IF;

    G_RAIL_REC.QUANTITY          := item_rec.Number_of_items;


    OKC_TIME_UTIL_PUB.get_duration
     ( p_start_date  => p_date_billed_from,
       p_end_date    => p_date_billed_to,
       x_duration    => G_RAIL_REC.QUANTITY_ORDERED,
       x_timeunit    => G_RAIL_REC.UOM_CODE,
       x_return_status => l_status
     );

    IF (p_lse_id in (12,46)) THEN
--The following line of code will be executed only for subscription
--for Bug#4390448
    IF p_lse_id = 46 THEN
      G_RAIL_REC.QUANTITY_ORDERED  := item_rec.Number_of_items;
    END IF;

      OPEN  prim_uom_cur(G_RAIL_REC.INVENTORY_ITEM_ID,
                         get_organization_id (p_dnz_chr_id));
      FETCH prim_uom_cur into G_RAIL_REC.UOM_CODE;
      CLOSE prim_uom_cur;
    END IF;
---commented for bug#3121402
--  ELSIF (p_top_line = 'N') THEN
  --  G_RAIL_REC.QUANTITY          := item_rec.Number_of_items;
 --   G_RAIL_REC.QUANTITY_ORDERED  := item_rec.Number_of_items;
--  END IF;  -- p_top_line
END Set_qty_and_uom;

Procedure Set_salesrep_id( p_dnz_chr_id        IN     NUMBER)
IS
Cursor l_Salesrep_csr(p_code          IN VARCHAR2,
                      p_dnz_chr_id    IN NUMBER) Is
SELECT     contact.object1_id1
  FROM     okc_contacts contact,
           okc_k_party_roles_b  party
  WHERE    contact.cpl_id   = party.id     --p_cpl_id
  AND      contact.cro_code = p_code
  AND      party.rle_code in ('VENDOR','MERCHANT')
  AND      party.dnz_chr_id = p_dnz_chr_id
  AND      party.cle_id is null;

l_cro_code                           Varchar2(30);
BEGIN
   l_cro_code := FND_PROFILE.VALUE('OKS_VENDOR_CONTACT_ROLE');

   OPEN  l_Salesrep_csr(l_cro_code, p_dnz_chr_id);
   FETCH l_Salesrep_csr into  G_RAIL_REC.PRIMARY_SALESREP_ID ;
   CLOSE l_Salesrep_csr;

END Set_salesrep_id;


Procedure Set_Attributes(p_contract_number     IN            VARCHAR2,
                         p_con_modifier        IN            VARCHAR2,
                         p_date_billed_from    IN            DATE,
                         p_date_billed_to      IN            DATE,
                         p_start_date          IN            DATE,
                         p_cle_id              IN            NUMBER,
                                        p_attribute_category  IN            VARCHAR2,
                         p_attribute1          IN            VARCHAR2,
                         p_attribute2          IN            VARCHAR2,
                         p_attribute3          IN            VARCHAR2,
                         p_attribute4          IN            VARCHAR2,
                         p_attribute5          IN            VARCHAR2,
                         p_attribute6          IN            VARCHAR2,
                         p_attribute7          IN            VARCHAR2,
                         p_attribute8          IN            VARCHAR2,
                         p_attribute9          IN            VARCHAR2,
                         p_attribute10         IN            VARCHAR2,
                         p_attribute11         IN            VARCHAR2,
                         p_attribute12         IN            VARCHAR2,
                         p_attribute13         IN            VARCHAR2,
                         p_attribute14         IN            VARCHAR2,
                         p_attribute15         IN            VARCHAR2,
                         p_currency_code       IN            VARCHAR2,
                         p_cust_po_number      IN            VARCHAR2,
                         p_dnz_chr_id          IN            NUMBER,
                         p_org_id              IN            VARCHAR2,
                         p_return_status       IN OUT NOCOPY VARCHAR2)
IS
Cursor l_get_top_line_lvl_id(p_cle_id IN NUMBER,p_start_date IN DATE) is
        SELECT to_char(ole.date_start,'YYYY/MM/DD')
        FROM oks_level_elements ole
        WHERE ole.cle_id = p_cle_id
        AND    trunc(p_start_date) >= trunc(ole.date_start)
        ORDER BY ole.date_start desc;
        --AND  p_start_date between ole.date_start and ole.date_end;

BEGIN
  p_return_status := 'S';

  G_RAIL_REC.BATCH_SOURCE_NAME               := 'OKS_CONTRACTS';
  G_RAIL_REC.CREATED_BY                      := FND_GLOBAL.user_id;
  G_RAIL_REC.CREATION_DATE                   := sysdate;
  G_RAIL_REC.LAST_UPDATED_BY                 := FND_GLOBAL.user_id;
  G_RAIL_REC.LAST_UPDATE_DATE                := sysdate;
  G_RAIL_REC.LINE_TYPE                       := G_LINE_TYPE;
  G_RAIL_REC.INTERFACE_LINE_CONTEXT          := 'OKS CONTRACTS';
  G_RAIL_REC.REASON_CODE                     := NULL;
  G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE1       := p_contract_number;
  G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE2       := NVL(p_con_modifier,'-');
  G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE4       := to_char(p_date_billed_from ,'YYYY/MM/DD');
  G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE5       := to_char(p_date_billed_to,'YYYY/MM/DD');

--Added on 3/25 for grouping rule please do not remove the following assignment

  OPEN l_get_top_line_lvl_id(p_cle_id , p_date_billed_from);
  FETCH l_get_top_line_lvl_id into G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE7;
  CLOSE l_get_top_line_lvl_id;

  G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE8  := to_char(p_start_date,'YYYY/MM/DD');
  G_RAIL_REC.RULE_START_DATE            := p_date_billed_from;
  G_RAIL_REC.RULE_END_DATE              := p_date_billed_to;
  G_RAIL_REC.SALES_ORDER_DATE           := SYSDATE;
  G_RAIL_REC.SALES_ORDER_SOURCE         := 'OKS_CONTRACTS';
  G_RAIL_REC.HEADER_ATTRIBUTE_CATEGORY  := substrb(p_attribute_category,0,150);
  G_RAIL_REC.HEADER_ATTRIBUTE1          := substrb(p_attribute1,0,150);
  G_RAIL_REC.HEADER_ATTRIBUTE2          := substrb(p_attribute2,0,150);
  G_RAIL_REC.HEADER_ATTRIBUTE3          := substrb(p_attribute3,0,150);
  G_RAIL_REC.HEADER_ATTRIBUTE4          := substrb(p_attribute4,0,150);
  G_RAIL_REC.HEADER_ATTRIBUTE5          := substrb(p_attribute5,0,150);
  G_RAIL_REC.HEADER_ATTRIBUTE6          := substrb(p_attribute6,0,150);
  G_RAIL_REC.HEADER_ATTRIBUTE7          := substrb(p_attribute7,0,150);
  G_RAIL_REC.HEADER_ATTRIBUTE8          := substrb(p_attribute8,0,150);
  G_RAIL_REC.HEADER_ATTRIBUTE9          := substrb(p_attribute9,0,150);
  G_RAIL_REC.HEADER_ATTRIBUTE10         := substrb(p_attribute10,0,150);
  G_RAIL_REC.HEADER_ATTRIBUTE11         := substrb(p_attribute11,0,150);
  G_RAIL_REC.HEADER_ATTRIBUTE12         := substrb(p_attribute12,0,150);
  G_RAIL_REC.HEADER_ATTRIBUTE13         := substrb(p_attribute13,0,150);
  G_RAIL_REC.HEADER_ATTRIBUTE14         := substrb(p_attribute14,0,150);
  G_RAIL_REC.HEADER_ATTRIBUTE15         := substrb(p_attribute15,0,150);
  G_RAIL_REC.CURRENCY_CODE              := p_currency_code;
  G_RAIL_REC.PURCHASE_ORDER             := p_cust_po_number;

  IF  (p_con_modifier Is not null)  THEN
    G_RAIL_REC.SALES_ORDER  := p_contract_number || '-' || p_con_modifier;
  ELSE
    G_RAIL_REC.SALES_ORDER  := p_contract_number;
  END IF;

  G_RAIL_REC.ORG_ID          :=  p_org_id;
  ----G_RAIL_REC.ORG_ID          := get_authoring_org_id (p_dnz_chr_id);


EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Set_Attributes => FAILED IN G_RAIL Field ASSIGNMENT FOR '|| p_cle_id||' Error '||sqlerrm);
    p_return_status := 'E';

END Set_Attributes;



Procedure Set_comments(p_bill_action   IN  VARCHAR2)
IS

Cursor fnd_csr (p_bill_action in varchar2) is
 select description from fnd_lookups
 where  lookup_type = 'OKS_BILL_ACTIONS'
 and    lookup_code = p_bill_action;


BEGIN
    OPEN  fnd_csr(p_bill_action);
    FETCH fnd_csr INTO G_RAIL_REC.COMMENTS;
    CLOSE fnd_csr;

  /*****
       commented as part of bug# 5860501

  IF (p_bill_action = 'TR') THEN
    G_RAIL_REC.COMMENTS   := 'Termination of contract with credit';
  ELSIF (p_bill_action = 'RI') THEN
    G_RAIL_REC.COMMENTS   := 'Regular Bill';
  ELSIF (p_bill_action in ('STR','SRI')) THEN
    G_RAIL_REC.COMMENTS   := 'Settlement Bill';
  ELSIF (p_bill_action = 'AV') THEN
    G_RAIL_REC.COMMENTS   := 'Average Bill';
  END IF;
***/

END Set_comments;


Procedure Set_gl_date(p_cle_id            IN  NUMBER,
                      p_date_billed_from  IN  DATE,
                      p_bill_action       IN  VARCHAR2)
IS
Cursor cur_line_sll_rule (p_cle_id             IN NUMBER,
                          p_date_billed_from   IN DATE) is

 SELECT str.invoice_offset_days --str.action_offset_days
  FROM  oks_stream_levels_b str,
        oks_level_elements lvl
  WHERE lvl.cle_id  = p_cle_id
  AND   trunc(p_date_billed_from) between trunc(lvl.date_start)
                                   and    trunc(lvl.date_end)
  AND   lvl.rul_id = str.id;

l_inv_offset          NUMBER;

BEGIN

 ----IF (p_bill_action NOT IN ('AV','TR','STR')) AND G_RAIL_REC.INVOICING_RULE_ID = -2 THEN
 IF (p_bill_action NOT IN ('TR','STR')) AND G_RAIL_REC.INVOICING_RULE_ID = -2 THEN
    OPEN  cur_line_sll_rule(p_cle_id,p_date_billed_from);
    FETCH cur_line_sll_rule INTO l_inv_offset;
    CLOSE cur_line_sll_rule;
 END IF;



 ----IF (p_bill_action in ('AV','TR','STR')) THEN
 IF (p_bill_action in ('TR','STR')) THEN
     G_RAIL_REC.GL_DATE := NULL;

 ELSIF (G_RAIL_REC.INVOICING_RULE_ID = -3) OR
       (G_RAIL_REC.INVOICING_RULE_ID = -2 AND l_inv_offset IS NULL) THEN

     G_RAIL_REC.GL_DATE := NULL;

 ELSIF G_RAIL_REC.INVOICING_RULE_ID = -2 AND l_inv_offset IS NOT NULL THEN

     IF TRUNC(p_date_billed_from) >= TRUNC(SYSDATE) THEN

        IF (TRUNC(p_date_billed_from) + l_inv_offset) >= TRUNC(SYSDATE) THEN
           G_RAIL_REC.GL_DATE := G_RAIL_REC.TRX_DATE;
        ELSE       --- <sysdate
           G_RAIL_REC.GL_DATE := SYSDATE;
        END IF;

     ELSE         ---- bill from < sysdate

        IF (TRUNC(p_date_billed_from) + l_inv_offset) >= TRUNC(SYSDATE) THEN
           G_RAIL_REC.GL_DATE := G_RAIL_REC.TRX_DATE;
        ELSE       --- <sysdate
           G_RAIL_REC.GL_DATE := NULL;
        END IF;

    END IF;        --chk for top line bill from

  END IF;

END Set_gl_date;



Procedure Set_aggrement_and_contacts(p_dnz_chr_id        IN  NUMBER,
                                     p_cle_id            IN  NUMBER,
                                     p_date_billed_from  IN  DATE,
                                     p_bill_action       IN  VARCHAR2)
IS
Cursor Cur_agg_id(p_id IN NUMBER) IS
    SELECT   Isa_agreement_id
    FROM     OKC_GOVERNANCES
    WHERE    dnz_Chr_id = p_id
    AND      cle_id Is Null;

Cursor Contact_csr( p_hdr_id NUMBER, p_cle_id NUMBER) Is
 SELECT Contact.object1_id1 , Contact.cro_code
 FROM  Okc_contacts Contact
      ,Okc_k_party_roles_B Party
 WHERE Contact.cpl_id    = Party.id
 AND   Contact.cro_code   in ('CUST_BILLING','CUST_SHIPPING')
 AND   p_date_billed_from between nvl(contact.start_date,p_date_billed_From) and
                                                    nvl(contact.end_date,p_date_billed_from)
 AND   party.dnz_chr_id  =  p_hdr_id
 AND   party.cle_id      =  p_cle_id
 AND   party.jtot_object1_code = 'OKX_PARTY';
BEGIN
  OPEN  Cur_agg_id(p_dnz_chr_id);
  FETCH Cur_agg_id into G_RAIL_REC.AGREEMENT_ID;
  CLOSE Cur_agg_id;

  FOR contact_rec in Contact_csr(p_dnz_chr_id,p_cle_id)
  LOOP
    IF (contact_rec.cro_code = 'CUST_BILLING') THEN
      G_RAIL_REC.ORIG_SYSTEM_BILL_CONTACT_ID     :=  contact_rec.object1_id1;
    ELSIF (contact_rec.cro_code = 'CUST_SHIPPING') THEN
      ----IF (p_bill_action not in ('AV','TR','STR')) THEN
      IF (p_bill_action not in ('TR','STR')) THEN
        G_RAIL_REC.ORIG_SYSTEM_SHIP_CONTACT_ID :=  contact_rec.object1_id1;
      END IF;
    END IF;
  END LOOP;
END Set_aggrement_and_contacts;



---------------------------------------------------------------------------
-- procedure insert_RA_interface
---------------------------------------------------------------------------
procedure insert_ra_interface(
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2
)
IS
  BEGIN
  x_return_status := 'S';

    If G_LOG_YES_NO = 'YES' then
       FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.insert_ra_interface => AMOUNT'||G_RAIL_REC.AMOUNT);
       FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.insert_ra_interface => BATCH_SOURCE_NAME'||G_RAIL_REC.BATCH_SOURCE_NAME);
       FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.insert_ra_interface => CURRENCY_CODE'||G_RAIL_REC.CURRENCY_CODE);
       FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.insert_ra_interface =>  SET_OF_BOOKS_ID '||G_RAIL_REC.SET_OF_BOOKS_ID);
       FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.insert_ra_interface => ORG_ID    '||G_RAIL_REC.ORG_ID);
    End If;


  IF ((G_RAIL_REC.CONVERSION_TYPE IS NULL) AND
         (G_RAIL_REC.CONVERSION_RATE is NULL)) THEN
    G_RAIL_REC.CONVERSION_TYPE := 'User';
    G_RAIL_REC.CONVERSION_RATE := 1;
  END IF;

  /***  this should be null to fix bug# 1612349  -- Hari

  if nvl(G_RAIL_REC.CONVERSION_TYPE, 'User') <> 'User' THEN
      G_RAIL_REC.CONVERSION_RATE := NULL;
  else
      G_RAIL_REC.CONVERSION_RATE := 1;
  end if;
  ***/

  /***conversion rate should be null if type <> user****/

  IF G_RAIL_REC.CONVERSION_TYPE <> 'User' THEN
     G_RAIL_REC.CONVERSION_RATE := NULL;
  END IF;

  INSERT INTO RA_INTERFACE_LINES_ALL (
     ACCOUNTING_RULE_ID
    ,ACCOUNTING_RULE_DURATION
    ,AGREEMENT_ID
    ,AMOUNT
    ,BATCH_SOURCE_NAME
    ,COMMENTS
    ,CONVERSION_DATE
    ,CONVERSION_RATE
    ,CONVERSION_TYPE
    ,CREATED_BY
    ,CREATION_DATE
    ,CREDIT_METHOD_FOR_ACCT_RULE
    ,CREDIT_METHOD_FOR_INSTALLMENTS
    ,CURRENCY_CODE
    ,CUST_TRX_TYPE_ID
    ,DESCRIPTION
    ,LAST_UPDATED_BY
    ,LAST_UPDATE_DATE
    ,LINE_TYPE
    ,TRX_DATE
    ,GL_DATE
    ,PRINTING_OPTION
    ,INTERFACE_LINE_ATTRIBUTE1
    ,INTERFACE_LINE_ATTRIBUTE2
    ,INTERFACE_LINE_ATTRIBUTE3
    ,INTERFACE_LINE_ATTRIBUTE4
    ,INTERFACE_LINE_ATTRIBUTE5
    ,INTERFACE_LINE_ATTRIBUTE6
    ,INTERFACE_LINE_ATTRIBUTE7
    ,INTERFACE_LINE_ATTRIBUTE8
    ,INTERFACE_LINE_ATTRIBUTE9
    ,INTERFACE_LINE_ATTRIBUTE10
    ,INTERFACE_LINE_ATTRIBUTE11
    ,INTERFACE_LINE_ATTRIBUTE12
    ,INTERFACE_LINE_ATTRIBUTE13
    ,INTERFACE_LINE_ATTRIBUTE14
    ,INTERFACE_LINE_ATTRIBUTE15
    ,INTERFACE_LINE_ID
    ,INTERFACE_LINE_CONTEXT
    ,INVENTORY_ITEM_ID
    ,INVOICING_RULE_ID
    ,ORIG_SYSTEM_BILL_CUSTOMER_ID
    ,ORIG_SYSTEM_BILL_ADDRESS_ID
    ,ORIG_SYSTEM_SHIP_CUSTOMER_ID
    ,ORIG_SYSTEM_SHIP_ADDRESS_ID
    ,ORIG_SYSTEM_BILL_CONTACT_ID
    ,ORIG_SYSTEM_SHIP_CONTACT_ID
    ,ORIG_SYSTEM_SOLD_CUSTOMER_ID
    ,PRIMARY_SALESREP_NUMBER
    ,PRIMARY_SALESREP_ID
    ,PURCHASE_ORDER
    ,PURCHASE_ORDER_REVISION
    ,PURCHASE_ORDER_DATE
    ,CUSTOMER_BANK_ACCOUNT_ID
    ,RECEIPT_METHOD_ID
    ,RECEIPT_METHOD_NAME
    ,QUANTITY
    ,QUANTITY_ORDERED
    ,REASON_CODE
    ,REASON_CODE_MEANING
    ,REFERENCE_LINE_ID
    ,RULE_START_DATE
    ,RULE_END_DATE
    ,SALES_ORDER
    ,SALES_ORDER_LINE
    ,CONTRACT_LINE_ID
    ,SALES_ORDER_DATE
    ,SALES_ORDER_SOURCE
    ,SET_OF_BOOKS_ID
    ,TAX_EXEMPT_FLAG
    ,TAX_EXEMPT_NUMBER
    ,TAX_EXEMPT_REASON_CODE
    ,TAX_CODE
    ,TERM_ID
    ,UNIT_SELLING_PRICE
    ,UNIT_STANDARD_PRICE
    ,UOM_CODE
    ,HEADER_Attribute_CATEGORY
    ,HEADER_Attribute1
    ,HEADER_Attribute2
    ,HEADER_Attribute3
    ,HEADER_Attribute4
    ,HEADER_Attribute5
    ,HEADER_Attribute6
    ,HEADER_Attribute7
    ,HEADER_Attribute8
    ,HEADER_Attribute9
    ,HEADER_Attribute10
    ,HEADER_Attribute11
    ,HEADER_Attribute12
    ,HEADER_Attribute13
    ,HEADER_Attribute14
    ,HEADER_Attribute15
    ,Attribute_CATEGORY
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
    ,ORG_ID
    ,TRANSLATED_DESCRIPTION
    ,invoiced_line_acctg_level
    ,Source_data_key1
    ,Source_data_key2
    ,Source_data_key3
    ,Source_data_key4
    ,Source_data_key5
    ,reference_line_attribute1
    ,reference_line_attribute2
    ,reference_line_attribute3
    ,reference_line_attribute4
    ,reference_line_attribute5
    ,reference_line_attribute6
    ,reference_line_attribute7
    ,reference_line_attribute8
    ,reference_line_attribute9
    ,reference_line_attribute10
    ,reference_line_context
    ,deferral_exclusion_flag
    ,parent_line_id
    ,payment_trxn_extension_id
    ,warehouse_id
    )
  VALues (
     G_RAIL_REC.ACCOUNTING_RULE_ID
    ,G_RAIL_REC.ACCOUNTING_RULE_DURATION
    ,G_RAIL_REC.AGREEMENT_ID
    ,G_RAIL_REC.AMOUNT
    ,G_RAIL_REC.BATCH_SOURCE_NAME
    ,G_RAIL_REC.COMMENTS
    ,G_RAIL_REC.CONVERSION_DATE
    ,G_RAIL_REC.CONVERSION_RATE
    ,nvl(G_RAIL_REC.CONVERSION_TYPE, 'User')
    ,G_RAIL_REC.CREATED_BY
    ,G_RAIL_REC.CREATION_DATE
    ,G_RAIL_REC.CREDIT_METHOD_FOR_ACCT_RULE
    ,G_RAIL_REC.CREDIT_METHOD_FOR_INSTALLMENTS
    ,G_RAIL_REC.CURRENCY_CODE
    ,G_RAIL_REC.CUST_TRX_TYPE_ID
    ,G_RAIL_REC.DESCRIPTION
    ,G_RAIL_REC.LAST_UPDATED_BY
    ,G_RAIL_REC.LAST_UPDATE_DATE
    ,G_RAIL_REC.LINE_TYPE
    ,G_RAIL_REC.TRX_DATE
    ,G_RAIL_REC.GL_DATE
    ,G_RAIL_REC.PRINTING_OPTION
    ,G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE1
    ,G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE2
    ,G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE3
    ,G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE4
    ,G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE5
    ,G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE6
    ,G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE7
    ,G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE8
    ,G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE9
    ,G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE10
    ,G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE11
    ,G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE12
    ,G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE13
    ,G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE14
    ,G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE15
    ,G_RAIL_REC.INTERFACE_LINE_ID
    ,G_RAIL_REC.INTERFACE_LINE_CONTEXT
    ,G_RAIL_REC.INVENTORY_ITEM_ID
    ,G_RAIL_REC.INVOICING_RULE_ID
    ,G_RAIL_REC.ORIG_SYSTEM_BILL_CUSTOMER_ID
    ,G_RAIL_REC.ORIG_SYSTEM_BILL_ADDRESS_ID
    ,G_RAIL_REC.ORIG_SYSTEM_SHIP_CUSTOMER_ID
    ,G_RAIL_REC.ORIG_SYSTEM_SHIP_ADDRESS_ID
    ,G_RAIL_REC.ORIG_SYSTEM_BILL_CONTACT_ID
    ,G_RAIL_REC.ORIG_SYSTEM_SHIP_CONTACT_ID
    ,G_RAIL_REC.ORIG_SYSTEM_SOLD_CUSTOMER_ID
    ,G_RAIL_REC.PRIMARY_SALESREP_NUMBER
    ,G_RAIL_REC.PRIMARY_SALESREP_ID
    ,G_RAIL_REC.PURCHASE_ORDER
    ,G_RAIL_REC.PURCHASE_ORDER_REVISION
    ,G_RAIL_REC.PURCHASE_ORDER_DATE
    ,G_RAIL_REC.CUSTOMER_BANK_ACCOUNT_ID
    ,G_RAIL_REC.RECEIPT_METHOD_ID
    ,G_RAIL_REC.RECEIPT_METHOD_NAME
    --,G_RAIL_REC.QUANTITY              /** for bug# 1882229   ***/
    ,G_RAIL_REC.QUANTITY_ORDERED
    ,G_RAIL_REC.QUANTITY_ORDERED
    ,G_RAIL_REC.REASON_CODE
    ,G_RAIL_REC.REASON_CODE_MEANING
    ,G_RAIL_REC.REFERENCE_LINE_ID
    ,G_RAIL_REC.RULE_START_DATE
    ,G_RAIL_REC.RULE_END_DATE
    ,G_RAIL_REC.SALES_ORDER
    ,G_RAIL_REC.SALES_ORDER_LINE
    ,G_RAIL_REC.CONTRACT_LINE_ID
    ,G_RAIL_REC.SALES_ORDER_DATE
    ,G_RAIL_REC.SALES_ORDER_SOURCE
    ,G_RAIL_REC.SET_OF_BOOKS_ID
    ,G_RAIL_REC.TAX_EXEMPT_FLAG
    ,G_RAIL_REC.TAX_EXEMPT_NUMBER
    ,G_RAIL_REC.TAX_EXEMPT_REASON_CODE
    ,G_RAIL_REC.TAX_CODE
    ,G_RAIL_REC.TERM_ID  /*Check it out */
    ,G_RAIL_REC.UNIT_SELLING_PRICE
    ,G_RAIL_REC.UNIT_STANDARD_PRICE
    ,G_RAIL_REC.UOM_CODE
    ,G_RAIL_REC.HEADER_Attribute_CATEGORY
    ,G_RAIL_REC.HEADER_Attribute1
    ,G_RAIL_REC.HEADER_Attribute2
    ,G_RAIL_REC.HEADER_Attribute3
    ,G_RAIL_REC.HEADER_Attribute4
    ,G_RAIL_REC.HEADER_Attribute5
    ,G_RAIL_REC.HEADER_Attribute6
    ,G_RAIL_REC.HEADER_Attribute7
    ,G_RAIL_REC.HEADER_Attribute8
    ,G_RAIL_REC.HEADER_Attribute9
    ,G_RAIL_REC.HEADER_Attribute10
    ,G_RAIL_REC.HEADER_Attribute11
    ,G_RAIL_REC.HEADER_Attribute12
    ,G_RAIL_REC.HEADER_Attribute13
    ,G_RAIL_REC.HEADER_Attribute14
    ,G_RAIL_REC.HEADER_Attribute15
    ,G_RAIL_REC.Attribute_CATEGORY
    ,G_RAIL_REC.Attribute1
    ,G_RAIL_REC.Attribute2
    ,G_RAIL_REC.Attribute3
    ,G_RAIL_REC.Attribute4
    ,G_RAIL_REC.Attribute5
    ,G_RAIL_REC.Attribute6
    ,G_RAIL_REC.Attribute7
    ,G_RAIL_REC.Attribute8
    ,G_RAIL_REC.Attribute9
    ,G_RAIL_REC.Attribute10
    ,G_RAIL_REC.Attribute11
    ,G_RAIL_REC.Attribute12
    ,G_RAIL_REC.Attribute13
    ,G_RAIL_REC.Attribute14
    ,G_RAIL_REC.Attribute15
    ,G_RAIL_REC.Org_Id
    ,G_RAIL_REC.TRANSLATED_DESCRIPTION
    ,G_RAIL_REC.invoiced_line_acctg_level
    ,G_RAIL_REC.Source_data_key1
    ,G_RAIL_REC.Source_data_key2
    ,G_RAIL_REC.Source_data_key3
    ,G_RAIL_REC.Source_data_key4
    ,G_RAIL_REC.Source_data_key5
    ,G_RAIL_REC.reference_line_attribute1
    ,G_RAIL_REC.reference_line_attribute2
    ,G_RAIL_REC.reference_line_attribute3
    ,G_RAIL_REC.reference_line_attribute4
    ,G_RAIL_REC.reference_line_attribute5
    ,G_RAIL_REC.reference_line_attribute6
    ,G_RAIL_REC.reference_line_attribute7
    ,G_RAIL_REC.reference_line_attribute8
    ,G_RAIL_REC.reference_line_attribute9
    ,G_RAIL_REC.reference_line_attribute10
    ,G_RAIL_REC.reference_line_context
    ,G_RAIL_REC.deferral_exclusion_flag
    ,G_RAIL_REC.parent_line_id
    ,G_RAIL_REC.payment_trxn_extension_id
    ,G_RAIL_REC.warehouse_id
    );

--    G_RAIL_REC  := G_INIT_RAIL_REC;

EXCEPTION
   When  Others Then
             x_return_status   :=   'E';
                FND_FILE.PUT_LINE(FND_FILE.LOG,
                                        'OKS_ARFEEDER_PUB.insert_ra_interface => Exception in insert into RA_INTERFACE_LINES '||' SQLCOE = '||sqlcode ||' Sqlerrm = '||sqlerrm);

  End insert_ra_interface;
---------------------------------------------------------------------------
-- procedure insert_RA_revenue_distributions
---------------------------------------------------------------------------
procedure insert_ra_rev_dist(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_cle_id                       IN NUMBER
)
IS
 CURSOR rev_dist_cur(p_cle_id  NUMBER) IS
      SELECT ACCOUNT_CLASS,
             CODE_COMBINATION_ID,
             PERCENT
          FROM oks_rev_distributions
       WHERE cle_id = p_cle_id;

  l_rev_dist     rev_dist_cur%ROWTYPE;

  BEGIN
    x_return_status := 'S';
    OPEN rev_dist_cur(p_cle_id);
    LOOP
      FETCH rev_dist_cur into l_rev_dist;
      EXIT WHEN rev_dist_cur%NOTFOUND;

      INSERT INTO RA_INTERFACE_DISTRIBUTIONS_ALL
        (ACCOUNT_CLASS,
         PERCENT,
         CODE_COMBINATION_ID,
         INTERFACE_LINE_CONTEXT,
         INTERFACE_LINE_ATTRIBUTE1,
         INTERFACE_LINE_ATTRIBUTE2,
         INTERFACE_LINE_ATTRIBUTE3,
         INTERFACE_LINE_ATTRIBUTE4,
         INTERFACE_LINE_ATTRIBUTE5,
         INTERFACE_LINE_ATTRIBUTE6,
         INTERFACE_LINE_ATTRIBUTE7,
         INTERFACE_LINE_ATTRIBUTE8,
         INTERFACE_LINE_ATTRIBUTE9,
         INTERFACE_LINE_ATTRIBUTE10,
         INTERFACE_LINE_ATTRIBUTE11,
         INTERFACE_LINE_ATTRIBUTE12,
         INTERFACE_LINE_ATTRIBUTE13,
         INTERFACE_LINE_ATTRIBUTE14,
         INTERFACE_LINE_ATTRIBUTE15,
         ORG_ID
        )
       values
        (
         l_rev_dist.account_class,
         l_rev_dist.percent,
         l_rev_dist.code_combination_id,
         G_RAIL_REC.interface_line_context,
         G_RAIL_REC.interface_line_attribute1,
         G_RAIL_REC.interface_line_attribute2,
         G_RAIL_REC.interface_line_attribute3,
         G_RAIL_REC.interface_line_attribute4,
         G_RAIL_REC.interface_line_attribute5,
         G_RAIL_REC.interface_line_attribute6,
         G_RAIL_REC.interface_line_attribute7,
         G_RAIL_REC.interface_line_attribute8,
         G_RAIL_REC.interface_line_attribute9,
         G_RAIL_REC.interface_line_attribute10,
         G_RAIL_REC.interface_line_attribute11,
         G_RAIL_REC.interface_line_attribute12,
         G_RAIL_REC.interface_line_attribute13,
         G_RAIL_REC.interface_line_attribute14,
         G_RAIL_REC.interface_line_attribute15,
         G_RAIL_REC.org_id
        ) ;
      END LOOP;
    CLOSE rev_dist_cur;
  EXCEPTION
   When  Others Then
             x_return_status   :=   'E';
                FND_FILE.PUT_LINE(FND_FILE.LOG,
                                        'OKS_ARFEEDER_PUB.insert_ra_rev_dist => Exception in insert into RA_INTERFACE_DISTRIBUTIONS'||' SQLCODE ='||SQLCODE||' SQLERRM = '||SQLERRM);

  END;


---------------------------------------------------------------------------
-- procedure insert_RA_interface_sc
---------------------------------------------------------------------------
procedure insert_ra_interface_sc(
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_called_from                  IN NUMBER
)
IS



BEGIN
x_return_status := 'S';

If G_LOG_YES_NO = 'YES' then
   FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.insert_ra_interface_sc => AMOUNT'||G_RAISC_REC.SALES_CREDIT_AMOUNT_SPLIT);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.insert_ra_interface_sc => PERCENT'||G_RAISC_REC.SALES_CREDIT_PERCENT_SPLIT);
End If;



G_RAISC_REC.SALES_CREDIT_AMOUNT_SPLIT := round(G_RAISC_REC.SALES_CREDIT_AMOUNT_SPLIT,2);

--assign values to G_RAISC_REC

G_RAISC_REC.INTERFACE_LINE_ATTRIBUTE1    := G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE1;
G_RAISC_REC.INTERFACE_LINE_ATTRIBUTE2    := G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE2;
G_RAISC_REC.INTERFACE_LINE_ATTRIBUTE3    := G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE3;
G_RAISC_REC.INTERFACE_LINE_ATTRIBUTE4    := G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE4;
G_RAISC_REC.INTERFACE_LINE_ATTRIBUTE5    := G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE5;
G_RAISC_REC.INTERFACE_LINE_ATTRIBUTE6    := G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE6;
G_RAISC_REC.INTERFACE_LINE_ATTRIBUTE7    := G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE7;
G_RAISC_REC.INTERFACE_LINE_ATTRIBUTE8    := G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE8;
G_RAISC_REC.INTERFACE_LINE_ATTRIBUTE9    := G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE9;
G_RAISC_REC.INTERFACE_LINE_ATTRIBUTE10   := G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE10;
G_RAISC_REC.INTERFACE_LINE_ATTRIBUTE11   := G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE11;
G_RAISC_REC.INTERFACE_LINE_ATTRIBUTE12   := G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE12;
G_RAISC_REC.INTERFACE_LINE_ATTRIBUTE13   := G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE13;
G_RAISC_REC.INTERFACE_LINE_ATTRIBUTE14   := G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE14;
G_RAISC_REC.INTERFACE_LINE_ATTRIBUTE15   := G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE15;
G_RAISC_REC.INTERFACE_LINE_CONTEXT       := G_RAIL_REC.INTERFACE_LINE_CONTEXT;
G_RAISC_REC.ORG_ID                       := G_RAIL_REC.ORG_ID;
G_RAISC_REC.CREATED_BY                   := G_RAIL_REC.CREATED_BY;
G_RAISC_REC.CREATION_DATE                := G_RAIL_REC.CREATION_DATE;
G_RAISC_REC.LAST_UPDATED_BY              := G_RAIL_REC.LAST_UPDATED_BY;
G_RAISC_REC.LAST_UPDATE_DATE             := G_RAIL_REC.LAST_UPDATE_DATE;



AR_InterfaceSalesCredits_GRP.insert_salescredit(
                          p_salescredit_rec => G_RAISC_REC,
                          x_return_status   => x_return_status,
                          x_msg_count       => x_msg_count,
                          x_msg_data        => x_msg_data);

IF NVL(x_return_status,'E') <> 'S' THEN
  RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;


--    G_RAIL_REC  := G_INIT_RAIL_REC;
--    G_RAISC_REC := G_INIT_RAISC_REC;

EXCEPTION
 WHEN  G_EXCEPTION_HALT_VALIDATION THEN
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'Error in insert RA_INTERFACE_SALESCREDITS ' || sqlerrm);

 When  Others Then
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
                FND_FILE.PUT_LINE(FND_FILE.LOG,
                        'OKS_ARFEEDER_PUB.insert_ra_interface_sc => Exception in insert into RA_INTERFACE_SALESCREDITS'||' SQLCODE = '||SQLCODE ||' SQLERRM = '||SQLERRM);

End insert_ra_interface_sc;


--mchoudha Fix for bug#4174921
--added parameter p_hdr_id
Procedure Sales_credit( p_id            IN           NUMBER,
                        p_hdr_id        IN           Number,
                        l_return_status OUT NOCOPY  Varchar2
                       )
Is
Cursor Sales_credit_cur IS
    Select  Ctc_id
           ,sales_credit_type_id1
           ,percent, sales_group_id
    From   OKS_K_SALES_CREDITS
    Where  cle_id = p_id;

--added by mchoudha for bug#4174921
--If line level salescredits are not present then
--pass header level salescredits to AR
--08-APR-2005 mchoudha Fix for bug#4293133
--Added one more condition cle_id is null
--to fetch only header level sales credits
Cursor Sales_credit_hdr_cur IS
    Select  Ctc_id
           ,sales_credit_type_id1
           ,percent
           ,sales_group_id
    From   OKS_K_SALES_CREDITS
    Where  chr_id = p_hdr_id
    And    cle_id IS NULL;


Sales_credit_rec                     Sales_credit_cur%ROWTYPE;
l_ret_stat                           Varchar2(20);
l_msg_cnt                            NUMBER;
l_msg_data                           Varchar2(2000);
p_called_from                        NUMBER;
l_sales_group_id                     NUMBER;

Begin
  OPEN  Sales_credit_cur;
  FETCH Sales_credit_cur into Sales_credit_rec;
  --added by mchoudha for bug#4174921
  --If line level salescredits are not present then
  --pass header level salescredits to AR
  if(Sales_credit_cur%NOTFOUND) THEN
    For Sales_credit_hdr_rec in Sales_credit_hdr_cur
    Loop
      if G_LOG_YES_NO = 'YES' then
        FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Sales_credit => Header Level RA_Interface_SalesCredit');
      end if;
      G_RAISC_REC.SALESREP_ID := Sales_credit_hdr_rec.CTC_ID;
      G_RAISC_REC.SALES_CREDIT_TYPE_ID := to_number(Sales_credit_hdr_rec.SALES_CREDIT_TYPE_ID1);
      G_RAISC_REC.SALES_CREDIT_PERCENT_SPLIT :=Sales_credit_hdr_rec.PERCENT;
      G_RAISC_REC.SALESGROUP_ID:= Sales_credit_hdr_rec.sales_group_id;
      Insert_ra_interface_sc
      (
        l_return_status,
        l_msg_cnt,
        l_msg_data,
        p_called_from
      );

       If l_return_status <> 'S' THEN
         oks_bill_rec_pub.get_message
          (l_msg_cnt  => l_msg_cnt,
           l_msg_data => l_msg_data);
           FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Sales_credit => Insert into RA_Interface_SalesCredit Failed For header id '||p_hdr_id);

       End If;


    End Loop;--End of sales credit header Loop
  else
    LOOP
      If G_LOG_YES_NO = 'YES' then
        FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Sales_credit =>Line level RA_Interface_SalesCredit');
      End If;
      Exit WHEN Sales_credit_cur%NOTFOUND;
      G_RAISC_REC.SALESREP_ID := Sales_credit_rec.CTC_ID;
      G_RAISC_REC.SALES_CREDIT_TYPE_ID := to_number(Sales_credit_rec.SALES_CREDIT_TYPE_ID1);
      G_RAISC_REC.SALES_CREDIT_PERCENT_SPLIT :=Sales_credit_rec.PERCENT;
      G_RAISC_REC.SALESGROUP_ID:= Sales_credit_rec.sales_group_id;

      Insert_ra_interface_sc
       (
        X_RETURN_STATUS  => L_return_status,
        X_MSG_COUNT      => l_msg_cnt,
        X_MSG_DATA       => l_msg_data,
        P_CALLED_FROM    => p_called_from);



      IF (l_return_status <> 'S') THEN
        oks_bill_rec_pub.get_message
          (L_MSG_CNT  => l_msg_cnt,
           L_MSG_DATA => l_msg_data);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Sales_credit => Insert into RA_Interface_SalesCredit Failed For'||p_id);

      End If;

      Fetch Sales_credit_cur into Sales_credit_rec;
    END LOOP;--End of sales credit Loop
  end if;  --End of Sales_credit_cur%NOTFOUND
  CLOSE Sales_credit_cur;

End;

--mchoudha Fix for bug#4174921
--added parameter p_hdr_id
Procedure Set_price_breaks(p_id             IN         NUMBER,
                           p_prv            IN         NUMBER,
                           p_contract_no    IN         VARCHAR2,
                           p_contract_mod   IN         VARCHAR2,
                           p_bill_inst_no   IN         NUMBER,
                           p_amount         IN         NUMBER,
                           p_int_att10      IN         VARCHAR2,
                           p_bcl_cle_id     IN         NUMBER,
                           p_currency_code  IN         VARCHAR2,
                           p_hdr_id         IN           Number,
                           x_msg_cnt        OUT NOCOPY NUMBER,
                           x_msg_data       OUT NOCOPY VARCHAR2,
                           x_return_status  OUT NOCOPY VARCHAR2
                           )
IS


--order by added so that while populating reference fields in termination
---order can be found out.

Cursor Price_breaks_cur(p_id IN NUMBER) IS
  SELECT quantity,
         unit_price,
         amount
  FROM   OKS_PRICE_BREAKS
  WHERE  bsl_id = p_id
  ORDER BY quantity_from;

-- Added the sales_order in where condition as part of
-- perf bug 3489672.
Cursor Termination_cur(
                       p_contract_number      IN VARCHAR2,
                       p_contract_modifier    IN VARCHAR2,
                       p_bill_instance_number IN NUMBER)
IS
  SELECT  abs(txl.extended_amount)   extended_amount,
          txl.quantity_ordered,
          txl.quantity_invoiced,
          txl.unit_selling_price,
          txl.gross_unit_selling_price,
          txl.gross_extended_amount,
          txl.amount_includes_tax_flag,
          txl.customer_trx_line_id ,
          txh.trx_date
    FROM  ra_customer_trx_all        txh,
          ra_customer_trx_lines_all  txl
   WHERE  txl.interface_line_attribute1 =  p_contract_number
    AND   nvl(txl.interface_line_attribute2,'-') = nvl(p_contract_modifier,'-')
    AND   txl.interface_line_attribute3  =  p_bill_instance_number
    AND   txl.interface_line_context =  'OKS CONTRACTS'
    AND   txl.customer_trx_id =  txh.customer_trx_id
    AND   txl.extended_amount > 0
    AND   txl.sales_order = p_contract_number|| decode(p_contract_modifier,null,'','-'||p_contract_modifier)
    ORDER BY abs(txl.extended_amount);

Cursor get_tax (p_customer_trx_line_id IN  NUMBER) IS
  SELECT extended_amount          tax_amount
   FROM RA_CUSTOMER_TRX_LINES_ALL
   WHERE line_type = 'TAX'
   AND   link_to_cust_trx_line_id = p_customer_trx_line_id;

Price_breaks_rec        Price_breaks_cur%ROWTYPE;
inv_rec                 Termination_cur%ROWTYPE;
l_pb_i                  NUMBER := 0;
l_check_amount          NUMBER := 0;
l_term_amount           NUMBER := 0;
l_amount                NUMBER := 0;
l_quantity              NUMBER := 0;
l_tax_amount            NUMBER := 0;
l_extended_amount       NUMBER := 0;
l_unit_selling_price    NUMBER := 0;
l_int_att10             VARCHAR2(20);
l_inclusive_tax         VARCHAR2(10);


BEGIN


  -- BUG 3638409
  l_int_att10  := p_int_att10;
  IF (p_prv =1) THEN
    l_pb_i := 0;

    FOR Price_breaks_rec in Price_breaks_cur(p_id)
    LOOP
      l_pb_i                               := l_pb_i + 1;
      G_RAIL_REC.description               := 'PB'||l_pb_i;
      G_RAIL_REC.quantity_ordered          := Price_breaks_rec.quantity;
      G_RAIL_REC.quantity                  := Price_breaks_rec.quantity;
      G_RAIL_REC.unit_selling_price        := Price_breaks_rec.unit_price;
      G_RAIL_REC.amount                    := Price_breaks_rec.amount;
      G_RAIL_REC.interface_line_attribute6 := Price_breaks_rec.amount;
      G_RAIL_REC.interface_line_attribute10:= l_int_att10||' for PB'||l_pb_i;


    --interface_line_attribute10 is populated with desc to make each line unique
    --This is required in case if amount is same for more than one break.
    --In such case autoinvoice should not reject the records.

      Insert_ra_interface
       (
         x_return_status,
         x_msg_cnt,
         x_msg_data
        );

      IF (x_return_status <> 'S') THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Set_price_breaks => Insert into RA_Interface_Lines Failed while inserting price breaks ' );
        x_return_status := 'E';
      END IF; --IF (l_ret_stat <> 'S')


      INSERT_RA_REV_DIST( x_return_status,
                          p_bcl_cle_id);

      IF (x_return_status <> 'S') THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Set_price_breaks => Insert INTO RA_REVENUE_DISTRIBUTIONS failed for Price Break');

        x_return_status := 'E';
      END IF;

      --mchoudha Fix for bug#4174921
      --added parameter p_hdr_id
      Sales_credit(p_bcl_cle_id ,
                   p_hdr_id,
                   x_return_status);

      IF ( x_return_status <> 'S') THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Set_price_breaks => Insert INTO RA_SALES_CREDIT FAILED for Price Breaks');
      END IF;

      EXIT When x_return_status <> 'S';
    END LOOP;

     UPDATE oks_bill_txn_lines
     SET cycle_refrence = l_int_att10||' for PB'
     WHERE bill_instance_number = TO_NUMBER(G_RAIL_REC.interface_line_attribute3);

  ELSIF (p_prv = 3) THEN

    l_pb_i := 0;
    l_check_amount := abs(p_amount);
    FOR inv_rec in Termination_cur(p_contract_no,
                                   p_contract_mod,
                                   p_bill_inst_no
                                  )
    LOOP

      l_inclusive_tax := '';
      l_tax_amount := 0;
      l_unit_selling_price := 0;

      IF (inv_rec.amount_includes_tax_flag = 'Y') THEN

        l_extended_amount :=  inv_rec.gross_extended_amount ;
        l_unit_selling_price := inv_rec.gross_unit_selling_price;
      ELSE
        l_extended_amount :=  inv_rec.extended_amount ;
        l_unit_selling_price := inv_rec.unit_selling_price;
      END IF;

      --IF (inv_rec.extended_amount <= l_check_amount) THEN
      IF (l_extended_amount <= l_check_amount) THEN
        l_term_amount := l_extended_amount;
      ELSE
        l_term_amount := l_check_amount;
      END IF;

      l_pb_i                               := l_pb_i + 1;
      G_RAIL_REC.reference_line_id         := inv_rec.customer_trx_line_id;
      G_RAIL_REC.trx_date                  := inv_rec.trx_date;
      G_RAIL_REC.description               := 'PBT'||l_pb_i;
      G_RAIL_REC.quantity_ordered          := round(l_term_amount/l_unit_selling_price);
      G_RAIL_REC.quantity                  := round(l_term_amount/l_unit_selling_price);
      G_RAIL_REC.amount                    := -1 * l_term_amount;
      G_RAIL_REC.interface_line_attribute6 := -1 * l_term_amount;

      Insert_ra_interface
         (
           x_return_status,
           x_msg_cnt,
           x_msg_data
          );

      IF (x_return_status <> 'S') THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Set_price_breaks => Insert into RA_Interface_Lines Failed while inserting price breaks ' );
        x_return_status := 'E';
      END IF; --IF (l_ret_stat <> 'S')


      INSERT_RA_REV_DIST( x_return_status,
                          p_bcl_cle_id);

      IF (x_return_status <> 'S') THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Set_price_breaks => Insert INTO RA_REVENUE_DISTRIBUTIONS failed for Price Break');

        x_return_status := 'E';
      END IF;

      --mchoudha Fix for bug#4174921
      --added parameter p_hdr_id
      Sales_credit(p_bcl_cle_id ,
                   p_hdr_id,
                   x_return_status);

      IF ( x_return_status <> 'S') THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Set_price_breaks => Insert INTO RA_SALES_CREDIT FAILED for Price Breaks');
      END IF;


      EXIT when x_return_status <> 'S';

      l_check_amount := l_check_amount - l_term_amount;

      IF (l_check_amount <= 0) THEN
        EXIT;
      END IF;
    END LOOP;
  END IF;

END Set_price_breaks;




/*----------------------------------------------------------------------
Returns Payment Method Details for a given Receipt Method Id
----------------------------------------------------------------------*/
PROCEDURE Get_Pay_Method_Info
(   p_pay_method_id   IN         NUMBER
,   p_pay_method_name OUT NOCOPY VARCHAR2
,   x_return_status   OUT NOCOPY VARCHAR2
)
IS

    CURSOR receipt_csr (pay_id number) is
    SELECT name
    FROM  AR_RECEIPT_METHODS
    WHERE RECEIPT_METHOD_ID = pay_id
    AND   SYSDATE >= NVL(START_DATE, SYSDATE)
    AND   SYSDATE <= NVL(END_DATE, SYSDATE)
    /* Commented and Modification done by sjanakir for Bug #6855301
    AND   PAYMENT_TYPE_CODE = 'CREDIT_CARD'; */
    AND   PAYMENT_CHANNEL_CODE = 'CREDIT_CARD';

BEGIN

  x_return_status := 'S';
  --errorout('In Get Pay Method Info');

  OPEN  receipt_csr(p_pay_method_id);
  FETCH receipt_csr INTO p_pay_method_name;
  CLOSE receipt_csr;

  --errorout('Get Pay Method Info '||p_pay_method_name);

  EXCEPTION
      WHEN OTHERS THEN
         x_return_status := 'E';
         FND_FILE.PUT_LINE(FND_FILE.LOG,
                 'OKS_ARFEEDER_PUB.Get_Pay_Method_Info => Exception in insert into GET_PAY_METHOD'||' SQLCODE = '||SQLCODE||' SQLERRM = '||SQLERRM);


END Get_Pay_Method_Info;


---------------------------------------------------------------------------
-- PROCEDURE Get_rec_feeder
---------------------------------------------------------------------------
PROCEDURE Get_REC_FEEDER
(
  X_RETURN_STATUS                OUT    NOCOPY  VARCHAR2,
  X_MSG_COUNT                    OUT    NOCOPY  NUMBER,
  X_MSG_DATA                     OUT    NOCOPY  VARCHAR2,
  P_FLAG                         IN             NUMBER, -- 1 sales_group_id present, 2-not present.
  P_CALLED_FROM                  IN             NUMBER,
  P_DATE                         IN             DATE,
  P_CLE_ID                       IN             NUMBER,
  P_PRV                          IN             NUMBER,
  P_BILLREP_TBL                  IN OUT NOCOPY OKS_BILL_REC_PUB.bill_report_tbl_type,
  P_BILLREP_TBL_IDX              IN             NUMBER,
  P_BILLREP_ERR_TBL              IN OUT NOCOPY OKS_BILL_REC_PUB.billrep_error_tbl_type,
  P_BILLREP_ERR_TBL_IDX          IN OUT NOCOPY NUMBER
) Is

Cursor Cur_address_billto(p_id In Varchar2,Code Varchar2) IS
 Select  a.cust_account_id,
            a.cust_acct_site_id,
            a.location_id,
            c.party_id,
                  a.id1
    From    Okx_cust_site_uses_v a, okx_customer_accounts_v  c
    Where   a.id1 = p_id
    And     c.id1 = a.cust_account_id
    AND     a.site_use_code = Code;


  /* can be used instead of OKX view query above
  SELECT ca.cust_account_id, ca.cust_acct_site_id ,
          l.location_id ,hca.party_id ,cs.site_use_iD
   FROM  hz_locations l,
         hz_party_sites ps,
         hz_cust_accounts       hca,
         hz_cust_acct_sites_all ca,
         hz_cust_site_uses_all cs
   WHERE  cs.site_use_id = p_id
   AND    cs.site_use_code = p_code
   AND    ca.cust_acct_site_id = cs.cust_acct_site_id
   AND    ps.location_id = l.location_id
   AND    l.content_source_type = 'USER_ENTERED'
   AND    ps.party_site_id = ca.party_site_id
   AND    hca.cust_account_id = ca.cust_account_id;
  */



Cursor cur_bcl Is
    Select a.id    ,
           a.btn_id ,
           a.date_billed_from,
           a.date_billed_to,
           a.cle_id,
           a.amount,
           a.bill_action,
           b.dnz_chr_id,
           a.date_next_invoice,
           b.start_date,
           b.lse_id,
           a.currency_code,
           b.date_terminated ,
           c.name                       lse_name,
           b.cust_acct_id,
           KLN.trxn_extension_id,
           b.line_number top_line_number
    From   OKC_LINE_STYLES_V   c,
           OKS_BILL_CONT_LINES a,
           OKC_K_LINES_B b,
           OKS_K_LINES_B KLN
    Where  a.btn_id Is Null
    And    a.amount Is Not Null
    And    b.id = a.cle_id
    And    b.id = p_cle_id
    AND    b.id = KLN.cle_id
    And    a.bill_action  not in ('TR','STR')
    And    c.id  = b.lse_id
    And    p_cle_id is not null;


CURSOR cur_bcl_pr IS
 Select    a.id    ,
           a.btn_id,
           a.date_billed_from,
           a.date_billed_to,
           a.cle_id,
           a.amount,
           a.bill_action,
           b.dnz_chr_id,
           a.date_next_invoice,
           b.start_date,
           b.lse_id,
           a.currency_code,
           b.date_terminated,
           c.name                      lse_name,
           b.cust_acct_id,
           KLN.trxn_extension_id,
           b.line_number top_line_number
    From   OKC_LINE_STYLES_V c,
           OKS_BCL_PR    a,
           OKC_K_LINES_B b,
           OKS_K_LINES_B KLN
    Where  a.btn_id  is null
    And    a.amount Is Not Null
    And    b.id = a.cle_id
    And    b.id = p_cle_id
    AND    b.id = KLN.cle_id
    And    c.id  = b.lse_id
    And    a.bill_action not in ('AV','TR','STR')
    And    p_cle_id is not null;

--19-NOV-2003 Mani
--added parallel hint on oks_bill_cont_lines

--mchoudha bug#4638641
--added RI also in the bill_action condition of where clause
 CURSOR cur_bcl_term IS
  Select    /*+  PARALLEL(a) */
            a.id    ,
            a.btn_id  ,
            a.date_billed_from,
            a.date_billed_to,
            a.cle_id,
            a.amount,
            a.bill_action,
            b.dnz_chr_id,
            a.date_next_invoice,
            b.start_date,
            b.lse_id,
            a.currency_code,
            b.date_terminated,
            c.name                         lse_name,
           b.cust_acct_id,
           KLN.trxn_extension_id,
           b.line_number top_line_number
        From
          OKC_LINE_STYLES_V      c,
          OKS_BILL_CONT_LINES    a,
          OKC_K_LINES_B b,
          OKS_K_LINES_B KLN
        Where  a.btn_id  is null
        And    a.amount Is Not Null
        And    b.id = a.cle_id
        AND    b.id = KLN.cle_id
        And    c.id  = b.lse_id
        And    a.bill_action in ('AV','TR','STR','SRI','RI')
        And    p_cle_id is null;


Cursor cur_hdr_Rules (p_cle_id IN NUMBER) is
SELECT
          nvl(rhdr.hold_billing,'N')     Hold_Billing_flag,
          nvl(rhdr.ar_interface_yn,'N')  ar_interface_yn, /* Added By sjanakir for Bug #6821826 */
          hdr.inv_rule_id                , -- IRE
          rhdr.acct_rule_id              , -- ARL
          rhdr.inv_trx_type              , --SBG
          nvl(rhdr.summary_trx_yn,'N')   summary_trx_yn, --SBG
          hdr.payment_term_id            , --PTR
          rhdr.tax_exemption_id          , --TAX
          rhdr.tax_status                ,  --TAX
          hdr.conversion_type            , --CVN
          hdr.conversion_rate            , --CVN
          hdr.conversion_rate_date       , --CVN
          hdr.bill_to_site_use_id        , --BTO
          hdr.ship_to_site_use_id        , --BTO
          rhdr.commitment_id,
          hdr.contract_number,
          hdr.contract_number_modifier,
          hdr.attribute_category,
          hdr.attribute1,
          hdr.attribute2,
          hdr.attribute3,
          hdr.attribute4,
          hdr.attribute5,
          hdr.attribute6,
          hdr.attribute7,
          hdr.attribute8,
          hdr.attribute9,
          hdr.attribute10,
          hdr.attribute11,
          hdr.attribute12,
          hdr.attribute13,
          hdr.attribute14,
          hdr.attribute15,
          hdr.currency_code,
          hdr.authoring_org_id,
          hdr.org_id,
          nvl(line.cust_po_number,hdr.cust_po_number)   cust_po_number,
          nvl(line.payment_type,rhdr.payment_type)  payment_type,
          rhdr.trxn_extension_id,
          --Start fixes of eBTax uptake bug#4756579
          rhdr.exempt_certificate_number,
          rhdr.exempt_reason_code
          --End fixes of eBtax uptake bug#4756579
   FROM
        OKS_K_HEADERS_B  rhdr,
        OKC_K_HEADERS_B  hdr,
        OKS_K_LINES_B    line
   WHERE line.cle_id = p_cle_id
   AND   hdr.id  = line.dnz_chr_id
   AND   hdr.id      = rhdr.chr_id;

Cursor cur_line_rules(p_cle_id IN NUMBER) IS
SELECT  line.bill_to_site_use_id ,
        line.ship_to_site_use_id,
        rline.commitment_id,
        rline.tax_code,
        rline.tax_status,
        rline.tax_exemption_id,
        line.inv_rule_id,
        line.cust_acct_id,
        rline.acct_rule_id,
        rline.invoice_text,
        rline.inv_print_flag,
        rline.usage_type,
        --Start fixes of eBTax uptake bug#4756579
        rline.exempt_certificate_number,
        rline.exempt_reason_code,
        rline.tax_classification_code
        --End fixes of eBtax uptake bug#4756579
    FROM OKS_K_LINES_V    rline,
         OKC_K_LINES_B    line
    WHERE line.id = p_cle_id
    AND   rline.cle_id = line.id;


Cursor ar_date_cur(p_bcl_id NUMBER) IS
  Select min(date_to_interface)
    From oks_bill_sub_lines
    Where bcl_id = p_bcl_id;

Cursor Cur_bsl(id_in In NUMBER) IS
    Select   a.id,
             a.cle_id,
             a.date_billed_from,
             a.date_billed_to,
             a.average,
             a.amount ,
             b.date_terminated,
             c.cle_id         top_line_id ,
             b.lse_id ,
             rline.invoice_text,
             rline.inv_print_flag,
             b.line_number sub_line_number
    From     OKS_BILL_SUB_LINES  a,
             OKS_BILL_CONT_LINES c,
             OKS_K_LINES_V       rline,
             OKC_K_LINES_B       b
    Where    a.bcl_id = id_in
    AND      c.id     = a.bcl_id
    AND      a.cle_id = b.id
    AND      rline.cle_id = b.id;



Cursor Cur_k_lines(id_in IN NUMBER) IS
    Select
            id
           ,start_date
           ,end_date
           ,item_description
           ,block23text
           ,attribute1
           ,attribute2
           ,attribute3
           ,attribute4
           ,attribute5
           ,attribute6
           ,attribute7
           ,attribute8
           ,attribute9
           ,attribute10
           ,attribute11
           ,attribute12
           ,attribute13
           ,attribute14
           ,attribute15
           ,attribute_category
    From   OKC_K_LINES_V
    Where  id = id_in;
-- changed the where condition of cur_tax for tax exemption project
-- if the exemption id is invalid then null is passed to the interface table

Cursor check_for_account_id(p_bill_to_site_use_id  IN NUMBER,
                        p_org_id IN NUMBER,
                        p_cust_account_id IN NUMBER) IS
  SELECT site.cust_account_id from hz_cust_acct_sites_all site
  where site.cust_acct_site_id in
                                  ( select uses.cust_acct_site_id
                                    from hz_cust_site_uses_all uses
                                    where site_use_id = p_bill_to_site_use_id
				    and   site_use_code = 'BILL_TO')
  and  nvl(site.org_id,p_org_id) = p_org_id
  and  site.cust_account_id = p_cust_account_id;

l_cust_account   number;



Cursor Cur_tax(id_in IN VARCHAR2,l_trx_date IN DATE) IS
--Start fixes of eBTax uptake bug#4756579
  SELECT v2.exempt_certificate_number,
  v2.exempt_reason_code
  FROM   zx_exemptions v2
  WHERE (trunc(l_trx_date) BETWEEN trunc(v2.EFFECTIVE_FROM)
  AND nvl( trunc(v2.EFFECTIVE_TO), trunc(l_trx_date)))
  AND v2.tax_exemption_id = id_in;
--End fixes of eBTax uptake bug#4756579


Cursor cur_tax_code (p_id  IN  VARCHAR2, p_org_id NUMBER) IS
--Start fixes of eBTax uptake bug#4756579
SELECT tax_classification_code
FROM zx_id_tcc_mapping
WHERE tax_rate_code_id = p_id
AND org_id = p_org_id;

Cursor Cur_valid_exemption(p_exempt_number IN VARCHAR2, p_trx_date IN DATE) IS
  SELECT v2.exempt_certificate_number,
  v2.exempt_reason_code
  FROM   zx_exemptions v2
  WHERE (trunc(p_trx_date) BETWEEN trunc(v2.EFFECTIVE_FROM)
  AND nvl( trunc(v2.EFFECTIVE_TO), trunc(p_trx_date)))
  AND v2.exempt_certificate_number = p_exempt_number;






--End fixes of eBTax uptake bug#4756579

Cursor Cur_lsl_type(id_in IN NUMBER) IS
       Select cl.lse_id,lsl.name
       From   OKC_LINE_STYLES_V lsl, OKC_K_LINES_B cl
       Where  lsl.id = cl.lse_id
       And    cl.id = id_in;


Cursor acct_type(p_id NUMBER) Is
       SELECT type,frequency
       FROM ra_rules
       WHERE rule_id = p_id;

       /*  Above select avoids OKX view usage
       Select type
       From   OKX_RULES_V
       Where  id1 = p_id;
       */


Cursor Cur_k_headers(p_id NUMBER) Is
        Select  Contract_number
               ,Contract_number_modifier
               ,authoring_org_id
               ,org_id
               ,currency_code
               ,cust_po_number
               ,attribute1
               ,attribute2
               ,attribute3
               ,attribute4
               ,attribute5
               ,attribute6
               ,attribute7
               ,attribute8
               ,attribute9
               ,attribute10
               ,attribute11
               ,attribute12
               ,attribute13
               ,attribute14
               ,attribute15
               ,attribute_category
        From    OKC_K_HEADERS_B
        Where   id = p_id;

--mchoudha Bug#3676706
--changed the condition from trunc(bcl.date_billed_from) = trunc(p_date_from)
--to trunc(bcl.date_billed_from) <= trunc(p_date_from) to consider
--cases where termination date is somewhere between the billing period

Cursor check_summary_billed (p_cle_id     IN  NUMBER,
                             p_date_from  IN  DATE,
                             p_date_to    IN  DATE) IS
  SELECT btl.bsl_id ,bcl.btn_id from oks_bill_txn_lines  btl,
                         oks_bill_cont_lines bcl
  WHERE  bcl.cle_id = p_cle_id
  AND    trunc(bcl.date_billed_from) <= trunc(p_date_from)
  AND    trunc(bcl.date_billed_to)   = trunc(p_date_to)
  AND    bcl.bill_action = 'RI'
  AND    bcl.btn_id   =   btl.btn_id ;


Cursor Cur_Parent_Order_line(p_id  IN  NUMBER) IS
    SELECT last_oe_order_line_id from csi_item_instances
    where instance_id in (select to_number(itm.object1_id1) from okc_k_items itm
                          where itm.cle_id = p_id
                          and jtot_object1_code = 'OKX_CUSTPROD');


Cursor Sales_credit_cur(p_id NUMBER) IS
    Select  Ctc_id
           ,sales_credit_type_id1
           ,percent
    From   OKS_K_SALES_CREDITS
    Where  cle_id = p_id;


Cursor chk_price_break_cur(p_id  IN  NUMBER) IS
    SELECT count(1)
      FROM oks_price_breaks
     WHERE bsl_id = p_id;

Cursor cur_okc_k_item_qty(p_id  IN NUMBER) IS
  SELECT  Number_of_items,
          UOM_code
  FROM    OKC_K_ITEMS
  WHERE   CLE_ID = p_id;


Cursor Interface_pb_cur IS
    SELECT interface_price_break
    FROM   OKS_K_DEFAULTS
    WHERE  cdt_type = 'MDT';

Cursor Bill_instance_cur(p_id  IN  NUMBER) IS
    SELECT average
      FROM oks_bill_sub_lines
     WHERE id = p_id;


-- Modified the following cursor for perf bug#3489672
-- added sales order in where clause.
 Cursor Inv_count_cur(p_contract_number      IN VARCHAR2,
                      p_contract_modifier    IN VARCHAR2,
                      p_bill_instance_number IN NUMBER)
IS
    SELECT  count(*)
      FROM  ra_customer_trx_all  d, --Okx_customer_trx_v d
            ra_customer_trx_lines_all c, --Okx_cust_trx_lines_v c
            ra_cust_trx_types_all types
     WHERE  c.interface_line_attribute1 = p_contract_number
       AND  nvl(c.interface_line_attribute2,'-') = nvl(p_contract_modifier ,'-')
       AND  c.Interface_line_attribute3 = to_char(p_bill_instance_number)
       AND  c.Interface_line_context =  'OKS CONTRACTS'
       AND  c.customer_trx_id = d.customer_trx_id
       AND  c.sales_order = p_contract_number|| decode(p_contract_modifier,null,'','-'||p_contract_modifier)
       AND  d.cust_trx_type_id = types.cust_trx_type_id
       AND  types.type = 'INV' ;

--Start 27-Dec-2005 nechatur Fix for bug#4390448
--Added the following two cursors Cur_bsd and l_usage_csr
Cursor Cur_bsd(p_id IN Number) IS
    Select  bsd.result result,
            bsd.unit_of_measure uom_code
    From    oks_bill_sub_line_dtls  bsd
    Where   bsd.bsl_id = p_id;

Cursor  l_usage_csr(p_id IN Number,p_hdr_id IN Number) Is
   Select  usage_type
     From  oks_k_lines_b kln
    Where  kln.cle_id = p_id;
--End 27-Dec-2005 nechatur Fix for bug#4390448


  CURSOR tax_info_csr(p_site_use_id IN NUMBER) IS
        SELECT c.party_id,
        a.party_site_id
        FROM hz_cust_acct_sites a,
        hz_cust_site_uses b,
        hz_party_sites c
        WHERE a.cust_acct_site_id = b.cust_acct_site_id
        AND c.party_site_id = a.party_site_id
        AND b.site_use_id = p_site_use_id;


   CURSOR Cur_Batch_Source_Id(p_org_id IN NUMBER)
        IS
        SELECT BATCH_SOURCE_ID
        FROM ra_batch_sources_all
        WHERE org_id = p_org_id
        AND NAME = 'OKS_CONTRACTS';


header_rec                           Cur_k_headers%ROWTYPE;
Bcl_rec                              Cur_bcl%ROWTYPE;
rul_hdr_rec                          cur_hdr_Rules%ROWTYPE;
rul_line_rec                         cur_line_Rules%ROWTYPE;
BSL_rec                              Cur_BSL%ROWTYPE;
l_bill_profile                       NUMBER := G_SUM;
l_dnz_chr_id                         NUMBER;
l_request_id                         VARCHAR2(60);
l_set_of_books_id                    NUMBER;
l_trx_date                           VARCHAR2(30);
l_currency_code                      VARCHAR2(60);
l_payment_type                       VARCHAR2(30);
l_customer_account_id                NUMBER;
l_ret_stat                           VARCHAR2(20);
l_msg_cnt                            NUMBER;
l_msg_count                          NUMBER;
l_msg_data                           VARCHAR2(2000);
l_index                              NUMBER;
l_lse_id                             NUMBER;
l_order_line_id                      NUMBER;
l_num_periods                        NUMBER;
l_lse_name                           VARCHAR2(240);
l_desc                               VARCHAR2(2000);
l_sal_person_cnt                     NUMBER;
l_sales_credit_yn_profile            VARCHAR2(5);
l_sales_credit_distr_profile         VARCHAR2(20);
l_bf_flag                            VARCHAR2(3);
l_acct_frequency                     VARCHAR2(15);
l_acct_calender                      VARCHAR2(15);
l_sc_rec1                            NUMBER;
l_sc_rec2                            NUMBER;
l_fail_stat                          NUMBER := 0;  /* set to 1 if any inser or update failed */
l_org_id                             NUMBER;
l_start_date                         DATE;
l_End_date                           DATE;
l_unmapped_date                      DATE;
l_type                               VARCHAR2(10);
BSL_rec_NUM                          NUMBER;
l_bill_instance_number               NUMBER;
tax_rec                              Cur_tax%rowtype;
billto_rec                           cur_address_billto%rowtype;
sales_credit_rec                     Sales_credit_cur%rowtype;
lines_rec                            Cur_k_lines%rowtype;
l_btnv_tbl_in                        OKS_BTN_PVT.btnv_tbl_type;
l_btnv_tbl_out                       OKS_BTN_PVT.btnv_tbl_type;
l_bclv_tbl_in                        OKS_bcl_PVT.bclv_tbl_type;
l_bclv_tbl_out                       OKS_bcl_PVT.bclv_tbl_type;
l_btlv_tbl_in                        OKS_BTL_PVT.btlv_tbl_type;
l_btlv_tbl_out                       OKS_BTL_PVT.btlv_tbl_type;
l_btn_pr_tbl_in                      OKS_BTN_PRINT_PREVIEW_PVT.btn_pr_tbl_type;
l_btn_pr_tbl_out                     OKS_BTN_PRINT_PREVIEW_PVT.btn_pr_tbl_type;
l_btl_pr_tbl_in                      OKS_BTL_PRINT_PREVIEW_PVT.btl_pr_tbl_type;
l_btl_pr_tbl_out                     OKS_BTL_PRINT_PREVIEW_PVT.btl_pr_tbl_type;
l_amount                             NUMBER := 0;
l_bill_profile_flag                  VARCHAR2(4);
l_contact                            NUMBER;
l_cpl_id                             NUMBER;
l_bsl_id                             NUMBER;
l_chk_bcl_id                         NUMBER;
l_cro_code                           VARCHAR2(30);
l_sublse_id                          NUMBER;
l_cust_id                            NUMBER;   --- for CC process
l_site_use_id                        NUMBER;   --- for CC process
l_sub_line_id                        NUMBER;   --- for CC process
l_cc_only                            BOOLEAN := TRUE ;  --- for CC process
l_pay_method_id                      NUMBER; -- for CC process
l_status                             VARCHAR2(15);
l_hdr_sbg_object1_id1                NUMBER;
l_ar_date                            DATE;
l_hold_flag                          VARCHAR2(10);
l_hdr_summary_flag                   VARCHAR2(10);
l_line_payment_mth                   VARCHAR2(10);
l_select_counter                     NUMBER     := 0;
l_reject_counter                     NUMBER     := 0;
l_process_counter                    NUMBER     := 0;
l_interface_pb                       VARCHAR2(1);
l_price_break_count                  NUMBER := 0;
l_inv_count                          NUMBER     := 0;
l_bill_instance_no                   NUMBER     := 0;
l_subline_failed                     BOOLEAN;
l_line_failed                        BOOLEAN;
l_subline_count                      NUMBER := 0;
MAIN_CUR_EXCEPTION                   Exception;
l_usage_type                         VARCHAR2(3);
report_bill_action                         VARCHAR2(3) := 'RI';
l_ship_to_party_site_id             NUMBER;
l_batch_source_id                   NUMBER;
l_bill_to_party_site_id             NUMBER;
l_bill_to_party_id                  NUMBER;
l_valid_flag                        VARCHAR2(3) := 'N';

--Start fixes of eBtax uptake bug#4756579
l_api_name                          CONSTANT VARCHAR2(30) := 'Get_REC_FEEDER';
--end fixes of eBtax uptake bug#4756579
/* Added by sjanakir for Bug # 6872005 */
/* Modified by cgopinee for PA-DSS enhancement*/
l_cc_expired                            VARCHAR2(10);

/* Added by sjanakir for Bug # 6855301 */
l_as_of_date 			    DATE;
l_flag                              Number; /*modified for bug:8943481*/

FUNCTION Get_receipt_method_id (p_customer_id	IN NUMBER,
				p_site_use_id	IN NUMBER,
				p_cc_only	IN BOOLEAN,
				p_as_of_date	IN DATE,
				p_org_id	IN NUMBER) RETURN NUMBER IS

l_check                             BOOLEAN := FALSE;
l_primary                           BOOLEAN := TRUE ;
l_cust_pay_method_id                NUMBER;
l_pay_method_id 		    NUMBER;

BEGIN
	l_cust_pay_method_id := arp_ext_bank_pkg.get_cust_pay_method
			  (p_customer_id	=> p_customer_id,
			   p_site_use_id 	=> p_site_use_id,
			   p_pay_method_id 	=> NULL,
			   p_cc_only 		=> p_cc_only,
			   p_primary 		=> l_primary,
			   p_check 		=> l_check,
			   p_as_of_date 	=> TRUNC(p_as_of_date));

	IF (NVL(l_cust_pay_method_id,0) > 0) THEN

		SELECT receipt_method_id
		  INTO l_pay_method_id
		  FROM ra_cust_receipt_methods
		 WHERE cust_receipt_method_id = l_cust_pay_method_id;
		IF G_LOG_YES_NO = 'YES' THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Payment method id is '||l_pay_method_id);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Customer Payment method id is '||l_cust_pay_method_id);
		END IF;
	ELSE

		l_pay_method_id :=  to_number(nvl(FND_PROFILE.VALUE_SPECIFIC('OKS_RECEIPT_METHOD_ID', NULL, NULL, NULL, p_org_id, NULL),'0'));

		IF l_pay_method_id = 0 THEN
			IF G_LOG_YES_NO = 'YES' THEN
				FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Payment method id is '||l_pay_method_id);
				FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Enter a Value for the Profile, OKS: Payment Method for AR Interface');
			END IF;
			RAISE MAIN_CUR_EXCEPTION;
		END IF;

		l_cust_pay_method_id := arp_ext_bank_pkg.process_cust_pay_method
						   (p_pay_method_id => l_pay_method_id,
						    p_customer_id   => p_customer_id,
						    p_site_use_id   => p_site_use_id,
						    p_as_of_date    => TRUNC(p_as_of_date));
		IF G_LOG_YES_NO = 'YES' THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Payment method id from Profile OKS: Payment Method for AR Interface is '||l_pay_method_id);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Customer Payment method id is '||l_cust_pay_method_id);
		END IF;
	END IF;

	RETURN l_pay_method_id;
EXCEPTION
	WHEN OTHERS THEN
	RAISE;
END;

/* Added by sjanakir for Bug # 6872005 */

FUNCTION check_CC_valid ( p_trxn_extension_id IN NUMBER) RETURN VARCHAR2 IS

/*Commented and added by cgopinee for PA-DSS enhancement*/
l_card_expired_flag                 VARCHAR2(10);
/*
l_cc_no				    VARCHAR2(30);
v_clean_cc			    VARCHAR2(30);
v_cc_type 			    iby_cc_validate.cctype;
v_cc_valid 			    BOOLEAN := TRUE;
l_exp_date			    DATE;
*/

BEGIN
SELECT NVL(card_expired_flag,'N')
  INTO l_card_expired_flag
  FROM iby_trxn_extensions_v
 WHERE trxn_extension_id = p_trxn_extension_id;

/* Commented by cgopinee for PA DSS Enhancement */
/*
	BEGIN
		SELECT ic.ccnumber,
		       NVL(ic.expirydate,SYSDATE +1)
		  INTO l_cc_no,
		       l_exp_date
		  FROM iby_creditcard ic,
		       iby_pmt_instr_uses_all ipa,
		       iby_fndcpt_tx_extensions ifte
		 WHERE ifte.trxn_extension_id = p_trxn_extension_id
		   AND ifte.instr_assignment_id = ipa.instrument_payment_use_id
		   AND ipa.instrument_id = ic.instrid;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
			IF G_LOG_YES_NO = 'YES' THEN
				FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Credit card details not found for Payment Transaction Extension ID');
			END IF;
			RAISE MAIN_CUR_EXCEPTION;
	WHEN OTHERS THEN
			IF G_LOG_YES_NO = 'YES' THEN
				FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Error retrieving Credit card details for Payment Transaction Extension ID');
			END IF;
			RAISE MAIN_CUR_EXCEPTION;
	END;


	iby_cc_validate.stripcc(  p_api_version		=> 1.0,
							  p_init_msg_list	=> 'T',
							  p_cc_id			=> l_cc_no,
							  x_return_status	=> l_ret_stat,
							  x_msg_count		=> l_msg_cnt,
							  x_msg_data		=> l_msg_data,
							  x_cc_id			=> v_clean_cc);


	IF l_ret_stat = OKC_API.G_RET_STS_SUCCESS
	THEN
	iby_cc_validate.getcctype(	p_api_version				=> 1.0,
								p_init_msg_list				=> 'T',
								p_cc_id						=> v_clean_cc,
								x_return_status				=> l_ret_stat,
								x_msg_count					=> l_msg_cnt,
								x_msg_data					=> l_msg_data,
								x_cc_type					=> v_cc_type);
		IF l_ret_stat = OKC_API.G_RET_STS_SUCCESS
		THEN
				IF v_cc_type=IBY_CC_VALIDATE.c_InvalidCC THEN
					IF G_LOG_YES_NO = 'YES' THEN
						FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Credit card number Format is invalid.');
					END IF;
					RAISE MAIN_CUR_EXCEPTION;
				ELSE
					IF G_LOG_YES_NO = 'YES' THEN
						FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Credit card number Format is valid.');
					END IF;
				END IF;

			iby_cc_validate.validatecc( p_api_version	=> 1.0,
										p_init_msg_list	=> 'T',
										p_cc_id			=> v_clean_cc,
										p_expr_date		=> l_exp_date,
										x_return_status	=> l_ret_stat,
										x_msg_count		=> l_msg_cnt,
										x_msg_data		=> l_msg_data,
										x_cc_valid		=> v_cc_valid);

			RETURN v_cc_valid;

		ELSE

			IF G_LOG_YES_NO = 'YES' THEN
				FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Error retrieving Credit card Type.');
			END IF;

			RETURN FALSE;

		END IF;
	ELSE

	   IF G_LOG_YES_NO = 'YES' THEN
		FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Error retrieving Credit card number.');
	   END IF;

	   RETURN FALSE;

	END IF;*/
        RETURN l_card_expired_flag;
EXCEPTION
	WHEN OTHERS THEN
	RETURN 'Y';
END check_CC_valid;

/* Addition by sjanakir for Bug # 6872005 Ends */

BEGIN

  /* GET THE CONCURRENT PROCESS ID */

  l_request_id := FND_GLOBAL.CONC_REQUEST_ID;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

 --Fix for bug#4198616
 --declared global variable G_LOG_YES_NO and using this variable
 --in place OKS_BILLING_PUB.l_write_log to decide whether to log
 --messages
 G_LOG_YES_NO := Fnd_profile.value('OKS_BILLING_REPORT_AND_LOG');

 FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => OKS: Billing Report And Log is set to '||G_LOG_YES_NO);


  /*FOR BILLING REPORT*/
  l_subline_failed := FALSE;
  l_line_failed := FALSE;


  IF (p_prv = 1) THEN
    OPEN Cur_bcl;
  ELSIF (p_prv = 2)  THEN
    OPEN Cur_bcl_pr;
  ELSIF (p_prv = 3) THEN
    OPEN Cur_bcl_term;
  END IF;

  LOOP
    IF (p_prv = 1) THEN
      FETCH Cur_bcl into bcl_rec;
      EXIT WHEN cur_bcl%NOTFOUND;
    ELSIF (p_prv = 2) THEN
      FETCH Cur_bcl_pr into bcl_rec;
      EXIT WHEN cur_bcl_pr%NOTFOUND;
    ELSIF (p_prv = 3) THEN
      FETCH Cur_bcl_term into bcl_rec;
      EXIT WHEN cur_bcl_term%NOTFOUND;
    END IF;

    BEGIN
      DBMS_TRANSACTION.SAVEPOINT('BEFORE_AR_TRANSACTION');
      --Fix for bug#4390448
      --initializing the variable l_usage_type to NULL
      l_usage_type := NULL;

      --Fix for bug#4390448
      --get the usage type to be used later
      l_lse_id := bcl_rec.lse_id;
      Open l_usage_csr(bcl_rec.cle_id,Bcl_rec.dnz_chr_id);
      Fetch l_usage_csr into l_usage_type;
      Close l_usage_csr;
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Usage Type '||l_usage_type);
      -- End for bug#4390448

      l_select_counter := l_select_counter + 1;
      l_bill_instance_number := NULL;
      l_flag:=0; /*modified for bug:8943481*/
      OPEN  cur_hdr_rules (bcl_rec.cle_id );
      FETCH cur_hdr_rules into rul_hdr_rec;
      IF cur_hdr_rules%NOTFOUND THEN
       l_flag := 1;
      END IF;
      CLOSE cur_hdr_rules;


      If G_LOG_YES_NO = 'YES' then
           FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => p_prv '||p_prv);
           FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => rul_hdr_rec.hold_billing_flag '||nvl(rul_hdr_rec.hold_billing_flag,'N'));
      End If;


      IF (nvl(rul_hdr_rec.hold_billing_flag,'N') = 'Y') THEN
        OPEN  ar_date_cur(bcl_rec.id);
        FETCH ar_date_cur into l_ar_date;
        CLOSE ar_date_cur;
      ELSE
        l_ar_date := NULL;        --sysdate;
      END IF;

/*****
      IF ((bcl_rec.bill_action not in ('AV','TR','STR'))OR
          ((bcl_rec.bill_action in ('AV','TR','STR')) AND
****/
      --BUG FIX 3450592 . added nvl in IF clause
      IF ((bcl_rec.bill_action not in ('TR','STR'))OR
          ((bcl_rec.bill_action in ('TR','STR')) AND
                    (nvl(trunc(l_ar_date),trunc(p_date)) <= trunc(p_date))
                     AND (rul_hdr_rec.ar_interface_yn ='Y') and l_flag = 0)) THEN  /* Added By sjanakir for Bug # 6821826 */ /*modified for bug:8943481*/


        If G_LOG_YES_NO = 'YES' then
           FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Processing Line :  '|| Bcl_rec.cle_id);
        End If;

        OPEN  Cur_K_headers(Bcl_rec.dnz_chr_id);
        FETCH Cur_k_headers into header_rec;
        CLOSE Cur_k_headers;


        OPEN  cur_k_lines(bcl_rec.cle_id);
        FETCH cur_k_lines into lines_rec;
        CLOSE cur_k_lines;

        --Insert Into OKS_BILL_TRANSACTIONS
        IF ((p_prv = 1) OR (p_prv = 3)) THEN
          l_btnv_tbl_in(1).CURRENCY_CODE      :=  nvl(bcl_rec.CURRENCY_CODE,header_rec.CURRENCY_CODE);
          l_btnv_tbl_in(1).trx_number         := '-99';

          OKS_BILLTRAN_PUB.insert_Bill_Tran_Pub
            (
             p_api_version                  =>  1.0,
             p_init_msg_list                =>  'T',
             x_return_status                =>   l_ret_stat,
             x_msg_count                    =>   l_msg_cnt,
             x_msg_data                     =>   l_msg_data,
             p_btnv_tbl                     =>   l_btnv_tbl_in,
             x_btnv_tbl                     =>   l_btnv_tbl_out
            );
        If G_LOG_YES_NO = 'YES' then
           FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => After calling OKS_BILLTRAN_PUB.insert_Bill_Tran_Pub l_ret_status'||l_ret_stat);
        End If;

        ELSIF  (p_prv = 2) THEN
          l_btn_pr_tbl_in(1).ID                   :=oks_bill_rec_pub.get_Seq_id;
          l_btn_pr_tbl_in(1).CURRENCY_CODE        :=nvl(bcl_rec.CURRENCY_CODE,header_rec.CURRENCY_CODE);
          l_btn_pr_tbl_in(1).TRX_NUMBER           := '-99';
          l_btn_pr_tbl_in(1).TRX_AMOUNT           := NULL;
          l_btn_pr_tbl_in(1).TRX_CLASS            := NULL;
          l_btn_pr_tbl_in(1).OBJECT_VERSION_NUMBER:= 1.0;
          l_btn_pr_tbl_in(1).CREATED_BY           := FND_GLOBAL.user_id;
          l_btn_pr_tbl_in(1).CREATION_DATE        := sysdate;
          l_btn_pr_tbl_in(1).LAST_UPDATED_BY      := FND_GLOBAL.user_id;
          l_btn_pr_tbl_in(1).LAST_UPDATE_DATE     := sysdate;
          l_btn_pr_tbl_in(1).TRX_DATE             := sysdate;
          l_btn_pr_tbl_in(1).LAST_UPDATE_LOGIN    := FND_GLOBAL.user_id;
          l_btn_pr_tbl_in(1).SECURITY_GROUP_ID    := NULL;

          OKS_BILLTRAN_PRV_PUB.insert_btn_pr
            (
             p_api_version             => 1.0 ,
             p_init_msg_list           => 'T',
             x_return_status           => l_ret_stat ,
             x_msg_count               => l_msg_count,
             x_msg_data                => l_msg_data ,
             p_btn_pr_tbl              => l_btn_pr_tbl_in ,
             x_btn_pr_tbl              => l_btn_pr_tbl_out
             );

        END IF;

        IF (l_ret_stat = 'S') THEN

          IF ((p_prv = 1) OR (p_prv = 3)) THEN

            --Update OKS_BILL_CONT_LINES with the BTN ID

            UPDATE oks_bill_cont_lines
            SET btn_id = l_btnv_tbl_out(1).id
            WHERE id =  bcl_rec.id ;

            If G_LOG_YES_NO = 'YES' then
              FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => After Updating btn_id of oks_bill_cont_lines');
            End If;

            l_btlv_tbl_in(1).btn_id := l_btnv_tbl_out(1).id;
            l_btlv_tbl_in(1).bcl_id := bcl_rec.id;

          ELSIF (p_prv = 2) THEN
            UPDATE     oks_bcl_pr
            SET BTN_ID =   l_btn_pr_tbl_in(1).ID
            WHERE ID   =   bcl_rec.id;

            l_btl_pr_tbl_in(1).BTN_ID     := l_btn_pr_tbl_in(1).ID;
            l_btl_pr_tbl_in(1).BCL_ID     := Bcl_rec.id;
          END IF;
        ELSE  -- (l_ret_stat = 'S')
          If G_LOG_YES_NO = 'YES' then
             FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Insert into Bill_Transactions Failed For Line : '||Bcl_rec.cle_id);
          End If;

          oks_bill_rec_pub.get_message(
                    l_msg_cnt  => l_msg_cnt,
                    l_msg_data => l_msg_data);
          IF (P_PRV <> 3) THEN
            x_msg_count := l_msg_cnt;
            x_msg_data  := l_msg_data;
          END IF;

          ---DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_AR_TRANSACTION');
          RAISE MAIN_CUR_EXCEPTION;
        END IF;  -- (l_ret_stat = 'S')


        -- g_rail_rec.set_of_books_id is set in Set_attributes

        /* Initialize AR Record */
        G_RAIL_REC.ACCOUNTING_RULE_DURATION           := NULL;
        G_RAIL_REC.ACCOUNTING_RULE_ID                 := NULL;
        G_RAIL_REC.CUSTOMER_BANK_ACCOUNT_ID           := NULL;
        G_RAIL_REC.RECEIPT_METHOD_NAME                := NULL;
        G_RAIL_REC.RECEIPT_METHOD_ID                  := NULL;
        G_RAIL_REC.TRX_DATE                           := NULL;
        G_RAIL_REC.REFERENCE_LINE_ID                  := NULL;
        G_RAIL_REC.ORIG_SYSTEM_BILL_CUSTOMER_ID       := NULL;
        G_RAIL_REC.ORIG_SYSTEM_BILL_ADDRESS_ID        := NULL;
        G_RAIL_REC.ORIG_SYSTEM_SOLD_CUSTOMER_ID       := NULL;
        G_RAIL_REC.ORIG_SYSTEM_SHIP_CUSTOMER_ID       := NULL;
        G_RAIL_REC.ORIG_SYSTEM_SHIP_ADDRESS_ID        := NULL;
        G_RAIL_REC.CONVERSION_TYPE                    := 'User';
        G_RAIL_REC.CONVERSION_DATE                    := NULL;
        G_RAIL_REC.CONVERSION_RATE                    := 1;
        G_RAIL_REC.GL_DATE                            := NULL;
        G_RAIL_REC.TERM_ID                            := NULL;
        G_RAIL_REC.TAX_EXEMPT_REASON_CODE             := NULL;
        G_RAIL_REC.TAX_EXEMPT_FLAG                    := NULL;
        G_RAIL_REC.TAX_EXEMPT_NUMBER                  := NULL;
        G_RAIL_REC.TAX_CODE                           := NULL;
        G_RAIL_REC.CREDIT_METHOD_FOR_ACCT_RULE        := NULL;
        G_RAIL_REC.CREDIT_METHOD_FOR_INSTALLMENTS     := NULL;
        G_RAIL_REC.ORIG_SYSTEM_BILL_CONTACT_ID        := NULL;
        G_RAIL_REC.ORIG_SYSTEM_SHIP_CONTACT_ID        := NULL;
        G_RAIL_REC.AGREEMENT_ID                       := NULL;
        G_RAIL_REC.TRANSLATED_DESCRIPTION             := NULL;
        G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE9          := NULL;
        G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE10         := NULL;
        G_RAIL_REC.QUANTITY                           := NULL;
        G_RAIL_REC.QUANTITY_ORDERED                   := NULL;
        G_RAIL_REC.UNIT_SELLING_PRICE                 := NULL;
        G_RAIL_REC.INVOICING_RULE_ID                  := NULL;
        G_RAIL_REC.CUST_TRX_TYPE_ID                   := NULL;
        G_RAIL_REC.SET_OF_BOOKS_ID := NULL;

        G_RAIL_REC.reference_line_attribute1          := NULL;
        G_RAIL_REC.reference_line_attribute2          := NULL;
        G_RAIL_REC.reference_line_attribute3          := NULL;
        G_RAIL_REC.reference_line_attribute4          := NULL;
        G_RAIL_REC.reference_line_attribute5          := NULL;
        G_RAIL_REC.reference_line_attribute6          := NULL;
        G_RAIL_REC.reference_line_attribute7          := NULL;
        G_RAIL_REC.reference_line_attribute8          := NULL;
        G_RAIL_REC.reference_line_attribute9          := NULL;
        G_RAIL_REC.reference_line_attribute10         := NULL;
        G_RAIL_REC.reference_line_context             := NULL;
        G_RAIL_REC.deferral_exclusion_flag            := NULL;
        G_RAIL_REC.parent_line_id                     := NULL;
        G_RAIL_REC.PAYMENT_TRXN_EXTENSION_ID          := NULL;
        G_RAIL_REC.contract_line_id                   := NULL;
        G_RAIL_REC.SALES_ORDER_LINE                   := NULL;
        G_RAIL_REC.PRIMARY_SALESREP_ID                := NULL;

        l_line_payment_mth                            := NULL;
        l_hdr_sbg_object1_id1                         := NULL;
        l_acct_calender                               := NULL;
        l_acct_frequency                              := NULL;
        l_num_periods                                 := NULL;


       -- -- Rules for The Contract Header

        IF (rul_hdr_rec.inv_rule_id IS NOT NULL) THEN
          IF (bcl_rec.bill_action in ('TR','STR')) THEN
            G_RAIL_REC.INVOICING_RULE_ID := NULL;
          ELSE
            G_RAIL_REC.INVOICING_RULE_ID :=  rul_hdr_rec.inv_rule_id;
          END IF;
          G_RAIL_REC.TRX_DATE  := bcl_rec.date_next_invoice;
        END IF;

        l_hdr_sbg_object1_id1  := rul_hdr_rec.inv_trx_type;
        l_hdr_summary_flag     := rul_hdr_rec.summary_trx_yn;

        G_RAIL_REC.SET_OF_BOOKS_ID := get_set_of_books_id (Bcl_rec.dnz_chr_id);

        Set_cust_trx_type(G_RAIL_REC.set_of_books_id,
                          bcl_rec.bill_action,
                          l_hdr_sbg_object1_id1,
                          header_rec.org_id);
        If G_LOG_YES_NO = 'YES' then
          FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => After Calling Set_cust_trx_type '||G_RAIL_REC.CUST_TRX_TYPE_ID);
        End If;

        IF (rul_hdr_rec.acct_rule_id IS NOT NULL) THEN
          OPEN  acct_type(rul_hdr_rec.acct_rule_id);
          FETCH acct_type into l_type,l_acct_frequency;
          CLOSE acct_type;

          IF (l_type  = 'ACC_DUR') THEN

                  l_acct_calender := get_acct_calender(G_RAIL_REC.SET_OF_BOOKS_ID);

            l_start_date := Greatest(Bcl_rec.date_billeD_from,lines_rec.start_date);
            l_End_date   := Least(Bcl_rec.date_billed_to,lines_rec.End_date);
            l_End_date   := l_End_date + 1;

            --G_RAIL_REC.ACCOUNTING_RULE_DURATION := CEIL(MONTHS_BETWEEN(l_End_date,l_start_date));

                  GL_CALENDAR_PKG.get_num_periods_in_date_range(
                                    CALENDAR_NAME     =>  l_acct_calender,
                                                PERIOD_TYPE       =>  l_acct_frequency,
                                                START_DATE        =>  l_start_date,
                                                END_DATE          =>  l_end_date,
                                                CHECK_MISSING     =>  FALSE,
                                                NUM_PERIODS       =>  l_num_periods,
                                                RETURN_CODE       =>  l_ret_stat,
                                                UNMAPPED_DATE     =>  l_unmapped_date);

            If G_LOG_YES_NO = 'YES' then
              FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => After Calling GL_CALENDAR_PKG.get_num_periods_in_date_range l_return_status '||l_ret_stat);
            End If;

            G_RAIL_REC.ACCOUNTING_RULE_DURATION := l_num_periods;
            -- This column must be a positive integer for AR

            IF (G_RAIL_REC.ACCOUNTING_RULE_DURATION = 0) THEN
              G_RAIL_REC.ACCOUNTING_RULE_DURATION := 1;
            END IF;
          ELSE
            G_RAIL_REC.ACCOUNTING_RULE_DURATION := NULL ;
          END IF;

          G_RAIL_REC.ACCOUNTING_RULE_ID := rul_hdr_rec.acct_rule_id;

          ----IF ( bcl_rec.bill_action in ('AV','TR','STR')) THEN
          IF ( bcl_rec.bill_action in ('TR','STR')) THEN
              G_RAIL_REC.ACCOUNTING_RULE_ID := NULL;
              G_RAIL_REC.CREDIT_METHOD_FOR_ACCT_RULE := 'UNIT';
              G_RAIL_REC.CREDIT_METHOD_FOR_INSTALLMENTS := 'LIFO';
          ELSE
            G_RAIL_REC.CREDIT_METHOD_FOR_ACCT_RULE := NULL;
            G_RAIL_REC.CREDIT_METHOD_FOR_INSTALLMENTS := NULL;
          END IF;

        END IF;

            -----(bcl_rec.bill_action not in ('AV','TR','STR'))) THEN
        IF ((rul_hdr_rec.payment_term_id  is NOT NULL) AND
            (bcl_rec.bill_action not in ('TR','STR'))) THEN
            G_RAIL_REC.TERM_ID := rul_hdr_rec.payment_term_id;
        END IF;

       --Start fixes of bug#4756579
        --Rewritten the tax code for R12 eBTax uptake
        --For exemptions:
        --(1)if exemption_certificate_number is populated, use that
        --(2)otherwise use tax_exemption_id to query exempt_certificate_number
        --and exempt_reasion_code from zx_exemptions

        IF (rul_hdr_rec.tax_status IS NOT NULL) THEN
          G_RAIL_REC.TAX_EXEMPT_FLAG :=  rul_hdr_rec.tax_status;
        -- added cur_date_trans cursor for tax exemption and modified the if condition to
        -- pass null if exemption id is invalid
          IF G_RAIL_REC.TAX_EXEMPT_FLAG = 'E' and
            rul_hdr_rec.exempt_certificate_number IS NULL THEN
                --historical contracts
                OPEN  Cur_tax(rul_hdr_rec.tax_exemption_id,Bcl_rec.DATE_NEXT_INVOICE);
                FETCH Cur_tax into tax_rec;
                IF cur_tax%notfound then
                    --exemption is not valid for the  date
                    G_RAIL_REC.TAX_EXEMPT_NUMBER := NULL;
                    G_RAIL_REC.TAX_EXEMPT_REASON_CODE := NULL;
                    --reset the tax_exempt_flag to 'S'
                    G_RAIL_REC.TAX_EXEMPT_FLAG := 'S';
                ELSE
				If G_LOG_YES_NO = 'YES' then
				   FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB. Exempt numer '||tax_rec.exempt_certificate_number||' Reason '||tax_rec.exempt_reason_code);
				End If;
                    G_RAIL_REC.TAX_EXEMPT_NUMBER := tax_rec.exempt_certificate_number;
                    G_RAIL_REC.TAX_EXEMPT_REASON_CODE := tax_rec.exempt_reason_code;
                END IF;

                CLOSE cur_tax;
          Elsif G_RAIL_REC.TAX_EXEMPT_FLAG = 'E' and
            rul_hdr_rec.exempt_certificate_number IS NOT NULL THEN
                G_RAIL_REC.TAX_EXEMPT_REASON_CODE := Rul_hdr_rec.exempt_reason_code;
                G_RAIL_REC.TAX_EXEMPT_NUMBER := Rul_hdr_rec.exempt_certificate_number;

          Elsif G_RAIL_REC.TAX_EXEMPT_FLAG = 'R'  Then --- Added this for bug 5600680
                    G_RAIL_REC.TAX_EXEMPT_NUMBER := NULL;
                    G_RAIL_REC.TAX_EXEMPT_REASON_CODE := NULL;
          Elsif G_RAIL_REC.TAX_EXEMPT_FLAG <> 'E'  Then
                    G_RAIL_REC.TAX_EXEMPT_FLAG := 'S';
                    G_RAIL_REC.TAX_EXEMPT_NUMBER := NULL;
                    G_RAIL_REC.TAX_EXEMPT_REASON_CODE := NULL;
          END IF; --IF (G_RAIL_REC.TAX_EXEMPT_FLAG = 'E')

        END IF; --IF (rul_hdr_rec.tax_status IS NOT NULL)
        --End fixes of bug#4756579

        IF (rul_hdr_rec.conversion_type IS NOT NULL) THEN
          /*
            conversion type cannot be null and hence nvl criteria
            is used for assignment of conversion_type
          */
          G_RAIL_REC.CONVERSION_TYPE :=nvl(rul_hdr_rec.conversion_type ,'User');

          /* This if is included to populated rate = 1
             if type is user.This is important if the
             functional currency is same as transactional
             currency. It that case the control will not go
             in below if stat
           */

           IF (G_RAIL_REC.CONVERSION_TYPE = 'User') THEN
             G_RAIL_REC.CONVERSION_RATE  := 1;
           ELSE
             G_RAIL_REC.CONVERSION_RATE  := NULL;
           END IF;

           /* If functional currency is not the same
              as transactional currency the assignment of
              rate use the below logic
           */
           IF (okc_currency_api.get_ou_currency(header_rec.org_id)  <> header_rec.currency_code ) THEN
             IF ( G_RAIL_REC.CONVERSION_TYPE = 'User') THEN
               G_RAIL_REC.CONVERSION_RATE :=nvl(rul_hdr_rec.conversion_rate,1);
             ELSE
               G_RAIL_REC.CONVERSION_RATE := NULL;
             END IF;
           END IF;

           /*cgopinee bugfix for 8361496*/
           IF (Rul_hdr_rec.conversion_rate_date IS NULL) OR
               (FND_PROFILE.VALUE('OKS_CURR_CONV_DATE') = 'SYSDATE' AND G_RAIL_REC.CONVERSION_TYPE <> 'User' )THEN
             G_RAIL_REC.CONVERSION_DATE := sysdate;
           ELSE
             G_RAIL_REC.CONVERSION_DATE := Rul_hdr_rec.conversion_rate_date;
             --G_RAIL_REC.CONVERSION_DATE := to_date(Rules_rec.Rule_information2,'YYYY/MM/DD HH24:MI:SS');
           END IF;

        END IF;


        IF (rul_hdr_rec.bill_to_site_use_id IS NOT NULL) THEN
          OPEN  Cur_ADDRESS_BILLTO(rul_hdr_rec.bill_to_site_use_id,'BILL_TO');
          FETCH Cur_address_billto into billto_rec;
          CLOSE Cur_ADDRESS_BILLTO;

          l_cust_id     := billto_rec.cust_account_id;
          l_site_use_id := billto_rec.id1;

          G_RAIL_REC.ORIG_SYSTEM_BILL_CUSTOMER_ID := billto_rec.cust_account_id;
          G_RAIL_REC.ORIG_SYSTEM_BILL_ADDRESS_ID:= billto_rec.cust_acct_site_id;
          G_RAIL_REC.ORIG_SYSTEM_SOLD_CUSTOMER_ID := billto_rec.cust_account_id;

        END IF;

        IF (rul_hdr_rec.ship_to_site_use_id IS NOT NULL) THEN
          OPEN  Cur_ADDRESS_BILLTO(rul_hdr_rec.ship_to_site_use_id,'SHIP_TO');
          FETCH Cur_address_billto into billto_rec;
          CLOSE Cur_ADDRESS_BILLTO;

          G_RAIL_REC.ORIG_SYSTEM_SHIP_CUSTOMER_ID:= billto_rec.cust_account_id;
          G_RAIL_REC.ORIG_SYSTEM_SHIP_ADDRESS_ID:=billto_rec.cust_acct_site_id;
        END IF;

        ------END OF HEADER RULE READING -------------------

        If G_LOG_YES_NO = 'YES' then
           FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => End Of Header Rule Processing And Beginning Of Line Rule processing');
        End If;

        ------LINE RULE READ --------------------------------

        OPEN  cur_line_rules (bcl_rec.cle_id );
        FETCH cur_line_rules into rul_line_rec;
        CLOSE cur_line_rules;

        IF (rul_line_rec.bill_to_site_use_id IS NOT NULL) THEN
          OPEN  cur_address_billto(rul_line_rec.bill_to_site_use_id,'BILL_TO');
          FETCH cur_address_billto into billto_rec;
          CLOSE cur_address_billto;

          G_RAIL_REC.ORIG_SYSTEM_BILL_CUSTOMER_ID:= billto_rec.cust_account_id;
          G_RAIL_REC.ORIG_SYSTEM_BILL_ADDRESS_ID:=billto_rec.cust_acct_site_id;
          G_RAIL_REC.ORIG_SYSTEM_SOLD_CUSTOMER_ID:= billto_rec.cust_account_id;

        END IF;

        IF (rul_line_rec.ship_to_site_use_id IS NOT NULL) THEN
          OPEN  cur_address_billto(rul_line_rec.ship_to_site_use_id,'SHIP_TO');
          FETCH Cur_address_billto into billto_rec;
          CLOSE cur_address_billto;

          G_RAIL_REC.ORIG_SYSTEM_SHIP_CUSTOMER_ID:= billto_rec.cust_account_id;
          G_RAIL_REC.ORIG_SYSTEM_SHIP_ADDRESS_ID:=billto_rec.cust_acct_site_id;

        END IF;


        --For exemptions:
        --(1)if exemption_certificate_number is populated, use that
        --(2)otherwise use tax_exemption_id to query exempt_certificate_number
        --and exempt_reasion_code from zx_exemptions

        IF ( Rul_line_rec.tax_status IS NOT NULL OR
             Rul_line_rec.tax_classification_code IS NOT NULL OR
             Rul_line_rec.tax_code IS NOT NULL )  Then

          G_RAIL_REC.TAX_EXEMPT_FLAG :=
                   nvl(Rul_line_rec.tax_status,'S');

          IF G_RAIL_REC.TAX_EXEMPT_FLAG = 'R' Then
		G_RAIL_REC.TAX_EXEMPT_NUMBER      := NULL;
		G_RAIL_REC.TAX_EXEMPT_REASON_CODE := NULL;
          ElsIF G_RAIL_REC.TAX_EXEMPT_FLAG <> 'E' Then
		G_RAIL_REC.TAX_EXEMPT_NUMBER      := NULL;
		G_RAIL_REC.TAX_EXEMPT_REASON_CODE := NULL;
		G_RAIL_REC.TAX_EXEMPT_FLAG        := 'S';
          ElsIF Rul_line_rec.tax_exemption_id IS NOT NULL THEN
                    --historical contracts
                    OPEN  Cur_tax(Rul_line_rec.tax_exemption_id,Bcl_rec.DATE_NEXT_INVOICE);
                    FETCH Cur_tax into tax_rec;
                    IF cur_tax%notfound then
                        --exemption is not valid for the  date
                        G_RAIL_REC.TAX_EXEMPT_NUMBER := NULL;
                        G_RAIL_REC.TAX_EXEMPT_REASON_CODE := NULL;
                        --reset the tax_exempt_flag to 'S'
                        G_RAIL_REC.TAX_EXEMPT_FLAG := 'S';

                    ELSE
			If G_LOG_YES_NO = 'YES' then
			    FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB. Exempt numer '||tax_rec.exempt_certificate_number||' Reason '||tax_rec.exempt_reason_code);
			End If;
                        G_RAIL_REC.TAX_EXEMPT_NUMBER := tax_rec.exempt_certificate_number;
                        G_RAIL_REC.TAX_EXEMPT_REASON_CODE := tax_rec.exempt_reason_code;
                    END IF;

                    CLOSE cur_tax;
          ElsIF
                Rul_line_rec.exempt_certificate_number IS NOT NULL THEN
                     G_RAIL_REC.TAX_EXEMPT_NUMBER := Rul_line_rec.exempt_certificate_number;
                     G_RAIL_REC.TAX_EXEMPT_REASON_CODE := Rul_line_rec.exempt_reason_code;


                OPEN tax_info_csr(Rul_line_rec.ship_to_site_use_id);
                FETCH tax_info_csr INTO l_bill_to_party_id, l_ship_to_party_site_id;
                CLOSE tax_info_csr;

                OPEN tax_info_csr(Rul_line_rec.bill_to_site_use_id);
                FETCH tax_info_csr INTO l_bill_to_party_id, l_bill_to_party_site_id;
                CLOSE tax_info_csr;

                OPEN Cur_Batch_Source_Id(rul_hdr_rec.org_id);
                FETCH Cur_Batch_Source_Id INTO l_batch_source_id;
                CLOSE Cur_Batch_Source_Id;


If G_LOG_YES_NO = 'YES' then
FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB. ZX API '||G_RAIL_REC.tax_exempt_number||' rsn '||G_RAIL_REC.tax_exempt_reason_code||' ship '||Rul_line_rec.ship_to_site_use_id);
FND_FILE.PUT_LINE(FND_FILE.LOG,'ZX API '||Rul_line_rec.bill_to_site_use_id||' cust '||Rul_line_rec.cust_acct_id||' s site '||l_ship_to_party_site_id||' b site '||l_bill_to_party_site_id);
FND_FILE.PUT_LINE(FND_FILE.LOG,'ZX API trx'||G_RAIL_REC.CUST_TRX_TYPE_ID||' Batch '||l_batch_source_id||' date '||Bcl_rec.DATE_NEXT_INVOICE);
end if;


                ZX_TCM_VALIDATE_EXEMPT_PKG.VALIDATE_TAX_EXEMPTIONS
                (p_tax_exempt_number => G_RAIL_REC.tax_exempt_number,
                 p_tax_exempt_reason_code => G_RAIL_REC.tax_exempt_reason_code,
                 p_ship_to_org_id => Rul_line_rec.ship_to_site_use_id,
                 p_invoice_to_org_id => Rul_line_rec.bill_to_site_use_id,
                 p_bill_to_cust_account_id => Rul_line_rec.cust_acct_id,
                 p_ship_to_party_site_id => l_ship_to_party_site_id,
                 p_bill_to_party_site_id => l_bill_to_party_site_id,
                 p_org_id => rul_hdr_rec.org_id,
                 p_bill_to_party_id => l_bill_to_party_id,
                 p_legal_entity_id => NULL,
                 p_trx_type_id => G_RAIL_REC.CUST_TRX_TYPE_ID,
                 p_batch_source_id => l_batch_source_id,
                 p_trx_date => Bcl_rec.DATE_NEXT_INVOICE,
                 p_exemption_status => 'PMU',  --fix bug 4766994
                 x_valid_flag => l_valid_flag,
                 x_return_status => l_ret_stat,
                 x_msg_count => l_msg_count,
                 x_msg_data => l_msg_data);


                if l_valid_flag <> 'Y' Then
		      If G_LOG_YES_NO = 'YES' then
FND_FILE.PUT_LINE(FND_FILE.LOG,'After call to ZX API return status '||l_valid_flag||' '||rul_line_rec.exempt_certificate_number||' date '||Bcl_rec.DATE_NEXT_INVOICE);
		      End If;
                        --reset the tax_exempt_flag to 'S'
                      G_RAIL_REC.TAX_EXEMPT_FLAG := 'S';
                      G_RAIL_REC.TAX_EXEMPT_NUMBER := NULL;
                      G_RAIL_REC.TAX_EXEMPT_REASON_CODE := NULL;
                 END IF;

            ELSE
               G_RAIL_REC.TAX_EXEMPT_FLAG := 'S';
               G_RAIL_REC.TAX_EXEMPT_NUMBER := NULL;
               G_RAIL_REC.TAX_EXEMPT_REASON_CODE := NULL;
            END IF;

       ELSE
           If G_RAIL_REC.TAX_EXEMPT_FLAG is NULL Then --- should not override header
                G_RAIL_REC.TAX_EXEMPT_FLAG := 'S';
                G_RAIL_REC.TAX_EXEMPT_NUMBER := NULL;
                G_RAIL_REC.TAX_EXEMPT_REASON_CODE := NULL;
           End If;

       END IF;---- IF (Rul_line_rec.tax_status IS NOT NULL OR Rul_line_rec.tax_classification_code is not null)

        --For tax classification code:
        --(1)if tax_classification_code is not null, use that
        --(2)otherwise use the old tax_code and query tax_classification_code
        --from zx_id_tcc_mapping
        IF (Rul_line_rec.tax_classification_code IS NOT NULL) THEN
            --new contracts
            G_RAIL_REC.TAX_CODE := Rul_line_rec.tax_classification_code;
		  If G_LOG_YES_NO = 'YES' then
			FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB. classification code '||G_RAIL_REC.TAX_CODE);
		  End If;
        ELSIF Rul_line_rec.tax_code IS NOT NULL THEN
            --old contracts
            OPEN  cur_tax_code(Rul_line_rec.tax_code, rul_hdr_rec.org_id);
            FETCH cur_tax_code into G_RAIL_REC.TAX_CODE;
            CLOSE cur_tax_code;
		  If G_LOG_YES_NO = 'YES' then
			FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB. derived from tax code '||G_RAIL_REC.TAX_CODE);
		  End If;

        ELSE
            G_RAIL_REC.TAX_CODE := NULL;
        END IF; -- IF (Rul_line_rec.tax_classification_code IS NOT NULL)
        --End fixes of eBtyax uptake bug#4756579

          -----IF (bcl_rec.bill_action in ('AV','TR','STR')) THEN
        IF (rul_line_rec.inv_rule_id IS NOT NULL) THEN
          IF (bcl_rec.bill_action in ('TR','STR')) THEN
            G_RAIL_REC.INVOICING_RULE_ID := NULL;
          ELSE
            G_RAIL_REC.INVOICING_RULE_ID := Rul_line_rec.inv_rule_id;
          END IF;
          G_RAIL_REC.TRX_DATE  := Bcl_rec.DATE_NEXT_INVOICE;
        END IF;

        IF (rul_line_rec.cust_acct_id IS NOT NULL) THEN
          G_RAIL_REC.ORIG_SYSTEM_SOLD_CUSTOMER_ID := Rul_line_rec.cust_acct_id;
        END IF;


        IF (Rul_line_rec.acct_rule_id is NOT NULL) THEN
          OPEN  acct_type(rul_line_rec.acct_rule_id);
          FETCH acct_type into l_type,l_acct_frequency;
          CLOSE acct_type;

          IF (l_type  = 'ACC_DUR') THEN
                  l_acct_calender := get_acct_calender(G_RAIL_REC.SET_OF_BOOKS_ID);

            l_start_date:=Greatest(Bcl_rec.date_billeD_from,lines_rec.start_date);
            l_End_date   := Least(Bcl_rec.date_billed_to,lines_rec.End_date);
            l_End_date   := l_End_date + 1;

            --G_RAIL_REC.ACCOUNTING_RULE_DURATION := CEIL(MONTHS_BETWEEN(l_End_date,l_start_date));

                  GL_CALENDAR_PKG.get_num_periods_in_date_range(
                                    CALENDAR_NAME     =>  l_acct_calender,
                                                PERIOD_TYPE       =>  l_acct_frequency,
                                                START_DATE        =>  l_start_date,
                                                END_DATE          =>  l_end_date,
                                                CHECK_MISSING     =>  FALSE,
                                                NUM_PERIODS       =>  l_num_periods,
                                                RETURN_CODE       =>  l_ret_stat,
                                                UNMAPPED_DATE     =>  l_unmapped_date);

            G_RAIL_REC.ACCOUNTING_RULE_DURATION := l_num_periods;

            -- This column must be a positive integer for AR
            IF (G_RAIL_REC.ACCOUNTING_RULE_DURATION = 0)  THEN
              G_RAIL_REC.ACCOUNTING_RULE_DURATION := 1;
            END IF;
          ELSE
            G_RAIL_REC.ACCOUNTING_RULE_DURATION := NULL ;
          END IF;

          G_RAIL_REC.ACCOUNTING_RULE_ID := Rul_line_rec.acct_rule_id;

          ---IF (bcl_rec.bill_action in ('AV','TR','STR')) THEN
          IF (bcl_rec.bill_action in ('TR','STR')) THEN
              G_RAIL_REC.ACCOUNTING_RULE_ID := NULL;
              G_RAIL_REC.CREDIT_METHOD_FOR_ACCT_RULE := 'UNIT';
              G_RAIL_REC.CREDIT_METHOD_FOR_INSTALLMENTS := 'LIFO';
          ELSE
            G_RAIL_REC.CREDIT_METHOD_FOR_ACCT_RULE := NULL;
            G_RAIL_REC.CREDIT_METHOD_FOR_INSTALLMENTS := NULL;
          END IF;

        END IF;

        ------END OF LINE RULE READING --------------------------------



        If G_LOG_YES_NO = 'YES' then
           FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Done with processing line rules');
           FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Updated all G_RAIL Field');
        End If;



        Set_aggrement_and_contacts(bcl_rec.dnz_chr_id,
                                   bcl_rec.cle_id,
                                   bcl_rec.date_billed_from,
                                   bcl_rec.bill_action);
        If G_LOG_YES_NO = 'YES' then
          FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => After Calling Set_aggrement_and_contacts');
        End If;

        Set_comments(bcl_rec.bill_action);
        If G_LOG_YES_NO = 'YES' then
          FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => After Calling Set_comments ');
        End If;

        Set_attributes(rul_hdr_rec.contract_number,
                       rul_hdr_rec.contract_number_modifier,
                       bcl_rec.date_billed_From,
                       bcl_rec.date_billed_to,
                       bcl_rec.start_date,
                       bcl_rec.cle_id,
                       rul_hdr_rec.attribute_category,
                       rul_hdr_rec.attribute1,
                       rul_hdr_rec.attribute2,
                       rul_hdr_rec.attribute3,
                       rul_hdr_rec.attribute4,
                       rul_hdr_rec.attribute5,
                       rul_hdr_rec.attribute6,
                       rul_hdr_rec.attribute7,
                       rul_hdr_rec.attribute8,
                       rul_hdr_rec.attribute9,
                       rul_hdr_rec.attribute10,
                       rul_hdr_rec.attribute11,
                       rul_hdr_rec.attribute12,
                       rul_hdr_rec.attribute13,
                       rul_hdr_rec.attribute14,
                       rul_hdr_rec.attribute15,
                       nvl(bcl_rec.currency_code,rul_hdr_rec.currency_code),
                       rul_hdr_rec.cust_po_number,
                       bcl_rec.dnz_chr_id,
                       rul_hdr_rec.org_id,
                       l_ret_stat
                       );

	-- Added by sjanakir for Bug#6524778
	IF l_type IN ('ACC_DUR','A') THEN
		G_RAIL_REC.RULE_END_DATE     := NULL;
	END IF;
	-- Addition Ends

        If G_LOG_YES_NO = 'YES' then
          FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => After Calling Set_attributes ');
        End If;


        G_RAIL_REC.sales_order_line   := bcl_rec.top_line_number;
        G_RAIL_REC.contract_line_id   := bcl_rec.cle_id;

        If G_LOG_YES_NO = 'YES' then
          FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => After setting line number ');
        End If;

        Set_gl_date ( p_cle_id  => bcl_rec.cle_id,
                      p_date_billed_from  => to_date(G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE7,'YYYY/MM/DD HH24:MI:SS'),
                      p_bill_action => bcl_rec.bill_action);

        If G_LOG_YES_NO = 'YES' then
          FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => After Calling Set_gl_date ');
        End If;


        IF (l_ret_stat <> 'S') THEN
          IF (P_PRV <> 3) THEN
            x_msg_count := l_msg_cnt;
            x_msg_data  := l_msg_data;
          END IF;

          ---DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_AR_TRANSACTION');
          RAISE MAIN_CUR_EXCEPTION;

        END IF;


        G_RAIL_REC.reference_line_id := NULL;
        G_RAIL_REC.payment_trxn_extension_id  :=  NULL;
        G_RAIL_REC.receipt_method_id  :=  NULL;

	IF  (P_PRV = 1 ) Then

            If G_LOG_YES_NO = 'YES' then
              FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Payment method is '||rul_hdr_rec.payment_type);
            End If;

             IF nvl(rul_hdr_rec.payment_type,'XX') = 'COM'
                    and  bcl_rec.trxn_extension_id is NULL then
	         set_commitment(rul_hdr_rec.commitment_id,
                                rul_hdr_rec.bill_to_site_use_id,
			        rul_line_rec.commitment_id,
				bcl_rec.cle_id,
				bcl_rec.dnz_chr_id,
				bcl_rec.cust_acct_id,
                                header_rec.org_id );
             End if;
             ---------------------
             IF nvl(rul_hdr_rec.payment_type,'XX')= 'CCR' Then

		l_as_of_date := bcl_rec.date_next_invoice;
		IF l_as_of_date IS NULL THEN
			l_as_of_date := SYSDATE;
		END IF;
                    IF bcl_rec.trxn_extension_id is NOT NULL then
                        G_RAIL_REC.payment_trxn_extension_id  :=
                               bcl_rec.trxn_extension_id;
			/* Commented and Modification done by sjanakir for Bug #6855301
     	                G_RAIL_REC.receipt_method_id :=  to_number(nvl(FND_PROFILE.VALUE_SPECIFIC('OKS_RECEIPT_METHOD_ID', NULL, NULL, NULL, rul_hdr_rec.org_id, NULL),'0'));*/
			G_RAIL_REC.receipt_method_id := Get_receipt_method_id (p_customer_id 		=> l_cust_id,
									       p_site_use_id		=> l_site_use_id,
									       p_cc_only		=> l_cc_only		,
									       p_as_of_date		=> TRUNC(l_as_of_date)	,
									       p_org_id			=> rul_hdr_rec.org_id)	;
                    ---check to ensure line commitment is not overwritten
                    ElsIf rul_line_rec.commitment_id is NULL Then
	               set_extn_id_at_party(rul_hdr_rec.bill_to_site_use_id,
                                            rul_hdr_rec.trxn_extension_id,
                                            bcl_rec.cust_acct_id,
                                            header_rec.org_id );
                       /* Added by sjanakir for Bug #6855301 */
		       IF (G_RAIL_REC.payment_trxn_extension_id  = rul_hdr_rec.trxn_extension_id) THEN
                   	 G_RAIL_REC.receipt_method_id := Get_receipt_method_id (p_customer_id 		=> l_cust_id,
                   	 							p_site_use_id		=> l_site_use_id,
                   	 							p_cc_only		=> l_cc_only,
                   	 							p_as_of_date		=> TRUNC(l_as_of_date),
                   	 							p_org_id		=> rul_hdr_rec.org_id);
         	       END IF;

                    End if;
				/* Added by sjanakir for Bug# 6872005 */
                    /* Modified by cgopinee for PA-DSS enhancement*/
				   l_cc_expired := check_CC_valid ( p_trxn_extension_id => G_RAIL_REC.payment_trxn_extension_id);

				   IF l_cc_expired ='N' THEN
						IF G_LOG_YES_NO = 'YES' THEN
							FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Credit card is not expired');
						END IF;
				   ELSE
					    IF G_LOG_YES_NO = 'YES' THEN
			       			FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Credit card has expired');
			       		END IF;

						RAISE MAIN_CUR_EXCEPTION;
				   END IF;
			   /* Addition Ends */


             END IF;

        END IF;


        Set_salesrep_id (bcl_rec.dnz_Chr_id);
        If G_LOG_YES_NO = 'YES' then
          FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => After Calling Set_salesrep_id ');
        End If;

        Set_qty_and_uom(bcl_rec.cle_id,
                        bcl_rec.dnz_chr_id,
                        bcl_rec.date_billed_from,
                        bcl_rec.date_billed_to,
                        bcl_rec.bill_action,
                        bcl_rec.lse_id,
                        'Y');
        If G_LOG_YES_NO = 'YES' then
          FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => After Calling Set_qty_and_uom ');
        End If;


       /****
       Bug# 5215768. As decided upon By AR team, Ramesh, Aaron, it was decided
       to pass Lifo rule to Usage CM lines
       Hari -   11-May-2006
       *****/
       IF bcl_rec.lse_id = 12 and p_prv = 3 Then
           G_RAIL_REC.CREDIT_METHOD_FOR_ACCT_RULE := 'LIFO';
       ELSIF bcl_rec.lse_id = 46 and p_prv = 3 Then
           G_RAIL_REC.CREDIT_METHOD_FOR_ACCT_RULE := 'UNIT';
       End if;

       -------------------------------------------------

        -- Set l_bill_profile . This parameter is used to decide wheather
        -- to do summary billing or detailed billing

        -----IF (bcl_rec.bill_action in ('AV','TR','STR')) THEN
        IF (bcl_rec.bill_action in ('TR','STR')) THEN
          l_bsl_id := NULL;
          l_chk_bcl_id := -44;
          OPEN   check_summary_billed (bcl_rec.cle_id,
                                       bcl_rec.date_billed_from,
                                       bcl_rec.date_billed_to );
          FETCH  check_summary_billed into l_bsl_id,l_chk_bcl_id;


          /*** for OM originated contracts, since there are no records in Bill Transactions
		     table. The credit transaction should be detailed.
			refer bug# 4353365 and 4365540   ****/

          IF check_summary_billed%NOTFOUND THEN
                l_chk_bcl_id := -44;
		End if;

          CLOSE  check_summary_billed ;
          IF ((l_bsl_id IS NULL) AND (l_chk_bcl_id <> -44)) THEN
            l_bill_profile := G_SUM;
          ELSE
            l_bill_profile := G_DET;
          END IF;

        ELSE
          IF (bcl_rec.lse_id = 12) THEN
            l_bill_profile := G_DET;
          ELSE
            IF (l_hdr_summary_flag = 'Y') THEN --Summary flag set in contract
              l_bill_profile := G_SUM;
            ELSE  -- read profile value
              l_bill_profile_flag := FND_PROFILE.VALUE('OKS_AR_TRANSACTIONS_SUBMIT_SUMMARY_YN');
              IF (l_bill_profile_flag = 'YES') THEN
                l_bill_profile := G_SUM;
              ELSE
                l_bill_profile := G_DET;
              END IF;
            END IF;
          END IF;
        END IF;


        -- BUG FIX  3401601.
        -- Added substrb
        G_RAIL_REC.interface_line_attribute9 := substrb(bcl_rec.lse_name,1,30);


        IF (l_bill_profile = G_SUM) THEN
          If G_LOG_YES_NO = 'YES' then
             FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Summary Bill Processing');
          End If;
          Set_ref_line_id( bcl_rec.bill_action,
                           bcl_rec.lse_id,
                           bcl_rec.cle_id,
                           bcl_rec.id,
                           bcl_rec.date_billed_From,
                           bcl_rec.date_billed_to,
                           rul_hdr_rec.commitment_id,
                           rul_line_rec.commitment_id,
                           header_rec.contract_number,
                           header_rec.contract_number_modifier,
                           NULL,
                           'Y',
                           l_line_payment_mth,
					  l_ret_stat
        --                                l_cust_trx_id,
        --                                        l_cust_trx_line_id
                          );

          IF (l_ret_stat <> 'S')  THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER Auto Invoice Not Run'||Bcl_rec.cle_id);
            ---DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_AR_TRANSACTION');
            RAISE MAIN_CUR_EXCEPTION;
          End if;


          If G_LOG_YES_NO = 'YES' then
             FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Before call to insert bill_txn_line');
          End If;

          IF ((p_prv = 1) OR (p_prv = 3)) THEN


            --l_btlv_tbl_in(1).TRX_LINE_AMOUNT  :=   Bcl_rec.amount;
            l_btlv_tbl_in(1).TRX_AMOUNT  :=   Bcl_rec.amount;
            l_btlv_tbl_in(1).BSL_ID           :=   NULL;

            OKS_BILLTRAN_LINE_PUB.insert_Bill_Tran_Line_Pub
                       (
                        p_api_version                  =>  1.0,
                        p_init_msg_list                =>  'T',
                        x_return_status                =>   l_ret_stat,
                        x_msg_count                    =>   l_msg_cnt,
                        x_msg_data                     =>   l_msg_data,
                        p_btlv_tbl                     =>   l_btlv_tbl_in,
                        x_btlv_tbl                     =>   l_btlv_tbl_out
                        );
         If G_LOG_YES_NO = 'YES' then
             FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => After calling OKS_BILLTRAN_LINE_PUB.insert_Bill_Tran_Line_Pub l_return_status'||l_ret_stat);
          End If;

          ELSIF (p_prv = 2) THEN
            l_btl_pr_tbl_in(1).ID   := oks_bill_rec_pub.get_seq_id;
            l_btl_pr_tbl_in(1).TRX_LINE_AMOUNT  :=   Bcl_rec.amount;
            l_btl_pr_tbl_in(1).BSL_ID  :=   NULL;
            l_btl_pr_tbl_in(1).OBJECT_VERSION_NUMBER  :=   1.0;
            l_btl_pr_tbl_in(1).CREATED_BY  :=   FND_GLOBAL.user_id;
            l_btl_pr_tbl_in(1).CREATION_DATE  :=   sysdate;
            l_btl_pr_tbl_in(1).LAST_UPDATED_BY := FND_GLOBAL.user_id;
            l_btl_pr_tbl_in(1).LAST_UPDATE_LOGIN:=FND_GLOBAL.user_id;
            l_btl_pr_tbl_in(1).LAST_UPDATE_DATE  :=   sysdate;
            l_btl_pr_tbl_in(1).BILL_INSTANCE_NUMBER  := -99;
            l_btl_pr_tbl_in(1).TRX_LINE_AMOUNT  := NULL;
            l_btl_pr_tbl_in(1).TRX_LINE_TAX_AMOUNT  := NULL;
            l_btl_pr_tbl_in(1).ATTRIBUTE_CATEGORY  := NULL;
            l_btl_pr_tbl_in(1).ATTRIBUTE1  := NULL;
            l_btl_pr_tbl_in(1).ATTRIBUTE2  := NULL;
            l_btl_pr_tbl_in(1).ATTRIBUTE3  := NULL;
            l_btl_pr_tbl_in(1).ATTRIBUTE4  := NULL;
            l_btl_pr_tbl_in(1).ATTRIBUTE5  := NULL;
            l_btl_pr_tbl_in(1).ATTRIBUTE6  := NULL;
            l_btl_pr_tbl_in(1).ATTRIBUTE7  := NULL;
            l_btl_pr_tbl_in(1).ATTRIBUTE8  := NULL;
            l_btl_pr_tbl_in(1).ATTRIBUTE1  := NULL;
            l_btl_pr_tbl_in(1).ATTRIBUTE9  := NULL;
            l_btl_pr_tbl_in(1).ATTRIBUTE10  := NULL;
            l_btl_pr_tbl_in(1).ATTRIBUTE11  := NULL;
            l_btl_pr_tbl_in(1).ATTRIBUTE12  := NULL;
            l_btl_pr_tbl_in(1).ATTRIBUTE13  := NULL;
            l_btl_pr_tbl_in(1).ATTRIBUTE14  := NULL;
            l_btl_pr_tbl_in(1).ATTRIBUTE15  := NULL;
            l_btl_pr_tbl_in(1).SECURITY_GROUP_ID  := NULL;

            OKS_BILLTRAN_LINE_PRV_PUB.insert_btl_pr(
                         p_api_version      => 1.0,
                         p_init_msg_list    => 'T',
                         x_return_status    => l_ret_stat,
                         x_msg_count        => l_msg_cnt,
                         x_msg_data         => l_msg_data,
                         p_btl_pr_tbl       => l_btl_pr_tbl_in,
                         x_btl_pr_tbl       => l_btl_pr_tbl_out);
          END IF;

          IF (l_ret_stat <> 'S')  THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER Insert into Bill_Tran_lines Failed For'||Bcl_rec.cle_id);
            oks_bill_rec_pub.get_message
                         (l_msg_cnt  => l_msg_cnt,
                          l_msg_data => l_msg_data);

            IF (P_PRV <> 3) THEN
              x_msg_count := l_msg_cnt;
              x_msg_data  := l_msg_data;
            END IF;

            ---DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_AR_TRANSACTION');
            RAISE MAIN_CUR_EXCEPTION;
          END IF;

          l_amount := (bcl_rec.amount);

          IF ((p_prv = 1) OR (p_prv = 3)) THEN

            Set_line_attribute(bcl_rec.cle_id,
                               bcl_rec.date_billed_From,
                               lines_rec.block23text,
                               rul_line_rec.invoice_text,
                               lines_rec.item_description,
                               l_btlv_tbl_out(1).bill_instance_number,
                               l_amount,
                               rul_line_rec.inv_print_flag,
                               lines_rec.attribute1,
                               lines_rec.attribute2,
                               lines_rec.attribute3,
                               lines_rec.attribute4,
                               lines_rec.attribute5,
                               lines_rec.attribute6,
                               lines_rec.attribute7,
                               lines_rec.attribute8,
                               lines_rec.attribute9,
                               lines_rec.attribute10,
                               lines_rec.attribute11,
                               lines_rec.attribute12,
                               lines_rec.attribute13,
                               lines_rec.attribute14,
                               lines_rec.attribute15,
                               lines_rec.attribute_category
                               );


            If G_LOG_YES_NO = 'YES' then
               FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Before call to ra_interface_lines');
            End If;

            G_RAIL_REC.invoiced_line_acctg_level := 'S';
            G_RAIL_REC.source_data_key1          := bcl_rec.cle_id;
            G_RAIL_REC.source_data_key2          := bcl_rec.id;

            Insert_ra_interface
                 (
                  l_ret_stat,
                  l_msg_cnt,
                  l_msg_data
                 );

            IF (l_ret_stat <> 'S') THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Insert into RA_Interface_Lines Failed For'||Bcl_rec.cle_id);
              oks_bill_rec_pub.get_message
                            (l_msg_cnt  => l_msg_cnt,
                             l_msg_data => l_msg_data);


              IF (P_PRV <> 3) THEN
                x_msg_count := l_msg_cnt;
                x_msg_data  := l_msg_data;

              END IF;
              ----DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_AR_TRANSACTION');
              RAISE MAIN_CUR_EXCEPTION;
            END IF;

            IF  P_PRV = 1 THEN

              UPDATE oks_bill_txn_lines
              SET cycle_refrence = G_RAIL_REC.interface_line_attribute10
              WHERE bill_instance_number = TO_NUMBER(G_RAIL_REC.interface_line_attribute3);
            END IF;


            If G_LOG_YES_NO = 'YES' then
               FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => End of Bill processing And Beginning of Revenue');
            End If;

            insert_ra_rev_dist( l_ret_stat,bcl_rec.cle_id);

            IF (l_ret_stat <> 'S') THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Insert INTO RA_REVENUE_DISTRIBUTIONS'||lines_rec.id);
              IF (P_PRV <> 3) THEN
                x_msg_count := l_msg_cnt;
                x_msg_data  := l_msg_data;

              END IF;
              ---DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_AR_TRANSACTION');
              RAISE MAIN_CUR_EXCEPTION;
            END IF;


            If G_LOG_YES_NO = 'YES' then
               FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => End of Revenue processing And Beginning of Sales Credit');
            End If;
            --mchoudha Fix for bug#4174921
            --added parameter p_hdr_id
            Sales_credit(Bcl_rec.cle_id ,
                         Bcl_rec.dnz_chr_id,
                         l_ret_stat);

            IF (l_ret_stat <> 'S') THEN

              IF (P_PRV <> 3) THEN
                x_msg_count := l_msg_cnt;
                x_msg_data  := l_msg_data;

              END IF;
              ---DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_AR_TRANSACTION');
              RAISE MAIN_CUR_EXCEPTION;
            END IF;

            If G_LOG_YES_NO = 'YES' then
               FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => End of sales credit processing ');
            End If;

          END IF; -- ((p_prv = 1) OR (p_prv = 3))

        ELSIF ( l_bill_profile = G_DET)  THEN

          If G_LOG_YES_NO = 'YES' then
             FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Detail Bill Processing');
          End If;

          ----This is for Usage averaging line to skip report
          if bcl_rec.bill_action = 'AV' Then
               report_bill_action := 'AV';
          end if;

          BSL_REC_NUM := 1;

          FOR BSL_REC IN Cur_BSL(Bcl_rec.id)
          LOOP

            If G_LOG_YES_NO = 'YES' then
               FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Processing Sub_Line Record'||BSL_REC_NUM||'.'||bsl_rec.cle_id);
            End If;
            BSL_REC_NUM := BSL_REC_NUM + 1;
            l_bill_instance_number := NULL;

            ----set_qty should only be called from top  line
           /* Set_qty_and_uom(bsl_rec.cle_id,
                            bcl_rec.dnz_chr_id,
                            bsl_rec.date_billed_from,
                            bsl_rec.date_billed_to,
                            bcl_rec.bill_action,
                            bcl_rec.lse_id,
                            'N');*/


            IF (l_lse_id in (19,1,12)) THEN
              OPEN  Cur_lsl_type(bsl_rec.cle_id);
              FETCH Cur_lsl_type into l_sublse_id, l_lse_name;
              CLOSE Cur_lsl_type;
              l_desc := l_lse_name || ':';
            END IF;


             /*******
                 The quantity and the uom_code is populated with instance qty and uom
                 for covered product. This is bug fix as part of Kronos.
                 refer bug# 4706155
                 for covered levels other than products, the derivation of quantity
                 and the uom will reamin as is.
              *************/

               IF bsl_rec.lse_id in (9,25) Then
                      OPEN  cur_okc_k_item_qty(bsl_rec.cle_id);
                      FETCH cur_okc_k_item_qty into G_RAIL_REC.QUANTITY, G_RAIL_REC.UOM_CODE;
                      CLOSE cur_okc_k_item_qty;
                      G_RAIL_REC.QUANTITY_ORDERED := G_RAIL_REC.QUANTITY;
                      IF p_prv = 3 THEN
                                G_RAIL_REC.CREDIT_METHOD_FOR_ACCT_RULE := 'UNIT';
                      End if;
               END IF;

               ---- End of kronos fix

         /***
            This is to honor the contract contengices by sending
            the order line id of the goods sold. Th edeferral flag is always
            set to 'Y', so that AR will not apply defaulting rules
         **/

           IF bsl_rec.lse_id in (25,9) Then
               OPEN Cur_Parent_Order_line(bsl_rec.cle_id);
               Fetch Cur_Parent_Order_line into
                   G_RAIL_REC.parent_line_id;
               Close Cur_Parent_Order_line;
           End If;

           G_RAIL_REC.deferral_exclusion_flag := 'Y';



            G_RAIL_REC.sales_order_line   := bcl_rec.top_line_number||'.'||bsl_rec.sub_line_number;
		  --- Top line id will be overwritten by sub line id for detailed billing
            G_RAIL_REC.contract_line_id   := bsl_rec.cle_id;


            Set_ref_line_id(
                            bcl_rec.bill_action,
                            bsl_rec.lse_id,
                            bsl_rec.cle_id,
                            bsl_rec.id,
                            bsl_rec.date_billed_From,
                            bsl_rec.date_billed_to,
                            rul_hdr_rec.commitment_id,
                            rul_line_rec.commitment_id,
                            header_rec.contract_number,
                            header_rec.contract_number_modifier,
                            bsl_rec.average,
                            'N',
                            l_line_payment_mth,
					   l_ret_stat
                --                         l_cust_trx_id,
                --                         l_cust_trx_line_id
                            );

          IF (l_ret_stat <> 'S')  THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER Auto Invoice Not Run'||Bcl_rec.cle_id);
            ---DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_AR_TRANSACTION');
            RAISE MAIN_CUR_EXCEPTION;
          End if;

            If G_LOG_YES_NO = 'YES' then
               FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => After calling Set_ref_line_id ');
            End If;

            IF ((p_prv =1) OR ( p_prv = 3)) THEN
              l_btlv_tbl_in(1).BSL_ID := bsl_rec.id;
              --l_btlv_tbl_in(1).TRX_LINE_AMOUNT := bsl_rec.amount;
              l_btlv_tbl_in(1).TRX_AMOUNT := bsl_rec.amount;

              OKS_BILLTRAN_LINE_PUB.insert_Bill_Tran_Line_Pub
                            (
                            p_api_version                  =>  1.0,
                            p_init_msg_list                =>  'T',
                            x_return_status                =>   l_ret_stat,
                            x_msg_count                    =>   l_msg_cnt,
                            x_msg_data                     =>   l_msg_data,
                            p_btlv_tbl                     =>   l_btlv_tbl_in,
                            x_btlv_tbl                     =>   l_btlv_tbl_out
                            );
              If G_LOG_YES_NO = 'YES' then
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => After call to insert bill_txn_lines l_return_status '||l_ret_stat);
              End If;

            ELSIF (p_prv =2 ) THEN
              l_btl_pr_tbl_in(1).ID     := oks_bill_rec_pub.get_seq_id;
              l_btl_pr_tbl_in(1).TRX_LINE_AMOUNT  :=   Bsl_rec.amount;
              l_btl_pr_tbl_in(1).BSL_ID  :=   bsl_rec.id;
              l_btl_pr_tbl_in(1).OBJECT_VERSION_NUMBER  :=   1.0;
              l_btl_pr_tbl_in(1).CREATED_BY  :=   FND_GLOBAL.user_id;
              l_btl_pr_tbl_in(1).CREATION_DATE  :=   sysdate;
              l_btl_pr_tbl_in(1).LAST_UPDATED_BY := FND_GLOBAL.user_id;
              l_btl_pr_tbl_in(1).LAST_UPDATE_LOGIN:=FND_GLOBAL.user_id;
              l_btl_pr_tbl_in(1).LAST_UPDATE_DATE  :=   sysdate;
              l_btl_pr_tbl_in(1).BILL_INSTANCE_NUMBER  := -99;
              l_btl_pr_tbl_in(1).TRX_LINE_AMOUNT  := NULL;
              l_btl_pr_tbl_in(1).TRX_LINE_TAX_AMOUNT  := NULL;
              l_btl_pr_tbl_in(1).ATTRIBUTE_CATEGORY  := NULL;
              l_btl_pr_tbl_in(1).ATTRIBUTE1  := NULL;
              l_btl_pr_tbl_in(1).ATTRIBUTE2  := NULL;
              l_btl_pr_tbl_in(1).ATTRIBUTE3  := NULL;
              l_btl_pr_tbl_in(1).ATTRIBUTE4  := NULL;
              l_btl_pr_tbl_in(1).ATTRIBUTE5  := NULL;
              l_btl_pr_tbl_in(1).ATTRIBUTE6  := NULL;
              l_btl_pr_tbl_in(1).ATTRIBUTE7  := NULL;
              l_btl_pr_tbl_in(1).ATTRIBUTE8  := NULL;
              l_btl_pr_tbl_in(1).ATTRIBUTE1  := NULL;
              l_btl_pr_tbl_in(1).ATTRIBUTE9  := NULL;
              l_btl_pr_tbl_in(1).ATTRIBUTE10  := NULL;
              l_btl_pr_tbl_in(1).ATTRIBUTE11  := NULL;
              l_btl_pr_tbl_in(1).ATTRIBUTE12  := NULL;
              l_btl_pr_tbl_in(1).ATTRIBUTE13  := NULL;
              l_btl_pr_tbl_in(1).ATTRIBUTE14  := NULL;
              l_btl_pr_tbl_in(1).ATTRIBUTE15  := NULL;
              l_btl_pr_tbl_in(1).SECURITY_GROUP_ID  := NULL;

              OKS_BILLTRAN_LINE_PRV_PUB.insert_btl_pr(
                         p_api_version      => 1.0,
                         p_init_msg_list    => 'T',
                         x_return_status    => l_ret_stat,
                         x_msg_count        => l_msg_cnt,
                         x_msg_data         => l_msg_data,
                         p_btl_pr_tbl       => l_btl_pr_tbl_in,
                         x_btl_pr_tbl       => l_btl_pr_tbl_out);



            END IF;

            IF (l_ret_stat <> 'S') THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Insert into Bill_Tran_lines Failed For'||bsl_rec.cle_id);
              oks_bill_rec_pub.get_message
                          (l_msg_cnt  => l_msg_cnt,
                           l_msg_data => l_msg_data);

              x_msg_count := l_msg_cnt;
              x_msg_data  := l_msg_data;
              ---DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_AR_TRANSACTION');
              RAISE MAIN_CUR_EXCEPTION;
            END IF;

            l_amount := (bsl_rec.amount);

            --start nechatur Fix for bug#4390448
            --pass the billed usage quantity and uom_code to ra_interface_lines
            IF l_lse_id = 12 THEN
              IF (l_usage_type <> 'NPR') THEN
                 Open Cur_bsd(Bsl_rec.id);
                 Fetch Cur_bsd into G_RAIL_REC.QUANTITY_ORDERED,G_RAIL_REC.UOM_CODE;
                 G_RAIL_REC.QUANTITY := G_RAIL_REC.QUANTITY_ORDERED;
                 Close Cur_bsd;
              END IF;
              --
              if nvl(l_amount,0) > 0 Then
                 G_RAIL_REC.unit_selling_price := l_amount/G_RAIL_REC.QUANTITY_ORDERED;
              end if;
            END IF;
            --end nechatur Fix for bug#4390448
            OPEN  Cur_k_lines(bsl_rec.cle_id);
            FETCH Cur_k_lines into lines_rec;
            CLOSE Cur_k_lines ;

            IF ((p_prv =1) OR (p_prv  = 3)) THEN
              Set_line_attribute(
                                   bsl_rec.cle_id,
                                   bsl_rec.date_billed_From,
                                   lines_rec.block23text,
                                   bsl_rec.invoice_text,
                                   lines_rec.item_description,
                                   l_btlv_tbl_out(1).bill_instance_number,
                                   l_amount,
                                   bsl_rec.inv_print_flag,
                                   lines_rec.attribute1,
                                   lines_rec.attribute2,
                                   lines_rec.attribute3,
                                   lines_rec.attribute4,
                                   lines_rec.attribute5,
                                   lines_rec.attribute6,
                                   lines_rec.attribute7,
                                   lines_rec.attribute8,
                                   lines_rec.attribute9,
                                   lines_rec.attribute10,
                                   lines_rec.attribute11,
                                   lines_rec.attribute12,
                                   lines_rec.attribute13,
                                   lines_rec.attribute14,
                                   lines_rec.attribute15,
                                   lines_rec.attribute_category
                                       );


            If G_LOG_YES_NO = 'YES' then
               FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => After calling Set_line_attribute ');
            End If;

              G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE4       :=
                        to_char(Bsl_rec.DATE_BILLED_FROM,'YYYY/MM/DD');
              G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE8       :=
                        to_char(lines_rec.start_date,'YYYY/MM/DD');
              G_RAIL_REC.INTERFACE_LINE_ATTRIBUTE5       :=
                        to_char(Bsl_rec.DATE_BILLED_TO,'YYYY/MM/DD');
              G_RAIL_REC.RULE_START_DATE   := Bsl_rec.DATE_BILLED_FROM;
-- Added by sjanakir for Bug#6524778
          	IF l_type IN ('ACC_DUR','A') THEN
	      		G_RAIL_REC.RULE_END_DATE     := NULL;
	      	ELSE
	      		G_RAIL_REC.RULE_END_DATE     := Bsl_rec.DATE_BILLED_TO;
		END IF;
-- Addition Ends

              If G_LOG_YES_NO = 'YES' then
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Before insert into ra_interface_lines');
              End If;

              G_RAIL_REC.invoiced_line_acctg_level := 'D';
              G_RAIL_REC.source_data_key1 := bsl_rec.top_line_id;
              G_RAIL_REC.source_data_key2 := bcl_rec.id;

              l_inv_count    := 0;
              l_interface_pb := 'N';


              IF (( p_prv = 1 ) AND ( bcl_rec.lse_id = 12) AND (rul_line_rec.usage_type <> 'NPR')) THEN
                OPEN  Interface_pb_cur;
                FETCH Interface_pb_cur into l_interface_pb;
                CLOSE Interface_pb_cur;

                         l_price_break_count := 0;

                         open  chk_price_break_cur(bsl_rec.id);
                         fetch chk_price_break_cur into l_price_break_count;
                         close chk_price_break_cur;

              ELSIF (( p_prv = 3 )  AND ( bcl_rec.lse_id = 12)AND (rul_line_rec.usage_type <> 'NPR')) THEN
                OPEN Bill_instance_cur(bsl_rec.id);
                FETCH Bill_instance_cur into l_bill_instance_no;
                CLOSE Bill_instance_cur;

                OPEN  Inv_count_cur(
                                 header_rec.contract_number,
                                 header_rec.contract_number_modifier,
                                 l_bill_instance_no);

                FETCH Inv_count_cur into l_inv_count;
                CLOSE Inv_count_cur;
              END IF;


              IF ( ((p_prv = 1)  AND ( NVL(l_interface_pb,'N') = 'Y') AND
                    (l_price_break_count <> 0)) OR
                   ((p_prv = 3 ) AND (l_inv_count > 1)) OR
                   ( p_prv = 3 AND bcl_rec.bill_action = 'TR' AND l_inv_count= 0 AND
                     bcl_rec.lse_id = 12 AND rul_line_rec.usage_type <> 'NPR' ) ) THEN

                IF (p_prv = 1) THEN
                  G_RAIL_REC.quantity_ordered := 0;
                  G_RAIL_REC.quantity := 0;
                  G_RAIL_REC.amount := 0;
                  G_RAIL_REC.interface_line_attribute6 := 0;

                  Insert_ra_interface
                  (
                        l_ret_stat,
                    l_msg_cnt,
                  l_msg_data
                  );


                  IF (l_ret_stat <> 'S') THEN

                    FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Insert into RA_Interface_Lines Failed For'||bsl_rec.cle_id);
                    oks_bill_rec_pub.get_message
                         (l_msg_cnt  => l_msg_cnt,
                          l_msg_data => l_msg_data);

                    x_msg_count := l_msg_cnt;
                    x_msg_data  := l_msg_data;
                    ---DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_AR_TRANSACTION');
                    RAISE MAIN_CUR_EXCEPTION;
                  END IF;

                  INSERT_RA_REV_DIST( l_ret_stat,
                                      bcl_rec.cle_id);

                  IF (l_ret_stat <> 'S') THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Insert INTO RA_REVENUE_DISTRIBUTIO NS'||lines_rec.id);

                    ---DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_AR_TRANSACTION');
                    RAISE MAIN_CUR_EXCEPTION;
                  END IF;

                  If G_LOG_YES_NO = 'YES' then
                      FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => End of Revenue processing And Beginning of Sales Credit');
                  End If;
                  --mchoudha Fix for bug#4174921
                  --added parameter p_hdr_id
                  SALES_CREDIT(Bcl_rec.cle_id ,
                               Bcl_rec.dnz_chr_id,
                               l_ret_stat);

                  IF ( l_ret_stat <> 'S') THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Insert INTO RA_SALES_CREDIT FAILED'||lines_rec.id);
                    ----DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_AR_TRANSACTION');
                    RAISE MAIN_CUR_EXCEPTION;
                  END IF;
                  If G_LOG_YES_NO = 'YES' then
                     FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => End of sales credit processing ');
                  End If;
               END IF;       -----IF (p_prv = 1)

               IF p_prv = 3 AND bcl_rec.bill_action = 'TR' AND l_inv_count= 0  THEN      ----billing rec not Invoiced
                   --mchoudha Fix for bug#4174921
                   --added parameter p_hdr_id
                   Set_Reference_PB_Value
                          (
                          p_bsl_id            => bsl_rec.id,
                          p_contract_no   => header_rec.contract_number,
                          p_contract_mod  => header_rec.contract_number_modifier,
                          p_bill_inst_no  => l_bill_instance_no,
                          p_amount        => bsl_rec.amount,
                          p_int_att10     => g_rail_rec.interface_line_attribute10,
                          p_bcl_cle_id    => bcl_rec.cle_id,
                          p_currency_code => bcl_rec.currency_code,
                          p_hdr_id        => Bcl_rec.dnz_chr_id,
                          x_msg_cnt       => l_msg_cnt,
                          x_msg_data      => l_msg_data,
                          x_return_status => l_ret_stat
                          );
                ELSE           ----either billing or termination when billing rec are invoiced
                   --mchoudha Fix for bug#4174921
                   --added parameter p_hdr_id
                   Set_price_breaks
                          (
                          p_id            => bsl_rec.id,
                          p_prv           => p_prv,
                          p_contract_no   => header_rec.contract_number,
                          p_contract_mod  => header_rec.contract_number_modifier,
                          p_bill_inst_no  => l_bill_instance_no,
                          p_amount        => bsl_rec.amount,
                          p_int_att10     => g_rail_rec.interface_line_attribute10,
                          p_bcl_cle_id    => bcl_rec.cle_id,
                          p_currency_code => bcl_rec.currency_code,
                          p_hdr_id        => Bcl_rec.dnz_chr_id,
                          x_msg_cnt       => l_msg_cnt,
                          x_msg_data      => l_msg_data,
                          x_return_status => l_ret_stat
                          );
                END IF;          ---l_inv_count chk


               IF (l_ret_stat <> 'S') THEN

                     FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Insert into RA_Interface_Lines Failed For'||bsl_rec.cle_id);
                  oks_bill_rec_pub.get_message
                              (l_msg_cnt  => l_msg_cnt,
                               l_msg_data => l_msg_data);

                    x_msg_count := l_msg_cnt;
                        x_msg_data  := l_msg_data;
                        ----DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_AR_TRANSACTION');
                        RAISE MAIN_CUR_EXCEPTION;
                  END IF;

              ELSE                  ---normal

                 Insert_ra_interface
                    (
                       l_ret_stat,
                       l_msg_cnt,
                       l_msg_data
                   );

                IF (l_ret_stat <> 'S') THEN
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Insert into RA_Interface_Lines Failed For'||bsl_rec.cle_id);
                         oks_bill_rec_pub.get_message
                                     (l_msg_cnt  => l_msg_cnt,
                                      l_msg_data => l_msg_data);

                      x_msg_count := l_msg_cnt;
                      x_msg_data  := l_msg_data;

                  ----DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_AR_TRANSACTION');
                  RAISE MAIN_CUR_EXCEPTION;

                END IF; --IF (l_ret_stat <> 'S')


                IF  P_PRV = 1 THEN

                   UPDATE oks_bill_txn_lines
                   SET cycle_refrence = G_RAIL_REC.interface_line_attribute10
                   WHERE bill_instance_number = TO_NUMBER(G_RAIL_REC.interface_line_attribute3);
                END IF;



                INSERT_RA_REV_DIST( l_ret_stat,bcl_rec.cle_id);

                IF (l_ret_stat <> 'S') THEN
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Insert INTO RA_REVENUE_DISTRIBUTIONS'||lines_rec.id);

                  ---DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_AR_TRANSACTION');
                  RAISE MAIN_CUR_EXCEPTION;
                END IF;

                If G_LOG_YES_NO = 'YES' then
                   FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => End of Revenue processing And Beginning of Sales Credit');
                End If;
                --mchoudha Fix for bug#4174921
                --added parameter p_hdr_id
                SALES_CREDIT(Bcl_rec.cle_id ,
                             Bcl_rec.dnz_chr_id,
                             l_ret_stat);

                IF ( l_ret_stat <> 'S') THEN
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Insert INTO RA_SALES_CREDIT FAILED'||lines_rec.id);
                  ----DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_AR_TRANSACTION');
                  RAISE MAIN_CUR_EXCEPTION;
                END IF;
                If G_LOG_YES_NO = 'YES' then
                   FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => End of sales credit processing ');
                End If;
              END IF;   --IF ( ((p_prv = 1)  AND ( NVL(l_interface_pb,'N') = 'Y'))OR ((p_prv = 3 ) AND (l_inv_count > 1)) )

            END IF; --((p_prv =1) OR (p_prv  = 3))

          END LOOP;-- End OF BSL Loop
        END IF;  -- SUM OR DET

      END IF;   -- Bill_action <> 'TR'

      l_process_counter := l_process_counter + 1;
    EXCEPTION
     WHEN MAIN_CUR_EXCEPTION THEN

        /*FOR BILLING REPORT*/
        --This is done to retrieve the profile value
        --because the error can occur before the profile option
        --is retrieved in the main logic
         IF (bcl_rec.lse_id = 12) THEN
            l_bill_profile := G_DET;
          ELSE
            IF (l_hdr_summary_flag = 'Y') THEN --Summary flag set in contract
              l_bill_profile := G_SUM;
            ELSE  -- read profile value
              l_bill_profile_flag := FND_PROFILE.VALUE('OKS_AR_TRANSACTIONS_SUBMIT_SUMMARY_YN');
              IF (l_bill_profile_flag = 'YES') THEN
                l_bill_profile := G_SUM;
              ELSE
                l_bill_profile := G_DET;
              END IF;
            END IF;
          END IF;

        IF (P_PRV <> 3) THEN
          IF (bcl_rec.lse_id = 46 ) THEN
            l_line_failed := TRUE;
            /*increment rejected for subscription*/
            p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines_Value:= p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines_Value + bcl_rec.amount;
            /*decrement successful for subscription*/
           -- p_billrep_tbl(p_billrep_tbl_idx).Successful_Lines_Value:= p_billrep_tbl(p_billrep_tbl_idx).Successful_Lines_Value - bcl_rec.amount ;
            p_billrep_err_tbl_idx := p_billrep_err_tbl_idx + 1;
            p_billrep_err_tbl(p_billrep_err_tbl_idx).Top_Line_id := bcl_rec.cle_id;
            p_billrep_err_tbl(p_billrep_err_tbl_idx).Lse_Id := 46;
            p_billrep_err_tbl(p_billrep_err_tbl_idx).Sub_line_id := NULL;
            p_billrep_err_tbl(p_billrep_err_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;

          ELSE
            IF (l_bill_profile = G_SUM) THEN
              l_line_failed := TRUE;
              p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines_Value:= p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines_Value + bcl_rec.amount;
             -- p_billrep_tbl(p_billrep_tbl_idx).Successful_Lines_Value:= p_billrep_tbl(p_billrep_tbl_idx).Successful_Lines_Value - bcl_rec.amount ;
              /*FOR ERROR REPORT*/
              p_billrep_err_tbl_idx := p_billrep_err_tbl_idx + 1;
              p_billrep_err_tbl(p_billrep_err_tbl_idx).Top_Line_id := bcl_rec.cle_id;
              p_billrep_err_tbl(p_billrep_err_tbl_idx).Lse_Id :=bcl_rec.lse_id;
              p_billrep_err_tbl(p_billrep_err_tbl_idx).Sub_line_id := NULL;
              p_billrep_err_tbl(p_billrep_err_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;

            ELSE
              l_subline_failed := TRUE;
              p_billrep_tbl(p_billrep_tbl_idx).Rejected_SubLines_Value := p_billrep_tbl(p_billrep_tbl_idx).Rejected_SubLines_Value + bcl_rec.amount;
            --  p_billrep_tbl(p_billrep_tbl_idx).Successful_SubLines_Value := p_billrep_tbl(p_billrep_tbl_idx).Successful_SubLines_Value - bcl_rec.amount ;
              /*FOR ERROR REPORT*/
              p_billrep_err_tbl_idx := p_billrep_err_tbl_idx + 1;
              p_billrep_err_tbl(p_billrep_err_tbl_idx).Top_Line_id := bcl_rec.cle_id;
              p_billrep_err_tbl(p_billrep_err_tbl_idx).Lse_Id := bcl_rec.lse_id;
              p_billrep_err_tbl(p_billrep_err_tbl_idx).Sub_line_id := bsl_rec.cle_id ;
              p_billrep_err_tbl(p_billrep_err_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;

            END IF; -- l_bill_profile = G_SUM
          END IF;    -- bcl_rec.lse_id = 46
        END IF;     -- P_PRV <> 3

       FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Insert Failed IN ARFEEDER MAIN_CUR_EXCEPTION RAISED '||sqlerrm);
       l_reject_counter := l_reject_counter + 1;
       DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_AR_TRANSACTION');
       x_return_status   :=  OKC_API.G_RET_STS_ERROR;
     WHEN  OTHERS THEN

        /*FOR BILLING REPORT*/
        --This is done to retrieve the profile value
        --because the error can occur before the profile option
        --is retrieved in the main logic
         IF (bcl_rec.lse_id = 12) THEN
            l_bill_profile := G_DET;
          ELSE
            IF (l_hdr_summary_flag = 'Y') THEN --Summary flag set in contract
              l_bill_profile := G_SUM;
            ELSE  -- read profile value
              l_bill_profile_flag := FND_PROFILE.VALUE('OKS_AR_TRANSACTIONS_SUBMIT_SUMMARY_YN');
              IF (l_bill_profile_flag = 'YES') THEN
                l_bill_profile := G_SUM;
              ELSE
                l_bill_profile := G_DET;
              END IF;
            END IF;
          END IF;

        IF (P_PRV <> 3) THEN
          IF (bcl_rec.lse_id = 46 ) THEN
              l_line_failed := TRUE;
            /*increment rejected for subscription*/
              p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines_Value:= p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines_Value + bcl_rec.amount;
            /*decrement successful for subscription*/
          --  p_billrep_tbl(p_billrep_tbl_idx).Successful_Lines_Value:= p_billrep_tbl(p_billrep_tbl_idx).Successful_Lines_Value - bcl_rec.amount ;
           /*FOR ERROR REPORT*/
              p_billrep_err_tbl_idx := p_billrep_err_tbl_idx + 1;
              p_billrep_err_tbl(p_billrep_err_tbl_idx).Top_Line_id := bcl_rec.cle_id;
              p_billrep_err_tbl(p_billrep_err_tbl_idx).Lse_Id := 46;
              p_billrep_err_tbl(p_billrep_err_tbl_idx).Sub_line_id := NULL;
              p_billrep_err_tbl(p_billrep_err_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;
          ELSE
            IF (l_bill_profile = G_SUM) THEN
                 l_line_failed := TRUE;
                 p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines_Value:= p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines_Value + bcl_rec.amount;
              --  p_billrep_tbl(p_billrep_tbl_idx).Successful_Lines_Value:= p_billrep_tbl(p_billrep_tbl_idx).Successful_Lines_Value - bcl_rec.amount ;
              /*FOR ERROR REPORT*/
                 p_billrep_err_tbl_idx := p_billrep_err_tbl_idx + 1;
                 p_billrep_err_tbl(p_billrep_err_tbl_idx).Top_Line_id := bcl_rec.cle_id;
                 p_billrep_err_tbl(p_billrep_err_tbl_idx).Lse_Id :=bcl_rec.lse_id;
                 p_billrep_err_tbl(p_billrep_err_tbl_idx).Sub_line_id := NULL;
                 p_billrep_err_tbl(p_billrep_err_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;
            ELSE
                 l_subline_failed := TRUE;
                 p_billrep_tbl(p_billrep_tbl_idx).Rejected_SubLines_Value := p_billrep_tbl(p_billrep_tbl_idx).Rejected_SubLines_Value + bcl_rec.amount;
              --  p_billrep_tbl(p_billrep_tbl_idx).Successful_SubLines_Value := p_billrep_tbl(p_billrep_tbl_idx).Successful_SubLines_Value - bcl_rec.amount ;
              /*FOR ERROR REPORT*/
                 p_billrep_err_tbl_idx := p_billrep_err_tbl_idx + 1;
                 p_billrep_err_tbl(p_billrep_err_tbl_idx).Top_Line_id := bcl_rec.cle_id;
                 p_billrep_err_tbl(p_billrep_err_tbl_idx).Lse_Id := bcl_rec.lse_id;
                 p_billrep_err_tbl(p_billrep_err_tbl_idx).Sub_line_id := bsl_rec.cle_id ;
                 p_billrep_err_tbl(p_billrep_err_tbl_idx).Error_Message := 'Error: '|| sqlerrm||'. Error Message: '||l_msg_data ;
            END IF; -- l_bill_profile = G_SUM
          END IF;  -- bcl_rec.lse_id = 46
        END IF;     -- P_PRV <> 3

       x_return_status   :=  OKC_API.G_RET_STS_ERROR;
       FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Insert Failed IN ARFEEDER OTHERS EXCEPTION RAISED'||sqlerrm);
       l_reject_counter := l_reject_counter + 1;
       DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_AR_TRANSACTION');

    END;

  IF (p_prv <> 3 and nvl(report_bill_action,'RI') <> 'AV') THEN
    --For successful Processing
    IF (l_bill_profile = G_SUM) THEN
      IF NOT l_line_failed  THEN
        p_billrep_tbl(p_billrep_tbl_idx).Successful_Lines_Value:= p_billrep_tbl(p_billrep_tbl_idx).Successful_Lines_Value + nvl(bcl_rec.amount,0);
      END IF;
    ELSE
      IF NOT l_subline_failed  THEN
        p_billrep_tbl(p_billrep_tbl_idx).Successful_SubLines_Value:= p_billrep_tbl(p_billrep_tbl_idx).Successful_SubLines_Value + nvl(bcl_rec.amount,0);
      END IF;
    END IF;
  END IF;

  END LOOP; -- BCL_CUR Loop

  IF (p_prv = 1) THEN
    CLOSE cur_bcl;
  ELSIF (p_prv = 2) THEN
    CLOSE cur_bcl_pr;
  ELSIF ( p_prv = 3) THEN
    CLOSE cur_bcl_term;
  END IF;

  /*FOR BILLING REPORT*/
  --For error Processing
  IF (l_line_failed) THEN
    p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines:= p_billrep_tbl(p_billrep_tbl_idx).Rejected_Lines +1;
  --  p_billrep_tbl(p_billrep_tbl_idx).Successful_Lines:= p_billrep_tbl(p_billrep_tbl_idx).Successful_Lines - 1;
  END IF;

  IF (l_subline_failed) THEN
    select count(id) into l_subline_count from oks_bill_sub_lines where bcl_id = Bcl_rec.id;
    p_billrep_tbl(p_billrep_tbl_idx).Rejected_SubLines:= p_billrep_tbl(p_billrep_tbl_idx).Rejected_SubLines +l_subline_count;
   -- p_billrep_tbl(p_billrep_tbl_idx).Successful_SubLines:= p_billrep_tbl(p_billrep_tbl_idx).Successful_SubLines - l_subline_count;
  END IF;

  IF (p_prv <> 3 and nvl(report_bill_action,'RI') <> 'AV') THEN
    --For successful Processing
    IF (l_bill_profile = G_SUM) THEN
      IF NOT l_line_failed  THEN
        p_billrep_tbl(p_billrep_tbl_idx).Successful_Lines:= p_billrep_tbl(p_billrep_tbl_idx).Successful_Lines +1;
      END IF;
    ELSE
      IF NOT l_subline_failed  THEN
	   if p_prv = 1 then
             select count(id) into l_subline_count from oks_bill_sub_lines where bcl_id = Bcl_rec.id;
	   elsif p_prv = 2 then
             select count(id) into l_subline_count from oks_bsl_pr where bcl_id = Bcl_rec.id;
        end if;
        FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.debug report'||l_subline_count);

        p_billrep_tbl(p_billrep_tbl_idx).Successful_SubLines:= p_billrep_tbl(p_billrep_tbl_idx).Successful_SubLines +l_subline_count;
      END IF;
    END IF;
  END IF;


EXCEPTION
  WHEN  G_EXCEPTION_BILLING THEN
    --x_return_status   :=  OKC_API.G_RET_STS_ERROR;
    FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Insert Failed IN ARFEEDER G_BILLING_EXCEPTION RAISED '||sqlerrm);
    DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_AR_TRANSACTION');
  WHEN  OTHERS THEN
    --x_return_status   :=  OKC_API.G_RET_STS_ERROR;
    FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Get_REC_FEEDER => Insert Failed IN ARFEEDER WHEN OTHERS EXCEPTION RAISED'||sqlerrm);
    DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_AR_TRANSACTION');

End Get_REC_FEEDER;

Procedure Populate_TR_reference_fields(p_instance_number   IN   NUMBER,
                                       p_contract_number   IN   VARCHAR2,
                                       p_contract_modifier IN   VARCHAR2,
                                       x_return_status     OUT NOCOPY  VARCHAR2)

IS

Cursor l_reference_summ_csr is

  select interface_line_attribute4, interface_line_attribute5, interface_line_attribute6,
         interface_line_attribute7, interface_line_attribute8, interface_line_attribute9,
         interface_line_attribute10, conversion_date
  from ra_interface_lines_all
  WHERE interface_line_attribute1 = p_contract_number
  and   interface_line_attribute3 = to_char(p_instance_number);

l_reference_summ_rec        l_reference_summ_csr%ROWTYPE;

Begin

x_return_status  := 'S';

G_RAIL_REC.reference_line_context     :=  'OKS CONTRACTS';
G_RAIL_REC.reference_line_attribute1  :=  p_contract_number;
G_RAIL_REC.reference_line_attribute2  :=  NVL(p_contract_modifier,'-');
G_RAIL_REC.reference_line_attribute3  :=  p_instance_number;

OPEN l_reference_summ_csr;
FETCH l_reference_summ_csr INTO l_reference_summ_rec;

   G_RAIL_REC.reference_line_attribute4  :=  l_reference_summ_rec.interface_line_attribute4;
   G_RAIL_REC.reference_line_attribute5  :=  l_reference_summ_rec.interface_line_attribute5;
   G_RAIL_REC.reference_line_attribute6  :=  l_reference_summ_rec.interface_line_attribute6;
   G_RAIL_REC.reference_line_attribute7  :=  l_reference_summ_rec.interface_line_attribute7;
   G_RAIL_REC.reference_line_attribute8  :=  l_reference_summ_rec.interface_line_attribute8;
   G_RAIL_REC.reference_line_attribute9  :=  l_reference_summ_rec.interface_line_attribute9;
   G_RAIL_REC.reference_line_attribute10 :=  l_reference_summ_rec.interface_line_attribute10;
   /*cgopinee bugfix for 8361496*/
   G_RAIL_REC.conversion_date            :=  l_reference_summ_rec.conversion_date;

CLOSE l_reference_summ_csr;


EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'E';

END Populate_TR_reference_fields;


--mchoudha Fix for bug#4174921
--added parameter p_hdr_id
Procedure Set_Reference_PB_Value(
                           p_bsl_id         IN         NUMBER,
                           p_contract_no    IN         VARCHAR2,
                           p_contract_mod   IN         VARCHAR2,
                           p_bill_inst_no   IN         NUMBER,
                           p_amount         IN         NUMBER,
                           p_int_att10      IN         VARCHAR2,
                           p_bcl_cle_id     IN         NUMBER,
                           p_currency_code  IN         VARCHAR2,
                           p_hdr_id         IN         NUMBER,
                           x_msg_cnt        OUT NOCOPY NUMBER,
                           x_msg_data       OUT NOCOPY VARCHAR2,
                           x_return_status  OUT NOCOPY VARCHAR2
                           )
IS

Cursor l_pb_inv_csr IS
  SELECT pb.quantity_from,
         pb.unit_price,
         pb.amount,
         btl.bsl_id
  FROM   OKS_PRICE_BREAKS pb,
         oks_bill_txn_lines btl
  WHERE  pb.bsl_id = btl.bsl_id
   AND   btl.bill_instance_number = p_bill_inst_no
   AND   pb.amount > 0
  ORDER BY pb.quantity_from;

Cursor l_inv_csr(p_bsl_id IN NUMBER) IS
  SELECT quantity,
         unit_price,
         amount, quantity_from
  FROM   OKS_PRICE_BREAKS
  WHERE  bsl_id = p_bsl_id
  ORDER BY abs(amount);

l_pb_inv_rec    l_pb_inv_csr%ROWTYPE;
inv_rec         l_inv_csr%rowtype;

TYPE pb_Type  IS RECORD
(
  line_index    NUMBER,
  amount        NUMBER);



Type pb_tbl is TABLE of pb_Type index by binary_integer;

l_inv_pb_tbl           pb_tbl;
l_pb_i                 NUMBER;
l_check_amount         NUMBER;
l_unit_selling_price   NUMBER;
l_extended_amount      NUMBER;
l_term_amount          NUMBER;
l_inv_bsl_id           NUMBER;
l_constant_ri10        VARCHAR2(100);
l_int_att10            VARCHAR2(100);


BEGIN

x_return_status := 'S';

l_constant_ri10 := G_RAIL_REC.reference_line_attribute10;             ---REFERENCE FIELD
l_int_att10     := p_int_att10;


l_pb_i := 0;

IF SUBSTR(l_constant_ri10, -2,2) = 'PB' THEN          ----price brks to AR
  FOR l_pb_inv_REC IN l_pb_inv_csr
  LOOP

   l_pb_i := l_pb_i + 1;

   l_inv_pb_tbl(l_pb_inv_REC.quantity_from).amount       := l_pb_inv_REC.amount;
   l_inv_pb_tbl(l_pb_inv_REC.quantity_from).line_index   := l_pb_i;

   l_inv_bsl_id := l_pb_inv_rec.bsl_id;
  END LOOP;


 IF l_inv_pb_tbl.COUNT > 0  THEN
  l_pb_i := 0;
  l_check_amount := abs(p_amount);

  FOR inv_rec in l_inv_csr(l_inv_bsl_id)
  LOOP

    l_unit_selling_price := 0;

    l_extended_amount :=  inv_rec.amount ;
    l_unit_selling_price := inv_rec.unit_price;


    IF (l_extended_amount <= l_check_amount) THEN
      l_term_amount := l_extended_amount;
    ELSE
      l_term_amount := l_check_amount;
    END IF;

    l_pb_i                               := l_pb_i + 1;

    G_RAIL_REC.description               := 'PBT'||l_pb_i;
    G_RAIL_REC.quantity_ordered          := round(l_term_amount/l_unit_selling_price);
    G_RAIL_REC.quantity                  := round(l_term_amount/l_unit_selling_price);
    G_RAIL_REC.amount                    := -1 * l_term_amount;
    G_RAIL_REC.interface_line_attribute6 := -1 * l_term_amount;
    G_RAIL_REC.interface_line_attribute10:= l_int_att10||' for PB'||l_pb_i;


    G_RAIL_REC.reference_line_attribute6  :=  l_extended_amount;
    G_RAIL_REC.reference_line_attribute10 :=  l_constant_ri10 || l_inv_pb_tbl(inv_rec.quantity_from).line_index;


    Insert_ra_interface
       (
         x_return_status,
         x_msg_cnt,
         x_msg_data
        );

    IF (x_return_status <> 'S') THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Set_Reference_PB_Value => Insert into RA_Interface_Lines Failed while inserting price breaks ' );
      x_return_status := 'E';
    END IF; --IF (l_ret_stat <> 'S')


    INSERT_RA_REV_DIST( x_return_status,
                        p_bcl_cle_id);

    IF (x_return_status <> 'S') THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Set_Reference_PB_Value => Insert INTO RA_REVENUE_DISTRIBUTIONS failed for Price Break');

      x_return_status := 'E';
    END IF;

    --mchoudha Fix for bug#4174921
    --added parameter p_hdr_id
    Sales_credit(p_bcl_cle_id ,
                 p_hdr_id,
                 x_return_status);

    IF ( x_return_status <> 'S') THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Set_Reference_PB_Value => Insert INTO RA_SALES_CREDIT FAILED for Price Breaks');
    END IF;


    EXIT when x_return_status <> 'S';

    l_check_amount := l_check_amount - l_term_amount;

    IF (l_check_amount <= 0) THEN
      EXIT;
    END IF;
  END LOOP;
 END IF;                ---l_inv_pb_tbl COUNT CHK

ELSE                    ---PB not passed to AR
   Insert_ra_interface
       (
         x_return_status,
         x_msg_cnt,
         x_msg_data
        );

    IF (x_return_status <> 'S') THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Set_Reference_PB_Value => Insert into RA_Interface_Lines Failed while inserting price breaks ' );
      x_return_status := 'E';
    END IF;         --IF (l_ret_stat <> 'S')


    INSERT_RA_REV_DIST( x_return_status,
                        p_bcl_cle_id);

    IF (x_return_status <> 'S') THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Set_Reference_PB_Value => Insert INTO RA_REVENUE_DISTRIBUTIONS failed for Price Break');

      x_return_status := 'E';
    END IF;

    --mchoudha Fix for bug#4174921
    --added parameter p_hdr_id
    Sales_credit(p_bcl_cle_id ,
                 p_hdr_id,
                 x_return_status);

    IF ( x_return_status <> 'S') THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'OKS_ARFEEDER_PUB.Set_Reference_PB_Value => Insert INTO RA_SALES_CREDIT FAILED for Price Breaks');
    END IF;

END IF;


END Set_Reference_PB_Value;


End OKS_ARFEEDER_PUB;

/
