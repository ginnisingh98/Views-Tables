--------------------------------------------------------
--  DDL for Package Body OKL_ST_CODE_CONVERSIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ST_CODE_CONVERSIONS" AS
/* $Header: OKLRSCCB.pls 120.14.12010000.2 2009/01/19 12:57:39 rgooty ship $ */

  PROCEDURE CONVERT_DATE(p_date            IN     DATE,
                         p_date_format     IN     VARCHAR2,
                         x_char_date       OUT NOCOPY   VARCHAR2)
  IS
  BEGIN
    IF p_date_format IS NOT NULL THEN
      x_char_date := TO_CHAR(p_date,p_date_format);
    ELSE
      x_char_date := TO_CHAR(p_date,G_DEFAULT_DATE_FORMAT);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_char_date := TO_CHAR(p_date,G_DEFAULT_DATE_FORMAT);
  END CONVERT_DATE;

  PROCEDURE TRANSLATE_COUNTRY(p_country IN VARCHAR2,
                              x_country OUT NOCOPY VARCHAR2)
  IS
  l_amp VARCHAR2(1) := '&';
  BEGIN
      IF p_country = 'US' THEN
       x_country := 'U.S.';
      ELSIF p_country = 'AU' THEN
       x_country := 'Australia';
      ELSIF p_country = 'AU' THEN
       x_country := 'Australia';
      ELSIF p_country = 'BE' THEN
       x_country := 'Belgium';
      ELSIF p_country = 'CA' THEN
       x_country := 'Canada';
      ELSIF p_country = 'CN' THEN
       x_country := 'China';
      ELSIF p_country = 'GB' THEN
       x_country := 'United Kingdom';
      ELSIF p_country = 'FR' THEN
       x_country := 'France';
      ELSIF p_country = 'DE' THEN
       x_country := 'Germany';
      ELSIF p_country = 'HK' THEN
       x_country := 'Hong Kong';
      ELSIF p_country = 'IN' THEN
       x_country := 'India';
      ELSIF p_country = 'ID' THEN
       x_country := 'Indonesia';

      ELSIF p_country = 'IE' THEN
       x_country := 'Ireland';
      ELSIF p_country = 'JP' THEN
       x_country := 'Japan';
      ELSIF p_country = 'MX' THEN
       x_country := 'Mexico';
      ELSIF p_country = 'NL' THEN
       x_country := 'Netherlands';
      ELSIF p_country = 'ES' THEN
       x_country := 'Spain';
      ELSIF p_country = 'SE' THEN
       x_country := 'Sweden';
      ELSIF p_country = 'CH' THEN
       x_country := 'Switzerland';
      ELSIF p_country = 'TH' THEN
       x_country := 'Thailand';
      ELSIF p_country = 'PR' THEN
       x_country := 'Puerto Rico';
      ELSIF p_country = 'AR' THEN
       x_country := 'Argentina';
      ELSIF p_country = 'SG' THEN
       x_country := 'Singapore';
      ELSIF p_country = 'BR' THEN
       x_country := 'Brazil';
      ELSIF p_country = 'DK' THEN
       x_country := 'Denmark';
      ELSIF p_country = 'AT' THEN
       x_country := 'Austria';
      ELSIF p_country = 'NO' THEN
       x_country := 'Norway';
      ELSIF p_country = 'FI' THEN
       x_country := 'Finland';
      ELSIF p_country = 'IT' THEN
       x_country := 'Italy';
      ELSE
        x_country := l_amp || 'lt;none' || l_amp || 'gt;';
      END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_country := p_country;
  END TRANSLATE_COUNTRY;

  PROCEDURE TRANSLATE_IRS_TAX_TREATMENT(p_irs_tax_treatment IN VARCHAR2,
                                        x_irs_tax_treatment OUT NOCOPY VARCHAR2)
  IS
  BEGIN

      IF p_irs_tax_treatment = 'LESSOR' THEN
        x_irs_tax_treatment := 'Lease';
      ELSIF p_irs_tax_treatment = 'LESSEE' THEN
        x_irs_tax_treatment := 'CSA';
      ELSE
        x_irs_tax_treatment := 'Unknown';
      END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_irs_tax_treatment := p_irs_tax_treatment;
  END TRANSLATE_IRS_TAX_TREATMENT;
 -- gboomina BUG#4508077 modified the signature to include RVI_YN
  PROCEDURE TRANSLATE_FASB_TREATMENT(p_fasb_treatment IN VARCHAR2,
                                        p_rvi_yn  IN VARCHAR2,
                                        x_fasb_treatment OUT NOCOPY VARCHAR2)
  IS
  BEGIN
 -- gboomina BUG#4508077 if RVI flag is set to yes then return blank
      IF p_rvi_yn = G_FND_YES THEN
	x_fasb_treatment := ' ';
      ELSIF p_fasb_treatment = 'LEASEOP' THEN
        x_fasb_treatment := 'Operating lease';
      ELSIF  p_fasb_treatment = 'LEASEDF' THEN
         x_fasb_treatment := 'Capital: Single investor (DFL)';
      ELSIF  p_fasb_treatment = 'LEASEST' THEN
        x_fasb_treatment := 'Capital: Single investor (DFL)';
      ELSIF  p_fasb_treatment = 'LOAN' THEN
        x_fasb_treatment := 'Capital: Loan';
      ELSE
        x_fasb_treatment := 'not defined';
      END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_fasb_treatment := p_fasb_treatment;
  END TRANSLATE_FASB_TREATMENT;

  --Added by dkagrawa on 06-Oct-2005. Overloaded method added when p_rvi_yn is not passed
  --Bug 4654549 - Start of Changes
  PROCEDURE TRANSLATE_FASB_TREATMENT(p_fasb_treatment IN VARCHAR2,
                                     x_fasb_treatment OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    IF p_fasb_treatment = 'LEASEOP' THEN
      x_fasb_treatment := 'Operating lease';
    ELSIF  p_fasb_treatment = 'LEASEDF' THEN
      x_fasb_treatment := 'Capital: Single investor (DFL)';
    ELSIF  p_fasb_treatment = 'LEASEST' THEN
      x_fasb_treatment := 'Capital: Single investor (DFL)';
    ELSIF  p_fasb_treatment = 'LOAN' THEN
      x_fasb_treatment := 'Capital: Loan';
    ELSE
      x_fasb_treatment := 'not defined';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_fasb_treatment := p_fasb_treatment;
  END TRANSLATE_FASB_TREATMENT;
  --Bug 4654549 - End of Changes

  PROCEDURE TRANSLATE_PURCHASE_OPTION(p_purchase_option IN VARCHAR2,
                                      x_purchase_option OUT NOCOPY VARCHAR2)
  IS
  BEGIN

      IF p_purchase_option = 'FMV' THEN
        x_purchase_option := 'FMV';
      ELSIF p_purchase_option = 'FPO' THEN
        x_purchase_option := 'Fixed';
      ELSIF p_purchase_option = 'NONE' THEN
        x_purchase_option := 'None';
      ELSIF p_purchase_option = '$1BO' THEN
        x_purchase_option := 'Fixed';
      ELSIF p_purchase_option = 'FRV' THEN
        x_purchase_option := 'None';
      ELSIF p_purchase_option = 'MONTHLY' THEN
        x_purchase_option := 'None';
      ELSE

              x_purchase_option := 'None';
      END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_purchase_option := p_purchase_option;
  END TRANSLATE_PURCHASE_OPTION;

  PROCEDURE TRANSLATE_DEPRECIATION_METHOD(p_depreciation_method IN VARCHAR2,
                                          x_depreciation_method OUT NOCOPY VARCHAR2,
					  p_term IN NUMBER,
			                  x_term OUT NOCOPY VARCHAR2,
					  p_salvage IN NUMBER,
					  x_salvage OUT NOCOPY NUMBER,
					  p_adr_convention IN VARCHAR2,
					  x_adr_convention OUT NOCOPY VARCHAR2)
  IS

    CURSOR l_okl_depre_method_csr(p_id VARCHAR2)
	IS
	SELECT VALUE
	FROM   OKL_SGN_TRANSLATIONS
	WHERE  JTOT_OBJECT1_CODE = 'FA_METHODS'
	AND object1_id1 = p_id;

	l_id VARCHAR2(30);

	l_method_strline  VARCHAR2(20)  := 'Str line, to end';
	l_method_acrs3yr  VARCHAR2(20)  := 'ACRS  3 yr';
	l_method_acrs5yr  VARCHAR2(20)  := 'ACRS  5 yr';
	l_method_acrs10yr VARCHAR2(20)  := 'ACRS 10 yr';
	l_method_acrs15yr VARCHAR2(20)  := 'ACRS 15 yr';
	l_adr_convention  VARCHAR2(100) := null;
  BEGIN
      IF p_depreciation_method IS NOT NULL THEN
	    l_id := p_depreciation_method;
	    OPEN l_okl_depre_method_csr(l_id);
		FETCH l_okl_depre_method_csr INTO x_depreciation_method;
		CLOSE l_okl_depre_method_csr;

		IF x_depreciation_method IS NOT NULL THEN
 		  -- Handle return value for Term
		  IF x_depreciation_method = l_method_strline  OR
		     x_depreciation_method = l_method_acrs3yr  OR
		     x_depreciation_method = l_method_acrs5yr  OR
		     x_depreciation_method = l_method_acrs10yr OR
		     x_depreciation_method = l_method_acrs15yr
          THEN
		    x_term := null;
		  ELSE
		    x_term := p_term/12;
		  END IF;

		  -- Handle return value for Salvage
		  IF  x_depreciation_method = l_method_acrs3yr  OR
		      x_depreciation_method = l_method_acrs5yr  OR
		      x_depreciation_method = l_method_acrs10yr OR
		      x_depreciation_method = l_method_acrs15yr
		  THEN
		    x_salvage := null;
		  ELSE
		    x_salvage := p_salvage;
		  END IF;

		  -- Handle return value for ADR Convention
		  IF  x_depreciation_method = l_method_acrs3yr  OR
		      x_depreciation_method = l_method_acrs5yr  OR
		      x_depreciation_method = l_method_acrs10yr OR
	  	      x_depreciation_method = l_method_acrs15yr
		  THEN
		    x_adr_convention := null;
		  ELSE
		    IF p_adr_convention IS NOT NULL THEN
		      TRANSLATE_DEPRE_ADRCONVENTION(p_adr_convention, l_adr_convention);
			END IF;
		    x_adr_convention := l_adr_convention;
		  END IF;
		END IF;
      END IF;
  EXCEPTION
    WHEN OTHERS THEN
	  IF l_okl_depre_method_csr%isopen THEN
	    CLOSE l_okl_depre_method_csr;
	  END IF;
      x_depreciation_method := p_depreciation_method;
      x_term := p_term/12;
  END TRANSLATE_DEPRECIATION_METHOD;

  PROCEDURE TRANSLATE_DEPRE_ADRCONVENTION(p_depreciation_adrconvention IN VARCHAR2,
                                          x_depreciation_adrconvention OUT NOCOPY VARCHAR2)
  IS
    CURSOR l_okl_depre_convention_csr(p_id VARCHAR2)
	IS
	SELECT VALUE
	FROM   OKL_SGN_TRANSLATIONS
	WHERE  JTOT_OBJECT1_CODE = 'FA_CONVENTION_TYPES'
	AND object1_id1 = p_id;

	l_id VARCHAR2(30);

  BEGIN
      IF p_depreciation_adrconvention IS NOT NULL THEN
	    l_id := p_depreciation_adrconvention;
	    OPEN l_okl_depre_convention_csr(l_id);
		FETCH l_okl_depre_convention_csr INTO x_depreciation_adrconvention;
		CLOSE l_okl_depre_convention_csr;
      END IF;
  EXCEPTION
    WHEN OTHERS THEN
	  IF l_okl_depre_convention_csr%isopen THEN
	    CLOSE l_okl_depre_convention_csr;
	  END IF;
      x_depreciation_adrconvention := p_depreciation_adrconvention;
  END TRANSLATE_DEPRE_ADRCONVENTION;


  PROCEDURE TRANSLATE_YN(p_yn IN VARCHAR2,
                         x_yn OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    IF p_yn = G_FND_YES
    THEN
     x_yn  := G_CSM_TRUE;
    ELSE
      x_yn := G_CSM_FALSE;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_yn := p_yn;
  END TRANSLATE_YN;

  PROCEDURE TRANSLATE_PERIODICITY(p_periodicity IN VARCHAR2,
                                  x_periodicity OUT NOCOPY VARCHAR2)
  IS
  BEGIN
      IF p_periodicity = 'A' THEN
        x_periodicity := 'Annual';
      ELSIF p_periodicity = 'S' THEN
        x_periodicity := 'Semiannual';
      ELSIF p_periodicity = 'Q' THEN
        x_periodicity := 'Quarterly';
      ELSIF p_periodicity = 'M' THEN
        x_periodicity := 'Monthly';
	  ELSIF p_periodicity = 'T' THEN -- smahapat fee type soln
	    x_periodicity := 'Stub';
      END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_periodicity := p_periodicity;
  END TRANSLATE_PERIODICITY;

  PROCEDURE TRANSLATE_STRUCTURE(p_structure IN VARCHAR2,
                                  x_structure OUT NOCOPY VARCHAR2)
  IS
    l_amp VARCHAR2(1) := '&';

  BEGIN
    IF p_structure = '1' THEN
     x_structure := '1st ' || l_amp || ' last';
    ELSIF p_structure = '2' THEN
     x_structure := '1st ' || l_amp || ' last 2';
    ELSIF p_structure = '3' THEN
     x_structure := '1st ' || l_amp || ' last 3';
    ELSE
-- by default strucutre would be null
-- added akjain 06-16-2002
       x_structure := NULL ;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_structure := p_structure;

  END TRANSLATE_STRUCTURE;

  PROCEDURE TRANSLATE_STREAM_TYPE(p_stream_type_name IN VARCHAR2,
                                  p_sfe_type IN VARCHAR2,
                                  x_stream_type_name OUT NOCOPY VARCHAR2,
								  x_stream_type_desc OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    -- special cases
    IF p_stream_type_name = 'AMORTIZED FEE INCOME' AND
	   p_sfe_type = OKL_SFE_PVT.G_SFE_TYPE_ONE_OFF THEN
	 x_stream_type_name := 'Single Fee Accrual';
    ELSIF p_stream_type_name = 'FEE INCOME' AND
	      p_sfe_type = 'SFI' THEN
     x_stream_type_name := 'Single Periodic Income Accrual';
	-- end special cases
	ELSIF p_sfe_type = OKL_SFE_PVT.G_SFE_TYPE_ONE_OFF
    OR p_stream_type_name = 'RATE PARTICIPATION'
    OR p_stream_type_name = 'RESIDUAL VALUE INSURANCE PREMIUM' THEN
     x_stream_type_name := 'Fee';

	-- removed since no periodic expense stream is generated
    --ELSIF p_sfe_type = OKL_SFE_PVT.G_SFE_TYPE_PERIODIC_EXPENSE THEN
     --x_stream_type_name := 'Periodic Expenses';
    ELSIF p_sfe_type = OKL_SFE_PVT.G_SFE_TYPE_PERIODIC_INCOME THEN
     x_stream_type_name := 'Periodic Income';
    ELSIF p_sfe_type = OKL_SFE_PVT.G_SFE_TYPE_SUBSIDY THEN
	 x_stream_type_name := 'Single Subsidy Accrual';
    ELSIF p_sfe_type = OKL_SFE_PVT.G_SFE_TYPE_RENT THEN
     x_stream_type_name := 'Rent';
    ELSIF p_stream_type_name = 'RENT' THEN
     x_stream_type_name := 'Rent';

   ELSIF p_stream_type_name = 'PRINCIPAL BALANCE' THEN
     x_stream_type_name := 'Lending Loans Balance';

    ELSIF p_stream_type_name = 'INTEREST PAYMENT' THEN
     x_stream_type_name := 'Lending Loans Interest';
    ELSIF p_stream_type_name = 'PRINCIPAL PAYMENT' THEN
     x_stream_type_name := 'Lending Loans Principal';
    ELSIF p_stream_type_name = 'RENTAL ACCRUAL' THEN
     --smahapat 02/12/03 bugfix# 2790764
     --x_stream_type_name := 'GL Rent Receivable Credits';
     x_stream_type_name := 'GL Book Rent';
    ELSIF p_stream_type_name = 'FAS 91 FEE INCOME' THEN
     x_stream_type_name := 'Initial Direct Costs';
    ELSIF p_stream_type_name = 'PRE-TAX INCOME' THEN
     --x_stream_type_name := 'GL Income Earned';
    --smahapat fixed bug 2826926
     x_stream_type_name := 'GL Income Recognized';
    ELSIF p_stream_type_name = 'UNEARNED INCOME' THEN
     x_stream_type_name := 'GL Income Unearned';
     --x_stream_type_name := 'GL Income Recognized';
    ELSIF p_stream_type_name = 'TERMINATION VALUE' THEN
     x_stream_type_name := 'Termination Value';
    ELSIF p_stream_type_name = 'STIP LOSS VALUE' THEN
-- modified to fix bug #  2440390
     x_stream_type_name := 'StipLoss Value';
    ELSIF p_stream_type_name = 'BOOK DEPRECIATION' THEN
     x_stream_type_name := 'Book Depreciation';
    ELSIF p_stream_type_name = 'FEDERAL DEPRECIATION' THEN
     x_stream_type_name := 'Federal Depreciation';
    ELSIF p_stream_type_name = 'STATE DEPRECIATION' THEN
     x_stream_type_name := 'State Depreciation';
	-- mvasudev, 07/18/2002
    ELSIF p_stream_type_name = 'LOAN PAYMENT' THEN
     x_stream_type_name := 'Lending Loans Debt Service';
	 -- smahapat 02/14/2003 bugfix# 2790695
    ELSIF p_stream_type_name = 'FEE INCOME' THEN
	 x_stream_type_name := 'Single Periodic Income Accrual';
    --ELSIF p_stream_type_name = 'AMORTIZED FEE INCOME' THEN
	 --x_stream_type_name := 'Single Fee Accrual';
    ELSIF p_stream_type_name = 'INTEREST INCOME' THEN
	 x_stream_type_name := 'Single Lending Loan Accrual';
    ELSIF p_stream_type_name = 'PERIODIC EXPENSE PAYABLE' THEN
	 x_stream_type_name := 'Single Periodic Expense Accrual';
	 -- smahapat fee type solution
    ELSIF p_stream_type_name = 'SECURITY DEPOSIT' THEN
	 x_stream_type_name := 'Security Deposits';
     ELSE
     x_stream_type_name := p_stream_type_name;
    END IF;

	IF p_stream_type_name = 'RESIDUAL VALUE INSURANCE PREMIUM' THEN
	 x_stream_type_desc := 'Residual Insurance Premium';
	ELSE
	 x_stream_type_desc := p_stream_type_name;
	END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_stream_type_name := p_stream_type_name;
      x_stream_type_desc := p_stream_type_name;

  END TRANSLATE_STREAM_TYPE;

  PROCEDURE TRANSLATE_STREAM_TYPE(p_stream_type_name IN VARCHAR2,
                                  p_sfe_type IN VARCHAR2,
								  p_sil_type IN VARCHAR2,
                                  x_stream_type_name OUT NOCOPY VARCHAR2,
	                              x_stream_type_desc OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    -- special cases
    IF p_stream_type_name = 'AMORTIZED FEE INCOME' AND
	   p_sfe_type = OKL_SFE_PVT.G_SFE_TYPE_ONE_OFF THEN
	 x_stream_type_name := 'Single Fee Accrual';
    ELSIF p_stream_type_name = 'FEE INCOME' AND
	      p_sfe_type = OKL_SFE_PVT.G_SFE_TYPE_PERIODIC_INCOME THEN
     x_stream_type_name := 'Single Periodic Income Accrual';
	ELSIF p_stream_type_name = 'PRE-TAX INCOME' AND
	      p_sil_type = OKL_SIL_PVT.G_SIL_TYPE_LEASE THEN
	 x_stream_type_name := 'Single Rent Accrual';
	ELSIF p_stream_type_name = 'PRE-TAX INCOME' THEN
	 x_stream_type_name := 'Single Lending Loan Accrual';
	-- end special cases
	ELSIF p_sfe_type = OKL_SFE_PVT.G_SFE_TYPE_ONE_OFF
    OR p_stream_type_name = 'RATE PARTICIPATION'
    OR p_stream_type_name = 'RESIDUAL VALUE INSURANCE PREMIUM' THEN
     x_stream_type_name := 'Fee';

	-- removed since no periodic expense stream is generated
    --ELSIF p_sfe_type = OKL_SFE_PVT.G_SFE_TYPE_PERIODIC_EXPENSE THEN
     --x_stream_type_name := 'Periodic Expenses';
    ELSIF p_sfe_type = OKL_SFE_PVT.G_SFE_TYPE_PERIODIC_INCOME THEN
     x_stream_type_name := 'Periodic Income';
    ELSIF p_sfe_type = OKL_SFE_PVT.G_SFE_TYPE_SUBSIDY THEN
	 x_stream_type_name := 'Single Subsidy Accrual';
    ELSIF p_sfe_type = OKL_SFE_PVT.G_SFE_TYPE_RENT THEN
     x_stream_type_name := 'Rent';
    ELSIF p_stream_type_name = 'RENT' THEN
     x_stream_type_name := 'Rent';

   ELSIF p_stream_type_name = 'PRINCIPAL BALANCE' THEN
     x_stream_type_name := 'Lending Loans Balance';

    ELSIF p_stream_type_name = 'INTEREST PAYMENT' THEN
     x_stream_type_name := 'Lending Loans Interest';
    ELSIF p_stream_type_name = 'PRINCIPAL PAYMENT' THEN
     x_stream_type_name := 'Lending Loans Principal';
    ELSIF p_stream_type_name = 'RENTAL ACCRUAL' THEN
     --smahapat 02/12/03 bugfix# 2790764
     --x_stream_type_name := 'GL Rent Receivable Credits';
     x_stream_type_name := 'Single Rent Accrual';
    ELSIF p_stream_type_name = 'FAS 91 FEE INCOME' THEN
     x_stream_type_name := 'Initial Direct Costs';
    ELSIF p_stream_type_name = 'UNEARNED INCOME' THEN
     x_stream_type_name := 'GL Income Unearned';
     --x_stream_type_name := 'GL Income Recognized';
    ELSIF p_stream_type_name = 'TERMINATION VALUE' THEN
     x_stream_type_name := 'Termination Value';
    ELSIF p_stream_type_name = 'STIP LOSS VALUE' THEN
-- modified to fix bug #  2440390
     x_stream_type_name := 'StipLoss Value';
    ELSIF p_stream_type_name = 'BOOK DEPRECIATION' THEN
     x_stream_type_name := 'Book Depreciation';
    ELSIF p_stream_type_name = 'FEDERAL DEPRECIATION' THEN
     x_stream_type_name := 'Federal Depreciation';
    ELSIF p_stream_type_name = 'STATE DEPRECIATION' THEN
     x_stream_type_name := 'State Depreciation';
	-- mvasudev, 07/18/2002
    ELSIF p_stream_type_name = 'LOAN PAYMENT' THEN
     x_stream_type_name := 'Lending Loans Debt Service';
	 -- smahapat 02/14/2003 bugfix# 2790695
    ELSIF p_stream_type_name = 'FEE INCOME' THEN
	 x_stream_type_name := 'Single Periodic Income Accrual';
    --ELSIF p_stream_type_name = 'AMORTIZED FEE INCOME' THEN
	 --x_stream_type_name := 'Single Fee Accrual';
    ELSIF p_stream_type_name = 'INTEREST INCOME' THEN
	 x_stream_type_name := 'Single Lending Loan Accrual';
    ELSIF p_stream_type_name = 'PERIODIC EXPENSE PAYABLE' THEN
	 x_stream_type_name := 'Single Periodic Expense Accrual';
	 -- smahapat fee type solution
    ELSIF p_stream_type_name = 'SECURITY DEPOSIT' THEN
	 x_stream_type_name := 'Security Deposits';
     ELSE
     x_stream_type_name := p_stream_type_name;
    END IF;

	IF p_stream_type_name = 'RESIDUAL VALUE INSURANCE PREMIUM' THEN
	 x_stream_type_desc := 'Residual Insurance Premium';
	ELSE
	 x_stream_type_desc := p_stream_type_name;
	END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_stream_type_name := p_stream_type_name;
      x_stream_type_desc := p_stream_type_name;

  END TRANSLATE_STREAM_TYPE;

  PROCEDURE REVERSE_TRANSLATE_STREAM_TYPE(p_stream_type_name IN VARCHAR2,
                                  p_stream_type_desc IN VARCHAR2,
                                  x_stream_type_name OUT NOCOPY VARCHAR2)
  IS
  BEGIN

    IF p_stream_type_name = 'Fee'
    OR p_stream_type_name = 'Periodic Expenses'
    OR p_stream_type_name = 'Periodic Income' THEN
	  x_stream_type_name := p_stream_type_desc;
    ELSIF p_stream_type_name = 'RENT' THEN
     x_stream_type_name := 'Rent';
    ELSIF p_stream_type_name = 'Lending Loans Balance' THEN
     x_stream_type_name := 'PRINCIPAL BALANCE';
    ELSIF p_stream_type_name = 'Lending Loans Interest' THEN
     x_stream_type_name := 'INTEREST PAYMENT';
    ELSIF p_stream_type_name = 'Lending Loans Principal' THEN
     x_stream_type_name := 'PRINCIPAL PAYMENT';
    --ELSIF p_stream_type_name = 'GL Rent Receivable Credits' THEN
    --smahapat 02/12/03 bugfix# 2790764
    ELSIF p_stream_type_name = 'GL Book Rent' THEN
     x_stream_type_name := 'RENTAL ACCRUAL';
    ELSIF p_stream_type_name = 'Initial Direct Costs' THEN
     x_stream_type_name := 'FAS 91 FEE INCOME';
    --ELSIF p_stream_type_name = 'GL Income Earned' THEN
    --smahapat fixed bug 2826926
    ELSIF p_stream_type_name = 'GL Income Recognized' THEN
     x_stream_type_name := 'PRE-TAX INCOME';
    ELSIF p_stream_type_name = 'GL Income Unearned' THEN
    -- modified to fix bug # 2449592
    --ELSIF p_stream_type_name = 'GL Income Recognized' THEN
         x_stream_type_name := 'UNEARNED INCOME';
    ELSIF p_stream_type_name = 'Termination Value' THEN
     x_stream_type_name := 'TERMINATION VALUE';
    ELSIF p_stream_type_name = 'StipLoss Value' THEN
    -- modified to fix bug # 2440390
     x_stream_type_name := 'STIP LOSS VALUE';
    ELSIF p_stream_type_name = 'Book Depreciation' THEN
     x_stream_type_name := 'BOOK DEPRECIATION';
    ELSIF p_stream_type_name = 'Federal Depreciation' THEN
     x_stream_type_name := 'FEDERAL DEPRECIATION';

    ELSIF p_stream_type_name = 'State Depreciation' THEN
     x_stream_type_name := 'STATE DEPRECIATION';
	 -- smahapat 02/14/2003 bugfix# 2790695
    ELSIF p_stream_type_name = 'GL Book Periodic Income' THEN
	 x_stream_type_name := 'FEE INCOME';
    ELSIF p_stream_type_name = 'GL Book Periodic Expenses' THEN
	 x_stream_type_name := 'PERIODIC EXPENSE PAYABLE';
	 -- smahapat fee type solution
	ELSIF p_stream_type_name = 'Security Deposits' THEN
	 x_stream_type_name := 'SECURITY DEPOSIT';
    ELSE
     x_stream_type_name := p_stream_type_name;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_stream_type_name := p_stream_type_name;

  END REVERSE_TRANSLATE_STREAM_TYPE;

  PROCEDURE TRANSLATE_ADVANCE_ARREARS(p_advance_arrears IN VARCHAR2,
                                      x_advance_arrears OUT NOCOPY VARCHAR2)
  IS
  BEGIN
	IF p_advance_arrears = G_ADVANCE THEN
	  x_advance_arrears := G_CSM_TRUE;
	ELSIF p_advance_arrears = G_ARREARS THEN
	  x_advance_arrears := G_CSM_FALSE;
	ELSE
	  x_advance_arrears := G_CSM_FALSE;
	END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_advance_arrears := p_advance_arrears;

  END TRANSLATE_ADVANCE_ARREARS;

  PROCEDURE TRANSLATE_INCOME_EXPENSE(p_income_expense IN VARCHAR2,
                                     x_income_expense OUT NOCOPY VARCHAR2)
  IS
  BEGIN
	IF p_income_expense = G_EXPENSE THEN
	  x_income_expense := G_CSM_TRUE;
	ELSIF p_income_expense = G_INCOME THEN
	  x_income_expense := G_CSM_FALSE;
	ELSE
	  x_income_expense := G_CSM_FALSE;
	END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_income_expense := p_income_expense;

  END TRANSLATE_INCOME_EXPENSE;

  PROCEDURE TRANSLATE_PERCENTAGE(p_percentage IN NUMBER,
                                 x_ratio      OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    IF p_percentage IS NOT NULL THEN
      x_ratio := TO_CHAR(p_percentage/100);
    ELSE
	  x_ratio := TO_CHAR(p_percentage);
	END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_ratio := TO_CHAR(p_percentage);
  END TRANSLATE_PERCENTAGE;

  PROCEDURE TRANSLATE_LOCK_LEVEL_STEP(p_lock_level_step IN VARCHAR2,
                                      x_lock_amount OUT NOCOPY VARCHAR2,
                                      x_lock_rate OUT NOCOPY VARCHAR2)
  IS
  BEGIN
     IF p_lock_level_step = G_LOCK_AMOUNT THEN
       x_lock_amount := G_CSM_TRUE;
       x_lock_rate := G_CSM_FALSE;
     ELSIF p_lock_level_step = G_LOCK_RATE THEN
       x_lock_rate := G_CSM_TRUE;
       x_lock_amount := G_CSM_FALSE;
     ELSIF p_lock_level_step = G_LOCK_BOTH THEN
       x_lock_amount := G_CSM_TRUE;
       x_lock_rate   := G_CSM_TRUE;
     ELSE
      x_lock_amount := p_lock_level_step;
      x_lock_rate   := p_lock_level_step;
     END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_lock_amount := p_lock_level_step;
      x_lock_rate   := p_lock_level_step;

  END TRANSLATE_LOCK_LEVEL_STEP;

  PROCEDURE TRANSLATE_MODE(p_mode IN VARCHAR2,
                           x_mode OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    IF p_mode = G_MODE_LESSOR THEN

      x_mode := 'Lessor';
    ELSIF p_mode = G_MODE_LENDER THEN
      x_mode := 'Lender';
    ELSIF p_mode = G_MODE_BOTH THEN
      x_mode := 'Both';
    ELSE
     x_mode := p_mode;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_mode := p_mode;

  END TRANSLATE_MODE;

PROCEDURE TRANSLATE_FEE_LEVEL_TYPE(p_fee_level_type IN VARCHAR2,
                                     x_fee_level_type OUT NOCOPY VARCHAR2)
IS
BEGIN
  IF p_fee_level_type = G_SFE_LEVEL_PAYMENT THEN
    x_fee_level_type := 'Payment';
  ELSIF p_fee_level_type = G_SFE_LEVEL_FUNDING THEN
    x_fee_level_type := 'Funding';
  ELSIF p_fee_level_type = G_SFE_LEVEL_INTEREST THEN
    x_fee_level_type := 'Interest ONLY';
  ELSIF p_fee_level_type = G_SFE_LEVEL_PRINCIPAL THEN
    x_fee_level_type := 'Principal';
  END IF;
EXCEPTION
    WHEN OTHERS THEN
      x_fee_level_type := p_fee_level_type;
END TRANSLATE_FEE_LEVEL_TYPE;

  PROCEDURE REVERSE_TRANSLATE_YN(p_yn IN VARCHAR2,
                                 x_yn OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    IF p_yn = G_CSM_TRUE
    THEN
     x_yn  := G_FND_YES;
    ELSIF p_yn = G_CSM_FALSE
	THEN
      x_yn := G_FND_NO;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_yn := p_yn;
  END REVERSE_TRANSLATE_YN;

  PROCEDURE REVERSE_TRANSLATE_PERIODICITY(p_periodicity IN VARCHAR2,
                                  x_periodicity OUT NOCOPY VARCHAR2)
  IS
  BEGIN
      IF p_periodicity = 'Annual' THEN
        x_periodicity := 'A';
      ELSIF p_periodicity = 'Semiannual' THEN
        x_periodicity := 'S';
      ELSIF p_periodicity = 'Quarterly' THEN
        x_periodicity := 'Q';
      ELSIF p_periodicity = 'Monthly' THEN
        x_periodicity := 'M';
	  ELSIF p_periodicity = 'Stub' THEN   -- smahapat fee type soln
	    x_periodicity := 'T';
      END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_periodicity := p_periodicity;
  END REVERSE_TRANSLATE_PERIODICITY;

PROCEDURE TRANSLATE_NEPA(p_nominal_yn IN VARCHAR2,
                         p_pre_tax_yn IN VARCHAR2,
                         x_nepa OUT NOCOPY VARCHAR2)
IS
BEGIN
  IF p_nominal_yn = G_FND_YES THEN
    IF p_pre_tax_yn = G_FND_YES THEN
      x_nepa := 'Pre-tax nominal';
    ELSIF p_pre_tax_yn = G_FND_NO THEN
      x_nepa := 'After-tax nominal';
    ELSE
      x_nepa := p_pre_tax_yn;
    END IF;
  ELSIF p_nominal_yn = G_FND_NO THEN
    IF p_pre_tax_yn = G_FND_YES THEN
      x_nepa := 'Pre-tax effective';
    ELSIF p_pre_tax_yn = G_FND_NO THEN
      x_nepa := 'After-tax effective';
    ELSE
      x_nepa := p_pre_tax_yn;
    END IF;
  ELSE
    x_nepa := p_nominal_yn;
  END IF;
EXCEPTION
    WHEN OTHERS THEN
    x_nepa := p_nominal_yn;
END TRANSLATE_NEPA;

PROCEDURE TRANSLATE_LOCK_LEVEL_LNSTEP(p_level_type IN VARCHAR2,

                                         p_lock_level_step IN VARCHAR2,
					 x_lock_amount OUT NOCOPY VARCHAR2,
                                         x_lock_rate OUT NOCOPY VARCHAR2)
  IS
    l_lock_amount VARCHAR2(10);
    l_lock_rate VARCHAR2(10);
  BEGIN
     IF (p_level_type = G_SFE_LEVEL_FUNDING OR p_level_type = 'Funding' ) THEN
       x_lock_amount := NULL;
       x_lock_rate := NULL;
     ELSE
	  TRANSLATE_LOCK_LEVEL_STEP(p_lock_level_step, l_lock_amount, l_lock_rate);
      x_lock_amount := l_lock_amount;
      x_lock_rate   := l_lock_rate;
     END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_lock_amount := G_CSM_TRUE;
      x_lock_rate   := G_CSM_FALSE;

END TRANSLATE_LOCK_LEVEL_LNSTEP;

PROCEDURE TRANSLATE_SIY_TYPE(p_siy_type IN VARCHAR2,
                                     x_siy_type OUT NOCOPY VARCHAR2)
IS
BEGIN
  IF p_siy_type = OKL_SIY_PVT.G_SIY_TYPE_YIELD THEN
    x_siy_type := 'Yield';
  ELSIF p_siy_type = OKL_SIY_PVT.G_SIY_TYPE_INTEREST_RATE THEN
    x_siy_type := 'Rates full/base term';
  END IF;
EXCEPTION
    WHEN OTHERS THEN
      x_siy_type := p_siy_type;
END TRANSLATE_SIY_TYPE;

  PROCEDURE TRANSLATE_GUARANTEE_TYPE(p_guarantee_type IN VARCHAR2,
                                     x_guarantee_type OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    IF p_guarantee_type = 'Lessee' or p_guarantee_type = 'LESSEE' THEN
      x_guarantee_type := 'Lessee';
    ELSIF p_guarantee_type = 'Other' or p_guarantee_type = 'OTHER' THEN
      x_guarantee_type := 'Third Party';
    ELSIF p_guarantee_type = 'Vendor' or p_guarantee_type = 'VENDOR' THEN
      x_guarantee_type := 'Third Party';
    ELSIF p_guarantee_type = 'NONE' THEN
      x_guarantee_type := 'Unguaranteed';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
	  x_guarantee_type := p_guarantee_type;
  END TRANSLATE_GUARANTEE_TYPE;

  PROCEDURE TRANSLATE_STATISTIC_INDEX(p_target_type IN VARCHAR2,
									  p_statistic_index IN VARCHAR2,
                                      x_statistic_index OUT NOCOPY VARCHAR2)
  IS
    l_target_type VARCHAR2(3) := 'INT';
  BEGIN
   fnd_file.put_line(fnd_file.log, 'st code conversion tarfet type '||p_target_type);
   fnd_file.put_line(fnd_file.log, 'st code conversion p_statistic_index '||p_statistic_index);
    IF p_target_type = l_target_type THEN
	  fnd_file.put_line(fnd_file.log, 'st code conversion set stat to 1 ');
	  x_statistic_index := '1';
	ELSE
	  x_statistic_index := p_statistic_index;
	END IF;
   fnd_file.put_line(fnd_file.log, 'st code conversion x_statistic_index '||x_statistic_index);
  EXCEPTION
    WHEN OTHERS THEN
	  x_statistic_index := p_statistic_index;
  END TRANSLATE_STATISTIC_INDEX;

--New Procedure Added to determine mode.

 PROCEDURE Get_mode (p_transaction_number In NUMBER,
	             x_mode out NOCOPY VARCHAR2)
 IS
  	CURSOR Get_mode_csr(cp_transaction_no NUMBER )
        IS
        SELECT
              sfe.deal_type,sil.sil_type
        FROM   okl_stream_interfaces_v sfe,
               okl_sif_lines_v sil
        WHERE  transaction_number = cp_transaction_no
        AND    sil.sif_id = sfe.id;

 BEGIN
  FOR l_get_mode_rec in Get_mode_csr(p_transaction_number)
  LOOP
	IF l_get_mode_rec.deal_type = 'LSBO' THEN
           IF l_get_mode_rec.sil_type = 'SGN'
           THEN
              x_mode := 'Both';
           ELSE
              x_mode := 'Lessor';
           END IF;

        ELSIF l_get_mode_rec.deal_type = 'LNBO' THEN
          x_mode := 'Lender';
        END IF;
  END LOOP;
END Get_mode;


--New Procedure Added to FundingAndRate.

 PROCEDURE SET_FUNDINGANDRATE (p_transaction_number In NUMBER,
                               p_fee_index In NUMBER,
  		               x_FundingAndRate out NOCOPY VARCHAR2)
 IS
  	CURSOR Set_FundingAndRate_csr(cp_transaction_no NUMBER,
                                      cp_fee_index      NUMBER
          )
        IS
	 SELECT
	  AMOUNT
	FROM
	  OKL_SIF_FEES SFEB,
	  OKL_STREAM_INTERFACES SIFB
	WHERE
	  SFEB.SIF_ID = SIFB.ID AND
          SFEB.SFE_TYPE = 'SFR' AND
          SFEB.FEE_INDEX_NUMBER = cp_fee_index AND
          SIFB.transaction_number = cp_transaction_no;

 BEGIN
  FOR l_FundingAndRate_rec in Set_FundingAndRate_csr(p_transaction_number,p_fee_index)
  LOOP
	IF l_FundingAndRate_rec.amount = 0 THEN
          x_FundingAndRate := 'true';
        END IF;
  END LOOP;
END SET_FUNDINGANDRATE;

--Added by kthriuva for the VR build
--This method fetches the balance method that needs to be used for the Balance Tag
PROCEDURE get_balance_method(p_transaction_number IN NUMBER,
                             x_balance_method     OUT NOCOPY VARCHAR2)
IS

CURSOR get_bal_meth_csr(p_trx_number IN NUMBER)
IS
SELECT FEES.BALANCE_TYPE_CODE
FROM OKL_SIF_FEES_V FEES,
     OKL_STREAM_INTERFACES SIF
WHERE SIF.TRANSACTION_NUMBER = p_trx_number
AND   SIF.ID = FEES.SIF_ID
AND   FEES.BALANCE_TYPE_CODE IS NOT NULL;

l_balance_method     okl_sif_fees.balance_type_code%TYPE;

BEGIN

  OPEN get_bal_meth_csr(p_transaction_number);
  FETCH get_bal_meth_csr INTO l_balance_method;
  CLOSE get_bal_meth_csr;

  IF l_balance_method = G_BALANCE_TERM THEN
     x_balance_method := 'Term';
  ELSIF l_balance_method = G_BALANCE_PAYMENT THEN
     x_balance_method := 'Payments';
  ELSIF l_balance_method = G_BALANCE_FUNDING THEN
     x_balance_method := 'Funding';
  ELSIF l_balance_method = G_BALANCE_RATE THEN
     x_balance_method := 'Rate';
  ELSE x_balance_method := 'None';
  END IF;

END get_balance_method;

--This method converts the date but returns the date only in the case of
--stubs and when the payment type is funding
--For periodic payments End Accrual date is not required
PROCEDURE CONVERT_DATE_RESTRUCT(p_date            IN    DATE,
                         p_date_format     IN  VARCHAR2,
                         p_type            IN  VARCHAR2,
                         p_periodicity     IN  VARCHAR2,
                         x_char_date       OUT NOCOPY   VARCHAR2)
  IS
  BEGIN
    IF (p_periodicity = 'Stub') OR (p_type = 'Funding') THEN
      IF p_date_format IS NOT NULL THEN
        x_char_date := TO_CHAR(p_date,p_date_format);
      ELSE
        x_char_date := TO_CHAR(p_date,G_DEFAULT_DATE_FORMAT);
      END IF;
    ELSE
        x_char_date := null ;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_char_date := TO_CHAR(p_date,G_DEFAULT_DATE_FORMAT);
  END CONVERT_DATE_RESTRUCT;
  --kthriuva - End of Changes for VR build

 -- gboomina BUG#4508077 procedure to set the description
    -- for fee with purpose code as RVI
    PROCEDURE SET_RVI_FEE_DESCRIPTION(p_kle_id IN NUMBER,
                                      p_description IN VARCHAR2,
                                              x_description OUT NOCOPY VARCHAR2)
    IS
      -- cursor to fetch the fee purpose code
      CURSOR get_fee_purpose_csr(p_fee_line_id IN NUMBER) IS
      SELECT fee_purpose_code
      FROM OKL_K_LINES
      WHERE ID = p_fee_line_id;
    BEGIN
      -- assign the value passed
      x_description := p_description;
      IF(p_kle_id IS NOT NULL) THEN
        -- fetch the purpose code for the fee line
        FOR l_fee_purpose_rec IN get_fee_purpose_csr(p_fee_line_id => p_kle_id)
        LOOP
          -- if purpose code is RVI then update the description as Residual Insurance Premium
          IF(l_fee_purpose_rec.fee_purpose_code = 'RVI') THEN
            x_description := 'Residual Insurance Premium';
          END IF;
        END LOOP;
      END IF;
    END SET_RVI_FEE_DESCRIPTION;

  --Added by kthiruva on 11-Nov-2005 for the VR build
  --Bug 4726209 - Start of Changes
  --The value of the <IsAdvance> tag is passed to this procedure
  --When IsAdvance is false, the payment is in Arrears and a value
  --'Y' needs to be returned. Else a value 'N' should be returned
  PROCEDURE REVERSE_TRANSLATE_ADV_OR_ARR (p_yn IN VARCHAR2,
                                          x_yn OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    IF p_yn = G_CSM_TRUE
    THEN
     x_yn  := G_FND_NO;
    ELSIF p_yn = G_CSM_FALSE
	THEN
      x_yn := G_FND_YES;
    END IF;
  END REVERSE_TRANSLATE_ADV_OR_ARR;
  --Bug 4726209 - End of Changes

  --Added by kthiruva on 19-Apr-2006 to determine if a Paydown has been made on a contract
  --Bug 5161075 - Start of Changes
  PROCEDURE IS_PPD_AVAILABLE(p_trx_number IN NUMBER,
                             x_yn OUT NOCOPY VARCHAR2)
  IS
   CURSOR get_contract_id_csr(p_trx_number NUMBER)
   IS
   SELECT KHR_ID
   FROM OKL_STREAM_INTERFACES
   WHERE TRANSACTION_NUMBER = p_trx_number;

   --This cursor determines whether there have been any Paydowns on this Contract
   CURSOR is_ppd_available_csr(chrId NUMBER)
   IS
   SELECT count(crl.id)
   FROM okc_rule_groups_b crg,
        okc_rules_b crl,
        okl_strm_type_v sty
   WHERE crl.rgp_id = crg.id
   AND crg.rgd_code = 'LALEVL'
   AND crl.rule_information_category = 'LASLH'
   AND crg.dnz_chr_id = chrId
   AND crl.object1_id1 = sty.id
   AND sty.stream_type_purpose = 'UNSCHEDULED_PRINCIPAL_PAYMENT'
   ORDER BY crl.rule_information1;

   l_ppd_count    NUMBER := 0;
   l_khr_id       NUMBER;


  BEGIN
    OPEN get_contract_id_csr(p_trx_number);
    FETCH get_contract_id_csr INTO l_khr_id;
    CLOSE get_contract_id_csr;

    IF l_khr_id is NOT NULL THEN
       OPEN is_ppd_available_csr(l_khr_id);
       FETCH is_ppd_available_csr INTO l_ppd_count;
       CLOSE is_ppd_available_csr;
    END IF;

    IF l_ppd_count > 0 THEN
       x_yn := 'false';
    ELSE
       x_yn := 'true';
    END IF;
  END  IS_PPD_AVAILABLE;
  --Bug 5161075 - End of Changes

  --Added by rbanerje on 03-Oct-2008 to return the decimal separator in the number format
  --Bug 6085025 - Start of Changes
  PROCEDURE get_decimal_separator  ( x_seperator OUT  NOCOPY VARCHAR2 )
  IS
  BEGIN
     x_seperator := SUBSTR(fnd_global.nls_numeric_characters, 1,1);
  END get_decimal_separator;
  --Bug 6085025 - End of Changes

END  Okl_St_Code_Conversions;

/
