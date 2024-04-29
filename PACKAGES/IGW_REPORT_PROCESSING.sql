--------------------------------------------------------
--  DDL for Package IGW_REPORT_PROCESSING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_REPORT_PROCESSING" AUTHID CURRENT_USER as
-- $Header: igwburps.pls 115.22 2002/11/15 00:28:39 ashkumar ship $
  G_START_PERIOD  	NUMBER(10):=1;
  G_PROPOSAL_ID   	NUMBER(15):=0;
  G_VERSION_ID		NUMBER(15):=0;
  G_PROPOSAL_FORM_NUMBER VARCHAR2(30);


  G_PKG_NAME CONSTANT VARCHAR2(30) := 'IGW_REPORT_PROCESSING';

  PROCEDURE create_reporting_data(	p_proposal_id   		NUMBER
					,p_proposal_form_number		VARCHAR2
					,x_return_status    	OUT NOCOPY	VARCHAR2
					,x_msg_data         	OUT NOCOPY	VARCHAR2
					,x_msg_count	    	OUT NOCOPY 	NUMBER);

  PROCEDURE create_itemized_budget(	p_proposal_id   		NUMBER
					,p_proposal_form_number		VARCHAR2
					,x_return_status    	OUT NOCOPY	VARCHAR2
					,x_msg_data         	OUT NOCOPY	VARCHAR2
					,x_msg_count	    	OUT NOCOPY 	NUMBER);

  PROCEDURE create_base_rate	       (p_proposal_id			NUMBER
					,p_proposal_form_number		VARCHAR2
					,x_return_status    	OUT NOCOPY	VARCHAR2
					,x_msg_data         	OUT NOCOPY	VARCHAR2
					,x_msg_count	    	OUT NOCOPY 	NUMBER);

  PROCEDURE create_budget_justification (p_proposal_id			NUMBER
					,p_proposal_form_number		VARCHAR2
					,x_return_status    	OUT NOCOPY	VARCHAR2
					,x_msg_data         	OUT NOCOPY	VARCHAR2);

  PROCEDURE dump_justification (p_proposal_id			NUMBER
				,p_proposal_form_number		VARCHAR2
				,x_return_status    	OUT NOCOPY	VARCHAR2
				,x_msg_data         	OUT NOCOPY	VARCHAR2);


  PROCEDURE create_q_explanation	(p_proposal_form_number		VARCHAR2
					,x_return_status    	OUT NOCOPY	VARCHAR2
					,x_msg_data         	OUT NOCOPY	VARCHAR2);

  FUNCTION get_final_version(p_proposal_id   NUMBER) RETURN NUMBER;


  FUNCTION get_period_total(p_budget_category_code VARCHAR2
					, p_period_id NUMBER) RETURN NUMBER;

  Function get_period_id RETURN NUMBER;
  pragma restrict_references(get_period_id, wnds, wnps);

  Function get_proposal_id RETURN NUMBER;
  pragma restrict_references(get_proposal_id, wnds, wnps);

  Function get_version_id RETURN NUMBER;
  pragma restrict_references(get_version_id, wnds, wnps);

  Function get_proposal_role(p_role_code VARCHAR2) RETURN VARCHAR2;
  --pragma restrict_references(get_proposal_role, wnds, wnps);
  --pragma restrict_references(get_proposal_role, wnps);

  --used in setup budget category hierarchy form
  Function get_category(p_category_code VARCHAR2
               , p_proposal_form_number VARCHAR2) RETURN VARCHAR2;

  Function get_abstract(p_proposal_id in INTEGER,
                 p_abstract_type_code in INTEGER) RETURN VARCHAR2;
  pragma restrict_references(get_abstract, wnds, wnps);


  PROCEDURE get_answer(p_proposal_id   in INTEGER,
                       P_question_no   in VARCHAR2,
                       p_person_id     in INTEGER,
                       p_party_id      in  INTEGER,
                       p_organization_id in INTEGER,
                       p_response1     out NOCOPY VARCHAR2,
                       p_response2     out NOCOPY VARCHAR2);

  FUNCTION get_response(p_proposal_id   in INTEGER,
                       P_question_no   in VARCHAR2,
                       p_person_id     in INTEGER default null,
                       p_party_id      in  INTEGER,
                       p_organization_id in INTEGER default null) RETURN VARCHAR2;
  pragma restrict_references(get_response, wnds, wnps);

  FUNCTION get_explanation(p_proposal_id   in INTEGER,
                       P_question_no   in VARCHAR2,
                       p_person_id     in INTEGER default null,
                       p_party_id      in  INTEGER,
                       p_organization_id in INTEGER default null) RETURN VARCHAR2;
  pragma restrict_references(get_explanation, wnds, wnps);


 FUNCTION get_subjects(p_proposal_id in INTEGER,
                       p_study_title_id INTEGER,
                       p_subject_race in VARCHAR2,
                       p_subject_gender in VARCHAR2) RETURN INTEGER;
  pragma restrict_references(get_subjects, wnds, wnps);

 FUNCTION get_job_name(person_id_v in NUMBER) RETURN VARCHAR2;
 pragma restrict_references(get_job_name, wnds);


 FUNCTION get_phone_number(v_person_id in NUMBER,
                          v_phone_type in VARCHAR2) RETURN VARCHAR2;
 pragma restrict_references(get_phone_number, wnds, wnps);


 FUNCTION  get_person_Degrees(person_id_p in number,
 			      party_id_p  in number,
                              proposal_id_p in number) RETURN VARCHAR2;
 pragma restrict_references(get_person_degrees, wnds, wnps);


 FUNCTION  get_org_type(p_org_id in integer,
                        p_org_type1 in varchar2,
                        p_org_type2 in varchar2 default null,
                        p_org_type3 in varchar2 default null) RETURN VARCHAR2;
 pragma restrict_references(get_org_type, wnds, wnps);

 FUNCTION  get_org_party_name(p_party_id in number, p_org_id in number) RETURN VARCHAR2;
 pragma restrict_references(get_org_party_name, wnds, wnps);


END IGW_REPORT_PROCESSING;

 

/
