--------------------------------------------------------
--  DDL for Package Body ECE_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECE_RULES_PKG" AS
-- $Header: ECERULEB.pls 120.4.12010000.2 2008/11/24 17:21:59 akemiset ship $

translator_code       VARCHAR2(30);

PROCEDURE Update_Status (
   p_transaction_type    IN      VARCHAR2,
   p_level               IN      NUMBER,
   p_valid_rule          IN      VARCHAR2,
   p_action              IN      VARCHAR2,
   p_interface_column_id IN      NUMBER DEFAULT NULL,
   p_rule_id             IN      NUMBER,
   p_stage_id            IN      NUMBER,
   p_document_id         IN      NUMBER,
   p_violation_level     IN      VARCHAR2,
   p_document_number     IN      VARCHAR2,
   p_msg_text            IN      VARCHAR2) IS

   xProgress                     VARCHAR2(80);
   l_cur_status                  ece_stage.status%TYPE;
   l_new_status                  ece_stage.status%TYPE;
   l_cur_index                   NUMBER;
   l_seq                         NUMBER;

BEGIN

  if ec_debug.G_debug_level >= 2 then
   ec_debug.push ('ECE_RULES_PKG.UPDATE_STATUS');
   ec_debug.pl (3, 'p_transaction_type', p_transaction_type);
   ec_debug.pl (3, 'p_level', p_level);
   ec_debug.pl (3, 'p_valid_rule', p_valid_rule);
   ec_debug.pl (3, 'p_action', p_action);
   ec_debug.pl (3, 'p_interface_column_id', p_interface_column_id);
   ec_debug.pl (3, 'p_rule_id', p_rule_id);
   ec_debug.pl (3, 'p_stage_id', p_stage_id);
   ec_debug.pl (3, 'p_document_id', p_document_id);
   ec_debug.pl (3, 'p_document_number', p_document_number);
   ec_debug.pl (3, 'p_msg_text', p_msg_text);
   end if;

   xProgress := 'ECERULEB-10-1000';
   l_cur_status := ec_utils.g_ext_levels(p_level).status;
   if ec_debug.G_debug_level =3 then
   ec_debug.pl (3, 'Current Status', l_cur_status);
   end if;

   if (p_valid_rule = 'Y') then

      -- If the current status is NEW or RE_PROCESS, then we have
      -- to update it to 'INSERT'.
      -- Otherwise, we should keep the current status.
      if (l_cur_status = g_new or l_cur_status = g_reprocess) then
         ec_utils.g_ext_levels(p_level).status := g_insert;
      end if;

   elsif (p_action <> g_log_only) then

         -- We have to compare the staging table status with the current action
         -- and update the status with the higher priority action.
         -- For example, if the staging table already has a status to abort,
         -- and the current action is to skip document, then we should keep
         -- the status as 'ABORT' since 'ABORT' has higher priority.
         -- The prioritized list:  'ABORT', 'SKIP_DOCUMENT', 'INSERT', 'NEW',
         -- 'RE_PROCESS'.

         xProgress := 'ECERULEB-10-1010';
         if (p_action = g_abort or l_cur_status = g_abort) then
            l_new_status := g_abort;
         elsif (p_action = g_skip_doc or l_cur_status = g_skip_doc) then
            l_new_status := g_skip_doc;
         else
            l_new_status := g_insert;
         end if;

         ec_utils.g_ext_levels(p_level).status := l_new_status;

         xProgress := 'ECERULEB-10-1020';
         -- insert new violation information into ece_rule_violations table.

         l_cur_index := g_rule_violation_tbl.count + 1;
         select ece_rule_violations_s.nextval into l_seq from dual;

         if SQL%NOTFOUND then
            ec_debug.pl (0, 'EC', 'ECE_GET_NEXT_SEQ_FAILED',
                         'PROGRESS_LEVEL', xProgress,
                         'SEQ', 'ECE_RULE_VIOLATIONS_S');
         end if;

         g_rule_violation_tbl(l_cur_index).violation_id := l_seq;
         g_rule_violation_tbl(l_cur_index).document_id := p_document_id;
         g_rule_violation_tbl(l_cur_index).stage_id := p_stage_id;
         g_rule_violation_tbl(l_cur_index).interface_column_id := p_interface_column_id;
         g_rule_violation_tbl(l_cur_index).rule_id := p_rule_id;
         g_rule_violation_tbl(l_cur_index).transaction_type := p_transaction_type;
         g_rule_violation_tbl(l_cur_index).document_number := p_document_number;
         g_rule_violation_tbl(l_cur_index).violation_level := p_violation_level;
         g_rule_violation_tbl(l_cur_index).ignore_flag := 'N';
         g_rule_violation_tbl(l_cur_index).message_text := p_msg_text;

       if ec_debug.G_debug_level =3 then
        ec_debug.pl (3, 'EC', 'ECE_VIOLATIONS_INSERTED');
       end if;

   else

      -- If the action is log only and current status is 'NEW' or
      -- 'RE_PROCESS, then we only need to update the status to
      -- 'INSERT' since the violation message is written to the
      -- log file within the corresponding rule validate procedure.
      -- Otherwise, we should keep the same status.

      xProgress := 'ECERULEB-10-1030';
      if (l_cur_status = g_new or l_cur_status = g_reprocess) then
         ec_utils.g_ext_levels(p_level).status := g_insert;
      end if;

   end if;

  if ec_debug.G_debug_level >= 2 then
   ec_debug.pl (3, 'Updated status',
                ec_utils.g_ext_levels(p_level).status);
   ec_debug.pop ('ECE_RULES_PKG.UPDATE_STATUS');
 end if;

EXCEPTION
   WHEN OTHERS then
      ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR','PROGRESS_LEVEL', xProgress);
      ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
      ec_debug.pop ('ECE_RULES_PKG.UPDATE_STATUS');
      raise fnd_api.g_exc_unexpected_error;

END Update_Status;


PROCEDURE Validate_Process_Rules(
   p_api_version_number  IN      NUMBER,
   p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
   p_simulate            IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status       OUT NOCOPY    VARCHAR2,
   x_msg_count           OUT NOCOPY    NUMBER,
   x_msg_data            OUT NOCOPY    VARCHAR2,
   p_transaction_type    IN      VARCHAR2,
   p_address_type        IN      VARCHAR2,
   p_stage_id            IN      NUMBER,
   p_document_id         IN      NUMBER,
   p_document_number     IN      VARCHAR2,
   p_level               IN      NUMBER,
   p_map_id              IN      NUMBER,
   p_staging_tbl         IN OUT  NOCOPY ec_utils.mapping_tbl) IS

   l_api_name           CONSTANT VARCHAR2(30) := 'Validate_Process_Rules';
   l_api_version_number CONSTANT NUMBER       := 1.0;

   xProgress                     VARCHAR2(80);
   l_rule_type                   ece_process_rules.rule_type%TYPE;
   l_rule_id                     NUMBER;
   l_action_code                 ece_process_rules.action_code%TYPE;
   l_valid_rule                  VARCHAR2(1):= 'Y';
   l_tp_detail_id                NUMBER;
   l_violation_level             VARCHAR2(10) := g_process_rule;
   l_ignore_flag                 ece_rule_violations.ignore_flag%TYPE;
   l_msg_text                    ece_rule_violations.message_text%TYPE;
   no_process_rule_info          EXCEPTION;

   CURSOR c_rule_info(
          p_rule_type            VARCHAR2,
          p_transaction_type     VARCHAR2) IS
   select process_rule_id, action_code
   from   ece_process_rules
   where  transaction_type = p_transaction_type and
          map_id = p_map_id and
          rule_type = p_rule_type;

   CURSOR c_ignore_flag(
          p_document_id          NUMBER,
          p_rule_id              NUMBER) IS
   select ignore_flag
   from   ece_rule_violations
   where  document_id = p_document_id and
          rule_id     = p_rule_id     and
          violation_level = l_violation_level;

BEGIN
  if ec_debug.G_debug_level >= 2 then
   ec_debug.push ('ECE_RULES_PKG.VALIDATE_PROCESS_RULES');
   ec_debug.pl (3, 'p_transaction_type', p_transaction_type);
   ec_debug.pl (3, 'p_address_type', p_address_type);
   ec_debug.pl (3, 'p_stage_id', p_stage_id);
   ec_debug.pl (3, 'p_document_id', p_document_id);
   ec_debug.pl (3, 'p_document_number', p_document_number);
   ec_debug.pl (3, 'p_level', p_level);
   ec_debug.pl (3, 'p_map_id', p_map_id);
 end if;

   -- Standard call to check for call compatibility.
   if not fnd_api.compatible_api_call (l_api_version_number,
                                       p_api_version_number, l_api_name,
                                       g_pkg_name) then
      raise fnd_api.g_exc_unexpected_error;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   if fnd_api.to_boolean(p_init_msg_list) then
      fnd_msg_pub.initialize;
   end if;

   -- Initialize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;

   xProgress := 'ECERULEB-20-1000';
   l_rule_type := g_p_trading_partner;

   open c_rule_info (l_rule_type, p_transaction_type);
   fetch c_rule_info into l_rule_id, l_action_code;

   if c_rule_info%NOTFOUND then
      raise no_process_rule_info;
   end if;
   close c_rule_info;

 if ec_debug.G_debug_level =3 then
   ec_debug.pl (3, 'rule_type', l_rule_type);
   ec_debug.pl (3, 'action_code', l_action_code);
 end if;

   xProgress := 'ECERULEB-20-1004';
   open c_ignore_flag (p_document_id, l_rule_id);
   fetch c_ignore_flag into l_ignore_flag;

   if c_ignore_flag%NOTFOUND then
      l_ignore_flag := 'N';
   end if;
   close c_ignore_flag;

  if ec_debug.G_debug_level =3 then
   ec_debug.pl (3, 'ignore_flag', l_ignore_flag);
  end if;


   xProgress := 'ECERULEB-20-1010';
   Validate_Trading_Partner(p_transaction_type, p_address_type, p_level,
                            p_map_id, p_staging_tbl, l_tp_detail_id,
                            l_msg_text, l_valid_rule);

   if (l_action_code <> g_disabled and l_ignore_flag = 'N') then
      xProgress := 'ECERULEB-20-1020';
      Update_Status(p_transaction_type, p_level, l_valid_rule, l_action_code, NULL,
                    l_rule_id, p_stage_id, p_document_id, l_violation_level,
                    p_document_number, l_msg_text);
   end if;

   if (l_tp_detail_id <> -1) then
      xProgress := 'ECERULEB-20-1030';
      l_rule_type := g_p_test_prod;
      open c_rule_info (l_rule_type, p_transaction_type);
      fetch c_rule_info into l_rule_id, l_action_code;

      if c_rule_info%NOTFOUND then
         raise no_process_rule_info;
      end if;
      close c_rule_info;

   if ec_debug.G_debug_level =3 then
      ec_debug.pl (3, 'rule_type', l_rule_type);
      ec_debug.pl (3, 'action_code', l_action_code);
   end if;

      xProgress := 'ECERULEB-20-1040';
      open c_ignore_flag (p_document_id, l_rule_id);
      fetch c_ignore_flag into l_ignore_flag;

      if c_ignore_flag%NOTFOUND then
         l_ignore_flag := 'N';
      end if;
      close c_ignore_flag;

   if ec_debug.G_debug_level =3 then
      ec_debug.pl (3, 'ignore_flag', l_ignore_flag);
   end if;

      if (l_action_code <> g_disabled and l_ignore_flag = 'N') then
         xProgress := 'ECERULEB-20-1050';
         Validate_Test_Prod (l_tp_detail_id, p_level, p_staging_tbl,
                             l_msg_text, l_valid_rule);

         xProgress := 'ECERULEB-20-1060';
         Update_Status(p_transaction_type, p_level, l_valid_rule, l_action_code,
                       NULL, l_rule_id, p_stage_id, p_document_id,
                       l_violation_level, p_document_number, l_msg_text);

      end if;
   end if;

   if (fnd_api.to_boolean(p_simulate)) then
      null;
   elsif (fnd_api.to_boolean(p_commit)) then
      commit work;
   end if;

   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.count_and_get(p_count => x_msg_count,
                             p_data  => x_msg_data);
  if ec_debug.G_debug_level >= 2 then
   ec_debug.pop ('ECE_RULES_PKG.VALIDATE_PROCESS_RULES');
  end if;

EXCEPTION
   WHEN fnd_api.g_exc_error then
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
      ec_debug.pop ('ECE_RULES_PKG.VALIDATE_PROCESS_RULES');

   WHEN fnd_api.g_exc_unexpected_error then
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
      ec_debug.pop ('ECE_RULES_PKG.VALIDATE_PROCESS_RULES');

   WHEN no_process_rule_info then
      if (c_rule_info%ISOPEN) then
         close c_rule_info;
      end if;
      ec_debug.pl (0, 'EC', 'ECE_NO_PROCESS_RULE',
                   'TRANSACTION_TYPE', p_transaction_type,
                   'RULE_TYPE', l_rule_type);
      x_return_status := fnd_api.g_ret_sts_error;
      ec_debug.pop ('ECE_RULES_PKG.VALIDATE_PROCESS_RULES');

   WHEN OTHERS THEN
      if (c_rule_info%ISOPEN) then
        close c_rule_info;
      end if;
      if (c_ignore_flag%ISOPEN) then
         close c_ignore_flag;
      end if;
      ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR','PROGRESS_LEVEL', xProgress);
      ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
         fnd_msg_pub.add_exc_msg(g_file_name, g_pkg_name, l_api_name);
      end if;
      fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
      ec_debug.pop ('ECE_RULES_PKG.VALIDATE_PROCESS_RULES');

END Validate_Process_Rules;


PROCEDURE Validate_Trading_Partner(
   p_transaction_type    IN      VARCHAR2,
   p_address_type        IN      VARCHAR2,
   p_level               IN      NUMBER,
   p_map_id              IN      NUMBER,
   p_staging_tbl         IN      ec_utils.mapping_tbl,
   x_tp_detail_id        OUT NOCOPY    NUMBER,
   x_msg_text            OUT NOCOPY    VARCHAR2,
   x_valid_rule          OUT NOCOPY    VARCHAR2) IS

   xProgress                     VARCHAR2(80);
   n_location_code_pos           NUMBER;
   n_translator_code_pos         NUMBER;
   l_location_code               VARCHAR2(35);
   l_translator_code             ece_tp_details.translator_code%TYPE;
   l_map_code                    ece_mappings.map_code%TYPE;
   loop_count            NUMBER:=0;
   n_org_id                      NUMBER;
   l_org_id                      NUMBER ;
   l_edi_flag                    VARCHAR2(1);

   /* bug 2151462: Modified the cursors to refer to base tables */

   CURSOR c_cust_addr IS
   select td.tp_detail_id,
          nvl(td.edi_flag,'N')
   from   ece_tp_details td,
          hz_cust_acct_sites_all   ra
   where  td.translator_code       = l_translator_code and
          ra.ece_tp_location_code  = l_location_code and
          ra.tp_header_id          = td.tp_header_id and
          td.document_id           = p_transaction_type and
          td.map_id                = p_map_id   and
          nvl(ra.org_id,-99)       = nvl(l_org_id,nvl(ra.org_id,-99)) and
          nvl(ra.status,'ZZ')      = 'A'; -- fix for bug 6401982
          --rownum                   = 1;

   CURSOR c_supplier_addr IS
   select td.tp_detail_id,
          nvl(td.edi_flag,'N')
   from   ece_tp_details td,
          po_vendor_sites_all pvs
   where  td.translator_code       = l_translator_code and
          pvs.ece_tp_location_code = l_location_code and
          pvs.tp_header_id         = td.tp_header_id and
          td.document_id           = p_transaction_type and
          td.map_id                = p_map_id   and
          nvl(pvs.org_id,-99)      = nvl(l_org_id,nvl(pvs.org_id,-99));
          --rownum                   = 1;

   CURSOR c_bank_addr IS
   select td.tp_detail_id,
          nvl(td.edi_flag,'N')
   from   ece_tp_details td,
          ce_bank_branches_v cbb,
          hz_contact_points hcp
   where  td.translator_code           = l_translator_code and
          hcp.edi_ece_tp_location_code = l_location_code and
          hcp.edi_tp_header_id         = td.tp_header_id and
          hcp.owner_table_id           = cbb.branch_party_id and
          hcp.owner_table_name         = 'HZ_PARTIES' and
          hcp.contact_point_type       = 'EDI' and
          td.document_id               = p_transaction_type and
          td.map_id                    = p_map_id  ;
          --rownum                   = 1;

   CURSOR c_hr_addr IS
   select td.tp_detail_id,
          nvl(td.edi_flag,'N')
   from   ece_tp_details td,
          hr_locations hrl
   where  td.translator_code       = l_translator_code and
          hrl.ece_tp_location_code = l_location_code and
          hrl.tp_header_id         = td.tp_header_id and
          td.document_id           = p_transaction_type and
          td.map_id                = p_map_id ;
          --rownum                   = 1;

BEGIN
  if ec_debug.G_debug_level >= 2 then
   ec_debug.push ('ECE_RULES_PKG.VALIDATE_TRADING_PARTNER');
   ec_debug.pl (3, 'p_transaction_type', p_transaction_type);
   ec_debug.pl (3, 'p_address_type', p_address_type);
   ec_debug.pl (3, 'p_level', p_level);
   ec_debug.pl (3, 'p_map_id', p_map_id);
 end if;

   xProgress := 'ECERULEB-30-1000';
   x_msg_text := NULL;
   x_valid_rule := 'Y';

   ec_utils.find_pos (
      1,
      'TP_LOCATION_CODE',
      n_location_code_pos);

   xProgress := 'ECERULEB-30-1010';
   ec_utils.find_pos (
      1,
      'TP_TRANSLATOR_CODE',
      n_translator_code_pos);

   xProgress := 'ECERULEB-30-1010';
   ec_utils.find_pos (
      1,
      'ORG_ID',
      n_org_id);

   --bug 2151462

   xProgress := 'ECERULEB-30-1020';
   l_location_code := p_staging_tbl (n_location_code_pos).value;
   l_translator_code := p_staging_tbl (n_translator_code_pos).value;
   translator_code := l_translator_code;
   l_org_id :=  p_staging_tbl (n_org_id).value;

  if ec_debug.G_debug_level =3 then
   ec_debug.pl (3, 'translator_code', l_translator_code);
   ec_debug.pl (3, 'location_code', l_location_code);
   ec_debug.pl (3, 'org_id', l_org_id);
  end if;

   if (p_address_type = g_customer) then

      xProgress := 'ECERULEB-30-1030';
      open c_cust_addr;
      loop
        fetch c_cust_addr into x_tp_detail_id, l_edi_flag;
        /*if c_cust_addr%NOTFOUND then
         x_tp_detail_id := -1;
     exit;
        end if; */
    exit when c_cust_addr%NOTFOUND;
    loop_count := loop_count + 1;
      end loop;
      close c_cust_addr;

   elsif (p_address_type = g_supplier) then
      xProgress := 'ECERULEB-30-1040';
      open c_supplier_addr;
      loop
        fetch c_supplier_addr into x_tp_detail_id, l_edi_flag;
        /*if c_supplier_addr%NOTFOUND then
         x_tp_detail_id := -1;
     exit;
        end if; */
        exit when c_supplier_addr%NOTFOUND;
    loop_count := loop_count + 1;
      end loop;
      close c_supplier_addr;

   elsif (p_address_type = g_bank) then
      xProgress := 'ECERULEB-30-1050';
      open c_bank_addr;
      loop
        fetch c_bank_addr into x_tp_detail_id, l_edi_flag;
        /*if c_bank_addr%NOTFOUND then
         x_tp_detail_id := -1;
     exit;
        end if; */
    exit when c_bank_addr%NOTFOUND;
    loop_count := loop_count + 1;
      end loop;
      close c_bank_addr;

   elsif (p_address_type = g_hr_location) then
      xProgress := 'ECERULEB-30-1060';
      open c_hr_addr;
      loop
        fetch c_hr_addr into x_tp_detail_id, l_edi_flag;
        /*if c_hr_addr%NOTFOUND then
         x_tp_detail_id := -1;
     exit;
        end if; */
    exit when c_hr_addr%NOTFOUND;
    loop_count := loop_count + 1;
      end loop;
      close c_hr_addr;

   else
      xProgress := 'ECERULEB-30-1070';
      x_tp_detail_id := -1;
   end if;

 if ec_debug.G_debug_level =3 then
   ec_debug.pl (3, 'loop_count', loop_count);
 end if;

   if (loop_count =  0) then
      xProgress := 'ECERULEB-30-1080';
      x_valid_rule := 'N';

      /*select map_code into l_map_code
      from ece_mappings
      where map_id = p_map_id;
      bug 2151462 */

      fnd_message.set_name ('EC', 'ECE_TP_NOT_FOUND');
      fnd_message.set_token ('TRANSLATOR_CODE', l_translator_code);
      fnd_message.set_token ('LOCATION_CODE', l_location_code);
      fnd_message.set_token ('TRANSACTION_TYPE', p_transaction_type);
      fnd_message.set_token ('ORG_ID', to_char(l_org_id));
      x_msg_text := fnd_message.get;
      ec_debug.pl (0, x_msg_text);
   elsif loop_count > 1 then  --bug2151462

      xProgress := 'ECERULEB-30-1090';
      x_valid_rule := 'N';
      fnd_message.set_name ('EC', 'ECE_MULTIPLE_TP_FOUND');
      fnd_message.set_token ('TRANSLATOR_CODE', l_translator_code);
      fnd_message.set_token ('LOCATION_CODE', l_location_code);
      fnd_message.set_token ('TRANSACTION_TYPE', p_transaction_type);
      fnd_message.set_token ('ORG_ID', to_char(l_org_id));
      x_msg_text := fnd_message.get;
      ec_debug.pl (0, x_msg_text);
   elsif loop_count = 1  and l_edi_flag = 'N' then

      xProgress := 'ECERULEB-30-1090';
      x_valid_rule := 'N';
      fnd_message.set_name ('EC', 'ECE_TP_NOT_ENABLED');
      fnd_message.set_token ('TRANSLATOR_CODE', l_translator_code);
      fnd_message.set_token ('LOCATION_CODE', l_location_code);
      fnd_message.set_token ('TRANSACTION_TYPE', p_transaction_type);
      fnd_message.set_token ('ORG_ID', to_char(l_org_id));
      x_msg_text := fnd_message.get;
      ec_debug.pl (0, x_msg_text);
   end if;

 if ec_debug.G_debug_level >= 2 then
   ec_debug.pl (3, 'x_msg_text', x_msg_text);
   ec_debug.pl (3, 'x_valid_rule', x_valid_rule);
   ec_debug.pop ('ECE_RULES_PKG.VALIDATE_TRADING_PARTNER');
 end if;

EXCEPTION
   WHEN OTHERS THEN
     if (c_cust_addr%ISOPEN) then
        close c_cust_addr;
     end if;
     if (c_supplier_addr%ISOPEN) then
        close c_supplier_addr;
     end if;
     if (c_bank_addr%ISOPEN) then
        close c_bank_addr;
     end if;
     if (c_hr_addr%ISOPEN) then
        close c_hr_addr;
     end if;

     ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR','PROGRESS_LEVEL',xProgress);
     ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
     ec_debug.pop ('ECE_RULES_PKG.VALIDATE_TRADING_PARTNER');
     raise fnd_api.g_exc_unexpected_error;

END Validate_Trading_Partner;


PROCEDURE Validate_Test_Prod(
   p_tp_detail_id        IN      NUMBER,
   p_level               IN      NUMBER,
   p_staging_tbl         IN      ec_utils.mapping_tbl,
   x_msg_text            OUT NOCOPY    VARCHAR2,
   x_valid_rule          OUT NOCOPY    VARCHAR2) IS

   xProgress                     VARCHAR2(80);
   n_test_flag_pos               NUMBER;
   l_file_test_flag              ece_tp_details.test_flag%TYPE;
   l_setup_test_flag             ece_tp_details.test_flag%TYPE;
   no_row_selected               EXCEPTION;

   CURSOR c_test_flag IS
   select test_flag
   from   ece_tp_details
   where  tp_detail_id = p_tp_detail_id and
          rownum       = 1;

BEGIN
  if ec_debug.G_debug_level >= 2 then
   ec_debug.push ('ECE_RULES_PKG.VALIDATE_TEST_PROD');
   ec_debug.pl (3, 'p_tp_detail_id', p_tp_detail_id);
   ec_debug.pl (3, 'p_level', p_level);
 end if;

   xProgress := 'ECERULEB-40-1000';
   x_msg_text := NULL;
   x_valid_rule := 'Y';

   ec_utils.find_pos (
      1,
      'TEST_INDICATOR',
      n_test_flag_pos);

   l_file_test_flag := p_staging_tbl (n_test_flag_pos).value;

  if ec_debug.G_debug_level = 3 then
   ec_debug.pl (3, 'file_test_flag', l_file_test_flag);
  end if;

   xProgress := 'ECERULEB-40-1010';
   open c_test_flag;
   fetch c_test_flag into l_setup_test_flag;
   if c_test_flag%NOTFOUND then
      raise no_row_selected;
   end if;
   close c_test_flag;

   ec_debug.pl (3, 'setup_test_flag', l_setup_test_flag);

   if (l_file_test_flag <> l_setup_test_flag) or
      (l_file_test_flag is null) or
      (l_setup_test_flag is null) then
      xProgress := 'ECERULEB-40-1020';
      x_valid_rule := 'N';
      fnd_message.set_name ('EC', 'ECE_TEST_PROD');
      x_msg_text := fnd_message.get;
      ec_debug.pl (0, x_msg_text);
   end if;

 if ec_debug.G_debug_level >= 2 then
   ec_debug.pl (3, 'x_msg_text', x_msg_text);
   ec_debug.pl (3, 'x_valid_rule', x_valid_rule);
   ec_debug.pop ('ECE_RULES_PKG.VALIDATE_TEST_PROD');
 end if;
EXCEPTION
   WHEN no_row_selected then
     if (c_test_flag%ISOPEN) then
        close c_test_flag;
     end if;
     ec_debug.pl (0, 'EC', 'ECE_NO_ROW_SELECTED',
                  'PROGRESS_LEVEL', xProgress,
                  'INFO', 'TEST_FLAG',
                  'TABLE_NAME', 'ECE_TP_DETAILS');
     ec_debug.pop ('ECE_RULES_PKG.VALIDATE_TEST_PROD');
     raise fnd_api.g_exc_error;

   WHEN OTHERS THEN
     if (c_test_flag%ISOPEN) then
        close c_test_flag;
     end if;
     ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR','PROGRESS_LEVEL', xProgress);
     ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
     ec_debug.pop ('ECE_RULES_PKG.VALIDATE_TEST_PROD');
     raise fnd_api.g_exc_unexpected_error;

END Validate_Test_Prod;


PROCEDURE Validate_Column_Rules(
   p_api_version_number  IN      NUMBER,
   p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
   p_simulate            IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status       OUT  NOCOPY   VARCHAR2,
   x_msg_count           OUT  NOCOPY   NUMBER,
   x_msg_data            OUT  NOCOPY   VARCHAR2,
   p_transaction_type    IN      VARCHAR2,
   p_stage_id            IN      NUMBER,
   p_document_id         IN      NUMBER,
   p_document_number     IN      VARCHAR2,
   p_level               IN      NUMBER,
   p_staging_tbl         IN OUT NOCOPY  ec_utils.mapping_tbl) IS

   l_api_name           CONSTANT VARCHAR2(30) := 'Validate_Column_Rules';
   l_api_version_number CONSTANT NUMBER       := 1.0;

   xProgress                     VARCHAR2(80);
   l_interface_column_id         NUMBER;
   l_interface_column_name       ece_interface_columns.interface_column_name%TYPE;
   l_interface_column_value      VARCHAR2(500);
   l_interface_column_datatype   ece_interface_columns.data_type%TYPE;
   l_rule_type                   ece_column_rules.rule_type%TYPE;
   l_rule_id                     NUMBER;
   l_action_code                 ece_column_rules.action_code%TYPE;
   l_valid_rule                  VARCHAR2(1):= 'Y';
   l_ignore_flag                 ece_rule_violations.ignore_flag%TYPE;
   l_violation_level             VARCHAR2(10):= g_column_rule;
   l_msg_text                    ece_rule_violations.message_text%TYPE;
   l_existing_rule               VARCHAR2(1) := 'Y';
   l_temp_status                 VARCHAR2(10);
   i                             pls_integer;       -- Bug 2708573

  /* Bug 2708573
   CURSOR c_col_rule_info (
          p_interface_column_id  NUMBER) IS
   select column_rule_id, rule_type, action_code
   from   ece_column_rules
   where  interface_column_id = p_interface_column_id
   order  by sequence;
  */

  /* CURSOR c_ignore_flag (
          p_document_id          NUMBER,
          p_interface_column_id  NUMBER,
          p_stage_id             NUMBER,
          p_rule_id              NUMBER) IS
   select ignore_flag
   from   ece_rule_violations
   where  document_id         = p_document_id         and
          interface_column_id = p_interface_column_id and
          stage_id            = p_stage_id            and
          rule_id             = p_rule_id             and
          violation_level     = l_violation_level; */

BEGIN
  if ec_debug.G_debug_level >= 2 then
   ec_debug.push ('ECE_RULES_PKG.VALIDATE_COLUMN_RULES');
   ec_debug.pl (3, 'p_transaction_type', p_transaction_type);
   ec_debug.pl (3, 'p_stage_id', p_stage_id);
   ec_debug.pl (3, 'p_document_id', p_document_id);
   ec_debug.pl (3, 'p_document_number', p_document_number);
   ec_debug.pl (3, 'p_level', p_level);
  end if;

   -- Standard call to check for call compatibility.
   if not fnd_api.compatible_api_call (l_api_version_number,
                                       p_api_version_number, l_api_name,
                                       g_pkg_name) then
      raise fnd_api.g_exc_unexpected_error;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   if fnd_api.to_boolean(p_init_msg_list) then
      fnd_msg_pub.initialize;
   end if;

   -- Initialize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;

   xProgress := 'ECERULEB-50-1000';

  /* bug 2500898
   for i in 1..p_staging_tbl.count loop
   for i in ec_utils.g_ext_levels(p_level).file_start_pos..ec_utils.g_ext_levels(p_level).file_end_pos
  */

   -- Bug 2708573
   -- Replaced the above for loop with while loop.
   i:= ec_utils.g_column_rule_tbl.FIRST;
   while i <> ec_utils.g_column_rule_tbl.LAST
   loop

      -- Bug 1853627  Added a check on the column_rule_flag in the following condition

      -- Bug 2708573
      -- if (p_staging_tbl(i).external_level = p_level AND p_staging_tbl(i).column_rule_flag ='Y') then

      if (ec_utils.g_column_rule_tbl(i).level = p_level) then

            xProgress := 'ECERULEB-50-1010';
            l_interface_column_id := p_staging_tbl(i).interface_column_id;
            l_interface_column_name := p_staging_tbl(i).interface_column_name;
            l_interface_column_datatype := p_staging_tbl(i).data_type;

            if ec_debug.G_debug_level = 3 then
             ec_debug.pl (3, 'interface_column_id', l_interface_column_id);
             ec_debug.pl (3, 'interface_column_name', l_interface_column_name);
             ec_debug.pl (3, 'interface_column_datatype', l_interface_column_datatype);
            end if;

        /* Bug 2708573
             open c_col_rule_info (l_interface_column_id);
             loop

             xProgress := 'ECERULEB-50-1030';
             fetch c_col_rule_info into l_rule_id, l_rule_type, l_action_code;
             exit when c_col_rule_info%NOTFOUND;
        */

            xProgress := 'ECERULEB-50-1020';
        l_rule_id    :=ec_utils.g_column_rule_tbl(i).column_rule_id;
            l_rule_type  :=ec_utils.g_column_rule_tbl(i).rule_type;
            l_action_code:=ec_utils.g_column_rule_tbl(i).action_code;

            if ec_debug.G_debug_level = 3 then
             ec_debug.pl (3, 'rule_id', l_rule_id);
             ec_debug.pl (3, 'rule_type', l_rule_type);
             ec_debug.pl (3, 'action_code', l_action_code);
            end if;

            xProgress := 'ECERULEB-50-1040';
            /* open c_ignore_flag (p_document_id, l_interface_column_id, p_stage_id, l_rule_id);

            xProgress := 'ECERULEB-50-1050';
            fetch c_ignore_flag into l_ignore_flag;
            if c_ignore_flag%NOTFOUND then
               l_ignore_flag := 'N';
            end if;

            if ec_debug.G_debug_level = 3 then
               ec_debug.pl (3, 'ignore_flag', l_ignore_flag);
            end if; */
            l_ignore_flag := 'N';
        for i in 1 .. ece_inbound.g_col_rule_viol_tbl.count
        loop
          if (ece_inbound.g_col_rule_viol_tbl(i).stage_id = p_stage_id) and
             (ece_inbound.g_col_rule_viol_tbl(i).rule_id = l_rule_id) and
         (ece_inbound.g_col_rule_viol_tbl(i).interface_col_id =  l_interface_column_id)then
                   l_ignore_flag := 'Y';
           exit;
          end if;
            end loop;




            l_interface_column_value := p_staging_tbl(i).value;

            if ec_debug.G_debug_level = 3 then
               ec_debug.pl (3, 'interface_column_value', l_interface_column_value);
            end if;

            if (l_action_code <> g_disabled and l_ignore_flag = 'N') then
               if (l_rule_type = g_c_value_required) then

                  xProgress := 'ECERULEB-50-1060';
                  Value_Required_Rule (l_interface_column_name,
                                       l_interface_column_value, l_valid_rule,
                                       l_msg_text);

               elsif (l_rule_type = g_c_simple_lookup) then

                  xProgress := 'ECERULEB-50-1070';
                  Simple_Lookup_Rule (l_interface_column_name,
                                      l_interface_column_value, l_rule_id,
                                      l_valid_rule, l_msg_text);

               elsif (l_rule_type = g_c_valueset) then

                  xProgress := 'ECERULEB-50-1080';
                  Valueset_Rule (l_interface_column_name,
                                 l_interface_column_value, l_rule_id,
                                 l_valid_rule, l_msg_text);

               elsif (l_rule_type = g_c_null_dependency) then

                  xProgress := 'ECERULEB-50-1090';
                  Null_Dependency_Rule (l_interface_column_name,
                                        l_interface_column_value, l_rule_id,
                                        p_staging_tbl, p_level,
                                        l_valid_rule, l_msg_text);

               elsif (l_rule_type = g_c_predefined_list) then

                  xProgress := 'ECERULEB-50-1100';
                  Predefined_List_Rule (l_interface_column_name,
                                        l_interface_column_value, l_rule_id,
                                        l_valid_rule, l_msg_text);

               elsif (l_rule_type = g_c_null_default) then

                  xProgress := 'ECERULEB-50-1110';
                  Null_Default_Rule (l_interface_column_name,
                                     l_interface_column_value, l_rule_id,
                                     p_level, p_staging_tbl,
                                     l_valid_rule, l_msg_text);

               elsif (l_rule_type = g_c_datatype_checking) then

                  xProgress := 'ECERULEB-50-1120';
                  Datatype_Checking_Rule (l_interface_column_datatype,
                                          l_interface_column_name,
                                          l_interface_column_value,
                                          l_valid_rule, l_msg_text);

               else

                  xProgress := 'ECERULEB-50-1130';
                  ec_debug.pl(0, 'EC', 'ECE_INVALID_RULE_TYPE',
                              'RULE_TYPE', l_rule_type);
                  l_existing_rule := 'N';
               end if;

               if (l_existing_rule = 'Y') then

                  xProgress := 'ECERULEB-50-1140';
                  Update_Status(p_transaction_type, p_level, l_valid_rule,
                                l_action_code, l_interface_column_id, l_rule_id,
                                p_stage_id, p_document_id, l_violation_level,
                                p_document_number, l_msg_text);

               end if;

            end if;

            xProgress := 'ECERULEB-50-1150';
           -- close c_ignore_flag;

     /* Bug 2708573
         end loop;
         close c_col_rule_info;
    */

      end if;

      xProgress := 'ECERULEB-50-1160';
      i := ec_utils.g_column_rule_tbl.NEXT(i);          -- Bug 2708573

   end loop;

   if (fnd_api.to_boolean(p_simulate)) then
      null;
   elsif (fnd_api.to_boolean(p_commit)) then
      commit work;
   end if;

   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.count_and_get(p_count => x_msg_count,
                             p_data  => x_msg_data);

  if ec_debug.G_debug_level = 3 then
   ec_debug.pl (3, 'x_return_status', x_return_status);
   ec_debug.pop ('ECE_RULES_PKG.VALIDATE_COLUMN_RULES');
  end if;

EXCEPTION
   WHEN fnd_api.g_exc_error then
     /* Bug 2708573
     if (c_col_rule_info%ISOPEN) then
        close c_col_rule_info;
      end if;
     */
--     if (c_ignore_flag%ISOPEN) then
 --       close c_ignore_flag;
   --   end if;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
      ec_debug.pop ('ECE_RULES_PKG.VALIDATE_COLUMN_RULES');

   WHEN fnd_api.g_exc_unexpected_error then
     /* Bug 2708573
      if (c_col_rule_info%ISOPEN) then
        close c_col_rule_info;
      end if;
     */

/*      if (c_ignore_flag%ISOPEN) then
         close c_ignore_flag;
      end if; */
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
      ec_debug.pop ('ECE_RULES_PKG.VALIDATE_COLUMN_RULES');

   WHEN OTHERS THEN
     /* Bug 2708573
      if (c_col_rule_info%ISOPEN) then
        close c_col_rule_info;
      end if;
     */

/*      if (c_ignore_flag%ISOPEN) then
         close c_ignore_flag;
      end if; */
      ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR','PROGRESS_LEVEL', xProgress);
      ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
         fnd_msg_pub.add_exc_msg(g_file_name, g_pkg_name, l_api_name);
      end if;
      fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
      ec_debug.pop ('ECE_RULES_PKG.VALIDATE_COLUMN_RULES');

END Validate_Column_Rules;


PROCEDURE Value_Required_Rule (
   p_column_name         IN      VARCHAR2,
   p_column_value        IN      VARCHAR2,
   x_valid_rule          OUT NOCOPY    VARCHAR2,
   x_msg_text            OUT NOCOPY    VARCHAR2) IS


   xProgress                     VARCHAR2(80);

BEGIN
  if ec_debug.G_debug_level >= 2 then
   ec_debug.push ('ECE_RULES_PKG.VALUE_REQUIRED_RULE');
   ec_debug.pl (3, 'p_column_name', p_column_name);
   ec_debug.pl (3, 'p_column_value', p_column_value);
  end if;

   xProgress := 'ECERULEB-60-1000';
   x_msg_text := NULL;
   x_valid_rule := 'Y';

   if (p_column_value is NULL) then
      xProgress := 'ECERULEB-60-1010';
      x_valid_rule := 'N';
      fnd_message.set_name ('EC', 'ECE_VALUE_REQUIRED');
      fnd_message.set_token ('COLUMN_NAME', p_column_name);
      x_msg_text := fnd_message.get;
      ec_debug.pl (0, x_msg_text);
   end if;

 if ec_debug.G_debug_level >= 2 then
   ec_debug.pl (3, 'x_valid_rule', x_valid_rule);
   ec_debug.pl (3, 'x_msg_text', x_msg_text);
   ec_debug.pop ('ECE_RULES_PKG.VALUE_REQUIRED_RULE');
 end if;

EXCEPTION
   WHEN OTHERS THEN
     ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR','PROGRESS_LEVEL', xProgress);
     ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
     ec_debug.pop ('ECE_RULES_PKG.VALUE_REQUIRED_RULE');
     raise fnd_api.g_exc_unexpected_error;

END Value_Required_Rule;


PROCEDURE Simple_Lookup_Rule (
   p_column_name       IN      VARCHAR2,
   p_column_value      IN      VARCHAR2,
   p_rule_id           IN      NUMBER,
   x_valid_rule        OUT NOCOPY     VARCHAR2,
   x_msg_text          OUT NOCOPY    VARCHAR2) IS

   xProgress                   VARCHAR2(80);
   l_column                    ece_rule_simple_lookup.lookup_column%TYPE;
   l_table                     ece_rule_simple_lookup.lookup_table%TYPE;
   l_where_clause              ece_rule_simple_lookup.lookup_where_clause%TYPE;
   l_select                    VARCHAR2(32000);
   l_from                      VARCHAR2(32000);
   l_where                     VARCHAR2(32000);
   l_sel_c                     INTEGER;
   l_match_column              NUMBER;
   l_dummy                     INTEGER;

   CURSOR c_simple_lookup_rule IS
   select lookup_column, lookup_table, lookup_where_clause
   from   ece_rule_simple_lookup
   where  column_rule_id = p_rule_id;

BEGIN

  if ec_debug.G_debug_level >= 2 then
   ec_debug.push ('ECE_RULES_PKG.SIMPLE_LOOKUP_RULE');
   ec_debug.pl (3, 'p_column_name', p_column_name);
   ec_debug.pl (3, 'p_column_value', p_column_value);
   ec_debug.pl (3, 'p_rule_id', p_rule_id);
 end if;

   xProgress := 'ECERULEB-70-1000';

   x_msg_text := NULL;
   x_valid_rule := 'Y';
   l_column := NULL;
   l_table  := NULL;
   l_where_clause := NULL;

   xProgress := 'ECERULEB-70-1010';
   open c_simple_lookup_rule;
   fetch c_simple_lookup_rule into l_column, l_table, l_where_clause;
   close c_simple_lookup_rule;

 if ec_debug.G_debug_level = 3 then
   ec_debug.pl (3, 'lookup_table', l_table);
   ec_debug.pl (3, 'lookup_column', l_column);
   ec_debug.pl (3, 'lookup_where_clause', l_where_clause);
 end if;

   xProgress := 'ECERULEB-70-1020';
   l_select := ' SELECT count(*)';
   l_from   := ' FROM ' || l_table;
   l_where  := ' WHERE ' || l_column || '= ' || ':l_p_column_value';

   if (l_where_clause is not null) then
      xProgress := 'ECERULEB-70-1030';
      l_where :=  l_where || ' AND ' || l_where_clause;
   end if;

   xProgress := 'ECERULEB-70-1040';
   l_select := l_select || l_from || l_where;

  if ec_debug.G_debug_level = 3 then
   ec_debug.pl (3, l_select);
  end if;

   xProgress := 'ECERULEB-70-1050';
   l_sel_c := dbms_sql.open_cursor;

   BEGIN
      xProgress := 'ECERULEB-70-1060';
      dbms_sql.parse (l_sel_c, l_select, dbms_sql.native);
   EXCEPTION
      WHEN OTHERS then
         ece_error_handling_pvt.print_parse_error
            ( dbms_sql.last_error_position, l_select);
         raise;
   END;

   xProgress := 'ECERULEB-70-1070';
   dbms_sql.define_column(l_sel_c, 1, l_match_column);

   xProgress := 'ECERULEB-70-1075';
   dbms_sql.bind_variable(l_sel_c,'l_p_column_value',p_column_value);

   xProgress := 'ECERULEB-70-1080';
   l_dummy := dbms_sql.execute(l_sel_c);

   if (dbms_sql.fetch_rows(l_sel_c) > 0) then
      xProgress := 'ECERULEB-70-1090';
      dbms_sql.column_value (l_sel_c, 1, l_match_column);
      if (l_match_column = 0) then
         xProgress := 'ECERULEB-70-1100';
         x_valid_rule := 'N';
      end if;
   end if;

   xProgress := 'ECERULEB-70-1110';
   dbms_sql.close_cursor (l_sel_c);

   if (x_valid_rule = 'N') then
      xProgress := 'ECERULEB-70-1120';
      fnd_message.set_name ('EC', 'ECE_SIMPLE_LOOKUP');
      fnd_message.set_token ('COLUMN_NAME', p_column_name);
      fnd_message.set_token ('COLUMN_VALUE', p_column_value);
      fnd_message.set_token ('LOOKUP_SELECT', l_select);
      x_msg_text := fnd_message.get;
      ec_debug.pl (0, x_msg_text);
   end if;

 if ec_debug.G_debug_level >= 2 then
   ec_debug.pl (3, 'x_valid_rule', x_valid_rule);
   ec_debug.pl (3, 'x_msg_text', x_msg_text);
   ec_debug.pop ('ECE_RULES_PKG.SIMPLE_LOOKUP_RULE');
 end if;

EXCEPTION
   WHEN OTHERS THEN
     if (c_simple_lookup_rule%ISOPEN) then
        close c_simple_lookup_rule;
     end if;
     if (dbms_sql.is_open(l_sel_c)) then
        dbms_sql.close_cursor (l_sel_c);
     end if;
     ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR','PROGRESS_LEVEL', xProgress);
     ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
     ec_debug.pop ('ECE_RULES_PKG.SIMPLE_LOOKUP_RULE');
     raise fnd_api.g_exc_unexpected_error;

END Simple_Lookup_Rule;


PROCEDURE Valueset_Rule (
   p_column_name         IN      VARCHAR2,
   p_column_value        IN      VARCHAR2,
   p_rule_id             IN      NUMBER,
   x_valid_rule          OUT NOCOPY    VARCHAR2,
   x_msg_text            OUT NOCOPY    VARCHAR2) IS

   xProgress                     VARCHAR2(80);
   l_valueset_name               ece_rule_valueset.valueset_name%TYPE;
   l_valueset_id                 NUMBER := -1;
   l_valueset                    fnd_vset.valueset_r;
   l_format                      fnd_vset.valueset_dr;
   l_rowcount                    NUMBER;
   l_value                       fnd_vset.value_dr;

   found                         BOOLEAN;
   match                         BOOLEAN := false;
   no_value_set                  EXCEPTION;

   CURSOR c_valueset IS
   select valueset_name
   from   ece_rule_valueset
   where  column_rule_id = p_rule_id;

   CURSOR c_flex_valueset_id IS
   select flex_value_set_id
   from   fnd_flex_value_sets
   where  flex_value_set_name = l_valueset_name;

BEGIN
 if ec_debug.G_debug_level >= 2 then
   ec_debug.push ('ECE_RULES_PKG.VALUESET_RULE');
   ec_debug.pl (3, 'p_column_name', p_column_name);
   ec_debug.pl (3, 'p_column_value', p_column_value);
   ec_debug.pl (3, 'p_rule_id', p_rule_id);
 end if;

   xProgress := 'ECERULEB-80-1000';
   x_msg_text := NULL;
   x_valid_rule := 'Y';

   open c_valueset;
   fetch c_valueset into l_valueset_name;
   close c_valueset;

 if ec_debug.G_debug_level = 3 then
   ec_debug.pl (3, 'valueset_name', l_valueset_name);
 end if;

   xProgress := 'ECERULEB-80-1010';
   open c_flex_valueset_id;

   xProgress := 'ECERULEB-80-1020';
   fetch c_flex_valueset_id into l_valueset_id;
 if ec_debug.G_debug_level = 3 then
   ec_debug.pl (3, 'valueset_id', l_valueset_id);
 end if;

   if (c_flex_valueset_id%NOTFOUND) then
      raise no_value_set;
   end if;

   xProgress := 'ECERULEB-80-1030';
   close c_flex_valueset_id;

   xProgress := 'ECERULEB-80-1040';
   fnd_vset.get_valueset (l_valueset_id, l_valueset, l_format);

   xProgress := 'ECERULEB-80-1050';
   fnd_vset.get_value_init (l_valueset, TRUE);

   xProgress := 'ECERULEB-80-1060';
   fnd_vset.get_value (l_valueset, l_rowcount, found, l_value);

   while (found) loop
   if ec_debug.G_debug_level = 3 then
      ec_debug.pl (3, 'valueset_value', l_value.value);
   end if;

      if (p_column_value = l_value.value) then
         xProgress := 'ECERULEB-80-1070';
         match := true;
         exit;
      end if;

      xProgress := 'ECERULEB-80-1080';
      fnd_vset.get_value (l_valueset, l_rowcount, found, l_value);
   end loop;

   xProgress := 'ECERULEB-80-1090';
   if (match) then
      x_valid_rule := 'Y';
      ec_debug.pl (3, 'EC', 'ECE_VALUE_IN_VALUESET');
   else
      x_valid_rule := 'N';
      ec_debug.pl (3, 'EC', 'ECE_VALUE_NOT_IN_VALUESET');
   end if;

   xProgress := 'ECERULEB-80-1100';
   fnd_vset.get_value_end (l_valueset);

   if (x_valid_rule = 'N') then
      xProgress := 'ECERULEB-80-1110';
      fnd_message.set_name ('EC', 'ECE_VALUESET');
      fnd_message.set_token ('COLUMN_NAME', p_column_name);
      fnd_message.set_token ('COLUMN_VALUE', p_column_value);
      fnd_message.set_token ('VALUESET', l_valueset_name);
      x_msg_text := fnd_message.get;
      ec_debug.pl (0, x_msg_text);
   end if;

  if ec_debug.G_debug_level >= 2 then
   ec_debug.pl (3, 'x_valid_rule', x_valid_rule);
   ec_debug.pl (3, 'x_msg_text', x_msg_text);
   ec_debug.pop ('ECE_RULES_PKG.VALUESET_RULE');
 end if;

EXCEPTION
   WHEN no_value_set then
     if (c_valueset%ISOPEN) then
        close c_valueset;
     end if;
     if (c_flex_valueset_id%ISOPEN) then
        close c_flex_valueset_id;
     end if;
     ec_debug.pl (0, 'EC', 'ECE_VALUESET_NOT_FOUND',
                  'VALUESET', l_valueset_name);
     ec_debug.pop ('ECE_RULES_PKG.VALUESET_RULE');
     raise fnd_api.g_exc_error;

   WHEN OTHERS THEN
     if (c_valueset%ISOPEN) then
        close c_valueset;
     end if;
     if (c_flex_valueset_id%ISOPEN) then
        close c_flex_valueset_id;
     end if;
     ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR','PROGRESS_LEVEL', xProgress);
     ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
     ec_debug.pop ('ECE_RULES_PKG.VALUESET_RULE');
     raise fnd_api.g_exc_unexpected_error;

END Valueset_Rule;


PROCEDURE Null_Dependency_Rule (
   p_column_name         IN      VARCHAR2,
   p_column_value        IN      VARCHAR2,
   p_rule_id             IN      NUMBER,
   p_staging_tbl         IN      ec_utils.mapping_tbl,
   p_level               IN      NUMBER,
   x_valid_rule          OUT NOCOPY     VARCHAR2,
   x_msg_text            OUT NOCOPY    VARCHAR2) IS

   xProgress                     VARCHAR2(80);
   l_null_rule_id                NUMBER;
   l_comp_code                   ece_rule_null_dep.comparison_code%TYPE;
   l_rule_column                 ece_rule_null_dep_details.interface_column%TYPE;
   l_column_pos                  NUMBER;
   l_detail_comp_code            ece_rule_null_dep_details.comparison_code%TYPE;
   l_rule_value                  ece_rule_null_dep_details.value%TYPE;
   l_column_value                VARCHAR2(500);
   condition                     BOOLEAN := true;

   CURSOR c_null_dependency IS
   select null_dependency_rule_id, comparison_code
   from   ece_rule_null_dep
   where  column_rule_id = p_rule_id;

   CURSOR c_null_dependency_detail IS
   select interface_column, comparison_code, value
   from   ece_rule_null_dep_details
   where  null_dependency_rule_id = l_null_rule_id
   order by null_dependency_detail_id;

BEGIN
  if ec_debug.G_debug_level >= 2 then
   ec_debug.push ('ECE_RULES_PKG.NULL_DEPENDENCY_RULE');
   ec_debug.pl (3, 'p_column_name', p_column_name);
   ec_debug.pl (3, 'p_column_value', p_column_value);
   ec_debug.pl (3, 'p_rule_id', p_rule_id);
   ec_debug.pl (3, 'p_level', p_level);
 end if;

   xProgress := 'ECERULEB-90-1000';
   x_msg_text := NULL;
   x_valid_rule := 'Y';

   open c_null_dependency;
   fetch c_null_dependency into l_null_rule_id, l_comp_code;
   close c_null_dependency;

   if ec_debug.G_debug_level = 3 then
   ec_debug.pl (3, 'null_rule_id', l_null_rule_id);
   ec_debug.pl (3, 'comparison_code', l_comp_code);
  end if;


   xProgress := 'ECERULEB-90-1010';
   open c_null_dependency_detail;
   loop
      if (condition = true) then
         xProgress := 'ECERULEB-90-1020';
         fetch c_null_dependency_detail into l_rule_column, l_detail_comp_code,
               l_rule_value;
         exit when c_null_dependency_detail%NOTFOUND;

      if ec_debug.G_debug_level = 3 then
         ec_debug.pl (3, 'rule_column', l_rule_column);
         ec_debug.pl (3, 'detail_comparison_code', l_detail_comp_code);
         ec_debug.pl (3, 'rule_value', l_rule_value);
      end if;

         xProgress := 'ECERULEB-90-1030';
         ec_utils.find_pos (
            1,
            p_level,
            l_rule_column,
            l_column_pos);

         xProgress := 'ECERULEB-90-1040';
         l_column_value := p_staging_tbl(l_column_pos).value;

      if ec_debug.G_debug_level = 3 then
         ec_debug.pl (3, 'column_value', l_column_value);
      end if;

         if ((l_detail_comp_code = 'IS_NULL') and (l_column_value is NULL)) then
            condition := true;
         elsif ((l_detail_comp_code = 'IS_NOT_NULL') and
                (l_column_value is not NULL)) then
            condition := true;
         elsif ((l_detail_comp_code = 'EQUAL') and
                (l_column_value = l_rule_value)) then
            condition := true;
         else
            condition := false;
         end if;
        if ec_debug.G_debug_level = 3 then
         ec_debug.pl (3, 'condition', condition);
        end if;

      else
         xProgress := 'ECERULEB-90-1050';
         exit;
      end if;
   end loop;

   xProgress := 'ECERULEB-90-1060';
   close c_null_dependency_detail;

  if ec_debug.G_debug_level = 3 then
   ec_debug.pl (3, 'meet all conditions', condition);
  end if;

   if (condition) then

      xProgress := 'ECERULEB-90-1070';
      if ((l_comp_code = 'MUST_BE_NULL') and (p_column_value is NULL)) then
         xProgress := 'ECERULEB-90-1080';
         x_valid_rule := 'Y';

      elsif ((l_comp_code = 'CANNOT_BE_NULL') and
             (p_column_value is not null)) then
         xProgress := 'ECERULEB-90-1090';
         x_valid_rule := 'Y';

      else
         xProgress := 'ECERULEB-90-1100';
         x_valid_rule := 'N';
         fnd_message.set_name ('EC', 'ECE_NULL_DEPENDENCY');
         fnd_message.set_token ('COLUMN_NAME', p_column_name);
         fnd_message.set_token ('COMPARISON_CODE', l_comp_code);
         x_msg_text := fnd_message.get;
         ec_debug.pl (0, x_msg_text);
      end if;

   end if;

  if ec_debug.G_debug_level >= 2 then
   ec_debug.pl (3, 'x_valid_rule', x_valid_rule);
   ec_debug.pl (3, 'x_msg_text', x_msg_text);
   ec_debug.pop ('ECE_RULES_PKG.NULL_DEPENDENCY_RULE');
 end if;

EXCEPTION
   WHEN OTHERS THEN
     if (c_null_dependency%ISOPEN) then
        close c_null_dependency;
     end if;
     if (c_null_dependency_detail%ISOPEN) then
        close c_null_dependency_detail;
     end if;
     ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR','PROGRESS_LEVEL', xProgress);
     ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
     ec_debug.pop ('ECE_RULES_PKG.NULL_DEPENDENCY_RULE');
     raise fnd_api.g_exc_unexpected_error;

END Null_Dependency_Rule;


PROCEDURE Predefined_List_Rule (
   p_column_name         IN      VARCHAR2,
   p_column_value        IN      VARCHAR2,
   p_rule_id             IN      NUMBER,
   x_valid_rule          OUT NOCOPY    VARCHAR2,
   x_msg_text            OUT NOCOPY    VARCHAR2) IS

   xProgress                     VARCHAR2(80);
   l_list_rule_id                NUMBER;
   l_comp_code                   ece_rule_list.comparison_code%TYPE;
   l_match                       NUMBER;

   CURSOR c_predefined_list IS
   select list_rule_id, comparison_code
   from   ece_rule_list
   where  column_rule_id = p_rule_id;

   CURSOR c_list_count IS
   select count(*)
   from   ece_rule_list_details
   where  list_rule_id = l_list_rule_id and
          value = p_column_value;

BEGIN
  if ec_debug.G_debug_level >= 2 then
   ec_debug.push ('ECE_RULES_PKG.PREDEFINED_LIST_RULE');
   ec_debug.pl (3, 'p_column_name', p_column_name);
   ec_debug.pl (3, 'p_column_value', p_column_value);
   ec_debug.pl (3, 'p_rule_id', p_rule_id);
 end if;

   xProgress := 'ECERULEB-100-1000';
   x_msg_text := NULL;
   x_valid_rule := 'Y';

   open c_predefined_list;
   fetch c_predefined_list into l_list_rule_id, l_comp_code;
   close c_predefined_list;

   if ec_debug.G_debug_level =  3 then
   ec_debug.pl (3, 'list_rule_id', l_list_rule_id);
   ec_debug.pl (3, 'comparison_code', l_comp_code);
 end if;

   xProgress := 'ECERULEB-100-1000';
   open c_list_count;
   fetch c_list_count into l_match;
   close c_list_count;

  if ec_debug.G_debug_level = 3 then
   ec_debug.pl (3, 'match', l_match);
 end if;

   xProgress := 'ECERULEB-100-1010';
   if ((l_comp_code = 'MUST_EQUAL') and (l_match > 0)) then
      x_valid_rule := 'Y';
   elsif ((l_comp_code = 'CANNOT_EQUAL') and (l_match = 0)) then
      x_valid_rule := 'Y';
   else
      x_valid_rule := 'N';
   end if;

   if (x_valid_rule = 'N') then
      xProgress := 'ECERULEB-100-1020';
      fnd_message.set_name ('EC', 'ECE_PREDEFINED_LIST');
      fnd_message.set_token ('COLUMN_NAME', p_column_name);
      fnd_message.set_token ('VALUE', p_column_value);

      if (l_comp_code = 'MUST_EQUAL') then
         xProgress := 'ECERULEB-100-1030';
         fnd_message.set_token ('COMPARISON', 'MUST EXISTS');

      elsif (l_comp_code = 'CANNOT_EQUAL') then
         xProgress := 'ECERULEB-100-1040';
         fnd_message.set_token ('COMPARISON', 'CANNOT EXISTS');
      end if;
      x_msg_text := fnd_message.get;
      ec_debug.pl (0, x_msg_text);
   end if;

 if ec_debug.G_debug_level >= 2 then
   ec_debug.pl (3, 'x_valid_rule', x_valid_rule);
   ec_debug.pl (3, 'x_msg_text', x_msg_text);
   ec_debug.pop ('ECE_RULES_PKG.PREDEFINED_LIST_RULE');
 end if;

EXCEPTION
   WHEN OTHERS THEN
     if (c_predefined_list%ISOPEN) then
        close c_predefined_list;
     end if;
     if (c_list_count%ISOPEN) then
        close c_list_count;
     end if;
     ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR','PROGRESS_LEVEL', xProgress);
     ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
     ec_debug.pop ('ECE_RULES_PKG.PREDEFINED_LIST_RULE');
     raise fnd_api.g_exc_unexpected_error;

END Predefined_List_Rule;


PROCEDURE Null_Default_Rule (
   p_column_name         IN      VARCHAR2,
   p_column_value        IN      VARCHAR2,
   p_rule_id             IN      NUMBER,
   p_level               IN      NUMBER,
   p_staging_tbl         IN OUT NOCOPY ec_utils.mapping_tbl,
   x_valid_rule          OUT NOCOPY    VARCHAR2,
   x_msg_text            OUT NOCOPY    VARCHAR2) IS

   xProgress                     VARCHAR2(80);
   l_list_rule_id                NUMBER;
   n_column_pos                  NUMBER;
   n_rule_column_pos             NUMBER;
   l_type_code                   ece_rule_null_default.default_type_code%TYPE;
   l_value_column_name           ece_rule_null_default.value_column_name%TYPE;
   l_column_value                VARCHAR2(500);

   CURSOR c_null_default IS
   select default_type_code, value_column_name
   from   ece_rule_null_default
   where  column_rule_id = p_rule_id;

BEGIN
  if ec_debug.G_debug_level >= 2 then
   ec_debug.push ('ECE_RULES_PKG.NULL_DEFAULT_RULE');
   ec_debug.pl (3, 'p_column_name', p_column_name);
   ec_debug.pl (3, 'p_column_value', p_column_value);
   ec_debug.pl (3, 'p_rule_id', p_rule_id);
   ec_debug.pl (3, 'p_level', p_level);
  end if;

   xProgress := 'ECERULEB-110-1000';
   x_msg_text := NULL;
   x_valid_rule := 'Y';

   if (p_column_value is NULL) then

      xProgress := 'ECERULEB-110-1010';
      open c_null_default;
      fetch c_null_default into l_type_code, l_value_column_name;
      close c_null_default;

  if ec_debug.G_debug_level = 3 then
      ec_debug.pl (3, 'type_code', l_type_code);
  end if;

      if (l_type_code = 'LITERAL') then
         xProgress := 'ECERULEB-110-1020';
         l_column_value := l_value_column_name;

   if ec_debug.G_debug_level = 3 then
         ec_debug.pl (3, 'value', l_column_value);
   end if;

      elsif (l_type_code = 'COLUMN') then
         xProgress := 'ECERULEB-110-1030';
         ec_utils.find_pos (
            1,
            p_level,
            l_value_column_name,
            n_rule_column_pos);
         l_column_value := p_staging_tbl(n_rule_column_pos).value;

         ec_debug.pl (3, 'column_name', l_value_column_name);
         ec_debug.pl (3, 'column_value', l_column_value);
      end if;

      xProgress := 'ECERULEB-110-1040';
      ec_utils.find_pos (
         p_level,
         p_column_name,
         n_column_pos);

      xProgress := 'ECERULEB-110-1050';
      p_staging_tbl(n_column_pos).value := l_column_value;

   if ec_debug.G_debug_level =  3 then
      ec_debug.pl (3, 'Column Position', n_column_pos);
      ec_debug.pl (3, 'Updated Column Value', p_staging_tbl(n_column_pos).value);
   end if;

      xProgress := 'ECERULEB-110-1060';
      x_valid_rule := 'N';
      fnd_message.set_name ('EC', 'ECE_NULL_DEFAULT');
      fnd_message.set_token ('COLUMN_NAME', p_column_name);
      fnd_message.set_token ('VALUE', l_column_value);
      x_msg_text := fnd_message.get;
      ec_debug.pl (0, x_msg_text);

   end if;

 if ec_debug.G_debug_level >= 2 then
   ec_debug.pl (3, 'x_valid_rule', x_valid_rule);
   ec_debug.pl (3, 'x_msg_text', x_msg_text);
   ec_debug.pop ('ECE_RULES_PKG.NULL_DEFAULT_RULE');
 end if;

EXCEPTION
   WHEN OTHERS THEN
     if (c_null_default%ISOPEN) then
        close c_null_default;
     end if;
     ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR','PROGRESS_LEVEL', xProgress);
     ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
     ec_debug.pop ('ECE_RULES_PKG.NULL_DEFAULT_RULE');
     raise fnd_api.g_exc_unexpected_error;

END Null_Default_Rule;


PROCEDURE Datatype_Checking_Rule (
   p_column_datatype     IN      VARCHAR2,
   p_column_name         IN      VARCHAR2,
   p_column_value        IN      VARCHAR2,
   x_valid_rule          OUT  NOCOPY   VARCHAR2,
   x_msg_text            OUT  NOCOPY   VARCHAR2) IS

   xProgress                     VARCHAR2(80);
   l_temp_num                    NUMBER;
   l_temp_date                   DATE;

BEGIN
  if ec_debug.G_debug_level >= 2 then
   ec_debug.push ('ECE_RULES_PKG.DATATYPE_CHECKING_RULE');
   ec_debug.pl (3, 'p_column_datatype', p_column_datatype);
   ec_debug.pl (3, 'p_column_name', p_column_name);
   ec_debug.pl (3, 'p_column_value', p_column_value);
  end if;

   xProgress := 'ECERULEB-120-1000';
   x_msg_text := NULL;
   x_valid_rule := 'Y';

   BEGIN
      if (p_column_datatype = 'NUMBER') then
         xProgress := 'ECERULEB-120-1010';
         l_temp_num := TO_NUMBER(p_column_value);

      elsif (p_column_datatype = 'DATE') then
         xProgress := 'ECERULEB-120-1020';
         l_temp_date := TO_DATE(p_column_value , 'YYYYMMDD HH24MISS');

      else
         xProgress := 'ECERULEB-120-1030';
         x_valid_rule := 'Y';
      end if;

      EXCEPTION
         WHEN others then
            x_valid_rule := 'N';
   END;

   if (x_valid_rule = 'N') then
      xProgress := 'ECERULEB-120-1040';
      fnd_message.set_name ('EC', 'ECE_DATATYPE_CHECKING');
      fnd_message.set_token ('COLUMN_NAME', p_column_name);
      fnd_message.set_token ('VALUE', p_column_value);
      fnd_message.set_token ('DATATYPE', p_column_datatype);
      x_msg_text := fnd_message.get;
      ec_debug.pl (0, x_msg_text);
   end if;

 if ec_debug.G_debug_level >= 2 then
   ec_debug.pl (3, 'x_valid_rule', x_valid_rule);
   ec_debug.pl (3, 'x_msg_text', x_msg_text);
   ec_debug.pop ('ECE_RULES_PKG.DATATYPE_CHECKING_RULE');
 end if;

EXCEPTION
   WHEN OTHERS THEN
     ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR','PROGRESS_LEVEL', xProgress);
     ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
     ec_debug.pop ('ECE_RULES_PKG.DATATYPE_CHECKING_RULE');
     raise fnd_api.g_exc_unexpected_error;

END Datatype_Checking_Rule;


PROCEDURE Validate_Get_Address_Info (
   p_entity_id_pos           IN  NUMBER,
   p_org_id_pos              IN  NUMBER,
   p_addr_id_pos             IN  NUMBER,
   p_tp_location_code_pos    IN  NUMBER,
   p_tp_translator_code_pos  IN  NUMBER,
   p_tp_location_name_pos    IN  NUMBER,
   p_addr1_pos               IN  NUMBER,
   p_addr2_pos               IN  NUMBER,
   p_addr3_pos               IN  NUMBER,
   p_addr4_pos               IN  NUMBER,
   p_addr_alt_pos            IN  NUMBER,
   p_city_pos                IN  NUMBER,
   p_county_pos              IN  NUMBER,
   p_state_pos               IN  NUMBER,
   p_zip_pos                 IN  NUMBER,
   p_province_pos            IN  NUMBER,
   p_country_pos             IN  NUMBER,
   p_region1_pos             IN  NUMBER DEFAULT NULL,
   p_region2_pos             IN  NUMBER DEFAULT NULL,
   p_region3_pos             IN  NUMBER DEFAULT NULL,
   p_address                 IN  VARCHAR2) IS

   xProgress                     VARCHAR2(80);
   l_entity_id                   NUMBER := NULL;
   l_address_type                NUMBER;
   l_msg_count                   NUMBER;
   l_msg_data                    VARCHAR2(80);
   l_status_code                 NUMBER;
   l_org_id                      NUMBER := NULL;
   l_addr_id                     NUMBER := NULL;
   l_tp_location_code            VARCHAR2(3200) := NULL;
   l_tp_translator_code          VARCHAR2(3200) := NULL;
   l_tp_location_name            VARCHAR2(3200) := NULL;
   l_addr1                       VARCHAR2(3200) := NULL;
   l_addr2                       VARCHAR2(3200) := NULL;
   l_addr3                       VARCHAR2(3200) := NULL;
   l_addr4                       VARCHAR2(3200) := NULL;
   l_addr_alt                    VARCHAR2(3200) := NULL;
   l_city                        VARCHAR2(3200) := NULL;
   l_county                      VARCHAR2(3200) := NULL;
   l_state                       VARCHAR2(3200) := NULL;
   l_zip                         VARCHAR2(3200) := NULL;
   l_province                    VARCHAR2(3200) := NULL;
   l_country                     VARCHAR2(3200) := NULL;
   l_region1                     VARCHAR2(3200) := NULL;
   l_region2                     VARCHAR2(3200) := NULL;
   l_region3                     VARCHAR2(3200) := NULL;
   x_entity_id                   VARCHAR2(3200) := NULL;
   x_org_id                      VARCHAR2(3200) := NULL;
   x_addr_id                     VARCHAR2(3200) := NULL;
   x_tp_location_code            VARCHAR2(3200) := NULL;
   x_tp_translator_code          VARCHAR2(3200) := NULL;
   x_tp_location_name            VARCHAR2(3200) := NULL;
   x_addr1                       VARCHAR2(3200) := NULL;
   x_addr2                       VARCHAR2(3200) := NULL;
   x_addr3                       VARCHAR2(3200) := NULL;
   x_addr4                       VARCHAR2(3200) := NULL;
   x_addr_alt                    VARCHAR2(3200) := NULL;
   x_city                        VARCHAR2(3200) := NULL;
   x_county                      VARCHAR2(3200) := NULL;
   x_state                       VARCHAR2(3200) := NULL;
   x_zip                         VARCHAR2(3200) := NULL;
   x_province                    VARCHAR2(3200) := NULL;
   x_country                     VARCHAR2(3200) := NULL;
   x_region1                     VARCHAR2(3200) := NULL;
   x_region2                     VARCHAR2(3200) := NULL;
   x_region3                     VARCHAR2(3200) := NULL;
   l_msg_text                    VARCHAR2(2000):= NULL;
   l_valid_rule                  VARCHAR2(1):= 'Y';
   l_rule_type                   VARCHAR2(80):= g_p_invalid_addr;
   l_transaction_type            VARCHAR2(40);
   l_map_id                      NUMBER;
   l_stage_id                    NUMBER(15);
   l_document_id                 NUMBER(15);
   l_document_number             ece_stage.document_number%TYPE;
   l_rule_id                     NUMBER;
   l_action_code                 ece_process_rules.action_code%TYPE;
   l_return_status               VARCHAR2(20);
   var_exists                    BOOLEAN := FALSE;
   l_stack_pos                   NUMBER;
   l_plsql_pos                   NUMBER;
   stack_variable_not_found      EXCEPTION;
   no_addr_rule_info             EXCEPTION;
   addr_unexp_error              EXCEPTION;
   l_found_on_tbl                VARCHAR2(1):= 'N';     --Bug 2617428
   j                             pls_integer;
   no_of_searches                pls_integer :=1;
   v_precedence_code             VARCHAR2(240);
   v_profile_name                VARCHAR2(80);
   v_pcode                       VARCHAR2(10);

   CURSOR c_addr_rule IS
   select process_rule_id, action_code
   from   ece_process_rules
   where  transaction_type = l_transaction_type and
          map_id = l_map_id and
          rule_type = l_rule_type;

BEGIN
/* Bug 2151462 - commented out the debug messages and code that is not reqd. for
**               Address derivation
*/
  if ec_debug.G_debug_level >= 2 then
   ec_debug.push ('ECE_RULES_PKG.VALIDATE_GET_ADDRESS_INFO');

   xProgress := 'ECERULEB-130-1000';

   ec_debug.pl (3,'p_org_id_pos', p_org_id_pos);
   ec_debug.pl (3,'p_addr_id_pos', p_addr_id_pos);
   ec_debug.pl (3,'p_tp_location_code_pos', p_tp_location_code_pos);
   ec_debug.pl (3,'p_tp_translator_code_pos', p_tp_translator_code_pos);
   ec_debug.pl (3,'p_tp_location_name_pos', p_tp_location_name_pos);
   ec_debug.pl (3,'p_addr1_pos', p_addr1_pos);
   ec_debug.pl (3,'p_addr2_pos', p_addr2_pos);
   ec_debug.pl (3,'p_addr3_pos', p_addr3_pos);
   ec_debug.pl (3,'p_addr4_pos', p_addr4_pos);
   ec_debug.pl (3,'p_addr_alt_pos', p_addr_alt_pos);
   ec_debug.pl (3,'p_city_pos', p_city_pos);
   ec_debug.pl (3,'p_county_pos', p_county_pos);
   ec_debug.pl (3,'p_state_pos', p_state_pos);
   ec_debug.pl (3,'p_zip_pos', p_zip_pos);
   ec_debug.pl (3,'p_province_pos', p_province_pos);
   ec_debug.pl (3,'p_country_pos', p_country_pos);
   ec_debug.pl (3,'p_region1_pos', p_region1_pos);
   ec_debug.pl (3,'p_region2_pos', p_region2_pos);
   ec_debug.pl (3,'p_region3_pos', p_region3_pos);
 end if;
    ECE_RULES_PKG.G_PARTY_NAME := null;
    ECE_RULES_PKG.G_PARTY_NUMBER := null;
   -- get address information if it exists in the pl/sql table.
   if (p_org_id_pos is not null) then
      xProgress := 'ECERULEB-130-1010';
      l_org_id := ec_utils.g_file_tbl (p_org_id_pos).value;
   end if;

   if (p_addr_id_pos is not null) then
      xProgress := 'ECERULEB-130-1020';
      l_addr_id := ec_utils.g_file_tbl (p_addr_id_pos).value;
   end if;

   if (p_tp_location_code_pos is not null) then
      xProgress := 'ECERULEB-130-1030';
      l_tp_location_code := ec_utils.g_file_tbl (p_tp_location_code_pos).value;
   end if;

 /*if (p_tp_translator_code_pos is not null) then
      xProgress := 'ECERULEB-130-1040';
      l_tp_translator_code := ec_utils.g_file_tbl (p_tp_translator_code_pos).value;
   end if;

   IF (p_tp_location_name_pos IS NOT NULL) THEN
      xProgress := 'ECERULEB-130-1045';
      l_tp_location_name := ec_utils.g_file_tbl(p_tp_location_name_pos).value;
   END IF;
   bug2151462*/

   if (p_tp_translator_code_pos is not null) then
      xProgress := 'ECERULEB-130-1040';
      ECE_RULES_PKG.G_PARTY_NUMBER := ec_utils.g_file_tbl (p_tp_translator_code_pos).value;
   end if;

   IF (p_tp_location_name_pos IS NOT NULL) THEN
      xProgress := 'ECERULEB-130-1045';
      ECE_RULES_PKG.G_PARTY_NAME := ec_utils.g_file_tbl(p_tp_location_name_pos).value;
   END IF;

   if (p_addr1_pos is not null) then
      xProgress := 'ECERULEB-130-1050';
      l_addr1 := ec_utils.g_file_tbl (p_addr1_pos).value;
   end if;

   if (p_addr2_pos is not null) then
      xProgress := 'ECERULEB-130-1060';
      l_addr2 := ec_utils.g_file_tbl (p_addr2_pos).value;
   end if;

   if (p_addr3_pos is not null) then
      xProgress := 'ECERULEB-130-1070';
      l_addr3 := ec_utils.g_file_tbl (p_addr3_pos).value;
   end if;

   if (p_addr4_pos is not null) then
      xProgress := 'ECERULEB-130-1080';
      l_addr4 := ec_utils.g_file_tbl (p_addr4_pos).value;
   end if;

   if (p_city_pos is not null) then
      xProgress := 'ECERULEB-130-1090';
      l_city := ec_utils.g_file_tbl (p_city_pos).value;
   end if;

/* if (p_county_pos is not null) then
      xProgress := 'ECERULEB-130-1100';
      l_county := ec_utils.g_file_tbl (p_county_pos).value;
   end if;

   if (p_state_pos is not null) then
      xProgress := 'ECERULEB-130-1110';
      l_state := ec_utils.g_file_tbl (p_state_pos).value;
   end if;
bug2151462 */

   if (p_zip_pos is not null) then
      xProgress := 'ECERULEB-130-1120';
      l_zip := ec_utils.g_file_tbl (p_zip_pos).value;
   end if;

/* if (p_country_pos is not null) then
      xProgress := 'ECERULEB-130-1130';
      l_country := ec_utils.g_file_tbl (p_country_pos).value;
   end if;

   if (p_region1_pos is not null) then
      xProgress := 'ECERULEB-130-1140';
      l_region1 := ec_utils.g_file_tbl (p_region1_pos).value;
   end if;

   if (p_region2_pos is not null) then
      xProgress := 'ECERULEB-130-1150';
      l_region2 := ec_utils.g_file_tbl (p_region2_pos).value;
   end if;

   if (p_region3_pos is not null) then
      xProgress := 'ECERULEB-130-1160';
      l_region3 := ec_utils.g_file_tbl (p_region3_pos).value;
   end if;
bug2151462 */

   xProgress := 'ECERULEB-130-1170';
   var_exists := ec_utils.find_variable(0, 'I_ADDRESS_TYPE',
                                                l_stack_pos, l_plsql_pos);

   -- get the address type and transaction type information.
   if NOT (var_exists) then
      xProgress := 'ECERULEB-130-1180';
      raise stack_variable_not_found;
   else
      xProgress := 'ECERULEB-130-1190';
      ec_debug.pl(3,'Address Type',ec_utils.g_stack(l_stack_pos).variable_value);
      select DECODE (ec_utils.g_stack(l_stack_pos).variable_value,
                     g_bank, ece_trading_partners_pub.g_bank,
                     g_customer, ece_trading_partners_pub.g_customer,
                     g_supplier, ece_trading_partners_pub.g_supplier,
                     g_hr_location, ece_trading_partners_pub.g_hr_location,
                     NULL) into l_address_type from dual;
   end if;

   xProgress := 'ECERULEB-130-1200';
   l_transaction_type := ec_utils.g_transaction_type;
   l_map_id := ec_utils.g_map_id;

   -- print out the address value before address derivation.
   xProgress := 'ECERULEB-130-1210';
 if ec_debug.G_debug_level = 3 then
   ec_debug.pl (3, 'Input to Address Derivation');
   ec_debug.pl (3, 'l_return_status', l_return_status);
   ec_debug.pl (3, 'l_msg_count', l_msg_count);
   ec_debug.pl (3, 'l_msg_data', l_msg_data);
   ec_debug.pl (3, 'l_status_code', l_status_code);
   ec_debug.pl (3, 'l_address_type', l_address_type);
   ec_debug.pl (3, 'l_transaction_type', l_transaction_type);
   ec_debug.pl (3, 'l_tp_translator_code', translator_code);
   ec_debug.pl (3, 'l_org_id', l_org_id);
   ec_debug.pl (3, 'l_addr_id', l_addr_id);
   ec_debug.pl (3, 'l_tp_location_code', l_tp_location_code);
   ec_debug.pl (3, 'l_addr1', l_addr1);
   ec_debug.pl (3, 'l_addr2', l_addr2);
   ec_debug.pl (3, 'l_addr3', l_addr3);
   ec_debug.pl (3, 'l_addr4', l_addr4);
   ec_debug.pl (3, 'l_addr_alt', l_addr_alt);
   ec_debug.pl (3, 'l_city', l_city);
   ec_debug.pl (3, 'l_zip', l_zip);
   ec_debug.pl (3,  'party_name', ece_rules_pkg.g_party_name);
   ec_debug.pl (3,  'party_number', ece_rules_pkg.g_party_number);
 end if;

  /* hgandiko1
   ec_debug.pl (3, 'l_tp_translator_code', l_tp_translator_code);
   ec_debug.pl (3, 'l_tp_location_name', l_tp_location_name);
   ec_debug.pl (3, 'l_county', l_county);
   ec_debug.pl (3, 'l_state', l_state);
   ec_debug.pl (3, 'l_zip', l_zip);
   ec_debug.pl (3, 'l_province', l_province);
   ec_debug.pl (3, 'l_country', l_country);
   ec_debug.pl (3, 'l_region1', l_region1);
   ec_debug.pl (3, 'l_region2', l_region2);
   ec_debug.pl (3, 'l_region3', l_region3);
   Bug 2617428
  */
   v_profile_name := 'ECE_' || NVL(LTRIM(RTRIM(UPPER(NVL(l_transaction_type,'NULL VALUE')))),'') || '_ADDRESS_PRECEDENCE';
   fnd_profile.get(v_profile_name,v_precedence_code);
   v_pcode := NVL(v_precedence_code,'0');
   xProgress := 'ECERULEB-130-1211';

   IF g_address_tbl.COUNT<>0 then
       IF v_pcode = '0' then
          for k in 1..g_address_tbl.COUNT
          loop
         IF (upper(g_address_tbl(k).address_type) =upper(l_address_type)) THEN
             IF (nvl(upper(g_address_tbl(k).tp_location_code),' ') = nvl(upper(l_tp_location_code),' ')) AND
                     (nvl(upper(g_address_tbl(k).address_line1),' ')= nvl(UPPER(l_addr1),' '))   AND
                     (nvl(upper(g_address_tbl(k).address_line2),' ')= nvl(UPPER(l_addr2),' '))   AND
                     (nvl(upper(g_address_tbl(k).address_line3),' ')= nvl(UPPER(l_addr3),' '))   AND
                     (nvl(upper(g_address_tbl(k).city),' ')= nvl(UPPER(l_city),' ')) AND
                     (nvl(upper(g_address_tbl(k).zip),' ')= nvl(UPPER(l_zip),' '))  THEN

                     if (l_org_id is null) OR (nvl(l_org_id,-99) = g_address_tbl(k).org_id)  --3608171
             then
                        l_address_type      :=g_address_tbl(k).address_type;
                        x_org_id            :=g_address_tbl(k).org_id;
                        x_addr_id           :=g_address_tbl(k).address_id;
                        x_tp_translator_code:=g_address_tbl(k).address_code;
                        x_entity_id         :=g_address_tbl(k).parent_id;
                        x_tp_location_code  :=g_address_tbl(k).tp_location_code;
                        x_tp_location_name  :=g_address_tbl(k).tp_location_name;
                        x_addr1             :=g_address_tbl(k).address_line1;
                        x_addr2             :=g_address_tbl(k).address_line2;
                        x_addr3             :=g_address_tbl(k).address_line3;
                        x_addr4             :=g_address_tbl(k).address_line4;
                        x_addr_alt          :=g_address_tbl(k).address_line_alt;
                        x_city              :=g_address_tbl(k).city;
                        x_county            :=g_address_tbl(k).county;
                        x_state             :=g_address_tbl(k).state;
                        x_zip               :=g_address_tbl(k).zip;
                        x_province          :=g_address_tbl(k).province;
                        x_country           :=g_address_tbl(k).country;
                        x_region1           :=g_address_tbl(k).region_1;
                        x_region2           :=g_address_tbl(k).region_2;
                        x_region3           :=g_address_tbl(k).region_3;
                        l_return_status     := fnd_api.G_RET_STS_SUCCESS;
                        l_status_code       := 0;
                        l_found_on_tbl      := 'Y';
                        exit;
                      END if;
                  END IF;
         END IF;
       END LOOP;
         ELSIF v_pcode = '2' THEN
       for k in 1..g_address_tbl.COUNT
          loop
         IF (upper(g_address_tbl(k).address_type) =upper(l_address_type)) THEN
             IF (nvl(upper(g_address_tbl(k).tp_location_code),' ') = nvl(upper(l_tp_location_code),' ')) AND
                     (nvl(upper(g_address_tbl(k).address_line1),' ')= nvl(UPPER(l_addr1),' '))   AND
                     (nvl(upper(g_address_tbl(k).address_line2),' ')= nvl(UPPER(l_addr2),' '))   AND
                     (nvl(upper(g_address_tbl(k).address_line3),' ')= nvl(UPPER(l_addr3),' '))   AND
                     (nvl(upper(g_address_tbl(k).city),' ')= nvl(UPPER(l_city),' ')) AND
                     (nvl(upper(g_address_tbl(k).zip),' ')= nvl(UPPER(l_zip),' ')) AND
             (nvl(upper(g_address_tbl(k).tp_location_name),' ')= nvl(UPPER(ece_rules_pkg.g_party_name),' ')) AND
                     (nvl(upper(g_address_tbl(k).tp_translator_code),' ')= nvl(UPPER(ece_rules_pkg.g_party_number),' '))
             THEN

                     if (l_org_id is null) OR (nvl(l_org_id,-99) = g_address_tbl(k).org_id)  --3608171
             then
                        l_address_type      :=g_address_tbl(k).address_type;
                        x_org_id            :=g_address_tbl(k).org_id;
                        x_addr_id           :=g_address_tbl(k).address_id;
                        x_tp_translator_code:=g_address_tbl(k).address_code;
                        x_entity_id         :=g_address_tbl(k).parent_id;
                        x_tp_location_code  :=g_address_tbl(k).tp_location_code;
                        x_tp_location_name  :=g_address_tbl(k).tp_location_name;
                        x_addr1             :=g_address_tbl(k).address_line1;
                        x_addr2             :=g_address_tbl(k).address_line2;
                        x_addr3             :=g_address_tbl(k).address_line3;
                        x_addr4             :=g_address_tbl(k).address_line4;
                        x_addr_alt          :=g_address_tbl(k).address_line_alt;
                        x_city              :=g_address_tbl(k).city;
                        x_county            :=g_address_tbl(k).county;
                        x_state             :=g_address_tbl(k).state;
                        x_zip               :=g_address_tbl(k).zip;
                        x_province          :=g_address_tbl(k).province;
                        x_country           :=g_address_tbl(k).country;
                        x_region1           :=g_address_tbl(k).region_1;
                        x_region2           :=g_address_tbl(k).region_2;
                        x_region3           :=g_address_tbl(k).region_3;
                        l_return_status     := fnd_api.G_RET_STS_SUCCESS;
                        l_status_code       := 0;
                        l_found_on_tbl      := 'Y';
                        exit;
                      END if;
                  END IF;
         END IF;
       END LOOP;
      ELSE
       for k in 1..g_address_tbl.COUNT
           loop
        IF (upper(g_address_tbl(k).address_type) =upper(l_address_type)) THEN
           IF upper(g_address_tbl(k).tp_translator_code) = UPPER(translator_code) AND
              upper(g_address_tbl(k).tp_location_code)= UPPER(l_tp_location_code) THEN
                  if (l_org_id is null) OR (nvl(l_org_id,-99) = g_address_tbl(k).org_id)  --3608171
                  then
                        l_address_type      :=g_address_tbl(k).address_type;
                        x_org_id            :=g_address_tbl(k).org_id;
                        x_addr_id           :=g_address_tbl(k).address_id;
                        x_tp_translator_code:=g_address_tbl(k).address_code;
                        x_entity_id         :=g_address_tbl(k).parent_id;
                        x_tp_location_code  :=g_address_tbl(k).tp_location_code;
                        x_tp_location_name  :=g_address_tbl(k).tp_location_name;
                        x_addr1             :=g_address_tbl(k).address_line1;
                        x_addr2             :=g_address_tbl(k).address_line2;
                        x_addr3             :=g_address_tbl(k).address_line3;
                        x_addr4             :=g_address_tbl(k).address_line4;
                        x_addr_alt          :=g_address_tbl(k).address_line_alt;
                        x_city              :=g_address_tbl(k).city;
                        x_county            :=g_address_tbl(k).county;
                        x_state             :=g_address_tbl(k).state;
                        x_zip               :=g_address_tbl(k).zip;
                        x_province          :=g_address_tbl(k).province;
                        x_country           :=g_address_tbl(k).country;
                        x_region1           :=g_address_tbl(k).region_1;
                        x_region2           :=g_address_tbl(k).region_2;
                        x_region3           :=g_address_tbl(k).region_3;
                        l_return_status     := fnd_api.G_RET_STS_SUCCESS;
                        l_status_code       := 0;
                        l_found_on_tbl      := 'Y';
                        exit;
                      END if;
                  END IF;
               END IF;
             END LOOP;
           END IF;
         END IF;

   if l_found_on_tbl = 'N' then     -- Bug 2614728

   -- Call the address derivation api to get the address information. hgandiko1
   xProgress := 'ECERULEB-130-1220';
   ece_trading_partners_pub.ece_get_address_wrapper(
      p_api_version_number   => 1.0,
      x_return_status        => l_return_status,
      x_msg_count            => l_msg_count,
      x_msg_data             => l_msg_data,
      x_status_code          => l_status_code,
      p_address_type         => l_address_type,
      p_transaction_type     => l_transaction_type,
      p_org_id_in            => l_org_id,
      p_address_id_in        => l_addr_id,
      p_tp_location_code_in  => l_tp_location_code,
      p_translator_code_in   => translator_code,
      p_tp_location_name_in  => l_tp_location_name,
      p_address_line1_in     => l_addr1,
      p_address_line2_in     => l_addr2,
      p_address_line3_in     => l_addr3,
      p_address_line4_in     => l_addr4,
      p_address_line_alt_in  => l_addr_alt,
      p_city_in              => l_city,
      p_county_in            => l_county,
      p_state_in             => l_state,
      p_zip_in               => l_zip,
      p_province_in          => l_province,
      p_country_in           => l_country,
      p_region_1_in          => l_region1,
      p_region_2_in          => l_region2,
      p_region_3_in          => l_region3,
      x_entity_id_out        => x_entity_id,
      x_org_id_out           => x_org_id,
      x_address_id_out       => x_addr_id,
      x_tp_location_code_out => x_tp_location_code,
      x_translator_code_out  => x_tp_translator_code,
      x_tp_location_name_out => x_tp_location_name,
      x_address_line1_out    => x_addr1,
      x_address_line2_out    => x_addr2,
      x_address_line3_out    => x_addr3,
      x_address_line4_out    => x_addr4,
      x_address_line_alt_out => x_addr_alt,
      x_city_out             => x_city,
      x_county_out           => x_county,
      x_state_out            => x_state,
      x_zip_out              => x_zip,
      x_province_out         => x_province,
      x_country_out          => x_country,
      x_region_1_out         => x_region1,
      x_region_2_out         => x_region2,
      x_region_3_out         => x_region3);

    xProgress := 'ECERULEB-130-1221';
    if x_addr_id IS NOT NULL then       -- Bug 2617428
      j :=      g_address_tbl.COUNT + 1;
      g_address_tbl(j).address_type      := l_address_type;
      g_address_tbl(j).org_id            := x_org_id;
      g_address_tbl(j).address_id        := x_addr_id;
      g_address_tbl(j).parent_id         := x_entity_id;
      g_address_tbl(j).tp_location_code  := x_tp_location_code;
      g_address_tbl(j).tp_location_name  := x_tp_location_name;
      g_address_tbl(j).tp_translator_code:= translator_code;
      g_address_tbl(j).address_code      := x_tp_translator_code;
      g_address_tbl(j).address_line1     := x_addr1;
      g_address_tbl(j).address_line2     := x_addr2;
      g_address_tbl(j).address_line3     := x_addr3;
      g_address_tbl(j).address_line4     := x_addr4;
      g_address_tbl(j).address_line_alt  := x_addr_alt;
      g_address_tbl(j).city          := x_city;
      g_address_tbl(j).county        := x_county;
      g_address_tbl(j).state         := x_state;
      g_address_tbl(j).zip       := x_zip;
      g_address_tbl(j).province      := x_province;
      g_address_tbl(j).country       := x_country;
      g_address_tbl(j).region_1      := x_region1;
      g_address_tbl(j).region_2      := x_region2;
      g_address_tbl(j).region_3      := x_region3;
    end if;
   end if;

   xProgress := 'ECERULEB-130-1230';
   if (l_return_status = fnd_api.g_ret_sts_success) then

      -- assign the address info that got from address derivation to
      -- pl/sql table.
      xProgress := 'ECERULEB-130-1240';
      if (l_status_code = ece_trading_partners_pub.g_no_errors) then
         xProgress := 'ECERULEB-130-1250';
         l_valid_rule := 'Y';

         if (p_entity_id_pos is not null) and (x_entity_id is not null) then
            xProgress := 'ECERULEB-130-1254';
            ec_utils.g_file_tbl (p_entity_id_pos).value := x_entity_id;
         end if;

         if (p_org_id_pos is not null) and (x_org_id is not null) then
            xProgress := 'ECERULEB-130-1260';
            ec_utils.g_file_tbl (p_org_id_pos).value := x_org_id;
         end if;

         if (p_addr_id_pos is not null) and (x_addr_id is not null) then
            xProgress := 'ECERULEB-130-1270';
            ec_utils.g_file_tbl (p_addr_id_pos).value := x_addr_id;
         end if;

         if (p_tp_location_code_pos is not null) and (x_tp_location_code is not null) then
            xProgress := 'ECERULEB-130-1280';
            ec_utils.g_file_tbl (p_tp_location_code_pos).value := x_tp_location_code;
         end if;

      -- Bug 2570369: Uncommented the following if condition because the x_tp_translator_code
      --              is used as a placeholder to store new values from the AD code such as
      --              inventory_organization_id from hr_locations.

         if (p_tp_translator_code_pos is not null) and (x_tp_translator_code is not null) then
            xProgress := 'ECERULEB-130-1290';
            ec_utils.g_file_tbl (p_tp_translator_code_pos).value := x_tp_translator_code;
         end if;

         if (p_tp_location_name_pos is not null) and (x_tp_location_name is not null) then
            xProgress := 'ECERULEB-130-1300';
            ec_utils.g_file_tbl (p_tp_location_name_pos).value := x_tp_location_name;
         end if;

         if (p_addr1_pos is not null) and (x_addr1 is not null) then
            xProgress := 'ECERULEB-130-1310';
            ec_utils.g_file_tbl (p_addr1_pos).value := x_addr1;
         end if;

         if (p_addr2_pos is not null) and (x_addr2 is not null) then
            xProgress := 'ECERULEB-130-1320';
            ec_utils.g_file_tbl (p_addr2_pos).value := x_addr2;
         end if;

         if (p_addr3_pos is not null) and (x_addr3 is not null) then
            xProgress := 'ECERULEB-130-1330';
            ec_utils.g_file_tbl (p_addr3_pos).value := x_addr3;
         end if;

         if (p_addr4_pos is not null) and (x_addr4 is not null) then
            xProgress := 'ECERULEB-130-1340';
            ec_utils.g_file_tbl (p_addr4_pos).value := x_addr4;
         end if;

         if (p_addr_alt_pos is not null) and (x_addr_alt is not null) then
            xProgress := 'ECERULEB-130-1350';
            ec_utils.g_file_tbl (p_addr_alt_pos).value := x_addr_alt;
         end if;

         if (p_city_pos is not null) and (x_city is not null) then
            xProgress := 'ECERULEB-130-1360';
            ec_utils.g_file_tbl (p_city_pos).value := x_city;
         end if;

         if (p_county_pos is not null) and (x_county is not null) then
            xProgress := 'ECERULEB-130-1370';
            ec_utils.g_file_tbl (p_county_pos).value := x_county;
         end if;

         if (p_state_pos is not null) and (x_state is not null) then
            xProgress := 'ECERULEB-130-1380';
            ec_utils.g_file_tbl (p_state_pos).value := x_state;
         end if;

         if (p_zip_pos is not null) and (x_zip is not null) then
            xProgress := 'ECERULEB-130-1390';
            ec_utils.g_file_tbl (p_zip_pos).value := x_zip;
         end if;

         if (p_province_pos is not null) and (x_province is not null) then
            xProgress := 'ECERULEB-130-1400';
            ec_utils.g_file_tbl (p_province_pos).value := x_province;
         end if;

         if (p_country_pos is not null) and (x_country is not null) then
            xProgress := 'ECERULEB-130-1410';
            ec_utils.g_file_tbl (p_country_pos).value := x_country;
         end if;

         if (p_region1_pos is not null) and (x_region1 is not null) then
            xProgress := 'ECERULEB-130-1420';
            ec_utils.g_file_tbl (p_region1_pos).value := x_region1;
         end if;

         if (p_region2_pos is not null) and (x_region2 is not null) then
            xProgress := 'ECERULEB-130-1430';
            ec_utils.g_file_tbl (p_region2_pos).value := x_region2;
         end if;

         if (p_region3_pos is not null) and (x_region3 is not null) then
            xProgress := 'ECERULEB-130-1440';
            ec_utils.g_file_tbl (p_region3_pos).value := x_region3;
         end if;

      /*  bug 2151462 Added new messages and modified the existing ones */

      elsif (l_status_code = ece_trading_partners_pub.g_inconsistent_addr_comp) then
         xProgress := 'ECERULEB-130-1450';
         fnd_message.set_name ('EC', 'ECE_INCONSISENT_ADDRESS');
         fnd_message.set_token ('ADDRESS', p_address);
         fnd_message.set_token ('A1', l_addr1);
         fnd_message.set_token ('A2', l_addr2);
         fnd_message.set_token ('A3', l_addr3);
         fnd_message.set_token ('A4', l_addr4);
         fnd_message.set_token ('CITY', l_city);
         fnd_message.set_token ('POSTAL_CODE', l_zip);
         fnd_message.set_token ('ORG_ID', l_org_id);
         fnd_message.set_token ('LOCATION_CODE', l_tp_location_code);
         l_msg_text := fnd_message.get;
         ec_debug.pl (0, l_msg_text);
         l_valid_rule := 'N';

      elsif (l_status_code = ece_trading_partners_pub.g_multiple_addr_found) then
         xProgress := 'ECERULEB-130-1460';
         fnd_message.set_name ('EC', 'ECE_MULTIPLE_ADDR_FOUND');
         fnd_message.set_token ('ADDRESS', p_address);
         fnd_message.set_token ('A1', l_addr1);
         fnd_message.set_token ('A2', l_addr2);
         fnd_message.set_token ('A3', l_addr3);
         fnd_message.set_token ('A4', l_addr4);
         fnd_message.set_token ('CITY', l_city);
         fnd_message.set_token ('POSTAL_CODE', l_zip);
         fnd_message.set_token ('ORG_ID', l_org_id);
         fnd_message.set_token ('LOCATION_CODE', l_tp_location_code);
         l_msg_text := fnd_message.get;
         ec_debug.pl (0, l_msg_text);
         l_valid_rule := 'N';

      elsif (l_status_code = ece_trading_partners_pub.g_cannot_derive_addr) then
         xProgress := 'ECERULEB-130-1470';
         fnd_message.set_name ('EC', 'ECE_CANNOT_DERIVE_ADDRESS');
         fnd_message.set_token ('ADDRESS', p_address);
         fnd_message.set_token ('LOCATION_CODE', l_tp_location_code);
         fnd_message.set_token ('ORG_ID', l_org_id);
         l_msg_text := fnd_message.get;
         ec_debug.pl (0, l_msg_text);
         l_valid_rule := 'N';

      elsif (l_status_code = ece_trading_partners_pub.g_multiple_loc_found) then
         xProgress := 'ECERULEB-130-1480';
         fnd_message.set_name ('EC', 'ECE_MULTIPLE_LOC_FOUND');
         fnd_message.set_token ('ADDRESS', p_address);
         fnd_message.set_token ('LOCATION_CODE', l_tp_location_code);
         fnd_message.set_token ('ORG_ID', l_org_id);
         l_msg_text := fnd_message.get;
         ec_debug.pl (0, l_msg_text);
         l_valid_rule := 'N';

      elsif (l_status_code = ece_trading_partners_pub.g_cannot_derive_addr_id) then
         xProgress := 'ECERULEB-130-1490';
         fnd_message.set_name ('EC', 'ECE_CANNOT_DERIVE_ADDRESS_ID');
         fnd_message.set_token ('ADDRESS', p_address);
         l_msg_text := fnd_message.get;
         ec_debug.pl (0, l_msg_text);
         l_valid_rule := 'N';
      end if;

   else
      if (l_status_code = ece_trading_partners_pub.g_invalid_addr_id) then
         xProgress := 'ECERULEB-130-1500';
         fnd_message.set_name ('EC', 'ECE_INVALID_ADDR_ID');
         fnd_message.set_token ('ADDRESS', p_address);
         fnd_message.set_token ('ADDRESS_ID', l_addr_id);
         fnd_message.set_token ('ORG_ID', l_org_id);
         l_msg_text := fnd_message.get;
         ec_debug.pl (0, l_msg_text);
         l_valid_rule := 'N';

      elsif (l_status_code = ece_trading_partners_pub.g_invalid_org_id) then
         xProgress := 'ECERULEB-130-1510';
         fnd_message.set_name ('EC', 'ECE_INVALID_ORG_ID');
         fnd_message.set_token ('ORG_ID', l_org_id);
         l_msg_text := fnd_message.get;
         ec_debug.pl (0, l_msg_text);
         l_valid_rule := 'N';

      elsif (l_status_code = ece_trading_partners_pub.g_invalid_parameter) then
         xProgress := 'ECERULEB-130-1520';
         fnd_message.set_name ('EC', 'ECE_INVALID_ADDR_PARAMETER');
         fnd_message.set_token ('ADDRESS', p_address);
         l_msg_text := fnd_message.get;
         ec_debug.pl (0, l_msg_text);
         l_valid_rule := 'N';

      else
         xProgress := 'ECERULEB-130-1530';
         raise addr_unexp_error;
      end if;

   end if;

   -- print out the address value after address derivation.
   xProgress := 'ECERULEB-130-1540';
 if ec_debug.G_debug_level = 3 then
   ec_debug.pl (3, 'Output of Address Derivation');
   ec_debug.pl (3, 'l_return_status', l_return_status);
   ec_debug.pl (3, 'l_msg_count', l_msg_count);
   ec_debug.pl (3, 'l_msg_data', l_msg_data);
   ec_debug.pl (3, 'l_status_code', l_status_code);
   ec_debug.pl (3, 'l_address_type', l_address_type);
   ec_debug.pl (3, 'l_transaction_type', l_transaction_type);
   ec_debug.pl (3, 'x_org_id', x_org_id);
   ec_debug.pl (3, 'x_addr_id', x_addr_id);
   ec_debug.pl (3, 'x_tp_location_code', x_tp_location_code);
   ec_debug.pl (3, 'x_tp_translator_code', x_tp_translator_code);
   ec_debug.pl (3, 'x_tp_location_name', x_tp_location_name);
   ec_debug.pl (3, 'x_addr1', x_addr1);
   ec_debug.pl (3, 'x_addr2', x_addr2);
   ec_debug.pl (3, 'x_addr3', x_addr3);
   ec_debug.pl (3, 'x_addr4', x_addr4);
   ec_debug.pl (3, 'x_addr_alt', x_addr_alt);
   ec_debug.pl (3, 'x_city', x_city);
   ec_debug.pl (3, 'x_county', x_county);
   ec_debug.pl (3, 'x_state', x_state);
   ec_debug.pl (3, 'x_zip', x_zip);
   ec_debug.pl (3, 'x_province', x_province);
   ec_debug.pl (3, 'x_country', x_country);
   ec_debug.pl (3, 'x_region1', x_region1);
   ec_debug.pl (3, 'x_region2', x_region2);
   ec_debug.pl (3, 'x_region3', x_region3);
   ec_debug.pl (3, 'l_valid_rule', l_valid_rule);
 end if;
   xProgress := 'ECERULEB-130-1550';
   l_stage_id := ec_utils.g_ext_levels(ec_utils.g_current_level).stage_id;
   l_document_id := ec_utils.g_ext_levels(ec_utils.g_current_level).document_id;
   l_document_number := ec_utils.g_ext_levels(ec_utils.g_current_level).document_number;

   xProgress := 'ECERULEB-130-1560';
  if ec_debug.G_debug_level =  3 then
   ec_debug.pl (3, 'l_stage_id', l_stage_id);
   ec_debug.pl (3, 'l_document_id', l_document_id);
   ec_debug.pl (3, 'l_document_number', l_document_number);
  end if;

   -- get the defined process rule 'INVALID_ADDRESS' information.
   xProgress := 'ECERULEB-130-1570';
   open c_addr_rule;
   fetch c_addr_rule into l_rule_id, l_action_code;
   if c_addr_rule%NOTFOUND then
      raise no_addr_rule_info;
   end if;

   xProgress := 'ECERULEB-130-1580';
   Update_Status (l_transaction_type, ec_utils.g_current_level, l_valid_rule,
                  l_action_code, NULL, l_rule_id, l_stage_id, l_document_id,
                  g_process_rule, l_document_number, l_msg_text);

   xProgress := 'ECERULEB-130-1590';
  if ec_debug.G_debug_level >= 2 then
   ec_debug.pop ('ECE_RULES_PKG.VALIDATE_GET_ADDRESS_INFO');
  end if;

EXCEPTION
   WHEN addr_unexp_error then
      ec_debug.pl (0, 'EC', 'ECE_ADDR_UNEXP_ERROR',
                   'ADDRESS', p_address);
      ec_debug.pop ('ECE_RULES_PKG.VALIDATE_GET_ADDRESS_INFO');
      raise ec_utils.program_exit;

   WHEN stack_variable_not_found then
     ec_debug.pl (0, 'EC', 'ECE_VARIABLE_NOT_ON_STACK',
                  'VARIABLE_NAME', 'I_ADDRESS_TYPE');
     ec_debug.pop ('ECE_RULES_PKG.VALIDATE_GET_ADDRESS_INFO');
     raise ec_utils.program_exit;

   WHEN no_addr_rule_info then
     if (c_addr_rule%ISOPEN) then
        close c_addr_rule;
     end if;
     ec_debug.pl (0, 'EC', 'ECE_NO_PROCESS_RULE',
                  'TRANSACTION_TYPE', l_transaction_type,
                  'RULE_TYPE', l_rule_type);
     ec_debug.pop ('ECE_RULES_PKG.VALIDATE_GET_ADDRESS_INFO');
     raise ec_utils.program_exit;

   WHEN OTHERS THEN
     if (c_addr_rule%ISOPEN) then
        close c_addr_rule;
     end if;
     ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR','PROGRESS_LEVEL', xProgress);
     ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
     ec_debug.pop ('ECE_RULES_PKG.VALIDATE_GET_ADDRESS_INFO');
     raise ec_utils.program_exit;

END Validate_Get_Address_Info;


PROCEDURE Validate_Ship_To_Address IS

   xProgress                     VARCHAR2(80);
   n_entity_id_pos               NUMBER := NULL;
   n_org_id_pos                  NUMBER := NULL;
   n_addr_id_pos                 NUMBER := NULL;
   n_edi_location_code_pos       NUMBER := NULL;
   n_tp_translator_code_pos      NUMBER := NULL;
   n_tp_location_name_pos        NUMBER := NULL;
   n_addr1_pos                   NUMBER := NULL;
   n_addr2_pos                   NUMBER := NULL;
   n_addr3_pos                   NUMBER := NULL;
   n_addr4_pos                   NUMBER := NULL;
   n_addr_alt_pos                NUMBER := NULL;
   n_city_pos                    NUMBER := NULL;
   n_county_pos                  NUMBER := NULL;
   n_state_pos                   NUMBER := NULL;
   n_zip_pos                     NUMBER := NULL;
   n_province_pos                NUMBER := NULL;
   n_country_pos                 NUMBER := NULL;
   n_region1_pos                 NUMBER := NULL;
   n_region2_pos                 NUMBER := NULL;
   n_region3_pos                 NUMBER := NULL;
   l_action_code                 ece_process_rules.action_code%TYPE;
   l_ignore_flag                 ece_rule_violations.ignore_flag%TYPE;
   l_address                     VARCHAR2(50) := 'ship to';

BEGIN

   xProgress := 'ECERULEB-140-1000';
  if ec_debug.G_debug_level >= 2 then
   ec_debug.push ('ECE_RULES_PKG.VALIDATE_SHIP_TO_ADDRESS');
 end if;
   Get_Action_Ignore_Flag (l_action_code, l_ignore_flag);

   if (l_action_code <> g_disabled and l_ignore_flag = 'N') then

      -- get the pl/sql position for address columns.
      xProgress := 'ECERULEB-140-1002';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_CUSTOMER_ID',
         n_entity_id_pos);

      xProgress := 'ECERULEB-140-1004';
         ec_utils.find_pos (
         1,
         'ORG_ID',
         n_org_id_pos);

      xProgress := 'ECERULEB-140-1010';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_ADDRESS_ID',
         n_addr_id_pos);

      xProgress := 'ECERULEB-140-1020';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_EDI_LOCATION_CODE',
         n_edi_location_code_pos);

/*      ec_utils.find_pos (
         1,
         'TP_TRANSLATOR_CODE',
         n_tp_translator_code_pos);
bug2151462 */

    /* Bug 2570369
    Using the variable n_tp_translator_code_pos to store the value of
    customer number since a new variable would require a change in the
    validate_get_address_info.
    */
   /* Bug 2663632 : Swapped the column names ship_to_address_code and
           ship_to_address_name
   */
      xProgress := 'ECERULEB-140-1030';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_ADDRESS_CODE',
         n_tp_translator_code_pos);

      xProgress := 'ECERULEB-140-1040';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_ADDRESS_NAME',
         n_tp_location_name_pos);

      xProgress := 'ECERULEB-140-1050';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_ADDRESS1',
         n_addr1_pos);

      xProgress := 'ECERULEB-140-1060';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_ADDRESS2',
         n_addr2_pos);

      xProgress := 'ECERULEB-140-1070';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_ADDRESS3',
         n_addr3_pos);

      xProgress := 'ECERULEB-140-1080';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_ADDRESS4',
         n_addr4_pos);

      xProgress := 'ECERULEB-140-1090';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_CITY',
         n_city_pos);

      xProgress := 'ECERULEB-140-1100';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_POSTAL_CODE',
         n_zip_pos);

      xProgress := 'ECERULEB-140-1110';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_COUNTRY_INT',
         n_country_pos);

      xProgress := 'ECERULEB-140-1120';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_STATE_INT',
         n_state_pos);

      xProgress := 'ECERULEB-140-1130';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_PROVINCE_INT',
         n_province_pos);

      xProgress := 'ECERULEB-140-1140';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_COUNTY',
         n_county_pos);

      xProgress := 'ECERULEB-140-1150';
      Validate_Get_Address_Info (n_entity_id_pos, n_org_id_pos, n_addr_id_pos,
                                 n_edi_location_code_pos, n_tp_translator_code_pos,
                                 n_tp_location_name_pos, n_addr1_pos, n_addr2_pos,
                                 n_addr3_pos, n_addr4_pos, n_addr_alt_pos,
                                 n_city_pos, n_county_pos, n_state_pos, n_zip_pos,
                                 n_province_pos, n_country_pos, n_region1_pos,
                                 n_region2_pos, n_region3_pos, l_address);

   end if;

   xProgress := 'ECERULEB-140-1160';
 if ec_debug.G_debug_level >= 2 then
   ec_debug.pop ('ECE_RULES_PKG.VALIDATE_SHIP_TO_ADDRESS');
 end if;

EXCEPTION
   WHEN ec_utils.program_exit then
     ec_debug.pop ('ECE_RULES_PKG.VALIDATE_SHIP_TO_ADDRESS');
     raise;

   WHEN OTHERS THEN
     ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR','PROGRESS_LEVEL', xProgress);
     ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
     ec_debug.pop ('ECE_RULES_PKG.VALIDATE_SHIP_TO_ADDRESS');
     raise ec_utils.program_exit;

END Validate_Ship_To_Address;


PROCEDURE Validate_Bill_To_Address IS

   xProgress                     VARCHAR2(80);
   n_entity_id_pos               NUMBER := NULL;
   n_org_id_pos                  NUMBER := NULL;
   n_addr_id_pos                 NUMBER := NULL;
   n_edi_location_code_pos       NUMBER := NULL;
   n_tp_translator_code_pos      NUMBER := NULL;
   n_tp_location_name_pos        NUMBER := NULL;
   n_addr1_pos                   NUMBER := NULL;
   n_addr2_pos                   NUMBER := NULL;
   n_addr3_pos                   NUMBER := NULL;
   n_addr4_pos                   NUMBER := NULL;
   n_addr_alt_pos                NUMBER := NULL;
   n_city_pos                    NUMBER := NULL;
   n_county_pos                  NUMBER := NULL;
   n_state_pos                   NUMBER := NULL;
   n_zip_pos                     NUMBER := NULL;
   n_province_pos                NUMBER := NULL;
   n_country_pos                 NUMBER := NULL;
   n_region1_pos                 NUMBER := NULL;
   n_region2_pos                 NUMBER := NULL;
   n_region3_pos                 NUMBER := NULL;
   l_action_code                 ece_process_rules.action_code%TYPE;
   l_ignore_flag                 ece_rule_violations.ignore_flag%TYPE;
   l_address                     VARCHAR2(50) := 'bill to';

BEGIN

   xProgress := 'ECERULEB-150-1000';
  if ec_debug.G_debug_level >= 2 then
   ec_debug.push ('ECE_RULES_PKG.VALIDATE_BILL_TO_ADDRESS');
 end if;

   Get_Action_Ignore_Flag (l_action_code, l_ignore_flag);

   if (l_action_code <> g_disabled and l_ignore_flag = 'N') then

      -- get the pl/sql position for address columns.
      xProgress := 'ECERULEB-150-1002';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_TO_CUSTOMER_ID',
         n_entity_id_pos);

      xProgress := 'ECERULEB-150-1004';
      ec_utils.find_pos (
         1,
         'ORG_ID',
         n_org_id_pos);

      xProgress := 'ECERULEB-150-1010';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_TO_ADDRESS_ID',
         n_addr_id_pos);

      xProgress := 'ECERULEB-150-1020';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_TO_EDI_LOCATION_CODE',
         n_edi_location_code_pos);

      /* ec_utils.find_pos (
         1,
         'TP_TRANSLATOR_CODE',
         n_tp_translator_code_pos);
      bug2151462 */

     /* Bug 2663632 : Create a new Column for retreiving Bill_to_address_name.
                      Also added code to retreive bill to customer number in
              bill_to_address_code.
     */
      xProgress := 'ECERULEB-150-1030';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_TO_ADDRESS_CODE',
         n_tp_translator_code_pos);

      xProgress := 'ECERULEB-150-1040';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_TO_ADDRESS_NAME',
         n_tp_location_name_pos);

      xProgress := 'ECERULEB-150-1050';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_TO_ADDRESS1',
         n_addr1_pos);

      xProgress := 'ECERULEB-150-1060';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_TO_ADDRESS2',
         n_addr2_pos);

      xProgress := 'ECERULEB-150-1070';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_TO_ADDRESS3',
         n_addr3_pos);

      xProgress := 'ECERULEB-150-1080';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_TO_ADDRESS4',
         n_addr4_pos);

      xProgress := 'ECERULEB-150-1090';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_TO_CITY',
         n_city_pos);

      xProgress := 'ECERULEB-150-1100';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_TO_POSTAL_CODE',
         n_zip_pos);

      xProgress := 'ECERULEB-150-1110';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_TO_COUNTRY_INT',
      n_country_pos);

      xProgress := 'ECERULEB-150-1120';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_TO_STATE_INT',
         n_state_pos);

      xProgress := 'ECERULEB-150-1130';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_TO_PROVINCE_INT',
         n_province_pos);

      xProgress := 'ECERULEB-150-1140';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_TO_COUNTY',
         n_county_pos);

      xProgress := 'ECERULEB-150-1150';
      Validate_Get_Address_Info (n_entity_id_pos, n_org_id_pos, n_addr_id_pos,
                                 n_edi_location_code_pos, n_tp_translator_code_pos,
                                 n_tp_location_name_pos, n_addr1_pos, n_addr2_pos,
                                 n_addr3_pos, n_addr4_pos, n_addr_alt_pos,
                                 n_city_pos, n_county_pos, n_state_pos, n_zip_pos,
                                 n_province_pos, n_country_pos, n_region1_pos,
                                 n_region2_pos, n_region3_pos, l_address);

   end if;

   xProgress := 'ECERULEB-150-1160';
  if ec_debug.G_debug_level >= 2 then
   ec_debug.pop ('ECE_RULES_PKG.VALIDATE_BILL_TO_ADDRESS');
 end if;
EXCEPTION
   WHEN ec_utils.program_exit then
     ec_debug.pop ('ECE_RULES_PKG.VALIDATE_BILL_TO_ADDRESS');
     raise;

   WHEN OTHERS THEN
     ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR','PROGRESS_LEVEL', xProgress);
     ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
     ec_debug.pop ('ECE_RULES_PKG.VALIDATE_BILL_TO_ADDRESS');
     raise ec_utils.program_exit;

END Validate_Bill_To_Address;


PROCEDURE Validate_Sold_To_Address IS

   xProgress                     VARCHAR2(80);
   n_entity_id_pos               NUMBER := NULL;
   n_org_id_pos                  NUMBER := NULL;
   n_addr_id_pos                 NUMBER := NULL;
   n_edi_location_code_pos       NUMBER := NULL;
   n_tp_translator_code_pos      NUMBER := NULL;
   n_tp_location_name_pos        NUMBER := NULL;
   n_addr1_pos                   NUMBER := NULL;
   n_addr2_pos                   NUMBER := NULL;
   n_addr3_pos                   NUMBER := NULL;
   n_addr4_pos                   NUMBER := NULL;
   n_addr_alt_pos                NUMBER := NULL;
   n_city_pos                    NUMBER := NULL;
   n_county_pos                  NUMBER := NULL;
   n_state_pos                   NUMBER := NULL;
   n_zip_pos                     NUMBER := NULL;
   n_province_pos                NUMBER := NULL;
   n_country_pos                 NUMBER := NULL;
   n_region1_pos                 NUMBER := NULL;
   n_region2_pos                 NUMBER := NULL;
   n_region3_pos                 NUMBER := NULL;
   l_action_code                 ece_process_rules.action_code%TYPE;
   l_ignore_flag                 ece_rule_violations.ignore_flag%TYPE;
   l_address                     VARCHAR2(50) := 'Sold to';

BEGIN

   xProgress := 'ECERULEB-230-1000';
  if ec_debug.G_debug_level >= 2 then
   ec_debug.push ('ECE_RULES_PKG.VALIDATE_SOLD_TO_ADDRESS');
  end if;

   Get_Action_Ignore_Flag (l_action_code, l_ignore_flag);

   if (l_action_code <> g_disabled and l_ignore_flag = 'N') then

      -- get the pl/sql position for address columns.
      xProgress := 'ECERULEB-230-1002';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SOLD_TO_CUSTOMER_ID',
         n_entity_id_pos);

      xProgress := 'ECERULEB-230-1004';
      ec_utils.find_pos (
         1,
         'ORG_ID',
         n_org_id_pos);

      xProgress := 'ECERULEB-230-1010';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SOLD_TO_ADDRESS_ID',
         n_addr_id_pos);

      xProgress := 'ECERULEB-230-1020';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SOLD_TO_EDI_LOCATION_CODE',
         n_edi_location_code_pos);

    /* ec_utils.find_pos (
         1,
         'TP_TRANSLATOR_CODE',
         n_tp_translator_code_pos);
    bug2151462 */

    /* Bug 2570369. This is a fix for the bug 2641276.
    Using the variable n_tp_translator_code_pos to store the value of
    customer number since a new variable would require a change in the
    validate_get_address_info.
    */
      xProgress := 'ECERULEB-230-1030';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SOLD_TO_ADDRESS_CODE',
         n_tp_translator_code_pos);

   /* Bug 2432974 Changed the column name SOLD_TO_ADDRESS_CODE to
      SOLD_TO_ADDRESS_NAME
   */
      xProgress := 'ECERULEB-230-1040';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SOLD_TO_ADDRESS_NAME',
         n_tp_location_name_pos);

      xProgress := 'ECERULEB-230-1050';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SOLD_TO_ADDRESS1',
         n_addr1_pos);

      xProgress := 'ECERULEB-230-1060';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SOLD_TO_ADDRESS2',
         n_addr2_pos);

      xProgress := 'ECERULEB-230-1070';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SOLD_TO_ADDRESS3',
         n_addr3_pos);

      xProgress := 'ECERULEB-230-1080';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SOLD_TO_ADDRESS4',
         n_addr4_pos);

      xProgress := 'ECERULEB-230-1090';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SOLD_TO_CITY',
         n_city_pos);

      xProgress := 'ECERULEB-230-1100';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SOLD_TO_POSTAL_CODE',
         n_zip_pos);

      xProgress := 'ECERULEB-230-1110';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SOLD_TO_COUNTRY_INT',
      n_country_pos);

      xProgress := 'ECERULEB-230-1120';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SOLD_TO_STATE_INT',
         n_state_pos);

      xProgress := 'ECERULEB-230-1130';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SOLD_TO_PROVINCE_INT',
         n_province_pos);

      xProgress := 'ECERULEB-230-1140';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SOLD_TO_COUNTY',
         n_county_pos);

      xProgress := 'ECERULEB-230-1150';
      Validate_Get_Address_Info (n_entity_id_pos, n_org_id_pos, n_addr_id_pos,
                                 n_edi_location_code_pos, n_tp_translator_code_pos,
                                 n_tp_location_name_pos, n_addr1_pos, n_addr2_pos,
                                 n_addr3_pos, n_addr4_pos, n_addr_alt_pos,
                                 n_city_pos, n_county_pos, n_state_pos, n_zip_pos,
                                 n_province_pos, n_country_pos, n_region1_pos,
                                 n_region2_pos, n_region3_pos, l_address);

   end if;

   xProgress := 'ECERULEB-230-1160';
  if ec_debug.G_debug_level >= 2 then
   ec_debug.pop ('ECE_RULES_PKG.VALIDATE_SOLD_TO_ADDRESS');
  end if;

EXCEPTION
   WHEN ec_utils.program_exit then
     ec_debug.pop ('ECE_RULES_PKG.VALIDATE_SOLD_TO_ADDRESS');
     raise;

   WHEN OTHERS THEN
     ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR','PROGRESS_LEVEL', xProgress);
     ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
     ec_debug.pop ('ECE_RULES_PKG.VALIDATE_SOLD_TO_ADDRESS');
     raise ec_utils.program_exit;

END Validate_Sold_To_Address;

PROCEDURE Validate_Ship_From_Address IS

   xProgress                     VARCHAR2(80);
   n_entity_id_pos               NUMBER := NULL;
   n_org_id_pos                  NUMBER := NULL;
   n_addr_id_pos                 NUMBER := NULL;
   n_edi_location_code_pos       NUMBER := NULL;
   n_tp_translator_code_pos      NUMBER := NULL;
   n_tp_location_name_pos        NUMBER := NULL;
   n_addr1_pos                   NUMBER := NULL;
   n_addr2_pos                   NUMBER := NULL;
   n_addr3_pos                   NUMBER := NULL;
   n_addr4_pos                   NUMBER := NULL;
   n_addr_alt_pos                NUMBER := NULL;
   n_city_pos                    NUMBER := NULL;
   n_county_pos                  NUMBER := NULL;
   n_state_pos                   NUMBER := NULL;
   n_zip_pos                     NUMBER := NULL;
   n_province_pos                NUMBER := NULL;
   n_country_pos                 NUMBER := NULL;
   n_region1_pos                 NUMBER := NULL;
   n_region2_pos                 NUMBER := NULL;
   n_region3_pos                 NUMBER := NULL;
   l_action_code                 ece_process_rules.action_code%TYPE;
   l_ignore_flag                 ece_rule_violations.ignore_flag%TYPE;
   l_address                     VARCHAR2(50) := 'ship from';

BEGIN

   xProgress := 'ECERULEB-160-1000';
  if ec_debug.G_debug_level >= 2 then
   ec_debug.push ('ECE_RULES_PKG.VALIDATE_SHIP_FROM_ADDRESS');
  end if;

   Get_Action_Ignore_Flag (l_action_code, l_ignore_flag);

   if (l_action_code <> g_disabled and l_ignore_flag = 'N') then

      -- get the pl/sql position for address columns.
      xProgress := 'ECERULEB-160-1002';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_FROM_CUSTOMER_ID',
         n_entity_id_pos);

      xProgress := 'ECERULEB-160-1004';
      ec_utils.find_pos (
         1,
         'ORG_ID',
         n_org_id_pos);

      xProgress := 'ECERULEB-160-1010';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_FROM_ADDRESS_ID',
         n_addr_id_pos);

      xProgress := 'ECERULEB-160-1020';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_FROM_EDI_LOCATION_CODE',
         n_edi_location_code_pos);

      xProgress := 'ECERULEB-160-1030';
/*      ec_utils.find_pos (
         1,
         'TP_TRANSLATOR_CODE',
         n_tp_translator_code_pos);

      xProgress := 'ECERULEB-160-1040';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_FROM_ADDRESS_CODE',
         n_tp_location_name_pos);
bug2151462 */

      xProgress := 'ECERULEB-160-1050';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_FROM_ADDRESS1',
         n_addr1_pos);

      xProgress := 'ECERULEB-160-1060';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_FROM_ADDRESS2',
         n_addr2_pos);

      xProgress := 'ECERULEB-160-1070';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_FROM_ADDRESS3',
         n_addr3_pos);

      xProgress := 'ECERULEB-160-1080';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_FROM_ADDRESS4',
         n_addr4_pos);

      xProgress := 'ECERULEB-160-1090';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_FROM_CITY',
         n_city_pos);

      xProgress := 'ECERULEB-160-1100';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_FROM_POSTAL_CODE',
         n_zip_pos);

      xProgress := 'ECERULEB-160-1110';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_FROM_COUNTRY_INT',
         n_country_pos);

      xProgress := 'ECERULEB-160-1120';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_FROM_STATE_INT',
         n_state_pos);

      xProgress := 'ECERULEB-160-1130';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_FROM_PROVINCE_INT',
         n_province_pos);

      xProgress := 'ECERULEB-160-1140';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_FROM_COUNTY',
         n_county_pos);

      xProgress := 'ECERULEB-160-1150';
      Validate_Get_Address_Info (n_entity_id_pos, n_org_id_pos, n_addr_id_pos,
                                 n_edi_location_code_pos, n_tp_translator_code_pos,
                                 n_tp_location_name_pos, n_addr1_pos, n_addr2_pos,
                                 n_addr3_pos, n_addr4_pos, n_addr_alt_pos,
                                 n_city_pos, n_county_pos, n_state_pos, n_zip_pos,
                                 n_province_pos, n_country_pos, n_region1_pos,
                                 n_region2_pos, n_region3_pos, l_address);

   end if;

   xProgress := 'ECERULEB-160-1160';
  if ec_debug.G_debug_level >= 2 then
   ec_debug.pop ('ECE_RULES_PKG.VALIDATE_SHIP_FROM_ADDRESS');
  end if;

EXCEPTION
   WHEN ec_utils.program_exit then
     ec_debug.pop ('ECE_RULES_PKG.VALIDATE_SHIP_FROM_ADDRESS');
     raise;

   WHEN OTHERS THEN
     ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR','PROGRESS_LEVEL', xProgress);
     ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
     ec_debug.pop ('ECE_RULES_PKG.VALIDATE_SHIP_FROM_ADDRESS');
     raise ec_utils.program_exit;

END Validate_Ship_From_Address;


PROCEDURE Validate_Bill_From_Address IS

   xProgress                     VARCHAR2(80);
   n_entity_id_pos               NUMBER := NULL;
   n_org_id_pos                  NUMBER := NULL;
   n_addr_id_pos                 NUMBER := NULL;
   n_edi_location_code_pos       NUMBER := NULL;
   n_tp_translator_code_pos      NUMBER := NULL;
   n_tp_location_name_pos        NUMBER := NULL;
   n_addr1_pos                   NUMBER := NULL;
   n_addr2_pos                   NUMBER := NULL;
   n_addr3_pos                   NUMBER := NULL;
   n_addr4_pos                   NUMBER := NULL;
   n_addr_alt_pos                NUMBER := NULL;
   n_city_pos                    NUMBER := NULL;
   n_county_pos                  NUMBER := NULL;
   n_state_pos                   NUMBER := NULL;
   n_zip_pos                     NUMBER := NULL;
   n_province_pos                NUMBER := NULL;
   n_country_pos                 NUMBER := NULL;
   n_region1_pos                 NUMBER := NULL;
   n_region2_pos                 NUMBER := NULL;
   n_region3_pos                 NUMBER := NULL;
   l_action_code                 ece_process_rules.action_code%TYPE;
   l_ignore_flag                 ece_rule_violations.ignore_flag%TYPE;
   l_address                     VARCHAR2(50) := 'bill from';

BEGIN

   xProgress := 'ECERULEB-170-1000';
  if ec_debug.G_debug_level >= 2 then
   ec_debug.push ('ECE_RULES_PKG.VALIDATE_BILL_FROM_ADDRESS');
  end if;

   Get_Action_Ignore_Flag (l_action_code, l_ignore_flag);

   if (l_action_code <> g_disabled and l_ignore_flag = 'N') then

      -- get the pl/sql position for address columns.
      xProgress := 'ECERULEB-170-1002';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_FROM_CUSTOMER_ID',
         n_entity_id_pos);

      xProgress := 'ECERULEB-170-1004';
      ec_utils.find_pos (
         1,
         'ORG_ID',
         n_org_id_pos);

      xProgress := 'ECERULEB-170-1010';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_FROM_ADDRESS_ID',
         n_addr_id_pos);

      xProgress := 'ECERULEB-170-1020';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_FROM_EDI_LOCATION_CODE',
         n_edi_location_code_pos);

      xProgress := 'ECERULEB-170-1030';
/*      ec_utils.find_pos (
         1,
         'TP_TRANSLATOR_CODE',
         n_tp_translator_code_pos);

      xProgress := 'ECERULEB-170-1040';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_FROM_ADDRESS_CODE',
         n_tp_location_name_pos);
bug2151462 */

      xProgress := 'ECERULEB-170-1050';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_FROM_ADDRESS1',
         n_addr1_pos);

      xProgress := 'ECERULEB-170-1060';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_FROM_ADDRESS2',
         n_addr2_pos);

      xProgress := 'ECERULEB-170-1070';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_FROM_ADDRESS3',
         n_addr3_pos);

      xProgress := 'ECERULEB-170-1080';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_FROM_ADDRESS4',
         n_addr4_pos);

      xProgress := 'ECERULEB-170-1090';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_FROM_CITY',
         n_city_pos);

      xProgress := 'ECERULEB-170-1100';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_FROM_POSTAL_CODE',
         n_zip_pos);

      xProgress := 'ECERULEB-170-1110';
    ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_FROM_COUNTRY_INT',
         n_country_pos);

      xProgress := 'ECERULEB-170-1120';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_FROM_STATE_INT',
         n_state_pos);

      xProgress := 'ECERULEB-170-1130';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_FROM_PROVINCE_INT',
         n_province_pos);

      xProgress := 'ECERULEB-170-1140';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_FROM_COUNTY',
         n_county_pos);

      xProgress := 'ECERULEB-170-1150';
      Validate_Get_Address_Info (n_entity_id_pos, n_org_id_pos, n_addr_id_pos,
                                 n_edi_location_code_pos, n_tp_translator_code_pos,
                                 n_tp_location_name_pos, n_addr1_pos, n_addr2_pos,
                                 n_addr3_pos, n_addr4_pos, n_addr_alt_pos,
                                 n_city_pos, n_county_pos, n_state_pos, n_zip_pos,
                                 n_province_pos, n_country_pos, n_region1_pos,
                                 n_region2_pos, n_region3_pos, l_address);

   end if;

   xProgress := 'ECERULEB-170-1160';
 if ec_debug.G_debug_level >= 2 then
   ec_debug.pop ('ECE_RULES_PKG.VALIDATE_BILL_FROM_ADDRESS');
 end if;

EXCEPTION
   WHEN ec_utils.program_exit then
     ec_debug.pop ('ECE_RULES_PKG.VALIDATE_BILL_FROM_ADDRESS');
     raise;

   WHEN OTHERS THEN
     ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR','PROGRESS_LEVEL', xProgress);
     ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
     ec_debug.pop ('ECE_RULES_PKG.VALIDATE_BILL_FROM_ADDRESS');
     raise ec_utils.program_exit;

END Validate_Bill_From_Address;


PROCEDURE Validate_Ship_To_Intrmd_Add IS

   xProgress                     VARCHAR2(80);
   n_entity_id_pos               NUMBER := NULL;
   n_org_id_pos                  NUMBER := NULL;
   n_addr_id_pos                 NUMBER := NULL;
   n_edi_location_code_pos       NUMBER := NULL;
   n_tp_translator_code_pos      NUMBER := NULL;
   n_tp_location_name_pos        NUMBER := NULL;
   n_addr1_pos                   NUMBER := NULL;
   n_addr2_pos                   NUMBER := NULL;
   n_addr3_pos                   NUMBER := NULL;
   n_addr4_pos                   NUMBER := NULL;
   n_addr_alt_pos                NUMBER := NULL;
   n_city_pos                    NUMBER := NULL;
   n_county_pos                  NUMBER := NULL;
   n_state_pos                   NUMBER := NULL;
   n_zip_pos                     NUMBER := NULL;
   n_province_pos                NUMBER := NULL;
   n_country_pos                 NUMBER := NULL;
   n_region1_pos                 NUMBER := NULL;
   n_region2_pos                 NUMBER := NULL;
   n_region3_pos                 NUMBER := NULL;
   l_action_code                 ece_process_rules.action_code%TYPE;
   l_ignore_flag                 ece_rule_violations.ignore_flag%TYPE;
   l_address                     VARCHAR2(50) := 'ship to intrmd';

BEGIN

   xProgress := 'ECERULEB-240-1000';
  if ec_debug.G_debug_level >= 2 then
   ec_debug.push ('ECE_RULES_PKG.VALIDATE_SHIP_TO_INTRMD_ADD');
 end if;

   Get_Action_Ignore_Flag (l_action_code, l_ignore_flag);

   if (l_action_code <> g_disabled and l_ignore_flag = 'N') then

      -- get the pl/sql position for address columns.
      xProgress := 'ECERULEB-240-1002';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_INTRMD_CUSTOMER_ID',
         n_entity_id_pos);

      xProgress := 'ECERULEB-240-1004';
      ec_utils.find_pos (
         1,
         'ORG_ID',
         n_org_id_pos);

      xProgress := 'ECERULEB-240-1010';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_INTRMD_ADDRESS_ID',
         n_addr_id_pos);

      xProgress := 'ECERULEB-240-1020';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_INTRMD_EDI_LOCATION_CODE',
         n_edi_location_code_pos);

      xProgress := 'ECERULEB-240-1030';
/*      ec_utils.find_pos (
         1,
         'TP_TRANSLATOR_CODE',
         n_tp_translator_code_pos);
bug2151462 */
      xProgress := 'ECERULEB-240-1040';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_INTRMD_ADDRESS_CODE',
         n_tp_location_name_pos);

      xProgress := 'ECERULEB-240-1050';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_INTRMD_ADDRESS1',
         n_addr1_pos);

      xProgress := 'ECERULEB-240-1060';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_INTRMD_ADDRESS2',
         n_addr2_pos);

      xProgress := 'ECERULEB-240-1070';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_INTRMD_ADDRESS3',
         n_addr3_pos);

      xProgress := 'ECERULEB-240-1080';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_INTRMD_ADDRESS4',
         n_addr4_pos);

      xProgress := 'ECERULEB-240-1090';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_INTRMD_CITY',
         n_city_pos);

      xProgress := 'ECERULEB-240-1100';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_INTRMD_POSTAL_CODE',
         n_zip_pos);

      xProgress := 'ECERULEB-240-1110';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_INTRMD_COUNTRY_INT',
         n_country_pos);

      xProgress := 'ECERULEB-240-1120';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_INTRMD_STATE_INT',
         n_state_pos);

      xProgress := 'ECERULEB-240-1130';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_INTRMD_PROVINCE_INT',
         n_province_pos);

      xProgress := 'ECERULEB-240-1140';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_INTRMD_COUNTY',
         n_county_pos);

      xProgress := 'ECERULEB-240-1150';
      Validate_Get_Address_Info (n_entity_id_pos, n_org_id_pos, n_addr_id_pos,
                                 n_edi_location_code_pos, n_tp_translator_code_pos,
                                 n_tp_location_name_pos, n_addr1_pos, n_addr2_pos,
                                 n_addr3_pos, n_addr4_pos, n_addr_alt_pos,
                                 n_city_pos, n_county_pos, n_state_pos, n_zip_pos,
                                 n_province_pos, n_country_pos, n_region1_pos,
                                 n_region2_pos, n_region3_pos, l_address);

   end if;

   xProgress := 'ECERULEB-240-1160';
  if ec_debug.G_debug_level >= 2 then
   ec_debug.pop ('ECE_RULES_PKG.VALIDATE_SHIP_TO_INTRMD_ADD');
  end if;

EXCEPTION
   WHEN ec_utils.program_exit then
     ec_debug.pop ('ECE_RULES_PKG.VALIDATE_SHIP_TO_INTRMD_ADD');
     raise;

   WHEN OTHERS THEN
     ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR','PROGRESS_LEVEL', xProgress);
     ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
     ec_debug.pop ('ECE_RULES_PKG.VALIDATE_SHIP_TO_INTRMD_ADD');
     raise ec_utils.program_exit;

END Validate_Ship_To_Intrmd_Add;

PROCEDURE Validate_Ship_To_Int_Address IS

   xProgress                     VARCHAR2(80);
   n_entity_id_pos               NUMBER := NULL;
   n_org_id_pos                  NUMBER := NULL;
   n_addr_id_pos                 NUMBER := NULL;
   n_edi_location_code_pos       NUMBER := NULL;
   n_tp_translator_code_pos      NUMBER := NULL;
   n_tp_location_name_pos        NUMBER := NULL;
   n_addr1_pos                   NUMBER := NULL;
   n_addr2_pos                   NUMBER := NULL;
   n_addr3_pos                   NUMBER := NULL;
   n_addr4_pos                   NUMBER := NULL;
   n_addr_alt_pos                NUMBER := NULL;
   n_city_pos                    NUMBER := NULL;
   n_county_pos                  NUMBER := NULL;
   n_state_pos                   NUMBER := NULL;
   n_zip_pos                     NUMBER := NULL;
   n_province_pos                NUMBER := NULL;
   n_country_pos                 NUMBER := NULL;
   n_region1_pos                 NUMBER := NULL;
   n_region2_pos                 NUMBER := NULL;
   n_region3_pos                 NUMBER := NULL;
   l_action_code                 ece_process_rules.action_code%TYPE;
   l_ignore_flag                 ece_rule_violations.ignore_flag%TYPE;
   l_address                     VARCHAR2(50) := 'ship to internal';

BEGIN

   xProgress := 'ECERULEB-180-1000';
  if ec_debug.G_debug_level >= 2 then
   ec_debug.push ('ECE_RULES_PKG.VALIDATE_SHIP_TO_INT_ADDRESS');
  end if;

   Get_Action_Ignore_Flag (l_action_code, l_ignore_flag);

   if (l_action_code <> g_disabled and l_ignore_flag = 'N') then

      -- get the pl/sql position for address columns.
      xProgress := 'ECERULEB-180-1004';
      ec_utils.find_pos (
         1,
         'ORG_ID',
         n_org_id_pos,
         FALSE);

      xProgress := 'ECERULEB-180-1010';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_INT_LOCATION_ID',
         n_addr_id_pos);

      xProgress := 'ECERULEB-180-1020';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_INT_EDI_LOCATION_CODE',
         n_edi_location_code_pos);

      xProgress := 'ECERULEB-180-1030';
/*      ec_utils.find_pos (
         1,
         'TP_TRANSLATOR_CODE',
         n_tp_translator_code_pos);
bug2151462 */
      xProgress := 'ECERULEB-180-1040';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_INT_LOCATION_NAME',
         n_tp_location_name_pos);

      xProgress := 'ECERULEB-180-1050';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_INT_ADDRESS1',
         n_addr1_pos);

      xProgress := 'ECERULEB-180-1060';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_INT_ADDRESS2',
         n_addr2_pos);

      xProgress := 'ECERULEB-180-1070';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_INT_ADDRESS3',
         n_addr3_pos);

      xProgress := 'ECERULEB-180-1090';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_INT_CITY',
         n_city_pos);

      xProgress := 'ECERULEB-180-1100';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_INT_POSTAL_CODE',
         n_zip_pos);

      xProgress := 'ECERULEB-180-1110';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_INT_COUNTRY',
         n_country_pos);

      xProgress := 'ECERULEB-180-1120';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_INT_REGION1',
         n_region1_pos);

      xProgress := 'ECERULEB-180-1130';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_INT_REGION2',
         n_region2_pos);

      xProgress := 'ECERULEB-180-1140';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_TO_INT_REGION3',
         n_region3_pos);

      xProgress := 'ECERULEB-180-1150';
      Validate_Get_Address_Info (n_entity_id_pos, n_org_id_pos, n_addr_id_pos,
                                 n_edi_location_code_pos, n_tp_translator_code_pos,
                                 n_tp_location_name_pos, n_addr1_pos, n_addr2_pos,
                                 n_addr3_pos, n_addr4_pos, n_addr_alt_pos,
                                 n_city_pos, n_county_pos, n_state_pos, n_zip_pos,
                                 n_province_pos, n_country_pos, n_region1_pos,
                                 n_region2_pos, n_region3_pos, l_address);

   end if;

   xProgress := 'ECERULEB-180-1160';
  if ec_debug.G_debug_level >= 2 then
   ec_debug.pop ('ECE_RULES_PKG.VALIDATE_SHIP_TO_INT_ADDRESS');
 end if;

EXCEPTION
   WHEN ec_utils.program_exit then
     ec_debug.pop ('ECE_RULES_PKG.VALIDATE_SHIP_TO_INT_ADDRESS');
     raise;

   WHEN OTHERS THEN
     ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR','PROGRESS_LEVEL', xProgress);
     ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
     ec_debug.pop ('ECE_RULES_PKG.VALIDATE_SHIP_TO_INT_ADDRESS');
     raise ec_utils.program_exit;

END Validate_Ship_To_Int_Address;


PROCEDURE Validate_Bill_To_Int_Address IS

   xProgress                     VARCHAR2(80);
   n_entity_id_pos               NUMBER := NULL;
   n_org_id_pos                  NUMBER := NULL;
   n_addr_id_pos                 NUMBER := NULL;
   n_edi_location_code_pos       NUMBER := NULL;
   n_tp_translator_code_pos      NUMBER := NULL;
   n_tp_location_name_pos        NUMBER := NULL;
   n_addr1_pos                   NUMBER := NULL;
   n_addr2_pos                   NUMBER := NULL;
   n_addr3_pos                   NUMBER := NULL;
   n_addr4_pos                   NUMBER := NULL;
   n_addr_alt_pos                NUMBER := NULL;
   n_city_pos                    NUMBER := NULL;
   n_county_pos                  NUMBER := NULL;
   n_state_pos                   NUMBER := NULL;
   n_zip_pos                     NUMBER := NULL;
   n_province_pos                NUMBER := NULL;
   n_country_pos                 NUMBER := NULL;
   n_region1_pos                 NUMBER := NULL;
   n_region2_pos                 NUMBER := NULL;
   n_region3_pos                 NUMBER := NULL;
   l_action_code                 ece_process_rules.action_code%TYPE;
   l_ignore_flag                 ece_rule_violations.ignore_flag%TYPE;
   l_address                     VARCHAR2(50) := 'bill to internal';

BEGIN

   xProgress := 'ECERULEB-190-1000';
  if ec_debug.G_debug_level >= 2 then
   ec_debug.push ('ECE_RULES_PKG.VALIDATE_BILL_TO_INT_ADDRESS');
  end if;

   Get_Action_Ignore_Flag (l_action_code, l_ignore_flag);

   if (l_action_code <> g_disabled and l_ignore_flag = 'N') then

      -- get the pl/sql position for address columns.
      xProgress := 'ECERULEB-190-1004';
      ec_utils.find_pos (
         1,
         'ORG_ID',
         n_org_id_pos,
         FALSE);

      xProgress := 'ECERULEB-190-1010';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_TO_INT_LOCATION_ID',
         n_addr_id_pos);

      xProgress := 'ECERULEB-190-1020';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_TO_INT_EDI_LOCATION_CODE',
         n_edi_location_code_pos);

      xProgress := 'ECERULEB-190-1030';
/*      ec_utils.find_pos (
         1,
         'TP_TRANSLATOR_CODE',
         n_tp_translator_code_pos);
bug2151462 */
      xProgress := 'ECERULEB-190-1040';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_TO_INT_LOCATION_NAME',
         n_tp_location_name_pos);

      xProgress := 'ECERULEB-190-1050';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_TO_INT_ADDRESS1',
         n_addr1_pos);

      xProgress := 'ECERULEB-190-1060';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_TO_INT_ADDRESS2',
         n_addr2_pos);

      xProgress := 'ECERULEB-190-1070';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_TO_INT_ADDRESS3',
         n_addr3_pos);

      xProgress := 'ECERULEB-190-1090';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_TO_INT_CITY',
         n_city_pos);

      xProgress := 'ECERULEB-190-1100';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_TO_INT_POSTAL_CODE',
         n_zip_pos);

      xProgress := 'ECERULEB-190-1110';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_TO_INT_COUNTRY',
         n_country_pos);

      xProgress := 'ECERULEB-190-1120';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_TO_INT_REGION1',
         n_region1_pos);

      xProgress := 'ECERULEB-190-1130';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_TO_INT_REGION2',
         n_region2_pos);

      xProgress := 'ECERULEB-190-1140';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_TO_INT_REGION3',
         n_region3_pos);

      xProgress := 'ECERULEB-190-1150';
      Validate_Get_Address_Info (n_entity_id_pos, n_org_id_pos, n_addr_id_pos,
                                 n_edi_location_code_pos, n_tp_translator_code_pos,
                                 n_tp_location_name_pos, n_addr1_pos, n_addr2_pos,
                                 n_addr3_pos, n_addr4_pos, n_addr_alt_pos,
                                 n_city_pos, n_county_pos, n_state_pos, n_zip_pos,
                                 n_province_pos, n_country_pos, n_region1_pos,
                                 n_region2_pos, n_region3_pos, l_address);

   end if;

   xProgress := 'ECERULEB-190-1160';
  if ec_debug.G_debug_level >= 2 then
   ec_debug.pop ('ECE_RULES_PKG.VALIDATE_BILL_TO_INT_ADDRESS');
  end if;

EXCEPTION
   WHEN ec_utils.program_exit then
     ec_debug.pop ('ECE_RULES_PKG.VALIDATE_BILL_TO_INT_ADDRESS');
     raise;

   WHEN OTHERS THEN
     ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR','PROGRESS_LEVEL', xProgress);
     ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
     ec_debug.pop ('ECE_RULES_PKG.VALIDATE_BILL_TO_INT_ADDRESS');
     raise ec_utils.program_exit;

END Validate_Bill_To_Int_Address;


PROCEDURE Validate_Ship_From_Int_Address IS

   xProgress                     VARCHAR2(80);
   n_entity_id_pos               NUMBER := NULL;
   n_org_id_pos                  NUMBER := NULL;
   n_addr_id_pos                 NUMBER := NULL;
   n_edi_location_code_pos       NUMBER := NULL;
   n_tp_translator_code_pos      NUMBER := NULL;
   n_tp_location_name_pos        NUMBER := NULL;
   n_addr1_pos                   NUMBER := NULL;
   n_addr2_pos                   NUMBER := NULL;
   n_addr3_pos                   NUMBER := NULL;
   n_addr4_pos                   NUMBER := NULL;
   n_addr_alt_pos                NUMBER := NULL;
   n_city_pos                    NUMBER := NULL;
   n_county_pos                  NUMBER := NULL;
   n_state_pos                   NUMBER := NULL;
   n_zip_pos                     NUMBER := NULL;
   n_province_pos                NUMBER := NULL;
   n_country_pos                 NUMBER := NULL;
   n_region1_pos                 NUMBER := NULL;
   n_region2_pos                 NUMBER := NULL;
   n_region3_pos                 NUMBER := NULL;
   l_action_code                 ece_process_rules.action_code%TYPE;
   l_ignore_flag                 ece_rule_violations.ignore_flag%TYPE;
   l_address                     VARCHAR2(50) := 'ship from internal';

BEGIN

   xProgress := 'ECERULEB-200-1000';

 if ec_debug.G_debug_level >= 2 then
   ec_debug.push ('ECE_RULES_PKG.VALIDATE_SHIP_FROM_INT_ADDRESS');
 end if;

   Get_Action_Ignore_Flag (l_action_code, l_ignore_flag);

   if (l_action_code <> g_disabled and l_ignore_flag = 'N') then

      -- get the pl/sql position for address columns.
      xProgress := 'ECERULEB-200-1004';
      ec_utils.find_pos (
         1,
         'ORG_ID',
         n_org_id_pos,
         FALSE);

      xProgress := 'ECERULEB-200-1010';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_FROM_INT_LOCATION_ID',
         n_addr_id_pos);

      xProgress := 'ECERULEB-200-1020';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_FROM_INT_EDI_LOCATION_CODE',
         n_edi_location_code_pos);

      xProgress := 'ECERULEB-200-1030';
/*      ec_utils.find_pos (
         1,
         'TP_TRANSLATOR_CODE',
         n_tp_translator_code_pos);
 bug 2151462*/

/* Bug 2570369 : Using the n_tp_translator_code_pos variable to store the position of
         column SHIP_FROM_INT_ORGANIZATION_ID
         Creating a new variable to store the position will require a change in
         in the validate_get_address_info procedure also
*/
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_FROM_INT_ORGANIZATION_ID',
         n_tp_translator_code_pos);

      xProgress := 'ECERULEB-200-1040';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_FROM_INT_LOCATION_NAME',
         n_tp_location_name_pos);

      xProgress := 'ECERULEB-200-1050';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_FROM_INT_ADDRESS1',
         n_addr1_pos);

      xProgress := 'ECERULEB-200-1060';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_FROM_INT_ADDRESS2',
         n_addr2_pos);

      xProgress := 'ECERULEB-200-1070';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_FROM_INT_ADDRESS3',
         n_addr3_pos);

      xProgress := 'ECERULEB-200-1090';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_FROM_INT_CITY',
         n_city_pos);

      xProgress := 'ECERULEB-200-1100';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_FROM_INT_POSTAL_CODE',
         n_zip_pos);

      xProgress := 'ECERULEB-200-1110';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_FROM_INT_COUNTRY',
         n_country_pos);

      xProgress := 'ECERULEB-200-1120';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_FROM_INT_REGION1',
         n_region1_pos);

      xProgress := 'ECERULEB-200-1130';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_FROM_INT_REGION2',
         n_region2_pos);

      xProgress := 'ECERULEB-200-1140';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'SHIP_FROM_INT_REGION3',
         n_region3_pos);

      xProgress := 'ECERULEB-200-1150';
      Validate_Get_Address_Info (n_entity_id_pos, n_org_id_pos, n_addr_id_pos,
                                 n_edi_location_code_pos, n_tp_translator_code_pos,
                                 n_tp_location_name_pos, n_addr1_pos, n_addr2_pos,
                                 n_addr3_pos, n_addr4_pos, n_addr_alt_pos,
                                 n_city_pos, n_county_pos, n_state_pos, n_zip_pos,
                                 n_province_pos, n_country_pos, n_region1_pos,
                                 n_region2_pos, n_region3_pos, l_address);

   end if;

   xProgress := 'ECERULEB-200-1160';
   if ec_debug.G_debug_level >= 2 then
   ec_debug.pop ('ECE_RULES_PKG.VALIDATE_SHIP_FROM_INT_ADDRESS');
  end if;
EXCEPTION
   WHEN ec_utils.program_exit then
     ec_debug.pop ('ECE_RULES_PKG.VALIDATE_SHIP_FROM_INT_ADDRESS');
     raise;

   WHEN OTHERS THEN
     ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR','PROGRESS_LEVEL', xProgress);
     ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
     ec_debug.pop ('ECE_RULES_PKG.VALIDATE_SHIP_FROM_INT_ADDRESS');
     raise ec_utils.program_exit;

END Validate_Ship_From_Int_Address;


PROCEDURE Validate_Bill_From_Int_Address IS

   xProgress                     VARCHAR2(80);
   n_entity_id_pos               NUMBER := NULL;
   n_org_id_pos                  NUMBER := NULL;
   n_addr_id_pos                 NUMBER := NULL;
   n_edi_location_code_pos       NUMBER := NULL;
   n_tp_translator_code_pos      NUMBER := NULL;
   n_tp_location_name_pos        NUMBER := NULL;
   n_addr1_pos                   NUMBER := NULL;
   n_addr2_pos                   NUMBER := NULL;
   n_addr3_pos                   NUMBER := NULL;
   n_addr4_pos                   NUMBER := NULL;
   n_addr_alt_pos                NUMBER := NULL;
   n_city_pos                    NUMBER := NULL;
   n_county_pos                  NUMBER := NULL;
   n_state_pos                   NUMBER := NULL;
   n_zip_pos                     NUMBER := NULL;
   n_province_pos                NUMBER := NULL;
   n_country_pos                 NUMBER := NULL;
   n_region1_pos                 NUMBER := NULL;
   n_region2_pos                 NUMBER := NULL;
   n_region3_pos                 NUMBER := NULL;
   l_action_code                 ece_process_rules.action_code%TYPE;
   l_ignore_flag                 ece_rule_violations.ignore_flag%TYPE;
   l_address                     VARCHAR2(50) := 'bill from internal';

BEGIN

   xProgress := 'ECERULEB-210-1000';
  if ec_debug.G_debug_level >= 2 then
   ec_debug.push ('ECE_RULES_PKG.VALIDATE_BILL_FROM_INT_ADDRESS');
  end if;

   Get_Action_Ignore_Flag (l_action_code, l_ignore_flag);

   if (l_action_code <> g_disabled and l_ignore_flag = 'N') then

      -- get the pl/sql position for address columns.
      xProgress := 'ECERULEB-210-1004';
      ec_utils.find_pos (
         1,
         'ORG_ID',
         n_org_id_pos,
         FALSE);

      xProgress := 'ECERULEB-210-1010';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_FROM_INT_LOCATION_ID',
         n_addr_id_pos);

      xProgress := 'ECERULEB-210-1020';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_FROM_INT_EDI_LOCATION_CODE',
         n_edi_location_code_pos);

      xProgress := 'ECERULEB-210-1030';
/*      ec_utils.find_pos (
         1,
         'TP_TRANSLATOR_CODE',
         n_tp_translator_code_pos);
 bug2151462 */

      xProgress := 'ECERULEB-210-1040';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_FROM_INT_LOCATION_NAME',
         n_tp_location_name_pos);

      xProgress := 'ECERULEB-210-1050';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_FROM_INT_ADDRESS1',
         n_addr1_pos);

      xProgress := 'ECERULEB-210-1060';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_FROM_INT_ADDRESS2',
         n_addr2_pos);

      xProgress := 'ECERULEB-210-1070';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_FROM_INT_ADDRESS3',
         n_addr3_pos);

      xProgress := 'ECERULEB-210-1090';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_FROM_INT_CITY',
         n_city_pos);

      xProgress := 'ECERULEB-210-1100';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_FROM_INT_POSTAL_CODE',
         n_zip_pos);

      xProgress := 'ECERULEB-210-1110';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_FROM_INT_COUNTRY',
         n_country_pos);

      xProgress := 'ECERULEB-210-1120';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_FROM_INT_REGION1',
         n_region1_pos);

      xProgress := 'ECERULEB-210-1130';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_FROM_INT_REGION2',
         n_region2_pos);

      xProgress := 'ECERULEB-210-1140';
      ec_utils.find_pos (
         ec_utils.g_current_level,
         'BILL_FROM_INT_REGION3',
         n_region3_pos);

      xProgress := 'ECERULEB-210-1150';
      Validate_Get_Address_Info (n_entity_id_pos, n_org_id_pos, n_addr_id_pos,
                                 n_edi_location_code_pos, n_tp_translator_code_pos,
                                 n_tp_location_name_pos, n_addr1_pos, n_addr2_pos,
                                 n_addr3_pos, n_addr4_pos, n_addr_alt_pos,
                                 n_city_pos, n_county_pos, n_state_pos, n_zip_pos,
                                 n_province_pos, n_country_pos, n_region1_pos,
                                 n_region2_pos, n_region3_pos, l_address);

   end if;

   xProgress := 'ECERULEB-210-1160';
  if ec_debug.G_debug_level >= 2 then
   ec_debug.pop ('ECE_RULES_PKG.VALIDATE_BILL_FROM_INT_ADDRESS');
  end if;

EXCEPTION
   WHEN ec_utils.program_exit then
     ec_debug.pop ('ECE_RULES_PKG.VALIDATE_BILL_FROM_INT_ADDRESS');
     raise;

   WHEN OTHERS THEN
     ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR','PROGRESS_LEVEL', xProgress);
     ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
     ec_debug.pop ('ECE_RULES_PKG.VALIDATE_BILL_FROM_INT_ADDRESS');
     raise ec_utils.program_exit;

END Validate_Bill_From_Int_Address;


PROCEDURE Validate_Form_Simple_Lookup (
   p_column_name       IN      VARCHAR2,
   p_table_name        IN      VARCHAR2,
   p_where_clause      IN      VARCHAR2,
   x_valid             OUT NOCOPY    BOOLEAN) IS

   l_select                    VARCHAR2(32000);
   l_from                      VARCHAR2(32000);
   l_where                     VARCHAR2(32000);
   l_sel_c                     INTEGER;

BEGIN

   x_valid := True;

   l_select := ' SELECT ' || p_column_name;
   l_from   := ' FROM ' || p_table_name;
   l_select := l_select || l_from;

   if (p_where_clause is not NULL) then
      l_where := ' WHERE ' || p_where_clause;
      l_select := l_select || l_where;
   end if;

   l_sel_c := dbms_sql.open_cursor;

   BEGIN
      dbms_sql.parse (l_sel_c, l_select, dbms_sql.native);
   EXCEPTION
      WHEN OTHERS then
         x_valid := False;
   END;

   dbms_sql.close_cursor (l_sel_c);

EXCEPTION
   WHEN OTHERS THEN
     x_valid := False;
     if (dbms_sql.is_open(l_sel_c)) then
        dbms_sql.close_cursor (l_sel_c);
     end if;
     app_exception.raise_exception;

END Validate_Form_Simple_Lookup;


PROCEDURE Get_Action_Ignore_Flag (
   x_action_code       OUT NOCOPY    VARCHAR2,
   x_ignore_flag       OUT NOCOPY    VARCHAR2) IS

   xProgress                     VARCHAR2(80);
   l_rule_type                   VARCHAR2(80) := g_p_invalid_addr;
   l_rule_id                     NUMBER;
   l_violation_level             VARCHAR2(10) := g_process_rule;
   no_process_rule_info          EXCEPTION;

   CURSOR c_rule_info(
          p_rule_type            VARCHAR2,
          p_transaction_type     VARCHAR2,
          p_map_id               NUMBER) IS
   select process_rule_id, action_code
   from   ece_process_rules
   where  transaction_type = p_transaction_type and
          map_id = p_map_id and
          rule_type = p_rule_type;

   CURSOR c_ignore_flag(
          p_document_id          NUMBER,
          p_rule_id              NUMBER) IS
   select ignore_flag
   from   ece_rule_violations
   where  document_id = p_document_id and
          rule_id     = p_rule_id     and
          violation_level = l_violation_level;

BEGIN
  if ec_debug.G_debug_level >= 2 then
   ec_debug.push ('ECE_RULES_PKG.GET_ACTION_IGNORE_FLAG');
   ec_debug.pl (3, 'g_transaction_type', ec_utils.g_transaction_type);
   ec_debug.pl (3, 'g_document_id', ec_utils.g_document_id);
  end if;

   xProgress := 'ECERULEB-220-1000';
   x_action_code := g_skip_doc;

   xProgress := 'ECERULEB-220-1010';
   open c_rule_info (l_rule_type, ec_utils.g_transaction_type, ec_utils.g_map_id);
   fetch c_rule_info into l_rule_id, x_action_code;

   if c_rule_info%NOTFOUND then
      raise no_process_rule_info;
   end if;
   close c_rule_info;

 if ec_debug.G_debug_level = 3 then
   ec_debug.pl (3, 'rule_type', l_rule_type);
   ec_debug.pl (3, 'action_code', x_action_code);
 end if;

   xProgress := 'ECERULEB-220-1020';
   open c_ignore_flag (ec_utils.g_document_id, l_rule_id);
   fetch c_ignore_flag into x_ignore_flag;

   if c_ignore_flag%NOTFOUND then
      x_ignore_flag := 'N';
   end if;
   close c_ignore_flag;

 if ec_debug.G_debug_level >= 2 then
   ec_debug.pl (3, 'ignore_flag', x_ignore_flag);

   ec_debug.pop ('ECE_RULES_PKG.GET_ACTION_IGNORE_FLAG');
  end if;

EXCEPTION
   WHEN no_process_rule_info then
      if (c_rule_info%ISOPEN) then
         close c_rule_info;
      end if;
      ec_debug.pl (0, 'EC', 'ECE_NO_PROCESS_RULE',
                   'TRANSACTION_TYPE', ec_utils.g_transaction_type,
                   'RULE_TYPE', l_rule_type);
      ec_debug.pop ('ECE_RULES_PKG.GET_ACTION_IGNORE_FLAG');
      raise ec_utils.program_exit;

   WHEN OTHERS THEN
      if (c_rule_info%ISOPEN) then
        close c_rule_info;
      end if;
      if (c_ignore_flag%ISOPEN) then
         close c_ignore_flag;
      end if;
      ec_debug.pl (0, 'EC', 'ECE_PROGRAM_ERROR','PROGRESS_LEVEL', xProgress);
      ec_debug.pl (0, 'EC', 'ECE_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM);
      ec_debug.pop ('ECE_RULES_PKG.GET_ACTION_IGNORE_FLAG');
      raise ec_utils.program_exit;

END Get_Action_Ignore_Flag;


END ECE_RULES_PKG;

/
