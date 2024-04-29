--------------------------------------------------------
--  DDL for Package Body PER_IN_ORG_INFO_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_IN_ORG_INFO_LEG_HOOK" AS
/* $Header: peinlhoi.pkb 120.22.12010000.5 2009/10/06 12:07:29 lnagaraj ship $ */
   g_package      CONSTANT VARCHAR2(30) := 'per_in_org_info_leg_hook.';
   g_debug        BOOLEAN;
   p_token_name   pay_in_utils.char_tab_type;
   p_token_value  pay_in_utils.char_tab_type;
   p_message_name VARCHAR2(30);


--------------------------------------------------------------------------
-- Name           : CHECK_UNIQUE_NUM_INS                                --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure is the driver procedure for the validation--
--                  of the Organizaition Information data for the       --
--                  context IN_CONTRACTOR_INFO.                         --
--                  This procedure is the hook procedure for            --
--                  for org information when org info is updated        --
-- Parameters     :                                                     --
--             IN : p_org_info_type_code    VARCHAR2                    --
--                  p_org_information1      VARCHAR2                    --
--                  p_org_information2      VARCHAR2                    --
--                  p_org_information3      VARCHAR2                    --
--                  p_org_information4      VARCHAR2                    --
--                  p_org_information5      VARCHAR2                    --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                    --
--------------------------------------------------------------------------
-- 1.0   16-May-2005    sukukuma       created this procedure           --
--------------------------------------------------------------------------
PROCEDURE check_unique_num_ins (p_org_info_type_code   IN VARCHAR2
                               ,p_org_information1     IN VARCHAR2
                               ,p_org_information2     IN VARCHAR2
                               ,p_org_information3     IN VARCHAR2
                               ,p_org_information4     IN VARCHAR2
                               ,p_org_information5     IN VARCHAR2) IS
BEGIN
NULL;
END check_unique_num_ins;


--------------------------------------------------------------------------
-- Name           : CHECK_UNIQUE_NUM_UPD                                --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure is the driver procedure for the validation--
--                  of the Organizaition Information data for the       --
--                  context IN_CONTRACTOR_INFO.                         --
--                  This procedure is the hook procedure for            --
--                  for org information when org info is updated        --
-- Parameters     :                                                     --
--             IN : p_org_information_id    NUMBER                      --
--                  p_org_info_type_code    VARCHAR2                    --
--                  p_org_information1      VARCHAR2                    --
--                  p_org_information2      VARCHAR2                    --
--                  p_org_information3      VARCHAR2                    --
--                  p_org_information4      VARCHAR2                    --
--                  p_org_information5      VARCHAR2                    --
--            OUT : 3                                                   --
--         RETURN : N/A                                                 --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                    --
--------------------------------------------------------------------------
-- 1.0   16-May-2005    sukukuma        Modified this procedure         --
--------------------------------------------------------------------------
PROCEDURE check_unique_num_upd (p_org_information_id   IN  NUMBER
                               ,p_org_info_type_code   IN VARCHAR2
                               ,p_org_information1     IN VARCHAR2
                               ,p_org_information2     IN VARCHAR2
                               ,p_org_information3     IN VARCHAR2
                               ,p_org_information4     IN VARCHAR2
                               ,p_org_information5     IN VARCHAR2)IS
BEGIN
NULL;
END check_unique_num_upd;

---------------------------------------------------------------------------
 --                                                                      --
 -- Name           : check_rep_ins                                       --
 -- Type           : Procedure                                           --
 -- Access         : Public                                              --
 -- Description    : Procedure is the driver procedure for the validation--
 --                  of the dates,so that they do not overlap.This also  --
 --                  performs PAN Validation and uniqueness checking of  --
 --                  TAN ,IF applicable.This is the hook procedure for   --
 --                  organization information when representative details--
 --                  are inserted.                                       --
 -- Parameters     :                                                     --
 --             IN : p_org_information1      VARCHAR2                    --
 --                  p_org_information2      VARCHAR2                    --
 --                  p_org_information3      VARCHAR2                    --
 --                  p_organization_id       NUMBER                      --
 --                  p_org_info_type_code    VARCHAR2                    --
 --                                                                      --
 --            OUT : N/A                                                 --
 --         RETURN : N/A                                                 --
-- Change History :                                                      --
---------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                     --
---------------------------------------------------------------------------
-- 1.0   16-May-2005    sukukuma        Modified this procedure          --
---------------------------------------------------------------------------
PROCEDURE check_rep_ins(p_org_information1   IN VARCHAR2
                       ,p_org_information2   IN VARCHAR2
                       ,p_org_information3   IN VARCHAR2
                       ,p_organization_id    IN NUMBER
                       ,p_org_info_type_code IN VARCHAR2)IS
BEGIN
NULL;
END  check_rep_ins;

 --------------------------------------------------------------------------
 --                                                                      --
 -- Name           : check_rep_upd                                       --
 -- Type           : Procedure                                           --
 -- Access         : Public                                              --
 -- Description    : Procedure is the driver procedure for the validation--
 --                  of the dates,so that they do not overlap.           --
 --                  This is the hook procedure for the                  --
 --                  organization information type when representative   --
 --                  details is updated.                                 --
 -- Parameters     :                                                     --
 --             IN : p_org_information1      VARCHAR2                    --
 --                  p_org_information2      VARCHAR2                    --
 --                  p_org_information3      VARCHAR2                    --
 --                  p_org_information_id  NUMBER                        --
 --                  p_org_info_type_code  VARCHAR2                      --
 --                                                                      --
 --            OUT : N/A                                                 --
 --         RETURN : N/A                                                 --
-- Change History :                                                      --
---------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                     --
---------------------------------------------------------------------------
-- 1.0   16-May-2005    sukukuma        Modified this procedure          --
---------------------------------------------------------------------------
PROCEDURE check_rep_upd(p_org_information1   IN VARCHAR2
                       ,p_org_information2   IN VARCHAR2
                       ,p_org_information3   IN VARCHAR2
                       ,p_org_information_id IN NUMBER
                       ,p_org_info_type_code IN VARCHAR2)IS
BEGIN
NULL;
END check_rep_upd;



--------------------------------------------------------------------------
-- Name           : CHECK_UNIQUE_NUM_INS                                --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure is the driver procedure for the validation--
--                  of the Organizaition Information data for the       --
--                  context IN_CONTRACTOR_INFO.                         --
--                  This procedure is the hook procedure for            --
--                  for org information when org info is updated        --
-- Parameters     :                                                     --
--             IN : p_org_info_type_code    VARCHAR2                    --
--                  p_org_information1      VARCHAR2                    --
--                  p_org_information2      VARCHAR2                    --
--                  p_org_information3      VARCHAR2                    --
--                  p_org_information4      VARCHAR2                    --
--                  p_org_information5      VARCHAR2                    --
--            OUT : p_message_name          VARCHAR2                    --
--                  p_token_name            VARCHAR2                    --
--                  p_token_value           VARCHAR2                    --
--            OUT : 3                                                   --
--         RETURN : N/A                                                 --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                    --
--------------------------------------------------------------------------
-- 1.0   16-May-2005    sukukuma       created this procedure           --
-- 1.1   11-Sep-2007    Sivanara       Added parameters                 --
--                                      1.p_org_information11           --
--					2.p_org_information12           --
--				       Also added code to check the     --
--                                     uniquess of                      --
--                                     1.Business Number                --
--                                     2.Cheque Number                  --
--                                     3.Challan Reference Number       --
--------------------------------------------------------------------------

PROCEDURE check_unique_num_ins (p_org_info_type_code   IN VARCHAR2
                               ,p_org_information1     IN VARCHAR2
                               ,p_org_information2     IN VARCHAR2
                               ,p_org_information3     IN VARCHAR2
                               ,p_org_information4     IN VARCHAR2
                               ,p_org_information5     IN VARCHAR2
                               ,p_org_information6     IN VARCHAR2
                               ,p_org_information11    IN VARCHAR2
                               ,p_org_information12    IN VARCHAR2
                               ,p_organization_id      IN NUMBER DEFAULT NULL
                               ,p_message_name         OUT NOCOPY VARCHAR2
                               ,p_token_name           OUT NOCOPY pay_in_utils.char_tab_type
                               ,p_token_value          OUT NOCOPY pay_in_utils.char_tab_type
) AS

     l_reg_num           VARCHAR2(1);
     l_lic_num           VARCHAR2(1);
     l_pf_num            VARCHAR2(1);
     l_esi_num           VARCHAR2(1);
     l_pan_num           VARCHAR2(1);
     l_receipt_num       VARCHAR2(1);
     l_ref_num           VARCHAR2(1);
     l_bus_numb_pf       VARCHAR2(1);
     l_challan_ref_no    VARCHAR2(1);
     l_chq_dd_no         VARCHAR2(1);
     l_pf_bnk_brnch_dtls VARCHAR2(1);
     l_org_info          hr_organization_information.org_information1%type;
     l_procedure         VARCHAR2(100);
     l_message           VARCHAR2(300);

     CURSOR chk_unique_reg (p_org_info VARCHAR2) IS
      SELECT 'X'
      FROM hr_organization_information
      WHERE org_information_context = 'IN_CONTRACTOR_INFO'
      AND   org_information1 = p_org_info;

     CURSOR chk_unique_license (p_org_info VARCHAR2) IS
      SELECT 'X'
      FROM hr_organization_information
      WHERE org_information_context = 'IN_CONTRACTOR_INFO'
      AND   org_information2 = p_org_info;

     CURSOR chk_unique_pf (p_org_info VARCHAR2) IS
      SELECT 'X'
      FROM hr_organization_information
      WHERE org_information_context = 'IN_CONTRACTOR_INFO'
      AND   org_information3 = p_org_info;

     CURSOR chk_unique_esi (p_org_info VARCHAR2) IS
      SELECT 'X'
      FROM hr_organization_information
      WHERE org_information_context = 'IN_CONTRACTOR_INFO'
      AND   org_information4 = p_org_info;

     CURSOR chk_unique_pan (p_org_info VARCHAR2) IS
      SELECT 'X'
      FROM hr_organization_information
      WHERE org_information_context = 'IN_CONTRACTOR_INFO'
      AND   org_information5 = p_org_info;

     CURSOR chk_unique_ref_no (p_org_info VARCHAR2, p_organization_id NUMBER, p_org_information6 VARCHAR2) IS
      SELECT 'X'
      FROM hr_organization_information
      WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
      AND   organization_id = p_organization_id
      AND   org_information6 = p_org_information6
      AND   org_information3 = p_org_info;

     CURSOR chk_unique_receipt_no (p_org_info VARCHAR2, p_organization_id NUMBER, p_org_information6 VARCHAR2) IS
      SELECT 'X'
      FROM hr_organization_information
      WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
      AND   organization_id = p_organization_id
      AND   org_information6 = p_org_information6
      AND   org_information4 = p_org_info;

     CURSOR chk_unique_bus_no_pf (p_org_info VARCHAR2) IS
      SELECT 'X'
      FROM hr_organization_information
      WHERE org_information_context = 'PER_IN_COMPANY_DF'
      AND   org_information5 = p_org_info;

     CURSOR chk_unique_chn_no_pf (p_org_info VARCHAR2) IS
      SELECT 'X'
      FROM hr_organization_information
      WHERE org_information_context = 'PER_IN_PF_CHALLAN_INFO'
      AND org_information12 = p_org_info;

     CURSOR chk_unq_chn_no_pf_7q (p_org_info VARCHAR2) IS
      SELECT 'X'
      FROM hr_organization_information
      WHERE org_information_context = 'PER_IN_PF_SEC7Q_INFO'
      AND org_information11 = p_org_info;

     CURSOR chk_unq_chn_no_pf_14b (p_org_info VARCHAR2) IS
      SELECT 'X'
      FROM hr_organization_information
      WHERE org_information_context = 'PER_IN_PF_CHN_SEC14B'
      AND org_information1 = p_org_info;

     CURSOR chk_unq_chn_no_pf_oth (p_org_info VARCHAR2,p_org_info_type_code varchar2) IS
      SELECT 'X'
      FROM hr_organization_information
      WHERE org_information_context = p_org_info_type_code
      AND org_information3 = p_org_info;

    CURSOR chk_unique_chq_no_pf (p_org_info VARCHAR2) IS
      SELECT 'X'
      FROM hr_organization_information
      WHERE org_information_context = 'PER_IN_PF_BANK_PAYMENT_DETAILS'
      AND   org_information5 = p_org_info;

     CURSOR chk_unq_chn_bnk_brnch_dtls IS
     SELECT 'X'
     FROM hr_organization_information
     WHERE org_information_context = 'PER_IN_PF_BANK_BRANCH_DTLS'
     AND org_information1 = p_org_information1
     AND org_information2 = p_org_information2
     AND organization_id = p_organization_id;
  BEGIN

  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'IN') THEN
       IF g_debug THEN
          pay_in_utils.trace('IN Legislation not installed. Not performing the validations',NULL);
       END IF;
       pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
       RETURN;
  END IF;

  l_procedure := g_package||'check_unique_num_ins';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_org_info_type_code',p_org_info_type_code);
       pay_in_utils.trace('p_org_information1  ',p_org_information1  );
       pay_in_utils.trace('p_org_information2  ',p_org_information2  );
       pay_in_utils.trace('p_org_information3  ',p_org_information3  );
       pay_in_utils.trace('p_org_information4  ',p_org_information4  );
       pay_in_utils.trace('p_org_information5  ',p_org_information5  );
       pay_in_utils.trace('p_org_information6  ',p_org_information6  );
       pay_in_utils.trace('p_org_information11  ',p_org_information11  );
       pay_in_utils.trace('p_org_information12  ',p_org_information12  );
       pay_in_utils.trace('p_organization_id   ',p_organization_id   );
       pay_in_utils.trace('p_message_name      ',p_message_name      );
       pay_in_utils.trace('**************************************************','********************');
   END IF;


  IF  p_org_info_type_code = 'IN_CONTRACTOR_INFO' THEN

        /* Check for Registration Number */
         OPEN chk_unique_reg(p_org_information1);
         FETCH chk_unique_reg INTO l_reg_num;
         CLOSE chk_unique_reg;

         IF l_reg_num = 'X' THEN
          IF g_debug THEN
             pay_in_utils.trace('Check valid value from lookup=>Registraion Certificate number',NULL);
          END IF;
          p_message_name  := 'PER_IN_DUPLICATE_VALUES';
          p_token_name(1) := 'FIELD';
          p_token_value(1):= hr_general.decode_lookup('IN_MESSAGE_TOKENS','REG_CERT_NO');
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
          RETURN ;
         END IF;

        /* Check for License Number */
         OPEN chk_unique_license(p_org_information2);
         FETCH chk_unique_license INTO l_lic_num;
         CLOSE chk_unique_license;

          IF l_lic_num = 'X' THEN
          IF g_debug THEN
             pay_in_utils.trace('Check valid value from lookup=>license number',NULL);
          END IF;
          p_message_name  := 'PER_IN_DUPLICATE_VALUES';
          p_token_name(1) := 'FIELD';
          p_token_value(1):= hr_general.decode_lookup('IN_MESSAGE_TOKENS','LICENSE_NO');
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
          RETURN ;

         END IF;

        /* Check for PF Number */
         OPEN chk_unique_pf(p_org_information3);
         FETCH chk_unique_pf INTO l_pf_num;
         CLOSE chk_unique_pf;

        IF l_pf_num = 'X' THEN
          IF g_debug THEN
             pay_in_utils.trace('Check valid value from lookup=>PF Number',NULL);
          END IF;
          p_message_name  := 'PER_IN_DUPLICATE_VALUES';
         -- p_token_name(1) := 'VALUE';
         -- p_token_value(1):= p_org_information3;
          p_token_name(1) := 'FIELD';
          p_token_value(1):= hr_general.decode_lookup('IN_MESSAGE_TOKENS','PF_NO');
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
          RETURN ;

         END IF;

        /* Check for ESI Number */
      IF p_org_information4 IS NOT NULL THEN

         OPEN chk_unique_esi(p_org_information4);
         FETCH chk_unique_esi INTO l_esi_num;
         CLOSE chk_unique_esi;

         IF l_esi_num = 'X' THEN
          IF g_debug THEN
             pay_in_utils.trace('Check valid value from lookup=>ESI number',NULL);
          END IF;
          p_message_name  := 'PER_IN_DUPLICATE_VALUES';
          p_token_name(1) := 'FIELD';
          p_token_value(1):= hr_general.decode_lookup('IN_MESSAGE_TOKENS','ESI_NO');
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
          RETURN ;

         END IF;

      END IF;


        /* Check for PAN Number and pan format*/
      IF p_org_information5 IS NOT NULL THEN


        per_in_person_leg_hook.check_pan_format(
                                             p_pan  =>p_org_information5
                                            ,p_pan_af=>NULL
                                            ,p_panref_number => NULL
                                            ,p_message_name  => p_message_name
                                            ,p_token_name       => p_token_name
                                            ,p_token_value      =>  p_token_value);

        IF  p_message_name <> 'SUCCESS' THEN
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
          RETURN ;
        END IF ;



         OPEN chk_unique_pan(p_org_information5);
         FETCH chk_unique_pan INTO l_pan_num;
         CLOSE chk_unique_pan;

         IF l_pan_num = 'X' THEN
          IF g_debug THEN
             pay_in_utils.trace('Check valid value from lookup=>PAN number',NULL);
          END IF;
          p_message_name  := 'PER_IN_DUPLICATE_VALUES';
          p_token_name(1) := 'FIELD';
          p_token_value(1):= hr_general.decode_lookup('IN_MESSAGE_TOKENS','PAN_NO');
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
          RETURN ;
          END IF;

      END IF;


  END IF;  /* End of Org Info Code */

  IF  p_org_info_type_code = 'PER_IN_FORM24Q_RECEIPT_DF' THEN

         OPEN chk_unique_ref_no(p_org_information3, p_organization_id, p_org_information6);
         FETCH chk_unique_ref_no INTO l_ref_num;
         CLOSE chk_unique_ref_no;
         pay_in_utils.set_location(g_debug,'l_ref_num : '||l_ref_num,100);

         IF l_ref_num = 'X' THEN
          IF g_debug THEN
             pay_in_utils.trace('Check valid value for Archive Ref Number',NULL);
          END IF;
          p_message_name  := 'PER_IN_NON_UNIQUE_VALUE';
          p_token_name(1) := 'NUMBER_CATEGORY';
          p_token_value(1):= hr_general.decode_lookup('IN_MESSAGE_TOKENS','ARCH_REF_NUM');
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
          RETURN ;
         END IF;

        /* Check for License Number */
         OPEN chk_unique_receipt_no(p_org_information4, p_organization_id, p_org_information6);
         FETCH chk_unique_receipt_no INTO l_receipt_num;
         CLOSE chk_unique_receipt_no;
         pay_in_utils.set_location(g_debug,'l_receipt_num : '||l_receipt_num,100);

         IF l_receipt_num = 'X' THEN
          IF g_debug THEN
             pay_in_utils.trace('Check valid Receipt Number',NULL);
          END IF;
          p_message_name  := 'PER_IN_NON_UNIQUE_VALUE';
          p_token_name(1) := 'NUMBER_CATEGORY';
          p_token_value(1):= hr_general.decode_lookup('IN_MESSAGE_TOKENS','RCPT_NUMBER');
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
          RETURN ;
         END IF;

  END IF;

/*Check for unique PF bank code and branch code*/
IF p_org_info_type_code = 'PER_IN_PF_BANK_BRANCH_DTLS' THEN
  OPEN chk_unq_chn_bnk_brnch_dtls;
         FETCH chk_unq_chn_bnk_brnch_dtls INTO l_pf_bnk_brnch_dtls;
         CLOSE chk_unq_chn_bnk_brnch_dtls;
         pay_in_utils.set_location(g_debug,'l_pf_bnk_brnch_dtls : '||l_pf_bnk_brnch_dtls,105);

         IF l_pf_bnk_brnch_dtls = 'X' THEN
          IF g_debug THEN
             pay_in_utils.trace('Check valid value for PF Bank Branch details',NULL);
          END IF;
          p_message_name  := 'PER_IN_PF_BANK_BRANCH_DTLS';
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
          RETURN ;
         END IF;

  END IF;

  /*Check for unique Base Business Number*/
 IF p_org_info_type_code = 'PER_IN_COMPANY_DF' THEN
  OPEN chk_unique_bus_no_pf(p_org_information5);
         FETCH chk_unique_bus_no_pf INTO l_bus_numb_pf;
         CLOSE chk_unique_bus_no_pf;
         pay_in_utils.set_location(g_debug,'l_bus_numb_pf : '||l_bus_numb_pf,110);

         IF l_bus_numb_pf = 'X' THEN
          IF g_debug THEN
             pay_in_utils.trace('Check valid value for Business Number',NULL);
          END IF;
          p_message_name  := 'PER_IN_NON_UNIQUE_VALUE';
          p_token_name(1) := 'NUMBER_CATEGORY';
          p_token_value(1):= hr_general.decode_lookup('IN_MESSAGE_TOKENS','BASE_BUSINESS_NUM');
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
          RETURN ;
         END IF;

  END IF;

 /*Check for unique Challan Reference Number*/
  IF p_org_info_type_code IN ('PER_IN_PF_CHALLAN_INFO',
                              'PER_IN_PF_BANK_PAYMENT_DETAILS',
                              'PER_IN_PF_CHN_SEC14B',
                              'PER_IN_PF_SEC7Q_INFO',
                              'PER_IN_PF_MIS_PAY_INFO') THEN

   IF p_org_info_type_code = 'PER_IN_PF_CHALLAN_INFO' THEN
   OPEN chk_unique_chn_no_pf(p_org_information12);
   FETCH chk_unique_chn_no_pf INTO l_challan_ref_no;
   CLOSE chk_unique_chn_no_pf;
   ELSIF p_org_info_type_code = 'PER_IN_PF_CHN_SEC14B' THEN
    OPEN chk_unq_chn_no_pf_14b(p_org_information1);
   FETCH chk_unq_chn_no_pf_14b INTO l_challan_ref_no;
   CLOSE chk_unq_chn_no_pf_14b;
   ELSIF p_org_info_type_code = 'PER_IN_PF_SEC7Q_INFO' THEN
    OPEN chk_unq_chn_no_pf_7q(p_org_information11);
   FETCH chk_unq_chn_no_pf_7q INTO l_challan_ref_no;
   CLOSE chk_unq_chn_no_pf_7q;
   ELSIF p_org_info_type_code IN ('PER_IN_PF_MIS_PAY_INFO','PER_IN_PF_BANK_PAYMENT_DETAILS') THEN
   OPEN chk_unq_chn_no_pf_oth(p_org_information3,p_org_info_type_code);
   FETCH chk_unq_chn_no_pf_oth INTO l_challan_ref_no;
   CLOSE chk_unq_chn_no_pf_oth;
   END IF;

   pay_in_utils.set_location(g_debug,'l_challan_ref_no : '||l_challan_ref_no,110);

    IF l_challan_ref_no = 'X' THEN
       IF g_debug THEN
        pay_in_utils.trace('Check valid value for Challan Reference Number for'|| p_org_info_type_code,NULL);
       END IF;
          p_message_name  := 'PER_IN_NON_UNIQUE_VALUE';
          p_token_name(1) := 'NUMBER_CATEGORY';
          p_token_value(1):= hr_general.decode_lookup('IN_MESSAGE_TOKENS','PF_CHALLAN_NO');
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
     RETURN ;
     END IF;

     /*Check for unique Cheque Number*/
     IF p_org_info_type_code = 'PER_IN_PF_BANK_PAYMENT_DETAILS' THEN
        OPEN chk_unique_chq_no_pf(p_org_information5);
         FETCH chk_unique_chq_no_pf INTO l_chq_dd_no;
         CLOSE chk_unique_chq_no_pf;
         pay_in_utils.set_location(g_debug,'l_chq_dd_no : '||l_chq_dd_no,120);

         IF l_chq_dd_no = 'X' THEN
          IF g_debug THEN
             pay_in_utils.trace('Check valid value for Cheque/ DD Number',NULL);
          END IF;
          p_message_name  := 'PER_IN_NON_UNIQUE_VALUE';
          p_token_name(1) := 'NUMBER_CATEGORY';
          p_token_value(1):= hr_general.decode_lookup('IN_MESSAGE_TOKENS','DD_CHQ_NO');
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
          RETURN ;
         END IF;
     END IF;
  END IF;
  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
       pay_in_utils.trace(l_message,l_procedure);

END check_unique_num_ins;




--------------------------------------------------------------------------
-- Name           : CHECK_UNIQUE_NUM_UPD                                --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure is the driver procedure for the validation--
--                  of the Organizaition Information data for the       --
--                  context IN_CONTRACTOR_INFO.                         --
--                  This procedure is the hook procedure for            --
--                  for org information when org info is updated        --
-- Parameters     :                                                     --
--             IN : p_org_information_id    NUMBER                      --
--                  p_org_info_type_code    VARCHAR2                    --
--                  p_org_information1      VARCHAR2                    --
--                  p_org_information2      VARCHAR2                    --
--                  p_org_information3      VARCHAR2                    --
--                  p_org_information4      VARCHAR2                    --
--                  p_org_information5      VARCHAR2                    --
--            OUT : p_message_name          VARCHAR2                    --
--                  p_token_name            VARCHAR2                    --
--                  p_token_value           VARCHAR2                    --
--                                                                      --
--            OUT : 3                                                   --
--         RETURN : N/A                                                 --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                    --
--------------------------------------------------------------------------
-- 1.0   16-May-2005    sukukuma       created this procedure           --
-- 1.1   11-Sep-2007    Sivanara       Added parameters                 --
--                                      1.p_org_information11           --
--					2.p_org_information12           --
--				       Also added code to check the     --
--                                     uniquess of                      --
--                                     1.Business Number                --
--                                     2.Cheque Number                  --
--                                     3.Challan Reference Number       --
--------------------------------------------------------------------------
PROCEDURE check_unique_num_upd (p_org_information_id   IN  NUMBER
                               ,p_org_info_type_code   IN VARCHAR2
                               ,p_org_information1     IN VARCHAR2
                               ,p_org_information2     IN VARCHAR2
                               ,p_org_information3     IN VARCHAR2
                               ,p_org_information4     IN VARCHAR2
                               ,p_org_information5     IN VARCHAR2
                               ,p_org_information6     IN VARCHAR2
                               ,p_org_information11     IN VARCHAR2
                               ,p_org_information12     IN VARCHAR2
                               ,p_organization_id      IN NUMBER DEFAULT NULL
                               ,p_message_name         OUT NOCOPY VARCHAR2
                               ,p_token_name           OUT NOCOPY pay_in_utils.char_tab_type
                               ,p_token_value          OUT NOCOPY pay_in_utils.char_tab_type
                               ) AS

     l_reg_num          VARCHAR2(1);
     l_lic_num          VARCHAR2(1);
     l_pf_num           VARCHAR2(1);
     l_esi_num          VARCHAR2(1);
     l_pan_num          VARCHAR2(1);
     l_bus_numb_pf      VARCHAR2(1);
     l_receipt_num      VARCHAR2(1);
     l_ref_num          VARCHAR2(1);
     l_challan_ref_no   VARCHAR2(1);
     l_pf_bnk_brnch_dtls VARCHAR2(1);
     l_org_info          hr_organization_information.org_information1%type;
     l_chq_dd_no        VARCHAR2(1);
     l_procedure        VARCHAR2(100);
     l_message          VARCHAR2(300);


     CURSOR chk_unique_reg (p_org_info VARCHAR2) IS
      SELECT 'X'
      FROM hr_organization_information
      WHERE org_information_context = 'IN_CONTRACTOR_INFO'
      AND   org_information1 = p_org_info
      AND   org_information_id <> p_org_information_id;

     CURSOR chk_unique_license (p_org_info VARCHAR2) IS
      SELECT 'X'
      FROM hr_organization_information
      WHERE org_information_context = 'IN_CONTRACTOR_INFO'
      AND   org_information2 = p_org_info
      AND   org_information_id <> p_org_information_id;

     CURSOR chk_unique_pf (p_org_info VARCHAR2) IS
      SELECT 'X'
      FROM hr_organization_information
      WHERE org_information_context = 'IN_CONTRACTOR_INFO'
      AND   org_information3 = p_org_info
      AND   org_information_id <> p_org_information_id;

     CURSOR chk_unique_esi (p_org_info VARCHAR2) IS
      SELECT 'X'
      FROM hr_organization_information
      WHERE org_information_context = 'IN_CONTRACTOR_INFO'
      AND   org_information4 = p_org_info
      AND   org_information_id <> p_org_information_id;

     CURSOR chk_unique_pan (p_org_info VARCHAR2) IS
      SELECT 'X'
      FROM hr_organization_information
      WHERE org_information_context = 'IN_CONTRACTOR_INFO'
      AND   org_information5 = p_org_info
      AND   org_information_id <> p_org_information_id;

     CURSOR chk_unique_ref_no (p_org_info VARCHAR2, p_organization_id NUMBER, p_org_information6 VARCHAR2) IS
      SELECT 'X'
      FROM hr_organization_information
      WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
      AND   org_information3 = p_org_info
      AND   org_information6 = p_org_information6
      AND   organization_id = p_organization_id
      AND   org_information_id <> p_org_information_id;


     CURSOR chk_unique_receipt_no (p_org_info VARCHAR2, p_organization_id NUMBER, p_org_information6 VARCHAR2) IS
      SELECT 'X'
      FROM hr_organization_information
      WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
      AND   org_information4 = p_org_info
      AND   org_information6 = p_org_information6
      AND   organization_id = p_organization_id
      AND   org_information_id <> p_org_information_id;

    CURSOR chk_unique_bus_no_pf (p_org_info VARCHAR2) IS
      SELECT 'X'
      FROM hr_organization_information
      WHERE org_information_context = 'PER_IN_COMPANY_DF'
      AND   org_information5 = p_org_info
       AND   org_information_id <> p_org_information_id;

    CURSOR chk_unique_chn_no_pf (p_org_info VARCHAR2) IS
       SELECT 'X'
      FROM hr_organization_information
      WHERE org_information_context = 'PER_IN_PF_CHALLAN_INFO'
      AND  org_information12 = p_org_info
      AND   org_information_id <> p_org_information_id;

       CURSOR chk_unq_chn_no_pf_7q (p_org_info VARCHAR2) IS
      SELECT 'X'
      FROM hr_organization_information
      WHERE org_information_context = 'PER_IN_PF_SEC7Q_INFO'
      AND org_information11 = p_org_info
      AND   org_information_id <> p_org_information_id;


     CURSOR chk_unq_chn_no_pf_14b (p_org_info VARCHAR2) IS
      SELECT 'X'
      FROM hr_organization_information
      WHERE org_information_context = 'PER_IN_PF_CHN_SEC14B'
      AND org_information1 = p_org_info
      AND   org_information_id <> p_org_information_id;

     CURSOR chk_unq_chn_no_pf_oth (p_org_info VARCHAR2,p_org_info_type_code varchar2) IS
      SELECT 'X'
      FROM hr_organization_information
      WHERE org_information_context = p_org_info_type_code
      AND org_information3 = p_org_info
      AND   org_information_id <> p_org_information_id;

    CURSOR chk_unique_chq_no_pf (p_org_info VARCHAR2) IS
      SELECT 'X'
      FROM hr_organization_information
      WHERE org_information_context = 'PER_IN_PF_BANK_PAYMENT_DETAILS'
      AND   org_information5 = p_org_info
      AND   org_information_id <> p_org_information_id;

      CURSOR chk_unq_chn_bnk_brnch_dtls IS
     SELECT 'X'
     FROM hr_organization_information
     WHERE org_information_context = 'PER_IN_PF_BANK_BRANCH_DTLS'
     AND org_information1 = p_org_information1
     AND org_information2 = p_org_information2
     AND   org_information_id <> p_org_information_id
     AND organization_id = p_organization_id;

  BEGIN

  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'IN') THEN
       IF g_debug THEN
           pay_in_utils.trace('IN Legislation not installed. Not performing the validations',NULL);
       END IF;
       pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
       RETURN;
  END IF;

  l_procedure := g_package||'check_unique_num_upd';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_org_information_id',p_org_information_id);
       pay_in_utils.trace('p_org_info_type_code',p_org_info_type_code);
       pay_in_utils.trace('p_org_information1  ',p_org_information1  );
       pay_in_utils.trace('p_org_information2  ',p_org_information2  );
       pay_in_utils.trace('p_org_information3  ',p_org_information3  );
       pay_in_utils.trace('p_org_information4  ',p_org_information4  );
       pay_in_utils.trace('p_org_information5  ',p_org_information5  );
       pay_in_utils.trace('p_org_information6  ',p_org_information6  );
       pay_in_utils.trace('p_org_information11  ',p_org_information11);
       pay_in_utils.trace('p_org_information12  ',p_org_information12);
       pay_in_utils.trace('p_organization_id   ',p_organization_id   );
       pay_in_utils.trace('p_message_name      ',p_message_name      );
       pay_in_utils.trace('**************************************************','********************');
   END IF;

  IF  p_org_info_type_code = 'IN_CONTRACTOR_INFO' THEN

        /* Check for Registration Number */
         OPEN chk_unique_reg(p_org_information1);
         FETCH chk_unique_reg INTO l_reg_num;
         CLOSE chk_unique_reg;

         IF l_reg_num = 'X' THEN
          IF g_debug THEN
           pay_in_utils.trace('Check valid value from lookup=>Registraion Certificate number',NULL);
          END IF;
          p_message_name  := 'PER_IN_DUPLICATE_VALUES';
          p_token_name(1) := 'FIELD';
          p_token_value(1):= hr_general.decode_lookup('IN_MESSAGE_TOKENS','REG_CERT_NO');
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
          RETURN ;
         END IF;

        /* Check for License Number */
         OPEN chk_unique_license(p_org_information2);
         FETCH chk_unique_license INTO l_lic_num;
         CLOSE chk_unique_license;

          IF l_lic_num = 'X' THEN
          IF g_debug THEN
           pay_in_utils.trace('Check valid value from lookup=>license number',NULL);
          END IF;
          p_message_name  := 'PER_IN_DUPLICATE_VALUES';
          p_token_name(1) := 'FIELD';
          p_token_value(1):= hr_general.decode_lookup('IN_MESSAGE_TOKENS','LICENSE_NO');
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
          RETURN ;

         END IF;

        /* Check for PF Number */
         OPEN chk_unique_pf(p_org_information3);
         FETCH chk_unique_pf INTO l_pf_num;
         CLOSE chk_unique_pf;

        IF l_pf_num = 'X' THEN
          IF g_debug THEN
           pay_in_utils.trace('Check valid value from lookup=>PF Number',NULL);
          END IF;
          p_message_name  := 'PER_IN_DUPLICATE_VALUES';
          p_token_name(1) := 'FIELD';
          p_token_value(1):= hr_general.decode_lookup('IN_MESSAGE_TOKENS','PF_NO');
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
          RETURN ;

         END IF;

        /* Check for ESI Number */
      IF p_org_information4 IS NOT NULL THEN

         OPEN chk_unique_esi(p_org_information4);
         FETCH chk_unique_esi INTO l_esi_num;
         CLOSE chk_unique_esi;

         IF l_esi_num = 'X' THEN
          IF g_debug THEN
           pay_in_utils.trace('Check valid value from lookup=>ESI number',NULL);
          END IF;
          p_message_name  := 'PER_IN_DUPLICATE_VALUES';
          p_token_name(1) := 'FIELD';
          p_token_value(1):= hr_general.decode_lookup('IN_MESSAGE_TOKENS','ESI_NO');
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
          RETURN ;
          END IF;

      END IF;


        /* Check for PAN Number */
      IF p_org_information5 IS NOT NULL THEN

       per_in_person_leg_hook.check_pan_format(
                                              p_pan  =>p_org_information5
                                             ,p_pan_af=>NULL
                                             ,p_panref_number => NULL
                                             ,p_message_name  => p_message_name
                                             ,p_token_name      => p_token_name
                                             ,p_token_value     =>  p_token_value);




          IF  p_message_name <> 'SUCCESS' THEN
             IF g_debug THEN
                pay_in_utils.trace('**************************************************','********************');
                pay_in_utils.trace('p_message_name',p_message_name);
                pay_in_utils.trace('**************************************************','********************');
             END IF;
             pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
             RETURN ;
          END IF ;


         OPEN chk_unique_pan(p_org_information5);
         FETCH chk_unique_pan INTO l_pan_num;
         CLOSE chk_unique_pan;

         IF l_pan_num = 'X' THEN
          IF g_debug THEN
           pay_in_utils.trace('Check valid value from lookup=>PAN number',NULL);
          END IF;
          p_message_name  := 'PER_IN_DUPLICATE_VALUES';
          p_token_name(1) := 'FIELD';
          p_token_value(1):= hr_general.decode_lookup('IN_MESSAGE_TOKENS','PAN_NO');
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
          RETURN ;
          END IF;

      END IF;


 END IF;  /* End of Org Info Code */

  IF  p_org_info_type_code = 'PER_IN_FORM24Q_RECEIPT_DF' THEN

         OPEN chk_unique_ref_no(p_org_information3, p_organization_id, p_org_information6);
         FETCH chk_unique_ref_no INTO l_ref_num;
         CLOSE chk_unique_ref_no;
         pay_in_utils.set_location(g_debug,'l_ref_num : '||l_ref_num,100);

        /* Check for Request Id */
         IF l_ref_num = 'X' THEN
          p_message_name  := 'PER_IN_NON_UNIQUE_VALUE';
          p_token_name(1) := 'NUMBER_CATEGORY';
          p_token_value(1):= hr_general.decode_lookup('IN_MESSAGE_TOKENS','ARCH_REF_NUM');
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
          RETURN ;
         END IF;

        /* Check for Reciept Number */
         OPEN chk_unique_receipt_no(p_org_information4, p_organization_id, p_org_information6);
         FETCH chk_unique_receipt_no INTO l_receipt_num;
         CLOSE chk_unique_receipt_no;
         pay_in_utils.set_location(g_debug,'l_receipt_num : '||l_receipt_num,100);

         IF l_receipt_num = 'X' THEN
          p_message_name  := 'PER_IN_NON_UNIQUE_VALUE';
          p_token_name(1) := 'NUMBER_CATEGORY';
          p_token_value(1):= hr_general.decode_lookup('IN_MESSAGE_TOKENS','RCPT_NUMBER');
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
          RETURN ;
         END IF;

  END IF;

  /*Check for uniquess of PF Bank and Branch Code*/
  IF p_org_info_type_code = 'PER_IN_PF_BANK_BRANCH_DTLS' THEN
  OPEN chk_unq_chn_bnk_brnch_dtls;
         FETCH chk_unq_chn_bnk_brnch_dtls INTO l_pf_bnk_brnch_dtls;
         CLOSE chk_unq_chn_bnk_brnch_dtls;
         pay_in_utils.set_location(g_debug,'l_pf_bnk_brnch_dtls : '||l_pf_bnk_brnch_dtls,110);

         IF l_pf_bnk_brnch_dtls = 'X' THEN
          IF g_debug THEN
             pay_in_utils.trace('Check valid value for PF Bank Branch details',NULL);
          END IF;
          p_message_name  := 'PER_IN_PF_BANK_BRANCH_DTLS';
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
          RETURN ;
         END IF;

  END IF;

  /*Check for unique PF Base Business Number*/
 IF p_org_info_type_code = 'PER_IN_COMPANY_DF' THEN
  OPEN chk_unique_bus_no_pf(p_org_information5);
         FETCH chk_unique_bus_no_pf INTO l_bus_numb_pf;
         CLOSE chk_unique_bus_no_pf;
         pay_in_utils.set_location(g_debug,'l_bus_numb_pf : '||l_bus_numb_pf,110);

         IF l_bus_numb_pf = 'X' THEN
          IF g_debug THEN
             pay_in_utils.trace('Check valid value for Base Business Number',NULL);
          END IF;
          p_message_name  := 'PER_IN_NON_UNIQUE_VALUE';
          p_token_name(1) := 'NUMBER_CATEGORY';
          p_token_value(1):= hr_general.decode_lookup('IN_MESSAGE_TOKENS','BASE_BUSINESS_NUM');
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
          RETURN ;
         END IF;

  END IF;
  /*Check for uniqueness of Challan Reference Number*/
 IF p_org_info_type_code IN ('PER_IN_PF_CHALLAN_INFO',
                              'PER_IN_PF_BANK_PAYMENT_DETAILS',
                              'PER_IN_PF_CHN_SEC14B',
                              'PER_IN_PF_SEC7Q_INFO',
                              'PER_IN_PF_MIS_PAY_INFO') THEN

   IF p_org_info_type_code = 'PER_IN_PF_CHALLAN_INFO' THEN
     OPEN chk_unique_chn_no_pf(p_org_information12);
     FETCH chk_unique_chn_no_pf INTO l_challan_ref_no;
     CLOSE chk_unique_chn_no_pf;
   ELSIF p_org_info_type_code = 'PER_IN_PF_CHN_SEC14B' THEN
     OPEN chk_unq_chn_no_pf_14b(p_org_information1);
     FETCH chk_unq_chn_no_pf_14b INTO l_challan_ref_no;
     CLOSE chk_unq_chn_no_pf_14b;
   ELSIF p_org_info_type_code = 'PER_IN_PF_SEC7Q_INFO' THEN
     OPEN chk_unq_chn_no_pf_7q(p_org_information11);
     FETCH chk_unq_chn_no_pf_7q INTO l_challan_ref_no;
     CLOSE chk_unq_chn_no_pf_7q;
   ELSIF p_org_info_type_code IN ('PER_IN_PF_MIS_PAY_INFO','PER_IN_PF_BANK_PAYMENT_DETAILS') THEN
     OPEN chk_unq_chn_no_pf_oth(p_org_information3,p_org_info_type_code);
     FETCH chk_unq_chn_no_pf_oth INTO l_challan_ref_no;
     CLOSE chk_unq_chn_no_pf_oth;
   END IF;
   pay_in_utils.set_location(g_debug,'l_challan_ref_no : '||l_challan_ref_no,110);

    IF l_challan_ref_no = 'X' THEN
       IF g_debug THEN
        pay_in_utils.trace('Check valid value for Challan Reference Number for'|| p_org_info_type_code,NULL);
       END IF;
          p_message_name  := 'PER_IN_NON_UNIQUE_VALUE';
          p_token_name(1) := 'NUMBER_CATEGORY';
          p_token_value(1):= hr_general.decode_lookup('IN_MESSAGE_TOKENS','PF_CHALLAN_NO');
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
     RETURN ;
     END IF;

     /*Check for uniqueness of Cheque Number*/
     IF p_org_info_type_code = 'PER_IN_PF_BANK_PAYMENT_DETAILS' THEN
        OPEN chk_unique_chq_no_pf(p_org_information5);
         FETCH chk_unique_chq_no_pf INTO l_chq_dd_no;
         CLOSE chk_unique_chq_no_pf;
         pay_in_utils.set_location(g_debug,'l_chq_dd_no : '||l_chq_dd_no,120);

         IF l_chq_dd_no = 'X' THEN
          IF g_debug THEN
             pay_in_utils.trace('Check valid value for Cheque/ DD Number',NULL);
          END IF;
          p_message_name  := 'PER_IN_NON_UNIQUE_VALUE';
          p_token_name(1) := 'NUMBER_CATEGORY';
          p_token_value(1):= hr_general.decode_lookup('IN_MESSAGE_TOKENS','DD_CHQ_NO');
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
          RETURN ;
         END IF;
     END IF;
  END IF;

  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
       pay_in_utils.trace(l_message,l_procedure);

END check_unique_num_upd;




 --------------------------------------------------------------------------
 --                                                                      --
 -- Name           : validate_date                                       --
 -- Type           : Procedure                                           --
 -- Access         : Public                                              --
 -- Description    : This procedure checks if the effective end date is  --
 --                  greater than or equal to effective start date .     --
 -- Parameters     :                                                     --
 --             IN : p_effective_start_date   DATE                       --
 --                  p_effective_end_date     DATE                       --
 --            OUT : p_message_name           VARCHAR2                   --
 --                  p_token_name             VARCHAR2                   --
 --                  p_token_value            VARCHAR2                   --
 --                                                                      --
 --            OUT : 3                                                   --
 --         RETURN : N/A                                                 --
 -- Change History :                                                     --
 --------------------------------------------------------------------------
 -- Rev#  Date           Userid           Description                    --
 --------------------------------------------------------------------------
 -- 1.0   16-May-2005    sukukuma         Modified this procedure        --
 --------------------------------------------------------------------------
  PROCEDURE validate_date(p_effective_start_date   IN DATE
                         ,p_effective_end_date     IN DATE
                         ,p_message_name           OUT NOCOPY VARCHAR2
                         ,p_token_name            OUT NOCOPY pay_in_utils.char_tab_type
                         ,p_token_value           OUT NOCOPY pay_in_utils.char_tab_type
                         )
  IS
    l_procedure VARCHAR2(50);
    l_message   VARCHAR2(300);
  BEGIN

  l_procedure := g_package||'validate_date';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_effective_start_date',p_effective_start_date);
       pay_in_utils.trace('p_effective_end_date  ',p_effective_end_date  );
       pay_in_utils.trace('p_message_name        ',p_message_name        );
       pay_in_utils.trace('**************************************************','********************');
   END IF;

    IF p_effective_end_date IS NOT NULL THEN
      pay_in_utils.set_location(g_debug,l_procedure,20);
      IF p_effective_end_date< p_effective_start_date THEN
      p_message_name := 'PER_IN_INCORRECT_DATES';
      p_token_name(1) := 'FIELD';
      p_token_value(1) := p_effective_end_date;
      IF g_debug THEN
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('p_message_name',p_message_name);
         pay_in_utils.trace('**************************************************','********************');
      END IF;
      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
      RETURN;
      END IF;
      pay_in_utils.set_location(g_debug,l_procedure,30);
    END IF;

  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
       pay_in_utils.trace(l_message,l_procedure);

   END;

 --------------------------------------------------------------------------
 --                                                                      --
 -- Name           : validate_corporate_number                           --
 -- Type           : Procedure                                           --
 -- Access         : Private                                             --
 -- Description    : This procedure checks that the corporate identity   --
 --                  number allows only alphabets and numbers            --
 -- Parameters     :                                                     --
 --             IN : p_org_information2      VARCHAR2                    --
 --            OUT : p_message_name          VARCHAR2                    --
 --                  p_token_name            VARCHAR2                    --
 --                  p_token_value           VARCHAR2                    --
 --                                                                      --
 --            OUT : 3                                                   --
 --         RETURN : N/A                                                 --
 -- Change History :                                                     --
 --------------------------------------------------------------------------
 -- Rev#  Date           Userid           Description                    --
 --------------------------------------------------------------------------
 -- 1.0   16-May-2005    sukukuma         Modified this procedure        --
 --------------------------------------------------------------------------

PROCEDURE validate_corporate_number (p_org_information2 IN VARCHAR2
                                    ,p_message_name     OUT NOCOPY VARCHAR2
                                    ,p_token_name       OUT NOCOPY pay_in_utils.char_tab_type
                                    ,p_token_value      OUT NOCOPY pay_in_utils.char_tab_type)
IS
l_procedure VARCHAR2(60);
l_message   VARCHAR2(300);
l_length NUMBER;
i        NUMBER;
BEGIN

  l_procedure := g_package||'validate_corporate_number';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_org_information2',p_org_information2);
       pay_in_utils.trace('p_message_name    ',p_message_name    );
       pay_in_utils.trace('**************************************************','********************');
   END IF;

  l_length :=length(p_org_information2);
  FOR i IN 1..l_length LOOP
    pay_in_utils.set_location(g_debug,l_procedure,20);
    IF  ascii( substr(p_org_information2, i, 1) ) BETWEEN 65 AND 90 OR
        ascii( substr(p_org_information2, i, 1) ) BETWEEN 48 AND 57 THEN
        NULL;
    ELSE
        p_message_name := 'PER_IN_ALPHANUMERIC_VALUE';
        p_token_name(1) := 'VALUE';
        p_token_value(1) := p_org_information2;
        p_token_name(2) := 'FIELD';
        p_token_value(2) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','CORP_ID_NO');
        IF g_debug THEN
           pay_in_utils.trace('**************************************************','********************');
           pay_in_utils.trace('p_message_name',p_message_name);
           pay_in_utils.trace('**************************************************','********************');
        END IF;
        pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
        RETURN;
    END IF;
  END LOOP;

  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
       pay_in_utils.trace(l_message,l_procedure);

END;


 -------------------------------------------------------------------------
 --                                                                      --
 -- Name           : check_rep_ins                                       --
 -- Type           : Procedure                                           --
 -- Access         : Public                                              --
 -- Description    : Procedure is the driver procedure for the validation--
 --                  of the dates,so that they do not overlap.This also  --
 --                  performs PAN Validation and uniqueness checking of  --
 --                  TAN,Challan,IF applicable.This is the hook procedure--
 --                  for organization information when representative    --
 --                  details are inserted.                               --
 -- Parameters     :                                                     --
 --             IN : p_org_information1      VARCHAR2                    --
 --                  p_org_information2      VARCHAR2                    --
 --                  p_org_information3      VARCHAR2                    --
 --                  p_organization_id       NUMBER                      --
 --                  p_org_info_type_code    VARCHAR2                    --
 --            OUT : p_message_name          VARCHAR2                    --
 --                  p_token_name            VARCHAR2                    --
 --                  p_token_value           VARCHAR2                    --
 --                                                                      --
 --            OUT : 3                                                   --
 --         RETURN : N/A                                                 --
 -- Change History :                                                     --
 --------------------------------------------------------------------------
 -- Rev#  Date           Userid           Description                    --
 --------------------------------------------------------------------------
 -- 1.0   16-May-2005    sukukuma         Modified this procedure        --
 -- 1.1   05-Jan-2006    lnagaraj         Added Check for Challan Number --
 -- 1.2   23-Sep-2009    mdubasi          Added new input parameters and --
 --					  validation on those inputs     --
 --------------------------------------------------------------------------
PROCEDURE check_rep_ins(p_org_information1   IN VARCHAR2
                       ,p_org_information2   IN VARCHAR2
                       ,p_org_information3   IN VARCHAR2
                       ,p_org_information6   IN VARCHAR2
                       ,p_org_information5   IN VARCHAR2
		       ,p_org_information9   IN VARCHAR2
                       ,p_org_information10  IN VARCHAR2
                       ,p_org_information11  IN VARCHAR2
                       ,p_org_information12  IN VARCHAR2
		       ,p_org_information13  IN VARCHAR2
		       ,p_org_information14  IN VARCHAR2
		       ,p_org_information15  IN VARCHAR2
                       ,p_organization_id    IN NUMBER
                       ,p_org_info_type_code IN VARCHAR2
                       ,p_message_name       OUT NOCOPY VARCHAR2
                       ,p_token_name         OUT NOCOPY pay_in_utils.char_tab_type
                       ,p_token_value        OUT NOCOPY pay_in_utils.char_tab_type
                       )
AS

  l_start_date DATE;
  l_end_date DATE;
  l_exists VARCHAR2(1);
  l_tan   VARCHAR2(1);
  l_procedure VARCHAR2(50);
  l_message   VARCHAR2(300);
  l_bsr_code VARCHAR2(80);
  l_pao_ddo_code varchar2(50);

  ------------------------------------------------------------------
  -- Cursor to check that TAN Number is unique and doesnt coincide
  -- with that of any other organization
  ------------------------------------------------------------------
  CURSOR chk_unique_tan  IS
  SELECT 'X'
    FROM hr_organization_information
   WHERE org_information_context = 'PER_IN_INCOME_TAX_DF'
     AND org_information1 = p_org_information1
     AND organization_id<>p_organization_id;


  -------------------------------------------------------------------
  -- Cursor to check that there is not date overlap during insert when the
  --'Represenative Details' Information type is chosen.
  -------------------------------------------------------------------
  CURSOR chk_date_overlap_rep_ins(p_start_date DATE
                                 ,p_end_date   DATE)IS
  SELECT 'X'
    FROM hr_organization_information hoi
   WHERE p_start_date <=nvl(fnd_date.canonical_to_date(hoi.org_information3),to_date('4712/12/31','YYYY/MM/DD'))
     AND nvl(p_end_date,to_date('4712/12/31','YYYY/MM/DD')) >=fnd_date.canonical_to_date(hoi.org_information2)
     AND organization_id=p_organization_id
     AND org_information_context=p_org_info_type_code;

  ------------------------------------------------------------------
  -- Cursor to check that Challan Number is unique and doesnt coincide
  -- with any other record
  ------------------------------------------------------------------
  CURSOR c_bsr_code
      IS
  SELECT bank.org_information4
    FROM hr_organization_information bank
   WHERE bank.org_information_context = 'PER_IN_CHALLAN_BANK'
     AND  p_org_information5 = bank.org_information_id ;

   CURSOR chk_unique_challan(p_bsr_code VARCHAR2) IS
   SELECT 'X'
     FROM hr_organization_units hou
         ,hr_organization_information hoi
    WHERE hoi.organization_id   = hou.organization_id
      AND hou.business_group_id = (SELECT business_group_id
                         FROM hr_organization_units org
                         WHERE org.organization_id = p_organization_id)
      AND hoi.org_information_context = 'PER_IN_IT_CHALLAN_INFO'
      AND hoi.org_information3 = p_org_information3
      AND hoi.org_information2= p_org_information2
      and ((p_org_information5 is not null and
           p_bsr_code  in (SELECT bank.org_information4
                 FROM hr_organization_units hou
                     ,hr_organization_information bank
                WHERE hoi.organization_id   = hou.organization_id
                  AND hou.business_group_id = (SELECT business_group_id
                         FROM hr_organization_units org
                         WHERE org.organization_id = p_organization_id)
                  AND hoi.org_information_context = 'PER_IN_IT_CHALLAN_INFO'
                  AND bank.org_information_context = 'PER_IN_CHALLAN_BANK'
                  AND bank.organization_id = hoi.organization_id
                  AND hoi.org_information5 = bank.org_information_id )) or
	   p_org_information5 is  null);


  BEGIN

    IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'IN') THEN
       IF g_debug THEN
           pay_in_utils.trace('IN Legislation not installed. Not performing the validations',NULL);
       END IF;
       pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
       RETURN;
    END IF;

  l_procedure := g_package||'check_rep_ins';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_org_information1  ',p_org_information1  );
       pay_in_utils.trace('p_org_information2  ',p_org_information2  );
       pay_in_utils.trace('p_org_information3  ',p_org_information3  );
       pay_in_utils.trace('p_org_information6  ',p_org_information6  );
       pay_in_utils.trace('p_org_information5  ',p_org_information5  );
       pay_in_utils.trace('p_org_information9  ',p_org_information9  );
       pay_in_utils.trace('p_org_information10  ',p_org_information10  );
       pay_in_utils.trace('p_org_information11  ',p_org_information11 );
       pay_in_utils.trace('p_org_information12  ',p_org_information12 );
       pay_in_utils.trace('p_org_information13  ',p_org_information13 );
       pay_in_utils.trace('p_org_information14  ',p_org_information14 );
       pay_in_utils.trace('p_organization_id   ',p_organization_id   );
       pay_in_utils.trace('p_org_info_type_code',p_org_info_type_code);
       pay_in_utils.trace('p_message_name      ',p_message_name      );
       pay_in_utils.trace('**************************************************','********************');
   END IF;

    IF p_org_info_type_code ='PER_IN_INCOME_TAX_DF' THEN
      --
      -- Check for uniqueness of TAN AND DATE OVERLAP
      --
      pay_in_utils.set_location(g_debug,l_procedure,20);



      OPEN chk_unique_tan;
      FETCH chk_unique_tan INTO l_tan;
      CLOSE chk_unique_tan;

      pay_in_utils.set_location(g_debug,l_procedure,30);
      IF l_tan = 'X' THEN

      p_message_name := 'PER_IN_NON_UNIQUE_VALUE';
      p_token_name(1) := 'NUMBER_CATEGORY';
      p_token_value(1) := p_org_information1;
      IF g_debug THEN
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('p_message_name',p_message_name);
         pay_in_utils.trace('**************************************************','********************');
      END IF;
      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
      RETURN ;
      END IF;
            /*24Q validation for Newly introduced fields*/

      --Valdiation for  PAO and DDO codes
     IF (p_org_information6 = 'A' AND (p_org_information10 is NULL OR p_org_information11 is NULL))
      THEN
              IF p_org_information10 is NULL THEN
                 l_pao_ddo_code := 'PAO Code';
               ELSIF p_org_information11 is NULL THEN
                  l_pao_ddo_code := 'DDO Code';
               END IF;

             p_message_name := 'PER_IN_MISSING_ENTRY_VALUE';
             p_token_name(1) := 'TOKEN1';
             p_token_value(1) := l_pao_ddo_code;
             p_token_name(2) := 'TOKEN2';
             p_token_value(2) := 'Employer Classification for Form 24Q/QC';
             p_token_name(3) := 'TOKEN3';
             p_token_value(3) := hr_general.decode_lookup('IN_24Q_ER_CLASS',p_org_information6);

             IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
             END IF;
             pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
             RETURN ;
      ELSIF  (p_org_information6 NOT IN( 'A','S','D','E','G','H','L','N') AND
               (p_org_information10 is NOT NULL OR
                p_org_information11 is NOT NULL OR
                p_org_information14 is NOT NULL OR
                p_org_information15 is NOT NULL))
      THEN
              IF p_org_information10 is NOT NULL THEN
                 l_pao_ddo_code := 'PAO Code';
              ELSIF p_org_information11 is NOT NULL THEN
                  l_pao_ddo_code := 'DDO Code';
	      ELSIF p_org_information14 is NOT NULL THEN
                  l_pao_ddo_code := 'PAO Registration No';
	      ELSIF p_org_information15 is NOT NULL THEN
                  l_pao_ddo_code := 'DDO Registration No';
              END IF;

             p_message_name := 'PER_IN_24Q_FIELDS_VALIDATE';
             p_token_name(1) := 'TOKEN1';
             p_token_value(1) := l_pao_ddo_code;
             p_token_name(2) := 'TOKEN2';
             p_token_value(2) := 'Employer Classification for Form 24Q/QC';
             p_token_name(3) := 'TOKEN3';
             p_token_value(3) := hr_general.decode_lookup('IN_24Q_ER_CLASS',p_org_information6);

             IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
             END IF;
             pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
             RETURN ;
      END IF;

      --Validation for Ministry Name

      IF ((p_org_information6 = 'A' OR p_org_information6 = 'D' OR p_org_information6 = 'G')
           AND p_org_information12 is NULL )
      THEN
       p_message_name := 'PER_IN_MISSING_ENTRY_VALUE';
       p_token_name(1) := 'TOKEN1';
       p_token_value(1) := 'Ministry Name';
       p_token_name(2) := 'TOKEN2';
       p_token_value(2) := 'Employer Classification for Form 24Q/QC';
       p_token_name(3) := 'TOKEN3';
       p_token_value(3) := hr_general.decode_lookup('IN_24Q_ER_CLASS',p_org_information6);
         IF g_debug THEN
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('p_message_name',p_message_name);
         pay_in_utils.trace('**************************************************','********************');
         END IF;
         pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
         RETURN ;
       ELSIF (p_org_information6 NOT IN ('A' , 'D' , 'G','E','H','L','N')
                AND p_org_information12 is NOT NULL) THEN
             p_message_name := 'PER_IN_24Q_FIELDS_VALIDATE';
             p_token_name(1) := 'TOKEN1';
             p_token_value(1) := 'Ministry Name';
	     p_token_name(2) := 'TOKEN2';
             p_token_value(2) := 'Employer Classification for Form 24Q/QC';
             p_token_name(3) := 'TOKEN3';
             p_token_value(3) := hr_general.decode_lookup('IN_24Q_ER_CLASS',p_org_information6);
	     IF g_debug THEN
                pay_in_utils.trace('**************************************************','********************');
                pay_in_utils.trace('p_message_name',p_message_name);
                pay_in_utils.trace('**************************************************','********************');
             END IF;
       pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
       RETURN ;

      END IF;

     -- Validation for State Name

     IF ((p_org_information6 = 'S' OR p_org_information6 = 'E' OR p_org_information6 = 'H' OR p_org_information6 = 'N')
	  AND p_org_information9 is NULL )
     THEN
       p_message_name := 'PER_IN_MISSING_ENTRY_VALUE';
       p_token_name(1) := 'TOKEN1';
       p_token_value(1) := 'State';
       p_token_name(2) := 'TOKEN2';
       p_token_value(2) := 'Employer Classification for Form 24Q/QC';
       p_token_name(3) := 'TOKEN3';
       p_token_value(3) := hr_general.decode_lookup('IN_24Q_ER_CLASS',p_org_information6);
       IF g_debug THEN
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('p_message_name',p_message_name);
         pay_in_utils.trace('**************************************************','********************');
       END IF;
       pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
       RETURN ;
     ELSIF (p_org_information6 NOT IN ( 'S' , 'E' , 'H' , 'N')
	  AND p_org_information9 is NOT NULL )
     THEN
             p_message_name := 'PER_IN_24Q_FIELDS_VALIDATE';
             p_token_name(1) := 'TOKEN1';
             p_token_value(1) := 'State';
	     p_token_name(2) := 'TOKEN2';
             p_token_value(2) := 'Employer Classification for Form 24Q/QC';
             p_token_name(3) := 'TOKEN3';
             p_token_value(3) := hr_general.decode_lookup('IN_24Q_ER_CLASS',p_org_information6);
        IF g_debug THEN
          pay_in_utils.trace('**************************************************','********************');
          pay_in_utils.trace('p_message_name',p_message_name);
          pay_in_utils.trace('**************************************************','********************');
       END IF;
       pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
       RETURN ;
     END IF;

      -- Validation for Other Ministry Name
      IF ( p_org_information12 = '99' AND p_org_information13 is NULL)
      THEN
       p_message_name := 'PER_IN_MISSING_ENTRY_VALUE';
       p_token_name(1) := 'TOKEN1';
       p_token_value(1) := 'Other Ministry Name';
       p_token_name(2) := 'TOKEN2';
       p_token_value(2) := 'Ministry Name';
       p_token_name(3) := 'TOKEN3';
       p_token_value(3) := 'Others';

       IF g_debug THEN
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('p_message_name',p_message_name);
         pay_in_utils.trace('**************************************************','********************');
       END IF;
       pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
       RETURN ;
      END IF;

    ELSIF p_org_info_type_code IN('PER_IN_COMPANY_REP_DF'
                                  ,'PER_IN_FACTORY_REP_DF'
                                  ,'PER_IN_ESTABLISHMENT_REP_DF'
                                  ,'PER_IN_ESI_REP_DF'
                                  ,'PER_IN_PF_REP_DF'
                                --,'PER_IN_LABOR_DEPT_REP_DF'
                                  ,'PER_IN_INCOME_TAX_REP_DF'
                                  ,'PER_IN_PROF_TAX_REP_DF'
                                  ,'IN_CONTRACTOR_EMPLOYERS_REP')
     THEN

      pay_in_utils.set_location(g_debug,l_procedure,70);
      l_start_date := fnd_date.canonical_to_date(p_org_information2);
      l_end_date   := fnd_date.canonical_to_date(p_org_information3);


     ------check for start date is not greater than end date--------


           validate_date(p_effective_start_date=>l_start_date
                    ,p_effective_end_date=>l_end_date
                    ,p_message_name  => p_message_name
                    ,p_token_name    => p_token_name
                    ,p_token_value   =>  p_token_value);

       pay_in_utils.set_location(g_debug,l_procedure,80);

      --
      -- Check for overlap
      --

      OPEN chk_date_overlap_rep_ins(l_start_date,l_end_date);

      FETCH chk_date_overlap_rep_ins INTO l_exists;

        IF l_exists ='X' THEN
         p_message_name := 'PER_IN_DATE_OVERLAP';

         IF g_debug THEN
            pay_in_utils.trace('**************************************************','********************');
            pay_in_utils.trace('p_message_name',p_message_name);
            pay_in_utils.trace('**************************************************','********************');
         END IF;
         pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
         RETURN;
        END IF;
        pay_in_utils.set_location(g_debug,l_procedure,90);
      CLOSE chk_date_overlap_rep_ins;

   ELSIF p_org_info_type_code IN('IN_CONTRACTOR_WORK_INFO') THEN

      pay_in_utils.set_location(g_debug,l_procedure,95);
      l_start_date := fnd_date.canonical_to_date(p_org_information2);
      l_end_date   := fnd_date.canonical_to_date(p_org_information3);

       --
       -- Check that the start date is not greater than end date
       --

       validate_date(p_effective_start_date=>l_start_date
                    ,p_effective_end_date=>l_end_date
                    ,p_message_name  => p_message_name
                    ,p_token_name    => p_token_name
                    ,p_token_value   =>  p_token_value);

       IF p_message_name <> 'SUCCESS' THEN
         IF g_debug THEN
            pay_in_utils.trace('**************************************************','********************');
            pay_in_utils.trace('p_message_name',p_message_name);
            pay_in_utils.trace('**************************************************','********************');
         END IF;
         pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
         RETURN;
       END IF;

    ELSIF p_org_info_type_code='PER_IN_COMPANY_DF' THEN
      --
      -- Check if the format of Corporate identity Number is correct
      --
      pay_in_utils.set_location(g_debug,l_procedure,100);
      validate_corporate_number(p_org_information2=>p_org_information2
                               ,p_message_name  => p_message_name
                               ,p_token_name    => p_token_name
                               ,p_token_value   =>  p_token_value);

       IF p_message_name <> 'SUCCESS' THEN
         IF g_debug THEN
            pay_in_utils.trace('**************************************************','********************');
            pay_in_utils.trace('p_message_name',p_message_name);
            pay_in_utils.trace('**************************************************','********************');
         END IF;
         pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
         RETURN;
       END IF;


      pay_in_utils.set_location(g_debug,l_procedure,110);
   ELSIF p_org_info_type_code = 'PER_IN_IT_CHALLAN_INFO' THEN
       -- Check for uniqueness of Challan Number

          OPEN c_bsr_code;
          FETCH c_bsr_code INTO l_bsr_code;
          CLOSE c_bsr_code;

          OPEN chk_unique_challan(l_bsr_code);
          FETCH chk_unique_challan INTO l_exists;
          CLOSE chk_unique_challan;

          IF l_exists = 'X' THEN
            IF g_debug THEN
             pay_in_utils.trace('Challan Number not unique in this BG',NULL);
            END IF;
            p_message_name  := 'PER_IN_NON_UNIQUE_IT_CHALLAN';
            IF g_debug THEN
               pay_in_utils.trace('**************************************************','********************');
               pay_in_utils.trace('p_message_name',p_message_name);
               pay_in_utils.trace('**************************************************','********************');
            END IF;
            pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,50);
            RETURN ;
          END IF;


    END IF; -- p_org_info_type_code ='PER_IN_INCOME_TAX_DF'

    pay_in_utils.set_location(g_debug,l_procedure,120);


  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
       pay_in_utils.trace(l_message,l_procedure);

  END check_rep_ins;




 --------------------------------------------------------------------------
 --                                                                      --
 -- Name           : check_rep_upd                                       --
 -- Type           : Procedure                                           --
 -- Access         : Public                                              --
 -- Description    : Procedure is the driver procedure for the validation--
 --                  of the dates,so that they do not overlap.           --
 --                  This is the hook procedure for the                  --
 --                  organization information type when representative   --
 --                  details is updated.                                 --
 -- Parameters     :                                                     --
 --             IN : p_org_information1      VARCHAR2                    --
 --                  p_org_information2      VARCHAR2                    --
 --                  p_org_information3      VARCHAR2                    --
 --                  p_org_information_id    NUMBER                      --
 --                  p_org_info_type_code    VARCHAR2                    --
 --            OUT : p_message_name          VARCHAR2                    --
 --                  p_token_name            VARCHAR2                    --
 --                  p_token_value           VARCHAR2                    --
 --                                                                      --
 --            OUT : 3                                                   --
 --         RETURN : N/A                                                 --
 -- Change History :                                                     --
 --------------------------------------------------------------------------
 -- Rev#  Date           Userid           Description                    --
 --------------------------------------------------------------------------
 -- 1.0   16-May-2005    sukukuma         Modified this procedure        --
 -- 1.1   05-Jan-2006    lnagaraj         Added for Challan Number       --
 --------------------------------------------------------------------------
 PROCEDURE check_rep_upd( p_org_information1   IN VARCHAR2
                         ,p_org_information2   IN VARCHAR2
                         ,p_org_information3   IN VARCHAR2
			 ,p_org_information6   IN VARCHAR2
                         ,p_org_information5   IN VARCHAR2
			 ,p_org_information9   IN VARCHAR2
                         ,p_org_information10  IN VARCHAR2
                         ,p_org_information11  IN VARCHAR2
                         ,p_org_information12  IN VARCHAR2
			 ,p_org_information13  IN VARCHAR2
   		         ,p_org_information14  IN VARCHAR2
		         ,p_org_information15  IN VARCHAR2
                         ,p_org_information_id IN NUMBER
                         ,p_org_info_type_code IN  VARCHAR2
                         ,p_message_name       OUT NOCOPY VARCHAR2
                         ,p_token_name         OUT NOCOPY pay_in_utils.char_tab_type
                         ,p_token_value        OUT NOCOPY pay_in_utils.char_tab_type)
 AS
   l_organization_id NUMBER;

   l_start_date DATE;
   l_end_date   DATE;
   l_exists     VARCHAR2(1);
   l_tan        VARCHAR2(1);
   l_procedure  VARCHAR2(50);
   l_message    VARCHAR2(300);
   l_bsr_code   VARCHAR2(80);
   l_pao_ddo_code Varchar2(50);
   --
   -- Cursor to check that the TAN Number doesnt coincide with that of any
   -- other organisation.
   --
   CURSOR chk_unique_tan (p_organization_id NUMBER) IS
   SELECT 'X'
     FROM hr_organization_information
    WHERE org_information_context = 'PER_IN_INCOME_TAX_DF'
      AND org_information1 = p_org_information1
      AND organization_id <>p_organization_id;

   --
   -- Cursor to get the organization id
   --
   CURSOR csr_organization_id IS
   SELECT organization_id
     FROM hr_organization_information
    WHERE org_information_id =p_org_information_id;


   --
   -- Cursor to check for date overlap in case the context is
   -- 'Representative Details'
   --
   CURSOR chk_date_overlap_rep_upd(p_organization_id NUMBER
                                  ,p_start_date      DATE
                                  ,p_end_date        DATE) IS
   SELECT 'X'
     FROM hr_organization_information hoi
    WHERE p_start_date <=nvl(fnd_date.canonical_to_date(hoi.org_information3),to_date('4712/12/31','YYYY/MM/DD'))
      AND nvl(p_end_date,to_date('4712/12/31','YYYY/MM/DD')) >=fnd_date.canonical_to_date(hoi.org_information2)
      AND organization_id=p_organization_id
      AND org_information_id <>p_org_information_id
      AND org_information_context=p_org_info_type_code;

CURSOR c_bsr_code
is
 SELECT bank.org_information4
                 FROM hr_organization_information bank
                WHERE bank.org_information_context = 'PER_IN_CHALLAN_BANK'
                 AND  p_org_information5 = bank.org_information_id ;




   CURSOR chk_unique_challan(p_challan_number  VARCHAR2
                            ,p_organization_id NUMBER
			    ,p_bsr_code VARCHAR2) IS
   SELECT 'X'
     FROM hr_organization_units hou
         ,hr_organization_information hoi
    WHERE hoi.organization_id   = hou.organization_id
      AND hou.business_group_id = (SELECT business_group_id
                         FROM hr_organization_units org
                         WHERE org.organization_id = p_organization_id)
      AND hoi.org_information_context = 'PER_IN_IT_CHALLAN_INFO'
      and ((p_org_information5 is not null and
           p_bsr_code  in (SELECT bank.org_information4
                 FROM hr_organization_units hou
                     ,hr_organization_information bank
                WHERE hoi.organization_id   = hou.organization_id
                  AND hou.business_group_id = (SELECT business_group_id
                         FROM hr_organization_units org
                         WHERE org.organization_id = p_organization_id)
                  AND hoi.org_information_context = 'PER_IN_IT_CHALLAN_INFO'
                  AND bank.org_information_context = 'PER_IN_CHALLAN_BANK'
                  AND bank.organization_id = hoi.organization_id
                  AND hoi.org_information5 = bank.org_information_id )) or
	   p_org_information5 is  null)
      AND hoi.org_information3 = p_challan_number /*Challan */
      AND hoi.org_information2 = p_org_information2 /* date */
      AND hoi.org_information_id <> p_org_information_id;

   BEGIN

     IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'IN') THEN
       IF g_debug THEN
           pay_in_utils.trace('IN Legislation not installed. Not performing the validations',NULL);
       END IF;
       pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
       RETURN;
     END IF;

     l_procedure := g_package||'check_rep_upd';
     g_debug := hr_utility.debug_enabled;
     pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_org_information1  ',p_org_information1  );
       pay_in_utils.trace('p_org_information2  ',p_org_information2  );
       pay_in_utils.trace('p_org_information3  ',p_org_information3  );
       pay_in_utils.trace('p_org_information6  ',p_org_information6  );
       pay_in_utils.trace('p_org_information5  ',p_org_information5  );
       pay_in_utils.trace('p_org_information9  ',p_org_information9  );
       pay_in_utils.trace('p_org_information10 ',p_org_information10  );
       pay_in_utils.trace('p_org_information11 ',p_org_information11 );
       pay_in_utils.trace('p_org_information12 ',p_org_information12 );
       pay_in_utils.trace('p_org_information14 ',p_org_information14 );
       pay_in_utils.trace('p_org_information15 ',p_org_information15 );
       pay_in_utils.trace('p_org_information_id',p_org_information_id);
       pay_in_utils.trace('p_org_info_type_code',p_org_info_type_code);
       pay_in_utils.trace('p_message_name      ',p_message_name      );
       pay_in_utils.trace('**************************************************','********************');
   END IF;

     OPEN csr_organization_id;
     FETCH csr_organization_id
      INTO l_organization_id;
     CLOSE  csr_organization_id;


     pay_in_utils.set_location(g_debug,l_procedure,30);

     IF p_org_info_type_code ='PER_IN_INCOME_TAX_DF' THEN
       -- Check for uniqueness of TAN
       pay_in_utils.set_location(g_debug,l_procedure,40);

       OPEN chk_unique_tan(l_organization_id);
       FETCH chk_unique_tan INTO l_tan;
       CLOSE chk_unique_tan;

       pay_in_utils.set_location(g_debug,l_procedure,50);

             --Validation for PAO and DDO codes

       IF (p_org_information6 = 'A' AND (p_org_information10 is NULL OR p_org_information11 is NULL))
      THEN
              IF p_org_information10 is NULL THEN
                 l_pao_ddo_code := 'PAO Code';
              ELSIF p_org_information11 is NULL THEN
                  l_pao_ddo_code := 'DDO Code';
              END IF;

       p_message_name := 'PER_IN_MISSING_ENTRY_VALUE';
       p_token_name(1) := 'TOKEN1';
       p_token_value(1) := l_pao_ddo_code;
       p_token_name(2) := 'TOKEN2';
       p_token_value(2) := 'Employer Classification for Form 24Q/QC';
       p_token_name(3) := 'TOKEN3';
       p_token_value(3) := hr_general.decode_lookup('IN_24Q_ER_CLASS',p_org_information6);

       IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_message_name',p_message_name);
       pay_in_utils.trace('**************************************************','********************');
       END IF;
       pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,52);
       RETURN ;
       ELSIF  (p_org_information6 NOT IN( 'A','S','D','E','G','H','L','N') AND
                 (p_org_information10 is NOT NULL OR
                  p_org_information11 is NOT NULL OR
                  p_org_information14 is NOT NULL OR
                  p_org_information15 is NOT NULL))
      THEN
              IF p_org_information10 is NOT NULL THEN
                 l_pao_ddo_code := 'PAO Code';
              ELSIF p_org_information11 is NOT NULL THEN
                  l_pao_ddo_code := 'DDO Code';
	      ELSIF p_org_information14 is NOT NULL THEN
                  l_pao_ddo_code := 'PAO Registration No';
	      ELSIF p_org_information15 is NOT NULL THEN
                  l_pao_ddo_code := 'DDO Registration No';
              END IF;

             p_message_name := 'PER_IN_24Q_FIELDS_VALIDATE';
             p_token_name(1) := 'TOKEN1';
             p_token_value(1) := l_pao_ddo_code;
             p_token_name(2) := 'TOKEN2';
             p_token_value(2) := 'Employer Classification for Form 24Q/QC';
             p_token_name(3) := 'TOKEN3';
             p_token_value(3) := hr_general.decode_lookup('IN_24Q_ER_CLASS',p_org_information6);

             IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name||l_pao_ddo_code);
             pay_in_utils.trace('**************************************************','********************');
             END IF;
             pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,54);
             RETURN ;
       END IF;

      --Validation for Ministry Name

      IF ((p_org_information6 = 'A' OR p_org_information6 = 'D' OR p_org_information6 = 'G')
           AND p_org_information12 is NULL )
      THEN
       p_message_name := 'PER_IN_MISSING_ENTRY_VALUE';
       p_token_name(1) := 'TOKEN1';
       p_token_value(1) := 'Ministry Name';
       p_token_name(2) := 'TOKEN2';
       p_token_value(2) := 'Employer Classification for Form 24Q/QC';
       p_token_name(3) := 'TOKEN3';
       p_token_value(3) := hr_general.decode_lookup('IN_24Q_ER_CLASS',p_org_information6);
       IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_message_name',p_message_name);
       pay_in_utils.trace('**************************************************','********************');
       END IF;
       pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,56);
       RETURN ;
       ELSIF (p_org_information6 NOT IN ('A' , 'D' , 'G','E','H','L','N') AND
                p_org_information12 is NOT NULL)
              THEN
             p_message_name := 'PER_IN_24Q_FIELDS_VALIDATE';
             p_token_name(1) := 'TOKEN1';
             p_token_value(1) := 'Ministry Name';
	     p_token_name(2) := 'TOKEN2';
             p_token_value(2) := 'Employer Classification for Form 24Q/QC';
             p_token_name(3) := 'TOKEN3';
             p_token_value(3) := hr_general.decode_lookup('IN_24Q_ER_CLASS',p_org_information6);
	     IF g_debug THEN
                pay_in_utils.trace('**************************************************','********************');
                pay_in_utils.trace('p_message_name',p_message_name);
                pay_in_utils.trace('**************************************************','********************');
             END IF;
       pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,58);
       RETURN ;

      END IF;

     -- Validation for State Name

     IF ((p_org_information6 = 'S' OR p_org_information6 = 'E' OR p_org_information6 = 'H' OR p_org_information6 = 'N')
	  AND p_org_information9 is NULL )
     THEN
       p_message_name := 'PER_IN_MISSING_ENTRY_VALUE';
       p_token_name(1) := 'TOKEN1';
       p_token_value(1) := 'State';
       p_token_name(2) := 'TOKEN2';
       p_token_value(2) := 'Employer Classification for Form 24Q/QC';
       p_token_name(3) := 'TOKEN3';
       p_token_value(3) := hr_general.decode_lookup('IN_24Q_ER_CLASS',p_org_information6);
       IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_message_name',p_message_name);
       pay_in_utils.trace('**************************************************','********************');
       END IF;
       pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,582);
       RETURN ;
     ELSIF (p_org_information6 NOT IN ( 'S' , 'E' , 'H' , 'N')
	  AND p_org_information9 is NOT NULL )
     THEN
             p_message_name := 'PER_IN_24Q_FIELDS_VALIDATE';
             p_token_name(1) := 'TOKEN1';
             p_token_value(1) := 'State';
	     p_token_name(2) := 'TOKEN2';
             p_token_value(2) := 'Employer Classification for Form 24Q/QC';
             p_token_name(3) := 'TOKEN3';
             p_token_value(3) := hr_general.decode_lookup('IN_24Q_ER_CLASS',p_org_information6);
        IF g_debug THEN
          pay_in_utils.trace('**************************************************','********************');
          pay_in_utils.trace('p_message_name',p_message_name);
          pay_in_utils.trace('**************************************************','********************');
       END IF;
       pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,584);
       RETURN ;
      END IF;

          -- Validation for Other Ministry Name
      IF ( p_org_information12 = '99' AND p_org_information13 is NULL)
      THEN
       p_message_name := 'PER_IN_MISSING_ENTRY_VALUE';
       p_token_name(1) := 'TOKEN1';
       p_token_value(1) := 'Other Ministry Name';
       p_token_name(2) := 'TOKEN2';
       p_token_value(2) := 'Ministry Name';
       p_token_name(3) := 'TOKEN3';
       p_token_value(3) := 'Others';

       IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_message_name',p_message_name);
       pay_in_utils.trace('**************************************************','********************');
       END IF;
       pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,586);
       RETURN ;
      END IF;

       IF l_tan = 'X' THEN
      p_message_name := 'PER_IN_NON_UNIQUE_VALUE';
      p_token_name(1) := 'NUMBER_CATEGORY';
      p_token_value(1) := p_org_information1;
       END IF;
      ELSIF p_org_info_type_code = 'PER_IN_IT_CHALLAN_INFO' THEN
       -- Check for uniqueness of Challan Number
        IF p_org_information3 IS NOT NULL THEN

	  OPEN c_bsr_code;
          FETCH c_bsr_code INTO l_bsr_code;
          CLOSE c_bsr_code;

          OPEN chk_unique_challan(p_org_information3,l_organization_id,l_bsr_code);
          FETCH chk_unique_challan INTO l_exists;
          CLOSE chk_unique_challan;

          IF l_exists = 'X' THEN
            IF g_debug THEN
             pay_in_utils.trace('Check valid value from lookup=>Challan number',NULL);
            END IF;
            p_message_name  := 'PER_IN_NON_UNIQUE_IT_CHALLAN';
            IF g_debug THEN
               pay_in_utils.trace('**************************************************','********************');
               pay_in_utils.trace('p_message_name',p_message_name);
               pay_in_utils.trace('**************************************************','********************');
            END IF;
            pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
            RETURN ;
          END IF;

        END IF;

     ELSIF p_org_info_type_code IN('PER_IN_COMPANY_REP_DF'
                                  ,'PER_IN_FACTORY_REP_DF'
                                  ,'PER_IN_ESTABLISHMENT_REP_DF'
                                  ,'PER_IN_ESI_REP_DF'
                                  ,'PER_IN_PF_REP_DF'
                                --,'PER_IN_LABOR_DEPT_REP_DF'
                                  ,'PER_IN_INCOME_TAX_REP_DF'
                                  ,'PER_IN_PROF_TAX_REP_DF'
                                  ,'IN_CONTRACTOR_EMPLOYERS_REP') THEN


      pay_in_utils.set_location(g_debug,l_procedure,90);

      l_start_date := fnd_date.canonical_to_date(p_org_information2);
      l_end_date   := fnd_date.canonical_to_date(p_org_information3);

      --check start date is not greater than end date

      validate_date(p_effective_start_date=>l_start_date
                    ,p_effective_end_date=>l_end_date
                    ,p_message_name  => p_message_name
                    ,p_token_name    => p_token_name
                    ,p_token_value   =>  p_token_value);

       pay_in_utils.set_location(g_debug,l_procedure,80);

      --
      -- Check for overlap
      --

      OPEN chk_date_overlap_rep_upd(l_organization_id
                                   ,l_start_date
                                   ,l_end_date);

      FETCH chk_date_overlap_rep_upd INTO l_exists;

      pay_in_utils.set_location(g_debug,l_procedure,110);

        IF l_exists='X' THEN
         p_message_name := 'PER_IN_DATE_OVERLAP';

        END IF;
        IF g_debug THEN
           pay_in_utils.trace('**************************************************','********************');
           pay_in_utils.trace('p_message_name',p_message_name);
           pay_in_utils.trace('**************************************************','********************');
         END IF;
         pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
         RETURN ;
      CLOSE chk_date_overlap_rep_upd;
      pay_in_utils.set_location(g_debug,l_procedure,120);


    ELSIF p_org_info_type_code IN('IN_CONTRACTOR_WORK_INFO') THEN


      pay_in_utils.set_location(g_debug,l_procedure,125);

      l_start_date := fnd_date.canonical_to_date(p_org_information2);
      l_end_date   := fnd_date.canonical_to_date(p_org_information3);


      --
       -- Check that the start date is not greater than end date
       --

       validate_date(p_effective_start_date=>l_start_date
                    ,p_effective_end_date=>l_end_date
                    ,p_message_name  => p_message_name
                    ,p_token_name    => p_token_name
                    ,p_token_value   =>  p_token_value);

       IF p_message_name <> 'SUCCESS' THEN
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
          RETURN;
       END IF;

    ELSIF p_org_info_type_code='PER_IN_COMPANY_DF' THEN
      --
      -- Check if the format of Corporate identity Number is correct
      --
      pay_in_utils.set_location(g_debug,l_procedure,100);
      validate_corporate_number(p_org_information2=>p_org_information2
                               ,p_message_name  => p_message_name
                               ,p_token_name    => p_token_name
                               ,p_token_value   =>  p_token_value);

       IF p_message_name <> 'SUCCESS' THEN
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
          RETURN;
       END IF;


      pay_in_utils.set_location(g_debug,l_procedure,130);


    END IF; -- p_org_info_type_code ='PER_IN_INCOME_TAX_DF'

      pay_in_utils.set_location(g_debug,l_procedure,140);

  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
       pay_in_utils.trace(l_message,l_procedure);

END check_rep_upd;




--------------------------------------------------------------------------
-- Name           : check_pf_challan_accounts                           --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Nulled out to avoid user hook issues during upgrade --
-- Parameters     :                                                     --
--             IN : p_org_info_type_code      VARCHAR2                  --
--		    p_org_information3        VARCHAR2                  --
--                  p_org_information4        VARCHAR2                  --
--                  p_org_information5        VARCHAR2                  --
--                  p_org_information6        VARCHAR2                  --
--                  p_org_information7        VARCHAR2                  --
--                  p_org_information8        VARCHAR2                  --

--------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                    --
--------------------------------------------------------------------------
-- 1.0   16-May-2005    sukukuma         Modified this procedure        --
-- 1.1   17-sep-2007    sivanara         Added message parameters and   --
--                                       removed fnd_message code       --
-- 1.2   22-Apr-2008    mdubasi          Removed above fix to resolve   --
--                                       P1 6967621                     --
--                                       Also nulling out contents      --
--                                       Code will now be in a new      --
--                                       private procedure              --
--                                       CHECK_PF_CHALLANS              --
--------------------------------------------------------------------------
PROCEDURE check_pf_challan_accounts (p_org_info_type_code   IN VARCHAR2
                                    ,p_org_information3     IN VARCHAR2
                                    ,p_org_information4     IN VARCHAR2
                                    ,p_org_information5     IN VARCHAR2
                                    ,p_org_information6     IN VARCHAR2
                                    ,p_org_information7     IN VARCHAR2
                                    ,p_org_information8     IN VARCHAR2
                                    ) AS
   l_procedure VARCHAR2(100);
   l_message   VARCHAR2(300);
BEGIN

  null;

END;


--------------------------------------------------------------------------
-- Name           : CHECK_PF_CHALLANS                                   --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure checks if at least one of the account     --
--                  fields in the PF Challan Information has been       --
--                  entered or not.                                     --
-- Parameters     :                                                     --
--             IN : p_org_info_type_code      VARCHAR2                  --
--		    p_org_information3        VARCHAR2                  --
--                  p_org_information4        VARCHAR2                  --
--                  p_org_information5        VARCHAR2                  --
--                  p_org_information6        VARCHAR2                  --
--                  p_org_information7        VARCHAR2                  --
--                  p_org_information8        VARCHAR2                  --
--                  p_message_name  OUT NOCOPY VARCHAR2                 --
--                  p_token_name  OUT NOCOPY pay_in_utils.char_tab_type --
--                  p_token_value  OUT NOCOPY pay_in_utils.char_tab_type--
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                    --
--------------------------------------------------------------------------
-- 1.0   16-May-2005    sukukuma         Modified this procedure        --
-- 1.1   17-sep-2007    sivanara         Added message parameters and   --
--                                       removed fnd_message code       --
--------------------------------------------------------------------------
PROCEDURE CHECK_PF_CHALLANS (p_org_info_type_code   IN VARCHAR2
                                    ,p_org_information3     IN VARCHAR2
                                    ,p_org_information4     IN VARCHAR2
                                    ,p_org_information5     IN VARCHAR2
                                    ,p_org_information6     IN VARCHAR2
                                    ,p_org_information7     IN VARCHAR2
                                    ,p_org_information8     IN VARCHAR2
				    ,p_message_name       OUT NOCOPY VARCHAR2
                                    ,p_token_name         OUT NOCOPY pay_in_utils.char_tab_type
                                    ,p_token_value        OUT NOCOPY pay_in_utils.char_tab_type
                                    ) AS
   l_procedure VARCHAR2(100);
   l_message   VARCHAR2(300);
BEGIN

  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'IN') THEN
       IF g_debug THEN
           pay_in_utils.trace('IN Legislation not installed. Not performing the validations',NULL);
       END IF;
       pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
       RETURN;
  END IF;
     p_message_name := 'SUCCESS';
     pay_in_utils.null_message(p_token_name, p_token_value);
     l_procedure := g_package||'CHECK_PF_CHALLANS';
     g_debug := hr_utility.debug_enabled;
     pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_org_info_type_code',p_org_info_type_code);
       pay_in_utils.trace('p_org_information3  ',p_org_information3  );
       pay_in_utils.trace('p_org_information4  ',p_org_information4  );
       pay_in_utils.trace('p_org_information5  ',p_org_information5  );
       pay_in_utils.trace('p_org_information6  ',p_org_information6  );
       pay_in_utils.trace('p_org_information7  ',p_org_information7  );
       pay_in_utils.trace('p_org_information8  ',p_org_information8  );
       pay_in_utils.trace('**************************************************','********************');
   END IF;

  IF p_org_info_type_code = 'PER_IN_PF_CHALLAN_INFO' THEN

    IF nvl(p_org_information3, '0') <> '0' OR
       nvl(p_org_information4, '0') <> '0' OR
       nvl(p_org_information5, '0') <> '0' OR
       nvl(p_org_information6, '0') <> '0' OR
       nvl(p_org_information7, '0') <> '0' OR
       nvl(p_org_information8, '0') <> '0' THEN
      NULL;
    ELSE
        p_message_name := 'PER_IN_INVALID_PF_CHALLAN_DATA';
    END IF;

  END IF;

  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
       pay_in_utils.trace(l_message,l_procedure);

END;
--------------------------------------------------------------------------
-- Name           : chk_mon_pf_chn_acc                                  --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure checks if at least one of the account     --
--                  fields in the PF Challan Information for Section 7Q,--
--                  Section 14B and Miscellanous payment has been       --
--                  entered or not.                                     --
-- Parameters     :                                                     --
--             IN : p_org_info_type_code      VARCHAR2                  --
--		    p_org_information3        VARCHAR2                  --
--                  p_org_information4        VARCHAR2                  --
--                  p_org_information5        VARCHAR2                  --
--                  p_org_information6        VARCHAR2                  --
--                  p_org_information7        VARCHAR2                  --
--                  p_org_information8        VARCHAR2                  --
--                  p_org_information9        VARCHAR2                  --
--                  p_org_information10        VARCHAR2                 --
--                  p_org_information11       VARCHAR2                  --
--                  p_org_information12       VARCHAR2                  --
--                  p_org_information13       VARCHAR2                  --
--                  p_message_name  OUT NOCOPY VARCHAR2                 --
--                  p_token_name  OUT NOCOPY pay_in_utils.char_tab_type --
--                  p_token_value  OUT NOCOPY pay_in_utils.char_tab_type--
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                    --
--------------------------------------------------------------------------
-- 1.0   14-sep-2007    sivanara         Created this procedure         --
--------------------------------------------------------------------------
PROCEDURE chk_mon_pf_chn_acc (p_org_info_type_code   IN VARCHAR2
                                    ,p_org_information3     IN VARCHAR2
				    ,p_org_information4     IN VARCHAR2
                                    ,p_org_information5     IN VARCHAR2
                                    ,p_org_information6     IN VARCHAR2
				    ,p_org_information7     IN VARCHAR2
				    ,p_org_information8     IN VARCHAR2
				    ,p_org_information9     IN VARCHAR2
				    ,p_org_information10     IN VARCHAR2
				    ,p_org_information11     IN VARCHAR2
				    ,p_org_information12     IN VARCHAR2
				    ,p_org_information13     IN VARCHAR2
				    ,p_message_name       OUT NOCOPY VARCHAR2
                                    ,p_token_name         OUT NOCOPY pay_in_utils.char_tab_type
                                    ,p_token_value        OUT NOCOPY pay_in_utils.char_tab_type
                                    ) AS
   l_procedure VARCHAR2(100);
   l_message   VARCHAR2(300);
BEGIN

  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'IN') THEN
       IF g_debug THEN
           pay_in_utils.trace('IN Legislation not installed. Not performing the validations',NULL);
       END IF;
       pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
       RETURN;
  END IF;
     p_message_name := 'SUCCESS';
     pay_in_utils.null_message(p_token_name, p_token_value);
     l_procedure := g_package||'chk_mon_pf_chn_acc';
     g_debug := hr_utility.debug_enabled;
     pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_org_info_type_code',p_org_info_type_code);
       pay_in_utils.trace('p_org_information3  ',p_org_information3  );
       pay_in_utils.trace('p_org_information4  ',p_org_information4  );
       pay_in_utils.trace('p_org_information5  ',p_org_information5  );
       pay_in_utils.trace('p_org_information6  ',p_org_information6  );
       pay_in_utils.trace('p_org_information7  ',p_org_information7  );
       pay_in_utils.trace('p_org_information8  ',p_org_information8  );
       pay_in_utils.trace('p_org_information9  ',p_org_information9  );
       pay_in_utils.trace('p_org_information10  ',p_org_information10);
       pay_in_utils.trace('p_org_information11  ',p_org_information11);
       pay_in_utils.trace('p_org_information12  ',p_org_information12);
       pay_in_utils.trace('p_org_information13  ',p_org_information13);
       pay_in_utils.trace('**************************************************','********************');
   END IF;

  IF p_org_info_type_code = 'PER_IN_PF_CHN_SEC14B' THEN

    IF nvl(p_org_information4, '0') <> '0' OR
       nvl(p_org_information5, '0') <> '0' OR
       nvl(p_org_information6, '0') <> '0' OR
       nvl(p_org_information7, '0') <> '0' OR
       nvl(p_org_information8, '0') <> '0' OR
       nvl(p_org_information9, '0') <> '0' THEN
       pay_in_utils.trace('p_org_information4  ',nvl(p_org_information4,'0'));
      NULL;
    ELSE
      p_message_name := 'PER_IN_INVALID_PF_CHALLAN_DATA';
    END IF;
  ELSIF p_org_info_type_code = 'PER_IN_PF_SEC7Q_INFO' THEN

    IF nvl(p_org_information3, '0') <> '0' OR
       nvl(p_org_information4, '0') <> '0' OR
       nvl(p_org_information5, '0') <> '0' OR
       nvl(p_org_information6, '0') <> '0' OR
       nvl(p_org_information7, '0') <> '0' OR
       nvl(p_org_information8, '0') <> '0' THEN
      NULL;
    ELSE
          p_message_name := 'PER_IN_INVALID_PF_CHALLAN_DATA';
    END IF;
  ELSIF p_org_info_type_code = 'PER_IN_PF_MIS_PAY_INFO' THEN

    IF nvl(p_org_information4, '0') <> '0' OR
       nvl(p_org_information5, '0') <> '0' OR
       nvl(p_org_information7, '0') <> '0' OR
       nvl(p_org_information9, '0') <> '0' OR
       nvl(p_org_information11, '0') <> '0' OR
       nvl(p_org_information13, '0') <> '0' THEN
      NULL;
    ELSE
       p_message_name := 'PER_IN_INVALID_PF_CHALLAN_DATA';
    END IF;
  END IF;

  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
       pay_in_utils.trace(l_message,l_procedure);

END chk_mon_pf_chn_acc;

--------------------------------------------------------------------------
-- Name           : check_lwf_challan_accounts                          --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure checks if at least one of the account     --
--                  fields in the LWF Challan Information has been      --
--                  entered or not.                                     --
-- Parameters     :                                                     --
--             IN : p_org_info_type_code      VARCHAR2                  --
--		    p_org_information3        VARCHAR2                  --
--                  p_org_information4        VARCHAR2                  --
--                  p_org_information5        VARCHAR2                  --
--                  p_org_information6        VARCHAR2                  --
--                  p_message_name  OUT NOCOPY VARCHAR2                 --
--                  p_token_name  OUT NOCOPY pay_in_utils.char_tab_type --
--                  p_token_value  OUT NOCOPY pay_in_utils.char_tab_type--
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                    --
--------------------------------------------------------------------------
-- 1.0   03-Nov-2007    sivanara         Created this Procedure         --
--------------------------------------------------------------------------
PROCEDURE check_lwf_challan_accounts (p_org_info_type_code   IN VARCHAR2
                                    ,p_org_information3     IN VARCHAR2
                                    ,p_org_information4     IN VARCHAR2
                                    ,p_org_information5     IN VARCHAR2
                                    ,p_org_information6     IN VARCHAR2
                  		    ,p_message_name       OUT NOCOPY VARCHAR2
                                    ,p_token_name         OUT NOCOPY pay_in_utils.char_tab_type
                                    ,p_token_value        OUT NOCOPY pay_in_utils.char_tab_type
                                    ) AS
   l_procedure VARCHAR2(100);
   l_message   VARCHAR2(300);
BEGIN

  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'IN') THEN
       IF g_debug THEN
           pay_in_utils.trace('IN Legislation not installed. Not performing the validations',NULL);
       END IF;
       pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
       RETURN;
  END IF;
     p_message_name := 'SUCCESS';
     pay_in_utils.null_message(p_token_name, p_token_value);
     l_procedure := g_package||'check_lwf_challan_accounts';
     g_debug := hr_utility.debug_enabled;
     pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_org_info_type_code',p_org_info_type_code);
       pay_in_utils.trace('p_org_information3  ',p_org_information3  );
       pay_in_utils.trace('p_org_information4  ',p_org_information4  );
       pay_in_utils.trace('p_org_information5  ',p_org_information5  );
       pay_in_utils.trace('p_org_information6  ',p_org_information6  );
       pay_in_utils.trace('**************************************************','********************');
   END IF;

  IF p_org_info_type_code = 'PER_IN_LWF_CHALLAN_INFO' THEN

    IF nvl(p_org_information3, '0') <> '0' OR
       nvl(p_org_information4, '0') <> '0' OR
       nvl(p_org_information5, '0') <> '0' OR
       nvl(p_org_information6, '0') <> '0' THEN
      NULL;
    ELSE
        p_message_name := 'PER_IN_INVALID_PF_CHALLAN_DATA';
    END IF;

  END IF;

  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
       pay_in_utils.trace(l_message,l_procedure);

END;

--------------------------------------------------------------------------
-- Name           : check_lwf_contribution_freq                         --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure checks if at least one of the account     --
--                  fields in the PF Challan Information for Section 7Q,--
--                  Section 14B and Miscellanous payment has been       --
--                  entered or not.                                     --
-- Parameters     :                                                     --
--             IN : p_org_information1        VARCHAR2                  --
--                  p_org_information2        VARCHAR2                  --
--                  p_message_name OUT NOCOPY VARCHAR2                  --
--                  p_token_name  OUT NOCOPY pay_in_utils.char_tab_type --
--                  p_token_value  OUT NOCOPY pay_in_utils.char_tab_type--
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                    --
--------------------------------------------------------------------------
-- 1.0   03-nov-2007    sivanara         Created this procedure         --
--------------------------------------------------------------------------
PROCEDURE check_lwf_contribution_freq (p_org_information1     IN VARCHAR2
				    ,p_org_information2     IN VARCHAR2
				    ,p_message_name       OUT NOCOPY VARCHAR2
                                    ,p_token_name         OUT NOCOPY pay_in_utils.char_tab_type
                                    ,p_token_value        OUT NOCOPY pay_in_utils.char_tab_type
                                    ) AS
   l_procedure VARCHAR2(100);
   l_message   VARCHAR2(300);
BEGIN

  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'IN') THEN
       IF g_debug THEN
           pay_in_utils.trace('IN Legislation not installed. Not performing the validations',NULL);
       END IF;
       pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
       RETURN;
  END IF;
     p_message_name := 'SUCCESS';
     pay_in_utils.null_message(p_token_name, p_token_value);
     l_procedure := g_package||'check_lwf_contribution_freq';
     g_debug := hr_utility.debug_enabled;
     pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_org_information1  ',p_org_information1);
       pay_in_utils.trace('p_org_information2  ',p_org_information2);
       pay_in_utils.trace('**************************************************','********************');
   END IF;

    IF p_org_information1 = 'TN' AND p_org_information2 <> '12'  THEN
      p_message_name := 'PER_IN_LWF_STATE_FREQ_MAP';
      p_token_name(1)  := 'STATE';
      p_token_value(1) := 'TamilNadu';
      p_token_name(2)  := 'FREQUENCY';
      p_token_value(2) := 'Yearly';
   ELSIF p_org_information1 = 'AP' AND p_org_information2 <> '12' THEN
      p_message_name := 'PER_IN_LWF_STATE_FREQ_MAP';
      p_token_name(1)  := 'STATE';
      p_token_value(1) := 'Andhra Pradesh';
      p_token_name(2)  := 'FREQUENCY';
      p_token_value(2) := 'Yearly';
   ELSIF p_org_information1 = 'KA' AND p_org_information2 <> '12' THEN
      p_message_name := 'PER_IN_LWF_STATE_FREQ_MAP';
      p_token_name(1)  := 'STATE';
      p_token_value(1) := 'Karnataka';
      p_token_name(2)  := 'FREQUENCY';
      p_token_value(2) := 'Yearly';
    ELSIF p_org_information1 = 'KL' AND p_org_information2 <> '2' THEN
      p_message_name := 'PER_IN_LWF_STATE_FREQ_MAP';
      p_token_name(1)  := 'STATE';
      p_token_value(1) := 'Kerala';
      p_token_name(2)  := 'FREQUENCY';
      p_token_value(2) := 'Half-Yearly';
    ELSIF p_org_information1 = 'GJ' AND p_org_information2 <> '2' THEN
      p_message_name := 'PER_IN_LWF_STATE_FREQ_MAP';
      p_token_name(1)  := 'STATE';
      p_token_value(1) := 'Gujarat';
      p_token_name(2)  := 'FREQUENCY';
      p_token_value(2) := 'Half-Yearly';
    ELSIF p_org_information1 = 'MP' AND p_org_information2 <> '2' THEN
      p_message_name := 'PER_IN_LWF_STATE_FREQ_MAP';
      p_token_name(1)  := 'STATE';
      p_token_value(1) := 'Madhya Pradesh';
      p_token_name(2)  := 'FREQUENCY';
      p_token_value(2) := 'Half-Yearly';
    ELSIF p_org_information1 = 'MH' AND p_org_information2 <> '2' THEN
      p_message_name := 'PER_IN_LWF_STATE_FREQ_MAP';
      p_token_name(1)  := 'STATE';
      p_token_value(1) := 'Maharastra';
      p_token_name(2)  := 'FREQUENCY';
      p_token_value(2) := 'Half-Yearly';

    END IF;

  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
       pay_in_utils.trace(l_message,l_procedure);

END check_lwf_contribution_freq;
--------------------------------------------------------------------------
-- Name           : check_org_internal                                  --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Main Procedure to be called from the Org Hook       --
-- Parameters     :                                                     --
--             IN : p_effective_date          DATE                      --
--                  p_organization_id         NUMBER                    --
--                  p_name                    VARCHAR2                  --
--                  p_date_from               DATE                      --
--                  p_date_to                 DATE                      --
--                  p_location_id             NUMBER                    --
--                  p_calling_procedure       VARCHAR2                  --
--            OUT : p_message_name            VARCHAR2                  --
--                : p_token_name              VARCHAR2                  --
--                : p_token_value             VARCHAR2                  --
--                                                                      --
--            OUT : 3                                                   --
--         RETURN : N/A                                                 --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                    --
--------------------------------------------------------------------------
-- 1.0   16-May-2005    sukukuma         Modified this procedure        --
--------------------------------------------------------------------------

PROCEDURE check_org_internal
                (p_effective_date     IN  DATE,
                 p_organization_id    IN NUMBER,
                 p_name               IN VARCHAR2,
                 p_date_from          IN DATE,
                 p_date_to            IN DATE,
                 p_location_id        IN NUMBER,
                 p_calling_procedure  IN VARCHAR2,
                 p_message_name       OUT NOCOPY VARCHAR2,
                 p_token_name         OUT NOCOPY pay_in_utils.char_tab_type,
                 p_token_value        OUT NOCOPY pay_in_utils.char_tab_type)
IS
   l_procedure  VARCHAR2(100);
   l_message    VARCHAR2(300);

BEGIN


  l_procedure := g_package||'check_org_internal';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_effective_date   ',p_effective_date   );
       pay_in_utils.trace('p_organization_id  ',p_organization_id  );
       pay_in_utils.trace('p_name             ',p_name             );
       pay_in_utils.trace('p_date_from        ',p_date_from        );
       pay_in_utils.trace('p_date_to          ',p_date_to          );
       pay_in_utils.trace('p_location_id      ',p_location_id      );
       pay_in_utils.trace('p_calling_procedure',p_calling_procedure);
       pay_in_utils.trace('p_message_name     ',p_message_name     );
       pay_in_utils.trace('**************************************************','********************');
   END IF;

  p_message_name := 'SUCCESS';
  pay_in_utils.null_message(p_token_name, p_token_value);

  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'IN') THEN
       IF g_debug THEN
           pay_in_utils.trace('IN Legislation not installed. Not performing the validations',NULL);
       END IF;
       pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
       RETURN;
  END IF;

  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  IF pay_in_utils.chk_org_class(p_organization_id, 'IN_PTAX_ORG') THEN
     pay_in_utils.set_location(g_debug,l_procedure,20);
     pay_in_prof_tax_pkg.check_pt_loc
                (p_organization_id   => p_organization_id
                ,p_calling_procedure => p_calling_procedure
                ,p_location_id       => p_location_id
                ,p_message_name      => p_message_name
                ,p_token_name        => p_token_name
                ,p_token_value       => p_token_value);

  END IF;
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);

  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
       pay_in_utils.trace(l_message,l_procedure);


END check_org_internal;




--------------------------------------------------------------------------
-- Name           : check_organization_update                           --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Main Procedure to be called from the Org Hook       --
-- Parameters     :                                                     --
--             IN : p_effective_date                DATE                --
--                  p_organization_id               NUMBER              --
--                  p_name                          VARCHAR2            --
--                  p_date_from                     DATE                --
--                  p_date_to                       DATE                --
--                  p_location_id                   NUMBER              --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                    --
--------------------------------------------------------------------------
-- 1.0   16-May-2005    sukukuma         Modified this procedure        --
--------------------------------------------------------------------------

PROCEDURE check_organization_update
                (p_effective_date     IN  DATE,
                 p_organization_id    IN NUMBER,
                 p_name               IN VARCHAR2,
                 p_date_from          IN DATE,
                 p_date_to            IN DATE,
                 p_location_id        IN NUMBER)
IS
   CURSOR c_org_id IS
      SELECT organization_id
            ,name
            ,date_from
            ,date_to
            ,location_id
      FROM   hr_organization_units
      WHERE  organization_id = p_organization_id;

   l_organization_id     hr_organization_units.organization_id%TYPE;
   l_name                hr_organization_units.name%TYPE;
   l_date_from           hr_organization_units.date_from%TYPE;
   l_date_to             hr_organization_units.date_to%TYPE;
   l_location_id         hr_organization_units.location_id%TYPE;

   l_procedure  VARCHAR2(100);
   l_message    VARCHAR2(300);

BEGIN

  l_procedure := g_package||'check_organization_update';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_effective_date ',p_effective_date );
       pay_in_utils.trace('p_organization_id',p_organization_id);
       pay_in_utils.trace('p_name           ',p_name           );
       pay_in_utils.trace('p_date_from      ',p_date_from      );
       pay_in_utils.trace('p_date_to        ',p_date_to        );
       pay_in_utils.trace('p_location_id    ',p_location_id    );
       pay_in_utils.trace('**************************************************','********************');
   END IF;

  p_message_name := 'SUCCESS';
  pay_in_utils.null_message(p_token_name, p_token_value);

  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  OPEN c_org_id;
  FETCH c_org_id
  INTO l_organization_id
      ,l_name
      ,l_date_from
      ,l_date_to
      ,l_location_id;
  CLOSE c_org_id;

  pay_in_utils.set_location(g_debug,l_procedure,20);

   IF p_name <> hr_api.g_varchar2 THEN
       l_name := p_name;
   END IF;

   IF p_location_id <> hr_api.g_number THEN
       l_location_id := p_location_id;
   END IF;

   IF p_date_from <> hr_api.g_date THEN
       l_date_from := p_date_from;
   END IF;

   IF p_date_to <> hr_api.g_date THEN
       l_date_to := p_date_to;
   END IF;

   check_org_internal
         (p_effective_date     => p_effective_date
         ,p_organization_id    => p_organization_id
         ,p_name               => l_name
         ,p_date_from          => l_date_from
         ,p_date_to            => l_date_to
         ,p_location_id        => l_location_id
         ,p_calling_procedure  => l_procedure
         ,p_message_name       => p_message_name
         ,p_token_name         => p_token_name
         ,p_token_value        => p_token_value);

  pay_in_utils.raise_message(800, p_message_name, p_token_name, p_token_value);
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,10);
/*
  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
       pay_in_utils.trace(l_message,l_procedure);
*/

END check_organization_update;



--------------------------------------------------------------------------
-- Name           : check_org_class_internal                            --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : Internal Proc  to be called from the Org Class Hook --
-- Parameters     :                                                     --
--             IN : p_effective_date        DATE                        --
--                : p_organization_id       NUMBER                      --
--                : p_org_classif_code      VARCHAR2                    --
--            OUT : p_message_name          VARCHAR2                    --
--                : p_token_name            VARCHAR2                    --
--                : p_token_value           VARCHAR2                    --
--                                                                      --
--            OUT : 3                                                   --
--         RETURN : N/A                                                 --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                    --
--------------------------------------------------------------------------
-- 1.0   16-May-2005    sukukuma         Modified this procedure        --
--------------------------------------------------------------------------


 PROCEDURE check_org_class_internal
               (p_effective_date     IN  DATE,
                p_organization_id    IN NUMBER,
                p_org_classif_code   IN VARCHAR2,
                p_calling_procedure  IN VARCHAR2,
                p_message_name       OUT NOCOPY VARCHAR2,
                p_token_name         OUT NOCOPY pay_in_utils.char_tab_type,
                p_token_value        OUT NOCOPY pay_in_utils.char_tab_type)
IS
   l_procedure  VARCHAR2(100);
   l_message    VARCHAR2(300);

BEGIN

  l_procedure := g_package||'check_org_class_internal';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_effective_date   ',p_effective_date   );
       pay_in_utils.trace('p_organization_id  ',p_organization_id  );
       pay_in_utils.trace('p_org_classif_code ',p_org_classif_code );
       pay_in_utils.trace('p_calling_procedure',p_calling_procedure);
       pay_in_utils.trace('p_message_name     ',p_message_name     );
       pay_in_utils.trace('**************************************************','********************');
   END IF;

  p_message_name := 'SUCCESS';
  pay_in_utils.null_message(p_token_name, p_token_value);

  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


  IF p_org_classif_code = 'IN_PTAX_ORG' THEN
     pay_in_prof_tax_pkg.check_pt_org_class
                (p_organization_id   => p_organization_id
                ,p_calling_procedure => p_calling_procedure
                ,p_message_name      => p_message_name
                ,p_token_name        => p_token_name
                ,p_token_value       => p_token_value);
  /*4033748*/
  ELSIF p_org_classif_code IN('IN_COMPANY','IN_FACTORY','IN_ESTABLISHMENT')THEN
     pay_in_ff_pkg.check_pf_location
                (p_organization_id   => p_organization_id
                ,p_calling_procedure => p_calling_procedure
                ,p_message_name      => p_message_name
                ,p_token_name        => p_token_name
                ,p_token_value       => p_token_value);
  END IF;
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
       pay_in_utils.trace(l_message,l_procedure);


END check_org_class_internal;



--------------------------------------------------------------------------
-- Name           : check_org_class_create                              --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : Internal Proc  to be called from the Org Class Hook --
-- Parameters     :                                                     --
--             IN : p_effective_date            DATE                    --
--                  p_organization_id           NUMBER                  --
--                  p_org_classif_code          VARCHAR2                --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                    --
--------------------------------------------------------------------------
-- 1.0   16-May-2005    sukukuma         Modified this procedure        --
--------------------------------------------------------------------------


PROCEDURE check_org_class_create
               (p_effective_date     IN  DATE
               ,p_organization_id    IN NUMBER
               ,p_org_classif_code   IN VARCHAR2
               )
IS
   l_procedure  VARCHAR2(100);
   l_message    VARCHAR2(300);

BEGIN

  l_procedure := g_package||'check_org_class_create';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_effective_date  ',p_effective_date  );
       pay_in_utils.trace('p_organization_id ',p_organization_id );
       pay_in_utils.trace('p_org_classif_code',p_org_classif_code);
       pay_in_utils.trace('**************************************************','********************');
   END IF;

  p_message_name := 'SUCCESS';
  pay_in_utils.null_message(p_token_name, p_token_value);

  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  check_org_class_internal
               (p_effective_date     => p_effective_date,
                p_organization_id    => p_organization_id,
                p_org_classif_code   => p_org_classif_code,
                p_calling_procedure  => l_procedure,
                p_message_name       => p_message_name,
                p_token_name         => p_token_name,
                p_token_value        => p_token_value);

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
  pay_in_utils.raise_message(800, p_message_name, p_token_name, p_token_value);
/*
  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
       pay_in_utils.trace(l_message,l_procedure);

*/
END check_org_class_create;




----------------------------------------------------------------------------------
-- Name           : check_org_info_internal                                     --
-- Type           : Procedure                                                   --
-- Access         : Public                                                      --
-- Description    : Internal Procedure to be called from the Org Info Hook      --
-- Parameters     :                                                             --
--             IN : p_effective_date        DATE                                --
--                : p_org_information_id    NUMBER                              --
--                : p_org_info_type_code    VARCHAR2                            --
--                : p_org_information1      VARCHAR2                            --
--                : p_org_information2      VARCHAR2                            --
--                : p_org_information3      VARCHAR2                            --
--                : p_org_information4      VARCHAR2                            --
--                : p_org_information5      VARCHAR2                            --
--                : p_org_information6      VARCHAR2                            --
--                : p_org_information8      VARCHAR2                            --
--                : p_org_information9      VARCHAR2                            --
--                : p_org_information10     VARCHAR2                            --
--                : p_org_information11     VARCHAR2                            --
--                : p_org_information12     VARCHAR2                            --
--                : p_org_information13     VARCHAR2                            --
--                : p_org_information14     VARCHAR2                            --
--                : p_org_information15     VARCHAR2                            --
--                : p_org_information16     VARCHAR2                            --
--                : p_org_information17     VARCHAR2                            --
--                : p_org_information18     VARCHAR2                            --
--                : p_org_information19     VARCHAR2                            --
--                : p_org_information20     VARCHAR2                            --
--            OUT : p_message_name          VARCHAR2                            --
--                : p_token_name            VARCHAR2                            --
--                : p_token_value           VARCHAR2                            --
--                                                                              --
--            OUT : 3                                                           --
--         RETURN : N/A                                                         --
-- Change History :                                                             --
----------------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                            --
----------------------------------------------------------------------------------
-- 1.0   16-May-2005    sukukuma         Modified this procedure                --
-- 1.1   05-Jan-2006    lnagaraj         Validations for PER_IN_IT_CHALLAN_INFO --
-- 1.2   25-Aug-2007    sivanara         Added Validation for PF monthly Returns--
-- 1.3   03-Nov-2007    sivanara         Added validation for LWF               --
----------------------------------------------------------------------------------

PROCEDURE check_org_info_internal
                (p_effective_date     IN  DATE,
                 p_org_information_id IN NUMBER,
                 p_organization_id    IN NUMBER,
                 p_org_info_type_code IN VARCHAR2,
                 p_org_information1   IN VARCHAR2,
                 p_org_information2   IN VARCHAR2,
                 p_org_information3   IN VARCHAR2,
                 p_org_information4   IN VARCHAR2,
                 p_org_information5   IN VARCHAR2,
                 p_org_information6   IN VARCHAR2,
                 p_org_information7   IN VARCHAR2,
                 p_org_information8   IN VARCHAR2,
                 p_org_information9   IN VARCHAR2,
                 p_org_information10  IN VARCHAR2,
                 p_org_information11  IN VARCHAR2,
                 p_org_information12  IN VARCHAR2,
                 p_org_information13  IN VARCHAR2,
                 p_org_information14  IN VARCHAR2,
                 p_org_information15  IN VARCHAR2,
                 p_org_information16  IN VARCHAR2,
                 p_org_information17  IN VARCHAR2,
                 p_org_information18  IN VARCHAR2,
                 p_org_information19  IN VARCHAR2,
                 p_org_information20  IN VARCHAR2,
                 p_calling_procedure  IN VARCHAR2,
                 p_message_name       OUT NOCOPY VARCHAR2,
                 p_token_name         OUT NOCOPY pay_in_utils.char_tab_type,
                 p_token_value        OUT NOCOPY pay_in_utils.char_tab_type)
IS
   CURSOR csr_employer_type
       IS
   SELECT org_information6
     FROM hr_organization_information hoi
    WHERE hoi.organization_id =p_organization_id
      AND hoi.org_information_context ='PER_IN_INCOME_TAX_DF';

   CURSOR csr_orig_check(p_org_information1 VARCHAR2
                       , p_org_information2 VARCHAR2
                       , p_org_information_id NUMBER)
       IS
       SELECT COUNT(*)
         FROM hr_organization_information
        WHERE organization_id = p_organization_id
          AND org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
          AND org_information1 = p_org_information1
          AND org_information2 = p_org_information2
          AND org_information3 IS NOT NULL
          AND org_information5 = 'A'
          AND org_information6 = 'O'
          AND (p_org_information_id IS NULL
            OR p_org_information_id <> org_information_id);

   CURSOR csr_correction_check(p_org_information1 VARCHAR2
                             , p_org_information2 VARCHAR2)
       IS
       SELECT COUNT(*)
         FROM hr_organization_information
        WHERE organization_id = p_organization_id
          AND org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
          AND org_information1 = p_org_information1
          AND org_information2 = p_org_information2
          AND org_information3 IS NOT NULL
          AND org_information6 = 'O';

   CURSOR csr_challan_no_upd_chk(p_org_information_id NUMBER
                               , p_org_information3   VARCHAR2
                               , p_organization_id    NUMBER
			       , p_org_information2   VARCHAR2)
       IS
       SELECT 'Y'
          FROM DUAL
         WHERE EXISTS
                (  SELECT 1
                     FROM hr_organization_information hoi
                         ,pay_element_entries_f pee
                         ,pay_element_types_f   pet
                    WHERE pet.element_name = 'Income Tax Challan Information'
                      AND pet.legislation_code = 'IN'
                      AND pee.element_type_id = pet.element_type_id
                      AND pay_in_utils.get_ee_value(pee.element_entry_id,'Challan or Voucher Number')  like '% - %'||hoi.org_information3||'% - %'||to_char(fnd_date.canonical_to_date(hoi.org_information2),'DD-Mon-RRRR')
                      AND hoi.org_information_context = 'PER_IN_IT_CHALLAN_INFO'
                      AND hoi.org_information_id = p_org_information_id
                      AND hoi.organization_id = p_organization_id
                      AND (hoi.org_information3 <> p_org_information3 OR hoi.org_information2 <> p_org_information2)
              );


   l_emlpr_type hr_organization_information.org_information3%TYPE;
   l_book_entry_allowed VARCHAR2(1);
   l_procedure          VARCHAR2(100);
   l_message            VARCHAR2(300);
   l_receipt_count      NUMBER;
   l_child_rec_flag     VARCHAR2(10);
   l_bank_det_count     NUMBER;
   l_pf_chn_no_chk      VARCHAR2(2);

BEGIN
  l_procedure := g_package||'check_org_info_internal';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

  p_message_name := 'SUCCESS';
  pay_in_utils.null_message(p_token_name, p_token_value);

  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'IN') THEN
       IF g_debug THEN
           pay_in_utils.trace('IN Legislation not installed. Not performing the validations',NULL);
       END IF;
       pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
       RETURN;
  END IF;

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_effective_date    ',p_effective_date    );
     pay_in_utils.trace('p_org_information_id',p_org_information_id);
     pay_in_utils.trace('p_organization_id   ',p_organization_id   );
     pay_in_utils.trace('p_org_info_type_code',p_org_info_type_code);
     pay_in_utils.trace('p_org_information1  ',p_org_information1  );
     pay_in_utils.trace('p_org_information2  ',p_org_information2  );
     pay_in_utils.trace('p_org_information3  ',p_org_information3  );
     pay_in_utils.trace('p_org_information4  ',p_org_information4  );
     pay_in_utils.trace('p_org_information5  ',p_org_information5  );
     pay_in_utils.trace('p_org_information6  ',p_org_information6  );
     pay_in_utils.trace('p_org_information7  ',p_org_information7  );
     pay_in_utils.trace('p_org_information8  ',p_org_information8  );
     pay_in_utils.trace('p_org_information9  ',p_org_information9  );
     pay_in_utils.trace('p_org_information10 ',p_org_information10 );
     pay_in_utils.trace('p_org_information11 ',p_org_information11 );
     pay_in_utils.trace('p_org_information12 ',p_org_information12 );
     pay_in_utils.trace('p_org_information13 ',p_org_information13 );
     pay_in_utils.trace('p_org_information14 ',p_org_information14 );
     pay_in_utils.trace('p_org_information15 ',p_org_information15 );
     pay_in_utils.trace('p_org_information16 ',p_org_information16 );
     pay_in_utils.trace('p_org_information17 ',p_org_information17 );
     pay_in_utils.trace('p_org_information18 ',p_org_information18 );
     pay_in_utils.trace('p_org_information19 ',p_org_information19 );
     pay_in_utils.trace('p_org_information20 ',p_org_information20 );
     pay_in_utils.trace('p_calling_procedure ',p_calling_procedure );
     pay_in_utils.trace('p_message_name      ',p_message_name      );
     pay_in_utils.trace('**************************************************','********************');
  END IF;

  pay_in_utils.set_location(g_debug,l_procedure,20);

  IF p_org_info_type_code = 'PER_IN_PT_EXEMPTIONS' THEN
      pay_in_prof_tax_pkg.check_pt_exemptions
         (p_organization_id    => p_organization_id
         ,p_org_information_id => p_org_information_id
         ,p_org_info_type_code => p_org_info_type_code
         ,p_state              => p_org_information1
         ,p_exemption_catg     => p_org_information2
         ,p_eff_start_date     => p_org_information3
         ,p_eff_end_date       => p_org_information4
         ,p_calling_procedure  => p_calling_procedure
         ,p_message_name       => p_message_name
         ,p_token_name         => p_token_name
         ,p_token_value        => p_token_value);
      IF g_debug THEN
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('p_message_name',p_message_name);
         pay_in_utils.trace('**************************************************','********************');
      END IF;
      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
      RETURN;
  ELSIF p_org_info_type_code = 'PER_IN_PT_FREQUENCY' THEN
      pay_in_prof_tax_pkg.check_pt_frequency
         (p_organization_id    => p_organization_id
         ,p_org_information_id => p_org_information_id
         ,p_org_info_type_code => p_org_info_type_code
         ,p_state              => p_org_information1
         ,p_frequency          => p_org_information2
         ,p_eff_start_date     => p_org_information3
         ,p_eff_end_date       => p_org_information4
         ,p_calling_procedure  => p_calling_procedure
         ,p_message_name       => p_message_name
         ,p_token_name         => p_token_name
         ,p_token_value        => p_token_value);
      IF g_debug THEN
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('p_message_name',p_message_name);
         pay_in_utils.trace('**************************************************','********************');
      END IF;
      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
      RETURN;

  ELSIF p_org_info_type_code = 'PER_IN_PT_CHALLAN_INFO' THEN
      pay_in_prof_tax_pkg.check_pt_challan_info
         (p_organization_id    => p_organization_id
         ,p_org_info_type_code => p_org_info_type_code
         ,p_payment_month      => p_org_information1
         ,p_payment_date       => p_org_information2
         ,p_payment_mode       => p_org_information3
         ,p_voucher_number     => p_org_information4
         ,p_amount             => p_org_information5
         ,p_interest           => p_org_information6
         ,p_payment_year       => p_org_information9
         ,p_excess_tax         => p_org_information8
         ,p_calling_procedure  => p_calling_procedure
         ,p_message_name       => p_message_name
         ,p_token_name         => p_token_name
         ,p_token_value        => p_token_value);
      IF g_debug THEN
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('p_message_name',p_message_name);
         pay_in_utils.trace('**************************************************','********************');
      END IF;
      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
      RETURN;
--
-- Bug 3847355  Added check_notice_period
--
  ELSIF p_org_info_type_code = 'PER_IN_NOTICE_DF' THEN
      pay_in_termination_pkg.check_notice_period
         (p_organization_id    => p_organization_id
         ,p_org_information_id => p_org_information_id
         ,p_org_info_type_code => p_org_info_type_code
         ,p_emp_category       => p_org_information1
         ,p_notice_period      => p_org_information2
         ,p_calling_procedure  => p_calling_procedure
         ,p_message_name       => p_message_name
         ,p_token_name         => p_token_name
         ,p_token_value        => p_token_value);
      IF g_debug THEN
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('p_message_name',p_message_name);
         pay_in_utils.trace('**************************************************','********************');
      END IF;
      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
      RETURN;
--
-- Bug 4057498  Added to make SRTC No mandatory for Mahrashtra
--
  ELSIF p_org_info_type_code = 'PER_IN_PROF_TAX_DF' THEN
/*      pay_in_prof_tax_pkg.check_srtc_state
         (p_organization_id    => p_organization_id
         ,p_org_information_id => p_org_information_id
         ,p_org_info_type_code => p_org_info_type_code
         ,p_srtc               => p_org_information3
         ,p_calling_procedure  => p_calling_procedure
         ,p_message_name       => p_message_name
         ,p_token_name         => p_token_name
         ,p_token_value        => p_token_value);*/
      IF (p_org_information4 = 'MH' AND p_org_information3 IS NULL)
      THEN
         p_message_name := 'PER_IN_BSRTC_NO';
      END IF;
      IF g_debug THEN
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('p_message_name',p_message_name);
         pay_in_utils.trace('**************************************************','********************');
      END IF;
      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
      RETURN;
--
-- Bug 4165173 Added to enforce validation on TAN and TAN Acknowledgement Number
-- Bug 4990632 Removed validation on TAN Acknowledgement Number
--
  ELSIF p_org_info_type_code = 'PER_IN_INCOME_TAX_DF' THEN

       IF p_org_information1 IS NULL
       THEN
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
          p_message_name  := 'HR_7207_API_MANDATORY_ARG';
          p_token_name(1) := 'ARGUMENT';
          p_token_name(2) := 'API_NAME';
          p_token_value(1):= 'p_org_information1';
          p_token_value(2):= l_procedure;
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
          RETURN;
        END IF;
  ELSIF p_org_info_type_code = 'PER_IN_IT_CHALLAN_INFO' THEN
       pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
       OPEN csr_employer_type;
       FETCH csr_employer_type INTO l_emlpr_type;
       CLOSE csr_employer_type;

       IF l_emlpr_type IN ('A','S','D','E','G','H','L','N') THEN
         l_book_entry_allowed :='Y';
       ELSE
         l_book_entry_allowed :='N';
       END IF;

       IF (l_book_entry_allowed ='N' AND p_org_information12 ='Y')
       THEN
        -- Non-Government companies cannot transfer through Book Entry
           p_message_name:='PER_IN_INCORRECT_BOOK_ENTRY';
           IF g_debug THEN
              pay_in_utils.trace('**************************************************','********************');
              pay_in_utils.trace('p_message_name',p_message_name);
              pay_in_utils.trace('**************************************************','********************');
           END IF;
           pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
           RETURN;
       END IF;

        IF (p_org_information12 = 'Y')
        THEN
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
          IF (p_org_information5 IS NOT NULL) THEN
           -- For transfer through book entry, do not enter Challan bank
             p_message_name:='PER_IN_BOOK_ENTRY';
             p_token_name(1) := 'FIELD';
             p_token_value(1):= hr_general.decode_lookup('IN_MESSAGE_TOKENS','CHALLAN_BANK');
             IF g_debug THEN
                pay_in_utils.trace('**************************************************','********************');
                pay_in_utils.trace('p_message_name',p_message_name);
                pay_in_utils.trace('**************************************************','********************');
             END IF;
             pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
             RETURN;
          ELSIF (p_org_information11 IS NOT NULL) THEN
           -- For transfer through book entry, do not enter  DD/Cheque number
             p_message_name:='PER_IN_BOOK_ENTRY';
             p_token_name(1) := 'FIELD';
             p_token_value(1):= hr_general.decode_lookup('IN_MESSAGE_TOKENS','DD_CHQ_NO');
             IF g_debug THEN
                pay_in_utils.trace('**************************************************','********************');
                pay_in_utils.trace('p_message_name',p_message_name);
                pay_in_utils.trace('**************************************************','********************');
             END IF;
             pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
             RETURN;
          END IF;
        ELSE
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,50);
           IF (p_org_information5 IS  NULL ) THEN
              -- For payment through challans, Challan bank and DD/Cheque number is mandatory
             p_message_name:='PER_IN_CHALLAN_DETAILS';
             p_token_name(1) := 'FIELD';
             p_token_value(1):= hr_general.decode_lookup('IN_MESSAGE_TOKENS','CHALLAN_BANK');
             IF g_debug THEN
                pay_in_utils.trace('**************************************************','********************');
                pay_in_utils.trace('p_message_name',p_message_name);
                pay_in_utils.trace('**************************************************','********************');
             END IF;
             pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
             RETURN;
           ELSIF  (p_org_information11 IS  NULL) THEN
              -- For payment through challans, Challan bank and DD/Cheque number is mandatory
             p_message_name:='PER_IN_CHALLAN_DETAILS';
             p_token_name(1) := 'FIELD';
             p_token_value(1):= hr_general.decode_lookup('IN_MESSAGE_TOKENS','DD_CHQ_NO');
             IF g_debug THEN
                pay_in_utils.trace('**************************************************','********************');
                pay_in_utils.trace('p_message_name',p_message_name);
                pay_in_utils.trace('**************************************************','********************');
             END IF;
             pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
             RETURN;
           END IF;

           IF(p_org_information3 IS  NOT NULL AND LENGTH(p_org_information3) > 5) THEN
             p_message_name:='PER_IN_CHALLAN_MAX_SIZE';
             IF g_debug THEN
                pay_in_utils.trace('**************************************************','********************');
                pay_in_utils.trace('p_message_name',p_message_name);
                pay_in_utils.trace('**************************************************','********************');
             END IF;
             pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
             RETURN;
           END IF;
        END IF;

        IF p_org_information_id IS NOT NULL THEN
           l_child_rec_flag := 'N';
           OPEN csr_challan_no_upd_chk(p_org_information_id, p_org_information3, p_organization_id, p_org_information2);
           FETCH csr_challan_no_upd_chk INTO l_child_rec_flag;
           CLOSE csr_challan_no_upd_chk;
           IF l_child_rec_flag = 'Y' THEN
              p_message_name:='PER_IN_REFERENCE_EE_RECORD';
              IF g_debug THEN
                 pay_in_utils.trace('**************************************************','********************');
                 pay_in_utils.trace('p_message_name',p_message_name);
                 pay_in_utils.trace('**************************************************','********************');
              END IF;
              pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
              RETURN;
           END IF;
        END IF;

  ELSIF p_org_info_type_code = 'PER_IN_FORM24Q_RECEIPT_DF' THEN
         pay_in_utils.set_location(g_debug,'in PER_IN_FORM24Q_RECEIPT_DF : '||l_procedure,10);
       IF p_org_information1 IS NULL
       THEN
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
          p_message_name  := 'HR_7207_API_MANDATORY_ARG';
          p_token_name(1) := 'ARGUMENT';
          p_token_name(2) := 'API_NAME';
          p_token_value(1):= 'p_org_information1';
          p_token_value(2):= l_procedure;
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
          RETURN;
       END IF;
       IF p_org_information2 IS NULL
       THEN
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
          p_message_name  := 'HR_7207_API_MANDATORY_ARG';
          p_token_name(1) := 'ARGUMENT';
          p_token_name(2) := 'API_NAME';
          p_token_value(1):= 'p_org_information2';
          p_token_value(2):= l_procedure;
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
          RETURN;
       END IF;
       IF p_org_information3 IS NULL
       THEN
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
          p_message_name  := 'HR_7207_API_MANDATORY_ARG';
          p_token_name(1) := 'ARGUMENT';
          p_token_name(2) := 'API_NAME';
          p_token_value(1):= 'p_org_information3';
          p_token_value(2):= l_procedure;
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
          RETURN;
       END IF;
       IF p_org_information4 IS NULL
       THEN
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
          p_message_name  := 'HR_7207_API_MANDATORY_ARG';
          p_token_name(1) := 'ARGUMENT';
          p_token_name(2) := 'API_NAME';
          p_token_value(1):= 'p_org_information4';
          p_token_value(2):= l_procedure;
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
          RETURN;
       END IF;
       IF p_org_information5 IS NULL
       THEN
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
          p_message_name  := 'HR_7207_API_MANDATORY_ARG';
          p_token_name(1) := 'ARGUMENT';
          p_token_name(2) := 'API_NAME';
          p_token_value(1):= 'p_org_information5';
          p_token_value(2):= l_procedure;
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
          RETURN;
       END IF;

       IF p_org_information6 IS NULL
       THEN
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
          p_message_name  := 'HR_7207_API_MANDATORY_ARG';
          p_token_name(1) := 'ARGUMENT';
          p_token_name(2) := 'API_NAME';
          p_token_value(1):= 'p_org_information6';
          p_token_value(2):= l_procedure;
          IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
          RETURN;
       END IF;

       IF p_org_information5 = 'A' AND
          p_org_information6 = 'O' THEN
          OPEN csr_orig_check(p_org_information1, p_org_information2, p_org_information_id);
          FETCH csr_orig_check INTO l_receipt_count;
          CLOSE csr_orig_check;

          pay_in_utils.set_location(g_debug,'l_receipt_count : '||l_receipt_count,100);


          IF l_receipt_count <> 0 THEN
             p_message_name  := 'PER_IN_24Q_ORIGINAL_ERROR';
             IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
                pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
             END IF;
             pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
             RETURN;
          END IF;
       END IF;

       IF p_org_information5 = 'A' AND
          p_org_information6 <> 'O' THEN

          OPEN csr_correction_check(p_org_information1, p_org_information2);
          FETCH csr_correction_check INTO l_receipt_count;
          CLOSE csr_correction_check;
          pay_in_utils.set_location(g_debug,'in l_receipt_count : '||l_receipt_count,100);

          IF l_receipt_count = 0 THEN
             p_message_name  := 'PER_IN_24Q_CORRECTION_ERROR';
             IF g_debug THEN
             pay_in_utils.trace('**************************************************','********************');
                pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
             END IF;
             pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
             RETURN;
          END IF;
       END IF;
 /*Validation on Base business Number and Business number null entry*/
  ELSIF p_org_info_type_code = 'PER_IN_PF_DF' THEN
     pay_in_utils.set_location(g_debug,'in PER_IN_PF_DF : '||l_procedure,10);
       IF  (p_org_information9 IS NULL AND p_org_information10 IS NOT NULL) OR
       (p_org_information9 IS NOT NULL AND p_org_information10 IS NULL)
        THEN
	IF p_org_information9 IS NULL THEN
         p_message_name   := 'PER_IN_PF_BUSINESS_NUMBER';
         p_token_name(1)  := 'FIELD1';
         p_token_value(1) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','BASE_BUSINESS_NUM');
         p_token_name(2)  := 'FIELD2';
         p_token_value(2) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','BUSINESS_NUMBER');
         ELSIF p_org_information10 IS NULL THEN
         p_message_name   := 'PER_IN_PF_BUSINESS_NUMBER';
         p_token_name(1)  := 'FIELD1';
         p_token_value(1) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','BUSINESS_NUMBER');
         p_token_name(2)  := 'FIELD2';
         p_token_value(2) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','BASE_BUSINESS_NUM');
	 END IF;
          IF g_debug THEN
             pay_in_utils.trace('*******VALIDATION OF BASE BUSINESS NUMBER AND BUSINESS NUMBER ******','********************');
             pay_in_utils.trace('**************************************************','********************');
             pay_in_utils.trace('p_message_name',p_message_name);
             pay_in_utils.trace('**************************************************','********************');
          END IF;
          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
          RETURN;
        END IF;
     /*Validation for state's deduction frequency mapping for LWF at BG level*/
     ELSIF p_org_info_type_code = 'PER_IN_LWF_FREQ_EMP_RULE' THEN
      pay_in_utils.set_location(g_debug,'in PER_IN_LWF_FREQ_EMP_RULE : '||l_procedure,10);
      check_lwf_contribution_freq (p_org_information1   =>p_org_information1
                                  ,p_org_information2   =>p_org_information2
                                  ,p_message_name       =>p_message_name
                                  ,p_token_name         =>p_token_name
                                  ,p_token_value        =>p_token_value);
      IF g_debug THEN
         pay_in_utils.trace('*******DEDUCTION FREQUENCY VALIDATION FOR LWF ******','********************');
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('p_message_name',p_message_name);
         pay_in_utils.trace('**************************************************','********************');
      END IF;
      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
      RETURN;
 END IF;
-------------------------check for uniqueness------------------------

IF  p_org_information_id IS NULL THEN


        check_unique_num_ins (p_org_info_type_code =>p_org_info_type_code
                     ,p_org_information1   =>p_org_information1
                     ,p_org_information2   =>p_org_information2
                     ,p_org_information3   =>p_org_information3
                     ,p_org_information4   =>p_org_information4
                     ,p_org_information5   =>p_org_information5
                     ,p_org_information6   =>p_org_information6
                     ,p_org_information11   =>p_org_information11
                     ,p_org_information12   =>p_org_information12
                     ,p_organization_id    =>p_organization_id
                     ,p_message_name       =>p_message_name
                     ,p_token_name         =>p_token_name
                     ,p_token_value        =>p_token_value
               );

IF  p_message_name <> 'SUCCESS' THEN
  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_message_name',p_message_name);
     pay_in_utils.trace('**************************************************','********************');
  END IF;
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
  RETURN ;
END IF ;

ELSE

   check_unique_num_upd(
                      p_org_information_id => p_org_information_id
                     ,p_org_info_type_code =>p_org_info_type_code
                     ,p_org_information1   =>p_org_information1
                     ,p_org_information2   =>p_org_information2
                     ,p_org_information3   =>p_org_information3
                     ,p_org_information4   =>p_org_information4
                     ,p_org_information5   =>p_org_information5
                     ,p_org_information6   =>p_org_information6
                     ,p_org_information11   =>p_org_information11
                     ,p_org_information12   =>p_org_information12
                     ,p_organization_id    =>p_organization_id
                     ,p_message_name       =>p_message_name
                     ,p_token_name         =>p_token_name
                     ,p_token_value        =>p_token_value
               );

  IF  p_message_name <> 'SUCCESS' THEN
     IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.trace('p_message_name',p_message_name);
        pay_in_utils.trace('**************************************************','********************');
     END IF;
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
     RETURN;
  END IF ;



END IF;
-----check of the dates,so that they do not overlap.This also performs PAN Validation and uniqueness checking of---

IF  p_org_information_id IS NULL THEN


check_rep_ins(     p_org_information1  => p_org_information1
                  ,p_org_information2  => p_org_information2
                  ,p_org_information3  => p_org_information3
		  ,p_org_information6  => p_org_information6
                  ,p_org_information5  => p_org_information5
		  ,p_org_information9  => p_org_information9
                  ,p_org_information10 => p_org_information10
                  ,p_org_information11 => p_org_information11
                  ,p_org_information12 => p_org_information12
		  ,p_org_information13 => p_org_information13
		  ,p_org_information14 => p_org_information14
		  ,p_org_information15 => p_org_information15
                  ,p_organization_id   => p_organization_id
                  ,p_org_info_type_code =>p_org_info_type_code
                  ,p_message_name      => p_message_name
                  ,p_token_name        => p_token_name
                  ,p_token_value       => p_token_value
                       );

   IF  p_message_name <> 'SUCCESS' THEN
      IF g_debug THEN
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('p_message_name',p_message_name);
         pay_in_utils.trace('**************************************************','********************');
      END IF;
      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
      RETURN;
   END IF ;


ELSE

check_rep_upd(     p_org_information1  => p_org_information1
                  ,p_org_information2  => p_org_information2
                  ,p_org_information3  => p_org_information3
		  ,p_org_information6  => p_org_information6
                  ,p_org_information5  => p_org_information5
		  ,p_org_information9  => p_org_information9
                  ,p_org_information10 => p_org_information10
                  ,p_org_information11 => p_org_information11
                  ,p_org_information12 => p_org_information12
		  ,p_org_information13 => p_org_information13
		  ,p_org_information14 => p_org_information14
		  ,p_org_information15 => p_org_information15
                  ,p_org_information_id =>p_org_information_id
                  ,p_org_info_type_code =>p_org_info_type_code
                  ,p_message_name      => p_message_name
                  ,p_token_name        => p_token_name
                  ,p_token_value       => p_token_value
                       );

   IF  p_message_name <> 'SUCCESS' THEN
      IF g_debug THEN
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('p_message_name',p_message_name);
         pay_in_utils.trace('**************************************************','********************');
      END IF;
      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
      RETURN;
   END IF ;

END IF;
----check for Monthly pf return Sec14B,Sec7Q and Misc. payment challan Accounts----
 chk_mon_pf_chn_acc (p_org_info_type_code  =>p_org_info_type_code
                     ,p_org_information3    =>p_org_information3
                     ,p_org_information4    =>p_org_information4
                     ,p_org_information5    =>p_org_information5
                     ,p_org_information6    =>p_org_information6
                     ,p_org_information7    =>p_org_information7
                     ,p_org_information8    =>p_org_information8
   		     ,p_org_information9     =>p_org_information9
		     ,p_org_information10     =>p_org_information10
		     ,p_org_information11     =>p_org_information11
		     ,p_org_information12     =>p_org_information12
		     ,p_org_information13     =>p_org_information13
		     ,p_message_name       => p_message_name
                     ,p_token_name         => p_token_name
                     ,p_token_value        => p_token_value
                      );
     IF  p_message_name <> 'SUCCESS' THEN
      IF g_debug THEN
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('p_message_name',p_message_name);
         pay_in_utils.trace('**************************************************','********************');
      END IF;
      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
      RETURN;
   END IF ;

--------------check for pf challan no--------------------

check_pf_challans (p_org_info_type_code   =>p_org_info_type_code
                          ,p_org_information3    =>p_org_information3
                          ,p_org_information4    =>p_org_information4
                          ,p_org_information5    =>p_org_information5
                          ,p_org_information6    =>p_org_information6
                          ,p_org_information7    =>p_org_information7
                          ,p_org_information8    =>p_org_information8
			  ,p_message_name       => p_message_name
                          ,p_token_name         => p_token_name
                          ,p_token_value        => p_token_value
                          );

IF  p_message_name <> 'SUCCESS' THEN
      IF g_debug THEN
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('p_message_name',p_message_name);
         pay_in_utils.trace('**************************************************','********************');
      END IF;
      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
      RETURN;
   END IF ;

  ----check for lwf challan Accounts----
 check_lwf_challan_accounts (p_org_info_type_code  =>p_org_info_type_code
                     ,p_org_information3    =>p_org_information3
                     ,p_org_information4    =>p_org_information4
                     ,p_org_information5    =>p_org_information5
                     ,p_org_information6    =>p_org_information6
   		     ,p_message_name       => p_message_name
                     ,p_token_name         => p_token_name
                     ,p_token_value        => p_token_value
                      );
     IF  p_message_name <> 'SUCCESS' THEN
      IF g_debug THEN
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('p_message_name',p_message_name);
         pay_in_utils.trace('**************************************************','********************');
      END IF;
      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
      RETURN;
   END IF ;
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,50);

  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 60);
       pay_in_utils.trace(l_message,l_procedure);


END check_org_info_internal;






--------------------------------------------------------------------------
-- Name           : check_org_info_create                               --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Main Procedure to be called from the Org Info Hook  --
-- Parameters     :                                                     --
--             IN : p_effective_date     IN  DATE                       --
--                : p_organization_id    IN  NUMBER                     --
--                : p_org_info_type_code IN VARCHAR2                    --
--                : p_org_information1   IN VARCHAR2                    --
--                : p_org_information2   IN VARCHAR2                    --
--                : p_org_information3   IN VARCHAR2                    --
--                : p_org_information4   IN VARCHAR2                    --
--                : p_org_information5   IN VARCHAR2                    --
--                : p_org_information6   IN VARCHAR2                    --
--                : p_org_information8   IN VARCHAR2                    --
--                : p_org_information9   IN VARCHAR2                    --
--                : p_org_information10  IN VARCHAR2                    --
--                : p_org_information11  IN VARCHAR2                    --
--                : p_org_information12  IN VARCHAR2                    --
--                : p_org_information13  IN VARCHAR2                    --
--                : p_org_information14  IN VARCHAR2                    --
--                : p_org_information15  IN VARCHAR2                    --
--                : p_org_information16  IN VARCHAR2                    --
--                : p_org_information17  IN VARCHAR2                    --
--                : p_org_information18  IN VARCHAR2                    --
--                : p_org_information19  IN VARCHAR2                    --
--                : p_org_information20  IN VARCHAR2                    --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                    --
--------------------------------------------------------------------------
-- 1.0   16-May-2005    sukukuma         Modified this procedure        --
--------------------------------------------------------------------------


PROCEDURE check_org_info_create
                (p_effective_date     IN  DATE,
                 p_organization_id    IN NUMBER,
                 p_org_info_type_code IN VARCHAR2,
                 p_org_information1   IN VARCHAR2,
                 p_org_information2   IN VARCHAR2,
                 p_org_information3   IN VARCHAR2,
                 p_org_information4   IN VARCHAR2,
                 p_org_information5   IN VARCHAR2,
                 p_org_information6   IN VARCHAR2,
                 p_org_information7   IN VARCHAR2,
                 p_org_information8   IN VARCHAR2,
                 p_org_information9   IN VARCHAR2,
                 p_org_information10  IN VARCHAR2,
                 p_org_information11  IN VARCHAR2,
                 p_org_information12  IN VARCHAR2,
                 p_org_information13  IN VARCHAR2,
                 p_org_information14  IN VARCHAR2,
                 p_org_information15  IN VARCHAR2,
                 p_org_information16  IN VARCHAR2,
                 p_org_information17  IN VARCHAR2,
                 p_org_information18  IN VARCHAR2,
                 p_org_information19  IN VARCHAR2,
                 p_org_information20  IN VARCHAR2)
IS

   l_procedure  VARCHAR2(100);
   l_message    VARCHAR2(300);

BEGIN

  l_procedure := g_package||'check_org_info_create';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_effective_date    ',p_effective_date    );
     pay_in_utils.trace('p_organization_id   ',p_organization_id   );
     pay_in_utils.trace('p_org_info_type_code',p_org_info_type_code);
     pay_in_utils.trace('p_org_information1  ',p_org_information1  );
     pay_in_utils.trace('p_org_information2  ',p_org_information2  );
     pay_in_utils.trace('p_org_information3  ',p_org_information3  );
     pay_in_utils.trace('p_org_information4  ',p_org_information4  );
     pay_in_utils.trace('p_org_information5  ',p_org_information5  );
     pay_in_utils.trace('p_org_information6  ',p_org_information6  );
     pay_in_utils.trace('p_org_information7  ',p_org_information7  );
     pay_in_utils.trace('p_org_information8  ',p_org_information8  );
     pay_in_utils.trace('p_org_information9  ',p_org_information9  );
     pay_in_utils.trace('p_org_information10 ',p_org_information10 );
     pay_in_utils.trace('p_org_information11 ',p_org_information11 );
     pay_in_utils.trace('p_org_information12 ',p_org_information12 );
     pay_in_utils.trace('p_org_information13 ',p_org_information13 );
     pay_in_utils.trace('p_org_information14 ',p_org_information14 );
     pay_in_utils.trace('p_org_information15 ',p_org_information15 );
     pay_in_utils.trace('p_org_information16 ',p_org_information16 );
     pay_in_utils.trace('p_org_information17 ',p_org_information17 );
     pay_in_utils.trace('p_org_information18 ',p_org_information18 );
     pay_in_utils.trace('p_org_information19 ',p_org_information19 );
     pay_in_utils.trace('p_org_information20 ',p_org_information20 );
     pay_in_utils.trace('**************************************************','********************');
  END IF;

  p_message_name := 'SUCCESS';
  pay_in_utils.null_message(p_token_name, p_token_value);

  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  check_org_info_internal
                (p_effective_date     => p_effective_date
                ,p_org_information_id => NULL
                ,p_organization_id    => p_organization_id
                ,p_org_info_type_code => p_org_info_type_code
                ,p_org_information1   => p_org_information1
                ,p_org_information2   => p_org_information2
                ,p_org_information3   => p_org_information3
                ,p_org_information4   => p_org_information4
                ,p_org_information5   => p_org_information5
                ,p_org_information6   => p_org_information6
                ,p_org_information7   => p_org_information7
                ,p_org_information8   => p_org_information8
                ,p_org_information9   => p_org_information9
                ,p_org_information10  => p_org_information10
                ,p_org_information11  => p_org_information11
                ,p_org_information12  => p_org_information12
                ,p_org_information13  => p_org_information13
                ,p_org_information14  => p_org_information14
                ,p_org_information15  => p_org_information15
                ,p_org_information16  => p_org_information16
                ,p_org_information17  => p_org_information17
                ,p_org_information18  => p_org_information18
                ,p_org_information19  => p_org_information19
                ,p_org_information20  => p_org_information20
                ,p_calling_procedure  => l_procedure
                ,p_message_name       => p_message_name
                ,p_token_name         => p_token_name
                ,p_token_value        => p_token_value);

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
  IF p_message_name <> 'HR_7207_API_MANDATORY_ARG' THEN
      pay_in_utils.raise_message(800, p_message_name, p_token_name, p_token_value);
  ELSE
      pay_in_utils.raise_message(801, p_message_name, p_token_name, p_token_value);
  END IF;
/*
  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
       pay_in_utils.trace(l_message,l_procedure);
*/
END check_org_info_create;




--------------------------------------------------------------------------
-- Name           : check_org_info_update                               --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Main Procedure to be called from the Org Info Hook  --
-- Parameters     :                                                     --
--             IN : p_effective_date     IN  DATE                       --
--                : p_org_information_id IN  NUMBER                     --
--                : p_org_info_type_code IN VARCHAR2                    --
--                : p_org_information1   IN VARCHAR2                    --
--                : p_org_information2   IN VARCHAR2                    --
--                : p_org_information3   IN VARCHAR2                    --
--                : p_org_information4   IN VARCHAR2                    --
--                : p_org_information5   IN VARCHAR2                    --
--                : p_org_information6   IN VARCHAR2                    --
--                : p_org_information8   IN VARCHAR2                    --
--                : p_org_information9   IN VARCHAR2                    --
--                : p_org_information10  IN VARCHAR2                    --
--                : p_org_information11  IN VARCHAR2                    --
--                : p_org_information12  IN VARCHAR2                    --
--                : p_org_information13  IN VARCHAR2                    --
--                : p_org_information14  IN VARCHAR2                    --
--                : p_org_information15  IN VARCHAR2                    --
--                : p_org_information16  IN VARCHAR2                    --
--                : p_org_information17  IN VARCHAR2                    --
--                : p_org_information18  IN VARCHAR2                    --
--                : p_org_information19  IN VARCHAR2                    --
--                : p_org_information20  IN VARCHAR2                    --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid           Description                    --
--------------------------------------------------------------------------
-- 1.0   16-May-2005    sukukuma         Modified this procedure        --
--------------------------------------------------------------------------

PROCEDURE check_org_info_update
                (p_effective_date     IN  DATE,
                 p_org_information_id IN  NUMBER,
                 p_org_info_type_code IN VARCHAR2,
                 p_org_information1   IN VARCHAR2,
                 p_org_information2   IN VARCHAR2,
                 p_org_information3   IN VARCHAR2,
                 p_org_information4   IN VARCHAR2,
                 p_org_information5   IN VARCHAR2,
                 p_org_information6   IN VARCHAR2,
                 p_org_information7   IN VARCHAR2,
                 p_org_information8   IN VARCHAR2,
                 p_org_information9   IN VARCHAR2,
                 p_org_information10  IN VARCHAR2,
                 p_org_information11  IN VARCHAR2,
                 p_org_information12  IN VARCHAR2,
                 p_org_information13  IN VARCHAR2,
                 p_org_information14  IN VARCHAR2,
                 p_org_information15  IN VARCHAR2,
                 p_org_information16  IN VARCHAR2,
                 p_org_information17  IN VARCHAR2,
                 p_org_information18  IN VARCHAR2,
                 p_org_information19  IN VARCHAR2,
                 p_org_information20  IN VARCHAR2)
IS

   CURSOR c_org_id IS
      SELECT organization_id
            ,org_information1
            ,org_information2
            ,org_information3
            ,org_information4
            ,org_information5
            ,org_information6
            ,org_information7
            ,org_information8
            ,org_information9
            ,org_information10
            ,org_information11
            ,org_information12
            ,org_information13
            ,org_information14
            ,org_information15
            ,org_information16
            ,org_information17
            ,org_information18
            ,org_information19
            ,org_information20
      FROM   hr_organization_information
      WHERE  org_information_id = p_org_information_id;

   l_organization_id     hr_organization_information.organization_id%TYPE;
   l_org_information1    hr_organization_information.org_information1%TYPE;
   l_org_information2    hr_organization_information.org_information2%TYPE;
   l_org_information3    hr_organization_information.org_information3%TYPE;
   l_org_information4    hr_organization_information.org_information4%TYPE;
   l_org_information5    hr_organization_information.org_information5%TYPE;
   l_org_information6    hr_organization_information.org_information6%TYPE;
   l_org_information7    hr_organization_information.org_information7%TYPE;
   l_org_information8    hr_organization_information.org_information8%TYPE;
   l_org_information9    hr_organization_information.org_information9%TYPE;
   l_org_information10   hr_organization_information.org_information10%TYPE;
   l_org_information11   hr_organization_information.org_information11%TYPE;
   l_org_information12   hr_organization_information.org_information12%TYPE;
   l_org_information13   hr_organization_information.org_information13%TYPE;
   l_org_information14   hr_organization_information.org_information14%TYPE;
   l_org_information15   hr_organization_information.org_information15%TYPE;
   l_org_information16   hr_organization_information.org_information16%TYPE;
   l_org_information17   hr_organization_information.org_information17%TYPE;
   l_org_information18   hr_organization_information.org_information18%TYPE;
   l_org_information19   hr_organization_information.org_information19%TYPE;
   l_org_information20   hr_organization_information.org_information20%TYPE;

   l_procedure  VARCHAR2(100);
   l_message    VARCHAR2(300);

BEGIN

  l_procedure := g_package||'check_org_info_update';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_effective_date    ',p_effective_date    );
     pay_in_utils.trace('p_org_information_id',p_org_information_id);
     pay_in_utils.trace('p_org_info_type_code',p_org_info_type_code);
     pay_in_utils.trace('p_org_information1  ',p_org_information1  );
     pay_in_utils.trace('p_org_information2  ',p_org_information2  );
     pay_in_utils.trace('p_org_information3  ',p_org_information3  );
     pay_in_utils.trace('p_org_information4  ',p_org_information4  );
     pay_in_utils.trace('p_org_information5  ',p_org_information5  );
     pay_in_utils.trace('p_org_information6  ',p_org_information6  );
     pay_in_utils.trace('p_org_information7  ',p_org_information7  );
     pay_in_utils.trace('p_org_information8  ',p_org_information8  );
     pay_in_utils.trace('p_org_information9  ',p_org_information9  );
     pay_in_utils.trace('p_org_information10 ',p_org_information10 );
     pay_in_utils.trace('p_org_information11 ',p_org_information11 );
     pay_in_utils.trace('p_org_information12 ',p_org_information12 );
     pay_in_utils.trace('p_org_information13 ',p_org_information13 );
     pay_in_utils.trace('p_org_information14 ',p_org_information14 );
     pay_in_utils.trace('p_org_information15 ',p_org_information15 );
     pay_in_utils.trace('p_org_information16 ',p_org_information16 );
     pay_in_utils.trace('p_org_information17 ',p_org_information17 );
     pay_in_utils.trace('p_org_information18 ',p_org_information18 );
     pay_in_utils.trace('p_org_information19 ',p_org_information19 );
     pay_in_utils.trace('p_org_information20 ',p_org_information20 );
     pay_in_utils.trace('**************************************************','********************');
  END IF;

  p_message_name := 'SUCCESS';
  pay_in_utils.null_message(p_token_name, p_token_value);

  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  OPEN c_org_id;
  FETCH c_org_id
  INTO l_organization_id
      ,l_org_information1
      ,l_org_information2
      ,l_org_information3
      ,l_org_information4
      ,l_org_information5
      ,l_org_information6
      ,l_org_information7
      ,l_org_information8
      ,l_org_information9
      ,l_org_information10
      ,l_org_information11
      ,l_org_information12
      ,l_org_information13
      ,l_org_information14
      ,l_org_information15
      ,l_org_information16
      ,l_org_information17
      ,l_org_information18
      ,l_org_information19
      ,l_org_information20 ;
  CLOSE c_org_id;

  pay_in_utils.set_location(g_debug,l_procedure,20);

   IF NVL (p_org_information1,'X') <> hr_api.g_varchar2 THEN
   l_org_information1 := p_org_information1;
   END IF;

   IF p_org_information2 <> hr_api.g_varchar2 THEN
       l_org_information2 := p_org_information2;
   END IF;

   IF p_org_information3 <> hr_api.g_varchar2 THEN
       l_org_information3 := p_org_information3;
   END IF;

   IF p_org_information4 <> hr_api.g_varchar2 THEN
       l_org_information4 := p_org_information4;
   END IF;

   IF NVL(p_org_information5,'X') <> hr_api.g_varchar2 THEN
       l_org_information5 := p_org_information5;
   END IF;

   IF p_org_information6 <> hr_api.g_varchar2 THEN
       l_org_information6 := p_org_information6;
   END IF;

   IF p_org_information7 <> hr_api.g_varchar2 THEN
       l_org_information7 := p_org_information7;
   END IF;

   IF p_org_information8 <> hr_api.g_varchar2 THEN
       l_org_information8 := p_org_information8;
   END IF;

   IF nvl(p_org_information9,'X') <> hr_api.g_varchar2 THEN
      l_org_information9 := p_org_information9;
   END IF;
   IF nvl(p_org_information10,'X') <> hr_api.g_varchar2 THEN
       l_org_information10 := p_org_information10;
   END IF;

   IF NVL(p_org_information11,'X') <> hr_api.g_varchar2 THEN
       l_org_information11 := p_org_information11;
   END IF;

   IF NVL(p_org_information12,'X') <> hr_api.g_varchar2 THEN
       l_org_information12 := p_org_information12;
   END IF;

   IF NVL(p_org_information13,'X') <> hr_api.g_varchar2 THEN
       l_org_information13 := p_org_information13;
   END IF;

   IF NVL (p_org_information14,'X') <> hr_api.g_varchar2 THEN
       l_org_information14 := p_org_information14;
   END IF;

   IF NVL (p_org_information15,'X') <> hr_api.g_varchar2 THEN
       l_org_information15 := p_org_information15;
   END IF;

   IF p_org_information16 <> hr_api.g_varchar2 THEN
       l_org_information16 := p_org_information16;
   END IF;

   IF p_org_information17 <> hr_api.g_varchar2 THEN
       l_org_information17 := p_org_information17;
   END IF;

   IF p_org_information18 <> hr_api.g_varchar2 THEN
       l_org_information18 := p_org_information18;
   END IF;

   IF p_org_information19 <> hr_api.g_varchar2 THEN
       l_org_information19 := p_org_information19;
   END IF;

   IF p_org_information20 <> hr_api.g_varchar2 THEN
       l_org_information20 := p_org_information20;
   END IF;

  IF (p_org_info_type_code = 'PER_IN_PROF_TAX_DF') THEN
       l_org_information3 := p_org_information3;
  END IF;

  check_org_info_internal
                (p_effective_date     => p_effective_date
                ,p_org_information_id => p_org_information_id
                ,p_organization_id    => l_organization_id
                ,p_org_info_type_code => p_org_info_type_code
                ,p_org_information1   => l_org_information1
                ,p_org_information2   => l_org_information2
                ,p_org_information3   => l_org_information3
                ,p_org_information4   => l_org_information4
                ,p_org_information5   => l_org_information5
                ,p_org_information6   => l_org_information6
                ,p_org_information7   => l_org_information7
                ,p_org_information8   => l_org_information8
                ,p_org_information9   => l_org_information9
                ,p_org_information10  => l_org_information10
                ,p_org_information11  => l_org_information11
                ,p_org_information12  => l_org_information12
                ,p_org_information13  => l_org_information13
                ,p_org_information14  => l_org_information14
                ,p_org_information15  => l_org_information15
                ,p_org_information16  => l_org_information16
                ,p_org_information17  => l_org_information17
                ,p_org_information18  => l_org_information18
                ,p_org_information19  => l_org_information19
                ,p_org_information20  => l_org_information20
                ,p_calling_procedure  => l_procedure
                ,p_message_name       => p_message_name
                ,p_token_name         => p_token_name
                ,p_token_value        => p_token_value);

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
  IF p_message_name = 'HR_7207_API_MANDATORY_ARG' THEN
      pay_in_utils.raise_message(801, p_message_name, p_token_name, p_token_value);
  ELSE
      pay_in_utils.raise_message(800, p_message_name, p_token_name, p_token_value);
  END IF;
/*
  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
       pay_in_utils.trace(l_message,l_procedure);
*/
END check_org_info_update;

END per_in_org_info_leg_hook;

/
