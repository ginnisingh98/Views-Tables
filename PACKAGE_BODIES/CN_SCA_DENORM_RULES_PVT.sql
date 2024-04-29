--------------------------------------------------------
--  DDL for Package Body CN_SCA_DENORM_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SCA_DENORM_RULES_PVT" AS
-- $Header: cnvscadb.pls 120.5 2006/03/31 04:16:25 rrshetty noship $
-- +======================================================================+
-- |                Copyright (c) 1994 Oracle Corporation                 |
-- |                   Redwood Shores, California, USA                    |
-- |                        All rights reserved.                          |
-- +======================================================================+
--
-- Package Name
--   CN_SCA_DENORM_RULES_PVT
-- Purpose
--   This package is a public API for processing Credit Rules and associated
--   allocation percentages.
-- History
--   06/26/03   Rao.Chenna         Created
--
--
-- Global Variables
--
PROCEDURE debugmsg(msg VARCHAR2) IS
BEGIN

    IF g_cn_debug = 'Y' THEN
        cn_message_pkg.debug(substr(msg,1,254));
        fnd_file.put_line(fnd_file.Log, msg);
    END IF;

END debugmsg;
--
PROCEDURE find_combinations(
   	p_transaction_source	IN  VARCHAR2,
   	p_org_id		IN  NUMBER,
	x_return_status		OUT NOCOPY VARCHAR2) IS

--+
--+ Cursors Section
--+

CURSOR rule_attr_cur IS
   SELECT mv.sca_rule_attribute_id,
          ra.src_column_name
     FROM cn_sca_rule_cond_vals_mv mv,
          cn_sca_rule_attributes ra
    WHERE mv.sca_rule_attribute_id = ra.sca_rule_attribute_id
      AND mv.transaction_source = p_transaction_source
      AND EXISTS(
          SELECT 'X'
            FROM cn_sca_denorm_rules dr
           WHERE mv.sca_credit_rule_id = dr.sca_credit_rule_id
	     AND dr.transaction_source = p_transaction_source
	     AND dr.org_id = p_org_id)
    GROUP BY mv.sca_rule_attribute_id, ra.src_column_name;
--
CURSOR get_attr_cur IS
   SELECT rule_attr_comb_value
     FROM cn_sca_denorm_rules
    WHERE transaction_source = p_transaction_source
      AND org_id = p_org_id
    GROUP BY rule_attr_comb_value;
--
CURSOR operator_cur(l_rule_attr_id NUMBER) IS
   SELECT mv.operator_id
     FROM cn_sca_rule_cond_vals_mv mv
    WHERE mv.sca_rule_attribute_id = l_rule_attr_id
    GROUP BY mv.operator_id;

--+
--+ Variables Section
--+

   l_attr_prime_tbl		attr_prime_tbl_type;
   l_attr_operator_tbl		attr_operator_tbl_type;
   l_op_counter			NUMBER := 1;
   l_start_loc			NUMBER := 1;
   l_end_loc			NUMBER;
   l_string			VARCHAR2(2000);
   l_update_flag		VARCHAR2(1) := 'Y';
   l_delete_flag		VARCHAR2(1) := 'N';

BEGIN

   debugmsg('Find Comb : Beginning of the find_combinations procedure');

   --+
   --+ Assign a PRIME number for each ATTRIBUTE in a PL/SQL Table.
   --+

   l_string := '2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,'||
               '79,83,89,97,101,103,107,109,113,127,131,137,139,149,151,157,'||
	       '163,167,173,179,181,191,193,197,199,211,223,227,229,233,239,'||
	       '241,251,257,263,269,271,277,281,283,293,307,311,313,317,331,'||
	       '337,347,349,353,359,367,373,379,383,389,397,401,409,419,421,'||
	       '431,433,439,443,449,457,461,463,467,479,487,491,499,503,509,'||
	       '521,523,541,';
   FOR i IN 1..100 LOOP
      l_end_loc := INSTR(l_string,',',l_start_loc) - 1;
      l_attr_prime_tbl(i).prime_number
                := SUBSTR(l_string,l_start_loc,((l_end_loc - l_start_loc)+1));
      l_start_loc := l_end_loc + 2;
      l_attr_prime_tbl(i).attribute_name := 'ATTRIBUTE'||i;
   END LOOP;

   --+
   --+ Reset RULE_ATTR_COMB_ID in CN_SCA_DENORM_RULES and update with
   --+ Combinations.
   --+

   UPDATE cn_sca_denorm_rules
      SET rule_attr_comb_value = 1
    WHERE transaction_source = p_transaction_source
      AND org_id = p_org_id;
   --

   FOR rule_attr_rec IN rule_attr_cur
   LOOP
      FOR i IN 1..l_attr_prime_tbl.COUNT
      LOOP
         --
         IF (l_attr_prime_tbl(i).attribute_name =
	     rule_attr_rec.src_column_name) THEN
	    --+
	    --+ For the first occurance, I need to update the rule_attr_comb_value
	    --+ in cn_sca_denorm_rules table.
	    --+

	    IF (l_update_flag = 'Y') THEN

	       UPDATE cn_sca_denorm_rules
                  SET rule_attr_comb_value = 1
                WHERE transaction_source = p_transaction_source
		  AND org_id = p_org_id;

               --debugmsg('Find Comb : rule_attr_comb_value reset to 1 for '||SQL%ROWCOUNT);
	       l_update_flag := 'N';

	    END IF;

	    BEGIN

	       UPDATE cn_sca_denorm_rules dr
	          SET dr.rule_attr_comb_value =
		      dr.rule_attr_comb_value * l_attr_prime_tbl(i).prime_number
		WHERE dr.sca_credit_rule_id IN(
		      SELECT idr.sca_credit_rule_id
		        FROM cn_sca_denorm_rules idr,
			     cn_sca_conditions c
		       WHERE idr.ancestor_rule_id = c.sca_credit_rule_id
		         AND c.sca_rule_attribute_id = rule_attr_rec.sca_rule_attribute_id
			 AND idr.transaction_source = p_transaction_source
			 AND idr.org_id = p_org_id)
	          AND dr.transaction_source = p_transaction_source;

               --debugmsg('Find Comb : rule_attr_rec.sca_rule_attribute_id :'||rule_attr_rec.sca_rule_attribute_id);
               --debugmsg('Find Comb : Total Recs Updated in Denorm Table :'||SQL%ROWCOUNT);

            END;
	    l_delete_flag := 'Y';
	 END IF;
	 --
      END LOOP;
      --
   END LOOP;
   --
   -- Populate Rule Attributes associated with each distinct rule_attr_comb_id
   -- into cn_sca_combinations
   --
   IF (l_delete_flag = 'Y') THEN
      DELETE FROM cn_sca_combinations
       WHERE transaction_source = p_transaction_source
         AND org_id = p_org_id;
   --
      FOR get_attr_rec IN get_attr_cur
      LOOP
         INSERT INTO cn_sca_combinations(
	     sca_rule_attribute_id,
	     rule_attr_comb_value,
	     transaction_source,
	     created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             last_update_login,
	     org_id)
         SELECT sca_rule_attribute_id,
	        get_attr_rec.rule_attr_comb_value,
	        p_transaction_source,
                fnd_global.user_id,
                SYSDATE,
                fnd_global.user_id,
                SYSDATE,
                fnd_global.login_id,
                p_org_id
           FROM cn_sca_rule_cond_vals_mv mv
          WHERE mv.sca_credit_rule_id IN (
             SELECT sca_credit_rule_id
               FROM cn_sca_denorm_rules dr
              WHERE rule_attr_comb_value = get_attr_rec.rule_attr_comb_value
                AND dr.transaction_source = p_transaction_source
                AND dr.org_id = p_org_id
                AND rownum = 1)
          GROUP BY sca_rule_attribute_id;
      END LOOP;
      x_return_status := 'S';
   ELSE
      x_return_status := 'F';
   END IF;
   debugmsg('Find Comb : End of the find_combinations procedure');

EXCEPTION

   WHEN OTHERS THEN
      debugmsg('Find Comb : Exception');
      x_return_status := 'F';

END;
--
PROCEDURE populate_rule_denorm (
	errbuf         		OUT NOCOPY 	VARCHAR2,
	retcode        		OUT NOCOPY 	NUMBER,
   	p_txn_src		IN		VARCHAR2) IS

--+
--+ PL/SQL Tables and Records
--+

   TYPE credit_rule_id_tbl_type
   IS TABLE OF cn_sca_credit_rules.sca_credit_rule_id%TYPE;

   l_credit_rule_id_tbl		credit_rule_id_tbl_type;

--+
--+ Local Variables Section
--+

   l_max_rank			NUMBER;
   l_process_audit_id		NUMBER;
   conc_status     		BOOLEAN;
   l_api_version                CONSTANT NUMBER :=1.0;
   l_return_status              VARCHAR2(50);
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(2000);
   l_continue			VARCHAR2(1) := 'N';
   l_invalid_rules		NUMBER := 0;
   l_temp_org_id NUMBER;
   p_org_id NUMBER;

--+
--+ Exceptions
--+

   ex_invalid_rules		EXCEPTION;
   l_no_rule_ex			EXCEPTION;

--+
--+ Cursors Section
--+

CURSOR c1 IS
   SELECT *
     FROM cn_sca_denorm_rules csdr
    WHERE transaction_source = p_txn_src
      AND org_id = p_org_id
      AND EXISTS (
          SELECT 'S'
            FROM cn_sca_credit_rules  csca
           WHERE csca.sca_credit_rule_id = csdr.sca_credit_rule_id
             AND transaction_source = p_txn_src
             AND NVL(IS_DENORMED,'N') = 'N');

CURSOR c2 IS
   SELECT csca.sca_credit_rule_id
     FROM cn_sca_credit_rules  csca
    WHERE transaction_source = p_txn_src
      AND org_id = p_org_id
      AND NVL(IS_DENORMED,'N') = 'N';
--

BEGIN

   p_org_id := mo_global.get_current_org_id();

   cn_message_pkg.begin_batch (
	 x_process_type	         => 'SCA Rules Sync',
	 x_parent_proc_audit_id  => null,
	 x_process_audit_id	 => l_process_audit_id,
	 x_request_id		 => fnd_global.conc_request_id,
	 p_org_id		 => p_org_id);

   debugmsg('Rules Sync : Start of the Rules Synchronization');
   debugmsg('Rules Sync : l_process_audit_id - '||l_process_audit_id);
   debugmsg('Rules Sync: mo_global.get_current_org_id is - ' || p_org_id);

   --dbms_output.put_line('Rules Sync : l_process_audit_id - '||l_process_audit_id);

   --+
   --+ First Check whether any Credit Rules Exists without a valid
   --+ Credit Rule Attribute. If exists, then dynamic PL/SQL package
   --+ should not be recreated.
   --+

   SELECT count(1)
     INTO l_invalid_rules
     FROM cn_sca_conditions a,
          cn_sca_credit_rules b
    WHERE a.sca_credit_rule_id = b.sca_credit_rule_id
      AND b.org_id = p_org_id
      AND NOT EXISTS(
          SELECT 'X'
	    FROM cn_sca_rule_attributes c
	   WHERE a.sca_rule_attribute_id = c.sca_rule_attribute_id)
      AND b.transaction_source = p_txn_src;

   IF (l_invalid_rules > 0) THEN

      debugmsg('Rules Sync : Rules Exists without Rule Attributes');
      debugmsg('Rules Sync : Invalid Rule Count :'||l_invalid_rules);
      RAISE ex_invalid_rules;

   END IF;

   --+
   --+ First Check whether Credit Rules are available or not. This l_max_rank
   --+ will be used to find the calculated rank.
   --+

   BEGIN
      SELECT max(rank)
        INTO l_max_rank
	FROM cn_sca_credit_rules
       WHERE transaction_source = p_txn_src
         AND org_id = p_org_id;

      IF (l_max_rank IS NULL) THEN
         debugmsg('Rules Sync :  Base table rules not found. Deleting data from denorm table');
         BEGIN
	    DELETE FROM cn_sca_denorm_rules
	     WHERE transaction_source = p_txn_src
	       AND org_id = p_org_id;
	    debugmsg('Rules Sync : Deleted denorm rule count : '||SQL%ROWCOUNT);
	    debugmsg('Rules Sync : Refreshing MV');
            DBMS_MVIEW.REFRESH('CN_SCA_RULE_COND_VALS_MV','C','',TRUE,FALSE,0,4,0,TRUE);
	    debugmsg('Rules Sync : Refreshing MV completed');
	    COMMIT;
         EXCEPTION
            WHEN OTHERS THEN
               debugmsg('Results Transfer : Unexpected exception while refreshing MV');
         END;
	 RAISE l_no_rule_ex;
      END IF;
   END;

   --+
   --+ Delete existing records in the denorm table corresponds to
   --+ given transaction source
   --+

   debugmsg('Rules Sync : Deleting Existing Rules Based on the Flag');

   DELETE FROM cn_sca_denorm_rules csdr
    WHERE transaction_source = p_txn_src
      AND org_id = p_org_id
      AND (EXISTS
          (SELECT 'S'
             FROM cn_sca_credit_rules  csca
            WHERE csca.sca_credit_rule_id = csdr.sca_credit_rule_id
              AND NVL(IS_DENORMED,'N') = 'N')
       OR NOT EXISTS
         (SELECT 'S'
            FROM cn_sca_credit_rules  csca
           WHERE csca.sca_credit_rule_id = csdr.sca_credit_rule_id));

   debugmsg('Rules Sync : Total Rules Deleted - '||SQL%ROWCOUNT);
   debugmsg('Rules Sync : l_max_rank - '||l_max_rank);

   --+
   --+ Insert rules without parents and their entire hierarchy.
   --+

   INSERT INTO cn_sca_denorm_rules(
          sca_credit_rule_id,
	  ancestor_rule_id,
	  start_date,
	  end_date,
	  rank,
	  level_from_root,
	  relative_rank,
	  root_flag,
	  transaction_source,
          created_by,
	  creation_date,
	  last_updated_by,
	  last_update_date,
          last_update_login,
	  org_id)
   SELECT sca_credit_rule_id,
          sca_credit_rule_id,
	  start_date,
	  end_date,
	  rank,
	  level,
	  1/(NVL(DECODE(rank,0,0.1,rank),l_max_rank)*POWER(l_max_rank,level)), -- relative rank
	  DECODE(NVL(parent_rule_id,0),0,'Y','N'), -- root flag
          p_txn_src,
	  fnd_global.user_id,
	  SYSDATE,
	  fnd_global.user_id,
          SYSDATE,
	  fnd_global.login_id,
	  p_org_id
     FROM cn_sca_credit_rules cscr
    WHERE transaction_source = p_txn_src
      AND org_id = p_org_id
      AND NVL(IS_DENORMED,'N') = 'N'
  CONNECT BY PRIOR sca_credit_rule_id = parent_rule_id
    START WITH parent_rule_id IS NULL AND transaction_source = p_txn_src;

   debugmsg('Rules Sync : Parent Rules Insert Completed :'||SQL%ROWCOUNT);

   --+
   --+ Take each rule from denorm table and find all its ancestors
   --+

   IF (SQL%ROWCOUNT > 0) THEN
   debugmsg('Rules Sync : Identifying children for each parent');

   FOR c1_rec IN c1
   LOOP
      INSERT INTO cn_sca_denorm_rules(
             sca_credit_rule_id,
	     ancestor_rule_id,
	     start_date,
	     end_date,
	     rank,
	     level_from_root,
	     relative_rank,
	     root_flag,
	     transaction_source,
	     created_by,
	     creation_date,
	     last_updated_by,
	     last_update_date,
	     last_update_login,
	     org_id)
      SELECT c1_rec.sca_credit_rule_id,
             sca_credit_rule_id,
	     c1_rec.start_date,
             c1_rec.end_date,
	     c1_rec.rank,
	     c1_rec.level_from_root,
	     c1_rec.relative_rank,
	     c1_rec.root_flag,
	     p_txn_src,
             fnd_global.user_id,
	     SYSDATE,
	     fnd_global.user_id,
             SYSDATE,
	     fnd_global.login_id,
	     p_org_id
        FROM cn_sca_credit_rules
       WHERE sca_credit_rule_id <> c1_rec.sca_credit_rule_id
         AND transaction_source = p_txn_src
         AND org_id = p_org_id
     CONNECT BY PRIOR parent_rule_id = sca_credit_rule_id
       START WITH sca_credit_rule_id = c1_rec.sca_credit_rule_id
         AND transaction_source = p_txn_src;

      --+
      --+ Update calculated rank based on the relative ranks of the ancestors
      --+

      UPDATE cn_sca_denorm_rules
         SET calculated_rank = (
	 	SELECT SUM(r2.relative_rank)
	          FROM cn_sca_denorm_rules r1,
		       cn_sca_denorm_rules r2
		 WHERE r1.transaction_source = p_txn_src
		   AND r2.transaction_source = p_txn_src
		   AND r1.sca_credit_rule_id = c1_rec.sca_credit_rule_id
		   AND r2.sca_credit_rule_id = r1.ancestor_rule_id
		   AND r2.ancestor_rule_id = r1.ancestor_rule_id),
	     num_rule_attributes = (
	        SELECT count(distinct c.sca_rule_attribute_id)
		  FROM cn_sca_denorm_rules r,
		       cn_sca_credit_rules s,
		       cn_sca_conditions  c
		 WHERE r.transaction_source = p_txn_src
		   AND s.transaction_source = p_txn_src
		   AND r.sca_credit_rule_id = c1_rec.sca_credit_rule_id
		   AND r.ancestor_rule_id = s.sca_credit_rule_id
		   AND s.sca_credit_rule_id = c.sca_credit_rule_id)
       WHERE transaction_source = p_txn_src
         AND sca_credit_rule_id = c1_rec.sca_credit_rule_id
	 AND org_id = p_org_id;

      --+
      --+ Resetting the is_denormed flag
      --+

      UPDATE cn_sca_credit_rules
         SET is_denormed     = 'Y'
       WHERE sca_credit_rule_id = c1_rec.sca_credit_rule_id
         AND transaction_source = p_txn_src
	 AND org_id = p_org_id;

   END LOOP;
   END IF;

   --+
   --+ Refresh the MVs
   --+

   debugmsg('Rules Sync : Start of the MV Refresh');

   BEGIN
      DBMS_MVIEW.REFRESH('CN_SCA_RULE_COND_VALS_MV','C','',TRUE,FALSE,0,4,0,TRUE);
   EXCEPTION
      WHEN OTHERS THEN
         debugmsg('Results Transfer : Unexpected exception');
         RAISE;
   END;

   debugmsg('Rules Sync : End of the MV Refresh');

   --+
   --+ Update Rule Attribute Combinations
   --+

   debugmsg('Rules Sync : Start of Updating Rule Combination ID');

   cn_sca_denorm_rules_pvt.find_combinations(
      		p_txn_src,
      		p_org_id,
		l_return_status);

   IF (l_return_status <> 'S') THEN
      debugmsg('Rules Sync : Error While Updating Rule Combinations');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   debugmsg('Rules Sync : End of Updating Rule Combination ID');

   --+
   --+ Creating Dynamic SQL Packages for Online and Batch Mode
   --+

   debugmsg('Rules Sync : Starting Batch Mode Dynamic Package Creation');

      cn_sca_rules_batch_gen_pvt.gen_sca_rules_batch_dyn(
        	p_api_version           => l_api_version,
        	x_return_status         => l_return_status,
        	x_msg_count             => l_msg_count,
        	x_msg_data              => l_msg_data,
        	x_transaction_source    => p_txn_src,
		p_org_id 		=> p_org_id);
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         debugmsg('SCA Rules Sync: Error While Creating Batch Dynamic Package');
	 RAISE FND_API.G_EXC_ERROR;
      END IF;

   debugmsg('Rules Sync : Starting Online Mode Dynamic Package Creation');

      cn_sca_rules_online_gen_pvt.gen_sca_rules_onln_dyn(
        	p_api_version           => l_api_version,
        	x_return_status         => l_return_status,
        	x_msg_count             => l_msg_count,
        	x_msg_data              => l_msg_data,
        	x_transaction_source    => p_txn_src,
		p_org_id 		=> p_org_id);
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         debugmsg('Rules Sync : Error While Creating Online Dynamic Package');
	 RAISE FND_API.G_EXC_ERROR;
      END IF;

   debugmsg('Rules Sync : Ending Online Mode Dynamic Package Creation');
   --
   COMMIT;
   --
   retcode := 0;
   errbuf  := 'Rules Synchronization Completed Successfully';
   debugmsg('Rules Synchronization Completed Successfully');
   cn_message_pkg.end_batch(l_process_audit_id);
   --

EXCEPTION

   WHEN ex_invalid_rules THEN
      ROLLBACK;
      cn_message_pkg.end_batch(l_process_audit_id);
      debugmsg('Rules Sync : Exception: ex_invalid_rules');
      conc_status := fnd_concurrent.set_completion_status(
			status 	=> 'ERROR',
            		message => '');

   WHEN l_no_rule_ex THEN
      ROLLBACK;
      debugmsg('Rules Sync : No Rules available in CN_SCA_CREDIT_RULES table');
      cn_message_pkg.end_batch(l_process_audit_id);
      conc_status := fnd_concurrent.set_completion_status(
			status 	=> 'ERROR',
            		message => '');

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK;
      debugmsg('Rules Sync : Execution Error');
      cn_message_pkg.end_batch(l_process_audit_id);
      conc_status := fnd_concurrent.set_completion_status(
			status 	=> 'ERROR',
            		message => '');

   WHEN OTHERS THEN
      ROLLBACK;
      debugmsg('Rules Sync : Unexpected exception');
      debugmsg('Oracle Error: '||SQLERRM);
      cn_message_pkg.end_batch(l_process_audit_id);
      conc_status := fnd_concurrent.set_completion_status(
			status 	=> 'ERROR',
            		message => '');
END;
--
END;

/
