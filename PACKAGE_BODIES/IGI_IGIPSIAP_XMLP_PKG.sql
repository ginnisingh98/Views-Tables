--------------------------------------------------------
--  DDL for Package Body IGI_IGIPSIAP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IGIPSIAP_XMLP_PKG" AS
 /* $Header: IGIPSIAPB.pls 120.0.12010000.3 2008/11/11 11:13:46 dramired ship $ */
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION BEFOREREPORT(P_FLEXFIELD_FROM in out NOCOPY varchar2, P_FLEXFIELD_TO in out NOCOPY varchar2) RETURN BOOLEAN IS
    LV_MESSAGE VARCHAR2(4000) := NULL;
    CURSOR CUR_GET_DESCRIPTION IS
      SELECT
        DESCRIPTION
      FROM
        IGI_LOOKUPS
      WHERE UPPER(LOOKUP_CODE) = 'SIA'
        AND LOOKUP_TYPE = 'GCC_DESCRIPTION';
    L_DESCRIPTION IGI_LOOKUPS.DESCRIPTION%TYPE;
  BEGIN
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    /*SRW.REFERENCE(P_STRUCT_NUM)*/NULL;
    --P_FLEXDATA := CONV_FLEX_LOW(P_FLEXDATA);
    --P_FLEXDATA_TO := CONV_FLEX_HIGH(P_FLEXDATA_TO);
    /*SRW.REFERENCE(P_STRUCT_NUM)*/NULL;

    /*SRW.REFERENCE(P_STRUCT_NUM)*/NULL;
    P_WHERE := CONV_WHERE(P_FLEXFIELD_FROM,'LOW');


    P_WHERE1 := CONV_WHERE1(P_FLEXFIELD_TO,'HIGH');

    P_WHERES := '('||P_WHERE||')'||' '||'AND'||' '||'('||P_WHERE1||')';
    --END IF;
    /*SRW.REFERENCE(P_STRUCT_NUM)*/NULL;
    OPEN CUR_GET_DESCRIPTION;
    FETCH CUR_GET_DESCRIPTION
     INTO L_DESCRIPTION;
    CLOSE CUR_GET_DESCRIPTION;
    IF IGI_GEN.IS_REQ_INSTALLED('SIA') THEN
      RETURN (TRUE);
    ELSE
      FND_MESSAGE.SET_NAME('IGI'
                          ,'IGI_GEN_PROD_NOT_INSTALLED');
      FND_MESSAGE.SET_TOKEN('OPTION_NAME'
                           ,L_DESCRIPTION);
      LV_MESSAGE := FND_MESSAGE.GET;
      /*SRW.MESSAGE(20000
                 ,LV_MESSAGE)*/NULL;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN (FALSE);
    END IF;
    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(100
                 ,SQLERRM)*/NULL;
      RETURN (FALSE);
  END BEFOREREPORT;

 /* FUNCTION CONV_FLEX_HIGH(P_FLEX IN VARCHAR2) RETURN VARCHAR2 IS
    V_SEGS VARCHAR2(600) := NULL;
  BEGIN
    V_SEGS := P_FLEX;
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT1'
                     ,'SEGMENT1_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT2'
                     ,'SEGMENT2_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT3'
                     ,'SEGMENT3_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT4'
                     ,'SEGMENT4_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT5'
                     ,'SEGMENT5_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT6'
                     ,'SEGMENT6_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT7'
                     ,'SEGMENT7_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT8'
                     ,'SEGMENT8_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT9'
                     ,'SEGMENT9_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT10'
                     ,'SEGMENT10_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT11'
                     ,'SEGMENT11_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT12'
                     ,'SEGMENT12_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT13'
                     ,'SEGMENT13_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT14'
                     ,'SEGMENT14_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT15'
                     ,'SEGMENT15_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT16'
                     ,'SEGMENT16_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT17'
                     ,'SEGMENT17_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT18'
                     ,'SEGMENT18_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT19'
                     ,'SEGMENT19_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT20'
                     ,'SEGMENT20_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT21'
                     ,'SEGMENT21_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT22'
                     ,'SEGMENT22_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT23'
                     ,'SEGMENT23_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT24'
                     ,'SEGMENT24_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT25'
                     ,'SEGMENT25_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT26'
                     ,'SEGMENT26_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT27'
                     ,'SEGMENT27_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT28'
                     ,'SEGMENT28_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT29'
                     ,'SEGMENT29_HIGH');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT30'
                     ,'SEGMENT30_HIGH');
    RETURN (V_SEGS);
  END CONV_FLEX_HIGH;

  FUNCTION CONV_FLEX_LOW(P_FLEX IN VARCHAR2) RETURN VARCHAR2 IS
    V_SEGS VARCHAR2(600) := NULL;
  BEGIN
    V_SEGS := P_FLEX;
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT1'
                     ,'SEGMENT1_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT2'
                     ,'SEGMENT2_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT3'
                     ,'SEGMENT3_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT4'
                     ,'SEGMENT4_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT5'
                     ,'SEGMENT5_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT6'
                     ,'SEGMENT6_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT7'
                     ,'SEGMENT7_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT8'
                     ,'SEGMENT8_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT9'
                     ,'SEGMENT9_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT10'
                     ,'SEGMENT10_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT11'
                     ,'SEGMENT11_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT12'
                     ,'SEGMENT12_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT13'
                     ,'SEGMENT13_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT14'
                     ,'SEGMENT14_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT15'
                     ,'SEGMENT15_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT16'
                     ,'SEGMENT16_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT17'
                     ,'SEGMENT17_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT18'
                     ,'SEGMENT18_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT19'
                     ,'SEGMENT19_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT20'
                     ,'SEGMENT20_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT21'
                     ,'SEGMENT21_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT22'
                     ,'SEGMENT22_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT23'
                     ,'SEGMENT23_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT24'
                     ,'SEGMENT24_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT25'
                     ,'SEGMENT25_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT26'
                     ,'SEGMENT26_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT27'
                     ,'SEGMENT27_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT28'
                     ,'SEGMENT28_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT29'
                     ,'SEGMENT29_LOW');
    V_SEGS := REPLACE(V_SEGS
                     ,'SEGMENT30'
                     ,'SEGMENT30_LOW');
    RETURN (V_SEGS);
  END CONV_FLEX_LOW;*/

FUNCTION CONV_WHERE(P_FLEXFIELD IN VARCHAR2,P_SEGMENT IN VARCHAR2) RETURN VARCHAR2 IS

TYPE T_VECTOR IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
TYPE T_VECTOR1 IS TABLE OF VARCHAR2(600) INDEX BY BINARY_INTEGER;
V_VALUE T_VECTOR;
V_INDEX_NEXT PLS_INTEGER := 1;
V_INDEX_PIPE PLS_INTEGER := 1;
i PLS_INTEGER := 0;
k PLS_INTEGER := 0;
V_SUBSTRI VARCHAR2(20);

  BEGIN
    P_FLEXDATA := NULL;
    V_INDEX_PIPE := INSTR(P_FLEXFIELD, '-', 1, 1);
    IF V_INDEX_PIPE > 0 THEN
       WHILE V_INDEX_PIPE > 0 LOOP
             i := i + 1;
             V_VALUE(i) := substr(P_FLEXFIELD, V_INDEX_NEXT, V_INDEX_PIPE - V_INDEX_NEXT);
             P_FLEXDATA := P_FLEXDATA||'SEGMENT'||i||'_LOW'||'||''-''||';
             V_INDEX_NEXT := V_INDEX_PIPE + 1;
             V_INDEX_PIPE := instr(P_FLEXFIELD, '-', V_INDEX_NEXT, 1);
             k:= LENGTH(V_VALUE(i));
             IF(k>0) THEN
                FOR dummy in 1 .. k LOOP
                    V_SUBSTRI := substr(V_VALUE(i),dummy,1);
                    IF(substr(V_VALUE(i),1,1)<>'''') THEN
                       IF((V_SUBSTRI >='A' AND V_SUBSTRI <='Z')
                                 OR (V_SUBSTRI >='a' AND V_SUBSTRI <='z')) THEN
                         V_VALUE(i):=''''||V_VALUE(i)||'''';
                       END IF;
                    END IF;
               END LOOP;
            END IF;
             P_WHERE := 'SEGMENT'||i||'_'||P_SEGMENT||'>='||V_VALUE(i)||' '||'AND'||' '||P_WHERE;
      END LOOP;
      P_FLEXDATA := RTRIM(P_FLEXDATA,'||''-''||');
   END IF;
   RETURN(P_WHERE);
END  CONV_WHERE;
FUNCTION CONV_WHERE1(P_FLEXFIELD IN VARCHAR2,P_SEGMENT IN VARCHAR2) RETURN VARCHAR2 IS

TYPE T_VECTOR IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
TYPE T_VECTOR1 IS TABLE OF VARCHAR2(600) INDEX BY BINARY_INTEGER;
V_VALUE T_VECTOR;
V_INDEX_NEXT PLS_INTEGER := 1;
V_INDEX_PIPE PLS_INTEGER := 1;
i PLS_INTEGER := 0;
k PLS_INTEGER := 0;
V_SUBSTRI VARCHAR2(20);

BEGIN
   P_FLEXDATA_TO:=null;
   V_INDEX_PIPE := INSTR(P_FLEXFIELD, '-', 1, 1);
   IF V_INDEX_PIPE > 0 THEN
      WHILE V_INDEX_PIPE > 0 LOOP
            i := i + 1;
            V_VALUE(i) := SUBSTR(P_FLEXFIELD, V_INDEX_NEXT, V_INDEX_PIPE - V_INDEX_NEXT);
            P_FLEXDATA_TO :=  P_FLEXDATA_TO||'SEGMENT'||i||'_HIGH'||'||''-''||';
            V_INDEX_NEXT := V_INDEX_PIPE + 1;
            V_INDEX_PIPE := INSTR(P_FLEXFIELD, '-', V_INDEX_NEXT, 1);
            k:= length(V_VALUE(i));
               IF(k>0) THEN
                  FOR dummy in 1 .. k LOOP
                       V_SUBSTRI := SUBSTR(V_VALUE(i),dummy,1);
                       IF(SUBSTR(V_VALUE(i),1,1)<>'''') THEN
                          IF((V_SUBSTRI >='A' AND V_SUBSTRI <='Z')
                                  OR (V_SUBSTRI >='a' AND V_SUBSTRI <='z')) THEN
                            V_VALUE(i):=''''||V_VALUE(i)||'''';
                          END IF;
                       END IF;
                   END LOOP;
               END IF;
         P_WHERE1 := 'SEGMENT'||i||'_'||P_SEGMENT||'<='||V_VALUE(i)||' '||'AND'||' '||P_WHERE1;
      END LOOP;
      P_FLEXDATA_TO := RTRIM(P_FLEXDATA_TO,'||''-''||');
   END IF;
   RETURN(P_WHERE1);
END  CONV_WHERE1;

END IGI_IGIPSIAP_XMLP_PKG;

/
