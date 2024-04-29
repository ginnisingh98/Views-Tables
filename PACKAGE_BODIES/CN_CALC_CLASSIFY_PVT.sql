--------------------------------------------------------
--  DDL for Package Body CN_CALC_CLASSIFY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CALC_CLASSIFY_PVT" AS
-- $Header: cnvcclsb.pls 120.5.12010000.2 2008/09/22 13:39:57 rajukum ship $

  G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_CALC_CLASSIFY_PVT';
  G_FILE_NAME                 CONSTANT VARCHAR2(12) := 'cnvcclsb.pls';
  G_LAST_UPDATE_DATE          DATE    := sysdate;
  G_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
  G_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;

  g_org_id                    NUMBER;
  g_org_append                VARCHAR2(100);

  g_intel_calc_flag           VARCHAR2(1);


  -- API name 	: classify_batch
  -- Type	: Private.
  -- Pre-reqs	:
  -- Usage	:
  --+
  -- Desc 	:
  --
  -- Parameters	:
  --  IN	:  p_api_version       NUMBER      Require
  -- 		   p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
  -- 		   p_commit	       VARCHAR2    Optional (FND_API.G_FALSE)
  -- 		   p_validation_level  NUMBER      Optional (FND_API.G_VALID_LEVEL_FULL)
  --  OUT	:  x_return_status     VARCHAR2(1)
  -- 		   x_msg_count	       NUMBER
  -- 		   x_msg_data	       VARCHAR2(2000)
  --  IN	:  p_physical_batch_id NUMBER(15) Require
  --
  --
  --  +
  --+
  -- Version	: Current version	1.0
  --		  Initial version 	1.0
  --+
  -- Notes	:
  --+
  -- End of comments

  PROCEDURE classify_batch
    ( p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,

      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,

      p_physical_batch_id     IN  NUMBER,
      p_mode                  IN  VARCHAR2 := 'NORMAL'

      ) IS

     l_api_name       CONSTANT VARCHAR2(30) := 'Classify_batch';
     l_api_version    CONSTANT NUMBER :=1.0;

     l_min_start_date DATE;
     l_max_end_date DATE;
     l_revenue_class_id NUMBER;
     l_stmt VARCHAR2(1000);

     l_calc_type VARCHAR2(30);
     l_dummy NUMBER;

     -- assuming l_min_start-date/l_max_end_date are not null
     CURSOR ruleset_cr IS
	SELECT ruleset_id,
	  Greatest(start_date, l_min_start_date) start_date,
	  Least(Nvl(end_date,l_max_end_date), Nvl(l_max_end_date, end_date)) end_date
	  FROM cn_rulesets_all
	  WHERE ((start_date < l_min_start_date AND (end_date IS NULL OR end_date >= l_min_start_date )) OR
              start_date BETWEEN l_min_start_date AND l_max_end_date)
	    AND module_type = 'REVCLS'
        AND org_id = g_org_id
	  ORDER BY start_date;

     l_ruleset ruleset_cr%ROWTYPE;
  BEGIN
     -- Standard Start of API savepoint
     SAVEPOINT	classify_batch;
     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call ( l_api_version ,
					  p_api_version ,
					  l_api_name    ,
					  G_PKG_NAME )
     THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
     END IF;

     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Codes start here
     IF (p_mode = 'NEW') THEN
	   l_calc_type := 'COMMISSION';
	   g_intel_calc_flag := 'N';
     ELSE
	   l_calc_type := cn_calc_sub_batches_pkg.get_calc_type(p_physical_batch_id);
	   g_intel_calc_flag := cn_calc_sub_batches_pkg.get_intel_calc_flag(p_physical_batch_id);
     END IF;

     SELECT MIN(start_date), MAX(end_date)
       INTO l_min_start_date, l_max_end_date
       FROM cn_process_batches_all
       WHERE physical_batch_id = p_physical_batch_id;

     -- cache org_id and org_append

     select org_id
       into g_org_id
       from cn_process_batches_all
      where physical_batch_id = p_physical_batch_id
        and rownum = 1;

	 g_org_append := '_' || g_org_id;

     FOR l_ruleset IN ruleset_cr LOOP

	l_stmt := 'BEGIN ' ||
	  ':rev_class_id := ' ||'cn_clsfn_' || To_char(Abs(l_ruleset.ruleset_id))
	  || g_org_append || '.classify_' || To_char(Abs(l_ruleset.ruleset_id)) ||
	  '( :commission_header_id);' ||	  'END;';


   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'cn.plsql.cn_calc_classify_pvt.classify_batch.statement',
			    	'Calling: '||l_stmt);
   end if;

	DECLARE
	   CURSOR l_trxs_csr IS
	      SELECT ch.commission_header_id,
		     ch.pre_processed_code,
		     ch.revenue_class_id
		FROM cn_commission_headers_all ch
		WHERE ch.direct_salesrep_id IN (SELECT salesrep_id
		                                  FROM cn_process_batches_all pb
                                         WHERE pb.physical_batch_id = p_physical_batch_id)
		AND ch.processed_date BETWEEN l_ruleset.start_date AND l_ruleset.end_date
        AND ch.org_id = g_org_id
		AND (( l_calc_type = 'COMMISSION'
		       AND ch.trx_type NOT IN ('FORECAST', 'GRP', 'BONUS') )
		     OR (l_calc_type = 'FORECAST' AND ch.trx_type = 'FORECAST' ) )
		AND ch.status IN ('COL') ;

	   CURSOR l_trx_cls_cr IS
	      SELECT ch.commission_header_id,
		     ch.pre_processed_code,
		     ch.revenue_class_id
		FROM cn_commission_headers_all ch
		WHERE ch.direct_salesrep_id
		IN ( SELECT salesrep_id
		     FROM cn_process_batches_all pb
		     WHERE pb.physical_batch_id = p_physical_batch_id)
		AND ch.processed_date BETWEEN l_ruleset.start_date AND l_ruleset.end_date
        AND ch.org_id = g_org_id
		AND exists (SELECT 1
			    FROM cn_notify_log_all notify
			    WHERE notify.period_id = ch.processed_period_id
			    AND notify.status = 'INCOMPLETE'
			    AND revert_state = 'COL'
                AND org_id = g_org_id
			    AND salesrep_id = -1000)
		AND (( l_calc_type = 'COMMISSION'
		       AND ch.trx_type NOT IN ('FORECAST', 'GRP', 'BONUS') )
		     OR (l_calc_type = 'FORECAST' AND ch.trx_type = 'FORECAST' ) )
		AND ch.status IN ('CLS', 'XCLS')
		AND substrb(ch.pre_processed_code,1,1) = 'C';

	   CURSOR l_trx_roll_cr IS
	      SELECT ch.commission_header_id,
		     ch.pre_processed_code,
		     ch.revenue_class_id
		FROM cn_commission_headers_all ch
		WHERE ch.direct_salesrep_id IN (SELECT salesrep_id
                                          FROM cn_process_batches_all pb
                                         WHERE pb.physical_batch_id = p_physical_batch_id)
		AND ch.processed_date BETWEEN l_ruleset.start_date AND l_ruleset.end_date
        AND ch.org_id = g_org_id
		AND exists (SELECT 1
			    FROM cn_notify_log_all notify
			    WHERE notify.period_id = ch.processed_period_id
			    AND notify.status = 'INCOMPLETE'
			    AND revert_state = 'COL'
                AND org_id = g_org_id
			    AND salesrep_id = -1000)
		AND (( l_calc_type = 'COMMISSION'
		       AND ch.trx_type NOT IN ('FORECAST', 'GRP', 'BONUS') )
		     OR (l_calc_type = 'FORECAST' AND ch.trx_type = 'FORECAST' ) )
		AND ch.status IN ('ROLL')
		AND (ch.parent_header_id IS NULL OR ch.parent_header_id <> -1)
		AND substrb(ch.pre_processed_code,1,1) = 'C';
	BEGIN
	   IF ( p_mode = 'NORMAL') AND (g_intel_calc_flag = 'Y') THEN
	      FOR eachtrx IN l_trx_cls_cr LOOP

		 execute immediate l_stmt using OUT l_revenue_class_id, eachtrx.commission_header_id;

		 IF (l_revenue_class_id IS NOT NULL) THEN
		    -- Find one revenue class for this transaction
		    UPDATE cn_commission_headers_all
		      SET status = 'CLS',
		      revenue_class_id = l_revenue_class_id,
              last_update_date = sysdate,
              last_updated_by = G_LAST_UPDATED_BY,
              last_update_login = G_LAST_UPDATE_LOGIN
		      WHERE commission_header_id = eachtrx.commission_header_id;

		    IF (l_revenue_class_id <> eachtrx.revenue_class_id) THEN
		       -- new revenue_class_id, need to re-populate
		       cn_formula_common_pkg.revert_header_lines
			 (p_commission_header_id => eachtrx.commission_header_id,
			  p_revert_state         => 'XCLS');
		    END IF;
		  ELSE
		    -- Couldn't find revenue class for this transaction
		    UPDATE cn_commission_headers_all
		      SET status = 'XCLS',
		      revenue_class_id = NULL,
              last_update_date = sysdate,
              last_updated_by = G_LAST_UPDATED_BY,
              last_update_login = G_LAST_UPDATE_LOGIN
		      WHERE commission_header_id = eachtrx.commission_header_id;

		    cn_formula_common_pkg.revert_header_lines
		      (p_commission_header_id => eachtrx.commission_header_id,
		       p_revert_state         => 'XCLS');

		 END IF;

	      END LOOP;

	      FOR eachtrx IN l_trx_roll_cr LOOP

		 execute immediate l_stmt using OUT l_revenue_class_id,
		   eachtrx.commission_header_id;

		 IF (l_revenue_class_id IS NOT NULL) THEN
		    IF (l_revenue_class_id <> eachtrx.revenue_class_id) THEN

		       -- Find one revenue class for this transaction
		       UPDATE cn_commission_headers_all
			 SET status = 'ROLL',
			 revenue_class_id = l_revenue_class_id,
              last_update_date = sysdate,
              last_updated_by = G_LAST_UPDATED_BY,
              last_update_login = G_LAST_UPDATE_LOGIN
			 WHERE commission_header_id = eachtrx.commission_header_id;

			 UPDATE cn_commission_lines_all
			 SET revenue_class_id = l_revenue_class_id
			 WHERE commission_header_id = eachtrx.commission_header_id;

		       -- new revenue_class_id, need to re-populate
		       cn_formula_common_pkg.revert_header_lines
			 (p_commission_header_id => eachtrx.commission_header_id,
			  p_revert_state         => 'ROLL');

		    END IF;
		  ELSE
		    -- Couldn't find revenue class for this transaction
		    UPDATE cn_commission_headers_all
		      SET status = 'XCLS',
		      revenue_class_id = NULL,
              last_update_date = sysdate,
              last_updated_by = G_LAST_UPDATED_BY,
              last_update_login = G_LAST_UPDATE_LOGIN
		      WHERE commission_header_id = eachtrx.commission_header_id;

		    cn_formula_common_pkg.revert_header_lines
		      (p_commission_header_id => eachtrx.commission_header_id,
		       p_revert_state         => 'XCLS');

		 END IF; -- End of l_revenue_class_id

	      END LOOP; -- End of l_trx_roll_cr

	   END IF; -- End of p_mode

	   FOR l_transaction IN l_trxs_csr LOOP
	      IF (substrb(l_transaction.pre_processed_code,1,1) = 'N') THEN
		 -- revenue_class_id is known, skip classification
		 l_revenue_class_id := l_transaction.revenue_class_id;
	       ELSE
		 -- this transaction need to be classified
		 execute immediate l_stmt using OUT l_revenue_class_id, l_transaction.commission_header_id;
	      END IF;

	      IF (l_revenue_class_id IS NOT NULL) THEN

		 -- Find one revenue class for this transaction
		 UPDATE cn_commission_headers_all
		   SET status = 'CLS',
		       revenue_class_id = l_revenue_class_id,
              last_update_date = sysdate,
              last_updated_by = G_LAST_UPDATED_BY,
              last_update_login = G_LAST_UPDATE_LOGIN
		   WHERE commission_header_id = l_transaction.commission_header_id;

	       ELSE
		 -- Couldn't find revenue class for this transaction
		 UPDATE cn_commission_headers_all
		   SET status = 'XCLS',
		       revenue_class_id = NULL,
              last_update_date = sysdate,
              last_updated_by = G_LAST_UPDATED_BY,
              last_update_login = G_LAST_UPDATE_LOGIN
		   WHERE commission_header_id = l_transaction.commission_header_id;

	      END IF;

	   END LOOP; -- end of transaction loop
	END; -- end of one ruleset
     END LOOP;

     -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit ) THEN
	COMMIT WORK;
     END IF;

     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
       ( p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO classify_batch;
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (p_count   =>  x_msg_count ,
	   p_data    =>  x_msg_data  ,
	   p_encoded => FND_API.G_FALSE
	  );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO classify_batch;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (p_count   =>  x_msg_count ,
	   p_data    =>  x_msg_data  ,
	   p_encoded => FND_API.G_FALSE
	  );

     WHEN OTHERS THEN
	ROLLBACK TO classify_batch;

	   if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       'cn.plsql.cn_calc_classify_pvt.classify_batch.exception',
		       		   sqlerrm);
       end if;

	fnd_file.put_line(fnd_file.Log, sqlerrm);
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	  THEN
	   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
	END IF;
	FND_MSG_PUB.Count_And_Get
	  (p_count   =>  x_msg_count ,
	   p_data    =>  x_msg_data  ,
	   p_encoded => FND_API.G_FALSE
	  );

  END classify_batch;


   -- API name 	: classify
  -- Type	: Private.
  -- Pre-reqs	:
  -- Usage	:
  --+
  -- Desc 	:
  --
  --
  --+
  -- Parameters	:
  --  IN	:  p_api_version       NUMBER      Require
  -- 		   p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
  -- 		   p_commit	       VARCHAR2    Optional (FND_API.G_FALSE)
  -- 		   p_validation_level  NUMBER      Optional (FND_API.G_VALID_LEVEL_FULL)
  --		   p_transaction_rec   cn_commission_headers%rowtype
  --  OUT	:  x_return_status     VARCHAR2(1)
  -- 		   x_msg_count	       NUMBER
  -- 		   x_msg_data	       VARCHAR2(2000)
  --               x_revenue_class_id   NUMBER
  --
  --
  --  +
  --+
  -- Version	: Current version	1.0
  --		  Initial version 	1.0
  --+
  -- Notes	:
  --+
  -- End of comments

procedure classify(p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_transaction_rec            IN      cn_commission_headers%rowtype,
   x_revenue_class_id           OUT NOCOPY NUMBER,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2)
IS

l_ruleset_id number;
l_ruleset_status varchar2(20);
l_begin varchar2(20) := 'begin :l_id := ';
l_package varchar2(50);
l_stmt varchar2(1000) :=
'classify(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,'||
':16,:17,:18,:19,:20,:21,:22,:23,:24,:25,:26,:27,:28,:29,:30,:31,:32,:33,:34,:35,:36,:37,:38,:39,'||
':40,:41,:42,:43,:44,:45,:46,:47,:48,:49,:50,:51,:52,:53,:54,:55,:56,:57,:58,:59,:60,:61,:62,:63,:64,:65,'||
':66,:67,:68,:69,:70,:71,:72,:73,:74,:75,:76,:77,:78,:79,:80,:81,:82,:83,:84,:85,:86,:87,:88,:89,:90,'||
':91,:92,:93,:94,:95,:96,:97,:98,:99,:100,:101,:102,:103,:104,:105,:106,:107,:108,:109,:110,:111,:112,'||
':113,:114,:115,:116,:117,:118,:119,:120,:121,:122,:123,:124,:125,:126,:127,:128,:129,:130,:131,:132,'||
':133,:134,:135,:136,:137,:138,:139,:140,:141,:142,:143,:144,:145,:146,:147,:148,:149,:150,:151,:152,:153,'||
':154,:155,:156,:157,:158,:159,:160,:161,:162,:163,:164,:165,:166,:167,:168,:169,:170,:171,:172,:173); end;';

cursor get_ruleset(l_org_id number, l_proc_date date) is
 select ruleset_id, ruleset_status
 from cn_rulesets_all
 where org_id = l_org_id
 and module_type = 'REVCLS'
 and l_proc_date between start_date and nvl(end_date,l_proc_date);

begin

--check fo null values of Processed date and Org_id
  IF p_transaction_rec.processed_date = FND_API.G_MISS_DATE THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSE IF p_transaction_rec.org_id =  FND_API.G_MISS_NUM THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  END IF;

  open get_ruleset(p_transaction_rec.org_id,p_transaction_rec.processed_date);
  fetch get_ruleset into l_ruleset_id, l_ruleset_status;

--Check if there is any Ruleset for the given processed date
  if(get_ruleset%notfound) then
  close get_ruleset;
  raise FND_API.G_EXC_ERROR;
  end if;

  close get_ruleset;
--Check if the Classification package has been generated for the selected Ruleset
  if l_ruleset_status <> 'GENERATED' then
  raise FND_API.G_EXC_ERROR;
  end if;

  l_package := 'cn_clsfn_' || abs(l_ruleset_id) || '_1_' || p_transaction_rec.org_id || '.';

  l_stmt := l_begin || l_package || l_stmt;


execute immediate l_stmt using out x_revenue_class_id,
p_transaction_rec.source_doc_type,
p_transaction_rec.attribute50,
p_transaction_rec.invoice_number,
p_transaction_rec.attribute73,
p_transaction_rec.attribute87,
p_transaction_rec.forecast_id,
p_transaction_rec.upside_quantity,
p_transaction_rec.upside_amount,
p_transaction_rec.uom_code,
p_transaction_rec.source_trx_id,
p_transaction_rec.source_trx_line_id,
p_transaction_rec.source_trx_sales_line_id,
p_transaction_rec.negated_flag,
p_transaction_rec.customer_id,
p_transaction_rec.inventory_item_id,
p_transaction_rec.order_number,
p_transaction_rec.booked_date,
p_transaction_rec.invoice_date,
p_transaction_rec.bill_to_address_id,
p_transaction_rec.ship_to_address_id,
p_transaction_rec.bill_to_contact_id,
p_transaction_rec.ship_to_contact_id,
p_transaction_rec.adj_comm_lines_api_id,
p_transaction_rec.adjust_date,
p_transaction_rec.adjusted_by,
p_transaction_rec.revenue_type,
p_transaction_rec.adjust_rollup_flag,
p_transaction_rec.adjust_comments,
p_transaction_rec.adjust_status,
p_transaction_rec.line_number,
p_transaction_rec.request_id,
p_transaction_rec.program_id,
p_transaction_rec.program_application_id,
p_transaction_rec.program_update_date,
p_transaction_rec.type,
p_transaction_rec.sales_channel,
p_transaction_rec.object_version_number,
p_transaction_rec.split_pct,
p_transaction_rec.split_status,
p_transaction_rec.security_group_id,
p_transaction_rec.parent_header_id,
p_transaction_rec.trx_type,
p_transaction_rec.status,
p_transaction_rec.pre_processed_code,
p_transaction_rec.comm_lines_api_id,
p_transaction_rec.source_trx_number,
p_transaction_rec.quota_id,
p_transaction_rec.srp_plan_assign_id,
p_transaction_rec.revenue_class_id,
p_transaction_rec.role_id,
p_transaction_rec.comp_group_id,
p_transaction_rec.commission_amount,
p_transaction_rec.trx_batch_id,
p_transaction_rec.reversal_flag,
p_transaction_rec.reversal_header_id,
p_transaction_rec.reason_code,
p_transaction_rec.comments,
p_transaction_rec.attribute_category,
p_transaction_rec.attribute1,
p_transaction_rec.attribute2,
p_transaction_rec.attribute3,
p_transaction_rec.attribute4,
p_transaction_rec.attribute5,
p_transaction_rec.attribute6,
p_transaction_rec.attribute7,
p_transaction_rec.attribute8,
p_transaction_rec.attribute9,
p_transaction_rec.attribute10,
p_transaction_rec.attribute11,
p_transaction_rec.attribute12,
p_transaction_rec.attribute13,
p_transaction_rec.attribute14,
p_transaction_rec.attribute15,
p_transaction_rec.attribute16,
p_transaction_rec.attribute17,
p_transaction_rec.attribute18,
p_transaction_rec.attribute19,
p_transaction_rec.attribute20,
p_transaction_rec.attribute21,
p_transaction_rec.attribute22,
p_transaction_rec.attribute23,
p_transaction_rec.attribute24,
p_transaction_rec.attribute25,
p_transaction_rec.attribute26,
p_transaction_rec.attribute27,
p_transaction_rec.attribute28,
p_transaction_rec.attribute29,
p_transaction_rec.attribute30,
p_transaction_rec.attribute31,
p_transaction_rec.attribute32,
p_transaction_rec.attribute33,
p_transaction_rec.attribute34,
p_transaction_rec.attribute35,
p_transaction_rec.attribute36,
p_transaction_rec.attribute37,
p_transaction_rec.attribute38,
p_transaction_rec.attribute39,
p_transaction_rec.attribute40,
p_transaction_rec.attribute41,
p_transaction_rec.attribute42,
p_transaction_rec.attribute43,
p_transaction_rec.attribute44,
p_transaction_rec.attribute45,
p_transaction_rec.attribute46,
p_transaction_rec.attribute47,
p_transaction_rec.attribute48,
p_transaction_rec.attribute49,
p_transaction_rec.attribute51,
p_transaction_rec.attribute52,
p_transaction_rec.attribute53,
p_transaction_rec.attribute54,
p_transaction_rec.attribute55,
p_transaction_rec.attribute56,
p_transaction_rec.attribute57,
p_transaction_rec.attribute58,
p_transaction_rec.attribute59,
p_transaction_rec.attribute60,
p_transaction_rec.attribute61,
p_transaction_rec.attribute62,
p_transaction_rec.attribute63,
p_transaction_rec.attribute64,
p_transaction_rec.attribute65,
p_transaction_rec.attribute66,
p_transaction_rec.attribute67,
p_transaction_rec.attribute68,
p_transaction_rec.attribute69,
p_transaction_rec.attribute70,
p_transaction_rec.attribute71,
p_transaction_rec.attribute72,
p_transaction_rec.attribute74,
p_transaction_rec.attribute75,
p_transaction_rec.attribute76,
p_transaction_rec.attribute77,
p_transaction_rec.attribute78,
p_transaction_rec.attribute79,
p_transaction_rec.attribute80,
p_transaction_rec.attribute81,
p_transaction_rec.attribute82,
p_transaction_rec.attribute83,
p_transaction_rec.attribute84,
p_transaction_rec.attribute85,
p_transaction_rec.attribute86,
p_transaction_rec.attribute88,
p_transaction_rec.attribute89,
p_transaction_rec.attribute90,
p_transaction_rec.attribute91,
p_transaction_rec.attribute92,
p_transaction_rec.attribute93,
p_transaction_rec.attribute94,
p_transaction_rec.attribute95,
p_transaction_rec.attribute96,
p_transaction_rec.attribute97,
p_transaction_rec.attribute98,
p_transaction_rec.attribute99,
p_transaction_rec.attribute100,
p_transaction_rec.last_update_date,
p_transaction_rec.last_updated_by,
p_transaction_rec.last_update_login,
p_transaction_rec.creation_date,
p_transaction_rec.created_by,
p_transaction_rec.org_id,
p_transaction_rec.exchange_rate,
p_transaction_rec.commission_header_id,
p_transaction_rec.direct_salesrep_id,
p_transaction_rec.processed_date,
p_transaction_rec.processed_period_id,
p_transaction_rec.rollup_date,
p_transaction_rec.transaction_amount,
p_transaction_rec.quantity,
p_transaction_rec.discount_percentage,
p_transaction_rec.margin_percentage,
p_transaction_rec.orig_currency_code,
p_transaction_rec.transaction_amount_orig;

-- Error handling. etc.
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 WHEN OTHERS THEN
 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

end classify;



END cn_calc_classify_pvt;

/
