--------------------------------------------------------
--  DDL for Package Body OKL_CONTEXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CONTEXT" AS
  /*$Header: OKLRCTXB.pls 120.5 2006/08/06 10:37:13 asawanka noship $*/

  -- Procedure set_okc_org_context(p_org_id IN NUMBER DEFAULT NULL,p_organization_id IN NUMBER DEFAULT NULL)
  -- Procedure sets the okc context values for Multi Org. If the parameters are not passed procedure reads
  --           the calue from user profile options.

  PROCEDURE set_okc_org_context(p_org_id IN NUMBER DEFAULT NULL,
                                p_organization_id IN NUMBER DEFAULT NULL) IS
  l_organization_id Number := p_organization_id;
  l_org_id Number := p_org_id;  --dkagrawa added for MOAC
  BEGIN
    IF l_organization_id is null then
       l_organization_id := NVL(OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_ITEM_INV_ORG_ID),-99);
    Else
       Null;
    End If;

    --dkagrawa added for MOAC --start
    IF l_org_id IS NULL THEN
      l_org_id := mo_global.get_current_org_id;
    END IF;
    IF NOT (l_organization_id = nvl(okc_context.get_okc_organization_id,-99)
           AND l_org_id = nvl(okc_context.get_okc_org_id,-99) )
    THEN
        okc_context.set_okc_org_context(p_org_id => l_org_id,
                                    p_organization_id => l_organization_id);
    END IF;
    --MOAC end
  END set_okc_org_context;

  -- Procedure set_okc_org_context(p_chr_id IN NUMBER)
  -- Procedure sets the okc context values for Multi Org. These org values are obtained from the okc_k_headers_v
  --           for the chr_id passed in.

  PROCEDURE set_okc_org_context(p_chr_id IN NUMBER) IS
  BEGIN
       okc_context.set_okc_org_context(p_chr_id => p_chr_id);
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
    RETURN(mo_global.get_current_org_id);
  END get_okc_org_id;

END okl_context;

/
