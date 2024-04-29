--------------------------------------------------------
--  DDL for Package Body ARP_BATCH_SOURCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_BATCH_SOURCE" AS
/* $Header: ARPLBSUB.pls 120.2.12010000.3 2009/11/24 08:55:41 pnallabo ship $  */

/*---------------------------------------------------------------------------+
 | PUBLIC PROCEDURE                                                          |
 |    create_trx_sequence                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function dynamically creates trx_number sequences for batch       |
 |    sources with automatic transaction numbering. It calls the             |
 |    bb_dist.create_sequence() procedure so that this will work in          |
 |    distributed environments.                                              |
 |                                                                           |
 | REQUIRES                                                                  |
 |   p_batch_source_id							     |
 |   P_last_number 							     |
 |                                                                           |
 | KNOWN BUGS                                                                |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | HISTORY                                                                   |
 |    9-DEC-94  Charlie Tomberg   Created.				     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
 PROCEDURE create_trx_sequence (
				 P_batch_source_id   IN   number,
				 P_org_id            IN   number default null,
				 P_last_number       IN   number
			       ) IS


  l_sequence_name  varchar2(1024);
  l_app_short_name varchar2(3);
  l_org_id         varchar2(30);
  l_sql_stmt       varchar2(2000);
  l_fnd_user       varchar2(30);
-- Start Bug 6010774, 6903507
  l_sequence_name_2  varchar2(1024);
  l_sql_stmt_2       varchar2(2000);
  l_sequence_name_3  varchar2(1024);
  l_sql_stmt_3       varchar2(2000);
  l_sequence_name_4  varchar2(1024);
  l_sql_stmt_4       varchar2(2000); /* bug 9131562 */
  l_country_code     varchar2(30);
-- End Bug 6010774, 6903507

BEGIN

  select min(ou.oracle_username)
  into   l_fnd_user
  from   FND_PRODUCT_INSTALLATIONS pi,
         FND_ORACLE_USERID ou
  where  ou.oracle_id = pi.oracle_id
  and    application_id = 0;

 /* SSA changes anukumar  select max(org_id)
  into   l_org_id
  from   ar_system_parameters;
 */
  IF (p_org_id is NULL) THEN
      l_sequence_name := 'RA_TRX_NUMBER_'||to_char(P_batch_source_id)||'_S';
      -- Start Bug 6010774, 6903507
      l_sequence_name_2 := 'JA_GUI_NUMBER_'||to_char(P_batch_source_id)||'_S';
      l_sequence_name_3 := 'JL_ZZ_TRX_NUM_'||to_char(P_batch_source_id)||'_S';
      -- End Bug 6010774, 6903507
      l_sequence_name_4 := 'JL_BR_TRX_NUM_'||to_char(P_batch_source_id)||'_S';
       /* bug 9131562 */
  ELSE
      l_sequence_name := 'RA_TRX_NUMBER_' || to_char(P_batch_source_id)||
                         '_' || p_org_id  || '_S';
      -- Start Bug 6010774, 6903507
      l_sequence_name_2 := 'JA_GUI_NUMBER_' || to_char(P_batch_source_id)||
                         '_' || p_org_id  || '_S';
      l_sequence_name_3 := 'JL_ZZ_TRX_NUM_' || to_char(P_batch_source_id)||
                         '_' || p_org_id  || '_S';
      -- End Bug 6010774, 6903507
      l_sequence_name_4 := 'JL_BR_TRX_NUM_' || to_char(P_batch_source_id)||
                           '_' || p_org_id  || '_S'; /* bug 9131562 */
  END IF;


  l_sql_stmt := 'create sequence '||l_sequence_name||
                ' minvalue 1 maxvalue 99999999999999999999  start with '||
                to_char(P_last_number + 1)||' cache 20';

  ad_ddl.do_ddl(l_fnd_user, 'AR', ad_ddl.create_sequence, l_sql_stmt, l_sequence_name);

  -- Start Bug 6010774, 6903507
  fnd_profile.get('JGZZ_COUNTRY_CODE', l_country_code);
  IF (l_country_code = 'TW') THEN
    l_sql_stmt_2 := 'create sequence '||l_sequence_name_2||
                ' minvalue 1 maxvalue 99999999999999999999  start with '||
                to_char(P_last_number + 1)||' nocache';

    ad_ddl.do_ddl(l_fnd_user, 'JA', ad_ddl.create_sequence, l_sql_stmt_2, l_sequence_name_2);
  ELSIF (l_country_code = 'BR') THEN
      l_sql_stmt_4 := 'create sequence '||l_sequence_name_4||
                  ' minvalue 1 maxvalue 99999999999999999999  start with '||
                   to_char(P_last_number + 1)||' nocache';
      /* bug 9131562 */
      ad_ddl.do_ddl(l_fnd_user, 'JL', ad_ddl.create_sequence, l_sql_stmt_4,l_sequence_name_4);
  ELSIF (l_country_code = 'AR') THEN
    l_sql_stmt_3 := 'create sequence '||l_sequence_name_3||
               ' minvalue 1 maxvalue 99999999999999999999  start with '||
                to_char(P_last_number + 1)||' nocache';

    ad_ddl.do_ddl(l_fnd_user, 'JL', ad_ddl.create_sequence, l_sql_stmt_3, l_sequence_name_3);
  END IF;
  -- End Bug 6010774, 6903507
END;	/* end of procedure create_trx_sequence */

END ARP_BATCH_SOURCE;

/
