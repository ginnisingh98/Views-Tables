--------------------------------------------------------
--  DDL for Package Body HZ_MIGRATE_MOSR_REFERENCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_MIGRATE_MOSR_REFERENCES" AS
/* $Header: ARHMPINSB.pls 120.4 2006/02/15 06:28:33 vravicha noship $ */

PROCEDURE MIGRATE_PARTY_REFERENCES(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2, l_batch_size IN varchar2) IS

cursor parties is
select orig_system_reference, party_id, created_by, nvl(created_by_module,'TCA'),
 nvl(application_id,'222'), creation_date,last_updated_by, last_update_date, nvl(last_update_login,-1)
 from hz_parties party where orig_system_reference is not null and status in ('A','I')
 and not exists(select 'X' from hz_orig_sys_references osr
                where party.party_id = osr.owner_table_id
                and  osr.owner_table_name = 'HZ_PARTIES'
                and osr.orig_system = 'UNKNOWN'
                and party.orig_system_reference =
                    osr.orig_system_reference
                and osr.status = 'A')
 and not exists(select 'N' from hz_orig_sys_mapping where owner_table_name='HZ_PARTIES' and multiple_flag='N' and orig_system='UNKNOWN');

cursor locations is
select orig_system_reference, location_id, created_by, nvl(created_by_module,'TCA'),
 nvl(application_id,'222'), creation_date,last_updated_by, last_update_date, nvl(last_update_login,-1)
 from hz_locations locations where orig_system_reference is not null
 and not exists(select 'X' from hz_orig_sys_references osr
                where locations.location_id = osr.owner_table_id
                and  osr.owner_table_name = 'HZ_LOCATIONS'
                and osr.orig_system = 'UNKNOWN'
                and locations.orig_system_reference =
                    osr.orig_system_reference
                and osr.status = 'A')
 and not exists(select 'N' from hz_orig_sys_mapping where owner_table_name='HZ_LOCATIONS' and multiple_flag='N' and orig_system='UNKNOWN');

cursor org_contacts is
select orig_system_reference, org_contact_id, created_by, nvl(created_by_module,'TCA'),
 nvl(application_id,'222'), creation_date,last_updated_by, last_update_date, nvl(last_update_login,-1)
 from hz_org_contacts org_contacts where orig_system_reference is not null and status in ('A','I')
 and not exists(select 'X' from hz_orig_sys_references osr
                where org_contacts.org_contact_id = osr.owner_table_id
                and  osr.owner_table_name = 'HZ_ORG_CONTACTS'
                and osr.orig_system = 'UNKNOWN'
                and org_contacts.orig_system_reference =
                    osr.orig_system_reference
                and osr.status = 'A')
and not exists(select 'N' from hz_orig_sys_mapping where owner_table_name='HZ_ORG_CONTACTS' and multiple_flag='N' and orig_system='UNKNOWN');

-- Bug 4956873
cursor contact_points is
select /*+ parallel(contact) */ orig_system_reference, contact_point_id, created_by, nvl(created_by_module,'TCA'),
 nvl(application_id,'222'), creation_date,last_updated_by, last_update_date, nvl(last_update_login,-1)
 from hz_contact_points contact where orig_system_reference is not null and status in ('A','I')
 and not exists(select /*+ parallel(osr) */ 'X' from hz_orig_sys_references osr
                where contact.contact_point_id = osr.owner_table_id
                and  osr.owner_table_name = 'HZ_CONTACT_POINTS'
                and osr.orig_system = 'UNKNOWN'
                and contact.orig_system_reference =
                    osr.orig_system_reference
                and osr.status = 'A')
 and not exists(select 'N' from hz_orig_sys_mapping where owner_table_name='HZ_CONTACT_POINTS' and multiple_flag='N' and orig_system='UNKNOWN');

-- Bug 4956873
cursor org_contact_roles is
select /*+ parallel(contact_roles) */ orig_system_reference, org_contact_role_id, created_by, nvl(created_by_module,'TCA'),
 nvl(application_id,'222'), creation_date,last_updated_by, last_update_date, nvl(last_update_login,-1)
 from hz_org_contact_roles contact_roles where orig_system_reference is not null and status in ('A','I')
 and not exists(select /*+ parallel(osr) */ 'X' from hz_orig_sys_references osr
                where contact_roles.org_contact_role_id = osr.owner_table_id
                and  osr.owner_table_name = 'HZ_ORG_CONTACT_ROLES'
                and osr.orig_system = 'UNKNOWN'
                and contact_roles.orig_system_reference =
                    osr.orig_system_reference
                and osr.status = 'A')
 and not exists(select 'N' from hz_orig_sys_mapping where owner_table_name='HZ_ORG_CONTACT_ROLES' and multiple_flag='N' and orig_system='UNKNOWN');

cursor party_sites is
select orig_system_reference, party_site_id, created_by, nvl(created_by_module,'TCA'),
 nvl(application_id,'222'), creation_date,last_updated_by, last_update_date, nvl(last_update_login,-1)
 from hz_party_sites party_sites where orig_system_reference is not null and status in ('A','I')
 and not exists(select 'X' from hz_orig_sys_references osr
                where party_sites.party_site_id = osr.owner_table_id
                and  osr.owner_table_name = 'HZ_PARTY_SITES'
                and osr.orig_system = 'UNKNOWN'
                and party_sites.orig_system_reference =
                    osr.orig_system_reference
                and osr.status = 'A')
 and not exists(select 'N' from hz_orig_sys_mapping where owner_table_name='HZ_PARTY_SITES' and multiple_flag='N' and orig_system='UNKNOWN');

TYPE orig_sys_ref_type is TABLE OF HZ_ORIG_SYS_REFERENCES.orig_system_reference%TYPE;
Type created_by_type is TABLE of HZ_ORIG_SYS_REFERENCES.created_by%TYPE;
Type created_by_module_type is TABLE of HZ_ORIG_SYS_REFERENCES.created_by_module%TYPE;
Type appl_id_type is TABLE of HZ_ORIG_SYS_REFERENCES.application_id%TYPE;
Type last_updated_by_type is TABLE of HZ_ORIG_SYS_REFERENCES.last_updated_by%TYPE;
Type creation_date_type is TABLE of HZ_ORIG_SYS_REFERENCES.creation_date%TYPE;
Type last_update_date_type is TABLE of HZ_ORIG_SYS_REFERENCES.last_update_date%TYPE;
Type last_update_login_type is TABLE of HZ_ORIG_SYS_REFERENCES.last_update_login%TYPE;

TYPE owner_tableid_type IS TABLE OF HZ_ORIG_SYS_REFERENCES.owner_table_id%TYPE;

orig_sys_ref orig_sys_ref_type;
created_by created_by_type;
created_by_module created_by_module_type;
appl_id appl_id_type;
last_updated_by last_updated_by_type;
creation_date creation_date_type;
last_update_date last_update_date_type;
last_update_login last_update_login_type;

party_id owner_tableid_type;
location_id owner_tableid_type;
org_contact_id owner_tableid_type;
contact_point_id owner_tableid_type;
org_contact_role_id owner_tableid_type;
party_site_id owner_tableid_type;

l_limit_rows number := 10000; /* Bug 4026560 */
i number;
l_last_fetch boolean;

BEGIN
retcode:=0;

IF l_batch_size < 10000 THEN
     l_limit_rows := l_batch_size ;
END IF ;

l_last_fetch:=false;
open parties;
loop
 fetch parties bulk collect into
 orig_sys_ref, party_id, created_by, created_by_module,
 appl_id, creation_date, last_updated_by, last_update_date,
 last_update_login limit l_limit_rows;

 if parties%NOTFOUND then
  l_last_fetch:=true;
 end if;

 if party_id.COUNT=0 and l_last_fetch then
  exit;
 end if;

 forall i in party_id.FIRST..party_id.LAST
insert into hz_orig_sys_references
(orig_system_ref_id, orig_system, orig_system_reference, owner_table_name, owner_table_id,
 status, start_date_active, end_date_active, reason_code, created_by,
 old_orig_system_reference, created_by_module, application_id, creation_date, last_updated_by,
 last_update_date,last_update_login, object_version_number)
 values(hz_orig_system_ref_s.nextval,'UNKNOWN', orig_sys_ref(i), 'HZ_PARTIES', party_id(i),
 'A', sysdate, null, null, created_by(i), null, created_by_module(i), appl_id(i),
 creation_date(i), last_updated_by(i), last_update_date(i),
 last_update_login(i), 1);

 if l_last_fetch then
  exit;
 end if;

  end loop;
close parties;

l_last_fetch:=false;
open locations;
loop
 fetch locations bulk collect into
 orig_sys_ref, location_id, created_by, created_by_module,
 appl_id, creation_date, last_updated_by, last_update_date,
 last_update_login limit l_limit_rows;

 if locations%NOTFOUND then
  l_last_fetch:=true;
 end if;

 if location_id.COUNT=0 and l_last_fetch then
  exit;
 end if;

 forall i in location_id.first..location_id.last
 insert into hz_orig_sys_references
 (orig_system_ref_id, orig_system, orig_system_reference, owner_table_name, owner_table_id,
 status, start_date_active, end_date_active, reason_code, created_by,
 old_orig_system_reference, created_by_module, application_id, creation_date, last_updated_by,
 last_update_date,last_update_login, object_version_number)
 values(hz_orig_system_ref_s.nextval,'UNKNOWN', orig_sys_ref(i), 'HZ_LOCATIONS', location_id(i),
 'A', sysdate, null, null, created_by(i), null, created_by_module(i), appl_id(i),
 creation_date(i), last_updated_by(i), last_update_date(i), last_update_login(i), 1);

 if l_last_fetch then
  exit;
 end if;

  end loop;
close locations;


l_last_fetch:=false;
open org_contacts;
loop
 fetch org_contacts bulk collect into
 orig_sys_ref, org_contact_id, created_by, created_by_module,
 appl_id, creation_date, last_updated_by, last_update_date,
 last_update_login limit l_limit_rows;

 if org_contacts%NOTFOUND then
  l_last_fetch:=true;
 end if;

 if org_contact_id.COUNT=0 and l_last_fetch then
  exit;
 end if;
 forall i in org_contact_id.first..org_contact_id.last
 insert into hz_orig_sys_references
 (orig_system_ref_id, orig_system, orig_system_reference, owner_table_name, owner_table_id,
 status, start_date_active, end_date_active, reason_code, created_by,
 old_orig_system_reference, created_by_module, application_id, creation_date, last_updated_by,
 last_update_date,last_update_login, object_version_number)
 values(hz_orig_system_ref_s.nextval,'UNKNOWN', orig_sys_ref(i), 'HZ_ORG_CONTACTS', org_contact_id(i),
 'A', sysdate, null, null, created_by(i), null, created_by_module(i), appl_id(i), creation_date(i),
 last_updated_by(i), last_update_date(i), last_update_login(i), 1);

 if l_last_fetch then
  exit;
 end if;

  end loop;
close org_contacts;

l_last_fetch:=false;
open contact_points;
loop
 fetch contact_points bulk collect into
 orig_sys_ref, contact_point_id, created_by, created_by_module,
 appl_id, creation_date, last_updated_by, last_update_date,
 last_update_login limit l_limit_rows;

 if contact_points%NOTFOUND then
  l_last_fetch:=true;
 end if;

 if contact_point_id.COUNT=0 and l_last_fetch then
  exit;
 end if;
 forall i in contact_point_id.first..contact_point_id.last
 insert into hz_orig_sys_references
 (orig_system_ref_id, orig_system, orig_system_reference, owner_table_name, owner_table_id,
 status, start_date_active, end_date_active, reason_code, created_by,
 old_orig_system_reference, created_by_module, application_id, creation_date, last_updated_by,
 last_update_date,last_update_login, object_version_number)
 values(hz_orig_system_ref_s.nextval,'UNKNOWN', orig_sys_ref(i), 'HZ_CONTACT_POINTS', contact_point_id(i),
 'A', sysdate, null, null, created_by(i), null, created_by_module(i), appl_id(i), creation_date(i), last_updated_by(i),
 last_update_date(i), last_update_login(i), 1);

 if l_last_fetch then
  exit;
 end if;

  end loop;
close contact_points;

 l_last_fetch:=false;
open org_contact_roles;
loop
 fetch org_contact_roles bulk collect into
 orig_sys_ref, org_contact_role_id, created_by, created_by_module,
 appl_id, creation_date, last_updated_by, last_update_date,
 last_update_login limit l_limit_rows;

 if org_contact_roles%NOTFOUND then
  l_last_fetch:=true;
 end if;

 if org_contact_role_id.COUNT=0 and l_last_fetch then
  exit;
 end if;
 forall i in org_contact_role_id.first..org_contact_role_id.last
 insert into hz_orig_sys_references
 (orig_system_ref_id, orig_system, orig_system_reference, owner_table_name, owner_table_id,
 status, start_date_active, end_date_active, reason_code, created_by,
 old_orig_system_reference, created_by_module, application_id, creation_date, last_updated_by,
 last_update_date,last_update_login, object_version_number)
 values(hz_orig_system_ref_s.nextval,'UNKNOWN', orig_sys_ref(i), 'HZ_ORG_CONTACT_ROLES', org_contact_role_id(i),
 'A', sysdate, null, null, created_by(i), null, created_by_module(i), appl_id(i), creation_date(i), last_updated_by(i),
 last_update_date(i), last_update_login(i), 1);

  if l_last_fetch then
  exit;
 end if;

  end loop;
close org_contact_roles;

l_last_fetch:=false;
open party_sites;
loop
 fetch party_sites bulk collect into
 orig_sys_ref, party_site_id, created_by, created_by_module,
 appl_id, creation_date, last_updated_by, last_update_date,
 last_update_login limit l_limit_rows;

 if party_sites%NOTFOUND then
  l_last_fetch:=true;
 end if;

 if party_site_id.COUNT=0 and l_last_fetch then
  exit;
 end if;
 forall i in party_site_id.first..party_site_id.last
 insert into hz_orig_sys_references
 (orig_system_ref_id, orig_system, orig_system_reference, owner_table_name, owner_table_id,
 status, start_date_active, end_date_active, reason_code, created_by,
 old_orig_system_reference, created_by_module, application_id, creation_date, last_updated_by,
 last_update_date,last_update_login, object_version_number)
 values(hz_orig_system_ref_s.nextval,'UNKNOWN', orig_sys_ref(i), 'HZ_PARTY_SITES', party_site_id(i),
 'A', sysdate, null, null, created_by(i), null, created_by_module(i), appl_id(i), creation_date(i),
 last_updated_by(i), last_update_date(i), last_update_login(i), 1);

 if l_last_fetch then
  exit;
 end if;

  end loop;
close party_sites;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    retcode := 2;
    errbuf := errbuf || SQLERRM;
    FND_FILE.close;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    retcode := 2;
    errbuf := errbuf || SQLERRM;
    FND_FILE.close;
  WHEN OTHERS THEN
    retcode := 2;
    errbuf := errbuf || SQLERRM;
    FND_FILE.close;

END;
END HZ_MIGRATE_MOSR_REFERENCES;

/
