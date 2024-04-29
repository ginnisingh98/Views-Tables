--------------------------------------------------------
--  DDL for Package Body QPR_DML_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_DML_PVT" as
/* $Header: QPRDMLSB.pls 120.3 2007/12/03 15:09:11 bhuchand noship $ */
 procedure LOADDMLPROG(awname in varchar2) is
str1 varchar2(10000);
str2 varchar2(10000);
str3 varchar2(10000);

begin
FND_FILE.PUT_LINE(FND_FILE.LOG,'Load DML Programs in AW '||awname);

dbms_aw.execute('aw attach '||awname||' rw');

FND_FILE.PUT_LINE(FND_FILE.LOG,'AW attached in RW Mode ');

str1 := 'define regression program;program;';
str1 := str1 || 'argument pricePlan text;';
str1 := str1 || 'argument prd text;';
str1 := str1 || 'argument cus text;';
str1 := str1 || 'argument psg text;';
str1 := str1 || 'variable prdDim text;';
str1 := str1 || 'variable cusDim text;';
str1 := str1 || 'variable timDim text;';
str1 := str1 || 'variable psgDim text;';
str1 := str1 || 'variable ordDim text;';
str1 := str1 || 'variable ordlevel text;';
str1 := str1 || 'variable salesDataCube text;';
str1 := str1 || 'variable ordQtyMeas text;';
str1 := str1 || 'variable grossRevMeas text;';
str1 := str1 || 'variable counter integer;';
str1 := str1 || 'variable quantity decimal;';
str1 := str1 || 'variable revenue decimal;';
str1 := str1 || 'variable qtySum decimal;';
str1 := str1 || 'variable revSum decimal;';
str1 := str1 || 'variable qtySqr decimal;';
str1 := str1 || 'variable qtyRevPrd decimal;';
str1 := str1 || 'variable slope decimal;';
str1 := str1 || 'variable intercept decimal;';
str1 := str1 || 'counter = 0;';
str1 := str1 || 'qtySum = 0;';
str2 := 'revSum = 0;';
str2 := str2 || 'qtySqr = 0;';
str2 := str2 || 'qtyRevPrd = 0;';
str2 := str2 || 'slope = 0;';
str2 := str2 || 'intercept = 0;';
str2 := str2 || 'SQL SELECT dim_code FROM qpr_dimensions WHERE price_plan_id = to_number(:pricePlan) and  dim_ppa_code = ''TIM'' into :timDim;';
str2 := str2 || 'SQL SELECT dim_code FROM qpr_dimensions WHERE price_plan_id  = to_number(:pricePlan) and dim_ppa_code = ''PRD'' into :prdDim;';
str2 := str2 || 'SQL SELECT dim_code FROM qpr_dimensions WHERE price_plan_id  = to_number(:pricePlan) and dim_ppa_code = ''CUS'' into :cusDim;';
str2 := str2 || 'SQL SELECT dim_code FROM qpr_dimensions WHERE price_plan_id  = to_number(:pricePlan) and dim_ppa_code = ''PSG'' into :psgDim;';
str2 := str2 || 'SQL SELECT dim_code FROM qpr_dimensions WHERE price_plan_id = to_number(:pricePlan) and dim_ppa_code = ''ORD'' into :ordDim;';
str2 := str2 || 'SQL SELECT  cube_code FROM  qpr_cubes WHERE price_plan_id  = to_number(:pricePlan) and  cube_ppa_code = ''PRICE_SALES'' into :salesDataCube;';
str2 := str2 || 'ordQtyMeas = joinchars(salesDataCube, ''_QPR_AO_Q_P'');';
str2 := str2 || 'grossRevMeas = joinchars(salesDataCube, ''_QPR_SP'');';
str2 := str2 || 'ordlevel = joinchars(ordDim, ''_LEVELREL'');';
str2 := str2 || 'allstat;';
str2 := str2 || 'limit &prdDim to prd;';
str2 := str2 || 'limit &timDim to last 1;';
str2 := str2 || 'limit &psgDim to psg;' ;
str2 := str2 || 'limit &ordDim to (&ordlevel eq ''ORDER_LINE'');';
str3 := 'for &ordDim;';
str3 := str3 || 'do;';
str3 := str3 || 'quantity = nafill(&ordQtyMeas, 0);';
str3 := str3 || 'revenue = nafill(&grossRevMeas, 0);';
str3 := str3 || 'qtySum = qtySum + quantity;';
str3 := str3 || 'revSum = revSum + revenue;';
str3 := str3 || 'qtySqr = qtySqr +(quantity * quantity);';
str3 := str3 || 'qtyRevPrd = qtyRevPrd + (revenue * quantity);';
str3 := str3 || ' if(&ordQtyMeas ne NA); ';
str3 := str3 || ' then do; ';
str3 := str3 || '   counter = counter+1;';
str3 := str3 || ' doend;';
str3 := str3 || 'doend;';
str3 := str3 || 'IF(qtySum ne 0);';
str3 := str3 || 'then do;';
str3 := str3 || 'slope = ((counter * qtyRevPrd) - (qtySum * revSum)) / (counter * qtySqr - (qtySum * qtySum));';
str3 := str3 || 'intercept = (revSum - (slope * qtySum)) / counter;';
str3 := str3 || 'doend;';
str3 := str3 || 'ALLSTAT;';
str3 := str3 || 'return(joinchars(slope,''_'',intercept));end;';


dbms_aw.execute(str1 || str2 || str3);

FND_FILE.PUT_LINE(FND_FILE.LOG,'Created Regression DML Program ..... ');



str1 := 'define retoffinv program;program;';
str1 := str1 || 'argument priceplan text;';
str1 := str1 || 'argument offinv_type text;';
str1 := str1 || 'variable oadPerMeas text;';
str1 := str1 || 'variable oadDim text;';
str1 := str1 || 'SQL select dim_code from qpr_dimensions where price_plan_id = to_number(:priceplan) and dim_ppa_code = ''OAD'' into :oadDim;';
str1 := str1 || 'if(isvalue(&oadDim,offinv_type) eq yes);';
str1 := str1 || 'then do;';
str1 := str1 || 'limit &oadDim to offinv_type;';
str1 := str1 || 'SQL select cube_code from qpr_cubes where price_plan_id = to_number(:priceplan) and cube_ppa_code = ''OFF_INV_ADJ'' into :oadPerMeas;';
str1 := str1 || 'oadPerMeas = joinchars(oadPerMeas,''_QPR_AR_PRC'');';
str1 := str1 || 'return nvl(&oadPerMeas,0);';
str1 := str1 || 'doend;';
str1 := str1 || 'else do;';
str1 := str1 || 'return 0;';
str1 := str1 || 'doend;end;';

dbms_aw.execute(str1);

FND_FILE.PUT_LINE(FND_FILE.LOG,'Created RetOffInv DML Program ..... ');

dbms_aw.execute('update;commit;');
FND_FILE.PUT_LINE(FND_FILE.LOG,'UPDATE and COMMIT');

dbms_aw.execute('aw detach '||awname);

FND_FILE.PUT_LINE(FND_FILE.LOG,'AW Detached');

EXCEPTION
when others then
   null;
  FND_FILE.PUT_LINE(FND_FILE.LOG,'Exception in LOAD DML');
end LOADDMLPROG;
end QPR_DML_PVT;

/
