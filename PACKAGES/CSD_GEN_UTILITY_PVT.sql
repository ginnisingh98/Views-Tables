--------------------------------------------------------
--  DDL for Package CSD_GEN_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_GEN_UTILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: csdvtgus.pls 120.1 2005/08/17 15:09:56 swai noship $*/

  g_dir           varchar2(255) :=
                  nvl(fnd_profile.value('CSD_LOGFILE_PATH'), '/tmp');

  g_file          varchar2(255) := null;
  g_file_ptr      utl_file.file_type;
  g_debug         varchar2(1)    := fnd_api.g_false;

  g_debug_level   number := to_number(nvl(
                  fnd_profile.value('CSD_DEBUG_LEVEL'), '0'));

  PROCEDURE set_debug_on;
  PROCEDURE set_debug_off;
  FUNCTION  is_debug_on return boolean;
  PROCEDURE add (p_debug_msg in varchar2);

  PROCEDURE dump_api_info(
    p_pkg_name  IN varchar2,
    p_api_name  IN varchar2);

  PROCEDURE dump_error_stack;

  FUNCTION  dump_error_stack RETURN varchar2;

  PROCEDURE dump_prod_txn_rec (
    p_prod_txn_rec in csd_process_pvt.product_txn_rec);

  PROCEDURE dump_sr_rec (
    p_sr_rec in csd_process_pvt.service_request_rec);

  PROCEDURE dump_estimate_rec (
    p_estimate_rec in csd_repair_estimate_pvt.repair_estimate_rec);

  PROCEDURE dump_repair_order_group_rec (
    p_repair_order_group_rec in csd_repair_groups_pvt.repair_order_group_rec);

  PROCEDURE dump_estimate_line_rec (
    p_estimate_line_rec in csd_repair_estimate_pvt.repair_estimate_line_rec);

  PROCEDURE dump_hz_person_rec (
    p_person_rec              IN  HZ_PARTY_V2PUB.person_rec_type
  );

  PROCEDURE dump_hz_org_rec (
    p_org_rec                 IN  HZ_PARTY_V2PUB.organization_rec_type
  );

  PROCEDURE dump_hz_acct_rec (
    p_account_rec             IN  HZ_CUST_ACCOUNT_V2PUB.cust_account_rec_type
  );

  PROCEDURE dump_hz_cust_profile_rec (
    p_cust_profile_rec        IN  HZ_CUSTOMER_PROFILE_V2PUB.customer_profile_rec_type
  );

  PROCEDURE dump_hz_phone_rec (
    p_phone_rec               IN  HZ_CONTACT_POINT_V2PUB.phone_rec_type
  );

  PROCEDURE dump_hz_email_rec (
    p_email_rec               IN  HZ_CONTACT_POINT_V2PUB.email_rec_type
  );

  PROCEDURE dump_hz_web_rec (
    p_web_rec                 IN  HZ_CONTACT_POINT_V2PUB.web_rec_type
  );

  PROCEDURE dump_address_rec (
    p_addr_rec            IN  CSD_PROCESS_PVT.address_rec_type
  );

  PROCEDURE dump_hz_party_site_rec (
    p_party_site_rec     IN  HZ_PARTY_SITE_V2PUB.party_site_rec_type
  );

  PROCEDURE dump_hz_party_site_use_rec (
    p_party_site_use_rec IN  HZ_PARTY_SITE_V2PUB.party_site_use_rec_type
  );

  PROCEDURE dump_hz_party_rel_rec (
    p_party_rel_rec      IN  HZ_RELATIONSHIP_V2PUB.relationship_rec_type
  );

  PROCEDURE dump_diagnostic_code_rec (
      p_diagnostic_code_rec      IN  CSD_DIAGNOSTIC_CODES_PVT.diagnostic_code_rec_type
  );

  PROCEDURE dump_dc_domain_rec (
      p_dc_domain_rec      IN  CSD_DC_DOMAINS_PVT.dc_domain_rec_type
  );

  PROCEDURE dump_ro_diagnostic_code_rec (
      p_ro_diagnostic_code_rec      IN  CSD_RO_DIAGNOSTIC_CODES_PVT.ro_diagnostic_code_rec_type
  );

  PROCEDURE dump_service_code_rec (
      p_service_code_rec      IN  CSD_SERVICE_CODES_PVT.service_code_rec_type
  );

  PROCEDURE dump_sc_domain_rec (
      p_sc_domain_rec      IN  CSD_SC_DOMAINS_PVT.sc_domain_rec_type
  );

  PROCEDURE dump_sc_work_entity_rec (
      p_sc_work_entity_rec      IN  CSD_SC_WORK_ENTITIES_PVT.sc_work_entity_rec_type
  );

  PROCEDURE dump_ro_service_code_rec (
      p_ro_service_code_rec      IN  CSD_RO_SERVICE_CODES_PVT.ro_service_code_rec_type
  );

  PROCEDURE dump_repair_estimate_line_tbl (
      p_repair_estimate_line_tbl      IN  CSD_REPAIR_ESTIMATE_PVT.repair_estimate_line_tbl
  );

  PROCEDURE dump_mle_lines_rec_type (
      p_mle_lines_rec      IN  CSD_REPAIR_ESTIMATE_PVT.mle_lines_rec_type
  );

  PROCEDURE dump_mle_lines_tbl_type (
      p_mle_lines_tbl      IN  CSD_REPAIR_ESTIMATE_PVT.mle_lines_tbl_type
  );

  Function G_CURRENT_RUNTIME_LEVEL Return Number;

END csd_gen_utility_pvt;


 

/
