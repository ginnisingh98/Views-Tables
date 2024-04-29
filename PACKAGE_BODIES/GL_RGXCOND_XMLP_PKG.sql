--------------------------------------------------------
--  DDL for Package Body GL_RGXCOND_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_RGXCOND_XMLP_PKG" AS
/* $Header: RGXCONDB.pls 120.1 2007/12/28 10:49:11 vijranga noship $ */
function BeforeReport return boolean is
begin
  BEGIN
    /*SRW.USER_EXIT('FND SRWINIT');*/null;
    DECLARE
       COA_ID    NUMBER;
       FUNC_CURR VARCHAR2(15);
    BEGIN
       SELECT chart_of_accounts_id INTO COA_ID
       FROM gl_access_sets WHERE access_set_id = P_ACCESS_SET_ID;
       C_STRUCT_NUM := COA_ID;
    END;
    C_ID_FLEX_CODE := 'GLLE' ;
       C_INDUSTRY_TYPE := FND_PROFILE.VALUE('INDUSTRY');
    /*SRW.USER_EXIT('FND GETPROFILE
                    INDUSTRY :C_INDUSTRY_TYPE');*/null;
    IF ( C_INDUSTRY_TYPE = 'G' )
    THEN
      C_ATTRIBUTE_FLAG := FND_PROFILE.VALUE('ATTRIBUTE_REPORTING');
        /*SRW.USER_EXIT('FND GETPROFILE
                    ATTRIBUTE_REPORTING :C_ATTRIBUTE_FLAG');*/null;
        IF ( C_ATTRIBUTE_FLAG = 'Y' )
        THEN
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
   END IF ;
   P_FLEXDATA_LOW := replace(P_FLEXDATA_LOW,'LEDGER_SEGMENT_LOW','GLLED.short_name');
   P_FLEXDATA_HIGH := replace(P_FLEXDATA_HIGH,'LEDGER_SEGMENT_HIGH','GLLED.short_name');
  END;
    select FND_FLEX_APIS.gbl_get_segment_delimiter(101,C_ID_FLEX_CODE,C_STRUCT_NUM) into C_DELIMITER from dual;
  if (C_DELIMITER ='') THEN
	C_DELIMITER := '-';
  end if;
  return (TRUE);
end;
function AfterReport return boolean is
begin
BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT');*/null;
END;  return (TRUE);
end;
function c_flex_lowformula(C_DATA_LOW in varchar2) return varchar2 is
C_FLEX_LOW varchar2(3000);
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
C_FLEX_LOW := replace(C_DATA_LOW,'\n',C_DELIMITER);
RETURN(C_FLEX_LOW);
end;
function c_flex_highformula(C_DATA_HIGH in varchar2) return varchar2 is
C_FLEX_HIGH varchar2(3000);
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
C_FLEX_HIGH := replace(C_DATA_HIGH,'\n',C_DELIMITER);
RETURN(C_FLEX_HIGH);
end;
function c_flex_typeformula(C_DATA_TYPE in varchar2) return varchar2 is
C_FLEX_TYPE varchar2(3000);
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
C_FLEX_TYPE := replace(C_DATA_TYPE,'\n',C_DELIMITER);
RETURN(C_FLEX_TYPE);
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
END GL_RGXCOND_XMLP_PKG ;



/
