--------------------------------------------------------
--  DDL for Package Body CE_STATEMENT_RECONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_STATEMENT_RECONS_PKG" AS
/* $Header: cestmreb.pls 120.4.12010000.2 2008/11/04 04:46:15 csutaria ship $ */

  l_DEBUG varchar2(1) := NVL(FND_PROFILE.value('CE_DEBUG'), 'N');
  --l_DEBUG varchar2(1) := 'Y';

  FUNCTION body_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN '$Revision: 120.4.12010000.2 $';

  END body_revision;

  FUNCTION spec_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN G_spec_revision;

  END spec_revision;

--
-- PUBLIC FUNCTIONS
--

  PROCEDURE check_unique(X_statement_line_id    NUMBER,
                         X_reference_type       VARCHAR2,
                         X_reference_id         VARCHAR2,
                         X_current_record_flag  VARCHAR2,
                         X_row_id               VARCHAR2) IS
    CURSOR chk_duplicates is
      SELECT 'Duplicate'
      FROM   CE_STATEMENT_RECON_GT_V csr --CE_STATEMENT_RECONCILIATIONS csr
      WHERE  csr.statement_line_id 	= X_statement_line_id
      AND    csr.reference_type   	= X_reference_type
      AND    csr.reference_id		= X_reference_id
      AND    csr.current_record_flag	= X_current_record_flag
      AND    (   X_row_id is null
              OR csr.row_id <> chartorowid(X_row_id));
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_duplicates;
    FETCH chk_duplicates INTO dummy;

    IF chk_duplicates%FOUND THEN
      CLOSE chk_duplicates;
      fnd_message.set_name('CE', 'CE_DUPLICATE_EXCHANGE_RATE');
      app_exception.raise_exception;
    END IF;
    CLOSE chk_duplicates;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'ce_statement_recons_pkg.check_unique');
      RAISE;
  END check_unique;

  PROCEDURE Insert_Row( X_Row_id                         IN OUT NOCOPY VARCHAR2,
                        X_statement_line_id             NUMBER,
                        X_reference_type                VARCHAR2,
                        X_reference_id                  NUMBER,
			X_org_id			NUMBER,
			X_legal_entity_id		NUMBER,
			X_reference_status		VARCHAR2,
			X_amount			NUMBER	DEFAULT NULL,
                        X_status_flag                   VARCHAR2,
                        X_action_flag                   VARCHAR2,
                        X_current_record_flag           VARCHAR2,
                        X_auto_reconciled_flag          VARCHAR2,
                        X_created_by                    NUMBER,
                        X_creation_date                 DATE,
                        X_last_updated_by               NUMBER,
                        X_last_update_date              DATE,
                        X_request_id                    NUMBER  DEFAULT NULL,
                        X_program_application_id        NUMBER  DEFAULT NULL,
                        X_program_id                    NUMBER  DEFAULT NULL,
                        X_program_update_date           DATE    DEFAULT NULL) IS

    reference_type_tmp		VARCHAR2(30);
    X_cash_receipt_id		NUMBER(15);
    X_statement_type 		VARCHAR2(30);
    X_org_id_tmp		NUMBER(15);
    Y_org_id			NUMBER(15);
    X_legal_entity_id_tmp		NUMBER(15);
    Y_legal_entity_id			NUMBER(15);

    CURSOR C_ROWID IS SELECT row_id FROM CE_STATEMENT_RECON_GT_V
                 WHERE statement_line_id = X_Statement_Line_Id
                 AND   reference_type = reference_type_tmp
                 AND   reference_id = X_Reference_Id
		 AND   current_record_flag = x_current_record_flag;

    CURSOR C_STMT_LOCK IS SELECT row_id, org_id, legal_entity_id
     FROM   	CE_STATEMENT_RECON_GT_V
     WHERE  	reference_type = reference_type_tmp	AND
		reference_id   = X_reference_id		AND
		statement_line_id = X_statement_line_id	AND
	        current_record_flag = 'Y'
     FOR UPDATE of current_record_flag NOWAIT;

    CURSOR C_LOCK IS SELECT row_id, org_id, legal_entity_id
     FROM   	CE_STATEMENT_RECON_GT_V
     WHERE  	reference_type = reference_type_tmp	AND
		reference_id   = X_reference_id		AND
	        current_record_flag = 'Y'
     FOR UPDATE of current_record_flag NOWAIT;
   BEGIN
   IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_STATEMENT_RECONS_PKG.insert_row 1');
  	cep_standard.debug('X_Row_id = '|| X_Row_id ||  ', X_statement_line_id = '  ||  X_statement_line_id);
        cep_standard.debug('X_reference_type ='||  X_reference_type  ||', X_reference_id = '|| X_reference_id ||
			   ', X_org_id = '||X_org_id || ', X_legal_entity_id = '||X_legal_entity_id ||
			   ', X_reference_status ='|| X_reference_status);
	cep_standard.debug('X_amount = ' || X_amount ||', X_status_flag = ' || X_status_flag ||
                           ', X_action_flag ='|| X_action_flag ||', X_current_record_flag = '|| X_current_record_flag ||
                           ', X_auto_reconciled_flag = ' ||X_auto_reconciled_flag);
    END IF;

    --
     -- Map AR transactions types 'MISC' and 'CASH' to 'RECEIPT'
     --
     IF (X_reference_type IN ('MISC','CASH')) THEN
       --
       -- Check to see if the receipt has been Debit Memo Reversed
       -- If the receipt is DM Reversed then assign the reference_type to be 'DM REVERSAL'
       --

       SELECT cash_receipt_id
       INTO X_cash_receipt_id
       FROM ar_cash_receipt_history_all
       WHERE cash_receipt_history_id = X_reference_id;

      BEGIN
       SELECT trx_type
       INTO X_statement_type
       FROM ce_statement_lines
       WHERE statement_line_id = X_statement_line_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
         X_statement_type := 'X';
       END;

       IF (arp_cashbook.receipt_debit_memo_reversed(X_cash_receipt_id)='Y')
		and (X_statement_type IN ('NSF', 'REJECTED')) THEN
         reference_type_tmp := 'DM REVERSAL';
       ELSE
         reference_type_tmp := 'RECEIPT';
       END IF;

     ELSE
       reference_type_tmp := X_reference_type;
     END IF;

     cep_standard.debug( ' reference_type_tmp ='||reference_type_tmp);

     --
     -- Lock the 'Y' in the CE_STATEMENT_RECONCILIATIONS
     -- to make sure that there is not anybody else matcing this transaction
     --
     IF(X_reference_type = 'STATEMENT')THEN
       OPEN C_STMT_LOCK;
       FETCH C_STMT_LOCK INTO X_Row_Id, X_org_id_tmp, X_legal_entity_id_tmp;
       if (C_STMT_LOCK%NOTFOUND) then
        CLOSE C_STMT_LOCK;
       ELSE
         UPDATE CE_STATEMENT_RECONCILS_ALL SET current_record_flag = 'N'
         WHERE rowid = X_Row_id;
         CLOSE C_STMT_LOCK;
       END IF;
     ELSE
       OPEN C_LOCK;
       FETCH C_LOCK INTO X_Row_Id, X_org_id_tmp, X_legal_entity_id_tmp;
       if (C_LOCK%NOTFOUND) then
        CLOSE C_LOCK;
       ELSE
         UPDATE CE_STATEMENT_RECONCILS_ALL SET current_record_flag = 'N'
         WHERE rowid = X_Row_id;
         CLOSE C_LOCK;
       END IF;
     END IF;

     IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('INSERT INTO CE_STATEMENT_RECON_GT_V');
     END IF;

     cep_standard.debug( ' X_org_id_tmp ='||X_org_id_tmp );
     cep_standard.debug( ' X_legal_entity_id_tmp ='||X_legal_entity_id_tmp );

     IF (X_org_id is null) THEN
	Y_org_id := X_org_id_tmp;
     ELSE
	Y_org_id := X_org_id;
     END IF;
     IF (X_legal_entity_id is null) THEN
	Y_legal_entity_id := X_legal_entity_id_tmp;
     ELSE
	Y_legal_entity_id := X_legal_entity_id;
     END IF;

     cep_standard.debug( ' Y_org_id ='||Y_org_id);
     cep_standard.debug( ' Y_legal_entity_id ='||Y_legal_entity_id);

     INSERT INTO CE_STATEMENT_RECONCILS_ALL(
              statement_line_id,
              reference_type,
              reference_id,
              status_flag,
	      amount,
              current_record_flag,
              auto_reconciled_flag,
              org_id,
              legal_entity_id,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
	      request_id,
	      program_application_id,
	      program_id,
	      program_update_date)
	      VALUES
	     (X_Statement_Line_Id,
              Reference_Type_Tmp,
              X_Reference_Id,
              X_Status_flag,
	      X_amount,
              X_Current_Record_Flag,
              X_Auto_Reconciled_Flag,
	      Y_org_id,
	      Y_legal_entity_id,
              X_Created_By,
              X_Creation_Date,
              X_last_updated_by,
              X_last_update_date,
	      DECODE(X_auto_reconciled_flag,'Y',
	             X_request_id,
		     NULL),
	      DECODE(X_auto_reconciled_flag,'Y',
	             X_program_application_id,
		     NULL),
	      DECODE(X_auto_reconciled_flag,'Y',
	             X_program_id,
		     NULL),
	      DECODE(X_auto_reconciled_flag,'Y',
	             X_program_update_date,
		     NULL));

   IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('end INSERT INTO CE_STATEMENT_RECON_GT_V');
   END IF;



    OPEN C_ROWID;
    FETCH C_ROWID INTO X_Row_Id;
    IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug(' fetch X_Row_Id ' ||X_Row_Id);
    END IF;
    --if (C_ROWID%NOTFOUND) then
    if (X_Row_Id is null ) then
      CLOSE C_ROWID;

      IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('Raise NO_DATA_FOUND');
      END IF;

      Raise NO_DATA_FOUND;

      IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('end Raise NO_DATA_FOUND');
      END IF;
    end if;
   IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug(' xx2 ');
   END IF;
    IF (X_status_flag = 'M') THEN
      DELETE from CE_RECONCILIATION_ERRORS
      WHERE  statement_line_id = X_statement_line_id;
    END IF;
    CLOSE C_ROWID;
   IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_STATEMENT_RECONS_PKG.insert_row 1');
   END IF;
  END Insert_Row;

  PROCEDURE Insert_Row( X_Row_id                         IN OUT NOCOPY VARCHAR2,
                        X_statement_line_id             NUMBER,
                        X_reference_type                VARCHAR2,
                        X_reference_id                  NUMBER,
			X_je_header_id			NUMBER,
			X_org_id			NUMBER,
			X_legal_entity_id		NUMBER,
			X_reference_status		VARCHAR2,
			X_amount                        NUMBER  DEFAULT NULL,
                        X_status_flag                   VARCHAR2,
                        X_action_flag                   VARCHAR2,
                        X_current_record_flag           VARCHAR2,
                        X_auto_reconciled_flag          VARCHAR2,
                        X_created_by                    NUMBER,
                        X_creation_date                 DATE,
                        X_last_updated_by               NUMBER,
                        X_last_update_date              DATE,
                        X_request_id                    NUMBER  DEFAULT NULL,
                        X_program_application_id        NUMBER  DEFAULT NULL,
                        X_program_id                    NUMBER  DEFAULT NULL,
                        X_program_update_date           DATE    DEFAULT NULL) IS

    reference_type_tmp		VARCHAR2(30);
    X_cash_receipt_id		NUMBER(15);
    X_statement_type		VARCHAR2(30);
    X_org_id_tmp		NUMBER(15);
    Y_org_id			NUMBER(15);
    X_legal_entity_id_tmp		NUMBER(15);
    Y_legal_entity_id			NUMBER(15);
    CURSOR C_ROWID IS SELECT row_id FROM CE_STATEMENT_RECON_GT_V
                 WHERE statement_line_id = X_Statement_Line_Id
                 AND   reference_type = reference_type_tmp
                 AND   reference_id = X_Reference_Id
		 AND   je_header_id = X_je_header_id
		 AND   current_record_flag = x_current_record_flag;

    CURSOR C_LOCK IS SELECT row_id, org_id, legal_entity_id
     FROM   	CE_STATEMENT_RECON_GT_V
     WHERE 	reference_type = reference_type_tmp	AND
		reference_id   = X_reference_id		AND
		je_header_id   = X_je_header_id		AND
             --   statement_line_id = X_Statement_Line_Id AND  bug 6888494
	        current_record_flag = 'Y'
     FOR UPDATE of current_record_flag NOWAIT;
   BEGIN
   IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_STATEMENT_RECONS_PKG.insert_row 2');
   END IF;
     --
     -- Map AR transactions types 'MISC' and 'CASH' to 'RECEIPT'
     --
     IF (X_reference_type IN ('MISC','CASH')) THEN
       --
       -- Check to see if the receipt has been Debit Memo Reversed
       -- If the receipt is DM Reversed then assign the reference_type to be 'DM REVERSAL'
       --
       SELECT cash_receipt_id
       INTO X_cash_receipt_id
       FROM ar_cash_receipt_history_all
       WHERE cash_receipt_history_id = X_reference_id;

      BEGIN
       SELECT trx_type
       INTO X_statement_type
       FROM ce_statement_lines
       WHERE statement_line_id = X_statement_line_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
         X_statement_type := 'X';
      END;


       IF (arp_cashbook.receipt_debit_memo_reversed(X_cash_receipt_id)='Y')
		and (X_statement_type IN ('NSF', 'REJECTED')) THEN
         reference_type_tmp := 'DM REVERSAL';
       ELSE
         reference_type_tmp := 'RECEIPT';
       END IF;

     ELSE
       reference_type_tmp := X_reference_type;
     END IF;

     cep_standard.debug( ' reference_type_tmp ='||reference_type_tmp);


     --
     -- Lock the 'Y' in the CE_STATEMENT_RECONCILIATIONS
     -- to make sure that there is not anybody else matcing this transaction
     --
     OPEN C_LOCK;
     FETCH C_LOCK INTO X_Row_Id, x_org_id_tmp, x_legal_entity_id_tmp;
     if (C_LOCK%NOTFOUND) then
      CLOSE C_LOCK;
     ELSE
       UPDATE CE_STATEMENT_RECONCILS_ALL SET current_record_flag = 'N'
       WHERE rowid = X_Row_id;
       CLOSE C_LOCK;
     END IF;
   IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('INSERT INTO CE_STATEMENT_RECONCILS_ALL 2');
   END IF;

     cep_standard.debug( ' X_org_id_tmp ='||X_org_id_tmp );
     cep_standard.debug( ' X_legal_entity_id_tmp ='||X_legal_entity_id_tmp );

     IF (X_org_id is null) THEN
	Y_org_id := X_org_id_tmp;
     ELSE
	Y_org_id := X_org_id;
     END IF;
     IF (X_legal_entity_id is null) THEN
	Y_legal_entity_id := X_legal_entity_id_tmp;
     ELSE
	Y_legal_entity_id := X_legal_entity_id;
     END IF;

     cep_standard.debug( ' reference_type_tmp ='||reference_type_tmp);
     cep_standard.debug( ' Y_org_id ='||Y_org_id);
     cep_standard.debug( ' Y_legal_entity_id ='||Y_legal_entity_id);


     INSERT INTO CE_STATEMENT_RECONCILS_ALL(
              statement_line_id,
              reference_type,
              reference_id,
	      je_header_id,
              status_flag,
	      amount,
              current_record_flag,
              auto_reconciled_flag,
	      org_id,
 	      legal_entity_id,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
	      request_id,
	      program_application_id,
	      program_id,
	      program_update_date)
	      VALUES
	     (X_Statement_Line_Id,
              Reference_Type_Tmp,
              X_Reference_Id,
	      X_je_header_id,
              X_Status_flag,
	      X_amount,
              X_Current_Record_Flag,
              X_Auto_Reconciled_Flag,
	      Y_org_id,
 	      Y_legal_entity_id,
              X_Created_By,
              X_Creation_Date,
              X_last_updated_by,
              X_last_update_date,
	      DECODE(X_auto_reconciled_flag,'Y',
	             X_request_id,
		     NULL),
	      DECODE(X_auto_reconciled_flag,'Y',
	             X_program_application_id,
		     NULL),
	      DECODE(X_auto_reconciled_flag,'Y',
	             X_program_id,
		     NULL),
	      DECODE(X_auto_reconciled_flag,'Y',
	             X_program_update_date,
		     NULL));

   IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('end INSERT INTO CE_STATEMENT_RECONCILS_ALL 2');
   END IF;
    OPEN C_ROWID;
    FETCH C_ROWID INTO X_Row_Id;
    if (C_ROWID%NOTFOUND) then
      CLOSE C_ROWID;
      Raise NO_DATA_FOUND;
    end if;
    IF (X_status_flag = 'M') THEN
      DELETE from CE_RECONCILIATION_ERRORS
      WHERE  statement_line_id = X_statement_line_id;
    END IF;
    CLOSE C_ROWID;
   IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_STATEMENT_RECONS_PKG.insert_row 2');
   END IF;
  END Insert_Row;


  PROCEDURE Lock_Row  ( X_Row_id                         IN OUT NOCOPY VARCHAR2,
                        X_statement_line_id             NUMBER,
                        X_reference_type                VARCHAR2,
                        X_reference_id                  NUMBER,
                        X_status                        VARCHAR2,
                        X_cleared_when_matched          VARCHAR2,
                        X_current_record_flag           VARCHAR2,
                        X_auto_reconciled_flag          VARCHAR2) IS
    Counter NUMBER;
    CURSOR C IS
        SELECT 	statement_line_id,
              	reference_type,
              	reference_id,
              	status_flag,
              	current_record_flag,
              	auto_reconciled_flag
        FROM   	CE_STATEMENT_RECON_GT_V
        WHERE  	statement_line_id = X_statement_line_id AND
		reference_type = X_reference_type	AND
		reference_id   = X_reference_id
        FOR UPDATE of Statement_Line_Id,reference_type, reference_id NOWAIT;
    Recinfo C%ROWTYPE;
  BEGIN
    Counter := 0;
    LOOP
      BEGIN
        Counter := Counter + 1;
        OPEN C;
        FETCH C INTO Recinfo;
        if (C%NOTFOUND) then
          CLOSE C;
          FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
          APP_EXCEPTION.RAISE_EXCEPTION;
        end if;
        CLOSE C;
        if ( (Recinfo.statement_line_id =  X_Statement_Line_Id)
           AND (Recinfo.reference_type =  X_Reference_Type)
           AND (Recinfo.reference_id =  X_Reference_Id)
           AND (   (Recinfo.status_flag =  X_Status)
                OR (    (Recinfo.status_flag IS NULL)
                    AND (X_Status IS NULL)))
           AND (   (Recinfo.current_record_flag =  X_Current_Record_Flag)
                OR (    (Recinfo.current_record_flag IS NULL)
                    AND (X_Current_Record_Flag IS NULL)))
           AND (   (Recinfo.auto_reconciled_flag =  X_Auto_Reconciled_Flag)
                OR (    (Recinfo.auto_reconciled_flag IS NULL)
                    AND (X_Auto_Reconciled_Flag IS NULL)))
          ) THEN
          return;
        else
          FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
          APP_EXCEPTION.RAISE_EXCEPTION;
        end if;
      END;
    end LOOP;
  END Lock_Row;

  PROCEDURE Update_Row( X_Row_id                         IN OUT NOCOPY VARCHAR2,
                        X_statement_line_id             NUMBER,
                        X_reference_type                VARCHAR2,
                        X_reference_id                  NUMBER,
                        X_status                        VARCHAR2,
                        X_cleared_when_matched          VARCHAR2,
                        X_current_record_flag           VARCHAR2,
                        X_auto_reconciled_flag          VARCHAR2,
                        X_created_by                    NUMBER,
                        X_creation_date                 DATE,
                        X_last_updated_by               NUMBER,
                        X_last_update_date              DATE) IS
  BEGIN
    UPDATE CE_STATEMENT_RECONCILS_ALL
    SET
       statement_line_id               =     X_Statement_Line_Id,
       reference_type                  =     X_Reference_Type,
       reference_id                    =     X_Reference_Id,
       status_flag                     =     X_Status,
       current_record_flag             =     X_Current_Record_Flag,
       auto_reconciled_flag            =     X_Auto_Reconciled_Flag,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_date                =     X_Last_Update_Date
    WHERE rowid = X_Row_Id;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Row_id VARCHAR2) IS
  BEGIN
    DELETE FROM CE_STATEMENT_RECONCILS_ALL
    WHERE rowid = X_Row_Id;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

END ce_statement_recons_pkg;

/
