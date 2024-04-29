--------------------------------------------------------
--  DDL for Package Body CN_UN_PROC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_UN_PROC_PUB" AS
--$Header: cnunprob.pls 115.10 2002/11/21 21:11:19 hlchen ship $

   G_PKG_NAME       	CONSTANT VARCHAR2(30) 	:= 'CN_UN_PROC_PUB';
   G_FILE_NAME          CONSTANT VARCHAR2(12) 	:= 'cnunprob.pls';
   G_LAST_UPDATE_DATE   DATE    		:= sysdate;
   G_LAST_UPDATED_BY    NUMBER  		:= fnd_global.user_id;
   G_CREATION_DATE      DATE    		:= sysdate;
   G_CREATED_BY         NUMBER  		:= fnd_global.user_id;
   G_LAST_UPDATE_LOGIN  NUMBER  		:= fnd_global.login_id;

PROCEDURE get_adj(
   p_api_version            IN  	NUMBER,
   p_init_msg_list          IN  	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level       IN  	VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
   x_return_status          OUT NOCOPY 	VARCHAR2,
   x_msg_count              OUT NOCOPY 	NUMBER,
   x_msg_data               OUT NOCOPY 	VARCHAR2,
   x_loading_status         OUT NOCOPY 	VARCHAR2,
   p_salesrep_id            IN 		NUMBER,
   p_pr_date_from           IN 		DATE,
   p_pr_date_to             IN 		DATE,
   p_invoice_num            IN 		VARCHAR2,
   p_order_num              IN 		NUMBER,
   p_adjust_status          IN 		VARCHAR2,
   p_adjust_date            IN 		DATE,
   p_trx_type               IN 		VARCHAR2,
   p_calc_status            IN 		VARCHAR2,
   p_load_status	    IN		VARCHAR2,
   p_date_pattern           IN 		DATE,
   p_start_record           IN  	NUMBER := 1,
   p_increment_count        IN  	NUMBER,
   x_adj_tbl                OUT NOCOPY 	adj_tbl_type,
   x_adj_count              OUT NOCOPY 	NUMBER,
   x_total_sales_credit     OUT NOCOPY 	NUMBER,
   x_total_commission       OUT NOCOPY 	NUMBER) IS

   l_api_name		CONSTANT VARCHAR2(30) 	:= 'get_adj';
   l_api_version      	CONSTANT NUMBER 	:= 1.0;
   l_flag             	NUMBER  		:= 0;
   l_column_value     	NUMBER;
   l_pr_date_from     	DATE;
   l_pr_date_to       	DATE;
   l_adjust_date      	DATE;

   adj                cn_un_proc_pub.unproc_rec_type;

   TYPE rc IS ref cursor;
   query_cur         rc;

   query   		VARCHAR2(10000);
   l_select		VARCHAR2(10000);
   l_from		VARCHAR2(10000);
   l_where		VARCHAR2(10000);
   l_insert		VARCHAR2(10000);

BEGIN
   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call(
		l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_INSERTED';
   --
   -- API body
   --
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

   /* Trying to contruct a cursor based on P_LOAD_STATUS Flag
      If the P_LOAD_STATUS is 'Unloaded' get the data from
      cn_comm_lines_api table. Otherwise get the data from
      cn_commission_headers table. */

   IF (p_load_status = 'Unloaded') THEN
      l_select := '
         SELECT CTRX.invoice_number	invoice_number,
     	        CTRX.invoice_date       invoice_date,
       	        CTRX.order_number       order_number,
       	        CTRX.booked_date        order_date,
	        CTRX.creation_date      creation_date,
 	        CTRX.processed_date     processed_date,
       	 	CL1.meaning             trx_type_disp,
       	 	CL2.meaning             adjust_status_disp,
       		CTRX.adjusted_by        adjusted_by,
		CTRX.load_status        load_status,
		''''		        calc_status_disp,
       		CTRX.transaction_amount sales_credit,
       		CTRX.commission_amount  commission,
                CTRX.adjust_date        adjust_date, ';
   ELSE
      l_select := '
         SELECT ctrx.invoice_number     invoice_number,
        	ctrx.invoice_date       invoice_date,
        	ctrx.order_number       order_number,
	        ctrx.booked_date        order_date,
	        ctrx.creation_date      creation_date,
        	ctrx.processed_date     processed_date,
        	clt.meaning		trx_type_disp,
        	clad.meaning		adjust_status_disp,
        	ctrx.adjusted_by        adjusted_by,
		''''			load_status,
        	cls.meaning		calc_status_disp,
        	ctrx.transaction_amount sales_credit,
        	ctrx.commission_amount  commission,
        	ctrx.adjust_date        adjust_date, ';
   END IF;
   l_select := l_select||'
       	       ctrx.attribute1,ctrx.attribute2,ctrx.attribute3,
     	       ctrx.attribute4, ctrx.attribute5, ctrx.attribute6,
     	       ctrx.attribute7, ctrx.attribute8, ctrx.attribute9,
     	       ctrx.attribute10, ctrx.attribute11, ctrx.attribute12,
     	       ctrx.attribute13, ctrx.attribute14, ctrx.attribute15,
     	       ctrx.attribute16, ctrx.attribute17, ctrx.attribute18,
     	       ctrx.attribute19, ctrx.attribute20, ctrx.attribute21,
     	       ctrx.attribute22, ctrx.attribute23, ctrx.attribute24,
     	       ctrx.attribute25, ctrx.attribute26, ctrx.attribute27,
     	       ctrx.attribute28, ctrx.attribute29, ctrx.attribute30,
     	       ctrx.attribute31, ctrx.attribute32, ctrx.attribute33,
     	       ctrx.attribute34, ctrx.attribute35, ctrx.attribute36,
     	       ctrx.attribute37, ctrx.attribute38, ctrx.attribute39,
     	       ctrx.attribute40, ctrx.attribute41, ctrx.attribute42,
     	       ctrx.attribute43, ctrx.attribute44, ctrx.attribute45,
     	       ctrx.attribute46, ctrx.attribute47, ctrx.attribute48,
     	       ctrx.attribute49, ctrx.attribute50, ctrx.attribute51,
     	       ctrx.attribute52, ctrx.attribute53, ctrx.attribute54,
     	       ctrx.attribute55, ctrx.attribute56, ctrx.attribute57,
     	       ctrx.attribute58, ctrx.attribute59, ctrx.attribute60,
     	       ctrx.attribute61, ctrx.attribute62, ctrx.attribute63,
     	       ctrx.attribute64, ctrx.attribute65, ctrx.attribute66,
     	       ctrx.attribute67, ctrx.attribute68, ctrx.attribute69,
     	       ctrx.attribute70, ctrx.attribute71, ctrx.attribute72,
     	       ctrx.attribute73, ctrx.attribute74, ctrx.attribute75,
     	       ctrx.attribute76, ctrx.attribute77, ctrx.attribute78,
     	       ctrx.attribute79, ctrx.attribute80, ctrx.attribute81,
     	       ctrx.attribute82, ctrx.attribute83, ctrx.attribute84,
     	       ctrx.attribute85, ctrx.attribute86, ctrx.attribute87,
     	       ctrx.attribute88, ctrx.attribute89, ctrx.attribute90,
     	       ctrx.attribute91, ctrx.attribute92, ctrx.attribute93,
     	       ctrx.attribute94, ctrx.attribute95, ctrx.attribute96,
     	       ctrx.attribute97, ctrx.attribute98, ctrx.attribute99,
     	       ctrx.attribute100 ';
   --
   IF (p_load_status = 'Unloaded') THEN
      l_from := '
	 FROM cn_comm_lines_api  ctrx,
       	      cn_lookups         cl1,
       	      cn_lookups         cl2 ';
   ELSE
      l_from := '
	 FROM cn_commission_headers   ctrx,
	      cn_lookups clt,
	      cn_lookups cls,
	      cn_lookups clad ';

   END IF;
   --
   IF (p_load_status = 'Unloaded') THEN
      l_where := '
         WHERE ctrx.trx_type     = cl1.lookup_code(+)
           AND cl1.lookup_type(+) = ''TRX TYPES''
           AND ctrx.adjust_status = cl2.lookup_code(+)
           AND cl2.lookup_type(+) = ''ADJUST_STATUS''
	   AND ctrx.load_status <> ''LOADED''
	   AND ctrx.salesrep_id = :1 ';
   ELSE
      l_where := '
         WHERE ctrx.trx_type = clt.lookup_code(+)
	   AND clt.lookup_type (+)= ''TRX TYPES''
	   AND ctrx.status = cls.lookup_code(+)
	   AND cls.lookup_type (+)= ''TRX_STATUS''
	   AND ctrx.adjust_status = clad.lookup_code (+)
	   AND clad.lookup_type (+)= ''ADJUST_STATUS''
	   AND ctrx.direct_salesrep_id = :1 ';
   END IF;
   --
   IF (l_pr_date_from IS NOT NULL) THEN
      l_where := l_where || ' and ctrx.processed_date >= :2 ';
   ELSE
      l_where := l_where || ' and :2 is null ';
   END IF;
   --
   IF (l_pr_date_to IS NOT NULL) THEN
      l_where := l_where || ' and ctrx.processed_date <= :3 ';
   ELSE
      l_where := l_where || ' and :3 is null ';
   END IF;
   --
   IF (p_invoice_num <> 'ALL') THEN
      l_where := l_where || ' and ctrx.invoice_number = :4 ';
   ELSE
      l_where := l_where || ' and :4 = ''ALL''';
   END IF;
   --
   IF (p_order_num <> -99999) THEN
      l_where := l_where || ' and ctrx.order_number = :5 ';
   ELSE
      l_where := l_where || ' and :5 = -99999';
   END IF;
   --
   IF (p_adjust_status <> 'ALL') THEN
      l_where := l_where || ' and ctrx.adjust_status = :6 ';
   ELSE
      l_where := l_where || ' and :6 = ''ALL''';
   END IF;
   --
   IF (l_adjust_date IS NOT NULL) THEN
      l_where := l_where || ' and trunc(ctrx.adjust_date) = trunc(:7) ';
   ELSE
      l_where := l_where || ' and :7 is null ';
   END IF;
   --
   IF (p_trx_type <> 'ALL') THEN
      l_where := l_where || ' and ctrx.trx_type = :8 ';
   ELSE
      l_where := l_where || ' and :8 = ''ALL''';
   END IF;
   --
   IF (p_load_status = 'Loaded') THEN
      IF (p_calc_status <> 'ALL') THEN
         l_where := l_where || ' and ctrx.status = :9 ';
      ELSE
         l_where := l_where || ' and :9 = ''ALL''';
      END IF;
   END IF;
   --
   query := l_select||' '||l_from||' '||l_where;
   --
   IF (p_load_status = 'Unloaded') THEN
      OPEN query_cur FOR query USING
	 p_salesrep_id,   -- :1
         trunc(l_pr_date_from),      -- :2
         trunc(l_pr_date_to)+.99999, -- :3
         p_invoice_num,   -- :4
         p_order_num,     -- :5
         p_adjust_status, -- :6
         l_adjust_date,   -- :7
         p_trx_type;      -- :8
   ELSE
      OPEN query_cur FOR query USING
	 p_salesrep_id,   -- :1
         trunc(l_pr_date_from),      -- :2
         trunc(l_pr_date_to)+.99999, -- :3
         p_invoice_num,   -- :4
         p_order_num,     -- :5
         p_adjust_status, -- :6
         l_adjust_date,   -- :7
         p_trx_type,	  -- :8
         p_calc_status;   -- :9
   END IF;
   LOOP
   FETCH query_cur INTO adj;
   EXIT WHEN query_cur%NOTFOUND;
   x_adj_count := x_adj_count + 1;
   x_total_sales_credit := x_total_sales_credit + Nvl(adj.sales_credit,0);
   x_total_commission := x_total_commission + Nvl(adj.commission,0);

   IF (( p_increment_count = -9999) OR
       (x_adj_count  BETWEEN p_start_record AND
       (p_start_record + p_increment_count -1))) THEN
      x_adj_tbl(x_adj_count).invoice_number 		:= adj.invoice_number;
      x_adj_tbl(x_adj_count).invoice_date 		:= adj.invoice_date;
      x_adj_tbl(x_adj_count).order_number 		:= adj.order_number;
      x_adj_tbl(x_adj_count).order_date 		:= adj.order_date;
      x_adj_tbl(x_adj_count).creation_date              := adj.creation_date;
      x_adj_tbl(x_adj_count).processed_date 		:= adj.processed_date;
      x_adj_tbl(x_adj_count).trx_type_disp 		:= adj.trx_type_disp;
      x_adj_tbl(x_adj_count).adjust_status_disp 	:= adj.adjust_status_disp;
      x_adj_tbl(x_adj_count).adjusted_by 		:= adj.adjusted_by;
      x_adj_tbl(x_adj_count).sales_credit 		:= Nvl(adj.sales_credit,0);
      x_adj_tbl(x_adj_count).commission 		:= Nvl(adj.commission,0);
      x_adj_tbl(x_adj_count).adjust_date 		:= adj.adjust_date;
      x_adj_tbl(x_adj_count).attribute1         	:= adj.attribute1;
      x_adj_tbl(x_adj_count).attribute2           	:= adj.attribute2;
      x_adj_tbl(x_adj_count).attribute3           	:= adj.attribute3;
      x_adj_tbl(x_adj_count).attribute4           	:= adj.attribute4;
      x_adj_tbl(x_adj_count).attribute5           	:= adj.attribute5;
      x_adj_tbl(x_adj_count).attribute6           	:= adj.attribute6;
      x_adj_tbl(x_adj_count).attribute7           	:= adj.attribute7;
      x_adj_tbl(x_adj_count).attribute8           	:= adj.attribute8;
      x_adj_tbl(x_adj_count).attribute9           	:= adj.attribute9;
      x_adj_tbl(x_adj_count).attribute10          	:= adj.attribute10;
      x_adj_tbl(x_adj_count).attribute11          	:= adj.attribute11;
      x_adj_tbl(x_adj_count).attribute12          	:= adj.attribute12;
      x_adj_tbl(x_adj_count).attribute13          	:= adj.attribute13;
      x_adj_tbl(x_adj_count).attribute14          	:= adj.attribute14;
      x_adj_tbl(x_adj_count).attribute15          	:= adj.attribute15;
      x_adj_tbl(x_adj_count).attribute16          	:= adj.attribute16;
      x_adj_tbl(x_adj_count).attribute17          	:= adj.attribute17;
      x_adj_tbl(x_adj_count).attribute18          	:= adj.attribute18;
      x_adj_tbl(x_adj_count).attribute19          	:= adj.attribute19;
      x_adj_tbl(x_adj_count).attribute20          	:= adj.attribute20;
      x_adj_tbl(x_adj_count).attribute21          	:= adj.attribute21;
      x_adj_tbl(x_adj_count).attribute22          	:= adj.attribute22;
      x_adj_tbl(x_adj_count).attribute23          	:= adj.attribute23;
      x_adj_tbl(x_adj_count).attribute24          	:= adj.attribute24;
      x_adj_tbl(x_adj_count).attribute25          	:= adj.attribute25;
      x_adj_tbl(x_adj_count).attribute26          	:= adj.attribute26;
      x_adj_tbl(x_adj_count).attribute27          	:= adj.attribute27;
      x_adj_tbl(x_adj_count).attribute28          	:= adj.attribute28;
      x_adj_tbl(x_adj_count).attribute29          	:= adj.attribute29;
      x_adj_tbl(x_adj_count).attribute30          	:= adj.attribute30;
      x_adj_tbl(x_adj_count).attribute31          	:= adj.attribute31;
      x_adj_tbl(x_adj_count).attribute32          	:= adj.attribute32;
      x_adj_tbl(x_adj_count).attribute33          	:= adj.attribute33;
      x_adj_tbl(x_adj_count).attribute34          	:= adj.attribute34;
      x_adj_tbl(x_adj_count).attribute35          	:= adj.attribute35;
      x_adj_tbl(x_adj_count).attribute36          	:= adj.attribute36;
      x_adj_tbl(x_adj_count).attribute37          	:= adj.attribute37;
      x_adj_tbl(x_adj_count).attribute38          	:= adj.attribute38;
      x_adj_tbl(x_adj_count).attribute39          	:= adj.attribute39;
      x_adj_tbl(x_adj_count).attribute40          	:= adj.attribute40;
      x_adj_tbl(x_adj_count).attribute41          	:= adj.attribute41;
      x_adj_tbl(x_adj_count).attribute42          	:= adj.attribute42;
      x_adj_tbl(x_adj_count).attribute43          	:= adj.attribute43;
      x_adj_tbl(x_adj_count).attribute44          	:= adj.attribute44;
      x_adj_tbl(x_adj_count).attribute45          	:= adj.attribute45;
      x_adj_tbl(x_adj_count).attribute46          	:= adj.attribute46;
      x_adj_tbl(x_adj_count).attribute47          	:= adj.attribute47;
      x_adj_tbl(x_adj_count).attribute48          	:= adj.attribute48;
      x_adj_tbl(x_adj_count).attribute49          	:= adj.attribute49;
      x_adj_tbl(x_adj_count).attribute50          	:= adj.attribute50;
      x_adj_tbl(x_adj_count).attribute51          	:= adj.attribute51;
      x_adj_tbl(x_adj_count).attribute52          	:= adj.attribute52;
      x_adj_tbl(x_adj_count).attribute53          	:= adj.attribute53;
      x_adj_tbl(x_adj_count).attribute54          	:= adj.attribute54;
      x_adj_tbl(x_adj_count).attribute55          	:= adj.attribute55;
      x_adj_tbl(x_adj_count).attribute56          	:= adj.attribute56;
      x_adj_tbl(x_adj_count).attribute57          	:= adj.attribute57;
      x_adj_tbl(x_adj_count).attribute58          	:= adj.attribute58;
      x_adj_tbl(x_adj_count).attribute59          	:= adj.attribute59;
      x_adj_tbl(x_adj_count).attribute60          	:= adj.attribute60;
      x_adj_tbl(x_adj_count).attribute61          	:= adj.attribute61;
      x_adj_tbl(x_adj_count).attribute62          	:= adj.attribute62;
      x_adj_tbl(x_adj_count).attribute63          	:= adj.attribute63;
      x_adj_tbl(x_adj_count).attribute64          	:= adj.attribute64;
      x_adj_tbl(x_adj_count).attribute65          	:= adj.attribute65;
      x_adj_tbl(x_adj_count).attribute66          	:= adj.attribute66;
      x_adj_tbl(x_adj_count).attribute67          	:= adj.attribute67;
      x_adj_tbl(x_adj_count).attribute68          	:= adj.attribute68;
      x_adj_tbl(x_adj_count).attribute69          	:= adj.attribute69;
      x_adj_tbl(x_adj_count).attribute70          	:= adj.attribute70;
      x_adj_tbl(x_adj_count).attribute71          	:= adj.attribute71;
      x_adj_tbl(x_adj_count).attribute72          	:= adj.attribute72;
      x_adj_tbl(x_adj_count).attribute73          	:= adj.attribute73;
      x_adj_tbl(x_adj_count).attribute74          	:= adj.attribute74;
      x_adj_tbl(x_adj_count).attribute75          	:= adj.attribute75;
      x_adj_tbl(x_adj_count).attribute76          	:= adj.attribute76;
      x_adj_tbl(x_adj_count).attribute77          	:= adj.attribute77;
      x_adj_tbl(x_adj_count).attribute78          	:= adj.attribute78;
      x_adj_tbl(x_adj_count).attribute79          	:= adj.attribute79;
      x_adj_tbl(x_adj_count).attribute80          	:= adj.attribute80;
      x_adj_tbl(x_adj_count).attribute81          	:= adj.attribute81;
      x_adj_tbl(x_adj_count).attribute82          	:= adj.attribute82;
      x_adj_tbl(x_adj_count).attribute83          	:= adj.attribute83;
      x_adj_tbl(x_adj_count).attribute84          	:= adj.attribute84;
      x_adj_tbl(x_adj_count).attribute85          	:= adj.attribute85;
      x_adj_tbl(x_adj_count).attribute86          	:= adj.attribute86;
      x_adj_tbl(x_adj_count).attribute87          	:= adj.attribute87;
      x_adj_tbl(x_adj_count).attribute88          	:= adj.attribute88;
      x_adj_tbl(x_adj_count).attribute89          	:= adj.attribute89;
      x_adj_tbl(x_adj_count).attribute90          	:= adj.attribute90;
      x_adj_tbl(x_adj_count).attribute91          	:= adj.attribute91;
      x_adj_tbl(x_adj_count).attribute92          	:= adj.attribute92;
      x_adj_tbl(x_adj_count).attribute93          	:= adj.attribute93;
      x_adj_tbl(x_adj_count).attribute94          	:= adj.attribute94;
      x_adj_tbl(x_adj_count).attribute95          	:= adj.attribute95;
      x_adj_tbl(x_adj_count).attribute96          	:= adj.attribute96;
      x_adj_tbl(x_adj_count).attribute97          	:= adj.attribute97;
      x_adj_tbl(x_adj_count).attribute98          	:= adj.attribute98;
      x_adj_tbl(x_adj_count).attribute99          	:= adj.attribute99;
      x_adj_tbl(x_adj_count).attribute100         	:= adj.attribute100;
      IF (p_load_status = 'Unloaded') THEN
         x_adj_tbl(x_adj_count).load_status		:= adj.load_status;
      ELSE
	 x_adj_tbl(x_adj_count).calc_status_disp	:= adj.calc_status_disp;
      END IF;
   END IF;
   END LOOP;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get (
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get (
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);

END;
--
END cn_un_proc_pub;

/
