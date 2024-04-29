--------------------------------------------------------
--  DDL for Package Body QPR_CREATE_AW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_CREATE_AW" AS
/* $Header: QPRUCAWB.pls 120.0 2007/10/11 13:05:32 agbennet noship $ */


function get_measure_code(p_price_plan_id number, p_term_code varchar2) return varchar2
is
o_meas varchar2(100);
begin
   SELECT  c.cube_code||'_'||b.measure_ppa_code
   into o_meas
   from qpr_measures b , qpr_cubes c
   where  b.price_plan_id = p_price_plan_id
   and b.measure_ppa_code = p_term_code
   and c.cube_id=b.cube_id;
   return o_meas;
exception
when others then
	return null;
end;

PROCEDURE CREATE_MODEL (p_price_plan_id number, p_cube_code varchar2) is

CURSOR qprmodels_cur IS
   SELECT a1.model_id, a1.model_name, c.dim_code dim_code
   FROM qpr_models a1, qpr_cube_dims a,
  	qpr_cubes b,  qpr_dimensions c
WHERE a.price_plan_id = p_price_plan_id
 AND b.cube_id = a.cube_id
 AND b.cube_ppa_code = p_cube_code
-- AND c.dim_code = a.dim_code
 and c.price_plan_dim_id = a.price_plan_dim_id
  and a1.model_meas_dim_code = c.dim_ppa_code;

   qprmodels_rec qprmodels_cur%ROWTYPE;
CURSOR qprmodeleqns_cur(modelId Number) IS
   SELECT model_id,execution_sequence,lhs_expression_id,rhs_expression_id,operator
   from qpr_model_equations
   where model_id = modelId
   order by execution_sequence;
   qprmodeleqns_rec qprmodeleqns_cur%ROWTYPE;
CURSOR qprexpressions_cur(exprId Number) IS
   SELECT expression_id,sequence,term_id
   from qpr_expressions
   where expression_id = exprId
   order by sequence;
   qprexpressions_rec qprexpressions_cur%ROWTYPE;

  CURSOR qprterms_cur(termId Number)IS
   SELECT term_id,term_code,term_type
   from qpr_terms
   where term_id = termId;

   qprterms_rec qprterms_cur%ROWTYPE;
   tempString varchar2(4000);
BEGIN
    dbms_aw.execute('aw attach '||'QPR'||p_price_plan_id||' rw;');
    for qprmodels_rec in qprmodels_cur loop
    dbms_aw.execute('define '||qprmodels_rec.model_name||' model ;');
    dbms_aw.execute('consider '||qprmodels_rec.model_name||'; ');
    tempString := 'DIMENSION '||qprmodels_rec.dim_code||'\n';
       for qprmodeleqns_rec in qprmodeleqns_cur(qprmodels_rec.model_id) loop
            for qprexpressions_rec in qprexpressions_cur(qprmodeleqns_rec.lhs_expression_id) loop
               for qprterms_rec in qprterms_cur(qprexpressions_rec.term_id) loop
                   if(qprterms_rec.term_type = 'MEASURE')
                   THEN
			tempString := tempString ||get_measure_code(p_price_plan_id, qprterms_rec.term_code)||'_STORED';
                   ELSE
                   tempString := tempString || qprterms_rec.term_code;
                   END IF;
               end loop;-- terms;
            end loop;-- expressions;
            tempString := tempString || qprmodeleqns_rec.operator;
            for qprexpressions_rec in qprexpressions_cur(qprmodeleqns_rec.rhs_expression_id) loop
               for qprterms_rec in qprterms_cur(qprexpressions_rec.term_id) loop
                                  if(qprterms_rec.term_type = 'MEASURE')
                   THEN
			tempString := tempString ||get_measure_code(p_price_plan_id, qprterms_rec.term_code)||'_STORED';
                   ELSE
                   tempString := tempString || qprterms_rec.term_code;
                   END IF;
               end loop;-- terms;
            end loop;-- expressions;
            tempString := tempString || '\n';
       end loop;-- modeleqns;
 dbms_aw.execute('MODEL JOINLINES( '||''''||tempString||''''||' '||''''||'END;'||''''||')');
 dbms_aw.EXECUTE('update;commit;');

 tempString := '';
 end loop;-- qprmodel;
 dbms_aw.execute('aw detach '||'QPR'||p_price_plan_id||';');
exception
 when others then
 dbms_aw.execute('aw detach '||'QPR'||p_price_plan_id||';');
END;


PROCEDURE SUBMIT_REQUEST_SET(P_PRICE_PLAN_ID IN NUMBER,
			P_REQUEST_ID OUT NOCOPY NUMBER,
			P_STMT_NUM OUT NOCOPY NUMBER,
			ERRBUF OUT NOCOPY VARCHAR2,
			RETCODE OUT NOCOPY VARCHAR2)

IS

--L_STMT_NUM NUMBER;
SUCC BOOLEAN;

BEGIN

--FND_GLOBAL.APPS_INITIALIZE(1008177,60007,667);
P_STMT_NUM := 10;
SUCC := FND_SUBMIT.SET_REQUEST_SET('QPR','FNDRSSUB2064');
P_STMT_NUM := 20;
IF SUCC THEN
	SUCC := FND_SUBMIT.SUBMIT_PROGRAM('QPR','QPRUCAWB','STAGE10',P_PRICE_PLAN_ID);
	P_STMT_NUM :=30;
	IF SUCC THEN
		SUCC := FND_SUBMIT.SUBMIT_PROGRAM('QPR','QPRUC2AWB','STAGE20',P_PRICE_PLAN_ID);
		P_STMT_NUM := 40;
		IF SUCC THEN
			P_REQUEST_ID := FND_SUBMIT.SUBMIT_SET(NULL,FALSE);
			P_STMT_NUM := 50;
		END IF;
	END IF;
END IF;
P_STMT_NUM := 60;
COMMIT;
P_STMT_NUM := 70;

EXCEPTION

WHEN OTHERS THEN
		RETCODE:= SQLCODE;
		ERRBUF := SQLERRM(-RETCODE);
		ERRBUF := errbuf||'-'||' ERROR OCCURED WHILE SUBMITTING REQUEST SET FOR PRICE_PLAN_ID = '||P_PRICE_PLAN_ID||' '||to_char(sysdate, 'hh24:mi:ss')||' '||P_STMT_NUM;
		P_REQUEST_ID := 0;
	--	DBMS_OUTPUT.PUT_LINE(errbuf);

END SUBMIT_REQUEST_SET;




PROCEDURE CREATE_AW ( errbuf OUT NOCOPY VARCHAR2,
			retcode OUT NOCOPY varchar2,
			P_PRICE_PLAN_ID NUMBER)

IS

L_AW_EXISTS2 EXCEPTION;
L_AW_NAME1 VARCHAR2(200);
L_AW_OUTPUT VARCHAR2(200);
L_CLB CLOB;
L_STMTNUM NUMBER;

BEGIN

L_STMTNUM := 10;

SELECT AW_XML,AW_CODE
INTO L_CLB,L_AW_NAME1
FROM QPR_PRICE_PLANS_B
WHERE PRICE_PLAN_ID = P_PRICE_PLAN_ID;

L_STMTNUM := 20;

IF(AW_EXISTS(L_AW_NAME1)) THEN

L_STMTNUM := 30;

l_aw_output := DBMS_AW_XML.EXECUTE(L_CLB);

L_STMTNUM := 40;

DBMS_AW.AW_UPDATE('APPS',L_AW_NAME1);

L_STMTNUM := 50;

L_STMTNUM := 60;

UPDATE QPR_PRICE_PLANS_B
SET AW_CREATED_FLAG = 'Y'
WHERE PRICE_PLAN_ID = P_PRICE_PLAN_ID;
COMMIT;

L_STMTNUM := 70;

create_model(p_price_plan_id, 'DEAL_MOD');

--Update the DML Program in the aw for deal.

qpr_dml_pvt.loaddmlprog(l_aw_name1);

errbuf := errbuf||' '||to_char(sysdate, 'hh24:mi:ss')||' '||'-'||'. ANALYTIC WORKSPACE CREATED '||L_STMTNUM;

ELSE

RAISE L_AW_EXISTS2;

END IF;


EXCEPTION

WHEN L_AW_EXISTS2 THEN

	retcode := SQLCODE;
	errbuf := SQLERRM(-retcode);
	errbuf := errbuf||'-'||' ANALYTIC WORKSPACE '||L_AW_NAME1||' ALREADY EXCISTS IN THE GIVEN SCHEMA.'||to_char(sysdate, 'hh24:mi:ss');

WHEN OTHERS THEN

	retcode := SQLCODE;
	errbuf := SQLERRM(-retcode);
	errbuf := errbuf||'-'||' ERROR OCCURED WHILE CREATING ANALYTIC WORKSPACE '|| L_AW_NAME1||' '||to_char(sysdate, 'hh24:mi:ss')||' '||L_STMTNUM;


END CREATE_AW;



FUNCTION AW_EXISTS(
		P_AW_NAME2 VARCHAR2 )

		RETURN BOOLEAN
IS

L_AW_EXISTS1 EXCEPTION;
L_RES BOOLEAN;
PRAGMA EXCEPTION_INIT (L_AW_EXISTS1,-33262);

BEGIN

DBMS_AW.AW_ATTACH('APPS',P_AW_NAME2,true);
L_RES := FALSE;
RETURN L_RES;

EXCEPTION

WHEN L_AW_EXISTS1 THEN

	L_RES := TRUE;
	RETURN L_RES;

END AW_EXISTS;

procedure create_aw_java(p_price_plan_is NUMBER) as
language java name 'oracle.apps.qpr.etl.aw.AWCreate.runProgram(int)';

PROCEDURE CREATE_AWXML ( errbuf OUT nocopy VARCHAR2, retcode OUT nocopy varchar2,
	P_PRICE_PLAN_ID IN NUMBER) IS
l_dummy number;
begin
--cwm2_olap_manager.set_echo_on;
create_aw_java(p_price_plan_id);

exception
 WHEN others THEN
    retcode := 2;
    errbuf  := 'Unexpected error '||substr(sqlerrm,1200);
end;
END;

/
