--------------------------------------------------------
--  DDL for Package GMA_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMA_STANDARD" AUTHID CURRENT_USER AS
/* $Header: GMASTNDS.pls 120.1 2005/07/19 11:41:32 txdaniel noship $

/* Global Variables */

G_SIGNATURE_STATUS varchar2(80):=NULL; -- Global variable which hold the status of workflow ('APPROVED','REJECTED')

G_API_VERSION NUMBER := 1.0;

/* Global Record Groups */

Type eventDetails is record(
                     event_name varchar2(240),
                     event_key  varchar2(240),
                     key_type   VARCHAR2(40)
                    );
Type eventQuery is table of eventDetails index by binary_integer;

Type RuleInputvalues is record(
                     input_name   varchar2(240),
                     input_value  varchar2(240)
                    );
Type ameRuleinputvalues is table of ruleInputvalues index by binary_integer;

/* signature Status. This Procedure returns signature status for a given event.
   The status is for the latest event happened and has values 'PENDING','COMPLETE','ERROR' */
PROCEDURE PSIG_STATUS
	(
	p_event 	in     varchar2,
	p_event_key	in     varchar2,
        P_status        out NOCOPY varchar2
	) ;

/* signature Requirement. This Procedure returns signature requireemnt for a given event.
   The status is boolean ('TRUE','FALSE') */

PROCEDURE PSIG_REQUIRED
	(
	   p_event       in   varchar2,
	   p_event_key	 in   varchar2,
           P_status      out NOCOPY boolean
	) ;

/* eRecord Requirement. This Procedure returns eRecord Requirement for a given event.
   The status is boolean ('TRUE','FALSE') */

PROCEDURE EREC_REQUIRED
	(
	   p_event       in   varchar2,
	   p_event_key	 in   varchar2,
           P_status      out NOCOPY boolean
	) ;

/* This function will be called from forms before calling the Transaction Query form */

FUNCTION PSIG_QUERY(p_eventQuery GMA_STANDARD.eventQuery) return number;

/* This procedure will be called to get AME input variable for a given transaction*/

 PROCEDURE GET_AMERULE_INPUT_VALUES(ameapplication IN varchar2,
                          	ameruleid IN NUMBER,
                          	amerulename IN VARCHAR2,
                               	ameruleinputvalues OUT NOCOPY GMA_STANDARD.ameruleinputvalues) ;


/* This Funcitons Returns a display date format */
  PROCEDURE DISPLAY_DATE(P_DATE_IN in DATE , P_DATE_OUT OUT NOCOPY Varchar2) ;


/*  Package Specification for the Document Management */

PROCEDURE Upload_File (	p_api_version		IN NUMBER,
			p_commit		IN VARCHAR2,
			p_called_from_forms	IN VARCHAR2,
			p_file_name 		IN VARCHAR2,
			p_category 		IN VARCHAR2,
			p_content_type 		IN VARCHAR2,
			p_version_label		IN VARCHAR2,
			p_file_data	 	IN BLOB,
			p_file_format 		IN VARCHAR2,
			p_source_lang		IN VARCHAR2,
			p_description		IN VARCHAR2,
			p_file_exists_action	IN VARCHAR2,
			p_submit_for_approval	IN VARCHAR2,
			p_attribute1 		IN VARCHAR2,
			p_attribute2 		IN VARCHAR2,
			p_attribute3 		IN VARCHAR2,
			p_attribute4 		IN VARCHAR2,
			p_attribute5 		IN VARCHAR2,
			p_attribute6 		IN VARCHAR2,
			p_attribute7 		IN VARCHAR2,
			p_attribute8 		IN VARCHAR2,
			p_attribute9 		IN VARCHAR2,
			p_attribute10 		IN VARCHAR2,
			p_created_by 		IN NUMBER,
			p_creation_date 	IN DATE,
			p_last_updated_by 	IN NUMBER,
			p_last_update_login 	IN NUMBER,
			p_last_update_date 	IN DATE,
			x_return_status 	OUT NOCOPY VARCHAR2,
			x_msg_data		OUT NOCOPY VARCHAR2);

-- Added for Melanie Grosser as a fix for bug# 3280763
-- This function is used to build a query of eRecords events based upon a
-- document attachment.  It return the id of the query so that the query can
-- be executed.
FUNCTION build_eres_query (p_entity_name IN  VARCHAR2,
                           p_pk1_value IN  VARCHAR2,
                           p_pk2_value IN  VARCHAR2,
                           p_pk3_value IN  VARCHAR2,
                           p_pk4_value IN  VARCHAR2,
                           p_pk5_value IN  VARCHAR2,
                           x_error_message OUT NOCOPY VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2
                           )  RETURN NUMBER;
-- Added for the erecord enhancement for GME. Details in bug 4328588
FUNCTION GET_ERECORD_ID
  ( p_event_name IN VARCHAR2
   ,p_event_key  IN VARCHAR2
  ) RETURN NUMBER	;

end gma_standard;

 

/
