--------------------------------------------------------
--  DDL for Package Body ARP_RECUR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_RECUR_PKG" AS
/* $Header: ARTIRECB.pls 120.4 2006/01/17 15:36:39 vcrisost ship $ */
  pg_cursor1  integer := '';
  pg_user_id          number;
  pg_conc_login_id    number;
  pg_login_id         number;
  pg_prog_appl_id     number;
  pg_conc_program_id  number;

PROCEDURE insert_p(
                    p_rec_rec         IN  ra_recur_interim%rowtype,
                    p_batch_source_id IN  ra_batch_sources.batch_source_id%type,
                    p_trx_number      OUT NOCOPY ra_recur_interim.trx_number%type
                  ) IS
    l_trx_num_cursor   integer;
    l_dummy            integer;
     l_org_id           integer;
    l_org_str          varchar2(30);
    l_trx_number       ra_recur_interim.trx_number%type;
    l_trx_str          VARCHAR2(1000);
BEGIN
    arp_util.debug('arp_process_recur.insert_p()+');
    p_trx_number := '';
     IF (p_rec_rec.trx_number is null)
     THEN
          SELECT MIN(org_id)
          INTO   l_org_id
          FROM   ar_system_parameters;

          IF (l_org_id IS NOT NULL) THEN
              l_org_str := '_'||to_char(l_org_id);
          ELSE
              l_org_str := NULL;
          END IF;

-- Bug 1185665 : change dbms_sql to use native dynamic sql
       l_trx_str :=  'select ra_trx_number_' ||
                               REPLACE(p_batch_source_id, '-', 'N') ||
                          l_org_str||
                          '_s.nextval trx_number ' ||
                          'from ra_batch_sources ' ||
                          'where batch_source_id = ' ||
                                 p_batch_source_id ||
                         ' and auto_trx_numbering_flag = ''Y''';

            EXECUTE IMMEDIATE l_trx_str
                INTO l_trx_number;

/*
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
*/
     ELSE
          l_trx_number := p_rec_rec.trx_number;
     END IF;
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
                 billing_date,
                 term_due_date,
                 gl_date,
                 term_discount_date,
                 request_id,
                 doc_sequence_value,
                 new_customer_trx_id)
  VALUES
               (
                 p_rec_rec.customer_trx_id,
                 l_trx_number,
                 pg_user_id,
                 sysdate,
                 pg_user_id,
                 sysdate,
                 nvl(pg_conc_login_id,
                     pg_login_id),
                 p_rec_rec.trx_date,
                 p_rec_rec.billing_date,
                 p_rec_rec.term_due_date,
                 p_rec_rec.gl_date,
                 p_rec_rec.term_discount_date ,
                 p_rec_rec.request_id,
                 p_rec_rec.doc_sequence_value,
                 p_rec_rec.new_customer_trx_id);

   p_trx_number := l_trx_number;

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


END ARP_RECUR_PKG  ;

/
