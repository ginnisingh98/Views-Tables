--------------------------------------------------------
--  DDL for Package Body JL_INTERFACE_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_INTERFACE_VAL" AS
/* $Header: jgjlgdfb.pls 120.13 2006/03/31 20:30:34 amohiudd ship $ */

--PG_DEBUG varchar2(1) :=  NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
-- Bugfix# 3259701
--PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE ap_business_rules
     (p_calling_program_name            IN    VARCHAR2,
      p_set_of_books_id                 IN    NUMBER,
      p_invoice_date                    IN    DATE,
      p_parent_table                    IN    VARCHAR2,
      p_parent_id                       IN    NUMBER,
      p_default_last_updated_by         IN    NUMBER,
      p_default_last_update_login       IN    NUMBER,
      p_line_type_lookup_code           IN    VARCHAR2,
      p_global_attribute_category       IN    VARCHAR2,
      p_global_attribute1               IN    VARCHAR2,
      p_global_attribute2               IN    VARCHAR2,
      p_global_attribute3               IN    VARCHAR2,
      p_global_attribute4               IN    VARCHAR2,
      p_global_attribute5               IN    VARCHAR2,
      p_global_attribute6               IN    VARCHAR2,
      p_global_attribute7               IN    VARCHAR2,
      p_global_attribute8               IN    VARCHAR2,
      p_global_attribute9               IN    VARCHAR2,
      p_global_attribute10              IN    VARCHAR2,
      p_global_attribute11              IN    VARCHAR2,
      p_global_attribute12              IN    VARCHAR2,
      p_global_attribute13              IN    VARCHAR2,
      p_global_attribute14              IN    VARCHAR2,
      p_global_attribute15              IN    VARCHAR2,
      p_global_attribute16              IN    VARCHAR2,
      p_global_attribute17              IN    VARCHAR2,
      p_global_attribute18              IN    VARCHAR2,
      p_global_attribute19              IN    VARCHAR2,
      p_global_attribute20              IN    VARCHAR2,
      p_current_invoice_status          OUT NOCOPY   VARCHAR2,
      p_calling_sequence          IN  VARCHAR2) IS

     l_credit_exists VARCHAR2(1);
     l_current_invoice_status VARCHAR2(1); -- := 'Y';

     l_debug_loc                     VARCHAR2(30); -- := 'check_ap_business_rules';
     l_curr_calling_sequence         VARCHAR2(2000);
     l_debug_info                    VARCHAR2(100);
     l_country_code                  VARCHAR2(10);

     l_ou_id                         NUMBER;

  BEGIN
    l_current_invoice_status := 'Y';
    l_debug_loc              := 'check_ap_business_rules';
  -------------------------- DEBUG INFORMATION ------------------------------
  l_curr_calling_sequence := 'jl_interface_val.'||l_debug_loc||'<-'||p_calling_sequence;
  l_debug_info := 'ap business rules';
  ---------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  --                         Global Flexfield Validation

  ------------------------------------------------------------------------------
  --  You can add your own validation code for your global flexfields.

  --  You should not include arguments(GLOBAL_ATTRIBUTE(n)) you do not validate
  --  in your procedure.

  --  Form Name: APXIISIM
 ------------------------------------------------------------------------------
  --   Header Level Validation - Block Name: INVOICES_FOLDER

  ------------------------------------------------------------------------------
  --    1-27.JL.AR.APXIISIM.INVOICES_FOLDER
  --    1-27a.JL.CO.APXIISIM.INVOICES_FOLDER -- Bug 3233307
  --    1-28.JL.BR.APXIISIM.INVOICES_FOLDER
  --    1-29.JL.CL.APXIISIM.INVOICES_FOLDER
  ------------------------------------------------------------------------------
  --   Line Level Validation   - Block Name: INVOICE_LINES_FOLDER

  ------------------------------------------------------------------------------
  --    2-5. JL.AR.APXIISIM.LINES_FOLDER
  --    2-6. JL.CO.APXIIFIX.LINES_FOLDER
  --    2-7. JL.BR.APXIISIM.LINES_FOLDER

  ------------------------------------------------------------------------------

  IF (p_global_attribute_category = 'JL.AR.APXIISIM.INVOICES_FOLDER') THEN

   jl_ar_apxiisim_invoices_folder
     (p_parent_id ,
      p_default_last_updated_by,
      p_default_last_update_login,
      p_global_attribute1,
      p_global_attribute2,
      p_global_attribute3,
      p_global_attribute4,
      p_global_attribute5,
      p_global_attribute6,
      p_global_attribute7,
      p_global_attribute8,
      p_global_attribute9,
      p_global_attribute10,
      p_global_attribute11,
      p_global_attribute12,
      p_global_attribute13,
      p_global_attribute14,
      p_global_attribute15,
      p_global_attribute16,
      p_global_attribute17,
      p_global_attribute18,
      p_global_attribute19,
      p_global_attribute20,
      l_current_invoice_status,
      p_calling_sequence);

 ELSIF (p_global_attribute_category ='JL.AR.APXIISIM.LINES_FOLDER') THEN
   jl_ar_apxiisim_lines_folder
     (p_parent_id,
      p_default_last_updated_by,
      p_default_last_update_login,
      p_global_attribute1,
      p_global_attribute2,
      p_global_attribute3,
      p_global_attribute4,
      p_global_attribute5,
      p_global_attribute6,
      p_global_attribute7,
      p_global_attribute8,
      p_global_attribute9,
      p_global_attribute10,
      p_global_attribute11,
      p_global_attribute12,
      p_global_attribute13,
      p_global_attribute14,
      p_global_attribute15,
      p_global_attribute16,
      p_global_attribute17,
      p_global_attribute18,
      p_global_attribute19,
      p_global_attribute20,
      l_current_invoice_status,
      p_calling_sequence);

 -- Bug 3233307 JL.CO.APXIISIM.INVOICES_FOLDER
  ELSIF (p_global_attribute_category = 'JL.CO.APXIISIM.INVOICES_FOLDER') THEN

   jl_co_apxiisim_invoices_folder
     (p_parent_id ,
      p_default_last_updated_by,
      p_default_last_update_login,
      p_global_attribute1,
      p_global_attribute2,
      p_global_attribute3,
      p_global_attribute4,
      p_global_attribute5,
      p_global_attribute6,
      p_global_attribute7,
      p_global_attribute8,
      p_global_attribute9,
      p_global_attribute10,
      p_global_attribute11,
      p_global_attribute12,
      p_global_attribute13,
      p_global_attribute14,
      p_global_attribute15,
      p_global_attribute16,
      p_global_attribute17,
      p_global_attribute18,
      p_global_attribute19,
      p_global_attribute20,
      l_current_invoice_status,
      p_calling_sequence);

  --
  --    2-5. JL.CO.APXIISIM.LINES_FOLDER
  --

 ELSIF (p_global_attribute_category ='JL.CO.APXIISIM.LINES_FOLDER') THEN

    jl_co_apxiisim_lines_folder
     (p_parent_id,
      p_default_last_updated_by,
      p_default_last_update_login,
      p_global_attribute1,
      p_global_attribute2,
      p_global_attribute3,
      p_global_attribute4,
      p_global_attribute5,
      p_global_attribute6,
      p_global_attribute7,
      p_global_attribute8,
      p_global_attribute9,
      p_global_attribute10,
      p_global_attribute11,
      p_global_attribute12,
      p_global_attribute13,
      p_global_attribute14,
      p_global_attribute15,
      p_global_attribute16,
      p_global_attribute17,
      p_global_attribute18,
      p_global_attribute19,
      p_global_attribute20,
      l_current_invoice_status,
      p_calling_sequence);

  --
  --   1-28. JL.BR.APXIISIM.INVOICES_FOLDER
  --

  ELSIF (p_global_attribute_category = 'JL.BR.APXIISIM.INVOICES_FOLDER') THEN

   jl_br_apxiisim_invoices_folder
     (p_parent_id ,
      p_default_last_updated_by,
      p_default_last_update_login,
      p_global_attribute1,
      p_global_attribute2,
      p_global_attribute3,
      p_global_attribute4,
      p_global_attribute5,
      p_global_attribute6,
      p_global_attribute7,
      p_global_attribute8,
      p_global_attribute9,
      p_global_attribute10,
      p_global_attribute11,
      p_global_attribute12,
      p_global_attribute13,
      p_global_attribute14,
      p_global_attribute15,
      p_global_attribute16,
      p_global_attribute17,
      p_global_attribute18,
      p_global_attribute19,
      p_global_attribute20,
      l_current_invoice_status,
      p_calling_sequence);

  --
  --    2-7. JL.BR.APXIISIM.LINES_FOLDER
  --

  ELSIF (p_global_attribute_category = 'JL.BR.APXIISIM.LINES_FOLDER') THEN

   jl_br_apxiisim_lines_folder
     (p_parent_id ,
      p_line_type_lookup_code,
      p_default_last_updated_by,
      p_default_last_update_login,
      p_global_attribute1,
      p_global_attribute2,
      p_global_attribute3,
      p_global_attribute4,
      p_global_attribute5,
      p_global_attribute6,
      p_global_attribute7,
      p_global_attribute8,
      p_global_attribute9,
      p_global_attribute10,
      p_global_attribute11,
      p_global_attribute12,
      p_global_attribute13,
      p_global_attribute14,
      p_global_attribute15,
      p_global_attribute16,
      p_global_attribute17,
      p_global_attribute18,
      p_global_attribute19,
      p_global_attribute20,
      l_current_invoice_status,
      p_calling_sequence);

   -- togeorge 11/18/1999
   -- Bug# 1074309
   jl_br_apxiisim_val_cfo_code
   (p_parent_id ,
    p_line_type_lookup_code,
    p_default_last_updated_by,
    p_default_last_update_login,
    l_current_invoice_status,
    p_calling_sequence);


  --
  --   1-29. JL.CL.APXIISIM.INVOICES_FOLDER
  --

  ELSIF (p_global_attribute_category = 'JL.CL.APXIISIM.INVOICES_FOLDER') THEN

   jl_cl_apxiisim_invoices_folder
     (p_parent_id ,
      p_default_last_updated_by,
      p_default_last_update_login,
      p_global_attribute1,
      p_global_attribute2,
      p_global_attribute3,
      p_global_attribute4,
      p_global_attribute5,
      p_global_attribute6,
      p_global_attribute7,
      p_global_attribute8,
      p_global_attribute9,
      p_global_attribute10,
      p_global_attribute11,
      p_global_attribute12,
      p_global_attribute13,
      p_global_attribute14,
      p_global_attribute15,
      p_global_attribute16,
      p_global_attribute17,
      p_global_attribute18,
      p_global_attribute19,
      p_global_attribute20,
      l_current_invoice_status,
      p_calling_sequence);

  END IF;

  p_current_invoice_status := l_current_invoice_status;

  /***************************************************************
  -- Call to check for multiple balancing segments
   ***************************************************************/
  ------------------------
  -- Get the Country Code
  ------------------------
  --Bug 2354736
  --fnd_profile.get('ORG_ID',l_ou_id);
  --Bug 4499004
  --commented out above line and getting org id from fnd concurrents
    SELECT org_id into l_ou_id FROM fnd_concurrent_requests
    WHERE request_id = fnd_global.conc_request_id ;

    fnd_request.set_org_id(l_ou_id);
  l_country_code := jg_zz_shared_pkg.get_country(l_ou_id, NULL,null);

  -------------------------------------------------------
  -- Execute the Colombia  Balancing Segament Validation
  -------------------------------------------------------
  IF (l_country_code = 'CO') THEN

     Declare
        invo_id number;
        l_liability_post_lookup_code AP_SYSTEM_PARAMETERS.liability_post_lookup_code%TYPE;
        validate_error   varchar2(200);
        l_cursor         NUMBER;
        l_sqlstmt        VARCHAR2(1000);
        l_ignore         NUMBER;
     Begin
        SELECT invoice_id
          INTO invo_id
          FROM ap_invoice_lines_interface
         WHERE invoice_line_id = P_parent_id;

        ----------------------------------------------------------------------------------------
        -- Get Set of Books and Auto-offsets Option info
        ----------------------------------------------------------------------------------------

        SELECT nvl(liability_post_lookup_code, 'NONE')
        INTO   l_liability_post_lookup_code
        FROM   ap_system_parameters;


        IF (l_Liability_Post_Lookup_Code = 'BALANCING_SEGMENT') AND
           (Ap_Extended_Withholding_Pkg.Ap_Extended_Withholding_Active)  THEN

           Begin
              ------------------------------------------
              -- Dynamic Call
              ------------------------------------------
              -- Create the SQL statement
              l_cursor := dbms_sql.open_cursor;
              l_sqlstmt := 'BEGIN :validate_error := ' ||
                           'JL_ZZ_AP_WITHHOLDING_PKG.Validate_Mult_BS_GateWay(:invo_id); END;';

              -- Parse the SQL statement
              dbms_sql.parse (l_cursor, l_sqlstmt, dbms_sql.native);

              -- Define the variables
              dbms_sql.bind_variable (l_cursor, 'validate_error', validate_error,200);
              dbms_sql.bind_variable (l_cursor, 'invo_id', invo_id);

              -- Execute the SQL statement
              l_ignore := dbms_sql.execute (l_cursor);

              -- Get the return value (success)
              dbms_sql.variable_value (l_cursor, 'validate_error', validate_error);

              -- Close the cursor
              dbms_sql.close_cursor (l_cursor);

           EXCEPTION
              WHEN others THEN
                 IF (dbms_sql.is_open(l_cursor)) THEN
                     dbms_sql.close_cursor(l_cursor);
                 END IF;
           End;
           -- Validate Mul BS by distribution lines.
           IF (validate_error = 'Error') THEN
               jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                             invo_id,
                            'MULTIPLE BAL SEG FOUND',
                             p_default_last_updated_by,
                             p_default_last_update_login,
                             p_calling_sequence);
                 p_current_invoice_status := 'N';
           END IF;
        END IF;
     Exception
        WHEN OTHERS THEN
             null;
     End; -- Pl Block
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', 'SQLERRM');
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
                        'Set Of Books Id = '||to_char(p_set_of_books_id)
                    ||', Parent Table = '||p_parent_table
                    ||', Parent Id = '||to_char(p_parent_id)
                    ||', Last Updated By = '||to_char(p_default_last_updated_by)
                    ||', Last Update Login = '||to_char(p_default_last_update_login)
                    ||', Line Type Lookup Code = '||p_line_type_lookup_code
                    ||', Global Attribute Category = '||p_global_attribute_category
                    ||', Global Attribute1 = '||p_global_attribute1
                    ||', Global Attribute2 = '||p_global_attribute2
                    ||', Global Attribute3 = '||p_global_attribute3
                    ||', Global Attribute4 = '||p_global_attribute4
                    ||', Global Attribute5 = '||p_global_attribute5
                    ||', Global Attribute6 = '||p_global_attribute6
                    ||', Global Attribute7 = '||p_global_attribute7
                    ||', Global Attribute8 = '||p_global_attribute8
                    ||', Global Attribute9 = '||p_global_attribute9
                    ||', Global Attribute10 = '||p_global_attribute10
                    ||', Global Attribute11 = '||p_global_attribute11
                    ||', Global Attribute12 = '||p_global_attribute12
                    ||', Global Attribute13 = '||p_global_attribute13
                    ||', Global Attribute14 = '||p_global_attribute14
                    ||', Global Attribute15 = '||p_global_attribute15
                    ||', Global Attribute16 = '||p_global_attribute16
                    ||', Global Attribute17 = '||p_global_attribute17
                    ||', Global Attribute18 = '||p_global_attribute18
                    ||', Global Attribute19 = '||p_global_attribute19
                    ||', Global Attribute20 = '||p_global_attribute20);

        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END ap_business_rules;

  -------------------------------------------------------------------------------
  --    Following segments are defined for Argentina Invoice Interface
  -------------------------------------------------------------------------------
  -- No. Name                Column             Value Set                  Req.
  -- --- ------------------- ------------------ -------------------------- ------
  --  1 Legal Transaction    GLOBAL_ATTRIBUTE11 JLAR_AP_LEGAL_TAX_CATEGORY   Yes
  --      Category
  --  2 Transaction letter   GLOBAL_ATTRIBUTE12  JLAR_DOCUMENT_LETTER        Yes
  --  3 Tax Authority        GlOBAL ATTRIBUTE13  JLAR_AP_DGI_CODE            Yes
  --    Transaction Type
  --  4 Customs Code         GLOBAL_ATTRIBUTE14  15 charcters                No
  --  5 Customs Issue Date   GLOBAL_ATTRIBUTE15  FND_STANDARD_DATE           No
  --  6 Customs Issue Number GLOBAL_ATTRIBUTE16  FND_NUMBER                  No
  --  7 Tax inclusive        GLOBAL_ATTRIBUTE17  AP_SRS_YES_NO_MAND          Yes
  --      with Note
  --------------------------------------------------------------------------------
  --
  -- This procedure validate the information in the GA 11,12,13,15,16,17
  -- in the invoice header for Argentina.
  --

  PROCEDURE jl_ar_apxiisim_invoices_folder
       (p_parent_id                 IN            NUMBER,
        p_default_last_updated_by   IN            NUMBER,
        p_default_last_update_login IN            NUMBER,
        p_global_attribute1         IN            VARCHAR2,
        p_global_attribute2         IN            VARCHAR2,
        p_global_attribute3         IN            VARCHAR2,
        p_global_attribute4         IN            VARCHAR2,
        p_global_attribute5         IN            VARCHAR2,
        p_global_attribute6         IN            VARCHAR2,
        p_global_attribute7         IN            VARCHAR2,
        p_global_attribute8         IN            VARCHAR2,
        p_global_attribute9         IN            VARCHAR2,
        p_global_attribute10        IN            VARCHAR2,
        p_global_attribute11        IN            VARCHAR2,
        p_global_attribute12        IN            VARCHAR2,
        p_global_attribute13        IN            VARCHAR2,
        p_global_attribute14        IN            VARCHAR2,
        p_global_attribute15        IN            VARCHAR2,
        p_global_attribute16        IN            VARCHAR2,
        p_global_attribute17        IN            VARCHAR2,
        p_global_attribute18        IN            VARCHAR2,
        p_global_attribute19        IN            VARCHAR2,
        p_global_attribute20        IN            VARCHAR2,
        p_current_invoice_status       OUT NOCOPY VARCHAR2,
        p_calling_sequence          IN            VARCHAR2) IS

    value_exists   VARCHAR2(1);
    Length_Date    Number;
    -- Bug 2729151
    l_global_attribute15 VARCHAR2(15);

  BEGIN

    -- Validation for Legal Transaction Category

    IF (p_global_attribute11 IS NOT NULL) THEN
      BEGIN
        SELECT 'X'
        INTO value_exists
        FROM fnd_lookups
        WHERE  lookup_type =  'JLAR_LEGAL_TRX_CATEGORY'
        AND  lookup_code = p_global_attribute11
        AND  nvl(start_date_active,sysdate) <= sysdate
        AND  nvl(end_date_active,sysdate) >= sysdate
        AND  enabled_flag = 'Y';
      EXCEPTION
        WHEN OTHERS THEN
          jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                                     p_parent_id,
                                                     'INVALID_GLOBAL_ATTR11',
                                                     p_default_last_updated_by,
                                                     p_default_last_update_login,
                                                     p_calling_sequence);
          p_current_invoice_status := 'N';

      END;
    ELSE -- The Global Attribute11 is Required
      jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                                 p_parent_id,
                                                 'INVALID_GLOBAL_ATTR11',
                                                 p_default_last_updated_by,
                                                 p_default_last_update_login,
                                                 p_calling_sequence);
      p_current_invoice_status := 'N';

    END IF; -- p_global_attribute11 is not null

    -- Validation for Transaction Letter

    IF (p_global_attribute12 IS NOT NULL) THEN
      BEGIN
        SELECT  'X'
        INTO  value_exists
        FROM  fnd_lookups
        WHERE  lookup_type = 'JLAR_DOCUMENT_LETTER'
        AND  lookup_code = p_global_attribute12
        AND  nvl(start_date_active,sysdate) <= sysdate
        AND  nvl(end_date_active,sysdate) >= sysdate
        AND  enabled_flag = 'Y' ;
      EXCEPTION
        WHEN OTHERS THEN
          jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                                     p_parent_id,
                                                     'INVALID_GLOBAL_ATTR12',
                                                     p_default_last_updated_by,
                                                     p_default_last_update_login,
                                                     p_calling_sequence);
          p_current_invoice_status := 'N';

      END;
    ELSE -- The Global Attribute12 is Required
      jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                                   p_parent_id,
                                                   'INVALID_GLOBAL_ATTR12',
                                                   p_default_last_updated_by,
                                                   p_default_last_update_login,
                                                   p_calling_sequence);
      p_current_invoice_status := 'N';

    END IF; -- p_global_attribute12 is not null

    -- Tax Authority Transaction Type
    IF (p_global_attribute13 IS NOT NULL) THEN   -- Tax Authority Transaction Type
      BEGIN
        SELECT 'X'
        INTO value_exists
        FROM jl_ar_ap_trx_dgi_codes
        WHERE trx_category =  p_global_attribute11
        and trx_letter = p_global_attribute12;
      EXCEPTION
        WHEN OTHERS THEN
          jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                                       p_parent_id,
                                                       'INVALID_GLOBAL_ATTR13',
                                                       p_default_last_updated_by,
                                                       p_default_last_update_login,
                                                       p_calling_sequence);

          p_current_invoice_status := 'N';
      END;
    ELSE -- The Global Attribute13 is Required
      jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                                   p_parent_id,
                                                   'INVALID_GLOBAL_ATTR13',
                                                   p_default_last_updated_by,
                                                   p_default_last_update_login,
                                                   p_calling_sequence);
      p_current_invoice_status := 'N';

    END IF; -- p_global_attribute13 is not null

    --********************************************************
    -- It doesn't have any validation for Customs Code p_global_attribute 14
    --
    --**********************************************************

    -- Customs Issue Date
    IF (p_global_attribute15 IS NOT NULL) THEN
      Length_Date := length (p_global_attribute15);

      --Bug 2729151
      l_global_attribute15 := to_char(fnd_date.canonical_to_date(p_global_attribute15));
      Length_Date := length (l_global_attribute15);

      IF (Length_Date = 9)  THEN
        IF NOT (jg_globe_flex_val_shared.Check_Format (l_global_attribute15,'D',9,'','','','','','')) THEN

          jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                    p_parent_id,
                                    'INVALID_GLOBAL_ATTR15',
                                    p_default_last_updated_by,
                                    p_default_last_update_login,
                                    p_calling_sequence);

          p_current_invoice_status := 'N';

        END IF; -- Check_Format 9
      ELSIF (Length_Date = 11)  THEN

        IF NOT(jg_globe_flex_val_shared.Check_Format (l_global_attribute15,'D', 11,'','','' ,'','','')) THEN

          jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                         p_parent_id,
                                        'INVALID_GLOBAL_ATTR15',
                                        p_default_last_updated_by,
                                        p_default_last_update_login,
                                        p_calling_sequence);

          p_current_invoice_status := 'N';

        END IF; -- Check_Format 11
      ELSE -- No Date Format.
        jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                  p_parent_id,
                                  'INVALID_GLOBAL_ATTR15',
                                  p_default_last_updated_by,
                                  p_default_last_update_login,
                                  p_calling_sequence);

        p_current_invoice_status := 'N';

      END IF; -- Check_Format 11
    END IF; -- Validate The Format Global Attribute15

    -- Customs Issue Number
    IF (p_global_attribute16 IS NOT NULL) THEN
      -- Bug 2729151
      -- Changed the 3rd paramter of check_format from '0' to '15'

      IF NOT(jg_globe_flex_val_shared.Check_Format (p_global_attribute16,'C',15,'','', '','','','')) THEN

        jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                p_parent_id,
                                'INVALID_GLOBAL_ATTR16',
                                p_default_last_updated_by,
                                p_default_last_update_login,
                                p_calling_sequence);
        p_current_invoice_status := 'N';

      END IF; -- Check_Format Number
    END IF; -- Validate Global Attribute 16

    -- Tax Inclusive with Note
    IF (p_global_attribute17 IS NOT NULL) THEN

      BEGIN
        SELECT 'X'
        INTO value_exists
        FROM fnd_lookups
        WHERE  lookup_type = 'YES_NO'
        AND  lookup_code = p_global_attribute17
        AND  nvl(start_date_active,sysdate) <= sysdate
        AND  nvl(end_date_active,sysdate) >= sysdate
        AND  enabled_flag = 'Y' ;
      EXCEPTION
        WHEN OTHERS THEN

          jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                 p_parent_id,
                                 'INVALID_GLOBAL_ATTR17',
                                 p_default_last_updated_by,
                                  p_default_last_update_login,
                                 p_calling_sequence);
          p_current_invoice_status := 'N';

      END;
    ELSE -- The Global Attribute17 is Required
      jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                 p_parent_id,
                                 'INVALID_GLOBAL_ATTR17',
                                 p_default_last_updated_by,
                                 p_default_last_update_login,
                                 p_calling_sequence);
      p_current_invoice_status := 'N';

    END IF; -- p_global_attribute17 is not null

    -- Validate the rest of the Global Attributes be NULL

    IF ((p_global_attribute1  IS NOT NULL) OR
        (p_global_attribute2  IS NOT NULL) OR
        (p_global_attribute3  IS NOT NULL) OR
        (p_global_attribute4  IS NOT NULL) OR
        (p_global_attribute5  IS NOT NULL) OR
        (p_global_attribute6  IS NOT NULL) OR
        (p_global_attribute7  IS NOT NULL) OR
        (p_global_attribute8  IS NOT NULL) OR
        (p_global_attribute9  IS NOT NULL) OR
        --(p_global_attribute10 IS NOT NULL) OR
        (p_global_attribute18 IS NOT NULL) --OR
        --(p_global_attribute19 IS NOT NULL) OR
        --(p_global_attribute20 IS NOT NULL)
       ) THEN
        jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                                   p_parent_id,
                                                   'GLOBAL_ATTR_VALUE_FOUND',
                                                   p_default_last_updated_by,
                                                   p_default_last_update_login,
                                                   p_calling_sequence);
        p_current_invoice_status := 'N';
    END IF;

    ----------------------------------------------------------------------------------------
    -- Call to check for multiple balancing segments
    -- Get Set of Books and Auto-offsets Option info
    ----------------------------------------------------------------------------------------
    Declare
      l_liability_post_lookup_code AP_SYSTEM_PARAMETERS.liability_post_lookup_code%TYPE;
      validate_error   varchar2(200);
      l_cursor         NUMBER;
      l_sqlstmt        VARCHAR2(1000);
      l_ignore         NUMBER;

    Begin
      SELECT nvl(liability_post_lookup_code, 'NONE')
      INTO   l_liability_post_lookup_code
      FROM   ap_system_parameters;

      IF (l_Liability_Post_Lookup_Code = 'BALANCING_SEGMENT') AND
         (Ap_Extended_Withholding_Pkg.Ap_Extended_Withholding_Active)  THEN

        Begin
          ------------------------------------------
          -- Dynamic Call
          ------------------------------------------
          -- Create the SQL statement
          l_cursor := dbms_sql.open_cursor;
          l_sqlstmt := 'BEGIN :validate_error := ' ||
                       'JL_ZZ_AP_WITHHOLDING_PKG.Validate_Mult_BS_GateWay(:p_parent_id); END;';

          -- Parse the SQL statement
          dbms_sql.parse (l_cursor, l_sqlstmt, dbms_sql.native);

          -- Define the variables
          dbms_sql.bind_variable (l_cursor, 'validate_error', validate_error,200);
          dbms_sql.bind_variable (l_cursor, 'p_parent_id', p_parent_id);

          -- Execute the SQL statement
          l_ignore := dbms_sql.execute (l_cursor);

          -- Get the return value (success)
          dbms_sql.variable_value (l_cursor, 'validate_error', validate_error);

          -- Close the cursor
          dbms_sql.close_cursor (l_cursor);

        EXCEPTION
          WHEN others THEN
            IF (dbms_sql.is_open(l_cursor)) THEN
              dbms_sql.close_cursor(l_cursor);
            END IF;
        End;
           -- Validate Mul BS by distribution lines.
        IF (validate_error = 'Error') THEN
          jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                          p_parent_id,
                          'MULTIPLE BAL SEG FOUND',
                          p_default_last_updated_by,
                          p_default_last_update_login,
                          p_calling_sequence);
          p_current_invoice_status := 'N';
        END IF;
      END IF;
    Exception
      WHEN OTHERS THEN
        null;
    End; -- Pl Block

  END jl_ar_apxiisim_invoices_folder;

  -------------------------------------------------------------------------------
  --    Following segments are defined for Argentina Invoice Lines Interface
  -------------------------------------------------------------------------------
  -- No. Name                Column             Value Set                Required

  -- --- ------------------- ------------------ ------------------------ -------
  --  1 Ship to Location     GLOBAL_ATTRIBUTE3  JLZZ_AP_SHIP_TO_LOCATION Yes

  --  2 Tax Inclusive Amount GLOBAL_ATTRIBUTE4  FND_NUMBER               No
  -------------------------------------------------------------------------------

  -- This procedure validate the information in the GA 3,4
  -- in the invoice Line for Argentina.
  --

  PROCEDURE jl_ar_apxiisim_lines_folder
     (p_parent_id                       IN    NUMBER,
      p_default_last_updated_by         IN    NUMBER,
      p_default_last_update_login       IN    NUMBER,
      p_global_attribute1               IN    VARCHAR2,
      p_global_attribute2               IN    VARCHAR2,
      p_global_attribute3               IN    VARCHAR2,
      p_global_attribute4               IN    VARCHAR2,
      p_global_attribute5               IN    VARCHAR2,
      p_global_attribute6               IN    VARCHAR2,
      p_global_attribute7               IN    VARCHAR2,
      p_global_attribute8               IN    VARCHAR2,
      p_global_attribute9               IN    VARCHAR2,
      p_global_attribute10              IN    VARCHAR2,
      p_global_attribute11              IN    VARCHAR2,
      p_global_attribute12              IN    VARCHAR2,
      p_global_attribute13              IN    VARCHAR2,
      p_global_attribute14              IN    VARCHAR2,
      p_global_attribute15              IN    VARCHAR2,
      p_global_attribute16              IN    VARCHAR2,
      p_global_attribute17              IN    VARCHAR2,
      p_global_attribute18              IN    VARCHAR2,
      p_global_attribute19              IN    VARCHAR2,
      p_global_attribute20              IN    VARCHAR2,
      p_current_invoice_status          OUT NOCOPY   VARCHAR2,
      p_calling_sequence                IN    VARCHAR2) IS

  value_exists   VARCHAR2(1);

  BEGIN
     -- Ship to Location
   IF (p_global_attribute3 IS NOT NULL) THEN
       BEGIN
         SELECT 'X'
           INTO value_exists
           FROM HR_Locations_all
          WHERE Location_id = p_global_attribute3
            AND  sysdate < nvl(inactive_date, sysdate+1); -- Bug 3463869
     EXCEPTION

       WHEN OTHERS THEN
        jg_globe_flex_val_shared.insert_rejections('AP_INVOICE_LINES_INTERFACE',
                             p_parent_id,
                              'INVALID_GLOBAL_ATTR3',
                              p_default_last_updated_by,
                              p_default_last_update_login,
                              p_calling_sequence);
            p_current_invoice_status := 'N';

       END;
     ELSE -- The Global Attribute3 is Required

     jg_globe_flex_val_shared.insert_rejections('AP_INVOICE_LINES_INTERFACE',
                          p_parent_id,
                          'INVALID_GLOBAL_ATTR3',
                          p_default_last_updated_by,
                          p_default_last_update_login,
                          p_calling_sequence);
        p_current_invoice_status := 'N';
     END IF; -- p_global_attribute3 is not null

  -- Tax Inclusive Amount
     IF (p_global_attribute4 IS NOT NULL) THEN
       IF NOT (jg_globe_flex_val_shared.Check_Format (p_global_attribute4,'N',0, '','','','','','')) THEN
       jg_globe_flex_val_shared.insert_rejections('AP_INVOICE_LINES_INTERFACE',
                          p_parent_id,
                           'INVALID_GLOBAL_ATTR4',
                           p_default_last_updated_by,
                           p_default_last_update_login,
                           p_calling_sequence);
         p_current_invoice_status := 'N';

       END IF; -- Check_Format Number
     END IF; -- Validate Global Attribute 4

     -- Validate the rest of the Global Attributes be NULL

     IF ((p_global_attribute1   IS NOT NULL) OR
         (p_global_attribute2   IS NOT NULL) OR
         (p_global_attribute5   IS NOT NULL) OR
         (p_global_attribute6   IS NOT NULL) OR
         (p_global_attribute7   IS NOT NULL) OR
         (p_global_attribute8   IS NOT NULL) OR
         (p_global_attribute9   IS NOT NULL) OR
         (p_global_attribute10  IS NOT NULL) OR
         (p_global_attribute11  IS NOT NULL) OR
         (p_global_attribute12  IS NOT NULL) OR
         (p_global_attribute13  IS NOT NULL) OR
         (p_global_attribute14  IS NOT NULL) OR
         (p_global_attribute15  IS NOT NULL) OR
         (p_global_attribute16  IS NOT NULL) OR
         (p_global_attribute17  IS NOT NULL) OR
         (p_global_attribute18  IS NOT NULL) OR
         (p_global_attribute19  IS NOT NULL) OR
         (p_global_attribute20  IS NOT NULL))
      THEN
      jg_globe_flex_val_shared.insert_rejections('AP_INVOICE_LINES_INTERFACE',
                                           p_parent_id,
                                         'GLOBAL_ATTR_VALUE_FOUND',
                                         p_default_last_updated_by,
                                       p_default_last_update_login,
                                          p_calling_sequence);
                p_current_invoice_status := 'N';
     END IF;
  END jl_ar_apxiisim_lines_folder;

 -- Bug 3233307
  -----------------------------------------------------------------------------
  --    Following segments are defined for Colombia Invoice Interface
  ------------------------------------------------------------------------------
  -- No. Name            Column             Value Set                  Required
  -- --- --------------- -----------------  -------------------------- ---------
  --  1 Ship to Location GLOBAL_ATTRIBUTE18   JLZZ_AP_SHIP_TO_LOCATION  Yes

  ------------------------------------------------------------------------------
  --
  -- This procedure validate the information in the GA  18
  -- in the invoice Header for Colombia.

 PROCEDURE jl_co_apxiisim_invoices_folder
       (p_parent_id                 IN            NUMBER,
        p_default_last_updated_by   IN            NUMBER,
        p_default_last_update_login IN            NUMBER,
        p_global_attribute1         IN            VARCHAR2,
        p_global_attribute2         IN            VARCHAR2,
        p_global_attribute3         IN            VARCHAR2,
        p_global_attribute4         IN            VARCHAR2,
        p_global_attribute5         IN            VARCHAR2,
        p_global_attribute6         IN            VARCHAR2,
        p_global_attribute7         IN            VARCHAR2,
        p_global_attribute8         IN            VARCHAR2,
        p_global_attribute9         IN            VARCHAR2,
        p_global_attribute10        IN            VARCHAR2,
        p_global_attribute11        IN            VARCHAR2,
        p_global_attribute12        IN            VARCHAR2,
        p_global_attribute13        IN            VARCHAR2,
        p_global_attribute14        IN            VARCHAR2,
        p_global_attribute15        IN            VARCHAR2,
        p_global_attribute16        IN            VARCHAR2,
        p_global_attribute17        IN            VARCHAR2,
        p_global_attribute18        IN            VARCHAR2,
        p_global_attribute19        IN            VARCHAR2,
        p_global_attribute20        IN            VARCHAR2,
        p_current_invoice_status       OUT NOCOPY VARCHAR2,
        p_calling_sequence          IN            VARCHAR2) IS

    value_exists   VARCHAR2(1);

  BEGIN

    -- Validation for Ship To Location

    IF (p_global_attribute18  IS NOT NULL) THEN
       BEGIN
          SELECT 'X'
            INTO value_exists
            FROM HR_Locations_all
           WHERE Location_id = p_global_attribute18
	     AND sysdate < nvl(inactive_date, sysdate+1); -- Bug 3463869
      EXCEPTION

        WHEN OTHERS THEN
             jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                  p_parent_id,
                                 'INVALID_GLOBAL_ATTR18',
                                 p_default_last_updated_by,
                                 p_default_last_update_login,
                                  p_calling_sequence);
               p_current_invoice_status := 'N';

       END;

     END IF; -- p_global_attribute18 is null

     IF ((p_global_attribute1   IS NOT NULL) OR
         (p_global_attribute2   IS NOT NULL) OR
         (p_global_attribute3   IS NOT NULL) OR
         (p_global_attribute4   IS NOT NULL) OR
         (p_global_attribute5   IS NOT NULL) OR
         (p_global_attribute6   IS NOT NULL) OR
         (p_global_attribute7   IS NOT NULL) OR
         (p_global_attribute8   IS NOT NULL) OR
         (p_global_attribute9   IS NOT NULL) OR
         (p_global_attribute10  IS NOT NULL) OR
         (p_global_attribute11  IS NOT NULL) OR
         (p_global_attribute12  IS NOT NULL) OR
         (p_global_attribute13  IS NOT NULL) OR
         (p_global_attribute14  IS NOT NULL) OR
         (p_global_attribute15  IS NOT NULL) OR
         (p_global_attribute16  IS NOT NULL) OR
         (p_global_attribute17  IS NOT NULL) OR
         (p_global_attribute19  IS NOT NULL) OR
         (p_global_attribute20  IS NOT NULL))
     THEN
       jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                            p_parent_id,
                           'GLOBAL_ATTR_VALUE_FOUND',
                           p_default_last_updated_by,
                           p_default_last_update_login,
                           p_calling_sequence);
         p_current_invoice_status := 'N';

     END IF;

 END jl_co_apxiisim_invoices_folder;

 -- End of Inclusion for bug 3233307

  -----------------------------------------------------------------------------
  --    Following segments are defined for Colombia Invoice Lines Interface
  ------------------------------------------------------------------------------
  -- No. Name            Column             Value Set                  Required
  -- --- --------------- -----------------  -------------------------- ---------
  --  1 TaxPayer ID      GLOBAL_ATTRIBUTE2   JLCO_AP_THIRDPARTY_ID     No
  --  2 Ship to Location GLOBAL_ATTRIBUTE3   JLZZ_AP_SHIP_TO_LOCATION  Yes

  ------------------------------------------------------------------------------
  --
  -- This procedure validate the information in the GA 2,3
  -- in the invoice Line for Colombia.
  --

  PROCEDURE jl_co_apxiisim_lines_folder
     (p_parent_id                       IN    NUMBER,
      p_default_last_updated_by         IN    NUMBER,
      p_default_last_update_login       IN    NUMBER,
      p_global_attribute1               IN    VARCHAR2,
      p_global_attribute2               IN    VARCHAR2,
      p_global_attribute3               IN    VARCHAR2,
      p_global_attribute4               IN    VARCHAR2,
      p_global_attribute5               IN    VARCHAR2,
      p_global_attribute6               IN    VARCHAR2,
      p_global_attribute7               IN    VARCHAR2,
      p_global_attribute8               IN    VARCHAR2,
      p_global_attribute9               IN    VARCHAR2,
      p_global_attribute10              IN    VARCHAR2,
      p_global_attribute11              IN    VARCHAR2,
      p_global_attribute12              IN    VARCHAR2,
      p_global_attribute13              IN    VARCHAR2,
      p_global_attribute14              IN    VARCHAR2,
      p_global_attribute15              IN    VARCHAR2,
      p_global_attribute16              IN    VARCHAR2,
      p_global_attribute17              IN    VARCHAR2,
      p_global_attribute18              IN    VARCHAR2,
      p_global_attribute19              IN    VARCHAR2,
      p_global_attribute20              IN    VARCHAR2,
      p_current_invoice_status          OUT NOCOPY   VARCHAR2,
      p_calling_sequence                IN    VARCHAR2) IS

  value_exists   VARCHAR2(1);


  BEGIN
     -- Taxpayer Id
     IF (p_global_attribute2 IS NOT NULL) THEN
       -- The validation is with the vendor num (segment1)
       BEGIN
          SELECT 'X'
            INTO value_exists
            FROM PO_Vendors

             WHERE segment1 = p_global_attribute2;
       EXCEPTION

        WHEN OTHERS THEN

        jg_globe_flex_val_shared.insert_rejections('AP_INVOICE_LINES_INTERFACE',
                                  p_parent_id,
                                  'INVALID_GLOBAL_ATTR2',
                                  p_default_last_updated_by,
                                  p_default_last_update_login,
                                  p_calling_sequence);

                p_current_invoice_status := 'N';

              END;
     END IF; -- p_global_attribute2 is not null


     -- Ship to Location
     IF (p_global_attribute3 IS NOT NULL) THEN
       BEGIN
          SELECT 'X'
            INTO value_exists
            FROM HR_Locations_all
           WHERE Location_id = p_global_attribute3
	     AND sysdate < nvl(inactive_date, sysdate+1); -- Bug 3463869
      EXCEPTION

        WHEN OTHERS THEN

        jg_globe_flex_val_shared.insert_rejections('AP_INVOICE_LINES_INTERFACE',
                                  p_parent_id,
                                 'INVALID_GLOBAL_ATTR3',
                                 p_default_last_updated_by,
                                 p_default_last_update_login,
                                  p_calling_sequence);
               p_current_invoice_status := 'N';

       END;
     ELSE -- The Global Attribute3 is Required
       jg_globe_flex_val_shared.insert_rejections('AP_INVOICE_LINES_INTERFACE',
                           p_parent_id,
                           'INVALID_GLOBAL_ATTR3',
                           p_default_last_updated_by,
                           p_default_last_update_login,
                           p_calling_sequence);
          p_current_invoice_status := 'N';

     END IF; -- p_global_attribute3 is not null


     IF ((p_global_attribute1   IS NOT NULL) OR
         (p_global_attribute4   IS NOT NULL) OR
         (p_global_attribute5   IS NOT NULL) OR
         (p_global_attribute6   IS NOT NULL) OR
         (p_global_attribute7   IS NOT NULL) OR
         (p_global_attribute8   IS NOT NULL) OR
         (p_global_attribute9   IS NOT NULL) OR
         (p_global_attribute10  IS NOT NULL) OR
         (p_global_attribute11  IS NOT NULL) OR
         (p_global_attribute12  IS NOT NULL) OR
         (p_global_attribute13  IS NOT NULL) OR
         (p_global_attribute14  IS NOT NULL) OR
         (p_global_attribute15  IS NOT NULL) OR
         (p_global_attribute16  IS NOT NULL) OR
         (p_global_attribute17  IS NOT NULL) OR
         (p_global_attribute18  IS NOT NULL) OR
         (p_global_attribute19  IS NOT NULL) OR
         (p_global_attribute20  IS NOT NULL))
     THEN
       jg_globe_flex_val_shared.insert_rejections('AP_INVOICE_LINES_INTERFACE',
                            p_parent_id,
                           'GLOBAL_ATTR_VALUE_FOUND',
                           p_default_last_updated_by,
                           p_default_last_update_login,
                           p_calling_sequence);
         p_current_invoice_status := 'N';

     END IF;

 END jl_co_apxiisim_lines_folder;

-- Parameters to ar_business_rules changed for TCA model, so have to modify the
--parameters passed to the procedures within ar_business_rules
/*
PROCEDURE ar_business_rules
     (p_calling_program_name            IN    VARCHAR2,
      p_sob_id                          IN    NUMBER,
      p_row_id                          IN    VARCHAR2,
      p_customer_name                   IN    VARCHAR2,
      p_customer_number                 IN    NUMBER,
      p_jgzz_fiscal_code                IN    VARCHAR2,
      p_generate_customer_number        IN    VARCHAR2,
      p_orig_system_customer_ref        IN    VARCHAR2,
      p_insert_update_flag              IN    VARCHAR2,
      p_request_id                      IN    NUMBER,
      p_global_attribute_category       IN    VARCHAR2,
      p_global_attribute1               IN    VARCHAR2,
      p_global_attribute2               IN    VARCHAR2,
      p_global_attribute3               IN    VARCHAR2,
      p_global_attribute4               IN    VARCHAR2,
      p_global_attribute5               IN    VARCHAR2,
      p_global_attribute6               IN    VARCHAR2,
      p_global_attribute7               IN    VARCHAR2,
      p_global_attribute8               IN    VARCHAR2,
      p_global_attribute9               IN    VARCHAR2,
      p_global_attribute10              IN    VARCHAR2,
      p_global_attribute11              IN    VARCHAR2,
      p_global_attribute12              IN    VARCHAR2,
      p_global_attribute13              IN    VARCHAR2,
      p_global_attribute14              IN    VARCHAR2,
      p_global_attribute15              IN    VARCHAR2,
      p_global_attribute16              IN    VARCHAR2,
      p_global_attribute17              IN    VARCHAR2,
      p_global_attribute18              IN    VARCHAR2,
      p_global_attribute19              IN    VARCHAR2,
      p_global_attribute20              IN    VARCHAR2,
      p_current_record_status           OUT NOCOPY   VARCHAR2) IS


     l_current_record_status       VARCHAR2(1) := 'S';

BEGIN

  ----------------------------- DEBUG INFORMATION ------------------------------
  IF PG_DEBUG = 'Y' THEN
   arp_util_tax.debug('ar_business_rules: ' || 'Check ar business rules');
  END IF;
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  --                         Global Flexfield Validation
  ------------------------------------------------------------------------------
  --  You can add your own validation code for your global flexfields.
  --
  --  Form Name:  ARXCUDCI
  ------------------------------------------------------------------------------
  --   Header Level Validation - Block Name: CUST
  ------------------------------------------------------------------------------
  --    1-1. JL.CL.ARXCUDCI.CUSTOMERS
  --    1-2. JL.CO.ARXCUDCI.CUSTOMERS
  --    1-3. JL.AR.ARXCUDCI.CUSTOMERS
 -------------------------------------------------------------------------------

  --    1-1. JL.CL.ARXCUDCI.RA_CUSTOMERS
  --

  IF (p_global_attribute_category = 'JL.CL.ARXCUDCI.CUSTOMERS') THEN
    jl_cl_arxcudci_customers(
                p_calling_program_name,
                p_sob_id,
                p_row_id,
                p_customer_name,
                p_customer_number,
                p_jgzz_fiscal_code,
                p_generate_customer_number,
                p_orig_system_customer_ref,
                p_insert_update_flag,
                p_request_id,
                p_global_attribute_category,
                p_global_attribute1,
                p_global_attribute2,
                p_global_attribute3,
                p_global_attribute4,
                p_global_attribute5,
                p_global_attribute6,
                p_global_attribute7,
                p_global_attribute8,
                p_global_attribute9,
                p_global_attribute10,
                p_global_attribute11,
                p_global_attribute12,
                p_global_attribute13,
                p_global_attribute14,
                p_global_attribute15,
                p_global_attribute16,
                p_global_attribute17,
                p_global_attribute18,
                p_global_attribute19,
                p_global_attribute20,
                l_current_record_status);

  --
  --    1-2. JL.CO.ARXCUDCI.RA_CUSTOMERS
  --
  ELSIF (p_global_attribute_category = 'JL.CO.ARXCUDCI.CUSTOMERS') THEN
    jl_co_arxcudci_customers(
                p_calling_program_name,
                p_sob_id,
                p_row_id,
                p_customer_name,
                p_customer_number,
                p_jgzz_fiscal_code,
                p_generate_customer_number,
                p_orig_system_customer_ref,
                p_insert_update_flag,
                p_request_id,
                p_global_attribute_category,
                p_global_attribute1,
                p_global_attribute2,
                p_global_attribute3,
                p_global_attribute4,
                p_global_attribute5,
                p_global_attribute6,
                p_global_attribute7,
                p_global_attribute8,
                p_global_attribute9,
                p_global_attribute10,
                p_global_attribute11,
                p_global_attribute12,
                p_global_attribute13,
                p_global_attribute14,
                p_global_attribute15,
                p_global_attribute16,
                p_global_attribute17,
                p_global_attribute18,
                p_global_attribute19,
                p_global_attribute20,
                l_current_record_status);

  --
  --    1-3. JL.AR.ARXCUDCI.RA_CUSTOMERS
  --
  ELSIF (p_global_attribute_category = 'JL.AR.ARXCUDCI.CUSTOMERS') THEN
     jl_ar_arxcudci_customers(
                p_calling_program_name,
                p_sob_id,
                p_row_id,
                p_customer_name,
                p_customer_number,
                p_jgzz_fiscal_code,
                p_generate_customer_number,
                p_orig_system_customer_ref,
                p_insert_update_flag,
                p_request_id,
                p_global_attribute_category,
                p_global_attribute1,
                p_global_attribute2,
                p_global_attribute3,
                p_global_attribute4,
                p_global_attribute5,
                p_global_attribute6,
                p_global_attribute7,
                p_global_attribute8,
                p_global_attribute9,
                p_global_attribute10,
                p_global_attribute11,
                p_global_attribute12,
                p_global_attribute13,
                p_global_attribute14,
                p_global_attribute15,
                p_global_attribute16,
                p_global_attribute17,
                p_global_attribute18,
                p_global_attribute19,
                p_global_attribute20,
                l_current_record_status);
  ELSIF (p_global_attribute_category = 'JL.BR.ARXCUDCI.Additional') THEN
         l_current_record_status := 'S';
  END IF;
  p_current_record_status := l_current_record_status;
   EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('Exception in JL_INTERFACE_VAL.AR_BUSINESS_RULES()');
       arp_util_tax.debug('ar_business_rules: ' || SQLERRM);
      ELSE
        NULL;
      END IF;
  END ar_business_rules;

*/

-- Modification to the passing of parameters to ar_business_rules for TCA model

PROCEDURE ar_business_rules
   (p_int_table_name                  IN VARCHAR2,
    p_glob_attr_set1        IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set2        IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set3        IN jg_globe_flex_val_shared.GdfRec,
    p_misc_prod_arg                   IN jg_globe_flex_val_shared.GenRec,
      p_current_record_status OUT NOCOPY  VARCHAR2) IS

  l_current_record_status       VARCHAR2(1);  -- := 'S';
  l_ou_id  NUMBER;

  PG_DEBUG varchar2(1); -- := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

BEGIN
  l_current_record_status   := 'S';
  PG_DEBUG := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
  ----------------------------- DEBUG INFORMATION ------------------------------
  IF PG_DEBUG = 'Y' THEN
   arp_util_tax.debug('ar_business_rules: ' || 'Check ar business rules');
  END IF;
  ------------------------------------------------------------------------------

  -- Call to validate the address gdfs

  IF p_int_table_name = 'CUSTOMER' THEN

     --fnd_profile.get('ORG_ID',l_ou_id);

  --Bug 4499004
  --commented out above line and getting org id from fnd concurrents
    SELECT org_id into l_ou_id FROM fnd_concurrent_requests
    WHERE request_id = fnd_global.conc_request_id ;

    fnd_request.set_org_id(l_ou_id);

     IF jg_zz_shared_pkg.get_country(l_ou_id, NULL,null) IN ('AR','BR','CO','CL') THEN --Bug 2354736

        IF p_glob_attr_set1.global_attribute_category IN
                                  ('JL.AR.ARXCUDCI.CUSTOMERS' ,
                                   'JL.CL.ARXCUDCI.CUSTOMERS' ,
                                   'JL.CO.ARXCUDCI.CUSTOMERS') THEN
           jl_zz_arxcudci_cust_txid (p_glob_attr_set1,
                                     p_glob_attr_set2,
                                     p_glob_attr_set3,
                                     p_misc_prod_arg,
                                     l_current_record_status);
        END IF;

        IF p_glob_attr_set2.global_attribute_category IN
                                  ('JL.AR.ARXCUDCI.Additional' ,
                                   'JL.BR.ARXCUDCI.Additional' ,
                                   'JL.CO.ARXCUDCI.Additional') THEN
           jl_zz_ar_tx_arxcudci_address (p_glob_attr_set1,
                                         p_glob_attr_set2,
                                         p_glob_attr_set3,
                                         p_misc_prod_arg,
                                         l_current_record_status);
        END IF;

     END IF;

     IF jg_zz_shared_pkg.get_country(l_ou_id, NULL) = 'BR' THEN --Bug 2354736

        IF p_glob_attr_set2.global_attribute_category =
                                           'JL.BR.ARXCUDCI.Additional' THEN
           jl_br_arxcudci_additional (p_glob_attr_set1,
                                      p_glob_attr_set2,
                                      p_glob_attr_set3,
                                      p_misc_prod_arg,
                                      l_current_record_status);
        END IF;

     END IF;

  -- Call to validate the profile gdfs

  ELSIF (p_int_table_name) = 'PROFILE' THEN

     --fnd_profile.get('ORG_ID',l_ou_id);
  --Bug 4499004
  --commented out above line and getting org id from fnd concurrents
    SELECT org_id into l_ou_id FROM fnd_concurrent_requests
    WHERE request_id = fnd_global.conc_request_id ;

    fnd_request.set_org_id(l_ou_id);

     IF jg_zz_shared_pkg.get_country(l_ou_id, NULL) = 'BR' THEN

        IF p_glob_attr_set2.global_attribute_category =
                                      'JL.BR.ARXCUDCI.Additional Info' THEN
           jl_br_customer_profiles (p_glob_attr_set1,
                                    p_glob_attr_set2,
                                    p_glob_attr_set3,
                                    p_misc_prod_arg,
                                   l_current_record_status);
        END IF;

     END IF;

  END IF;

  p_current_record_status := l_current_record_status;

EXCEPTION
  WHEN OTHERS THEN
        IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('Exception in JL_INTERFACE_VAL.AR_BUSINESS_RULES()');
        arp_util_tax.debug('ar_business_rules: ' || SQLERRM);
        ELSE
          NULL;
        END IF;
END ar_business_rules;


PROCEDURE jl_zz_arxcudci_cust_txid(
    p_glob_attr_set1        IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set2        IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set3        IN jg_globe_flex_val_shared.GdfRec,
    p_misc_prod_arg        IN jg_globe_flex_val_shared.GenRec,
    p_record_status        OUT NOCOPY   VARCHAR2) IS

    l_record_status       VARCHAR2(1); -- := 'S';

BEGIN
        l_record_status := 'S';

        IF p_glob_attr_set1.global_attribute_category =
                                 'JL.CL.ARXCUDCI.CUSTOMERS' THEN
           jl_cl_arxcudci_customers(p_glob_attr_set1,
                                    p_glob_attr_set2,
                                    p_glob_attr_set3,
                                    p_misc_prod_arg,
                                    l_record_status);
        ELSIF p_glob_attr_set1.global_attribute_category =
                                   'JL.CO.ARXCUDCI.CUSTOMERS' THEN
           jl_co_arxcudci_customers(p_glob_attr_set1,
                                    p_glob_attr_set2,
                                    p_glob_attr_set3,
                                    p_misc_prod_arg,
                                    l_record_status);
        ELSIF p_glob_attr_set1.global_attribute_category =
                                   'JL.AR.ARXCUDCI.CUSTOMERS' THEN
           jl_ar_arxcudci_customers(p_glob_attr_set1,
                                    p_glob_attr_set2,
                                    p_glob_attr_set3,
                                    p_misc_prod_arg,
                                    l_record_status);
        END IF;

        p_record_status := l_record_status;

END jl_zz_arxcudci_cust_txid;
 -----------------------------------------------------------------------------------
 --      1-1. JL_CL_ARXCUDCI_RA_CUSTOMERS()
 ----------------------------------------------------------------------------------
 --    Following segments are defined for Chile Customer Interface:
 ----------------------------------------------------------------------------------
 -- No. Name                        Column              Value Set               Req
 ----- --------------------------- ------------------  ----------------------- ----
 --  1 Primary ID Type             GLOBAL_ATTRIBUTE10  JLZZ_ORIGIN              YES
 --  2 Primary ID Validation Digit GLOBAL_ATTRIBUTE12  JLCL_TAXID_VAL_DIGIT

 -----------------------------------------------------------------------------------
PROCEDURE jl_cl_arxcudci_customers(
    p_glob_attr_set1        IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set2        IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set3        IN jg_globe_flex_val_shared.GdfRec,
    p_misc_prod_arg        IN jg_globe_flex_val_shared.GenRec,
    p_record_status        OUT NOCOPY   VARCHAR2) IS

        l_record_status        VARCHAR2(1); -- := 'S';
        l_taxid_record_status  VARCHAR2(1); -- := 'S';
        l_mesg_code            VARCHAR2(50);
        l_taxid_mesg_code      VARCHAR2(50);
        l_row_id               ROWID; --       := p_misc_prod_arg.core_prod_arg2;
BEGIN
  l_record_status        := 'S';
  l_taxid_record_status  := 'S';
  l_row_id               := p_misc_prod_arg.core_prod_arg2;
  -- Checking for Domestic or Foreign Customer

  IF (p_glob_attr_set1.global_attribute10 NOT IN
                   ('DOMESTIC_ORIGIN','FOREIGN_ORIGIN')) OR
     (p_glob_attr_set1.global_attribute10 IS NULL) THEN

    --  Return the record status and the error message code
    --  (j2 -Invalid Value in Global Attribute10) to update
    --  INTERFACE_STATUS field in RA_CUSTOMERS_INTERFACE
    --  with error code

    l_mesg_code := 'j2,';
    l_record_status := 'E';

  END IF;

  IF (p_misc_prod_arg.core_prod_arg5 is not null) THEN
    IF (p_glob_attr_set1.global_attribute10 = 'DOMESTIC_ORIGIN' AND
        p_glob_attr_set1.global_attribute12 IS NULL) OR
       (p_glob_attr_set1.global_attribute12 IS NOT NULL AND
       ((lengthb(p_glob_attr_set1.global_attribute12)<>1) OR
       (p_glob_attr_set1.global_attribute12  not in
       ('0','1','2','3','4','5','6','7','8','9','K') ))) THEN

             -- Return the record status and the error message code
             -- (j4 -Invalid Value in Global Attribute12) to update
             -- INTERFACE_STATUS field in RA_CUSTOMERS_INTERFACE
             -- with error code

             -- Checking for global attribute12 has a value then check if it is
             -- between 0 - 9 or K.
             -- The length allowed for validation digit is 1

             l_mesg_code  := l_mesg_code||'j4,';
             l_record_status := 'E';
    END IF;
  END IF;  -- End if Tax ID is not null

  IF (p_glob_attr_set1.global_attribute1 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute2 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute3 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute4 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute5 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute6 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute7 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute8 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute9 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute11 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute13 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute14 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute15 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute16 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute17 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute18 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute19 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute20 IS NOT NULL) THEN

    l_mesg_code  := l_mesg_code||'i1,';
    l_record_status := 'E';

  END IF;

 IF (l_record_status = 'E') THEN
     jg_globe_flex_val_shared.update_interface_status (l_row_id,
           'RA_CUSTOMERS_INTERFACE',
           l_mesg_code,
           l_record_status);
  END IF;

  -- Checking for Tax ID is not null

  IF l_record_status = 'S' THEN
    IF (p_misc_prod_arg.core_prod_arg5 is not null) THEN

      jl_zz_taxid_customers(
                  'CL',
               --   'RACUST',
                  p_misc_prod_arg.core_prod_arg11,
                  p_misc_prod_arg.core_prod_arg2,
                  p_misc_prod_arg.core_prod_arg3,
                  p_misc_prod_arg.core_prod_arg4,
                  p_misc_prod_arg.core_prod_arg5,
                 -- p_generate_customer_number,
                  p_misc_prod_arg.core_prod_arg6,
                  p_misc_prod_arg.core_prod_arg7,
                  p_misc_prod_arg.core_prod_arg8,
                  p_misc_prod_arg.core_prod_arg9,
                  p_glob_attr_set1.global_attribute_category,
                  NULL,
                  p_glob_attr_set1.global_attribute10,
                  p_glob_attr_set1.global_attribute12,
                  l_taxid_mesg_code,
                  l_taxid_record_status);
    END IF; -- End IF taxpayer ID is not null.
  END IF;  -- End IF l_record_status = 'S'

 IF (l_taxid_record_status = 'E') THEN
     jg_globe_flex_val_shared.update_interface_status (l_row_id,
           'RA_CUSTOMERS_INTERFACE',
           l_taxid_mesg_code,
           l_taxid_record_status);
  ELSIF (l_taxid_record_status = 'W') THEN
     jg_globe_flex_val_shared.update_interface_status (l_row_id,
           'RA_CUSTOMERS_INTERFACE',
           l_taxid_mesg_code,
           l_taxid_record_status);
  END IF;

 IF l_record_status = 'E' OR l_taxid_record_status = 'E' THEN
   p_record_status := 'E';
 ELSE
   p_record_status := 'S';
 END IF;

END jl_cl_arxcudci_customers;

 -------------------------------------------------------------------------------------
 --      1-2. JL_CO_ARXCUDCI_RA_CUSTOMERS()
 -------------------------------------------------------------------------------------
 --    Following segments are defined for Colombia Customer Interface:

 -------------------------------------------------------------------------------------
 --    No. Name                        Column              Value Set              Req.
 --    --- --------------------------- ------------------  --------------------  -----
 --      1 Primary ID Type             GLOBAL_ATTRIBUTE10  JL_CO_TAXID_TYPE       YES
 --      2 Primary ID Validation Digit GLOBAL_ATTRIBUTE12  JLZZ_TAXID_VAL_DIGIT

 -------------------------------------------------------------------------------------

PROCEDURE jl_co_arxcudci_customers(
    p_glob_attr_set1        IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set2        IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set3        IN jg_globe_flex_val_shared.GdfRec,
    p_misc_prod_arg        IN jg_globe_flex_val_shared.GenRec,
    p_record_status        OUT NOCOPY   VARCHAR2) IS

        l_record_status        VARCHAR2(1); -- := 'S';
        l_taxid_record_status  VARCHAR2(1); -- := 'S';
        l_mesg_code            VARCHAR2(50);
        l_taxid_mesg_code      VARCHAR2(50);
        l_row_id               ROWID;       --:= p_misc_prod_arg.core_prod_arg2;
BEGIN
        l_record_status         := 'S';
        l_taxid_record_status   := 'S';
        l_row_id                := p_misc_prod_arg.core_prod_arg2;

  -- Checking for Natural people, Foreign  and Legal Entity

  IF (p_glob_attr_set1.global_attribute10 NOT IN
                         ('INDIVIDUAL','LEGAL_ENTITY','FOREIGN_ENTITY')) OR
     (p_glob_attr_set1.global_attribute10 IS NULL) THEN

    -- Return the record status and the error message code
    -- (j2 -Invalid Value in Global Attribute10)
    -- to update INTERFACE_STATUS field in RA_CUSTOMERS_INTERFACE
    -- with error code

    l_mesg_code  := 'j2,';
    l_record_status := 'E';

  END IF;

  -- Checking for Legal and Global attribute12 is NULL

  IF (p_misc_prod_arg.core_prod_arg5 is not null) THEN
    IF (p_glob_attr_set1.global_attribute10 = 'LEGAL_ENTITY' AND
        p_glob_attr_set1.global_attribute12 IS NULL) OR
       (p_glob_attr_set1.global_attribute12 IS NOT NULL AND
       ((lengthb(p_glob_attr_set1.global_attribute12)<>1) OR
       (p_glob_attr_set1.global_attribute12  not in
       ('0','1','2','3','4','5','6','7','8','9')))) THEN

             -- Return the record status and the error message code
             -- (j4 -Invalid Value in Global Attribute12) to update
             -- INTERFACE_STATUS field in RA_CUSTOMERS_INTERFACE
             -- with error code

             -- Checking for global attribute12 has a value then check if it is
             -- between 0 - 9 or K.
             -- The length allowed for validation digit is 1

             l_mesg_code  := l_mesg_code||'j4,';
             l_record_status := 'E';
    END IF;
  END IF;

  IF (p_glob_attr_set1.global_attribute1 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute2 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute3 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute4 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute5 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute6 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute7 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute8 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute9 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute11 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute13 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute14 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute15 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute16 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute17 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute18 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute19 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute20 IS NOT NULL) THEN

      l_mesg_code  := l_mesg_code||'i1,';
      l_record_status := 'E';
  END IF;

  IF (l_record_status = 'E') THEN
     jg_globe_flex_val_shared.update_interface_status (l_row_id,
           'RA_CUSTOMERS_INTERFACE',
           l_mesg_code,
           l_record_status);
  END IF;

  IF l_record_status = 'S' THEN
    IF (p_misc_prod_arg.core_prod_arg5 is not null) THEN
      jl_zz_taxid_customers(
                  'CO',
                  --'RACUST',
                  p_misc_prod_arg.core_prod_arg11,
                  p_misc_prod_arg.core_prod_arg2 ,
                  p_misc_prod_arg.core_prod_arg3 ,
                  p_misc_prod_arg.core_prod_arg4 ,
                  p_misc_prod_arg.core_prod_arg5 ,
                  --p_generate_customer_number,
                  p_misc_prod_arg.core_prod_arg6 ,
                  p_misc_prod_arg.core_prod_arg7 ,
                  p_misc_prod_arg.core_prod_arg8 ,
                  p_misc_prod_arg.core_prod_arg9 ,
                  p_glob_attr_set1.global_attribute_category,
                  NULL,
                  p_glob_attr_set1.global_attribute10,
                  p_glob_attr_set1.global_attribute12,
                  l_taxid_mesg_code,
                  l_taxid_record_status);
    END IF; -- End IF taxpayer ID is not null.
  END IF;  -- End IF l_record_status = 'S'


 IF (l_taxid_record_status = 'E') THEN
     jg_globe_flex_val_shared.update_interface_status (l_row_id,
           'RA_CUSTOMERS_INTERFACE',
           l_taxid_mesg_code,
           l_taxid_record_status);

 ELSIF (l_taxid_record_status = 'W') THEN
     jg_globe_flex_val_shared.update_interface_status (l_row_id,
           'RA_CUSTOMERS_INTERFACE',
           l_taxid_mesg_code,
           l_taxid_record_status);
 END IF;

 IF l_record_status = 'E' OR l_taxid_record_status = 'E' THEN
   p_record_status := 'E';
 ELSE
   p_record_status := 'S';
 END IF;


END jl_co_arxcudci_customers;

 -----------------------------------------------------------------------------------
 --      1-3. JL.AR.ARXCUDCI.RA_CUSTOMERS()
 -----------------------------------------------------------------------------------
 --    Following segments are defined for Argentina Customer Interface:

 ------------------------------------------------------------------------------------
 --    No. Name                        Column              Value Set            Req.
 --    --- --------------------------- ------------------  -------------------- ----
 --      1 Origin                      GLOBAL_ATTRIBUTE9   JLZZ_ORIGIN          YES
 --      2 Primary ID Type             GLOBAL_ATTRIBUTE10  JLAR_TAXID_TYPE      YES
 --      3 Primary ID Validation Digit GLOBAL_ATTRIBUTE12  JLZZ_TAXID_VAL_DIGIT

 -------------------------------------------------------------------------------
PROCEDURE jl_ar_arxcudci_customers(
    p_glob_attr_set1        IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set2        IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set3        IN jg_globe_flex_val_shared.GdfRec,
    p_misc_prod_arg        IN jg_globe_flex_val_shared.GenRec,
    p_record_status        OUT NOCOPY   VARCHAR2) IS

        l_lookup_code          VARCHAR2(2);
        l_record_status        VARCHAR2(1);  --:= 'S';
        l_taxid_record_status  VARCHAR2(1);  --:= 'S';
        l_mesg_code            VARCHAR2(50);
        l_taxid_mesg_code      VARCHAR2(50);
        l_row_id               ROWID;        --:= p_misc_prod_arg.core_prod_arg2;

BEGIN
        l_record_status        := 'S';
        l_taxid_record_status  := 'S';
        l_row_id               := p_misc_prod_arg.core_prod_arg2;

  IF (p_glob_attr_set1.global_attribute9 NOT IN
                             ('DOMESTIC_ORIGIN','FOREIGN_ORIGIN')) OR
     (p_glob_attr_set1.global_attribute9 IS NULL) THEN

    -- Return the record status and the error message code
    -- (j1 -Invalid Value in Global Attribute9)
    -- to update INTERFACE_STATUS field in RA_CUSTOMERS_INTERFACE
    -- with error code

    l_mesg_code  := 'j1,';
    l_record_status := 'E';
  END IF;

  -- Validate for p_global_attribute10

  BEGIN
    SELECT 'x'
    INTO l_lookup_code
    FROM dual
    WHERE exists (select lookup_code
                  from fnd_lookups
                  where lookup_type = 'JLAR_TAXID_TYPE'
                  and lookup_code = p_glob_attr_set1.global_attribute10);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- Return the record status and the error message code
        -- (j2 -Invalid Value in Global Attribute10) to update
        -- INTERFACE_STATUS field in RA_CUSTOMERS_INTERFACE
        -- with error code

        l_mesg_code := l_mesg_code||'j2,';
        l_record_status := 'E';

  END;  -- End Begin Validation for p_global_attribute10

  -- Checking for '82' and '80'(Domestic CUIT and CUIL) and Global attribute12
  -- is NULL

  IF (p_misc_prod_arg.core_prod_arg5 is not null) THEN
    IF (p_glob_attr_set1.global_attribute10 IN ('80','82') AND
        p_glob_attr_set1.global_attribute12 is NULL) OR
       (p_glob_attr_set1.global_attribute12 IS NOT NULL AND
        ((lengthb(p_glob_attr_set1.global_attribute12)<>1) OR
         (p_glob_attr_set1.global_attribute12  not in
         ('0','1','2','3','4','5','6','7','8','9')))) THEN

      -- Return the record status and the error message code
      -- (j4 -Invalid Value in Global Attribute12) to update
      -- INTERFACE_STATUS field in RA_CUSTOMERS_INTERFACE
      -- with error code

      l_mesg_code  := l_mesg_code||'j4,';
      l_record_status := 'E';

    END IF;
  END IF;

  IF (p_glob_attr_set1.global_attribute1 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute2 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute3 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute4 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute5 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute6 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute7 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute8 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute11 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute13 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute14 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute15 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute16 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute17 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute18 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute19 IS NOT NULL) OR
     (p_glob_attr_set1.global_attribute20 IS NOT NULL) THEN

    l_mesg_code  := l_mesg_code||'i1,';
    l_record_status := 'E';

  END IF;

  IF (l_record_status = 'E') THEN
     jg_globe_flex_val_shared.update_interface_status (l_row_id,
           'RA_CUSTOMERS_INTERFACE',
           l_mesg_code,
           l_record_status);
  END IF;

  IF l_record_status = 'S' THEN
    IF (p_misc_prod_arg.core_prod_arg5 is not null) THEN
      jl_zz_taxid_customers(
                  'AR',
                  --'RACUST',
                  p_misc_prod_arg.core_prod_arg11,
                  p_misc_prod_arg.core_prod_arg2,
                  p_misc_prod_arg.core_prod_arg3,
                  p_misc_prod_arg.core_prod_arg4,
                  p_misc_prod_arg.core_prod_arg5,
                  --p_generate_customer_number,
                  p_misc_prod_arg.core_prod_arg6,
                  p_misc_prod_arg.core_prod_arg7,
                  p_misc_prod_arg.core_prod_arg8,
                  p_misc_prod_arg.core_prod_arg9,
                  p_glob_attr_set1.global_attribute_category,
                  p_glob_attr_set1.global_attribute9,
                  p_glob_attr_set1.global_attribute10,
                  p_glob_attr_set1.global_attribute12,
                  l_taxid_mesg_code,
                  l_taxid_record_status);
    END IF; -- End IF taxpayer ID is not null.
  END IF;  -- End IF l_record_status = 'S'

 IF (l_taxid_record_status = 'E') THEN
     jg_globe_flex_val_shared.update_interface_status (l_row_id,
           'RA_CUSTOMERS_INTERFACE',
           l_taxid_mesg_code,
           l_taxid_record_status);
 ELSIF (l_taxid_record_status = 'W') THEN
     jg_globe_flex_val_shared.update_interface_status (l_row_id,
           'RA_CUSTOMERS_INTERFACE',
           l_taxid_mesg_code,
           l_taxid_record_status);
 END IF;

 IF l_record_status = 'E' OR l_taxid_record_status = 'E' THEN
   p_record_status := 'E';
 ELSE
   p_record_status := 'S';
 END IF;

END jl_ar_arxcudci_customers;

  ---------------------------------------------------------------------------
  -- JL_ZZ_TAXID_RA_CUSTOMERS():
  -- This procedure validates Bussines Rules for each country and
  -- call JG_TAXID_VAL_PKG package
  --------------------------------------------------------------------------
PROCEDURE jl_zz_taxid_customers(
                p_country_code                  IN VARCHAR2,
                p_calling_program_name          IN VARCHAR2,
                p_row_id                        IN VARCHAR2,
                p_customer_name                 IN VARCHAR2,
                p_customer_number               IN VARCHAR2,
                p_jgzz_fiscal_code              IN VARCHAR2,
                p_generate_customer_number      IN VARCHAR2,
                p_orig_system_customer_ref      IN VARCHAR2,
                p_insert_update_flag            IN VARCHAR2,
                p_request_id                    IN NUMBER,
                p_global_attribute_category     IN VARCHAR2,
                p_global_attribute9             IN VARCHAR2,
                p_global_attribute10            IN VARCHAR2,
                p_global_attribute12            IN VARCHAR2,
                p_taxid_mesg_code              OUT NOCOPY VARCHAR2,
                p_taxid_record_status          OUT NOCOPY VARCHAR2) IS

    l_return_ar             VARCHAR2(10):=NULL;
    l_return_ap             VARCHAR2(10):=NULL;
    l_return_hr             VARCHAR2(10):=NULL;
    l_return_bk             VARCHAR2(10):=NULL;
    l_taxid_raise_error     VARCHAR2(30);
    l_cus_sup_num           VARCHAR2(30);
    l_num_digits            NUMBER; -- Maximum digits allowed for each country
    l_copy                  VARCHAR2(1);
    l_customer_id           NUMBER;

PG_DEBUG varchar2(1);

BEGIN
  PG_DEBUG := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

  FND_PROFILE.GET('JLZZ_TAXID_RAISE_ERROR',l_taxid_raise_error);
  IF p_country_code = 'CL' THEN
    l_taxid_raise_error := NVL(l_taxid_raise_error,'VALIDATION_TYPE_WARN');
    l_num_digits := 12; -- Maximum digits allowed for Chile
  END IF; -- End IF p_country_code = 'CL'

  IF p_country_code = 'CO' THEN
    l_taxid_raise_error := NVL(l_taxid_raise_error,'VALIDATION_TYPE_ERROR');
    l_num_digits := 14; -- Maximum digits allowed for Colombia
  END IF; -- End IF p_country_code = 'CO'

  IF p_country_code = 'AR' THEN
    l_taxid_raise_error := NVL(l_taxid_raise_error,'VALIDATION_TYPE_ERROR');
    IF (p_global_attribute10 IN ('80','82')) THEN
      l_num_digits:=10;
    ELSIF (p_global_attribute10 = '96') THEN
      l_num_digits:=8;
    END IF;
  END IF; -- End IF p_country_code = 'AR'


  IF p_country_code IN ('CL','CO') THEN
     FND_PROFILE.GET('JLZZ_COPY_CUS_SUP_NUM',l_cus_sup_num);
     l_cus_sup_num := NVL(l_cus_sup_num,'Y');
     IF p_generate_customer_number='N' AND l_cus_sup_num='Y' THEN
        l_copy:='Y';
     ELSE
        l_copy:='N';
     END IF;
  END IF;

  -- Validation for CHECK_NUMERIC AND CHECK_LENGTH
  IF (p_country_code IN ('CL','CO')) OR
     (p_country_code = 'AR' and (p_global_attribute9 = 'DOMESTIC_ORIGIN' AND p_global_attribute10 IN ('80','82','96')) OR
     (p_global_attribute9 = 'FOREIGN_ORIGIN' AND p_global_attribute10 = '80')) THEN

    -- Check for Numeric

    IF JG_TAXID_VAL_PKG.CHECK_NUMERIC(p_jgzz_fiscal_code) <> 'TRUE' THEN

      -- Return the record status and the error message code
      -- k3 - Taxpayer ID should be numeric) to update
      -- INTERFACE_STATUS field in RA_CUSTOMERS_INTERFACE
      -- with error code

      p_taxid_mesg_code  := 'k3,';
      p_taxid_record_status := 'E';
      return;

    END IF;

    -- Check maximun digits allowed.

    IF JG_TAXID_VAL_PKG.CHECK_LENGTH(
                                     p_country_code,
                                     l_num_digits,
                                     p_jgzz_fiscal_code
                                    ) <> 'TRUE' THEN
      -- Return the record status and the error message code
      -- (k4 - Taxpayer ID exceeds maximun digits allowed)
      -- to update  INTERFACE_STATUS field in
      -- RA_CUSTOMERS_INTERFACE with error code

      p_taxid_mesg_code  := 'k4,';
      p_taxid_record_status := 'E';
      return;

    END IF;
  END IF; --End for validation CHECK_NUMERIC and CHECK_LENGTH

  -- Validation for CHECK_UNIQUENESS

  -- Checking for Customer_id in RA_CUSTOMERS table for records marked for
  -- Update in RA_CUSTOMERS_INTERFACE

  IF (p_insert_update_flag = 'U') THEN

   BEGIN

     SELECT rc.cust_account_id INTO l_customer_id
     FROM hz_cust_accounts rc
     WHERE rc.orig_system_reference = p_orig_system_customer_ref;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
        IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('jl_zz_taxid_customers: ' || 'No data found in hz_cust_accounts table for Update');
        ELSE
          NULL;
        END IF;
      WHEN OTHERS THEN
        IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('Exception in JL_INTERFACE_VAL.JL_ZZ_TAXID_CUSTOMERS()');
        arp_util_tax.debug('jl_zz_taxid_customers: ' || SQLERRM);
        ELSE
          NULL;
        END IF;
   END;

  ELSE

     l_customer_id := 0;

  END IF;


  IF (p_country_code IN ('CL','CO')) OR
     (p_country_code = 'AR' and p_global_attribute9='DOMESTIC_ORIGIN') THEN
    IF JG_TAXID_VAL_PKG.CHECK_UNIQUENESS(
                                         p_country_code,
                                         p_jgzz_fiscal_code,
                                         l_customer_id,
                                         --'RACUST',
                                         p_calling_program_name,
                                         p_orig_system_customer_ref,
                                         p_customer_name,
                                         p_request_id) <> 'TRUE' THEN

      -- Return the record status and the error message code
      -- (k5 - Duplicate Tax ID) to update INTERFACE_STATUS
      -- field in RA_CUSTOMERS_INTERFACE with error code

      p_taxid_mesg_code := 'k5,';
      p_taxid_record_status := 'E';
      return;

    END IF;
  END IF;  -- End validation for CHECK_UNIQUENESS

  -- Validation for CROSS_VALIDATE

  IF (p_country_code = 'CL' AND p_global_attribute10 = 'DOMESTIC_ORIGIN') OR
     (p_country_code = 'CO') OR
     (p_country_code = 'AR' and p_global_attribute9 = 'DOMESTIC_ORIGIN' AND p_global_attribute10 IN ('80','82','96')) THEN

    -- Call procedure to cross validate if Customer exists
    -- as a Supplier with different Tax ID and Name

    IF p_customer_name IS NOT NULL THEN

      JG_TAXID_VAL_PKG.CHECK_CROSS_MODULE(
                                          p_country_code,
                                          p_customer_name,
                                          p_jgzz_fiscal_code,
                                          p_global_attribute9,
                                          p_global_attribute10,
                                          p_calling_program_name,
                                          l_return_ar,
                                          l_return_ap,
                                          l_return_hr,
                                          l_return_bk);
      IF (l_return_ap='k6') THEN

        -- Return the record status and the warning message
        -- code (k6 -Tax ID used by different Supplier)
        -- to update INTERFACE_STATUS field in
        -- RA_CUSTOMERS_INTERFACE with error code

        IF l_taxid_raise_error= 'VALIDATION_TYPE_ERROR' THEN
          p_taxid_mesg_code := 'k6,';
          p_taxid_record_status := 'E';
          return;
        ELSE
          p_taxid_mesg_code := p_taxid_mesg_code||'k6,';
          p_taxid_record_status := 'W';
        END IF;
      ELSIF (l_return_ap='k8') THEN

        -- Return the record status and the warning message code
        -- (k8 - Customer exist as Supplier with different
        -- Tax id) to update WARNING_TEXT field in
        -- RA_CUSTOMERS_INTERFACE with error code

        IF l_taxid_raise_error='VALIDATION_TYPE_ERROR' THEN
          p_taxid_mesg_code := 'k8,';
          p_taxid_record_status := 'E';
          return;
        ELSE
          p_taxid_mesg_code := p_taxid_mesg_code||'k8,';
          p_taxid_record_status := 'W';
        END IF;
      END IF;

      IF (l_return_hr='k7') THEN

        -- Return the record status and the warning message
        -- code (k7 -Tax ID used by different Company - Company
        -- with different name) to update WARNING_TEXT field in
        -- RA_CUSTOMERS_INTERFACE with error code

        IF l_taxid_raise_error='VALIDATION_TYPE_ERROR' THEN
          p_taxid_mesg_code := 'k7,';
          p_taxid_record_status := 'E';
          return;
        ELSE
          p_taxid_mesg_code := p_taxid_mesg_code||'k7,';
          p_taxid_record_status := 'W';
        END IF;
      ELSIF (l_return_hr='k9') THEN

        --  Return the record status and the warning message code
        --  (k9 - Customer exist as Company with
        --  different Tax ID) to update WARNING_TEXT field in
        --  RA_CUSTOMERS_INTERFACE with error code

        IF l_taxid_raise_error='VALIDATION_TYPE_ERROR' THEN
          p_taxid_mesg_code := 'k9,';
          p_taxid_record_status := 'E';
          return;
        ELSE
          p_taxid_mesg_code := p_taxid_mesg_code||'k9,';
          p_taxid_record_status := 'W';
        END IF;
      END IF;

      IF p_country_code = 'CO' THEN   -- Validations for Banks.
        IF (l_return_bk='l1') THEN

          -- Return the record status and the warning message
          -- code (l1 - Tax ID used by different Bank)
          -- to update WARNING_TEXT field in
          -- RA_CUSTOMERS_INTERFACE with error code

          IF l_taxid_raise_error='VALIDATION_TYPE_ERROR' THEN
            p_taxid_mesg_code := 'l1,';
            p_taxid_record_status := 'E';
            return;
          ELSE
            p_taxid_mesg_code := p_taxid_mesg_code||'l1,';
            p_taxid_record_status := 'W';
          END IF;
        ELSIF (l_return_bk='l2') THEN

          -- Return the record status and the warning message code
          -- (l2 - Customer exist as a Bank with different Tax ID
          -- or ID Type) to update WARNING_TEXT field in
          -- RA_CUSTOMERS_INTERFACE with error code

          IF l_taxid_raise_error='VALIDATION_TYPE_ERROR' THEN
            p_taxid_mesg_code := 'l2,';
            p_taxid_record_status := 'E';
            return;
          ELSE
            p_taxid_mesg_code := p_taxid_mesg_code||'l2,';
            p_taxid_record_status := 'W';
          END IF;
        END IF;
      END IF; -- End IF p_country_code = 'CO' for Banks
    END IF; -- End of IF p_customer_name IS NOT NULL
  END IF; -- End for Cross Module Validate

  -- Validation algorithm for verifying the validation digit

  IF (p_country_code = 'CL' and p_global_attribute10 = 'DOMESTIC_ORIGIN') OR
     (p_country_code = 'CO' and p_global_attribute10 = 'LEGAL_ENTITY') OR
     ((p_country_code = 'AR' and (p_global_attribute9 = 'DOMESTIC_ORIGIN' AND p_global_attribute10 IN ('80','82')) OR
      (p_global_attribute9 = 'FOREIGN_ORIGIN' AND p_global_attribute10 = '80')))
 THEN
    IF JG_TAXID_VAL_PKG.CHECK_ALGORITHM(
                                        p_jgzz_fiscal_code,
                                        p_country_code,
                                        p_global_attribute12
                                        ) <> 'TRUE' THEN
      IF (l_taxid_raise_error = 'VALIDATION_TYPE_ERROR') THEN

        -- Return the record status and the error message code
        -- (k0 - Validation Routine Failed)
        -- to update INTERFACE_STATUS field in
        -- RA_CUSTOMERS_INTERFACE with error code

        p_taxid_mesg_code := 'k0,';
        p_taxid_record_status := 'E';
        return;

      ELSE

        -- The record can be processed. But a Warning message
        -- should appear in the Log File. Update field
        -- WARNING_TEXT in RA_CUSTOMERS_INTERFACE with
        -- error code k0 - Tax ID Validation Routine Failed

        p_taxid_mesg_code := p_taxid_mesg_code||'k0,';
        p_taxid_record_status := 'W';

      END IF;
    END IF;
  END IF;  -- End Validation Algorithm

  IF (p_country_code = 'CL' AND l_copy = 'Y' AND p_customer_number IS NULL) THEN

     IF p_global_attribute12 IS NOT NULL THEN
        UPDATE ra_customers_interface
        SET customer_number = p_jgzz_fiscal_code||'-'||p_global_attribute12
        WHERE rowid = p_row_id;
     ELSE
        UPDATE ra_customers_interface
        SET customer_number = p_jgzz_fiscal_code
        WHERE rowid = p_row_id;
     END IF;
  END IF;

  IF (p_country_code = 'CO' AND l_copy = 'Y' AND p_customer_number IS NULL) THEN

    IF (p_global_attribute10 = 'LEGAL_ENTITY') AND (p_global_attribute12 IS NOT NULL) THEN
        UPDATE ra_customers_interface
        SET customer_number = p_jgzz_fiscal_code||'-'||p_global_attribute12
        WHERE rowid = p_row_id;
    ELSE
        UPDATE ra_customers_interface
        SET customer_number = p_jgzz_fiscal_code
        WHERE rowid = p_row_id;
    END IF;


  END IF;

  IF p_taxid_record_status IS NULL THEN

    IF PG_DEBUG = 'Y' THEN
    arp_util_tax.debug('jl_zz_taxid_customers: ' || 'In if record status is null p_taxid_record_status: '||p_taxid_record_status);
    END IF;
    p_taxid_record_status:='S';

  END IF;
END jl_zz_taxid_customers;

  -------------------------------------------------------------------------------
  --    Following segments are defined for Brazilian Invoice Interface
  -------------------------------------------------------------------------------
  -- No. Name                            Column             Value Set                       Required
  -- -- ------------------------------- --------------------- ---------------------------  -------
  -- 1  Collection Document Association GLOBAL_ATTRIBUTE1  JLBR_AP_CHAR_ENABLE_BANK_COLL   Yes
  -- 2  Operation Fiscal Code           GLOBAL_ATTRIBUTE2  JLBR_AP_CFO_CODE2               No
  -- 3  Series                          GLOBAL_ATTRIBUTE3  JLBR_AP_CHAR_INVOICE_SERIES     No
  -- 4  Class                           GLOBAL_ATTRIBUTE4  JLBR_AP_CHAR_INVOICE_CLASS      No
  -- 5  ICMS Base Amount                GLOBAL_ATTRIBUTE5  JLBR_PO_NUMBER_BASE_AMOUNT      No
  -- 6  ICMS Name                       GLOBAL_ATTRIBUTE6  JLBR_PO_CHAR_ICMS_TAX_NAME      No
  -- 7  ICMS Amount                     GLOBAL_ATTRIBUTE7  JLBR_PO_NUMBER_ICMS_TAX_AMOUNT  No
  -- 8  IPI Amount                      GLOBAL_ATTRIBUTE8  JLBR_PO_NUMBER_IPI_TAX_AMOUNT   No
  -- 9  Withholding Base Amount         GLOBAL_ATTRIBUTE9  JLBR_AP_NUMBER_WHT_BASE_AMOUNT  No
  --------------------------------------------------------------------------------
  -- This procedure validates the information in the GA 1,2,3,4,5,6,7,8,9,10
  -- in the invoice header for Brazil.
  --

  PROCEDURE jl_br_apxiisim_invoices_folder
     (p_parent_id                       IN    NUMBER,
      p_default_last_updated_by         IN    NUMBER,
      p_default_last_update_login       IN    NUMBER,
      p_global_attribute1               IN    VARCHAR2,
      p_global_attribute2               IN    VARCHAR2,
      p_global_attribute3               IN    VARCHAR2,
      p_global_attribute4               IN    VARCHAR2,
      p_global_attribute5               IN    VARCHAR2,
      p_global_attribute6               IN    VARCHAR2,
      p_global_attribute7               IN    VARCHAR2,
      p_global_attribute8               IN    VARCHAR2,
      p_global_attribute9               IN    VARCHAR2,
      p_global_attribute10              IN    VARCHAR2,
      p_global_attribute11              IN    VARCHAR2,
      p_global_attribute12              IN    VARCHAR2,
      p_global_attribute13              IN    VARCHAR2,
      p_global_attribute14              IN    VARCHAR2,
      p_global_attribute15              IN    VARCHAR2,
      p_global_attribute16              IN    VARCHAR2,
      p_global_attribute17              IN    VARCHAR2,
      p_global_attribute18              IN    VARCHAR2,
      p_global_attribute19              IN    VARCHAR2,
      p_global_attribute20              IN    VARCHAR2,
      p_current_invoice_status          OUT NOCOPY   VARCHAR2,
      p_calling_sequence                IN    VARCHAR2) IS

  value_exists   VARCHAR2(1);
  p_val_date     date;

  BEGIN

      -- Validation for Collection Document Association Option

      IF (p_global_attribute1 IS NOT NULL) THEN
         BEGIN
           SELECT 'X'
             INTO value_exists
             FROM fnd_lookups
            WHERE  lookup_type =  'YES_NO'
              AND  lookup_code = p_global_attribute1
              AND  nvl(start_date_active,sysdate) <= sysdate
              AND  nvl(end_date_active,sysdate) >= sysdate
              AND  enabled_flag = 'Y';
         EXCEPTION

           WHEN OTHERS THEN
             jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                              p_parent_id,
                              'INVALID_GLOBAL_ATTR1',
                              p_default_last_updated_by,
                              p_default_last_update_login,
                              p_calling_sequence);
             p_current_invoice_status := 'N';

         END;
      ELSE -- The Global Attribute1 is Required
        jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                            p_parent_id,
                            'INVALID_GLOBAL_ATTR1',
                            p_default_last_updated_by,
                            p_default_last_update_login,
                            p_calling_sequence);
        p_current_invoice_status := 'N';

      END IF; -- p_global_attribute1 is not null

      -- Validation for Operation Fiscal Code

      IF (p_global_attribute2 IS NOT NULL) THEN
        BEGIN
          SELECT  'X'
            INTO  value_exists
            FROM  jl_br_ap_operations
             WHERE  cfo_code = p_global_attribute2;
        EXCEPTION
          WHEN OTHERS THEN
            jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                            p_parent_id,
                            'INVALID_GLOBAL_ATTR2',
                            p_default_last_updated_by,
                            p_default_last_update_login,
                            p_calling_sequence);
            p_current_invoice_status := 'N';
        END;
      END IF; -- p_global_attribute2 is not null

      -- Validation for Invoice Series

      IF (p_global_attribute3 IS NOT NULL) THEN
         BEGIN
           SELECT 'X'
             INTO value_exists
             FROM fnd_lookups
            WHERE  lookup_type =  'JLBR_INVOICE_SERIES'
              AND  lookup_code = p_global_attribute3
              AND  nvl(start_date_active,sysdate) <= sysdate
              AND  nvl(end_date_active,sysdate) >= sysdate
              AND  enabled_flag = 'Y';
         EXCEPTION

           WHEN OTHERS THEN
             jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                              p_parent_id,
                              'INVALID_GLOBAL_ATTR3',
                              p_default_last_updated_by,
                              p_default_last_update_login,
                              p_calling_sequence);
             p_current_invoice_status := 'N';

         END;
      END IF; -- p_global_attribute3 is not null

      -- Validation for Invoice Class

      IF (p_global_attribute4 IS NOT NULL) THEN
         BEGIN
           SELECT 'X'
             INTO value_exists
             FROM fnd_lookups
            WHERE  lookup_type =  'JLBR_INVOICE_CLASS'
              AND  lookup_code = p_global_attribute4
              AND  nvl(start_date_active,sysdate) <= sysdate
              AND  nvl(end_date_active,sysdate) >= sysdate
              AND  enabled_flag = 'Y';
         EXCEPTION

           WHEN OTHERS THEN
             jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                              p_parent_id,
                              'INVALID_GLOBAL_ATTR4',
                              p_default_last_updated_by,
                              p_default_last_update_login,
                              p_calling_sequence);
             p_current_invoice_status := 'N';

         END;
      END IF; -- p_global_attribute4 is not null

      -- Format for ICMS Base Amount

      /* NUMBER(15,2),Numbers Only (0-9)*/
      IF (NOT jg_globe_flex_val_shared.check_format(p_global_attribute5,'N',15,2,'N','N','N','','')) THEN
                  jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                    p_parent_id,
                                    'INVALID_GLOBAL_ATTR5',
                                    p_default_last_updated_by,
                                    p_default_last_update_login,
                                    p_calling_sequence);
        p_current_invoice_status := 'N';
      END IF;

      -- Validation for ICMS Name

      -- Bug # 955006
      -- irani 10/15/99

      IF (p_global_attribute6 IS NOT NULL) THEN

         BEGIN
           SELECT invoice_date
             INTO p_val_date
             FROM ap_invoices_interface
            WHERE invoice_id = p_parent_id;
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
                Null;
         END;

         BEGIN
           SELECT 'X'
             INTO value_exists
             FROM ap_tax_codes
            WHERE  tax_type =  'ICMS'
              AND  name = p_global_attribute6
              AND nvl(start_date,p_val_date) <= p_val_date
              AND nvl(inactive_date,p_val_date+1) > p_val_date
              AND nvl(enabled_flag,'Y') = 'Y';
         EXCEPTION

           WHEN OTHERS THEN
             jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                              p_parent_id,
                              'INVALID_GLOBAL_ATTR6',
                              p_default_last_updated_by,
                              p_default_last_update_login,
                              p_calling_sequence);
             p_current_invoice_status := 'N';

         END;
      END IF; -- p_global_attribute6 is not null

      -- Format for ICMS Amount

      /* NUMBER(15,2),Numbers Only (0-9)*/
      IF (NOT jg_globe_flex_val_shared.check_format(p_global_attribute7,'N',15,2,'N','N','N','','')) THEN
                  jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                    p_parent_id,
                                    'INVALID_GLOBAL_ATTR7',
                                    p_default_last_updated_by,
                                    p_default_last_update_login,
                                    p_calling_sequence);
        p_current_invoice_status := 'N';
      END IF;

      -- Format for IPI Amount

      /* NUMBER(15,2),Numbers Only (0-9)*/
      IF (NOT jg_globe_flex_val_shared.check_format(p_global_attribute8,'N',15,2,'N','N','N','','')) THEN
                  jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                    p_parent_id,
                                    'INVALID_GLOBAL_ATTR8',
                                    p_default_last_updated_by,
                                    p_default_last_update_login,
                                    p_calling_sequence);
        p_current_invoice_status := 'N';
      END IF;

      -- Format for Withholding Base Amount

      /* NUMBER(15,2)*/
      IF (NOT jg_globe_flex_val_shared.check_format(p_global_attribute9,'N',15,2,'Y','N','N','','')) THEN
                  jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                    p_parent_id,
                                    'INVALID_GLOBAL_ATTR9',
                                    p_default_last_updated_by,
                                    p_default_last_update_login,
                                    p_calling_sequence);
        p_current_invoice_status := 'N';
      END IF;

      -- Validation for Consolidated Invoice Number (Should be NULL at this point)

      IF (p_global_attribute10 IS NOT NULL) THEN
             jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                              p_parent_id,
                              'INVALID_GLOBAL_ATTR10',
                              p_default_last_updated_by,
                              p_default_last_update_login,
                              p_calling_sequence);
             p_current_invoice_status := 'N';

      END IF; -- p_global_attribute10 is not null


     -- Validate the rest of the Global Attributes be NULL

         IF ((p_global_attribute11  IS NOT NULL) OR
          (p_global_attribute12  IS NOT NULL) OR
          (p_global_attribute13  IS NOT NULL) OR
          (p_global_attribute14  IS NOT NULL) OR
          (p_global_attribute15  IS NOT NULL) OR
          (p_global_attribute16  IS NOT NULL) OR
          (p_global_attribute17  IS NOT NULL) OR
          (p_global_attribute18  IS NOT NULL) OR
          (p_global_attribute19  IS NOT NULL) OR
          (p_global_attribute20 IS NOT NULL))
     THEN
        jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                          p_parent_id,
                          'GLOBAL_ATTR_VALUE_FOUND',
                          p_default_last_updated_by,
                          p_default_last_update_login,
                          p_calling_sequence);
             p_current_invoice_status := 'N';
    END IF;

  END jl_br_apxiisim_invoices_folder;

  -------------------------------------------------------------------------------
  --    Following segments are defined for Brazilian Invoice Lines Interface
  -------------------------------------------------------------------------------
  -- No. Name                   Column             Value Set                Required

  -- --- -------------------    ------------------ ------------------------ -------
  --  1  Operation Fiscal Code  GLOBAL_ATTRIBUTE1  JLBR_AP_CFO_CODE         No
  --------------------------------------------------------------------------------
  -- This procedure validates the information in the GA 1
  -- in the invoice Line for Brazil.
  --
   PROCEDURE jl_br_apxiisim_lines_folder
     (p_parent_id                       IN    NUMBER,
      p_line_type_lookup_code           IN    VARCHAR2,
      p_default_last_updated_by         IN    NUMBER,
      p_default_last_update_login       IN    NUMBER,
      p_global_attribute1               IN    VARCHAR2,
      p_global_attribute2               IN    VARCHAR2,
      p_global_attribute3               IN    VARCHAR2,
      p_global_attribute4               IN    VARCHAR2,
      p_global_attribute5               IN    VARCHAR2,
      p_global_attribute6               IN    VARCHAR2,
      p_global_attribute7               IN    VARCHAR2,
      p_global_attribute8               IN    VARCHAR2,
      p_global_attribute9               IN    VARCHAR2,
      p_global_attribute10              IN    VARCHAR2,
      p_global_attribute11              IN    VARCHAR2,
      p_global_attribute12              IN    VARCHAR2,
      p_global_attribute13              IN    VARCHAR2,
      p_global_attribute14              IN    VARCHAR2,
      p_global_attribute15              IN    VARCHAR2,
      p_global_attribute16              IN    VARCHAR2,
      p_global_attribute17              IN    VARCHAR2,
      p_global_attribute18              IN    VARCHAR2,
      p_global_attribute19              IN    VARCHAR2,
      p_global_attribute20              IN    VARCHAR2,
      p_current_invoice_status          OUT NOCOPY   VARCHAR2,
      p_calling_sequence                IN    VARCHAR2) IS

  value_exists   VARCHAR2(1);

  BEGIN
     -- Validation for Operation Fiscal Code

     IF (p_global_attribute1 IS NOT NULL) THEN
         BEGIN
           SELECT 'X'
             INTO value_exists
             FROM jl_br_ap_operations
            WHERE p_line_type_lookup_code = 'ITEM'
              AND CFO_CODE = p_global_attribute1;
         EXCEPTION
           WHEN OTHERS THEN
             jg_globe_flex_val_shared.insert_rejections('AP_INVOICE_LINES_INTERFACE',
                             p_parent_id,
                              'INVALID_GLOBAL_ATTR1',
                              p_default_last_updated_by,
                              p_default_last_update_login,
                              p_calling_sequence);
              p_current_invoice_status := 'N';
         END;
       END IF; -- p_global_attribute1 is not null

       -- Validate the rest of the Global Attributes be NULL

       IF ((p_global_attribute2   IS NOT NULL) OR
           (p_global_attribute3   IS NOT NULL) OR
           (p_global_attribute4   IS NOT NULL) OR
           (p_global_attribute5   IS NOT NULL) OR
           (p_global_attribute6   IS NOT NULL) OR
           (p_global_attribute7   IS NOT NULL) OR
           (p_global_attribute8   IS NOT NULL) OR
           (p_global_attribute9   IS NOT NULL) OR
           (p_global_attribute10  IS NOT NULL) OR
           (p_global_attribute11  IS NOT NULL) OR
           (p_global_attribute12  IS NOT NULL) OR
           (p_global_attribute13  IS NOT NULL) OR
           (p_global_attribute14  IS NOT NULL) OR
           (p_global_attribute15  IS NOT NULL) OR
           (p_global_attribute16  IS NOT NULL) OR
           (p_global_attribute17  IS NOT NULL) OR
           (p_global_attribute18  IS NOT NULL) OR
           (p_global_attribute19  IS NOT NULL) OR
           (p_global_attribute20  IS NOT NULL))
          THEN
        jg_globe_flex_val_shared.insert_rejections('AP_INVOICE_LINES_INTERFACE',
                                           p_parent_id,
                                         'GLOBAL_ATTR_VALUE_FOUND',
                                         p_default_last_updated_by,
                                       p_default_last_update_login,
                                          p_calling_sequence);
                p_current_invoice_status := 'N';
       END IF;
  END jl_br_apxiisim_lines_folder;

  -- togeorge 11/22/1999
  -- Bug# 1074309
  PROCEDURE jl_br_apxiisim_val_cfo_code
     (p_parent_id                       IN    NUMBER,
      p_line_type_lookup_code           IN    VARCHAR2,
      p_default_last_updated_by         IN    NUMBER,
      p_default_last_update_login       IN    NUMBER,
      p_current_invoice_status          OUT NOCOPY   VARCHAR2,
      p_calling_sequence                IN    VARCHAR2) IS

  l_invoice_id   NUMBER;
  l_po_number  VARCHAR2(20);
  l_cfo_code  VARCHAR2(15);
  l_icms_tax_name VARCHAR2(15);
  l_icms_tax_amount VARCHAR2(15);
  l_exists  NUMBER;
  BEGIN
     BEGIN
      SELECT invoice_id,po_number
 INTO l_invoice_id,l_po_number
 FROM ap_invoice_lines_interface
       WHERE invoice_line_id = p_parent_id;
     EXCEPTION
      WHEN OTHERS THEN
       null;
     END;
     IF l_po_number is null THEN --then it is a nomatch case
        BEGIN
  SELECT global_attribute2,global_attribute6,global_attribute7
    INTO l_cfo_code,l_icms_tax_name,l_icms_tax_amount
    FROM ap_invoices_interface
          WHERE invoice_id = l_invoice_id;
 EXCEPTION
  WHEN OTHERS THEN
   null;
 END;
        IF l_icms_tax_name IS NOT NULL OR l_icms_tax_amount IS NOT NULL THEN
    IF l_cfo_code IS NULL THEN
       BEGIN
               SELECT DISTINCT 1
                 INTO l_exists
                 FROM ap_interface_rejections
                 WHERE parent_id=l_invoice_id
                   AND parent_table = 'AP_INVOICES_INTERFACE'
                   AND REJECT_LOOKUP_CODE = 'INVALID_GLOBAL_ATTR2';
              EXCEPTION
               WHEN NO_DATA_FOUND THEN
                jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                             l_invoice_id,
                              'INVALID_GLOBAL_ATTR2',
                              p_default_last_updated_by,
                              p_default_last_update_login,
                              p_calling_sequence);
              END;
              p_current_invoice_status := 'N';
    END IF;
 END IF;
     END IF;

  END jl_br_apxiisim_val_cfo_code;

--=========================================================================
-- This procedure validates address attribute columns From Customer Interface
-- table (RA_CUSTOMERS_INTERFACE) for specific Brazilian requirements.
-- IF any validation fails, this procedure writes the error code
-- in the interface_status column of RA_CUSTOMERS_INTERFACE
--========================================================================
Procedure jl_br_arxcudci_additional
(   p_glob_attr_set1        IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set2        IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set3        IN jg_globe_flex_val_shared.GdfRec,
    p_misc_prod_arg        IN jg_globe_flex_val_shared.GenRec,
    p_record_status        OUT NOCOPY   VARCHAR2)
IS
l_inscription_type    varchar2(1);
l_inscription_number  varchar2(9);
l_inscription_branch  varchar2(4);
l_inscription_digit   varchar2(2);
l_errbuf              varchar2(30);
l_retcode             number;
l_num_check           number;
l_error_code          varchar2(50) DEFAULT NULL;
l_row_id              ROWID;   -- := p_misc_prod_arg.core_prod_arg2;

BEGIN
  l_row_id    := p_misc_prod_arg.core_prod_arg2;

/* Check inscription Number */
IF p_glob_attr_set2.global_attribute2 is not null THEN

   /* Get the inscription type code */
   l_inscription_type  := substr(p_glob_attr_set2.global_attribute2,1,1);
   l_inscription_number := substr(p_glob_attr_set2.global_attribute3,1,9);
   l_inscription_branch := substr(p_glob_attr_set2.global_attribute4,1,4);
   l_inscription_digit  := substr(p_glob_attr_set2.global_attribute5,1,2);

   BEGIN
     select to_number(l_inscription_type)
     into   l_num_check
     from   dual;
   EXCEPTION WHEN INVALID_NUMBER OR VALUE_ERROR THEN
            l_error_code := l_error_code||'n3,';
   END;
   IF l_error_code is NULL THEN
     IF l_inscription_type = '1' OR
        l_inscription_type = '2' THEN
        BEGIN
          select to_number(l_inscription_number)
          into   l_num_check
          from   dual;
          EXCEPTION WHEN INVALID_NUMBER OR VALUE_ERROR  THEN
            l_error_code := l_error_code||'n4,';
        END;

        BEGIN
          select to_number(l_inscription_branch)
          into   l_num_check
          from   dual;
          EXCEPTION WHEN INVALID_NUMBER OR VALUE_ERROR THEN
            l_error_code := l_error_code ||'n5,';
        END;

        BEGIN
          select to_number(l_inscription_digit)
          into   l_num_check
          from   dual;
          EXCEPTION WHEN INVALID_NUMBER OR VALUE_ERROR THEN
            l_error_code := l_error_code ||'n6,';
        END;
      END IF;
   END IF;
   IF (l_error_code is null)   THEN
       jl_br_inscription_number.validate_inscription_number(
                l_inscription_type,
                l_inscription_number,
                l_inscription_branch,
                l_inscription_digit,
                l_errbuf,
                l_retcode);

       IF l_retcode <> 0  THEN        /* Validation of inscription number failed */
          IF l_errbuf = 'CGC_INSCRIPTION_NUMBER_ERR' OR
             l_errbuf = 'CPF_INSCRIPTION_NUMBER_ERR' THEN
             l_error_code := l_error_code ||'n6,';
          ELSIF l_errbuf = 'CPF_INSCRIPTION_BRANCH_ERR' THEN
              l_error_code := l_error_code ||'n5,';
          ELSIF l_errbuf = 'INSCRIPTION_TYPE_ERR' THEN
       l_error_code := l_error_code ||'n3,';
          END IF;

       END IF;

   END IF;

ELSE /* There is no inscription type */
     l_error_code := l_error_code ||'n3,';
END IF;

--Call procedure to write the error codes to interface table
IF l_error_code IS NULL THEN
   p_record_status := 'S';
ELSE
   p_record_status := 'E';
   jg_globe_flex_val_shared.update_interface_status
   (l_row_id,
    'RA_CUSTOMERS_INTERFACE',
    l_error_code,
    p_record_status);
END IF;

END;

--=========================================================================
-- This procedure validates the customer profile attribute columns From
-- Customer Interface table (RA_CUSTOMERS_INTERFACE) for specific
-- Brazilian requirements. IF any validation fails, this procedure writes
--the error code in the Interface status column of RA_CUSTOMER_PROFILES_
--INTERFACE
--========================================================================+

PROCEDURE jl_br_customer_profiles
(   p_glob_attr_set1        IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set2        IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set3        IN jg_globe_flex_val_shared.GdfRec,
    p_misc_prod_arg        IN jg_globe_flex_val_shared.GenRec,
    p_record_status        OUT NOCOPY VARCHAR2)
IS

dummy_code NUMBER;
l_error_code  varchar2(50);  -- :='';
l_row_id  ROWID;             -- := p_misc_prod_arg.core_prod_arg2;

BEGIN
l_error_code  :='';
l_row_id      := p_misc_prod_arg.core_prod_arg2;

--Check Remit_protest_instructions
IF p_glob_attr_set2.global_attribute1 IS NOT NULL THEN
  BEGIN
    SELECT 1
    INTO dummy_code
    FROM fnd_lookups
    WHERE lookup_code=p_glob_attr_set2.global_attribute1
    AND  lookup_type = 'YES_NO'
    AND NVL(START_DATE_ACTIVE,SYSDATE) <= SYSDATE
    AND NVL(END_DATE_ACTIVE,SYSDATE) >= SYSDATE
    AND ENABLED_FLAG = 'Y';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_error_code := l_error_code||'r4,';
  END;
ELSE
  l_error_code := l_error_code||'r4,';
END IF;

--Check Remit interest instructions
IF p_glob_attr_set2.global_attribute2 IS NOT NULL THEN
  BEGIN
    SELECT 1
    INTO dummy_code
    FROM fnd_lookups
    WHERE lookup_code=p_glob_attr_set2.global_attribute2
    AND  lookup_type = 'YES_NO'
    AND NVL(START_DATE_ACTIVE,SYSDATE) <= SYSDATE
    AND NVL(END_DATE_ACTIVE,SYSDATE) >= SYSDATE
    AND ENABLED_FLAG = 'Y';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_error_code :=l_error_code||'r5,';
  END;
ELSE
  l_error_code := l_error_code||'r5,';
END IF;


IF l_error_code IS NULL THEN
   p_record_status := 'S';
ELSE
   p_record_status := 'E';
   jg_globe_flex_val_shared.update_interface_status
   (l_row_id,
    'RA_CUSTOMER_PROFILES_INTERFACE',
    l_error_code,
    p_record_status);
END IF;
END;

--=========================================================================
-- This procedure validates address attribute column From Customer Interface
-- table (RA_CUSTOMERS_INTERFACE) for LTE requirements.
-- IF any validation fails, this procedure writes the error code
-- in the interface_status column of RA_CUSTOMERS_INTERFACE
--========================================================================
procedure jl_zz_ar_tx_arxcudci_address
(   p_glob_attr_set1        IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set2        IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set3        IN jg_globe_flex_val_shared.GdfRec,
    p_misc_prod_arg        IN jg_globe_flex_val_shared.GenRec,
    p_record_status        OUT NOCOPY   VARCHAR2) IS

  l_error_code            varchar2(50) DEFAULT NULL;
  l_row_id                ROWID;        -- := p_misc_prod_arg.core_prod_arg2;
  l_tax_method            VARCHAR2(30);
  l_tax_rule_set          VARCHAR2(30);
  l_dummy                 NUMBER;

BEGIN
  l_row_id     := p_misc_prod_arg.core_prod_arg2;
  l_tax_method := NULL;

  BEGIN
    -- Bug 3761529
    SELECT tax_method_code
    INTO   l_tax_method
    FROM   zx_product_options;

    SELECT substr(global_attribute13,1,30)
    INTO   l_tax_rule_set
    FROM   ar_system_parameters;
  EXCEPTION
    WHEN OTHERS THEN
         l_tax_method := NULL;
  END;

  IF l_tax_method = 'LTE' THEN

     /* Check contributor Condition Class Value */

     IF p_glob_attr_set2.global_attribute8 is not null THEN

        l_dummy := 0;
        BEGIN
          SELECT count(*)
          INTO   l_dummy
          FROM   jl_zz_ar_tx_att_cls tac,
                 jl_zz_ar_tx_categ tc
          WHERE  tac.tax_attr_class_code = p_glob_attr_set2.global_attribute8
          AND    tac.tax_attr_class_type = 'CONTRIBUTOR_CLASS'
          AND    tac.enabled_flag = 'Y'
          AND    tac.tax_category_id = tc.tax_category_id
          AND    tc.tax_rule_set = l_tax_rule_set;
        EXCEPTION
          WHEN OTHERS THEN
               l_dummy := 0;
        END;

        IF l_dummy = 0 THEN
           l_error_code := l_error_code ||'n9,';
        END IF;

     ELSE
        l_error_code := l_error_code ||'n9,';
     END IF;

     /* Value for 'Use Cust Site Profile' should be 'N'.
        Currently NULL value is interpreted as 'Y' by Latin Tax Engine to
        support existing records. New records in Customer Site must have
        a value of 'Y'/'N' for global_attribute9. If value is 'Y', Tax
        Engine evaluates JL_ZZ_AR_TX_CUS_CLS for applicability and evaluates
        JL_ZZ_AR_TX_ATT_CLS if value is 'N'.
        This change was implemented as part of Bugfix #1783986     */

     IF NVL(p_glob_attr_set2.global_attribute9,'Y') <> 'N' THEN
        l_error_code := l_error_code || 'n0,';
     END IF;

  END IF;

  -- Call procedure to write the error codes to interface table

  IF l_error_code IS NULL THEN
     p_record_status := 'S';
  ELSE
     p_record_status := 'E';
     jg_globe_flex_val_shared.update_interface_status (l_row_id,
           'RA_CUSTOMERS_INTERFACE',
           l_error_code,
           p_record_status);
  END IF;

END jl_zz_ar_tx_arxcudci_address;


  -------------------------------------------------------------------------------
  --    Following segments are defined for Chile Invoice Interface
  -------------------------------------------------------------------------------
  -- No. Name                Column             Value Set                  Req.
  -- --- ------------------- ------------------ -------------------------- ------
  --  1  Document Type       GLOBAL_ATTRIBUTE19 JLCL_AP_DOCUMENT_TYPE_IG   No
  --------------------------------------------------------------------------------
  --
  -- This procedure validates the information in the GA19
  -- in the invoice header for Chile.
  --

  PROCEDURE jl_cl_apxiisim_invoices_folder
     (p_parent_id                       IN    NUMBER,
      p_default_last_updated_by         IN    NUMBER,
      p_default_last_update_login       IN    NUMBER,
      p_global_attribute1               IN    VARCHAR2,
      p_global_attribute2               IN    VARCHAR2,
      p_global_attribute3               IN    VARCHAR2,
      p_global_attribute4               IN    VARCHAR2,
      p_global_attribute5               IN    VARCHAR2,
      p_global_attribute6               IN    VARCHAR2,
      p_global_attribute7               IN    VARCHAR2,
      p_global_attribute8               IN    VARCHAR2,
      p_global_attribute9               IN    VARCHAR2,
      p_global_attribute10              IN    VARCHAR2,
      p_global_attribute11              IN    VARCHAR2,
      p_global_attribute12              IN    VARCHAR2,
      p_global_attribute13              IN    VARCHAR2,
      p_global_attribute14              IN    VARCHAR2,
      p_global_attribute15              IN    VARCHAR2,
      p_global_attribute16              IN    VARCHAR2,
      p_global_attribute17              IN    VARCHAR2,
      p_global_attribute18              IN    VARCHAR2,
      p_global_attribute19              IN    VARCHAR2,
      p_global_attribute20              IN    VARCHAR2,
      p_current_invoice_status          OUT NOCOPY   VARCHAR2,
      p_calling_sequence                IN    VARCHAR2) IS

  value_exists   VARCHAR2(1);

  BEGIN

      -- Validation for Document Type

      IF (p_global_attribute19 IS NOT NULL) THEN
         BEGIN
           SELECT 'X'
             INTO value_exists
             FROM fnd_lookups
            WHERE  lookup_type =  'JLCL_AP_DOCUMENT_TYPE'
              AND  lookup_code = p_global_attribute19
              AND  nvl(start_date_active,sysdate) <= sysdate
              AND  nvl(end_date_active,sysdate) >= sysdate
              AND  enabled_flag = 'Y';
         EXCEPTION

           WHEN OTHERS THEN
              jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                              p_parent_id,
                              'INVALID_GLOBAL_ATTR19',
                              p_default_last_updated_by,
                              p_default_last_update_login,
                              p_calling_sequence);
                   p_current_invoice_status := 'N';

         END;
      END IF; -- p_global_attribute19 is not null


      -- Validate the rest of the Global Attributes be NULL

      IF ((p_global_attribute1   IS NOT NULL) OR
          (p_global_attribute2   IS NOT NULL) OR
          (p_global_attribute3   IS NOT NULL) OR
          (p_global_attribute4   IS NOT NULL) OR
          (p_global_attribute5   IS NOT NULL) OR
          (p_global_attribute6   IS NOT NULL) OR
          (p_global_attribute7   IS NOT NULL) OR
          (p_global_attribute8   IS NOT NULL) OR
          (p_global_attribute9   IS NOT NULL) OR
          (p_global_attribute10  IS NOT NULL) OR
          (p_global_attribute11  IS NOT NULL) OR
          (p_global_attribute12  IS NOT NULL) OR
          (p_global_attribute13  IS NOT NULL) OR
          (p_global_attribute14  IS NOT NULL) OR
          (p_global_attribute15  IS NOT NULL) OR
          (p_global_attribute16  IS NOT NULL) OR
          (p_global_attribute17  IS NOT NULL) OR
          (p_global_attribute18  IS NOT NULL) OR
          (p_global_attribute20  IS NOT NULL))
      THEN
        jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                           p_parent_id,
                                         'GLOBAL_ATTR_VALUE_FOUND',
                                         p_default_last_updated_by,
                                       p_default_last_update_login,
                                          p_calling_sequence);
                p_current_invoice_status := 'N';
      END IF;

  END jl_cl_apxiisim_invoices_folder;

END JL_INTERFACE_VAL;

/
