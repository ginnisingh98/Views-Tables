--------------------------------------------------------
--  DDL for Package Body HZ_IMP_DQM_STAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_IMP_DQM_STAGE" AS
/* $Header: ARHDISTB.pls 120.22 2006/07/21 06:26:32 rarajend noship $ */

/*
Developer Notes:

*/
TYPE coltab IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
l_trans_list coltab;

TYPE StageImpContactCurTyp IS REF CURSOR;
G_PKG_NAME      CONSTANT VARCHAR2(30)    := 'HZ_IMP_DQM_STAGE' ;


NO_STD_CHK      CONSTANT INTEGER := 1;
DO_STD_CHK      CONSTANT INTEGER := 2;
-- set to false during checkin.
is_test BOOLEAN := false;

PROCEDURE l(str VARCHAR2) IS
BEGIN
  HZ_GEN_PLSQL.add_line(str);
END;

FUNCTION using_allow_cust(
    p_match_rule_id     IN NUMBER,
    p_et_name IN VARCHAR2,
    p_attr_name IN VARCHAR2
    ) RETURN VARCHAR2 ;

PROCEDURE chk_et_req(p_entity_name IN VARCHAR2,
                     p_rule_id IN NUMBER,
                     x_bool    IN OUT NOCOPY VARCHAR2);

FUNCTION chk_is_std(p_attribute_name IN VARCHAR2
) RETURN VARCHAR2 ;

PROCEDURE get_table_name (
 p_entity_name  IN VARCHAR2,
 p_table_name IN OUT NOCOPY VARCHAR2
 );

PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE
);

/**
* Procedure to write a message to the out file
**/
PROCEDURE out(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
  IF message = 'NEWLINE' THEN
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
  ELSIF (newline) THEN
    FND_FILE.put_line(fnd_file.output,message);
  ELSE
    FND_FILE.put(fnd_file.output,message);
  END IF;
END out;


-----------------------------------------------------------------------
-- Function to fetch messages of the stack and log the error
-----------------------------------------------------------------------
PROCEDURE logerror(SQLERRM VARCHAR2 DEFAULT NULL)
IS
  l_msg_data VARCHAR2(2000);
BEGIN
  FND_MSG_PUB.Reset;
  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    l_msg_data := substr(l_msg_data || FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ), 1, 2000) ;
  END LOOP;
  IF (SQLERRM IS NOT NULL) THEN
    l_msg_data := substr(l_msg_data || SQLERRM, 1, 2000);
  END IF;
  log(l_msg_data);
END;


/**
* Procedure to write a message to the out and log files
**/
PROCEDURE outandlog(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
  out(message, newline);
  log(message);
END outandlog;

FUNCTION using_allow_cust(
    p_match_rule_id     IN NUMBER,
    p_et_name IN VARCHAR2,
    p_attr_name IN VARCHAR2
) RETURN VARCHAR2
IS
    using_allow_cust VARCHAR2(1) := 'N';
    CURSOR c1 is    select 'Y'
         from hz_match_rule_primary a
         where match_rule_id = p_match_rule_id
         and a.attribute_id in (
             select attribute_id
             from hz_trans_attributes_b
             where entity_name = p_et_name
             and attribute_name = p_attr_name)
         union
             select 'Y'
             from hz_match_rule_secondary a
             where match_rule_id = p_match_rule_id
             and a.attribute_id in (
                 select attribute_id
                 from hz_trans_attributes_b
                 where entity_name = p_et_name
                 and attribute_name = p_attr_name);

    l_procedure_name VARCHAR2(30) := '.USING_ALLOW_CUST' ;
    BEGIN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
     END IF;
       OPEN c1;
         LOOP
         FETCH c1 into using_allow_cust;
         EXIT WHEN c1%NOTFOUND;
        END LOOP;
        CLOSE c1;
    RETURN using_allow_cust;
    EXCEPTION WHEN OTHERS THEN
        using_allow_cust := 'N';
    END using_allow_cust;

FUNCTION get_os (p_batch_id IN NUMBER
) RETURN VARCHAR2
IS
 l_os VARCHAR2(30) ;
BEGIN
    select original_system into l_os from hz_imp_batch_summary where batch_id = p_batch_id;
    IF (l_os IS NULL) THEN
        log(' hz_imp_batch_summary.original_system has return null. This indicates an error during batch setup.');
    END IF;
    RETURN l_os;
    EXCEPTION WHEN others THEN
        RAISE FND_API.G_EXC_ERROR;
END get_os;

PROCEDURE POP_INTERFACE_SEARCH_TAB (
    p_batch_id				 IN   NUMBER,
    p_match_rule_id          IN      NUMBER,
    p_from_osr                       IN   VARCHAR2,
    p_to_osr                         IN   VARCHAR2,
    x_return_status                    OUT NOCOPY    VARCHAR2,
    x_msg_count                        OUT NOCOPY    NUMBER,
    x_msg_data                         OUT NOCOPY    VARCHAR2
  ) IS
l_sql_stmt VARCHAR2(255) ;
  BEGIN
     x_return_status := fnd_api.g_ret_sts_success;
     hz_trans_pkg.set_bulk_dup_id ;
 --    execute immediate ' begin HZ_IMP_MATCH_RULE_'||p_match_rule_id||'.pop_parties_int('|| p_batch_id ||',' || p_from_osr ||','|| p_to_osr||'); end;';
     l_sql_stmt :=   ' begin HZ_IMP_MATCH_RULE_'||p_match_rule_id||'.pop_parties_int(:1, :2, :3); end;';
     execute immediate l_sql_stmt using p_batch_id, p_from_osr, p_to_osr;
--     execute immediate ' begin HZ_IMP_MATCH_RULE_'||p_match_rule_id||'.pop_party_sites_int('|| p_batch_id ||',' || p_from_osr ||','|| p_to_osr||'); end;';
     l_sql_stmt :=   ' begin HZ_IMP_MATCH_RULE_'||p_match_rule_id||'.pop_party_sites_int(:1, :2,:3); end;';
     execute immediate l_sql_stmt using p_batch_id, p_from_osr, p_to_osr;
--     execute immediate ' begin HZ_IMP_MATCH_RULE_'||p_match_rule_id||'.pop_cp_int('|| p_batch_id ||',' || p_from_osr ||','|| p_to_osr||'); end;';
     l_sql_stmt :=   ' begin HZ_IMP_MATCH_RULE_'||p_match_rule_id||'.pop_cp_int(:1, :2,:3); end;';
     execute immediate l_sql_stmt using p_batch_id, p_from_osr, p_to_osr;
--     execute immediate ' begin HZ_IMP_MATCH_RULE_'||p_match_rule_id||'.pop_contacts_int('|| p_batch_id ||',' || p_from_osr ||','|| p_to_osr||'); end;';
     l_sql_stmt :=   ' begin HZ_IMP_MATCH_RULE_'||p_match_rule_id||'.pop_contacts_int(:1, :2,:3); end;';
     execute immediate l_sql_stmt using p_batch_id, p_from_osr, p_to_osr;

   EXCEPTION WHEN others THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
         FND_MESSAGE.SET_TOKEN('PROC' ,'POP_INTERFACE_SEARCH_TAB');
         FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
         FND_MSG_PUB.ADD;
         fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                  p_count => x_msg_count,
                  p_data  => x_msg_data);
  END POP_INTERFACE_SEARCH_TAB;

 PROCEDURE POP_INT_TCA_SEARCH_TAB (
     p_batch_id				 IN   NUMBER,
     p_match_rule_id         IN      NUMBER,
     p_from_osr                       IN   VARCHAR2,
     p_to_osr                         IN   VARCHAR2 ,
     p_batch_mode_flag                 IN VARCHAR2,
     x_return_status                    OUT NOCOPY    VARCHAR2,
     x_msg_count                        OUT NOCOPY    NUMBER,
     x_msg_data                         OUT NOCOPY    VARCHAR2
   ) IS

   l_a VARCHAR2(1);
   l_c NUMBER;
   l_d NUMBER;
   l_e VARCHAR2(1);
   l_sql_stmt VARCHAR2(255); -- ????
   BEGIN
   log(' Start of staging for interface_tca POP_INT_TCA_SEARCH_TAB');
   log(' p_batch_id = ' || p_batch_id);
   log(' p_match_rule_id = '|| p_match_rule_id);
   log(' p_from_osr = '|| p_from_osr);
   log(' p_to_osr = ' || p_to_osr);
   log(' p_batch_mode_flag = '|| p_batch_mode_flag);

   x_return_status := fnd_api.g_ret_sts_success;
   hz_trans_pkg.set_bulk_dup_id ;
   select batch_dedup_flag, batch_dedup_match_rule_id, registry_dedup_match_rule_id, addr_val_flag
   into l_a, l_c, l_d, l_e
   from hz_imp_batch_summary
   where batch_id = p_batch_id;
   log ('l_a = '|| l_a);
   log ('l_c = '|| l_c);
   log ('l_d = '|| l_d);
   log ('l_e = '|| l_e);
    /*
    l_a = was interface dedup run
    l_b is interface_tca required
    l_c = interface match rule id
    l_d = interface_tca match rule id
    l_e = address validation flag
    */
       IF ((l_a = 'Y') AND (l_c = l_d) ) THEN
           IF (l_e = 'Y') THEN
                   log(' Restage party_sites entity due to address validation');
--                 execute immediate ' begin HZ_IMP_MATCH_RULE_'||p_match_rule_id||'.pop_party_sites('|| p_batch_id ||',' || p_from_osr ||','|| p_to_osr||'); end;';
                   l_sql_stmt := ' begin HZ_IMP_MATCH_RULE_'||p_match_rule_id||'.pop_party_sites(:1 ,:2, :3, :4); end;';
                   execute immediate l_sql_stmt using p_batch_id, p_from_osr, p_to_osr, p_batch_mode_flag;
            ELSE
                -- - Update IDs on PARTY SITES
                log( ' Update party_sites since address validation was not run');

                update HZ_SRCH_PSITES c set party_site_id = ( select b.party_site_id
                from hz_imp_addresses_int a, HZ_IMP_ADDRESSES_SG b
                where a.rowid = b.int_row_id
                and c.int_row_id = a.rowid
                and a.batch_id = p_batch_id
                and a.batch_id = c.batch_id
                and b.action_flag = 'I'  ),
                party_id = ( select b.party_id
                from hz_imp_addresses_int a, HZ_IMP_ADDRESSES_SG b
                where a.rowid = b.int_row_id
                and c.int_row_id = a.rowid
                and a.batch_id = p_batch_id
                and a.batch_id = c.batch_id
                and b.action_flag = 'I'
                ) where batch_id = p_batch_id;
             END IF;
                -- - Update IDs on PARTY, CONTACTS, CONTACT_POINTS
             log( ' Update party as same match rule being used');
             update hz_srch_parties c set party_id = ( select b.party_id
             from hz_imp_parties_int a, hz_imp_parties_sg b
             where a.rowid = b.int_row_id
             and c.int_row_id = a.rowid
             and a.batch_id = p_batch_id
             and a.batch_id = c.batch_id
             and b.action_flag = 'I' );
             log( ' Update contacts as same match rule being used');
             update HZ_SRCH_CONTACTS c set party_id = ( select b.sub_id
             from HZ_IMP_CONTACTS_INT a, HZ_IMP_CONTACTS_SG b
             where a.rowid = b.int_row_id
             and c.int_row_id = a.rowid
             and a.batch_id = p_batch_id
             and a.batch_id = c.batch_id
             and b.action_flag = 'I' ),
             org_contact_id = (select b.contact_id
             from HZ_IMP_CONTACTS_INT a, HZ_IMP_CONTACTS_SG b
             where a.rowid = b.int_row_id
             and a.batch_id = p_batch_id
             and a.batch_id = c.batch_id
             and b.action_flag = 'I' );
             log( ' Update contact_points as same match rule being used');
             update HZ_SRCH_CPTS c set party_id = ( select b.party_id
             from HZ_IMP_CONTACTPTS_INT a, HZ_IMP_CONTACTPTS_SG b
             where a.rowid = b.int_row_id
             and c.int_row_id = a.rowid
             and a.batch_id = p_batch_id
             and a.batch_id = c.batch_id
             and b.action_flag = 'I' ),
             party_site_id = ( select b.party_site_id
             from HZ_IMP_CONTACTPTS_INT a, HZ_IMP_CONTACTPTS_SG b
             where a.rowid = b.int_row_id
             and c.int_row_id = a.rowid
             and a.batch_id = p_batch_id
             and a.batch_id = c.batch_id
             and b.action_flag = 'I' ),
             contact_point_id = ( select b.contact_point_id
             from HZ_IMP_CONTACTPTS_INT a, HZ_IMP_CONTACTPTS_SG b
             where a.rowid = b.int_row_id
             and c.int_row_id = a.rowid
             and a.batch_id = p_batch_id
             and a.batch_id = c.batch_id
             and b.action_flag = 'I' );
        ELSE
             log(' Restage all four entities ');
--             execute immediate ' begin HZ_IMP_MATCH_RULE_'||p_match_rule_id||'.pop_parties('|| p_batch_id ||',' || p_from_osr ||','|| p_to_osr||','||p_batch_mode_flag||'); end;';
             l_sql_stmt := ' begin HZ_IMP_MATCH_RULE_'||p_match_rule_id||'.pop_parties(:1 ,:2, :3, :4); end;';
             execute immediate l_sql_stmt using p_batch_id, p_from_osr, p_to_osr, p_batch_mode_flag;
--             execute immediate ' begin HZ_IMP_MATCH_RULE_'||p_match_rule_id||'.pop_party_sites('|| p_batch_id ||',' || p_from_osr ||','|| p_to_osr||'); end;';
             l_sql_stmt := ' begin HZ_IMP_MATCH_RULE_'||p_match_rule_id||'.pop_party_sites(:1 ,:2, :3, :4); end;';
             execute immediate l_sql_stmt using p_batch_id, p_from_osr, p_to_osr, p_batch_mode_flag;
--             execute immediate ' begin HZ_IMP_MATCH_RULE_'||p_match_rule_id||'.pop_cp('|| p_batch_id ||',' || p_from_osr ||','|| p_to_osr||'); end;';
             l_sql_stmt := ' begin HZ_IMP_MATCH_RULE_'||p_match_rule_id||'.pop_cp(:1 ,:2, :3, :4); end;';
             execute immediate l_sql_stmt using p_batch_id, p_from_osr, p_to_osr, p_batch_mode_flag;
--             execute immediate ' begin HZ_IMP_MATCH_RULE_'||p_match_rule_id||'.pop_contacts('|| p_batch_id ||',' || p_from_osr ||','|| p_to_osr||'); end;';
             l_sql_stmt := ' begin HZ_IMP_MATCH_RULE_'||p_match_rule_id||'.pop_contacts(:1 ,:2, :3, :4); end;';
             execute immediate l_sql_stmt using p_batch_id, p_from_osr, p_to_osr, p_batch_mode_flag;
         END IF;
   log('End of staging for interface_tca POP_INT_TCA_SEARCH_TAB');
   EXCEPTION WHEN others THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
         FND_MESSAGE.SET_TOKEN('PROC' ,'POP_INT_TCA_SEARCH_TAB');
         FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
         FND_MSG_PUB.ADD;
         fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
               p_count => x_msg_count,
               p_data  => x_msg_data);
   END POP_INT_TCA_SEARCH_TAB;

FUNCTION has_trx_context(proc VARCHAR2) RETURN BOOLEAN IS

  l_sql VARCHAR2(255);
  l_entity VARCHAR2(255);
  l_procedure VARCHAR2(255);
  l_attribute VARCHAR2(255);
  c NUMBER;
  n NUMBER;
  l_custom BOOLEAN;

BEGIN
  c := dbms_sql.open_cursor;
  l_sql := 'select ' || proc ||
           '(:attrval,:lang,:attr,:entity,:ctx) from dual';
  dbms_sql.parse(c,l_sql,2);
  DBMS_SQL.BIND_VARIABLE(c,':attrval','x');
  DBMS_SQL.BIND_VARIABLE(c,':lang','x');
  DBMS_SQL.BIND_VARIABLE(c,':attr','x');
  DBMS_SQL.BIND_VARIABLE(c,':entity','x');
  DBMS_SQL.BIND_VARIABLE(c,':ctx','x');
  n:=DBMS_SQL.execute(c);
  dbms_sql.close_cursor(c);
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    dbms_sql.close_cursor(c);
    RETURN FALSE;
END;

FUNCTION chk_for_trunc (
    p_table_name    IN VARCHAR2,
    p_batch_id      IN  NUMBER
) RETURN VARCHAR2 IS
    l_procedure_name VARCHAR2(30) := '.CHK_FOR_TRUNC' ;
    l_bool VARCHAR2(1) := 'N';
    l_sql_stmt VARCHAR2(255);
    l_count NUMBER := 0;
BEGIN
    l_sql_stmt := ' select /*+ INDEX(a) */ count(batch_id) from ' || p_table_name || ' a where batch_id <> :1 and rownum < 2 ';
    execute immediate l_sql_stmt into l_count using p_batch_id;
    IF (l_count <= 0) THEN
      l_bool := 'Y';
    ELSE
      l_bool := 'N';
    END IF;
    RETURN l_bool;
    EXCEPTION WHEN OTHERS THEN
        l_bool := 'N';
        RETURN l_bool;
END chk_for_trunc;

PROCEDURE chk_table (
    p_table_name    IN VARCHAR2,
    p_batch_id      IN  NUMBER
) IS
    l_procedure_name VARCHAR2(30) := '.CHK_TABLE' ;
    l_bool VARCHAR2(1) := 'N';
    l_owner VARCHAR2(30);
    l_sql_stmt VARCHAR2(255);
BEGIN
    l_bool := chk_for_trunc(p_table_name, p_batch_id);
    l_sql_stmt :=  ' delete from ' ||  p_table_name || ' where batch_id = :1 ' ;
    IF (l_bool = 'Y') THEN
      BEGIN
          l_owner := get_owner_name(p_table_name, 'TABLE');
          log ('Attempting to truncate table ' || p_table_name);
          execute immediate ' truncate table ' || l_owner || '.' || p_table_name;
      EXCEPTION WHEN OTHERS THEN
          log(SQLERRM);
          log('Exception thrown possibly due to lock on table. Unable to truncate hence deleting data for batch_id ' || p_batch_id ||'Deletion in progress...');
          execute immediate l_sql_stmt using p_batch_id;
      END;
    ELSE
          execute immediate l_sql_stmt using p_batch_id;
    END IF;
    EXCEPTION WHEN OTHERS THEN
        log(SQLERRM);
        RAISE FND_API.G_EXC_ERROR;
END chk_table;

PROCEDURE chk_srch_tab ( p_batch_id IN NUMBER
) IS
  l_owner VARCHAR2(255);
  l_table_name VARCHAR2(30);
  l_sql_stmt VARCHAR2(255);
BEGIN
    chk_table('HZ_SRCH_PARTIES', p_batch_id);
    chk_table('HZ_SRCH_PSITES', p_batch_id);
    chk_table('HZ_SRCH_CONTACTS', p_batch_id);
    chk_table('HZ_SRCH_CPTS', p_batch_id);
    EXCEPTION WHEN OTHERS THEN
        RAISE FND_API.G_EXC_ERROR;
END chk_srch_tab;

PROCEDURE dqm_post_imp_cleanup (
    p_batch_id  IN NUMBER,
     x_return_status                    OUT NOCOPY    VARCHAR2,
     x_msg_count                        OUT NOCOPY    NUMBER,
     x_msg_data                         OUT NOCOPY    VARCHAR2
) IS
    l_procedure_name VARCHAR2(30) := '.DQM_POST_IMP_CLEANUP' ;
BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    log(' HZ_DQM_DUP_ID_PKG.final_process_int_tca_dup_id(' || p_batch_id || '); +');
    HZ_DQM_DUP_ID_PKG.final_process_int_tca_dup_id(p_batch_id);
    log(' HZ_DQM_DUP_ID_PKG.final_process_int_tca_dup_id(' || p_batch_id || '); -');
    chk_srch_tab(p_batch_id);
    delete from HZ_INT_DUP_RESULTS where batch_id = p_batch_id;
    EXCEPTION WHEN OTHERS THEN
         log(SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
         FND_MESSAGE.SET_TOKEN('PROC' ,'DQM_POST_IMP_CLEANUP');
         FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
         FND_MSG_PUB.ADD;
         fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
               p_count => x_msg_count,
               p_data  => x_msg_data);
END dqm_post_imp_cleanup;

PROCEDURE del_from_table (p_table_name  IN VARCHAR2,
    p_batch_id IN NUMBER) IS

l_sql_stmt VARCHAR2(255);
l_owner VARCHAR2(30);
BEGIN
    l_owner := get_owner_name(p_table_name, 'TABLE');
    l_sql_stmt := ' delete from ' ||l_owner || '.' || p_table_name || ' where batch_id = :1 ';
    execute immediate l_sql_stmt using p_batch_id;
    EXCEPTION WHEN OTHERS THEN
        log(SQLERRM);
        RAISE FND_API.G_EXC_ERROR;
END del_from_table;



PROCEDURE dqm_pre_imp_cleanup (
    p_batch_id  IN NUMBER,
    x_return_status                    OUT NOCOPY    VARCHAR2,
    x_msg_count                        OUT NOCOPY    NUMBER,
    x_msg_data                         OUT NOCOPY    VARCHAR2
) IS
    l_procedure_name VARCHAR2(30) := '.DQM_PRE_IMP_CLEANUP' ;
    l_owner VARCHAR2(255);
    l_table_name VARCHAR2(30);
    l_sql_stmt VARCHAR2(255);
BEGIN
     x_return_status := fnd_api.g_ret_sts_success;
    chk_srch_tab(p_batch_id);
    delete from HZ_IMP_INT_DEDUP_RESULTS where batch_id = p_batch_id;
    delete from HZ_IMP_DUP_PARTIES where batch_id = p_batch_id;
    delete from HZ_IMP_DUP_DETAILS where batch_id = p_batch_id;
    EXCEPTION WHEN OTHERS THEN
         log(SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
         FND_MESSAGE.SET_TOKEN('PROC' ,'DQM_PRE_IMP_CLEANUP');
         FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
         FND_MSG_PUB.ADD;
         fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
               p_count => x_msg_count,
               p_data  => x_msg_data);
END dqm_pre_imp_cleanup;

FUNCTION get_owner_name (
    p_object_name IN  VARCHAR2,
    p_object_type IN VARCHAR2
) RETURN VARCHAR2 IS
    l_owner VARCHAR2(30);
    l_status VARCHAR2(255);
    l_owner1 VARCHAR2(255);
    l_temp VARCHAR2(255);
BEGIN
     IF (fnd_installation.GET_APP_INFO('AR',l_status,l_temp,l_owner1)) THEN
         select owner into l_owner from sys.all_objects
         where object_name = p_object_name  and OBJECT_TYPE =  p_object_type and owner = l_owner1;
     END IF;
         RETURN l_owner;
    EXCEPTION WHEN OTHERS THEN
       log(SQLERRM);
       RAISE FND_API.G_EXC_ERROR;
END get_owner_name;

/*
PROCEDURE del_existing_rec(p_et_name   IN VARCHAR,
     p_batch_id IN NUMBER
) IS

BEGIN
    IF (p_et_name = 'PSITES') THEN
        delete from hz_srch_psites a
        where a.party_os || a.party_osr in (
        select a.party_os || a.party_osr
        from HZ_IMP_ADDRESSES_SG b
        where a.party_os = b.party_orig_system
        and a.party_osr = b.party_orig_system_reference
        and b.action_flag = 'U'
        and a.batch_id = p_batch_id);
     ELSIF (p_et_name = 'CONTACTS') THEN
        delete from HZ_SRCH_CONTACTS c where c.contact_os ||c.contact_osr || c.batch_id in(
        select b.contact_orig_system || b.contact_orig_system_reference || b.batch_id
        from HZ_IMP_CONTACTS_SG a, HZ_IMP_CONTACTS_INT b
        where a.int_row_id = b.rowid
        and a.action_flag = 'U'
        and b.contact_orig_system = c.contact_os
        and b.contact_orig_system_reference = c.contact_osr
         and b.batch_id = p_batch_id);
     ELSIF (p_et_name = 'CP') THEN
        delete from HZ_SRCH_CPTS a
        where a.party_os || a.party_osr in (
        select a.party_os || a.party_osr
        from HZ_IMP_CONTACTPTS_SG b
        where a.party_os = b.party_orig_system
        and a.party_osr = b.party_orig_system_reference
        and b.action_flag = 'U'
        and a.batch_id = p_batch_id);
     END IF;
END del_existing_rec;
*/

PROCEDURE dqm_inter_imp_cleanup (
     p_batch_id  IN NUMBER,
     x_return_status                    OUT NOCOPY    VARCHAR2,
     x_msg_count                        OUT NOCOPY    NUMBER,
     x_msg_data                         OUT NOCOPY    VARCHAR2
) IS
    l_procedure_name VARCHAR2(30) := '.DQM_INTER_IMP_CLEANUP' ;
    /*
    l_a = was interface dedup run
    l_b is interface_tca required
    l_c = interface match rule id
    l_d = interface_tca match rule id
    l_e = address validation flag
    */
    l_a VARCHAR2(1);
    l_b VARCHAR2(1);
    l_c NUMBER;
    l_d NUMBER;
    l_e VARCHAR2(1);
    l_owner VARCHAR2(255);
    l_table_name VARCHAR2(30);
    l_status VARCHAR2(255);
    l_owner1 VARCHAR2(255);
    l_temp VARCHAR2(255);
	l_sqlstr VARCHAR2(4000);

BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    select batch_dedup_flag, registry_dedup_flag, batch_dedup_match_rule_id, registry_dedup_match_rule_id, addr_val_flag
    into l_a, l_b, l_c, l_d, l_e
    from hz_imp_batch_summary
    where batch_id = p_batch_id;


    IF (l_b = 'Y') THEN
        IF ((l_a = 'Y') AND (l_c = l_d) ) THEN
            IF (l_e = 'Y') THEN
                   IF (fnd_installation.GET_APP_INFO('AR',l_status,l_temp,l_owner1)) THEN
                    /*select owner into l_owner from sys.all_objects
                    where object_name = 'HZ_SRCH_PSITES' and OBJECT_TYPE = 'TABLE' and owner = l_owner1 ;*/
                    --Bug:4956084
                    l_sqlstr := 'select owner from sys.all_tables
                    where table_name = ''HZ_SRCH_PSITES'' and owner = :p_owner ';
					execute immediate l_sqlstr into l_owner USING l_owner1 ;
                    l_table_name := l_owner || '.HZ_SRCH_PSITES';
                    chk_table(l_table_name, p_batch_id);
                   END IF;
            END IF;
        ELSIF (l_a = 'Y') THEN
            chk_srch_tab(p_batch_id);
            -- delete from all three tables
/*            del_existing_rec('CONTACTS', p_batch_id);
            del_existing_rec('CP', p_batch_id);
            del_existing_rec('PSITES', p_batch_id); */
        END IF;
    END IF;
    EXCEPTION WHEN OTHERS THEN
         log(SQLERRM); --
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
         FND_MESSAGE.SET_TOKEN('PROC' ,'DQM_INTER_IMP_CLEANUP');
         FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
         FND_MSG_PUB.ADD;
         fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
               p_count => x_msg_count,
               p_data  => x_msg_data);
END dqm_inter_imp_cleanup;

/**
* Procedure to write a message to the log file
**/
PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE
) IS
BEGIN
  IF message = 'NEWLINE' THEN
   FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
  ELSIF (newline) THEN
    FND_FILE.put_line(fnd_file.log,message);
  ELSE
    FND_FILE.put(fnd_file.log,message);
  END IF;
END log;


PROCEDURE interface_dup_id_worker (
    retcode  OUT NOCOPY   VARCHAR2,
    err             OUT NOCOPY    VARCHAR2,
    p_batch_id IN   VARCHAR2,
    p_match_rule_id IN  VARCHAR2,
    p_worker_num    IN VARCHAR2,
    p_num_of_workers    IN  VARCHAR2,
    p_phase IN  OUT NOCOPY VARCHAR2
) IS

l_to_osr VARCHAR2(30);
l_from_osr VARCHAR2(30);
x_return_status    VARCHAR2(30);
x_msg_count NUMBER;
x_msg_data VARCHAR2(255);
l_row_id VARCHAR2(100);

BEGIN
     x_return_status := fnd_api.g_ret_sts_success;
 LOOP
  log(' Processing worker ' ||  p_worker_num );
    l_row_id := NULL;
    IF (p_phase = 'PHASE_1') THEN
            UPDATE hz_imp_work_units SET BATCH_DEDUP_STATUS = 'P', BATCH_DEDUP_STAGE = 1
            WHERE batch_id = p_batch_id and BATCH_DEDUP_STATUS is null and rownum = 1
            RETURNING rowid, FROM_ORIG_SYSTEM_REF, TO_ORIG_SYSTEM_REF into l_row_id, l_from_osr, l_to_osr;
            IF (l_row_id IS NULL) THEN
              EXIT;
            END IF;
            COMMIT;
            log('calling HZ_IMP_DQM_STAGE.POP_INTERFACE_SEARCH_TAB');
            log ('p_batch_id = ' || p_batch_id);
            log ('p_match_rule_id = ' || p_match_rule_id);
            log ('l_from_osr = ' || l_from_osr);
            log ('l_to_osr = ' || l_to_osr);
            HZ_IMP_DQM_STAGE.POP_INTERFACE_SEARCH_TAB(to_number(p_batch_id),
            to_number(p_match_rule_id), l_from_osr, l_to_osr,
            x_return_status, x_msg_count, x_msg_data);

            IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
                retcode := 2;
                err := x_msg_data;
		logerror;
                UPDATE hz_imp_work_units SET BATCH_DEDUP_STATUS = 'E' where rowid = l_row_id;
                RAISE FND_API.G_EXC_ERROR;
            ELSE
                UPDATE hz_imp_work_units SET BATCH_DEDUP_STATUS = 'C' where rowid = l_row_id;
            END IF;
            COMMIT;
    ELSIF (p_phase = 'PHASE_2') THEN
            UPDATE hz_imp_work_units SET BATCH_DEDUP_STATUS = 'P', BATCH_DEDUP_STAGE = 2
            WHERE batch_id = p_batch_id AND BATCH_DEDUP_STAGE = 1 and ROWNUM = 1
            RETURNING rowid, FROM_ORIG_SYSTEM_REF, TO_ORIG_SYSTEM_REF into l_row_id, l_from_osr, l_to_osr;
            IF (l_row_id IS NULL) THEN
              EXIT;
            END IF;
            COMMIT;
            HZ_DQM_DUP_ID_PKG.interface_dup_id_worker(p_batch_id, p_match_rule_id, l_from_osr, l_to_osr, x_return_status, x_msg_count, x_msg_data);
            IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
                retcode := 2;
                err := x_msg_data;
                logerror;
                UPDATE hz_imp_work_units SET BATCH_DEDUP_STATUS = 'E' WHERE ROWID = l_row_id;
                RAISE FND_API.G_EXC_ERROR;
            ELSE
                UPDATE hz_imp_work_units SET BATCH_DEDUP_STATUS = 'C' WHERE ROWID = l_row_id;
            END IF;
            COMMIT;
      END IF;
  END LOOP;
  EXCEPTION WHEN OTHERS THEN
        retcode := 2;
        err := SQLERRM;
        log ('Error ::'|| err);
        RAISE FND_API.G_EXC_ERROR;
END interface_dup_id_worker;


PROCEDURE interface_dup_id(
    retcode  OUT NOCOPY   VARCHAR2,
    err             OUT NOCOPY    VARCHAR2,
    p_batch_id IN   VARCHAR2,
    p_match_rule_id IN  VARCHAR2,
    p_num_of_workers    IN  VARCHAR2
) IS
 req_data VARCHAR2(30);
 TYPE nTable IS TABLE OF NUMBER index by binary_integer;
 l_sub_requests nTable;
 x_return_status VARCHAR2(1) ;
 x_msg_count NUMBER;
 x_msg_data VARCHAR2(255);

 x_dup_batch_id NUMBER;
 l_state boolean := true;
 l_sub FND_CONCURRENT.REQUESTS_TAB_TYPE;
 call_status             boolean;
 l_conc_phase            VARCHAR2(80);
  l_conc_status           VARCHAR2(80);
  l_conc_dev_phase        VARCHAR2(30);
  l_conc_dev_status       VARCHAR2(30);
  l_message               VARCHAR2(240);
  l_workers_completed boolean ;
BEGIN
/*  DQM - Batch De-duplication Program
    Writes to - HZ_IMP_BATCH_SUMMARY.BATCH_DEDUP_STATUS
    Values -
       PROCESSING - When program starts the process
       COMPLETED - When program ends successfully. Also write all the DQM Count columns in this case.
       ERROR - When program encounters some error
*/
    req_data := fnd_conc_global.request_data;
    log('req_data = '|| req_data);
    IF ( req_data IS NULL) THEN
-- code for validation.  needs to be completed ????
/*
        l_bool := if_correct_batch(p_batch_id);
        IF l_bool THEN
            l_bool := if_correct_rule(p_match_rule_id);
            IF (l_bool) THEN
                l_bool := if_correct_worker_num( p_num_of_workers);
                ELSE
                log (' Please pass worker number between 0 and 100');
                END IF;
        ELSE
           log ('Please check the match rule you passed');
        END IF;
*/

        chk_table('HZ_INT_DUP_RESULTS', p_batch_id);
        UPDATE HZ_IMP_BATCH_SUMMARY set BATCH_DEDUP_STATUS = 'PROCESSING' where batch_id = p_batch_id;
        COMMIT;
--        HZ_IMP_DQM_STAGE.dqm_pre_imp_cleanup(p_batch_id, x_return_status, x_msg_count, x_msg_data);
        FOR I in 1..to_number(p_num_of_workers) LOOP
           log('I = ' || I);
           l_sub_requests(i) := FND_REQUEST.SUBMIT_REQUEST('AR', 'ARHDIDIW',
                        'Interface Duplicate Identification Worker' || to_char(i),
                        to_char(sysdate,'DD-MON-YY HH:MI:SS'),
                        true, p_batch_id, p_match_rule_id, to_char(I), p_num_of_workers, 'PHASE_1');
           IF l_sub_requests(i) = 0 THEN
                log('Error submitting worker ' || i);
                log(fnd_message.get);
                retcode := 2;
                RAISE FND_API.G_EXC_ERROR;
           ELSE
                log('Submitted request for Worker ' || TO_CHAR(I) );
                log('Request ID : ' || l_sub_requests(i));
           END IF;
           EXIT when l_sub_requests(i) = 0;
        END LOOP;
       fnd_conc_global.set_req_globals(conc_status => 'PAUSED', request_data => 'STAGING') ;
       err  := 'Concurrent Workers submitted.';
       retcode := 0;
    ELSIF ( req_data = 'STAGING') THEN
          -- adding below  for better error handling, parent should denote the error status if any child fails.
          -- AFTER ALL THE WORKERS ARE DONE, SEE IF THEY HAVE ALL COMPLETED NORMALLY
          -- assume that all concurrent dup workers completed normally, unless found otherwise
          l_workers_completed := TRUE;
          select request_id BULK COLLECT into l_sub_requests
          from fnd_concurrent_requests R
          where parent_request_id = FND_GLOBAL.conc_request_id
          and (phase_code<>'C' or status_code<>'C');
          IF  l_sub_requests.count > 0 THEN
            l_workers_completed := FALSE;
            FOR I in 1..l_sub_requests.COUNT LOOP
              outandlog('Worker with request id ' || l_sub_requests(I) );
              outandlog('Did not complete normally.');
              retcode := 2;
              log(' retcode = ' || retcode);
              RAISE FND_API.G_EXC_ERROR;
            END LOOP;
          END IF;
          log('p_rule_id '||p_match_rule_id);
     IF l_workers_completed THEN
        FOR I in 1..to_number(p_num_of_workers) LOOP
           l_sub_requests(i) := FND_REQUEST.SUBMIT_REQUEST('AR', 'ARHDIDIW',
                        'Interface Duplicate Identification Worker' || to_char(i),
                        to_char(sysdate,'DD-MON-YY HH:MI:SS'),
                        true, p_batch_id, p_match_rule_id, to_char(I), p_num_of_workers, 'PHASE_2');
           IF l_sub_requests(i) = 0 THEN
                log('Error submitting worker ' || i);
                log(fnd_message.get);
           ELSE
                log('Submitted request for Worker ' || TO_CHAR(I) );
                log('Request ID : ' || l_sub_requests(i));
           END IF;
           EXIT when l_sub_requests(i) = 0;
        END LOOP;
       fnd_conc_global.set_req_globals(conc_status => 'PAUSED', request_data => 'EXIT') ;
       err  := 'Concurrent Workers submitted.';
       retcode := 0;
     END IF;
    ELSIF ( req_data = 'EXIT') THEN
          -- adding below  for better error handling, parent should denote the error status if any child fails.
          -- AFTER ALL THE WORKERS ARE DONE, SEE IF THEY HAVE ALL COMPLETED NORMALLY
          -- assume that all concurrent dup workers completed normally, unless found otherwise
          l_workers_completed := TRUE;
          select request_id BULK COLLECT into l_sub_requests
          from fnd_concurrent_requests R
          where parent_request_id = FND_GLOBAL.conc_request_id
          and (phase_code<>'C' or status_code<>'C');
          IF  l_sub_requests.count > 0 THEN
            l_workers_completed := FALSE;
            FOR I in 1..l_sub_requests.COUNT LOOP
              outandlog('Worker with request id ' || l_sub_requests(I) );
              outandlog('Did not complete normally');
              retcode := 2;
              log(' retcode = ' || retcode);
              RAISE FND_API.G_EXC_ERROR;
            END LOOP;
          END IF;
          log('p_rule_id '||p_match_rule_id);
        IF l_workers_completed THEN
            HZ_DQM_DUP_ID_PKG.interface_sanitize_report(p_batch_id,
            p_match_rule_id, x_return_status, x_msg_count, x_msg_data);

    --    update hz_imp_batch_summary set est_no_matches = $no where batch_id = p_batch_id;
            UPDATE HZ_IMP_BATCH_SUMMARY set BATCH_DEDUP_STATUS = 'COMPLETED' where batch_id = p_batch_id;
            COMMIT;
            chk_table('HZ_INT_DUP_RESULTS', p_batch_id);
        END IF;
    END IF;
    EXCEPTION WHEN OTHERS THEN
        retcode := 2;
        log(' retcode . = ' || retcode);
        UPDATE HZ_IMP_BATCH_SUMMARY set BATCH_DEDUP_STATUS = 'ERROR' where batch_id = p_batch_id;
        COMMIT;
        RAISE FND_API.G_EXC_ERROR;
END interface_dup_id;

PROCEDURE gen_pkg_spec (
	    p_pkg_name 	IN	VARCHAR2,
        p_rule_id	IN	NUMBER
) IS
    l_procedure_name VARCHAR2(30) := '.GEN_PKG_SPEC' ;
BEGIN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter p_pkg_name='||p_pkg_name || ' p_rule_id='|| p_rule_id);
    END IF;
  IF is_test THEN
      l('CREATE or REPLACE PACKAGE ' || p_pkg_name || ' AUTHID CURRENT_USER AS'); -- this
  END IF;
  l('    PROCEDURE pop_parties( 	 ');
  l('        p_batch_id IN	NUMBER, ');
  l('        p_from_osr                       IN   VARCHAR2, ');
  l('        p_to_osr                         IN   VARCHAR2,  ');
  l('        p_batch_mode_flag                  IN VARCHAR2 ); ');
  l(' ');
  l('  PROCEDURE pop_party_sites ( ');
  l('   	 p_batch_id IN	NUMBER,  ');
  l('        p_from_osr                       IN   VARCHAR2, ');
  l('  	     p_to_osr                         IN   VARCHAR2,  ');
  l('        p_batch_mode_flag                  IN VARCHAR2 ); ');
  l('        ');
  l('  PROCEDURE pop_cp (  ');
  l('   	 p_batch_id IN	NUMBER, ');
  l('        p_from_osr                       IN   VARCHAR2, ');
  l('  	     p_to_osr                         IN   VARCHAR2, ');
  l('        p_batch_mode_flag                  IN VARCHAR2 ); ');
  l(' ');
  l('  PROCEDURE pop_contacts (  ');
  l('   	 p_batch_id IN	NUMBER, ');
  l('        p_from_osr                       IN   VARCHAR2, ');
  l('  	     p_to_osr                         IN   VARCHAR2, ');
  l('        p_batch_mode_flag                  IN VARCHAR2 ); ');
  l(' ');
  l(' PROCEDURE pop_parties_int ( ');
  l('    	 p_batch_id IN	NUMBER, ');
  l('        p_from_osr                       IN   VARCHAR2, ');
  l('    	 p_to_osr                         IN   VARCHAR2 );');
  l(' ');
  l(' PROCEDURE pop_party_sites_int ( ');
  l('    	 p_batch_id IN	NUMBER, ');
  l('        p_from_osr                       IN   VARCHAR2, ');
  l('    	 p_to_osr                         IN   VARCHAR2 );');
  l(' ');
  l(' PROCEDURE pop_cp_int ( ');
  l('    	 p_batch_id IN	NUMBER, ');
  l('        p_from_osr                       IN   VARCHAR2, ');
  l('    	 p_to_osr                         IN   VARCHAR2 );');
  l(' ');
  l('  PROCEDURE pop_contacts_int (  ');
  l('   	 p_batch_id IN	NUMBER, ');
  l('        p_from_osr                       IN   VARCHAR2, ');
  l('  	     p_to_osr                         IN   VARCHAR2 );');
  l(' ');
  IF is_test THEN
    l('END ' || p_pkg_name || ';');  -- this
  END IF;
      EXCEPTION WHEN OTHERS THEN
          RAISE FND_API.G_EXC_ERROR;
END gen_pkg_spec;


PROCEDURE get_table_name (
 p_entity_name  IN VARCHAR2,
 p_table_name IN OUT NOCOPY VARCHAR2
 ) IS
 l_procedure_name VARCHAR2(30) := 'GET_TABLE_NAME';
 BEGIN
   IF ((p_entity_name = 'PARTY') OR (p_entity_name = 'HZ_STAGED_PARTIES')) THEN
       p_table_name := 'HZ_IMP_PARTIES_INT';
   ELSIF ((p_entity_name = 'PARTY_SITES') OR (p_entity_name = 'HZ_STAGED_PARTY_SITES')) THEN
       p_table_name := 'HZ_IMP_ADDRESSES_INT';
   ELSIF ((p_entity_name = 'CONTACTS') OR (p_entity_name = 'HZ_STAGED_CONTACTS')) THEN
       p_table_name := 'HZ_IMP_CONTACTS_INT';
   ELSIF ((p_entity_name = 'CONTACT_POINTS') OR (p_entity_name = 'HZ_STAGED_CONTACT_POINTS')) THEN
       p_table_name := 'HZ_IMP_CONTACTPTS_INT';
   ELSE
        IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_log.string(fnd_log.LEVEL_ERROR,G_PKG_NAME||l_procedure_name,'p_entity_name='||p_entity_name);
          END IF;
   END IF;
END get_table_name;

PROCEDURE get_select_str(
    p_entity_name       IN VARCHAR2,
    p_rule_id     IN NUMBER,
    p_sql_str IN OUT NOCOPY VARCHAR2,
    p_et_point IN VARCHAR2,
    p_std_chk IN NUMBER
) IS
 is_first BOOLEAN := TRUE;
 l_procedure_name VARCHAR2(30) := '.GET_SELECT_STR' ;
 l_table_name VARCHAR2(30);
 is_using_allow_cust_attr VARCHAR2(1) := 'N';

BEGIN
   get_table_name(p_entity_name, l_table_name);
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
    END IF;
--    FOR TX IN (select decode(attribute_name, 'PARTY_NAME', 'ORGANIZATION_NAME', attribute_name) as attribute_name
    FOR TX IN (select attribute_name
                from hz_trans_attributes_b
                where entity_name = p_entity_name
                and HZ_IMP_DQM_STAGE.EXIST_COL(attribute_name, p_entity_name) = 'Y'
                and custom_attribute_procedure is null
/*                and attribute_name not in
                ('SIC_CODE', 'SIC_CODE_TYPE', 'TAX_NAME', 'CATEGORY_CODE', 'IDENTIFYING_ADDRESS_FLAG', 'STATUS', 'PRIMARY_FLAG', 'REFERENCE_USE_FLAG' ) */
                and attribute_id in ( select attribute_id
                    from hz_match_rule_primary
                    where match_rule_id = p_rule_id
                    union
                    select attribute_id
                    from hz_match_rule_secondary
                    where match_rule_id = p_rule_id)
                    ) LOOP
        IF is_first THEN
            is_first := false;
            IF (p_std_chk = DO_STD_CHK) THEN
                p_sql_str :=  '  select ' || chk_is_std(TX.attribute_name)  ;
            ELSE
                IF TX.attribute_name = 'PARTY_NAME' THEN
                   p_sql_str :=  '  select decode(a.party_type, ''ORGANIZATION'', a.organization_name, ''PERSON'', a.person_first_name || '' '' || a.person_last_name) as PARTY_NAME ';
               ELSE
                   p_sql_str :=  '  select a.' || TX.attribute_name ;
               END IF;
            END IF;
        ELSE
            IF (p_std_chk = DO_STD_CHK) THEN
                p_sql_str :=  p_sql_str || ', ' || chk_is_std(TX.attribute_name) ;
            ELSE
               IF TX.attribute_name = 'PARTY_NAME' THEN
                   p_sql_str :=  p_sql_str || ', decode(a.party_type, ''ORGANIZATION'', a.organization_name, ''PERSON'', a.person_first_name || '' '' || a.person_last_name) as PARTY_NAME ';
               ELSE
                   p_sql_str :=  p_sql_str || ', a.' || TX.attribute_name ;
               END IF;
            END IF;
        END IF;
    END LOOP;
    IF p_et_point = 'INT_INT' THEN
        IF p_entity_name = 'PARTY'  /* and p_sql_str != null */  THEN
          p_sql_str := p_sql_str || ', a.party_orig_system, a.party_orig_system_reference, b.party_id, a.rowid, a.party_type' ;
        ELSIF p_entity_name = 'PARTY_SITES'  /* and p_sql_str != null */  THEN
            is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'PARTY_SITES', 'ADDRESS'); -- using_address(p_rule_id);
--          IF (p_std_chk = NO_STD_CHK) THEN
            IF (p_sql_str is NULL) THEN
              p_sql_str :=  'select a.party_orig_system';
              p_sql_str := p_sql_str || ', a.party_orig_system_reference, a.site_orig_system';
              p_sql_str := p_sql_str || ', a.site_orig_system_reference, b.party_id, b.party_site_id, b.party_action_flag, a.rowid';
            ELSE
              p_sql_str := p_sql_str || ', a.party_orig_system';
              p_sql_str := p_sql_str || ', a.party_orig_system_reference, a.site_orig_system';
              p_sql_str := p_sql_str || ', a.site_orig_system_reference, b.party_id, b.party_site_id, b.party_action_flag, a.rowid';
            END IF;
            IF (is_using_allow_cust_attr = 'Y') THEN
--              p_sql_str := p_sql_str || ', a.address1 || a.address2 || a.address3 || a.address4 as address ';
                p_sql_str := p_sql_str || ','|| chk_is_std('ADDRESS1') || ' || '' '' '
                                       || '||' || chk_is_std('ADDRESS2') || ' || '' '' '
                                       || '||'  || chk_is_std('ADDRESS3') || ' || '' '' '
                                       || '||'  || chk_is_std('ADDRESS4')||' as address ';
            END IF;
/*          ELSE IF (p_std_chk = DO_STD_CHK) THEN

          ELSE
            dbms_output.put_line('SOMETHING WRONG 1 ');
            IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_log.string(fnd_log.LEVEL_ERROR,G_PKG_NAME||l_procedure_name,'p_et_point = ''INT_INT'',p_entity_name='||p_entity_name||' p_std_chk=' || p_std_chk);
            END IF;
          END IF;
          */
        ELSIF p_entity_name = 'CONTACT_POINTS'  /* and p_sql_str != null */  THEN
          is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'CONTACT_POINTS', 'RAW_PHONE_NUMBER'); -- using_raw_ph_no(p_rule_id);
          IF (p_sql_str IS NULL) THEN
              p_sql_str := 'select a.party_orig_system, a.party_orig_system_reference, a.cp_orig_system, a.cp_orig_system_reference, a.site_orig_system';
              p_sql_str := p_sql_str || ', a.site_orig_system_reference, b.party_site_id, b.contact_point_id, b.party_id, b.party_action_flag, a.rowid, a.contact_point_type';
          ELSE
              p_sql_str := p_sql_str || ', a.party_orig_system, a.party_orig_system_reference, a.cp_orig_system, a.cp_orig_system_reference, a.site_orig_system';
              p_sql_str := p_sql_str || ', a.site_orig_system_reference, b.party_site_id, b.contact_point_id, b.party_id, b.party_action_flag, a.rowid, a.contact_point_type';
          END IF;
          IF (is_using_allow_cust_attr = 'Y') THEN
              p_sql_str := p_sql_str || ', decode(a.raw_phone_number, null, a.PHONE_COUNTRY_CODE||a.PHONE_AREA_CODE ||a.phone_number, a.raw_phone_number) as raw_phone_number ';
          END IF;
        ELSIF p_entity_name = 'CONTACTS'  /* and p_sql_str != null */  THEN
              IF (p_sql_str IS NULL) THEN
                  p_sql_str :=  'select a.obj_orig_system, a.obj_orig_system_reference, a.contact_orig_system, a.contact_orig_system_reference, b.party_action_flag, a.rowid, b.obj_id';
              ELSE
                  p_sql_str := p_sql_str || ', a.obj_orig_system, a.obj_orig_system_reference, a.contact_orig_system, a.contact_orig_system_reference, b.party_action_flag, a.rowid, b.obj_id';
              END IF;
        ELSE
            IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_log.string(fnd_log.LEVEL_ERROR,G_PKG_NAME||l_procedure_name,'p_et_point = ''INT_INT'',p_entity_name='||p_entity_name);
            END IF;
        END IF;
    ELSIF p_et_point = 'INT_TCA' THEN
        IF p_entity_name = 'PARTY'  /* and p_sql_str != null */  THEN
          p_sql_str := p_sql_str || ', a.party_orig_system, a.party_orig_system_reference, a.rowid, a.party_type ' ;
        ELSIF p_entity_name = 'PARTY_SITES'  /* and p_sql_str != null */  THEN
            is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'PARTY_SITES', 'ADDRESS');--using_address(p_rule_id);
            IF (p_sql_str is NULL) THEN
              p_sql_str := 'select a.party_orig_system';
              p_sql_str := p_sql_str || ', a.party_orig_system_reference, a.site_orig_system, a.site_orig_system_reference, a.rowid';
            ELSE
              p_sql_str := p_sql_str || ', a.party_orig_system';
              p_sql_str := p_sql_str || ', a.party_orig_system_reference, a.site_orig_system, a.site_orig_system_reference, a.rowid';
            END IF;
            IF (is_using_allow_cust_attr = 'Y') THEN
              p_sql_str := p_sql_str || ',  a.address1 || '' '' || a.address2 || '' '' || a.address3 || '' '' || a.address4 as address  ';
            END IF;
        ELSIF p_entity_name = 'CONTACT_POINTS'  /* and p_sql_str != null */  THEN
              is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'CONTACT_POINTS','RAW_PHONE_NUMBER');--using_raw_ph_no(p_rule_id);
              IF (p_sql_str IS NULL) THEN
                   p_sql_str := 'select a.party_orig_system, a.party_orig_system_reference, a.cp_orig_system, a.cp_orig_system_reference, a.site_orig_system, a.site_orig_system_reference, a.rowid, a.contact_point_type';
              ELSE
                   p_sql_str := p_sql_str || ', a.party_orig_system, a.party_orig_system_reference, a.cp_orig_system, a.cp_orig_system_reference, a.site_orig_system, a.site_orig_system_reference, a.rowid, a.contact_point_type';
              END IF;
              IF (is_using_allow_cust_attr = 'Y') THEN
                  p_sql_str := p_sql_str || ',decode(a.raw_phone_number, null, a.PHONE_COUNTRY_CODE||a.PHONE_AREA_CODE ||a.phone_number,a.raw_phone_number) as raw_phone_number ';
              END IF;
        ELSIF p_entity_name = 'CONTACTS'  /* and p_sql_str != null */  THEN
              IF (p_sql_str IS NULL) THEN
                 p_sql_str := 'select a.obj_orig_system, a.obj_orig_system_reference, a.contact_orig_system, a.contact_orig_system_reference, a.rowid';
              ELSE
                 p_sql_str := p_sql_str || ', a.obj_orig_system, a.obj_orig_system_reference, a.contact_orig_system, a.contact_orig_system_reference, a.rowid';
              END IF;
        ELSE
            IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_log.string(fnd_log.LEVEL_ERROR,G_PKG_NAME||l_procedure_name,'p_et_point = ''INT_TCA'',p_entity_name='||p_entity_name);
            END IF;
        END IF;
    ELSE
        IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            fnd_log.string(fnd_log.LEVEL_ERROR,G_PKG_NAME||l_procedure_name,'p_et_point = '||p_et_point);
        END IF;
    END IF;
      EXCEPTION WHEN OTHERS THEN
          RAISE FND_API.G_EXC_ERROR;
END get_select_str;

PROCEDURE get_trans_str (
    p_entity_name       IN VARCHAR2,
    p_rule_id     IN NUMBER,
    p_sql_str IN OUT NOCOPY VARCHAR2,
    p_et_point IN VARCHAR2
) IS
 is_first BOOLEAN := TRUE;
 is_using_allow_cust_attr VARCHAR2(1) := 'N';
 l_procedure_name VARCHAR2(30) := '.GET_TRANS_STR' ;
 l_table_name VARCHAR2(30);
BEGIN
    get_table_name(p_entity_name, l_table_name);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
    END IF;
      FOR TX IN ( select attribute_id || 'E' as STAGED_ATTRIBUTE_COLUMN
            from hz_trans_attributes_b
            where attribute_id in (select attribute_id
            from hz_match_rule_primary
            where match_rule_id = p_rule_id
            union
            select attribute_id
            from hz_match_rule_secondary
            where match_rule_id = p_rule_id)
            and entity_name = p_entity_name
            and HZ_IMP_DQM_STAGE.EXIST_COL(attribute_name, p_entity_name) = 'Y'
            and custom_attribute_procedure is null
/*            and attribute_name not in
            ('SIC_CODE', 'SIC_CODE_TYPE', 'TAX_NAME', 'CATEGORY_CODE', 'IDENTIFYING_ADDRESS_FLAG', 'STATUS', 'PRIMARY_FLAG', 'REFERENCE_USE_FLAG' ) */
            ) LOOP
            IF is_first THEN
               is_first := false;
               p_sql_str := '       H_' || TX.STAGED_ATTRIBUTE_COLUMN ;
            ELSE
               p_sql_str := p_sql_str || ', H_' || TX.STAGED_ATTRIBUTE_COLUMN ;
            END IF;
       END LOOP;
    IF p_et_point = 'INT_INT' THEN
       IF p_entity_name = 'PARTY' THEN
           p_sql_str := p_sql_str || ', H_P_PARTY_OS , H_P_PARTY_OSR, H_P_PARTY_ID, H_P_ROW_ID, H_P_P_TYPE' ;
       ELSIF p_entity_name = 'PARTY_SITES' THEN
           is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'PARTY_SITES','ADDRESS');--using_address(p_rule_id);
           IF (p_sql_str IS NULL) THEN
               p_sql_str := ' H_P_PARTY_OS, H_P_PARTY_OSR, H_P_PS_OS, H_P_PS_OSR, H_P_PARTY_ID, H_P_PARTY_SITE_ID, H_P_N_PARTY, H_P_ROW_ID' ;
           ELSE
               p_sql_str := p_sql_str || ', H_P_PARTY_OS, H_P_PARTY_OSR, H_P_PS_OS, H_P_PS_OSR, H_P_PARTY_ID, H_P_PARTY_SITE_ID, H_P_N_PARTY, H_P_ROW_ID' ;
           END IF;
            IF (is_using_allow_cust_attr = 'Y') THEN
              p_sql_str := p_sql_str || ', H_P_PS_ADD ';
            END IF;
       ELSIF p_entity_name = 'CONTACT_POINTS' THEN
           is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'CONTACT_POINTS','RAW_PHONE_NUMBER');--using_raw_ph_no(p_rule_id);
           IF (p_sql_str IS NULL) THEN
               p_sql_str := ' H_P_PARTY_OS, H_P_PARTY_OSR, H_P_CP_OS, H_P_CP_OSR, H_P_PS_OS, H_P_PS_OSR, H_P_PARTY_SITE_ID, H_P_CONTACT_POINT_ID, H_P_PARTY_ID, H_P_N_PARTY, H_P_ROW_ID, H_P_CP_TYPE';
            ELSE
               p_sql_str := p_sql_str || ', H_P_PARTY_OS, H_P_PARTY_OSR, H_P_CP_OS, H_P_CP_OSR, H_P_PS_OS, H_P_PS_OSR, H_P_PARTY_SITE_ID, H_P_CONTACT_POINT_ID, H_P_PARTY_ID, H_P_N_PARTY, H_P_ROW_ID, H_P_CP_TYPE';
            END IF;
            IF (is_using_allow_cust_attr = 'Y') THEN
                p_sql_str := p_sql_str || ', H_P_CP_R_PH_NO ';
            END IF;
       ELSIF p_entity_name = 'CONTACTS' THEN
           is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'CONTACTS','CONTACT_NAME');-- using_contact_name(p_rule_id);
           IF (p_sql_str IS NULL) THEN
               p_sql_str := ' H_P_SUBJECT_OS, H_P_SUBJECT_OSR, H_P_CONTACT_OS, H_P_CONTACT_OSR, H_P_N_PARTY, H_P_ROW_ID, H_CT_OBJ_ID ';
           ELSE
               p_sql_str := p_sql_str || ', H_P_SUBJECT_OS, H_P_SUBJECT_OSR, H_P_CONTACT_OS, H_P_CONTACT_OSR, H_P_N_PARTY, H_P_ROW_ID, H_CT_OBJ_ID ';
           END IF;
           IF (is_using_allow_cust_attr = 'Y') THEN
                p_sql_str := p_sql_str || ', H_CT_NAME ';
           END IF;
       ELSE
            IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                fnd_log.string(fnd_log.LEVEL_ERROR,G_PKG_NAME||l_procedure_name,'p_et_point = ''INT_INT'', p_entity_name = '||p_entity_name);
            END IF;
       END IF;
     ELSIF p_et_point = 'INT_TCA' THEN
       IF p_entity_name = 'PARTY' THEN
           p_sql_str := p_sql_str || ', H_P_PARTY_OS , H_P_PARTY_OSR, H_P_ROW_ID, H_P_P_TYPE' ;
       ELSIF p_entity_name = 'PARTY_SITES' THEN
           is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'PARTY_SITES','ADDRESS'); --using_address(p_rule_id);
           IF (p_sql_str IS NULL) THEN
               p_sql_str := ' H_P_PARTY_OS, H_P_PARTY_OSR, H_P_PS_OS, H_P_PS_OSR, H_P_ROW_ID' ;
           ELSE
               p_sql_str := p_sql_str || ', H_P_PARTY_OS, H_P_PARTY_OSR, H_P_PS_OS, H_P_PS_OSR, H_P_ROW_ID' ;
           END IF;
            IF (is_using_allow_cust_attr = 'Y') THEN
              p_sql_str := p_sql_str || ', H_P_PS_ADD ';
            END IF;
       ELSIF p_entity_name = 'CONTACT_POINTS' THEN
           is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'CONTACT_POINTS','RAW_PHONE_NUMBER'); --using_raw_ph_no(p_rule_id);
           IF (p_sql_str IS NULL) THEN
               p_sql_str := ' H_P_PARTY_OS, H_P_PARTY_OSR, H_P_CP_OS, H_P_CP_OSR, H_P_PS_OS, H_P_PS_OSR, H_P_ROW_ID, H_P_CP_TYPE';
            ELSE
               p_sql_str := p_sql_str || ', H_P_PARTY_OS, H_P_PARTY_OSR, H_P_CP_OS, H_P_CP_OSR, H_P_PS_OS, H_P_PS_OSR, H_P_ROW_ID, H_P_CP_TYPE';
            END IF;
            IF (is_using_allow_cust_attr = 'Y') THEN
                p_sql_str := p_sql_str || ', H_P_CP_R_PH_NO ';
            END IF;
       ELSIF p_entity_name = 'CONTACTS' THEN
           is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'CONTACTS','CONTACT_NAME');-- using_contact_name(p_rule_id);
           IF (p_sql_str IS NULL) THEN
               p_sql_str := ' H_P_SUBJECT_OS, H_P_SUBJECT_OSR, H_P_CONTACT_OS, H_P_CONTACT_OSR, H_P_ROW_ID ';
           ELSE
               p_sql_str := p_sql_str || ', H_P_SUBJECT_OS, H_P_SUBJECT_OSR, H_P_CONTACT_OS, H_P_CONTACT_OSR, H_P_ROW_ID ';
           END IF;
           IF (is_using_allow_cust_attr = 'Y') THEN
                p_sql_str := p_sql_str || ', H_CT_NAME ';
           END IF;
       ELSE
            IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                fnd_log.string(fnd_log.LEVEL_ERROR,G_PKG_NAME||l_procedure_name,'p_et_point = ''INT_TCA'', p_entity_name = '||p_entity_name);
            END IF;
       END IF;
     ELSE
        IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            fnd_log.string(fnd_log.LEVEL_ERROR,G_PKG_NAME||l_procedure_name,'p_et_point = '|| p_et_point);
         END IF;
    END IF;
      EXCEPTION WHEN OTHERS THEN
          RAISE FND_API.G_EXC_ERROR;

END get_trans_str;

PROCEDURE get_cust_insert_str (
    p_entity_name       IN VARCHAR2,
    p_match_rule_id     IN NUMBER,
    p_sql_str IN OUT NOCOPY VARCHAR2,
    p_et_point IN VARCHAR2,
    p_attr_name IN VARCHAR2,
    p_purpose VARCHAR2 -- can be taken out
) IS
 is_first BOOLEAN := TRUE;
 is_using_allow_cust_attr VARCHAR2(1) := 'N';
 l_procedure_name VARCHAR2(30) := '.GET_CUST_INSERT_STR' ;
 l_table_name VARCHAR2(30);
BEGIN
    get_table_name(p_entity_name, l_table_name);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
     END IF;
      FOR TX IN (  select STAGED_ATTRIBUTE_COLUMN
            from hz_trans_functions_b
            where attribute_id in (select attribute_id
            from hz_trans_attributes_b
            where attribute_name = p_attr_name
            and entity_name = p_entity_name)
            and function_id in (select function_id
            from hz_match_rule_primary e, hz_primary_trans d
            where match_rule_id = p_match_rule_id
            and e.PRIMARY_ATTRIBUTE_ID = d.PRIMARY_ATTRIBUTE_ID
            union
            select function_id
            from hz_match_rule_secondary g, hz_secondary_trans f
            where f.SECONDARY_ATTRIBUTE_ID = g.SECONDARY_ATTRIBUTE_ID
            and match_rule_id = p_match_rule_id)
            order by STAGED_ATTRIBUTE_COLUMN
            ) LOOP
            IF is_first THEN
               is_first := false;
               p_sql_str :=  ', ' || TX.STAGED_ATTRIBUTE_COLUMN ;
            ELSE
               p_sql_str := p_sql_str || ', ' || TX.STAGED_ATTRIBUTE_COLUMN ;
            END IF;
            END LOOP;
END get_cust_insert_str;


PROCEDURE get_insert_str (
    p_entity_name       IN VARCHAR2,
    p_rule_id     IN NUMBER,
    p_sql_str IN OUT NOCOPY VARCHAR2,
    p_et_point IN VARCHAR2
) IS
 is_first BOOLEAN := TRUE;
 is_using_allow_cust_attr VARCHAR2(1) := 'N';
 l_procedure_name VARCHAR2(30) := '.GET_INSERT_STR' ;
 l_table_name VARCHAR2(30);
 l_sql_str VARCHAR2(255) ;
BEGIN
    get_table_name(p_entity_name, l_table_name);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
     END IF;
      FOR TX IN ( select STAGED_ATTRIBUTE_COLUMN
            from hz_trans_functions_b
            where function_id in
		     (select function_id
                     from hz_match_rule_primary e, hz_primary_trans d
                     where match_rule_id = p_rule_id
                     and e.PRIMARY_ATTRIBUTE_ID = d.PRIMARY_ATTRIBUTE_ID
                     union
                     select function_id
                     from hz_match_rule_secondary g, hz_secondary_trans f
                     where f.SECONDARY_ATTRIBUTE_ID = g.SECONDARY_ATTRIBUTE_ID
                     and match_rule_id = p_rule_id)
            and nvl(active_flag, 'Y') <> 'N'
            and staged_attribute_table = p_entity_name
            and attribute_id not in (
                   select attribute_id
                    from hz_trans_attributes_b
                    where  custom_attribute_procedure is not  null
                    or HZ_IMP_DQM_STAGE.EXIST_COL(attribute_name, p_entity_name) = 'N'
/*                    or  attribute_name in
                    ('SIC_CODE', 'SIC_CODE_TYPE', 'TAX_NAME', 'CATEGORY_CODE', 'IDENTIFYING_ADDRESS_FLAG', 'STATUS', 'PRIMARY_FLAG', 'REFERENCE_USE_FLAG' ) */
                    ) order by STAGED_ATTRIBUTE_COLUMN
            ) LOOP
            IF is_first THEN
               is_first := false;
               p_sql_str :=  '          ' || TX.STAGED_ATTRIBUTE_COLUMN ;
            ELSE
               p_sql_str := p_sql_str || ', ' || TX.STAGED_ATTRIBUTE_COLUMN ;
            END IF;
       END LOOP;
    IF p_et_point = 'INT_INT' THEN
       IF p_entity_name = 'HZ_STAGED_PARTIES' THEN
           IF (p_sql_str IS NULL) THEN
               p_sql_str := ' PARTY_OS, PARTY_OSR, PARTY_ID, BATCH_ID, INT_ROW_ID' ;
           ELSE
               p_sql_str := p_sql_str || ', PARTY_OS, PARTY_OSR, PARTY_ID, BATCH_ID, INT_ROW_ID' ;
           END IF;
        ELSIF p_entity_name = 'HZ_STAGED_PARTY_SITES' THEN
           is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'PARTY_SITES','ADDRESS'); --using_address(p_rule_id);
           IF (p_sql_str IS NULL) THEN
               p_sql_str := ' PARTY_SITE_ID, PARTY_ID, PARTY_OS, PARTY_OSR, PARTY_SITE_OS, PARTY_SITE_OSR, NEW_PARTY_FLAG, BATCH_ID, INT_ROW_ID ';
           ELSE
               p_sql_str := p_sql_str || ', PARTY_SITE_ID, PARTY_ID, PARTY_OS, PARTY_OSR, PARTY_SITE_OS, PARTY_SITE_OSR, NEW_PARTY_FLAG, BATCH_ID, INT_ROW_ID ';
           END IF;
           IF (is_using_allow_cust_attr = 'Y') THEN
--                p_sql_str := p_sql_str || ', TX3, TX4, TX26, TX27 ';
                get_cust_insert_str ('PARTY_SITES', p_rule_id, l_sql_str, 'PS', 'ADDRESS', null);
                p_sql_str := p_sql_str || l_sql_str;
            END IF;
        ELSIF p_entity_name = 'HZ_STAGED_CONTACT_POINTS' THEN
           is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'CONTACT_POINTS','RAW_PHONE_NUMBER');-- using_raw_ph_no(p_rule_id);
           IF (p_sql_str IS NULL) THEN
               p_sql_str := ' PARTY_SITE_ID, PARTY_ID, PARTY_OS, PARTY_OSR, PARTY_SITE_OS, PARTY_SITE_OSR, CONTACT_POINT_ID, CONTACT_PT_OS, CONTACT_PT_OSR, NEW_PARTY_FLAG, BATCH_ID, INT_ROW_ID, CONTACT_POINT_TYPE ';
           ELSE
               p_sql_str := p_sql_str || ', PARTY_SITE_ID, PARTY_ID, PARTY_OS, PARTY_OSR, PARTY_SITE_OS, PARTY_SITE_OSR, CONTACT_POINT_ID, CONTACT_PT_OS, CONTACT_PT_OSR, NEW_PARTY_FLAG, BATCH_ID, INT_ROW_ID, CONTACT_POINT_TYPE ';
           END IF;
           IF (is_using_allow_cust_attr = 'Y') THEN
--                p_sql_str := p_sql_str || ', TX10, TX158 ';
                get_cust_insert_str ('CONTACT_POINTS', p_rule_id, l_sql_str, 'CP', 'RAW_PHONE_NUMBER', null);
                p_sql_str := p_sql_str || l_sql_str;
            END IF;
        ELSIF p_entity_name = 'HZ_STAGED_CONTACTS' THEN
           is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'CONTACTS','CONTACT_NAME');--using_contact_name(p_rule_id);
           IF (p_sql_str IS NULL) THEN
                p_sql_str := ' PARTY_OS, PARTY_OSR, CONTACT_OS, CONTACT_OSR, NEW_PARTY_FLAG, BATCH_ID, INT_ROW_ID, PARTY_ID ';
           ELSE
                p_sql_str := p_sql_str || ', PARTY_OS, PARTY_OSR, CONTACT_OS, CONTACT_OSR, NEW_PARTY_FLAG, BATCH_ID, INT_ROW_ID, PARTY_ID ';
           END IF;
           IF (is_using_allow_cust_attr = 'Y') THEN
--                p_sql_str := p_sql_str || ', TX2, TX5, TX6, TX156 ';
                get_cust_insert_str ('CONTACTS', p_rule_id, l_sql_str, NULL, 'CONTACT_NAME', null);
                p_sql_str := p_sql_str || l_sql_str;
            END IF;
        ELSE
            IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                fnd_log.string(fnd_log.LEVEL_ERROR,G_PKG_NAME||l_procedure_name,'p_et_point = ''INT_INT'', p_entity_name = '||p_entity_name);
            END IF;
       END IF;
    ELSIF p_et_point = 'INT_TCA' THEN
       IF p_entity_name = 'HZ_STAGED_PARTIES' THEN
           IF (p_sql_str IS NULL) THEN
               p_sql_str := ' PARTY_OS, PARTY_OSR, BATCH_ID, INT_ROW_ID' ;
           ELSE
               p_sql_str := p_sql_str || ', PARTY_OS, PARTY_OSR, BATCH_ID, INT_ROW_ID' ;
           END IF;
        ELSIF p_entity_name = 'HZ_STAGED_PARTY_SITES' THEN
           is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'PARTY_SITES','ADDRESS');--using_address(p_rule_id);
           IF (p_sql_str IS NULL) THEN
               p_sql_str := ' PARTY_OS, PARTY_OSR, PARTY_SITE_OS, PARTY_SITE_OSR, BATCH_ID, INT_ROW_ID';
           ELSE
               p_sql_str := p_sql_str || ', PARTY_OS, PARTY_OSR, PARTY_SITE_OS, PARTY_SITE_OSR, BATCH_ID, INT_ROW_ID';
           END IF;
           IF (is_using_allow_cust_attr = 'Y') THEN
--               p_sql_str := p_sql_str || ', TX3, TX4, TX26, TX27 ';
                get_cust_insert_str ('PARTY_SITES', p_rule_id, l_sql_str, 'PS', 'ADDRESS', null);
                p_sql_str := p_sql_str || l_sql_str;
            END IF;
        ELSIF p_entity_name = 'HZ_STAGED_CONTACT_POINTS' THEN
           is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'CONTACT_POINTS','RAW_PHONE_NUMBER');--using_raw_ph_no(p_rule_id);
           IF (p_sql_str IS NULL) THEN
               p_sql_str := ' PARTY_OS, PARTY_OSR, PARTY_SITE_OS, PARTY_SITE_OSR, CONTACT_PT_OS, CONTACT_PT_OSR, BATCH_ID, INT_ROW_ID, CONTACT_POINT_TYPE';
           ELSE
               p_sql_str := p_sql_str || ', PARTY_OS, PARTY_OSR, PARTY_SITE_OS, PARTY_SITE_OSR, CONTACT_PT_OS, CONTACT_PT_OSR, BATCH_ID, INT_ROW_ID, CONTACT_POINT_TYPE';
           END IF;
           IF (is_using_allow_cust_attr = 'Y') THEN
--                p_sql_str := p_sql_str || ', TX10, TX158 ';
                get_cust_insert_str ('CONTACT_POINTS', p_rule_id, l_sql_str, 'CP', 'RAW_PHONE_NUMBER', null);
                p_sql_str := p_sql_str || l_sql_str;
            END IF;
        ELSIF p_entity_name = 'HZ_STAGED_CONTACTS' THEN
           is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'CONTACTS','CONTACT_NAME');--using_contact_name(p_rule_id);
           IF (p_sql_str is NULL) THEN
               p_sql_str := ' PARTY_OS, PARTY_OSR, CONTACT_OS, CONTACT_OSR, BATCH_ID, INT_ROW_ID ';
           ELSE
               p_sql_str := p_sql_str || ', PARTY_OS, PARTY_OSR, CONTACT_OS, CONTACT_OSR, BATCH_ID, INT_ROW_ID ';
           END IF;
           IF (is_using_allow_cust_attr = 'Y') THEN
--                p_sql_str := p_sql_str || ', TX2, TX5, TX6, TX156 ';
                get_cust_insert_str ('CONTACTS', p_rule_id, l_sql_str, NULL, 'CONTACT_NAME', null);
                p_sql_str := p_sql_str || l_sql_str;
           END IF;
        ELSE
            IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                fnd_log.string(fnd_log.LEVEL_ERROR,G_PKG_NAME||l_procedure_name,'p_et_point = ''INT_TCA'', p_entity_name = '||p_entity_name);
            END IF;
       END IF;
    ELSE
        IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
             fnd_log.string(fnd_log.LEVEL_ERROR,G_PKG_NAME||l_procedure_name,'p_et_point = '|| p_et_point);
        END IF;
    END IF;
      EXCEPTION WHEN OTHERS THEN
          RAISE FND_API.G_EXC_ERROR;

END get_insert_str;

PROCEDURE get_cust_insert_val_str (
    p_entity_name       IN VARCHAR2,
    p_rule_id     IN NUMBER,
    p_sql_str IN OUT NOCOPY VARCHAR2,
    p_et_point IN VARCHAR2,
    p_attr_name IN VARCHAR2
) IS
 is_first BOOLEAN := TRUE;
 is_using_allow_cust_attr VARCHAR2(1) := 'N';
 l_procedure_name VARCHAR2(30) := '.GET_CUST_INSERT_VAL_STR' ;
 l_table_name VARCHAR2(30);
 BEGIN
   get_table_name(p_entity_name, l_table_name);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
    END IF;
      FOR TX IN ( select STAGED_ATTRIBUTE_COLUMN
            from hz_trans_functions_b
            where attribute_id in (select attribute_id
            from hz_trans_attributes_b
            where attribute_name = p_attr_name
            and entity_name = p_entity_name)
            and function_id in (select function_id
            from hz_match_rule_primary e, hz_primary_trans d
            where match_rule_id = p_rule_id
            and e.PRIMARY_ATTRIBUTE_ID = d.PRIMARY_ATTRIBUTE_ID
            union
            select function_id
            from hz_match_rule_secondary g, hz_secondary_trans f
            where f.SECONDARY_ATTRIBUTE_ID = g.SECONDARY_ATTRIBUTE_ID
            and match_rule_id = p_rule_id)
            order by STAGED_ATTRIBUTE_COLUMN
            ) LOOP
            IF is_first THEN
               is_first := false;
               p_sql_str := ', H_'||p_et_point||'_CUST_' || TX.STAGED_ATTRIBUTE_COLUMN || '(I)' ;
            ELSE
               p_sql_str := p_sql_str || ', H_'||p_et_point||'_CUST_' || TX.STAGED_ATTRIBUTE_COLUMN || '(I)' ;
            END IF;
       END LOOP;
END   get_cust_insert_val_str;

PROCEDURE get_insert_val_str (
    p_entity_name       IN VARCHAR2,
    p_rule_id     IN NUMBER,
    p_sql_str IN OUT NOCOPY VARCHAR2,
    p_et_point IN VARCHAR2
) IS
 is_first BOOLEAN := TRUE;
 is_using_allow_cust_attr VARCHAR2(1) := 'N';
 l_procedure_name VARCHAR2(30) := '.GET_INSERT_VAL_STR' ;
 l_table_name VARCHAR2(30);
 l_sql_str VARCHAR2(255);
 BEGIN
   get_table_name(p_entity_name, l_table_name);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
    END IF;
      FOR TX IN ( select STAGED_ATTRIBUTE_COLUMN
            from hz_trans_functions_b
            where function_id in (select function_id
            from hz_match_rule_primary e, hz_primary_trans d
            where e.PRIMARY_ATTRIBUTE_ID = d.PRIMARY_ATTRIBUTE_ID
            and match_rule_id = p_rule_id
            union
            select function_id
            from hz_match_rule_secondary g, hz_secondary_trans f
            where f.SECONDARY_ATTRIBUTE_ID = g.SECONDARY_ATTRIBUTE_ID
            and match_rule_id = p_rule_id)
            and nvl(active_flag, 'Y') <> 'N'
            and staged_attribute_table = p_entity_name
            and attribute_id not in (
                    select attribute_id
                    from hz_trans_attributes_b
                    where  custom_attribute_procedure is not  null
                    or HZ_IMP_DQM_STAGE.EXIST_COL(attribute_name, p_entity_name) = 'N'

            ) order by STAGED_ATTRIBUTE_COLUMN
            ) LOOP
            IF is_first THEN
               is_first := false;
               p_sql_str := '          H_' || TX.STAGED_ATTRIBUTE_COLUMN || '(I)' ;
            ELSE
               p_sql_str := p_sql_str || ', H_' || TX.STAGED_ATTRIBUTE_COLUMN || '(I)' ;
            END IF;
       END LOOP;
    IF (p_et_point = 'INT_INT') THEN
       IF p_entity_name = 'HZ_STAGED_PARTIES' THEN
           IF (p_sql_str IS NULL) THEN
               p_sql_str := '  H_P_PARTY_OS(I),  H_P_PARTY_OSR(I),  H_P_PARTY_ID(I), P_BATCH_ID, H_P_ROW_ID(I)' ;
           ELSE
               p_sql_str := p_sql_str || ',  H_P_PARTY_OS(I),  H_P_PARTY_OSR(I),  H_P_PARTY_ID(I), P_BATCH_ID, H_P_ROW_ID(I)' ;
           END IF;
        ELSIF p_entity_name = 'HZ_STAGED_PARTY_SITES' THEN
           is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'PARTY_SITES','ADDRESS');--  using_address(p_rule_id);
           IF (p_sql_str IS NULL) THEN
               p_sql_str := ' H_P_PARTY_SITE_ID(I), H_P_PARTY_ID(I), H_P_PARTY_OS(I), H_P_PARTY_OSR(I), H_P_PS_OS(I), H_P_PS_OSR(I), H_P_N_PARTY(I), P_BATCH_ID, H_P_ROW_ID(I) ';
           ELSE
               p_sql_str := p_sql_str || ', H_P_PARTY_SITE_ID(I), H_P_PARTY_ID(I), H_P_PARTY_OS(I), H_P_PARTY_OSR(I), H_P_PS_OS(I), H_P_PS_OSR(I), H_P_N_PARTY(I), P_BATCH_ID, H_P_ROW_ID(I) ';
           END IF;
           IF (is_using_allow_cust_attr = 'Y') THEN
--                p_sql_str := p_sql_str || ', H_P_PS_CUST_TX3(I), H_P_PS_CUST_TX4(I), H_P_PS_CUST_TX26(I), H_P_PS_CUST_TX27(I) ';
                get_cust_insert_val_str ('PARTY_SITES', p_rule_id, l_sql_str, 'PS', 'ADDRESS');
                p_sql_str := p_sql_str || l_sql_str;
            END IF;
        ELSIF p_entity_name = 'HZ_STAGED_CONTACT_POINTS' THEN
           is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'CONTACT_POINTS','RAW_PHONE_NUMBER');--using_raw_ph_no(p_rule_id);
           IF (p_sql_str IS NULL) THEN
               p_sql_str := ' H_P_PARTY_SITE_ID(I), H_P_PARTY_ID(I), H_P_PARTY_OS(I), H_P_PARTY_OSR(I), H_P_PS_OS(I), H_P_PS_OSR(I) ';
               p_sql_str := p_sql_str || ', H_P_CONTACT_POINT_ID(I), H_P_CP_OS(I), H_P_CP_OSR(I), H_P_N_PARTY(I), P_BATCH_ID, H_P_ROW_ID(I), H_P_CP_TYPE(I) ';
            ELSE
               p_sql_str := p_sql_str || ', H_P_PARTY_SITE_ID(I), H_P_PARTY_ID(I), H_P_PARTY_OS(I), H_P_PARTY_OSR(I), H_P_PS_OS(I), H_P_PS_OSR(I) ';
               p_sql_str := p_sql_str || ', H_P_CONTACT_POINT_ID(I), H_P_CP_OS(I), H_P_CP_OSR(I), H_P_N_PARTY(I), P_BATCH_ID, H_P_ROW_ID(I), H_P_CP_TYPE(I) ';
            END IF;
           IF (is_using_allow_cust_attr = 'Y') THEN
--                p_sql_str := p_sql_str || ', H_P_CP_CUST_TX10(I), H_P_CP_CUST_TX158(I) ';
                get_cust_insert_val_str ('CONTACT_POINTS', p_rule_id, l_sql_str, 'CP', 'RAW_PHONE_NUMBER');
                p_sql_str := p_sql_str || l_sql_str;
           END IF;
        ELSIF p_entity_name = 'HZ_STAGED_CONTACTS' THEN
           is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'CONTACTS','CONTACT_NAME');--using_contact_name(p_rule_id);
           IF (p_sql_str IS NULL) THEN
               p_sql_str := ' H_P_SUBJECT_OS(I), H_P_SUBJECT_OSR(I), H_P_CONTACT_OS(I), H_P_CONTACT_OSR(I), H_P_N_PARTY(I), P_BATCH_ID, H_P_ROW_ID(I), H_CT_OBJ_ID(I) ';
           ELSE
               p_sql_str := p_sql_str || ', H_P_SUBJECT_OS(I), H_P_SUBJECT_OSR(I), H_P_CONTACT_OS(I), H_P_CONTACT_OSR(I), H_P_N_PARTY(I), P_BATCH_ID, H_P_ROW_ID(I), H_CT_OBJ_ID(I) ';
           END IF;
           IF (is_using_allow_cust_attr = 'Y') THEN
--                p_sql_str := p_sql_str || ', H_P_CT_CUST_2(I), H_P_CT_CUST_5(I), H_P_CT_CUST_6(I), H_P_CT_CUST_156(I) ';
                get_cust_insert_val_str ('CONTACTS', p_rule_id, l_sql_str, 'CT', 'CONTACT_NAME');
                p_sql_str := p_sql_str || l_sql_str;
           END IF;
        ELSE
            IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                fnd_log.string(fnd_log.LEVEL_ERROR,G_PKG_NAME||l_procedure_name,'p_et_point = ''INT_INT'', p_entity_name = '||p_entity_name);
            END IF;
       END IF;
     ELSIF (p_et_point = 'INT_TCA') THEN
       IF p_entity_name = 'HZ_STAGED_PARTIES' THEN
           IF (p_sql_str IS NULL) THEN
               p_sql_str := ' H_P_PARTY_OS(I),  H_P_PARTY_OSR(I), P_BATCH_ID, H_P_ROW_ID(I)' ;
           ELSE
               p_sql_str := p_sql_str || ',  H_P_PARTY_OS(I),  H_P_PARTY_OSR(I), P_BATCH_ID, H_P_ROW_ID(I)' ;
           END IF;
        ELSIF p_entity_name = 'HZ_STAGED_PARTY_SITES' THEN
           is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'PARTY_SITES','ADDRESS');--using_address(p_rule_id);
           IF (p_sql_str IS NULL) THEN
               p_sql_str := ' H_P_PARTY_OS(I), H_P_PARTY_OSR(I), H_P_PS_OS(I), H_P_PS_OSR(I), P_BATCH_ID, H_P_ROW_ID(I)';
           ELSE
               p_sql_str := p_sql_str || ', H_P_PARTY_OS(I), H_P_PARTY_OSR(I), H_P_PS_OS(I), H_P_PS_OSR(I), P_BATCH_ID, H_P_ROW_ID(I)';
           END IF;
           IF (is_using_allow_cust_attr = 'Y') THEN
--                p_sql_str := p_sql_str || ',  H_P_PS_CUST_TX3(I), H_P_PS_CUST_TX4(I), H_P_PS_CUST_TX26(I), H_P_PS_CUST_TX27(I) ';
                get_cust_insert_val_str ('PARTY_SITES', p_rule_id, l_sql_str, 'PS', 'ADDRESS');
                p_sql_str := p_sql_str || l_sql_str;
            END IF;
        ELSIF p_entity_name = 'HZ_STAGED_CONTACT_POINTS' THEN
           is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'CONTACT_POINTS','RAW_PHONE_NUMBER');--using_raw_ph_no(p_rule_id);
           IF (p_sql_str IS NULL) THEN
               p_sql_str := ' H_P_PARTY_OS(I), H_P_PARTY_OSR(I), H_P_PS_OS(I), H_P_PS_OSR(I)';
               p_sql_str := p_sql_str || ', H_P_CP_OS(I), H_P_CP_OSR(I), P_BATCH_ID, H_P_ROW_ID(I), H_P_CP_TYPE(I)';
           ELSE
               p_sql_str := p_sql_str || ', H_P_PARTY_OS(I), H_P_PARTY_OSR(I), H_P_PS_OS(I), H_P_PS_OSR(I)';
               p_sql_str := p_sql_str || ', H_P_CP_OS(I), H_P_CP_OSR(I), P_BATCH_ID, H_P_ROW_ID(I), H_P_CP_TYPE(I)';
           END IF;
           IF (is_using_allow_cust_attr = 'Y') THEN
--                p_sql_str := p_sql_str || ', H_P_CP_CUST_TX10(I), H_P_CP_CUST_TX158(I) ';
                get_cust_insert_val_str ('CONTACT_POINTS', p_rule_id, l_sql_str, 'CP', 'RAW_PHONE_NUMBER');
                p_sql_str := p_sql_str || l_sql_str;
           END IF;
        ELSIF p_entity_name = 'HZ_STAGED_CONTACTS' THEN
           is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'CONTACTS','CONTACT_NAME');--using_contact_name(p_rule_id);
           IF (p_sql_str IS NULL) THEN
                p_sql_str := ' H_P_SUBJECT_OS(I), H_P_SUBJECT_OSR(I), H_P_CONTACT_OS(I), H_P_CONTACT_OSR(I), P_BATCH_ID, H_P_ROW_ID(I) ';
           ELSE
                p_sql_str := p_sql_str || ', H_P_SUBJECT_OS(I), H_P_SUBJECT_OSR(I), H_P_CONTACT_OS(I), H_P_CONTACT_OSR(I), P_BATCH_ID, H_P_ROW_ID(I) ';
           END IF;
           IF (is_using_allow_cust_attr = 'Y') THEN
--                p_sql_str := p_sql_str || ', H_P_CT_CUST_2(I), H_P_CT_CUST_5(I), H_P_CT_CUST_6(I), H_P_CT_CUST_156(I) ';
                get_cust_insert_val_str ('CONTACTS', p_rule_id, l_sql_str, 'CT', 'CONTACT_NAME');
                p_sql_str := p_sql_str || l_sql_str;
           END IF;
        ELSE
            IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                fnd_log.string(fnd_log.LEVEL_ERROR,G_PKG_NAME||l_procedure_name,'p_et_point = ''INT_TCA'', p_entity_name = '||p_entity_name);
            END IF;
       END IF;
     ELSE
            IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                fnd_log.string(fnd_log.LEVEL_ERROR,G_PKG_NAME||l_procedure_name,'p_et_point = '|| p_et_point);
            END IF;
     END IF;
      EXCEPTION WHEN OTHERS THEN
          RAISE FND_API.G_EXC_ERROR;

END get_insert_val_str;

/*
FUNCTION using_address(
    p_rule_id     IN NUMBER
    ) RETURN VARCHAR2 IS

    using_address VARCHAR2(1) := 'N';
     CURSOR c1 is    select 'Y'
     from hz_match_rule_primary a, hz_match_rule_secondary b
     where a.match_rule_id = b.match_rule_id
     and a.match_rule_id = p_rule_id
     -- check if one really needs the below condition
--     and a.attribute_id = b.attribute_id
         and a.attribute_id in (
     select attribute_id
     from hz_trans_attributes_b
      where entity_name = 'PARTY_SITES'
     and attribute_name = 'ADDRESS');
    l_procedure_name VARCHAR2(30) := '.USING_RAW_PH_NO' ;
    BEGIN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
     END IF;
       OPEN c1;
         LOOP
         FETCH c1 into using_address;
         EXIT WHEN c1%NOTFOUND;
        END LOOP;
        CLOSE c1;
    RETURN using_address;
    EXCEPTION WHEN OTHERS THEN
        using_address := 'N';
    END using_address;


FUNCTION using_raw_ph_no(
    p_rule_id     IN NUMBER
    ) RETURN VARCHAR2 IS

    using_raw_ph_no VARCHAR2(1) := 'N';
     CURSOR c1 is    select 'Y'
     from hz_match_rule_primary a, hz_match_rule_secondary b
     where a.match_rule_id = b.match_rule_id
     and a.match_rule_id = p_rule_id
     -- check if one really needs the below condition
--     and a.attribute_id = b.attribute_id
         and a.attribute_id in (
     select attribute_id
     from hz_trans_attributes_b
      where entity_name = 'CONTACT_POINTS'
     and attribute_name = 'RAW_PHONE_NUMBER');
    l_procedure_name VARCHAR2(30) := '.USING_RAW_PH_NO' ;
    BEGIN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
     END IF;
       OPEN c1;
         LOOP
         FETCH c1 into using_raw_ph_no;
         EXIT WHEN c1%NOTFOUND;
        END LOOP;
        CLOSE c1;
    RETURN using_raw_ph_no;
    EXCEPTION WHEN OTHERS THEN
        using_raw_ph_no := 'N';
    END using_raw_ph_no;


FUNCTION using_contact_name(
    p_rule_id     IN NUMBER
    ) RETURN VARCHAR2 IS

    using_contact_name VARCHAR2(1) := 'N';
     CURSOR c1 is    select 'Y'
     from hz_match_rule_primary a, hz_match_rule_secondary b
     where a.match_rule_id = b.match_rule_id
     and a.match_rule_id = p_rule_id
     -- check if one really needs the below condition
--     and a.attribute_id = b.attribute_id
         and a.attribute_id in (
     select attribute_id
     from hz_trans_attributes_b
     where entity_name = 'CONTACTS'
     and attribute_name = 'CONTACT_NAME' );
    l_procedure_name VARCHAR2(30) := '.USING_CONTACT_NAME' ;
    BEGIN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
     END IF;
       OPEN c1;
         LOOP
         FETCH c1 into using_contact_name;
         EXIT WHEN c1%NOTFOUND;
        END LOOP;
        CLOSE c1;
    RETURN using_contact_name;
    EXCEPTION WHEN OTHERS THEN
        using_contact_name := 'N';
    END using_contact_name;

FUNCTION using_org_name(
    p_rule_id     IN NUMBER
    ) RETURN VARCHAR2 IS

    using_contact_name VARCHAR2(1) := 'N';
     CURSOR c1 is    select 'Y'
     from hz_match_rule_primary a, hz_match_rule_secondary b
     where a.match_rule_id = b.match_rule_id
     and a.match_rule_id = p_rule_id
     and a.attribute_id = b.attribute_id
         and a.attribute_id in (
     select attribute_id
     from hz_trans_attributes_b
     where entity_name = 'CONTACTS'
     and attribute_name = 'CONTACT_NAME' );
    l_procedure_name VARCHAR2(30) := '.USING_CONTACT_NAME' ;
    BEGIN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
     END IF;
       OPEN c1;
         LOOP
         FETCH c1 into using_contact_name;
         EXIT WHEN c1%NOTFOUND;
        END LOOP;
        CLOSE c1;
    RETURN using_contact_name;
    EXCEPTION WHEN OTHERS THEN
        using_contact_name := 'N';
    END using_org_name;
*/

PROCEDURE get_custom_attr_cur(
    	p_rule_id IN NUMBER,
        p_et_name IN VARCHAR,
        p_attr_name IN VARCHAR2,
        x_custom_cur IN OUT NOCOPY StageImpContactCurTyp
 ) IS
 BEGIN
     OPEN x_custom_cur FOR
         select ATTRIBUTE_NAME, USER_DEFINED_ATTRIBUTE_NAME, PROCEDURE_NAME, STAGED_ATTRIBUTE_COLUMN, b.attribute_id
            from hz_trans_functions_b b, hz_trans_attributes_vl c
            where b.attribute_id = c.attribute_id
            --Fix for bug 4669257. Removing the hardcoded reference below.
            --and userenv('LANG') = 'US'
            and b.function_id in (select function_id
            from hz_match_rule_primary d, hz_primary_trans e
            where match_rule_id = p_rule_id
            and d.primary_attribute_id = e.primary_attribute_id
            union
            select function_id
            from hz_match_rule_secondary f, hz_secondary_trans g
            where f.SECONDARY_ATTRIBUTE_ID = g.SECONDARY_ATTRIBUTE_ID -- b.attribute_id = c.attribute_id
            and match_rule_id = p_rule_id)
            and nvl(active_flag, 'Y') <> 'N'
            and entity_name = p_et_name
            and attribute_name = p_attr_name;
 END get_custom_attr_cur;

PROCEDURE get_trans_proc (
    p_entity_name       IN VARCHAR2,
    p_rule_id     IN NUMBER,
    l_trans_list IN OUT NOCOPY coltab
) IS

l_str VARCHAR2(2000);
is_using_allow_cust_attr VARCHAR(1) := 'N';
i NUMBER := 0;

l_procedure_name VARCHAR2(30) := '.GET_TRANS_PROC' ;
l_table_name VARCHAR2(30);
l_custom_cur StageImpContactCurTyp;
l_attribute_name VARCHAR2(255);
l_user_defined_attribute_name VARCHAR2(255);
l_proc_name VARCHAR2(255);
l_staged_attribute_column VARCHAr2(255);
l_attribute_id NUMBER;

-- VJN Introduced for Conditional Word Replacements
NONE BOOLEAN := TRUE ;
BEGIN
    get_table_name(p_entity_name, l_table_name);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
     END IF;

     -- VJN ADDED CODE FOR TRACKING CONDITION ATTRIBUTES AT THIS ENTITY LEVEL
    FOR TX IN (                               ---------->   CONDITIONAL REPLACEMENT CODE ENDS
 	         select STAGED_ATTRIBUTE_COLUMN, b.attribute_id
             from hz_trans_functions_b b, hz_trans_attributes_vl c
             where b.attribute_id = c.attribute_id
             --Fix for bug 4669257. Removing the hardcoded reference below.
             --and userenv('LANG') = 'US'
             and b.function_id in
                  (select function_id
                   from hz_match_rule_primary d, hz_primary_trans e
                   where match_rule_id = p_rule_id
                   and d.primary_attribute_id = e.primary_attribute_id
                   union
                   select function_id
                   from hz_match_rule_secondary f, hz_secondary_trans g
                   where f.SECONDARY_ATTRIBUTE_ID = g.SECONDARY_ATTRIBUTE_ID -- b.attribute_id = c.attribute_id
                   and match_rule_id = p_rule_id)
             and nvl(active_flag, 'Y') <> 'N'
             and entity_name = p_entity_name
             and custom_attribute_procedure is null
             and HZ_IMP_DQM_STAGE.EXIST_COL(attribute_name, p_entity_name) = 'Y'
             order by STAGED_ATTRIBUTE_COLUMN
             ) LOOP
                -- DO THIS IF AND ONLY IF THIS ATTRIBUTE IS A CONDITION ATTRIBUTE
	        IF HZ_WORD_CONDITIONS_PKG.is_a_cond_attrib( TX.ATTRIBUTE_ID)
     		THEN
             		-- ONE TIME ONLY
             		IF NONE
             		THEN
             			l_trans_list(i) := '----------- SETTING GLOBAL CONDITION RECORD AT THE ' || p_entity_name || ' LEVEL ---------';
             			i := i + 1 ;
             			NONE := FALSE ;
             		END IF ;

                    l_trans_list(i) := '      HZ_WORD_CONDITIONS_PKG.set_gbl_condition_rec (' ||
	              	                                TX.ATTRIBUTE_ID || ',' || 'H_' || TX.ATTRIBUTE_ID || 'E(I) );' ;
             		i := i + 1;
                END IF;

             END LOOP ;        ---------->   CONDITIONAL REPLACEMENT CODE ENDS



     IF p_entity_name = 'PARTY' THEN
        l_trans_list(i) := '        HZ_TRANS_PKG.set_party_type(H_P_P_TYPE(I));';
        i := i + 1;
      END IF;
      FOR TX IN ( select ATTRIBUTE_NAME, USER_DEFINED_ATTRIBUTE_NAME, PROCEDURE_NAME, STAGED_ATTRIBUTE_COLUMN, b.attribute_id
            from hz_trans_functions_b b, hz_trans_attributes_vl c
            where b.attribute_id = c.attribute_id
            --Fix for bug 4669257. Removing the hardcoded reference below.
            --and userenv('LANG') = 'US'
            and b.function_id in
                 (select function_id
                  from hz_match_rule_primary d, hz_primary_trans e
                  where match_rule_id = p_rule_id
                  and d.primary_attribute_id = e.primary_attribute_id
                  union
                  select function_id
                  from hz_match_rule_secondary f, hz_secondary_trans g
                  where f.SECONDARY_ATTRIBUTE_ID = g.SECONDARY_ATTRIBUTE_ID -- b.attribute_id = c.attribute_id
                  and match_rule_id = p_rule_id)
            and nvl(active_flag, 'Y') <> 'N'
            and entity_name = p_entity_name
            and custom_attribute_procedure is null
            and HZ_IMP_DQM_STAGE.EXIST_COL(attribute_name, p_entity_name) = 'Y'
--            and attribute_name not in
--           ('SIC_CODE', 'SIC_CODE_TYPE', 'TAX_NAME', 'CATEGORY_CODE', 'IDENTIFYING_ADDRESS_FLAG', 'STATUS', 'PRIMARY_FLAG', 'REFERENCE_USE_FLAG' )

            order by STAGED_ATTRIBUTE_COLUMN
            ) LOOP

            IF has_trx_context(TX.PROCEDURE_NAME) THEN
                    l_str := '        H_' || TX.STAGED_ATTRIBUTE_COLUMN || '(I) := ' || TX.PROCEDURE_NAME || '(H_' || TX.ATTRIBUTE_ID || 'E(I), NULL, '''|| TX.ATTRIBUTE_NAME || ''', '''|| p_entity_name || ''', ''SEARCH'' );' ;
            ELSE
                    l_str := '        H_' || TX.STAGED_ATTRIBUTE_COLUMN || '(I) := ' || TX.PROCEDURE_NAME || '(H_' || TX.ATTRIBUTE_ID || 'E(I), NULL, '''|| TX.ATTRIBUTE_NAME || ''', '''|| p_entity_name || ''');' ;
            END IF;
                    l_trans_list(i) := l_str;
                    l_str := '';
                    i := i + 1;
            END LOOP;
       IF p_entity_name = 'CONTACTS' THEN
       is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'CONTACTS','CONTACT_NAME');--using_contact_name(p_rule_id);
        IF (is_using_allow_cust_attr = 'Y') THEN
            -- for dynamic transformation for custom atribute
            get_custom_attr_cur(p_rule_id, p_entity_name, 'CONTACT_NAME', l_custom_cur);
            LOOP FETCH l_custom_cur into l_attribute_name, l_user_defined_attribute_name, l_proc_name, l_staged_attribute_column, l_attribute_id;
            EXIT when l_custom_cur%NOTFOUND;
            IF has_trx_context(l_proc_name) THEN
                    l_str := '        H_CT_CUST_'||l_staged_attribute_column||'(I) := ' || l_proc_name || '(H_CT_NAME(I), NULL, '''|| l_attribute_name || ''', '''|| p_entity_name || ''', ''SEARCH'' );' ;
            ELSE
                    l_str := '        H_CT_CUST_'||l_staged_attribute_column||'(I) := ' || l_proc_name || '(H_CT_NAME(I), NULL, '''|| l_attribute_name || ''', '''|| p_entity_name || '''); ' ;
            END IF;
                    l_trans_list(i) := l_str;
                    l_str := '';
                    i := i + 1;
            END LOOP;
/*
          l_trans_list(i + 2) := '        H_P_CT_CUST_2(I) := HZ_TRANS_PKG.EXACT_PADDED(H_CT_NAME(I), NULL, ''CONTACT_NAME'', ''CONTACTS'');';
          l_trans_list(i + 3) := '        H_P_CT_CUST_5(I) := HZ_TRANS_PKG.WRPERSON_EXACT(H_CT_NAME(I), NULL, ''CONTACT_NAME'', ''CONTACTS'');';
          l_trans_list(i + 1) := '        H_P_CT_CUST_6(I) := HZ_TRANS_PKG.WRPERSON_CLEANSE(H_CT_NAME(I), NULL, ''CONTACT_NAME'', ''CONTACTS'');';
          l_trans_list(i) := '        H_P_CT_CUST_156(I) := HZ_TRANS_PKG.SOUNDX(H_CT_NAME(I), NULL, ''CONTACT_NAME'', ''CONTACTS'');';
          */
        END IF;
       ELSIF p_entity_name = 'CONTACT_POINTS' THEN
           is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'CONTACT_POINTS','RAW_PHONE_NUMBER');--using_raw_ph_no(p_rule_id);
            IF (is_using_allow_cust_attr = 'Y') THEN
            -- for dynamic transformation for custom atribute
            get_custom_attr_cur(p_rule_id, p_entity_name, 'RAW_PHONE_NUMBER', l_custom_cur);
            LOOP FETCH l_custom_cur into l_attribute_name, l_user_defined_attribute_name, l_proc_name, l_staged_attribute_column, l_attribute_id;
            EXIT when l_custom_cur%NOTFOUND;
            IF has_trx_context(l_proc_name) THEN
                    l_str := '        H_CP_CUST_'||l_staged_attribute_column||'(I) := ' || l_proc_name || '(H_P_CP_R_PH_NO(I), NULL, '''|| l_attribute_name || ''', '''|| p_entity_name || ''', ''SEARCH'' );' ;
            ELSE
                    l_str := '        H_CP_CUST_'||l_staged_attribute_column||'(I) := ' || l_proc_name || '(H_P_CP_R_PH_NO(I), NULL, '''|| l_attribute_name || ''', '''|| p_entity_name || '''); ' ;
            END IF;
                    l_trans_list(i) := l_str;
                    l_str := '';
                    i := i + 1;
            END LOOP;
/*
              l_trans_list(i + 1) := '        H_P_CP_CUST_TX10(I) := HZ_TRANS_PKG.REVERSE_PHONE_NUMBER(H_P_CP_R_PH_NO(I), NULL, ''RAW_PHONE_NUMBER'', ''CONTACT_POINTS''); ';
              l_trans_list(i) := '        H_P_CP_CUST_TX158(I) := HZ_TRANS_PKG.RM_SPLCHAR(H_P_CP_R_PH_NO(I), NULL, ''RAW_PHONE_NUMBER'', ''CONTACT_POINTS''); ';  */
            END IF;
       ELSIF p_entity_name = 'PARTY_SITES' THEN
             is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'PARTY_SITES','ADDRESS');--using_address(p_rule_id);
             IF ( is_using_allow_cust_attr = 'Y') THEN
               -- for dynamic transformation for custom atribute
               get_custom_attr_cur(p_rule_id, p_entity_name, 'ADDRESS', l_custom_cur);
               LOOP FETCH l_custom_cur into l_attribute_name, l_user_defined_attribute_name, l_proc_name, l_staged_attribute_column, l_attribute_id;
               EXIT when l_custom_cur%NOTFOUND;
                IF has_trx_context(l_proc_name) THEN
                    l_str := '        H_PS_CUST_'||l_staged_attribute_column||'(I) := ' || l_proc_name || '(H_P_PS_ADD(I), NULL, '''|| l_attribute_name || ''', '''|| p_entity_name || ''', ''SEARCH'' );' ;
                ELSE
                    l_str := '        H_PS_CUST_'||l_staged_attribute_column||'(I) := ' || l_proc_name || '(H_P_PS_ADD(I), NULL, '''|| l_attribute_name || ''', '''|| p_entity_name || '''); ' ;
                 END IF;
                    l_trans_list(i) := l_str;
                    l_str := '';
                    i := i + 1;
                END LOOP;
/*
               l_trans_list(i) := '        H_P_PS_CUST_TX3(I) := HZ_TRANS_PKG.WRADDRESS_EXACT(H_P_PS_ADD(I), NULL, ''ADDRESS'', ''PARTY_SITES''); ';
               l_trans_list(i + 1) := '        H_P_PS_CUST_TX4(I) := HZ_TRANS_PKG.WRADDRESS_CLEANSE(H_P_PS_ADD(I), NULL, ''ADDRESS'', ''PARTY_SITES''); ';
               l_trans_list(i + 2) := '        H_P_PS_CUST_TX26(I) := HZ_TRANS_PKG.BASIC_WRADDR(H_P_PS_ADD(I), NULL, ''ADDRESS'', ''PARTY_SITES'', ''SEARCH''); ';
               l_trans_list(i + 3) := '        H_P_PS_CUST_TX27(I) := HZ_TRANS_PKG.BASIC_CLEANSE_WRADDR(H_P_PS_ADD(I), NULL, ''ADDRESS'', ''PARTY_SITES'', ''SEARCH''); '; */
             END IF;
       END IF;
      EXCEPTION WHEN OTHERS THEN
          RAISE FND_API.G_EXC_ERROR;
END get_trans_proc;

PROCEDURE gen_pop_parties (
    p_rule_id   IN    NUMBER
)
IS
l_sel_str VARCHAR2(4000) := NULL;
x_bool VARCHAR2(1);
l_procedure_name VARCHAR2(30) := '.GEN_POP_PARTIES' ;
BEGIN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
    END IF;
  l('PROCEDURE pop_parties (');
  l('   	 p_batch_id IN	NUMBER,');
  l('        p_from_osr                       IN   VARCHAR2,');
  l('   	 p_to_osr                         IN   VARCHAR2,');
  l('        p_batch_mode_flag                IN   VARCHAR2 ');
  l(') IS ');
  l(' l_last_fetch BOOLEAN := FALSE;');
  l(' p_party_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('');
  l(' count NUMBER := 0;');
  l('  BEGIN ');
  x_bool := 'N';
  chk_et_req('PARTY', p_rule_id, x_bool);
  IF (x_bool = 'Y') THEN
  l('-- query for interface to TCA');
  l('        open p_party_cur FOR ');
  get_select_str('PARTY', p_rule_id, l_sel_str, 'INT_INT',null);
  l( l_sel_str);
-- dbms_output.put_line('l_sel_str get_select_str ' || l_sel_str);
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;
  l_sel_str := '';
--              select a.organization_name, a.duns_number_c, a.tax_reference,
--                    a.party_orig_system, a.party_orig_system_reference, b.party_id
  l('    		from hz_imp_parties_int a, hz_imp_parties_sg b ');
  l('    		where  b.action_flag = ''I''');
  l('    		and b.int_row_id = a.rowid ');
  l('            and a.batch_id = p_batch_id ');
  l('            and b.party_orig_system_reference >=  p_from_osr ');
  l('            and b.party_orig_system_reference <= p_to_osr  ');
  l('            and b.batch_mode_flag = p_batch_mode_flag ');
  l('            and interface_status is null ; ');
  l('   LOOP ');
  l('    FETCH p_party_cur BULK COLLECT INTO ');
  get_trans_str('PARTY', p_rule_id, l_sel_str, 'INT_INT');
  l( l_sel_str);
-- dbms_output.put_line('l_sel_str get_trans_str ' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;
  l_sel_str := '';
/*         H_TX4
         ,H_TX11
         ,H_TX41
		, H_P_PARTY_OS
		, H_P_PARTY_OSR
      	, H_P_PARTY_ID */
  l('          LIMIT g_limit; ');
  l('    IF (p_party_cur%NOTFOUND)  THEN ');
  l('      l_last_fetch:=TRUE;');
  l('    END IF;');
  l('   ');
  l('    IF H_P_PARTY_OS.COUNT=0 AND l_last_fetch THEN');
  l('      EXIT;');
  l('    END IF;');
  l('   ');
  l('    FOR I in H_P_PARTY_OSR.FIRST..H_P_PARTY_OSR.LAST LOOP');
           -- pass STAGE wherever p_context is required.
  get_trans_proc('PARTY', p_rule_id, l_trans_list);
  FOR I in l_trans_list.FIRST..l_trans_list.LAST LOOP
--    dbms_output.put_line('l_trans_list get_trans_proc ' || l_trans_list(I));
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_trans_list(I));
    END IF;
    l(l_trans_list(I));
    l_trans_list.DELETE(I);
  END LOOP  ;
/*        H_TX4(I):=HZ_TRANS_PKG.WRNAMES_CLEANSE(H_TX4(I),NULL, 'ORGANIZATION_NAME','PARTY','STAGE');
        H_TX11(I):=HZ_TRANS_PKG.EXACT_PADDED(H_TX11(I),NULL, 'SIC_CODE','PARTY');
        H_TX41(I):=HZ_TRANS_PKG.EXACT(H_TX41(I),NULL, 'DUNS_NUMBER_C','PARTY');
        -- H_TX44(I):=HZ_TRANS_PKG.RM_SPLCHAR(H_TX44(I),NULL, 'TAX_REFERENCE','PARTY');
*/
  l('    END LOOP;');
  l('    SAVEPOINT pop_parties;');
  l('    BEGIN ');
  l('      FORALL I in H_P_PARTY_OSR.FIRST..H_P_PARTY_OSR.LAST');
  l('        INSERT INTO HZ_SRCH_PARTIES (');
  get_insert_str('HZ_STAGED_PARTIES', p_rule_id, l_sel_str, 'INT_INT');
  l( l_sel_str);
-- dbms_output.put_line('l_sel_str get_insert_str ' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;
  l_sel_str := '';

/*	       PARTY_ID
		  , PARTY_OS
		  , PARTY_OSR
           , TX4
           , TX11
           , TX41
--           , TX44 */
  l('        ) VALUES ( ');
  get_insert_val_str('HZ_STAGED_PARTIES', p_rule_id, l_sel_str, 'INT_INT');
  l( l_sel_str);
-- dbms_output.put_line('l_sel_str get_insert_val_str ' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE, G_PKG_NAME||l_procedure_name, l_sel_str);
    END IF;
  l_sel_str := '';
  /*
          H_P_PARTY_ID(I)
        , H_P_PARTY_OS(I)
 	     , H_P_PARTY_OSR(I)
        , H_TX4(I)
        , H_TX11(I)
        , H_TX41(I)
    */
--        , H_TX44(I)
  l('            ); ');
  l('      EXCEPTION ');
  l('        WHEN OTHERS THEN');
  l('          ROLLBACK to pop_parties;');
  l(' --          dbms_output.put_line(SubStr(''Error ''||TO_CHAR(SQLCODE)||'': ''||SQLERRM, 1, 255));');
  l('          RAISE;');
  l('      END ;');
  l('      IF l_last_fetch THEN');
  l('        FND_CONCURRENT.AF_Commit;');
  l('        EXIT;');
  l('      END IF;');
  l('      FND_CONCURRENT.AF_Commit;');
  l('      ');
  l('   END LOOP; ');
  l('   CLOSE  p_party_cur; ');
   ELSE
     l(' null;');
   END IF;
  l('  END pop_parties; ');
      EXCEPTION WHEN OTHERS THEN
          RAISE FND_API.G_EXC_ERROR;
END gen_pop_parties;


PROCEDURE gen_pop_parties_int (
    p_rule_id   IN    NUMBER
)
IS
l_sel_str VARCHAR2(4000) := NULL;
x_bool VARCHAR2(1);
l_procedure_name VARCHAR2(30) := '.GEN_POP_PARTIES_INT' ;
BEGIN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.LEVEL_STATEMENT, G_PKG_NAME||l_procedure_name, 'Enter');
    END IF;
  x_bool := 'N';

l(' PROCEDURE pop_parties_int ( ');
l('    	 p_batch_id IN	NUMBER, ');
l('      p_from_osr                       IN   VARCHAR2, ');
l('    	 p_to_osr                         IN   VARCHAR2 ');
l(' ) IS  ');
l('  l_last_fetch BOOLEAN := FALSE; ');
l('  p_party_cur HZ_PARTY_STAGE.StageCurTyp; ');
l('  ');
l('  count NUMBER := 0; ');
l('  l_os VARCHAR2(30); ');
l('   BEGIN  ');
l('   l_os := HZ_IMP_DQM_STAGE.get_os(p_batch_id); ');
  chk_et_req('PARTY', p_rule_id, x_bool);
  IF (x_bool = 'Y') THEN
 -- query for interface to TCA
l('         open p_party_cur FOR ');
  get_select_str('PARTY', p_rule_id, l_sel_str, 'INT_TCA', NULL);
  l_sel_str := l_sel_str || ' , a.party_id '; --bug 5393826
  l( l_sel_str);
-- dbms_output.put_line('get_select_str (PARTY -int tca) ' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE, G_PKG_NAME||l_procedure_name, l_sel_str);
    END IF;
  l_sel_str := '';
/*            select a.organization_name, a.duns_number_c, a.tax_reference,
                    a.party_orig_system, a.party_orig_system_reference
                    */
l('    		from hz_imp_parties_int a  ');
l('    		where a.batch_id = p_batch_id  ');
l('         and a.party_orig_system_reference >= p_from_osr ');
l('         and a.party_orig_system_reference <= p_to_osr ');
l('         and a.party_orig_system = l_os; ');
l('    LOOP ');
l('    FETCH p_party_cur BULK COLLECT INTO ');
  get_trans_str('PARTY', p_rule_id, l_sel_str, 'INT_TCA');
  l_sel_str := l_sel_str || ' , H_P_PARTY_ID '; -- bug 5393826
  l( l_sel_str);
-- dbms_output.put_line('get_trans_str PARTY int tca ' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE, G_PKG_NAME||l_procedure_name, l_sel_str);
    END IF;
  l_sel_str := '';
/*         H_TX4
         ,H_TX11
         ,H_TX41
		, H_P_PARTY_OS
		, H_P_PARTY_OSR */
l('          LIMIT g_limit; ');
l('    IF p_party_cur%NOTFOUND THEN ');
l('      l_last_fetch:=TRUE; ');
l('    END IF; ');
l('    ');
l('    IF H_P_PARTY_OS.COUNT=0 AND l_last_fetch THEN ');
l('      EXIT; ');
l('    END IF; ');
l('    ');
l('    FOR I in H_P_PARTY_OSR.FIRST..H_P_PARTY_OSR.LAST LOOP ');
         -- pass STAGE  wherever p_context is required.
  get_trans_proc('PARTY', p_rule_id, l_trans_list);
  FOR I in l_trans_list.FIRST..l_trans_list.LAST LOOP
--    dbms_output.put_line('get_trans_proc (PARTY int tca)' || l_trans_list(I));
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE, G_PKG_NAME||l_procedure_name, l_trans_list(I));
    END IF;
    l(l_trans_list(I));
    l_trans_list.DELETE(I);
  END LOOP  ;
/*        H_TX4(I):=HZ_TRANS_PKG.WRNAMES_CLEANSE(H_TX4(I),NULL, 'ORGANIZATION_NAME','PARTY','STAGE');
        H_TX11(I):=HZ_TRANS_PKG.EXACT_PADDED(H_TX11(I),NULL, 'SIC_CODE','PARTY');
        H_TX41(I):=HZ_TRANS_PKG.EXACT(H_TX41(I),NULL, 'DUNS_NUMBER_C','PARTY');
        */
l('    END LOOP; ');
l('    SAVEPOINT pop_parties_int; ');
l('    BEGIN  ');
l('      FORALL I in H_P_PARTY_OSR.FIRST..H_P_PARTY_OSR.LAST ');
l('        INSERT INTO HZ_SRCH_PARTIES ( ');
  get_insert_str('HZ_STAGED_PARTIES', p_rule_id, l_sel_str, 'INT_TCA');
  l_sel_str := l_sel_str || ' , PARTY_ID '; -- bug 5393826
  l( l_sel_str);
-- dbms_output.put_line('get_insert_str PARTY int tca ' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE, G_PKG_NAME||l_procedure_name, l_sel_str);
    END IF;
  l_sel_str := '';
/*		   PARTY_OS
		  , PARTY_OSR
           , TX4
           , TX11
           , TX41*/
l('        ) VALUES ( ');
  get_insert_val_str('HZ_STAGED_PARTIES', p_rule_id, l_sel_str, 'INT_TCA');
   l_sel_str := l_sel_str || ' , H_P_PARTY_ID(I) '; -- bug 5393826
  l( l_sel_str);
-- dbms_output.put_line('l_sel_str get_insert_val_str ' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE, G_PKG_NAME||l_procedure_name, l_sel_str);
    END IF;
  l_sel_str := '';
/*         H_P_PARTY_OS(I)
 	     , H_P_PARTY_OSR(I)
        , H_TX4(I)
        , H_TX11(I)
        , H_TX41(I)
*/
l('            );  ');
l('      EXCEPTION  ');
l('        WHEN OTHERS THEN ');
l('          ROLLBACK to pop_parties_int; ');
l('--          dbms_output.put_line(SubStr(''Error ''||TO_CHAR(SQLCODE)||'': ''||SQLERRM, 1, 255)); ');
l('          RAISE; ');
l('      END ; ');
l('     IF l_last_fetch THEN ');
l('        FND_CONCURRENT.AF_Commit; ');
l('        EXIT; ');
l('      END IF; ');
l('      FND_CONCURRENT.AF_Commit; ');
l('       ');
l('  END LOOP; ');
l('   CLOSE  p_party_cur; ');
   ELSE
     l(' null; ');
   END IF;
l('  END pop_parties_int; ');
      EXCEPTION WHEN OTHERS THEN
          RAISE FND_API.G_EXC_ERROR;
END gen_pop_parties_int ;


PROCEDURE gen_pop_party_sites (
    p_rule_id   IN    NUMBER
)
IS
l_sel_str VARCHAR2(4000) := NULL;
x_bool VARCHAR2(1);
l_procedure_name VARCHAR2(30) := '.GEN_POP_PARTY_SITES' ;
BEGIN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
    END IF;
l('');
l('  PROCEDURE pop_party_sites ( ');
l('   	 p_batch_id IN	NUMBER, ');
l('      p_from_osr                       IN   VARCHAR2, ');
l('  	 p_to_osr                         IN   VARCHAR2, ');
l('      p_batch_mode_flag                IN   VARCHAR2 ');
l('    ) IS ');
l(' l_last_fetch BOOLEAN := FALSE; ');
l(' l_party_site_cur HZ_PARTY_STAGE.StageCurTyp; ');
l(' ');
l('  BEGIN ');
  x_bool := 'N';
  chk_et_req('PARTY_SITES', p_rule_id, x_bool);
  IF (x_bool = 'Y') THEN
l('-- query for interface to tca ');
l('		open l_party_site_cur for ');
  get_select_str('PARTY_SITES', p_rule_id, l_sel_str, 'INT_INT', DO_STD_CHK);
  l( l_sel_str);
-- dbms_output.put_line('select_str (PARTY_SITES) = ' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;
  l_sel_str := '';
/*
            select  a.party_orig_system, a.party_orig_system_reference,
                a.site_orig_system, a.site_orig_system_reference,
                b.party_id, b.party_site_id, a.address1, a.postal_code
                */
l('            from hz_imp_addresses_int a, hz_imp_addresses_sg b ');
l('            where a.batch_id = p_batch_id ');
l('            and b.action_flag = ''I'' ');
l('            and b.int_row_id = a.rowid ');
--l('            and nvl(a.accept_standardized_flag, ''N'') <> ''Y'' ');
l('            and a.party_orig_system_reference >= p_from_osr ');
l('            and a.party_orig_system_reference <= p_to_osr ');
l('            and b.batch_mode_flag = p_batch_mode_flag ');
l('            and interface_status is null ; ');

/*
l(' union ');
-- addition starts --
  get_select_str('PARTY_SITES', p_rule_id, l_sel_str, 'INT_INT', DO_STD_CHK);
  l( l_sel_str);
dbms_output.put_line('select_str (PARTY_SITES) = ' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;
  l_sel_str := '';
l('            from hz_imp_addresses_int a, hz_imp_addresses_sg b ');
l('            where a.batch_id = p_batch_id ');
l('            and b.action_flag = ''I'' ');
l('            and b.int_row_id = a.rowid ');
l('            and a.accept_standardized_flag = ''Y'' ');
l('            and a.party_orig_system_reference >= p_from_osr ');
l('            and a.party_orig_system_reference <= p_to_osr; ');
*/
-- addition ends --
l('   LOOP ');
/* l('    IF l_party_site_cur%NOTFOUND THEN  ');
l('      l_last_fetch:=TRUE; ');
l('    END IF;   '); */
l('    FETCH l_party_site_cur BULK COLLECT INTO ');
get_trans_str('PARTY_SITES', p_rule_id, l_sel_str, 'INT_INT');
  l( l_sel_str);
-- dbms_output.put_line('get_trans_str (PARTY_SITES) =' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE, G_PKG_NAME||l_procedure_name, l_sel_str);
    END IF;
  l_sel_str := '';
/*         H_P_PARTY_OS,
		 H_P_PARTY_OSR,
         H_P_PS_OS,
		 H_P_PS_OSR,
		 H_P_PARTY_ID,
		 H_P_PARTY_SITE_ID,
         H_TX4,
         H_TX6
         */
l('      LIMIT g_limit;  ');
l('     ');
  l('    IF (l_party_site_cur%NOTFOUND) THEN ');
  l('      l_last_fetch := TRUE;');
  l('    END IF;');
  l('   ');
  l('    IF H_P_PS_OS.COUNT = 0 AND l_last_fetch THEN');
  l('      EXIT;');
  l('    END IF;');
  l('   ');
l('    FOR I in H_P_PARTY_OSR.FIRST..H_P_PARTY_OSR.LAST LOOP     ');
  get_trans_proc('PARTY_SITES', p_rule_id, l_trans_list);
  FOR I in l_trans_list.FIRST..l_trans_list.LAST LOOP
--    dbms_output.put_line('get_trans_proc (PARTY_SITES) = ' || l_trans_list(I));
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE, G_PKG_NAME||l_procedure_name, l_trans_list(I));
    END IF;
    l(l_trans_list(I));
    l_trans_list.DELETE(I);
  END LOOP  ;
/*        H_TX4(I):= HZ_TRANS_PKG.WRADDRESS_CLEANSE (H_TX4(I),NULL, ''ADDRESS'',''PARTY_SITE'');
        H_TX6(I):= HZ_TRANS_PKG.CLEANSED_EMAIL (H_TX6(I),NULL, 'POSTAL_CODE','PARTY_SITE');
        H_TX11(I):= HZ_TRANS_PKG.RM_SPLCHAR(H_TX11(I),NULL, 'POSTAL_CODE','PARTY_SITE');
        */
l('    END LOOP; ');
l('    SAVEPOINT pop_party_sites; ');
l('    BEGIN      ');
l('      FORALL I in H_P_PARTY_OSR.FIRST..H_P_PARTY_OSR.LAST ');
l('        INSERT INTO HZ_SRCH_PSITES ( ');
  get_insert_str('HZ_STAGED_PARTY_SITES', p_rule_id, l_sel_str, 'INT_INT');
  l( l_sel_str);
-- dbms_output.put_line('l_sel_str get_insert_str ' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE, G_PKG_NAME||l_procedure_name, l_sel_str);
    END IF;
  l_sel_str := '';
 /*        PARTY_SITE_ID,
		 PARTY_ID,
		PARTY_OS,
		PARTY_OSR,
		PARTY_SITE_OS,
		PARTY_SITE_OSR
           , TX4
           , TX6
           , TX11
           */
l('        ) VALUES (  ');
  get_insert_val_str('HZ_STAGED_PARTY_SITES', p_rule_id, l_sel_str, 'INT_INT');
  l( l_sel_str);
-- dbms_output.put_line(' get_insert_val_str (PARTY_SITES) = ' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;
  l_sel_str := '';
/*        H_P_PARTY_SITE_ID(I),
          H_P_PARTY_ID(I),
          H_P_PARTY_OS(I),
          H_P_PARTY_OSR(I),
          H_P_PS_OS(I),
          H_P_PS_OSR(I)
        , H_TX4(I)
        , H_TX6(I)
        , H_TX11(I)
        */
l('            ); ');
l('      EXCEPTION ');
l('        WHEN OTHERS THEN ');
l('          ROLLBACK to pop_party_sites; ');
l('          RAISE; ');
l('      END; ');
l('       ');
l('      IF l_last_fetch THEN ');
l('        FND_CONCURRENT.AF_Commit; ');
l('        EXIT; ');
l('      END IF; ');
l('      FND_CONCURRENT.AF_Commit; ');
l('       ');
l('   END LOOP; ');
l('   CLOSE  l_party_site_cur; ');
ELSE
    l(' null;');
END IF;
l('	  END pop_party_sites; ');
      EXCEPTION WHEN OTHERS THEN
          RAISE FND_API.G_EXC_ERROR;
END gen_pop_party_sites;


PROCEDURE gen_pop_party_sites_int (
    p_rule_id   IN    NUMBER
)
IS
l_sel_str VARCHAR2(4000) := NULL;
x_bool VARCHAR2(1);
    l_procedure_name VARCHAR2(30) := '.GEN_POP_PARTY_SITES_INT' ;
BEGIN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
    END IF;
l(' ');
l('  PROCEDURE pop_party_sites_int ( ');
l('    	 p_batch_id IN	NUMBER, ');
l('      p_from_osr                       IN   VARCHAR2, ');
l('   	 p_to_osr                         IN   VARCHAR2 ');
l('     ) IS  ');

l('  l_last_fetch BOOLEAN := FALSE; ');
l('  l_party_site_cur HZ_PARTY_STAGE.StageCurTyp; ');
l('   ');
l('  l_os VARCHAR2(30); ');
l('   BEGIN  ');
l('   l_os := HZ_IMP_DQM_STAGE.get_os(p_batch_id); ');
  x_bool := 'N';
  chk_et_req('PARTY_SITES', p_rule_id, x_bool);
  IF (x_bool = 'Y') THEN

 -- query for interface to tca
l(' 		open l_party_site_cur for ');
  get_select_str('PARTY_SITES', p_rule_id, l_sel_str, 'INT_TCA', null);
  l_sel_str := l_sel_str || ' , a.party_id '; --bug 5393826
  l( l_sel_str);
-- dbms_output.put_line('select_str (PARTY_SITES int tca) = ' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;
  l_sel_str := '';
/*            select  a.party_orig_system, a.party_orig_system_reference,
                a.site_orig_system, a.site_orig_system_reference,
                  a.address1, a.postal_code */
l('             from hz_imp_addresses_int a ');
l('             where a.batch_id = p_batch_id ');
l('             and a.party_orig_system_reference >= p_from_osr ');
l('             and a.party_orig_system_reference <= p_to_osr ');
l('             and a.party_orig_system = l_os; ');
l('   LOOP ');
l('     FETCH l_party_site_cur BULK COLLECT INTO ');
get_trans_str('PARTY_SITES', p_rule_id, l_sel_str, 'INT_TCA');
l_sel_str := l_sel_str || ' , H_P_PARTY_ID '; -- bug 5393826
  l( l_sel_str);
-- dbms_output.put_line('get_trans_str (PARTY_SITES) =' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;
  l_sel_str := '';
/*         H_P_PARTY_OS,
		 H_P_PARTY_OSR,
         H_P_PS_OS,
		 H_P_PS_OSR,
         H_TX4,
         H_TX6 */
l('      LIMIT g_limit; ');
l('   ');
l('     IF l_party_site_cur%NOTFOUND THEN ');
l('       l_last_fetch:=TRUE; ');
l('     END IF; ');
l('     IF H_P_PS_OS.COUNT=0 AND l_last_fetch THEN ');
l('       EXIT; ');
l('     END IF; ');
l('      ');
l('     FOR I in H_P_PS_OSR.FIRST..H_P_PS_OSR.LAST LOOP ');
  get_trans_proc('PARTY_SITES', p_rule_id, l_trans_list);
  FOR I in l_trans_list.FIRST..l_trans_list.LAST LOOP
--     dbms_output.put_line('get_trans_proc (PARTY_SITES) = ' || l_trans_list(I));
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_trans_list(I));
    END IF;
    l(l_trans_list(I));
    l_trans_list.DELETE(I);
  END LOOP  ;
/*
        H_TX4(I):= HZ_TRANS_PKG.WRADDRESS_CLEANSE (H_TX4(I),NULL, 'ADDRESS','PARTY_SITE');
        H_TX6(I):= HZ_TRANS_PKG.CLEANSED_EMAIL (H_TX6(I),NULL, 'POSTAL_CODE','PARTY_SITE');
        H_TX11(I):= HZ_TRANS_PKG.RM_SPLCHAR(H_TX11(I),NULL, 'POSTAL_CODE','PARTY_SITE');
        */
l('     END LOOP; ');
l('     SAVEPOINT pop_party_sites_int; ');
l('     BEGIN      ');
l('       FORALL I in H_P_PS_OSR.FIRST..H_P_PS_OSR.LAST  ');
l('         INSERT INTO HZ_SRCH_PSITES ( ');
  get_insert_str('HZ_STAGED_PARTY_SITES', p_rule_id, l_sel_str, 'INT_TCA');
  l_sel_str := l_sel_str || ' , PARTY_ID ';-- bug 5393826
  l( l_sel_str);
-- dbms_output.put_line('l_sel_str get_insert_str ' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;
  l_sel_str := '';
/*		PARTY_OS,
		PARTY_OSR,
		PARTY_SITE_OS,
		PARTY_SITE_OSR
           , TX4
           , TX6
           , TX11 */
l('         ) VALUES ( ');
  get_insert_val_str('HZ_STAGED_PARTY_SITES', p_rule_id, l_sel_str, 'INT_TCA');
  l_sel_str := l_sel_str || ' , H_P_PARTY_ID(I) '; -- bug 5393826
  l( l_sel_str);
-- dbms_output.put_line(' get_insert_val_str (PARTY_SITES) = ' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;
  l_sel_str := '';
/*          H_P_PARTY_OS(I),
          H_P_PARTY_OSR(I),
          H_P_PS_OS(I),
          H_P_PS_OSR(I)
        , H_TX4(I)
        , H_TX6(I)
        , H_TX11(I) */
l('             ); ');
l('       EXCEPTION  ');
l('         WHEN OTHERS THEN ');
l('           ROLLBACK to pop_party_sites_int; ');
l('           RAISE; ');
l('       END; ');
l('     ');
l('       IF l_last_fetch THEN ');
l('         FND_CONCURRENT.AF_Commit; ');
l('         EXIT; ');
l('       END IF; ');
l('       FND_CONCURRENT.AF_Commit; ');
l('     ');
l('    END LOOP; ');
l('   CLOSE  l_party_site_cur; ');
   ELSE
     l(' null;');
   END IF;
l(' 	  END pop_party_sites_int; ');
      EXCEPTION WHEN OTHERS THEN
          RAISE FND_API.G_EXC_ERROR;

END gen_pop_party_sites_int;

PROCEDURE   gen_static_text(
        p_rule_id       IN      NUMBER
) IS
    l_procedure_name VARCHAR2(30) := '.GEN_STATIC_TEXT' ;
BEGIN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
    END IF;
/*
*/
  l('PROCEDURE POP_INTERFACE_SEARCH_TAB (');
  l('    p_batch_id				 IN   NUMBER,');
  l('    p_from_osr                       IN   VARCHAR2,');
  l('    p_to_osr                         IN   VARCHAR2,');
  l('    x_return_status                    OUT NOCOPY    VARCHAR2,');
  l('    x_msg_count                        OUT NOCOPY    NUMBER,');
  l('    x_msg_data                         OUT NOCOPY    VARCHAR2');
  l('  ) IS');
  l(' ');
  l('  BEGIN');
  l(' ');
  l('     x_return_status := fnd_api.g_ret_sts_success; ');
  l('     pop_parties(p_batch_id, p_from_osr, p_to_osr);');
  l('     pop_party_sites(p_batch_id, p_from_osr, p_to_osr);');
  l('     pop_cp(p_batch_id, p_from_osr, p_to_osr);');
  l('     pop_contacts(p_batch_id, p_from_osr, p_to_osr);');
  l('   --  build_srch_indexes();  ');
  l('   EXCEPTION WHEN others THEN ');
  l('         x_return_status := fnd_api.g_ret_sts_unexp_error; ');
  l('         fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, ');
  l('                  p_count => x_msg_count, ');
  l('                  p_data  => x_msg_data); ');
  l('         RAISE;  ');
  l('  END POP_INTERFACE_SEARCH_TAB;');
  l(' ');

  l(' PROCEDURE POP_INT_TCA_SEARCH_TAB ( ');
  l('     p_batch_id				 IN   NUMBER, ');
  l('     p_from_osr                       IN   VARCHAR2, ');
  l('     p_to_osr                         IN   VARCHAR2 , ');
  l('     x_return_status                    OUT NOCOPY    VARCHAR2, ');
  l('     x_msg_count                        OUT NOCOPY    NUMBER, ');
  l('     x_msg_data                         OUT NOCOPY    VARCHAR2 ');
  l('   ) IS ');
  l('    ');
  l('   l_a VARCHAR2(1);   ');
  l('   l_b VARCHAR2(1);   ');
  l('   l_c NUMBER;   ');
  l('   l_d NUMBER;   ');
  l('   l_e VARCHAR2(1);   ');
  l('    ');

  l('   BEGIN ');
  l('     x_return_status := fnd_api.g_ret_sts_success; ');
  l('   select batch_dedup_flag, registry_dedup_flag, batch_dedup_match_rule_id, registry_dedup_match_rule_id, addr_val_flag  ');
  l('   into l_a, l_b, l_c, l_d, l_e  ');
  l('   from hz_imp_batch_summary  ');
  l('   where batch_id = p_batch_id;  ');
  l('      ');
  l('   IF (l_b = ''Y'') THEN ');
  l('       IF ((l_a = ''Y'') AND (l_c = l_d) ) THEN  ');
  l('           IF (l_e = ''Y'') THEN ');
  l('                  pop_party_sites_int(p_batch_id, p_from_osr, p_to_osr);  ');
  l('             END IF;  ');
  l('         ELSIF (l_a = ''Y'') THEN ');
  l('             pop_parties_int(p_batch_id, p_from_osr, p_to_osr); ');
  l('             pop_party_sites_int(p_batch_id, p_from_osr, p_to_osr); ');
  l('             pop_cp_int(p_batch_id, p_from_osr, p_to_osr);  ');
  l('             pop_contacts_int(p_batch_id, p_from_osr, p_to_osr); ');
  l('         END IF; ');
  l('     END IF;     ');

  l('   EXCEPTION WHEN others THEN ');
  l('         x_return_status := fnd_api.g_ret_sts_unexp_error; ');
  l('         fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, ');
  l('               p_count => x_msg_count, ');
  l('               p_data  => x_msg_data);  ');
  l('         RAISE;  ');
  l('   END POP_INT_TCA_SEARCH_TAB; ');

  l(' ');
      EXCEPTION WHEN OTHERS THEN
          RAISE FND_API.G_EXC_ERROR;
END gen_static_text;

PROCEDURE gen_get_contact_cur (
    p_rule_id   IN    NUMBER
)
IS
l_sel_str VARCHAR2(4000) := NULL;
x_bool VARCHAR2(1) := NULL;
l_procedure_name VARCHAR2(30) := '.GEN_GET_CONTACT_CUR' ;
BEGIN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
    END IF;
  l('   PROCEDURE get_contact_cur( ');
  l('    	 p_batch_id IN	NUMBER, ');
  l('        p_from_osr                       IN   VARCHAR2, ');
  l('   	 p_to_osr                         IN   VARCHAR2, ');
  l('        p_batch_mode_flag                IN   VARCHAR2, ');
  l('        x_contact_cur IN OUT NOCOPY StageImpContactCurTyp ');
  l(' ) IS  ');
  l('   	 is_using_allow_cust_attr	VARCHAR2(1); ');
  l('      CURSOR c1 is    select ''Y'' ');
  l('      from hz_trans_attributes_vl  ');
  l('      where entity_name = ''CONTACTS''   ');
  -- l('      and userenv(''LANG'') = ''US''  ');
  l('      and attribute_name = ''CONTACT_NAME'' ');
  l('      and attribute_id in (    ');
  l('      select attribute_id ');
  l('      from hz_match_rule_primary b ');
  l('      where match_rule_id = '|| p_rule_id);
  l('      union ');
  l('      select attribute_id ');
  l('      from hz_match_rule_secondary b ');
  l('      where match_rule_id = '|| p_rule_id ||' ) and rownum = 1;   ');
  l(' ');
  l(' BEGIN ');
  x_bool := 'N';
  chk_et_req('CONTACTS', p_rule_id, x_bool);
  IF (x_bool = 'Y') THEN
  l('    OPEN c1; ');
  l('    LOOP     ');
  l('     FETCH c1 INTO is_using_allow_cust_attr; ');
  l('     EXIT when c1%NOTFOUND; ');
  l('    END LOOP;  ');
  l('   CLOSE  c1; ');
  l('    IF (is_using_allow_cust_attr = ''Y'') THEN ');
  l('      OPEN x_contact_cur FOR      ');
  -- cursor1 if match_rule has contact_name, person_first_name, person_last_name in it.
  get_select_str('CONTACTS', p_rule_id, l_sel_str, 'INT_INT', NULL);
  l_sel_str := l_sel_str || ', c.person_first_name || ''  '' || c.person_last_name as person_name' ;
-- dbms_output.put_line('l_sel_str ' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;
  l(l_sel_str);
  l_sel_str := '';

/*  l('             select a.sub_orig_system, a.sub_orig_system_reference, ');
  l('                 a.site_orig_system, a.site_orig_system_reference,  ');
  l('                 a.contact_orig_system, a.contact_orig_system_reference, ');
  l('                 a.contact_number, a.title, c.person_first_name || '' '' || c.person_last_name as person_name ');
*/
  l('             from HZ_IMP_CONTACTS_INT a, HZ_IMP_CONTACTS_SG b, HZ_IMP_PARTIES_INT c ');
  l('         	where a.batch_id = p_batch_id ');
  l('         	and b.action_flag = ''I'' ');
  l('             and b.int_row_id = a.rowid  ');
  l('             and a.sub_orig_system_reference >= p_from_osr ');
  l('             and a.sub_orig_system_reference <= p_to_osr ');
             -- for contact_name
  l('             and a.sub_orig_system = c.party_orig_system ');
  l('             and a.batch_id = c.batch_id ');
--  l('            and a.sub_orig_system = c.party_orig_system ');
  l('             and b.sub_id = c.party_id ');
  l('            and b.batch_mode_flag = p_batch_mode_flag ');
  l('            and a.interface_status is null  ');
  l('             union all ');
  get_select_str('CONTACTS', p_rule_id, l_sel_str, 'INT_INT', NULL);
  l_sel_str := l_sel_str || ',  c.party_name as person_name' ;
  l(l_sel_str);
-- dbms_output.put_line('get_select_str (CONTACTS)' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;
 l_sel_str := '';
/*  l('                 select  a.sub_orig_system, a.sub_orig_system_reference, ');
  l('                 a.site_orig_system, a.site_orig_system_reference, ');
  l('                 a.contact_orig_system, a.contact_orig_system_reference, ');
  l('                 a.contact_number, a.title, c.party_name as person_name ');
  */
  l('             from HZ_IMP_CONTACTS_INT a, HZ_IMP_CONTACTS_SG b, hz_parties c  ');
  l('         	where a.batch_id = p_batch_id ');
  l('         	and b.action_flag = ''I'' ');
  l('             and b.int_row_id = a.rowid ');
  l('             and a.sub_orig_system_reference >= p_from_osr ');
  l('             and a.sub_orig_system_reference <= p_to_osr ');
             -- for contact_name
--  l('             and a.sub_orig_system = c.party_id ');
  l('             and b.sub_id = c.party_id ');
  l('            and b.batch_mode_flag = p_batch_mode_flag ');
  l('            and a.interface_status is null  ');
  l('        ; ');
  l('   ELSE       ');
  l('      OPEN x_contact_cur FOR ');
            -- cursor2 if specified match_rule does not have name associated with it.
  get_select_str('CONTACTS', p_rule_id, l_sel_str, 'INT_INT', NULL);
  l_sel_str := l_sel_str || ' ' ; -- ,  null person_name
  l(l_sel_str);
-- dbms_output.put_line('get_select_str (CONTACTS)' || l_sel_str);
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;
 l_sel_str := '';
/*  l('             select a.sub_orig_system, a.sub_orig_system_reference, ');
  l('                 a.site_orig_system, a.site_orig_system_reference,  ');
  l('                 a.contact_orig_system, a.contact_orig_system_reference, ');
  l('                 a.contact_number, a.title, null person_name ');
  */
  l('             from HZ_IMP_CONTACTS_INT a, HZ_IMP_CONTACTS_SG b ');
  l('         	where a.batch_id = p_batch_id ');
  l('         	and b.action_flag = ''I'' ');
  l('             and b.int_row_id = a.rowid  ');
/*  l('             and b.contact_orig_system = a.contact_orig_system ');
  l('             and b.contact_orig_system_reference = a.contact_orig_system_reference ');
  l('             and b.sub_orig_system = a.sub_orig_system ');
  l('             and b.sub_orig_system_reference = a.sub_orig_system_reference ');
  l('             and b.obj_orig_system = a.obj_orig_system ');
  l('             and b.obj_orig_system_reference = a.obj_orig_system_reference ');
  l('                      '); */
  l('             and a.sub_orig_system_reference  >= p_from_osr ');
  l('             and a.sub_orig_system_reference  <= p_to_osr    ');
  l('            and b.batch_mode_flag = p_batch_mode_flag ');
  l('            and a.interface_status is null ; ');
  l('        END IF; ');
    ELSE
         l(' null; --5');
    END IF;
  l(' END get_contact_cur; ');
  l(' ');
      EXCEPTION WHEN OTHERS THEN
          RAISE FND_API.G_EXC_ERROR;
  END gen_get_contact_cur;


PROCEDURE gen_get_contact_cur_int (
    p_rule_id   IN    NUMBER
)
IS
l_sel_str VARCHAR2(4000) := NULL;
x_bool VARCHAR2(1) := NULL;
l_procedure_name VARCHAR2(30) := '.GEN_GET_CONTACT_CUR_INT' ;
BEGIN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
    END IF;
   l(' PROCEDURE get_contact_cur_int( ');
l('    	 p_batch_id IN	NUMBER, ');
l('      p_from_osr                       IN   VARCHAR2, ');
l('   	 p_to_osr                         IN   VARCHAR2, ');
l('      x_contact_cur IN OUT NOCOPY StageImpContactCurTyp ');
l(' ) IS  ');
l('   	 is_using_allow_cust_attr	VARCHAR2(1); ');
l('      CURSOR c1 is    select ''Y'' ');
l('      from hz_trans_attributes_vl  ');
l('      where entity_name = ''CONTACTS''   ');
-- l('      and userenv(''LANG'') = ''US''  ');
l('      and attribute_name = ''CONTACT_NAME'' ');
l('      and attribute_id in (    ');
l('      select attribute_id ');
l('      from hz_match_rule_primary b ');
l('      where match_rule_id = '|| p_rule_id);
l('      union ');
l('      select attribute_id ');
l('      from hz_match_rule_secondary b ');
l('      where match_rule_id = '|| p_rule_id ||' ) and rownum = 1;   ');
l(' ');
l('  l_os VARCHAR2(30); ');
l('   BEGIN  --');
l('   l_os := HZ_IMP_DQM_STAGE.get_os(p_batch_id); ');
  x_bool := 'N';
  chk_et_req('CONTACTS', p_rule_id, x_bool);
  IF (x_bool = 'Y') THEN
l('    OPEN c1; ');
l('    LOOP     ');
l('     FETCH c1 into is_using_allow_cust_attr; ');
l('     EXIT when c1%NOTFOUND; ');
l('    END LOOP;  ');
l('    IF (is_using_allow_cust_attr = ''Y'') THEN ');
l('      OPEN x_contact_cur FOR      ');
 -- cursor1 if match_rule has contact_name, person_first_name, person_last_name in it.
  get_select_str('CONTACTS', p_rule_id, l_sel_str, 'INT_TCA', NULL);
-- dbms_output.put_line('l_sel_str (CONTACTS int tca 1)' || l_sel_str);
  l_sel_str := l_sel_str || ', c.person_first_name || ''  '' || c.person_last_name as person_name' ;
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;
-- dbms_output.put_line('l_sel_str (CONTACTS int tca)' || l_sel_str);
  l(l_sel_str);
  l_sel_str := '';
/*                        select a.sub_orig_system, a.sub_orig_system_reference,
                a.site_orig_system, a.site_orig_system_reference,
                a.contact_orig_system, a.contact_orig_system_reference,
                a.contact_number, a.title, c.person_first_name || ' ' || c.person_last_name as person_name
                */
l('             from HZ_IMP_CONTACTS_INT a, HZ_IMP_PARTIES_INT c ');
l('         	where a.batch_id = p_batch_id ');
l('             and a.sub_orig_system_reference >= p_from_osr ');
l('             and a.sub_orig_system_reference <= p_to_osr ');
l('             and a.sub_orig_system_reference = c.party_orig_system_reference ');
             -- for contact_name
l('             and a.sub_orig_system = c.party_orig_system ');
l('             and a.batch_id = c.batch_id ');
-- l('             and a.sub_orig_system = c.party_orig_system ');
l('             and a.sub_orig_system = l_os; ');
/* l('             union ');
  get_select_str('CONTACTS', p_rule_id, l_sel_str, 'INT_TCA', NULL);
  l_sel_str := l_sel_str || ',  c.party_name as person_name' ;
  l(l_sel_str);
 dbms_output.put_line('get_select_str (CONTACTS int_tca)' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;

 l_sel_str := ''; */
/*                select  a.sub_orig_system, a.sub_orig_system_reference,
                a.site_orig_system, a.site_orig_system_reference,
                a.contact_orig_system, a.contact_orig_system_reference,
                a.contact_number, a.title, c.party_name as person_name */
/* l('             from HZ_IMP_CONTACTS_INT a, hz_parties c ');
l('         	where a.batch_id = p_batch_id ');
l('             and a.sub_orig_system >= p_from_osr ');
l('             and a.sub_orig_system <= p_to_osr ');
             -- for contact_name
l('  --           and a.sub_orig_system = c.party_id; '); */
l('   ELSE        ');
l('      OPEN x_contact_cur FOR ');
         -- cursor2 if specified match_rule does not have name associated with it.
  get_select_str('CONTACTS', p_rule_id, l_sel_str, 'INT_TCA', NULL);
  l_sel_str := l_sel_str || ',  null person_name' ;
  l(l_sel_str);
-- dbms_output.put_line('get_select_str (CONTACTS int_tca)' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;

 l_sel_str := '';
/*            select a.sub_orig_system, a.sub_orig_system_reference,
                a.site_orig_system, a.site_orig_system_reference,
                a.contact_orig_system, a.contact_orig_system_reference,
                a.contact_number, a.title, null person_name */
l('             from HZ_IMP_CONTACTS_INT a ');
l('         	where a.batch_id = p_batch_id ');
l('             and a.sub_orig_system_reference >= p_from_osr ');
l('             and a.sub_orig_system_reference <= p_to_osr   ');
l('             and a.sub_orig_system = l_os; ');
l('        END IF; ');
ELSE
 l(' null; ');
END IF;
l(' END get_contact_cur_int; ');
l(' ');
      EXCEPTION WHEN OTHERS THEN
          RAISE FND_API.G_EXC_ERROR;
END gen_get_contact_cur_int;

PROCEDURE gen_pop_contacts (
    p_rule_id   IN    NUMBER
)
IS
l_sel_str VARCHAR2(4000) := NULL;
x_bool VARCHAR2(1);
l_procedure_name VARCHAR2(30) := '.GEN_POP_CONTACTS' ;
BEGIN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
    END IF;
l(' PROCEDURE pop_contacts ( ');
l('    	 p_batch_id IN	NUMBER, ');
l('      p_from_osr                       IN   VARCHAR2, ');
l('   	 p_to_osr                         IN   VARCHAR2, ');
l('      p_batch_mode_flag                IN   VARCHAR2 ');
l('     ) IS  ');
l('  l_last_fetch BOOLEAN := FALSE; ');
l('  l_contact_cur StageImpContactCurTyp; ');
l('   ');
l('   BEGIN ');
  x_bool := 'N';
  chk_et_req('CONTACTS', p_rule_id, x_bool);
  IF (x_bool = 'Y') THEN
 -- query for interface to tca
l('      get_contact_cur(p_batch_id, p_from_osr, p_to_osr, p_batch_mode_flag, l_contact_cur ); ');
l('    LOOP ');
l('       FETCH l_contact_cur BULK COLLECT INTO ');
  get_trans_str('CONTACTS', p_rule_id, l_sel_str, 'INT_INT');
  l( l_sel_str);
-- dbms_output.put_line('get_trans_str (CONTACTS) ' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;
  l_sel_str := '';
/*         H_P_SUBJECT_OS,
		 H_P_SUBJECT_OSR,
         H_P_PS_OS,
		 H_P_PS_OSR,
		 H_P_CONTACT_OS,
		 H_P_CONTACT_OSR,
         H_TX4,
         H_TX6,
         H_TX45 */
l('      LIMIT g_limit;  ');
l('  ');
l('     IF l_contact_cur%NOTFOUND THEN     ');
l('       l_last_fetch:=TRUE; ');
l('     END IF; ');
l('     IF H_P_CONTACT_OS.COUNT=0 AND l_last_fetch THEN ');
l('       EXIT; ');
l('     END IF; ');
l('      ');
l('     FOR I in H_P_CONTACT_OSR.FIRST..H_P_CONTACT_OSR.LAST LOOP ');
  get_trans_proc('CONTACTS', p_rule_id, l_trans_list);
  FOR I in l_trans_list.FIRST..l_trans_list.LAST LOOP
--    dbms_output.put_line('get_trans_proc (CONTACTS)' || l_trans_list(I));
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_trans_list(I));
    END IF;
    l(l_trans_list(I));
    l_trans_list.DELETE(I);
  END LOOP  ;
/*        H_TX4(I):= HZ_TRANS_PKG.WRADDRESS_CLEANSE (H_TX4(I),NULL, 'CONTACT_NUMBER','CONTACTS');
        H_TX6(I):= HZ_TRANS_PKG.CLEANSED_EMAIL (H_TX6(I),NULL, 'TITLE','CONTACTS');
        */
l('     END LOOP; ');
l('     SAVEPOINT pop_contacts; ');
l('     BEGIN     ');
l('       FORALL I in H_P_CONTACT_OSR.FIRST..H_P_CONTACT_OSR.LAST ');
l('         INSERT INTO HZ_SRCH_CONTACTS ( ');
  get_insert_str('HZ_STAGED_CONTACTS', p_rule_id, l_sel_str, 'INT_INT');
  l( l_sel_str);
-- dbms_output.put_line(' get_insert_str (CONTACTS)' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;
  l_sel_str := '';
/*		PARTY_OS,
		PARTY_OSR,
    	 CONTACT_OS,
         CONTACT_OSR
           , TX4
           , TX6 */
l('         ) VALUES ( ');
  get_insert_val_str('HZ_STAGED_CONTACTS', p_rule_id, l_sel_str, 'INT_INT');
  l( l_sel_str);
-- dbms_output.put_line('get_insert_val_str (CONTACTS)' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;
  l_sel_str := '';
/*          H_P_SUBJECT_OS(I),
          H_P_SUBJECT_OSR(I),
          H_P_CONTACT_OS(I),
          H_P_CONTACT_OSR(I)
        , H_TX4(I)
        , H_TX6(I) */
l('             ); ');
l('       EXCEPTION  ');
l('         WHEN OTHERS THEN ');
l('           ROLLBACK to pop_contacts; ');
l('           RAISE; ');
l('       END; ');
l('        ');
l('       IF l_last_fetch THEN ');
l('         FND_CONCURRENT.AF_Commit; ');
l('         EXIT; ');
l('       END IF; ');
l('       FND_CONCURRENT.AF_Commit; ');
l('        ');
l('    END LOOP; ');
l('    CLOSE l_contact_cur ; ');
ELSE
 l(' null; ');
END IF;
l(' 	  END pop_contacts; ');
l(' ');
      EXCEPTION WHEN OTHERS THEN
          RAISE FND_API.G_EXC_ERROR;
END gen_pop_contacts;


PROCEDURE gen_pop_contacts_int (
    p_rule_id   IN    NUMBER
)
IS
l_sel_str VARCHAR2(4000) := NULL;
x_bool VARCHAR2(1);
l_procedure_name VARCHAR2(30) := '.GEN_POP_CONTACTS_INT' ;
BEGIN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
    END IF;
l(' PROCEDURE pop_contacts_int ( ');
l('    	 p_batch_id IN	NUMBER, ');
l('      p_from_osr                       IN   VARCHAR2, ');
l('   	 p_to_osr                         IN   VARCHAR2 ');
l('     ) IS  ');
l('  l_last_fetch BOOLEAN := FALSE; ');
l('  l_contact_cur StageImpContactCurTyp; ');
l('   ');
l('   BEGIN ');
  x_bool := 'N';
  chk_et_req('CONTACTS', p_rule_id, x_bool);
  IF (x_bool = 'Y') THEN

 -- query for interface to tca
l('      get_contact_cur_int(p_batch_id, p_from_osr, p_to_osr, l_contact_cur ); ');
l('    LOOP ');
l('       FETCH l_contact_cur BULK COLLECT INTO ');
  get_trans_str('CONTACTS', p_rule_id, l_sel_str, 'INT_TCA');
  l( l_sel_str);
-- dbms_output.put_line('get_trans_str (CONTACTS int_tca) ' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;
  l_sel_str := '';
/*         H_P_SUBJECT_OS,
		 H_P_SUBJECT_OSR,
         H_P_PS_OS,
		 H_P_PS_OSR,
		 H_P_CONTACT_OS,
		 H_P_CONTACT_OSR,
         H_TX4,
         H_TX6,
         H_TX45 */
l('       LIMIT g_limit; ');
l('  ');
l('     IF l_contact_cur%NOTFOUND THEN     ');
l('       l_last_fetch:=TRUE; ');
l('     END IF; ');
l('     IF H_P_CONTACT_OS.COUNT=0 AND l_last_fetch THEN ');
l('       EXIT; ');
l('     END IF; ');
l('     FOR I in H_P_CONTACT_OS.FIRST..H_P_CONTACT_OS.LAST LOOP ');
  get_trans_proc('CONTACTS', p_rule_id, l_trans_list);
  FOR I in l_trans_list.FIRST..l_trans_list.LAST LOOP
--   dbms_output.put_line('get_trans_proc (CONTACTS int_tca)' || l_trans_list(I));
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_trans_list(I));
    END IF;
    l(l_trans_list(I));
    l_trans_list.DELETE(I);
  END LOOP  ;
/*        H_TX4(I):= HZ_TRANS_PKG.WRADDRESS_CLEANSE (H_TX4(I),NULL, 'CONTACT_NUMBER','CONTACTS');
        H_TX6(I):= HZ_TRANS_PKG.CLEANSED_EMAIL (H_TX6(I),NULL, 'TITLE','CONTACTS'); */
l('     END LOOP; ');
l('     SAVEPOINT pop_contacts_int; ');
l('     BEGIN      ');
l('       FORALL I in H_P_CONTACT_OS.FIRST..H_P_CONTACT_OS.LAST ');
l('         INSERT INTO HZ_SRCH_CONTACTS ( ');
  get_insert_str('HZ_STAGED_CONTACTS', p_rule_id, l_sel_str, 'INT_TCA');
  l( l_sel_str);
-- dbms_output.put_line(' get_insert_str (CONTACTS int_tca)' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;
  l_sel_str := '';
/*		PARTY_OS,
		PARTY_OSR,
    	 CONTACT_OS,
         CONTACT_OSR
           , TX4
           , TX6 */
l('         ) VALUES ( ');
  get_insert_val_str('HZ_STAGED_CONTACTS', p_rule_id, l_sel_str, 'INT_TCA');
  l( l_sel_str);
-- dbms_output.put_line('get_insert_val_str (CONTACTS int_tca)' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;
  l_sel_str := '';
/*          H_P_SUBJECT_OS(I),
          H_P_SUBJECT_OSR(I),
          H_P_CONTACT_OS(I),
          H_P_CONTACT_OSR(I)
        , H_TX4(I)
        , H_TX6(I) */
l('             ); ');
l('       EXCEPTION  ');
l('         WHEN OTHERS THEN ');
l('           ROLLBACK to pop_contacts_int; ');
l('           RAISE; ');
l('       END; ');
l('        ');
l('       IF l_last_fetch THEN ');
l('         FND_CONCURRENT.AF_Commit; ');
l('         EXIT; ');
l('       END IF; ');
l('       FND_CONCURRENT.AF_Commit; ');
l('        ');
l('     END LOOP; ');
l('     CLOSE l_contact_cur ; ');
ELSE
 l(' null; ');
END IF;
l(' 	  END pop_contacts_int; ');
      EXCEPTION WHEN OTHERS THEN
          RAISE FND_API.G_EXC_ERROR;
END gen_pop_contacts_int;

PROCEDURE gen_pop_cp (
    p_rule_id   IN    NUMBER
)
IS
l_sel_str VARCHAR2(4000) := NULL;
x_bool VARCHAR2(1);
l_procedure_name VARCHAR2(30) := '.GEN_POP_CP' ;
BEGIN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
    END IF;
  l('  PROCEDURE pop_cp (  ');
  l('   	 p_batch_id IN	NUMBER, ');
  l('        p_from_osr                       IN   VARCHAR2, ');
  l('  	     p_to_osr                         IN   VARCHAR2, ');
  l('        p_batch_mode_flag                  IN VARCHAR2 ');
  l('    ) IS  ');
  l('  ');
  l('    	l_last_fetch BOOLEAN := FALSE; ');
  l('      l_cp_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  BEGIN ');
  x_bool := 'N';
  chk_et_req('CONTACT_POINTS', p_rule_id, x_bool);
  IF (x_bool = 'Y') THEN
 -- query for interface to tca
  l('	open l_cp_cur for ');
  get_select_str('CONTACT_POINTS', p_rule_id, l_sel_str, 'INT_INT', NULL);
  l( l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;

-- dbms_output.put_line('get_select_str (CONTACT_POINTS) ' || l_sel_str);
  l_sel_str := '';
/*    	select a.email_address, a.party_orig_system_reference,
            a.party_orig_system, a.cp_orig_system, a.cp_orig_system_reference,
            a.site_orig_system, a.site_orig_system_reference, b.party_site_id,
            b.contact_point_id, b.party_id */
  l('    	from  HZ_IMP_CONTACTPTS_INT a,  HZ_IMP_CONTACTPTS_SG b --');
  l('    	where a.batch_id = p_batch_id  ');
  l('    	and b.action_flag = ''I'' ');
  l(' 		and b.int_row_id = a.rowid ');
  l('    	and b.party_orig_system_reference >= p_from_osr ');
  l('    	and b.party_orig_system_reference <= p_to_osr ');
  l('       and b.batch_mode_flag = p_batch_mode_flag ');
  l('       and interface_status is null ; ');

  l('   LOOP ');
  l('      FETCH l_cp_cur BULK COLLECT INTO ');
  get_trans_str('CONTACT_POINTS', p_rule_id, l_sel_str, 'INT_INT');
  l( l_sel_str);
-- dbms_output.put_line('get_trans_str (CONTACT_POINTS) ' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;
  l_sel_str := '';
/*	          H_TX41
      	   	, H_P_PARTY_ID
			, H_P_PARTY_OS
			, H_P_PARTY_OSR
	         , H_P_CP_OS
	         , H_P_CP_OSR
	         , H_P_PS_OS
		      , H_P_PS_OSR
	         , H_P_PARTY_SITE_ID
	         , H_P_CONTACT_POINT_ID
             */
  l('       LIMIT g_limit; ');
  l('     IF l_cp_cur%NOTFOUND THEN    ');
  l('       l_last_fetch := TRUE; ');
  l('     END IF; ');
  l('      ');
  l('     IF H_P_CP_OSR.COUNT = 0 AND l_last_fetch THEN ');
  l('       EXIT; ');
  l('     END IF; ');
  l('      ');
  l('     FOR I in H_P_PARTY_OSR.FIRST..H_P_PARTY_OSR.LAST LOOP   ');
     get_trans_proc('CONTACT_POINTS', p_rule_id, l_trans_list);
     FOR I in l_trans_list.FIRST..l_trans_list.LAST LOOP
--       dbms_output.put_line(' get_trans_proc (CONTACT_POINTS) ' || l_trans_list(I));
       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_trans_list(I));
        END IF;
       l(l_trans_list(I));
       l_trans_list.DELETE(I);
     END LOOP  ;
/*
    	H_TX41(I):=HZ_TRANS_PKG.WRNAMES_CLEANSE(H_TX41(I),NULL, 'EMAIL','CONTACT_POINTS','STAGE');
        */
  l('     END LOOP;  ');
  l('     SAVEPOINT POP_CP; ');
  l('     BEGIN      ');
  l('       FORALL I in H_P_PARTY_OSR.FIRST..H_P_PARTY_OSR.LAST  ');
  l('         INSERT INTO HZ_SRCH_CPTS  ( ');
  get_insert_str('HZ_STAGED_CONTACT_POINTS', p_rule_id, l_sel_str, 'INT_INT');
  l( l_sel_str);
-- dbms_output.put_line(' get_insert_str (CONTACT_POINTS) ' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;
  l_sel_str := '';
/*		       PARTY_SITE_ID,
			 PARTY_ID,
			PARTY_OS,
			PARTY_OSR,
			PARTY_SITE_OS,
			PARTY_SITE_OSR,
			CONTACT_POINT_ID,
	         CONTACT_PT_OS,
	         CONTACT_PT_OSR
	           , TX41
               */
  l('        ) VALUES ( ');
   get_insert_val_str('HZ_STAGED_CONTACT_POINTS', p_rule_id, l_sel_str, 'INT_INT');
  l( l_sel_str);
-- dbms_output.put_line('get_insert_val_str (CONTACT_POINTS) ' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;
  l_sel_str := '';
/*	          H_P_PARTY_SITE_ID(I),
	          H_P_PARTY_ID(I),
	          H_P_PARTY_OS(I),
	          H_P_PARTY_OSR(I),
	          H_P_PS_OS(I),
	          H_P_PS_OSR(I),
	          H_P_CONTACT_POINT_ID(I),
	          H_P_CP_OS(I),
	          H_P_CP_OSR(I)
	        , H_TX41(I)
            */
  l('            );  ');
  l('      EXCEPTION  ');
  l('        WHEN OTHERS THEN  ');
  l('          ROLLBACK to POP_CP;  ');
  l('          RAISE; ');
  l('      END; ');
  l('        ');
  l('       IF l_last_fetch THEN ');
  l('         FND_CONCURRENT.AF_Commit; ');
  l('         EXIT; ');
  l('       END IF; ');
  l('       FND_CONCURRENT.AF_Commit; ');
  l(' ');
  l('  END LOOP; ');
  l('  CLOSE l_cp_cur; ');
ELSE
   l(' null;');
END IF;
  l('  END pop_cp; ');
      EXCEPTION WHEN OTHERS THEN
          RAISE FND_API.G_EXC_ERROR;
END gen_pop_cp;


PROCEDURE gen_pop_cp_int (
    p_rule_id   IN    NUMBER
)
IS
l_sel_str VARCHAR2(4000) := NULL;
x_bool VARCHAR2(1);
l_procedure_name VARCHAR2(30) := '.GEN_POP_CP_INT' ;
BEGIN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
    END IF;
l(' ');
l('  PROCEDURE pop_cp_int ( ');
l('    	 p_batch_id IN	NUMBER, ');
l('      p_from_osr                       IN   VARCHAR2, ');
l('   	 p_to_osr                         IN   VARCHAR2 ');
l('     ) IS  ');
l(' 	l_last_fetch BOOLEAN := FALSE; ');
l('     l_cp_cur HZ_PARTY_STAGE.StageCurTyp; ');
l('  l_os VARCHAR2(30); ');
l('   BEGIN  ');
l('   l_os := HZ_IMP_DQM_STAGE.get_os(p_batch_id); ');
  x_bool := 'N';
  chk_et_req('CONTACT_POINTS', p_rule_id, x_bool);
  IF (x_bool = 'Y') THEN
 -- query for interface to tca
l(' 	open l_cp_cur for  ');
  get_select_str('CONTACT_POINTS', p_rule_id, l_sel_str, 'INT_TCA', NULL);
  l_sel_str := l_sel_str || ' , a.party_id '; --bug 5393826
  l( l_sel_str);
-- dbms_output.put_line('get_select_str (CONTACT_POINTS) ' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;
  l_sel_str := '';
/*    	select a.email_address, a.party_orig_system_reference,
            a.party_orig_system, a.cp_orig_system, a.cp_orig_system_reference,
            a.site_orig_system, a.site_orig_system_reference
            */
l('     	from HZ_IMP_CONTACTPTS_INT a ');
l('     	where a.batch_id = p_batch_id  ');
l('     	and a.party_orig_system_reference >= p_from_osr ');
l('     	and a.party_orig_system_reference <= p_to_osr ');
l('         and a.party_orig_system = l_os; ');
l('  ');
l('   LOOP ');
l('       FETCH l_cp_cur BULK COLLECT INTO ');
  get_trans_str('CONTACT_POINTS', p_rule_id, l_sel_str, 'INT_TCA');
  l_sel_str := l_sel_str || ' , H_P_PARTY_ID '; -- bug 5393826
  l( l_sel_str);
-- dbms_output.put_line('get_trans_str (CONTACT_POINTS) ' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;
  l_sel_str := '';
/*	          H_TX41
			, H_P_PARTY_OS
			, H_P_PARTY_OSR
	         , H_P_CP_OS
	         , H_P_CP_OSR
	         , H_P_PS_OS
		      , H_P_PS_OSR */
l('       LIMIT g_limit; ');
l('     IF l_cp_cur%NOTFOUND THEN ');
l('       l_last_fetch:=TRUE; ');
l('     END IF; ');
l('      ');
l('     IF H_P_CP_OS.COUNT=0 AND l_last_fetch THEN ');
l('       EXIT; ');
l('     END IF; ');
l('     ');
l('     FOR I in H_P_PARTY_OSR.FIRST..H_P_PARTY_OSR.LAST LOOP ');
     get_trans_proc('CONTACT_POINTS', p_rule_id, l_trans_list);
     FOR I in l_trans_list.FIRST..l_trans_list.LAST LOOP
--  dbms_output.put_line(' get_trans_proc (CONTACT_POINTS) ' || l_trans_list(I));
       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_trans_list(I));
        END IF;
       l(l_trans_list(I));
       l_trans_list.DELETE(I);
     END LOOP  ;
--    	H_TX41(I):=HZ_TRANS_PKG.WRNAMES_CLEANSE(H_TX41(I),NULL, 'EMAIL','CONTACT_POINTS','STAGE');
l('     END LOOP; ');
l('     SAVEPOINT pop_cp_int; ');
l('     BEGIN      ');
l('       FORALL I in H_P_PARTY_OSR.FIRST..H_P_PARTY_OSR.LAST ');
l('         INSERT INTO HZ_SRCH_CPTS ( ');
  get_insert_str('HZ_STAGED_CONTACT_POINTS', p_rule_id, l_sel_str, 'INT_TCA');
  l_sel_str := l_sel_str || ' , PARTY_ID '; -- bug 5393826
  l( l_sel_str);
-- dbms_output.put_line(' get_insert_str (CONTACT_POINTS) ' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;
  l_sel_str := '';
/*			PARTY_OS,
			PARTY_OSR,
			PARTY_SITE_OS,
			PARTY_SITE_OSR,
	         CONTACT_PT_OS,
	         CONTACT_PT_OSR
	           , TX41 */
l('         ) VALUES ( ');
   get_insert_val_str('HZ_STAGED_CONTACT_POINTS', p_rule_id, l_sel_str, 'INT_TCA');
   l_sel_str := l_sel_str || ' ,H_P_PARTY_ID(I) '; -- bug 5393826
  l( l_sel_str);
-- dbms_output.put_line('get_insert_val_str (CONTACT_POINTS) ' || l_sel_str);
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_PROCEDURE,G_PKG_NAME||l_procedure_name,l_sel_str);
    END IF;
  l_sel_str := '';
/*	          H_P_PARTY_OS(I),
	          H_P_PARTY_OSR(I),
	          H_P_PS_OS(I),
	          H_P_PS_OSR(I),
	          H_P_CP_OS(I),
	          H_P_CP_OSR(I)
	        , H_TX41(I) */
l('             ); ');
l('       EXCEPTION  ');
l('         WHEN OTHERS THEN ');
l('           ROLLBACK to pop_cp_int; ');
l('           RAISE; ');
l('       END; ');
l('      ');
l('       IF l_last_fetch THEN ');
l('         FND_CONCURRENT.AF_Commit; ');
l('         EXIT; ');
l('       END IF; ');
l('       FND_CONCURRENT.AF_Commit; ');
l('      ');
l('    END LOOP; ');
l('    CLOSE l_cp_cur ; ');
l(' ');
ELSE
   l(' null; ');
END IF;
l('  END pop_cp_int; ');
      EXCEPTION WHEN OTHERS THEN
          RAISE FND_API.G_EXC_ERROR;
END gen_pop_cp_int;

PROCEDURE gen_declarations (
        p_rule_id       IN      NUMBER
) IS
is_using_allow_cust_attr VARCHAR2(1) := 'N';
l_procedure_name VARCHAR2(30) := '.GEN_DECLARATIONS' ;
BEGIN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
    END IF;
  l('    g_match_rule_id NUMBER := ' ||p_rule_id || ';');
  l('    TYPE StageImpContactCurTyp IS REF CURSOR;');
  l('    TYPE NumberList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;');
  l('    TYPE CharList2000 IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;');
  l('    TYPE CharList1000 IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;');
  l('    TYPE CharList30 IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;');
  l('    TYPE CharList60 IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;');
  l('    TYPE CharList240 IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;');
  l('    TYPE CharList1 IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;');
  l('    TYPE RowIdList IS TABLE OF rowid INDEX BY BINARY_INTEGER; ');
  l('    H_P_ROW_ID RowIdList; ');
  l('    H_P_N_PARTY CharList1; ');
  l('    H_P_PARTY_ID NumberList;');
  l('    H_P_PARTY_OS CharList30;');
  l('    H_P_PARTY_OSR CharList240;');
  l('    H_P_PS_OS CharList30;');
  l('    H_P_PS_OSR CharList240;');
  l('    H_P_P_TYPE CharList30; ');
  l('    H_P_PARTY_SITE_ID NumberList;');
  l('    H_P_CONTACT_POINT_ID NumberList;');
  l('    H_P_CP_OS CharList30;');
  l('    H_P_CP_OSR CharList240;');
  l('    H_P_SUBJECT_OS CharList30;');
  l('    H_P_SUBJECT_OSR CharList240;');
  l('    H_P_CONTACT_OS CharList30;');
  l('    H_P_CONTACT_OSR CharList240;');
  l('    H_P_CP_TYPE CharList30; ');
  l('    H_TX0 CharList2000;');
  l('    g_limit NUMBER := 1000;');
  l('    H_CT_OBJ_ID NumberList; ');

      FOR TX IN ( select STAGED_ATTRIBUTE_COLUMN
            from hz_trans_functions_b
            where attribute_id in (select attribute_id
            from hz_match_rule_primary
            where match_rule_id = p_rule_id)
            union
            select STAGED_ATTRIBUTE_COLUMN
            from hz_trans_functions_b
            where attribute_id in (select attribute_id
            from hz_match_rule_secondary
            where match_rule_id = p_rule_id)
            order by STAGED_ATTRIBUTE_COLUMN
            ) LOOP
                 l( '    H_' || TX.STAGED_ATTRIBUTE_COLUMN || ' CharList2000;');
       END LOOP;

       FOR TX2 IN ( select attribute_id
            from hz_trans_attributes_vl
            --Fix for bug 4669257. Removing the hardcoded reference below.
            -- where userenv('LANG') = 'US'
            where attribute_id in (select attribute_id
            from hz_match_rule_primary
            where match_rule_id = p_rule_id
            union
            select attribute_id
            from hz_match_rule_secondary
            where match_rule_id = p_rule_id)
            and custom_attribute_procedure is null
            ) LOOP
               l( '    H_' || TX2.attribute_id || 'E CharList2000;');
       END LOOP;

       is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'CONTACTS','CONTACT_NAME');--using_contact_name(p_rule_id);
        IF (is_using_allow_cust_attr = 'Y') THEN
            l('    H_CT_NAME CharList2000; ');
 -- convert to bind variable query. ????
/*   l_sql_stmt := ' select count(distinct batch_id) from ' || p_table_name || ' where batch_id <> :1';
    execute immediate l_sql_stmt into l_count using p_batch_id;
  */
            FOR TX5 IN ( select STAGED_ATTRIBUTE_COLUMN
                        from hz_trans_functions_b
                        where attribute_id in (select attribute_id
                            from hz_trans_attributes_b
                            where attribute_name = 'CONTACT_NAME'
                            and entity_name = 'CONTACTS')
                            and function_id in (select function_id
                                from hz_match_rule_primary e, hz_primary_trans d
                                where match_rule_id = p_rule_id
                                and e.PRIMARY_ATTRIBUTE_ID = d.PRIMARY_ATTRIBUTE_ID
                        union
                        select function_id
                        from hz_match_rule_secondary g, hz_secondary_trans f
                        where f.SECONDARY_ATTRIBUTE_ID = g.SECONDARY_ATTRIBUTE_ID
                        and match_rule_id = p_rule_id)
                        order by STAGED_ATTRIBUTE_COLUMN ) LOOP
--                 l( '    H_' || TX.STAGED_ATTRIBUTE_COLUMN || ' CharList2000;');
               l('    H_CT_CUST_' || TX5.STAGED_ATTRIBUTE_COLUMN || ' CharList2000;' );
              END LOOP;

/*            l('    H_CT_CUST_TX2 CharList2000; ');
            l('    H_CT_CUST_TX5 CharList2000; ');
            l('    H_CT_CUST_TX6 CharList2000; ');
            l('    H_CT_CUST_TX156 CharList2000;   ');
            l('    H_CT_CUST_TX23 CharList2000;   '); -- added extra
            l('    H_CT_CUST_TX24 CharList2000;   '); -- added extra
            */
       END IF;

       is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'CONTACT_POINTS','RAW_PHONE_NUMBER');--using_raw_ph_no(p_rule_id);
        IF (is_using_allow_cust_attr = 'Y') THEN
            l('    H_P_CP_R_PH_NO CharList60; ');

            FOR TX3 IN ( select STAGED_ATTRIBUTE_COLUMN
                        from hz_trans_functions_b
                        where attribute_id in (select attribute_id
                            from hz_trans_attributes_b
                            where attribute_name = 'RAW_PHONE_NUMBER'
                            and entity_name = 'CONTACT_POINTS')
                            and function_id in (select function_id
                                from hz_match_rule_primary e, hz_primary_trans d
                                where match_rule_id = p_rule_id
                                and e.PRIMARY_ATTRIBUTE_ID = d.PRIMARY_ATTRIBUTE_ID
                        union
                        select function_id
                        from hz_match_rule_secondary g, hz_secondary_trans f
                        where f.SECONDARY_ATTRIBUTE_ID = g.SECONDARY_ATTRIBUTE_ID
                        and match_rule_id = p_rule_id)
                        order by STAGED_ATTRIBUTE_COLUMN ) LOOP
--                 l( '    H_' || TX.STAGED_ATTRIBUTE_COLUMN || ' CharList2000;');
               l('    H_CP_CUST_' || TX3.STAGED_ATTRIBUTE_COLUMN || ' CharList2000;' );
              END LOOP;
/*            l('    H_CP_CUST_TX10 CharList2000; ');
            l('    H_CP_CUST_TX158 CharList2000; ');
*/
       END IF;
       is_using_allow_cust_attr := using_allow_cust(p_rule_id, 'PARTY_SITES','ADDRESS');--using_address(p_rule_id);
        IF (is_using_allow_cust_attr = 'Y') THEN
            l('    H_P_PS_ADD CharList1000; ');
            FOR TX4 IN ( select STAGED_ATTRIBUTE_COLUMN
                        from hz_trans_functions_b
                        where attribute_id in (select attribute_id
                            from hz_trans_attributes_b
                            where attribute_name = 'ADDRESS'
                            and entity_name = 'PARTY_SITES')
                            and function_id in (select function_id
                                from hz_match_rule_primary e, hz_primary_trans d
                                where match_rule_id = p_rule_id
                                and e.PRIMARY_ATTRIBUTE_ID = d.PRIMARY_ATTRIBUTE_ID
                        union
                        select function_id
                        from hz_match_rule_secondary g, hz_secondary_trans f
                        where f.SECONDARY_ATTRIBUTE_ID = g.SECONDARY_ATTRIBUTE_ID
                        and match_rule_id = p_rule_id)
                        order by STAGED_ATTRIBUTE_COLUMN ) LOOP
--                 l( '    H_' || TX.STAGED_ATTRIBUTE_COLUMN || ' CharList2000;');
               l('    H_PS_CUST_' || TX4.STAGED_ATTRIBUTE_COLUMN || ' CharList2000;' );
              END LOOP;
/*            l('    H_PS_CUST_TX3 CharList240; ');
            l('    H_PS_CUST_TX4 CharList240; ');
            l('    H_PS_CUST_TX26 CharList240; ');
            l('    H_PS_CUST_TX27 CharList240; ');
            l('    H_P_PS_CUST_TX3 CharList240; ');
            l('    H_P_PS_CUST_TX4 CharList240; ');
            l('    H_P_PS_CUST_TX26 CharList240; ');
            l('    H_P_PS_CUST_TX27 CharList240; ');
            */
       END IF;
      EXCEPTION WHEN OTHERS THEN
          RAISE FND_API.G_EXC_ERROR;
END gen_declarations;

FUNCTION chk_is_std(p_attribute_name IN VARCHAR2
) RETURN VARCHAR2
IS
l_procedure_name VARCHAR2(30) := '.CHK_IS_STD' ;
l_attribute_name VARCHAR2(255) := null ;
l_bool VARCHAR2(1) := 'N';
l_status VARCHAR2(255);
l_owner VARCHAR2(255);
l_temp VARCHAR2(255);


    CURSOR c1 is select 'Y'
    from sys.dba_tab_columns
    where table_name = 'HZ_IMP_ADDRESSES_INT'
    and column_name = l_attribute_name and owner = l_owner;
BEGIN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
    END IF;
    l_attribute_name := p_attribute_name || '_STD';
    IF (fnd_installation.GET_APP_INFO('AR',l_status,l_temp,l_owner)) THEN
        OPEN c1;
        FETCH c1 INTO l_bool;
        IF c1%NOTFOUND THEN
            l_attribute_name := ' a.' || p_attribute_name;
        ELSE
            l_attribute_name := ' decode(accept_standardized_flag, ''Y'', a.' || l_attribute_name || ', a.' || p_attribute_name || ')'  ;
        END IF;
       RETURN   l_attribute_name;
    END IF;
      EXCEPTION WHEN OTHERS THEN
        l_attribute_name := ' a.' || p_attribute_name;
END chk_is_std;

PROCEDURE chk_et_req(p_entity_name IN VARCHAR2,
                     p_rule_id IN NUMBER,
                     x_bool    IN OUT NOCOPY VARCHAR2
) IS
l_procedure_name VARCHAR2(30) := '.CHK_RT_REQ' ;
l_table_name VARCHAR2(30);
BEGIN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
    END IF;
    get_table_name(p_entity_name, l_table_name);
    BEGIN
       IF (p_entity_name = 'CONTACTS') THEN
            x_bool := using_allow_cust(p_rule_id, 'CONTACTS','CONTACT_NAME');--using_contact_name(p_rule_id);
       END IF;
       IF (x_bool <> 'Y') THEN
                select distinct 'Y' into x_bool
                from hz_trans_attributes_vl
                --Fix for bug 4669257. Removing the hardcoded reference below.
                --where userenv('LANG') = 'US'
                where entity_name = p_entity_name
                and custom_attribute_procedure is null
                and HZ_IMP_DQM_STAGE.EXIST_COL(attribute_name, p_entity_name) = 'Y'
--                and attribute_name not in ('SIC_CODE', 'SIC_CODE_TYPE', 'TAX_NAME', 'CATEGORY_CODE', 'IDENTIFYING_ADDRESS_FLAG', 'STATUS', 'PRIMARY_FLAG', 'REFERENCE_USE_FLAG' )
                and attribute_id in ( select attribute_id
                    from hz_match_rule_primary
                    where match_rule_id = p_rule_id
                    union
                    select attribute_id
                    from hz_match_rule_secondary
                    where match_rule_id = p_rule_id);
         END IF;
    EXCEPTION
    WHEN OTHERS THEN
        x_bool := 'N';
    END;
END   chk_et_req;


PROCEDURE gen_pkg_body (
        p_pkg_name      IN      VARCHAR2,
        p_rule_id	IN	NUMBER
) IS

  -- Local Variables
  FIRST boolean;
  FIRST1 boolean;
  UPSTMT boolean;
  l_match_str VARCHAR2(255);
  l_attrib_cnt NUMBER;
  l_party_filter VARCHAR2(1) := null;
  l_ps_filter VARCHAR2(1) := null;
  l_contact_filter VARCHAR2(1) := null;
  l_cpt_filter VARCHAR2(1) := null;
  l_num_primary NUMBER;
  l_num_secondary NUMBER;
  l_ent VARCHAR2(30);
  l_max_score NUMBER;
  l_match_threshold NUMBER;
  l_purpose VARCHAR2(30);
  TYPE NumberList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE CharList IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;
  attribList NumberList;
  l_party_filter_str VARCHAR2(2000);
  l_dyn_party_filter_str VARCHAR2(2000);
  l_p_select_list VARCHAR2(1000);
  l_p_param_list VARCHAR2(1000);
  l_p_into_list VARCHAR2(1000);
  l_ps_select_list VARCHAR2(1000);
  l_ps_param_list VARCHAR2(1000);
  l_ps_into_list VARCHAR2(1000);
  l_c_select_list VARCHAR2(1000);
  l_c_param_list VARCHAR2(1000);
  l_c_into_list VARCHAR2(1000);
  l_cpt_select_list VARCHAR2(1000);
  l_cpt_param_list VARCHAR2(1000);
  l_cpt_into_list VARCHAR2(1000);
  cnt NUMBER;
  l_party_filt_bind CharList;
  l_cpt_type VARCHAR2(255);
  l_trans VARCHAR2(4000);
  l_auto_merge_score NUMBER;
  tmp VARCHAR2(30);
  l_procedure_name VARCHAR2(30) := '.GEN_PKG_BODY' ;
BEGIN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter');
    END IF;
  IF is_test THEN
    l('CREATE or REPLACE PACKAGE BODY ' || p_pkg_name || ' IS'); -- this
  END IF;
  gen_declarations(p_rule_id);
 -- gen_static_text(p_rule_id);
  gen_pop_parties(p_rule_id);
  gen_pop_party_sites(p_rule_id);
  gen_pop_cp(p_rule_id);
  gen_get_contact_cur(p_rule_id);
  gen_pop_contacts(p_rule_id);
  gen_pop_parties_int(p_rule_id);
  gen_pop_party_sites_int(p_rule_id);
  gen_pop_cp_int(p_rule_id);
  gen_get_contact_cur_int(p_rule_id);
  gen_pop_contacts_int(p_rule_id);
  IF is_test THEN
     l('END ' || p_pkg_name || ';'); -- this
  END IF;
      EXCEPTION WHEN OTHERS THEN
          RAISE FND_API.G_EXC_ERROR;

END gen_pkg_body;

FUNCTION EXIST_COL (attr_name IN VARCHAR2,
                entity IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN
  IF entity = 'PARTY' or entity = 'HZ_STAGED_PARTIES' THEN
    IF attr_name IN ('PARTY_NAME') THEN
      RETURN 'Y';
    END IF;
    EXECUTE IMMEDIATE 'select '||attr_name||' from HZ_IMP_PARTIES_INT where rownum=1';
  ELSIF entity = 'PARTY_SITES' or entity = 'HZ_STAGED_PARTY_SITES' THEN
    IF attr_name IN ('ADDRESS') THEN
      RETURN 'Y';
    END IF;
    EXECUTE IMMEDIATE 'select '||attr_name||' from HZ_IMP_ADDRESSES_INT where rownum=1';
  ELSIF entity = 'CONTACTS' or entity = 'HZ_STAGED_CONTACTS' THEN
    IF attr_name IN ('CONTACT_NAME') THEN
      RETURN 'Y';
    END IF;
    BEGIN
      EXECUTE IMMEDIATE 'select '||attr_name||' from HZ_IMP_CONTACTS_INT where rownum=1';
    EXCEPTION
      WHEN OTHERS THEN
        EXECUTE IMMEDIATE 'select '||attr_name||' from hz_imp_parties_int where rownum=1';
    END;
  ELSIF entity = 'CONTACT_POINTS' or entity = 'HZ_STAGED_CONTACT_POINTS' THEN
    IF attr_name IN ('RAW_PHONE_NUMBER') THEN
      RETURN 'Y';
    END IF;
    EXECUTE IMMEDIATE 'select '||attr_name||' from HZ_IMP_CONTACTPTS_INT where rownum=1';
  END IF;
  RETURN 'Y';
EXCEPTION
  WHEN others THEN
    RETURN 'N';
END EXIST_COL;

/*
PROCEDURE gen_hz_dqm_imp_debug(
    	p_rule_id	IN	NUMBER,
        x_return_status         OUT NOCOPY    VARCHAR2,
        x_msg_count             OUT NOCOPY    NUMBER,
        x_msg_data              OUT NOCOPY    VARCHAR2
) IS

   CURSOR check_inactive IS
    SELECT 1
    FROM hz_match_rule_primary p, hz_primary_trans pt, hz_trans_functions_vl f
    WHERE p.match_rule_id = p_rule_id
    AND pt.PRIMARY_ATTRIBUTE_ID = p.PRIMARY_ATTRIBUTE_ID
    AND f.function_id = pt.function_id
    --Fix for bug 4669257. Removing the hardcoded reference below.
    --AND userenv('LANG') = 'US'
    AND nvl(f.ACTIVE_FLAG,'Y') = 'N'
    UNION
    SELECT 1
    FROM hz_match_rule_secondary s, hz_secondary_trans pt, hz_trans_functions_vl f
    WHERE s.match_rule_id = p_rule_id
    AND pt.SECONDARY_ATTRIBUTE_ID = s.SECONDARY_ATTRIBUTE_ID
    AND f.function_id = pt.function_id
    --Fix for bug 4669257. Removing the hardcoded reference below.
    --AND userenv('LANG') = 'US'
    AND nvl(f.ACTIVE_FLAG,'Y') = 'N';

    -- Local variable declarations
    l_tmp VARCHAR2(255);
    l_rule_id NUMBER;
    l_batch_flag VARCHAR2(1);
    l_package_name VARCHAR2(2000);
    l_procedure_name VARCHAR2(30) := '.GEN_HZ_DQM_IMP_DEBUG' ;
BEGIN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log_repository.init;
       fnd_log.string(fnd_log.LEVEL_STATEMENT,G_PKG_NAME||l_procedure_name,'Enter, p_rule_id='||p_rule_id);
    END IF;
  --Initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Initialize the compiled package name
  l_rule_id := TO_NUMBER(p_rule_id);
  l_package_name := 'HZ_IMP_MATCH_RULE_'||p_rule_id;
  -- Initialize message stack
  FND_MSG_PUB.initialize;


 BEGIN
    -- Verify that the match rule exists
    SELECT 1 INTO l_batch_flag
    FROM HZ_MATCH_RULES_VL
    WHERE match_rule_id = l_rule_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_STAGE_NO_RULE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END;
-- Check if match rule has any inactive transformations
  OPEN check_inactive;
  FETCH check_inactive INTO l_tmp;
  IF check_inactive%FOUND THEN
    CLOSE  check_inactive;
      BEGIN
        EXECUTE IMMEDIATE 'DROP PACKAGE HZ_MATCH_RULE_'||l_rule_id;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      fnd_message.set_name('AR','HZ_MR_HAS_INACTIVE_TX');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE check_inactive;
  -- Generate and compile match rule package spec
  HZ_GEN_PLSQL.new(l_package_name, 'PACKAGE');
  gen_pkg_spec(l_package_name, l_rule_id);
  HZ_GEN_PLSQL.compile_code;
  -- Generate and compile match rule package body
  HZ_GEN_PLSQL.new(l_package_name, 'PACKAGE BODY');
  gen_pkg_body(l_package_name, l_rule_id);
  HZ_GEN_PLSQL.compile_code;

    --Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_encoded => FND_API.G_FALSE,
    p_count => x_msg_count,
    p_data  => x_msg_data);

  UPDATE HZ_MATCH_RULES_B SET COMPILATION_FLAG = 'C' WHERE MATCH_RULE_ID = l_rule_id;
  COMMIT;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
    x_return_status := FND_API.G_RET_STS_ERROR;
    UPDATE HZ_MATCH_RULES_B SET COMPILATION_FLAG = 'U' WHERE MATCH_RULE_ID = l_rule_id;
    COMMIT;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    UPDATE HZ_MATCH_RULES_B SET COMPILATION_FLAG = 'U' WHERE MATCH_RULE_ID = l_rule_id;
    COMMIT;
  WHEN OTHERS THEN

    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC','compile_match_rule');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;

    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    UPDATE HZ_MATCH_RULES_B SET COMPILATION_FLAG = 'U' WHERE MATCH_RULE_ID = l_rule_id;
    COMMIT;

END gen_hz_dqm_imp_debug;
*/
END HZ_IMP_DQM_STAGE;


/
