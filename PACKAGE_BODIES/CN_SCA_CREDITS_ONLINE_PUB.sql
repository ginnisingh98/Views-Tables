--------------------------------------------------------
--  DDL for Package Body CN_SCA_CREDITS_ONLINE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SCA_CREDITS_ONLINE_PUB" AS
-- $Header: cnpscaob.pls 120.2 2005/09/07 17:54:29 rchenna noship $
 -- +=========================================================================+
 -- +                   Procedure get_sales_credits                           +
 -- + Procedure Added for 11.5.10 SCA Enhancment                              +
 -- + For the transaction passed in identify winning rule using dynamic pkg   +
 -- + get allocation percentages and distribute and return the sales credit   +
 -- +                                                                         +
 -- + Based on the p_batch_id, API will get the data from                     +
 -- + cn_sca_headers_interface_GTT and cn_sca_lines_interface_GTT Global      +
 -- + Temporary tables. After processing, this API will keep the data in      +
 -- + cn_sca_lines_output_GTT table.                                          +
 -- +=========================================================================+
PROCEDURE get_sales_credits(
          p_api_version              IN           number,
          p_init_msg_list            IN           varchar2  := fnd_api.g_false,
          x_batch_id                 IN           number,
          p_org_id                   IN           number,
          x_return_status            OUT NOCOPY   varchar2,
          x_msg_count                OUT NOCOPY   number,
          x_msg_data                 OUT NOCOPY   varchar2)IS
   l_api_name                              CONSTANT VARCHAR2(30) := 'get_sales_credits';
   l_api_version                           CONSTANT NUMBER :=1.0;
   l_win_rule_id                           cn_sca_credit_rules.SCA_CREDIT_RULE_ID%TYPE;
   l_package_name                          VARCHAR2(100);
   l_stmt                                  VARCHAR2(4000);
   l_org_id                                NUMBER := NULL;
   l_found_rule_flag                       VARCHAR2(1);
   l_limit_rows                            NUMBER := 1 ;
   l_count                                 number;
   l_trx_source                            cn_sca_headers_interface_gtt.transaction_source%TYPE;
   l_rev_not_100_flag                      VARCHAR2(1) := 'N';

--+
--+ PL/SQL Tables and Records
--+

   TYPE interface_id_tbl_type
   IS TABLE OF cn_sca_headers_interface.sca_headers_interface_id%type;

   TYPE credit_rule_id_tbl_type
   IS TABLE OF cn_sca_credit_rules.sca_credit_rule_id%type;

   TYPE process_status_tbl_type
   IS TABLE OF cn_sca_headers_interface.process_status%type;

   TYPE rounding_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   TYPE lines_output_id_tbl_type
   IS TABLE OF cn_sca_lines_output.sca_lines_output_id%type;

   TYPE rounding_tbl_rec_type IS RECORD (
        rounding_tbl		   	   rounding_tbl_type,
	lines_output_id_tbl		   lines_output_id_tbl_type,
   	interface_id_tbl	    	   interface_id_tbl_type);

   l_rounding_tbl_rec			   rounding_tbl_rec_type;

--+
--+ Cursors Section
--+

--+
--+ Quote creation is always within an operating unit. At the same time, this
--+ table is a Global Temporary Table which has session specific data. So we
--+ need notadd org_id as filter condition for the statement.
--+
CURSOR  get_trans_src_cr IS
   SELECT DISTINCT transaction_source
     FROM cn_sca_headers_interface_gtt
    WHERE sca_batch_id = x_batch_id;

-- codeCheck: Though cn_sca_winning_rules_gtt has processed_date column,
-- dynamic SQL is not populating this column. That is why I had to refer
-- cn_sca_headers_interface_gtt table here. In future this table reference
-- need to be eliminated.

CURSOR rounding_cur IS
   SELECT ROUND(MAX(NVL(csad.rev_split_pct,0)) - SUM(NVL(l.allocation_percentage,0)),4),
          MIN(l.sca_lines_output_id) sca_lines_output_id,
          w.sca_headers_interface_id
     FROM cn_sca_headers_interface_gtt cshi,
          cn_sca_winning_rules_gtt w,
          cn_sca_lines_output_gtt l,
          cn_sca_alloc_details csad,
          cn_sca_allocations csa
    WHERE cshi.sca_headers_interface_id = w.sca_headers_interface_id
      AND w.sca_headers_interface_id = l.sca_headers_interface_id
      AND w.sca_credit_rule_id = csa.sca_credit_rule_id
      AND csad.sca_allocation_id = csa.sca_allocation_id
      AND w.sca_batch_id = x_batch_id
      AND csad.role_id = l.role_id
      AND l.revenue_type = 'REVENUE'
      AND cshi.processed_date BETWEEN csa.start_date AND NVL(end_date,cshi.processed_date)
   HAVING ROUND(MAX(NVL(csad.rev_split_pct,0)) - SUM(NVL(l.allocation_percentage,0)),4) <> 0
    GROUP BY w.sca_headers_interface_id,l.role_id;

CURSOR rounding1_cur IS
   SELECT ROUND(MAX(NVL(csad.nonrev_split_pct,0)) - SUM(NVL(l.allocation_percentage,0)),4),
          MIN(l.sca_lines_output_id) sca_lines_output_id,
          w.sca_headers_interface_id
     FROM cn_sca_headers_interface_gtt cshi,
          cn_sca_winning_rules_gtt w,
          cn_sca_lines_output_gtt l,
          cn_sca_alloc_details csad,
          cn_sca_allocations csa
    WHERE cshi.sca_headers_interface_id = w.sca_headers_interface_id
      AND w.sca_headers_interface_id = l.sca_headers_interface_id
      AND w.sca_credit_rule_id = csa.sca_credit_rule_id
      AND csad.sca_allocation_id = csa.sca_allocation_id
      AND w.sca_batch_id = x_batch_id
      AND csad.role_id = l.role_id
      AND l.revenue_type = 'NONREVENUE'
      AND NVL(csad.nrev_credit_split,'N')  = 'Y'
      AND cshi.processed_date BETWEEN csa.start_date AND NVL(end_date,cshi.processed_date)
   HAVING ROUND(MAX(NVL(csad.nonrev_split_pct,0)) - SUM(NVL(l.allocation_percentage,0)),4) <> 0
    GROUP BY w.sca_headers_interface_id,l.role_id;

 BEGIN
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

   --+
   --+ codeCheck: Eventually this logic will be after MOAC patch is applied.
   --+ We will validate the org_id using MO_GLOBAL.VALIDATE_ORGID_PUB_API
   --+

   BEGIN
      SELECT org_id INTO  l_org_id FROM cn_repositories;
      IF l_org_id IS NULL then
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('CN', 'CN_INVALID_ORG');
            FND_MSG_PUB.ADD;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('CN', 'CN_INVALID_ORG');
            FND_MSG_PUB.ADD;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
   END ;


   OPEN get_trans_src_cr;
   FETCH get_trans_src_cr INTO l_trx_source;
   IF get_trans_src_cr%NOTFOUND THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
   	 FND_MESSAGE.SET_NAME ('CN','CN_SCA_NO_ROWS_TO_PROCESS');
   	 FND_MSG_PUB.Add;
      END IF;
      CLOSE get_trans_src_cr;
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   CLOSE get_trans_src_cr;

   -- Construct the name of the dynamic package to be called to get the
   -- the winning rule
   l_package_name := 'cn_sca_rodyn_'|| substr(lower(l_trx_source),1,8) || '_' || abs(l_org_id) || '_pkg';
   l_stmt := 'BEGIN ' || l_package_name ||'.get_winning_rule(:x_batch_id,:p_org_id,:x_return_status,:x_msg_count,:x_msg_data);  END;';
   -- Execute the dyanmic package to get all the winning rules
   -- inserted into cn_sca_winning_rules_gtt.

   --dbms_output.put_line('BEFORE CALLING  ');
   --dbms_output.put_line(l_stmt);

   EXECUTE IMMEDIATE l_stmt USING IN x_batch_id ,IN p_org_id, OUT x_return_status,OUT x_msg_count,OUT x_msg_data;

   --dbms_output.put_line('status is INTERNAL '||x_return_status||'  '||x_msg_data);

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
   END IF;

   l_stmt :=
   'INSERT INTO cn_sca_lines_output_gtt
   (
   sca_lines_output_id        ,
   sca_batch_id,
   sca_headers_interface_id   ,
   processed_date             ,
   status                     ,
   source_trx_id              ,
   resource_id                ,
   role_id                    ,
   revenue_type               ,
   allocation_percentage
   )
   SELECT cn_sca_lines_output_gtt_s.nextval,
          batch_id,
          interface_id,
          processed_date,
          status,
          src_trx_id,
          resource_id,
          role_id,
          revenue_type,
          allocation
   FROM
   (select
           x.batch_id,
           x.interface_id,
           x.processed_date,
           x.status,
           x.src_trx_id,
           x.resource_id,
           x.role_id,
           y.revenue_type,
           decode(y.revenue_type, ''REVENUE'', x.rev_value, x.non_rev_value) allocation
   from
   (SELECT :x_batch_id1 batch_id,
           csli.sca_headers_interface_id interface_id,
           cshig.processed_date processed_date,
           ''ALLOCATED'' status,
           csli.source_trx_id  src_trx_id,
           csli.resource_id resource_id,
           csli.role_id role_id,
           ROUND(csad.rev_split_pct/nvl(crc.count_of_resources,1),4) rev_value,
           DECODE(csad.nrev_credit_split,''Y'',
                  ROUND(csad.nonrev_split_pct/NVL(crc.count_of_resources,1),4),
                  csad.nonrev_split_pct) non_rev_value
   FROM    cn_sca_alloc_details csad,
           cn_sca_allocations csa,
           (SELECT min( sca_credit_rule_id) sca_credit_rule_id,
                   sca_headers_interface_id
           FROM    cn_sca_winning_rules_gtt
           WHERE sca_batch_id = :x_batch_id2
           GROUP BY SCA_HEADERS_INTERFACE_ID  ) cswrg,
           cn_sca_headers_interface_gtt cshig,
           (SELECT count(distinct RESOURCE_ID) count_of_resources ,
                   role_id,
                   sca_headers_interface_id
           FROM    cn_sca_lines_interface_gtt cslig
           WHERE   cslig.sca_batch_id =:x_batch_id3
           GROUP BY sca_headers_interface_id,
                   role_id) crc,
           cn_sca_lines_interface_gtt csli
   WHERE   cshig.sca_batch_id = :x_batch_id4
   AND     csli.sca_batch_id =cshig.sca_batch_id
   AND     cswrg.sca_headers_interface_id = cshig.sca_headers_interface_id
   AND     crc.sca_headers_interface_id =   cshig.sca_headers_interface_id
   AND     csli.sca_headers_interface_id =  cshig.sca_headers_interface_id
   AND     csa.sca_credit_rule_id = cswrg.sca_credit_rule_id
   AND     csad.ROLE_ID = csli.role_id
   AND     crc.ROLE_ID  = csli.role_id
   AND     csad.sca_allocation_id = csa.sca_allocation_id
   AND     cshig.processed_date
   BETWEEN csa.start_date AND NVL(end_date,cshig.processed_date)
   ) x,
   (select ''REVENUE'' revenue_type from dual
   union all
    select ''NONREVENUE'' revenue_type from dual) y) result1 WHERE allocation > 0';

    EXECUTE IMMEDIATE l_stmt USING IN x_batch_id,IN x_batch_id,IN x_batch_id,IN x_batch_id;

   --+
   --+ This code will eliminate the rounding issue for Revenue split percentages.
   --+

   OPEN rounding_cur;
   FETCH rounding_cur
   BULK COLLECT INTO l_rounding_tbl_rec.rounding_tbl,
                     l_rounding_tbl_rec.lines_output_id_tbl,
                     l_rounding_tbl_rec.interface_id_tbl;
   CLOSE rounding_cur;

   IF (l_rounding_tbl_rec.interface_id_tbl.COUNT > 0) THEN
      FORALL indx IN l_rounding_tbl_rec.interface_id_tbl.FIRST .. l_rounding_tbl_rec.interface_id_tbl.LAST
            UPDATE cn_sca_lines_output_gtt l
	       SET l.allocation_percentage = l.allocation_percentage +
	                                     l_rounding_tbl_rec.rounding_tbl(indx)
             WHERE l.sca_headers_interface_id = l_rounding_tbl_rec.interface_id_tbl(indx)
	       AND l.sca_lines_output_id = l_rounding_tbl_rec.lines_output_id_tbl(indx);
   END IF;

   --+
   --+ This code will eliminate the rounding issue for Non-revenue split percentages.
   --+

   OPEN rounding1_cur;
   FETCH rounding1_cur
   BULK COLLECT INTO l_rounding_tbl_rec.rounding_tbl,
                     l_rounding_tbl_rec.lines_output_id_tbl,
                     l_rounding_tbl_rec.interface_id_tbl;
   CLOSE rounding1_cur;

   IF (l_rounding_tbl_rec.interface_id_tbl.COUNT > 0) THEN
      FORALL indx IN l_rounding_tbl_rec.interface_id_tbl.FIRST .. l_rounding_tbl_rec.interface_id_tbl.LAST
            UPDATE cn_sca_lines_output_gtt l
	       SET l.allocation_percentage = l.allocation_percentage +
	                                     l_rounding_tbl_rec.rounding_tbl(indx)
             WHERE l.sca_headers_interface_id = l_rounding_tbl_rec.interface_id_tbl(indx)
	       AND l.sca_lines_output_id = l_rounding_tbl_rec.lines_output_id_tbl(indx);
   END IF;


   -- update the status to rev not 100 where sum
   -- of allocated revenues across roles is not 100
   UPDATE cn_sca_lines_output_gtt set status = 'REV NOT 100'
   WHERE sca_batch_id =x_batch_id
   AND   revenue_type = 'REVENUE'
   AND sca_headers_interface_id in
   (SELECT  sca_headers_interface_id
       FROM  cn_sca_lines_output_gtt
       WHERE sca_batch_id = x_batch_id
       AND   revenue_type = 'REVENUE'
       GROUP BY sca_headers_interface_id
       HAVING SUM(allocation_percentage) <> 100);
  IF SQL%ROWCOUNT > 0 THEN
  	l_rev_not_100_flag := 'Y';
  END IF;




   -- copy the status from output to headers table
   UPDATE cn_sca_headers_interface_gtt cshig set
   PROCESS_STATUS = (SELECT distinct status
                     FROM cn_sca_lines_output_gtt cslog
                     WHERE cslog.sca_headers_interface_id = cshig.sca_headers_interface_id
                     AND sca_batch_id =x_batch_id
                     AND revenue_type = 'REVENUE'),
   CREDIT_RULE_ID  = (SELECT min( sca_credit_rule_id)
                      FROM    cn_sca_winning_rules_gtt cswr
                       WHERE sca_batch_id = x_batch_id
                       and cswr.sca_headers_interface_id = cshig.sca_headers_interface_id)
   WHERE sca_batch_id = x_batch_id   ;
   --AND EXISTS (SELECT  'X'
   --                  FROM cn_sca_lines_output_gtt cslog
   --                  WHERE cslog.sca_headers_interface_id = cshig.sca_headers_interface_id
   --                  AND revenue_type = 'REVENUE');

   -- if no output was created then
   -- update headers to unallocated
   UPDATE cn_sca_headers_interface_gtt cshig set
   PROCESS_STATUS = 'NOT ALLOCATED'
   WHERE sca_batch_id = x_batch_id
   AND NOT EXISTS (SELECT  'X'
                     FROM cn_sca_lines_output_gtt cslog
                     WHERE cslog.sca_headers_interface_id = cshig.sca_headers_interface_id
                     AND revenue_type = 'REVENUE');

   -- if no output was created then
   -- update headers to unallocated
   UPDATE cn_sca_headers_interface_gtt cshig set
   PROCESS_STATUS = 'NO RULE'
   WHERE sca_batch_id = x_batch_id
   AND NOT EXISTS (SELECT  'X'
                     FROM    cn_sca_winning_rules_gtt cswr
                     WHERE sca_batch_id = x_batch_id
                     AND cswr.sca_headers_interface_id = cshig.sca_headers_interface_id);



  IF l_rev_not_100_flag = 'Y' THEN

	/* codeCheck: We may need p_org_id while calling this procedure from
	   batch program */
    	cn_sca_wf_pkg.start_process(p_sca_batch_id => x_batch_id,
    	                            p_wf_process   => 'CN_SCA_REV_DIST_PR',
                                    p_wf_item_type => 'CNSCARPR');
  END IF;


  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
          (p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
           );
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
          (p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
           );
     WHEN OTHERS THEN
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

END get_sales_credits;
END cn_sca_credits_online_pub;

/
