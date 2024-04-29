--------------------------------------------------------
--  DDL for Package Body CS_CHG_AUTO_SUB_CON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CHG_AUTO_SUB_CON_PKG" as
/* $Header: csxvasub.pls 120.9.12010000.4 2010/01/11 10:59:21 sshilpam ship $ */
/*********** Global  Variables  ********************************/
G_PKG_NAME     CONSTANT  VARCHAR2(30)  := 'CS_Chg_Auto_Sub_CON_PKG';
/***************************************************************/
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   Procedure Name:  Main_Procedure
--   Type    :  Private
--   Purpose :  This is the main procedure of the concurrent program.
--   Pre-Req :
--   Parameters:
--   OUT :
--      Errbuf                 OUT       VARCHAR2  This is for returning error messages
--                                                 Standard out parameter for a concurrent program.
--      Retcode                OUT       NUMBER    This is an out parameter to return error
--                                                 code to the concurrent program.
--                                                 Standard out parameter for a concurrent program.
--                                                 retcode = 0 success, 1 = warning, 2=error.
--
PROCEDURE Main_Procedure(ERRBUF      OUT    NOCOPY  VARCHAR2,
         	         RETCODE     OUT    NOCOPY  NUMBER) IS

lx_msg_data  VARCHAR2(2000);
lx_msg_count NUMBER;
lx_return_status VARCHAR2(1);
conc_status BOOLEAN;

BEGIN

         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'***************************************************************************************************');
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Starting Concurrent Program for autosubmitting Charge Lines: '|| to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'***************************************************************************************************');

--added for r12 to populate temporary tables
                        MO_GLOBAL.INIT('CS_CHARGES')  ;

			Auto_Submit_Chg_Lines(p_api_version   => 1.0,
       					      p_init_msg_list => fnd_api.g_false,
       					      p_commit        => fnd_api.g_false,
                              		      x_return_status => lx_return_status,
       					      x_msg_count     => lx_msg_count,
       					      x_msg_data      => lx_msg_data);

                       IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS)
                       THEN
                       conc_status := fnd_concurrent.set_completion_status('WARNING','Warning');
                       END IF;

       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'*****************************************************************************************************');
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Completed Concurrent Program for autosubmitting Charge Lines: '|| to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'*****************************************************************************************************');

END Main_Procedure;

/*--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   Procedure Name:  Auto_Submit_Chg_Lines
--   Type    :  Private
--   Purpose :  This procedure is for identifying lines for Autosubmission.
--              It is intended for use by the owning module only.
--   Pre-Req :
--   Parameters:
--       p_api_version           IN      NUMBER     Required
--       p_init_msg_list         IN      VARCHAR2   Optional
--       p_commit                IN      VARCHAR2   Optional
--       x_return_status         OUT     VARCHAR2
--       x_msg_data	         OUT     VARCHAR2
--
==  Modification History:
==
==  Date        Name       Desc
==  ----------  ---------  ---------------------------------------------
==  05-May-2008  BKANIMOZ  Bug Fix for 6995001.Modified the Where Clause
==                         l_auto_submit_mode = 'WHEN_ALL_TASKS_FINAL'
==
==  04-May-2009  GASANKAR  Bug Fix 7692111 : Added the condition AND   ced.order_line_id IS NULL
==                         in autosubmit_cv cursors.
========================================================================*/
PROCEDURE Auto_Submit_Chg_Lines(
       p_api_version     IN   NUMBER,
       p_init_msg_list   IN   VARCHAR2,
       p_commit          IN   VARCHAR2,
       x_return_status   OUT  NOCOPY VARCHAR2,
       x_msg_count       OUT  NOCOPY NUMBER,
       x_msg_data	 OUT  NOCOPY VARCHAR2) IS

-- Created a dummy cursor so that can create strong ref cursors instead of weak.
-- This cursor will not be opened in the api.
--
CURSOR AutosubmitTyp IS
    SELECT inc.incident_id,
           inc.incident_number,
	   trunc(inc.incident_date) incident_date,
           inc.incident_type_id,
           edt.estimate_detail_id,
           hzp.party_name,
           edt.bill_to_party_id,
           edt.currency_code,
           edt.list_price,
           edt.quantity_required,
           edt.selling_price,
           nvl(edt.contract_discount_amount,0) contract_discount_amount,
           edt.after_warranty_cost
   FROM   cs_estimate_details edt,
          cs_incidents_all_b inc,
          hz_parties hzp
  WHERE   edt.incident_id = inc.incident_id
  AND     edt.bill_to_party_id = hzp.party_id;


TYPE AutosubmitCurTyp IS REF CURSOR RETURN AutosubmitTyp%ROWTYPE;
autosubmit_cv AutosubmitCurTyp;

TYPE t_auto_submit_lines_tab IS TABLE OF AutosubmitTyp%ROWTYPE
INDEX BY BINARY_INTEGER;

AutosubmitTAB     t_auto_submit_lines_tab;
--
-- Charge Lines Cursor for Total Service Requests and Incident_Type.
CURSOR Cs_Chg_Sr_Total(p_incident_id NUMBER)  IS
  -- Total for a Service request,Estimates,Actuals and Incident_Type.
    SELECT ced.incident_id,
           ciab.incident_number,
           ciab.incident_type_id,
           cit.name incident_type,
           nvl(trunc(ciab.incident_date),trunc(ciab.creation_date)) incident_date,
           ciab.creation_date,
           ced.currency_code,
           sum(ced.after_warranty_cost) Total_Charges
    FROM   cs_incidents_all_b ciab,
           cs_incident_types cit,
           cs_estimate_details ced
    WHERE  ciab.incident_id = ced.incident_id
      AND  ciab.incident_type_id = cit.incident_type_id
      AND  ced.charge_line_type IN ('ACTUAL','IN_PROGRESS')
      AND  ced.incident_id = p_incident_id
   GROUP BY ced.currency_code,ced.incident_id,ciab.incident_number,ciab.incident_date,ciab.creation_date,ciab.incident_type_id,cit.name;

TYPE t_chg_sr_tot_tab IS TABLE OF Cs_Chg_sr_Total%rowtype
INDEX BY BINARY_INTEGER;

ChgSrTotTAB     t_chg_sr_tot_tab;

-- Charge Lines cursor for Estimate and Actual Totals.
--
CURSOR Cs_Chg_Est_Act_Tot(p_incident_id NUMBER) IS
       SELECT sum(decode(edt.charge_line_type,'ESTIMATE',edt.after_warranty_cost, NULL)) Estimates,
       	      sum(decode(edt.charge_line_type,'ESTIMATE', NULL, edt.after_warranty_cost)) Actuals,
       	      edt.currency_code,
              inc.incident_number,
              inc.incident_date,
              inc.incident_id
        FROM  cs_estimate_details edt,
              cs_incidents_all_b inc
	WHERE edt.incident_id = p_incident_id
	AND   inc.incident_id = edt.incident_id
	GROUP BY currency_code,inc.incident_id,inc.incident_number,inc.incident_date;

TYPE t_chg_est_Act_tot_tab IS TABLE OF Cs_Chg_Est_Act_Tot%rowtype
INDEX BY BINARY_INTEGER;

ChgEstActTotTAB     t_chg_est_Act_tot_tab;
--
--
  CURSOR cs_chg_restriction_rules IS
  SELECT restriction_id,
         restriction_type,
         condition,
         value_object_id,
         value_amount,
         currency_code,
         trunc(start_date_active) start_date_active,
         trunc(end_date_active) end_date_active
  FROM   cs_chg_sub_restrictions
  ORDER BY restriction_type;

TYPE t_restriction_rules_tab IS TABLE OF cs_chg_restriction_rules%rowtype
INDEX BY BINARY_INTEGER;

RestrulesTAB   t_restriction_rules_tab;
--
-- Added for bug:3475786
-- Cursor for deriving no_charge_flag
	CURSOR cs_charge_flags(p_estimate_detail_id number) IS
	SELECT nvl(edt.no_charge_flag,'N') chg_no_charge_flag,
  	       nvl(tt.no_charge_flag,'N')  txn_no_charge_flag
	FROM   cs_estimate_details edt,
	       cs_transaction_types tt
	WHERE  edt.estimate_detail_id = p_estimate_detail_id
	AND    tt.transaction_type_id = edt.transaction_type_id;
--
l_chg_no_charge_flag VARCHAR2(1);
l_txn_no_charge_flag VARCHAR2(1);
--
-- Define Local Variables
 l_api_name                  CONSTANT  VARCHAR2(30) := 'Auto_Submit_Chg_Lines' ;
 l_api_name_full             CONSTANT  VARCHAR2(61) := G_PKG_NAME || '.' || l_api_name ;
 l_api_version               CONSTANT  NUMBER       := 1.0 ;
--
--
i  NUMBER := 0;
j  NUMBER := 0;
k  NUMBER := 0;
L  NUMBER := 0;
N  NUMBER := 0;
A  NUMBER := 0;
l_sr_restriction      VARCHAR2(100);
l_chg_line_restriction VARCHAR2(100);
l_incident_id          NUMBER := -999;
l_auto_submit_mode     VARCHAR2(30);
l_restriction_qualify_flag VARCHAR2(1) := 'N';
l_line_restriction_flag    VARCHAR2(1) := 'N';
l_last_rec_flag    	   VARCHAR2(1) := 'N';
last_rec    		NUMBER := -999;
--
rest_count	  NUMBER;
--
l_actual VARCHAR2(30);
l_Actual_Percent   NUMBER;
l_estimate VARCHAR2(30);
l_currency_code VARCHAR2(30) := NULL;
--
--
l_msg_index_out        NUMBER;
--
--
/*** Variables for logging messages  ****/
l_rest1         VARCHAR2(250);
l_rest2         VARCHAR2(250);
l_rest3         VARCHAR2(250);


--new enh for simplex
l_check_debrief_status VARCHAR2(1) := 'N';
l_found  VARCHAR2(1)       := 'N';

BEGIN

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --  Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

    l_auto_submit_mode := fnd_profile.value('CS_CHG_AUTO_SUBMIT_MODE');
    l_check_debrief_status := fnd_profile.value('CS_CHG_CHECK_DEBRIEF_STATUS'); --new enh

         IF     l_check_debrief_status IS NULL THEN
                l_check_debrief_status := 'N';
         END IF;



     -- Validate autosubmit mode profile.
     -- Auto_Submit_Mode can contain one of the following values:
     -- 'AS_AVAILABLE','WHEN_ALL_TASKS_FINAL', 'WHEN_SERVICE_REQUEST_FINAL'.
     BEGIN
     IF l_auto_submit_mode IS NULL THEN
         FND_MSG_PUB.Initialize;
         FND_MESSAGE.Set_Name('CS','CS_CHG_DEFINE_PROFILE_OPTION');
         FND_MESSAGE.Set_Token('PROFILE_OPTION','CS_CHG_AUTO_SUBMIT_MODE');
         FND_MSG_PUB.Add;
         -- x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      	FND_MSG_PUB.get(p_encoded  => 'F',
       	                p_data=>x_msg_data,
                        p_msg_index_out=> l_msg_index_out);

	-- Recording exceptions in the log file.
      	FND_FILE.put_line(FND_FILE.LOG,x_msg_data);

     END;


    /* Querying the right select statement into the cursor variable */
    IF l_auto_submit_mode = 'AS_AVAILABLE' THEN
            IF NOT autosubmit_cv%ISOPEN THEN
                /* Open cursor variable. */
                OPEN autosubmit_cv FOR  SELECT ciab.incident_id,
                                               ciab.incident_number,
                                               nvl(trunc(ciab.incident_date),trunc(ciab.creation_date)) incident_date,
                                               ciab.incident_type_id,
	                                       ced.estimate_detail_id,
                                               hzp.party_name,
                                               ced.bill_to_party_id,
	                                       ced.currency_code,
	                                       ced.list_price,
                                               ced.quantity_required,
                                               ced.selling_price,
      	                                       nvl(ced.contract_discount_amount,0) contract_discount_amount,
                                               ced.after_warranty_cost
                                        FROM   cs_incidents_all_b ciab,
	                                       cs_estimate_details ced,
                                               hz_parties hzp
                                        WHERE  ciab.incident_id = ced.incident_id
                                          AND  ced.bill_to_party_id = hzp.party_id
                                          AND  ced.line_submitted = 'N'
					  AND  ced.order_line_id IS NULL  --bug 7692111
                                          AND  ced.charge_line_type = 'ACTUAL'
                                          AND  ced.source_code = 'SD'
                                          AND  ced.original_source_code = 'SR'
                                          AND  ced.interface_to_oe_flag = 'Y'
                                       ORDER BY ciab.incident_id;
           END IF;
    ELSIF l_auto_submit_mode = 'WHEN_ALL_TASKS_FINAL' THEN

    IF    l_check_debrief_status = 'N' THEN
            IF NOT autosubmit_cv%ISOPEN THEN
                /* Open cursor variable. */
                OPEN autosubmit_cv FOR SELECT  ciab.incident_id,
                                               ciab.incident_number,
                                               nvl(trunc(ciab.incident_date),trunc(ciab.creation_date)) incident_date,
                                               ciab.incident_type_id,
	                                       ced.estimate_detail_id,
                                               hzp.party_name,
                                               ced.bill_to_party_id,
	                                       ced.currency_code,
	                                       ced.list_price,
                                               ced.quantity_required,
                                               ced.selling_price,
      	                                       nvl(ced.contract_discount_amount,0) contract_discount_amount,
                                               ced.after_warranty_cost
                                       FROM    cs_incidents_all_b ciab,
                                               cs_estimate_details ced,
                                               hz_parties hzp
	                               WHERE   ciab.incident_id = ced.incident_id
                                         AND   ced.bill_to_party_id = hzp.party_id
                                         AND   ced.line_submitted = 'N'
                                         AND   ced.charge_line_type = 'ACTUAL'
					 AND   ced.order_line_id IS NULL  --bug 7692111
                                         AND   ced.source_code = 'SD'
                                         AND   ced.original_source_code = 'SR'
                                         AND   ced.interface_to_oe_flag = 'Y'
                                          AND   ciab.incident_id NOT IN  (SELECT jtv.source_object_id
                                                                     FROM   jtf_tasks_vl jtv,
									    jtf_task_statuses_b jts
                                                                           -- jtf_task_assignments jta,
	                                                                   -- csf_debrief_headers cdh
                                                                     WHERE jtv.source_object_id = ciab.incident_id
								     -- AND  jta.task_id = jtv.task_id
                                                                      AND   jtv.source_object_type_code = 'SR'
                                                                      -- checking for closed tasks.
                                                                      AND  jtv.task_status_id = jts.task_status_id
                                                                      AND   nvl(jts.closed_flag,'N') = 'N')
                                                                      --AND   cdh.task_assignment_id = jta.task_assignment_id
                                                                      --AND   cdh.processed_flag = 'COMPLETED')
                                         ORDER BY ciab.incident_id;
            END IF;

   ELSIF  l_check_debrief_status = 'Y' THEN  -- new enh for simplex
          IF NOT autosubmit_cv%ISOPEN THEN
                OPEN autosubmit_cv FOR SELECT  ciab.incident_id,
                                               ciab.incident_number,
                                               nvl(trunc(ciab.incident_date),trunc(ciab.creation_date)) incident_date,
                                               ciab.incident_type_id,
                                               ced.estimate_detail_id,
                                               hzp.party_name,
                                               ced.bill_to_party_id,
                                               ced.currency_code,
                                               ced.list_price,
                                               ced.quantity_required,
                                               ced.selling_price,
                                               nvl(ced.contract_discount_amount,0) contract_discount_amount,
                                               ced.after_warranty_cost
                                       FROM    cs_incidents_all_b ciab,
                                               cs_estimate_details ced,
                                               hz_parties hzp
                                       WHERE   ciab.incident_id = ced.incident_id
                                         AND   ced.bill_to_party_id = hzp.party_id
                                         AND   ced.line_submitted = 'N'
					 AND   ced.order_line_id IS NULL  --bug 7647091
                                         AND   ced.charge_line_type = 'ACTUAL'
                                         AND   ced.source_code = 'SD'
                                         AND   ced.original_source_code = 'SR'
                                         AND   ced.interface_to_oe_flag = 'Y'
                                         AND   ciab.incident_id IN (SELECT jtv.source_object_id
                                                                     FROM   jtf_tasks_vl jtv,
                                                                            jtf_task_statuses_b jts,
                                                                            jtf_task_assignments jta,
                                                                            csf_debrief_headers cdh
                                                                     WHERE jtv.source_object_id = ciab.incident_id
                                                                      AND  jta.task_id = jtv.task_id
                                                                      AND   jtv.source_object_type_code = 'SR'
                                                                      -- checking for closed tasks.
                                                                      AND  jtv.task_status_id = jts.task_status_id
                                                                      AND   nvl(jts.closed_flag,'N') = 'Y'
                                                                      AND   cdh.task_assignment_id = jta.task_assignment_id)
                                         ORDER BY ciab.incident_id;
            END IF;
    END IF;

    ELSIF l_auto_submit_mode = 'WHEN_SERVICE_REQUEST_FINAL' THEN
            IF NOT autosubmit_cv%ISOPEN THEN
                /* Open cursor variable. */
                OPEN autosubmit_cv FOR SELECT ciab.incident_id,
                                              ciab.incident_number,
                                              nvl(trunc(ciab.incident_date),trunc(ciab.creation_date)) incident_date,
                                              ciab.incident_type_id,
	                                          ced.estimate_detail_id,
                                              hzp.party_name,
                                              ced.bill_to_party_id,
	                                          ced.currency_code,
	                                          ced.list_price,
                                              ced.quantity_required,
                                              ced.selling_price,
      	                                      nvl(ced.contract_discount_amount,0) contract_discount_amount,
                                              ced.after_warranty_cost
                                        FROM   cs_incidents_all_b ciab,
                                               hz_parties hzp,
                                               cs_estimate_details ced
                                        WHERE  ciab.incident_id = ced.incident_id
                                          AND  ced.bill_to_party_id = hzp.party_id
                                          AND  ciab.status_flag = 'C'
                                          AND  ced.line_submitted = 'N'
					  AND   ced.order_line_id IS NULL  --bug 7692111
                                          AND  ced.charge_line_type = 'ACTUAL'
                                          AND  ced.source_code = 'SD'
                                          AND  ced.original_source_code = 'SR'
                                          AND  ced.interface_to_oe_flag = 'Y'
                                       ORDER BY ciab.incident_id;
            END IF;
     END IF;  -- End of autosubmit mode.

          -- Open restrictions cursor and store it into a table.
          --
	  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*********************************');
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Start of Restrictions');
	  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*********************************');

          OPEN cs_chg_restriction_rules;
           LOOP
             j := j+1;
             -- Fetch all the restriction rules.
               FETCH  cs_chg_restriction_rules
               INTO  RestrulesTab(j);
               EXIT WHEN cs_chg_restriction_rules%NOTFOUND;


               l_rest1 := ('Restriction:' || RestrulesTab(j).restriction_type || ' '|| 'Currency:' || RestrulesTab(j).currency_code);
               l_rest2 := ('Amount:' || RestrulesTab(j).Value_Amount || ' '|| 'Value_Object_Id:' || RestrulesTab(j).Value_Object_Id);
               l_rest3 := ('Start_Date:' || RestrulesTab(j).Start_Date_Active || ' '|| 'End_Date: ' || RestrulesTab(j).End_Date_Active);

               FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_rest1 || l_rest2 || l_rest3);

           END LOOP;
           CLOSE cs_chg_restriction_rules;

	   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '***********************************');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'End of Restrictions');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '***********************************');

         --
         -- Fetch all charge lines into a table
          LOOP
      	    i := i+1;

         -- Fetch all eligible lines to be auto submitted.
             FETCH autosubmit_cv
             INTO  AutosubmitTAB(i);
             IF autosubmit_cv%found then
                l_found := 'Y';
             else
                l_found := 'N';
             End IF;
             EXIT WHEN autosubmit_cv%NOTFOUND;

	 -- Calling Update_Charge_Details to clear existing messages before
         -- logging new ones.
             Update_Charge_Lines(AutosubmitTAB(i).incident_id,
                                AutosubmitTAB(i).incident_number,
                                NULL,
                                NULL,
                                NULL,
                                'N',
                                'CLEAR',
                                x_return_status,
                                x_msg_data);
          --
          --
	   END LOOP;
           CLOSE autosubmit_cv;

        i := AutosubmitTAB.FIRST;
        --
        LOOP

         -- dbms_output.put_line('Value Of First Incident_Id' || AutosubmitTAB(i).incident_id);
         -- dbms_output.put_line('Value Of counter i ' || i);
         -- dbms_output.put_line('Restriction qualify flag' || l_restriction_qualify_flag);


    -- new enh for simplex


      IF  l_check_debrief_status = 'Y' THEN

          Check_Debrief_Status(p_incident_id  => AutosubmitTAB(i).incident_id,
                               p_incident_number  => AutosubmitTAB(i).incident_number,
                               p_estimate_detail_id  => AutosubmitTab(i).estimate_detail_id,
                               p_currency_code => AutosubmitTAB(i).currency_code,
                               x_restriction_qualify_flag => l_restriction_qualify_flag,
                               x_return_status  => x_return_status,
                               x_msg_data => x_msg_data);
     END IF;

    -- end  new enh for simplex


          /***********************     LINE LEVEL RESTRICTIONS      ********************/

	   -- dbms_output.put_line('Restriction_count' || RestrulesTab.count);
           rest_count := RestrulesTab.count;
           IF rest_count > 0 then

	   j := RestrulesTab.FIRST;
           LOOP


		-- If there is only one sr, then make sure that line level restrictions
             	-- are excecuted before sr level restrictions.
             	--

              IF AutosubmitTAB.NEXT(i) IS NULL THEN
	           last_rec := AutosubmitTAB.COUNT;

              	if last_rec <> -999 and
              	   last_rec = AutosubmitTAB.LAST then
                   l_line_restriction_flag  := 'Y';
	      	end if;
             END IF;


              -- Beginning of line level restrictions.
              --
              -- dbms_output.put_line('Beginnig of Line_Level_restriction' || RestrulesTab(j).restriction_type);
              -- dbms_output.put_line('Restriction_count' || RestrulesTab.count);

                IF RestrulesTab(j).restriction_type = ('CHARGE_LINE_AMOUNT') THEN

                -- dbms_output.put_line('inside Charge_line_amt');
                -- dbms_output.put_line('Charge_line_amt condition'|| RestrulesTab(j).condition);

                       IF RestrulesTab(j).condition = '>' THEN
                           if  (AutosubmitTAB(i).after_warranty_cost > RestrulesTab(j).value_amount and
                               AutosubmitTAB(i).currency_code = RestrulesTab(j).currency_code  and
                               ((AutosubmitTAB(i).incident_date >= RestrulesTab(j).start_date_active
                                 or RestrulesTab(j).start_date_active IS NULL) and
                               (AutosubmitTAB(i).incident_date <= RestrulesTab(j).end_date_active
                                or RestrulesTab(j).end_date_active IS NULL))) then



			        FND_MSG_PUB.Initialize;
                                FND_MESSAGE.SET_NAME('CS', 'CS_CHG_LINE_AMT_RESTRICTION');
                                FND_MESSAGE.SET_TOKEN('CURRENCY_CODE',AutosubmitTAB(i).currency_code);
                                FND_MESSAGE.SET_TOKEN('AFTER_WARRANTY_COST',AutosubmitTAB(i).after_warranty_cost);
                                FND_MESSAGE.SET_TOKEN('RESTRICTION_TYPE', RestrulesTab(j).restriction_type);
                                FND_MESSAGE.SET_TOKEN('CONDITION', RestrulesTab(j).condition);
                                FND_MESSAGE.SET_TOKEN('VALUE_AMOUNT', RestrulesTab(j).value_amount);
                                FND_MESSAGE.SET_TOKEN('CURRENCY', RestrulesTab(j).currency_code);
                                FND_MSG_PUB.Add;

                                Update_Charge_Lines(AutosubmitTAB(i).incident_id,
                                                    AutosubmitTAB(i).incident_number,
                                                    AutosubmitTab(i).estimate_detail_id,
                                                    AutosubmitTAB(i).currency_code,
                                                    'CS_CHG_LINE_AMT_RESTRICTION',
                                                    'N',
                                                    'LINE',
                                                     x_return_status,
                                                     x_msg_data);

                                l_restriction_qualify_flag := 'Y';

                          end if;

                            -- dbms_output.put_line('inside Charge_line_amt before = ');

                     ELSIF RestrulesTab(j).condition = '=' THEN
                          if  (AutosubmitTAB(i).after_warranty_cost = RestrulesTab(j).value_amount and
                               AutosubmitTAB(i).currency_code = RestrulesTab(j).currency_code and
                               ((AutosubmitTAB(i).incident_date >= RestrulesTab(j).start_date_active
                                 or RestrulesTab(j).start_date_active IS NULL) and
                               (AutosubmitTAB(i).incident_date <= RestrulesTab(j).end_date_active
                                or RestrulesTab(j).end_date_active IS NULL))) then


                                FND_MSG_PUB.Initialize;
                                FND_MESSAGE.SET_NAME('CS', 'CS_CHG_LINE_AMT_RESTRICTION');
                                FND_MESSAGE.SET_TOKEN('CURRENCY_CODE',AutosubmitTAB(i).currency_code);
                                FND_MESSAGE.SET_TOKEN('AFTER_WARRANTY_COST',AutosubmitTAB(i).after_warranty_cost);
                                -- FND_MESSAGE.SET_TOKEN('SR', chgSrTotTAB(k).incident_number, TRUE);
                                FND_MESSAGE.SET_TOKEN('RESTRICTION_TYPE', RestrulesTab(j).restriction_type);
                                FND_MESSAGE.SET_TOKEN('CONDITION', RestrulesTab(j).condition);
                                FND_MESSAGE.SET_TOKEN('VALUE_AMOUNT', RestrulesTab(j).value_amount);
                                FND_MESSAGE.SET_TOKEN('CURRENCY', RestrulesTab(j).currency_code);
                                FND_MSG_PUB.Add;

                                -- Call Update_Charge_Lines.
                                Update_Charge_Lines(AutosubmitTAB(i).incident_id,
                                                    AutosubmitTAB(i).incident_number,
                                                    AutosubmitTab(i).estimate_detail_id,
                                                    AutosubmitTAB(i).currency_code,
                                                    'CS_CHG_LINE_AMT_RESTRICTION',
                                                    'N',
                                                    'LINE',
                                                     x_return_status,
                                                     x_msg_data);

                                l_restriction_qualify_flag := 'Y';

                          end if;

                          -- dbms_output.put_line('Before Restriction Condition ' || RestrulesTab(j).condition);

                         ELSIF RestrulesTab(j).condition = '<' THEN

			  if  AutosubmitTAB(i).after_warranty_cost < RestrulesTab(j).value_amount and
                              AutosubmitTAB(i).currency_code = RestrulesTab(j).currency_code and
                              (AutosubmitTAB(i).incident_date >= RestrulesTab(j).start_date_active
                               or RestrulesTab(j).start_date_active IS NULL) and                                                        (AutosubmitTAB(i).incident_date <= RestrulesTab(j).end_date_active
                                 or RestrulesTab(j).end_date_active IS NULL) then

                          -- dbms_output.put_line('After Restriction Condition ' || RestrulesTab(j).condition);

				FND_MSG_PUB.Initialize;
                                FND_MESSAGE.SET_NAME('CS', 'CS_CHG_LINE_AMT_RESTRICTION');
                                FND_MESSAGE.SET_TOKEN('CURRENCY_CODE',AutosubmitTAB(i).currency_code);
                                FND_MESSAGE.SET_TOKEN('AFTER_WARRANTY_COST',AutosubmitTAB(i).after_warranty_cost);
                                -- FND_MESSAGE.SET_TOKEN('SR', chgSrTotTAB(k).incident_number, TRUE);
                                FND_MESSAGE.SET_TOKEN('RESTRICTION_TYPE', RestrulesTab(j).restriction_type);
                                FND_MESSAGE.SET_TOKEN('CONDITION', RestrulesTab(j).condition);
                                FND_MESSAGE.SET_TOKEN('VALUE_AMOUNT', RestrulesTab(j).value_amount);
                                FND_MESSAGE.SET_TOKEN('CURRENCY', RestrulesTab(j).currency_code);
                                FND_MSG_PUB.Add;

                               -- Call Update_Charge_Lines.
                               Update_Charge_Lines(AutosubmitTAB(i).incident_id,
                                                   AutosubmitTAB(i).incident_number,
                                                  AutosubmitTab(i).estimate_detail_id,
                                                  AutosubmitTAB(i).currency_code,
                                                  'CS_CHG_LINE_AMT_RESTRICTION',
                                                  'N',
                                                  'LINE',
                                                  x_return_status,
                                                  x_msg_data);

                               l_restriction_qualify_flag := 'Y';

                         end if;

                        ELSIF RestrulesTab(j).condition = '<=' THEN
                          if  (AutosubmitTAB(i).after_warranty_cost <= RestrulesTab(j).value_amount and
                               AutosubmitTAB(i).currency_code = RestrulesTab(j).currency_code and
                               ((AutosubmitTAB(i).incident_date >= RestrulesTab(j).start_date_active
                                 or RestrulesTab(j).start_date_active IS NULL) and
                               (AutosubmitTAB(i).incident_date <= RestrulesTab(j).end_date_active
                                or RestrulesTab(j).end_date_active IS NULL))) then

                                FND_MSG_PUB.Initialize;
                                FND_MESSAGE.SET_NAME('CS', 'CS_CHG_LINE_AMT_RESTRICTION');
                                FND_MESSAGE.SET_TOKEN('CURRENCY_CODE',AutosubmitTAB(i).currency_code);
                                FND_MESSAGE.SET_TOKEN('AFTER_WARRANTY_COST',AutosubmitTAB(i).after_warranty_cost);
                                -- FND_MESSAGE.SET_TOKEN('SR', chgSrTotTAB(k).incident_number, TRUE);
                                FND_MESSAGE.SET_TOKEN('RESTRICTION_TYPE', RestrulesTab(j).restriction_type);
                                FND_MESSAGE.SET_TOKEN('CONDITION', RestrulesTab(j).condition);
                                FND_MESSAGE.SET_TOKEN('VALUE_AMOUNT', RestrulesTab(j).value_amount);
                                FND_MESSAGE.SET_TOKEN('CURRENCY', RestrulesTab(j).currency_code);
                                FND_MSG_PUB.Add;

                               -- Call Update_Charge_Lines.
                               Update_Charge_Lines(AutosubmitTAB(i).incident_id,
                                                   AutosubmitTAB(i).incident_number,
                                                   AutosubmitTab(i).estimate_detail_id,
                                                   AutosubmitTAB(i).currency_code,
                                                   'CS_CHG_LINE_AMT_RESTRICTION',
                                                   'N',
                                                   'LINE',
                                                   x_return_status,
                                                   x_msg_data);

                               l_restriction_qualify_flag := 'Y';

                          end if;

                          ELSIF RestrulesTab(j).condition = '>=' THEN
                          if  (AutosubmitTAB(i).after_warranty_cost >= RestrulesTab(j).value_amount and
                               AutosubmitTAB(i).currency_code = RestrulesTab(j).currency_code and
                               ((AutosubmitTAB(i).incident_date >= RestrulesTab(j).start_date_active
                                 or RestrulesTab(j).start_date_active IS NULL) and
                               (AutosubmitTAB(i).incident_date <= RestrulesTab(j).end_date_active
                                or RestrulesTab(j).end_date_active IS NULL))) then


                                FND_MSG_PUB.Initialize;
                                FND_MESSAGE.SET_NAME('CS', 'CS_CHG_LINE_AMT_RESTRICTION');
                                FND_MESSAGE.SET_TOKEN('CURRENCY_CODE',AutosubmitTAB(i).currency_code);
                                FND_MESSAGE.SET_TOKEN('AFTER_WARRANTY_COST',AutosubmitTAB(i).after_warranty_cost);
                                -- FND_MESSAGE.SET_TOKEN('SR', chgSrTotTAB(k).incident_number, TRUE);
                                FND_MESSAGE.SET_TOKEN('RESTRICTION_TYPE', RestrulesTab(j).restriction_type);
                                FND_MESSAGE.SET_TOKEN('CONDITION', RestrulesTab(j).condition);
                                FND_MESSAGE.SET_TOKEN('VALUE_AMOUNT', RestrulesTab(j).value_amount);
                                FND_MESSAGE.SET_TOKEN('CURRENCY', RestrulesTab(j).currency_code);
                                FND_MSG_PUB.Add;

                                -- Call Update_Charge_Lines.
                                Update_Charge_Lines(AutosubmitTAB(i).incident_id,
                                                    AutosubmitTAB(i).incident_number,
                                                    AutosubmitTab(i).estimate_detail_id,
                                                    AutosubmitTAB(i).currency_code,
                                                    'CS_CHG_LINE_AMT_RESTRICTION',
                                                    'N',
                                                    'LINE',
                                                    x_return_status,
                                                    x_msg_data);

                               l_restriction_qualify_flag := 'Y';

                          end if;

                      END IF; -- Charge_line_amt Condition Endif

             ELSIF RestrulesTab(j).restriction_type = ('BILL_TO_CUSTOMER')  THEN
                   if (AutosubmitTAB(i).bill_to_party_id = RestrulesTab(j).value_object_id) and
                      ((AutosubmitTAB(i).incident_date >= RestrulesTab(j).start_date_active)
                        or (RestrulesTab(j).start_date_active IS NULL))  and
                         ((RestrulesTab(j).end_date_active IS NULL) or
                           (AutosubmitTAB(i).incident_date <= RestrulesTab(j).end_date_active)) then

                                FND_MSG_PUB.Initialize;
                                FND_MESSAGE.SET_NAME('CS', 'CS_CHG_BILL_TO_CT_RESTRICTION');
                                FND_MESSAGE.SET_TOKEN('BILL_TO_CUSTOMER_ID',AutosubmitTAB(i).bill_to_party_id);
                                FND_MESSAGE.SET_TOKEN('RESTRICTION_TYPE', RestrulesTab(j).restriction_type);
                                FND_MESSAGE.SET_TOKEN('CONDITION', RestrulesTab(j).condition);
                                FND_MESSAGE.SET_TOKEN('BILL_TO_CUSTOMER_NAME', AutosubmitTAB(i).party_name);
                                FND_MSG_PUB.Add;

                                -- Call Update_Charge_Lines.
                                Update_Charge_Lines(AutosubmitTAB(i).incident_id,
                                                    AutosubmitTAB(i).incident_number,
                                                    AutosubmitTab(i).estimate_detail_id,
                                                    AutosubmitTAB(i).currency_code,
                                                    'CS_CHG_BILL_TO_CT_RESTRICTION',
                                                    'N',
                                                    'LINE',
                                                    x_return_status,
                                                    x_msg_data);

                               l_restriction_qualify_flag := 'Y';
                       end if;

                ELSIF  (RestrulesTab(j).restriction_type = ('EXCLUDE_IF_MANUALLY_OVERRIDDEN') and
                         ((AutosubmitTAB(i).incident_date >= RestrulesTab(j).start_date_active
                                 	or RestrulesTab(j).start_date_active IS NULL) and                                                 (AutosubmitTAB(i).incident_date <= RestrulesTab(j).end_date_active or RestrulesTab(j).end_date_active IS NULL))) then
			--
			--
			OPEN cs_charge_flags(AutosubmitTAB(i).estimate_detail_id);
			FETCH cs_charge_flags
			INTO l_chg_no_charge_flag,
		             l_txn_no_charge_flag;
			CLOSE cs_charge_flags;
			--
			--
                             if ((AutosubmitTAB(i).after_warranty_cost <> ((AutosubmitTAB(i).selling_price * AutosubmitTAB(i).quantity_required  - AutosubmitTAB(i).contract_discount_amount)) and
                                  l_chg_no_charge_flag = 'N' and
                                  l_txn_no_charge_flag = 'N')  OR
                                 (AutosubmitTAB(i).after_warranty_cost <> ((AutosubmitTAB(i).selling_price * AutosubmitTAB(i).quantity_required  - AutosubmitTAB(i).contract_discount_amount)) and
                                  l_chg_no_charge_flag = 'N' and
                                  l_txn_no_charge_flag = 'Y')  OR
                               	 (AutosubmitTAB(i).after_warranty_cost <> ((AutosubmitTAB(i).selling_price * AutosubmitTAB(i).quantity_required  - AutosubmitTAB(i).contract_discount_amount)) and
                                  l_chg_no_charge_flag = 'Y' and
                                  l_txn_no_charge_flag = 'N')) then


                             	FND_MSG_PUB.Initialize;
                             	FND_MESSAGE.SET_NAME('CS', 'CS_CHG_AMT_OVERIDE_RESTRICTION');
                             	FND_MESSAGE.SET_TOKEN('CURRENCY_CODE',AutosubmitTAB(i).currency_code);
                             	FND_MESSAGE.SET_TOKEN('AFTER_WARRANTY_COST',AutosubmitTAB(i).after_warranty_cost);
                             	FND_MESSAGE.SET_TOKEN('RESTRICTION_TYPE', RestrulesTab(j).restriction_type);
                             	FND_MSG_PUB.Add;
                             	-- Need to verify if these are required.
                             	-- Confirmed with krasimir that this is not required.
                             	/* FND_MESSAGE.SET_TOKEN('CONDITION', RestrulesTab(j).condition,TRUE);
                             	FND_MESSAGE.SET_TOKEN('VALUE_AMOUNT', RestrulesTab(j).condition,TRUE);
                             	FND_MESSAGE.SET_TOKEN('CURRENCY', AutosubmitTAB(i).party_name,TRUE); */


                             	-- Call Update_Charge_Lines.

                             	Update_Charge_Lines(AutosubmitTAB(i).incident_id,
                               	                  AutosubmitTAB(i).incident_number,
                               	                  AutosubmitTab(i).estimate_detail_id,
                               	                  AutosubmitTAB(i).currency_code,
                                                 'CS_CHG_AMT_OVERIDE_RESTRICTION',
                                                 'N',
                                                 'LINE',
                                                  x_return_status,
                                                  x_msg_data);

                        	l_restriction_qualify_flag := 'Y';
                        end if;

                   END IF; -- End If for line level restriction types.

               EXIT WHEN j = RestrulesTab.LAST;
               j := RestrulesTab.NEXT(j);

               END LOOP;  -- restrictions End Loop
           -- dbms_output.put_line('Restriction_Qualify_Flag in the line end' || l_restriction_qualify_flag);

       /****************************** END OF LINE LEVEL RESTRICTIONS  ***********************************/

       	/***************************** SR LEVEL RESTRICTIONS **********************************/

	   -- Assigning the next index value to L
           -- and verify if the value exists.

          -- dbms_output.put_line('Restriction Count' || RestrulesTab.count);
          -- dbms_output.put_line('Beginning of SR level restriction');
          -- dbms_output.put_line('restriction_qualify_flag' || l_restriction_qualify_flag);

	   L := AutosubmitTAB.NEXT(i);
           IF AutosubmitTAB.EXISTS(L) THEN
           L := AutosubmitTAB.NEXT(i);
           ELSE
             L := i;
             l_last_rec_flag := 'Y';
           END IF;

           --
            IF  (AutosubmitTAB(i).incident_id <> AutosubmitTAB(L).incident_id
                 OR   l_line_restriction_flag = 'Y'
                 OR   l_last_rec_flag = 'Y' )  AND
                 (l_restriction_qualify_flag = 'N' OR
                  l_restriction_qualify_flag = 'Y') THEN

                 l_incident_id := AutosubmitTAB(i).incident_id;


           -- dbms_output.put_line('Value Of l_Incident_Id in the SR level restriction' || AutosubmitTAB(i).incident_id);

           OPEN Cs_Chg_Sr_Total(l_incident_id);
           LOOP
                  k := k+1;
                  FETCH Cs_Chg_Sr_Total
                  INTO ChgSrTotTAB(k);
                  EXIT WHEN Cs_Chg_Sr_Total%NOTFOUND;

                  j := RestrulesTab.FIRST;

                  LOOP

           -- dbms_output.put_line('Restriction_type before Total_Sr' || RestrulesTab(j).restriction_type);

                   /*** Call the SR level restrictions  **/
                IF  RestrulesTab(j).restriction_type = 'TOTAL_SERVICE_REQUEST_CHARGES' THEN
                     IF RestrulesTab(j).condition = '>' then
                       if chgSrTotTAB(k).Total_Charges > RestrulesTab(j).value_amount and
                          chgSrTotTAB(k).currency_code = RestrulesTab(j).currency_code and
                       ((chgSrTotTab(k).incident_date >= RestrulesTab(j).start_date_active
                         or RestrulesTab(j).start_date_active IS NULL) and
                         (chgSrTotTab(k).incident_date <= RestrulesTab(j).end_date_active
                         or RestrulesTab(j).end_date_active IS NULL)) then

                            FND_MSG_PUB.Initialize;
                            FND_MESSAGE.SET_NAME('CS', 'CS_CHG_TOTAL_CHRG_RESTRICTION');
                            FND_MESSAGE.SET_TOKEN('CURRENCY_CODE',chgSrTotTAB(k).currency_code);
                            FND_MESSAGE.SET_TOKEN('TOTAL_AMOUNT',chgSrTotTAB(k).Total_Charges);
                            FND_MESSAGE.SET_TOKEN('INCIDENT_NUMBER', chgSrTotTAB(k).incident_number);
                            FND_MESSAGE.SET_TOKEN('RESTRICTION_TYPE', RestrulesTab(j).restriction_type);
                            FND_MESSAGE.SET_TOKEN('CONDITION', RestrulesTab(j).condition);
                            FND_MESSAGE.SET_TOKEN('VALUE_AMOUNT', RestrulesTab(j).value_amount);
                            FND_MESSAGE.SET_TOKEN('CURRENCY', RestrulesTab(j).currency_code);
                            FND_MSG_PUB.Add;

                            -- Call Update_Charge_Lines.
                            Update_Charge_Lines(ChgSrTotTAB(k).incident_id,
                                                ChgSrTotTAB(k).incident_number,
                                                NULL,
                                                RestrulesTab(j).currency_code,
                                                'CS_CHG_TOTAL_CHRG_RESTRICTION',
                                                'N',
                                                'HEADER',
                                                x_return_status,
                                                x_msg_data);

                             l_restriction_qualify_flag := 'Y';

                       end if;

                      ELSIF RestrulesTab(j).condition = '=' then
                       if chgSrTotTAB(k).Total_Charges = RestrulesTab(j).value_amount and
                          chgSrTotTAB(k).currency_code =  RestrulesTab(j).currency_code and
                         ((chgSrTotTab(k).incident_date >= RestrulesTab(j).start_date_active
                         or RestrulesTab(j).start_date_active IS NULL) and
                         (chgSrTotTab(k).incident_date <= RestrulesTab(j).end_date_active
                         or RestrulesTab(j).end_date_active IS NULL)) then


                            FND_MSG_PUB.Initialize;
			    FND_MESSAGE.SET_NAME('CS', 'CS_CHG_TOTAL_CHRG_RESTRICTION');
                            FND_MESSAGE.SET_TOKEN('CURRENCY_CODE',chgSrTotTAB(k).currency_code);
                            FND_MESSAGE.SET_TOKEN('TOTAL_AMOUNT',chgSrTotTAB(k).Total_Charges);
                            FND_MESSAGE.SET_TOKEN('INCIDENT_NUMBER', chgSrTotTAB(k).incident_number);
                            FND_MESSAGE.SET_TOKEN('RESTRICTION_TYPE', RestrulesTab(j).restriction_type);
                            FND_MESSAGE.SET_TOKEN('CONDITION', RestrulesTab(j).condition);
                            FND_MESSAGE.SET_TOKEN('VALUE_AMOUNT', RestrulesTab(j).value_amount);
                            FND_MESSAGE.SET_TOKEN('CURRENCY', RestrulesTab(j).currency_code);
                            FND_MSG_PUB.Add;


                            -- Call Update_Charge_Lines.
                            Update_Charge_Lines(ChgSrTotTAB(k).incident_id,
                                                ChgSrTotTAB(k).incident_number,
                                                NULL,
                                                RestrulesTab(j).currency_code,
                                                'CS_CHG_TOTAL_CHRG_RESTRICTION',
                                                'N',
                                                'HEADER',
                                                x_return_status,
                                                x_msg_data);

                             l_restriction_qualify_flag := 'Y';


                       end if;

                    ELSIF RestrulesTab(j).condition = '<' then
                       if chgSrTotTAB(k).Total_Charges < RestrulesTab(j).value_amount and
                          chgSrTotTAB(k).currency_code =  RestrulesTab(j).currency_code and
                         ((chgSrTotTab(k).incident_date >= RestrulesTab(j).start_date_active
                         or RestrulesTab(j).start_date_active IS NULL) and
                         (chgSrTotTab(k).incident_date <= RestrulesTab(j).end_date_active
                         or RestrulesTab(j).end_date_active IS NULL)) then


                            FND_MSG_PUB.Initialize;
                            FND_MESSAGE.SET_NAME('CS', 'CS_CHG_TOTAL_CHRG_RESTRICTION');
                            FND_MESSAGE.SET_TOKEN('CURRENCY_CODE',chgSrTotTAB(k).currency_code);
                            FND_MESSAGE.SET_TOKEN('TOTAL_AMOUNT',chgSrTotTAB(k).Total_Charges);
                            FND_MESSAGE.SET_TOKEN('INCIDENT_NUMBER', chgSrTotTAB(k).incident_number);
                            FND_MESSAGE.SET_TOKEN('RESTRICTION_TYPE', RestrulesTab(j).restriction_type);
                            FND_MESSAGE.SET_TOKEN('CONDITION', RestrulesTab(j).condition);
                            FND_MESSAGE.SET_TOKEN('VALUE_AMOUNT', RestrulesTab(j).value_amount);
                            FND_MESSAGE.SET_TOKEN('CURRENCY', RestrulesTab(j).currency_code);
                            FND_MSG_PUB.Add;


                              -- Call Update_Charge_Lines.
                              Update_Charge_Lines(ChgSrTotTAB(k).incident_id,
                                                  ChgSrTotTAB(k).incident_number,
                                                  NULL,
                                                  RestrulesTab(j).currency_code,
                                                  'CS_CHG_TOTAL_CHRG_RESTRICTION',
                                                  'N',
                                                  'HEADER',
                                                  x_return_status,
                                                  x_msg_data);


                            l_restriction_qualify_flag := 'Y';

                       end if;

                   ELSIF RestrulesTab(j).condition = '<=' then
                       if chgSrTotTAB(k).Total_Charges <= RestrulesTab(j).value_amount and
                          chgSrTotTAB(k).currency_code =  RestrulesTab(j).currency_code and
                          ((chgSrTotTab(k).incident_date >= RestrulesTab(j).start_date_active
                         or RestrulesTab(j).start_date_active IS NULL) and
                         (chgSrTotTab(k).incident_date <= RestrulesTab(j).end_date_active
                         or RestrulesTab(j).end_date_active IS NULL)) then



                            FND_MSG_PUB.Initialize;
			    FND_MESSAGE.SET_NAME('CS', 'CS_CHG_TOTAL_CHRG_RESTRICTION');
                            FND_MESSAGE.SET_TOKEN('CURRENCY_CODE',chgSrTotTAB(k).currency_code);
                            FND_MESSAGE.SET_TOKEN('TOTAL_AMOUNT',chgSrTotTAB(k).Total_Charges);
                            FND_MESSAGE.SET_TOKEN('INCIDENT_NUMBER', chgSrTotTAB(k).incident_number);
                            FND_MESSAGE.SET_TOKEN('RESTRICTION_TYPE', RestrulesTab(j).restriction_type);
                            FND_MESSAGE.SET_TOKEN('CONDITION', RestrulesTab(j).condition);
                            FND_MESSAGE.SET_TOKEN('VALUE_AMOUNT', RestrulesTab(j).value_amount);
                            FND_MESSAGE.SET_TOKEN('CURRENCY', RestrulesTab(j).currency_code);
                            FND_MSG_PUB.Add;


                            -- Call Update_Charge_Lines.
                            Update_Charge_Lines(ChgSrTotTAB(k).incident_id,
                                                ChgSrTotTAB(k).incident_number,
                                                NULL,
                                                RestrulesTab(j).currency_code,
                                                'CS_CHG_TOTAL_CHRG_RESTRICTION',
                                                'N',
                                                'HEADER',
                                                x_return_status,
                                                x_msg_data);


                          l_restriction_qualify_flag := 'Y';


                       end if;

                  ELSIF RestrulesTab(j).condition = '>=' then
                       if chgSrTotTAB(k).Total_Charges >= RestrulesTab(j).value_amount and
                          chgSrTotTAB(k).currency_code =  RestrulesTab(j).currency_code and
                          ((chgSrTotTab(k).incident_date >= RestrulesTab(j).start_date_active
                         or RestrulesTab(j).start_date_active IS NULL) and
                         (chgSrTotTab(k).incident_date <= RestrulesTab(j).end_date_active
                         or RestrulesTab(j).end_date_active IS NULL)) then


                            FND_MSG_PUB.Initialize;
                            FND_MESSAGE.SET_NAME('CS', 'CS_CHG_TOTAL_CHRG_RESTRICTION');
                            FND_MESSAGE.SET_TOKEN('CURRENCY_CODE',chgSrTotTAB(k).currency_code);
                            FND_MESSAGE.SET_TOKEN('TOTAL_AMOUNT',chgSrTotTAB(k).Total_Charges);
                            FND_MESSAGE.SET_TOKEN('INCIDENT_NUMBER', chgSrTotTAB(k).incident_number);
                            FND_MESSAGE.SET_TOKEN('RESTRICTION_TYPE', RestrulesTab(j).restriction_type);
                            FND_MESSAGE.SET_TOKEN('CONDITION', RestrulesTab(j).condition);
                            FND_MESSAGE.SET_TOKEN('VALUE_AMOUNT', RestrulesTab(j).value_amount);
                            FND_MESSAGE.SET_TOKEN('CURRENCY', RestrulesTab(j).currency_code);
                            FND_MSG_PUB.Add;

                            -- Call Update_Charge_Lines.
                            Update_Charge_Lines(ChgSrTotTAB(k).incident_id,
                                                ChgSrTotTAB(k).incident_number,
                                                NULL,
                                                RestrulesTab(j).currency_code,
                                                'CS_CHG_TOTAL_CHRG_RESTRICTION',
                                                'N',
                                                'HEADER',
                                                x_return_status,
                                                x_msg_data);


                         l_restriction_qualify_flag := 'Y';

                       end if;
                    END IF; --Endif for TOTAL_SERVICE_REQUEST_CHARGES condition.
                END IF;  -- Endif for total_service_request.

            IF RestrulesTab(j).restriction_type = 'SERVICE_REQUEST_TYPE' THEN
                      if RestrulesTab(j).value_object_id = chgSrTotTab(k).incident_type_id and
                         ((chgSrTotTab(k).incident_date >= RestrulesTab(j).start_date_active
                         or RestrulesTab(j).start_date_active IS NULL) and
                         (chgSrTotTab(k).incident_date <= RestrulesTab(j).end_date_active
                         or RestrulesTab(j).end_date_active IS NULL)) then



                            FND_MSG_PUB.Initialize;
                            FND_MESSAGE.SET_NAME('CS', 'CS_CHG_SR_TYPE_RESTRICTION');
                            -- Need to verify, if we need to show status in the message.
                            -- FND_MESSAGE.SET_TOKEN('STATUS',chgSrTotTAB(k).currency_code, TRUE);
                            FND_MESSAGE.SET_TOKEN('RESTRICTION_TYPE', RestrulesTab(j).restriction_type);
                            FND_MESSAGE.SET_TOKEN('CONDITION', RestrulesTab(j).condition);
                            FND_MESSAGE.SET_TOKEN('INCIDENT_TYPE', chgSrTotTAB(k).incident_type);
                            FND_MSG_PUB.Add;


                            -- Call Update_Charge_Lines.
                            Update_Charge_Lines(ChgSrTotTAB(k).incident_id,
                                                ChgSrTotTAB(k).incident_number,
                                                NULL,
                                                RestrulesTab(j).currency_code,
                                                'CS_CHG_SR_TYPE_RESTRICTION',
                                                'N',
                                                'HEADER',
                                                x_return_status,
                                                x_msg_data);

                           l_restriction_qualify_flag := 'Y';


                     end if;
            END IF;  -- Restrictions EndIf.


             EXIT WHEN j = RestrulesTab.LAST;
             j := RestrulesTab.NEXT(j);


             END LOOP;  -- Restrictions EndLoop.

          END LOOP;  --Total Sr EndLoop.
          CLOSE Cs_Chg_Sr_Total;

	   --
           -- 'Actuals Exceed Estimates restriction Type'.
           j := RestrulesTab.FIRST;
           LOOP


             IF RestrulesTab(j).restriction_type = ('ACTUALS_EXCEED_ESTIMATES') THEN
                    --
                    -- Get the Actual and Estimate Value for the SR.
		     -- bug fix:3542151
                     n := 0;
                     OPEN Cs_Chg_Est_Act_Tot(l_incident_id);
                     n := n + 1;
                     LOOP
                     FETCH Cs_Chg_Est_Act_Tot
		     INTO  ChgEstActTotTAB(n);
                     EXIT WHEN Cs_Chg_Est_Act_Tot%NOTFOUND;
		     END LOOP;
                     CLOSE Cs_Chg_Est_Act_Tot;

                     n := ChgEstActTotTAB.FIRST;
		    LOOP

                        IF ChgEstActTotTAB.EXISTS(n) THEN
                          IF ChgEstActTotTAB(n).Estimates IS NOT NULL and
                             ChgEstActTotTAB(n).Actuals IS NOT NULL THEN

                          l_Actual_Percent := ((ChgEstActTotTAB(n).Actuals - ChgEstActTotTAB(n).Estimates)/ChgEstActTotTAB(n).Actuals)*100;

                        IF RestrulesTab(j).condition = '>' then
                           if l_Actual_Percent > RestrulesTab(j).value_amount and
                            ((ChgEstActTotTAB(n).incident_date >= RestrulesTab(j).start_date_active
                              or RestrulesTab(j).start_date_active IS NULL) and
                            (ChgEstActTotTAB(n).incident_date <= RestrulesTab(j).end_date_active
                              or RestrulesTab(j).end_date_active IS NULL)) then


                            FND_MSG_PUB.Initialize;
                            FND_MESSAGE.SET_NAME('CS','CS_CHG_A_EXCEED_ET_RESTRICTION');
                            FND_MESSAGE.SET_TOKEN('ACTUALS',ChgEstActTotTAB(n).Actuals);
                            FND_MESSAGE.SET_TOKEN('ESTIMATES',ChgEstActTotTAB(n).Estimates);
                            FND_MESSAGE.SET_TOKEN('INCIDENT_NUMBER', ChgEstActTotTAB(n).incident_number);
                            FND_MESSAGE.SET_TOKEN('CURRENCY_CODE', ChgEstActTotTAB(n).currency_code);
                            FND_MESSAGE.SET_TOKEN('RESTRICTION_TYPE', RestrulesTab(j).restriction_type);
                            FND_MESSAGE.SET_TOKEN('CONDITION', RestrulesTab(j).condition);
                            FND_MESSAGE.SET_TOKEN('VALUE_AMOUNT', RestrulesTab(j).value_amount);
                            FND_MSG_PUB.Add;


                           -- Call Update_Charge_Lines.
                           Update_Charge_Lines(ChgEstActTotTAB(n).incident_id,
                                               ChgEstActTotTAB(n).incident_number,
                                               NULL,
					       ChgEstActTotTAB(n).currency_code,
                                              'CS_CHG_A_EXCEED_ET_RESTRICTION',
                                              'N',
                                              'HEADER',
                                              x_return_status,
                                              x_msg_data);

                           l_restriction_qualify_flag := 'Y';


			  end if;

                  END IF; -- End of Condition for Actuals_exceed_estimates
                 END IF;  -- actuals and estimates endif
              END IF;

              EXIT WHEN n = ChgEstActTotTAB.LAST;
              n := ChgEstActTotTAB.NEXT(n);
              END LOOP;

              END IF;  -- Restrictions end if.

             EXIT WHEN j = RestrulesTab.LAST;
             j := RestrulesTab.NEXT(j);
             END LOOP; -- Restrictions Loop


               -- dbms_output.put_line('Calling submit_charge_lines');
               -- dbms_output.put_line('restriction_flag' || l_restriction_qualify_flag);

               --
               IF l_restriction_qualify_flag = 'N' then
               -- Call submit order API here for an incident_id.
               Submit_Charge_Lines(p_incident_id   => l_incident_id,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data);
              END IF;

        END IF; -- End If check the incident_id value.


        /***********  END OF SR LEVEL RESTRICTIONS  *************/

     -- Need to reset the restriction_qualify_flag if SR number changes.
     --
     L := AutosubmitTAB.NEXT(i);
     IF L IS NULL THEN
     L := AutosubmitTAB.LAST;
     END IF;

     IF AutosubmitTAB(i).incident_id <> AutosubmitTAB(L).incident_id THEN
       -- Reset the restriction qualify flag
       l_restriction_qualify_flag := 'N';
     END IF;



 ELSIF rest_count = 0 then

	 -- dbms_output.put_line('Value of incident_id ' || AutosubmitTAB(i).incident_id);

               Submit_Charge_Lines(p_incident_id   => AutosubmitTAB(i).incident_id,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data);

         -- dbms_output.put_line('completed submission');

END IF;
--
--
EXIT WHEN i = AutosubmitTAB.LAST;
i := AutosubmitTAB.NEXT(i);
END LOOP;  --Cs_Chg_Auto_Submit_Lines End Loop



 EXCEPTION
WHEN OTHERS THEN
IF  l_found = 'N'  THEN
    FND_FILE.put_line(FND_FILE.LOG,'There are no eligible Charge lines available for submission to Order Management');
  ELSE
     x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('CS', 'CS_DB_ERROR');
     FND_MESSAGE.SET_TOKEN(token => 'PROG_NAME', value => 'CS_Chg_Auto_Sub_CON_PKG.Auto_submit_charge_Lines');
     FND_MESSAGE.SET_TOKEN(token => 'SQLCODE', value => SQLCODE);
     FND_MESSAGE.SET_TOKEN(token => 'SQLERRM', value => SQLERRM);
     FND_MSG_PUB.add;
     FND_MSG_PUB.get(p_encoded  => 'F',
                     p_data=>x_msg_data,
                     p_msg_index_out=> l_msg_index_out);

     -- Recording exceptions in the log file.
     FND_FILE.put_line(FND_FILE.LOG,x_msg_data);
END IF;

END Auto_Submit_Chg_Lines;
--
--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   Procedure Name:  Update_Charge_Lines
--   Type    :  Private
--   Purpose :  This procedure is for updating charge lines with appropriate
--              restriction message.
--   Pre-Req :
--   Parameters:
--   IN :
--       p_incident_id           IN      NUMBER
--       p_estimate_detail_id    IN      NUMBER
--       p_currency_code         IN      VARCHAR2
--       p_restriction_message   IN      VARCHAR2
--       p_line_submitted        IN      VARCHAR2
--       p_restriction_type      IN      VARCHAR2
--       x_return_status	 OUT     VARCHAR2
--	 x_msg_data	  	 OUT     VARCHAR2
--   ***************************************************************************************
--   1  | SSHILPAM   | Bug 5697830: Default the line_submitted to 'N' only for the corresponding line
--	|	     | and not to all the lines under the service request.
--   2  | GASANKAR   |  Bug Fix 7692111 : Added the condition AND   ced.order_line_id IS NULL
--                         in autosubmit_cv cursors.
--   ****************************************************************************************

PROCEDURE  Update_Charge_Lines(p_incident_id        NUMBER,
                               p_incident_number    VARCHAR2,
                               p_estimate_detail_id  NUMBER,
                               p_currency_code       VARCHAR2,
                               p_submit_restriction_message  VARCHAR2,
                               p_line_submitted     VARCHAR2,
                               p_restriction_type   VARCHAR2,
                               x_return_status    OUT NOCOPY VARCHAR2,
			       x_msg_data	  OUT NOCOPY VARCHAR2
                               ) IS

-- Number of Charge Lines
-- Only actual charge lines are stamped with the restriction message
-- Bug fix:3608980
   CURSOR Charge_Line_Count(p_incident_id NUMBER,p_currency_code VARCHAR2) IS
   SELECT estimate_detail_id
   FROM   cs_estimate_details
   WHERE  incident_id = p_incident_id
   AND    charge_line_type = 'ACTUAL'
   AND    source_code = 'SD'
   AND    original_source_code = 'SR'
   AND    currency_code = nvl(p_currency_code,currency_code)
   AND    line_submitted = 'N'
   AND    order_line_id IS NULL ; --bug 7692111


   TYPE t_charge_count_tab IS TABLE OF Charge_Line_Count%rowtype
   INDEX BY BINARY_INTEGER;

   chglnctTAB     t_charge_count_tab;

   lx_msg_data  VARCHAR2(2000);
   t  NUMBER :=0;
   l_msg_index_out  NUMBER;

BEGIN
          x_return_status := FND_API.G_RET_STS_SUCCESS;

          IF p_submit_restriction_message IS NOT NULL THEN

            FND_MSG_PUB.get(p_encoded  => 'F',
                            p_data=>lx_msg_data,
                            p_msg_index_out=> l_msg_index_out);

            -- Recording the message for concurrent program output.
            FND_FILE.PUT_LINE(FND_FILE.output,'Service Request Number:' || p_incident_number);
            FND_FILE.PUT_LINE(FND_FILE.output, lx_msg_data);


             IF p_restriction_type = 'LINE' THEN

                UPDATE CS_ESTIMATE_DETAILS
                SET  submit_restriction_message = (submit_restriction_message || lx_msg_data),
                     line_submitted = p_line_submitted,
		     last_update_date = sysdate, -- bug 8838622
		     last_update_login = fnd_global.login_id, -- bug 8838622
		     last_updated_by = fnd_global.user_id -- bug 8838622
                WHERE Estimate_Detail_Id = p_estimate_detail_id
                AND  incident_id = p_incident_id;


            ELSIF p_restriction_type  = 'HEADER'  THEN

               OPEN Charge_Line_Count(p_incident_id,p_currency_code);
               LOOP
                t := t +1;

                  FETCH Charge_Line_Count
                  INTO  chglnctTAB(t);
                  EXIT WHEN Charge_Line_Count%NOTFOUND;


                  UPDATE CS_ESTIMATE_DETAILS
                  SET   submit_restriction_message = (submit_restriction_message || lx_msg_data),
                        line_submitted = p_line_submitted,
			last_update_date = sysdate, -- bug 8838622
		        last_update_login = fnd_global.login_id, -- bug 8838622
		        last_updated_by = fnd_global.user_id -- bug 8838622
                  WHERE  incident_id = p_incident_id
                  AND    estimate_detail_id = chglnctTAB(t).estimate_detail_id;

               END LOOP;
               CLOSE Charge_Line_Count;

             END IF;  --restriction_type.

       ELSIF p_submit_restriction_message IS NULL THEN

             IF p_restriction_type  = 'CLEAR'  THEN
                OPEN Charge_Line_Count(p_incident_id,p_currency_code);
                   LOOP
                       t := t +1;

                       FETCH Charge_Line_Count
                       INTO  chglnctTAB(t);
                       EXIT WHEN Charge_Line_Count%NOTFOUND;

                       UPDATE CS_ESTIMATE_DETAILS
                       SET   submit_restriction_message = NULL,
                             line_submitted = p_line_submitted,
			     last_update_date = sysdate, -- bug 8838622
		             last_update_login = fnd_global.login_id, -- bug 8838622
			     last_updated_by = fnd_global.user_id -- bug 8838622
                      WHERE  incident_id = p_incident_id
		      AND    estimate_detail_id = chglnctTAB(t).estimate_detail_id;  -- For bug 5697830

		  COMMIT;
                  END LOOP;
               CLOSE Charge_Line_Count;
            END IF; -- restriction_type.
      END IF; -- submit_error_message.

COMMIT;

EXCEPTION
 WHEN OTHERS THEN
     x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
     -- ROLLBACK TO CS_Chg_Auto_Submission_PVT;
     FND_MESSAGE.SET_NAME('CS', 'CS_DB_ERROR');
     FND_MESSAGE.SET_TOKEN(token => 'PROG_NAME', value => 'CS_Chg_Auto_Sub_CON_PKG.Update_Charge_Lines');
     FND_MESSAGE.SET_TOKEN(token => 'SQLCODE', value => SQLCODE);
     FND_MESSAGE.SET_TOKEN(token => 'SQLERRM', value => SQLERRM);
     FND_MSG_PUB.add;
     FND_MSG_PUB.get(p_encoded  => 'F',
                     p_data=>x_msg_data,
                     p_msg_index_out=> l_msg_index_out);

     -- Recording exceptions in the log file.
     FND_FILE.put_line(FND_FILE.LOG,x_msg_data);


END Update_Charge_Lines;

--  Procedure Submit_Charge_Lines.
--   Parameters:
--       p_incident_id           IN      NUMBER     Required
--   OUT:
--       x_return_status         OUT    NOCOPY     VARCHAR2
--       x_msg_count             OUT    NOCOPY     NUMBER
--       x_msg_data              OUT    NOCOPY     VARCHAR2
--
PROCEDURE Submit_Charge_Lines(p_incident_id      IN  NUMBER,
                              x_return_status    OUT NOCOPY VARCHAR2,
                              x_msg_count        OUT NOCOPY NUMBER,
                              x_msg_data         OUT NOCOPY VARCHAR2) IS

CURSOR SR_VAL(p_incident_id number) IS
select inc.customer_id,inc.account_id,inc.incident_number
from   cs_incidents_all_b inc
where  inc.incident_id = p_incident_id;

l_account_id  NUMBER;
l_party_id    NUMBER;
l_incident_number VARCHAR2(30);
l_msg_index_out NUMBER;

BEGIN

IF p_incident_id IS NOT NULL THEN

OPEN SR_VAL(p_incident_id);
FETCH SR_VAL
INTO  l_party_id,l_account_id,l_incident_number;
CLOSE SR_VAL;

END IF;


    -- Recording the message for concurrent program output.
    FND_FILE.PUT_LINE(FND_FILE.output,'Service Request Number:' || l_incident_number);
    --
   -- dbms_output.put_line('Calling submit_order');

  CS_Charge_Create_Order_PUB.Submit_Order(
                 p_api_version           =>  1.0,
                 p_init_msg_list         =>  'T',
                 p_commit                =>  'T',
                 p_validation_level      =>  NULL,
                 p_incident_id           =>  p_incident_id,
                 p_party_id              =>  l_party_id,
                 p_account_id            =>  l_account_id,
                 p_book_order_flag       =>  NULL,
                 p_submit_source         =>  'FS',
                 p_submit_from_system    =>  'AUTO_SUBMISSION',
                 x_return_status         =>  x_return_status,
                 x_msg_count             =>  x_msg_count,
                 x_msg_data              =>  x_msg_data);



IF x_return_status <> 'S' THEN
      IF (FND_MSG_PUB.Count_Msg > 0) THEN
         FOR i in 1..FND_MSG_PUB.Count_Msg
            LOOP
               FND_MSG_PUB.Get(p_msg_index => i,
                               p_encoded => 'F',
                               p_data => x_msg_data,
                               p_msg_index_out => l_msg_index_out );

               -- logging messages returned by the submit order API.
               fnd_file.put_line(FND_FILE.OUTPUT,x_msg_data);

            END LOOP;
         END IF;
END IF;
--
-- This is added to change the restriction flag value after the SR has been processed.
--
-- l_restriction_flag := ' ';


EXCEPTION
WHEN OTHERS THEN
     x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
     -- ROLLBACK TO CS_Chg_Auto_Submission_PVT;
     FND_MESSAGE.SET_NAME('CS', 'CS_DB_ERROR');
     FND_MESSAGE.SET_TOKEN(token => 'PROG_NAME', value => 'CS_Chg_Auto_Sub_CON_PKG.Update_Charge_Lines');
     FND_MESSAGE.SET_TOKEN(token => 'SQLCODE', value => SQLCODE);
     FND_MESSAGE.SET_TOKEN(token => 'SQLERRM', value => SQLERRM);
     FND_MSG_PUB.add;
     FND_MSG_PUB.get(p_encoded  => 'F',
                     p_data=>x_msg_data,
                     p_msg_index_out=> l_msg_index_out);

     -- Recording exceptions in the log file.
     FND_FILE.put_line(FND_FILE.LOG,x_msg_data);

END Submit_Charge_Lines;



-- new enh for simplex


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   Procedure Name:  Check_Debrief_Status
--   Type    :  Private
--   Purpose :  This procedure is to verify the debrief status before submitting to OM
--   Pre-Req :
--   Parameters:
--   IN :
--       p_incident_id           IN      NUMBER
--       p_estimate_detail_id    IN      NUMBER
--       p_currency_code         IN      VARCHAR2
--       p_incident_number       IN      VARCHAR2
--       x_return_status         OUT     VARCHAR2
--       x_msg_data              OUT     VARCHAR2


PROCEDURE  Check_Debrief_Status(p_incident_id         NUMBER,
                                p_incident_number     VARCHAR2,
                                p_estimate_detail_id  NUMBER,
                                p_currency_code       VARCHAR2,
                                x_restriction_qualify_flag OUT NOCOPY VARCHAR2,
                                x_return_status       OUT NOCOPY VARCHAR2,
                                x_msg_data            OUT NOCOPY VARCHAR2
                                ) IS



l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(4000);
lx_msg_index_out number;
l_deb_status CSF_DEBRIEF_UPDATE_PKG.debrief_status_tbl_type;
l_count_db NUMBER;
l_count_ui NUMBER;
lv_index BINARY_INTEGER;
l_debrief_status VARCHAR2(1);
conc_status BOOLEAN;
l_msg_index_out        NUMBER;
lx_msg_count NUMBER;


BEGIN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*********************************');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'verifying debrief status ..');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*********************************');


      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_restriction_qualify_flag := 'N';

      csf_debrief_update_pkg.debrief_status_check(
                         p_incident_id      => p_incident_id,
                         p_api_version      => 1.0,
                         p_validation_level => 0,
                         x_debrief_status   => l_deb_status,
                         x_return_status    => x_return_status,
                         x_msg_count        => l_msg_count,
                         x_msg_data         => l_msg_data );



        IF      x_return_status = 'E' THEN

      	IF 	l_deb_status.COUNT > 0 THEN
        	lv_index := l_deb_status.FIRST;
         	FOR lv_temp IN 1..l_deb_status.COUNT LOOP

         	  IF 	    l_deb_status(lv_index).debrief_status = 'P' THEN

                            FND_MSG_PUB.Initialize;
                            FND_MESSAGE.SET_NAME( 'CS','CS_CHG_DEBRIEF_PENDING');
                            FND_MSG_PUB.Add;

       		            FND_MSG_PUB.get(p_encoded  => 'F',
                     		            p_data=>l_msg_data,
                     		            p_msg_index_out=> l_msg_index_out);

                FND_FILE.put_line(FND_FILE.LOG,'Service Request Number:' || p_incident_number);
                FND_FILE.put_line(FND_FILE.LOG,'Estimate Detail ID:' || p_estimate_detail_id);
                FND_FILE.put_line(FND_FILE.LOG,l_msg_data);
                conc_status := fnd_concurrent.set_completion_status('WARNING','Warning');

                                Update_Charge_Lines(p_incident_id,
                                   	            p_incident_number,
                                                    p_estimate_detail_id,
                                                    p_currency_code,
                                                    'CS_CHG_DEBRIEF_PENDING',
                                                    'N',
                                                    'HEADER',
                                                    x_return_status,
                                                    x_msg_data);

                x_restriction_qualify_flag := 'Y';


               	ELSIF  	        l_deb_status(lv_index).debrief_status = 'E' THEN
                                FND_MSG_PUB.Initialize;
                                FND_MESSAGE.SET_NAME( 'CS','CS_CHG_DEBRIEF_ERRORS');
                                FND_MSG_PUB.Add;
             		        FND_MSG_PUB.get(p_encoded  => 'F',
                     	        	        p_data=>l_msg_data,
                     	  		        p_msg_index_out=> l_msg_index_out);

                FND_FILE.put_line(FND_FILE.LOG,'Service Request Number:' || p_incident_number);
                FND_FILE.put_line(FND_FILE.LOG,'Estimate Detail ID:' || p_estimate_detail_id);
                FND_FILE.put_line(FND_FILE.LOG,l_msg_data);
	        conc_status := fnd_concurrent.set_completion_status('WARNING','Warning');


                       		Update_Charge_Lines(p_incident_id,
                                                p_incident_number,
                                                p_estimate_detail_id,
                                                p_currency_code,
                                                'CS_CHG_DEBRIEF_ERRORS',
                                                'N',
                                                'HEADER',
                                                x_return_status,
                                                x_msg_data);
                x_restriction_qualify_flag := 'Y';

                    ELSE
                         NULL;   -- neither E or P
                         END IF;   --for E or P status


           EXIT WHEN lv_index = l_deb_status.LAST ;
           lv_index := l_deb_status.NEXT(lv_index);
           END LOOP;
	   ELSE

             null;  --If count is zero, no records.
           END IF;
       ELSIF  x_return_status = 'U' THEN
            IF (FND_MSG_PUB.Count_Msg > 0) THEN
                FOR i in 1..FND_MSG_PUB.Count_Msg
            LOOP
               FND_MSG_PUB.Get(p_msg_index => i,
                               p_encoded => 'F',
                               p_data => x_msg_data,
                               p_msg_index_out => l_msg_index_out );

               -- logging messages returned by the submit order API.
               fnd_file.put_line(FND_FILE.OUTPUT,x_msg_data);

            END LOOP;
            END IF;


 END IF;  --for return status. we will do nothing if return_status is other than E or U.

           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*********************************');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Exiting Debrief_Status_Check');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*********************************');

EXCEPTION
 WHEN OTHERS THEN
     x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
     -- ROLLBACK TO CS_Chg_Auto_Submission_PVT;
     FND_MESSAGE.SET_NAME('CS', 'CS_DB_ERROR');
     FND_MESSAGE.SET_TOKEN(token => 'PROG_NAME', value => 'CS_Chg_Auto_Sub_CON_PKG.Check_Debrief_Status');
     FND_MESSAGE.SET_TOKEN(token => 'SQLCODE', value => SQLCODE);
     FND_MESSAGE.SET_TOKEN(token => 'SQLERRM', value => SQLERRM);
     FND_MSG_PUB.add;
     FND_MSG_PUB.get(p_encoded  => 'F',
                     p_data=>x_msg_data,
                     p_msg_index_out=> l_msg_index_out);

     -- Recording exceptions in the log file.
     FND_FILE.put_line(FND_FILE.LOG,x_msg_data);


END Check_Debrief_Status;

-- end of new procedure for new enh for simplex






END CS_Chg_Auto_Sub_CON_PKG;

/
