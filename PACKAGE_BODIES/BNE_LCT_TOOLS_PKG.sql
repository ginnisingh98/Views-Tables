--------------------------------------------------------
--  DDL for Package Body BNE_LCT_TOOLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_LCT_TOOLS_PKG" as
/* $Header: bnelcttoolsb.pls 120.6 2005/12/07 16:09:24 dagroves noship $ */

function APP_ID_TO_ASN(X_APP_ID IN NUMBER) RETURN FND_APPLICATION.APPLICATION_SHORT_NAME%TYPE
is
  V_ASN FND_APPLICATION.APPLICATION_SHORT_NAME%TYPE;
begin
  if X_APP_ID is null
  then
    return(null);
  end if;
  --
  SELECT APPLICATION_SHORT_NAME
  INTO   V_ASN
  FROM FND_APPLICATION
  WHERE APPLICATION_ID = X_APP_ID;
  --
  return(V_ASN);
exception
  when no_data_found then
    raise_application_error(-20000, 'No Application is registered in Applications with an application id of '||to_char(X_APP_ID)||'.');
end APP_ID_TO_ASN;

function ASN_TO_APP_ID(X_ASN IN VARCHAR2) RETURN FND_APPLICATION.APPLICATION_ID%TYPE
is
  V_APP_ID FND_APPLICATION.APPLICATION_ID%TYPE;
begin
  if X_ASN is null
  then
    return(null);
  end if;
  --
  SELECT APPLICATION_ID
  INTO   V_APP_ID
  FROM FND_APPLICATION
  WHERE APPLICATION_SHORT_NAME = X_ASN;
  --
  return(V_APP_ID);
exception
  when no_data_found then
    raise_application_error(-20000, 'No Application is registered in Applications with an application short name of '''||X_ASN||'''.');
end ASN_TO_APP_ID;

function GET_APP_ID(X_BNE_KEY IN VARCHAR2)
RETURN NUMBER
IS
  COLON_POSITION INTEGER;
  KEY_NUMBER     NUMBER;
BEGIN
  if (X_BNE_KEY is NULL)
  THEN
    RETURN(NULL);
  END IF;

  COLON_POSITION := INSTR(X_BNE_KEY, ':');
  if (COLON_POSITION = 0)
  THEN
    RETURN(NULL);
  END IF;

  BEGIN
    KEY_NUMBER := SUBSTR(X_BNE_KEY,1,(COLON_POSITION -1));
  EXCEPTION
    WHEN INVALID_NUMBER THEN
      KEY_NUMBER := ASN_TO_APP_ID(SUBSTR(X_BNE_KEY,1,(COLON_POSITION -1)));
  END;
  RETURN(KEY_NUMBER);
END GET_APP_ID;

function GET_CODE(X_BNE_KEY IN VARCHAR2)
RETURN VARCHAR2
IS
  COLON_POSITION INTEGER;
  KEY_CODE       VARCHAR2(40);
BEGIN
  if (X_BNE_KEY is NULL)
  THEN
    RETURN(NULL);
  END IF;

  COLON_POSITION := INSTR(X_BNE_KEY, ':');
  if (COLON_POSITION = 0)
  THEN
    RETURN(NULL);
  END IF;

  KEY_CODE       := TRIM(SUBSTR(X_BNE_KEY, COLON_POSITION+1));
  RETURN(KEY_CODE);
END GET_CODE;

--------------------------------------------------------------------------------
--  FUNCTION:         GET_PLSQL_ATT9 (PACKAGE PRIVATE)                        --
--                                                                            --
--  DESCRIPTION:      Retrieve any code values for parameter lists encoded in --
--                    attributes, this is done for the PLSQL, CLEANUP_PLSQL   --
--                    and CONCURRENT_REQUEST steps of the parameter driven    --
--                    importer.                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  30-MAY-2005  DAGROVES  Created.                                           --
--------------------------------------------------------------------------------
function GET_PLSQL_ATT9(X_LIST_APP_ID IN NUMBER,
                        X_LIST_CODE   IN VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR C_ATT9(CP_APPLICATION_ID   NUMBER,
                CP_PARAM_LIST_CODE  VARCHAR2)
  IS
  SELECT ATTRIBUTE9
  FROM   BNE_ATTRIBUTES A, BNE_PARAM_LIST_ITEMS I
  WHERE  A.APPLICATION_ID  = I.ATTRIBUTE_APP_ID
  AND    A.ATTRIBUTE_CODE  = I.ATTRIBUTE_CODE
  AND    I.APPLICATION_ID  = CP_APPLICATION_ID
  AND    I.PARAM_LIST_CODE = CP_PARAM_LIST_CODE
  AND    ATTRIBUTE9 IS NOT NULL
  ORDER BY I.SEQUENCE_NUM;

  REC            C_ATT9%ROWTYPE;
  COLON_POSITION INTEGER;
  KEY_CODE       VARCHAR2(40);
  RET            VARCHAR2(2000);
BEGIN
  FOR REC IN C_ATT9(X_LIST_APP_ID, X_LIST_CODE)
  LOOP
    COLON_POSITION := INSTR(REC.ATTRIBUTE9, ':');
    if (COLON_POSITION > 0)
    THEN
      KEY_CODE       := TRIM(SUBSTR(REC.ATTRIBUTE9, COLON_POSITION+1));
      RET            := RET||','||KEY_CODE;
    END IF;
  END LOOP;
  RETURN(RET);
END ;

--------------------------------------------------------------------------------
--  FUNCTION:         GET_IMPORT_LISTS                                        --
--                                                                            --
--  DESCRIPTION:      Retrieve all code values for parameter lists used by    --
--                    the parameter driven importer.                          --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  30-MAY-2005  DAGROVES  Created.                                           --
--------------------------------------------------------------------------------
function GET_IMPORT_LISTS(X_IMPORT_LIST_APP_ID IN NUMBER,
                          X_IMPORT_LIST_CODE   IN VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR C_MASTER_LIST_ITEMS(CP_APPLICATION_ID   NUMBER,
                             CP_PARAM_LIST_CODE VARCHAR2)
  IS
  SELECT PARAM_NAME,
         STRING_VALUE,
         ATTRIBUTE_APP_ID,
         ATTRIBUTE_CODE
  FROM   BNE_PARAM_LIST_ITEMS
  WHERE  APPLICATION_ID  = CP_APPLICATION_ID
  AND    PARAM_LIST_CODE = CP_PARAM_LIST_CODE;

  PARAM_NAME     BNE_PARAM_LIST_ITEMS.PARAM_NAME%TYPE;
  PARAM_VALUE    BNE_PARAM_LIST_ITEMS.STRING_VALUE%TYPE;
  COLON_POSITION INTEGER;
  KEY_NUMBER     NUMBER;
  KEY_CODE       VARCHAR2(40);
  TMP            VARCHAR2(2000);
  RET            VARCHAR2(2000);
BEGIN
  RET := NULL;
  if X_IMPORT_LIST_APP_ID is null OR
     X_IMPORT_LIST_CODE   is null
  then
    return(null);
  end if;
  --
  FOR REC IN C_MASTER_LIST_ITEMS(X_IMPORT_LIST_APP_ID, X_IMPORT_LIST_CODE)
  LOOP
    -- PARAM_NAME can have the following values:
    -- SQL
    -- PLSQL
    -- CONCURRENT_REQUEST
    -- SEQUENCE
    -- GROUP
    -- SUCCESS_MESSAGE
    -- ROW_MAPPING
    -- ERRORED_ROWS
    -- ERROR_LOOKUP
    -- CLEANUP_SQL
    -- CLEANUP_PLSQL
    --
    PARAM_NAME  := REC.PARAM_NAME;
    PARAM_VALUE := REC.STRING_VALUE;

    -- All entries except 'SUCCESS_MESSAGE' have a sub-list.
    IF (PARAM_NAME NOT IN ('SUCCESS_MESSAGE'))
    THEN
      COLON_POSITION := INSTR(PARAM_VALUE, ':');
      KEY_NUMBER     := SUBSTR(PARAM_VALUE,1,(COLON_POSITION -1));
      KEY_CODE       := TRIM(SUBSTR(PARAM_VALUE, COLON_POSITION+1));
      -- all sublists are required, add to return value.
      RET            := RET||','||KEY_CODE;

      -- Drill further into lists as required.
      if (PARAM_NAME = 'PLSQL')
      then
        -- attribute 9 of parameters in sublist contains a sublist
        RET := RET||','||GET_PLSQL_ATT9(KEY_NUMBER, KEY_CODE);
      elsif (PARAM_NAME = 'CONCURRENT_REQUEST')
      then
        -- attribute 9 of parameters in sublist contains a sublist
        RET := RET||','||GET_PLSQL_ATT9(KEY_NUMBER, KEY_CODE);
      elsif (PARAM_NAME = 'CLEANUP_PLSQL')
      then
        -- attribute 9 of parameters in sublist contains a sublist
        RET := RET||','||GET_PLSQL_ATT9(KEY_NUMBER, KEY_CODE);
-- Commented out for efficiency, however these values form
-- the unique list of import steps and are left for clarity.
--      elsif (PARAM_NAME = 'SEQUENCE')
--      then
--        null; -- No sub-lists for this step.
--      elsf (PARAM_NAME = 'SQL')
--      then
--        null; -- No sub-lists for this step.
--      elsif (PARAM_NAME = 'GROUP')
--      then
--        null; -- No sub-lists for this step.
--      elsif (PARAM_NAME = 'ROW_MAPPING')
--      then
--        null; -- No sub-lists for this step.
--      elsif (PARAM_NAME = 'ERRORED_ROWS')
--      then
--        null; -- No sub-lists for this step.
--      elsif (PARAM_NAME = 'ERROR_LOOKUP')
--      then
--        null; -- No sub-lists for this step.
--      elsif (PARAM_NAME = 'CLEANUP_SQL')
--      then
--        null; -- No sub-lists for this step.
      END IF;
    END IF;

  END LOOP;
  RETURN(RET);
END GET_IMPORT_LISTS;

function GET_NAMED_ATTRIBUTE(ATTS IN BNE_ATTRIBUTES%ROWTYPE,
                             NAME IN BNE_ATTRIBUTES.ATTRIBUTE_NAME1%TYPE)
RETURN VARCHAR2
IS
  RET BNE_ATTRIBUTES.ATTRIBUTE1%TYPE;
BEGIN
  if NAME is null
  THEN
    return(null);
  end if;
  if ATTS.ATTRIBUTE_NAME1 = name then
    return(ATTS.ATTRIBUTE1);
  elsif ATTS.ATTRIBUTE_NAME2 = name then
    return(ATTS.ATTRIBUTE2);
  elsif ATTS.ATTRIBUTE_NAME3 = name then
    return(ATTS.ATTRIBUTE3);
  elsif ATTS.ATTRIBUTE_NAME4 = name then
    return(ATTS.ATTRIBUTE4);
  elsif ATTS.ATTRIBUTE_NAME5 = name then
    return(ATTS.ATTRIBUTE5);
  elsif ATTS.ATTRIBUTE_NAME6 = name then
    return(ATTS.ATTRIBUTE6);
  elsif ATTS.ATTRIBUTE_NAME7 = name then
    return(ATTS.ATTRIBUTE7);
  elsif ATTS.ATTRIBUTE_NAME8 = name then
    return(ATTS.ATTRIBUTE8);
  elsif ATTS.ATTRIBUTE_NAME9 = name then
    return(ATTS.ATTRIBUTE9);
  elsif ATTS.ATTRIBUTE_NAME10 = name then
    return(ATTS.ATTRIBUTE10);
  elsif ATTS.ATTRIBUTE_NAME11 = name then
    return(ATTS.ATTRIBUTE11);
  elsif ATTS.ATTRIBUTE_NAME12 = name then
    return(ATTS.ATTRIBUTE12);
  elsif ATTS.ATTRIBUTE_NAME13 = name then
    return(ATTS.ATTRIBUTE13);
  elsif ATTS.ATTRIBUTE_NAME14 = name then
    return(ATTS.ATTRIBUTE14);
  elsif ATTS.ATTRIBUTE_NAME15 = name then
    return(ATTS.ATTRIBUTE15);
  elsif ATTS.ATTRIBUTE_NAME16 = name then
    return(ATTS.ATTRIBUTE16);
  elsif ATTS.ATTRIBUTE_NAME17 = name then
    return(ATTS.ATTRIBUTE17);
  elsif ATTS.ATTRIBUTE_NAME18 = name then
    return(ATTS.ATTRIBUTE18);
  elsif ATTS.ATTRIBUTE_NAME19 = name then
    return(ATTS.ATTRIBUTE19);
  elsif ATTS.ATTRIBUTE_NAME20 = name then
    return(ATTS.ATTRIBUTE20);
  elsif ATTS.ATTRIBUTE_NAME21 = name then
    return(ATTS.ATTRIBUTE21);
  elsif ATTS.ATTRIBUTE_NAME22 = name then
    return(ATTS.ATTRIBUTE22);
  elsif ATTS.ATTRIBUTE_NAME23 = name then
    return(ATTS.ATTRIBUTE23);
  elsif ATTS.ATTRIBUTE_NAME24 = name then
    return(ATTS.ATTRIBUTE24);
  elsif ATTS.ATTRIBUTE_NAME25 = name then
    return(ATTS.ATTRIBUTE25);
  elsif ATTS.ATTRIBUTE_NAME26 = name then
    return(ATTS.ATTRIBUTE26);
  elsif ATTS.ATTRIBUTE_NAME27 = name then
    return(ATTS.ATTRIBUTE27);
  elsif ATTS.ATTRIBUTE_NAME28 = name then
    return(ATTS.ATTRIBUTE28);
  elsif ATTS.ATTRIBUTE_NAME29 = name then
    return(ATTS.ATTRIBUTE29);
  elsif ATTS.ATTRIBUTE_NAME30 = name then
    return(ATTS.ATTRIBUTE30);
  else
    return(null);
  END IF;
END GET_NAMED_ATTRIBUTE;

--------------------------------------------------------------------------------
--  FUNCTION:         GET_EXTENSIBLE_MENUS_LISTS                              --
--                                                                            --
--  DESCRIPTION:      Retrieve all code values for parameter lists used by    --
--                    the extensible menus functionality.                     --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  07-Dec-2005  DAGROVES  Created.                                           --
--------------------------------------------------------------------------------
function GET_EXTENSIBLE_MENUS_LISTS(X_CDPF_LIST_APP_ID IN NUMBER,
                                    X_CDPF_LIST_CODE   IN VARCHAR2)
RETURN VARCHAR2
IS
  RET            VARCHAR2(2000);
  ATTS           BNE_ATTRIBUTES%ROWTYPE;
  TMP            VARCHAR2(2000);
  COLON_POSITION INTEGER;

  CURSOR C_LIST_FK(CP_APPLICATION_ID   NUMBER,
                   CP_PARAM_LIST_CODE  VARCHAR2)
  IS
  SELECT A.*
  FROM   BNE_PARAM_LIST_ITEMS LI, BNE_PARAM_DEFNS_B PD, BNE_ATTRIBUTES A
  WHERE  LI.PARAM_DEFN_APP_ID = PD.APPLICATION_ID
  AND    LI.PARAM_DEFN_CODE = PD.PARAM_DEFN_CODE
  AND    PD.PARAM_SOURCE = 'WEBADI:ViewerExtension'
  AND    A.APPLICATION_ID = PD.ATTRIBUTE_APP_ID
  AND    A.ATTRIBUTE_CODE = PD.ATTRIBUTE_CODE
  AND    LI.APPLICATION_ID  = CP_APPLICATION_ID
  AND    LI.PARAM_LIST_CODE = CP_PARAM_LIST_CODE;
BEGIN
  RET := NULL;
  if X_CDPF_LIST_APP_ID is null OR
     X_CDPF_LIST_CODE   is null
  then
    return(null);
  end if;
  --
  OPEN C_LIST_FK(X_CDPF_LIST_APP_ID, X_CDPF_LIST_CODE);
  FETCH C_LIST_FK INTO ATTS;
  if C_LIST_FK%NOTFOUND then
    CLOSE C_LIST_FK;
    return(null);
  end if;
  CLOSE C_LIST_FK;
  TMP := GET_NAMED_ATTRIBUTE(ATTS, 'PARAM_LIST_KEY');
  if TMP is null
  then
    return(null);
  end if;
  COLON_POSITION := INSTR(TMP, ':');
  RET            := TRIM(SUBSTR(TMP, COLON_POSITION+1));

  return(ret);
exception
  when OTHERS then
    if (C_LIST_FK%ISOPEN) then
      close C_LIST_FK;
    end if;
END GET_EXTENSIBLE_MENUS_LISTS;


--------------------------------------------------------------------------------
--  FUNCTION:         GET_ESC_EXTENSIBLE_MENUS_LISTS                          --
--                                                                            --
--  DESCRIPTION:      Retrieve all code values for parameter lists used by    --
--                    the extensible menus functionality.  The Menus codes are--
--                    surrounded by the '#' character to prevent substr probs.--
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  07-Dec-2005  DAGROVES  Created.                                           --
--------------------------------------------------------------------------------
function GET_ESC_EXTENSIBLE_MENUS_LISTS(X_CDPF_LIST_APP_ID IN NUMBER,
                                        X_CDPF_LIST_CODE   IN VARCHAR2)
RETURN VARCHAR2
IS
  RET            VARCHAR2(2000);
BEGIN
  RET := GET_EXTENSIBLE_MENUS_LISTS(X_CDPF_LIST_APP_ID, X_CDPF_LIST_CODE);
  if RET is not NULL
  then
    return('#'||RET||'#');
  end if;
  return(null);
END GET_ESC_EXTENSIBLE_MENUS_LISTS;



end BNE_LCT_TOOLS_PKG;

/
