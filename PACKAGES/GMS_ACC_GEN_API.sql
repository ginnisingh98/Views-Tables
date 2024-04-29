--------------------------------------------------------
--  DDL for Package GMS_ACC_GEN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_ACC_GEN_API" AUTHID CURRENT_USER as
/* $Header: gmsacgns.pls 115.11 2003/04/10 17:48:47 rnamburi ship $ */

FUNCTION GET_AWARD_ID (	x_exp_item_id 	in NUMBER
		   				,x_doc_type		IN VARCHAR2
                       	,x_cdl_line_num	in NUMBER
                       	,x_err_code      out NOCOPY NUMBER
                       	,x_err_msg       out NOCOPY varchar2) return NUMBER ;

FUNCTION GET_AWARD_ID (	x_award_set_id 		in NUMBER
                        ,x_attr_award_id 	in VARCHAR2
                        ,x_document_type 	in VARCHAR2 default NULL
                        ,x_err_code 		out NOCOPY NUMBER
                        ,x_err_msg 			out NOCOPY varchar2) return NUMBER;

FUNCTION GET_AWARD_ID (	itemtype		IN  VARCHAR2
                        , itemkey  		IN  VARCHAR2
                        , actid			IN	NUMBER
                        , funcmode		IN  VARCHAR2
                        , resultout		OUT	NOCOPY VARCHAR2
			  			, p_doc_type	IN VARCHAR2 DEFAULT NULL) return NUMBER;


FUNCTION GET_AWARD_ID ( x_award_set_id	IN NUMBER,
						x_doc_type		IN varchar2
						) return NUMBER ;

PRAGMA RESTRICT_REFERENCES( GET_AWARD_ID, WNDS,WNPS);


FUNCTION GET_AWARD_ID ( x_exp_enc_item_id  	IN NUMBER,
						x_doc_type      	IN varchar2,
						x_cdl_line			IN NUMBER
					   ) return NUMBER  ;

PRAGMA RESTRICT_REFERENCES( GET_AWARD_ID, WNDS,WNPS);

END GMS_ACC_GEN_API ;

 

/
