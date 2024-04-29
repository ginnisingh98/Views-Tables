--------------------------------------------------------
--  DDL for Package Body OKS_COVERAGE_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_COVERAGE_MIGRATION" AS
/* $Header: OKSCOVMB.pls 120.0 2005/05/25 18:25:54 appldev noship $ */

--PROCEDURE Coverage_migration( x_return_status OUT NOCOPY VARCHAR2) IS
PROCEDURE Coverage_migration(   p_start_rowid   IN ROWID,
                                p_end_rowid     IN ROWID,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_message_data  OUT NOCOPY VARCHAR2) IS


CURSOR Csr_Get_Coverage_Rules (l_start_rowid IN ROWID ,l_end_rowid IN ROWID )   IS

    SELECT
        LINE.ID LINE_ID,
        Line.Created_By Line_Created_By,
		Line.Creation_Date		Line_Creation_Date,
        Line.Last_Updated_By    Line_Last_Updated_By,
        Line.Last_Update_Date   Line_Last_Update_Date,
        Line.Last_Update_Login  Line_Last_Update_Login,
        RGP.ID LINE_RGP_ID,
        Rul.RowID  Rul_Row_ID       ,
        Rul.ID  Rule_ID,
        LINE.LSE_ID LINE_LSE_ID,
        LINE.DNZ_CHR_ID LINE_DNZ_CHR_ID,
        OBJECT1_ID1  LINE_OBJECT1_ID1,
        OBJECT2_ID1 LINE_OBJECT2_ID1,
        RULE_INFORMATION1  COV_RULE_INFO1,
        RULE_INFORMATION2  COV_RULE_INFO2,
        RULE_INFORMATION3  COV_RULE_INFO3,
        RULE_INFORMATION4  COV_RULE_INFO4,
        RULE_INFORMATION5  COV_RULE_INFO5,
        RULE_INFORMATION6  COV_RULE_INFO6,
        RULE_INFORMATION7  COV_RULE_INFO7,
        RULE_INFORMATION8  COV_RULE_INFO8,
        RULE_INFORMATION9  COV_RULE_INFO9,
        RULE_INFORMATION10 COV_RULE_INFO10,
        RULE_INFORMATION11 COV_RULE_INFO11,
        RULE_INFORMATION12 COV_RULE_INFO12,
        RULE_INFORMATION13 COV_RULE_INFO13,
        RULE_INFORMATION14 COV_RULE_INFO14,
        RULE_INFORMATION15 COV_RULE_INFO15,
        RULE_INFORMATION_CATEGORY  COV_RULE_INFO,
        RUL.OBJECT_VERSION_NUMBER  COV_OBJ_VER_NUMBER
    FROM
       OKC_RULE_GROUPS_B RGP,
       OKC_RULES_B RUL,
       OKC_K_LINES_B LINE
  WHERE  LINE.ID = RGP.CLE_ID
  AND    RGP.ID  = RUL.RGP_ID
  AND    LINE.LSE_ID IN (2,15,20)
 -- AND    RUL.RULE_INFORMATION_CATEGORY IN ('ECE','WHE','UGE','STR','CVE','PMP')
  AND    LINE.DNZ_CHR_ID = RGP.DNZ_CHR_ID
--  AND    RUL.RULE_INFORMATION15 IS NULL
  AND    NOT EXISTS (SELECT CLE_ID FROM OKS_K_LINES_B WHERE CLE_ID = LINE.ID)
  AND    Rul.rowid BETWEEN l_start_rowid and l_end_rowid
  ORDER BY LINE.ID;

G_Exception_Halt                Exception;

TYPE RowId_Tbl_Type  IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
TYPE Num_Tbl_Type  IS VARRAY(1000) OF NUMBER;
TYPE Date_Tbl_Type IS VARRAY(1000) OF DATE;
TYPE Vc15_Tbl_Type IS VARRAY(1000) OF VARCHAR2(15);
TYPE Vc20_Tbl_Type IS VARRAY(1000) OF VARCHAR2(20);
TYPE Vc150_Tbl_Type IS VARRAY(1000) OF VARCHAR2(150);
TYPE Vc30_Tbl_Type IS VARRAY(1000) OF VARCHAR2(30);
TYPE Vc1_Tbl_Type IS VARRAY(1000) OF VARCHAR2(1);
TYPE Vc3_Tbl_Type IS VARRAY(1000) OF VARCHAR2(3);
TYPE Vc2000_Tbl_Type IS VARRAY(1000) OF VARCHAR2(2000);
TYPE Vc50_Tbl_Type IS VARRAY(1000) OF VARCHAR2(50);
TYPE Vc80_Tbl_Type IS VARRAY(1000) OF VARCHAR2(80);
TYPE Vc120_Tbl_Type IS VARRAY(1000) OF VARCHAR2(120);
TYPE Vc600_Tbl_Type IS VARRAY(1000) OF VARCHAR2(600);

Rul_Row_ID_TBl              RowId_Tbl_Type;
LINE_ID_TBL                 Num_Tbl_Type;
Line_Created_By_TBL         Num_Tbl_Type;
Line_Creation_Date_TBL		Date_Tbl_Type;
Line_Last_Updated_By_TBL    Num_Tbl_Type;
Line_Last_Update_Date_TBL   Date_Tbl_Type;
Line_Last_Update_Login_TBL  Num_Tbl_Type;
LINE_RGP_ID_TBL             Num_Tbl_Type;
Rule_ID_TBL                 Num_Tbl_Type;
LINE_LSE_ID_TBL             Num_Tbl_Type;
LINE_DNZ_CHR_ID_TBL         Num_Tbl_Type;
LINE_OBJECT1_ID1_TBL        Vc150_Tbl_Type;
LINE_OBJECT2_ID1_TBL        Vc150_Tbl_Type;
COV_RULE_INFO1_TBL         Vc150_Tbl_Type;
COV_RULE_INFO2_TBL         Vc150_Tbl_Type;
COV_RULE_INFO3_TBL         Vc150_Tbl_Type;
COV_RULE_INFO4_TBL         Vc150_Tbl_Type;
COV_RULE_INFO5_TBL         Vc150_Tbl_Type;
COV_RULE_INFO6_TBL         Vc150_Tbl_Type;
COV_RULE_INFO7_TBL         Vc150_Tbl_Type;
COV_RULE_INFO8_TBL         Vc150_Tbl_Type;
COV_RULE_INFO9_TBL         Vc150_Tbl_Type;
COV_RULE_INFO10_TBL         Vc150_Tbl_Type;
COV_RULE_INFO11_TBL         Vc150_Tbl_Type;
COV_RULE_INFO12_TBL         Vc150_Tbl_Type;
COV_RULE_INFO13_TBL         Vc150_Tbl_Type;
COV_RULE_INFO14_TBL         Vc150_Tbl_Type;
COV_RULE_INFO15_TBL         Vc150_Tbl_Type;
COV_RULE_INFO_TBL           Vc150_Tbl_Type;
COV_OBJ_VER_NUMBER_TBL         Num_Tbl_Type;

x_clev_tbl_in             	oks_kln_pvt.klnv_tbl_type;
l_clev_tbl_in             	oks_kln_pvt.klnv_tbl_type;
l_cle_ctr                   NUMBER := 0;
tablename1                  VArchar2(1000);
x_msg_count                 NUMBER := 0;
x_msg_data                 VArchar2(1000);
L_OLD_CLE_ID                NUMBER  := -99999;
L_CLE_ID                    NUMBER  := -99999;
l_duration                  NUMBER;
l_period                    VArchar2(10);
l_return_status             VArchar2(1) := OKC_API.G_RET_STS_SUCCESS;
l_transfer_option           VArchar2(250);


l_start_rowid       ROWID := p_start_rowid;
l_end_rowid         ROWID := p_end_rowid;
l_msg_data          VARCHAR2(1000);
l_msg_index_out     NUMBER;
l_message           VARCHAR2(2400);

PROCEDURE   get_duration_period(p_id IN NUMBER,
                                x_duration  OUT NOCOPY NUMBER,
                                x_period    OUT NOCOPY VARCHAR2) IS

CURSOR Csr_get_duration (l_ID IN NUMBER) IS
SELECT UOM_CODE,Duration
FROM   OKC_TIMEVALUES_V
WHERE  id  = l_id;

Lx_Duration NUMBER := NULL;
Lx_Period   VARCHAR2(100) := NULL;

BEGIN

FOR Csr_get_duration_Rec in Csr_get_duration(p_id) LOOP

Lx_period := Csr_get_duration_Rec.uom_code;
Lx_duration   := Csr_get_duration_Rec.Duration;

END LOOP;

X_duration := Lx_duration;
X_Period :=Lx_Period;

EXCEPTION
WHEN OTHERS THEN
   OKC_API.SET_MESSAGE
    (P_App_Name	  => G_APP_NAME_OKS
	,P_Msg_Name	  => G_UNEXPECTED_ERROR
	,P_Token1	  => G_SQLCODE_TOKEN
	,P_Token1_Value	  => SQLCODE
	,P_Token2	  => G_SQLERRM_TOKEN
	,P_Token2_Value   => SQLERRM);
END;


BEGIN
-- -- dbms_output.put_line('IN Begin');

G_APP_NAME := 'Coverage_migration';
OPEN Csr_Get_Coverage_Rules (l_start_rowid,l_end_rowid);
LOOP
    BEGIN
    l_clev_tbl_in.DELETE;

    FETCH Csr_Get_Coverage_Rules BULK COLLECT INTO
            LINE_ID_TBL                 ,
            Line_Created_By_TBL         ,
			Line_Creation_Date_TBL		,
            Line_Last_Updated_By_TBL    ,
            Line_Last_Update_Date_TBL   ,
            Line_Last_Update_Login_TBL  ,
            LINE_RGP_ID_TBL             ,
            Rul_Row_ID_TBl              ,
            Rule_Id_Tbl                 ,
            LINE_LSE_ID_TBL             ,
            LINE_DNZ_CHR_ID_TBL         ,
            LINE_OBJECT1_ID1_TBL        ,
            LINE_OBJECT2_ID1_TBL        ,
            COV_RULE_INFO1_TBL         ,
            COV_RULE_INFO2_TBL         ,
            COV_RULE_INFO3_TBL         ,
            COV_RULE_INFO4_TBL         ,
            COV_RULE_INFO5_TBL         ,
            COV_RULE_INFO6_TBL         ,
            COV_RULE_INFO7_TBL         ,
            COV_RULE_INFO8_TBL         ,
            COV_RULE_INFO9_TBL         ,
            COV_RULE_INFO10_TBL         ,
            COV_RULE_INFO11_TBL         ,
            COV_RULE_INFO12_TBL         ,
            COV_RULE_INFO13_TBL         ,
            COV_RULE_INFO14_TBL         ,
            COV_RULE_INFO15_TBL         ,
            COV_RULE_INFO_TBL           ,
            COV_OBJ_VER_NUMBER_TBL
            LIMIT 1000;--20;


        IF LINE_ID_TBL.COUNT > 0 THEN

--        remove dbms

            FOR I IN LINE_ID_TBL.FIRST .. LINE_ID_TBL.LAST LOOP
            L_Cle_id := LINE_ID_TBL(i);

            IF (L_OLD_CLE_ID <> L_CLE_ID) THEN
                l_cle_ctr := l_cle_ctr + 1;

--            l_clev_tbl_in(l_cle_ctr).Id := okc_p_util.raw_to_number(sys_guid());
            l_clev_tbl_in(l_cle_ctr).Created_By   := Line_Created_By_TBL(i);
            l_clev_tbl_in(l_cle_ctr).Creation_Date   := Line_Creation_Date_TBL(i);
            l_clev_tbl_in(l_cle_ctr).Last_Updated_By   := Line_Last_Updated_By_TBL(i);
            l_clev_tbl_in(l_cle_ctr).Last_Update_Date   := Line_Last_Update_Date_TBL(i);
            l_clev_tbl_in(l_cle_ctr).Last_Update_Login  := Line_Last_Update_Login_TBL(i);
            l_clev_tbl_in(l_cle_ctr).Cle_Id         :=  LINE_ID_TBL(i);
            l_clev_tbl_in(l_cle_ctr).Dnz_Chr_Id         :=  LINE_DNZ_CHR_ID_TBL(i);
            l_clev_tbl_in(l_cle_ctr).object_version_number :=  1;
            l_clev_tbl_in(l_cle_ctr).Sync_Date_Install :=  'N';

            END IF;

            IF   COV_RULE_INFO_TBL(i) = 'CVE' THEN
                l_clev_tbl_in(l_cle_ctr).Coverage_Type := COV_RULE_INFO1_TBL(i);--'G';
            END IF;

            IF   COV_RULE_INFO_TBL(i) = 'STR' THEN
                IF COV_RULE_INFO1_TBL(i) = 'Y' THEN
                    l_clev_tbl_in(l_cle_ctr).TRANSFER_OPTION  := 'TRANS';
                ELSE
                    l_clev_tbl_in(l_cle_ctr).TRANSFER_OPTION  :=  'TERMINATE';
                END IF;

            END IF;


            IF   COV_RULE_INFO_TBL(i) = 'UGE' THEN
                l_clev_tbl_in(l_cle_ctr).Prod_Upgrade_YN := COV_RULE_INFO1_TBL(i);--'N';
            END IF;


            IF COV_RULE_INFO_TBL(i) = 'ECE' THEN
                l_clev_tbl_in(l_cle_ctr).EXCEPTION_COV_ID   :=  COV_RULE_INFO1_TBL(i);
            END IF;

            IF COV_RULE_INFO_TBL(i) = 'WHE' THEN
                l_clev_tbl_in(l_cle_ctr).Prod_Upgrade_YN := COV_RULE_INFO1_TBL(i);
            END IF;

            IF COV_RULE_INFO_TBL(i) = 'PMP' THEN

                l_clev_tbl_in(l_cle_ctr).PM_PROGRAM_ID      := LINE_OBJECT1_ID1_TBL(i);
                l_clev_tbl_in(l_cle_ctr).PM_CONF_REQ_YN     := COV_RULE_INFO1_TBL(i);
                l_clev_tbl_in(l_cle_ctr).PM_SCH_EXISTS_YN   := COV_RULE_INFO2_TBL(i);

            END IF;



            L_OLD_CLE_ID := L_CLE_ID;
            END LOOP;
        END IF;

         tablename1 := 'OKS_K_LINES';

         IF l_clev_tbl_in.count > 0 THEN
            oks_kln_pvt.insert_row
            (
                x_return_status     => l_return_status,
                p_klnv_tbl          => l_clev_tbl_in,
                p_api_version       => 1,
                p_init_msg_list     => null,--   Could Not Found use standard
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data,
                x_klnv_tbl          => x_clev_tbl_in
            );

            IF x_msg_count > 0  THEN
              FOR i in 1..x_msg_count   LOOP
                 apps.fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => x_msg_data,
                                  p_msg_index_out => l_msg_index_out);
--               l_message := l_message||' ; '||x_msg_data;

              END LOOP;
             END IF;
        END IF;

                        x_return_status := 'S';
                        X_Message_Data  := NULL;
EXCEPTION
    WHEN G_EXCEPTION_HALT THEN

    ROLLBACK;

    x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );

         IF x_msg_count > 0              THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
        END IF;
                x_message_data  := l_message;
                x_return_status := 'E';
    WHEN Others THEN


    x_return_status := OKC_API.G_RET_STS_ERROR;

    x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                    );

         IF x_msg_count > 0              THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
        END IF;
                x_message_data  := l_message;
                x_return_status := 'E';

    END;

EXIT WHEN Csr_Get_Coverage_Rules%NOTFOUND;

END LOOP;

CLOSE Csr_Get_Coverage_Rules;


EXCEPTION
    WHEN Others THEN

    x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                    );

         IF x_msg_count > 0              THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
        END IF;
                x_message_data  := l_message;
                x_return_status := 'E';

END Coverage_migration;


--PROCEDURE Business_Process_migration( x_return_status OUT NOCOPY VARCHAR2) IS
PROCEDURE Business_Process_migration(p_start_rowid IN ROWID,p_end_rowid IN ROWID,x_return_status OUT NOCOPY VARCHAR2,x_message_data  OUT NOCOPY VARCHAR2) IS

CURSOR Csr_Get_Buss_Process (l_start_rowid IN ROWID ,l_end_rowid IN ROWID ) IS
    SELECT
        LINE.ID LINE_ID,
        Line.Created_By Line_Created_By,
		Line.Creation_Date		Line_Creation_Date,
        Line.Last_Updated_By    Line_Last_Updated_By,
        Line.Last_Update_Date   Line_Last_Update_Date,
        Line.Last_Update_Login  Line_Last_Update_Login,
        Rul.ID  Rule_Id,
        RGP.ID LINE_RGP_ID,
        Rul.RowId   Rul_Row_Id,
        LINE.LSE_ID LINE_LSE_ID,
        LINE.DNZ_CHR_ID LINE_DNZ_CHR_ID,
        OBJECT1_ID1  LINE_OBJECT1_ID1,
        OBJECT2_ID1 LINE_OBJECT2_ID1,
        RULE_INFORMATION1  COV_RULE_INFO1,
        RULE_INFORMATION2  COV_RULE_INFO2,
        RULE_INFORMATION3  COV_RULE_INFO3,
        RULE_INFORMATION4  COV_RULE_INFO4,
        RULE_INFORMATION5  COV_RULE_INFO5,
        RULE_INFORMATION6  COV_RULE_INFO6,
        RULE_INFORMATION7  COV_RULE_INFO7,
        RULE_INFORMATION8  COV_RULE_INFO8,
        RULE_INFORMATION9  COV_RULE_INFO9,
        RULE_INFORMATION10 COV_RULE_INFO10,
        RULE_INFORMATION11 COV_RULE_INFO11,
        RULE_INFORMATION12 COV_RULE_INFO12,
        RULE_INFORMATION13 COV_RULE_INFO13,
        RULE_INFORMATION14 COV_RULE_INFO14,
        RULE_INFORMATION15 COV_RULE_INFO15,
        RULE_INFORMATION_CATEGORY  COV_RULE_INFO,
        RUL.OBJECT_VERSION_NUMBER  COV_OBJ_VER_NUMBER
    FROM
       OKC_RULE_GROUPS_B RGP,
       OKC_RULES_B RUL,
       OKC_K_LINES_B LINE
  WHERE  LINE.ID = RGP.CLE_ID
  AND    RGP.ID  = RUL.RGP_ID
  AND    LINE.LSE_ID in (3,16,21)
  AND    RUL.RULE_INFORMATION_CATEGORY IN ('OFS','CVR','DST','PRE','BTD')
  AND    LINE.DNZ_CHR_ID = RGP.DNZ_CHR_ID
--  AND    RUL.RULE_INFORMATION15  IS NULL
  AND    Rul.rowid BETWEEN l_start_rowid and l_end_rowid
  AND    NOT EXISTS  (SELECT CLE_ID FROM OKS_K_Lines_B where cle_id = LINE.ID)
  ORDER BY LINE.ID;



TYPE RowId_Tbl_Type  IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
TYPE Num_Tbl_Type  IS VARRAY(1000) OF NUMBER;
TYPE Date_Tbl_Type IS VARRAY(1000) OF DATE;
TYPE Vc15_Tbl_Type IS VARRAY(1000) OF VARCHAR2(15);
TYPE Vc20_Tbl_Type IS VARRAY(1000) OF VARCHAR2(20);
TYPE Vc150_Tbl_Type IS VARRAY(1000) OF VARCHAR2(150);
TYPE Vc30_Tbl_Type IS VARRAY(1000) OF VARCHAR2(30);
TYPE Vc1_Tbl_Type IS VARRAY(1000) OF VARCHAR2(1);
TYPE Vc3_Tbl_Type IS VARRAY(1000) OF VARCHAR2(3);
TYPE Vc2000_Tbl_Type IS VARRAY(1000) OF VARCHAR2(2000);
TYPE Vc50_Tbl_Type IS VARRAY(1000) OF VARCHAR2(50);
TYPE Vc80_Tbl_Type IS VARRAY(1000) OF VARCHAR2(80);
TYPE Vc120_Tbl_Type IS VARRAY(1000) OF VARCHAR2(120);
TYPE Vc600_Tbl_Type IS VARRAY(1000) OF VARCHAR2(600);


Rul_Row_ID_TBl              RowId_Tbl_Type;
LINE_ID_TBL                 Num_Tbl_Type;
Line_Created_By_TBL         Num_Tbl_Type;
Line_Creation_Date_TBl		Date_Tbl_Type;
Line_Last_Updated_By_TBL    Num_Tbl_Type;
Line_Last_Update_Date_TBL   Date_Tbl_Type;
Line_Last_Update_Login_TBL  Num_Tbl_Type;
RUL_ID_TBL                 Num_Tbl_Type;
LINE_RGP_ID_TBL             Num_Tbl_Type;
LINE_LSE_ID_TBL             Num_Tbl_Type;
LINE_DNZ_CHR_ID_TBL         Num_Tbl_Type;
LINE_OBJECT1_ID1_TBL        Vc150_Tbl_Type;
LINE_OBJECT2_ID1_TBL        Vc150_Tbl_Type;
COV_RULE_INFO1_TBL         Vc150_Tbl_Type;
COV_RULE_INFO2_TBL         Vc150_Tbl_Type;
COV_RULE_INFO3_TBL         Vc150_Tbl_Type;
COV_RULE_INFO4_TBL         Vc150_Tbl_Type;
COV_RULE_INFO5_TBL         Vc150_Tbl_Type;
COV_RULE_INFO6_TBL         Vc150_Tbl_Type;
COV_RULE_INFO7_TBL         Vc150_Tbl_Type;
COV_RULE_INFO8_TBL         Vc150_Tbl_Type;
COV_RULE_INFO9_TBL         Vc150_Tbl_Type;
COV_RULE_INFO10_TBL         Vc150_Tbl_Type;
COV_RULE_INFO11_TBL         Vc150_Tbl_Type;
COV_RULE_INFO12_TBL         Vc150_Tbl_Type;
COV_RULE_INFO13_TBL         Vc150_Tbl_Type;
COV_RULE_INFO14_TBL         Vc150_Tbl_Type;
COV_RULE_INFO15_TBL         Vc150_Tbl_Type;
COV_RULE_INFO_TBL           Vc150_Tbl_Type;
COV_OBJ_VER_NUMBER_TBL         Num_Tbl_Type;

x_clev_tbl_in             	oks_kln_pvt.klnv_tbl_type;
l_clev_tbl_in             	oks_kln_pvt.klnv_tbl_type;
l_cle_ctr                   NUMBER := 0;
tablename1                  VArchar2(1000);
x_msg_count                 NUMBER := 0;
x_msg_data                 VArchar2(1000);
L_OLD_CLE_ID                NUMBER  := -99999;
L_CLE_ID                    NUMBER  := -99999;
l_duration                  NUMBER;
l_period                    VArchar2(10);
l_return_Status             VArchar2(3):= OKC_API.G_RET_STS_SUCCESS;
l_OU_CURRENCY               VArchar2(10);


l_start_rowid       ROWID := p_start_rowid;
l_end_rowid         ROWID := p_end_rowid;
l_msg_data          VARCHAR2(1000);
l_msg_index_out     NUMBER;
l_message           VARCHAR2(2400);


EXCEPTIONHALT_VALIDATION    EXCEPTION;
G_EXCEPTION_HALT            EXCEPTION;

PROCEDURE   get_duration_period(p_id IN NUMBER,
                                x_duration  OUT NOCOPY NUMBER,
                                x_period    OUT NOCOPY VARCHAR2) IS

CURSOR Csr_get_duration (l_ID IN NUMBER) IS
SELECT UOM_CODE,Duration
FROM   OKC_TIMEVALUES_V
WHERE  id  = l_id;

Lx_Duration NUMBER := NULL;
Lx_Period   VARCHAR2(100) := NULL;
G_APP_NAME  VARCHAR2(100) := NULL;

BEGIN
G_APP_NAME  := 'get_duration_period';

FOR Csr_get_duration_Rec in Csr_get_duration(p_id) LOOP

Lx_period := Csr_get_duration_Rec.uom_code;
Lx_duration   := Csr_get_duration_Rec.Duration;

END LOOP;

X_duration := Lx_duration;
X_Period :=Lx_Period;

EXCEPTION
WHEN OTHERS THEN
    x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );


END get_duration_period;

PROCEDURE   Create_Coverage_Time(   P_Rule_Id       IN NUMBER,
                                        P_Cle_Id        IN NUMBER,
                                        P_Dnz_Chr_ID    IN NUMBER,
                                        X_return_Status OUT NOCOPY VARCHAR2)IS

    l_rule_ID   NUMBER  := P_rule_Id;
    l_cle_Id    NUMBER  := P_Cle_id;
    l_dnz_Id    NUMBER  :=P_Dnz_Chr_ID;

    l_COV_TZE_LINE_ID   NUMBER := null;

    l_count     NUMBER := 0;
    G_APP_NAME  VARCHAR2(100) := NULL;
   G_EXCEPTIONHALT_VALIDATION EXCEPTION;

    CURSOR Csr_get_time_zone_ID (rule_id IN NUMBER) IS
    SELECT  Times.tze_id tze_id,
            Times.Created_By Times_Created_By,
            Times.Last_Updated_By    Times_Last_Updated_By,
            Times.Last_Update_Date   Times_Last_Update_Date,
            Times.Last_Update_Login  Times_Last_Update_Login
    FROM    okc_timevalues_v times,
            okc_cover_times cvt
    WHERE   CVT.tve_ID = TIMES.id
    AND     CVT.rul_id = rule_id
    AND     rownum = 1;

    CURSOR Csr_get_count_time_zone_ID(k_cle_Id IN NUMBER,k_dnz_Id IN NUMBER) IS
    SELECT  COUNT(*) NCOUNT
    FROM    OKS_COVERAGE_TIMEZONES
    WHERE   cle_id      = k_cle_Id
    AND     dnz_chr_Id  = k_dnz_Id;

    BEGIN
    G_APP_NAME  := 'Create_Coverage_Time';

        FOR get_count_time_zone_ID_Rec IN Csr_get_count_time_zone_ID(l_cle_Id, l_dnz_Id) LOOP
          l_count   :=  get_count_time_zone_ID_Rec.NCOUNT;
        END LOOP;

        IF l_count =0 THEN

        l_COV_TZE_LINE_ID := null;
        l_ctz_rec := l_ctz_rec + 1;

        FOR get_time_zone_ID_Rec IN Csr_get_time_zone_ID(l_rule_ID) LOOP


            l_ctzv_tbl_in(l_ctz_rec).Id                 := okc_p_util.raw_to_number(sys_guid());


            l_ctzv_tbl_in(l_ctz_rec).Created_By         := get_time_zone_ID_Rec.Times_Created_By;
            l_ctzv_tbl_in(l_ctz_rec).Last_Updated_By    := get_time_zone_ID_Rec.Times_Last_Updated_By;
            l_ctzv_tbl_in(l_ctz_rec).Last_Update_Date   := get_time_zone_ID_Rec.Times_Last_Update_Date;
            l_ctzv_tbl_in(l_ctz_rec).Last_Update_Login  := get_time_zone_ID_Rec.Times_Last_Update_Login;
            l_ctzv_tbl_in(l_ctz_rec).Cle_Id             :=  l_Cle_Id;
            l_ctzv_tbl_in(l_ctz_rec).Dnz_Chr_Id         :=  l_dnz_Id;
            l_ctzv_tbl_in(l_ctz_rec).DEFAULT_YN         :=  'Y';
            l_ctzv_tbl_in(l_ctz_rec).TIMEZONE_ID        :=  get_time_zone_ID_Rec.tze_id;
            l_ctzv_tbl_in(l_ctz_rec).object_version_number :=  1;


        END LOOP;
		END IF;

        X_return_Status := 'S';
        X_Message_Data  := NULL;

    EXCEPTION
        WHEN OTHERS THEN

    x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );
         IF x_msg_count > 0              THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
        END IF;
                x_message_data  := l_message;
                X_return_Status := 'E';

    END Create_Coverage_Time;


BEGIN

G_APP_NAME := 'Business_Process_migration';
l_OU_CURRENCY   := OKC_CURRENCY_API.GET_OU_CURRENCY;

OPEN Csr_Get_Buss_Process (l_start_rowid,l_end_rowid);
LOOP
    BEGIN
    FETCH Csr_Get_Buss_Process BULK COLLECT INTO
            LINE_ID_TBL                 ,
            Line_Created_By_TBL         ,
			Line_Creation_Date_TBL		,
            Line_Last_Updated_By_TBL    ,
            Line_Last_Update_Date_TBL   ,
            Line_Last_Update_Login_TBL  ,
            RUL_ID_TBL                  ,
            LINE_RGP_ID_TBL             ,
            Rul_Row_ID_TBl              ,
            LINE_LSE_ID_TBL             ,
            LINE_DNZ_CHR_ID_TBL         ,
            LINE_OBJECT1_ID1_TBL        ,
            LINE_OBJECT2_ID1_TBL        ,
            COV_RULE_INFO1_TBL         ,
            COV_RULE_INFO2_TBL         ,
            COV_RULE_INFO3_TBL         ,
            COV_RULE_INFO4_TBL         ,
            COV_RULE_INFO5_TBL         ,
            COV_RULE_INFO6_TBL         ,
            COV_RULE_INFO7_TBL         ,
            COV_RULE_INFO8_TBL         ,
            COV_RULE_INFO9_TBL         ,
            COV_RULE_INFO10_TBL         ,
            COV_RULE_INFO11_TBL         ,
            COV_RULE_INFO12_TBL         ,
            COV_RULE_INFO13_TBL         ,
            COV_RULE_INFO14_TBL         ,
            COV_RULE_INFO15_TBL         ,
            COV_RULE_INFO_TBL           ,
            COV_OBJ_VER_NUMBER_TBL
            LIMIT 1000;

--  -- dbms_output.put_line('Value of LINE_ID_TBL.COUNT='||TO_CHAR(LINE_ID_TBL.COUNT));

        IF LINE_ID_TBL.COUNT > 0 THEN

            FOR I IN LINE_ID_TBL.FIRST .. LINE_ID_TBL.LAST LOOP
            L_Cle_id := LINE_ID_TBL(i);

            IF (L_OLD_CLE_ID <> L_CLE_ID) THEN
                l_cle_ctr := l_cle_ctr + 1;


--            l_clev_tbl_in(l_cle_ctr).Id := okc_p_util.raw_to_number(sys_guid());
            l_clev_tbl_in(l_cle_ctr).Created_By   := Line_Created_By_TBL(i);
            l_clev_tbl_in(l_cle_ctr).Creation_Date   := Line_Creation_Date_Tbl(i);
            l_clev_tbl_in(l_cle_ctr).Last_Updated_By   := Line_Last_Updated_By_TBL(i);
            l_clev_tbl_in(l_cle_ctr).Last_Update_Date   := Line_Last_Update_Date_TBL(i);
            l_clev_tbl_in(l_cle_ctr).Last_Update_Login  := Line_Last_Update_Login_TBL(i);
            l_clev_tbl_in(l_cle_ctr).Cle_Id         :=  LINE_ID_TBL(i);
            l_clev_tbl_in(l_cle_ctr).Dnz_Chr_Id         :=  LINE_DNZ_CHR_ID_TBL(i);
            l_clev_tbl_in(l_cle_ctr).object_version_number :=  1;
            l_clev_tbl_in(l_cle_ctr).Sync_Date_Install :=  'N';

            END IF;


            IF   COV_RULE_INFO_TBL(i) = 'OFS' THEN
                IF COV_RULE_INFO1_TBL(i) IS NOT NULL THEN

                    get_duration_period(p_id => COV_RULE_INFO1_TBL(i),
                                        x_duration  => l_duration,
                                        x_period    => l_period);

                END IF;

                l_clev_tbl_in(l_cle_ctr).OFFSET_DURATION := l_duration;
                l_clev_tbl_in(l_cle_ctr).OFFSET_PERIOD :=   l_period;

            END IF;



            IF   COV_RULE_INFO_TBL(i) = 'DST' THEN
                l_clev_tbl_in(l_cle_ctr).DISCOUNT_LIST := LINE_OBJECT1_ID1_TBL(i);
            END IF;


            IF   COV_RULE_INFO_TBL(i) = 'PRE' THEN

                UPDATE OKC_K_LINES_B
                SET PRICE_LIST_ID = LINE_OBJECT1_ID1_TBL(i),
                    CURRENCY_CODE = l_OU_CURRENCY
                WHERE ID = LINE_ID_TBL(i);

            END IF;


            IF COV_RULE_INFO_TBL(i) = 'BTD' THEN

    	        l_clev_tbl_in(l_cle_ctr).ALLOW_BT_DISCOUNT := 'Y';
            END IF;


            IF COV_RULE_INFO_TBL(i) = 'CVR' THEN

            Create_Coverage_Time(   P_Rule_Id       =>  RUL_ID_TBL(i),
                                    P_Cle_Id        =>  LINE_ID_TBL(i),
                                    P_Dnz_Chr_ID    =>  LINE_DNZ_CHR_ID_TBL(i),
                                    X_return_Status =>  l_return_Status);

            IF  l_return_Status <> 'S' THEN
                RAISE EXCEPTIONHALT_VALIDATION;
            END IF;

            END IF;
            --************************************************

            L_OLD_CLE_ID := L_CLE_ID;

            --*************************************************

            END LOOP;
        END IF;


 tablename1 := 'OKS_K_LINES';

 IF l_clev_tbl_in.count > 0 THEN
    oks_kln_pvt.insert_row
    (
            x_return_status     => l_return_status,
            p_klnv_tbl          => l_clev_tbl_in,
            p_api_version       =>1,
            p_init_msg_list     => null,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            x_klnv_tbl          => x_clev_tbl_in
    );

END IF;
 -- -- dbms_output.put_line('oks_kln_pvt Value of l_return_status='||l_return_status);


            IF x_msg_count > 0  THEN
              FOR i in 1..x_msg_count   LOOP
                 apps.fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => x_msg_data,
                                  p_msg_index_out => l_msg_index_out);
               l_message := l_message||' ; '||x_msg_data;
                --  -- dbms_output.put_line(x_msg_data);
              END LOOP;
              END IF;

-- -- dbms_output.put_line('Value of l_ctzv_tbl_in.COUNT='||TO_CHAR(l_ctzv_tbl_in.COUNT));

IF l_return_status = 'S' THEN
l_message := NULL;

    IF l_ctzv_tbl_in.COUNT > 0 THEN
    OKS_CTZ_PVT.insert_row
        (
            x_return_status                         => l_return_status,
            p_oks_coverage_timezones_v_tbl          => l_ctzv_tbl_in,
            p_api_version                           =>1,
            p_init_msg_list                         => null, --standard
            x_msg_count                             => x_msg_count,
            x_msg_data                              => x_msg_data,
            x_oks_coverage_timezones_v_tbl          => x_ctzv_tbl_in
        );
    END IF;
 -- -- dbms_output.put_line('OKS_CTZ_PVT Value of l_return_status='||l_return_status);

            IF x_msg_count > 0  THEN
              FOR i in 1..x_msg_count   LOOP
                 apps.fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => x_msg_data,
                                  p_msg_index_out => l_msg_index_out);
--               l_message := l_message||' ; '||x_msg_data;
                --  -- dbms_output.put_line(x_msg_data);
              END LOOP;
              END IF;


END IF;

l_ctzv_tbl_in.delete;
l_clev_tbl_in.delete;

    IF l_return_status = 'S' THEN
              x_return_status := 'S';
              x_message_data  := NULL;
    ELSE
                RAISE G_EXCEPTION_HALT;
    END IF;



EXCEPTION


    WHEN EXCEPTIONHALT_VALIDATION THEN
    --  -- dbms_output.put_line('SQLERRM ---->'||SQLERRM);
        ROLLBACK;
        l_ctzv_tbl_in.delete;
        l_clev_tbl_in.delete;
        l_cvtv_tbl_in.delete;

        x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );

         IF x_msg_count > 0              THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
        END IF;

                x_message_data  := l_message;
                x_return_status := 'E';
     WHEN G_EXCEPTION_HALT THEN
    --  -- dbms_output.put_line('222 --->SQLERRM ---->'||SQLERRM);
        ROLLBACK;
        l_ctzv_tbl_in.delete;
        l_clev_tbl_in.delete;
        l_cvtv_tbl_in.delete;


    x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );

    IF x_msg_count > 0  THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
    END IF;
                x_message_data  := l_message;
                x_return_status := 'E';

    WHEN Others THEN

        ROLLBACK;
        l_ctzv_tbl_in.delete;
        l_clev_tbl_in.delete;
        l_cvtv_tbl_in.delete;


        x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );
         IF x_msg_count > 0              THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
    END IF;
                x_message_data  := l_message;
                x_return_status := 'E';
    END;

EXIT WHEN Csr_Get_Buss_Process%NOTFOUND;

END LOOP;

CLOSE Csr_Get_Buss_Process;

EXCEPTION
    WHEN Others THEN

        x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );

         IF x_msg_count > 0              THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
        END IF;
                x_message_data  := l_message;
                x_return_status := 'E';
END Business_Process_migration;

--PROCEDURE COVERAGE_TIMES_MIGRATION ( x_return_status OUT NOCOPY VARCHAR2) IS
PROCEDURE COVERAGE_TIMES_MIGRATION (    p_start_rowid IN ROWID,
                                        p_end_rowid IN ROWID,
                                        x_return_status OUT NOCOPY VARCHAR2,
                                        x_message_data  OUT NOCOPY VARCHAR2) IS

CURSOR Csr_Get_Coverage_times (l_start_rowid IN ROWID ,l_end_rowid IN ROWID ) IS
SELECT  CTZ.ID                  TimeZone_ID,
        CTZ.DNZ_CHR_ID          DNZ_CHR_ID,
        TIMES.ROWID             TIMES_ROW_ID,
        TIMES.TVE_ID_STARTED    TVE_ID_STARTED,
        TIMES.TVE_ID_ENDED      TVE_ID_ENDED,
        Times.Created_By        Times_Created_By,
        Times.Last_Updated_By   Times_Last_Updated_By,
        Times.Last_Update_Date  Times_Last_Update_Date,
        Times.Last_Update_Login Times_Last_Update_Login,
        Times.Attribute15       Times_Attribute15
FROM    OKS_COVERAGE_TIMEZONES CTZ,
        OKC_RULE_GROUPS_B RGP,
        OKC_RULES_B RUL,
        OKC_COVER_TIMES CVT,
        OKC_TIMEVALUES_B TIMES
WHERE   CTZ.Cle_Id = RGP.CLE_ID
AND     CTZ.DNZ_CHR_ID = RGP.DNZ_CHR_ID
AND     RGP.ID = RUL.RGP_ID
AND     RGP.DNZ_CHR_ID = RUL.DNZ_CHR_ID
AND     RUL.RULE_INFORMATION_CATEGORY = 'CVR'
AND     RUL.ID  = CVT.RUL_ID
AND     CVT.TVE_ID = TIMES.ID
--AND     Times.Attribute15 IS NULL
AND     Times.rowid BETWEEN l_start_rowid and l_end_rowid
AND     NOT EXISTS (Select COV_TZE_LINE_ID from OKS_COVERAGE_TIMES where COV_TZE_LINE_ID= CTZ.ID);


CURSOR get_Coverage_time_Cur (l_tve_id IN NUMBER) IS
SELECT tve_type,day_of_week,hour,minute
FROM   okc_timevalues_v
WHERE  ID = l_tve_id;

TYPE Vc420_Tbl_Type IS VARRAY(1000) OF VARCHAR2(420);
TYPE Num_Tbl_Type  IS VARRAY(1000) OF NUMBER;
TYPE RowId_Tbl_Type  IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
TYPE Date_Tbl_Type IS VARRAY(1000) OF DATE;


TIMES_ROW_ID        RowId_Tbl_Type;
TimeZone_ID_TBL     Num_Tbl_Type;
TVE_ID_STARTED_TBL  Num_Tbl_Type;
TVE_ID_ENDED_TBL    Num_Tbl_Type;
DNZ_CHR_ID_TBL      Num_Tbl_Type;
Times_Attribute15_TBL   Vc420_Tbl_Type;
TIMES_Created_By_TBL         Num_Tbl_Type;
TIMES_Last_Updated_By_TBL    Num_Tbl_Type;
TIMES_Last_Update_Date_TBL   Date_Tbl_Type;
TIMES_Last_Update_Login_TBL  Num_Tbl_Type;

tablename1      VARCHAR2(1000);
l_return_status VARCHAR2(1) :=OKC_API.G_RET_STS_SUCCESS;
l_msg_count     NUMBER;

l_start_rowid       ROWID := p_start_rowid;
l_end_rowid         ROWID := p_end_rowid;
l_msg_data          VARCHAR2(1000);
l_msg_index_out     NUMBER;
l_message           VARCHAR2(2400);
x_msg_count                 NUMBER := 0;
x_msg_data                 VArchar2(1000);

G_EXCEPTION_HALT    EXCEPTION;
BEGIN
G_APP_NAME := 'COVERAGE_TIMES_MIGRATION';

OPEN Csr_Get_Coverage_times (l_start_rowid,l_end_rowid);
LOOP
    BEGIN
    l_cvt_rec   := 0;
    FETCH Csr_Get_Coverage_times BULK COLLECT INTO
            TimeZone_ID_Tbl,
            DNZ_CHR_ID_TBL,
            TIMES_ROW_ID,
            TVE_ID_STARTED_Tbl,
            TVE_ID_ENDED_Tbl,
            TIMES_Created_By_TBL,
            TIMES_Last_Updated_By_TBL,
            TIMES_Last_Update_Date_TBL,
            TIMES_Last_Update_Login_TBL,
            Times_Attribute15_TBL
            LIMIT 1000;

-- -- dbms_output.put_line('Value of TimeZone_ID_Tbl.COUNT='||TO_CHAR(TimeZone_ID_Tbl.COUNT));

    IF  TimeZone_ID_Tbl.COUNT > 0 THEN
    FOR I IN TimeZone_ID_Tbl.FIRST .. TimeZone_ID_Tbl.LAST LOOP

            l_cvt_rec := l_cvt_rec + 1;


            l_cvtv_tbl_in(l_cvt_rec).ID                 := okc_p_util.raw_to_number(sys_guid());


            l_cvtv_tbl_in(l_cvt_rec).COV_TZE_LINE_ID    := TimeZone_ID_Tbl(i);
            l_cvtv_tbl_in(l_cvt_rec).DNZ_CHR_ID    := DNZ_CHR_ID_TBL(i);

            l_cvtv_tbl_in(l_cvt_rec).Created_By         := TIMES_Created_By_TBL(i);
            l_cvtv_tbl_in(l_cvt_rec).Last_Updated_By    := TIMES_Last_Updated_By_TBL(i);
            l_cvtv_tbl_in(l_cvt_rec).Last_Update_Date   := TIMES_Last_Update_Date_TBL(i);
            l_cvtv_tbl_in(l_cvt_rec).Last_Update_Login  := TIMES_Last_Update_Login_TBL(i);
            l_cvtv_tbl_in(l_cvt_rec).object_version_number :=  1;

            FOR get_Coverage_time_REC  IN get_Coverage_time_Cur(TVE_ID_STARTED_TBL(i)) LOOP

            IF    get_Coverage_time_REC.day_of_week = 'SUN' THEN

                l_cvtv_tbl_in(l_cvt_rec).SUNDAY_YN := 'Y';

            ELSIF    get_Coverage_time_REC.day_of_week = 'MON' THEN

                l_cvtv_tbl_in(l_cvt_rec).MONDAY_YN := 'Y';

            ELSIF    get_Coverage_time_REC.day_of_week = 'TUE' THEN
                l_cvtv_tbl_in(l_cvt_rec).TUESDAY_YN := 'Y';

            ELSIF    get_Coverage_time_REC.day_of_week = 'WED' THEN
                l_cvtv_tbl_in(l_cvt_rec).WEDNESDAY_YN := 'Y';

            ELSIF    get_Coverage_time_REC.day_of_week = 'THU' THEN
                l_cvtv_tbl_in(l_cvt_rec).THURSDAY_YN := 'Y';

            ELSIF    get_Coverage_time_REC.day_of_week = 'FRI' THEN
                l_cvtv_tbl_in(l_cvt_rec).FRIDAY_YN := 'Y';

            ELSIF    get_Coverage_time_REC.day_of_week = 'SAT' THEN
                l_cvtv_tbl_in(l_cvt_rec).SATURDAY_YN := 'Y';

            END IF;

            l_cvtv_tbl_in(l_cvt_rec).START_HOUR := get_Coverage_time_REC.HOUR;
            l_cvtv_tbl_in(l_cvt_rec).START_MINUTE := get_Coverage_time_REC.MINUTE;

            END LOOP;

            FOR get_Coverage_time_REC  IN get_Coverage_time_Cur(TVE_ID_ENDED_Tbl(i)) LOOP

            l_cvtv_tbl_in(l_cvt_rec).END_HOUR := get_Coverage_time_REC.HOUR;
            l_cvtv_tbl_in(l_cvt_rec).END_MINUTE := get_Coverage_time_REC.MINUTE;

            END LOOP;


    END LOOP;
    END IF;

    tablename1 := 'oks_coverage_times';
   --  -- dbms_output.put_line('Value of l_cvtv_tbl_in.COUNT ='||TO_CHAR(l_cvtv_tbl_in.COUNT ));

    IF l_cvtv_tbl_in.COUNT > 0 THEN

  OKS_Insert_Row_Upg.INSERT_ROW_UPG_CVTV_TBL(          x_return_status             => l_return_status,
                                                    P_CVTV_TBL =>l_cvtv_tbl_in);

-- -- dbms_output.put_line('Value of l_return_status='||l_return_status);
        IF l_return_status = 'S' THEN
            x_return_status := 'S';
            x_message_data := NULL;
        ELSE
            RAISE G_EXCEPTION_HALT;
        END IF;

    END IF;


    EXIT WHEN Csr_Get_Coverage_times%NOTFOUND;

    EXCEPTION
        WHEN G_EXCEPTION_HALT THEN
        ROLLBACK;
        x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );

        IF x_msg_count > 0              THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
        END IF;

                x_message_data  := l_message;
                x_return_status := 'E';
        WHEN Others THEN
        ROLLBACK;
        x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );

         IF x_msg_count > 0              THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
        END IF;

                x_message_data  := l_message;
                x_return_status := 'E';

    END;
    EXIT WHEN Csr_Get_Coverage_times%NOTFOUND;
END LOOP;
CLOSE Csr_Get_Coverage_times;
EXCEPTION
    WHEN Others THEN
    Raise;
        x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );

         IF x_msg_count > 0              THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
        END IF;
                x_message_data  := l_message;
                x_return_status := 'E';

END COVERAGE_TIMES_MIGRATION;


--PROCEDURE Reaction_Time_migration( x_return_status OUT NOCOPY VARCHAR2) IS
PROCEDURE Reaction_Time_migration(  p_start_rowid   IN ROWID,
                                    p_end_rowid     IN ROWID,
                                    x_return_status OUT NOCOPY VARCHAR2,
                                    x_message_data  OUT NOCOPY VARCHAR2) IS

CURSOR Csr_Get_Reaction_Times (l_start_rowid IN ROWID ,l_end_rowid IN ROWID ) IS
    SELECT
        LINE.ID LINE_ID,
        Line.Created_By Line_Created_By,
		Line.Creation_Date		Line_Creation_Date,
        Line.Last_Updated_By    Line_Last_Updated_By,
        Line.Last_Update_Date   Line_Last_Update_Date,
        Line.Last_Update_Login  Line_Last_Update_Login,
        Rul.ROWID   RUL_ROW_ID,
        Rul.ID  Rul_Id,
        RGP.ID LINE_RGP_ID,
        LINE.LSE_ID LINE_LSE_ID,
        LINE.DNZ_CHR_ID LINE_DNZ_CHR_ID,
        OBJECT1_ID1  LINE_OBJECT1_ID1,
        OBJECT2_ID1 LINE_OBJECT2_ID1,
        RULE_INFORMATION1  COV_RULE_INFO1,
        RULE_INFORMATION2  COV_RULE_INFO2,
        RULE_INFORMATION3  COV_RULE_INFO3,
        RULE_INFORMATION4  COV_RULE_INFO4,
        RULE_INFORMATION5  COV_RULE_INFO5,
        RULE_INFORMATION6  COV_RULE_INFO6,
        RULE_INFORMATION7  COV_RULE_INFO7,
        RULE_INFORMATION8  COV_RULE_INFO8,
        RULE_INFORMATION9  COV_RULE_INFO9,
        RULE_INFORMATION10 COV_RULE_INFO10,
        RULE_INFORMATION11 COV_RULE_INFO11,
        RULE_INFORMATION12 COV_RULE_INFO12,
        RULE_INFORMATION13 COV_RULE_INFO13,
        RULE_INFORMATION14 COV_RULE_INFO14,
        RULE_INFORMATION15 COV_RULE_INFO15,
        RULE_INFORMATION_CATEGORY  COV_RULE_INFO,
        RUL.OBJECT_VERSION_NUMBER  COV_OBJ_VER_NUMBER
    FROM
       OKC_RULE_GROUPS_B RGP,
       OKC_RULES_B RUL,
       OKC_K_LINES_B LINE
  WHERE   LINE.ID = RGP.CLE_ID
  AND    RGP.ID  = RUL.RGP_ID
  AND    LINE.LSE_ID IN (4,17,22)
  AND    RUL.RULE_INFORMATION_CATEGORY IN ('RCN','RSN')
--  AND    RUL.RULE_INFORMATION15 IS NULL
  AND    Rul.rowid BETWEEN l_start_rowid and l_end_rowid
  AND    NOT EXISTS (SELECT CLE_ID FROM OKS_K_LINES_B WHERE CLE_ID = LINE.ID)
  ORDER BY LINE.ID;


TYPE RowId_Tbl_Type  IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
TYPE Num_Tbl_Type  IS VARRAY(1000) OF NUMBER;
TYPE Date_Tbl_Type IS VARRAY(1000) OF DATE;
TYPE Vc15_Tbl_Type IS VARRAY(1000) OF VARCHAR2(15);
TYPE Vc20_Tbl_Type IS VARRAY(1000) OF VARCHAR2(20);
TYPE Vc150_Tbl_Type IS VARRAY(1000) OF VARCHAR2(150);
TYPE Vc30_Tbl_Type IS VARRAY(1000) OF VARCHAR2(30);
TYPE Vc1_Tbl_Type IS VARRAY(1000) OF VARCHAR2(1);
TYPE Vc3_Tbl_Type IS VARRAY(1000) OF VARCHAR2(3);
TYPE Vc2000_Tbl_Type IS VARRAY(1000) OF VARCHAR2(2000);
TYPE Vc50_Tbl_Type IS VARRAY(1000) OF VARCHAR2(50);
TYPE Vc80_Tbl_Type IS VARRAY(1000) OF VARCHAR2(80);
TYPE Vc120_Tbl_Type IS VARRAY(1000) OF VARCHAR2(120);
TYPE Vc600_Tbl_Type IS VARRAY(1000) OF VARCHAR2(600);


LINE_ID_TBL                 Num_Tbl_Type;
Line_Created_By_TBL         Num_Tbl_Type;
Line_Creation_Date_Tbl		Date_Tbl_Type;
Line_Last_Updated_By_TBL    Num_Tbl_Type;
Line_Last_Update_Date_TBL   Date_Tbl_Type;
Line_Last_Update_Login_TBL  Num_Tbl_Type;
RUL_ROW_ID_TBL              RowId_Tbl_Type;
RUL_ID_TBL                 Num_Tbl_Type;
LINE_RGP_ID_TBL             Num_Tbl_Type;
LINE_LSE_ID_TBL             Num_Tbl_Type;
LINE_DNZ_CHR_ID_TBL         Num_Tbl_Type;
LINE_OBJECT1_ID1_TBL        Vc150_Tbl_Type;
LINE_OBJECT2_ID1_TBL        Vc150_Tbl_Type;
COV_RULE_INFO1_TBL         Vc150_Tbl_Type;
COV_RULE_INFO2_TBL         Vc150_Tbl_Type;
COV_RULE_INFO3_TBL         Vc150_Tbl_Type;
COV_RULE_INFO4_TBL         Vc150_Tbl_Type;
COV_RULE_INFO5_TBL         Vc150_Tbl_Type;
COV_RULE_INFO6_TBL         Vc150_Tbl_Type;
COV_RULE_INFO7_TBL         Vc150_Tbl_Type;
COV_RULE_INFO8_TBL         Vc150_Tbl_Type;
COV_RULE_INFO9_TBL         Vc150_Tbl_Type;
COV_RULE_INFO10_TBL         Vc150_Tbl_Type;
COV_RULE_INFO11_TBL         Vc150_Tbl_Type;
COV_RULE_INFO12_TBL         Vc150_Tbl_Type;
COV_RULE_INFO13_TBL         Vc150_Tbl_Type;
COV_RULE_INFO14_TBL         Vc150_Tbl_Type;
COV_RULE_INFO15_TBL         Vc150_Tbl_Type;
COV_RULE_INFO_TBL           Vc150_Tbl_Type;
COV_OBJ_VER_NUMBER_TBL         Num_Tbl_Type;


x_clev_tbl_in             	oks_kln_pvt.klnv_tbl_type;
l_clev_tbl_in             	oks_kln_pvt.klnv_tbl_type;

x_actv_tbl_in               OKS_ACT_PVT.OksActionTimeTypesVTblType;
l_actv_tbl_in               OKS_ACT_PVT.OksActionTimeTypesVTblType;


L_OLD_CLE_ID                NUMBER  := -99999;
L_CLE_ID                    NUMBER  := -99999;
l_cle_ctr                   NUMBER  := 0;
l_return_Status             VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
x_msg_count                 NUMBER := 0;
x_msg_data                 VArchar2(1000);

l_start_rowid       ROWID := p_start_rowid;
l_end_rowid         ROWID := p_end_rowid;

l_msg_data          VARCHAR2(1000);
l_msg_index_out     NUMBER;
l_message           VARCHAR2(2400);

G_EXCEPTION_HALT            EXCEPTION;

BEGIN
G_APP_NAME := 'Reaction_Time_migration';
OPEN Csr_Get_Reaction_Times (l_start_rowid,l_end_rowid);
LOOP
    BEGIN
    FETCH Csr_Get_Reaction_Times BULK COLLECT INTO
            LINE_ID_TBL                 ,
            Line_Created_By_TBL         ,
			Line_Creation_Date_TBL		,
            Line_Last_Updated_By_TBL    ,
            Line_Last_Update_Date_TBL   ,
            Line_Last_Update_Login_TBL  ,
            RUL_ROW_ID_TBL              ,
            RUL_ID_TBL                  ,
            LINE_RGP_ID_TBL             ,
            LINE_LSE_ID_TBL             ,
            LINE_DNZ_CHR_ID_TBL         ,
            LINE_OBJECT1_ID1_TBL        ,
            LINE_OBJECT2_ID1_TBL        ,
            COV_RULE_INFO1_TBL         ,
            COV_RULE_INFO2_TBL         ,
            COV_RULE_INFO3_TBL         ,
            COV_RULE_INFO4_TBL         ,
            COV_RULE_INFO5_TBL         ,
            COV_RULE_INFO6_TBL         ,
            COV_RULE_INFO7_TBL         ,
            COV_RULE_INFO8_TBL         ,
            COV_RULE_INFO9_TBL         ,
            COV_RULE_INFO10_TBL         ,
            COV_RULE_INFO11_TBL         ,
            COV_RULE_INFO12_TBL         ,
            COV_RULE_INFO13_TBL         ,
            COV_RULE_INFO14_TBL         ,
            COV_RULE_INFO15_TBL         ,
            COV_RULE_INFO_TBL           ,
            COV_OBJ_VER_NUMBER_TBL
            LIMIT 1000;

        IF LINE_ID_TBL.COUNT > 0 THEN  --LINE_ID_TBL.COUNT > 0

            FOR I IN LINE_ID_TBL.FIRST .. LINE_ID_TBL.LAST LOOP

            L_Cle_id := LINE_ID_TBL(i);

            IF (L_OLD_CLE_ID <> L_CLE_ID) THEN
                l_cle_ctr := l_cle_ctr + 1;

            l_clev_tbl_in(l_cle_ctr).Id := okc_p_util.raw_to_number(sys_guid());

            l_clev_tbl_in(l_cle_ctr).Created_By   := Line_Created_By_TBL(i);
            l_clev_tbl_in(l_cle_ctr).Creation_Date   := Line_Creation_Date_TBL(i);
            l_clev_tbl_in(l_cle_ctr).Last_Updated_By   := Line_Last_Updated_By_TBL(i);
            l_clev_tbl_in(l_cle_ctr).Last_Update_Date   := Line_Last_Update_Date_TBL(i);
            l_clev_tbl_in(l_cle_ctr).Last_Update_Login  := Line_Last_Update_Login_TBL(i);

            l_clev_tbl_in(l_cle_ctr).Cle_Id         :=  LINE_ID_TBL(i);
            l_clev_tbl_in(l_cle_ctr).Dnz_Chr_Id         :=  LINE_DNZ_CHR_ID_TBL(i);

            l_clev_tbl_in(l_cle_ctr).object_version_number :=  1;
            l_clev_tbl_in(l_cle_ctr).Sync_Date_Install :=  'N';

            IF      ((COV_RULE_INFO_TBL(i) = 'RCN') OR (COV_RULE_INFO_TBL(i) = 'RSN')) THEN

            l_clev_tbl_in(l_cle_ctr).INCIDENT_SEVERITY_ID :=    LINE_OBJECT1_ID1_TBL(i);
            l_clev_tbl_in(l_cle_ctr).PDF_ID               :=    COV_RULE_INFO1_TBL(i);
            l_clev_tbl_in(l_cle_ctr).WORK_THRU_YN         :=    COV_RULE_INFO3_TBL(i);
            l_clev_tbl_in(l_cle_ctr).REACT_ACTIVE_YN      :=    COV_RULE_INFO4_TBL(i);
            l_clev_tbl_in(l_cle_ctr).REACT_TIME_NAME      :=    COV_RULE_INFO2_TBL(i);

            END IF;



            END IF;            --IF (L_OLD_CLE_ID <> L_CLE_ID) THEN

            l_act_ctr := l_act_ctr + 1;

            l_actv_tbl_in(l_act_ctr).Id := okc_p_util.raw_to_number(sys_guid());
            l_actv_tbl_in(l_act_ctr).Created_By   := -9999;
            l_actv_tbl_in(l_act_ctr).Last_Updated_By   := -9999;
            l_actv_tbl_in(l_act_ctr).Last_Update_Date   := sysdate;
            l_actv_tbl_in(l_act_ctr).Last_Update_Login  := -9999;
            l_actv_tbl_in(l_act_ctr).Cle_Id         :=  LINE_ID_TBL(i);
            l_actv_tbl_in(l_act_ctr).Dnz_Chr_Id         :=  LINE_DNZ_CHR_ID_TBL(i);
            l_actv_tbl_in(l_act_ctr).action_type_code   :=  COV_RULE_INFO_TBL(i);
            l_actv_tbl_in(l_act_ctr).object_version_number :=  1;


            L_OLD_CLE_ID := L_CLE_ID;


            END LOOP;

        END IF; ----LINE_ID_TBL.COUNT > 0


IF l_clev_tbl_in.count > 0 THEN
    oks_kln_pvt.insert_row
    (
            x_return_status     => l_return_status,
            p_klnv_tbl          => l_clev_tbl_in,
            p_api_version       =>1,
            p_init_msg_list     => null,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            x_klnv_tbl          => x_clev_tbl_in
    );
END IF;


IF l_actv_tbl_in.count > 0 THEN
    OKS_ACT_PVT.insert_row
    (
            x_return_status                         => l_return_status,
            p_oks_action_time_types_v_tbl           => l_actv_tbl_in,
            p_api_version                           =>1,
            p_init_msg_list                         => null,
            x_msg_count                             => x_msg_count,
            x_msg_data                              => x_msg_data,
            x_oks_action_time_types_v_tbl           => X_actv_tbl_in
    );
END IF;

l_actv_tbl_in.DELETE;
l_clev_tbl_in.DELETE;

        IF l_return_status = 'S' THEN
                        x_return_status := 'S';
                        x_message_data := NULL;
        ELSE
            RAISE G_EXCEPTION_HALT;
        END IF;

EXCEPTION
    WHEN G_EXCEPTION_HALT THEN
    ROLLBACK;
    l_actv_tbl_in.DELETE;
    l_clev_tbl_in.DELETE;

        x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );
         IF x_msg_count > 0              THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
        END IF;
                x_message_data  := l_message;
                x_return_status := 'E';
    WHEN Others THEN
    ROLLBACK;
    l_actv_tbl_in.DELETE;
    l_clev_tbl_in.DELETE;

        x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );
         IF x_msg_count > 0              THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
    END IF;
                x_message_data  := l_message;
                x_return_status := 'E';
END;

EXIT WHEN Csr_Get_Reaction_Times%NOTFOUND;

END LOOP;
CLOSE     Csr_Get_Reaction_Times;

END Reaction_Time_migration;

PROCEDURE Reaction_TimeValues_Migration ( x_return_status OUT NOCOPY VARCHAR2,
                                            x_message_data  OUT NOCOPY VARCHAR2) IS


    CURSOR Csr_Get_Timevalues   IS
        SELECT  TYP.id  Action_Type_ID,
                TYP.cle_id Action_Type_Cle_ID ,
                TYP.dnz_chr_id Action_Type_Dnz_ID ,
                TYP.Created_By  Created_By,
                TYP.Last_Updated_By Last_Updated_By,
                TYP.Last_Update_Date    Last_Update_Date,
                TYP.Last_Update_Login   Last_Update_Login,
                RIN.UOM_CODE    UOM_CODE,
                RIN.DURATION    DURATION,
                TIM.DAY_OF_WEEK DAY_OF_WEEK,
                TIM.TVE_TYPE    TVE_TYPE,
                Rul.ID          RUL_ID
        FROM    oks_action_time_types_v TYP,
                okc_rule_groups_V RGP,okc_rules_v  RUL,
                okc_timevalues_v TIM,okc_react_intervals RIN
        WHERE RGP.CLE_ID = TYP.CLE_ID
        AND   RGP.DNZ_CHR_ID = TYP.DNZ_CHR_ID
        AND   RGP.ID    = RUL.RGP_ID
       -- AND typ.id = 308454467546072904212144662892351929683
        AND   RGP.DNZ_CHR_ID = RUL.DNZ_CHR_ID
        AND   RUL.DNZ_CHR_ID = TYP.DNZ_CHR_ID
        AND   RUL.ID =   RIN.RUL_ID
        AND   rul.RULE_INFORMATION_CATEGORY = typ.ACTION_TYPE_CODE
        AND   RIN.DNZ_CHR_ID = TYP.DNZ_CHR_ID
        AND   TIM.ID   =   RIN.TVE_ID
        AND   TIM.DNZ_CHR_ID    =  RIN.DNZ_CHR_ID
        AND   TIM.DNZ_CHR_ID    =  RGP.DNZ_CHR_ID
        AND   TIM.DNZ_CHR_ID    =  RUL.DNZ_CHR_ID
        AND   TIM.DNZ_CHR_ID    =  TYP.DNZ_CHR_ID
        AND NOT EXISTS (Select cov_action_type_id FROM OKS_ACTION_TIMES WHERE COV_ACTION_TYPE_ID =TYP.id)
        ORDER BY RUL.ID;


TYPE RowId_Tbl_Type  IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
TYPE Num_Tbl_Type  IS VARRAY(1000) OF NUMBER;

TYPE Vc15_Tbl_Type IS VARRAY(1000) OF VARCHAR2(15);
TYPE Vc20_Tbl_Type IS VARRAY(1000) OF VARCHAR2(20);
TYPE Date_Tbl_Type IS VARRAY(1000) OF DATE;

l_acm_ctr   NUMBER :=0;

l_return_status            VArchar2(2):= 'S';

x_msg_count                 NUMBER := 0;
x_msg_data                 VArchar2(1000);

l_msg_data          VARCHAR2(1000);
l_msg_index_out     NUMBER;
l_message           VARCHAR2(2400);
--l_start_rowid       ROWID := p_start_rowid;
--l_end_rowid         ROWID := p_end_rowid;

G_EXCEPTION_HALT        EXCEPTION;

Action_Type_ID_TBL      Num_Tbl_Type;
Action_Type_Cle_ID_TBL  Num_Tbl_Type;
Action_Type_Dnz_ID_TBL  Num_Tbl_Type;
Created_By_TBL          Num_Tbl_Type;
Last_Updated_By_TBL     Num_Tbl_Type;
Last_Update_Date_TBL    Date_Tbl_Type;
Last_Update_Login_TBL   Num_Tbl_Type;
UOM_CODE_TBL            Vc20_Tbl_Type;
DURATION_TBL            Num_Tbl_Type;
DAY_OF_WEEK_TBL         Vc20_Tbl_Type;
TVE_TYPE_TBL            Vc20_Tbl_Type;
RUL_ID_TBL              Num_Tbl_Type;
l_rul_id                NUMBER := -9999;
 BEGIN

G_APP_NAME := 'Reaction_TimeValues_Migration';

OPEN Csr_Get_Timevalues ;
LOOP
    BEGIN
    FETCH Csr_Get_Timevalues BULK COLLECT INTO
            Action_Type_ID_TBL,
            Action_Type_Cle_ID_TBL,
            Action_Type_Dnz_ID_TBL,
            Created_By_TBL,
            Last_Updated_By_TBL,
            Last_Update_Date_TBL,
            Last_Update_Login_TBL,
            UOM_CODE_TBL,
            DURATION_TBL,
            DAY_OF_WEEK_TBL,
            TVE_TYPE_TBL,
            RUL_ID_TBL
            LIMIT 1000;

          --   -- dbms_output.put_line('Value of Action_Type_ID_TBL.COUNT='||TO_CHAR(Action_Type_ID_TBL.COUNT));

            IF  Action_Type_ID_TBL.COUNT > 0 THEN
            FOR I IN Action_Type_ID_TBL.FIRST .. Action_Type_ID_TBL.LAST LOOP

            IF  l_rul_id  <> RUL_ID_TBL(I) THEN

                l_rul_id := RUL_ID_TBL(I);
                l_acm_ctr := l_acm_ctr + 1;

                l_acmv_tbl_in(l_acm_ctr).Created_By         := Created_By_TBL(i);
                l_acmv_tbl_in(l_acm_ctr).Last_Updated_By    := Last_Updated_By_TBL(i);
                l_acmv_tbl_in(l_acm_ctr).Last_Update_Date   := Last_Update_Date_TBL(i);
                l_acmv_tbl_in(l_acm_ctr).Last_Update_Login  := Last_Update_Login_TBL(i);
                l_acmv_tbl_in(l_acm_ctr).SECURITY_GROUP_ID      := NULL;
                l_acmv_tbl_in(l_acm_ctr).PROGRAM_APPLICATION_ID := NULL;
                l_acmv_tbl_in(l_acm_ctr).PROGRAM_ID := NULL;
                l_acmv_tbl_in(l_acm_ctr).PROGRAM_UPDATE_DATE := NULL;
                l_acmv_tbl_in(l_acm_ctr).REQUEST_ID := NULL;

                l_acmv_tbl_in(l_acm_ctr).ID := okc_p_util.raw_to_number(sys_guid());
                l_acmv_tbl_in(l_acm_ctr).COV_ACTION_TYPE_ID := Action_Type_ID_TBL(i);
                l_acmv_tbl_in(l_acm_ctr).CLE_ID             := Action_Type_Cle_ID_TBL(i);
                l_acmv_tbl_in(l_acm_ctr).Dnz_chr_id       := Action_Type_Dnz_ID_TBL(i);
                l_acmv_tbl_in(l_acm_ctr).UOM_CODE       :=  UOM_CODE_TBL(i);
                l_acmv_tbl_in(l_acm_ctr).object_version_number :=  1;

                    l_acmv_tbl_in(l_acm_ctr).SUN_DURATION   :=  NULL;
                    l_acmv_tbl_in(l_acm_ctr).MON_DURATION   :=  NULL;
                    l_acmv_tbl_in(l_acm_ctr).TUE_DURATION   :=  NULL;
                    l_acmv_tbl_in(l_acm_ctr).WED_DURATION   :=  NULL;
                    l_acmv_tbl_in(l_acm_ctr).THU_DURATION   :=  NULL;
                    l_acmv_tbl_in(l_acm_ctr).FRI_DURATION   :=  NULL;
                    l_acmv_tbl_in(l_acm_ctr).SAT_DURATION   :=  NULL;
            END IF;
                IF DAY_OF_WEEK_TBL(i) = 'SUN' THEN
                    l_acmv_tbl_in(l_acm_ctr).SUN_DURATION   := DURATION_TBL(i);

                ELSIF DAY_OF_WEEK_TBL(i) = 'MON' THEN
                    l_acmv_tbl_in(l_acm_ctr).MON_DURATION   := DURATION_TBL(i);

                ELSIF DAY_OF_WEEK_TBL(i) = 'TUE' THEN
                    l_acmv_tbl_in(l_acm_ctr).TUE_DURATION   := DURATION_TBL(i);

                ELSIF DAY_OF_WEEK_TBL(i) = 'WED' THEN
                    l_acmv_tbl_in(l_acm_ctr).WED_DURATION   := DURATION_TBL(i);

                ELSIF DAY_OF_WEEK_TBL(i) = 'THU' THEN
                    l_acmv_tbl_in(l_acm_ctr).THU_DURATION   := DURATION_TBL(i);

                ELSIF DAY_OF_WEEK_TBL(i) = 'FRI' THEN
                    l_acmv_tbl_in(l_acm_ctr).FRI_DURATION   := DURATION_TBL(i);

                ELSIF DAY_OF_WEEK_TBL(i) = 'SAT' THEN
                    l_acmv_tbl_in(l_acm_ctr).SAT_DURATION   := DURATION_TBL(i);
                END IF;

            END LOOP;
            END IF;

-- -- dbms_output.put_line('Value of l_acmv_tbl_in.COUNT='||TO_CHAR(l_acmv_tbl_in.COUNT));

IF  l_acmv_tbl_in.COUNT > 0 THEN

OKS_Insert_Row_Upg.INSERT_ROW_UPG_ACMV_TBL
					(x_return_status			=> l_return_status,
					P_ACMV_TBL 					=> l_acmv_tbl_in);
-- -- dbms_output.put_line('Value of l_return_Status='||l_return_Status);
    IF l_return_Status = 'S' THEN
        X_return_Status := 'S';
        X_Message_Data := NULL;
        COMMIT;
    ELSE
        RAISE G_EXCEPTION_HALT;
    END IF;

END IF;

    EXIT WHEN Csr_Get_Timevalues%NOTFOUND;
CLOSE Csr_Get_Timevalues;

EXCEPTION
    WHEN G_EXCEPTION_HALT THEN
    ROLLBACK;

                      x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );

        IF x_msg_count > 0  THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
        END IF;
                x_message_data  := l_message;
                x_return_status := 'E';


    WHEN Others THEN
        x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );
         IF x_msg_count > 0              THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
    END IF;
                x_message_data  := l_message;
                x_return_status := 'E';

    END;

    EXIT WHEN Csr_Get_Timevalues%NOTFOUND;
    CLOSE Csr_Get_Timevalues;
 l_acmv_tbl_in.DELETE;

END LOOP;

IF  Csr_Get_Timevalues%ISOPEN        THEN
    CLOSE Csr_Get_Timevalues;
END IF;


--CLOSE Csr_Get_Timevalues;
EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
            x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );
         IF x_msg_count > 0              THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
    END IF;
                x_message_data  := l_message;
                x_return_status := 'E';

END Reaction_TimeValues_Migration;



--PROCEDURE BILL_TYPES_MIGRATION( x_return_status OUT NOCOPY VARCHAR2) IS
PROCEDURE BILL_TYPES_MIGRATION( p_start_rowid   IN ROWID,
                                p_end_rowid     IN ROWID,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_message_data  OUT NOCOPY VARCHAR2) IS
CURSOR Csr_Get_Bill_Types (l_start_rowid IN ROWID ,l_end_rowid IN ROWID ) IS
    SELECT
        LINE.ID LINE_ID,
        Line.Created_By Line_Created_By,
		Line.Creation_Date		Line_Creation_Date,
        Line.Last_Updated_By    Line_Last_Updated_By,
        Line.Last_Update_Date   Line_Last_Update_Date,
        Line.Last_Update_Login  Line_Last_Update_Login,
        Rul.ROWID   RUL_ROW_ID,
        RGP.ID LINE_RGP_ID,
        LINE.LSE_ID LINE_LSE_ID,
        LINE.DNZ_CHR_ID LINE_DNZ_CHR_ID,
        OBJECT1_ID1  LINE_OBJECT1_ID1,
        OBJECT2_ID1 LINE_OBJECT2_ID1,
        RULE_INFORMATION1  COV_RULE_INFO1,
        RULE_INFORMATION2  COV_RULE_INFO2,
        RULE_INFORMATION3  COV_RULE_INFO3,
        RULE_INFORMATION4  COV_RULE_INFO4,
        RULE_INFORMATION5  COV_RULE_INFO5,
        RULE_INFORMATION6  COV_RULE_INFO6,
        RULE_INFORMATION7  COV_RULE_INFO7,
        RULE_INFORMATION8  COV_RULE_INFO8,
        RULE_INFORMATION9  COV_RULE_INFO9,
        RULE_INFORMATION10 COV_RULE_INFO10,
        RULE_INFORMATION11 COV_RULE_INFO11,
        RULE_INFORMATION12 COV_RULE_INFO12,
        RULE_INFORMATION13 COV_RULE_INFO13,
        RULE_INFORMATION14 COV_RULE_INFO14,
        RULE_INFORMATION15 COV_RULE_INFO15,
        RULE_INFORMATION_CATEGORY  COV_RULE_INFO,
        RUL.OBJECT_VERSION_NUMBER  COV_OBJ_VER_NUMBER
    FROM
       OKC_RULE_GROUPS_B RGP,
       OKC_RULES_B RUL,
       OKC_K_LINES_B LINE
  WHERE LINE.ID = RGP.CLE_ID
  AND    RGP.ID  = RUL.RGP_ID
  AND    LINE.LSE_ID IN (5,59,23)
  --AND    RUL.RULE_INFORMATION_CATEGORY IN ('LMT')
--  AND    RUL.RULE_INFORMATION15 IS NULL
  AND    Rul.rowid BETWEEN l_start_rowid and l_end_rowid
  AND    NOT EXISTS (SELECT CLE_ID FROM OKS_K_LINES_B WHERE CLE_ID = LINE.ID)
  ORDER BY LINE.ID;



TYPE RowId_Tbl_Type  IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
TYPE Num_Tbl_Type  IS VARRAY(1000) OF NUMBER;
TYPE Date_Tbl_Type IS VARRAY(1000) OF DATE;
TYPE Vc15_Tbl_Type IS VARRAY(1000) OF VARCHAR2(15);
TYPE Vc20_Tbl_Type IS VARRAY(1000) OF VARCHAR2(20);
TYPE Vc150_Tbl_Type IS VARRAY(1000) OF VARCHAR2(150);
TYPE Vc30_Tbl_Type IS VARRAY(1000) OF VARCHAR2(30);
TYPE Vc1_Tbl_Type IS VARRAY(1000) OF VARCHAR2(1);
TYPE Vc3_Tbl_Type IS VARRAY(1000) OF VARCHAR2(3);
TYPE Vc2000_Tbl_Type IS VARRAY(1000) OF VARCHAR2(2000);
TYPE Vc50_Tbl_Type IS VARRAY(1000) OF VARCHAR2(50);
TYPE Vc80_Tbl_Type IS VARRAY(1000) OF VARCHAR2(80);
TYPE Vc120_Tbl_Type IS VARRAY(1000) OF VARCHAR2(120);
TYPE Vc600_Tbl_Type IS VARRAY(1000) OF VARCHAR2(600);


LINE_ID_TBL                 Num_Tbl_Type;
Line_Created_By_TBL         Num_Tbl_Type;
Line_Creation_Date_TBL		Date_Tbl_Type;
Line_Last_Updated_By_TBL    Num_Tbl_Type;
Line_Last_Update_Date_TBL   Date_Tbl_Type;
Line_Last_Update_Login_TBL  Num_Tbl_Type;
RUL_ROW_ID_TBL              RowId_Tbl_Type;
LINE_RGP_ID_TBL             Num_Tbl_Type;
LINE_LSE_ID_TBL             Num_Tbl_Type;
LINE_DNZ_CHR_ID_TBL         Num_Tbl_Type;
LINE_OBJECT1_ID1_TBL        Vc150_Tbl_Type;
LINE_OBJECT2_ID1_TBL        Vc150_Tbl_Type;
COV_RULE_INFO1_TBL         Vc150_Tbl_Type;
COV_RULE_INFO2_TBL         Vc150_Tbl_Type;
COV_RULE_INFO3_TBL         Vc150_Tbl_Type;
COV_RULE_INFO4_TBL         Vc150_Tbl_Type;
COV_RULE_INFO5_TBL         Vc150_Tbl_Type;
COV_RULE_INFO6_TBL         Vc150_Tbl_Type;
COV_RULE_INFO7_TBL         Vc150_Tbl_Type;
COV_RULE_INFO8_TBL         Vc150_Tbl_Type;
COV_RULE_INFO9_TBL         Vc150_Tbl_Type;
COV_RULE_INFO10_TBL         Vc150_Tbl_Type;
COV_RULE_INFO11_TBL         Vc150_Tbl_Type;
COV_RULE_INFO12_TBL         Vc150_Tbl_Type;
COV_RULE_INFO13_TBL         Vc150_Tbl_Type;
COV_RULE_INFO14_TBL         Vc150_Tbl_Type;
COV_RULE_INFO15_TBL         Vc150_Tbl_Type;
COV_RULE_INFO_TBL           Vc150_Tbl_Type;
COV_OBJ_VER_NUMBER_TBL         Num_Tbl_Type;

x_clev_tbl_in             	oks_kln_pvt.klnv_tbl_type;
l_clev_tbl_in             	oks_kln_pvt.klnv_tbl_type;
l_cle_ctr                   NUMBER := 0;
tablename1                  VArchar2(1000);
x_msg_count                 NUMBER := 0;
x_msg_data                 VArchar2(1000);
L_OLD_CLE_ID                NUMBER  := -99999;
L_CLE_ID                    NUMBER  := -99999;
l_duration                  NUMBER;
l_period                    VArchar2(10);
l_return_status            VArchar2(1) := OKC_API.G_RET_STS_SUCCESS;
G_EXCEPTION_HALT            EXCEPTION;

l_start_rowid       ROWID := p_start_rowid;
l_end_rowid         ROWID := p_end_rowid;

l_msg_data          VARCHAR2(1000);
l_msg_index_out     NUMBER;
l_message           VARCHAR2(2400);

BEGIN
G_APP_NAME := 'BILL_TYPES_MIGRATION';
OPEN Csr_Get_Bill_Types (l_start_rowid,l_end_rowid);
LOOP
    BEGIN
    FETCH Csr_Get_Bill_Types BULK COLLECT INTO
            LINE_ID_TBL                 ,
            Line_Created_By_TBL         ,
			Line_Creation_Date_TBL		,
            Line_Last_Updated_By_TBL    ,
            Line_Last_Update_Date_TBL   ,
            Line_Last_Update_Login_TBL  ,
            RUL_ROW_ID_TBL              ,
            LINE_RGP_ID_TBL             ,
            LINE_LSE_ID_TBL             ,
            LINE_DNZ_CHR_ID_TBL         ,
            LINE_OBJECT1_ID1_TBL        ,
            LINE_OBJECT2_ID1_TBL        ,
            COV_RULE_INFO1_TBL         ,
            COV_RULE_INFO2_TBL         ,
            COV_RULE_INFO3_TBL         ,
            COV_RULE_INFO4_TBL         ,
            COV_RULE_INFO5_TBL         ,
            COV_RULE_INFO6_TBL         ,
            COV_RULE_INFO7_TBL         ,
            COV_RULE_INFO8_TBL         ,
            COV_RULE_INFO9_TBL         ,
            COV_RULE_INFO10_TBL         ,
            COV_RULE_INFO11_TBL         ,
            COV_RULE_INFO12_TBL         ,
            COV_RULE_INFO13_TBL         ,
            COV_RULE_INFO14_TBL         ,
            COV_RULE_INFO15_TBL         ,
            COV_RULE_INFO_TBL           ,
            COV_OBJ_VER_NUMBER_TBL
            LIMIT 1000;



        IF LINE_ID_TBL.COUNT > 0 THEN

            FOR I IN LINE_ID_TBL.FIRST .. LINE_ID_TBL.LAST LOOP
            L_Cle_id := LINE_ID_TBL(i);
            IF (L_OLD_CLE_ID <> L_CLE_ID) THEN
                l_cle_ctr := l_cle_ctr + 1;
            END IF;

            l_clev_tbl_in(l_cle_ctr).Id := okc_p_util.raw_to_number(sys_guid());
            l_clev_tbl_in(l_cle_ctr).Created_By   := Line_Created_By_tbl(i);
            l_clev_tbl_in(l_cle_ctr).Creation_Date   := Line_Creation_Date_TBL(i);
            l_clev_tbl_in(l_cle_ctr).Last_Updated_By   :=
									Line_Last_Updated_By_TBL(i);
            l_clev_tbl_in(l_cle_ctr).Last_Update_Date   :=
									Line_Last_Update_Date_TBL(i);
            l_clev_tbl_in(l_cle_ctr).Last_Update_Login  :=
            						Line_Last_Update_Login_TBL(i);
            l_clev_tbl_in(l_cle_ctr).Cle_Id         :=  LINE_ID_TBL(i);
            l_clev_tbl_in(l_cle_ctr).Dnz_Chr_Id         :=  LINE_DNZ_CHR_ID_TBL(i);
            l_clev_tbl_in(l_cle_ctr).object_version_number :=  1;
            l_clev_tbl_in(l_cle_ctr).Sync_Date_Install :=  'N';

            IF   COV_RULE_INFO_TBL(i) = 'LMT' THEN
                l_clev_tbl_in(l_cle_ctr).LIMIT_UOM_QUANTIFIED  := COV_RULE_INFO1_TBL(i);
                l_clev_tbl_in(l_cle_ctr).DISCOUNT_AMOUNT       := COV_RULE_INFO2_TBL(i);
                l_clev_tbl_in(l_cle_ctr).DISCOUNT_PERCENT      := COV_RULE_INFO4_TBL(i);
            END IF;


            L_OLD_CLE_ID := L_CLE_ID;
            END LOOP;
        END IF;


         tablename1 := 'OKS_K_LINES';

         IF l_clev_tbl_in.count > 0 THEN
            oks_kln_pvt.insert_row
            (
                x_return_status     => l_return_status,
                p_klnv_tbl          => l_clev_tbl_in,
                p_api_version       =>1,
                p_init_msg_list     => null,
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data,
                x_klnv_tbl          => x_clev_tbl_in
            );

        END IF;


         IF l_return_status = 'S' THEN
            x_return_status := 'S';
            x_message_data := NULL;
        ELSE
            RAISE G_EXCEPTION_HALT;
        END IF;

EXCEPTION
    WHEN G_EXCEPTION_HALT THEN
    ROLLBACK;

      x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );
    l_clev_tbl_in.DELETE;

         IF x_msg_count > 0              THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
    END IF;
                x_message_data  := l_message;
                x_return_status := 'E';
    WHEN Others THEN
    ROLLBACK;
    x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );
    l_clev_tbl_in.DELETE;
         IF x_msg_count > 0              THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
    END IF;
                x_message_data  := l_message;
                x_return_status := 'E';
        EXIT WHEN Csr_Get_Bill_Types%NOTFOUND;
    END;

        EXIT WHEN Csr_Get_Bill_Types%NOTFOUND;

END LOOP;

CLOSE Csr_Get_Bill_Types;

EXCEPTION
    WHEN Others THEN
    x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );
     IF x_msg_count > 0              THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
    END IF;
                x_message_data  := l_message;
                x_return_status := 'E';

END BILL_TYPES_MIGRATION;



/**********************************HISTORY***********************************************/

PROCEDURE   Insert_Into_Klines( p_clev_tbl_in   IN  klnv_tbl_type,
                                p_clet_tbl_in   IN  klt_tbl_type,
                                x_return_Status OUT NOCOPY VARCHAR2) IS
i_clev_tbl_in   klnv_tbl_type   :=    p_clev_tbl_in;
l_clet_tbl_in   klt_tbl_type    :=  p_clet_tbl_in;

l_return_Status     VARCHAR2(1) := 'S';
x_msg_count         NUMBER := 0;
x_msg_data          VArchar2(1000);
l_msg_data          VARCHAR2(1000);
l_msg_index_out     NUMBER;
l_message           VARCHAR2(2400);

BEGIN
G_APP_NAME := 'Insert_Into_Klines';

IF i_clev_tbl_in.COUNT  > 0 THEN

        i  := i_clev_tbl_in.FIRST; j:=0;
        WHILE i is not null   LOOP
            j:=j+1;

            In_ID(J):=	i_clev_tbl_in(I).Id;
            In_MAJOR_VERSION  (J):=	i_clev_tbl_in(I).object_version_number;
            In_CLE_ID (J):=	i_clev_tbl_in(I).CLE_ID  ;
            In_DNZ_CHR_ID     (J):=	i_clev_tbl_in(I).DNZ_CHR_ID         ;
            In_DISCOUNT_LIST(J):=	i_clev_tbl_in(I).DISCOUNT_LIST ;
            In_ACCT_RULE_ID (J):=	i_clev_tbl_in(I).ACCT_RULE_ID  ;
            In_PAYMENT_TYPE (J):=	i_clev_tbl_in(I).PAYMENT_TYPE  ;
            In_CC_NO      (J):=	i_clev_tbl_in(I).CC_NO         ;
            In_CC_EXPIRY_DATE       (J):=	i_clev_tbl_in(I).CC_EXPIRY_DATE;
            In_CC_BANK_ACCT_ID      (J):=	i_clev_tbl_in(I).CC_BANK_ACCT_ID          ;
            In_CC_AUTH_CODE (J):=	i_clev_tbl_in(I).CC_AUTH_CODE  ;
            In_LOCKED_PRICE_LIST_ID (J):=	i_clev_tbl_in(I).LOCKED_PRICE_LIST_ID     ;
            In_USAGE_EST_YN (J):=	i_clev_tbl_in(I).USAGE_EST_YN  ;
            In_USAGE_EST_METHOD     (J):=	i_clev_tbl_in(I).USAGE_EST_METHOD         ;
            In_USAGE_EST_START_DATE (J):=	i_clev_tbl_in(I).USAGE_EST_START_DATE     ;
            In_TERMN_METHOD (J):=	i_clev_tbl_in(I).TERMN_METHOD  ;
            In_UBT_AMOUNT (J):=	i_clev_tbl_in(I).UBT_AMOUNT    ;
            In_CREDIT_AMOUNT(J):=	i_clev_tbl_in(I).CREDIT_AMOUNT ;
            In_SUPPRESSED_CREDIT    (J):=	i_clev_tbl_in(I).SUPPRESSED_CREDIT        ;
            In_OVERRIDE_AMOUNT      (J):=	i_clev_tbl_in(I).OVERRIDE_AMOUNT          ;
            In_CUST_PO_NUMBER_REQ_YN(J):=	i_clev_tbl_in(I).CUST_PO_NUMBER_REQ_YN    ;
            In_CUST_PO_NUMBER       (J):=	i_clev_tbl_in(I).CUST_PO_NUMBER;
            In_GRACE_DURATION       (J):=	i_clev_tbl_in(I).GRACE_DURATION;
            In_GRACE_PERIOD (J):=	i_clev_tbl_in(I).GRACE_PERIOD  ;
            In_INV_PRINT_FLAG       (J):=	i_clev_tbl_in(I).INV_PRINT_FLAG;
            In_PRICE_UOM  (J):=	i_clev_tbl_in(I).PRICE_UOM     ;
            In_TAX_AMOUNT (J):=	i_clev_tbl_in(I).TAX_AMOUNT    ;
            In_TAX_INCLUSIVE_YN     (J):=	i_clev_tbl_in(I).TAX_INCLUSIVE_YN         ;
            In_TAX_STATUS (J):=	i_clev_tbl_in(I).TAX_STATUS    ;
            In_TAX_CODE   (J):=	i_clev_tbl_in(I).TAX_CODE      ;
            In_TAX_EXEMPTION_ID     (J):=	i_clev_tbl_in(I).TAX_EXEMPTION_ID         ;
            In_IB_TRANS_TYPE(J):=	i_clev_tbl_in(I).IB_TRANS_TYPE ;
            In_IB_TRANS_DATE(J):=	i_clev_tbl_in(I).IB_TRANS_DATE ;
            In_PROD_PRICE (J):=	i_clev_tbl_in(I).PROD_PRICE    ;
            In_SERVICE_PRICE(J):=	i_clev_tbl_in(I).SERVICE_PRICE ;
            In_CLVL_LIST_PRICE      (J):=	i_clev_tbl_in(I).CLVL_LIST_PRICE          ;
            In_CLVL_QUANTITY(J):=	i_clev_tbl_in(I).CLVL_QUANTITY ;
            In_CLVL_EXTENDED_AMT    (J):=	i_clev_tbl_in(I).CLVL_EXTENDED_AMT        ;
            In_CLVL_UOM_CODE(J):=	i_clev_tbl_in(I).CLVL_UOM_CODE ;
            In_TOPLVL_OPERAND_CODE  (J):=	i_clev_tbl_in(I).TOPLVL_OPERAND_CODE      ;
            In_TOPLVL_OPERAND_VAL   (J):=	i_clev_tbl_in(I).TOPLVL_OPERAND_VAL       ;
            In_TOPLVL_QUANTITY      (J):=	i_clev_tbl_in(I).TOPLVL_QUANTITY          ;
            In_TOPLVL_UOM_CODE      (J):=	i_clev_tbl_in(I).TOPLVL_UOM_CODE          ;
            In_TOPLVL_ADJ_PRICE     (J):=	i_clev_tbl_in(I).TOPLVL_ADJ_PRICE         ;
            In_TOPLVL_PRICE_QTY     (J):=	i_clev_tbl_in(I).TOPLVL_PRICE_QTY         ;
            In_AVERAGING_INTERVAL   (J):=	i_clev_tbl_in(I).AVERAGING_INTERVAL       ;
            In_SETTLEMENT_INTERVAL  (J):=	i_clev_tbl_in(I).SETTLEMENT_INTERVAL      ;
            In_MINIMUM_QUANTITY     (J):=	i_clev_tbl_in(I).MINIMUM_QUANTITY         ;
            In_DEFAULT_QUANTITY     (J):=	i_clev_tbl_in(I).DEFAULT_QUANTITY         ;
            In_AMCV_FLAG  (J):=	i_clev_tbl_in(I).AMCV_FLAG     ;
            In_FIXED_QUANTITY       (J):=	i_clev_tbl_in(I).FIXED_QUANTITY;
            In_USAGE_DURATION       (J):=	i_clev_tbl_in(I).USAGE_DURATION;
            In_USAGE_PERIOD (J):=	i_clev_tbl_in(I).USAGE_PERIOD  ;
            In_LEVEL_YN   (J):=	i_clev_tbl_in(I).LEVEL_YN      ;
            In_USAGE_TYPE (J):=	i_clev_tbl_in(I).USAGE_TYPE    ;
            In_UOM_QUANTIFIED       (J):=	i_clev_tbl_in(I).UOM_QUANTIFIED;
            In_BASE_READING (J):=	i_clev_tbl_in(I).BASE_READING  ;
            In_BILLING_SCHEDULE_TYPE(J):=	i_clev_tbl_in(I).BILLING_SCHEDULE_TYPE    ;
            In_COVERAGE_TYPE(J):=	i_clev_tbl_in(I).COVERAGE_TYPE ;
            In_EXCEPTION_COV_ID     (J):=	i_clev_tbl_in(I).EXCEPTION_COV_ID         ;
            In_LIMIT_UOM_QUANTIFIED (J):=	i_clev_tbl_in(I).LIMIT_UOM_QUANTIFIED     ;
            In_DISCOUNT_AMOUNT      (J):=	i_clev_tbl_in(I).DISCOUNT_AMOUNT          ;
            In_DISCOUNT_PERCENT     (J):=	i_clev_tbl_in(I).DISCOUNT_PERCENT         ;
            In_OFFSET_DURATION      (J):=	i_clev_tbl_in(I).OFFSET_DURATION          ;
            In_OFFSET_PERIOD(J):=	i_clev_tbl_in(I).OFFSET_PERIOD ;
            In_INCIDENT_SEVERITY_ID (J):=	i_clev_tbl_in(I).INCIDENT_SEVERITY_ID     ;
            In_PDF_ID     (J):=	i_clev_tbl_in(I).PDF_ID        ;
            In_WORK_THRU_YN (J):=	i_clev_tbl_in(I).WORK_THRU_YN  ;
            In_REACT_ACTIVE_YN      (J):=	i_clev_tbl_in(I).REACT_ACTIVE_YN          ;
            In_TRANSFER_OPTION      (J):=	i_clev_tbl_in(I).TRANSFER_OPTION          ;
            In_PROD_UPGRADE_YN      (J):=	i_clev_tbl_in(I).PROD_UPGRADE_YN          ;
            In_INHERITANCE_TYPE     (J):=	i_clev_tbl_in(I).INHERITANCE_TYPE         ;
            In_PM_PROGRAM_ID(J):=	i_clev_tbl_in(I).PM_PROGRAM_ID ;
            In_PM_CONF_REQ_YN       (J):=	i_clev_tbl_in(I).PM_CONF_REQ_YN;
            In_PM_SCH_EXISTS_YN     (J):=	i_clev_tbl_in(I).PM_SCH_EXISTS_YN         ;
            In_ALLOW_BT_DISCOUNT    (J):=	i_clev_tbl_in(I).ALLOW_BT_DISCOUNT        ;
            In_APPLY_DEFAULT_TIMEZONE (J):=	i_clev_tbl_in(I).APPLY_DEFAULT_TIMEZONE   ;
            In_SYNC_DATE_INSTALL    (J):=	i_clev_tbl_in(I).SYNC_DATE_INSTALL        ;
            In_OBJECT_VERSION_NUMBER    (J):=	i_clev_tbl_in(I).OBJECT_VERSION_NUMBER   ;
            In_SECURITY_GROUP_ID    (J):=	i_clev_tbl_in(I).SECURITY_GROUP_ID        ;
            In_REQUEST_ID (J):=	i_clev_tbl_in(I).REQUEST_ID    ;
            In_CREATED_BY     (J):=	i_clev_tbl_in(I).CREATED_BY         ;
            In_CREATION_DATE  (J):=	i_clev_tbl_in(I).CREATION_DATE      ;
            In_LAST_UPDATED_BY(J):=	i_clev_tbl_in(I).LAST_UPDATED_BY    ;
            In_LAST_UPDATE_DATE (J):=	i_clev_tbl_in(I).LAST_UPDATE_DATE   ;
            In_LAST_UPDATE_LOGIN    (J):=	i_clev_tbl_in(I).LAST_UPDATE_LOGIN        ;
            In_COMMITMENT_ID(J):=	i_clev_tbl_in(I).COMMITMENT_ID ;
            In_FULL_CREDIT(J):=	i_clev_tbl_in(I).FULL_CREDIT;

                i:=i_clev_tbl_in.next(i);

        END LOOP;
        l_tabsize := i_clev_tbl_in.COUNT;

END IF;

IF l_clet_tbl_in.count > 0 THEN
            i  := l_clet_tbl_in.FIRST; K:=0;
            while i is not null   LOOP
                k:=k+1;

            TLn_ID(K):=	l_clet_tbl_in(I).Id;

            tln_major_version(k) := l_clet_tbl_in(I).major_version;
            tln_language(k) :=l_clet_tbl_in(I).language;
            tln_source_lang(k) :=l_clet_tbl_in(I).source_lang;
            tln_sfwt_flag(k) := l_clet_tbl_in(I).sfwt_flag;
            tln_invoice_text(k) :=NULL ; --l_clet_tbl_in(I).invoice_text;
--            tln_IB_TRX_DETAILS(k):=l_clet_tbl_in(I).IB_TRX_DETAILS;
--            tln_STATUS_TEXT(k):=l_clet_tbl_in(I).STATUS_TEXT;
--            tln_REACT_TIME_NAME(k):=l_clet_tbl_in(I).REACT_TIME_NAME;
--            tln_SECURITY_GROUP_ID(k):=l_clet_tbl_in(I).SECURITY_GROUP_ID;
            tln_created_by(k) :=l_clet_tbl_in(I).created_by;
            tln_creation_date(k) :=l_clet_tbl_in(I).creation_date;
            tln_last_updated_by(k) :=l_clet_tbl_in(I).last_updated_by;
            tln_last_update_date(k) :=l_clet_tbl_in(I).last_update_date;
            tln_last_update_login(k) :=l_clet_tbl_in(I).last_update_login;
                            i:=l_clet_tbl_in.next(i);
            END LOOP;
            l_tabsize2 := l_clet_tbl_in.COUNT;

END IF;


FORALL I IN  1  ..   l_tabsize

            INSERT INTO OKS_K_LINES_BH
            (
                ID,
                MAJOR_VERSION ,
                CLE_ID,
                DNZ_CHR_ID,
                DISCOUNT_LIST ,
                ACCT_RULE_ID,
                PAYMENT_TYPE,
                CC_NO ,
                CC_EXPIRY_DATE,
                CC_BANK_ACCT_ID ,
                CC_AUTH_CODE,
                LOCKED_PRICE_LIST_ID,
                USAGE_EST_YN,
                USAGE_EST_METHOD,
                USAGE_EST_START_DATE,
                TERMN_METHOD,
                UBT_AMOUNT,
                CREDIT_AMOUNT ,
                SUPPRESSED_CREDIT ,
                OVERRIDE_AMOUNT ,
                CUST_PO_NUMBER_REQ_YN ,
                CUST_PO_NUMBER,
                GRACE_DURATION,
                GRACE_PERIOD,
                INV_PRINT_FLAG,
                PRICE_UOM ,
                TAX_AMOUNT,
                TAX_INCLUSIVE_YN,
                TAX_STATUS,
                TAX_CODE,
                TAX_EXEMPTION_ID,
                IB_TRANS_TYPE ,
                IB_TRANS_DATE ,
                PROD_PRICE,
                SERVICE_PRICE ,
                CLVL_LIST_PRICE ,
                CLVL_QUANTITY ,
                CLVL_EXTENDED_AMT ,
                CLVL_UOM_CODE ,
                TOPLVL_OPERAND_CODE ,
                TOPLVL_OPERAND_VAL,
                TOPLVL_QUANTITY ,
                TOPLVL_UOM_CODE ,
                TOPLVL_ADJ_PRICE,
                TOPLVL_PRICE_QTY,
                AVERAGING_INTERVAL,
                SETTLEMENT_INTERVAL ,
                MINIMUM_QUANTITY,
                DEFAULT_QUANTITY,
                AMCV_FLAG ,
                FIXED_QUANTITY,
                USAGE_DURATION,
                USAGE_PERIOD,
                LEVEL_YN,
                USAGE_TYPE,
                UOM_QUANTIFIED,
                BASE_READING,
                BILLING_SCHEDULE_TYPE ,
                COVERAGE_TYPE ,
                EXCEPTION_COV_ID,
                LIMIT_UOM_QUANTIFIED,
                DISCOUNT_AMOUNT ,
                DISCOUNT_PERCENT,
                OFFSET_DURATION ,
                OFFSET_PERIOD ,
                INCIDENT_SEVERITY_ID,
                PDF_ID,
                WORK_THRU_YN,
                REACT_ACTIVE_YN ,
                TRANSFER_OPTION ,
                PROD_UPGRADE_YN ,
                INHERITANCE_TYPE,
                PM_PROGRAM_ID ,
                PM_CONF_REQ_YN,
                PM_SCH_EXISTS_YN,
                ALLOW_BT_DISCOUNT ,
                APPLY_DEFAULT_TIMEZONE,
                SYNC_DATE_INSTALL ,
                OBJECT_VERSION_NUMBER ,
                SECURITY_GROUP_ID ,
                REQUEST_ID,
                CREATED_BY,
                CREATION_DATE ,
                LAST_UPDATED_BY ,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN ,
                COMMITMENT_ID ,
                FULL_CREDIT)

            VALUES
            (
	In_ID(I),
	In_MAJOR_VERSION (I),
	In_CLE_ID(I),
	In_DNZ_CHR_ID(I),
	In_DISCOUNT_LIST (I),
	In_ACCT_RULE_ID(I),
	In_PAYMENT_TYPE(I),
	In_CC_NO (I),
	In_CC_EXPIRY_DATE(I),
	In_CC_BANK_ACCT_ID (I),
	In_CC_AUTH_CODE(I),
	In_LOCKED_PRICE_LIST_ID(I),
	In_USAGE_EST_YN(I),
	In_USAGE_EST_METHOD(I),
	In_USAGE_EST_START_DATE(I),
	In_TERMN_METHOD(I),
	In_UBT_AMOUNT(I),
	In_CREDIT_AMOUNT (I),
	In_SUPPRESSED_CREDIT (I),
	In_OVERRIDE_AMOUNT (I),
	In_CUST_PO_NUMBER_REQ_YN (I),
	In_CUST_PO_NUMBER(I),
	In_GRACE_DURATION(I),
	In_GRACE_PERIOD(I),
	In_INV_PRINT_FLAG(I),
	In_PRICE_UOM (I),
	In_TAX_AMOUNT(I),
	In_TAX_INCLUSIVE_YN(I),
	In_TAX_STATUS(I),
	In_TAX_CODE(I),
	In_TAX_EXEMPTION_ID(I),
	In_IB_TRANS_TYPE (I),
	In_IB_TRANS_DATE (I),
	In_PROD_PRICE(I),
	In_SERVICE_PRICE (I),
	In_CLVL_LIST_PRICE (I),
	In_CLVL_QUANTITY (I),
	In_CLVL_EXTENDED_AMT (I),
	In_CLVL_UOM_CODE (I),
	In_TOPLVL_OPERAND_CODE (I),
	In_TOPLVL_OPERAND_VAL(I),
	In_TOPLVL_QUANTITY (I),
	In_TOPLVL_UOM_CODE (I),
	In_TOPLVL_ADJ_PRICE(I),
	In_TOPLVL_PRICE_QTY(I),
	In_AVERAGING_INTERVAL(I),
	In_SETTLEMENT_INTERVAL (I),
	In_MINIMUM_QUANTITY(I),
	In_DEFAULT_QUANTITY(I),
	In_AMCV_FLAG (I),
	In_FIXED_QUANTITY(I),
	In_USAGE_DURATION(I),
	In_USAGE_PERIOD(I),
	In_LEVEL_YN(I),
	In_USAGE_TYPE(I),
	In_UOM_QUANTIFIED(I),
	In_BASE_READING(I),
	In_BILLING_SCHEDULE_TYPE (I),
	In_COVERAGE_TYPE (I),
	In_EXCEPTION_COV_ID(I),
	In_LIMIT_UOM_QUANTIFIED(I),
	In_DISCOUNT_AMOUNT (I),
	In_DISCOUNT_PERCENT(I),
	In_OFFSET_DURATION (I),
	In_OFFSET_PERIOD (I),
	In_INCIDENT_SEVERITY_ID(I),
	In_PDF_ID(I),
	In_WORK_THRU_YN(I),
	In_REACT_ACTIVE_YN (I),
	In_TRANSFER_OPTION (I),
	In_PROD_UPGRADE_YN (I),
	In_INHERITANCE_TYPE(I),
	In_PM_PROGRAM_ID (I),
	In_PM_CONF_REQ_YN(I),
	In_PM_SCH_EXISTS_YN(I),
	In_ALLOW_BT_DISCOUNT (I),
	In_APPLY_DEFAULT_TIMEZONE(I),
	In_SYNC_DATE_INSTALL (I),
	In_OBJECT_VERSION_NUMBER (I),
	In_SECURITY_GROUP_ID (I),
	In_REQUEST_ID(I),
	In_CREATED_BY(I),
	In_CREATION_DATE (I),
	In_LAST_UPDATED_BY (I),
	In_LAST_UPDATE_DATE(I),
	In_LAST_UPDATE_LOGIN (I),
	In_COMMITMENT_ID (I),
	In_FULL_CREDIT(I));

    IF l_tabsize2 > 0 THEN
            FORALL I IN  1  ..   l_tabsize2

INSERT INTO OKS_K_LINES_TLH(
ID,
MAJOR_VERSION,
LANGUAGE,
SOURCE_LANG,
SFWT_FLAG,
INVOICE_TEXT,
IB_TRX_DETAILS,
STATUS_TEXT,
REACT_TIME_NAME,
SECURITY_GROUP_ID,
CREATED_BY,
CREATION_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATE_LOGIN) VALUES
(
            TLn_ID(I),
            Tln_MAJOR_VERSION(I),
            tln_language(I),
            tln_source_lang(I) ,
            tln_sfwt_flag(I) ,
            tln_invoice_text(I) ,
            NULL,
            NULL,
            NULL,
            NULL,
            tln_created_by(I),
            tln_creation_date(I) ,
            tln_last_updated_by(I) ,
            tln_last_update_date(I) ,
            tln_last_update_login(I) );
END IF;

X_RETURN_STATUS := 'S' ;

EXCEPTION
WHEN OTHERS THEN
        ROLLBACK;

        x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );

         IF x_msg_count > 0              THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
        END IF;

                x_return_status := OKC_API.G_RET_STS_ERROR;
END;


PROCEDURE COVERAGE_HISTORY_MIGRATION (   p_start_rowid   IN ROWID,
                                         p_end_rowid     IN ROWID,
                                         x_return_status OUT NOCOPY VARCHAR2,
                                         x_message_data  OUT NOCOPY VARCHAR2) IS

CURSOR Get_CoverageHist_Rules (l_start_rowid IN ROWID ,l_end_rowid IN ROWID )   IS
    SELECT
        LINE.ID LINE_ID,
        Line.Created_By Line_Created_By,
		Line.Creation_Date		Line_Creation_Date,
        Line.Last_Updated_By    Line_Last_Updated_By,
        Line.Last_Update_Date   Line_Last_Update_Date,
        Line.Last_Update_Login  Line_Last_Update_Login,
        RGP.ID LINE_RGP_ID,
        Rul.RowID  Rul_Row_ID       ,
        Rul.ID  Rule_ID,
        LINE.LSE_ID LINE_LSE_ID,
        LINE.DNZ_CHR_ID LINE_DNZ_CHR_ID,
        OBJECT1_ID1  LINE_OBJECT1_ID1,
        OBJECT2_ID1 LINE_OBJECT2_ID1,
        RULE_INFORMATION1  COV_RULE_INFO1,
        RULE_INFORMATION2  COV_RULE_INFO2,
        RULE_INFORMATION3  COV_RULE_INFO3,
        RULE_INFORMATION4  COV_RULE_INFO4,
        RULE_INFORMATION5  COV_RULE_INFO5,
        RULE_INFORMATION6  COV_RULE_INFO6,
        RULE_INFORMATION7  COV_RULE_INFO7,
        RULE_INFORMATION8  COV_RULE_INFO8,
        RULE_INFORMATION9  COV_RULE_INFO9,
        RULE_INFORMATION10 COV_RULE_INFO10,
        RULE_INFORMATION11 COV_RULE_INFO11,
        RULE_INFORMATION12 COV_RULE_INFO12,
        RULE_INFORMATION13 COV_RULE_INFO13,
        RULE_INFORMATION14 COV_RULE_INFO14,
        RULE_INFORMATION15 COV_RULE_INFO15,
        RULE_INFORMATION_CATEGORY  COV_RULE_INFO,
        RUL.OBJECT_VERSION_NUMBER  COV_OBJ_VER_NUMBER,
        RUL.MAJOR_VERSION MAJOR_VERSION,
        KINE.ID k_line_id
    FROM
       OKC_RULE_GROUPS_BH RGP,
       OKC_RULES_BH RUL,
       OKC_K_LINES_BH LINE,
       OKS_K_LINES_B KINE
  WHERE  LINE.ID = KINE.CLE_ID
  AND    LINE.DNZ_CHR_ID = KINE.DNZ_CHR_ID
  AND    LINE.ID = RGP.CLE_ID
  AND    RGP.ID  = RUL.RGP_ID
  AND    LINE.LSE_ID IN (2,15,20)
 -- AND    RUL.RULE_INFORMATION_CATEGORY IN ('ECE','WHE','UGE','STR','CVE','PMP')
  AND    LINE.DNZ_CHR_ID = RGP.DNZ_CHR_ID
--  AND    RUL.RULE_INFORMATION15 IS NULL
  AND    NOT EXISTS (SELECT CLE_ID FROM OKS_K_LINES_BH WHERE CLE_ID = LINE.ID)
  AND    Rul.rowid BETWEEN l_start_rowid and l_end_rowid
  AND    LINE.major_version = RGP.major_version
  AND    RGP.major_version = RUL.major_version
  ORDER BY LINE.ID,RUL.major_version;

  CURSOR Get_Rule_TlH (P_ID IN NUMBER) IS
    SELECT    ID,
            MAJOR_VERSION,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            COMMENTS,
            TEXT,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            SECURITY_GROUP_ID
    FROM        OKC_RULES_TLH
    WHERE       ID = P_ID;



G_Exception_Halt                Exception;


TYPE RowId_Tbl_Type  IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
TYPE Num_Tbl_Type  IS VARRAY(1000) OF NUMBER;
TYPE Date_Tbl_Type IS VARRAY(1000) OF DATE;
TYPE Vc15_Tbl_Type IS VARRAY(1000) OF VARCHAR2(15);
TYPE Vc20_Tbl_Type IS VARRAY(1000) OF VARCHAR2(20);
TYPE Vc150_Tbl_Type IS VARRAY(1000) OF VARCHAR2(150);
TYPE Vc30_Tbl_Type IS VARRAY(1000) OF VARCHAR2(30);
TYPE Vc1_Tbl_Type IS VARRAY(1000) OF VARCHAR2(1);
TYPE Vc3_Tbl_Type IS VARRAY(1000) OF VARCHAR2(3);
TYPE Vc2000_Tbl_Type IS VARRAY(1000) OF VARCHAR2(2000);
TYPE Vc50_Tbl_Type IS VARRAY(1000) OF VARCHAR2(50);
TYPE Vc80_Tbl_Type IS VARRAY(1000) OF VARCHAR2(80);
TYPE Vc120_Tbl_Type IS VARRAY(1000) OF VARCHAR2(120);
TYPE Vc600_Tbl_Type IS VARRAY(1000) OF VARCHAR2(600);

Rul_Row_ID_TBl              RowId_Tbl_Type;
LINE_ID_TBL                 Num_Tbl_Type;
Line_Created_By_TBL         Num_Tbl_Type;
Line_Creation_Date_TBL		Date_Tbl_Type;
Line_Last_Updated_By_TBL    Num_Tbl_Type;
Line_Last_Update_Date_TBL   Date_Tbl_Type;
Line_Last_Update_Login_TBL  Num_Tbl_Type;
LINE_RGP_ID_TBL             Num_Tbl_Type;
Rule_ID_TBL                 Num_Tbl_Type;
LINE_LSE_ID_TBL             Num_Tbl_Type;
LINE_DNZ_CHR_ID_TBL         Num_Tbl_Type;
LINE_OBJECT1_ID1_TBL        Vc150_Tbl_Type;
LINE_OBJECT2_ID1_TBL        Vc150_Tbl_Type;
COV_RULE_INFO1_TBL         Vc150_Tbl_Type;
COV_RULE_INFO2_TBL         Vc150_Tbl_Type;
COV_RULE_INFO3_TBL         Vc150_Tbl_Type;
COV_RULE_INFO4_TBL         Vc150_Tbl_Type;
COV_RULE_INFO5_TBL         Vc150_Tbl_Type;
COV_RULE_INFO6_TBL         Vc150_Tbl_Type;
COV_RULE_INFO7_TBL         Vc150_Tbl_Type;
COV_RULE_INFO8_TBL         Vc150_Tbl_Type;
COV_RULE_INFO9_TBL         Vc150_Tbl_Type;
COV_RULE_INFO10_TBL         Vc150_Tbl_Type;
COV_RULE_INFO11_TBL         Vc150_Tbl_Type;
COV_RULE_INFO12_TBL         Vc150_Tbl_Type;
COV_RULE_INFO13_TBL         Vc150_Tbl_Type;
COV_RULE_INFO14_TBL         Vc150_Tbl_Type;
COV_RULE_INFO15_TBL         Vc150_Tbl_Type;
COV_RULE_INFO_TBL           Vc150_Tbl_Type;
COV_OBJ_VER_NUMBER_TBL         Num_Tbl_Type;
MAJOR_VERSION_TBL            Num_Tbl_Type;
k_line_id_TBL         Num_Tbl_Type;


l_cle_ctr                   NUMBER := 0;
tablename1                  VArchar2(1000);
x_msg_count                 NUMBER := 0;
x_msg_data                 VArchar2(1000);
L_OLD_CLE_ID                NUMBER  := -99999;
L_CLE_ID                    NUMBER  := -99999;
l_duration                  NUMBER;
l_period                    VArchar2(10);
l_return_status             VArchar2(1) := OKC_API.G_RET_STS_SUCCESS;
l_transfer_option           VArchar2(250);
l_msg_index_out             NUMBER;

l_start_rowid       ROWID := p_start_rowid;
l_end_rowid         ROWID := p_end_rowid;

  l_tabsize NUMBER := i_clev_tbl_in.COUNT;
  l_tabsize2 NUMBER;
  I NUMBER;
  J NUMBER;
  K NUMBER;

  l_clt_ctr NUMBER := 0;


l_old_line_id NUMBER :=  -9999;
l_line_id NUMBER;
/****************************************************/
PROCEDURE   get_duration_period(p_id IN NUMBER,
                                x_duration  OUT NOCOPY NUMBER,
                                x_period    OUT NOCOPY VARCHAR2) IS

CURSOR get_duration (l_ID IN NUMBER) IS
SELECT UOM_CODE,Duration
FROM   OKC_TIMEVALUES_V
WHERE  id  = l_id;

Lx_Duration NUMBER := NULL;
Lx_Period   VARCHAR2(100) := NULL;

BEGIN

FOR get_duration_Rec in get_duration(p_id) LOOP

Lx_period := get_duration_Rec.uom_code;
Lx_duration   := get_duration_Rec.Duration;

END LOOP;

X_duration := Lx_duration;
X_Period :=Lx_Period;

EXCEPTION
WHEN OTHERS THEN
   OKC_API.SET_MESSAGE
    (P_App_Name	  => G_APP_NAME_OKS
	,P_Msg_Name	  => G_UNEXPECTED_ERROR
	,P_Token1	  => G_SQLCODE_TOKEN
	,P_Token1_Value	  => SQLCODE
	,P_Token2	  => G_SQLERRM_TOKEN
	,P_Token2_Value   => SQLERRM);
END;

BEGIN

G_APP_NAME := 'Coverage_History_migration';
OPEN Get_CoverageHist_Rules (l_start_rowid,l_end_rowid);
LOOP
    BEGIN
    i_clev_tbl_in.DELETE;
    l_clet_tbl_in.DELETE;
    FETCH Get_CoverageHist_Rules BULK COLLECT INTO

            LINE_ID_TBL                 ,
            Line_Created_By_TBL         ,
			Line_Creation_Date_TBL		,
            Line_Last_Updated_By_TBL    ,
            Line_Last_Update_Date_TBL   ,
            Line_Last_Update_Login_TBL  ,
            LINE_RGP_ID_TBL             ,
            Rul_Row_ID_TBl              ,
            Rule_Id_Tbl                 ,
            LINE_LSE_ID_TBL             ,
            LINE_DNZ_CHR_ID_TBL         ,
            LINE_OBJECT1_ID1_TBL        ,
            LINE_OBJECT2_ID1_TBL        ,
            COV_RULE_INFO1_TBL         ,
            COV_RULE_INFO2_TBL         ,
            COV_RULE_INFO3_TBL         ,
            COV_RULE_INFO4_TBL         ,
            COV_RULE_INFO5_TBL         ,
            COV_RULE_INFO6_TBL         ,
            COV_RULE_INFO7_TBL         ,
            COV_RULE_INFO8_TBL         ,
            COV_RULE_INFO9_TBL         ,
            COV_RULE_INFO10_TBL         ,
            COV_RULE_INFO11_TBL         ,
            COV_RULE_INFO12_TBL         ,
            COV_RULE_INFO13_TBL         ,
            COV_RULE_INFO14_TBL         ,
            COV_RULE_INFO15_TBL         ,
            COV_RULE_INFO_TBL           ,
            COV_OBJ_VER_NUMBER_TBL,
            MAJOR_VERSION_TBL,
            k_line_id_TBL
            LIMIT 1000;--20;

         -- dbms_output.put_line('Value of LINE_ID_TBL.COUNT='||TO_CHAR(LINE_ID_TBL.COUNT));

        IF LINE_ID_TBL.COUNT > 0 THEN

--        remove dbms

            FOR I IN LINE_ID_TBL.FIRST .. LINE_ID_TBL.LAST LOOP
            L_Cle_id := LINE_ID_TBL(i);

            IF (L_OLD_CLE_ID <> L_CLE_ID) THEN
                l_cle_ctr := l_cle_ctr + 1;

            i_clev_tbl_in(l_cle_ctr).id := k_line_id_TBL(i);
            l_line_id := LINE_ID_TBL(i);
             -- dbms_output.put_line('Value of l_line_id='||TO_CHAR(l_line_id));

            i_clev_tbl_in(l_cle_ctr).Created_By   := Line_Created_By_TBL(i);
            i_clev_tbl_in(l_cle_ctr).Creation_Date   := Line_Creation_date_TBL(i);
            i_clev_tbl_in(l_cle_ctr).Last_Updated_By   := Line_Last_Updated_By_TBL(i);
            i_clev_tbl_in(l_cle_ctr).Last_Update_Date   := Line_Last_Update_Date_TBL(i);
            i_clev_tbl_in(l_cle_ctr).Last_Update_Login  := Line_Last_Update_Login_TBL(i);
            i_clev_tbl_in(l_cle_ctr).Cle_Id         :=  LINE_ID_TBL(i);
            i_clev_tbl_in(l_cle_ctr).Dnz_Chr_Id         :=  LINE_DNZ_CHR_ID_TBL(i);
            i_clev_tbl_in(l_cle_ctr).object_version_number :=  MAJOR_VERSION_TBL(i);--1;
            i_clev_tbl_in(l_cle_ctr).Sync_Date_Install :=  'N';

            END IF;

            IF   COV_RULE_INFO_TBL(i) = 'CVE' THEN
                i_clev_tbl_in(l_cle_ctr).Coverage_Type := COV_RULE_INFO1_TBL(i);--'G';
            END IF;

            IF   COV_RULE_INFO_TBL(i) = 'STR' THEN
                IF COV_RULE_INFO1_TBL(i) = 'Y' THEN
                    i_clev_tbl_in(l_cle_ctr).TRANSFER_OPTION  := 'TRANS';
                ELSE
                    i_clev_tbl_in(l_cle_ctr).TRANSFER_OPTION  :=  'NO_CHANGE';
                END IF;

            END IF;


            IF   COV_RULE_INFO_TBL(i) = 'UGE' THEN
                i_clev_tbl_in(l_cle_ctr).Prod_Upgrade_YN := COV_RULE_INFO1_TBL(i);--'N';
            END IF;


            IF COV_RULE_INFO_TBL(i) = 'ECE' THEN
                i_clev_tbl_in(l_cle_ctr).EXCEPTION_COV_ID   :=  COV_RULE_INFO1_TBL(i);
            END IF;

            IF COV_RULE_INFO_TBL(i) = 'WHE' THEN
                i_clev_tbl_in(l_cle_ctr).Prod_Upgrade_YN := COV_RULE_INFO1_TBL(i);
            END IF;

            IF COV_RULE_INFO_TBL(i) = 'PMP' THEN

                i_clev_tbl_in(l_cle_ctr).PM_PROGRAM_ID      := LINE_OBJECT1_ID1_TBL(i);
                i_clev_tbl_in(l_cle_ctr).PM_CONF_REQ_YN     := COV_RULE_INFO1_TBL(i);
                i_clev_tbl_in(l_cle_ctr).PM_SCH_EXISTS_YN   := COV_RULE_INFO2_TBL(i);

            END IF;

        -------------------------            FOR TLH-----------------------
        IF  l_line_id <> l_old_line_id THEN
         -- dbms_output.put_line('--->Value of Rule_Id_Tbl(l_cle_ctr)='||TO_CHAR(Rule_Id_Tbl(l_cle_ctr)));
        FOR Get_Rule_TlH_REC IN Get_Rule_TlH(Rule_Id_Tbl(l_cle_ctr))  LOOP
        l_clt_ctr := l_clt_ctr + 1;
         -- dbms_output.put_line('---------->l_clt_ctr='||TO_CHAR(l_clt_ctr));
            l_clet_tbl_in(l_clt_ctr).id                 :=  i_clev_tbl_in(l_cle_ctr).id;
            l_clet_tbl_in(l_clt_ctr).MAJOR_VERSION      := Get_Rule_TlH_REC.MAJOR_VERSION;
            l_clet_tbl_in(l_clt_ctr).language           :=  Get_Rule_TlH_REC.language;
            l_clet_tbl_in(l_clt_ctr).source_lang        :=  Get_Rule_TlH_REC.source_lang;
            l_clet_tbl_in(l_clt_ctr).sfwt_flag          :=  Get_Rule_TlH_REC.sfwt_flag;
            l_clet_tbl_in(l_clt_ctr).invoice_text       := NULL;--  Get_Rule_TlH_REC.text;
  --            l_clet_tbl_in(l_clt_ctr).ib_trx_details     :=  Get_Rule_TlH_REC.ib_trx_details;
  --          l_clet_tbl_in(l_clt_ctr).status_text        :=  Get_Rule_TlH_REC.status_text;
  --          l_clet_tbl_in(l_clt_ctr).react_time_name    :=  Get_Rule_TlH_REC.react_time_name;
            l_clet_tbl_in(l_clt_ctr).created_by         :=  Get_Rule_TlH_REC.created_by;
            l_clet_tbl_in(l_clt_ctr).creation_date      :=  Get_Rule_TlH_REC.creation_date;
            l_clet_tbl_in(l_clt_ctr).last_updated_by    :=  Get_Rule_TlH_REC.last_updated_by;
            l_clet_tbl_in(l_clt_ctr).last_update_date   :=  Get_Rule_TlH_REC.last_update_date;
            l_clet_tbl_in(l_clt_ctr).last_update_login  :=  Get_Rule_TlH_REC.last_update_login;

        END LOOP;
        l_old_line_id := l_line_id;
         -- dbms_output.put_line('Value of l_old_line_id='||TO_CHAR(l_old_line_id));
        END IF;
        --------------------------------------------------------------------

            L_OLD_CLE_ID := L_CLE_ID;
            END LOOP;
        END IF;

         tablename1 := 'OKS_K_LINES';
             -- dbms_output.put_line('Value of i_clev_tbl_in.countBefore Insert '||TO_CHAR(i_clev_tbl_in.count));

    IF i_clev_tbl_in.count > 0 THEN
        i  := i_clev_tbl_in.FIRST; j:=0;
        while i is not null   LOOP
            j:=j+1;

            In_ID(J):=	i_clev_tbl_in(I).Id;
            In_MAJOR_VERSION  (J):=	i_clev_tbl_in(I).object_version_number;
            In_CLE_ID (J):=	i_clev_tbl_in(I).CLE_ID  ;
            In_DNZ_CHR_ID     (J):=	i_clev_tbl_in(I).DNZ_CHR_ID         ;
            In_DISCOUNT_LIST(J):=	i_clev_tbl_in(I).DISCOUNT_LIST ;
            In_ACCT_RULE_ID (J):=	i_clev_tbl_in(I).ACCT_RULE_ID  ;
            In_PAYMENT_TYPE (J):=	i_clev_tbl_in(I).PAYMENT_TYPE  ;
            In_CC_NO      (J):=	i_clev_tbl_in(I).CC_NO         ;
            In_CC_EXPIRY_DATE       (J):=	i_clev_tbl_in(I).CC_EXPIRY_DATE;
            In_CC_BANK_ACCT_ID      (J):=	i_clev_tbl_in(I).CC_BANK_ACCT_ID          ;
            In_CC_AUTH_CODE (J):=	i_clev_tbl_in(I).CC_AUTH_CODE  ;
            In_LOCKED_PRICE_LIST_ID (J):=	i_clev_tbl_in(I).LOCKED_PRICE_LIST_ID     ;
            In_USAGE_EST_YN (J):=	i_clev_tbl_in(I).USAGE_EST_YN  ;
            In_USAGE_EST_METHOD     (J):=	i_clev_tbl_in(I).USAGE_EST_METHOD         ;
            In_USAGE_EST_START_DATE (J):=	i_clev_tbl_in(I).USAGE_EST_START_DATE     ;
            In_TERMN_METHOD (J):=	i_clev_tbl_in(I).TERMN_METHOD  ;
            In_UBT_AMOUNT (J):=	i_clev_tbl_in(I).UBT_AMOUNT    ;
            In_CREDIT_AMOUNT(J):=	i_clev_tbl_in(I).CREDIT_AMOUNT ;
            In_SUPPRESSED_CREDIT    (J):=	i_clev_tbl_in(I).SUPPRESSED_CREDIT        ;
            In_OVERRIDE_AMOUNT      (J):=	i_clev_tbl_in(I).OVERRIDE_AMOUNT          ;
            In_CUST_PO_NUMBER_REQ_YN(J):=	i_clev_tbl_in(I).CUST_PO_NUMBER_REQ_YN    ;
            In_CUST_PO_NUMBER       (J):=	i_clev_tbl_in(I).CUST_PO_NUMBER;
            In_GRACE_DURATION       (J):=	i_clev_tbl_in(I).GRACE_DURATION;
            In_GRACE_PERIOD (J):=	i_clev_tbl_in(I).GRACE_PERIOD  ;
            In_INV_PRINT_FLAG       (J):=	i_clev_tbl_in(I).INV_PRINT_FLAG;
            In_PRICE_UOM  (J):=	i_clev_tbl_in(I).PRICE_UOM     ;
            In_TAX_AMOUNT (J):=	i_clev_tbl_in(I).TAX_AMOUNT    ;
            In_TAX_INCLUSIVE_YN     (J):=	i_clev_tbl_in(I).TAX_INCLUSIVE_YN         ;
            In_TAX_STATUS (J):=	i_clev_tbl_in(I).TAX_STATUS    ;
            In_TAX_CODE   (J):=	i_clev_tbl_in(I).TAX_CODE      ;
            In_TAX_EXEMPTION_ID     (J):=	i_clev_tbl_in(I).TAX_EXEMPTION_ID         ;
            In_IB_TRANS_TYPE(J):=	i_clev_tbl_in(I).IB_TRANS_TYPE ;
            In_IB_TRANS_DATE(J):=	i_clev_tbl_in(I).IB_TRANS_DATE ;
            In_PROD_PRICE (J):=	i_clev_tbl_in(I).PROD_PRICE    ;
            In_SERVICE_PRICE(J):=	i_clev_tbl_in(I).SERVICE_PRICE ;
            In_CLVL_LIST_PRICE      (J):=	i_clev_tbl_in(I).CLVL_LIST_PRICE          ;
            In_CLVL_QUANTITY(J):=	i_clev_tbl_in(I).CLVL_QUANTITY ;
            In_CLVL_EXTENDED_AMT    (J):=	i_clev_tbl_in(I).CLVL_EXTENDED_AMT        ;
            In_CLVL_UOM_CODE(J):=	i_clev_tbl_in(I).CLVL_UOM_CODE ;
            In_TOPLVL_OPERAND_CODE  (J):=	i_clev_tbl_in(I).TOPLVL_OPERAND_CODE      ;
            In_TOPLVL_OPERAND_VAL   (J):=	i_clev_tbl_in(I).TOPLVL_OPERAND_VAL       ;
            In_TOPLVL_QUANTITY      (J):=	i_clev_tbl_in(I).TOPLVL_QUANTITY          ;
            In_TOPLVL_UOM_CODE      (J):=	i_clev_tbl_in(I).TOPLVL_UOM_CODE          ;
            In_TOPLVL_ADJ_PRICE     (J):=	i_clev_tbl_in(I).TOPLVL_ADJ_PRICE         ;
            In_TOPLVL_PRICE_QTY     (J):=	i_clev_tbl_in(I).TOPLVL_PRICE_QTY         ;
            In_AVERAGING_INTERVAL   (J):=	i_clev_tbl_in(I).AVERAGING_INTERVAL       ;
            In_SETTLEMENT_INTERVAL  (J):=	i_clev_tbl_in(I).SETTLEMENT_INTERVAL      ;
            In_MINIMUM_QUANTITY     (J):=	i_clev_tbl_in(I).MINIMUM_QUANTITY         ;
            In_DEFAULT_QUANTITY     (J):=	i_clev_tbl_in(I).DEFAULT_QUANTITY         ;
            In_AMCV_FLAG  (J):=	i_clev_tbl_in(I).AMCV_FLAG     ;
            In_FIXED_QUANTITY       (J):=	i_clev_tbl_in(I).FIXED_QUANTITY;
            In_USAGE_DURATION       (J):=	i_clev_tbl_in(I).USAGE_DURATION;
            In_USAGE_PERIOD (J):=	i_clev_tbl_in(I).USAGE_PERIOD  ;
            In_LEVEL_YN   (J):=	i_clev_tbl_in(I).LEVEL_YN      ;
            In_USAGE_TYPE (J):=	i_clev_tbl_in(I).USAGE_TYPE    ;
            In_UOM_QUANTIFIED       (J):=	i_clev_tbl_in(I).UOM_QUANTIFIED;
            In_BASE_READING (J):=	i_clev_tbl_in(I).BASE_READING  ;
            In_BILLING_SCHEDULE_TYPE(J):=	i_clev_tbl_in(I).BILLING_SCHEDULE_TYPE    ;
            In_COVERAGE_TYPE(J):=	i_clev_tbl_in(I).COVERAGE_TYPE ;
            In_EXCEPTION_COV_ID     (J):=	i_clev_tbl_in(I).EXCEPTION_COV_ID         ;
            In_LIMIT_UOM_QUANTIFIED (J):=	i_clev_tbl_in(I).LIMIT_UOM_QUANTIFIED     ;
            In_DISCOUNT_AMOUNT      (J):=	i_clev_tbl_in(I).DISCOUNT_AMOUNT          ;
            In_DISCOUNT_PERCENT     (J):=	i_clev_tbl_in(I).DISCOUNT_PERCENT         ;
            In_OFFSET_DURATION      (J):=	i_clev_tbl_in(I).OFFSET_DURATION          ;
            In_OFFSET_PERIOD(J):=	i_clev_tbl_in(I).OFFSET_PERIOD ;
            In_INCIDENT_SEVERITY_ID (J):=	i_clev_tbl_in(I).INCIDENT_SEVERITY_ID     ;
            In_PDF_ID     (J):=	i_clev_tbl_in(I).PDF_ID        ;
            In_WORK_THRU_YN (J):=	i_clev_tbl_in(I).WORK_THRU_YN  ;
            In_REACT_ACTIVE_YN      (J):=	i_clev_tbl_in(I).REACT_ACTIVE_YN          ;
            In_TRANSFER_OPTION      (J):=	i_clev_tbl_in(I).TRANSFER_OPTION          ;
            In_PROD_UPGRADE_YN      (J):=	i_clev_tbl_in(I).PROD_UPGRADE_YN          ;
            In_INHERITANCE_TYPE     (J):=	i_clev_tbl_in(I).INHERITANCE_TYPE         ;
            In_PM_PROGRAM_ID(J):=	i_clev_tbl_in(I).PM_PROGRAM_ID ;
            In_PM_CONF_REQ_YN       (J):=	i_clev_tbl_in(I).PM_CONF_REQ_YN;
            In_PM_SCH_EXISTS_YN     (J):=	i_clev_tbl_in(I).PM_SCH_EXISTS_YN         ;
            In_ALLOW_BT_DISCOUNT    (J):=	i_clev_tbl_in(I).ALLOW_BT_DISCOUNT        ;
            In_APPLY_DEFAULT_TIMEZONE (J):=	i_clev_tbl_in(I).APPLY_DEFAULT_TIMEZONE   ;
            In_SYNC_DATE_INSTALL    (J):=	i_clev_tbl_in(I).SYNC_DATE_INSTALL        ;
            In_OBJECT_VERSION_NUMBER    (J):=	i_clev_tbl_in(I).OBJECT_VERSION_NUMBER   ;
            In_SECURITY_GROUP_ID    (J):=	i_clev_tbl_in(I).SECURITY_GROUP_ID        ;
            In_REQUEST_ID (J):=	i_clev_tbl_in(I).REQUEST_ID    ;
            In_CREATED_BY     (J):=	i_clev_tbl_in(I).CREATED_BY         ;
            In_CREATION_DATE  (J):=	i_clev_tbl_in(I).CREATION_DATE      ;
            In_LAST_UPDATED_BY(J):=	i_clev_tbl_in(I).LAST_UPDATED_BY    ;
            In_LAST_UPDATE_DATE (J):=	i_clev_tbl_in(I).LAST_UPDATE_DATE   ;
            In_LAST_UPDATE_LOGIN    (J):=	i_clev_tbl_in(I).LAST_UPDATE_LOGIN        ;
            In_COMMITMENT_ID(J):=	i_clev_tbl_in(I).COMMITMENT_ID ;
            In_FULL_CREDIT(J):=	i_clev_tbl_in(I).FULL_CREDIT;

                i:=i_clev_tbl_in.next(i);

        END LOOP;

        IF l_clet_tbl_in.count > 0 THEN
            i  := l_clet_tbl_in.FIRST; K:=0;
            while i is not null   LOOP
                k:=k+1;

            TLn_ID(K):=	l_clet_tbl_in(I).Id;

            tln_major_version(k) := l_clet_tbl_in(I).major_version;
            tln_language(k) :=l_clet_tbl_in(I).language;
            tln_source_lang(k) :=l_clet_tbl_in(I).source_lang;
            tln_sfwt_flag(k) := l_clet_tbl_in(I).sfwt_flag;
            tln_invoice_text(k) := NULL; --l_clet_tbl_in(I).invoice_text;
--            tln_IB_TRX_DETAILS(k):=l_clet_tbl_in(I).IB_TRX_DETAILS;
--            tln_STATUS_TEXT(k):=l_clet_tbl_in(I).STATUS_TEXT;
--            tln_REACT_TIME_NAME(k):=l_clet_tbl_in(I).REACT_TIME_NAME;
--            tln_SECURITY_GROUP_ID(k):=l_clet_tbl_in(I).SECURITY_GROUP_ID;
            tln_created_by(k) :=l_clet_tbl_in(I).created_by;
            tln_creation_date(k) :=l_clet_tbl_in(I).creation_date;
            tln_last_updated_by(k) :=l_clet_tbl_in(I).last_updated_by;
            tln_last_update_date(k) :=l_clet_tbl_in(I).last_update_date;
            tln_last_update_login(k) :=l_clet_tbl_in(I).last_update_login;
                            i:=l_clet_tbl_in.next(i);
            END LOOP;
                l_tabsize2 := l_clet_tbl_in.COUNT;

        END IF;

               l_tabsize := i_clev_tbl_in.COUNT;
              -- dbms_output.put_line('Value of l_tabsize='||TO_CHAR(l_tabsize));
            FORALL I IN  1  ..   l_tabsize

            INSERT INTO OKS_K_LINES_BH
            (
                ID,
                MAJOR_VERSION ,
                CLE_ID,
                DNZ_CHR_ID,
                DISCOUNT_LIST ,
                ACCT_RULE_ID,
                PAYMENT_TYPE,
                CC_NO ,
                CC_EXPIRY_DATE,
                CC_BANK_ACCT_ID ,
                CC_AUTH_CODE,
                LOCKED_PRICE_LIST_ID,
                USAGE_EST_YN,
                USAGE_EST_METHOD,
                USAGE_EST_START_DATE,
                TERMN_METHOD,
                UBT_AMOUNT,
                CREDIT_AMOUNT ,
                SUPPRESSED_CREDIT ,
                OVERRIDE_AMOUNT ,
                CUST_PO_NUMBER_REQ_YN ,
                CUST_PO_NUMBER,
                GRACE_DURATION,
                GRACE_PERIOD,
                INV_PRINT_FLAG,
                PRICE_UOM ,
                TAX_AMOUNT,
                TAX_INCLUSIVE_YN,
                TAX_STATUS,
                TAX_CODE,
                TAX_EXEMPTION_ID,
                IB_TRANS_TYPE ,
                IB_TRANS_DATE ,
                PROD_PRICE,
                SERVICE_PRICE ,
                CLVL_LIST_PRICE ,
                CLVL_QUANTITY ,
                CLVL_EXTENDED_AMT ,
                CLVL_UOM_CODE ,
                TOPLVL_OPERAND_CODE ,
                TOPLVL_OPERAND_VAL,
                TOPLVL_QUANTITY ,
                TOPLVL_UOM_CODE ,
                TOPLVL_ADJ_PRICE,
                TOPLVL_PRICE_QTY,
                AVERAGING_INTERVAL,
                SETTLEMENT_INTERVAL ,
                MINIMUM_QUANTITY,
                DEFAULT_QUANTITY,
                AMCV_FLAG ,
                FIXED_QUANTITY,
                USAGE_DURATION,
                USAGE_PERIOD,
                LEVEL_YN,
                USAGE_TYPE,
                UOM_QUANTIFIED,
                BASE_READING,
                BILLING_SCHEDULE_TYPE ,
                COVERAGE_TYPE ,
                EXCEPTION_COV_ID,
                LIMIT_UOM_QUANTIFIED,
                DISCOUNT_AMOUNT ,
                DISCOUNT_PERCENT,
                OFFSET_DURATION ,
                OFFSET_PERIOD ,
                INCIDENT_SEVERITY_ID,
                PDF_ID,
                WORK_THRU_YN,
                REACT_ACTIVE_YN ,
                TRANSFER_OPTION ,
                PROD_UPGRADE_YN ,
                INHERITANCE_TYPE,
                PM_PROGRAM_ID ,
                PM_CONF_REQ_YN,
                PM_SCH_EXISTS_YN,
                ALLOW_BT_DISCOUNT ,
                APPLY_DEFAULT_TIMEZONE,
                SYNC_DATE_INSTALL ,
                OBJECT_VERSION_NUMBER ,
                SECURITY_GROUP_ID ,
                REQUEST_ID,
                CREATED_BY,
                CREATION_DATE ,
                LAST_UPDATED_BY ,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN ,
                COMMITMENT_ID ,
                FULL_CREDIT)

            VALUES
            (
	In_ID(I),
	In_MAJOR_VERSION (I),
	In_CLE_ID(I),
	In_DNZ_CHR_ID(I),
	In_DISCOUNT_LIST (I),
	In_ACCT_RULE_ID(I),
	In_PAYMENT_TYPE(I),
	In_CC_NO (I),
	In_CC_EXPIRY_DATE(I),
	In_CC_BANK_ACCT_ID (I),
	In_CC_AUTH_CODE(I),
	In_LOCKED_PRICE_LIST_ID(I),
	In_USAGE_EST_YN(I),
	In_USAGE_EST_METHOD(I),
	In_USAGE_EST_START_DATE(I),
	In_TERMN_METHOD(I),
	In_UBT_AMOUNT(I),
	In_CREDIT_AMOUNT (I),
	In_SUPPRESSED_CREDIT (I),
	In_OVERRIDE_AMOUNT (I),
	In_CUST_PO_NUMBER_REQ_YN (I),
	In_CUST_PO_NUMBER(I),
	In_GRACE_DURATION(I),
	In_GRACE_PERIOD(I),
	In_INV_PRINT_FLAG(I),
	In_PRICE_UOM (I),
	In_TAX_AMOUNT(I),
	In_TAX_INCLUSIVE_YN(I),
	In_TAX_STATUS(I),
	In_TAX_CODE(I),
	In_TAX_EXEMPTION_ID(I),
	In_IB_TRANS_TYPE (I),
	In_IB_TRANS_DATE (I),
	In_PROD_PRICE(I),
	In_SERVICE_PRICE (I),
	In_CLVL_LIST_PRICE (I),
	In_CLVL_QUANTITY (I),
	In_CLVL_EXTENDED_AMT (I),
	In_CLVL_UOM_CODE (I),
	In_TOPLVL_OPERAND_CODE (I),
	In_TOPLVL_OPERAND_VAL(I),
	In_TOPLVL_QUANTITY (I),
	In_TOPLVL_UOM_CODE (I),
	In_TOPLVL_ADJ_PRICE(I),
	In_TOPLVL_PRICE_QTY(I),
	In_AVERAGING_INTERVAL(I),
	In_SETTLEMENT_INTERVAL (I),
	In_MINIMUM_QUANTITY(I),
	In_DEFAULT_QUANTITY(I),
	In_AMCV_FLAG (I),
	In_FIXED_QUANTITY(I),
	In_USAGE_DURATION(I),
	In_USAGE_PERIOD(I),
	In_LEVEL_YN(I),
	In_USAGE_TYPE(I),
	In_UOM_QUANTIFIED(I),
	In_BASE_READING(I),
	In_BILLING_SCHEDULE_TYPE (I),
	In_COVERAGE_TYPE (I),
	In_EXCEPTION_COV_ID(I),
	In_LIMIT_UOM_QUANTIFIED(I),
	In_DISCOUNT_AMOUNT (I),
	In_DISCOUNT_PERCENT(I),
	In_OFFSET_DURATION (I),
	In_OFFSET_PERIOD (I),
	In_INCIDENT_SEVERITY_ID(I),
	In_PDF_ID(I),
	In_WORK_THRU_YN(I),
	In_REACT_ACTIVE_YN (I),
	In_TRANSFER_OPTION (I),
	In_PROD_UPGRADE_YN (I),
	In_INHERITANCE_TYPE(I),
	In_PM_PROGRAM_ID (I),
	In_PM_CONF_REQ_YN(I),
	In_PM_SCH_EXISTS_YN(I),
	In_ALLOW_BT_DISCOUNT (I),
	In_APPLY_DEFAULT_TIMEZONE(I),
	In_SYNC_DATE_INSTALL (I),
	In_OBJECT_VERSION_NUMBER (I),
	In_SECURITY_GROUP_ID (I),
	In_REQUEST_ID(I),
	In_CREATED_BY(I),
	In_CREATION_DATE (I),
	In_LAST_UPDATED_BY (I),
	In_LAST_UPDATE_DATE(I),
	In_LAST_UPDATE_LOGIN (I),
	In_COMMITMENT_ID (I),
	In_FULL_CREDIT(I));

    IF l_tabsize2 > 0 THEN
            FORALL I IN  1  ..   l_tabsize2

            INSERT INTO OKS_K_LINES_TLH
            (
ID,
MAJOR_VERSION,
LANGUAGE,
SOURCE_LANG,
SFWT_FLAG,
INVOICE_TEXT,
IB_TRX_DETAILS,
STATUS_TEXT,
REACT_TIME_NAME,
SECURITY_GROUP_ID,
CREATED_BY,
CREATION_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATE_LOGIN) VALUES
(
            TLn_ID(I),
            Tln_MAJOR_VERSION(I),
            tln_language(I),
            tln_source_lang(I) ,
            tln_sfwt_flag(I) ,
            tln_invoice_text(I) ,
            NULL,
            NULL,
            NULL,
            NULL,
            tln_created_by(I),
            tln_creation_date(I) ,
            tln_last_updated_by(I) ,
            tln_last_update_date(I) ,
            tln_last_update_login(I) );
        END IF;

END IF;
                        x_return_status := 'S';



EXCEPTION
    WHEN G_EXCEPTION_HALT THEN
 -- dbms_output.put_line('Value of 1 ERROR '||SQLERRM);
    ROLLBACK;

    OKC_API.SET_MESSAGE
    (     p_app_name        => G_APP_NAME,
          p_msg_name        => G_UNEXPECTED_ERROR,
          p_token1          => G_SQLCODE_TOKEN,
          p_token1_value    => SQLCODE,
          p_token2          => G_SQLERRM_TOKEN,
          p_token2_value    => SQLERRM
    );
                x_return_status := 'E';
    WHEN Others THEN
 -- dbms_output.put_line('Value of 2 ERROR '||SQLERRM);

    x_return_status := OKC_API.G_RET_STS_ERROR;

    OKC_API.SET_MESSAGE
    (     p_app_name        => G_APP_NAME,
          p_msg_name        => G_UNEXPECTED_ERROR,
          p_token1          => G_SQLCODE_TOKEN,
          p_token1_value    => SQLCODE,
          p_token2          => G_SQLERRM_TOKEN,
          p_token2_value    => SQLERRM
    );

                x_return_status := 'E';

    END;

EXIT WHEN Get_CoverageHist_Rules%NOTFOUND;

END LOOP;

CLOSE Get_CoverageHist_Rules;


EXCEPTION
    WHEN Others THEN

    x_return_status := OKC_API.G_RET_STS_ERROR;

    OKC_API.SET_MESSAGE
        ( p_app_name        => G_APP_NAME,
          p_msg_name        => G_UNEXPECTED_ERROR,
          p_token1          => G_SQLCODE_TOKEN,
          p_token1_value    => SQLCODE,
          p_token2          => G_SQLERRM_TOKEN,
          p_token2_value    => SQLERRM
        );
                x_return_status := 'E';

END COVERAGE_HISTORY_MIGRATION;


PROCEDURE Buss_Proc_History_migration(p_start_rowid IN ROWID,p_end_rowid IN ROWID,x_return_status OUT NOCOPY VARCHAR2,
x_message_data  OUT NOCOPY VARCHAR2) IS

CURSOR Get_Buss_Process_Cur (l_start_rowid IN ROWID ,l_end_rowid IN ROWID ) IS
    SELECT
        LINE.ID LINE_ID,
        Line.Created_By Line_Created_By,
		Line.Creation_Date		Line_Creation_Date,
        Line.Last_Updated_By    Line_Last_Updated_By,
        Line.Last_Update_Date   Line_Last_Update_Date,
        Line.Last_Update_Login  Line_Last_Update_Login,
        Rul.ID  Rule_Id,
        RGP.ID LINE_RGP_ID,
        Rul.RowId   Rul_Row_Id,
        LINE.LSE_ID LINE_LSE_ID,
        LINE.DNZ_CHR_ID LINE_DNZ_CHR_ID,
        OBJECT1_ID1  LINE_OBJECT1_ID1,
        OBJECT2_ID1 LINE_OBJECT2_ID1,
        RULE_INFORMATION1  COV_RULE_INFO1,
        RULE_INFORMATION2  COV_RULE_INFO2,
        RULE_INFORMATION3  COV_RULE_INFO3,
        RULE_INFORMATION4  COV_RULE_INFO4,
        RULE_INFORMATION5  COV_RULE_INFO5,
        RULE_INFORMATION6  COV_RULE_INFO6,
        RULE_INFORMATION7  COV_RULE_INFO7,
        RULE_INFORMATION8  COV_RULE_INFO8,
        RULE_INFORMATION9  COV_RULE_INFO9,
        RULE_INFORMATION10 COV_RULE_INFO10,
        RULE_INFORMATION11 COV_RULE_INFO11,
        RULE_INFORMATION12 COV_RULE_INFO12,
        RULE_INFORMATION13 COV_RULE_INFO13,
        RULE_INFORMATION14 COV_RULE_INFO14,
        RULE_INFORMATION15 COV_RULE_INFO15,
        RULE_INFORMATION_CATEGORY  COV_RULE_INFO,
        RUL.OBJECT_VERSION_NUMBER  COV_OBJ_VER_NUMBER,
        RUL.MAJOR_VERSION MAJOR_VERSION,
        KINE.ID k_line_id
    FROM
       OKC_RULE_GROUPS_BH RGP,
       OKC_RULES_BH RUL,
       OKC_K_LINES_BH LINE,
       OKS_K_LINES_B KINE
  WHERE  KINE.ID > -1
  AND    LINE.ID = KINE.CLE_ID
  AND    LINE.DNZ_CHR_ID = KINE.DNZ_CHR_ID
  AND    LINE.ID = RGP.CLE_ID
  AND    RGP.ID  = RUL.RGP_ID
  AND    LINE.LSE_ID in (3,16,21)
  AND    RUL.RULE_INFORMATION_CATEGORY IN ('OFS','CVR','DST','PRE','BTD')
  AND    LINE.DNZ_CHR_ID = RGP.DNZ_CHR_ID
--  AND    RUL.RULE_INFORMATION15  IS NULL
  AND    Rul.rowid BETWEEN l_start_rowid and l_end_rowid
  AND    NOT EXISTS  (SELECT CLE_ID FROM OKS_K_Lines_BH where cle_id = LINE.ID)
  AND    LINE.MAJOR_VERSION = RGP.MAJOR_VERSION
  AND    RGP.MAJOR_VERSION = RUL.MAJOR_VERSION
  ORDER BY LINE.ID,RUL.MAJOR_VERSION;

CURSOR Get_Rule_TlH (P_ID IN NUMBER) IS
    SELECT    ID,
            MAJOR_VERSION,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            COMMENTS,
            TEXT,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            SECURITY_GROUP_ID
    FROM        OKC_RULES_TLH
    WHERE       ID = P_ID;

TYPE RowId_Tbl_Type  IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
TYPE Num_Tbl_Type  IS VARRAY(1000) OF NUMBER;
TYPE Date_Tbl_Type IS VARRAY(1000) OF DATE;
TYPE Vc15_Tbl_Type IS VARRAY(1000) OF VARCHAR2(15);
TYPE Vc20_Tbl_Type IS VARRAY(1000) OF VARCHAR2(20);
TYPE Vc150_Tbl_Type IS VARRAY(1000) OF VARCHAR2(150);
TYPE Vc30_Tbl_Type IS VARRAY(1000) OF VARCHAR2(30);
TYPE Vc1_Tbl_Type IS VARRAY(1000) OF VARCHAR2(1);
TYPE Vc3_Tbl_Type IS VARRAY(1000) OF VARCHAR2(3);
TYPE Vc2000_Tbl_Type IS VARRAY(1000) OF VARCHAR2(2000);
TYPE Vc50_Tbl_Type IS VARRAY(1000) OF VARCHAR2(50);
TYPE Vc80_Tbl_Type IS VARRAY(1000) OF VARCHAR2(80);
TYPE Vc120_Tbl_Type IS VARRAY(1000) OF VARCHAR2(120);
TYPE Vc600_Tbl_Type IS VARRAY(1000) OF VARCHAR2(600);


Rul_Row_ID_TBl              RowId_Tbl_Type;
LINE_ID_TBL                 Num_Tbl_Type;
Line_Created_By_TBL         Num_Tbl_Type;
Line_Creation_Date_TBL		Date_Tbl_Type;
Line_Last_Updated_By_TBL    Num_Tbl_Type;
Line_Last_Update_Date_TBL   Date_Tbl_Type;
Line_Last_Update_Login_TBL  Num_Tbl_Type;
RUL_ID_TBL                 Num_Tbl_Type;
LINE_RGP_ID_TBL             Num_Tbl_Type;
LINE_LSE_ID_TBL             Num_Tbl_Type;
LINE_DNZ_CHR_ID_TBL         Num_Tbl_Type;
LINE_OBJECT1_ID1_TBL        Vc150_Tbl_Type;
LINE_OBJECT2_ID1_TBL        Vc150_Tbl_Type;
COV_RULE_INFO1_TBL         Vc150_Tbl_Type;
COV_RULE_INFO2_TBL         Vc150_Tbl_Type;
COV_RULE_INFO3_TBL         Vc150_Tbl_Type;
COV_RULE_INFO4_TBL         Vc150_Tbl_Type;
COV_RULE_INFO5_TBL         Vc150_Tbl_Type;
COV_RULE_INFO6_TBL         Vc150_Tbl_Type;
COV_RULE_INFO7_TBL         Vc150_Tbl_Type;
COV_RULE_INFO8_TBL         Vc150_Tbl_Type;
COV_RULE_INFO9_TBL         Vc150_Tbl_Type;
COV_RULE_INFO10_TBL         Vc150_Tbl_Type;
COV_RULE_INFO11_TBL         Vc150_Tbl_Type;
COV_RULE_INFO12_TBL         Vc150_Tbl_Type;
COV_RULE_INFO13_TBL         Vc150_Tbl_Type;
COV_RULE_INFO14_TBL         Vc150_Tbl_Type;
COV_RULE_INFO15_TBL         Vc150_Tbl_Type;
COV_RULE_INFO_TBL           Vc150_Tbl_Type;
COV_OBJ_VER_NUMBER_TBL         Num_Tbl_Type;
MAJOR_VERSION_TBL           Num_Tbl_Type;
k_line_id_TBL               Num_Tbl_Type;


l_cle_ctr                   NUMBER := 0;
tablename1                  VArchar2(1000);
x_msg_count                 NUMBER := 0;
x_msg_data                 VArchar2(1000);
L_OLD_CLE_ID                NUMBER  := -99999;
L_CLE_ID                    NUMBER  := -99999;
l_duration                  NUMBER;
l_period                    VArchar2(10);
l_return_Status             VArchar2(3):= OKC_API.G_RET_STS_SUCCESS;
l_OU_CURRENCY               VArchar2(10);
L_MSG_INDEX_OUT                     number;
l_message                   VArchar2(1000);
l_start_rowid       ROWID := p_start_rowid;
l_end_rowid         ROWID := p_end_rowid;
  l_tabsize NUMBER := i_clev_tbl_in.COUNT;
  l_tabsize2 NUMBER;
  I NUMBER;
  J NUMBER;
  K NUMBER;
l_status        VARCHAR2(100);
EXCEPTIONHALT_VALIDATION    EXCEPTION;
G_EXCEPTION_HALT            EXCEPTION;


l_old_line_id NUMBER :=  -9999;
l_line_id NUMBER;
/****************************************************/

PROCEDURE   get_duration_period(p_id IN NUMBER,
                                x_duration  OUT NOCOPY NUMBER,
                                x_period    OUT NOCOPY VARCHAR2) IS


CURSOR get_duration (l_ID IN NUMBER) IS
SELECT TAL.UOM_CODE,TAL.Duration
FROM   OKC_TIMEVALUES_BH ISE, OKC_TIMEVALUES_BH TAL
WHERE  ISE.id  = l_id
AND    ISE.TVE_ID_STARTED = TAL.ID
AND    ISE.TVE_TYPE = 'ISE'
AND    TAL.TVE_TYPE = 'TAL'
AND    ISE.DNZ_CHR_ID = TAL.DNZ_CHR_ID;

Lx_Duration NUMBER := NULL;
Lx_Period   VARCHAR2(100) := NULL;

BEGIN

FOR get_duration_Rec in get_duration(p_id) LOOP

Lx_period := get_duration_Rec.uom_code;
Lx_duration   := get_duration_Rec.Duration;

END LOOP;

X_duration := Lx_duration;
X_Period :=Lx_Period;

EXCEPTION
WHEN OTHERS THEN
   OKC_API.SET_MESSAGE
    (P_App_Name	  => G_APP_NAME_OKS
	,P_Msg_Name	  => G_UNEXPECTED_ERROR
	,P_Token1	  => G_SQLCODE_TOKEN
	,P_Token1_Value	  => SQLCODE
	,P_Token2	  => G_SQLERRM_TOKEN
	,P_Token2_Value   => SQLERRM);
END get_duration_period;

PROCEDURE   Create_Coverage_Time(   P_Rule_Id       IN NUMBER,
                                        P_Cle_Id        IN NUMBER,
                                        P_Dnz_Chr_ID    IN NUMBER,
                                        X_return_Status OUT NOCOPY VARCHAR2) IS

    l_rule_ID   NUMBER  := P_rule_Id;
    l_cle_Id    NUMBER  := P_Cle_id;
    l_dnz_Id    NUMBER  :=P_Dnz_Chr_ID;

    l_COV_TZE_LINE_ID   NUMBER := null;

    l_count     NUMBER := 0;

   G_EXCEPTIONHALT_VALIDATION EXCEPTION;

    CURSOR get_time_zone_ID_Cur (rule_id IN NUMBER) IS
    SELECT  Times.tze_id tze_id,
            Times.Created_By Times_Created_By,
            Times.Last_Updated_By    Times_Last_Updated_By,
            Times.Last_Update_Date   Times_Last_Update_Date,
            Times.Last_Update_Login  Times_Last_Update_Login,
            Times.Object_Version_Number Times_Object_Version_Number,
            Times.Major_Version  Times_Major_Version
    FROM    okc_timevalues_bh times,
            okc_cover_times_h cvt
    WHERE   CVT.tve_ID = TIMES.id
    AND     CVT.rul_id = rule_id
    AND     rownum = 1;

    CURSOR get_count_time_zone_ID_Cur (cle_Id IN NUMBER,dnz_Id IN NUMBER) IS
    SELECT  COUNT(*) NCOUNT
    FROM    OKS_COVERAGE_TIMEZONES
    WHERE   cle_id      = cle_Id
    AND     dnz_chr_Id  = dnz_Id;

    BEGIN
        FOR get_count_time_zone_ID_Rec IN get_count_time_zone_ID_Cur(l_cle_Id, l_dnz_Id) LOOP
          l_count   :=  get_count_time_zone_ID_Rec.NCOUNT;
        END LOOP;

        IF l_count =0 THEN

        l_COV_TZE_LINE_ID := null;
        l_ctz_rec := l_ctz_rec + 1;

        FOR get_time_zone_ID_Rec IN get_time_zone_ID_Cur(l_rule_ID) LOOP


            i_ctzv_tbl_in(l_ctz_rec).Id                 := okc_p_util.raw_to_number(sys_guid());


            i_ctzv_tbl_in(l_ctz_rec).Created_By         := get_time_zone_ID_Rec.Times_Created_By;
            i_ctzv_tbl_in(l_ctz_rec).Last_Updated_By    := get_time_zone_ID_Rec.Times_Last_Updated_By;
            i_ctzv_tbl_in(l_ctz_rec).Last_Update_Date   := get_time_zone_ID_Rec.Times_Last_Update_Date;
            i_ctzv_tbl_in(l_ctz_rec).Last_Update_Login  := get_time_zone_ID_Rec.Times_Last_Update_Login;
            i_ctzv_tbl_in(l_ctz_rec).Cle_Id             :=  l_Cle_Id;
            i_ctzv_tbl_in(l_ctz_rec).Dnz_Chr_Id         :=  l_dnz_Id;
            i_ctzv_tbl_in(l_ctz_rec).DEFAULT_YN         :=  'Y';
            i_ctzv_tbl_in(l_ctz_rec).TIMEZONE_ID        :=  get_time_zone_ID_Rec.tze_id;
            i_ctzv_tbl_in(l_ctz_rec).object_version_number := get_time_zone_ID_Rec.Times_Object_Version_Number;
            i_ctzv_tbl_in(l_ctz_rec).Major_Version      := get_time_zone_ID_Rec.Times_Major_Version;


        END LOOP;
		END IF;

        X_return_Status := 'S';
    EXCEPTION
        WHEN OTHERS THEN
                X_return_Status := 'E';
           OKC_API.SET_MESSAGE
            (P_App_Name	  => G_APP_NAME_OKS
        	,P_Msg_Name	  => G_UNEXPECTED_ERROR
        	,P_Token1	  => G_SQLCODE_TOKEN
        	,P_Token1_Value	  => SQLCODE
        	,P_Token2	  => G_SQLERRM_TOKEN
        	,P_Token2_Value   => SQLERRM);

    END Create_Coverage_Time;



BEGIN
G_APP_NAME := 'Business_Process_migration';
l_OU_CURRENCY   := OKC_CURRENCY_API.GET_OU_CURRENCY;

OPEN Get_Buss_Process_Cur (l_start_rowid,l_end_rowid);
LOOP
    BEGIN
    FETCH Get_Buss_Process_Cur BULK COLLECT INTO
            LINE_ID_TBL                 ,
            Line_Created_By_TBL         ,
			Line_Creation_Date_TBL		,
            Line_Last_Updated_By_TBL    ,
            Line_Last_Update_Date_TBL   ,
            Line_Last_Update_Login_TBL  ,
            RUL_ID_TBL                  ,
            LINE_RGP_ID_TBL             ,
            Rul_Row_ID_TBl              ,
            LINE_LSE_ID_TBL             ,
            LINE_DNZ_CHR_ID_TBL         ,
            LINE_OBJECT1_ID1_TBL        ,
            LINE_OBJECT2_ID1_TBL        ,
            COV_RULE_INFO1_TBL         ,
            COV_RULE_INFO2_TBL         ,
            COV_RULE_INFO3_TBL         ,
            COV_RULE_INFO4_TBL         ,
            COV_RULE_INFO5_TBL         ,
            COV_RULE_INFO6_TBL         ,
            COV_RULE_INFO7_TBL         ,
            COV_RULE_INFO8_TBL         ,
            COV_RULE_INFO9_TBL         ,
            COV_RULE_INFO10_TBL         ,
            COV_RULE_INFO11_TBL         ,
            COV_RULE_INFO12_TBL         ,
            COV_RULE_INFO13_TBL         ,
            COV_RULE_INFO14_TBL         ,
            COV_RULE_INFO15_TBL         ,
            COV_RULE_INFO_TBL           ,
            COV_OBJ_VER_NUMBER_TBL,
            MAJOR_VERSION_TBL,
            k_line_id_TBL
            LIMIT 1000;

--  -- dbms_output.put_line('Value of LINE_ID_TBL.COUNT='||TO_CHAR(LINE_ID_TBL.COUNT));

        IF LINE_ID_TBL.COUNT > 0 THEN

            FOR I IN LINE_ID_TBL.FIRST .. LINE_ID_TBL.LAST LOOP
            L_Cle_id := LINE_ID_TBL(i);

            IF (L_OLD_CLE_ID <> L_CLE_ID) THEN
                l_cle_ctr := l_cle_ctr + 1;


            i_clev_tbl_in(l_cle_ctr).Id := k_line_id_TBL(I);
            l_line_id := LINE_ID_TBL(i);
            i_clev_tbl_in(l_cle_ctr).Created_By   := Line_Created_By_TBL(i);
            i_clev_tbl_in(l_cle_ctr).Creation_Date   := Line_Creation_Date_TBL(i);
            i_clev_tbl_in(l_cle_ctr).Last_Updated_By   := Line_Last_Updated_By_TBL(i);
            i_clev_tbl_in(l_cle_ctr).Last_Update_Date   := Line_Last_Update_Date_TBL(i);
            i_clev_tbl_in(l_cle_ctr).Last_Update_Login  := Line_Last_Update_Login_TBL(i);
            i_clev_tbl_in(l_cle_ctr).Cle_Id         :=  LINE_ID_TBL(i);
            i_clev_tbl_in(l_cle_ctr).Dnz_Chr_Id         :=  LINE_DNZ_CHR_ID_TBL(i);
            i_clev_tbl_in(l_cle_ctr).object_version_number :=  1;
            i_clev_tbl_in(l_cle_ctr).Sync_Date_Install :=  'N';

            END IF;


            IF   COV_RULE_INFO_TBL(i) = 'OFS' THEN
                IF COV_RULE_INFO1_TBL(i) IS NOT NULL THEN

                    get_duration_period(p_id => COV_RULE_INFO1_TBL(i),
                                        x_duration  => l_duration,
                                        x_period    => l_period);

                END IF;

                i_clev_tbl_in(l_cle_ctr).OFFSET_DURATION := l_duration;
                i_clev_tbl_in(l_cle_ctr).OFFSET_PERIOD :=   l_period;

            END IF;



            IF   COV_RULE_INFO_TBL(i) = 'DST' THEN
                i_clev_tbl_in(l_cle_ctr).DISCOUNT_LIST := LINE_OBJECT1_ID1_TBL(i);
            END IF;


            IF   COV_RULE_INFO_TBL(i) = 'PRE' THEN

                UPDATE OKC_K_LINES_BH
                SET PRICE_LIST_ID = LINE_OBJECT1_ID1_TBL(i),
                    CURRENCY_CODE = l_OU_CURRENCY
                WHERE ID = LINE_ID_TBL(i);

            END IF;


            IF COV_RULE_INFO_TBL(i) = 'BTD' THEN

    	        i_clev_tbl_in(l_cle_ctr).ALLOW_BT_DISCOUNT := 'Y';
            END IF;


            IF COV_RULE_INFO_TBL(i) = 'CVR' THEN

            Create_Coverage_Time(   P_Rule_Id       =>  RUL_ID_TBL(i),
                                    P_Cle_Id        =>  LINE_ID_TBL(i),
                                    P_Dnz_Chr_ID    =>  LINE_DNZ_CHR_ID_TBL(i),
                                    X_return_Status =>  l_return_Status);

            IF  l_return_Status <> 'S' THEN
                RAISE EXCEPTIONHALT_VALIDATION;
            END IF;

            END IF;

        -------------------------            FOR TLH-----------------------
        IF  l_line_id <> l_old_line_id THEN
         -- dbms_output.put_line('--->Value of Rule_Id_Tbl(l_cle_ctr)='||TO_CHAR(Rul_Id_Tbl(I)));
        FOR Get_Rule_TlH_REC IN Get_Rule_TlH(Rul_Id_Tbl(l_cle_ctr))  LOOP
        l_clt_ctr := l_clt_ctr + 1;
         -- dbms_output.put_line('---------->l_clt_ctr='||TO_CHAR(l_clt_ctr));
            l_clet_tbl_in(l_clt_ctr).id                 :=  i_clev_tbl_in(l_cle_ctr).id;
            l_clet_tbl_in(l_clt_ctr).MAJOR_VERSION      := Get_Rule_TlH_REC.MAJOR_VERSION;
            l_clet_tbl_in(l_clt_ctr).language           :=  Get_Rule_TlH_REC.language;
            l_clet_tbl_in(l_clt_ctr).source_lang        :=  Get_Rule_TlH_REC.source_lang;
            l_clet_tbl_in(l_clt_ctr).sfwt_flag          :=  Get_Rule_TlH_REC.sfwt_flag;
            l_clet_tbl_in(l_clt_ctr).invoice_text       := NULL; -- Get_Rule_TlH_REC.text;
  --            l_clet_tbl_in(l_clt_ctr).ib_trx_details     :=  Get_Rule_TlH_REC.ib_trx_details;
  --          l_clet_tbl_in(l_clt_ctr).status_text        :=  Get_Rule_TlH_REC.status_text;
  --          l_clet_tbl_in(l_clt_ctr).react_time_name    :=  Get_Rule_TlH_REC.react_time_name;
            l_clet_tbl_in(l_clt_ctr).created_by         :=  Get_Rule_TlH_REC.created_by;
            l_clet_tbl_in(l_clt_ctr).creation_date      :=  Get_Rule_TlH_REC.creation_date;
            l_clet_tbl_in(l_clt_ctr).last_updated_by    :=  Get_Rule_TlH_REC.last_updated_by;
            l_clet_tbl_in(l_clt_ctr).last_update_date   :=  Get_Rule_TlH_REC.last_update_date;
            l_clet_tbl_in(l_clt_ctr).last_update_login  :=  Get_Rule_TlH_REC.last_update_login;

        END LOOP;
        l_old_line_id := l_line_id;
         -- dbms_output.put_line('Value of l_old_line_id='||TO_CHAR(l_old_line_id));
        END IF;
        --------------------------------------------------------------------
            --************************************************

            L_OLD_CLE_ID := L_CLE_ID;

            --*************************************************

            END LOOP;
        END IF;

         tablename1 := 'OKS_K_LINES';
             -- dbms_output.put_line('Value of i_clev_tbl_in.countBefore Insert '||TO_CHAR(i_clev_tbl_in.count));

    IF i_clev_tbl_in.count > 0 THEN
            Insert_Into_Klines( p_clev_tbl_in   =>  i_clev_tbl_in,
                                p_clet_tbl_in   =>  l_clet_tbl_in,
                                x_return_Status =>  l_return_status);
    END IF;

     IF i_ctzv_tbl_in.COUNT > 0 THEN
            i  := i_ctzv_tbl_in.FIRST; K:=0;
            while i is not null   LOOP
                k:=k+1;

                IN_ID(k) := 	i_ctzv_tbl_in(i).ID;
                IN_DNZ_CHR_ID(k) := 	i_ctzv_tbl_in(i).DNZ_CHR_ID;
                IN_CLE_ID(k) := 	i_ctzv_tbl_in(i).CLE_ID;
                IN_DEFAULT_YN(k) := 	i_ctzv_tbl_in(i).DEFAULT_YN;
                IN_TIMEZONE_ID(k) := 	i_ctzv_tbl_in(i).TIMEZONE_ID;
                IN_SECURITY_GROUP_ID(k) := 	i_ctzv_tbl_in(i).SECURITY_GROUP_ID;
                IN_PROGRAM_APPLICATION_ID(k) := 	i_ctzv_tbl_in(i).PROGRAM_APPLICATION_ID;
                IN_PROGRAM_ID(k) := 	i_ctzv_tbl_in(i).PROGRAM_ID;
                IN_PROGRAM_UPDATE_DATE(k) := 	i_ctzv_tbl_in(i).PROGRAM_UPDATE_DATE;
                IN_REQUEST_ID(k) := 	i_ctzv_tbl_in(i).REQUEST_ID;
                IN_CREATED_BY(k) := 	i_ctzv_tbl_in(i).CREATED_BY;
                IN_CREATION_DATE(k) := 	i_ctzv_tbl_in(i).CREATION_DATE;
                IN_LAST_UPDATED_BY(k) := 	i_ctzv_tbl_in(i).LAST_UPDATED_BY;
                IN_LAST_UPDATE_DATE(k) := 	i_ctzv_tbl_in(i).LAST_UPDATE_DATE;
                IN_LAST_UPDATE_LOGIN(k) := 	i_ctzv_tbl_in(i).LAST_UPDATE_LOGIN;
                IN_OBJECT_VERSION_NUMBER(k) := 	i_ctzv_tbl_in(i).OBJECT_VERSION_NUMBER;
                IN_MAJOR_VERSION(k) := 	i_ctzv_tbl_in(i).MAJOR_VERSION;

                i:=i_ctzv_tbl_in.next(i);

            END LOOP;

                l_tabsize := i_ctzv_tbl_in.COUNT;
                l_status := 'Before Insert';

            FORALL I IN  1  ..   l_tabsize

            INSERT INTO OKS_COVERAGE_TIMEZONES_H(
                                ID,
								DNZ_CHR_ID,
                                CLE_ID,
                                DEFAULT_YN,
                                TIMEZONE_ID,
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
                                OBJECT_VERSION_NUMBER,
                                MAJOR_VERSION)
            VALUES
                               (IN_ID(i),
                                IN_DNZ_CHR_ID(i),
                                IN_CLE_ID(i),
                                IN_DEFAULT_YN(i),
                                IN_TIMEZONE_ID(i),
                                IN_SECURITY_GROUP_ID(i),
                                IN_PROGRAM_APPLICATION_ID(i),
                                IN_PROGRAM_ID(i),
                                IN_PROGRAM_UPDATE_DATE(i),
                                IN_REQUEST_ID(i),
                                IN_CREATED_BY(i),
                                IN_CREATION_DATE(i),
                                IN_LAST_UPDATED_BY(i),
                                IN_LAST_UPDATE_DATE(i),
                                IN_LAST_UPDATE_LOGIN(i),
                                IN_OBJECT_VERSION_NUMBER(i),
                                IN_MAJOR_VERSION(i));

        END IF;


i_ctzv_tbl_in.delete;
i_clev_tbl_in.delete;

    IF l_return_status = 'S' THEN
              x_return_status := 'S';
    ELSE
                RAISE G_EXCEPTION_HALT;
    END IF;


EXCEPTION


    WHEN EXCEPTIONHALT_VALIDATION THEN
    --  -- dbms_output.put_line('SQLERRM ---->'||SQLERRM);
        ROLLBACK;
        i_ctzv_tbl_in.delete;
        i_clev_tbl_in.delete;
        i_cvtv_tbl_in.delete;


    x_return_status := OKC_API.G_RET_STS_ERROR;
    OKC_API.SET_MESSAGE
    (   p_app_name        => G_APP_NAME,
          p_msg_name        => G_UNEXPECTED_ERROR,
          p_token1          => G_SQLCODE_TOKEN,
          p_token1_value    => SQLCODE,
          p_token2          => G_SQLERRM_TOKEN,
          p_token2_value    => SQLERRM
    );
                x_return_status := 'E';
     WHEN G_EXCEPTION_HALT THEN

        ROLLBACK;
        i_ctzv_tbl_in.delete;
        i_clev_tbl_in.delete;
        i_cvtv_tbl_in.delete;

    x_return_status := OKC_API.G_RET_STS_ERROR;
    OKC_API.SET_MESSAGE
    (   p_app_name        => G_APP_NAME,
          p_msg_name        => G_UNEXPECTED_ERROR,
          p_token1          => G_SQLCODE_TOKEN,
          p_token1_value    => SQLCODE,
          p_token2          => G_SQLERRM_TOKEN,
          p_token2_value    => SQLERRM
    );
                x_return_status := 'E';
    WHEN Others THEN

        ROLLBACK;
        i_ctzv_tbl_in.delete;
        i_clev_tbl_in.delete;
        i_cvtv_tbl_in.delete;

    x_return_status := OKC_API.G_RET_STS_ERROR;
    OKC_API.SET_MESSAGE
    (   p_app_name        => G_APP_NAME,
          p_msg_name        => G_UNEXPECTED_ERROR,
          p_token1          => G_SQLCODE_TOKEN,
          p_token1_value    => SQLCODE,
          p_token2          => G_SQLERRM_TOKEN,
          p_token2_value    => SQLERRM
    );
        x_return_status := 'E';
    END;

EXIT WHEN Get_Buss_Process_Cur%NOTFOUND;

END LOOP;

CLOSE Get_Buss_Process_Cur;

EXCEPTION
    WHEN Others THEN
    x_return_status := OKC_API.G_RET_STS_ERROR;
    OKC_API.SET_MESSAGE
    (   p_app_name        => G_APP_NAME,
          p_msg_name        => G_UNEXPECTED_ERROR,
          p_token1          => G_SQLCODE_TOKEN,
          p_token1_value    => SQLCODE,
          p_token2          => G_SQLERRM_TOKEN,
          p_token2_value    => SQLERRM
    );
        x_return_status := 'E';
END Buss_Proc_History_migration;




PROCEDURE COV_TIMES_History_MIGRATION(      p_start_rowid IN ROWID,
                                            p_end_rowid IN ROWID,
                                            x_return_status OUT NOCOPY VARCHAR2,
                                            x_message_data  OUT NOCOPY VARCHAR2)IS



CURSOR Csr_Get_Coverage_times (l_start_rowid IN ROWID ,l_end_rowid IN ROWID ) IS
SELECT  CTZ.ID                  TimeZone_ID,
        CTZ.DNZ_CHR_ID          DNZ_CHR_ID,
        Times.ID                Times_Id,
        TIMES.ROWID             TIMES_ROW_ID,
        TIMES.TVE_ID_STARTED    TVE_ID_STARTED,
        TIMES.TVE_ID_ENDED      TVE_ID_ENDED,
        Times.Created_By        Times_Created_By,
        Times.Last_Updated_By   Times_Last_Updated_By,
        Times.Last_Update_Date  Times_Last_Update_Date,
        Times.Last_Update_Login Times_Last_Update_Login,
        Times.Attribute15       Times_Attribute15,
        Times.object_version_number Times_object_version_number,
        Times.major_version Times_major_version
FROM    OKS_COVERAGE_TIMEZONES CTZ,
        OKC_RULE_GROUPS_BH RGP,
        OKC_RULES_BH RUL,
        OKC_COVER_TIMES_H CVT,
        OKC_TIMEVALUES_BH TIMES
WHERE   CTZ.Cle_Id = RGP.CLE_ID
AND     CTZ.DNZ_CHR_ID = RGP.DNZ_CHR_ID
AND     RGP.ID = RUL.RGP_ID
AND     RGP.DNZ_CHR_ID = RUL.DNZ_CHR_ID
AND     RUL.RULE_INFORMATION_CATEGORY = 'CVR'
AND     RUL.ID  = CVT.RUL_ID
AND     CVT.TVE_ID = TIMES.ID
--AND     times.id = 304783990308709311929711428529893238167
AND     RGP.MAJOR_VERSION = RUL.MAJOR_VERSION
AND     RUL.MAJOR_VERSION = CVT.MAJOR_VERSION
AND     CVT.MAJOR_VERSION = TIMES.MAJOR_VERSION
AND     Times.rowid BETWEEN l_start_rowid and l_end_rowid
AND     NOT EXISTS (Select COV_TZE_LINE_ID from OKS_COVERAGE_TIMES_H where COV_TZE_LINE_ID= CTZ.ID);


CURSOR get_Coverage_time_Cur (l_tve_id IN NUMBER) IS
SELECT tve_type,day_of_week,hour,minute
FROM   okc_timevalues_BH
WHERE  ID = l_tve_id;

TYPE Vc420_Tbl_Type IS VARRAY(1000) OF VARCHAR2(420);
TYPE Num_Tbl_Type  IS VARRAY(1000) OF NUMBER;
TYPE RowId_Tbl_Type  IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
TYPE Date_Tbl_Type  IS VARRAY(1000) OF DATE;

Times_Id_tbl        Num_Tbl_Type;
TIMES_ROW_ID        RowId_Tbl_Type;
TimeZone_ID_TBL     Num_Tbl_Type;
TVE_ID_STARTED_TBL  Num_Tbl_Type;
TVE_ID_ENDED_TBL    Num_Tbl_Type;
DNZ_CHR_ID_TBL      Num_Tbl_Type;
Times_Attribute15_TBL   Vc420_Tbl_Type;
TIMES_Created_By_TBL         Num_Tbl_Type;
TIMES_Last_Updated_By_TBL    Num_Tbl_Type;
TIMES_Last_Update_Date_TBL   Date_Tbl_Type;
TIMES_Last_Update_Login_TBL  Num_Tbl_Type;
Times_obj_version_number_TBL  Num_Tbl_Type;
Times_major_version_TBL  Num_Tbl_Type;

tablename1      VARCHAR2(1000);
l_return_status VARCHAR2(1) :=OKC_API.G_RET_STS_SUCCESS;
l_msg_count     NUMBER;

l_start_rowid       ROWID := p_start_rowid;
l_end_rowid         ROWID := p_end_rowid;
l_msg_data          VARCHAR2(1000);
l_msg_index_out     NUMBER;
l_message           VARCHAR2(2400);
x_msg_count                 NUMBER := 0;
x_msg_data                 VArchar2(1000);

G_EXCEPTION_HALT    EXCEPTION;
l_status            VARCHAR2(100) := NULL;
/************************************************************/



IN_ID               OKC_DATATYPES.NumberTabTyp;
IN_DNZ_CHR_ID       OKC_DATATYPES.NumberTabTyp;
IN_COV_TZE_LINE_ID  OKC_DATATYPES.NumberTabTyp;
IN_START_HOUR       OKC_DATATYPES.NumberTabTyp;
IN_START_MINUTE     OKC_DATATYPES.NumberTabTyp;
IN_END_HOUR         OKC_DATATYPES.NumberTabTyp;
IN_END_MINUTE       OKC_DATATYPES.NumberTabTyp;
IN_MONDAY_YN        OKC_DATATYPES.VAR3TabTyp;
IN_TUESDAY_YN       OKC_DATATYPES.VAR3TabTyp;
IN_WEDNESDAY_YN     OKC_DATATYPES.VAR3TabTyp;
IN_THURSDAY_YN      OKC_DATATYPES.VAR3TabTyp;
IN_FRIDAY_YN        OKC_DATATYPES.VAR3TabTyp;
IN_SATURDAY_YN      OKC_DATATYPES.VAR3TabTyp;
IN_SUNDAY_YN        OKC_DATATYPES.VAR3TabTyp;
IN_SECURITY_GROUP_ID        OKC_DATATYPES.NumberTabTyp;
IN_PROGRAM_APPLICATION_ID   OKC_DATATYPES.NumberTabTyp;
IN_PROGRAM_ID               OKC_DATATYPES.NumberTabTyp;
IN_PROGRAM_UPDATE_DATE      OKC_DATATYPES.DateTabTyp;
IN_REQUEST_ID               OKC_DATATYPES.NumberTabTyp;
IN_CREATED_BY               OKC_DATATYPES.NumberTabTyp;
IN_CREATION_DATE            OKC_DATATYPES.DateTabTyp;
IN_LAST_UPDATED_BY          OKC_DATATYPES.NumberTabTyp;
IN_LAST_UPDATE_DATE         OKC_DATATYPES.DateTabTyp;
IN_LAST_UPDATE_LOGIN        OKC_DATATYPES.NumberTabTyp;
IN_OBJECT_VERSION_NUMBER    OKC_DATATYPES.NumberTabTyp;
IN_MAJOR_VERSION            OKC_DATATYPES.NumberTabTyp;

/************************************************************/




BEGIN
G_APP_NAME := 'COVERAGE_TIMES_HISTORY_MIGRATION';

OPEN Csr_Get_Coverage_times (l_start_rowid,l_end_rowid);
LOOP
    BEGIN
    l_cvt_rec   := 0;
    i_cvtv_tbl_in.DELETE;
    l_status := 'Before fetch';

    FETCH Csr_Get_Coverage_times BULK COLLECT INTO
            TimeZone_ID_Tbl,
            DNZ_CHR_ID_TBL,
            Times_Id_tbl,
            TIMES_ROW_ID,
            TVE_ID_STARTED_Tbl,
            TVE_ID_ENDED_Tbl,
            TIMES_Created_By_TBL,
            TIMES_Last_Updated_By_TBL,
            TIMES_Last_Update_Date_TBL,
            TIMES_Last_Update_Login_TBL,
            Times_Attribute15_TBL,
            Times_obj_version_number_tbl,
            Times_major_version_TBL
            LIMIT 1000;

    -- -- dbms_output.put_line('Value of TimeZone_ID_Tbl.COUNT='||TO_CHAR(TimeZone_ID_Tbl.COUNT));

    l_status := 'In Fetch';

    IF  TimeZone_ID_Tbl.COUNT > 0 THEN
    FOR I IN TimeZone_ID_Tbl.FIRST .. TimeZone_ID_Tbl.LAST LOOP

            l_cvt_rec := l_cvt_rec + 1;


            i_cvtv_tbl_in(l_cvt_rec).ID                 := Times_Id_tbl(i);
            --okc_p_util.raw_to_number(sys_guid());

            i_cvtv_tbl_in(l_cvt_rec).COV_TZE_LINE_ID    := TimeZone_ID_Tbl(i);
            i_cvtv_tbl_in(l_cvt_rec).DNZ_CHR_ID    := DNZ_CHR_ID_TBL(i);

            i_cvtv_tbl_in(l_cvt_rec).Created_By         := TIMES_Created_By_TBL(i);
            i_cvtv_tbl_in(l_cvt_rec).Last_Updated_By    := TIMES_Last_Updated_By_TBL(i);
            i_cvtv_tbl_in(l_cvt_rec).Last_Update_Date   := TIMES_Last_Update_Date_TBL(i);
            i_cvtv_tbl_in(l_cvt_rec).Last_Update_Login  := TIMES_Last_Update_Login_TBL(i);
            i_cvtv_tbl_in(l_cvt_rec).object_version_number :=  Times_obj_version_number_tbl(i);
            i_cvtv_tbl_in(l_cvt_rec).major_version          := Times_major_version_TBL(i);
            i_cvtv_tbl_in(l_cvt_rec).SECURITY_GROUP_ID      := NULL;
            i_cvtv_tbl_in(l_cvt_rec).PROGRAM_APPLICATION_ID:= NULL;
            i_cvtv_tbl_in(l_cvt_rec).PROGRAM_ID:= NULL;
            i_cvtv_tbl_in(l_cvt_rec).REQUEST_ID:= NULL;

            FOR get_Coverage_time_REC  IN get_Coverage_time_Cur(TVE_ID_STARTED_TBL(i)) LOOP

            IF    get_Coverage_time_REC.day_of_week = 'SUN' THEN

                i_cvtv_tbl_in(l_cvt_rec).SUNDAY_YN := 'Y';

            ELSIF    get_Coverage_time_REC.day_of_week = 'MON' THEN

                i_cvtv_tbl_in(l_cvt_rec).MONDAY_YN := 'Y';

            ELSIF    get_Coverage_time_REC.day_of_week = 'TUE' THEN
                i_cvtv_tbl_in(l_cvt_rec).TUESDAY_YN := 'Y';

            ELSIF    get_Coverage_time_REC.day_of_week = 'WED' THEN
                i_cvtv_tbl_in(l_cvt_rec).WEDNESDAY_YN := 'Y';

            ELSIF    get_Coverage_time_REC.day_of_week = 'THU' THEN
                i_cvtv_tbl_in(l_cvt_rec).THURSDAY_YN := 'Y';

            ELSIF    get_Coverage_time_REC.day_of_week = 'FRI' THEN
                i_cvtv_tbl_in(l_cvt_rec).FRIDAY_YN := 'Y';

            ELSIF    get_Coverage_time_REC.day_of_week = 'SAT' THEN
                i_cvtv_tbl_in(l_cvt_rec).SATURDAY_YN := 'Y';

            END IF;

            i_cvtv_tbl_in(l_cvt_rec).START_HOUR := get_Coverage_time_REC.HOUR;
            i_cvtv_tbl_in(l_cvt_rec).START_MINUTE := get_Coverage_time_REC.MINUTE;

            END LOOP;

            FOR get_Coverage_time_REC  IN get_Coverage_time_Cur(TVE_ID_ENDED_Tbl(i)) LOOP

            i_cvtv_tbl_in(l_cvt_rec).END_HOUR := get_Coverage_time_REC.HOUR;
            i_cvtv_tbl_in(l_cvt_rec).END_MINUTE := get_Coverage_time_REC.MINUTE;

            END LOOP;


    END LOOP;
    END IF;

    tablename1 := 'oks_coverage_times';

     -- dbms_output.put_line('Value of i_cvtv_tbl_in.COUNT='||TO_CHAR(i_cvtv_tbl_in.COUNT));

    IF i_cvtv_tbl_in.COUNT > 0 THEN

            i  := i_cvtv_tbl_in.FIRST; K:=0;
            while i is not null   LOOP
                k:=k+1;

                IN_ID(k) := 	i_cvtv_tbl_in(i).ID;
                IN_DNZ_CHR_ID(k) := 	i_cvtv_tbl_in(i).DNZ_CHR_ID;
                IN_COV_TZE_LINE_ID(k) := 	i_cvtv_tbl_in(i).COV_TZE_LINE_ID;
                IN_START_HOUR(k) := 	i_cvtv_tbl_in(i).START_HOUR;
                IN_START_MINUTE(k) := 	i_cvtv_tbl_in(i).START_MINUTE;
                IN_END_HOUR(k) := 	i_cvtv_tbl_in(i).END_HOUR;
                IN_END_MINUTE(k) := 	i_cvtv_tbl_in(i).END_MINUTE;
                IN_MONDAY_YN(k) := 	i_cvtv_tbl_in(i).MONDAY_YN;
                IN_TUESDAY_YN(k) := 	i_cvtv_tbl_in(i).TUESDAY_YN;
                IN_WEDNESDAY_YN(k) := 	i_cvtv_tbl_in(i).WEDNESDAY_YN;
                IN_THURSDAY_YN(k) := 	i_cvtv_tbl_in(i).THURSDAY_YN;
                IN_FRIDAY_YN(k) := 	i_cvtv_tbl_in(i).FRIDAY_YN;
                IN_SATURDAY_YN(k) := 	i_cvtv_tbl_in(i).SATURDAY_YN;
                IN_SUNDAY_YN(k) := 	i_cvtv_tbl_in(i).SUNDAY_YN;
                IN_SECURITY_GROUP_ID(k) := 	i_cvtv_tbl_in(i).SECURITY_GROUP_ID;
                IN_PROGRAM_APPLICATION_ID(k) := 	i_cvtv_tbl_in(i).PROGRAM_APPLICATION_ID;
                IN_PROGRAM_ID(k) := 	i_cvtv_tbl_in(i).PROGRAM_ID;
                IN_PROGRAM_UPDATE_DATE(k) := 	i_cvtv_tbl_in(i).PROGRAM_UPDATE_DATE;
                IN_REQUEST_ID(k) := 	i_cvtv_tbl_in(i).REQUEST_ID;
                IN_CREATED_BY(k) := 	i_cvtv_tbl_in(i).CREATED_BY;
                IN_CREATION_DATE(k) := 	i_cvtv_tbl_in(i).CREATION_DATE;
                IN_LAST_UPDATED_BY(k) := 	i_cvtv_tbl_in(i).LAST_UPDATED_BY;
                IN_LAST_UPDATE_DATE(k) := 	i_cvtv_tbl_in(i).LAST_UPDATE_DATE;
                IN_LAST_UPDATE_LOGIN(k) := 	i_cvtv_tbl_in(i).LAST_UPDATE_LOGIN;
                IN_OBJECT_VERSION_NUMBER(k) := 	i_cvtv_tbl_in(i).OBJECT_VERSION_NUMBER;
                IN_MAJOR_VERSION(k) := 	i_cvtv_tbl_in(i).MAJOR_VERSION;

                i:=i_cvtv_tbl_in.next(i);

            END LOOP;

                l_tabsize := i_cvtv_tbl_in.COUNT;
                l_status := 'Before Insert';

            FORALL I IN  1  ..   l_tabsize

            INSERT INTO OKS_COVERAGE_TIMES_H(
                                ID,
								DNZ_CHR_ID,
								COV_TZE_LINE_ID,
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
								OBJECT_VERSION_NUMBER,
								MAJOR_VERSION)VALUES
                               (
                                IN_ID (i),
                                IN_DNZ_CHR_ID (i),
                                IN_COV_TZE_LINE_ID (i),
                                IN_START_HOUR (i),
                                IN_START_MINUTE (i),
                                IN_END_HOUR (i),
                                IN_END_MINUTE (i),
                                IN_MONDAY_YN (i),
                                IN_TUESDAY_YN (i),
                                IN_WEDNESDAY_YN (i),
                                IN_THURSDAY_YN (i),
                                IN_FRIDAY_YN (i),
                                IN_SATURDAY_YN (i),
                                IN_SUNDAY_YN (i),
                                IN_SECURITY_GROUP_ID (i),
                                IN_PROGRAM_APPLICATION_ID (i),
                                IN_PROGRAM_ID (i),
                                IN_PROGRAM_UPDATE_DATE (i),
                                IN_REQUEST_ID (i),
                                IN_CREATED_BY (i),
                                IN_CREATION_DATE (i),
                                IN_LAST_UPDATED_BY (i),
                                IN_LAST_UPDATE_DATE (i),
                                IN_LAST_UPDATE_LOGIN (i),
                                IN_OBJECT_VERSION_NUMBER (i),
                                IN_MAJOR_VERSION (i));



          x_return_status := 'S';

    END IF;


    EXIT WHEN Csr_Get_Coverage_times%NOTFOUND;

    EXCEPTION
        WHEN G_EXCEPTION_HALT THEN
        ROLLBACK;
        x_return_status := OKC_API.G_RET_STS_ERROR;
        OKC_API.SET_MESSAGE
        (     p_app_name        => G_APP_NAME,
              p_msg_name        => G_UNEXPECTED_ERROR,
              p_token1          => G_SQLCODE_TOKEN,
              p_token1_value    => SQLCODE,
              p_token2          => G_SQLERRM_TOKEN,
              p_token2_value    => SQLERRM
        );

        x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );

         IF x_msg_count > 0              THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
    END IF;

                x_message_data  := l_message;
                x_return_status := 'E';
        WHEN Others THEN
        ROLLBACK;
        x_return_status := OKC_API.G_RET_STS_ERROR;
        OKC_API.SET_MESSAGE
        (     p_app_name        => G_APP_NAME,
              p_msg_name        => G_UNEXPECTED_ERROR,
              p_token1          => G_SQLCODE_TOKEN,
              p_token1_value    => SQLCODE,
              p_token2          => G_SQLERRM_TOKEN,
              p_token2_value    => SQLERRM
        );

        x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );

         IF x_msg_count > 0              THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
        END IF;

                x_message_data  := l_message;
                x_return_status := 'E';

    END;
    EXIT WHEN Csr_Get_Coverage_times%NOTFOUND;
END LOOP;
CLOSE Csr_Get_Coverage_times;
EXCEPTION
    WHEN Others THEN
    Raise;
    x_return_status := OKC_API.G_RET_STS_ERROR;
    OKC_API.SET_MESSAGE
   	  (   p_app_name        => G_APP_NAME,
          p_msg_name        => G_UNEXPECTED_ERROR,
          p_token1          => G_SQLCODE_TOKEN,
          p_token1_value    => SQLCODE,
          p_token2          => G_SQLERRM_TOKEN,
          p_token2_value    => SQLERRM
          );

        x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );

         IF x_msg_count > 0              THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
        END IF;
                x_message_data  := l_message;
                x_return_status := 'E';



END COV_TIMES_History_MIGRATION;

PROCEDURE Reaction_Time_Hist_migration(     p_start_rowid IN ROWID,
                                            p_end_rowid IN ROWID,
                                            x_return_status OUT NOCOPY VARCHAR2,
                                            x_message_data  OUT NOCOPY VARCHAR2) IS


CURSOR Csr_Get_Reaction_Times (l_start_rowid IN ROWID ,l_end_rowid IN ROWID ) IS
  SELECT
        LINE.ID LINE_ID,
        Line.Created_By Line_Created_By,
		Line.Creation_Date		Line_Creation_Date,
        Line.Last_Updated_By    Line_Last_Updated_By,
        Line.Last_Update_Date   Line_Last_Update_Date,
        Line.Last_Update_Login  Line_Last_Update_Login,
        Rul.ROWID   RUL_ROW_ID,
        Rul.ID  Rul_Id,
        RGP.ID LINE_RGP_ID,
        LINE.LSE_ID LINE_LSE_ID,
        LINE.DNZ_CHR_ID LINE_DNZ_CHR_ID,
        OBJECT1_ID1  LINE_OBJECT1_ID1,
        OBJECT2_ID1 LINE_OBJECT2_ID1,
        RULE_INFORMATION1  COV_RULE_INFO1,
        RULE_INFORMATION2  COV_RULE_INFO2,
        RULE_INFORMATION3  COV_RULE_INFO3,
        RULE_INFORMATION4  COV_RULE_INFO4,
        RULE_INFORMATION5  COV_RULE_INFO5,
        RULE_INFORMATION6  COV_RULE_INFO6,
        RULE_INFORMATION7  COV_RULE_INFO7,
        RULE_INFORMATION8  COV_RULE_INFO8,
        RULE_INFORMATION9  COV_RULE_INFO9,
        RULE_INFORMATION10 COV_RULE_INFO10,
        RULE_INFORMATION11 COV_RULE_INFO11,
        RULE_INFORMATION12 COV_RULE_INFO12,
        RULE_INFORMATION13 COV_RULE_INFO13,
        RULE_INFORMATION14 COV_RULE_INFO14,
        RULE_INFORMATION15 COV_RULE_INFO15,
        RULE_INFORMATION_CATEGORY  COV_RULE_INFO,
        RUL.OBJECT_VERSION_NUMBER  COV_OBJ_VER_NUMBER,
        KINE.ID k_line_id,
        Rul.major_version Rul_major_version
    FROM
       OKC_RULE_GROUPS_BH RGP,
       OKC_RULES_BH RUL,
       OKC_K_LINES_BH LINE,
       OKS_K_LINES_B KINE
  WHERE LINE.ID = KINE.CLE_ID
  AND    LINE.DNZ_CHR_ID = KINE.DNZ_CHR_ID
  AND      LINE.ID = RGP.CLE_ID
  AND    RGP.ID  = RUL.RGP_ID
  AND    LINE.LSE_ID IN (4,17,22)
  AND    RUL.RULE_INFORMATION_CATEGORY IN ('RCN','RSN')
  AND     RGP.MAJOR_VERSION = RUL.MAJOR_VERSION
  AND     LINE.MAJOR_VERSION = RGP.MAJOR_VERSION
--  AND    RUL.RULE_INFORMATION15 IS NULL
  AND    Rul.rowid BETWEEN l_start_rowid and l_end_rowid
  AND    NOT EXISTS (SELECT CLE_ID FROM OKS_K_LINES_BH WHERE CLE_ID = LINE.ID)
  ORDER BY LINE.ID;

CURSOR Get_Rule_TlH (P_ID IN NUMBER) IS
    SELECT    ID,
            MAJOR_VERSION,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            COMMENTS,
            TEXT,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            SECURITY_GROUP_ID
    FROM        OKC_RULES_TLH
    WHERE       ID = P_ID;

CURSOR Get_Action_Time_Types (p_Cle_Id IN NUMBER)Is
Select ID
FROM   OKS_ACTION_TIME_TYPES
WHERE  CLE_ID = p_Cle_ID;

CURSOR Get_Action_Type_Id (p_Id IN NUMBER) IS
SELECT  CLE_ID,object_version_number   --CLE_ID
FROM    OKS_K_LINES_B
WHERE ID = P_ID;


TYPE RowId_Tbl_Type  IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
TYPE Num_Tbl_Type  IS VARRAY(1000) OF NUMBER;
TYPE Date_Tbl_Type IS VARRAY(1000) OF DATE;
TYPE Vc15_Tbl_Type IS VARRAY(1000) OF VARCHAR2(15);
TYPE Vc20_Tbl_Type IS VARRAY(1000) OF VARCHAR2(20);
TYPE Vc150_Tbl_Type IS VARRAY(1000) OF VARCHAR2(150);
TYPE Vc30_Tbl_Type IS VARRAY(1000) OF VARCHAR2(30);
TYPE Vc1_Tbl_Type IS VARRAY(1000) OF VARCHAR2(1);
TYPE Vc3_Tbl_Type IS VARRAY(1000) OF VARCHAR2(3);
TYPE Vc2000_Tbl_Type IS VARRAY(1000) OF VARCHAR2(2000);
TYPE Vc50_Tbl_Type IS VARRAY(1000) OF VARCHAR2(50);
TYPE Vc80_Tbl_Type IS VARRAY(1000) OF VARCHAR2(80);
TYPE Vc120_Tbl_Type IS VARRAY(1000) OF VARCHAR2(120);
TYPE Vc600_Tbl_Type IS VARRAY(1000) OF VARCHAR2(600);


LINE_ID_TBL                 Num_Tbl_Type;
Line_Created_By_TBL         Num_Tbl_Type;
Line_Creation_Date_TBL		Date_Tbl_Type;
Line_Last_Updated_By_TBL    Num_Tbl_Type;
Line_Last_Update_Date_TBL   Date_Tbl_Type;
Line_Last_Update_Login_TBL  Num_Tbl_Type;
RUL_ROW_ID_TBL              RowId_Tbl_Type;
RUL_ID_TBL                 Num_Tbl_Type;
LINE_RGP_ID_TBL             Num_Tbl_Type;
LINE_LSE_ID_TBL             Num_Tbl_Type;
LINE_DNZ_CHR_ID_TBL         Num_Tbl_Type;
LINE_OBJECT1_ID1_TBL        Vc150_Tbl_Type;
LINE_OBJECT2_ID1_TBL        Vc150_Tbl_Type;
COV_RULE_INFO1_TBL         Vc150_Tbl_Type;
COV_RULE_INFO2_TBL         Vc150_Tbl_Type;
COV_RULE_INFO3_TBL         Vc150_Tbl_Type;
COV_RULE_INFO4_TBL         Vc150_Tbl_Type;
COV_RULE_INFO5_TBL         Vc150_Tbl_Type;
COV_RULE_INFO6_TBL         Vc150_Tbl_Type;
COV_RULE_INFO7_TBL         Vc150_Tbl_Type;
COV_RULE_INFO8_TBL         Vc150_Tbl_Type;
COV_RULE_INFO9_TBL         Vc150_Tbl_Type;
COV_RULE_INFO10_TBL         Vc150_Tbl_Type;
COV_RULE_INFO11_TBL         Vc150_Tbl_Type;
COV_RULE_INFO12_TBL         Vc150_Tbl_Type;
COV_RULE_INFO13_TBL         Vc150_Tbl_Type;
COV_RULE_INFO14_TBL         Vc150_Tbl_Type;
COV_RULE_INFO15_TBL         Vc150_Tbl_Type;
COV_RULE_INFO_TBL           Vc150_Tbl_Type;
COV_OBJ_VER_NUMBER_TBL      Num_Tbl_Type;
k_line_id_tbl               Num_Tbl_Type;
Rul_major_version_tbl       Num_Tbl_Type;




L_OLD_CLE_ID                NUMBER  := -99999;
L_CLE_ID                    NUMBER  := -99999;
l_cle_ctr                   NUMBER  := 0;
l_return_Status             VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
x_msg_count                 NUMBER := 0;
x_msg_data                 VArchar2(1000);

l_start_rowid       ROWID := p_start_rowid;
l_end_rowid         ROWID := p_end_rowid;

l_msg_data          VARCHAR2(1000);
l_msg_index_out     NUMBER;
l_message           VARCHAR2(2400);

l_old_line_id NUMBER :=  -9999;
l_line_id NUMBER;

G_EXCEPTION_HALT            EXCEPTION;

BEGIN
G_APP_NAME := 'Reaction_Time_migration';
OPEN Csr_Get_Reaction_Times (l_start_rowid,l_end_rowid);
LOOP
    BEGIN
    FETCH Csr_Get_Reaction_Times BULK COLLECT INTO
            LINE_ID_TBL                 ,
            Line_Created_By_TBL         ,
			Line_Creation_Date_Tbl		,
            Line_Last_Updated_By_TBL    ,
            Line_Last_Update_Date_TBL   ,
            Line_Last_Update_Login_TBL  ,
            RUL_ROW_ID_TBL              ,
            RUL_ID_TBL                  ,
            LINE_RGP_ID_TBL             ,
            LINE_LSE_ID_TBL             ,
            LINE_DNZ_CHR_ID_TBL         ,
            LINE_OBJECT1_ID1_TBL        ,
            LINE_OBJECT2_ID1_TBL        ,
            COV_RULE_INFO1_TBL         ,
            COV_RULE_INFO2_TBL         ,
            COV_RULE_INFO3_TBL         ,
            COV_RULE_INFO4_TBL         ,
            COV_RULE_INFO5_TBL         ,
            COV_RULE_INFO6_TBL         ,
            COV_RULE_INFO7_TBL         ,
            COV_RULE_INFO8_TBL         ,
            COV_RULE_INFO9_TBL         ,
            COV_RULE_INFO10_TBL         ,
            COV_RULE_INFO11_TBL         ,
            COV_RULE_INFO12_TBL         ,
            COV_RULE_INFO13_TBL         ,
            COV_RULE_INFO14_TBL         ,
            COV_RULE_INFO15_TBL         ,
            COV_RULE_INFO_TBL           ,
            COV_OBJ_VER_NUMBER_TBL      ,
            k_line_id_tbl               ,
            Rul_major_version_tbl
            LIMIT 1000;

        IF LINE_ID_TBL.COUNT > 0 THEN  --LINE_ID_TBL.COUNT > 0

        l_act_ctr   :=  0;
        l_cle_ctr   :=  0;

            FOR I IN LINE_ID_TBL.FIRST .. LINE_ID_TBL.LAST LOOP

            L_Cle_id := LINE_ID_TBL(i);

            IF (L_OLD_CLE_ID <> L_CLE_ID) THEN
                l_cle_ctr := l_cle_ctr + 1;

            i_clev_tbl_in(l_cle_ctr).Id :=  k_line_id_tbl(i);    --okc_p_util.raw_to_number(sys_guid());
            l_line_id := LINE_ID_TBL(i);
            i_clev_tbl_in(l_cle_ctr).Created_By   := Line_Created_By_TBL(i);
            i_clev_tbl_in(l_cle_ctr).Creation_Date   := Line_Creation_Date_TBL(i);
            i_clev_tbl_in(l_cle_ctr).Last_Updated_By   := Line_Last_Updated_By_TBL(i);
            i_clev_tbl_in(l_cle_ctr).Last_Update_Date   := Line_Last_Update_Date_TBL(i);
            i_clev_tbl_in(l_cle_ctr).Last_Update_Login  := Line_Last_Update_Login_TBL(i);

            i_clev_tbl_in(l_cle_ctr).Cle_Id         :=  LINE_ID_TBL(i);
            i_clev_tbl_in(l_cle_ctr).Dnz_Chr_Id         :=  LINE_DNZ_CHR_ID_TBL(i);

            i_clev_tbl_in(l_cle_ctr).object_version_number :=  1;
            i_clev_tbl_in(l_cle_ctr).Sync_Date_Install :=  'N';

            IF      ((COV_RULE_INFO_TBL(i) = 'RCN') OR (COV_RULE_INFO_TBL(i) = 'RSN')) THEN

            i_clev_tbl_in(l_cle_ctr).INCIDENT_SEVERITY_ID :=    LINE_OBJECT1_ID1_TBL(i);
            i_clev_tbl_in(l_cle_ctr).PDF_ID               :=    COV_RULE_INFO1_TBL(i);
            i_clev_tbl_in(l_cle_ctr).WORK_THRU_YN         :=    COV_RULE_INFO3_TBL(i);
            i_clev_tbl_in(l_cle_ctr).REACT_ACTIVE_YN      :=    COV_RULE_INFO4_TBL(i);
            i_clev_tbl_in(l_cle_ctr).REACT_TIME_NAME      :=    COV_RULE_INFO2_TBL(i);
            i_clev_tbl_in(l_cle_ctr).major_version        := Rul_major_version_tbl(i);

            END IF;


            -------------------------            FOR TLH-----------------------
                    IF  l_line_id <> l_old_line_id THEN
                         -- dbms_output.put_line('--->Value of Rule_Id_Tbl(l_cle_ctr)='||TO_CHAR(Rul_Id_Tbl(I)));
                        FOR Get_Rule_TlH_REC IN Get_Rule_TlH(Rul_Id_Tbl(l_cle_ctr))  LOOP
                        l_clt_ctr := l_clt_ctr + 1;
                             -- dbms_output.put_line('---------->l_clt_ctr='||TO_CHAR(l_clt_ctr));

                                l_clet_tbl_in(l_clt_ctr).id                 :=  i_clev_tbl_in(l_cle_ctr).id;
                                l_clet_tbl_in(l_clt_ctr).MAJOR_VERSION      := Get_Rule_TlH_REC.MAJOR_VERSION;
                                l_clet_tbl_in(l_clt_ctr).language           :=  Get_Rule_TlH_REC.language;
                                l_clet_tbl_in(l_clt_ctr).source_lang        :=  Get_Rule_TlH_REC.source_lang;
                                l_clet_tbl_in(l_clt_ctr).sfwt_flag          :=  Get_Rule_TlH_REC.sfwt_flag;
                                l_clet_tbl_in(l_clt_ctr).invoice_text       := NULL;--  Get_Rule_TlH_REC.text;
                  --            l_clet_tbl_in(l_clt_ctr).ib_trx_details     :=  Get_Rule_TlH_REC.ib_trx_details;
                      --          l_clet_tbl_in(l_clt_ctr).status_text        :=  Get_Rule_TlH_REC.status_text;
                      --          l_clet_tbl_in(l_clt_ctr).react_time_name    :=  Get_Rule_TlH_REC.react_time_name;
                                l_clet_tbl_in(l_clt_ctr).created_by         :=  Get_Rule_TlH_REC.created_by;
                                l_clet_tbl_in(l_clt_ctr).creation_date      :=  Get_Rule_TlH_REC.creation_date;
                                l_clet_tbl_in(l_clt_ctr).last_updated_by    :=  Get_Rule_TlH_REC.last_updated_by;
                                l_clet_tbl_in(l_clt_ctr).last_update_date   :=  Get_Rule_TlH_REC.last_update_date;
                                l_clet_tbl_in(l_clt_ctr).last_update_login  :=  Get_Rule_TlH_REC.last_update_login;

                        END LOOP;

                                l_old_line_id := l_line_id;
                                 -- dbms_output.put_line('Value of l_old_line_id='||TO_CHAR(l_old_line_id));
                    END IF;

            END IF;            --IF (L_OLD_CLE_ID <> L_CLE_ID) THEN


            L_OLD_CLE_ID := L_CLE_ID;


            END LOOP;

        END IF; ----LINE_ID_TBL.COUNT > 0


    IF i_clev_tbl_in.count > 0 THEN
        Insert_Into_Klines( p_clev_tbl_in   =>  i_clev_tbl_in,
                            p_clet_tbl_in   =>  l_clet_tbl_in,
                            x_return_Status =>  l_return_status);

    FOR I IN i_clev_tbl_in.FIRST .. i_clev_tbl_in.LAST LOOP
     -- dbms_output.put_line('11-->Value of i_clev_tbl_in(I).ID='||TO_CHAR(i_clev_tbl_in(I).ID));
        For Get_Action_Type_Id_Rec IN Get_Action_Type_Id(i_clev_tbl_in(I).ID) LOOP
        FOR Get_Action_Time_Types_Rec IN Get_Action_Time_Types(Get_Action_Type_Id_Rec.CLE_ID) LOOP

                l_return_Status := OKS_ACT_PVT.Create_Version(
                                                                p_id            => Get_Action_Time_Types_Rec.ID,
                                                                p_major_version  => 1) ;
		END LOOP;
		END LOOP;
	END LOOP;
    END IF;

i_clev_tbl_in.DELETE;

        IF l_return_status = 'S' THEN
                        x_return_status := 'S';
                        x_message_data := NULL;
        ELSE
            RAISE G_EXCEPTION_HALT;
        END IF;

EXCEPTION
    WHEN G_EXCEPTION_HALT THEN
    ROLLBACK;
    i_actv_tbl_in.DELETE;
    i_clev_tbl_in.DELETE;

    x_return_status := OKC_API.G_RET_STS_ERROR;
    OKC_API.SET_MESSAGE
   	  (   p_app_name        => G_APP_NAME,
          p_msg_name        => G_UNEXPECTED_ERROR,
          p_token1          => G_SQLCODE_TOKEN,
          p_token1_value    => SQLCODE,
          p_token2          => G_SQLERRM_TOKEN,
          p_token2_value    => SQLERRM
      );

        x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );
         IF x_msg_count > 0              THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
    END IF;
                x_message_data  := l_message;
                x_return_status := 'E';
    WHEN Others THEN
    ROLLBACK;
    i_actv_tbl_in.DELETE;
    i_clev_tbl_in.DELETE;

    x_return_status := OKC_API.G_RET_STS_ERROR;
    OKC_API.SET_MESSAGE
   	  (   p_app_name        => G_APP_NAME,
          p_msg_name        => G_UNEXPECTED_ERROR,
          p_token1          => G_SQLCODE_TOKEN,
          p_token1_value    => SQLCODE,
          p_token2          => G_SQLERRM_TOKEN,
          p_token2_value    => SQLERRM
          );

        x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );
         IF x_msg_count > 0              THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
    END IF;
                x_message_data  := l_message;
                x_return_status := 'E';
END;

EXIT WHEN Csr_Get_Reaction_Times%NOTFOUND;

END LOOP;

CLOSE     Csr_Get_Reaction_Times;
END Reaction_Time_Hist_migration;


PROCEDURE React_TimeVal_Hist_Migration ( x_return_status OUT NOCOPY VARCHAR2,
                                            x_message_data  OUT NOCOPY VARCHAR2) IS


    CURSOR Csr_Get_Timevalues   IS

SELECT  TYP.id  Action_Type_ID,
                TYP.cle_id Action_Type_Cle_ID ,
                TYP.dnz_chr_id Action_Type_Dnz_ID ,
                TYP.Created_By  Created_By,
                TYP.Last_Updated_By Last_Updated_By,
                TYP.Last_Update_Date    Last_Update_Date,
                TYP.Last_Update_Login   Last_Update_Login,
                RIN.UOM_CODE    UOM_CODE,
                RIN.DURATION    DURATION,
                TIM.DAY_OF_WEEK DAY_OF_WEEK,
                TIM.TVE_TYPE    TVE_TYPE,
                Rul.ID          RUL_ID,
                Rul.major_version Rul_major_version
           FROM    oks_action_time_types_h TYP,
                okc_rule_groups_bh RGP,okc_rules_bh  RUL,
                okc_timevalues_bh TIM,okc_react_intervals_h RIN
        WHERE RGP.CLE_ID = TYP.CLE_ID
        AND   RGP.DNZ_CHR_ID = TYP.DNZ_CHR_ID
        AND   RGP.ID    = RUL.RGP_ID
        AND   RGP.DNZ_CHR_ID = RUL.DNZ_CHR_ID
        AND   RUL.DNZ_CHR_ID = TYP.DNZ_CHR_ID
        AND   RUL.ID =   RIN.RUL_ID
        AND   rul.RULE_INFORMATION_CATEGORY = typ.ACTION_TYPE_CODE
        AND   RIN.DNZ_CHR_ID = TYP.DNZ_CHR_ID
        AND   TIM.ID   =   RIN.TVE_ID
        AND   TIM.DNZ_CHR_ID    =  RIN.DNZ_CHR_ID
        AND   TIM.DNZ_CHR_ID    =  RGP.DNZ_CHR_ID
        AND   TIM.DNZ_CHR_ID    =  RUL.DNZ_CHR_ID
        AND   TIM.DNZ_CHR_ID    =  TYP.DNZ_CHR_ID
        AND   RGP.major_version = TYP.major_version
        AND   RGP.major_version = rul.major_version
        AND   rul.major_version = TYP.major_version
        AND   RIN.major_version = TYP.major_version
        AND   RIN.major_version = RUL.major_version
        AND   TIM.major_version   = RIN.major_version
        AND NOT EXISTS (Select cle_id FROM OKS_ACTION_TIMES_H WHERE CLE_ID = TYP.cle_id and major_version = typ.major_version)
        ORDER BY RUL.ID;


TYPE RowId_Tbl_Type  IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
TYPE Num_Tbl_Type  IS VARRAY(1000) OF NUMBER;

TYPE Vc15_Tbl_Type IS VARRAY(1000) OF VARCHAR2(15);
TYPE Vc20_Tbl_Type IS VARRAY(1000) OF VARCHAR2(20);
TYPE Date_Tbl_Type IS VARRAY(1000) OF DATE;

l_acm_ctr   NUMBER :=0;

l_return_status            VArchar2(2):= 'S';

x_msg_count                 NUMBER := 0;
x_msg_data                 VArchar2(1000);

l_msg_data          VARCHAR2(1000);
l_msg_index_out     NUMBER;
l_message           VARCHAR2(2400);
--l_start_rowid       ROWID := p_start_rowid;
--l_end_rowid         ROWID := p_end_rowid;
l_rul_id                NUMBER := -9999;

G_EXCEPTION_HALT        EXCEPTION;

Action_Type_ID_TBL      Num_Tbl_Type;
Action_Type_Cle_ID_TBL  Num_Tbl_Type;
Action_Type_Dnz_ID_TBL  Num_Tbl_Type;
Created_By_TBL          Num_Tbl_Type;
Last_Updated_By_TBL     Num_Tbl_Type;
Last_Update_Date_TBL    Date_Tbl_Type;
Last_Update_Login_TBL   Num_Tbl_Type;
UOM_CODE_TBL            Vc20_Tbl_Type;
DURATION_TBL            Num_Tbl_Type;
DAY_OF_WEEK_TBL         Vc20_Tbl_Type;
TVE_TYPE_TBL            Vc20_Tbl_Type;
RUL_ID_TBL              Num_Tbl_Type;
Rul_major_version_tbl   Num_Tbl_Type;

BEGIN

G_APP_NAME := 'Reaction_TimeValues_Migration';

OPEN Csr_Get_Timevalues ;
LOOP
    BEGIN
    FETCH Csr_Get_Timevalues BULK COLLECT INTO
            Action_Type_ID_TBL,
            Action_Type_Cle_ID_TBL,
            Action_Type_Dnz_ID_TBL,
            Created_By_TBL,
            Last_Updated_By_TBL,
            Last_Update_Date_TBL,
            Last_Update_Login_TBL,
            UOM_CODE_TBL,
            DURATION_TBL,
            DAY_OF_WEEK_TBL,
            TVE_TYPE_TBL,
            RUL_ID_TBL,
            Rul_major_version_tbl
            LIMIT 1000;

          --   -- dbms_output.put_line('Value of Action_Type_ID_TBL.COUNT='||TO_CHAR(Action_Type_ID_TBL.COUNT));

    IF  Action_Type_ID_TBL.COUNT > 0 THEN
            FOR I IN Action_Type_ID_TBL.FIRST .. Action_Type_ID_TBL.LAST LOOP

            IF  l_rul_id  <> RUL_ID_TBL(I) THEN

                l_rul_id := RUL_ID_TBL(I);
                l_acm_ctr := l_acm_ctr + 1;

                i_acmv_tbl_in(l_acm_ctr).Created_By         := Created_By_TBL(i);
                i_acmv_tbl_in(l_acm_ctr).Last_Updated_By    := Last_Updated_By_TBL(i);
                i_acmv_tbl_in(l_acm_ctr).Last_Update_Date   := Last_Update_Date_TBL(i);
                i_acmv_tbl_in(l_acm_ctr).Last_Update_Login  := Last_Update_Login_TBL(i);
                i_acmv_tbl_in(l_acm_ctr).SECURITY_GROUP_ID      := NULL;
                i_acmv_tbl_in(l_acm_ctr).PROGRAM_APPLICATION_ID := NULL;
                i_acmv_tbl_in(l_acm_ctr).PROGRAM_ID := NULL;
                i_acmv_tbl_in(l_acm_ctr).PROGRAM_UPDATE_DATE := NULL;
                i_acmv_tbl_in(l_acm_ctr).REQUEST_ID := NULL;

                i_acmv_tbl_in(l_acm_ctr).ID := okc_p_util.raw_to_number(sys_guid());
                i_acmv_tbl_in(l_acm_ctr).COV_ACTION_TYPE_ID := Action_Type_ID_TBL(i);
                i_acmv_tbl_in(l_acm_ctr).CLE_ID             := Action_Type_Cle_ID_TBL(i);
                i_acmv_tbl_in(l_acm_ctr).Dnz_chr_id       := Action_Type_Dnz_ID_TBL(i);
                i_acmv_tbl_in(l_acm_ctr).UOM_CODE       :=  UOM_CODE_TBL(i);
                i_acmv_tbl_in(l_acm_ctr).object_version_number :=  1;

                    i_acmv_tbl_in(l_acm_ctr).SUN_DURATION   :=  NULL;
                    i_acmv_tbl_in(l_acm_ctr).MON_DURATION   :=  NULL;
                    i_acmv_tbl_in(l_acm_ctr).TUE_DURATION   :=  NULL;
                    i_acmv_tbl_in(l_acm_ctr).WED_DURATION   :=  NULL;
                    i_acmv_tbl_in(l_acm_ctr).THU_DURATION   :=  NULL;
                    i_acmv_tbl_in(l_acm_ctr).FRI_DURATION   :=  NULL;
                    i_acmv_tbl_in(l_acm_ctr).SAT_DURATION   :=  NULL;
                    i_acmv_tbl_in(l_acm_ctr).major_version := Rul_major_version_tbl(I);
            END IF;

                IF DAY_OF_WEEK_TBL(i) = 'SUN' THEN
                    i_acmv_tbl_in(l_acm_ctr).SUN_DURATION   := DURATION_TBL(i);

                ELSIF DAY_OF_WEEK_TBL(i) = 'MON' THEN
                    i_acmv_tbl_in(l_acm_ctr).MON_DURATION   := DURATION_TBL(i);

                ELSIF DAY_OF_WEEK_TBL(i) = 'TUE' THEN
                    i_acmv_tbl_in(l_acm_ctr).TUE_DURATION   := DURATION_TBL(i);

                ELSIF DAY_OF_WEEK_TBL(i) = 'WED' THEN
                    i_acmv_tbl_in(l_acm_ctr).WED_DURATION   := DURATION_TBL(i);

                ELSIF DAY_OF_WEEK_TBL(i) = 'THU' THEN
                    i_acmv_tbl_in(l_acm_ctr).THU_DURATION   := DURATION_TBL(i);

                ELSIF DAY_OF_WEEK_TBL(i) = 'FRI' THEN
                    i_acmv_tbl_in(l_acm_ctr).FRI_DURATION   := DURATION_TBL(i);

                ELSIF DAY_OF_WEEK_TBL(i) = 'SAT' THEN
                    i_acmv_tbl_in(l_acm_ctr).SAT_DURATION   := DURATION_TBL(i);
                END IF;

            END LOOP;
            END IF;


IF  i_acmv_tbl_in.COUNT > 0 THEN
            i  := i_acmv_tbl_in.FIRST; K:=0;

            WHILE  I is not null   LOOP

                k:=k+1;

                IN_ID(K) :=     i_acmv_tbl_in(I).ID ;
                IN_COV_ACTION_TYPE_ID(K) :=     i_acmv_tbl_in(I).COV_ACTION_TYPE_ID ;
                IN_CLE_ID(K) :=     i_acmv_tbl_in(I).CLE_ID ;
                IN_DNZ_CHR_ID(K) :=     i_acmv_tbl_in(I).DNZ_CHR_ID ;
                IN_UOM_CODE(K) :=   i_acmv_tbl_in(I).UOM_CODE ;
                IN_SUN_DURATION(K) :=   i_acmv_tbl_in(I).SUN_DURATION ;
                IN_MON_DURATION(K) :=   i_acmv_tbl_in(I).MON_DURATION ;
                IN_TUE_DURATION(K) :=   i_acmv_tbl_in(I).TUE_DURATION ;
                IN_WED_DURATION(K) :=   i_acmv_tbl_in(I).WED_DURATION ;
                IN_THU_DURATION(K) :=   i_acmv_tbl_in(I).THU_DURATION ;
                IN_FRI_DURATION(K) :=   i_acmv_tbl_in(I).FRI_DURATION ;
                IN_SAT_DURATION(K) :=   i_acmv_tbl_in(I).SAT_DURATION ;
                IN_SECURITY_GROUP_ID(K) :=  i_acmv_tbl_in(I).SECURITY_GROUP_ID ;
                IN_PROGRAM_APPLICATION_ID(K) :=     i_acmv_tbl_in(I).PROGRAM_APPLICATION_ID ;
                IN_PROGRAM_ID(K) :=     i_acmv_tbl_in(I).PROGRAM_ID ;
                IN_PROGRAM_UPDATE_DATE(K) :=    i_acmv_tbl_in(I).PROGRAM_UPDATE_DATE ;
                IN_REQUEST_ID(K) :=     i_acmv_tbl_in(I).REQUEST_ID ;
                IN_CREATED_BY(K) :=     i_acmv_tbl_in(I).CREATED_BY ;
                IN_CREATION_DATE(K) :=  i_acmv_tbl_in(I).CREATION_DATE ;
                IN_LAST_UPDATED_BY(K) :=    i_acmv_tbl_in(I).LAST_UPDATED_BY ;
                IN_LAST_UPDATE_DATE(K) :=   i_acmv_tbl_in(I).LAST_UPDATE_DATE ;
                IN_LAST_UPDATE_LOGIN(K) :=  i_acmv_tbl_in(I).LAST_UPDATE_LOGIN ;
                IN_OBJECT_VERSION_NUMBER(K) :=  i_acmv_tbl_in(I).OBJECT_VERSION_NUMBER ;
                IN_MAJOR_VERSION(K) :=  i_acmv_tbl_in(I).MAJOR_VERSION ;

                i:=i_acmv_tbl_in.next(i);

            END LOOP;

                l_tabsize := i_acmv_tbl_in.COUNT;
--                l_status := 'Before Insert';

            FORALL I IN  1  ..   l_tabsize
            INSERT INTO     OKS_ACTION_TIMES_H(
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
                                                CREATION_DATE,
                                                LAST_UPDATED_BY,
                                                LAST_UPDATE_DATE,
                                                LAST_UPDATE_LOGIN,
                                                OBJECT_VERSION_NUMBER,
                                                MAJOR_VERSION)
            VALUES                             (
                                                IN_ID(I),
                                                IN_COV_ACTION_TYPE_ID(I),
                                                IN_CLE_ID(I),
                                                IN_DNZ_CHR_ID(I),
                                                IN_UOM_CODE(I),
                                                IN_SUN_DURATION(I),
                                                IN_MON_DURATION(I),
                                                IN_TUE_DURATION(I),
                                                IN_WED_DURATION(I),
                                                IN_THU_DURATION(I),
                                                IN_FRI_DURATION(I),
                                                IN_SAT_DURATION(I),
                                                IN_SECURITY_GROUP_ID(I),
                                                IN_PROGRAM_APPLICATION_ID(I),
                                                IN_PROGRAM_ID(I),
                                                IN_PROGRAM_UPDATE_DATE(I),
                                                IN_REQUEST_ID(I),
                                                IN_CREATED_BY(I),
                                                IN_CREATION_DATE(I),
                                                IN_LAST_UPDATED_BY(I),
                                                IN_LAST_UPDATE_DATE(I),
                                                IN_LAST_UPDATE_LOGIN(I),
                                                IN_OBJECT_VERSION_NUMBER(I),
                                                IN_MAJOR_VERSION(I));

    IF l_return_Status = 'S' THEN
        X_return_Status := 'S';
        X_Message_Data := NULL;
        COMMIT;
    ELSE
        RAISE G_EXCEPTION_HALT;
    END IF;

END IF;

    EXIT WHEN Csr_Get_Timevalues%NOTFOUND;

EXCEPTION
    WHEN G_EXCEPTION_HALT THEN

    ROLLBACK;
    OKC_API.SET_MESSAGE
    (     p_app_name        => G_APP_NAME,
          p_msg_name        => G_UNEXPECTED_ERROR,
          p_token1          => G_SQLCODE_TOKEN,
          p_token1_value    => SQLCODE,
          p_token2          => G_SQLERRM_TOKEN,
          p_token2_value    => SQLERRM
    );

                      x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );

        IF x_msg_count > 0  THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
        END IF;
                x_message_data  := l_message;
                x_return_status := 'E';


    WHEN Others THEN
    x_return_status := OKC_API.G_RET_STS_ERROR;
    OKC_API.SET_MESSAGE
    (     p_app_name        => G_APP_NAME,
          p_msg_name        => G_UNEXPECTED_ERROR,
          p_token1          => G_SQLCODE_TOKEN,
          p_token1_value    => SQLCODE,
          p_token2          => G_SQLERRM_TOKEN,
          p_token2_value    => SQLERRM
    );
                      x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );
         IF x_msg_count > 0              THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
    END IF;
                x_message_data  := l_message;
                x_return_status := 'E';
--                EXIT;
    END;

    EXIT WHEN Csr_Get_Timevalues%NOTFOUND;

 i_acmv_tbl_in.DELETE;

END LOOP;

IF  Csr_Get_Timevalues%ISOPEN        THEN
    CLOSE Csr_Get_Timevalues;
END IF;


--CLOSE Csr_Get_Timevalues;
EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;

END React_TimeVal_Hist_Migration;



PROCEDURE BILL_TYPE_HIST_MIGRATION( p_start_rowid   IN ROWID,
                                    p_end_rowid     IN ROWID,
                                    x_return_status OUT NOCOPY VARCHAR2,
                                    x_message_data  OUT NOCOPY VARCHAR2) IS

CURSOR Csr_Get_Bill_Types (l_start_rowid IN ROWID ,l_end_rowid IN ROWID ) IS
    SELECT
        LINE.ID LINE_ID,
        Line.Created_By Line_Created_By,
		Line.Creation_Date		Line_Creation_Date,
        Line.Last_Updated_By    Line_Last_Updated_By,
        Line.Last_Update_Date   Line_Last_Update_Date,
        Line.Last_Update_Login  Line_Last_Update_Login,
        Rul.ROWID   RUL_ROW_ID,
        Rul.ID      Rul_Id,
        RGP.ID LINE_RGP_ID,
        LINE.LSE_ID LINE_LSE_ID,
        LINE.DNZ_CHR_ID LINE_DNZ_CHR_ID,
        OBJECT1_ID1  LINE_OBJECT1_ID1,
        OBJECT2_ID1 LINE_OBJECT2_ID1,
        RULE_INFORMATION1  COV_RULE_INFO1,
        RULE_INFORMATION2  COV_RULE_INFO2,
        RULE_INFORMATION3  COV_RULE_INFO3,
        RULE_INFORMATION4  COV_RULE_INFO4,
        RULE_INFORMATION5  COV_RULE_INFO5,
        RULE_INFORMATION6  COV_RULE_INFO6,
        RULE_INFORMATION7  COV_RULE_INFO7,
        RULE_INFORMATION8  COV_RULE_INFO8,
        RULE_INFORMATION9  COV_RULE_INFO9,
        RULE_INFORMATION10 COV_RULE_INFO10,
        RULE_INFORMATION11 COV_RULE_INFO11,
        RULE_INFORMATION12 COV_RULE_INFO12,
        RULE_INFORMATION13 COV_RULE_INFO13,
        RULE_INFORMATION14 COV_RULE_INFO14,
        RULE_INFORMATION15 COV_RULE_INFO15,
        RULE_INFORMATION_CATEGORY  COV_RULE_INFO,
        RUL.OBJECT_VERSION_NUMBER  COV_OBJ_VER_NUMBER,
        RUL.MAJOR_VERSION   RUL_MAJOR_VERSION
    FROM
       OKC_RULE_GROUPS_BH RGP,
       OKC_RULES_BH RUL,
       OKC_K_LINES_BH LINE
  WHERE LINE.ID = RGP.CLE_ID
  AND    RGP.ID  = RUL.RGP_ID
  AND    LINE.LSE_ID IN (5,59,23)
  --AND    RUL.RULE_INFORMATION_CATEGORY IN ('LMT')
  AND    Rul.rowid BETWEEN l_start_rowid and l_end_rowid
  AND  RGP.MAJOR_VERSION = LINE.MAJOR_VERSION
  AND  RGP.MAJOR_VERSION = RUL.MAJOR_VERSION
  AND    NOT EXISTS (SELECT CLE_ID FROM OKS_K_LINES_BH WHERE CLE_ID = LINE.ID)
  ORDER BY LINE.ID;

CURSOR Get_Rule_TlH (P_ID IN NUMBER) IS
    SELECT    ID,
            MAJOR_VERSION,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            COMMENTS,
            TEXT,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            SECURITY_GROUP_ID
    FROM        OKC_RULES_TLH
    WHERE       ID = P_ID;


TYPE RowId_Tbl_Type  IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
TYPE Num_Tbl_Type  IS VARRAY(1000) OF NUMBER;
TYPE Date_Tbl_Type IS VARRAY(1000) OF DATE;
TYPE Vc15_Tbl_Type IS VARRAY(1000) OF VARCHAR2(15);
TYPE Vc20_Tbl_Type IS VARRAY(1000) OF VARCHAR2(20);
TYPE Vc150_Tbl_Type IS VARRAY(1000) OF VARCHAR2(150);
TYPE Vc30_Tbl_Type IS VARRAY(1000) OF VARCHAR2(30);
TYPE Vc1_Tbl_Type IS VARRAY(1000) OF VARCHAR2(1);
TYPE Vc3_Tbl_Type IS VARRAY(1000) OF VARCHAR2(3);
TYPE Vc2000_Tbl_Type IS VARRAY(1000) OF VARCHAR2(2000);
TYPE Vc50_Tbl_Type IS VARRAY(1000) OF VARCHAR2(50);
TYPE Vc80_Tbl_Type IS VARRAY(1000) OF VARCHAR2(80);
TYPE Vc120_Tbl_Type IS VARRAY(1000) OF VARCHAR2(120);
TYPE Vc600_Tbl_Type IS VARRAY(1000) OF VARCHAR2(600);


LINE_ID_TBL                 Num_Tbl_Type;
Line_Created_By_TBL         Num_Tbl_Type;
Line_Creation_Date_TBL		Date_Tbl_Type;
Line_Last_Updated_By_TBL    Num_Tbl_Type;
Line_Last_Update_Date_TBL   Date_Tbl_Type;
Line_Last_Update_Login_TBL  Num_Tbl_Type;
RUL_ROW_ID_TBL              RowId_Tbl_Type;
LINE_RGP_ID_TBL             Num_Tbl_Type;
LINE_LSE_ID_TBL             Num_Tbl_Type;
LINE_DNZ_CHR_ID_TBL         Num_Tbl_Type;
LINE_OBJECT1_ID1_TBL        Vc150_Tbl_Type;
LINE_OBJECT2_ID1_TBL        Vc150_Tbl_Type;
COV_RULE_INFO1_TBL         Vc150_Tbl_Type;
COV_RULE_INFO2_TBL         Vc150_Tbl_Type;
COV_RULE_INFO3_TBL         Vc150_Tbl_Type;
COV_RULE_INFO4_TBL         Vc150_Tbl_Type;
COV_RULE_INFO5_TBL         Vc150_Tbl_Type;
COV_RULE_INFO6_TBL         Vc150_Tbl_Type;
COV_RULE_INFO7_TBL         Vc150_Tbl_Type;
COV_RULE_INFO8_TBL         Vc150_Tbl_Type;
COV_RULE_INFO9_TBL         Vc150_Tbl_Type;
COV_RULE_INFO10_TBL         Vc150_Tbl_Type;
COV_RULE_INFO11_TBL         Vc150_Tbl_Type;
COV_RULE_INFO12_TBL         Vc150_Tbl_Type;
COV_RULE_INFO13_TBL         Vc150_Tbl_Type;
COV_RULE_INFO14_TBL         Vc150_Tbl_Type;
COV_RULE_INFO15_TBL         Vc150_Tbl_Type;
COV_RULE_INFO_TBL           Vc150_Tbl_Type;
COV_OBJ_VER_NUMBER_TBL         Num_Tbl_Type;
RUL_MAJOR_VERSION_TBL          Num_Tbl_Type;
Rul_Id_Tbl                     Num_Tbl_Type;

--h_clev_tbl_in             	oks_kln_pvt.klnv_tbl_type;
--i_clev_tbl_in             	oks_kln_pvt.klnv_tbl_type;

l_cle_ctr                   NUMBER := 0;
tablename1                  VArchar2(1000);
x_msg_count                 NUMBER := 0;
x_msg_data                 VArchar2(1000);
L_OLD_CLE_ID                NUMBER  := -99999;
L_CLE_ID                    NUMBER  := -99999;
l_duration                  NUMBER;
l_period                    VArchar2(10);
l_return_status            VArchar2(1) := OKC_API.G_RET_STS_SUCCESS;
G_EXCEPTION_HALT            EXCEPTION;

l_start_rowid       ROWID := p_start_rowid;
l_end_rowid         ROWID := p_end_rowid;

l_msg_data          VARCHAR2(1000);
l_msg_index_out     NUMBER;
l_message           VARCHAR2(2400);

l_line_id           NUMBER := -9999;
l_old_line_id       NUMBER := -9999;

BEGIN
G_APP_NAME := 'BILL_TYPES_MIGRATION';
OPEN Csr_Get_Bill_Types (l_start_rowid,l_end_rowid);
LOOP
    BEGIN
    FETCH Csr_Get_Bill_Types BULK COLLECT INTO
            LINE_ID_TBL                 ,
            Line_Created_By_TBL         ,
			Line_Creation_Date_Tbl		,
            Line_Last_Updated_By_TBL    ,
            Line_Last_Update_Date_TBL   ,
            Line_Last_Update_Login_TBL  ,
            RUL_ROW_ID_TBL              ,
            Rul_Id_Tbl                  ,
            LINE_RGP_ID_TBL             ,
            LINE_LSE_ID_TBL             ,
            LINE_DNZ_CHR_ID_TBL         ,
            LINE_OBJECT1_ID1_TBL        ,
            LINE_OBJECT2_ID1_TBL        ,
            COV_RULE_INFO1_TBL         ,
            COV_RULE_INFO2_TBL         ,
            COV_RULE_INFO3_TBL         ,
            COV_RULE_INFO4_TBL         ,
            COV_RULE_INFO5_TBL         ,
            COV_RULE_INFO6_TBL         ,
            COV_RULE_INFO7_TBL         ,
            COV_RULE_INFO8_TBL         ,
            COV_RULE_INFO9_TBL         ,
            COV_RULE_INFO10_TBL         ,
            COV_RULE_INFO11_TBL         ,
            COV_RULE_INFO12_TBL         ,
            COV_RULE_INFO13_TBL         ,
            COV_RULE_INFO14_TBL         ,
            COV_RULE_INFO15_TBL         ,
            COV_RULE_INFO_TBL           ,
            COV_OBJ_VER_NUMBER_TBL      ,
            RUL_MAJOR_VERSION_TBL
            LIMIT 1000;


 -- dbms_output.put_line('Value of LINE_ID_TBL.COUNT='||TO_CHAR(LINE_ID_TBL.COUNT));

        IF LINE_ID_TBL.COUNT > 0 THEN

            FOR I IN LINE_ID_TBL.FIRST .. LINE_ID_TBL.LAST LOOP
            L_Cle_id := LINE_ID_TBL(i);
            IF (L_OLD_CLE_ID <> L_CLE_ID) THEN
                l_cle_ctr := l_cle_ctr + 1;
            END IF;
            l_line_id := LINE_ID_TBL(i);

            i_clev_tbl_in(l_cle_ctr).Id := okc_p_util.raw_to_number(sys_guid());
            i_clev_tbl_in(l_cle_ctr).Created_By   := Line_Created_By_tbl(i);
            i_clev_tbl_in(l_cle_ctr).Creation_Date   := Line_Creation_Date_TBL(i);
            i_clev_tbl_in(l_cle_ctr).Last_Updated_By   :=
									Line_Last_Updated_By_TBL(i);
            i_clev_tbl_in(l_cle_ctr).Last_Update_Date   :=
									Line_Last_Update_Date_TBL(i);
            i_clev_tbl_in(l_cle_ctr).Last_Update_Login  := Line_Last_Update_Login_TBL(i);
            i_clev_tbl_in(l_cle_ctr).Cle_Id         :=  LINE_ID_TBL(i);
            i_clev_tbl_in(l_cle_ctr).Dnz_Chr_Id         :=  LINE_DNZ_CHR_ID_TBL(i);
            i_clev_tbl_in(l_cle_ctr).object_version_number :=  1;
            i_clev_tbl_in(l_cle_ctr).Sync_Date_Install :=  'N';

            IF   COV_RULE_INFO_TBL(i) = 'LMT' THEN
                i_clev_tbl_in(l_cle_ctr).LIMIT_UOM_QUANTIFIED  := COV_RULE_INFO1_TBL(i);
                i_clev_tbl_in(l_cle_ctr).DISCOUNT_AMOUNT       := COV_RULE_INFO2_TBL(i);
                i_clev_tbl_in(l_cle_ctr).DISCOUNT_PERCENT      := COV_RULE_INFO4_TBL(i);
                i_clev_tbl_in(l_cle_ctr).major_version        := Rul_major_version_tbl(i);
            END IF;


            -------------------------            FOR TLH-----------------------
                    IF  l_line_id <> l_old_line_id THEN
                         -- dbms_output.put_line('--->Value of Rule_Id_Tbl(l_cle_ctr)='||TO_CHAR(Rul_Id_Tbl(I)));
                        FOR Get_Rule_TlH_REC IN Get_Rule_TlH(Rul_Id_Tbl(l_cle_ctr))  LOOP
                        l_clt_ctr := l_clt_ctr + 1;
                             -- dbms_output.put_line('---------->l_clt_ctr='||TO_CHAR(l_clt_ctr));
                                l_clet_tbl_in(l_clt_ctr).id                 :=  i_clev_tbl_in(l_cle_ctr).id;
                                l_clet_tbl_in(l_clt_ctr).MAJOR_VERSION      := Get_Rule_TlH_REC.MAJOR_VERSION;
                                l_clet_tbl_in(l_clt_ctr).language           :=  Get_Rule_TlH_REC.language;
                                l_clet_tbl_in(l_clt_ctr).source_lang        :=  Get_Rule_TlH_REC.source_lang;
                                l_clet_tbl_in(l_clt_ctr).sfwt_flag          :=  Get_Rule_TlH_REC.sfwt_flag;
                                l_clet_tbl_in(l_clt_ctr).invoice_text       :=  NULL; --Get_Rule_TlH_REC.text;
                  --            l_clet_tbl_in(l_clt_ctr).ib_trx_details     :=  Get_Rule_TlH_REC.ib_trx_details;
                      --          l_clet_tbl_in(l_clt_ctr).status_text        :=  Get_Rule_TlH_REC.status_text;
                      --          l_clet_tbl_in(l_clt_ctr).react_time_name    :=  Get_Rule_TlH_REC.react_time_name;
                                l_clet_tbl_in(l_clt_ctr).created_by         :=  Get_Rule_TlH_REC.created_by;
                                l_clet_tbl_in(l_clt_ctr).creation_date      :=  Get_Rule_TlH_REC.creation_date;
                                l_clet_tbl_in(l_clt_ctr).last_updated_by    :=  Get_Rule_TlH_REC.last_updated_by;
                                l_clet_tbl_in(l_clt_ctr).last_update_date   :=  Get_Rule_TlH_REC.last_update_date;
                                l_clet_tbl_in(l_clt_ctr).last_update_login  :=  Get_Rule_TlH_REC.last_update_login;

                        END LOOP;

                                l_old_line_id := l_line_id;
                                 -- dbms_output.put_line('Value of l_old_line_id='||TO_CHAR(l_old_line_id));
                    END IF;




            L_OLD_CLE_ID := L_CLE_ID;
            END LOOP;
        END IF;


         tablename1 := 'OKS_K_LINES';

         IF i_clev_tbl_in.count > 0 THEN
 -- dbms_output.put_line('Value of i_clev_tbl_in='||TO_CHAR(i_clev_tbl_in.COUNT));
 -- dbms_output.put_line('Value of l_clet_tbl_in='||TO_CHAR(l_clet_tbl_in.COUNT));
            Insert_Into_Klines( p_clev_tbl_in   =>  i_clev_tbl_in,
                                p_clet_tbl_in   =>  l_clet_tbl_in,
                                x_return_Status =>  l_return_status);
        END IF;


         IF l_return_status = 'S' THEN
            x_return_status := 'S';
            x_message_data := NULL;
        ELSE
            RAISE G_EXCEPTION_HALT;
        END IF;

EXCEPTION
    WHEN G_EXCEPTION_HALT THEN
    ROLLBACK;

      x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );
    i_clev_tbl_in.DELETE;

         IF x_msg_count > 0              THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
    END IF;
                x_message_data  := l_message;
                x_return_status := 'E';
    WHEN Others THEN
    ROLLBACK;
    x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );
    i_clev_tbl_in.DELETE;
         IF x_msg_count > 0              THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
    END IF;
                x_message_data  := l_message;
                x_return_status := 'E';
        EXIT WHEN Csr_Get_Bill_Types%NOTFOUND;
    END;

        EXIT WHEN Csr_Get_Bill_Types%NOTFOUND;

END LOOP;

CLOSE Csr_Get_Bill_Types;

EXCEPTION
    WHEN Others THEN
    x_return_status :=    OKC_API.HANDLE_EXCEPTIONS(
                                                    G_APP_NAME,
                                                    G_PKG_NAME,
                                                    'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                    x_msg_count,
                                                    x_msg_data,
                                                    '_PVT'
                                                   );
     IF x_msg_count > 0              THEN
              FOR i in 1..x_msg_count   LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
            l_message := l_message||' ; '||l_msg_data;

              END LOOP;
    END IF;
                x_message_data  := l_message;
                x_return_status := 'E';

END BILL_TYPE_HIST_MIGRATION;



/*********************************** HISTORY ****************************************/




END OKS_COVERAGE_MIGRATION;



/
