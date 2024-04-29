--------------------------------------------------------
--  DDL for Package Body PN_GL_TRANSFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_GL_TRANSFER" as
-- $Header: PNGLTRNB.pls 120.1 2005/11/28 01:53:36 appldev noship $


Procedure gl_transfer (p_journal_category        VARCHAR2 ,
                       P_selection_type          VARCHAR2 ,
                       P_batch_name              VARCHAR2,
                       p_from_date               DATE,
                       p_to_date                 DATE,
                       P_validate_account        VARCHAR2 ,
                       p_gl_transfer_mode        VARCHAR2 ,
                       p_submit_journal_import   VARCHAR2 ,
                       p_process_days            VARCHAR2,
                       p_debug_flag              VARCHAR2

                       )
AS
   l_sob_list              xla_gl_transfer_pkg.t_sob_list := xla_gl_transfer_pkg.t_sob_list();
   l_sob_info              gl_mc_info.t_ael_sob_info;
   i                       NUMBER := 0;
   l_request_id            NUMBER; -- Concurrent Request Id
   l_appl_id               NUMBER; -- Application Id.
   l_user_id               NUMBER; -- User Id.
   l_org_id                NUMBER;
   l_org_code              hr_operating_units.name%TYPE;
   l_je_category           xla_gl_transfer_pkg.t_ae_category;
   l_desc                               VARCHAR2(2000);
   l_set_of_books_id       NUMBER;

CURSOR c1 (l_sob_id NUMBER) IS
   SELECT set_of_books_id,
          name,
          currency_code
   FROM  gl_sets_of_books
   WHERE set_of_books_id =l_sob_id;
BEGIN
pnp_debug_pkg.log('at the start :');

   l_je_category(1)  := p_journal_category;

pnp_debug_pkg.log('Get Profile Information');
   l_request_id := FND_GLOBAL.conc_request_id;
   l_appl_id    := FND_GLOBAL.resp_appl_id;
   l_user_id    := FND_GLOBAL.user_id;
   l_org_id     := pn_mo_cache_utils.get_current_org_id;

   l_set_of_books_id := TO_NUMBER(pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID',l_org_id));

   FOR rec IN c1(l_set_of_books_id) LOOP
        i := i+1 ;
        l_sob_info(i).sob_id            := rec.set_of_books_id;
        l_sob_info(i).currency_code     := rec.currency_code;
        l_sob_info(i).sob_name          := rec.name;
   END LOOP; /* c1 loop */


pnp_debug_pkg.log('Populating l_sob_list table');

   FOR i IN l_sob_info.first..l_sob_info.last LOOP
        l_sob_list.EXTEND;
        l_sob_list(i).sob_id        := l_sob_info(i).sob_id;
        l_sob_list(i).sob_name      := l_sob_info(i).sob_name;
        l_sob_list(i).sob_curr_code := l_sob_info(i).currency_code;
   END LOOP;

pnp_debug_pkg.log('Getting Organization Name');
   IF l_org_id IS NOT NULL THEN
      SELECT name
        INTO l_org_code
        FROM hr_operating_units
        WHERE organization_id = l_org_id;
   END IF;

   IF p_batch_name is null THEN
        l_desc := null;
   ELSE
        l_desc := l_org_code || ' ' || p_batch_name;
   END IF;

pnp_debug_pkg.log('Calling Common Transfer API');

   xla_gl_transfer_pkg.xla_gl_transfer
     (
      p_application_id         => l_appl_id,
      p_user_id                => l_user_id,
      p_request_id             => l_request_id,
      p_org_id                 => l_org_id,
      p_program_name           => 'PN1',
      p_selection_type         => p_selection_type,
      p_sob_list               => l_sob_list,
      p_batch_name             => p_batch_name,
      p_source_doc_id          => NULL,
      p_source_document_table  => NULL,
      p_start_date             => P_from_date,
      p_end_date               => P_to_date,
      p_journal_category       => l_je_category,
      p_validate_account       => p_validate_account,
      p_gl_transfer_mode       => p_gl_transfer_mode,
      p_submit_journal_import  => p_submit_journal_import,
      p_summary_journal_entry  => 'N',
      p_process_days           => p_process_days,
      p_batch_desc             => l_desc,
      p_je_desc                => l_desc,
      p_je_line_desc           => NULL,
      p_debug_flag             => p_debug_flag
     );

pnp_debug_pkg.log('Calling Common Transfer API at end');

END gl_transfer;

------------------------------
-- End of Package
------------------------------
END PN_GL_TRANSFER;

/
