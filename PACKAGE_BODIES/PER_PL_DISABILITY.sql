--------------------------------------------------------
--  DDL for Package Body PER_PL_DISABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PL_DISABILITY" AS
/* $Header: pepldisp.pkb 120.1 2006/09/13 12:53:41 mseshadr noship $ */
g_package VARCHAR2(30);
PROCEDURE check_pl_disability(p_reason  VARCHAR2,p_proc VARCHAR2) IS
--
BEGIN
--
       hr_api.mandatory_arg_error
             (p_api_name         => p_proc,
              p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','REASON'),
              p_argument_value   => p_reason
             );

END check_pl_disability;
--
PROCEDURE create_pl_disability(p_reason  VARCHAR2) IS
--
l_proc  VARCHAR2(72);
--
BEGIN
g_package := 'PER_PL_DISABILITY';
l_proc := g_package||'CREATE_PL_PERSON';
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.set_location('Leaving : '||l_proc,10);
   return;
END IF;
    --
     per_pl_disability.check_pl_disability(p_reason => p_reason,p_proc => l_proc);

    --
END create_pl_disability;
--
PROCEDURE update_pl_disability(p_reason  VARCHAR2) IS
--
l_proc  VARCHAR2(72);
--
BEGIN
    --
g_package := 'PER_PL_DISABILITY';
l_proc := g_package||'UPDATE_PL_PERSON';
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.set_location('Leaving : '||l_proc,10);
   return;
END IF;
     per_pl_disability.check_pl_disability(p_reason => p_reason,p_proc => l_proc);
    --
END update_pl_disability;
--
END per_pl_disability;

/
