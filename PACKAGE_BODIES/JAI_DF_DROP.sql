--------------------------------------------------------
--  DDL for Package Body JAI_DF_DROP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_DF_DROP" AS
/* $Header: jai_df_drop.plb 120.0 2006/10/06 15:40:04 rallamse noship $ */

procedure remove_context ( errbuf OUT NOCOPY VARCHAR2     ,
                           retcode OUT NOCOPY VARCHAR2
                         ) as

   lv_appl_short_name    varchar2(10);
   lv_flexfield_name     varchar2(30);

   ln_application_id     number;
   lv_value_set_name      fnd_flex_value_sets.flex_value_set_name%type;

   cursor cur_segment(cpn_application_id number, cpv_flex_name varchar2,  cpv_context varchar2) is
     select
       end_user_column_name,
       flex_value_set_id
     from fnd_descr_flex_column_usages cu
     where cu.descriptive_flexfield_name    = cpv_flex_name
     and   cu.descriptive_flex_context_code = cpv_context
     and   application_id                   = cpn_application_id;

   cursor cur_value_set(cpn_value_set_id number) is
     select flex_value_set_name
     from   fnd_flex_value_sets
     where  flex_value_set_id = cpn_value_set_id;

   cursor cur_appl_id(cpv_app_short_name varchar2) is
     select application_id
       from fnd_application
     where application_short_name = cpv_app_short_name;

  /* Added cpn_application_id parameter for bug 4924146 */
  cursor c_get_dff_details (cpn_application_id number, p_segment_name varchar2) is
    select  descriptive_flex_context_code,
            application_column_name,
            flex_value_set_id
    from    fnd_descr_flex_column_usages
    where   application_id = cpn_application_id
    and      descriptive_flexfield_name = 'AP_INVOICES'
    and      end_user_column_name =  p_segment_name;

  lv_context                      fnd_descr_flex_column_usages.descriptive_flex_context_code%type;
  lv_attribute_vat_invoice        fnd_descr_flex_column_usages.application_column_name%type;
  lv_attribute_vat_date           fnd_descr_flex_column_usages.application_column_name%type;
  lv_attribute_vat_receipt_date   fnd_descr_flex_column_usages.application_column_name%type;
  lv_sql_string                   varchar2(2000);
  ln_value_set_inv_id             number;
  ln_value_set_date_id            number;
  ln_value_set_rdate_id           number;
  lv_value_set_inv_name           fnd_flex_value_sets.flex_value_set_name%type;
  lv_value_set_date_name          fnd_flex_value_sets.flex_value_set_name%type;
  lv_value_set_rdate_name         fnd_flex_value_sets.flex_value_set_name%type;
  lv_flag													VARCHAR2(1);

    --Function added by Sanjikum, Bug#5443693
    FUNCTION check_before_delete_dff(pv_flexfield_name	VARCHAR2,
    																 pv_context					VARCHAR2)
    RETURN VARCHAR2
    IS
    	CURSOR c_flex
    	IS
    	SELECT	application_table_name,
    					context_column_name
			FROM 		fnd_descriptive_flexs
			WHERE 	descriptive_flexfield_name = pv_flexfield_name;

			r_flex 	c_flex%ROWTYPE;
			lv_sql	VARCHAR2(2000);
			lv_flag	VARCHAR2(1);

    BEGIN
      OPEN c_flex;
      FETCH c_flex INTO r_flex;
      CLOSE c_flex;

      lv_sql := 'SELECT /*+ parallel(e) */ ''1'' from '||r_flex.application_table_name||'e WHERE '||r_flex.context_column_name||' = :a AND rownum < 2' ;

      BEGIN
      	EXECUTE IMMEDIATE lv_sql INTO lv_flag USING pv_context;
      EXCEPTION
      	WHEN NO_DATA_FOUND THEN
      		lv_flag := '0';
      END;

      RETURN NVL(lv_flag,'0');

    EXCEPTION
    	WHEN OTHERS THEN
    		RETURN '1';
    END check_before_delete_dff;

    procedure delete_context is
    	lv_flag	VARCHAR2(1);
    begin
    	--Start of addition by Sanjikum, Bug#5443693
    	lv_flag := check_before_delete_dff(pv_flexfield_name	=> lv_flexfield_name,
    																		 pv_context				  => lv_context);
      IF lv_flag = '1' THEN
      	RETURN;
      END IF;
      --End of addition by Sanjikum, Bug#5443693


      /* Delete ValueSets */
      for rec_segment in cur_segment(ln_application_id, lv_flexfield_name, lv_context) loop

        fnd_flex_dsc_api.delete_segment
        (
          appl_short_name  => lv_appl_short_name,
          flexfield_name   => lv_flexfield_name ,
          context          => lv_context ,
          segment          => rec_segment.end_user_column_name
        );

        if rec_segment.flex_value_set_id is not null then

          open cur_value_set(rec_segment.flex_value_set_id);
          fetch cur_value_set into lv_value_set_name;
          close cur_value_set;

          fnd_flex_val_api.delete_valueset(lv_value_set_name);
        end if;

      end loop;

      /* Delete Context */
      fnd_flex_dsc_api.delete_context (
       appl_short_name   => lv_appl_short_name ,
       flexfield_name    => lv_flexfield_name  ,
       context           => lv_context
      );

    end delete_context;

BEGIN

  retcode := 0 ; /* rallamse setting retcode = 0 */

  /* DFF # 1 : FA_ADDITIONS DFF */
  begin
    lv_appl_short_name  := 'OFA';
    lv_flexfield_name   := 'FA_ADDITIONS';
    lv_context          := 'India B Of Assets';
    ln_application_id   := null;

    open cur_appl_id(lv_appl_short_name);
    fetch cur_appl_id into ln_application_id;
    close cur_appl_id;

    delete_context;
  EXCEPTION
    WHEN OTHERS THEN
      null;
  end;

  commit;

  /* DFF # 2 :  FA_MASS_ADDITIONS DFF */
  begin
    lv_appl_short_name  := 'OFA';
    lv_flexfield_name   := 'FA_MASS_ADDITIONS';
    lv_context          := 'India B Of Assets';
    ln_application_id   := null;

    open cur_appl_id(lv_appl_short_name);
    fetch cur_appl_id into ln_application_id;
    close cur_appl_id;

    delete_context;
  exception
    when others then
      null;
  end;

  /* DFF # 3 :  MTL_MATERIAL_TRANSACTIONS DFF */
  begin
    lv_appl_short_name    := 'INV';
    lv_flexfield_name     := 'MTL_MATERIAL_TRANSACTIONS';
    lv_context            := 'India Other Transaction';
    ln_application_id   := null;

    open cur_appl_id(lv_appl_short_name);
    fetch cur_appl_id into ln_application_id;
    close cur_appl_id;

    delete_context;
  exception
    when others then
      null;
  end;

  /* DFF # 4 :  RCV_SHIPMENT_HEADERS - India Receipt DFF */
  begin
    lv_appl_short_name    := 'PO';
    lv_flexfield_name     := 'RCV_SHIPMENT_HEADERS';
    lv_context            := 'India Receipt';
    ln_application_id   := null;

    open cur_appl_id(lv_appl_short_name);
    fetch cur_appl_id into ln_application_id;
    close cur_appl_id;

    delete_context;
  exception
    when others then
      null;
  end;

  /* DFF # 5 : AP_INVOICES - India Original Invoice for TDS DFF */
  begin
    lv_appl_short_name    := 'SQLAP';
    lv_flexfield_name     := 'AP_INVOICES';
    lv_context            := 'India Original Invoice for TDS';
    ln_application_id   := null;

    open cur_appl_id(lv_appl_short_name);
    fetch cur_appl_id into ln_application_id;
    close cur_appl_id;

    delete_context;
  exception
    when others then
      null;
  end;

  /* DFF # 6 : AP_INVOICE_DISTRIBUTIONS - India Distributions DFF */
  begin
    lv_appl_short_name    := 'SQLAP';
    lv_flexfield_name     := 'AP_INVOICE_DISTRIBUTIONS';
    lv_context            := 'India Distributions';
    ln_application_id   := null;

    open cur_appl_id(lv_appl_short_name);
    fetch cur_appl_id into ln_application_id;
    close cur_appl_id;

    delete_context;
  exception
    when others then
      null;
  end;

  /* DFF # 7 : AP_CHECKS - India Payment Information */
  begin
    lv_appl_short_name    := 'SQLAP';
    lv_flexfield_name     := 'AP_CHECKS';
    lv_context            := 'India Payment Information';
    ln_application_id   := null;

    open cur_appl_id(lv_appl_short_name);
    fetch cur_appl_id into ln_application_id;
    close cur_appl_id;

    delete_context;
  exception
    when others then
      null;
  end;


  /* DFF # 8 : PER_ORGANIZATION_UNITS - India Org Info */
  begin
    lv_appl_short_name    := 'PER';
    lv_flexfield_name     := 'PER_ORGANIZATION_UNITS';
    lv_context            := 'India Org Info';
    ln_application_id   := null;

    open cur_appl_id(lv_appl_short_name);
    fetch cur_appl_id into ln_application_id;
    close cur_appl_id;

    delete_context;
  exception
    when others then
      null;
  end;

/* DFF # 9 : MTL_SYSTEM_ITEMS - India Items */
  begin
    lv_appl_short_name    := 'INV';
    lv_flexfield_name     := 'MTL_SYSTEM_ITEMS';
    lv_context            := 'India Items';
    ln_application_id   := null;

    open cur_appl_id(lv_appl_short_name);
    fetch cur_appl_id into ln_application_id;
    close cur_appl_id;

    delete_context;
  exception
    when others then
      null;
  end;

/* DFF # 10 : RCV_TRANSACTIONS - India Return to Vendor */
  begin
    lv_appl_short_name    := 'PO';
    lv_flexfield_name     := 'RCV_TRANSACTIONS';
    lv_context            := 'India Return to Vendor';
    ln_application_id   := null;

    open cur_appl_id(lv_appl_short_name);
    fetch cur_appl_id into ln_application_id;
    close cur_appl_id;

    delete_context;
  exception
    when others then
      null;
  end;

/* DFF # 11 : RCV_TRANSACTIONS - India RMA Receipt */
  begin
    lv_appl_short_name    := 'PO';
    lv_flexfield_name     := 'RCV_TRANSACTIONS';
    lv_context            := 'India RMA Receipt';
    ln_application_id   := null;

    open cur_appl_id(lv_appl_short_name);
    fetch cur_appl_id into ln_application_id;
    close cur_appl_id;

    delete_context;
  exception
    when others then
      null;
  end;

/* DFF # 12 : RCV_TRANSACTIONS - India Return to Vendor */
  begin
    lv_appl_short_name    := 'PO';
    lv_flexfield_name     := 'RCV_TRANSACTIONS';
    lv_context            := 'India Receipt';
    ln_application_id   := null;

    open cur_appl_id(lv_appl_short_name);
    fetch cur_appl_id into ln_application_id;
    close cur_appl_id;

    delete_context;
  exception
    when others then
      null;
  end;

 /* DFF # 13 :  RCV_SHIPMENT_HEADERS - India RMA Receipt DFF */
  begin
    lv_appl_short_name    := 'PO';
    lv_flexfield_name     := 'RCV_SHIPMENT_HEADERS';
    lv_context            := 'India RMA Receipt';
    ln_application_id   := null;

    open cur_appl_id(lv_appl_short_name);
    fetch cur_appl_id into ln_application_id;
    close cur_appl_id;

    delete_context;
  exception
    when others then
      null;
  end;

 /* DFF # 14 :  FND_COMMON_LOOKUPS - India Lookup Codes */
  begin
    lv_appl_short_name    := 'FND';
    lv_flexfield_name     := 'FND_COMMON_LOOKUPS';
    lv_context            := 'India Lookup Codes';
    ln_application_id   := null;

    open cur_appl_id(lv_appl_short_name);
    fetch cur_appl_id into ln_application_id;
    close cur_appl_id;

    delete_context;
  exception
    when others then
      null;
  end;


/* DFF # 15 :  RA_INTERFACE_LINES - SUPPLEMENT CM' */
  begin
    lv_appl_short_name    :=   'AR';
    lv_flexfield_name     :=   'RA_INTERFACE_LINES';
    lv_context            :=   'SUPPLEMENT CM';
    ln_application_id   := null;

    open cur_appl_id(lv_appl_short_name);
    fetch cur_appl_id into ln_application_id;
    close cur_appl_id;

    delete_context;
  exception
    when others then
      null;
  end;

/* DFF # 16 :  RA_INTERFACE_LINES - SUPPLEMENT DM */
  begin
    lv_appl_short_name    := 'AR';
    lv_flexfield_name     := 'RA_INTERFACE_LINES';
    lv_context            := 'SUPPLEMENT DM';
    ln_application_id   := null;

    open cur_appl_id(lv_appl_short_name);
    fetch cur_appl_id into ln_application_id;
    close cur_appl_id;

    delete_context;
  exception
    when others then
      null;
  end;

/* DFF # 17 :  RA_INTERFACE_LINES - SUPPLEMENT DM */
  begin
    lv_appl_short_name    := 'AR';
    lv_flexfield_name     := 'RA_INTERFACE_LINES';
    lv_context            := 'SUPPLEMENT INVOICE';
    ln_application_id   := null;

    open cur_appl_id(lv_appl_short_name);
    fetch cur_appl_id into ln_application_id;
    close cur_appl_id;

    delete_context;
  exception
    when others then
      null;
  end;

  /* DFF # 18 :  RA_INTERFACE_LINES - TDS CREDIT */
  begin
    lv_appl_short_name    := 'AR';
    lv_flexfield_name     := 'RA_INTERFACE_LINES';
    lv_context            := 'TDS CREDIT';
    ln_application_id   := null;

    open cur_appl_id(lv_appl_short_name);
    fetch cur_appl_id into ln_application_id;
    close cur_appl_id;

    delete_context;
  exception
    when others then
      null;
  end;

  /* DFF # 19 :  OE_LINE_ATTRIBUTES - Sales Order India*/
  begin
    lv_appl_short_name    := 'ONT';
    lv_flexfield_name     := 'OE_LINE_ATTRIBUTES';
    lv_context            := 'Sales Order India';
    ln_application_id   := null;

    open cur_appl_id(lv_appl_short_name);
    fetch cur_appl_id into ln_application_id;
    close cur_appl_id;

    delete_context;
  exception
    when others then
      null;
  end;

  /* DFF # 20 :  OE_LINE_ATTRIBUTES - Invoice India */
  begin
    lv_appl_short_name    := 'ONT';
    lv_flexfield_name     := 'OE_LINE_ATTRIBUTES';
    lv_context            := 'Invoice India';
    ln_application_id   := null;

    open cur_appl_id(lv_appl_short_name);
    fetch cur_appl_id into ln_application_id;
    close cur_appl_id;

    delete_context;
  exception
    when others then
      null;
  end;


  /* DFF # 21 :  OE_LINE_ATTRIBUTES - Sales Order India*/
  begin
    lv_appl_short_name    := 'ONT';
    lv_flexfield_name     := 'OE_LINE_ATTRIBUTES';
    lv_context            := 'Customer PO India';
    ln_application_id   := null;

    open cur_appl_id(lv_appl_short_name);
    fetch cur_appl_id into ln_application_id;
    close cur_appl_id;

    delete_context;
  exception
    when others then
      null;
  end;

  /* VAT- Dynamic Segments ..could be allocated to any context */
  /* Added ln_application_id population code for bug 4924146 */
  select application_id into ln_application_id
  from fnd_application
  where application_short_name = 'SQLAP';

  open  c_get_dff_details(ln_application_id, 'VAT Invoice Number'); /* Added appl_id for bug 4924146 */
  fetch c_get_dff_details into lv_context, lv_attribute_vat_invoice,ln_value_set_inv_id;
  close c_get_dff_details;

  if ln_value_set_inv_id is not null then
    open cur_value_set(ln_value_set_inv_id);
    fetch cur_value_set into lv_value_set_inv_name;
    close cur_value_set;
  end if;

  open  c_get_dff_details(ln_application_id, 'VAT Invoice Date'); /* Added appl_id for bug 4924146 */
  fetch c_get_dff_details into lv_context, lv_attribute_vat_date,ln_value_set_date_id;
  close c_get_dff_details;

  if ln_value_set_date_id is not null then
    open cur_value_set(ln_value_set_date_id);
    fetch cur_value_set into lv_value_set_date_name;
    close cur_value_set;
  end if;

  open  c_get_dff_details(ln_application_id, 'VAT invoice Receipt Date'); /* Added appl_id for bug 4924146 */
  fetch c_get_dff_details into lv_context, lv_attribute_vat_receipt_date, ln_value_set_rdate_id;
  close c_get_dff_details;

  if ln_value_set_rdate_id is not null then
    open cur_value_set(ln_value_set_rdate_id);
    fetch cur_value_set into lv_value_set_rdate_name;
    close cur_value_set;
  end if;

	--Start of addition by Sanjikum, Bug#5443693
	lv_flag := check_before_delete_dff(pv_flexfield_name	=> 'AP_INVOICES',
																		 pv_context				  => lv_context);
	IF lv_flag = '1' THEN
		goto end_of_proc;
	END IF;
	--End of addition by Sanjikum, Bug#5443693

  if lv_attribute_vat_invoice is not null then

      fnd_flex_dsc_api.delete_segment
    (
      appl_short_name  => 'SQLAP',
      flexfield_name   => 'AP_INVOICES',
      context          => lv_context,
      segment          => lv_attribute_vat_invoice
    );

    if lv_value_set_inv_name is not null then
      begin
        fnd_flex_val_api.delete_valueset(lv_value_set_inv_name);
      exception
        when others then
          null;
      end;

    end if;

  end if;

  if lv_attribute_vat_date is not null then

    fnd_flex_dsc_api.delete_segment
    (
      appl_short_name  => 'SQLAP',
      flexfield_name   => 'AP_INVOICES',
      context          => lv_context,
      segment          => lv_attribute_vat_date
    );

    if lv_value_set_date_name is not null then
      begin
        fnd_flex_val_api.delete_valueset(lv_value_set_date_name);
      exception
        when others then
          null;
      end;

    end if;

  end if;

  if lv_attribute_vat_receipt_date is not null then
    fnd_flex_dsc_api.delete_segment
    (
      appl_short_name  => 'SQLAP',
      flexfield_name   => 'AP_INVOICES',
      context          => lv_context,
      segment          => lv_attribute_vat_receipt_date
    );

    if lv_value_set_rdate_name is not null then
      begin
        fnd_flex_val_api.delete_valueset(lv_value_set_rdate_name);
      exception
        when others then
          null;
      end;
    end if;

  end if;

  if lv_context = 'India VAT' then
    fnd_flex_dsc_api.delete_context
    (
      appl_short_name   => 'SQLAP'         ,
      flexfield_name    => 'AP_INVOICES'   ,
      context           => 'India VAT'
    );
  end if;

  <<END_OF_PROC>>
  NULL;

EXCEPTION
WHEN others THEN
  retcode := '2';
  errbuf  := substr(sqlerrm,1,1999);

END remove_context ;

END jai_df_drop ;

/
