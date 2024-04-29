--------------------------------------------------------
--  DDL for Package Body HXT_HXT957F_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_HXT957F_XMLP_PKG" AS
/* $Header: HXT957FB.pls 120.0 2007/12/03 11:27:15 amakrish noship $ */

function var_type_desformula(VAR_TYPE in varchar2) return varchar2 is
   Var_Type_Des  VARCHAR2(20);
begin

   if VAR_TYPE = 'EAR' then
      Var_Type_Des := 'EARNING';
   else if VAR_TYPE = 'ORG1' then
         Var_Type_Des := 'ORGANIZATION';
   else if VAR_TYPE = 'LOC1' then
         Var_Type_Des := 'LOCATION';
   else  Var_Type_Des := '';
   end if;
   end if;
   end if;
   return Var_Type_Des;
end;

function Var_Type_NameFormula(VAR_TYPE in varchar2,VAR_TYPE_ID in number) return VARCHAR2 is
  Var_Type_Name VARCHAR2(60); begin
  Var_Type_Name := '';
  if VAR_TYPE = 'ORG1' then
     BEGIN
        IF (VAR_TYPE_ID IS NOT NULL) THEN
          DECLARE
            CURSOR C IS
              SELECT NAME
              FROM
              HR_ALL_ORGANIZATION_UNITS_TL
              WHERE  ORGANIZATION_ID = VAR_TYPE_ID
              AND language = userenv('LANG');
          BEGIN
            OPEN C;
            FETCH C
            INTO   Var_Type_Name;
            IF C%NOTFOUND THEN
              Var_Type_Name := '';
            END IF;
            CLOSE C;
          EXCEPTION
            WHEN OTHERS THEN
              Var_Type_Name := '';
          END;
        END IF;
     END;
  else if VAR_TYPE = 'LOC1' then
     BEGIN
        IF (VAR_TYPE_ID IS NOT NULL) THEN
          DECLARE
            CURSOR C IS
              SELECT LOCATION_CODE
              FROM   HR_LOCATIONS_ALL_TL
              WHERE  LOCATION_ID = VAR_TYPE_ID
              AND  LANGUAGE = USERENV('LANG');
          BEGIN
            OPEN C;
            FETCH C
            INTO   Var_Type_Name;
            IF C%NOTFOUND THEN
              Var_Type_Name := '';
            END IF;
            CLOSE C;
          EXCEPTION
            WHEN OTHERS THEN
              Var_Type_Name := '';
          END;
        END IF;
     END;
  else if VAR_TYPE = 'EAR' then
     BEGIN
        IF (VAR_TYPE_ID IS NOT NULL) THEN
          DECLARE
            CURSOR C IS
              SELECT ELEMENT_NAME
              FROM   PAY_ELEMENT_TYPES_F_TL
              WHERE  ELEMENT_TYPE_ID = VAR_TYPE_ID
	      AND  LANGUAGE = USERENV('LANG');
          BEGIN
            OPEN C;
            FETCH C
            INTO   Var_Type_Name;
            IF C%NOTFOUND THEN
              Var_Type_Name := '';
            END IF;
            CLOSE C;
          EXCEPTION
            WHEN OTHERS THEN
              Var_Type_Name := '';
          END;
        END IF;
     END;
  else
     Var_Type_Name := '';
  end if;
  end if;
  end if;
  return Var_Type_Name;

end;

function BeforeReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END HXT_HXT957F_XMLP_PKG ;

/
