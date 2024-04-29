--------------------------------------------------------
--  DDL for Package Body OKC_CONTEXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CONTEXT" AS
  /*$Header: OKCPCTXB.pls 120.7.12010000.2 2010/02/10 08:41:17 spingali ship $*/
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

    g_okc_organization_id       NUMBER;
    g_okc_business_group_id     NUMBER;
    g_moac_access_mode          VARCHAR2(3);
    g_moac_current_org_id       NUMBER;

  -- Procedure set_okc_org_context(p_org_id IN NUMBER DEFAULT NULL,p_organization_id IN NUMBER DEFAULT NULL)
  -- Procedure sets the okc context values for Multi Org. If the parameters are not passed procedure reads
  --           the calue from user profile options.

  PROCEDURE set_okc_org_context(p_org_id IN NUMBER ,
                                p_organization_id IN NUMBER ) IS

  -- Bug Fix 5014701- Performance Re-Fix

    CURSOR c_bus_grp(p_id IN NUMBER) IS
    SELECT business_group_id
    FROM   HR_ALL_ORGANIZATION_UNITS OU,
           HR_ORGANIZATION_INFORMATION OI1,
           HR_ORGANIZATION_INFORMATION OI2
    WHERE  OU.ORGANIZATION_ID = p_id
      AND  OI1.ORG_INFORMATION1 = 'OPERATING_UNIT'
      AND  OI2.ORG_INFORMATION_CONTEXT = 'Operating Unit Information'
      AND  OI1.ORGANIZATION_ID = OU.ORGANIZATION_ID
      AND OI2.ORGANIZATION_ID = OU.ORGANIZATION_ID;

  /**
    CURSOR c_bus_grp(p_id IN NUMBER) IS
    SELECT business_group_id
    FROM   okx_organization_defs_v
    WHERE  id1= p_id
    AND    ORGANIZATION_TYPE = 'OPERATING_UNIT' AND INFORMATION_TYPE = 'Operating Unit Information';

  **/


    l_business_group_id         NUMBER;
    l_default_org_id            hr_operating_units.organization_id%TYPE;
    l_default_ou_name           hr_operating_units.name%TYPE;
    l_ou_count                  NUMBER;
    l_org_id                    hr_operating_units.organization_id%TYPE;


  BEGIN
  -- Sets the org_id to a context namespace attribute.
     IF p_org_id IS NULL  OR p_org_id = -99 THEN
    --mmadhavi changes for MOAC project
    /*
      DBMS_SESSION.SET_CONTEXT('OKC_CONTEXT','ORG_ID',NVL(FND_PROFILE.VALUE('ORG_ID'),-99));
    ELSE
      DBMS_SESSION.SET_CONTEXT('OKC_CONTEXT','ORG_ID',p_org_id);
    END IF;
    */

	mo_utils.get_default_ou(l_default_org_id, l_default_ou_name, l_ou_count);
	If l_default_org_id is NOT NULL AND l_default_org_id <> -99 THEN
		mo_global.set_policy_context('S', l_default_org_id);
		l_org_id := l_default_org_id;
	Else
		mo_global.set_policy_context('M', NULL);
		l_org_id := NULL;

	End If;

     ELSE
	mo_global.set_policy_context('S', p_org_id);
	l_org_id := p_org_id;
     END IF;

  -- Sets the Inventory org_id to a context namespace attribute.
  -- If Organization_ID is null, then use the Org_ID set in the context
  -- tsaifee 07/24/2000.

    IF p_organization_id IS NULL  THEN
      -- Added By Jvorugan for Bug:4729941
      IF l_org_id IS NOT NULL THEN
      DBMS_SESSION.SET_CONTEXT('OKC_CONTEXT','ORGANIZATION_ID',
                 NVL(OE_PROFILE.VALUE('OE_ORGANIZATION_ID',l_org_id),-99));  --Mmadhavi replaced get_okc_org_id with l_org_id
      ELSE
               DBMS_SESSION.SET_CONTEXT('OKC_CONTEXT','ORGANIZATION_ID',-99);
      END IF;
      -- End of changes  for Bug:4729941
    ELSE
      DBMS_SESSION.SET_CONTEXT('OKC_CONTEXT','ORGANIZATION_ID',p_organization_id);
    END IF;

  -- Sets the Inventory business_group_id to a context namespace attribute.

    --OPEN c_bus_grp(sys_context('OKC_CONTEXT','ORG_ID'));
    OPEN c_bus_grp(l_org_id);  --Mmadhavi replaced get_okc_org_id with l_org_id
    FETCH c_bus_grp INTO  l_business_group_id;
    CLOSE c_bus_grp;

    l_business_group_id := NVL(l_business_group_id,-99);

    DBMS_SESSION.SET_CONTEXT('OKC_CONTEXT','BUSINESS_GROUP_ID',l_business_group_id);

  END set_okc_org_context;

  -- Procedure set_okc_org_context(p_chr_id IN NUMBER)
  -- Procedure sets the okc context values for Multi Org. These org values are obtained from the okc_k_headers_v
  --           for the chr_id passed in.

  PROCEDURE set_okc_org_context(p_chr_id IN NUMBER) IS
    CURSOR c_chr IS
    SELECT authoring_org_id,
           inv_organization_id
    FROM   okc_k_headers_all_b --changed to _all for MOAC
    WHERE  id = p_chr_id;

  -- Bug Fix 5014701- Performance Fix

    CURSOR c_bus_grp(p_id IN NUMBER) IS
    SELECT business_group_id
    FROM   HR_ALL_ORGANIZATION_UNITS OU
    WHERE  OU.ORGANIZATION_ID = p_id;

  /**
    CURSOR c_bus_grp(p_id IN NUMBER) IS
    SELECT business_group_id
    FROM   okx_organization_defs_v
    WHERE  id1= p_id
    AND    ORGANIZATION_TYPE = 'OPERATING_UNIT' AND INFORMATION_TYPE = 'Operating Unit Information';

   **/

    l_business_group_id         NUMBER;
    l_org_id                    hr_operating_units.organization_id%TYPE;

  BEGIN
    DBMS_SESSION.SET_CONTEXT('OKC_CONTEXT','CHR_ID',p_chr_id); -- bug#2155926

    FOR l_c_chr IN c_chr
    LOOP
      --DBMS_SESSION.SET_CONTEXT('OKC_CONTEXT','ORG_ID',l_c_chr.authoring_org_id);
      --mmadhavi for MOAC project
      mo_global.set_policy_context('S', l_c_chr.authoring_org_id);
      DBMS_SESSION.SET_CONTEXT('OKC_CONTEXT','ORGANIZATION_ID',l_c_chr.inv_organization_id);
      l_org_id := l_c_chr.authoring_org_id ;
    END LOOP;

  -- Sets the Inventory business_group_id to a context namespace attribute.

    OPEN c_bus_grp(l_org_id);  --Mmadhavi replaced get_okc_org_id with l_org_id
    FETCH c_bus_grp INTO  l_business_group_id;
    CLOSE c_bus_grp;

    l_business_group_id := NVL(l_business_group_id,-99);

    DBMS_SESSION.SET_CONTEXT('OKC_CONTEXT','BUSINESS_GROUP_ID',l_business_group_id);
  END set_okc_org_context;

  -- Function get_okc_organization_id RETURN NUMBER
  -- Returns the Inventory organization id.

  FUNCTION  get_okc_organization_id RETURN NUMBER IS
  BEGIN
    RETURN(sys_context('OKC_CONTEXT','ORGANIZATION_ID'));
  END get_okc_organization_id;

  -- Function get_okc_org_id RETURN NUMBER
  -- Returns the org_id.

  FUNCTION  get_okc_org_id RETURN NUMBER IS
  BEGIN
    --RETURN(sys_context('OKC_CONTEXT','ORG_ID'));
    --mmadhavi for MOAC
    RETURN nvl(mo_global.get_current_org_id,-99);
  END get_okc_org_id;


--new procedure added to save the current OKC and MOAC contexts
--the following contexts are saved
--  OKC_CONTEXT :   ORGANIZATION_ID
--  OKC_CONTEXT :   BUSINESS_GROUP_ID
--  MOAC (via MO_GLOBAL.set_policy_context)
--      MO_GLOBAL.g_access_mode     (MULTI_ORG :    ACCESS_MODE)
--      MO_GLOBAL.g_current_org_id  (MULTI_ORG2 :    CURRENT_ORG_ID)
PROCEDURE save_current_contexts
IS
BEGIN
    g_moac_access_mode := MO_GLOBAL.get_access_mode;
    g_moac_current_org_id := MO_GLOBAL.get_current_org_id;
    g_okc_organization_id := sys_context('OKC_CONTEXT', 'ORGANIZATION_ID');
    g_okc_business_group_id := sys_context('OKC_CONTEXT','BUSINESS_GROUP_ID');
END save_current_contexts;



--new procedure added to restore the OKC and MOAC contexts saved by
--call to save_current_contexts
/*PROCEDURE restore_contexts
IS
BEGIN
    MO_GLOBAL.set_policy_context(g_moac_access_mode, g_moac_current_org_id);
    DBMS_SESSION.SET_CONTEXT('OKC_CONTEXT','ORGANIZATION_ID',g_okc_organization_id);
    DBMS_SESSION.SET_CONTEXT('OKC_CONTEXT','ORGANIZATION_ID',g_okc_business_group_id);
END restore_contexts;*/

---modified for bug8936332

 PROCEDURE restore_contexts IS
 BEGIN
 MO_GLOBAL.set_policy_context(g_moac_access_mode, g_moac_current_org_id);
 DBMS_SESSION.SET_CONTEXT('OKC_CONTEXT','ORGANIZATION_ID',g_okc_organization_id);
 DBMS_SESSION.SET_CONTEXT('OKC_CONTEXT','BUSINESS_GROUP_ID',g_okc_business_group_id);
 END restore_contexts;

---modified for bug8936332

END okc_context;

/
