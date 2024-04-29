--------------------------------------------------------
--  DDL for Package Body OKS_INSERT_ROW_UPG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_INSERT_ROW_UPG" AS
/* $Header: OKSCOVUB.pls 120.0 2005/05/25 17:40:38 appldev noship $ */


l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

PROCEDURE INSERT_ROW_UPG_CTZV_TBL
						(x_return_status OUT NOCOPY VARCHAR2,
						P_CTZV_TBL  OKS_CTZ_PVT.OksCoverageTimezonesVTblType) IS

		l_tabsize NUMBER := P_CTZV_TBL.COUNT;
		l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;
		In_ID           OKC_DATATYPES.NumberTabTyp;
		In_CLE_ID           OKC_DATATYPES.NumberTabTyp;
		In_DEFAULT_YN           OKC_DATATYPES.VAR3TabTyp;
		In_TIMEZONE_ID           OKC_DATATYPES.NumberTabTyp;
		In_DNZ_CHR_ID           OKC_DATATYPES.NumberTabTyp;
		In_CREATED_BY           OKC_DATATYPES.NumberTabTyp;
		In_CREATION_DATE           OKC_DATATYPES.DateTabTyp;
		In_LAST_UPDATED_BY           OKC_DATATYPES.NumberTabTyp;
		In_LAST_UPDATE_DATE           OKC_DATATYPES.DateTabTyp;
		In_LAST_UPDATE_LOGIN           OKC_DATATYPES.NumberTabTyp;
		In_SECURITY_GROUP_ID           OKC_DATATYPES.NumberTabTyp;
		In_PROGRAM_APPLICATION_ID           OKC_DATATYPES.NumberTabTyp;
		In_PROGRAM_ID           OKC_DATATYPES.NumberTabTyp;
		In_PROGRAM_UPDATE_DATE           OKC_DATATYPES.DateTabTyp;
		In_REQUEST_ID           OKC_DATATYPES.NumberTabTyp;
		In_OBJECT_VERSION_NUMBER           OKC_DATATYPES.NumberTabTyp;
		i                                NUMBER := P_CTZV_TBL.FIRST;
		j                                NUMBER := 0;

BEGIN
		x_return_status := OKC_API.G_RET_STS_SUCCESS;
		IF (l_debug = 'Y') THEN
			okc_debug.Set_Indentation('OKS_CTZ_PVT');
			okc_debug.log('23400: Entered INSERT_ROW_UPG', 2);
		END IF;

WHILE i IS NOT NULL LOOP

		j                               := j +1;
		In_ID(j)    :=      P_CTZV_TBL(i).ID;
		In_CLE_ID(j)    :=      P_CTZV_TBL(i).CLE_ID;
		In_DEFAULT_YN(j)    :=      P_CTZV_TBL(i).DEFAULT_YN;
		In_TIMEZONE_ID(j)    :=      P_CTZV_TBL(i).TIMEZONE_ID;
		In_DNZ_CHR_ID(j)    :=      P_CTZV_TBL(i).DNZ_CHR_ID;
		In_CREATED_BY(j)    :=      P_CTZV_TBL(i).CREATED_BY;
		In_CREATION_DATE(j)    :=      P_CTZV_TBL(i).CREATION_DATE;
		In_LAST_UPDATED_BY(j)    :=      P_CTZV_TBL(i).LAST_UPDATED_BY;
		In_LAST_UPDATE_DATE(j)    :=      P_CTZV_TBL(i).LAST_UPDATE_DATE;
		In_LAST_UPDATE_LOGIN(j)    :=      P_CTZV_TBL(i).LAST_UPDATE_LOGIN;
		In_SECURITY_GROUP_ID(j)    :=      P_CTZV_TBL(i).SECURITY_GROUP_ID;
		In_PROGRAM_APPLICATION_ID(j):=     P_CTZV_TBL(i).PROGRAM_APPLICATION_ID;
		In_PROGRAM_ID(j)    :=      P_CTZV_TBL(i).PROGRAM_ID;
		In_PROGRAM_UPDATE_DATE(j)    :=      P_CTZV_TBL(i).PROGRAM_UPDATE_DATE;
		In_REQUEST_ID(j)    :=      P_CTZV_TBL(i).REQUEST_ID;
		In_OBJECT_VERSION_NUMBER(j) := P_CTZV_TBL(i).OBJECT_VERSION_NUMBER;

		i  :=P_CTZV_TBL.NEXT(i);

END LOOP;

FORALL i in 1..l_tabsize
INSERT      INTO oks_coverage_timezones (
		ID,
		CLE_ID,
		DEFAULT_YN,
		TIMEZONE_ID,
		DNZ_CHR_ID,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN,
		SECURITY_GROUP_ID,
		PROGRAM_APPLICATION_ID,
		PROGRAM_ID,
		PROGRAM_UPDATE_DATE,
		REQUEST_ID,
		OBJECT_VERSION_NUMBER)
		VALUES (
		in_ID(i),
		in_CLE_ID(i),
		in_DEFAULT_YN(i),
		in_TIMEZONE_ID(i),
		in_DNZ_CHR_ID(i),
		in_CREATED_BY(i),
		in_CREATION_DATE(i),
		in_LAST_UPDATED_BY(i),
		in_LAST_UPDATE_DATE(i),
		in_LAST_UPDATE_LOGIN(i),
		in_SECURITY_GROUP_ID(i),
		in_PROGRAM_APPLICATION_ID(i),
		in_PROGRAM_ID(i),
		in_PROGRAM_UPDATE_DATE(i),
		in_REQUEST_ID(i),
		in_OBJECT_VERSION_NUMBER(i));

		IF (l_debug = 'Y') THEN
			okc_debug.log('23500: Exiting INSERT_ROW_UPG', 2);
			okc_debug.Reset_Indentation;
		END IF;

EXCEPTION
WHEN OTHERS THEN
		IF (l_debug = 'Y') THEN
			okc_debug.log('23600: Exiting INSERT_ROW_UPG:OTHERS Exception', 2);
			okc_debug.Reset_Indentation;
		END IF;

		OKC_API.SET_MESSAGE(
				p_app_name        => G_APP_NAME,
				p_msg_name        => G_UNEXPECTED_ERROR,
				p_token1          => G_SQLCODE_TOKEN,
				p_token1_value    => SQLCODE,
				p_token2          => G_SQLERRM_TOKEN,
				p_token2_value    => SQLERRM);

			x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END INSERT_ROW_UPG_CTZV_TBL;


PROCEDURE INSERT_ROW_UPG_CVTV_TBL
					(x_return_status OUT NOCOPY VARCHAR2,
					 P_CVTV_TBL  OKS_CVT_PVT.oks_coverage_times_v_tbl_type) IS

		l_tabsize NUMBER := P_CVTV_TBL.COUNT;
		l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;
		In_ID           OKC_DATATYPES.NumberTabTyp;
		In_COV_TZE_LINE_ID           OKC_DATATYPES.NumberTabTyp;
		In_DNZ_CHR_ID           OKC_DATATYPES.NumberTabTyp;
		In_START_HOUR           OKC_DATATYPES.NumberTabTyp;
		In_START_MINUTE           OKC_DATATYPES.NumberTabTyp;
		In_END_HOUR           OKC_DATATYPES.NumberTabTyp;
		In_END_MINUTE           OKC_DATATYPES.NumberTabTyp;
		In_MONDAY_YN           OKC_DATATYPES.VAR3TabTyp;
		In_TUESDAY_YN           OKC_DATATYPES.VAR3TabTyp;
		In_WEDNESDAY_YN           OKC_DATATYPES.VAR3TabTyp;
		In_THURSDAY_YN           OKC_DATATYPES.VAR3TabTyp;
		In_FRIDAY_YN           OKC_DATATYPES.VAR3TabTyp;
		In_SATURDAY_YN           OKC_DATATYPES.VAR3TabTyp;
		In_SUNDAY_YN           OKC_DATATYPES.VAR3TabTyp;
		In_CREATED_BY           OKC_DATATYPES.NumberTabTyp;
		In_CREATION_DATE           OKC_DATATYPES.DateTabTyp;
		In_LAST_UPDATED_BY           OKC_DATATYPES.NumberTabTyp;
		In_LAST_UPDATE_DATE           OKC_DATATYPES.DateTabTyp;
		In_LAST_UPDATE_LOGIN           OKC_DATATYPES.NumberTabTyp;
		In_SECURITY_GROUP_ID           OKC_DATATYPES.NumberTabTyp;
		In_PROGRAM_APPLICATION_ID           OKC_DATATYPES.NumberTabTyp;
		In_PROGRAM_ID           OKC_DATATYPES.NumberTabTyp;
		In_PROGRAM_UPDATE_DATE           OKC_DATATYPES.DateTabTyp;
		In_REQUEST_ID           OKC_DATATYPES.NumberTabTyp;
		In_OBJECT_VERSION_NUMBER           OKC_DATATYPES.NumberTabTyp;
		i                                NUMBER := P_CVTV_TBL.FIRST;
		j                                NUMBER := 0;

BEGIN
		x_return_status := OKC_API.G_RET_STS_SUCCESS;
IF (l_debug = 'Y') THEN
		okc_debug.Set_Indentation('OKS_CVT_PVT');
		okc_debug.log('23400: Entered INSERT_ROW_UPG', 2);
END IF;

WHILE i IS NOT NULL LOOP
		j                               := j +1;
		In_ID(j)    :=      P_CVTV_TBL(i).ID;
		In_COV_TZE_LINE_ID(j)    :=      P_CVTV_TBL(i).COV_TZE_LINE_ID;
		In_DNZ_CHR_ID(j)    :=      P_CVTV_TBL(i).DNZ_CHR_ID;
		In_START_HOUR(j)    :=      P_CVTV_TBL(i).START_HOUR;
		In_START_MINUTE(j)    :=      P_CVTV_TBL(i).START_MINUTE;
		In_END_HOUR(j)    :=      P_CVTV_TBL(i).END_HOUR;
		In_END_MINUTE(j)    :=      P_CVTV_TBL(i).END_MINUTE;
		In_MONDAY_YN(j)    :=      P_CVTV_TBL(i).MONDAY_YN;
		In_TUESDAY_YN(j)    :=      P_CVTV_TBL(i).TUESDAY_YN;
		In_WEDNESDAY_YN(j)    :=      P_CVTV_TBL(i).WEDNESDAY_YN;
		In_THURSDAY_YN(j)    :=      P_CVTV_TBL(i).THURSDAY_YN;
		In_FRIDAY_YN(j)    :=      P_CVTV_TBL(i).FRIDAY_YN;
		In_SATURDAY_YN(j)    :=      P_CVTV_TBL(i).SATURDAY_YN;
		In_SUNDAY_YN(j)    :=      P_CVTV_TBL(i).SUNDAY_YN;
		In_CREATED_BY(j)    :=      P_CVTV_TBL(i).CREATED_BY;
		In_CREATION_DATE(j)    :=      P_CVTV_TBL(i).CREATION_DATE;
		In_LAST_UPDATED_BY(j)    :=      P_CVTV_TBL(i).LAST_UPDATED_BY;
		In_LAST_UPDATE_DATE(j)    :=      P_CVTV_TBL(i).LAST_UPDATE_DATE;
		In_LAST_UPDATE_LOGIN(j)    :=      P_CVTV_TBL(i).LAST_UPDATE_LOGIN;
		In_SECURITY_GROUP_ID(j)    :=  P_CVTV_TBL(i).SECURITY_GROUP_ID;
		In_PROGRAM_APPLICATION_ID(j):= P_CVTV_TBL(i).PROGRAM_APPLICATION_ID;
		In_PROGRAM_ID(j)    :=      P_CVTV_TBL(i).PROGRAM_ID;
		In_PROGRAM_UPDATE_DATE(j)    :=      P_CVTV_TBL(i).PROGRAM_UPDATE_DATE;
		In_REQUEST_ID(j)    :=      P_CVTV_TBL(i).REQUEST_ID;
		In_OBJECT_VERSION_NUMBER(j)    :=      P_CVTV_TBL(i).OBJECT_VERSION_NUMBER;
		i  :=P_CVTV_TBL.NEXT(i);
END LOOP;

FORALL i in 1..l_tabsize
INSERT      INTO Oks_Coverage_Times (
		ID,
		COV_TZE_LINE_ID,
		DNZ_CHR_ID,
		START_HOUR,
		START_MINUTE,
		END_HOUR,
		END_MINUTE,
		MONDAY_YN,
		TUESDAY_YN,
		WEDNESDAY_YN,
		THURSDAY_YN,
		FRIDAY_YN,
		SATURDAY_YN,
		SUNDAY_YN,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN,
		SECURITY_GROUP_ID,
		PROGRAM_APPLICATION_ID,
		PROGRAM_ID,
		PROGRAM_UPDATE_DATE,
		REQUEST_ID,
		OBJECT_VERSION_NUMBER)
		VALUES (
		in_ID(i),
		in_COV_TZE_LINE_ID(i),
		in_DNZ_CHR_ID(i),
		in_START_HOUR(i),
		in_START_MINUTE(i),
		in_END_HOUR(i),
		in_END_MINUTE(i),
		in_MONDAY_YN(i),
		in_TUESDAY_YN(i),
		in_WEDNESDAY_YN(i),
		in_THURSDAY_YN(i),
		in_FRIDAY_YN(i),
		in_SATURDAY_YN(i),
		in_SUNDAY_YN(i),
		in_CREATED_BY(i),
		in_CREATION_DATE(i),
		in_LAST_UPDATED_BY(i),
		in_LAST_UPDATE_DATE(i),
		in_LAST_UPDATE_LOGIN(i),
		in_SECURITY_GROUP_ID(i),
		in_PROGRAM_APPLICATION_ID(i),
		in_PROGRAM_ID(i),
		in_PROGRAM_UPDATE_DATE(i),
		in_REQUEST_ID(i),
		in_Object_Version_Number(i));

		IF (l_debug = 'Y') THEN
				okc_debug.log('23500: Exiting INSERT_ROW_UPG', 2);
				okc_debug.Reset_Indentation;
  		END IF;
EXCEPTION
WHEN OTHERS THEN
		IF (l_debug = 'Y') THEN
			okc_debug.log('23600: Exiting INSERT_ROW_UPG:OTHERS Exception', 2);
			okc_debug.Reset_Indentation;
		END IF;

		OKC_API.SET_MESSAGE(
				p_app_name        => G_APP_NAME,
				p_msg_name        => G_UNEXPECTED_ERROR,
				p_token1          => G_SQLCODE_TOKEN,
				p_token1_value    => SQLCODE,
				p_token2          => G_SQLERRM_TOKEN,
				p_token2_value    => SQLERRM);
				x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END INSERT_ROW_UPG_CVTV_TBL;

PROCEDURE INSERT_ROW_UPG_ACMV_TBL
					(x_return_status OUT NOCOPY VARCHAR2,
					 P_ACMV_TBL  OKS_ACM_PVT.oks_action_times_v_tbl_type) IS

		l_tabsize NUMBER := P_ACMV_TBL.COUNT;
		l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;
		l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
		In_ID           OKC_DATATYPES.NumberTabTyp;
		In_COV_ACTION_TYPE_ID           OKC_DATATYPES.NumberTabTyp;
		In_CLE_ID           OKC_DATATYPES.NumberTabTyp;
		In_DNZ_CHR_ID           OKC_DATATYPES.NumberTabTyp;
		In_UOM_CODE           OKC_DATATYPES.VAR30TabTyp;
		In_SUN_DURATION           OKC_DATATYPES.NumberTabTyp;
		In_MON_DURATION           OKC_DATATYPES.NumberTabTyp;
		In_TUE_DURATION           OKC_DATATYPES.NumberTabTyp;
		In_WED_DURATION           OKC_DATATYPES.NumberTabTyp;
		In_THU_DURATION           OKC_DATATYPES.NumberTabTyp;
		In_FRI_DURATION           OKC_DATATYPES.NumberTabTyp;
		In_SAT_DURATION           OKC_DATATYPES.NumberTabTyp;
		In_SECURITY_GROUP_ID           OKC_DATATYPES.NumberTabTyp;
		In_PROGRAM_APPLICATION_ID           OKC_DATATYPES.NumberTabTyp;
		In_PROGRAM_ID           OKC_DATATYPES.NumberTabTyp;
		In_PROGRAM_UPDATE_DATE           OKC_DATATYPES.DateTabTyp;
		In_REQUEST_ID           OKC_DATATYPES.NumberTabTyp;
		In_CREATED_BY           OKC_DATATYPES.NumberTabTyp;
		In_Object_Version_Number           OKC_DATATYPES.NumberTabTyp;
		In_CREATION_DATE           OKC_DATATYPES.DateTabTyp;
		In_LAST_UPDATED_BY           OKC_DATATYPES.NumberTabTyp;
		In_LAST_UPDATE_DATE           OKC_DATATYPES.DateTabTyp;
		In_LAST_UPDATE_LOGIN           OKC_DATATYPES.NumberTabTyp;
		i                                NUMBER := P_ACMV_TBL.FIRST;
		j                                NUMBER := 0;
BEGIN
		x_return_status := OKC_API.G_RET_STS_SUCCESS;

		IF (l_debug = 'Y') THEN
				okc_debug.Set_Indentation('OKS_ACM_PVT');
				okc_debug.log('23400: Entered INSERT_ROW_UPG', 2);
		END IF;

		WHILE i IS NOT NULL LOOP
		j                               := j +1;
		In_ID(j)    :=      P_ACMV_TBL(i).ID;
		In_COV_ACTION_TYPE_ID(j)    :=      P_ACMV_TBL(i).COV_ACTION_TYPE_ID;
		In_CLE_ID(j)    :=      P_ACMV_TBL(i).CLE_ID;
		In_DNZ_CHR_ID(j)    :=      P_ACMV_TBL(i).DNZ_CHR_ID;
		In_UOM_CODE(j)    :=      P_ACMV_TBL(i).UOM_CODE;
		In_SUN_DURATION(j)    :=      P_ACMV_TBL(i).SUN_DURATION;
		In_MON_DURATION(j)    :=      P_ACMV_TBL(i).MON_DURATION;
		In_TUE_DURATION(j)    :=      P_ACMV_TBL(i).TUE_DURATION;
		In_WED_DURATION(j)    :=      P_ACMV_TBL(i).WED_DURATION;
		In_THU_DURATION(j)    :=      P_ACMV_TBL(i).THU_DURATION;
		In_FRI_DURATION(j)    :=      P_ACMV_TBL(i).FRI_DURATION;
		In_SAT_DURATION(j)    :=      P_ACMV_TBL(i).SAT_DURATION;
		In_SECURITY_GROUP_ID(j)    :=      P_ACMV_TBL(i).SECURITY_GROUP_ID;
		In_PROGRAM_APPLICATION_ID(j) := P_ACMV_TBL(i).PROGRAM_APPLICATION_ID;
		In_PROGRAM_ID(j)    :=      P_ACMV_TBL(i).PROGRAM_ID;
		In_PROGRAM_UPDATE_DATE(j)    :=      P_ACMV_TBL(i).PROGRAM_UPDATE_DATE;
		In_REQUEST_ID(j)    :=      P_ACMV_TBL(i).REQUEST_ID;
		In_CREATED_BY(j)    :=      P_ACMV_TBL(i).CREATED_BY;
		In_OBJECT_VERSION_NUMBER(j)    :=      P_ACMV_TBL(i).OBJECT_VERSION_NUMBER;
		In_CREATION_DATE(j)    :=      P_ACMV_TBL(i).CREATION_DATE;
		In_LAST_UPDATED_BY(j)    :=      P_ACMV_TBL(i).LAST_UPDATED_BY;
		In_LAST_UPDATE_DATE(j)    :=      P_ACMV_TBL(i).LAST_UPDATE_DATE;
		In_LAST_UPDATE_LOGIN(j)    :=      P_ACMV_TBL(i).LAST_UPDATE_LOGIN;
		i  :=P_ACMV_TBL.NEXT(i);
		END LOOP;

FORALL i in 1..l_tabsize
INSERT      INTO Oks_Action_Times (
		ID,
		COV_ACTION_TYPE_ID,
		CLE_ID,
		DNZ_CHR_ID,
		UOM_CODE,
		SUN_DURATION,
		MON_DURATION,
		TUE_DURATION,
		WED_DURATION,
		THU_DURATION,
		FRI_DURATION,
		SAT_DURATION,
		SECURITY_GROUP_ID,
		PROGRAM_APPLICATION_ID,
		PROGRAM_ID,
		PROGRAM_UPDATE_DATE,
		REQUEST_ID,
		CREATED_BY,
		OBJECT_VERSION_NUMBER,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN)
		VALUES (
		in_ID(i),
		in_COV_ACTION_TYPE_ID(i),
		in_CLE_ID(i),
		in_DNZ_CHR_ID(i),
		in_UOM_CODE(i),
		in_SUN_DURATION(i),
		in_MON_DURATION(i),
		in_TUE_DURATION(i),
		in_WED_DURATION(i),
		in_THU_DURATION(i),
		in_FRI_DURATION(i),
		in_SAT_DURATION(i),
		in_SECURITY_GROUP_ID(i),
		in_PROGRAM_APPLICATION_ID(i),
		in_PROGRAM_ID(i),
		in_PROGRAM_UPDATE_DATE(i),
		in_REQUEST_ID(i),
		in_CREATED_BY(i),
		in_object_version_number(i),
		in_CREATION_DATE(i),
		in_LAST_UPDATED_BY(i),
		in_LAST_UPDATE_DATE(i),
		in_LAST_UPDATE_LOGIN(i));

		IF (l_debug = 'Y') THEN
				okc_debug.log('23500: Exiting INSERT_ROW_UPG', 2);
				okc_debug.Reset_Indentation;
		END IF;

		EXCEPTION
		WHEN OTHERS THEN
		IF (l_debug = 'Y') THEN
			okc_debug.log('23600: Exiting INSERT_ROW_UPG:OTHERS Exception', 2);
			okc_debug.Reset_Indentation;
		END IF;

		OKC_API.SET_MESSAGE(
				p_app_name        => G_APP_NAME,
				p_msg_name        => G_UNEXPECTED_ERROR,
				p_token1          => G_SQLCODE_TOKEN,
				p_token1_value    => SQLCODE,
				p_token2          => G_SQLERRM_TOKEN,
				p_token2_value    => SQLERRM);
				x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END INSERT_ROW_UPG_ACMV_TBL;


PROCEDURE INSERT_ROW_UPG_ACTV_TBL
					(x_return_status OUT NOCOPY VARCHAR2,
					 P_ACTV_TBL  OKS_ACT_PVT.OksActionTimeTypesVTblType) IS

		l_tabsize NUMBER := P_ACTV_TBL.COUNT;
		l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;
		l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
		In_ID           OKC_DATATYPES.NumberTabTyp;
		In_CLE_ID           OKC_DATATYPES.NumberTabTyp;
		In_DNZ_CHR_ID           OKC_DATATYPES.NumberTabTyp;
		In_ACTION_TYPE_CODE           OKC_DATATYPES.VAR30TabTyp;
		In_SECURITY_GROUP_ID           OKC_DATATYPES.NumberTabTyp;
		In_PROGRAM_APPLICATION_ID           OKC_DATATYPES.NumberTabTyp;
		In_PROGRAM_ID           OKC_DATATYPES.NumberTabTyp;
		In_PROGRAM_UPDATE_DATE           OKC_DATATYPES.DateTabTyp;
		In_REQUEST_ID           OKC_DATATYPES.NumberTabTyp;
		In_CREATED_BY           OKC_DATATYPES.NumberTabTyp;
		In_CREATION_DATE           OKC_DATATYPES.DateTabTyp;
		In_LAST_UPDATED_BY           OKC_DATATYPES.NumberTabTyp;
		In_LAST_UPDATE_DATE           OKC_DATATYPES.DateTabTyp;
		In_LAST_UPDATE_LOGIN           OKC_DATATYPES.NumberTabTyp;
		In_OBJECT_VERSION_NUMBER           OKC_DATATYPES.NumberTabTyp;
		i                                NUMBER := P_ACTV_TBL.FIRST;
		j                                NUMBER := 0;
BEGIN
		x_return_status := OKC_API.G_RET_STS_SUCCESS;

		IF (l_debug = 'Y') THEN
				okc_debug.Set_Indentation('OKS_ACT_PVT');
				okc_debug.log('23400: Entered INSERT_ROW_UPG', 2);
		END IF;

		 WHILE i IS NOT NULL LOOP
		 j                               := j +1;
		In_ID(j)    :=      P_ACTV_TBL(i).ID;
		In_CLE_ID(j)    :=      P_ACTV_TBL(i).CLE_ID;
		In_DNZ_CHR_ID(j)    :=      P_ACTV_TBL(i).DNZ_CHR_ID;
		In_ACTION_TYPE_CODE(j)    :=      P_ACTV_TBL(i).ACTION_TYPE_CODE;
		In_SECURITY_GROUP_ID(j)    :=      P_ACTV_TBL(i).SECURITY_GROUP_ID;
		In_PROGRAM_APPLICATION_ID(j)  :=  P_ACTV_TBL(i).PROGRAM_APPLICATION_ID;
		In_PROGRAM_ID(j)    :=      P_ACTV_TBL(i).PROGRAM_ID;
		In_PROGRAM_UPDATE_DATE(j)    :=      P_ACTV_TBL(i).PROGRAM_UPDATE_DATE;
		In_REQUEST_ID(j)    :=      P_ACTV_TBL(i).REQUEST_ID;
		In_CREATED_BY(j)    :=      P_ACTV_TBL(i).CREATED_BY;
		In_CREATION_DATE(j)    :=      P_ACTV_TBL(i).CREATION_DATE;
		In_LAST_UPDATED_BY(j)    :=      P_ACTV_TBL(i).LAST_UPDATED_BY;
		In_LAST_UPDATE_DATE(j)    :=      P_ACTV_TBL(i).LAST_UPDATE_DATE;
		In_LAST_UPDATE_LOGIN(j)    :=      P_ACTV_TBL(i).LAST_UPDATE_LOGIN;
		In_OBJECT_VERSION_NUMBER(j)    :=      P_ACTV_TBL(i).OBJECT_VERSION_NUMBER;

		i  :=P_ACTV_TBL.NEXT(i);
		END LOOP;
FORALL i in 1..l_tabsize
INSERT      INTO Oks_Action_Time_Types (
		ID,
		CLE_ID,
		DNZ_CHR_ID,
		ACTION_TYPE_CODE,
		SECURITY_GROUP_ID,
		PROGRAM_APPLICATION_ID,
		PROGRAM_ID,
		PROGRAM_UPDATE_DATE,
		REQUEST_ID,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN,
		OBJECT_VERSION_NUMBER)
VALUES (
		in_ID(i),
		in_CLE_ID(i),
		in_DNZ_CHR_ID(i),
		in_ACTION_TYPE_CODE(i),
		in_SECURITY_GROUP_ID(i),
		in_PROGRAM_APPLICATION_ID(i),
		in_PROGRAM_ID(i),
		in_PROGRAM_UPDATE_DATE(i),
		in_REQUEST_ID(i),
		in_CREATED_BY(i),
		in_CREATION_DATE(i),
		in_LAST_UPDATED_BY(i),
		in_LAST_UPDATE_DATE(i),
		in_LAST_UPDATE_LOGIN(i),
		in_OBJECT_VERSION_NUMBER(i));

		  IF (l_debug = 'Y') THEN
				 okc_debug.log('23500: Exiting INSERT_ROW_UPG', 2);
				 okc_debug.Reset_Indentation;
		  END IF;

		EXCEPTION
		WHEN OTHERS THEN
		  IF (l_debug = 'Y') THEN
			okc_debug.log('23600: Exiting INSERT_ROW_UPG:OTHERS Exception', 2);
			okc_debug.Reset_Indentation;
		  END IF;

		  OKC_API.SET_MESSAGE(
				p_app_name        => G_APP_NAME,
				p_msg_name        => G_UNEXPECTED_ERROR,
				p_token1          => G_SQLCODE_TOKEN,
				p_token1_value    => SQLCODE,
				p_token2          => G_SQLERRM_TOKEN,
				p_token2_value    => SQLERRM);

		  		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END INSERT_ROW_UPG_ACTV_TBL;


PROCEDURE INSERT_ROW_UPG_KLNV_TBL
						(x_return_status OUT NOCOPY VARCHAR2,
						 P_KLNV_TBL  OKS_KLN_PVT.klnv_tbl_type) IS

		l_tabsize NUMBER := P_KLNV_TBL.COUNT;
		l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;
		l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
		--In_ROW_ID           OKC_DATATYPES.;
		In_ID           OKC_DATATYPES.NumberTabTyp;
		In_CLE_ID           OKC_DATATYPES.NumberTabTyp;
		In_DNZ_CHR_ID           OKC_DATATYPES.NumberTabTyp;
		In_DISCOUNT_LIST           OKC_DATATYPES.NumberTabTyp;
		In_ACCT_RULE_ID           OKC_DATATYPES.NumberTabTyp;
		In_PAYMENT_TYPE           OKC_DATATYPES.VAR30TabTyp;
		In_CC_NO           OKC_DATATYPES.VAR150TabTyp;
		In_CC_EXPIRY_DATE           OKC_DATATYPES.DateTabTyp;
		In_CC_BANK_ACCT_ID           OKC_DATATYPES.NumberTabTyp;
		In_CC_AUTH_CODE           OKC_DATATYPES.VAR150TabTyp;
		In_COMMITMENT_ID           OKC_DATATYPES.NumberTabTyp;
		In_LOCKED_PRICE_LIST_ID           OKC_DATATYPES.NumberTabTyp;
		In_USAGE_EST_YN           OKC_DATATYPES.VAR3TabTyp;
		In_USAGE_EST_METHOD           OKC_DATATYPES.VAR30TabTyp;
		In_USAGE_EST_START_DATE           OKC_DATATYPES.DateTabTyp;
		In_TERMN_METHOD           OKC_DATATYPES.VAR30TabTyp;
		In_UBT_AMOUNT           OKC_DATATYPES.NumberTabTyp;
		In_CREDIT_AMOUNT           OKC_DATATYPES.NumberTabTyp;
		In_SUPPRESSED_CREDIT           OKC_DATATYPES.NumberTabTyp;
		In_OVERRIDE_AMOUNT           OKC_DATATYPES.NumberTabTyp;
		In_CUST_PO_NUMBER_REQ_YN           OKC_DATATYPES.VAR3TabTyp;
		In_CUST_PO_NUMBER           OKC_DATATYPES.VAR150TabTyp;
		In_GRACE_DURATION           OKC_DATATYPES.NumberTabTyp;
		In_GRACE_PERIOD           OKC_DATATYPES.VAR30TabTyp;
		In_INV_PRINT_FLAG           OKC_DATATYPES.VAR3TabTyp;
		In_PRICE_UOM           OKC_DATATYPES.VAR30TabTyp;
		In_TAX_AMOUNT           OKC_DATATYPES.NumberTabTyp;
		In_TAX_INCLUSIVE_YN           OKC_DATATYPES.VAR3TabTyp;
		In_TAX_STATUS           OKC_DATATYPES.VAR30TabTyp;
		In_TAX_CODE           OKC_DATATYPES.NumberTabTyp;
		In_TAX_EXEMPTION_ID           OKC_DATATYPES.NumberTabTyp;
		In_IB_TRANS_TYPE           OKC_DATATYPES.VAR10TabTyp;
		In_IB_TRANS_DATE           OKC_DATATYPES.DateTabTyp;
		In_PROD_PRICE           OKC_DATATYPES.NumberTabTyp;
		In_SERVICE_PRICE           OKC_DATATYPES.NumberTabTyp;
		In_CLVL_LIST_PRICE           OKC_DATATYPES.NumberTabTyp;
		In_CLVL_QUANTITY           OKC_DATATYPES.NumberTabTyp;
		In_CLVL_EXTENDED_AMT           OKC_DATATYPES.NumberTabTyp;
		In_CLVL_UOM_CODE           OKC_DATATYPES.VAR3TabTyp;
		In_TOPLVL_OPERAND_CODE           OKC_DATATYPES.VAR30TabTyp;
		In_TOPLVL_OPERAND_VAL           OKC_DATATYPES.NumberTabTyp;
		In_TOPLVL_QUANTITY           OKC_DATATYPES.NumberTabTyp;
		In_TOPLVL_UOM_CODE           OKC_DATATYPES.VAR3TabTyp;
		In_TOPLVL_ADJ_PRICE           OKC_DATATYPES.NumberTabTyp;
		In_TOPLVL_PRICE_QTY           OKC_DATATYPES.NumberTabTyp;
		In_AVERAGING_INTERVAL           OKC_DATATYPES.NumberTabTyp;
		In_SETTLEMENT_INTERVAL           OKC_DATATYPES.VAR30TabTyp;
		In_MINIMUM_QUANTITY           OKC_DATATYPES.NumberTabTyp;
		In_DEFAULT_QUANTITY           OKC_DATATYPES.NumberTabTyp;
		In_AMCV_FLAG           OKC_DATATYPES.VAR3TabTyp;
		In_FIXED_QUANTITY           OKC_DATATYPES.NumberTabTyp;
		In_USAGE_DURATION           OKC_DATATYPES.NumberTabTyp;
		In_USAGE_PERIOD           OKC_DATATYPES.VAR3TabTyp;
		In_LEVEL_YN           OKC_DATATYPES.VAR3TabTyp;
		In_USAGE_TYPE           OKC_DATATYPES.VAR10TabTyp;
		In_UOM_QUANTIFIED           OKC_DATATYPES.VAR3TabTyp;
		In_BASE_READING           OKC_DATATYPES.NumberTabTyp;
		In_BILLING_SCHEDULE_TYPE           OKC_DATATYPES.VAR10TabTyp;
		In_FULL_CREDIT           OKC_DATATYPES.VAR3TabTyp;
		In_COVERAGE_TYPE           OKC_DATATYPES.VAR30TabTyp;
		In_EXCEPTION_COV_ID           OKC_DATATYPES.NumberTabTyp;
		In_LIMIT_UOM_QUANTIFIED           OKC_DATATYPES.VAR3TabTyp;
		In_DISCOUNT_AMOUNT           OKC_DATATYPES.NumberTabTyp;
		In_DISCOUNT_PERCENT           OKC_DATATYPES.NumberTabTyp;
		In_OFFSET_DURATION           OKC_DATATYPES.NumberTabTyp;
		In_OFFSET_PERIOD           OKC_DATATYPES.VAR3TabTyp;
		In_INCIDENT_SEVERITY_ID           OKC_DATATYPES.NumberTabTyp;
		In_PDF_ID           OKC_DATATYPES.NumberTabTyp;
		In_WORK_THRU_YN           OKC_DATATYPES.VAR3TabTyp;
		In_REACT_ACTIVE_YN           OKC_DATATYPES.VAR3TabTyp;
		In_TRANSFER_OPTION           OKC_DATATYPES.VAR30TabTyp;
		In_PROD_UPGRADE_YN           OKC_DATATYPES.VAR3TabTyp;
		In_INHERITANCE_TYPE           OKC_DATATYPES.VAR30TabTyp;
		In_PM_PROGRAM_ID           OKC_DATATYPES.NumberTabTyp;
		In_PM_CONF_REQ_YN           OKC_DATATYPES.VAR3TabTyp;
		In_PM_SCH_EXISTS_YN           OKC_DATATYPES.VAR3TabTyp;
		In_ALLOW_BT_DISCOUNT           OKC_DATATYPES.VAR3TabTyp;
		In_APPLY_DEFAULT_TIMEZONE           OKC_DATATYPES.VAR3TabTyp;
		In_SYNC_DATE_INSTALL           OKC_DATATYPES.VAR3TabTyp;
		In_SFWT_FLAG           OKC_DATATYPES.VAR3TabTyp;
		In_INVOICE_TEXT           OKC_DATATYPES.VAR1995TabTyp;
		In_IB_TRX_DETAILS           OKC_DATATYPES.VAR1995TabTyp;
		In_STATUS_TEXT           OKC_DATATYPES.VAR450TabTyp;
		In_REACT_TIME_NAME           OKC_DATATYPES.VAR450TabTyp;
		In_OBJECT_VERSION_NUMBER           OKC_DATATYPES.NumberTabTyp;
		In_SECURITY_GROUP_ID           OKC_DATATYPES.NumberTabTyp;
		In_REQUEST_ID           OKC_DATATYPES.NumberTabTyp;
		In_CREATED_BY           OKC_DATATYPES.NumberTabTyp;
		In_CREATION_DATE           OKC_DATATYPES.DateTabTyp;
		In_LAST_UPDATED_BY           OKC_DATATYPES.NumberTabTyp;
		In_LAST_UPDATE_DATE           OKC_DATATYPES.DateTabTyp;
		In_LAST_UPDATE_LOGIN           OKC_DATATYPES.NumberTabTyp;
		i                                NUMBER := P_KLNV_TBL.FIRST;
		j                                NUMBER := 0;
BEGIN
		x_return_status := OKC_API.G_RET_STS_SUCCESS;

		IF (l_debug = 'Y') THEN
				okc_debug.Set_Indentation('OKS_KLN_PVT');
				okc_debug.log('23400: Entered INSERT_ROW_UPG', 2);
 		END IF;

   WHILE i IS NOT NULL LOOP
       j                               := j +1;
      In_ID(j)    :=      P_KLNV_TBL(i).ID;
      In_CLE_ID(j)    :=      P_KLNV_TBL(i).CLE_ID;
      In_DNZ_CHR_ID(j)    :=      P_KLNV_TBL(i).DNZ_CHR_ID;
      In_DISCOUNT_LIST(j)    :=      P_KLNV_TBL(i).DISCOUNT_LIST;
      In_ACCT_RULE_ID(j)    :=      P_KLNV_TBL(i).ACCT_RULE_ID;
      In_PAYMENT_TYPE(j)    :=      P_KLNV_TBL(i).PAYMENT_TYPE;
      In_CC_NO(j)    :=      P_KLNV_TBL(i).CC_NO;
      In_CC_EXPIRY_DATE(j)    :=      P_KLNV_TBL(i).CC_EXPIRY_DATE;
      In_CC_BANK_ACCT_ID(j)    :=      P_KLNV_TBL(i).CC_BANK_ACCT_ID;
      In_CC_AUTH_CODE(j)    :=      P_KLNV_TBL(i).CC_AUTH_CODE;
      In_COMMITMENT_ID(j)    :=      P_KLNV_TBL(i).COMMITMENT_ID;
      In_LOCKED_PRICE_LIST_ID(j)    :=      P_KLNV_TBL(i).LOCKED_PRICE_LIST_ID;
      In_USAGE_EST_YN(j)    :=      P_KLNV_TBL(i).USAGE_EST_YN;
      In_USAGE_EST_METHOD(j)    :=      P_KLNV_TBL(i).USAGE_EST_METHOD;
      In_USAGE_EST_START_DATE(j)    :=      P_KLNV_TBL(i).USAGE_EST_START_DATE;
      In_TERMN_METHOD(j)    :=      P_KLNV_TBL(i).TERMN_METHOD;
      In_UBT_AMOUNT(j)    :=      P_KLNV_TBL(i).UBT_AMOUNT;
      In_CREDIT_AMOUNT(j)    :=      P_KLNV_TBL(i).CREDIT_AMOUNT;
      In_SUPPRESSED_CREDIT(j)    :=      P_KLNV_TBL(i).SUPPRESSED_CREDIT;
      In_OVERRIDE_AMOUNT(j)    :=      P_KLNV_TBL(i).OVERRIDE_AMOUNT;
      In_CUST_PO_NUMBER_REQ_YN(j)  :=      P_KLNV_TBL(i).CUST_PO_NUMBER_REQ_YN;
      In_CUST_PO_NUMBER(j)    :=      P_KLNV_TBL(i).CUST_PO_NUMBER;
      In_GRACE_DURATION(j)    :=      P_KLNV_TBL(i).GRACE_DURATION;
      In_GRACE_PERIOD(j)    :=      P_KLNV_TBL(i).GRACE_PERIOD;
      In_INV_PRINT_FLAG(j)    :=      P_KLNV_TBL(i).INV_PRINT_FLAG;
      In_PRICE_UOM(j)    :=      P_KLNV_TBL(i).PRICE_UOM;
      In_TAX_AMOUNT(j)    :=      P_KLNV_TBL(i).TAX_AMOUNT;
      In_TAX_INCLUSIVE_YN(j)    :=      P_KLNV_TBL(i).TAX_INCLUSIVE_YN;
      In_TAX_STATUS(j)    :=      P_KLNV_TBL(i).TAX_STATUS;
      In_TAX_CODE(j)    :=      P_KLNV_TBL(i).TAX_CODE;
      In_TAX_EXEMPTION_ID(j)    :=      P_KLNV_TBL(i).TAX_EXEMPTION_ID;
      In_IB_TRANS_TYPE(j)    :=      P_KLNV_TBL(i).IB_TRANS_TYPE;
      In_IB_TRANS_DATE(j)    :=      P_KLNV_TBL(i).IB_TRANS_DATE;
      In_PROD_PRICE(j)    :=      P_KLNV_TBL(i).PROD_PRICE;
      In_SERVICE_PRICE(j)    :=      P_KLNV_TBL(i).SERVICE_PRICE;
      In_CLVL_LIST_PRICE(j)    :=      P_KLNV_TBL(i).CLVL_LIST_PRICE;
      In_CLVL_QUANTITY(j)    :=      P_KLNV_TBL(i).CLVL_QUANTITY;
      In_CLVL_EXTENDED_AMT(j)    :=      P_KLNV_TBL(i).CLVL_EXTENDED_AMT;
      In_CLVL_UOM_CODE(j)    :=      P_KLNV_TBL(i).CLVL_UOM_CODE;
      In_TOPLVL_OPERAND_CODE(j)    :=      P_KLNV_TBL(i).TOPLVL_OPERAND_CODE;
      In_TOPLVL_OPERAND_VAL(j)    :=      P_KLNV_TBL(i).TOPLVL_OPERAND_VAL;
      In_TOPLVL_QUANTITY(j)    :=      P_KLNV_TBL(i).TOPLVL_QUANTITY;
      In_TOPLVL_UOM_CODE(j)    :=      P_KLNV_TBL(i).TOPLVL_UOM_CODE;
      In_TOPLVL_ADJ_PRICE(j)    :=      P_KLNV_TBL(i).TOPLVL_ADJ_PRICE;
      In_TOPLVL_PRICE_QTY(j)    :=      P_KLNV_TBL(i).TOPLVL_PRICE_QTY;
      In_AVERAGING_INTERVAL(j)    :=      P_KLNV_TBL(i).AVERAGING_INTERVAL;
      In_SETTLEMENT_INTERVAL(j)    :=      P_KLNV_TBL(i).SETTLEMENT_INTERVAL;
      In_MINIMUM_QUANTITY(j)    :=      P_KLNV_TBL(i).MINIMUM_QUANTITY;
      In_DEFAULT_QUANTITY(j)    :=      P_KLNV_TBL(i).DEFAULT_QUANTITY;
      In_AMCV_FLAG(j)    :=      P_KLNV_TBL(i).AMCV_FLAG;
      In_FIXED_QUANTITY(j)    :=      P_KLNV_TBL(i).FIXED_QUANTITY;
      In_USAGE_DURATION(j)    :=      P_KLNV_TBL(i).USAGE_DURATION;
      In_USAGE_PERIOD(j)    :=      P_KLNV_TBL(i).USAGE_PERIOD;
      In_LEVEL_YN(j)    :=      P_KLNV_TBL(i).LEVEL_YN;
      In_USAGE_TYPE(j)    :=      P_KLNV_TBL(i).USAGE_TYPE;
      In_UOM_QUANTIFIED(j)    :=      P_KLNV_TBL(i).UOM_QUANTIFIED;
      In_BASE_READING(j)    :=      P_KLNV_TBL(i).BASE_READING;
      In_BILLING_SCHEDULE_TYPE(j)  :=      P_KLNV_TBL(i).BILLING_SCHEDULE_TYPE;
      In_FULL_CREDIT(j)    :=      P_KLNV_TBL(i).FULL_CREDIT;
      In_COVERAGE_TYPE(j)    :=      P_KLNV_TBL(i).COVERAGE_TYPE;
      In_EXCEPTION_COV_ID(j)    :=      P_KLNV_TBL(i).EXCEPTION_COV_ID;
      In_LIMIT_UOM_QUANTIFIED(j)    :=      P_KLNV_TBL(i).LIMIT_UOM_QUANTIFIED;
      In_DISCOUNT_AMOUNT(j)    :=      P_KLNV_TBL(i).DISCOUNT_AMOUNT;
      In_DISCOUNT_PERCENT(j)    :=      P_KLNV_TBL(i).DISCOUNT_PERCENT;
      In_OFFSET_DURATION(j)    :=      P_KLNV_TBL(i).OFFSET_DURATION;
      In_OFFSET_PERIOD(j)    :=      P_KLNV_TBL(i).OFFSET_PERIOD;
      In_INCIDENT_SEVERITY_ID(j)    :=      P_KLNV_TBL(i).INCIDENT_SEVERITY_ID;
      In_PDF_ID(j)    :=      P_KLNV_TBL(i).PDF_ID;
      In_WORK_THRU_YN(j)    :=      P_KLNV_TBL(i).WORK_THRU_YN;
      In_REACT_ACTIVE_YN(j)    :=      P_KLNV_TBL(i).REACT_ACTIVE_YN;
      In_TRANSFER_OPTION(j)    :=      P_KLNV_TBL(i).TRANSFER_OPTION;
      In_PROD_UPGRADE_YN(j)    :=      P_KLNV_TBL(i).PROD_UPGRADE_YN;
      In_INHERITANCE_TYPE(j)    :=      P_KLNV_TBL(i).INHERITANCE_TYPE;
      In_PM_PROGRAM_ID(j)    :=      P_KLNV_TBL(i).PM_PROGRAM_ID;
      In_PM_CONF_REQ_YN(j)    :=      P_KLNV_TBL(i).PM_CONF_REQ_YN;
      In_PM_SCH_EXISTS_YN(j)    :=      P_KLNV_TBL(i).PM_SCH_EXISTS_YN;
      In_ALLOW_BT_DISCOUNT(j)    :=      P_KLNV_TBL(i).ALLOW_BT_DISCOUNT;
      In_APPLY_DEFAULT_TIMEZONE(j) :=      P_KLNV_TBL(i).APPLY_DEFAULT_TIMEZONE;
      In_SYNC_DATE_INSTALL(j)    :=      P_KLNV_TBL(i).SYNC_DATE_INSTALL;
      In_SFWT_FLAG(j)    :=      P_KLNV_TBL(i).SFWT_FLAG;
      In_INVOICE_TEXT(j)    :=      P_KLNV_TBL(i).INVOICE_TEXT;
      In_IB_TRX_DETAILS(j)    :=      P_KLNV_TBL(i).IB_TRX_DETAILS;
      In_STATUS_TEXT(j)    :=      P_KLNV_TBL(i).STATUS_TEXT;
      In_REACT_TIME_NAME(j)    :=      P_KLNV_TBL(i).REACT_TIME_NAME;
      In_OBJECT_VERSION_NUMBER(j)  :=      P_KLNV_TBL(i).OBJECT_VERSION_NUMBER;
      In_SECURITY_GROUP_ID(j)    :=      P_KLNV_TBL(i).SECURITY_GROUP_ID;
      In_REQUEST_ID(j)    :=      P_KLNV_TBL(i).REQUEST_ID;
      In_CREATED_BY(j)    :=      P_KLNV_TBL(i).CREATED_BY;
      In_CREATION_DATE(j)    :=      P_KLNV_TBL(i).CREATION_DATE;
      In_LAST_UPDATED_BY(j)    :=      P_KLNV_TBL(i).LAST_UPDATED_BY;
      In_LAST_UPDATE_DATE(j)    :=      P_KLNV_TBL(i).LAST_UPDATE_DATE;
      In_LAST_UPDATE_LOGIN(j)    :=      P_KLNV_TBL(i).LAST_UPDATE_LOGIN;
      i  :=P_KLNV_TBL.NEXT(i);

 END LOOP;

FORALL i in 1..l_tabsize

 INSERT    INTO Oks_K_Lines_B(
				ID,
				CLE_ID,
				DNZ_CHR_ID,
				DISCOUNT_LIST,
				ACCT_RULE_ID,
				PAYMENT_TYPE,
				CC_NO,
				CC_EXPIRY_DATE,
				CC_BANK_ACCT_ID,
				CC_AUTH_CODE,
				COMMITMENT_ID,
				LOCKED_PRICE_LIST_ID,
				USAGE_EST_YN,
				USAGE_EST_METHOD,
				USAGE_EST_START_DATE,
				TERMN_METHOD,
				UBT_AMOUNT,
				CREDIT_AMOUNT,
				SUPPRESSED_CREDIT,
				OVERRIDE_AMOUNT,
				CUST_PO_NUMBER_REQ_YN,
				CUST_PO_NUMBER,
				GRACE_DURATION,
				GRACE_PERIOD,
				INV_PRINT_FLAG,
				PRICE_UOM,
				TAX_AMOUNT,
				TAX_INCLUSIVE_YN,
				TAX_STATUS,
				TAX_CODE,
				TAX_EXEMPTION_ID,
				IB_TRANS_TYPE,
				IB_TRANS_DATE,
				PROD_PRICE,
				SERVICE_PRICE,
				CLVL_LIST_PRICE,
				CLVL_QUANTITY,
				CLVL_EXTENDED_AMT,
				CLVL_UOM_CODE,
				TOPLVL_OPERAND_CODE,
				TOPLVL_OPERAND_VAL,
				TOPLVL_QUANTITY,
				TOPLVL_UOM_CODE,
				TOPLVL_ADJ_PRICE,
				TOPLVL_PRICE_QTY,
				AVERAGING_INTERVAL,
				SETTLEMENT_INTERVAL,
				MINIMUM_QUANTITY,
				DEFAULT_QUANTITY,
				AMCV_FLAG,
				FIXED_QUANTITY,
				USAGE_DURATION,
				USAGE_PERIOD,
				LEVEL_YN,
				USAGE_TYPE,
				UOM_QUANTIFIED,
				BASE_READING,
				BILLING_SCHEDULE_TYPE,
				FULL_CREDIT,
				COVERAGE_TYPE,
				EXCEPTION_COV_ID,
				LIMIT_UOM_QUANTIFIED,
				DISCOUNT_AMOUNT,
				DISCOUNT_PERCENT,
				OFFSET_DURATION,
				OFFSET_PERIOD,
				INCIDENT_SEVERITY_ID,
				PDF_ID,
				WORK_THRU_YN,
				REACT_ACTIVE_YN,
				TRANSFER_OPTION,
				PROD_UPGRADE_YN,
				INHERITANCE_TYPE,
				PM_PROGRAM_ID,
				PM_CONF_REQ_YN,
				PM_SCH_EXISTS_YN,
				ALLOW_BT_DISCOUNT,
				APPLY_DEFAULT_TIMEZONE,
				SYNC_DATE_INSTALL,
				OBJECT_VERSION_NUMBER,
				SECURITY_GROUP_ID,
				REQUEST_ID,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATE_LOGIN)
				VALUES (
				in_ID(i),
				in_CLE_ID(i),
				in_DNZ_CHR_ID(i),
				in_DISCOUNT_LIST(i),
				in_ACCT_RULE_ID(i),
				in_PAYMENT_TYPE(i),
				in_CC_NO(i),
				in_CC_EXPIRY_DATE(i),
				in_CC_BANK_ACCT_ID(i),
				in_CC_AUTH_CODE(i),
				in_COMMITMENT_ID(i),
				in_LOCKED_PRICE_LIST_ID(i),
				in_USAGE_EST_YN(i),
				in_USAGE_EST_METHOD(i),
				in_USAGE_EST_START_DATE(i),
				in_TERMN_METHOD(i),
				in_UBT_AMOUNT(i),
				in_CREDIT_AMOUNT(i),
				in_SUPPRESSED_CREDIT(i),
				in_OVERRIDE_AMOUNT(i),
				in_CUST_PO_NUMBER_REQ_YN(i),
				in_CUST_PO_NUMBER(i),
				in_GRACE_DURATION(i),
				in_GRACE_PERIOD(i),
				in_INV_PRINT_FLAG(i),
				in_PRICE_UOM(i),
				in_TAX_AMOUNT(i),
				in_TAX_INCLUSIVE_YN(i),
				in_TAX_STATUS(i),
				in_TAX_CODE(i),
				in_TAX_EXEMPTION_ID(i),
				in_IB_TRANS_TYPE(i),
				in_IB_TRANS_DATE(i),
				in_PROD_PRICE(i),
				in_SERVICE_PRICE(i),
				in_CLVL_LIST_PRICE(i),
				in_CLVL_QUANTITY(i),
				in_CLVL_EXTENDED_AMT(i),
				in_CLVL_UOM_CODE(i),
				in_TOPLVL_OPERAND_CODE(i),
				in_TOPLVL_OPERAND_VAL(i),
				in_TOPLVL_QUANTITY(i),
				in_TOPLVL_UOM_CODE(i),
				in_TOPLVL_ADJ_PRICE(i),
				in_TOPLVL_PRICE_QTY(i),
				in_AVERAGING_INTERVAL(i),
				in_SETTLEMENT_INTERVAL(i),
				in_MINIMUM_QUANTITY(i),
				in_DEFAULT_QUANTITY(i),
				in_AMCV_FLAG(i),
				in_FIXED_QUANTITY(i),
				in_USAGE_DURATION(i),
				in_USAGE_PERIOD(i),
				in_LEVEL_YN(i),
				in_USAGE_TYPE(i),
				in_UOM_QUANTIFIED(i),
				in_BASE_READING(i),
				in_BILLING_SCHEDULE_TYPE(i),
				in_FULL_CREDIT(i),
				in_COVERAGE_TYPE(i),
				in_EXCEPTION_COV_ID(i),
				in_LIMIT_UOM_QUANTIFIED(i),
				in_DISCOUNT_AMOUNT(i),
				in_DISCOUNT_PERCENT(i),
				in_OFFSET_DURATION(i),
				in_OFFSET_PERIOD(i),
				in_INCIDENT_SEVERITY_ID(i),
				in_PDF_ID(i),
				in_WORK_THRU_YN(i),
				in_REACT_ACTIVE_YN(i),
				in_TRANSFER_OPTION(i),
				in_PROD_UPGRADE_YN(i),
				in_INHERITANCE_TYPE(i),
				in_PM_PROGRAM_ID(i),
				in_PM_CONF_REQ_YN(i),
				in_PM_SCH_EXISTS_YN(i),
				in_ALLOW_BT_DISCOUNT(i),
				in_APPLY_DEFAULT_TIMEZONE(i),
				in_SYNC_DATE_INSTALL(i),
				in_OBJECT_VERSION_NUMBER(i),
				in_SECURITY_GROUP_ID(i),
				in_REQUEST_ID(i),
				in_CREATED_BY(i),
				in_CREATION_DATE(i),
				in_LAST_UPDATED_BY(i),
				in_LAST_UPDATE_DATE(i),
				in_LAST_UPDATE_LOGIN(i));

  FOR lang_i IN OKC_UTIL.g_language_code.FIRST..OKC_UTIL.g_language_code.LAST LOOP

FORALL i in 1..l_tabsize
 INSERT      INTO Oks_K_Lines_TL(
				id,
				language,
				source_lang,
				sfwt_flag,
				invoice_text,
				ib_trx_details,
				status_text,
				react_time_name,
				created_by,
				creation_date,
				last_updated_by,
				last_update_date,
				last_update_login)
		VALUES
			(	in_ID(i),
				OKC_UTIL.g_language_code(lang_i),
				l_source_lang,
				in_SFWT_FLAG(i),
				in_INVOICE_TEXT(i),
				in_IB_TRX_DETAILS(i),
				in_STATUS_TEXT(i),
				in_REACT_TIME_NAME(i),
				in_CREATED_BY(i),
				in_CREATION_DATE(i),
				in_LAST_UPDATED_BY(i),
				in_LAST_UPDATE_DATE(i),
				in_LAST_UPDATE_LOGIN(i));
      END LOOP;

    IF (l_debug = 'Y') THEN
       okc_debug.log('23500: Exiting INSERT_ROW_UPG', 2);
       okc_debug.Reset_Indentation;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 'Y') THEN
       okc_debug.log('23600: Exiting INSERT_ROW_UPG:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END INSERT_ROW_UPG_KLNV_TBL;

PROCEDURE INSERT_ROW_UPG_bill_sch
            (x_return_status OUT NOCOPY VARCHAR2,
            p_oks_billrate_schedules_v_tbl  OKS_BRS_PVT.OksBillrateSchedulesVTblType) IS

l_tabsize NUMBER := p_oks_billrate_schedules_v_tbl.COUNT;
l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;
l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
In_ID           OKC_DATATYPES.NumberTabTyp;
In_CLE_ID           OKC_DATATYPES.NumberTabTyp;
In_BT_CLE_ID           OKC_DATATYPES.NumberTabTyp;
In_DNZ_CHR_ID           OKC_DATATYPES.NumberTabTyp;
In_START_HOUR           OKC_DATATYPES.NumberTabTyp;
In_START_MINUTE           OKC_DATATYPES.NumberTabTyp;
In_END_HOUR           OKC_DATATYPES.NumberTabTyp;
In_END_MINUTE           OKC_DATATYPES.NumberTabTyp;
In_MONDAY_FLAG           OKC_DATATYPES.VAR3TabTyp;
In_TUESDAY_FLAG           OKC_DATATYPES.VAR3TabTyp;
In_WEDNESDAY_FLAG           OKC_DATATYPES.VAR3TabTyp;
In_THURSDAY_FLAG           OKC_DATATYPES.VAR3TabTyp;
In_FRIDAY_FLAG           OKC_DATATYPES.VAR3TabTyp;
In_SATURDAY_FLAG           OKC_DATATYPES.VAR3TabTyp;
In_SUNDAY_FLAG           OKC_DATATYPES.VAR3TabTyp;
In_OBJECT1_ID1           OKC_DATATYPES.VAR40TabTyp;
In_OBJECT1_ID2           OKC_DATATYPES.VAR40TabTyp;
In_JTOT_OBJECT1_CODE           OKC_DATATYPES.VAR30TabTyp;
In_BILL_RATE_CODE           OKC_DATATYPES.VAR40TabTyp;
In_FLAT_RATE           OKC_DATATYPES.NumberTabTyp;
In_UOM           OKC_DATATYPES.VAR3TabTyp;
In_HOLIDAY_YN           OKC_DATATYPES.VAR3TabTyp;
In_PERCENT_OVER_LIST_PRICE           OKC_DATATYPES.NumberTabTyp;
In_PROGRAM_APPLICATION_ID           OKC_DATATYPES.NumberTabTyp;
In_PROGRAM_ID           OKC_DATATYPES.NumberTabTyp;
In_PROGRAM_UPDATE_DATE           OKC_DATATYPES.DateTabTyp;
In_REQUEST_ID           OKC_DATATYPES.NumberTabTyp;
In_CREATED_BY           OKC_DATATYPES.NumberTabTyp;
In_CREATION_DATE           OKC_DATATYPES.DateTabTyp;
In_LAST_UPDATED_BY           OKC_DATATYPES.NumberTabTyp;
In_LAST_UPDATE_DATE           OKC_DATATYPES.DateTabTyp;
In_LAST_UPDATE_LOGIN           OKC_DATATYPES.NumberTabTyp;
In_SECURITY_GROUP_ID           OKC_DATATYPES.NumberTabTyp;
In_OBJECT_VERSION_NUMBER           OKC_DATATYPES.NumberTabTyp;
  i                                NUMBER := p_oks_billrate_schedules_v_tbl.FIRST;
  j                                NUMBER := 0;
BEGIN
x_return_status := OKC_API.G_RET_STS_SUCCESS;
IF (l_debug = 'Y') THEN
okc_debug.Set_Indentation('OKS_BRS_PVT');
okc_debug.log('23400: Entered INSERT_ROW_UPG', 2);
 END IF;
   WHILE i IS NOT NULL
     LOOP
       j                               := j +1;
      In_ID(j)    :=      p_oks_billrate_schedules_v_tbl(i).ID;
      In_CLE_ID(j)    :=      p_oks_billrate_schedules_v_tbl(i).CLE_ID;
      In_BT_CLE_ID(j)    :=      p_oks_billrate_schedules_v_tbl(i).BT_CLE_ID;
      In_DNZ_CHR_ID(j)    :=      p_oks_billrate_schedules_v_tbl(i).DNZ_CHR_ID;
      In_START_HOUR(j)    :=      p_oks_billrate_schedules_v_tbl(i).START_HOUR;
      In_START_MINUTE(j)    :=      p_oks_billrate_schedules_v_tbl(i).START_MINUTE;
      In_END_HOUR(j)    :=      p_oks_billrate_schedules_v_tbl(i).END_HOUR;
      In_END_MINUTE(j)    :=      p_oks_billrate_schedules_v_tbl(i).END_MINUTE;
      In_MONDAY_FLAG(j)    :=      p_oks_billrate_schedules_v_tbl(i).MONDAY_FLAG;
      In_TUESDAY_FLAG(j)    :=      p_oks_billrate_schedules_v_tbl(i).TUESDAY_FLAG;
      In_WEDNESDAY_FLAG(j)    :=      p_oks_billrate_schedules_v_tbl(i).WEDNESDAY_FLAG;
      In_THURSDAY_FLAG(j)    :=      p_oks_billrate_schedules_v_tbl(i).THURSDAY_FLAG;
      In_FRIDAY_FLAG(j)    :=      p_oks_billrate_schedules_v_tbl(i).FRIDAY_FLAG;
      In_SATURDAY_FLAG(j)    :=      p_oks_billrate_schedules_v_tbl(i).SATURDAY_FLAG;
      In_SUNDAY_FLAG(j)    :=      p_oks_billrate_schedules_v_tbl(i).SUNDAY_FLAG;
      In_OBJECT1_ID1(j)    :=      p_oks_billrate_schedules_v_tbl(i).OBJECT1_ID1;
      In_OBJECT1_ID2(j)    :=      p_oks_billrate_schedules_v_tbl(i).OBJECT1_ID2;
      In_JTOT_OBJECT1_CODE(j)    :=      p_oks_billrate_schedules_v_tbl(i).JTOT_OBJECT1_CODE;
      In_BILL_RATE_CODE(j)    :=      p_oks_billrate_schedules_v_tbl(i).BILL_RATE_CODE;
      In_FLAT_RATE(j)    :=      p_oks_billrate_schedules_v_tbl(i).FLAT_RATE;
      In_UOM(j)    :=      p_oks_billrate_schedules_v_tbl(i).UOM;
      In_HOLIDAY_YN(j)    :=      p_oks_billrate_schedules_v_tbl(i).HOLIDAY_YN;
      In_PERCENT_OVER_LIST_PRICE(j)    :=      p_oks_billrate_schedules_v_tbl(i).PERCENT_OVER_LIST_PRICE;
      In_PROGRAM_APPLICATION_ID(j)    :=      p_oks_billrate_schedules_v_tbl(i).PROGRAM_APPLICATION_ID;
      In_PROGRAM_ID(j)    :=      p_oks_billrate_schedules_v_tbl(i).PROGRAM_ID;
      In_PROGRAM_UPDATE_DATE(j)    :=      p_oks_billrate_schedules_v_tbl(i).PROGRAM_UPDATE_DATE;
      In_REQUEST_ID(j)    :=      p_oks_billrate_schedules_v_tbl(i).REQUEST_ID;
      In_CREATED_BY(j)    :=      p_oks_billrate_schedules_v_tbl(i).CREATED_BY;
      In_CREATION_DATE(j)    :=      p_oks_billrate_schedules_v_tbl(i).CREATION_DATE;
      In_LAST_UPDATED_BY(j)    :=      p_oks_billrate_schedules_v_tbl(i).LAST_UPDATED_BY;
      In_LAST_UPDATE_DATE(j)    :=      p_oks_billrate_schedules_v_tbl(i).LAST_UPDATE_DATE;
      In_LAST_UPDATE_LOGIN(j)    :=      p_oks_billrate_schedules_v_tbl(i).LAST_UPDATE_LOGIN;
      In_SECURITY_GROUP_ID(j)    :=      p_oks_billrate_schedules_v_tbl(i).SECURITY_GROUP_ID;
      In_OBJECT_VERSION_NUMBER(j)    :=      p_oks_billrate_schedules_v_tbl(i).OBJECT_VERSION_NUMBER;

      i  :=p_oks_billrate_schedules_v_tbl.NEXT(i);

 END LOOP;

FORALL i in 1..l_tabsize
   INSERT      INTO OKS_BILLRATE_SCHEDULES (
ID,
CLE_ID,
BT_CLE_ID,
DNZ_CHR_ID,
START_HOUR,
START_MINUTE,
END_HOUR,
END_MINUTE,
MONDAY_FLAG,
TUESDAY_FLAG,
WEDNESDAY_FLAG,
THURSDAY_FLAG,
FRIDAY_FLAG,
SATURDAY_FLAG,
SUNDAY_FLAG,
OBJECT1_ID1,
OBJECT1_ID2,
JTOT_OBJECT1_CODE,
BILL_RATE_CODE,
FLAT_RATE,
UOM,
HOLIDAY_YN,
PERCENT_OVER_LIST_PRICE,
PROGRAM_APPLICATION_ID,
PROGRAM_ID,
PROGRAM_UPDATE_DATE,
REQUEST_ID,
CREATED_BY,
CREATION_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATE_LOGIN,
SECURITY_GROUP_ID,
OBJECT_VERSION_NUMBER)
VALUES (
in_ID(i),
in_CLE_ID(i),
in_BT_CLE_ID(i),
in_DNZ_CHR_ID(i),
in_START_HOUR(i),
in_START_MINUTE(i),
in_END_HOUR(i),
in_END_MINUTE(i),
in_MONDAY_FLAG(i),
in_TUESDAY_FLAG(i),
in_WEDNESDAY_FLAG(i),
in_THURSDAY_FLAG(i),
in_FRIDAY_FLAG(i),
in_SATURDAY_FLAG(i),
in_SUNDAY_FLAG(i),
in_OBJECT1_ID1(i),
in_OBJECT1_ID2(i),
in_JTOT_OBJECT1_CODE(i),
in_BILL_RATE_CODE(i),
in_FLAT_RATE(i),
in_UOM(i),
in_HOLIDAY_YN(i),
in_PERCENT_OVER_LIST_PRICE(i),
in_PROGRAM_APPLICATION_ID(i),
in_PROGRAM_ID(i),
in_PROGRAM_UPDATE_DATE(i),
in_REQUEST_ID(i),
in_CREATED_BY(i),
in_CREATION_DATE(i),
in_LAST_UPDATED_BY(i),
in_LAST_UPDATE_DATE(i),
in_LAST_UPDATE_LOGIN(i),
in_SECURITY_GROUP_ID(i),
in_OBJECT_VERSION_NUMBER(i));

    IF (l_debug = 'Y') THEN
       okc_debug.log('23500: Exiting INSERT_ROW_UPG', 2);
       okc_debug.Reset_Indentation;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 'Y') THEN
       okc_debug.log('23600: Exiting INSERT_ROW_UPG:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END INSERT_ROW_UPG_bill_sch;

PROCEDURE INSERT_ROW_UPG_KHRV_TBL
                        (x_return_status OUT NOCOPY VARCHAR2,
                         P_KHRV_TBL  OKS_KHR_PVT.khrv_tbl_type) IS


l_tabsize NUMBER := P_KHRV_TBL.COUNT;
l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;
l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
In_ID           OKC_DATATYPES.NumberTabTyp;
In_CHR_ID           OKC_DATATYPES.NumberTabTyp;
In_ACCT_RULE_ID           OKC_DATATYPES.NumberTabTyp;
In_PAYMENT_TYPE           OKC_DATATYPES.VAR30TabTyp;
In_CC_NO           OKC_DATATYPES.VAR120TabTyp;
In_CC_EXPIRY_DATE           OKC_DATATYPES.DateTabTyp;
In_CC_BANK_ACCT_ID           OKC_DATATYPES.NumberTabTyp;
In_CC_AUTH_CODE           OKC_DATATYPES.VAR150TabTyp;
In_GRACE_DURATION           OKC_DATATYPES.NumberTabTyp;
In_GRACE_PERIOD           OKC_DATATYPES.VAR30TabTyp;
In_EST_REV_PERCENT           OKC_DATATYPES.NumberTabTyp;
In_EST_REV_DATE           OKC_DATATYPES.DateTabTyp;
In_TAX_AMOUNT           OKC_DATATYPES.NumberTabTyp;
In_TAX_STATUS           OKC_DATATYPES.VAR30TabTyp;
In_TAX_CODE           OKC_DATATYPES.NumberTabTyp;
In_TAX_EXEMPTION_ID           OKC_DATATYPES.NumberTabTyp;
In_BILLING_PROFILE_ID           OKC_DATATYPES.NumberTabTyp;
In_RENEWAL_STATUS           OKC_DATATYPES.VAR30TabTyp;
In_ELECTRONIC_RENEWAL_FLAG           OKC_DATATYPES.VAR3TabTyp;
In_QUOTE_TO_CONTACT_ID           OKC_DATATYPES.NumberTabTyp;
In_QUOTE_TO_SITE_ID           OKC_DATATYPES.NumberTabTyp;
In_QUOTE_TO_EMAIL_ID           OKC_DATATYPES.NumberTabTyp;
In_QUOTE_TO_PHONE_ID           OKC_DATATYPES.NumberTabTyp;
In_QUOTE_TO_FAX_ID           OKC_DATATYPES.NumberTabTyp;
In_RENEWAL_PO_REQUIRED           OKC_DATATYPES.VAR3TabTyp;
In_RENEWAL_PO_NUMBER           OKC_DATATYPES.VAR240TabTyp;
In_RENEWAL_PRICE_LIST           OKC_DATATYPES.NumberTabTyp;
In_RENEWAL_PRICING_TYPE           OKC_DATATYPES.VAR30TabTyp;
In_RENEWAL_MARKUP_PERCENT           OKC_DATATYPES.NumberTabTyp;
In_RENEWAL_GRACE_DURATION           OKC_DATATYPES.NumberTabTyp;
In_RENEWAL_GRACE_PERIOD           OKC_DATATYPES.VAR30TabTyp;
In_RENEWAL_EST_REV_PERCENT           OKC_DATATYPES.NumberTabTyp;
In_RENEWAL_EST_REV_DURATION           OKC_DATATYPES.NumberTabTyp;
In_RENEWAL_EST_REV_PERIOD           OKC_DATATYPES.VAR30TabTyp;
In_RENEWAL_PRICE_LIST_USED           OKC_DATATYPES.NumberTabTyp;
In_RENEWAL_TYPE_USED           OKC_DATATYPES.VAR30TabTyp;
In_RENEWAL_NOTIFICATION_TO           OKC_DATATYPES.NumberTabTyp;
In_RENEWAL_PO_USED           OKC_DATATYPES.VAR3TabTyp;
In_RENEWAL_PRICING_TYPE_USED           OKC_DATATYPES.VAR30TabTyp;
In_RENEWAL_MARKUP_PERCENT_USED           OKC_DATATYPES.NumberTabTyp;
In_REV_EST_PERCENT_USED           OKC_DATATYPES.NumberTabTyp;
In_REV_EST_DURATION_USED           OKC_DATATYPES.NumberTabTyp;
In_REV_EST_PERIOD_USED           OKC_DATATYPES.VAR30TabTyp;
In_BILLING_PROFILE_USED           OKC_DATATYPES.NumberTabTyp;
In_ERN_FLAG_USED_YN           OKC_DATATYPES.VAR3TabTyp;
In_EVN_THRESHOLD_AMT           OKC_DATATYPES.NumberTabTyp;
In_EVN_THRESHOLD_CUR           OKC_DATATYPES.VAR30TabTyp;
In_ERN_THRESHOLD_AMT           OKC_DATATYPES.NumberTabTyp;
In_ERN_THRESHOLD_CUR           OKC_DATATYPES.VAR30TabTyp;
In_RENEWAL_GRACE_DURATION_USED           OKC_DATATYPES.NumberTabTyp;
In_RENEWAL_GRACE_PERIOD_USED           OKC_DATATYPES.VAR30TabTyp;
In_INV_TRX_TYPE           OKC_DATATYPES.VAR30TabTyp;
In_INV_PRINT_PROFILE           OKC_DATATYPES.VAR3TabTyp;
In_AR_INTERFACE_YN           OKC_DATATYPES.VAR3TabTyp;
In_HOLD_BILLING           OKC_DATATYPES.VAR3TabTyp;
In_SUMMARY_TRX_YN           OKC_DATATYPES.VAR3TabTyp;
In_SERVICE_PO_NUMBER           OKC_DATATYPES.VAR240TabTyp;
In_SERVICE_PO_REQUIRED           OKC_DATATYPES.VAR3TabTyp;
In_BILLING_SCHEDULE_TYPE           OKC_DATATYPES.VAR10TabTyp;
In_OBJECT_VERSION_NUMBER           OKC_DATATYPES.NumberTabTyp;
In_SECURITY_GROUP_ID           OKC_DATATYPES.NumberTabTyp;
In_REQUEST_ID           OKC_DATATYPES.NumberTabTyp;
In_CREATED_BY           OKC_DATATYPES.NumberTabTyp;
In_CREATION_DATE           OKC_DATATYPES.DateTabTyp;
In_LAST_UPDATED_BY           OKC_DATATYPES.NumberTabTyp;
In_LAST_UPDATE_DATE           OKC_DATATYPES.DateTabTyp;
In_LAST_UPDATE_LOGIN           OKC_DATATYPES.NumberTabTyp;
In_COMMITMENT_ID           OKC_DATATYPES.NumberTabTyp;
  i                                NUMBER := P_KHRV_TBL.FIRST;
  j                                NUMBER := 0;
BEGIN
x_return_status := OKC_API.G_RET_STS_SUCCESS;
IF (l_debug = 'Y') THEN
okc_debug.Set_Indentation('OKS_KHR_PVT');
okc_debug.log('23400: Entered INSERT_ROW_UPG', 2);
 END IF;
   WHILE i IS NOT NULL
     LOOP
       j                               := j +1;
      In_ID(j)    :=      P_KHRV_TBL(i).ID;
      In_CHR_ID(j)    :=      P_KHRV_TBL(i).CHR_ID;
      In_ACCT_RULE_ID(j)    :=      P_KHRV_TBL(i).ACCT_RULE_ID;
      In_PAYMENT_TYPE(j)    :=      P_KHRV_TBL(i).PAYMENT_TYPE;
      In_CC_NO(j)    :=      P_KHRV_TBL(i).CC_NO;
      In_CC_EXPIRY_DATE(j)    :=      P_KHRV_TBL(i).CC_EXPIRY_DATE;
      In_CC_BANK_ACCT_ID(j)    :=      P_KHRV_TBL(i).CC_BANK_ACCT_ID;
      In_CC_AUTH_CODE(j)    :=      P_KHRV_TBL(i).CC_AUTH_CODE;
      In_GRACE_DURATION(j)    :=      P_KHRV_TBL(i).GRACE_DURATION;
      In_GRACE_PERIOD(j)    :=      P_KHRV_TBL(i).GRACE_PERIOD;
      In_EST_REV_PERCENT(j)    :=      P_KHRV_TBL(i).EST_REV_PERCENT;
      In_EST_REV_DATE(j)    :=      P_KHRV_TBL(i).EST_REV_DATE;
      In_TAX_AMOUNT(j)    :=      P_KHRV_TBL(i).TAX_AMOUNT;
      In_TAX_STATUS(j)    :=      P_KHRV_TBL(i).TAX_STATUS;
      In_TAX_CODE(j)    :=      P_KHRV_TBL(i).TAX_CODE;
      In_TAX_EXEMPTION_ID(j)    :=      P_KHRV_TBL(i).TAX_EXEMPTION_ID;
      In_BILLING_PROFILE_ID(j)    :=      P_KHRV_TBL(i).BILLING_PROFILE_ID;
      In_RENEWAL_STATUS(j)    :=      P_KHRV_TBL(i).RENEWAL_STATUS;
      In_ELECTRONIC_RENEWAL_FLAG(j)    :=      P_KHRV_TBL(i).ELECTRONIC_RENEWAL_FLAG;
      In_QUOTE_TO_CONTACT_ID(j)    :=      P_KHRV_TBL(i).QUOTE_TO_CONTACT_ID;
      In_QUOTE_TO_SITE_ID(j)    :=      P_KHRV_TBL(i).QUOTE_TO_SITE_ID;
      In_QUOTE_TO_EMAIL_ID(j)    :=      P_KHRV_TBL(i).QUOTE_TO_EMAIL_ID;
      In_QUOTE_TO_PHONE_ID(j)    :=      P_KHRV_TBL(i).QUOTE_TO_PHONE_ID;
      In_QUOTE_TO_FAX_ID(j)    :=      P_KHRV_TBL(i).QUOTE_TO_FAX_ID;
      In_RENEWAL_PO_REQUIRED(j)    :=      P_KHRV_TBL(i).RENEWAL_PO_REQUIRED;
      In_RENEWAL_PO_NUMBER(j)    :=      P_KHRV_TBL(i).RENEWAL_PO_NUMBER;
      In_RENEWAL_PRICE_LIST(j)    :=      P_KHRV_TBL(i).RENEWAL_PRICE_LIST;
      In_RENEWAL_PRICING_TYPE(j)    :=      P_KHRV_TBL(i).RENEWAL_PRICING_TYPE;
      In_RENEWAL_MARKUP_PERCENT(j)    :=      P_KHRV_TBL(i).RENEWAL_MARKUP_PERCENT;
      In_RENEWAL_GRACE_DURATION(j)    :=      P_KHRV_TBL(i).RENEWAL_GRACE_DURATION;
      In_RENEWAL_GRACE_PERIOD(j)    :=      P_KHRV_TBL(i).RENEWAL_GRACE_PERIOD;
      In_RENEWAL_EST_REV_PERCENT(j)    :=      P_KHRV_TBL(i).RENEWAL_EST_REV_PERCENT;
      In_RENEWAL_EST_REV_DURATION(j)    :=      P_KHRV_TBL(i).RENEWAL_EST_REV_DURATION;
      In_RENEWAL_EST_REV_PERIOD(j)    :=      P_KHRV_TBL(i).RENEWAL_EST_REV_PERIOD;
      In_RENEWAL_PRICE_LIST_USED(j)    :=      P_KHRV_TBL(i).RENEWAL_PRICE_LIST_USED;
      In_RENEWAL_TYPE_USED(j)    :=      P_KHRV_TBL(i).RENEWAL_TYPE_USED;
      In_RENEWAL_NOTIFICATION_TO(j)    :=      P_KHRV_TBL(i).RENEWAL_NOTIFICATION_TO;
      In_RENEWAL_PO_USED(j)    :=      P_KHRV_TBL(i).RENEWAL_PO_USED;
      In_RENEWAL_PRICING_TYPE_USED(j)    :=      P_KHRV_TBL(i).RENEWAL_PRICING_TYPE_USED;
      In_RENEWAL_MARKUP_PERCENT_USED(j)    :=      P_KHRV_TBL(i).RENEWAL_MARKUP_PERCENT_USED;
      In_REV_EST_PERCENT_USED(j)    :=      P_KHRV_TBL(i).REV_EST_PERCENT_USED;
      In_REV_EST_DURATION_USED(j)    :=      P_KHRV_TBL(i).REV_EST_DURATION_USED;
      In_REV_EST_PERIOD_USED(j)    :=      P_KHRV_TBL(i).REV_EST_PERIOD_USED;
      In_BILLING_PROFILE_USED(j)    :=      P_KHRV_TBL(i).BILLING_PROFILE_USED;
      In_ERN_FLAG_USED_YN(j)    :=      P_KHRV_TBL(i).ERN_FLAG_USED_YN;
      In_EVN_THRESHOLD_AMT(j)    :=      P_KHRV_TBL(i).EVN_THRESHOLD_AMT;
      In_EVN_THRESHOLD_CUR(j)    :=      P_KHRV_TBL(i).EVN_THRESHOLD_CUR;
      In_ERN_THRESHOLD_AMT(j)    :=      P_KHRV_TBL(i).ERN_THRESHOLD_AMT;
      In_ERN_THRESHOLD_CUR(j)    :=      P_KHRV_TBL(i).ERN_THRESHOLD_CUR;
      In_RENEWAL_GRACE_DURATION_USED(j)    :=      P_KHRV_TBL(i).RENEWAL_GRACE_DURATION_USED;
      In_RENEWAL_GRACE_PERIOD_USED(j)    :=      P_KHRV_TBL(i).RENEWAL_GRACE_PERIOD_USED;
      In_INV_TRX_TYPE(j)    :=      P_KHRV_TBL(i).INV_TRX_TYPE;
      In_INV_PRINT_PROFILE(j)    :=      P_KHRV_TBL(i).INV_PRINT_PROFILE;
      In_AR_INTERFACE_YN(j)    :=      P_KHRV_TBL(i).AR_INTERFACE_YN;
      In_HOLD_BILLING(j)    :=      P_KHRV_TBL(i).HOLD_BILLING;
      In_SUMMARY_TRX_YN(j)    :=      P_KHRV_TBL(i).SUMMARY_TRX_YN;
      In_SERVICE_PO_NUMBER(j)    :=      P_KHRV_TBL(i).SERVICE_PO_NUMBER;
      In_SERVICE_PO_REQUIRED(j)    :=      P_KHRV_TBL(i).SERVICE_PO_REQUIRED;
      In_BILLING_SCHEDULE_TYPE(j)    :=      P_KHRV_TBL(i).BILLING_SCHEDULE_TYPE;
      In_OBJECT_VERSION_NUMBER(j)    :=      P_KHRV_TBL(i).OBJECT_VERSION_NUMBER;
      In_SECURITY_GROUP_ID(j)    :=      P_KHRV_TBL(i).SECURITY_GROUP_ID;
      In_REQUEST_ID(j)    :=      P_KHRV_TBL(i).REQUEST_ID;
      In_CREATED_BY(j)    :=      P_KHRV_TBL(i).CREATED_BY;
      In_CREATION_DATE(j)    :=      P_KHRV_TBL(i).CREATION_DATE;
      In_LAST_UPDATED_BY(j)    :=      P_KHRV_TBL(i).LAST_UPDATED_BY;
      In_LAST_UPDATE_DATE(j)    :=      P_KHRV_TBL(i).LAST_UPDATE_DATE;
      In_LAST_UPDATE_LOGIN(j)    :=      P_KHRV_TBL(i).LAST_UPDATE_LOGIN;
      In_COMMITMENT_ID(j)    :=      P_KHRV_TBL(i).COMMITMENT_ID;
      i  :=P_KHRV_TBL.NEXT(i);
 END LOOP;
FORALL i in 1..l_tabsize
   INSERT      INTO OKS_K_HEADERS_B (
ID,
CHR_ID,
ACCT_RULE_ID,
PAYMENT_TYPE,
CC_NO,
CC_EXPIRY_DATE,
CC_BANK_ACCT_ID,
CC_AUTH_CODE,
GRACE_DURATION,
GRACE_PERIOD,
EST_REV_PERCENT,
EST_REV_DATE,
TAX_AMOUNT,
TAX_STATUS,
TAX_CODE,
TAX_EXEMPTION_ID,
BILLING_PROFILE_ID,
RENEWAL_STATUS,
ELECTRONIC_RENEWAL_FLAG,
QUOTE_TO_CONTACT_ID,
QUOTE_TO_SITE_ID,
QUOTE_TO_EMAIL_ID,
QUOTE_TO_PHONE_ID,
QUOTE_TO_FAX_ID,
RENEWAL_PO_REQUIRED,
RENEWAL_PO_NUMBER,
RENEWAL_PRICE_LIST,
RENEWAL_PRICING_TYPE,
RENEWAL_MARKUP_PERCENT,
RENEWAL_GRACE_DURATION,
RENEWAL_GRACE_PERIOD,
RENEWAL_EST_REV_PERCENT,
RENEWAL_EST_REV_DURATION,
RENEWAL_EST_REV_PERIOD,
RENEWAL_PRICE_LIST_USED,
RENEWAL_TYPE_USED,
RENEWAL_NOTIFICATION_TO,
RENEWAL_PO_USED,
RENEWAL_PRICING_TYPE_USED,
RENEWAL_MARKUP_PERCENT_USED,
REV_EST_PERCENT_USED,
REV_EST_DURATION_USED,
REV_EST_PERIOD_USED,
BILLING_PROFILE_USED,
ERN_FLAG_USED_YN,
EVN_THRESHOLD_AMT,
EVN_THRESHOLD_CUR,
ERN_THRESHOLD_AMT,
ERN_THRESHOLD_CUR,
RENEWAL_GRACE_DURATION_USED,
RENEWAL_GRACE_PERIOD_USED,
INV_TRX_TYPE,
INV_PRINT_PROFILE,
AR_INTERFACE_YN,
HOLD_BILLING,
SUMMARY_TRX_YN,
SERVICE_PO_NUMBER,
SERVICE_PO_REQUIRED,
BILLING_SCHEDULE_TYPE,
OBJECT_VERSION_NUMBER,
SECURITY_GROUP_ID,
REQUEST_ID,
CREATED_BY,
CREATION_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATE_LOGIN,
COMMITMENT_ID)
VALUES (
in_ID(i),
in_CHR_ID(i),
in_ACCT_RULE_ID(i),
in_PAYMENT_TYPE(i),
in_CC_NO(i),
in_CC_EXPIRY_DATE(i),
in_CC_BANK_ACCT_ID(i),
in_CC_AUTH_CODE(i),
in_GRACE_DURATION(i),
in_GRACE_PERIOD(i),
in_EST_REV_PERCENT(i),
in_EST_REV_DATE(i),
in_TAX_AMOUNT(i),
in_TAX_STATUS(i),
in_TAX_CODE(i),
in_TAX_EXEMPTION_ID(i),
in_BILLING_PROFILE_ID(i),
in_RENEWAL_STATUS(i),
in_ELECTRONIC_RENEWAL_FLAG(i),
in_QUOTE_TO_CONTACT_ID(i),
in_QUOTE_TO_SITE_ID(i),
in_QUOTE_TO_EMAIL_ID(i),
in_QUOTE_TO_PHONE_ID(i),
in_QUOTE_TO_FAX_ID(i),
in_RENEWAL_PO_REQUIRED(i),
in_RENEWAL_PO_NUMBER(i),
in_RENEWAL_PRICE_LIST(i),
in_RENEWAL_PRICING_TYPE(i),
in_RENEWAL_MARKUP_PERCENT(i),
in_RENEWAL_GRACE_DURATION(i),
in_RENEWAL_GRACE_PERIOD(i),
in_RENEWAL_EST_REV_PERCENT(i),
in_RENEWAL_EST_REV_DURATION(i),
in_RENEWAL_EST_REV_PERIOD(i),
in_RENEWAL_PRICE_LIST_USED(i),
in_RENEWAL_TYPE_USED(i),
in_RENEWAL_NOTIFICATION_TO(i),
in_RENEWAL_PO_USED(i),
in_RENEWAL_PRICING_TYPE_USED(i),
in_RENEWAL_MARKUP_PERCENT_USED(i),
in_REV_EST_PERCENT_USED(i),
in_REV_EST_DURATION_USED(i),
in_REV_EST_PERIOD_USED(i),
in_BILLING_PROFILE_USED(i),
in_ERN_FLAG_USED_YN(i),
in_EVN_THRESHOLD_AMT(i),
in_EVN_THRESHOLD_CUR(i),
in_ERN_THRESHOLD_AMT(i),
in_ERN_THRESHOLD_CUR(i),
in_RENEWAL_GRACE_DURATION_USED(i),
in_RENEWAL_GRACE_PERIOD_USED(i),
in_INV_TRX_TYPE(i),
in_INV_PRINT_PROFILE(i),
in_AR_INTERFACE_YN(i),
in_HOLD_BILLING(i),
in_SUMMARY_TRX_YN(i),
in_SERVICE_PO_NUMBER(i),
in_SERVICE_PO_REQUIRED(i),
in_BILLING_SCHEDULE_TYPE(i),
in_OBJECT_VERSION_NUMBER(i),
in_SECURITY_GROUP_ID(i),
in_REQUEST_ID(i),
in_CREATED_BY(i),
in_CREATION_DATE(i),
in_LAST_UPDATED_BY(i),
in_LAST_UPDATE_DATE(i),
in_LAST_UPDATE_LOGIN(i),
in_COMMITMENT_ID(i));
    IF (l_debug = 'Y') THEN
       okc_debug.log('23500: Exiting INSERT_ROW_UPG', 2);
       okc_debug.Reset_Indentation;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 'Y') THEN
       okc_debug.log('23600: Exiting INSERT_ROW_UPG:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END INSERT_ROW_UPG_KHRV_TBL;


PROCEDURE INSERT_ROW_UPG_sllv_tbl (x_return_status OUT NOCOPY VARCHAR2, p_sllv_tbl  OKS_SLL_PVT.sllv_tbl_type) IS
l_tabsize NUMBER := p_sllv_tbl.COUNT;
l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;
l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
In_ID           OKC_DATATYPES.NumberTabTyp;
In_CHR_ID           OKC_DATATYPES.NumberTabTyp;
In_CLE_ID           OKC_DATATYPES.NumberTabTyp;
In_DNZ_CHR_ID           OKC_DATATYPES.NumberTabTyp;
In_SEQUENCE_NO           OKC_DATATYPES.NumberTabTyp;
In_UOM_CODE           OKC_DATATYPES.VAR3TabTyp;
In_START_DATE           OKC_DATATYPES.DateTabTyp;
In_END_DATE           OKC_DATATYPES.DateTabTyp;
In_LEVEL_PERIODS           OKC_DATATYPES.NumberTabTyp;
In_UOM_PER_PERIOD           OKC_DATATYPES.NumberTabTyp;
In_ADVANCE_PERIODS           OKC_DATATYPES.NumberTabTyp;
In_LEVEL_AMOUNT           OKC_DATATYPES.NumberTabTyp;
In_INVOICE_OFFSET_DAYS           OKC_DATATYPES.NumberTabTyp;
In_INTERFACE_OFFSET_DAYS           OKC_DATATYPES.NumberTabTyp;
In_COMMENTS           OKC_DATATYPES.VAR1995TabTyp;
In_DUE_ARR_YN           OKC_DATATYPES.VAR3TabTyp;
In_AMOUNT           OKC_DATATYPES.NumberTabTyp;
In_LINES_DETAILED_YN           OKC_DATATYPES.VAR3TabTyp;
In_OBJECT_VERSION_NUMBER           OKC_DATATYPES.NumberTabTyp;
In_REQUEST_ID           OKC_DATATYPES.NumberTabTyp;
In_CREATED_BY           OKC_DATATYPES.NumberTabTyp;
In_CREATION_DATE           OKC_DATATYPES.DateTabTyp;
In_LAST_UPDATED_BY           OKC_DATATYPES.NumberTabTyp;
In_LAST_UPDATE_DATE           OKC_DATATYPES.DateTabTyp;
In_LAST_UPDATE_LOGIN           OKC_DATATYPES.NumberTabTyp;
  i                                NUMBER := p_sllv_tbl.FIRST;
  j                                NUMBER := 0;

BEGIN
x_return_status := OKC_API.G_RET_STS_SUCCESS;
IF (l_debug = 'Y') THEN
okc_debug.Set_Indentation('OKS_SLL_PVT');
okc_debug.log('23400: Entered INSERT_ROW_UPG', 2);
 END IF;
   WHILE i IS NOT NULL
     LOOP
       j                               := j +1;
      In_ID(j)    :=      p_sllv_tbl(i).ID;
      In_CHR_ID(j)    :=      p_sllv_tbl(i).CHR_ID;
      In_CLE_ID(j)    :=      p_sllv_tbl(i).CLE_ID;
      In_DNZ_CHR_ID(j)    :=      p_sllv_tbl(i).DNZ_CHR_ID;
      In_SEQUENCE_NO(j)    :=      p_sllv_tbl(i).SEQUENCE_NO;
      In_UOM_CODE(j)    :=      p_sllv_tbl(i).UOM_CODE;
      In_START_DATE(j)    :=      p_sllv_tbl(i).START_DATE;
      In_END_DATE(j)    :=      p_sllv_tbl(i).END_DATE;
      In_LEVEL_PERIODS(j)    :=      p_sllv_tbl(i).LEVEL_PERIODS;
      In_UOM_PER_PERIOD(j)    :=      p_sllv_tbl(i).UOM_PER_PERIOD;
      In_ADVANCE_PERIODS(j)    :=      p_sllv_tbl(i).ADVANCE_PERIODS;
      In_LEVEL_AMOUNT(j)    :=      p_sllv_tbl(i).LEVEL_AMOUNT;
      In_INVOICE_OFFSET_DAYS(j)    :=      p_sllv_tbl(i).INVOICE_OFFSET_DAYS;
      In_INTERFACE_OFFSET_DAYS(j)    :=      p_sllv_tbl(i).INTERFACE_OFFSET_DAYS;
      In_COMMENTS(j)    :=      p_sllv_tbl(i).COMMENTS;
      In_DUE_ARR_YN(j)    :=      p_sllv_tbl(i).DUE_ARR_YN;
      In_AMOUNT(j)    :=      p_sllv_tbl(i).AMOUNT;
      In_LINES_DETAILED_YN(j)    :=      p_sllv_tbl(i).LINES_DETAILED_YN;
      In_OBJECT_VERSION_NUMBER(j)    :=      p_sllv_tbl(i).OBJECT_VERSION_NUMBER;
      In_REQUEST_ID(j)    :=      p_sllv_tbl(i).REQUEST_ID;
      In_CREATED_BY(j)    :=      p_sllv_tbl(i).CREATED_BY;
      In_CREATION_DATE(j)    :=      p_sllv_tbl(i).CREATION_DATE;
      In_LAST_UPDATED_BY(j)    :=      p_sllv_tbl(i).LAST_UPDATED_BY;
      In_LAST_UPDATE_DATE(j)    :=      p_sllv_tbl(i).LAST_UPDATE_DATE;
      In_LAST_UPDATE_LOGIN(j)    :=      p_sllv_tbl(i).LAST_UPDATE_LOGIN;
      i  :=p_sllv_tbl.NEXT(i);
 END LOOP;
FORALL i in 1..l_tabsize
   INSERT      INTO OKS_STREAM_LEVELS_B (
ID,
CHR_ID,
CLE_ID,
DNZ_CHR_ID,
SEQUENCE_NO,
UOM_CODE,
START_DATE,
END_DATE,
LEVEL_PERIODS,
UOM_PER_PERIOD,
ADVANCE_PERIODS,
LEVEL_AMOUNT,
INVOICE_OFFSET_DAYS,
INTERFACE_OFFSET_DAYS,
COMMENTS,
DUE_ARR_YN,
AMOUNT,
LINES_DETAILED_YN,
OBJECT_VERSION_NUMBER,
SECURITY_GROUP_ID,
REQUEST_ID,
CREATED_BY,
CREATION_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATE_LOGIN)
VALUES (
in_ID(i),
in_CHR_ID(i),
in_CLE_ID(i),
in_DNZ_CHR_ID(i),
in_SEQUENCE_NO(i),
in_UOM_CODE(i),
in_START_DATE(i),
in_END_DATE(i),
in_LEVEL_PERIODS(i),
in_UOM_PER_PERIOD(i),
in_ADVANCE_PERIODS(i),
in_LEVEL_AMOUNT(i),
in_INVOICE_OFFSET_DAYS(i),
in_INTERFACE_OFFSET_DAYS(i),
in_COMMENTS(i),
in_DUE_ARR_YN(i),
in_AMOUNT(i),
in_LINES_DETAILED_YN(i),
in_OBJECT_VERSION_NUMBER(i),
NULL,
in_REQUEST_ID(i),
in_CREATED_BY(i),
in_CREATION_DATE(i),
in_LAST_UPDATED_BY(i),
in_LAST_UPDATE_DATE(i),
in_LAST_UPDATE_LOGIN(i));
    IF (l_debug = 'Y') THEN
       okc_debug.log('23500: Exiting INSERT_ROW_UPG', 2);
       okc_debug.Reset_Indentation;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 'Y') THEN
       okc_debug.log('23600: Exiting INSERT_ROW_UPG:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END INSERT_ROW_UPG_sllv_tbl;


PROCEDURE INSERT_ROW_UPG_letv_tbl (x_return_status OUT NOCOPY VARCHAR2, p_letv_tbl  OKS_BILL_LEVEL_ELEMENTS_PVT.letv_tbl_type) IS
l_tabsize NUMBER := p_letv_tbl.COUNT;
l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;
l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
In_ID           OKC_DATATYPES.NumberTabTyp;
In_SEQUENCE_NUMBER           OKC_DATATYPES.VAR240TabTyp;
In_DATE_START           OKC_DATATYPES.DateTabTyp;
In_AMOUNT           OKC_DATATYPES.NumberTabTyp;
In_DATE_RECEIVABLE_GL           OKC_DATATYPES.DateTabTyp;
In_DATE_REVENUE_RULE_START           OKC_DATATYPES.DateTabTyp;
In_DATE_TRANSACTION           OKC_DATATYPES.DateTabTyp;
In_DATE_DUE           OKC_DATATYPES.DateTabTyp;
In_DATE_PRINT           OKC_DATATYPES.DateTabTyp;
In_DATE_TO_INTERFACE           OKC_DATATYPES.DateTabTyp;
In_DATE_COMPLETED           OKC_DATATYPES.DateTabTyp;
In_OBJECT_VERSION_NUMBER           OKC_DATATYPES.NumberTabTyp;
In_RUL_ID           OKC_DATATYPES.NumberTabTyp;
In_CREATED_BY           OKC_DATATYPES.NumberTabTyp;
In_CREATION_DATE           OKC_DATATYPES.DateTabTyp;
In_LAST_UPDATED_BY           OKC_DATATYPES.NumberTabTyp;
In_LAST_UPDATE_DATE           OKC_DATATYPES.DateTabTyp;
--In_SECURITY_GROUP_ID           OKC_DATATYPES.NumberTabTyp;
In_CLE_ID           OKC_DATATYPES.NumberTabTyp;
In_DNZ_CHR_ID           OKC_DATATYPES.NumberTabTyp;
In_DATE_END           OKC_DATATYPES.DateTabTyp;
In_PARENT_CLE_ID           OKC_DATATYPES.NumberTabTyp;
  i                                NUMBER := p_letv_tbl.FIRST;
  j                                NUMBER := 0;

BEGIN
x_return_status := OKC_API.G_RET_STS_SUCCESS;
IF (l_debug = 'Y') THEN
okc_debug.Set_Indentation('OKS_BILL_LEVEL_ELEMENTS_PVT');
okc_debug.log('23400: Entered INSERT_ROW_UPG', 2);
 END IF;
   WHILE i IS NOT NULL
     LOOP
       j                               := j +1;
      In_ID(j)    :=      p_letv_tbl(i).ID;
      In_SEQUENCE_NUMBER(j)    :=      p_letv_tbl(i).SEQUENCE_NUMBER;
      In_DATE_START(j)    :=      p_letv_tbl(i).DATE_START;
      In_AMOUNT(j)    :=      p_letv_tbl(i).AMOUNT;
      In_DATE_RECEIVABLE_GL(j)    :=      p_letv_tbl(i).DATE_RECEIVABLE_GL;
      In_DATE_REVENUE_RULE_START(j)    :=      p_letv_tbl(i).DATE_REVENUE_RULE_START;
      In_DATE_TRANSACTION(j)    :=      p_letv_tbl(i).DATE_TRANSACTION;
      In_DATE_DUE(j)    :=      p_letv_tbl(i).DATE_DUE;
      In_DATE_PRINT(j)    :=      p_letv_tbl(i).DATE_PRINT;
      In_DATE_TO_INTERFACE(j)    :=      p_letv_tbl(i).DATE_TO_INTERFACE;
      In_DATE_COMPLETED(j)    :=      p_letv_tbl(i).DATE_COMPLETED;
      In_OBJECT_VERSION_NUMBER(j)    :=      p_letv_tbl(i).OBJECT_VERSION_NUMBER;
      In_RUL_ID(j)    :=      p_letv_tbl(i).RUL_ID;
      In_CREATED_BY(j)    :=      p_letv_tbl(i).CREATED_BY;
      In_CREATION_DATE(j)    :=      p_letv_tbl(i).CREATION_DATE;
      In_LAST_UPDATED_BY(j)    :=      p_letv_tbl(i).LAST_UPDATED_BY;
      In_LAST_UPDATE_DATE(j)    :=      p_letv_tbl(i).LAST_UPDATE_DATE;
    --  In_SECURITY_GROUP_ID(j)    :=      p_letv_tbl(i).SECURITY_GROUP_ID;
      In_CLE_ID(j)    :=      p_letv_tbl(i).CLE_ID;
      In_DNZ_CHR_ID(j)    :=      p_letv_tbl(i).DNZ_CHR_ID;
      In_DATE_END(j)    :=      p_letv_tbl(i).DATE_END;
      In_PARENT_CLE_ID(j)    :=      p_letv_tbl(i).PARENT_CLE_ID;
      i  :=p_letv_tbl.NEXT(i);
 END LOOP;
FORALL i in 1..l_tabsize
   INSERT      INTO OKS_LEVEL_ELEMENTS (
ID,
SEQUENCE_NUMBER,
DATE_START,
AMOUNT,
DATE_RECEIVABLE_GL,
DATE_REVENUE_RULE_START,
DATE_TRANSACTION,
DATE_DUE,
DATE_PRINT,
DATE_TO_INTERFACE,
DATE_COMPLETED,
OBJECT_VERSION_NUMBER,
RUL_ID,
CREATED_BY,
CREATION_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_DATE,
SECURITY_GROUP_ID,
CLE_ID,
DNZ_CHR_ID,
DATE_END,
PARENT_CLE_ID)
VALUES (
in_ID(i),
in_SEQUENCE_NUMBER(i),
in_DATE_START(i),
in_AMOUNT(i),
in_DATE_RECEIVABLE_GL(i),
in_DATE_REVENUE_RULE_START(i),
in_DATE_TRANSACTION(i),
in_DATE_DUE(i),
in_DATE_PRINT(i),
in_DATE_TO_INTERFACE(i),
in_DATE_COMPLETED(i),
in_OBJECT_VERSION_NUMBER(i),
in_RUL_ID(i),
in_CREATED_BY(i),
in_CREATION_DATE(i),
in_LAST_UPDATED_BY(i),
in_LAST_UPDATE_DATE(i),
NULL,
in_CLE_ID(i),
in_DNZ_CHR_ID(i),
in_DATE_END(i),
in_PARENT_CLE_ID(i));
    IF (l_debug = 'Y') THEN
       okc_debug.log('23500: Exiting INSERT_ROW_UPG', 2);
       okc_debug.Reset_Indentation;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 'Y') THEN
       okc_debug.log('23600: Exiting INSERT_ROW_UPG:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END INSERT_ROW_UPG_letv_tbl;





  -----------------------------------------------------------------------------
  -- Start INSERT_SUB_TBLS  Added by AVReddy on Dec 22 03
  -----------------------------------------------------------------------------


  PROCEDURE INSERT_BY_TBL_SUBHDR(
               x_return_status OUT NOCOPY VARCHAR2
              ,P_SUBHDR_TBL  OKS_SUBSCR_HDR_PVT.schv_tbl_type) IS

     l_in_id                             OKC_DATATYPES.NumberTabTyp;
     l_in_name                           OKC_DATATYPES.Var240TabTyp;
     l_in_description                    OKC_DATATYPES.Var1995TabTyp;
     l_in_cle_id                         OKC_DATATYPES.NumberTabTyp;
     l_in_dnz_chr_id                     OKC_DATATYPES.NumberTabTyp;
     l_in_instance_id                    OKC_DATATYPES.NumberTabTyp;
     l_in_sfwt_flag                      OKC_DATATYPES.Var3TabTyp;
     l_in_subscription_type              OKC_DATATYPES.Var30TabTyp;
     l_in_item_type                      OKC_DATATYPES.Var10TabTyp;
     l_in_media_type                     OKC_DATATYPES.Var10TabTyp;
     l_in_status                         OKC_DATATYPES.Var3TabTyp;
     l_in_frequency                      OKC_DATATYPES.Var75TabTyp;
     l_in_fulfillment_channel            OKC_DATATYPES.Var30TabTyp;
     l_in_offset                         OKC_DATATYPES.NumberTabTyp;
     l_in_comments                       OKC_DATATYPES.Var1995TabTyp;
     l_in_object_version_number          OKC_DATATYPES.NumberTabTyp;
     l_in_created_by                     OKC_DATATYPES.NumberTabTyp;
     l_in_creation_date                  OKC_DATATYPES.DateTabTyp;
     l_in_last_updated_by                OKC_DATATYPES.NumberTabTyp;
     l_in_last_update_date               OKC_DATATYPES.DateTabTyp;
     l_in_last_update_login              OKC_DATATYPES.NumberTabTyp;
     l_in_UPG_ORIG_SYSTEM_REF            OKC_DATATYPES.Var75TabTyp;
     l_in_UPG_ORIG_SYSTEM_REF_ID         OKC_DATATYPES.NumberTabTyp;

     l_in_tabsize              NUMBER       := P_SUBHDR_TBL.COUNT;
     l_source_lang             VARCHAR2(12) := okc_util.get_userenv_lang;
     tbl_idx                   NUMBER;
     j                         NUMBER       := 0;


  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKS_SUBSCR_HDR_PVT');
       okc_debug.log('23400: Entered INSERT_ROW_SUBHDR_UPG', 2);
    END IF;
    tbl_idx  := P_SUBHDR_TBL.FIRST;

    WHILE tbl_idx IS NOT NULL LOOP
      j                                      := j +1;
      l_in_id(j)                             := P_SUBHDR_TBL(tbl_idx).id;
      l_in_name(j)                           := P_SUBHDR_TBL(tbl_idx).name;
      l_in_description(j)                    := P_SUBHDR_TBL(tbl_idx).description;
      l_in_cle_id(j)                         := P_SUBHDR_TBL(tbl_idx).cle_id;
      l_in_dnz_chr_id(j)                     := P_SUBHDR_TBL(tbl_idx).dnz_chr_id;
      l_in_instance_id(j)                    := P_SUBHDR_TBL(tbl_idx).instance_id;
      l_in_sfwt_flag(j)                      := P_SUBHDR_TBL(tbl_idx).sfwt_flag;
      l_in_subscription_type(j)              := P_SUBHDR_TBL(tbl_idx).subscription_type;
      l_in_item_type(j)                      := P_SUBHDR_TBL(tbl_idx).item_type;
      l_in_media_type(j)                     := P_SUBHDR_TBL(tbl_idx).media_type;
      l_in_status(j)                         := P_SUBHDR_TBL(tbl_idx).status;
      l_in_frequency(j)                      := P_SUBHDR_TBL(tbl_idx).frequency;
      l_in_fulfillment_channel(j)            := P_SUBHDR_TBL(tbl_idx).fulfillment_channel;
      l_in_offset(j)                         := P_SUBHDR_TBL(tbl_idx).offset;
      l_in_comments(j)                       := P_SUBHDR_TBL(tbl_idx).comments;
      l_in_object_version_number(j)          := P_SUBHDR_TBL(tbl_idx).object_version_number;
      l_in_created_by(j)                     := P_SUBHDR_TBL(tbl_idx).created_by;
      l_in_creation_date(j)                  := P_SUBHDR_TBL(tbl_idx).creation_date;
      l_in_last_updated_by(j)                := P_SUBHDR_TBL(tbl_idx).last_updated_by;
      l_in_last_update_date(j)               := P_SUBHDR_TBL(tbl_idx).last_update_date;
      l_in_last_update_login(j)              := P_SUBHDR_TBL(tbl_idx).last_update_login;
      l_in_UPG_ORIG_SYSTEM_REF(j)            := P_SUBHDR_TBL(tbl_idx).UPG_ORIG_SYSTEM_REF;
      l_in_UPG_ORIG_SYSTEM_REF_ID(j)         := P_SUBHDR_TBL(tbl_idx).UPG_ORIG_SYSTEM_REF_ID;
      tbl_idx                                := P_SUBHDR_TBL.NEXT(tbl_idx);

    END LOOP;
    FORALL x in 1    ..l_in_tabsize
      INSERT INTO OKS_SUBSCR_HEADER_B(
        id,
        cle_id,
        dnz_chr_id,
        instance_id,
        subscription_type,
        item_type,
        media_type,
        status,
        frequency,
        fulfillment_channel,
        offset,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
        ,UPG_ORIG_SYSTEM_REF
        ,UPG_ORIG_SYSTEM_REF_ID)
      VALUES (
         l_in_id(x)
        ,l_in_cle_id(x)
        ,l_in_dnz_chr_id(x)
        ,l_in_instance_id(x)
        ,l_in_subscription_type(x)
        ,l_in_item_type(x)
        ,l_in_media_type(x)
        ,l_in_status(x)
        ,l_in_frequency(x)
        ,l_in_fulfillment_channel(x)
        ,l_in_offset(x)
        ,l_in_object_version_number(x)
        ,l_in_created_by(x)
        ,l_in_creation_date(x)
        ,l_in_last_updated_by(x)
        ,l_in_last_update_date(x)
        ,l_in_last_update_login(x)
        ,l_in_UPG_ORIG_SYSTEM_REF(x)
        ,l_in_UPG_ORIG_SYSTEM_REF_ID(x)        );


    FOR lang_i IN OKC_UTIL.g_language_code.FIRST..OKC_UTIL.g_language_code.LAST LOOP
      FORALL x in 1..l_in_tabsize
        INSERT INTO OKS_SUBSCR_HEADER_TL(
          id,
          name,
          description,
          language,
          source_lang,
          sfwt_flag,
          comments,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login,
          SECURITY_GROUP_ID )
        VALUES (
          l_in_id(x)
          ,l_in_name(x)
          ,l_in_description(x)
          ,OKC_UTIL.g_language_code(lang_i)
          ,l_source_lang
          ,l_in_sfwt_flag(x)
          ,l_in_comments(x)
          ,l_in_created_by(x)
          ,l_in_creation_date(x)
          ,l_in_last_updated_by(x)
          ,l_in_last_update_date(x)
          ,l_in_last_update_login(x)
          ,null  );

    END LOOP;

    IF (l_debug = 'Y') THEN
      okc_debug.log('23500: Exiting INSERT_ROW_SUBHDR_UPG', 2);
      okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('23600: Exiting INSERT_ROW_SUBHDR_UPG:OTHERS Exception', 2);
        okc_debug.Reset_Indentation;
      END IF;

      OKC_API.SET_MESSAGE(
            p_app_name        => G_APP_NAME,
            p_msg_name        => G_UNEXPECTED_ERROR,
            p_token1          => G_SQLCODE_TOKEN,
            p_token1_value    => SQLCODE,
            p_token2          => G_SQLERRM_TOKEN,
            p_token2_value    => SQLERRM);

      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END INSERT_BY_TBL_SUBHDR;


--------------------------------------------------------------------------------
-----------      INSERT_ROW_UPG_SUBPTNS_TBL
--------------------------------------------------------------------------------

  PROCEDURE INSERT_BY_TBL_SUBPTNS(
               x_return_status OUT NOCOPY VARCHAR2
              ,P_SUBPTN_TBL  OKS_SUBSCR_PTRNS_PVT.scpv_tbl_type) IS

    l_in_id                             OKC_DATATYPES.NumberTabTyp;
    l_in_osh_id                         OKC_DATATYPES.NumberTabTyp;
    l_in_dnz_chr_id                     OKC_DATATYPES.NumberTabTyp;
    l_in_dnz_cle_id                     OKC_DATATYPES.NumberTabTyp;
    l_in_seq_no                         OKC_DATATYPES.NumberTabTyp;
    l_in_year                           OKC_DATATYPES.Var240TabTyp;
    l_in_month                          OKC_DATATYPES.Var240TabTyp;
    l_in_week                           OKC_DATATYPES.Var240TabTyp;
    l_in_week_day                       OKC_DATATYPES.Var240TabTyp;
    l_in_day                            OKC_DATATYPES.Var240TabTyp;
    l_in_object_version_number          OKC_DATATYPES.NumberTabTyp;
    l_in_created_by                     OKC_DATATYPES.NumberTabTyp;
    l_in_creation_date                  OKC_DATATYPES.DateTabTyp;
    l_in_last_updated_by                OKC_DATATYPES.NumberTabTyp;
    l_in_last_update_date               OKC_DATATYPES.DateTabTyp;
    l_in_last_update_login              OKC_DATATYPES.NumberTabTyp;

    l_in_tabsize                 NUMBER := P_SUBPTN_TBL.COUNT;
    tbl_idx                      NUMBER := P_SUBPTN_TBL.FIRST;
    j                            NUMBER := 0;



  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKS_SUBSCR_HDR_PVT');
       okc_debug.log('23400: Entered INSERT_BY_TBL_SUBPTNS', 2);
    END IF;

    WHILE tbl_idx IS NOT NULL LOOP
      j                               := j +1;
      l_in_id(j)                      := P_SUBPTN_TBL(tbl_idx).id;
      l_in_osh_id(j)                  := P_SUBPTN_TBL(tbl_idx).osh_id;
      l_in_dnz_cle_id(j)              := P_SUBPTN_TBL(tbl_idx).DNZ_cle_id;
      l_in_dnz_chr_id(j)              := P_SUBPTN_TBL(tbl_idx).DNZ_chr_id;
      l_in_seq_no(J)                  := P_SUBPTN_TBL(tbl_idx).seq_no;
      l_in_year(J)                    := P_SUBPTN_TBL(tbl_idx).year;
      l_in_month(J)                   := P_SUBPTN_TBL(tbl_idx).month;
      l_in_week(J)                    := P_SUBPTN_TBL(tbl_idx).week;
      l_in_week_day(J)                := P_SUBPTN_TBL(tbl_idx).week_day;
      l_in_day(J)                     := P_SUBPTN_TBL(tbl_idx).day;
      l_in_object_version_number(j)   := P_SUBPTN_TBL(tbl_idx).object_version_number;
      l_in_created_by(j)              := P_SUBPTN_TBL(tbl_idx).created_by;
      l_in_creation_date(j)           := P_SUBPTN_TBL(tbl_idx).creation_date;
      l_in_last_updated_by(j)         := P_SUBPTN_TBL(tbl_idx).last_updated_by;
      l_in_last_update_date(j)        := P_SUBPTN_TBL(tbl_idx).last_update_date;
      l_in_last_update_login(j)       := P_SUBPTN_TBL(tbl_idx).last_update_login;

      tbl_idx                         := P_SUBPTN_TBL.NEXT(tbl_idx);

    END LOOP;

    FORALL x in 1..l_in_tabsize

      INSERT INTO OKS_SUBSCR_PATTERNS(
        id,
        osh_id,
        dnz_chr_id,
        dnz_cle_id,
        seq_no,
        year,
        month,
        week,
        week_day,
        day,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_in_id(x)
       ,l_in_osh_id(x)
       ,l_in_dnz_chr_id(x)
       ,l_in_dnz_cle_id(x)
       ,l_in_seq_no(x)
       ,l_in_year(x)
       ,l_in_month(x)
       ,l_in_week(x)
       ,l_in_week_day(x)
       ,l_in_day(x)
       ,l_in_object_version_number(x)
       ,l_in_created_by(x)
       ,l_in_creation_date(x)
       ,l_in_last_updated_by(x)
       ,l_in_last_update_date(x)
       ,l_in_last_update_login(x)    );


    IF (l_debug = 'Y') THEN
      okc_debug.log('23500: Exiting INSERT_BY_TBL_SUBPTNS', 2);
      okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('23600: Exiting INSERT_BY_TBL_SUBPTNS:OTHERS Exception', 2);
        okc_debug.Reset_Indentation;
      END IF;

      OKC_API.SET_MESSAGE(
            p_app_name        => G_APP_NAME,
            p_msg_name        => G_UNEXPECTED_ERROR,
            p_token1          => G_SQLCODE_TOKEN,
            p_token1_value    => SQLCODE,
            p_token2          => G_SQLERRM_TOKEN,
            p_token2_value    => SQLERRM);

      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END INSERT_BY_TBL_SUBPTNS;
-----------------------------------------------------------------------------
--------- INSERT_BY_TBL_SUBPTNS
------------------------------------------------------------------------------



  -----------------------------------------------------------------------------
  -- INSERT_BY_TBL_SUBELMNTS for:OKS_SUBSCR_ELEMENTS
  -----------------------------------------------------------------------------

  PROCEDURE INSERT_BY_TBL_SUBELMNTS(
               x_return_status OUT NOCOPY VARCHAR2
              ,P_SUBELMNTS_TBL  OKS_SUBSCR_ELEMS_PVT.scev_tbl_type) IS


    l_in_tabsize                 NUMBER := P_SUBELMNTS_TBL.COUNT;
    tbl_idx                      NUMBER := P_SUBELMNTS_TBL.FIRST;
    j                            NUMBER := 0;

    l_in_id                             OKC_DATATYPES.NumberTabTyp;
    l_in_osh_id                         OKC_DATATYPES.NumberTabTyp;
    l_in_dnz_chr_id                     OKC_DATATYPES.NumberTabTyp;
    l_in_dnz_cle_id                     OKC_DATATYPES.NumberTabTyp;
    l_in_seq_no                         OKC_DATATYPES.NumberTabTyp;
    l_in_LINKED_FLAG                    OKC_DATATYPES.Var10TabTyp;
    l_in_OM_INTERFACE_DATE              OKC_DATATYPES.DateTabTyp;
    l_in_AMOUNT                         OKC_DATATYPES.NumberTabTyp;
    l_in_START_DATE                     OKC_DATATYPES.DateTabTyp;
    l_in_end_DATE                       OKC_DATATYPES.DateTabTyp;
    l_in_QUANTITY                       OKC_DATATYPES.NumberTabTyp;
    l_in_UOM_CODE                       OKC_DATATYPES.Var3TabTyp;
    l_in_ORDER_HEADER_ID                OKC_DATATYPES.NumberTabTyp;
    l_in_ORDER_LINE_ID                  OKC_DATATYPES.NumberTabTyp;
    l_in_object_version_number          OKC_DATATYPES.NumberTabTyp;
    l_in_created_by                     OKC_DATATYPES.NumberTabTyp;
    l_in_creation_date                  OKC_DATATYPES.DateTabTyp;
    l_in_last_updated_by                OKC_DATATYPES.NumberTabTyp;
    l_in_last_update_date               OKC_DATATYPES.DateTabTyp;
    l_in_last_update_login              OKC_DATATYPES.NumberTabTyp;

    l_in_SECURITY_GROUP_ID              OKC_DATATYPES.NumberTabTyp;



  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (l_debug = 'Y') THEN
      okc_debug.Set_Indentation('OKS_SUBSCR_ELEMS_PVT');
      okc_debug.log('23400: Entered INSERT_BY_TBL_SUBELMNTS', 2);
    END IF;

    WHILE tbl_idx IS NOT NULL LOOP
      j                               := j +1;

      l_in_id(j)                             :=  P_SUBELMNTS_TBL(tbl_idx).id;
      l_in_osh_id(j)                         :=  P_SUBELMNTS_TBL(tbl_idx).osh_id;
      l_in_dnz_chr_id(j)                     :=  P_SUBELMNTS_TBL(tbl_idx).dnz_chr_id;
      l_in_dnz_cle_id(j)                     :=  P_SUBELMNTS_TBL(tbl_idx).dnz_cle_id;
      l_in_seq_no(j)                         :=  P_SUBELMNTS_TBL(tbl_idx).seq_no;
      l_in_LINKED_FLAG(j)                    :=  P_SUBELMNTS_TBL(tbl_idx).LINKED_FLAG;
      l_in_OM_INTERFACE_DATE(j)              :=  P_SUBELMNTS_TBL(tbl_idx).OM_INTERFACE_DATE;
      l_in_AMOUNT(j)                         :=  P_SUBELMNTS_TBL(tbl_idx).AMOUNT;
      l_in_START_DATE(j)                     :=  P_SUBELMNTS_TBL(tbl_idx).START_DATE;
      l_in_end_DATE(j)                       :=  P_SUBELMNTS_TBL(tbl_idx).end_DATE;
      l_in_QUANTITY(j)                       :=  P_SUBELMNTS_TBL(tbl_idx).QUANTITY;
      l_in_UOM_CODE(j)                       :=  P_SUBELMNTS_TBL(tbl_idx).UOM_CODE;
      l_in_ORDER_HEADER_ID(j)                :=  P_SUBELMNTS_TBL(tbl_idx).ORDER_HEADER_ID;
      l_in_ORDER_LINE_ID(j)                  :=  P_SUBELMNTS_TBL(tbl_idx).ORDER_LINE_ID;
      l_in_object_version_number(j)          :=  P_SUBELMNTS_TBL(tbl_idx).object_version_number;
      l_in_created_by(j)                     :=  P_SUBELMNTS_TBL(tbl_idx).created_by;
      l_in_creation_date(j)                  :=  P_SUBELMNTS_TBL(tbl_idx).creation_date;
      l_in_last_updated_by(j)                :=  P_SUBELMNTS_TBL(tbl_idx).last_updated_by;
      l_in_last_update_date(j)               :=  P_SUBELMNTS_TBL(tbl_idx).last_update_date;
      l_in_last_update_login(j)              :=  P_SUBELMNTS_TBL(tbl_idx).last_update_login;

      tbl_idx                                := P_SUBELMNTS_TBL.NEXT(tbl_idx);

    END LOOP;

    FORALL x in 1..l_in_tabsize
      INSERT INTO OKS_SUBSCR_ELEMENTS(
        id,
        osh_id,
        dnz_chr_id,
        dnz_cle_id,
        linked_flag,
        seq_no,
        om_interface_date,
        amount,
        start_date,
        end_date,
        quantity,
        uom_code,
        order_header_id,
        order_line_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
    VALUES (
        l_in_id(x)
       ,l_in_osh_id(x)
       ,l_in_dnz_chr_id(x)
       ,l_in_dnz_cle_id(x)
       ,l_in_linked_flag(x)
       ,l_in_seq_no(x)
       ,l_in_om_interface_date(x)
       ,l_in_amount(x)
       ,l_in_start_date(x)
       ,l_in_end_date(x)
       ,l_in_quantity(x)
       ,l_in_uom_code(x)
       ,l_in_order_header_id(x)
       ,l_in_order_line_id(x)
       ,l_in_object_version_number(x)
       ,l_in_created_by(x)
       ,l_in_creation_date(x)
       ,l_in_last_updated_by(x)
       ,l_in_last_update_date(x)
       ,l_in_last_update_login(x));

    IF (l_debug = 'Y') THEN
      okc_debug.log('23500: Exiting INSERT_BY_TBL_SUBELMNTS', 2);
      okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('23600: Exiting INSERT_BY_TBL_SUBELMNTS:OTHERS Exception', 2);
        okc_debug.Reset_Indentation;
      END IF;

      OKC_API.SET_MESSAGE(
            p_app_name        => G_APP_NAME,
            p_msg_name        => G_UNEXPECTED_ERROR,
            p_token1          => G_SQLCODE_TOKEN,
            p_token1_value    => SQLCODE,
            p_token2          => G_SQLERRM_TOKEN,
            p_token2_value    => SQLERRM);

      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;


  END INSERT_BY_TBL_SUBELMNTS;

  -----------------------------------------------------------------------------
  -- END insert_row_upg  for:OKS_SUBSCR_ELEMENTS --
  -----------------------------------------------------------------------------






  -----------------------------------------------------------------------------
  -- End INSERT_SUB_TBLS
  -----------------------------------------------------------------------------











END OKS_Insert_Row_Upg;


/
