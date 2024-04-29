--------------------------------------------------------
--  DDL for Package Body JL_AR_AR_PREFIX_TRX_NUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_AR_AR_PREFIX_TRX_NUM" AS
/*$Header: jlarrutb.pls 120.3 2005/04/07 18:24:17 appradha ship $*/

PROCEDURE update_trx_number_date (
  p_batch_source_id           IN     ra_customer_trx_all.batch_source_id%TYPE,
  p_trx_number                IN OUT NOCOPY ra_customer_trx_all.trx_number%TYPE,
  p_trx_date                  IN OUT NOCOPY ra_customer_trx_all.trx_date%TYPE )
IS

  l_trx_num_cursor          INTEGER;
  l_org_id                  NUMBER;
  l_count                   NUMBER;
  l_last_trx_date           DATE;
  l_document_letter         VARCHAR2(1);
  l_branch_number           VARCHAR2(4);
  l_imported_source_id      ra_batch_sources_all.batch_source_id%TYPE;
  l_auto_trx_numbering_flag ra_batch_sources_all.auto_trx_numbering_flag%TYPE;
  l_batch_source_type       ra_batch_sources_all.batch_source_type%TYPE;
  l_trx_number              ra_customer_trx_all.trx_number%TYPE;
  l_country_code            VARCHAR2(5);


BEGIN

   l_org_id := MO_GLOBAL.get_current_org_id;

   l_country_code := JG_ZZ_SHARED_PKG.GET_COUNTRY(l_org_id,null);
   IF l_country_code = 'AR' THEN

     --l_org_id := fnd_profile.value('ORG_ID');

     SELECT auto_trx_numbering_flag,
            batch_source_type,
            to_number(global_attribute1),
            substr(global_attribute2,1,4),
            substr(global_attribute3,1,1),
            to_date(global_attribute4,'YYYY/MM/DD HH24:MI:SS')
     INTO   l_auto_trx_numbering_flag,
            l_batch_source_type,
            l_imported_source_id,
            l_branch_number,
            l_document_letter,
            l_last_trx_date
     FROM   ra_batch_sources
     WHERE  batch_source_id = p_batch_source_id;

     IF l_batch_source_type = 'INV' THEN

        l_trx_num_cursor := dbms_sql.open_cursor;

        dbms_sql.parse(l_trx_num_cursor,
                       'select ra_trx_number_' ||
                       to_char(l_imported_source_id) ||
                       '_' ||
                       to_char(l_org_id)||
                       '_s.nextval trx_number ' ||
                       'from dual ',
                       dbms_sql.NATIVE);

        dbms_sql.define_column(l_trx_num_cursor, 1, l_trx_number, 20);

        l_count := dbms_sql.execute_and_fetch(l_trx_num_cursor,TRUE);

        dbms_sql.column_value(l_trx_num_cursor, 1, l_trx_number);

        dbms_sql.close_cursor(l_trx_num_cursor);

        SELECT substr(global_attribute2,1,4),
               substr(global_attribute3,1,1),
               to_date(global_attribute4,'YYYY/MM/DD HH24:MI:SS')
        INTO   l_branch_number,
               l_document_letter,
               l_last_trx_date
        FROM   ra_batch_sources
        WHERE  batch_source_id = l_imported_source_id;

        p_trx_number := l_document_letter || '-' ||
                        l_branch_number ||  '-' ||
                        lpad(l_trx_number,8,'0');
        p_trx_date := l_last_trx_date;

     ELSE

       IF l_auto_trx_numbering_flag = 'Y' THEN

         p_trx_number := l_document_letter ||  '-' ||
                        l_branch_number ||  '-' ||
                        lpad(p_trx_number,8,'0');
         p_trx_date := l_last_trx_date;

       END IF;

     END IF;

   END IF;

END update_trx_number_date;

END JL_AR_AR_PREFIX_TRX_NUM;

/
