--------------------------------------------------------
--  DDL for Package IGW_PROP_CHECKLIST_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_CHECKLIST_TBH" AUTHID CURRENT_USER as
--$Header: igwtpchs.pls 115.1 2002/03/28 19:15:03 pkm ship    $

PROCEDURE UPDATE_ROW (
 X_ROWID 		     in 	VARCHAR2,
 P_PROPOSAL_ID               in	 	NUMBER,
 P_DOCUMENT_TYPE_CODE        in		VARCHAR2,
 P_CHECKLIST_ORDER	     in         NUMBER,
 P_COMPLETE 		     in         VARCHAR2,
 P_NOT_APPLICABLE	     in		VARCHAR2,
 P_MODE 		     in 	VARCHAR2 default 'R',
 P_RECORD_VERSION_NUMBER     in         NUMBER,
 X_RETURN_STATUS             out  	VARCHAR2);


 END IGW_PROP_CHECKLIST_TBH;

 

/
