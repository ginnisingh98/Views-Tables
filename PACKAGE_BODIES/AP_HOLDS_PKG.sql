--------------------------------------------------------
--  DDL for Package Body AP_HOLDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_HOLDS_PKG" AS
/* $Header: apiholdb.pls 120.10.12010000.3 2009/02/20 06:51:36 anarun ship $ */


/*  */
G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_HOLDS_PKG';
G_MSG_UERROR        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
G_MSG_ERROR         CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_ERROR;
G_MSG_SUCCESS       CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
G_MSG_HIGH          CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
G_MSG_MEDIUM        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
G_MSG_LOW           CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
G_LINES_PER_FETCH   CONSTANT NUMBER       := 1000;

G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER   := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED      CONSTANT NUMBER   := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR           CONSTANT NUMBER   := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION       CONSTANT NUMBER   := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT           CONSTANT NUMBER   := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE       CONSTANT NUMBER   := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT       CONSTANT NUMBER   := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME           CONSTANT VARCHAR2(100) := 'AP.PLSQL.AP_HOLDS_PKG.';

PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       x_hold_id                 in out nocopy number, --5128839
                       X_Invoice_Id                     NUMBER,
                       X_Line_Location_Id               NUMBER,
                       X_Hold_Lookup_Code               VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Held_By                        NUMBER,
                       X_Hold_Date                      DATE,
                       X_Hold_Reason                    VARCHAR2,
                       X_Release_Lookup_Code            VARCHAR2,
                       X_Release_Reason                 VARCHAR2,
                       X_Status_Flag                    VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
		       X_Responsibility_Id		NUMBER,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Org_Id                         NUMBER,
		       X_calling_sequence	IN	VARCHAR2
  ) IS
    CURSOR C IS SELECT rowid FROM AP_HOLDS
                 WHERE invoice_id = X_Invoice_Id
                 AND   (    (line_location_id = X_Line_Location_Id)
                        or (line_location_id is NULL and X_Line_Location_Id is NULL))
                 AND   hold_lookup_code = X_Hold_Lookup_Code;
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);
    l_user_releaseable_flag     VARCHAR2(1);
    l_initiate_workflow_flag    VARCHAR2(1);

   BEGIN

--     Update the calling sequence
--
       current_calling_sequence := 'AP_HOLDS_PKG.INSERT_ROW<-' ||
                                    X_calling_sequence;


       select ap_holds_s.nextval
       into x_hold_id
       from dual;

       debug_info := 'Insert into AP_HOLDS';
       INSERT INTO AP_HOLDS(
              hold_id,
              invoice_id,
              line_location_id,
              hold_lookup_code,
              last_update_date,
              last_updated_by,
              held_by,
              hold_date,
              hold_reason,
              release_lookup_code,
              release_reason,
              status_flag,
              last_update_login,
              creation_date,
              created_by,
              responsibility_id,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15,
              attribute_category,
              org_id
             ) VALUES (
              x_hold_id,
              X_Invoice_Id,
              X_Line_Location_Id,
              X_Hold_Lookup_Code,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Held_By,
              X_Hold_Date,
              X_Hold_Reason,
              X_Release_Lookup_Code,
              X_Release_Reason,
              X_Status_Flag,
              X_Last_Update_Login,
              X_Creation_Date,
              X_Created_By,
	      X_Responsibility_Id,
              X_Attribute1,
              X_Attribute2,
              X_Attribute3,
              X_Attribute4,
              X_Attribute5,
              X_Attribute6,
              X_Attribute7,
              X_Attribute8,
              X_Attribute9,
              X_Attribute10,
              X_Attribute11,
              X_Attribute12,
              X_Attribute13,
              X_Attribute14,
              X_Attribute15,
              X_Attribute_Category,
              X_Org_Id
             );

    -- See if this is user releaseable and
    -- Workflow enabled hold. If so, start the
    -- workflow.
    /* bug 5206670. Hold Workflow */
    SELECT nvl(user_releaseable_flag,'N'),
           nvl(initiate_workflow_flag,'N')
    INTO   l_user_releaseable_flag,
           l_initiate_workflow_flag
    FROM   ap_hold_codes
    WHERE  hold_lookup_code = X_Hold_Lookup_Code;

    IF (l_user_releaseable_flag = 'Y' AND
       l_initiate_workflow_flag = 'Y') THEN

       AP_WORKFLOW_PKG.create_hold_wf_process(x_hold_id);

    END IF;

    --Bug 4539462 DBI logging
    AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_HOLDS',
               p_operation => 'I',
               p_key_value1 => X_invoice_id,
                p_calling_sequence => current_calling_sequence);

    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      debug_info := 'Close cursor C - ROW NOTFOUND';
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    debug_info := 'Close cursor C';
    CLOSE C;

    EXCEPTION
        WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || X_Rowid ||
                       			', INVOICE_ID == ' || TO_CHAR(X_Invoice_Id) ||
                       			', LINE_LOCATION_ID = ' || TO_CHAR(X_Line_Location_Id) ||
                       			', HOLD_LOOKUP_CODE = ' || X_Hold_Lookup_Code);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;


  END Insert_Row;


/*   */
  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,

                     X_Invoice_Id                       NUMBER,
                     X_Line_Location_Id                 NUMBER,
                     X_Hold_Lookup_Code                 VARCHAR2,
                     X_Held_By                          NUMBER,
                     X_Hold_Date                        DATE,
                     X_Hold_Reason                      VARCHAR2,
                     X_Release_Lookup_Code              VARCHAR2,
                     X_Release_Reason                   VARCHAR2,
                     X_Status_Flag                      VARCHAR2,
		     X_Responsibility_Id		NUMBER,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Attribute_Category               VARCHAR2,
                     X_Org_Id                           NUMBER,
		     X_calling_sequence		IN	VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   AP_HOLDS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Invoice_Id NOWAIT;
    Recinfo C%ROWTYPE;
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);


  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'AP_HOLDS_PKG.LOCK_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      debug_info := 'Close cursor C - ROW NOTFOUND';
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    debug_info := 'Close cursor C';
    CLOSE C;
    if (

               (Recinfo.invoice_id =  X_Invoice_Id)
           AND (   (Recinfo.line_location_id =  X_Line_Location_Id)
                OR (    (Recinfo.line_location_id IS NULL)
                    AND (X_Line_Location_Id IS NULL)))
           AND (Recinfo.hold_lookup_code =  X_Hold_Lookup_Code)
           AND (Recinfo.held_by =  X_Held_By)
           AND (trunc(Recinfo.hold_date) =  trunc(X_Hold_Date)) --Bug 2909797,6143486
           AND (   (Recinfo.hold_reason =  X_Hold_Reason)
                OR (    (Recinfo.hold_reason IS NULL)
                    AND (X_Hold_Reason IS NULL)))
           AND (   (Recinfo.release_lookup_code =  X_Release_Lookup_Code)
                OR (    (Recinfo.release_lookup_code IS NULL)
                    AND (X_Release_Lookup_Code IS NULL)))
           AND (   (Recinfo.release_reason =  X_Release_Reason)
                OR (    (Recinfo.release_reason IS NULL)
                    AND (X_Release_Reason IS NULL)))
           AND (   (Recinfo.status_flag =  X_Status_Flag)
                OR (    (Recinfo.status_flag IS NULL)
                    AND (X_Status_Flag IS NULL)))
           AND (   (Recinfo.Responsibility_Id =  X_Responsibility_Id)
                OR (    (Recinfo.Responsibility_Id IS NULL)
                    AND (X_Responsibility_Id IS NULL)))
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 =  X_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 =  X_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 =  X_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 =  X_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 =  X_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
           AND (   (Recinfo.attribute_category =  X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
           AND (   (Recinfo.org_id =  X_Org_Id)
                OR (    (Recinfo.org_id IS NULL)
                    AND (X_Org_Id IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

    EXCEPTION
      WHEN OTHERS THEN
         IF (SQLCODE <> -20001) THEN
           IF (SQLCODE = -54) THEN
             FND_MESSAGE.SET_NAME('SQLAP','AP_RESOURCE_BUSY');
           ELSE
             FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
             FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
             FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
             FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || X_Rowid ||
                       			', INVOICE_ID == ' || TO_CHAR(X_Invoice_Id) ||
                       			', LINE_LOCATION_ID = ' || TO_CHAR(X_Line_Location_Id) ||
                       			', HOLD_LOOKUP_CODE = ' || X_Hold_Lookup_Code);
             FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
	 END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

  END Lock_Row;


/*    */
  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Invoice_Id                     NUMBER,
                       X_Line_Location_Id               NUMBER,
                       X_Hold_Lookup_Code               VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Held_By                        NUMBER,
                       X_Hold_Date                      DATE,
                       X_Hold_Reason                    VARCHAR2,
                       X_Release_Lookup_Code            VARCHAR2,
                       X_Release_Reason                 VARCHAR2,
                       X_Status_Flag                    VARCHAR2,
                       X_Last_Update_Login              NUMBER,
		       X_Responsibility_Id		NUMBER,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Wf_Status                      VARCHAR2,
		       X_calling_sequence	IN	VARCHAR2

  ) IS

    l_invoice_amount		AP_INVOICES_ALL.INVOICE_AMOUNT%TYPE;
    l_payment_status_flag       AP_INVOICES_ALL.PAYMENT_STATUS_FLAG%TYPE;
    l_invoice_type_lookup_code  AP_INVOICES_ALL.INVOICE_TYPE_LOOKUP_CODE%TYPE;
    l_tax_hold_codes		AP_ETAX_SERVICES_PKG.Rel_Hold_Codes_Type;
    l_approval_status           VARCHAR2(100);
    l_success			BOOLEAN := TRUE;
    l_error_code		VARCHAR2(4000);
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);
    l_old_wf_status             AP_HOLDS_ALL.WF_STATUS%TYPE ; -- Bug 8266290
    l_hold_id                   AP_HOLDS_ALL.HOLD_ID%TYPE   ; -- Bug 8266290
  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'AP_HOLDS_PKG.UPDATE_ROW<-' ||
                                 X_calling_sequence;

    -- Bug 8266290 : Start
    SELECT  wf_status,
            hold_id
    INTO    l_old_wf_status,
            l_hold_id
    FROM    ap_holds
    WHERE   rowid = X_Rowid ;

    IF l_old_wf_status = 'STARTED' and
       ( X_Wf_Status = 'STARTED' or X_Wf_Status = 'MANUALLYRELEASED' )  THEN
        AP_WORKFLOW_PKG.abort_holds_workflow( l_hold_id ) ;
    END IF ;
    -- Bug 8266290 : End

    debug_info := 'Update AP_HOLDS';
    UPDATE AP_HOLDS
    SET
       invoice_id                      =     X_Invoice_Id,
       line_location_id                =     X_Line_Location_Id,
       hold_lookup_code                =     X_Hold_Lookup_Code,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       held_by                         =     X_Held_By,
       hold_date                       =     X_Hold_Date,
       hold_reason                     =     X_Hold_Reason,
       release_lookup_code             =     X_Release_Lookup_Code,
       release_reason                  =     X_Release_Reason,
       status_flag                     =     X_Status_Flag,
       last_update_login               =     X_Last_Update_Login,
       Responsibility_Id	       =     X_Responsibility_Id,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9,
       attribute10                     =     X_Attribute10,
       attribute11                     =     X_Attribute11,
       attribute12                     =     X_Attribute12,
       attribute13                     =     X_Attribute13,
       attribute14                     =     X_Attribute14,
       attribute15                     =     X_Attribute15,
       attribute_category              =     X_Attribute_Category,
       /* bug 5206670. Hold Workflow */
       wf_status                       =     Decode(X_Wf_Status, 'STARTED', 'MANUALLYRELEASED',
                                                    X_WF_Status)
    WHERE rowid = X_Rowid;

    --Bug 4539462 DBI logging
    AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_HOLDS',
               p_operation => 'U',
               p_key_value1 => X_invoice_id,
                p_calling_sequence => current_calling_sequence);

    --ETAX: Invwkb
    --All the code below this comment is added for ETAX.
    --Initialize the PL/SQL table
    FOR num in 1..10 LOOP
     l_tax_hold_codes(num) := NULL;
    END LOOP;


    --Unlike the code in quick_release we need to call this below api ,
    --regardless of whether the invoice status
    --after releasing this hold would go to 'APPROVED'or not, since this procedure
    --is called record by record, there is no way to figure it whether the user is
    --updating all the holds on the invoice, there by making the status 'APPROVED' or
    --just releasing this particular hold.
    IF (x_release_lookup_code IN ('TAX AMOUNT RANGE','TAX VARIANCE')) THEN

       l_tax_hold_codes(1) := x_release_lookup_code;

       l_success := ap_etax_services_pkg.release_tax_holds(
		                        p_invoice_id => x_invoice_id,
				        p_calling_mode => 'RELEASE TAX HOLDS',
				        p_tax_hold_code => l_tax_hold_codes,
				        p_all_error_messages => 'N',
				        p_error_code => l_error_code,
				        p_calling_sequence => current_calling_sequence);

       IF (NOT l_success) THEN
         FND_MESSAGE.SET_NAME('SQLAP','AP_ETX_CANNOT_REL_TAX_HOLDS');
         FND_MESSAGE.SET_TOKEN('REASON',l_error_code);
	 APP_EXCEPTION.RAISE_EXCEPTION;
       END IF;

    END IF;

    SELECT invoice_amount,
           payment_status_flag,
	   invoice_type_lookup_code
    INTO l_invoice_amount,
         l_payment_status_flag,
         l_invoice_type_lookup_code
    FROM ap_invoices
    WHERE invoice_id = x_invoice_id;

    l_approval_status := ap_invoices_pkg.get_approval_status(x_invoice_id,
                         		                     l_invoice_amount,
                                                             l_payment_status_flag,
                                                             l_invoice_type_lookup_code);

    IF (l_approval_status IN ('APPROVED','AVAILABLE','UNPAID','FULL'))THEN
      IF (l_success) THEN

          l_success := ap_etax_pkg.calling_etax(
	                             p_invoice_id => x_invoice_id,
	                             p_calling_mode => 'FREEZE INVOICE',
	                             p_all_error_messages => 'N',
	                             p_error_code => l_error_code,
	                             p_calling_sequence => current_calling_sequence);

	  IF (not l_success) THEN

             FND_MESSAGE.SET_NAME('SQLAP','AP_ETX_CANNOT_FRZ_INV');
             FND_MESSAGE.SET_TOKEN('REASON',l_error_code);
             APP_EXCEPTION.RAISE_EXCEPTION;

          END IF;

      END IF;
    END IF;


    --bugfix:4913913 commented out the code
    /*
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if; */

    EXCEPTION
        WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || X_Rowid ||
                       			', INVOICE_ID == ' || TO_CHAR(X_Invoice_Id) ||
                       			', LINE_LOCATION_ID = ' || TO_CHAR(X_Line_Location_Id) ||
                       			', HOLD_LOOKUP_CODE = ' || X_Hold_Lookup_Code);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Update_Row;


/*   */
  PROCEDURE Delete_Row(X_Rowid 				VARCHAR2,
		       X_calling_sequence	IN	VARCHAR2) IS

  current_calling_sequence    VARCHAR2(2000);
  debug_info                  VARCHAR2(100);
  l_invoice_id		      NUMBER;

  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'AP_HOLDS_PKG.DELETE_ROW<-' ||
                                 X_calling_sequence;

    --Bug 4539462 Need the invoice_id
    Select invoice_id
    Into l_invoice_id
    From ap_holds
    Where rowid = X_Rowid;

    debug_info := 'Delete from AP_HOLDS';
    DELETE FROM AP_HOLDS
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    --Bug 4539462 DBI logging
    AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_HOLDS',
               p_operation => 'D',
               p_key_value1 => l_invoice_id,
                p_calling_sequence => current_calling_sequence);

    EXCEPTION
        WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || X_Rowid);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Delete_Row;

  -----------------------------------------------------------------------
  -- PROCEDURE insert_single_hold inserts a single record into
  -- the AP_HOLDS table given a record in ap_invoices.
  -----------------------------------------------------------------------
  PROCEDURE insert_single_hold  (X_invoice_id         IN number,
                                 X_hold_lookup_code   IN varchar2,
                                 X_hold_type IN varchar2 DEFAULT NULL,
                                 X_hold_reason IN varchar2 DEFAULT NULL,
                                 X_held_by IN number DEFAULT NULL,
                                 X_calling_sequence IN varchar2 DEFAULT NULL)
  IS
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);
    l_hold_reason 	     ap_holds.hold_reason%TYPE; --bug 1188566

    cursor hold_cursor is
      select description
      from   ap_hold_codes
      where  hold_type = nvl(X_hold_type,hold_type)
      and    hold_lookup_code = X_hold_lookup_code;

      l_api_name varchar2(50);
      l_hold_id  ap_holds_all.hold_id%type;

  BEGIN

    -- Update the calling sequence
    --
    current_calling_sequence :=
              'AP_HOLDS_PKG.insert_single_hold<-'||
                     X_calling_sequence;
    l_api_name := 'Insert_Single_Hold';

    -- If no hold_code was passed to the procedure, abort the call
    if (X_hold_lookup_code is null) then
      return;
    end if;

    -- If a hold reason was passed to the function, then we do not
    -- need to get a description from AP_HOLD_CODES.  We don't want
    -- to override the user-entered description

    if (X_hold_reason is null) then
      debug_info := 'Select from AP_HOLD_CODES';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,debug_info);
      END IF;

      open hold_cursor;
      fetch hold_cursor into l_hold_reason;
      close hold_cursor;

      debug_info := 'l_hold_reason is '||l_hold_reason;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,debug_info);
      END IF;

    else
      l_hold_reason := X_hold_reason;
    end if;

    debug_info := 'Insert into AP_HOLDS';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,debug_info);
    END IF;

    --bugfix:5523240
    SELECT ap_holds_s.nextval
    INTO   l_hold_id
    FROM   DUAL;

    INSERT INTO AP_HOLDS
         (INVOICE_ID, HOLD_LOOKUP_CODE, HOLD_DATE,
          CREATED_BY, CREATION_DATE, LAST_UPDATE_LOGIN,
          LAST_UPDATE_DATE, LAST_UPDATED_BY,
          HELD_BY, HOLD_REASON, ORG_ID, HOLD_ID)
    SELECT
          X_invoice_id, X_hold_lookup_code, SYSDATE,
          FND_GLOBAL.user_id, -- 7299826
          SYSDATE,
          FND_GLOBAL.LOGIN_ID, -- 7299826
          SYSDATE,
          FND_GLOBAL.user_id, -- 7299826
          nvl(X_held_by,FND_GLOBAL.user_id), -- 7299826
          l_hold_reason,
          ORG_ID,L_HOLD_ID
    FROM  ap_invoices
    WHERE invoice_id = X_invoice_id
    AND   not exists
      (SELECT 'Already on this hold'
       FROM   ap_holds
        WHERE  invoice_id = X_invoice_id
          AND    hold_lookup_code = X_hold_lookup_code
          AND    release_lookup_code IS NULL);

    --Bug 4539462 DBI logging
    AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_HOLDS',
               p_operation => 'I',
               p_key_value1 => X_invoice_id,
                p_calling_sequence => current_calling_sequence);

        EXCEPTION
          WHEN OTHERS THEN
            IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                        current_calling_sequence);

              FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'X_invoice_id  = '      ||X_invoice_id
              ||', X_hold_lookup_code = '||X_hold_lookup_code
              ||', X_hold_type = '       ||X_hold_type
              ||', X_hold_reason = '     ||X_hold_reason
              ||', X_held_by = '         ||X_held_by
                                       );

              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
            END IF;
          APP_EXCEPTION.RAISE_EXCEPTION;

  END insert_single_hold;

  -----------------------------------------------------------------------
  -- PROCEDURE release_single_hold releases a hold by updating a single
  -- record in AP_HOLDS with a release_lookup_code
  -----------------------------------------------------------------------
  PROCEDURE release_single_hold (X_invoice_id          IN number,
                                 X_hold_lookup_code    IN varchar2,
                                 X_release_lookup_code IN varchar2,
                                 X_held_by IN number DEFAULT NULL,
                                 X_calling_sequence IN varchar2 DEFAULT NULL)
  IS
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);
    l_hold_reason        ap_hold_codes.description%TYPE;
    l_last_updated_by       ap_invoices.last_updated_by%TYPE;
    l_last_update_login       ap_invoices.last_update_login%TYPE;

    cursor invoice_who_cursor is
      select last_updated_by,
       last_update_login
      from   ap_invoices
      where  invoice_id = X_invoice_id;

  BEGIN

    -- Update the calling sequence
    --
    current_calling_sequence :=
              'AP_HOLDS_PKG.release_single_hold<-'||
                     X_calling_sequence;

    debug_info := 'Select from AP_INVOICES';

    open invoice_who_cursor;
    fetch invoice_who_cursor into l_last_updated_by, l_last_update_login;
    close invoice_who_cursor;

    debug_info := 'Update AP_HOLDS';

    UPDATE ap_holds
       SET release_lookup_code = X_release_lookup_code,
           release_reason = (SELECT description
                               FROM ap_lookup_codes
                              WHERE lookup_type = 'HOLD CODE'
                                AND lookup_code = X_release_lookup_code),
           last_updated_by = FND_GLOBAL.user_id, -- 7299826
           last_update_date = SYSDATE,
           last_update_login = FND_GLOBAL.login_id -- 7299826
     WHERE invoice_id = X_invoice_id
       AND held_by = nvl(X_held_by,held_by) -- 7299826
       AND release_lookup_code IS NULL
       AND hold_lookup_code = X_hold_lookup_code;

     --Bug 4539462 DBI logging
     AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_HOLDS',
               p_operation => 'U',
               p_key_value1 => X_invoice_id,
                p_calling_sequence => current_calling_sequence);

        EXCEPTION
          WHEN OTHERS THEN
            IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                        current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'X_invoice_id = '        ||X_invoice_id
              ||', X_hold_lookup_code = '  ||X_hold_lookup_code
              ||', X_release_lookup_code= '||X_release_lookup_code
              ||', X_held_by = '           ||X_held_by
                                       );
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
            END IF;
          APP_EXCEPTION.RAISE_EXCEPTION;

  END release_single_hold;


  -----------------------------------------------------------------------
  -- PROCEDURE quick_release release either ALL holds or one specificated
  -- hold for each one invoice.
  -- This procedure is called by Action window from APXINWKB
  -----------------------------------------------------------------------
  PROCEDURE quick_release (X_invoice_id    IN  NUMBER,
         X_hold_lookup_code  IN  VARCHAR2,
         X_release_lookup_code IN  VARCHAR2,
         X_release_reason  IN  VARCHAR2,
         X_responsibility_id  IN  NUMBER,
         X_last_updated_by  IN  NUMBER,
         X_last_update_date  IN  DATE,
         X_holds_count  IN OUT NOCOPY  NUMBER,
         X_approval_status_lookup_code IN OUT NOCOPY  VARCHAR2,
         X_calling_sequence   IN  VARCHAR2)
  IS
    l_success         BOOLEAN := TRUE;
    l_error_code      VARCHAR2(4000);
    l_tax_hold_codes  AP_ETAX_SERVICES_PKG.Rel_Hold_Codes_Type;
    num         BINARY_INTEGER := 1;
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

    cursor l_invoice_status_cursor is
      select ap_invoices_pkg.get_holds_count(invoice_id),
             ap_invoices_pkg.get_approval_status(
                                 invoice_id,
                                 invoice_amount,
                                 payment_status_flag,
                                 invoice_type_lookup_code)
      from   ap_invoices
      where  invoice_id = X_invoice_id;

    cursor tax_holds_cursor is
      select hold_lookup_code
      from ap_holds
      where invoice_id = x_invoice_id
      and hold_lookup_code IN ('TAX AMOUNT RANGE','TAX VARIANCE')
      and release_lookup_code IS NULL;

  BEGIN

    -- Update the calling sequence
    --
    current_calling_sequence :=
              'AP_HOLDS_PKG.quick_release<-'||
                     X_calling_sequence;

    FOR num IN 1..10 LOOP
       l_tax_hold_codes(num) := NULL;
    END LOOP;

    ------------------------------------------------------------------------
    -- Update final_match_flag to 'N' if try to release 'CANT CLOSE PO' hold
    ------------------------------------------------------------------------
    debug_info := 'Update AP_INVOICE_DISTRIBUTIONS';

    UPDATE ap_invoice_distributions D
    SET    final_match_flag = 'N'
    WHERE  D.invoice_id = X_invoice_id
    AND     ((X_hold_lookup_code = 'CANT CLOSE PO') OR
         ((X_hold_lookup_code = 'ALL')
             AND EXISTS(SELECT 'X'
        FROM AP_HOLDS H
       WHERE H.invoice_id = X_invoice_id
         AND H.hold_lookup_code = 'CANT CLOSE PO'
         AND H.release_lookup_code IS NULL)));

    OPEN tax_holds_cursor;
    LOOP
      FETCH tax_holds_cursor into l_tax_hold_codes(num);
      EXIT when tax_holds_cursor%notfound;
      num := num+1;
    END LOOP;
    CLOSE tax_holds_cursor;


    -- Bug 8266290 : Start
    FOR c_wf_status IN ( SELECT   hold_id
                         FROM     ap_holds H
                         WHERE    H.invoice_id = X_invoice_id
                         AND      X_hold_lookup_code IN (H.hold_lookup_code, 'ALL')
                         AND      H.hold_lookup_code not in ('DIST VARIANCE', 'NO RATE',
                                                             'CANT FUNDS CHECK', 'INSUFFICIENT FUNDS',
                                                             'FINAL MATCHING', 'FUTURE PERIOD', 'CANT TRY PO CLOSE',
                                                             'DIST ACCT INVALID', 'ERV ACCT INVALID', 'LIAB ACCT INVALID')
                         AND      H.release_lookup_code is null
                         AND      H.wf_status = 'STARTED'
                        )
    LOOP
        AP_WORKFLOW_PKG.abort_holds_workflow( c_wf_status.hold_id ) ;
    END LOOP ;
    -- Bug 8266290 : End

    ------------------------------------------------------------------------
    -- Release single hold if pass hold_lookup_code or all holds if pass 'ALL'
    -- in hold_lookup_code
    ------------------------------------------------------------------------
    debug_info := 'Update AP_HOLDS';

   UPDATE ap_holds H
      SET H.release_lookup_code = X_release_lookup_code,
        H.release_reason      = X_release_reason,
    H.responsibility_id  = X_responsibility_id,
          H.last_update_date    = X_last_update_date,
        H.last_updated_by     = X_last_updated_by
    WHERE H.invoice_id = X_invoice_id
      AND X_hold_lookup_code IN (H.hold_lookup_code, 'ALL')
      AND H.hold_lookup_code not in ('DIST VARIANCE', 'NO RATE',
                       'CANT FUNDS CHECK', 'INSUFFICIENT FUNDS',
                       'FINAL MATCHING', 'FUTURE PERIOD', 'CANT TRY PO CLOSE',
                       'DIST ACCT INVALID', 'ERV ACCT INVALID', 'LIAB ACCT INVALID')
      AND H.release_lookup_code is null;

    --Bug 4539462 DBI logging
    AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_HOLDS',
               p_operation => 'U',
               p_key_value1 => X_invoice_id,
                p_calling_sequence => current_calling_sequence);

    ------------------------------------------------------------------------
    -- Retrieve new invoice statuses
    ------------------------------------------------------------------------
    debug_info := 'Retrieving new invoice statuses';

    open l_invoice_status_cursor;
    fetch l_invoice_status_cursor into
    X_holds_count,
    X_approval_status_lookup_code;
    close l_invoice_status_cursor;

    --ETAX: Invwkb
    --If the invoice goes to 'APPROVED' status outside the context of 'Invoice validation'
    --process then we need to update ETAX with the same status, and also if we released
    --TAX holds , we need to update ETAX of the same so that tax holds are released on
    --detail tax lines in ETAX repository.
    IF (x_approval_status_lookup_code IN ('APPROVED','AVAILABLE','FULL','UNPAID')) THEN

  IF(l_tax_hold_codes.COUNT <> 0) THEN

            l_success := ap_etax_services_pkg.release_tax_holds(
                         p_invoice_id => x_invoice_id,
             p_calling_mode => 'RELEASE TAX HOLDS',
             p_tax_hold_code => l_tax_hold_codes,
             p_all_error_messages => 'N',
             p_error_code => l_error_code,
             p_calling_sequence => current_calling_sequence);

            IF (not l_success) THEN
               FND_MESSAGE.SET_NAME('SQLAP','AP_ETX_CANNOT_REL_TAX_HOLDS');
         FND_MESSAGE.SET_TOKEN('REASON',l_error_code);
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

        END IF;

        IF (l_success) THEN

           l_success := ap_etax_pkg.calling_etax(
              p_invoice_id => x_invoice_id,
        p_calling_mode => 'FREEZE INVOICE',
        p_all_error_messages => 'N',
        p_error_code => l_error_code,
        p_calling_sequence => current_calling_sequence);

           IF (not l_success) THEN

              FND_MESSAGE.SET_NAME('SQLAP','AP_ETX_CANNOT_FRZ_INV');
        FND_MESSAGE.SET_TOKEN('REASON',l_error_code);
        APP_EXCEPTION.RAISE_EXCEPTION;

           END IF;

        END IF;

    END IF; /* x_approval_status_ IN ... */

    ------------------------------------------------------------------------
    -- Commit changes to database
    ------------------------------------------------------------------------
    debug_info := 'Commit changes';

    COMMIT;

   EXCEPTION
          WHEN OTHERS THEN
            IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                        current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'X_invoice_id = '        ||TO_CHAR(X_invoice_id)
              ||', X_hold_lookup_code = '  ||X_hold_lookup_code
              ||', X_release_lookup_code= '||X_release_lookup_code
              ||', X_release_reason= '||X_release_reason
              ||', X_responsibility_id= '||TO_CHAR(X_responsibility_id)
              ||', X_last_updated_by= '||TO_CHAR(X_last_updated_by)
              ||', X_last_update_date= '||TO_CHAR(X_last_update_date)
              ||', X_holds_count= '||TO_CHAR(X_holds_count)
              ||', X_approval_status_lookup_code= '||
                           X_approval_status_lookup_code
);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
            END IF;
          APP_EXCEPTION.RAISE_EXCEPTION;

  END quick_release;








END AP_HOLDS_PKG;


/
