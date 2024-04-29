--------------------------------------------------------
--  DDL for Package PSP_ENC_CREATE_LINES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ENC_CREATE_LINES" AUTHID CURRENT_USER AS
/*$Header: PSPENLNS.pls 120.2.12000000.1 2007/01/18 12:09:37 appldev noship $*/

/*****	Commented the following procedure for create and update multi thread enh.
  Procedure Create_Enc_Lines(
			errbuf 			OUT NOCOPY 	varchar2,
			retCode 		OUT NOCOPY 	varchar2,
  			p_Payroll_ID 		IN 	Number,
			p_Enc_Line_Type 	IN 	varchar2,
			p_business_group_id	IN	Number,
			p_set_of_books_id	IN	Number);
	End of comment for Create and Update multi thread enh.	*****/

PROCEDURE cel_init(p_payroll_action_id IN NUMBER);
PROCEDURE cel_range_code	(pactid	IN		NUMBER,
			sqlstr	OUT NOCOPY	VARCHAR2);
PROCEDURE cel_asg_action_code	(p_pactid	IN	NUMBER,
				start_asg	IN	NUMBER,
				end_asg		IN	NUMBER,
				p_chunk_num	IN	NUMBER);
PROCEDURE cel_archive	(p_payroll_action_id	IN	NUMBER,
			p_chunk_number		IN	NUMBER);
procedure cel_deinit(p_payroll_action_id in number);
PROCEDURE rollback_cel	(errbuf			OUT NOCOPY	VARCHAR2,
			retcode			OUT NOCOPY	VARCHAR2,
			p_payroll_action_id	IN		NUMBER,
			p_person_id1		IN		NUMBER,
			p_assignment_id1	IN		NUMBER,
			p_person_id2		IN		NUMBER,
			p_assignment_id2	IN		NUMBER,
			p_person_id3		IN		NUMBER,
			p_assignment_id3	IN		NUMBER,
			p_person_id4		IN		NUMBER,
			p_assignment_id4	IN		NUMBER,
			p_person_id5		IN		NUMBER,
			p_assignment_id5	IN		NUMBER);
END;

 

/
