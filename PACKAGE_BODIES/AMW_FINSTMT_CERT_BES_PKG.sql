--------------------------------------------------------
--  DDL for Package Body AMW_FINSTMT_CERT_BES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_FINSTMT_CERT_BES_PKG" AS
/* $Header: amwfbusb.pls 120.28 2007/12/10 06:41:35 srbalasu noship $  */

--G_USER_ID NUMBER   := FND_GLOBAL.USER_ID;
--G_LOGIN_ID NUMBER  := FND_GLOBAL.CONC_LOGIN_ID;

G_PKG_NAME    CONSTANT VARCHAR2 (30) := 'AMW_FINSTMT_CERT_BES_PKG';
G_API_NAME   CONSTANT VARCHAR2 (15) := 'amwfbusb.pls';


G_START_DATE DATE;
G_END_DATE DATE;

l_index number;

--l_result_ok CONSTANT VARCHAR2 (30) := 'SUCCESS';
--l_result_err CONSTANT VARCHAR2 (30) := 'ERROR';


PROCEDURE Initialize(p_certification_id NUMBER) IS
l_cert_id  NUMBER ;
l_error_message varchar2(4000);

BEGIN


l_cert_id := p_certification_id;

GetGLPeriodfor_FinCertEvalSum
(P_Certification_ID => l_cert_id,
 P_start_date => G_START_DATE,
 P_end_date => G_END_DATE
);


EXCEPTION WHEN OTHERS THEN
    fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Initialize'
              || SUBSTR (SQLERRM, 1, 100), 1, 200));
    l_error_message := 'Error '||TO_CHAR(SQLCODE)||': '||SQLERRM ;

END Initialize;


/* **************************** DELETE_ROWS in case of refresh data for a particular certification ******************* */

procedure DELETE_ROWS ( x_fin_certification_id    NUMBER, x_table_name VARCHAR2  )
IS
l_sql_stmt VARCHAR2(2000);
begin

  l_sql_stmt := 'DELETE FROM ' || x_table_name || ' WHERE  fin_certification_id     =  : 1 ';

 EXECUTE IMMEDIATE l_sql_stmt USING x_fin_certification_id;


EXCEPTION
 WHEN NO_DATA_FOUND THEN
    /*** Record doesn't exist ***/
    fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.DELETE_FIN_CERT_SUM_ROWS');
WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
  fnd_file.put_line(fnd_file.LOG,  'fin_certification_id  ' || x_fin_certification_id  );

 RAISE ;
 RETURN;

end DELETE_ROWS ;


PROCEDURE  Is_Eval_Change
(
    old_opinion_log_id          IN    	NUMBER,
    new_opinion_log_id          IN    	NUMBER,
    x_change_flag	    OUT NOCOPY  VARCHAR2
)
IS

l_old_opinion_value_code amw_opinion_values_b.opinion_value_code%type;
l_new_opinion_value_code amw_opinion_values_b.opinion_value_code%type;

CURSOR Get_Opinion_Value(p_opinion_log_id NUMBER)IS
SELECT OPINION_VALUE_CODE INTO l_old_opinion_value_code
FROM AMW_OPINION_VALUES_B value,
AMW_OPINION_LOG_DETAILS detail,
AMW_OPINION_COMPONTS_B comp
WHERE detail.opinion_log_id = p_opinion_log_id
AND detail.opinion_component_id = comp.opinion_component_id
AND comp.opinion_component_code = 'OVERALL'
AND detail.opinion_value_id = value.opinion_value_id;

BEGIN

IF(old_opinion_log_id <> 0 and  old_opinion_log_id IS NOT NULL ) THEN
OPEN Get_Opinion_Value(old_opinion_log_id);
FETCH Get_Opinion_Value INTO l_old_opinion_value_code;
CLOSE Get_Opinion_Value;
END IF;

OPEN Get_Opinion_Value(new_opinion_log_id);
FETCH Get_Opinion_Value INTO l_new_opinion_value_code;
CLOSE Get_Opinion_Value;

IF ( (old_opinion_log_id = 0 OR old_opinion_log_id is null) and (l_new_opinion_value_code is null) ) THEN
	x_change_flag := 'N';
ELSIF ( (old_opinion_log_id = 0 OR old_opinion_log_id is null) and l_new_opinion_value_code = 'EFFECTIVE') THEN
	x_change_flag := 'F';
ELSIF( (old_opinion_log_id = 0 OR old_opinion_log_id is null) and l_new_opinion_value_code <> 'EFFECTIVE') THEN
	x_change_flag := 'B';
ELSIF( l_old_opinion_value_code = 'EFFECTIVE' and  l_new_opinion_value_code = 'EFFECTIVE') THEN
	x_change_flag := 'N';
ELSIF( l_old_opinion_value_code = 'EFFECTIVE' and l_new_opinion_value_code <> 'EFFECTIVE') THEN
       x_change_flag := 'B';
ELSIF( l_old_opinion_value_code <> 'EFFECTIVE' and l_new_opinion_value_code = 'EFFECTIVE') THEN
	x_change_flag := 'F';
ELSIF (l_old_opinion_value_code <> 'EFFECTIVE' and l_new_opinion_value_code <> 'EFFECTIVE') THEN
	x_change_flag := 'N';
END IF;

END Is_Eval_Change;

FUNCTION Get_Ratio_Fin_Cert
       	( P_CERTIFICATION_ID IN NUMBER,
                  P_FINANCIAL_STATEMENT_ID IN NUMBER,
                  P_STATEMENT_GROUP_ID IN NUMBER ,
                  P_ACCOUNT_ID      IN NUMBER,
                  P_FINANCIAL_ITEM_ID IN NUMBER,
                  P_OBJECT_TYPE IN VARCHAR2,
                  P_STMT VARCHAR2)
 RETURN NUMBER
 IS
 	l_stmt1  VARCHAR2(300);
	l_stmt2  VARCHAR2(200);
	l_sql_stmt VARCHAR2(4000);
	l_ratio_num NUMBER;

 BEGIN
 	l_stmt1 := ' AND TEMP.STATEMENT_GROUP_ID = :2 AND TEMP.FINANCIAL_STATEMENT_ID = :3 AND TEMP.FINANCIAL_ITEM_ID = :4)';
        l_stmt2 := ' AND TEMP.NATURAL_ACCOUNT_ID = :2)';

        IF P_OBJECT_TYPE = 'FINANCIAL ITEM' THEN
        l_sql_stmt := p_stmt || l_stmt1;

        EXECUTE IMMEDIATE l_sql_stmt INTO l_ratio_num USING P_CERTIFICATION_ID, P_STATEMENT_GROUP_ID, P_FINANCIAL_STATEMENT_ID, P_FINANCIAL_ITEM_ID ;
        ELSIF P_OBJECT_TYPE = 'ACCOUNT' THEN
        l_sql_stmt := p_stmt || l_stmt2;

        EXECUTE IMMEDIATE l_sql_stmt INTO l_ratio_num USING P_CERTIFICATION_ID, P_ACCOUNT_ID ;
        END IF;

        return l_ratio_num;

 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*** Record doesn't exist ***/
    fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.Get_Ratio_Fin_Cert');
    RETURN 0;
  WHEN OTHERS THEN
    /*** Raise any other error ***/
    fnd_file.put_line(fnd_file.LOG, 'Unexpected error IN ' || G_PKG_NAME || '.Get_Ratio_Fin_Cert');
    fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
    RAISE;
 END Get_Ratio_Fin_Cert;



 FUNCTION GetTotalProcesses
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2 ) RETURN NUMBER

IS
	l_stmt  VARCHAR2(300);
	l_stmt1  VARCHAR2(300);
	l_stmt2  VARCHAR2(200);
	l_sql_stmt VARCHAR2(4000);

	X_TOTAL_NUMBER_OF_PROCESSES NUMBER;
BEGIN

        l_stmt1 := ' AND fin.STATEMENT_GROUP_ID = :2 AND fin.FINANCIAL_STATEMENT_ID = :3 AND fin.FINANCIAL_ITEM_ID = :4)';
        l_stmt2 := ' AND fin.NATURAL_ACCOUNT_ID = :2)';

        l_stmt := ' select count(1) from (SELECT DISTINCT ORGANIZATION_ID, PROCESS_ID
        FROM amw_fin_cert_scope fin WHERE FIN_CERTIFICATION_ID= :1 AND PROCESS_ID IS NOT NULL';

        IF P_OBJECT_TYPE = 'FINANCIAL ITEM' THEN
        l_sql_stmt := l_stmt || l_stmt1;

        EXECUTE IMMEDIATE l_sql_stmt INTO X_TOTAL_NUMBER_OF_PROCESSES USING P_CERTIFICATION_ID, P_STATEMENT_GROUP_ID, P_FINANCIAL_STATEMENT_ID, P_FINANCIAL_ITEM_ID ;

        ELSIF P_OBJECT_TYPE = 'ACCOUNT' THEN
        l_sql_stmt := l_stmt || l_stmt2;

        EXECUTE IMMEDIATE l_sql_stmt INTO X_TOTAL_NUMBER_OF_PROCESSES USING P_CERTIFICATION_ID, P_ACCOUNT_ID ;
        END IF;

        RETURN X_TOTAL_NUMBER_OF_PROCESSES;

 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*** Record doesn't exist ***/
    fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.GetTotalProcesses');
    RETURN 0;
  WHEN OTHERS THEN
  fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.GetTotalProcesses');
  fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
    RAISE;
END GetTotalProcesses ;


FUNCTION Get_Proc_Certified_Done
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2 ) RETURN NUMBER

IS
	l_stmt VARCHAR2(2000);
	l_stmt1 VARCHAR2(100);
	l_stmt2 VARCHAR2(100);
	l_sql_stmt VARCHAR2(2000);

	X_PROCS_FOR_CERT_DONE Number;
	--l_start_time date;
	--l_end_time date;
BEGIN

l_stmt1 := ' AND FIN.STATEMENT_GROUP_ID = :2 AND FIN.FINANCIAL_STATEMENT_ID = :3 AND FIN.FINANCIAL_ITEM_ID = :4)';
l_stmt2 := ' AND FIN.NATURAL_ACCOUNT_ID = :2)';

l_stmt := 'select count(1)  from (
 	Select distinct  fin.PROCESS_ID, fin.ORGANIZATION_ID
	FROM
	AMW_OPINION_MV aov,
	amw_fin_cert_scope fin,
	AMW_FIN_PROC_CERT_RELAN rel
	WHERE
	 rel.FIN_STMT_CERT_ID = ' || P_CERTIFICATION_ID || '
	and    fin.FIN_CERTIFICATION_ID = :1
	and    rel.end_date is null
	and    aov.PK2_VALUE = rel.PROC_CERT_ID
 	and    aov.PK3_VALUE = fin.ORGANIZATION_ID
 	and    aov.PK1_VALUE = fin.process_ID
                and    fin.process_id is not null
                and   aov.OPINION_TYPE_CODE = ''CERTIFICATION''
	and   aov.opinion_component_code = ''OVERALL''
	and   aov.object_name = ''AMW_ORG_PROCESS''';

        IF P_OBJECT_TYPE = 'FINANCIAL ITEM' THEN
        l_sql_stmt := l_stmt || l_stmt1;

       -- l_start_time := sysdate;
        EXECUTE IMMEDIATE l_sql_stmt INTO X_PROCS_FOR_CERT_DONE USING P_CERTIFICATION_ID, P_STATEMENT_GROUP_ID, P_FINANCIAL_STATEMENT_ID, P_FINANCIAL_ITEM_ID ;
       -- l_end_time := sysdate;


        ELSIF P_OBJECT_TYPE = 'ACCOUNT' THEN
        l_sql_stmt := l_stmt || l_stmt2;


         -- l_start_time := sysdate;
        EXECUTE IMMEDIATE l_sql_stmt INTO X_PROCS_FOR_CERT_DONE USING P_CERTIFICATION_ID, P_ACCOUNT_ID ;
        --l_end_time := sysdate;

        END IF;

        RETURN X_PROCS_FOR_CERT_DONE ;

 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*** Record doesn't exist ***/
    fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.Get_Proc_Certified_Done');
    RETURN 0;
  WHEN OTHERS THEN
    /*** Raise any other error ***/
    fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.Get_Proc_Certified_Done');
    fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
    RAISE;

END Get_Proc_Certified_Done;


FUNCTION  Get_Proc_Verified
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN NUMBER

IS
l_stmt VARCHAR2(2000);
	l_stmt1 VARCHAR2(100);
	l_stmt2 VARCHAR2(100);
	l_sql_stmt VARCHAR2(2000);

	X_PROC_VERIFIED Number;
BEGIN

l_stmt1 := ' AND FIN.STATEMENT_GROUP_ID = :2 AND FIN.FINANCIAL_STATEMENT_ID = :3 AND FIN.FINANCIAL_ITEM_ID = :4)';
l_stmt2 := ' AND FIN.NATURAL_ACCOUNT_ID = :2)';

        l_stmt := 'SELECT COUNT(1) FROM
 	(Select distinct  fin.PROCESS_ID, fin.ORGANIZATION_ID
	FROM
	AMW_OPINION_MV aov,
	amw_fin_cert_scope fin
	WHERE aov.OPINION_TYPE_CODE = ''EVALUATION''
        and aov.object_name = ''AMW_ORG_PROCESS''
        and aov.opinion_component_code = ''OVERALL''
        and aov.PK3_VALUE = fin.ORGANIZATION_ID
        and aov.PK1_VALUE = fin.PROCESS_ID
        --fix bug 5724066
	and aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = ''CANC'')
        and fin.process_id is not null
        and fin.FIN_CERTIFICATION_ID = :1 ';

IF P_OBJECT_TYPE = 'FINANCIAL ITEM' THEN
        l_sql_stmt := l_stmt || l_stmt1;

        EXECUTE IMMEDIATE l_sql_stmt INTO X_PROC_VERIFIED USING P_CERTIFICATION_ID, P_STATEMENT_GROUP_ID, P_FINANCIAL_STATEMENT_ID, P_FINANCIAL_ITEM_ID ;

ELSIF P_OBJECT_TYPE = 'ACCOUNT' THEN
        l_sql_stmt := l_stmt || l_stmt2;
        EXECUTE IMMEDIATE l_sql_stmt INTO X_PROC_VERIFIED USING P_CERTIFICATION_ID, P_ACCOUNT_ID ;
END IF;

        RETURN X_PROC_VERIFIED;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*** Record doesn't exist ***/
    fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.Get_Proc_Verified');
    RETURN 0;
  WHEN OTHERS THEN
    /*** Raise any other error ***/
    fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.Get_Proc_Verified');
    fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
    RAISE;

END Get_Proc_Verified;

FUNCTION Get_ORG_WITH_INEFF_CTRLS
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN NUMBER

IS
	l_stmt VARCHAR2(2000);
	l_stmt1 VARCHAR2(100);
	l_stmt2 VARCHAR2(100);
	l_sql_stmt VARCHAR2(2000);

	X_ORG_WITH_INEFF_CTRLS  Number;
BEGIN

l_stmt1 := ' AND FIN.STATEMENT_GROUP_ID = :2 AND FIN.FINANCIAL_STATEMENT_ID = :3 AND FIN.FINANCIAL_ITEM_ID = :4)';
l_stmt2 := ' AND FIN.NATURAL_ACCOUNT_ID = :2)';

l_stmt := 'select count(1) from (
select distinct fin.ORGANIZATION_ID
FROM
AMW_OPINION_MV aov,
amw_fin_cert_scope fin
WHERE
 aov.AUTHORED_DATE in (select max(aov2.authored_date)
                       from AMW_OPINIONS aov2
                       where aov2.object_opinion_type_id = aov.object_opinion_type_id
                       and aov2.pk1_value = aov.pk1_value )
and aov.OPINION_TYPE_CODE = ''EVALUATION''
and aov.object_name = ''AMW_ORGANIZATION''
and aov.OPINION_VALUE_CODE <> ''EFFECTIVE''
and aov.opinion_component_code = ''OVERALL''
and aov.pk1_value = fin.organization_id
--fix bug 5724066
and aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = ''CANC'')
and fin.FIN_CERTIFICATION_ID= :1 ';


IF P_OBJECT_TYPE = 'FINANCIAL ITEM' THEN
        l_sql_stmt := l_stmt || l_stmt1;
        EXECUTE IMMEDIATE l_sql_stmt INTO X_ORG_WITH_INEFF_CTRLS USING P_CERTIFICATION_ID, P_STATEMENT_GROUP_ID, P_FINANCIAL_STATEMENT_ID, P_FINANCIAL_ITEM_ID ;
ELSIF P_OBJECT_TYPE = 'ACCOUNT' THEN
        l_sql_stmt := l_stmt || l_stmt2;
        EXECUTE IMMEDIATE l_sql_stmt INTO X_ORG_WITH_INEFF_CTRLS USING P_CERTIFICATION_ID, P_ACCOUNT_ID ;
END IF;

        RETURN X_ORG_WITH_INEFF_CTRLS;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*** Record doesn't exist ***/
    fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.Get_ORG_WITH_INEFF_CTRLS');
    RETURN 0;
  WHEN OTHERS THEN
    /*** Raise any other error ***/
    fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.Get_ORG_WITH_INEFF_CTRLS');
    fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
    RAISE;

END Get_ORG_WITH_INEFF_CTRLS;

FUNCTION Get_ORG_EVALUATED
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN NUMBER

IS
	l_stmt VARCHAR2(2000);
	l_stmt1 VARCHAR2(100);
	l_stmt2 VARCHAR2(100);
	l_sql_stmt VARCHAR2(2000);

	X_ORG_EVALUATED  Number;

BEGIN

l_stmt1 := ' AND FIN.STATEMENT_GROUP_ID = :2 AND FIN.FINANCIAL_STATEMENT_ID = :3 AND FIN.FINANCIAL_ITEM_ID = :4)';
l_stmt2 := ' AND FIN.NATURAL_ACCOUNT_ID = :2)';

l_stmt := 'select count(1) from (
select distinct fin.ORGANIZATION_ID
FROM
AMW_OPINION_MV aov,
amw_fin_cert_scope fin
WHERE aov.OPINION_TYPE_CODE = ''EVALUATION''
and aov.object_name = ''AMW_ORGANIZATION''
and aov.opinion_component_code = ''OVERALL''
and aov.pk1_value = fin.organization_id
--fix bug 5724066
and aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = ''CANC'')
and fin.FIN_CERTIFICATION_ID= :1 ';


IF P_OBJECT_TYPE = 'FINANCIAL ITEM' THEN
        l_sql_stmt := l_stmt || l_stmt1;
        EXECUTE IMMEDIATE l_sql_stmt INTO X_ORG_EVALUATED USING P_CERTIFICATION_ID, P_STATEMENT_GROUP_ID, P_FINANCIAL_STATEMENT_ID, P_FINANCIAL_ITEM_ID ;
ELSIF P_OBJECT_TYPE = 'ACCOUNT' THEN
        l_sql_stmt := l_stmt || l_stmt2;

        EXECUTE IMMEDIATE l_sql_stmt INTO X_ORG_EVALUATED USING P_CERTIFICATION_ID, P_ACCOUNT_ID ;
END IF;

                RETURN X_ORG_EVALUATED;

 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*** Record doesn't exist ***/
    fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.Get_ORG_EVALUATED');
    RETURN 0;
  WHEN OTHERS THEN
    /*** Raise any other error ***/
    fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.Get_ORG_EVALUATED');
fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
    RAISE;

END Get_ORG_EVALUATED;

FUNCTION Get_TOTAL_ORGS
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2 ) RETURN NUMBER

IS
l_stmt VARCHAR2(2000);
	l_stmt1 VARCHAR2(100);
	l_stmt2 VARCHAR2(100);
	l_sql_stmt VARCHAR2(2000);

	X_TOTAL_ORGS Number;


BEGIN

l_stmt1 := ' AND FIN.STATEMENT_GROUP_ID = :2 AND FIN.FINANCIAL_STATEMENT_ID = :3 AND FIN.FINANCIAL_ITEM_ID = :4)';
l_stmt2 := ' AND FIN.NATURAL_ACCOUNT_ID = :2)';

l_stmt := 'select COUNT(1)
  from (select distinct fin.organization_id
        from amw_fin_cert_scope fin
        where
        fin.organization_id is not null
        and  fin.FIN_CERTIFICATION_ID= :1 ';

IF P_OBJECT_TYPE = 'FINANCIAL ITEM' THEN
        l_sql_stmt := l_stmt || l_stmt1;

        EXECUTE IMMEDIATE l_sql_stmt INTO X_TOTAL_ORGS USING P_CERTIFICATION_ID, P_STATEMENT_GROUP_ID, P_FINANCIAL_STATEMENT_ID, P_FINANCIAL_ITEM_ID ;

ELSIF P_OBJECT_TYPE = 'ACCOUNT' THEN
        l_sql_stmt := l_stmt || l_stmt2;
        EXECUTE IMMEDIATE l_sql_stmt INTO X_TOTAL_ORGS USING P_CERTIFICATION_ID, P_ACCOUNT_ID ;

END IF;

RETURN X_TOTAL_ORGS;

 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*** Record doesn't exist ***/
    fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.Get_TOTAL_ORGS');
    RETURN 0;
  WHEN OTHERS THEN
    /*** Raise any other error ***/
    fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.Get_TOTAL_ORGS');
fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
    RAISE;

END Get_TOTAL_ORGS;

FUNCTION Get_ORG_CERTIFIED
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2 ) RETURN NUMBER


IS
l_stmt VARCHAR2(2000);
	l_stmt1 VARCHAR2(100);
	l_stmt2 VARCHAR2(100);
	l_sql_stmt VARCHAR2(2000);

	X_ORG_CERTIFIED  Number;
BEGIN

l_stmt1 := ' AND FIN.STATEMENT_GROUP_ID = :2 AND FIN.FINANCIAL_STATEMENT_ID = :3 AND FIN.FINANCIAL_ITEM_ID = :4)';
l_stmt2 := ' AND FIN.NATURAL_ACCOUNT_ID = :2)';

l_stmt := 'select count(1) from ( select distinct fin.organization_id FROM
AMW_OPINION_MV aov,
AMW_FIN_CERT_SCOPE fin
WHERE
aov.AUTHORED_DATE in (select max(aov2.authored_date)
                       from AMW_OPINIONS aov2
                       where aov2.object_opinion_type_id = aov.object_opinion_type_id
                       and aov2.pk1_value = aov.pk1_value )
and aov.OPINION_TYPE_CODE = ''CERTIFICATION''
and aov.object_name = ''AMW_ORGANIZATION''
and aov.opinion_component_code = ''OVERALL''
and aov.PK1_VALUE = fin.organization_id
and fin.organization_id is not null
and fin.FIN_CERTIFICATION_ID= :1 ';


IF P_OBJECT_TYPE = 'FINANCIAL ITEM' THEN
        l_sql_stmt := l_stmt || l_stmt1;

        EXECUTE IMMEDIATE l_sql_stmt INTO X_ORG_CERTIFIED USING P_CERTIFICATION_ID, P_STATEMENT_GROUP_ID, P_FINANCIAL_STATEMENT_ID, P_FINANCIAL_ITEM_ID ;

ELSIF P_OBJECT_TYPE = 'ACCOUNT' THEN
        l_sql_stmt := l_stmt || l_stmt2;

        EXECUTE IMMEDIATE l_sql_stmt INTO X_ORG_CERTIFIED USING P_CERTIFICATION_ID, P_ACCOUNT_ID ;
END IF;

RETURN X_ORG_CERTIFIED;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*** Record doesn't exist ***/
    fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.Get_ORG_CERTIFIED');
    RETURN 0;
  WHEN OTHERS THEN
    /*** Raise any other error ***/
fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.Get_ORG_CERTIFIED');
fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
    RAISE;

END Get_ORG_CERTIFIED;

FUNCTION Get_PROC_WITH_INEFF_CTRLS
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN NUMBER

IS
l_stmt VARCHAR2(2000);
	l_stmt1 VARCHAR2(100);
	l_stmt2 VARCHAR2(100);
	l_sql_stmt VARCHAR2(2000);

	X_PROC_WITH_INEFF_CTRLS  Number;

BEGIN

l_stmt1 := ' AND FIN.STATEMENT_GROUP_ID = :2 AND FIN.FINANCIAL_STATEMENT_ID = :3 AND FIN.FINANCIAL_ITEM_ID = :4)';
l_stmt2 := ' AND FIN.NATURAL_ACCOUNT_ID = :2)';

l_stmt := 'select count(1) from (
Select distinct  fin.process_id, fin.ORGANIZATION_ID
FROM
	AMW_OPINION_MV aov,
	amw_fin_cert_scope fin
WHERE
aov.AUTHORED_DATE in (select max(aov2.authored_date)
                       from AMW_OPINIONS aov2
                       where aov2.object_opinion_type_id = aov.object_opinion_type_id
                       and aov2.pk1_value = aov.pk1_value
                       and aov2.pk3_value = aov.pk3_value)
and aov.OPINION_TYPE_CODE = ''EVALUATION''
and aov.object_name = ''AMW_ORG_PROCESS''
and aov.OPINION_VALUE_CODE <> ''EFFECTIVE''
and aov.opinion_component_code = ''OVERALL''
and aov.PK3_VALUE = fin.ORGANIZATION_ID
and aov.PK1_VALUE = fin.process_id
--fix bug 5724066
and aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = ''CANC'')
and fin.process_id is not null
and fin.FIN_CERTIFICATION_ID= :1 ';



IF P_OBJECT_TYPE = 'FINANCIAL ITEM' THEN
        l_sql_stmt := l_stmt || l_stmt1;

        EXECUTE IMMEDIATE l_sql_stmt INTO X_PROC_WITH_INEFF_CTRLS USING P_CERTIFICATION_ID, P_STATEMENT_GROUP_ID, P_FINANCIAL_STATEMENT_ID, P_FINANCIAL_ITEM_ID ;
ELSIF P_OBJECT_TYPE = 'ACCOUNT' THEN
        l_sql_stmt := l_stmt || l_stmt2;

        EXECUTE IMMEDIATE l_sql_stmt INTO X_PROC_WITH_INEFF_CTRLS USING P_CERTIFICATION_ID, P_ACCOUNT_ID ;
END IF;

         RETURN X_PROC_WITH_INEFF_CTRLS;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*** Record doesn't exist ***/
    fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.Get_PROC_WITH_INEFF_CTRLS');
    RETURN 0;
  WHEN OTHERS THEN
    /*** Raise any other error ***/
fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.Get_PROC_WITH_INEFF_CTRLS');
fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
    RAISE;

END Get_PROC_WITH_INEFF_CTRLS;

FUNCTION Get_UNMITIGATED_RISKS
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2 ) RETURN NUMBER

IS
l_stmt VARCHAR2(2000);
	l_stmt1 VARCHAR2(100);
	l_stmt2 VARCHAR2(100);
	l_sql_stmt VARCHAR2(2000);

	X_UNMITIGATED_RISKS  Number;
BEGIN

l_stmt1 := ' AND FIN.STATEMENT_GROUP_ID = :2 AND FIN.FINANCIAL_STATEMENT_ID = :3 AND FIN.FINANCIAL_ITEM_ID = :4)';
l_stmt2 := ' AND FIN.NATURAL_ACCOUNT_ID = :2)';

l_stmt := 'select count(1)  from (
select distinct  fin.risk_id ,fin.organization_id, fin.Process_ID
FROM
	amw_opinion_log_mv aov,
	amw_fin_item_acc_risk fin,
    	amw_risk_associations risks
WHERE risks.pk1 = fin.fin_certification_id
and risks.object_type = ''PROCESS_FINCERT''
and risks.risk_id = fin.risk_id
and risks.pk2 = fin.organization_id
and risks.pk3 = fin.process_id
and aov.opinion_log_id = risks.pk4
and aov.OPINION_TYPE_CODE = ''EVALUATION''
and aov.object_name = ''AMW_ORG_PROCESS_RISK''
and aov.opinion_component_code = ''OVERALL''
and aov.OPINION_VALUE_CODE <> ''EFFECTIVE''
and aov.AUTHORED_DATE in (select max(aov2.authored_date)
                       from AMW_OPINIONS aov2
                       where aov2.object_opinion_type_id = aov.object_opinion_type_id
                       and aov2.pk1_value = aov.pk1_value
                       and aov2.pk3_value = aov.pk3_value
                       and aov2.pk4_value = aov.pk4_value
                       )
and fin.object_type = ''' || P_OBJECT_TYPE || '''' || '
and fin.FIN_CERTIFICATION_ID= :1 ';

IF P_OBJECT_TYPE = 'FINANCIAL ITEM' THEN
        l_sql_stmt := l_stmt || l_stmt1;



        EXECUTE IMMEDIATE l_sql_stmt INTO X_UNMITIGATED_RISKS USING P_CERTIFICATION_ID, P_STATEMENT_GROUP_ID, P_FINANCIAL_STATEMENT_ID, P_FINANCIAL_ITEM_ID ;
ELSIF P_OBJECT_TYPE = 'ACCOUNT' THEN
        l_sql_stmt := l_stmt || l_stmt2;


        EXECUTE IMMEDIATE l_sql_stmt INTO X_UNMITIGATED_RISKS USING P_CERTIFICATION_ID, P_ACCOUNT_ID ;
END IF;

        RETURN X_UNMITIGATED_RISKS;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*** Record doesn't exist ***/
    fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.Get_UNMITIGATED_RISKS');
    RETURN 0;
  WHEN OTHERS THEN
    /*** Raise any other error ***/
fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.Get_UNMITIGATED_RISKS');
fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
    RAISE;
END Get_UNMITIGATED_RISKS;

FUNCTION Get_Total_RISKS
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2 ) RETURN NUMBER

IS
	l_stmt VARCHAR2(2000);
	l_stmt1 VARCHAR2(100);
	l_stmt2 VARCHAR2(100);
	l_sql_stmt VARCHAR2(2000);

	X_TOTAL_RISKS Number;
BEGIN

l_stmt1 := ' AND FIN.STATEMENT_GROUP_ID = :2 AND FIN.FINANCIAL_STATEMENT_ID = :3 AND FIN.FINANCIAL_ITEM_ID = :4)';
l_stmt2 := ' AND FIN.NATURAL_ACCOUNT_ID = :2)';

l_stmt := 'select count(1)
from (
select distinct risk_id, organization_id, process_id
FROM
	amw_fin_item_acc_risk fin
WHERE   fin.object_type =  ''' || P_OBJECT_TYPE || '''' || '
AND     fin.FIN_CERTIFICATION_ID= :1 ';

IF P_OBJECT_TYPE = 'FINANCIAL ITEM' THEN
        l_sql_stmt := l_stmt || l_stmt1;


        EXECUTE IMMEDIATE l_sql_stmt INTO X_TOTAL_RISKS USING P_CERTIFICATION_ID, P_STATEMENT_GROUP_ID, P_FINANCIAL_STATEMENT_ID, P_FINANCIAL_ITEM_ID ;


        ELSIF P_OBJECT_TYPE = 'ACCOUNT' THEN
        l_sql_stmt := l_stmt || l_stmt2;


        EXECUTE IMMEDIATE l_sql_stmt INTO X_TOTAL_RISKS USING P_CERTIFICATION_ID, P_ACCOUNT_ID ;

        END IF;
                RETURN X_TOTAL_RISKS;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*** Record doesn't exist ***/
    fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.Get_Total_RISKS');
    RETURN 0;
  WHEN OTHERS THEN
    /*** Raise any other error ***/
fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.Get_Total_RISKS');
fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
    RAISE;
END Get_Total_RISKS;

FUNCTION Get_RISKS_VERIFIED
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN NUMBER

IS
	l_stmt VARCHAR2(2000);
	l_stmt1 VARCHAR2(100);
	l_stmt2 VARCHAR2(100);
	l_sql_stmt VARCHAR2(2000);

	X_RISKS_VERIFIED  Number;
BEGIN

l_stmt1 := ' AND FIN.STATEMENT_GROUP_ID = :2 AND FIN.FINANCIAL_STATEMENT_ID = :3 AND FIN.FINANCIAL_ITEM_ID = :4)';
l_stmt2 := ' AND FIN.NATURAL_ACCOUNT_ID = :2)';

l_stmt := 'select count(1)  from (
select distinct  fin.risk_id ,fin.organization_id, fin.Process_ID
FROM
	amw_opinion_log_mv aov,
	amw_fin_item_acc_risk fin,
	amw_risk_associations risks
WHERE risks.pk1 = fin.fin_certification_id
and risks.object_type = ''PROCESS_FINCERT''
and risks.risk_id = fin.risk_id
and risks.pk2 = fin.organization_id
and risks.pk3 = fin.process_id
and aov.opinion_log_id = risks.pk4
and aov.OPINION_TYPE_CODE = ''EVALUATION''
and aov.object_name = ''AMW_ORG_PROCESS_RISK''
and aov.opinion_component_code = ''OVERALL''
and fin.object_type = ''' || P_OBJECT_TYPE || '''' || '
and fin.FIN_CERTIFICATION_ID= :1 ';

IF P_OBJECT_TYPE = 'FINANCIAL ITEM' THEN
        l_sql_stmt := l_stmt || l_stmt1;


        EXECUTE IMMEDIATE l_sql_stmt INTO X_RISKS_VERIFIED USING P_CERTIFICATION_ID, P_STATEMENT_GROUP_ID, P_FINANCIAL_STATEMENT_ID, P_FINANCIAL_ITEM_ID ;


        ELSIF P_OBJECT_TYPE = 'ACCOUNT' THEN
        l_sql_stmt := l_stmt || l_stmt2;


        EXECUTE IMMEDIATE l_sql_stmt INTO X_RISKS_VERIFIED USING P_CERTIFICATION_ID, P_ACCOUNT_ID ;

        END IF;
                RETURN X_RISKS_VERIFIED;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*** Record doesn't exist ***/
    fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.Get_RISKS_VERIFIED');
    RETURN 0;
  WHEN OTHERS THEN
    /*** Raise any other error ***/
fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.Get_RISKS_VERIFIED');
fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
    RAISE;

END Get_RISKS_VERIFIED;


FUNCTION Get_INEFFECTIVE_CONTROLS
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN NUMBER

IS
	l_stmt VARCHAR2(2000);
	l_stmt1 VARCHAR2(100);
	l_stmt2 VARCHAR2(100);
	l_sql_stmt VARCHAR2(2000);

	X_INEFFECTIVE_CONTROLS  Number;


BEGIN

l_stmt1 := ' AND FIN.STATEMENT_GROUP_ID = :2 AND FIN.FINANCIAL_STATEMENT_ID = :3 AND FIN.FINANCIAL_ITEM_ID = :4)';
l_stmt2 := ' AND FIN.NATURAL_ACCOUNT_ID = :2)';

/****replace with the following query that uses opinon_log_id in amw_fin_item_acc_ctrl table directly
l_stmt := 'select count(1) from(
select distinct  fin.control_id, fin.organization_id
FROM
AMW_OPINION_MV aov,
amw_fin_item_acc_ctrl fin
WHERE
aov.AUTHORED_DATE in (select max(aov2.authored_date)
                       from AMW_OPINIONS aov2
                       where aov2.object_opinion_type_id = aov.object_opinion_type_id
                       and aov2.pk1_value = aov.pk1_value
                       and aov2.pk3_value = aov.pk3_value)
AND aov.OPINION_TYPE_CODE = ''EVALUATION''
AND aov.object_name = ''AMW_ORG_CONTROL''
and aov.OPINION_VALUE_CODE <> ''EFFECTIVE''
and aov.opinion_component_code = ''OVERALL''
AND aov.pk1_value = fin.control_id
AND aov.pk3_value = fin.organization_id
--fix bug 5724066
and aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = ''CANC'')
and fin.object_type = ''' || P_OBJECT_TYPE || '''' || '
and fin.fin_certification_id = :1 ';
****************/


/*** use opinion_log_id in amw_control_associations instead of opinion_log_id in amw_fin_item_acc_ctrl
**** so that it consists with VO query and also reduces the maintainence   ***********************/
l_stmt := 'select count(1) from(
select distinct  fin.control_id, fin.organization_id
FROM
amw_opinion_log_mv aov,
amw_fin_item_acc_ctrl fin,
amw_control_associations ctrls
WHERE
aov.opinion_log_id = ctrls.pk5
and ctrls.pk1 = fin.fin_certification_id
and   ctrls.object_type =   ''RISK_FINCERT''
and ctrls.control_id = fin.control_id
and ctrls.pk2 = fin.organization_id
and aov.OPINION_TYPE_CODE = ''EVALUATION''
and aov.object_name = ''AMW_ORG_CONTROL''
and aov.OPINION_VALUE_CODE <> ''EFFECTIVE''
and aov.opinion_component_code = ''OVERALL''
and aov.AUTHORED_DATE in (select max(aov2.authored_date)
                       from AMW_OPINIONS aov2
                       where aov2.object_opinion_type_id = aov.object_opinion_type_id
                       and aov2.pk1_value = aov.pk1_value
                       and aov2.pk3_value = aov.pk3_value)
and fin.object_type = ''' || P_OBJECT_TYPE || '''' || '
and fin.fin_certification_id = :1 ';


IF P_OBJECT_TYPE = 'FINANCIAL ITEM' THEN
        l_sql_stmt := l_stmt || l_stmt1;

        EXECUTE IMMEDIATE l_sql_stmt INTO X_INEFFECTIVE_CONTROLS USING P_CERTIFICATION_ID, P_STATEMENT_GROUP_ID, P_FINANCIAL_STATEMENT_ID, P_FINANCIAL_ITEM_ID ;


        ELSIF P_OBJECT_TYPE = 'ACCOUNT' THEN
        l_sql_stmt := l_stmt || l_stmt2;


        EXECUTE IMMEDIATE l_sql_stmt INTO X_INEFFECTIVE_CONTROLS USING P_CERTIFICATION_ID, P_ACCOUNT_ID ;

        END IF;
         RETURN X_INEFFECTIVE_CONTROLS;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*** Record doesn't exist ***/
    fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.Get_INEFFECTIVE_CONTROLS');
    RETURN 0;
  WHEN OTHERS THEN
    /*** Raise any other error ***/
fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.Get_INEFFECTIVE_CONTROLS');
fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
    RAISE;

END Get_INEFFECTIVE_CONTROLS;

FUNCTION Get_CONTROLS_VERIFIED
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN NUMBER

IS
	l_stmt VARCHAR2(2000);
	l_stmt1 VARCHAR2(100);
	l_stmt2 VARCHAR2(100);
	l_sql_stmt VARCHAR2(2000);

	X_CONTROLS_VERIFIED  Number;


BEGIN

l_stmt1 := ' AND FIN.STATEMENT_GROUP_ID = :2 AND FIN.FINANCIAL_STATEMENT_ID = :3 AND FIN.FINANCIAL_ITEM_ID = :4)';
l_stmt2 := ' AND FIN.NATURAL_ACCOUNT_ID = :2)';

/*****replace with the following query ,which uses  opinion_log_id directly in amw_fin_item_acc_ctrl table
l_stmt := 'select count(1) from(
select distinct  fin.control_id, fin.organization_id
FROM
AMW_OPINION_MV aov,
amw_fin_item_acc_ctrl fin
WHERE aov.OPINION_TYPE_CODE = ''EVALUATION''
AND aov.object_name = ''AMW_ORG_CONTROL''
and aov.opinion_component_code = ''OVERALL''
AND aov.pk1_value = fin.control_id
AND aov.pk3_value = fin.organization_id
--fix bug 5724066
and aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = ''CANC'')
and fin.object_type = ''' || P_OBJECT_TYPE || '''' || '
and fin.fin_certification_id = :1 ';
******/
l_stmt := 'select count(1) from(
select distinct  fin.control_id, fin.organization_id
FROM
AMW_OPINION_LOG_MV aov,
amw_fin_item_acc_ctrl fin,
amw_control_associations ctrls
WHERE
aov.opinion_log_id = ctrls.pk5
and ctrls.pk1 = fin.fin_certification_id
and ctrls.object_type =   ''RISK_FINCERT''
and ctrls.control_id = fin.control_id
and ctrls.PK2   = fin.organization_id
and aov.OPINION_TYPE_CODE = ''EVALUATION''
and  aov.object_name = ''AMW_ORG_CONTROL''
and  aov.opinion_component_code = ''OVERALL''
and fin.object_type = ''' || P_OBJECT_TYPE || '''' || '
and fin.fin_certification_id = :1 ';



IF P_OBJECT_TYPE = 'FINANCIAL ITEM' THEN
        l_sql_stmt := l_stmt || l_stmt1;


        EXECUTE IMMEDIATE l_sql_stmt INTO X_CONTROLS_VERIFIED USING P_CERTIFICATION_ID, P_STATEMENT_GROUP_ID, P_FINANCIAL_STATEMENT_ID, P_FINANCIAL_ITEM_ID ;
        --RETURN X_CONTROLS_VERIFIED;

        ELSIF P_OBJECT_TYPE = 'ACCOUNT' THEN
        l_sql_stmt := l_stmt || l_stmt2;


        EXECUTE IMMEDIATE l_sql_stmt INTO X_CONTROLS_VERIFIED USING P_CERTIFICATION_ID, P_ACCOUNT_ID ;
        --RETURN X_CONTROLS_VERIFIED;
        END IF;
        RETURN X_CONTROLS_VERIFIED;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*** Record doesn't exist ***/
    fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.Get_CONTROLS_VERIFIED');
    RETURN 0;
  WHEN OTHERS THEN
    /*** Raise any other error ***/
fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.Get_CONTROLS_VERIFIED');
fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
    RAISE;


END Get_CONTROLS_VERIFIED;



FUNCTION Get_TOTAL_CONTROLS
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN NUMBER

IS
	l_stmt VARCHAR2(2000);
	l_stmt1 VARCHAR2(100);
	l_stmt2 VARCHAR2(100);
	l_sql_stmt VARCHAR2(2000);

	X_TOTAL_CONTROLS Number;


BEGIN

l_stmt1 := ' AND FIN.STATEMENT_GROUP_ID = :2 AND FIN.FINANCIAL_STATEMENT_ID = :3 AND FIN.FINANCIAL_ITEM_ID = :4)';
l_stmt2 := ' AND FIN.NATURAL_ACCOUNT_ID = :2)';

l_stmt := 'select count(1)
from (
select distinct organization_id, control_id
FROM
amw_fin_item_acc_ctrl fin
WHERE fin.object_type =  ''' || p_object_type || '''' || '
      and fin.FIN_CERTIFICATION_ID= :1 ';

IF P_OBJECT_TYPE = 'FINANCIAL ITEM' THEN
        l_sql_stmt := l_stmt || l_stmt1;

        EXECUTE IMMEDIATE l_sql_stmt INTO X_TOTAL_CONTROLS USING P_CERTIFICATION_ID, P_STATEMENT_GROUP_ID, P_FINANCIAL_STATEMENT_ID, P_FINANCIAL_ITEM_ID ;
        --RETURN X_TOTAL_CONTROLS;

        ELSIF P_OBJECT_TYPE = 'ACCOUNT' THEN
        l_sql_stmt := l_stmt || l_stmt2;

        EXECUTE IMMEDIATE l_sql_stmt INTO X_TOTAL_CONTROLS USING P_CERTIFICATION_ID, P_ACCOUNT_ID ;
        --RETURN X_TOTAL_CONTROLS;
        END IF;

        RETURN X_TOTAL_CONTROLS;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*** Record doesn't exist ***/
    fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.Get_TOTAL_CONTROLS');
    RETURN 0;
  WHEN OTHERS THEN
    /*** Raise any other error ***/
fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.Get_TOTAL_CONTROLS');
fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
    RAISE;

END Get_TOTAL_CONTROLS;

/*
PROCEDURE Get_Fin_Evaluation
( P_CERTIFICATION_ID IN NUMBER,
P_FINANCIAL_ITEM_ID  IN NUMBER,
P_ACCOUNT_ID  	     IN NUMBER,
P_OBJECT_TYPE 	     IN VARCHAR2,
X_FIN_EVALUATION     OUT  NOCOPY NUMBER
)IS
BEGIN
IF (P_OBJECT_TYPE = 'FINANCIAL ITEM') THEN
	SELECT 	max(aov.opinion_log_id) INTO X_FIN_EVALUATION
	FROM 	AMW_OPINION_LOG_MV aov
       	WHERE 	aov.object_name = 'AMW_FINANCIAL_ITEM'
        AND 	aov.opinion_type_code = 'EVALUATION'
        AND 	aov.pk1_value = P_FINANCIAL_ITEM_ID
        AND 	aov.pk2_value = P_CERTIFICATION_ID
        AND 	aov.authored_date = (select max(aov2.authored_date)
                       	             from AMW_OPINIONS aov2
                               	     where aov2.object_opinion_type_id = aov.object_opinion_type_id
                                     and aov2.pk2_value = aov.pk2_value
                                     and aov2.pk1_value = aov.pk1_value);

ELSIF (P_OBJECT_TYPE = 'ACCOUNT') THEN
       SELECT 	max(aov.opinion_log_id) INTO X_FIN_EVALUATION
	FROM 	AMW_OPINION_LOG_MV aov
       	WHERE 	aov.object_name = 'AMW_KEY_ACCOUNT'
        AND 	aov.opinion_type_code = 'EVALUATION'
        AND 	aov.pk1_value = P_ACCOUNT_ID
        AND 	aov.pk2_value = P_CERTIFICATION_ID
        AND 	aov.authored_date = (select max(aov2.authored_date)
                       	             from AMW_OPINIONS aov2
                               	     where aov2.object_opinion_type_id = aov.object_opinion_type_id
                                     and aov2.pk2_value = aov.pk2_value
                                     and aov2.pk1_value = aov.pk1_value);
END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.Get_Fin_Evaluation');
    raise;
  WHEN OTHERS THEN
  fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.Get_Fin_Evaluation');
  fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
    RAISE;
END Get_Fin_Evaluation;
**********/

FUNCTION Get_PROC_CERT_WITH_ISSUES
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN NUMBER

IS
	l_stmt VARCHAR2(2000);
	l_stmt1 VARCHAR2(100);
	l_stmt2 VARCHAR2(100);
	l_sql_stmt VARCHAR2(2000);

	l_start_time date;
	l_end_time date;

	X_PROC_CERT_WITH_ISSUES Number;

BEGIN

l_stmt1 := ' AND FIN.STATEMENT_GROUP_ID = :2 AND FIN.FINANCIAL_STATEMENT_ID = :3 AND FIN.FINANCIAL_ITEM_ID = :4)';
l_stmt2 := ' AND FIN.NATURAL_ACCOUNT_ID = :2)';

l_stmt := 'select count(1)  from (
Select distinct  fin.process_ID, fin.ORGANIZATION_ID
FROM
	AMW_OPINION_MV aov,
	amw_fin_cert_scope fin,
	amw_fin_proc_cert_relan rel
WHERE
rel.FIN_STMT_CERT_ID = ' || P_CERTIFICATION_ID || '
and fin.FIN_CERTIFICATION_ID= :1
and fin.process_id is not null
and rel.end_date is null
and  aov.PK2_VALUE = rel.PROC_CERT_ID
and aov.PK3_VALUE = fin.ORGANIZATION_ID
and aov.PK1_VALUE = fin.PROCESS_ID
and aov.OPINION_TYPE_CODE = ''CERTIFICATION''
and aov.object_name = ''AMW_ORG_PROCESS''
and aov.OPINION_VALUE_CODE <> ''EFFECTIVE''
and aov.opinion_component_code = ''OVERALL''
and aov.authored_date = (select max(aov2.authored_date)
                                     from AMW_OPINIONS  aov2
                                     where aov2.object_opinion_type_id
                                           = aov.object_opinion_type_id
                                     and aov2.pk3_value = aov.pk3_value
                                     AND aov2.pk2_value in
                                        (select proc_cert_Id from AMW_FIN_PROC_CERT_RELAN
                                         where fin_stmt_cert_id = fin.FIN_CERTIFICATION_ID
                                         and end_date is null)
                                     and aov2.pk1_value = aov.pk1_value) ';


IF P_OBJECT_TYPE = 'FINANCIAL ITEM' THEN
        l_sql_stmt := l_stmt || l_stmt1;



      --  l_start_time := sysdate;
        EXECUTE IMMEDIATE l_sql_stmt INTO X_PROC_CERT_WITH_ISSUES USING P_CERTIFICATION_ID, P_STATEMENT_GROUP_ID, P_FINANCIAL_STATEMENT_ID, P_FINANCIAL_ITEM_ID ;
      -- l_end_time := sysdate;
      --  RETURN X_PROC_CERT_WITH_ISSUES;

        ELSIF P_OBJECT_TYPE = 'ACCOUNT' THEN
         l_sql_stmt := l_stmt || l_stmt2;


    --  l_start_time := sysdate;
        EXECUTE IMMEDIATE l_sql_stmt INTO X_PROC_CERT_WITH_ISSUES USING P_CERTIFICATION_ID, P_ACCOUNT_ID ;

      -- l_end_time := sysdate;

      -- RETURN X_PROC_CERT_WITH_ISSUES;
        END IF;

        RETURN X_PROC_CERT_WITH_ISSUES;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*** Record doesn't exist ***/
    fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.Get_PROC_CERT_WITH_ISSUES');
    RETURN 0;
  WHEN OTHERS THEN
    /*** Raise any other error ***/
fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.Get_PROC_CERT_WITH_ISSUES');
fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
    RAISE;

END Get_PROC_CERT_WITH_ISSUES;


---------------------------******** Get Information for Dashboard ********----------------
PROCEDURE  Get_global_proc_not_certified
(
    p_certification_id          IN    	NUMBER,
    x_global_proc_not_certified OUT NOCOPY Number
) IS
BEGIN
  SELECT count(1) INTO x_global_proc_not_certified
     	FROM ( SELECT distinct proc.organization_id, proc.process_id
     	       FROM AMW_FIN_PROCESS_EVAL_SUM proc
     	       WHERE proc.fin_certification_id = p_certification_id
                   AND proc.organization_id = NVL(fnd_profile.value('AMW_GLOBAL_ORG_ID'), -999)
                   AND not exists (SELECT 'Y'
                             FROM AMW_OPINION_MV aov,
                             	  AMW_FIN_PROC_CERT_RELAN rel
                             WHERE aov.object_name = 'AMW_ORG_PROCESS'
                              AND aov.opinion_type_code = 'CERTIFICATION'
                              AND aov.opinion_component_code = 'OVERALL'
                              AND aov.pk3_value = proc.organization_id
                              AND aov.pk2_value = rel.proc_cert_id
                              AND rel.fin_stmt_cert_id = p_certification_id
                              AND rel.end_date is null
                              AND aov.pk1_value = proc.process_id));
END Get_global_proc_not_certified;



PROCEDURE  Get_local_proc_not_certified
(
    p_certification_id          IN    	NUMBER,
    x_local_proc_not_certified OUT NOCOPY Number
)IS
BEGIN

 	-- local_proc_not_certified
        SELECT count(1) INTO x_local_proc_not_certified
           FROM ( SELECT distinct proc.organization_id, proc.process_id
     	       FROM AMW_FIN_PROCESS_EVAL_SUM proc
     	       WHERE proc.fin_certification_id = p_certification_id
                   AND proc.organization_id <> NVL(fnd_profile.value('AMW_GLOBAL_ORG_ID'),-999)
                   AND not exists (SELECT 'Y'
                             FROM AMW_OPINION_MV aov,
                             	  AMW_FIN_PROC_CERT_RELAN rel
                             WHERE aov.object_name = 'AMW_ORG_PROCESS'
                              AND aov.opinion_type_code = 'CERTIFICATION'
                              AND aov.opinion_component_code = 'OVERALL'
                              AND aov.pk3_value = proc.organization_id
                              AND aov.pk2_value = rel.proc_cert_id
                              AND rel.fin_stmt_cert_id = p_certification_id
                              AND rel.end_date is null
                              AND aov.pk1_value = proc.process_id));


END Get_local_proc_not_certified;

PROCEDURE  Get_global_proc_with_issue
(
    p_certification_id          IN    	NUMBER,
    x_global_proc_with_issue OUT NOCOPY Number
)IS
BEGIN

---- global_proc_with_issue
	SELECT count(1) INTO x_global_proc_with_issue
 		FROM  (SELECT DISTINCT proc.organization_id, proc.process_id
 		       FROM AMW_FIN_PROCESS_EVAL_SUM proc,
 		            AMW_OPINION_MV aov,
 		            AMW_FIN_PROC_CERT_RELAN rel
 		       WHERE proc.fin_certification_id = p_certification_id
                   	AND proc.organization_id = NVL(fnd_profile.value('AMW_GLOBAL_ORG_ID'), -999)
                   	AND aov.object_name = 'AMW_ORG_PROCESS'
                   	AND aov.opinion_component_code = 'OVERALL'
                   	AND aov.opinion_type_code = 'CERTIFICATION'
                   	AND aov.pk3_value = proc.organization_id
                   	AND aov.pk2_value = rel.proc_cert_id
                   	AND rel.fin_stmt_cert_id = p_certification_id
                   	AND rel.end_date is null
                   	AND aov.pk1_value = proc.process_id
                   	AND aov.OPINION_VALUE_CODE <> 'EFFECTIVE'
                   	 AND aov.authored_date = (select max(aov2.authored_date)
                       	             from AMW_OPINIONS aov2
                               	     where aov2.object_opinion_type_id = aov.object_opinion_type_id
                                     and aov2.pk3_value = aov.pk3_value
                                     and aov2.pk1_value = aov.pk1_value));
END Get_global_proc_with_issue;

PROCEDURE  Get_local_proc_with_issue
(
    p_certification_id          IN    	NUMBER,
    x_local_proc_with_issue OUT NOCOPY Number
)IS
BEGIN
	------local_proc_with_issue
        SELECT count(1) INTO x_local_proc_with_issue
          FROM  (SELECT DISTINCT proc.organization_id, proc.process_id
 		       FROM AMW_FIN_PROCESS_EVAL_SUM proc,
 		            AMW_OPINION_MV aov,
 		            AMW_FIN_PROC_CERT_RELAN rel
 		 WHERE proc.fin_certification_id = p_certification_id
                   	AND proc.organization_id <> NVL(fnd_profile.value('AMW_GLOBAL_ORG_ID'), -999)
                   	AND aov.object_name = 'AMW_ORG_PROCESS'
                   	AND aov.opinion_type_code = 'CERTIFICATION'
                   	AND aov.opinion_component_code = 'OVERALL'
                   	AND aov.pk3_value = proc.organization_id
                   	AND aov.pk2_value = rel.proc_cert_id
                   	AND rel.fin_stmt_cert_id = p_certification_id
                   	AND rel.end_date is null
                   	AND aov.pk1_value = proc.process_id
                   	AND aov.OPINION_VALUE_CODE <> 'EFFECTIVE'
                   	 AND aov.authored_date = (select max(aov2.authored_date)
                       	             from AMW_OPINIONS aov2
                               	     where aov2.object_opinion_type_id = aov.object_opinion_type_id
                                     and aov2.pk3_value = aov.pk3_value
                                     and aov2.pk1_value = aov.pk1_value));
END Get_local_proc_with_issue;


PROCEDURE  Get_global_proc_ineff_ctrl
(
    p_certification_id          IN    	NUMBER,
    x_global_proc_ineff_ctrl OUT NOCOPY Number
) IS
BEGIN
	-------------global_proc_with_ineff_ctrl IS
    	 SELECT count(1) INTO x_global_proc_ineff_ctrl
    	 from (select distinct proc.organization_id, proc.process_id
    	 FROM AMW_FIN_PROCESS_EVAL_SUM proc,
    	      AMW_OPINION_MV aov
    	 WHERE  proc.fin_certification_id = p_certification_id
    	 AND	proc.organization_id = aov.pk3_value
    	 AND	proc.process_id      = aov.pk1_value
    	 --fix bug 5724066
	 AND    aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = 'CANC')
    	 AND    proc.organization_id = NVL(fnd_profile.value('AMW_GLOBAL_ORG_ID'), -999)
    	 AND 	aov.object_name = 'AMW_ORG_PROCESS'
         AND 	aov.opinion_type_code = 'EVALUATION'
         AND    aov.opinion_component_code = 'OVERALL'
         AND 	aov.authored_date = (select max(aov2.authored_date)
			      		   from AMW_OPINIONS aov2
			      		  where aov2.object_opinion_type_id = aov.object_opinion_type_id
			      		  and aov2.pk3_value = aov.pk3_value
                            		  		  and aov2.pk1_value = aov.pk1_value)
         AND	 aov.OPINION_VALUE_CODE <> 'EFFECTIVE');

END Get_global_proc_ineff_ctrl;

PROCEDURE  Get_local_proc_ineff_ctrl
(
    p_certification_id          IN    	NUMBER,
    x_local_proc_ineff_ctrl OUT NOCOPY Number
) IS
BEGIN
	------ local_proc_with_ineff_ctrl
        SELECT count(1) INTO x_local_proc_ineff_ctrl
        from (select distinct proc.organization_id, proc.process_id
    	 FROM AMW_FIN_PROCESS_EVAL_SUM proc,
    	      AMW_OPINION_MV aov
    	 WHERE  proc.fin_certification_id = p_certification_id
    	 AND	proc.organization_id = aov.pk3_value
    	 AND	proc.process_id      = aov.pk1_value
    	 --fix bug 5724066
	 AND    aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = 'CANC')
    	 AND    proc.organization_id <>  NVL(fnd_profile.value('AMW_GLOBAL_ORG_ID'), -999)
    	 AND 	aov.object_name = 'AMW_ORG_PROCESS'
         AND 	aov.opinion_type_code = 'EVALUATION'
         AND 	aov.opinion_component_code = 'OVERALL'
         AND 	aov.authored_date = (select max(aov2.authored_date)
			      		   from AMW_OPINIONS aov2
			      		  where aov2.object_opinion_type_id = aov.object_opinion_type_id
			      		  and aov2.pk3_value = aov.pk3_value
                            		  and aov2.pk1_value = aov.pk1_value)
         AND	 aov.OPINION_VALUE_CODE <> 'EFFECTIVE');
END Get_local_proc_ineff_ctrl;

PROCEDURE  Get_unmitigated_risks
(
    p_certification_id          IN    	NUMBER,
    x_unmitigated_risks OUT NOCOPY Number
)IS
BEGIN
	----unmitigated_risks IS
	/*** remove due to ratio number mismatch
    	SELECT count(1)  INTO x_unmitigated_risks
    	from (select distinct fin.organization_id, fin.process_id, fin.risk_id
	FROM 	AMW_OPINION_MV aov,
		AMW_FIN_ITEM_ACC_RISK fin
	WHERE
		fin.object_type = 'FINANCIAL STATEMENT'
	AND	fin.FIN_CERTIFICATION_ID = p_certification_id
	AND	aov.AUTHORED_DATE in (select max(aov2.authored_date)
                       from AMW_OPINIONS aov2
                       where aov2.object_opinion_type_id = aov.object_opinion_type_id
                       and aov2.pk1_value = aov.pk1_value
                       and aov2.pk3_value = aov.pk3_value
                       and aov2.pk4_value = aov.pk4_value)
	AND aov.OPINION_TYPE_CODE = 'EVALUATION'
	AND aov.object_name = 'AMW_ORG_PROCESS_RISK'
	AND aov.opinion_component_code = 'OVERALL'
	AND aov.pk1_value = fin.risk_id
	AND aov.pk3_value = fin.organization_id
	AND aov.pk4_value = fin.process_ID
	--fix bug 5724066
	AND aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = 'CANC')
	AND aov.OPINION_VALUE_CODE <> 'EFFECTIVE');
	*******/

	----unmitigated_risks IS
    	SELECT count(1)  INTO x_unmitigated_risks
	from AMW_RISK_ASSOCIATIONS risks,
	AMW_OPINION_LOG_MV op
	where risks.pk1 = p_certification_id
	and risks.pk4 = op.opinion_log_id (+)
	and op.OPINION_VALUE_CODE <> 'EFFECTIVE'
	and risks.object_type = 'PROCESS_FINCERT';

END Get_unmitigated_risks;


PROCEDURE  Get_ineffective_controls
(
    p_certification_id          IN    	NUMBER,
    x_ineffective_controls	 OUT NOCOPY Number
)IS
BEGIN
	---------ineffective_controls
      	/***************replace to use opinion_log_id in amw_fin_item_acc_ctrl table
      	SELECT count(1) INTO x_ineffective_controls
      	from(select distinct  fin.control_id, fin.organization_id
	FROM 	AMW_OPINION_MV aov,
		AMW_FIN_ITEM_ACC_CTRL fin
	WHERE	fin.fin_certification_id = p_certification_id
	AND	fin.object_type = 'FINANCIAL STATEMENT'
	AND	 aov.pk1_value = fin.control_id
	AND 	aov.pk3_value = fin.organization_id
	--fix bug 5724066
	AND     aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = 'CANC')
	AND 	aov.OPINION_TYPE_CODE = 'EVALUATION'
	AND 	aov.object_name = 'AMW_ORG_CONTROL'
	AND 	aov.opinion_component_code = 'OVERALL'
	AND	aov.AUTHORED_DATE in (select max(aov2.authored_date)
                       from AMW_OPINIONS aov2
                       where aov2.object_opinion_type_id = aov.object_opinion_type_id
                       and aov2.pk1_value = aov.pk1_value
                       and aov2.pk3_value = aov.pk3_value)
	AND	 aov.OPINION_VALUE_CODE <> 'EFFECTIVE');
	**********************/
	SELECT count(1) INTO x_ineffective_controls
      	from(select distinct  fin.control_id, fin.organization_id
	FROM 	AMW_OPINION_LOG_MV aov,
		AMW_FIN_ITEM_ACC_CTRL fin
	WHERE	fin.fin_certification_id = p_certification_id
	AND	fin.object_type = 'FINANCIAL STATEMENT'
	AND     aov.opinion_log_id = fin.OPINION_LOG_ID
	AND 	aov.OPINION_TYPE_CODE = 'EVALUATION'
	AND 	aov.object_name = 'AMW_ORG_CONTROL'
	AND 	aov.opinion_component_code = 'OVERALL'
	AND	aov.AUTHORED_DATE in (select max(aov2.authored_date)
                       from AMW_OPINIONS aov2
                       where aov2.object_opinion_type_id = aov.object_opinion_type_id
                       and aov2.pk1_value = aov.pk1_value
                       and aov2.pk3_value = aov.pk3_value)
	AND	 aov.OPINION_VALUE_CODE <> 'EFFECTIVE');


END Get_ineffective_controls;

PROCEDURE  Get_orgs_pending_in_scope
(
    p_certification_id          IN    	NUMBER,
    x_orgs_pending_in_scope     OUT NOCOPY Number
)IS
BEGIN
	-----orgs_pending_in_scope IS
        SELECT 	count(distinct fin.organization_id) INTO x_orgs_pending_in_scope
        FROM 	AMW_FIN_CERT_SCOPE fin
	WHERE 	fin.FIN_CERTIFICATION_ID = p_certification_id
	AND	fin.organization_id is not null
	AND 	not exists ( SELECT 'Y'
                             FROM AMW_OPINION_MV aov
                             WHERE aov.object_name = 'AMW_ORG_PROCESS'
                             AND aov.opinion_type_code = 'CERTIFICATION'
                             AND aov.opinion_component_code = 'OVERALL'
                             AND aov.pk3_value = fin.organization_id
                             AND aov.pk2_value = p_certification_id
                             AND aov.pk1_value = fin.process_id);

END Get_orgs_pending_in_scope;



 ----------------------------- ********************************** ----------------------
procedure insert_fin_cert_eval_sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
 X_FIN_CERTIFICATION_ID                       IN         NUMBER,
 X_FINANCIAL_STATEMENT_ID                     IN         NUMBER,
 X_FINANCIAL_ITEM_ID                          IN         NUMBER,
 X_ACCOUNT_GROUP_ID                           IN         NUMBER,
 X_NATURAL_ACCOUNT_ID                         IN         NUMBER,
 X_OBJECT_TYPE                                IN         VARCHAR,
 X_PROC_PENDING_CERTIFICATION                 IN         NUMBER,
 X_TOTAL_NUMBER_OF_PROCESSES                  IN         NUMBER,
 X_PROC_CERTIFIED_WITH_ISSUES                 IN         NUMBER,
 X_PROCS_FOR_CERT_DONE                        IN         NUMBER,
 x_proc_evaluated                             IN         NUMBER,
 X_ORG_WITH_INEFFECTIVE_CTRLS                 IN         NUMBER,
-- X_ORG_CERTIFIED                            IN         NUMBER,
 x_orgs_FOR_CERT_DONE                         IN         NUMBER,
 x_orgs_evaluated                             IN         NUMBER,
  x_total_orgs			 IN         NUMBER,
 X_PROC_WITH_INEFFECTIVE_CTRLS                IN         NUMBER,
 X_UNMITIGATED_RISKS                          IN         NUMBER,
 X_RISKS_VERIFIED                             IN         NUMBER,
  X_TOTAL_RISKS			 IN         NUMBER,
 X_INEFFECTIVE_CONTROLS                       IN         NUMBER,
 X_CONTROLS_VERIFIED                          IN         NUMBER,
  X_TOTAL_CONTROLS			IN         NUMBER,
 X_OPEN_ISSUES                                IN         NUMBER,
 X_PRO_PENDING_CERT_PRCNT                     IN         NUMBER,
 X_PROCESSES_WITH_ISSUES_PRCNT                IN         NUMBER,
 X_ORG_WITH_INEFF_CTRLS_PRCNT                 IN         NUMBER,
 X_PROC_WITH_INEFF_CTRLS_PRCNT                IN         NUMBER,
 X_UNMITIGATED_RISKS_PRCNT                    IN         NUMBER,
 X_INEFFECTIVE_CTRLS_PRCNT                    IN         NUMBER,
 X_OBJ_CONTEXT                                IN         NUMBER,
 X_CREATED_BY                                 IN         NUMBER,
 X_CREATION_DATE                              IN         DATE,
 X_LAST_UPDATED_BY                            IN         NUMBER,
 X_LAST_UPDATE_DATE                           IN         DATE,
 X_LAST_UPDATE_LOGIN                          IN         NUMBER,
 X_SECURITY_GROUP_ID                          IN         NUMBER,
 X_OBJECT_VERSION_NUMBER                      IN         NUMBER,
 x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
 )
IS
M_COUNT NUMBER := 0;


l_api_name           CONSTANT VARCHAR2(30) := 'insert_fin_cert_eval_sum';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

SAVEPOINT insert_fin_cert_eval_sum;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;

SELECT COUNT(1) INTO M_COUNT FROM amw_fin_cert_eval_sum
        WHERE FIN_CERTIFICATION_ID = X_FIN_CERTIFICATION_ID
        AND FINANCIAL_STATEMENT_ID = X_FINANCIAL_STATEMENT_ID
        AND NVL(FINANCIAL_ITEM_ID,0) = NVL(X_FINANCIAL_ITEM_ID,0)
        AND NVL(NATURAL_ACCOUNT_ID,0)     = NVL(X_NATURAL_ACCOUNT_ID,0)
        AND NVL(ACCOUNT_GROUP_ID,0)       = NVL(X_ACCOUNT_GROUP_ID,0)
        AND OBJECT_TYPE            = X_OBJECT_TYPE;


 IF (M_COUNT is null or M_COUNT = 0) then
insert into amw_fin_cert_eval_sum(
FIN_CERTIFICATION_ID                   ,
FINANCIAL_STATEMENT_ID                 ,
FINANCIAL_ITEM_ID                      ,
NATURAL_ACCOUNT_ID                     ,
ACCOUNT_GROUP_ID                       ,
OBJECT_TYPE                            ,
PROC_PENDING_CERTIFICATION             ,
TOTAL_NUMBER_OF_PROCESSES              ,
PROC_CERTIFIED_WITH_ISSUES             ,
PROCS_FOR_CERT_DONE                   ,
proc_evaluated                        ,
ORG_WITH_INEFFECTIVE_CONTROLS          ,
orgs_FOR_CERT_DONE                    ,
--org_certified                         ,
orgs_evaluated                         ,
total_number_of_orgs  ,
PROC_WITH_INEFFECTIVE_CONTROLS         ,
UNMITIGATED_RISKS                      ,
RISKS_VERIFIED                         ,
TOTAL_NUMBER_OF_RISKS ,
INEFFECTIVE_CONTROLS                   ,
CONTROLS_VERIFIED                      ,
TOTAL_NUMBER_OF_CTRLS	,
OPEN_ISSUES                            ,
PRO_PENDING_CERT_PRCNT                 ,
PROCESSES_WITH_ISSUES_PRCNT            ,
ORG_WITH_INEFF_CONTROLS_PRCNT  ,
PROC_WITH_INEFF_CONTROLS_PRCNT         ,
UNMITIGATED_RISKS_PRCNT                ,
INEFFECTIVE_CONTROLS_PRCNT             ,
OBJ_CONTEXT                            ,
CREATED_BY                             ,
CREATION_DATE                          ,
LAST_UPDATED_BY                        ,
LAST_UPDATE_DATE                       ,
LAST_UPDATE_LOGIN                      ,
SECURITY_GROUP_ID                      ,
OBJECT_VERSION_NUMBER
)
values
(
 X_FIN_CERTIFICATION_ID,
 X_FINANCIAL_STATEMENT_ID,
 X_FINANCIAL_ITEM_ID     ,
 X_NATURAL_ACCOUNT_ID    ,
 X_ACCOUNT_GROUP_ID      ,
 X_OBJECT_TYPE           ,
 X_PROC_PENDING_CERTIFICATION,
 X_TOTAL_NUMBER_OF_PROCESSES ,
 X_PROC_CERTIFIED_WITH_ISSUES,
X_TOTAL_NUMBER_OF_PROCESSES ,
-- X_PROCS_FOR_CERT_DONE  -- was replaced by total processes,
X_PROC_EVALUATED         ,
 X_ORG_WITH_INEFFECTIVE_CTRLS,
 --X_ORG_CERTIFIED             ,
 x_orgs_FOR_CERT_DONE                     ,
 x_orgs_evaluated                         ,
 x_total_orgs	,
 X_PROC_WITH_INEFFECTIVE_CTRLS,
 X_UNMITIGATED_RISKS          ,
 X_RISKS_VERIFIED             ,
 X_TOTAL_RISKS	,
 X_INEFFECTIVE_CONTROLS       ,
 X_CONTROLS_VERIFIED          ,
 X_TOTAL_CONTROLS	,
 X_OPEN_ISSUES                ,
 round(nvl(x_proc_pending_certification, 0) / decode(nvl(x_total_number_of_processes, 0), 0, 1, x_total_number_of_processes), 2) * 100,
 round(nvl(x_proc_certified_with_issues, 0)/ decode(nvl(x_total_number_of_processes, 0), 0, 1, x_total_number_of_processes), 2) * 100,
 round(nvl(x_org_with_ineffective_ctrls, 0) / decode(nvl(x_total_orgs, 0), 0, 1, x_total_orgs), 2) * 100,
 round(nvl(x_proc_with_ineffective_ctrls, 0) / decode(nvl(x_total_number_of_processes, 0), 0, 1, x_total_number_of_processes), 2) * 100,
 round(nvl(x_unmitigated_risks, 0) / decode(nvl(x_total_risks, 0), 0, 1, x_total_risks), 2)* 100,
 round(nvl(x_ineffective_controls, 0) / decode(nvl(x_total_controls, 0), 0, 1,  x_total_controls), 2)* 100,
 X_OBJ_CONTEXT                ,
 X_CREATED_BY                 ,
 X_CREATION_DATE              ,
 X_LAST_UPDATED_BY            ,
 X_LAST_UPDATE_DATE           ,
 X_LAST_UPDATE_LOGIN          ,
 X_SECURITY_GROUP_ID          ,
 X_OBJECT_VERSION_NUMBER
);

else -- update

  update amw_fin_cert_eval_sum set
  FIN_CERTIFICATION_ID
= X_FIN_CERTIFICATION_ID,
FINANCIAL_STATEMENT_ID
 = X_FINANCIAL_STATEMENT_ID,
FINANCIAL_ITEM_ID
 = X_FINANCIAL_ITEM_ID     ,
NATURAL_ACCOUNT_ID
 = X_NATURAL_ACCOUNT_ID,
ACCOUNT_GROUP_ID
 = X_ACCOUNT_GROUP_ID      ,
OBJECT_TYPE
 = X_OBJECT_TYPE           ,
PROC_PENDING_CERTIFICATION
 = X_PROC_PENDING_CERTIFICATION,
TOTAL_NUMBER_OF_PROCESSES
 = X_TOTAL_NUMBER_OF_PROCESSES,
PROC_CERTIFIED_WITH_ISSUES
 = X_PROC_CERTIFIED_WITH_ISSUES,
PROCS_FOR_CERT_DONE
= X_TOTAL_NUMBER_OF_PROCESSES ,
-- X_PROCS_FOR_CERT_DONE  -- was replaced by total processes
PROC_EVALUATED
= X_PROC_EVALUATED ,
ORG_WITH_INEFFECTIVE_CONTROLS
 = X_ORG_WITH_INEFFECTIVE_CTRLS,
orgs_FOR_CERT_DONE
 = X_orgs_FOR_CERT_DONE                     ,
orgs_evaluated
 = X_orgs_evaluated                         ,
 total_number_of_orgs
 = x_total_orgs	,
PROC_WITH_INEFFECTIVE_CONTROLS
= X_PROC_WITH_INEFFECTIVE_CTRLS,
UNMITIGATED_RISKS
 = X_UNMITIGATED_RISKS          ,
RISKS_VERIFIED
 = X_RISKS_VERIFIED             ,
 TOTAL_NUMBER_OF_RISKS
 =  X_TOTAL_RISKS,
INEFFECTIVE_CONTROLS
 = X_INEFFECTIVE_CONTROLS,
CONTROLS_VERIFIED
 = X_CONTROLS_VERIFIED        ,
 TOTAL_NUMBER_OF_CTRLS
 = X_TOTAL_CONTROLS	,
OPEN_ISSUES
 = X_OPEN_ISSUES                ,
pro_pending_cert_prcnt= round(nvl(x_proc_pending_certification, 0) / decode(nvl(x_total_number_of_processes, 0), 0, 1,x_total_number_of_processes), 2) * 100,
processes_with_issues_prcnt= round(nvl(x_proc_certified_with_issues, 0)/ decode(nvl(x_total_number_of_processes, 0), 0, 1, x_total_number_of_processes), 2) * 100,
org_with_ineff_controls_prcnt =  round(nvl(x_org_with_ineffective_ctrls, 0) / decode(nvl(x_total_orgs, 0), 0, 1, x_total_orgs), 2) * 100,
proc_with_ineff_controls_prcnt= round(nvl(x_proc_with_ineffective_ctrls, 0) / decode(nvl(x_total_number_of_processes, 0), 0, 1, x_total_number_of_processes), 2) * 100,
unmitigated_risks_prcnt =  round(nvl(x_unmitigated_risks, 0) / decode(nvl(x_total_risks, 0), 0, 1, x_total_risks), 2)* 100,
ineffective_controls_prcnt  = round(nvl(x_ineffective_controls, 0) / decode(nvl(x_total_controls, 0), 0, 1,  x_total_controls), 2)* 100,
OBJ_CONTEXT
 = X_OBJ_CONTEXT                ,
CREATED_BY
 = X_CREATED_BY                 ,
CREATION_DATE
 = X_CREATION_DATE           ,
LAST_UPDATED_BY
 = X_LAST_UPDATED_BY      ,
LAST_UPDATE_DATE
 = X_LAST_UPDATE_DATE     ,
LAST_UPDATE_LOGIN
 = X_LAST_UPDATE_LOGIN    ,
SECURITY_GROUP_ID
 = X_SECURITY_GROUP_ID      ,
OBJECT_VERSION_NUMBER
 = X_OBJECT_VERSION_NUMBER
 WHERE FIN_CERTIFICATION_ID = X_FIN_CERTIFICATION_ID
   AND FINANCIAL_STATEMENT_ID = X_FINANCIAL_STATEMENT_ID
        AND NVL(FINANCIAL_ITEM_ID,0) = NVL(X_FINANCIAL_ITEM_ID,0)
        AND NVL(NATURAL_ACCOUNT_ID,0)     = NVL(X_NATURAL_ACCOUNT_ID,0)
        AND NVL(ACCOUNT_GROUP_ID,0)       = NVL(X_ACCOUNT_GROUP_ID,0)
        AND OBJECT_TYPE            = X_OBJECT_TYPE;
 end if;

 x_return_status := FND_API.G_RET_STS_SUCCESS;

 EXCEPTION
     WHEN NO_DATA_FOUND THEN
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
       ROLLBACK TO insert_fin_cert_eval_sum;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);

END insert_fin_cert_eval_sum;



 ----------------------------- ********************************** ----------------------
-- this procedure build a flat table for financial certification, item, account, process
-- it contains the whole structure of financial information no matter weather process associated to it or not
-- it contains 3 layesr joins for 4 situations.
-- layer 1: join certification  with fin_stmnt_items
-- layter 2: join resultset of layer1 with key_account
-- layer 3: join resultset of layer2 with process hierarchy via account_association

--situation 1: accounts have one or more children linking to a process
--situation 2: account directly assocates with a process and also links to one or more financial items
--situation 3: --- add all of childen accounts which associate with the top account which directly links to an item
--- e.g A2 is a child of A1. A1 links to an financial item which relates to fin certification
--  and P1 is associated with A2. so we want to add one record which contains A2, P1 info. in scope table

--situation 4:
-- account has sub-account, but account itself doesn't associate with any item. His parent/parent's parent links to -- -- item.
--- and its sub-account links to a process. e.g A1-A2-A3, A3-P1. so this query make A2-P

---for performance reason, we split a big query into 4 queries based on 4 situtation.
----------------------------- ********************************** ----------------------

PROCEDURE INSERT_FIN_CERT_SCOPE(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
) IS

L_COUNT NUMBER;
L_COUNT2 NUMBER;
l_api_name           CONSTANT VARCHAR2(30) := 'INSERT_FIN_CERT_SCOPE';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

SAVEPOINT INSERT_FIN_CERT_SCOPE;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;

SELECT COUNT(1) INTO L_COUNT FROM AMW_FIN_CERT_SCOPE
WHERE FIN_CERTIFICATION_ID = P_CERTIFICATION_ID;

/** even if there is no process attached to an account. if the account belongs to the financial
**  certification, we should add it to the amw_fin_cert_scope table
SELECT COUNT(1) INTO L_COUNT2 FROM AMW_FIN_PROCESS_EVAL_SUM
WHERE FIN_CERTIFICATION_ID = P_CERTIFICATION_ID;


IF (L_COUNT2 = 0 OR L_COUNT2 IS NULL) THEN
RETURN;
END IF;
****/

IF (L_COUNT = 0 OR L_COUNT IS NULL) THEN
----add those accounts that have one or more children linking to a process
insert into amw_fin_cert_scope(
FIN_CERT_SCOPE_ID ,
FIN_CERTIFICATION_ID ,
STATEMENT_GROUP_ID ,
FINANCIAL_STATEMENT_ID,
FINANCIAL_ITEM_ID,
ACCOUNT_GROUP_ID ,
NATURAL_ACCOUNT_ID                     ,
ORGANIZATION_ID				,
PROCESS_ID				,
CREATED_BY                             ,
CREATION_DATE                          ,
LAST_UPDATED_BY                        ,
LAST_UPDATE_DATE                       ,
LAST_UPDATE_LOGIN                      ,
SECURITY_GROUP_ID                      ,
OBJECT_VERSION_NUMBER )
SELECT AMW_FIN_CERT_SCOPE_S.NEXTVAL, P_CERTIFICATION_ID, itemaccmerge.statement_group_id, itemaccmerge.financial_statement_id, itemaccmerge.financial_item_id,
itemaccmerge.account_group_id, itemaccmerge.natural_account_id,itemaccmerge.organization_id, case when proc.child_process_id = -2 then itemaccmerge.process_id else proc.child_process_id end process_id,
1, sysdate, 1, sysdate, 1, null, 1
FROM
	AMW_FIN_PROCESS_FLAT proc,

	(SELECT temp.STATEMENT_GROUP_ID, temp.FINANCIAL_STATEMENT_ID, temp.FINANCIAL_ITEM_ID,
 		temp.ACCOUNT_GROUP_ID,
 		case when temp.NATURAL_ACCOUNT_ID = -1 then temp.child_natural_account_id else temp.NATURAL_ACCOUNT_ID end natural_account_id,
 		ACCREL.PK1 organization_id, ACCREL.PK2 process_id
 	 FROM
 		(SELECT NATURAL_ACCOUNT_ID, PK1, PK2 FROM AMW_ACCT_ASSOCIATIONS
 		 WHERE OBJECT_TYPE = 'PROCESS_ORG'
 		 AND APPROVAL_DATE IS NOT NULL
 		 AND DELETION_APPROVAL_DATE IS NULL
 		 ) ACCREL,

	   	 (select temp2.statement_group_id, temp2.financial_statement_id, temp2.financial_item_id,
 		  temp2.account_group_id, temp2.natural_account_id, flat.child_natural_account_id
		  from AMW_FIN_KEY_ACCT_FLAT flat,
 		  (select distinct temp1.statement_group_id, temp1.financial_statement_id,
		   case when temp1.financial_item_id = -1 then temp1.child_financial_item_id
		   else temp1.financial_item_id end financial_item_id, itemaccrel.account_group_id, itemaccrel.natural_account_id
		  from  AMW_FIN_ITEMS_KEY_ACC ITEMACCREL,

      			(select -1 financial_item_id, itemb.financial_item_id child_financial_item_id, itemb.statement_group_id, itemb.financial_statement_id
			FROM AMW_CERTIFICATION_B cert,
     	     		     AMW_FIN_STMNT_ITEMS_B itemb
			WHERE cert.CERTIFICATION_ID = P_CERTIFICATION_ID
			and cert.statement_group_id = itemb.statement_group_id
			and cert.financial_statement_id = itemb.financial_statement_id
		UNION ALL
			select itemb.financial_item_id, itemflat.child_financial_item_id, itemb.statement_group_id, itemb.financial_statement_id
			from AMW_FIN_ITEM_FLAT itemflat,
     	     		        AMW_FIN_STMNT_ITEMS_B itemb,
             		     	        AMW_CERTIFICATION_B cert
			where
				cert.CERTIFICATION_ID = P_CERTIFICATION_ID
				and cert.statement_group_id = itemb.statement_group_id
				and cert.financial_statement_id = itemb.financial_statement_id
				and itemflat.parent_financial_item_id = itemb.financial_item_id
				and itemflat.statement_group_id = itemb.statement_group_id
				and itemflat.financial_statement_id = itemb.financial_statement_id) temp1
			where
    				temp1.statement_group_id = ITEMACCREL.statement_group_id (+)
   				and temp1.financial_statement_id = ITEMACCREL.financial_statement_id (+)
   				and temp1.child_financial_item_id = ITEMACCREL.financial_item_id (+)) temp2
 		   where temp2.account_group_id = flat.account_group_id
 		   and temp2.natural_account_id = flat.parent_natural_account_id) temp
 	WHERE
 		ACCREL.NATURAL_ACCOUNT_ID  = temp.CHILD_NATURAL_ACCOUNT_ID) itemaccmerge
		-- only insert those account whose childen have a link to the process
		--ACCREL.NATURAL_ACCOUNT_ID (+) = temp.CHILD_NATURAL_ACCOUNT_ID) itemaccmerge
WHERE proc.organization_id (+) = itemaccmerge.organization_id
and proc.parent_process_id (+) = itemaccmerge.process_id
and proc.fin_certification_id (+) = p_certification_id;

-- add account which has link to a item and also directly assocates with a process
insert into amw_fin_cert_scope(
FIN_CERT_SCOPE_ID ,
FIN_CERTIFICATION_ID ,
STATEMENT_GROUP_ID,
FINANCIAL_STATEMENT_ID ,
FINANCIAL_ITEM_ID,
ACCOUNT_GROUP_ID                       ,
NATURAL_ACCOUNT_ID                     ,
ORGANIZATION_ID				,
PROCESS_ID				,
CREATED_BY                             ,
CREATION_DATE                          ,
LAST_UPDATED_BY                        ,
LAST_UPDATE_DATE                       ,
LAST_UPDATE_LOGIN                      ,
SECURITY_GROUP_ID                      ,
OBJECT_VERSION_NUMBER )
SELECT AMW_FIN_CERT_SCOPE_S.NEXTVAL, P_CERTIFICATION_ID, itemaccmerge.statement_group_id, itemaccmerge.financial_statement_id, itemaccmerge.financial_item_id,
itemaccmerge.account_group_id, itemaccmerge.natural_account_id,itemaccmerge.organization_id, case when proc.child_process_id = -2 then itemaccmerge.process_id else proc.child_process_id end process_id,
1, sysdate, 1, sysdate, 1, null, 1
FROM
	AMW_FIN_PROCESS_FLAT proc,

	(SELECT temp.STATEMENT_GROUP_ID, temp.FINANCIAL_STATEMENT_ID, temp.FINANCIAL_ITEM_ID,
 temp.ACCOUNT_GROUP_ID,temp.NATURAL_ACCOUNT_ID,ACCREL.PK1 organization_id, ACCREL.PK2 process_id
 	 FROM
 		(SELECT NATURAL_ACCOUNT_ID, PK1, PK2 FROM AMW_ACCT_ASSOCIATIONS
 		 WHERE OBJECT_TYPE = 'PROCESS_ORG'
 		 AND APPROVAL_DATE IS NOT NULL
 		 AND DELETION_APPROVAL_DATE IS NULL
 		 ) ACCREL,

	   	(select distinct temp1.statement_group_id, temp1.financial_statement_id,
		   case when temp1.financial_item_id = -1 then temp1.child_financial_item_id
		   else temp1.financial_item_id end financial_item_id, itemaccrel.account_group_id, itemaccrel.natural_account_id
		  from  AMW_FIN_ITEMS_KEY_ACC ITEMACCREL,

      			(select -1 financial_item_id, itemb.financial_item_id child_financial_item_id, itemb.statement_group_id, itemb.financial_statement_id
			FROM AMW_CERTIFICATION_B cert,
     	     		     AMW_FIN_STMNT_ITEMS_B itemb
			WHERE cert.CERTIFICATION_ID = P_CERTIFICATION_ID
			and cert.statement_group_id = itemb.statement_group_id
			and cert.financial_statement_id = itemb.financial_statement_id
		UNION ALL
			select itemb.financial_item_id, itemflat.child_financial_item_id, itemb.statement_group_id, itemb.financial_statement_id
			from AMW_FIN_ITEM_FLAT itemflat,
     	     		        AMW_FIN_STMNT_ITEMS_B itemb,
             		     	        AMW_CERTIFICATION_B cert
			where
				cert.CERTIFICATION_ID = P_CERTIFICATION_ID
				and cert.statement_group_id = itemb.statement_group_id
				and cert.financial_statement_id = itemb.financial_statement_id
				and itemflat.parent_financial_item_id = itemb.financial_item_id
				and itemflat.statement_group_id = itemb.statement_group_id
				and itemflat.financial_statement_id = itemb.financial_statement_id) temp1
			where
    				temp1.statement_group_id = ITEMACCREL.statement_group_id (+)
   				and temp1.financial_statement_id = ITEMACCREL.financial_statement_id (+)
   				and temp1.child_financial_item_id = ITEMACCREL.financial_item_id (+)) temp
 	WHERE
		ACCREL.NATURAL_ACCOUNT_ID (+) = temp.NATURAL_ACCOUNT_ID) itemaccmerge
WHERE proc.organization_id (+) = itemaccmerge.organization_id
and proc.parent_process_id (+) = itemaccmerge.process_id
and proc.fin_certification_id (+) = p_certification_id;

--- add all of childen accounts which associate with the top account which directly links to an item
--- e.g A2 is a child of A1. A1 links to an financial item which relates to fin certification
--  and P1 is associated with A2. so we want to add one record which contains A2, P1 info. in scope table
insert into amw_fin_cert_scope(
FIN_CERT_SCOPE_ID 			,
FIN_CERTIFICATION_ID                   ,
STATEMENT_GROUP_ID		       ,
FINANCIAL_STATEMENT_ID                 ,
FINANCIAL_ITEM_ID                      ,
ACCOUNT_GROUP_ID                       ,
NATURAL_ACCOUNT_ID                     ,
ORGANIZATION_ID				,
PROCESS_ID				,
CREATED_BY                             ,
CREATION_DATE                          ,
LAST_UPDATED_BY                        ,
LAST_UPDATE_DATE                       ,
LAST_UPDATE_LOGIN                      ,
SECURITY_GROUP_ID                      ,
OBJECT_VERSION_NUMBER )
SELECT AMW_FIN_CERT_SCOPE_S.NEXTVAL, P_CERTIFICATION_ID, itemaccmerge.statement_group_id, itemaccmerge.financial_statement_id, itemaccmerge.financial_item_id,
itemaccmerge.account_group_id, itemaccmerge.natural_account_id,itemaccmerge.organization_id, case when proc.child_process_id = -2 then itemaccmerge.process_id else proc.child_process_id end process_id,
1, sysdate, 1, sysdate, 1, null, 1
FROM
	AMW_FIN_PROCESS_FLAT proc,

	(SELECT temp.STATEMENT_GROUP_ID, temp.FINANCIAL_STATEMENT_ID, temp.FINANCIAL_ITEM_ID,
 		temp.ACCOUNT_GROUP_ID,
 		temp.child_natural_account_id natural_account_id,
 		ACCREL.PK1 organization_id, ACCREL.PK2 process_id
 	 FROM
 		(SELECT NATURAL_ACCOUNT_ID, PK1, PK2 FROM AMW_ACCT_ASSOCIATIONS
 		 WHERE OBJECT_TYPE = 'PROCESS_ORG'
 		 AND APPROVAL_DATE IS NOT NULL
 		 AND DELETION_APPROVAL_DATE IS NULL
 		 ) ACCREL,

	   	(select temp2.statement_group_id, temp2.financial_statement_id, temp2.financial_item_id,
  		flat.account_group_id, flat.child_natural_account_id
  		from AMW_FIN_KEY_ACCT_FLAT flat,
 		        (select distinct temp1.statement_group_id, temp1.financial_statement_id,
		   case when temp1.financial_item_id = -1 then temp1.child_financial_item_id
		   else temp1.financial_item_id end financial_item_id, itemaccrel.account_group_id, itemaccrel.natural_account_id
		  from  AMW_FIN_ITEMS_KEY_ACC ITEMACCREL,

      			(select -1 financial_item_id, itemb.financial_item_id child_financial_item_id, itemb.statement_group_id, itemb.financial_statement_id
			FROM AMW_CERTIFICATION_B cert,
     	     		     AMW_FIN_STMNT_ITEMS_B itemb
			WHERE cert.CERTIFICATION_ID = P_CERTIFICATION_ID
			and cert.statement_group_id = itemb.statement_group_id
			and cert.financial_statement_id = itemb.financial_statement_id
		UNION ALL
			select itemb.financial_item_id, itemflat.child_financial_item_id, itemb.statement_group_id, itemb.financial_statement_id
			from AMW_FIN_ITEM_FLAT itemflat,
     	     		        AMW_FIN_STMNT_ITEMS_B itemb,
             		     	        AMW_CERTIFICATION_B cert
			where
				cert.CERTIFICATION_ID = P_CERTIFICATION_ID
				and cert.statement_group_id = itemb.statement_group_id
				and cert.financial_statement_id = itemb.financial_statement_id
				and itemflat.parent_financial_item_id = itemb.financial_item_id
				and itemflat.statement_group_id = itemb.statement_group_id
				and itemflat.financial_statement_id = itemb.financial_statement_id) temp1
			where
    				temp1.statement_group_id = ITEMACCREL.statement_group_id (+)
   				and temp1.financial_statement_id = ITEMACCREL.financial_statement_id (+)
   				and temp1.child_financial_item_id = ITEMACCREL.financial_item_id (+))temp2
 		where temp2.account_group_id = flat.account_group_id
 		and temp2.natural_account_id = flat.parent_natural_account_id) temp
 	WHERE
		ACCREL.NATURAL_ACCOUNT_ID (+)  = temp.CHILD_NATURAL_ACCOUNT_ID)  itemaccmerge
WHERE proc.organization_id (+) = itemaccmerge.organization_id
and proc.parent_process_id (+) = itemaccmerge.process_id
and proc.fin_certification_id (+) = p_certification_id;



-- account has sub-account, but account itself doesn't associate with any item. His parent/parent's parent links to -- -- item.
--- and its sub-account links to a process. e.g A1-A2-A3, A3-P1. so this query make A2-P
insert into amw_fin_cert_scope(
FIN_CERT_SCOPE_ID 			,
FIN_CERTIFICATION_ID                   ,
STATEMENT_GROUP_ID		       ,
FINANCIAL_STATEMENT_ID                 ,
FINANCIAL_ITEM_ID                      ,
ACCOUNT_GROUP_ID                       ,
NATURAL_ACCOUNT_ID                     ,
ORGANIZATION_ID				,
PROCESS_ID				,
CREATED_BY                             ,
CREATION_DATE                          ,
LAST_UPDATED_BY                        ,
LAST_UPDATE_DATE                       ,
LAST_UPDATE_LOGIN                      ,
SECURITY_GROUP_ID                      ,
OBJECT_VERSION_NUMBER )
SELECT AMW_FIN_CERT_SCOPE_S.NEXTVAL, P_CERTIFICATION_ID, null statement_group_id, null financial_statement_id,
null financial_item_id,
itemaccmerge.account_group_id, itemaccmerge.natural_account_id,itemaccmerge.organization_id,
case when proc.child_process_id = -2 then itemaccmerge.process_id else proc.child_process_id end process_id,
1, sysdate, 1, sysdate, 1, null, 1
FROM
	AMW_FIN_PROCESS_FLAT proc,

	(SELECT temp.ACCOUNT_GROUP_ID,
 		temp.NATURAL_ACCOUNT_ID,
 		ACCREL.PK1 organization_id, ACCREL.PK2 process_id
 	 FROM
 		(SELECT NATURAL_ACCOUNT_ID, PK1, PK2 FROM AMW_ACCT_ASSOCIATIONS
 		 WHERE OBJECT_TYPE = 'PROCESS_ORG'
 		 AND APPROVAL_DATE IS NOT NULL
 		 AND DELETION_APPROVAL_DATE IS NULL
 		 ) ACCREL,

	   	(select flat.account_group_id, flat.parent_natural_account_id natural_account_id, flat.child_natural_account_id
 		from
 			(select flat.account_group_id, flat.parent_natural_account_id, flat.child_natural_account_id
				from AMW_FIN_KEY_ACCT_FLAT flat
			start with (account_group_id, parent_natural_account_id) in
			(select account_group_id, natural_account_id
 			      from amw_fin_cert_scope
 			      where fin_certification_id = P_CERTIFICATION_ID)
 			connect by parent_natural_account_id = prior child_natural_account_id
 			           and account_group_id = prior account_group_id) flat
 	       where not exists (
 		select 'Y'
 		from AMW_FIN_CERT_SCOPE  temp2
 		where flat.account_group_id = temp2.account_group_id
 		and   flat.parent_natural_account_id = temp2.natural_account_id
 		and   temp2.fin_certification_id = P_CERTIFICATION_ID) ) temp
 	WHERE
		ACCREL.NATURAL_ACCOUNT_ID (+) = temp.CHILD_NATURAL_ACCOUNT_ID)  itemaccmerge
WHERE proc.organization_id (+) = itemaccmerge.organization_id
and proc.parent_process_id (+) = itemaccmerge.process_id
and proc.fin_certification_id(+) = P_CERTIFICATION_ID;

END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
       ROLLBACK TO INSERT_FIN_CERT_SCOPE;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);

END INSERT_FIN_CERT_SCOPE;

--------------------------------------- ******************************** ----------------------------

PROCEDURE INSERT_FIN_CTRL(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
) IS
L_COUNT NUMBER;
l_error_message VARCHAR2(4000);
l_api_name           CONSTANT VARCHAR2(30) := 'INSERT_FIN_CTRL';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

SAVEPOINT INSERT_FIN_CTRL;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;

SELECT COUNT(1) INTO L_COUNT FROM AMW_FIN_ITEM_ACC_CTRL
WHERE FIN_CERTIFICATION_ID = P_CERTIFICATION_ID;

IF (L_COUNT = 0 OR L_COUNT IS NULL) THEN

insert into amw_fin_item_acc_ctrl
(
OBJECT_TYPE,
FIN_CERTIFICATION_ID,
STATEMENT_GROUP_ID ,
FINANCIAL_STATEMENT_ID,
FINANCIAL_ITEM_ID,
ACCOUNT_GROUP_ID ,
NATURAL_ACCOUNT_ID ,
ORGANIZATION_ID ,
CONTROL_ID ,
CONTROL_REV_ID ,
OPINION_LOG_ID,
CREATED_BY ,
CREATION_DATE  ,
LAST_UPDATED_BY  ,
LAST_UPDATE_DATE  ,
LAST_UPDATE_LOGIN  ,
SECURITY_GROUP_ID ,
OBJECT_VERSION_NUMBER )
SELECT distinct 'ACCOUNT' OBJECT_TYPE , fin_certification_id, statement_group_id, financial_statement_id, null financial_item_id,
account_group_id, natural_account_id, organization_id, control_id, control_rev_id, pk5 opinion_log_id, 1, sysdate, 1, sysdate, 1, null, 1
from amw_fin_cert_scope scp,
     amw_control_associations ctrl
where ctrl.pk1 = scp.fin_certification_id
and ctrl.object_type = 'RISK_FINCERT'
and scp.natural_account_id is not null
and scp.organization_id = ctrl.pk2
and scp.process_id = ctrl.pk3
and ctrl.pk1 = p_certification_id
union all
select distinct 'FINANCIAL ITEM' OBJECT_TYPE, fin_certification_id, statement_group_id, financial_statement_id, financial_item_id,
null account_group_id, null natural_account_id, organization_id, control_id,  control_rev_id, pk5 opinion_log_id, 1, sysdate, 1, sysdate, 1, null, 1
from amw_fin_cert_scope scp,
     amw_control_associations ctrl
where ctrl.pk1 = scp.fin_certification_id
and ctrl.object_type = 'RISK_FINCERT'
and scp.organization_id = ctrl.pk2
and scp.process_id = ctrl.pk3
and ctrl.pk1 = p_certification_id
union all
select distinct  'FINANCIAL STATEMENT' OBJECT_TYPE, fin_certification_id, statement_group_id, financial_statement_id, null financial_item_id,
null account_group_id, null natural_account_id, organization_id, control_id, control_rev_id, pk5 opinion_log_id, 1, sysdate, 1, sysdate, 1, null, 1
from amw_fin_cert_scope scp,
     amw_control_associations ctrl
where ctrl.pk1 = scp.fin_certification_id
and ctrl.object_type = 'RISK_FINCERT'
and scp.organization_id = ctrl.pk2
and scp.process_id = ctrl.pk3
and ctrl.pk1 = p_certification_id;

if(p_commit <> FND_API.g_false)
then commit;
end if;

END IF;
x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
       ROLLBACK TO INSERT_FIN_CTRL;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
 		RETURN;
END INSERT_FIN_CTRL;

PROCEDURE INSERT_FIN_RISK(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
)IS
L_COUNT NUMBER;

l_api_name           CONSTANT VARCHAR2(30) := 'INSERT_FIN_RISK';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN
SAVEPOINT INSERT_FIN_RISK;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;

SELECT COUNT(1) INTO L_COUNT FROM AMW_FIN_ITEM_ACC_RISK
WHERE FIN_CERTIFICATION_ID = P_CERTIFICATION_ID;

IF (L_COUNT = 0 OR L_COUNT IS NULL) THEN

insert into amw_fin_item_acc_risk(
OBJECT_TYPE,
FIN_CERTIFICATION_ID,
STATEMENT_GROUP_ID,
FINANCIAL_STATEMENT_ID,
FINANCIAL_ITEM_ID,
ACCOUNT_GROUP_ID,
NATURAL_ACCOUNT_ID,
ORGANIZATION_ID,
PROCESS_ID,
RISK_ID,
RISK_REV_ID,
OPINION_LOG_ID,
CREATED_BY ,
CREATION_DATE  ,
LAST_UPDATED_BY  ,
LAST_UPDATE_DATE  ,
LAST_UPDATE_LOGIN  ,
SECURITY_GROUP_ID ,
OBJECT_VERSION_NUMBER )
SELECT distinct 'ACCOUNT' OBJECT_TYPE , fin_certification_id, statement_group_id, financial_statement_id, null financial_item_id,
account_group_id, natural_account_id, organization_id, process_id, risk_id, risk_rev_id, pk4 opinion_log_id, 1, sysdate, 1, sysdate, 1, null, 1
from amw_fin_cert_scope scp,
     amw_risk_associations risk
where risk.pk1 = scp.fin_certification_id
and  risk.object_type = 'PROCESS_FINCERT'
and scp.natural_account_id is not null
and scp.organization_id = risk.pk2
and scp.process_id = risk.pk3
and risk.pk1 = p_certification_id
union all
select distinct 'FINANCIAL ITEM' OBJECT_TYPE, fin_certification_id, statement_group_id, financial_statement_id, financial_item_id,
null account_group_id, null natural_account_id, organization_id, process_id, risk_id, risk_rev_id, pk4 opinion_log_id, 1, sysdate, 1, sysdate, 1, null, 1
from amw_fin_cert_scope scp,
     amw_risk_associations risk
where risk.pk1 = scp.fin_certification_id
and risk.object_type = 'PROCESS_FINCERT'
and scp.organization_id = risk.pk2
and scp.process_id = risk.pk3
and risk.pk1 = p_certification_id
union all
select distinct  'FINANCIAL STATEMENT' OBJECT_TYPE, fin_certification_id, statement_group_id, financial_statement_id, null financial_item_id,
null account_group_id, null natural_account_id, organization_id, process_id, risk_id, risk_rev_id, pk4 opinion_log_id, 1, sysdate, 1, sysdate, 1, null, 1
from amw_fin_cert_scope scp,
     amw_risk_associations risk
where risk.pk1 = scp.fin_certification_id
and risk.object_type = 'PROCESS_FINCERT'
and scp.organization_id = risk.pk2
and scp.process_id = risk.pk3
and risk.pk1 = p_certification_id;

if(p_commit <> FND_API.g_false)
then commit;
end if;

END IF;
x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
     WHEN NO_DATA_FOUND THEN
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
       ROLLBACK TO INSERT_FIN_RISK;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;

END INSERT_FIN_RISK;


Procedure GetGLPeriodfor_FinCertEvalSum
(P_Certification_ID in number,
P_start_date out NOCOPY  date,
P_end_date out NOCOPY  date)
IS
BEGIN
 Select
GL_PERIODS.START_DATE ,
GL_PERIODS.END_DATE
into P_start_date, P_end_Date
from
AMW_CERTIFICATION_VL CERTIFICATION,
amw_gl_periods_v GL_PERIODS
WHERE
GL_PERIODS.PERIOD_NAME = CERTIFICATION.CERTIFICATION_PERIOD_NAME
AND GL_PERIODS.PERIOD_SET_NAME = CERTIFICATION.CERTIFICATION_PERIOD_SET_NAME
and CERTIFICATION.OBJECT_TYPE='FIN_STMT'
AND CERTIFICATION.CERTIFICATION_ID = P_Certification_ID;


  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*** Record doesn't exist ***/
    fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.GetGLPeriodfor_FinCertEvalSum');
    RETURN;
  WHEN OTHERS THEN
    /*** Raise any other error ***/
fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.GetGLPeriodfor_FinCertEvalSum');
fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
    RAISE;

END GetGLPeriodfor_FinCertEvalSum;


PROCEDURE POPULATE_PROC_HIERARCHY(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
P_CERTIFICATION_ID NUMBER,
P_PROCESS_ID NUMBER,
P_ORGANIZATION_ID NUMBER,
p_account_process_flag VARCHAR2,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
 )IS

  l_count NUMBER;

  l_api_name           CONSTANT VARCHAR2(30) := 'POPULATE_PROC_HIERARCHY';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

  BEGIN

  SAVEPOINT POPULATE_PROC_HIERARCHY;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT COUNT(1) INTO l_count FROM AMW_FIN_PROCESS_FLAT
  WHERE PARENT_PROCESS_ID = P_PROCESS_ID
  AND ORGANIZATION_ID = P_ORGANIZATION_ID
  AND FIN_CERTIFICATION_ID = P_CERTIFICATION_ID;

  --process directly associates to the account which belongs to this financial statement
  -- to simplify the query, try amw_org_hierarchy_denorm
  IF(l_count = 0 or l_count is null) THEN
  		IF  p_account_process_flag = 'Y' THEN
   INSERT INTO AMW_FIN_PROCESS_FLAT
                    (
                     FIN_CERTIFICATION_ID,
                     PARENT_PROCESS_ID,
                     CHILD_PROCESS_ID,
                     ORGANIZATION_ID,
                     CREATED_BY ,
                     CREATION_DATE  ,
                     LAST_UPDATED_BY  ,
                     LAST_UPDATE_DATE  ,
                     LAST_UPDATE_LOGIN  ,
                     SECURITY_GROUP_ID ,
                     OBJECT_VERSION_NUMBER )
                     		(select P_CERTIFICATION_ID, P_PROCESS_ID, child_id, P_ORGANIZATION_ID, 1, sysdate, 1, sysdate, 1, null, 1
												from amw_approved_hierarchies
												start with parent_id = P_PROCESS_ID AND ORGANIZATION_ID = P_ORGANIZATION_ID
															and start_date is not null and end_date is null
												CONNECT BY PRIOR CHILD_ID = PARENT_ID AND ORGANIZATION_ID = P_ORGANIZATION_ID
					  									and start_date is not null and end_date is null
												UNION
												 select P_CERTIFICATION_ID, P_PROCESS_ID,  -2, P_ORGANIZATION_ID, 1, sysdate, 1, sysdate, 1, null, 1 from dual);
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
                     select P_CERTIFICATION_ID, process_id,  parent_child_id, organization_id, 1, sysdate, 1, sysdate, 1, null, 1
                     from amw_org_hierarchy_denorm
                     where organization_id = P_ORGANIZATION_ID
                  	and hierarchy_type = 'A'
                  	and process_id = P_PROCESS_ID
                  	and (up_down_ind = 'D'
                  	or (parent_child_id = -2 and  up_down_ind= 'U'));
*/
                 ELSE
                    INSERT INTO AMW_FIN_PROCESS_FLAT
                    (
                     FIN_CERTIFICATION_ID,
                     PARENT_PROCESS_ID,
                     CHILD_PROCESS_ID,
                     ORGANIZATION_ID,
                     CREATED_BY ,
                     CREATION_DATE  ,
                     LAST_UPDATED_BY  ,
                     LAST_UPDATE_DATE  ,
                     LAST_UPDATE_LOGIN  ,
                     SECURITY_GROUP_ID ,
                     OBJECT_VERSION_NUMBER )
                     	(select P_CERTIFICATION_ID, P_PROCESS_ID, child_id, P_ORGANIZATION_ID, 1, sysdate, 1, sysdate, 1, null, 1
												from amw_approved_hierarchies
												start with parent_id = P_PROCESS_ID AND ORGANIZATION_ID = P_ORGANIZATION_ID
															and start_date is not null and end_date is null
												CONNECT BY PRIOR CHILD_ID = PARENT_ID AND ORGANIZATION_ID = P_ORGANIZATION_ID
					  									and start_date is not null and end_date is null);
--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
                     select P_CERTIFICATION_ID, process_id,  parent_child_id, organization_id, 1, sysdate, 1, sysdate, 1, null, 1
                      from amw_org_hierarchy_denorm
                  	where organization_id = P_ORGANIZATION_ID
                  	and hierarchy_type = 'A'
                  	and process_id = P_PROCESS_ID
                  	and up_down_ind = 'D';
*/
                     END IF;

    END IF;

--process directly associates to the account which belongs to this financial statement
-- to be deleted because it's a less efficient solution
-- Note: select p_process_id is very important. it's different from select parent_id
/*
  IF  p_account_process_flag = 'Y' THEN
  INSERT INTO AMW_FIN_PROCESS_FLAT
  (CERTIFICATION_ID,
   PARENT_PROCESS_ID,
   CHILD_PROCESS_ID,
   ORGANIZATION_ID)
   (SELECT  distinct P_CERTIFICATION_ID, P_PROCESS_ID, child_id, organization_id
   FROM    AMW_APPROVED_HIERARCHIES
   START WITH parent_id = P_PROCESS_ID
   AND organization_id = P_ORGANIZATION_ID
   CONNECT BY prior child_id = parent_id
   AND  prior organization_id = organization_id
   UNION ALL
   SELECT P_CERTIFICATION_ID, P_PROCESS_ID, -1, P_ORGANIZATION_ID FROM DUAL);
  -- sub processes of the process which directly links to the account
  ELSE
  INSERT INTO AMW_FIN_PROCESS_FLAT
  (CERTIFICATION_ID,
   PARENT_PROCESS_ID,
   CHILD_PROCESS_ID,
   ORGANIZATION_ID)
   SELECT  distinct P_CERTIFICATION_ID, P_PROCESS_ID, child_id, organization_id
   FROM    AMW_APPROVED_HIERARCHIES
   START WITH parent_id = P_PROCESS_ID
   AND organization_id = P_ORGANIZATION_ID
   CONNECT BY prior child_id = parent_id
   AND  prior organization_id = organization_id;
   END IF;

      **********************/

if(p_commit <> FND_API.g_false)
then commit;
end if;
x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
       ROLLBACK TO POPULATE_PROC_HIERARCHY;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;

 END POPULATE_PROC_HIERARCHY;



--------------populate all of financial certification related summary tables -------------------------
FUNCTION Populate_Fin_Stmt_Cert_Sum
( p_subscription_guid   in     raw,
  p_event               in out NOCOPY wf_event_t)
return varchar2
IS

 l_key                    varchar2(240) := p_event.GetEventKey();
 l_org_id                 NUMBER;
 l_user_id 	            NUMBER;
 l_resp_id 	            NUMBER;
 l_resp_appl_id           NUMBER;
 l_security_group_id      NUMBER;
 l_fin_cert_id NUMBER;

 l_api_name           CONSTANT VARCHAR2(30) := 'Populate_Fin_Stmt_Cert_Sum';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);



BEGIN

SAVEPOINT Populate_Fin_Stmt_Cert_Sum;

fnd_file.put_line(fnd_file.LOG, 'start oracle.apps.amw.certification.create event subcription: Populate_Fin_Stmt_Cert_Sum' || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

  l_org_id := p_event.GetValueForParameter('ORG_ID');
  l_user_id := p_event.GetValueForParameter('USER_ID');
  l_resp_id := p_event.GetValueForParameter('RESP_ID');
  l_resp_appl_id := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_group_id := p_event.GetValueForParameter('SECURITY_GROUP_ID');

  fnd_global.apps_initialize (l_user_id, l_resp_id, l_resp_appl_id, l_security_group_id);

  --l_org_id := p_event.GetValueForParameter('ORG_ID');
   l_fin_cert_id :=  p_event.GetValueForParameter('FIN_CERTIFICATION_ID');

  fnd_file.put_line(fnd_file.LOG, 'fin_certification_id = ' || l_fin_cert_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

  IF (l_fin_cert_id  IS NOT NULL) THEN
   AMW_FINSTMT_CERT_BES_PKG.Master_Fin_Proc_Eval_Sum
   ( p_certification_id => l_fin_cert_id,
    --p_start_date => c_cert_Rec.start_date,
     p_commit => FND_API.g_true,
     x_return_status    => l_return_status,
     x_msg_count   => l_msg_count,
    x_msg_data    => l_msg_data);
  END IF;

  fnd_file.put_line(fnd_file.LOG, 'finish populating summary table with certification_id = ' || l_fin_cert_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

RETURN FND_API.G_RET_STS_SUCCESS;

EXCEPTION
 WHEN OTHERS THEN
    ROLLBACK TO Populate_Fin_Stmt_Cert_Sum;
     WF_CORE.CONTEXT('AMW_FINSTMT_CERT_BES_PKG', 'Populate_Fin_Stmt_Cert_Sum', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN FND_API.G_RET_STS_UNEXP_ERROR;

end Populate_Fin_Stmt_Cert_Sum;

FUNCTION Certification_Update
( p_subscription_guid   in     raw,
  p_event               in out NOCOPY wf_event_t
) return VARCHAR2
IS

 l_key                    varchar2(240) := p_event.GetEventKey();
 l_org_id                 NUMBER;
 l_user_id 	            NUMBER;
 l_resp_id 	            NUMBER;
 l_resp_appl_id           NUMBER;
 l_security_group_id      NUMBER;

  l_opinion_log_id  NUMBER;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

fnd_file.put_line(fnd_file.LOG, 'start oracle.apps.amw.opinion.certification.update event subcription: Certification_Update' || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

  /*
  l_org_id := p_event.GetValueForParameter('ORG_ID');
  l_user_id := p_event.GetValueForParameter('USER_ID');
  l_resp_id := p_event.GetValueForParameter('RESP_ID');
  l_resp_appl_id := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_group_id := p_event.GetValueForParameter('SECURITY_GROUP_ID');

  fnd_global.apps_initialize (l_user_id, l_resp_id, l_resp_appl_id, l_security_group_id);
  */



   l_opinion_log_id :=  p_event.GetValueForParameter('OPINION_LOG_ID');

fnd_file.put_line(fnd_file.LOG, 'before evaluation_update.opinion_log_id=' || l_opinion_log_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

	Certification_Update_Handler(
   	 p_opinion_log_id  => l_opinion_log_id,
     	x_return_status => l_return_status,
    	x_msg_count    => l_msg_count,
   	 x_msg_data     => l_msg_data);

fnd_file.put_line(fnd_file.LOG, 'after evaluation_update.opinion_log_id=' || l_opinion_log_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

 RETURN l_return_status;



EXCEPTION
 WHEN OTHERS THEN
     WF_CORE.CONTEXT('AMW_FINSTMT_CERT_BES_PKG', 'Certification_Update', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, FND_API.G_RET_STS_UNEXP_ERROR);
     RETURN l_return_status;

END  Certification_Update;


FUNCTION Evaluation_Update
( p_subscription_guid   in     raw,
  p_event               in out NOCOPY wf_event_t
) return VARCHAR2
IS


 l_key                    varchar2(240) := p_event.GetEventKey();
 l_org_id                 NUMBER;
 l_user_id 	            NUMBER;
 l_resp_id 	            NUMBER;
 l_resp_appl_id           NUMBER;
 l_security_group_id      NUMBER;

  l_opinion_log_id  NUMBER;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

fnd_file.put_line(fnd_file.LOG, 'start oracle.apps.amw.opinion.evaluation.update event subcription: evaluation_update' || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

  /*
  l_org_id := p_event.GetValueForParameter('ORG_ID');
  l_user_id := p_event.GetValueForParameter('USER_ID');
  l_resp_id := p_event.GetValueForParameter('RESP_ID');
  l_resp_appl_id := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_group_id := p_event.GetValueForParameter('SECURITY_GROUP_ID');

  fnd_global.apps_initialize (l_user_id, l_resp_id, l_resp_appl_id, l_security_group_id);
  */


  l_opinion_log_id :=  p_event.GetValueForParameter('OPINION_LOG_ID');

fnd_file.put_line(fnd_file.LOG, 'before evaluation_update.opinion_log_id=' || l_opinion_log_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

	Evaluation_Update_Handler(
   	 p_opinion_log_id  => l_opinion_log_id,
     	x_return_status => l_return_status,
    	x_msg_count    => l_msg_count,
   	 x_msg_data     => l_msg_data);

fnd_file.put_line(fnd_file.LOG, 'after evaluation_update.opinion_log_id=' || l_opinion_log_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

 RETURN l_return_status;


EXCEPTION
 WHEN OTHERS THEN
     WF_CORE.CONTEXT('AMW_FINSTMT_CERT_BES_PKG', 'Evaluation_Update', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, FND_API.G_RET_STS_UNEXP_ERROR);
     RETURN l_return_status;

END  Evaluation_Update;

PROCEDURE Certification_Update_Handler(
   p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
    p_opinion_log_id  IN       NUMBER,
     x_return_status             OUT  nocopy VARCHAR2,
    x_msg_count                 OUT  nocopy NUMBER,
    x_msg_data                  OUT  nocopy VARCHAR2
)
IS

 CURSOR Get_Obj_Name (p_opinion_log_id NUMBER) IS
 SELECT obj.obj_name , oplog.pk1_value, oplog.pk2_value, oplog.pk3_value,
 	oplog.pk4_value, oplog.pk5_value, oplog.opinion_id
 FROM FND_OBJECTS obj,
      AMW_OBJECT_OPINION_TYPES oot,
      AMW_OPINIONS_LOG oplog
 WHERE oplog.opinion_log_id = p_opinion_log_id
 AND   oplog.object_opinion_type_id = oot.object_opinion_type_id
 AND   oot.object_id = obj.object_id;

 l_opinion_log_id number;
 l_opinion_id number;
 l_object_name varchar2(100);
 l_pk1 number;
 l_pk2 number;
 l_pk3 number;
 l_pk4 number;
 l_pk5 number;

 l_api_name           CONSTANT VARCHAR2(30) := 'Certification_Update_Handler';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

SAVEPOINT Certification_Update_Handler;
fnd_file.put_line(fnd_file.LOG, 'start Certification_Update_Handler::' || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;
          g_refresh_flag := 'N';

 l_opinion_log_id := p_opinion_log_id;
  open Get_Obj_Name(l_opinion_log_id);
  fetch Get_Obj_Name into l_object_name, l_pk1, l_pk2, l_pk3, l_pk4, l_pk5, l_opinion_id;
  close Get_Obj_Name;

  IF (l_object_name = 'AMW_ORGANIZATION') THEN
  fnd_file.put_line(fnd_file.LOG, 'before organization_change_handler: org_id' || l_pk3 || ' opinion_log_id= ' || l_opinion_log_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
  ORGANIZATION_CHANGE_HANDLER(
  	p_org_id => l_pk3 ,
 	p_opinion_log_id => l_opinion_log_id,
 	p_action => 'CERTIFICATION',
 	x_return_status   => l_return_status,
	x_msg_count  => l_msg_count,
	x_msg_data    => l_msg_data);

    UPDATE AMW_FIN_ORG_EVAL_SUM
    SET
    LAST_UPDATE_DATE = sysdate,
    last_updated_by = fnd_global.user_id,
    last_update_login = fnd_global.conc_login_id,
    CERT_OPINION_LOG_ID  = l_opinion_log_id,
    CERT_OPINION_ID   = l_opinion_id
    WHERE ORGANIZATION_ID = l_pk1
    AND   FIN_CERTIFICATION_ID IN (SELECT CERTIFICATION_ID FROM  AMW_CERTIFICATION_B
   				  WHERE CERTIFICATION_STATUS IN ('ACTIVE', 'DRAFT'));
 if(p_commit <> FND_API.g_false)
then commit;
end if;

  fnd_file.put_line(fnd_file.LOG, 'after organization_change_handler: org_id' || l_pk3 || ' opinion_log_id= ' || l_opinion_log_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

  ELSIF (l_object_name = 'AMW_ORG_PROCESS') THEN
  fnd_file.put_line(fnd_file.LOG, 'after process_change_handler: org_id' || l_pk3 || 'process_id' || l_pk1 || ' opinion_log_id= ' || l_opinion_log_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
         PROCESS_CHANGE_HANDLER(
  	p_org_id => l_pk3 ,
 	p_process_id => l_pk1 ,
 	p_opinion_log_id => l_opinion_log_id,
 	p_action => 'CERTIFICATION',
 	x_return_status   => l_return_status,
	x_msg_count  => l_msg_count,
	x_msg_data    => l_msg_data);

   UPDATE AMW_FIN_PROCESS_EVAL_SUM SET
   LAST_UPDATE_DATE = sysdate,
   last_updated_by = fnd_global.user_id,
   last_update_login = fnd_global.conc_login_id,
   CERT_OPINION_LOG_ID = l_opinion_log_id,
   CERT_OPINION_ID   = l_opinion_id
   WHERE ORGANIZATION_ID = l_pk3
   AND   PROCESS_ID = l_pk1
   AND   FIN_CERTIFICATION_ID IN (SELECT CERTIFICATION_ID FROM  AMW_CERTIFICATION_B
   				  WHERE CERTIFICATION_STATUS IN ('ACTIVE', 'DRAFT'));

 if(p_commit <> FND_API.g_false)
then commit;
end if;

 fnd_file.put_line(fnd_file.LOG, 'after process_change_handler: org_id' || l_pk3 || 'process_id' || l_pk1 || ' opinion_log_id= ' || l_opinion_log_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

 END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

 EXCEPTION
     WHEN NO_DATA_FOUND THEN
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
       ROLLBACK TO Certification_Update_Handler;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;

END Certification_Update_Handler;


PROCEDURE Evaluation_Update_Handler(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_opinion_log_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
)
IS

 CURSOR Get_Obj_Name (p_opinion_log_id NUMBER)
 IS
 SELECT obj.obj_name , oplog.pk1_value, oplog.pk2_value, oplog.pk3_value,
 	oplog.pk4_value, oplog.pk5_value, oplog.opinion_id
 FROM 	FND_OBJECTS obj,
      	AMW_OBJECT_OPINION_TYPES oot,
      	AMW_OPINIONS_LOG oplog
 WHERE oplog.opinion_log_id = p_opinion_log_id
 	AND   oplog.object_opinion_type_id = oot.object_opinion_type_id
 	AND   oot.object_id = obj.object_id;

 l_opinion_log_id number;
 l_opinion_id number;
 l_object_name varchar2(100);
 l_pk1 number;
 l_pk2 number;
 l_pk3 number;
 l_pk4 number;
 l_pk5 number;

 l_api_name           CONSTANT VARCHAR2(30) := 'Evaluation_Update_Handler';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_index number := 0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

SAVEPOINT Evaluation_Update_Handler;
fnd_file.put_line(fnd_file.LOG, 'start evaluation_update_handler::' || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;
         g_refresh_flag := 'N';

 l_opinion_log_id := p_opinion_log_id;
  open Get_Obj_Name(l_opinion_log_id);
  fetch Get_Obj_Name into l_object_name, l_pk1, l_pk2, l_pk3, l_pk4, l_pk5, l_opinion_id;
  close Get_Obj_Name;

  IF (l_object_name = 'AMW_ORGANIZATION') THEN
  fnd_file.put_line(fnd_file.LOG, 'before organization_change_handler: org_id' || l_pk3 || ' opinion_log_id= ' || l_opinion_log_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
  ORGANIZATION_CHANGE_HANDLER(
  	p_org_id => l_pk3 ,
 	p_opinion_log_id => l_opinion_log_id,
 	p_action => 'EVALUATION',
 	x_return_status   => l_return_status,
	x_msg_count  => l_msg_count,
	x_msg_data    => l_msg_data);

    UPDATE AMW_FIN_ORG_EVAL_SUM
    SET
    LAST_UPDATE_DATE = sysdate,
    last_updated_by = fnd_global.user_id,
    last_update_login = fnd_global.conc_login_id,
    EVAL_OPINION_LOG_ID  = l_opinion_log_id,
    EVAL_OPINION_ID   = l_opinion_id
    WHERE ORGANIZATION_ID = l_pk1
    AND   FIN_CERTIFICATION_ID IN (SELECT CERTIFICATION_ID FROM  AMW_CERTIFICATION_B
   				  WHERE CERTIFICATION_STATUS IN ('ACTIVE', 'DRAFT'));
 if(p_commit <> FND_API.g_false) then
 commit;
end if;

  fnd_file.put_line(fnd_file.LOG, 'after organization_change_handler: org_id' || l_pk3 || ' opinion_log_id= ' || l_opinion_log_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

  ELSIF (l_object_name = 'AMW_ORG_PROCESS') THEN
  fnd_file.put_line(fnd_file.LOG, 'after process_change_handler: org_id' || l_pk3 || 'process_id' || l_pk1 || ' opinion_log_id= ' || l_opinion_log_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
         PROCESS_CHANGE_HANDLER(
  	p_org_id => l_pk3 ,
 	p_process_id => l_pk1 ,
 	p_opinion_log_id => l_opinion_log_id,
 	p_action => 'EVALUATION',
 	x_return_status   => l_return_status,
	x_msg_count  => l_msg_count,
	x_msg_data    => l_msg_data);

   UPDATE AMW_FIN_PROCESS_EVAL_SUM SET
   LAST_UPDATE_DATE = sysdate,
   last_updated_by = fnd_global.user_id,
   last_update_login = fnd_global.conc_login_id,
   EVAL_OPINION_LOG_ID = l_opinion_log_id,
   EVAL_OPINION_ID   = l_opinion_id
   WHERE ORGANIZATION_ID = l_pk3
   AND   PROCESS_ID = l_pk1
   AND   FIN_CERTIFICATION_ID IN (SELECT CERTIFICATION_ID FROM  AMW_CERTIFICATION_B
   				  WHERE CERTIFICATION_STATUS IN ('ACTIVE', 'DRAFT'));

 if(p_commit <> FND_API.g_false)
then commit;
end if;

   fnd_file.put_line(fnd_file.LOG, 'after process_change_handler: org_id' || l_pk3 || 'process_id' || l_pk1 || ' opinion_log_id= ' || l_opinion_log_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

  ELSIF (l_object_name = 'AMW_ORG_PROCESS_RISK') THEN
fnd_file.put_line(fnd_file.LOG, 'before risk_evaluation_handler: org_id=' || l_pk3 || 'risk_id=' || l_pk1 || 'process_id=' || l_pk4 || ' opinion_log_id= ' || l_opinion_log_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
   RISK_EVALUATION_HANDLER
   (p_risk_id => l_pk1,
   p_org_id => l_pk3,
   p_process_id => l_pk4,
   p_opinion_log_id => l_opinion_log_id,
   x_return_status   => l_return_status,
   x_msg_count  => l_msg_count,
   x_msg_data    => l_msg_data);

   UPDATE AMW_RISK_ASSOCIATIONS SET
   LAST_UPDATE_DATE = sysdate,
   last_updated_by = fnd_global.user_id,
   last_update_login = fnd_global.conc_login_id,
   pk4 = l_opinion_log_id
   WHERE OBJECT_TYPE = 'PROCESS_FINCERT'
   AND   risk_id = l_pk1
   AND   pk2= l_pk3
   AND   pk3= l_pk4
   AND   pk1  IN (SELECT CERTIFICATION_ID FROM  AMW_CERTIFICATION_B
   				  WHERE CERTIFICATION_STATUS IN ('ACTIVE', 'DRAFT'));
if(p_commit <> FND_API.g_false)
then commit;
end if;

  fnd_file.put_line(fnd_file.LOG, 'after risk_evaluation_handler: org_id=' || l_pk3 || 'risk_id=' || l_pk1 || 'process_id=' || l_pk4 || ' opinion_log_id= ' || l_opinion_log_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

ELSIF (l_object_name = 'AMW_ORG_CONTROL') THEN
  fnd_file.put_line(fnd_file.LOG, 'before control_evaluation_handler: org_id=' || l_pk3 || 'control_id=' || l_pk1  || ' opinion_log_id= ' || l_opinion_log_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
   CONTROL_EVALUATION_HANDLER
   (p_ctrl_id => l_pk1,
    p_org_id => l_pk3,
    p_opinion_log_id => l_opinion_log_id,
    x_return_status   => l_return_status,
    x_msg_count  => l_msg_count,
    x_msg_data    => l_msg_data);

   UPDATE AMW_CONTROL_ASSOCIATIONS SET
   LAST_UPDATE_DATE = sysdate,
   last_updated_by = fnd_global.user_id,
   last_update_login = fnd_global.conc_login_id,
   pk5 = l_opinion_log_id
   WHERE OBJECT_TYPE = 'RISK_FINCERT'
   AND   control_id = l_pk1
   AND   pk2 = l_pk3
   AND   pk1  IN (SELECT CERTIFICATION_ID FROM  AMW_CERTIFICATION_B
   				  WHERE CERTIFICATION_STATUS IN ('ACTIVE', 'DRAFT'));

if(p_commit <> FND_API.g_false)
then commit;
end if;

  fnd_file.put_line(fnd_file.LOG, 'after control_evaluation_handler: org_id=' || l_pk3 || 'risk_id=' || l_pk1 || 'process_id=' || l_pk4 || ' opinion_log_id= ' || l_opinion_log_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

ELSIF (l_object_name = 'AMW_ORG_AP_CONTROL') THEN
  fnd_file.put_line(fnd_file.LOG, 'before ap_evaluation_handler: org_id=' || l_pk3 || 'control_id=' || l_pk1  || ' opinion_log_id= ' || l_opinion_log_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

   UPDATE AMW_AP_ASSOCIATIONS
   SET 	LAST_UPDATE_DATE = sysdate,
   	last_updated_by = fnd_global.user_id,
   	last_update_login = fnd_global.conc_login_id,
	/**05.02.2006 npanandi: fixing the below bug, since it is actually
	   pk5 that stores the opinionLogId
	pk4 = l_opinion_log_id
	 **/
   	pk5 = l_opinion_log_id
   WHERE OBJECT_TYPE = 'CONTROL_FINCERT'
   	AND   audit_procedure_id = l_pk1
   	AND   pk2 = l_pk3  -- organization_id
   	AND   pk1  IN (SELECT CERTIFICATION_ID FROM  AMW_CERTIFICATION_B
   				  WHERE CERTIFICATION_STATUS IN ('ACTIVE', 'DRAFT'));

if(p_commit <> FND_API.g_false)
then commit;
end if;

  fnd_file.put_line(fnd_file.LOG, 'after ap_evaluation_handler: org_id=' || l_pk3 || 'risk_id=' || l_pk1 || 'process_id=' || l_pk4 || ' opinion_log_id= ' || l_opinion_log_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));


  END IF;

--IF (G_REFRESH_FLAG = 'Y') THEN
--l_index := m_certification_list.FIRST;
--WHILE  l_index <= m_certification_list.LAST LOOP

--AMW_FINSTMT_CERT_BES_PKG.Master_Fin_Proc_Eval_Sum
--   ( p_certification_id => m_certification_list(l_index),
--     p_mode => 'REFRESH',
--     x_return_status    => l_return_status,
--     x_msg_count   => l_msg_count,
--    x_msg_data    => l_msg_data);

--l_index := l_index + 1;

--END LOOP;

--END IF;

if(p_commit <> FND_API.g_false)
then commit;
end if;



  x_return_status := FND_API.G_RET_STS_SUCCESS;

 EXCEPTION
     WHEN NO_DATA_FOUND THEN
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
       ROLLBACK TO Evaluation_Update_Handler;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;

END Evaluation_Update_Handler;



FUNCTION Evaluation_Create
( p_subscription_guid   in     raw,
  p_event               in out NOCOPY wf_event_t
) return VARCHAR2
IS
BEGIN
NULL;
END Evaluation_Create;


FUNCTION Update_Fin_Stmt_Cert_Sum
( p_subscription_guid   in     raw,
  p_event               in out NOCOPY wf_event_t
) return VARCHAR2
IS

l_key                    varchar2(240) := p_event.GetEventKey();
 l_org_id                 NUMBER;
 l_user_id 	            NUMBER;
 l_resp_id 	            NUMBER;
 l_resp_appl_id           NUMBER;
 l_security_group_id      NUMBER;
 l_fin_cert_id NUMBER;

 l_api_name           CONSTANT VARCHAR2(30) := 'Update_Fin_Stmt_Cert_Sum';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

SAVEPOINT Update_Fin_Stmt_Cert_Sum;

fnd_file.put_line(fnd_file.LOG, 'start oracle.apps.amw.certification.update event subcription: Update_Fin_Stmt_Cert_Sum ' || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

  l_org_id := p_event.GetValueForParameter('ORG_ID');
  l_user_id := p_event.GetValueForParameter('USER_ID');
  l_resp_id := p_event.GetValueForParameter('RESP_ID');
  l_resp_appl_id := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_group_id := p_event.GetValueForParameter('SECURITY_GROUP_ID');

  fnd_global.apps_initialize (l_user_id, l_resp_id, l_resp_appl_id, l_security_group_id);

  --l_org_id := p_event.GetValueForParameter('ORG_ID');
   l_fin_cert_id :=  p_event.GetValueForParameter('FIN_CERTIFICATION_ID');

  fnd_file.put_line(fnd_file.LOG, 'fin_certification_id = ' || l_fin_cert_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

   AMW_FINSTMT_CERT_BES_PKG.Master_Fin_Proc_Eval_Sum
   (p_certification_id => l_fin_cert_id,
     p_commit  => FND_API.g_true,
     x_return_status    => l_return_status,
     x_msg_count   => l_msg_count,
    x_msg_data    => l_msg_data);

  fnd_file.put_line(fnd_file.LOG, 'finish updating summary table with certification_id = ' || l_fin_cert_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

RETURN FND_API.G_RET_STS_SUCCESS;

EXCEPTION
 WHEN OTHERS THEN
     WF_CORE.CONTEXT('AMW_FINSTMT_CERT_BES_PKG', 'Update_Fin_Stmt_Cert_Sum', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR' || l_msg_data);
     RETURN FND_API.G_RET_STS_UNEXP_ERROR;

END Update_Fin_Stmt_Cert_Sum;


PROCEDURE Master_Fin_Proc_Eval_Sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  		IN       NUMBER,
p_start_date 	IN DATE := null,
p_mode			IN VARCHAR2 := 'NEW',
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
) IS
l_error_message varchar2(4000);
l_start_time date;
l_end_time date;

l_api_name           CONSTANT VARCHAR2(30) := 'Master_Fin_Proc_Eval_Sum';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);
l_start_date date;

BEGIN

SAVEPOINT Master_Fin_Proc_Eval_Sum;

dbms_mview.refresh('AMW_OPINION_MV', '?');
dbms_mview.refresh('AMW_OPINION_LOG_MV', '?');

 l_start_date := p_start_date;
 IF(p_mode = 'NEW') THEN
  Populate_All_Fin_Proc_Eval_Sum
  (p_certification_id => p_certification_id,
   x_return_status     =>  l_return_status,
   x_msg_count         =>  l_msg_count,
   x_msg_data          =>  l_msg_data);
   fnd_file.put_line(fnd_file.LOG, 'finish populating amw_fin_process_eval_sum table:p_certification_id = ' || p_certification_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
 ELSE
 Refresh_All_Fin_Proc_Eval_Sum
  (p_certification_id => p_certification_id,
   x_return_status     =>  l_return_status,
   x_msg_count         =>  l_msg_count,
   x_msg_data          =>  l_msg_data);
   fnd_file.put_line(fnd_file.LOG, 'finish refreshing Refresh_All_Fin_Proc_Eval_Sum:p_certification_id = ' || p_certification_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
  END IF;

  Populate_Fin_Risk_Ass_Sum
  (p_certification_id => p_certification_id,
   x_return_status     =>  l_return_status,
   x_msg_count         =>  l_msg_count,
   x_msg_data          =>  l_msg_data);
    fnd_file.put_line(fnd_file.LOG, 'finish populating amw_risk_associations table:p_certification_id = ' || p_certification_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
  Populate_Fin_Ctrl_Ass_Sum
  (p_certification_id => p_certification_id,
   x_return_status     =>  l_return_status,
   x_msg_count         =>  l_msg_count,
   x_msg_data          =>  l_msg_data);
   fnd_file.put_line(fnd_file.LOG, 'finish populating amw_control_associations table:p_certification_id = ' || p_certification_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
  Populate_Fin_AP_Ass_Sum
  (p_certification_id => p_certification_id,
   x_return_status     =>  l_return_status,
   x_msg_count         =>  l_msg_count,
   x_msg_data          =>  l_msg_data);
   fnd_file.put_line(fnd_file.LOG, 'finish populating amw_ap_associations table:p_certification_id = ' || p_certification_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
    l_start_time := sysdate;
  INSERT_FIN_CERT_SCOPE
  (p_certification_id => p_certification_id,
   x_return_status     =>  l_return_status,
   x_msg_count         =>  l_msg_count,
   x_msg_data          =>  l_msg_data);
   l_end_time := sysdate;
   fnd_file.put_line(fnd_file.LOG, 'finish populating amw_fin_cert_scope table:p_certification_id = ' || p_certification_id || ' elapsed time is ' || (l_end_time-l_start_time)*24*60*60);

  INSERT_FIN_RISK
  (p_certification_id => p_certification_id,
   x_return_status     =>  l_return_status,
   x_msg_count         =>  l_msg_count,
   x_msg_data          =>  l_msg_data);
  fnd_file.put_line(fnd_file.LOG, 'finish populating amw_fin_item_acc_risks table:p_certification_id = ' || p_certification_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

  INSERT_FIN_CTRL
  (p_certification_id => p_certification_id,
   x_return_status     =>  l_return_status,
   x_msg_count         =>  l_msg_count,
   x_msg_data          =>  l_msg_data);
fnd_file.put_line(fnd_file.LOG, 'finish populating amw_fin_item_acc_ctrls table:p_certification_id = ' || p_certification_id || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

  l_start_time := sysdate;

   Populate_Cert_General_Sum
            (p_certification_id => p_certification_id,
             p_start_date => l_start_date,
             x_return_status    => l_return_status,
     	     x_msg_count   => l_msg_count,
    	     x_msg_data    => l_msg_data);

   l_end_time := sysdate;
fnd_file.put_line(fnd_file.LOG, 'finish populating amw_cert_dashboard_sum  table:p_certification_id = ' || p_certification_id || ' elapsed time is ' || (l_end_time-l_start_time)*24*60*60);
      l_start_time := sysdate;
  Populate_All_Fin_Org_Eval_Sum
   (p_certification_id => p_certification_id,
   x_return_status     =>  l_return_status,
   x_msg_count         =>  l_msg_count,
   x_msg_data          =>  l_msg_data);

    l_end_time := sysdate;
fnd_file.put_line(fnd_file.LOG, 'finish populating amw_fin_org_eval_sum table:p_certification_id = ' || p_certification_id ||  ' elapsed time is ' || (l_end_time-l_start_time)*24*60*60);
      l_start_time := sysdate;

  build_amw_fin_cert_eval_sum
   (p_certification_id => p_certification_id,
   x_return_status     =>  l_return_status,
   x_msg_count         =>  l_msg_count,
   x_msg_data          =>  l_msg_data);

   l_end_time := sysdate;
  fnd_file.put_line(fnd_file.LOG, 'finish populating amw_fin_cert_eval_sum table:p_certification_id = ' || p_certification_id || ' elapsed time is ' || (l_end_time-l_start_time)*24*60*60);

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
       ROLLBACK TO Master_Fin_Proc_Eval_Sum;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;


END Master_Fin_Proc_Eval_Sum;

PROCEDURE Refresh_All_Fin_Proc_Eval_Sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
)
IS

CURSOR c_process IS
SELECT organization_id, process_id, revision_number, process_org_rev_id, account_process_flag
FROM AMW_FIN_PROCESS_EVAL_SUM
WHERE FIN_CERTIFICATION_ID = p_certification_id;

   l_error_message varchar2(4000);

 l_api_name           CONSTANT VARCHAR2(30) := 'Refresh_All_Fin_Proc_Eval_Sum';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);



BEGIN

    SAVEPOINT Refresh_All_Fin_Proc_Eval_Sum;

    -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;


        FOR process_rec IN c_process LOOP
         	exit when c_process%notfound;

          Populate_Fin_Process_Eval_Sum
          ( p_certification_id => p_certification_id,
            p_start_date => null,
            p_end_date =>  null,
            p_process_org_rev_id => process_rec.process_org_rev_id,
            p_process_id => process_rec.process_id,
            p_revision_number	 => process_rec.revision_number,
            p_organization_id => process_rec.organization_id,
            p_account_process_flag => process_rec.account_process_flag,
          x_return_status   => l_return_status,
          x_msg_count  => l_msg_count,
          x_msg_data    => l_msg_data);

        END LOOP;

if(p_commit <> FND_API.g_false)
then commit;
end if;


x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
       ROLLBACK TO Refresh_All_Fin_Proc_Eval_Sum;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;

END Refresh_All_Fin_Proc_Eval_Sum;


PROCEDURE Populate_All_Fin_Proc_Eval_Sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
)
IS

 -- select all the processes based on the certification_id
---this is for later use after we uptake multiple process certifications
/*CURSOR c_process(p_certification_id NUMBER) IS
SELECT 	distinct aa.pk1 organization_id, aa.pk2 process_id, po.revision_number, po.process_org_rev_id
        FROM   	AMW_ACCT_ASSOCIATIONS aa,
               	AMW_FIN_ITEMS_KEY_ACC fika,
	      	AMW_PROCESS_ORGANIZATION po,
		AMW_CERTIFICATION_B cert
        WHERE  	aa.object_type = 'PROCESS_ORG'
	AND     aa.pk1 = po.organization_id
        AND     aa.pk2 = po.process_id
        AND     aa.approval_date is not null
        AND 	aa.approval_date = po.approval_date
   	AND 	aa.deletion_approval_date is null
   	AND	po.approval_end_date is null
   	AND po.revision_number = (select max(revision_number) from amw_process_organization
       where organization_id = aa.pk1 and process_id = aa.pk2 and approval_date = aa.approval_date)
    	AND    	fika.statement_group_id =  cert.statement_group_id
	AND     fika.financial_statement_id = cert.financial_statement_id
	AND     cert.certification_id = p_certification_id
    	AND    	aa.natural_account_id in
		( select  acc.child_natural_account_id
		  from AMW_FIN_KEY_ACCT_FLAT acc
		  where acc.parent_natural_account_id = fika.natural_account_id
		  and acc.account_group_id = fika.account_group_id
		  union all
		  select acc.natural_account_id
		  from amw_fin_key_accounts_b acc
	  	  where acc.natural_account_id = fika.natural_account_id
		  and acc.account_group_id = fika.account_group_id
		); */

-- psomanat : 01/09/2007 : Modified the cursor for performance for bug 5683030
/*CURSOR c_process(p_certification_id NUMBER) IS
SELECT 	distinct aa.pk1 organization_id, aa.pk2 process_id, po.revision_number, po.process_org_rev_id
        FROM   	AMW_ACCT_ASSOCIATIONS aa,
               	AMW_FIN_ITEMS_KEY_ACC fika,
	      	AMW_PROCESS_ORGANIZATION po,
		AMW_CERTIFICATION_B cert
        WHERE  cert.certification_id = p_certification_id
        	AND aa.object_type = 'PROCESS_ORG'
	AND     aa.pk1 = po.organization_id
        AND     aa.pk2 = po.process_id
        AND     aa.approval_date is not null
       -- AND 	aa.approval_date = po.approval_date
   --	AND 	aa.deletion_approval_date is null
   --	AND     po.approval_date = aa.approval_date
    	AND     po.approval_status = 'A'
    	AND	po.approval_end_date is null
    	AND      po.approval_date is not null
		09.12.2006 npanandi: LORAL issue, only include those Processes
	      which are not disassociated from the Organizations, and whose disassociations
		  are not yet approved

		and po.deletion_date is NULL 09.12.2006 npanandi: ends fix for LORAL issue
    	AND    	fika.statement_group_id =  cert.statement_group_id
	AND     fika.financial_statement_id = cert.financial_statement_id
    	 AND EXISTS
     	 ( SELECT CHILD_NATURAL_ACCOUNT_ID
       	 FROM AMW_FIN_KEY_ACCT_FLAT ACC
        	WHERE
         	ACC.CHILD_NATURAL_ACCOUNT_ID = AA.NATURAL_ACCOUNT_ID
         	AND ACC.PARENT_NATURAL_ACCOUNT_ID = FIKA.NATURAL_ACCOUNT_ID
         	AND ACC.ACCOUNT_GROUP_ID = FIKA.ACCOUNT_GROUP_ID
        	UNION ALL
        	SELECT ACC.NATURAL_ACCOUNT_ID
        	FROM AMW_FIN_KEY_ACCOUNTS_B ACC
        	WHERE
        	ACC.NATURAL_ACCOUNT_ID = AA.NATURAL_ACCOUNT_ID
         	AND ACC.NATURAL_ACCOUNT_ID = FIKA.NATURAL_ACCOUNT_ID
         	AND ACC.ACCOUNT_GROUP_ID = FIKA.ACCOUNT_GROUP_ID
      	); */
-- psomanat : 01/09/2007 : Modified the cursor for performance for bug 5683030
CURSOR c_process(p_certification_id NUMBER) IS
SELECT  PO.ORGANIZATION_ID,
        PO.PROCESS_ID,
        PO.REVISION_NUMBER,
        PO.PROCESS_ORG_REV_ID
FROM AMW_PROCESS_ORGANIZATION PO ,amw_audit_units_v aauv
WHERE /*02.13.07 npanandi: bug 5043879 fix for
        including only those orgs that are active */
      po.organization_id = aauv.organization_id
  and
/*02.13.07 npanandi: bug 5043879 fix ends*/
       EXISTS (
    SELECT AA.PK1
    FROM  AMW_ACCT_ASSOCIATIONS AA,
     (  SELECT ACC.CHILD_NATURAL_ACCOUNT_ID NATURAL_ACCOUNT_ID
        FROM AMW_FIN_KEY_ACCT_FLAT ACC,
             AMW_CERTIFICATION_B CERT,
             AMW_FIN_ITEMS_KEY_ACC FIKA
        WHERE CERT.CERTIFICATION_ID = p_certification_id
            AND   FIKA.STATEMENT_GROUP_ID = CERT.STATEMENT_GROUP_ID
            AND   FIKA.FINANCIAL_STATEMENT_ID = CERT.FINANCIAL_STATEMENT_ID
            AND   FIKA.NATURAL_ACCOUNT_ID = ACC.PARENT_NATURAL_ACCOUNT_ID
            AND   FIKA.ACCOUNT_GROUP_ID   = ACC.ACCOUNT_GROUP_ID
        UNION ALL
        SELECT ACC.NATURAL_ACCOUNT_ID
        FROM AMW_FIN_KEY_ACCOUNTS_B ACC,
             AMW_CERTIFICATION_B CERT,
             AMW_FIN_ITEMS_KEY_ACC FIKA
            WHERE CERT.CERTIFICATION_ID = p_certification_id
            AND   FIKA.STATEMENT_GROUP_ID = CERT.STATEMENT_GROUP_ID
            AND   FIKA.FINANCIAL_STATEMENT_ID = CERT.FINANCIAL_STATEMENT_ID
            AND FIKA.ACCOUNT_GROUP_ID = ACC.ACCOUNT_GROUP_ID
            AND FIKA.NATURAL_ACCOUNT_ID = ACC.NATURAL_ACCOUNT_ID
     ) CF
    WHERE AA.NATURAL_ACCOUNT_ID = CF.NATURAL_ACCOUNT_ID
    AND AA.OBJECT_TYPE = 'PROCESS_ORG'
    AND   AA.PK1 = PO.ORGANIZATION_ID
    AND   AA.PK2 = PO.PROCESS_ID
    AND   AA.APPROVAL_DATE IS NOT NULL
)
AND   PO.APPROVAL_STATUS = 'A'
AND   PO.APPROVAL_END_DATE IS NULL
AND   PO.APPROVAL_DATE IS NOT NULL
AND   PO.DELETION_DATE IS NULL;


---for later use when multiple process certification is uptaken
/*CURSOR c_child_processes(p_proc_id NUMBER, p_org_id NUMBER) IS
 SELECT  distinct temp.child_process_id, temp.organization_id, orgproc.revision_number,
         orgproc.process_org_rev_id
        FROM    AMW_FIN_PROCESS_FLAT temp,
        	AMW_PROCESS_ORGANIZATION orgproc
        WHERE   temp.parent_process_id = p_proc_id
        AND     temp.organization_id = p_org_id
        AND 	temp.certification_id = p_certification_id
        AND 	orgproc.process_id = temp.child_process_id
        AND 	orgproc.organization_id = temp.organization_id
        AND 	orgproc.approval_date is not null
        AND	orgproc.approval_end_date is null
        AND     orgproc.revision_number = (select max(revision_number) from AMW_PROCESS_ORGANIZATION orgproc2
        	where orgproc2.process_id = orgproc.process_id
        	and orgproc2.organization_id = orgproc.organization_id);
--------------------------------------------------------*/
/*
CURSOR c_child_processes(p_proc_id NUMBER, p_org_id NUMBER) IS
 SELECT  distinct proc.child_process_id, proc.organization_id
        FROM    AMW_FIN_PROCESS_FLAT proc,
        WHERE   proc.child_process_id <> -2
        AND     proc.parent_process_id = p_proc_id
        AND     proc.organization_id = p_org_id
        AND 	proc.fin_certification_id = p_certification_id;
*/

CURSOR c_child_processes(p_proc_id NUMBER, p_org_id NUMBER) IS
 SELECT  distinct temp.child_process_id, temp.organization_id, orgproc.revision_number,
         orgproc.process_org_rev_id
        FROM    AMW_FIN_PROCESS_FLAT temp,
        	AMW_PROCESS_ORGANIZATION orgproc, amw_audit_units_v aauv
        WHERE   /*02.13.07 npanandi: bug 5043879 fix for
                  including only those orgs that are active */
              orgproc.organization_id = aauv.organization_id
          and
                /*02.13.07 npanandi: bug 5043879 fix ends*/
                temp.child_process_id <> -2
        AND     temp.parent_process_id = p_proc_id
        AND     temp.organization_id = p_org_id
        AND 	temp.fin_certification_id = p_certification_id
        AND 	orgproc.process_id = temp.child_process_id
        AND 	orgproc.organization_id = temp.organization_id
        AND 	orgproc.approval_date is not null
        AND	orgproc.approval_end_date is null
		/**09.12.2006 npanandi: LORAL issue, only include those Processes
	      which are not disassociated from the Organizations, and whose disassociations
		  are not yet approved
		**/
		and orgproc.deletion_date is NULL /*09.12.2006 npanandi: ends fix for LORAL issue**/;


    -- org process certified
    CURSOR org_processes_certified(p_cert_id NUMBER,p_process_id NUMBER) IS
        SELECT  count(distinct aov.pk3_value)
        FROM    AMW_OPINION_MV aov
        WHERE   aov.object_name = 'AMW_ORG_PROCESS'
        AND     aov.opinion_type_code = 'CERTIFICATION'
        AND 	aov.opinion_component_code = 'OVERALL'
        AND     aov.pk3_value <> NVL(fnd_profile.value('AMW_GLOBAL_ORG_ID'),-999)
        AND     aov.pk1_value = p_process_id
	AND     aov.pk3_value in (select distinct evalsum.organization_id
                                from amw_fin_process_eval_sum evalsum
                                where evalsum.fin_certification_id = p_cert_id
				  and evalsum.process_id=p_process_id)
	AND     aov.pk2_value in (select proc_cert_Id from AMW_FIN_PROC_CERT_RELAN
           			where fin_stmt_cert_id = p_cert_id and end_date is null );

    CURSOR total_org_processes(p_cert_id NUMBER,p_process_id NUMBER) IS
        select count(distinct evalsum.organization_id)
        from   amw_fin_process_eval_sum evalsum
        where  evalsum.fin_certification_id = p_cert_id
	and    evalsum.process_id=p_process_id
        and    evalsum.organization_id <>
		NVL(fnd_profile.value('AMW_GLOBAL_ORG_ID'),-999);


    --Begin variant process

    CURSOR var_procs(p_cert_id NUMBER) IS
        SELECT  fin_certification_id,organization_id,process_id
        FROM    AMW_FIN_PROCESS_EVAL_SUM
        WHERE   fin_certification_id = p_cert_id
        AND     organization_id = NVL(fnd_profile.value('AMW_GLOBAL_ORG_ID'),-999);

    CURSOR org_var_processes_certified(p_cert_id NUMBER,p_start_date DATE,p_end_date DATE,p_process_id NUMBER) IS
        select count(1) from
          (SELECT  distinct aov.pk3_value,aov.pk1_value
           FROM    AMW_OPINION_MV aov
           WHERE   aov.object_name = 'AMW_ORG_PROCESS'
           AND     aov.opinion_type_code = 'CERTIFICATION'
           AND 	   aov.opinion_component_code = 'OVERALL'
	   AND     aov.pk2_value in (
			select proc_cert_Id from AMW_FIN_PROC_CERT_RELAN
           		where fin_stmt_cert_id = p_cert_id
           		and end_date is null)
           AND     aov.pk1_value in (SELECT  varproc.process_id
                                     FROM    AMW_PROCESS varproc
                                     WHERE   varproc.standard_variation = p_process_id
                                     AND     varproc.standard_process_flag = 'N'
                                     AND     varproc.process_id in (select distinct evalsum.process_id
                                                                    from amw_fin_process_eval_sum evalsum
                                                                    where evalsum.fin_certification_id = p_cert_id)));


    CURSOR total_org_var_processes(p_cert_id NUMBER,p_process_id NUMBER) IS
        select count(1) from
          (select distinct evalsum.organization_id,evalsum.process_id
           from amw_fin_process_eval_sum evalsum
           where evalsum.fin_certification_id = p_cert_id
           and   evalsum.process_id in (select varproc.process_id
                                        FROM    AMW_PROCESS varproc
                                        WHERE   varproc.standard_variation = p_process_id
                                        AND     varproc.standard_process_flag = 'N'));

    -- end variant process

    --l_start_date DATE;
    --l_end_date   DATE;
    l_org_var_processes_certified NUMBER;
    l_org_processes_certified NUMBER;
    l_total_org_var_processes     NUMBER;
    l_total_org_processes     NUMBER;

    l_error_message varchar2(4000);

 l_api_name           CONSTANT VARCHAR2(30) := 'Populate_All_Fin_Proc_Eval_Sum';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

    SAVEPOINT Populate_All_Fin_Proc_Eval_Sum;

    -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;


 FOR process_rec IN c_process(p_certification_id) LOOP
         	exit when c_process%notfound;
          POPULATE_PROC_HIERARCHY
          (     p_certification_id => p_certification_id,
                P_PROCESS_ID => process_rec.process_id,
                P_ORGANIZATION_ID => process_rec.organization_id,
                p_account_process_flag => 'Y',
         	x_return_status   => l_return_status,
		x_msg_count  => l_msg_count,
		x_msg_data    => l_msg_data);

          Populate_Fin_Process_Eval_Sum
          ( p_certification_id => p_certification_id,
            p_start_date => null,
            p_end_date =>  null,
            p_process_org_rev_id => process_rec.process_org_rev_id,
            p_process_id => process_rec.process_id,
            p_revision_number	 => process_rec.revision_number,
            p_organization_id => process_rec.organization_id,
            p_account_process_flag => 'Y',
          x_return_status   => l_return_status,
          x_msg_count  => l_msg_count,
          x_msg_data    => l_msg_data);

          --Populate data for child processes
	  FOR child_rec IN c_child_processes(process_rec.process_id,process_rec.organization_id) LOOP
	    	exit when c_child_processes%notfound;

	    POPULATE_PROC_HIERARCHY
	     (     p_certification_id => p_certification_id,
                P_PROCESS_ID => child_rec.child_process_id,
                P_ORGANIZATION_ID => child_rec.organization_id,
                p_account_process_flag => 'Y',
         	x_return_status   => l_return_status,
	x_msg_count  => l_msg_count,
	x_msg_data    => l_msg_data);

            Populate_Fin_Process_Eval_Sum
            ( p_certification_id => p_certification_id,
            p_start_date => null,
            p_end_date =>  null,
            p_process_org_rev_id => child_rec.process_org_rev_id,
            p_process_id => child_rec.child_process_id,
            p_revision_number	 => child_rec.revision_number,
            p_organization_id => child_rec.organization_id,
            p_account_process_flag => 'N',
          x_return_status   => l_return_status,
          x_msg_count  => l_msg_count,
          x_msg_data    => l_msg_data);

          END LOOP;
        END LOOP;


        -- Handle varient processes
        FOR var_rec IN var_procs(p_certification_id) LOOP
               exit when var_procs%notfound;

          OPEN org_var_processes_certified(var_rec.fin_certification_id,null,null,var_rec.process_id);
          FETCH org_var_processes_certified INTO l_org_var_processes_certified;
          CLOSE org_var_processes_certified;

          OPEN org_processes_certified(var_rec.fin_certification_id,var_rec.process_id);
          FETCH org_processes_certified INTO l_org_processes_certified;
          CLOSE org_processes_certified;

          l_org_processes_certified := l_org_processes_certified+
					l_org_var_processes_certified;

          OPEN total_org_var_processes(var_rec.fin_certification_id,var_rec.process_id);
          FETCH total_org_var_processes INTO l_total_org_var_processes;
          CLOSE total_org_var_processes;

          OPEN total_org_processes(var_rec.fin_certification_id,var_rec.process_id);
          FETCH total_org_processes INTO l_total_org_processes;
          CLOSE total_org_processes;

          l_total_org_processes := l_total_org_processes+
				    l_total_org_var_processes;

          UPDATE AMW_FIN_PROCESS_EVAL_SUM
          SET  LAST_UPDATE_DATE = sysdate,
   		last_updated_by = fnd_global.user_id,
   		last_update_login = fnd_global.conc_login_id,
             TOTAL_NUMBER_OF_ORG_PROCS = l_total_org_processes,
              NUMBER_OF_ORG_PROCS_CERTIFIED = l_org_processes_certified,
              ORG_PROCS_CERTIFIED_PRCNT =
	     round(((l_org_processes_certified/decode(l_total_org_processes,0,1,l_total_org_processes)) *100),0)
          WHERE FIN_CERTIFICATION_ID = var_rec.fin_certification_id
          AND   ORGANIZATION_ID = var_rec.organization_id
          AND   PROCESS_ID = var_rec.process_id;

        END LOOP;
if(p_commit <> FND_API.g_false)
then commit;
end if;



 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
       ROLLBACK TO Populate_All_Fin_Proc_Eval_Sum;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;


END Populate_All_Fin_Proc_Eval_Sum;


PROCEDURE  Populate_Fin_Process_Eval_Sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id          IN      NUMBER,
p_start_date                IN      DATE,
p_end_date                  IN      DATE,
p_process_org_rev_id	IN   	NUMBER,
p_process_id   		IN	NUMBER,
p_revision_number		IN	NUMBER,
p_organization_id		IN 	NUMBER,
p_account_process_flag      IN      VARCHAR2,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
)
IS


     CURSOR sub_processes_certified IS
    	SELECT  count(distinct aov.pk1_value)
      	FROM  	AMW_OPINION_MV aov
        WHERE 	aov.object_name = 'AMW_ORG_PROCESS'
        AND 	aov.opinion_type_code = 'CERTIFICATION'
        AND 	aov.opinion_component_code = 'OVERALL'
        AND 	aov.pk3_value = p_organization_id
	AND     aov.pk2_value in (select proc_cert_Id from AMW_FIN_PROC_CERT_RELAN
           			where fin_stmt_cert_id = p_certification_id
           			and end_date is null)
        AND     aov.pk1_value in (select distinct(orgrel.child_process_id)
                                  from AMW_FIN_PROCESS_FLAT orgrel
                                  where orgrel.parent_process_id = p_process_id
                                  and orgrel.organization_id = p_organization_id
                                  and orgrel.fin_certification_id = p_certification_id
                                  );

    CURSOR total_sub_processes IS
        SELECT  count(distinct child_process_id)
        FROM    AMW_FIN_PROCESS_FLAT
    	WHERE   parent_process_id = p_process_id
        AND     organization_id = p_organization_id
        AND 	child_process_id <> -2
        AND   fin_certification_id = p_certification_id;


    CURSOR certification_result IS
        SELECT 	aov.opinion_id
        FROM 	AMW_OPINION_MV aov
        WHERE 	aov.object_name = 'AMW_ORG_PROCESS'
        AND 	aov.opinion_type_code = 'CERTIFICATION'
        AND 	aov.opinion_component_code = 'OVERALL'
        AND 	aov.pk3_value = p_organization_id
	AND     aov.pk2_value in (select proc_cert_Id from AMW_FIN_PROC_CERT_RELAN
           			where fin_stmt_cert_id = p_certification_id
           			and end_date is null)
        AND 	aov.pk1_value = p_process_id
        AND 	aov.authored_date = (select max(aov2.authored_date)
                                     from AMW_OPINIONS aov2
                                     where aov2.object_opinion_type_id = aov.object_opinion_type_id
                                     and aov2.pk3_value = aov.pk3_value
                                     and aov2.pk1_value = aov.pk1_value
				     and aov2.pk2_value in
				       (select proc_cert_Id from AMW_FIN_PROC_CERT_RELAN
           			        where fin_stmt_cert_id = p_certification_id
           			        and end_date is null));



    CURSOR certification_result_history(p_opinion_id number) IS
        SELECT 	max(opinion_log_id)
        FROM 	AMW_OPINIONS_LOG
        WHERE 	opinion_id = p_opinion_id;


    CURSOR last_evaluation IS
        SELECT 	distinct aov.opinion_id
	FROM 	AMW_OPINION_MV aov
       	WHERE 	aov.object_name = 'AMW_ORG_PROCESS'
        AND 	aov.opinion_type_code = 'EVALUATION'
        AND 	aov.opinion_component_code = 'OVERALL'
        AND 	aov.pk3_value = p_organization_id
        AND 	aov.pk1_value = p_process_id
        --fix bug 5724066
	AND     aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = 'CANC')
        AND 	aov.authored_date = (select max(aov2.authored_date)
                       	             from AMW_OPINIONS aov2
                               	     where aov2.object_opinion_type_id = aov.object_opinion_type_id
                                     and aov2.pk3_value = aov.pk3_value
                                     and aov2.pk1_value = aov.pk1_value);

     CURSOR last_evaluation_history(p_opinion_id number) IS
     select max(opinion_log_id)
     from amw_opinions_log
     where opinion_id = p_opinion_id;


CURSOR unmitigated_risks IS
SELECT 	count(1)
       	FROM
       		AMW_RISK_ASSOCIATIONS ara,
            		AMW_FIN_PROCESS_FLAT orgrel,
           		 AMW_OPINION_MV aov
        WHERE   ara.object_type = 'PROCESS_ORG'
        AND      ara.pk1 = p_organization_id
        AND     orgrel.fin_certification_id = p_certification_id
        AND     ara.pk1 = orgrel.organization_id
        AND     ((ara.pk2 = p_process_id and orgrel.parent_process_id = ara.pk2 and orgrel.child_process_id = -2)
        	or (ara.pk2 = orgrel.child_process_id and orgrel.parent_process_id = p_process_id))
        AND 	ara.approval_date is not null
        AND 	ara.deletion_approval_date is null
        AND 	aov.object_name = 'AMW_ORG_PROCESS_RISK'
        AND 	aov.opinion_type_code = 'EVALUATION'
        AND 	aov.opinion_component_code = 'OVERALL'
        AND 	aov.pk3_value = ara.pk1
        AND 	aov.pk4_value = ara.pk2
        AND 	aov.pk1_value = ara.risk_id
        --fix bug 5724066
	AND     aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = 'CANC')
        AND 	aov.authored_date = (select max(aov2.authored_date)
                                     from AMW_OPINIONS  aov2
                                     where aov2.object_opinion_type_id = aov.object_opinion_type_id
                                     and aov2.pk4_value = aov.pk4_value
                                     and aov2.pk3_value = aov.pk3_value
                                     and aov2.pk1_value = aov.pk1_value)
      	AND 	aov.OPINION_VALUE_CODE <> 'EFFECTIVE';



  CURSOR total_risks IS
  SELECT count(1)
       	FROM
       		AMW_RISK_ASSOCIATIONS ara,
            AMW_FIN_PROCESS_FLAT orgrel
        WHERE   ara.object_type = 'PROCESS_ORG'
        AND 	ara.pk1 = p_organization_id
        and     orgrel.fin_certification_id = p_certification_id
        and     orgrel.organization_id = ara.pk1
        AND     ((ara.pk2 = p_process_id and orgrel.parent_process_id = ara.pk2 and orgrel.child_process_id = -2)
            or (ara.pk2 = orgrel.child_process_id and orgrel.parent_process_id = p_process_id))
        AND 	ara.approval_date is not null
        AND 	ara.deletion_approval_date is null;


 --why distinct? because the same risk could be evaluated in different projects. so in opinion_mv has several records corresponding to
 -- one risk.
 CURSOR risks_verified IS
  SELECT 	count(1)
 from (select distinct ara.pk1, ara.pk2, ara.risk_id
       	FROM
       		AMW_RISK_ASSOCIATIONS ara,
                	AMW_OPINION_MV aov,
                	AMW_FIN_PROCESS_FLAT orgrel
        WHERE   ara.object_type = 'PROCESS_ORG'
        AND 	ara.pk1 = p_organization_id
        AND     orgrel.fin_certification_id = p_certification_id
        and     orgrel.organization_id = ara.pk1
        AND     ( (ara.pk2 = p_process_id and ara.pk2 = orgrel.parent_process_id and orgrel.child_process_id = -2)
        	or (ara.pk2 = orgrel.child_process_id and orgrel.parent_process_id = p_process_id))
        AND 	ara.approval_date is not null
        AND 	ara.deletion_approval_date is null
        AND 	aov.object_name = 'AMW_ORG_PROCESS_RISK'
        AND 	aov.opinion_type_code = 'EVALUATION'
        AND 	aov.opinion_component_code = 'OVERALL'
        AND 	aov.pk3_value = ara.pk1
        AND 	aov.pk4_value = ara.pk2
        AND 	aov.pk1_value = ara.risk_id
        --fix bug 5724066
	AND     aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = 'CANC')
        );


 CURSOR ineffective_controls IS
  SELECT 	count(distinct aca.control_id)
        FROM
		AMW_CONTROL_ASSOCIATIONS aca,
        AMW_FIN_PROCESS_FLAT orgrel,
        AMW_OPINION_MV aov
        WHERE
        aca.object_type = 'RISK_ORG'
        and aca.pk1   = p_organization_id
        and orgrel.fin_certification_id = p_certification_id
        and aca.pk1 = orgrel.organization_id
        and     aca.approval_date is not null
        and     aca.deletion_approval_date is null
        and     ( (aca.pk2 = p_process_id  and aca.pk2 = orgrel.parent_process_id and orgrel.child_process_id = -2)
                or ( aca.pk2 = orgrel.child_process_id and orgrel.parent_process_id = p_process_id))
        AND 	aov.object_name = 'AMW_ORG_CONTROL'
        AND 	aov.opinion_type_code = 'EVALUATION'
        AND 	aov.opinion_component_code = 'OVERALL'
        AND 	aov.pk3_value = aca.pk1
        AND 	aov.pk1_value = aca.control_id
        --fix bug 5724066
	AND     aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = 'CANC')
        AND 	aov.authored_date = (select max(aov2.authored_date)
                                     from AMW_OPINIONS  aov2
                                    where aov2.object_opinion_type_id = aov.object_opinion_type_id
                                     and aov2.pk3_value = aov.pk3_value
                                     and aov2.pk1_value = aov.pk1_value)
        AND 	aov.OPINION_VALUE_CODE <> 'EFFECTIVE';



 CURSOR total_controls IS
 SELECT 	count(distinct aca.control_id)
        FROM
		AMW_CONTROL_ASSOCIATIONS aca,
        		AMW_FIN_PROCESS_FLAT orgrel
        WHERE   aca.object_type = 'RISK_ORG'
        and     aca.pk1 = p_organization_id
        and     orgrel.fin_certification_id = p_certification_id
        and     aca.pk1 = orgrel.organization_id
        and     aca.approval_date is not null
        and     aca.deletion_approval_date is null
        and     (( aca.pk2 = p_process_id and  orgrel.parent_process_id = aca.pk2 and orgrel.child_process_id = -2)
                or (aca.pk2 = orgrel.child_process_id and orgrel.parent_process_id = p_process_id));


CURSOR verified_controls IS
SELECT 	count(distinct aca.control_id)
        FROM
		AMW_CONTROL_ASSOCIATIONS aca,
        		AMW_FIN_PROCESS_FLAT orgrel,
       		AMW_OPINION_MV aov
        WHERE
        aca.object_type = 'RISK_ORG'
        and aca.pk1   = p_organization_id
        and orgrel.fin_certification_id = p_certification_id
        and orgrel.organization_id = aca.pk1
        and     aca.approval_date is not null
        and     aca.deletion_approval_date is null
        and     (( aca.pk2 = p_process_id  and aca.pk2 =  orgrel.parent_process_id and orgrel.child_process_id = -2)
            or (aca.pk2 = orgrel.child_process_id and orgrel.parent_process_id = p_process_id))
        AND 	aov.object_name = 'AMW_ORG_CONTROL'
        AND 	aov.opinion_type_code = 'EVALUATION'
        AND 	aov.opinion_component_code = 'OVERALL'
        AND 	aov.pk3_value = aca.pk1
        AND 	aov.pk1_value = aca.control_id
        --fix bug 5724066
	AND     aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = 'CANC')
        ;


   l_sub_processes_certified		NUMBER;
   l_total_sub_processes		NUMBER;
   l_org_processes_certified		NUMBER;
   l_total_org_processes		NUMBER;
   l_cert_opinion_id			NUMBER;
   l_eval_opinion_id			NUMBER;
   l_last_evaluation			NUMBER;
   l_unmitigated_risks			NUMBER;
   l_total_risks			NUMBER;
   l_verified_risks			NUMBER;
   l_ineffective_controls		NUMBER;
   l_total_controls			NUMBER;
   l_verified_controls			NUMBER;
   l_open_findings                      NUMBER;
   l_count				NUMBER;
   l_cert_opinion_log_id		NUMBER;
   l_eval_opinion_log_id		NUMBER;

    l_certification_id                  NUMBER;
    l_process_id   		 	NUMBER;
    l_organization_id		 	NUMBER;

    l_error_message varchar2(4000);

l_api_name           CONSTANT VARCHAR2(30) := 'Populate_Fin_Process_Eval_Sum';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

l_new NUMBER;

BEGIN

SAVEPOINT Populate_Fin_Process_Eval_Sum;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;


         SELECT count(1) into l_count
     FROM AMW_FIN_PROCESS_EVAL_SUM sum
     WHERE sum.fin_certification_id = p_certification_id
     AND   sum.organization_id = p_organization_id
     AND   sum.process_id = p_process_id
     AND EXISTS ( SELECT 'Y' FROM AMW_FIN_CERT_SCOPE scp
     		  WHERE scp.fin_certification_id = sum.fin_certification_id
     		  and scp.organization_id = sum.organization_id
     		  and scp.process_id = sum.process_id
     		  and scp.process_id is not null);


     SELECT COUNT(1) INTO l_new FROM AMW_FIN_CERT_SCOPE
        WHERE FIN_CERTIFICATION_ID = p_certification_id;

     	IF( l_count = 0 and l_new <> 0 ) THEN RETURN;
     	END IF;

	 l_certification_id   := p_certification_id;
    	 l_process_id   := p_process_id;
    	 l_organization_id := 	p_organization_id;

    	 l_total_org_processes := 0;
    	 l_org_processes_certified := 0;


    OPEN sub_processes_certified;
    FETCH sub_processes_certified INTO l_sub_processes_certified;
    CLOSE sub_processes_certified;

    OPEN total_sub_processes;
    FETCH total_sub_processes INTO l_total_sub_processes;
    CLOSE total_sub_processes;


    OPEN certification_result;
    FETCH certification_result INTO l_cert_opinion_id;
    CLOSE certification_result;

    OPEN last_evaluation;
    FETCH last_evaluation INTO l_eval_opinion_id;
    CLOSE last_evaluation;

    OPEN unmitigated_risks;
    FETCH unmitigated_risks INTO l_unmitigated_risks;
    CLOSE unmitigated_risks;

 OPEN total_risks;
 FETCH total_risks INTO l_total_risks;
 CLOSE total_risks;

 OPEN risks_verified;
 FETCH risks_verified INTO l_verified_risks;
 CLOSE risks_verified;

    OPEN ineffective_controls;
    FETCH ineffective_controls INTO l_ineffective_controls;
    CLOSE ineffective_controls;

    OPEN total_controls;
 FETCH total_controls INTO l_total_controls;
 CLOSE total_controls;

 OPEN verified_controls;
 FETCH verified_controls INTO l_verified_controls;
 CLOSE verified_controls;

    OPEN certification_result_history(l_cert_opinion_id);
    FETCH certification_result_history INTO l_cert_opinion_log_id;
    CLOSE certification_result_history;

    OPEN last_evaluation_history(l_eval_opinion_id);
    FETCH last_evaluation_history INTO l_eval_opinion_log_id;
    CLOSE last_evaluation_history;


    BEGIN
        l_open_findings := amw_findings_pkg.calculate_open_findings (
               'AMW_PROJ_FINDING',
               'PROJ_ORG_PROC', p_process_id,
               'PROJ_ORG', p_organization_id,
               null, null,
               null, null,
               null, null );
    EXCEPTION
        WHEN OTHERS THEN
            null;
    END;



   --first time to insert the process records for this certification
    IF (l_new = 0 and l_count = 0) THEN

       INSERT INTO AMW_FIN_PROCESS_EVAL_SUM(
         FIN_CERTIFICATION_ID,
         PROCESS_ID,
         ORGANIZATION_ID,
         CERT_OPINION_ID,
         EVAL_OPINION_ID,
         UNMITIGATED_RISKS,
         RISKS_VERIFIED,
         TOTAL_NUMBER_OF_RISKS,
         INEFFECTIVE_CONTROLS,
         CONTROLS_VERIFIED,
         TOTAL_NUMBER_OF_CTRLS,
         UNMITIGATED_RISKS_PRCNT,
         INEFFECTIVE_CONTROLS_PRCNT,
         TOTAL_NUMBER_OF_SUB_PROCS,
         NUMBER_OF_SUB_PROCS_CERTIFIED,
         SUB_PROCS_CERTIFIED_PRCNT,
         TOTAL_NUMBER_OF_ORG_PROCS,
         NUMBER_OF_ORG_PROCS_CERTIFIED,
         ORG_PROCS_CERTIFIED_PRCNT,
         OPEN_FINDINGS,
         ACCOUNT_PROCESS_FLAG,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         CERT_OPINION_LOG_ID,
         EVAL_OPINION_LOG_ID,
         REVISION_NUMBER,
         PROCESS_ORG_REV_ID)
        VALUES
        (     p_certification_id,
              p_process_id,
              p_organization_id,
              l_cert_opinion_id,
              l_eval_opinion_id,
              l_unmitigated_risks,
              l_verified_risks,
              l_total_risks,
              l_ineffective_controls,
              l_verified_controls,
              l_total_controls,
              round((nvl(l_unmitigated_risks, 0)/decode(nvl(l_total_risks,0),0,1,l_total_risks) *100),0),
              round((nvl(l_ineffective_controls, 0)/decode(nvl(l_total_controls,0),0,1,l_total_controls) *100),0),
              l_total_sub_processes,
              l_sub_processes_certified,
              round((nvl(l_sub_processes_certified, 0)/decode(nvl(l_total_sub_processes,0),0,1,l_total_sub_processes) *100),0),
              l_total_org_processes,
              l_org_processes_certified,
              round((nvl(l_org_processes_certified, 0)/decode(nvl(l_total_org_processes,0),0,1,l_total_org_processes) *100),0),
              l_open_findings,
              p_account_process_flag,
              FND_GLOBAL.USER_ID,
              SYSDATE,
              SYSDATE,
              FND_GLOBAL.USER_ID,
              FND_GLOBAL.USER_ID,
              l_cert_opinion_log_id,
              l_eval_opinion_log_id,
              p_revision_number,
              p_process_org_rev_id);

    ELSE

       UPDATE AMW_FIN_PROCESS_EVAL_SUM
       SET
         CERT_OPINION_ID = l_cert_opinion_id,
         EVAL_OPINION_ID = l_eval_opinion_id,
         UNMITIGATED_RISKS =  l_unmitigated_risks,
         RISKS_VERIFIED = l_verified_risks,
         TOTAL_NUMBER_OF_RISKS = l_total_risks,
         INEFFECTIVE_CONTROLS = l_ineffective_controls,
         CONTROLS_VERIFIED = l_verified_controls,
         TOTAL_NUMBER_OF_CTRLS = l_total_controls,
         UNMITIGATED_RISKS_PRCNT =  round((nvl(l_unmitigated_risks, 0)/decode(nvl(l_total_risks,0),0,1,l_total_risks) *100),0),
         INEFFECTIVE_CONTROLS_PRCNT =  round((nvl(l_ineffective_controls, 0)/decode(nvl(l_total_controls,0),0,1,l_total_controls) *100),0),
         TOTAL_NUMBER_OF_SUB_PROCS =  l_total_sub_processes,
         NUMBER_OF_SUB_PROCS_CERTIFIED =  l_sub_processes_certified,
         SUB_PROCS_CERTIFIED_PRCNT =  round((nvl(l_sub_processes_certified,0)/decode(nvl(l_total_sub_processes,0),0,1,l_total_sub_processes) *100),0),
         TOTAL_NUMBER_OF_ORG_PROCS = l_total_org_processes,
         NUMBER_OF_ORG_PROCS_CERTIFIED = l_org_processes_certified,
         ORG_PROCS_CERTIFIED_PRCNT = round((nvl(l_org_processes_certified, 0)/decode(nvl(l_total_org_processes,0),0,1,l_total_org_processes) *100),0),
         OPEN_FINDINGS =  l_open_findings,
         CREATED_BY = FND_GLOBAL.USER_ID,
         CREATION_DATE = SYSDATE,
         LAST_UPDATE_DATE = SYSDATE,
         LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
         LAST_UPDATE_LOGIN  = fnd_global.conc_login_id,
         CERT_OPINION_LOG_ID = l_cert_opinion_log_id,
         EVAL_OPINION_LOG_ID =  l_eval_opinion_log_id
       WHERE FIN_CERTIFICATION_ID = p_certification_id
       AND 	PROCESS_ID = p_process_id
       AND 	ORGANIZATION_ID = p_organization_id
       AND      PROCESS_ORG_REV_ID = p_process_org_rev_id;

    END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
       ROLLBACK TO Populate_Fin_Process_Eval_Sum;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;


END Populate_Fin_Process_Eval_Sum;

/********************delete becuase put ceritification loop in master_... procedure *****************
PROCEDURE Populate_All_Fin_Risk_Ass_Sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
) IS

l_api_name           CONSTANT VARCHAR2(30) := 'Populate_All_Fin_Risk_Ass_Sum';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

SAVEPOINT Populate_All_Fin_Risk_Ass_Sum;

Populate_Fin_Risk_Ass_Sum
(p_certification_id => p_certification_id,
x_return_status   => l_return_status,
x_msg_count  => l_msg_count,
x_msg_data    => l_msg_data);


 x_return_status := FND_API.G_RET_STS_SUCCESS;

 EXCEPTION
     WHEN NO_DATA_FOUND THEN
     IF c_cert%ISOPEN THEN
      	close c_cert;
      END IF;
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
      IF c_cert%ISOPEN THEN
      	close c_cert;
      END IF;
       ROLLBACK TO Populate_All_Fin_Risk_Ass_Sum;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;

END Populate_All_Fin_Risk_Ass_Sum;

*********************************************/


-------------populate risk association which related to financial certification ----
PROCEDURE Populate_Fin_Risk_Ass_Sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
) IS

CURSOR c_finrisks IS
SELECT
	risks.risk_id,
	risks.PK1,
	risks.PK2,
	risks.ASSOCIATION_CREATION_DATE,
	risks.APPROVAL_DATE,
	risks.DELETION_DATE,
	risks.DELETION_APPROVAL_DATE,
	risk.RISK_REV_ID
FROM
	AMW_RISK_ASSOCIATIONS risks,
	AMW_FIN_PROCESS_EVAL_SUM eval,
	AMW_RISKS_B risk
WHERE
	eval.fin_certification_id = p_certification_id
	and risk.risk_id = risks.risk_id
	and risk.CURR_APPROVED_FLAG = 'Y'
	and risks.object_type='PROCESS_ORG'
	and risks.PK1 = eval.organization_id
	and risks.PK2 = eval.process_id
	and risks.approval_date is not null
	and risks.approval_date <= sysdate
	and risks.deletion_approval_date is null
UNION ALL
SELECT
	risks.risk_id,
	risks.PK1,
	risks.PK2,
	risks.ASSOCIATION_CREATION_DATE,
	risks.APPROVAL_DATE,
	risks.DELETION_DATE,
	risks.DELETION_APPROVAL_DATE,
	risk.RISK_REV_ID
FROM
	AMW_RISK_ASSOCIATIONS risks,
	AMW_FIN_PROCESS_EVAL_SUM eval,
	AMW_RISKS_B risk
WHERE
	eval.fin_certification_id = p_certification_id
	and risk.risk_id = risks.risk_id
	and risk.CURR_APPROVED_FLAG = 'Y'
	and risks.object_type='ENTITY_RISK'
	and risks.PK1 = eval.organization_id
	and risks.approval_date is not null
	and risks.approval_date <= sysdate
	and risks.deletion_approval_date is null;

	--in risk association table, if type = 'PROCESS_FINCERT', pk1=certification_id, pk2=organization_id, pk3=process_id, pk4=opinion_log_id
	CURSOR last_evaluation(l_risk_id number, l_organization_id number, l_process_id number)  IS
        SELECT 	distinct aov.opinion_log_id
	FROM 	AMW_OPINION_LOG_MV aov
       	WHERE 	aov.object_name = 'AMW_ORG_PROCESS_RISK'
        AND 	aov.opinion_type_code = 'EVALUATION'
        AND 	aov.pk3_value = l_organization_id
        AND 	aov.pk4_value = l_process_id
        AND	aov.pk1_value = l_risk_id
        --fix bug 5724066
        AND aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = 'CANC')
	AND 	aov.authored_date = (select max(aov2.authored_date)
                       	             from AMW_OPINIONS aov2
                               	     where aov2.object_opinion_type_id = aov.object_opinion_type_id
                                     and aov2.pk3_value = aov.pk3_value
                                     and aov2.pk1_value = aov.pk1_value
                                     and aov2.pk4_value = aov.pk4_value);



l_count NUMBER;
m_opinion_log_id NUMBER;
l_error_message varchar2(4000);


l_api_name           CONSTANT VARCHAR2(30) := 'Populate_Fin_Risk_Ass_Sum';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

	SAVEPOINT Populate_Fin_Risk_Ass_Sum;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;


	SELECT COUNT(1) INTO l_count FROM AMW_RISK_ASSOCIATIONS
	WHERE object_type = 'PROCESS_FINCERT'
	AND pk1 = p_certification_id;

	IF (l_count = 0) THEN
	FOR risk_rec IN c_finrisks LOOP
	exit when c_finrisks%notfound;

		m_opinion_log_id := null;
		OPEN last_evaluation(risk_rec.risk_id, risk_rec.pk1, risk_rec.pk2);
		FETCH last_evaluation INTO m_opinion_log_id;
		CLOSE last_evaluation;



		INSERT INTO AMW_RISK_ASSOCIATIONS(
 			       RISK_ASSOCIATION_ID,
			       RISK_ID,
			       PK1,
			       PK2,
			       PK3,
			       PK4,
			       CREATED_BY,
			       CREATION_DATE,
			       LAST_UPDATE_DATE,
			       LAST_UPDATED_BY,
			       LAST_UPDATE_LOGIN,
			       OBJECT_VERSION_NUMBER,
			       OBJECT_TYPE,
			       ASSOCIATION_CREATION_DATE,
			       APPROVAL_DATE,
			       DELETION_DATE,
			       DELETION_APPROVAL_DATE,
			       RISK_REV_ID)
			 VALUES ( amw_risk_associations_s.nextval,
			         risk_rec.risk_id,
			         p_certification_id,
			         risk_rec.PK1,
			         risk_rec.PK2,
			         m_opinion_log_id,
			         FND_GLOBAL.USER_ID,
			       	 SYSDATE,
			         SYSDATE,
			         FND_GLOBAL.USER_ID,
			         FND_GLOBAL.USER_ID,
			         1,
			         'PROCESS_FINCERT',
			         risk_rec.ASSOCIATION_CREATION_DATE,
			         risk_rec.APPROVAL_DATE,
				 risk_rec.DELETION_DATE,
				 risk_rec.DELETION_APPROVAL_DATE,
				 risk_rec.RISK_REV_ID);

		END LOOP;

	   if(p_commit <> FND_API.g_false)
           then commit;
       end if;
    /**05.02.2006 npanandi: bug 5201579 fix --- need to have an update DML here**/
	else /**this means that l_count is not zero, so update**/
	   FOR risk_rec IN c_finrisks LOOP
	   exit when c_finrisks%notfound;

	      m_opinion_log_id := null;
		  OPEN last_evaluation(risk_rec.risk_id, risk_rec.pk1, risk_rec.pk2);
		  FETCH last_evaluation INTO m_opinion_log_id;
		  CLOSE last_evaluation;

		  update AMW_RISK_ASSOCIATIONS /**need only to update the opinionLogId here**/
 		     set PK4 = m_opinion_log_id,
			     LAST_UPDATE_DATE = sysdate,
			     LAST_UPDATED_BY = fnd_global.USER_ID,
			     LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID,
			     OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1
		   where object_type = 'PROCESS_FINCERT'
		     and risk_id = risk_rec.risk_id
			 and PK2 = risk_rec.PK1
			 and PK3 = risk_rec.PK2
			 and pk1 in (select certification_id from amw_certification_b
			              where certification_status in ('ACTIVE','DRAFT'));
		END LOOP;
	    if(p_commit <> FND_API.g_false)
           then commit;
        end if;
	/**05.02.2006 npanandi: bug 5201579 fix ends here**/
	    	END IF;
x_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION
     WHEN NO_DATA_FOUND THEN
     IF c_finrisks%ISOPEN THEN
      	close c_finrisks;
         END IF;
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
      IF c_finrisks%ISOPEN THEN
      	close c_finrisks;
         END IF;
       ROLLBACK TO Populate_Fin_Risk_Ass_Sum;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;

END Populate_Fin_Risk_Ass_Sum;

-------------populate all of financial certification which has one or more control associations
/****************loop in master procedure *******************
PROCEDURE Populate_All_Fin_Ctrl_Ass_Sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
)IS
 CURSOR c_cert IS
        SELECT 	cert.certification_id, period.start_date,period.end_date
        FROM 	AMW_CERTIFICATION_B cert,
		AMW_GL_PERIODS_V period
        WHERE 	cert.certification_period_name = period.period_name
        AND 	cert.certification_period_set_name = period.period_set_name
        AND     cert.object_type='FIN_STMT'
        AND     cert.certification_status in ('ACTIVE','DRAFT');

l_api_name           CONSTANT VARCHAR2(30) := 'Populate_All_Fin_Ctrl_Ass_Sum';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

SAVEPOINT Populate_All_Fin_Ctrl_Ass_Sum;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_certification_id  IS NOT NULL THEN
   Populate_Fin_Ctrl_Ass_Sum
     (	p_certification_id => p_certification_id,
	x_return_status   => l_return_status,
	x_msg_count  => l_msg_count,
	x_msg_data    => l_msg_data);
   ELSE
          FOR cert_rec IN c_cert LOOP
        	exit when c_cert%notfound;
        	 Populate_Fin_Ctrl_Ass_Sum
        	 (
        	 p_certification_id => p_certification_id,
	x_return_status   => l_return_status,
	x_msg_count  => l_msg_count,
	x_msg_data    => l_msg_data
	);
        END LOOP;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
     IF c_cert%ISOPEN THEN
      	close c_cert;
      END IF;
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
      IF c_cert%ISOPEN THEN
      	close c_cert;
      END IF;
           ROLLBACK TO Populate_All_Fin_Ctrl_Ass_Sum;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;


 END Populate_All_Fin_Ctrl_Ass_Sum;

 ****************************************/

-------------populate control association which related to financial certification ----
PROCEDURE Populate_Fin_Ctrl_Ass_Sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
) IS
CURSOR c_fincontrols IS

SELECT
	controls.control_id,
	controls.PK1,
	controls.PK2,
	controls.PK3,
	controls.ASSOCIATION_CREATION_DATE,
	controls.APPROVAL_DATE,
	controls.DELETION_DATE,
	controls.DELETION_APPROVAL_DATE,
	control.CONTROL_REV_ID
FROM
	AMW_RISK_ASSOCIATIONS risks,
	AMW_CONTROL_ASSOCIATIONS controls,
	AMW_CONTROLS_B control
WHERE
	controls.object_type='RISK_ORG'
	and control.CURR_APPROVED_FLAG = 'Y'
	and control.control_id = controls.control_id
	and risks.PK1 = p_certification_id
	and risks.PK2 = controls.PK1
	and risks.PK3 = controls.PK2
	and controls.PK3 = risks.risk_id
	and risks.object_type = 'PROCESS_FINCERT'
	and controls.approval_date is not null
	and controls.approval_date <= sysdate
    	and controls.deletion_approval_date is null

UNION ALL
SELECT
	controls.control_id,
	controls.PK1,
	controls.PK2,
	controls.PK3,
	controls.ASSOCIATION_CREATION_DATE,
	controls.APPROVAL_DATE,
	controls.DELETION_DATE,
	controls.DELETION_APPROVAL_DATE,
	control.CONTROL_REV_ID
FROM
	AMW_RISK_ASSOCIATIONS risks,
	AMW_CONTROL_ASSOCIATIONS controls,
	AMW_CONTROLS_B control
WHERE
	controls.object_type='ENTITY_CONTROL'
	and control.CURR_APPROVED_FLAG = 'Y'
	and control.control_id = controls.control_id
	and risks.PK1 = p_certification_id
	and risks.PK2 = controls.PK1
	--and risks.PK3 IS NULL
	--and controls.PK3 = risks.risk_id -- controls.pk3 is null
	and risks.object_type = 'PROCESS_FINCERT'
	and controls.approval_date is not null
	and controls.approval_date <= sysdate
    	and controls.deletion_approval_date is null;



--in control association table, if type = 'RISK_FINCERT', pk1=certification_id, pk2=organization_id, pk3=process_id, pk4=risk_id, pk5=opinion_log_id
	CURSOR last_evaluation(l_organization_id number, l_control_id number)  IS
        SELECT 	distinct aov.opinion_log_id
	FROM 	AMW_OPINION_LOG_MV aov
       	WHERE 	aov.object_name = 'AMW_ORG_CONTROL'
        AND 	aov.opinion_type_code = 'EVALUATION'
        AND 	aov.pk3_value = l_organization_id
        AND	aov.pk1_value = l_control_id
        --fix bug 5724066
	AND aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = 'CANC')
        AND 	aov.authored_date = (select max(aov2.authored_date)
                       	             from AMW_OPINIONS aov2
                               	     where aov2.object_opinion_type_id = aov.object_opinion_type_id
                                     and aov2.pk3_value = aov.pk3_value
                                     and aov2.pk1_value = aov.pk1_value);

	l_count NUMBER;
	m_opinion_log_id NUMBER;

l_api_name           CONSTANT VARCHAR2(30) := 'Populate_Fin_Ctrl_Ass_Sum';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

	SAVEPOINT Populate_Fin_Ctrl_Ass_Sum;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;


	SELECT COUNT(1) INTO l_count FROM AMW_CONTROL_ASSOCIATIONS
	WHERE OBJECT_TYPE = 'RISK_FINCERT'
	and PK1 = p_certification_id;

	IF (l_count = 0) THEN
	FOR control_rec IN c_fincontrols LOOP
	exit when c_fincontrols%notfound;

	m_opinion_log_id := null;
	OPEN last_evaluation(control_rec.pk1, control_rec.control_id);
	FETCH last_evaluation INTO m_opinion_log_id;
	CLOSE last_evaluation;

		INSERT INTO AMW_CONTROL_ASSOCIATIONS(
 			       CONTROL_ASSOCIATION_ID,
			       CONTROL_ID,
			       PK1,
			       PK2,
			       PK3,
			       PK4,
			       PK5,
			       CREATED_BY,
			       CREATION_DATE,
			       LAST_UPDATE_DATE,
			       LAST_UPDATED_BY,
			       LAST_UPDATE_LOGIN,
			       OBJECT_VERSION_NUMBER,
			       OBJECT_TYPE,
			       ASSOCIATION_CREATION_DATE,
			       APPROVAL_DATE,
			       DELETION_DATE,
			       DELETION_APPROVAL_DATE,
			       CONTROL_REV_ID)
			 VALUES (AMW_CONTROL_ASSOCIATIONS_S.nextval,
			         control_rec.control_id,
			         p_certification_id,
			         control_rec.PK1,
			         control_rec.PK2,
			         control_rec.PK3,
			         m_opinion_log_id,
			         FND_GLOBAL.USER_ID,
			       	 SYSDATE,
			         SYSDATE,
			         FND_GLOBAL.USER_ID,
			         FND_GLOBAL.USER_ID,
			         1,
			         'RISK_FINCERT',
			         control_rec.ASSOCIATION_CREATION_DATE,
	 		         control_rec.APPROVAL_DATE,
			         control_rec.DELETION_DATE,
			        control_rec.DELETION_APPROVAL_DATE,
			        control_rec.CONTROL_REV_ID);


		END LOOP;

		ELSE
	FOR control_rec IN c_fincontrols LOOP
	exit when c_fincontrols%notfound;

	m_opinion_log_id := null;
	OPEN last_evaluation(control_rec.pk1, control_rec.control_id);
	FETCH last_evaluation INTO m_opinion_log_id;
	CLOSE last_evaluation;

  UPDATE AMW_CONTROL_ASSOCIATIONS SET
   LAST_UPDATE_DATE = sysdate,
   last_updated_by = fnd_global.user_id,
   last_update_login = fnd_global.conc_login_id,
   pk5 = m_opinion_log_id
   WHERE OBJECT_TYPE = 'RISK_FINCERT'
   AND  control_id = control_rec.control_id
   AND   pk2 = control_rec.pk1
   AND   pk1  IN (SELECT CERTIFICATION_ID FROM  AMW_CERTIFICATION_B
   WHERE CERTIFICATION_STATUS IN ('ACTIVE', 'DRAFT'));

END LOOP;


if(p_commit <> FND_API.g_false)
then commit;
end if;
	END IF;
	   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     IF c_fincontrols%ISOPEN THEN
      	close c_fincontrols;
      END IF;
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
      IF c_fincontrols%ISOPEN THEN
      	close c_fincontrols;
      END IF;
       ROLLBACK TO Populate_Fin_Ctrl_Ass_Sum;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;

END Populate_Fin_Ctrl_Ass_Sum;

-------------populate all of financial certification that has one or more control associations  ----
/********************delete becuase the loop is put in to master procedure
PROCEDURE Populate_All_Fin_AP_Ass_Sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
) IS
 CURSOR c_cert IS
        SELECT 	cert.certification_id, period.start_date,period.end_date
        FROM 	AMW_CERTIFICATION_B cert,
		AMW_GL_PERIODS_V period
        WHERE 	cert.certification_period_name = period.period_name
        AND 	cert.certification_period_set_name = period.period_set_name
        AND     cert.object_type='FIN_STMT'
        AND     cert.certification_status in ('ACTIVE','DRAFT');


l_api_name           CONSTANT VARCHAR2(30) := 'Populate_All_Fin_AP_Ass_Sum';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);
l_certification_id NUMBER;

BEGIN

SAVEPOINT Populate_All_Fin_AP_Ass_Sum;

l_certification_id := p_certification_id;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;

 IF p_certification_id IS NOT NULL THEN
   Populate_Fin_AP_Ass_Sum
   (	p_certification_id => l_certification_id,
	x_return_status   => l_return_status,
	x_msg_count  => l_msg_count,
	x_msg_data    => l_msg_data);
   ELSE
          FOR cert_rec IN c_cert LOOP
        	exit when c_cert%notfound;
        	 Populate_Fin_AP_Ass_Sum
        	   (	p_certification_id => l_certification_id,
		x_return_status   => l_return_status,
		x_msg_count  => l_msg_count,
		x_msg_data    => l_msg_data);
        END LOOP;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
     IF c_cert%ISOPEN THEN
      	close c_cert;
      END IF;
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
      IF c_cert%ISOPEN THEN
      	close c_cert;
      END IF;
       ROLLBACK TO Populate_All_Fin_AP_Ass_Sum;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;

END Populate_All_Fin_AP_Ass_Sum;
**************************************************/


-------------populate control association which related to financial certification ----
PROCEDURE Populate_Fin_AP_Ass_Sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
) IS

CURSOR c_finap IS
SELECT
	ap.AUDIT_PROCEDURE_ID,
	ap.PK1,
	ap.PK2,
	ap.PK3,
	ap.ASSOCIATION_CREATION_DATE,
	ap.APPROVAL_DATE,
	ap.DELETION_DATE,
	ap.DELETION_APPROVAL_DATE,
	apb.AUDIT_PROCEDURE_REV_ID
FROM
	AMW_AP_ASSOCIATIONS ap,
	AMW_CONTROL_ASSOCIATIONS controls,
	AMW_AUDIT_PROCEDURES_B apb
WHERE
	ap.object_type='CTRL_ORG'
	and apb.CURR_APPROVED_FLAG = 'Y'
	and ap.audit_procedure_id = apb.audit_procedure_id
	and controls.PK1 = p_certification_id /*certificationId*/
	and controls.PK2 = ap.PK1 /*organizationId*/
	and controls.PK3 = ap.PK2 /*processId*/
	and controls.control_id = ap.PK3 /*controlId*/
	and controls.object_type = 'RISK_FINCERT'
	and ap.association_creation_date is not null
	and ap.deletion_date is null
UNION ALL
SELECT
	ap.AUDIT_PROCEDURE_ID,
	ap.PK1,
	ap.PK2,
	ap.PK3,
	ap.ASSOCIATION_CREATION_DATE,
	ap.APPROVAL_DATE,
	ap.DELETION_DATE,
	ap.DELETION_APPROVAL_DATE,
	apb.AUDIT_PROCEDURE_REV_ID
FROM
	AMW_AP_ASSOCIATIONS ap,
	AMW_CONTROL_ASSOCIATIONS controls,
	AMW_AUDIT_PROCEDURES_B apb
WHERE
	ap.object_type='ENTITY_CTRL_AP'
	and apb.CURR_APPROVED_FLAG = 'Y'
	and ap.audit_procedure_id = apb.audit_procedure_id
	and controls.PK1 = p_certification_id
	and controls.PK2 = ap.PK1
	--and controls.PK3 = ap.PK2
	and controls.PK3 is null /**it is null here because the corresponding Ctrl is an EntityControl**/
	and controls.control_id = ap.PK3
	and controls.object_type = 'RISK_FINCERT'
	and ap.association_creation_date is not null
	and ap.deletion_date is null;

--need check opinion framework doc
--in ap association table, if type = 'CTRL_FINCERT', pk1=certification_id, pk2=organization_id, pk3=process_id, pk4=control_id, pk5=opinion_id
CURSOR last_evaluation(l_audit_procedure_id number, l_organization_id number, l_control_id number)  IS
SELECT 	distinct aov.opinion_id
FROM 	AMW_OPINION_MV aov
WHERE
                aov.object_name = 'AMW_ORG_AP_CONTROL'
        AND 	aov.opinion_type_code = 'EVALUATION'
        AND 	aov.opinion_component_code = 'OVERALL'
        AND 	aov.pk3_value = l_organization_id
        AND 	aov.pk4_value = l_audit_procedure_id
        AND	aov.pk1_value = l_control_id
        --fix bug 5724066
	AND     aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = 'CANC')
        AND 	aov.authored_date = (select max(aov2.authored_date)
                       	             from AMW_OPINIONS aov2
                               	     where aov2.object_opinion_type_id = aov.object_opinion_type_id
                                     and aov2.pk3_value = aov.pk3_value
                                     and aov2.pk1_value = aov.pk1_value
                                     and aov2.pk4_value = aov.pk4_value);


	l_count NUMBER;
	m_opinion_id NUMBER;


l_api_name           CONSTANT VARCHAR2(30) := 'Populate_Fin_AP_Ass_Sum';
l_api_version_number CONSTANT NUMBER  := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

   SAVEPOINT Populate_Fin_AP_Ass_Sum;

 -- Standard call to check for call compatibility.

        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;



	SELECT COUNT(1) INTO l_count FROM AMW_AP_ASSOCIATIONS
	WHERE OBJECT_TYPE = 'CTRL_FINCERT'
	and PK1 = p_certification_id;

	IF (l_count = 0) THEN
	   FOR ap_rec IN c_finap LOOP
	   exit when c_finap%notfound;

	      m_opinion_id := null;
	      OPEN last_evaluation(ap_rec.audit_procedure_id, ap_rec.pk1, ap_rec.pk3);
	         FETCH last_evaluation INTO m_opinion_id;
	      CLOSE last_evaluation;


		  INSERT INTO AMW_AP_ASSOCIATIONS(
			       AP_ASSOCIATION_ID,
 			       AUDIT_PROCEDURE_ID,
			       PK1, /*certificationId*/
			       PK2, /*organizationId*/
			       PK3, /*processId*/
			       PK4, /*controlId*/
			       PK5, /*opinionLogId*/
			       CREATED_BY,
			       CREATION_DATE,
			       LAST_UPDATE_DATE,
			       LAST_UPDATED_BY,
			       LAST_UPDATE_LOGIN,
			       OBJECT_VERSION_NUMBER,
			       OBJECT_TYPE,
			       ASSOCIATION_CREATION_DATE,
			       APPROVAL_DATE,
			       DELETION_DATE,
			       DELETION_APPROVAL_DATE,
			       AUDIT_PROCEDURE_REV_ID)
			 VALUES (AMW_AP_ASSOCIATIONS_S.nextval,
			         ap_rec.audit_procedure_id,
			         p_certification_id, /*certificationId*/
			         ap_rec.PK1, /*organizationId*/
			         ap_rec.PK2, /*processId*/
			         ap_rec.PK3, /*controlId*/
			         m_opinion_id, /*opinionLogId*/
			         FND_GLOBAL.USER_ID,
			         SYSDATE,
			         SYSDATE,
			         FND_GLOBAL.USER_ID,
			         FND_GLOBAL.USER_ID,
			         1,
			         'CTRL_FINCERT',
			         ap_rec.ASSOCIATION_CREATION_DATE,
	 		         ap_rec.APPROVAL_DATE,
			         ap_rec.DELETION_DATE,
			         ap_rec.DELETION_APPROVAL_DATE,
			         ap_rec.AUDIT_PROCEDURE_REV_ID);
       END LOOP;
       if(p_commit <> FND_API.g_false)
          then commit;
       end if;
	/**05.02.2006 npanandi: bug 5201579 fix here for updating, if count=0**/
	else
	   FOR ap_rec IN c_finap LOOP
	   exit when c_finap%notfound;

	      m_opinion_id := null;
	      OPEN last_evaluation(ap_rec.audit_procedure_id, ap_rec.pk1, ap_rec.pk3);
	         FETCH last_evaluation INTO m_opinion_id;
	      CLOSE last_evaluation;


		  update AMW_AP_ASSOCIATIONS
			 set PK5 = m_opinion_id
			    ,LAST_UPDATE_DATE = SYSDATE
			    ,LAST_UPDATED_BY = FND_GLOBAL.USER_ID
			    ,LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
			    ,OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1
		   where object_type = 'CTRL_FINCERT'
		     and AUDIT_PROCEDURE_ID = ap_rec.audit_procedure_id
			 AND PK2 = AP_REC.PK1 /**organizationId**/
			 and pk4 = ap_rec.pk3 /**controlId**/
			 AND PK1 IN (SELECT CERTIFICATION_ID
			               FROM AMW_CERTIFICATION_B
                          WHERE CERTIFICATION_STATUS IN ('ACTIVE','DRAFT'));
       END LOOP;
       if(p_commit <> FND_API.g_false)
          then commit;
       end if;
	  /**05.02.2006 npanandi: bug 5201579 fix ends here**/
	END IF;
	x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     IF c_finap%ISOPEN THEN
      	close c_finap;
      END IF;
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
      IF c_finap%ISOPEN THEN
      	close c_finap;
      END IF;
      ROLLBACK TO Populate_Fin_AP_Ass_Sum;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;

END Populate_Fin_AP_Ass_Sum;


PROCEDURE Populate_All_Fin_Org_Eval_Sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
) IS

    CURSOR c_cert IS
        SELECT 	cert.certification_id, period.start_date, period.end_date
        FROM 	AMW_CERTIFICATION_B cert,
		AMW_GL_PERIODS_V period
        WHERE 	cert.certification_period_name = period.period_name
        AND 	cert.certification_period_set_name = period.period_set_name
        AND     cert.object_type='FIN_STMT'
        AND     cert.certification_status in ('ACTIVE','DRAFT');


   -- select all the processes based on the certification_id
    CURSOR c_org  IS
    	SELECT distinct organization_id
    	FROM AMW_FIN_PROCESS_EVAL_SUM
    	WHERE FIN_CERTIFICATION_ID = p_certification_id;

l_subsidiary_tbl amw_scope_pvt.sub_tbl_type;
l_lob_tbl amw_scope_pvt.lob_tbl_type;
l_org_tbl amw_scope_pvt.org_tbl_type;
l_proc_tbl amw_scope_pvt.process_tbl_type;

l_sub_vs AMW_AUDIT_UNITS_V.subsidiary_valueset%TYPE;
 l_lob_vs AMW_AUDIT_UNITS_V.subsidiary_valueset%TYPE;

 l_position NUMBER;

    l_start_date DATE;
    l_end_date DATE;

l_api_name           CONSTANT VARCHAR2(30) := 'Populate_All_Fin_Org_Eval_Sum';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

SAVEPOINT Populate_All_Fin_Org_Eval_Sum;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;

	DELETE FROM AMW_ENTITY_HIERARCHIES
	WHERE ENTITY_TYPE = 'FINSTMT_CERTIFICATION'
	AND ENTITY_ID = p_certification_id;


        l_sub_vs := FND_PROFILE.value('AMW_SUBSIDIARY_AUDIT_UNIT');
        l_lob_vs := FND_PROFILE.value('AMW_LOB_AUDIT_UNITS');

         l_position := 1;

        -- DELETE_ROWS(p_certification_id, 'AMW_FIN_ORG_EVAL_SUM');

	 FOR org_rec IN c_org LOOP
	 exit when c_org%notfound;

          Populate_Fin_Org_Eval_Sum(
          p_certification_id => p_certification_id,
          p_start_date => null,
          p_end_date => null,
          p_organization_id => org_rec.organization_id,
          x_return_status  => l_return_status,
	  x_msg_count => l_msg_count,
	  x_msg_data  => l_msg_data
	);


	      /***05.25.2006 npanandi: bug 5142819 test -- added following
              begin, exception, end block to capture any errors locally
              and proceed from there, instead of erroring out the whole
              Concurrent Program***/
          begin
             SELECT company_code, lob_code
		       into l_subsidiary_tbl(l_position).subsidiary_code, l_lob_tbl(l_position).lob_code
               FROM amw_audit_units_v
              WHERE organization_id = org_rec.organization_id;

             l_org_tbl(l_position).org_id := org_rec.organization_id;
             l_position := l_position + 1;
		  exception
             when no_data_found then
                null; /***do nothing, let the loop continue
                          this ~~~~MOST PROBABLY~~~~ has to do with the fact
                          that there was an error in
                          Populate_Fin_Org_Eval_Sum as well
                       ***/
          end;

	END LOOP;

  IF(l_subsidiary_tbl.count <> 0 ) THEN
	AMW_SCOPE_PVT.add_scope
	(
                    p_entity_id       => p_certification_id,
                    p_entity_type     => 'FINSTMT_CERTIFICATION',
                    p_sub_vs       => l_sub_vs,
                    p_lob_vs     => l_lob_vs,
                    p_subsidiary_tbl    => l_subsidiary_tbl,
                    p_lob_tbl      =>l_lob_tbl ,
                    p_org_tbl   => l_org_tbl,
                    p_process_tbl          => l_proc_tbl,
                    x_return_status         => l_return_status,
                    x_msg_count     => l_msg_count,
                    x_msg_data    => l_msg_data
	);
END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
       ROLLBACK TO Populate_All_Fin_Org_Eval_Sum;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;

END Populate_All_Fin_Org_Eval_Sum;



PROCEDURE  Populate_Fin_Org_Eval_Sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id          IN      NUMBER,
p_start_date                IN      DATE,
p_end_date			IN      DATE,
p_organization_id		IN 	NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
)
IS
    CURSOR last_evaluation IS
        SELECT 	distinct aov.opinion_id
	FROM 	AMW_OPINION_MV aov
       	WHERE 	aov.object_name = 'AMW_ORGANIZATION'
        AND 	aov.opinion_type_code = 'EVALUATION'
        AND 	aov.opinion_component_code = 'OVERALL'
        AND 	aov.pk1_value = p_organization_id
        --fix bug 5724066
	AND     aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = 'CANC')
        AND 	aov.authored_date = (select max(aov2.authored_date)
                       	             from AMW_OPINIONS aov2
                               	     where aov2.object_opinion_type_id = aov.object_opinion_type_id
                                     and aov2.pk1_value = aov.pk1_value);

   CURSOR last_evaluation_history(l_opinion_id number) IS
        SELECT 	max(aov.opinion_log_id)
	FROM 	AMW_OPINIONS_LOG aov
       	WHERE 	aov.opinion_id = l_opinion_id;

    CURSOR last_certification IS
       SELECT aov.opinion_id
        FROM    AMW_OPINION_MV aov
        WHERE   aov.object_name = 'AMW_ORGANIZATION'
        AND     aov.opinion_type_code = 'CERTIFICATION'
        AND     aov.opinion_component_code = 'OVERALL'
       AND     aov.pk1_value = p_organization_id
        AND     aov.authored_date = (select max(aov2.authored_date)
                                     from AMW_OPINIONS aov2
                                     where aov2.object_opinion_type_id = aov.object_opinion_type_id
                                     and aov2.pk1_value = aov.pk1_value)
        AND     aov.pk2_value in (select proc_cert_Id from AMW_FIN_PROC_CERT_RELAN
                                where fin_stmt_cert_id = p_certification_id
                                 and end_date is null );

   CURSOR last_certification_history(l_opinion_id number) IS
   	SELECT max(opinion_log_id)
   	FROM 	AMW_OPINIONS_LOG aov
       	WHERE 	aov.opinion_id = l_opinion_id;

    CURSOR total_num_of_proc IS
	SELECT COUNT(DISTINCT PROCESS_ID) FROM AMW_FIN_PROCESS_EVAL_SUM
	WHERE FIN_CERTIFICATION_ID = p_certification_id AND ORGANIZATION_ID = p_organization_id;


CURSOR pending_proc IS
    SELECT count(distinct proeval.process_id)
    FROM AMW_FIN_PROCESS_EVAL_SUM proeval
    WHERE proeval.fin_certification_id = p_certification_id
    AND	  proeval.organization_id = p_organization_id
    AND       proeval.cert_opinion_log_id is null;


    CURSOR proc_with_issue IS
    SELECT count(distinct proeval.process_id)
    FROM AMW_FIN_PROCESS_EVAL_SUM proeval,
    	 AMW_OPINION_MV aov
    WHERE proeval.fin_certification_id = p_certification_id
    AND	  proeval.organization_id = p_organization_id
    AND     aov.object_name = 'AMW_ORG_PROCESS'
        AND     aov.opinion_type_code = 'CERTIFICATION'
        AND 	aov.opinion_component_code = 'OVERALL'
        AND     aov.pk3_value = p_organization_id
	AND     aov.pk2_value in (select proc_cert_Id from AMW_FIN_PROC_CERT_RELAN
           			where fin_stmt_cert_id = p_certification_id
           			 and end_date is null )
        AND     aov.pk1_value = proeval.process_id
	AND     aov.authored_date = (select max(aov2.authored_date)
                       	             from AMW_OPINIONS  aov2
                               	     where aov2.object_opinion_type_id
					   = aov.object_opinion_type_id
                                     and aov2.pk3_value = aov.pk3_value
				     AND aov2.pk2_value in
					(select proc_cert_Id from AMW_FIN_PROC_CERT_RELAN
           				 where fin_stmt_cert_id = p_certification_id
           				 and end_date is null)
                                     and aov2.pk1_value = aov.pk1_value)
        AND     aov.OPINION_VALUE_CODE <> 'EFFECTIVE';

    CURSOR proc_without_issue IS
    SELECT count(distinct proeval.process_id)
    FROM AMW_FIN_PROCESS_EVAL_SUM proeval,
    	 AMW_OPINION_MV aov
    WHERE proeval.fin_certification_id = p_certification_id
    AND	  proeval.organization_id = p_organization_id
    AND     aov.object_name = 'AMW_ORG_PROCESS'
        AND     aov.opinion_type_code = 'CERTIFICATION'
        AND 	aov.opinion_component_code = 'OVERALL'
        AND     aov.pk3_value = p_organization_id
	AND     aov.pk2_value in (select proc_cert_Id from AMW_FIN_PROC_CERT_RELAN
           			where fin_stmt_cert_id = p_certification_id
           			and end_date is null)
        AND     aov.pk1_value = proeval.process_id
	AND     aov.authored_date = (select max(aov2.authored_date)
                       	             from AMW_OPINIONS  aov2
                               	     where aov2.object_opinion_type_id
					   = aov.object_opinion_type_id
                                     and aov2.pk3_value = aov.pk3_value
				     AND aov2.pk2_value in
					(select proc_cert_Id from AMW_FIN_PROC_CERT_RELAN
           				 where fin_stmt_cert_id = p_certification_id
           				 and end_date is null)
                                     and aov2.pk1_value = aov.pk1_value)
        AND     aov.OPINION_VALUE_CODE = 'EFFECTIVE';

    CURSOR proc_with_ineff_ctrl IS
     SELECT count(distinct proeval.process_id)
     FROM AMW_FIN_PROCESS_EVAL_SUM proeval,
    	  AMW_OPINION_MV aov
    WHERE proeval.fin_certification_id = p_certification_id
    AND	  proeval.organization_id = p_organization_id
     AND     aov.object_name = 'AMW_ORG_PROCESS'
        AND     aov.opinion_type_code = 'EVALUATION'
        AND 	aov.opinion_component_code = 'OVERALL'
        AND     aov.pk3_value = p_organization_id
        AND     aov.pk1_value = proeval.process_id
        --fix bug 5724066
	AND     aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = 'CANC')
        AND     aov.authored_date =
		      (select max(aov2.authored_date)
		       from   AMW_OPINIONS  aov2
		       where aov2.object_opinion_type_id = aov.object_opinion_type_id
			 and aov2.pk3_value = aov.pk3_value
                         and aov2.pk1_value = aov.pk1_value)
           AND aov.OPINION_VALUE_CODE <> 'EFFECTIVE';

  CURSOR verified_processes IS
   SELECT count(distinct proeval.process_id)
     FROM AMW_FIN_PROCESS_EVAL_SUM proeval,
    	  AMW_OPINION_MV aov
    WHERE proeval.fin_certification_id = p_certification_id
    AND	  proeval.organization_id = p_organization_id
     AND     aov.object_name = 'AMW_ORG_PROCESS'
        AND     aov.opinion_type_code = 'EVALUATION'
        AND     aov.opinion_component_code = 'OVERALL'
        AND     aov.pk3_value = p_organization_id
        AND     aov.pk1_value = proeval.process_id
        --fix bug 5724066
	AND     aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = 'CANC');



    CURSOR unmitigated_risks IS
     SELECT 	count(distinct ara.risk_association_id)
     FROM 	AMW_RISK_ASSOCIATIONS ara,
                AMW_OPINION_MV aov
    WHERE	ara.object_type = 'PROCESS_FINCERT'
    AND		ara.pk1= p_certification_id
    AND		ara.pk2= p_organization_id
    AND 	aov.object_name = 'AMW_ORG_PROCESS_RISK'
    AND 	aov.opinion_type_code = 'EVALUATION'
    AND 	aov.opinion_component_code = 'OVERALL'
    AND 	aov.pk3_value = ara.pk2
    AND 	aov.pk4_value = ara.pk3
    AND 	aov.pk1_value = ara.risk_id
    --fix bug 5724066
    AND         aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = 'CANC')
    AND 	aov.authored_date = (select max(aov2.authored_date)
                                     from AMW_OPINIONS  aov2
                                     where aov2.object_opinion_type_id = aov.object_opinion_type_id
                                     and aov2.pk4_value = aov.pk4_value
                                     and aov2.pk3_value = aov.pk3_value
                                     and aov2.pk1_value = aov.pk1_value)
      	AND 	aov.OPINION_VALUE_CODE <> 'EFFECTIVE';


    CURSOR total_risks IS
        SELECT 	count(distinct ara.risk_association_id)
        FROM AMW_RISK_ASSOCIATIONS ara
        WHERE	ara.object_type = 'PROCESS_FINCERT'
    	AND		ara.pk1= p_certification_id
    	AND		ara.pk2= p_organization_id;

CURSOR verified_risks IS
SELECT 	count(distinct ara.risk_association_id)
     FROM 	AMW_RISK_ASSOCIATIONS ara,
                	AMW_OPINION_MV aov
    WHERE	ara.object_type = 'PROCESS_FINCERT'
    AND		ara.pk1= p_certification_id
    AND		ara.pk2= p_organization_id
    AND 	aov.object_name = 'AMW_ORG_PROCESS_RISK'
    AND 	aov.opinion_type_code = 'EVALUATION'
    AND 	aov.opinion_component_code = 'OVERALL'
    AND 	aov.pk3_value = ara.pk2
    AND 	aov.pk4_value = ara.pk3
    AND 	aov.pk1_value = ara.risk_id
    --fix bug 5724066
    AND aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = 'CANC');

    CURSOR ineffective_controls IS
    SELECT 	count(distinct aca.control_id)
    FROM	AMW_CONTROL_ASSOCIATIONS aca ,
                AMW_OPINION_MV aov
    WHERE	aca.object_type = 'RISK_FINCERT'
    AND		aca.pk1 = p_certification_id
    AND		aca.pk2 = p_organization_id
    AND 	aov.object_name = 'AMW_ORG_CONTROL'
    AND 	aov.opinion_type_code = 'EVALUATION'
    AND 	aov.opinion_component_code = 'OVERALL'
    AND 	aov.pk3_value = p_organization_id
    AND 	aov.pk1_value = aca.control_id
    --fix bug 5724066
    AND         aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = 'CANC')
    AND 	aov.authored_date = (select max(aov2.authored_date)
                                     from AMW_OPINIONS  aov2
                                     where aov2.object_opinion_type_id = aov.object_opinion_type_id
                                     and aov2.pk3_value = aov.pk3_value
                                     and aov2.pk1_value = aov.pk1_value)
    AND 	aov.OPINION_VALUE_CODE <> 'EFFECTIVE';


    CURSOR total_controls IS
        SELECT 	count(distinct aca.control_id)
        FROM AMW_CONTROL_ASSOCIATIONS aca
        WHERE	aca.object_type = 'RISK_FINCERT'
    AND		aca.pk1 = p_certification_id
    AND		aca.pk2 = p_organization_id;

    CURSOR verified_controls IS
    SELECT 	count(distinct aca.control_id)
    FROM	AMW_CONTROL_ASSOCIATIONS aca ,
                AMW_OPINION_MV aov
    WHERE	aca.object_type = 'RISK_FINCERT'
    AND		aca.pk1 = p_certification_id
    AND		aca.pk2 = p_organization_id
    AND 	aov.object_name = 'AMW_ORG_CONTROL'
    AND 	aov.opinion_type_code = 'EVALUATION'
    AND 	aov.opinion_component_code = 'OVERALL'
    AND 	aov.pk3_value = p_organization_id
    AND 	aov.pk1_value = aca.control_id
    --fix bug 5724066
    AND aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = 'CANC');

    CURSOR c_org IS
        SELECT  subsidiary_valueset, company_code, lob_valueset, lob_code
        FROM    amw_audit_units_v
        WHERE   organization_id = p_organization_id;

    l_eval_opinion_id		NUMBER;
    l_proc_pending_cert		NUMBER;
    l_total_num_of_procs	NUMBER;
    l_proc_with_issue		NUMBER;
    l_proc_without_issue	NUMBER;
    l_proc_certified		NUMBER;
    l_proc_with_ineff_ctrl	NUMBER;
    l_proc_verified		NUMBER;
    l_unmitigated_risks	NUMBER;
    l_total_risks		NUMBER;
    l_verified_risks		NUMBER;
    l_ineff_controls		NUMBER;
    l_total_controls		NUMBER;
    l_verified_controls		NUMBER;
    l_open_findings		NUMBER;
    l_sub_vs			VARCHAR2(150);
    l_lob_vs			VARCHAR2(150);
    l_sub_code			VARCHAR2(150);
    l_lob_code			VARCHAR2(150);
    l_eval_opinion_log_id	NUMBER;
    l_cert_opinion_id		NUMBER;
    l_cert_opinion_log_id	NUMBER;

l_api_name           CONSTANT VARCHAR2(30) := 'Populate_Fin_Org_Eval_Sum';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN


SAVEPOINT Populate_Fin_Org_Eval_Sum;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;




    --fnd_file.put_line (fnd_file.LOG, 'p_certification_id='||to_char(p_certification_id));
    --fnd_file.put_line(fnd_file.LOG, 'p_organization_id='||to_char(p_organization_id));
   -- fnd_file.put_line(fnd_file.LOG, 'before last_evaludation:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

    OPEN last_evaluation;
    FETCH last_evaluation INTO l_eval_opinion_id;
    CLOSE last_evaluation;
   --fnd_file.put_line(fnd_file.LOG, 'after last_evaludation:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

    OPEN total_num_of_proc;
    FETCH total_num_of_proc INTO l_total_num_of_procs;
    CLOSE total_num_of_proc;
   -- fnd_file.put_line(fnd_file.LOG, 'after total_num_of_proc:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));


  OPEN proc_with_issue;
  FETCH proc_with_issue INTO l_proc_with_issue;
  CLOSE proc_with_issue;
   -- fnd_file.put_line(fnd_file.LOG, 'after proc_with_issue:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

 OPEN proc_without_issue;
 FETCH proc_without_issue INTO l_proc_without_issue;
 CLOSE proc_without_issue;
   -- fnd_file.put_line(fnd_file.LOG, 'after proc_without_issue:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

    l_proc_certified := l_proc_with_issue + l_proc_without_issue;

--replace the calculation with one cursor to easy debug process.
--    l_proc_pending_cert := l_total_num_of_procs-l_proc_certified;

    OPEN pending_proc;
    FETCH pending_proc INTO l_proc_pending_cert;
    CLOSE pending_proc;


    OPEN proc_with_ineff_ctrl;
    FETCH proc_with_ineff_ctrl INTO l_proc_with_ineff_ctrl;
    CLOSE proc_with_ineff_ctrl;
    --fnd_file.put_line(fnd_file.LOG, 'after proc_with_ineff_ctrl:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));


     OPEN verified_processes;
     FETCH verified_processes INTO l_proc_verified;
     CLOSE verified_processes;

    OPEN unmitigated_risks;
    FETCH unmitigated_risks INTO l_unmitigated_risks;
    CLOSE unmitigated_risks;
    --fnd_file.put_line(fnd_file.LOG, 'after unmitigated:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));


    OPEN total_risks;
    FETCH total_risks INTO l_total_risks;
    CLOSE total_risks;
    --fnd_file.put_line(fnd_file.LOG, 'after total_risks:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));


     OPEN verified_risks;
     FETCH verified_risks INTO l_verified_risks;
     CLOSE verified_risks;


    OPEN ineffective_controls;
    FETCH ineffective_controls INTO l_ineff_controls;
    CLOSE ineffective_controls;
    --fnd_file.put_line(fnd_file.LOG, 'after ineffective_controls:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

    OPEN total_controls;
    FETCH total_controls INTO l_total_controls;
    CLOSE total_controls;
    --fnd_file.put_line(fnd_file.LOG, 'after total_controls:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

     OPEN verified_controls;
     FETCH verified_controls INTO l_verified_controls;
     CLOSE verified_controls;

    OPEN c_org;
    FETCH c_org INTO l_sub_vs, l_sub_code, l_lob_vs, l_lob_code;
    CLOSE c_org;
   -- fnd_file.put_line(fnd_file.LOG, 'after c_org:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

    BEGIN
        l_open_findings := amw_findings_pkg.calculate_open_findings (
               'AMW_PROJ_FINDING',
	       'PROJ_ORG', p_organization_id,
	       null, null,
	       null, null,
	       null, null,
	       null, null );
   EXCEPTION
        WHEN OTHERS THEN
            null;
    END;

    OPEN last_evaluation_history(l_eval_opinion_id);
    FETCH last_evaluation_history INTO l_eval_opinion_log_id;
    CLOSE last_evaluation_history;
   -- fnd_file.put_line(fnd_file.LOG, 'after last_evaludation_history:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

    OPEN last_certification;
    FETCH last_certification INTO l_cert_opinion_id;
    CLOSE last_certification;
    --fnd_file.put_line(fnd_file.LOG, 'after last_certification:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

    OPEN last_certification_history(l_cert_opinion_id);
    FETCH last_certification_history INTO l_cert_opinion_log_id;
    CLOSE last_certification_history;
    --fnd_file.put_line(fnd_file.LOG, 'after last_certification_history'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

   -- fnd_file.put_line(fnd_file.LOG, 'after open_findings:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

    /**05.25.2006 npanandi: bug 5250100 test**/
    if((l_sub_vs is null) OR (l_sub_code is null)) then
       G_ORG_ERROR := 'Y';
       /**05.25.2006 npanandi: need x_return_status in
          populate_all_fin_org_eval_sum procedure**/
       x_return_status := FND_API.G_RET_STS_ERROR;
       fnd_file.put_line(fnd_file.LOG, '********** WARNING: Unexpected error in OrganizationId: '||p_organization_id||', processing not done for this Organization' );
    else --- do the updates/inserts
      /**05.25.2006 npanandi: bug 5250100 test ends**/

	  UPDATE  AMW_FIN_ORG_EVAL_SUM
         SET EVAL_OPINION_ID = l_eval_opinion_id,
             PROC_PENDING_CERTIFICATION = l_proc_pending_cert,
		     TOTAL_NUMBER_OF_PROCS = l_total_num_of_procs,
		     PROC_CERTIFIED_WITH_ISSUES = l_proc_with_issue,
		     PROC_VERIFIED = l_proc_verified,
		     PROC_CERTIFIED  = l_proc_certified,
		     PROC_WITH_INEFFECTIVE_CONTROLS = l_proc_with_ineff_ctrl,
		     UNMITIGATED_RISKS = l_unmitigated_risks,
		     RISKS_VERIFIED = l_verified_risks,
		     TOTAL_NUMBER_OF_RISKS = l_total_risks,
		     INEFFECTIVE_CONTROLS = l_ineff_controls,
		     CONTROLS_VERIFIED = l_verified_controls,
		     TOTAL_NUMBER_OF_CTRLS = l_total_controls,
		     PROC_PENDING_CERT_PRCNT =
		      round(nvl(l_proc_pending_cert, 0) /decode(nvl(l_total_num_of_procs,0), 0,1,l_total_num_of_procs),2)*100,
		     PROCESSES_WITH_ISSUES_PRCNT =
	              round(nvl(l_proc_with_issue, 0) /decode(nvl(l_total_num_of_procs, 0), 0,1,l_total_num_of_procs),2)*100,
		     PROC_WITH_INEFF_CONTROLS_PRCNT =
		      round(nvl(l_proc_with_ineff_ctrl, 0) /decode(nvl(l_total_num_of_procs,0), 0,1,l_total_num_of_procs),2)*100,
		     UNMITIGATED_RISKS_PRCNT = round(nvl(l_unmitigated_risks, 0) /decode(nvl(l_total_risks, 0),0,1,l_total_risks), 2)*100,
		     INEFFECTIVE_CONTROLS_PRCNT = round(nvl(l_ineff_controls, 0) /decode(nvl(l_total_controls, 0),0,1,l_total_controls), 2)*100,
		     OPEN_FINDINGS = l_open_findings,
             LAST_UPDATE_DATE = sysdate,
             LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
             LAST_UPDATE_LOGIN = fnd_global.conc_login_id,
		     OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1,
		     SUBSIDIARY_VS = l_sub_vs,
		     SUBSIDIARY_CODE = l_sub_code,
		     LOB_VS = l_lob_vs,
		     LOB_CODE = l_lob_code,
		     CERT_OPINION_ID  = l_cert_opinion_id,
		     EVAL_OPINION_LOG_ID  = l_eval_opinion_log_id,
		     CERT_OPINION_LOG_ID  = l_cert_opinion_log_id
       WHERE fin_certification_id = p_certification_id
         AND organization_id = p_organization_id;


     IF (SQL%NOTFOUND) THEN
        INSERT INTO AMW_FIN_ORG_EVAL_SUM(
	      FIN_CERTIFICATION_ID,
	      ORGANIZATION_ID,
	      EVAL_OPINION_ID,
	      PROC_PENDING_CERTIFICATION,
	      TOTAL_NUMBER_OF_PROCS,
	      PROC_CERTIFIED_WITH_ISSUES,
	      PROC_VERIFIED,
	      PROC_CERTIFIED,
	      PROC_WITH_INEFFECTIVE_CONTROLS,
	      UNMITIGATED_RISKS,
	      RISKS_VERIFIED,
	      TOTAL_NUMBER_OF_RISKS,
	      INEFFECTIVE_CONTROLS,
	      CONTROLS_VERIFIED,
	      TOTAL_NUMBER_OF_CTRLS,
	      PROC_PENDING_CERT_PRCNT,
	      PROCESSES_WITH_ISSUES_PRCNT,
	      PROC_WITH_INEFF_CONTROLS_PRCNT,
	      UNMITIGATED_RISKS_PRCNT,
	      INEFFECTIVE_CONTROLS_PRCNT,
	      OPEN_FINDINGS,
	      CREATED_BY,
	      CREATION_DATE,
	      LAST_UPDATED_BY,
	      LAST_UPDATE_DATE,
	      LAST_UPDATE_LOGIN,
	      OBJECT_VERSION_NUMBER,
	      SUBSIDIARY_VS,
	      SUBSIDIARY_CODE,
	      LOB_VS,
	      LOB_CODE,
	      CERT_OPINION_ID ,
	      EVAL_OPINION_LOG_ID ,
	      CERT_OPINION_LOG_ID)
       SELECT p_certification_id,
              	      p_organization_id,
	      l_eval_opinion_id,
	      l_proc_pending_cert,
	      l_total_num_of_procs,
	      l_proc_with_issue,
	      l_proc_verified,
	      l_proc_certified,
	      l_proc_with_ineff_ctrl,
	      l_unmitigated_risks,
	      l_verified_risks,
	      l_total_risks,
	      l_ineff_controls,
	      l_verified_controls,
	      l_total_controls,
	      round(nvl(l_proc_pending_cert, 0)/decode(nvl(l_total_num_of_procs, 0), 0,1,l_total_num_of_procs),2)*100,
	      round(nvl(l_proc_with_issue, 0)/decode(nvl(l_total_num_of_procs, 0), 0,1,l_total_num_of_procs),2)*100,
	      round(nvl(l_proc_with_ineff_ctrl, 0)/decode(nvl(l_total_num_of_procs, 0), 0,1,l_total_num_of_procs),2)*100,
	      round(nvl(l_unmitigated_risks, 0)/decode(nvl(l_total_risks, 0),0,1,l_total_risks), 2)*100,
	      round(nvl(l_ineff_controls, 0) /decode(nvl(l_total_controls, 0),0,1,l_total_controls), 2)*100,
	      l_open_findings,
              FND_GLOBAL.USER_ID,
              SYSDATE,
              FND_GLOBAL.USER_ID,
              SYSDATE,
              FND_GLOBAL.USER_ID,
	      1,
	      l_sub_vs,
	      l_sub_code,
	      l_lob_vs,
	      l_lob_code,
	      l_cert_opinion_id,
	      l_eval_opinion_log_id,
	      l_cert_opinion_log_id
        FROM  DUAL;
    END IF;

  end if; /***05.25.2006 npanandi: end of if clause for bug 5250100 testing***/

  if(p_commit <> FND_API.g_false) then
     commit;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
       ROLLBACK TO Populate_Fin_Org_Eval_Sum;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;
END Populate_Fin_Org_Eval_Sum;


PROCEDURE build_amw_fin_cert_eval_sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
) IS

---CURSOR TO GET ALL OF FINANCIAL ITEMS WHICH RELATE TO THIS FINANCIAL CERTIFICATION
CURSOR Get_all_items IS
SELECT DISTINCT ITEM.STATEMENT_GROUP_ID, ITEM.FINANCIAL_STATEMENT_ID, ITEM.FINANCIAL_ITEM_ID
FROM AMW_FIN_CERT_SCOPE ITEM
WHERE ITEM.FIN_CERTIFICATION_ID = P_CERTIFICATION_ID
AND ITEM.FINANCIAL_ITEM_ID IS NOT NULL;

--CURSOR TO GET ALL OF ACCOUNTS WHICH RELATE TO THIS FINANCIAL CERTIFICATION
CURSOR 	Get_all_accts IS
SELECT DISTINCT finitemAcc.statement_group_id, finitemAcc.financial_statement_id, finitemAcc.financial_item_id,  finitemAcc.account_group_id, finitemAcc.natural_account_id
FROM AMW_FIN_CERT_SCOPE finitemAcc
WHERE finitemAcc.FIN_CERTIFICATION_ID = P_CERTIFICATION_ID
AND finitemAcc.natural_account_id is not null;

---CURSOR TO GET ALL OF CERTIFICATION WITH 'DRAFT', 'ACTIVE' STATUS
cursor Get_Cert_for_processing
   is
   select
        certifcationb.CERTIFICATION_ID ,
        certifcationb.FINANCIAL_STATEMENT_ID,
        certifcationb.STATEMENT_GROUP_ID
   FROM
        AMW_CERTIFICATION_B certifcationb
   where
        certifcationb.OBJECT_TYPE='FIN_STMT'
    and certifcationb.CERTIFICATION_STATUS in ('ACTIVE', 'DRAFT');



     l_certification_id NUMBER;

  l_api_name           CONSTANT VARCHAR2(30) := 'build_amw_fin_cert_eval_sum';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

   SAVEPOINT build_amw_fin_cert_eval_sum;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;



     l_certification_id := P_CERTIFICATION_ID;

  --DELETE_ROWS(P_CERTIFICATION_ID, 'AMW_FIN_CERT_EVAL_SUM');

 FOR Get_all_items_Rec in Get_all_items LOOP
	 exit when Get_all_items %notfound;
	compute_values_for_eval_sum
                 (P_CERTIFICATION_ID => l_certification_id,
                  P_FINANCIAL_STATEMENT_ID => Get_all_items_Rec.FINANCIAL_STATEMENT_ID ,
                  P_STATEMENT_GROUP_ID => Get_all_items_Rec.STATEMENT_GROUP_ID ,
                  P_FINANCIAL_ITEM_ID => Get_all_items_Rec.FINANCIAL_ITEM_ID,
                  P_ACCOUNT_GROUP_ID   => NULL,
                  P_ACCOUNT_ID         => NULL,
                  P_OBJECT_TYPE => 'FINANCIAL ITEM',
                  x_return_status    => l_return_status,
     	x_msg_count   => l_msg_count,
    	x_msg_data    => l_msg_data);


                 amw_fin_coso_views_pvt.create_fin_ctrl_objectives
     	(P_CERTIFICATION_ID => l_certification_id,
                 P_FINANCIAL_STATEMENT_ID => Get_all_items_Rec.FINANCIAL_STATEMENT_ID ,
                  P_STATEMENT_GROUP_ID => Get_all_items_Rec.STATEMENT_GROUP_ID ,
                  P_FINANCIAL_ITEM_ID => Get_all_items_Rec.FINANCIAL_ITEM_ID,
                  P_ACCOUNT_GROUP_ID   => NULL,
                  P_ACCOUNT_ID         => NULL,
                  P_OBJECT_TYPE => 'FINANCIAL ITEM');

                 amw_fin_coso_views_pvt.create_fin_ctrl_Assertions
                 (P_CERTIFICATION_ID => l_certification_id,
                 P_FINANCIAL_STATEMENT_ID => Get_all_items_Rec.FINANCIAL_STATEMENT_ID ,
                  P_STATEMENT_GROUP_ID => Get_all_items_Rec.STATEMENT_GROUP_ID ,
                  P_FINANCIAL_ITEM_ID => Get_all_items_Rec.FINANCIAL_ITEM_ID,
                  P_ACCOUNT_GROUP_ID   => NULL,
                  P_ACCOUNT_ID         => NULL,
                  P_OBJECT_TYPE => 'FINANCIAL ITEM');

                amw_fin_coso_views_pvt.create_fin_ctrl_components
                (P_CERTIFICATION_ID => l_certification_id,
                 P_FINANCIAL_STATEMENT_ID => Get_all_items_Rec.FINANCIAL_STATEMENT_ID ,
                  P_STATEMENT_GROUP_ID => Get_all_items_Rec.STATEMENT_GROUP_ID ,
                  P_FINANCIAL_ITEM_ID => Get_all_items_Rec.FINANCIAL_ITEM_ID,
                  P_ACCOUNT_GROUP_ID   => NULL,
                  P_ACCOUNT_ID         => NULL,
                  P_OBJECT_TYPE => 'FINANCIAL ITEM');



 END LOOP;

  FOR Get_all_accts_Rec IN Get_all_accts LOOP
           exit when Get_all_accts%notfound;
           compute_values_for_eval_sum
                 (P_CERTIFICATION_ID => l_certification_id,
                  P_STATEMENT_GROUP_ID => Get_all_accts_Rec.STATEMENT_GROUP_ID ,
                  P_FINANCIAL_STATEMENT_ID => Get_all_accts_Rec.FINANCIAL_STATEMENT_ID,
                  P_FINANCIAL_ITEM_ID => Get_all_accts_Rec.financial_item_id,
                  P_ACCOUNT_ID         => Get_all_accts_Rec.natural_account_id,
                  P_ACCOUNT_GROUP_ID   => Get_all_accts_Rec.account_group_id,
                  P_OBJECT_TYPE => 'ACCOUNT',
                   x_return_status    => l_return_status,
     		x_msg_count   => l_msg_count,
    		x_msg_data    => l_msg_data);


          amw_fin_coso_views_pvt.create_fin_ctrl_objectives
           	(P_CERTIFICATION_ID => l_certification_id,
                  P_STATEMENT_GROUP_ID => Get_all_accts_Rec.STATEMENT_GROUP_ID ,
                  P_FINANCIAL_STATEMENT_ID => Get_all_accts_Rec.FINANCIAL_STATEMENT_ID,
                  P_FINANCIAL_ITEM_ID => Get_all_accts_Rec.financial_item_id,
                  P_ACCOUNT_ID         => Get_all_accts_Rec.natural_account_id,
                  P_ACCOUNT_GROUP_ID   => Get_all_accts_Rec.account_group_id,
                  P_OBJECT_TYPE => 'ACCOUNT');

         amw_fin_coso_views_pvt.create_fin_ctrl_Assertions
         	(P_CERTIFICATION_ID => l_certification_id,
                  P_STATEMENT_GROUP_ID => Get_all_accts_Rec.STATEMENT_GROUP_ID ,
                  P_FINANCIAL_STATEMENT_ID => Get_all_accts_Rec.FINANCIAL_STATEMENT_ID,
                  P_FINANCIAL_ITEM_ID => Get_all_accts_Rec.financial_item_id,
                  P_ACCOUNT_ID         => Get_all_accts_Rec.natural_account_id,
                  P_ACCOUNT_GROUP_ID   => Get_all_accts_Rec.account_group_id,
                  P_OBJECT_TYPE => 'ACCOUNT');

         amw_fin_coso_views_pvt.create_fin_ctrl_components
         	(P_CERTIFICATION_ID => l_certification_id,
                  P_STATEMENT_GROUP_ID => Get_all_accts_Rec.STATEMENT_GROUP_ID ,
                  P_FINANCIAL_STATEMENT_ID => Get_all_accts_Rec.FINANCIAL_STATEMENT_ID,
                  P_FINANCIAL_ITEM_ID => Get_all_accts_Rec.financial_item_id,
                  P_ACCOUNT_ID         => Get_all_accts_Rec.natural_account_id,
                  P_ACCOUNT_GROUP_ID   => Get_all_accts_Rec.account_group_id,
                  P_OBJECT_TYPE => 'ACCOUNT');



  END LOOP;


 x_return_status := FND_API.G_RET_STS_SUCCESS;

 EXCEPTION
     WHEN NO_DATA_FOUND THEN
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
       ROLLBACK TO build_amw_fin_cert_eval_sum;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;


END build_amw_fin_cert_eval_sum;

/*********************************************************************************************/
/**************************************Add by Dong -----------------------------------------*/
/********************************* combine statement item and account calls into one --------*/
/********************************************************************************************/
PROCEDURE compute_values_for_eval_sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id IN NUMBER,
p_financial_statement_id IN NUMBER ,
p_statement_group_id IN NUMBER ,
p_financial_item_id IN NUMBER,
p_account_group_id IN NUMBER,
p_account_id   IN NUMBER,
p_object_type IN VARCHAR2,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
) IS


-- variables for totals
      M_PROC_PENDING_CERTIFICATION number :=0;
      M_TOTAL_NUMBER_OF_PROCESSES  number :=0;
      M_PROC_CERTIFIED_WITH_ISSUES number :=0;
      M_PROCS_FOR_CERT_DONE number :=0;
      M_PROC_VERIFIED              number :=0;

      M_org_with_ineffective_ctrls  number :=0;
      M_org_certified              number :=0;
      M_org_evaluated 		number :=0;
      M_total_orgs		number :=0;

      M_proc_with_ineffective_ctrls  number :=0;

      M_unmitigated_risks          number :=0;
      M_risks_verified             number :=0;
      M_total_risks		 number :=0;

      M_ineffective_controls       number :=0;
      M_controls_verified          number :=0;
      M_total_controls		 number :=0;

      M_open_issues                number :=0;

      M_PRO_PENDING_CERT_PRCNT number :=0;
      M_PROCESSES_WITH_ISSUES_PRCNT number :=0;
      M_ORG_WITH_INEFF_CTRLS_PRCNT number :=0;
      M_PROC_WITH_INEFF_CTRLS_PRCNT number :=0;
      M_UNMITIGATED_RISKS_PRCNT number  :=0;
      M_INEFFECTIVE_CONTROLS_PRCNT number :=0;



      --l_eval_opinion_id NUMBER;
     -- l_eval_opinion_log_id NUMBER;

      l_stmt  VARCHAR2(4000);

 	l_deleteme date;

      L_FINANCIAL_STATEMENT_ID NUMBER ;
      L_CERTIFICATION_ID NUMBER ;
      L_STATEMENT_GROUP_ID NUMBER ;
      L_FINANCIAL_ITEM_ID NUMBER ;
      L_ACCOUNT_ID NUMBER;
      L_OBJECT_TYPE VARCHAR2(30) ;
      L_ACCOUNT_GROUP_ID NUMBER ;

      l_start_time date;
      l_end_time date;

l_api_name           CONSTANT VARCHAR2(30) := 'compute_values_for_eval_sum';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

SAVEPOINT compute_values_for_eval_sum;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;



      L_FINANCIAL_STATEMENT_ID  := P_FINANCIAL_STATEMENT_ID;
      L_CERTIFICATION_ID  := P_CERTIFICATION_ID;
      L_STATEMENT_GROUP_ID := P_STATEMENT_GROUP_ID;
      L_FINANCIAL_ITEM_ID  := P_FINANCIAL_ITEM_ID;
      L_ACCOUNT_ID  := P_ACCOUNT_ID;
      L_OBJECT_TYPE  := p_object_type;
      L_ACCOUNT_GROUP_ID  :=  p_account_group_id;


          l_start_time := sysdate;
         M_TOTAL_NUMBER_OF_PROCESSES := GetTotalProcesses
                  (P_CERTIFICATION_ID => L_CERTIFICATION_ID,
                  P_FINANCIAL_STATEMENT_ID => L_FINANCIAL_STATEMENT_ID,
                  P_STATEMENT_GROUP_ID => L_STATEMENT_GROUP_ID ,
                  P_FINANCIAL_ITEM_ID => L_FINANCIAL_ITEM_ID,
                  P_ACCOUNT_GROUP_ID  => L_ACCOUNT_GROUP_ID,
                  P_ACCOUNT_ID    => L_ACCOUNT_ID,
                  P_OBJECT_TYPE => L_OBJECT_TYPE);
           l_end_time := sysdate;

       IF (M_TOTAL_NUMBER_OF_PROCESSES IS NOT NULL OR
           M_TOTAL_NUMBER_OF_PROCESSES <> 0)
       THEN




        l_start_time := sysdate;

       M_PROCS_FOR_CERT_DONE := Get_Proc_Certified_Done(
       	 P_CERTIFICATION_ID => L_CERTIFICATION_ID,
                  P_FINANCIAL_STATEMENT_ID => L_FINANCIAL_STATEMENT_ID,
                  P_STATEMENT_GROUP_ID => L_STATEMENT_GROUP_ID ,
                  P_FINANCIAL_ITEM_ID => L_FINANCIAL_ITEM_ID,
                  P_ACCOUNT_GROUP_ID  => L_ACCOUNT_GROUP_ID,
                  P_ACCOUNT_ID    => P_ACCOUNT_ID,
                  P_OBJECT_TYPE => P_OBJECT_TYPE);

        l_end_time := sysdate;

           l_start_time := sysdate;
         M_PROC_VERIFIED := Get_Proc_Verified(
        	  P_CERTIFICATION_ID => L_CERTIFICATION_ID,
                  P_FINANCIAL_STATEMENT_ID => L_FINANCIAL_STATEMENT_ID,
                  P_STATEMENT_GROUP_ID => L_STATEMENT_GROUP_ID ,
                  P_FINANCIAL_ITEM_ID => L_FINANCIAL_ITEM_ID,
                  P_ACCOUNT_GROUP_ID  => L_ACCOUNT_GROUP_ID,
                  P_ACCOUNT_ID    => P_ACCOUNT_ID,
                  P_OBJECT_TYPE => P_OBJECT_TYPE );

        l_end_time := sysdate;


 M_PROC_PENDING_CERTIFICATION := M_TOTAL_NUMBER_OF_PROCESSES - M_PROCS_FOR_CERT_DONE ;

                    l_start_time := sysdate;
	-- CountProcswithIssues_finitem
	 M_PROC_CERTIFIED_WITH_ISSUES := Get_PROC_CERT_WITH_ISSUES(
        	  P_CERTIFICATION_ID => L_CERTIFICATION_ID,
                  P_FINANCIAL_STATEMENT_ID => L_FINANCIAL_STATEMENT_ID,
                  P_STATEMENT_GROUP_ID => L_STATEMENT_GROUP_ID ,
                  P_FINANCIAL_ITEM_ID => L_FINANCIAL_ITEM_ID,
                  P_ACCOUNT_GROUP_ID  => L_ACCOUNT_GROUP_ID,
                  P_ACCOUNT_ID    => P_ACCOUNT_ID,
                  P_OBJECT_TYPE => P_OBJECT_TYPE );


 	l_end_time := sysdate;



                       l_start_time := sysdate;
	--  CountOrgsIneffCtrl_finitem
	M_ORG_WITH_INEFFECTIVE_CTRLS :=  Get_ORG_WITH_INEFF_CTRLS(
        	  P_CERTIFICATION_ID => L_CERTIFICATION_ID,
                  P_FINANCIAL_STATEMENT_ID => L_FINANCIAL_STATEMENT_ID,
                  P_STATEMENT_GROUP_ID => L_STATEMENT_GROUP_ID ,
                  P_FINANCIAL_ITEM_ID => L_FINANCIAL_ITEM_ID,
                  P_ACCOUNT_GROUP_ID  => L_ACCOUNT_GROUP_ID,
                  P_ACCOUNT_ID    => P_ACCOUNT_ID,
                  P_OBJECT_TYPE => P_OBJECT_TYPE);

                   l_end_time := sysdate;


                     l_start_time := sysdate;
       --CountOrgsEvaluated_finitem
        M_ORG_EVALUATED := Get_ORG_EVALUATED (
        	  P_CERTIFICATION_ID => L_CERTIFICATION_ID,
                  P_FINANCIAL_STATEMENT_ID => L_FINANCIAL_STATEMENT_ID,
                  P_STATEMENT_GROUP_ID => L_STATEMENT_GROUP_ID ,
                  P_FINANCIAL_ITEM_ID => L_FINANCIAL_ITEM_ID,
                  P_ACCOUNT_GROUP_ID  => L_ACCOUNT_GROUP_ID,
                  P_ACCOUNT_ID    => P_ACCOUNT_ID,
                  P_OBJECT_TYPE => P_OBJECT_TYPE);

                  l_end_time := sysdate;

            M_TOTAL_ORGS := Get_TOTAL_ORGS (
        	  P_CERTIFICATION_ID => L_CERTIFICATION_ID,
                  P_FINANCIAL_STATEMENT_ID => L_FINANCIAL_STATEMENT_ID,
                  P_STATEMENT_GROUP_ID => L_STATEMENT_GROUP_ID ,
                  P_FINANCIAL_ITEM_ID => L_FINANCIAL_ITEM_ID,
                  P_ACCOUNT_GROUP_ID  => L_ACCOUNT_GROUP_ID,
                  P_ACCOUNT_ID    => P_ACCOUNT_ID,
                  P_OBJECT_TYPE => P_OBJECT_TYPE);


	 l_start_time := sysdate;
	--CountOrgsCertified_finitem
	M_ORG_CERTIFIED := Get_ORG_CERTIFIED (
        	  P_CERTIFICATION_ID => L_CERTIFICATION_ID,
                  P_FINANCIAL_STATEMENT_ID => L_FINANCIAL_STATEMENT_ID,
                  P_STATEMENT_GROUP_ID => L_STATEMENT_GROUP_ID ,
                  P_FINANCIAL_ITEM_ID => L_FINANCIAL_ITEM_ID,
                  P_ACCOUNT_GROUP_ID  => L_ACCOUNT_GROUP_ID,
                  P_ACCOUNT_ID    => P_ACCOUNT_ID,
                  P_OBJECT_TYPE => P_OBJECT_TYPE);

	 l_end_time := sysdate;

	 l_start_time := sysdate;
--OPEN CountProcsIneffCtrl_finitem
	M_PROC_WITH_INEFFECTIVE_CTRLS := Get_PROC_WITH_INEFF_CTRLS (
        	 P_CERTIFICATION_ID => L_CERTIFICATION_ID,
                  P_FINANCIAL_STATEMENT_ID => L_FINANCIAL_STATEMENT_ID,
                  P_STATEMENT_GROUP_ID => L_STATEMENT_GROUP_ID ,
                  P_FINANCIAL_ITEM_ID => L_FINANCIAL_ITEM_ID,
                  P_ACCOUNT_GROUP_ID  => L_ACCOUNT_GROUP_ID,
                  P_ACCOUNT_ID    => P_ACCOUNT_ID,
                  P_OBJECT_TYPE => P_OBJECT_TYPE);

	 l_end_time := sysdate;


 	 l_start_time := sysdate;
--OPEN CountIneffectiveCtrls_finitem
	M_INEFFECTIVE_CONTROLS := Get_INEFFECTIVE_CONTROLS (
        	  P_CERTIFICATION_ID => L_CERTIFICATION_ID,
                  P_FINANCIAL_STATEMENT_ID => L_FINANCIAL_STATEMENT_ID,
                  P_STATEMENT_GROUP_ID => L_STATEMENT_GROUP_ID ,
                  P_FINANCIAL_ITEM_ID => L_FINANCIAL_ITEM_ID,
                  P_ACCOUNT_GROUP_ID  => L_ACCOUNT_GROUP_ID,
                  P_ACCOUNT_ID    => P_ACCOUNT_ID,
                  P_OBJECT_TYPE => P_OBJECT_TYPE);

	 l_end_time := sysdate;


	 l_start_time := sysdate;
-- CountUnmittigatedRisk_finitem
M_UNMITIGATED_RISKS := Get_UNMITIGATED_RISKS (
        	  P_CERTIFICATION_ID => L_CERTIFICATION_ID,
                  P_FINANCIAL_STATEMENT_ID => L_FINANCIAL_STATEMENT_ID,
                  P_STATEMENT_GROUP_ID => L_STATEMENT_GROUP_ID ,
                  P_FINANCIAL_ITEM_ID => L_FINANCIAL_ITEM_ID,
                  P_ACCOUNT_GROUP_ID  => L_ACCOUNT_GROUP_ID,
                  P_ACCOUNT_ID    => P_ACCOUNT_ID,
                  P_OBJECT_TYPE => P_OBJECT_TYPE);

 	 l_end_time := sysdate;

            l_start_time := sysdate;
--  CountRisksVerified_finitem
M_RISKS_VERIFIED := Get_RISKS_VERIFIED(
        	  P_CERTIFICATION_ID => L_CERTIFICATION_ID,
                  P_FINANCIAL_STATEMENT_ID => L_FINANCIAL_STATEMENT_ID,
                  P_STATEMENT_GROUP_ID => L_STATEMENT_GROUP_ID ,
                  P_FINANCIAL_ITEM_ID => L_FINANCIAL_ITEM_ID,
                  P_ACCOUNT_GROUP_ID  => L_ACCOUNT_GROUP_ID,
                  P_ACCOUNT_ID    => P_ACCOUNT_ID,
                  P_OBJECT_TYPE => P_OBJECT_TYPE);

                   l_end_time := sysdate;


         M_TOTAL_RISKS := Get_Total_RISKS(
        	  P_CERTIFICATION_ID => L_CERTIFICATION_ID,
                  P_FINANCIAL_STATEMENT_ID => L_FINANCIAL_STATEMENT_ID,
                  P_STATEMENT_GROUP_ID => L_STATEMENT_GROUP_ID ,
                  P_FINANCIAL_ITEM_ID => L_FINANCIAL_ITEM_ID,
                  P_ACCOUNT_GROUP_ID  => L_ACCOUNT_GROUP_ID,
                  P_ACCOUNT_ID    => P_ACCOUNT_ID,
                  P_OBJECT_TYPE => P_OBJECT_TYPE);

 	 l_start_time := sysdate;
	M_CONTROLS_VERIFIED := Get_CONTROLS_VERIFIED(
        	  P_CERTIFICATION_ID => L_CERTIFICATION_ID,
                  P_FINANCIAL_STATEMENT_ID => L_FINANCIAL_STATEMENT_ID,
                  P_STATEMENT_GROUP_ID => L_STATEMENT_GROUP_ID ,
                  P_FINANCIAL_ITEM_ID => L_FINANCIAL_ITEM_ID,
                  P_ACCOUNT_GROUP_ID  => L_ACCOUNT_GROUP_ID,
                  P_ACCOUNT_ID    => P_ACCOUNT_ID,
                  P_OBJECT_TYPE => P_OBJECT_TYPE);

		  l_end_time := sysdate;


	M_TOTAL_CONTROLS := Get_TOTAL_CONTROLS(
        	  P_CERTIFICATION_ID => L_CERTIFICATION_ID,
                  P_FINANCIAL_STATEMENT_ID => L_FINANCIAL_STATEMENT_ID,
                  P_STATEMENT_GROUP_ID => L_STATEMENT_GROUP_ID ,
                  P_FINANCIAL_ITEM_ID => L_FINANCIAL_ITEM_ID,
                  P_ACCOUNT_GROUP_ID  => L_ACCOUNT_GROUP_ID,
                  P_ACCOUNT_ID    => P_ACCOUNT_ID,
                  P_OBJECT_TYPE => P_OBJECT_TYPE );


 END IF;  -- end of total process <>0


         -- insert a fin item record
               insert_fin_cert_eval_sum(
                X_FIN_CERTIFICATION_ID                       => P_CERTIFICATION_ID,
                X_FINANCIAL_STATEMENT_ID                     => P_FINANCIAL_STATEMENT_ID,
                X_FINANCIAL_ITEM_ID                          => P_FINANCIAL_ITEM_ID,
                X_ACCOUNT_GROUP_ID                           => P_ACCOUNT_GROUP_ID,
                X_NATURAL_ACCOUNT_ID                         => P_ACCOUNT_ID,
                X_OBJECT_TYPE                                => P_OBJECT_TYPE,
                X_PROC_PENDING_CERTIFICATION                 => M_PROC_PENDING_CERTIFICATION,
                X_TOTAL_NUMBER_OF_PROCESSES                  => M_TOTAL_NUMBER_OF_PROCESSES,
                X_PROC_CERTIFIED_WITH_ISSUES                 => M_PROC_CERTIFIED_WITH_ISSUES,
                X_PROCS_FOR_CERT_DONE                        => M_PROCS_FOR_CERT_DONE,
                x_proc_evaluated                             => M_PROC_VERIFIED,
                X_ORG_WITH_INEFFECTIVE_CTRLS                 => M_org_with_ineffective_ctrls,
                -- X_ORG_CERTIFIED                           => M_org_certified,
                x_orgs_FOR_CERT_DONE                         => M_org_certified,
                x_orgs_evaluated                             => M_org_evaluated,
                x_total_orgs		=>  M_total_orgs,
                X_PROC_WITH_INEFFECTIVE_CTRLS                => M_proc_with_ineffective_ctrls,
                X_UNMITIGATED_RISKS                          => M_unmitigated_risks,
                X_RISKS_VERIFIED                             => M_risks_verified,
                X_TOTAL_RISKS		=> M_total_risks,
                X_INEFFECTIVE_CONTROLS                       => M_ineffective_controls,
                X_CONTROLS_VERIFIED                          => M_controls_verified,
                X_TOTAL_CONTROLS     => M_total_controls,
                X_OPEN_ISSUES                                => M_open_issues,
                --X_PRO_PENDING_CERT_PRCNT                     => M_PRO_PENDING_CERT_PRCNT,
                --X_PROCESSES_WITH_ISSUES_PRCNT                => M_PROCESSES_WITH_ISSUES_PRCNT,
                --X_ORG_WITH_INEFF_CTRLS_PRCNT                 => M_ORG_WITH_INEFF_CTRLS_PRCNT,
                --X_PROC_WITH_INEFF_CTRLS_PRCNT                => M_PROC_WITH_INEFF_CTRLS_PRCNT,
                --X_UNMITIGATED_RISKS_PRCNT                    => M_UNMITIGATED_RISKS_PRCNT,
                --X_INEFFECTIVE_CTRLS_PRCNT                    => M_INEFFECTIVE_CONTROLS_PRCNT,
                X_PRO_PENDING_CERT_PRCNT                     => null,
                X_PROCESSES_WITH_ISSUES_PRCNT                => null,
                X_ORG_WITH_INEFF_CTRLS_PRCNT                 => null,
                X_PROC_WITH_INEFF_CTRLS_PRCNT                => null,
                X_UNMITIGATED_RISKS_PRCNT                    => null,
                X_INEFFECTIVE_CTRLS_PRCNT                    => null,
                X_OBJ_CONTEXT                                => NULL,
                --X_CREATED_BY                               => g_user_id,
                X_CREATED_BY                                 => 1,
                X_CREATION_DATE                              => SYSDATE,
                --X_LAST_UPDATED_BY                          => g_user_id,
                X_LAST_UPDATED_BY                            => 1,
                X_LAST_UPDATE_DATE                           => SYSDATE,
                --X_LAST_UPDATE_LOGIN                        => g_login_id,
                X_LAST_UPDATE_LOGIN                          => 1,
                X_SECURITY_GROUP_ID                          => NULL,
                X_OBJECT_VERSION_NUMBER                      => NULL,
                x_return_status    => l_return_status,
     		x_msg_count   => l_msg_count,
    		x_msg_data    => l_msg_data);

x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
       ROLLBACK TO compute_values_for_eval_sum;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;

END compute_values_for_eval_sum;

------------populate scorecard info  --------------------------------
/*******************************delete becuase loop is put into master proceudre ****************
PROCEDURE Populate_All_Cert_General_Sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
) IS
-- select all processes in scope for the certification
    CURSOR c_cert IS
        SELECT cert.CERTIFICATION_ID, period.start_date
          FROM AMW_CERTIFICATION_B cert, AMW_GL_PERIODS_V period
         WHERE cert.object_type = 'FIN_STMT' and cert.certification_period_name = period.period_name
           AND cert.certification_period_set_name = period.period_set_name
           and cert.CERTIFICATION_STATUS in ('ACTIVE', 'DRAFT');

CURSOR c_start_date IS
    	SELECT period.start_date
          FROM AMW_CERTIFICATION_B cert, AMW_GL_PERIODS_V period
         WHERE cert.object_type = 'FIN_STMT' and cert.certification_period_name = period.period_name
           AND cert.certification_period_set_name = period.period_set_name
           and cert.CERTIFICATION_STATUS in ('ACTIVE', 'DRAFT')
           AND cert.certification_id = p_certification_id;

    l_start_date DATE;
l_api_name           CONSTANT VARCHAR2(30) := 'Populate_All_Cert_General_Sum';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

SAVEPOINT Populate_All_Cert_General_Sum;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;


        OPEN c_start_date;
        FETCH c_start_date INTO l_start_date;
        CLOSE c_start_date;

   IF p_certification_id IS NOT NULL THEN

        IF l_start_date is not null THEN
            Populate_Cert_General_Sum
            (p_certification_id => p_certification_id,
             p_start_date => l_start_date,
             x_return_status    => l_return_status,
     	     x_msg_count   => l_msg_count,
    	     x_msg_data    => l_msg_data);
        END IF;

        ELSE
        FOR cert_rec IN c_cert LOOP
             exit when c_cert%notfound;

             IF l_start_date is not null THEN
            Populate_Cert_General_Sum
            (p_certification_id => cert_rec.certification_id,
             p_start_date => cert_rec.start_date,
             x_return_status    => l_return_status,
     	     x_msg_count   => l_msg_count,
    	     x_msg_data    => l_msg_data);
            END IF;

        END LOOP;
    END IF;


x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          IF c_cert%ISOPEN THEN
      	close c_cert;
      END IF;
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
          IF c_cert%ISOPEN THEN
      	close c_cert;
      END IF;
        ROLLBACK TO Populate_All_Cert_General_Sum;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;

END Populate_All_Cert_General_Sum;

***********************/


PROCEDURE  Populate_Cert_General_Sum(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id          IN    	NUMBER,
p_start_date		IN  	DATE,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
)
IS

         CURSOR new_risks_added IS
          SELECT count(1)
	  FROM AMW_RISK_ASSOCIATIONS
         WHERE association_creation_date >= (SELECT period.start_date
          FROM AMW_CERTIFICATION_B cert, AMW_GL_PERIODS_V period
         WHERE cert.object_type = 'FIN_STMT' and cert.certification_period_name = period.period_name
           AND cert.certification_period_set_name = period.period_set_name
           AND cert.certification_id = p_certification_id)
           AND object_type = 'PROCESS_FINCERT'
           AND pk1 = p_certification_id;



 CURSOR new_controls_added IS
    	SELECT count(1)
    	FROM AMW_CONTROL_ASSOCIATIONS
    	WHERE association_creation_date >= (SELECT period.start_date
          FROM AMW_CERTIFICATION_B cert, AMW_GL_PERIODS_V period
         WHERE cert.object_type = 'FIN_STMT' and cert.certification_period_name = period.period_name
           AND cert.certification_period_set_name = period.period_set_name
           AND cert.certification_id = p_certification_id)
    	and pk1 = p_certification_id
    	and object_type = 'RISK_FINCERT';


    CURSOR orgs_in_scope IS
        SELECT count(distinct fin.organization_id)
        FROM AMW_FIN_CERT_SCOPE fin
        where fin.FIN_CERTIFICATION_ID= p_certification_id;
--------------------------------------------------------------------------

    l_new_risks_added                	NUMBER;
    l_new_controls_added             	NUMBER;
    l_global_proc_not_certified      	NUMBER;
    l_global_proc_with_issue 	     	NUMBER;
    l_local_proc_not_certified 	     	NUMBER;
    l_local_proc_with_issue          	NUMBER;
    l_global_proc_ineff_ctrl NUMBER;
    l_local_proc_ineff_ctrl 	NUMBER;
    l_unmitigated_risks 		NUMBER;
    l_ineffective_controls 		NUMBER;
    l_orgs_in_scope			NUMBER;
    l_orgs_pending_in_scope		NUMBER;

    l_certification_id NUMBER ;

l_api_name           CONSTANT VARCHAR2(30) := 'Populate_Cert_General_Sum';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

SAVEPOINT Populate_Cert_General_Sum;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;


    l_certification_id := p_certification_id;

    --fnd_file.put_line (fnd_file.LOG, 'p_certification_id='||to_char(p_certification_id));
    --fnd_file.put_line(fnd_file.LOG, 'before new_risks_added :'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

    OPEN new_risks_added;
    FETCH new_risks_added INTO l_new_risks_added;
    CLOSE new_risks_added;

    --fnd_file.put_line(fnd_file.LOG, 'before new_controls_added :'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
    OPEN new_controls_added;
    FETCH new_controls_added INTO l_new_controls_added;
    CLOSE new_controls_added;

    --fnd_file.put_line(fnd_file.LOG, 'before orgs_in_scope :'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
    OPEN orgs_in_scope;
    FETCH orgs_in_scope INTO l_orgs_in_scope;
    CLOSE orgs_in_scope;


Get_global_proc_not_certified(p_certification_id => l_certification_id, x_global_proc_not_certified => l_global_proc_not_certified);
Get_local_proc_not_certified(p_certification_id => l_certification_id, x_local_proc_not_certified => l_local_proc_not_certified);

Get_global_proc_with_issue(p_certification_id => l_certification_id, x_global_proc_with_issue => l_global_proc_with_issue);
Get_local_proc_with_issue(p_certification_id => l_certification_id,
			  x_local_proc_with_issue => l_local_proc_with_issue);

Get_global_proc_ineff_ctrl(p_certification_id => l_certification_id,
				x_global_proc_ineff_ctrl => l_global_proc_ineff_ctrl);
Get_local_proc_ineff_ctrl(p_certification_id => l_certification_id,
			  x_local_proc_ineff_ctrl => l_local_proc_ineff_ctrl);

Get_unmitigated_risks(p_certification_id => l_certification_id,
 		      x_unmitigated_risks => l_unmitigated_risks);
Get_ineffective_controls(p_certification_id => l_certification_id,
 		         x_ineffective_controls => l_ineffective_controls);
Get_orgs_pending_in_scope(p_certification_id => l_certification_id,
 		         x_orgs_pending_in_scope => l_orgs_pending_in_scope);

    UPDATE  AMW_CERT_DASHBOARD_SUM
       SET NEW_RISKS_ADDED = l_new_risks_added,
           NEW_CONTROLS_ADDED = l_new_controls_added,
           PROCESSES_NOT_CERT = l_global_proc_not_certified,
           PROCESSES_CERT_ISSUES = l_global_proc_with_issue,
           ORG_PROCESS_NOT_CERT = l_local_proc_not_certified,
           ORG_PROCESS_CERT_ISSUES = l_local_proc_with_issue,
           PROC_INEFF_CONTROL = l_global_proc_ineff_ctrl,
           ORG_PROC_INEFF_CONTROL = l_local_proc_ineff_ctrl,
           UNMITIGATED_RISKS = l_unmitigated_risks,
           INEFFECTIVE_CONTROLS = l_ineffective_controls,
           ORGS_IN_SCOPE = l_orgs_in_scope,
           ORGS_PENDING_IN_SCOPE = l_orgs_pending_in_scope,
           PERIOD_START_DATE = p_start_date,
           LAST_UPDATE_DATE = sysdate,
           LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
	   LAST_UPDATE_LOGIN = fnd_global.conc_login_id
     WHERE certification_id = p_certification_id;

    IF (SQL%NOTFOUND) THEN
       INSERT INTO AMW_CERT_DASHBOARD_SUM (
	  CERTIFICATION_ID,
                  NEW_RISKS_ADDED,
                  NEW_CONTROLS_ADDED,
                  PROCESSES_NOT_CERT,
                  PROCESSES_CERT_ISSUES,
                  ORG_PROCESS_NOT_CERT,
                  ORG_PROCESS_CERT_ISSUES,
                  PROC_INEFF_CONTROL,
                  ORG_PROC_INEFF_CONTROL,
                  UNMITIGATED_RISKS,
                  INEFFECTIVE_CONTROLS,
                  ORGS_IN_SCOPE,
                  ORGS_PENDING_IN_SCOPE,
                  PERIOD_START_DATE,
	          CREATED_BY,
	          CREATION_DATE,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
	          LAST_UPDATE_LOGIN)
	SELECT p_certification_id,
       	       l_new_risks_added,
       	       l_new_controls_added,
       	       l_global_proc_not_certified,
       	       l_global_proc_with_issue,
       	       l_local_proc_not_certified,
       	       l_local_proc_with_issue,
	       l_global_proc_ineff_ctrl,
               l_local_proc_ineff_ctrl,
               l_unmitigated_risks,
               l_ineffective_controls,
               l_orgs_in_scope,
               l_orgs_pending_in_scope,
               p_start_date,
               FND_GLOBAL.USER_ID,
               SYSDATE,
               SYSDATE,
	       FND_GLOBAL.USER_ID,
	       FND_GLOBAL.USER_ID
	FROM  DUAL;
    END IF;

if(p_commit <> FND_API.g_false)
then commit;
end if;

x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
       ROLLBACK TO Populate_Cert_General_Sum;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;

END Populate_Cert_General_Sum;

PROCEDURE reset_amw_fin_cert_eval_sum(p_certification_id in number)
is
  begin

  SAVEPOINT reset_amw_fin_cert_eval_sum;

  if p_certification_id is not null then
   update amw_fin_cert_eval_sum
   set
   	LAST_UPDATE_DATE = sysdate,
   	last_updated_by = fnd_global.user_id,
   	last_update_login = fnd_global.conc_login_id,
      PROC_PENDING_CERTIFICATION = 0,
      TOTAL_NUMBER_OF_PROCESSES  =0,
      PROC_CERTIFIED_WITH_ISSUES =0,
      -- PROC_VERIFIED              =0 ,
      PROCS_FOR_CERT_DONE       =0 ,
      proc_evaluated            =0 ,
      org_with_ineffective_controls  =0,
      -- org_certified              =0,
      orgs_FOR_CERT_DONE             =0,
      orgs_evaluated                    =0,
      proc_with_ineffective_controls  =0,
      unmitigated_risks          =0,
      risks_verified             =0,
      ineffective_controls       =0,
      controls_verified          =0,
      open_issues                =0,
      PRO_PENDING_CERT_PRCNT =0,
      PROCESSES_WITH_ISSUES_PRCNT =0,
      ORG_WITH_INEFF_CONTROLS_PRCNT =0,
      PROC_WITH_INEFF_CONTROLS_PRCNT =0,
      UNMITIGATED_RISKS_PRCNT =0,
      INEFFECTIVE_CONTROLS_PRCNT =0,
       total_number_of_risks = 0,
      total_number_of_ctrls = 0,
      total_number_of_orgs = 0
      WHERE fin_certification_id = p_certification_id;
  else
    update amw_fin_cert_eval_sum
    set
      LAST_UPDATE_DATE = sysdate,
      last_updated_by = fnd_global.user_id,
      last_update_login = fnd_global.conc_login_id,
      PROC_PENDING_CERTIFICATION = 0,
      TOTAL_NUMBER_OF_PROCESSES  =0,
      PROC_CERTIFIED_WITH_ISSUES =0,
      --PROC_VERIFIED              =0 ,
       PROCS_FOR_CERT_DONE            =0 ,
     proc_evaluated                    =0 ,
      org_with_ineffective_controls  =0,
      -- org_certified              =0,
      orgs_FOR_CERT_DONE        =0,
      orgs_evaluated            =0,
      proc_with_ineffective_controls  =0,
      unmitigated_risks          =0,
      risks_verified             =0,
      ineffective_controls       =0,
      controls_verified          =0,
      open_issues                =0,
      PRO_PENDING_CERT_PRCNT =0,
      PROCESSES_WITH_ISSUES_PRCNT =0,
      ORG_WITH_INEFF_CONTROLS_PRCNT =0,
      PROC_WITH_INEFF_CONTROLS_PRCNT =0,
      UNMITIGATED_RISKS_PRCNT =0,
      INEFFECTIVE_CONTROLS_PRCNT =0,
       total_number_of_risks = 0,
      total_number_of_ctrls = 0,
      total_number_of_orgs = 0
      WHERE fin_certification_id IN
      (select certifcationb.CERTIFICATION_ID
       		FROM    AMW_CERTIFICATION_B certifcationb
       		where certifcationb.OBJECT_TYPE='FIN_STMT'
       		and certifcationb.CERTIFICATION_STATUS in ('ACTIVE', 'DRAFT'));
   end if;

END reset_amw_fin_cert_eval_sum;

PROCEDURE reset_amw_fin_proc_eval_sum(p_certification_id in number)
IS
BEGIN
SAVEPOINT reset_amw_fin_proc_eval_sum;

     IF(p_certification_id is not null) then
     	UPDATE  AMW_FIN_PROCESS_EVAL_SUM
       SET
       	   LAST_UPDATE_DATE = sysdate,
   	   last_updated_by = fnd_global.user_id,
   	   last_update_login = fnd_global.conc_login_id,
           CERT_OPINION_ID = 0,
           EVAL_OPINION_ID = 0,
           CERT_OPINION_LOG_ID = 0,
           EVAL_OPINION_LOG_ID = 0,
           UNMITIGATED_RISKS = 0,
           INEFFECTIVE_CONTROLS = 0,
           NUMBER_OF_SUB_PROCS_CERTIFIED = 0,
           TOTAL_NUMBER_OF_SUB_PROCS = 0,
           SUB_PROCS_CERTIFIED_PRCNT = 0,
           NUMBER_OF_ORG_PROCS_CERTIFIED = 0,
           TOTAL_NUMBER_OF_ORG_PROCS = 0,
           ORG_PROCS_CERTIFIED_PRCNT = 0,
           OPEN_FINDINGS = 0,
           risks_verified = 0,
           controls_verified = 0,
           total_number_of_risks = 0,
           total_number_of_ctrls = 0
     WHERE fin_certification_id = p_certification_id;
     ELSE
     	UPDATE  AMW_FIN_PROCESS_EVAL_SUM
        SET
           LAST_UPDATE_DATE = sysdate,
   	   last_updated_by = fnd_global.user_id,
   	   last_update_login = fnd_global.conc_login_id,
           CERT_OPINION_ID = 0,
           EVAL_OPINION_ID = 0,
           CERT_OPINION_LOG_ID = 0,
           EVAL_OPINION_LOG_ID = 0,
           UNMITIGATED_RISKS = 0,
           INEFFECTIVE_CONTROLS = 0,
           NUMBER_OF_SUB_PROCS_CERTIFIED = 0,
           TOTAL_NUMBER_OF_SUB_PROCS = 0,
           SUB_PROCS_CERTIFIED_PRCNT = 0,
           NUMBER_OF_ORG_PROCS_CERTIFIED = 0,
           TOTAL_NUMBER_OF_ORG_PROCS = 0,
           ORG_PROCS_CERTIFIED_PRCNT = 0,
           OPEN_FINDINGS = 0,
            risks_verified = 0,
           controls_verified = 0,
           total_number_of_risks = 0,
           total_number_of_ctrls = 0
      WHERE fin_certification_id IN
      (select
          certifcationb.CERTIFICATION_ID
       FROM    AMW_CERTIFICATION_B certifcationb
       where
           certifcationb.OBJECT_TYPE='FIN_STMT'
       and certifcationb.CERTIFICATION_STATUS in ('ACTIVE', 'DRAFT'));

    END IF;
END reset_amw_fin_proc_eval_sum;



PROCEDURE reset_amw_fin_org_eval_sum(p_certification_id in number)
IS
BEGIN
SAVEPOINT reset_amw_fin_org_eval_sum;

	IF p_certification_id is not null THEN
	UPDATE
	  AMW_FIN_ORG_EVAL_SUM
          SET
           LAST_UPDATE_DATE = sysdate,
   	   last_updated_by = fnd_global.user_id,
   	   last_update_login = fnd_global.conc_login_id,
           EVAL_OPINION_ID = 0,
           CERT_OPINION_LOG_ID = 0,
           CERT_OPINION_ID = 0,
           EVAL_OPINION_LOG_ID = 0,
           PROC_PENDING_CERTIFICATION = 0,
           TOTAL_NUMBER_OF_PROCS = 0,
           PROC_CERTIFIED_WITH_ISSUES = 0,
           PROC_VERIFIED = 0,
           PROC_WITH_INEFFECTIVE_CONTROLS = 0,
           UNMITIGATED_RISKS = 0,
           RISKS_VERIFIED = 0,
           INEFFECTIVE_CONTROLS = 0,
           CONTROLS_VERIFIED = 0,
           PROC_PENDING_CERT_PRCNT =0,
           PROCESSES_WITH_ISSUES_PRCNT =0,
           PROC_WITH_INEFF_CONTROLS_PRCNT = 0,
           UNMITIGATED_RISKS_PRCNT = 0,
           INEFFECTIVE_CONTROLS_PRCNT = 0,
           OPEN_FINDINGS = 0,
           total_number_of_risks = 0,
           total_number_of_ctrls = 0,
          proc_certified = 0
     WHERE fin_certification_id = p_certification_id;
     ELSE
       UPDATE  AMW_FIN_ORG_EVAL_SUM
          SET
          LAST_UPDATE_DATE = sysdate,
   	  last_updated_by = fnd_global.user_id,
   	  last_update_login = fnd_global.conc_login_id,
           EVAL_OPINION_ID = 0,
           CERT_OPINION_LOG_ID = 0,
           CERT_OPINION_ID = 0,
           EVAL_OPINION_LOG_ID = 0,
           PROC_PENDING_CERTIFICATION = 0,
           TOTAL_NUMBER_OF_PROCS = 0,
           PROC_CERTIFIED_WITH_ISSUES = 0,
           PROC_VERIFIED = 0,
           PROC_WITH_INEFFECTIVE_CONTROLS = 0,
           UNMITIGATED_RISKS = 0,
           RISKS_VERIFIED = 0,
           INEFFECTIVE_CONTROLS = 0,
           CONTROLS_VERIFIED = 0,
           PROC_PENDING_CERT_PRCNT =0,
           PROCESSES_WITH_ISSUES_PRCNT =0,
           PROC_WITH_INEFF_CONTROLS_PRCNT = 0,
           UNMITIGATED_RISKS_PRCNT = 0,
           INEFFECTIVE_CONTROLS_PRCNT = 0,
           OPEN_FINDINGS = 0,
           total_number_of_risks = 0,
          total_number_of_ctrls = 0,
          proc_certified = 0
      WHERE fin_certification_id IN
      (select
          certifcationb.CERTIFICATION_ID
       FROM    AMW_CERTIFICATION_B certifcationb
       where
           certifcationb.OBJECT_TYPE='FIN_STMT'
       and certifcationb.CERTIFICATION_STATUS in ('ACTIVE', 'DRAFT'));

      END IF;
END reset_amw_fin_org_eval_sum;

PROCEDURE reset_amw_cert_dashboard_sum(p_certification_id in number)
IS
BEGIN
SAVEPOINT reset_amw_cert_dashboard_sum;

	IF p_certification_id is not null THEN
	UPDATE  AMW_CERT_DASHBOARD_SUM
          SET
          LAST_UPDATE_DATE = sysdate,
   	  last_updated_by = fnd_global.user_id,
   	  last_update_login = fnd_global.conc_login_id,
           NEW_RISKS_ADDED = 0,
           NEW_CONTROLS_ADDED = 0,
           PROCESSES_NOT_CERT = 0,
           PROCESSES_CERT_ISSUES = 0,
           ORG_PROCESS_NOT_CERT = 0,
           ORG_PROCESS_CERT_ISSUES = 0,
           PROC_INEFF_CONTROL = 0,
           ORG_PROC_INEFF_CONTROL = 0,
           UNMITIGATED_RISKS = 0,
           INEFFECTIVE_CONTROLS = 0,
           ORGS_IN_SCOPE = 0,
           ORGS_PENDING_IN_SCOPE = 0,
           ORGS_PENDING_CERTIFICATION = 0
     WHERE certification_id = p_certification_id;
     ELSE
     	UPDATE  AMW_CERT_DASHBOARD_SUM
          SET
           LAST_UPDATE_DATE = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.conc_login_id,
           NEW_RISKS_ADDED = 0,
           NEW_CONTROLS_ADDED = 0,
           PROCESSES_NOT_CERT = 0,
           PROCESSES_CERT_ISSUES = 0,
           ORG_PROCESS_NOT_CERT = 0,
           ORG_PROCESS_CERT_ISSUES = 0,
           PROC_INEFF_CONTROL = 0,
           ORG_PROC_INEFF_CONTROL = 0,
           UNMITIGATED_RISKS = 0,
           INEFFECTIVE_CONTROLS = 0,
           ORGS_IN_SCOPE = 0,
           ORGS_PENDING_IN_SCOPE = 0,
           ORGS_PENDING_CERTIFICATION = 0
	WHERE certification_id IN
      		(select certifcationb.CERTIFICATION_ID
       		FROM    AMW_CERTIFICATION_B certifcationb
       		where certifcationb.OBJECT_TYPE='FIN_STMT'
       		and certifcationb.CERTIFICATION_STATUS in ('ACTIVE', 'DRAFT'));
       	END IF;

END reset_amw_cert_dashboard_sum;

PROCEDURE reset_fin_all(p_certification_id in number)
IS
	l_certification_id number ;
BEGIN
	SAVEPOINT reset_fin_all;

	l_certification_id := p_certification_id;

	reset_amw_fin_cert_eval_sum(l_certification_id);
	reset_amw_fin_proc_eval_sum(l_certification_id);
	reset_amw_fin_org_eval_sum(l_certification_id);
	reset_amw_cert_dashboard_sum(l_certification_id);

END reset_fin_all;

--******************************************************************************************************
/* ************************* Code to be executed for updating 4 financial certification summary tables
*************************** when business evevnt is rised on opinion changes
--******************************************************************************************************/
PROCEDURE RISK_EVALUATION_HANDLER(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_risk_id 	                 number,
 p_org_id number,
 p_process_id number,
 p_opinion_log_id number,
 x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2)
IS

---CURSOR TO GET ALL OF FINANCIAL ITEMS WHICH RELATE TO THIS RISK
CURSOR Get_all_items(l_risk_id number, l_org_id number, l_process_id number)IS
SELECT DISTINCT item.FIN_CERTIFICATION_ID, item.STATEMENT_GROUP_ID, item.FINANCIAL_STATEMENT_ID, item.FINANCIAL_ITEM_ID
FROM AMW_FIN_ITEM_ACC_RISK ITEM,
     AMW_CERTIFICATION_B cert
WHERE ITEM.RISK_ID = l_risk_id
AND  ITEM.ORGANIZATION_ID = l_org_id
AND  ITEM.PROCESS_ID = l_process_id
AND ITEM.FINANCIAL_ITEM_ID IS NOT NULL
AND  item.FIN_CERTIFICATION_ID = cert.CERTIFICATION_ID
AND  cert.CERTIFICATION_STATUS IN ('ACTIVE', 'DRAFT');

--CURSOR TO GET ALL OF ACCOUNTS WHICH RELATE TO THIS RISK
CURSOR 	Get_all_accts (l_risk_id number, l_org_id number, l_process_id number)IS
SELECT DISTINCT finitemAcc.fin_certification_id, finitemAcc.account_group_id, finitemAcc.natural_account_id
FROM AMW_FIN_ITEM_ACC_RISK finitemAcc,
     AMW_CERTIFICATION_B cert
WHERE finitemAcc.RISK_ID = l_risk_id
AND   finitemAcc.ORGANIZATION_ID = l_org_id
AND   finitemAcc.PROCESS_ID = l_process_id
AND finitemAcc.natural_account_id is not null
AND  finitemAcc.FIN_CERTIFICATION_ID = cert.CERTIFICATION_ID
AND  cert.CERTIFICATION_STATUS IN ('ACTIVE', 'DRAFT');

--CURSOR TO GET ALL OF FINANCIAL CERTIFICATION WHICH HAS PROCESSES THAT RELATES TO THIS RISK
CURSOR Get_all_fin_cert(l_org_id number, l_process_id number) IS
SELECT DISTINCT proc.FIN_CERTIFICATION_ID
FROM AMW_FIN_PROCESS_EVAL_SUM proc,
     AMW_CERTIFICATION_B cert
WHERE proc.organization_id = l_org_id
AND proc.PROCESS_ID = l_process_id
AND  proc.FIN_CERTIFICATION_ID = cert.CERTIFICATION_ID
AND  cert.CERTIFICATION_STATUS IN ('ACTIVE', 'DRAFT');

--CURSOR TO GET OLD EVAL OPINION ID
CURSOR Get_old_opinion_id(l_cert_id number, l_org_id number, l_process_id number) IS
SELECT PK4
FROM AMW_RISK_ASSOCIATIONS
WHERE OBJECT_TYPE = 'PROCESS_FINCERT'
AND PK1 = l_cert_id
AND PK2 = l_org_id
AND PK3 = l_process_id
AND RISK_ID = p_risk_id;


 CURSOR Get_Dashboard_Risk(l_cert_id NUMBER) IS
        SELECT UNMITIGATED_RISKS FROM AMW_CERT_DASHBOARD_SUM
          WHERE CERTIFICATION_ID = l_cert_id;

CURSOR Get_Process_Risk(l_cert_id NUMBER, l_org_id NUMBER, l_process_id NUMBER) IS
        SELECT UNMITIGATED_RISKS, RISKS_VERIFIED, TOTAL_NUMBER_OF_RISKS
        FROM AMW_FIN_PROCESS_EVAL_SUM
          WHERE FIN_CERTIFICATION_ID = l_cert_id
          AND ORGANIZATION_ID = l_org_id
          AND PROCESS_ID = l_process_id;

CURSOR Get_Org_Risk(l_cert_id NUMBER, l_org_id NUMBER) IS
        SELECT UNMITIGATED_RISKS, RISKS_VERIFIED, TOTAL_NUMBER_OF_RISKS
        FROM  AMW_FIN_ORG_EVAL_SUM
          WHERE FIN_CERTIFICATION_ID = l_cert_id
          AND ORGANIZATION_ID = l_org_id;

CURSOR Get_Item_Risk(l_cert_id NUMBER, l_stmt_id NUMBER, l_item_id NUMBER) IS
       SELECT UNMITIGATED_RISKS, RISKS_VERIFIED,  TOTAL_NUMBER_OF_RISKS
         FROM  AMW_FIN_CERT_EVAL_SUM
         WHERE FIN_CERTIFICATION_ID = l_cert_id
    AND FINANCIAL_STATEMENT_ID = l_stmt_id
    AND FINANCIAL_ITEM_ID = l_item_id
    AND OBJECT_TYPE = 'FINANCIAL ITEM';

CURSOR Get_Acct_Risk(l_cert_id NUMBER, l_acct_group_id NUMBER, l_acct_id NUMBER) IS
         SELECT UNMITIGATED_RISKS, RISKS_VERIFIED, TOTAL_NUMBER_OF_RISKS
         FROM  AMW_FIN_CERT_EVAL_SUM
       WHERE FIN_CERTIFICATION_ID = l_cert_id
       AND ACCOUNT_GROUP_ID = l_acct_group_id
       AND NATURAL_ACCOUNT_ID = l_acct_id
      AND OBJECT_TYPE = 'ACCOUNT';

M_dashboard_unmitigated_risks          number;

M_item_unmitigated_risks          number;
M_item_risks_verified             number;
M_item_risks_total	number;

M_acc_unmitigated_risks          number ;
M_acc_risks_verified             number ;
M_acc_risks_total            number ;

M_org_unmitigated_risks          number ;
M_org_risks_verified             number ;
M_org_risks_total            number ;

M_gen_unmitigated_risks          number ;


M_proc_unmitigated_risks          number ;
M_proc_risks_verified             number ;
M_proc_risks_total	number;


M_opinion_log_id AMW_OPINIONS_LOG.OPINION_LOG_ID%TYPE;

M_change_flag VARCHAR2(1);
M_new_flag VARCHAR2(1) := 'N';

l_api_name           CONSTANT VARCHAR2(30) := 'RISK_EVALUATION_HANDLER';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

SAVEPOINT RISK_EVALUATION_HANDLER;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;



FOR Get_all_items_Rec in Get_all_items(p_risk_id, p_org_id , p_process_id) LOOP
	 exit when Get_all_items %notfound;

    OPEN Get_old_opinion_id(Get_all_items_Rec.FIN_CERTIFICATION_ID, p_org_id, p_process_id);
    FETCH Get_old_opinion_id INTO M_opinion_log_id;
    CLOSE Get_old_opinion_id;

 M_item_unmitigated_risks := 0;
 M_item_risks_verified := 0;
 M_item_risks_total := 0;

   OPEN Get_Item_Risk(Get_all_items_Rec.FIN_CERTIFICATION_ID, Get_all_items_Rec.FINANCIAL_STATEMENT_ID,
   Get_all_items_Rec.FINANCIAL_ITEM_ID);
   FETCH Get_Item_Risk  INTO M_item_unmitigated_risks, M_item_risks_verified, M_item_risks_total;
   CLOSE Get_Item_Risk;

	 Is_Eval_Change(
    		old_opinion_log_id  => M_opinion_log_id,
    		new_opinion_log_id  =>  P_opinion_log_id,
    		x_change_flag	=> M_change_flag);

    IF(M_opinion_log_id = 0 OR M_opinion_log_id IS NULL) THEN  -- a new evaluation
    M_new_flag := 'Y';
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
*********IF(M_item_risks_verified + 1 > M_item_risks_total)                  ****/
 /********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(Get_all_items_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR (M_item_risks_verified + 1 <  M_item_risks_total)  )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_items_Rec.fin_certification_id) := Get_all_items_Rec.fin_certification_id;
ELSE
********/
UPDATE AMW_FIN_CERT_EVAL_SUM
        SET
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id,
        risks_verified = least(risks_verified + 1, total_number_of_risks)
        WHERE FIN_CERTIFICATION_ID = Get_all_items_Rec.FIN_CERTIFICATION_ID
        AND FINANCIAL_STATEMENT_ID = Get_all_items_Rec.FINANCIAL_STATEMENT_ID
        AND FINANCIAL_ITEM_ID = Get_all_items_Rec.FINANCIAL_ITEM_ID
        AND OBJECT_TYPE = 'FINANCIAL ITEM';
--END IF;   -- end of  if not
   END IF;  --enf of a new evaluation

 --- M_change_flag = 'F' and M_new_flag = 'N'  means the Opinion is changed from Ineffective to Efective
 --- M_change_flag = 'B' means the Opinion is changed from Efective to Ineffective

        IF (M_change_flag = 'F'  and M_new_flag = 'N') THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
*********(IF(M_item_unmitigated_risks -1  < 0) 		 *******************/
 /********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(Get_all_items_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR (M_item_unmitigated_risks -1  >  0)   )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_items_Rec.fin_certification_id) := Get_all_items_Rec.fin_certification_id;
ELSE
*************/
UPDATE AMW_FIN_CERT_EVAL_SUM
        SET
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id,
        unmitigated_risks = greatest(0, unmitigated_risks -1),
        unmitigated_risks_prcnt = round( (greatest(0, m_item_unmitigated_risks -1))/decode(nvl(m_item_risks_total, 0), 0, 1, m_item_risks_total), 2)*100
        WHERE FIN_CERTIFICATION_ID = Get_all_items_Rec.FIN_CERTIFICATION_ID
	AND FINANCIAL_STATEMENT_ID = Get_all_items_Rec.FINANCIAL_STATEMENT_ID
        AND FINANCIAL_ITEM_ID = Get_all_items_Rec.FINANCIAL_ITEM_ID
        AND OBJECT_TYPE = 'FINANCIAL ITEM';
--END IF;

        ELSIF (M_change_flag = 'B') THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
***********IF(M_item_unmitigated_risks + 1 > M_item_risks_verified)  ********************/
 /********* remove 'IF' logic now because the refresh logic is disabled temporarily
 IF NOT ( (m_certification_list.exists(Get_all_items_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR (M_item_unmitigated_risks + 1 < M_item_risks_verified)   )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_items_Rec.fin_certification_id) := Get_all_items_Rec.fin_certification_id;
ELSE
***********/
UPDATE AMW_FIN_CERT_EVAL_SUM
        SET
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id,
        unmitigated_risks = least(unmitigated_risks + 1,  risks_verified),
        unmitigated_risks_prcnt = round((least(m_item_unmitigated_risks + 1, risks_verified))/decode(nvl(m_item_risks_total, 0), 0, 1, m_item_risks_total), 2)*100
        WHERE FIN_CERTIFICATION_ID = Get_all_items_Rec.FIN_CERTIFICATION_ID
	AND FINANCIAL_STATEMENT_ID = Get_all_items_Rec.FINANCIAL_STATEMENT_ID
        AND FINANCIAL_ITEM_ID = Get_all_items_Rec.FINANCIAL_ITEM_ID
        AND OBJECT_TYPE = 'FINANCIAL ITEM';
--END IF;

        END IF;

        UPDATE AMW_FIN_ITEM_ACC_RISK
        SET
        LAST_UPDATE_DATE = sysdate,
   	last_updated_by = fnd_global.user_id,
   	last_update_login = fnd_global.conc_login_id,
   	OPINION_LOG_ID = P_opinion_log_id
         WHERE FIN_CERTIFICATION_ID = Get_all_items_Rec.FIN_CERTIFICATION_ID
	AND FINANCIAL_STATEMENT_ID = Get_all_items_Rec.FINANCIAL_STATEMENT_ID
        AND FINANCIAL_ITEM_ID = Get_all_items_Rec.FINANCIAL_ITEM_ID
        AND OBJECT_TYPE = 'FINANCIAL ITEM';


  END LOOP;

 FOR Get_all_accts_Rec IN Get_all_accts(p_risk_id, p_org_id , p_process_id) LOOP
           exit when Get_all_accts%notfound;

    OPEN Get_old_opinion_id(Get_all_accts_Rec.FIN_CERTIFICATION_ID, p_org_id, p_process_id);
    FETCH Get_old_opinion_id INTO M_opinion_log_id;
    CLOSE Get_old_opinion_id;


	  Is_Eval_Change(
    		old_opinion_log_id  => M_opinion_log_id,
    		new_opinion_log_id  =>  P_opinion_log_id,
    		x_change_flag	=> M_change_flag);


   OPEN Get_Acct_Risk(Get_all_accts_Rec.FIN_CERTIFICATION_ID, Get_all_accts_Rec.ACCOUNT_GROUP_ID,
   Get_all_accts_Rec.NATURAL_ACCOUNT_ID);
   FETCH Get_Acct_Risk  INTO M_acc_unmitigated_risks, M_acc_risks_verified, M_acc_risks_total;
   CLOSE Get_Acct_Risk;

   IF(M_opinion_log_id = 0 OR M_opinion_log_id IS NULL) THEN  -- a new evaluation
    M_new_flag := 'Y';
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********IF(M_acc_risks_verified + 1 > M_acc_risks_total) ***********************/
 /********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_accts_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y')  OR (M_acc_risks_verified + 1 < M_acc_risks_total)    )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_accts_Rec.fin_certification_id) := Get_all_accts_Rec.fin_certification_id;
ELSE
*************/
UPDATE AMW_FIN_CERT_EVAL_SUM
        SET
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id,
        risks_verified = least(risks_verified + 1, total_number_of_risks)
       WHERE FIN_CERTIFICATION_ID = Get_all_accts_Rec.FIN_CERTIFICATION_ID
	AND ACCOUNT_GROUP_ID = Get_all_accts_Rec.ACCOUNT_GROUP_ID
	AND NATURAL_ACCOUNT_ID = Get_all_accts_Rec.NATURAL_ACCOUNT_ID
        AND OBJECT_TYPE = 'ACCOUNT';
--END IF;
   END IF;

        IF(M_change_flag = 'F'  and M_new_flag = 'N') THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********    IF(M_acc_unmitigated_risks - 1 < 0 ) *******************************/
   /********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_accts_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR (M_acc_unmitigated_risks - 1 >  0 )     )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_accts_Rec.fin_certification_id) := Get_all_accts_Rec.fin_certification_id;
ELSE
**********/
 UPDATE AMW_FIN_CERT_EVAL_SUM
        SET
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id,
        unmitigated_risks = greatest(0, unmitigated_risks -1) ,
        unmitigated_risks_prcnt = round((greatest(0, m_acc_unmitigated_risks - 1))/ decode(nvl(m_acc_risks_total,0), 0,1, m_acc_risks_total), 2) * 100
        WHERE FIN_CERTIFICATION_ID = Get_all_accts_Rec.FIN_CERTIFICATION_ID
	AND ACCOUNT_GROUP_ID = Get_all_accts_Rec.ACCOUNT_GROUP_ID
	AND NATURAL_ACCOUNT_ID = Get_all_accts_Rec.NATURAL_ACCOUNT_ID
        AND OBJECT_TYPE = 'ACCOUNT';
--END IF;


        ELSIF (M_change_flag = 'B') THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********    IF( M_acc_unmitigated_risks + 1 > M_acc_risks_verified )  *******************************/
 /********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_accts_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y')  OR ( M_acc_unmitigated_risks + 1 < M_acc_risks_verified )      )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_accts_Rec.fin_certification_id) := Get_all_accts_Rec.fin_certification_id;
ELSE
***************/
UPDATE AMW_FIN_CERT_EVAL_SUM
        SET
        last_update_date = sysdate,
   	last_updated_by = fnd_global.user_id,
   	last_update_login = fnd_global.conc_login_id,
        unmitigated_risks = least(unmitigated_risks + 1 ,risks_verified),
        unmitigated_risks_prcnt = round((least(risks_verified, m_acc_unmitigated_risks + 1))/ decode(nvl(m_acc_risks_total,0), 0,1, m_acc_risks_total), 2) * 100
        WHERE FIN_CERTIFICATION_ID = Get_all_accts_Rec.FIN_CERTIFICATION_ID
	AND ACCOUNT_GROUP_ID = Get_all_accts_Rec.ACCOUNT_GROUP_ID
	AND NATURAL_ACCOUNT_ID = Get_all_accts_Rec.NATURAL_ACCOUNT_ID
        AND OBJECT_TYPE = 'ACCOUNT';
--END IF;
        END IF;

        UPDATE AMW_FIN_ITEM_ACC_RISK
        SET
        LAST_UPDATE_DATE = sysdate,
   	last_updated_by = fnd_global.user_id,
   	last_update_login = fnd_global.conc_login_id,
   	OPINION_LOG_ID = P_opinion_log_id
         WHERE FIN_CERTIFICATION_ID = Get_all_accts_Rec.FIN_CERTIFICATION_ID
	AND ACCOUNT_GROUP_ID = Get_all_accts_Rec.ACCOUNT_GROUP_ID
	AND NATURAL_ACCOUNT_ID = Get_all_accts_Rec.NATURAL_ACCOUNT_ID
        AND OBJECT_TYPE = 'ACCOUNT';


 END LOOP;


 ---modify the org, dashboard and process eval summary tables
 FOR Get_all_fin_cert_Rec IN Get_all_fin_cert(p_org_id , p_process_id) LOOP
           exit when Get_all_fin_cert%notfound;

    OPEN Get_old_opinion_id(Get_all_fin_cert_Rec.FIN_CERTIFICATION_ID, p_org_id, p_process_id);
    FETCH Get_old_opinion_id INTO M_opinion_log_id;
    CLOSE Get_old_opinion_id;

    OPEN Get_Dashboard_Risk(Get_all_fin_cert_Rec.fin_certification_id);
       FETCH Get_Dashboard_Risk INTO M_dashboard_unmitigated_risks;
       CLOSE Get_Dashboard_Risk;

      OPEN Get_Process_Risk(Get_all_fin_cert_Rec.fin_certification_id, p_org_id, p_process_id);
       FETCH Get_Process_Risk INTO M_proc_unmitigated_risks, M_proc_risks_verified, M_proc_risks_total;
       CLOSE Get_Process_Risk;

      OPEN Get_Org_Risk(Get_all_fin_cert_Rec.fin_certification_id, p_org_id);
       FETCH Get_Org_Risk INTO M_org_unmitigated_risks, M_org_risks_verified, M_org_risks_total;
       CLOSE Get_Org_Risk;

Is_Eval_Change(
    		old_opinion_log_id  => M_opinion_log_id,
    		new_opinion_log_id  =>  P_opinion_log_id,
    		x_change_flag	=> M_change_flag);


     IF(M_opinion_log_id = 0 OR M_opinion_log_id IS NULL) THEN  -- a new evaluation
     M_new_flag := 'Y';
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********   IF(M_proc_risks_verified + 1 > M_proc_risks_total) *******************************/
 /********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_fin_cert_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y')  OR (M_proc_risks_verified + 1 < M_proc_risks_total)   )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_fin_cert_Rec.fin_certification_id) := Get_all_fin_cert_Rec.fin_certification_id;
ELSE
************/
UPDATE AMW_FIN_PROCESS_EVAL_SUM
        SET
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id,
        risks_verified = least(risks_verified + 1,  total_number_of_risks)
        WHERE FIN_CERTIFICATION_ID = Get_all_fin_cert_Rec.fin_certification_id
  	AND ORGANIZATION_ID = p_org_id
  	AND PROCESS_ID = p_process_id;
-- END IF;
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********IF(M_org_risks_verified + 1 > M_org_risks_total) *******************************/
 /********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_fin_cert_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y')  OR(M_org_risks_verified + 1 <  M_org_risks_total)    )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_fin_cert_Rec.fin_certification_id) := Get_all_fin_cert_Rec.fin_certification_id;
ELSE
*********/
UPDATE AMW_FIN_ORG_EVAL_SUM
        SET
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id,
        risks_verified =  least(risks_verified + 1,  total_number_of_risks)
      WHERE FIN_CERTIFICATION_ID = Get_all_fin_cert_Rec.fin_certification_id
        	AND ORGANIZATION_ID = p_org_id;
--END IF;
   END IF;  -- end of a new evaluation

   IF(M_change_flag = 'F' and M_new_flag = 'N' ) THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********IF( M_dashboard_unmitigated_risks -1 < 0 ) *******************************/
 /********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_fin_cert_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR( M_dashboard_unmitigated_risks -1 > 0 )  )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_fin_cert_Rec.fin_certification_id) := Get_all_fin_cert_Rec.fin_certification_id;
ELSE
*************/
UPDATE AMW_CERT_DASHBOARD_SUM
 	SET
 	LAST_UPDATE_DATE = sysdate,
   	last_updated_by = fnd_global.user_id,
   	last_update_login = fnd_global.conc_login_id,
 	unmitigated_risks = greatest(0, unmitigated_risks -1 )
 	WHERE CERTIFICATION_ID = Get_all_fin_cert_Rec.fin_certification_id;
--END IF;
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********        IF(M_proc_unmitigated_risks -1 < 0 )    *******************************/
 /********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_fin_cert_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y')  OR(M_proc_unmitigated_risks -1 > 0 )  )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_fin_cert_Rec.fin_certification_id) := Get_all_fin_cert_Rec.fin_certification_id;
ELSE
************/
UPDATE AMW_FIN_PROCESS_EVAL_SUM
 	SET
 	LAST_UPDATE_DATE = sysdate,
   	last_updated_by = fnd_global.user_id,
   	last_update_login = fnd_global.conc_login_id,
 	UNMITIGATED_RISKS = UNMITIGATED_RISKS - 1
  	WHERE FIN_CERTIFICATION_ID = Get_all_fin_cert_Rec.fin_certification_id
  	AND ORGANIZATION_ID = p_org_id
  	AND PROCESS_ID = p_process_id;
--END IF;
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********        IF(M_org_unmitigated_risks -1 < 0 )   *******************************/
 /********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_fin_cert_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y')  OR(M_org_unmitigated_risks -1 > 0 )   )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_fin_cert_Rec.fin_certification_id) := Get_all_fin_cert_Rec.fin_certification_id;
ELSE
*********/
UPDATE AMW_FIN_ORG_EVAL_SUM
 	SET
 	last_update_date = sysdate,
   	last_updated_by = fnd_global.user_id,
   	last_update_login = fnd_global.conc_login_id,
 	unmitigated_risks = greatest(0, unmitigated_risks -1),
 	unmitigated_risks_prcnt = round((greatest(0, m_org_unmitigated_risks - 1))/decode(nvl(m_org_risks_total, 0), 0, 1, m_org_risks_total), 2)*100
 	WHERE FIN_CERTIFICATION_ID = Get_all_fin_cert_Rec.fin_certification_id
        	AND ORGANIZATION_ID = p_org_id;
-- END IF;
   ELSIF(M_change_flag = 'B') THEN
    	UPDATE AMW_CERT_DASHBOARD_SUM
    	SET
    	LAST_UPDATE_DATE = sysdate,
   	last_updated_by = fnd_global.user_id,
   	last_update_login = fnd_global.conc_login_id,
    	UNMITIGATED_RISKS = UNMITIGATED_RISKS + 1
 	WHERE CERTIFICATION_ID = Get_all_fin_cert_Rec.fin_certification_id;

/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********        IF(M_proc_unmitigated_risks + 1  >  M_proc_risks_verified ) *******************************/
 /********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_fin_cert_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y')  OR(M_proc_unmitigated_risks + 1  <   M_proc_risks_verified )  )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_fin_cert_Rec.fin_certification_id) := Get_all_fin_cert_Rec.fin_certification_id;
ELSE
************/
UPDATE AMW_FIN_PROCESS_EVAL_SUM
 	SET
 	last_update_date = sysdate,
   	last_updated_by = fnd_global.user_id,
   	last_update_login = fnd_global.conc_login_id,
 	unmitigated_risks = least(unmitigated_risks +1,  risks_verified)
  	WHERE FIN_CERTIFICATION_ID = Get_all_fin_cert_Rec.fin_certification_id
  	AND ORGANIZATION_ID = p_org_id
  	AND PROCESS_ID = p_process_id;
--END IF;
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********        IF(M_org_unmitigated_risks + 1  >  M_org_risks_verified )  *******************************/
 /********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(Get_all_fin_cert_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y')  OR(M_org_unmitigated_risks + 1  <  M_org_risks_verified )   )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_fin_cert_Rec.fin_certification_id) := Get_all_fin_cert_Rec.fin_certification_id;
ELSE
***************/
UPDATE AMW_FIN_ORG_EVAL_SUM
  	SET
  	last_update_date = sysdate,
   	last_updated_by = fnd_global.user_id,
   	last_update_login = fnd_global.conc_login_id,
  	unmitigated_risks = least(unmitigated_risks + 1,risks_verified),
  	unmitigated_risks_prcnt = round((least(m_org_unmitigated_risks + 1, risks_verified))/decode(nvl(m_org_risks_total, 0), 0, 1, m_org_risks_total), 2)*100
 	WHERE FIN_CERTIFICATION_ID = Get_all_fin_cert_Rec.fin_certification_id
        AND ORGANIZATION_ID = p_org_id;
--END IF;
  END IF;

END LOOP;


x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
       ROLLBACK TO RISK_EVALUATION_HANDLER;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;

END RISK_EVALUATION_HANDLER;

PROCEDURE CONTROL_EVALUATION_HANDLER(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_ctrl_id 		IN 	NUMBER,
p_org_id 		IN 	NUMBER,
p_opinion_log_id 	IN	NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
)
IS

---CURSOR TO GET ALL OF FINANCIAL ITEMS WHICH RELATE TO THIS CONTROL
CURSOR Get_all_items(l_control_id number, l_org_id number)IS
SELECT DISTINCT item.FIN_CERTIFICATION_ID, item.STATEMENT_GROUP_ID, item.FINANCIAL_STATEMENT_ID, item.FINANCIAL_ITEM_ID
FROM AMW_FIN_ITEM_ACC_CTRL ITEM,
     AMW_CERTIFICATION_B cert
WHERE ITEM.CONTROL_ID = l_control_id
AND  ITEM.ORGANIZATION_ID = l_org_id
AND  ITEM.FINANCIAL_ITEM_ID IS NOT NULL
AND  item.FIN_CERTIFICATION_ID = cert.CERTIFICATION_ID
AND  cert.CERTIFICATION_STATUS IN ('ACTIVE', 'DRAFT');

--CURSOR TO GET ALL OF ACCOUNTS WHICH RELATE TO THIS RISK
CURSOR 	Get_all_accts (l_control_id number, l_org_id number)IS
SELECT DISTINCT finitemAcc.fin_certification_id, finitemAcc.account_group_id, finitemAcc.natural_account_id
FROM AMW_FIN_ITEM_ACC_CTRL finitemAcc,
     AMW_CERTIFICATION_B cert
WHERE finitemAcc.CONTROL_ID = l_control_id
AND   finitemAcc.ORGANIZATION_ID = l_org_id
AND finitemAcc.natural_account_id is not null
AND  finitemAcc.FIN_CERTIFICATION_ID = cert.CERTIFICATION_ID
AND  cert.CERTIFICATION_STATUS IN ('ACTIVE', 'DRAFT');

--CURSOR TO GET ALL OF FINANCIAL CERTIFICATION WHICH HAS PROCESSES THAT RELATES TO THIS CONTROL
CURSOR Get_all_fin_cert(l_org_id number) IS
SELECT DISTINCT proc.FIN_CERTIFICATION_ID
FROM AMW_FIN_PROCESS_EVAL_SUM proc,
     AMW_CERTIFICATION_B cert
WHERE proc.organization_id = l_org_id
AND  proc.FIN_CERTIFICATION_ID = cert.CERTIFICATION_ID
AND  cert.CERTIFICATION_STATUS IN ('ACTIVE', 'DRAFT');

--CURSOR TO GET OLD EVAL OPINION ID
CURSOR Get_old_opinion_id(l_cert_id number, l_org_id number) IS
SELECT PK5
FROM AMW_CONTROL_ASSOCIATIONS
WHERE OBJECT_TYPE = 'RISK_FINCERT'
AND PK1 = l_cert_id
AND PK2 = l_org_id
AND CONTROL_ID = p_ctrl_id;

--Cursor to get old values
   CURSOR Get_Item_Ctrl(l_cert_id NUMBER, l_stmt_id NUMBER, l_item_id NUMBER) IS
       SELECT INEFFECTIVE_CONTROLS, CONTROLS_VERIFIED, TOTAL_NUMBER_OF_CTRLS
         FROM  AMW_FIN_CERT_EVAL_SUM
         WHERE FIN_CERTIFICATION_ID = l_cert_id
    AND FINANCIAL_STATEMENT_ID = l_stmt_id
    AND FINANCIAL_ITEM_ID = l_item_id
    AND OBJECT_TYPE = 'FINANCIAL ITEM';



    CURSOR Get_Acct_Ctrl(l_cert_id NUMBER, l_acct_group_id NUMBER, l_acct_id NUMBER) IS
     SELECT INEFFECTIVE_CONTROLS, CONTROLS_VERIFIED, TOTAL_NUMBER_OF_CTRLS
      FROM  AMW_FIN_CERT_EVAL_SUM
         WHERE FIN_CERTIFICATION_ID = l_cert_id
          AND ACCOUNT_GROUP_ID = l_acct_group_id
       AND NATURAL_ACCOUNT_ID = l_acct_id
      AND OBJECT_TYPE = 'ACCOUNT';

   CURSOR Get_Dashboard_Ctrl(l_cert_id NUMBER) IS
        SELECT INEFFECTIVE_CONTROLS FROM AMW_CERT_DASHBOARD_SUM
          WHERE CERTIFICATION_ID = l_cert_id;

 CURSOR Get_Org_Ctrl(l_cert_id NUMBER, l_org_id NUMBER) IS
        SELECT  INEFFECTIVE_CONTROLS, CONTROLS_VERIFIED, TOTAL_NUMBER_OF_CTRLS
        FROM  AMW_FIN_ORG_EVAL_SUM
          WHERE FIN_CERTIFICATION_ID = l_cert_id
          AND ORGANIZATION_ID = l_org_id;

CURSOR Get_Proc_Ctrl(l_cert_id NUMBER, l_org_id NUMBER) IS
        SELECT INEFFECTIVE_CONTROLS, CONTROLS_VERIFIED, TOTAL_NUMBER_OF_CTRLS
        FROM AMW_FIN_PROCESS_EVAL_SUM
          WHERE FIN_CERTIFICATION_ID = l_cert_id
          AND ORGANIZATION_ID = l_org_id;

M_item_ctrls_verified  number;
M_item_ineff_ctrls number;
M_item_ctrls_total number;

M_acc_ineff_ctrls  number;
M_acc_ctrls_verified number;
M_acc_ctrls_total number;

M_org_ineff_ctrls number;
M_org_ctrls_verified number;
M_org_ctrls_total number;

M_proc_ineff_ctrls number;
M_proc_ctrls_verified number;
M_proc_ctrls_total number;

M_dashboard_ineff_ctrls number;


M_opinion_log_id AMW_OPINIONS_LOG.OPINION_LOG_ID%TYPE;

/*****************************************
M_new_flag='Y', it's a new evaluation.
M_change_flag='F', it's from ineffective to effective.
M_change_flag='B', it's from effective to ineffective
******************************************/

M_change_flag VARCHAR2(1);
M_new_flag VARCHAR2(1) := 'N';

l_api_name           CONSTANT VARCHAR2(30) := 'CONTROL_EVALUATION_HANDLER';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

SAVEPOINT CONTROL_EVALUATION_HANDLER;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;



FOR Get_all_items_Rec in Get_all_items(p_ctrl_id, p_org_id) LOOP
	 exit when Get_all_items %notfound;

    OPEN Get_old_opinion_id(Get_all_items_Rec.FIN_CERTIFICATION_ID, p_org_id);
    FETCH Get_old_opinion_id INTO M_opinion_log_id;
    CLOSE Get_old_opinion_id;

   M_item_ineff_ctrls := 0;
   M_item_ctrls_verified := 0;
   M_item_ctrls_total := 0;

   OPEN Get_Item_Ctrl(Get_all_items_Rec.FIN_CERTIFICATION_ID, Get_all_items_Rec.FINANCIAL_STATEMENT_ID,
   Get_all_items_Rec.FINANCIAL_ITEM_ID);
   FETCH Get_Item_Ctrl  INTO M_item_ineff_ctrls, M_item_ctrls_verified, M_item_ctrls_total;
   CLOSE Get_Item_Ctrl;

    Is_Eval_Change(
    		old_opinion_log_id  => M_opinion_log_id,
    		new_opinion_log_id  =>  P_opinion_log_id,
    		x_change_flag	=> M_change_flag);


IF ((M_opinion_log_id IS NULL) OR (M_opinion_log_id = 0)) THEN -- a new evaluation
    M_new_flag := 'Y';
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********      (M_item_ctrls_verified + 1 > M_item_ctrls_total)     *******************************/
 /********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_items_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y')  OR(M_item_ctrls_verified + 1 < M_item_ctrls_total)   )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_items_Rec.fin_certification_id) := Get_all_items_Rec.fin_certification_id;
ELSE
*************/
UPDATE AMW_FIN_CERT_EVAL_SUM
        SET
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id,
        controls_verified = least(controls_verified + 1, total_number_of_ctrls)
        WHERE FIN_CERTIFICATION_ID = Get_all_items_Rec.FIN_CERTIFICATION_ID
	AND FINANCIAL_STATEMENT_ID = Get_all_items_Rec.FINANCIAL_STATEMENT_ID
        AND FINANCIAL_ITEM_ID = get_all_items_rec.FINANCIAL_ITEM_ID
        AND OBJECT_TYPE = 'FINANCIAL ITEM';
--END IF;
       END IF;

        IF (M_change_flag = 'F' ) AND (M_new_flag = 'N') THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********      (M_item_ineff_ctrls  - 1 < 0 )      *******************************/
 /********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_items_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y')  OR(M_item_ineff_ctrls  - 1 > 0 )    )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_items_Rec.fin_certification_id) := Get_all_items_Rec.fin_certification_id;
ELSE
*************/
        UPDATE AMW_FIN_CERT_EVAL_SUM
        SET
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id,
        ineffective_controls = greatest(0, ineffective_controls -1),
        ineffective_controls_prcnt = round( (greatest(0, m_item_ineff_ctrls -1))/decode(nvl(m_item_ctrls_total, 0), 0, 1, m_item_ctrls_total), 2)*100
        WHERE FIN_CERTIFICATION_ID = Get_all_items_Rec.FIN_CERTIFICATION_ID
	AND FINANCIAL_STATEMENT_ID = Get_all_items_Rec.FINANCIAL_STATEMENT_ID
        AND FINANCIAL_ITEM_ID = Get_all_items_Rec.FINANCIAL_ITEM_ID
        AND OBJECT_TYPE = 'FINANCIAL ITEM';
--END IF;

        ELSIF (M_change_flag = 'B') THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********    ( M_item_ineff_ctrls  + 1 > M_item_ctrls_verified)     *******************************/
 /********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_items_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y')  OR( M_item_ineff_ctrls  + 1 < M_item_ctrls_verified)    )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_items_Rec.fin_certification_id) := Get_all_items_Rec.fin_certification_id;
ELSE
*************/
UPDATE AMW_FIN_CERT_EVAL_SUM
        SET
        last_update_date = sysdate,
   	last_updated_by = fnd_global.user_id,
   	last_update_login = fnd_global.conc_login_id,
        ineffective_controls = least(ineffective_controls + 1,  controls_verified),
        ineffective_controls_prcnt = round( (least(m_item_ineff_ctrls + 1, controls_verified))/decode(nvl(m_item_ctrls_total, 0), 0, 1, m_item_ctrls_total), 2)*100
        WHERE FIN_CERTIFICATION_ID = Get_all_items_Rec.FIN_CERTIFICATION_ID
	AND FINANCIAL_STATEMENT_ID = Get_all_items_Rec.FINANCIAL_STATEMENT_ID
        AND FINANCIAL_ITEM_ID = Get_all_items_Rec.FINANCIAL_ITEM_ID
        AND OBJECT_TYPE = 'FINANCIAL ITEM';
--END IF;
        END IF;

         amw_fin_coso_views_pvt.Update_item_ctrl_components (
	P_CERTIFICATION_ID => Get_all_items_Rec.FIN_CERTIFICATION_ID,
                  P_FINANCIAL_STATEMENT_ID =>  Get_all_items_Rec.FINANCIAL_STATEMENT_ID,
                  P_STATEMENT_GROUP_ID => Get_all_items_Rec.STATEMENT_GROUP_ID,
                  P_FINANCIAL_ITEM_ID => Get_all_items_Rec.FINANCIAL_ITEM_ID,
                  P_CONTROL_ID   => p_ctrl_id,
                  P_ORG_ID  => p_org_id,
                  P_CHANGE_FLAG => M_change_flag,
                  P_NEW_FLAG => M_new_flag) ;

        amw_fin_coso_views_pvt.Update_item_ctrl_Assertions (
                  P_CERTIFICATION_ID => Get_all_items_Rec.FIN_CERTIFICATION_ID,
                  P_FINANCIAL_STATEMENT_ID =>  Get_all_items_Rec.FINANCIAL_STATEMENT_ID,
                  P_STATEMENT_GROUP_ID => Get_all_items_Rec.STATEMENT_GROUP_ID,
                  P_FINANCIAL_ITEM_ID => Get_all_items_Rec.FINANCIAL_ITEM_ID,
                  P_CONTROL_ID   => p_ctrl_id,
                  P_ORG_ID  => p_org_id,
                  P_CHANGE_FLAG => M_change_flag,
                  P_NEW_FLAG => M_new_flag) ;

        amw_fin_coso_views_pvt.Update_item_ctrl_objectives(
		  P_CERTIFICATION_ID => Get_all_items_Rec.FIN_CERTIFICATION_ID,
                  P_FINANCIAL_STATEMENT_ID =>  Get_all_items_Rec.FINANCIAL_STATEMENT_ID,
                  P_STATEMENT_GROUP_ID => Get_all_items_Rec.STATEMENT_GROUP_ID,
                  P_FINANCIAL_ITEM_ID => Get_all_items_Rec.FINANCIAL_ITEM_ID,
                  P_CONTROL_ID   => p_ctrl_id,
                  P_ORG_ID  => p_org_id,
                  P_CHANGE_FLAG => M_change_flag,
                  P_NEW_FLAG => M_new_flag) ;

                  UPDATE AMW_FIN_ITEM_ACC_CTRL
                  SET
       	 LAST_UPDATE_DATE = sysdate,
   	last_updated_by = fnd_global.user_id,
   	last_update_login = fnd_global.conc_login_id,
       	OPINION_LOG_ID = P_opinion_log_id
       WHERE FIN_CERTIFICATION_ID = Get_all_items_Rec.FIN_CERTIFICATION_ID
	AND FINANCIAL_STATEMENT_ID = Get_all_items_Rec.FINANCIAL_STATEMENT_ID
        AND FINANCIAL_ITEM_ID = Get_all_items_Rec.FINANCIAL_ITEM_ID
        AND OBJECT_TYPE = 'FINANCIAL ITEM';


  END LOOP;

 FOR Get_all_accts_Rec IN Get_all_accts(p_ctrl_id, p_org_id) LOOP
           exit when Get_all_accts%notfound;

    OPEN Get_old_opinion_id(Get_all_accts_Rec.FIN_CERTIFICATION_ID, p_org_id);
    FETCH Get_old_opinion_id INTO M_opinion_log_id;
    CLOSE Get_old_opinion_id;

    M_acc_ineff_ctrls := 0;
    M_acc_ctrls_verified := 0;
    M_acc_ctrls_total := 0;

   OPEN Get_Acct_Ctrl(Get_all_accts_Rec.FIN_CERTIFICATION_ID, Get_all_accts_Rec.ACCOUNT_GROUP_ID,
   Get_all_accts_Rec.NATURAL_ACCOUNT_ID);
   FETCH Get_Acct_Ctrl  INTO M_acc_ineff_ctrls, M_acc_ctrls_verified, M_acc_ctrls_total;
   CLOSE Get_Acct_Ctrl;

     Is_Eval_Change(
    		old_opinion_log_id  => M_opinion_log_id,
    		new_opinion_log_id  =>  P_opinion_log_id,
    		x_change_flag	=> M_change_flag);


   IF ((M_opinion_log_id IS NULL) OR (M_opinion_log_id = 0)) THEN -- a new evaluation
    M_new_flag := 'Y';
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********    (M_acc_ctrls_verified + 1 > M_acc_ctrls_total)     *******************************/
 /********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_accts_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR(M_acc_ctrls_verified + 1 <  M_acc_ctrls_total)    )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_accts_Rec.fin_certification_id) := Get_all_accts_Rec.fin_certification_id;
ELSE
************/
        UPDATE AMW_FIN_CERT_EVAL_SUM
        SET
        last_update_date = sysdate,
       last_updated_by = fnd_global.user_id,
       last_update_login = fnd_global.conc_login_id,
        controls_verified = least(controls_verified + 1, total_number_of_ctrls )
         WHERE FIN_CERTIFICATION_ID = Get_all_accts_Rec.FIN_CERTIFICATION_ID
	AND ACCOUNT_GROUP_ID = Get_all_accts_Rec.ACCOUNT_GROUP_ID
	AND NATURAL_ACCOUNT_ID = Get_all_accts_Rec.NATURAL_ACCOUNT_ID
        AND OBJECT_TYPE = 'ACCOUNT';
--END IF;
        END IF;

        IF(M_change_flag = 'F' ) AND (M_new_flag = 'N') THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********   (M_acc_ineff_ctrls - 1 < 0 )     *******************************/
 /********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_accts_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR (M_acc_ineff_ctrls - 1 >  0 )   )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_accts_Rec.fin_certification_id) := Get_all_accts_Rec.fin_certification_id;
ELSE
****************/
UPDATE AMW_FIN_CERT_EVAL_SUM
        SET
        last_update_date = sysdate,
   	last_updated_by = fnd_global.user_id,
   	last_update_login = fnd_global.conc_login_id,
        ineffective_controls = greatest(0, ineffective_controls - 1),
        ineffective_controls_prcnt = round( (greatest(0, m_acc_ineff_ctrls - 1))/decode(nvl(m_acc_ctrls_total, 0), 0, 1, m_acc_ctrls_total), 2)*100
        WHERE FIN_CERTIFICATION_ID = Get_all_accts_Rec.FIN_CERTIFICATION_ID
	AND ACCOUNT_GROUP_ID = Get_all_accts_Rec.ACCOUNT_GROUP_ID
	AND NATURAL_ACCOUNT_ID = Get_all_accts_Rec.NATURAL_ACCOUNT_ID
        AND OBJECT_TYPE = 'ACCOUNT';
--END IF;

        ELSIF (M_change_flag = 'B') THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********   IF(M_acc_ineff_ctrls  + 1 >  M_acc_ctrls_verified)    *******************************/
  /********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_accts_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR (M_acc_ineff_ctrls  + 1 <  M_acc_ctrls_verified)   )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_accts_Rec.fin_certification_id) := Get_all_accts_Rec.fin_certification_id;
ELSE
***********/
 UPDATE AMW_FIN_CERT_EVAL_SUM
        SET
        last_update_date = sysdate,
   	last_updated_by = fnd_global.user_id,
   	last_update_login = fnd_global.conc_login_id,
        ineffective_controls = least(ineffective_controls + 1, controls_verified),
        ineffective_controls_prcnt = round( (least(m_acc_ineff_ctrls + 1, controls_verified)) /decode(nvl(m_acc_ctrls_total, 0), 0, 1, m_acc_ctrls_total), 2)*100
        WHERE FIN_CERTIFICATION_ID = Get_all_accts_Rec.FIN_CERTIFICATION_ID
	AND ACCOUNT_GROUP_ID = Get_all_accts_Rec.ACCOUNT_GROUP_ID
	AND NATURAL_ACCOUNT_ID = Get_all_accts_Rec.NATURAL_ACCOUNT_ID
        AND OBJECT_TYPE = 'ACCOUNT';
--END IF;
        END IF;


        amw_fin_coso_views_pvt.Update_acc_ctrl_components (
        	  P_CERTIFICATION_ID => Get_all_accts_Rec.FIN_CERTIFICATION_ID,
                  P_ACCOUNT_GROUP_ID  => Get_all_accts_Rec.ACCOUNT_GROUP_ID,
                  P_ACCOUNT_ID   => Get_all_accts_Rec.NATURAL_ACCOUNT_ID,
                  P_CONTROL_ID   => p_ctrl_id,
                  P_ORG_ID  => p_org_id ,
                  P_CHANGE_FLAG => M_change_flag,
                  P_NEW_FLAG  => M_new_flag);

        amw_fin_coso_views_pvt.Update_acc_ctrl_Assertions (
                  P_CERTIFICATION_ID => Get_all_accts_Rec.FIN_CERTIFICATION_ID,
                  P_ACCOUNT_GROUP_ID  => Get_all_accts_Rec.ACCOUNT_GROUP_ID,
                  P_ACCOUNT_ID   => Get_all_accts_Rec.NATURAL_ACCOUNT_ID,
                  P_CONTROL_ID   => p_ctrl_id,
                  P_ORG_ID  => p_org_id ,
                  P_CHANGE_FLAG => M_change_flag,
                  P_NEW_FLAG  => M_new_flag);

        amw_fin_coso_views_pvt.Update_acc_ctrl_objectives (
        	 P_CERTIFICATION_ID => Get_all_accts_Rec.FIN_CERTIFICATION_ID,
                  P_ACCOUNT_GROUP_ID  => Get_all_accts_Rec.ACCOUNT_GROUP_ID,
                  P_ACCOUNT_ID   => Get_all_accts_Rec.NATURAL_ACCOUNT_ID,
                  P_CONTROL_ID   => p_ctrl_id,
                  P_ORG_ID  => p_org_id ,
                  P_CHANGE_FLAG => M_change_flag,
                  P_NEW_FLAG  => M_new_flag);

                    UPDATE AMW_FIN_ITEM_ACC_CTRL
                  SET
       	 LAST_UPDATE_DATE = sysdate,
   	last_updated_by = fnd_global.user_id,
   	last_update_login = fnd_global.conc_login_id,
       	OPINION_LOG_ID = P_opinion_log_id
      WHERE FIN_CERTIFICATION_ID = Get_all_accts_Rec.FIN_CERTIFICATION_ID
	AND ACCOUNT_GROUP_ID = Get_all_accts_Rec.ACCOUNT_GROUP_ID
	AND NATURAL_ACCOUNT_ID = Get_all_accts_Rec.NATURAL_ACCOUNT_ID
        AND OBJECT_TYPE = 'ACCOUNT';

 END LOOP;


 ---modify the org, dashboard and process eval summary tables
 FOR Get_all_fin_cert_Rec IN Get_all_fin_cert(p_org_id) LOOP
           exit when Get_all_fin_cert%notfound;

    OPEN Get_old_opinion_id(Get_all_fin_cert_Rec.FIN_CERTIFICATION_ID, p_org_id);
    FETCH Get_old_opinion_id INTO M_opinion_log_id;
    CLOSE Get_old_opinion_id;

   OPEN Get_Org_Ctrl(Get_all_fin_cert_Rec.FIN_CERTIFICATION_ID, p_org_id);
   FETCH Get_Org_Ctrl  INTO M_org_ineff_ctrls, M_org_ctrls_verified, M_org_ctrls_total;
   CLOSE Get_Org_Ctrl;

   OPEN Get_Dashboard_Ctrl(Get_all_fin_cert_Rec.fin_certification_id);
   FETCH Get_Dashboard_Ctrl  INTO M_dashboard_ineff_ctrls;
   CLOSE Get_Dashboard_Ctrl;

   OPEN Get_Proc_Ctrl(Get_all_fin_cert_Rec.fin_certification_id, p_org_id);
   FETCH Get_Proc_Ctrl  INTO M_proc_ineff_ctrls, M_proc_ctrls_verified, M_proc_ctrls_total;
   CLOSE Get_Proc_Ctrl;

	  Is_Eval_Change(
    		old_opinion_log_id  => M_opinion_log_id,
    		new_opinion_log_id  =>  P_opinion_log_id,
    		x_change_flag	=> M_change_flag);


 IF ((M_opinion_log_id IS NULL) OR (M_opinion_log_id = 0)) THEN -- a new evaluation
    M_new_flag := 'Y';
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********   IF(M_proc_ctrls_verified + 1 > M_proc_ctrls_total)    *******************************/
 /********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_fin_cert_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR (M_proc_ctrls_verified + 1 < M_proc_ctrls_total)   )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_fin_cert_Rec.fin_certification_id) := Get_all_fin_cert_Rec.fin_certification_id;
ELSE
*************/
      UPDATE AMW_FIN_PROCESS_EVAL_SUM
 	SET
 	last_update_date = sysdate,
   	last_updated_by = fnd_global.user_id,
   	last_update_login = fnd_global.conc_login_id,
 	controls_verified = least(controls_verified + 1, total_number_of_ctrls )
  	WHERE FIN_CERTIFICATION_ID = get_all_fin_cert_rec.fin_certification_id
  	AND ORGANIZATION_ID = p_org_id;
--END IF;

/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********  (M_org_ctrls_verified + 1 > M_org_ctrls_total)    *******************************/
 /********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_fin_cert_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR (M_org_ctrls_verified + 1 < M_org_ctrls_total)   )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_fin_cert_Rec.fin_certification_id) := Get_all_fin_cert_Rec.fin_certification_id;
ELSE
***********/
UPDATE AMW_FIN_ORG_EVAL_SUM
 	SET
 	LAST_UPDATE_DATE = sysdate,
   	last_updated_by = fnd_global.user_id,
   	last_update_login = fnd_global.conc_login_id,
 	controls_verified = least(controls_verified + 1, total_number_of_ctrls )
  	WHERE FIN_CERTIFICATION_ID = get_all_fin_cert_rec.fin_certification_id
  	AND ORGANIZATION_ID = p_org_id;
--END IF;

END IF;

   IF(M_change_flag = 'F' ) AND (M_new_flag = 'N') THEN

/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********  (M_dashboard_ineff_ctrls -1 < 0 )     *******************************/
  /********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_fin_cert_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR (M_dashboard_ineff_ctrls -1 > 0 )    )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_fin_cert_Rec.fin_certification_id) := Get_all_fin_cert_Rec.fin_certification_id;
ELSE
*****************/
UPDATE AMW_CERT_DASHBOARD_SUM
 	SET
 	LAST_UPDATE_DATE = sysdate,
   	last_updated_by = fnd_global.user_id,
   	last_update_login = fnd_global.conc_login_id,
 	ineffective_controls = greatest(0, ineffective_controls - 1)
 	WHERE CERTIFICATION_ID = Get_all_fin_cert_Rec.fin_certification_id;
-- END IF;

 /********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********  (M_proc_ineff_ctrls -1 < 0 )     *******************************/
 /********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_fin_cert_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR (M_proc_ineff_ctrls -1 > 0 )   )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_fin_cert_Rec.fin_certification_id) := Get_all_fin_cert_Rec.fin_certification_id;
ELSE
************/
UPDATE AMW_FIN_PROCESS_EVAL_SUM
 	SET
 	LAST_UPDATE_DATE = sysdate,
   	last_updated_by = fnd_global.user_id,
   	last_update_login = fnd_global.conc_login_id,
	ineffective_controls = greatest(0, ineffective_controls - 1)
  	WHERE FIN_CERTIFICATION_ID = Get_all_fin_cert_Rec.fin_certification_id
  	AND ORGANIZATION_ID = p_org_id;
--END IF;

 /********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********  (M_org_ineff_ctrls - 1  < 0 )      *******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_fin_cert_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR (M_org_ineff_ctrls - 1  > 0 )    )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_fin_cert_Rec.fin_certification_id) := Get_all_fin_cert_Rec.fin_certification_id;
ELSE
************/
UPDATE AMW_FIN_ORG_EVAL_SUM
 	SET
 	last_update_date = sysdate,
   	last_updated_by = fnd_global.user_id,
   	last_update_login = fnd_global.conc_login_id,
 	ineffective_controls = greatest(0, ineffective_controls - 1),
       	 ineffective_controls_prcnt = round( (greatest(0, m_org_ineff_ctrls - 1))/decode(nvl(m_org_ctrls_total, 0), 0, 1, m_org_ctrls_total), 2)*100
 	WHERE FIN_CERTIFICATION_ID = Get_all_fin_cert_Rec.fin_certification_id
        AND ORGANIZATION_ID = p_org_id;
-- END IF;

   ELSIF(M_change_flag = 'B') THEN

    	UPDATE AMW_CERT_DASHBOARD_SUM
    	SET
    	last_update_date = sysdate,
   	last_updated_by = fnd_global.user_id,
   	last_update_login = fnd_global.conc_login_id,
    	ineffective_controls = ineffective_controls + 1
 	WHERE CERTIFICATION_ID = Get_all_fin_cert_Rec.fin_certification_id;

/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
********** (M_org_ineff_ctrls +  1  >  M_org_ctrls_verified )     *******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_fin_cert_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR(M_org_ineff_ctrls +  1  <  M_org_ctrls_verified )    )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_fin_cert_Rec.fin_certification_id) := Get_all_fin_cert_Rec.fin_certification_id;
ELSE
***********/
 UPDATE AMW_FIN_ORG_EVAL_SUM
  	SET
  	last_update_date = sysdate,
   	last_updated_by = fnd_global.user_id,
   	last_update_login = fnd_global.conc_login_id,
 	 ineffective_controls = least(ineffective_controls + 1,  controls_verified),
       	 ineffective_controls_prcnt = round((least(m_org_ineff_ctrls + 1, controls_verified))/decode(nvl(m_org_ctrls_total, 0), 0, 1, m_org_ctrls_total), 2)*100
 	WHERE FIN_CERTIFICATION_ID = Get_all_fin_cert_Rec.fin_certification_id
        AND ORGANIZATION_ID = p_org_id;
 --END IF;

/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********(M_proc_ineff_ctrls +  1  >  M_proc_ctrls_verified )     *******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_fin_cert_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR(M_proc_ineff_ctrls +  1  <   M_proc_ctrls_verified )     )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_fin_cert_Rec.fin_certification_id) := Get_all_fin_cert_Rec.fin_certification_id;
ELSE
********/
  UPDATE AMW_FIN_PROCESS_EVAL_SUM
 	SET
 	last_update_date = sysdate,
   	last_updated_by = fnd_global.user_id,
   	last_update_login = fnd_global.conc_login_id,
 	 ineffective_controls = least(ineffective_controls + 1,  controls_verified),
 	 ineffective_controls_prcnt = round((least(ineffective_controls + 1, controls_verified))/decode(nvl(total_number_of_ctrls , 0), 0, 1, total_number_of_ctrls), 2)*100
  	WHERE FIN_CERTIFICATION_ID = Get_all_fin_cert_Rec.fin_certification_id
  	AND ORGANIZATION_ID = p_org_id;
--  END IF;

  END IF;

END LOOP;



x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     IF Get_all_fin_cert%ISOPEN THEN
     close Get_all_fin_cert;
     end if;
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
      IF Get_all_fin_cert%ISOPEN THEN
       close Get_all_fin_cert;
      end if;
       ROLLBACK TO CONTROL_EVALUATION_HANDLER;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RAISE;
                RETURN;


END CONTROL_EVALUATION_HANDLER;

PROCEDURE PROCESS_CHANGE_HANDLER
(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
 p_org_id number,
 p_process_id number,
 p_opinion_log_id number,
 p_action varchar2,
 x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2)
IS

---CURSOR TO GET ALL OF FINANCIAL ITEMS WHICH RELATE TO THIS PROCESS
CURSOR Get_all_items( l_org_id number, l_process_id number)IS
SELECT DISTINCT fin.FIN_CERTIFICATION_ID, fin.STATEMENT_GROUP_ID, fin.FINANCIAL_STATEMENT_ID, fin.FINANCIAL_ITEM_ID
FROM AMW_FIN_CERT_SCOPE fin,
     AMW_CERTIFICATION_B cert
WHERE fin.ORGANIZATION_ID = l_org_id
AND  fin.PROCESS_ID = l_process_id
AND  fin.FINANCIAL_ITEM_ID IS NOT NULL
AND  fin.FIN_CERTIFICATION_ID = cert.CERTIFICATION_ID
AND  cert.CERTIFICATION_STATUS IN ('ACTIVE', 'DRAFT');

---CURSOR TO GET ALL OF ACCOUNTS WHICH RELATE TO THIS PROCESS
CURSOR 	Get_all_accts (l_org_id number, l_process_id number)IS
SELECT DISTINCT fin.fin_certification_id, fin.account_group_id, fin.natural_account_id
FROM AMW_FIN_CERT_SCOPE fin,
     AMW_CERTIFICATION_B cert
WHERE fin.ORGANIZATION_ID = l_org_id
AND   fin.PROCESS_ID = l_process_id
AND   fin.natural_account_id is not null
AND  fin.FIN_CERTIFICATION_ID = cert.CERTIFICATION_ID
AND  cert.CERTIFICATION_STATUS IN ('ACTIVE', 'DRAFT');


--CURSOR TO GET ALL OF FINANCIAL CERTIFICATION WHICH CONTAINS THIS PROCESSE
CURSOR Get_all_fin_cert(l_org_id number, l_process_id number) IS
SELECT proc.FIN_CERTIFICATION_ID
FROM AMW_FIN_PROCESS_EVAL_SUM proc,
     AMW_CERTIFICATION_B cert
WHERE proc.organization_id = l_org_id
AND proc.PROCESS_ID = l_process_id
AND proc.FIN_CERTIFICATION_ID = cert.CERTIFICATION_ID
AND cert.CERTIFICATION_STATUS IN ('ACTIVE', 'DRAFT');


--CURSOR TO GET ALL OF FINCERCIAL CERTIFICATION WHICH THIS PROCESS AS SUB-PROCESS
CURSOR Get_all_fin_process(l_org_id number, l_process_id number) IS
SELECT proc.FIN_CERTIFICATION_ID, proc.PARENT_PROCESS_ID
FROM AMW_FIN_PROCESS_FLAT proc,
     AMW_CERTIFICATION_B cert
WHERE proc.ORGANIZATION_ID = l_org_id
AND proc.CHILD_PROCESS_ID = l_process_id
AND cert.CERTIFICATION_ID = proc.FIN_CERTIFICATION_ID
AND cert.CERTIFICATION_STATUS IN ('ACTIVE', 'DRAFT');

--CURSOR TO GET OLD EVAL OPINION LOG ID
CURSOR Get_old_opinion_id(l_cert_id number, l_org_id number, l_process_id number) IS
SELECT EVAL_OPINION_LOG_ID
FROM AMW_FIN_PROCESS_EVAL_SUM
WHERE  FIN_CERTIFICATION_ID = l_cert_id
AND ORGANIZATION_ID = l_org_id
AND PROCESS_ID = l_process_id;

--CURSOR TO GET OLD CERT OPINION LOG ID
CURSOR Get_old_cert_opinion_id(l_cert_id number, l_org_id number, l_process_id number) IS
    SELECT CERT_OPINION_LOG_ID
	FROM AMW_FIN_PROCESS_EVAL_SUM
	WHERE  FIN_CERTIFICATION_ID = l_cert_id
	AND ORGANIZATION_ID = l_org_id
	AND PROCESS_ID = l_process_id;

--CURSOR TO GET PROCESS INFO FOR AN ITEM when an evaluation
     CURSOR Get_Item_Proc(l_cert_id NUMBER, l_stmt_id NUMBER, l_item_id NUMBER) IS
         SELECT PROC_WITH_INEFFECTIVE_CONTROLS, PROC_EVALUATED,TOTAL_NUMBER_OF_PROCESSES
         FROM  AMW_FIN_CERT_EVAL_SUM
         WHERE FIN_CERTIFICATION_ID = l_cert_id
    AND FINANCIAL_STATEMENT_ID = l_stmt_id
    AND FINANCIAL_ITEM_ID = l_item_id
    AND OBJECT_TYPE = 'FINANCIAL ITEM';

--CURSOR TO GET PROCESS INFO FOR AN ACCOUNT
CURSOR Get_Acct_Proc(l_cert_id NUMBER, l_acct_group_id NUMBER, l_acct_id NUMBER) IS
        SELECT PROC_WITH_INEFFECTIVE_CONTROLS, PROC_EVALUATED,TOTAL_NUMBER_OF_PROCESSES
         FROM  AMW_FIN_CERT_EVAL_SUM
       WHERE FIN_CERTIFICATION_ID = l_cert_id
       AND ACCOUNT_GROUP_ID = l_acct_group_id
       AND NATURAL_ACCOUNT_ID = l_acct_id
      AND OBJECT_TYPE = 'ACCOUNT';

 --CURSOR TO GET PROCESS INFO FOR AN ITEM when certification is modified
   CURSOR Get_Cert_Item_Proc(l_cert_id NUMBER, l_stmt_id NUMBER, l_item_id NUMBER) IS
       SELECT TOTAL_NUMBER_OF_PROCESSES, PROC_PENDING_CERTIFICATION, PROC_CERTIFIED_WITH_ISSUES
         FROM  AMW_FIN_CERT_EVAL_SUM
         WHERE FIN_CERTIFICATION_ID = l_cert_id
    AND FINANCIAL_STATEMENT_ID = l_stmt_id
    AND FINANCIAL_ITEM_ID = l_item_id
    AND OBJECT_TYPE = 'FINANCIAL ITEM';

 --CURSOR TO GET PROCESS INFO FOR AN ACCOUNT when certification is modified
   CURSOR Get_Cert_Acct_Proc(l_cert_id NUMBER, l_acct_group_id NUMBER, l_acct_id NUMBER) IS
        SELECT TOTAL_NUMBER_OF_PROCESSES, PROC_PENDING_CERTIFICATION, PROC_CERTIFIED_WITH_ISSUES
         FROM  AMW_FIN_CERT_EVAL_SUM
       WHERE FIN_CERTIFICATION_ID = l_cert_id
       AND ACCOUNT_GROUP_ID = l_acct_group_id
       AND NATURAL_ACCOUNT_ID = l_acct_id
      AND OBJECT_TYPE = 'ACCOUNT';

 --CURSOR TO GET FIN-CERT ID IN ORG_SUM TABLE
CURSOR Get_All_Org_Cert(l_org_id number) IS
SELECT  fin_certification_id, PROC_PENDING_CERTIFICATION, PROC_CERTIFIED_WITH_ISSUES,
	PROC_CERTIFIED, PROC_VERIFIED, TOTAL_NUMBER_OF_PROCS, PROC_WITH_INEFFECTIVE_CONTROLS
FROM amw_fin_org_eval_sum
WHERE ORGANIZATION_ID = l_org_id;

CURSOR Get_Dashboard_Info(l_cert_id number) IS
SELECT PROCESSES_NOT_CERT, PROCESSES_CERT_ISSUES, ORG_PROCESS_NOT_CERT, ORG_PROCESS_CERT_ISSUES,
PROC_INEFF_CONTROL, ORG_PROC_INEFF_CONTROL
FROM amw_cert_dashboard_sum
WHERE certification_id = l_cert_id;

CURSOR Get_parent_process(l_opinion_log_id  number, l_org_id number, l_process_id number) IS
SELECT fin.fin_certification_id, fin.organization_id, fin.process_id, fin.number_of_sub_procs_certified, fin.total_number_of_sub_procs
FROM    amw_fin_process_eval_sum fin
       WHERE fin.organization_id = l_org_id
	 AND fin.process_id in (
	          SELECT proc.parent_process_id
		    FROM amw_fin_process_flat proc
		    WHERE proc.fin_certification_id = fin.fin_certification_id
		    AND 	proc.organization_id = l_org_id
		    AND 	proc.child_process_id = l_process_id)
	AND  fin.fin_certification_id in (select rel.fin_stmt_cert_id from amw_fin_proc_cert_relan rel, amw_opinions_log opin
		       where rel.proc_cert_id = opin.pk2_value
		       and opin.opinion_log_id = l_opinion_log_id
		       and rel.end_date is null);

M_dashbd_proc_not_cert number;
M_dashbd_proc_cert_issue number;
M_dashbd_org_proc_not_cert number;
M_dashbd_org_proc_cert_issue number;
M_dashbd_proc_ineff_ctrl number;
M_dashbd_org_proc_ineff_ctrl number;

M_item_proc_pending_cert  number;
M_item_total_number_process number;
M_item_proc_cert_with_issue number;
M_item_proc_with_ineff_ctrl number;
M_item_proc_evaluated number;

M_acc_proc_pending_cert  number;
M_acc_total_number_process number;
M_acc_proc_cert_with_issue number;
M_acc_proc_with_ineff_ctrl number;
M_acc_proc_evaluated number;


M_proc_num_of_sub_procs_cert number;
M_proc_total_num_of_sub_proc number;

M_org_proc_with_ineff_ctrl number;
M_org_total_num_of_process number;
M_org_total_number_process number;
M_org_proc_pending_cert number;
M_org_proc_cert_with_issue number;

M_opinion_log_id AMW_OPINIONS_LOG.OPINION_LOG_ID%TYPE;

M_change_flag VARCHAR2(1);
M_new_flag VARCHAR2(1) := 'N';

l_error_message varchar2(4000);


l_api_name           CONSTANT VARCHAR2(30) := 'PROCESS_CHANGE_HANDLER';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

SAVEPOINT PROCESS_CHANGE_HANDLER;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;

--modify fin_cert_eval summary table
IF (p_action = 'EVALUATION') THEN

FOR Get_all_items_Rec in Get_all_items(p_org_id , p_process_id) LOOP
	 exit when Get_all_items %notfound;


    OPEN Get_old_opinion_id(Get_all_items_Rec.FIN_CERTIFICATION_ID, p_org_id, p_process_id);
    FETCH Get_old_opinion_id INTO M_opinion_log_id;
    CLOSE Get_old_opinion_id;

   M_item_total_number_process := 0;
   M_item_proc_evaluated := 0;
   M_item_proc_with_ineff_ctrl := 0;

  OPEN Get_Item_Proc(Get_all_items_Rec.FIN_CERTIFICATION_ID, Get_all_items_Rec.FINANCIAL_STATEMENT_ID,
   Get_all_items_Rec.FINANCIAL_ITEM_ID);
   FETCH Get_Item_Proc  INTO M_item_proc_with_ineff_ctrl, M_item_proc_evaluated, M_item_total_number_process;
   CLOSE Get_Item_Proc;

	Is_Eval_Change (
    		old_opinion_log_id  => M_opinion_log_id ,
    		new_opinion_log_id  => p_opinion_log_id,
    		x_change_flag	=> M_change_flag);


    IF(M_opinion_log_id = 0 OR M_opinion_log_id IS NULL) THEN  -- a new evaluation
     M_new_flag := 'Y';
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********(M_item_proc_evaluated + 1 > M_item_total_number_process)    *******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_items_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR(M_item_proc_evaluated + 1 < M_item_total_number_process) )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_items_Rec.fin_certification_id) := Get_all_items_Rec.fin_certification_id;
ELSE
*************/
UPDATE AMW_FIN_CERT_EVAL_SUM
        SET
        proc_evaluated = least(proc_evaluated + 1,total_number_of_processes),
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id
        WHERE FIN_CERTIFICATION_ID = Get_all_items_Rec.FIN_CERTIFICATION_ID
       AND FINANCIAL_STATEMENT_ID = Get_all_items_Rec.FINANCIAL_STATEMENT_ID
        AND FINANCIAL_ITEM_ID = Get_all_items_Rec.FINANCIAL_ITEM_ID
        AND OBJECT_TYPE = 'FINANCIAL ITEM';
-- END IF;

 END IF;


        IF (M_change_flag = 'B') THEN
 /********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********( M_item_proc_with_ineff_ctrl + 1 > M_item_proc_evaluated )    *******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_items_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR( M_item_proc_with_ineff_ctrl + 1 < M_item_proc_evaluated )  )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_items_Rec.fin_certification_id) := Get_all_items_Rec.fin_certification_id;
ELSE
****************/
UPDATE AMW_FIN_CERT_EVAL_SUM
        SET
        proc_with_ineffective_controls = least(proc_with_ineffective_controls + 1, controls_verified),
        proc_with_ineff_controls_prcnt = round( (least(m_item_proc_with_ineff_ctrl + 1, controls_verified))/decode(nvl(m_item_total_number_process, 0), 0, 1, m_item_total_number_process), 2) * 100,
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id
        WHERE FIN_CERTIFICATION_ID = Get_all_items_Rec.FIN_CERTIFICATION_ID
       AND FINANCIAL_STATEMENT_ID = Get_all_items_Rec.FINANCIAL_STATEMENT_ID
        AND FINANCIAL_ITEM_ID = Get_all_items_Rec.FINANCIAL_ITEM_ID
        AND OBJECT_TYPE = 'FINANCIAL ITEM';
--END IF;

        ELSIF (M_change_flag = 'F'  and M_new_flag = 'N' )  THEN
 /********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********( M_item_proc_with_ineff_ctrl -1 < 0  )    *******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_items_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR( M_item_proc_with_ineff_ctrl -1 > 0  )  )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_items_Rec.fin_certification_id) := Get_all_items_Rec.fin_certification_id;
ELSE
**************/
UPDATE AMW_FIN_CERT_EVAL_SUM
        SET
        proc_with_ineffective_controls = greatest(0, proc_with_ineffective_controls - 1),
        proc_with_ineff_controls_prcnt = round( (greatest(0,m_item_proc_with_ineff_ctrl - 1))/decode(nvl(m_item_total_number_process, 0), 0, 1, m_item_total_number_process), 2) * 100,
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id
        WHERE FIN_CERTIFICATION_ID = Get_all_items_Rec.FIN_CERTIFICATION_ID
        AND FINANCIAL_STATEMENT_ID = Get_all_items_Rec.FINANCIAL_STATEMENT_ID
        AND FINANCIAL_ITEM_ID = Get_all_items_Rec.FINANCIAL_ITEM_ID
        AND OBJECT_TYPE = 'FINANCIAL ITEM';
-- END IF;
        END IF;
    END LOOP;


    FOR Get_all_accts_Rec IN Get_all_accts(p_org_id , p_process_id) LOOP
           exit when Get_all_accts%notfound;

     OPEN Get_old_opinion_id(Get_all_accts_Rec.FIN_CERTIFICATION_ID, p_org_id, p_process_id);
    FETCH Get_old_opinion_id INTO M_opinion_log_id;
    CLOSE Get_old_opinion_id;

      M_acc_proc_with_ineff_ctrl := 0;
    M_acc_proc_evaluated := 0;
    M_acc_total_number_process := 0;

   OPEN Get_Acct_Proc(Get_all_accts_Rec.FIN_CERTIFICATION_ID, Get_all_accts_Rec.ACCOUNT_GROUP_ID,
   Get_all_accts_Rec.NATURAL_ACCOUNT_ID);
   FETCH Get_Acct_Proc  INTO M_acc_proc_with_ineff_ctrl, M_acc_proc_evaluated,  M_acc_total_number_process;
   CLOSE Get_Acct_Proc;

	Is_Eval_Change(
    		old_opinion_log_id  =>  M_opinion_log_id ,
    		new_opinion_log_id  =>  p_opinion_log_id,
    		x_change_flag	=> M_change_flag);



    IF(M_opinion_log_id = 0 OR M_opinion_log_id IS NULL) THEN  --  a new evaluation
     M_new_flag := 'Y';
 /********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********(M_acc_proc_evaluated + 1 > M_acc_total_number_process)   *******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_accts_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR(M_acc_proc_evaluated + 1 <  M_acc_total_number_process)   )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_accts_Rec.fin_certification_id) := Get_all_accts_Rec.fin_certification_id;
ELSE
**************/
UPDATE AMW_FIN_CERT_EVAL_SUM
        SET
        proc_evaluated = least(proc_evaluated + 1, total_number_of_processes),
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id
        WHERE FIN_CERTIFICATION_ID = Get_all_accts_Rec.FIN_CERTIFICATION_ID
       AND ACCOUNT_GROUP_ID = Get_all_accts_Rec.ACCOUNT_GROUP_ID
       AND NATURAL_ACCOUNT_ID = Get_all_accts_Rec.NATURAL_ACCOUNT_ID
       AND OBJECT_TYPE = 'ACCOUNT';
 --   END IF;
END IF;

        IF (M_change_flag = 'B') THEN
 /********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********(  M_acc_proc_with_ineff_ctrl + 1 > M_acc_proc_evaluated)    *******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_accts_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR(  M_acc_proc_with_ineff_ctrl + 1 <  M_acc_proc_evaluated)   )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_accts_Rec.fin_certification_id) := Get_all_accts_Rec.fin_certification_id;
ELSE
***************/
UPDATE AMW_FIN_CERT_EVAL_SUM
        SET
        proc_with_ineffective_controls = least(proc_with_ineffective_controls + 1,controls_verified),
        proc_with_ineff_controls_prcnt = round( (least(m_item_proc_with_ineff_ctrl + 1, controls_verified))/decode(nvl(m_acc_total_number_process, 0), 0, 1, m_acc_total_number_process), 2) * 100,
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id
        WHERE FIN_CERTIFICATION_ID = Get_all_accts_Rec.FIN_CERTIFICATION_ID
       AND ACCOUNT_GROUP_ID = Get_all_accts_Rec.ACCOUNT_GROUP_ID
       AND NATURAL_ACCOUNT_ID = Get_all_accts_Rec.NATURAL_ACCOUNT_ID
       AND OBJECT_TYPE = 'ACCOUNT';
-- END IF;

        ELSIF (M_change_flag = 'F'  and M_new_flag = 'N' )  THEN
 /********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********(  M_acc_proc_with_ineff_ctrl -1 < 0 ) *******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_accts_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR(  M_acc_proc_with_ineff_ctrl -1 > 0 )   )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_accts_Rec.fin_certification_id) := Get_all_accts_Rec.fin_certification_id;
ELSE
***********/
 UPDATE AMW_FIN_CERT_EVAL_SUM
        SET
        proc_with_ineffective_controls = greatest(0,proc_with_ineffective_controls - 1),
        proc_with_ineff_controls_prcnt = round( (greatest(0,m_acc_proc_with_ineff_ctrl - 1))/decode(nvl(m_acc_total_number_process, 0), 0, 1, m_acc_total_number_process), 2) * 100,
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id
        WHERE FIN_CERTIFICATION_ID = Get_all_accts_Rec.FIN_CERTIFICATION_ID
        AND ACCOUNT_GROUP_ID = Get_all_accts_Rec.ACCOUNT_GROUP_ID
        AND NATURAL_ACCOUNT_ID = Get_all_accts_Rec.NATURAL_ACCOUNT_ID
        AND OBJECT_TYPE = 'ACCOUNT';
--END IF;
        END IF;


 END LOOP;

 --update amw_fin_org_eval_sum and amw_cert_dashboard_sum tables
 FOR Get_All_Org_Cert_Rec in Get_All_Org_Cert(p_org_id) LOOP
 	exit when Get_All_Org_Cert %notfound;

    OPEN Get_old_cert_opinion_id(Get_All_Org_Cert_Rec.FIN_CERTIFICATION_ID, p_org_id, p_process_id);
    FETCH Get_old_cert_opinion_id INTO M_opinion_log_id;
    CLOSE Get_old_cert_opinion_id;

      Is_Eval_Change(
    		old_opinion_log_id  =>  M_opinion_log_id ,
    		new_opinion_log_id  =>  p_opinion_log_id,
    		x_change_flag	=> M_change_flag);

    OPEN Get_Dashboard_Info(Get_All_Org_Cert_Rec.FIN_CERTIFICATION_ID);
    FETCH Get_Dashboard_Info INTO M_dashbd_proc_not_cert,M_dashbd_proc_cert_issue,
				  M_dashbd_org_proc_not_cert,M_dashbd_org_proc_cert_issue,
				  M_dashbd_proc_ineff_ctrl,M_dashbd_org_proc_ineff_ctrl;
    CLOSE Get_Dashboard_Info;

     IF(M_opinion_log_id is NOT NULL AND M_change_flag = 'F' ) THEN
 /********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********( get_all_org_cert_rec.proc_verified  + 1  >  get_all_org_cert_rec.total_number_of_procs) *******************************/
 /********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(get_all_org_cert_rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR( Get_All_Org_Cert_Rec.PROC_VERIFIED  + 1  <  Get_All_Org_Cert_Rec.TOTAL_NUMBER_OF_PROCS)   )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(get_all_org_cert_rec.fin_certification_id) := get_all_org_cert_rec.fin_certification_id;
ELSE
***********/
UPDATE AMW_FIN_ORG_EVAL_SUM SET
        LAST_UPDATE_DATE = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id,
        proc_verified =  least(proc_verified + 1, total_number_of_procs )
        WHERE FIN_CERTIFICATION_ID = Get_All_Org_Cert_Rec.FIN_CERTIFICATION_ID
	AND ORGANIZATION_ID  = p_org_id;
--END IF;

   ELSIF( M_opinion_log_id is NULL AND M_change_flag = 'B' ) THEN
 /********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********(( get_all_org_cert_rec.proc_verified  + 1  >  get_all_org_cert_rec.total_number_of_procs)
********* or ( get_all_org_cert_rec.proc_with_ineffective_controls + 1 > get_all_org_cert_rec.proc_verified))*******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(get_all_org_cert_rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR(( get_all_org_cert_rec.proc_verified  + 1  <  get_all_org_cert_rec.total_number_of_procs)
        AND ( get_all_org_cert_rec.proc_with_ineffective_controls + 1 < get_all_org_cert_rec.proc_verified))   )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(get_all_org_cert_rec.fin_certification_id) := get_all_org_cert_rec.fin_certification_id;
ELSE
*************/
UPDATE AMW_FIN_ORG_EVAL_SUM SET
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id,
        proc_verified =  least(proc_verified + 1,total_number_of_procs),
        proc_with_ineffective_controls = least(proc_with_ineffective_controls + 1,proc_verified),
        proc_with_ineff_controls_prcnt = round( (least(proc_with_ineffective_controls + 1, proc_verified))/decode(nvl(total_number_of_procs, 0), 0, 1, total_number_of_procs), 2)*100
        WHERE FIN_CERTIFICATION_ID = Get_All_Org_Cert_Rec.FIN_CERTIFICATION_ID
	AND ORGANIZATION_ID  = p_org_id;
--END IF;

	IF p_org_id = fnd_profile.value('AMW_GLOBAL_ORG_ID') THEN
	  UPDATE amw_cert_dashboard_sum
             SET last_update_date = sysdate,
                 last_updated_by = fnd_global.user_id,
	         last_update_login = fnd_global.conc_login_id,
		 proc_ineff_control = proc_ineff_control+1
  	   WHERE certification_id = get_all_org_cert_rec.fin_certification_id;
        ELSE
	  UPDATE amw_cert_dashboard_sum
             SET last_update_date = sysdate,
                 last_updated_by = fnd_global.user_id,
	         last_update_login = fnd_global.conc_login_id,
		 org_proc_ineff_control = org_proc_ineff_control+1
  	   WHERE certification_id = get_all_org_cert_rec.fin_certification_id;
        END IF;

     ELSIF(M_opinion_log_id is NOT NULL AND M_change_flag = 'F' ) THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********( get_all_org_cert_rec.proc_with_ineffective_controls  - 1 < 0 )*******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(get_all_org_cert_rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR( get_all_org_cert_rec.proc_with_ineffective_controls  - 1 > 0 )   )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(get_all_org_cert_rec.fin_certification_id) := get_all_org_cert_rec.fin_certification_id;
ELSE
****************/
UPDATE AMW_FIN_ORG_EVAL_SUM SET
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id,
        proc_with_ineffective_controls = greatest(0, proc_with_ineffective_controls - 1),
        proc_with_ineff_controls_prcnt = round( (greatest(0, proc_with_ineffective_controls - 1))/decode(nvl(total_number_of_procs, 0), 0, 1, total_number_of_procs), 2)*100
        WHERE FIN_CERTIFICATION_ID = Get_All_Org_Cert_Rec.FIN_CERTIFICATION_ID
	AND ORGANIZATION_ID  = p_org_id;
--END IF;
	IF p_org_id = fnd_profile.value('AMW_GLOBAL_ORG_ID') THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********( m_dashbd_proc_ineff_ctrl -1 < 0 ) *******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(get_all_org_cert_rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR( m_dashbd_proc_ineff_ctrl -1 > 0 )   )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(get_all_org_cert_rec.fin_certification_id) := get_all_org_cert_rec.fin_certification_id;
ELSE
***********/
 UPDATE amw_cert_dashboard_sum
             SET last_update_date = sysdate,
                 last_updated_by = fnd_global.user_id,
	         last_update_login = fnd_global.conc_login_id,
		 proc_ineff_control = greatest(0,proc_ineff_control-1)
  	   WHERE certification_id = get_all_org_cert_rec.fin_certification_id;
-- END IF;
        ELSE
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********( m_dashbd_org_proc_ineff_ctrl -1 < 0 )*******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(get_all_org_cert_rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR( m_dashbd_org_proc_ineff_ctrl -1 > 0 )  )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(get_all_org_cert_rec.fin_certification_id) := get_all_org_cert_rec.fin_certification_id;
ELSE
*************/
UPDATE amw_cert_dashboard_sum
             SET last_update_date = sysdate,
                 last_updated_by = fnd_global.user_id,
	         last_update_login = fnd_global.conc_login_id,
		 org_proc_ineff_control = greatest(0, org_proc_ineff_control-1)
  	   WHERE certification_id = get_all_org_cert_rec.fin_certification_id;
--        END IF;
END IF;
 	ELSIF(M_opinion_log_id is NOT NULL AND M_change_flag = 'B' ) THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********( get_all_org_cert_rec.proc_with_ineffective_controls  + 1  >  get_all_org_cert_rec.proc_verified) *******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(get_all_org_cert_rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR( get_all_org_cert_rec.proc_with_ineffective_controls  + 1  <  get_all_org_cert_rec.proc_verified)  )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(get_all_org_cert_rec.fin_certification_id) := get_all_org_cert_rec.fin_certification_id;
ELSE
**************/
UPDATE AMW_FIN_ORG_EVAL_SUM SET
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id,
        proc_with_ineffective_controls = least(proc_with_ineffective_controls + 1, proc_verified),
        proc_with_ineff_controls_prcnt = round( (least(proc_with_ineffective_controls + 1, proc_verified) )/decode(nvl(total_number_of_procs, 0), 0, 1, total_number_of_procs), 2)*100
        WHERE FIN_CERTIFICATION_ID = Get_All_Org_Cert_Rec.FIN_CERTIFICATION_ID
	AND ORGANIZATION_ID  = p_org_id;
--END IF;

	IF p_org_id = fnd_profile.value('AMW_GLOBAL_ORG_ID') THEN
	  UPDATE amw_cert_dashboard_sum
             SET last_update_date = sysdate,
                 last_updated_by = fnd_global.user_id,
	         last_update_login = fnd_global.conc_login_id,
		 proc_ineff_control = proc_ineff_control + 1
  	   WHERE certification_id = get_all_org_cert_rec.fin_certification_id;
        ELSE
	  UPDATE amw_cert_dashboard_sum
             SET last_update_date = sysdate,
                 last_updated_by = fnd_global.user_id,
	         last_update_login = fnd_global.conc_login_id,
		 org_proc_ineff_control = org_proc_ineff_control + 1
  	   WHERE certification_id = get_all_org_cert_rec.fin_certification_id;
        END IF;

	END IF; -- end of a list of ifs

END LOOP; --end of amw_fin_org_eval_sum and amw_cert_dashboard_sum

END IF;  --end of  p_action = 'EVALUATION'

IF (p_action = 'CERTIFICATION') THEN

FOR Get_all_items_Rec in Get_all_items(p_org_id , p_process_id) LOOP
	 exit when Get_all_items %notfound;

    OPEN Get_old_cert_opinion_id(Get_all_items_Rec.FIN_CERTIFICATION_ID, p_org_id, p_process_id);
    FETCH Get_old_cert_opinion_id INTO M_opinion_log_id;
    CLOSE Get_old_cert_opinion_id;

    Is_Eval_Change(
    		old_opinion_log_id  =>  M_opinion_log_id ,
    		new_opinion_log_id  =>  p_opinion_log_id,
    		x_change_flag	=> M_change_flag);

	M_item_total_number_process := 0;
    	M_item_proc_pending_cert := 0;
    	M_item_proc_cert_with_issue := 0;

 OPEN Get_Cert_Item_Proc(Get_all_items_Rec.FIN_CERTIFICATION_ID, Get_all_items_Rec.FINANCIAL_STATEMENT_ID,
   Get_all_items_Rec.FINANCIAL_ITEM_ID);
   FETCH Get_Cert_Item_Proc  INTO M_item_total_number_process, M_item_proc_pending_cert, M_item_proc_cert_with_issue;
   CLOSE Get_Cert_Item_Proc;

        IF(M_opinion_log_id = 0 OR M_opinion_log_id IS NULL) THEN  -- a new certification
          M_new_flag := 'Y';
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********( m_item_proc_pending_cert  - 1 < 0 ) *******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_items_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR( m_item_proc_pending_cert  - 1 > 0 )   )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_items_Rec.fin_certification_id) := Get_all_items_Rec.fin_certification_id;
ELSE
***********/
 UPDATE AMW_FIN_CERT_EVAL_SUM SET
        last_update_date = sysdate,
         last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id,
        proc_pending_certification =  greatest(0, proc_pending_certification - 1),
        procs_for_cert_done = least(procs_for_cert_done + 1,  total_number_of_processes ),
        pro_pending_cert_prcnt = round( (greatest(0,proc_pending_certification -1) )/decode(nvl(total_number_of_processes, 0), 0, 1, total_number_of_processes) ,2)*100
        WHERE FIN_CERTIFICATION_ID = Get_all_items_Rec.FIN_CERTIFICATION_ID
	AND FINANCIAL_STATEMENT_ID = Get_all_items_Rec.FINANCIAL_STATEMENT_ID
        AND FINANCIAL_ITEM_ID = Get_all_items_Rec.FINANCIAL_ITEM_ID
        AND OBJECT_TYPE = 'FINANCIAL ITEM';
--END IF;
        END IF;


        IF (M_change_flag = 'F'  and M_new_flag = 'N' ) THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********( m_item_proc_cert_with_issue  - 1 < 0 )  *******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_items_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR( m_item_proc_cert_with_issue  - 1 > 0 )    )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_items_Rec.fin_certification_id) := Get_all_items_Rec.fin_certification_id;
ELSE
*************/
      UPDATE AMW_FIN_CERT_EVAL_SUM SET
        last_update_date = sysdate,
         last_updated_by = fnd_global.user_id,
       last_update_login = fnd_global.conc_login_id,
        proc_certified_with_issues = least(0,proc_certified_with_issues -1),
        processes_with_issues_prcnt = round( (least(0, m_item_proc_cert_with_issue -1))/decode(nvl(m_item_total_number_process, 0), 0, 1, m_item_total_number_process), 2)*100
        WHERE FIN_CERTIFICATION_ID = Get_all_items_Rec.FIN_CERTIFICATION_ID
	AND FINANCIAL_STATEMENT_ID = Get_all_items_Rec.FINANCIAL_STATEMENT_ID
        AND FINANCIAL_ITEM_ID = Get_all_items_Rec.FINANCIAL_ITEM_ID
        AND OBJECT_TYPE = 'FINANCIAL ITEM';
--END IF;


        ELSIF (M_change_flag = 'B') THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********( m_item_proc_cert_with_issue  +  1 >  m_item_total_number_process )  *******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_items_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR( m_item_proc_cert_with_issue  +  1 <  m_item_total_number_process )   )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_items_Rec.fin_certification_id) := Get_all_items_Rec.fin_certification_id;
ELSE
****************/
 UPDATE AMW_FIN_CERT_EVAL_SUM SET
        last_update_date = sysdate,
         last_updated_by = fnd_global.user_id,
       last_update_login = fnd_global.conc_login_id,
        proc_certified_with_issues = least(proc_certified_with_issues + 1, total_number_of_processes ),
        processes_with_issues_prcnt = round( (least(m_item_proc_cert_with_issue + 1, total_number_of_processes))/decode(nvl(m_item_total_number_process, 0), 0, 1, m_item_total_number_process), 2)*100
        WHERE FIN_CERTIFICATION_ID = Get_all_items_Rec.FIN_CERTIFICATION_ID
	AND FINANCIAL_STATEMENT_ID = Get_all_items_Rec.FINANCIAL_STATEMENT_ID
        AND FINANCIAL_ITEM_ID = Get_all_items_Rec.FINANCIAL_ITEM_ID
        AND OBJECT_TYPE = 'FINANCIAL ITEM';
--END IF;
        END IF;

  END LOOP;

  FOR Get_all_accts_Rec IN Get_all_accts(p_org_id , p_process_id) LOOP
           exit when Get_all_accts%notfound;

     OPEN Get_old_cert_opinion_id(Get_all_accts_Rec.FIN_CERTIFICATION_ID, p_org_id, p_process_id);
    FETCH Get_old_cert_opinion_id INTO M_opinion_log_id;
    CLOSE Get_old_cert_opinion_id;



    		M_acc_total_number_process := 0;
    		M_acc_proc_pending_cert := 0;
    		M_acc_proc_cert_with_issue := 0;

OPEN Get_Cert_Acct_Proc(Get_all_accts_Rec.FIN_CERTIFICATION_ID, Get_all_accts_Rec.ACCOUNT_GROUP_ID,
Get_all_accts_Rec.NATURAL_ACCOUNT_ID);
FETCH Get_Cert_Acct_Proc  INTO  M_acc_total_number_process, M_acc_proc_pending_cert, M_acc_proc_cert_with_issue;
CLOSE Get_Cert_Acct_Proc;

	Is_Eval_Change(
    		old_opinion_log_id  =>  M_opinion_log_id ,
    		new_opinion_log_id  =>  p_opinion_log_id,
    		x_change_flag	=> M_change_flag);

        IF(M_opinion_log_id IS NULL OR M_opinion_log_id = 0 ) THEN  --  a new certification
         M_new_flag := 'Y';
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********(m_acc_proc_pending_cert - 1 < 0 )   *******************************/
 /********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_accts_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR(m_acc_proc_pending_cert - 1 > 0 )   )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_accts_Rec.fin_certification_id) := Get_all_accts_Rec.fin_certification_id;
ELSE
***************/
UPDATE AMW_FIN_CERT_EVAL_SUM SET
        last_update_date = sysdate,
         last_updated_by = fnd_global.user_id,
       last_update_login = fnd_global.conc_login_id,
        proc_pending_certification =  greatest(0, proc_pending_certification - 1),
        procs_for_cert_done = least(procs_for_cert_done + 1,total_number_of_processes),
        pro_pending_cert_prcnt = round( (greatest(0,proc_pending_certification -1))/decode(nvl(total_number_of_processes, 0), 0, 1, total_number_of_processes), 2)*100
        WHERE FIN_CERTIFICATION_ID = Get_all_accts_Rec.FIN_CERTIFICATION_ID
       AND ACCOUNT_GROUP_ID = Get_all_accts_Rec.ACCOUNT_GROUP_ID
       AND NATURAL_ACCOUNT_ID = Get_all_accts_Rec.NATURAL_ACCOUNT_ID
       AND OBJECT_TYPE = 'ACCOUNT';
        END IF;
-- END IF;
        IF (M_change_flag = 'F'  and M_new_flag = 'N' ) THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********(m_acc_proc_cert_with_issue - 1 < 0 )    *******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_accts_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR(m_acc_proc_cert_with_issue - 1 > 0 )   )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_accts_Rec.fin_certification_id) := Get_all_accts_Rec.fin_certification_id;
ELSE
***********/
 UPDATE AMW_FIN_CERT_EVAL_SUM SET
         last_update_date = sysdate,
         last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id,
        proc_certified_with_issues = greatest(0,proc_certified_with_issues -1),
        processes_with_issues_prcnt = round( (greatest(0,m_acc_proc_cert_with_issue -1))/decode(nvl(m_acc_total_number_process, 0), 0, 1, m_acc_total_number_process), 2)*100
       WHERE FIN_CERTIFICATION_ID = Get_all_accts_Rec.FIN_CERTIFICATION_ID
       AND ACCOUNT_GROUP_ID = Get_all_accts_Rec.ACCOUNT_GROUP_ID
       AND NATURAL_ACCOUNT_ID = Get_all_accts_Rec.NATURAL_ACCOUNT_ID
       AND OBJECT_TYPE = 'ACCOUNT';
--END IF;

        ELSIF (M_change_flag = 'B') THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********(m_acc_proc_cert_with_issue + 1 > m_acc_total_number_process ) *******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(Get_all_accts_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR(m_acc_proc_cert_with_issue + 1 < m_acc_total_number_process )    )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_accts_Rec.fin_certification_id) := Get_all_accts_Rec.fin_certification_id;
ELSE
********************/
UPDATE AMW_FIN_CERT_EVAL_SUM SET
         last_update_date = sysdate,
         last_updated_by = fnd_global.user_id,
       last_update_login = fnd_global.conc_login_id,
        proc_certified_with_issues = least(proc_certified_with_issues + 1,total_number_of_processes),
        processes_with_issues_prcnt = round( (least(m_acc_proc_cert_with_issue + 1, total_number_of_processes))/decode(nvl(m_acc_total_number_process, 0), 0, 1, m_acc_total_number_process), 2)*100
      WHERE FIN_CERTIFICATION_ID = Get_all_accts_Rec.FIN_CERTIFICATION_ID
       AND ACCOUNT_GROUP_ID = Get_all_accts_Rec.ACCOUNT_GROUP_ID
       AND NATURAL_ACCOUNT_ID = Get_all_accts_Rec.NATURAL_ACCOUNT_ID
       AND OBJECT_TYPE = 'ACCOUNT';
-- END IF;

        END IF;

 END LOOP; --end of account loop


  --update amw_fin_org_eval_sum and amw_cert_dashboard_sum tables
 FOR Get_All_Org_Cert_Rec in Get_All_Org_Cert(p_org_id) LOOP
 	exit when Get_All_Org_Cert %notfound;

    OPEN Get_old_cert_opinion_id(Get_All_Org_Cert_Rec.FIN_CERTIFICATION_ID, p_org_id, p_process_id);
    FETCH Get_old_cert_opinion_id INTO M_opinion_log_id;
    CLOSE Get_old_cert_opinion_id;

      Is_Eval_Change(
    		old_opinion_log_id  =>  M_opinion_log_id ,
    		new_opinion_log_id  =>  p_opinion_log_id,
    		x_change_flag	=> M_change_flag);

    OPEN Get_Dashboard_Info(Get_All_Org_Cert_Rec.FIN_CERTIFICATION_ID);
    FETCH Get_Dashboard_Info INTO M_dashbd_proc_not_cert,M_dashbd_proc_cert_issue,
				  M_dashbd_org_proc_not_cert,M_dashbd_org_proc_cert_issue,
				  M_dashbd_proc_ineff_ctrl,M_dashbd_org_proc_ineff_ctrl;
    CLOSE Get_Dashboard_Info;


     IF(M_opinion_log_id IS NULL AND M_change_flag = 'F' ) THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********(( get_all_org_cert_rec.proc_certified  + 1  >  get_all_org_cert_rec.total_number_of_procs)
        or (get_all_org_cert_rec.proc_pending_certification -1 < 0 ) )  *******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(get_all_org_cert_rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR(( get_all_org_cert_rec.proc_certified  + 1  <  get_all_org_cert_rec.total_number_of_procs)
        AND  (get_all_org_cert_rec.proc_pending_certification -1 > 0 ) )    )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(get_all_org_cert_rec.fin_certification_id) := get_all_org_cert_rec.fin_certification_id;
ELSE
*****************/
UPDATE AMW_FIN_ORG_EVAL_SUM SET
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id,
        proc_certified =  least(proc_certified + 1,total_number_of_procs ),
        proc_pending_certification = greatest(0, proc_pending_certification - 1)
        WHERE FIN_CERTIFICATION_ID = Get_All_Org_Cert_Rec.FIN_CERTIFICATION_ID
	AND ORGANIZATION_ID  = p_org_id;
--END IF;

   ELSIF(M_opinion_log_id is NULL AND M_change_flag = 'B' ) THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********(( get_all_org_cert_rec.proc_certified  + 1  >  get_all_org_cert_rec.total_number_of_procs)
        or ( get_all_org_cert_rec.proc_certified_with_issues + 1 > get_all_org_cert_rec.proc_certified)
        or ( get_all_org_cert_rec.proc_pending_certification - 1 < 0 ))*******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(get_all_org_cert_rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR(( get_all_org_cert_rec.proc_certified  + 1  <  get_all_org_cert_rec.total_number_of_procs)
        and ( get_all_org_cert_rec.proc_certified_with_issues + 1 < get_all_org_cert_rec.proc_certified)
        and ( get_all_org_cert_rec.proc_pending_certification - 1 >  0 ))    )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(get_all_org_cert_rec.fin_certification_id) := get_all_org_cert_rec.fin_certification_id;
ELSE
**************/
UPDATE AMW_FIN_ORG_EVAL_SUM SET
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id,
        proc_certified =  least(proc_certified + 1,total_number_of_procs),
        proc_pending_certification = greatest(0, proc_pending_certification - 1),
        proc_certified_with_issues = least(proc_certified_with_issues + 1, proc_certified),
        proc_pending_cert_prcnt = round( (least(proc_pending_certification + 1, total_number_of_procs))/decode(nvl(total_number_of_procs, 0), 0, 1, total_number_of_procs), 2)*100,
        processes_with_issues_prcnt = round( (least(proc_certified_with_issues + 1, proc_certified))/decode(nvl(total_number_of_procs, 0), 0, 1, total_number_of_procs), 2)*100
        WHERE FIN_CERTIFICATION_ID = Get_All_Org_Cert_Rec.FIN_CERTIFICATION_ID
	AND ORGANIZATION_ID  = p_org_id;
--END IF;
	IF p_org_id = fnd_profile.value('AMW_GLOBAL_ORG_ID') THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********( M_dashbd_proc_not_cert -1 < 0 )*******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(get_all_org_cert_rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR( M_dashbd_proc_not_cert -1 > 0 ) )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(get_all_org_cert_rec.fin_certification_id) := get_all_org_cert_rec.fin_certification_id;
ELSE
*******************/
  UPDATE amw_cert_dashboard_sum
             SET last_update_date = sysdate,
                 last_updated_by = fnd_global.user_id,
	         last_update_login = fnd_global.conc_login_id,
		 processes_cert_issues = processes_cert_issues +1,
		 processes_not_cert = processes_not_cert - 1
  	   WHERE certification_id = get_all_org_cert_rec.fin_certification_id;
-- END IF;
        ELSE
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********( m_dashbd_org_proc_not_cert -1 < 0 ) *******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(get_all_org_cert_rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR( m_dashbd_org_proc_not_cert -1 > 0 )  )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(get_all_org_cert_rec.fin_certification_id) := get_all_org_cert_rec.fin_certification_id;
ELSE
***************/
UPDATE amw_cert_dashboard_sum
             SET last_update_date = sysdate,
                 last_updated_by = fnd_global.user_id,
	         last_update_login = fnd_global.conc_login_id,
		 org_process_cert_issues = org_process_cert_issues+1,
		 org_process_not_cert = greatest(0, org_process_not_cert -1)
  	   WHERE certification_id = get_all_org_cert_rec.fin_certification_id;
--        END IF;
END IF;
     ELSIF(M_opinion_log_id is NOT NULL AND M_change_flag = 'F' ) THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********(get_all_org_cert_rec.proc_certified_with_issues - 1 < 0 )*******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(get_all_org_cert_rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR(get_all_org_cert_rec.proc_certified_with_issues - 1 > 0 ) )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(get_all_org_cert_rec.fin_certification_id) := get_all_org_cert_rec.fin_certification_id;
ELSE
*************/
UPDATE AMW_FIN_ORG_EVAL_SUM SET
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id,
        proc_certified_with_issues = greatest(0, proc_certified_with_issues -  1),
        processes_with_issues_prcnt = round( (greatest(0, proc_certified_with_issues - 1))/decode(nvl(total_number_of_procs, 0), 0, 1, total_number_of_procs), 2)*100
        WHERE FIN_CERTIFICATION_ID = Get_All_Org_Cert_Rec.FIN_CERTIFICATION_ID
	AND ORGANIZATION_ID  = p_org_id;
--END IF;
	IF p_org_id = fnd_profile.value('AMW_GLOBAL_ORG_ID') THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********( m_dashbd_proc_cert_issue -1 < 0 ) *******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(get_all_org_cert_rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR( m_dashbd_proc_cert_issue -1 > 0 )  )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(get_all_org_cert_rec.fin_certification_id) := get_all_org_cert_rec.fin_certification_id;
ELSE
*****************/
 UPDATE amw_cert_dashboard_sum
             set last_update_date = sysdate,
                 last_updated_by = fnd_global.user_id,
	         last_update_login = fnd_global.conc_login_id,
		 processes_cert_issues = greatest(0, processes_cert_issues  - 1)
  	   WHERE certification_id = get_all_org_cert_rec.fin_certification_id;
--END IF;
        ELSE
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********( m_dashbd_org_proc_cert_issue -1 < 0 ) *******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(get_all_org_cert_rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR( m_dashbd_org_proc_cert_issue -1 > 0 )   )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(get_all_org_cert_rec.fin_certification_id) := get_all_org_cert_rec.fin_certification_id;
ELSE
****************/
UPDATE amw_cert_dashboard_sum
             set last_update_date = sysdate,
                 last_updated_by = fnd_global.user_id,
	         last_update_login = fnd_global.conc_login_id,
		 org_process_cert_issues = greatest(0, org_process_cert_issues - 1)
  	   WHERE certification_id = get_all_org_cert_rec.fin_certification_id;
--        END IF;
END IF;
 	ELSIF(M_opinion_log_id is NOT NULL AND M_change_flag = 'B' ) THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********(get_all_org_cert_rec.proc_certified_with_issues +  1 < get_all_org_cert_rec.proc_certified ) *******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(get_all_org_cert_rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR(get_all_org_cert_rec.proc_certified_with_issues +  1 < get_all_org_cert_rec.proc_certified ) )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(get_all_org_cert_rec.fin_certification_id) := get_all_org_cert_rec.fin_certification_id;
ELSE
***************/
 UPDATE AMW_FIN_ORG_EVAL_SUM SET
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id,
        proc_certified_with_issues = least(proc_certified_with_issues +  1,  total_number_of_procs),
        processes_with_issues_prcnt = round( (least(proc_certified_with_issues + 1, total_number_of_procs))/decode(nvl(total_number_of_procs, 0), 0, 1, total_number_of_procs), 2)*100
        WHERE FIN_CERTIFICATION_ID = Get_All_Org_Cert_Rec.FIN_CERTIFICATION_ID
	AND ORGANIZATION_ID  = p_org_id;
--END IF;
	IF p_org_id = fnd_profile.value('AMW_GLOBAL_ORG_ID') THEN
	  UPDATE amw_cert_dashboard_sum
             SET last_update_date = sysdate,
                 last_updated_by = fnd_global.user_id,
	         last_update_login = fnd_global.conc_login_id,
		 processes_cert_issues = processes_cert_issues  + 1
  	   WHERE certification_id = get_all_org_cert_rec.fin_certification_id;
        ELSE
	  UPDATE amw_cert_dashboard_sum
             SET last_update_date = sysdate,
                 last_updated_by = fnd_global.user_id,
	         last_update_login = fnd_global.conc_login_id,
		 org_process_cert_issues = greatest(0, org_process_cert_issues - 1)
  	   WHERE certification_id = get_all_org_cert_rec.fin_certification_id;
        END IF;

	END IF; -- end of a list of ifs

 END LOOP; --end of amw_fin_org_eval_sum and amw_cert_dashboard_sum

 --update amw_fin_process_eval_sum table
 FOR Get_parent_process_Rec in Get_parent_process(p_opinion_log_id, p_org_id, p_process_id ) LOOP
 	exit when Get_parent_process %notfound;

 OPEN Get_old_cert_opinion_id(Get_parent_process_Rec.fin_certification_id, p_org_id, p_process_id);
    FETCH Get_old_cert_opinion_id INTO M_opinion_log_id;
    CLOSE Get_old_cert_opinion_id;

IF(m_opinion_log_id IS NULL OR m_opinion_log_id = 0 ) THEN -- a new certification
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b  *******************************************
**********(( get_all_org_cert_rec.number_of_sub_procs_certified  + 1  >  get_all_org_cert_rec.total_number_of_procs) ********/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(get_parent_process_rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR (get_parent_process_rec.number_of_sub_procs_certified  + 1  <  get_parent_process_rec.total_number_of_sub_procs) )THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(get_parent_process_rec.fin_certification_id) := get_parent_process_rec.fin_certification_id;
ELSE
***************/
UPDATE amw_fin_process_eval_sum
SET
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id,
       number_of_sub_procs_certified = number_of_sub_procs_certified + 1
        WHERE fin_certification_id = get_parent_process_rec.fin_certification_id
	AND organization_id  = get_parent_process_rec.organization_id
	AND process_id = get_parent_process_rec.process_id;
--END IF;
END IF;

 END LOOP;

  END IF; --end of p_action = CERTIFICATION


  x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
       ROLLBACK TO PROCESS_CHANGE_HANDLER;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;

END PROCESS_CHANGE_HANDLER;


PROCEDURE ORGANIZATION_CHANGE_HANDLER
(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_org_id 		IN 	NUMBER,
p_opinion_log_id 	IN	NUMBER,
p_action 		IN 	VARCHAR2,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
)
IS
---CURSOR TO GET ALL OF FINANCIAL ITEMS WHICH RELATE TO THIS ORGANIZATION
CURSOR Get_all_items( l_org_id number)IS
SELECT DISTINCT fin.FIN_CERTIFICATION_ID, fin.STATEMENT_GROUP_ID, fin.FINANCIAL_STATEMENT_ID, fin.FINANCIAL_ITEM_ID
FROM AMW_FIN_CERT_SCOPE fin,
     AMW_CERTIFICATION_B cert
WHERE fin.ORGANIZATION_ID = l_org_id
AND  fin.FINANCIAL_ITEM_ID IS NOT NULL
AND  fin.FIN_CERTIFICATION_ID = cert.CERTIFICATION_ID
AND  cert.CERTIFICATION_STATUS IN ('ACTIVE', 'DRAFT');

---CURSOR TO GET ALL OF ACCOUNTS WHICH RELATE TO THIS ORGANIZATION
CURSOR 	Get_all_accts (l_org_id number)IS
SELECT DISTINCT fin.fin_certification_id, fin.account_group_id, fin.natural_account_id
FROM AMW_FIN_CERT_SCOPE fin,
     AMW_CERTIFICATION_B cert
WHERE fin.ORGANIZATION_ID = l_org_id
AND   fin.natural_account_id is not null
AND  fin.FIN_CERTIFICATION_ID = cert.CERTIFICATION_ID
AND  cert.CERTIFICATION_STATUS IN ('ACTIVE', 'DRAFT');


--CURSOR TO GET ALL OF FINANCIAL CERTIFICATION WHICH RELATE THIS ORGANIZATION
CURSOR Get_all_fin_cert(l_org_id number) IS
SELECT org.FIN_CERTIFICATION_ID
FROM AMW_FIN_ORG_EVAL_SUM org,
     AMW_CERTIFICATION_B cert
WHERE org.organization_id = l_org_id
AND org.FIN_CERTIFICATION_ID = cert.CERTIFICATION_ID
AND cert.CERTIFICATION_STATUS IN ('ACTIVE', 'DRAFT');


--CURSOR TO GET OLD EVAL OPINION LOG ID
CURSOR Get_old_opinion_id(l_cert_id number, l_org_id number) IS
SELECT DISTINCT EVAL_OPINION_LOG_ID
FROM AMW_FIN_ORG_EVAL_SUM
WHERE  FIN_CERTIFICATION_ID = l_cert_id
AND ORGANIZATION_ID = l_org_id;

--CURSOR TO GET OLD CERT OPINION LOG ID
CURSOR Get_old_cert_opinion_id(l_cert_id number, l_org_id number) IS
SELECT DISTINCT CERT_OPINION_LOG_ID
FROM AMW_FIN_ORG_EVAL_SUM
WHERE  FIN_CERTIFICATION_ID = l_cert_id
AND ORGANIZATION_ID = l_org_id;

--CURSOR TO GET ORGANIZATION INFORMATION FOR ITEM
    CURSOR Get_Item_Org(l_cert_id number, l_stmt_id number, l_item_id number) IS
    SELECT ORG_WITH_INEFFECTIVE_CONTROLS, ORGS_EVALUATED, TOTAL_NUMBER_OF_ORGS
    FROM AMW_FIN_CERT_EVAL_SUM
    WHERE FIN_CERTIFICATION_ID = l_cert_id
    AND FINANCIAL_STATEMENT_ID = l_stmt_id
    AND FINANCIAL_ITEM_ID = l_item_id
    AND OBJECT_TYPE = 'FINANCIAL ITEM';

--CURSOR TO GET ORGANIZATION INFORMATION FOR ACCOUNT
    CURSOR Get_Acc_Org(l_cert_id number, l_acct_group_id  number, l_acct_id number) IS
      SELECT ORG_WITH_INEFFECTIVE_CONTROLS, ORGS_EVALUATED, TOTAL_NUMBER_OF_ORGS
    FROM AMW_FIN_CERT_EVAL_SUM
    WHERE FIN_CERTIFICATION_ID =  l_cert_id
       AND ACCOUNT_GROUP_ID = l_acct_group_id
       AND NATURAL_ACCOUNT_ID = l_acct_id
       AND OBJECT_TYPE = 'ACCOUNT';


M_item_org_with_ineff_ctrl number;
M_item_org_evaluated number;
M_item_total_orgs number;

M_item_proc_pending_cert  number;
M_item_total_number_process number;
M_item_proc_cert_with_issue number;

M_acc_org_with_ineff_ctrl number;
M_acc_org_evaluated number;
M_acc_total_orgs number;

M_acc_proc_pending_cert  number;
M_acc_total_number_process number;
M_acc_proc_cert_with_issue number;
M_acc_proc_with_ineff_ctrl number;

M_opinion_log_id AMW_OPINIONS_LOG.OPINION_LOG_ID%TYPE;

M_change_flag VARCHAR2(1);
M_new_flag VARCHAR2(1) := 'N';

l_error_message varchar2(4000);


l_api_name           CONSTANT VARCHAR2(30) := 'ORGANIZATION_CHANGE_HANDLER';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

SAVEPOINT ORGANIZATION_CHANGE_HANDLER;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;



--modify fin_cert_eval summary table
IF (p_action = 'EVALUATION') THEN
FOR Get_all_items_Rec in Get_all_items(p_org_id) LOOP
	 exit when Get_all_items %notfound;


    OPEN Get_old_opinion_id(Get_all_items_Rec.FIN_CERTIFICATION_ID, p_org_id);
    FETCH Get_old_opinion_id INTO M_opinion_log_id;
    CLOSE Get_old_opinion_id;

    OPEN Get_Item_Org(Get_all_items_Rec.FIN_CERTIFICATION_ID, Get_all_items_Rec.FINANCIAL_STATEMENT_ID,
    Get_all_items_Rec.FINANCIAL_ITEM_ID);
    FETCH Get_Item_Org  INTO M_item_org_with_ineff_ctrl, M_item_org_evaluated, M_item_total_orgs;
    CLOSE Get_Item_Org;

	Is_Eval_Change (
    		old_opinion_log_id  => M_opinion_log_id ,
    		new_opinion_log_id  => p_opinion_log_id,
    		x_change_flag	=> M_change_flag);


    IF(M_opinion_log_id = 0 OR M_opinion_log_id IS NULL) THEN  -- a new evaluation
         M_new_flag := 'Y';
 /********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********(m_item_org_evaluated + 1 > m_item_total_orgs)*******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(Get_all_items_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR(m_item_org_evaluated + 1 < m_item_total_orgs) )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_items_Rec.fin_certification_id) := Get_all_items_Rec.fin_certification_id;
ELSE
****************/
UPDATE AMW_FIN_CERT_EVAL_SUM
        SET
        orgs_evaluated = least(orgs_evaluated + 1, total_number_of_orgs),
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id
        WHERE FIN_CERTIFICATION_ID = Get_all_items_Rec.FIN_CERTIFICATION_ID
        AND FINANCIAL_STATEMENT_ID = Get_all_items_Rec.FINANCIAL_STATEMENT_ID
        AND FINANCIAL_ITEM_ID = Get_all_items_Rec.FINANCIAL_ITEM_ID
        AND OBJECT_TYPE = 'FINANCIAL ITEM';
--    END IF;
END IF;
        IF (M_change_flag = 'B') THEN
 /********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********(m_item_org_with_ineff_ctrl + 1 >  m_item_org_evaluated) *******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(Get_all_items_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR(m_item_org_with_ineff_ctrl + 1 <  m_item_org_evaluated)  )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_items_Rec.fin_certification_id) := Get_all_items_Rec.fin_certification_id;
ELSE
*************/
UPDATE AMW_FIN_CERT_EVAL_SUM
        SET
        org_with_ineffective_controls = least(org_with_ineffective_controls + 1, orgs_evaluated),
        org_with_ineff_controls_prcnt = round( (least(org_with_ineffective_controls + 1, orgs_evaluated, total_number_of_orgs) )/decode(nvl(total_number_of_orgs, 0), 0, 1, total_number_of_orgs), 2) * 100,
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id
        WHERE FIN_CERTIFICATION_ID = Get_all_items_Rec.FIN_CERTIFICATION_ID
       AND FINANCIAL_STATEMENT_ID = Get_all_items_Rec.FINANCIAL_STATEMENT_ID
        AND FINANCIAL_ITEM_ID = Get_all_items_Rec.FINANCIAL_ITEM_ID
        AND OBJECT_TYPE = 'FINANCIAL ITEM';
-- END IF;
        ELSIF (M_change_flag = 'F'  and M_new_flag = 'N')  THEN
 /********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********(m_item_org_with_ineff_ctrl - 1 < 0 ) *******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(Get_all_items_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR(m_item_org_with_ineff_ctrl - 1 > 0 )  )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_items_Rec.fin_certification_id) := Get_all_items_Rec.fin_certification_id;
ELSE
***************/
UPDATE AMW_FIN_CERT_EVAL_SUM
        SET
        org_with_ineffective_controls = greatest(0,org_with_ineffective_controls - 1),
        org_with_ineff_controls_prcnt = round( (greatest(0, m_item_org_with_ineff_ctrl - 1) )/decode(nvl(m_item_total_orgs, 0), 0, 1, m_item_total_orgs), 2) * 100,
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id
        WHERE FIN_CERTIFICATION_ID = Get_all_items_Rec.FIN_CERTIFICATION_ID
        AND FINANCIAL_STATEMENT_ID = Get_all_items_Rec.FINANCIAL_STATEMENT_ID
        AND FINANCIAL_ITEM_ID = Get_all_items_Rec.FINANCIAL_ITEM_ID
        AND OBJECT_TYPE = 'FINANCIAL ITEM';
--END IF;
        END IF;

    END LOOP;

    FOR Get_all_accts_Rec IN Get_all_accts(p_org_id) LOOP
           exit when Get_all_accts%notfound;

     OPEN Get_old_opinion_id(Get_all_accts_Rec.FIN_CERTIFICATION_ID, p_org_id);
    FETCH Get_old_opinion_id INTO M_opinion_log_id;
    CLOSE Get_old_opinion_id;



   OPEN Get_Acc_Org(Get_all_accts_Rec.FIN_CERTIFICATION_ID, Get_all_accts_Rec.ACCOUNT_GROUP_ID,
   Get_all_accts_Rec.NATURAL_ACCOUNT_ID);
   FETCH Get_Acc_Org  INTO M_acc_org_with_ineff_ctrl, M_acc_org_evaluated, M_acc_total_orgs;
   CLOSE Get_Acc_Org;

   Is_Eval_Change(
    		old_opinion_log_id  =>  M_opinion_log_id ,
    		new_opinion_log_id  =>  p_opinion_log_id,
    		x_change_flag	=> M_change_flag);

        IF(M_opinion_log_id = 0 OR M_opinion_log_id IS NULL) THEN  --  a new evaluation
         M_new_flag := 'Y';
 /********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********(m_acc_org_evaluated + 1 > m_acc_total_orgs)  *******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(Get_all_accts_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR(m_acc_org_evaluated + 1 < m_acc_total_orgs)   )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_accts_Rec.fin_certification_id) := Get_all_accts_Rec.fin_certification_id;
ELSE
****************/
   UPDATE AMW_FIN_CERT_EVAL_SUM
        SET
        orgs_evaluated = least(orgs_evaluated + 1, total_number_of_orgs),
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id
        WHERE FIN_CERTIFICATION_ID = Get_all_accts_Rec.FIN_CERTIFICATION_ID
       AND ACCOUNT_GROUP_ID = Get_all_accts_Rec.ACCOUNT_GROUP_ID
       AND NATURAL_ACCOUNT_ID = Get_all_accts_Rec.NATURAL_ACCOUNT_ID
       AND OBJECT_TYPE = 'ACCOUNT';
--    END IF;
END IF;
        IF (M_change_flag = 'B') THEN
  /********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********(m_acc_org_with_ineff_ctrl + 1 > m_acc_org_evaluated) *******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(Get_all_accts_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR(m_acc_org_with_ineff_ctrl + 1 < m_acc_org_evaluated)  )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_accts_Rec.fin_certification_id) := Get_all_accts_Rec.fin_certification_id;
ELSE
**************/
  UPDATE AMW_FIN_CERT_EVAL_SUM
        SET
        org_with_ineffective_controls = least(org_with_ineffective_controls + 1, orgs_evaluated),
        proc_with_ineff_controls_prcnt = round( (least(m_acc_org_with_ineff_ctrl + 1, orgs_evaluated))/decode(nvl(m_acc_total_orgs, 0), 0, 1, m_acc_total_orgs), 2) * 100,
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id
        WHERE FIN_CERTIFICATION_ID = Get_all_accts_Rec.FIN_CERTIFICATION_ID
       AND ACCOUNT_GROUP_ID = Get_all_accts_Rec.ACCOUNT_GROUP_ID
       AND NATURAL_ACCOUNT_ID = Get_all_accts_Rec.NATURAL_ACCOUNT_ID
       AND OBJECT_TYPE = 'ACCOUNT';
-- END IF;
        ELSIF (M_change_flag = 'F'  and M_new_flag = 'N' )  THEN
   /********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********(m_acc_org_with_ineff_ctrl - 1 < 0 )   *******************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(Get_all_accts_Rec.fin_certification_id)) OR (g_refresh_flag = 'Y') OR(m_acc_org_with_ineff_ctrl - 1 > 0 )    )  THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(Get_all_accts_Rec.fin_certification_id) := Get_all_accts_Rec.fin_certification_id;
ELSE
*******************/
 UPDATE AMW_FIN_CERT_EVAL_SUM
        SET
        org_with_ineffective_controls = greatest(0, org_with_ineffective_controls - 1),
        proc_with_ineff_controls_prcnt = round( (m_acc_org_with_ineff_ctrl - 1)/decode(nvl(m_acc_total_orgs, 0), 0, 1, m_acc_total_orgs), 2) * 100,
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id
        WHERE FIN_CERTIFICATION_ID = Get_all_accts_Rec.FIN_CERTIFICATION_ID
        AND ACCOUNT_GROUP_ID = Get_all_accts_Rec.ACCOUNT_GROUP_ID
        AND NATURAL_ACCOUNT_ID = Get_all_accts_Rec.NATURAL_ACCOUNT_ID
        AND OBJECT_TYPE = 'ACCOUNT';
--END IF;
        END IF;


 END LOOP;

END IF;

/**** Since we don't store pending or certified with issue informaton about organization in fin-cert
****** this part is saved for future use **************/
IF (p_action = 'CERTIFICATION') THEN
 null;
/**************

FOR Get_all_items_Rec in Get_all_items(p_org_id) LOOP
	 exit when Get_all_items %notfound;

IF(M_opinion_log_id IS NULL OR M_opinion_log_id = 0 ) THEN -- a new certification
         M_new_flag := 'Y';

        UPDATE AMW_FIN_CERT_EVAL_SUM SET
        LAST_UPDATE_DATE = sysdate,
         last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id,
        orgs_for_cert_done =  least(orgs_for_cert_done + 1, total_number_of_orgs)
        WHERE FIN_CERTIFICATION_ID = Get_all_items_Rec.FIN_CERTIFICATION_ID
	AND FINANCIAL_STATEMENT_ID = Get_all_items_Rec.FINANCIAL_STATEMENT_ID
        AND FINANCIAL_ITEM_ID = Get_all_items_Rec.FINANCIAL_ITEM_ID
        AND OBJECT_TYPE = 'FINANCIAL ITEM';
        END IF;

  END LOOP;

  FOR Get_all_accts_Rec IN Get_all_accts(p_org_id) LOOP
           exit when Get_all_accts%notfound;


        IF(M_opinion_log_id IS NULL OR M_opinion_log_id = 0 ) THEN  --new certification
    		 M_new_flag := 'Y';

        UPDATE AMW_FIN_CERT_EVAL_SUM SET
        LAST_UPDATE_DATE = sysdate,
         last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.conc_login_id,
        orgs_for_cert_done =  least(orgs_for_cert_done + 1, total_number_of_orgs)
        WHERE FIN_CERTIFICATION_ID = Get_all_accts_Rec.FIN_CERTIFICATION_ID
       AND ACCOUNT_GROUP_ID = Get_all_accts_Rec.ACCOUNT_GROUP_ID
       AND NATURAL_ACCOUNT_ID = Get_all_accts_Rec.NATURAL_ACCOUNT_ID
       AND OBJECT_TYPE = 'ACCOUNT';
        END IF;

 END LOOP; --end of account loop
   ******************/

  END IF; --end of p_action = CERTIFICATION


 -- nothing need to modify in process_eval summary tables

 ---nothing need to modify in dashboard, org_eval summary tables

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
       ROLLBACK TO ORGANIZATION_CHANGE_HANDLER;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;

END ORGANIZATION_CHANGE_HANDLER;

---------------------------------The following procedures are only for migration purpose------------
---------------------------------name convention is the regular procedure name_M ------------------
PROCEDURE Populate_Fin_Risk_Ass_Sum_M(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
) IS

CURSOR c_finrisks IS
SELECT
	risks.risk_id,
	risks.PK1,
	risks.PK2,
	risks.ASSOCIATION_CREATION_DATE,
	risks.APPROVAL_DATE,
	risks.DELETION_DATE,
	risks.DELETION_APPROVAL_DATE,
	risk.RISK_REV_ID
FROM
	AMW_RISK_ASSOCIATIONS risks,
	AMW_FIN_PROCESS_EVAL_SUM eval,
	AMW_RISKS_B risk
WHERE
	eval.fin_certification_id = p_certification_id
	and risk.risk_id = risks.risk_id
	and risk.CURR_APPROVED_FLAG = 'Y'
	and risks.object_type='PROCESS_ORG'
	and risks.PK1 = eval.organization_id
	and risks.PK2 = eval.process_id
	and risks.approval_date is not null
	and risks.approval_date <= sysdate
	and risks.deletion_approval_date is null
UNION ALL
SELECT
	risks.risk_id,
	risks.PK1,
	risks.PK2,
	risks.ASSOCIATION_CREATION_DATE,
	risks.APPROVAL_DATE,
	risks.DELETION_DATE,
	risks.DELETION_APPROVAL_DATE,
	risk.RISK_REV_ID
FROM
	AMW_RISK_ASSOCIATIONS risks,
	AMW_FIN_PROCESS_EVAL_SUM eval,
	AMW_RISKS_B risk
WHERE
	eval.fin_certification_id = p_certification_id
	and risk.risk_id = risks.risk_id
	and risk.CURR_APPROVED_FLAG = 'Y'
	and risks.object_type='ENTITY_RISK'
	and risks.PK1 = eval.organization_id
	and risks.approval_date is not null
	and risks.approval_date <= sysdate
	and risks.deletion_approval_date is null;

	--in risk association table, if type = 'PROCESS_FINCERT', pk1=certification_id, pk2=organization_id, pk3=process_id, pk4=opinion_log_id
	CURSOR last_evaluation(l_risk_id number, l_organization_id number, l_process_id number)  IS
        select distinct ao.opinion_log_id
	from    AMW_OPINIONS_LOG ao,
     		AMW_OBJECT_OPINION_TYPES aoot,
     		AMW_OPINION_TYPES_B aot,
     		FND_OBJECTS fo
	where   ao.OBJECT_OPINION_TYPE_ID = aoot.OBJECT_OPINION_TYPE_ID
		and aoot.OPINION_TYPE_ID = aot.OPINION_TYPE_ID
		and aoot.OBJECT_ID = fo.OBJECT_ID
		and fo.obj_name = 'AMW_ORG_PROCESS_RISK'
       		and aot.opinion_type_code = 'EVALUATION'
        	and ao.pk3_value = l_organization_id
        	and ao.pk4_value = l_process_id
        	and ao.pk1_value = l_risk_id
        	--fix bug 5724066
	        AND ao.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = 'CANC')
        	and ao.authored_date = (select max(aov2.authored_date)
                       	             from AMW_OPINIONS aov2
                               	     where aov2.object_opinion_type_id = ao.object_opinion_type_id
                                     and aov2.pk3_value = ao.pk3_value
                                     and aov2.pk1_value = ao.pk1_value
                                     and aov2.pk4_value = ao.pk4_value);

l_count NUMBER;
m_opinion_log_id NUMBER;
l_error_message varchar2(4000);


l_api_name           CONSTANT VARCHAR2(30) := 'Populate_Fin_Risk_Ass_Sum_M';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

	SAVEPOINT Populate_Fin_Risk_Ass_Sum_M;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;


	SELECT COUNT(1) INTO l_count FROM AMW_RISK_ASSOCIATIONS
	WHERE object_type = 'PROCESS_FINCERT'
	AND pk1 = p_certification_id;

	IF (l_count = 0) THEN
	FOR risk_rec IN c_finrisks LOOP
	exit when c_finrisks%notfound;

		m_opinion_log_id := null;
		OPEN last_evaluation(risk_rec.risk_id, risk_rec.pk1, risk_rec.pk2);
		FETCH last_evaluation INTO m_opinion_log_id;
		CLOSE last_evaluation;



		INSERT INTO AMW_RISK_ASSOCIATIONS(
 			       RISK_ASSOCIATION_ID,
			       RISK_ID,
			       PK1,
			       PK2,
			       PK3,
			       PK4,
			       CREATED_BY,
			       CREATION_DATE,
			       LAST_UPDATE_DATE,
			       LAST_UPDATED_BY,
			       LAST_UPDATE_LOGIN,
			       OBJECT_VERSION_NUMBER,
			       OBJECT_TYPE,
			       ASSOCIATION_CREATION_DATE,
			       APPROVAL_DATE,
			       DELETION_DATE,
			       DELETION_APPROVAL_DATE,
			       RISK_REV_ID)
			 VALUES ( amw_risk_associations_s.nextval,
			         risk_rec.risk_id,
			         p_certification_id,
			         risk_rec.PK1,
			         risk_rec.PK2,
			         m_opinion_log_id,
			         FND_GLOBAL.USER_ID,
			       	 SYSDATE,
			         SYSDATE,
			         FND_GLOBAL.USER_ID,
			         FND_GLOBAL.USER_ID,
			         1,
			         'PROCESS_FINCERT',
			         risk_rec.ASSOCIATION_CREATION_DATE,
			         risk_rec.APPROVAL_DATE,
				 risk_rec.DELETION_DATE,
				 risk_rec.DELETION_APPROVAL_DATE,
				 risk_rec.RISK_REV_ID);

		END LOOP;
if(p_commit <> FND_API.g_false)
then commit;
end if;

    	END IF;
x_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION
     WHEN NO_DATA_FOUND THEN
     IF c_finrisks%ISOPEN THEN
      	close c_finrisks;
         END IF;
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
      IF c_finrisks%ISOPEN THEN
      	close c_finrisks;
         END IF;
       ROLLBACK TO Populate_Fin_Risk_Ass_Sum_M;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;

END Populate_Fin_Risk_Ass_Sum_M;


PROCEDURE Populate_Fin_Ctrl_Ass_Sum_M(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
) IS
CURSOR c_fincontrols IS

SELECT
	controls.control_id,
	controls.PK1,
	controls.PK2,
	controls.PK3,
	controls.ASSOCIATION_CREATION_DATE,
	controls.APPROVAL_DATE,
	controls.DELETION_DATE,
	controls.DELETION_APPROVAL_DATE,
	control.CONTROL_REV_ID
FROM
	AMW_RISK_ASSOCIATIONS risks,
	AMW_CONTROL_ASSOCIATIONS controls,
	AMW_CONTROLS_B control
WHERE
	controls.object_type='RISK_ORG'
	and control.CURR_APPROVED_FLAG = 'Y'
	and control.control_id = controls.control_id
	and risks.PK1 = p_certification_id
	and risks.PK2 = controls.PK1
	and risks.PK3 = controls.PK2
	and controls.PK3 = risks.risk_id
	and risks.object_type = 'PROCESS_FINCERT'
UNION ALL
SELECT
	controls.control_id,
	controls.PK1,
	controls.PK2,
	controls.PK3,
	controls.ASSOCIATION_CREATION_DATE,
	controls.APPROVAL_DATE,
	controls.DELETION_DATE,
	controls.DELETION_APPROVAL_DATE,
	control.CONTROL_REV_ID
FROM
	AMW_RISK_ASSOCIATIONS risks,
	AMW_CONTROL_ASSOCIATIONS controls,
	AMW_CONTROLS_B control
WHERE
	controls.object_type='ENTITY_CONTROL'
	and control.CURR_APPROVED_FLAG = 'Y'
	and control.control_id = controls.control_id
	and risks.PK1 = p_certification_id
	and risks.PK2 = controls.PK1
	and risks.PK3 IS NULL
	and controls.PK3 = risks.risk_id
	and risks.object_type = 'PROCESS_FINCERT';



--in control association table, if type = 'RISK_FINCERT', pk1=certification_id, pk2=organization_id, pk3=process_id, pk4=risk_id, pk5=opinion_log_id
	CURSOR last_evaluation(l_organization_id number, l_control_id number)  IS
        select distinct ao.opinion_log_id
	from
     		AMW_OPINIONS_LOG ao,
     		AMW_OBJECT_OPINION_TYPES aoot,
     		AMW_OPINION_TYPES_B aot,
     		FND_OBJECTS fo
	where ao.OBJECT_OPINION_TYPE_ID = aoot.OBJECT_OPINION_TYPE_ID
		and aoot.OPINION_TYPE_ID = aot.OPINION_TYPE_ID
		and aoot.OBJECT_ID = fo.OBJECT_ID
		and fo.obj_name = 'AMW_ORG_CONTROL'
       		and aot.opinion_type_code = 'EVALUATION'
        	and ao.pk3_value = l_organization_id
        	and ao.pk1_value = l_control_id
        	--fix bug 5724066
	        and ao.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = 'CANC')
        	and ao.authored_date = (select max(aov2.authored_date)
                       	             from AMW_OPINIONS aov2
                               	     where aov2.object_opinion_type_id = ao.object_opinion_type_id
                                     and aov2.pk3_value = ao.pk3_value
                                     and aov2.pk1_value = ao.pk1_value);

	l_count NUMBER;
	m_opinion_log_id NUMBER;

l_api_name           CONSTANT VARCHAR2(30) := 'Populate_Fin_Ctrl_Ass_Sum_M';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

	SAVEPOINT Populate_Fin_Ctrl_Ass_Sum_M;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;


	SELECT COUNT(1) INTO l_count FROM AMW_CONTROL_ASSOCIATIONS
	WHERE OBJECT_TYPE = 'RISK_FINCERT'
	and PK1 = p_certification_id;

	IF (l_count = 0) THEN
	FOR control_rec IN c_fincontrols LOOP
	exit when c_fincontrols%notfound;

	m_opinion_log_id := null;
	OPEN last_evaluation(control_rec.pk1, control_rec.control_id);
	FETCH last_evaluation INTO m_opinion_log_id;
	CLOSE last_evaluation;

		INSERT INTO AMW_CONTROL_ASSOCIATIONS(
 			       CONTROL_ASSOCIATION_ID,
			       CONTROL_ID,
			       PK1,
			       PK2,
			       PK3,
			       PK4,
			       PK5,
			       CREATED_BY,
			       CREATION_DATE,
			       LAST_UPDATE_DATE,
			       LAST_UPDATED_BY,
			       LAST_UPDATE_LOGIN,
			       OBJECT_VERSION_NUMBER,
			       OBJECT_TYPE,
			       ASSOCIATION_CREATION_DATE,
			       APPROVAL_DATE,
			       DELETION_DATE,
			       DELETION_APPROVAL_DATE,
			       CONTROL_REV_ID)
			 VALUES (AMW_CONTROL_ASSOCIATIONS_S.nextval,
			         control_rec.control_id,
			         p_certification_id,
			         control_rec.PK1,
			         control_rec.PK2,
			         control_rec.PK3,
			         m_opinion_log_id,
			         FND_GLOBAL.USER_ID,
			       	 SYSDATE,
			         SYSDATE,
			         FND_GLOBAL.USER_ID,
			         FND_GLOBAL.USER_ID,
			         1,
			         'RISK_FINCERT',
			         control_rec.ASSOCIATION_CREATION_DATE,
	 		         control_rec.APPROVAL_DATE,
			         control_rec.DELETION_DATE,
			        control_rec.DELETION_APPROVAL_DATE,
			        control_rec.CONTROL_REV_ID);

		END LOOP;
if(p_commit <> FND_API.g_false)
then commit;
end if;
	END IF;
	   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     IF c_fincontrols%ISOPEN THEN
      	close c_fincontrols;
      END IF;
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
      IF c_fincontrols%ISOPEN THEN
      	close c_fincontrols;
      END IF;
       ROLLBACK TO Populate_Fin_Ctrl_Ass_Sum_M;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;

END Populate_Fin_Ctrl_Ass_Sum_M;


-------------populate control association which related to financial certification ----
PROCEDURE Populate_Fin_AP_Ass_Sum_M(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
) IS

CURSOR c_finap IS
SELECT
	ap.AUDIT_PROCEDURE_ID,
	ap.PK1,
	ap.PK2,
	ap.PK3,
	ap.ASSOCIATION_CREATION_DATE,
	ap.APPROVAL_DATE,
	ap.DELETION_DATE,
	ap.DELETION_APPROVAL_DATE,
	apb.AUDIT_PROCEDURE_REV_ID
FROM
	AMW_AP_ASSOCIATIONS ap,
	AMW_CONTROL_ASSOCIATIONS controls,
	AMW_AUDIT_PROCEDURES_B apb
WHERE
	ap.object_type='CTRL_ORG'
	and apb.CURR_APPROVED_FLAG = 'Y'
	and ap.audit_procedure_id = apb.audit_procedure_id
	and controls.PK1 = p_certification_id
	and controls.PK2 = ap.PK1
	and controls.PK2 = ap.PK2
	and controls.control_id = ap.PK3
	and controls.object_type = 'RISK_FINCERT'
UNION ALL
SELECT
	ap.AUDIT_PROCEDURE_ID,
	ap.PK1,
	ap.PK2,
	ap.PK3,
	ap.ASSOCIATION_CREATION_DATE,
	ap.APPROVAL_DATE,
	ap.DELETION_DATE,
	ap.DELETION_APPROVAL_DATE,
	apb.AUDIT_PROCEDURE_REV_ID
FROM
	AMW_AP_ASSOCIATIONS ap,
	AMW_CONTROL_ASSOCIATIONS controls,
	AMW_AUDIT_PROCEDURES_B apb
WHERE
	ap.object_type='ENTITY_CTRL_AP'
	and apb.CURR_APPROVED_FLAG = 'Y'
	and ap.audit_procedure_id = apb.audit_procedure_id
	and controls.PK1 = p_certification_id
	and controls.PK2 = ap.PK1
	--and controls.PK3 = ap.PK2
	and controls.PK3 is null
	and controls.control_id = ap.PK3
	and controls.object_type = 'RISK_FINCERT';

--need check opinion framework doc
--in ap association table, if type = 'CTRL_FINCERT', pk1=certification_id, pk2=organization_id, pk3=process_id, pk4=control_id, pk5=opinion_id
CURSOR last_evaluation(l_audit_procedure_id number, l_organization_id number, l_control_id number)  IS
SELECT 	distinct aov.opinion_id
FROM 	AMW_OPINION_M_V aov
WHERE
                aov.object_name = 'AMW_ORG_AP_CONTROL'
        AND 	aov.opinion_type_code = 'EVALUATION'
        AND 	aov.opinion_component_code = 'OVERALL'
        AND 	aov.pk3_value = l_organization_id
        AND 	aov.pk4_value = l_audit_procedure_id
        AND	aov.pk1_value = l_control_id
        --fix bug 5724066
	AND     aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = 'CANC')
        AND 	aov.authored_date = (select max(aov2.authored_date)
                       	             from AMW_OPINIONS aov2
                               	     where aov2.object_opinion_type_id = aov.object_opinion_type_id
                                     and aov2.pk3_value = aov.pk3_value
                                     and aov2.pk1_value = aov.pk1_value
                                     and aov2.pk4_value = aov.pk4_value);


	l_count NUMBER;
	m_opinion_id NUMBER;


l_api_name           CONSTANT VARCHAR2(30) := 'Populate_Fin_AP_Ass_Sum_M';
l_api_version_number CONSTANT NUMBER  := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

   SAVEPOINT Populate_Fin_AP_Ass_Sum_M;

 -- Standard call to check for call compatibility.

        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;



	SELECT COUNT(1) INTO l_count FROM AMW_AP_ASSOCIATIONS
	WHERE OBJECT_TYPE = 'CTRL_FINCERT'
	and PK1 = p_certification_id;

	IF (l_count = 0) THEN
	FOR ap_rec IN c_finap LOOP
	exit when c_finap%notfound;

	m_opinion_id := null;
	OPEN last_evaluation(ap_rec.audit_procedure_id, ap_rec.pk1, ap_rec.pk3);
	FETCH last_evaluation INTO m_opinion_id;
	CLOSE last_evaluation;


		INSERT INTO AMW_AP_ASSOCIATIONS(
			       AP_ASSOCIATION_ID,
 			       AUDIT_PROCEDURE_ID,
			       PK1,
			       PK2,
			       PK3,
			       PK4,
			       PK5,
			       CREATED_BY,
			       CREATION_DATE,
			       LAST_UPDATE_DATE,
			       LAST_UPDATED_BY,
			       LAST_UPDATE_LOGIN,
			       OBJECT_VERSION_NUMBER,
			       OBJECT_TYPE,
			       ASSOCIATION_CREATION_DATE,
			       APPROVAL_DATE,
			       DELETION_DATE,
			       DELETION_APPROVAL_DATE,
			       AUDIT_PROCEDURE_REV_ID)
			 VALUES (AMW_AP_ASSOCIATIONS_S.nextval,
			         ap_rec.audit_procedure_id,
			         p_certification_id,
			         ap_rec.PK1,
			         ap_rec.PK2,
			         ap_rec.PK3,
			         m_opinion_id,
			         FND_GLOBAL.USER_ID,
			         SYSDATE,
			         SYSDATE,
			         FND_GLOBAL.USER_ID,
			         FND_GLOBAL.USER_ID,
			         1,
			         'CTRL_FINCERT',
			         ap_rec.ASSOCIATION_CREATION_DATE,
	 		         ap_rec.APPROVAL_DATE,
			         ap_rec.DELETION_DATE,
			         ap_rec.DELETION_APPROVAL_DATE,
			         ap_rec.AUDIT_PROCEDURE_REV_ID);


		END LOOP;
if(p_commit <> FND_API.g_false)
then commit;
end if;
	END IF;
	x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     IF c_finap%ISOPEN THEN
      	close c_finap;
      END IF;
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
      IF c_finap%ISOPEN THEN
      	close c_finap;
      END IF;
      ROLLBACK TO Populate_Fin_AP_Ass_Sum_M;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;

END Populate_Fin_AP_Ass_Sum_M;


FUNCTION  Get_Proc_Verified_M
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN NUMBER

IS
l_stmt VARCHAR2(2000);
	l_stmt1 VARCHAR2(100);
	l_stmt2 VARCHAR2(100);
	l_sql_stmt VARCHAR2(2000);

	X_PROC_VERIFIED Number;
BEGIN

l_stmt1 := ' AND FIN.STATEMENT_GROUP_ID = :2 AND FIN.FINANCIAL_STATEMENT_ID = :3 AND FIN.FINANCIAL_ITEM_ID = :4)';
l_stmt2 := ' AND FIN.NATURAL_ACCOUNT_ID = :2)';

        l_stmt := 'SELECT COUNT(1) FROM
 	(Select distinct  fin.PROCESS_ID, fin.ORGANIZATION_ID
	FROM
	AMW_OPINION_M_V aov,
	amw_fin_cert_scope fin
	WHERE aov.OPINION_TYPE_CODE = ''EVALUATION''
        and aov.object_name = ''AMW_ORG_PROCESS''
        and aov.opinion_component_code = ''OVERALL''
        and aov.PK3_VALUE = fin.ORGANIZATION_ID
        and aov.PK1_VALUE = fin.PROCESS_ID
        --fix bug 5724066
	and aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = ''CANC'')
        and fin.process_id is not null
        and fin.FIN_CERTIFICATION_ID = :1 ';

IF P_OBJECT_TYPE = 'FINANCIAL ITEM' THEN
        l_sql_stmt := l_stmt || l_stmt1;

        EXECUTE IMMEDIATE l_sql_stmt INTO X_PROC_VERIFIED USING P_CERTIFICATION_ID, P_STATEMENT_GROUP_ID, P_FINANCIAL_STATEMENT_ID, P_FINANCIAL_ITEM_ID ;

ELSIF P_OBJECT_TYPE = 'ACCOUNT' THEN
        l_sql_stmt := l_stmt || l_stmt2;
        EXECUTE IMMEDIATE l_sql_stmt INTO X_PROC_VERIFIED USING P_CERTIFICATION_ID, P_ACCOUNT_ID ;
END IF;

        RETURN X_PROC_VERIFIED;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*** Record doesn't exist ***/
    fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.Get_Proc_Verified_M');
    RETURN 0;
  WHEN OTHERS THEN
    /*** Raise any other error ***/
    fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.Get_Proc_Verified_M');
    fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
    RAISE;

END Get_Proc_Verified_M;

FUNCTION Get_ORG_EVALUATED_M
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN NUMBER

IS
	l_stmt VARCHAR2(2000);
	l_stmt1 VARCHAR2(100);
	l_stmt2 VARCHAR2(100);
	l_sql_stmt VARCHAR2(2000);

	X_ORG_EVALUATED  Number;

BEGIN

l_stmt1 := ' AND FIN.STATEMENT_GROUP_ID = :2 AND FIN.FINANCIAL_STATEMENT_ID = :3 AND FIN.FINANCIAL_ITEM_ID = :4)';
l_stmt2 := ' AND FIN.NATURAL_ACCOUNT_ID = :2)';

l_stmt := 'select count(1) from (
select distinct fin.ORGANIZATION_ID
FROM
AMW_OPINION_M_V aov,
amw_fin_cert_scope fin
WHERE aov.OPINION_TYPE_CODE = ''EVALUATION''
and aov.object_name = ''AMW_ORGANIZATION''
and aov.opinion_component_code = ''OVERALL''
and aov.pk1_value = fin.organization_id
--fix bug 5724066
and aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = ''CANC'')
and fin.FIN_CERTIFICATION_ID= :1 ';


IF P_OBJECT_TYPE = 'FINANCIAL ITEM' THEN
        l_sql_stmt := l_stmt || l_stmt1;
        EXECUTE IMMEDIATE l_sql_stmt INTO X_ORG_EVALUATED USING P_CERTIFICATION_ID, P_STATEMENT_GROUP_ID, P_FINANCIAL_STATEMENT_ID, P_FINANCIAL_ITEM_ID ;
ELSIF P_OBJECT_TYPE = 'ACCOUNT' THEN
        l_sql_stmt := l_stmt || l_stmt2;

        EXECUTE IMMEDIATE l_sql_stmt INTO X_ORG_EVALUATED USING P_CERTIFICATION_ID, P_ACCOUNT_ID ;
END IF;

                RETURN X_ORG_EVALUATED;

 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*** Record doesn't exist ***/
    fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.Get_ORG_EVALUATED_M');
    RETURN 0;
  WHEN OTHERS THEN
    /*** Raise any other error ***/
    fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.Get_ORG_EVALUATED_M');
fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
    RAISE;

END Get_ORG_EVALUATED_M;

FUNCTION Get_RISKS_VERIFIED_M
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN NUMBER

IS
	l_stmt VARCHAR2(2000);
	l_stmt1 VARCHAR2(100);
	l_stmt2 VARCHAR2(100);
	l_sql_stmt VARCHAR2(2000);

	X_RISKS_VERIFIED  Number;
BEGIN

l_stmt1 := ' AND FIN.STATEMENT_GROUP_ID = :2 AND FIN.FINANCIAL_STATEMENT_ID = :3 AND FIN.FINANCIAL_ITEM_ID = :4)';
l_stmt2 := ' AND FIN.NATURAL_ACCOUNT_ID = :2)';

/*********** replace with the following query that uses opinion_log_id directly
l_stmt := 'select count(1)  from (
select distinct  fin.risk_id ,fin.organization_id, fin.Process_ID
FROM
	AMW_OPINION_M_V aov,
	amw_fin_item_acc_risk fin
WHERE
aov.OPINION_TYPE_CODE = ''EVALUATION''
and aov.object_name = ''AMW_ORG_PROCESS_RISK''
and aov.opinion_component_code = ''OVERALL''
and aov.pk1_value = fin.risk_id
and aov.pk3_value = fin.organization_id
and aov.pk4_value = fin.process_ID
--fix bug 5724066
and aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = ''CANC'')
and fin.object_type = ''' || P_OBJECT_TYPE || '''' || '
and fin.FIN_CERTIFICATION_ID= :1 ';
************/

l_stmt := 'select count(1)  from (
select distinct  fin.risk_id ,fin.organization_id, fin.Process_ID
FROM
	amw_opinion_m_v aov,
	amw_opinions_log aol,
	amw_fin_item_acc_risk fin
WHERE
aov.OPINION_TYPE_CODE = ''EVALUATION''
and aov.object_name = ''AMW_ORG_PROCESS_RISK''
and aov.opinion_component_code = ''OVERALL''
and aol.opinion_log_id = fin.opinion_log_id
and aol.opinion_id = aov.opinion_id
and aol.opinion_set_id = aov.opinion_set_id
and fin.object_type = ''' || P_OBJECT_TYPE || '''' || '
and fin.FIN_CERTIFICATION_ID= :1 ';

IF P_OBJECT_TYPE = 'FINANCIAL ITEM' THEN
        l_sql_stmt := l_stmt || l_stmt1;

        EXECUTE IMMEDIATE l_sql_stmt INTO X_RISKS_VERIFIED USING P_CERTIFICATION_ID, P_STATEMENT_GROUP_ID, P_FINANCIAL_STATEMENT_ID, P_FINANCIAL_ITEM_ID ;


        ELSIF P_OBJECT_TYPE = 'ACCOUNT' THEN
        l_sql_stmt := l_stmt || l_stmt2;

        EXECUTE IMMEDIATE l_sql_stmt INTO X_RISKS_VERIFIED USING P_CERTIFICATION_ID, P_ACCOUNT_ID ;

        END IF;
                RETURN X_RISKS_VERIFIED;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*** Record doesn't exist ***/
    fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.Get_RISKS_VERIFIED_M');
    RETURN 0;
  WHEN OTHERS THEN
    /*** Raise any other error ***/
fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.Get_RISKS_VERIFIED_M');
fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
    RAISE;

END Get_RISKS_VERIFIED_M;

FUNCTION Get_CONTROLS_VERIFIED_M
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN NUMBER

IS
	l_stmt VARCHAR2(2000);
	l_stmt1 VARCHAR2(100);
	l_stmt2 VARCHAR2(100);
	l_sql_stmt VARCHAR2(2000);

	X_CONTROLS_VERIFIED  Number;


BEGIN

l_stmt1 := ' AND FIN.STATEMENT_GROUP_ID = :2 AND FIN.FINANCIAL_STATEMENT_ID = :3 AND FIN.FINANCIAL_ITEM_ID = :4)';
l_stmt2 := ' AND FIN.NATURAL_ACCOUNT_ID = :2)';

/********replace to use opinion_log_id in amw_fin_item_acc_ctrl
l_stmt := 'select count(1) from(
select distinct  fin.control_id, fin.organization_id
FROM
AMW_OPINION_M_V aov,
amw_fin_item_acc_ctrl fin
WHERE aov.OPINION_TYPE_CODE = ''EVALUATION''
AND aov.object_name = ''AMW_ORG_CONTROL''
and aov.opinion_component_code = ''OVERALL''
AND aov.pk1_value = fin.control_id
AND aov.pk3_value = fin.organization_id
--fix bug 5724066
AND aov.pk2_value not in (select audit_project_id from amw_audit_projects where audit_project_status = ''CANC'')
and fin.object_type = ''' || P_OBJECT_TYPE || '''' || '
and fin.fin_certification_id = :1 ';
****************************/

l_stmt := 'select count(1) from(
select distinct  fin.control_id, fin.organization_id
FROM
amw_opinion_m_v aov,
amw_opinions_log aol,
amw_fin_item_acc_ctrl fin
WHERE aov.OPINION_TYPE_CODE = ''EVALUATION''
and  aov.object_name = ''AMW_ORG_CONTROL''
and aov.opinion_component_code = ''OVERALL''
and aol.opinion_log_id = fin.OPINION_LOG_ID
and aol.opinion_id = aov.opinion_id
and aol.opinion_set_id = aov.opinion_set_id
and fin.object_type = ''' || P_OBJECT_TYPE || '''' || '
and fin.fin_certification_id = :1 ';

IF P_OBJECT_TYPE = 'FINANCIAL ITEM' THEN
        l_sql_stmt := l_stmt || l_stmt1;

        EXECUTE IMMEDIATE l_sql_stmt INTO X_CONTROLS_VERIFIED USING P_CERTIFICATION_ID, P_STATEMENT_GROUP_ID, P_FINANCIAL_STATEMENT_ID, P_FINANCIAL_ITEM_ID ;
        --RETURN X_CONTROLS_VERIFIED;

        ELSIF P_OBJECT_TYPE = 'ACCOUNT' THEN
        l_sql_stmt := l_stmt || l_stmt2;

        EXECUTE IMMEDIATE l_sql_stmt INTO X_CONTROLS_VERIFIED USING P_CERTIFICATION_ID, P_ACCOUNT_ID ;
        --RETURN X_CONTROLS_VERIFIED;
        END IF;
        RETURN X_CONTROLS_VERIFIED;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*** Record doesn't exist ***/
    fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.Get_CONTROLS_VERIFIED_M');
    RETURN 0;
  WHEN OTHERS THEN
    /*** Raise any other error ***/
fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.Get_CONTROLS_VERIFIED_M');
fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
    RAISE;


END Get_CONTROLS_VERIFIED_M;


END AMW_FINSTMT_CERT_BES_PKG;

/
