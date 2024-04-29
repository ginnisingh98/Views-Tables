--------------------------------------------------------
--  DDL for Package Body IEX_CALL_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_CALL_HISTORY" 
/* $Header: iexhiclb.pls 120.0 2004/01/24 03:18:48 appldev noship $ */
AS
	---------------------------------------------------------------------
	--				Forward Declarations - Call History
	---------------------------------------------------------------------
    PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

Procedure Get_Activity_Status
		(p_Interaction_id  IN	Number,
		 p_doc_ref	    IN	Varchar2,
		 p_Activity_Exists OUT NOCOPY	Varchar2)  ;

	---------------------------------------------------------------------
	--		  Forward Declarations - Call History Activities
	---------------------------------------------------------------------

	Procedure Get_Action_Description
		(p_Action_id 	IN	Number,
		 p_Action_Desc OUT NOCOPY JTF_IH_ACTIONS_VL.Short_Description%TYPE) ;

	Procedure Get_OUTCOME_Description
		(p_Outcome_Id 	IN	Number,
		 p_Outcome_Desc OUT NOCOPY JTF_IH_OUTCOMES_VL.Short_Description%TYPE)  ;

	Procedure Get_REASON_Description
		(p_REASON_id 	IN	Number,
		 p_REASON_Desc OUT NOCOPY JTF_IH_REASONS_VL.Short_Description%TYPE)  ;

	Procedure Get_result_description
		(p_result_id 	IN	Number,
		 p_result_Desc OUT NOCOPY JTF_IH_RESULTS_VL.Short_Description%TYPE)  ;

	Procedure Get_Object_Name
		(p_doc_ref 	IN	Varchar2,
		 p_object_name OUT NOCOPY JTF_OBJECTS_VL.name%TYPE)  ;
	---------------------------------------------------------------------
	--				   QUERY_INTERACTION_RECORDS
	---------------------------------------------------------------------
	-- Queries and returns history records for the passed date range
	-- Called from the form block.
	---------------------------------------------------------------------
	PROCEDURE QUERY_INTERACTION_RECORDS (
		p_mode          IN      Varchar2,
    		p_id		        IN 	    Number		,
		P_From_Date		  IN      Date			,
		P_To_Date   		IN      Date			,
		p_Interaction_tbl  	IN OUT NOCOPY  	Interaction_Tbl,
		p_error_code		IN OUT NOCOPY	Varchar2		,
		p_error_mesg		IN OUT NOCOPY	Varchar2	)
    IS
		    l_cnt Number	;
		    v_interaction_cur Interaction_cursor 		;
		    v_interaction_sql Varchar2(1000) 			;
		    v_activity_status Varchar2(1000)			;
		    v_interaction_id  JTF_IH_INTERACTIONS.Interaction_Id%TYPE  ;

		    CURSOR  Interaction_party_cur
            	(p_party_id Number,
             	p_from_date Date,
			p_to_date Date)
        	    IS
		    Select 	 JIIN.interaction_id			,
				         JIIN.start_date_time		,
					       JREV.resource_name
		    From		 JTF_IH_INTERACTIONS		JIIN	,
					       JTF_RS_RESOURCE_EXTNS_VL	JREV
		    where 	 JIIN.party_id = p_party_id
		    AND 		 JIIN.start_date_time
						     BETWEEN p_from_date and (p_to_date + 1)
		    AND		   JIIN.Resource_Id = JREV.resource_id
		    ORDER BY JIIN.start_date_time DESC ;

		    CURSOR   Interaction_cust_cur
                 (p_cust_account_id Number,
                  p_from_date Date,
			p_to_date Date)
        	    IS
        		Select JIIN.interaction_id		,
				JIIN.start_date_time		,
				JREV.resource_name
		    From	JTF_IH_INTERACTIONS		JIIN	,
				JTF_RS_RESOURCE_EXTNS_VL	JREV,
                 		JTF_IH_ACTIVITIES JIA
		    where 	 JIA.cust_account_id = p_cust_account_id
        		AND      JIA.Interaction_Id = JIIN.Interaction_Id
        		AND		   JIIN.Resource_Id = JREV.resource_id
		    	AND 	   JIIN.start_date_time
					     BETWEEN p_from_date and (p_to_date + 1)
		    ORDER BY JIIN.start_date_time DESC ;

	Begin

    if p_mode = 'PARTY' then
		    OPEN Interaction_party_cur(p_id, p_from_date, p_to_date) ;
		    FETCH Interaction_party_cur
        BULK COLLECT INTO
				      v_interaction_id_tbl,
              v_start_date_time_tbl,
				      v_resource_name_tbl			;

		    close Interaction_party_cur ;
    elsif p_mode = 'CUST' then
		    OPEN Interaction_cust_cur(p_id, p_from_date, p_to_date) ;
		    FETCH Interaction_cust_cur
        BULK COLLECT INTO
				      v_interaction_id_tbl,
              v_start_date_time_tbl,
				      v_resource_name_tbl			;

		    close Interaction_cust_cur ;
    End IF ;



		FOR l_cnt IN 1..v_interaction_id_tbl.count LOOP

			p_Interaction_tbl(l_cnt).Interaction_id
						:= v_Interaction_id_tbl(l_cnt);

		     v_interaction_id    := v_Interaction_id_tbl(l_cnt) ;

			p_Interaction_tbl(l_cnt).Start_Date
			    := To_Char(v_start_date_time_tbl(l_cnt),'DD-MON-YYYY') ;
			p_Interaction_tbl(l_cnt).Start_Time
				:= To_char(v_start_date_time_tbl(l_cnt), 'HH:MM:SS') ;

			p_Interaction_tbl(l_cnt).resource_name
				:= v_resource_name_tbl(l_cnt);

			-- Dispute Activity Status
			get_Activity_status(v_interaction_id, 'IEX_DISPUTE',
										v_activity_status) ;
			If v_activity_status NOT IN ('Yes', 'No') then
			    p_Interaction_tbl(l_cnt).Disputed := 'ERROR' ;
			Else
			    p_Interaction_tbl(l_cnt).Disputed := v_activity_status ;
			End If ;

			-- Payment Activity Status
			get_Activity_status(v_interaction_id, 'IEX_PAYMENT',
										v_activity_status) ;
			If v_activity_status NOT IN ('Yes', 'No') then
			    p_Interaction_tbl(l_cnt).Paid := 'ERROR' ;
			Else
			    p_Interaction_tbl(l_cnt).Paid := v_activity_status ;
			End If ;

			-- Correspondence Activity Status
			get_Activity_status(v_interaction_id, 'IEX_DUNNING',
										v_activity_status) ;
			If v_activity_status NOT IN ('Yes', 'No') then
			    p_Interaction_tbl(l_cnt).Correspondence_Sent := 'ERROR' ;
			Else
			    p_Interaction_tbl(l_cnt).Correspondence_Sent
									:= v_activity_status ;
			End If ;

			-- Promise_to_pay Activity Status
			get_Activity_status(v_interaction_id, 'IEX_PROMISE', v_activity_status) ;
			If v_activity_status NOT IN ('Yes', 'No') then
			    p_Interaction_tbl(l_cnt).Promise_to_pay := 'ERROR' ;
			Else
			    p_Interaction_tbl(l_cnt).Promise_to_pay
										:= v_activity_status ;
		    End If ;
		END LOOP ;

	Exception
		WHEN OTHERS THEN
			p_error_code := SQLCODE ;
			p_error_mesg := SQLERRM ;

	End ;
	---------------------------------------------------------------------
	--			PROCEDURE QUERY_ACTIVITY_RECORDS
	---------------------------------------------------------------------
	-- Queries activity records for the passed interaction_id from
	-- JTF_IH_ACTIVITIES table. This returns a table of records which is
	-- used as the source for detail block in the call history form.
	---------------------------------------------------------------------
	PROCEDURE QUERY_ACTIVITY_RECORDS
				(P_Interaction_id 	    		IN OUT NOCOPY	Number ,
				 p_Interaction_Activity_tbl  	IN OUT NOCOPY
								    Interaction_Activity_Tbl,
				 p_error_code     	    		IN OUT NOCOPY  	Varchar2,
				 p_error_mesg            	IN OUT NOCOPY  	Varchar2)
	IS
		l_cnt Number	:= 1 ;
		v_activity_cur Interaction_Activity_cursor 	;
		v_activity_sql	Varchar2(1000) 			;
		v_activity_rec Activity_Select_Rec 	;
	Begin

	     v_activity_sql :=
		   'Select
				JIA.interaction_id	,
				JIA.activity_id	,
				JIA.action_id		,
				JIA.outcome_id		,
				JIA.reason_id		,
				JIA.result_id		,
				JIA.duration		,
				JIA.doc_id		,
				JIA.doc_ref		,
				JIA.object_id		,
				JIA.object_type	,
				JIA.source_code_id	,
				JIA.source_code
		    From	JTF_IH_ACTIVITIES 		JIA
		    Where JIA.Interaction_id = :interaction_id' ;

		OPEN v_activity_cur FOR v_activity_sql USING p_interaction_id ;

		LOOP
			FETCH v_activity_cur INTO v_activity_rec ;
			EXIT WHEN v_activity_cur%NOTFOUND ;

			p_interaction_activity_tbl(l_cnt).Interaction_id
							:= v_activity_rec.Interaction_id ;

			p_interaction_activity_tbl(l_cnt).Action_Id
							:= v_activity_rec.Action_Id ;
			If v_activity_rec.action_id is NOT NULL then
				Get_Action_Description(v_activity_rec.action_id	,
				   p_interaction_activity_tbl(l_cnt).Action_Description ) ;
			End If ;

			p_interaction_activity_tbl(l_cnt).Outcome_Id
							:= v_activity_rec.outcome_id ;
			If v_activity_rec.outcome_id is NOT NULL then
				Get_Outcome_Description (v_activity_rec.Outcome_id	,
				   p_interaction_activity_tbl(l_cnt).Outcome_Description ) ;
			End If ;

			p_interaction_activity_tbl(l_cnt).Reason_Id
							:= v_activity_rec.reason_id ;
			If v_activity_rec.Reason_id is NOT NULL then
				Get_Reason_Description(v_activity_rec.Reason_id 	,
				   p_interaction_activity_tbl(l_cnt).Reason_Description ) ;
			End If ;

			p_interaction_activity_tbl(l_cnt).Result_Id
							:= v_activity_rec.result_id ;
			If v_activity_rec.Result_id is NOT NULL then
				Get_Result_Description(v_activity_rec.Result_id	,
				    p_Interaction_activity_tbl(l_cnt).Result_Description ) ;
			End If ;

			p_interaction_activity_tbl(l_cnt).Duration
							:= v_activity_rec.Duration ;

			p_interaction_activity_tbl(l_cnt).doc_id
							:= v_activity_rec.doc_id ;

			p_interaction_activity_tbl(l_cnt).doc_ref
							:= v_activity_rec.doc_ref ;

			p_interaction_activity_tbl(l_cnt).object_id
							:= v_activity_rec.object_id ;

			p_interaction_activity_tbl(l_cnt).Object_type
							:= v_activity_rec.Object_type ;

			p_interaction_activity_tbl(l_cnt).Source_Code_Id
							:= v_activity_rec.Source_Code_Id ;

			p_interaction_activity_tbl(l_cnt).Source_Code_Type
							:= v_activity_rec.Source_Code_Type ;

		     -- Populate Object Name and Description
			If v_activity_Rec.doc_ref IS NOT NULL then
				get_object_name(v_activity_rec.doc_ref,
					p_interaction_activity_tbl(l_cnt).Object_Name) ;
			End IF ;


			l_cnt := l_cnt + 1 ;

	    END LOOP ;
	    CLOSE V_Activity_Cur ;
	Exception
		WHEN OTHERS THEN
			p_error_code := SQLCODE ;
	End ;
	---------------------------------------------------------------------
	--			GET_ACTIVITY_STATUS
	---------------------------------------------------------------------
	-- Takes Interaction_id and doc_Ref as parameters and returns the
	-- Activity Count
	---------------------------------------------------------------------
	Procedure Get_Activity_Status
		(p_Interaction_id  IN	Number,
		 p_doc_ref	    IN	Varchar2,
		 p_Activity_Exists OUT NOCOPY	Varchar2)
	IS
		v_sql	Varchar2(1000)  ;
		v_ret	Number		;
	Begin
		v_sql :=
			'Select Count(*)
			 from jtf_ih_activities
			 where Interaction_id = :Interaction_Id
			 AND   doc_ref = :doc_ref' ;

		EXECUTE IMMEDIATE v_sql
		INTO v_ret
		USING p_Interaction_id, p_doc_ref		;

		If v_ret >= 1 then
			p_activity_exists := 'Yes' ;
		Else
			p_activity_exists := 'No' ;
		End If ;

	EXCEPTION
		When others then
			p_Activity_Exists :=substr(to_char(sqlcode) || sqlerrm, 1, 120) ;
	END Get_Activity_Status ;

	---------------------------------------------------------------------
	--			GET_ACTION_DESCRIPTION
	---------------------------------------------------------------------
	-- Takes Action_id as parameter and returns the corresponding
	-- description from JTF_IH_ACTIONS_VL view
	---------------------------------------------------------------------
	Procedure Get_Action_Description
		(p_Action_id 	IN	Number,
		 p_Action_Desc OUT NOCOPY JTF_IH_ACTIONS_VL.Short_Description%TYPE)
	IS
		v_sql	Varchar2(100) ;
	Begin
		v_sql :=
			'Select Short_Description
			 from JTF_IH_ACTIONS_VL
			 where Action_id = :Action_id' ;

		EXECUTE IMMEDIATE v_sql
			INTO p_action_desc
			USING p_action_id ;
	EXCEPTION
		When NO_DATA_FOUND then
			p_action_desc := null ;
		When others then
			p_Action_desc :=  substr(sqlcode || sqlerrm, 1, 120) ;
	END Get_Action_Description ;


	---------------------------------------------------------------------
	--				GET_OBJECT_NAME
	---------------------------------------------------------------------
	-- Takes Object Code as parameter and returns the corresponding
	-- description from JTF_OBJECTS_VL view
	---------------------------------------------------------------------
	Procedure Get_Object_Name
		(p_doc_ref 	IN	Varchar2,
		 p_object_name OUT NOCOPY JTF_OBJECTS_VL.name%TYPE)
	IS
		v_sql	Varchar2(200) ;
	Begin
		v_sql :=
			'Select Name
			 from JTF_Objects_vl
			 where object_code = :p_doc_ref' ;

		EXECUTE IMMEDIATE v_sql
			INTO p_object_name
			USING p_doc_ref ;
	EXCEPTION
		When NO_DATA_FOUND then
			p_object_name := null ;
		When others then
			p_object_name :=  substr(sqlcode || sqlerrm, 1, 120) ;
	END Get_Object_Name ;
	---------------------------------------------------------------------
	--			GET_Outcome_DESCRIPTION
	---------------------------------------------------------------------
	-- Takes Action_id as parameter and returns the corresponding
	-- description from JTF_IH_ACTIONS_VL view
	---------------------------------------------------------------------
	Procedure Get_OUTCOME_Description
		(p_Outcome_Id 	IN	Number,
		 p_Outcome_Desc OUT NOCOPY JTF_IH_OUTCOMES_VL.Short_Description%TYPE)
	IS
		v_sql	Varchar2(100) ;
	Begin
		v_sql :=
			'Select Short_Description
			from JTF_IH_OUTCOMES_VL
			where Outcome_Id = :Outcome_Id' ;

		EXECUTE IMMEDIATE v_sql
			INTO p_outcome_desc
			USING p_outcome_id ;
	EXCEPTION
		When NO_DATA_FOUND then
			p_outcome_desc := null ;
		When others then
			p_outcome_desc:=  substr(sqlcode || sqlerrm, 1, 120) ;
	END GET_OUTCOME_DESCRIPTION ;



	---------------------------------------------------------------------
	--					GET_REASON_DESCRIPTION
	---------------------------------------------------------------------
	-- Takes Action_id as parameter and returns the corresponding
	-- description from JTF_IH_REASONS_VL view
	---------------------------------------------------------------------
	Procedure Get_REASON_Description
		(p_REASON_id 	IN	Number,
		 p_REASON_Desc OUT NOCOPY JTF_IH_REASONS_VL.Short_Description%TYPE)
	IS
		v_sql	Varchar2(100) ;
	Begin
		v_sql :=
			'Select Short_Description
			 from JTF_IH_REASONS_VL
			 where REASON_id = :REASON_id' ;

		EXECUTE IMMEDIATE v_sql
			INTO p_reason_desc
			USING p_reason_id ;
	EXCEPTION
		When NO_DATA_FOUND then
			p_reason_desc := null ;
		When others then
			p_REASON_desc :=  substr(sqlcode || sqlerrm, 1, 120) ;
	END GET_REASON_DESCRIPTION ;

	---------------------------------------------------------------------
	--					GET_RESULT_DESCRIPTION
	---------------------------------------------------------------------
	-- Takes result_id as parameter and returns the corresponding
	-- description from JTF_IH_RESULTS_VL view
	---------------------------------------------------------------------
	Procedure Get_result_description
		(p_result_id 	IN	Number,
		 p_result_Desc OUT NOCOPY JTF_IH_RESULTS_VL.Short_Description%TYPE)
	IS
		v_sql	Varchar2(100) ;
	Begin
		v_sql :=
			'Select Short_Description
			 from JTF_IH_RESULTS_VL
			 where result_id = :result_id' ;

		EXECUTE IMMEDIATE v_sql
			INTO p_result_desc
			USING p_result_id ;
	EXCEPTION
		When NO_DATA_FOUND then
			p_result_desc := null ;
		When others then
			p_result_desc :=  substr(sqlcode || sqlerrm, 1, 120) ;
	END GET_RESULT_DESCRIPTION ;


End IEX_CALL_HISTORY ;

/
