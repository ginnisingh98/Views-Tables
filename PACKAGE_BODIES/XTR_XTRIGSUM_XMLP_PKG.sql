--------------------------------------------------------
--  DDL for Package Body XTR_XTRIGSUM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_XTRIGSUM_XMLP_PKG" AS
/* $Header: XTRIGSUMB.pls 120.1 2007/12/28 12:50:00 npannamp noship $ */
  FUNCTION CF_SET_PARAFORMULA RETURN VARCHAR2 IS
  BEGIN
    SELECT
      SUBSTR(USER
            ,1
            ,10)
    INTO
      CP_PARA
    FROM
      DUAL;
    RETURN (CP_PARA);
  END CF_SET_PARAFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    L_DMMY_NUM NUMBER;
    L_MESSAGE FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
    CURSOR GET_LANGUAGE_DESC IS
      SELECT
        ITEM_NAME,
        SUBSTR(TEXT
              ,1
              ,100) LANG_NAME
      FROM
        XTR_SYS_LANGUAGES_VL
      WHERE MODULE_NAME = 'XTRIGSUM';
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    BEGIN
      COMPANY_NAME_HEADER := CEP_STANDARD.GET_WINDOW_SESSION_TITLE;
    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('XTR'
                            ,'XTR_LOOKUP_ERR');
        L_MESSAGE := FND_MESSAGE.GET;
        RAISE_APPLICATION_ERROR(-20101
                               ,NULL);
    END;
    IF (P_DISPLAY_DEBUG = 'Y') THEN
      NULL;
    END IF;
    FOR c IN GET_LANGUAGE_DESC LOOP
      IF C.ITEM_NAME = 'Z1COMPANY' THEN
        Z1COMPANY := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1FOR_PERIOD' THEN
        Z1FOR_PERIOD := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1INTERGROUP_PARTY' THEN
        Z1INTERGROUP_PARTY := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1PARAMETERS' THEN
        Z1PARAMETERS := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1REPORT_NOS' THEN
        Z1REPORT_NOS := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1TO' THEN
        Z1TO := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2ADJUSTMENT' THEN
        Z2ADJUSTMENT := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2BALANCE' THEN
        Z2BALANCE := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2CCY' THEN
        Z2CCY := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2CURRENCY' THEN
        Z2CURRENCY := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2DATE' THEN
        Z2DATE := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2DAY' THEN
        Z2DAY := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2END_OF_REPORT' THEN
        Z2END_OF_REPORT := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2INTEREST' THEN
        Z2INTEREST := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2INTEREST_BFWD' THEN
        Z2INTEREST_BFWD := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2INTEREST_CFWD' THEN
        Z2INTEREST_CFWD := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2INTEREST_FOR_THE_PERIOD' THEN
        Z2INTEREST_FOR_THE_PERIOD := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2INTEREST_SETTLED' THEN
        Z2INTEREST_SETTLED := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2INT_RATE' THEN
        Z2INT_RATE := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2PRIN' THEN
        Z2PRIN := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2SETTLED_ON' THEN
        Z2SETTLED_ON := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2PAGE' THEN
        Z2PAGE := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2REPORT' THEN
        Z2REPORT := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2REQUESTED_BY' THEN
        Z2REQUESTED_BY := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2NOTE' THEN
        Z2NOTE := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'REPORT_DATE' THEN
        REPORT_DATE := C.LANG_NAME;
      END IF;
    END LOOP;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
    L_ERROR NUMBER;
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
    LD_DATE DATE;
  BEGIN
    SELECT
      TRUNC(SYSDATE)
    INTO
      LD_DATE
    FROM
      DUAL;
    P_PERIOD_FROM_1 := TO_CHAR(TO_DATE(P_PERIOD_FROM
                                    ,'YYYY/MM/DD HH24:MI:SS')
                            ,'DD-MON-YYYY');
    P_PERIOD_TO_1 := TO_CHAR(TO_DATE(P_PERIOD_TO
                                  ,'YYYY/MM/DD HH24:MI:SS')
                          ,'DD-MON-YYYY');
    PER_FROM := P_PERIOD_FROM_1;
    PER_TO := P_PERIOD_TO_1;
    PER_TO := NVL(PER_TO
                 ,LD_DATE);
    IF PER_FROM IS NOT NULL THEN
      PER_TO := GREATEST(PER_TO
                        ,PER_FROM);
    END IF;
    SEL_COMP2 := P_COMPANY;
    SEL_PARTY2 := P_INTERGROUP_PARTY;
    SELECT
      CP.USER_CONCURRENT_PROGRAM_NAME
    INTO
      REPORT_SHORT_NAME2
    FROM
      FND_CONCURRENT_PROGRAMS_VL CP,
      FND_CONCURRENT_REQUESTS CR
    WHERE CR.REQUEST_ID = FND_GLOBAL.CONC_REQUEST_ID
      AND CP.APPLICATION_ID = CR.PROGRAM_APPLICATION_ID
      AND CP.CONCURRENT_PROGRAM_ID = CR.CONCURRENT_PROGRAM_ID;

      REPORT_SHORT_NAME2 := substr(REPORT_SHORT_NAME2,1,instr(REPORT_SHORT_NAME2,' (XML)'));
    RETURN (TRUE);
  END AFTERPFORM;

 FUNCTION CF_INT_CFFORMULA(COMP_CODE IN VARCHAR2
                           ,PTY_CODE IN VARCHAR2
                           ,CCY IN VARCHAR2
                           ,CF_INTEREST_FOR_DUMMY_REC IN NUMBER
                           ,DAY_COUNT_TYPE IN VARCHAR2
                           ,ACC_INT_BF IN NUMBER) RETURN NUMBER IS
	Lvr_Combination_Code	Varchar2(100) 	:= Comp_code||Pty_Code||Ccy;
	Lnu_Int_Amt		Number 		:= nvl(Cf_interest_for_dummy_rec,0);
begin
	If Lvr_Combination_Code <> Nvl(P_Combination,'*') Then

			p_IntAmt_Running  := 0;
			p_SetAmt_Running  := 0;
			P_Prev_day_Count_Type := day_count_Type;
			P_Prev_Prev_day_Count_Type := Null;
--			P_Oldest_Transfer_Date := Trans_Date;

		P_Combination := Lvr_Combination_Code ;
	Else
		P_Prev_Prev_day_Count_Type := P_Prev_day_Count_Type;
		P_Prev_day_Count_Type := day_count_Type;
	End If;

  	p_IntAmt_Running := Nvl(p_IntAmt_Running,0)+Lnu_Int_Amt;
  	p_SetAmt_Running := (Nvl(p_SetAmt_Running,0)+nvl(Acc_Int_Bf,0));

  	Return(Nvl(p_IntAmt_Running,0) - Nvl(P_SetAmt_Running,0));

end;
 /* FUNCTION CF_INT_CFFORMULA(COMP_CODE IN VARCHAR2
                           ,PTY_CODE IN VARCHAR2
                           ,CCY IN VARCHAR2
                           ,CF_INTEREST_FOR_DUMMY_REC IN NUMBER
                           ,DAY_COUNT_TYPE IN VARCHAR2
                           ,ACC_INT_BF IN NUMBER) RETURN NUMBER IS
    LVR_COMBINATION_CODE VARCHAR2(100) := COMP_CODE || PTY_CODE || CCY;
    LNU_INT_AMT NUMBER := NVL(CF_INTEREST_FOR_DUMMY_REC
       ,0);
  BEGIN
    IF LVR_COMBINATION_CODE < NVL(P_COMBINATION
       ,'*') THEN
      P_INTAMT_RUNNING := 0;
      P_SETAMT_RUNNING := 0;
      P_PREV_DAY_COUNT_TYPE := DAY_COUNT_TYPE;
      P_PREV_PREV_DAY_COUNT_TYPE := NULL;
      P_COMBINATION := LVR_COMBINATION_CODE;
    ELSE
      P_PREV_PREV_DAY_COUNT_TYPE := P_PREV_DAY_COUNT_TYPE;
      P_PREV_DAY_COUNT_TYPE := DAY_COUNT_TYPE;
    END IF;
    P_INTAMT_RUNNING := NVL(P_INTAMT_RUNNING
                           ,0) + LNU_INT_AMT;
    P_SETAMT_RUNNING := (NVL(P_SETAMT_RUNNING
                           ,0) + NVL(ACC_INT_BF
                           ,0));
    RETURN (NVL(P_INTAMT_RUNNING
              ,0) - NVL(P_SETAMT_RUNNING
              ,0));
  END CF_INT_CFFORMULA;*/

  FUNCTION FN_GET_DAYS(ANU_ST_DATE IN DATE) RETURN NUMBER IS
  BEGIN
    RETURN (0);
  END FN_GET_DAYS;

FUNCTION CF_INTEREST_FOR_DUMMY_RECFORMU(CF_NO_OF_DAYS IN NUMBER
                                         ,ROUNDING_FACTOR IN NUMBER
                                         ,IG_YEAR_BASIS IN VARCHAR2
                                         ,DAY_COUNT_TYPE IN VARCHAR2
                                         ,SET_DATE IN DATE
                                         ,PTY_CODE IN VARCHAR2
                                         ,COMP_CODE IN VARCHAR2
                                         ,CCY IN VARCHAR2
                                         ,PRIN_ACTION IN VARCHAR2
                                         ,CF_PRV_DAY IN DATE
                                         ,TRANS_DATE IN DATE
                                         ,BAL_BF IN NUMBER
                                         ,CF_PRV_RATE IN NUMBER
                                         ,ROUNDING_TYPE IN VARCHAR2) RETURN NUMBER IS
	    LNU_YEAR_DAYS NUMBER;
    LNU_NO_OF_DAYS NUMBER := CF_NO_OF_DAYS;
    LNU_YR_BASIS NUMBER;
    LNU_ROUNDFAC NUMBER := ROUNDING_FACTOR;
    LVR_YEAR_CALC_TYPE VARCHAR2(15) := IG_YEAR_BASIS;
    LNU_INTEREST NUMBER;
    LVR_DAY_COUNT_TYPE VARCHAR2(1) := DAY_COUNT_TYPE;
    PRV_DATE DATE := SET_DATE;
    L_OLDEST_DATE DATE := P_OLDEST_TRANSFER_DATE;
    L_FIRST_TRANS_FLAG VARCHAR2(1) := 'N';
    L_PRV_DAY_COUNT_TYPE VARCHAR2(1) := P_PREV_PREV_DAY_COUNT_TYPE;
    L_DAY_COUNT_TYPE VARCHAR2(1) := P_PREV_DAY_COUNT_TYPE;

cursor OLDEST_DATE is
  select min(TRANSFER_DATE)
    from xtr_intergroup_transfers
   where party_code = PTY_CODE
     and company_code = COMP_CODE
     and currency = CCY;

begin

           open oldest_date;
           fetch oldest_date into l_oldest_date;
           close oldest_date;

           if prin_action <> 'DUMMY' then
              prv_date := cf_prv_day;
           end if;

		if l_day_count_type = 'B' and l_oldest_date = prv_date then
			l_first_trans_flag := 'Y';
		elsif (l_day_count_type = 'B' or l_day_count_type ='F') and l_oldest_date <> prv_date then
			if l_day_count_type = 'F' and (l_prv_day_count_type = 'B' or l_prv_day_count_type = 'L') then
				prv_date := prv_date  + 1;
			elsif l_day_count_type ='B' and l_prv_day_count_type = 'L' then
				l_first_trans_flag := 'Y';
	   		end if;
		end if;

		XTR_CALC_P.CALC_DAYS_RUN (prv_date,TRANS_DATE,Lvr_Year_calc_Type,Lnu_no_of_days,Lnu_Yr_Basis,Null,Lvr_day_count_type,l_first_trans_flag);
		Lnu_interest := xtr_fps2_p.interest_round(BAL_BF * cf_prv_rate / 100 *Lnu_no_of_days /Lnu_yr_basis,Lnu_roundfac,rounding_type );
		Return(Lnu_Interest);
end;

/*  FUNCTION CF_INTEREST_FOR_DUMMY_RECFORMU(CF_NO_OF_DAYS IN NUMBER
                                         ,ROUNDING_FACTOR IN NUMBER
                                         ,IG_YEAR_BASIS IN VARCHAR2
                                         ,DAY_COUNT_TYPE IN VARCHAR2
                                         ,SET_DATE IN DATE
                                         ,PTY_CODE IN VARCHAR2
                                         ,COMP_CODE IN VARCHAR2
                                         ,CCY IN VARCHAR2
                                         ,PRIN_ACTION IN VARCHAR2
                                         ,CF_PRV_DAY IN DATE
                                         ,TRANS_DATE IN DATE
                                         ,BAL_BF IN NUMBER
                                         ,CF_PRV_RATE IN NUMBER
                                         ,ROUNDING_TYPE IN VARCHAR2) RETURN NUMBER IS
    LNU_YEAR_DAYS NUMBER;
    LNU_NO_OF_DAYS NUMBER := CF_NO_OF_DAYS;
    LNU_YR_BASIS NUMBER;
    LNU_ROUNDFAC NUMBER := ROUNDING_FACTOR;
    LVR_YEAR_CALC_TYPE VARCHAR2(15) := IG_YEAR_BASIS;
    LNU_INTEREST NUMBER;
    LVR_DAY_COUNT_TYPE VARCHAR2(1) := DAY_COUNT_TYPE;
    PRV_DATE DATE := SET_DATE;
    L_OLDEST_DATE DATE := P_OLDEST_TRANSFER_DATE;
    L_FIRST_TRANS_FLAG VARCHAR2(1) := 'N';
    L_PRV_DAY_COUNT_TYPE VARCHAR2(1) := P_PREV_PREV_DAY_COUNT_TYPE;
    L_DAY_COUNT_TYPE VARCHAR2(1) := P_PREV_DAY_COUNT_TYPE;
    CURSOR OLDEST_DATE IS
      SELECT
        MIN(TRANSFER_DATE)
      FROM
        XTR_INTERGROUP_TRANSFERS
      WHERE PARTY_CODE = PTY_CODE
        AND COMPANY_CODE = COMP_CODE
        AND CURRENCY = CCY;
  BEGIN
    OPEN OLDEST_DATE;
    FETCH OLDEST_DATE
     INTO
       L_OLDEST_DATE;
    CLOSE OLDEST_DATE;
    IF PRIN_ACTION < 'DUMMY' THEN
      PRV_DATE := CF_PRV_DAY;
    END IF;
    IF L_DAY_COUNT_TYPE = 'B' AND L_OLDEST_DATE = PRV_DATE THEN
      L_FIRST_TRANS_FLAG := 'Y';
    ELSIF (L_DAY_COUNT_TYPE = 'B' OR L_DAY_COUNT_TYPE = 'F') AND L_OLDEST_DATE < PRV_DATE THEN
      IF L_DAY_COUNT_TYPE = 'F' AND (L_PRV_DAY_COUNT_TYPE = 'B' OR L_PRV_DAY_COUNT_TYPE = 'L') THEN
        PRV_DATE := PRV_DATE + 1;
      ELSIF L_DAY_COUNT_TYPE = 'B' AND L_PRV_DAY_COUNT_TYPE = 'L' THEN
        L_FIRST_TRANS_FLAG := 'Y';
      END IF;
    END IF;
    XTR_CALC_P.CALC_DAYS_RUN(PRV_DATE
                            ,TRANS_DATE
                            ,LVR_YEAR_CALC_TYPE
                            ,LNU_NO_OF_DAYS
                            ,LNU_YR_BASIS
                            ,NULL
                            ,LVR_DAY_COUNT_TYPE
                            ,L_FIRST_TRANS_FLAG);
    LNU_INTEREST := XTR_FPS2_P.INTEREST_ROUND(BAL_BF * CF_PRV_RATE / 100 * LNU_NO_OF_DAYS / LNU_YR_BASIS
                                             ,LNU_ROUNDFAC
                                             ,ROUNDING_TYPE);
    RETURN (LNU_INTEREST);
  END CF_INTEREST_FOR_DUMMY_RECFORMU;*/

  FUNCTION CF_NO_OF_DAYSFORMULA(N_DAYS IN NUMBER
                               ,IG_YEAR_BASIS IN VARCHAR2
                               ,DAY_COUNT_TYPE IN VARCHAR2
                               ,SET_DATE IN DATE
                               ,PTY_CODE IN VARCHAR2
                               ,COMP_CODE IN VARCHAR2
                               ,CCY IN VARCHAR2
                               ,PRIN_ACTION IN VARCHAR2
                               ,CF_PRV_DAY IN DATE
                               ,TRANS_DATE IN DATE) RETURN NUMBER IS
    LNU_NO_OF_DAYS NUMBER := N_DAYS;
    LNU_YR_BASIS NUMBER;
    LVR_YEAR_CALC_TYPE VARCHAR2(15) := IG_YEAR_BASIS;
    LVR_DAY_COUNT_TYPE VARCHAR2(1) := DAY_COUNT_TYPE;
    L_FIRST_TRANS_FLAG VARCHAR2(1) := 'N';
    L_PRV_DAY_COUNT_TYPE VARCHAR2(1) := P_PREV_PREV_DAY_COUNT_TYPE;
    L_DAY_COUNT_TYPE VARCHAR2(1) := P_PREV_DAY_COUNT_TYPE;
    PRV_DATE DATE := SET_DATE;
    L_OLDEST_DATE DATE := P_OLDEST_TRANSFER_DATE;
    CURSOR OLDEST_DATE IS
      SELECT
        MIN(TRANSFER_DATE)
      FROM
        XTR_INTERGROUP_TRANSFERS
      WHERE PARTY_CODE = PTY_CODE
        AND COMPANY_CODE = COMP_CODE
        AND CURRENCY = CCY;
  BEGIN
    OPEN OLDEST_DATE;
    FETCH OLDEST_DATE
     INTO
       L_OLDEST_DATE;
    CLOSE OLDEST_DATE;
    IF PRIN_ACTION < 'DUMMY' THEN
      PRV_DATE := CF_PRV_DAY;
    END IF;
    BEGIN
      IF L_DAY_COUNT_TYPE = 'B' AND L_OLDEST_DATE = PRV_DATE THEN
        L_FIRST_TRANS_FLAG := 'Y';
      ELSIF (L_DAY_COUNT_TYPE = 'B' OR L_DAY_COUNT_TYPE = 'F') AND L_OLDEST_DATE < PRV_DATE THEN
        IF L_DAY_COUNT_TYPE = 'F' AND (L_PRV_DAY_COUNT_TYPE = 'B' OR L_PRV_DAY_COUNT_TYPE = 'L') THEN
          PRV_DATE := PRV_DATE + 1;
        ELSIF L_DAY_COUNT_TYPE = 'B' AND L_PRV_DAY_COUNT_TYPE = 'L' THEN
          L_FIRST_TRANS_FLAG := 'Y';
        END IF;
      END IF;
      XTR_CALC_P.CALC_DAYS_RUN(PRV_DATE
                              ,TRANS_DATE
                              ,LVR_YEAR_CALC_TYPE
                              ,LNU_NO_OF_DAYS
                              ,LNU_YR_BASIS
                              ,NULL
                              ,LVR_DAY_COUNT_TYPE
                              ,L_FIRST_TRANS_FLAG);
      RETURN (LNU_NO_OF_DAYS);
    END;
  END CF_NO_OF_DAYSFORMULA;

  FUNCTION CF_PRV_DAYFORMULA(COMP_CODE IN VARCHAR2
                            ,PTY_CODE IN VARCHAR2
                            ,CCY IN VARCHAR2
                            ,TRANS_DATE IN DATE
                            ,TRANSACTION_NUMBER1 IN NUMBER) RETURN DATE IS
    L_DATE DATE;
    CURSOR PRV_DATE IS
      SELECT
        MAX(TRANSFER_DATE)
      FROM
        XTR_INTERGROUP_TRANSFERS
      WHERE COMPANY_CODE = COMP_CODE
        AND PARTY_CODE = PTY_CODE
        AND CURRENCY = CCY
        AND TRANSFER_DATE <= TRANS_DATE
        AND TRANSACTION_NUMBER < TRANSACTION_NUMBER1;
  BEGIN
    OPEN PRV_DATE;
    FETCH PRV_DATE
     INTO
       L_DATE;
    CLOSE PRV_DATE;
    RETURN (GREATEST(NVL(L_DATE
                       ,TRANS_DATE)
                   ,PER_FROM));
  END CF_PRV_DAYFORMULA;

  FUNCTION CF_PRV_RATEFORMULA(COMP_CODE IN VARCHAR2
                             ,PTY_CODE IN VARCHAR2
                             ,CCY IN VARCHAR2
                             ,TRANS_DATE IN DATE) RETURN NUMBER IS
    L_RATE NUMBER;
    CURSOR PRV_RATE IS
      SELECT
        INTEREST_RATE
      FROM
        XTR_INTERGROUP_TRANSFERS A
      WHERE COMPANY_CODE = COMP_CODE
        AND PARTY_CODE = PTY_CODE
        AND CURRENCY = CCY
        AND TRANSFER_DATE = (
        SELECT
          MAX(TRANSFER_DATE)
        FROM
          XTR_INTERGROUP_TRANSFERS B
        WHERE A.DEAL_NUMBER = B.DEAL_NUMBER
          AND TRANSFER_DATE < TRANS_DATE )
        AND TRANSACTION_NUMBER = (
        SELECT
          MAX(TRANSACTION_NUMBER)
        FROM
          XTR_INTERGROUP_TRANSFERS C
        WHERE A.DEAL_NUMBER = C.DEAL_NUMBER
          AND TRANSFER_DATE < TRANS_DATE );
  BEGIN
    OPEN PRV_RATE;
    FETCH PRV_RATE
     INTO
       L_RATE;
    CLOSE PRV_RATE;
    RETURN NVL(L_RATE
              ,0);
  END CF_PRV_RATEFORMULA;

  FUNCTION BAL_BFFORMULA(COMP_CODE IN VARCHAR2
                        ,PTY_CODE IN VARCHAR2
                        ,CCY IN VARCHAR2
                        ,TRANS_DATE IN DATE) RETURN NUMBER IS
    L_BAL_BF NUMBER;
    CURSOR BAL_BF IS
      SELECT
        BALANCE_OUT
      FROM
        XTR_INTERGROUP_TRANSFERS A
      WHERE COMPANY_CODE = COMP_CODE
        AND PARTY_CODE = PTY_CODE
        AND CURRENCY = CCY
        AND TRANSFER_DATE = (
        SELECT
          MAX(TRANSFER_DATE)
        FROM
          XTR_INTERGROUP_TRANSFERS B
        WHERE A.DEAL_NUMBER = B.DEAL_NUMBER
          AND TRANSFER_DATE < TRANS_DATE )
        AND TRANSACTION_NUMBER = (
        SELECT
          MAX(TRANSACTION_NUMBER)
        FROM
          XTR_INTERGROUP_TRANSFERS C
        WHERE A.DEAL_NUMBER = C.DEAL_NUMBER
          AND TRANSFER_DATE < TRANS_DATE );
  BEGIN
    OPEN BAL_BF;
    FETCH BAL_BF
     INTO
       L_BAL_BF;
    CLOSE BAL_BF;
    RETURN NVL(L_BAL_BF
              ,0);
  END BAL_BFFORMULA;

  FUNCTION CP_PARA_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_PARA;
  END CP_PARA_P;

END XTR_XTRIGSUM_XMLP_PKG;


/
