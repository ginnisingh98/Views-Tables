--------------------------------------------------------
--  DDL for Package Body CS_CSXSRDET_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CSXSRDET_XMLP_PKG" AS
/* $Header: CSXSRDETB.pls 120.0 2008/01/24 13:30:11 dwkrishn noship $ */

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    BEGIN
      IF (P_CUSTOMER_NUM_LOW IS NOT NULL) AND (P_CUSTOMER_NUM_HIGH IS NOT NULL) THEN
        LP_CUSTOMER_NUMBER := 'and (inc.customer_number between :P_Customer_Num_Low  AND :P_Customer_Num_High)';
      ELSIF (P_CUSTOMER_NUM_LOW IS NOT NULL) THEN
        LP_CUSTOMER_NUMBER := 'AND inc.customer_number >= :P_Customer_Num_Low';
      ELSIF (P_CUSTOMER_NUM_HIGH IS NOT NULL) THEN
        LP_CUSTOMER_NUMBER := 'and inc.customer_number <= :P_Customer_Num_High ';
      END IF;

      IF (LP_CUSTOMER_NUMBER IS NULL) THEN
	LP_CUSTOMER_NUMBER :='AND 1=1';
END IF;
      IF (P_REQUEST_LOW IS NOT NULL) AND (P_REQUEST_HIGH IS NOT NULL) THEN
        LP_REQUEST_NUMBER := 'AND (INC.incident_number BETWEEN
                                                            :P_request_Low AND
                                                            :P_request_High)';
      ELSIF (P_REQUEST_LOW IS NOT NULL) THEN
        LP_REQUEST_NUMBER := 'AND INC.incident_number >=
                                                                 :P_request_Low';
      ELSIF (P_REQUEST_HIGH IS NOT NULL) THEN
        LP_REQUEST_NUMBER := 'AND INC.incident_number <=
                                                                  :P_request_High ';
      END IF;
    IF (LP_REQUEST_NUMBER IS NULL) THEN
    LP_REQUEST_NUMBER := 'AND 1=1';
    END IF;
      IF (P_TYPE IS NOT NULL) THEN
        LP_TYPE := 'AND inc.incident_type =
                                                   :P_type';
      END IF;
      IF (LP_TYPE IS NULL) THEN
	LP_TYPE :='AND 1=1';
END IF;
      IF (P_SEVERITY IS NOT NULL) THEN
        LP_SEVERITY := 'AND inc.severity =
                                                       :P_Severity';
      END IF;
           IF (LP_SEVERITY IS NULL) THEN
	LP_SEVERITY :='AND 1=1';
END IF;
      IF (P_URGENCY IS NOT NULL) THEN
        LP_URGENCY := 'AND inc.URGENCY=
                                                      :P_Urgency ';
      END IF;
        IF (LP_URGENCY IS NULL) THEN
	LP_URGENCY :='AND 1=1';
END IF;
      IF (P_PROBLEM_CODE IS NOT NULL) THEN
        LP_PROBLEM_CODE := 'AND INC.problem_code =
                                                           :P_problem_code';
      END IF;

       IF (LP_PROBLEM_CODE IS NULL) THEN
	LP_PROBLEM_CODE :='AND 1=1';
END IF;
      IF (P_RESOLUTION_CODE IS NOT NULL) THEN
        LP_RESOLUTION_CODE := 'AND INC.Resolution_code =
                                                              :P_Resolution_code';
      END IF;
        IF (LP_RESOLUTION_CODE IS NULL) THEN
	LP_RESOLUTION_CODE :='AND 1=1';
END IF;
      IF (P_OWNER IS NOT NULL) THEN
        LP_OWNER := 'AND inc.owner =
                                                    :P_Owner';
      END IF;
 IF (LP_OWNER IS NULL) THEN
	LP_OWNER :='AND 1=1';
END IF;
      IF (P_STATUS IS NOT NULL) THEN
        LP_STATUS := 'AND inc.status_code =
                                                     :P_Status';
      END IF;
      IF (LP_STATUS IS NULL) THEN
	LP_STATUS :='AND 1=1';
END IF;
      IF (P_LOGGED_BY IS NOT NULL) THEN
        LP_LOGGEDBY := 'AND inc.logged_by_name =
                                                       :P_logged_by';
      END IF;
       IF (LP_LOGGEDBY IS NULL) THEN
	LP_LOGGEDBY :='AND 1=1';
END IF;
      IF (P_CLOSED_DATE IS NOT NULL) THEN
        LP_CLOSEDDATE := 'AND trunc(INC.date_closed) = ' || '''' || P_CLOSED_DATE || '''';
      END IF;
       IF (LP_CLOSEDDATE IS NULL) THEN
	LP_CLOSEDDATE :='AND 1=1';
END IF;
      IF (P_CLOSED_FLAG IS NOT NULL) THEN
        LP_CLOSED_FLAG := 'AND inc.closed_flag =
                                                          :P_closed_flag';
      END IF;
         IF (LP_CLOSED_FLAG IS NULL) THEN
	LP_CLOSED_FLAG :='AND 1=1';
END IF;
      IF (P_SR_NOTES_STATUS IS NOT NULL) THEN
        LP_SR_NOTES_STATUS := 'AND jtf_sr.status_code =
                                                              :p_sr_notes_status';
      END IF;
      IF (P_TASK_NOTES_STATUS IS NOT NULL) THEN
        LP_TASK_NOTES_STATUS := 'AND jtf_task.status_code =
                                                                :p_task_notes_status';
      END IF;
      RETURN (TRUE);
    END;
    RETURN NULL;
  END AFTERPFORM;

  FUNCTION AFTERPARAMFORM RETURN BOOLEAN IS
  BEGIN
    IF (P_REQUEST_LOW IS NOT NULL) AND (P_REQUEST_HIGH IS NOT NULL) THEN
      LP_REQUEST_NUMBER := 'AND (INC.incident_number BETWEEN ' || '''' || P_REQUEST_LOW || '''' || ' AND ' || '''' || P_REQUEST_HIGH || '''' || ')';
    ELSIF (P_REQUEST_LOW IS NOT NULL) THEN
      LP_REQUEST_NUMBER := 'AND INC.incident_number >= ' || '''' || P_REQUEST_LOW || '''' || '';
    ELSIF (P_REQUEST_HIGH IS NOT NULL) THEN
      LP_REQUEST_NUMBER := 'AND INC.incident_number <= ' || '''' || P_REQUEST_HIGH || '''' || '';
    ELSE
      LP_REQUEST_NUMBER := 'AND INC.incident_number like ' || '''%%''' || '';
    END IF;
    IF (LP_REQUEST_NUMBER IS NULL) THEN
    LP_REQUEST_NUMBER := 'AND 1=1';
    END IF;
    IF (AFTERPFORM) THEN
      NULL;
    END IF;
    RETURN (TRUE);
  END AFTERPARAMFORM;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      STATEMENT1 VARCHAR2(80);
      STATEMENT2 VARCHAR2(80);
    BEGIN
      BEGIN
        P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
        /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          /*SRW.MESSAGE(1
                     ,'srw_init')*/NULL;
      END;
      BEGIN
        /*SRW.REFERENCE(P_ORGANIZATION_ID)*/NULL;
        P_ORGANIZATION_ID := FND_PROFILE.VALUE('SO_ORGANIZATION_ID');
      END;
      BEGIN
        /*SRW.REFERENCE(P_ITEM_STRUCT_NUM)*/NULL;
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          /*SRW.MESSAGE(2
                     ,'Item Flex Select failed in before report trigger')*/NULL;
          RAISE;
      END;
      BEGIN
        /*SRW.REFERENCE(P_ITEM_STRUCT_NUM)*/NULL;
        /*SRW.REFERENCE(P_FLEX_ITEM_CODE)*/NULL;
        IF (P_ITEM_LOW IS NOT NULL) AND (P_ITEM_HIGH IS NOT NULL) THEN
          P_ITEM_WHERE := ' AND ' || P_ITEM_WHERE;
        ELSIF (P_ITEM_LOW IS NOT NULL) AND (P_ITEM_HIGH IS NULL) THEN
          P_ITEM_WHERE := ' AND ' || P_ITEM_WHERE;
        ELSIF (P_ITEM_LOW IS NULL) AND (P_ITEM_HIGH IS NOT NULL) THEN
          P_ITEM_WHERE := ' AND ' || P_ITEM_WHERE;
        ELSE
          NULL;
        END IF;
	 IF (P_ITEM_WHERE IS NULL) THEN
	P_ITEM_WHERE :='AND 1=1';
END IF;
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          /*SRW.MESSAGE(3
                     ,'Item Flex Where failed in before report trigger')*/NULL;
          RAISE;
      END;
      BEGIN
        /*SRW.REFERENCE(P_USER_ID)*/NULL;
        P_USER_ID := FND_GLOBAL.USER_ID;
      END;
      CS_GET_COMPANY_NAME(RP_COMPANY_NAME
                         ,P_SOB_ID);
      CS_GET_REPORT_NAME(RP_REPORT_NAME
                        ,P_CONC_REQUEST_ID
                        ,'Service Request SUmmary Report');
    END;
RP_REPORT_NAME := substr(RP_REPORT_NAME,1,instr(RP_REPORT_NAME,' (XML)'));

    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_REPORT_NAME;
  END RP_REPORT_NAME_P;

  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_COMPANY_NAME;
  END RP_COMPANY_NAME_P;

  /*PROCEDURE PUT(NAME IN VARCHAR2
               ,VAL IN VARCHAR2) IS
  BEGIN
    STPROC.INIT('begin FND_PROFILE.PUT(:NAME, :VAL); end;');
    STPROC.BIND_I(NAME);
    STPROC.BIND_I(VAL);
    STPROC.EXECUTE;
  END PUT;*/

/*  FUNCTION DEFINED(NAME IN VARCHAR2) RETURN BOOLEAN IS
    X0 BOOLEAN;
  BEGIN
    STPROC.INIT('declare X0rv BOOLEAN; begin X0rv := FND_PROFILE.DEFINED(:NAME); :X0 := sys.diutil.bool_to_int(X0rv); end;');
    STPROC.BIND_I(NAME);
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,X0);
    RETURN X0;
  END DEFINED;*/

/*  PROCEDURE GET(NAME IN VARCHAR2
               ,VAL OUT NOCOPY VARCHAR2) IS
  BEGIN
    STPROC.INIT('begin FND_PROFILE.GET(:NAME, :VAL); end;');
    STPROC.BIND_I(NAME);
    STPROC.BIND_O(VAL);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,VAL);
  END GET;*/

/*  FUNCTION VALUE(NAME IN VARCHAR2) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    STPROC.INIT('begin :X0 := FND_PROFILE.VALUE(:NAME); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(NAME);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;
  END VALUE;
*/
/*  FUNCTION VALUE_WNPS(NAME IN VARCHAR2) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    STPROC.INIT('begin :X0 := FND_PROFILE.VALUE_WNPS(:NAME); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(NAME);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;
  END VALUE_WNPS;*/

/*  FUNCTION SAVE_USER(X_NAME IN VARCHAR2
                    ,X_VALUE IN VARCHAR2) RETURN BOOLEAN IS
    X0 BOOLEAN;
  BEGIN
    STPROC.INIT('declare X0rv BOOLEAN; begin X0rv := FND_PROFILE.SAVE_USER(:X_NAME, :X_VALUE); :X0 := sys.diutil.bool_to_int(X0rv); end;');
    STPROC.BIND_I(X_NAME);
    STPROC.BIND_I(X_VALUE);
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(3
                   ,X0);
    RETURN X0;
  END SAVE_USER;*/

/*  FUNCTION SAVE(X_NAME IN VARCHAR2
               ,X_VALUE IN VARCHAR2
               ,X_LEVEL_NAME IN VARCHAR2
               ,X_LEVEL_VALUE IN VARCHAR2
               ,X_LEVEL_VALUE_APP_ID IN VARCHAR2) RETURN BOOLEAN IS
    X0 BOOLEAN;
  BEGIN
    STPROC.INIT('declare X0rv BOOLEAN; begin X0rv := FND_PROFILE.SAVE(:X_NAME, :X_VALUE, :X_LEVEL_NAME, :X_LEVEL_VALUE, :X_LEVEL_VALUE_APP_ID); :X0 := sys.diutil.bool_to_int(X0rv); end;');
    STPROC.BIND_I(X_NAME);
    STPROC.BIND_I(X_VALUE);
    STPROC.BIND_I(X_LEVEL_NAME);
    STPROC.BIND_I(X_LEVEL_VALUE);
    STPROC.BIND_I(X_LEVEL_VALUE_APP_ID);
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(6
                   ,X0);
    RETURN X0;
  END SAVE;*/

/*  PROCEDURE GET_SPECIFIC(NAME_Z IN VARCHAR2
                        ,USER_ID_Z IN NUMBER
                        ,RESPONSIBILITY_ID_Z IN NUMBER
                        ,APPLICATION_ID_Z IN NUMBER
                        ,VAL_Z OUT NOCOPY VARCHAR2
                        ,DEFINED_Z OUT NOCOPY BOOLEAN) IS
  BEGIN
    STPROC.INIT('declare DEFINED_Z BOOLEAN; begin DEFINED_Z := sys.diutil.int_to_bool(:DEFINED_Z); FND_PROFILE.GET_SPECIFIC(:NAME_Z, :USER_ID_Z, :RESPONSIBILITY_ID_Z, :APPLICATION_ID_Z, :VAL_Z, DEFINED_Z);
	:DEFINED_Z := sys.diutil.bool_to_int(DEFINED_Z); end;');
    STPROC.BIND_O(DEFINED_Z);
    STPROC.BIND_I(NAME_Z);
    STPROC.BIND_I(USER_ID_Z);
    STPROC.BIND_I(RESPONSIBILITY_ID_Z);
    STPROC.BIND_I(APPLICATION_ID_Z);
    STPROC.BIND_O(VAL_Z);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,DEFINED_Z);
    STPROC.RETRIEVE(6
                   ,VAL_Z);
  END GET_SPECIFIC;*/

/*  FUNCTION VALUE_SPECIFIC(NAME IN VARCHAR2
                         ,USER_ID IN NUMBER
                         ,RESPONSIBILITY_ID IN NUMBER
                         ,APPLICATION_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    STPROC.INIT('begin :X0 := FND_PROFILE.VALUE_SPECIFIC(:NAME, :USER_ID, :RESPONSIBILITY_ID, :APPLICATION_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(NAME);
    STPROC.BIND_I(USER_ID);
    STPROC.BIND_I(RESPONSIBILITY_ID);
    STPROC.BIND_I(APPLICATION_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;
  END VALUE_SPECIFIC;*/

/*  PROCEDURE INITIALIZE(USER_ID_Z IN NUMBER
                      ,RESPONSIBILITY_ID_Z IN NUMBER
                      ,APPLICATION_ID_Z IN NUMBER
                      ,SITE_ID_Z IN NUMBER) IS
  BEGIN
    STPROC.INIT('begin FND_PROFILE.INITIALIZE(:USER_ID_Z, :RESPONSIBILITY_ID_Z, :APPLICATION_ID_Z, :SITE_ID_Z); end;');
    STPROC.BIND_I(USER_ID_Z);
    STPROC.BIND_I(RESPONSIBILITY_ID_Z);
    STPROC.BIND_I(APPLICATION_ID_Z);
    STPROC.BIND_I(SITE_ID_Z);
    STPROC.EXECUTE;
  END INITIALIZE;*/

/*  PROCEDURE PUTMULTIPLE(NAMES IN VARCHAR2
                       ,VALS IN VARCHAR2
                       ,NUM IN NUMBER) IS
  BEGIN
    STPROC.INIT('begin FND_PROFILE.PUTMULTIPLE(:NAMES, :VALS, :NUM); end;');
    STPROC.BIND_I(NAMES);
    STPROC.BIND_I(VALS);
    STPROC.BIND_I(NUM);
    STPROC.EXECUTE;
  END PUTMULTIPLE;*/

  PROCEDURE CS_GET_COMPANY_NAME(RP_COMPANY_NAME IN OUT NOCOPY VARCHAR2
                               ,P_SOB_ID IN NUMBER) IS
  BEGIN
/*    STPROC.INIT('begin CS_REPORTS_PACKAGE.CS_GET_COMPANY_NAME(:RP_COMPANY_NAME, :P_SOB_ID); end;');
    STPROC.BIND_IO(RP_COMPANY_NAME);
    STPROC.BIND_I(P_SOB_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,RP_COMPANY_NAME);*/
begin
CS_REPORTS_PACKAGE.CS_GET_COMPANY_NAME(RP_COMPANY_NAME, P_SOB_ID);
end;


  END CS_GET_COMPANY_NAME;

  PROCEDURE CS_GET_REPORT_NAME(RP_REPORT_NAME IN OUT NOCOPY VARCHAR2
                              ,P_CONC_REQUEST_ID IN NUMBER
                              ,P_REPORT_NAME IN VARCHAR2) IS
  BEGIN
  /*  STPROC.INIT('begin CS_REPORTS_PACKAGE.CS_GET_REPORT_NAME(:RP_REPORT_NAME, :P_CONC_REQUEST_ID, :P_REPORT_NAME); end;');
    STPROC.BIND_IO(RP_REPORT_NAME);
    STPROC.BIND_I(P_CONC_REQUEST_ID);
    STPROC.BIND_I(P_REPORT_NAME);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,RP_REPORT_NAME);*/
		   begin
		   CS_REPORTS_PACKAGE.CS_GET_REPORT_NAME(RP_REPORT_NAME, P_CONC_REQUEST_ID, P_REPORT_NAME);
		   end;

  END CS_GET_REPORT_NAME;

/*  PROCEDURE GET_P_STRUCT_NUM(P_ITEM_STRUCT_NUM IN OUT NOCOPY VARCHAR2
                            ,RETURN_VALUE IN OUT NOCOPY NUMBER) IS
  BEGIN
    STPROC.INIT('begin CS_REPORTS_PACKAGE.GET_P_STRUCT_NUM(:P_ITEM_STRUCT_NUM, :RETURN_VALUE); end;');
    STPROC.BIND_IO(P_ITEM_STRUCT_NUM);
    STPROC.BIND_IO(RETURN_VALUE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,P_ITEM_STRUCT_NUM);
    STPROC.RETRIEVE(2
                   ,RETURN_VALUE);
  END GET_P_STRUCT_NUM;*/

END CS_CSXSRDET_XMLP_PKG;


/
