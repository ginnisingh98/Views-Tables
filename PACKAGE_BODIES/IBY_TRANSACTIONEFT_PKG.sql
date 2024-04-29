--------------------------------------------------------
--  DDL for Package Body IBY_TRANSACTIONEFT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_TRANSACTIONEFT_PKG" AS
/*$Header: ibyteftb.pls 120.31.12010000.11 2009/12/03 12:26:33 sgogula ship $*/

  --
  -- Declare global variables
  --
  G_CURRENT_RUNTIME_LEVEL      CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_TRANSACTIONEFT_PKG';

/*--------------------------------------------------------------------
|  Name :  createLogicalGroups
|
|  Purpose : To create logical groups in Funds Capture Instruction (for SEPA)
|
|  Parameters:
|   IN:
|   x_batches_tab -- Table of Funds Capture instruction
|
|   OUT:
|   N/A
|
|
|
*-----------------------------------------------------------------------*/
PROCEDURE createLogicalGroups(
x_batches_tab IN IBY_TRANSACTIONCC_PKG.batchAttrTabType
)
IS

select_clause VARCHAR(4000);
into_clause   VARCHAR(4000);
from_clause   VARCHAR(4000);
where_clause  VARCHAR(4000);
order_clause  VARCHAR(4000);

l_grouping_mode varchar2(40);
l_grp_cntr NUMBER;

l_mbatch_id IBY_BATCHES_ALL.mbatchid%TYPE;
l_logical_group_reference  iby_trxn_summaries_all.logical_group_reference%TYPE;
l_module_name  VARCHAR2(200)  := G_PKG_NAME || '.createLogicalGroups';

prev_org_id                   iby_trxn_summaries_all.org_id%TYPE;
prev_legal_entity_id          iby_trxn_summaries_all.legal_entity_id%TYPE;
prev_payeeinstrid             iby_trxn_summaries_all.payeeinstrid%TYPE;
prev_currencynamecode         iby_trxn_summaries_all.currencynamecode%TYPE;
prev_settledate               iby_trxn_summaries_all.settledate%TYPE;
prev_category_purpose         iby_trxn_summaries_all.category_purpose%TYPE;
prev_seq_type                 iby_trxn_summaries_all.seq_type%TYPE;
prev_service_level            iby_trxn_summaries_all.service_level%TYPE;
prev_localinstr               iby_trxn_summaries_all.localinstr%TYPE;
prev_bank_charge_bearer_code  iby_trxn_summaries_all.bank_charge_bearer_code%TYPE;


TYPE type_trxnmid  IS TABLE OF
     IBY_TRXN_SUMMARIES_ALL.trxnmid%TYPE
     INDEX BY BINARY_INTEGER;
t_trxnmid type_trxnmid;

TYPE type_org_id  IS TABLE OF
     IBY_TRXN_SUMMARIES_ALL.org_id%TYPE
     INDEX BY BINARY_INTEGER;
t_org_id type_org_id;

TYPE type_legal_entity_id  IS TABLE OF
     IBY_TRXN_SUMMARIES_ALL.legal_entity_id%TYPE
     INDEX BY BINARY_INTEGER;
t_legal_entity_id type_legal_entity_id;

TYPE type_payeeinstrid  IS TABLE OF
     IBY_TRXN_SUMMARIES_ALL.payeeinstrid%TYPE
     INDEX BY BINARY_INTEGER;
t_payeeinstrid type_payeeinstrid;

TYPE type_currencynamecode  IS TABLE OF
     IBY_TRXN_SUMMARIES_ALL.currencynamecode%TYPE
     INDEX BY BINARY_INTEGER;
t_currencynamecode type_currencynamecode;

TYPE type_settledate  IS TABLE OF
     IBY_TRXN_SUMMARIES_ALL.settledate%TYPE
     INDEX BY BINARY_INTEGER;
t_settledate type_settledate;

TYPE type_category_purpose  IS TABLE OF
     IBY_TRXN_SUMMARIES_ALL.category_purpose%TYPE
     INDEX BY BINARY_INTEGER;
t_category_purpose type_category_purpose;

TYPE type_seq_type  IS TABLE OF
     IBY_TRXN_SUMMARIES_ALL.seq_type%TYPE
     INDEX BY BINARY_INTEGER;
t_seq_type type_seq_type;

TYPE type_service_level  IS TABLE OF
     IBY_TRXN_SUMMARIES_ALL.service_level%TYPE
     INDEX BY BINARY_INTEGER;
t_service_level type_service_level;

TYPE type_localinstr  IS TABLE OF
     IBY_TRXN_SUMMARIES_ALL.localinstr%TYPE
     INDEX BY BINARY_INTEGER;
t_localinstr type_localinstr;

TYPE type_bank_charge_bearer_code  IS TABLE OF
     IBY_TRXN_SUMMARIES_ALL.bank_charge_bearer_code%TYPE
     INDEX BY BINARY_INTEGER;
t_bank_charge_bearer_code type_bank_charge_bearer_code;

TYPE type_logical_group_reference IS TABLE OF
     IBY_TRXN_SUMMARIES_ALL.logical_group_reference%TYPE
     INDEX BY BINARY_INTEGER;
t_logical_group_reference type_logical_group_reference;

BEGIN

  print_debuginfo(l_module_name, 'ENTER');

  /* Only 'MIXD' grouping mode is supported now */
  l_grouping_mode := 'MIXD';

  FOR i in  x_batches_tab.FIRST ..  x_batches_tab.LAST LOOP

        l_mbatch_id := x_batches_tab(i).mbatch_id;

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	  print_debuginfo(l_module_name, 'Instruction: '
             || l_mbatch_id || ', Grouping Mode: '
             || l_grouping_mode);
	END IF;

        IF (l_grouping_mode IS NOT NULL) THEN
        IF l_grouping_mode = 'MIXD' THEN

        /* The previous values are made to hold '' so that the
         * first transaction in a batch
         * always has a new logical group id
         */

           prev_org_id :='';
           prev_legal_entity_id :='';
           prev_payeeinstrid :='';
           prev_currencynamecode :='';
           prev_settledate :='';
           prev_category_purpose :='';
           prev_seq_type :='';
           prev_service_level :='';
           prev_localinstr :='';
           prev_bank_charge_bearer_code :='';

           from_clause   :=' FROM IBY_TRXN_SUMMARIES_ALL';
	   where_clause := ' WHERE mbatchid = ' || l_mbatch_id;

           order_clause  := ' ORDER BY ';
           order_clause     := order_clause || ' org_id , legal_entity_id, payeeinstrid, currencynamecode, settledate, ';
           order_clause     := order_clause || ' category_purpose , seq_type, service_level, localinstr, bank_charge_bearer_code ';

           select_clause := 'SELECT TRXNMID
	                          , org_id
                                  , legal_entity_id
                                  , payeeinstrid
                                  , currencynamecode
				  , settledate
				  , category_purpose
				  , seq_type
				  , service_level
				  , localinstr
				  , bank_charge_bearer_code'
                                 ;

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              print_debuginfo(l_module_name, 'select_clause: '
                   || select_clause);
              print_debuginfo(l_module_name, 'from_clause: '
                   || from_clause);
              print_debuginfo(l_module_name, 'where_clause: '
                   || where_clause);
              print_debuginfo(l_module_name, 'order_clause: '
                   || order_clause);
           END IF;


           EXECUTE IMMEDIATE select_clause
                          || from_clause
                          || where_clause
                          || order_clause
           BULK COLLECT INTO  t_trxnmid
	                      ,t_org_id
			      ,t_legal_entity_id
			      ,t_payeeinstrid
			      ,t_currencynamecode
			      ,t_settledate
			      ,t_category_purpose
			      ,t_seq_type
			      ,t_service_level
			      ,t_localinstr
			      ,t_bank_charge_bearer_code
			      ;

           l_grp_cntr            := 0;

           FOR j in t_trxnmid.FIRST .. t_trxnmid.LAST
           LOOP

               IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN

	          print_debuginfo(l_module_name, 'current record: t_trxnmid'|| t_trxnmid(j) || ',t_org_id'
                    || t_org_id(j)|| ',t_legal_entity_id '|| t_legal_entity_id(j)
                    || ',t_payeeinstrid ' ||  t_payeeinstrid(j)
		    || ',t_currencynamecode ' ||  t_currencynamecode(j)
		    || ',t_settledate ' ||  t_settledate(j)
		    || ',t_category_purpose ' ||  t_category_purpose(j)
		    || ',t_seq_type ' ||  t_seq_type(j)
		    || ',t_service_level ' ||  t_service_level(j)
		    || ',t_localinstr ' ||  t_localinstr(j)
		    || ',t_bank_charge_bearer_code ' ||  t_bank_charge_bearer_code(j)
		   ) ;

	          print_debuginfo(l_module_name, 'previous record: prev_org_id '|| prev_org_id
                    ||  ',prev_legal_entity_id  '|| prev_legal_entity_id
                    || ',prev_payeeinstrid ' ||  prev_payeeinstrid
		    || ',prev_currencynamecode ' ||  prev_currencynamecode
		    || ',prev_settledate ' ||  prev_settledate
		    || ',prev_category_purpose  ' ||  prev_category_purpose
		    || ',prev_seq_type ' ||  prev_seq_type
		    || ',prev_service_level ' ||  prev_service_level
		    || ',prev_localinstr ' ||  prev_localinstr
		    || ',prev_bank_charge_bearer_code ' ||  prev_bank_charge_bearer_code
		   ) ;

              END IF;

              IF   t_org_id(j)             = prev_org_id
                 AND t_legal_entity_id(j)  = prev_legal_entity_id
                 AND t_payeeinstrid(j)     = prev_payeeinstrid
                 AND t_currencynamecode(j) = prev_currencynamecode
                 AND t_settledate(j)       = prev_settledate
                 AND t_category_purpose(j) = prev_category_purpose
                 AND t_seq_type(j)         = prev_seq_type
                 AND t_service_level(j)    = prev_service_level
                 AND t_localinstr(j)       = prev_localinstr
                 AND t_bank_charge_bearer_code(j) = prev_bank_charge_bearer_code

              THEN
                 t_logical_group_reference(j)     := l_logical_group_reference;
                 print_debuginfo(l_module_name, 'The prev and current trxns have same grouping attributes. trxnmid: '
                   || t_trxnmid(j) || ', logical_grp_ref: '
                   || t_logical_group_reference(j));

              ELSE
                 prev_org_id           := t_org_id(j);
                 prev_legal_entity_id  := t_legal_entity_id(j);
                 prev_payeeinstrid     := t_payeeinstrid(j);
                 prev_currencynamecode := t_currencynamecode(j);
                 prev_settledate       := t_settledate(j);
                 prev_category_purpose := t_category_purpose(j);
                 prev_seq_type         := t_seq_type(j);
                 prev_service_level    := t_service_level(j);
                 prev_localinstr       := t_localinstr(j);
                 prev_bank_charge_bearer_code := t_bank_charge_bearer_code(j);

		 l_grp_cntr                       := l_grp_cntr + 1;
                 l_logical_group_reference        := l_mbatch_id ||'_'|| l_grp_cntr;
                 t_logical_group_reference(j)     := l_logical_group_reference;
                 print_debuginfo(l_module_name, ' The prev and current trxn have diff grouping attributes. trxnmid: '
                   || t_trxnmid(j) || ', logical_grp_ref: '
                   || t_logical_group_reference(j));

              END IF;
           END LOOP;

           FORALL j IN t_trxnmid.FIRST .. t_trxnmid.LAST
              UPDATE IBY_TRXN_SUMMARIES_ALL
                 SET logical_group_reference =  t_logical_group_reference(j)
               WHERE trxnmid  = t_trxnmid(j);

        END IF;
      END IF;
  END LOOP;

END createLogicalGroups;

/*
 * The purpose of this procedure is to check if there is any open
 * transaction which are due.  If there is, it will insert a row into
 * the iby_batches_all table to keep track of the batch status, and
 * change the transactions status to other status. So, the open
 * transactions will be sent as part of future batch close. Also, it
 * will not allow any modification and cancellation to these transactions.
 */
PROCEDURE createBatchCloseTrxns(
            merch_batchid_in     IN    VARCHAR2,
            merchant_id_in       IN    VARCHAR2,
            vendor_id_in         IN    NUMBER,
            vendor_key_in        IN    VARCHAR2,
            newstatus_in         IN    NUMBER,
            oldstatus_in         IN    NUMBER,
            batchstate_in        IN    NUMBER,
            settlement_date_in   IN    DATE,
            req_type_in          IN    VARCHAR2,
            numtrxns_out         OUT   NOCOPY NUMBER
            )
   IS

   numrows NUMBER;
   l_mpayeeid iby_payee.mpayeeid%type;
   l_mbatchid iby_batches_all.mbatchid%type;

   BEGIN

   SELECT
       COUNT(*)
   INTO
       numtrxns_out
   FROM
       iby_trxn_summaries_all
   WHERE
       status  = oldstatus_in   AND
       payeeid = merchant_id_in AND
       bepid   = vendor_id_in   AND
       bepkey  = vendor_key_in  AND
       batchid IS NULL          AND
       trunc(settledate) <= trunc(settlement_date_in) AND
       instrtype = 'BANKACCOUNT';

   /*
    * If there isn't any open transactions, then exit.
    */
   IF (numtrxns_out > 0) THEN

      SELECT
          iby_batches_s.NEXTVAL
      INTO
          l_mbatchid
      FROM
          DUAL;

      iby_accppmtmthd_pkg.getMPayeeId(merchant_id_in, l_mpayeeid);
      -- Bug:8363526 : Inserting new column settledate VALUE:sysdate
      INSERT INTO iby_batches_all
         (MBATCHID,
          BATCHID,
          MPAYEEID,
          PAYEEID,
          BEPID,
          BEPKEY,
          BATCHSTATUS,
          BATCHSTATEID,
          BATCHCLOSEDATE,
          REQTYPE,
          REQDATE,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          OBJECT_VERSION_NUMBER,
          SENTCOUNTER,
          SENTCOUNTERDAILY
          ,settledate          )
      VALUES
         (
         l_mbatchid,
         merch_batchid_in,
         l_mpayeeid,
         merchant_id_in,
         vendor_id_in,
         vendor_key_in,
         batchstate_in,
         batchstate_in,
         settlement_date_in,
         req_type_in,
         sysdate,
         sysdate,
         fnd_global.user_id,
         sysdate,
         fnd_global.user_id,
         fnd_global.login_id,
         0,
         0,
         0
         ,sysdate);

      UPDATE
         IBY_TRXN_SUMMARIES_ALL
      SET
         status                = newstatus_in,
         batchid               = merch_batchid_in,
         mbatchid              = l_mbatchid,
         last_update_date      = sysdate,
         updatedate            = sysdate,
         last_updated_by       = fnd_global.user_id,
         object_version_number = object_version_number + 1
      WHERE
         status = oldstatus_in    AND
         payeeid = merchant_id_in AND
         bepid = vendor_id_in     AND
         bepkey = vendor_key_in   AND
         batchid IS NULL          AND
         trunc(settledate) <= trunc(settlement_date_in) AND
         instrtype = 'BANKACCOUNT'
         ;

      COMMIT;

   END IF;

END createBatchCloseTrxns;

/*
 * The purpose of this procedure is to check if there is any open
 * transaction which are due.  If there is, it will insert a row into
 * the iby_batches_all table to keep track of the batch status, and
 * change the transactions status to other status. So, the open
 * transactions will be sent as part of future batch close. Also, it
 * will not allow any modification and cancellation to these transactions.
 */
PROCEDURE createBatchCloseTrxnsNew(
            merch_batchid_in     IN    VARCHAR2,
            profile_code_in      IN    iby_batches_all.
                                           process_profile_code%TYPE,
            merchant_id_in       IN    VARCHAR2,
            vendor_id_in         IN    NUMBER,
            vendor_key_in        IN    VARCHAR2,
            newstatus_in         IN    NUMBER,
            oldstatus_in         IN    NUMBER,
            batchstate_in        IN    NUMBER,
            settlement_date_in   IN    DATE,
            req_type_in          IN    VARCHAR2,
            instr_type_in        IN    iby_batches_all.
                                           instrument_type%TYPE,
            br_disputed_flag_in  IN    iby_batches_all.
                                           br_disputed_flag%TYPE,
            f_pmt_channel_in     IN    iby_trxn_summaries_all.
                                           payment_channel_code%TYPE,
            f_curr_in            IN    iby_trxn_summaries_all.
                                           currencynamecode%TYPE,
            f_settle_date        IN    iby_trxn_summaries_all.
                                           settledate%TYPE,
            f_due_date           IN    iby_trxn_summaries_all.
                                           settlement_due_date%TYPE,
            f_maturity_date      IN    iby_trxn_summaries_all.
                                           br_maturity_date%TYPE,
            f_instr_type         IN    iby_trxn_summaries_all.
                                           instrtype%TYPE,
            numtrxns_out         OUT   NOCOPY NUMBER,
            mbatch_ids_out       OUT   NOCOPY JTF_NUMBER_TABLE,
            batch_ids_out        OUT   NOCOPY JTF_VARCHAR2_TABLE_100
            )
   IS

   numrows NUMBER;
   l_mpayeeid iby_payee.mpayeeid%type;
   l_mbatchid iby_batches_all.mbatchid%type;
   l_module_name CONSTANT VARCHAR2(200) :=
       G_PKG_NAME || '.createBatchCloseTrxnsNew';

   l_batches_tab         IBY_TRANSACTIONCC_PKG.batchAttrTabType;
   l_trxns_in_batch_tab  IBY_TRANSACTIONCC_PKG.trxnsInBatchTabType;

   l_index  NUMBER;

   l_system_prof_code   iby_fndcpt_sys_eft_pf_b.funds_xfer_format_code%type;

   BEGIN

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name, 'ENTER');

   END IF;
   mbatch_ids_out := JTF_NUMBER_TABLE();
   batch_ids_out  := JTF_VARCHAR2_TABLE_100();

   /*
    * BEP and vendor related params.
    */
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name, 'vendor_id_in: '
	       || vendor_id_in);
	   print_debuginfo(l_module_name, 'vendor_key_in: '
	       || vendor_key_in);
	   print_debuginfo(l_module_name, 'merchant_id_in: '
	       || merchant_id_in);
	   print_debuginfo(l_module_name, 'req_type_in: '
	       || req_type_in);
	   print_debuginfo(l_module_name, 'profile_code_in: '
	       || profile_code_in);
	   print_debuginfo(l_module_name, 'settlement_date_in: '
	       || settlement_date_in);
	   print_debuginfo(l_module_name, 'oldstatus_in: '
	       || oldstatus_in);

   END IF;
   SELECT
       COUNT(*)
   INTO
       numtrxns_out
   FROM
       iby_trxn_summaries_all
   WHERE
       status  = oldstatus_in   AND
       payeeid = merchant_id_in AND
       bepid   = vendor_id_in   AND
       bepkey  = vendor_key_in  AND
       batchid IS NULL          AND
       trunc(nvl(settledate, sysdate)) <= trunc(nvl(settlement_date_in, sysdate-1)) AND
       instrtype = 'BANKACCOUNT';

   /*
    * If there isn't any open transactions, then exit.
    */
   IF (numtrxns_out > 0) THEN

       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo(l_module_name, 'Invoking grouping ..');

       END IF;
       /*
        * Group all the transactions for this profile into
        * batches as per the grouping attributes on the profile.
        */
       IBY_TRANSACTIONCC_PKG.performTransactionGrouping(
           instr_type_in,
           req_type_in,
           f_pmt_channel_in,
           f_curr_in,
           f_settle_date,
           f_due_date,
           f_maturity_date,
           f_instr_type,
	   merch_batchid_in,
           l_batches_tab,
           l_trxns_in_batch_tab
           );

       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo(l_module_name, '# batches created: '
	           || l_batches_tab.COUNT);

	       print_debuginfo(l_module_name, '# transactions processed: '
	           || l_trxns_in_batch_tab.COUNT);

       END IF;
       /*
        * After grouping it is possible that multiple batches were
        * created. Each batch will be a separate row in the
        * IBY_BATCHES_ALL table with a unique mbatchid.
        *
        * The user may have provided a batch id (batch prefix), we will
        * have to assign that batch id to each of the created batches.
        *
        * This batch id would be sent to the payment system. It therefore
        * has to be unique. Therefore, we add a suffix to the user
        * provided batch id to ensure that batches created after grouping
        * have a unique batch id.
        */
       IF (l_batches_tab.COUNT > 0) THEN

           l_index := 1;
           FOR k IN l_batches_tab.FIRST .. l_batches_tab.LAST LOOP

               /*
                * Assign a unique batch id to each batch.
                */
               l_batches_tab(k).batch_id :=
                   merch_batchid_in ||'_'|| l_index;
               l_index := l_index + 1;

           END LOOP;

       END IF;

       /* Perform the logical grouping of transactions for SEPA
          Chk the format based on the profile code
	  If it contains SEPA, then create the logical grouping.
       */

       SELECT sp.funds_xfer_format_code
	 INTO  l_system_prof_code
	 FROM iby_fndcpt_user_eft_pf_b up
	       ,iby_fndcpt_sys_eft_pf_b sp
	WHERE up.sys_eft_profile_code =  sp.sys_eft_profile_code
	  AND up.user_eft_profile_code = profile_code_in;

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Fetched Format ' || l_system_prof_code );
        END IF;

        IF (instr( l_system_prof_code, 'SEPA') >0)
	    THEN
            createLogicalGroups(l_batches_tab);
        END IF;

	/* Logical grouping of transactions for SEPA - END  */

       /*
        * After grouping, the transactions will be assigned a mbatch id.
        * Assign them a batch id as well (based on the batch id
        * corresponding to each mbatch id).
        */
       IF (l_trxns_in_batch_tab.COUNT > 0) THEN

           FOR m IN l_trxns_in_batch_tab.FIRST ..
                     l_trxns_in_batch_tab.LAST LOOP

               FOR k IN l_batches_tab.FIRST .. l_batches_tab.LAST LOOP

                   /*
                    * Find the mbatch id in the batches array
                    * corresponding to the mbatchid of this transaction.
                    */
                   IF (l_trxns_in_batch_tab(m).mbatch_id =
                             l_batches_tab(k).mbatch_id) THEN

                       /*
                        * Assign the batch id from the batches array
                        * to this transaction.
                        */
                       l_trxns_in_batch_tab(m).batch_id :=
                           l_batches_tab(k).batch_id;

                   END IF;

               END LOOP;

           END LOOP;

       END IF;


      /*

      SELECT
          iby_batches_s.NEXTVAL
      INTO
          l_mbatchid
      FROM
          DUAL;
      */

      iby_accppmtmthd_pkg.getMPayeeId(merchant_id_in, l_mpayeeid);

      IF (l_batches_tab.COUNT <> 0) THEN

          FOR i IN l_batches_tab.FIRST .. l_batches_tab.LAST LOOP

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	              print_debuginfo(l_module_name, 'Going to insert batch '
	                  || l_batches_tab(i).mbatch_id);

              END IF;
              INSERT INTO iby_batches_all
                 (MBATCHID,
                  BATCHID,
                  MPAYEEID,
                  PAYEEID,
                  BEPID,
                  BEPKEY,
                  BATCHSTATUS,
                  BATCHSTATEID,
                  BATCHCLOSEDATE,
                  REQTYPE,
                  REQDATE,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATE_LOGIN,
                  OBJECT_VERSION_NUMBER,
                  SENTCOUNTER,
                  SENTCOUNTERDAILY,
                  PROCESS_PROFILE_CODE,
                  INSTRUMENT_TYPE,
                  BR_DISPUTED_FLAG,
                  CURRENCYNAMECODE,
                  PAYEEINSTRID,
                  LEGAL_ENTITY_ID,
                  ORG_ID,
                  ORG_TYPE,
                  SETTLEDATE
                  )
              VALUES
                 (
                 l_batches_tab(i).mbatch_id,
                 merch_batchid_in || '_' || i,
                 l_mpayeeid,
                 merchant_id_in,
                 vendor_id_in,
                 l_batches_tab(i).bep_key,
                 batchstate_in,
                 batchstate_in,
                 settlement_date_in,
                 req_type_in,
                 sysdate,
                 sysdate,
                 fnd_global.user_id,
                 sysdate,
                 fnd_global.user_id,
                 fnd_global.login_id,
                 0,
                 0,
                 0,
                 l_batches_tab(i).profile_code,
                 instr_type_in,
                 br_disputed_flag_in,

                 /*
                  * Fix for bug 5614670:
                  *
                  * Populate the batch related attributes
                  * created after grouping in this
                  * insert.
                  */
                 l_batches_tab(i).curr_code,
                 l_batches_tab(i).int_bank_acct_id,
                 l_batches_tab(i).le_id,
                 l_batches_tab(i).org_id,
                 l_batches_tab(i).org_type,
                 l_batches_tab(i).settle_date
                 );

                 validate_open_batch(
                     vendor_id_in,
                     l_batches_tab(i).mbatch_id);

              /*
               * Store the created mbatchids in the output param
               * to return to the caller.
               */
              mbatch_ids_out.EXTEND;
              mbatch_ids_out(i) := l_batches_tab(i).mbatch_id;

              /*
               * Store the created batchids in the output param
               * to return to the caller.
               */
              batch_ids_out.EXTEND;
              batch_ids_out(i) := l_batches_tab(i).batch_id;

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	              print_debuginfo(l_module_name, 'Finished insert batch '
	                  || l_batches_tab(i).mbatch_id);

              END IF;
          END LOOP;

      END IF; -- if l_batches_tab.COUNT <> 0

      IF (l_trxns_in_batch_tab.COUNT <> 0) THEN

          FOR i IN l_trxns_in_batch_tab.FIRST .. l_trxns_in_batch_tab.LAST LOOP

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	              print_debuginfo(l_module_name, 'Going to update transaction '
	                  || l_trxns_in_batch_tab(i).trxn_id);

              END IF;
              UPDATE
                 IBY_TRXN_SUMMARIES_ALL
              SET
                 status                = newstatus_in,
                 batchid               = l_trxns_in_batch_tab(i).batch_id,
                 mbatchid              = l_trxns_in_batch_tab(i).mbatch_id,
                 last_update_date      = sysdate,
                 updatedate            = sysdate,
                 last_updated_by       = fnd_global.user_id,
                 object_version_number = object_version_number + 1
              WHERE
                 transactionid = l_trxns_in_batch_tab(i).trxn_id AND
                 status        = iby_transactioncc_pkg.C_STATUS_OPEN_BATCHED
                 ;

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	              print_debuginfo(l_module_name, 'Finished updating transaction'
	                  || l_trxns_in_batch_tab(i).trxn_id);

              END IF;
          END LOOP;

      END IF; -- if l_trxns_in_batch_tab.COUNT <> 0

      COMMIT;

   ELSE

       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo(l_module_name, 'No open transactions; Exiting ..');

       END IF;
   END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name, 'mbatchids count: '
	       || mbatch_ids_out.COUNT);

	   print_debuginfo(l_module_name, 'EXIT');

   END IF;
END createBatchCloseTrxnsNew;

/*
 * This is the overloaded form of the previous API. This takes an array of
 * profile codes as input parameter (instead of a single one)
 * The purpose of this procedure is to check if there is any open
 * transaction which are due.  If there is, it will insert a row into
 * the iby_batches_all table to keep track of the batch status, and
 * change the transactions status to other status. So, the open
 * transactions will be sent as part of future batch close. Also, it
 * will not allow any modification and cancellation to these transactions.
 */
PROCEDURE createBatchCloseTrxnsNew(
            merch_batchid_in     IN    VARCHAR2,
            profile_code_array   IN    JTF_VARCHAR2_TABLE_100,
            merchant_id_in       IN    VARCHAR2,
            vendor_id_in         IN    NUMBER,
            vendor_key_in        IN    VARCHAR2,
            newstatus_in         IN    NUMBER,
            oldstatus_in         IN    NUMBER,
            batchstate_in        IN    NUMBER,
            settlement_date_in   IN    DATE,
            req_type_in          IN    VARCHAR2,
            instr_type_in        IN    iby_batches_all.
                                           instrument_type%TYPE,
            br_disputed_flag_in  IN    iby_batches_all.
                                           br_disputed_flag%TYPE,
            f_pmt_channel_in     IN    iby_trxn_summaries_all.
                                           payment_channel_code%TYPE,
            f_curr_in            IN    iby_trxn_summaries_all.
                                           currencynamecode%TYPE,
            f_settle_date        IN    iby_trxn_summaries_all.
                                           settledate%TYPE,
            f_due_date           IN    iby_trxn_summaries_all.
                                           settlement_due_date%TYPE,
            f_maturity_date      IN    iby_trxn_summaries_all.
                                           br_maturity_date%TYPE,
            f_instr_type         IN    iby_trxn_summaries_all.
                                           instrtype%TYPE,
            numtrxns_out         OUT   NOCOPY NUMBER,
            mbatch_ids_out       OUT   NOCOPY JTF_NUMBER_TABLE,
            batch_ids_out        OUT   NOCOPY JTF_VARCHAR2_TABLE_100
            )
   IS

   numrows NUMBER;
   l_mpayeeid iby_payee.mpayeeid%type;
   l_mbatchid iby_batches_all.mbatchid%type;
   l_module_name CONSTANT VARCHAR2(200) :=
       G_PKG_NAME || '.createBatchCloseTrxnsNew';

   l_batches_tab         IBY_TRANSACTIONCC_PKG.batchAttrTabType;
   l_trxns_in_batch_tab  IBY_TRANSACTIONCC_PKG.trxnsInBatchTabType;
   numProfCodes NUMBER;
   strProfCodes VARCHAR2(200);
   l_cursor_stmt VARCHAR2(1000);
   TYPE dyn_transactions       IS REF CURSOR;
   l_trxn_cursor               dyn_transactions;

   l_index  NUMBER;
   l_system_prof_code   iby_fndcpt_sys_eft_pf_b.funds_xfer_format_code%type;

   BEGIN

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name, 'ENTER');

   END IF;
   /* Form a comma separated string for the bepkeys */
     numProfCodes := profile_code_array.count;
     FOR i IN 1..(numProfCodes-1) LOOP
        strProfCodes := strProfCodes||''''||profile_code_array(i)||''',';
     END LOOP;
     /* Append the last profile code without comma at the end */
     strProfCodes := strProfCodes||''''||profile_code_array(numProfCodes)||'''';

   mbatch_ids_out := JTF_NUMBER_TABLE();
   batch_ids_out  := JTF_VARCHAR2_TABLE_100();

   /*
    * BEP and vendor related params.
    */
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name, 'vendor_id_in: '
	       || vendor_id_in);
	   print_debuginfo(l_module_name, 'vendor_key_in: '
	       || vendor_key_in);
	   print_debuginfo(l_module_name, 'merchant_id_in: '
	       || merchant_id_in);
	   print_debuginfo(l_module_name, 'req_type_in: '
	       || req_type_in);
	   print_debuginfo(l_module_name, 'profile codes (as comma separated string): '
	       || strProfCodes);
	   print_debuginfo(l_module_name, 'settlement_date_in: '
	       || settlement_date_in);
	   print_debuginfo(l_module_name, 'oldstatus_in: '
	       || oldstatus_in);
   END IF;
/*
 * We won't be using this cursor. Instead we will be using the reference
 * cursor written below. The cursor fetches the transactions based on the
 * profile codes rather than bepkey.
 */

 /*  SELECT
       COUNT(*)
   INTO
       numtrxns_out
   FROM
       iby_trxn_summaries_all
   WHERE
       status  = oldstatus_in   AND
       payeeid = merchant_id_in AND
       bepid   = vendor_id_in   AND
       bepkey  = vendor_key_in  AND
       batchid IS NULL          AND
       trunc(nvl(settledate, sysdate)) <= trunc(nvl(settlement_date_in, sysdate-1)) AND
       instrtype = 'BANKACCOUNT';
  */

     l_cursor_stmt := ' SELECT COUNT(*) FROM                                     '||
                      ' iby_trxn_summaries_all WHERE                             '||
                      ' status = '||oldstatus_in||' AND                          '||
                      ' payeeid = '''||merchant_id_in||''' AND                   '||
                      ' bepid = '||vendor_id_in||' AND                           '||
                      ' process_profile_code IN ('||strProfCodes||') AND         '||
                      ' batchid IS NULL AND                                      '||
		    -- bug 8238335
                    --  ' trunc(nvl(settledate, sysdate)) <= trunc(nvl(to_date('''||settlement_date_in||'''), sysdate-1)) AND '||
                      ' instrtype = ''BANKACCOUNT''                              '
                      ;

     OPEN l_trxn_cursor FOR l_cursor_stmt;
     FETCH l_trxn_cursor INTO numtrxns_out;
     CLOSE l_trxn_cursor;
   /*
    * If there isn't any open transactions, then exit.
    */
   IF (numtrxns_out > 0) THEN

       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo(l_module_name, 'Invoking grouping ..');

       END IF;
       /*
        * Group all the transactions for this profile into
        * batches as per the grouping attributes on the profile.
        */
       IBY_TRANSACTIONCC_PKG.performTransactionGrouping(
           profile_code_array,
           instr_type_in,
           req_type_in,
           f_pmt_channel_in,
           f_curr_in,
           f_settle_date,
           f_due_date,
           f_maturity_date,
           f_instr_type,
           merch_batchid_in,
           l_batches_tab,
           l_trxns_in_batch_tab
           );

       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo(l_module_name, '# batches created: '
	           || l_batches_tab.COUNT);

	       print_debuginfo(l_module_name, '# transactions processed: '
	           || l_trxns_in_batch_tab.COUNT);

       END IF;
       /*
        * After grouping it is possible that multiple batches were
        * created. Each batch will be a separate row in the
        * IBY_BATCHES_ALL table with a unique mbatchid.
        *
        * The user may have provided a batch id (batch prefix), we will
        * have to assign that batch id to each of the created batches.
        *
        * This batch id would be sent to the payment system. It therefore
        * has to be unique. Therefore, we add a suffix to the user
        * provided batch id to ensure that batches created after grouping
        * have a unique batch id.
        */
       IF (l_batches_tab.COUNT > 0) THEN

           l_index := 1;
           FOR k IN l_batches_tab.FIRST .. l_batches_tab.LAST LOOP

               /*
                * Assign a unique batch id to each batch.
                */
               l_batches_tab(k).batch_id :=
                   merch_batchid_in ||'_'|| l_index;
               l_index := l_index + 1;

           END LOOP;

       END IF;

       /* Perform the logical grouping of transactions for SEPA
          Chk the format based on the profile code
	  If it contains SEPA, then create the logical grouping.
       */

       SELECT sp.funds_xfer_format_code
	 INTO  l_system_prof_code
	 FROM iby_fndcpt_user_eft_pf_b up
	       ,iby_fndcpt_sys_eft_pf_b sp
	WHERE up.sys_eft_profile_code =  sp.sys_eft_profile_code
	  AND up.user_eft_profile_code = profile_code_array(1);

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo(l_module_name, 'Fetched Format ' || l_system_prof_code );
        END IF;

        IF (instr( l_system_prof_code, 'SEPA') >0)
	THEN
            createLogicalGroups(l_batches_tab);
        END IF;

	/* Logical grouping of transactions for SEPA - END  */


       /*
        * After grouping, the transactions will be assigned a mbatch id.
        * Assign them a batch id as well (based on the batch id
        * corresponding to each mbatch id).
        */
       IF (l_trxns_in_batch_tab.COUNT > 0) THEN

           FOR m IN l_trxns_in_batch_tab.FIRST ..
                     l_trxns_in_batch_tab.LAST LOOP

               FOR k IN l_batches_tab.FIRST .. l_batches_tab.LAST LOOP

                   /*
                    * Find the mbatch id in the batches array
                    * corresponding to the mbatchid of this transaction.
                    */
                   IF (l_trxns_in_batch_tab(m).mbatch_id =
                             l_batches_tab(k).mbatch_id) THEN

                       /*
                        * Assign the batch id from the batches array
                        * to this transaction.
                        */
                       l_trxns_in_batch_tab(m).batch_id :=
                           l_batches_tab(k).batch_id;

                   END IF;

               END LOOP;

           END LOOP;

       END IF;


      /*

      SELECT
          iby_batches_s.NEXTVAL
      INTO
          l_mbatchid
      FROM
          DUAL;
      */

      iby_accppmtmthd_pkg.getMPayeeId(merchant_id_in, l_mpayeeid);

      IF (l_batches_tab.COUNT <> 0) THEN

          FOR i IN l_batches_tab.FIRST .. l_batches_tab.LAST LOOP

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	              print_debuginfo(l_module_name, 'Going to insert batch '
	                  || l_batches_tab(i).mbatch_id);
              END IF;
              /*
	       * Modified to insert null values for bepkey, currency and
	       * profile code columns since these could have multiple values
	       * for a batch.
	       */
              INSERT INTO iby_batches_all
                 (MBATCHID,
                  BATCHID,
                  MPAYEEID,
                  PAYEEID,
                  BEPID,
                  BEPKEY,
                  BATCHSTATUS,
                  BATCHSTATEID,
                  BATCHCLOSEDATE,
                  REQTYPE,
                  REQDATE,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATE_LOGIN,
                  OBJECT_VERSION_NUMBER,
                  SENTCOUNTER,
                  SENTCOUNTERDAILY,
                  PROCESS_PROFILE_CODE,
                  INSTRUMENT_TYPE,
                  BR_DISPUTED_FLAG,
                  CURRENCYNAMECODE,
                  PAYEEINSTRID,
                  LEGAL_ENTITY_ID,
                  ORG_ID,
                  ORG_TYPE,
                  SETTLEDATE
                  )
              VALUES
                 (
                 l_batches_tab(i).mbatch_id,
                 merch_batchid_in || '_' || i,
                 l_mpayeeid,
                 merchant_id_in,
                 vendor_id_in,
                 null, -- l_batches_tab(i).bep_key
                 batchstate_in,
                 batchstate_in,
                 settlement_date_in,
                 req_type_in,
                 sysdate,
                 sysdate,
                 fnd_global.user_id,
                 sysdate,
                 fnd_global.user_id,
                 fnd_global.login_id,
                 0,
                 0,
                 0,
		 --l_batches_tab(i).profile_code
		 profile_code_array(1),
                 instr_type_in,
                 br_disputed_flag_in,

                 /*
                  * Fix for bug 5614670:
                  *
                  * Populate the batch related attributes
                  * created after grouping in this
                  * insert.
                  */
                 null, --l_batches_tab(i).curr_code
                 l_batches_tab(i).int_bank_acct_id,
                 l_batches_tab(i).le_id,
                 l_batches_tab(i).org_id,
                 l_batches_tab(i).org_type,
                 l_batches_tab(i).settle_date
                 );

              /*
               * Store the created mbatchids in the output param
               * to return to the caller.
               */
              mbatch_ids_out.EXTEND;
              mbatch_ids_out(i) := l_batches_tab(i).mbatch_id;

              /*
               * Store the created batchids in the output param
               * to return to the caller.
               */
              batch_ids_out.EXTEND;
              batch_ids_out(i) := l_batches_tab(i).batch_id;

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	              print_debuginfo(l_module_name, 'Finished insert batch '
	                  || l_batches_tab(i).mbatch_id);

              END IF;
          END LOOP;

      END IF; -- if l_batches_tab.COUNT <> 0

      IF (l_trxns_in_batch_tab.COUNT <> 0) THEN

          FOR i IN l_trxns_in_batch_tab.FIRST .. l_trxns_in_batch_tab.LAST LOOP

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	              print_debuginfo(l_module_name, 'Going to update transaction '
	                  || l_trxns_in_batch_tab(i).trxn_id);

              END IF;
              UPDATE
                 IBY_TRXN_SUMMARIES_ALL
              SET
                 status                = newstatus_in,
                 batchid               = l_trxns_in_batch_tab(i).batch_id,
                 mbatchid              = l_trxns_in_batch_tab(i).mbatch_id,
                 last_update_date      = sysdate,
                 updatedate            = sysdate,
                 last_updated_by       = fnd_global.user_id,
                 object_version_number = object_version_number + 1
              WHERE
                 transactionid = l_trxns_in_batch_tab(i).trxn_id AND
                 status        = iby_transactioncc_pkg.C_STATUS_OPEN_BATCHED
                 ;

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	              print_debuginfo(l_module_name, 'Finished updating transaction'
	                  || l_trxns_in_batch_tab(i).trxn_id);

              END IF;
          END LOOP;

      END IF; -- if l_trxns_in_batch_tab.COUNT <> 0

      COMMIT;

   ELSE

       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo(l_module_name, 'No open transactions; Exiting ..');

       END IF;
   END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo(l_module_name, 'mbatchids count: '
	       || mbatch_ids_out.COUNT);

	   print_debuginfo(l_module_name, 'EXIT');

   END IF;
END createBatchCloseTrxnsNew;


/*Update the batch and transactions status and other infomations based on the
  payeeid and batchid */
PROCEDURE updateBatchCloseTrxns(
            merch_batchid_in     IN    VARCHAR2,
            merchant_id_in       IN    VARCHAR2,
            newstatus_in         IN    NUMBER,
            batchstate_in        IN    NUMBER,
            numtrxns_in          IN    NUMBER,
            batchtotal_in        IN    NUMBER DEFAULT null,
            salestotal_in        IN    NUMBER DEFAULT null,
            credittotal_in       IN    NUMBER DEFAULT null,
            time_in              IN    DATE,
            vendor_code_in       IN    VARCHAR2,
            vendor_message_in    IN    VARCHAR2
            )
   IS

   BEGIN
   -- reset the OBJECT VERSION NUMBER, since we not using it
   -- the purpose of this, it is to keep track the EFT batchseq number

   UPDATE iby_batches_all SET
      SENTCOUNTERDAILY = 0
   WHERE batchid = merch_batchid_in
      AND payeeid = merchant_id_in
      AND trunc(LAST_UPDATE_DATE) < trunc(sysdate);


   UPDATE iby_batches_all SET
      BATCHSTATUS = batchstate_in,
      BATCHSTATEID = batchstate_in,
      NUMTRXNS = numtrxns_in,

      --
      -- only change these values if the incoming values are
      -- non-trivial
      --
      BATCHTOTAL = DECODE(NVL(batchtotal_in,''),'',batchtotal,batchtotal_in),
      BATCHSALES = DECODE(NVL(salestotal_in,''),'',batchsales,salestotal_in),
      BATCHCREDIT = DECODE(NVL(credittotal_in,''),'',batchcredit,credittotal_in),

      BATCHCLOSEDATE = time_in,
      BEPCODE = vendor_code_in,
      BEPMESSAGE = vendor_message_in,
      LAST_UPDATE_DATE = sysdate,
      LAST_UPDATED_BY = fnd_global.user_id,
      OBJECT_VERSION_NUMBER = Object_Version_Number + 1,
      SENTCOUNTER = SENTCOUNTER + 1,
      SENTCOUNTERDAILY = SENTCOUNTERDAILY + 1
   WHERE batchid = merch_batchid_in
      AND payeeid = merchant_id_in;

   UPDATE iby_trxn_summaries_all
   SET
      STATUS = newstatus_in,
      BEPCODE = vendor_code_in,
      BEPMESSAGE = vendor_message_in,
      LAST_UPDATE_DATE = sysdate,
      UPDATEDATE = sysdate,
      LAST_UPDATED_BY = fnd_global.user_id,
      OBJECT_VERSION_NUMBER = object_version_number + 1
   WHERE
   -- 109 means STATUS_BATCH_TRANSITIONAL, 101 means STATUS_BATCH_COMM_ERROR, 120 means STATUS_BATCH_MAX_EXCEEDED
      status in (109, 101, 120)
   AND
      batchid = merch_batchid_in
   AND
      payeeid = merchant_id_in
   AND
      instrtype = 'BANKACCOUNT';

   COMMIT;

END updateBatchCloseTrxns;


/*Update the transactions status and other informations by passed the data in as array.*/
procedure updateTrxnResultStatus(i_merch_batchid      IN    VARCHAR2,
                                 i_merchant_id        IN    VARCHAR2,
                                 i_status_arr         IN    JTF_NUMBER_TABLE,
                                 i_errCode_arr        IN    JTF_VARCHAR2_TABLE_100,
                                 i_errMsg_arr         IN    JTF_VARCHAR2_TABLE_300,
                                 i_tangibleId_arr     IN    JTF_VARCHAR2_TABLE_100,
                                 o_status_arr         OUT NOCOPY JTF_NUMBER_TABLE,
                                 o_error_code         OUT NOCOPY NUMBER,
                                 o_error_msg          OUT NOCOPY VARCHAR2
                                )

IS

 l_index     INTEGER;
 c_FAIL      NUMBER := -1;
 c_SUCCESS   NUMBER := 0;

BEGIN

 o_status_arr := JTF_NUMBER_TABLE();
 o_status_arr.extend( i_tangibleId_arr.count );

 o_error_code := 0;

 l_index := i_tangibleId_arr.first;

 WHILE (TRUE) LOOP

    o_status_arr( l_index ) := c_SUCCESS;

    BEGIN  -- Nested block begins

       UPDATE iby_trxn_summaries_all
       SET    STATUS =  i_status_arr( l_index ),
              BEPCODE = i_errCode_arr( l_index ),
              BEPMESSAGE = i_errMsg_arr( l_index ),
              LAST_UPDATE_DATE = sysdate,
              UPDATEDATE = sysdate,
              LAST_UPDATED_BY = fnd_global.user_id
       WHERE  TANGIBLEID = i_tangibleId_arr( l_index )
       AND    batchid = i_merch_batchid
       AND    payeeid = i_merchant_id;

       IF ( SQL%NOTFOUND ) THEN
          o_status_arr( l_index ) := c_FAIL;
          ROLLBACK;
       ELSE
          COMMIT;
       END IF;

    EXCEPTION
       WHEN OTHERS THEN
          o_status_arr( l_index ) := c_FAIL;
          o_error_code := SQLCODE;
          o_error_msg := SUBSTR(SQLERRM, 1, 200);

    END; -- Nested block ends

    EXIT WHEN ( i_tangibleId_arr.last = l_index );

    l_index := i_tangibleId_arr.next( l_index );

 END LOOP; --end of while loop

END updateTrxnResultStatus;

PROCEDURE insertEFTBatchTrxns(
            i_ecappid        IN iby_trxn_summaries_all.ecappid%TYPE,
            i_payeeid        IN iby_trxn_summaries_all.payeeid%TYPE,
            i_ecbatchid      IN iby_trxn_summaries_all.ecbatchid%TYPE,
            i_bepid          IN iby_trxn_summaries_all.bepid%TYPE,
            i_bepkey         IN iby_trxn_summaries_all.bepkey%TYPE,
            i_pmtmethod      IN iby_trxn_summaries_all.paymentmethodname%TYPE,
            i_reqtype        IN iby_trxn_summaries_all.reqtype%TYPE,
            i_reqdate        IN iby_trxn_summaries_all.reqdate%TYPE,
            i_payeeinstrid   IN iby_trxn_summaries_all.payeeinstrid%TYPE,
            i_orgid          IN iby_trxn_summaries_all.org_id%TYPE,

            i_payerinstrid   IN JTF_NUMBER_TABLE,
            i_amount         IN JTF_NUMBER_TABLE,
            i_payerid        IN JTF_VARCHAR2_TABLE_100,
            i_tangibleid     IN JTF_VARCHAR2_TABLE_100,
            i_currency       IN JTF_VARCHAR2_TABLE_100,
            i_refinfo        IN JTF_VARCHAR2_TABLE_100,
            i_memo           IN JTF_VARCHAR2_TABLE_100,
            i_ordermedium    IN JTF_VARCHAR2_TABLE_100,
            i_eftauthmethod  IN JTF_VARCHAR2_TABLE_100,
            i_instrsubtype   IN JTF_VARCHAR2_TABLE_100,
            i_settledate     IN JTF_DATE_TABLE,
            i_issuedate      IN JTF_DATE_TABLE,
            i_customerref    IN JTF_VARCHAR2_TABLE_100,
            o_trxnId         OUT NOCOPY JTF_NUMBER_TABLE
            )
IS
     l_mtangibleid JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
     l_trxnmid JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
     l_mpayeeid iby_payee.mpayeeid%TYPE;
     l_count NUMBER;

     CURSOR c_trxnmid IS
          SELECT iby_trxnsumm_mid_s.nextval
          FROM DUAL;

     CURSOR c_mtangibleid IS
          SELECT iby_tangible_s.nextval
          FROM DUAL;

BEGIN
     /**
      * Check if this EC batch is already been submitted
      * by the EC application.
      */
     SELECT count(*) INTO l_count
     FROM iby_trxn_summaries_all
     WHERE ecbatchid = i_ecbatchid
     AND ecappid = i_ecappid
     AND payeeid = i_payeeid;

     IF(l_count > 0) THEN
          raise_application_error(-20000, 'IBY_20560#', FALSE);
     END IF;

     iby_fipayments_pkg.checkInstrId(i_payeeinstrid);

     IF (c_trxnmid%ISOPEN) THEN
          CLOSE c_trxnmid;
     END IF;

     IF (c_mtangibleid%ISOPEN) THEN
          CLOSE c_mtangibleid;
     END IF;

     l_mtangibleid.EXTEND(i_tangibleid.COUNT);
     l_trxnmid.EXTEND(i_tangibleid.COUNT);

     o_trxnid := JTF_NUMBER_TABLE();
     o_trxnid.EXTEND(i_tangibleid.COUNT);

     /**
      * Obtain the master payeeid for the given payee.
      */
     iby_accppmtmthd_pkg.getMPayeeId(i_payeeid, l_mpayeeid);

     FOR j IN i_tangibleid.FIRST..i_tangibleid.LAST
     LOOP
          /**
           * Check if the payer has registered the instrument.
           */
          iby_fipayments_pkg.checkInstrId(i_payerinstrid(j));

          /**
           * Check if there is already a request with same payee id
           * tangible id and request type.
           */
          IF (iby_fipayments_pkg.requestExists(i_payeeid, i_tangibleid(j), NULL, i_reqtype)) THEN
               raise_application_error(-20000, 'IBY_20560#', FALSE);
          END IF;

          o_trxnid(j) := iby_transactioncc_pkg.getTID(i_payeeid, i_tangibleid(j));

          OPEN c_trxnmid;
          FETCH c_trxnmid INTO l_trxnmid(j);
          CLOSE c_trxnmid;

          OPEN c_mtangibleid;
          FETCH c_mtangibleid INTO l_mtangibleid(j);
          CLOSE c_mtangibleid;

     END LOOP;

 /**
      * Create tangible records in iby_tangible.
      */
     FOR j IN i_tangibleid.FIRST..i_tangibleid.LAST  LOOP

     /**
      * Check for duplicate tangible ids
      */
      select count(*)  into l_count
      from iby_trxn_summaries_all s
      where payeeId = i_payeeId
      and tangibleid = i_tangibleId(j)
      and UPPER(reqType) = UPPER(i_reqType);

      IF (l_count=0) THEN

          INSERT INTO iby_tangible
          (
               mtangibleId, tangibleid, amount,
               currencyNameCode, refinfo, memo, issuedate,
               order_medium, eft_auth_method,
               last_update_date, last_updated_by,
               creation_date, created_by,
               last_update_login, object_version_number
          )
          VALUES
          (
               l_mtangibleid(j), i_tangibleid(j), i_amount(j),
               i_currency(j), i_refinfo(j), i_memo(j), i_issuedate(j),
               i_ordermedium(j), i_eftauthmethod(j),
               sysdate, fnd_global.user_id,
               sysdate, fnd_global.user_id,
               fnd_global.login_id, 1
          );

          /**
           * Create transaction records in iby_trxn_summaries_all.
           */
           INSERT INTO iby_trxn_summaries_all
          (
               org_id, ecappid, mpayeeid, payeeid,
               bepid, bepkey, paymentMethodname,
               ecbatchid, trxnmid, transactionid, mtangibleId,
               tangibleid, payeeinstrid, payerid, payerinstrid,
               amount, currencyNameCode, reqdate,
               reqtype, status, settledate, instrtype, instrsubtype,
               settlement_customer_reference,
               last_update_date, updatedate, last_updated_by,
               creation_date, created_by,
               last_update_login, object_version_number,needsupdt
          )
          VALUES
          (
               i_orgid, i_ecappid, l_mpayeeid, i_payeeid,
               i_bepid, i_bepkey, i_pmtmethod, i_ecbatchid,
               l_trxnmid(j), o_trxnid(j), l_mtangibleid(j),
               i_tangibleid(j), i_payeeinstrid, i_payerid(j),
               i_payerinstrid(j), i_amount(j), i_currency(j),
               i_reqdate, i_reqtype, 100, i_settledate(j),
               'BANKACCOUNT', i_instrsubtype(j),
               i_customerref(j),
               sysdate, sysdate, fnd_global.user_id,
               sysdate, fnd_global.user_id,
               fnd_global.login_id, 1,'Y'
          );

          ELSIF (l_count=1)  THEN

          /* If a duplicate request exists
           * it has to be in a failed status, as 'requestExists' has already
           * been checked, hence updating the duplicate failed request.
           */

          UPDATE iby_tangible
          set mtangibleId      = l_mtangibleid(j),
              amount           = i_amount(j),
              currencyNameCode = i_currency(j),
              refinfo          = i_refinfo(j),
              memo             = i_memo(j),
              order_medium     = i_ordermedium(j),
              eft_auth_method  = i_eftauthmethod(j),
              issuedate        = i_issuedate(j),
              last_update_date = sysdate,
              last_updated_by  = fnd_global.user_id,
              creation_date    = sysdate,
              created_by       = fnd_global.user_id,
              last_update_login= fnd_global.login_id,
              object_version_number = 1
          where tangibleid     = i_tangibleid(j);

          UPDATE iby_trxn_summaries_all
          set org_id            = i_orgid,
              ecappid           = i_ecappid,
              mpayeeid          = l_mpayeeid,
              payeeid           = i_payeeid,
              bepid             = i_bepid,
              bepkey            = i_bepkey,
              paymentMethodname = i_pmtmethod,
              ecbatchid         = i_ecbatchid,
              trxnmid           = l_trxnmid(j),
              transactionid     = o_trxnid(j),
              mtangibleId       = l_mtangibleid(j),
              payeeinstrid      = i_payeeinstrid,
              payerid           = i_payerid(j),
              payerinstrid      = i_payerinstrid(j),
              amount            = i_amount(j),
              currencyNameCode  = i_currency(j),
              reqdate           = i_reqdate,
              reqtype           = i_reqtype,
              status            = 100,
              settledate        = i_settledate(j),
              instrtype         = 'BANKACCOUNT',
              instrsubtype      = i_instrsubtype(j),
              settlement_customer_reference
                                = i_customerref(j),
              bepcode           = null,
              bepmessage        = null,
              batchid           = null,
              mbatchid          = null,
              errorlocation     = null,
              last_update_date  = sysdate,
              updatedate        = sysdate,
              last_updated_by   = fnd_global.user_id,
              creation_date     = sysdate,
              created_by        = fnd_global.user_id,
              last_update_login = fnd_global.user_id,
              object_version_number = 1

        where tangibleid = i_tangibleid(j);
          ELSE
           raise_application_error(-20000, 'IBY_20560#', FALSE);

          END IF;

     END LOOP;

     COMMIT;
END insertEFTBatchTrxns;

  -------------------------------------------------------------------------
  -- This procedure inserts or update the verify transaction data into the
  -- database.
  -------------------------------------------------------------------------

  PROCEDURE createEFTVerifyTrxn(
            i_ecappid        IN iby_trxn_summaries_all.ecappid%TYPE,
            i_reqtype        IN iby_trxn_summaries_all.reqtype%TYPE,
            i_bepid          IN iby_trxn_summaries_all.bepid%TYPE,
            i_bepkey         IN iby_trxn_summaries_all.bepkey%TYPE,
            i_payeeid        IN iby_trxn_summaries_all.payeeid%TYPE,
            i_payeeinstrid   IN iby_trxn_summaries_all.payeeinstrid%TYPE,
            i_tangibleid     IN iby_trxn_summaries_all.tangibleid%TYPE,
            i_amount         IN iby_trxn_summaries_all.amount%TYPE,
            i_currency       IN iby_trxn_summaries_all.currencynamecode%TYPE,
            i_status         IN iby_trxn_summaries_all.status%TYPE,
            i_refinfo        IN iby_tangible.refinfo%TYPE,
            i_memo           IN iby_tangible.memo%TYPE,
            i_acctno         IN iby_tangible.acctno%TYPE,
            i_ordermedium    IN iby_tangible.order_medium%TYPE,
            i_eftauthmethod  IN iby_tangible.eft_auth_method%TYPE,
            i_orgid          IN iby_trxn_summaries_all.org_id%TYPE,
            i_pmtmethod      IN iby_trxn_summaries_all.paymentmethodname%TYPE,
    	    i_payerid        IN iby_trxn_summaries_all.payerid%TYPE,
            i_instrtype      IN iby_trxn_summaries_all.instrtype%TYPE,
            i_instrsubtype   IN iby_trxn_summaries_all.instrsubtype%TYPE,
            i_payerinstrid   IN iby_trxn_summaries_all.payerinstrid%TYPE,
            i_trxndate       IN iby_trxn_summaries_all.updatedate%TYPE,
            i_trxntypeid     IN iby_trxn_summaries_all.TrxntypeID%TYPE,
            i_bepcode        IN iby_trxn_summaries_all.BEPCode%TYPE,
            i_bepmessage     IN iby_trxn_summaries_all.BEPMessage%TYPE,
            i_errorlocation  IN iby_trxn_summaries_all.errorlocation%TYPE,
            i_referenceCode  IN iby_trxn_summaries_all.proc_reference_code%TYPE,
            o_trxnid         OUT NOCOPY iby_trxn_summaries_all.transactionid%TYPE,
            i_orgtype        IN iby_trxn_summaries_all.org_type%TYPE,
            i_pmtchannelcode IN iby_trxn_summaries_all.payment_channel_code%TYPE,
            i_factoredflag   IN iby_trxn_summaries_all.factored_flag%TYPE,
  i_pmtinstrassignmentId IN iby_trxn_summaries_all.payer_instr_assignment_id%TYPE,
            i_process_profile_code IN iby_trxn_summaries_all.process_profile_code%TYPE,
            o_trxnmid        OUT NOCOPY iby_trxn_summaries_all.trxnmid%TYPE
            )  IS

  l_mtangibleid     iby_trxn_summaries_all.mtangibleid%TYPE;
  l_trxnmid         iby_trxn_summaries_all.transactionid%TYPE;

-- new parameters for eft authorizations
  l_debit_auth_flag      iby_trxn_summaries_all.debit_auth_flag%TYPE;
  l_debit_auth_method    iby_trxn_summaries_all.debit_auth_method%TYPE;
  l_debit_auth_reference iby_trxn_summaries_all.debit_auth_reference%TYPE;
  l_payer_party_id       iby_trxn_summaries_all.payer_party_id%TYPE;
  l_mpayeeid        iby_payee.mpayeeid%TYPE;
  l_trxn_exists     VARCHAR2(1);

  l_payer_notif_flag     iby_trxn_summaries_all.payer_notification_required%TYPE;
  l_bep_type              iby_bepinfo.bep_type%TYPE;

  CURSOR trxn_exists IS
  SELECT 'Y', trxnmid, mtangibleid
    FROM iby_trxn_summaries_all s
   WHERE payeeId = i_payeeId
     AND tangibleid = i_tangibleid
     AND UPPER(reqType) = UPPER(i_reqType)
     AND status <> '0'
     ORDER BY trxnmid desc;
  -- It will update the same transaction if not successfull
  -- of the same request type

  CURSOR c_payer_notif_eft (i_user_fcpp_code iby_trxn_summaries_all.process_profile_code%TYPE) IS
  SELECT DECODE(payer_notification_format, null, 'N', 'Y')
    FROM iby_fndcpt_user_eft_pf_b up, iby_fndcpt_sys_eft_pf_b sp
   WHERE up.sys_eft_profile_code = sp.sys_eft_profile_code
     AND up.user_eft_profile_code = i_user_fcpp_code;

  BEGIN

     -- Check if payer has registered the instrument

    IF ( NVL(i_payerinstrid,0) <> 0) THEN
      iby_fipayments_pkg.checkInstrId(i_payerinstrid);
    END IF;

  -- Get the master payeeid for the given payee
    iby_accppmtmthd_pkg.getMPayeeId(i_payeeid, l_mpayeeid);

    -- this function returns the existing transactionid from the iby_trxn_summaries_all
    -- table if one exist for the payeeid and tangibleid, or a new one from the DB
    -- sequence if none exists.
    o_trxnid := iby_transactioncc_pkg.getTID(i_payeeid, i_tangibleid);

    --  Verify if transaction already exist and aget l_trxnmid so that the
    --  update is done using the PK

    OPEN trxn_exists;
    FETCH trxn_exists INTO l_trxn_exists, l_trxnmid, l_mtangibleid;
    CLOSE trxn_exists;


    -- get the debit authrization values
begin
    IF  (i_pmtinstrassignmentId>0) then
   select debit_auth_flag,
          debit_auth_method,
          debit_auth_reference
   into   l_debit_auth_flag,
          l_debit_auth_method,
          l_debit_auth_reference
   from   iby_pmt_instr_uses_all
   where  instrument_payment_use_id=i_pmtinstrassignmentId;
   END IF;
exception
   WHEN NO_DATA_FOUND THEN
     null;
end;


   -- get the payer party id
 -- get the payer_party_id if exists
 begin
   if(i_payerid is not NULL) then
       l_payer_party_id :=to_number(i_payerid);
       end if;
  exception
    when others then
     l_payer_party_id :=null;
  end;

    -- get bep_type info
    BEGIN
      SELECT bep_type
        INTO l_bep_type
        FROM iby_bepinfo
       WHERE bepid = i_bepid;
    EXCEPTION
      WHEN others THEN NULL;
    END;

    -- get payer notification flag for capture transactions
    -- for Gateway
    -- for processor transactions the flag is set during batch close
    -- only BANKACCOUNTS
    IF (i_trxntypeid IN (3,8,9,100) AND
        l_bep_type = 'GATEWAY') THEN
       -- only BANKACCOUNTS
      OPEN c_payer_notif_eft(i_process_profile_code);
      FETCH c_payer_notif_eft INTO l_payer_notif_flag;
      CLOSE c_payer_notif_eft;

    END IF;

    IF (NVL(l_trxn_exists, 'N') = 'N') THEN
       --Create an entry in iby_tangible table
       iby_bill_pkg.createBill(
           i_tangibleid,                -- IN i_billId
           i_amount,                    -- IN i_billAmount
           i_currency,                  -- IN i_billCurDef
           i_acctno,                    -- IN i_billAcct
           i_refinfo,                   -- IN i_billRefInfo
           i_memo,                      -- IN i_billMemo
           i_ordermedium,               -- IN i_billOrderMedium
           i_eftauthmethod,             -- IN i_billEftAuthMethod
           l_mtangibleid);              -- OUT io_mtangibleid


       -- Create transaction records in iby_trxn_summaries_all.
       INSERT INTO iby_trxn_summaries_all(
             trxnmid,
             org_id,
             ecappid,
             mpayeeid,
             payeeid,
             bepid,
             bepkey,
             paymentMethodname,
             transactionid,
             mtangibleId,
             tangibleid,
             payeeinstrid,
             payerid,
             payerinstrid,
             amount,
             currencyNameCode,
             reqtype,
             status,
             settledate,
             instrtype,
             instrsubtype,
             last_update_date,
             reqdate,
             updatedate,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             object_version_number,
             bepcode,
             bepmessage,
             errorlocation,
             trxntypeid,
             proc_reference_code,
             org_type,
             payment_channel_code,
             factored_flag,
             payer_instr_assignment_id,
             process_profile_code,
             payer_party_id,
             debit_auth_flag,
             debit_auth_method,
             debit_auth_reference,
             payer_notification_required,
	     needsupdt
          ) VALUES (
             iby_trxnsumm_mid_s.NEXTVAL,       -- trxnmid
             i_orgid,                          -- org_id
             i_ecappid,                        -- ecappid
             l_mpayeeid,                       -- mpayeeid
             i_payeeid,                        -- payeeid
             i_bepid,                          -- bepid
             i_bepkey,                         -- bepkey
             i_pmtmethod,                      -- paymentMethodname
             o_trxnid,                         -- transactionid
             l_mtangibleid,                    -- mtangibleId
             i_tangibleid,                     -- tangibleid
             i_payeeinstrid,                   -- payeeinstrid
             i_payerid,                        -- payerid
             i_payerinstrid,                   -- payerinstrid
             i_amount,                         -- amount
             i_currency,                       -- currencyNameCode
             i_reqtype,                        -- reqtype
             i_status,                         -- status
             null,                             -- settledate
             i_instrtype,                      -- instrtype
             i_instrsubtype,                   -- instrsubtype
             sysdate,                          -- last_update_date
             i_trxndate,                       -- reqdate
             i_trxndate,                       -- updatedate
             fnd_global.user_id,               -- last_updated_by
             sysdate,                          -- creation_date
             fnd_global.user_id,               -- created_by
             fnd_global.login_id,              -- last_update_login
             1,                                -- object_version_number
             i_bepcode,                        -- bepcode
             i_bepmessage,                     -- bepmessage
             i_errorlocation,                  -- errorlocation
             i_trxntypeid,                     -- trxntypeid
             i_referencecode,                  -- reference code
             i_orgtype,                        -- org_type
             i_pmtchannelcode,                 -- payment_channel_code
             i_factoredflag,                    -- factored_flag
             i_pmtinstrassignmentId,
             i_process_profile_code,
             l_payer_party_id,
             l_debit_auth_flag,
             l_debit_auth_method,
             l_debit_auth_reference,
             DECODE(i_status, 0, l_payer_notif_flag, 'N'),
	     'Y'
          ) RETURNING trxnmid INTO l_trxnmid;

    ELSE
      -- A transaction is already created.

      -- Update iby_tangible table

      iby_bill_pkg.modBill(
           l_mtangibleid,               -- IN i_mtangibleid
           i_tangibleid,                -- IN i_billId
           i_amount,                    -- IN i_billAmount
           i_currency,                  -- IN i_billCurDef
           i_acctno,                    -- IN i_billAcct
           i_refinfo,                   -- IN i_billRefInfo
           i_memo,                      -- IN i_billMemo
           i_ordermedium,               -- IN i_billOrderMedium
           i_eftauthmethod);            -- IN i_billEftAuthMethod

       UPDATE iby_trxn_summaries_all
          SET tangibleid            = i_tangibleid,
              org_id                = i_orgid,
              ecappid               = i_ecappid,
              mpayeeid              = l_mpayeeid,
              payeeid               = i_payeeid,
              bepid                 = i_bepid,
              bepkey                = i_bepkey,
              paymentMethodname     = i_pmtmethod,
              transactionid         = o_trxnid,
              mtangibleId           = l_mtangibleid,
              payeeinstrid          = i_payeeinstrid,
              payerid               = i_payerid,
              payerinstrid          = i_payerinstrid,
              amount                = i_amount,
              currencyNameCode      = i_currency,
              reqtype               = i_reqtype,
              status                = i_status,
              instrtype             = i_instrtype,
              instrsubtype          = i_instrsubtype,
              bepcode               = i_bepcode,
              bepmessage            = i_bepmessage,
              errorlocation         = i_errorlocation,
              last_update_date      = sysdate,
              reqdate               = i_trxndate,
              updatedate            = i_trxndate,
              last_updated_by       = fnd_global.user_id,
              creation_date         = sysdate,
              created_by            = fnd_global.user_id,
              last_update_login     = fnd_global.user_id,
              object_version_number = 1,
--              trxntypeid            = i_trxntypeid,
              proc_reference_code   = i_referencecode,
              org_type              = i_orgtype,
              payment_channel_code  = i_pmtchannelcode,
              factored_flag         = i_factoredflag,
              debit_auth_flag       = l_debit_auth_flag,
              debit_auth_method     = l_debit_auth_method,
              debit_auth_reference  = l_debit_auth_reference,
              payer_instr_assignment_id= i_pmtinstrassignmentId,
              process_profile_code  = i_process_profile_code,
              payer_party_id        = l_payer_party_id,
              payer_notification_required = DECODE(i_status, 0, l_payer_notif_flag, 'N')
        WHERE trxnmid               = l_trxnmid;


    END IF;
    o_trxnmid := l_trxnmid;

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN

      IF (trxn_exists%ISOPEN ) THEN
        CLOSE trxn_exists;
      END IF;
      raise_application_error(-20000, 'IBY_20400#', FALSE);

  END createEFTVerifyTrxn;

/*--------------------------------------------------------------------
 | NAME:
 |     print_debuginfo
 |
 | PURPOSE:
 |     This procedure prints the debug message to the concurrent manager
 |     log file.
 |
 | PARAMETERS:
 |     IN
 |      p_debug_text - The debug message to be printed
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE print_debuginfo(
     p_module     IN VARCHAR2,
     p_debug_text IN VARCHAR2
     )
 IS
 PRAGMA AUTONOMOUS_TRANSACTION;

 BEGIN

     /*
      * If FND_GLOBAL.conc_request_id is -1, it implies that
      * this method has not been invoked via the concurrent
      * manager. In that case, write to apps log else write
      * to concurrent manager log file.
      */
     IF (FND_GLOBAL.conc_request_id = -1) THEN

         /*
          * OPTION I:
          * Write debug text to the common application log file.
          */
         IBY_DEBUG_PUB.add(
             substr(RPAD(p_module,55) || ' : ' || p_debug_text, 0, 150),
             FND_LOG.G_CURRENT_RUNTIME_LEVEL,
             'iby.plsql.IBY_VALIDATIONSETS_PUB'
             );

         /*
          * OPTION II:
          * Write debug text to DBMS output file.
          */
         --DBMS_OUTPUT.PUT_LINE(substr(RPAD(p_module,40)||' : '||
         --    p_debug_text, 0, 150));

         /*
          * OPTION III:
          * Write debug text to temporary table.
          */
         /* uncomment these two lines for debugging */
         --INSERT INTO TEMP_IBY_LOGS VALUES (p_module || ': '
         --    || p_debug_text, sysdate);

         --COMMIT;

     ELSE

         /*
          * OPTION I:
          * Write debug text to the concurrent manager log file.
          */
         FND_FILE.PUT_LINE(FND_FILE.LOG, p_module || ': ' || p_debug_text);

         /*
          * OPTION II:
          * Write debug text to DBMS output file.
          */
         --DBMS_OUTPUT.PUT_LINE(substr(RPAD(p_module,40)||' : '||
         --    p_debug_text, 0, 150));

         /*
          * OPTION III:
          * Write debug text to temporary table.
          */
         /* uncomment these two lines for debugging */
         --INSERT INTO TEMP_IBY_LOGS VALUES (p_module || ': '
         --    || p_debug_text, sysdate);

         --COMMIT;

     END IF;

 END print_debuginfo;

  PROCEDURE validate_open_batch
  (
  p_bep_id           IN     iby_trxn_summaries_all.bepid%TYPE,
  p_mbatch_id        IN     iby_batches_all.mbatchid%TYPE
  )
  IS

    l_call_string        VARCHAR2(1000);
    l_call_params        JTF_VARCHAR2_TABLE_200 := JTF_VARCHAR2_TABLE_200();
    l_return_status      VARCHAR2(10);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(5000);
    l_trxn_count         NUMBER;

    CURSOR c_valsets(ci_bep_id iby_trxn_summaries_all.bepid%TYPE)
    IS
      SELECT validation_code_package, validation_code_entry_point
      FROM iby_validation_sets_b vs, iby_fndcpt_sys_cc_pf_b pf,
        iby_val_assignments va
      WHERE (vs.validation_code_language = 'PLSQL')
        AND (vs.validation_level_code = 'INSTRUCTION' )
        AND (pf.payment_system_id = ci_bep_id)
        AND (pf.settlement_format_code = va.assignment_entity_id)
        AND (va.val_assignment_entity_type = 'FORMAT')
        AND (va.validation_set_code = vs.validation_set_code)
        AND (NVL(va.inactive_date,SYSDATE-100) < SYSDATE);

  BEGIN

    --
    -- first check if any encrypted trxns exist in the batch;
    -- if so, then the security key must be present for the batch
    -- close to continue
    --

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             print_debuginfo('validate_ob', 'p_mbatch_id = ' || p_mbatch_id);
     END IF;

    SELECT COUNT(transactionid)
      INTO l_trxn_count
      FROM iby_batches_all ba, iby_trxn_summaries_all ts
      WHERE (ba.mbatchid = p_mbatch_id)
        AND (ba.payeeid = ts.payeeid)
        AND (ba.batchid = ts.batchid);
     --
     -- batch cannot be empty
     --
     IF (l_trxn_count < 1) THEN
       raise_application_error(-20000,'IBY_50314',FALSE);
     END IF;

     l_call_params.extend(6);
     l_call_params(1) := '1';
     l_call_params(2) := '''' || FND_API.G_TRUE || '''';
     l_call_params(3) := TO_CHAR(p_mbatch_id);
     l_call_params(4) := '';
     l_call_params(5) := '';
     l_call_params(6) := '';

     FOR cp IN c_valsets(p_bep_id) LOOP
       l_call_string :=
         iby_utility_pvt.get_call_exec(cp.validation_code_package,
                                       cp.validation_code_entry_point,
                                       l_call_params);
       EXECUTE IMMEDIATE l_call_string USING
         OUT l_return_status,
         OUT l_msg_count,
         OUT l_msg_data;

       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          raise_application_error(-20000,
            'IBY_20220#ERRMSG=' || fnd_msg_pub.get(p_msg_index => 1,p_encoded => FND_API.G_FALSE),
            FALSE);
       END IF;
     END LOOP;

  END validate_open_batch;


END IBY_TRANSACTIONEFT_PKG;


/
