--------------------------------------------------------
--  DDL for Package Body JG_GLOBE_FLEX_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_GLOBE_FLEX_VAL" AS
/* $Header: jggdfvb.pls 120.16.12010000.5 2010/02/19 13:52:04 rsaini ship $ */


  ------------------------------------------------------------------
  --                                                             ---
  --                      PRIVATE section                        ---
  --                                                             ---
  ------------------------------------------------------------------

  --
  -- Table Type Defintion to Store Flexfield Name and Context Code.
  --
  TYPE ContextList IS TABLE OF VARCHAR2(70) INDEX BY BINARY_INTEGER;

  --
  -- Global Variable Definition
  --
  g_context_tab  ContextList;              -- Context Code Table
  g_table_size   BINARY_INTEGER DEFAULT 0; -- Table Size

  --
  -- Find
  --
  -- PURPOSE
  -- Find index of flexfield and context code combination.
  --
  -- RETURN
  -- Table index if found, g_table_size if not found.
  --
--  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AR_ENABLE_DEBUG_OUTPUT'), 'N');

-- Bug 8859419 Start

   G_CURRENT_RUNTIME_LEVEL     NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   G_LEVEL_UNEXPECTED CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
   G_LEVEL_ERROR      CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
   G_LEVEL_EXCEPTION  CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
   G_LEVEL_EVENT      CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
   G_LEVEL_PROCEDURE  CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
   G_LEVEL_STATEMENT  CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
   G_MODULE_NAME      CONSTANT VARCHAR2(50) := 'JG.PLSQL.JG_GLOBE_FLEX_VAL';

-- Bug 8859419 End

  FUNCTION find
       (p_flexfield_and_context IN VARCHAR2) RETURN BINARY_INTEGER IS

    l_flex_and_context  VARCHAR2(70);
    l_table_index       BINARY_INTEGER;
    l_found             BOOLEAN;

  BEGIN
    l_flex_and_context := p_flexfield_and_context;
    l_table_index := 0;
    l_found     := FALSE;

    WHILE (l_table_index < g_table_size) AND (NOT l_found) LOOP
      IF g_context_tab(l_table_index) = l_flex_and_context THEN
        l_found := TRUE;

      ELSE
        l_table_index := l_table_index + 1;
      END IF;
    END LOOP;

    RETURN l_table_index;

  END find;

  --
  -- Is_Defined
  --
  -- PURPOSE
  -- Check if a context code is defined.
  --
  -- RETURN
  -- TRUE if the context code is defined.
  --
  FUNCTION is_defined
       (p_flexfield_name   IN  VARCHAR2,
        p_context_code     IN  VARCHAR2) RETURN BOOLEAN IS

    l_context_code   VARCHAR2(30);

    CURSOR c_context IS
      SELECT fc.descriptive_flex_context_code
      FROM fnd_descr_flex_contexts fc
      WHERE fc.application_id = 7003
      AND fc.descriptive_flex_context_code = p_context_code
      AND fc.descriptive_flexfield_name = p_flexfield_name
      AND fc.enabled_flag = 'Y';

  BEGIN
    OPEN c_context;
    FETCH c_context INTO l_context_code;
    IF (c_context%NOTFOUND) THEN
      RETURN  FALSE;
    ELSE
      RETURN  TRUE;

    END IF;

    CLOSE c_context;

  END is_defined;

  --
  -- Check_Mixed_Countries():
  --
  -- PURPOSE
  -- Check if a context code is valid.
  --
  -- RETURN
  --  Error Code if a context code is invalid.
  --
  FUNCTION check_mixed_countries
       (p_category1        IN VARCHAR2,
        p_category2        IN VARCHAR2,
        p_category3        IN VARCHAR2) RETURN VARCHAR2 IS

    l_country1    VARCHAR2(5);
    l_country2    VARCHAR2(5);
    l_country3    VARCHAR2(5);
    l_errcode     VARCHAR2(3);

  BEGIN
    l_country1    := SUBSTRB(p_category1,1,5);
    l_country2    := SUBSTRB(p_category2,1,5);
    l_country3    := SUBSTRB(p_category3,1,5);
    l_errcode     := NULL;
    --
    -- When 2 or more out of 3 countries are null:

    --
    IF (l_country1 IS NULL AND l_country2 IS NULL) OR
       (l_country1 IS NULL AND l_country3 IS NULL) OR
       (l_country2 IS NULL AND l_country3 IS NULL)
    THEN
      RETURN (l_errcode);
    END IF;
    --
    -- When one or none out of 3 countries is null:
    --
    IF (l_country1 = l_country2 AND l_country1 = l_country3) OR
       (l_country1 = l_country2 AND l_country3 IS NULL) OR
       (l_country1 = l_country3 AND l_country2 IS NULL) OR
       (l_country2 = l_country3 AND l_country1 IS NULL)
    THEN
        RETURN (l_errcode);
    END IF;

    --
    -- Return the error code in case of invalid context code
    --
    l_errcode := 't4,';
    RETURN (l_errcode);

  END check_mixed_countries;

  ---------------------------------------------------------------------------
  --    CHECK_ATTR_EXISTS():
  --       Check if GLOBAL_ATTRIBUTE(n) has NOT NULL value to indicate if
  --       global flexfield has a value.
  ---------------------------------------------------------------------------
  FUNCTION check_attr_exists
       (p_global_attribute_category  IN    VARCHAR2,
        p_global_attribute1          IN    VARCHAR2,
        p_global_attribute2          IN    VARCHAR2,
        p_global_attribute3          IN    VARCHAR2,
        p_global_attribute4          IN    VARCHAR2,
        p_global_attribute5          IN    VARCHAR2,
        p_global_attribute6          IN    VARCHAR2,
        p_global_attribute7          IN    VARCHAR2,
        p_global_attribute8          IN    VARCHAR2,
        p_global_attribute9          IN    VARCHAR2,
        p_global_attribute10         IN    VARCHAR2,
        p_global_attribute11         IN    VARCHAR2,
        p_global_attribute12         IN    VARCHAR2,
        p_global_attribute13         IN    VARCHAR2,
        p_global_attribute14         IN    VARCHAR2,
        p_global_attribute15         IN    VARCHAR2,
        p_global_attribute16         IN    VARCHAR2,
        p_global_attribute17         IN    VARCHAR2,
        p_global_attribute18         IN    VARCHAR2,
        p_global_attribute19         IN    VARCHAR2,
        p_global_attribute20         IN    VARCHAR2) RETURN BOOLEAN IS

  BEGIN
    IF (p_global_attribute1  IS NOT NULL) or
       (p_global_attribute2  IS NOT NULL) or
       (p_global_attribute3  IS NOT NULL) or
       (p_global_attribute4  IS NOT NULL) or
       (p_global_attribute5  IS NOT NULL) or
       (p_global_attribute6  IS NOT NULL) or
       (p_global_attribute7  IS NOT NULL) or
       (p_global_attribute8  IS NOT NULL) or
       (p_global_attribute9  IS NOT NULL) or
       (p_global_attribute10 IS NOT NULL) or
       (p_global_attribute11 IS NOT NULL) or
       (p_global_attribute12 IS NOT NULL) or
       (p_global_attribute13 IS NOT NULL) or
       (p_global_attribute14 IS NOT NULL) or
       (p_global_attribute15 IS NOT NULL) or
       (p_global_attribute16 IS NOT NULL) or
       (p_global_attribute17 IS NOT NULL) or
       (p_global_attribute18 IS NOT NULL) or
       (p_global_attribute19 IS NOT NULL) or
       (p_global_attribute20 IS NOT NULL) THEN

      IF p_global_attribute_category IS NOT NULL THEN  -- Check if at least one
         return(TRUE);                                 -- attributes is NOT NULL
      ELSE
         return(FALSE);
      END IF;

    ELSE
        return(TRUE);

    END IF;
  END check_attr_exists;

  --
  -- Modified version of check_attr_exists
  --
  FUNCTION check_attr_exists
       (p_glob_attr_set IN  jg_globe_flex_val_shared.GdfRec) RETURN BOOLEAN IS

  BEGIN
    IF (p_glob_attr_set.global_attribute1  IS NOT NULL) or
       (p_glob_attr_set.global_attribute2  IS NOT NULL) or
       (p_glob_attr_set.global_attribute3  IS NOT NULL) or
       (p_glob_attr_set.global_attribute4  IS NOT NULL) or
       (p_glob_attr_set.global_attribute5  IS NOT NULL) or
       (p_glob_attr_set.global_attribute6  IS NOT NULL) or
       (p_glob_attr_set.global_attribute7  IS NOT NULL) or
       (p_glob_attr_set.global_attribute8  IS NOT NULL) or
       (p_glob_attr_set.global_attribute9  IS NOT NULL) or
       (p_glob_attr_set.global_attribute10 IS NOT NULL) or
       (p_glob_attr_set.global_attribute11 IS NOT NULL) or
       (p_glob_attr_set.global_attribute12 IS NOT NULL) or
       (p_glob_attr_set.global_attribute13 IS NOT NULL) or
       (p_glob_attr_set.global_attribute14 IS NOT NULL) or
       (p_glob_attr_set.global_attribute15 IS NOT NULL) or
       (p_glob_attr_set.global_attribute16 IS NOT NULL) or
       (p_glob_attr_set.global_attribute17 IS NOT NULL) or
       (p_glob_attr_set.global_attribute18 IS NOT NULL) or
       (p_glob_attr_set.global_attribute19 IS NOT NULL) or
       (p_glob_attr_set.global_attribute20 IS NOT NULL) THEN

      IF p_glob_attr_set.global_attribute_category IS NOT NULL THEN
         return(TRUE);
      ELSE
         return(FALSE);
      END IF;

    ELSE
        return(TRUE);

    END IF;
  END check_attr_exists;
  --
  -- End of modification
  --

  ---------------------------------------------------------------------------
  --  CHECK_CONTEXT_CODE():
  --     Check if specified GLOBAL_ATTRIBUTE_CATEGORY has a valid context
  --     code definition of the flexfield.
  --     P_CALLING_PROGRAM_NAME is the program name from which this procedure
  --     The logic is based on the assumption that before the invoices are
  --     uploaded from the flat file, the global_attribute columns are mapped
  --     correctly as per the pre seeded data for the global flexfields.
  --
  --     There is no global flexfield in Invoice Gateway of R11i for Korea,
  --     China, and Canada, so comment out for their context.
  ---------------------------------------------------------------------------
  FUNCTION check_context_code(
      p_calling_program_name    IN    VARCHAR2,
      p_context_code            IN    VARCHAR2) RETURN BOOLEAN IS

    --
    -- Following variables are used in AR validation
    -- Note: Default value of l_flexfield_name is p_calling_program_name.
    --       It looks confusing but in case of AR Flexfield name is passed to
    --       p_calling_program_name
    --
    l_table_index      BINARY_INTEGER;
    l_defined          BOOLEAN;
    l_flexfield_name   VARCHAR2(40);
    l_context_code     VARCHAR2(30);
    l_flex_and_context VARCHAR2(70);


  BEGIN
    l_flexfield_name   := p_calling_program_name;
    l_context_code     := p_context_code;
    --
    -- AP global flexflield contexts.
    --
    IF p_calling_program_name = 'APXIIMPT' THEN --Invoice Gatewayvalidation prog
      IF p_context_code IN ('JA.TH.APXIISIM.INVOICES_INTF',
                            'JA.TW.APXIISIM.INVOICES_FOLDER',
                            'JA.SG.APXIISIM.INVOICES_FOLDER',
    --                      'JA.KR.APXIISIM.INVOICES_FOLDER',
    --                      'JA.CN.APXIISIM.INVOICES_FOLDER',
    --                      'JA.KR.APXIISIM.LINES_FOLDER',
    --                      'JA.CA.APXIISIM.LINES_FOLDER',
                            'JE.BE.APXIISIM.EFT',
                            'JE.CH.APXIISIM.DTA',
                            'JE.CH.APXIISIM.SAD',
       'JE.DK.APXIISIM.EDI_INFO',
                            'JE.DK.APXIISIM.GIRO_DOMESTIC',
                            'JE.DK.APXIISIM.GIRO_FOREIGN',
                            'JE.DK.APXIISIM.UNIT_DOMESTIC',
                            'JE.DK.APXIISIM.UNIT_FOREIGN',
                            'JE.ES.APXIISIM.MODELO349',
                            'JE.ES.APXIISIM.MODELO347',
                            'JE.ES.APXIISIM.MODELO347PR',
                            'JE.ES.APXIISIM.OTHER',
                            'JE.FI.APXIISIM.A_LOMAKE',
                            'JE.FI.APXIISIM.B_LOMAKE',
                            'JE.FI.APXIISIM.KKL_VIITE',
                            'JE.FI.APXIISIM.VAPAA_VIITE',
                            'JE.FR.APXIISIM.TAX_RULE',
                            'JE.NL.APXIISIM.FOREIGN',
                            'JE.NO.APXIISIM.NORWAY',
                            'JE.SE.APXIISIM.BANK_SISU',
                            'JE.SE.APXIISIM.BANK_UTLI',
                            'JE.SE.APXIISIM.BANK_INLAND',
                            'JE.SE.APXIISIM.POST_INLAND',
                            'JE.SE.APXIISIM.POST_UTLAND',
                            'JE.CZ.APXIISIM.INVOICE_INFO',
                            'JE.HU.APXIISIM.TAX_DATE',
                            'JE.PL.APXIISIM.INVOICE_INFO',
                          --'JE.HU.APXIISIM.STAT_CODE',
                          --'JE.PL.APXIISIM.STAT_CODE',
                            'JL.AR.APXIISIM.INVOICES_FOLDER',
                            'JL.AR.APXIISIM.LINES_FOLDER',
       'JL.CO.APXIISIM.INVOICES_FOLDER', -- Added for Bug3233307
                            'JL.CO.APXIISIM.LINES_FOLDER',
                            'JL.BR.APXIISIM.INVOICES_FOLDER',
                            'JL.BR.APXIISIM.LINES_FOLDER',
                            'JE.IT.APXIISIM.DISTRIBUTIONS',
                            'JL.CL.APXIISIM.INVOICES_FOLDER',

 		-- Added as the part of ECE Enhancement --

        	            'JE.SK.APXIISIM.INVOICE_INFO',
		            'JE.CZ.APXIISIM.FINAL',
                            'JE.HU.APXIISIM.FINAL',
                            'JE.PL.APXIISIM.FINAL',
                            'JE.SK.APXIISIM.FINAL',
                            'JE.PL.APXIISIM.INSURANCE_INFO',

       	-- Added as the part of RLP Enhancement bug 5741915 --

        --BUG:9237440 start
			    --'JE.RU.APXINWKB.XXRL_INVOICE',
			    --'JE.RU.APXINWKB.XXRL_SUM_DIF',
			    --'JE.RU.APXINWKB.XXRL_DISTRIBUT',
			    'JE.RU.APXIISIM.XXRL_INVOICE',
			    'JE.RU.APXIISIM.XXRL_SUM_DIF',
			    'JE.RU.APXIISIM.XXRL_DISTRIBUT'
	--BUG:9237440 End
                           )

      THEN
         RETURN(TRUE);
      ELSE
         RETURN(FALSE);
      END IF;

--Changed to the new HZ flexfield definitions
     /* ELSIF (p_calling_program_name = 'JG_RA_CUSTOMERS') OR
          (p_calling_program_name = 'JG_RA_ADDRESSES') OR
          (p_calling_program_name = 'JG_RA_SITE_USES') OR
          (p_calling_program_name = 'JG_AR_CUSTOMER_PROFILES') OR
          (p_calling_program_name = 'JG_AR_CUSTOMER_PROFILE_AMOUNTS')THEN
    */
    ELSIF (p_calling_program_name = 'JG_HZ_CUST_ACCOUNTS') OR
          (p_calling_program_name = 'JG_HZ_CUST_ACCT_SITES') OR
          (p_calling_program_name = 'JG_HZ_CUST_SITE_USES') OR
          (p_calling_program_name = 'JG_HZ_CUSTOMER_PROFILES') OR
          (p_calling_program_name = 'JG_HZ_CUST_PROFILE_AMTS')THEN

      --
      -- 1. Search combination of flexfield and context code in PL/SQL Table.
      -- 2. If it's not stored in PL/SQL Table,check if the combination is valid
      -- 3. If the combination is valid, add it to the PL/SQL Table and return
      --    TRUE. Otherwise, return FALSE.
      --

      --
      --  Concatenate Flexfield and Context Code  to check if
      --  the combination is valid.
      --
      l_flex_and_context := l_flexfield_name || l_context_code;

      --
      --  Search index for a context code.
      --
      l_table_index := find(l_flex_and_context);

      IF l_table_index < g_table_size THEN
        RETURN (TRUE);

      ELSE
        l_defined := is_defined(l_flexfield_name, l_context_code);
        IF (l_defined) THEN
          g_context_tab(g_table_size) := l_flexfield_name || l_context_code;
          g_table_size := g_table_size + 1;
          RETURN (TRUE);

        ELSE
          RETURN (FALSE);

        END IF;
      END IF;
    --
    -- End of AR validation.
    --

    --
    -- Other Products such as FA, etc.  ADD NEW ENTRY IF NECESSARY.
    --
    ELSE
      RETURN(FALSE);

    END IF;
  END check_context_code;

  FUNCTION check_each_gdf(p_flexfield_name   VARCHAR2,
                           p_glob_attr_set   jg_globe_flex_val_shared.GdfRec,
                           p_glob_attr_gen   jg_globe_flex_val_shared.GenRec)
 RETURN VARCHAR2 IS

 l_errcode VARCHAR2(10) DEFAULT NULL;

  BEGIN
     IF check_attr_exists(p_glob_attr_set) <> TRUE THEN
        --
        -- Store the error code to be returned
        --
                l_errcode := 'i1,';

     END IF;

     IF p_glob_attr_set.global_attribute_category IS NOT NULL THEN
        IF check_context_code(p_flexfield_name,
                       p_glob_attr_set.global_attribute_category) <> TRUE THEN
          --
          --  Concatenate the error code to be returned
          --
          -- Changed to refer to the new flexfield definitions

          --IF p_flexfield_name ='JG_RA_CUSTOMERS' THEN
           IF p_flexfield_name = 'JG_HZ_CUST_ACCOUNTS' THEN
                l_errcode := l_errcode||'i2,';

          --ELSIF p_flexfield_name = 'JG_RA_ADDRESSES' THEN
            ELSIF p_flexfield_name = 'JG_HZ_CUST_ACCT_SITES' THEN
                l_errcode := l_errcode||'n1,';

   --ELSIF p_flexfield_name = 'JG_RA_SITE_USES' THEN
          ELSIF p_flexfield_name = 'JG_HZ_CUST_SITE_USES' THEN
                l_errcode := l_errcode||'p2,';

         -- ELSIF p_flexfield_name = 'JG_AR_CUSTOMER_PROFILES' THEN
          ELSIF p_flexfield_name = 'JG_HZ_CUSTOMER_PROFILES' THEN
                l_errcode := l_errcode||'r3,';

          --ELSIF p_flexfield_name = 'JG_AR_CUSTOMER_PROFILE_AMOUNTS' THEN
          ELSIF p_flexfield_name = 'JG_HZ_CUST_PROFILE_AMTS' THEN
                l_errcode := l_errcode||'i2,';

          END IF;
       END IF;
     END IF;

  --
  -- Return the concatenated error code
  --
  return(l_errcode);

  END check_each_gdf;

  ---------------------------------------------------------------------------
  --                                                                      ---
  --                           PUBLIC section                             ---
  --                                                                      ---
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  --    REASSIGN_CONTEXT_CODE():
  --       Reassign global_attribute_category before transfering data
  --       from interface tables
  --
  -- Prod         Current Code             ->          Target Code
  ---------------------------------------------------------------------------
  --  AP    JA.CN.APXIISIM.INVOICES_FOLDER     JA.CN.APXINWKB.INVOICES
  --  AP    JA.KR.APXIISIM.INVOICES_FOLDER     JA.KR.APXINWKB.AP_INVOICES
  --  AP    JA.TH.APXIISIM.INVOICES_INTF       JA.TH.APXINWKB.INVOICES
  --  AP    JA.TW.APXIISIM.INVOICES_FOLDER     JA.TW.APXINWKB.INVOICES
  --  AP    JA.SG.APXIISIM.INVOICES_FOLDER     JA.TW.APXINWKB.INVOICES
  --  AP    JA.KR.APXIISIM.LINES_FOLDER        JA.KR.APXINWKB.INVOICE_DISTR
  --  AP    JA.CA.APXIISIM.LINES_FOLDER        JA.CA.APXINWKB.INVOICE_DISTR
  --
  --  AP    JE.BE.APXIISIM.EFT                BE.EFT Payments
  --  AP    JE.CH.APXIISIM.DTA                CH.Swiss DTA Payment
  --  AP    JE.CH.APXIISIM.SAD                CH.Swiss SAD Payment
  --  AP    JE.DK.APXIISIM.EDI_INFO           JE.DK.APXINWKB.EDI_INFO
  --  AP    JE.DK.APXIISIM.GIRO_DOMESTIC      DK.GiroBank Domestic
  --  AP    JE.DK.APXIISIM.GIRO_FOREIGN       DK.GiroBank Foreign
  --  AP    JE.DK.APXIISIM.UNIT_DOMESTIC      DK.Unitel Domestic
  --  AP    JE.DK.APXIISIM.UNIT_FOREIGN       DK.Unitel Foreign
  --  AP    JE.FI.APXIISIM.A_LOMAKE           FI.A-lomake
  --  AP    JE.FI.APXIISIM.B_LOMAKE           FI.B-lomake
  --  AP    JE.FI.APXIISIM.KKL_VIITE          FI.Konekielinen viite
  --  AP    JE.FI.APXIISIM.VAPAA_VIITE        FI.Vapaa viite
  --  AP    JE.NL.APXIISIM.FOREIGN            NL.Foreign Payments
  --  AP    JE.NO.APXIISIM.NORWAY             NO.Norway
  --  AP    JE.SE.APXIISIM.BANK_SISU          SE.Bankgiro SISU
  --  AP    JE.SE.APXIISIM.BANK_UTLI          SE.Bankgiro UTLI
  --  AP    JE.SE.APXIISIM.POST_INLAND        SE.Postgiro Inland
  --  AP    JE.SE.APXIISIM.POST_UTLAND        SE.Postgiro Utland
  --  AP    JE.SE.APXIISIM.BANK_INLAND        SE.Bankgiro Inland
  --  AP    JE.CZ.APXIISIM.INVOICE_INFO      JE.CZ.APXINWKB.INVOICE_INFO
  --  AP    JE.HU.APXIISIM.TAX_DATE          JE.HU.APXINWKB.TAX_DATE
  --  AP    JE.PL.APXIISIM.INVOICE_INFO      JE.PL.APXINWKB.INVOICE_INFO
  --  AP    JE.HU.APXIISIM.STAT_CODE         JE.HU.APXINWKB.STAT_CODE
  --  AP    JE.PL.APXIISIM.STAT_CODE         JE.PL.APXINWKB.STAT_CODE
  --  AP    JL.AR.APXIISIM.INVOICES_FOLDER   JL.AR.APXINWKB.INVOICES
  --  AP    JL.AR.APXIISIM.LINES_FOLDER      JL.AR.APXINWKB.DISTRIBUTIONS
  --  AP    JL.CO.APXIISIM.INVOICES_FOLDER   JL.CO.APXINWKB.INVOICES  -- Added for bug3233307
  --  AP    JL.CO.APXIISIM.LINES_FOLDER      JL.CO.APXINWKB.DISTRIBUTIONS
  --  AP    JL.BR.APXIISIM.INVOICES_FOLDER   JL.BR.APXINWKB.AP_INVOICES
  --  AP    JL.BR.APXIISIM.LINES_FOLDER      JL.BR.APXINWKB.D_SUM_FOLDER
  --  AP    JE.IT.APXIISIM.DISTRIBUTIONS     JE.IT.APXINWKB.DISTRIBUTIONS
  --  AP    JL.CL.APXIISIM.INVOICES_FOLDER   JL.CL.APXINWKB.AP_INVOICES

 -- Added below as part of ECE Enhancement --

  --  AP    JE.SK.APXIISIM.INVOICE_INFO      JE.SK.APXINWKB.INVOICE_INFO
  --  AP    JE.HU.APXIISIM.FINAL             JE.HU.APXINWKB.FINAL
  --  AP    JE.PL.APXIISIM.FINAL             JE.PL.APXINWKB.FINAL
  --  AP    JE.CZ.APXIISIM.FINAL         JE.CZ.APXINWKB.FINAL
  --  AP    JE.SK.APXIISIM.FINAL         JE.SK.APXINWKB.FINAL
  --  AP    JE.PL.APXIISIM.INSURANCE_INFO    JE.PL.APXINWKB.INSURANCE_INFO

  -- Added below as part of RLP Enhancement --

  --  AP    JE.RU.APXIISIM.XXRL_INVOICE      JE.RU.APXINWKB.XXRL_INVOICE
  --  AP    JE.RU.APXIISIM.XXRL_SUM_DIF	     JE.RU.APXINWKB.XXRL_SUM_DIF
  --  AP    JE.RU.APXIISIM.XXRL_DISTRIBUT    JE.RU.APXINWKB.XXRL_DISTRIBUT


  --                   <<  ADD ADDITIONAL ENTRY HERE   >>
  --
  --     There is no global flexfield in Invoice Gateway of R11i for Korea,
  --     China, and Canada, so comment out for their context.
  --
  ---------------------------------------------------------------------------
  FUNCTION reassign_context_code(
         p_global_context_code   IN OUT NOCOPY   VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    IF (p_global_context_code IS NULL) THEN
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JA.TH.APXIISIM.INVOICES_INTF') THEN
      p_global_context_code := 'JA.TH.APXINWKB.INVOICES';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JA.TW.APXIISIM.INVOICES_FOLDER') THEN
      p_global_context_code := 'JA.TW.APXINWKB.INVOICES';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JA.SG.APXIISIM.INVOICES_FOLDER') THEN
      p_global_context_code := 'JA.SG.APXINWKB.INVOICES';
      RETURN(TRUE);
  --  ELSIF (p_global_context_code = 'JA.CN.APXIISIM.INVOICES_FOLDER') THEN
  --    p_global_context_code := 'JA.CN.APXINWKB.INVOICES';
  --    RETURN(TRUE);
  --  ELSIF (p_global_context_code = 'JA.KR.APXIISIM.INVOICES_FOLDER') THEN
  --    p_global_context_code := 'JA.KR.APXINWKB.AP_INVOICES';
  --    RETURN(TRUE);
  --  ELSIF (p_global_context_code = 'JA.KR.APXIISIM.LINES_FOLDER') THEN
  --    p_global_context_code := 'JA.KR.APXINWKB.INVOICE_DISTR';
  --    RETURN(TRUE);
  --  ELSIF (p_global_context_code = 'JA.CA.APXIISIM.LINES_FOLDER') THEN
  --    p_global_context_code := 'JA.CA.APXINWKB.INVOICE_DISTR';
  --    RETURN(TRUE);

  -- Added for RLP project
  --BUG:9237440 modified the APXINWKB to APXIISIM in if condition for RU.

     ELSIF (p_global_context_code = 'JE.RU.APXIISIM.XXRL_INVOICE') THEN
       p_global_context_code := 'JE.RU.APXINWKB.XXRL_INVOICE';
       RETURN(TRUE);
     ELSIF (p_global_context_code = 'JE.RU.APXIISIM.XXRL_SUM_DIF') THEN
       p_global_context_code := 'JE.RU.APXINWKB.XXRL_SUM_DIF';
       RETURN(TRUE);
     ELSIF (p_global_context_code = 'JE.RU.APXIISIM.XXRL_DISTRIBUT') THEN
       p_global_context_code := 'JE.RU.APXINWKB.XXRL_DISTRIBUT';
       RETURN(TRUE);

    ELSIF (p_global_context_code = 'JE.BE.APXIISIM.EFT') THEN
      p_global_context_code := 'BE.EFT Payments';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JE.CH.APXIISIM.DTA') THEN
      p_global_context_code := 'CH.Swiss DTA Payment';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JE.CH.APXIISIM.SAD') THEN
      p_global_context_code := 'CH.Swiss SAD Payment';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JE.DK.APXIISIM.EDI_INFO') THEN
      p_global_context_code := 'JE.DK.APXINWKB.EDI_INFO';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JE.DK.APXIISIM.GIRO_DOMESTIC') THEN
      p_global_context_code := 'DK.GiroBank Domestic';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JE.DK.APXIISIM.GIRO_FOREIGN') THEN
      p_global_context_code := 'DK.GiroBank Foreign';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JE.DK.APXIISIM.UNIT_DOMESTIC') THEN
      p_global_context_code := 'DK.Unitel Domestic';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JE.DK.APXIISIM.UNIT_FOREIGN') THEN
      p_global_context_code := 'DK.Unitel Foreign';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JE.FI.APXIISIM.A_LOMAKE') THEN
      p_global_context_code := 'FI.A-lomake';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JE.FI.APXIISIM.B_LOMAKE') THEN
      p_global_context_code := 'FI.B-lomake';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JE.FI.APXIISIM.KKL_VIITE') THEN
      p_global_context_code := 'FI.Konekielinen viite';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JE.FI.APXIISIM.VAPAA_VIITE') THEN
      p_global_context_code := 'FI.Vapaa viite';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JE.NL.APXIISIM.FOREIGN') THEN
      p_global_context_code := 'NL.Foreign Payments';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JE.NO.APXIISIM.NORWAY') THEN
      p_global_context_code := 'NO.Norway';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JE.SE.APXIISIM.BANK_SISU') THEN
      p_global_context_code := 'SE.Bankgiro SISU';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JE.SE.APXIISIM.BANK_UTLI') THEN
      p_global_context_code := 'SE.Bankgiro UTLI';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JE.SE.APXIISIM.BANK_INLAND') THEN
      p_global_context_code := 'SE.Bankgiro Inland';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JE.SE.APXIISIM.POST_INLAND') THEN
      p_global_context_code := 'SE.Postgiro Inland';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JE.SE.APXIISIM.POST_UTLAND') THEN
      p_global_context_code := 'SE.Postgiro Utland';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JE.CZ.APXIISIM.INVOICE_INFO') THEN
      p_global_context_code := 'JE.CZ.APXINWKB.INVOICE_INFO';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JE.HU.APXIISIM.TAX_DATE') THEN
      p_global_context_code := 'JE.HU.APXINWKB.TAX_DATE';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JE.PL.APXIISIM.INVOICE_INFO') THEN
      p_global_context_code := 'JE.PL.APXINWKB.INVOICE_INFO';
      RETURN(TRUE);


-- Commeneted the below as part of the ECE Project

/*
    ELSIF (p_global_context_code = 'JE.HU.APXIISIM.STAT_CODE') THEN
      p_global_context_code := 'JE.HU.APXINWKB.STAT_CODE';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JE.PL.APXIISIM.STAT_CODE') THEN
      p_global_context_code := 'JE.PL.APXINWKB.STAT_CODE';
      RETURN(TRUE);    */

    ELSIF (p_global_context_code = 'JL.AR.APXIISIM.INVOICES_FOLDER') THEN
      p_global_context_code:='JL.AR.APXINWKB.INVOICES';
      RETURN(TRUE);
    ELSIF (p_global_context_code ='JL.AR.APXIISIM.LINES_FOLDER') THEN
           p_global_context_code := 'JL.AR.APXINWKB.DISTRIBUTIONS';
           RETURN(TRUE);
    -- Bug 3233307
    ELSIF (p_global_context_code = 'JL.CO.APXIISIM.INVOICES_FOLDER') THEN
           p_global_context_code:= 'JL.CO.APXINWKB.INVOICES';
           RETURN(TRUE);
    ELSIF (p_global_context_code = 'JL.CO.APXIISIM.LINES_FOLDER') THEN
           p_global_context_code := 'JL.CO.APXINWKB.DISTRIBUTIONS';
           RETURN(TRUE);
    ELSIF (p_global_context_code = 'JL.BR.APXIISIM.INVOICES_FOLDER') THEN
      p_global_context_code := 'JL.BR.APXINWKB.AP_INVOICES';
      RETURN(TRUE);
    ELSIF (p_global_context_code ='JL.BR.APXIISIM.LINES_FOLDER') THEN
      p_global_context_code := 'JL.BR.APXINWKB.D_SUM_FOLDER';
      RETURN(TRUE);
    ELSIF (p_global_context_code ='JE.IT.APXIISIM.DISTRIBUTIONS') THEN
      p_global_context_code := 'JE.IT.APXINWKB.DISTRIBUTIONS';
      RETURN(TRUE);
    ELSIF (p_global_context_code ='JE.ES.APXIISIM.MODELO349') THEN
      p_global_context_code := 'JE.ES.APXINWKB.MODELO349';
      RETURN(TRUE);
    ELSIF (p_global_context_code ='JE.ES.APXIISIM.MODELO347') THEN
      p_global_context_code := 'JE.ES.APXINWKB.MODELO347';
      RETURN(TRUE);
    ELSIF (p_global_context_code ='JE.ES.APXIISIM.OTHER') THEN
      p_global_context_code := 'JE.ES.APXINWKB.OTHER';
      RETURN(TRUE);
    ELSIF (p_global_context_code ='JE.ES.APXIISIM.MODELO347PR') THEN
      p_global_context_code := 'JE.ES.APXINWKB.MODELO347PR';
      RETURN(TRUE);

     ELSIF (p_global_context_code ='JE.FR.APXIISIM.TAX_RULE') THEN
      p_global_context_code := 'JE.FR.APXINWKB.TAX_RULE';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JL.CL.APXIISIM.INVOICES_FOLDER') THEN
      p_global_context_code:='JL.CL.APXINWKB.AP_INVOICES';
      RETURN(TRUE);

 -- Added the below as part of the ECE Project

    ELSIF (p_global_context_code = 'JE.SK.APXIISIM.INVOICE_INFO') THEN
      p_global_context_code := 'JE.SK.APXINWKB.INVOICE_INFO';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JE.PL.APXIISIM.INSURANCE_INFO') THEN
      p_global_context_code := 'JE.PL.APXINWKB.INSURANCE_INFO';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JE.HU.APXIISIM.FINAL') THEN
      p_global_context_code := 'JE.HU.APXINWKB.FINAL';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JE.PL.APXIISIM.FINAL') THEN
      p_global_context_code := 'JE.PL.APXINWKB.FINAL';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JE.CZ.APXIISIM.FINAL') THEN
      p_global_context_code := 'JE.CZ.APXINWKB.FINAL';
      RETURN(TRUE);
    ELSIF (p_global_context_code = 'JE.SK.APXIISIM.FINAL') THEN
      p_global_context_code := 'JE.SK.APXINWKB.FINAL';
      RETURN(TRUE);


--  << ADD NEW ENTRY HERE >>
--  ELSIF (p_global_context_code = 'CURRENT CONTEXT CODE') THEN
--    p_global_context_code := 'TARGET CONTEXT CODE';
--    RETURN(TRUE);

    ELSE
      RETURN(FALSE);
    END IF;
  END reassign_context_code;

  ---------------------------------------------------------------------------
  -- CHECK_ATTR_VALUE():
  --   Check global flexfield information prior to inserting it into
  --   the table upon which the global flexfield is defined.
  --   This procedure will indicate an error if any of the values are
  --   invalid
  --   The parameters p_core_prod_arg1 to p_core_prod_arg30 are defined
  --   considering the future expansion we may need to include global
  --   flexfield validation for other products.
  --------------------------------------------------------------------------
  PROCEDURE check_attr_value
     (p_calling_program_name       IN     VARCHAR2,
      p_global_attribute_category  IN     VARCHAR2,
      p_global_attribute1          IN OUT NOCOPY     VARCHAR2,
      p_global_attribute2          IN OUT NOCOPY     VARCHAR2,
      p_global_attribute3          IN OUT NOCOPY     VARCHAR2,
      p_global_attribute4          IN OUT NOCOPY     VARCHAR2,
      p_global_attribute5          IN OUT NOCOPY     VARCHAR2,
      p_global_attribute6          IN OUT NOCOPY     VARCHAR2,
      p_global_attribute7          IN OUT NOCOPY     VARCHAR2,
      p_global_attribute8          IN OUT NOCOPY     VARCHAR2,
      p_global_attribute9          IN OUT NOCOPY     VARCHAR2,
      p_global_attribute10         IN OUT NOCOPY     VARCHAR2,
      p_global_attribute11         IN OUT NOCOPY     VARCHAR2,
      p_global_attribute12         IN OUT NOCOPY     VARCHAR2,
      p_global_attribute13         IN OUT NOCOPY     VARCHAR2,
      p_global_attribute14         IN OUT NOCOPY     VARCHAR2,
      p_global_attribute15         IN OUT NOCOPY     VARCHAR2,
      p_global_attribute16         IN OUT NOCOPY     VARCHAR2,
      p_global_attribute17         IN OUT NOCOPY     VARCHAR2,
      p_global_attribute18         IN OUT NOCOPY     VARCHAR2,
      p_global_attribute19         IN OUT NOCOPY     VARCHAR2,
      p_global_attribute20         IN OUT NOCOPY     VARCHAR2,
      p_core_prod_arg1             IN     VARCHAR2 ,
      p_core_prod_arg2             IN     VARCHAR2 ,
      p_core_prod_arg3             IN     VARCHAR2 ,
      p_core_prod_arg4             IN     VARCHAR2 ,
      p_core_prod_arg5           IN     VARCHAR2 ,
      p_core_prod_arg6           IN     VARCHAR2 ,
      p_core_prod_arg7             IN     VARCHAR2 ,
      p_core_prod_arg8             IN     VARCHAR2 ,
      p_core_prod_arg9             IN     VARCHAR2 ,
      p_core_prod_arg10            IN     VARCHAR2 ,
      p_core_prod_arg11            IN     VARCHAR2 ,
      p_core_prod_arg12            IN     VARCHAR2 ,
      p_core_prod_arg13            IN     VARCHAR2 ,
      p_core_prod_arg14            IN     VARCHAR2 ,
      p_core_prod_arg15            IN     VARCHAR2 ,
      p_core_prod_arg16            IN     VARCHAR2 ,
      p_core_prod_arg17            IN     VARCHAR2 ,
      p_core_prod_arg18            IN     VARCHAR2 ,
      p_core_prod_arg19            IN     VARCHAR2 ,
      p_core_prod_arg20            IN     VARCHAR2 ,
      p_core_prod_arg21            IN     VARCHAR2 ,
      p_core_prod_arg22            IN     VARCHAR2 ,
      p_core_prod_arg23            IN     VARCHAR2 ,
      p_core_prod_arg24            IN     VARCHAR2 ,
      p_core_prod_arg25            IN     VARCHAR2 ,
      p_core_prod_arg26            IN     VARCHAR2 ,
      p_core_prod_arg27            IN     VARCHAR2 ,
      p_core_prod_arg28            IN     VARCHAR2 ,
      p_core_prod_arg29            IN     VARCHAR2 ,
      p_core_prod_arg30            IN     VARCHAR2 ,
      p_current_status             OUT NOCOPY    VARCHAR2) IS

  BEGIN
    IF p_calling_program_name = 'APXIIMPT' THEN
       check_attr_value_ap
          (p_calling_program_name,
           TO_NUMBER(p_core_prod_arg1), -- Set of Books Id
           fnd_date.canonical_to_date(p_core_prod_arg2),   -- Invoice Date
           p_core_prod_arg3,            -- Parent Table
           TO_NUMBER(p_core_prod_arg4), -- Parent Id
           TO_NUMBER(p_core_prod_arg5), -- Default Last Updated By
           TO_NUMBER(p_core_prod_arg6), -- Default Last Update Login
	   TO_NUMBER(p_core_prod_arg8), -- Vendor Site ID -For DK EDI
	   p_core_prod_arg9,		-- payment curency code - FOR DK EDI
           p_core_prod_arg10,           -- Item Type Lookup Code - FOR BR
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
           p_current_status,
           p_core_prod_arg7);          -- Current Calling Sequence
    END IF;

  --
  -- AR validation is implemented in check_attr_value_ar
  -- due to the data model changes in TCA.
  --

  END CHECK_ATTR_VALUE;

  ---------------------------------------------------------------------------
  -- CHECK_ATTR_VALUE_AP():
  --    This procedure validates AP global flexfield.
  --    Currently the procedure validates the following flexfields.
  --    JG_AP_INVOICES_INTERFACE
  --    JG_AP_INVOICE_LINES_INTERFACE
  --    Whenever the validation fails, a record is inserted into the
  --    AP_INTERFACE_REJECTIONS table.
  --------------------------------------------------------------------------
  PROCEDURE check_attr_value_ap(
      p_calling_program_name  		IN    VARCHAR2,
      p_set_of_books_id     		IN    NUMBER,
      p_invoice_date                    IN    DATE,
      p_parent_table          		IN    VARCHAR2,
      p_parent_id          		IN    NUMBER,
      p_default_last_updated_by		IN    NUMBER,
      p_default_last_update_login	IN    NUMBER,
      p_inv_vendor_site_id		IN    NUMBER,
      p_inv_payment_currency_code	IN    VARCHAR2,
      p_line_type_lookup_code           IN    VARCHAR2,
      p_global_attribute_category       IN    VARCHAR2,
      p_global_attribute1   		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute2   		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute3   		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute4   		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute5   		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute6   		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute7   		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute8   		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute9   		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute10  		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute11  		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute12  		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute13  		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute14  		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute15  		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute16  		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute17  		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute18  		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute19  		IN OUT NOCOPY    VARCHAR2,
      p_global_attribute20  		IN OUT NOCOPY    VARCHAR2,
      p_current_invoice_status		OUT NOCOPY   VARCHAR2,
      p_calling_sequence       		IN    VARCHAR2) IS

     l_credit_exists            VARCHAR2(1);
     l_current_invoice_status1  VARCHAR2(1);
     l_current_invoice_status2  VARCHAR2(1);

     l_debug_loc                VARCHAR2(30);
     l_curr_calling_sequence    VARCHAR2(2000);
     l_debug_info               VARCHAR2(100);

  BEGIN
     l_current_invoice_status1   := 'Y';
     l_current_invoice_status2   := 'Y';

     l_debug_loc                 := 'check_attr_value_ap';

  -------------------------- DEBUG INFORMATION ------------------------------
  l_curr_calling_sequence := 'jg_globe_flex_val.'||l_debug_loc||'<-'||p_calling_sequence;
  l_debug_info := 'Check if value exists in global attribute columns where not expected';
  ---------------------------------------------------------------------------
  --
  -- Check AP Context Integrity
  --
  check_ap_context_integrity
          (p_calling_program_name,
           p_parent_table,
           p_parent_id,
           p_default_last_updated_by,
           p_default_last_update_login,
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
           l_current_invoice_status1,
           l_curr_calling_sequence);          -- Current Calling Sequence

  --
  --  Added to improve performance. Return if global flexfield is null.
  --
  IF (p_global_attribute_category IS NULL) THEN
     p_current_invoice_status := l_current_invoice_status1;
     RETURN;
  END IF;

  --
  -- Check AP Business Rules
  --
  check_ap_business_rules
          (p_calling_program_name,
           p_set_of_books_id,
           p_invoice_date,
           p_parent_table,
           p_parent_id,
           p_default_last_updated_by,
           p_default_last_update_login,
      	   p_inv_vendor_site_id,
           p_inv_payment_currency_code,
           p_line_type_lookup_code,
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
           l_current_invoice_status2,
           l_curr_calling_sequence);          -- Current Calling Sequence

    IF (l_current_invoice_status1 = 'N') or (l_current_invoice_status2 = 'N') THEN
        p_current_invoice_status := 'N';
    ELSE
        p_current_invoice_status := 'Y';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', 'SQLERRM');
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
                        'Calling Program Name = '||p_calling_program_name
                    ||', Set Of Books Id = '||to_char(p_set_of_books_id)
                    ||', Parent Table = '||p_parent_table
                    ||', Parent Id = '||to_char(p_parent_id)
                    ||', Last Updated By = '||to_char(p_default_last_updated_by)
                    ||', Last Update Login = '||to_char(p_default_last_update_login)
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
  END check_attr_value_ap;

  ---------------------------------------------------------------------------
  --  CHECK_AP_CONTEXT_INTEGRITY()
  --  Check ap context integrity.
  ---------------------------------------------------------------------------
  PROCEDURE check_ap_context_integrity(
         p_calling_program_name            IN    VARCHAR2,
         p_parent_table                    IN    VARCHAR2,
         p_parent_id                       IN    NUMBER,
         p_default_last_updated_by         IN    NUMBER,
         p_default_last_update_login       IN    NUMBER,
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
         p_calling_sequence                IN    VARCHAR2) IS

     l_current_invoice_status1       VARCHAR2(1);
     l_current_invoice_status2       VARCHAR2(1);

     l_debug_loc                     VARCHAR2(30);
     l_curr_calling_sequence         VARCHAR2(2000);
     l_debug_info                    VARCHAR2(100);

  BEGIN
     l_debug_loc  := 'check_ap_context_integrity';
    -------------------------- DEBUG INFORMATION ------------------------------
    l_curr_calling_sequence := 'jg_globe_flex_val.'||l_debug_loc||'<-'||p_calling_sequence;
    l_debug_info := 'Reject invalid context code';
    ---------------------------------------------------------------------------
    --
    -- Reject when global attribute value found where not expected.
    --
    reject_value_found
          (p_parent_table,
           p_parent_id,
           p_default_last_updated_by,
           p_default_last_update_login,
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
           l_current_invoice_status1,
           l_curr_calling_sequence);          -- Current Calling Sequence

    --
    -- Reject invalid global attribute category.
    --
    reject_invalid_context_code
          (p_calling_program_name,
           p_parent_table,
           p_parent_id,
           p_default_last_updated_by,
           p_default_last_update_login,
           p_global_attribute_category,
           l_current_invoice_status2,
           l_curr_calling_sequence);          -- Current Calling Sequence

    IF (l_current_invoice_status1 = 'N') or (l_current_invoice_status2 = 'N') THEN
        p_current_invoice_status := 'N';
    END IF;

  END check_ap_context_integrity;

  ---------------------------------------------------------------------------
  --  REJECT_VALUE_FOUND()
  --  Reject when global attribute value found where not expected.
  ---------------------------------------------------------------------------
  PROCEDURE reject_value_found(
         p_parent_table                    IN    VARCHAR2,
         p_parent_id                       IN    NUMBER,
         p_default_last_updated_by         IN    NUMBER,
         p_default_last_update_login       IN    NUMBER,
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
         p_calling_sequence                IN    VARCHAR2) IS

     l_debug_loc                     VARCHAR2(30);
     l_curr_calling_sequence         VARCHAR2(2000);
     l_debug_info                    VARCHAR2(100);

  BEGIN
     l_debug_loc  := 'reject_value_found';
    -------------------------- DEBUG INFORMATION ------------------------------
    l_curr_calling_sequence := 'jg_globe_flex_val.'||l_debug_loc||'<-'||p_calling_sequence;
    l_debug_info := 'Reject invalid context code';
    ---------------------------------------------------------------------------
    IF (check_attr_exists(
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
        p_global_attribute20) <> TRUE)
    THEN
      jg_globe_flex_val_shared.insert_rejections(p_parent_table,
                        p_parent_id,
                        'GLOBAL_ATTR_VALUE_FOUND',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        p_calling_sequence);
      p_current_invoice_status := 'N';
    END IF;
  END reject_value_found;

  ---------------------------------------------------------------------------
  --  REJECT_INVALID_CONTEXT_CODE()
  --  Reject when global attribute value found where not expected.
  ---------------------------------------------------------------------------
  PROCEDURE reject_invalid_context_code(
         p_calling_program_name            IN    VARCHAR2,
         p_parent_table                    IN    VARCHAR2,
         p_parent_id                       IN    NUMBER,
         p_default_last_updated_by         IN    NUMBER,
         p_default_last_update_login       IN    NUMBER,
         p_global_attribute_category       IN    VARCHAR2,
         p_current_invoice_status          OUT NOCOPY   VARCHAR2,
         p_calling_sequence                IN    VARCHAR2) IS

     l_debug_loc                     VARCHAR2(30);
     l_curr_calling_sequence         VARCHAR2(2000);
     l_debug_info                    VARCHAR2(100);

  BEGIN
     l_debug_loc     := 'reject_invalid_context_code';
    -------------------------- DEBUG INFORMATION ------------------------------
    l_curr_calling_sequence := 'jg_globe_flex_val.'||l_debug_loc||'<-'||p_calling_sequence;
    l_debug_info := 'Reject invalid context code';
    ---------------------------------------------------------------------------
    IF p_global_attribute_category IS NOT NULL THEN
      l_debug_info := 'Check if specified context value is valid';
      IF (check_context_code(
                     p_calling_program_name,
                     p_global_attribute_category) <> TRUE)
      THEN
        jg_globe_flex_val_shared.insert_rejections(p_parent_table,
                          p_parent_id,
                          'INVALID_GLOBAL_CONTEXT',
                          p_default_last_updated_by,
                          p_default_last_update_login,
                          p_calling_sequence);
        p_current_invoice_status := 'N';
      END IF;
    END IF;
  END reject_invalid_context_code;

  ---------------------------------------------------------------------------
  -- CHECK_AP_BUSINESS_RULES():
  --    This procedure validates AP global flexfield values.
  --    Currently the procedure validates the following flexfields.
  --    JG_AP_INVOICES_INTERFACE
  --    JG_AP_INVOICE_LINES_INTERFACE
  --    Whenever the validation fails, a record is inserted into the
  --    AP_INTERFACE_REJECTIONS table.
  --------------------------------------------------------------------------
  PROCEDURE check_ap_business_rules(
      p_calling_program_name            IN    VARCHAR2,
      p_set_of_books_id                 IN    NUMBER,
      p_invoice_date                    IN    DATE,
      p_parent_table                    IN    VARCHAR2,
      p_parent_id                       IN    NUMBER,
      p_default_last_updated_by         IN    NUMBER,
      p_default_last_update_login       IN    NUMBER,
      p_inv_vendor_site_id              IN    NUMBER,
      p_inv_payment_currency_code       IN    VARCHAR2,
      p_line_type_lookup_code           IN    VARCHAR2,
      p_global_attribute_category       IN    VARCHAR2,
      p_global_attribute1               IN OUT NOCOPY    VARCHAR2,
      p_global_attribute2               IN OUT NOCOPY    VARCHAR2,
      p_global_attribute3               IN OUT NOCOPY    VARCHAR2,
      p_global_attribute4               IN OUT NOCOPY    VARCHAR2,
      p_global_attribute5               IN OUT NOCOPY    VARCHAR2,
      p_global_attribute6               IN OUT NOCOPY    VARCHAR2,
      p_global_attribute7               IN OUT NOCOPY    VARCHAR2,
      p_global_attribute8               IN OUT NOCOPY    VARCHAR2,
      p_global_attribute9               IN OUT NOCOPY    VARCHAR2,
      p_global_attribute10              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute11              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute12              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute13              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute14              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute15              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute16              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute17              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute18              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute19              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute20              IN OUT NOCOPY    VARCHAR2,
      p_current_invoice_status          OUT NOCOPY   VARCHAR2,
      p_calling_sequence                IN    VARCHAR2) IS

     l_credit_exists VARCHAR2(1);

     l_debug_loc                     VARCHAR2(30);
     l_curr_calling_sequence         VARCHAR2(2000);
     l_debug_info                    VARCHAR2(100);
  BEGIN
     l_debug_loc  := 'check_ap_business_rules';

  -------------------------- DEBUG INFORMATION ------------------------------
  l_curr_calling_sequence := 'jg_globe_flex_val.'||l_debug_loc||'<-'||p_calling_sequence;
  l_debug_info := 'Check ap business rules';
  ---------------------------------------------------------------------------

     p_current_invoice_status := 'Y'; -- Initialize record status variable

  --------------------------------------------------------------------------------------
  --                         Global Flexfield Validation
  --------------------------------------------------------------------------------------
  --  You can add your own validation code for your global flexfields.
  --  You should not include arguments(GLOBAL_ATTRIBUTE(n)) you do not validate
  --  in your procedure.
  --  Form Name: APXIISIM
  --------------------------------------------------------------------------------------
  --   Header Level Validation - Block Name: INVOICES_FOLDER
  --------------------------------------------------------------------------------------
  --    1-1. JA.KR.APXIISIM.INVOICES_FOLDER
  --    1-2. JA.CN.APXIISIM.INVOICES_FOLDER
  --    1-3. JA.TH.APXIISIM.INVOICES_INTF
  --    1-4. JA.TW.APXIISIM.INVOICES_FOLDER
  --    1-5. JA.SG.APXIISIM.INVOICES_FOLDER
  --    1-6. JE.BE.APXIISIM.EFT
  --    1-7. JE.CH.APXIISIM.DTA
  --    1-8. JE.CH.APXIISIM.SAD
  --    1-9.0 JE.DK.APXIISIM.EDI_INFO
  --    1-9. JE.DK.APXIISIM.GIRO_DOMESTIC
  --    1-10.JE.DK.APXIISIM.GIRO_FOREIGN
  --    1-11.JE.DK.APXIISIM.UNIT_DOMESTIC
  --    1-12.JE.DK.APXIISIM.UNIT_FOREIGN
  --    1-13.JE.FI.APXIISIM.A_LOMAKE
  --    1-14.JE.FI.APXIISIM.B_LOMAKE
  --    1-15.JE.FI.APXIISIM.KKL_VIITE
  --    1-16.JE.FI.APXIISIM.VAPAA_VIITE
  --    1-17.JE.NL.APXIISIM.FOREIGN
  --    1-19.JE.NO.APXIISIM.NORWAY
  --    1-20.JE.SE.APXIISIM.BANK_SISU
  --    1-21.JE.SE.APXIISIM.BANK_UTLI
  --    1-22.JE.SE.APXIISIM.POST_INLAND
  --    1-23.JE.SE.APXIISIM.POST_UTLAND
  --    1-24.JE.CZ.APXIISIM.INVOICE_INFO
  --    1-25.JE.HU.APXIISIM.TAX_DATE
  --    1-26.JE.PL.APXIISIM.INVOICE_INFO
  --    1-27.JL.AR.APXIISIM.INVOICES_FOLDER
  --    1-27a.JL.CO.APXIISIM.INVOICES_FOLDER -- Bug 3233307
  --    1-28.JL.BR.APXIISIM.INVOICES_FOLDER
  --    1-29.JL.CL.APXIISIM.INVOICES_FOLDER
  --    1-30.JE.SK.APXIISIM.INVOICE_INFO
  --------------------------------------------------------------------------------------
  --   Line Level Validation   - Block Name: INVOICE_LINES_FOLDER
  --------------------------------------------------------------------------------------
  --    2-1.  JA.KR.APXIISIM.LINES_FOLDER
  --    2-2.  JA.CA.APXIISIM.LINES_FOLDER
  --    2-3.  JE.HU.APXIISIM.STAT_CODE
  --    2-4.  JE.PL.APXIISIM.STAT_CODE
  --    2-5.  JL.AR.APXIISIM.LINES_FOLDER
  --    2-6.  JL.CO.APXIIFIX.LINES_FOLDER
  --    2-7.  JL.BR.APXIISIM.LINES_FOLDER
  --    2-8.  JE.HU.APXIISIM.FINAL
  --    2-9.  JE.PL.APXIISIM.FINAL
  --    2-10. JE.CZ.APXIISIM.FINAL
  --    2-11. JE.SK.APXIISIM.FINAL
  --    2-12. JE.PL.APXIISIM.INSURANCE_INFO

  --
  --     There is no global flexfield in Invoice Gateway of R11i for Korea,
  --     China, and Canada, so comment out for their context.
  --------------------------------------------------------------------------------------

  --
  --    1-1. JA.KR.APXIISIM.INVOICES_FOLDER
  --
  IF (p_global_attribute_category in ('JA.TH.APXIISIM.INVOICES_INTF',
                                      'JA.TW.APXIISIM.INVOICES_FOLDER',
  --                                  'JA.KR.APXIISIM.INVOICES_FOLDER',
  --                                  'JA.CN.APXIISIM.INVOICES_FOLDER',
  --                                  'JA.KR.APXIISIM.LINES_FOLDER',
  --                                  'JA.CA.APXIISIM.LINES_FOLDER'
                                      'JA.SG.APXIISIM.INVOICES_FOLDER')) THEN
   ja_interface_val.ap_business_rules(
      p_calling_program_name,
      p_set_of_books_id,
      p_invoice_date,
      p_parent_table,
      p_parent_id,
      p_default_last_updated_by,
      p_default_last_update_login,
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
      p_current_invoice_status,
      p_calling_sequence);

  ELSIF (p_global_attribute_category in ('JE.BE.APXIISIM.EFT',
                                         'JE.CH.APXIISIM.DTA',
                                         'JE.CH.APXIISIM.SAD',
					 'JE.DK.APXIISIM.EDI_INFO',
                                         'JE.DK.APXIISIM.GIRO_DOMESTIC',
                                         'JE.DK.APXIISIM.GIRO_FOREIGN',
                                         'JE.DK.APXIISIM.UNIT_DOMESTIC',
                                         'JE.DK.APXIISIM.UNIT_FOREIGN',
                                         'JE.ES.APXIISIM.MODELO349',
                                         'JE.FI.APXIISIM.A_LOMAKE',
                                         'JE.FI.APXIISIM.B_LOMAKE',
                                         'JE.FI.APXIISIM.KKL_VIITE',
                                         'JE.FI.APXIISIM.VAPAA_VIITE',
                                         'JE.NL.APXIISIM.FOREIGN',
                                         'JE.NO.APXIISIM.NORWAY',
                                         'JE.SE.APXIISIM.BANK_SISU',
                                         'JE.SE.APXIISIM.BANK_UTLI',
                                         'JE.SE.APXIISIM.BANK_INLAND',
                                         'JE.SE.APXIISIM.POST_INLAND',
                                         'JE.SE.APXIISIM.POST_UTLAND',
                                         'JE.CZ.APXIISIM.INVOICE_INFO',
                                         'JE.HU.APXIISIM.TAX_DATE',
                                         'JE.PL.APXIISIM.INVOICE_INFO',
                                       --'JE.HU.APXIISIM.STAT_CODE',
                                         'JE.IT.APXIISIM.DISTRIBUTIONS',
                                     --  'JE.PL.APXIISIM.STAT_CODE'
                                         'JE.SK.APXIISIM.INVOICE_INFO',
                                         'JE.SK.APXIISIM.FINAL',
                                         'JE.HU.APXIISIM.FINAL',
                                         'JE.CZ.APXIISIM.FINAL',
                                         'JE.PL.APXIISIM.FINAL',
					 'JE.PL.APXIISIM.INSURANCE_INFO'
					) ) THEN

   je_interface_val.ap_business_rules(
      p_calling_program_name,
      p_set_of_books_id,
      p_invoice_date,
      p_parent_table,
      p_parent_id,
      p_default_last_updated_by,
      p_default_last_update_login,
      p_inv_vendor_site_id,
      p_inv_payment_currency_code,
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
      p_current_invoice_status,
      p_calling_sequence);

  ELSIF (p_global_attribute_category in ('JL.AR.APXIISIM.INVOICES_FOLDER',
                                         'JL.AR.APXIISIM.LINES_FOLDER',
				         'JL.CO.APXIISIM.INVOICES_FOLDER', -- Bug 3233307
                                         'JL.CO.APXIISIM.LINES_FOLDER',
                                         'JL.BR.APXIISIM.INVOICES_FOLDER',
                                         'JL.BR.APXIISIM.LINES_FOLDER',
                                         'JL.CL.APXIISIM.INVOICES_FOLDER')) THEN
   jl_interface_val.ap_business_rules(
      p_calling_program_name,
      p_set_of_books_id,
      p_invoice_date,
      p_parent_table,
      p_parent_id,
      p_default_last_updated_by,
      p_default_last_update_login,
      p_line_type_lookup_code,
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
      p_current_invoice_status,
      p_calling_sequence);

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
  END check_ap_business_rules;


  -- Call global flexfield validations procedure for validating the Tax ID and
  -- global flexfield segments in RA_CUSTOMERS_INTERFACE

  PROCEDURE ar_cust_interface(p_request_id         IN   NUMBER,
                              p_org_id             IN   NUMBER,
-- This org_id is not used for data partitioning
                              p_sob_id             IN   NUMBER,
                              p_user_id            IN   NUMBER,
                              p_application_id     IN   NUMBER,
                              p_language           IN   NUMBER,
                              p_program_id         IN   NUMBER,
                              p_prog_appl_id       IN   NUMBER,
                              p_last_update_login  IN   NUMBER,
                              p_int_table_name     IN   VARCHAR2
  ) IS

  l_current_status            VARCHAR2(1);
  l_error_count               NUMBER(15):=0;

  --
  -- Modified to implement new TCA model
  --
  -- This is for new RA_CUSTOMERS_INTERFACE model.
  -- You can delete old model once you completed.
  --
  -- This revision includes following columns:
  --
  -- customer_name,
  -- customer_number,
  -- jg_zz_fiscal_code,
  -- orig_system_customer_ref,
  -- insert_update_flag
  -- global_attribute_category
  -- global_attribute1..20
  -- gdf_address_attr_cat
  -- gdf_address_attr1..20
  -- gdf_site_use_attr_cat
  -- gdf_site_use_attr1..20
  --

  CURSOR ra_customers_interface IS
    SELECT  i.customer_name, i.customer_number, i.jgzz_fiscal_code,
            i.orig_system_customer_ref,i.insert_update_flag,
            i.cust_tax_reference,
            i.global_attribute_category,i.global_attribute1,
            i.global_attribute2,i.global_attribute3,i.global_attribute4,
            i.global_attribute5,i.global_attribute6,i.global_attribute7,
            i.global_attribute8,i.global_attribute9,i.global_attribute10,
            i.global_attribute11,i.global_attribute12,i.global_attribute13,
            i.global_attribute14,i.global_attribute15,i.global_attribute16,
            i.global_attribute17,i.global_attribute18,i.global_attribute19,
            i.global_attribute20,
            i.gdf_address_attr_cat,i.gdf_address_attribute1,
            i.gdf_address_attribute2,i.gdf_address_attribute3,i.gdf_address_attribute4,
            i.gdf_address_attribute5,i.gdf_address_attribute6,i.gdf_address_attribute7,
            i.gdf_address_attribute8,i.gdf_address_attribute9,i.gdf_address_attribute10,
            i.gdf_address_attribute11,i.gdf_address_attribute12,i.gdf_address_attribute13,
            i.gdf_address_attribute14,i.gdf_address_attribute15,i.gdf_address_attribute16,
            i.gdf_address_attribute17,i.gdf_address_attribute18,i.gdf_address_attribute19,
            i.gdf_address_attribute20,
            i.gdf_site_use_attr_cat,i.gdf_site_use_attribute1,
            i.gdf_site_use_attribute2,i.gdf_site_use_attribute3,i.gdf_site_use_attribute4,
            i.gdf_site_use_attribute5,i.gdf_site_use_attribute6,i.gdf_site_use_attribute7,
            i.gdf_site_use_attribute8,i.gdf_site_use_attribute9,i.gdf_site_use_attribute10,
            i.gdf_site_use_attribute11,i.gdf_site_use_attribute12,i.gdf_site_use_attribute13,
            i.gdf_site_use_attribute14,i.gdf_site_use_attribute15,i.gdf_site_use_attribute16,
            i.gdf_site_use_attribute17,i.gdf_site_use_attribute18,i.gdf_site_use_attribute19,
            i.gdf_site_use_attribute20,
            i.rowid
    FROM    ra_customers_interface i
    WHERE   i.request_id = p_request_id
    AND     nvl(i.validated_flag,'N') <> 'Y';

  --
  -- Still under development.
  -- Need to make sure which columns to be selected.
  --
  -- This revision includes following columns:
  --
  -- gdf_cust_prof_attr_cat
  -- gdf_cust_prof_attr1..20
  --

  CURSOR ra_customer_profiles_interface IS
    SELECT  i.global_attribute_category,i.global_attribute1,
            i.global_attribute2,i.global_attribute3,i.global_attribute4,
            i.global_attribute5,i.global_attribute6,i.global_attribute7,
            i.global_attribute8,i.global_attribute9,i.global_attribute10,
            i.global_attribute11,i.global_attribute12,i.global_attribute13,
            i.global_attribute14,i.global_attribute15,i.global_attribute16,
            i.global_attribute17,i.global_attribute18,i.global_attribute19,
            i.global_attribute20,
            i.gdf_cust_prof_attr_cat,i.gdf_cust_prof_attribute1,
            i.gdf_cust_prof_attribute2,i.gdf_cust_prof_attribute3,i.gdf_cust_prof_attribute4,
            i.gdf_cust_prof_attribute5,i.gdf_cust_prof_attribute6,i.gdf_cust_prof_attribute7,
            i.gdf_cust_prof_attribute8,i.gdf_cust_prof_attribute9,i.gdf_cust_prof_attribute10,
            i.gdf_cust_prof_attribute11,i.gdf_cust_prof_attribute12,i.gdf_cust_prof_attribute13,
            i.gdf_cust_prof_attribute14,i.gdf_cust_prof_attribute15,i.gdf_cust_prof_attribute16,
            i.gdf_cust_prof_attribute17,i.gdf_cust_prof_attribute18,i.gdf_cust_prof_attribute19,
            i.gdf_cust_prof_attribute20,
            i.rowid
    FROM    ra_customer_profiles_interface i
    WHERE   i.request_id = p_request_id
    AND     nvl(i.validated_flag,'N') <> 'Y';


  gdf_rec1           jg_globe_flex_val_shared.GdfRec;  /* New Record Variable */
  gdf_rec2           jg_globe_flex_val_shared.GdfRec;  /* New Record Variable */
  gdf_rec3           jg_globe_flex_val_shared.GdfRec;  /* New Record Variable */
  gdf_general_rec    jg_globe_flex_val_shared.GenRec;  /* New Record Variable */

  --
  -- End of modification
  --

  CURSOR generate_number IS
    SELECT s.generate_customer_number
    FROM   ar_system_parameters s
    WHERE  s.set_of_books_id  = p_sob_id;
  l_cust_man_numbering ar_system_parameters.generate_customer_number%TYPE;

  PG_DEBUG varchar2(1);

  BEGIN

  PG_DEBUG := NVL(FND_PROFILE.value('AR_ENABLE_DEBUG_OUTPUT'), 'N');
    --  arp_standard.enable_debug;

    --  If there is a performance problem for Customers other than Chile,
    --  Colombia and Argentina, the performance can be improved by
    --  uncommenting the Return Statement given below.
    --  There will not be any validations for global flexfields if this
    --  Return statement is uncommented.

    --  RETURN;

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('check_attr_value: ' || 'Begin AR Cust Interface procedure');
          arp_standard.debug('check_attr_value: ' || 'Global Descr Flex Field Validation Begin: '
                                  || to_char(sysdate, 'DD-MON-RR HH:MI:SS'));
       END IF;

    -- Get Customer Numbering - Automatic/Manual from AR_SYSTEM_PARAMETERS

    IF p_int_table_name = 'CUSTOMER' THEN
      OPEN generate_number;
      FETCH generate_number INTO l_cust_man_numbering;
      CLOSE generate_number;

      FOR idx_cur IN ra_customers_interface LOOP
         --
         -- Modified to implement new TCA model
         --
        gdf_rec1.global_attribute_category := idx_cur.global_attribute_category;
         gdf_rec1.global_attribute1  := idx_cur.global_attribute1;
         gdf_rec1.global_attribute2  := idx_cur.global_attribute2;
         gdf_rec1.global_attribute3  := idx_cur.global_attribute3;
         gdf_rec1.global_attribute4  := idx_cur.global_attribute4;
         gdf_rec1.global_attribute5  := idx_cur.global_attribute5;
         gdf_rec1.global_attribute6  := idx_cur.global_attribute6;
         gdf_rec1.global_attribute7  := idx_cur.global_attribute7;
         gdf_rec1.global_attribute8  := idx_cur.global_attribute8;
         gdf_rec1.global_attribute9  := idx_cur.global_attribute9;
         gdf_rec1.global_attribute10 := idx_cur.global_attribute10;
         gdf_rec1.global_attribute11 := idx_cur.global_attribute11;
         gdf_rec1.global_attribute12 := idx_cur.global_attribute12;
         gdf_rec1.global_attribute13 := idx_cur.global_attribute13;
         gdf_rec1.global_attribute14 := idx_cur.global_attribute14;
         gdf_rec1.global_attribute15 := idx_cur.global_attribute15;
         gdf_rec1.global_attribute16 := idx_cur.global_attribute16;
         gdf_rec1.global_attribute17 := idx_cur.global_attribute17;
         gdf_rec1.global_attribute18 := idx_cur.global_attribute18;
         gdf_rec1.global_attribute19 := idx_cur.global_attribute19;
         gdf_rec1.global_attribute20 := idx_cur.global_attribute20;

         gdf_rec2.global_attribute_category := idx_cur.gdf_address_attr_cat;
         gdf_rec2.global_attribute1  := idx_cur.gdf_address_attribute1;
         gdf_rec2.global_attribute2  := idx_cur.gdf_address_attribute2;
         gdf_rec2.global_attribute3  := idx_cur.gdf_address_attribute3;
         gdf_rec2.global_attribute4  := idx_cur.gdf_address_attribute4;
         gdf_rec2.global_attribute5  := idx_cur.gdf_address_attribute5;
         gdf_rec2.global_attribute6  := idx_cur.gdf_address_attribute6;
         gdf_rec2.global_attribute7  := idx_cur.gdf_address_attribute7;
         gdf_rec2.global_attribute8  := idx_cur.gdf_address_attribute8;
         gdf_rec2.global_attribute9  := idx_cur.gdf_address_attribute9;
         gdf_rec2.global_attribute10 := idx_cur.gdf_address_attribute10;
         gdf_rec2.global_attribute11 := idx_cur.gdf_address_attribute11;
         gdf_rec2.global_attribute12 := idx_cur.gdf_address_attribute12;
         gdf_rec2.global_attribute13 := idx_cur.gdf_address_attribute13;
         gdf_rec2.global_attribute14 := idx_cur.gdf_address_attribute14;
         gdf_rec2.global_attribute15 := idx_cur.gdf_address_attribute15;
         gdf_rec2.global_attribute16 := idx_cur.gdf_address_attribute16;
         gdf_rec2.global_attribute17 := idx_cur.gdf_address_attribute17;
         gdf_rec2.global_attribute18 := idx_cur.gdf_address_attribute18;
         gdf_rec2.global_attribute19 := idx_cur.gdf_address_attribute19;
         gdf_rec2.global_attribute20 := idx_cur.gdf_address_attribute20;

         gdf_rec3.global_attribute_category := idx_cur.gdf_site_use_attr_cat;
         gdf_rec3.global_attribute1  := idx_cur.gdf_site_use_attribute1;
         gdf_rec3.global_attribute2  := idx_cur.gdf_site_use_attribute2;
         gdf_rec3.global_attribute3  := idx_cur.gdf_site_use_attribute3;
         gdf_rec3.global_attribute4  := idx_cur.gdf_site_use_attribute4;
         gdf_rec3.global_attribute5  := idx_cur.gdf_site_use_attribute5;
         gdf_rec3.global_attribute6  := idx_cur.gdf_site_use_attribute6;
         gdf_rec3.global_attribute7  := idx_cur.gdf_site_use_attribute7;
         gdf_rec3.global_attribute8  := idx_cur.gdf_site_use_attribute8;
         gdf_rec3.global_attribute9  := idx_cur.gdf_site_use_attribute9;
         gdf_rec3.global_attribute10 := idx_cur.gdf_site_use_attribute10;
         gdf_rec3.global_attribute11 := idx_cur.gdf_site_use_attribute11;
         gdf_rec3.global_attribute12 := idx_cur.gdf_site_use_attribute12;
         gdf_rec3.global_attribute13 := idx_cur.gdf_site_use_attribute13;
         gdf_rec3.global_attribute14 := idx_cur.gdf_site_use_attribute14;
         gdf_rec3.global_attribute15 := idx_cur.gdf_site_use_attribute15;
         gdf_rec3.global_attribute16 := idx_cur.gdf_site_use_attribute16;
         gdf_rec3.global_attribute17 := idx_cur.gdf_site_use_attribute17;
         gdf_rec3.global_attribute18 := idx_cur.gdf_site_use_attribute18;
         gdf_rec3.global_attribute19 := idx_cur.gdf_site_use_attribute19;
         gdf_rec3.global_attribute20 := idx_cur.gdf_site_use_attribute20;

         gdf_general_rec.core_prod_arg1  := p_sob_id;
         gdf_general_rec.core_prod_arg2  := idx_cur.rowid;
         gdf_general_rec.core_prod_arg3  := idx_cur.customer_name;
         gdf_general_rec.core_prod_arg4  := idx_cur.customer_number;
         gdf_general_rec.core_prod_arg5  := idx_cur.jgzz_fiscal_code;
         gdf_general_rec.core_prod_arg6  := l_cust_man_numbering;
         gdf_general_rec.core_prod_arg7  := idx_cur.orig_system_customer_ref;
         gdf_general_rec.core_prod_arg8  := idx_cur.insert_update_flag;
         gdf_general_rec.core_prod_arg9  := p_request_id;
         gdf_general_rec.core_prod_arg10 := idx_cur.cust_tax_reference;
         gdf_general_rec.core_prod_arg11 := 'RACUST';
--
-- Checks the validity of the attributes and performs business logic
--
             CHECK_ATTR_VALUE_AR( 'CUSTOMER',
                               gdf_rec1,
                               gdf_rec2,
                               gdf_rec3,
                               gdf_general_rec,
                               l_current_status);
         --
         -- End of modification
         --

        IF l_current_status = 'E' THEN
          l_error_count := l_error_count + 1;
        END IF;

      END LOOP;
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('check_attr_value: ' || 'Records in error = '|| l_error_count);
         END IF;

    --
    -- Modified to implement new TCA model
    --
    -- This LOOP is for RA_CUSTOMER_PROFILE_INTERFACE model.
    --
    ELSIF p_int_table_name = 'PROFILE' THEN

      OPEN generate_number;
      FETCH generate_number INTO l_cust_man_numbering;
      CLOSE generate_number;
      FOR idx_cur IN ra_customer_profiles_interface LOOP
        gdf_rec1.global_attribute_category := idx_cur.global_attribute_category;
         gdf_rec1.global_attribute1  := idx_cur.global_attribute1;
         gdf_rec1.global_attribute2  := idx_cur.global_attribute2;
         gdf_rec1.global_attribute3  := idx_cur.global_attribute3;
         gdf_rec1.global_attribute4  := idx_cur.global_attribute4;
         gdf_rec1.global_attribute5  := idx_cur.global_attribute5;
         gdf_rec1.global_attribute6  := idx_cur.global_attribute6;
         gdf_rec1.global_attribute7  := idx_cur.global_attribute7;
         gdf_rec1.global_attribute8  := idx_cur.global_attribute8;
         gdf_rec1.global_attribute9  := idx_cur.global_attribute9;
         gdf_rec1.global_attribute10 := idx_cur.global_attribute10;
         gdf_rec1.global_attribute11 := idx_cur.global_attribute11;
         gdf_rec1.global_attribute12 := idx_cur.global_attribute12;
         gdf_rec1.global_attribute13 := idx_cur.global_attribute13;
         gdf_rec1.global_attribute14 := idx_cur.global_attribute14;
         gdf_rec1.global_attribute15 := idx_cur.global_attribute15;
         gdf_rec1.global_attribute16 := idx_cur.global_attribute16;
         gdf_rec1.global_attribute17 := idx_cur.global_attribute17;
         gdf_rec1.global_attribute18 := idx_cur.global_attribute18;
         gdf_rec1.global_attribute19 := idx_cur.global_attribute19;
         gdf_rec1.global_attribute20 := idx_cur.global_attribute20;

         gdf_rec2.global_attribute_category := idx_cur.gdf_cust_prof_attr_cat;
         gdf_rec2.global_attribute1  := idx_cur.gdf_cust_prof_attribute1;
         gdf_rec2.global_attribute2  := idx_cur.gdf_cust_prof_attribute2;
         gdf_rec2.global_attribute3  := idx_cur.gdf_cust_prof_attribute3;
         gdf_rec2.global_attribute4  := idx_cur.gdf_cust_prof_attribute4;
         gdf_rec2.global_attribute5  := idx_cur.gdf_cust_prof_attribute5;
         gdf_rec2.global_attribute6  := idx_cur.gdf_cust_prof_attribute6;
         gdf_rec2.global_attribute7  := idx_cur.gdf_cust_prof_attribute7;
         gdf_rec2.global_attribute8  := idx_cur.gdf_cust_prof_attribute8;
         gdf_rec2.global_attribute9  := idx_cur.gdf_cust_prof_attribute9;
         gdf_rec2.global_attribute10 := idx_cur.gdf_cust_prof_attribute10;
         gdf_rec2.global_attribute11 := idx_cur.gdf_cust_prof_attribute11;
         gdf_rec2.global_attribute12 := idx_cur.gdf_cust_prof_attribute12;
         gdf_rec2.global_attribute13 := idx_cur.gdf_cust_prof_attribute13;
         gdf_rec2.global_attribute14 := idx_cur.gdf_cust_prof_attribute14;
         gdf_rec2.global_attribute15 := idx_cur.gdf_cust_prof_attribute15;
         gdf_rec2.global_attribute16 := idx_cur.gdf_cust_prof_attribute16;
         gdf_rec2.global_attribute17 := idx_cur.gdf_cust_prof_attribute17;
         gdf_rec2.global_attribute18 := idx_cur.gdf_cust_prof_attribute18;
         gdf_rec2.global_attribute19 := idx_cur.gdf_cust_prof_attribute19;
         gdf_rec2.global_attribute20 := idx_cur.gdf_cust_prof_attribute20;

         gdf_general_rec.core_prod_arg1  := p_sob_id;
         gdf_general_rec.core_prod_arg2  := idx_cur.rowid;
         gdf_general_rec.core_prod_arg9  := p_request_id;
         gdf_general_rec.core_prod_arg11 := 'RACUST';

--
-- Checks the validity of the attributes and performs business logic
--

         CHECK_ATTR_VALUE_AR( 'PROFILE',
                               gdf_rec1,
                               gdf_rec2,
                               gdf_rec3,
                               gdf_general_rec,
                               l_current_status);

      IF l_current_status = 'E' THEN
         l_error_count := l_error_count + 1;
      END IF;

      END LOOP;

    END IF;
    --
    -- End of modification
    --

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('Not calling JG_GLOBE_FLEX_VAL_PKG.CHECK_ATTR_VALUE');
       arp_standard.debug('check_attr_value: ' || 'Global Descr Flex Field Validation end: '
                             || to_char(sysdate, 'DD-MON-RR HH:MI:SS'));
    END IF;
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('check_attr_value: ' || 'Exception calling JG_GLOBE_FLEX_VAL.ar_cust_interface');
       arp_standard.debug('check_attr_value: ' || SQLERRM);
       arp_standard.debug('check_attr_value: ' || 'Global Descr Flex Field Validation end: '
                             || to_char(sysdate, 'DD-MON-RR HH:MI:SS'));
    END IF;
  END ar_cust_interface;


---------------------------------------------------------------------------
  -- CHECK_ATTR_VALUE_AR():
  -- This procedure validates AR global flexfield.
 --------------------------------------------------------------------------

  --
  -- Modified version of check_attr_value_ar
  --
  PROCEDURE check_attr_value_ar
     (p_int_table_name           IN     VARCHAR2,
      p_glob_attr_set1           IN     jg_globe_flex_val_shared.GdfRec,
      p_glob_attr_set2           IN     jg_globe_flex_val_shared.GdfRec,
      p_glob_attr_set3           IN     jg_globe_flex_val_shared.GdfRec,
      p_glob_attr_general        IN     jg_globe_flex_val_shared.GenRec,
      p_current_record_status    OUT NOCOPY    VARCHAR2
      ) IS

  l_current_record_status1      VARCHAR2(1);
  l_current_record_status2      VARCHAR2(1);
  PG_DEBUG varchar2(1);

  BEGIN
  PG_DEBUG := NVL(FND_PROFILE.value('AR_ENABLE_DEBUG_OUTPUT'), 'N');
  l_current_record_status1  :='S';
  l_current_record_status2  :='S';

  --arp_standard.enable_debug;
  -------------------------- DEBUG INFORMATION ---------------------------------
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Begin check_attr_value_ar procedure in JG_GLOBE_FLEX_VAL p
ackage');
  END IF;
  ------------------------------------------------------------------------------

  --
  -- Check AR Context Integrity
  --
   check_ar_context_integrity
          (p_int_table_name,
           p_glob_attr_set1,
           p_glob_attr_set2,
           p_glob_attr_set3,
           p_glob_attr_general,
           l_current_record_status1);

  --
  -- If generic validation succeeds then,check AR Business Rules
  --
  IF (l_current_record_status1 <>  'E') THEN
--Call check_ar_business_rules for customer interface
        IF p_int_table_name = 'CUSTOMER' THEN
           check_ar_business_rules
                        (p_int_table_name,
                         p_glob_attr_set1,
                         p_glob_attr_set2,
                         p_glob_attr_set3,
                         p_glob_attr_general,
                         l_current_record_status2,
                         NULL);
                IF (l_current_record_status2 = 'E') THEN
                        p_current_record_status := 'E';
                ELSE
                        p_current_record_status := 'S';
                END IF;
--Call check_ar_business_rules for customer profile interface
          ELSIF p_int_table_name='PROFILE' THEN
                check_ar_business_rules
                        (p_int_table_name,
		         p_glob_attr_set1,
                         p_glob_attr_set2,
                         p_glob_attr_set3,
                         p_glob_attr_general,
                         l_current_record_status2,
                         NULL);
                IF (l_current_record_status2 = 'E') THEN
                        p_current_record_status := 'E';
                ELSE
                        p_current_record_status := 'S';
                END IF;
          END IF;
--End of modification

  ELSE
        -- Return the error status
         p_current_record_status := 'E';
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('Exception calling JG_GLOBE_FLEX_VAL.CHECK_ATTR_VALUE_
AR()');
          arp_standard.debug('check_attr_value: ' || SQLERRM);
       END IF;
  END check_attr_value_ar;
  --
  -- End of modification
  --

  ---------------------------------------------------------------------------
  --  CHECK_AR_CONTEXT_INTEGRITY()
  --  Check ar context integrity.
  ---------------------------------------------------------------------------
  --
  -- Modified version of ar_context_integrity
  --
  PROCEDURE check_ar_context_integrity(
         p_int_table_name           IN     VARCHAR2,
         p_glob_attr_set1           IN     jg_globe_flex_val_shared.GdfRec,
         p_glob_attr_set2           IN     jg_globe_flex_val_shared.GdfRec,
         p_glob_attr_set3           IN     jg_globe_flex_val_shared.GdfRec,
         p_glob_attr_general        IN     jg_globe_flex_val_shared.GenRec,
         p_current_record_status    OUT NOCOPY    VARCHAR2) IS

  l_errcode1    varchar2(10) DEFAULT NULL;
  l_errcode     varchar2(50) DEFAULT NULL;
  PG_DEBUG varchar2(1);

  BEGIN
  PG_DEBUG := NVL(FND_PROFILE.value('AR_ENABLE_DEBUG_OUTPUT'), 'N');

  --
  -- Check whether multiple country context exists in a single record.
  --
 l_errcode1 := check_mixed_countries(p_glob_attr_set1.global_attribute_category,
                                  p_glob_attr_set2.global_attribute_category,
                               p_glob_attr_set3.global_attribute_category);

 -- Concatenate the error codes into one variable
    l_errcode := l_errcode1;

  --
  -- Reject when global attribute value found where not expected
  --
    IF p_int_table_name = 'CUSTOMER' THEN

   -- Check for JG_HZ_CUST_ACCOUNTS and not JG_RA_CUSTOMERS

   /*l_errcode1 := check_each_gdf('JG_RA_CUSTOMERS',
                                     p_glob_attr_set1,
                                     p_glob_attr_general);*/

       l_errcode1 := check_each_gdf('JG_HZ_CUST_ACCOUNTS',
                                     p_glob_attr_set1,
                                     p_glob_attr_general);

        -- Concatenate the error codes to update the STATUS column

        l_errcode := l_errcode||l_errcode1;

        -- Check for JG_HZ_CUST_ACCT_SITES and not JG_RA_ADDRESSES

        /*l_errcode1 := check_each_gdf('JG_RA_ADDRESSES',
                                     p_glob_attr_set2,
                                     p_glob_attr_general);*/

        l_errcode1 := check_each_gdf('JG_HZ_CUST_ACCT_SITES',
                                     p_glob_attr_set2,
                                     p_glob_attr_general);

        l_errcode := l_errcode||l_errcode1;

        -- Check for JG_HZ_CUST_ACCT_SITES and not JG_RA_SITE_USES

       /*l_errcode1 := check_each_gdf('JG_RA_SITE_USES',
                                     p_glob_attr_set2,
                                     p_glob_attr_general);*/


        l_errcode1 := check_each_gdf('JG_HZ_CUST_SITE_USES',
                                     p_glob_attr_set3,
                                     p_glob_attr_general);

        l_errcode := l_errcode||l_errcode1;

       -- Bugfix 1999861. Added condition to check for any error,
       -- before updating interface table.

       IF l_errcode IS NOT NULL THEN
          --
          -- Update STATUS column of the customer interface table
          --
          JG_GLOBE_FLEX_VAL_SHARED.UPDATE_RA_CUSTOMERS_INTERFACE(
                                l_errcode,
                                p_glob_attr_general.core_prod_arg2,
                                'E');
       END IF;

    ELSIF p_int_table_name = 'PROFILE' THEN

       -- Check for JG_HZ_CUSTOMER_PROFILES
       -- Since the existing global_attributes 1..20 in
       -- ra_customer_profiles_interface are used for profile amounts and
       -- gdf_cust_prof_attributes1..20 are used for customer_profiles,
       -- we are passing p_glob_attr_set2 argument for JG_HZ_CUSTOMER_PROFILES
       -- and p_glob_attr_set1 argument for JG_HZ_CUST_PROFILE_AMTS.

       /*l_errcode1 := check_each_gdf('JG_AR_CUSTOMER_PROFILES',
                                     p_glob_attr_set2,
                                     p_glob_attr_general);*/

       l_errcode1 := check_each_gdf('JG_HZ_CUSTOMER_PROFILES',
                                     p_glob_attr_set2,
                                     p_glob_attr_general);
       l_errcode := l_errcode||l_errcode1;

       -- Check for JG_HZ_CUST_PROFILE_AMNTS and not JG_AR_CUSTOMER_PROFILE_AMOUNTS

        /*l_errcode1 := check_each_gdf('JG_AR_CUSTOMER_PROFILE_AMOUNTS',
                                     p_glob_attr_set2,
                                     p_glob_attr_general);*/

       l_errcode1 := check_each_gdf('JG_HZ_CUST_PROFILE_AMTS',
                                     p_glob_attr_set1,
                                     p_glob_attr_general);
       l_errcode := l_errcode||l_errcode1;

       --
       -- Update STATUS column of the profile interface table
       --
      JG_GLOBE_FLEX_VAL_SHARED.UPDATE_INTERFACE_STATUS(
                                p_glob_attr_general.core_prod_arg2,
                                'RA_CUSTOMER_PROFILES_INTERFACE',
                                l_errcode,
                                'E');

    END IF;

    --
    -- Return the record status
    --
    IF l_errcode is NOT NULL THEN
       p_current_record_status := 'E';
    ELSE
       p_current_record_status := 'S';
    END IF;

  EXCEPTION
      WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('check_ar_context_integrity: ' || 'Exception calling JG_GLOBE_FLEX_VAL.CHECK_AR_CONTEXT
_INTEGRITY()');
           arp_standard.debug('check_ar_context_integrity: ' || SQLERRM);
        END IF;

  END check_ar_context_integrity;

  --
  -- End of modification
  --

  ---------------------------------------------------------------------------
  -- CHECK_AR_BUSINESS_RULES():
  --    This procedure validates AR global flexfield values.
  --------------------------------------------------------------------------
/*
  PROCEDURE check_ar_business_rules(
      p_calling_program_name            IN    VARCHAR2,
      p_sob_id                          IN    NUMBER,
      p_row_id                          IN    VARCHAR2,
      p_customer_name                   IN    VARCHAR2,
      p_customer_number                 IN    VARCHAR2,
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

  l_current_record_status       VARCHAR2(1):='S';

 BEGIN
  -------------------------- DEBUG INFORMATION ------------------------------
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('check_ar_business_rules: ' || 'Begin Check ar business rules');
  END IF;
  ---------------------------------------------------------------------------

  ------------------------------------------------------------------------------
--------
  --                         Global Flexfield Validation
  ------------------------------------------------------------------------------
--------
  --  You can add your own validation code for your global flexfields.
  --
  --  Form Name:  ARXCUDCI
  ------------------------------------------------------------------------------
--------
  --   Header Level Validation - Block Name: CUST
  ------------------------------------------------------------------------------
--------
  --    1-1. JL.CL.ARXCUDCI.CUSTOMERS
  --    1-2. JL.CO.ARXCUDCI.CUSTOMERS
  --    1-3. JL.AR.ARXCUDCI.CUSTOMERS
  --    1-4. JL.BR.ARXCUDCI.Additional
--------------------------------------------------------------------------------
------

  --    1-1. JL.CL.ARXCUDCI.RA_CUSTOMERS
  --
  IF (p_global_attribute_category in ( 'JL.CL.ARXCUDCI.CUSTOMERS',
                                       'JL.CO.ARXCUDCI.CUSTOMERS',
                                       'JL.BR.ARXCUDCI.Additional',
                                       'JL.AR.ARXCUDCI.CUSTOMERS')) THEN
   jl_interface_val.ar_business_rules(
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
  END IF;

      p_current_record_status := l_current_record_status;

  EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Exception in JG_GLOBE_FLEX_VAL.CHECK_AR_BUSINESS_RULES()');
         arp_standard.debug('check_ar_business_rules: ' || SQLERRM);
      END IF;
  END check_ar_business_rules;
*/

--
-- Modified version of check_ar_business_rules
--
  PROCEDURE check_ar_business_rules(
      p_int_table_name            IN    VARCHAR2,
      p_glob_attr_set1            IN    jg_globe_flex_val_shared.GdfRec,
      p_glob_attr_set2            IN    jg_globe_flex_val_shared.GdfRec,
      p_glob_attr_set3            IN    jg_globe_flex_val_shared.GdfRec,
      p_glob_attr_general         IN    jg_globe_flex_val_shared.GenRec,
      p_current_record_status     OUT NOCOPY   VARCHAR2,
      p_org_id                    IN  NUMBER ) IS --2354736


  l_current_record_status  VARCHAR2(1);
  l_product_code           VARCHAR2(10);
  l_org_id                 NUMBER;
  PG_DEBUG varchar2(1);

 BEGIN

  PG_DEBUG := NVL(FND_PROFILE.value('AR_ENABLE_DEBUG_OUTPUT'), 'N');

  if p_org_id is null then
    --l_org_id :=  to_number(fnd_profile.value ('ORG_ID'));
    --
    --Bug 4499004
    --
    SELECT org_id into l_org_id FROM fnd_concurrent_requests
    WHERE request_id = fnd_global.conc_request_id ;

    fnd_request.set_org_id(l_org_id);
  end if;

  l_current_record_status  := 'S';
  --2354736
  l_product_code := JG_ZZ_SHARED_PKG.GET_PRODUCT(l_org_id,NULL, null);

  --IF sys_context('JG',l_product_code) = 'JA' THEN  --2354736
  IF l_product_code = 'JA' THEN
  --IF sys_context('JG','JGZZ_PRODUCT_CODE') = 'JA' THEN

    ja_interface_val.ar_business_rules(
                  'CUSTOMER',
                  p_glob_attr_set1,
                  p_glob_attr_set2,
                  p_glob_attr_set3,
                  p_glob_attr_general,
                  l_current_record_status);

--Validate for the customer address and customer profile
  --ELSIF sys_context('JG',l_product_code) = 'JL' THEN  --2354736
  ELSIF l_product_code = 'JL' THEN
  --ELSIF sys_context('JG','JGZZ_PRODUCT_CODE') = 'JL' THEN

           jl_interface_val.ar_business_rules(
    		p_int_table_name,
    		p_glob_attr_set1,
    		p_glob_attr_set2,
    		p_glob_attr_set3,
    		p_glob_attr_general,
	        l_current_record_status);
          --Validate for the customer in JE Amar added
    ELSIF l_product_code = 'JE' THEN
  --ELSIF sys_context('JG',l_product_code) = 'JE' THEN  --2354736
  --ELSIF sys_context('JG','JGZZ_PRODUCT_CODE') = 'JE' THEN
          je_interface_val.ar_business_rules(
               'CUSTOMER',
               p_glob_attr_set1,
               p_glob_attr_set2,
               p_glob_attr_set3,
               p_glob_attr_general,
               l_current_record_status);
           -- End Validate for the customer in JE Amar Added.

   END IF;

  p_current_record_status := l_current_record_status;

  EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Exception in JG_GLOBE_FLEX_VAL.CHECK_AR_BUSINESS_RULES()');
         arp_standard.debug('check_ar_business_rules: ' || SQLERRM);
      END IF;
  END check_ar_business_rules;


--
-- End of modification
--

-- The Following procedure is stubbed out due to the obsoletion of table jg_zz_invoice_info.
-- The table was used in the different EFT solution in JE and this functionality is now
-- covered in Oracle Payments.

PROCEDURE insert_jg_zz_invoice_info
     (p_invoice_id                      IN     NUMBER,
      p_global_attribute_category       IN OUT NOCOPY VARCHAR2,
      p_global_attribute1               IN OUT NOCOPY VARCHAR2,
      p_global_attribute2               IN OUT NOCOPY VARCHAR2,
      p_global_attribute3               IN OUT NOCOPY VARCHAR2,
      p_global_attribute4               IN OUT NOCOPY VARCHAR2,
      p_global_attribute5               IN OUT NOCOPY VARCHAR2,
      p_global_attribute6               IN OUT NOCOPY VARCHAR2,
      p_global_attribute7               IN OUT NOCOPY VARCHAR2,
      p_global_attribute8               IN OUT NOCOPY VARCHAR2,
      p_global_attribute9               IN OUT NOCOPY VARCHAR2,
      p_global_attribute10              IN OUT NOCOPY VARCHAR2,
      p_global_attribute11              IN OUT NOCOPY VARCHAR2,
      p_global_attribute12              IN OUT NOCOPY VARCHAR2,
      p_global_attribute13              IN OUT NOCOPY VARCHAR2,
      p_global_attribute14              IN OUT NOCOPY VARCHAR2,
      p_global_attribute15              IN OUT NOCOPY VARCHAR2,
      p_global_attribute16              IN OUT NOCOPY VARCHAR2,
      p_global_attribute17              IN OUT NOCOPY VARCHAR2,
      p_global_attribute18              IN OUT NOCOPY VARCHAR2,
      p_global_attribute19              IN OUT NOCOPY VARCHAR2,
      p_global_attribute20              IN OUT NOCOPY VARCHAR2,
      p_last_updated_by                 IN     NUMBER,
      p_last_update_date                IN     DATE,
      p_last_update_login               IN     NUMBER,
      p_created_by                      IN     NUMBER,
      p_creation_date                   IN     DATE,
      p_calling_sequence                IN     VARCHAR2) IS

        l_debug_loc                     VARCHAR2(30);
        l_curr_calling_sequence         VARCHAR2(2000);
        l_debug_info                    VARCHAR2(100);
   PG_DEBUG varchar2(1);

  BEGIN
	NULL;
--  PG_DEBUG := NVL(FND_PROFILE.value('AR_ENABLE_DEBUG_OUTPUT'), 'N');
--        l_debug_loc   := 'Insert_Jg_Zz_Invoice_Info';
--
--    -------------------------- DEBUG INFORMATION ------------------------------
--    l_curr_calling_sequence := 'jg_globe_flex_val.'||l_debug_loc||'<-'||p_calling_sequence;
--    l_debug_info := 'Insert invoices to jg_zz_invice_info';
--    ---------------------------------------------------------------------------
--  IF p_global_attribute_category IN ('BE.EFT Payments','CH.Swiss DTA Payment','CH.Swiss SAD Payment',
--                                     'DK','DK.GiroBank Domestic','DK.GiroBank Foreign',
--                                     'DK.Unitel Domestic','DK.Unitel Foreign','FI.A-lomake',
--                                     'FI.B-lomake','FI.Konekielinen viite','FI.Vapaa viite',
--                                     'NL.Foreign Payments','NO','NO.Norway',
--                                     'SE.Bankgiro SISU','SE.Bankgiro UTLI','SE.Postgiro Inland',
--                                    'SE.Postgiro Utland' , 'SE.Bankgiro Inland') THEN
--    INSERT INTO jg_zz_invoice_info
--       (invoice_id,
--       jgzz_attribute_category,
--        jgzz_invoice_info1,
--        jgzz_invoice_info2,
--        jgzz_invoice_info3,
--        jgzz_invoice_info4,
--        jgzz_invoice_info5,
--        jgzz_invoice_info6,
--        jgzz_invoice_info7,
--        jgzz_invoice_info8,
--        jgzz_invoice_info9,
--        jgzz_invoice_info10,
--        jgzz_invoice_info11,
--        jgzz_invoice_info12,
--        jgzz_invoice_info13,
--        jgzz_invoice_info14,
--        jgzz_invoice_info15,
--        jgzz_invoice_info16,
--        jgzz_invoice_info17,
--        jgzz_invoice_info18,
--        jgzz_invoice_info19,
--        jgzz_invoice_info20, --This table has up to 30 columns,however
--        last_updated_by,     --column 21 thru 30 are invalid since the
--        last_update_date,    --base table has only 20 global flexfields.
--        last_update_login,   --Hence, no insertion to those columns are
--        created_by,          --required. Their values will always be null.
--        creation_date)       -- Agreed by Jason.
--    SELECT
--        p_invoice_id,
--        p_global_attribute_category,
--        p_global_attribute1,
--        p_global_attribute2,
--        p_global_attribute3,
--        p_global_attribute4,
--        p_global_attribute5,
--        p_global_attribute6,
--        p_global_attribute7,
--        p_global_attribute8,
--        p_global_attribute9,
--        p_global_attribute10,
--        p_global_attribute11,
--        p_global_attribute12,
--        p_global_attribute13,
--        p_global_attribute14,
--        p_global_attribute15,
--        p_global_attribute16,
--        p_global_attribute17,
--        p_global_attribute18,
--        p_global_attribute19,
--        p_global_attribute20,
--        p_last_updated_by,
--        DECODE(p_last_update_date,NULL,sysdate,p_last_update_date),
--        p_last_update_login,
--        p_created_by,
--        DECODE(p_creation_date,NULL,sysdate,p_creation_date)
--    FROM DUAL;
--
--        p_global_attribute_category := NULL;
--        p_global_attribute1         := NULL;
--        p_global_attribute2         := NULL;
--        p_global_attribute3         := NULL;
--        p_global_attribute4         := NULL;
--        p_global_attribute5         := NULL;
--        p_global_attribute6         := NULL;
--        p_global_attribute7         := NULL;
--        p_global_attribute8         := NULL;
--        p_global_attribute9         := NULL;
--        p_global_attribute10        := NULL;
--        p_global_attribute11        := NULL;
--        p_global_attribute12        := NULL;
--        p_global_attribute13        := NULL;
--        p_global_attribute14        := NULL;
--        p_global_attribute15        := NULL;
--        p_global_attribute16        := NULL;
--        p_global_attribute17        := NULL;
--        p_global_attribute18        := NULL;
--        p_global_attribute19        := NULL;
--        p_global_attribute20        := NULL;
--
--  END IF;
--  EXCEPTION
--    WHEN OTHERS THEN
--      IF (SQLCODE <> -20001) THEN
--        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
--        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
--        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
--        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
--      END IF;
--      APP_EXCEPTION.RAISE_EXCEPTION;
  END;

  PROCEDURE insert_global_tables
     (p_table_name        IN VARCHAR2,
      p_key_column1       IN VARCHAR2,
      p_key_column2       IN VARCHAR2,
      p_key_column3       IN VARCHAR2,
      p_key_column4       IN VARCHAR2,
      p_key_column5       IN VARCHAR2,
      p_key_column6       IN VARCHAR2) IS

    l_product_code  VARCHAR2(2);
  PG_DEBUG varchar2(1);

  BEGIN
  PG_DEBUG := NVL(FND_PROFILE.value('AR_ENABLE_DEBUG_OUTPUT'), 'N');

    l_product_code := fnd_profile.value('JG_PRODUCT_CODE');

    IF l_product_code = 'JL' THEN
      --
      -- Call jl cover package
      --
      -- jl_interface_val.insert_global_tables(
      --                  p_table_name
      --                 ,p_key_column1
      --                 ,p_key_column2
      --                 ,p_key_column3
      --                 ,p_key_column4
      --                 ,p_key_column5
      --                 ,p_key_column6
      --
      NULL;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      arp_standard.debug('Exception calling JG_GLOBE_FLEX_VAL.insert_global_tabl
es');
      arp_standard.debug(SQLERRM);
      app_exception.raise_exception;
  END;

-- Bug 8859419 Start

   -- Evaluates whether a specific GDF context exists                 |

   Function Gdf_Context_Exists(p_gdf_context IN Varchar2) Return Boolean IS
      /* Checks whether the context is enabled for the country. It checks the contexts
         only for the JG_RA_CUSTOMER_TRX_LINES gdf. */

      --Bug 9080741 Modified cursor to be generic for all countries
      Cursor C_Gdf_Context Is
          Select 'Yes' exist_flag
          From fnd_descr_flex_contexts
          Where application_id  = 7003
          And descriptive_flexfield_name like 'JG_AP_INVOICE_DISTRIBUTIONS'
          And descriptive_flex_context_code = p_gdf_context
          --And substr(descriptive_flex_context_code, 4, 2) =  cp_country_code
          and enabled_flag = 'Y';
      l_exist Varchar2(30);
      l_country_code Varchar2(30);
      l_api_name CONSTANT VARCHAR2(200) := 'Gdf_Context_Exists';
      l_debug_info Varchar2(2000);
   Begin
      l_debug_info := 'Begining of Function';
      If (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) Then
         Fnd_Log.String(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      End If;

      l_exist := 'No';

      --Bug 9080741
      --fnd_profile.get('JGZZ_COUNTRY_CODE', l_country_code);
      --l_debug_info := 'Country Code is : ' || l_country_code;
      --If (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) Then
        -- Fnd_Log.String(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      --End If;

      --If (l_country_code = 'AR') THEN --Bug 9080741
         l_debug_info := 'Index Value : ' || p_gdf_context;
         If (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) Then
            Fnd_Log.String(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
         End If;
         If G_GDF_CONTEXT_T.Count > 0 Then
            If G_GDF_CONTEXT_T.Exists(p_gdf_context) Then
               l_exist := 'Yes';
               l_debug_info := 'GDF Context ' || p_gdf_context || ' found in the PL/SQL Table' ;
               If (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) Then
                  Fnd_Log.String(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
               End If;
            Else
               For C_Gdf_Context_Rec in C_Gdf_Context Loop
                  G_GDF_CONTEXT_T(p_gdf_context).global_attribute_category := p_gdf_context;
                  l_exist := C_Gdf_Context_Rec.exist_flag;
                  l_debug_info := 'GDF Context ' || p_gdf_context || ' found in the Database' ;
                  If (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) Then
                     Fnd_Log.String(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                  End If;
               End Loop;
            End If;
         Else
            For C_Gdf_Context_Rec in C_Gdf_Context Loop
               G_GDF_CONTEXT_T(p_gdf_context).global_attribute_category := p_gdf_context;
               l_exist := C_Gdf_Context_Rec.exist_flag;
               l_debug_info := 'GDF Context ' || p_gdf_context || ' found in the Database' ;
               If (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) Then
                  Fnd_Log.String(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
               End If;
            End Loop;
         End If;
      --End If;
      If upper(l_exist) = 'YES' THEN
         l_debug_info := 'GDF Context ' || p_gdf_context || ' found, returning TRUE' ;
         If (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) Then
            Fnd_Log.String(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
         End If;
         Return TRUE;
      Else
         l_debug_info := 'GDF Context ' || p_gdf_context || ' not found , returning FALSE' ;
         If (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) Then
             Fnd_Log.String(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
         End If;
         Return FALSE;
      End If;
   Exception
      When Others Then
         l_debug_info := 'Exception Encountered, returning FALSE' ;
         If (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            Fnd_Log.String(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
         End If;
         Return FALSE;
   End Gdf_Context_Exists;

-- Bug 8859419 End
END jg_globe_flex_val;

/
