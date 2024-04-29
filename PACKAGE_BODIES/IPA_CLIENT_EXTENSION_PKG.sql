--------------------------------------------------------
--  DDL for Package Body IPA_CLIENT_EXTENSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IPA_CLIENT_EXTENSION_PKG" AS
 /* $Header: IPAAMCEB.pls 120.1 2005/08/16 15:57:22 dlanka noship $ */

   /*
     * This function returns the name of the Segment identified
     * by the given qualifier
     */
    FUNCTION unique_qualifier_to_segment(appl_id   IN NUMBER,
                                         code      IN VARCHAR2,
                                         num       IN NUMBER,
                                         qualifier IN VARCHAR2,
                                         name      IN OUT NOCOPY VARCHAR2)
    RETURN BOOLEAN
    IS
    BEGIN

        SELECT s.segment_name INTO name
          FROM fnd_id_flex_segments s,
               fnd_segment_attribute_values sav,
  	       fnd_segment_attribute_types sat
         WHERE s.application_id = appl_id
           AND s.id_flex_code = code
           AND s.id_flex_num = num
           AND s.enabled_flag = 'Y'
           AND s.application_column_name = sav.application_column_name
           AND sav.application_id = appl_id
           AND sav.id_flex_code = code
           AND sav.id_flex_num = num
           AND sav.attribute_value = 'Y'
           AND sav.segment_attribute_type = sat.segment_attribute_type
           AND sat.application_id = appl_id
           AND sat.id_flex_code = code
           AND sat.segment_attribute_type = qualifier;

        RETURN TRUE;

    EXCEPTION
        WHEN TOO_MANY_ROWS THEN
            fnd_message.set_name('FND', 'FLEXWK-USE UNIQUE QUALIFIER');
            fnd_message.set_token('QUAL', qualifier);
            RETURN FALSE;

        WHEN OTHERS THEN
            fnd_message.set_name('FND', 'FLEXWK-NO SEG MATCHING QUAL');
            fnd_message.set_token('QUAL', qualifier);
            fnd_message.set_token('NUM', TO_CHAR(num));
            fnd_message.set_token('CODE', code);
            RETURN FALSE;

    END unique_qualifier_to_segment;

    /*
     * This function returns the segment number for the given
     * segment in a code combination.
     */
    FUNCTION get_segment_number(appl_id  IN NUMBER,
                                code     IN VARCHAR2,
                                num      IN NUMBER,
                                segment  IN VARCHAR2,
                                sequence IN OUT NOCOPY NUMBER)
    RETURN BOOLEAN
    IS
    seg_num NUMBER;
    BEGIN

       /*
        * Get the user specified segment number
        */
        SELECT segment_num into seg_num
          FROM fnd_id_flex_segments
         WHERE application_id = appl_id
           AND id_flex_code = code
           AND id_flex_num = num
           AND segment_name = segment
           AND enabled_flag = 'Y';

       /*
        * The above value gives the relative order of the
	    * segments. Convert it into the segment number.
        */
        SELECT count(segment_num) INTO sequence
          FROM fnd_id_flex_segments
         WHERE application_id = appl_id
           AND id_flex_code = code
           AND id_flex_num = num
           AND enabled_flag = 'Y'
           AND segment_num <= seg_num;

         RETURN TRUE;

     EXCEPTION
         WHEN OTHERS THEN
            fnd_message.set_name('FND', 'FLEXWK-CANNOT FIND SEG');
            fnd_message.set_token('SEG', segment);
            fnd_message.set_token('NUM', TO_CHAR(num));
            fnd_message.set_token('CODE', code);
            RETURN FALSE;

     END get_segment_number;

     /**********************************************************************
     * This Procedure gets the Default Depreciation expense account.
     *
     * If Asset is a Group Assets (i.e Default group asset is defined for the
     * category - Book) then this procedure gets the Deprn expense account
     * from  the Group Asset Setup (i.e IFA_GROUP_DEFAULTS).
     *
     * If Asset is a Unit Asset ,it derives the Deprn expense by the method specified
     * in build_deprn_expense_acct procedure
     *
     * The PARAMETERS are
     *  PARAMETER NAME         Description           TYPE        Mandatory/Optional
     *  --------------         -----------           ----        ------------------
     *  p_book_type_code      - Asset Book          - IN          Mandatory
     *  p_asset_category_id   - Asset Category      - IN          Mandatory
     *  p_location_id         - Asset location      - IN          Optional
     *  p_expenditure_item_id - Asset Category      - IN          Optional
     *  p_expense_ccid_out    - Asset Deprn Expense - IN/OUT      Mandatory
     *  p_err_stack           - Error Stack         - IN/OUT      Mandatory
     *  p_err_stage           - Error Stage         - IN/OUT      Mandatory
     *  p_err_code            - Error Code          - IN/OUT      Mandatory
     *
     * Note - Error Stack, Error Code and Error stage are used for debugging purpose
     *        So Pass a parameter of variable charecter of minimum length of 650
     ***********************************************************************/

     procedure get_default_deprn_expense(p_book_type_code in varchar2,
                                         p_asset_category_id in number,
                                         p_location_id in number default null,
                                         p_expenditure_item_id in number default null,
                                         p_expense_ccid_out in out NOCOPY number,
                                         p_err_stack in out NOCOPY varchar2,
                                         p_err_stage in out NOCOPY varchar2,
                                         p_err_code in out NOCOPY varchar2)
     is

     /**** Commented for Enh#2800443 - Begin
     CURSOR get_group_asset_id IS
     SELECT default_group_asset_id
     FROM   fa_category_books
     WHERE  category_id = p_asset_category_id
     AND    book_type_code = p_book_type_code;


     CURSOR get_depr_ccid (p_group_asset_id in number) IS
     SELECT deprn_expense_acct_ccid
     FROM   fa_group_asset_default
     WHERE  book_type_code = p_book_type_code
     AND    group_asset_id = p_group_asset_id;

     Commented for Enh#28000443 - End *****/

     /* Added for Enh#2800443 - Begin*/

     CURSOR get_group_asset_id IS
     SELECT group_asset_id
     FROM   fa_category_book_defaults
     WHERE  category_id = p_asset_category_id
     AND    book_type_code = p_book_type_code
     AND    trunc(SYSDATE) between start_dpis and nvl(end_dpis, TRUNC(SYSDATE));


     CURSOR get_depr_ccid (p_group_asset_id in number) IS
     SELECT code_combination_id
     FROM   fa_distribution_history
     WHERE  asset_id = p_group_asset_id
     AND    transaction_header_id_out is null
     AND    rownum = 1;

     /* Added for Enh#2800443 - End */


     l_group_asset_id number;
     l_old_err_stack varchar2(650);


     Begin
     l_old_err_stack := p_err_stack;
     p_err_stack := p_err_stack||'->'||'GET_DEFAULT_DEPRN_EXPENSE';
     p_err_stage := 'Getting Default group';

       open get_group_asset_id;
       fetch get_group_asset_id into  l_group_asset_id;

       if  l_group_asset_id is not null then  /* Group Asset */
          p_err_stage := 'Getting Default group depreciation Expense';
          open get_depr_ccid(l_group_asset_id);
          fetch get_depr_ccid into p_expense_ccid_out;
          close get_depr_ccid;
       --
        else /* Unit Asset */
          -- Procedure to Get  Default depreciation Expense for unit asset
           build_deprn_expense_acct(p_book_type_code,
                                    p_asset_category_id,
                                    p_location_id,
                                    p_expenditure_item_id,
                                    p_expense_ccid_out  ,
                                    p_err_stack  ,
                                    p_err_stage  ,
                                    p_err_code  );
       end if;

       close get_group_asset_id;
       p_err_stack := l_old_err_stack;

     End get_default_deprn_expense;

   /***************************************************************************************
    * This procedure derives the default depreciation expense account for the unit assets
    * The Default mechanism that is being followed is:
    *  1. The Natural accout segment comes from the Depreciation Expense Segment specified
    *     for the Category - Book and
    *  2. All other segments get defaulted from the  Account generator default
    *     specified at the Book Controls
    *
    *  Note : If the User wants to Customize the default segments, they can do so by calling
    *  steps 1 to  step3 for manipulating the segments values for each of the segments, before
    *  finally callig step 4 to derive the expense account for the unit assets. In step 4
    *  If the CCID already exists it will be used, Otherwise a new CCID will be created
    *  if dynamic insert is allowed
    **************************************************************************************/
procedure build_deprn_expense_acct(p_book_type_code in varchar2,
                                   p_asset_category_id in number,
                                   p_location_id in number default null,
                                   p_expenditure_item_id in number default null,
                                   p_expense_ccid_out in out NOCOPY number,
                                   p_err_stack in out NOCOPY varchar2,
                                   p_err_stage in out NOCOPY varchar2,
                                   p_err_code  in out NOCOPY varchar2)
is
Cursor c_appln is
select nvl(application_id,101)
from fnd_application
where application_short_name = 'SQLGL';
l_appln_id   fnd_application.application_id%type;

Cursor c_book_info is
Select book_class,accounting_flex_structure,  flexbuilder_defaults_ccid
from fa_book_controls
where book_type_code = p_book_type_code;
book_info_rec c_book_info%rowtype;

Cursor c_deprn_expense_seg is
select deprn_expense_acct
from fa_category_books
where category_id    = p_asset_category_id
and   book_type_code = p_book_type_code;

l_deprn_expense_seg fa_category_books.deprn_expense_acct%type;

segarr fnd_flex_ext.segmentarray;

result  boolean;
err_msg  varchar2(1000);
l_no_segments  number;
i binary_integer;
l_acct_segment_name varchar2(30) default null;
l_acct_segment_seq  number := 0;
l_ccid_out number := 0;
l_old_err_stack varchar2(650);

BEGIN
  l_old_err_stack := p_err_stack;

  --Initialize the array
  FOR i in 1..30 LOOP
     segarr(i) := null;
  END LOOP;

  p_err_stack := p_err_stack||'->'||'BUILD_DEPRN_EXPENSE_ACCOUNT';
  p_err_stage := 'Getting Application ID';
  open c_appln;
  fetch c_appln into l_appln_id;
  close c_appln;

  /***************************************************************************
		      Getting Book Information
  ****************************************************************************/

  p_err_stage := 'Getting Book Information';
  open c_book_info;
  fetch c_book_info into book_info_rec;
  if(c_book_info%NOTFOUND) then
    close c_book_info;
    p_err_code := 'IFA_INVALID_BOOK_TYPE';
    return;
  end if;
  close c_book_info;


  /***************************************************************************
		   Getting Depreciation Expense Segment from Asset Category - Book
  ****************************************************************************/

  p_err_stage := 'Getting Depreciation Expense Segment';
  open c_deprn_expense_seg;
  fetch c_deprn_expense_seg into l_deprn_expense_seg;
  if(c_deprn_expense_seg%NOTFOUND) then
     close c_deprn_expense_seg;
     p_err_code := 'IFA_CATG_NOT_DEFINED_FOR_BOOK';
     return;
  end if;
  close c_deprn_expense_seg;



  /***************************************************************************
  Get the Segment values in Segarr for the Default Account Generator CCID
  ****************************************************************************/

  p_err_stage := 'Splitting segments from Default ccid';
  if(NOT fnd_flex_ext.get_segments(application_short_name => 'SQLGL'
                                   ,key_flex_code => 'GL#'
                                   ,structure_number => book_info_rec.accounting_flex_structure
                                   ,combination_id => book_info_rec.flexbuilder_defaults_ccid
                                   ,n_segments => l_no_segments
                                   ,segments => segarr)
    ) then
      err_msg := fnd_message.get;
      p_err_code := err_msg;
      return;
  end if;


  /***************************************************************************
			Step 1:
     Find the segment name For Natural Account
     For  Natural account   -   Pass 'GL_ACCOUNT'
	  Balancing segment -   Pass 'GL_BALANCING'

     Segment Name is stored in l_acct_segment_name
  ****************************************************************************/

  p_err_stage := 'Getting Natural Account Segment Name';
  If (NOT unique_qualifier_to_segment(l_appln_id
                                      ,'GL#'
                                      ,book_info_rec.accounting_flex_structure
                                      ,'GL_ACCOUNT'
                                      ,l_acct_segment_name)
     ) then
       p_err_code := 'IFA_ERR_GL_ACCOUNT_SEG_NAME';
       return;
  end if;


  /*******************************************************************************
                        Step 2:
      Get the sequence number for the natural account
      Pass l_acct_segment_name for Segment Name
      Sequence number for the natural account will be passed to l_acct_segment_seq
  ********************************************************************************/

  p_err_stage := 'Getting Natural Account Segment Sequence';
  if (NOT get_segment_number(l_appln_id
                            ,'GL#'
                            ,book_info_rec.accounting_flex_structure
                            ,l_acct_segment_name
                            ,l_acct_segment_seq)
     ) then
       p_err_code := 'IFA_ERR_GL_ACCOUNT_SEG_SEQUENCE';
       return;
  end if;


  /***************************************************************************
		       Step 3:
      Segarr is an array structure and has been initialized with segments from
      Default Account Generator CCID

      Assign the natural segment with the default expense segment for the
      category and book
  ****************************************************************************/

  p_err_stage := 'Assigning Natural Account to efault expense segment for the category and book';
  segarr(l_acct_segment_seq) := l_deprn_expense_seg;



  /***************************************************************************
		      Step 4
      Get the  code combination ID for the combined segments
  ****************************************************************************/

  p_err_stage := 'Getting the New code combination';
  if(NOT fnd_flex_ext.get_combination_id(application_short_name => 'SQLGL'
                                        ,key_flex_code => 'GL#'
                                        ,structure_number => book_info_rec.accounting_flex_structure
                                        ,validation_date => sysdate
                                        ,n_segments => l_no_segments
                                        ,segments => segarr
                                        ,combination_id => p_expense_ccid_out )
    ) then
      err_msg := FND_MESSAGE.get;
      --p_err_code := 'IFA_ERR_GETIING_NEW_CCID';
      p_err_code := substr(err_msg,1,200);
      return;
  end if;
      p_err_stage := 'build_deprn_expense_acct - Successfully Completed';
      p_err_stack := l_old_err_stack ;
  END build_deprn_expense_acct;


  /* Moved the following code from /fadev/fa/11.5/patch/115/sql/FACCEX1MB.pls
     for Enh#2800443, as that is being stubbed out for FA.M */
  /***************************************************************************
  * The following examples demonstrate how you can define your own
  * rules to Detremine Units to adjust on Existing Asset.
  * Three examples are included:
  *    1.   If the Expenditure Type is Supplier and Raw Cost > 0 then
  *	     Units To Adjust = Qty on the Expenditure Item
  *    2.   If the Expenditure Type is Supplier and Raw Cost < 0 then
  * 	     Units To Adjust = -1 *Qty on the Expenditure Item
  *    3.   If the Expenditure Type is NOT Supplier  then
  * 	     Units To Adjust =  0
  *
  ****************************************************************************/

  PROCEDURE SET_UNITS_TO_ADJUST(x_mass_addition_row   IN fa_mass_additions%ROWTYPE,
                                x_units_to_adjust     IN OUT NOCOPY NUMBER,
                                x_error_code          IN OUT NOCOPY VARCHAR2,
                                x_error_message       IN OUT NOCOPY VARCHAR2) IS

     -- Define local variables

      l_expenditure_type    pa_expenditure_items_all.expenditure_type%TYPE;
      l_raw_cost            pa_expenditure_items_all.raw_cost%TYPE;
      l_quantity            pa_expenditure_items_all.quantity%TYPE;
      l_project_Asset_line_id pa_project_asset_lines_all.project_asset_line_id%TYPE;

     CURSOR get_exp_item_details IS
     SELECT 	pei.expenditure_type,pei.raw_cost,pei.quantity
     FROM   	pa_project_asset_lines ppal,
                pa_expenditure_items pei,
                pa_project_asset_line_details ppald
     WHERE      ppal.project_Asset_line_id = l_project_Asset_line_id
     AND        ppal.project_asset_line_detail_id= ppald.project_asset_line_detail_id
     AND        pei.expenditure_item_id = ppald.expenditure_item_id
     AND        ROWNUM=1;

  BEGIN

     -- Initialize output parameters

     x_error_code := '0';

   -- ==============================================================
   -- Extension logic to set Units To Adjust from the Expenditure Item
   -- ==============================================================

   -- Attributes of the Mass Addition record are stored in variable
   -- x_mass_addition_Row. This extension uses the Project Asset line Id
   -- stored in  parameter x_mass_addition_Row to identify summarized
   -- Expenditure items. Using Ids of the Exp items Expenditure Type and
   -- Raw Cost can be determined.

     l_project_Asset_line_id := x_mass_addition_row.project_Asset_line_id;


     -- Initialize the error message so that if we receive an unexpected
     -- error and control moves to the exception handling part of the
     -- code, we will know where we were at the time of the problem.

     X_Error_Message := 'Problem Getting the Expenditure Type';


     -- Opening cursor to get the Exp Item details
     OPEN get_exp_item_details ;
     FETCH get_exp_item_details
       INTO l_expenditure_type,l_raw_cost,l_quantity;
     CLOSE get_exp_item_details ;

     -- Setting Units to adjust based on Exp Item details

     IF l_expenditure_type = 'SUPPLIER' THEN
    	IF l_raw_cost > 0 THEN
    	  x_units_to_adjust := l_quantity;
    	ELSIF l_raw_cost < 0 THEN
    	  x_units_to_adjust := -1*l_quantity;
    	END IF;
     ELSE
    	x_units_to_adjust := 0;
     END IF;

  EXCEPTION
    WHEN Others THEN
      x_error_code := SQLCODE;
  END SET_UNITS_TO_ADJUST;


END IPA_CLIENT_EXTENSION_PKG;

/
