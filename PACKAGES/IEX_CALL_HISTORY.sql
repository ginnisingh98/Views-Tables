--------------------------------------------------------
--  DDL for Package IEX_CALL_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_CALL_HISTORY" AUTHID CURRENT_USER AS
/* $Header: iexhicls.pls 120.0 2004/01/24 03:18:50 appldev noship $ */
	TYPE Interaction_Rec is RECORD(
		Interaction_id		JTF_IH_INTERACTIONS.Interaction_Id%TYPE,
		start_date		Varchar2(25)	,
		start_time		Varchar2(25)	,
		resource_name		jtf_rs_resource_extns_vl.resource_name%TYPE,
		Disputed			Varchar2(5)	,
		Paid				Varchar2(5)	,
		Correspondence_sent	Varchar2(5)	,
		Promise_to_pay		Varchar2(5)	) ;

	-- Interaction pl/sql Table that is passed back to the form
	TYPE Interaction_tbl is TABLE of Interaction_rec
		Index By Binary_Integer ;

	TYPE interaction_id_tbl IS TABLE OF
					JTF_IH_INTERACTIONS.Interaction_Id%TYPE
					Index By Binary_Integer ;


	TYPE start_date_time_tbl IS TABLE OF Date
					Index By Binary_Integer ;
	TYPE resource_name_tbl IS TABLE OF
					jtf_rs_resource_extns_vl.resource_name%TYPE
					Index By Binary_Integer ;

	v_interaction_id_tbl	Interaction_id_tbl	;
	v_start_date_time_tbl	start_date_time_tbl	;
	v_resource_name_tbl		resource_name_tbl	;

	-- Actual History Activity PL/SQl Record that is passed back to the Form
	TYPE	Interaction_Activity_Rec is RECORD(
		Interaction_Id		JTF_IH_ACTIVITIES.Interaction_id%TYPE	,
		Action_id			JTF_IH_ACTIVITIES.Action_Id%TYPE		,
		Action_Description	JTF_IH_ACTIONS_TL.Short_Description%TYPE,
		OutCome_Id		JTF_IH_ACTIVITIES.Outcome_id%TYPE		,
		Outcome_Description	JTF_IH_OUTCOMES_TL.Short_Description%TYPE,
		Reason_id			JTF_IH_ACTIVITIES.Reason_Id%TYPE		,
		Reason_Description	JTF_IH_REASONS_TL.Short_Description%TYPE,
		Result_id			JTF_IH_ACTIVITIES.Result_Id%TYPE		,
		Result_Description	JTF_IH_RESULTS_TL.Short_Description%TYPE,
		Duration			JTF_IH_ACTIVITIES.Duration%TYPE		,
		Doc_Id			JTF_IH_ACTIVITIES.doc_id%TYPE			,
		Doc_ref			JTF_IH_ACTIVITIES.doc_ref%TYPE		,
		Object_Name		JTF_OBJECTS_VL.Name%TYPE				,
		Object_Description	JTF_OBJECTS_VL.Description%TYPE		,
		Object_Id			JTF_IH_ACTIVITIES.Object_Id%TYPE		,
		Object_Type		JTF_IH_ACTIVITIES.Object_Type%TYPE		,
		Source_Code_Id		JTF_IH_ACTIVITIES.Source_Code_Id%TYPE	,
		Source_Code_Type	JTF_IH_ACTIVITIES.Source_Code%TYPE) ;

	-- History Activity pl/sql Table that is passed back to the form
	TYPE Interaction_Activity_Tbl is TABLE of Interaction_Activity_Rec
		Index By Binary_Integer ;

	-- Internal Selection Record, used to build the main activity record
	TYPE Activity_Select_rec IS RECORD(
		Interaction_id		JTF_IH_ACTIVITIES.interaction_id%TYPE	,
		Activity_Id		JTF_IH_ACTIVITIES.activity_id%TYPE		,
		Action_Id			JTF_IH_ACTIVITIES.action_id%TYPE		,
		OutCome_ID		JTF_IH_ACTIVITIES.outcome_id%TYPE		,
		Reason_ID			JTF_IH_ACTIVITIES.reason_id%TYPE		,
		Result_Id			JTF_IH_ACTIVITIES.result_id%TYPE		,
		Duration			JTF_IH_ACTIVITIES.duration%TYPE		,
		Doc_Id			JTF_IH_ACTIVITIES.doc_id%TYPE			,
		Doc_ref			JTF_IH_ACTIVITIES.doc_ref%TYPE		,
		Object_Id			JTF_IH_ACTIVITIES.Object_Id%TYPE		,
		Object_Type		JTF_IH_ACTIVITIES.Object_Type%TYPE		,
		Source_Code_Id		JTF_IH_ACTIVITIES.Source_Code_Id%TYPE	,
		Source_Code_Type	JTF_IH_ACTIVITIES.Source_Code%TYPE ) ;

	-- Ref cursors to select the History and Activity Data
	TYPE INTERACTION_CURSOR 			IS	REF CURSOR	;
	TYPE INTERACTION_ACTIVITY_CURSOR 	IS	REF CURSOR	;


	PROCEDURE QUERY_INTERACTION_RECORDS (
		p_mode          IN      Varchar2,
    		p_id		        IN 	    Number		,
		P_From_Date		  IN      Date			,
		P_To_Date   		IN      Date			,
		p_Interaction_tbl  	IN OUT NOCOPY  	Interaction_Tbl,
		p_error_code		IN OUT NOCOPY	Varchar2		,
		p_error_mesg		IN OUT NOCOPY	Varchar2	) 	;

	PROCEDURE QUERY_ACTIVITY_RECORDS
		(P_Interaction_id 			IN OUT NOCOPY	Number		,
    		p_Interaction_activity_tbl 	IN OUT NOCOPY  	Interaction_Activity_Tbl,
		p_error_code     			IN OUT NOCOPY  	Varchar2,
		p_error_mesg     			IN OUT NOCOPY  	Varchar2)  ;


End IEX_CALL_HISTORY ;

 

/
