--------------------------------------------------------
--  DDL for Package AR_CMGT_WF_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CMGT_WF_ENGINE" AUTHID CURRENT_USER AS
/* $Header: ARCMGWFS.pls 120.6 2005/12/23 19:39:04 bsarkar noship $ */

PROCEDURE ASSIGN_CREDIT_ANALYST (
    itemtype        in      varchar2,
    itemkey         in      varchar2,
    actid           in      number,
    funcmode        in      varchar2,
    resultout       out NOCOPY     varchar2);

PROCEDURE POST_CREDIT_ANALYST_ASSIGNMENT (
    itemtype        in      varchar2,
    itemkey         in      varchar2,
    actid           in      number,
    funcmode        in      varchar2,
    resultout       out NOCOPY     varchar2);

procedure start_workflow (
    p_credit_request_id             IN  NUMBER,
    p_application_status            IN  VARCHAR2 default 'SUBMIT');


procedure CHECK_APPLICATION_STATUS(
	itemtype		         in 	varchar2,
	itemkey			         in	varchar2,
	actid			         in	number,
	funcmode		         in	varchar2,
	resultout		         out NOCOPY	varchar2);

PROCEDURE CREATE_PARTY_PROFILE (
    itemtype        in      varchar2,
    itemkey         in      varchar2,
    actid           in      number,
    funcmode        in      varchar2,
    resultout       out NOCOPY     varchar2);

procedure CHECK_CREDIT_POLICY(
	itemtype		         in varchar2,
	itemkey			         in	varchar2,
	actid			         in	number,
	funcmode		         in	varchar2,
	resultout		         out NOCOPY varchar2);

procedure CHECK_SCORING_MODEL(
	itemtype		         in varchar2,
	itemkey			         in	varchar2,
	actid			         in	number,
	funcmode		         in	varchar2,
	resultout		         out NOCOPY varchar2);


procedure UNDO_CASE_FOLDER(
	itemtype		         in varchar2,
	itemkey			         in	varchar2,
	actid			         in	number,
	funcmode		         in	varchar2,
	resultout		         out NOCOPY varchar2);


procedure UPDATE_CREDIT_REQ_TO_PROCESS(
	itemtype		         in varchar2,
	itemkey			         in	varchar2,
	actid			         in	number,
	funcmode		         in	varchar2,
	resultout		         out NOCOPY varchar2);

PROCEDURE UPDATE_CREDIT_REQ_TO_SUBMIT (
    itemtype        in      varchar2,
    itemkey         in      varchar2,
    actid           in      number,
    funcmode        in      varchar2,
    resultout       out NOCOPY     varchar2);

PROCEDURE UPDATE_CASE_FOLDER_SUBMITTED (
    itemtype        in      varchar2,
    itemkey         in      varchar2,
    actid           in      number,
    funcmode        in      varchar2,
    resultout       out NOCOPY     varchar2);


procedure GATHER_DATA_POINTS(
	itemtype		         in varchar2,
	itemkey			         in	varchar2,
	actid			         in	number,
	funcmode		         in	varchar2,
	resultout		         out NOCOPY varchar2);

procedure CALCULATE_SCORE(
	itemtype		         in varchar2,
	itemkey			         in	varchar2,
	actid			         in	number,
	funcmode		         in	varchar2,
	resultout		         out NOCOPY varchar2);

procedure CHECK_AUTO_RULES(
	itemtype		         in varchar2,
	itemkey			         in	varchar2,
	actid			         in	number,
	funcmode		         in	varchar2,
	resultout		         out NOCOPY varchar2);

procedure OVERRIDE_CHECKLIST(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2);

procedure CHECK_REQUIRED_DATA_POINTS(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2) ;

procedure CHECK_SCORING_DATA_POINTS(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2);

procedure SKIP_APPROVAL(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2);


procedure GENERATE_RECOMMENDATION(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2);



procedure APPROVAL_PROCESS(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2);

 procedure UPDATE_AME_APPROVE(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2);

 procedure UPDATE_AME_REJECT(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2);

PROCEDURE IMPLEMENT_RECOMMENDATION(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2);

PROCEDURE IMPLEMENT_CUSTOM_RECO(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2);

procedure MARK_MANUAL_ANALYSIS(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2);

PROCEDURE SET_ROUTING_STATUS (
    itemtype        in      varchar2,
    itemkey         in      varchar2,
    actid           in      number,
    funcmode        in      varchar2,
    resultout       out NOCOPY     varchar2);



PROCEDURE CHECK_SCORING_CURRENCY (
    itemtype        in      varchar2,
    itemkey         in      varchar2,
    actid           in      number,
    funcmode        in      varchar2,
    resultout       out NOCOPY     varchar2);

PROCEDURE UPDATE_SKIP_APPROVAL_FLAG (
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2);

PROCEDURE UPDATE_CF_TO_CREATE (
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2);

PROCEDURE POST_IMPLEMENT_PROCESS (
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2);

PROCEDURE GENERATE_CREDIT_CLASSIFICATION (
    itemtype        in      varchar2,
    itemkey         in      varchar2,
    actid           in      number,
    funcmode        in      varchar2,
    resultout       out NOCOPY     varchar2);

PROCEDURE UPDATE_WF_ATTRIBUTE (
	p_itemkey			IN		VARCHAR2,
    p_attribute_type    IN      VARCHAR2,
	p_attribute_name	IN		VARCHAR2,
	p_attribute_value	IN		VARCHAR2 );

PROCEDURE MARK_REQUEST_ON_HOLD (
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2);

PROCEDURE VALIDATE_RECOMMENDATIONS(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2);

PROCEDURE CHECK_CHILD_REQ_COMPLETED(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2);
procedure APPEAL_RESUB_DECISION(
	itemtype		in 	varchar2,
	itemkey			in	varchar2,
	actid			in	number,
	funcmode		in	varchar2,
	resultout		out NOCOPY	varchar2);
PROCEDURE POPULATE_WF_ATTRIBUTES (
    itemtype         in      varchar2,
    itemkey          in      varchar2,
    actid            in      number,
    funcmode         in      varchar2,
    p_called_from 	 IN      varchar2,
    resultout        out NOCOPY     varchar2);
PROCEDURE CHECK_EXTRNAL_DATA_POINTS (
  itemtype         in      varchar2,
    itemkey          in      varchar2,
    actid            in      number,
    funcmode         in      varchar2,
    resultout        out NOCOPY     varchar2);
PROCEDURE GET_EXT_SCORE_RECOMMENDATIONS (
    itemtype         in      varchar2,
    itemkey          in      varchar2,
    p_cf_id          in      number,
    resultout        out NOCOPY     varchar2);

PROCEDURE submit_xml_case_folder (
    		p_case_folder_id	IN NUMBER,
    		p_request_id		OUT NOCOPY NUMBER  );

END AR_CMGT_WF_ENGINE;

 

/
