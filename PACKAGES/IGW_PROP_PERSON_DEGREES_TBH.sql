--------------------------------------------------------
--  DDL for Package IGW_PROP_PERSON_DEGREES_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_PERSON_DEGREES_TBH" AUTHID CURRENT_USER as
--$Header: igwtppds.pls 115.1 2002/03/28 19:15:11 pkm ship    $


PROCEDURE UPDATE_ROW (
 X_ROWID 		     in 	VARCHAR2,
 P_PROPOSAL_ID               in	 	NUMBER,
 P_PERSON_DEGREE_ID          in		NUMBER,
 P_SHOW_FLAG 		     in         VARCHAR2,
 P_DEGREE_SEQUENCE	     in		NUMBER,
 P_MODE 		     in 	VARCHAR2 default 'R',
 P_RECORD_VERSION_NUMBER     in         NUMBER,
 X_RETURN_STATUS             out  	VARCHAR2);


 END IGW_PROP_PERSON_DEGREES_TBH;

 

/
