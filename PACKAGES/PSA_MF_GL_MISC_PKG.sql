--------------------------------------------------------
--  DDL for Package PSA_MF_GL_MISC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_MF_GL_MISC_PKG" AUTHID CURRENT_USER AS
   /* $Header: PSAMFGMS.pls 120.3 2006/09/13 12:57:33 agovil ship $ */


   PROCEDURE misc_rct_to_gl
     (errbuf               OUT NOCOPY VARCHAR2,
      retcode              OUT NOCOPY VARCHAR2,
      p_set_of_books_id    IN  NUMBER,
      p_gl_date_from       IN  VARCHAR2,
      p_gl_date_to         IN  VARCHAR2,
      p_gl_posted_date     IN  VARCHAR2,
      p_parent_req_id      IN  NUMBER
--      x_posting_control_id OUT NOCOPY NUMBER DEFAULT NULL
      );
END psa_mf_gl_misc_pkg;

 

/
