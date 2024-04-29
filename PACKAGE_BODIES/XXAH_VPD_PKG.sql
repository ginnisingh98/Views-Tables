--------------------------------------------------------
--  DDL for Package Body XXAH_VPD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_VPD_PKG" AS
--#########################################################################
--#
--#                 Copyright (c) 2010 Oracle Corporation
--#                        All rights reserved
--#
--#########################################################################
--#
--# Application   : Ahold Customizations
--# Module        :
--# File          : $RCSfile: xxahvpd.plb $
--# Version       : $Revision: 1.0 $
--# Description   : Package containing functions and procedures related to
--#                 the implementation of a VPD security
--#
--#
--# Date        Authors           Change reference/Description
--# ----------- ----------------- ----------------------------------
--# 01-DEC-2010 Johan Peeters     Initial version
--#
--#
--##########################################################################
--
--
g_module VARCHAR2(2000) := 'oracle.apps.xxah.xxah_vpd_pkg';
--
FUNCTION parent_child_org(p_organization_id NUMBER
                         ,p_direction       VARCHAR2
                         ) RETURN VARCHAR2 IS
  CURSOR c_org_parent(p_org_id NUMBER) IS
--      SELECT pose.org_structure_element_id
--            ,pose.business_group_id
--            ,pose.org_structure_version_id
--            ,pose.organization_id_parent
--            ,pose.organization_id_child
--            ,haou_child.NAME  child_org
--            ,haou_parent.NAME parent_org
    SELECT pose.organization_id_parent
          ,haou_parent.NAME parent_org
    FROM PER_ORG_STRUCTURE_ELEMENTS pose
        ,PER_ORG_STRUCTURE_VERSIONS posv
        ,hr_all_organization_units haou_child
        ,hr_all_organization_units haou_parent
        ,per_organization_structures  pos
    WHERE pose.ORG_STRUCTURE_VERSION_ID  = posv.ORG_STRUCTURE_VERSION_ID
      AND pose.organization_id_child = p_organization_id
      AND haou_child.organization_id = pose.organization_id_child
      AND haou_parent.organization_id = pose.organization_id_parent
      AND pos.organization_structure_id = posv.organization_structure_id
      AND pos.NAME = 'Vendor Allowance';
  --
  l_org_id NUMBER;
  l_org_name VARCHAR2(240);
  l_module VARCHAR2(2000) := g_module||'.parent_child_org';
BEGIN
  IF p_direction = 'PARENT' THEN
    --
    OPEN c_org_parent(p_organization_id);
    FETCH c_org_parent INTO l_org_id, l_org_name;
    IF c_org_parent%FOUND THEN
      CLOSE c_org_parent;
      fnd_log.STRING(fnd_log.level_statement,l_module,'Parent org = '||l_org_id);
      l_org_name := parent_child_org(l_org_id,'PARENT')||'#'||l_org_name;
    ELSE
      CLOSE c_org_parent;
    END IF;
    --
    RETURN l_org_name;
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    fnd_log.STRING(fnd_log.level_exception,l_module,'Unhandled exception, in when others, sqlerrm='||SQLERRM);
    RETURN NULL;
END parent_child_org;
  --
  -- function return concatenated string containing complete org structure bottom-up for
  -- the specified user_id OR salesrep_id
  -- parameter p_level identifies if org name is returned for user/person level only(CURRENT) or all level bottom up are returned (ALL)
FUNCTION get_hash_key(p_salesrep_id   NUMBER
                     ,p_buyer_id      NUMBER
                     ,p_user_id       NUMBER
                     ,p_level         VARCHAR2
                     ,p_creation_date DATE DEFAULT SYSDATE
                     ) RETURN VARCHAR2 IS
  --
  CURSOR c_created (x_user_id NUMBER
                   ,x_creation_date DATE
                   ) IS
    SELECT haou.NAME org_name
          ,paa.organization_id
    FROM fnd_user fu
        ,per_all_assignments_f  paa
        ,hr_all_organization_units     haou
    WHERE fu.user_id = x_user_id
      AND fu.employee_id = paa.person_id
      AND haou.organization_id = paa.organization_id
      AND NVL(x_creation_date,SYSDATE) BETWEEN paa.effective_start_date AND NVL(paa.effective_end_date,sysdate+1);
  --
  CURSOR c_salesrep (x_salesrep_id NUMBER
                    ,x_creation_date DATE
                    ) IS
    SELECT haou.NAME org_name
          ,paa.organization_id
    FROM jtf_rs_salesreps jrs
        ,per_all_assignments_f  paa
        ,hr_all_organization_units     haou
    WHERE jrs.salesrep_id = x_salesrep_id
      AND jrs.person_id = paa.person_id
      AND haou.organization_id = paa.organization_id
      AND x_creation_date BETWEEN paa.effective_start_date AND NVL(paa.effective_end_date,sysdate+1);
  --
  CURSOR c_buyer(x_buyer_id NUMBER
                ,x_creation_date DATE
                ) IS
    SELECT haou.NAME org_name
          ,paa.organization_id
    FROM per_all_assignments_f  paa
        ,hr_all_organization_units     haou
    WHERE paa.person_id = x_buyer_id
      AND haou.organization_id = paa.organization_id
      AND x_creation_date BETWEEN paa.effective_start_date AND NVL(paa.effective_end_date,sysdate+1);
  --
  r_created c_created%ROWTYPE;
  r_salesrep c_salesrep%ROWTYPE;
  r_buyer c_buyer%ROWTYPE;
  l_hash_key VARCHAR2(4000);
  l_module VARCHAR2(2000) := g_module||'.get_hash_key';
  --
BEGIN
  l_hash_key := NULL;
  --
  IF p_salesrep_id IS NOT NULL THEN
    --
    -- for salesrep we derive the org assignment at time of entity (sales agreement) creation date.
    -- in this way we make sure that we get the org structure at creation time meaning the org for which the
    -- sales agreement was created. If the salesrep changes org then this does not influence the org for which the
    -- agreement is visible.
    OPEN c_salesrep(p_salesrep_id,p_creation_date);
    FETCH c_salesrep INTO r_salesrep;
    IF c_salesrep%NOTFOUND THEN
      CLOSE c_salesrep;
      RETURN NULL;
    END IF;
    CLOSE c_salesrep;
    --
    l_hash_key := r_salesrep.org_name;
    --
    IF p_level = 'ALL' THEN
      l_hash_key := parent_child_org(r_salesrep.organization_id,'PARENT')||'#'||l_hash_key;
    END IF;
    --
    l_hash_key := l_hash_key||'#';
    --
    fnd_log.STRING(fnd_log.level_statement,l_module,'Org assignment = '||r_salesrep.org_name);
    fnd_log.STRING(fnd_log.level_statement,l_module,'Hash Key = '||l_hash_key);
    --
  ELSIF p_buyer_id IS NOT NULL THEN
    --
    -- for buyer we derive the org assignment at time of entity (blanket agreement) creation date.
    -- in this way we make sure that we get the org structure at creation time meaning the org for which the
    -- blanket was created. If the buyer changes org then this does not influence the org for which the
    -- agreement is visible.
    OPEN c_buyer(p_buyer_id,p_creation_date);
    FETCH c_buyer INTO r_buyer;
    IF c_buyer%NOTFOUND THEN
      CLOSE c_buyer;
      RETURN NULL;
    END IF;
    CLOSE c_buyer;
    --
    l_hash_key := r_buyer.org_name;
    --
    IF p_level = 'ALL' THEN
      l_hash_key := parent_child_org(r_buyer.organization_id,'PARENT')||'#'||l_hash_key;
    END IF;
    --
    l_hash_key := l_hash_key||'#';
    --
    fnd_log.STRING(fnd_log.level_statement,l_module,'Org assignment = '||r_buyer.org_name);
    fnd_log.STRING(fnd_log.level_statement,l_module,'Hash Key = '||l_hash_key);
    --
  ELSIF p_user_id IS NOT NULL THEN
    --
    OPEN c_created(p_user_id, p_creation_date);
    FETCH c_created INTO r_created;
    IF c_created%NOTFOUND THEN
      CLOSE c_created;
      RETURN(NULL);
    END IF;
    CLOSE c_created;
    --
    l_hash_key := '#'||r_created.org_name;
    --
    IF p_level = 'ALL' THEN
      l_hash_key := parent_child_org(r_created.organization_id,'PARENT')||'#'||l_hash_key;
    END IF;
    --
    l_hash_key := l_hash_key||'#';
    --
    fnd_log.STRING(fnd_log.level_statement,l_module,'Org assignment = '||r_created.org_name);
    fnd_log.STRING(fnd_log.level_statement,l_module,'Hash Key = '||l_hash_key);
  END IF;
  --
  RETURN l_hash_key;
EXCEPTION
  WHEN OTHERS THEN
    fnd_log.STRING(fnd_log.level_exception,l_module,'Unhandled exception, in when others, sqlerrm='||SQLERRM);
    RETURN NULL;
END get_hash_key;
--
--This functions checks if the user is in the approval list of the sales agreement.
FUNCTION is_approver(p_user_id        NUMBER
                    ,p_application_id NUMBER
                    ,p_trx_id         NUMBER
                    ) RETURN VARCHAR2 IS
  --
  l_module    VARCHAR2(2000) := g_module||'is_approver';
BEGIN
  --
  RETURN is_approver(p_user_id,p_application_id,to_char(p_trx_id));
EXCEPTION
  WHEN OTHERS THEN
    fnd_log.STRING(fnd_log.level_exception,l_module,'Unhandled EXCEPTION, IN WHEN others, SQLERRM='||SQLERRM);
    RETURN 'Y';
  --
END is_approver;
--
FUNCTION is_approver(p_user_id        NUMBER
                    ,p_application_id NUMBER
                    ,p_trx_id         ame_trans_approval_history.transaction_id%TYPE
                    ) RETURN VARCHAR2 IS
  --
  CURSOR c_approver(x_user_id NUMBER
                   ,x_application_id NUMBER
                   ,x_trx_id VARCHAR2
                   ) IS
    SELECT 'Y'
    FROM ame_trans_approval_history atah
        ,fnd_user                   fu
        ,per_people_x               P
    WHERE 1=1
      AND atah.transaction_id LIKE x_trx_id
      AND atah.application_id = x_application_id
      AND atah.NAME = fu.user_name
      AND fu.employee_id = P.PERSON_ID
      AND fu.user_id = x_user_id;
  --
  l_approver_flag VARCHAR2(1);
  l_module    VARCHAR2(2000) := g_module||'is_approver';
BEGIN
  --
  OPEN c_approver(p_user_id,p_application_id,p_trx_id);
  FETCH c_approver INTO l_approver_flag;
  IF c_approver%NOTFOUND THEN
    l_approver_flag := 'N';
  END IF;
  CLOSE c_approver;
  --
  RETURN l_approver_flag;
  --
EXCEPTION
  WHEN OTHERS THEN
    fnd_log.STRING(fnd_log.level_exception,l_module,'Unhandled EXCEPTION, IN WHEN others, SQLERRM='||SQLERRM);
    RETURN 'Y';
  --
END is_approver;
--
FUNCTION access_allowed(p_entity        VARCHAR2
--                       ,p_salesrep_id   NUMBER
--                       ,p_buyer_id      NUMBER
                       ,p_reference_id  NUMBER
                       ,p_user_id       NUMBER
                       ,p_header_id     NUMBER
                       ,p_creation_date DATE DEFAULT SYSDATE
                       ,p_doc_type      VARCHAR2
                       ) RETURN VARCHAR2 IS
  CURSOR c_app(b_name ame_calling_apps.application_name%TYPE) IS
  SELECT application_id
  FROM ame_calling_apps
  WHERE application_name = b_name
  ;
  l_module      VARCHAR2(2000) := g_module||'access_allowed';
  l_ref_hash    VARCHAR2(2000);
  l_user_hash   VARCHAR2(2000);
  l_apprv_appl_id NUMBER;
  l_access_flag VARCHAR2(1);
  v_header_id VARCHAR2(40);
BEGIN
  --
  -- put some log messages
  fnd_log.STRING(fnd_log.level_statement,l_module,'Reference id ='||p_reference_id);
  fnd_log.STRING(fnd_log.level_statement,l_module,'logged on user id ='||fnd_global.user_id);
  --
  IF p_entity = 'OKC_REP_CONTRACTS' THEN
    --
    -- field ref_id is filled in with the owner_id, which is a user_id
    l_ref_hash := xxah_vpd_pkg.get_hash_key(NULL,NULL,p_reference_id,'ALL',p_creation_date);
    l_user_hash := xxah_vpd_pkg.get_hash_key(NULL,NULL,fnd_global.user_id,'CURRENT',sysdate);
    --
  ELSIF p_entity = 'PO_HEADERS'  THEN
    -- if not BLANKET the no security required
    IF NVL(p_doc_type,'x') != 'BLANKET' THEN
      RETURN 'Y';
    END IF;
    --
    -- in case of po_headers reference_id is the buyer_id
    l_ref_hash := xxah_vpd_pkg.get_hash_key(NULL,p_reference_id,NULL,'ALL',p_creation_date);
    l_user_hash := xxah_vpd_pkg.get_hash_key(NULL,NULL,fnd_global.user_id,'CURRENT',sysdate);
  --
  ELSIF p_entity = 'OE_BLANKET_HEADERS' THEN
    --
    -- in case of blanket headers the ref_id is the salesrep_id
    l_ref_hash := xxah_vpd_pkg.get_hash_key(p_reference_id,NULL,NULL,'ALL',p_creation_date);
    l_user_hash := xxah_vpd_pkg.get_hash_key(NULL,NULL,fnd_global.user_id,'CURRENT',sysdate);
    --
  ELSIF p_entity = 'PON_AUCTION_HEADERS' THEN
    --
    -- in case of auction headers the ref_id is the created_by
    l_ref_hash := xxah_vpd_pkg.get_hash_key(NULL,NULL,p_reference_id,'ALL',p_creation_date);
    l_user_hash := xxah_vpd_pkg.get_hash_key(NULL,NULL,fnd_global.user_id,'CURRENT',sysdate);
    --
  END IF;
  --
  fnd_log.STRING(fnd_log.level_statement,l_module,'Ref hash='||l_ref_hash);
  fnd_log.STRING(fnd_log.level_statement,l_module,'User hash='||l_user_hash);
  --
  IF l_ref_hash LIKE '%'||l_user_hash||'%' THEN
    RETURN 'Y';
  ELSE
    --
    -- check if user is in approvers list.
    IF p_entity = 'OE_BLANKET_HEADERS' THEN
      OPEN c_app('Vendor Allowance Agreement');
      FETCH c_app INTO l_apprv_appl_id;
      CLOSE c_app;
      v_header_id := to_char(p_header_id);
    ELSIF p_entity = 'PO_HEADERS' THEN
      OPEN c_app('XXAH Blanket Purchase Agreement');
      FETCH c_app INTO l_apprv_appl_id;
      CLOSE c_app;
      v_header_id := to_char(p_header_id)||'%';
    ELSE
      RETURN 'N';
    END IF;
    --
    -- if not found in org hierarchy, then check if user is in approver list
    l_access_flag := is_approver(fnd_global.user_id, l_apprv_appl_id ,v_header_id);
    --
    RETURN l_access_flag;
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    fnd_log.STRING(fnd_log.level_exception,l_module,'Unhandled EXCEPTION, IN WHEN others, SQLERRM='||SQLERRM);
    RETURN 'Y';
  --
END access_allowed;
--
FUNCTION xxbi_access_allowed(p_hash_key      VARCHAR2
                            ,p_user_id       NUMBER
                            ) RETURN VARCHAR2 IS
  l_module      VARCHAR2(2000) := g_module||'xxbi_access_allowed';
  l_user_hash   VARCHAR2(2000);
  l_access_flag VARCHAR2(1);
BEGIN
  --
  fnd_log.STRING(fnd_log.level_statement,l_module,'hash_key='||p_hash_key);
  --
  l_user_hash := xxah_vpd_pkg.get_hash_key(NULL,fnd_global.user_id,'CURRENT',sysdate);
  --
  fnd_log.STRING(fnd_log.level_statement,l_module,'User hash='||l_user_hash);
  --
  IF p_hash_key LIKE '%'||l_user_hash||'%' THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    fnd_log.STRING(fnd_log.level_exception,l_module,'Unhandled EXCEPTION, IN WHEN others, SQLERRM='||SQLERRM);
    RETURN 'Y';
  --
END xxbi_access_allowed;
--
FUNCTION policy_oe_blanket_headers (obj_schema IN VARCHAR2
                              	    ,obj_name   IN VARCHAR2  ) RETURN VARCHAR2 IS
  v_predicate VARCHAR2(4000);
  v_org_id NUMBER;
  v_security_profile_id NUMBER;
  l_module VARCHAR2(2000) := g_module||'.policy_oe_blanket_headers';
  --
BEGIN
    --
  IF fnd_profile.value('XXAH_ENABLE_VPD') = 'Y' THEN
    --
    fnd_log.STRING(fnd_log.level_statement,l_module,'VPD Enabled for user_id = '||fnd_global.user_id);
    --
    v_predicate := ' xxah_vpd_pkg.access_allowed(''OE_BLANKET_HEADERS'',oe_blanket_headers.salesrep_id,fnd_global.user_id,oe_blanket_headers.header_id,oe_blanket_headers.creation_date,null) = ''Y''';
    --
    fnd_log.STRING(fnd_log.level_statement,l_module,'Predicate = '||v_predicate);
  ELSE
    fnd_log.STRING(fnd_log.level_statement,l_module,'VPD Disabled');
    v_predicate :=  '';
  END IF;
  --
  RETURN v_predicate;
EXCEPTION
  WHEN OTHERS THEN
    fnd_log.STRING(fnd_log.level_exception,l_module,'Unhandled exception, in when others, sqlerrm='||SQLERRM);
    v_predicate := '';
    RETURN v_predicate;
END policy_oe_blanket_headers;
--
-- Policy function used on PO_HEADERS_ALL
FUNCTION policy_po_headers (obj_schema IN VARCHAR2
                           ,obj_name   IN VARCHAR2  ) RETURN VARCHAR2 IS
  v_predicate VARCHAR2(4000);
  v_org_id NUMBER;
  v_security_profile_id NUMBER;
  l_module VARCHAR2(2000) := g_module||'.policy_po_headers';
  --
BEGIN
  --
  IF fnd_profile.value('XXAH_ENABLE_VPD') = 'Y' THEN
    --
    fnd_log.STRING(fnd_log.level_statement,l_module,'VPD Enabled for user_id = '||fnd_global.user_id);
    --
    v_predicate := ' xxah_vpd_pkg.access_allowed(''PO_HEADERS'',agent_id,fnd_global.user_id,po_header_id,creation_date,type_lookup_code) = ''Y''';
    --
    fnd_log.STRING(fnd_log.level_statement,l_module,'Predicate = '||v_predicate);
  ELSE
    fnd_log.STRING(fnd_log.level_statement,l_module,'VPD Disabled');
    v_predicate :=  '';
  END IF;
  --
  RETURN v_predicate;
EXCEPTION
  WHEN OTHERS THEN
    fnd_log.STRING(fnd_log.level_exception,l_module,'Unhandled exception, in when others, sqlerrm='||SQLERRM);
    v_predicate := '';
    RETURN v_predicate;
END policy_po_headers;
--
FUNCTION policy_okc_rep_contracts (obj_schema IN VARCHAR2
                                  ,obj_name   IN VARCHAR2  ) RETURN VARCHAR2 IS
  v_predicate VARCHAR2(4000);
  v_org_id NUMBER;
  v_security_profile_id NUMBER;
  l_module VARCHAR2(2000) := g_module||'.policy_okc_rep_contracts';
  --
BEGIN
    --
  IF fnd_profile.value('XXAH_ENABLE_VPD') = 'Y' THEN
    --
    fnd_log.STRING(fnd_log.level_statement,l_module,'VPD Enabled for user_id = '||fnd_global.user_id);
    --
    v_predicate := ' xxah_vpd_pkg.access_allowed(''OKC_REP_CONTRACTS'',owner_id,fnd_global.user_id,contract_id,creation_date,null) = ''Y''';
    --
    fnd_log.STRING(fnd_log.level_statement,l_module,'Predicate = '||v_predicate);
  ELSE
    fnd_log.STRING(fnd_log.level_statement,l_module,'VPD Disabled');
    v_predicate :=  '';
  END IF;
  --
  RETURN v_predicate;
EXCEPTION
  WHEN OTHERS THEN
    fnd_log.STRING(fnd_log.level_exception,l_module,'Unhandled exception, in when others, sqlerrm='||SQLERRM);
    v_predicate := '';
    RETURN v_predicate;
END policy_okc_rep_contracts;
--
FUNCTION policy_pon_auction_headers (obj_schema IN VARCHAR2
                                    ,obj_name   IN VARCHAR2  ) RETURN VARCHAR2 IS
  v_predicate VARCHAR2(4000);
  v_org_id NUMBER;
  v_security_profile_id NUMBER;
  l_module VARCHAR2(2000) := g_module||'.policy_pon_auction_headers';
  --
BEGIN
    --
  IF fnd_profile.value('XXAH_ENABLE_VPD') = 'Y' THEN
    --
    fnd_log.STRING(fnd_log.level_statement,l_module,'VPD Enabled for user_id = '||fnd_global.user_id);
    --
    v_predicate := ' xxah_vpd_pkg.access_allowed(''PON_AUCTION_HEADERS'',created_by,fnd_global.user_id,auction_header_id,creation_date,null) = ''Y''';
    --
    fnd_log.STRING(fnd_log.level_statement,l_module,'Predicate = '||v_predicate);
  ELSE
    fnd_log.STRING(fnd_log.level_statement,l_module,'VPD Disabled');
    v_predicate :=  '';
  END IF;
  --
  RETURN v_predicate;
EXCEPTION
  WHEN OTHERS THEN
    fnd_log.STRING(fnd_log.level_exception,l_module,'Unhandled exception, in when others, sqlerrm='||SQLERRM);
    v_predicate := '';
    RETURN v_predicate;
END policy_pon_auction_headers;
--
FUNCTION policy_xxbi_va_bh_bl_oh_ol (obj_schema IN VARCHAR2
                                    ,obj_name   IN VARCHAR2  ) RETURN VARCHAR2 IS
  v_predicate VARCHAR2(4000);
  v_org_id NUMBER;
  v_security_profile_id NUMBER;
  l_module VARCHAR2(2000) := g_module||'.policy_xxbbi_va_bh_bl_oh_ol';
  --
BEGIN
    --
  IF fnd_profile.value('XXAH_ENABLE_VPD') = 'Y' THEN
    --
    fnd_log.STRING(fnd_log.level_statement,l_module,'VPD Enabled for user_id = '||fnd_global.user_id);
    --
    v_predicate := ' xxah_vpd_pkg.xxbi_access_allowed(xxbi_va_bh_bl_oh_ol.hash_key,fnd_global.user_id) = ''Y''';
    --
    fnd_log.STRING(fnd_log.level_statement,l_module,'Predicate = '||v_predicate);
  ELSE
    fnd_log.STRING(fnd_log.level_statement,l_module,'VPD Disabled');
    v_predicate :=  '';
  END IF;
  --
  RETURN v_predicate;
EXCEPTION
  WHEN OTHERS THEN
    fnd_log.STRING(fnd_log.level_exception,l_module,'Unhandled exception, in when others, sqlerrm='||SQLERRM);
    v_predicate := '';
    RETURN v_predicate;
END policy_xxbi_va_bh_bl_oh_ol;
--
END xxah_Vpd_Pkg;

/

  GRANT EXECUTE ON "APPS"."XXAH_VPD_PKG" TO "EBSBI";
