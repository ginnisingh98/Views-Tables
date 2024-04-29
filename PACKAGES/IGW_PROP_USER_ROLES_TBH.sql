--------------------------------------------------------
--  DDL for Package IGW_PROP_USER_ROLES_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_USER_ROLES_TBH" AUTHID CURRENT_USER as
--$Header: igwtpurs.pls 115.2 2002/11/15 00:47:22 ashkumar ship $

PROCEDURE INSERT_ROW (
	x_rowid 		out NOCOPY 		VARCHAR2,
        p_proposal_id		in              NUMBER,
 	p_user_id               in 		NUMBER,
 	p_role_id               in		NUMBER,
	p_mode 			in 		VARCHAR2 default 'R',
	x_return_status         out NOCOPY  		VARCHAR2);

PROCEDURE UPDATE_ROW (
  	x_rowid 		in 		VARCHAR2,
        p_proposal_id		in              NUMBER,
 	p_user_id               in 		NUMBER,
 	p_role_id               in		NUMBER,
	p_mode 			in 		VARCHAR2 default 'R',
	p_record_version_number in              NUMBER,
	x_return_status         out NOCOPY  		VARCHAR2);

PROCEDURE DELETE_ROW (
  x_rowid 		  	in 		VARCHAR2,
  p_record_version_number 	in 		NUMBER,
  x_return_status         	out NOCOPY  		VARCHAR2);

 END IGW_PROP_USER_ROLES_TBH;

 

/
