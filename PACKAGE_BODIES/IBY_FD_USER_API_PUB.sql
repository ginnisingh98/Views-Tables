--------------------------------------------------------
--  DDL for Package Body IBY_FD_USER_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_FD_USER_API_PUB" AS
/*$Header: ibyfduab.pls 120.11.12010000.11 2010/09/01 16:21:31 gmaheswa ship $*/

--
-- Declare Global variables
--
SRA_INVALID_INSTR EXCEPTION;


-- Data structure to cache instruction access
-- Bug 8850654
  TYPE t_instr_record_type IS RECORD(
   access number
   );

  TYPE instr_table_type IS TABLE OF t_instr_record_type INDEX BY BINARY_INTEGER;

  g_instr_table instr_table_type;


--
-- Forward Declarations
--
PROCEDURE print_debuginfo(p_module IN VARCHAR2,
                          p_debug_text IN VARCHAR2);

PROCEDURE Validate_Method_and_Profile (
     p_api_version              IN   NUMBER,
     p_init_msg_list            IN   VARCHAR2 default FND_API.G_FALSE,
     p_payment_method_code      IN   VARCHAR2,
     p_ppp_id                   IN   NUMBER,
     p_payment_document_id      IN   NUMBER,
     p_crt_instr_flag           IN   VARCHAR2,
     p_int_bank_acc_arr         IN   Int_Bank_Acc_Tab_Type,
     p_le_arr                   IN   Legal_Entity_Tab_Type,
     p_org_arr                  IN   Org_Tab_Type,
     p_curr_arr                 IN   Currency_Tab_Type,
     x_return_status            OUT  NOCOPY VARCHAR2,
     x_msg_count                OUT  NOCOPY NUMBER,
     x_msg_data                 OUT  NOCOPY VARCHAR2
)
IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'Validate_Method_and_Profile';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.Validate_Method_and_Profile';

  l_count              NUMBER;
  l_le_name            VARCHAR2(240);
  l_org_name           VARCHAR2(240);
  l_acc_name           VARCHAR2(240);
  l_profile_name       VARCHAR2(100);
  l_method_name        VARCHAR2(100);
  l_payment_document_id NUMBER;
  l_proc_type          VARCHAR2(30);

  CURSOR method_appl_cur (p_method_code VARCHAR2,
                          p_driver_type VARCHAR2,
                          p_driver_value VARCHAR2)
  IS
    select count(APPLICABLE_PMT_MTHD_ID)
      from iby_applicable_pmt_mthds
     where payment_method_code = p_method_code
       and applicable_type_code = p_driver_type
       and (applicable_value_to is null or applicable_value_to = p_driver_value);

  CURSOR profile_appl_cur (p_profile_id NUMBER,
                           p_driver_type VARCHAR2,
                           p_driver_value VARCHAR2)
  IS
    select count(ap.applicable_pmt_prof_id)
      from iby_applicable_pmt_profs ap,
           iby_payment_profiles p
     where ap.system_profile_code = p.system_profile_code
       and p.payment_profile_id = p_profile_id
       and ap.applicable_type_code = p_driver_type
       and (ap.applicable_value_to is null OR ap.applicable_value_to = p_driver_value);

  CURSOR profile_org_appl_cur (p_profile_id NUMBER,
                               p_driver_id_value VARCHAR2,
                               p_driver_type_value VARCHAR2)
  IS
    select count(ap.applicable_pmt_prof_id)
      from iby_applicable_pmt_profs ap,
           iby_payment_profiles p
     where ap.system_profile_code = p.system_profile_code
       and p.payment_profile_id = p_profile_id
       and ap.applicable_type_code = 'PAYER_ORG'
       and ((ap.applicable_value_to is null AND ap.applicable_value_from is null) OR
            (ap.applicable_value_to = p_driver_id_value AND
             ap.applicable_value_from = p_driver_type_value));


BEGIN
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_payment_method_code is not null THEN
    print_debuginfo(l_module_name,'Payment method ' || p_payment_method_code || ' is to be validated.');

    select payment_method_name
      into l_method_name
      from IBY_PAYMENT_METHODS_VL
     where payment_method_code = p_payment_method_code;

    -- Validate legal entities for the payment method
    IF (p_le_arr.COUNT > 0) THEN
      FOR i in p_le_arr.FIRST..p_le_arr.LAST LOOP
        OPEN method_appl_cur(p_payment_method_code, 'PAYER_LE', to_char(p_le_arr(i)));
        FETCH method_appl_cur INTO l_count;
        CLOSE method_appl_cur;

        IF l_count = 0 THEN
          select name
            into l_le_name
            from XLE_FIRSTPARTY_INFORMATION_V
           where legal_entity_id = p_le_arr(i);

          FND_MESSAGE.set_name('IBY', 'IBY_AP_VLDT_METHOD_LE');
          FND_MESSAGE.SET_TOKEN('METHOD', l_method_name);
          FND_MESSAGE.SET_TOKEN('OBJECT', l_le_name);
          FND_MSG_PUB.Add;

          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END LOOP;
    END IF;

    -- Validate organizations for the payment method
    IF (p_org_arr.COUNT > 0) THEN
      FOR i in p_org_arr.FIRST..p_org_arr.LAST LOOP
        OPEN method_appl_cur(p_payment_method_code, 'PAYER_ORG', to_char(p_org_arr(i).org_id));
        FETCH method_appl_cur INTO l_count;
        CLOSE method_appl_cur;

        IF l_count = 0 THEN
          select name
            into l_org_name
            from HR_ALL_ORGANIZATION_UNITS_VL
           where organization_id = p_org_arr(i).org_id;

          FND_MESSAGE.set_name('IBY', 'IBY_AP_VLDT_METHOD_ORG');
          FND_MESSAGE.SET_TOKEN('METHOD', l_method_name);
          FND_MESSAGE.SET_TOKEN('OBJECT', l_org_name);
          FND_MSG_PUB.Add;

          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END LOOP;
    END IF;

  END IF; -- if payment method is not null

  IF p_ppp_id is not null THEN
    print_debuginfo(l_module_name,'Payment profile ' || p_ppp_id || ' is to be validated.');

    select payment_profile_name
      into l_profile_name
      from IBY_PAYMENT_PROFILES
     where payment_profile_id = p_ppp_id;

    -- Validate legal entities for the payment profile
    IF (p_int_bank_acc_arr.COUNT > 0) THEN
      FOR i in p_int_bank_acc_arr.FIRST..p_int_bank_acc_arr.LAST LOOP
        OPEN profile_appl_cur(p_ppp_id, 'INTERNAL_BANK_ACCOUNT', to_char(p_int_bank_acc_arr(i)));
        FETCH profile_appl_cur INTO l_count;
        CLOSE profile_appl_cur;

        IF l_count = 0 THEN
          select bank_account_name
            into l_acc_name
            from CE_INTERNAL_BANK_ACCOUNTS_V
           where bank_account_id = p_int_bank_acc_arr(i);

          FND_MESSAGE.set_name('IBY', 'IBY_AP_VLDT_PROF_ACC');
          FND_MESSAGE.SET_TOKEN('PROFILE', l_profile_name);
          FND_MESSAGE.SET_TOKEN('OBJECT', l_acc_name);
          FND_MSG_PUB.Add;

          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END LOOP;
    END IF;

    -- Validate organizations for the payment profile
    IF (p_org_arr.COUNT > 0) THEN
      FOR i in p_org_arr.FIRST..p_org_arr.LAST LOOP
        OPEN profile_org_appl_cur(p_ppp_id, p_org_arr(i).org_id, p_org_arr(i).org_type);
        FETCH profile_org_appl_cur INTO l_count;
        CLOSE profile_org_appl_cur;

        IF l_count = 0 THEN
          select name
            into l_org_name
            from HR_ALL_ORGANIZATION_UNITS_VL
           where organization_id = p_org_arr(i).org_id;

          FND_MESSAGE.set_name('IBY', 'IBY_AP_VLDT_PROF_ORG');
          FND_MESSAGE.SET_TOKEN('PROFILE', l_profile_name);
          FND_MESSAGE.SET_TOKEN('OBJECT', l_org_name);
          FND_MSG_PUB.Add;

          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END LOOP;
    END IF;

    -- Validate currencies for the payemnt profile
    IF (p_curr_arr.COUNT > 0) THEN
      FOR i in p_curr_arr.FIRST..p_curr_arr.LAST LOOP
        OPEN profile_appl_cur(p_ppp_id, 'CURRENCY_CODE', p_curr_arr(i));
        FETCH profile_appl_cur INTO l_count;
        CLOSE profile_appl_cur;

        IF l_count = 0 THEN
          FND_MESSAGE.set_name('IBY', 'IBY_AP_VLDT_PROF_CURR');
          FND_MESSAGE.SET_TOKEN('PROFILE', l_profile_name);
          FND_MESSAGE.SET_TOKEN('OBJECT', p_curr_arr(i));
          FND_MSG_PUB.Add;

          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END LOOP;
    END IF;

    -- Validate payment method for the payemnt profile
    IF p_payment_method_code is not null THEN
      select count(ap.applicable_pmt_prof_id)
        into l_count
        from iby_applicable_pmt_profs ap,
             iby_payment_profiles p
       where ap.system_profile_code = p.system_profile_code
         and p.payment_profile_id = p_ppp_id
         and ap.applicable_type_code = 'PAYMENT_METHOD'
         and (ap.applicable_value_to is null OR ap.applicable_value_to = p_payment_method_code);

      IF l_count = 0 THEN
        FND_MESSAGE.set_name('IBY', 'IBY_AP_VLDT_PROF_METHOD');
        FND_MESSAGE.SET_TOKEN('PROFILE', l_profile_name);
        FND_MESSAGE.SET_TOKEN('OBJECT', l_method_name);
        FND_MSG_PUB.Add;

        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

  END IF; -- if payment profile is not null

  -- Validate Create Instruction Flag, etc.
  IF p_crt_instr_flag = 'Y' THEN
     IF p_ppp_id is null THEN
        /*
        FND_MESSAGE.set_name('IBY', 'IBY_BUILD_INV_PARAMS');
        FND_MSG_PUB.Add;

        x_return_status := FND_API.G_RET_STS_ERROR;*/
        print_debuginfo(l_module_name,'Payment profile entry considered optional after bug 8781032');
     ELSE
        IF p_payment_document_id is null THEN
           select nvl(DEFAULT_PAYMENT_DOCUMENT_ID, -1),
                  processing_type
             into l_payment_document_id,
                  l_proc_type
             from iby_payment_profiles
            where payment_profile_id = p_ppp_id;

           IF (l_payment_document_id = -1) and
              (l_proc_type = 'PRINTED') THEN
              FND_MESSAGE.set_name('IBY', 'IBY_APSUB_NO_DEFAULT_PMT_DOC');
              FND_MSG_PUB.Add;

              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
        END IF;
     END IF;
  END IF;

  IF p_payment_document_id is not null THEN
     IF p_ppp_id is null OR p_int_bank_acc_arr.COUNT = 0 THEN
        FND_MESSAGE.set_name('IBY', 'IBY_BUILD_MISS_PMT_DOC_REL_PAR');
        FND_MSG_PUB.Add;

        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
  END IF;

  -- End of API body.

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

  print_debuginfo(l_module_name, 'RETURN Validate_Method_Profile');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
      print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
      print_debuginfo(l_module_name,'SQLerr is :' || substr(SQLERRM, 1, 150));

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
      print_debuginfo(l_module_name,'Unexpected ERROR: Exception occured during call to API ');
      print_debuginfo(l_module_name,'SQLerr is :' || substr(SQLERRM, 1, 150));

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
      print_debuginfo(l_module_name,'Other ERROR: Exception occured during call to API ');
      print_debuginfo(l_module_name,'SQLerr is :' || substr(SQLERRM, 1, 150));

END Validate_Method_and_Profile;

FUNCTION Payment_Instruction_Action (
     p_instruction_status       IN   VARCHAR2
) RETURN VARCHAR2 IS
  l_action VARCHAR2(100);
BEGIN
  if p_instruction_status = 'CREATION_ERROR' then
    l_action := 'IBY_FD_INSTRUCTION_VALIDATE';
  elsif p_instruction_status = 'FORMATTED_READY_TO_TRANSMIT' then
    l_action := 'IBY_FD_INSTRUCTION_TRANSMIT';
  elsif p_instruction_status = 'TRANSMISSION_FAILED' then
    l_action := 'IBY_FD_INSTRUCTION_TRANS_ERR';
  elsif p_instruction_status = 'FORMATTED_READY_FOR_PRINTING' then
    l_action := 'IBY_FD_PAYMENT_PRINT';
  elsif p_instruction_status = 'SUBMITTED_FOR_PRINTING' then
    l_action := 'IBY_FD_INSTRUCTION_DETAIL';
  elsif p_instruction_status = 'CREATED_READY_FOR_PRINTING' then
    l_action := 'IBY_FD_PAYMENT_PRINT';
  elsif p_instruction_status = 'CREATED_READY_FOR_FORMATTING' then
    l_action := 'IBY_FD_PAYMENT_PRINT';
  elsif p_instruction_status = 'FORMATTED' then
    l_action := 'IBY_FD_PAYMENT_PRINT_RECORD';
  elsif p_instruction_status = 'CREATED' then
    l_action := 'IBY_FD_PAYMENT_PRINT';
  elsif p_instruction_status = 'TRANSMITTED' then
    l_action := 'TRANSMITTED_RETRY_COMPLETION';
  else
    l_action := 'Dummy';
  end if;

  return l_action;
EXCEPTION
  when others then
    return 'Dummy';
END Payment_Instruction_Action;

FUNCTION Pmt_Instr_Terminate_Enabled (
     p_instruction_status       IN   VARCHAR2,
     p_instruction_id           IN   NUMBER,
     p_request_id               IN   NUMBER DEFAULT NULL
) RETURN VARCHAR2 IS

  l_action VARCHAR2(100);
  l_request_status VARCHAR2(100);

BEGIN
    IF (p_instruction_status IN ('CREATION_ERROR',
                                 'FORMATTED_READY_TO_TRANSMIT',
                                 'TRANSMISSION_FAILED',
                                 'FORMATTED_READY_FOR_PRINTING',
                                 'CREATED_READY_FOR_PRINTING',
                                 'CREATED_READY_FOR_FORMATTING',
                                 'FORMATTED',
				 'CREATED') AND p_request_id IS NOT NULL) THEN

      l_request_status := iby_disburse_ui_api_pub_pkg.get_conc_request_status(p_request_id);

      IF (l_request_status = 'SUCCESS') THEN
        l_action := 'Terminate_Disabled';
      ELSIF (l_request_status = 'ERROR') THEN
        l_action := 'Terminate_Enabled';
      ELSE
        l_action := 'Terminate_Disabled';
      END IF;

    ELSE
      l_action := 'Terminate_Disabled';
    END IF;

  RETURN l_action;
EXCEPTION
  when others then
    return 'Terminate_Disabled';

END Pmt_Instr_Terminate_Enabled;

FUNCTION Instr_Sec_Terminate_Enabled (
     p_instruction_status       IN   VARCHAR2,
     p_org_id                   IN   NUMBER,
     p_instruction_id           IN   NUMBER,
     p_request_id               IN   NUMBER DEFAULT NULL
) RETURN VARCHAR2 IS

  l_action VARCHAR2(100);
  l_access NUMBER;
  l_request_status VARCHAR2(100);

BEGIN

  if p_org_id is null then
    declare
      d_access NUMBER;
    begin
      select 0
      into   l_access
      from   dual
      where exists
           (select null
            from   iby_payments_all
            where  payment_instruction_id = p_instruction_id
            and    org_id <> -1
            and    MO_GLOBAL.CHECK_ACCESS(org_id) = 'N');

      l_access := 0;

    exception
      when no_data_found then
        l_access := 1;
      when others then
        raise;
    end;

  elsif MO_GLOBAL.CHECK_ACCESS(p_org_id) = 'Y' then
    l_access := 1;
  else
    l_access := 0;
  end if;

  IF NOT (l_access = 1) OR Is_Pmt_Instr_Complete(p_instruction_id)='Y' THEN
    -- If not MOAC access to all payments
    l_action := 'Terminate_Disabled';

  ELSE
    IF (p_instruction_status IN ('CREATION_ERROR',
                                 'FORMATTED_READY_TO_TRANSMIT',
                                 'TRANSMISSION_FAILED',
                                 'FORMATTED_READY_FOR_PRINTING',
                                 'CREATED_READY_FOR_PRINTING',
                                 'CREATED_READY_FOR_FORMATTING',
                                 'FORMATTED',
				 'CREATED') AND p_request_id IS NOT NULL) THEN

      l_request_status := iby_disburse_ui_api_pub_pkg.get_conc_request_status(p_request_id);

      IF (l_request_status = 'SUCCESS') THEN
        l_action := 'Terminate_Disabled';
      ELSIF (l_request_status = 'ERROR') THEN
        l_action := 'Terminate_Enabled';
      ELSE
        l_action := 'Terminate_Disabled';
      END IF;

    ELSE
      l_action := 'Terminate_Disabled';
    END IF;
  END IF;

  RETURN l_action;
EXCEPTION
  when others then
    return 'Terminate_Disabled';

END Instr_Sec_Terminate_Enabled;


FUNCTION Pmt_Instr_Action_Enabled (
     p_instruction_status       IN   VARCHAR2,
     p_org_id                   IN   NUMBER,
     p_instruction_id           IN   NUMBER,
     p_request_id               IN   NUMBER DEFAULT NULL
) RETURN VARCHAR2 IS

  l_action VARCHAR2(100);
  l_access NUMBER;
  l_request_status VARCHAR2(100);

BEGIN
  if p_org_id is null then
      IF(g_instr_table.EXISTS(p_instruction_id) AND g_instr_table(p_instruction_id).access IS NOT NULL) THEN
          l_access := g_instr_table(p_instruction_id).access;
      ELSE
		    begin
		      select 0
		      into   l_access
		      from   dual
		      where exists
			   (select null
			    from   iby_payments_all
			    where  payment_instruction_id = p_instruction_id
			    and    org_id <> -1
			    and    MO_GLOBAL.CHECK_ACCESS(org_id) = 'N');

		      l_access := 0;

		    exception
		      when no_data_found then
			l_access := 1;
		      when others then
			raise;
		    end;
             g_instr_table(p_instruction_id).access := l_access;
     END IF;
  elsif MO_GLOBAL.CHECK_ACCESS(p_org_id) = 'Y' then
    l_access := 1;
  else
    l_access := 0;
  end if;

  IF NOT (l_access = 1) OR (p_instruction_status = 'CREATED' and Is_Pmt_Instr_Complete(p_instruction_id)='Y') THEN
    -- If not MOAC access to all payments
    l_action := 'TakeActionDisabled';

  ELSE
    IF (p_instruction_status IN ('CREATION_ERROR',
                                 'FORMATTED_READY_TO_TRANSMIT',
                                 'TRANSMISSION_FAILED',
                                 'FORMATTED_READY_FOR_PRINTING',
                                 'SUBMITTED_FOR_PRINTING',
                                 'CREATED_READY_FOR_PRINTING',
                                 'CREATED_READY_FOR_FORMATTING',
                                 'FORMATTED',
				 'CREATED')) THEN

      l_request_status := iby_disburse_ui_api_pub_pkg.get_conc_request_status(p_request_id);

      IF (l_request_status = 'SUCCESS') THEN
        l_action := 'TakeActionEnabled';
      ELSIF (l_request_status = 'ERROR') THEN
          l_action := 'WarningIndEvenActive';
      ELSE
        l_action := 'InProgressIndStatus';
      END IF;
    ELSE
   	IF ((p_instruction_status = 'TRANSMITTED') AND (Is_transmitted_Pmt_Inst_Compl(p_instruction_id) = 'N'))THEN
	  l_action := 'TakeActionEnabled';
	ELSE
          l_action := 'TakeActionDisabled';
        END IF;
    END IF;
  END IF;

  RETURN l_action;
EXCEPTION
  when others then
    return 'TakeActionDisabled';

END Pmt_Instr_Action_Enabled;

PROCEDURE retrieve_default_sra_format(
     p_api_version              IN   NUMBER,
     p_init_msg_list            IN   VARCHAR2 default FND_API.G_FALSE,
     p_instr_id                 IN   NUMBER,
     x_default_sra_format_code  OUT  NOCOPY VARCHAR2,
     x_default_sra_format_name  OUT  NOCOPY VARCHAR2,
     x_return_status            OUT  NOCOPY VARCHAR2,
     x_msg_count                OUT  NOCOPY NUMBER,
     x_msg_data                 OUT  NOCOPY VARCHAR2)
IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'Validate_Method_and_Profile';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.retrieve_default_sra_format';

  l_instr_sra_ok NUMBER;
BEGIN
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_instr_id is null THEN
    FND_MESSAGE.set_name('IBY', 'IBY_SRA_SUBMIT_INVALID_INSTR');
    FND_MESSAGE.SET_TOKEN('INSTR_ID', p_instr_id);
    FND_MSG_PUB.Add;
    raise SRA_INVALID_INSTR;
  END IF;

  select count(*)
    into l_instr_sra_ok
    from IBY_PAY_INSTRUCTIONS_ALL
   where generate_sep_remit_advice_flag = 'Y'
     and (REMITTANCE_ADVICE_CREATED_FLAG = 'N' or
          IBY_FD_POST_PICP_PROGS_PVT.get_allow_multiple_sra_flag(p_instr_id) = 'Y')
     and payment_instruction_status not in ('CREATION_ERROR', 'RETRY_CREATION', 'TERMINATED')
     and IBY_FD_POST_PICP_PROGS_PVT.val_instruction_accessible(p_instr_id) = 'Y';

  IF l_instr_sra_ok = 0 THEN
    FND_MESSAGE.set_name('IBY', 'IBY_SRA_SUBMIT_INVALID_INSTR');
    FND_MESSAGE.SET_TOKEN('INSTR_ID', p_instr_id);
    FND_MSG_PUB.Add;
    raise SRA_INVALID_INSTR;
  ELSE
    select sra_setup.remittance_advice_format_code,
           f.format_name
      into x_default_sra_format_code,
           x_default_sra_format_name
      from iby_pay_instructions_all ins,
           iby_payment_profiles pp,
           iby_remit_advice_setup sra_setup,
           iby_formats_vl f
     where ins.payment_instruction_id = p_instr_id
       and pp.payment_profile_id = ins.payment_profile_id
       and pp.system_profile_code = sra_setup.system_profile_code
       and sra_setup.remittance_advice_format_code = f.FORMAT_CODE (+);
  END IF;

  -- End of API body.

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

  print_debuginfo(l_module_name, 'RETURN retrieve_default_sra_format');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
      print_debuginfo(l_module_name,'ERROR: Exception occured during call to API ');
      print_debuginfo(l_module_name,'SQLerr is :' || substr(SQLERRM, 1, 150));

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
      print_debuginfo(l_module_name,'Unexpected ERROR: Exception occured during call to API ');
      print_debuginfo(l_module_name,'SQLerr is :' || substr(SQLERRM, 1, 150));

    WHEN SRA_INVALID_INSTR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
      print_debuginfo(l_module_name,'ERROR: The payment instruction is not available for SRA. ');

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
      print_debuginfo(l_module_name,'Other ERROR: Exception occured during call to API ');
      print_debuginfo(l_module_name,'SQLerr is :' || substr(SQLERRM, 1, 150));

END retrieve_default_sra_format;


--
--
--
PROCEDURE print_debuginfo(p_module IN VARCHAR2,
                          p_debug_text IN VARCHAR2)
IS
BEGIN
  --
  -- Writing debug text to the pl/sql debug file.
  --
  FND_FILE.PUT_LINE(FND_FILE.LOG, p_module||p_debug_text);

  IBY_DEBUG_PUB.add(substr(RPAD(p_module,55)||' : '|| p_debug_text, 0, 150),
                    FND_LOG.G_CURRENT_RUNTIME_LEVEL,
                    G_DEBUG_MODULE);

END print_debuginfo;


FUNCTION Is_Pmt_Instr_Complete (
     p_instruction_id           IN   NUMBER
) RETURN VARCHAR2 IS

  l_complete_code VARCHAR2(30);

BEGIN

  SELECT payments_complete_code
  INTO l_complete_code
  FROM iby_pay_instructions_all
  WHERE payment_instruction_id = p_instruction_id;

  IF (l_complete_code = 'YES') THEN
   RETURN 'Y';
  ELSE
   RETURN 'N';
  END IF;

END Is_Pmt_Instr_Complete;

FUNCTION Is_transmitted_Pmt_Inst_Compl (
     p_instruction_id           IN   NUMBER
) RETURN VARCHAR2 IS

  l_complete_code VARCHAR2(30);
l_mark_complete_event VARCHAR2(30);
BEGIN

  SELECT inst.payments_complete_code, pp.mark_complete_event
  INTO l_complete_code, l_mark_complete_event
  FROM iby_pay_instructions_all inst, iby_payment_profiles pp
     WHERE inst.payment_profile_id = pp.payment_profile_id
       AND inst.payment_instruction_id = p_instruction_id;

  IF (l_complete_code = 'YES') THEN
   RETURN 'Y';
  ELSIF l_mark_complete_event <> 'TRANSMITTED' THEN
   RETURN 'Y';
  ELSE
   RETURN 'N';
  END IF;

END Is_transmitted_Pmt_Inst_Compl;


FUNCTION Pmt_Instr_Terminate_Allowed (
     p_instruction_id           IN   NUMBER
) RETURN VARCHAR2 IS

  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.Pmt_Instr_Terminate_Allowed';
  l_allowed VARCHAR2(20) :='NO';
  l_request_status VARCHAR2(100);
  l_instruction_status varchar2(30);
  l_pmt_complete_code varchar2(30);
  l_process_type varchar2(30);
  l_request_id number(15);

BEGIN

     print_debuginfo(l_module_name,'Enter');

      FND_MSG_PUB.initialize;

     print_debuginfo(l_module_name,'Instruction Id::'||p_instruction_id);


select PAYMENT_INSTRUCTION_STATUS,
       PROCESS_TYPE,
       PAYMENTS_COMPLETE_CODE,
       REQUEST_ID
into   l_instruction_status,
       l_process_type,
       l_pmt_complete_code,
       l_request_id
from iby_pay_instructions_all
where payment_instruction_id = p_instruction_id;

     print_debuginfo(l_module_name,'Instruction Status::'||l_instruction_status);
     print_debuginfo(l_module_name,'Process Type::'||l_process_type);
     print_debuginfo(l_module_name,'Payment Complete Code::'||l_pmt_complete_code);
     print_debuginfo(l_module_name,'Request Id::'||l_request_id);

    IF(l_instruction_status = 'SUBMITTED_FOR_PRINTING')
    THEN
            FND_MESSAGE.set_name('IBY', 'IBY_INSTR_TERM_SUB_PRNT');
	    FND_MSG_PUB.Add;
    ELSIF(l_process_type = 'IMMEDIATE')
    THEN
            FND_MESSAGE.set_name('IBY', 'IBY_INSTR_TERM_SING_PMT');
	    FND_MSG_PUB.Add;
    ELSIF(l_pmt_complete_code = 'YES')
    THEN
            FND_MESSAGE.set_name('IBY', 'IBY_INSTR_TERM_COMP');
	    FND_MSG_PUB.Add;
    ELSIF(l_instruction_status IN ('CREATION_ERROR',
				   'FORMATTED_READY_TO_TRANSMIT' ,
				   'TRANSMISSION_FAILED',
				   'FORMATTED_READY_FOR_PRINTING',
				   'FORMATTED_ELECTRONIC',
				   'FORMATTED',
				   'CREATED_READY_FOR_PRINTING',
				   'CREATED_READY_FOR_FORMATTING',
				   'CREATED'))THEN

              IF(l_request_id is not null) THEN
		      l_request_status := iby_disburse_ui_api_pub_pkg.get_conc_request_status(l_request_id);

		      IF (l_request_status = 'SUCCESS') THEN
			l_allowed := 'YES';
		      ELSIF (l_request_status = 'ERROR') THEN
			l_allowed := 'YES';
		      ELSE
			       FND_MESSAGE.set_name('IBY', 'IBY_INSTR_TERM_FRMT_PRG');
			       FND_MSG_PUB.Add;
		      END IF;
	      ELSE
	            l_allowed := 'YES';
              END IF;
    END IF;
       print_debuginfo(l_module_name,'Return Variable::'||l_allowed);
       print_debuginfo(l_module_name,'Exit');

return 	l_allowed;

END Pmt_Instr_Terminate_Allowed;


FUNCTION Pmt_Instr_Sec_Term_Allowed (
     p_instruction_status       IN   VARCHAR2,
     p_process_type             IN   VARCHAR2,
     p_instruction_id           IN   NUMBER,
     p_org_id                   IN   NUMBER,
     p_pmt_complete_code        IN   VARCHAR2,
     p_request_id               IN   NUMBER DEFAULT NULL,
     p_msg_req                  IN   VARCHAR2 DEFAULT 'Y'
) RETURN VARCHAR2 IS

  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.Pmt_Instr_Sec_Term_Allowed';
  l_access NUMBER;
  l_allowed VARCHAR2(20) :='NO';
  l_request_status VARCHAR2(100);

BEGIN

     print_debuginfo(l_module_name,'Enter');
     print_debuginfo(l_module_name,'Instruction Status::'||p_instruction_status);
     print_debuginfo(l_module_name,'Process Type::'||p_process_type);
     print_debuginfo(l_module_name,'Instruction Id::'||p_instruction_id);
     print_debuginfo(l_module_name,'Org Id::'||p_org_id);
     print_debuginfo(l_module_name,'Payment Complete Code::'||p_pmt_complete_code);
     print_debuginfo(l_module_name,'Request Id::'||p_request_id);
      FND_MSG_PUB.initialize;


  if p_org_id is null then

    begin
      select 0
      into   l_access
      from   dual
      where exists
           (select null
            from   iby_payments_all
            where  payment_instruction_id = p_instruction_id
            and    org_id <> -1
            and    MO_GLOBAL.CHECK_ACCESS(org_id) = 'N');

      l_access := 0;

    exception
      when no_data_found then
        l_access := 1;
      when others then
        raise;
    end;

  elsif MO_GLOBAL.CHECK_ACCESS(p_org_id) = 'Y' then
    l_access := 1;
  else
    l_access := 0;
  end if;

  IF NOT(l_access = 1)  THEN
    -- If not MOAC access to all payments
    l_allowed := 'NO';
    IF(p_msg_req = 'Y') THEN
	    FND_MESSAGE.set_name('IBY', 'IBY_INSTR_TERM_INV_ACCESS');
	    FND_MSG_PUB.Add;
    END IF;

  ELSE


	    IF(p_instruction_status = 'SUBMITTED_FOR_PRINTING')
	    THEN
	            l_allowed := 'NO';
		    IF(p_msg_req = 'Y') THEN
			    FND_MESSAGE.set_name('IBY', 'IBY_INSTR_TERM_SUB_PRNT');
			    FND_MSG_PUB.Add;
		    END IF;
	    ELSIF(p_process_type = 'IMMEDIATE')
	    THEN
	            l_allowed := 'NO';
		    IF(p_msg_req = 'Y') THEN
			    FND_MESSAGE.set_name('IBY', 'IBY_INSTR_TERM_SING_PMT');
			    FND_MSG_PUB.Add;
		    END IF;
	    ELSIF(p_pmt_complete_code = 'YES')
	    THEN
	            l_allowed := 'NO';
		    IF(p_msg_req = 'Y') THEN
			    FND_MESSAGE.set_name('IBY', 'IBY_INSTR_TERM_COMP');
			    FND_MSG_PUB.Add;
		    END IF;
	    ELSIF(p_instruction_status IN ('CREATION_ERROR',
					   'FORMATTED_READY_TO_TRANSMIT' ,
					   'TRANSMISSION_FAILED',
					   'FORMATTED_READY_FOR_PRINTING',
					   'FORMATTED_ELECTRONIC',
					   'FORMATTED',
					   'CREATED_READY_FOR_PRINTING',
					   'CREATED_READY_FOR_FORMATTING',
					   'CREATED'))THEN

		      IF(p_request_id is not null) THEN
			      l_request_status := iby_disburse_ui_api_pub_pkg.get_conc_request_status(p_request_id);

			      IF (l_request_status = 'SUCCESS') THEN
				l_allowed := 'YES';
			      ELSIF (l_request_status = 'ERROR') THEN
				l_allowed := 'YES';
			      ELSE
			               l_allowed := 'NO';
				       IF(p_msg_req = 'Y') THEN
					       FND_MESSAGE.set_name('IBY', 'IBY_INSTR_TERM_FRMT_PRG');
					       FND_MSG_PUB.Add;
				       END IF;

			      END IF;
		      ELSE
			    l_allowed := 'YES';
		      END IF;
	    END IF;
    END IF;
       print_debuginfo(l_module_name,'Return Variable::'||l_allowed);
       print_debuginfo(l_module_name,'Exit');

return 	l_allowed;

END Pmt_Instr_Sec_Term_Allowed;


FUNCTION PPR_Sec_Term_Allowed (
     p_pay_service_req_id  IN   NUMBER
) RETURN VARCHAR2 IS

l_allowed VARCHAR2(20):= 'YES';
l_instruction_status VARCHAR2(30);
l_process_type       VARCHAR2(30);
l_instruction_id     NUMBER(15);
l_org_id             NUMBER(15);
l_pmt_complete_code  VARCHAR2(30);
l_request_id         NUMBER(15);

CURSOR instr_for_ppr(ppr_id number) is
SELECT PAYMENT_INSTRUCTION_STATUS,
       PROCESS_TYPE,
       PAYMENT_INSTRUCTION_ID,
       ORG_ID,
       PAYMENTS_COMPLETE_CODE,
       REQUEST_ID
FROM IBY_PAY_INSTRUCTIONS_ALL INSTR
WHERE EXISTS (SELECT 'PAYMENTS'
              FROM IBY_PAYMENTS_ALL PMT
	      WHERE PMT.PAYMENT_SERVICE_REQUEST_ID= ppr_id
	      AND PMT.PAYMENT_INSTRUCTION_ID =  InStr.PAYMENT_INSTRUCTION_ID);

BEGIN
      FND_MSG_PUB.initialize;

    OPEN instr_for_ppr(p_pay_service_req_id);
    loop
       FETCH instr_for_ppr INTO l_instruction_status,
				l_process_type,
				l_instruction_id,
				l_org_id,
				l_pmt_complete_code,
				l_request_id ;
	exit when instr_for_ppr%NOTFOUND;


        l_allowed :=   Pmt_Instr_Sec_Term_Allowed (
				     l_instruction_status,
				     l_process_type,
				     l_instruction_id,
				     l_org_id,
				     l_pmt_complete_code,
				     l_request_id,
				     'N'
                                       );
        IF(l_allowed = 'NO') THEN
	   return l_allowed;
	END IF;
   end loop;
return l_allowed;
END PPR_Sec_Term_Allowed;


END IBY_FD_USER_API_PUB;

/
