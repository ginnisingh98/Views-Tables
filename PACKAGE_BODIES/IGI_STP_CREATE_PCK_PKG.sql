--------------------------------------------------------
--  DDL for Package Body IGI_STP_CREATE_PCK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_STP_CREATE_PCK_PKG" AS
   -- $Header: igistpcb.pls 120.8.12010000.2 2008/08/04 13:08:35 sasukuma ship $
   -- Processing Variables
--following variables added for bug 3199481: fnd logging changes: sdixit
   l_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
   l_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
   l_event_level number	:=	FND_LOG.LEVEL_EVENT;
   l_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
   l_error_level number	:=	FND_LOG.LEVEL_ERROR;
   l_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;




   p_batch_id                     number;
   p_package_id                   number;
   p_netting_trx_type_id          number;
   p_trx_type_class               varchar2(3);
   p_contra_party_id              number;
   p_contra_amount                number;
   l_message                      varchar2(240);
   l_variable                     varchar2(80);
   l_value                        varchar2(2000);
   p_org_id                       number;

   -- get_candidate_packages : to allow processing of
   -- all netting transactions
   --org_id added as part of MOAC uptake
   CURSOR get_candidate_packages IS
      SELECT distinct package_id,
             netting_trx_type_id
      FROM igi_stp_candidates_all
      WHERE batch_id =p_batch_id
      AND org_id = p_org_id;

   -- get_ap_amount : to calculate the sum of the invoice
   --	amounts selected for a package and netting transaction
   CURSOR get_ap_amount IS
      SELECT sum(amount) ap_amount
      FROM igi_stp_candidates
      WHERE batch_id = p_batch_id
      AND application = 'AP'
      AND netting_trx_type_id = p_netting_trx_type_id
      AND package_id = p_package_id;

   -- get_ar_amount : to calculate the sum of the invoice
   --	amounts selected for a package and netting transaction
   CURSOR get_ar_amount IS
      SELECT sum(amount) ar_amount
      FROM igi_stp_candidates_ALL
      WHERE batch_id = p_batch_id
      AND application = 'AR'
      AND ORG_ID = P_ORG_ID
   AND netting_trx_type_id = p_netting_trx_type_id
   AND package_id = p_package_id;

   -- Bug 2938450 (Tpradhan)
   -- Commented the following cursor since it is not in use
   -- get_ap_only_amount : to calculate the sum of the invoice
   -- amounts selected for a package and netting transaction
   /*
   CURSOR get_ap_only_amount IS
      SELECT sum(amount) ap_amount
      FROM igi_stp_candidates cand,
           igi_stp_net_type_alloc net
      WHERE cand.batch_id = p_batch_id
      AND cand.application = 'AP'
      AND cand.netting_trx_type_id = p_netting_trx_type_id
      AND cand.package_id = p_package_id
      AND net.netting_trx_type_id = cand.netting_trx_type_id
      AND net.application = decode(cand.application,'AP','SQLAP',cand.application)
      AND net.trx_type_class = p_trx_type_class;
   */

   -- Bug 2938450 (Tpradhan)
   -- In the Cursors get_ar_candidate_details, get_ap_candidate_details and get_ap_only_candidate_details
   -- the Amount column selected has been modified to now select the difference between the amount and
   -- the current netting amount. This change was made because if only the amount is selected then the
   -- system checks whether the amount being netted is less than the amount fetched through the cursor.
   -- If yes then it adds the amount being netted to the existing netting amount. Thus in a scenario
   -- where the Amount is 5000 and Current Netting Amount is 3000, if the user tries to net a new amount of
   -- 4000 the system accepts it and adds 4000 to the current netting of 3000 thereby leading to a
   -- transaction amount of 5000 and netting amount of 3000 + 4000 = 7000. With the changes now it will
   -- net only 4000 - 3000 which is 1000 to the existing amount of 3000 thus making the total netting
   -- amount to 4000 thereby ensuring that it does not exceed the transaction amount

   -- get_ar_candidate_details : to retrieve the details
   -- of the candidate transactions in order to create package
   -- records
   CURSOR  get_ar_candidate_details IS
      SELECT package_num,
             application,
             trx_id,
             trx_number,
             stp_id,
             site_id,
             reference,
             (amount - netting_amount) Amount,			-- Bug 2938450 (Details of changes on top)
             currency_code,
             exchange_rate,
             exchange_rate_type,
             exchange_date
      FROM igi_stp_candidates
      WHERE batch_id = p_batch_id
      AND package_id = p_package_id
      AND netting_trx_type_id = p_netting_trx_type_id
      AND process_flag = 'S'
      AND application = 'AR';

   -- get_ap_candidate_details : to retrieve the details
   -- of the candidate transactions in order to create package
   -- records
   CURSOR get_ap_candidate_details IS
      SELECT package_num,
             application,
             trx_id,
             trx_number,
             stp_id,
             site_id,
             reference,
             (amount - netting_amount) Amount,			-- Bug 2938450 (Details of changes on top)
             currency_code,
             exchange_rate,
             exchange_rate_type,
             exchange_date
      FROM igi_stp_candidates
      WHERE batch_id = p_batch_id
      AND package_id = p_package_id
      AND netting_trx_type_id = p_netting_trx_type_id
      AND process_flag = 'S'
      AND application = 'AP';

   -- get_ap_only_candidate_details : to retrieve the details
   -- of the candidate transactions for a transaction class
   -- in order to create package records
   CURSOR  get_ap_only_candidate_details IS
      SELECT cand.package_num,
             cand.application,
             cand.trx_id,
             cand.trx_number,
             cand.stp_id,
             cand.site_id,
             cand.reference,
             (cand.amount - cand.netting_amount) Amount,	-- Bug 2938450 (Details of changes on top)
             net.trx_type_class,
             currency_code,
             exchange_rate,
             exchange_rate_type,
             exchange_date
      FROM igi_stp_candidates_all cand,
           igi_stp_net_type_alloc_all net
      WHERE cand.batch_id = p_batch_id
      AND cand.package_id = p_package_id
      AND cand.netting_trx_type_id = p_netting_trx_type_id
      AND cand.process_flag = 'S'
      AND cand.application = 'AP'
      AND net.netting_trx_type_id = cand.netting_trx_type_id
      AND net.application = decode(cand.application,'AP','SQLAP',cand.application)
      AND net.trx_type_class = 'INV'
      and cand.org_id = p_org_id
      and cand.org_id = net.org_id;

   CURSOR get_vendor (p_customer_id in number) is
      select vendor_id from igi_po_vendors
      where customer_id = p_customer_id;

   CURSOR get_vendor_sites(p_vendor_id in number) is
      select vendor_site_id , accts_pay_code_combination_id
      from ap_supplier_sites_all
      where vendor_id = p_vendor_id
      and pay_site_flag = 'Y'
      and org_id = p_org_id
      and rownum = 1;

   CURSOR get_customer (p_vendor_id in number) is
      select customer_id from igi_po_vendors
      where vendor_id = p_vendor_id;

   CURSOR get_customer_sites(p_customer_id in number ) is
    select CSU.site_use_id, gl_id_rec
    from HZ_PARTY_SITES PS,
    HZ_LOCATIONS LOC,
    HZ_CUST_ACCT_SITES_ALL CAS,
    HZ_CUST_SITE_USES  CSU
    where CAS.party_site_id = PS.party_site_id
    AND LOC.location_id = PS.location_id
    and CAS.CUST_ACCOUNT_ID         = p_customer_id
    and   CSU.cust_acct_site_id = CAS.cust_acct_site_id
    and  CSU.site_use_code ='BILL_TO'
    AND  CSU.PRIMARY_FLAG ='Y';



 PROCEDURE feed_packages (p_batch_id                in number,
                          l_package_id              in number,
                          l_package_num             in number,
                          l_org_id                  in number,
                          l_stp_id                  in number,
                          l_site_id                 in number,
                          l_amount                  in number,
                          l_trx_number              in varchar2,
                          l_reference               in varchar2,
                          l_netting_trx_type_id     in number,
                          l_ccid                    in number,
                          l_application             in varchar2,
                          l_trx_type_class          in varchar2,
                          l_currency_code           in varchar2,
                          l_exchange_rate           in number,
                          l_exchange_rate_type      in varchar2,
                          l_exchange_date           in date)
 IS
 l_prefix             varchar2(240);
 local_site_id      number;
-- l_currency_code    varchar2(15);

 cursor   get_ar_site is
    select CSU.site_use_id
    from HZ_PARTY_SITES PS,
    HZ_LOCATIONS LOC,
    HZ_CUST_ACCT_SITES_ALL CAS,
    HZ_CUST_SITE_USES  CSU
    where CAS.party_site_id = PS.party_site_id
    AND LOC.location_id = PS.location_id
    and CAS.CUST_ACCOUNT_ID         = l_stp_id
    and   CSU.cust_acct_site_id = CAS.cust_acct_site_id
    and  CSU.site_use_code ='BILL_TO'
    AND  CSU.PRIMARY_FLAG ='Y';

 --Fwd port bug6743918
 cursor  get_ap_site is
    select  vendor_site_id
    from    ap_supplier_sites_all
    where   vendor_id = l_stp_id
    and     pay_site_flag ='Y'
    and     vendor_site_id = l_site_id
    and     org_id = p_org_id;


 BEGIN

-- Get currency code
/*
if l_application = 'AP'
then
	select invoice_currency_code
	into   l_currency_code
	from	ap_invoices
	where	invoice_num =  l_trx_number;

else
	select invoice_currency_code
	into   l_currency_code
	from	ra_customer_trx
	where	trx_number =  l_trx_number;

end if; */

   -- Get Document Number prefix --
   l_message := 'Get Document Number prefix';
   fnd_profile.get('IGI_STP_NETTING_PREFIX',l_prefix);
   -- Insert into the packages table
   l_message := 'Insert into the packages table';
   if l_netting_trx_type_id in (1,2,4,6)
      then  if l_application = 'AP'
            then    open get_ap_site;
                    fetch get_ap_site into local_site_id;
                    close get_ap_site;

            else
                    open get_ar_site;
                    fetch get_ar_site into local_site_id;
                    close get_ar_site;

            end if;
            else local_site_id :=null;
   end if;

     INSERT INTO igi_stp_packages_all
	( BATCH_ID                 ,
	  PACKAGE_ID               ,
 	  PACKAGE_NUM              ,
 	  ORG_ID		   ,
 	  STP_ID                   ,
          SITE_ID                  ,
   	  APPLICATION              ,
   	  AMOUNT                   ,
 	  ACCOUNTING_DATE   	   ,
 	  TRX_NUMBER               ,
 	  RELATED_TRX_NUMBER       ,
 	  REFERENCE                ,
 	  NETTING_TRX_TYPE_ID      ,
 	  TECHNICAL_CCID           ,
 	  REC_OR_LIAB_CCID         ,
 	  TRX_TYPE_CLASS           ,
 	  DOC_CATEGORY_CODE        ,
 	  DESCRIPTION              ,
          CURRENCY_CODE            ,
          EXCHANGE_RATE            ,
          EXCHANGE_RATE_TYPE       ,
          EXCHANGE_DATE            ,
          CREATED_BY               ,
          CREATION_DATE            ,
          LAST_UPDATED_BY          ,
          LAST_UPDATE_DATE         )
   SELECT
 	  p_batch_id                                 ,
	  l_package_id                               ,
 	  l_package_num                              ,
 	  P_ORG_ID                                   ,
 	  l_stp_id                                   ,
 	  nvl(local_site_Id,l_site_id)               ,
 	  l_application                              ,
 	  l_amount                                   ,
 	  sysdate                                    ,
 	  l_prefix||to_char(igi_stp_trx_s.nextval)   ,
  	  l_trx_number                               ,
 	  l_reference                                ,
 	  l_netting_trx_type_id                      ,
 	  net.netting_expense_ccid     	             ,
 	  l_ccid                                     ,
 	  l_trx_type_class                           ,
 	  net.doc_category_code                      ,
 	  net.netting_trx_type_id                    ,
	  l_currency_code                            ,
          l_exchange_rate                            ,
          l_exchange_rate_type                       ,
          l_exchange_date                            ,
          -1                                         ,
          sysdate                                    ,
          -1                                         ,
          sysdate
  FROM  igi_stp_net_type_alloc_ALL net
  WHERE net.netting_trx_type_id = l_netting_trx_type_id
  AND   net.application = decode(l_application,'AP', 'SQLAP',l_application)
  AND   net.trx_type_class = l_trx_type_class
  AND ORG_ID = P_ORG_ID;

  EXCEPTION
  WHEN OTHERS THEN
--      fnd_message.set_name('IGI', 'MRC_SYSTEM_OPTIONS_NOT_FOUND');
--      fnd_message.set_token('MODULE','STEP 1');
--      RAISE_APPLICATION_ERROR(-20010, fnd_message.get);

      --bug 3199481 fnd logging changes: sdixit
           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.feed_packages',TRUE);
           END IF;
      RAISE_APPLICATION_ERROR(-20010, 'Error in feed_packages procedure');
 END feed_packages;


 PROCEDURE Delete_Candidates (p_user_id            in number)
 IS
 BEGIN
     -- Delete Candidates --
--ssemwal for Bug 2437020 included where condition
    DELETE FROM igi_stp_candidates
     WHERE user_id = p_user_id ;
 --shsaxena for bug 2713715
    -- and process_flag = 'R';
--shsaxena for bug 2713715
 EXCEPTION
  WHEN OTHERS THEN
     Rollback;
         --bug 3199481 fnd logging changes: sdixit
           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.Delete_Candidates',TRUE);
           END IF;
--	  fnd_message.set_name('SQLGL', 'MRC_SYSTEM_OPTIONS_NOT_FOUND');
--          fnd_message.set_token('MODULE','STEP 2');
--          RAISE_APPLICATION_ERROR(-20010, fnd_message.get);
      RAISE_APPLICATION_ERROR(-20010, 'Error in delete_candidates procedure');
 END Delete_Candidates;


 PROCEDURE Netting (p_batch_id            in number,
                    p_package_id          in number,
                    p_netting_trx_type_id in number)
 IS
 l_ar_netting_amount             number;
 l_ap_netting_amount             number;
 l_get_ar_amount                 number;
 l_get_ap_amount                 number;
 l_liability_ccid                number;
 l_rec_ccid                      number;
 l_flag                          varchar2(1);

 BEGIN



        --------------------------------------
	-- Process AP or AR Balance package --
	--------------------------------------


	   -- Calculate the AP netting amount
           l_message := 'Getting the initial AP netting amount';
	   OPEN get_ap_amount;
	   FETCH get_ap_amount INTO  l_get_ap_amount;
           CLOSE get_ap_amount;

              l_variable := 'l_get_ap_amount';
              l_value := to_char(l_get_ap_amount);
            --bug 3199481 fnd logging changes: sdixit: start block
	      IF l_state_level >= l_debug_level THEN
	         fnd_log.string(l_state_level,'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.Netting',l_message||' : '||l_get_ap_amount);
	      END IF;
            --bug 3199481 fnd logging changes: sdixit: end block

	   -- Calculate  the AR netting amount
           l_message := 'Getting the initial AR netting amount';
	   OPEN get_ar_amount;
	   FETCH get_ar_amount INTO  l_get_ar_amount;
	   CLOSE get_ar_amount;

                  l_variable := 'l_get_ar_amount';
                  l_value := to_char(l_get_ar_amount);
                --bug 3199481 fnd logging changes: sdixit: start block
                  IF (l_state_level >=  l_debug_level ) THEN
                     FND_LOG.STRING  (l_state_level ,
		                     'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.Netting',
                                     l_message||' :'||l_get_ar_amount);
                  END IF;
                --bug 3199481 fnd logging changes: sdixit: end block

	   -- set the netting_amount to the lower of the AP netting amount
	   -- and AR netting amount
       l_message := 'Getting the netting amount';

	   -- Bug 2938450 (Tpradhan), Replaced the from dual select statement with direct assignment
	   l_ar_netting_amount := least(nvl(l_get_ap_amount,0),nvl(l_get_ar_amount,0));
	   l_ap_netting_amount := l_ar_netting_amount;
           --bug 3199481 fnd logging changes: sdixit: start block
             IF (l_state_level >=  l_debug_level ) THEN
                FND_LOG.STRING  (l_state_level ,
	                        'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.Netting',
                                 l_message||' :'||l_ar_netting_amount);
             END IF;
           --bug 3199481 fnd logging changes: sdixit: end block



	   IF (l_ap_netting_amount <> 0)
	   OR (l_ar_netting_amount <> 0)

	   THEN
           l_flag := '1';
	   -- Process the AR elements of the package --
	   --------------------------------------------
	   FOR ar_rec IN get_ar_candidate_details LOOP

   	        -- Get the receivables account --
   	        l_message := 'Getting the receivable account';
   	        IF l_rec_ccid is null
	        THEN
	            SELECT dist.code_combination_id
	            INTO l_rec_ccid
                    FROM ra_customer_trx trx,
                         ra_cust_trx_line_gl_dist dist,
                         igi_stp_candidates candidates
                     WHERE dist.customer_trx_id = trx.customer_trx_id
 		     AND dist.account_class = 'REC'
		     AND trx.trx_number = candidates.trx_number
		     AND candidates.package_id = p_package_id
		     AND candidates.netting_trx_type_id = p_netting_trx_type_id
		     AND candidates.batch_id = p_batch_id
		     AND rownum = 1;
	        END IF;
                     l_variable := 'l_rec_ccid';
                     l_value := to_char(l_rec_ccid);
                   --bug 3199481 fnd logging changes: sdixit: start block
                     IF (l_state_level  >=  l_debug_level ) THEN
                         FND_LOG.STRING  (l_state_level ,
			                 'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.Netting',
                                         l_message||' : '||l_rec_ccid);
		     END IF;
                   --bug 3199481 fnd logging changes: sdixit: end block


         feed_packages (p_batch_id,
                               p_package_id,
                               ar_rec.package_num,
                               p_org_id,
                               ar_rec.stp_id,
                               ar_rec.site_id,
                               (-1)*least(ar_rec.amount,l_ar_netting_amount),
                               ar_rec.trx_number,
                               ar_rec.reference,
                               p_netting_trx_type_id,
                               l_rec_ccid,
-- Bug: 1079477 changed AP to AR
                               'AR',
                               'CM',
                               ar_rec.currency_code,
                               ar_rec.exchange_rate,
                               ar_rec.exchange_rate_type,
                               ar_rec.exchange_date);

    		 --bug 3199481 fnd logging changes: sdixit: start block
      		 IF (l_state_level  >=  l_debug_level ) THEN
         		 FND_LOG.STRING  (l_state_level , 'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.Netting',
               		  'Creating a payables document');
  		 END IF;
     		--bug 3199481 fnd logging changes: sdixit: end block
	        l_ar_netting_amount := l_ar_netting_amount - ar_rec.amount;
                l_message := 'AR Netting amount diminish';

                     l_variable := 'l_ar_netting_amount';
                     l_value := to_char(l_ar_netting_amount);
                  --bug 3199481 fnd logging changes: sdixit: start block
                    IF (l_state_level  >=  l_debug_level ) THEN
                       FND_LOG.STRING  (l_state_level , 'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.Netting',
                    l_message||' : '||l_ar_netting_amount);
		    END IF;
                  --bug 3199481 fnd logging changes: sdixit: end block

            IF l_ar_netting_amount <= 0
     	    THEN  exit;
	        END IF;

	  END LOOP;



	  -- Process the AP elements of the package -
	  ------------------------------------------

          l_flag := '2';
	  FOR ap_rec IN get_ap_candidate_details LOOP

	     -- Get the liability account
	     l_message := 'Getting the liability account';
             IF l_liability_ccid is null THEN
	        SELECT api.accts_pay_code_combination_id
	        INTO l_liability_ccid
                FROM ap_invoices api,
                     igi_stp_candidates candidates
                WHERE api.invoice_id = candidates.trx_id
		AND candidates.package_id = p_package_id
		AND candidates.netting_trx_type_id = p_netting_trx_type_id
		AND candidates.batch_id = p_batch_id
		AND rownum = 1;
	     END IF;

             l_variable := 'l_liability_ccid';
             l_value := to_char(l_liability_ccid);
             --bug 3199481 fnd logging changes: sdixit: start block
             IF (l_state_level  >=  l_debug_level ) THEN
                 FND_LOG.STRING  (l_state_level , 'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.Netting',
                 l_message||' : '||l_liability_ccid);
             END IF;
             --bug 3199481 fnd logging changes: sdixit: end block

	     feed_packages (p_batch_id,
                            p_package_id,
                            ap_rec.package_num,
                            p_org_id,
                            ap_rec.stp_id,
                            ap_rec.site_id,
                            (-1)*least(ap_rec.amount,l_ap_netting_amount),
                            ap_rec.trx_number,
                            ap_rec.reference,
                            p_netting_trx_type_id,
                            l_liability_ccid,
-- Bug: 1079477 changed AR to AP
                            'AP',
                            'CM',
                            ap_rec.currency_code,
                            ap_rec.exchange_rate,
                            ap_rec.exchange_rate_type,
                            ap_rec.exchange_date);

             l_message := 'Creating a receivable document';
             --bug 3199481 fnd logging changes: sdixit: start block
             IF (l_state_level  >=  l_debug_level ) THEN
                  FND_LOG.STRING  (l_state_level , 'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.Netting',l_message);
             END IF;

	    l_ap_netting_amount := l_ap_netting_amount - ap_rec.amount;
            l_message := 'AP Netting amount diminish';
            l_variable := 'l_ap_netting_amount';
            l_value    := to_char(l_ap_netting_amount);
            --bug 3199481 fnd logging changes: sdixit: start block
            IF (l_state_level  >=  l_debug_level ) THEN
                FND_LOG.STRING  (l_state_level , 'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.Netting',
                l_message||' : '||l_ap_netting_amount);
            END IF;

	    IF l_ap_netting_amount <= 0 THEN
                 exit;
	    END IF;
            END LOOP;
    END IF;
 EXCEPTION
      WHEN OTHERS THEN
--	  fnd_message.set_name('SQLGL', 'MRC_SYSTEM_OPTIONS_NOT_FOUND');
--         fnd_message.set_token('MODULE','STEP 3');
--          RAISE_APPLICATION_ERROR(-20010, fnd_message.get);
      if l_flag = '1' then

         --bug 3199481 fnd logging changes: sdixit
           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.Netting.msg1',TRUE);
           END IF;

         RAISE_APPLICATION_ERROR(-20010, 'Error in netting procedure Receivable AC  ');
       elsif l_flag = '2' then
         --bug 3199481 fnd logging changes: sdixit
           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.Netting.msg2',TRUE);
           END IF;
         RAISE_APPLICATION_ERROR(-20010, 'Error in netting procedure Liability AC');
      else
         --bug 3199481 fnd logging changes: sdixit
           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.Netting.msg3',TRUE);
           END IF;
         RAISE_APPLICATION_ERROR(-20010, 'Error in netting procedure');
      end if;

 END Netting;

procedure trx_sites
is
begin
   null;
end trx_sites;

--p_org_id is new input parameter added as part of MOAC uptake

 PROCEDURE AP_only_Netting (p_batch_id            in number,
                            p_package_id          in number,
                            p_netting_trx_type_id in number,
                            p_contra_party_id     in number,
                            p_contra_amount       in number,
                            p_org_id              in number)
 IS
   l_ap_only_netting_amount        number;
   l_liability_ccid                number;
   l_contra_party_site_id          number;
   l_contra_trx_type_id            varchar2(30);
   l_flag                          varchar2(1);
 BEGIN

      -- Initialise ap_amount to the sum for all transaction types--
      l_message := 'Getting the initial AP netting amount for objections to payment and assignments';
      l_ap_only_netting_amount  :=  nvl(p_contra_amount,0);
                  l_variable := 'l_ap_only_netting_amount';
                  l_value    := to_char(l_ap_only_netting_amount);
                --bug 3199481 fnd logging changes: sdixit: start block
               --   fnd_file.put_line(fnd_file.log ,l_message||' : '||l_ap_only_netting_amount);
                 IF (l_state_level  >=  l_debug_level ) THEN
                    FND_LOG.STRING  (l_state_level , 'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.Ap_only_Netting',
                      l_message||' : '||l_ap_only_netting_amount);
                 END IF;
               --bug 3199481 fnd logging changes: sdixit: end block

      -- Get the contra_party_site_id
      l_message := 'Get the contra_party_site_id';
      l_flag := '1';
      --po_vendor_sites replaced with ap_supplier_sites_all and org_id added
      SELECT vendor_site_id
      INTO   l_contra_party_site_id
      FROM   ap_supplier_sites_all
      WHERE  vendor_id = p_contra_party_id
      AND org_id = p_org_id
      AND    rownum = 1;
                 l_variable := 'l_contra_party_site_id';
                 l_value    := to_char(l_contra_party_site_id);
               --bug 3199481 fnd logging changes: sdixit: start block
                 --fnd_file.put_line(fnd_file.log ,l_message||' : '||l_contra_party_site_id);
                 IF (l_state_level  >=  l_debug_level ) THEN
                     FND_LOG.STRING  (l_state_level , 'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.Ap_only_Netting',
                       l_message||' : '||l_contra_party_site_id);
                 END IF;
              --bug 3199481 fnd logging changes: sdixit: end block

      l_flag := '2';
      FOR ap_rec IN get_ap_only_candidate_details  LOOP


	     -- Get the liability account
	     l_message := 'Getting the liability account';
            IF l_liability_ccid is null
	    THEN
	        SELECT api.accts_pay_code_combination_id
	        INTO l_liability_ccid
                FROM ap_invoices_all api,
                     igi_stp_candidates_all candidates
                WHERE api.invoice_id = candidates.trx_id
		    AND candidates.package_id = p_package_id
		    AND candidates.netting_trx_type_id = p_netting_trx_type_id
		    AND candidates.batch_id = p_batch_id
		    and candidates.org_id = p_org_id
		    and api.org_id = candidates.org_id
		    AND rownum = 1;
	    END IF;

                l_variable := 'l_liability_ccid';
                l_value := to_char(l_liability_ccid);
                --bug 3199481 fnd logging changes: sdixit: start block
	        --  fnd_file.put_line(fnd_file.log ,l_message||' : '||l_liability_ccid);
                IF (l_state_level  >=  l_debug_level ) THEN
                   FND_LOG.STRING  (l_state_level , 'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.ap_only_Netting',
                         l_message||' : '||l_liability_ccid);
                END IF;
                --bug 3199481 fnd logging changes: sdixit: end block


	    IF p_netting_trx_type_id = 3

        THEN
--           IF (nvl(l_ap_only_netting_amount,0) <> 0)

--           THEN
              -- Insert the AP document for the stp
               feed_packages (p_batch_id,
                              p_package_id,
                              ap_rec.package_num,
                              P_ORG_ID,
                              p_contra_party_id,
                              l_contra_party_site_id,
                              least(round(ap_rec.amount,2),l_ap_only_netting_amount),
                              ap_rec.trx_number,
                              ap_rec.reference,
                              p_netting_trx_type_id,
                              l_liability_ccid,
                              'AP',
                              'INV',
                              ap_rec.currency_code,
                              ap_rec.exchange_rate,
                              ap_rec.exchange_rate_type,
                              ap_rec.exchange_date);
                         l_message := 'Create AP objection to payment document for the third party';
                         --bug 3199481 fnd logging changes: sdixit: start block
	                 --d_file.put_line(fnd_file.log ,l_message);
                         IF (l_state_level  >=  l_debug_level ) THEN
                            FND_LOG.STRING  (l_state_level , 'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.Ap_only_Netting',l_message);
                         END IF;
                         --bug 3199481 fnd logging changes: sdixit: end block

         -- Insert the AP document for the Contra party id
              feed_packages (p_batch_id,
                            p_package_id,
                            ap_rec.package_num,
                            P_ORG_ID,
                            ap_rec.stp_id,
                            ap_rec.site_id,
                            round((-1)*least(ap_rec.amount,l_ap_only_netting_amount),2),
                            ap_rec.trx_number,
                            ap_rec.reference,
                            p_netting_trx_type_id,
                            l_liability_ccid,
                            'AP',
                            'CM',
                            ap_rec.currency_code,
                            ap_rec.exchange_rate,
                            ap_rec.exchange_rate_type,
                            ap_rec.exchange_date);
                         l_message := 'Create AP objection to payment document for the Contra party';
                       --bug 3199481 fnd logging changes: sdixit: start block
		         IF (l_state_level  >=  l_debug_level ) THEN
		             FND_LOG.STRING  (l_state_level , 'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.Ap_only_Netting',l_message);
		         END IF;
                       --bug 3199481 fnd logging changes: sdixit: end block

          ELSIF  p_netting_trx_type_id = 5 THEN
            -- Netting Trx Type = 5 therefore process Assignments
            -- Insert the AP document for the stp

               feed_packages (p_batch_id,
                            p_package_id,
                            ap_rec.package_num,
                            P_ORG_ID,
                            p_contra_party_id,
                            l_contra_party_site_id,
                            least(round(ap_rec.amount,2),l_ap_only_netting_amount),
--                            round(ap_rec.amount,2),
                            ap_rec.trx_number,
                            ap_rec.reference,
                            p_netting_trx_type_id,
                            l_liability_ccid,
                            'AP',
                            'INV',
                            ap_rec.currency_code,
                            ap_rec.exchange_rate,
                            ap_rec.exchange_rate_type,
                            ap_rec.exchange_date);

                        l_message := 'Create AP assignment document for the STP';
                      --bug 3199481 fnd logging changes: sdixit: start block
                        IF (l_state_level  >=  l_debug_level ) THEN
		          FND_LOG.STRING  (l_state_level , 'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.Ap_only_Netting',l_message);
		        END IF;
                      --bug 3199481 fnd logging changes: sdixit: end block

             -- Insert the AP document for the Contra party id
             feed_packages (p_batch_id,
                            p_package_id,
                            ap_rec.package_num,
                            P_ORG_ID,
                            ap_rec.stp_id,
                            ap_rec.site_id,
                            round((-1)*least(ap_rec.amount,l_ap_only_netting_amount),2),
--                            round(-1*ap_rec.amount,2),
                            ap_rec.trx_number,
                            ap_rec.reference,
                            p_netting_trx_type_id,
                            l_liability_ccid,
                            'AP',
                            'CM',
                            ap_rec.currency_code,
                            ap_rec.exchange_rate,
                            ap_rec.exchange_rate_type,
                            ap_rec.exchange_date);
                       l_message := 'Create AP assignment doc. for the Contra party';
                      --bug 3199481 fnd logging changes: sdixit: start block
                        IF (l_state_level  >=  l_debug_level ) THEN
		          FND_LOG.STRING  (l_state_level , 'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.Ap_only_Netting',l_message);
		        END IF;
                      --bug 3199481 fnd logging changes: sdixit: end block

        END IF;

	    l_ap_only_netting_amount := l_ap_only_netting_amount - ap_rec.amount;
            l_message := 'AP Netting amount diminish';
                     l_variable := 'l_ap_only_netting_amount';
                     l_value    := to_char(l_ap_only_netting_amount);
                      --bug 3199481 fnd logging changes: sdixit: start block
                        IF (l_state_level  >=  l_debug_level ) THEN
		          FND_LOG.STRING  (l_state_level , 'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.Ap_only_Netting',l_message);
		        END IF;
                      --bug 3199481 fnd logging changes: sdixit: end block

	    IF l_ap_only_netting_amount <= 0
	    THEN  exit;
	    END IF;
	  END LOOP;

 EXCEPTION
    WHEN OTHERS THEN
--     fnd_message.set_name('SQLGL', 'MRC_SYSTEM_OPTIONS_NOT_FOUND');
--     fnd_message.set_token('MODULE',l_message);
--     RAISE_APPLICATION_ERROR(-20010, fnd_message.get);
       if l_flag = '1' then
         --bug 3199481 fnd logging changes: sdixit
           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.AP_Only_Netting.msg1',TRUE);
           END IF;
          RAISE_APPLICATION_ERROR(-20010, 'Error in ap_only_netting procedure vendor site id');
       elsif l_flag = '2' then
         --bug 3199481 fnd logging changes: sdixit
           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.AP_Only_Netting.msg2',TRUE);
           END IF;
          RAISE_APPLICATION_ERROR(-20010, 'Error in ap_only_netting procedure liability account');
       else
         --bug 3199481 fnd logging changes: sdixit
           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.AP_Only_Netting.msg3',TRUE);
           END IF;
          RAISE_APPLICATION_ERROR(-20010, 'Error in ap_only_netting procedure' );
       end if;
 END AP_only_Netting;

 --l_org_id is new input parameter added as part of MOAC uptake
 PROCEDURE Submit_Netting (l_batch_id              in number
                          ,l_contra_party_id       in number
                          ,l_contra_amount         in number
                          ,l_org_id                in number)
 IS
 l_user_id        number;

 BEGIN



   p_batch_id := l_batch_id;
       l_variable := 'l_batch_id';
       l_value    := to_char(l_batch_id);
   p_contra_party_id := l_contra_party_id;
       l_variable := 'l_contra_party_id';
       l_value    := to_char(l_contra_party_id);
   p_contra_amount := l_contra_amount;
       l_variable := 'l_contra_amount';
       l_value    := to_char(l_contra_amount);
   p_org_id := l_org_id;





   FOR candidate_rec IN get_candidate_packages LOOP

    p_package_id := candidate_rec.package_id;
    p_netting_trx_type_id := candidate_rec.netting_trx_type_id;


       l_variable := 'p_package_id';
       l_value    := to_char(p_package_id);
       l_message := 'package_id : '||to_char(p_package_id);
       --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_state_level  >=  l_debug_level ) THEN
	FND_LOG.STRING  (l_state_level , 'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.Submit_Netting',l_message);
	END IF;
       --bug 3199481 fnd logging changes: sdixit: end block

       l_variable := 'p_netting_trx_type_id';
       l_value    := to_char(p_netting_trx_type_id);
       l_message := 'netting_trx_type_id : '||to_char(p_netting_trx_type_id);
       --bug 3199481 fnd logging changes: sdixit: start block
        IF (l_state_level  >=  l_debug_level ) THEN
	     FND_LOG.STRING  (l_state_level , 'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.Submit_Netting',l_message);
	END IF;
       --bug 3199481 fnd logging changes: sdixit: end block

       --Transaction types 1 and 2 are commented because this partcular feature is not part of R12
       --p_org_id is new input parameter passed to AP_only_Netting,pay_excess_netting and sup_reimb_netting procedures

	/* IF candidate_rec.netting_trx_type_id = 1  THEN
	   l_message := 'Process AP Balance';
	   Netting(p_batch_id,p_package_id,1);
	ELSIF candidate_rec.netting_trx_type_id = 2  THEN
	   l_message := 'Process AP Balance';
	   Netting(p_batch_id,p_package_id,2);*/
	IF candidate_rec.netting_trx_type_id = 3  THEN
  	   l_message := 'Process Objections to Payment';
  	   AP_only_Netting(p_batch_id,p_package_id,3, p_contra_party_id, p_contra_amount,p_org_id);
	ELSIF candidate_rec.netting_trx_type_id = 4  THEN
	   l_message := 'Process Payment excesses';
           pay_excess_netting(p_batch_id,p_package_id,4,p_org_id);
	ELSIF candidate_rec.netting_trx_type_id = 5  THEN

	   l_message := 'Process Assignments';
	   AP_only_Netting(p_batch_id,p_package_id,5, p_contra_party_id, p_contra_amount,p_org_id);
	ELSIF candidate_rec.netting_trx_type_id = 6  THEN
	   l_message := 'Process Supplier Reimbursements';
           sup_reimb_netting(p_batch_id,p_package_id,6,p_org_id);
	END IF;
    END LOOP;

    l_user_id := fnd_profile.value('USER_ID');
    l_variable := 'l_user_id';
    l_value    := to_char(l_user_id);
    l_message := 'Deleting candidates';
    Delete_Candidates (l_user_id);


 END Submit_Netting;

PROCEDURE pay_excess_netting (p_batch_id             in number,
                              package_id             in number,
                              p_netting_trx_type_id  in number,
                              p_ORG_ID                 IN NUMBER) IS
   l_ar_netting_amount         number;
   l_get_ar_amount             number;
   l_liability_ccid            number;
   l_rec_ccid                  number;
   l_flag                      varchar2(1);
   l_vendor_id                 number;
   l_vendor_site_id            number;
BEGIN
        --------------------------------------
	-- Process AP or AR Balance package --
	--------------------------------------
   -- Calculate  the AR netting amount
   l_message := 'Getting the initial AR netting amount';
   OPEN get_ar_amount;
   FETCH get_ar_amount INTO  l_get_ar_amount;
   CLOSE get_ar_amount;

      l_variable := 'l_get_ar_amount';
      l_value := to_char(l_get_ar_amount);
      --bug 3199481 fnd logging changes: sdixit: start block
        IF (l_state_level  >=  l_debug_level ) THEN
		FND_LOG.STRING  (l_state_level , 'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.Pay_excess_Netting',l_message);
	END IF;
      --bug 3199481 fnd logging changes: sdixit: end block

   -- set the netting_amount to the lower of the AP netting amount
   -- and AR netting amount
   l_message := 'Getting the netting amount';

   -- Bug 2938450 (Tpradhan), Replaced the from dual select statement with direct assignment
   l_ar_netting_amount := nvl(l_get_ar_amount,0);
      l_variable := 'l_ar_netting_amount';
      l_value := to_char(l_ar_netting_amount);
      --bug 3199481 fnd logging changes: sdixit: start block
        IF (l_state_level  >=  l_debug_level ) THEN
		FND_LOG.STRING  (l_state_level , 'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.pay_excess_Netting',l_message);
	END IF;
      --bug 3199481 fnd logging changes: sdixit: end block
   IF (l_ar_netting_amount <> 0) THEN
      l_flag := '1';
      -- Process the AR elements of the package --
      --------------------------------------------
      FOR ar_rec IN get_ar_candidate_details LOOP
      -- Get the receivables account --
         l_message := 'Getting the receivable account';
         IF l_rec_ccid is null THEN
	    SELECT dist.code_combination_id
            INTO l_rec_ccid
            FROM ra_customer_trx trx,
                 ra_cust_trx_line_gl_dist dist,
                 igi_stp_candidates candidates
            WHERE dist.customer_trx_id = trx.customer_trx_id
            AND dist.account_class = 'REC'
            AND trx.trx_number = candidates.trx_number
            AND candidates.package_id = p_package_id
	    AND candidates.netting_trx_type_id = p_netting_trx_type_id
	    AND candidates.batch_id = p_batch_id
	    AND rownum = 1;
         END IF;
            l_variable := 'l_rec_ccid';
            l_value := to_char(l_rec_ccid);
                      --bug 3199481 fnd logging changes: sdixit: start block
                        IF (l_state_level  >=  l_debug_level ) THEN
		          FND_LOG.STRING  (l_state_level , 'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.pay_excess_Netting',l_message);
		        END IF;
                      --bug 3199481 fnd logging changes: sdixit: end block
            l_message := 'Creating a Receivable DM';
         feed_packages (p_batch_id,
                        p_package_id,
                        ar_rec.package_num,
                        P_ORG_ID,
                        ar_rec.stp_id,
                        ar_rec.site_id,
                        (-1)*least(ar_rec.amount,l_ar_netting_amount),
                        ar_rec.trx_number,
                        ar_rec.reference,
                        p_netting_trx_type_id,
                        l_rec_ccid,
                        'AR',
                        'DM',
                        ar_rec.currency_code,
                        ar_rec.exchange_rate,
                        ar_rec.exchange_rate_type,
                        ar_rec.exchange_date);
            l_message := 'Creating a payable invoice';
                      --bug 3199481 fnd logging changes: sdixit: start block
                        IF (l_state_level  >=  l_debug_level ) THEN
		          FND_LOG.STRING  (l_state_level , 'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.pay_excess_Netting',l_message);
		        END IF;
                      --bug 3199481 fnd logging changes: sdixit: end block

         open get_vendor(ar_rec.stp_id);
         fetch get_vendor into l_vendor_id;
         close get_vendor;
         open get_vendor_sites(l_vendor_id);
         fetch get_vendor_sites into l_vendor_site_id, l_liability_ccid;
         close get_vendor_sites;

         feed_packages (p_batch_id,
                        p_package_id,
                        ar_rec.package_num,
                        p_org_id,
                        l_vendor_id,
                        l_vendor_site_id,
                        (-1)*least(ar_rec.amount,l_ar_netting_amount),
                        ar_rec.trx_number,
                        ar_rec.reference,
                        p_netting_trx_type_id,
                        l_liability_ccid,
                        'AP',
                        'INV',
                        ar_rec.currency_code,
                        ar_rec.exchange_rate,
                        ar_rec.exchange_rate_type,
                        ar_rec.exchange_date);
         l_ar_netting_amount := l_ar_netting_amount - ar_rec.amount;

         l_message := 'Payment Excess Netting amount diminish';
            l_variable := 'l_ar_netting_amount';
            l_value := to_char(l_ar_netting_amount);
            --bug 3199481 fnd logging changes: sdixit: start block
            IF (l_state_level  >=  l_debug_level ) THEN
	         FND_LOG.STRING  (l_state_level , 'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.pay_excess_Netting',l_message);
	    END IF;
            --bug 3199481 fnd logging changes: sdixit: end block

         IF l_ar_netting_amount <= 0 THEN
            exit;
         END IF;

      END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
         --bug 3199481 fnd logging changes: sdixit
           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.pay_excess_netting',TRUE);
           END IF;

      if l_flag = '1' then
         RAISE_APPLICATION_ERROR(-20010, 'Error in pay excess netting procedure Receivable AC  ');
      else
         RAISE_APPLICATION_ERROR(-20010, 'Error in pay excess netting procedure');
      end if;
END pay_excess_netting;


 PROCEDURE sup_reimb_netting (p_batch_id             in number,
                              package_id            in number,
                              p_netting_trx_type_id   in number,
                              p_org_id                in number) IS
   l_ap_netting_amount             number;
   l_get_ap_amount                 number;
   l_liability_ccid                number;
   l_rec_ccid                      number;
   l_customer_id                   number;
   l_customer_site_id              number;
   l_flag                          varchar2(1);

BEGIN
        --------------------------------------
	-- Process AP or AR Balance package --
	--------------------------------------


   -- Calculate the AP netting amount
   l_message := 'Getting the initial AP netting amount';
   OPEN get_ap_amount;
   FETCH get_ap_amount INTO  l_get_ap_amount;
   CLOSE get_ap_amount;

      l_variable := 'l_get_ap_amount';
      l_value := to_char(l_get_ap_amount);
      --bug 3199481 fnd logging changes: sdixit: start block
        IF (l_state_level  >=  l_debug_level ) THEN
		FND_LOG.STRING  (l_state_level , 'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.sup_reimb_Netting',l_message);
	END IF;
      --bug 3199481 fnd logging changes: sdixit: end block

   l_message := 'Getting the netting amount';

   -- Bug 2938450 (Tpradhan), Replaced the from dual select statement with direct assignment
   l_ap_netting_amount := nvl(l_get_ap_amount,0);
   IF (l_ap_netting_amount <> 0) THEN
      l_flag := '1';
      FOR ap_rec IN get_ap_candidate_details LOOP
         -- Get the liability account
         l_message := 'Getting the liability account';
         IF l_liability_ccid is null THEN
	    SELECT api.accts_pay_code_combination_id
	    INTO l_liability_ccid
            FROM ap_invoices api,
                 igi_stp_candidates candidates
            WHERE api.invoice_id = candidates.trx_id
	    AND candidates.package_id = p_package_id
	    AND candidates.netting_trx_type_id = p_netting_trx_type_id
	    AND candidates.batch_id = p_batch_id
	    AND rownum = 1;
         END IF;
            l_variable := 'l_liability_ccid';
            l_value := to_char(l_liability_ccid);
                      --bug 3199481 fnd logging changes: sdixit: start block
	                --fnd_file.put_line(fnd_file.log ,l_message);
                        IF (l_state_level  >=  l_debug_level ) THEN
		          FND_LOG.STRING  (l_state_level , 'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.sup_reimb_Netting',l_message);
		        END IF;
                      --bug 3199481 fnd logging changes: sdixit: end block

	 feed_packages (p_batch_id,
                        p_package_id,
                        ap_rec.package_num,
                        p_org_id,
                        ap_rec.stp_id,
                        ap_rec.site_id,
                        (-1)*least(ap_rec.amount,l_ap_netting_amount),
                        ap_rec.trx_number,
                        ap_rec.reference,
                        p_netting_trx_type_id,
                        l_liability_ccid,
                        'AP',
                        'INV',
                        ap_rec.currency_code,
                        ap_rec.exchange_rate,
                        ap_rec.exchange_rate_type,
                        ap_rec.exchange_date);
            l_message := 'Creating a receivable document';
                      --bug 3199481 fnd logging changes: sdixit: start block
                        IF (l_state_level  >=  l_debug_level ) THEN
		          FND_LOG.STRING  (l_state_level , 'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.sup_reimb_Netting',l_message);
		        END IF;
                      --bug 3199481 fnd logging changes: sdixit: end block

         open get_customer(ap_rec.stp_id);
         fetch get_customer into l_customer_id;
         close get_customer;
         open get_customer_sites(l_customer_id);
         fetch get_customer_sites into l_customer_site_id,l_rec_ccid;
         close get_customer_sites;

	 feed_packages (p_batch_id,
                        p_package_id,
                        ap_rec.package_num,
                        p_org_id,
                        l_customer_id,
                        l_customer_site_id,
                        (-1)*least(ap_rec.amount,l_ap_netting_amount),
                        ap_rec.trx_number,
                        ap_rec.reference,
                        p_netting_trx_type_id,
                        l_rec_ccid,
                        'AR',
                        'DM',
                        ap_rec.currency_code,
                        ap_rec.exchange_rate,
                        ap_rec.exchange_rate_type,
                        ap_rec.exchange_date);
	 l_ap_netting_amount := l_ap_netting_amount - ap_rec.amount;
         l_message := 'AP Netting amount diminish';
            l_variable := 'l_ap_netting_amount';
            l_value    := to_char(l_ap_netting_amount);
                      --bug 3199481 fnd logging changes: sdixit: start block
                        IF (l_state_level  >=  l_debug_level ) THEN
		          FND_LOG.STRING  (l_state_level , 'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.sup_reimb_Netting',l_message);
		        END IF;
                      --bug 3199481 fnd logging changes: sdixit: end block

	 IF l_ap_netting_amount <= 0 THEN
            exit;
	 END IF;
      END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
         --bug 3199481 fnd logging changes: sdixit
           IF ( l_unexp_level >= l_debug_level ) THEN

               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,'igi.plsql.igistpcb.IGI_STP_CREATE_PCK_PKG.sup_reimb_netting',TRUE);
           END IF;
      if l_flag = '1' then
         RAISE_APPLICATION_ERROR(-20010, 'Error in supplier reimb netting procedure Liability AC');
      else
         RAISE_APPLICATION_ERROR(-20010, 'Error in supplier reimb netting procedure');
      end if;

END sup_reimb_netting;


END IGI_STP_CREATE_PCK_PKG;

/
