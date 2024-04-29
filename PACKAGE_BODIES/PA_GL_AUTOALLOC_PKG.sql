--------------------------------------------------------
--  DDL for Package Body PA_GL_AUTOALLOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_GL_AUTOALLOC_PKG" AS
/*  $Header: PAXGLAAB.pls 120.3 2005/09/29 14:54:08 dlanka noship $  */
----------------------------------------------------------------------------
FUNCTION GET_PERIOD_TYPE (	p_allocation_set_id 	Number	)
RETURN CHAR
IS

v_pa_period CHAR(1) := 'N';
v_gl_period CHAR(1) := 'N';
v_period_type VARCHAR2(2);

CURSOR C_Period
IS
   SELECT DISTINCT a.period_type
   FROM pa_alloc_rules_all a,
 	gl_auto_alloc_batches b
   WHERE b.allocation_set_id = p_allocation_set_id
   AND   b.batch_type_code = 'P'
   AND   a.rule_id = b.batch_id;

BEGIN

   OPEN C_Period;
   LOOP

      FETCH C_Period
      INTO  v_period_type ;

      EXIT WHEN C_Period%NOTFOUND;

      IF v_Period_Type = 'PA' THEN
	 v_pa_period := 'Y';
      ELSIF v_Period_Type = 'GL' THEN
	 v_gl_period := 'Y';
      END IF;

   END LOOP;

   CLOSE C_Period;

   IF v_pa_period = 'N' AND v_gl_period = 'N' THEN
      RETURN 'N';
   ELSIF v_pa_period = 'Y' AND v_gl_period = 'Y' THEN
      RETURN 'B';
   ELSIF v_pa_period = 'N' AND v_gl_period = 'Y' THEN
      RETURN 'G';
   ELSIF v_pa_period = 'Y' AND v_gl_period = 'N' THEN
      RETURN 'P';
   END IF;

END GET_PERIOD_TYPE;
----------------------------------------------------------------------------
FUNCTION Valid_Run_Period (	p_allocation_set_id	IN 	Number,
				p_pa_period 		IN	Varchar2
							default  Null,
				p_gl_period 		IN	Varchar2
							default  Null)

RETURN BOOLEAN
IS

v_period_type CHAR(1);

BEGIN

   v_period_type := Get_Period_Type (p_allocation_set_id);

   if v_period_type = 'N' then
      return TRUE;
   elsif v_period_type = 'P' then
      if p_pa_period is not null then
         return TRUE;
      else
         return FALSE;
      end if;
   elsif v_period_type = 'G' then
      if p_gl_period is not null then
         return TRUE;
      else
         return FALSE;
      end if;
   elsif v_period_type = 'B' then
      if ((p_pa_period is not null) and (p_gl_period is not null)) then
         return TRUE;
      else
         return FALSE;
      end if;
   end if;

END Valid_Run_Period;
------------------------------------------------------------------------------
Function	Submit_Alloc_Request(	p_rule_id		IN	Number,
					p_expnd_item_date	IN	Date,
					p_pa_period		IN	Varchar2,
					p_gl_period		IN	Varchar2
				     )
Return Number
IS

v_run_period	Varchar2(15);
v_period_type	Varchar2(2);
v_request_id	Number;
v_expnd_item_date Varchar2(20);
l_org_id        Number;

BEGIN

   /** Find out the run_period (pa/gl period) to be passed **/
   select period_type, org_id -- Fix for bug : 4640479
   into v_period_type , l_org_id
   from pa_alloc_rules_all
   where rule_id = p_rule_id;

   /* dbms_output.put_line('Period Type = '||v_period_type); */

   IF v_period_type = 'GL' THEN
      v_run_period := p_gl_period;
   ELSIF v_period_type = 'PA' THEN
      v_run_period := p_pa_period;
   END IF;

  /** Convert the date parameter to varchar2 to make use of FND_REQUEST.SUBMIT
      _REQUEST **/
   v_expnd_item_date := fnd_date.date_to_canonical (p_expnd_item_date);

   fnd_request.set_org_id (l_org_id);
   v_request_id :=
		FND_REQUEST.SUBMIT_REQUEST(
       		'PA',
                'PAXALGAT',
                '',
                '',
                FALSE,
                p_rule_id,
                v_run_period,
                v_expnd_item_date
		,'G'
		,'','','','','','','','','','','','','','',''
		,'','','','','','','','','','','','','','',''
		,'','','','','','','','','','','','','','',''
		,'','','','','','','','','','','','','','',''
		,'','','','','','','','','','','','','','',''
		,'','','','','','','','','','','','','','',''
		,'','','','','','');

   Return v_request_id;

END Submit_Alloc_Request;
------------------------------------------------------------------------------
Procedure get_pa_step_status (
                      p_request_Id        In   Number
                     ,p_step_number       In   Number
                     ,p_mode              In   Varchar2
                     ,l_status            Out NOCOPY  Varchar2) IS

 v_meaning         Varchar2(80);
 v_description     Varchar2(240);
 v_status_code     Varchar2(30);
 v_lookup_code     Varchar2(30);
 v_request_id      Number := p_request_id;

 v_phase           Varchar2(30);
 v_status          Varchar2(30);
 v_dev_phase       Varchar2(30);
 v_dev_status      Varchar2(30);
 v_message         Varchar2(240);
 v_call_status       Boolean;

 Cursor Get_status_Code_C IS
 Select Status_Code
 From GL_AUTO_ALLOC_BATCH_HISTORY
 Where REQUEST_ID = p_request_Id
 AND   STEP_NUMBER = p_step_number;

 Cursor Get_Status_Meaning_C IS
 Select
  Meaning
 ,Description
 From gl_lookups
 Where LOOKUP_TYPE = 'AUTOALLOCATION_STATUS'
 And LOOKUP_CODE = v_lookup_code;
 Cursor get_request_id_C IS
  Select request_id
  From GL_AUTO_ALLOC_BAT_HIST_DET
  Where PARENT_REQUEST_ID = p_request_Id
  And STEP_NUMBER = p_step_number
  order by request_id desc;

Begin

If p_mode = 'SD' Then
  -- Mode is step-down
  If p_request_id is Null Or
     p_step_number is Null Then
     l_status := NULL;
     return;
  End If;

  Open Get_status_Code_C;
  Fetch Get_status_Code_C into v_status_code;
  If Get_status_Code_C%NOTFOUND Then
      l_status := NULL;
      Close Get_status_Code_C;
      return;
   End If;
   Close Get_status_Code_C;

   If v_status_code in ('ALPP','DCPP','UPPP','RLAPP','RALPP',
                                'RDCPP','RUPPP' ) Then
      -- Find whether pending request is presently  running or completed
      Open get_request_id_C;
      Fetch get_request_id_C into v_request_id;
      Close get_request_id_C;

      v_call_status :=
      fnd_concurrent.get_request_status(
           v_request_Id
          ,'PA'
          ,NULL
          ,v_phase
          ,v_status
          ,v_dev_phase
          ,v_dev_status
          ,v_message
        );

     If v_dev_phase = 'COMPLETE' AND
           v_dev_status In ('ERROR','CANCELLED','TERMINATED') Then

         if v_status_code = 'ALPP' Then
            v_status_code := 'ALPF';
         Elsif v_status_code = 'DCPP' Then
            v_status_code := 'DCPF';
         Elsif v_status_code = 'RLALPP' Then
            v_status_code := 'RLALPF';
         ELsif v_status_code = 'UPPP' Then
            v_status_code := 'UPPF';
         Elsif v_status_code = 'RALPP' Then
            v_status_code := 'RALPF';
         Elsif v_status_code = 'RDCPP' Then
            v_status_code := 'RDCPF';
         Elsif v_status_code = 'RUPPP' Then
            v_status_code := 'RUPPP';
         End If;

     ElsIf v_dev_phase = 'COMPLETE' AND
           v_dev_status = 'NORMAL' Then

 	 If v_status_code = 'ALPP'  Then
            v_status_code := 'ALPC' ;
         ElsIf v_status_code = 'RLALPP'  Then
            v_status_code := 'RLALPC' ;
         ElsIf v_status_code = 'DCPP'  Then
            v_status_code := 'DCPC' ;

         ElsIf v_status_code = 'UPPP'  Then
            v_status_code := 'UPPC' ;
         ElsIf v_status_code = 'RALPP'  Then
            v_status_code := 'RALPC' ;
         ElsIf v_status_code = 'RDCPP'  Then
            v_status_code := 'RDCPC' ;
         ElsIf v_status_code = 'RUPPP'  Then
            v_status_code := 'RUPPC' ;
         End If;

      ElsIf v_dev_phase = 'RUNNING' AND
           v_dev_status in ('NORMAL')  Then

         If v_status_code = 'ALPP'  Then
            v_status_code := 'ALPR' ;
         ElsIf v_status_code = 'RLALPP'  Then
            v_status_code := 'RLALPR' ;
         ElsIf v_status_code = 'DCPP'  Then
            v_status_code := 'DCPR' ;
         ElsIf v_status_code = 'UPPP'  Then
            v_status_code := 'UPPR' ;
         ElsIf v_status_code = 'RALPP'  Then
            v_status_code := 'RALPR' ;
         ElsIf v_status_code = 'RDCPP'  Then
            v_status_code := 'RDCPR' ;
         ElsIf v_status_code = 'RUPPP'  Then

            v_status_code := 'RUPPR' ;
         End If;

      End If;
   End If;
   v_lookup_code := v_status_code;

   Open Get_Status_Meaning_C;
   Fetch Get_Status_Meaning_C into
      v_Meaning, v_description;

   If Get_Status_Meaning_C%NOTFOUND Then
      FND_MESSAGE.Set_Name('SQLGL', 'GL_AUTO_ALLOC_STATUS_ERR');
      l_status := FND_MESSAGE.Get;
      Close Get_Status_Meaning_C;
      return;
   Else
     Close Get_Status_Meaning_C;
     l_status := v_description;
   End If;
Else
  -- if not step down
   v_call_status :=
        fnd_concurrent.get_request_status(
           v_request_Id
          ,'PA'
          ,NULL
          ,v_phase
          ,v_status
          ,v_dev_phase
          ,v_dev_status
          ,v_message
        );

 If v_dev_phase = 'COMPLETE' AND
          v_dev_status = 'NORMAL' Then
           l_status := v_dev_phase;

       ElsIf v_dev_phase = 'COMPLETE' AND
         v_dev_status <> 'NORMAL' Then
         l_status := v_dev_status;
       Else
         l_status := v_dev_phase;
       End If;
 End If;
End get_pa_step_status;

------------------------------------------------------------------------------
END PA_GL_AUTOALLOC_PKG;

/
