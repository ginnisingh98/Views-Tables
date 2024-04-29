--------------------------------------------------------
--  DDL for Package Body CSM_PARTY_DATA_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_PARTY_DATA_EVENT_PKG" AS
/* $Header: csmepdab.pls 120.13 2008/06/12 12:51:22 trajasek noship $ */

g_table_name0            CONSTANT VARCHAR2(30) := 'HZ_PARTIES';
g_acc_table_name0        CONSTANT VARCHAR2(30) := 'CSM_PARTIES_ACC';
g_acc_sequence_name0     CONSTANT VARCHAR2(30) := 'CSM_PARTIES_ACC_S';
g_publication_item_name0 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSF_M_PARTIES');
g_pk1_name0              CONSTANT VARCHAR2(30) := 'PARTY_ID';

g_acc_table_name1        CONSTANT VARCHAR2(30) := 'CSM_PARTY_SITES_ACC';
g_acc_sequence_name1     CONSTANT VARCHAR2(30) := 'CSM_PARTY_SITES_ACC_S';
g_pk1_name1              CONSTANT VARCHAR2(30) := 'PARTY_SITE_ID';
g_pk2_name1              CONSTANT VARCHAR2(30) := 'PARTY_ID';
g_publication_item_name1 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSF_M_PARTY_SITES');

g_acc_table_name2        CONSTANT VARCHAR2(30) := 'CSM_HZ_LOCATIONS_ACC';
g_acc_sequence_name2     CONSTANT VARCHAR2(30) := 'CSM_HZ_LOCATIONS_ACC_S';
g_pk1_name2              CONSTANT VARCHAR2(30) := 'LOCATION_ID';
g_publication_item_name2 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSM_HZ_LOCATIONS');

g_acc_table_name3        CONSTANT VARCHAR2(30) := 'CSM_ITEM_INSTANCES_ACC';
g_acc_sequence_name3     CONSTANT VARCHAR2(30) := 'CSM_ITEM_INSTANCES_ACC_S';
g_pk1_name3              CONSTANT VARCHAR2(30) := 'INSTANCE_ID';
g_publication_item_name3 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSF_M_ITEM_INSTANCES');

g_acc_table_name4        CONSTANT VARCHAR2(30) := 'CSM_HZ_CONTACT_POINTS_ACC';
g_acc_sequence_name4     CONSTANT VARCHAR2(30) := 'CSM_HZ_CONTACT_POINTS_ACC_S';
g_pk1_name4              CONSTANT VARCHAR2(30) :=  'CONTACT_POINT_ID';
g_publication_item_name4 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSM_HZ_CONTACT_POINTS');

/*g_acc_table_name5        CONSTANT VARCHAR2(30) := 'CSM_PARTIES_ACC';
g_acc_sequence_name5     CONSTANT VARCHAR2(30) := 'CSM_PARTIES_ACC_S';
g_pk1_name5              CONSTANT VARCHAR2(30) := 'PARTY_ID';
g_publication_item_name5 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSF_M_PARTIES');*/

g_acc_table_name6        CONSTANT VARCHAR2(30) := 'CSM_HZ_CUST_ACCOUNTS_ACC';
g_acc_sequence_name6     CONSTANT VARCHAR2(30) := 'CSM_HZ_CUST_ACCOUNTS_ACC_S';
g_pk1_name6              CONSTANT VARCHAR2(30) := 'CUST_ACCOUNT_ID';
g_publication_item_name6 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSM_HZ_CUST_ACCOUNTS');

g_acc_table_name7        CONSTANT VARCHAR2(30) := 'CSM_COUNTERS_ACC';
g_acc_sequence_name7     CONSTANT VARCHAR2(30) := 'CSM_COUNTERS_ACC_S';
g_pk1_name7              CONSTANT VARCHAR2(30) := 'COUNTER_ID';
g_publication_item_name7 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSF_M_COUNTERS');

g_acc_table_name8        CONSTANT VARCHAR2(30) := 'CSM_COUNTER_VALUES_ACC';
g_acc_sequence_name8     CONSTANT VARCHAR2(30) := 'CSM_COUNTER_VALUES_ACC_S';
g_pk1_name8              CONSTANT VARCHAR2(30) := 'COUNTER_VALUE_ID';
g_pk2_name8              CONSTANT VARCHAR2(30) := 'COUNTER_ID';
g_publication_item_name8 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSF_M_COUNTER_VALUES');


g_acc_table_name9        CONSTANT VARCHAR2(30) := 'CSM_COUNTER_PROP_VALUES_ACC';
g_acc_sequence_name9     CONSTANT VARCHAR2(30) := 'CSM_COUNTER_PROP_VALUES_ACC_S';
g_pk1_name9              CONSTANT VARCHAR2(30) := 'COUNTER_PROP_VALUE_ID';
g_publication_item_name9 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
  			     CSM_ACC_PKG.t_publication_item_list('CSM_COUNTER_PROP_VALUES');

g_acc_table_name10        CONSTANT VARCHAR2(30) := 'CSM_COUNTER_PROPERTIES_ACC';
g_acc_sequence_name10     CONSTANT VARCHAR2(30) := 'CSM_COUNTER_PROPERTIES_ACC_S';
g_pk1_name10              CONSTANT VARCHAR2(30) := 'COUNTER_PROPERTY_ID';
g_publication_item_name10 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
  			      CSM_ACC_PKG.t_publication_item_list('CSM_COUNTER_PROPERTIES');

g_acc_table_name11        CONSTANT VARCHAR2(30) := 'CSM_HZ_RELATIONSHIPS_ACC';
g_acc_sequence_name11     CONSTANT VARCHAR2(30) := 'CSM_HZ_RELATIONSHIPS_ACC_S';
g_pk1_name11              CONSTANT VARCHAR2(30) := 'RELATIONSHIP_ID';
g_pk2_name11              CONSTANT VARCHAR2(30) := 'DIRECTIONAL_FLAG';
g_publication_item_name11 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
  			      CSM_ACC_PKG.t_publication_item_list('CSM_HZ_RELATIONSHIPS');

PROCEDURE REFRESH_ACC ( x_return_status OUT NOCOPY VARCHAR2,
                        x_error_message OUT NOCOPY VARCHAR2
                      )
IS

--variable declarations

TYPE l_party_id_tbl_type         IS TABLE OF csm_parties_acc.party_id%TYPE INDEX BY BINARY_INTEGER;
TYPE l_user_id_tbl_type          IS TABLE OF csm_parties_acc.user_id%TYPE INDEX BY BINARY_INTEGER;
TYPE l_party_site_id_tbl_type    IS TABLE OF csm_party_sites_acc.party_site_id%TYPE INDEX BY BINARY_INTEGER;
TYPE l_location_id_tbl_type      IS TABLE OF csm_hz_locations_acc.location_id%TYPE INDEX BY BINARY_INTEGER;
TYPE l_instance_id_tbl_type      IS TABLE OF csm_item_instances_acc.instance_id%TYPE INDEX BY BINARY_INTEGER;
TYPE l_contacts_id_tbl_type      IS TABLE OF csm_sr_contacts_acc.sr_contact_point_id%TYPE INDEX BY BINARY_INTEGER;
TYPE l_cust_acct_id_tbl_type     IS TABLE OF csm_hz_cust_accounts_acc.cust_account_id%TYPE INDEX BY BINARY_INTEGER;
TYPE l_counter_id_tbl_type       IS TABLE OF csm_counters_acc.counter_id%TYPE INDEX BY BINARY_INTEGER;
TYPE l_counter_value_id_tbl_type IS TABLE OF csm_counter_values_acc.counter_value_id%TYPE INDEX BY BINARY_INTEGER;
TYPE l_counter_prop_val_tbl_type IS TABLE OF csm_counter_prop_values_acc.counter_prop_value_id%TYPE INDEX BY BINARY_INTEGER;
TYPE l_counter_prp_id_tbl_type   IS TABLE OF csm_counter_properties_acc.counter_property_id%TYPE INDEX BY BINARY_INTEGER;
TYPE l_relationship_id_tbl_type  IS TABLE OF HZ_RELATIONSHIPS.RELATIONSHIP_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE l_direct_flag_tbl_type      IS TABLE OF HZ_RELATIONSHIPS.DIRECTIONAL_FLAG%TYPE INDEX BY BINARY_INTEGER;
TYPE ver_lab_Tab                 IS TABLE OF csi_i_version_labels.version_label%TYPE INDEX BY BINARY_INTEGER;

l_party_id_tbl                   l_party_id_tbl_type;
l_user_id_tbl                    l_user_id_tbl_type;
l_party_site_id_tbl              l_party_site_id_tbl_type;
l_location_id_tbl                l_location_id_tbl_type;
l_instance_id_tbl                l_instance_id_tbl_type;
l_contacts_id_tbl                l_contacts_id_tbl_type;
l_cust_acct_id_tbl               l_cust_acct_id_tbl_type;
l_counter_id_tbl                 l_counter_id_tbl_type;
l_counter_value_id_tbl           l_counter_value_id_tbl_type;
l_counter_prop_val_tbl           l_counter_prop_val_tbl_type;
l_counter_prp_id_tbl             l_counter_prp_id_tbl_type;
l_relationship_id_tbl            l_relationship_id_tbl_type;
l_direct_flag_tbl                l_direct_flag_tbl_type;
l_inv_item_id_tbl                ASG_DOWNLOAD.USER_LIST;
l_last_vld_org_id_tbl            ASG_DOWNLOAD.USER_LIST;
l_subject_id_tbl                 l_party_id_tbl_type;
l_ver_label_lst                  ver_lab_Tab;
l_parent_inst_id_lst             l_instance_id_tbl_type;

l_sqlerrno                       VARCHAR2(20);
l_sqlerrmsg                      VARCHAR2(2000);
p_message                        VARCHAR2(3000);
l_return_status                  VARCHAR2(3000);
l_error_message                  VARCHAR2(3000);
l_counter_profile_value          VARCHAR2(1) := NULL;
l_contract_profile_value         VARCHAR2(1) := NULL;
l_error_msg                      VARCHAR2(4000);



/*
This cursor fetches party_id for the parties mapped to group_owner_id
*/

CURSOR l_party_ins_csr
IS
SELECT tcpa.user_id
     , tcpa.party_id
FROM   csm_party_assignment tcpa
WHERE  tcpa.party_site_id IN (-1,-2)
AND    tcpa.deleted_flag  = 'N'
AND    NOT EXISTS ( SELECT 1
                    FROM  csm_parties_acc cpa
                    WHERE cpa.party_id  = tcpa.party_id
                    AND   cpa.user_id   = tcpa.user_id
                  );

/*
This cursor fetches party_site_id and location_id for the parties mapped to group_owner_id
*/

CURSOR l_party_sites_ins_csr
IS
SELECT tcpa.user_id
     , tcpa.party_id
     , hps.party_site_id
     , hps.location_id
FROM   csm_party_assignment tcpa
     , hz_party_sites hps
WHERE  tcpa.party_id       = hps.party_id
AND    tcpa.deleted_flag   = 'N'
AND    (tcpa.party_site_id = -1
OR     tcpa.party_site_id  = hps.party_site_id)
AND  NOT EXISTS ( SELECT 1
                  FROM csm_party_sites_acc cpsa
                  WHERE cpsa.party_site_id = hps.party_site_id
                  AND   cpsa.user_id       = tcpa.user_id
                )
AND  NOT EXISTS ( SELECT 1
                  FROM csm_hz_locations_acc chla
                  WHERE chla.location_id = hps.location_id
                  AND   chla.user_id     = tcpa.user_id
                );

/*
This cursor fetches instance_id for the parties mapped to group_owner_id
*/

CURSOR l_instance_ins_csr
IS
SELECT cii.instance_id
     , tcpa.user_id
     , cii.inventory_item_id
     , cii.last_vld_organization_id
     , civ.version_label
     , CIR.OBJECT_ID
FROM   csi_item_instances cii
     , csm_party_sites_acc cpsa
     , csm_party_assignment tcpa
     , csi_i_version_labels civ
     , CSI_II_RELATIONSHIPS CIR
WHERE  cii.location_id        = cpsa.party_site_id
AND    cpsa.party_id          = tcpa.party_id
AND    cpsa.user_id           = tcpa.user_id
AND    cii.location_type_code = 'HZ_PARTY_SITES'
AND    (tcpa.party_site_id    = -1
OR     tcpa.party_site_id     = cpsa.party_site_id)
AND    tcpa.deleted_flag      = 'N'
AND    cii.instance_id = civ.instance_id(+)
AND    (TRUNC(SYSDATE) BETWEEN TRUNC(NVL(civ.active_start_date,SYSDATE))
AND    TRUNC(NVL(civ.active_end_date,SYSDATE)))
AND    CII.INSTANCE_ID = CIR.SUBJECT_ID(+)
AND    CIR.RELATIONSHIP_TYPE_CODE(+) = 'COMPONENT-OF'
AND    NOT EXISTS ( SELECT 1
                    FROM  csm_item_instances_acc ciia
                    WHERE ciia.instance_id = cii.instance_id
                    AND   ciia.user_id     = tcpa.user_id
                  )
UNION
SELECT cii.instance_id
     , cpa.user_id
     , cii.inventory_item_id
     , cii.last_vld_organization_id
     , civ.version_label
     , CIR.OBJECT_ID
FROM   csi_item_instances cii
     , csm_party_assignment cpa
     , hz_locations hz
     , csi_i_version_labels civ
     , CSI_II_RELATIONSHIPS CIR
WHERE  cii.owner_party_id     = cpa.party_id
AND    cii.location_id        = hz.location_id
AND    cii.location_type_code = 'HZ_LOCATIONS'
AND    cpa.party_site_id      IN (-1,-2)
AND    cpa.deleted_flag       = 'N'
AND    cii.instance_id = civ.instance_id(+)
AND    (TRUNC(SYSDATE) BETWEEN TRUNC(NVL(civ.active_start_date,SYSDATE))
AND    TRUNC(NVL(civ.active_end_date,SYSDATE)))
AND    CII.INSTANCE_ID = CIR.SUBJECT_ID(+)
AND    CIR.RELATIONSHIP_TYPE_CODE(+) = 'COMPONENT-OF'
AND    NOT EXISTS ( SELECT 1
                    FROM   csm_item_instances_acc ciia
                    WHERE  ciia.user_id = cpa.user_id
                  );

/*
This cursor fetches counter_id for the instances downloaded
*/

CURSOR l_counter_ins_csr
IS
SELECT ccb.counter_id
     , ciia.user_id
FROM   csi_counters_b ccb
     , csi_counter_associations cca
     , csm_item_instances_acc ciia
WHERE  ccb.counter_id         = cca.counter_id
AND    cca.source_object_id   = ciia.instance_id
AND    ccb.counter_type       = 'REGULAR'
AND    cca.source_object_code = 'CP'
AND    ciia.user_id IN (SELECT cpa.user_id
                        FROM   csm_party_assignment cpa
                        WHERE  cpa.deleted_flag = 'N'
                       )
AND    NOT EXISTS      (SELECT 1
                        FROM   csm_counters_acc ccsa
                        WHERE  ccsa.user_id     = ciia.user_id
                        AND    ccsa.counter_id  = ccb.counter_id
                       );

/*
This cursor fetches counter_value_id for the instances downloaded
*/

CURSOR l_counter_value_ins_csr
IS
SELECT ccr.counter_value_id
     , ccr.counter_id
     , cca.user_id
FROM   csi_counter_readings ccr
     , csm_counters_acc cca
WHERE  ccr.counter_id = cca.counter_id
AND    cca.user_id IN ( SELECT cpa.user_id
                        FROM   csm_party_assignment cpa
                        WHERE  cpa.deleted_flag ='N'
                      )
AND    NOT EXISTS     ( SELECT 1
                        FROM   csm_counter_values_acc ccva
                        WHERE  ccva.user_id          = cca.user_id
                        AND    ccva.counter_value_id = ccr.counter_value_id
                      );

/*
This cursor fetches counter_prop_value_id for the instances downloaded
*/

CURSOR l_counter_prop_value_ins_csr
IS
SELECT ccpr.counter_prop_value_id
     , ccva.user_id
FROM   csi_ctr_property_readings ccpr
     , csm_counter_values_acc ccva
WHERE  ccpr.counter_value_id = ccva.counter_value_id
AND    ccva.user_id IN ( SELECT cpa.user_id
                         FROM   csm_party_assignment cpa
                         WHERE  cpa.deleted_flag ='N'
                       )
AND     NOT EXISTS     ( SELECT 1
                         FROM   csm_counter_prop_values_acc ccpva
                         WHERE  ccpva.user_id               = ccva.user_id
                         AND    ccpva.counter_prop_value_id = ccpr.counter_prop_value_id
                       );

/*
This cursor fetches counter_property_id for the instances downloaded
*/

CURSOR l_counter_property_ins_csr
IS
SELECT ccpb.counter_property_id
     , cca.user_id
FROM   csi_counter_properties_b ccpb
     , csm_counters_acc cca
WHERE  ccpb.counter_id = cca.counter_id
AND    cca.user_id IN ( SELECT cpa.user_id
                        FROM   csm_party_assignment cpa
                        WHERE  cpa.deleted_flag ='N'
                      )
AND   NOT EXISTS      ( SELECT 1
                        FROM   csm_counter_properties_acc ccpa
                        WHERE  ccpa.user_id             = cca.user_id
                        AND    ccpa.counter_property_id = ccpb.counter_property_id
                      );
/*
This cursor fetches contact_id for the parties mapped to group_owner_id
*/

CURSOR l_contacts_ins_csr
IS
SELECT hcp.contact_point_id
     , hcp.owner_table_id
     , tcpa.user_id
     , hpr.relationship_id
     , hpr.directional_flag
     , hpr.subject_id
FROM   hz_relationships hpr
     , csm_party_assignment tcpa
     , hz_contact_points hcp
WHERE  hpr.object_id                = tcpa.party_id
AND    hpr.party_id                 = hcp.owner_table_id
AND    hpr.relationship_code        IN ('CONTACT_OF','EMPLOYEE_OF')
AND    hcp.primary_flag             = 'Y'
AND    tcpa.deleted_flag            = 'N'
AND    tcpa.party_site_id           IN (-1,-2)
AND    NOT EXISTS ( SELECT 1
                    FROM   csm_hz_relationships_acc chra
                    WHERE  chra.relationship_id  = hpr.relationship_id
                    AND    chra.user_id          = tcpa.user_id
                  );

/*
This cursor fetches customer_account_id for the parties mapped to group_owner_id
*/

CURSOR l_customer_accounts_ins_csr
IS
SELECT hca.cust_account_id
     , tcpa.user_id
FROM   hz_cust_accounts hca
     , csm_party_assignment tcpa
WHERE  hca.party_id        = tcpa.party_id
AND    tcpa.deleted_flag   = 'N'
AND    tcpa.party_site_id  IN (-1,-2)
AND NOT EXISTS ( SELECT 1
                 FROM  csm_hz_cust_accounts_acc chca
                 WHERE chca.cust_account_id = hca.cust_account_id
                 AND   chca.user_id         = tcpa.user_id
               );

/*
This cursor fetches party_id for the parties mapped to group_owner_id
*/

CURSOR l_party_del_csr
IS
SELECT tcpa.user_id
     , tcpa.party_id
FROM   csm_party_assignment tcpa
WHERE  tcpa.party_site_id IN (-1,-2)
AND    tcpa.deleted_flag  = 'Y'
AND    EXISTS ( SELECT 1
                FROM  csm_parties_acc cpa
                WHERE cpa.party_id  = tcpa.party_id
                AND   cpa.user_id   = tcpa.user_id
              );

/*
This cursor fetches party_site_id and location_id for the parties mapped to group_owner_id
*/

CURSOR l_party_sites_del_csr
IS
SELECT tcpa.user_id
     , tcpa.party_id
     , hps.party_site_id
     , hps.location_id
FROM   csm_party_assignment tcpa,
       hz_party_sites hps
WHERE  tcpa.party_id       = hps.party_id
AND    tcpa.deleted_flag   = 'Y'
AND    (tcpa.party_site_id = -1
OR     tcpa.party_site_id  = hps.party_site_id)
AND    EXISTS ( SELECT 1
                FROM  csm_party_sites_acc cpsa
                WHERE cpsa.party_site_id = hps.party_site_id
                AND   cpsa.user_id       = tcpa.user_id
              )
AND    EXISTS ( SELECT 1
                FROM  csm_hz_locations_acc chla
                WHERE chla.location_id = hps.location_id
                AND   chla.user_id     = tcpa.user_id
              );

/*
This cursor fetches instance_id for the parties mapped to group_owner_id
*/

CURSOR l_instance_del_csr
IS
SELECT cii.instance_id
     , tcpa.user_id
     , cii.inventory_item_id
     , cii.LAST_VLD_ORGANIZATION_ID
FROM   csi_item_instances cii
     , csm_party_sites_acc cpsa
     , csm_party_assignment tcpa
WHERE  cii.location_id        = cpsa.party_site_id
AND    cpsa.party_id          = tcpa.party_id
AND    cpsa.user_id           = tcpa.user_id
AND    cii.location_type_code = 'HZ_PARTY_SITES'
AND    (tcpa.party_site_id    = -1
OR     tcpa.party_site_id     = cpsa.party_site_id)
AND    tcpa.deleted_flag      = 'Y'
AND    EXISTS ( SELECT 1
                FROM  csm_item_instances_acc ciia
                WHERE ciia.instance_id = cii.instance_id
                AND   ciia.user_id     = tcpa.user_id
              )
UNION
SELECT cii.instance_id
     , cpa.user_id
     , cii.inventory_item_id
     , cii.last_vld_organization_id
FROM   csi_item_instances cii
     , csm_party_assignment cpa
     , hz_locations hz
WHERE  cii.owner_party_id     = cpa.party_id
AND    cii.location_id        = hz.location_id
AND    cii.location_type_code = 'HZ_LOCATIONS'
AND    cpa.party_site_id      IN (-1,-2)
AND    cpa.deleted_flag       = 'Y'
AND    EXISTS ( SELECT 1
                FROM   csm_item_instances_acc ciia
                WHERE  ciia.user_id = cpa.user_id
               );

/*
This cursor fetches counter_id for the instances downloaded
*/

CURSOR l_counter_del_csr
IS
SELECT ccb.counter_id
     , ccsa.user_id
FROM   csi_counters_b ccb
     , csi_counter_associations cca
     ,csm_counters_acc ccsa
WHERE  ccb.counter_id         = cca.counter_id
AND    ccb.counter_type       = 'REGULAR'
AND    cca.source_object_code = 'CP'
AND    ccsa.counter_id   = ccb.counter_id
AND    NOT EXISTS (SELECT 1
                   FROM   csm_item_instances_acc ciia
                   WHERE  cca.source_object_id   = ciia.instance_id
                   AND    ccsa.user_id           = ciia.user_id
                   );

/*
This cursor fetches counter_value_id for the instances downloaded
*/

CURSOR l_counter_value_del_csr
IS
SELECT ccr.counter_value_id
     , ccr.counter_id
     , ccva.user_id
FROM   csi_counter_readings ccr
      ,csm_counter_values_acc ccva
WHERE  ccva.counter_value_id = ccr.counter_value_id
AND    NOT EXISTS   (   SELECT 1
                        FROM   csm_counters_acc cca
                        WHERE  cca.user_id    = ccva.user_id
                        AND    ccr.counter_id = cca.counter_id
                      );

/*
This cursor fetches counter_prop_value_id for the instances downloaded
*/

CURSOR l_counter_prop_value_del_csr
IS
SELECT ccpr.counter_prop_value_id
     , ccpva.user_id
FROM   csi_ctr_property_readings ccpr
     , csm_counter_prop_values_acc ccpva
WHERE  ccpva.counter_prop_value_id = ccpr.counter_prop_value_id
AND    NOT EXISTS (SELECT 1
                   FROM   csm_counter_values_acc ccva
                   WHERE  ccpr.counter_value_id = ccva.counter_value_id
                   AND    ccva.user_id = ccpva.user_id
                   );

/*
This cursor fetches counter_property_id for the instances downloaded
*/
CURSOR l_counter_property_del_csr
IS
SELECT ccpb.counter_property_id
     , ccpa.user_id
FROM   csi_counter_properties_b ccpb
     , csm_counter_properties_acc ccpa
WHERE ccpa.counter_property_id = ccpb.counter_property_id
AND   NOT EXISTS(SELECT 1
                 FROM   csm_counters_acc cca
                 WHERE  ccpb.counter_id = cca.counter_id
                 AND    cca.user_id = ccpa.user_id
                 );

/*
This cursor fetches contact_id for the parties mapped to group_owner_id
*/

CURSOR l_contacts_del_csr
IS
SELECT hcp.contact_point_id
     , hcp.owner_table_id
     , tcpa.user_id
     , hpr.relationship_id
     , hpr.directional_flag
     , hpr.subject_id
FROM   hz_relationships hpr
     , csm_party_assignment tcpa
     , hz_contact_points hcp
WHERE  hpr.object_id                = tcpa.party_id
AND    hpr.party_id                 = hcp.owner_table_id
AND    hpr.relationship_code        IN ('CONTACT_OF','EMPLOYEE_OF')
AND    hcp.primary_flag             = 'Y'
AND    tcpa.deleted_flag            = 'Y'
AND    tcpa.party_site_id           IN (-1,-2)
AND    EXISTS ( SELECT 1
                FROM   csm_hz_relationships_acc chra
                WHERE  chra.relationship_id  = hpr.relationship_id
                AND    chra.user_id          = tcpa.user_id
              );

/*
This cursor fetches customer_account_id for the parties mapped to group_owner_id
*/

CURSOR l_customer_accounts_del_csr
IS
SELECT hca.cust_account_id
     , tcpa.user_id
FROM   hz_cust_accounts hca
     , csm_party_assignment tcpa
WHERE  hca.party_id       = tcpa.party_id
AND    tcpa.deleted_flag  = 'Y'
AND    tcpa.party_site_id IN (-1,-2)
AND    EXISTS ( SELECT 1
                FROM   csm_hz_cust_accounts_acc chca
                WHERE chca.cust_account_id = hca.cust_account_id
                AND   chca.user_id         = tcpa.user_id
              );

BEGIN


  CSM_UTIL_PKG.LOG('Entering CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC Package ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);

  l_counter_profile_value  := fnd_profile.value_specific('CSM_COUNTER_DWLD_PARTY');

  l_contract_profile_value := fnd_profile.value_specific('CSM_CONTRACT_DWLD_PARTY');

  CSM_UTIL_PKG.LOG('Deleting Customer Accounts-START ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
  OPEN  l_customer_accounts_del_csr;

    LOOP

      IF l_cust_acct_id_tbl.COUNT > 0 THEN

         l_cust_acct_id_tbl.DELETE;

       END IF;

       IF l_user_id_tbl.COUNT > 0 THEN

          l_user_id_tbl.DELETE;

       END IF;

         FETCH l_customer_accounts_del_csr BULK COLLECT INTO l_cust_acct_id_tbl,l_user_id_tbl LIMIT 100;
         EXIT WHEN l_cust_acct_id_tbl.COUNT = 0;

           IF l_cust_acct_id_tbl.COUNT > 0 THEN

             FOR i IN l_cust_acct_id_tbl.FIRST..l_cust_acct_id_tbl.LAST LOOP

             --call the CSM_ACC_PKG to delete the record from csm_hz_cust_accounts_acc table

               CSM_ACC_PKG.Delete_Acc
                 ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name6
                  ,P_ACC_TABLE_NAME         => g_acc_table_name6
                  ,P_PK1_NAME               => g_pk1_name6
                  ,P_PK1_NUM_VALUE          => l_cust_acct_id_tbl(i)
                  ,P_USER_ID                => l_user_id_tbl(i)
                 );

             END LOOP;

           END IF;

      -- commit after every 100 records

      COMMIT;

    END LOOP;

  CLOSE l_customer_accounts_del_csr;
  CSM_UTIL_PKG.LOG('Deleting Customer Accounts-END ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
  CSM_UTIL_PKG.LOG('Deleting Customer HZ Contacts-START ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
  OPEN l_contacts_del_csr;

    LOOP

      IF l_contacts_id_tbl.COUNT > 0 THEN

         l_contacts_id_tbl.DELETE;

      END IF;

      IF l_user_id_tbl.COUNT > 0 THEN

         l_user_id_tbl.DELETE;

      END IF;

      IF l_party_id_tbl.COUNT > 0 THEN

         l_party_id_tbl.DELETE;

      END IF;

      IF l_relationship_id_tbl.COUNT > 0 THEN

         l_relationship_id_tbl.DELETE;

      END IF;

      IF l_direct_flag_tbl.COUNT > 0 THEN
         l_direct_flag_tbl.DELETE;
      END IF;
      IF l_subject_id_tbl.COUNT > 0 THEN
         l_subject_id_tbl.DELETE;
      END IF;

        FETCH l_contacts_del_csr BULK COLLECT INTO l_contacts_id_tbl,l_party_id_tbl,l_user_id_tbl,l_relationship_id_tbl,l_direct_flag_tbl,l_subject_id_tbl LIMIT 100;
        EXIT WHEN l_contacts_id_tbl.COUNT = 0;

          IF l_contacts_id_tbl.COUNT > 0 THEN

            FOR i IN l_contacts_id_tbl.FIRST..l_contacts_id_tbl.LAST LOOP

               --call the CSM_ACC_PKG to delete the record from csm_sr_contacts_acc table

               CSM_ACC_PKG.Delete_Acc
                 ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name4
                  ,P_ACC_TABLE_NAME         => g_acc_table_name4
                  ,P_PK1_NAME               => g_pk1_name4
                  ,P_PK1_NUM_VALUE          => l_contacts_id_tbl(i)
                  ,P_USER_ID                => l_user_id_tbl(i)
                 );

                 --call the CSM_ACC_PKG to delete the record from csm_hz_relationships_acc table

              CSM_ACC_PKG.Delete_Acc
                ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name11
                 ,P_ACC_TABLE_NAME         => g_acc_table_name11
                 ,P_PK1_NAME               => g_pk1_name11
                 ,P_PK1_NUM_VALUE          => l_relationship_id_tbl(i)
                 ,P_PK2_NAME               => g_pk2_name11
                 ,P_PK2_CHAR_VALUE         => l_direct_flag_tbl(i)
                 ,P_USER_ID                => l_user_id_tbl(i)
                );

            END LOOP;

              -- commit after every 100 records

              COMMIT;

            FOR i IN l_party_id_tbl.FIRST..l_party_id_tbl.LAST LOOP

              --call the CSM_ACC_PKG to delete the record from csm_parties_acc table

              CSM_ACC_PKG.Delete_Acc
                ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name0
                 ,P_ACC_TABLE_NAME         => g_acc_table_name0
                 ,P_PK1_NAME               => g_pk1_name0
                 ,P_PK1_NUM_VALUE          => l_party_id_tbl(i)
                 ,P_USER_ID                => l_user_id_tbl(i)
                );

              CSM_ACC_PKG.Delete_Acc
                ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name0
                 ,P_ACC_TABLE_NAME         => g_acc_table_name0
                 ,P_PK1_NAME               => g_pk1_name0
                 ,P_PK1_NUM_VALUE          => l_subject_id_tbl(i)
                 ,P_USER_ID                => l_user_id_tbl(i)
                );

            END LOOP;

          END IF;

        -- commit after every 100 records

      COMMIT;

    END LOOP;

  CLOSE l_contacts_del_csr;
CSM_UTIL_PKG.LOG('Deleting Customer HZ Contacts-END ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
CSM_UTIL_PKG.LOG('Deleting Instances-START ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
OPEN l_instance_del_csr;

    LOOP

      IF l_instance_id_tbl.COUNT > 0 THEN

         l_instance_id_tbl.DELETE;

      END IF;

      IF l_user_id_tbl.COUNT > 0 THEN

         l_user_id_tbl.DELETE;

      END IF;

        IF l_inv_item_id_tbl.COUNT > 0 THEN

         l_inv_item_id_tbl.DELETE;

      END IF;

      IF l_last_vld_org_id_tbl.COUNT > 0 THEN

         l_last_vld_org_id_tbl.DELETE;

      END IF;

        FETCH l_instance_del_csr BULK COLLECT INTO l_instance_id_tbl,l_user_id_tbl, l_inv_item_id_tbl, l_last_vld_org_id_tbl LIMIT 100;  --l_user_ins_tbl LIMIT 100;
        EXIT WHEN l_instance_id_tbl.COUNT = 0;

          IF l_instance_id_tbl.COUNT > 0 THEN

            FOR i IN l_instance_id_tbl.FIRST..l_instance_id_tbl.LAST LOOP

              --call the CSM_ACC_PKG to delete the record from csm_item_instances_acc table

              CSM_ACC_PKG.Delete_Acc
                ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name3
                 ,P_ACC_TABLE_NAME         => g_acc_table_name3
                 ,P_PK1_NAME               => g_pk1_name3
                 ,P_PK1_NUM_VALUE          => l_instance_id_tbl(i)
                 ,P_USER_ID                => l_user_id_tbl(i)
                );

                --Deleting corresponding item from acc
                       csm_mtl_system_items_event_pkg.MTL_SYSTEM_ITEMS_ACC_D(l_inv_item_id_tbl(i),
                                                             l_last_vld_org_id_tbl(i),
                                                             l_user_id_tbl(i),
                                                             l_error_msg,
                                                             l_return_status);

            END LOOP;

          END IF;

        -- commit after every 100 records

        COMMIT;

    END LOOP;

  CLOSE l_instance_del_csr;
  CSM_UTIL_PKG.LOG('Deleting Instances-END ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
CSM_UTIL_PKG.LOG('Deleting Counters-START ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
  OPEN l_counter_del_csr;

    LOOP

      IF l_counter_id_tbl.COUNT > 0 THEN

         l_counter_id_tbl.DELETE;

      END IF;

      IF l_user_id_tbl.COUNT > 0 THEN

         l_user_id_tbl.DELETE;

      END IF;

        FETCH l_counter_del_csr BULK COLLECT INTO l_counter_id_tbl,l_user_id_tbl LIMIT 100;
        EXIT WHEN l_counter_id_tbl.COUNT = 0;

          IF l_counter_id_tbl.COUNT > 0 THEN

            FOR i IN l_counter_id_tbl.FIRST..l_counter_id_tbl.LAST LOOP

              --call the CSM_ACC_PKG to delete from csm_counters_acc table

              CSM_ACC_PKG.Delete_Acc
                ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name7
                 ,P_ACC_TABLE_NAME         => g_acc_table_name7
                 ,P_PK1_NAME               => g_pk1_name7
                 ,P_PK1_NUM_VALUE          => l_counter_id_tbl(i)
                 ,P_USER_ID                => l_user_id_tbl(i)
                );

            END LOOP;

          END IF;

        -- commit after every 100 records

      COMMIT;

    END LOOP;

  CLOSE l_counter_del_csr;
  CSM_UTIL_PKG.LOG('Deleting Counters-END ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
  CSM_UTIL_PKG.LOG('Deleting Counter Values-START ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
  OPEN l_counter_value_del_csr;

    LOOP

      IF l_counter_value_id_tbl.COUNT > 0 THEN

         l_counter_value_id_tbl.DELETE;

       END IF;

       IF l_counter_id_tbl.COUNT > 0 THEN

          l_counter_id_tbl.DELETE;

       END IF;

       IF l_user_id_tbl.COUNT > 0 THEN

          l_user_id_tbl.DELETE;

       END IF;

         FETCH l_counter_value_del_csr BULK COLLECT INTO l_counter_value_id_tbl,l_counter_id_tbl,l_user_id_tbl LIMIT 100;
         EXIT WHEN l_counter_value_id_tbl.COUNT = 0;

           IF l_counter_value_id_tbl.COUNT > 0 THEN

             FOR i IN l_counter_value_id_tbl.FIRST..l_counter_value_id_tbl.LAST LOOP

               --call the CSM_ACC_PKG to delete from csm_counter_values_acc table

               CSM_ACC_PKG.Delete_Acc
                 ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name8
                  ,P_ACC_TABLE_NAME         => g_acc_table_name8
                  ,P_PK1_NAME               => g_pk1_name8
                  ,P_PK1_NUM_VALUE          => l_counter_value_id_tbl(i)
                  ,P_USER_ID                => l_user_id_tbl(i)
                 );

             END LOOP;

           END IF;

        -- commit after every 100 records

      COMMIT;

    END LOOP;

  CLOSE l_counter_value_del_csr;
  CSM_UTIL_PKG.LOG('Deleting Counter Values-END ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
  CSM_UTIL_PKG.LOG('Deleting Counter Property-START ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
  OPEN l_counter_property_del_csr;

    LOOP

      IF l_counter_prp_id_tbl.COUNT > 0 THEN

         l_counter_prp_id_tbl.DELETE;

      END IF;

      IF l_user_id_tbl.COUNT > 0 THEN

         l_user_id_tbl.DELETE;

      END IF;

        FETCH l_counter_property_del_csr BULK COLLECT INTO l_counter_prp_id_tbl,l_user_id_tbl LIMIT 100;
        EXIT WHEN l_counter_prp_id_tbl.COUNT = 0;

          IF l_counter_prp_id_tbl.COUNT > 0 THEN

            FOR i IN l_counter_prp_id_tbl.FIRST..l_counter_prp_id_tbl.LAST LOOP

              --call the CSM_ACC_PKG to  delete from CSM_COUNTER_PROPERTIES_ACC table

               CSM_ACC_PKG.Delete_Acc
                 ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name9
                  ,P_ACC_TABLE_NAME         => g_acc_table_name9
                  ,P_PK1_NAME               => g_pk1_name9
                  ,P_PK1_NUM_VALUE          => l_counter_prp_id_tbl(i)
                  ,P_USER_ID                => l_user_id_tbl(i)
                 );

            END LOOP;

          END IF;

       -- commit after every 100 records

      COMMIT;

    END LOOP;

  CLOSE l_counter_property_del_csr;
CSM_UTIL_PKG.LOG('Deleting Counter Property-END ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
CSM_UTIL_PKG.LOG('Deleting Counter Property Values-START ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
  OPEN l_counter_prop_value_del_csr;

    LOOP

      IF l_counter_prop_val_tbl.COUNT > 0 THEN

         l_counter_prop_val_tbl.DELETE;

      END IF;

      IF l_user_id_tbl.COUNT > 0 THEN

         l_user_id_tbl.DELETE;

      END IF;

        FETCH l_counter_prop_value_del_csr BULK COLLECT INTO l_counter_prop_val_tbl,l_user_id_tbl LIMIT 100;
        EXIT WHEN l_counter_prop_val_tbl.COUNT = 0;

          IF l_counter_prop_val_tbl.COUNT > 0 THEN

            FOR i IN l_counter_prop_val_tbl.FIRST..l_counter_prop_val_tbl.LAST LOOP

              --call the CSM_ACC_PKG to delete from CSM_COUNTER_PROP_VALUES_ACC table

              CSM_ACC_PKG.Delete_Acc
                ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name9
                 ,P_ACC_TABLE_NAME         => g_acc_table_name9
                 ,P_PK1_NAME               => g_pk1_name9
                 ,P_PK1_NUM_VALUE          => l_counter_prop_val_tbl(i)
                 ,P_USER_ID                => l_user_id_tbl(i)
                );

            END LOOP;

          END IF;

       -- commit after every 100 records

       COMMIT;

    END LOOP;

  CLOSE l_counter_prop_value_del_csr;
  CSM_UTIL_PKG.LOG('Deleting Counter Property Values-END ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
  CSM_UTIL_PKG.LOG('Deleting Party Sites and HZ Locations -START ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
  OPEN l_party_sites_del_csr;

    LOOP

      IF l_user_id_tbl.COUNT > 0 THEN

         l_user_id_tbl.DELETE;

      END IF;

      IF l_party_id_tbl.COUNT > 0 THEN

         l_party_id_tbl.DELETE;

      END IF;

      IF l_party_site_id_tbl.COUNT > 0 THEN

         l_party_site_id_tbl.DELETE;

      END IF;

      IF l_location_id_tbl.COUNT > 0 THEN

         l_location_id_tbl.DELETE;

      END IF;

        FETCH l_party_sites_del_csr BULK COLLECT INTO l_user_id_tbl,l_party_id_tbl,l_party_site_id_tbl,l_location_id_tbl LIMIT 100;
        EXIT WHEN l_party_site_id_tbl.COUNT = 0;

          IF l_party_site_id_tbl.COUNT > 0 THEN

            FOR i IN l_party_site_id_tbl.FIRST..l_party_site_id_tbl.LAST LOOP

               --call the CSM_ACC_PKG to delete the record from csm_party_sites_acc table

                CSM_ACC_PKG.Delete_Acc
                  ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
                   ,P_ACC_TABLE_NAME         => g_acc_table_name1
                   ,P_PK1_NAME               => g_pk1_name1
                   ,P_PK1_NUM_VALUE          => l_party_site_id_tbl(i)
                   ,P_PK2_NAME               => g_pk2_name1
                   ,P_PK2_NUM_VALUE          => l_party_id_tbl(i)
                   ,P_USER_ID                => l_user_id_tbl(i)
                  );

               --call the CSM_ACC_PKG to delete the record from csm_parties_acc table

               CSM_ACC_PKG.Delete_Acc
                 ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name0
                  ,P_ACC_TABLE_NAME         => g_acc_table_name0
                  ,P_PK1_NAME               => g_pk1_name0
                  ,P_PK1_NUM_VALUE          => l_party_id_tbl(i)
                  ,P_USER_ID                => l_user_id_tbl(i)
                 );

            END LOOP;

               -- commit after every 100 records

               COMMIT;

             FOR i IN l_location_id_tbl.FIRST..l_location_id_tbl.LAST LOOP

               --call the CSM_ACC_PKG to delete the record from csm_hz_locations_acc table

               CSM_ACC_PKG.Delete_Acc
                 ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name2
                  ,P_ACC_TABLE_NAME         => g_acc_table_name2
                  ,P_PK1_NAME               => g_pk1_name2
                  ,P_PK1_NUM_VALUE          => l_location_id_tbl(i)
                  ,P_USER_ID                => l_user_id_tbl(i)
                 );

             END LOOP;

           END IF;

         -- commit after every 100 records

      COMMIT;

    END LOOP;

  CLOSE l_party_sites_del_csr;
  CSM_UTIL_PKG.LOG('Deleting Party Sites and HZ Locations -END ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
  CSM_UTIL_PKG.LOG('Deleting Parties -START ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
  OPEN l_party_del_csr;

    LOOP

      IF l_party_id_tbl.COUNT > 0 THEN

         l_party_id_tbl.DELETE;

      END IF;

      IF l_user_id_tbl.COUNT > 0 THEN

         l_user_id_tbl.DELETE;

      END IF;

        FETCH l_party_del_csr BULK COLLECT INTO l_user_id_tbl,l_party_id_tbl LIMIT 100;
        EXIT WHEN l_party_id_tbl.COUNT = 0;

          IF l_party_id_tbl.COUNT > 0 THEN

            FOR i IN l_party_id_tbl.FIRST..l_party_id_tbl.LAST LOOP

              --call the CSM_ACC_PKG to delete the record from csm_parties_acc table

              CSM_ACC_PKG.Delete_Acc
                ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name0
                 ,P_ACC_TABLE_NAME         => g_acc_table_name0
                 ,P_PK1_NAME               => g_pk1_name0
                 ,P_PK1_NUM_VALUE          => l_party_id_tbl(i)
                 ,P_USER_ID                => l_user_id_tbl(i)
                );

            END LOOP;

          END IF;

        -- commit after every 100 records

      COMMIT;

    END LOOP;

  CLOSE l_party_del_csr;
  CSM_UTIL_PKG.LOG('Deleting Parties -END ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);

  CSM_UTIL_PKG.LOG('Processing Parties-START ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);

  OPEN l_party_ins_csr;

    LOOP

      IF l_party_id_tbl.COUNT > 0 THEN

         l_party_id_tbl.DELETE;

      END IF;

      IF l_user_id_tbl.COUNT > 0 THEN

               l_user_id_tbl.DELETE;

      END IF;

        FETCH l_party_ins_csr BULK COLLECT INTO l_user_id_tbl,l_party_id_tbl LIMIT 100;
        EXIT WHEN l_party_id_tbl.COUNT = 0;

          IF l_party_id_tbl.COUNT > 0 THEN

            FOR i IN l_party_id_tbl.FIRST..l_party_id_tbl.LAST LOOP

              --call the CSM_ACC_PKG to insert into csm_parties_acc table

              CSM_ACC_PKG.Insert_Acc
                ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name0
                 ,P_ACC_TABLE_NAME         => g_acc_table_name0
                 ,P_SEQ_NAME               => g_acc_sequence_name0
                 ,P_PK1_NAME               => g_pk1_name0
                 ,P_PK1_NUM_VALUE          => l_party_id_tbl(i)
                 ,P_USER_ID                => l_user_id_tbl(i)
                );

            END LOOP;

          END IF;
        -- commit after every 100 records
      COMMIT;

    END LOOP;

  CLOSE l_party_ins_csr;
  CSM_UTIL_PKG.LOG('Processing Parties-END ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
  CSM_UTIL_PKG.LOG('Processing Party Sites and Locations-START ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
  OPEN l_party_sites_ins_csr;

    LOOP

      IF l_user_id_tbl.COUNT > 0 THEN

         l_user_id_tbl.DELETE;

      END IF;

      IF l_party_id_tbl.COUNT > 0 THEN

         l_party_id_tbl.DELETE;

      END IF;


      IF l_party_site_id_tbl.COUNT > 0 THEN

         l_party_site_id_tbl.DELETE;

      END IF;

      IF l_location_id_tbl.COUNT > 0 THEN

         l_location_id_tbl.DELETE;

      END IF;

        FETCH l_party_sites_ins_csr BULK COLLECT INTO l_user_id_tbl,l_party_id_tbl,l_party_site_id_tbl,l_location_id_tbl LIMIT 100;

        EXIT WHEN l_party_site_id_tbl.COUNT = 0;


          IF l_party_site_id_tbl.COUNT > 0 THEN

            FOR i IN l_party_site_id_tbl.FIRST..l_party_site_id_tbl.LAST LOOP

              --call the CSM_ACC_PKG to insert into csm_party_sites_acc table

              CSM_ACC_PKG.Insert_Acc
                ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
                 ,P_ACC_TABLE_NAME         => g_acc_table_name1
                 ,P_SEQ_NAME               => g_acc_sequence_name1
                 ,P_PK1_NAME               => g_pk1_name1
                 ,P_PK1_NUM_VALUE          => l_party_site_id_tbl(i)
                 ,P_PK2_NAME               => g_pk2_name1
                 ,P_PK2_NUM_VALUE          => l_party_id_tbl(i)
                 ,P_USER_ID                => l_user_id_tbl(i)
                );

             --call the CSM_ACC_PKG to insert into csm_parties_acc table

              CSM_ACC_PKG.Insert_Acc
                ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name0
                 ,P_ACC_TABLE_NAME         => g_acc_table_name0
                 ,P_SEQ_NAME               => g_acc_sequence_name0
                 ,P_PK1_NAME               => g_pk1_name0
                 ,P_PK1_NUM_VALUE          => l_party_id_tbl(i)
                 ,P_USER_ID                => l_user_id_tbl(i)
                );
            END LOOP;

              -- commit after every 100 records
              COMMIT;

            FOR i IN l_location_id_tbl.FIRST..l_location_id_tbl.LAST LOOP

              --call the CSM_ACC_PKG to insert into csm_hz_locations_acc table

              CSM_ACC_PKG.Insert_Acc
                ( P_PUBLICATION_ITEM_NAMES  => g_publication_item_name2
                 ,P_ACC_TABLE_NAME          => g_acc_table_name2
                 ,P_SEQ_NAME                => g_acc_sequence_name2
                 ,P_USER_ID                 => l_user_id_tbl(i)
                 ,P_PK1_NAME                => g_pk1_name2
                 ,P_PK1_NUM_VALUE           => l_location_id_tbl(i)
                );


            END LOOP;

          END IF;

      -- commit after every 100 records

      COMMIT;

    END LOOP;

  CLOSE l_party_sites_ins_csr;
  CSM_UTIL_PKG.LOG('Processing Party Sites and Locations-END ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
  CSM_UTIL_PKG.LOG('Processing Instances-START ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);

  OPEN l_instance_ins_csr;

    LOOP

      IF l_instance_id_tbl.COUNT > 0 THEN

         l_instance_id_tbl.DELETE;

      END IF;

      IF l_user_id_tbl.COUNT > 0 THEN
         l_user_id_tbl.DELETE;
      END IF;

      IF l_inv_item_id_tbl.COUNT > 0 THEN
         l_inv_item_id_tbl.DELETE;
      END IF;

      IF l_last_vld_org_id_tbl.COUNT > 0 THEN
         l_last_vld_org_id_tbl.DELETE;
      END IF;

      IF l_ver_label_lst.COUNT > 0 THEN
         l_ver_label_lst.DELETE;
      END IF;

      IF l_parent_inst_id_lst.COUNT > 0 THEN
         l_parent_inst_id_lst.DELETE;
      END IF;

        FETCH l_instance_ins_csr BULK COLLECT INTO l_instance_id_tbl,l_user_id_tbl,
        l_inv_item_id_tbl, l_last_vld_org_id_tbl, l_ver_label_lst, l_parent_inst_id_lst LIMIT 100;  --l_user_ins_tbl LIMIT 100;

        EXIT WHEN l_instance_id_tbl.COUNT = 0;

          IF l_instance_id_tbl.COUNT > 0 THEN

            FOR i IN l_instance_id_tbl.FIRST..l_instance_id_tbl.LAST LOOP

               --call the CSM_ACC_PKG to insert into csm_item_instances_acc table

               CSM_ACC_PKG.Insert_Acc
                 ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name3
                  ,P_ACC_TABLE_NAME         => g_acc_table_name3
                  ,P_SEQ_NAME               => g_acc_sequence_name3
                  ,P_PK1_NAME               => g_pk1_name3
                  ,P_PK1_NUM_VALUE          => l_instance_id_tbl(i)
                  ,P_USER_ID                => l_user_id_tbl(i)
                 );

                  UPDATE csm_item_instances_acc
                  SET    PARENT_INSTANCE_ID = l_parent_inst_id_lst(i),
                         VERSION_LABEL      = l_ver_label_lst(i)
                  WHERE  USER_ID     = l_user_id_tbl(i)
                  AND    INSTANCE_ID = l_instance_id_tbl(i);

                --inserting the corresponding item into acc table
                csm_mtl_system_items_event_pkg.MTL_SYSTEM_ITEMS_ACC_I(l_inv_item_id_tbl(i),
                                                             l_last_vld_org_id_tbl(i),
                                                             l_user_id_tbl(i),
                                                             l_error_msg,
                                                             l_return_status);

            END LOOP;

          END IF;

      -- commit after every 100 records

      COMMIT;

    END LOOP;

  CLOSE l_instance_ins_csr;
  CSM_UTIL_PKG.LOG('Processing Instances-END ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);

  IF l_counter_profile_value = 'Y' THEN

  CSM_UTIL_PKG.LOG('Processing Counters-START ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);

  OPEN l_counter_ins_csr;

    LOOP

      IF l_counter_id_tbl.COUNT > 0 THEN

         l_counter_id_tbl.DELETE;

      END IF;

      IF l_user_id_tbl.COUNT > 0 THEN

         l_user_id_tbl.DELETE;

      END IF;

        FETCH l_counter_ins_csr BULK COLLECT INTO l_counter_id_tbl,l_user_id_tbl LIMIT 100;
        EXIT WHEN l_counter_id_tbl.COUNT = 0;

          IF l_counter_id_tbl.COUNT > 0 THEN

            FOR i IN l_counter_id_tbl.FIRST..l_counter_id_tbl.LAST LOOP

              --call the CSM_ACC_PKG to insert into csm_counters_acc table

              CSM_ACC_PKG.Insert_Acc
                ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name7
                 ,P_ACC_TABLE_NAME         => g_acc_table_name7
                 ,P_SEQ_NAME               => g_acc_sequence_name7
                 ,P_PK1_NAME               => g_pk1_name7
                 ,P_PK1_NUM_VALUE          => l_counter_id_tbl(i)
                 ,P_USER_ID                => l_user_id_tbl(i)
                );

            END LOOP;

          END IF;

        -- commit after every 100 records

        COMMIT;

    END LOOP;

  CLOSE l_counter_ins_csr;
CSM_UTIL_PKG.LOG('Processing Counters-END ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
CSM_UTIL_PKG.LOG('Processing Counter Values-START ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
  OPEN l_counter_value_ins_csr;

    LOOP

      IF l_counter_value_id_tbl.COUNT > 0 THEN

         l_counter_value_id_tbl.DELETE;

      END IF;

      IF l_counter_id_tbl.COUNT > 0 THEN

         l_counter_id_tbl.DELETE;

      END IF;

      IF l_user_id_tbl.COUNT > 0 THEN

         l_user_id_tbl.DELETE;

      END IF;

        FETCH l_counter_value_ins_csr BULK COLLECT INTO l_counter_value_id_tbl,l_counter_id_tbl,l_user_id_tbl LIMIT 100;
        EXIT WHEN l_counter_value_id_tbl.COUNT = 0;

          IF l_counter_value_id_tbl.COUNT > 0 THEN

            FOR i IN l_counter_value_id_tbl.FIRST..l_counter_value_id_tbl.LAST LOOP

               --call the CSM_ACC_PKG to insert into csm_counter_values_acc table

               CSM_ACC_PKG.Insert_Acc
                 ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name8
                  ,P_ACC_TABLE_NAME         => g_acc_table_name8
                  ,P_SEQ_NAME               => g_acc_sequence_name8
                  ,P_PK1_NAME               => g_pk1_name8
                  ,P_PK1_NUM_VALUE          => l_counter_value_id_tbl(i)
                  ,P_PK2_NAME               => g_pk2_name8
                  ,P_PK2_NUM_VALUE          => l_counter_id_tbl(i)
                  ,P_USER_ID                => l_user_id_tbl(i)
                 );

             END LOOP;

          END IF;

          -- commit after every 100 records

          COMMIT;

    END LOOP;

  CLOSE l_counter_value_ins_csr;
 CSM_UTIL_PKG.LOG('Processing Counter Values-END ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
 CSM_UTIL_PKG.LOG('Processing Counter Property-START ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
  OPEN l_counter_property_ins_csr;

    LOOP

      IF l_counter_prp_id_tbl.COUNT > 0 THEN

         l_counter_prp_id_tbl.DELETE;

      END IF;

      IF l_user_id_tbl.COUNT > 0 THEN

         l_user_id_tbl.DELETE;

      END IF;

        FETCH l_counter_property_ins_csr BULK COLLECT INTO l_counter_prp_id_tbl,l_user_id_tbl LIMIT 100;
        EXIT WHEN l_counter_prp_id_tbl.COUNT = 0;

          IF l_counter_prp_id_tbl.COUNT > 0 THEN

            FOR i IN l_counter_prp_id_tbl.FIRST..l_counter_prp_id_tbl.LAST LOOP

               --call the CSM_ACC_PKG to insert into CSM_COUNTER_PROPERTIES_ACC table

               CSM_ACC_PKG.Insert_Acc
                 ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name9
                  ,P_ACC_TABLE_NAME         => g_acc_table_name9
                  ,P_SEQ_NAME               => g_acc_sequence_name9
                  ,P_PK1_NAME               => g_pk1_name9
                  ,P_PK1_NUM_VALUE          => l_counter_prp_id_tbl(i)
                  ,P_USER_ID                => l_user_id_tbl(i)
                 );

            END LOOP;

          END IF;

         -- commit after every 100 records

      COMMIT;

    END LOOP;

  CLOSE l_counter_property_ins_csr;
 CSM_UTIL_PKG.LOG('Processing Counter Property-END ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
 CSM_UTIL_PKG.LOG('Processing Counter Property Values-START ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
  OPEN l_counter_prop_value_ins_csr;

    LOOP

      IF l_counter_prop_val_tbl.COUNT > 0 THEN

         l_counter_prop_val_tbl.DELETE;

      END IF;

      IF l_user_id_tbl.COUNT > 0 THEN

         l_user_id_tbl.DELETE;

      END IF;

        FETCH l_counter_prop_value_ins_csr BULK COLLECT INTO l_counter_prop_val_tbl,l_user_id_tbl LIMIT 100;
        EXIT WHEN l_counter_prop_val_tbl.COUNT = 0;

          IF l_counter_prop_val_tbl.COUNT > 0 THEN

            FOR i IN l_counter_prop_val_tbl.FIRST..l_counter_prop_val_tbl.LAST LOOP

              --call the CSM_ACC_PKG to insert into CSM_COUNTER_PROP_VALUES_ACC table

              CSM_ACC_PKG.Insert_Acc
                ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name9
                 ,P_ACC_TABLE_NAME         => g_acc_table_name9
                 ,P_SEQ_NAME               => g_acc_sequence_name9
                 ,P_PK1_NAME               => g_pk1_name9
                 ,P_PK1_NUM_VALUE          => l_counter_prop_val_tbl(i)
                 ,P_USER_ID                => l_user_id_tbl(i)
                );

            END LOOP;

          END IF;

        -- commit after every 100 records

      COMMIT;

    END LOOP;

  CLOSE l_counter_prop_value_ins_csr;
 CSM_UTIL_PKG.LOG('Processing Counter Property Values-END ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);

ELSE

   CSM_UTIL_PKG.LOG('The Profile Option CSM: Allow Counters Download for Parties is set to NO',FND_LOG.LEVEL_PROCEDURE);

END IF;

 CSM_UTIL_PKG.LOG('Processing HZ Contacts-START ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
  OPEN l_contacts_ins_csr;

    LOOP

      IF l_contacts_id_tbl.COUNT > 0 THEN

         l_contacts_id_tbl.DELETE;

      END IF;


      IF l_user_id_tbl.COUNT > 0 THEN

         l_user_id_tbl.DELETE;

      END IF;

      IF l_party_id_tbl.COUNT > 0 THEN

         l_party_id_tbl.DELETE;

      END IF;

      IF l_relationship_id_tbl.COUNT > 0 THEN

         l_relationship_id_tbl.DELETE;

      END IF;

      IF l_direct_flag_tbl.COUNT > 0 THEN
         l_direct_flag_tbl.DELETE;
      END IF;
      IF l_subject_id_tbl.COUNT > 0 THEN
         l_subject_id_tbl.DELETE;
      END IF;

        FETCH l_contacts_ins_csr BULK COLLECT INTO l_contacts_id_tbl,l_party_id_tbl,l_user_id_tbl,l_relationship_id_tbl,l_direct_flag_tbl,l_subject_id_tbl LIMIT 100;

        EXIT WHEN l_contacts_id_tbl.COUNT = 0;

          IF l_contacts_id_tbl.COUNT > 0 THEN

            FOR i IN l_contacts_id_tbl.FIRST..l_contacts_id_tbl.LAST LOOP

              --call the CSM_ACC_PKG to insert into csm_sr_contacts_acc table

              CSM_ACC_PKG.Insert_Acc
                ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name4
                 ,P_ACC_TABLE_NAME         => g_acc_table_name4
                 ,P_SEQ_NAME               => g_acc_sequence_name4
                 ,P_PK1_NAME               => g_pk1_name4
                 ,P_PK1_NUM_VALUE          => l_contacts_id_tbl(i)
                 ,P_USER_ID                => l_user_id_tbl(i)
                );

             --call the CSM_ACC_PKG to insert into csm_hz_relationships_acc table

              CSM_ACC_PKG.Insert_Acc
                ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name11
                 ,P_ACC_TABLE_NAME         => g_acc_table_name11
                 ,P_SEQ_NAME               => g_acc_sequence_name11
                 ,P_PK1_NAME               => g_pk1_name11
                 ,P_PK1_NUM_VALUE          => l_relationship_id_tbl(i)
                 ,P_PK2_NAME               => g_pk2_name11
                 ,P_PK2_CHAR_VALUE         => l_direct_flag_tbl(i)
                 ,P_USER_ID                => l_user_id_tbl(i)
                );

            END LOOP;

              -- commit after every 100 records

             COMMIT;

            FOR i IN l_party_id_tbl.FIRST..l_party_id_tbl.LAST LOOP

              --call the CSM_ACC_PKG to insert object id into csm_parties_acc table
              CSM_ACC_PKG.Insert_Acc
                ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name0
                 ,P_ACC_TABLE_NAME         => g_acc_table_name0
                 ,P_SEQ_NAME               => g_acc_sequence_name0
                 ,P_PK1_NAME               => g_pk1_name0
                 ,P_PK1_NUM_VALUE          => l_party_id_tbl(i)
                 ,P_USER_ID                => l_user_id_tbl(i)
                );

              --call the CSM_ACC_PKG to insert Subject id into csm_parties_acc table
              CSM_ACC_PKG.Insert_Acc
                ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name0
                 ,P_ACC_TABLE_NAME         => g_acc_table_name0
                 ,P_SEQ_NAME               => g_acc_sequence_name0
                 ,P_PK1_NAME               => g_pk1_name0
                 ,P_PK1_NUM_VALUE          => l_subject_id_tbl(i)
                 ,P_USER_ID                => l_user_id_tbl(i)
                );

            END LOOP;

          END IF;

        -- commit after every 100 records

        COMMIT;

    END LOOP;

  CLOSE l_contacts_ins_csr;
CSM_UTIL_PKG.LOG('Processing HZ Contacts-END ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
CSM_UTIL_PKG.LOG('Processing Customer Accounts-START ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
  OPEN  l_customer_accounts_ins_csr;

    LOOP

      IF l_cust_acct_id_tbl.COUNT > 0 THEN

         l_cust_acct_id_tbl.DELETE;

      END IF;

      IF l_user_id_tbl.COUNT > 0 THEN

         l_user_id_tbl.DELETE;

      END IF;

        FETCH l_customer_accounts_ins_csr BULK COLLECT INTO l_cust_acct_id_tbl,l_user_id_tbl LIMIT 100;
        EXIT WHEN l_cust_acct_id_tbl.COUNT = 0;

          IF l_cust_acct_id_tbl.COUNT > 0 THEN

            FOR i IN l_cust_acct_id_tbl.FIRST..l_cust_acct_id_tbl.LAST LOOP

            --call the CSM_ACC_PKG to insert the record into csm_hz_cust_accounts_acc table

              CSM_ACC_PKG.Insert_Acc
                ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name6
                 ,P_ACC_TABLE_NAME         => g_acc_table_name6
                 ,P_SEQ_NAME               => g_acc_sequence_name6
                 ,P_PK1_NAME               => g_pk1_name6
                 ,P_PK1_NUM_VALUE          => l_cust_acct_id_tbl(i)
                 ,P_USER_ID                => l_user_id_tbl(i)
                );

            END LOOP;

          END IF;

           -- commit after every 100 records

          COMMIT;

    END LOOP;

  CLOSE l_customer_accounts_ins_csr;
  CSM_UTIL_PKG.LOG('Processing Customer Accounts-END ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);

  DELETE FROM csm_party_assignment
  WHERE  DELETED_FLAG='Y';

  COMMIT;

  CSM_UTIL_PKG.LOG('Calling CSM_SERVICE_HISTORY_EVENT_PKG.PROCESS_OWNER_HISTORY package', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);

  /* we dont require the records with deleted flag as Y
     hence calling the service history package after the delete statement */

  CSM_SERVICE_HISTORY_EVENT_PKG.PROCESS_OWNER_HISTORY(l_return_status,l_error_message);

  UPDATE jtm_con_request_data
  SET last_run_date  = SYSDATE
  WHERE product_code = 'CSM'
  AND package_name   = 'CSM_PARTY_DATA_EVENT_PKG'
  AND procedure_name = 'REFRESH_ACC';

  COMMIT;

    x_return_status := 'SUCCESS';
    x_error_message := 'PARTY_ID,PARTY_SITE_ID,LOCATION_ID,ITEM_INSTANCE_ID,CONTACT_ID are successfully processed';
    CSM_UTIL_PKG.LOG('Leaving CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC Package ', 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);

EXCEPTION
  WHEN others THEN
    l_sqlerrno      := to_char(SQLCODE);
    l_sqlerrmsg     := substr(SQLERRM, 1,2000);
    x_return_status := 'ERROR';
    x_error_message := l_sqlerrmsg;
    p_message       := 'Exception in CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC Procedure :' || l_sqlerrno || ':' || l_sqlerrmsg;
    CSM_UTIL_PKG.LOG(p_message, 'CSM_PARTY_DATA_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
    ROLLBACK;

  END REFRESH_ACC;

END CSM_PARTY_DATA_EVENT_PKG;

/
