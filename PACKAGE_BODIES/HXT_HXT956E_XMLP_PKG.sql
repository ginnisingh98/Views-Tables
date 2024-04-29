--------------------------------------------------------
--  DDL for Package Body HXT_HXT956E_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_HXT956E_XMLP_PKG" AS
/* $Header: HXT956EB.pls 120.0 2007/12/03 11:12:13 amakrish noship $ */

function ppremformula(P_ELT_PRIOR_PREM_ID in number, P_EFFECTIVE_START_DATE in date, P_EFFECTIVE_END_DATE in date) return varchar2 is
   PPREM     VARCHAR2(80);
begin
   PPREM := ' ';
DECLARE
    CURSOR C IS
      SELECT ELTT.ELEMENT_NAME
      FROM   PAY_ELEMENT_TYPES_F ELT1
            ,PAY_ELEMENT_TYPES_F_TL ELTT
            ,HXT_PAY_ELEMENT_TYPES_F_DDF_V ELTV1
      WHERE  ELTV1.ELEMENT_TYPE_ID = P_ELT_PRIOR_PREM_ID
      AND    ELTV1.EFFECTIVE_START_DATE <= P_EFFECTIVE_START_DATE
      AND    ELTV1.EFFECTIVE_END_DATE >= P_EFFECTIVE_END_DATE
      AND    ELTV1.ELEMENT_TYPE_ID = ELT1.ELEMENT_TYPE_ID
      AND    ELT1.EFFECTIVE_START_DATE <= P_EFFECTIVE_START_DATE
      AND    ELT1.EFFECTIVE_END_DATE >= P_EFFECTIVE_END_DATE
      AND    ELT1.element_type_id = eltt.element_type_id
      AND    ELTV1.element_type_id = elt1.element_type_id
      and    eltt.language = userenv('LANG')
      and (eltv1.hxt_premium_type = 'FACTOR'
      AND eltv1.hxt_earning_category = 'OVT'
       or eltv1.hxt_earning_category NOT IN ('REG', 'OVT', 'ABS'));
  BEGIN
    IF P_ELT_PRIOR_PREM_ID IS NOT NULL THEN
    OPEN C;
    FETCH C
    INTO   PPREM;
    IF C%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE C;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      PPREM := ' ';
    WHEN OTHERS THEN
      /*SRW.MESSAGE(01,'ERROR '||PPREM);*/null;

  END;
   RETURN PPREM;
end;

function incexcformula(APPLY_PRIOR_PREM_YN in varchar2) return varchar2 is
    INCEXC   VARCHAR2(10);
begin
    INCEXC := ' ';
    IF APPLY_PRIOR_PREM_YN = 'Y' THEN
       INCEXC := 'Include';
    ELSE
       IF APPLY_PRIOR_PREM_YN = 'N' THEN
          INCEXC := 'Exclude';
       ELSE
          INCEXC := APPLY_PRIOR_PREM_YN;
       END IF;
    END IF;
RETURN INCEXC;
end;

function edateformula(EFFECTIVE_END_DATE in date) return date is
   EDATE   DATE;
begin
   EDATE := NULL;
   IF EFFECTIVE_END_DATE = TO_DATE('31/12/4712','DD/MM/YYYY') THEN
         EDATE := NULL;
   ELSE
      EDATE := EFFECTIVE_END_DATE;
   END IF;
RETURN EDATE;
end;

function earn_premformula(P_ELT_EARNED_PREM_ID in number, P_EFFECTIVE_START_DATE in date, P_EFFECTIVE_END_DATE in date) return varchar2 is
    EARN_PREM    VARCHAR2(80);
begin
    EARN_PREM := ' ';
DECLARE
    CURSOR C IS
      SELECT ELTT.ELEMENT_NAME
      FROM   PAY_ELEMENT_TYPES_F ELT
            ,PAY_ELEMENT_TYPES_F_TL ELTT
            ,HXT_PAY_ELEMENT_TYPES_F_DDF_V ELTV
      WHERE  ELTV.ELEMENT_TYPE_ID = P_ELT_EARNED_PREM_ID
      AND    ELTV.EFFECTIVE_START_DATE <= P_EFFECTIVE_START_DATE
      AND    ELTV.EFFECTIVE_END_DATE >= P_EFFECTIVE_END_DATE
      AND    ELTV.ELEMENT_TYPE_ID = ELT.ELEMENT_TYPE_ID
      AND    ELT.EFFECTIVE_START_DATE <= P_EFFECTIVE_START_DATE
      AND    ELT.EFFECTIVE_END_DATE >= P_EFFECTIVE_END_DATE
      AND    ELT.element_type_id = eltt.element_type_id
      AND    ELTV.element_type_id = elt.element_type_id
      and    eltt.language = userenv('LANG')
      and (eltv.hxt_premium_type = 'FACTOR'
      AND eltv.hxt_earning_category = 'OVT'
       or eltv.hxt_earning_category NOT IN ('REG', 'OVT', 'ABS'));
  BEGIN
    IF P_ELT_EARNED_PREM_ID IS NOT NULL THEN
    OPEN C;
    FETCH C
    INTO   EARN_PREM;
    IF C%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE C;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        EARN_PREM := ' ';
    WHEN OTHERS THEN
      /*SRW.MESSAGE(01,'ERROR  '||EARN_PREM);*/null;

  END;
  RETURN EARN_PREM;
end;

function BeforePForm return boolean is
begin

  return (TRUE);
end;

function AfterPForm return boolean is
begin

  return (TRUE);
end;

function BeforeReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  return (TRUE);
end;

function BetweenPage return boolean is
begin

  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END HXT_HXT956E_XMLP_PKG ;

/
