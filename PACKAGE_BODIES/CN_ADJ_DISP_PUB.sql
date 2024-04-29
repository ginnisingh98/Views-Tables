--------------------------------------------------------
--  DDL for Package Body CN_ADJ_DISP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_ADJ_DISP_PUB" AS
--$Header: cnpadjb.pls 120.2 2005/09/26 07:36:03 chanthon noship $

  G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_ADJ_DISP_PUB';
  G_FILE_NAME                 CONSTANT VARCHAR2(12) := 'cnpadjb.pls';
  G_LAST_UPDATE_DATE          DATE    := sysdate;
  G_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
  G_CREATION_DATE             DATE    := sysdate;
  G_CREATED_BY                NUMBER  := fnd_global.user_id;
  G_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;


  PROCEDURE get_adj
    (
     p_api_version            IN  NUMBER,
     p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
     p_validation_level       IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
     x_return_status          OUT NOCOPY VARCHAR2,
     x_msg_count              OUT NOCOPY NUMBER,
     x_msg_data               OUT NOCOPY VARCHAR2,
     x_loading_status         OUT NOCOPY VARCHAR2,
     p_salesrep_id            IN NUMBER ,
     p_pr_date_from           IN DATE ,
     p_pr_date_to             IN DATE ,
     p_invoice_num            IN VARCHAR2,
     p_order_num              IN NUMBER,
     p_calc_status            IN VARCHAR2,
     p_adjust_status          IN VARCHAR2,
     p_adjust_date            IN DATE,
     p_trx_type               IN VARCHAR2,
     p_date_pattern           IN DATE,
     p_start_record           IN  NUMBER := 1,
     p_increment_count        IN  NUMBER,
     p_curr_code              IN  VARCHAR2,
     x_adj_tbl                OUT NOCOPY  adj_tbl_type,
     x_adj_count              OUT NOCOPY NUMBER,
     x_total_sales_credit     OUT NOCOPY NUMBER,
     x_total_commission       OUT NOCOPY NUMBER,
     x_conv_status            OUT NOCOPY VARCHAR2
    )


    IS

     l_api_name		  CONSTANT VARCHAR2(30) := 'get_adj';
     l_api_version        CONSTANT NUMBER := 1.0;
     l_flag               NUMBER  := 0;
     l_column_value       NUMBER;
     l_pr_date_from       DATE  ;
     l_pr_date_to         DATE  ;
     l_adjust_date        DATE  ;
     l_customer_name      VARCHAR2(50);
     l_customer_number    VARCHAR2(30);
     l_quota_name         VARCHAR2(80);
     l_revenue_class_name VARCHAR2(30);
     l_credit_type_id     NUMBER;
     l_temp_sts           VARCHAR2(30);
     l_conv_sc            NUMBER;
     l_conv_ca            NUMBER;

     adj  adj_rec_type;

     --Added l_func_curr to get functional currency to pass it to CN_API
     l_func_curr varchar2(8);
     --Added l_org_id as this procedure does not have org_id as I/P param
     l_org_id Number := mo_global.get_current_org_id();

     TYPE rc IS ref cursor;
     query_cur         rc;

     -- get credit type ID from the quota_id
     cursor get_credit_type_id (l_quota_id in number) is
	select nvl(credit_type_id, -1000)
	  from cn_quotas
	 where quota_id = l_quota_id;

     query   VARCHAR2(20000) := '
      SELECT
        ctrx.invoice_number 	       invoice_number,
        ctrx.invoice_date	       invoice_date,
        ctrx.order_number 	       order_number,
        ctrx.booked_date 	       order_date,
        ctrx.creation_date             creation_date,
        ctrx.processed_date            processed_date,
        ctrx.trx_type_disp	       trx_type_disp,
        ctrx.adjust_status_disp        adjust_status_disp,
        ctrx.adjusted_by               adjusted_by,
        ctrx.adjust_date               adjust_date,
        ctrx.status_disp               calc_status_disp,
        ctrx.orig_currency_code        currency_code,
        ctrx.transaction_amount        sales_credit,
        ctrx.commission_amount         commission,
        ctrx.attribute1                attribute1,
        ctrx.attribute2                attribute2,
	ctrx.attribute3                attribute3,
	ctrx.attribute4                attribute4,
	ctrx.attribute5                attribute5,
	ctrx.attribute6                attribute6,
	ctrx.attribute7                attribute7,
	ctrx.attribute8                attribute8,
	ctrx.attribute9                attribute9,
	ctrx.attribute10               attribute10,
	ctrx.attribute11               attribute11,
	ctrx.attribute12               attribute12,
	ctrx.attribute13               attribute13,
	ctrx.attribute14               attribute14,
	ctrx.attribute15               attribute15,
	ctrx.attribute16               attribute16,
	ctrx.attribute17               attribute17,
	ctrx.attribute18               attribute18,
	ctrx.attribute19               attribute19,
	ctrx.attribute20               attribute20,
	ctrx.attribute21               attribute21,
	ctrx.attribute22               attribute22,
	ctrx.attribute23               attribute23,
	ctrx.attribute24               attribute24,
	ctrx.attribute25               attribute25,
	ctrx.attribute26               attribute26,
	ctrx.attribute27               attribute27,
	ctrx.attribute28               attribute28,
	ctrx.attribute29               attribute29,
	ctrx.attribute30               attribute30,
	ctrx.attribute31               attribute31,
	ctrx.attribute32               attribute32,
	ctrx.attribute33               attribute33,
	ctrx.attribute34               attribute34,
	ctrx.attribute35               attribute35,
	ctrx.attribute36               attribute36,
	ctrx.attribute37               attribute37,
	ctrx.attribute38               attribute38,
	ctrx.attribute39               attribute39,
	ctrx.attribute40               attribute40,
	ctrx.attribute41               attribute41,
	ctrx.attribute42               attribute42,
	ctrx.attribute43               attribute43,
	ctrx.attribute44               attribute44,
	ctrx.attribute45               attribute45,
	ctrx.attribute46               attribute46,
	ctrx.attribute47               attribute47,
	ctrx.attribute48               attribute48,
	ctrx.attribute49               attribute49,
	ctrx.attribute50               attribute50,
	ctrx.attribute51               attribute51,
	ctrx.attribute52               attribute52,
	ctrx.attribute53               attribute53,
	ctrx.attribute54               attribute54,
	ctrx.attribute55               attribute55,
	ctrx.attribute56               attribute56,
	ctrx.attribute57               attribute57,
	ctrx.attribute58               attribute58,
	ctrx.attribute59               attribute59,
	ctrx.attribute60               attribute60,
	ctrx.attribute61               attribute61,
	ctrx.attribute62               attribute62,
	ctrx.attribute63               attribute63,
	ctrx.attribute64               attribute64,
	ctrx.attribute65               attribute65,
	ctrx.attribute66               attribute66,
	ctrx.attribute67               attribute67,
	ctrx.attribute68               attribute68,
	ctrx.attribute69               attribute69,
	ctrx.attribute70               attribute70,
	ctrx.attribute71               attribute71,
	ctrx.attribute72               attribute72,
	ctrx.attribute73               attribute73,
	ctrx.attribute74               attribute74,
	ctrx.attribute75               attribute75,
	ctrx.attribute76               attribute76,
	ctrx.attribute77               attribute77,
	ctrx.attribute78               attribute78,
	ctrx.attribute79               attribute79,
	ctrx.attribute80               attribute80,
	ctrx.attribute81               attribute81,
	ctrx.attribute82               attribute82,
	ctrx.attribute83               attribute83,
	ctrx.attribute84               attribute84,
	ctrx.attribute85               attribute85,
	ctrx.attribute86               attribute86,
	ctrx.attribute87               attribute87,
	ctrx.attribute88               attribute88,
	ctrx.attribute89               attribute89,
	ctrx.attribute90               attribute90,
	ctrx.attribute91               attribute91,
	ctrx.attribute92               attribute92,
	ctrx.attribute93               attribute93,
	ctrx.attribute94               attribute94,
	ctrx.attribute95               attribute95,
	ctrx.attribute96               attribute96,
	ctrx.attribute97               attribute97,
	ctrx.attribute98               attribute98,
	ctrx.attribute99               attribute99,
	ctrx.attribute100              attribute100,
        ctrx.customer_id	       customer_id,
        NULL                           customer_name,
        NULL                           customer_number,
        ctrx.bill_to_address_id	       bill_to_address_id,
        ctrx.ship_to_address_id	       ship_to_address_id,
        ctrx.bill_to_contact_id	       bill_to_contact_id,
        ctrx.ship_to_contact_id	       ship_to_contact_id,
        ctrx.rollup_date	       rollup_date,
        ctrx.comments		       comments,
        ctrx.reason_code	       reason_code,
        ctrx.reason                    reason,
        ctrx.quota_id		       quota_id,
        NULL                           quota_name,
        ctrx.revenue_class_id	       revenue_class_id,
        NULL                           revenue_class_name

     FROM
       cn_trx_details 	       ctrx';


  BEGIN

   --+
   --+ Standard call to check for call compatibility.
   --+
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name,
                                        G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --+
   --+ Initialize message list if p_init_msg_list is set to TRUE.
   --+
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --+
   --+  Initialize API return status to success
   --+
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_INSERTED';

   --+
   --+ API body
   --+


    x_adj_count          := 0;
    x_total_sales_credit := 0;
    x_total_commission   := 0;

    IF (p_date_pattern IS NOT NULL) THEN
      IF (p_adjust_date <> p_date_pattern)  THEN
        l_adjust_date := p_adjust_date;
      END IF;
      IF (p_pr_date_from <> p_date_pattern) THEN
        l_pr_date_from := p_pr_date_from;
      END IF;
      IF (p_pr_date_to <> p_date_pattern) THEN
        l_pr_date_to := p_pr_date_to;
      END IF;
    END IF;

    --+    FOR adj IN adj_cur( p_salesrep_id,l_pr_date_from,l_pr_date_to,
    --+     p_invoice_num, p_order_num, p_calc_status, p_adjust_status,
    --+     l_adjust_date, p_trx_type)

    query := query || ' WHERE ctrx.credited_salesrep_id = :1 ';

    IF (l_pr_date_from IS NOT NULL) THEN
       --query := query || ' and trunc(ctrx.processed_date) >= :2 ';
       query := query || ' and ctrx.processed_date >= trunc(:2) ';
     ELSE
       query := query || ' and :2 is null ';
    END IF;

    IF (l_pr_date_to IS NOT NULL) THEN
       --query := query || ' and trunc(ctrx.processed_date) <= :3 ';
       query := query || ' and ctrx.processed_date <= trunc(:3)+0.99999 ';
     ELSE
       query := query || ' and :3 is null ';
    END IF;

    IF (p_invoice_num <> 'ALL') THEN
       query := query || ' and ctrx.invoice_number = :4 ';
     ELSE
       query := query || ' and :4 = ''ALL''';
    END IF;

    IF (p_order_num <> -99999) THEN
       query := query || ' and ctrx.order_number = :5 ';
     ELSE
       query := query || ' and :5 = -99999';
    END IF;

    IF (p_calc_status <> 'ALL') THEN
       query := query || ' and ctrx.status = :6 ';
     ELSE
       query := query || ' and :6 = ''ALL''';
    END IF;

    IF (p_adjust_status <> 'ALL') THEN
       query := query || ' and ctrx.adjust_status = :7 ';
     ELSE
       query := query || ' and :7 = ''ALL''';
    END IF;

    IF (l_adjust_date IS NOT NULL) THEN
       query := query || ' and trunc(ctrx.adjust_date) = :8 ';
     ELSE
       query := query || ' and :8 is null ';
    END IF;

    IF (p_trx_type <> 'ALL') THEN
       query := query || ' and ctrx.trx_type = :9 ';
     ELSE
       query := query || ' and :9 = ''ALL''';
    END IF;

 /*
    dbms_output.put_line('p_salesrep_id'||p_salesrep_id);
    dbms_output.put_line('l_pr_date_from'||l_pr_date_from);
    dbms_output.put_line('l_pr_date_to'||l_pr_date_to);
    dbms_output.put_line('p_invoice_num'||p_invoice_num);
    dbms_output.put_line('p_order_num'||p_order_num);
    dbms_output.put_line('p_calc_status'||p_calc_status);
    dbms_output.put_line('p_adjust_status'||p_adjust_status);
    dbms_output.put_line('l_adjust_date'||l_adjust_date);
    dbms_output.put_line('p_trx_type'||p_trx_type);
*/

    OPEN query_cur FOR query
      using
       p_salesrep_id,   -- :1
       l_pr_date_from,  -- :2
       l_pr_date_to,    -- :3
       p_invoice_num,   -- :4
       p_order_num,     -- :5
       p_calc_status,   -- :6
       p_adjust_status, -- :7
       l_adjust_date,   -- :8
       p_trx_type;      -- :9

    LOOP

       FETCH query_cur INTO adj;
       exit when query_cur%notfound;

       --dbms_output.put_line('adj.sales_credit = ' || adj.sales_credit);
       --dbms_output.put_line('adj.commission = ' || adj.commission);

       x_adj_count := x_adj_count + 1;
       l_credit_type_id := -1000;
       open  get_credit_type_id(adj.quota_id);
       fetch get_credit_type_id into l_credit_type_id;
       close get_credit_type_id;

       /* cn_ytd_balances_pvt.Currency_Convert
	 (nvl(adj.sales_credit,0), l_credit_type_id, p_curr_code,
	  l_conv_sc, l_temp_sts);
       cn_ytd_balances_pvt.Currency_Convert
	 (nvl(adj.commission,0), l_credit_type_id, p_curr_code,
	  l_conv_ca, l_temp_sts); */

      select s.currency_code into l_func_curr
      from gl_sets_of_books s, cn_repositories r
      where r.set_of_books_id = s.set_of_books_id
      and r.application_id = 283 and r.org_id=l_org_id;
      l_conv_sc :=  cn_api.convert_to_repcurr(nvl(adj.sales_credit,0),
                                sysdate,
                                nvl(cn_system_parameters.value('CN_CONVERSION_TYPE',l_org_id),'Corporate'),
                                l_credit_type_id,
                                l_func_curr,
                                p_curr_code,
                                l_org_id
                                );
      l_conv_ca := cn_api.convert_to_repcurr(nvl(adj.commission,0),
                                sysdate,
                                nvl(cn_system_parameters.value('CN_CONVERSION_TYPE',l_org_id),'Corporate'),
                                l_credit_type_id,
                                l_func_curr,
                                p_curr_code,
                                l_org_id
                                );


       if (l_temp_sts <> 'SUCCESS' AND x_conv_status is null) then
	  x_conv_status := fnd_message.get_string('CN', l_temp_sts);
       end if;

       x_total_sales_credit := x_total_sales_credit + l_conv_sc;
       x_total_commission := x_total_commission + l_conv_ca;

       IF (( p_increment_count = -9999) OR
	   (x_adj_count  BETWEEN p_start_record
	    AND (p_start_record + p_increment_count -1)))
	 THEN
	x_adj_tbl(x_adj_count).invoice_number := adj.invoice_number;
	x_adj_tbl(x_adj_count).invoice_date := adj.invoice_date;
	x_adj_tbl(x_adj_count).order_number := adj.order_number;
	x_adj_tbl(x_adj_count).order_date := adj.order_date;
	x_adj_tbl(x_adj_count).creation_date := adj.creation_date;
	x_adj_tbl(x_adj_count).processed_date :=  adj.processed_date;
	x_adj_tbl(x_adj_count).trx_type_disp := adj.trx_type_disp;
	x_adj_tbl(x_adj_count).adjust_status_disp := adj.adjust_status_disp;
	x_adj_tbl(x_adj_count).adjusted_by := adj.adjusted_by;
	x_adj_tbl(x_adj_count).adjust_date := adj.adjust_date;
	x_adj_tbl(x_adj_count).calc_status_disp := adj.calc_status_disp;
	x_adj_tbl(x_adj_count).currency_code := adj.currency_code;
	x_adj_tbl(x_adj_count).sales_credit := l_conv_sc;
	x_adj_tbl(x_adj_count).commission := l_conv_ca;

	x_adj_tbl(x_adj_count).attribute1         :=
	  adj.attribute1;
	x_adj_tbl(x_adj_count).attribute2         :=
	  adj.attribute2;
	x_adj_tbl(x_adj_count).attribute3         :=
	  adj.attribute3;
	x_adj_tbl(x_adj_count).attribute4         :=
	  adj.attribute4;
	x_adj_tbl(x_adj_count).attribute5         :=
	  adj.attribute5;
	x_adj_tbl(x_adj_count).attribute6         :=
	  adj.attribute6;
	x_adj_tbl(x_adj_count).attribute7         :=
	  adj.attribute7;
	x_adj_tbl(x_adj_count).attribute8         :=
	  adj.attribute8;
	x_adj_tbl(x_adj_count).attribute9         :=
	  adj.attribute9;
	x_adj_tbl(x_adj_count).attribute10         :=
	  adj.attribute10;
	x_adj_tbl(x_adj_count).attribute11         :=
	  adj.attribute11;
	x_adj_tbl(x_adj_count).attribute12         :=
	  adj.attribute12;
	x_adj_tbl(x_adj_count).attribute13         :=
	  adj.attribute13;
	x_adj_tbl(x_adj_count).attribute14         :=
	  adj.attribute14;
	x_adj_tbl(x_adj_count).attribute15         :=
	  adj.attribute15;
	x_adj_tbl(x_adj_count).attribute16         :=
	  adj.attribute16;
	x_adj_tbl(x_adj_count).attribute17         :=
	  adj.attribute17;
	x_adj_tbl(x_adj_count).attribute18         :=
	  adj.attribute18;
	x_adj_tbl(x_adj_count).attribute19         :=
	  adj.attribute19;
	x_adj_tbl(x_adj_count).attribute20         :=
	  adj.attribute20;
	x_adj_tbl(x_adj_count).attribute21         :=
	  adj.attribute21;
	x_adj_tbl(x_adj_count).attribute22         :=
	  adj.attribute22;
	x_adj_tbl(x_adj_count).attribute23         :=
	  adj.attribute23;
	x_adj_tbl(x_adj_count).attribute24         :=
	  adj.attribute24;
	x_adj_tbl(x_adj_count).attribute25         :=
	  adj.attribute25;
	x_adj_tbl(x_adj_count).attribute26         :=
	  adj.attribute26;
	x_adj_tbl(x_adj_count).attribute27         :=
	  adj.attribute27;
	x_adj_tbl(x_adj_count).attribute28         :=
	  adj.attribute28;
	x_adj_tbl(x_adj_count).attribute29         :=
	  adj.attribute29;
	x_adj_tbl(x_adj_count).attribute30         :=
	  adj.attribute30;
	x_adj_tbl(x_adj_count).attribute31         :=
	  adj.attribute31;
	x_adj_tbl(x_adj_count).attribute32         :=
	  adj.attribute32;
	x_adj_tbl(x_adj_count).attribute33         :=
	  adj.attribute33;
	x_adj_tbl(x_adj_count).attribute34         :=
	  adj.attribute34;
	x_adj_tbl(x_adj_count).attribute35         :=
	  adj.attribute35;
	x_adj_tbl(x_adj_count).attribute36         :=
	  adj.attribute36;
	x_adj_tbl(x_adj_count).attribute37         :=
	  adj.attribute37;
	x_adj_tbl(x_adj_count).attribute38         :=
	  adj.attribute38;
	x_adj_tbl(x_adj_count).attribute39         :=
	  adj.attribute39;
	x_adj_tbl(x_adj_count).attribute40         :=
	  adj.attribute40;
	x_adj_tbl(x_adj_count).attribute41         :=
	  adj.attribute41;
	x_adj_tbl(x_adj_count).attribute42         :=
	  adj.attribute42;
	x_adj_tbl(x_adj_count).attribute43         :=
	  adj.attribute43;
	x_adj_tbl(x_adj_count).attribute44         :=
	  adj.attribute44;
	x_adj_tbl(x_adj_count).attribute45         :=
	  adj.attribute45;
	x_adj_tbl(x_adj_count).attribute46         :=
	  adj.attribute46;
	x_adj_tbl(x_adj_count).attribute47         :=
	  adj.attribute47;
	x_adj_tbl(x_adj_count).attribute48         :=
	  adj.attribute48;
	x_adj_tbl(x_adj_count).attribute49         :=
	  adj.attribute49;
	x_adj_tbl(x_adj_count).attribute50         :=
	  adj.attribute50;
	x_adj_tbl(x_adj_count).attribute51         :=
	  adj.attribute51;
	x_adj_tbl(x_adj_count).attribute52         :=
	  adj.attribute52;
	x_adj_tbl(x_adj_count).attribute53         :=
	  adj.attribute53;
	x_adj_tbl(x_adj_count).attribute54         :=
	  adj.attribute54;
	x_adj_tbl(x_adj_count).attribute55         :=
	  adj.attribute55;
	x_adj_tbl(x_adj_count).attribute56         :=
	  adj.attribute56;
	x_adj_tbl(x_adj_count).attribute57         :=
	  adj.attribute57;
	x_adj_tbl(x_adj_count).attribute58         :=
	  adj.attribute58;
	x_adj_tbl(x_adj_count).attribute59         :=
	  adj.attribute59;
	x_adj_tbl(x_adj_count).attribute60         :=
	  adj.attribute60;
	x_adj_tbl(x_adj_count).attribute61         :=
	  adj.attribute61;
	x_adj_tbl(x_adj_count).attribute62         :=
	  adj.attribute62;
	x_adj_tbl(x_adj_count).attribute63         :=
	  adj.attribute63;
	x_adj_tbl(x_adj_count).attribute64         :=
	  adj.attribute64;
	x_adj_tbl(x_adj_count).attribute65         :=
	  adj.attribute65;
	x_adj_tbl(x_adj_count).attribute66         :=
	  adj.attribute66;
	x_adj_tbl(x_adj_count).attribute67         :=
	  adj.attribute67;
	x_adj_tbl(x_adj_count).attribute68         :=
	  adj.attribute68;
	x_adj_tbl(x_adj_count).attribute69         :=
	  adj.attribute69;
	x_adj_tbl(x_adj_count).attribute70         :=
	  adj.attribute70;
	x_adj_tbl(x_adj_count).attribute71         :=
	  adj.attribute71;
	x_adj_tbl(x_adj_count).attribute72         :=
	  adj.attribute72;
	x_adj_tbl(x_adj_count).attribute73         :=
	  adj.attribute73;
	x_adj_tbl(x_adj_count).attribute74         :=
	  adj.attribute74;
	x_adj_tbl(x_adj_count).attribute75         :=
	  adj.attribute75;
	x_adj_tbl(x_adj_count).attribute76         :=
	  adj.attribute76;
	x_adj_tbl(x_adj_count).attribute77         :=
	  adj.attribute77;
	x_adj_tbl(x_adj_count).attribute78         :=
	  adj.attribute78;
	x_adj_tbl(x_adj_count).attribute79         :=
	  adj.attribute79;
	x_adj_tbl(x_adj_count).attribute80         :=
	  adj.attribute80;
	x_adj_tbl(x_adj_count).attribute81         :=
	  adj.attribute81;
	x_adj_tbl(x_adj_count).attribute82         :=
	  adj.attribute82;
	x_adj_tbl(x_adj_count).attribute83         :=
	  adj.attribute83;
	x_adj_tbl(x_adj_count).attribute84         :=
	  adj.attribute84;
	x_adj_tbl(x_adj_count).attribute85         :=
	  adj.attribute85;
	x_adj_tbl(x_adj_count).attribute86         :=
	  adj.attribute86;
	x_adj_tbl(x_adj_count).attribute87         :=
	  adj.attribute87;
	x_adj_tbl(x_adj_count).attribute88         :=
	  adj.attribute88;
	x_adj_tbl(x_adj_count).attribute89         :=
	  adj.attribute89;
	x_adj_tbl(x_adj_count).attribute90         :=
	  adj.attribute90;
	x_adj_tbl(x_adj_count).attribute91         :=
	  adj.attribute91;
	x_adj_tbl(x_adj_count).attribute92         :=
	  adj.attribute92;
	x_adj_tbl(x_adj_count).attribute93         :=
	  adj.attribute93;
	x_adj_tbl(x_adj_count).attribute94         :=
	  adj.attribute94;
	x_adj_tbl(x_adj_count).attribute95         :=
	  adj.attribute95;
	x_adj_tbl(x_adj_count).attribute96         :=
	  adj.attribute96;
	x_adj_tbl(x_adj_count).attribute97         :=
	  adj.attribute97;
	x_adj_tbl(x_adj_count).attribute98         :=
	  adj.attribute98;
	x_adj_tbl(x_adj_count).attribute99         :=
	  adj.attribute99;
	x_adj_tbl(x_adj_count).attribute100        :=
	  adj.attribute100;


        x_adj_tbl(x_adj_count).customer_id         := adj.customer_id;
	IF adj.customer_id IS NOT NULL THEN
	    BEGIN
	     SELECT substrb(PARTY.PARTY_NAME,1,50), CUST_ACCT.ACCOUNT_NUMBER
		 INTO l_customer_name, l_customer_number
	     FROM HZ_PARTIES PARTY, HZ_CUST_ACCOUNTS CUST_ACCT
	     WHERE CUST_ACCT.CUST_ACCOUNT_ID = adj.customer_id
	       AND CUST_ACCT.PARTY_ID = PARTY.PARTY_ID;
	       x_adj_tbl(x_adj_count).customer_name   := l_customer_name;
	       x_adj_tbl(x_adj_count).customer_number := l_customer_number;
	    EXCEPTION
	       WHEN NO_DATA_FOUND THEN
		  x_adj_tbl(x_adj_count).customer_name   := NULL;
		  x_adj_tbl(x_adj_count).customer_number := NULL;
	    END;
	 ELSE
		  x_adj_tbl(x_adj_count).customer_name   := NULL;
		  x_adj_tbl(x_adj_count).customer_number := NULL;
	END IF;

        x_adj_tbl(x_adj_count).bill_to_address_id  := adj.bill_to_address_id;
	x_adj_tbl(x_adj_count).ship_to_address_id  := adj.ship_to_address_id;
	x_adj_tbl(x_adj_count).bill_to_contact_id  := adj.bill_to_contact_id;
	x_adj_tbl(x_adj_count).ship_to_contact_id  := adj.ship_to_contact_id;
	x_adj_tbl(x_adj_count).rollup_date         := adj.rollup_date;
        x_adj_tbl(x_adj_count).comments            := adj.comments;
        x_adj_tbl(x_adj_count).reason_code         := adj.reason_code;
	x_adj_tbl(x_adj_count).reason              := adj.reason;

        x_adj_tbl(x_adj_count).quota_id		   := adj.quota_id;
	IF adj.quota_id IS NOT NULL THEN
	   BEGIN
	      SELECT name INTO l_quota_name
		FROM cn_quotas WHERE quota_id =  adj.quota_id;
	      x_adj_tbl(x_adj_count).quota_name := l_quota_name;
	   EXCEPTION
	      WHEN no_data_found THEN
		 x_adj_tbl(x_adj_count).quota_name := NULL;
	   END;
	 ELSE
		 x_adj_tbl(x_adj_count).quota_name := NULL;
	END IF;

	x_adj_tbl(x_adj_count).revenue_class_id	   := adj.revenue_class_id;
	IF adj.revenue_class_id IS NOT NULL THEN
	   BEGIN
	      SELECT name INTO l_revenue_class_name
		FROM cn_revenue_classes
		WHERE revenue_class_id = adj.revenue_class_id;
	      x_adj_tbl(x_adj_count).revenue_class_name :=
		l_revenue_class_name;
	   EXCEPTION
	      WHEN no_data_found THEN
		 x_adj_tbl(x_adj_count).revenue_class_name := NULL;
	   END;
	 ELSE
		 x_adj_tbl(x_adj_count).revenue_class_name := NULL;
	END IF;


      END IF;

    END LOOP;



  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
          (
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
           );
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_loading_status := 'UNEXPECTED_ERR';
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
          (
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE
           );
     WHEN OTHERS THEN
        x_loading_status := 'UNEXPECTED_ERR';
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
           FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
        END IF;
        FND_MSG_PUB.Count_And_Get
          (
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
           );

  END;
END cn_adj_disp_pub;

/
