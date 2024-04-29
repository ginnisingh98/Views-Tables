--------------------------------------------------------
--  DDL for Package Body OM_SETUP_VALID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OM_SETUP_VALID_PKG" AS
-- $Header: OEXRSTVB.pls 115.27 2004/05/06 05:34:02 rmoharan ship $

-- Added for bug 3310908 - Start
  RESP_LIST   SARRAY := SARRAY();
  USER_LIST   SARRAY := SARRAY();
  APPS_LIST   SARRAY := SARRAY();
-- Added for bug 3310908 - End

PROCEDURE VALIDATE_MAIN (
		X_RETCODE 	OUT NOCOPY 	BOOLEAN,
		P_LEVEL		IN	VARCHAR2,
		P_VALUE		IN	VARCHAR2
	) IS
		flags		CHECK_FLAG;
		value		VARCHAR2(5):='FALSE';
		errLogged	BOOLEAN := FALSE;
		entity		VARCHAR2(100) := 'System';
		error_type	VARCHAR2(15) := 'ERROR';
		mesg_name	VARCHAR2(255):= 'ONT_SETVAL_INVALID_INPUT';
		ou		NUMBER;
BEGIN
                OE_DEBUG_PUB.ADD('Inside OEXRSTVB : Validate_Main');
		RESP_LIST := GENERATE_LIST_RESP( P_LEVEL, P_VALUE );
		IF ( P_LEVEL = 'RESP' AND (RESP_LIST(1) is null or RESP_LIST(1) = 0) ) THEN
			ou := getOperatingUnit( P_VALUE );
			errLogged := writeError( entity, P_LEVEL, P_VALUE, error_type, mesg_name ,
					null, null, null, null, null, null, null, null,
					null, null, null);
			X_RETCODE := TRUE;
			RETURN;
		END IF;
		OE_DEBUG_PUB.ADD('Validate_Main : Retrieved_Resp_List');
		OE_DEBUG_PUB.ADD('Resp_List count :'||RESP_lIST.COUNT);
		APPS_LIST := GENERATE_LIST_APPS;
		OE_DEBUG_PUB.ADD('Validate_Main : Retrieved_Apps_List');
		OE_DEBUG_PUB.ADD('Apps_List count :'||APPS_lIST.COUNT);
		USER_LIST := GENERATE_LIST_USER( P_LEVEL, P_VALUE );
		OE_DEBUG_PUB.ADD('Validate_Main : Retrieved_Use_List');
		OE_DEBUG_PUB.ADD('User_List count :'||USER_lIST.COUNT);
		flags :=  CHECK_FLAG (
				value, value, value, value, value,
				value, value, value, value, value,
				value, value, value, value, value,
				value, value
			  );
		IF ( P_LEVEL = 'USER' ) THEN

			flags(1)  := 'TRUE';
			flags(2)  := 'TRUE';
			flags(17) := 'TRUE';
		ELSIF ( (P_LEVEL = 'RESP' OR P_LEVEL = 'OU') ) THEN
			flags(1)  := 'TRUE';
			flags(2)  := 'TRUE';
			flags(3)  := 'TRUE';
			flags(4)  := 'TRUE';
			flags(7)  := 'TRUE';
			flags(8)  := 'TRUE';
			flags(9)  := 'TRUE';
			flags(10)  := 'TRUE';
			flags(11)  := 'TRUE';
			flags(12)  := 'TRUE';
			flags(13)  := 'TRUE';
			flags(14)  := 'TRUE';
			flags(15)  := 'TRUE';
			flags(16)  := 'TRUE';
		ELSIF ( P_LEVEL = 'INST') THEN
			value := 'TRUE';
			flags :=  CHECK_FLAG (
				value, value, value, value, value,
				value, value, value, value, value,
				value, value, value, value, value,
				value, value, value
			  );

		END IF;
		IF ( flags(1) = 'TRUE' ) THEN
			VALIDATE_PROFILE_OPTIONS( p_level, p_value );
		END IF;
		IF ( flags(2) = 'TRUE' ) THEN
			VALIDATE_USER_PROFILE_OPTIONS( p_level, p_value );
		END IF;
		IF ( flags(3) = 'TRUE' ) THEN
			VALIDATE_SET_OF_BOOKS_SETUP( p_level, p_value );
		END IF;
		IF ( flags(4) = 'TRUE' ) THEN
			VALIDATE_ITEM_VALID_ORG( p_level, p_value );
		END IF;
		IF ( flags(5) = 'TRUE' ) THEN
			VALIDATE_SALES_ORDER_KEYFLEX( p_level, p_value );
		END IF;
		IF ( flags(6) = 'TRUE' ) THEN
			VALIDATE_ITEM_CATALOGS_FLEX( p_level, p_value );
		END IF;
		IF ( flags(7) = 'TRUE' ) THEN
			VALIDATE_TRANSACTION_TYPES( p_level, p_value );
		END IF;
		IF ( flags(8) = 'TRUE' ) THEN
			VALIDATE_DOC_SEQ_SALES_ORDERS( p_level, p_value );
		END IF;
		IF ( flags(9) = 'TRUE' ) THEN
			VALIDATE_CREDIT_CHECKING( p_level, p_value );
		END IF;
		IF ( flags(10) = 'TRUE' ) THEN
			VALIDATE_ITEM_DEFINITION( p_level, p_value );
		END IF;
		IF ( flags(11) = 'TRUE' ) THEN
			VALIDATE_PRICE_LIST_DEFINITION( p_level, p_value );
		END IF;
		IF ( flags(12) = 'TRUE' ) THEN
			VALIDATE_SALES_CRDT_DEFINITION( p_level, p_value );
		END IF;
		IF ( flags(13) = 'TRUE' ) THEN
			VALIDATE_SHIPPING_ORGS( p_level, p_value );
		END IF;
		IF ( flags(14) = 'TRUE' ) THEN
			VALIDATE_PERIOD_STATUS( p_level, p_value );
		END IF;
		IF ( flags(15) = 'TRUE' ) THEN
			VALIDATE_FREIGHT_CARRIER( p_level, p_value );
		END IF;
		IF ( flags(16) = 'TRUE' ) THEN
			VALIDATE_DOC_SEQ_SHIPPING( p_level, p_value );
		END IF;
		IF ( flags(17) = 'TRUE' ) THEN
			VALIDATE_SHIPPING_GRANTS_ROLES( p_level, p_value );
		END IF;
		X_RETCODE := TRUE;
	EXCEPTION
		WHEN OTHERS THEN
			X_RETCODE := FALSE;
			RETURN;
	END VALIDATE_MAIN;
/***********************************************************************************************/
/** getOperatingUnit ***************************************************************************/
/***********************************************************************************************/
	FUNCTION getOperatingUnit ( resp_id NUMBER ) RETURN NUMBER AS
		oper_unit	NUMBER;
		prof_opt_id	NUMBER;

		prof_opt_val	VARCHAR2(255);
	BEGIN
		prof_opt_id  := getProfileOptionId('ORG_ID');
		IF ( prof_opt_id = null ) THEN
			RETURN -1;
		ELSE
			prof_opt_val := getProfileOptionValue( 10003, resp_id, prof_opt_id );

		END IF;
		IF ( prof_opt_val = null ) THEN
			RETURN -1;
		ELSE
			oper_unit    := to_number(prof_opt_val);
		END IF;

		RETURN oper_unit;
	END getOperatingUnit;
/***********************************************************************************************/
/** getProfileOptionId *************************************************************************/
/***********************************************************************************************/
	FUNCTION getProfileOptionId ( prof_opt_name VARCHAR2 ) RETURN NUMBER AS
		prof_opt_id	NUMBER;
	BEGIN
		SELECT FPO.PROFILE_OPTION_ID
		INTO prof_opt_id
		FROM FND_PROFILE_OPTIONS FPO, FND_PROFILE_OPTIONS_TL FPOT
		WHERE FPO.PROFILE_OPTION_NAME = FPOT.PROFILE_OPTION_NAME
		AND FPOT.LANGUAGE=USERENV('LANG')
		AND FPOT.PROFILE_OPTION_NAME LIKE prof_opt_name;
		RETURN prof_opt_id;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN -1;
	END getProfileOptionId;
/***********************************************************************************************/
/** getProfOptName *************************************************************************/
/***********************************************************************************************/
	FUNCTION getProfOptName ( prof_opt_name VARCHAR2 ) RETURN VARCHAR2 AS
		user_prof_opt_name	VARCHAR2(255);
	BEGIN
		SELECT FPOT.USER_PROFILE_OPTION_NAME
		INTO user_prof_opt_name
		FROM FND_PROFILE_OPTIONS_TL FPOT
		WHERE FPOT.LANGUAGE=USERENV('LANG')
		AND FPOT.PROFILE_OPTION_NAME LIKE prof_opt_name;
		RETURN user_prof_opt_name;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN -1;
	END getProfOptName;
/***********************************************************************************************/
/** getProfileOptionValue **********************************************************************/
/***********************************************************************************************/
	FUNCTION getProfileOptionValue (
			lvl_id		VARCHAR2,
			lvl_value	VARCHAR2,
			prof_opt_id	NUMBER
	) RETURN VARCHAR2 AS
		prof_opt_val	VARCHAR2(255);
	BEGIN
		IF (lvl_id = '10001') THEN
			SELECT PROFILE_OPTION_VALUE
			INTO prof_opt_val
			FROM FND_PROFILE_OPTION_VALUES
			WHERE PROFILE_OPTION_ID = prof_opt_id
			AND LEVEL_ID = lvl_id
			AND ROWNUM < 2;
		ELSE
			SELECT PROFILE_OPTION_VALUE
			INTO prof_opt_val
			FROM FND_PROFILE_OPTION_VALUES
			WHERE PROFILE_OPTION_ID = prof_opt_id
			AND LEVEL_ID = lvl_id
			AND LEVEL_VALUE = lvl_value
			AND ROWNUM < 2;
		END IF;
		RETURN prof_opt_val;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN -1;
	WHEN OTHERS THEN
		RETURN -1;
	END getProfileOptionValue;
/***********************************************************************************************/
/** getRespForUser *****************************************************************************/
/***********************************************************************************************/
	FUNCTION getRespForUser ( user_id NUMBER ) RETURN SARRAY AS
		resp_id		NUMBER;
		resps		SARRAY:= SARRAY();
		CURSOR resp_cursor IS
			SELECT USER_ID, RESPONSIBILITY_ID
			FROM FND_USER_RESP_GROUPS;
		resp 		resp_cursor%ROWTYPE;
		indx		NUMBER;
	BEGIN
		indx 	:= 1;
		resps.extend(1000);
		OPEN resp_cursor;
		LOOP
			FETCH resp_cursor INTO resp;
			EXIT WHEN resp_cursor%NOTFOUND;
			IF resp.USER_ID = user_id THEN
				resps(indx) := resp.RESPONSIBILITY_ID;
				indx := indx + 1;
				IF ( mod(indx,1000) = 999 ) THEN
				   resps.extend(1000);
				END IF;
			END IF;
		END LOOP;
		resps(indx) := -1;
		RETURN resps;
	END getRespForUser;
/***********************************************************************************************/
/** getResps ***********************************************************************************/
/***********************************************************************************************/
	FUNCTION getResps RETURN NUMARRAY AS
		prof_opt_val	VARCHAR2(255);
		resps		NUMARRAY:= NUMARRAY();
		CURSOR resp_cursor IS
			SELECT RESPONSIBILITY_ID
			FROM FND_RESPONSIBILITY;
		resp 		resp_cursor%ROWTYPE;
		indx		NUMBER;
	BEGIN
		indx 	:= 1;
		resps.extend(1000);
		OPEN resp_cursor;
		LOOP
			FETCH resp_cursor INTO resp;
			EXIT WHEN resp_cursor%NOTFOUND;
			resps(indx) := resp.RESPONSIBILITY_ID;
			indx := indx + 1;
			IF ( mod(indx,1000) = 999 ) THEN
			   resps.extend(1000);
			END IF;
		END LOOP;
		resps(indx) := -1;
		RETURN resps;
	END getResps;
/***********************************************************************************************/
/** getUsers ***********************************************************************************/
/***********************************************************************************************/
--NOT Being Used anymore
/*	FUNCTION getUsers RETURN NUMARRAY AS
		users		NUMARRAY:= NUMARRAY();
		CURSOR usr_cursor IS
			SELECT USER_ID
			FROM FND_USER;
		usr 		usr_cursor%ROWTYPE;
		indx		NUMBER;
	BEGIN
		indx 	:= 1;
		users.extend(1000);
		OPEN usr_cursor;
		LOOP
			FETCH usr_cursor INTO usr;
			EXIT WHEN usr_cursor%NOTFOUND;
			users(indx) := usr.USER_ID;
			indx := indx + 1;
			IF ( mod(indx,1000) = 999 ) THEN
			   users.extend(1000);
			END IF;
		END LOOP;
		users(indx) := -1;
		RETURN users;
	END getUsers;
*/


/***********************************************************************************************/
/** getUserName ********************************************************************************/
/***********************************************************************************************/
	FUNCTION getUserName ( userid NUMBER ) RETURN VARCHAR2 AS
		username	VARCHAR2(255);
	BEGIN
		SELECT USER_NAME
		INTO username
		FROM FND_USER
		WHERE USER_ID = userid;
		RETURN username;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN -1;
	END;
/***********************************************************************************************/
/** getUserName ********************************************************************************/
/***********************************************************************************************/
	FUNCTION getOuName ( ouid NUMBER ) RETURN VARCHAR2 AS
		ouname	VARCHAR2(255);
	BEGIN
		SELECT NAME
		INTO ouname
		FROM HR_ALL_ORGANIZATION_UNITS_TL
		WHERE ORGANIZATION_ID = ouid
		AND LANGUAGE = USERENV('LANG');
		RETURN ouname;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN -1;
	END;

/***********************************************************************************************/
/** getTtypeName *******************************************************************************/
/***********************************************************************************************/
	FUNCTION getTtypeName ( ttypeid NUMBER ) RETURN VARCHAR2 AS
		ttypename	VARCHAR2(255);
	BEGIN
		SELECT NAME
		INTO ttypename
		FROM OE_TRANSACTION_TYPES_TL
		WHERE TRANSACTION_TYPE_ID = ttypeid
		AND LANGUAGE=USERENV('LANG');
		RETURN ttypename;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN -1;
	END;
/***********************************************************************************************/
/** getRespName ********************************************************************************/
/***********************************************************************************************/
	FUNCTION getRespName ( resp_id NUMBER ) RETURN VARCHAR2 AS
		resp_name	VARCHAR2(255);
	BEGIN
		BEGIN
			SELECT RESPONSIBILITY_NAME
			INTO resp_name
			FROM FND_RESPONSIBILITY_TL
			WHERE RESPONSIBILITY_ID = resp_id
			AND LANGUAGE=USERENV('LANG');
			RETURN resp_name;
		EXCEPTION
		WHEN OTHERS THEN
			RETURN -1;
		END;
	END getRespName;
/***********************************************************************************************/
/** getAppsName ********************************************************************************/
/***********************************************************************************************/
	FUNCTION getAppsName ( appl_id NUMBER ) RETURN VARCHAR2 AS
		appl_name	VARCHAR2(255);
	BEGIN
		BEGIN
			SELECT APPLICATION_NAME
			INTO appl_name
			FROM FND_APPLICATION_TL
			WHERE APPLICATION_ID = appl_id
			AND LANGUAGE=USERENV('LANG');
			RETURN appl_name;
		EXCEPTION
		WHEN OTHERS THEN
			RETURN -1;
		END;
	END getAppsName;
/***********************************************************************************************/
/** getShippingOrgsForOu ***********************************************************************/
/***********************************************************************************************/
	FUNCTION getShippingOrgsForOu(ou NUMBER) RETURN SARRAY AS
		/* Array Variables */
		shiporgs	SARRAY := SARRAY();
		/* Counter Variables */
		ind		NUMBER := 1;
		/* Cursor Variables */
		CURSOR shorgs(ou NUMBER) IS
			SELECT  ORGANIZATION_ID
			FROM    WSH_SHIPPING_PARAMETERS
			WHERE   ORGANIZATION_ID IN (
			SELECT 	HOU.ORGANIZATION_ID ORGANIZATION_ID
			FROM 	HR_ORGANIZATION_UNITS HOU,
				HR_ORGANIZATION_INFORMATION HOI,
				FND_PRODUCT_GROUPS FPG
			WHERE 	HOU.ORGANIZATION_ID = HOI.ORGANIZATION_ID
			AND     DECODE ( FPG.MULTI_ORG_FLAG, 'Y',
				DECODE (HOI.ORG_INFORMATION_CONTEXT, 'Accounting Information',
						TO_NUMBER(HOI.ORG_INFORMATION3), TO_NUMBER(NULL)
						), TO_NUMBER(NULL)
					) = ou
			);
			shorg		shorgs%ROWTYPE;
	BEGIN
		shiporgs.extend(100000);
		OPEN shorgs(ou);
		FETCH shorgs INTO shorg;
		LOOP
			shiporgs(ind) := shorg.ORGANIZATION_ID;
			ind := ind + 1;
			IF ( mod(ind,1000) = 999 ) THEN
			   shiporgs.extend(1000);
			END IF;
			FETCH shorgs INTO shorg;
			EXIT WHEN shorgs%NOTFOUND;

		END LOOP;
		RETURN trimArray(shiporgs);
	END getShippingOrgsForOu;
/***********************************************************************************************/
/** getRespListForForm  ************************************************************************/
/***********************************************************************************************/
	FUNCTION getRespListForForm
	(
	  p_form_name    VARCHAR2
	, p_description  VARCHAR2
	, p_application  VARCHAR2
	)
	RETURN SARRAY
	AS
	  l_function_list  SARRAY := SARRAY();
	  l_function_id    NUMBER;
	  l_menu_list      SARRAY := SARRAY();
	  l_resp_list      SARRAY := SARRAY();
	  l_temp_list      SARRAY := SARRAY();
 	  l_ctr_j          NUMBER := 1;
	  l_index          NUMBER := 1;
	  l_form_name      VARCHAR2(100);
	  l_description    VARCHAR2(100);
	  l_application    VARCHAR2(10);
	  l_isdouble        BOOLEAN;
	BEGIN
	  l_form_name := p_form_name;
	  l_description := p_description;
	  l_application := p_application;
	  l_function_list := getFormFunctionId(l_form_name,l_application,l_description);
          OE_DEBUG_PUB.ADD('Inside Get_Resp_List_For_Form : fn list count :');
          OE_DEBUG_PUB.ADD(l_function_list.COUNT);
	  FOR k IN 1..l_function_list.COUNT
	  LOOP
	    l_function_id := l_function_list(k);
	    l_menu_list   := getAllMenus(l_function_id);
	    l_temp_list   := getRespListFromMenus(l_menu_list);
	    l_resp_list.extend(l_temp_list.COUNT);
	    FOR i IN 1..l_temp_list.COUNT
	    LOOP
	      l_isdouble:=FALSE;
	      l_ctr_j:=1;
	      WHILE (l_ctr_j < i)
	      LOOP
	        IF (l_temp_list(i) = l_temp_list(l_ctr_j)) THEN
                  l_isdouble:=TRUE;
                  EXIT;
	        END IF;
	        l_ctr_j:=l_ctr_j+1;
	      END LOOP;
              IF (l_isdouble=FALSE) THEN
                l_resp_list(l_index):=l_temp_list(i);
                l_index:=l_index+1;
              END IF;
            END LOOP;
	  END LOOP;
	  RETURN l_resp_list;
	END getRespListForForm;
/***********************************************************************************************/
/** getRespListFromMenus  **********************************************************************/
/***********************************************************************************************/
	FUNCTION getRespListFromMenus ( menus SARRAY ) RETURN SARRAY AS
	CURSOR resp_get IS
		SELECT MENU_ID, RESPONSIBILITY_ID
		FROM FND_RESPONSIBILITY;
		rget		resp_get%ROWTYPE;
		ind		NUMBER := 1;
		counter 	NUMBER := 1;
		ctr 		NUMBER := 1;
		resps		SARRAY := SARRAY();
		menu_id		NUMBER := 0;
	BEGIN
		resps.extend(1000);
		FOR i IN 1..menus.COUNT
		LOOP
			IF ( menus(i) IS NULL ) THEN
				EXIT;
			END IF;
			ctr := ctr + 1;
		END LOOP;
		FOR i IN 1..ctr
		LOOP
			SELECT to_number(menus(i))
			INTO menu_id
			FROM DUAL;
			OPEN resp_get;
			FETCH resp_get INTO rget;
			LOOP
				IF ( rget.MENU_ID = menu_id ) THEN
					resps(ind) := rget.RESPONSIBILITY_ID;
					ind := ind + 1;
					IF ( MOD(ind,1000) = 999 ) THEN
					    resps.extend(1000);
					END IF;
				END IF;
				FETCH resp_get INTO rget;
				EXIT WHEN resp_get%NOTFOUND;
			END LOOP;
			CLOSE resp_get;
		END LOOP;
		FOR i IN 1..resps.COUNT
		LOOP
			IF resps(i) IS NULL THEN
				EXIT;
			END IF;
			counter := counter + 1;
		END LOOP;
		RETURN( trimArray( resps ) );
	END getRespListFromMenus;
/***********************************************************************************************/
/** getSubMenus  *******************************************************************************/
/***********************************************************************************************/
	FUNCTION getSubMenus( menu_id NUMBER ) RETURN SARRAY AS
		CURSOR sub_menus( submenu_id IN NUMBER ) IS
			SELECT menu_id
			FROM FND_MENU_ENTRIES
			WHERE SUB_MENU_ID = submenu_id;
		smenus 	sub_menus%ROWTYPE;
		menus 	SARRAY := SARRAY();
		ind	NUMBER:=1;
	BEGIN
		OPEN sub_menus( menu_id );
		FETCH sub_menus INTO smenus;
		menus.extend(1000);
		LOOP
			menus(ind) := smenus.menu_id;
			ind := ind + 1;
			IF ( MOD(ind,1000) = 999 ) THEN
			    menus.extend(1000);
			END IF;
			FETCH sub_menus INTO smenus;
			EXIT WHEN sub_menus%NOTFOUND;
		END LOOP;
		menus := trimArray( menus );
		RETURN menus;
	END getSubMenus;
/***********************************************************************************************/
/** getUniqueList  *****************************************************************************/
/***********************************************************************************************/
	FUNCTION getUniqueList( list SARRAY ) RETURN SARRAY AS
			unique_list	SARRAY := SARRAY();
			uctr		NUMBER := 1;
			isdouble	BOOLEAN := FALSE;
	 BEGIN
		unique_list.extend(list.COUNT);
		FOR j IN 1..list.COUNT
		LOOP
			FOR i IN 1..j
			LOOP
				IF ( list(j) = unique_list(i) ) THEN
					isdouble := TRUE;
				END IF;
			END LOOP;
			IF isdouble = FALSE THEN
				unique_list(uctr) := list(j);
				uctr := uctr + 1;
			END IF;
			isdouble := FALSE;
		END LOOP;
		RETURN( trimArray(unique_list) );
	 END getUniqueList;
/***********************************************************************************************/
/** isNumeric  *********************************************************************************/
/***********************************************************************************************/
	 FUNCTION isNumeric ( myStr  VARCHAR2 ) RETURN BOOLEAN AS
		myNbr		NUMBER;
	 BEGIN
		myNbr	 := to_number(myStr);
		RETURN TRUE;
	 EXCEPTION
	 WHEN OTHERS THEN
		IF ( SQLCODE = '-6502' ) THEN
			RETURN FALSE;
		END IF;
	END isNumeric;
/***********************************************************************************************/
/** trimArray  *********************************************************************************/
/***********************************************************************************************/
	FUNCTION trimArray (
		in_array	SARRAY
	) RETURN SARRAY AS
		out_array	SARRAY := SARRAY();
		out_ctr		NUMBER := 0;
		out_idx		NUMBER := 1;
	BEGIN
		FOR i IN 1..in_array.COUNT
		LOOP
			IF ( in_array(i) IS NOT NULL ) THEN
				out_ctr := out_ctr + 1;
			END IF;
		END LOOP;
		out_array.extend(out_ctr);
		FOR i IN 1..in_array.COUNT
		LOOP
			IF ( in_array(i) IS NOT NULL ) THEN
				out_array(out_idx) := in_array(i);
				out_idx := out_idx + 1;
			END IF;
		END LOOP;
		RETURN out_array;
	END trimArray;
/***********************************************************************************************/
/** writeError  ********************************************************************************/
/***********************************************************************************************/
	FUNCTION writeError (
			ENTITY			VARCHAR2,
			P_LEVEL			VARCHAR2,
			P_VALUE			VARCHAR2,
			ERROR_TYPE		VARCHAR2,
			MESG_NAME		VARCHAR2,
			TYPE			VARCHAR2,
			USER_NAME		VARCHAR2,
			OPERATING_UNIT		VARCHAR2,
			ORGANIZATION_ID		VARCHAR2,
			SET_OF_BOOKS_AR 	VARCHAR2,
			SET_OF_BOOKS		VARCHAR2,
			SET_OF_BOOKS_PF 	VARCHAR2,
			PROFILE_OPTION		VARCHAR2,
			TRANSACT_TYPE		VARCHAR2,
			DOC_CATEGORY		VARCHAR2,
			PAYMENT_TERM		VARCHAR2
	) RETURN BOOLEAN AS
		TEMP		VARCHAR2(100);
		P_F_LEVEL	VARCHAR2(100);
		P_F_VALUE	VARCHAR2(100);
	BEGIN
		IF ( P_LEVEL = 'OU' ) THEN
			P_F_LEVEL := 'Operating Unit';
			P_F_VALUE := getOuName(to_number(P_VALUE));
		ELSIF ( P_LEVEL = 'RESP' ) THEN
			P_F_LEVEL := 'Responsibility';
			P_F_VALUE := getRespName(to_number(P_VALUE));
		ELSIF ( P_LEVEL = 'USER' ) THEN
			P_F_LEVEL := 'User';
			P_F_VALUE := getUserName(to_number(P_VALUE));
		ELSIF ( P_LEVEL = 'INST' ) THEN
			P_F_LEVEL := 'Instance';
		END IF;
		INSERT INTO OM_SETUP_VALID_REP
		( ENTITY, P_LEVEL, P_VALUE, ERROR_TYPE,
		  MESG_NAME, TYPE, USER_NAME, OPERATING_UNIT,
		  ORGANIZATION, SET_OF_BOOKS_AR, SET_OF_BOOKS,
		  SET_OF_BOOKS_PF, PROFILE_OPTION, TRANSACT_TYPE,
		  DOC_CATEGORY, PAYMENT_TERM
		)
		VALUES
		( ENTITY, P_F_LEVEL, P_F_VALUE, ERROR_TYPE,
		  MESG_NAME, TYPE, USER_NAME, OPERATING_UNIT,
		  ORGANIZATION_ID, SET_OF_BOOKS_AR, SET_OF_BOOKS,
		  SET_OF_BOOKS_PF, PROFILE_OPTION, TRANSACT_TYPE,
		  DOC_CATEGORY, PAYMENT_TERM
		);
		RETURN TRUE;
	EXCEPTION
	WHEN OTHERS THEN
		RETURN FALSE;
	END writeError;
/***********************************************************************************************/
/** addArrayToArr  *****************************************************************************/
/***********************************************************************************************/
	FUNCTION addArrayToArr (
		IN_ARRAY	SARRAY,
		AD_ARRAY	SARRAY
	)RETURN SARRAY AS
		OUT_ARRAY	SARRAY := SARRAY();
		ARRAY_IN	SARRAY := SARRAY();
		ARRAY_AD	SARRAY := SARRAY();
		COUNT_TOT	NUMBER := 0;
		COUNT_IN	NUMBER := 0;
		COUNT_AD	NUMBER := 0;
		k		NUMBER := 0;
	BEGIN
		ARRAY_IN  := trimArray( IN_ARRAY );
		ARRAY_AD  := trimArray( AD_ARRAY );
		COUNT_IN  := ARRAY_IN.COUNT;
		COUNT_AD  := ARRAY_AD.COUNT;
		COUNT_TOT := COUNT_IN + COUNT_AD;
		OUT_ARRAY.extend(COUNT_TOT);
		FOR i IN 1..COUNT_IN
		LOOP
			OUT_ARRAY(i) := IN_ARRAY(i);
		END LOOP;
		FOR i IN COUNT_IN+1..COUNT_TOT
		LOOP
			k := i-COUNT_IN;
			OUT_ARRAY(i) := AD_ARRAY(k);
		END LOOP;
		RETURN( OUT_ARRAY );
	END addArrayToArr;
/***********************************************************************************************/
/** checkForOMResp  ****************************************************************************/
/***********************************************************************************************/
	FUNCTION checkForOMResp( user_id NUMBER ) RETURN BOOLEAN AS
		resp_id		NUMBER;
	BEGIN
		SELECT RESPONSIBILITY_ID
		INTO resp_id
		FROM FND_USER_RESP_GROUPS
		WHERE USER_ID = user_id
		AND RESPONSIBILITY_APPLICATION_ID = 660
		AND ROWNUM < 2;
		RETURN TRUE;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;
	END checkForOMResp;
/***********************************************************************************************/
/** checkForOMResp  ****************************************************************************/
/***********************************************************************************************/
	FUNCTION checkForOmOu( oper_unit NUMBER ) RETURN BOOLEAN AS
		orgcount	NUMBER;
	BEGIN
                -- Sys Param Change
                -- Table OE_SYSTEM_PARAMETERS_ALL is replace by OE_SYS_PARAMETERS_ALL
		SELECT COUNT(ORG_ID)
		INTO orgcount
		FROM OE_SYS_PARAMETERS_ALL
		WHERE ORG_ID = oper_unit;
		IF orgcount = 0 THEN
			RETURN FALSE;
		ELSE
			RETURN TRUE;
		END IF;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;
	END checkForOmOu;
/***********************************************************************************************/
/** getAllMenus  *******************************************************************************/
/***********************************************************************************************/
	FUNCTION getAllMenus( func_id NUMBER ) RETURN SARRAY AS
		menu_tmp_arr	SARRAY := SARRAY();
		menu_fin_arr	SARRAY := SARRAY();
		menu_sub_arr	SARRAY := SARRAY();
		menu_rec_arr	SARRAY := SARRAY();
		ctr		NUMBER := 1;
		i		NUMBER := 1;
		fin_idx		NUMBER := 1;
	BEGIN
		menu_tmp_arr.extend(1000);
		--menu_fin_arr.extend(1000);
		menu_rec_arr := getMenus(func_id);
		FOR j IN 1..menu_rec_arr.COUNT
		LOOP
			menu_tmp_arr(j) := menu_rec_arr(j);
		END LOOP;
		WHILE ( menu_tmp_arr(i) IS NOT NULL )
		LOOP
			menu_sub_arr := getSubMenus(menu_tmp_arr(i));
			IF ( menu_sub_arr.COUNT > 0 ) THEN
				menu_rec_arr := addArrayToArr( menu_tmp_arr, menu_sub_arr );
				FOR j IN 1..menu_rec_arr.COUNT
				LOOP
					menu_tmp_arr(j) := menu_rec_arr(j);
					IF ( MOD(j,1000)=999 ) THEN
					    menu_tmp_arr.extend(1000);
					END IF;
				END LOOP;
		/**********************************************************/
		/* -- Commented for Set of Books Validation Bug.----------
			ELSE
				menu_fin_arr(fin_idx) := menu_tmp_arr(i);
				fin_idx := fin_idx + 1;
		---------------------------------------------------------*/
		/**********************************************************/
			END IF;
			i := i + 1;
		END LOOP;
		RETURN menu_tmp_arr;
	END getAllMenus;
/***********************************************************************************************/
/** GENERATE_LIST_APPS  ************************************************************************/
/***********************************************************************************************/
	FUNCTION GENERATE_LIST_APPS RETURN SARRAY AS
	CURSOR ALL_APPS(resp_id IN NUMBER) IS
		SELECT APPLICATION_ID
		FROM FND_RESPONSIBILITY
		WHERE RESPONSIBILITY_ID=resp_id;
		ctr		NUMBER := 1;
		j 		NUMBER := 1;
		apps_all	ALL_APPS%ROWTYPE;
                --
                -- Bug 3537496 : Modified by NKILLEDA
                --   Changed the variable name from 'apps' to l_apps for GSCC
                --   compliance. the specific rule is file.sql.6.
                --
                l_apps		SARRAY := SARRAY();
		isdouble	BOOLEAN := FALSE;
		isFound		BOOLEAN := FALSE;
		TEMP_LIST	SARRAY := SARRAY();
	BEGIN
		l_apps.extend(1000);
		FOR i IN 1..RESP_LIST.COUNT
		LOOP
			OPEN ALL_APPS(RESP_LIST(i));
			FETCH ALL_APPS INTO apps_all;
			LOOP
				l_apps(ctr) := apps_all.APPLICATION_ID;
				ctr := ctr + 1;
				IF ( MOD(ctr,1000)=999 ) THEN
				    l_apps.extend(1000);
				END IF;
				FETCH ALL_APPS INTO apps_all;
				EXIT WHEN ALL_APPS%NOTFOUND;
			END LOOP;
			CLOSE ALL_APPS ;
		END LOOP;
		RETURN getUniqueList( l_apps );
	END GENERATE_LIST_APPS;
/***********************************************************************************************/
/** GENERATE_LIST_RESP  ************************************************************************/
/***********************************************************************************************/
	FUNCTION GENERATE_LIST_RESP (
			P_LEVEL		VARCHAR2,
			P_VALUE		VARCHAR2
	) RETURN SARRAY AS
		RET_LIST	SARRAY := SARRAY();
		list_so		SARRAY := SARRAY();
		list_sh		SARRAY := SARRAY();
		list_qp		SARRAY := SARRAY();
		list_ru		SARRAY := SARRAY();
		list_all	SARRAY := SARRAY();
		lvl_id 		NUMBER ;
		lvl_value 	NUMBER ;
		prof_opt_id 	NUMBER := 1991;
		oper_unit	VARCHAR2(30);
		ctr		NUMBER := 1;
	BEGIN
	        OE_DEBUG_PUB.ADD('In OEXRSTVB : Generate_List_Resp function');
		list_so := getRespListForForm('OEXOEORD', 'Sales Orders', 'ONT');
		OE_DEBUG_PUB.ADD('Retrieved responsibilities accessing Sales Order form');
		list_sh := getRespListForForm('WSHFSTRX', null, 'WSH' );
		OE_DEBUG_PUB.ADD('Retrieved responsibilities accessing Shipping Transactions form');
		list_qp := getRespListForForm('QPXPRLST', null, 'QP' );
		OE_DEBUG_PUB.ADD('Retrieved responsibilities accessing Price List form');
		list_all := addArrayToArr(list_qp, addArrayToArr(list_so, list_sh));
		IF P_LEVEL = 'INST'  THEN
			RETURN getUniqueList(list_all);
		END IF;
		IF P_LEVEL = 'OU' THEN
			RET_LIST.extend(list_all.COUNT);
			FOR i IN 1..list_all.COUNT
			LOOP
				lvl_id := 10003;
				lvl_value := list_all(i);
				oper_unit := getProfileOptionValue( lvl_id, lvl_value,
						prof_opt_id );
				IF oper_unit = p_value THEN
					RET_LIST(ctr) := list_all(i);
					ctr := ctr + 1;
				END IF;
			END LOOP;
			RETURN getUniqueList(RET_LIST);
		END IF;
		IF P_LEVEL = 'RESP' THEN
			RET_LIST.extend(1);
			FOR i IN 1..list_all.COUNT
			LOOP
			  	IF list_all(i) = P_VALUE THEN
			    		RET_LIST(1) := P_VALUE;
			  	END IF;
			END LOOP;
			RETURN RET_LIST;
		END IF;
		IF P_LEVEL = 'USER' THEN
			list_ru := getRespForUser( to_number(p_value) );
			RET_LIST.extend(list_all.COUNT);
			FOR i IN 1..list_all.COUNT
			LOOP
			   FOR j IN 1..list_ru.COUNT
			   LOOP
				IF ( list_ru(j) = list_all(i) ) THEN
					RET_LIST(ctr) := list_all(i);
					ctr := ctr + 1;
					EXIT;
				END IF;
			   END LOOP;
			END LOOP;
			RETURN getUniqueList(RET_LIST);
		END IF;
	END GENERATE_LIST_RESP;
/***********************************************************************************************/
/** GENERATE_LIST_USER  ************************************************************************/
/***********************************************************************************************/
	FUNCTION GENERATE_LIST_USER(
			P_LEVEL		VARCHAR2,
			P_VALUE		VARCHAR2
	) RETURN SARRAY AS
	CURSOR ALL_USER(resp_id IN NUMBER) IS
		SELECT USER_ID
		FROM FND_USER_RESP_GROUPS
		WHERE RESPONSIBILITY_ID=resp_id;
		ctr		NUMBER := 1;
		j 		NUMBER := 1;
		user_all	ALL_USER%ROWTYPE;
		users		SARRAY := SARRAY();
		isdouble	BOOLEAN := FALSE;
		isFound		BOOLEAN := FALSE;
		TEMP_LIST	SARRAY := SARRAY();
	BEGIN
		IF P_LEVEL = 'USER' THEN
			users.extend(1);
			users(1) := P_VALUE;
			RETURN users;
		END IF;
		users.extend(1000);
		FOR i IN 1..RESP_LIST.COUNT
		LOOP
			OPEN ALL_USER(RESP_LIST(i));
			FETCH ALL_USER INTO user_all;
			LOOP
				users(ctr) := user_all.USER_ID;
				ctr := ctr + 1;
				IF ( MOD(ctr,1000) = 999 ) THEN
				    users.extend(1000);
				END IF;
				FETCH ALL_USER INTO user_all;
				EXIT WHEN ALL_USER%NOTFOUND;
			END LOOP;
			CLOSE ALL_USER ;
		END LOOP;
		RETURN getUniqueList( users );
	END GENERATE_LIST_USER;
/***********************************************************************************************/
/** Initialize Temp Tables  ********************************************************************/
/***********************************************************************************************/
	FUNCTION initializeTemp RETURN BOOLEAN IS
	BEGIN
	   DECLARE
	   BEGIN
	/*------------------------------------------------------------------------------
	Following PL/SQL block inserts rows into the om_setup_valid_entities table.
	------------------------------------------------------------------------------*/

  	      BEGIN
    	         INSERT INTO OM_SETUP_VALID_ENTITIES(ENTITY_NAME, PROCEDURE_NAME, USER_FLAG, RESPONSIBILITY_FLAG, OPERATING_UNIT_FLAG, INSTANCE_FLAG, SEQUENCE_NUM)
    	         VALUES ('Key Flex Field Setup', 'VALIDATE_SALES_ORDER_KEYFLEX', 'N', 'N', 'N', 'Y', 1);
    	         INSERT INTO OM_SETUP_VALID_ENTITIES(ENTITY_NAME, PROCEDURE_NAME, USER_FLAG, RESPONSIBILITY_FLAG, OPERATING_UNIT_FLAG, INSTANCE_FLAG, SEQUENCE_NUM)
    	         VALUES ('Key Flex Field Setup', 'VALIDATE_ITEM_CATALOGS_FLEX', 'N', 'N', 'N', 'Y', 2);
    	         INSERT INTO OM_SETUP_VALID_ENTITIES(ENTITY_NAME, PROCEDURE_NAME, USER_FLAG, RESPONSIBILITY_FLAG, OPERATING_UNIT_FLAG, INSTANCE_FLAG, SEQUENCE_NUM)
    	         VALUES ('Shipping Organizations', 'VALIDATE_SHIPPING_ORGS(:lvl, :val)', 'N', 'Y', 'Y', 'Y', 3);
    	         INSERT INTO OM_SETUP_VALID_ENTITIES(ENTITY_NAME, PROCEDURE_NAME, USER_FLAG, RESPONSIBILITY_FLAG, OPERATING_UNIT_FLAG, INSTANCE_FLAG, SEQUENCE_NUM)
    	         VALUES ('Period Status', 'VALIDATE_PERIOD_STATUS(:lvl, :val)', 'N', 'Y', 'Y', 'Y', 4);
    	         INSERT INTO OM_SETUP_VALID_ENTITIES(ENTITY_NAME, PROCEDURE_NAME, USER_FLAG, RESPONSIBILITY_FLAG, OPERATING_UNIT_FLAG, INSTANCE_FLAG, SEQUENCE_NUM)
    	         VALUES ('Profile Options', 'VALIDATE_PROFILE_OPTIONS(:lvl, :val)', 'Y', 'Y', 'Y', 'Y', 5);
    	         INSERT INTO OM_SETUP_VALID_ENTITIES(ENTITY_NAME, PROCEDURE_NAME, USER_FLAG, RESPONSIBILITY_FLAG, OPERATING_UNIT_FLAG, INSTANCE_FLAG, SEQUENCE_NUM)
    	         VALUES ('User Level Profile Options', 'VALIDATE_USER_PROFILE_OPTIONS(:lvl, :val)', 'Y', 'Y', 'Y', 'Y', 6);
    	         INSERT INTO OM_SETUP_VALID_ENTITIES(ENTITY_NAME, PROCEDURE_NAME, USER_FLAG, RESPONSIBILITY_FLAG, OPERATING_UNIT_FLAG, INSTANCE_FLAG, SEQUENCE_NUM)
    	         VALUES ('Item Validation Organization', 'VALIDATE_ITEM_VALID_ORG(:lvl, :val)', 'N', 'Y', 'Y', 'Y', 7);
    	         INSERT INTO OM_SETUP_VALID_ENTITIES(ENTITY_NAME, PROCEDURE_NAME, USER_FLAG, RESPONSIBILITY_FLAG, OPERATING_UNIT_FLAG, INSTANCE_FLAG, SEQUENCE_NUM)
    	         VALUES ('Document Sequences For Sales Orders', 'VALIDATE_DOC_SEQ_SALES_ORDERS(:lvl, :val)', 'N', 'Y', 'Y', 'Y', 8);
    	         INSERT INTO OM_SETUP_VALID_ENTITIES(ENTITY_NAME, PROCEDURE_NAME, USER_FLAG, RESPONSIBILITY_FLAG, OPERATING_UNIT_FLAG, INSTANCE_FLAG, SEQUENCE_NUM)
    	         VALUES ('Document Sequences for Shipping Documents', 'VALIDATE_DOC_SEQ_SHIPPING(:lvl, :val)', 'N', 'Y', 'Y', 'Y', 9);
    	         INSERT INTO OM_SETUP_VALID_ENTITIES(ENTITY_NAME, PROCEDURE_NAME, USER_FLAG, RESPONSIBILITY_FLAG, OPERATING_UNIT_FLAG, INSTANCE_FLAG, SEQUENCE_NUM)
    	         VALUES ('Item Definition', 'VALIDATE_ITEM_DEFINITION(:lvl, :val)', 'N', 'Y', 'Y', 'Y', 10);
    	         INSERT INTO OM_SETUP_VALID_ENTITIES(ENTITY_NAME, PROCEDURE_NAME, USER_FLAG, RESPONSIBILITY_FLAG, OPERATING_UNIT_FLAG, INSTANCE_FLAG, SEQUENCE_NUM)
    	         VALUES ('Price List Definition', 'VALIDATE_PRICE_LIST_DEFINITION(:lvl, :val)', 'N', 'Y', 'Y', 'Y', 11);
    	         INSERT INTO OM_SETUP_VALID_ENTITIES(ENTITY_NAME, PROCEDURE_NAME, USER_FLAG, RESPONSIBILITY_FLAG, OPERATING_UNIT_FLAG, INSTANCE_FLAG, SEQUENCE_NUM)
    	         VALUES ('Transaction Type', 'VALIDATE_TRANSACTION_TYPES(:lvl, :val)', 'N', 'Y', 'Y', 'Y', 12);
    	         INSERT INTO OM_SETUP_VALID_ENTITIES(ENTITY_NAME, PROCEDURE_NAME, USER_FLAG, RESPONSIBILITY_FLAG, OPERATING_UNIT_FLAG, INSTANCE_FLAG, SEQUENCE_NUM)
    	         VALUES ('Credit Checking Setup', 'VALIDATE_CREDIT_CHECKING(:lvl, :val)', 'N', 'Y', 'Y', 'Y', 13);
    	         INSERT INTO OM_SETUP_VALID_ENTITIES(ENTITY_NAME, PROCEDURE_NAME, USER_FLAG, RESPONSIBILITY_FLAG, OPERATING_UNIT_FLAG, INSTANCE_FLAG, SEQUENCE_NUM)
    	         VALUES ('Sales Credit', 'VALIDATE_SALES_CRDT_DEFINITION(:lvl, :val)', 'N', 'Y', 'Y', 'Y', 14);
    	         INSERT INTO OM_SETUP_VALID_ENTITIES(ENTITY_NAME, PROCEDURE_NAME, USER_FLAG, RESPONSIBILITY_FLAG, OPERATING_UNIT_FLAG, INSTANCE_FLAG, SEQUENCE_NUM)
    	         VALUES ('Freight Carrier', 'VALIDATE_FREIGHT_CARRIER(:lvl, :val)', 'N', 'Y', 'Y', 'Y', 15);
    	         INSERT INTO OM_SETUP_VALID_ENTITIES(ENTITY_NAME, PROCEDURE_NAME, USER_FLAG, RESPONSIBILITY_FLAG, OPERATING_UNIT_FLAG, INSTANCE_FLAG, SEQUENCE_NUM)
    	         VALUES ('Set of Books', 'VALIDATE_SET_OF_BOOKS_SETUP(:lvl, :val)', 'N', 'Y', 'Y', 'Y', 16);
    	         INSERT INTO OM_SETUP_VALID_ENTITIES(ENTITY_NAME, PROCEDURE_NAME, USER_FLAG, RESPONSIBILITY_FLAG, OPERATING_UNIT_FLAG, INSTANCE_FLAG, SEQUENCE_NUM)
    	         VALUES ('Shipping Grants and Roles', 'VALIDATE_SHIPPING_GRANTS_ROLES(:lvl, :val)', 'Y', 'N', 'N', 'Y', 17);
    	         INSERT INTO OM_SETUP_VALID_ENTITIES(ENTITY_NAME, PROCEDURE_NAME, USER_FLAG, RESPONSIBILITY_FLAG, OPERATING_UNIT_FLAG, INSTANCE_FLAG, SEQUENCE_NUM)
    	         VALUES ('System', 'None', 'N', 'Y', 'N', 'N', 18);
 	      EXCEPTION
	      WHEN OTHERS THEN
	         begin
	         RETURN(FALSE);
	         end;
	      END;
	/*------------------------------------------------------------------------------
	Following PL/SQL block inserts rows into the om_setup_valid_errm table.
	------------------------------------------------------------------------------*/
	      BEGIN
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_PROF_OPT', 'The following profile options have not been defined at any level.');
    	         /*
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_USER_PROF_OPT', 'The following profile options should not have a value for any user that has access to an Order Management responsibility.');
    	         */
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_USR_PRF_OPT', 'The following profile options should not have a value for any user that has access to an Order Management responsibility.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_SOB', 'Set of books do not match between AR system option and GL Set of Books name profile option.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_MASTER_ORG', 'Item Validation Organizations do not match between OM Parameters and QP: Item Validation Organization profile option.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_SO_FLEX', 'Sales Order Key Flex Field is not included required 3 segments or not enabled or not allowed dynamic insert.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_ITMCAT_FLEX', 'Item Catalogs Key Flex Field is not enabled or not frozen.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_NOTFOUND_DOC_SEQ ', 'There are no document sequences defined for Oracle Order Management.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_NOTFOUND_DOC_CAT', 'A document category with the same name as the transaction type does not exist.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_DOC_SEQ', 'There is not a document sequence assignment in the set of book corresponding to each operating unit with OM parameters defined for Oracle Order Management.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INACTIVE_DOC_SEQ', 'The following document category should be actively assigned, in the set of books corresponding to the operating unit of the transaction type, to an active sequence.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_CC_NOTFOUND', 'No credit check rules exist.');
    	         /*
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_CC_INVALID_TRAN_TYPE', 'Credit check rules are not enabled in the following transaction type.');
    	         */
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_CC_INVALID_TRAN_TYP', 'Credit check rules are not enabled in the following transaction type.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_CC_INVALID_PAY_TERM', 'There is no payment term that is enabled for credit checking.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_CC_INVALID_CUST', 'There is no customer or the customer site that is enabled for credit checking.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_CC_PRE_CALC_EXPO', 'The Credit Checking Initialize process is not scheduled and there is at least one credit check rule using pre-calculated Exposure.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_ITEM', 'No item exists in the following inventory organizations with OE Transactable, Customer Ordered, Customer Order Enabled, Returnable, Internal Ordered, Internal Orders Enabled, OE Transactable enabled');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_PRC_LST', 'No active price list exists with items assigned to it.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_SLS_CRDT', 'No sales credit type exists for both quota and non-quota types.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_SHIP_ORG', 'Shipping parameters have not been defined in any inventory organizations in the following shipping operating units.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_DFLT_SUBINV', 'A default staging subinventory has not been defined in the following shipping inventory organizations.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_SUBINV_ORGN', 'Subinventories are not defined in the following shipping inventory organizations.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_SHIP_OMORG', 'Shipping parameters have not been defined in the following inventory organizations.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_PICK_RULES', 'No picking rule exists in the following shipping inventory organizations.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_NO_OPEN_PERIOD', 'No open period exists in the following inventory organizations.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_CURR_PERIOD', 'The current period is not opened in the following inventory organizations.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_FC_INACTIVE_ALL', 'No active carrier exists.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_FC_INACTIVE_ORG', 'No active carrier exists in any inventory organizations under the following Operating Unit.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_FC_RELATIONS', 'No carrier / ship method relationships exist in any inventory organizations under the following Operating Unit.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_SHIP_DOC_SEQ', 'There are no document sequences defined for Oracle Shipping.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_SHIP_DOC_BOL', 'There are no document categories defined for BOL.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_SHIP_DOC_PKSLP', 'There are no document sequence categories defined for Pack Slip.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_SHIP_DOC_SEQ_ASSGN', 'There is not a document sequence assignment in the set of book corresponding to each operating unit with OM parameters defined for both BOL and Pack Slip.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_NOTFOUND_ROLES', 'No shipping role are defined. ');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_NOTFOUND_ROLES_USER', 'No shipping role is assigned to this user. ');
    	         /*
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_NOTFOUND_ROLES_USERS', 'No shipping role is assigned to any existing user. ');
    	         */
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_NOTFOUND_ROLE_USERS', 'No shipping role is assigned to any existing user. ');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_TRAN_TYPE_1', 'No transaction type is defined in the following operating units.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_TRAN_TYPE_2', 'No Order workflow assignment exists for any the following transaction types in the following operating units.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_TRAN_TYPE_3', 'No line workflow exists for any the following transaction types in the following operating units.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_TRAN_TYPE_4', 'No credit checking for booking or shipping either Ordering, Packing, Picking or Shipping for any the following transaction types exists in the following operating units.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_TRAN_TYPE_5', 'Schduling level is not set for the following transaction types in the following operating units.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_TRAN_TYPE_6', 'COGS account is not set for the following transaction types in the following operating units.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_TRAN_TYPE_7', 'Invoice source and Non-Delivery invoice source are not set for the following transaction types in the following operating units.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_TRAN_TYPE_8', 'Receivables Transaction Type is not set in the following operating units.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_TRAN_TYPE_9', 'No default order line type exists for the following transaction types in the following operating units.');
    	         /*
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_TRAN_TYPE_10', 'No default return line type exists for the following transaction types in the following operating units.');
    	         */
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_TRAN_TYPE10', 'No default return line type exists for the following transaction types in the following operating units.');
    	         INSERT INTO OM_SETUP_VALID_ERRM(MESG_NAME, DESCRIPTION)
    	         VALUES('ONT_SETVAL_INVALID_INPUT', 'The selected responsibility cannot be validated for OM Setup as it cannot access the Sales Orders, Shipping Transactions and Price Lists forms.');

	      EXCEPTION
	      WHEN OTHERS THEN
	         begin
	         RETURN(FALSE);
	         end;
	      END;
	/*------------------------------------------------------------------------------
	Following PL/SQL block inserts rows into the OM_SETUP_VALID_PROF_OPT table.
	------------------------------------------------------------------------------*/
	      BEGIN
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('AR_USE_INV_ACCT_FOR_CM_FLAG', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('CZ_UIMGR_URL', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('ONT_ADMINISTER_PUBLIC_QUERIES', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('OE_CREDIT_TRANSACTION_TYPE_ID', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('WSH_CR_SREP_FOR_FREIGHT', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('OE_CUST_ITEM_SHOW_MATCHES', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('ONT_EST_AUTH_VALID_DAYS', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('ONT_INCLUDED_ITEM_FREEZE_METHOD', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('WSH_INVOICE_NUMBERING_METHOD', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('OE_INVOICE_SOURCE', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('OE_INVOICE_TRANSACTION_TYPE_ID', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('OE_ID_FLEX_CODE', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('OE_NON_DELIVERY_INVOICE_SOURCE', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('OM_OVER_RETURN_TOLERANCE', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('OE_OVERSHIP_INVOICE_BASIS', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('OM_OVER_SHIPMENT_TOLERANCE', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('ONT_RETURN_ITEM_MISMATCH_ACTION', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('ONT_RETURN_FULFILLED_LINE_ACTION', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('OE_DISCOUNT_DETAILS_ON_INVOICE', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('ONT_SOURCE_CODE', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('OM_UNDER_RETURN_TOLERANCE', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('OM_UNDER_SHIPMENT_TOLERANCE', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('QP_BLIND_DISCOUNT', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('QP_ORGANIZATION_ID', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('QP_NEGATIVE_PRICING', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('QP_SOURCE_SYSTEM_CODE', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('QP_UNIT_PRICE_PRECISION_TYPE', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('QP_VERIFY_GSA', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('UNIQUE:SEQ_NUMBERS', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('AR_ALLOW_TAX_UPDATE', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('AR_ALLOW_TAX_CODE_OVERRIDE', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('AR_TAX_USE_VENDOR', 'INST', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('AR_USE_INV_ACCT_FOR_CM_FLAG', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('CZ_UIMGR_URL', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('BOM:ITEM_SEQUENCE_INCREMENT', 'USER', 660 );
    	         --INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         --VALUES('BOM:DEFAULT_BOM_LEVELS', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('ONT_ADMINISTER_PUBLIC_QUERIES', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('OE_APPLY_AUTOMATIC_ATCHMT', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('ONT_AUTOSCHEDULE', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('ONT_CREDIT_CARD_PRIVILEGES', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('OE_CREDIT_TRANSACTION_TYPE_ID', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('ONT_CUSTOMER_RELATIONSHIPS', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('ONT_EST_AUTH_VALID_DAYS', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('ONT_GSA_VIOLATION_ACTION', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('ONT_INCLUDED_ITEM_FREEZE_METHOD', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('WSH_INVOICE_NUMBERING_METHOD', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('OE_INVOICE_SOURCE', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('OE_INVOICE_TRANSACTION_TYPE_ID', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('OE_ID_FLEX_CODE', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('OE_NON_DELIVERY_INVOICE_SOURCE', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('OM_OVER_RETURN_TOLERANCE', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('OM_OVER_SHIPMENT_TOLERANCE', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('OE_OVERSHIP_INVOICE_BASIS', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('ONT_RECEIPT_METHOD_ID', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('ONT_RESERVATION_TIME_FENCE', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('ONT_RETURN_ITEM_MISMATCH_ACTION', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('ONT_RETURN_FULFILLED_LINE_ACTION', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('ONT_RISK_FAC_THRESHOLD', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('ONT_SCHEDULE_LINE_ON_HOLD', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('OE_DISCOUNT_DETAILS_ON_INVOICE', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('ONT_SOURCE_CODE', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('OM_UNDER_RETURN_TOLERANCE', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('OM_UNDER_SHIPMENT_TOLERANCE', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('QP_ACCRUAL_UOM_CLASS', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('QP_BLIND_DISCOUNT', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('QP_ORGANIZATION_ID', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('QP_LINE_VOLUME_UOM_CODE', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('QP_LINE_WEIGHT_UOM_CODE', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('QP_NEGATIVE_PRICING', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('QP_SOURCE_SYSTEM_CODE', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('QP_UNIT_PRICE_PRECISION_TYPE', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('QP_VERIFY_GSA', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('UNIQUE:SEQ_NUMBERS', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('AR_ALLOW_TAX_UPDATE', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('AR_ALLOW_MANUAL_TAX_LINES', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('AR_ALLOW_TAX_CODE_OVERRIDE', 'USER', 660 );
   	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('AR_TAX_USE_VENDOR', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('SO_INVOICE_FREIGHT_AS_LINE', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('OE_INVENTORY_ITEM_FOR_FREIGHT', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('AR_CALCULATE_TAX_ON_CM', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('WSH_CR_SREP_FOR_FREIGHT', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('ORG_ID', 'USER', 660 );
    	         INSERT INTO OM_SETUP_VALID_PROF_OPT(PROFILE_OPTION_NAME, VAL_LEVEL, APPLICATION_ID)
    	         VALUES('GL_SET_OF_BKS_NAME', 'USER', 660 );
	      EXCEPTION
	         WHEN OTHERS THEN
	         begin
	         RETURN(FALSE);
	         end;
	      END;
	   END;
	 RETURN(TRUE);
	END initializeTemp;
/***********************************************************************************************/
/** getFormFunctionId  *************************************************************************/
/***********************************************************************************************/
        FUNCTION getFormFunctionId
        (
          p_form_name	 VARCHAR2
        , p_application	 VARCHAR2
        , p_description	 VARCHAR2
        )
        RETURN sarray
        as
          ---------------------------------------------------------
          --------- Input/Output/Inter Variables ------------------
          ---------------------------------------------------------
          l_form_name       VARCHAR2(100);
          l_application     VARCHAR2(10);
          l_description     VARCHAR2(100);
          l_form_id         NUMBER;
          l_application_id  NUMBER;
          l_function_id     NUMBER;
          l_function_list   SARRAY:=SARRAY();
          l_empty_cursor    BOOLEAN:=FALSE;
          l_csr_app_id      NUMBER;
          l_sarray_init_lgt NUMBER:=1000;
          l_sarray_ext_cnt  NUMBER:=999;
          ---------------------------------------------------------
          --------- Cursor Variables ------------------------------
          ---------------------------------------------------------
	  CURSOR c_function_cursor(c_form_id NUMBER) IS
             select application_id, function_id
             from fnd_form_functions
             where form_id = c_form_id;
          ---------------------------------------------------------
          --------- Cursor Row Type variables ---------------------
          ---------------------------------------------------------
          l_function_csr   c_function_cursor%ROWTYPE;
          l_list_index     NUMBER:=1;
          ---------------------------------------------------------
          --------- Other variables -------------------------------
          ---------------------------------------------------------
        begin
          OE_DEBUG_PUB.ADD('IN  OEXRSTVB: Get_Form_Function_Id');
          OE_DEBUG_PUB.ADD('Input Paramters: ');
          OE_DEBUG_PUB.ADD('    l_form_name: '||l_form_name);
          OE_DEBUG_PUB.ADD('  l_application: '||l_application);
          OE_DEBUG_PUB.ADD('  l_description: '||l_description);
          l_form_name := p_form_name;
          l_application := p_application;
          l_description := p_description;
          l_function_list.extend(l_sarray_init_lgt);
          ---------------------------------------------------------
          ---------- Get the Form Id from Form Name ---------------
          ---------------------------------------------------------
          select form_id
          into l_form_id
          from fnd_form
          where form_name = l_form_name;
          OE_DEBUG_PUB.ADD('l_form_id: '||l_form_id);
          ---------------------------------------------------------
          ---------- Application Id from Application Short Name  --
          ---------------------------------------------------------
          select application_id
          into l_application_id
          from fnd_application
	  where application_short_name = l_application;
	  OE_DEBUG_PUB.ADD('l_application_id: '||l_application_id);
	  ---------------------------------------------------------
          ---------- Process cursor to get function list ----------
          ---------------------------------------------------------
          open c_function_cursor(l_form_id);
          OE_DEBUG_PUB.ADD('Opened Cursor c_function_cursor');
          fetch c_function_cursor into l_function_csr;
          OE_DEBUG_PUB.ADD('Fetched cursor into l_function_csr');
          if ( c_function_cursor%NOTFOUND ) then
            OE_DEBUG_PUB.ADD('No records in cursor');
            l_empty_cursor := true;
          else
            OE_DEBUG_PUB.ADD('records found in cursor');
            l_csr_app_id:=l_function_csr.application_id;
            OE_DEBUG_PUB.ADD('l_csr_app_id :'||l_csr_app_id);
            if (l_csr_app_id=l_application_id) then
              loop
                l_function_list(l_list_index):=l_function_csr.function_id;
                l_list_index:=l_list_index+1;
                if(MOD(l_list_index,l_sarray_init_lgt)=l_sarray_ext_cnt) then
                  l_function_list.extend(l_sarray_init_lgt);
                end if;
                fetch c_function_cursor into l_function_csr;
                exit when c_function_cursor%NOTFOUND;
              end loop;
            end if;
          end if;
          ---------------------------------------------------------
          ------------ Trim function name list  -------------------
          ---------------------------------------------------------
          l_function_list:=trimArray(l_function_list);
          return l_function_list;
        end getFormFunctionId;
/***********************************************************************************************/
/** getMenus  *********************************************************************************/
/***********************************************************************************************/
	FUNCTION getMenus( func_id NUMBER ) RETURN SARRAY AS
		menus 		SARRAY := SARRAY();
	CURSOR func_menus( func_id IN NUMBER ) IS
		SELECT menu_id
		FROM FND_MENU_ENTRIES
		WHERE FUNCTION_ID = func_id;
		fmenus	func_menus%ROWTYPE;
		ind	NUMBER:=1;
	BEGIN
		OPEN func_menus(func_id);
		FETCH func_menus INTO fmenus;
		menus.extend(1000);
		LOOP
			menus(ind) := fmenus.menu_id;
			ind := ind + 1;
			IF ( MOD(ind,1000) = 999 ) THEN
			   menus.extend(1000);
			END IF;
			FETCH func_menus INTO fmenus;
			EXIT WHEN func_menus%NOTFOUND;

		END LOOP;
		RETURN(trimArray( menus ) );
	END;
/***********************************************************************************************/
/** Procedures**********************************************************************************/
/***********************************************************************************************/
	PROCEDURE VALIDATE_PROFILE_OPTIONS(P_LEVEL  IN  VARCHAR2, P_VALUE IN VARCHAR2)
	IS
		/* Procedure variables */
		prof_opts	SARRAY := SARRAY();
		prof_opt_id	NUMBER;
		prof_opt_val	VARCHAR2(100);
		prof_opt_valn	NUMBER;
		resps		SARRAY := SARRAY();
		numVal		BOOLEAN;
		/* Report table variables */
		entity		VARCHAR2(100);
		error_type	VARCHAR2(15);
		mesg_name	VARCHAR2(255);
		/* Flags variables */

		isDefined	BOOLEAN;
		errLogged	BOOLEAN;
		/* Cursors	   */
		CURSOR profile_options IS
			SELECT PROFILE_OPTION_NAME
			FROM OM_SETUP_VALID_PROF_OPT
			WHERE VAL_LEVEL = 'INST'
			AND APPLICATION_ID = 660;
                --
                -- Bug 3537496 : Modified by NKILLEDA
                --   Changed the variable name from 'po' to l_po_rec for GSCC
                --   compliance. the specific rule is file.sql.6.
                --
		l_po_rec	profile_options%ROWTYPE;
		/* Counters */
		ind		NUMBER := 1;
	BEGIN
		prof_opts.extend(100);
		OPEN profile_options;
		FETCH profile_options INTO l_po_rec;
		LOOP
			prof_opts(ind) := l_po_rec.PROFILE_OPTION_NAME;
			ind := ind + 1;
			FETCH profile_options INTO l_po_rec;
			EXIT WHEN profile_options%NOTFOUND;
		END LOOP;
		prof_opts := trimArray(prof_opts);
		FOR i IN 1..prof_opts.COUNT
		LOOP
			isDefined := FALSE;
			prof_opt_id := getProfileOptionId( prof_opts(i) );
			prof_opt_val := getProfileOptionValue(10001, p_value, prof_opt_id);
			numVal := isNumeric( prof_opt_val );
			IF ( (numVal=FALSE) OR
			     ((numVal=TRUE) AND NOT ((prof_opt_val=-1) OR (prof_opt_val is null))
			     )
			   ) THEN
				isDefined := TRUE;
			END IF;
			IF ( isDefined = FALSE ) THEN
				FOR j IN 1..APPS_LIST.COUNT
				LOOP
					prof_opt_val := getProfileOptionValue(10002, APPS_LIST(j), prof_opt_id);
					numVal := isNumeric( prof_opt_val );
					IF ((numVal=FALSE)OR((numVal=TRUE)

							 AND NOT( (prof_opt_val=-1)
								   OR (prof_opt_val is null)))) THEN
						isDefined := TRUE;
					END IF;
				END LOOP;
			END IF;
			IF ( isDefined = FALSE ) THEN
				FOR j IN 1..RESP_LIST.COUNT
				LOOP
					prof_opt_val := getProfileOptionValue(10003, RESP_LIST(j), prof_opt_id);
					numVal := isNumeric( prof_opt_val );
					IF ((numVal=FALSE)OR((numVal=TRUE)
							 AND NOT( (prof_opt_val=-1)

								   OR (prof_opt_val is null)))) THEN
						isDefined := TRUE;
					END IF;
				END LOOP;
			END IF;
			IF ( isDefined = FALSE ) THEN
				FOR j IN 1..USER_LIST.COUNT
				LOOP
					prof_opt_val := getProfileOptionValue(10004, USER_LIST(j), prof_opt_id);
					numVal := isNumeric( prof_opt_val );
					IF ((numVal=FALSE)OR((numVal=TRUE)
							 AND NOT( (prof_opt_val=-1)
								   OR (prof_opt_val is null)))) THEN
						isDefined := TRUE;
					END IF;
				END LOOP;
			END IF;
			IF isDefined = FALSE THEN
				entity 		:= 'Profile Options';
				error_type 	:= 'ERROR';
				mesg_name 	:= 'ONT_SETVAL_INVALID_PROF_OPT';
				errLogged	:= writeError( entity, p_level, p_value, error_type, mesg_name ,
								null, null, null, null, null, null, null, getProfOptName(prof_opts(i)),
								null, null, null);
			END IF;
		END LOOP;
	END VALIDATE_PROFILE_OPTIONS;
	PROCEDURE VALIDATE_USER_PROFILE_OPTIONS(P_LEVEL  IN  VARCHAR2, P_VALUE IN VARCHAR2)
	IS
		/* Procedure variables */
		prof_opts	SARRAY := SARRAY();
		prof_opt_id	NUMBER;
		prof_opt_val	VARCHAR2(100);
		prof_opt_valn	NUMBER;
		numVal		BOOLEAN;
		user_name	VARCHAR2(255);
		/* Report table variables */
		entity		VARCHAR2(100);
		error_type	VARCHAR2(15);
		mesg_name	VARCHAR2(255);
		/* Cursors	   */
		CURSOR profile_options IS
			SELECT PROFILE_OPTION_NAME
			FROM OM_SETUP_VALID_PROF_OPT
			WHERE VAL_LEVEL = 'USER'
			AND APPLICATION_ID = 660;
		upo		profile_options%ROWTYPE;
		/* Counters */
		ind		NUMBER := 1;
		omresp		BOOLEAN;
		errLogged	BOOLEAN;
	BEGIN
		prof_opts.extend(100);
		entity 		:= 'User Level Profile Options';
		error_type 	:= 'ERROR';
		mesg_name 	:= 'ONT_SETVAL_INVALID_USR_PRF_OPT';
		OPEN profile_options;
		FETCH profile_options INTO upo;
		LOOP
			prof_opts(ind) := upo.PROFILE_OPTION_NAME;
			ind := ind + 1;
			FETCH profile_options INTO upo;
			EXIT WHEN profile_options%NOTFOUND;
		END LOOP;
		prof_opts := trimArray(prof_opts);
		FOR i IN 1..prof_opts.COUNT
		LOOP
			prof_opt_id := getProfileOptionId( prof_opts(i) );
			FOR j IN 1..USER_LIST.COUNT
			LOOP
				omresp := checkForOMResp(USER_LIST(j));
				IF ( omresp = TRUE ) THEN
					prof_opt_val := getProfileOptionValue(10004, USER_LIST(j), prof_opt_id);
					numVal := isNumeric( prof_opt_val );
					user_name := getUserName(USER_LIST(j));
					IF ((numVal=FALSE)OR((numVal=TRUE) AND NOT( (prof_opt_val=-1)
					     OR (prof_opt_val is null)))) THEN
						errLogged := writeError( entity, p_level, p_value, error_type, mesg_name,
							    null, user_name, null, null, null, null, null,
							    getProfOptName(prof_opts(i)), null, null, null );
					END IF;
				END IF;
			END LOOP;
		END LOOP;
	END VALIDATE_USER_PROFILE_OPTIONS;
	PROCEDURE VALIDATE_SET_OF_BOOKS_SETUP(P_LEVEL  IN  VARCHAR2, P_VALUE IN VARCHAR2)
	IS
		/* Report table variables */
		entity		VARCHAR2(100) := 'Set of Books';
		error_type	VARCHAR2(15)  := 'ERROR';
		mesg_name	VARCHAR2(255) := 'ONT_SETVAL_INVALID_SOB';
		/* Indicator variables */
		isError		BOOLEAN := FALSE;
		errLogged	BOOLEAN;
		/* Local variables */
		lvl_id		VARCHAR2(10);
		lvl_value	VARCHAR2(10);
		prof_opt_id	NUMBER:=1991;
		oper_unit	NUMBER;
		ou		NUMBER;
		ou_cur		NUMBER;
		sobar		VARCHAR2(255);
		sobhr		VARCHAR2(255);
		sobgl		VARCHAR2(255);
		/* Array Variables */
		oulist		SARRAY:=SARRAY();
		/* Counter Variables */
		indx 		NUMBER:=1;
		appcount	NUMBER:=0;
                /* Ar system parameters */
                l_AR_Sys_Param_Rec    AR_SYSTEM_PARAMETERS_ALL%ROWTYPE;
                l_sob_id              NUMBER;

	BEGIN

		IF ( P_LEVEL = 'OU' ) THEN
			oulist.extend(1);
			oulist(1) := P_VALUE;
		ELSE
			oulist.extend(4000);
			FOR i IN 1..RESP_LIST.COUNT
			LOOP
				ou := getOperatingUnit( RESP_LIST(i) );
				IF ( ou <> -1 ) THEN
					oulist(indx) := ou;
					indx := indx + 1;
				END IF;
			END LOOP;
			oulist := getUniqueList(trimArray( oulist ));
		END IF;
		FOR i IN 1..oulist.COUNT
		LOOP
			BEGIN
                            IF oe_code_control.code_release_level < '110510' THEN
				SELECT gsob.NAME
				INTO sobar
				FROM AR_SYSTEM_PARAMETERS_ALL aspa, GL_SETS_OF_BOOKS gsob
				WHERE aspa.ORG_ID = oulist(i)
				AND gsob.SET_OF_BOOKS_ID = aspa.SET_OF_BOOKS_ID;
                            ELSE
                                l_AR_Sys_Param_Rec := OE_Sys_Parameters_Pvt.Get_AR_Sys_Params(oulist(i));
                                l_sob_id := l_AR_Sys_Param_Rec.set_of_books_id;
                                 SELECT gsob.NAME
                                 INTO sobar
                                 FROM GL_SETS_OF_BOOKS gsob
                                 WHERE gsob.SET_OF_BOOKS_ID = l_sob_id;
                            END IF;

			EXCEPTION
			WHEN OTHERS THEN
				sobar := -1;
			END;
			BEGIN
				SELECT gsob.NAME
				INTO sobhr
				FROM HR_OPERATING_UNITS hou, GL_SETS_OF_BOOKS gsob
				WHERE hou.ORGANIZATION_ID = oulist(i)
				AND gsob.SET_OF_BOOKS_ID = hou.SET_OF_BOOKS_ID;
			EXCEPTION
			WHEN OTHERS THEN
				sobhr := -1;
			END;
			FOR j IN 1..RESP_LIST.COUNT
			LOOP
				ou_cur := getOperatingUnit( RESP_LIST(j) );
				IF ( ou_cur = oulist(i) ) THEN
					sobgl:=getProfileOptionValue(10003, RESP_LIST(j), 1202);
					IF ( sobgl<>to_char(-1) AND sobar<>to_char(-1) AND sobhr<>to_char(-1)
					     AND (sobgl<>sobar OR sobar<>sobhr OR sobgl<>sobhr) ) THEN
						errLogged := writeError( entity, p_level, p_value, error_type,
								mesg_name, 'Resp', getRespName(RESP_LIST(j)),
								null, null, sobar, sobhr, sobgl, null, null, null, null );
					END IF;
					FOR k IN 1..APPS_LIST.COUNT
					LOOP
						SELECT COUNT(APPLICATION_ID)
						INTO appcount
						FROM FND_RESPONSIBILITY
						WHERE RESPONSIBILITY_ID = RESP_LIST(j)
						AND APPLICATION_ID = APPS_LIST(k);
						IF ( appcount>0 ) THEN
							sobgl:=getProfileOptionValue(10002, APPS_LIST(k), 1202);
							IF ( sobgl<>to_char(-1) AND sobar<>to_char(-1) AND sobhr<>to_char(-1)
							     AND ( sobgl<>sobar OR sobar<>sobhr OR sobgl<>sobhr ) ) THEN
								errLogged := writeError( entity, p_level, p_value, error_type,
										mesg_name, 'Appl', getAppsName(APPS_LIST(k)),
										null, null, sobar, sobhr, sobgl, null, null, null, null );
							END IF;
						END IF;
					END LOOP;
				END IF;
			END LOOP;
		END LOOP;
	END VALIDATE_SET_OF_BOOKS_SETUP;
	PROCEDURE VALIDATE_ITEM_VALID_ORG(P_LEVEL  IN  VARCHAR2, P_VALUE IN VARCHAR2)
	IS
		/* Report table variables */
		entity		VARCHAR2(100) := 'Item Validation Organization';
		error_type	VARCHAR2(15)  := 'ERROR';
		mesg_name	VARCHAR2(255) := 'ONT_SETVAL_INVALID_MASTER_ORG';
		oulist		SARRAY := SARRAY();
		ou		NUMBER;
		indx		NUMBER:=1;
		/* Indicator variables */
		isError		BOOLEAN := FALSE;
		errLogged	BOOLEAN;
		/* Local variables */
		lvl_id		VARCHAR2(10);
		lvl_value	VARCHAR2(10);
		prof_opt_id	NUMBER:=1991;
		oper_unit	NUMBER;
		mstrorgrb	NUMBER;
		mstrorgib	NUMBER;
		mstrorg		NUMBER;
	BEGIN
		IF ( P_LEVEL = 'OU' ) THEN
			oulist.extend(1);
			oulist(1) := P_VALUE;
		ELSE
			oulist.extend(4000);
			FOR i IN 1..RESP_LIST.COUNT
			LOOP
				ou := getOperatingUnit( RESP_LIST(i) );
				IF ( ou <> -1 ) THEN
					oulist(indx) := ou;
					indx := indx + 1;
				END IF;
			END LOOP;
			oulist := getUniqueList(trimArray( oulist ));
		END IF;
		FOR j IN 1..oulist.COUNT
		LOOP
                  -- Start Sys Param Change
                  /*
			BEGIN
				SELECT MASTER_ORGANIZATION_ID
				INTO mstrorg
				FROM OE_SYSTEM_PARAMETERS_ALL
				WHERE ORG_ID = oulist(j);
			EXCEPTION
			WHEN OTHERS THEN
				mstrorg := -1;
			END;
                  */

                        mstrorg:=
                           oe_sys_parameters.value('MASTER_ORGANIZATION_ID', oulist(j));
                  -- END Sys Param Change
/*
-- Commented out for bug 2888807
			mstrorgib := getProfileOptionValue( 10001, null, 1000227 );
			IF ( ( mstrorg <> -1 AND mstrorgib <> -1 AND mstrorg <> mstrorgib )
			   OR ( mstrorg = -1 AND mstrorgib <> -1 ) )
			THEN
				IF ( mstrorg = -1 ) THEN
					errLogged := writeError( entity, p_level, p_value, error_type, mesg_name,
					    'Not Defined', null, getOuName(oulist(j)), getOuName(mstrorgib), null,
					    null, null, null, null, null, null );
				ELSE
					errLogged := writeError( entity, p_level, p_value, error_type, mesg_name,
					    getOuName(mstrorg), null, getOuName(oulist(j)), getOuName(mstrorgib), null,
					    null, null, null, null, null, null );
				END IF;
			END IF;
-- Commented out for bug 2888807
*/
			FOR i IN 1..RESP_LIST.COUNT
			LOOP
				lvl_id := 10003;
				lvl_value := RESP_LIST(i);
				oper_unit := getProfileOptionValue( lvl_id, lvl_value, prof_opt_id );
				IF ( oper_unit = oulist(j) ) THEN
				   mstrorgrb := getProfileOptionValue( lvl_id, lvl_value, 1000227 );
				   IF ( mstrorgrb = -1 ) THEN
				   	lvl_id := 10001;
				   	mstrorgrb := getProfileOptionValue( lvl_id, lvl_value, 1000227 );
				   END IF;
  				   IF ( ( mstrorg <> -1 AND mstrorgrb <> -1 AND mstrorg <> mstrorgrb )
				      OR ( mstrorg = -1 AND mstrorgrb <> -1 ) )
				   THEN
				   	IF ( mstrorg = -1 ) THEN
				      		errLogged := writeError( entity, p_level, p_value, error_type, mesg_name,
				  	           'Not Defined', null, getOuName(oper_unit), getOuName(mstrorgrb), null,
						   null, null, null, null, null, null );
					ELSE
				      		errLogged := writeError( entity, p_level, p_value, error_type, mesg_name,
				  	           getOuName(mstrorg), null, getOuName(oper_unit), getOuName(mstrorgrb), null,
						   null, null, null, null, null, null );
					END IF;
				   END IF;
				END IF;
			END LOOP;
		END LOOP;
	END VALIDATE_ITEM_VALID_ORG;
	PROCEDURE VALIDATE_SALES_ORDER_KEYFLEX(P_LEVEL  IN  VARCHAR2, P_VALUE IN VARCHAR2)
	IS
		/* Report table variables */
		entity		VARCHAR2(100) := 'Key Flex Field Setup';
		error_type	VARCHAR2(15)  := 'ERROR';
		mesg_name	VARCHAR2(255) := 'ONT_SETVAL_INVALID_SO_FLEX';
		/* Cursor Variables */
		CURSOR flex_defs IS
			SELECT 	DYNAMIC_INSERTS_ALLOWED_FLAG,
				FFST.ENABLED_FLAG
			FROM 	FND_ID_FLEX_STRUCTURES_VL FFST,
				FND_ID_FLEX_SEGMENTS_VL      FFSG,
				FND_FLEX_VALUE_SETS          FVS
			WHERE 	FFST.APPLICATION_ID     = 401
			AND 	FFST.ID_FLEX_CODE         = 'MKTS'
			AND 	FFST.APPLICATION_ID       = FFSG.APPLICATION_ID
			AND 	FFST.ID_FLEX_CODE         = FFSG.ID_FLEX_CODE
			AND 	FFST.ID_FLEX_NUM          = FFSG.ID_FLEX_NUM
			AND 	FVS.FLEX_VALUE_SET_ID(+)  = FFSG.FLEX_VALUE_SET_ID;
		flex		flex_defs%ROWTYPE;

		CURSOR flex_segs IS
			SELECT 	SEGMENT_NUM,
				SEGMENT_NAME,
				FFST.ENABLED_FLAG
			FROM 	FND_ID_FLEX_STRUCTURES_VL FFST,
				FND_ID_FLEX_SEGMENTS_VL      FFSG,
				FND_FLEX_VALUE_SETS          FVS
			WHERE 	FFST.APPLICATION_ID     = 401
			AND 	FFST.ID_FLEX_CODE         = 'MKTS'
			AND 	FFST.APPLICATION_ID       = FFSG.APPLICATION_ID
			AND 	FFST.ID_FLEX_CODE         = FFSG.ID_FLEX_CODE
			AND 	FFST.ID_FLEX_NUM          = FFSG.ID_FLEX_NUM
			AND 	FVS.FLEX_VALUE_SET_ID(+)  = FFSG.FLEX_VALUE_SET_ID;
		flexs		flex_segs%ROWTYPE;

		/* Counters */
		counter		NUMBER := 0;
		/* Indicator variables */
		isError		BOOLEAN := FALSE;
		errLogged	BOOLEAN;
		enabled		VARCHAR2(1);
		senable		VARCHAR2(1);
		dyninsa		VARCHAR2(1);
	BEGIN
		OPEN flex_defs;
		FETCH flex_defs INTO flex;
		LOOP
			enabled := flex.ENABLED_FLAG;
			dyninsa := flex.DYNAMIC_INSERTS_ALLOWED_FLAG;
			IF ( enabled = 'N' OR dyninsa = 'N') THEN
				isError := TRUE;
				EXIT;
			END IF;
			counter := counter + 1;

			FETCH flex_defs INTO flex;
			EXIT WHEN flex_defs%NOTFOUND;
		END LOOP;
		IF (isError=FALSE) AND (counter<3) THEN
			isError := TRUE;
		END IF;
		CLOSE flex_defs;
		OPEN flex_segs;
		FETCH flex_segs INTO flexs;
		LOOP
			senable := flexs.ENABLED_FLAG;
			IF ( senable='N') THEN
				isError := TRUE;
				EXIT;
			END IF;
			counter := counter + 1;

			FETCH flex_segs INTO flexs;
			EXIT WHEN flex_segs%NOTFOUND;
		END LOOP;
		CLOSE flex_segs;
		IF isError = TRUE THEN
			errLogged := writeError( entity, p_level, p_value, error_type, mesg_name,
				    null, null, null, null, null, null, null,
				    null, null, null, null );
		END IF;
	END VALIDATE_SALES_ORDER_KEYFLEX;
	PROCEDURE VALIDATE_ITEM_CATALOGS_FLEX(P_LEVEL  IN  VARCHAR2, P_VALUE IN VARCHAR2)
	IS
		/* Report table variables */
		entity 		VARCHAR2(100) := 'Key Flex Field Setup';
		error_type 	VARCHAR2(15)  := 'ERROR';
		mesg_name 	VARCHAR2(255) := 'ONT_SETVAL_INVALID_ITMCAT_FLEX';
		/* Cursor Variables */
		CURSOR flex_defs IS
			SELECT 	FREEZE_FLEX_DEFINITION_FLAG,
				SEGMENT_NUM,
				SEGMENT_NAME,
				FFSG.ENABLED_FLAG
			FROM 	FND_ID_FLEX_STRUCTURES_VL FFST,
				FND_ID_FLEX_SEGMENTS_VL      FFSG,
				FND_FLEX_VALUE_SETS          FVS
			WHERE 	FFST.APPLICATION_ID     = 401
			AND 	FFST.ID_FLEX_CODE         = 'MICG'
			AND 	FFST.APPLICATION_ID       = FFSG.APPLICATION_ID
			AND 	FFST.ID_FLEX_CODE         = FFSG.ID_FLEX_CODE
			AND 	FFST.ID_FLEX_NUM          = FFSG.ID_FLEX_NUM
			AND 	FVS.FLEX_VALUE_SET_ID(+)  = FFSG.FLEX_VALUE_SET_ID;
		flex		flex_defs%ROWTYPE;
		/* Counters */
		counter		NUMBER := 0;
		/* Indicator variables */
		isError		BOOLEAN := FALSE;
		errLogged	BOOLEAN;
		freezed		VARCHAR2(1);
		enabled		VARCHAR2(1);
	BEGIN
		OPEN flex_defs;
		FETCH flex_defs INTO flex;
		LOOP
			freezed := flex.FREEZE_FLEX_DEFINITION_FLAG;
			enabled := flex.ENABLED_FLAG;
			IF ( freezed = 'N' OR enabled = 'N') THEN
				isError := TRUE;
				EXIT;
			END IF;
			counter := counter + 1;
			FETCH flex_defs INTO flex;
			EXIT WHEN flex_defs%NOTFOUND;
		END LOOP;
		IF (isError=FALSE) AND (counter=0) THEN
			isError := TRUE;
		END IF;
		IF isError = TRUE THEN
			errLogged := writeError( entity, p_level, p_value, error_type, mesg_name,
				    null, null, null, null, null, null, null,
				    null, null, null, null );
		END IF;
	END VALIDATE_ITEM_CATALOGS_FLEX;
	PROCEDURE VALIDATE_TRANSACTION_TYPES(P_LEVEL  IN  VARCHAR2, P_VALUE IN VARCHAR2)
	IS
		/* Report table variables */
		entity		VARCHAR2(100) := 'Transaction Type';
		error_type	VARCHAR2(15);
		mesg_name	VARCHAR2(255);
		/* Indicator variables */
		errLogged	BOOLEAN;
		/* OU Array variables */
		ou		NUMBER;
		oulist		SARRAY := SARRAY();
		oulist2		SARRAY := SARRAY();
		oulist3		SARRAY := SARRAY();
		oulist4		SARRAY := SARRAY();
		oulist5		SARRAY := SARRAY();
		oulist6		SARRAY := SARRAY();
		oulist7		SARRAY := SARRAY();
		oulist8		SARRAY := SARRAY();
		oulist9		SARRAY := SARRAY();
		/* Ttypes Array variables */
		ttypes2		SARRAY := SARRAY();
		ttypes3		SARRAY := SARRAY();
		ttypes4		SARRAY := SARRAY();
		ttypes5		SARRAY := SARRAY();
		ttypes6		SARRAY := SARRAY();
		ttypes7		SARRAY := SARRAY();
		ttypes8		SARRAY := SARRAY();
		ttypes9		SARRAY := SARRAY();
		/* Counter variable */
		indx		NUMBER := 1;
		cnt1		NUMBER := 1;
		cnt2		NUMBER := 1;
		cnt3		NUMBER := 1;
		/* Cursor Variables */
		CURSOR csr2 IS
			SELECT T.TRANSACTION_TYPE_ID, T.ORG_ID
			FROM OE_TRANSACTION_TYPES_ALL T
			WHERE NOT T.TRANSACTION_TYPE_ID IN ( SELECT UNIQUE ORDER_TYPE_ID
						       FROM OE_WORKFLOW_ASSIGNMENTS
						       WHERE LINE_TYPE_ID IS NULL );
		csrvar2		csr2%ROWTYPE;
		CURSOR csr3 IS
			SELECT T.TRANSACTION_TYPE_ID, T.ORG_ID
			FROM OE_TRANSACTION_TYPES_ALL T
			WHERE NOT T.TRANSACTION_TYPE_ID IN ( SELECT UNIQUE ORDER_TYPE_ID
				  		       FROM OE_WORKFLOW_ASSIGNMENTS
				  		       WHERE LINE_TYPE_ID IS NOT NULL );
		csrvar3		csr3%ROWTYPE;
		CURSOR csr4 IS
			SELECT TRANSACTION_TYPE_ID, ORG_ID
			FROM OE_TRANSACTION_TYPES_ALL
			WHERE TRANSACTION_TYPE_CODE = 'ORDER'
			AND ORDER_CATEGORY_CODE <> 'RETURN'
			AND DEFAULT_OUTBOUND_LINE_TYPE_ID IS NULL;

		csrvar4		csr4%ROWTYPE;
		CURSOR csr5 IS
			SELECT TRANSACTION_TYPE_ID, ORG_ID
			FROM OE_TRANSACTION_TYPES_ALL
			WHERE TRANSACTION_TYPE_CODE = 'ORDER'
			AND DEFAULT_INBOUND_LINE_TYPE_ID IS NULL
			AND ORDER_CATEGORY_CODE <> 'ORDER';
		csrvar5		csr5%ROWTYPE;
		CURSOR csr6 IS
			SELECT TRANSACTION_TYPE_ID, ORG_ID
			FROM OE_TRANSACTION_TYPES_ALL
			WHERE ENTRY_CREDIT_CHECK_RULE_ID IS NULL
			AND SHIPPING_CREDIT_CHECK_RULE_ID IS NULL;
		csrvar6		csr6%ROWTYPE;
		CURSOR csr7 IS
			SELECT TRANSACTION_TYPE_ID, ORG_ID
			FROM OE_TRANSACTION_TYPES_ALL
			WHERE SCHEDULING_LEVEL_CODE IS NULL;
		csrvar7		csr6%ROWTYPE;
		CURSOR csr8 IS
			SELECT TRANSACTION_TYPE_ID, ORG_ID
			FROM OE_TRANSACTION_TYPES_ALL
			WHERE COST_OF_GOODS_SOLD_ACCOUNT IS NULL;
		csrvar8		csr8%ROWTYPE;
		CURSOR csr9 IS
			SELECT TRANSACTION_TYPE_ID, ORG_ID
			FROM OE_TRANSACTION_TYPES_ALL
			WHERE NON_DELIVERY_INVOICE_SOURCE_ID IS NULL
			AND INVOICE_SOURCE_ID IS NULL;
		csrvar9		csr9%ROWTYPE;
		CURSOR csr10 IS
			SELECT UNIQUE ORG_ID
			FROM OE_TRANSACTION_TYPES_ALL
			WHERE CUST_TRX_TYPE_ID IS NULL;
		csrvar10	csr10%ROWTYPE;
	BEGIN
		IF ( P_LEVEL = 'OU' ) THEN
			oulist.extend(1);
			oulist(1) := P_VALUE;
		ELSE
			oulist.extend(4000);
			FOR i IN 1..RESP_LIST.COUNT
			LOOP
				ou := getOperatingUnit( RESP_LIST(i) );
				IF ( ou <> -1 ) THEN
					oulist(indx) := ou;
					indx := indx + 1;
				END IF;
			END LOOP;
			oulist := getUniqueList(trimArray( oulist ));
		END IF;
		FOR i IN 1..oulist.COUNT
		LOOP
			SELECT COUNT(TRANSACTION_TYPE_ID)
			INTO cnt1
			FROM OE_TRANSACTION_TYPES_ALL
			WHERE ORG_ID = oulist(i);
			IF ( cnt1 = 0 ) THEN
				error_type := 'ERROR';
				mesg_name := 'ONT_SETVAL_INVALID_TRAN_TYPE_1';
				errLogged := writeError( entity, p_level, p_value, error_type, mesg_name,
				    null, null, getOuName(oulist(i)), null, null, null, null,
				    null, null, null, null );
			END IF;
			OPEN csr2;
			FETCH csr2 INTO csrvar2;
			LOOP
				error_type := 'ERROR';
				mesg_name := 'ONT_SETVAL_INVALID_TRAN_TYPE_2';
				IF csrvar2.ORG_ID = oulist(i) THEN
					errLogged:= writeError( entity, p_level, p_value, error_type, mesg_name,
					    null, null, getOuName(csrvar2.ORG_ID), null, null, null, null,
					    null, getTtypeName(csrvar2.TRANSACTION_TYPE_ID), null, null );
				END IF;
				FETCH csr2 INTO csrvar2;
				EXIT WHEN csr2%NOTFOUND;
			END LOOP;
			CLOSE csr2;
			OPEN csr3;
			FETCH csr3 INTO csrvar3;
			LOOP
				error_type := 'ERROR';
				mesg_name := 'ONT_SETVAL_INVALID_TRAN_TYPE_3';
				IF csrvar3.ORG_ID = oulist(i) THEN
					errLogged := writeError( entity, p_level, p_value, error_type, mesg_name,
					    null, null, getOuName(csrvar3.ORG_ID), null, null, null, null,
					    null, getTtypeName(csrvar3.TRANSACTION_TYPE_ID), null, null );
				END IF;
				FETCH csr3 INTO csrvar3;
				EXIT WHEN csr3%NOTFOUND;
			END LOOP;
			CLOSE csr3;
			OPEN csr4;
			FETCH csr4 INTO csrvar4;
			LOOP
				error_type := 'WARNING';
				mesg_name := 'ONT_SETVAL_INVALID_TRAN_TYPE_9';
				IF csrvar4.ORG_ID = oulist(i) THEN
					errLogged := writeError( entity, p_level, p_value, error_type, mesg_name,
					    null, null, getOuName(csrvar4.ORG_ID), null, null, null, null,
					    null, getTtypeName(csrvar4.TRANSACTION_TYPE_ID), null, null );
				END IF;
				FETCH csr4 INTO csrvar4;
				EXIT WHEN csr4%NOTFOUND;
			END LOOP;
			CLOSE csr4;
			OPEN csr5;
			FETCH csr5 INTO csrvar5;
			LOOP
				error_type := 'WARNING';
				mesg_name := 'ONT_SETVAL_INVALID_TRAN_TYPE10';
				IF csrvar5.ORG_ID = oulist(i) THEN
					errLogged := writeError( entity, p_level, p_value, error_type, mesg_name,
					    null, null, getOuName(csrvar5.ORG_ID), null, null, null, null,
					    null, getTtypeName(csrvar5.TRANSACTION_TYPE_ID), null, null );
				END IF;
				FETCH csr5 INTO csrvar5;
				EXIT WHEN csr5%NOTFOUND;
			END LOOP;
			CLOSE csr5;
			/*
			OPEN csr6;
			FETCH csr6 INTO csrvar6;
			LOOP
				error_type := 'WARNING';
				mesg_name := 'ONT_SETVAL_INVALID_TRAN_TYPE_4';
				IF csrvar6.ORG_ID = oulist(i) THEN
					errLogged := writeError( entity, p_level, p_value, error_type, mesg_name,
					    null, null, getOuName(csrvar6.ORG_ID), null, null, null, null,
					    null, getTtypeName(csrvar6.TRANSACTION_TYPE_ID), null, null );
				END IF;
				FETCH csr6 INTO csrvar6;
				EXIT WHEN csr6%NOTFOUND;
			END LOOP;
			CLOSE csr6;
			*/
			OPEN csr7;
			FETCH csr7 INTO csrvar7;
			LOOP
				error_type := 'WARNING';
				mesg_name := 'ONT_SETVAL_INVALID_TRAN_TYPE_5';
				IF csrvar7.ORG_ID = oulist(i) THEN
					errLogged := writeError( entity, p_level, p_value, error_type, mesg_name,
					    null, null, getOuName(csrvar7.ORG_ID), null, null, null, null,
					    null, getTtypeName(csrvar7.TRANSACTION_TYPE_ID), null, null );
				END IF;
				FETCH csr7 INTO csrvar7;
				EXIT WHEN csr7%NOTFOUND;
			END LOOP;
			CLOSE csr7;
			OPEN csr8;
			FETCH csr8 INTO csrvar8;
			LOOP
				error_type := 'WARNING';
				mesg_name := 'ONT_SETVAL_INVALID_TRAN_TYPE_6';
				IF csrvar8.ORG_ID = oulist(i) THEN
					errLogged := writeError( entity, p_level, p_value, error_type, mesg_name,
					    null, null, getOuName(csrvar8.ORG_ID), null, null, null, null,
					    null, getTtypeName(csrvar8.TRANSACTION_TYPE_ID), null, null );
				END IF;
				FETCH csr8 INTO csrvar8;
				EXIT WHEN csr8%NOTFOUND;
			END LOOP;
			CLOSE csr8;
			OPEN csr9;
			FETCH csr9 INTO csrvar9;
			LOOP
				error_type := 'WARNING';
				mesg_name := 'ONT_SETVAL_INVALID_TRAN_TYPE_7';
				IF csrvar9.ORG_ID = oulist(i) THEN
					errLogged := writeError( entity, p_level, p_value, error_type, mesg_name,
					    null, null, getOuName(csrvar9.ORG_ID), null, null, null, null,
					    null, getTtypeName(csrvar9.TRANSACTION_TYPE_ID), null, null );
				END IF;
				FETCH csr9 INTO csrvar9;
				EXIT WHEN csr9%NOTFOUND;
			END LOOP;
			CLOSE csr9;
			OPEN csr10;
			FETCH csr10 INTO csrvar10;
			LOOP
				error_type := 'WARNING';
				mesg_name := 'ONT_SETVAL_INVALID_TRAN_TYPE_8';
				IF csrvar10.ORG_ID = oulist(i) THEN
					errLogged := writeError( entity, p_level, p_value, error_type, mesg_name,
					    null, null, getOuName(csrvar10.ORG_ID), null, null, null, null,
					    null, null, null, null );
				END IF;
				FETCH csr10 INTO csrvar10;
				EXIT WHEN csr10%NOTFOUND;
			END LOOP;
			CLOSE csr10;
		END LOOP;
	END VALIDATE_TRANSACTION_TYPES;
	PROCEDURE VALIDATE_DOC_SEQ_SALES_ORDERS(P_LEVEL  IN  VARCHAR2, P_VALUE IN VARCHAR2)
	IS
		/* Report table variables */
		entity		VARCHAR2(100) := 'Document Sequences For Sales Orders';
		error_type	VARCHAR2(15)  ;
		mesg_name	VARCHAR2(255) ;
		/* Indicator variables */
		errLogged	BOOLEAN;
		isError 	BOOLEAN:=FALSE;
		omdef		BOOLEAN:=FALSE;
		/* Counter Variables */
		indx		NUMBER:=1;
		docseqcnt	NUMBER:=0;
		dscatcnt	NUMBER:=0;
		actcount	NUMBER:=0;
		sobcount	NUMBER:=0;
		/* Array Variables */
		oulist		SARRAY:=SARRAY();
		/* Local Variables */
		ou		NUMBER;
		sobcat		NUMBER;
		sobhr		NUMBER;
		/* Cursor Variables */
		CURSOR ttypes IS
			SELECT tl.NAME, b.ORG_ID
			FROM OE_TRANSACTION_TYPES_TL tl, OE_TRANSACTION_TYPES_ALL b
			WHERE tl.TRANSACTION_TYPE_ID = b.TRANSACTION_TYPE_ID
			AND tl.LANGUAGE=USERENV('LANG')
			ORDER BY b.ORG_ID;
		ttype		ttypes%ROWTYPE;
		CURSOR doccats IS
			SELECT tta.ORG_ID, fdsc.CODE, fdsc.NAME
			FROM FND_DOC_SEQUENCE_CATEGORIES fdsc
			     , OE_TRANSACTION_TYPES_ALL tta
			     , OE_TRANSACTION_TYPES_TL  ttl
			WHERE ttl.NAME = fdsc.NAME
			AND tta.TRANSACTION_TYPE_ID = ttl.TRANSACTION_TYPE_ID
			AND ttl.LANGUAGE=USERENV('LANG')
			ORDER BY tta.ORG_ID;
		doccat		doccats%ROWTYPE;
	BEGIN
		SELECT COUNT(DOC_SEQUENCE_ID)
		INTO docseqcnt
		FROM FND_DOCUMENT_SEQUENCES
		WHERE APPLICATION_ID = 660;
		IF docseqcnt = 0 THEN
			error_type := 'ERROR';
			mesg_name := 'ONT_SETVAL_NOTFOUND_DOC_SEQ';
			errLogged := writeError( entity, p_level, p_value, error_type, mesg_name,
			    null, null, null, null, null, null, null, null, null, null, null );
		END IF;
		IF ( P_LEVEL = 'OU' ) THEN
			oulist.extend(1);
			oulist(1) := P_VALUE;
		ELSE
			oulist.extend(4000);
			FOR i IN 1..RESP_LIST.COUNT
			LOOP
				ou := getOperatingUnit( RESP_LIST(i) );
				IF ( ou <> -1 ) THEN
					oulist(indx) := ou;
					indx := indx + 1;
				END IF;
			END LOOP;
			oulist := getUniqueList(trimArray( oulist ));
		END IF;
		FOR i IN 1..oulist.COUNT
		LOOP
			OPEN ttypes;
			FETCH ttypes INTO ttype;
			LOOP
				IF ttype.ORG_ID = oulist(i) THEN
					SELECT COUNT(NAME)
					INTO dscatcnt
					FROM FND_DOC_SEQUENCE_CATEGORIES
					WHERE NAME = ttype.NAME
					AND TABLE_NAME = 'OE_TRANSACTION_TYPES_ALL';
					IF dscatcnt = 0 THEN
						error_type := 'ERROR';
						mesg_name := 'ONT_SETVAL_NOTFOUND_DOC_CAT';
						errLogged := writeError( entity, p_level, p_value, error_type,
								mesg_name, null, null, getOuName(oulist(i)),
								null, null, null, null, null, ttype.NAME,
								null, null );
					END IF;
				END IF;
				FETCH ttypes INTO ttype;
				EXIT WHEN ttypes%NOTFOUND;
			END LOOP;
			CLOSE ttypes;
			OPEN doccats;
			FETCH doccats INTO doccat;
			LOOP
				IF (doccat.ORG_ID = oulist(i) ) THEN
					BEGIN
						SELECT UNIQUE SET_OF_BOOKS_ID
						INTO sobhr
						FROM HR_OPERATING_UNITS
						WHERE ORGANIZATION_ID = doccat.ORG_ID;
					EXCEPTION
					WHEN OTHERS THEN
						sobhr := -1;
						isError := TRUE;
					END;
					IF ( sobhr <> -1 ) THEN
						SELECT COUNT(DOC_SEQUENCE_ASSIGNMENT_ID)
						INTO actcount
						FROM FND_DOC_SEQUENCE_ASSIGNMENTS
						WHERE CATEGORY_CODE = doccat.CODE
						AND START_DATE <= SYSDATE
						AND SYSDATE <= NVL ( END_DATE, SYSDATE)
						AND SET_OF_BOOKS_ID = sobhr;
					END IF;
					IF actcount = 0 THEN
						error_type := 'ERROR';
						mesg_name := 'ONT_SETVAL_INACTIVE_DOC_SEQ';
						errLogged := writeError( entity, p_level, p_value, error_type,
								mesg_name, null, null, null, null, null, null, null,
								null, null, doccat.NAME, null );
					END IF;
				END IF;
				FETCH doccats INTO doccat;
				EXIT WHEN doccats%NOTFOUND;
			END LOOP;
			CLOSE doccats;
			omdef := checkForOmOu(oulist(i));
			IF omdef = TRUE THEN
				BEGIN
					SELECT UNIQUE SET_OF_BOOKS_ID
					INTO sobhr
					FROM HR_OPERATING_UNITS
					WHERE ORGANIZATION_ID = doccat.ORG_ID;
				EXCEPTION
				WHEN OTHERS THEN
					sobhr := -1;
					isError := TRUE;
				END;
				IF ( sobhr <> -1 ) THEN
					SELECT COUNT(SET_OF_BOOKS_ID)
					into sobcount
					FROM FND_DOC_SEQUENCE_ASSIGNMENTS
					WHERE SET_OF_BOOKS_ID = sobhr;
				END IF;
				IF ( sobcount = 0 ) THEN
					error_type := 'ERROR';
					mesg_name := 'ONT_SETVAL_INVALID_DOC_SEQ';
					errLogged := writeError( entity, p_level, p_value, error_type,
							mesg_name, null, null, null, null, null, null,
							null, null, null, null, null );
				END IF;
			END IF;
		END LOOP;
	END VALIDATE_DOC_SEQ_SALES_ORDERS;
	PROCEDURE VALIDATE_CREDIT_CHECKING(P_LEVEL  IN  VARCHAR2, P_VALUE IN VARCHAR2)
	IS
		/* Report table variables */
		entity		VARCHAR2(100) := 'Credit Checking Setup';
		error_type	VARCHAR2(15)  ;
		mesg_name	VARCHAR2(255) ;
		/* Counter Variables */
		ccrcnt		NUMBER:=0;
		custcnt		NUMBER:=0;
		creqcnt		NUMBER:=0;
		ccexcnt		NUMBER:=0;
		ptcount		NUMBER:=0;
		indx		NUMBER:=1;
		/* Array Variables */
		oulist		SARRAY:=SARRAY();
		/* Local Variables */
		ou		NUMBER;
		sob		VARCHAR2(50);
		/* Cursor Variables */
		CURSOR ttdisabled IS
			SELECT tl.NAME, b.ORG_ID
			FROM OE_TRANSACTION_TYPES_ALL b
			     , OE_TRANSACTION_TYPES_TL tl
			WHERE ENTRY_CREDIT_CHECK_RULE_ID IS NULL
			AND SHIPPING_CREDIT_CHECK_RULE_ID IS NULL
			AND PICKING_CREDIT_CHECK_RULE_ID IS NULL
			AND PACKING_CREDIT_CHECK_RULE_ID IS NULL
			AND tl.LANGUAGE = USERENV('LANG')
			AND tl.TRANSACTION_TYPE_ID = b.TRANSACTION_TYPE_ID;
		ttypes		ttdisabled%ROWTYPE;
		/* Indicator Variables */
		errLogged	BOOLEAN;
	BEGIN
		SELECT COUNT(CREDIT_CHECK_RULE_ID)
		INTO ccrcnt
		FROM OE_CREDIT_CHECK_RULES;
		IF ( ccrcnt = 0 ) THEN
			error_type := 'WARNING';
			mesg_name := 'ONT_SETVAL_CC_NOTFOUND';
			errLogged := writeError( entity, p_level, p_value, error_type, mesg_name,
			    null, null, null, null, null, null, null, null, null, null, null );
		END IF;
		IF ( P_LEVEL = 'OU' ) THEN
			oulist.extend(1);
			oulist(1) := P_VALUE;
		ELSE
			oulist.extend(4000);
			FOR i IN 1..RESP_LIST.COUNT
			LOOP
				ou := getOperatingUnit( RESP_LIST(i) );
				IF ( ou <> -1 ) THEN
					oulist(indx) := ou;
					indx := indx + 1;
				END IF;
			END LOOP;
			oulist := getUniqueList(trimArray(oulist));
		END IF;
		SELECT COUNT(TERM_ID)
		INTO ptcount
		FROM RA_TERMS_B
		WHERE CREDIT_CHECK_FLAG = 'Y';
		FOR i IN 1..oulist.COUNT
		LOOP
			error_type := 'WARNING';
			mesg_name := 'ONT_SETVAL_CC_INVALID_PAY_TERM';
			IF ( ptcount = 0 ) THEN
				SELECT gl.name
				INTO sob
				FROM GL_SETS_OF_BOOKS gl
				     , HR_OPERATING_UNITS hou
				WHERE hou.organization_id = oulist(i)
				AND gl.set_of_books_id = hou.set_of_books_id;
				errLogged := writeError( entity, p_level, p_value, error_type, mesg_name,
				    null, null, getOuName(oulist(i)), null, null, sob, null, null,
				    null, null, null );
			END IF;
			error_type := 'WARNING';
			mesg_name := 'ONT_SETVAL_CC_INVALID_TRAN_TYP';
			OPEN ttdisabled;
			FETCH ttdisabled INTO ttypes;
			LOOP
				IF ( ttypes.ORG_ID = oulist(i) ) THEN
					errLogged := writeError( entity, p_level, p_value, error_type, mesg_name,
					    null, null, getOuName(oulist(i)), null, null, null, null, null,
					    ttypes.NAME, null, null );
				END IF;
				FETCH ttdisabled INTO ttypes;
				EXIT WHEN ttdisabled%NOTFOUND;
			END LOOP;
			CLOSE ttdisabled;
			error_type := 'WARNING';
			mesg_name := 'ONT_SETVAL_CC_INVALID_CUST';
			SELECT COUNT(CUST_ACCOUNT_PROFILE_ID)
			INTO custcnt
			FROM HZ_CUSTOMER_PROFILES
			WHERE CREDIT_CHECKING = 'Y';
			IF custcnt = 0 THEN
				errLogged := writeError( entity, p_level, p_value, error_type, mesg_name,
				    null, null, getOuName(oulist(i)), null, null, null, null, null,
				    null, null, null );
			END IF;
			error_type := 'WARNING';
			mesg_name := 'ONT_SETVAL_CC_PRE_CALC_EXPO';
			SELECT COUNT(CREDIT_CHECK_RULE_ID)
			INTO ccexcnt
			FROM OE_CREDIT_CHECK_RULES
			WHERE QUICK_CR_CHECK_FLAG = 'Y';
			SELECT COUNT(fcr.REQUEST_ID)
			INTO creqcnt
			FROM FND_CONCURRENT_REQUESTS fcr, FND_CONCURRENT_PROGRAMS_TL fcp
			WHERE fcr.CONCURRENT_PROGRAM_ID=fcp.concurrent_program_id
			AND (( fcr.PHASE_CODE='P' AND fcr.STATUS_CODE='Q'
			OR  fcr.PHASE_CODE='P' AND fcr.STATUS_CODE='R' )
			OR  ( fcr.PHASE_CODE='R' AND fcr.STATUS_CODE='R' ))
			AND fcp.USER_CONCURRENT_PROGRAM_NAME like 'Initialize Credit Summaries Table'
			AND fcp.LANGUAGE = USERENV('LANG');
			IF ccexcnt > 0 and creqcnt = 0 THEN
				errLogged := writeError( entity, p_level, p_value, error_type, mesg_name,
				    null, null, getOuName(oulist(i)), null, null, null, null, null,
				    null, null, null );
			END IF;
		END LOOP;
	END VALIDATE_CREDIT_CHECKING;
	PROCEDURE VALIDATE_ITEM_DEFINITION(P_LEVEL  IN  VARCHAR2, P_VALUE IN VARCHAR2)
	IS
		/* Report table variables */
		entity		VARCHAR2(100) := 'Item Definition';
		error_type	VARCHAR2(15)  := 'ERROR';
		mesg_name	VARCHAR2(255) := 'ONT_SETVAL_INVALID_ITEM';
		/* Counter Variables */
		indx		NUMBER:=1;
		itmcnt		NUMBER:=0;
		/* Array Variables */
		oulist		SARRAY:=SARRAY();
		/* Local Variables */
		ou		NUMBER;
		mstrorg		NUMBER;
		arstatus	VARCHAR2(1);
		/* Indicator Variables */
		errLogged	BOOLEAN;
	BEGIN
		BEGIN
			SELECT STATUS
			INTO arstatus
			FROM FND_PRODUCT_INSTALLATIONS
			WHERE APPLICATION_ID = 222;
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			arstatus := 'N';
		END;
		IF ( P_LEVEL = 'OU' ) THEN
			oulist.extend(1);
			oulist(1) := P_VALUE;
		ELSE
			oulist.extend(4000);
			FOR i IN 1..RESP_LIST.COUNT
			LOOP
				ou := getOperatingUnit( RESP_LIST(i) );
				IF ( ou <> -1 ) THEN
					oulist(indx) := ou;
					indx := indx + 1;
				END IF;
			END LOOP;
			oulist := getUniqueList(trimArray(oulist));
		END IF;
		FOR i IN 1..oulist.COUNT
		LOOP
                    -- Start Sys Param Change
                    /*
			BEGIN
				SELECT MASTER_ORGANIZATION_ID
				INTO mstrorg
				FROM OE_SYSTEM_PARAMETERS_ALL
				WHERE ORG_ID = oulist(i);
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				mstrorg := null;
			END;
                      */
                        mstrorg :=
                          oe_sys_parameters.value('MASTER_ORGANIZATION_ID',oulist(i));
                      -- End Sys Param Change
			IF mstrorg IS NOT NULL THEN
				IF arstatus = 'I' THEN
					SELECT COUNT(INVENTORY_ITEM_ID)
					INTO itmcnt
					FROM MTL_SYSTEM_ITEMS_B
					WHERE ORGANIZATION_ID = mstrorg
					AND MTL_TRANSACTIONS_ENABLED_FLAG = 'Y'
					AND CUSTOMER_ORDER_FLAG = 'Y'
					AND CUSTOMER_ORDER_ENABLED_FLAG = 'Y'
					AND RETURNABLE_FLAG = 'Y'
					AND INTERNAL_ORDER_FLAG = 'Y'
					AND INTERNAL_ORDER_ENABLED_FLAG = 'Y'
					AND SHIPPABLE_ITEM_FLAG = 'Y'
					AND INVOICEABLE_ITEM_FLAG = 'Y'
					AND RESERVABLE_TYPE = 1
					AND INVOICE_ENABLED_FLAG = 'Y';
				ELSE
					SELECT COUNT(INVENTORY_ITEM_ID)
					INTO itmcnt
					FROM MTL_SYSTEM_ITEMS_B
					WHERE ORGANIZATION_ID = mstrorg
					AND MTL_TRANSACTIONS_ENABLED_FLAG = 'Y'
					AND CUSTOMER_ORDER_FLAG = 'Y'
					AND CUSTOMER_ORDER_ENABLED_FLAG = 'Y'
					AND RETURNABLE_FLAG = 'Y'
					AND INTERNAL_ORDER_FLAG = 'Y'
					AND INTERNAL_ORDER_ENABLED_FLAG = 'Y'
					AND SHIPPABLE_ITEM_FLAG = 'Y'
					AND RESERVABLE_TYPE = 1
					AND INVOICEABLE_ITEM_FLAG = 'Y';
				END IF;
			END IF;
			IF itmcnt = 0 THEN
				errLogged := writeError( entity, p_level, p_value, error_type, mesg_name, null,
					    null, getOuName(mstrorg), getOuName(mstrorg), null, null, null, null, null, null,
					    null );
			END IF;
		END LOOP;
	END VALIDATE_ITEM_DEFINITION;
	PROCEDURE VALIDATE_PRICE_LIST_DEFINITION(P_LEVEL  IN  VARCHAR2, P_VALUE IN VARCHAR2)
	IS
		/* Report table variables */
		entity		VARCHAR2(100) := 'Price List Definition';
		error_type	VARCHAR2(15)  := 'ERROR';
		mesg_name	VARCHAR2(255) := 'ONT_SETVAL_INVALID_PRC_LST';
		/* Counter Variables */
		prclstct	NUMBER := 1;
		/* Indicator Variables */
		errLogged	BOOLEAN;
	BEGIN
		SELECT COUNT(QLLV.LIST_HEADER_ID)
		INTO prclstct
		FROM QP_LIST_LINES_V QLLV, QP_LIST_HEADERS_B QLHB
		WHERE QLLV.LIST_HEADER_ID = QLHB.LIST_HEADER_ID
		/* Commented as it is not required.
		AND SYSDATE >= NVL(QLHB.START_DATE_ACTIVE, TO_DATE('01-JAN-1000','DD-MON-YYYY'))
		AND SYSDATE <  NVL(QLHB.END_DATE_ACTIVE, TO_DATE('31-DEC-2999'))
		*/
		AND QLLV.PRODUCT_ATTRIBUTE = 'PRICING_ATTRIBUTE1'
		AND QLHB.LIST_HEADER_ID IN (SELECT LIST_HEADER_ID
					    FROM QP_LIST_HEADERS_B);
		IF prclstct = 0 THEN
			errLogged := writeError( entity, p_level, p_value, error_type, mesg_name, null,
				    null, null, null, null, null, null, null, null, null, null );
		END IF;
	END VALIDATE_PRICE_LIST_DEFINITION;
	PROCEDURE VALIDATE_SALES_CRDT_DEFINITION(P_LEVEL  IN  VARCHAR2, P_VALUE IN VARCHAR2)
	IS
		/* Report table variables */
		entity		VARCHAR2(100) := 'Sales Credit';
		error_type	VARCHAR2(15)  := 'WARNING';
		mesg_name	VARCHAR2(255) := 'ONT_SETVAL_INVALID_SLS_CRDT';
		/* Counter variables */
		qcnt		NUMBER := 1;
		nqcnt		NUMBER := 1;
		qtype		VARCHAR2(10);
		/* Indicator Variables */
		isError		BOOLEAN := TRUE;
		errLogged	BOOLEAN;
	BEGIN
		SELECT COUNT(QUOTA_FLAG)
		INTO qcnt
		FROM OE_SALES_CREDIT_TYPES
		WHERE QUOTA_FLAG = 'Y';
		SELECT COUNT(QUOTA_FLAG)
		INTO nqcnt
		FROM OE_SALES_CREDIT_TYPES
		WHERE QUOTA_FLAG IS NULL
		OR QUOTA_FLAG = 'N';
		IF qcnt=0 AND nqcnt=0 THEN
			qtype := 'BOTH';
		ELSIF qcnt=0 THEN
			qtype := 'QUOTA';
		ELSIF nqcnt = 0 THEN
			qtype := 'NON QUOTA';
		ELSE
			isError := FALSE;
		END IF;
		IF isError = TRUE THEN
			errLogged := writeError( entity, p_level, p_value, error_type, mesg_name, qtype,
				    null, null, null, null, null, null, null, null, null, null );
		END IF;
	END VALIDATE_SALES_CRDT_DEFINITION;
	PROCEDURE VALIDATE_PERIOD_STATUS(P_LEVEL  IN  VARCHAR2, P_VALUE IN VARCHAR2)
	IS
		/* Report table variables */
		entity		VARCHAR2(100) := 'Period Status';
		error_type	VARCHAR2(15)  := 'WARNING';
		mesg_name	VARCHAR2(255) := 'ONT_SETVAL_INVALID_SLS_CRDT';
		/* Counter Variables */
		opencnt		NUMBER:=0;
		currcnt		NUMBER:=0;
		/* Array Variables */
		oulist		SARRAY:=SARRAY();
		shiporgs	SARRAY:=SARRAY();
		/* Local Variables */
		ou		NUMBER;
		status		VARCHAR2(10);
		/* Counter Variables */
		indx		NUMBER:=1;
		/* Indicator Variables */
		errLogged	BOOLEAN;
	BEGIN
		IF ( P_LEVEL = 'OU' ) THEN
			oulist.extend(1);
			oulist(1) := P_VALUE;
		ELSE
			oulist.extend(4000);
			FOR i IN 1..RESP_LIST.COUNT
			LOOP
				ou := getOperatingUnit( RESP_LIST(i) );
				IF ( ou <> -1 ) THEN
					oulist(indx) := ou;
					indx := indx + 1;
				END IF;
			END LOOP;
			oulist := getUniqueList(trimArray(oulist));
		END IF;
		FOR i IN 1..oulist.COUNT
		LOOP
			shiporgs := getUniqueList(getShippingOrgsForOu(oulist(i)));
			FOR j IN 1..shiporgs.COUNT
			LOOP
				SELECT COUNT(ORGANIZATION_ID)
				INTO opencnt
				FROM ORG_ACCT_PERIODS_V
				WHERE ORGANIZATION_ID = shiporgs(j)
				AND STATUS = 'Open';
				SELECT COUNT(ORGANIZATION_ID)
				INTO currcnt
				FROM ORG_ACCT_PERIODS_V
				WHERE ORGANIZATION_ID = shiporgs(j)
				AND SYSDATE >= START_DATE
				AND SYSDATE <  END_DATE
				AND STATUS = 'Open';
				IF opencnt = 0 THEN
					error_type := 'WARNING';
					mesg_name := 'ONT_SETVAL_NO_OPEN_PERIOD';
					errLogged := writeError( entity, p_level, p_value, error_type,
							  mesg_name, null, null, getOuName(oulist(i)), getOuName(shiporgs(j)),
							  null, null, null, null, null, null, null );
				END IF;
				IF currcnt = 0 THEN
					error_type := 'WARNING';
					mesg_name := 'ONT_SETVAL_INVALID_CURR_PERIOD';
					errLogged := writeError( entity, p_level, p_value, error_type,
							  mesg_name, null, null, getOuName(oulist(i)), getOuName(shiporgs(j)),
							  null, null, null, null, null, null, null );
				END IF;
			END LOOP;
		END LOOP;
	END VALIDATE_PERIOD_STATUS;
	PROCEDURE VALIDATE_SHIPPING_ORGS(P_LEVEL  IN  VARCHAR2, P_VALUE IN VARCHAR2)
	IS
		/* Report table variables */
		entity		VARCHAR2(100) := 'Shipping Organizations';
		error_type	VARCHAR2(15)  ;
		mesg_name	VARCHAR2(255) ;
		/* Array Variables */
		oulist		SARRAY:=SARRAY();
		shiporgs	SARRAY:=SARRAY();
		/* Local Variables */
		ou		NUMBER;
		dftstgsub	VARCHAR2(100);
		/* Counter Variables */
		indx		NUMBER:=1;
		shsecnt		NUMBER:=0;
		shipcnt		NUMBER:=0;
		shorgscnt	NUMBER:=0;
		secinvcnt	NUMBER:=0;
		pickcnt		NUMBER:=0;
		/* Indicator Variables */
		errLogged	BOOLEAN;
	BEGIN
		IF ( P_LEVEL = 'OU' ) THEN
			oulist.extend(1);
			oulist(1) := P_VALUE;
		ELSE
			oulist.extend(4000);
			FOR i IN 1..RESP_LIST.COUNT
			LOOP
				ou := getOperatingUnit( RESP_LIST(i) );
				IF ( ou <> -1 ) THEN
					oulist(indx) := ou;
					indx := indx + 1;
				END IF;
			END LOOP;
			oulist := getUniqueList(trimArray(oulist));
		END IF;
		FOR i IN 1..oulist.COUNT
		LOOP
			shiporgs := getUniqueList(getShippingOrgsForOu(oulist(i)));
			SELECT COUNT(FREIGHT_CODE_COMBINATION_ID)
			INTO shsecnt
			FROM MTL_INTERCOMPANY_PARAMETERS
			WHERE SHIP_ORGANIZATION_ID = oulist(i)
			OR SELL_ORGANIZATION_ID = oulist(i);
			IF shsecnt <> 0 THEN
				SELECT COUNT(FREIGHT_CODE_COMBINATION_ID)
				INTO shipcnt
				FROM MTL_INTERCOMPANY_PARAMETERS
				WHERE SHIP_ORGANIZATION_ID = oulist(i);
			END IF;
			IF ( shsecnt = 0 ) OR ( shsecnt <> 0 AND shipcnt <> 0 ) THEN
				FOR j IN 1..shiporgs.COUNT
				LOOP
					SELECT COUNT(ORGANIZATION_ID)
					INTO shorgscnt
					FROM WSH_SHIPPING_PARAMETERS
					WHERE ORGANIZATION_ID = shiporgs(j);
					IF shorgscnt > 0 THEN
						EXIT;
					END IF;
				END LOOP;
				IF ( shorgscnt = 0 ) THEN
					error_type := 'ERROR';
					mesg_name := 'ONT_SETVAL_INVALID_SHIP_ORG';
					errLogged := writeError( entity, p_level, p_value, error_type,
						  mesg_name, null, null, getOuName(oulist(i)), null, null, null,
						  null, null, null, null, null );
				END IF;
				FOR j IN 1..shiporgs.COUNT
				LOOP
					SELECT COUNT(ORGANIZATION_ID)
					INTO shorgscnt
					FROM WSH_SHIPPING_PARAMETERS
					WHERE ORGANIZATION_ID = shiporgs(j);
					IF ( shorgscnt = 0 AND checkForOmOu(oulist(i)) = TRUE) THEN
						error_type := 'WARNING';
						mesg_name := 'ONT_SETVAL_INVALID_SHIP_OMORG';
						errLogged := writeError( entity, p_level, p_value, error_type,
							  mesg_name, null, null, getOuName(oulist(i)), getOuName(shiporgs(j)),
							  null, null, null, null, null, null, null );
					END IF;
				END LOOP;
			END IF;
			FOR j IN 1..shiporgs.COUNT
			LOOP
				BEGIN
					SELECT DEFAULT_STAGE_SUBINVENTORY
					INTO dftstgsub
					FROM WSH_SHIPPING_PARAMETERS
					WHERE ORGANIZATION_ID = shiporgs(j);
				EXCEPTION
				WHEN NO_DATA_FOUND THEN
					dftstgsub := null;
				WHEN OTHERS THEN
					dftstgsub := null;
				END;
				IF dftstgsub IS NULL THEN
					error_type := 'ERROR';
					mesg_name := 'ONT_SETVAL_INVALID_DFLT_SUBINV';
					errLogged := writeError( entity, p_level, p_value, error_type,
						  mesg_name, null, null, getOuName(oulist(i)),
						  getOuName(shiporgs(j)), null, null, null, null, null,
						  null, null );
				END IF;
			END LOOP;
			FOR j IN 1..shiporgs.COUNT
			LOOP
				SELECT COUNT(SECONDARY_INVENTORY_NAME)
				INTO secinvcnt
				FROM MTL_SECONDARY_INVENTORIES_FK_V
				WHERE ORGANIZATION_ID = shiporgs(j);
				IF secinvcnt = 0 THEN
					error_type := 'ERROR';
					mesg_name := 'ONT_SETVAL_INVALID_SUBINV_ORGN';
					errLogged := writeError( entity, p_level, p_value, error_type,
						  mesg_name, null, null, getOuName(oulist(i)),
						  getOuName(shiporgs(j)), null, null, null, null, null,
						  null, null );
				END IF;
			END LOOP;
			FOR j IN 1..shiporgs.COUNT
			LOOP
				SELECT COUNT(ORGANIZATION_ID)
				INTO pickcnt
				FROM WSH_SHIPPING_PARAMETERS
				WHERE ORGANIZATION_ID = shiporgs(j)
				AND PICK_SEQUENCE_RULE_ID IS NOT NULL
				AND PICK_GROUPING_RULE_ID IS NOT NULL;
				IF pickcnt = 0 THEN
					error_type := 'ERROR';
					mesg_name := 'ONT_SETVAL_INVALID_PICK_RULES';
					errLogged := writeError( entity, p_level, p_value, error_type,
						  mesg_name, null, null, getOuName(oulist(i)),
						  getOuName(shiporgs(j)), null, null, null, null, null,
						  null, null );
				END IF;
			END LOOP;
		END LOOP;
	  RETURN;
	END VALIDATE_SHIPPING_ORGS;
	PROCEDURE VALIDATE_FREIGHT_CARRIER(P_LEVEL  IN  VARCHAR2, P_VALUE IN VARCHAR2)
	IS
		/* Report table variables */
		entity		VARCHAR2(100) := 'Freight Carrier';
		error_type	VARCHAR2(15)  ;
		mesg_name	VARCHAR2(255) ;
		/* Array Variables */
		oulist		SARRAY:=SARRAY();
		shiporgs	SARRAY:=SARRAY();
		/* Local Variables */
		ou		NUMBER;
		/* Counter Variables */
		indx		NUMBER:=1;
		activect	NUMBER:=0;
		actorgct	NUMBER:=0;
		cashmect	NUMBER:=0;
		/* Indicator Variables */
		errLogged	BOOLEAN;
		dummy_v		VARCHAR2(10);
	BEGIN
      BEGIN
        SELECT 'x'
        INTO   dummy_v
        FROM   org_freight_vl
        WHERE  rownum = 1;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
			error_type := 'ERROR';
			mesg_name := 'ONT_SETVAL_FC_INACTIVE_ALL';
			errLogged := writeError( entity, p_level, p_value, error_type,
					  mesg_name, null, null, null, null, null, null,
					  null, null, null, null, null );
      END;
/*
		SELECT COUNT(FREIGHT_CODE)
		INTO activect
		FROM ORG_FREIGHT_VL;
*/
		/*WHERE SYSDATE <= NVL(DISABLE_DATE, TO_DATE('31-DEC-2999'));*/
/*
		IF activect = 0 THEN
			error_type := 'ERROR';
			mesg_name := 'ONT_SETVAL_FC_INACTIVE_ALL';
			errLogged := writeError( entity, p_level, p_value, error_type,
					  mesg_name, null, null, null, null, null, null,
					  null, null, null, null, null );
		END IF;
*/

		IF ( P_LEVEL = 'OU' ) THEN
			oulist.extend(1);
			oulist(1) := P_VALUE;
		ELSE
			oulist.extend(4000);
			FOR i IN 1..RESP_LIST.COUNT
			LOOP
				ou := getOperatingUnit( RESP_LIST(i) );
				IF ( ou <> -1 ) THEN
					oulist(indx) := ou;
					indx := indx + 1;
				END IF;
			END LOOP;
			oulist := getUniqueList(trimArray(oulist));
		END IF;
		FOR i IN 1..oulist.COUNT
		LOOP
			shiporgs := getUniqueList(getShippingOrgsForOu(oulist(i)));
			FOR j IN 1..shiporgs.COUNT
			LOOP
				SELECT COUNT(ORG_CARRIER_SERVICE_ID)
				INTO actorgct
				FROM WSH_ORG_CARRIER_SERVICES_V
				WHERE ENABLED_FLAG = 'Y'
				AND ORGANIZATION_ID = shiporgs(j);
				SELECT COUNT(FREIGHT_CODE)
				INTO cashmect
				FROM WSH_CARRIER_SHIP_METHODS_V
				WHERE ENABLED_FLAG = 'Y'
				AND ORGANIZATION_ID = shiporgs(j);
			END LOOP;
			IF actorgct=0 THEN
				error_type := 'ERROR';
				mesg_name := 'ONT_SETVAL_FC_INACTIVE_ORG';
				errLogged := writeError( entity, p_level, p_value, error_type,
						  mesg_name, null, null, getOuName(oulist(i)), null, null, null,
						  null, null, null, null, null );
			END IF;
			IF cashmect=0 THEN
				error_type := 'ERROR';
				mesg_name := 'ONT_SETVAL_FC_RELATIONS';
				errLogged := writeError( entity, p_level, p_value, error_type,
						  mesg_name, null, null, getOuName(oulist(i)), null, null, null,
						  null, null, null, null, null );
			END IF;
		END LOOP;
	END VALIDATE_FREIGHT_CARRIER;
	PROCEDURE VALIDATE_DOC_SEQ_SHIPPING(P_LEVEL  IN  VARCHAR2, P_VALUE IN VARCHAR2)
	IS
		/* Report table variables */
		entity		VARCHAR2(100) := 'Document Sequences for Shipping Documents';
		error_type	VARCHAR2(15)  ;
		mesg_name	VARCHAR2(255) ;
		/* Counter Variables */
		doccount	NUMBER := 0;
		bolcount	NUMBER := 0;
		pkslpcnt	NUMBER := 0;
		indx		NUMBER := 1;
		omcnt		NUMBER := 0;
		bolacnt		NUMBER := 0;
		pkslpacnt	NUMBER := 0;
		/* Array Variables */
		oulist		SARRAY := SARRAY();
		/* Local Variables */
		ou		NUMBER;
		sob		NUMBER;
		/* Indicator Variables */
		errLogged	BOOLEAN;
	BEGIN
		SELECT COUNT(DOC_SEQUENCE_ID)
		INTO doccount
		FROM FND_DOCUMENT_SEQUENCES
		WHERE APPLICATION_ID = 665;
		IF ( doccount = 0 ) THEN
			mesg_name := 'ONT_SETVAL_SHIP_DOC_SEQ';
			error_type := 'ERROR';
			errLogged := writeError( entity, p_level, p_value, error_type, mesg_name, null,
				    null, null, null, null, null, null, null, null, null, null );
		END IF;
		SELECT COUNT(wdsc.DOC_SEQUENCE_CATEGORY_ID)
		INTO   bolcount
		FROM  WSH_DOC_SEQUENCE_CATEGORIES wdsc
		     ,FND_DOC_SEQUENCE_CATEGORIES fdsc
		WHERE wdsc.CATEGORY_CODE = fdsc.CODE
		AND fdsc.NAME = 'BOL';
		IF ( bolcount = 0 ) THEN
			mesg_name := 'ONT_SETVAL_SHIP_DOC_BOL';
			error_type := 'WARNING';
			errLogged := writeError( entity, p_level, p_value, error_type, mesg_name, null,
				    null, null, null, null, null, null, null, null, null, null );
		END IF;
		SELECT COUNT(wdsc.DOC_SEQUENCE_CATEGORY_ID)
		INTO   pkslpcnt
		FROM  WSH_DOC_SEQUENCE_CATEGORIES wdsc
		     ,FND_DOC_SEQUENCE_CATEGORIES fdsc
		WHERE wdsc.CATEGORY_CODE = fdsc.CODE
		AND fdsc.NAME = 'BOL';
		IF ( pkslpcnt = 0 ) THEN
			mesg_name := 'ONT_SETVAL_SHIP_DOC_PKSLP';
			error_type := 'WARNING';
			errLogged := writeError( entity, p_level, p_value, error_type, mesg_name, null,
				    null, null, null, null, null, null, null, null, null, null );
		END IF;
		IF ( P_LEVEL = 'OU' ) THEN
			oulist.extend(1);
			oulist(1) := P_VALUE;
		ELSE
			oulist.extend(4000);
			FOR i IN 1..RESP_LIST.COUNT
			LOOP
				ou := getOperatingUnit( RESP_LIST(i) );
				IF ( ou <> -1 ) THEN
					oulist(indx) := ou;
					indx := indx + 1;
				END IF;
			END LOOP;
			oulist := getUniqueList(trimArray(oulist));
		END IF;
		FOR i IN 1..oulist.COUNT
		LOOP
                        -- Sys param Change
                        -- Table oe_system_parameters_all is replaced by oe_sys_parameters_all
			SELECT COUNT(*)
			INTO omcnt
			FROM OE_SYS_PARAMETERS_ALL
			WHERE ORG_ID = oulist(i);
			IF omcnt > 0 THEN
				BEGIN
					SELECT SET_OF_BOOKS_ID
					INTO sob
					FROM HR_OPERATING_UNITS
					WHERE ORGANIZATION_ID = oulist(i);
				EXCEPTION
				WHEN NO_DATA_FOUND THEN
					sob := -1;
				END;
				SELECT COUNT(fdsa.DOC_SEQUENCE_ASSIGNMENT_ID)
				INTO bolacnt
				FROM  FND_DOC_SEQUENCE_ASSIGNMENTS fdsa
				     ,FND_DOC_SEQUENCE_CATEGORIES fdsc
				WHERE SET_OF_BOOKS_ID = sob
				AND CATEGORY_CODE = fdsc.CODE
				AND fdsc.NAME = 'BOL';
				SELECT COUNT(fdsa.DOC_SEQUENCE_ASSIGNMENT_ID)
				INTO pkslpacnt
				FROM  FND_DOC_SEQUENCE_ASSIGNMENTS fdsa
				     ,FND_DOC_SEQUENCE_CATEGORIES fdsc
				WHERE SET_OF_BOOKS_ID = sob
				AND CATEGORY_CODE = fdsc.CODE
				AND fdsc.NAME = 'PKSLP';
				IF ( bolacnt > 0 AND pkslpacnt > 0 ) THEN
					mesg_name := 'ONT_SETVAL_SHIP_DOC_NO_ASSGN';
				ELSE
					mesg_name := 'ONT_SETVAL_SHIP_DOC_SEQ_ASSGN';
					error_type := 'WARNING';
					errLogged := writeError( entity, p_level, p_value, error_type, mesg_name, null,
					    null, null, null, null, null, null, null, null, null, null );
					EXIT;
				END IF;
			END IF;
		END LOOP;
	END VALIDATE_DOC_SEQ_SHIPPING;
	PROCEDURE VALIDATE_SHIPPING_GRANTS_ROLES(P_LEVEL  IN  VARCHAR2, P_VALUE IN VARCHAR2)
	IS
		/* Report table variables */
		entity		VARCHAR2(100) := 'Shipping Grants and Roles';
		error_type	VARCHAR2(15)  ;
		mesg_name	VARCHAR2(255) ;
		/* Counter variables */
		rolecnt		NUMBER := 1;
		/* Temporary Variables */
		roleid		NUMBER;
		/* Indicator Variables */
		isError		BOOLEAN := FALSE;
		errLogged	BOOLEAN;
	BEGIN
		SELECT COUNT(ROLE_ID)
		INTO rolecnt
		FROM WSH_ROLES;
		IF rolecnt = 0 THEN
			error_type := 'ERROR';
			mesg_name := 'ONT_SETVAL_NOTFOUND_ROLES';
			errLogged := writeError( entity, p_level, p_value, error_type, mesg_name, null,
			    null, null, null, null, null, null, null, null, null, null );
		END IF;
		FOR i IN 1..USER_LIST.COUNT
		LOOP
			BEGIN
				SELECT ROLE_ID
				INTO roleid
				FROM WSH_GRANTS
				WHERE USER_ID = USER_LIST(i)
				AND ROWNUM < 2;
				isError := FALSE;
				EXIT;
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				isError := TRUE;
			END;
		END LOOP;
		IF isError = TRUE THEN
			error_type := 'ERROR';
			IF ( USER_LIST.COUNT = 1 ) THEN
			        mesg_name := 'ONT_SETVAL_NOTFOUND_ROLES_USER';
				errLogged := writeError( entity, p_level, p_value, error_type, mesg_name, null,
				    USER_LIST(1), null, null, null, null, null, null, null, null, null );
			ELSE
			        mesg_name := 'ONT_SETVAL_NOTFOUND_ROLE_USERS';
				errLogged := writeError( entity, p_level, p_value, error_type, mesg_name, null,
				    null, null, null, null, null, null, null, null, null, null );

			END IF;
		END IF;
END VALIDATE_SHIPPING_GRANTS_ROLES;
END OM_SETUP_VALID_PKG;


/
