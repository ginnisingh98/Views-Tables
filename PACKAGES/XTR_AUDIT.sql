--------------------------------------------------------
--  DDL for Package XTR_AUDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_AUDIT" AUTHID CURRENT_USER AS
/* $Header: xtraudts.pls 120.2 2005/06/29 05:50:47 badiredd ship $ */

PROCEDURE XTR_AUDIT_REPORT(
		errbuf       		OUT NOCOPY	VARCHAR2,
		retcode      		OUT NOCOPY	VARCHAR2,
		p_event_group			VARCHAR2,
		p_audit_from_date		VARCHAR2,
		p_audit_to_date			VARCHAR2);

PROCEDURE XTR_AUDIT_RETRIEVE(
		p_audit_requested_by IN VARCHAR2,
		p_audit_request_id   IN NUMBER,
		p_event_name         IN VARCHAR2,
		p_date_from          IN VARCHAR2,
		p_date_to            IN VARCHAR2);

PROCEDURE XTR_TERM_ACTIONS_RETRIEVE(
		p_audit_requested_by IN VARCHAR2,
		p_audit_request_id   IN NUMBER,
		p_event_name         IN VARCHAR2,
		p_date_from          IN VARCHAR2,
		p_date_to            IN VARCHAR2);

PROCEDURE SUBMIT_AUDIT_REPORT(
		p_audit_request_id  IN NUMBER,
                p_event_group   IN VARCHAR2,
		p_from_date 	IN VARCHAR2,
		p_to_date	IN VARCHAR2);

END XTR_AUDIT;

 

/
