--------------------------------------------------------
--  DDL for Package IGW_PROP_NARRATIVES_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_NARRATIVES_TBH" AUTHID CURRENT_USER as
--$Header: igwtprns.pls 115.2 2002/11/15 00:39:25 ashkumar ship $

PROCEDURE INSERT_ROW (
 X_ROWID 		     out NOCOPY 	VARCHAR2,
 P_PROPOSAL_ID               in	 	NUMBER,
 P_MODULE_TITLE              in		VARCHAR2,
 P_MODULE_STATUS             in		VARCHAR2,
 P_CONTACT_NAME              in         VARCHAR2,
 P_PHONE_NUMBER              In         VARCHAR2,
 P_EMAIL_ADDRESS             in         VARCHAR2,
 P_COMMENTS                  in         VARCHAR2,
 P_MODE		             in 	VARCHAR2 default 'R',
 X_RETURN_STATUS             out NOCOPY  	VARCHAR2);


PROCEDURE UPDATE_ROW (
 X_ROWID 		     in 	VARCHAR2,
 P_PROPOSAL_ID               in	 	NUMBER,
 P_MODULE_ID                 in		NUMBER,
 P_MODULE_TITLE              in		VARCHAR2,
 P_MODULE_STATUS             in		VARCHAR2,
 P_CONTACT_NAME              in         VARCHAR2,
 P_PHONE_NUMBER              in         VARCHAR2,
 P_EMAIL_ADDRESS             in         VARCHAR2,
 P_COMMENTS                  in         VARCHAR2,
 P_MODE 		     in 	VARCHAR2 default 'R',
 P_RECORD_VERSION_NUMBER     in         NUMBER,
 X_RETURN_STATUS             out NOCOPY  	VARCHAR2);


PROCEDURE DELETE_ROW (
  x_rowid 		  	in 		VARCHAR2,
  p_record_version_number 	in 		NUMBER,
  x_return_status         	out NOCOPY  		VARCHAR2);


 END IGW_PROP_NARRATIVES_TBH;

 

/
