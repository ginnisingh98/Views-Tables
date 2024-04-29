--------------------------------------------------------
--  DDL for Package Body AR_CMGT_CREDIT_CLASS_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CMGT_CREDIT_CLASS_CONC" AS
/* $Header: ARCMCLSB.pls 115.3 2002/11/22 19:59:21 bsarkar noship $ */

PROCEDURE update_credit_classification(
       errbuf                           IN OUT NOCOPY VARCHAR2,
       retcode                          IN OUT NOCOPY VARCHAR2,
       p_profile_class_id               IN VARCHAR2,
       p_credit_classification          IN VARCHAR2,
       p_update_flag                    IN VARCHAR2
  )IS

l_conc_request_id  NUMBER;
l_conc_program_id  NUMBER;
l_conc_login_id    NUMBER;
l_sql_statement    VARCHAR2(4000);

BEGIN
        arp_util.debug('AR_CMGT_CREDIT_CLASS_CONC.update_credit_classification (+)');

        l_conc_request_id  := fnd_global.conc_request_id;
        l_conc_program_id  := fnd_global.conc_program_id;
        l_conc_login_id    := fnd_global.user_id;

        IF NVL(p_update_flag,'N')= 'Y' THEN
	       l_sql_statement :=  'UPDATE hz_customer_profiles '||
           	           'SET  last_updated_by       = :1, '||
                       'last_update_date           = :2, '||
                       'program_id                 = :3, '||
                       'program_update_date        = :4, '||
                       'request_id                 = :5, '||
                       'credit_classification      = :6 '||
                       'WHERE profile_class_id     = :7 ';
           EXECUTE IMMEDIATE l_sql_statement using
                       l_conc_login_id, SYSDATE,l_conc_program_id,
                       TRUNC( SYSDATE ),l_conc_request_id,
                       p_credit_classification, p_profile_class_id;
       ELSIF NVL(p_update_flag,'N')= 'N' THEN
            l_sql_statement :=  'UPDATE hz_customer_profiles '||
           	           'SET  last_updated_by       = :1, '||
                       'last_update_date           = :2, '||
                       'program_id                 = :3, '||
                       'program_update_date        = :4, '||
                       'request_id                 = :5, '||
                       'credit_classification      = :6 '||
                       'WHERE profile_class_id     = :7 ' ||
                       'AND credit_classification IS NULL ';
             EXECUTE IMMEDIATE l_sql_statement using
                       l_conc_login_id, SYSDATE,l_conc_program_id,
                       TRUNC( SYSDATE ),l_conc_request_id,
                       p_credit_classification, p_profile_class_id;
       END IF;

       arp_util.debug('AR_CMGT_CREDIT_CLASS_CONC.update_credit_classification (-)');

EXCEPTION
 WHEN others THEN
   arp_util.debug('EXCEPTION : AR_CMGT_CREDIT_CLASS_CONC.update_credit_classification '||SQLERRM);
   app_exception.raise_exception;
END;

END AR_CMGT_CREDIT_CLASS_CONC;

/
