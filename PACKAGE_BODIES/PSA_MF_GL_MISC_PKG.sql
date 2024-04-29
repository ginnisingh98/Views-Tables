--------------------------------------------------------
--  DDL for Package Body PSA_MF_GL_MISC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_MF_GL_MISC_PKG" AS
     /* $Header: PSAMFGMB.pls 120.7 2006/09/13 13:02:06 agovil ship $ */

     l_batch_prefix VARCHAR2(30) := 'AR ';
     l_user_id  number(15)  := fnd_global.user_id;
     l_status VARCHAR2(30) := 'NEW';
     l_actual_flag VARCHAR2(1) := 'A';

     PROCEDURE misc_rct_to_gl
     (errbuf               OUT nocopy VARCHAR2,
      retcode              OUT nocopy VARCHAR2,
      p_set_of_books_id    IN  NUMBER,
      p_gl_date_from       IN  VARCHAR2,
      p_gl_date_to         IN  VARCHAR2,
      p_gl_posted_date     IN  VARCHAR2,
      p_parent_req_id      IN  NUMBER
--    x_posting_control_id OUT nocopy NUMBER
      ) IS
      BEGIN
        NULL;
      END  misc_rct_to_gl;

END psa_mf_gl_misc_pkg;

/
