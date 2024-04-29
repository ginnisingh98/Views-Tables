--------------------------------------------------------
--  DDL for Package Body PQP_WEBADI_INTEGRATION_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_WEBADI_INTEGRATION_UTILS" AS
/* $Header: pqwadiut.pkb 120.1 2006/02/21 06:39:05 bshukla noship $ */

--
-- ------------------------------------------------------------------------
-- | -----------------< register_integrator_to_form >---------------------|
-- ------------------------------------------------------------------------
PROCEDURE webadi_meta_data_info(p_application_id        IN  NUMBER
                               ,p_caller_identifier     IN  VARCHAR2
                               ,p_integrator_code       OUT NOCOPY VARCHAR2
                               ,p_layout_code           OUT NOCOPY VARCHAR2
                               ,p_supported_spreasheet  OUT NOCOPY VARCHAR2
                               ) IS
CURSOR integrator_layout_codes IS
SELECT pltl.prompt_left   integrator_code,
       pltl.prompt_above  layout_code
FROM   bne_param_lists_b  plb,
       bne_param_lists_tl pltl
WHERE  plb.param_list_code = p_caller_identifier
AND    plb.param_list_code = pltl.param_list_code
AND    decode(pltl.user_tip, NULL, 'Y', decode(substr(pltl.user_tip,1,1), '+',
       decode(sign(instr(pltl.user_tip, HR_API.GET_LEGISLATION_CONTEXT)), 1, 'Y', 'N'), '-', decode(sign(instr(pltl.user_tip,
       HR_API.GET_LEGISLATION_CONTEXT)), 1, 'N', 'Y'), 'Y' ) ) = 'Y'
AND    pltl.application_id = p_application_id
AND    plb.application_id  = p_application_id
AND    pltl.language = userenv('lang');

CURSOR spreadsheet_version IS
   SELECT viewer_code,
          user_name
   FROM   bne_viewers_tl
   WHERE  viewer_code IN ('EXCEL97', 'EXCEL2000', 'EXCELXP')
   and language = userenv('lang');

    l_viewer_information VARCHAR2(2000):= NULL;
BEGIN
     FOR ilc IN integrator_layout_codes
     LOOP
         p_integrator_code := ilc.integrator_code;
         p_layout_code     := ilc.layout_code;
     END LOOP;

     FOR sv IN spreadsheet_version
     LOOP
       l_viewer_information := l_viewer_information ||
                               sv.viewer_code || '::' || sv.user_name || '##';
     END LOOP;
     p_supported_spreasheet := l_viewer_information;
END webadi_meta_data_info;
END pqp_webadi_integration_utils;

/
