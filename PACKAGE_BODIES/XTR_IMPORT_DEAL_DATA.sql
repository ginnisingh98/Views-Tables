--------------------------------------------------------
--  DDL for Package Body XTR_IMPORT_DEAL_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_IMPORT_DEAL_DATA" as
/* $Header: xtrimddb.pls 120.12 2005/06/29 08:33:04 badiredd ship $*/


  /*--------------------------------------------------------------*/
  Procedure	Put_Log(Avr_Buff In Varchar2) is
  /*--------------------------------------------------------------*/
  Begin
	Fnd_File.Put_Line(Fnd_file.LOG,Avr_Buff);
  End;


  /*--------------------------------------------------------------*/
  Procedure Log_Interface_Errors(AExt_Deal_Id        In Varchar2,
                                 ADeal_Type             Varchar2,
                                 Error_Column        In Varchar2,
                                 Error_Code          In Varchar2,
                                 Transaction_No      In Number) is
  /*--------------------------------------------------------------*/

  Ld_sysdate Date Default Sysdate;
  v_error_line Varchar2(4000):='    ';
  v_disp_error_column Varchar2(80);

  Begin

  	   /* If reporting a DFF error, substitute the value of the first detected
  	      error into the column name for the CM log. This assumes that this
  	      procedure is immediately called after running validate flex fields*/
  	   if (Error_Column='Attribute16' and G_DFF_Error_column is not null) then
  	     v_disp_error_column := G_DFF_Error_column;
  	     G_DFF_Error_column := ''; -- only use once
  	   else
  	     v_disp_error_column := nvl(Error_Column,' ');
  	   end if;

  	   if (Transaction_No is not null) then
  	     v_error_line:=v_error_line||fnd_message.get_string('XTR','XTR_TRANSACTION_LABEL')||lpad(Transaction_No,6)||', ';
  	   end if;

  	   v_error_line:=v_error_line||lpad(v_disp_error_column,20)||' - '||fnd_message.get_string('XTR',Error_Code);

  	   g_current_deal_log_list(g_current_deal_log_list.count):=v_error_line;


	if (error_column is not null) then

		Insert Into Xtr_Interface_Errors(CREATED_BY	        ,
						 CREATION_DATE          ,
						 LAST_UPDATED_BY        ,
						 LAST_UPDATE_DATE       ,
						 LAST_UPDATE_LOGIN      ,
						 EXTERNAL_DEAL_ID       ,
						 DEAL_TYPE              ,
						 ERROR_COLUMN           ,
						 ERROR_CODE             ,
						 TRANSACTION_NO         )
					 Values	(Fnd_Global.User_Id,
						 Ld_sysdate,
						 Null,
						 Null,
						 Null,
						 AExt_Deal_Id,
						 ADeal_Type,
						 Error_Column,
						 Error_Code,
						 Transaction_No);
	end if;
  End;


  /*--------------------------------------------------------------*/
  Procedure Log_Deal_Warning(p_warning_message  In Varchar2) IS
  BEGIN
      g_current_deal_log_list(g_current_deal_log_list.count):=p_warning_message;
      g_has_warnings:=true;
  END Log_Deal_Warning;

  /*--------------------------------------------------------------*/
  /* The following code implements the duplicate deal check.      */
  /*--------------------------------------------------------------*/
  PROCEDURE CHECK_DEAL_DUPLICATE_ID(p_external_deal_id    IN VARCHAR2,
                                    p_external_deal_type  IN VARCHAR2,
                                    p_deal_type           IN VARCHAR2,
                                    error                 OUT NOCOPY BOOLEAN) is
  /*--------------------------------------------------------------*/
  l_count NUMBER;

  begin

     /* check for duplicate External Deal ID in XTR_DEALS */
     if p_deal_type = 'FX' then
        select count(*)
        into   l_count
        from   XTR_DEALS
        where  external_deal_id = p_external_deal_id
        and    deal_type        = p_deal_type
        and    status_code     <> 'CANCELLED';

     elsif p_deal_type = 'IG' then
        select count(*)
        into   l_count
        from   XTR_INTERGROUP_TRANSFERS
        where  external_deal_id = p_external_deal_id;

     elsif p_deal_type = 'NI' then
        select count(*)
        into   l_count
        from   XTR_DEALS
        where  external_deal_id = p_external_deal_id
        and    deal_type        = p_deal_type
        and    status_code     <> 'CANCELLED';

     end if;

     if (l_count > 0) then
        error := TRUE;
     else
        error := FALSE;
     end if;

     if (error = TRUE) then
        update xtr_deals_interface
        set    load_status_code = 'DUPLICATE_DEAL_ID',
               last_update_date = trunc(SYSDATE),
               Last_Updated_by  = fnd_global.user_id
        where  external_deal_id = p_external_deal_id
        and    deal_type        = p_external_deal_type;

        log_interface_errors(p_external_deal_id,p_external_deal_type,null,'XTR_DUPLICATE_ID');
     end if;

  end CHECK_DEAL_DUPLICATE_ID;


  /*------------------------------------------------------------*/
  /* The following code implements the CHECK_USER_AUTH process  */
  /*------------------------------------------------------------*/
  PROCEDURE CHECK_USER_AUTH(p_external_deal_id IN VARCHAR2,
                            p_deal_type    IN VARCHAR2,
                            p_company_code IN VARCHAR2,
                            error OUT NOCOPY BOOLEAN) is
  /*------------------------------------------------------------*/
  l_dummy varchar2(1);

  BEGIN

        error := FALSE;

     BEGIN

     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('XTR_IMP_DEAL_DATE.CHECK_USER_AUTH');
        xtr_risk_debug_pkg.dlog('CHECK_USER_AUTH: ' || 'p_company_code',p_company_code);
     END IF;

       select 'Y'
        into   l_dummy
        from   xtr_parties_v
        where  party_type = 'C'
        and    party_code = p_company_code
        and    rownum     = 1;

     IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpop('XTR_IMP_DEAL_DATA.CHECK_USER_AUTH');
     END IF;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
        error := TRUE;
        log_interface_errors( p_external_deal_id ,p_deal_type,'CompanyCode','XTR_INV_COMP_CODE');
        IF xtr_risk_debug_pkg.g_Debug THEN
           xtr_risk_debug_pkg.dpop('XTR_IMP_DEAL_DATA.CHECK_USER_AUTH');
        END IF;

     END;

  END CHECK_USER_AUTH;


  /*--------------------------------------------------------------------------------*/
  FUNCTION val_desc_flex( p_Interface_Rec    IN XTR_DEALS_INTERFACE%ROWTYPE,
                          p_desc_flex        IN VARCHAR2,
                          p_error_segment    IN OUT NOCOPY VARCHAR2) return BOOLEAN is
  /*--------------------------------------------------------------------------------*/
  l_segment number(3);

  BEGIN

     fnd_flex_descval.set_column_value('ATTRIBUTE1',p_Interface_Rec.ATTRIBUTE1);
     fnd_flex_descval.set_column_value('ATTRIBUTE2',p_Interface_Rec.ATTRIBUTE2);
     fnd_flex_descval.set_column_value('ATTRIBUTE3',p_Interface_Rec.ATTRIBUTE3);
     fnd_flex_descval.set_column_value('ATTRIBUTE4',p_Interface_Rec.ATTRIBUTE4);
     fnd_flex_descval.set_column_value('ATTRIBUTE5',p_Interface_Rec.ATTRIBUTE5);
     fnd_flex_descval.set_column_value('ATTRIBUTE6',p_Interface_Rec.ATTRIBUTE6);
     fnd_flex_descval.set_column_value('ATTRIBUTE7',p_Interface_Rec.ATTRIBUTE7);
     fnd_flex_descval.set_column_value('ATTRIBUTE8',p_Interface_Rec.ATTRIBUTE8);
     fnd_flex_descval.set_column_value('ATTRIBUTE9',p_Interface_Rec.ATTRIBUTE9);
     fnd_flex_descval.set_column_value('ATTRIBUTE10',p_Interface_Rec.ATTRIBUTE10);
     fnd_flex_descval.set_column_value('ATTRIBUTE11',p_Interface_Rec.ATTRIBUTE11);
     fnd_flex_descval.set_column_value('ATTRIBUTE12',p_Interface_Rec.ATTRIBUTE12);
     fnd_flex_descval.set_column_value('ATTRIBUTE13',p_Interface_Rec.ATTRIBUTE13);
     fnd_flex_descval.set_column_value('ATTRIBUTE14',p_Interface_Rec.ATTRIBUTE14);
     fnd_flex_descval.set_column_value('ATTRIBUTE15',p_Interface_Rec.ATTRIBUTE15);

     fnd_flex_descval.set_context_value(p_Interface_Rec.ATTRIBUTE_CATEGORY);

     /* G_DFF_Error_Column holds the value of the first column that has an error
        this value is used by log_error to change the column that is displayed
        in the CM log.  See bug 2807931 for more details */
     G_DFF_Error_Column := '';

     IF fnd_flex_descval.validate_desccols('XTR',p_desc_flex) then
       if (fnd_flex_descval.is_valid) then
           null;
       else
           l_segment := to_char(fnd_flex_descval.error_segment) ;
           If l_segment Is not null Then
              G_DFF_Error_Column := 'Attribute'||l_segment;
              p_error_segment := 'Attribute16';
           Else
                p_error_segment := 'AttributeCategory';
           End If;
           return(FALSE);
       end if;

       if (fnd_flex_descval.value_error OR
            fnd_flex_descval.unsupported_error) then

           l_segment := to_char(fnd_flex_descval.error_segment) ;
           If l_segment Is not null Then
              G_DFF_Error_Column := 'Attribute'||l_segment;
              p_error_segment := 'Attribute16';
           Else
                p_error_segment := 'AttributeCategory';
           End If;

           return(FALSE);
       end if;

       return(TRUE);

      ELSE
        l_segment := to_char(fnd_flex_descval.error_segment) ;

        If l_segment Is not null Then
                G_DFF_Error_Column := 'Attribute'||l_segment;
                p_error_segment := 'Attribute16';
        Else
                p_error_segment := 'AttributeCategory';
        End If;

        return(FALSE);
      END IF;

  END val_desc_flex;


  /* val_transaction_desc_flex performs the exact same function as val_desc_flex
     only it does it for the transaction interface table.  Too bad these headers
     are not polymorphic.  Regardless, if you change one of these functions, please
     make sure to include equivalent changes to this procedure.
  */

  /*--------------------------------------------------------------------------------*/
  FUNCTION val_transaction_desc_flex( p_Interface_Rec    IN XTR_TRANSACTIONS_INTERFACE%ROWTYPE,
                          p_desc_flex        IN VARCHAR2,
                          p_error_segment    IN OUT NOCOPY VARCHAR2) return BOOLEAN is
  /*--------------------------------------------------------------------------------*/
  l_segment number(3);

  BEGIN

     fnd_flex_descval.set_column_value('ATTRIBUTE1',p_Interface_Rec.ATTRIBUTE1);
     fnd_flex_descval.set_column_value('ATTRIBUTE2',p_Interface_Rec.ATTRIBUTE2);
     fnd_flex_descval.set_column_value('ATTRIBUTE3',p_Interface_Rec.ATTRIBUTE3);
     fnd_flex_descval.set_column_value('ATTRIBUTE4',p_Interface_Rec.ATTRIBUTE4);
     fnd_flex_descval.set_column_value('ATTRIBUTE5',p_Interface_Rec.ATTRIBUTE5);
     fnd_flex_descval.set_column_value('ATTRIBUTE6',p_Interface_Rec.ATTRIBUTE6);
     fnd_flex_descval.set_column_value('ATTRIBUTE7',p_Interface_Rec.ATTRIBUTE7);
     fnd_flex_descval.set_column_value('ATTRIBUTE8',p_Interface_Rec.ATTRIBUTE8);
     fnd_flex_descval.set_column_value('ATTRIBUTE9',p_Interface_Rec.ATTRIBUTE9);
     fnd_flex_descval.set_column_value('ATTRIBUTE10',p_Interface_Rec.ATTRIBUTE10);
     fnd_flex_descval.set_column_value('ATTRIBUTE11',p_Interface_Rec.ATTRIBUTE11);
     fnd_flex_descval.set_column_value('ATTRIBUTE12',p_Interface_Rec.ATTRIBUTE12);
     fnd_flex_descval.set_column_value('ATTRIBUTE13',p_Interface_Rec.ATTRIBUTE13);
     fnd_flex_descval.set_column_value('ATTRIBUTE14',p_Interface_Rec.ATTRIBUTE14);
     fnd_flex_descval.set_column_value('ATTRIBUTE15',p_Interface_Rec.ATTRIBUTE15);

     fnd_flex_descval.set_context_value(p_Interface_Rec.ATTRIBUTE_CATEGORY);

     /* G_DFF_Error_Column holds the value of the first column that has an error
        this value is used by log_error to change the column that is displayed
        in the CM log.  See bug 2807931 for more details */
     G_DFF_Error_Column := '';

     IF fnd_flex_descval.validate_desccols('XTR',p_desc_flex) then
       if (fnd_flex_descval.is_valid) then
           null;
       else
           l_segment := to_char(fnd_flex_descval.error_segment) ;
           If l_segment Is not null Then
              G_DFF_Error_Column := 'Attribute'||l_segment;
              p_error_segment := 'Attribute16';
           Else
                p_error_segment := 'AttributeCategory';
           End If;
           return(FALSE);
       end if;

       if (fnd_flex_descval.value_error OR
            fnd_flex_descval.unsupported_error) then

           l_segment := to_char(fnd_flex_descval.error_segment) ;
           If l_segment Is not null Then
              G_DFF_Error_Column := 'Attribute'||l_segment;
              p_error_segment := 'Attribute16';
           Else
                p_error_segment := 'AttributeCategory';
           End If;

           return(FALSE);
       end if;

       return(TRUE);

      ELSE
        l_segment := to_char(fnd_flex_descval.error_segment) ;

        If l_segment Is not null Then
                G_DFF_Error_Column := 'Attribute'||l_segment;
                p_error_segment := 'Attribute16';
        Else
                p_error_segment := 'AttributeCategory';
        End If;

        return(FALSE);
      END IF;

  END val_transaction_desc_flex;


  /*
     Translate_Deal_Details changes information from the meaning to
     lookup code values for specific columns of the specified deal
     type.  This allows the import script to use either what is
     seen on the form, or the underlying code.  We recommend using
     the underlying code value because it is not mutable.
     If you call this from the UI, use Translate_Deal_Details_UI
     to send the translated values back into the table
  */
  /* For the CE Bank Migration Enhancement, The CPARTY account
     name / number translaction is also placed in this procedure
  */
  /*--------------------------------------------------------------*/
  Procedure Translate_Deal_Details( deal_type In Varchar2,
                                    ARec In Out NOCOPY xtr_deals_interface%rowtype) is
  /*--------------------------------------------------------------*/

       b_updated Boolean:=false;

       /*
          Translate_Column is a helper function for Translate_Deal_Details
          that takes care of the translation when given a specified column
       */
       Procedure Translate_Value(p_lookupType In Varchar2,
                                 p_value in out nocopy Varchar2
                                 ) is
           cursor translate_cursor is
             select lookup_code
             from   fnd_lookups
             where  lookup_type=p_lookupType
             and    (upper(lookup_code)=upper(p_value) or upper(meaning)=upper(p_value))
             and    rownum=1;
           v_oldValue Varchar2(80):=p_value;
       BEGIN
           open translate_cursor;
           fetch translate_cursor into p_value;
           close translate_cursor;
           if (v_oldValue<>p_value) then
             b_updated:=true;
           end if;
       END Translate_Value;

       /*
          Translate_accounts is a helper function for Translate_Deal_Details
          that takes care of the translation from account name -> number and
          vis versa.
          Because of the translation the values will be valid/invalid together
          thus validation can be performed on one or the other column as
          long as the error is placed under the modifiable field.
          This means we can leave the old validation code untouched.
       */
       Procedure Translate_Accounts(p_account_number In Out nocopy Varchar2,
                                    p_account_name In Out nocopy Varchar2
                                   ) is
	p_new_name         XTR_DEALS_INTERFACE.CPARTY_REF%TYPE;
	p_new_number       XTR_DEALS_INTERFACE.CPARTY_ACCOUNT_NO%TYPE;
	b_local_updated    BOOLEAN := FALSE;
	CURSOR translate_by_number(p_number VARCHAR2) is
		SELECT bank_short_code
		FROM xtr_bank_accounts_v
		WHERE account_number = p_number;

	CURSOR translate_by_name(p_name VARCHAR2) IS
		SELECT account_number
		FROM xtr_bank_accounts_v
		WHERE bank_short_code=p_name;

	BEGIN
		IF p_account_number IS NOT NULL THEN
			OPEN translate_by_number(p_account_number);
			FETCH translate_by_number INTO p_new_name;
			CLOSE translate_by_number;
			p_new_number:=p_account_number;
		ELSIF p_account_name IS NOT NULL THEN
			OPEN translate_by_name(p_account_name);
			FETCH translate_by_name INTO p_new_number;
			CLOSE translate_by_name;
			p_new_name:=p_account_name;
		END IF;
		IF p_new_number IS NOT NULL AND (p_new_number<>p_account_number OR p_account_number IS NULL) THEN
			b_local_updated:=TRUE;
		ELSIF p_new_name IS NOT NULL AND (p_new_name<>p_account_name OR p_account_name IS NULL) THEN
			b_local_updated:=TRUE;
		END IF;
		IF (b_local_updated) THEN
			p_account_number := p_new_number;
			p_account_name := p_new_name;
			b_updated := TRUE;
		END IF;
	END;

  BEGIN
    if (deal_type='FX') then
      Translate_Value('XTR_DEAL_PRICE_MODELS',    ARec.PRICING_MODEL);
      Translate_Accounts(ARec.CPARTY_ACCOUNT_NO,  ARec.CPARTY_REF);
    elsif (deal_type='IG') then
      Translate_Value('XTR_DAY_COUNT_TYPE',       ARec.DAY_COUNT_TYPE);
      Translate_Value('XTR_ROUNDING_TYPE',        ARec.ROUNDING_TYPE);
      Translate_Value('XTR_DEAL_PRICE_MODELS',    ARec.PRICING_MODEL);
      Translate_Value('XTR_DEAL_PRICE_MODELS',    ARec.MIRROR_PRICING_MODEL);
    elsif (deal_type='NI') then
      Translate_Value('XTR_DEAL_PRICE_MODELS',    ARec.PRICING_MODEL);
      Translate_Value('XTR_PRINCIPAL_SETTLED_BY', ARec.SETTLE_ACTION_REQD);
      Translate_Value('XTR_DISCOUNT_YIELD',       ARec.BASIS_TYPE);
      Translate_Value('XTR_DAY_COUNT_BASIS',      ARec.YEAR_CALC_TYPE);
      Translate_Value('XTR_DAY_COUNT_TYPE',       ARec.DAY_COUNT_TYPE);
      Translate_Value('XTR_ROUNDING_TYPE',        ARec.ROUNDING_TYPE);
      Translate_Accounts(ARec.CPARTY_ACCOUNT_NO,  ARec.CPARTY_REF);
    elsif (deal_type='EXP') then
      Translate_Accounts(ARec.CPARTY_ACCOUNT_NO,  ARec.ACCOUNT_NO_B);
    end if;


    if (b_updated) then
      update xtr_deals_interface
      set    PRICING_MODEL        = ARec.PRICING_MODEL,
             MIRROR_PRICING_MODEL = ARec.MIRROR_PRICING_MODEL,
             SETTLE_ACTION_REQD   = ARec.SETTLE_ACTION_REQD,
             BASIS_TYPE           = ARec.BASIS_TYPE,
             YEAR_CALC_TYPE       = ARec.YEAR_CALC_TYPE,
             DAY_COUNT_TYPE       = ARec.DAY_COUNT_TYPE,
             ROUNDING_TYPE        = ARec.ROUNDING_TYPE,
             CPARTY_ACCOUNT_NO    = ARec.CPARTY_ACCOUNT_NO,
             CPARTY_REF            = ARec.CPARTY_REF,
             ACCOUNT_NO_B         = ARec.ACCOUNT_NO_B
      where  external_deal_id     = ARec.EXTERNAL_DEAL_ID
      and    deal_type            = ARec.DEAL_TYPE;
    end if;

  END Translate_Deal_Details;

  /*
     This is the call to be made from the UI, pass in the external_deal_id
     and user_deal_type and this call will then call Translate_Deal_Details
  */
  /*--------------------------------------------------------------*/
  Procedure Translate_Deal_Details_UI(p_external_deal_id xtr_deals_interface.external_deal_id%type,
                                      p_user_deal_type   xtr_deals_interface.deal_type%type) is
  /*--------------------------------------------------------------*/

    l_deal_type xtr_deals_interface.external_deal_id%type:=null;
    ARec xtr_deals_interface%rowtype;

    cursor getDeal is
      select *
      from   xtr_deals_interface
      where  external_deal_id = p_external_deal_id
      and    deal_type=p_user_deal_type;
    Cursor getDealType Is
      Select Deal_Type
      From   Xtr_Deal_Types_V
      Where  User_Deal_Type = p_user_deal_type;
  BEGIN
    open getDeal;
    fetch getDeal into ARec;
    if (getDeal%FOUND) then
        Open  getDealType;
        Fetch getDealType Into l_deal_type;
        Close getDealType;
        Translate_Deal_Details(l_deal_type,ARec);
    end if;
    close getDeal;


  END Translate_Deal_Details_UI;



    Procedure log_successful_deal(Deal_Type    IN VARCHAR2,
                                  Deal_Number  IN NUMBER,
                                  Deal_Subtype IN VARCHAR2,
                                  Product_Type IN VARCHAR2,
                                  Company_Code IN VARCHAR2,
                                  Cparty_Code  IN VARCHAR2,
                                  Currency     IN VARCHAR2,
                                  Amount       IN NUMBER) IS
    BEGIN
        put_log(
                lpad(nvl(Deal_Type        ,' '), 5)||','||
                lpad(nvl(Deal_Number      ,0  ),15)||','||
                lpad(nvl(Deal_Subtype     ,' '), 9)||','||
                lpad(nvl(Product_Type     ,' '), 9)||','||
                lpad(nvl(Company_Code     ,' '), 9)||','||
                lpad(nvl(Cparty_Code      ,' '), 9)||','||
                lpad(nvl(Currency         ,' '), 4)||','||
                lpad(to_char(nvl(Amount,0),fnd_currency.get_format_mask(nvl(Currency,'USD'),20)),20));
        for i in 0..g_current_deal_log_list.count-1 loop
        	put_log(g_current_deal_log_list(i));
        end loop;
        g_current_deal_log_list.delete;
    END LOG_SUCCESSFUL_DEAL;

    Procedure log_failed_deal(Deal_Type         IN VARCHAR2,
                              External_Deal_Id  IN VARCHAR2,
                              Deal_Subtype      IN VARCHAR2,
                              Product_Type      IN VARCHAR2,
                              Company_Code      IN VARCHAR2,
                              Cparty_Code       IN VARCHAR2,
                              Currency          IN VARCHAR2,
                              Amount            IN NUMBER) IS
    BEGIN
        g_failure_log_list(g_failure_log_list.count):=' ';
        g_failure_log_list(g_failure_log_list.count):=(
                lpad(nvl(Deal_Type        ,' '), 5)||','||
                lpad(nvl(External_Deal_Id ,' '),15)||','||
                lpad(nvl(Deal_Subtype     ,' '), 9)||','||
                lpad(nvl(Product_Type     ,' '), 9)||','||
                lpad(nvl(Company_Code     ,' '), 9)||','||
                lpad(nvl(Cparty_Code      ,' '), 9)||','||
                lpad(nvl(Currency         ,' '), 4)||','||
                lpad(to_char(nvl(Amount,0),fnd_currency.get_format_mask(nvl(Currency,'USD'),20)),20));
        for i in 0..g_current_deal_log_list.count-1 loop
        	g_failure_log_list(g_failure_log_list.count):=g_current_deal_log_list(i);
        end loop;
        g_current_deal_log_list.delete;
    END LOG_FAILED_DEAL;



  /*--------------------------------------------------------------*/

  /*--------------------------------------------------------------*/
  Procedure TRANSFER_DEALS( ERRBUF		Out nocopy 	Varchar2,
			    RETCODE		Out nocopy	Varchar2,
			    P_Company_Code     	In	Varchar2,
			    P_Deal_Type        	In	Varchar2,
               		    P_Ext_Deal_Id_From 	In 	Varchar2,
               		    P_Ext_Deal_Id_To   	In 	Varchar2,
               		    P_Load_Status       In     	Varchar2,
               		    P_Source           	In 	Varchar2) is
  /*--------------------------------------------------------------*/


        /*--------------------------------------------*/
        /* Call from form: select all 'SUBMIT' deals  */
        /*--------------------------------------------*/
	Cursor 	Int_Form_Deal_Cursor(bDeal_Type In Varchar2,
				     bDeal_Fr   In Varchar2,
				     bDeal_To   In Varchar2) Is
	Select 	*
	From 	Xtr_Deals_Interface
	Where  	Nvl(Load_Status_Code,'NEW') 	= 	'SUBMIT'
	Order By Deal_Type, company_code, cparty_code, currency_a, date_a, external_deal_id;


        /*----------------------------------------------------------*/
        /* Call from concurrent program: select deals from criteria */
        /*----------------------------------------------------------*/
	Cursor 	Int_Con_Deal_Cursor(bDeal_Type In Varchar2,
				    bDeal_Fr In Varchar2,
				    bDeal_To In Varchar2,
				    bCompany_Code In Varchar2,
				    bLoad_Status In Varchar) Is
	Select	*
	From 	Xtr_Deals_Interface
	Where 	External_Deal_Id Between Nvl(bDeal_Fr,External_Deal_Id)
			 	 And	 Nvl(bDeal_To,External_Deal_Id)
	And   	Company_Code   	 Like 	 Nvl(bCompany_Code,'%')
	And   	Deal_Type      	 Like 	 Nvl(bDeal_Type,'%')
	And   	Nvl(Load_Status_Code,'NEW') like  nvl(bLoad_status,'%')
	Order By Deal_Type, company_code, cparty_code, currency_a, date_a, external_deal_id;


        /*------------------------------------------------------*/
        /*  Determine if the deal type is invalid or supported. */
        /*------------------------------------------------------*/
	Cursor 	Valid_Deal_Type(B_Deal_Type In Varchar2) Is
	Select 	Deal_Type
	From	Xtr_Deal_Types_V
	Where 	User_Deal_Type = B_Deal_Type;

        /*------------------------------------------------------*/
        /*  Determine if the deal type is invalid or supported. */
        /*------------------------------------------------------*/
	Cursor 	Get_deal_name(p_deal_type In Varchar2) Is
	Select 	Name
	From	Xtr_Deal_Types_V
	Where 	Deal_Type = p_deal_type;


        /*-------------------*/
        /*  Local variables. */
        /*-------------------*/
	LRec_External_Deal    xtr_deals_interface%rowtype;
	L_Deal_Name	      xtr_deal_types_v.name%type;
	L_Deal_Type	      xtr_deal_types_v.deal_type%type;
	deal_error            BOOLEAN Default FALSE;
	user_error            BOOLEAN Default FALSE;
	duplicate_error       BOOLEAN Default FALSE;
	mandatory_error       BOOLEAN Default FALSE;
	validation_error      BOOLEAN Default FALSE;
	limit_error           BOOLEAN Default FALSE;

	p_has_warnings        BOOLEAN Default FALSE;

	p_is_first_fx         BOOLEAN Default TRUE;
	p_is_first_ig         BOOLEAN Default TRUE;
	p_is_first_exp        BOOLEAN Default TRUE;
	p_is_first_ni         BOOLEAN Default TRUE;

	p_deal_no             Number  :=  0;

	p_total_fx            Number  :=  0;
	p_success_fx          Number  :=  0;
	p_failure_fx          Number  :=  0;
	p_tot_suc_buy_amt_fx  Number  :=  0;
	p_tot_suc_sell_amt_fx Number  :=  0;
	p_tot_fai_buy_amt_fx  Number  :=  0;
	p_tot_fai_sell_amt_fx Number  :=  0;

	p_total_ig            Number  :=  0;
	p_success_ig          Number  :=  0;
	p_failure_ig          Number  :=  0;
	p_tot_suc_prin_amt_ig Number  :=  0;
	p_tot_fai_prin_amt_ig Number  :=  0;

	p_total_exp            Number  :=  0;
	p_success_exp          Number  :=  0;
	p_failure_exp          Number  :=  0;
	p_tot_suc_est_amt_exp  Number  :=  0;
	p_tot_suc_act_amt_exp Number  :=  0;
	p_tot_fai_est_amt_exp  Number  :=  0;
	p_tot_fai_act_amt_exp Number  :=  0;

	p_total_ni            Number  :=  0;
	p_success_ni          Number  :=  0;
	p_failure_ni          Number  :=  0;
	p_tot_suc_amt_ni      Number  :=  0;
	p_tot_suc_amt_ni      Number  :=  0;

	p_is_success          BOOLEAN Default FALSE;

        /*-----------------------------------------------------------------------------------*/
        /* Transfer_Deal_Protected is a wrapper that provides system critical error handling */
        /* In the event of an unforseen error, undoes the damage and allows recovery         */
        /* This allows for item level exception handling                                     */
        /*-----------------------------------------------------------------------------------*/
        Procedure Transfer_Deal_Protected
        Is
        Begin

        p_is_success:=false;
                        ----------------------------------------------------------------------------------
                        --* To purge all the related data in the error table before processing the record
                        ----------------------------------------------------------------------------------
                        delete from xtr_interface_errors
                        where  external_deal_id = LRec_External_Deal.external_deal_id
                        and    deal_type        = LRec_External_Deal.deal_type;



                        ------------------------------------------------------------------------------------
                        --* To purge all orphaned transaction data that was not deleted with the deal header
                        ------------------------------------------------------------------------------------
                        delete
			from  xtr_transactions_interface tr
			where not exists (
			      select dl.external_deal_id
			      from   xtr_deals_interface dl
			      where  dl.external_deal_id = tr.external_deal_id
			      and    dl.deal_type = tr.deal_type
			      );


			--* call the appropriate validation and transfer package
			--* based on curr_deal_type

			IF L_Deal_Type = 'FX' Then
			   p_total_fx := p_total_fx +1;
			   if (p_is_first_fx) then
			       p_is_first_fx:=false;
			       put_log(' ');
			   end if;

                           ----------------------------------------------------------------------------------------------
                           --* The following code checks for duplicate External Deal ID in the interface and deal tables
                           ----------------------------------------------------------------------------------------------
                           CHECK_DEAL_DUPLICATE_ID(LRec_External_Deal.external_deal_id,
                                                   LRec_External_Deal.deal_type,
                                                   L_Deal_Type, duplicate_error);

                           if Duplicate_Error then
			      p_failure_fx          := p_failure_fx + 1;
			      p_tot_fai_buy_amt_fx  := p_tot_fai_buy_amt_fx  + LRec_External_Deal.amount_a;
			      p_tot_fai_sell_amt_fx := p_tot_fai_sell_amt_fx + LRec_External_Deal.amount_b;
			      p_has_warnings        := true;

                           else

			      XTR_FX_TRANSFERS_PKG.TRANSFER_FX_DEALS(LRec_External_Deal,
						                     user_error,
						                     mandatory_error,
						                     validation_error,
						                     limit_error,
						                     p_deal_no);

			      if not User_Error and not Mandatory_Error And
                                 not Validation_Error and not Limit_Error then
				 p_success_fx          := p_success_fx + 1;
				 p_tot_suc_buy_amt_fx  := p_tot_suc_buy_amt_fx  + LRec_External_Deal.amount_a;
				 p_tot_suc_sell_amt_fx := p_tot_suc_sell_amt_fx + LRec_External_Deal.amount_b;
				 p_is_success          := true;
			      else
				 p_failure_fx          := p_failure_fx + 1;
				 p_tot_fai_buy_amt_fx  := p_tot_fai_buy_amt_fx  + LRec_External_Deal.amount_a;
				 p_tot_fai_sell_amt_fx := p_tot_fai_sell_amt_fx + LRec_External_Deal.amount_b;
				 p_has_warnings        := true;
			      end if;
			   end if;  /* FX Duplicate_Error */

			ELSIF L_Deal_Type = 'IG' Then
			   p_total_ig := p_total_ig +1;
			   if (p_is_first_ig) then
			       p_is_first_ig:=false;
			       put_log(' ');
			   end if;

                           ----------------------------------------------------------------------------------------------
                           --* The following code checks for duplicate External Deal ID in the interface and IG tables
                           ----------------------------------------------------------------------------------------------
                           CHECK_DEAL_DUPLICATE_ID(LRec_External_Deal.external_deal_id,
                                                   LRec_External_Deal.deal_type,
                                                   L_Deal_Type, duplicate_error);

                           if Duplicate_Error then
			      p_failure_ig          := p_failure_ig + 1;
			      p_tot_fai_prin_amt_ig := p_tot_fai_prin_amt_ig + LRec_External_Deal.amount_a;
			      p_has_warnings        := true;

                           else

			      XTR_IG_TRANSFERS_PKG.TRANSFER_IG_DEALS(LRec_External_Deal,
                                                                     null,
						                     user_error,
						                     mandatory_error,
						                     validation_error,
						                     limit_error,
						                     p_deal_no);

			      if not user_error and not mandatory_error and
                                 not validation_error and not limit_error then
				 p_success_ig          := p_success_ig + 1;
				 p_tot_suc_prin_amt_ig := p_tot_suc_prin_amt_ig + LRec_External_Deal.amount_a;
				 p_is_success          := true;
			      else
				 p_failure_ig          := p_failure_ig + 1;
				 p_tot_fai_prin_amt_ig := p_tot_fai_prin_amt_ig + LRec_External_Deal.amount_a;
				 p_has_warnings        := true;
			      end if;
			   end if;  /* IG Duplicate_Error */

			ELSIF L_Deal_Type = 'EXP' Then
			   p_total_exp := p_total_exp +1;
			   if (p_is_first_exp) then
			       p_is_first_exp:=false;
			       put_log(' ');
			   end if;

                        ----------------------------------------------------
                        --* The following code checks for duplicate External
			--* Deal ID in the interface and IG tables
                        ----------------------------------------------------
                           CHECK_DEAL_DUPLICATE_ID(
				LRec_External_Deal.external_deal_id,
                                LRec_External_Deal.deal_type,
                                L_Deal_Type, duplicate_error);

                           if Duplicate_Error then
			      p_failure_exp          := p_failure_exp + 1;
			      p_tot_fai_est_amt_exp := p_tot_fai_est_amt_exp+
						LRec_External_Deal.amount_a;
			      p_tot_fai_act_amt_exp := p_tot_fai_act_amt_exp+
						LRec_External_Deal.amount_a;
						p_has_warnings        := true;
                           else
			      XTR_EXP_TRANSFERS_PKG.TRANSFER_EXP_DEALS(
							LRec_External_Deal,
                                                        null,
						        user_error,
						        mandatory_error,
						        validation_error,
						        limit_error,
						        p_deal_no);

			      if not user_error and not mandatory_error and
                                 not validation_error and not limit_error then
				 p_success_exp          := p_success_exp + 1;
				 p_tot_suc_est_amt_exp:=p_tot_suc_est_amt_exp
						 + LRec_External_Deal.amount_a;
				 p_tot_suc_act_amt_exp:=p_tot_suc_act_amt_exp
						 + LRec_External_Deal.amount_a;
				 p_is_success          := true;
			      else
				 p_failure_exp          := p_failure_exp + 1;
				 p_has_warnings        := true;
				 p_tot_fai_est_amt_exp:=p_tot_fai_est_amt_exp
						+ LRec_External_Deal.amount_a;
				 p_tot_fai_act_amt_exp:=p_tot_fai_act_amt_exp
						 + LRec_External_Deal.amount_a;
			      end if;
			   end if;  /* EXP Duplicate_Error */

			ELSIF L_Deal_Type = 'NI' Then
			   p_total_ni := p_total_ni +1;
			   if (p_is_first_ni) then
			       p_is_first_ni:=false;
			       put_log(' ');
			   end if;

                           ----------------------------------------------------------------------------------------------
                           --* The following code checks for duplicate External Deal ID in the interface and deal tables
                           ----------------------------------------------------------------------------------------------
                           CHECK_DEAL_DUPLICATE_ID(LRec_External_Deal.external_deal_id,
                                                   LRec_External_Deal.deal_type,
                                                   L_Deal_Type, duplicate_error);

                           if Duplicate_Error then
			      p_failure_ni          := p_failure_ni + 1;
			      p_has_warnings        := true;
			      --WDK: How do we mark failed amount?  Don't know without looking into transaction details
                              --p_tot_fai_amt_ni      := p_tot_fai_amt_ni + LRec_External_Deal.amount_a;

                           else

			      XTR_NI_TRANSFERS_PKG.TRANSFER_NI_DEALS(LRec_External_Deal,
						                     user_error,
						                     mandatory_error,
						                     validation_error,
						                     limit_error,
						                     p_deal_no);

			      if not User_Error and not Mandatory_Error And
                                 not Validation_Error and not Limit_Error then
				 p_success_ni          := p_success_ni + 1;
				 p_is_success          := true;
                                 --WDK: Can we use amount_a to store accumulation?
                                 --p_tot_suc_amt_ni      := p_suc_suc_amt_ni + LRec_External_Deal.amount_a;
			      else
				 p_failure_ni          := p_failure_ni + 1;
				 p_has_warnings        := true;
                                 --WDK: Can we use amount_a to store accumulation?
                                 --Stop short of transaction total on failure?
                                 --p_tot_fai_amt_ni      := p_suc_fai_amt_ni + LRec_External_Deal.amount_a;
			      end if;
			   end if;  /* NI Duplicate_Error */

			ELSE
                              -------------------------------------------------------------
			      --* update as the same error for unsupported deal types also
                              -------------------------------------------------------------
			      UPDATE xtr_deals_interface
			      set    load_status_code = 'DEAL_TYPE_ERROR',
                                     last_update_date = trunc(SYSDATE),
                                     Last_Updated_by  = fnd_global.user_id
			      where  external_deal_id = LRec_External_Deal.external_deal_id
			      and    deal_type        = LRec_External_Deal.deal_type;

			      p_has_warnings:=true;

			      Log_Interface_Errors(LRec_External_Deal.external_deal_id,
			                           LRec_External_Deal.deal_type,
			                           Null,
			                           'XTR_INV_DEAL_TYPE');


  			END IF;

  			if (p_has_warnings) then
  			    g_has_warnings:=true;
  			end if;

  			if (p_is_success) then
            log_successful_deal(LRec_External_Deal.Deal_Type,
                                p_deal_no,
                                LRec_External_Deal.Deal_Subtype,
                                LRec_External_Deal.Product_Type,
                                LRec_External_Deal.Company_Code,
                                LRec_External_Deal.Cparty_Code,
                                LRec_External_Deal.Currency_A,
                                LRec_External_Deal.Amount_A);
  			else
            log_failed_deal(LRec_External_Deal.Deal_Type,
                            LRec_External_Deal.External_Deal_Id,
                            LRec_External_Deal.Deal_Subtype,
                            LRec_External_Deal.Product_Type,
                            LRec_External_Deal.Company_Code,
                            LRec_External_Deal.Cparty_Code,
                            LRec_External_Deal.Currency_A,
                            LRec_External_Deal.Amount_A);
        end if;

        Exception
                When Others Then
                        UPDATE Xtr_Deals_Interface
                        SET Load_Status_Code='ERROR'
                        WHERE External_Deal_Id=LRec_External_Deal.External_Deal_Id;

                        p_has_warnings:=true;
                        g_has_warnings:=true;

                        Log_Interface_Errors(LRec_External_Deal.external_deal_id,
												                     LRec_External_Deal.deal_type,
												                     Null,
												                     'XTR_IMPORT_UNEXPECTED_ERROR');

		      if l_deal_type='FX' then
			  p_failure_fx          := p_failure_fx + 1;
			  p_tot_fai_buy_amt_fx  := p_tot_fai_buy_amt_fx  + LRec_External_Deal.amount_a;
			  p_tot_fai_sell_amt_fx := p_tot_fai_sell_amt_fx + LRec_External_Deal.amount_b;
		      elsif l_deal_type='EXP' then
			  p_failure_exp         := p_failure_exp + 1;
			  p_tot_fai_est_amt_exp := p_tot_fai_est_amt_exp + LRec_External_Deal.amount_a;
			  p_tot_fai_act_amt_exp := p_tot_fai_act_amt_exp + LRec_External_Deal.amount_a;
		      elsif l_deal_type='IG' then
			  p_failure_ig          := p_failure_ig + 1;
			  p_tot_fai_prin_amt_ig := p_tot_fai_prin_amt_ig + LRec_External_Deal.amount_a;
		      elsif l_deal_type='NI' then
			  p_failure_ni          := p_failure_ni + 1;
		      end if;


                log_failed_deal(LRec_External_Deal.Deal_Type,
                                LRec_External_Deal.External_Deal_Id,
                                LRec_External_Deal.Deal_Subtype,
                                LRec_External_Deal.Product_Type,
                                LRec_External_Deal.Company_Code,
                                LRec_External_Deal.Cparty_Code,
                                LRec_External_Deal.Currency_A,
                                LRec_External_Deal.Amount_A);


        End;



  Begin
     xtr_risk_debug_pkg.start_conc_prog;

        /*-------------------------------------------------------------------------*/
	/* Setting the user id which will be used in the CHECK_USER_AUTH procedure */
        /*-------------------------------------------------------------------------*/
	IF P_Source = 'FORM' Then
	   Open  Int_Form_Deal_Cursor (P_Deal_Type, P_Ext_Deal_Id_From, P_Ext_Deal_Id_To);
	   Fetch Int_Form_Deal_Cursor Into LRec_External_Deal;
	ELSE
	   Open  Int_Con_Deal_Cursor (P_Deal_Type, P_Ext_Deal_Id_From, P_Ext_Deal_Id_To, P_Company_Code, P_Load_Status);
	   Fetch Int_Con_Deal_Cursor Into LRec_External_Deal;
	END IF;

	put_log(fnd_message.get_string('XTR','XTR_SUCCESSFUL_IMPORT'));
	put_log(lpad('-',79,'-'));
	put_log(fnd_message.get_string('XTR','XTR_IMPORT_HEADER'));

	g_current_deal_log_list.delete;
	g_failure_log_list.delete;

        -----------------------------------
	--* Loop through all the records
        -----------------------------------
	LOOP

	        deal_error            := FALSE;
	        user_error            := FALSE;
	        duplicate_error       := FALSE;
	        mandatory_error       := FALSE;
	        validation_error      := FALSE;
	        limit_error           := FALSE;

		IF P_Source = 'FORM' Then
			Exit When Int_Form_Deal_Cursor%NotFound;
		ELSE
			Exit When Int_Con_Deal_Cursor%NotFound;
		END IF;

		--* Validate deal type
		--* Need Not do this as the cursor itself is picked on this
		--* Condition Only. So only valid records would be fetched in the
		--* Cursor for Importing.
		--* But need to do this validation when the cursor is fetched for all deal types

                L_Deal_Type := null;

		Open  Valid_Deal_Type(LRec_External_Deal.Deal_Type);
		Fetch Valid_Deal_Type Into L_Deal_Type;
		Close Valid_Deal_Type;


		IF L_Deal_Type is null then

		      UPDATE xtr_deals_interface
		      set    load_status_code = 'DEAL_TYPE_ERROR',
                             last_update_date = trunc(SYSDATE),
                             Last_Updated_by  = fnd_global.user_id
		      where  external_deal_id = LRec_External_Deal.external_deal_id
		      and    deal_type        = LRec_External_Deal.deal_type;

		      g_has_warnings:=true;
		      Log_Interface_Errors(LRec_External_Deal.external_deal_id,
					   LRec_External_Deal.deal_type,
					   Null,
					   'XTR_INV_DEAL_TYPE');

		    log_failed_deal(LRec_External_Deal.Deal_Type,
				    LRec_External_Deal.External_Deal_Id,
				    LRec_External_Deal.Deal_Subtype,
				    LRec_External_Deal.Product_Type,
				    LRec_External_Deal.Company_Code,
				    LRec_External_Deal.Cparty_Code,
				    LRec_External_Deal.Currency_A,
				    LRec_External_Deal.Amount_A);



		ELSE

                        Translate_Deal_Details(L_Deal_Type,LRec_External_Deal);

                        -- The following is an exception handling wrapper
                        Transfer_Deal_Protected;




		END IF;

		IF P_Source = 'FORM' Then
			Fetch Int_Form_Deal_Cursor Into	LRec_External_Deal;
		ELSE
			Fetch Int_Con_Deal_Cursor Into 	LRec_External_Deal;
		END IF;


	END LOOP;

	put_log(' ');
	put_log(fnd_message.get_string('XTR','XTR_FAILED_IMPORT'));
	put_log(lpad('-',79,'-'));
	put_log(fnd_message.get_string('XTR','XTR_IMPORT_FAIL_HEADER'));
	for i in 0..g_failure_log_list.count-1 loop
		put_log(g_failure_log_list(i));
	end loop;


       /* ------------------------------------------------
          Sample log file for FX
          ------------------------------------------------
          Foreign Exchange
          --------------------
          Total number of deals: 50

          Total number of successful transfers: 48
               Control total buy amount is  123456.78
               Control total sell amount is 25252.52

          Total number of unsuccessful transfers: 2
               Control total buy amount is  1001.01
               Control total sell amount is 505.50

       */ ------------------------------------------------
	IF p_total_fx <> 0 then

           Open  Get_deal_name('FX');
           Fetch Get_deal_name Into L_Deal_Name;
           Close Get_deal_name;

	   put_log(' ');

	   put_log(L_Deal_Name);
           put_log(rpad('-',length(L_Deal_Name),'-'));

	   Fnd_Message.Set_Name('XTR','XTR_TOT_DEALS');
	   Fnd_Message.Set_Token('VALUE',p_total_fx);
	   put_log(Fnd_Message.Get);
	   Fnd_Message.Clear;

	   put_log(' ');

	   Fnd_Message.Set_Name('XTR','XTR_TOT_SUCCESS_DEALS');
	   Fnd_Message.Set_Token('VALUE',p_success_fx);
	   put_log(Fnd_Message.Get);
	   Fnd_Message.Clear;

	   Fnd_Message.Set_Name('XTR','XTR_FX_CTRL_TOTAL_BUY');
	   Fnd_Message.Set_Token('VALUE',p_tot_suc_buy_amt_fx);
	   put_log(Fnd_Message.Get);
	   Fnd_Message.Clear;

	   Fnd_Message.Set_Name('XTR','XTR_FX_CTRL_TOTAL_SELL');
	   Fnd_Message.Set_Token('VALUE',p_tot_suc_sell_amt_fx);
	   put_log(Fnd_Message.Get);
	   Fnd_Message.Clear;

	   put_log(' ');

	   Fnd_Message.Set_Name('XTR','XTR_TOT_UNSUCCESS_DEALS');
	   Fnd_Message.Set_Token('VALUE',p_failure_fx);
	   put_log(Fnd_Message.Get);
	   Fnd_Message.Clear;

	   Fnd_Message.Set_Name('XTR','XTR_FX_CTRL_TOTAL_BUY');
	   Fnd_Message.Set_Token('VALUE',p_tot_fai_buy_amt_fx);
	   put_log(Fnd_Message.Get);
	   Fnd_Message.Clear;

	   Fnd_Message.Set_Name('XTR','XTR_FX_CTRL_TOTAL_SELL');
	   Fnd_Message.Set_Token('VALUE',p_tot_fai_sell_amt_fx);
	   put_log(Fnd_Message.Get);
	   Fnd_Message.Clear;

	END IF;

       /* ------------------------------------------------
          Sample log file for IG
          ------------------------------------------------
          Intergroup Transfers
          --------------------
          Total number of deals: 50

          Total number of successful transfers: 48
               Control total principal adjustment amount is  123456.78

          Total number of unsuccessful transfers: 2
               Control total principal adjustment amount is  1001.01

       */ ------------------------------------------------
	IF p_total_ig <> 0 then

           Open  Get_deal_name('IG');
           Fetch Get_deal_name Into L_Deal_Name;
           Close Get_deal_name;

	   put_log(' ');

	   put_log(L_Deal_Name);
           put_log(rpad('-',length(L_Deal_Name),'-'));

	   Fnd_Message.Set_Name('XTR','XTR_TOT_DEALS');
	   Fnd_Message.Set_Token('VALUE',p_total_ig);
	   put_log(Fnd_Message.Get);
	   Fnd_Message.Clear;

	   put_log(' ');

	   Fnd_Message.Set_Name('XTR','XTR_TOT_SUCCESS_DEALS');
	   Fnd_Message.Set_Token('VALUE',p_success_ig);
	   put_log(Fnd_Message.Get);
	   Fnd_Message.Clear;

	   Fnd_Message.Set_Name('XTR','XTR_IG_CTRL_TOTAL');
	   Fnd_Message.Set_Token('VALUE',p_tot_suc_prin_amt_ig);
	   put_log(Fnd_Message.Get);
	   Fnd_Message.Clear;

	   put_log(' ');

	   Fnd_Message.Set_Name('XTR','XTR_TOT_UNSUCCESS_DEALS');
	   Fnd_Message.Set_Token('VALUE',p_failure_ig);
	   put_log(Fnd_Message.Get);
	   Fnd_Message.Clear;

	   Fnd_Message.Set_Name('XTR','XTR_IG_CTRL_TOTAL');
	   Fnd_Message.Set_Token('VALUE',p_tot_fai_prin_amt_ig);
	   put_log(Fnd_Message.Get);
	   Fnd_Message.Clear;


	END IF;

       /* ------------------------------------------------
          Sample log file for EXP
          ------------------------------------------------
          Exposure Transactions
          ---------------------
          Total number of deals: 50

          Total number of successful transfers: 48
               Control total estimate amount is  123456.78
               Control total actual amount is 25252.52

          Total number of unsuccessful transfers: 2
               Control total estimate amount is  1001.01
               Control total actual amount is 505.50

       */ ------------------------------------------------
	IF p_total_exp <> 0 then

           Open  Get_deal_name('EXP');
           Fetch Get_deal_name Into L_Deal_Name;
           Close Get_deal_name;

	   put_log(' ');

	   put_log(L_Deal_Name);
           put_log(rpad('-',length(L_Deal_Name),'-'));

	   Fnd_Message.Set_Name('XTR','XTR_TOT_DEALS');
	   Fnd_Message.Set_Token('VALUE',p_total_exp);
	   put_log(Fnd_Message.Get);
	   Fnd_Message.Clear;

	   put_log(' ');

	   Fnd_Message.Set_Name('XTR','XTR_TOT_SUCCESS_DEALS');
	   Fnd_Message.Set_Token('VALUE',p_success_exp);
	   put_log(Fnd_Message.Get);
	   Fnd_Message.Clear;

	   Fnd_Message.Set_Name('XTR','XTR_EXP_CTRL_TOTAL_EST');
	   Fnd_Message.Set_Token('VALUE',p_tot_suc_est_amt_exp);
	   put_log(Fnd_Message.Get);
	   Fnd_Message.Clear;

	   Fnd_Message.Set_Name('XTR','XTR_EXP_CTRL_TOTAL_ACT');
	   Fnd_Message.Set_Token('VALUE',p_tot_suc_act_amt_exp);
	   put_log(Fnd_Message.Get);
	   Fnd_Message.Clear;

	   put_log(' ');

	   Fnd_Message.Set_Name('XTR','XTR_TOT_UNSUCCESS_DEALS');
	   Fnd_Message.Set_Token('VALUE',p_failure_exp);
	   put_log(Fnd_Message.Get);
	   Fnd_Message.Clear;

	   Fnd_Message.Set_Name('XTR','XTR_EXP_CTRL_TOTAL_EST');
	   Fnd_Message.Set_Token('VALUE',p_tot_fai_est_amt_exp);
	   put_log(Fnd_Message.Get);
	   Fnd_Message.Clear;

	   Fnd_Message.Set_Name('XTR','XTR_EXP_CTRL_TOTAL_ACT');
	   Fnd_Message.Set_Token('VALUE',p_tot_fai_act_amt_exp);
	   put_log(Fnd_Message.Get);
	   Fnd_Message.Clear;

        END IF;

       /* ------------------------------------------------
          Sample log file for NI
          ------------------------------------------------
          Intergroup Transfers
          --------------------
          Total number of deals: 50

          Total number of successful transfers: 48
               --WDK: what could we display?
               --Control total principal adjustment amount is  123456.78

          Total number of unsuccessful transfers: 2
               --WDK: is there a simple answer?
               --Control total principal adjustment amount is  1001.01

       */ ------------------------------------------------
	IF p_total_ni <> 0 then

           Open  Get_deal_name('NI');
           Fetch Get_deal_name Into L_Deal_Name;
           Close Get_deal_name;

	   put_log(' ');

	   put_log(L_Deal_Name);
           put_log(rpad('-',length(L_Deal_Name),'-'));

	   Fnd_Message.Set_Name('XTR','XTR_TOT_DEALS');
	   Fnd_Message.Set_Token('VALUE',p_total_ni);
	   put_log(Fnd_Message.Get);
	   Fnd_Message.Clear;

	   put_log(' ');

	   Fnd_Message.Set_Name('XTR','XTR_TOT_SUCCESS_DEALS');
	   Fnd_Message.Set_Token('VALUE',p_success_ni);
	   put_log(Fnd_Message.Get);
	   Fnd_Message.Clear;

           /* WDK: TBD
	   Fnd_Message.Set_Name('XTR','XTR_NI_CTRL_TOTAL');
	   Fnd_Message.Set_Token('VALUE',p_tot_suc_amt_ni
	   put_log(Fnd_Message.Get);
	   Fnd_Message.Clear;
           */

	   put_log(' ');

	   Fnd_Message.Set_Name('XTR','XTR_TOT_UNSUCCESS_DEALS');
	   Fnd_Message.Set_Token('VALUE',p_failure_ni);
	   put_log(Fnd_Message.Get);
	   Fnd_Message.Clear;

           /* WDK: TBD
	   Fnd_Message.Set_Name('XTR','XTR_IG_CTRL_TOTAL');
	   Fnd_Message.Set_Token('VALUE',p_tot_fai_prin_amt_ig);
	   put_log(Fnd_Message.Get);
	   Fnd_Message.Clear;
           */


	END IF;

	IF (P_Source = 'FORM') Then
		Close Int_Form_Deal_Cursor;
	ELSE
		Close Int_Con_Deal_Cursor;
	END IF;

        IF (G_has_warnings) then
           retcode:=1; --completed with warnings
        END IF;

     xtr_risk_debug_pkg.stop_conc_debug;
end TRANSFER_DEALS;

END  Xtr_Import_Deal_Data;

/
