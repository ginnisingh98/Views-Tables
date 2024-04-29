--------------------------------------------------------
--  DDL for Package Body CSC_ACTION_ASSEMBLER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_ACTION_ASSEMBLER_PVT" AS
/* $Header: cscvrenb.pls 115.22 2004/06/22 11:09:21 bhroy ship $ */

 G_PKG_NAME CONSTANT VARCHAR2(30) := 'CSC_Action_Assembler_PVT' ;

 l_Param_tbl Params_Tab_TYPE;
 l_tbl_count number := 0;
PROCEDURE ENABLE_PLAN (P_PARTY_ID 	       NUMBER,
		       P_CUST_ACCOUNT_ID       NUMBER,
		       P_END_USER_TYPE         VARCHAR2 := NULL,
                       X_CONDITION_ID_TBL     OUT NOCOPY CONDITION_ID_Tab_Type )
IS
 no_of_rows NUMBER := 0;
 Cursor C1 IS
  select a.plan_id
  from   csc_cust_plans a,
	 csc_plan_headers_b b
  where  a.party_id                  = p_Party_id
  and    a.plan_id                   = b.plan_id
  and    nvl(b.end_user_type, 'Y')   = nvl(p_end_user_type, nvl(b.end_user_type, 'Y') )
  and    a.cust_account_id is null
  and    a.plan_status_code in ('APPLIED', 'ENABLED', 'TRANSFERED')
  and    trunc(sysdate) between trunc(nvl(b.start_date_active, sysdate))
			    and trunc(nvl(b.end_date_active, sysdate))
  UNION
  select a.plan_id
  from   csc_cust_plans a,
	 csc_plan_headers_b b
  where  a.party_id                  = p_party_id
  and    a.plan_id                   = b.plan_id
  and    nvl(b.end_user_type, 'Y')   = nvl(p_end_user_type, nvl(b.end_user_type, 'Y') )
  and    a.cust_account_id           = p_cust_account_id
  and    a.plan_status_code in ('APPLIED', 'ENABLED', 'TRANSFERED')
  and    trunc(sysdate) between trunc(nvl(b.start_date_active, sysdate))
			    and trunc(nvl(b.end_date_active, sysdate));

 Cursor C2 ( c_plan_id NUMBER ) IS
  SELECT och.id Condition_id
  FROM csc_plan_lines cpl,okc_condition_headers_v och
  WHERE cpl.condition_id = och.id
  AND cpl.plan_id = c_plan_id;

BEGIN
 X_Condition_ID_TBL.DELETE;
 FOR C1_REC IN C1 LOOP
    FOR C2_rec in C2 ( c1_rec.plan_id ) LOOP
      no_of_rows := no_of_rows + 1;
      X_CONDITION_ID_TBL(no_of_rows).CONDITION_ID := C2_rec.Condition_ID;
    END LOOP;
 END LOOP;
END ENABLE_PLAN;

/*
PROCEDURE CHECK_ACTION_ATTRIBUTES (p_Action_id NUMBER,
				    p_Msg_Tbl IN OKC_AQ_PVT.MSG_TAB_TYP,
				    x_Action_attr_tbl OUT NOCOPY OKC_AQ_PVT.MSG_TAB_TYP)
IS
 Cursor C1 is
  SELECT element_name
  FROM okc_action_attributes_v
  WHERE acn_id = p_Action_id;

 TYPE Element_Name_Rec_Type IS RECORD ( Element_Name VARCHAR2(1000));

 TYPE Element_Name_Tab_Type IS TABLE OF Element_Name_Rec_Type
  INDEX BY BINARY_INTEGER;

 l_Element_Name_Tbl Element_Name_Tab_Type;
 l_no_of_rows Number := 0;
 l_no_of_recs Number := 0;

BEGIN
 FOR C1_rec in C1 LOOP
   l_no_of_rows := l_no_of_rows + 1;
   l_Element_Name_Tbl(l_no_of_rows).Element_Name := C1_rec.Element_Name;
 END LOOP;
 x_Action_Attr_tbl := okc_aq_pvt.msg_tab_typ();
 IF p_Msg_Tbl.count > 0
 THEN
  FOR i in p_Msg_tbl.FIRST..p_Msg_Tbl.LAST LOOP
     FOR j in 1..l_Element_Name_tbl.COUNT LOOP
	  IF l_Element_Name_tbl(j).Element_Name = p_Msg_Tbl(i).Element_Name
	  THEN
		x_Action_Attr_Tbl.Extend;
	     l_no_of_recs := l_no_of_recs + 1;
	     x_Action_Attr_Tbl(l_no_of_recs).Element_Name := p_Msg_Tbl(i).Element_Name;
	     x_Action_Attr_Tbl(l_no_of_recs).Element_Value := p_Msg_Tbl(i).Element_Value;
	  END IF;
     END LOOP;
  END LOOP;
 END IF;
END CHECK_ACTION_ATTRIBUTES;
*/

PROCEDURE ENABLE_PLAN_AND_GET_OUTCOMES (
   P_PARTY_ID                IN  NUMBER,
   P_Cust_Account_Id         IN  NUMBER,
   P_End_User_Type           IN  VARCHAR2 := NULL,
   P_Application_Short_Name  IN  VARCHAR2,
   P_Msg_Tbl                 IN  OKC_AQ_PVT.MSG_TAB_TYP,
   X_Results_Tbl             OUT NOCOPY RESULTS_TAB_TYPE )
IS
 x_return_status varchar2(1);
 x_msg_count number;
 x_msg_data varchar2(2000);
 l_Condition_Tbl Condition_Id_Tab_Type;
 l_results_tbl RESULTS_TAB_TYPE;
BEGIN
   ENABLE_PLAN ( P_PARTY_ID        => p_Party_Id,
		 P_CUST_ACCOUNT_ID => P_CUST_ACCOUNT_ID,
		 P_END_USER_TYPE   => P_END_USER_TYPE,
		 X_CONDITION_ID_TBL   => l_Condition_Tbl );

   IF l_Condition_tbl.Count > 0 THEN
     FOR i in l_Condition_tbl.FIRST..l_Condition_tbl.LAST LOOP

     GET_OUTCOMES(
 	    p_api_version_number => 1,
 	    p_init_msg_list    => CSC_CORE_UTILS_PVT.G_FALSE,
 	    p_Condition_id 	   => l_Condition_tbl(i).Condition_id,
            p_Application_Short_Name => p_Application_Short_Name,
	    P_Msg_Tbl        =>P_Msg_Tbl,
 	    x_return_status    => x_return_status,
 	    x_msg_count        => x_msg_count ,
 	    x_msg_data         => x_msg_data ,
            x_Results_Tbl      => l_results_tbl );
       IF x_return_status <> 'S' THEN
       NULL; --Need to add stuff here
       END IF;
     END LOOP;
     x_results_tbl := l_results_tbl;
   END IF;
END ENABLE_PLAN_AND_GET_OUTCOMES;


PROCEDURE GET_OUTCOMES(
 	p_api_version_number   	IN  NUMBER,
 	p_init_msg_list        	IN  VARCHAR2 := CSC_CORE_UTILS_PVT.G_FALSE,
 	P_Condition_Id		IN  okc_condition_headers_b.id%TYPE,
        P_Application_short_name IN VARCHAR2,
 	P_Msg_Tbl		IN  OKC_AQ_PVT.MSG_TAB_TYP,
 	x_return_status        	OUT NOCOPY VARCHAR2,
 	x_msg_count            	OUT NOCOPY NUMBER,
   	x_msg_data             	OUT NOCOPY VARCHAR2,
        X_Results_Tbl           IN OUT NOCOPY RESULTS_TAB_TYPE  )
 IS
  --local variables
  l_OUTCOME_TBL  OKC_CONDITION_EVAL_PUB.OUTCOME_TAB_TYPE ;
  l_RESULTS_TBL  RESULTS_TAB_TYPE ;

  l_MSG_REC OKC_AQ_PVT.MSG_REC_TYP;
  l_MSG_TBL OKC_AQ_PVT.MSG_TAB_TYP ;

  l_param_tbl    params_tab_type;
  l_Name         VARCHAR2(1000);
  l_Description  VARCHAR2(1800);
  l_no_of_recs   NUMBER ;
BEGIN
   OKC_CONDITION_EVAL_PUB.EVALUATE_PLAN_CONDITION (
    	p_api_version      => p_api_version_number,
     	p_init_msg_list    => p_init_msg_list,
     	x_return_status    => x_return_status,
     	x_msg_count        => x_msg_Count,
     	x_msg_data         => x_msg_data,
     	P_Cnh_Id           => P_Condition_Id,
     	P_Msg_Tab          => P_Msg_Tbl,
     	X_Sync_Outcome_Tab => l_outcome_tbl
    	     );
   IF l_outcome_tbl.count > 0 THEN
    FOR i in l_outcome_tbl.FIRST..l_outcome_tbl.LAST LOOP
     l_no_of_recs := nvl(X_results_tbl.count,0) + 1;
     IF l_outcome_tbl(i).type = 'ALERT' THEN
        l_Description := GET_ALERT_NAME( l_outcome_tbl(i).Name,p_Application_Short_Name, l_Name );
     ELSIF l_outcome_tbl(i).type = 'SCRIPT' THEN
	l_Name := GET_SCRIPT_NAME( l_outcome_tbl(i).Name );
        --l_Name := l_outcome_tbl(i).Name;
        l_Description := l_Name;
     END IF;
     X_results_tbl(l_no_of_recs).Name := l_Name;
     X_results_tbl(l_no_of_recs).Type := l_Outcome_Tbl(i).Type;
     X_results_tbl(l_no_of_recs).Description := l_Description;
    END LOOP;
   END IF;
EXCEPTION
 WHEN OTHERS THEN
    FND_MSG_PUB.Build_Exc_Msg;
    APP_EXCEPTION.RAISE_EXCEPTION;
END GET_OUTCOMES;

FUNCTION GET_ALERT_NAME(
		  P_String                           VARCHAR2,
		  p_Application_Short_Name     IN    VARCHAR2,
		  x_Name                       OUT   NOCOPY VARCHAR2 )
RETURN VARCHAR2
IS
   l_message_text       VARCHAR2(1800);
   l_alert_msg          VARCHAR2(4000);
   l_alert_count        NUMBER              := 0;
   l_params_tbl         PARAMS_TAB_TYPE;

   temp number(2) := 0;
BEGIN
   l_Params_tbl := Detach_String ( p_String, x_Name );
   l_message_text := fnd_message.get_string(
				    appin        => p_application_short_name,
				    namein       => x_name );
   --FND_MSG_PUB.INITIALIZE;
   FOR i in 1..l_params_tbl.COUNT LOOP
      IF i = 1 THEN
         FND_MESSAGE.SET_NAME(p_Application_Short_Name,l_params_tbl(i).PName);
      END IF;
      IF instr(l_message_text, '&'||l_params_tbl(i).Name ) <> 0 then
         FND_MESSAGE.SET_TOKEN(l_params_tbl(i).Name, l_params_tbl(i).Value);
      END IF;
   END LOOP;

   FND_MSG_PUB.INITIALIZE;
   l_alert_msg := FND_MESSAGE.GET;
   RETURN ( l_alert_msg );
END GET_ALERT_NAME;

FUNCTION GET_SCRIPT_NAME( P_String VARCHAR2 ) RETURN VARCHAR2
IS
   l_Name VARCHAR2(4000);
   l_params_tbl PARAMS_TAB_TYPE;
BEGIN
   l_Params_tbl := Detach_String (p_String, l_Name );
   return( l_Name );
END GET_SCRIPT_NAME;

-- bug 3712807, increased l_string, l_name to handle multiple parameters, a long list.

FUNCTION DETACH_STRING ( p_string VARCHAR2, x_Name OUT NOCOPY VARCHAR2 )
   RETURN params_tab_type
IS
  l_string              varchar2(2000)        := p_string;
  l_brac_cnt            number                := 0;
  l_proc_name           varchar2(150);
  l_name                varchar2(2000);
  x_param_tbl           params_tab_type;

  i                     number(6)             := 0;
  j                     number(6);
  l_pos                 number(6)             := 0;
  l_param               varchar2(250);
  l_value               varchar2(360);
BEGIN

   l_brac_cnt := instr(l_string, '(' ) + 1;

   -- get the executable name
   if l_brac_cnt > 1 then
	 l_proc_name := substr(l_string, 1, l_brac_cnt - 2);
   else
	 l_proc_name := rtrim(l_string, ';');
   end if;
   x_name := l_proc_name;

   -- get the parameter/value list
   l_name := substr( l_string, l_brac_cnt+1 );

   -- translate is done to make the last parenthesis a comma to make the
   -- detach of the value consistent in the loop below.
   l_name := translate(l_name, ')', ',');

   -- get the total number of parameter/value combinations in the string.
   loop
	 l_pos := instr(l_name, '=>', 1, i+1);
	 exit when l_pos = 0;
	 i := i + 1;
   end loop;

   for j in 1..i
   loop
	 x_param_tbl(j).name  := substr(l_name, 1, instr(l_name, '=>')-1 );
	 x_param_tbl(j).value := substr(l_name, instr(l_name, '=>')+2, instr(l_name, ',') -
										                 (instr(l_name, '=>')+2) );

-- Bug# 3457037
	If ( ( trim(x_param_tbl(j).value) = '''OKC_API.G_MISS_CHAR''' ) OR ( trim(x_param_tbl(j).value) = 'OKC_API.G_MISS_NUM') OR ( trim(x_param_tbl(j).value) = '''OKC_API.G_MISS_DATE''' ) ) Then
		x_param_tbl(j).value := '';
	End If;

	 l_name  := trim (leading ' ' FROM substr(l_name, instr(l_name, ',')+1 ) );
      x_param_tbl(j).PName := l_proc_Name;
   end loop;

   If (i < 1) Then
	x_param_tbl(1).name := '';
	x_param_tbl(1).value := '';
        x_param_tbl(1).PName := l_proc_Name;
   End If;

   RETURN (x_param_tbl);

END Detach_String;

END CSC_ACTION_ASSEMBLER_PVT;

/
