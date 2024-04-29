--------------------------------------------------------
--  DDL for Package Body PA_FP_OF_WEBADI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_OF_WEBADI_PKG" as
/* $Header: PAFPOFWB.pls 120.1 2005/08/19 16:27:24 mwasowic noship $ */

PROCEDURE populate_interface_table
 		 (  p_session_id	   IN   NUMBER,
		    p_budget_version_id    IN   NUMBER,
		    p_amount_type_code     IN   VARCHAR2,
                    x_return_status        OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                    x_msg_count            OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                    x_msg_data             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                   )
IS


v_category_id_tab       PA_FORECAST_GLOB.NumberTabTyp;
v_org_id_tab            PA_FORECAST_GLOB.NumberTabTyp;
l_budget_version_id     NUMBER;
l_amount_type_code      VARCHAR2(30);
l_session_id		NUMBER;
Category_id_tab         PA_FORECAST_GLOB.NumberTabTyp;
Category_tab            PA_FORECAST_GLOB.VCTabTyp;
OU_id_tab               PA_FORECAST_GLOB.NumberTabTyp;
OU_name_tab             PA_FORECAST_GLOB.VCTabTyp;
Organization_Id_tab     PA_FORECAST_GLOB.NumberTabTyp;
Organization_Name_tab   PA_FORECAST_GLOB.VCTabTyp;
Other_OU_Id_tab         PA_FORECAST_GLOB.NumberTabTyp;
Other_OU_Name_tab       PA_FORECAST_GLOB.VCTabTyp;
Other_Organization_Id_tab PA_FORECAST_GLOB.NumberTabTyp;
Other_Organization_Name_tab PA_FORECAST_GLOB.VCTabTyp;
Txn_Project_Name_tab    PA_FORECAST_GLOB.VCTabTyp;
Resource_Name_tab       PA_FORECAST_GLOB.VCTabTyp;
Period1_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period2_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period3_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period4_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period5_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period6_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period7_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period8_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period9_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period10_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period11_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period12_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period13_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period14_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period15_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period16_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period17_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period18_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period19_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period20_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period21_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period22_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period23_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period24_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period25_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period26_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period27_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period28_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period29_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period30_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period31_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period32_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period33_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period34_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period35_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period36_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period37_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period38_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period39_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period40_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period41_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period42_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period43_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period44_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period45_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period46_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period47_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period48_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period49_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period50_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period51_tab             PA_FORECAST_GLOB.NumberTabTyp;
Period52_tab             PA_FORECAST_GLOB.NumberTabTyp;

i		NUMBER;
j		NUMBER;
k		NUMBER;
m		NUMBER;
n		NUMBER;
l_category_id	NUMBER;
ll_category_id  NUMBER;
l_other_org_id	NUMBER;
x		NUMBER;
l_category_name VARCHAR2(30);
l_org_tot_period1 NUMBER;
l_org_tot_period2 NUMBER;
l_org_tot_period3 NUMBER;
l_org_tot_period4 NUMBER;
l_org_tot_period5 NUMBER;
l_org_tot_period6 NUMBER;
l_org_tot_period7 NUMBER;
l_org_tot_period8 NUMBER;
l_org_tot_period9 NUMBER;
l_org_tot_period10 NUMBER;
l_org_tot_period11 NUMBER;
l_org_tot_period12 NUMBER;
l_org_tot_period13 NUMBER;
l_org_tot_period14 NUMBER;
l_org_tot_period15 NUMBER;
l_org_tot_period16 NUMBER;
l_org_tot_period17 NUMBER;
l_org_tot_period18 NUMBER;
l_org_tot_period19 NUMBER;
l_org_tot_period20 NUMBER;
l_org_tot_period21 NUMBER;
l_org_tot_period22 NUMBER;
l_org_tot_period23 NUMBER;
l_org_tot_period24 NUMBER;
l_org_tot_period25 NUMBER;
l_org_tot_period26 NUMBER;
l_org_tot_period27 NUMBER;
l_org_tot_period28 NUMBER;
l_org_tot_period29 NUMBER;
l_org_tot_period30 NUMBER;
l_org_tot_period31 NUMBER;
l_org_tot_period32 NUMBER;
l_org_tot_period33 NUMBER;
l_org_tot_period34 NUMBER;
l_org_tot_period35 NUMBER;
l_org_tot_period36 NUMBER;
l_org_tot_period37 NUMBER;
l_org_tot_period38 NUMBER;
l_org_tot_period39 NUMBER;
l_org_tot_period40 NUMBER;
l_org_tot_period41 NUMBER;
l_org_tot_period42 NUMBER;
l_org_tot_period43 NUMBER;
l_org_tot_period44 NUMBER;
l_org_tot_period45 NUMBER;
l_org_tot_period46 NUMBER;
l_org_tot_period47 NUMBER;
l_org_tot_period48 NUMBER;
l_org_tot_period49 NUMBER;
l_org_tot_period50 NUMBER;
l_org_tot_period51 NUMBER;
l_org_tot_period52 NUMBER;


l_cat_tot_period1 NUMBER;
l_cat_tot_period2 NUMBER;
l_cat_tot_period3 NUMBER;
l_cat_tot_period4 NUMBER;
l_cat_tot_period5 NUMBER;
l_cat_tot_period6 NUMBER;
l_cat_tot_period7 NUMBER;
l_cat_tot_period8 NUMBER;
l_cat_tot_period9 NUMBER;
l_cat_tot_period10 NUMBER;
l_cat_tot_period11 NUMBER;
l_cat_tot_period12 NUMBER;
l_cat_tot_period13 NUMBER;
l_cat_tot_period14 NUMBER;
l_cat_tot_period15 NUMBER;
l_cat_tot_period16 NUMBER;
l_cat_tot_period17 NUMBER;
l_cat_tot_period18 NUMBER;
l_cat_tot_period19 NUMBER;
l_cat_tot_period20 NUMBER;
l_cat_tot_period21 NUMBER;
l_cat_tot_period22 NUMBER;
l_cat_tot_period23 NUMBER;
l_cat_tot_period24 NUMBER;
l_cat_tot_period25 NUMBER;
l_cat_tot_period26 NUMBER;
l_cat_tot_period27 NUMBER;
l_cat_tot_period28 NUMBER;
l_cat_tot_period29 NUMBER;
l_cat_tot_period30 NUMBER;
l_cat_tot_period31 NUMBER;
l_cat_tot_period32 NUMBER;
l_cat_tot_period33 NUMBER;
l_cat_tot_period34 NUMBER;
l_cat_tot_period35 NUMBER;
l_cat_tot_period36 NUMBER;
l_cat_tot_period37 NUMBER;
l_cat_tot_period38 NUMBER;
l_cat_tot_period39 NUMBER;
l_cat_tot_period40 NUMBER;
l_cat_tot_period41 NUMBER;
l_cat_tot_period42 NUMBER;
l_cat_tot_period43 NUMBER;
l_cat_tot_period44 NUMBER;
l_cat_tot_period45 NUMBER;
l_cat_tot_period46 NUMBER;
l_cat_tot_period47 NUMBER;
l_cat_tot_period48 NUMBER;
l_cat_tot_period49 NUMBER;
l_cat_tot_period50 NUMBER;
l_cat_tot_period51 NUMBER;
l_cat_tot_period52 NUMBER;


CURSOR C1 IS
SELECT distinct category_id
FROM     PA_FP_OF_WEBADI_V;

CURSOR C2(l_category_id number) IS
SELECT distinct Other_Organization_Id
FROM   PA_FP_OF_WEBADI_V
Where  category_id = l_category_id;

CURSOR C3(l_category_id number,l_other_org_id number) IS
SELECT

Category_id,
Category,
OU_id,
OU_name,
Organization_Id,
Organization_Name,
Other_OU_Id,
Other_OU_Name,
Other_Organization_Id,
Other_Organization_Name,
Txn_Project_Name,
Resource_Name,
Period1,
Period2,
Period3,
Period4,
Period5,
Period6,
Period7,
Period8,
Period9,
Period10,
Period11,
Period12,
Period13,
Period14,
Period15,
Period16,
Period17,
Period18,
Period19,
Period20,
Period21,
Period22,
Period23,
Period24,
Period25,
Period26,
Period27,
Period28,
Period29,
Period30,
Period31,
Period32,
Period33,
Period34,
Period35,
Period36,
Period37,
Period38,
Period39,
Period40,
Period41,
Period42,
Period43,
Period44,
Period45,
Period46,
Period47,
Period48,
Period49,
Period50,
Period51,
Period52
FROM  PA_FP_OF_WEBADI_V
Where Category_id = l_category_id
  and Other_Organization_Id =l_other_org_id;

BEGIN
       i := 0;
       j := 0;
       m := 0;
       n := 0;
       k := 0;
   l_session_id := p_session_id;
   l_budget_version_id := p_budget_version_id;
   l_amount_type_code  := p_amount_type_code;

delete from pa_fp_of_webadi_xface
where session_id = l_session_id
  and amount_type_code = l_amount_type_code;


OPEN C1;

    LOOP
          --dbms_output.put_line('i '||i);
          FETCH C1 INTO v_category_id_tab(i);
          i := i+1;
          EXIT WHEN C1%NOTFOUND;
    END LOOP;

CLOSE C1;
--dbms_output.put_line('i '||i);


FOR m IN 0 .. i-2 LOOP
--dbms_output.put_line('category id '||v_category_id_tab(m));
   l_category_id := v_category_id_tab(m);

	 j:=0;
         OPEN C2(l_category_id);

    LOOP

          FETCH C2 INTO v_org_id_tab(j);
          j := j+1;
          EXIT WHEN C2%NOTFOUND;

    END LOOP;

CLOSE C2;
     --dbms_output.put_line('j '||j);

   FOR n IN 0..j-2 LOOP
      l_other_org_id := v_org_id_tab(n);
--dbms_output.put_line('cat id '||l_category_id);
--dbms_output.put_line('org id '||l_other_org_id);
          k := 0;
   OPEN C3(l_category_id,l_other_org_id);

         LOOP
               k := k+1;
            FETCH C3 INTO       Category_id_tab(k),
				Category_tab(k),
				OU_id_tab(k),
				OU_name_tab(k),
				Organization_Id_tab(k),
				Organization_Name_tab(k),
				Other_OU_Id_tab(k),
				Other_OU_Name_tab(k),
				Other_Organization_Id_tab(k),
				Other_Organization_Name_tab(k),
				Txn_Project_Name_tab(k),
				Resource_Name_tab(k),
				Period1_tab(k),
				Period2_tab(k),
            			Period3_tab(k),
Period4_tab(k),
Period5_tab(k),
Period6_tab(k),
Period7_tab(k),
Period8_tab(k),
Period9_tab(k),
Period10_tab(k),
Period11_tab(k),
Period12_tab(k),
Period13_tab(k),
Period14_tab(k),
Period15_tab(k),
Period16_tab(k),
Period17_tab(k),
Period18_tab(k),
Period19_tab(k),
Period20_tab(k),
Period21_tab(k),
Period22_tab(k),
Period23_tab(k),
Period24_tab(k),
Period25_tab(k),
Period26_tab(k),
Period27_tab(k),
Period28_tab(k),
Period29_tab(k),
Period30_tab(k),
Period31_tab(k),
Period32_tab(k),
Period33_tab(k),
Period34_tab(k),
Period35_tab(k),
Period36_tab(k),
Period37_tab(k),
Period38_tab(k),
Period39_tab(k),
Period40_tab(k),
Period41_tab(k),
Period42_tab(k),
Period43_tab(k),
Period44_tab(k),
Period45_tab(k),
Period46_tab(k),
Period47_tab(k),
Period48_tab(k),
Period49_tab(k),
Period50_tab(k),
Period51_tab(k),
Period52_tab(k);

	EXIT WHEN C3%NOTFOUND;

     END LOOP;

   CLOSE C3;

   FORALL x in Category_id_tab.first..Category_id_tab.last
        INSERT INTO  pa_fp_of_webadi_xface
               (Session_id,
                budget_version_id,
                amount_type_code,
                Category_id,
                Category,
                org_id,
                Other_Organization_Name,
                Project_Name,
                Resource_Name,
                Prd1,
                Prd2,
                Prd3,
Prd4,
Prd5,
Prd6,
Prd7,
Prd8,
Prd9,
Prd10,
Prd11,
Prd12,
Prd13,
Prd14,
Prd15,
Prd16,
Prd17,
Prd18,
Prd19,
Prd20,
Prd21,
Prd22,
Prd23,
Prd24,
Prd25,
Prd26,
Prd27,
Prd28,
Prd29,
Prd30,
Prd31,
Prd32,
Prd33,
Prd34,
Prd35,
Prd36,
Prd37,
Prd38,
Prd39,
Prd40,
Prd41,
Prd42,
Prd43,
Prd44,
Prd45,
Prd46,
Prd47,
Prd48,
Prd49,
Prd50,
Prd51,
Prd52)
	VALUES
	       (l_session_id,
                l_budget_version_id,
                l_amount_type_code,
                Category_id_tab(x),
		Category_tab(x),
		OU_id_tab(x),
		Other_Organization_Name_tab(x)||'--'||Other_OU_Name_tab(x),
		Txn_Project_Name_tab(x),
		Resource_Name_tab(x),
		Period1_tab(x),
		Period2_tab(x),
		Period3_tab(x),
Period4_tab(x),
Period5_tab(x),
Period6_tab(x),
Period7_tab(x),
Period8_tab(x),
Period9_tab(x),
Period10_tab(x),
Period11_tab(x),
Period12_tab(x),
Period13_tab(x),
Period14_tab(x),
Period15_tab(x),
Period16_tab(x),
Period17_tab(x),
Period18_tab(x),
Period19_tab(x),
Period20_tab(x),
Period21_tab(x),
Period22_tab(x),
Period23_tab(x),
Period24_tab(x),
Period25_tab(x),
Period26_tab(x),
Period27_tab(x),
Period28_tab(x),
Period29_tab(x),
Period30_tab(x),
Period31_tab(x),
Period32_tab(x),
Period33_tab(x),
Period34_tab(x),
Period35_tab(x),
Period36_tab(x),
Period37_tab(x),
Period38_tab(x),
Period39_tab(x),
Period40_tab(x),
Period41_tab(x),
Period42_tab(x),
Period43_tab(x),
Period44_tab(x),
Period45_tab(x),
Period46_tab(x),
Period47_tab(x),
Period48_tab(x),
Period49_tab(x),
Period50_tab(x),
Period51_tab(x),
Period52_tab(x));

--dbms_output.put_line('x: '||x);
--dbms_output.put_line('calculating org total');

    	select sum(period1),
               sum(period2),
               sum(period3),
               sum(period4),
               sum(period5),
               sum(period6),
               sum(period7),
               sum(period8),
               sum(period9),
               sum(period10),
               sum(period11),
               sum(period12),
               sum(period13),
               sum(period14),
               sum(period15),
               sum(period16),
               sum(period17),
               sum(period18),
               sum(period19),
               sum(period20),
               sum(period21),
               sum(period22),
               sum(period23),
               sum(period24),
               sum(period25),
               sum(period26),
               sum(period27),
               sum(period28),
               sum(period29),
               sum(period30),
               sum(period31),
               sum(period32),
               sum(period33),
               sum(period34),
               sum(period35),
               sum(period36),
               sum(period37),
               sum(period38),
               sum(period39),
               sum(period40),
               sum(period41),
               sum(period42),
               sum(period43),
               sum(period44),
               sum(period45),
               sum(period46),
               sum(period47),
               sum(period48),
               sum(period49),
               sum(period50),
               sum(period51),
               sum(period52)
         into  l_org_tot_period1,
               l_org_tot_period2,
               l_org_tot_period3,
               l_org_tot_period4,
               l_org_tot_period5,
               l_org_tot_period6,
               l_org_tot_period7,
               l_org_tot_period8,
               l_org_tot_period9,
               l_org_tot_period10,
               l_org_tot_period11,
               l_org_tot_period12,
               l_org_tot_period13,
               l_org_tot_period14,
               l_org_tot_period15,
               l_org_tot_period16,
               l_org_tot_period17,
               l_org_tot_period18,
               l_org_tot_period19,
               l_org_tot_period20,
               l_org_tot_period21,
               l_org_tot_period22,
               l_org_tot_period23,
               l_org_tot_period24,
               l_org_tot_period25,
               l_org_tot_period26,
               l_org_tot_period27,
               l_org_tot_period28,
               l_org_tot_period29,
               l_org_tot_period30,
               l_org_tot_period31,
               l_org_tot_period32,
               l_org_tot_period33,
               l_org_tot_period34,
               l_org_tot_period35,
               l_org_tot_period36,
               l_org_tot_period37,
               l_org_tot_period38,
               l_org_tot_period39,
               l_org_tot_period40,
               l_org_tot_period41,
               l_org_tot_period42,
               l_org_tot_period43,
               l_org_tot_period44,
               l_org_tot_period45,
               l_org_tot_period46,
               l_org_tot_period47,
               l_org_tot_period48,
               l_org_tot_period49,
               l_org_tot_period50,
               l_org_tot_period51,
               l_org_tot_period52
         From  PA_FP_OF_WEBADI_V
        Where category_id = l_category_id
          And Other_Organization_Id = l_other_org_id;


--dbms_output.put_line('Done calculating org total');


   Insert INTO  pa_fp_of_webadi_xface
               (Session_id,
                budget_version_id,
                amount_type_code,
                Category_id,
                Category,
                Other_Organization_Name,
                Prd1,
                Prd2,
                Prd3,
Prd4,
Prd5,
Prd6,
Prd7,
Prd8,
Prd9,
Prd10,
Prd11,
Prd12,
Prd13,
Prd14,
Prd15,
Prd16,
Prd17,
Prd18,
Prd19,
Prd20,
Prd21,
Prd22,
Prd23,
Prd24,
Prd25,
Prd26,
Prd27,
Prd28,
Prd29,
Prd30,
Prd31,
Prd32,
Prd33,
Prd34,
Prd35,
Prd36,
Prd37,
Prd38,
Prd39,
Prd40,
Prd41,
Prd42,
Prd43,
Prd44,
Prd45,
Prd46,
Prd47,
Prd48,
Prd49,
Prd50,
Prd51,
Prd52 )
        VALUES( l_session_id,
                l_budget_version_id,
                l_amount_type_code,
                Category_id_tab(1),
                Category_tab(1),
                Other_Organization_Name_tab(1)||'--'||Other_OU_Name_tab(1)||' Total',
		l_org_tot_period1,
                l_org_tot_period2,
                l_org_tot_period3,
               l_org_tot_period4,
               l_org_tot_period5,
               l_org_tot_period6,
               l_org_tot_period7,
               l_org_tot_period8,
               l_org_tot_period9,
               l_org_tot_period10,
               l_org_tot_period11,
               l_org_tot_period12,
               l_org_tot_period13,
               l_org_tot_period14,
               l_org_tot_period15,
               l_org_tot_period16,
               l_org_tot_period17,
               l_org_tot_period18,
               l_org_tot_period19,
               l_org_tot_period20,
               l_org_tot_period21,
               l_org_tot_period22,
               l_org_tot_period23,
               l_org_tot_period24,
               l_org_tot_period25,
               l_org_tot_period26,
               l_org_tot_period27,
               l_org_tot_period28,
               l_org_tot_period29,
               l_org_tot_period30,
               l_org_tot_period31,
               l_org_tot_period32,
               l_org_tot_period33,
               l_org_tot_period34,
               l_org_tot_period35,
               l_org_tot_period36,
               l_org_tot_period37,
               l_org_tot_period38,
               l_org_tot_period39,
               l_org_tot_period40,
               l_org_tot_period41,
               l_org_tot_period42,
               l_org_tot_period43,
               l_org_tot_period44,
               l_org_tot_period45,
               l_org_tot_period46,
               l_org_tot_period47,
               l_org_tot_period48,
               l_org_tot_period49,
               l_org_tot_period50,
               l_org_tot_period51,
               l_org_tot_period52);

       l_category_name := Category_tab(1);
       ll_category_id := Category_id_tab(1);

	Category_id_tab.delete;
	Category_tab.delete;
	OU_id_tab.delete;
	OU_name_tab.delete;
	Organization_Id_tab.delete;
	Organization_Name_tab.delete;
	Other_OU_Id_tab.delete;
	Other_OU_Name_tab.delete;
	Other_Organization_Id_tab.delete;
	Other_Organization_Name_tab.delete;
	Txn_Project_Name_tab.delete;
	Resource_Name_tab.delete;
	Period1_tab.delete;
	Period2_tab.delete;
	Period3_tab.delete;
        Period4_tab.delete;
        Period5_tab.delete;
        Period6_tab.delete;
        Period7_tab.delete;
        Period8_tab.delete;
        Period9_tab.delete;
        Period10_tab.delete;
        Period11_tab.delete;
        Period12_tab.delete;
        Period13_tab.delete;
        Period14_tab.delete;
        Period15_tab.delete;
        Period16_tab.delete;
        Period17_tab.delete;
        Period18_tab.delete;
        Period19_tab.delete;
        Period20_tab.delete;
        Period21_tab.delete;
        Period22_tab.delete;
        Period23_tab.delete;
        Period24_tab.delete;
        Period25_tab.delete;
        Period26_tab.delete;
        Period27_tab.delete;
        Period28_tab.delete;
        Period29_tab.delete;
        Period30_tab.delete;
        Period31_tab.delete;
        Period32_tab.delete;
        Period33_tab.delete;
        Period34_tab.delete;
        Period35_tab.delete;
        Period36_tab.delete;
        Period37_tab.delete;
        Period38_tab.delete;
        Period39_tab.delete;
        Period40_tab.delete;
        Period41_tab.delete;
        Period42_tab.delete;
        Period43_tab.delete;
        Period44_tab.delete;
        Period45_tab.delete;
        Period46_tab.delete;
        Period47_tab.delete;
        Period48_tab.delete;
        Period49_tab.delete;
        Period50_tab.delete;
        Period51_tab.delete;
        Period52_tab.delete;



     END LOOP; --for loop n

--dbms_output.put_line('calculating cat total');
        select sum(period1),
               sum(period2),
               sum(period3),
               sum(period4),
               sum(period5),
               sum(period6),
               sum(period7),
               sum(period8),
               sum(period9),
               sum(period10),
               sum(period11),
               sum(period12),
               sum(period13),
               sum(period14),
               sum(period15),
               sum(period16),
               sum(period17),
               sum(period18),
               sum(period19),
               sum(period20),
               sum(period21),
               sum(period22),
               sum(period23),
               sum(period24),
               sum(period25),
               sum(period26),
               sum(period27),
               sum(period28),
               sum(period29),
               sum(period30),
               sum(period31),
               sum(period32),
               sum(period33),
               sum(period34),
               sum(period35),
               sum(period36),
               sum(period37),
               sum(period38),
               sum(period39),
               sum(period40),
               sum(period41),
               sum(period42),
               sum(period43),
               sum(period44),
               sum(period45),
               sum(period46),
               sum(period47),
               sum(period48),
               sum(period49),
               sum(period50),
               sum(period51),
               sum(period52)
         into  l_cat_tot_period1,
               l_cat_tot_period2,
               l_cat_tot_period3,
               l_cat_tot_period4,
               l_cat_tot_period5,
               l_cat_tot_period6,
               l_cat_tot_period7,
               l_cat_tot_period8,
               l_cat_tot_period9,
               l_cat_tot_period10,
               l_cat_tot_period11,
               l_cat_tot_period12,
               l_cat_tot_period13,
               l_cat_tot_period14,
               l_cat_tot_period15,
               l_cat_tot_period16,
               l_cat_tot_period17,
               l_cat_tot_period18,
               l_cat_tot_period19,
               l_cat_tot_period20,
               l_cat_tot_period21,
               l_cat_tot_period22,
               l_cat_tot_period23,
               l_cat_tot_period24,
               l_cat_tot_period25,
               l_cat_tot_period26,
               l_cat_tot_period27,
               l_cat_tot_period28,
               l_cat_tot_period29,
               l_cat_tot_period30,
               l_cat_tot_period31,
               l_cat_tot_period32,
               l_cat_tot_period33,
               l_cat_tot_period34,
               l_cat_tot_period35,
               l_cat_tot_period36,
               l_cat_tot_period37,
               l_cat_tot_period38,
               l_cat_tot_period39,
               l_cat_tot_period40,
               l_cat_tot_period41,
               l_cat_tot_period42,
               l_cat_tot_period43,
               l_cat_tot_period44,
               l_cat_tot_period45,
               l_cat_tot_period46,
               l_cat_tot_period47,
               l_cat_tot_period48,
               l_cat_tot_period49,
               l_cat_tot_period50,
               l_cat_tot_period51,
               l_cat_tot_period52
         From  PA_FP_OF_WEBADI_V
        Where category_id = l_category_id;

--dbms_output.put_line('done calculating cat total');


   Insert INTO  pa_fp_of_webadi_xface
               (Session_id,
                budget_version_id,
                amount_type_code,
                category_id,
                category,
                Prd1,
                Prd2,
                Prd3,
Prd4,
Prd5,
Prd6,
Prd7,
Prd8,
Prd9,
Prd10,
Prd11,
Prd12,
Prd13,
Prd14,
Prd15,
Prd16,
Prd17,
Prd18,
Prd19,
Prd20,
Prd21,
Prd22,
Prd23,
Prd24,
Prd25,
Prd26,
Prd27,
Prd28,
Prd29,
Prd30,
Prd31,
Prd32,
Prd33,
Prd34,
Prd35,
Prd36,
Prd37,
Prd38,
Prd39,
Prd40,
Prd41,
Prd42,
Prd43,
Prd44,
Prd45,
Prd46,
Prd47,
Prd48,
Prd49,
Prd50,
Prd51,
Prd52)
        VALUES( l_session_id,
                l_budget_version_id,
                l_amount_type_code,
                ll_category_id,
                l_category_name||' Total',
                l_cat_tot_period1,
                l_cat_tot_period2,
                l_cat_tot_period3,
               l_cat_tot_period4,
               l_cat_tot_period5,
               l_cat_tot_period6,
               l_cat_tot_period7,
               l_cat_tot_period8,
               l_cat_tot_period9,
               l_cat_tot_period10,
               l_cat_tot_period11,
               l_cat_tot_period12,
               l_cat_tot_period13,
               l_cat_tot_period14,
               l_cat_tot_period15,
               l_cat_tot_period16,
               l_cat_tot_period17,
               l_cat_tot_period18,
               l_cat_tot_period19,
               l_cat_tot_period20,
               l_cat_tot_period21,
               l_cat_tot_period22,
               l_cat_tot_period23,
               l_cat_tot_period24,
               l_cat_tot_period25,
               l_cat_tot_period26,
               l_cat_tot_period27,
               l_cat_tot_period28,
               l_cat_tot_period29,
               l_cat_tot_period30,
               l_cat_tot_period31,
               l_cat_tot_period32,
               l_cat_tot_period33,
               l_cat_tot_period34,
               l_cat_tot_period35,
               l_cat_tot_period36,
               l_cat_tot_period37,
               l_cat_tot_period38,
               l_cat_tot_period39,
               l_cat_tot_period40,
               l_cat_tot_period41,
               l_cat_tot_period42,
               l_cat_tot_period43,
               l_cat_tot_period44,
               l_cat_tot_period45,
               l_cat_tot_period46,
               l_cat_tot_period47,
               l_cat_tot_period48,
               l_cat_tot_period49,
               l_cat_tot_period50,
               l_cat_tot_period51,
               l_cat_tot_period52);


END LOOP;--for loop m

commit;

END populate_interface_table;

END pa_fp_of_webadi_pkg;

/
