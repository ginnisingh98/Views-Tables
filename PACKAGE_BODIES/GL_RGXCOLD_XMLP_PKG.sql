--------------------------------------------------------
--  DDL for Package Body GL_RGXCOLD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_RGXCOLD_XMLP_PKG" AS
/* $Header: RGXCOLDB.pls 120.1 2008/05/29 11:06:12 vijranga noship $ */
function BeforeReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWINIT');*/null;
  DECLARE
    COA_ID    NUMBER;
    FUNC_CURR VARCHAR2(15);
  BEGIN
    SELECT chart_of_accounts_id INTO COA_ID
    FROM gl_access_sets WHERE access_set_id = P_ACCESS_SET_ID;
    C_STRUCT_NUM := COA_ID ;
  END;
  C_ID_FLEX_CODE := 'GLLE';
  /*SRW.USER_EXIT('FND GETPROFILE
                 INDUSTRY :C_INDUSTRY_TYPE');*/null;
  IF ( C_INDUSTRY_TYPE = 'G' ) THEN
    /*SRW.USER_EXIT('FND GETPROFILE
                   ATTRIBUTE_REPORTING :C_ATTRIBUTE_FLAG');*/null;
    IF ( C_ATTRIBUTE_FLAG = 'Y' ) THEN
      C_ID_FLEX_CODE := 'GLAT' ;
      P_FLEXDATA_LOW := P_FLEXDATA_LOW||P_FLEXDATA_LOW2||
                         P_FLEXDATA_LOW3 ;
      P_FLEXDATA_HIGH := P_FLEXDATA_HIGH||P_FLEXDATA_HIGH2||
                          P_FLEXDATA_HIGH3 ;
      P_FLEXDATA_TYPE := P_FLEXDATA_TYPE||P_FLEXDATA_TYPE2||
                          P_FLEXDATA_TYPE3 ;
      P_FLEX_LPROMPT := P_FLEX_LPROMPT||P_FLEX_LPROMPT2||
                         P_FLEX_LPROMPT3 ;
    END IF;
  END IF;
  /*SRW.REFERENCE(C_STRUCT_NUM);*/null;
  /*SRW.USER_EXIT('FND FLEXRSQL CODE=":C_ID_FLEX_CODE"
                 OUTPUT=":P_FLEXDATA"
                 APPL_SHORT_NAME="SQLGL"
                 TYPE=":P_FLEXDATA_TYPE\n_TYPE"
                 NUM=":C_STRUCT_NUM"');*/null;
  /*SRW.REFERENCE(C_STRUCT_NUM);*/null;
 null;
  P_FLEXDATA_LOW := replace(P_FLEXDATA_LOW,'LEDGER_SEGMENT_LOW','GLLED.short_name');
  P_FLEXDATA_HIGH := replace(P_FLEXDATA_HIGH,'LEDGER_SEGMENT_HIGH','GLLED.short_NAME');
  return (TRUE);
end;
function AfterReport return boolean is
begin
BEGIN
   /*SRW.USER_EXIT('FND SRWEXIT');*/null;
   RETURN TRUE;
END;  return (TRUE);
end;
function c_flex_lowformula(C_FLEX_LOW in varchar2) return varchar2 is
begin
/*SRW.REFERENCE(C_ID_FLEX_CODE);*/null;
/*SRW.REFERENCE(C_DATA_LOW);*/null;
/*SRW.REFERENCE(C_STRUCT_NUM);*/null;
/*SRW.USER_EXIT('FND FLEXRIDVAL
               CODE=":C_ID_FLEX_CODE"
               APPL_SHORT_NAME="SQLGL"
               DATA=":C_DATA_LOW"
               VALUE=":C_FLEX_LOW"
               NUM=":C_STRUCT_NUM"');*/null;
RETURN(C_FLEX_LOW);
end;
function c_flex_highformula(C_FLEX_HIGH in varchar2) return varchar2 is
begin
/*SRW.REFERENCE(C_ID_FLEX_CODE);*/null;
/*SRW.REFERENCE(C_DATA_HIGH);*/null;
/*SRW.REFERENCE(C_STRUCT_NUM);*/null;
/*SRW.USER_EXIT('FND FLEXRIDVAL
               CODE=":C_ID_FLEX_CODE"
               APPL_SHORT_NAME="SQLGL"
               DATA=":C_DATA_HIGH"
               VALUE=":C_FLEX_HIGH"
               NUM=":C_STRUCT_NUM"');*/null;
RETURN(C_FLEX_HIGH);
end;
function c_flex_typeformula(C_FLEX_TYPE in varchar2) return varchar2 is
begin
/*SRW.REFERENCE(C_ID_FLEX_CODE);*/null;
/*SRW.REFERENCE(C_DATA_TYPE);*/null;
/*SRW.REFERENCE(C_STRUCT_NUM);*/null;
/*SRW.USER_EXIT('FND FLEXRIDVAL
               CODE=":C_ID_FLEX_CODE"
               APPL_SHORT_NAME="SQLGL"
               DATA=":C_DATA_TYPE"
               VALUE=":C_FLEX_TYPE"
               NUM=":C_STRUCT_NUM"');*/null;
RETURN(C_FLEX_TYPE);
end;
function display_format_dspformula(display_format in varchar2, display_precision in number, format_mask_width in number, format_before_text in varchar2, format_after_text in varchar2) return char is
  display_fmt       varchar2(30);
  tmp_display_fmt   varchar2(30);
  nines_bf_radix    NUMBER;
  radix		    varchar2(30);
  thsnd_sprtr       varchar2(30);
  po_thsnd_sprtr    varchar2(1);
  temp              varchar2(15);
 icx_num_char varchar2(10);
begin
 fnd_profile.get('ICX_NUMERIC_CHARACTERS', icx_num_char);
radix := substr(icx_num_char,1,1);
thsnd_sprtr := substr(icx_num_char,2,1);

  fnd_profile.get('CURRENCY:THOUSANDS_SEPARATOR', temp);
  po_thsnd_sprtr := nvl(temp,'Y');
  IF (display_format IS NULL or display_format = '') THEN
      display_fmt := '';
    ELSE
      IF (po_thsnd_sprtr = 'N') THEN
        IF (display_precision = 0) THEN
          display_fmt := LPAD('9', format_mask_width, '9');
        ELSE
          display_fmt := LPAD(RPAD(radix, display_precision + 1, '9'),
                              format_mask_width, '9');
        END IF;
      ELSE
        IF (display_precision = 0) THEN
          IF (format_mask_width <= 3) THEN
            display_fmt := LPAD('9', format_mask_width, '9');
          ELSE
            display_fmt := LPAD(LPAD(thsnd_sprtr || '999',
                                     TRUNC(format_mask_width/4)*4,
                                     thsnd_sprtr || '999'),
                                     format_mask_width, '9');
          END IF;
        ELSE
          nines_bf_radix := format_mask_width - display_precision - 1;
          IF (nines_bf_radix <= 3) THEN
            display_fmt := RPAD(LPAD('9', nines_bf_radix, '9') ||
                                radix,
                                format_mask_width, '9');
          ELSE
            display_fmt := RPAD(LPAD(LPAD(thsnd_sprtr || '999' || radix,
                                          TRUNC(nines_bf_radix/4)*4 + 1,
                                          thsnd_sprtr || '999'),
                               format_mask_width - display_precision, '9'),
                               format_mask_width,'9');
          END IF;
        END IF;
      END IF;
      tmp_display_fmt := LPAD(display_fmt, NVL(NVL(LENGTH(display_format), 0),0) -
                                       NVL(NVL(LENGTH(format_before_text), 0),0) -
                                       NVL(NVL(LENGTH(format_after_text), 0),0),
                          ' ');
      display_fmt := format_before_text || tmp_display_fmt || format_after_text;
    END IF;
  return(display_fmt);
end;
--Functions to refer Oracle report placeholders--
 Function C_STRUCT_NUM_p return number is
	Begin
	 return C_STRUCT_NUM;
	 END;
 Function C_ID_FLEX_CODE_p return varchar2 is
	Begin
	 return C_ID_FLEX_CODE;
	 END;
 Function C_INDUSTRY_TYPE_p return varchar2 is
	Begin
	 return C_INDUSTRY_TYPE;
	 END;
 Function C_ATTRIBUTE_FLAG_p return varchar2 is
	Begin
	 return C_ATTRIBUTE_FLAG;
	 END;
END GL_RGXCOLD_XMLP_PKG ;


/
