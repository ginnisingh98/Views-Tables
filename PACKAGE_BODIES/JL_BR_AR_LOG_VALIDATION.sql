--------------------------------------------------------
--  DDL for Package Body JL_BR_AR_LOG_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_AR_LOG_VALIDATION" as
/* $Header: jlbrrvlb.pls 120.11.12010000.6 2009/12/28 23:12:30 spasupun ship $ */

PROCEDURE logical_validation(
  p_file_control             IN jl_br_ar_ret_interface_all.file_control%TYPE,
  p_ent_seq_num              IN jl_br_ar_ret_interface_all.ENTRY_SEQUENTIAL_NUMBER%TYPE, -- Bug#8331293
  p_called_from               IN     VARCHAR2, -- Bug#8331293
  p_bank_number              IN jl_br_ar_ret_interface_all.bank_number%TYPE,
  p_company_code             IN jl_br_ar_ret_interface_all.company_code%TYPE,
  p_inscription_number       IN jl_br_ar_ret_interface_all.inscription_number%TYPE,
  p_bank_occurrence_code     IN jl_br_ar_ret_interface_all.bank_occurrence_code%TYPE,
  p_occurrence_date          IN jl_br_ar_ret_interface_all.occurrence_date%TYPE,
  p_company_use              IN jl_br_ar_ret_interface_all.company_use%TYPE,
  p_your_number              IN jl_br_ar_ret_interface_all.your_number%TYPE,
  p_customer_name            IN jl_br_ar_ret_interface_all.customer_name%TYPE,
  p_trade_note_amount        IN jl_br_ar_ret_interface_all.trade_note_amount%TYPE,
  p_credit_amount            IN jl_br_ar_ret_interface_all.credit_amount%TYPE,
  p_interest_amount_received IN jl_br_ar_ret_interface_all.interest_amount_received%TYPE,
  p_discount_amount          IN jl_br_ar_ret_interface_all.discount_amount%TYPE,
  p_abatement_amount         IN jl_br_ar_ret_interface_all.abatement_amount%TYPE,
  p_bank_party_id               OUT NOCOPY NUMBER,
  p_error_code               IN OUT NOCOPY varchar2)
IS
  X_bank_number              jl_br_ar_ret_interface_all.bank_number%TYPE;
  X_jlbr_bank_number         jl_br_ar_ret_interface_all.bank_number%TYPE;
  X_remittance_bank          jl_br_ar_ret_interface_all.bank_number%TYPE;
  X_company_code             jl_br_ar_ret_interface_all.company_code%TYPE;
  X_inscription_number       jl_br_ar_ret_interface_all.inscription_number%TYPE;
  X_cgc                      jl_br_ar_ret_interface_all.inscription_number%TYPE;
  X_bank_occurrence_code     jl_br_ar_ret_interface_all.bank_occurrence_code%TYPE;
  X_company_use              jl_br_ar_ret_interface_all.company_use%TYPE;
  X_your_number              jl_br_ar_ret_interface_all.your_number%TYPE;
  X_bank_occurrence_code_std jl_br_ar_bank_occurrences.std_occurrence_code%TYPE;
  X_document_status          jl_br_ar_collection_docs_all.document_status%TYPE;
  X_customer_name            jl_br_ar_ret_interface_all.customer_name%TYPE;
  X_payment_schedule_id      jl_br_ar_collection_docs_all.payment_schedule_id%TYPE;
  X_trade_note_amount        jl_br_ar_ret_interface_all.trade_note_amount%TYPE;
  X_document_amount          jl_br_ar_ret_interface_all.trade_note_amount%TYPE;
  X_credit_amount            jl_br_ar_ret_interface_all.credit_amount%TYPE;
  X_interest_amount_received jl_br_ar_ret_interface_all.interest_amount_received%TYPE;
  X_discount_amount          jl_br_ar_ret_interface_all.discount_amount%TYPE;
  X_abatement_amount         jl_br_ar_ret_interface_all.abatement_amount%TYPE;
  X_customer_name1           jl_br_ar_ret_interface_all.customer_name%TYPE;
  X_dual_num                 number;
  X_remittance_bank_id       NUMBER;
  error_validation           EXCEPTION;
  valid_date                 BOOLEAN;
  ------------------------------------------------------------------------
  --Bug 4192066: Added required variables for parameters required to call
  --            XLE API to get the tax registration number
  ------------------------------------------------------------------------

  l_init_msg_list            VARCHAR2(2000);
  l_commit                   VARCHAR2(2000);
  l_validation_level         NUMBER;
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(2000);
  l_return_status            VARCHAR2(2000);
  l_ledger_id                ar_system_parameters.set_of_books_id%TYPE;
  l_acct_balancing_segment   ar_system_parameters.global_attribute1%TYPE;
  l_ledger_info              xle_businessinfo_grp.le_ledger_rec_type;
  l_legal_entity_id          xle_entity_profiles.legal_entity_id%TYPE;
  l_legal_entity_name        xle_entity_profiles.name%TYPE;
  l_party_id                 hz_parties.party_id%TYPE;
  l_party_type               hz_parties.party_type%TYPE;


  -- Bug#8331293 Replaced SQL query with cursor
  Cursor Comp_JLBRRVFD (  cp_ledger_id ar_system_parameters.set_of_books_id%TYPE
                ,cp_lacct_balancing_segment ar_system_parameters.global_attribute1%TYPE
                ,cp_file_control jl_br_ar_ret_interface_all.file_control%TYPE
				,cp_ent_seq_num jl_br_ar_ret_interface_all.ENTRY_SEQUENTIAL_NUMBER%TYPE)
 IS
   Select etb.registration_number
     From
           xle_establishment_v etb
          ,xle_bsv_associations bsv
          ,gl_ledger_le_v gl
          ,jl_br_ar_ret_interface jlint
      Where
           etb.legal_entity_id     = gl.legal_entity_id
      And   bsv.legal_parent_id   = etb.legal_entity_id
      And   etb.establishment_id  = bsv.legal_construct_id
      And   bsv.entity_name        = cp_lacct_balancing_segment
      And   gl.ledger_id              = cp_ledger_id
      And   rtrim(upper(substr(translate(etb.establishment_name,
'????cCuUaAeEoOaAaAeEiIoOuU!@#$%&*()_+=[]{}/\?:<>|',
'aAoOcCuUaAeEoOaAaAeEiIoOuU                       '),1,30))) = rtrim(upper(jlint.company_name))  --bug 8412707 + bug8527766
	  And   file_control =  cp_file_control
	  And   ENTRY_SEQUENTIAL_NUMBER =  cp_ent_seq_num
          AND trunc(SYSDATE) between trunc(nvl(bsv.effective_from, SYSDATE))
	                     and trunc(nvl(bsv.effective_to,SYSDATE)); --bug 9239401

	Cursor Comp_JLBRRCDB (  cp_ledger_id ar_system_parameters.set_of_books_id%TYPE
                ,cp_lacct_balancing_segment ar_system_parameters.global_attribute1%TYPE
                ,cp_file_control jl_br_ar_ret_interface_all.file_control%TYPE
				,cp_ent_seq_num jl_br_ar_ret_interface_all.ENTRY_SEQUENTIAL_NUMBER%TYPE)
 IS
   Select etb.registration_number
     From
           xle_establishment_v etb
          ,xle_bsv_associations bsv
          ,gl_ledger_le_v gl
          ,JL_BR_AR_RET_INTERFACE_EXT jlint
      Where
           etb.legal_entity_id     = gl.legal_entity_id
      And   bsv.legal_parent_id   = etb.legal_entity_id
      And   etb.establishment_id  = bsv.legal_construct_id
      And   bsv.entity_name        = cp_lacct_balancing_segment
      And   gl.ledger_id              = cp_ledger_id
      And   rtrim(upper(substr(translate(etb.establishment_name,
'????cCuUaAeEoOaAaAeEiIoOuU!@#$%&*()_+=[]{}/\?:<>|',
'aAoOcCuUaAeEoOaAaAeEiIoOuU                       '),1,30))) = rtrim(upper(jlint.company_name))  --bug 8412707 + bug8527766
	  And   file_control =  cp_file_control
	  And   ENTRY_SEQUENTIAL_NUMBER =  cp_ent_seq_num
          AND trunc(SYSDATE) between trunc(nvl(bsv.effective_from, SYSDATE))
	                     and     trunc(nvl(bsv.effective_to,SYSDATE));  --bug 9239401

BEGIN
  fnd_file.put_line(FND_FILE.LOG,'Parameters passed to JL_BR_AR_LOG_VALIDATION.logical_validation');
  fnd_file.put_line(FND_FILE.LOG,'File Control : ' ||  p_file_control );
  fnd_file.put_line(FND_FILE.LOG,'Sequence Number : ' || p_ent_seq_num );
  fnd_file.put_line(FND_FILE.LOG,'Called From : ' || p_called_from);



  X_bank_number              := p_bank_number;
  X_company_code             := p_company_code;
  X_inscription_number       := nvl(p_inscription_number,0);
  X_bank_occurrence_code     := p_bank_occurrence_code;
  X_company_use              := p_company_use;
  X_your_number              := p_your_number;
  X_customer_name            := p_customer_name;
  X_trade_note_amount        := p_trade_note_amount;
  X_credit_amount            := p_credit_amount;
  X_interest_amount_received := p_interest_amount_received;
  X_discount_amount          := p_discount_amount;
  X_abatement_amount         := p_abatement_amount;

  fnd_file.put_line(FND_FILE.LOG,'Bank Number : ' || X_bank_number);
  fnd_file.put_line(FND_FILE.LOG,'Company Code : ' || X_company_code);
  fnd_file.put_line(FND_FILE.LOG,'Inscription Number :' || X_inscription_number );

/* Bug 8527766 */
/* Becoming 1st validation as BANK_PARTY_ID is NOT NULL in INTERFACE_EXT table */

  /****************************/
  /* Validate Bank Number     */
  /****************************/

  fnd_file.put_line(FND_FILE.LOG,'Validating Bank Number...');

  BEGIN
    /* CE uptake - Bug#2932986
    SELECT distinct bank_number
    INTO            X_jlbr_bank_number
    FROM            jl_br_ar_bank_occurrences
    WHERE           bank_number = X_bank_number
                    AND ROWNUM < 2;
    */

    SELECT  prof.bank_or_branch_number,
            nvl(occ.bank_party_id,0)  --bug 8527766 - can be NULL in occ table
    INTO    X_jlbr_bank_number,
            p_bank_party_id
    FROM    jl_br_ar_bank_occurrences occ,
            hz_organization_profiles prof
    WHERE   prof.bank_or_branch_number = X_bank_number
      AND   occ.bank_party_id = prof.party_id
      AND   prof.home_country ='BR'
      AND   rownum = 1;

  fnd_file.put_line(FND_FILE.LOG,'x_jlbr_bank_number: ' || X_jlbr_bank_number);
  fnd_file.put_line(FND_FILE.LOG,'p_bank_party_id : ' || p_bank_party_id);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_error_code := 'INVALID_BANK_NUMBER';
        p_bank_party_id := 0;  --bug 8527766 - ensure value is NOT NULL
        RAISE error_validation;
  END;

  /*******************************/
  /* Validate Occurrence Code    */
  /*******************************/

  fnd_file.put_line(FND_FILE.LOG,'Validating Occurrence Code...');

  BEGIN
    -- CE uptake - Bug#2932986
    SELECT  occ.std_occurrence_code
    INTO    X_bank_occurrence_code_std
    FROM    jl_br_ar_bank_occurrences occ,
            hz_organization_profiles prof
    WHERE   occ.bank_occurrence_code = X_bank_occurrence_code
            AND prof.bank_or_branch_number = X_bank_number
            AND occ.bank_party_id = prof.party_id
            AND prof.home_country ='BR'
            AND occ.bank_occurrence_type = 'RETURN_OCCURRENCE'
	    AND SYSDATE between TRUNC(prof.effective_start_date)
            AND NVL(TRUNC(prof.effective_end_date), SYSDATE+1);

  fnd_file.put_line(FND_FILE.LOG,'x_bank_occurrence_code_std : ' || x_bank_occurrence_code_std);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_error_code := 'INVALID_BANK_OCCURRENCE_CODE';
        RAISE error_validation;
  END;

  /****************************/
  /* Validate Occurrence Date */
  /****************************/

  fnd_file.put_line(FND_FILE.LOG,'Validating Occurrence Date...');

  BEGIN
    valid_date := ARP_UTIL.IS_GL_DATE_VALID(p_occurrence_date);
    IF NOT valid_date THEN
      p_error_code := 'INVALID_OCCURRENCE_DATE';
      RAISE error_validation;
    END IF;
  END;


  /****************************/
  /* Validate Company Code    */
  /****************************/

  fnd_file.put_line(FND_FILE.LOG,'Validating Company Code...');

  BEGIN
  /*
    SELECT distinct aba.global_attribute7
    INTO            X_dual_num
    FROM            ap_bank_accounts_all aba,
                    jl_br_ar_collection_docs cd,
                    ar_payment_schedules_all arps
    WHERE   cd.document_id = X_company_use
    AND     aba.bank_account_id = cd.bank_account_id
    AND     arps.payment_schedule_id = cd.payment_schedule_id
  -- bug 1892303
  -- AND     arps.trx_number||'-'||to_char(arps.terms_sequence_number) = X_your_number
     AND     to_number(aba.global_attribute7) = X_company_code;
   */

    SELECT distinct acct.secondary_account_reference
    INTO            X_dual_num
    FROM            ce_bank_accounts acct,
                    ce_bank_acct_uses_all acctUse,
                    jl_br_ar_collection_docs cd,
                    ar_payment_schedules_all arps
    WHERE   cd.document_id = X_company_use
    AND     acctUse.bank_acct_use_id = cd.bank_acct_use_id
    AND     acct.bank_account_id = acctUse.bank_account_id
    AND     arps.payment_schedule_id = cd.payment_schedule_id
  --  bug 1892303
  --  AND     arps.trx_number||'-'||to_char(arps.terms_sequence_number) = trim(X_your_number)
    AND     to_number(acct.secondary_account_reference) = X_company_code;

fnd_file.put_line(FND_FILE.LOG,'x_dual_num : ' || x_dual_num);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_error_code := 'INVALID_COMPANY_CODE_FOR_BANK';
        RAISE error_validation;
      WHEN TOO_MANY_ROWS THEN
        null;
  END;

  /********************/
  /* Validate Document*/
  /********************/

  fnd_file.put_line(FND_FILE.LOG,'Validating Document...');

  IF X_company_use IS NOT null THEN
    BEGIN

      /* CE uptake - Bug#2932986
      SELECT doc.payment_schedule_id,
             doc.document_status,
             bra.bank_number
      INTO   X_payment_schedule_id,
             X_document_status,
             X_remittance_bank
      FROM   jl_br_ar_collection_docs doc,
             ap_bank_accounts_all acc,
             ap_bank_branches bra
      WHERE  doc.document_id = X_company_use
             AND doc.bank_account_id = acc.bank_account_id
             AND acc.bank_branch_id = bra.bank_branch_id;
      */

      SELECT doc.payment_schedule_id,
             doc.document_status,
             HzPartyBank.party_id bank_id
      INTO   X_payment_schedule_id,
             X_document_status,
             X_remittance_bank_id
      FROM   jl_br_ar_collection_docs doc,
             ce_bank_accounts CeBankAccount,
             ce_bank_acct_uses_all CeBankAcctUse,
             hz_parties HzPartyBank
       Where doc.bank_acct_use_id = CeBankAcctUse.bank_acct_use_id
             And CeBankAcctUse.bank_account_id = CeBankAccount.bank_account_id
             And CeBankAccount.BANK_ID =  HzPartyBank.PARTY_ID
             --And HzPartyBank.Country = 'BR'
             And doc.document_id = X_company_use;
       --End of CE uptake

fnd_file.put_line(FND_FILE.LOG,'x_payment_schedule_id : ' || x_payment_schedule_id);
fnd_file.put_line(FND_FILE.LOG,'x_document_status : ' || x_document_status);
fnd_file.put_line(FND_FILE.LOG,'x_remittance_bank_id : ' || x_remittance_bank_id);


      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          p_error_code := 'COLL_DOC_NOT_EXIST';
          RAISE error_validation;
        WHEN others THEN
          null;
    END;

fnd_file.put_line(FND_FILE.LOG,'Validating Trade Note...');

    BEGIN
      SELECT payment_schedule_id
      INTO   X_payment_schedule_id
      FROM   ar_payment_schedules
      WHERE  payment_schedule_id = X_payment_schedule_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          p_error_code := 'TRADE_NOTE_NOT_EXIST';
          RAISE error_validation;
        WHEN TOO_MANY_ROWS THEN
          null;
    END;

/*
  ELSE

    BEGIN
      SELECT payment_schedule_id
      INTO   X_payment_schedule_id
      FROM   ar_payment_schedules
      WHERE  trx_number|| '-' ||to_char(terms_sequence_number)=X_your_number;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          p_error_code := 'TRADE_NOTE_NOT_EXIST';
          RAISE error_validation;
        WHEN others THEN
          null;
    END;

    BEGIN
      SELECT doc.document_status,
             bra.bank_number
      INTO   X_document_status,
             X_remittance_bank
      FROM   jl_br_ar_collection_docs doc,
             ap_bank_accounts_all acc,
             ap_bank_branches bra
      WHERE  doc.payment_schedule_id = X_payment_schedule_id
             AND doc.bank_account_id = acc.bank_account_id
             AND acc.bank_branch_id = bra.bank_branch_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          p_error_code := 'COLL_DOC_NOT_EXIST';
          RAISE error_validation;
        WHEN others THEN
          null;
    END;

*/
  END IF;

  /****************************/
  /* Validate Bank            */
  /****************************/

  -- CE uptake - Bug#2932986
  IF X_remittance_bank_id <> p_bank_party_id THEN
    p_error_code := 'INVALID_BANK_NUMBER';
fnd_file.put_line(FND_FILE.LOG,'X_remittance_bank_id <> p_bank_party_id');
    RAISE error_validation;
  END IF;

  /****************/
  /* Validate CGC */
  /****************/

fnd_file.put_line(FND_FILE.LOG,'Validating Inscription Number...');

  BEGIN

  ----------------------------------------------------------------------
  -- BUG 4192066. JL_BR_COMPANY_INFOS is being obsoleted. To obtaint the
  --              registration number a new API is being called.
  --              To obtain the Reg Number we need to pass the party_id
  --              party_type and effective_date.
  ----------------------------------------------------------------------

     -----------------------------------------------------------
     -- Retrieve the set_of_books_id and acct_balancing_segment
     -- from ar_system_parameters
     -----------------------------------------------------------
     SELECT set_of_books_id,
            global_attribute1
       INTO l_ledger_id,
            l_acct_balancing_segment
       FROM ar_system_parameters;

  fnd_file.put_line(FND_FILE.LOG,'Legder Id : ' || l_ledger_id);
  fnd_file.put_line(FND_FILE.LOG,'Balancing Segment : ' || l_acct_balancing_segment);

     ------------------------------------------------------------
     -- Proceed to retrieve the Ledger Information which contains
     -- the Legal Entity Id as well
     ------------------------------------------------------------
/*     XLE_BUSINESSINFO_GRP.Get_Ledger_Info(
                x_return_status => l_return_status         ,
                x_msg_data      => l_msg_data              ,
                P_Ledger_ID     => l_ledger_id             ,
                P_BSV           => l_acct_balancing_segment,
                x_Ledger_info   => l_ledger_info
                );
     -------------------------------------------------------------
     -- Retrieve the Name of the Legal Entity
     -------------------------------------------------------------
     l_legal_entity_name := l_ledger_info(1).Name;
     l_party_id          := l_ledger_info(1).Party_id;
     l_legal_entity_id   := l_ledger_info(1).legal_entity_id;


     -------------------------------------------------------------
     -- Retrieve the Registration Number
     -------------------------------------------------------------
     XLE_UTILITIES_GRP.get_fp_vatregistration_LEID
                            (p_api_version      => 1.0,
                             p_init_msg_list    => l_init_msg_list,
                             p_commit           => l_commit,
                             p_effective_date   => sysdate,
                             x_return_status    => l_return_status,
                             x_msg_count        => l_msg_count,
                             x_msg_data         => l_msg_data,
                             p_legal_entity_id  => l_legal_entity_id,
                             x_registration_number => x_cgc
                             );*/
    -- Bug#8331293 Start
	-- Commenting below sql query.This is replaced by cursor Comp
     /* Select etb.registration_number
           INTO x_cgc
     From
          xle_establishment_v etb
         ,xle_bsv_associations bsv
         ,gl_ledger_le_v gl
     Where
          etb.legal_entity_id     = gl.legal_entity_id
     And   bsv.legal_parent_id   = etb.legal_entity_id
     And   etb.establishment_id  = bsv.legal_construct_id
     And   bsv.entity_name        = l_acct_balancing_segment
     And   gl.ledger_id              = l_ledger_id; */

	IF p_called_from = 'JLBRRVFD' then
     fnd_file.put_line(FND_FILE.LOG,'Called From JLBRRVFD');

	-- Called from program Brazilian Receivables Import of Bank Return Program(JLBRRVFD.sql)

    For Comp_JLBRRVFD_Rec in Comp_JLBRRVFD (    l_ledger_id
                         ,l_acct_balancing_segment
                         ,p_file_control
                         ,p_ent_seq_num	)
		Loop
       fnd_file.put_line(FND_FILE.LOG,'in the Comp_JLBRRVFD Cursor');
       fnd_file.put_line(FND_FILE.LOG,'Registration Number Fetched : ' || Comp_JLBRRVFD_Rec.registration_number);
			x_cgc := Comp_JLBRRVFD_Rec.registration_number;
		End Loop;

	ELSE

	-- It can be called from form Correct Bank Returns (JLBRRCDB.fmb)

	For Comp_JLBRRCDB_Rec in Comp_JLBRRCDB (    l_ledger_id
                         ,l_acct_balancing_segment
                         ,p_file_control
                         ,p_ent_seq_num	)
		Loop
       fnd_file.put_line(FND_FILE.LOG,'in the Comp_JLBRRCDB Cursor');
       fnd_file.put_line(FND_FILE.LOG,'Registration Number is : ' || Comp_JLBRRCDB_Rec.registration_number);
			x_cgc := Comp_JLBRRCDB_Rec.registration_number;
		End Loop;

	END IF;


    -- Bug#8331293 End

  /* SELECT distinct (decode(inf.register_type, 3, '00000000000000',
                            to_number(lpad(inf.register_number,9,'0')||
                            lpad(inf.register_subsidiary,4,'0')||
                            lpad(inf.register_digit,2,'0'))))
    INTO  X_cgc
    FROM  jl_br_company_infos inf,
          hz_cust_acct_sites_all adr,
          ra_customer_trx_all trx,
          ar_payment_schedules pay
    WHERE pay.payment_schedule_id = X_payment_schedule_id
          AND trx.customer_trx_id = pay.customer_trx_id
          AND adr.cust_acct_site_id = trx.remit_to_address_id
          AND inf.accounting_balancing_segment = adr.global_attribute1
          AND inf.set_of_books_id = trx.set_of_books_id; */
    fnd_file.put_line(FND_FILE.LOG,'Comapring value of X_cgc variable  ' || X_cgc);
    fnd_file.put_line(FND_FILE.LOG,'Comparing value of X_inscription_number ' || X_inscription_number);
    IF nvl(X_cgc,0) <> X_inscription_number THEN
      p_error_code := 'INVALID_COMPANY_INSCRIPT_NUM';
      fnd_file.put_line(FND_FILE.LOG,'Raising exception since the values are not matching');
      RAISE error_validation;
    END IF;

    EXCEPTION
      --WHEN NO_DATA_FOUND THEN
      WHEN OTHERS THEN
        p_error_code := 'INVALID_COMPANY_INSCRIPT_NUM';
        RAISE error_validation;
      /*WHEN TOO_MANY_ROWS THEN
        null;*/
  END;

  /**************************************/
  /* Validate Occurrence Code           */
  /**************************************/

  IF      X_bank_occurrence_code_std = 'CONFIRMED_ENTRY'
     AND  X_document_status = 'CANCELED'
     THEN p_error_code := 'COLL_DOC_CANCELED';
          RAISE error_validation;
  ELSIF   X_bank_occurrence_code_std = 'CONFIRMED_ENTRY'
     AND  X_document_status = 'REFUSED'
     THEN p_error_code := 'COLL_DOC_REFUSED';
          RAISE error_validation;
  ELSIF   X_bank_occurrence_code_std = 'CONFIRMED_ENTRY'
     AND  X_document_status = 'WRITTEN_OFF'
     THEN p_error_code := 'COLL_DOC_WRITTEN_OFF';
          RAISE error_validation;
  ELSIF   X_bank_occurrence_code_std = 'PARTIAL_SETTLEMENT'
     AND  X_document_status = 'PARTIALLY_RECEIVED'
     THEN p_error_code := 'COLL_DOC_PARTIAL_RECEIVED';
          RAISE error_validation;
  ELSIF   X_bank_occurrence_code_std = 'CONFIRMED_ENTRY'
     AND  X_document_status = 'PARTIALLY_RECEIVED'
     THEN p_error_code := 'COLL_DOC_PARTIAL_RECEIVED';
          RAISE error_validation;
  ELSIF   X_bank_occurrence_code_std = 'CONFIRMED_ENTRY'
     AND  X_document_status = 'TOTALLY_RECEIVED'
     THEN p_error_code := 'COLL_DOC_FULLY_RECEIVED';
          RAISE error_validation;
  ELSIF   X_bank_occurrence_code_std = 'REJECTED_ENTRY'
     AND  X_document_status = 'CANCELED'
     THEN p_error_code := 'COLL_DOC_CANCELED';
          RAISE error_validation;
  ELSIF   X_bank_occurrence_code_std = 'REJECTED_ENTRY'
     AND  X_document_status <> 'FORMATTED'
     THEN p_error_code := 'COLL_DOC_NOT_REJECTED';
          RAISE error_validation;
  ELSIF   X_bank_occurrence_code_std in
                                     ('FULL_SETTLEMENT','PARTIAL_SETTLEMENT')
     AND  X_document_status = 'TOTALLY_RECEIVED'
     THEN p_error_code := 'COLL_DOC_FULLY_RECEIVED';
          RAISE error_validation;
  ELSIF   X_bank_occurrence_code_std in
                                     ('FULL_SETTLEMENT','PARTIAL_SETTLEMENT')
     AND  X_document_status = 'REFUSED'
     THEN p_error_code := 'COLL_DOC_REFUSED';
          RAISE error_validation;
  ELSIF   X_bank_occurrence_code_std in
                                     ('FULL_SETTLEMENT','PARTIAL_SETTLEMENT')
     AND  X_document_status = 'WRITTEN_OFF'
     THEN p_error_code := 'COLL_DOC_WRITTEN_OFF';
          RAISE error_validation;
  ELSIF   X_bank_occurrence_code_std in
                                     ('FULL_SETTLEMENT','PARTIAL_SETTLEMENT')
     AND  X_document_status = 'CANCELED'
     THEN p_error_code := 'COLL_DOC_CANCELED';
          RAISE error_validation;
/*
  ELSIF   X_bank_occurrence_code_std = 'DEBIT_BALANCE_SETTLEMENT'
     AND  X_document_status = 'TOTALLY_RECEIVED'
     THEN p_error_code := 'COLL_DOC_FULLY_RECEIVED';
          RAISE error_validation;
  ELSIF   X_bank_occurrence_code_std = 'DEBIT_BALANCE_SETTLEMENT'
     AND  X_document_status = 'REFUSED'
     THEN p_error_code := 'COLL_DOC_REFUSED';
          RAISE error_validation;
  ELSIF   X_bank_occurrence_code_std = 'DEBIT_BALANCE_SETTLEMENT'
     AND  X_document_status = 'WRITTEN_OFF'
     THEN p_error_code := 'COLL_DOC_WRITTEN_OFF';
          RAISE error_validation;
  ELSIF   X_bank_occurrence_code_std = 'DEBIT_BALANCE_SETTLEMENT'
     AND  X_document_status = 'CANCELED'
     THEN p_error_code := 'COLL_DOC_CANCELED';
          RAISE error_validation;
*/
  ELSIF   X_bank_occurrence_code_std = 'AUTOMATIC_WRITE_OFF'
     AND  X_document_status = 'WRITTEN_OFF'
     THEN p_error_code := 'COLL_DOC_WRITTEN_OFF';
          RAISE error_validation;
  ELSIF   X_bank_occurrence_code_std = 'AUMOMATIC_WRITE_OFF'
     AND  X_document_status = 'REFUSED'
     THEN p_error_code := 'COLL_DOC_REFUSED';
          RAISE error_validation;
  ELSIF   X_bank_occurrence_code_std = 'AUMOMATIC_WRITE_OFF'
     AND  X_document_status = 'PARTIALLY_RECEIVED'
     THEN p_error_code := 'COLL_DOC_PARTIAL_RECEIVED';
          RAISE error_validation;
  ELSIF   X_bank_occurrence_code_std = 'AUMOMATIC_WRITE_OFF'
     AND  X_document_status = 'TOTALLY_RECEIVED'
     THEN p_error_code := 'COLL_DOC_FULLY_RECEIVED';
          RAISE error_validation;
  ELSIF   X_bank_occurrence_code_std = 'AUMOMATIC_WRITE_OFF'
     AND  X_document_status = 'CANCELED'
     THEN p_error_code := 'COLL_DOC_CANCELED';
          RAISE error_validation;
  ELSIF   X_bank_occurrence_code_std = 'PAYMENT_AFTER_WRITE_OFF'
     AND  X_document_status = 'REFUSED'
     THEN p_error_code := 'COLL_DOC_REFUSED';
          RAISE error_validation;
  ELSIF   X_bank_occurrence_code_std = 'PAYMENT_AFTER_WRITE_OFF'
     AND  X_document_status = 'PARTIALLY_RECEIVED'
     THEN p_error_code := 'COLL_DOC_PARTIAL_RECEIVED';
          RAISE error_validation;
  ELSIF   X_bank_occurrence_code_std = 'PAYMENT_AFTER_WRITE_OFF'
     AND  X_document_status = 'TOTALLY_RECEIVED'
     THEN p_error_code := 'COLL_DOC_FULLY_RECEIVED';
          RAISE error_validation;
  ELSIF   X_bank_occurrence_code_std = 'PAYMENT_AFTER_WRITE_OFF'
     AND  X_document_status = 'CANCELED'
     THEN p_error_code := 'COLL_DOC_CANCELED';
          RAISE error_validation;
  ELSIF   X_bank_occurrence_code_std = 'PAYMENT_AFTER_WRITE_OFF'
     AND  X_document_status <> 'WRITTEN_OFF'
     THEN p_error_code := 'COLL_DOC_NOT_WRITTEN_OFF';
          RAISE error_validation;
 END IF;

  /******************************************/
  /* Validate Customer Name                 */
  /******************************************/

/* Old code replaced because of translation issues */

/*  IF X_customer_name IS NOT null THEN
    BEGIN
      SELECT   substr(pty.party_name, 1,50)
      INTO     X_customer_name1
      FROM     hz_cust_accounts_all cst,
               hz_parties pty,
               ra_customer_trx trx
      WHERE    trx.bill_to_customer_id = cst.cust_account_id
               AND cst.party_id = pty.party_id
               AND trx.customer_trx_id = (SELECT customer_trx_id
                                          FROM   ar_payment_schedules
                                          WHERE  payment_schedule_id =
                                                 X_payment_schedule_id);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          p_error_code := 'INVALID_CUSTOMER_NAME';
          RAISE error_validation;
        WHEN TOO_MANY_ROWS THEN
          null;
    END;

    IF rpad(substr(X_customer_name1,1,30),30) <>
         rpad(substr(X_customer_name,1,30),30)
    THEN p_error_code := 'INVALID_CUSTOMER_NAME';
         RAISE error_validation;
    END IF;

 END IF; */

/* New Code for Validate customer name because of translation issues */

/* Bug 1329486 Customer name validation removed from logical val procedure */
/* because of special characters */

  IF X_bank_occurrence_code_std = 'FULL_SETTLEMENT' THEN

    /*************************/
    /* Validate Credit Amount*/
    /*************************/

    IF nvl(X_trade_note_amount,0) <> nvl(X_credit_amount,0) -
                                     nvl(X_interest_amount_received,0) +
                                     nvl(X_discount_amount,0) +
                                     nvl(X_abatement_amount,0)
    THEN
      p_error_code := 'INCORRECT_AMOUNT';
      RAISE error_validation;
    END IF;

  END IF;

  /*************************************************/
  /* Validate Document Amount with Original Amount */
  /*************************************************/

  BEGIN
    SELECT nvl(doc.document_amount,0)
    INTO   X_document_amount
    FROM   jl_br_ar_bank_occurrences ban,
           jl_br_ar_occurrence_docs_all doc,
           jl_br_ar_collection_docs cob
    WHERE  ban.std_occurrence_code = 'REMITTANCE'
           AND ban.bank_occurrence_type = 'REMITTANCE_OCCURRENCE'
           --AND ban.bank_number = X_bank_number
           AND ban.bank_party_id = p_bank_party_id
           AND doc.bank_occurrence_code = ban.bank_occurrence_code
           AND doc.occurrence_status in ('CONFIRMED')
           --AND doc.bank_number = ban.bank_number
           AND doc.bank_party_id = ban.bank_party_id
           AND doc.bank_occurrence_type = ban.bank_occurrence_type
           AND doc.document_id = cob.document_id
/*
           AND cob.document_status in ('FORMATTED','CONFIRMED')
           AND cob.payment_schedule_id = X_payment_schedule_id;
*/
           AND cob.document_id = X_company_use;

    EXCEPTION
      WHEN others THEN
        X_document_amount := -1;
  END;

  IF X_document_amount <> X_trade_note_amount THEN
    p_error_code := 'COLL_DOC_AMOUNT_NOT_MATCH';
    RAISE error_validation;
  END IF;


  /****************************/
  /* No Validation Error      */
  /****************************/

  p_error_code := 'SUCCESS';

EXCEPTION
  WHEN error_validation THEN null;

END logical_validation;

END JL_BR_AR_LOG_VALIDATION;


/
