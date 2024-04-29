--------------------------------------------------------
--  DDL for Package Body JL_AR_RECUR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_AR_RECUR_PKG" AS
/* $Header: jlzzirib.pls 115.0 99/07/16 03:15:25 porting ship $ */
  pg_cursor1  integer := '';
  pg_user_id          number;
  pg_conc_login_id    number;
  pg_login_id         number;
  pg_prog_appl_id     number;
  pg_conc_program_id  number;

PROCEDURE insert_interim(
            p_customer_trx_id     IN  ra_recur_interim.customer_trx_id%type,
            p_trx_date            IN  DATE,
            p_term_due_date       IN  DATE,
            p_gl_date             IN  DATE,
            p_term_discount_date  IN  DATE,
            p_request_id          IN  ra_recur_interim.request_id%type,
            p_doc_sequence_value  IN  ra_recur_interim.doc_sequence_value%type,
            p_new_customer_trx_id IN  ra_recur_interim.new_customer_trx_id%type,
            p_batch_source_id     IN  ra_batch_sources.batch_source_id%type,
            p_trx_number_out      OUT ra_recur_interim.trx_number%type) IS

    l_country_code     VARCHAR2(2);
    l_trx_num_cursor   INTEGER;
    l_dummy            INTEGER;
    l_org_id           INTEGER;
    l_org_str          VARCHAR2(30);
    l_trx_number       ra_recur_interim.trx_number%TYPE;
    l_trx_date         DATE;

BEGIN
    arp_util.debug('arp_process_recur.insert_p()+');
    --
    -- Get Country Code
    --
    l_country_code := fnd_profile.value('JGZZ_COUNTRY_CODE');

    --
    -- Initialize
    --
    l_trx_date := p_trx_date;
    p_trx_number_out := '';

    --
    -- Get a New Transaction Number
    --
          SELECT MIN(org_id)
          INTO   l_org_id
          FROM   ar_system_parameters;

          IF (l_org_id IS NOT NULL) THEN
              l_org_str := '_'||to_char(l_org_id);
          ELSE
              l_org_str := NULL;
          END IF;

          l_trx_num_cursor := dbms_sql.open_cursor;

          dbms_sql.parse(l_trx_num_cursor,
                          'select ra_trx_number_' ||
                               REPLACE(p_batch_source_id, '-', 'N') ||
                          l_org_str||
                          '_s.nextval trx_number ' ||
                          'from ra_batch_sources ' ||
                          'where batch_source_id = ' ||
                                 p_batch_source_id ||
                         ' and auto_trx_numbering_flag = ''Y''',
                         dbms_sql.v7);

          dbms_sql.define_column(l_trx_num_cursor, 1, l_trx_number, 20);

          l_dummy := dbms_sql.execute_and_fetch(l_trx_num_cursor, TRUE);

          dbms_sql.column_value(l_trx_num_cursor, 1, l_trx_number);

          dbms_sql.close_cursor(l_trx_num_cursor);

     --
     -- Overwrite transaction number and date for Argentina
     --
     IF l_country_code = 'AR' THEN
       jl_ar_ar_prefix_trx_num.update_trx_number_date(
                      p_batch_source_id,
                      l_trx_number,
                      l_trx_date);
     END IF;

     --
     -- Insert trx information into ra_recur_interim
     --
     INSERT INTO ra_recur_interim
               (
                 customer_trx_id,
                 trx_number,
                 created_by,
                 creation_date,
                 last_updated_by,
                 last_update_date,
                 last_update_login,
                 trx_date,
                 term_due_date,
                 gl_date,
                 term_discount_date,
                 request_id,
                 doc_sequence_value,
                 new_customer_trx_id)
  VALUES
               (
                 p_customer_trx_id,
                 l_trx_number,
                 pg_user_id,
                 sysdate,
                 pg_user_id,
                 sysdate,
                 nvl(pg_conc_login_id,
                     pg_login_id),
                 l_trx_date,
                 p_term_due_date,
                 p_gl_date,
                 p_term_discount_date ,
                 p_request_id,
                 p_doc_sequence_value,
                 p_new_customer_trx_id);

   p_trx_number_out := l_trx_number;

   arp_util.debug('arp_process_recur.insert_p()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_process_recur.insert_p()');
        RAISE;

END;
BEGIN

  pg_user_id          := fnd_global.user_id;
  pg_conc_login_id    := fnd_global.conc_login_id;
  pg_login_id         := fnd_global.login_id;
  pg_prog_appl_id     := fnd_global.prog_appl_id;
  pg_conc_program_id  := fnd_global.conc_program_id;


END JL_AR_RECUR_PKG  ;

/
