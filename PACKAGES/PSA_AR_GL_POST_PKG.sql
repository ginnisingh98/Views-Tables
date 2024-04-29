--------------------------------------------------------
--  DDL for Package PSA_AR_GL_POST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_AR_GL_POST_PKG" AUTHID CURRENT_USER AS
/* $Header: PSAMFG1S.pls 120.0 2005/06/20 19:31:53 vmedikon noship $ */

PROCEDURE transfer_to_gl(
			 p_start_date         IN DATE,
			 p_post_thru_date     IN DATE,
			 p_parent_req_id      IN NUMBER,
			 p_posting_control_id IN NUMBER,
                         p_summary_flag       IN VARCHAR2,
                         p_status_code       OUT NOCOPY VARCHAR2
			 );

END psa_ar_gl_post_pkg;

 

/
