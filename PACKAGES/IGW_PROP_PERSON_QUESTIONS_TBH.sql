--------------------------------------------------------
--  DDL for Package IGW_PROP_PERSON_QUESTIONS_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_PERSON_QUESTIONS_TBH" AUTHID CURRENT_USER as
--$Header: igwtppqs.pls 115.3 2002/11/15 00:42:29 ashkumar ship $

PROCEDURE INSERT_ROW (
	x_rowid 		out NOCOPY 		VARCHAR2,
        p_proposal_id		in              NUMBER,
 	p_party_id              in 		NUMBER,
 	p_person_id             in 		NUMBER,
 	p_question_number       in              VARCHAR2,
	p_answer     		in		VARCHAR2,
 	p_explanation           in		VARCHAR2,
 	p_review_date           in              DATE,
	p_mode 			in 		VARCHAR2 default 'R',
	x_return_status         out NOCOPY  		VARCHAR2);
------------------------------------------------------------------------------------------

PROCEDURE UPDATE_ROW (
  	x_rowid 		in 		VARCHAR2,
	p_record_version_number in              NUMBER,
        p_proposal_id		in              NUMBER,
 	p_party_id              in 		NUMBER,
 	p_person_id             in 		NUMBER,
 	p_question_number       in              VARCHAR2,
	p_answer     		in		VARCHAR2,
 	p_explanation           in		VARCHAR2,
 	p_review_date           in              DATE,
	p_mode 			in 		VARCHAR2 default 'R',
	x_return_status         out NOCOPY  		VARCHAR2);
---------------------------------------------------------------------------------------------

PROCEDURE DELETE_ROW (
  x_rowid 		  	in  	VARCHAR2,
  p_record_version_number 	in 	NUMBER,
  x_return_status         	out NOCOPY  	VARCHAR2);


 END IGW_PROP_PERSON_QUESTIONS_TBH;

 

/
