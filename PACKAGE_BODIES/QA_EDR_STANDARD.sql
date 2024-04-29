--------------------------------------------------------
--  DDL for Package Body QA_EDR_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_EDR_STANDARD" AS
/* $Header: qaedrb.pls 115.6 2004/02/18 01:58:17 isivakum noship $ */

counter pls_integer;

v_eventQuery EDR_STANDARD_PUB.EventDetail_tbl_type;
--Uncomment above when edr_standard_pub is available
v_erecord_id_tbl EDR_ERES_EVENT_PUB.ERECORD_ID_TBL_TYPE;
v_eres_event_rec EDR_ERES_EVENT_PUB.ERES_EVENT_REC_TYPE;--8.1.7 change
v_eres_event_tbl EDR_ERES_EVENT_PUB.ERES_EVENT_TBL_TYPE;

v_eventQuery_pvt EDR_STANDARD.eventQuery;

--Below added for bug 3265661 so Fuad can call this from engwkfwb.pls
v_doc_parameters_tbl EDR_EVIDENCESTORE_PUB.params_tbl_type;
v_sig_parameters_tbl EDR_EVIDENCESTORE_PUB.params_tbl_type;

--------------------------------------------------
--PRIVATE PROCEDURES
PROCEDURE convert_QaToEdr (qa_event IN qa_edr_standard.eres_event_rec_type,
                           edr_event IN OUT NOCOPY EDR_ERES_EVENT_PUB.eres_event_rec_type)
IS

BEGIN

    edr_event.event_name     := qa_event.event_name;
    edr_event.event_key      := qa_event.event_key ;
    edr_event.erecord_id     := qa_event.erecord_id;
    edr_event.event_status   := qa_event.event_status;
    edr_event.param_name_1   := qa_event.param_name_1;
    edr_event.param_value_1  := qa_event.param_value_1;
    edr_event.param_name_2   := qa_event.param_name_2;
    edr_event.param_value_2  := qa_event.param_value_2;
    edr_event.param_name_3   := qa_event.param_name_3;
    edr_event.param_value_3  := qa_event.param_value_3;
    edr_event.param_name_4   := qa_event.param_name_4;
    edr_event.param_value_4  := qa_event.param_value_4;
    edr_event.param_name_5   := qa_event.param_name_5;
    edr_event.param_value_5  := qa_event.param_value_5;
    edr_event.param_name_6   := qa_event.param_name_6;
    edr_event.param_value_6  := qa_event.param_value_6;
    edr_event.param_name_7   := qa_event.param_name_7;
    edr_event.param_value_7  := qa_event.param_value_7;
    edr_event.param_name_8   := qa_event.param_name_8;
    edr_event.param_value_8  := qa_event.param_value_8;
    edr_event.param_name_9   := qa_event.param_name_9;
    edr_event.param_value_9  := qa_event.param_value_9;
    edr_event.param_name_10  := qa_event.param_name_10;
    edr_event.param_value_10 := qa_event.param_value_10;
    edr_event.param_name_11  := qa_event.param_name_11;
    edr_event.param_value_11 := qa_event.param_value_11;
    edr_event.param_name_12  := qa_event.param_name_12;
    edr_event.param_value_12 := qa_event.param_value_12;
    edr_event.param_name_13  := qa_event.param_name_13;
    edr_event.param_value_13 := qa_event.param_value_13;
    edr_event.param_name_14  := qa_event.param_name_14;
    edr_event.param_value_14 := qa_event.param_value_14;
    edr_event.param_name_15  := qa_event.param_name_15;
    edr_event.param_value_15 := qa_event.param_value_15;
    edr_event.param_name_16  := qa_event.param_name_16;
    edr_event.param_value_16 := qa_event.param_value_16;
    edr_event.param_name_17  := qa_event.param_name_17;
    edr_event.param_value_17 := qa_event.param_value_17;
    edr_event.param_name_18  := qa_event.param_name_18;
    edr_event.param_value_18 := qa_event.param_value_18;
    edr_event.param_name_19  := qa_event.param_name_19;
    edr_event.param_value_19 := qa_event.param_value_19;
    edr_event.param_name_20  := qa_event.param_name_20;
    edr_event.param_value_20 := qa_event.param_value_20;

END convert_QaToEdr;
--------------------------------------------------------------------
PROCEDURE convert_EdrToQa (edr_event IN EDR_ERES_EVENT_PUB.eres_event_rec_type,
                           qa_event IN OUT NOCOPY qa_edr_standard.eres_event_rec_type)
IS

BEGIN

    qa_event.event_name     := edr_event.event_name;
    qa_event.event_key      := edr_event.event_key ;
    qa_event.erecord_id     := edr_event.erecord_id;
    qa_event.event_status   := edr_event.event_status;
    qa_event.param_name_1   := edr_event.param_name_1;
    qa_event.param_value_1  := edr_event.param_value_1;
    qa_event.param_name_2   := edr_event.param_name_2;
    qa_event.param_value_2  := edr_event.param_value_2;
    qa_event.param_name_3   := edr_event.param_name_3;
    qa_event.param_value_3  := edr_event.param_value_3;
    qa_event.param_name_4   := edr_event.param_name_4;
    qa_event.param_value_4  := edr_event.param_value_4;
    qa_event.param_name_5   := edr_event.param_name_5;
    qa_event.param_value_5  := edr_event.param_value_5;
    qa_event.param_name_6   := edr_event.param_name_6;
    qa_event.param_value_6  := edr_event.param_value_6;
    qa_event.param_name_7   := edr_event.param_name_7;
    qa_event.param_value_7  := edr_event.param_value_7;
    qa_event.param_name_8   := edr_event.param_name_8;
    qa_event.param_value_8  := edr_event.param_value_8;
    qa_event.param_name_9   := edr_event.param_name_9;
    qa_event.param_value_9  := edr_event.param_value_9;
    qa_event.param_name_10  := edr_event.param_name_10;
    qa_event.param_value_10 := edr_event.param_value_10;
    qa_event.param_name_11  := edr_event.param_name_11;
    qa_event.param_value_11 := edr_event.param_value_11;
    qa_event.param_name_12  := edr_event.param_name_12;
    qa_event.param_value_12 := edr_event.param_value_12;
    qa_event.param_name_13  := edr_event.param_name_13;
    qa_event.param_value_13 := edr_event.param_value_13;
    qa_event.param_name_14  := edr_event.param_name_14;
    qa_event.param_value_14 := edr_event.param_value_14;
    qa_event.param_name_15  := edr_event.param_name_15;
    qa_event.param_value_15 := edr_event.param_value_15;
    qa_event.param_name_16  := edr_event.param_name_16;
    qa_event.param_value_16 := edr_event.param_value_16;
    qa_event.param_name_17  := edr_event.param_name_17;
    qa_event.param_value_17 := edr_event.param_value_17;
    qa_event.param_name_18  := edr_event.param_name_18;
    qa_event.param_value_18 := edr_event.param_value_18;
    qa_event.param_name_19  := edr_event.param_name_19;
    qa_event.param_value_19 := edr_event.param_value_19;
    qa_event.param_name_20  := edr_event.param_name_20;
    qa_event.param_value_20 := edr_event.param_value_20;

END convert_EdrToQa;

---------------------------------------------------------------
PROCEDURE Get_PsigStatus (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_event_name 		in    	varchar2,
	p_event_key		in    	varchar2,
      	x_psig_status    	out 	NOCOPY varchar2   )
IS

BEGIN

    edr_standard_pub.Get_PsigStatus(
    p_api_version,
	p_init_msg_list,
	x_return_status,
	x_msg_count,
	x_msg_data,
	p_event_name,
	p_event_key,
    x_psig_status);

    NULL;
END;

-- ---------------------------------------

PROCEDURE Is_eSig_Required  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_event_name 	       	IN 	varchar2,
	p_event_key	 	IN   	varchar2,
	x_isRequired_eSig      	OUT 	NOCOPY VARCHAR2  )
IS

BEGIN

    edr_standard_pub.Is_eSig_Required (
	p_api_version,
	p_init_msg_list,
	x_return_status,
	x_msg_count,
	x_msg_data,
	p_event_name,
	p_event_key,
	x_isRequired_eSig   );

    NULL;
END;

-- ---------------------------------------

PROCEDURE Is_eRec_Required  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_event_name 	       	IN 	varchar2,
	p_event_key	 	IN   	varchar2,
	x_isRequired_eRec     	OUT 	NOCOPY VARCHAR2   )
 IS

 BEGIN

    edr_standard_pub.Is_eRec_Required  (
	p_api_version,
	p_init_msg_list,
	x_return_status,
	x_msg_count,
	x_msg_data,
	p_event_name,
	p_event_key,
	x_isRequired_eRec   ) ;

     NULL;
 END;


-- ---------------------------------------

Procedure Get_QueryId_OnEvents (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	p_commit		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_eventQuery_recTbl 	IN	qa_edr_standard.eventQuery,
	x_query_id		OUT	NOCOPY NUMBER  )
 IS
    i NUMBER;
 BEGIN

      for counter IN 1..p_eventQuery_recTbl.COUNT loop
         v_eventQuery(counter).event_name := p_eventQuery_recTbl(counter).event_name;
         v_eventQuery(counter).event_key := p_eventQuery_recTbl(counter).event_key;
         v_eventQuery(counter).key_type := p_eventQuery_recTbl(counter).key_type;
      end loop;

    edr_standard_pub.Get_QueryId_OnEvents (
	p_api_version,
	p_init_msg_list,
	p_commit,
	x_return_status,
	x_msg_count,
	x_msg_data,
	v_eventQuery,
	x_query_id  );

       NULL;
 END;


-- --------------------------------------

PROCEDURE DISPLAY_DATE_PUB (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	P_DATE_IN  		IN  	DATE ,
	x_date_out 		OUT 	NOCOPY Varchar2 ) IS
 BEGIN

    edr_standard_pub.DISPLAY_DATE (
	p_api_version,
	p_init_msg_list,
	x_return_status,
	x_msg_count,
	x_msg_data,
	P_DATE_IN,
	x_date_out );

    NULL;
 END;


-- ---------------------------------------

Procedure Is_AuditValue_Old (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_table_name 		IN 	VARCHAR2,
	p_column_name   	IN 	VARCHAR2,
	p_primKey_name     	IN 	VARCHAR2,
	p_primKey_value    	IN 	VARCHAR2,
	x_isOld_auditValue	OUT	NOCOPY VARCHAR2   )
 IS
 BEGIN

    edr_standard_pub.Is_AuditValue_Old (
	p_api_version,
	p_init_msg_list,
	x_return_status,
	x_msg_count,
	x_msg_data,
	p_table_name,
	p_column_name,
	p_primKey_name,
	p_primKey_value,
	x_isOld_auditValue);

     NULL;
 END;

-- ---------------------------------------

PROCEDURE Get_Lookup_Meaning (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_lookup_type 		IN 	VARCHAR2,
	p_lookup_code 		IN 	VARCHAR2,
	x_lkup_meaning 		OUT 	NOCOPY VARCHAR2  )
 IS

 BEGIN
    edr_standard_pub.Get_Lookup_Meaning (
	p_api_version,
	p_init_msg_list,
	x_return_status,
	x_msg_count,
	x_msg_data,
	p_lookup_type,
	p_lookup_code,
	x_lkup_meaning  );
     NULL;
 END;

------------------------------------------------------------------
FUNCTION PSIG_QUERY(p_eventQuery QA_EDR_STANDARD.eventQuery) return number IS PRAGMA AUTONOMOUS_TRANSACTION;
i number;
begin
      for counter IN 1..p_eventQuery.COUNT loop
         v_eventQuery_pvt(counter).event_name := p_eventQuery(counter).event_name;
         v_eventQuery_pvt(counter).event_key := p_eventQuery(counter).event_key;
         v_eventQuery_pvt(counter).key_type := p_eventQuery(counter).key_type;
      end loop;
      i := edr_standard.psig_query(v_eventQuery_pvt);
      return i;
END PSIG_QUERY;



PROCEDURE DISPLAY_DATE(P_DATE_IN in DATE , P_DATE_OUT OUT NOCOPY Varchar2) IS
BEGIN
  edr_standard.display_date(p_date_in, p_date_out);
END DISPLAY_DATE;

--Below from EDR_ERES_EVENT_PUB
PROCEDURE RAISE_ERES_EVENT
( p_api_version         IN                NUMBER                          ,
  p_init_msg_list       IN                VARCHAR2,
  p_validation_level    IN                NUMBER,
  x_return_status       OUT NOCOPY        VARCHAR2                        ,
  x_msg_count           OUT NOCOPY        NUMBER                          ,
  x_msg_data            OUT NOCOPY        VARCHAR2                        ,
  p_child_erecords      IN                ERECORD_ID_TBL_TYPE             ,
  x_event               IN OUT NOCOPY     ERES_EVENT_REC_TYPE
)
IS

BEGIN
        for counter IN 1..p_child_erecords.COUNT loop
            v_erecord_id_tbl(counter) := p_child_erecords(counter);
        end loop;

        convert_QaToEdr (x_event, v_eres_event_rec);

   EDR_ERES_EVENT_PUB.RAISE_ERES_EVENT
   ( p_api_version         ,
    p_init_msg_list   ,
    p_validation_level ,
    x_return_status  ,
    x_msg_count ,
    x_msg_data ,
    v_erecord_id_tbl ,
    v_eres_event_rec
    ) ;

        convert_EdrToQa(v_eres_event_rec, x_event);

END;

PROCEDURE RAISE_INTER_EVENT
( p_api_version          IN               NUMBER                          ,
  p_init_msg_list        IN               VARCHAR2,
  p_validation_level     IN               NUMBER,
  x_return_status        OUT NOCOPY       VARCHAR2                        ,
  x_msg_count            OUT NOCOPY       NUMBER                          ,
  x_msg_data             OUT NOCOPY       VARCHAR2                        ,
  x_events               IN OUT NOCOPY    ERES_EVENT_TBL_TYPE             ,
  x_overall_status 	 OUT NOCOPY       VARCHAR2
)
IS

BEGIN
      for counter IN 1..x_events.COUNT loop
        convert_QaToEdr(x_events(counter), v_eres_event_tbl(counter));
      end loop;

      EDR_ERES_EVENT_PUB.RAISE_INTER_EVENT
      ( p_api_version  ,
         p_init_msg_list   ,
        p_validation_level  ,
        x_return_status   ,
        x_msg_count  ,
        x_msg_data ,
        v_eres_event_tbl   ,
        x_overall_status
        );

      for counter IN 1..x_events.COUNT loop
        convert_EdrToQa(v_eres_event_tbl(counter), x_events(counter));
      end loop;

END;


PROCEDURE GET_ERECORD_ID ( p_api_version   IN	NUMBER	    ,
                           p_init_msg_list IN	VARCHAR2  ,
                           x_return_status OUT	NOCOPY VARCHAR2 ,
                           x_msg_count	 OUT	NOCOPY NUMBER   ,
                           x_msg_data	 OUT	NOCOPY VARCHAR2 ,
                           p_event_name    IN   VARCHAR2        ,
                           p_event_key     IN   VARCHAR2        ,
                           x_erecord_id	 OUT NOCOPY 	NUMBER         )
IS

BEGIN
    EDR_STANDARD_PUB.GET_ERECORD_ID
    ( p_api_version     ,
      p_init_msg_list  ,
      x_return_status  ,
      x_msg_count ,
      x_msg_data ,
      p_event_name   ,
      p_event_key  ,
      x_erecord_id  );
          NULL;
END;

procedure SEND_ACKN
( p_api_version          IN		NUMBER				   ,
  p_init_msg_list	 IN		VARCHAR2			   ,
  x_return_status	 OUT NOCOPY	VARCHAR2		  	   ,
  x_msg_count		 OUT NOCOPY 	NUMBER				   ,
  x_msg_data		 OUT NOCOPY	VARCHAR2			   ,
  p_event_name           IN            	VARCHAR2  			   ,
  p_event_key            IN            	VARCHAR2  			   ,
  p_erecord_id	         IN		NUMBER			  	   ,
  p_trans_status	 IN		VARCHAR2			   ,
  p_ackn_by              IN             VARCHAR2		           ,
  p_ackn_note	         IN		VARCHAR2			   ,
  p_autonomous_commit	 IN  		VARCHAR2
)
IS
BEGIN
    EDR_TRANS_ACKN_PUB.SEND_ACKN( p_api_version,
            p_init_msg_list,
            x_return_status	,
            x_msg_count	 ,
            x_msg_data	   ,
            p_event_name  ,
            p_event_key  ,
            p_erecord_id ,
            p_trans_status	 ,
            p_ackn_by    ,
            p_ackn_note	   ,
            p_autonomous_commit
            );
END;

-- ----------------------------------------
-- API name 	: wrapper for edr Capture_Signature
-- Reference	: edr_evidencestore_pub.capture_signature for documentation
-- Function	: capture the signature for single event
-- BUG: Below added for bug 3265661 so Fuad can call this from engwkfwb.pls
-- ---------------------------------------

PROCEDURE Capture_Signature  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	p_commit		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_psig_xml		IN 	CLOB,
	p_psig_document		IN 	CLOB,
	p_psig_docFormat	IN 	VARCHAR2,
	p_psig_requester	IN 	VARCHAR2,
	p_psig_source		IN 	VARCHAR2,
	p_event_name		IN 	VARCHAR2,
	p_event_key		IN 	VARCHAR2,
	p_wf_notif_id		IN 	NUMBER,
	x_document_id		OUT	NOCOPY NUMBER,
	p_doc_parameters_tbl	IN	qa_edr_standard.Params_tbl_type,
	p_user_name		IN	VARCHAR2,
	p_original_recipient	IN	VARCHAR2,
	p_overriding_comment	IN	VARCHAR2,
	x_signature_id		OUT	NOCOPY NUMBER,
	p_evidenceStore_id	IN	NUMBER,
	p_user_response		IN	VARCHAR2,
	p_sig_parameters_tbl	IN	qa_edr_standard.Params_tbl_type )
IS
BEGIN
      for counter IN 1..p_doc_parameters_tbl.COUNT loop
         v_doc_parameters_tbl(counter).param_name := p_doc_parameters_tbl(counter).param_name;
         v_doc_parameters_tbl(counter).param_value := p_doc_parameters_tbl(counter).param_value;
         v_doc_parameters_tbl(counter).param_displayname := p_doc_parameters_tbl(counter).param_displayname;
      end loop;

      for counter IN 1..p_sig_parameters_tbl.COUNT loop
         v_sig_parameters_tbl(counter).param_name := p_sig_parameters_tbl(counter).param_name;
         v_sig_parameters_tbl(counter).param_value := p_sig_parameters_tbl(counter).param_value;
         v_sig_parameters_tbl(counter).param_displayname := p_sig_parameters_tbl(counter).param_displayname;
      end loop;

   -- capture and store the eRecord in the evidence store
	EDR_EvidenceStore_PUB.Capture_Signature  (
		p_api_version		=> p_api_version,
		p_init_msg_list		=> p_init_msg_list,
		p_commit		=> p_commit,
		x_return_status		=> x_return_status,
		x_msg_count	    	=> x_msg_count,
		x_msg_data		=> x_msg_data,
		P_PSIG_XML		=> p_psig_xml,
	        P_PSIG_DOCUMENT		=> p_psig_document,
		P_PSIG_DocFormat 	=> p_psig_docFormat,
		P_PSIG_REQUESTER	=> p_psig_requester,
		P_PSIG_SOURCE		=> p_psig_source,
		P_EVENT_NAME		=> p_event_name,
		P_EVENT_KEY		=> p_event_key,
		P_WF_Notif_ID		=> p_wf_notif_id,
		x_DOCUMENT_ID		=> x_document_id,
		p_doc_parameters_tbl	=> v_doc_parameters_tbl,
		p_user_name	        => p_user_name,
		p_original_recipient	=> p_original_recipient,
		p_overriding_comment	=> p_overriding_comment,
		x_signature_id		=> x_signature_id,
		p_evidenceStore_id	=> p_evidenceStore_id,
		p_user_response	    	=> p_user_response,
		p_sig_parameters_tbl	=> v_sig_parameters_tbl  );

END;

  FUNCTION IS_INSTALLED RETURN VARCHAR2
  IS
	  --Above is a new function added as per bug 3253566
  	  --it returns 'F' in the stub version and 'T' in real version
  BEGIN
     RETURN FND_API.G_TRUE; --this is the character 'T'
  END;

   -- ALL OF BELOW 6 Procedures added due to Bug 3447098 as requested by
   -- ENG-Eres team developer Fuad Abdi
-- ----------------------------------------
-- API name 	: Open_Document (Bug 3447098)
-- Type		: Public
-- Function	: create a document instance for signature
--		: and can associate signatures before closing the docuemnt
-- Versions	: 1.0	17-Jul-03	created
-- ---------------------------------------

PROCEDURE open_Document	(
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	p_commit		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	P_PSIG_XML    		IN 	CLOB DEFAULT NULL,
    P_PSIG_DOCUMENT  	IN 	CLOB DEFAULT NULL,
    P_PSIG_DOCUMENTFORMAT  	IN 	VARCHAR2 DEFAULT NULL,
    P_PSIG_REQUESTER	IN 	VARCHAR2,
    P_PSIG_SOURCE    	IN 	VARCHAR2 DEFAULT NULL,
    P_EVENT_NAME  		IN 	VARCHAR2 DEFAULT NULL,
    P_EVENT_KEY  		IN 	VARCHAR2 DEFAULT NULL,
    p_WF_Notif_ID           IN 	NUMBER   DEFAULT NULL,
    x_DOCUMENT_ID          	OUT 	NOCOPY NUMBER	)
IS
BEGIN
    EDR_EvidenceStore_PUB.open_document (
    p_api_version ,
	p_init_msg_list ,
	p_commit ,
	x_return_status	,
	x_msg_count	,
	x_msg_data ,
	P_PSIG_XML ,
    P_PSIG_DOCUMENT ,
    P_PSIG_DOCUMENTFORMAT ,
    P_PSIG_REQUESTER ,
    P_PSIG_SOURCE ,
    P_EVENT_NAME ,
    P_EVENT_KEY ,
    p_WF_Notif_ID ,
    x_DOCUMENT_ID );
END;

-- ----------------------------------------
-- API name 	: Post_DocumentParameter (Bug 3447098)
-- Type		: Public
-- Function	: Update a document
-- Versions	: 1.0	17-Jul-03	created
-- ---------------------------------------

PROCEDURE Post_DocumentParameters  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	p_commit		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
    p_document_id          	IN  	NUMBER,
    p_doc_parameters_tbl  	IN  	qa_edr_standard.Params_tbl_type   )
IS
BEGIN
      v_doc_parameters_tbl.DELETE; --clear the table if anything already exists

      for counter IN 1..p_doc_parameters_tbl.COUNT loop
         v_doc_parameters_tbl(counter).param_name := p_doc_parameters_tbl(counter).param_name;
         v_doc_parameters_tbl(counter).param_value := p_doc_parameters_tbl(counter).param_value;
         v_doc_parameters_tbl(counter).param_displayname := p_doc_parameters_tbl(counter).param_displayname;
      end loop;

    EDR_EvidenceStore_PUB.Post_DocumentParameters (
	p_api_version ,
	p_init_msg_list ,
	p_commit ,
	x_return_status ,
	x_msg_count ,
	x_msg_data ,
    p_document_id ,
    v_doc_parameters_tbl );
END;

-- ----------------------------------------
-- API name 	: Close_Document (Bug 3447098)
-- Type		: Public
-- Function	: close a document
-- Versions	: 1.0	17-Jul-03	created
-- ---------------------------------------

PROCEDURE Close_Document	(
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	p_commit		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
    P_DOCUMENT_ID          	IN  	NUMBER	)
IS
BEGIN
    EDR_EvidenceStore_PUB.Close_Document (
       p_api_version ,
	   p_init_msg_list ,
	   p_commit ,
	   x_return_status ,
	   x_msg_count ,
	   x_msg_data ,
       P_DOCUMENT_ID );

END;

-- ----------------------------------------
-- API name 	: Request_Signature (Bug 3447098)
-- Type		: Public
-- Function	: Update a document
-- Versions	: 1.0	17-Jul-03	created
-- ---------------------------------------

PROCEDURE Request_Signature  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	p_commit		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
    P_DOCUMENT_ID         	IN 	NUMBER,
	P_USER_NAME           	IN 	VARCHAR2,
    P_ORIGINAL_RECIPIENT  	IN 	VARCHAR2 DEFAULT NULL,
    P_OVERRIDING_COMMENT 	IN 	VARCHAR2 DEFAULT NULL,
    x_signature_id         	OUT 	NOCOPY NUMBER      )
IS
BEGIN
  EDR_EvidenceStore_PUB.Request_Signature (
   	p_api_version ,
	p_init_msg_list ,
	p_commit ,
	x_return_status ,
	x_msg_count ,
	x_msg_data ,
    P_DOCUMENT_ID ,
	P_USER_NAME ,
    P_ORIGINAL_RECIPIENT ,
    P_OVERRIDING_COMMENT ,
    x_signature_id );

END;


-- ----------------------------------------
-- API name 	: Post_Signature (Bug 3447098)
-- Type		: Public
-- Function	: Update a document
-- Versions	: 1.0	17-Jul-03	created
-- ---------------------------------------

PROCEDURE Post_Signature  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	p_commit		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
    P_DOCUMENT_ID         	IN 	NUMBER,
	p_evidenceStore_id  	IN 	VARCHAR2,
	P_USER_NAME          	IN 	VARCHAR2,
	P_USER_RESPONSE      	IN 	VARCHAR2,
    P_ORIGINAL_RECIPIENT  	IN 	VARCHAR2 DEFAULT NULL,
    P_OVERRIDING_COMMENT 	IN 	VARCHAR2 DEFAULT NULL,
    x_signature_id         	OUT 	NOCOPY NUMBER        )
IS
BEGIN
  EDR_EvidenceStore_PUB.Post_Signature  (
	p_api_version ,
	p_init_msg_list ,
	p_commit ,
	x_return_status	,
	x_msg_count ,
	x_msg_data ,
    P_DOCUMENT_ID ,
	p_evidenceStore_id ,
	P_USER_NAME ,
	P_USER_RESPONSE ,
    P_ORIGINAL_RECIPIENT ,
    P_OVERRIDING_COMMENT ,
    x_signature_id );

END;



-- ----------------------------------------
-- API name 	: Post_SignatureParameters (Bug 3447098)
-- Type		: Public
-- Function	: Update a document
-- Versions	: 1.0	17-Jul-03	created
-- ---------------------------------------

PROCEDURE Post_SignatureParameters  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	p_commit		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
    p_signature_id         	IN  	NUMBER,
    p_sig_parameters_tbl	IN  	qa_edr_standard.Params_tbl_type   )
IS
BEGIN
      v_doc_parameters_tbl.DELETE; --clear the table if anything already exists

      for counter IN 1..p_sig_parameters_tbl.COUNT loop
         v_doc_parameters_tbl(counter).param_name := p_sig_parameters_tbl(counter).param_name;
         v_doc_parameters_tbl(counter).param_value := p_sig_parameters_tbl(counter).param_value;
         v_doc_parameters_tbl(counter).param_displayname := p_sig_parameters_tbl(counter).param_displayname;
      end loop;

  EDR_EvidenceStore_PUB.Post_SignatureParameters  (
	p_api_version ,
	p_init_msg_list	,
	p_commit ,
	x_return_status ,
	x_msg_count ,
	x_msg_data ,
    	p_signature_id ,
    	v_doc_parameters_tbl );

END;


end QA_EDR_STANDARD;

/
