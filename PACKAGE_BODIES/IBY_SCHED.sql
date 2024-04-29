--------------------------------------------------------
--  DDL for Package Body IBY_SCHED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_SCHED" as
/*$Header: ibyscfib.pls 120.4.12010000.7 2009/07/08 08:44:33 sugottum ship $*/

TYPE ecapp_rec_type IS RECORD (
  ecappid NUMBER,
  app_short_name VARCHAR2(100)
);
TYPE ecappTabType IS TABLE OF ecapp_rec_type INDEX BY BINARY_INTEGER;

procedure cardInfo (in_payerinstrid in iby_trans_fi_v.payerinstrid%type,
                    in_payeeid in iby_trans_fi_v.payeeid%type,
                    in_tangibleid in iby_trans_fi_v.tangibleid%type,
                    out_ccnumber_from out nocopy iby_creditcard_v.ccnumber%type,
                    out_expdate_from out nocopy iby_creditcard_v.expirydate%type,
                    out_accttype_from out nocopy iby_accttype.accttype%type,
                    out_name out nocopy varchar2,
                    out_bankid_to out nocopy iby_ext_bank_accounts_v.bank_party_id%type,
                    out_branchid_to out nocopy iby_ext_bank_accounts_v.branch_party_id%type,
                    out_acctid_to out nocopy iby_ext_bank_accounts_v.ext_bank_account_id%type,
                    out_accttype_to out nocopy iby_accttype.accttype%type,
                    out_acctno out nocopy iby_tangible.acctno%type,
                    out_refinfo out nocopy iby_tangible.refinfo%type,
                    out_memo out nocopy iby_tangible.memo%type,
                    out_currency out nocopy iby_tangible.currencynamecode%type)
is
cursor c_userCardInfo (cin_payerinstrid in iby_trans_fi_v.payerinstrid%type) is

    select ccnumber,
           expirydate,
           accttype
    from iby_creditcard_v c,
	 iby_trxn_summaries_all d
    where d.payerinstrid = cin_payerinstrid
      and d.payerinstrid = c.instrid;

cursor c_payeeBankInfo (cin_payeeid in iby_trans_fi_v.payeeid%type) is
    select b.bank_party_id,
           b.branch_party_id,
           b.ext_bank_account_id,
           b.bank_account_type
    from iby_ext_bank_accounts_v b,
	 iby_trxn_summaries_all d
    where d.payeeid = cin_payeeid
      and d.payeeinstrid = b.ext_bank_account_id;

cursor c_tangibleInfo (cin_tangibleid in iby_trans_fi_v.tangibleid%type) is
    select acctno,
           refinfo,
           memo,
           currencynamecode
    from iby_tangible t
    where t.tangibleid = cin_tangibleid;
BEGIN
-- get the user's credit card information
open c_userCardInfo(in_payerinstrid);
fetch c_userCardInfo into out_ccnumber_from,
                          out_expdate_from,
                          out_accttype_from;
if c_userCardInfo%NOTFOUND
then raise_application_error(-20099, 'No user credit card info found');
end if;
close c_userCardInfo;

-- get the payee's bank account information
open c_payeeBankInfo(in_payeeid);
fetch c_payeeBankInfo into out_bankid_to,
                           out_branchid_to,
                           out_acctid_to,
                           out_accttype_to;
if c_payeeBankInfo%NOTFOUND then
    raise_application_error(-20092, 'No payee bank account info found');
end if;
close c_payeeBankInfo;
-- get the tangible information
open c_tangibleInfo(in_tangibleid);
fetch c_tangibleInfo into out_acctno,
                          out_refinfo,
                          out_memo,
                          out_currency;
if c_tangibleInfo%NOTFOUND
then raise_application_error(-20093, 'No tangible info found');
end if;
close c_tangibleInfo;
end cardInfo;

procedure bankInfo (in_payerinstrid in iby_trans_fi_v.payerinstrid%type,
                    in_payeeid in iby_trans_fi_v.payeeid%type,
                    in_tangibleid in iby_trans_fi_v.tangibleid%type,
                    out_bankid_from out nocopy iby_ext_bank_accounts_v.bank_party_id%type,
                    out_branchid_from out nocopy iby_ext_bank_accounts_v.branch_party_id%type,
                    out_acctid_from out nocopy iby_ext_bank_accounts_v.ext_bank_account_id%type,
                    out_accttype_from out nocopy iby_accttype.accttype%type,
                    out_name out nocopy varchar2,
                    out_bankid_to out nocopy iby_ext_bank_accounts_v.bank_party_id%type,
                    out_branchid_to out nocopy iby_ext_bank_accounts_v.branch_party_id%type,
                    out_acctid_to out nocopy iby_ext_bank_accounts_v.ext_bank_account_id%type,
                    out_accttype_to out nocopy iby_accttype.accttype%type,
                    out_acctno out nocopy iby_tangible.acctno%type,
                    out_refinfo out nocopy iby_tangible.refinfo%type,
                    out_memo out nocopy iby_tangible.memo%type,
                    out_currency out nocopy iby_tangible.currencynamecode%type)
is
cursor c_userBankInfo (cin_payerinstrid in iby_trans_fi_v.payerinstrid%type) is

    select b.bank_party_id,
           b.branch_party_id,
           b.ext_bank_account_id,
           b.bank_account_type
    from iby_ext_bank_accounts_v b,
         iby_trxn_summaries_all d
    where d.payerinstrid = cin_payerinstrid
      and d.payerinstrid = b.ext_bank_account_id;


cursor c_payeeBankInfo (cin_payeeid in iby_trans_fi_v.payeeid%type) is
    select b.bank_party_id,
           b.branch_party_id,
           b.ext_bank_account_id,
           b.bank_account_type
    from iby_ext_bank_accounts_v b,
	 iby_trxn_summaries_all d
    where d.payeeid = cin_payeeid
      and d.payeeinstrid = b.ext_bank_account_id;

cursor c_tangibleInfo (cin_tangibleid in iby_trans_fi_v.tangibleid%type) is
    select acctno,
           refinfo,
           memo,
           currencynamecode
    from iby_tangible t
    where t.tangibleid = cin_tangibleid;
begin
-- get the user's bank account information
open c_userBankInfo (in_payerinstrid);
fetch c_userBankInfo into out_bankid_from,
                          out_branchid_from,
                          out_acctid_from,
                          out_accttype_from;
if c_userBankInfo%NOTFOUND
then raise_application_error(-20094, 'No user bank account info found');
end if;
close c_userBankInfo;

-- get the payee's bank account information
open c_payeeBankInfo (in_payeeid);
fetch c_payeeBankInfo into out_bankid_to,
                           out_branchid_to,
                           out_acctid_to,
                           out_accttype_to;
if c_payeeBankInfo%NOTFOUND
then raise_application_error(-20092, 'No payee bank account info found');
end if;
close c_payeeBankInfo;
-- get the tangible information
open c_tangibleInfo (in_tangibleid);
fetch c_tangibleInfo into out_acctno,
                          out_refinfo,
                          out_memo,
                          out_currency;
if c_tangibleInfo%NOTFOUND
then raise_application_error(-20093, 'No tangible info found');
end if;
close c_tangibleInfo;
end bankInfo;


-- Overloaded procedure
procedure update_ecapp is
TYPE txn_mid_TabTyp is TABLE OF iby_trans_core_v.trxnmid%TYPE
    INDEX BY BINARY_INTEGER;

o_status  		VARCHAR2(80);
o_errcode 		VARCHAR2(80);
o_errmsg 		VARCHAR2(80);

txn_id_Tab	        JTF_VARCHAR2_TABLE_100;
Status_Tab		JTF_NUMBER_TABLE;
reqtype_Tab		JTF_VARCHAR2_TABLE_100;
updatedt_Tab		JTF_DATE_TABLE;
refcode_Tab		JTF_VARCHAR2_TABLE_100;
o_statusindiv_Tab	JTF_VARCHAR2_TABLE_100;

txn_mid_Tab 		txn_mid_TabTyp;

-- String and cursors for dynamic PL/SQL
ecapp_name		VARCHAR2(30);
v_procString		VARCHAR2(1000);
v_NumRows		INTEGER;
totalRows		INTEGER;
extendRows              INTEGER:=1;
l_dbg_mod VARCHAR2(100) := 'iby.plsql.IBY_SCHED.update_ecapp';
  i NUMBER := 0;
l_objectCount           INTEGER;
l_recordCounter         NUMBER:=0;
l_object_owner          VARCHAR2(100);

CURSOR ecapp_cursor(cin_owner VARCHAR2) IS
    SELECT distinct(a.ECAPPID),
                   a.APPLICATION_SHORT_NAME FROM IBY_ECAPP_V a
    WHERE EXISTS
      (SELECT * FROM dba_objects b WHERE
       b.object_name = a.application_short_name || '_ECAPP_PKG' and
       owner=cin_owner);

  -- Updated the where clause so that the transactions initiated from
  -- OM will also be picked up this cursor (bug# 8239041)
  CURSOR c_trans_core  (cin_ecappid in iby_ecapp.ecappid%type) IS
   SELECT iby_trans_core_v.TRANSACTIONID,
	  iby_trans_core_v.STATUS,
	  iby_trans_core_v.UPDATEDATE,
	  iby_trans_core_v.REQTYPE,
	  iby_trans_core_v.REFERENCECODE,
	  iby_trans_core_v.TRXNMID
     FROM iby_trans_core_v
    WHERE iby_trans_core_v.needsupdt IN ('Y','F')
      --AND iby_trans_core_v.ecappid = DECODE(cin_ecappid, '222', cin_ecappid, iby_trans_core_v.ecappid);
      AND iby_trans_core_v.ecappid = DECODE(cin_ecappid, '222', iby_trans_core_v.ecappid,cin_ecappid);

  CURSOR c_trans_fi (cin_ecappid in iby_ecapp.ecappid%type) IS
   SELECT iby_trans_fi_v.TRANSACTIONID,
	  iby_trans_fi_v.STATUS,
	  iby_trans_fi_v.UPDATEDATE,
	  iby_trans_fi_v.REQTYPE,
	  iby_trans_fi_v.REFERENCECODE,
	  iby_trans_fi_v.TRXNMID
     FROM iby_trans_fi_v
    WHERE iby_trans_fi_v.needsupdt IN ('Y','F')
      AND iby_trans_fi_v.ecappid = cin_ecappid;

  CURSOR c_trans_bankacct (cin_ecappid in iby_ecapp.ecappid%type) IS
   SELECT iby_trans_bankacct_v.TRANSACTIONID,
	  iby_trans_bankacct_v.STATUS,
	  iby_trans_bankacct_v.UPDATEDATE,
	  iby_trans_bankacct_v.REQTYPE,
	  iby_trans_bankacct_v.REFERENCECODE,
	  iby_trans_bankacct_v.TRXNMID
     FROM iby_trans_bankacct_v
    WHERE iby_trans_bankacct_v.needsupdt IN ('Y','F')
      AND iby_trans_bankacct_v.ecappid = cin_ecappid;

  CURSOR c_trans_pcard (cin_ecappid in iby_ecapp.ecappid%type) IS
   SELECT iby_trans_pcard_v.TRANSACTIONID,
          iby_trans_pcard_v.STATUS,
          iby_trans_pcard_v.UPDATEDATE,
          iby_trans_pcard_v.REQTYPE,
          iby_trans_pcard_v.REFERENCECODE,
          iby_trans_pcard_v.TRXNMID
     FROM iby_trans_pcard_v
    WHERE iby_trans_pcard_v.needsupdt IN ('Y','F')
      AND iby_trans_pcard_v.ecappid = cin_ecappid;

   l_ecappTab ecappTabType;
   l_ecapp_rec ecapp_rec_type;

BEGIN
   -- Bug# 8663985
   IF (ecapp_cursor%ISOPEN) THEN CLOSE ecapp_cursor; END IF;
   -- Must specify owner when accessing DBA_ and ALL_ views
   -- Retrieve the owner name and pass it to the cursor
   select oracle_username into l_object_owner
	from fnd_oracle_userid
	where read_only_flag = 'U';

   OPEN ecapp_cursor(l_object_owner);
   FETCH ecapp_cursor BULK COLLECT INTO l_ecappTab;

   txn_id_Tab := JTF_VARCHAR2_TABLE_100();
   Status_Tab := JTF_NUMBER_TABLE();
   reqtype_Tab := JTF_VARCHAR2_TABLE_100();
   updatedt_Tab := JTF_DATE_TABLE();
   refcode_Tab := JTF_VARCHAR2_TABLE_100();
   o_statusindiv_Tab :=	JTF_VARCHAR2_TABLE_100();

   iby_debug_pub.add('l_ecappTab.COUNT:' || l_ecappTab.COUNT,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

   IF(l_ecappTab.COUNT>0) THEN
	FOR j in l_ecappTab.FIRST..l_ecappTab.LAST LOOP
	  l_ecapp_rec:=l_ecappTab(j);

	  iby_debug_pub.add('Fetching records for ECAPPID:' ||
	  l_ecapp_rec.ecappid,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

	  FOR r_trans_core IN c_trans_core(l_ecapp_rec.ecappid) LOOP
	      l_recordCounter := l_recordCounter + 1;
	      txn_id_Tab.extend(extendRows);
	      txn_id_Tab(l_recordCounter)   := to_char(r_trans_core.TRANSACTIONID);
	      Status_Tab.extend(extendRows);
	      Status_Tab(l_recordCounter)   := r_trans_core.STATUS;
	      reqtype_Tab.extend(extendRows);
	      reqtype_Tab(l_recordCounter)  := r_trans_core.REQTYPE;
	      updatedt_Tab.extend(extendRows);
	      updatedt_Tab(l_recordCounter) := r_trans_core.UPDATEDATE;
	      refcode_Tab.extend(extendRows);
	      refcode_Tab(l_recordCounter)  := r_trans_core.REFERENCECODE;
	      txn_mid_Tab(l_recordCounter)  := r_trans_core.TRXNMID;
	   END LOOP;

	  FOR r_trans_fi IN c_trans_fi(l_ecapp_rec.ecappid) LOOP
	      l_recordCounter := l_recordCounter + 1;
	      txn_id_Tab.extend(extendRows);
	      txn_id_Tab(l_recordCounter)   := to_char(r_trans_fi.TRANSACTIONID);
	      Status_Tab.extend(extendRows);
	      Status_Tab(l_recordCounter)   := r_trans_fi.STATUS;
	      reqtype_Tab.extend(extendRows);
	      reqtype_Tab(l_recordCounter)  := r_trans_fi.REQTYPE;
	      updatedt_Tab.extend(extendRows);
	      updatedt_Tab(l_recordCounter) := r_trans_fi.UPDATEDATE;
	      refcode_Tab.extend(extendRows);
	      refcode_Tab(l_recordCounter)  := r_trans_fi.REFERENCECODE;
	      txn_mid_Tab(l_recordCounter)  := r_trans_fi.TRXNMID;
	  END LOOP;

	  FOR r_trans_bankacct IN c_trans_bankacct(l_ecapp_rec.ecappid) LOOP
	      l_recordCounter := l_recordCounter + 1;
	      txn_id_Tab.extend(extendRows);
	      txn_id_Tab(l_recordCounter)   := to_char(r_trans_bankacct.TRANSACTIONID);
	      Status_Tab.extend(extendRows);
	      Status_Tab(l_recordCounter)   := r_trans_bankacct.STATUS;
	      reqtype_Tab.extend(extendRows);
	      reqtype_Tab(l_recordCounter)  := r_trans_bankacct.REQTYPE;
	      updatedt_Tab.extend(extendRows);
	      updatedt_Tab(l_recordCounter) := r_trans_bankacct.UPDATEDATE;
	      refcode_Tab.extend(extendRows);
	      refcode_Tab(l_recordCounter)  := r_trans_bankacct.REFERENCECODE;
	      txn_mid_Tab(l_recordCounter)  := r_trans_bankacct.TRXNMID;
	  END LOOP;

	  FOR r_trans_pcard IN c_trans_pcard(l_ecapp_rec.ecappid) LOOP
	      l_recordCounter := l_recordCounter + 1;
	      txn_id_Tab.extend(extendRows);
	      txn_id_Tab(l_recordCounter)   := to_char(r_trans_pcard.TRANSACTIONID);
	      Status_Tab.extend(extendRows);
	      Status_Tab(l_recordCounter)   := r_trans_pcard.STATUS;
	      reqtype_Tab.extend(extendRows);
	      reqtype_Tab(l_recordCounter)  := r_trans_pcard.REQTYPE;
	      updatedt_Tab.extend(extendRows);
	      updatedt_Tab(l_recordCounter) := r_trans_pcard.UPDATEDATE;
	      refcode_Tab.extend(extendRows);
	      refcode_Tab(l_recordCounter)  := r_trans_pcard.REFERENCECODE;
	      txn_mid_Tab(l_recordCounter)  := r_trans_pcard.TRXNMID;
	  END LOOP;
	END LOOP;
    END IF;
 /*
  * Add begin-end block around dynamic ecapp call. This is to
  * handle gracefully the exception that is caused when the
  * ecapp_pkg.update_status() method does not exist.
  *
  * Fix for bug 3883880 - rameshsh
  */
 BEGIN
 IF(l_ecappTab.COUNT>0) THEN
  FOR j in l_ecappTab.FIRST..l_ecappTab.LAST LOOP
   l_ecapp_rec:=l_ecappTab(j);
   iby_debug_pub.add('application_short_name:' || l_ecapp_rec.app_short_name,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
    IF (l_recordCounter <> 0) then
--   Now dynamically construct the procedure name and invoke it

     -- The procedure string
     v_procString :=  'BEGIN '|| l_ecapp_rec.app_short_name || '_ecapp_pkg.update_status( :1, :2, :3, :4, :5, :6, :7, :8, :9, :10); END; ';

    -- dbms_output.put_line('Proc call: ' || v_procString);
    if(l_ecapp_rec.app_short_name = 'AR') then
      iby_debug_pub.add('Invoking update_status Procedure for the application:' ||
      l_ecapp_rec.app_short_name,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
    end if;
    iby_debug_pub.add('record counter:' || l_recordCounter,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

    EXECUTE IMMEDIATE v_procString USING  IN l_recordCounter,
	                                  IN txn_id_Tab,
	                                  IN reqtype_Tab,
					  IN Status_Tab,
					  IN updatedt_Tab,
					  IN refcode_Tab,
				          OUT o_status,
				          OUT o_errcode,
					  OUT o_errmsg,
					  IN OUT o_statusindiv_Tab;

   iby_debug_pub.add('update_status has been executed for :'||
   l_ecapp_rec.app_short_name ,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

  -- Doing the bulk update instead of Row-by-Row
   FORALL j IN 1..l_recordCounter
	UPDATE iby_trxn_summaries_all
	      SET NeedsUpdt = DECODE(upper(o_statusindiv_Tab(j)), 'TRUE', 'N', 'F')
	      WHERE trxnmid = txn_mid_Tab(j);
	iby_debug_pub.add('Updation of iby_trxn_summaries_all successful' ,
	iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

     END IF;
    END LOOP;
  END IF;
  EXCEPTION
      WHEN OTHERS THEN

      /*
       * If we reached here it means that either the ecapp name does not
       * exist in iby_ecapp_v, or that the procedure ecapp_pkg.update_status
       * does not exist. Both these are ok. Swallow the exception and
       * all procedure to exit gracefully. Fix for bug 3883880.
       */
      --iby_debug_pub.add('Exception Occurred: Either the ecapp name does not exist ||
      --|| in iby_ecapp_v, or that the procedure ecapp_pkg.update_status does not exist'|| sqlerrm ,
      --iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
      NULL;

  END;

  commit;

EXCEPTION
WHEN OTHERS THEN
   FOR k IN 1..i LOOP
      UPDATE iby_trxn_summaries_all
      SET    NeedsUpdt = 'F'
      WHERE  trxnmid = txn_mid_Tab(k);
   END LOOP;
   commit;
   raise_application_error(-20000, 'IBY_204610#ECAPP=' || l_ecapp_rec.app_short_name , FALSE );
end update_ecapp;
-- End of Overloaded Procedure

procedure update_ecapp (in_ecappid in iby_ecapp.ecappid%type)
is


TYPE txn_mid_TabTyp is TABLE OF iby_trans_core_v.trxnmid%TYPE
    INDEX BY BINARY_INTEGER;

o_status  		VARCHAR2(80);
o_errcode 		VARCHAR2(80);
o_errmsg 		VARCHAR2(80);

txn_id_Tab	        JTF_VARCHAR2_TABLE_100;
Status_Tab		JTF_NUMBER_TABLE;
reqtype_Tab		JTF_VARCHAR2_TABLE_100;
updatedt_Tab		JTF_DATE_TABLE;
refcode_Tab		JTF_VARCHAR2_TABLE_100;
o_statusindiv_Tab	JTF_VARCHAR2_TABLE_100;

txn_mid_Tab 		txn_mid_TabTyp;

-- String and cursors for dynamic PL/SQL
ecapp_name		VARCHAR2(30);
v_procString		VARCHAR2(1000);
v_NumRows		INTEGER;
totalRows		INTEGER;
extendRows              INTEGER:=1;
l_dbg_mod VARCHAR2(100) := 'iby.plsql.IBY_SCHED.update_ecapp';
i NUMBER := 0;

  -- Updated the where clause so that the transactions initiated from
  -- OM will also be picked up this cursor (bug# 8239041)
  CURSOR c_trans_core  (cin_ecappid in iby_ecapp.ecappid%type) IS
   SELECT iby_trans_core_v.TRANSACTIONID,
	  iby_trans_core_v.STATUS,
	  iby_trans_core_v.UPDATEDATE,
	  iby_trans_core_v.REQTYPE,
	  iby_trans_core_v.REFERENCECODE,
	  iby_trans_core_v.TRXNMID
     FROM iby_trans_core_v
    WHERE iby_trans_core_v.needsupdt IN ('Y','F')
      --AND iby_trans_core_v.ecappid = DECODE(cin_ecappid, '222', cin_ecappid, iby_trans_core_v.ecappid);
      AND iby_trans_core_v.ecappid = DECODE(cin_ecappid, '222', iby_trans_core_v.ecappid,cin_ecappid);


  CURSOR c_trans_fi (cin_ecappid in iby_ecapp.ecappid%type) IS
   SELECT iby_trans_fi_v.TRANSACTIONID,
	  iby_trans_fi_v.STATUS,
	  iby_trans_fi_v.UPDATEDATE,
	  iby_trans_fi_v.REQTYPE,
	  iby_trans_fi_v.REFERENCECODE,
	  iby_trans_fi_v.TRXNMID
     FROM iby_trans_fi_v
    WHERE iby_trans_fi_v.needsupdt IN ('Y','F')
      AND iby_trans_fi_v.ecappid = cin_ecappid;

   -- r_trans_fi c_trans_fi%ROWTYPE;

  CURSOR c_trans_bankacct (cin_ecappid in iby_ecapp.ecappid%type) IS
   SELECT iby_trans_bankacct_v.TRANSACTIONID,
	  iby_trans_bankacct_v.STATUS,
	  iby_trans_bankacct_v.UPDATEDATE,
	  iby_trans_bankacct_v.REQTYPE,
	  iby_trans_bankacct_v.REFERENCECODE,
	  iby_trans_bankacct_v.TRXNMID
     FROM iby_trans_bankacct_v
    WHERE iby_trans_bankacct_v.needsupdt IN ('Y','F')
      AND iby_trans_bankacct_v.ecappid = cin_ecappid;

   -- r_trans_bankacct c_trans_bankacct%ROWTYPE;

  CURSOR c_trans_pcard (cin_ecappid in iby_ecapp.ecappid%type) IS
   SELECT iby_trans_pcard_v.TRANSACTIONID,
          iby_trans_pcard_v.STATUS,
          iby_trans_pcard_v.UPDATEDATE,
          iby_trans_pcard_v.REQTYPE,
          iby_trans_pcard_v.REFERENCECODE,
          iby_trans_pcard_v.TRXNMID
     FROM iby_trans_pcard_v
    WHERE iby_trans_pcard_v.needsupdt IN ('Y','F')
      AND iby_trans_pcard_v.ecappid = cin_ecappid;

BEGIN
   txn_id_Tab := JTF_VARCHAR2_TABLE_100();
   Status_Tab := JTF_NUMBER_TABLE();
   reqtype_Tab := JTF_VARCHAR2_TABLE_100();
   updatedt_Tab := JTF_DATE_TABLE();
   refcode_Tab := JTF_VARCHAR2_TABLE_100();
   o_statusindiv_Tab :=	JTF_VARCHAR2_TABLE_100();

   -- Commented out the below piece of code as extending the tables upfront
   -- may cause serious performance issues and also mismatch between the number
   -- of columns initialized in the pl/sql table and the actual values sent
   -- across to the calling API. Changed the logic so that the extension of table
   -- happens as and when it is required. By doing that we can minimize the usage
   -- of select query for retrieving the totalrows.
   -- For e.g, consider a typical example:
   -- 1. count(*) from iby_trxn_summaries_all retrieves 838
   -- 2. JTF tables get initialized with this number
   -- 3. The "i" value in the For loops is "145" in this scenario
   -- 4. The remaining elements in the JTF table is null
   -- 5. To avoid this the tables are getting extended in the loop itself.

   -- finding the total number of rows
   --SELECT count(*)
   --INTO totalRows
   --FROM iby_trxn_summaries_all
   --WHERE needsupdt IN ('Y','F')
   --AND ecappid = in_ecappid;

   --IF( totalRows < 1 ) THEN
      --RETURN;
  --else
  --iby_debug_pub.add('Total Rows:' || totalRows,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
  --iby_debug_pub.add('ecappid:' || in_ecappid,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
  --END IF;

   --allocation number of elements based on count
   --dbms_output.put_line('Total Rows: ' || totalRows);
   --txn_id_Tab.extend(totalRows);
   --Status_Tab.extend(totalRows);
   --reqtype_Tab.extend(totalRows);
   --updatedt_Tab.extend(totalRows);
   --refcode_Tab.extend(totalRows);
   --o_statusindiv_Tab.extend(totalRows);

   FOR r_trans_core IN c_trans_core(in_ecappid) LOOP
      i := i + 1;

      txn_id_Tab.extend(extendRows);
      txn_id_Tab(i)   := to_char(r_trans_core.TRANSACTIONID);
      Status_Tab.extend(extendRows);
      Status_Tab(i)   := r_trans_core.STATUS;
      reqtype_Tab.extend(extendRows);
      reqtype_Tab(i)  := r_trans_core.REQTYPE;
      updatedt_Tab.extend(extendRows);
      updatedt_Tab(i) := r_trans_core.UPDATEDATE;
      refcode_Tab.extend(extendRows);
      refcode_Tab(i)  := r_trans_core.REFERENCECODE;
      txn_mid_Tab(i)  := r_trans_core.TRXNMID;
   END LOOP;

  FOR r_trans_fi IN c_trans_fi(in_ecappid) LOOP
      i := i + 1;

      txn_id_Tab.extend(extendRows);
      txn_id_Tab(i)   := to_char(r_trans_fi.TRANSACTIONID);
      Status_Tab.extend(extendRows);
      Status_Tab(i)   := r_trans_fi.STATUS;
      reqtype_Tab.extend(extendRows);
      reqtype_Tab(i)  := r_trans_fi.REQTYPE;
      updatedt_Tab.extend(extendRows);
      updatedt_Tab(i) := r_trans_fi.UPDATEDATE;
      refcode_Tab.extend(extendRows);
      refcode_Tab(i)  := r_trans_fi.REFERENCECODE;
      txn_mid_Tab(i)  := r_trans_fi.TRXNMID;

   END LOOP;

  FOR r_trans_bankacct IN c_trans_bankacct(in_ecappid) LOOP
      i := i + 1;

      txn_id_Tab.extend(extendRows);
      txn_id_Tab(i)   := to_char(r_trans_bankacct.TRANSACTIONID);
      Status_Tab.extend(extendRows);
      Status_Tab(i)   := r_trans_bankacct.STATUS;
      reqtype_Tab.extend(extendRows);
      reqtype_Tab(i)  := r_trans_bankacct.REQTYPE;
      updatedt_Tab.extend(extendRows);
      updatedt_Tab(i) := r_trans_bankacct.UPDATEDATE;
      refcode_Tab.extend(extendRows);
      refcode_Tab(i)  := r_trans_bankacct.REFERENCECODE;
      txn_mid_Tab(i)  := r_trans_bankacct.TRXNMID;

   END LOOP;

  FOR r_trans_pcard IN c_trans_pcard(in_ecappid) LOOP
      i := i + 1;

      txn_id_Tab.extend(extendRows);
      txn_id_Tab(i)   := to_char(r_trans_pcard.TRANSACTIONID);
      Status_Tab.extend(extendRows);
      Status_Tab(i)   := r_trans_pcard.STATUS;
      reqtype_Tab.extend(extendRows);
      reqtype_Tab(i)  := r_trans_pcard.REQTYPE;
      updatedt_Tab.extend(extendRows);
      updatedt_Tab(i) := r_trans_pcard.UPDATEDATE;
      refcode_Tab.extend(extendRows);
      refcode_Tab(i)  := r_trans_pcard.REFERENCECODE;
      txn_mid_Tab(i)  := r_trans_pcard.TRXNMID;

   END LOOP;

 /*
  * Add begin-end block around dynamic ecapp call. This is to
  * handle gracefully the exception that is caused when the
  * ecapp_pkg.update_status() method does not exist.
  *
  * Fix for bug 3883880 - rameshsh
  */
 BEGIN

  -- Now getting the application short name
  iby_debug_pub.add('Enter update_ecapp:',iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
  -- The view iby_ecapp_v has two records for each of the ecappid's. To avoid
  -- the possible exception, using distinct function
  SELECT distinct(application_short_name)
   INTO  ecapp_name
   FROM  iby_ecapp_v
   WHERE ecappid = in_ecappid;
   iby_debug_pub.add('application_short_name:' || ecapp_name,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
   -- dbms_output.put_line('Total count for inner loop : ' || i);
   --dbms_output.put_line('Sending in  : ' || txn_id_Tab(1) ||'** ' ||Status_Tab(1) ||'** '|| updatedt_Tab(1) || '** '|| refcode_Tab(1) ||'** '|| txn_mid_Tab(1));
   --iby_debug_pub.add('I value:' || i,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
    IF (i <> 0) then

--   Now dynamically construct the procedure name and invoke it

     -- The procedure string
     v_procString :=  'BEGIN '|| ecapp_name || '_ecapp_pkg.update_status( :1, :2, :3, :4, :5, :6, :7, :8, :9, :10); END; ';

    -- dbms_output.put_line('Proc call: ' || v_procString);
    if(ecapp_name = 'AR') then
      iby_debug_pub.add('Invoking update_status Procedure for the application:' ||
      ecapp_name,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
    end if;
    EXECUTE IMMEDIATE v_procString USING  IN i,
	                                  IN txn_id_Tab,
	                                  IN reqtype_Tab,
					  IN Status_Tab,
					  IN updatedt_Tab,
					  IN refcode_Tab,
				          OUT o_status,
				          OUT o_errcode,
					  OUT o_errmsg,
					  IN OUT o_statusindiv_Tab;
   iby_debug_pub.add('update_status has been executed for :'||
   ecapp_name ,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

  -- Doing the bulk update instead of Row-by-Row
   FORALL j IN 1..i
   --if (o_statusindiv_Tab(j) = 'TRUE') then
   	UPDATE iby_trxn_summaries_all
              SET NeedsUpdt = DECODE(upper(o_statusindiv_Tab(j)), 'TRUE', 'N', 'F')
              WHERE trxnmid = txn_mid_Tab(j);
   --else
   --	UPDATE iby_trxn_summaries_all
     --             SET NeedsUpdt = 'F'
       --           WHERE trxnmid = txn_mid_Tab(j);
   --end if;
   --END LOOP;
   iby_debug_pub.add('Updation of iby_trxn_summaries_all successful' ,iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

  END IF;

  EXCEPTION
      WHEN OTHERS THEN

      /*
       * If we reached here it means that either the ecapp name does not
       * exist in iby_ecapp_v, or that the procedure ecapp_pkg.update_status
       * does not exist. Both these are ok. Swallow the exception and
       * all procedure to exit gracefully. Fix for bug 3883880.
       */
      --iby_debug_pub.add('Exception Occurred: Either the ecapp name does not exist ||
      --|| in iby_ecapp_v, or that the procedure ecapp_pkg.update_status does not exist'|| sqlerrm ,
      --iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
      NULL;

  END;

  commit;

EXCEPTION
WHEN OTHERS THEN
   FOR k IN 1..i LOOP
      UPDATE iby_trxn_summaries_all
      SET    NeedsUpdt = 'F'
      WHERE  trxnmid = txn_mid_Tab(k);
   END LOOP;
   commit;
   raise_application_error(-20000, 'IBY_204610#ECAPP=' || ecapp_name , FALSE );

end update_ecapp;


function updPmtStatus (in_psreqid in iby_trxn_fi.psreqid%type,
                        in_dtpmtprc in varchar2, -- YYYYMMDD
                        in_pmtprcst in varchar2, -- 'PAID','UNPAID','FAILED','PAYFAILED'
                        in_srvrid in iby_trxn_fi.srvid%type,
                        in_refinfo in iby_trxn_fi.referencecode%type)
   return number -- nonzero if rows were updated.
is
begin
 update iby_trxn_summaries_all
  set status = decode(in_pmtprcst, 'PAID', 0, 'UNPAID', 17, 'FAILED',
                      16, 'PAYFAILED', 16, 16),
      updatedate = to_date(in_dtpmtprc,'YYYYMMDD'),  needsupdt = 'Y'
  where trxnmid in
     (select trxnmid from iby_trxn_fi where psreqid = in_psreqid);
 if SQL%NOTFOUND
  then return 0;
 end if;
 update iby_trxn_fi set srvid = in_srvrid, referencecode = in_refinfo
  where psreqid = in_psreqid;
 if SQL%NOTFOUND
  then return 0;
 end if;
 return 1;
end updPmtStatus;

-- This procedure updates the transaction information after it has been processed
-- and updates the needsUpdate flag to 'Y' so that ECApps are updated with proper
-- information.

 procedure update_trxn_status( i_unchanged_status            IN    NUMBER,
                               i_numTrxns                    IN    NUMBER,
                               i_status_arr                  IN    JTF_NUMBER_TABLE,
                               i_errLoc_arr                  IN    JTF_NUMBER_TABLE,
                               i_errCode_arr                 IN    JTF_VARCHAR2_TABLE_100,
                               i_errMsg_arr                  IN    JTF_VARCHAR2_TABLE_300,
                               i_tangibleId_arr              IN    JTF_VARCHAR2_TABLE_100,
                               i_trxnMId_arr                 IN    JTF_NUMBER_TABLE,
                               i_srvrId_arr                  IN    JTF_VARCHAR2_TABLE_100,
                               i_refCode_arr                 IN    JTF_VARCHAR2_TABLE_100,
                               i_auxMsg_arr                  IN    JTF_VARCHAR2_TABLE_300,
                               i_fee_arr                     IN    JTF_NUMBER_TABLE,
                               o_status_arr                  OUT NOCOPY JTF_NUMBER_TABLE,
                               o_error_code                  OUT NOCOPY NUMBER,
                               o_error_msg                   OUT NOCOPY VARCHAR2
                             )
 IS

    l_index     INTEGER;
    l_status    NUMBER;
    c_FAIL      NUMBER := -1;
    c_SUCCESS   NUMBER := 0;

 BEGIN

    o_status_arr := JTF_NUMBER_TABLE();
    o_status_arr.extend( i_tangibleId_arr.count );

    o_error_code := 0;

    l_index := i_tangibleId_arr.first;

    WHILE (TRUE) LOOP

       l_status := i_status_arr( l_index );
       o_status_arr( l_index ) := c_SUCCESS;

       BEGIN  -- Nested block begins

          UPDATE iby_trxn_summaries_all
          SET    status =  decode( l_status, i_unchanged_status, status, l_status),
                 errorlocation = i_errLoc_arr( l_index ),
                 BEPCode = i_errCode_arr( l_index ),
                 BEPMessage = i_errMsg_arr( l_index ),
                 needsupdt = 'Y'
          WHERE  TANGIBLEID = i_tangibleId_arr( l_index )
          AND    status <> -99;

          IF ( SQL%NOTFOUND ) THEN
             o_status_arr( l_index ) := c_FAIL;
          ELSE
             UPDATE iby_trxn_fi
             SET    referencecode =  i_refCode_arr( l_index ),
                    srvId = i_srvrId_arr( l_index ),
                    AUXMSG = i_auxMsg_arr( l_index ),
                    PROCESSFEE = i_fee_arr( l_index )
             WHERE  TRXNMID = i_trxnMId_arr( l_index );
                    --(SELECT TRXNMID
                     --FROM   IBY_TRXN_SUMMARIES_ALL
                     --WHERE  TANGIBLEID = i_tangibleId_arr( l_index )
                    --);

             IF ( SQL%NOTFOUND ) THEN
                o_status_arr( l_index ) := c_FAIL;
                ROLLBACK;
             END IF;

          END IF;

          IF ( o_status_arr( l_index ) <> c_FAIL ) THEN
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

 END update_trxn_status;

end iby_sched;

/
