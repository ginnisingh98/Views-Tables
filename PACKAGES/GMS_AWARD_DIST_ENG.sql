--------------------------------------------------------
--  DDL for Package GMS_AWARD_DIST_ENG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_AWARD_DIST_ENG" AUTHID CURRENT_USER AS
-- $Header: gmsawdes.pls 115.6 2002/11/28 07:27:23 srkotwal ship $

 FUNCTION FUNC_BUFF_RECORDS( p_header_id NUMBER,
                             p_line_id   NUMBER,
                             p_document_type VARCHAR2,
			     p_dist_award_id NUMBER ) return NUMBER ;


	PROCEDURE PROC_DISTRIBUTE_RECORDS ( P_DOC_HEADER_ID 	IN  NUMBER,
					    P_DOC_TYPE    	IN  VARCHAR2,
					    P_RECS_PROCESSED 	OUT NOCOPY NUMBER,
					    P_RECS_REJECTED  	OUT NOCOPY NUMBER);

	PROCEDURE PRE_IMPORT(	P_transaction_source	IN	VARCHAR2,
				p_batch			IN	varchar2,
				p_user_id		IN	NUMBER,
				p_xface_id		IN	NUMBER ) ;
END GMS_AWARD_DIST_ENG;

 

/
