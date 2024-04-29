--------------------------------------------------------
--  DDL for Package PSP_ROLLBACK_DIST_LINES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ROLLBACK_DIST_LINES" AUTHID CURRENT_USER AS
/*$Header: PSPRBDLS.pls 115.7 2002/11/19 07:39:52 lveerubh ship $*/

PROCEDURE DELETE_LINES(errbuf			OUT NOCOPY 	VARCHAR2,
		       retcode			OUT NOCOPY	VARCHAR2,
		       p_source_type		IN	VARCHAR2,
		       p_source_code		IN	VARCHAR2,
		       p_payroll_id		IN	NUMBER,
		       p_time_period_id		IN	NUMBER,
		       p_batch_name		IN	VARCHAR2,
		       p_business_group_id	IN	NUMBER,
		       p_set_of_books_id	IN	NUMBER);
END psp_rollback_dist_lines;

 

/
