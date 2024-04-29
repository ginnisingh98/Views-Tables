--------------------------------------------------------
--  DDL for Package Body JL_CO_AP_WITHHOLDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_CO_AP_WITHHOLDING_PKG" AS
/* $Header: jlcopwhb.pls 120.12.12010000.4 2010/05/13 22:11:17 rsaini ship $ */

/**************************************************************************
 *                    Private Procedure Specification                    *
 **************************************************************************/

/**************************************************************************
 *                                                                        *
 * Name       : Jl_Co_Ap_Calculate_AWT_Amounts                            *
 * Purpose    : This procedure performs all the withholding calculations  *
 *              and generates the temporary distribution lines.           *
 *                                                                        *
 **************************************************************************/
 PROCEDURE Jl_Co_Ap_Calculate_AWT_Amounts
		(P_Invoice_Id			IN Number,
		 P_AWT_Date			IN Date,
		 P_Calling_Module		IN Varchar2,
		 P_Create_Dists			IN Varchar2,
		 P_Amount			IN Number,
		 P_Last_Updated_By		IN Number	Default Null,
		 P_Last_Update_Login		IN Number	Default Null,
		 P_Program_Application_Id	IN Number	Default Null,
		 P_Program_Id			IN Number	Default Null,
		 P_Request_Id			IN Number	Default Null,
		 P_AWT_Success			IN OUT NOCOPY Varchar2,
		 P_Calling_Sequence		IN Varchar2
		);

/**************************************************************************
 *                                                                        *
 * Name       : User_Defined_Formula_Exists                               *
 * Purpose    : This function returns TRUE, if there is atleast one       *
 *              type within this NIT, with the user defined formula       *
 *              flag set to 'Y'. Otherwise, it returns FALSE              *
 *                                                                        *
 **************************************************************************/

FUNCTION User_Defined_Formula_Exists
			(P_Invoice_Id	IN Number,
			 P_NIT		IN Varchar2) RETURN BOOLEAN;


/**************************************************************************
 *                                                                        *
 * Name       : Initialize_Withholdings                                   *
 * Purpose    : Obtains all the attributes for the current withholding    *
 *		tax type and tax name. This procedure also initializes a 	  *
 *		PL/SQL table to store the withholdings
 *                                                                        *
 **************************************************************************/
PROCEDURE Initialize_Withholdings
         (P_Vendor_Id          IN     Number,
          P_AWT_Type_Code      IN     Varchar2,
          P_Tax_Id             IN     Number,
          P_Rec_AWT_Type       OUT NOCOPY    jl_zz_ap_awt_types%ROWTYPE,
          P_Rec_AWT_Name       OUT NOCOPY    Jl_Zz_Ap_Withholding_Pkg.Rec_AWT_Code,
          P_Rec_Suppl_AWT_Type OUT NOCOPY    jl_zz_ap_supp_awt_types%ROWTYPE,
          P_Rec_Suppl_AWT_Name OUT NOCOPY    jl_zz_ap_sup_awt_cd%ROWTYPE,
          P_Wh_Table           IN OUT NOCOPY Jl_Zz_Ap_Withholding_Pkg.Tab_Withholding);



/**************************************************************************
 *                                                                        *
 * Name       : Process_Withholdings                                      *
 * Purpose    : Process the information for the current withholding tax   *
 *              type and name                                             *
 *                                                                        *
 **************************************************************************/
PROCEDURE Process_Withholdings
      (P_Vendor_Id              IN     Number,
       P_Rec_AWT_Type           IN     jl_zz_ap_awt_types%ROWTYPE,
       P_Rec_Suppl_AWT_Type     IN     jl_zz_ap_supp_awt_types%ROWTYPE,
       P_AWT_Date               IN     Date,
       P_GL_Period_Name         IN     Varchar2,
       P_Base_Currency_Code     IN     Varchar2,
       P_User_Defd_Formula	IN     Boolean,
       P_NIT_Number		IN     Varchar2	  Default null,
       P_Tab_Withhold           IN OUT NOCOPY Jl_Zz_Ap_Withholding_Pkg.Tab_Withholding,
       P_Tab_All_Withhold	IN OUT NOCOPY Jl_Zz_Ap_Withholding_Pkg.Tab_All_Withholding,
       P_AWT_Success		OUT NOCOPY Varchar2,
       P_Last_Updated_By        IN     Number     Default null,
       P_Last_Update_Login      IN     Number     Default null,
       P_Program_Application_Id IN     Number     Default null,
       P_Program_Id             IN     Number     Default null,
       P_Request_Id             IN     Number     Default null,
       P_Calling_Module         IN     Varchar2   Default null
       );


/**************************************************************************
 *                          Public Procedures                             *
 **************************************************************************/


/**************************************************************************
 *                                                                        *
 * Name       : Jl_Co_Ap_Do_Withholding                                   *
 * Purpose    : This is the main procedure for the Colombian Automatic    *
 *              Withholding Tax calculation. Three different processing   *
 *              units are executed from this main routine.                *
 *                                                                        *
 **************************************************************************/

PROCEDURE Jl_Co_Ap_Do_Withholding
				(P_Invoice_Id		  IN Number,
				 P_AWT_Date		  IN Date,
				 P_Calling_Module	  IN Varchar2,
				 P_Amount		  IN Number,
				 P_Payment_Num		  IN Number 	Default Null,
				 P_Last_Updated_By	  IN Number,
				 P_Last_Update_Login	  IN Number,
				 P_Program_Application_Id IN Number	Default Null,
				 P_Program_Id		  IN Number     Default Null,
				 P_Request_Id		  IN Number     Default Null,
				 P_AWT_Success		  OUT NOCOPY Varchar2
				)
IS
    ------------------------
    -- Variables Definition
    ------------------------
    l_awt_flag			ap_invoices.awt_flag%TYPE;
    l_inv_curr_code		ap_invoices.invoice_currency_code%TYPE;
    l_invoice_type_lookup_code  ap_invoices.invoice_type_lookup_code%TYPE;
    l_AWT_success		Varchar2(2000) := 'SUCCESS';
    l_create_dists 		ap_system_parameters.create_awt_dists_type%TYPE;
    l_create_invoices        ap_system_parameters.create_awt_invoices_type%TYPE;
    current_calling_sequence	Varchar2(2000);
    debug_info			Varchar2(100);
	l_AWT_DATE			DATE;    -- bug: 8770258



BEGIN

   current_calling_sequence := 'JL_CO_AP_WITHHOLDING_PKG.Jl_Co_Ap_Do_Withholding';

   -----------------------------------------------------------------------
   -- IF calling module is different from AUTOAPPROVAL should not execute
   -- anything for Colombia Bug# 2279293
   -----------------------------------------------------------------------
   IF (P_Calling_Module <> 'AUTOAPPROVAL') THEN
       -- Bug 3008030 Initialize OUT parameter P_AWT_Success.
      P_AWT_Success := l_AWT_success;
      Return;
   END IF;

   ------------------------------------------------------------------------
   -- Read the AWT flag for the current invoice to check whether AWT
   -- calculation has already been performed by AUTOAPPROVAL on this
   -- invoice
   ------------------------------------------------------------------------
   debug_info := 'Read the AWT flag for the current invoice';

   SELECT
   	  nvl(awt_flag,'N') awt_flag,
   	  invoice_currency_code,
      invoice_type_lookup_code ,
	  gl_date      -- bug: 8770258
	  --  As AWT_DATE=GL_DATE for colombia(Approval time AWT Generation)
   INTO
   	  l_awt_flag,
   	  l_inv_curr_code,
      l_invoice_type_lookup_code,
	  l_AWT_DATE   -- bug: 8770258
   FROM
   	  ap_invoices
   WHERE
   	  invoice_id = P_Invoice_Id;

   ---------------------------
   -- Check Invoice Type
   ---------------------------
   IF (l_invoice_type_lookup_code = 'AWT') THEN
       P_AWT_Success := l_AWT_success;
       Return;
   END IF;

   ---------------------------
   -- Read setup information
   ---------------------------
   debug_info := 'Read setup information';

   SELECT
   	  nvl(create_awt_dists_type, 'NEVER'),
   	  nvl(create_awt_invoices_type, 'NEVER')
   INTO
   	  l_create_dists,
   	  l_create_invoices
   FROM
   	  ap_system_parameters;

   ------------------------------------------------------------------------
   -- Checks whether the withholding taxes are calculated at invoice
   -- approval time
   ------------------------------------------------------------------------
   IF (l_create_dists <> 'APPROVAL' ) THEN
   	RETURN;
   END IF;

   -----------------------------------------------------------
   -- Withholding Tax Calculation for "Invoice AutoApproval"
   -----------------------------------------------------------
   IF (
   	(P_Calling_Module = 'AUTOAPPROVAL') AND
   	(l_awt_flag <> 'Y')
      )
   THEN

	SAVEPOINT Before_Temporary_Calculations;

	--------------------------------------
	-- Create Temporary AWT Distributions
	--------------------------------------
	Jl_Co_Ap_Calculate_AWT_Amounts
				(P_Invoice_Id,
				 l_AWT_DATE,     -- bug: 8770258
				 P_Calling_Module,
				 l_create_dists,
				 P_Amount,
				 P_Last_Updated_By,
				 P_Last_Update_Login,
				 P_Program_Application_Id,
				 P_Program_Id,
				 P_Request_Id,
				 l_AWT_success,
				 current_calling_sequence
				);

	IF (l_AWT_success <> 'SUCCESS') THEN

		ROLLBACK TO Before_Temporary_Calculations;
	ELSE
		----------------------------
		-- Create AWT Distributions
		----------------------------
		Ap_Withholding_Pkg.Create_AWT_Distributions
						(P_Invoice_Id,
				 		 P_Calling_Module,
				 		 l_create_dists,
				 		 P_Payment_Num,
				 		 l_inv_curr_code,
				 		 P_Last_Updated_By,
				 		 P_Last_Update_Login,
				 		 P_Program_Application_Id,
				 		 P_Program_Id,
				 		 P_Request_Id,
				 		 current_calling_sequence
						);

	 END IF;

 	IF (
 	    (l_create_invoices = 'APPROVAL')
    	    AND (l_AWT_success = 'SUCCESS')
           )
   	THEN

		-----------------------
		-- Create AWT Invoices
		-----------------------
	     	Ap_Withholding_Pkg.Create_AWT_Invoices
						(P_Invoice_Id,
						 l_AWT_DATE,   -- bug: 8770258
				 		 P_Last_Updated_By,
				 		 P_Last_Update_Login,
				 		 P_Program_Application_Id,
				 		 P_Program_Id,
				 		 P_Request_Id,
				 		 current_calling_sequence,
                                                 P_Calling_Module
						);
	END IF;

	P_AWT_Success := l_AWT_success;
   -- Bug 3404210
   -- When the invoice is validated for the second time after creating
   -- a manual hold, the system generates AWT hold. This is because the invoice
   -- to which withholding is already applied, AWT_FLAG is set to 'Y'
   -- So it will not enter the above IF condition and SUCCESS status is not
   -- returned to the called program. Added the below ELSE part.
   ELSE
      P_AWT_Success := l_AWT_success;
   END IF;

EXCEPTION
   WHEN others THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('JL','JL_ZZ_AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS',
                      '  Invoice Id  = '       || to_char(P_Invoice_Id) ||
                      ', AWT Date    = '       || to_char(P_Awt_Date,'YYYY/MM/DD') ||
                      ', Calling module  = '   || P_Calling_Module ||
                      ', Amount  = '           || to_char(P_Amount));

              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

END Jl_Co_Ap_Do_Withholding ;


/**************************************************************************
 *                         Private Procedure                              *
 **************************************************************************/

/**************************************************************************
 *                                                                        *
 * Name       : Jl_Co_Ap_Calculate_AWT_Amounts                            *
 * Purpose    : This procedure performs all the withholding calculations  *
 *              and generates the temporary distribution lines.           *
 *                                                                        *
 **************************************************************************/

PROCEDURE Jl_Co_Ap_Calculate_AWT_Amounts
		(P_Invoice_Id			IN Number,
		 P_AWT_Date			IN Date,
		 P_Calling_Module		IN Varchar2,
		 P_Create_Dists			IN Varchar2,
		 P_Amount			IN Number,
		 P_Last_Updated_By		IN Number	Default Null,
		 P_Last_Update_Login		IN Number	Default Null,
		 P_Program_Application_Id	IN Number	Default Null,
		 P_Program_Id			IN Number	Default Null,
		 P_Request_Id			IN Number	Default Null,
		 P_AWT_Success			IN OUT NOCOPY Varchar2,
		 P_Calling_Sequence		IN Varchar2
		)
IS

   -------------------------------
   -- Local Variables Definition
   -------------------------------
   l_previous_awt_type_code    Varchar2(30);
   l_previous_tax_id           Number;
   l_current_vendor_id	       Number;
   l_current_awt               Number;
   l_initial_awt               Number;
   l_tax_base_amt              Number;
   l_nit		       po_vendors.segment1%TYPE;
   l_user_defd_formula_exists  Boolean := FALSE;
   l_gl_period_name	       ap_invoice_distributions.period_name%TYPE;
   l_base_currency_code	       Varchar2(15);
   debug_info		       Varchar2(100);
   current_calling_sequence    Varchar2(2000);

   ---------------------------------------------------------
   -- Cursor to select all distinct NIT within the invoice
   ---------------------------------------------------------
   CURSOR c_nit(Inv_Id Number)
   IS
   SELECT
	  distinct nvl(substr(apid.global_attribute2,1,30),pove.segment1) nit
   FROM
          ap_invoices			apin,
	  ap_invoice_distributions	apid,
	  po_vendors			pove
   WHERE
          apid.invoice_id = apin.invoice_id
   AND    pove.vendor_id  = apin.vendor_id
   AND    apin.invoice_id = Inv_Id;

   --------------------------------------------------------------------------
   -- Cursor to select all the withholding tax types and names with same NIT
   -- and associated to the invoice
   --------------------------------------------------------------------------
   CURSOR c_withholdings(Inv_Id Number,Nit Varchar2)
   IS
   SELECT
 	  jlst.awt_type_code				awt_type_code,
	  jlsc.tax_id					tax_id,
	  apin.invoice_id				invoice_id,
	  pove2.vendor_id				vendor_id,
	  apid.invoice_distribution_id			invoice_distribution_id,
	  nvl(apin.base_amount, apin.invoice_amount)	invoice_amount,
	  nvl(apid.base_amount, apid.amount)		line_amount
   FROM
	  jl_zz_ap_inv_dis_wh		jlwh,
	  ap_invoices			apin,
	  ap_invoice_distributions	apid,
	  jl_zz_ap_supp_awt_types	jlst,
	  jl_zz_ap_sup_awt_cd		jlsc,
	  jl_zz_ap_awt_types		jlat,
	  po_vendors			pove,
	  po_vendors			pove2
   WHERE
	  apid.invoice_id 		= jlwh.invoice_id
   AND	  apid.invoice_distribution_id	= jlwh.invoice_distribution_id
   AND	  apin.invoice_id		= apid.invoice_id
   AND	  pove.vendor_id		= apin.vendor_id
   AND	  pove2.segment1 = nvl(apid.global_attribute2,pove.segment1)
   AND	  jlwh.supp_awt_code_id		= jlsc.supp_awt_code_id
   AND 	  jlsc.supp_awt_type_id 	= jlst.supp_awt_type_id
   AND	  jlat.awt_type_code		= jlst.awt_type_code
   AND 	  jlwh.invoice_id		= Inv_Id
   AND	  nvl(apid.global_attribute2,pove.segment1)= Nit
   AND    NVL(apid.reversal_flag, 'N') <> 'Y'                 -- bug 7693731 Colombia AWT reverse
   ORDER BY
   	  jlat.user_defined_formula_flag,
	  jlst.awt_type_code,
	  jlsc.tax_id;



   ------------------------
   -- Records Declaration
   ------------------------
   rec_withholding       c_withholdings%ROWTYPE;
   rec_awt_type          jl_zz_ap_awt_types%ROWTYPE;
   rec_awt_name          Jl_Zz_Ap_Withholding_Pkg.Rec_AWT_Code;
   rec_suppl_awt_type    jl_zz_ap_supp_awt_types%ROWTYPE;
   rec_suppl_awt_name    jl_zz_ap_sup_awt_cd%ROWTYPE;

   -------------------------
   -- Table Declaration
   -------------------------
   tab_withholdings      Jl_Zz_Ap_Withholding_Pkg.Tab_Withholding;
   tab_invoice_wh	 Jl_Zz_Ap_Withholding_Pkg.Tab_All_Withholding;

BEGIN

   current_calling_sequence := 'JL_CO_AP_WITHHOLDING_PKG.Jl_Co_Ap_Calculate_AWT_Amounts';

   ------------------------------------------
   -- Opens the cursor to select all the NIT
   ------------------------------------------
   debug_info := 'Open Cursor to select all NIT within the invoice';
   OPEN c_nit(P_Invoice_Id);
   debug_info := 'Fetch cursor for each NIT selected';
   FETCH c_nit INTO l_nit;
   IF (c_nit%NOTFOUND) THEN
        RETURN;
   END IF;

   ------------------------------
   -- Loop for each NIT obtained
   ------------------------------
   LOOP

	---------------------------------------------------------------
	-- Initializes a PL/SQL table to store all withholding details
	---------------------------------------------------------------
	IF (tab_invoice_wh IS NOT NULL) THEN
	    tab_invoice_wh.DELETE;
	END IF;

        ---------------------------------------------------------------------
   	-- Checks whether there exist atleast one type with the user defined
 	-- formula set to 'Y'
        ---------------------------------------------------------------------
        debug_info := 'Call a function to check for user defined formula';
   	l_user_defd_formula_exists := User_Defined_Formula_Exists
   							(P_Invoice_Id,
   							 l_nit);
	---------------------------------------------------------------
	-- Opens the cursor to select all the withholdings to process
	---------------------------------------------------------------
	debug_info := 'Open cursor for all the withholdings with same NIT';
	OPEN c_withholdings(P_Invoice_Id,l_nit);
	debug_info := 'Fetch cursor for each withholding';
	FETCH c_withholdings INTO rec_withholding;
	IF (c_withholdings%FOUND) THEN

	---------------------------
	-- Gets generic parameters
	---------------------------
	l_base_currency_code := Jl_Zz_Ap_Withholding_Pkg.Get_Base_Currency_Code;
	l_gl_period_name     := Jl_Zz_Ap_Withholding_Pkg.Get_GL_Period_Name
								(P_AWT_Date);

	----------------------------------
	-- Initialize auxillary variables
	----------------------------------
	l_current_vendor_id	 := rec_withholding.vendor_id;
	l_previous_awt_type_code := rec_withholding.awt_type_code;
	l_previous_tax_id   	 := rec_withholding.tax_id;

	-------------------------------------------------------------
	-- Obtains all the information associated to the withholding
	-- taxes and initializes a PL/SQL table to store them
	-------------------------------------------------------------
	Initialize_Withholdings (rec_withholding.vendor_id,
				 rec_withholding.awt_type_code,
				 rec_withholding.tax_id,
				 rec_awt_type,
				 rec_awt_name,
				 rec_suppl_awt_type,
				 rec_suppl_awt_name,
				 tab_withholdings);


	l_current_awt := 0;
	l_initial_awt := 1;

	---------------------------------------------------------------
	-- Loop for each withholding tax type within the invoice with
	-- same NIT
	---------------------------------------------------------------
	LOOP

	   ---------------------------------------
	   -- Checks whether there are more taxes
	   ---------------------------------------
	   IF (c_withholdings%NOTFOUND) THEN
	   	------------------------------------------------
	   	-- Process the withholding tax name information
	   	------------------------------------------------
	   	Jl_Zz_Ap_Withholding_Pkg.Process_Withholding_Name
	   						(l_current_vendor_id,
	   						 rec_awt_type,
	   						 rec_awt_name,
							 rec_suppl_awt_type,
	   						 rec_suppl_awt_name,
	   						 P_AWT_Date,
	   						 tab_withholdings,
	   						 l_initial_awt,
	   						 l_current_awt,
	   						 tab_invoice_wh,
	   						 P_AWT_Success);
		IF (P_AWT_Success <> 'SUCCESS') THEN
                    CLOSE c_withholdings;
                    CLOSE c_nit;
	            RETURN;
        	END IF;

	   	-----------------------------------------------------
	   	-- Process previous withholding tax type information.
	   	-- Prorates the withheld amounts, if applicable and
	   	-- Inserts temporary distribution lines
	   	-----------------------------------------------------
            	Process_Withholdings (l_current_vendor_id,
                	              rec_awt_type,
                        	      rec_suppl_awt_type,
                                      P_AWT_Date,
	                              l_gl_period_name,
                                      l_base_currency_code,
                                      l_user_defd_formula_exists,
                                      l_nit,
                                      tab_withholdings,
                                      tab_invoice_wh,
                                      P_AWT_Success,
                                      P_Last_Updated_By,
                                      P_Last_Update_Login,
                                      P_Program_Application_Id,
                                      P_Program_Id,
                                      P_Request_Id,
                                      P_Calling_Module
				      );

	   -------------------------------------------------------
	   -- Check whether the withholding tax type has changed
	   -------------------------------------------------------
	   ELSIF (rec_withholding.awt_type_code<>l_previous_awt_type_code) THEN

	   	-------------------------------------------------
	   	-- Process previous withholding tax information
	   	-------------------------------------------------
	   	Jl_Zz_Ap_Withholding_Pkg.Process_Withholding_Name
	   					(l_current_vendor_id,
	   					 rec_awt_type,
	   					 rec_awt_name,
						 rec_suppl_awt_type,
	   					 rec_suppl_awt_name,
	   					 P_AWT_Date,
	   					 tab_withholdings,
	   					 l_initial_awt,
	   					 l_current_awt,
	   					 tab_invoice_wh,
	   					 P_AWT_Success);

	   	IF (P_AWT_Success <> 'SUCCESS') THEN
                    CLOSE c_withholdings;
                    CLOSE c_nit;
	            RETURN;
        	END IF;

	   	-----------------------------------------------------
	   	-- Process previous withholding tax type information.
	   	-- Prorates the withheld amounts, if applicable and
	   	-- Inserts temporary distribution lines
	   	-----------------------------------------------------
            	Process_Withholdings (l_current_vendor_id,
                	              rec_awt_type,
                        	      rec_suppl_awt_type,
                                      P_AWT_Date,
	                              l_gl_period_name,
                                      l_base_currency_code,
                                      l_user_defd_formula_exists,
                                      l_nit,
                                      tab_withholdings,
                                      tab_invoice_wh,
                                      P_AWT_Success,
                                      P_Last_Updated_By,
                                      P_Last_Update_Login,
                                      P_Program_Application_Id,
                                      P_Program_Id,
                                      P_Request_Id,
                                      P_Calling_Module
				      );

		-------------------------------------------------------------
		-- Obtains all the information associated to the wittholding
		-- taxes and initializes a PL/SQL table to store them
		-------------------------------------------------------------
		Initialize_Withholdings (rec_withholding.vendor_id,
					 rec_withholding.awt_type_code,
					 rec_withholding.tax_id,
				 	 rec_awt_type,
				 	 rec_awt_name,
 					 rec_suppl_awt_type,
					 rec_suppl_awt_name,
					 tab_withholdings);

		--------------------------------------
		-- Re-initializes auxillary variables
		--------------------------------------

		l_current_awt := 0;
		l_initial_awt := 1;
		l_previous_awt_type_code := rec_withholding.awt_type_code;
		l_previous_tax_id	 := rec_withholding.tax_id;

	-------------------------------------------
	-- Checks whether the tax name has changed
	-------------------------------------------
	ELSIF (rec_withholding.tax_id <> l_previous_tax_id) THEN


		Jl_Zz_Ap_Withholding_Pkg.Print_Tax_Names (tab_withholdings);

		------------------------------------------------
		-- Process previous withholding tax information
		------------------------------------------------

		Jl_Zz_Ap_Withholding_Pkg.Process_Withholding_Name
						(l_current_vendor_id,
						 rec_awt_type,
						 rec_awt_name,
						 rec_suppl_awt_type,
						 rec_suppl_awt_name,
						 P_AWT_Date,
						 tab_withholdings,
						 l_initial_awt,
						 l_current_awt,
						 tab_invoice_wh,
						 P_AWT_Success);

		IF (P_AWT_Success <> 'SUCCESS') THEN
                    CLOSE c_withholdings;
                    CLOSE c_nit;
	            RETURN;
        	END IF;
        	-------------------------------------------------
		-- Obtains all the information associated to the
		-- withholding tax name
		-------------------------------------------------

		Jl_Zz_Ap_Withholding_Pkg.Initialize_Withholding_Name
	                        		(rec_withholding.awt_type_code,
                                 		 rec_withholding.tax_id,
                                 		 rec_withholding.vendor_id,
                                 		 rec_awt_name,
                                 		 rec_suppl_awt_name);

                -------------------------------------------
		-- Re-initializes the auxillary variables
		-------------------------------------------
		l_previous_tax_id := rec_withholding.tax_id;
		l_initial_awt	  := l_current_awt + 1;

	END IF;

	--------------------------------------------
	-- Checks whether there are some more taxes
	--------------------------------------------
	EXIT WHEN c_withholdings%NOTFOUND;

	-----------------------------------
	-- Obtains the taxable base amount
	-----------------------------------
	l_tax_base_amt := Jl_Zz_Ap_Withholding_Pkg.Get_Taxable_Base_Amount
					(rec_withholding.invoice_id,
					 rec_withholding.invoice_distribution_id,
					 rec_withholding.line_amount,
					 Null,
					 rec_withholding.invoice_amount,
					 rec_awt_type.taxable_base_amount_basis);

	-----------------------------------------------------------
	-- Stores the information of the current tax name into the
	-- PL/SQL table
	-----------------------------------------------------------
	l_current_awt := l_current_awt + 1;
	Jl_Zz_Ap_Withholding_Pkg.Store_Tax_Name
			(tab_withholdings,
			 l_current_awt,
			 rec_withholding.invoice_id,
			 rec_withholding.invoice_distribution_id,
			 rec_withholding.awt_type_code,
			 rec_withholding.tax_id,
			 rec_awt_name.name,
			 rec_awt_name.tax_code_combination_id,
			 rec_awt_name.awt_period_type,
			 rec_awt_type.jurisdiction_type,
			 rec_withholding.line_amount,
			 l_tax_base_amt);

	------------------------------------
	-- Fetches next tax type / tax name
	------------------------------------
	FETCH c_withholdings into rec_withholding;

	END LOOP; -- withholding by NIT

      END IF;  --c_withholdings is notfound no more withholdings for the nit

	---------------------------------
	-- Closes the withholding cursor
	---------------------------------
	debug_info := 'Close cursor for all withholdings with same NIT';
	CLOSE c_withholdings;

	--------------------
	-- Fetches next NIT
	--------------------
	FETCH c_nit into l_nit;
	EXIT WHEN c_nit%NOTFOUND;

   END LOOP;

   -------------------------
   -- Closes the NIT cursor
   -------------------------
   debug_info := 'Close cursor for all selected NIT';
   CLOSE c_nit;

EXCEPTION
   WHEN others THEN
     DECLARE
     	error_text	Varchar2(512) := substr(sqlerrm, 1, 512);
     BEGIN
     	P_AWT_Success := error_text;

        IF (SQLCODE <> -20001) THEN
            FND_MESSAGE.SET_NAME('JL','JL_ZZ_AP_DEBUG');
            FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
            FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
            FND_MESSAGE.SET_TOKEN('PARAMETERS',
                      '  Invoice Id = '        || to_char(P_Invoice_Id) ||
                      ', Awt Date  = '         || to_char(P_Awt_Date,'YYYY/MM/DD') ||
                      ', Calling Module = '    || P_Calling_Module ||
                      ', Create Dists = '      || P_Create_Dists ||
                      ', Amount  = '           || to_char(P_Amount));

            FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
        END IF;
        APP_EXCEPTION.RAISE_EXCEPTION;
     END;

END Jl_Co_Ap_Calculate_AWT_Amounts;


/**************************************************************************
 *                                                                        *
 * Name       : User_Defined_Formula_Exists                               *
 * Purpose    : This function returns TRUE, if there is atleast one       *
 *              type within this NIT, with the user defined formula       *
 *              flag set to 'Y'. Otherwise, it returns FALSE              *
 *                                                                        *
 **************************************************************************/

FUNCTION User_Defined_Formula_Exists
			(P_Invoice_Id	IN Number,
			 P_NIT		IN Varchar2) RETURN BOOLEAN
IS
   -------------------------------
   -- Local Variables Definition
   -------------------------------
   l_user_defined_formula_flag    jl_zz_ap_awt_types.user_defined_formula_flag%TYPE;
   debug_info			  Varchar2(100);
   current_calling_sequence	  Varchar2(2000);

   --------------------------------------------------------------------------
   -- Cursor to select the user defined formula flag of the withholding
   -- types with same NIT and associated to the invoice
   --------------------------------------------------------------------------
   CURSOR c_user_defined_formula_flag(Inv_Id Number,Nit Varchar2)
   IS
   SELECT
 	  jlat.user_defined_formula_flag user_defined_formula_flag
   FROM
	  jl_zz_ap_inv_dis_wh		jlwh,
	  ap_invoices			apin,
	  ap_invoice_distributions	apid,
	  jl_zz_ap_supp_awt_types	jlst,
	  jl_zz_ap_sup_awt_cd		jlsc,
	  jl_zz_ap_awt_types		jlat,
	  po_vendors			pove
   WHERE
	  apid.invoice_id 		= jlwh.invoice_id
   AND	  apid.invoice_distribution_id	= jlwh.invoice_distribution_id
   AND	  apin.invoice_id		= apid.invoice_id
   AND	  pove.vendor_id		= apin.vendor_id
   AND	  jlwh.supp_awt_code_id		= jlsc.supp_awt_code_id
   AND 	  jlsc.supp_awt_type_id 	= jlst.supp_awt_type_id
   AND	  jlat.awt_type_code		= jlst.awt_type_code
   AND 	  jlwh.invoice_id		= Inv_Id
   AND	  nvl(apid.global_attribute2,pove.segment1)= Nit
   AND 	  nvl(jlat.user_defined_formula_flag,'N') = 'Y';


BEGIN

   current_calling_sequence := 'JL_CO_AP_WITHHOLDING_PKG.User_Defined_Formula_Exists';

   -------------------------------------------------------------------------
   -- Opens the cursor to select all the user defined formula flag
   -------------------------------------------------------------------------
   debug_info := 'Open cursor to get user defined formula flag';
   OPEN c_user_defined_formula_flag(P_Invoice_Id, P_NIT);
   debug_info := 'Fetch from cursor to get user defined formula flag';
   FETCH c_user_defined_formula_flag INTO l_user_defined_formula_flag;

   --------------------------------------------------
   -- Checks whether the cursor has fetched any row
   -- Returns FALSE, if there are no rows fetched.
   -- Otherwise, returns TRUE
   --------------------------------------------------
   IF (c_user_defined_formula_flag%NOTFOUND) THEN
   	CLOSE c_user_defined_formula_flag;
   	RETURN FALSE;
   ELSE
    	CLOSE c_user_defined_formula_flag;
   	RETURN TRUE;

   END IF;

EXCEPTION
   WHEN others THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('JL','JL_ZZ_AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS',
                      '  Invoice Id  = '       || to_char(P_Invoice_Id) ||
                      ', NIT    = '            || P_NIT );

              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

END User_Defined_Formula_Exists;

/**************************************************************************
 *                                                                        *
 * Name       : Initialize_Withholdings                                   *
 * Purpose    : Obtains all the attributes for the current withholding    *
 *              tax type and name. This procedure also initializes the    *
 *              PL/SQL table to store the withholdings                    *
 *                                                                        *
 **************************************************************************/
PROCEDURE Initialize_Withholdings
         (P_Vendor_Id           IN     Number,
          P_AWT_Type_Code       IN     Varchar2,
          P_Tax_Id              IN     Number,
          P_Rec_AWT_Type        OUT NOCOPY    jl_zz_ap_awt_types%ROWTYPE,
          P_Rec_AWT_Name        OUT NOCOPY    Jl_Zz_Ap_Withholding_Pkg.Rec_AWT_Code,
          P_Rec_Suppl_AWT_Type  OUT NOCOPY    jl_zz_ap_supp_awt_types%ROWTYPE,
          P_Rec_Suppl_AWT_Name  OUT NOCOPY    jl_zz_ap_sup_awt_cd%ROWTYPE,
          P_Wh_Table            IN OUT NOCOPY Jl_Zz_Ap_Withholding_Pkg.Tab_Withholding)
IS
BEGIN

    Jl_Zz_Ap_Withholding_Pkg.Initialize_Withholding_Type
                                (P_AWT_Type_Code,
                                 P_Vendor_Id,
                                 P_Rec_AWT_Type,
                                 P_Rec_Suppl_AWT_Type);

    Jl_Zz_Ap_Withholding_Pkg.Initialize_Withholding_Name
                                (P_AWT_Type_Code,
                                 P_Tax_Id,
                                 P_Vendor_Id,
                                 P_Rec_AWT_Name,
                                 P_Rec_Suppl_AWT_Name);

    Jl_Zz_Ap_Withholding_Pkg.Initialize_Withholding_Table
                                (P_Wh_Table);

END Initialize_Withholdings;


/**************************************************************************
 *                                                                        *
 * Name       : Process_Withholdings                                      *
 * Purpose    : Process the information for the current withholding tax   *
 *              type and name                                             *
 *                                                                        *
 **************************************************************************/
PROCEDURE Process_Withholdings
      (P_Vendor_Id              IN     Number,
       P_Rec_AWT_Type           IN     jl_zz_ap_awt_types%ROWTYPE,
       P_Rec_Suppl_AWT_Type     IN     jl_zz_ap_supp_awt_types%ROWTYPE,
       P_AWT_Date               IN     Date,
       P_GL_Period_Name         IN     Varchar2,
       P_Base_Currency_Code     IN     Varchar2,
       P_User_Defd_Formula	IN     Boolean,
       P_NIT_Number		IN     Varchar2	  Default null,
       P_Tab_Withhold           IN OUT NOCOPY Jl_Zz_Ap_Withholding_Pkg.Tab_Withholding,
       P_Tab_All_Withhold	IN OUT NOCOPY Jl_Zz_Ap_Withholding_Pkg.Tab_All_Withholding,
       P_AWT_Success		OUT NOCOPY    Varchar2,
       P_Last_Updated_By        IN     Number     Default null,
       P_Last_Update_Login      IN     Number     Default null,
       P_Program_Application_Id IN     Number     Default null,
       P_Program_Id             IN     Number     Default null,
       P_Request_Id             IN     Number     Default null,
       P_Calling_Module         IN     Varchar2   Default null
       )

IS
    l_revised_amount_flag       Boolean := FALSE;

BEGIN
    ------------------------------------------------
    -- Process previous withholding tax type
    ------------------------------------------------
    Jl_Zz_Ap_Withholding_Pkg.Process_Withholding_Type
                                (P_Rec_AWT_Type,
                                 P_Rec_Suppl_AWT_Type,
                                 P_AWT_Date,
                                 P_Base_Currency_Code,
                                 P_Tab_Withhold);

    --------------------------------
    -- Prorates the withheld amounts
    --------------------------------
    --BUG 9668909
    Jl_Zz_Ap_Withholding_Pkg.Prorate_Withholdings(P_Tab_Withhold,
						      P_Base_Currency_Code);
    Jl_Zz_Ap_Withholding_Pkg.Store_Prorated_Withholdings
   						(P_Tab_Withhold,
   					         P_Tab_All_Withhold);
    --BUG 9668909
    /*IF ((P_user_defd_formula) AND
	(nvl(P_Rec_AWT_Type.user_defined_formula_flag,'N') = 'N')) THEN
	Jl_Zz_Ap_Withholding_Pkg.Prorate_Withholdings(P_Tab_Withhold,
						      P_Base_Currency_Code);
	Jl_Zz_Ap_Withholding_Pkg.Store_Prorated_Withholdings
   						(P_Tab_Withhold,
   					         P_Tab_All_Withhold);
    END IF;*/



    ---------------------------------------------------------
    -- Determines whether revised taxable base amount should
    -- be considered while storing into temporary table
    ---------------------------------------------------------

    IF (nvl(P_Rec_AWT_Type.user_defined_formula_flag,'N') = 'Y') THEN
	l_revised_amount_flag := TRUE;
    ELSE
	l_revised_amount_flag := FALSE;
    END IF;

    ----------------------------------------
    -- Insert Temporary Distributions Lines
    ----------------------------------------
    Jl_Zz_Ap_Withholding_Pkg.Store_Into_Temporary_Table
                                (P_Tab_Withhold,
                                 P_Vendor_Id,
                                 P_AWT_Date,
                                 P_GL_Period_Name,
                                 P_Base_Currency_Code,
                                 l_revised_amount_flag,
                                 TRUE,                --BUG 9668909 -- Prorated Amount Flag
                                 FALSE,               -- Zero WH Applicable
                                 FALSE,		      -- Handle Bucket
                                 P_AWT_Success,
                                 P_Last_Updated_By,
                                 P_Last_Update_Login,
                                 P_Program_Application_Id,
                                 P_Program_Id,
                                 P_Request_Id,
                                 P_Calling_Module,
                                 null,		      -- checkrun name
                                 null,                -- checkrun id
                                 null,		      -- payment number
				 'JL.CO.APXINWKB.DISTRIBUTIONS',
                                 P_NIT_Number
                                 );
    IF (P_AWT_Success <> 'SUCCESS') THEN
        RETURN;
    END IF;

    Jl_Zz_Ap_Withholding_Pkg.Print_Tax_Names (P_Tab_Withhold);

END Process_Withholdings;

END JL_CO_AP_WITHHOLDING_PKG;

/
