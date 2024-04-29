--------------------------------------------------------
--  DDL for Package Body IGI_CIS2007_IGIPPADR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_CIS2007_IGIPPADR_PKG" AS
-- $Header: IGIPPADB.pls 120.2 2008/01/28 15:07:27 rsaini noship $
      function BeforeReport return boolean is
      begin
        if UPPER(P_TOTAL_TYPE) = 'T' then
          p_select_clause := ' , (lines.total_payments + lines.total_deductions) GROSS_AMOUNT_PAID,' ||
                             ' lines.MATERIAL_COST MATERIAL_COST,' ||
                             ' lines.LABOUR_COST LABOUR_COST, ' ||
                             ' lines.TOTAL_DEDUCTIONS AMOUNT_DEDUCTED, ' ||
			     ' null INVOICE_NUM ' ;
          p_from_clause := ', HR_LOCATIONS_V hrl';

          if UPPER(P_ZERO_DEDUCTIONS) = 'Y' Then
	     p_where_clause := ' and hrl.location_id = aprea.LOCATION_ID '||
	  	               ' and UPPER(hdr.period_name) ='''||UPPER(P_PERIOD)||'''';
	  else
	     p_where_clause := ' and hrl.location_id = aprea.LOCATION_ID '||
	  	               ' and UPPER(hdr.period_name) ='''||UPPER(P_PERIOD)||'''' ||
	  	               ' and nvl(lines.total_deductions,0) > 0' ;
	  end if;

          if (P_SUPPLIER_FROM IS NOT NULL) then
            p_where_clause := p_where_clause || ' and LINES.vendor_name >= ' || '''' ||
                              P_SUPPLIER_FROM || '''';
          end if;
          if (P_SUPPLIER_TO IS NOT NULL) then
            p_where_clause := p_where_clause || ' and LINES.vendor_name <= ' || '''' ||
                              P_SUPPLIER_TO || '''';
          end if;

          p_where_clause := p_where_clause || ' order by lines.vendor_name ';


        elsif UPPER(P_TOTAL_TYPE) = 'P' then
          p_select_clause := ', (payment.amount + payment.total_deductions) GROSS_AMOUNT_PAID,' ||
                             ' payment.MATERIAL_COST MATERIAL_COST,' ||
                             ' payment.LABOUR_COST LABOUR_COST, ' ||
                             ' payment.TOTAL_DEDUCTIONS AMOUNT_DEDUCTED, ' ||
			     ' invoice.INVOICE_NUM INVOICE_NUM ' ;
          p_from_clause  := ', HR_LOCATIONS_V hrl, igi_cis_mth_ret_pay_h payment, AP_INVOICES invoice';
          p_where_clause := ' and hrl.location_id = aprea.LOCATION_ID '||
                            ' and UPPER(hdr.period_name) ='''||UPPER(P_PERIOD)||'''' ||' and payment.INVOICE_ID = invoice.INVOICE_ID ' ;
          if UPPER(P_ZERO_DEDUCTIONS) = 'Y' Then
             p_where_clause := p_where_clause ||' and lines.HEADER_ID = payment.header_id
                                               and lines.vendor_id = payment.VENDOR_ID ';
          else
            p_where_clause := p_where_clause ||' and lines.HEADER_ID = payment.header_id and lines.vendor_id = payment.VENDOR_ID ' ||
                            		       ' and nvl(payment.total_deductions,0) > 0' ;
          end if;

          p_where_clause := p_where_clause ||' and lines.HEADER_ID = payment.header_id
                                               and lines.vendor_id = payment.VENDOR_ID ';
          if (P_SUPPLIER_FROM IS NOT NULL) then
            p_where_clause := p_where_clause || ' and LINES.vendor_name >= ' || '''' ||
                              P_SUPPLIER_FROM || '''';
          end if;
          if (P_SUPPLIER_TO IS NOT NULL) then
            p_where_clause := p_where_clause || ' and LINES.vendor_name <= ' || '''' ||
                              P_SUPPLIER_TO || '''';
          end if;
          p_where_clause := p_where_clause || ' order by lines.vendor_name ';


        end if;
        return(TRUE);
      end BeforeReport;
      -------------------------------------------------------------------------------------
      function get_PRINT_TYPE return varchar2 is
        l_print_type IGI_LOOKUPS.MEANING% TYPE := null;
      begin
        select meaning
          into l_print_type
          from IGI_LOOKUPS
         where LOOKUP_TYPE = 'IGI_CIS2007_PRINT_TYPES'
           and LOOKUP_CODE = P_PRINT_TYPE;
            return(l_print_type);
      exception
        WHEN no_data_found THEN
          return(l_print_type);
      end get_PRINT_TYPE;
      --------------------------------------------------------------------------------
      function get_ORG_NAME return varchar2 is
        l_org_id   HR_OPERATING_UNITS.organization_id%TYPE := null;
        l_org_name HR_OPERATING_UNITS.name%TYPE := null;
      begin
        l_org_id := MO_GLOBAL.get_current_org_id;
        select name
          into l_org_name
          from hr_operating_units
         where organization_id = l_org_id;
        return(l_org_name);
      exception
        WHEN no_data_found THEN
          return(l_org_name);
      end get_ORG_NAME;
      -------------------------------------------------------------------------------
      function get_PERIOD_END_DATE return varchar2 is
        l_period_type AP_OTHER_PERIODS.Period_Type%TYPE;
        l_end_date    AP_OTHER_PERIODS.Start_Date%TYPE;
      begin
        l_period_type := fnd_profile.value('IGI_CIS2007_CALENDAR');
        select end_date
          into l_end_date
          from AP_OTHER_PERIODS
         where period_type = l_period_type
           and period_name = P_PERIOD;
        return(l_end_date);
      exception
        WHEN no_data_found THEN
          return(l_end_date);
      end get_PERIOD_END_DATE;
end IGI_CIS2007_IGIPPADR_PKG;

/
