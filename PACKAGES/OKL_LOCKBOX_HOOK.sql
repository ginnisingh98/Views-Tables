--------------------------------------------------------
--  DDL for Package OKL_LOCKBOX_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LOCKBOX_HOOK" AUTHID CURRENT_USER AS
/*$Header: OKLRLBHS.pls 115.2 2002/12/18 12:48:23 kjinger noship $*/
--
PROCEDURE proc_before_validation(out_errorbuf OUT NOCOPY VARCHAR2,
                                 out_errorcode OUT NOCOPY VARCHAR2,
                                 in_trans_req_id IN VARCHAR2,
                                 out_insert_records OUT NOCOPY VARCHAR2);
--
PROCEDURE proc_after_validation(out_errorbuf OUT NOCOPY VARCHAR2,
                                 out_errorcode OUT NOCOPY VARCHAR2,
                                 in_trans_req_id IN VARCHAR2,
                                 out_insert_records OUT NOCOPY VARCHAR2);
--
PROCEDURE proc_after_second_validation(out_errorbuf OUT NOCOPY VARCHAR2,
                                 out_errorcode OUT NOCOPY VARCHAR2,
                                 in_trans_req_id IN VARCHAR2);
--
PROCEDURE cursor_for_matching_rule(p_matching_option IN VARCHAR2,
                                   p_cursor_string OUT NOCOPY VARCHAR2);
--
END okl_lockbox_hook;

 

/
