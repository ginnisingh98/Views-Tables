--------------------------------------------------------
--  DDL for Package Body AP_APXVDLBL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXVDLBL_XMLP_PKG" AS
/* $Header: APXVDLBLB.pls 120.0 2007/12/27 08:45:36 vjaganat noship $ */
FUNCTION  custom_init         RETURN BOOLEAN IS
BEGIN
  BEGIN
               SELECT sort_by_alternate_field
     INTO SORT_BY_ALTERNATE
     FROM AP_SYSTEM_PARAMETERS;
  EXCEPTION
    WHEN OTHERS THEN
      SORT_BY_ALTERNATE := 'N';
  END;
  BEGIN
    /*SRW.REFERENCE(DEFAULT_COUNTRY_CODE);*/null;
    /*SRW.USER_EXIT('FND GETPROFILE NAME="DEFAULT_COUNTRY" FIELD="DEFAULT_COUNTRY_CODE"');*/null;
  EXCEPTION
    WHEN OTHERS THEN
      DEFAULT_COUNTRY_CODE_1 := 'US';
  END;
  IF DEFAULT_COUNTRY_CODE is NULL THEN
    DEFAULT_COUNTRY_CODE_1 := 'US';
  else
  DEFAULT_COUNTRY_CODE_1:=DEFAULT_COUNTRY_CODE;
 END IF;
  BEGIN
    select territory_short_name into DEFAULT_COUNTRY_NAME
    from fnd_territories_vl
    where territory_code = DEFAULT_COUNTRY_CODE_1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      select territory_short_name into DEFAULT_COUNTRY_NAME
      from fnd_territories_vl
      where territory_code = 'US';
  END;
  BEGIN
    select displayed_field into ATTN_MESSAGE
    from ap_lookup_codes
    where lookup_type = 'MAIL_LABEL_ATTN_MESSAGE' and
          lookup_code = 'ATTN_MESSAGE';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ATTN_MESSAGE := 'Attn: Accounts Receivable';
  END;
  IF (P_VENDOR_TYPE is NULL) THEN
    P_VENDOR_TYPE_1:= 'All';
  END IF;
  IF (P_SITE is NULL) THEN
    P_SITE_1 := 'All';
  END IF;
  IF (P_SITE = 'Pay') THEN
    PAY_SITE := 'Y';
  ELSIF (P_SITE = 'Non-Pay') THEN
    PAY_SITE := 'N';
  END IF;
RETURN (TRUE);
RETURN NULL; EXCEPTION
  WHEN   OTHERS  THEN
    RETURN (FALSE);
END;
function BeforeReport return boolean is
begin
DECLARE
  init_failure    EXCEPTION;
BEGIN
  /*SRW.USER_EXIT('FND SRWINIT');*/null;
  IF (p_debug_switch in ('y','Y')) THEN
     /*SRW.MESSAGE('1','After SRWINIT');*/null;
  END IF;
  IF(custom_init <> TRUE) THEN
      RAISE init_failure;
  END IF;
  IF (p_debug_switch in ('y','Y')) THEN
      /*SRW.MESSAGE('2','After Custom_Init');*/null;
  END IF;
  IF (p_debug_switch in ('y','Y')) THEN
     /*SRW.BREAK;*/null;
  END IF;
  RETURN (TRUE);
EXCEPTION
  WHEN   OTHERS  THEN
    RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;
END;
  return (TRUE);
end;
function AfterReport return boolean is
begin
BEGIN
   /*SRW.USER_EXIT('FND SRWEXIT');*/null;
   IF (P_DEBUG_SWITCH = 'Y') THEN
      /*SRW.MESSAGE('20','After SRWEXIT');*/null;
   END IF;
EXCEPTION
WHEN OTHERS THEN
   RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;
END;  return (TRUE);
end;
function C_ORDER_BYFormula return VARCHAR2 is
begin
IF P_ORDER_COLUMN = 'Zip' THEN
    IF SORT_BY_ALTERNATE = 'Y' THEN
        return('ORDER BY upper(s.zip), upper(v.vendor_name_alt), upper(s.vendor_site_code_alt)');
    ELSE
        return('ORDER BY upper(s.zip), upper(v.vendor_name), upper(s.vendor_site_code)');
    END IF;
ELSE
    IF SORT_BY_ALTERNATE = 'Y' THEN
        return('ORDER BY upper(v.vendor_name_alt), upper(s.vendor_site_code_alt)');
    ELSE
        return('ORDER BY upper(v.vendor_name), upper(s.vendor_site_code)');
    END IF;
END IF;
RETURN NULL; end;
function c_address_concatenatedformula(address1 in varchar2, address2 in varchar2, address3 in varchar2,
city in varchar2, state in varchar2, zip in varchar2, country_name in varchar2,
country_code in varchar2, vendor_name in varchar2, attention in varchar2) return varchar2 is
begin
return( arp_addr_label_pkg.format_address_label(
	NULL,
	address1,
	address2,
	address3,
	NULL,
	city,
	NULL,
	state,
	NULL,
	zip,
	country_name,
	country_code,
	vendor_name,
	NULL,
	attention,
	NULL,
	NULL,
	DEFAULT_COUNTRY_CODE_1,
	DEFAULT_COUNTRY_NAME,
	P_PRINT_HOME_COUNTRY,
	34,
	6,
	6
));
end;
--Functions to refer Oracle report placeholders--
END AP_APXVDLBL_XMLP_PKG ;



/
