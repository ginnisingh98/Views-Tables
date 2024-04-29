--------------------------------------------------------
--  DDL for Package Body OKL_CREDIT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CREDIT_PUB" AS
/* $Header: OKLPCRDB.pls 120.22 2006/09/22 09:01:29 abhsaxen noship $ */
----------------------------------------------------------------------------
-- Global Message Constants
----------------------------------------------------------------------------
-- see FND_NEW_MESSAGES for full message text
G_NOT_FOUND                  CONSTANT VARCHAR2(30) := 'OKC_NOT_FOUND';  -- message_name
G_NOT_FOUND_V1               CONSTANT VARCHAR2(30) := 'VALUE1';         -- token 1
G_NOT_FOUND_V2               CONSTANT VARCHAR2(30) := 'VALUE2';         -- token 2

G_NOT_UNIQUE                 CONSTANT VARCHAR2(30) := 'OKL_LLA_NOT_UNIQUE';
G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(30) := 'OKL_UNEXPECTED_ERROR';

G_SQLERRM_TOKEN              CONSTANT VARCHAR2(30) := 'OKL_SQLERRM';
G_SQLCODE_TOKEN              CONSTANT VARCHAR2(30) := 'OKL_SQLCODE';

G_NO_INIT_MSG                CONSTANT VARCHAR2(1)  := OKL_API.G_FALSE;
G_VIEW                       CONSTANT VARCHAR2(30) := 'OKL_TRX_AP_INVOICES_V';

G_FND_APP                    CONSTANT VARCHAR2(30) := OKL_API.G_FND_APP;
G_FORM_UNABLE_TO_RESERVE_REC CONSTANT VARCHAR2(30) := OKL_API.G_FORM_UNABLE_TO_RESERVE_REC;
G_FORM_RECORD_DELETED        CONSTANT VARCHAR2(30) := OKL_API.G_FORM_RECORD_DELETED;
G_FORM_RECORD_CHANGED        CONSTANT VARCHAR2(30) := OKL_API.G_FORM_RECORD_CHANGED;
G_RECORD_LOGICALLY_DELETED	 CONSTANT VARCHAR2(30) := OKL_API.G_RECORD_LOGICALLY_DELETED;

G_REQUIRED_VALUE             CONSTANT VARCHAR2(30) := 'OKL_REQUIRED_VALUE';
G_INVALID_VALUE              CONSTANT VARCHAR2(30) := OKL_API.G_INVALID_VALUE;
G_COL_NAME_TOKEN             CONSTANT VARCHAR2(30) := OKL_API.G_COL_NAME_TOKEN;
G_PARENT_TABLE_TOKEN         CONSTANT VARCHAR2(30) := OKL_API.G_PARENT_TABLE_TOKEN;
G_CHILD_TABLE_TOKEN          CONSTANT VARCHAR2(30) := OKL_API.G_CHILD_TABLE_TOKEN;
G_NO_PARENT_RECORD           CONSTANT VARCHAR2(30) :='OKL_NO_PARENT_RECORD';
G_NOT_SAME                   CONSTANT VARCHAR2(30) :='OKL_CANNOT_BE_SAME';

	G_API_TYPE	VARCHAR2(3) := 'PUB';
      G_RLE_CODE  VARCHAR2(10) := 'LESSEE';
      G_STS_CODE  VARCHAR2(10) := 'NEW';
      G_SCS_CODE  VARCHAR2(30) := 'CREDITLINE_CONTRACT';

      G_CREATE_MODE  VARCHAR2(30) := 'CREATE';
      G_UPDATE_MODE  VARCHAR2(30) := 'UPDATE';
      G_DELETE_MODE  VARCHAR2(30) := 'DELETE';

 G_CREDIT_CHKLST_TPL CONSTANT VARCHAR2(30) := 'LACCLH';
 G_CREDIT_CHKLST_TPL_RULE1 CONSTANT VARCHAR2(30) := 'LACCLT';
 G_CREDIT_CHKLST_TPL_RULE2 CONSTANT VARCHAR2(30) := 'LACCLD'; -- credit line checklist
 G_CREDIT_CHKLST_TPL_RULE3 CONSTANT VARCHAR2(30) := 'LACLFD'; /*funding checklist template for a credit line*/
 G_CREDIT_CHKLST_TPL_RULE4 CONSTANT VARCHAR2(30) := 'LACLFM'; /*funding checklist template header for a credit line*/
 G_RGP_TYPE CONSTANT VARCHAR2(30) := 'KRG';

/*
-- vthiruva, 08/31/2004
-- Added Constants to enable Business Event
*/
G_WF_EVT_CR_LN_CREATED CONSTANT VARCHAR2(50) := 'oracle.apps.okl.la.credit_line.created';
G_WF_EVT_CR_LN_UPDATED CONSTANT VARCHAR2(50) := 'oracle.apps.okl.la.credit_line.updated';
G_WF_EVT_CR_LN_ACTIVATED CONSTANT VARCHAR2(50) := 'oracle.apps.okl.la.credit_line.activated';
G_WF_ITM_CR_LINE_ID CONSTANT VARCHAR2(30) := 'CREDIT_LINE_ID';

----------------------------------------------------------------------------
-- Data Structures
----------------------------------------------------------------------------
  subtype rgpv_rec_type is okl_okc_migration_pvt.rgpv_rec_type;
  subtype rgpv_tbl_type is okl_okc_migration_pvt.rgpv_tbl_type;
  subtype rulv_rec_type is okl_rule_pub.rulv_rec_type;
  subtype rulv_tbl_type is okl_rule_pub.rulv_tbl_type;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : NULLIF
-- Description     : local functions to replace 9i new functions
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------

FUNCTION NULLIF(p1 NUMBER, p2 NUMBER) RETURN NUMBER
is
  l_temp NUMBER;

begin

  IF p1 = p2 THEN
    l_temp := NULL;
  ELSE
    l_temp := p1;
  END IF;

  RETURN l_temp;

exception
  when others then
    return NULL;

END NULLIF;

FUNCTION NULLIF(p1 VARCHAR2, p2 VARCHAR2) RETURN VARCHAR2
is
  l_temp VARCHAR2(32767);

begin

  IF p1 = p2 THEN
    l_temp := NULL;
  ELSE
    l_temp := p1;
  END IF;

  RETURN l_temp;

exception
  when others then
    return NULL;

END NULLIF;

FUNCTION NULLIF(p1 DATE, p2 DATE) RETURN DATE
is
  l_temp DATE;

begin

  IF p1 = p2 THEN
    l_temp := NULL;
  ELSE
    l_temp := p1;
  END IF;

  RETURN l_temp;

exception
  when others then
    return NULL;

END NULLIF;

/*
-- vthiruva, 08/31/2004
-- START, Added PROCEDURE to enable Business Event
*/
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : raise_business_event
-- Description     : local_procedure, raises business event by making a call to
--                   okl_wf_pvt.raise_event
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
PROCEDURE raise_business_event(
                p_api_version       IN NUMBER,
                p_init_msg_list     IN VARCHAR2,
                x_return_status     OUT NOCOPY VARCHAR2,
                x_msg_count         OUT NOCOPY NUMBER,
                x_msg_data          OUT NOCOPY VARCHAR2,
                p_id                IN NUMBER,
                p_event_name        IN VARCHAR2) IS

l_parameter_list        wf_parameter_list_t;
BEGIN
    --create the parameter list to pass to raise_event
    wf_event.AddParameterToList(G_WF_ITM_CR_LINE_ID,p_id,l_parameter_list);

    OKL_WF_PVT.raise_event(p_api_version    => p_api_version,
                           p_init_msg_list  => p_init_msg_list,
			   x_return_status  => x_return_status,
			   x_msg_count      => x_msg_count,
			   x_msg_data       => x_msg_data,
			   p_event_name     => p_event_name,
			   p_parameters     => l_parameter_list);

    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
END raise_business_event;

/*
-- vthiruva, 08/31/2004
-- END, PROCEDURE to enable Business Event
*/


----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_credit_chklst_tpl
-- Description     : wrapper api for create credit checklist template FK associated
--                   with credit line contract ID
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_credit_chklst_tpl(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rgpv_rec                     IN  rgpv_rec_type
   ,p_rulv_rec                     IN  rulv_rec_type
   ,x_rgpv_rec                     OUT NOCOPY rgpv_rec_type
   ,x_rulv_rec                     OUT NOCOPY rulv_rec_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'create_credit_chklst_tpl';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_rgpv_rec        rgpv_rec_type := p_rgpv_rec;
  lp_rulv_rec        rulv_rec_type := p_rulv_rec;

  lp_rule2_rulv_rec    rulv_rec_type;
  lx_rule2_rulv_rec    rulv_rec_type;

  lp_rule3_rulv_rec    rulv_rec_type;
  lx_rule3_rulv_rec    rulv_rec_type;

  lp_rule4_rulv_rec    rulv_rec_type;
  lx_rule4_rulv_rec    rulv_rec_type;

  l_todo_item_code      okl_checklist_details.TODO_ITEM_CODE%type;
--start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
  l_function_id         okl_checklist_details_uv.function_id%type;
  l_inst_checklist_type okl_checklists.checklist_type%type;
  l_dummy number;
  l_is_grp_found boolean;


cursor c_is_grp(p_ckl_id number) is
  select 1
  from   okl_checklists clist
  where  clist.checklist_purpose_code = 'CHECKLIST_TEMPLATE_GROUP'
  and    clist.id = p_ckl_id
  ;

-- group checklist template items
cursor c_grp_chk (p_ckl_id number) is
--start modified abhsaxen for performance SQLID 20562590
select cld.todo_item_code,
         cld.function_id,
         clh.checklist_type
from OKL_CHECKLIST_DTLS_ALL CLD, OKL_CHECKLISTS CLH
where cld.ckl_id = clh.id
 and exists (select 1
              from  okl_checklists chlidren
              where chlidren.id = cld.ckl_id
              and   chlidren.ckl_id = p_ckl_id)
--end modified abhsaxen for performance SQLID 20562590
;

-- checklist template
cursor c_chk_tpl (p_ckl_id number) is
  select ckd.TODO_ITEM_CODE,
--start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
         ckd.FUNCTION_ID,
         ckd.CHECKLIST_TYPE
--from okl_checklist_details ckd
from okl_checklist_details_uv ckd
--end: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
where ckd.ckl_id = p_ckl_id;

begin
  -- Set API savepoint
  SAVEPOINT create_credit_chklst_tpl;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/
/*
-------------------------------------------------------------
1. create rule group
2. create rule1 : template
3. create rule2 : get the source of the checklist template lists
4. create rules based on #3. cursor
5. create rule3 : get the source of the checklist template lists
6. create rules based on #5. cursor
-------------------------------------------------------------
*/

-------------------------------------------------------------
--1. create rule group when user choose either credit line or funding checklist template
-------------------------------------------------------------
 IF ((lp_rulv_rec.RULE_INFORMATION1 is not null AND
       lp_rulv_rec.RULE_INFORMATION1 <> OKL_API.G_MISS_CHAR)
       OR
      (lp_rulv_rec.RULE_INFORMATION2 is not null AND
       lp_rulv_rec.RULE_INFORMATION2 <> OKL_API.G_MISS_CHAR)) THEN

    -- DNZ_CHR_ID is set by calling program
    -- CHR_ID is set by calling program
    lp_rgpv_rec.RGD_CODE := G_CREDIT_CHKLST_TPL;
    lp_rgpv_rec.RGP_TYPE := G_RGP_TYPE;

    okl_rule_pub.create_rule_group(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_rgpv_rec       => lp_rgpv_rec,
      x_rgpv_rec       => x_rgpv_rec);

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;
-------------------------------------------------------------
--2. create rule1 : template
-------------------------------------------------------------

    -- RULE_INFORMATION1, RULE_INFORMATION2, DNZ_CHR_ID are set by calling program
    lp_rulv_rec.RGP_ID := x_rgpv_rec.ID;
    lp_rulv_rec.RULE_INFORMATION_CATEGORY := G_CREDIT_CHKLST_TPL_RULE1;
    lp_rulv_rec.STD_TEMPLATE_YN := 'N';
    lp_rulv_rec.WARN_YN := 'N';

    okl_rule_pub.create_rule(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_rulv_rec       => lp_rulv_rec,
      x_rulv_rec       => x_rulv_rec);

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

 END IF;
-------------------------------------------------------------
-- credit line checklist
--
--3. create rule2 : get the source of the checklist template lists
--4. create rules based on #3. cursor
-------------------------------------------------------------
 IF (lp_rulv_rec.RULE_INFORMATION1 is not null AND
     lp_rulv_rec.RULE_INFORMATION1 <> OKL_API.G_MISS_CHAR) THEN

--start: 06-May-2005  cklee okl.h Lease App IA Authoring
  OPEN c_is_grp(TO_NUMBER(lp_rulv_rec.RULE_INFORMATION1));
  FETCH c_is_grp INTO l_dummy;
  l_is_grp_found := c_is_grp%FOUND;
  CLOSE c_is_grp;
--end: 06-May-2005  cklee okl.h Lease App IA Authoring

  -- is not a group template
  IF l_is_grp_found = false THEN
--end: 06-May-2005  cklee okl.h Lease App IA Authoring

    open c_chk_tpl(to_number(lp_rulv_rec.RULE_INFORMATION1));
    LOOP

      fetch c_chk_tpl into l_todo_item_code,
--start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
                           l_function_id,
                           l_inst_checklist_type;
--end: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
      EXIT WHEN c_chk_tpl%NOTFOUND;

      lp_rule2_rulv_rec.RGP_ID := x_rgpv_rec.ID;
      lp_rule2_rulv_rec.DNZ_CHR_ID := lp_rgpv_rec.DNZ_CHR_ID;
      lp_rule2_rulv_rec.RULE_INFORMATION_CATEGORY := G_CREDIT_CHKLST_TPL_RULE2;
      lp_rule2_rulv_rec.STD_TEMPLATE_YN := 'N';
      lp_rule2_rulv_rec.WARN_YN := 'N';
      lp_rule2_rulv_rec.RULE_INFORMATION1 := l_todo_item_code;
      lp_rule2_rulv_rec.RULE_INFORMATION2 := 'N';
      lp_rule2_rulv_rec.RULE_INFORMATION3 := 'N';
      lp_rule2_rulv_rec.RULE_INFORMATION5 := G_STS_CODE; -- set default status
--start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
      lp_rule2_rulv_rec.RULE_INFORMATION7 := 'UNDETERMINED'; -- set default status
      lp_rule2_rulv_rec.RULE_INFORMATION9 := l_function_id;
      lp_rule2_rulv_rec.RULE_INFORMATION10 := l_inst_checklist_type;
--end: 06-May-2005  cklee okl.h Lease App IA Authoring                            |

      okl_rule_pub.create_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_rule2_rulv_rec,
        x_rulv_rec       => lx_rule2_rulv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      End If;

    END LOOP;
    CLOSE c_chk_tpl;

  -- is a group template
--  IF l_is_grp_found = false THEN
  ELSE

    open c_grp_chk(to_number(lp_rulv_rec.RULE_INFORMATION1));
    LOOP

      fetch c_grp_chk into l_todo_item_code,
--start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
                           l_function_id,
                           l_inst_checklist_type;
--end: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
      EXIT WHEN c_grp_chk%NOTFOUND;

      lp_rule2_rulv_rec.RGP_ID := x_rgpv_rec.ID;
      lp_rule2_rulv_rec.DNZ_CHR_ID := lp_rgpv_rec.DNZ_CHR_ID;
      lp_rule2_rulv_rec.RULE_INFORMATION_CATEGORY := G_CREDIT_CHKLST_TPL_RULE2;
      lp_rule2_rulv_rec.STD_TEMPLATE_YN := 'N';
      lp_rule2_rulv_rec.WARN_YN := 'N';
      lp_rule2_rulv_rec.RULE_INFORMATION1 := l_todo_item_code;
      lp_rule2_rulv_rec.RULE_INFORMATION2 := 'N';
      lp_rule2_rulv_rec.RULE_INFORMATION3 := 'N';
      lp_rule2_rulv_rec.RULE_INFORMATION5 := G_STS_CODE; -- set default status
--start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
      lp_rule2_rulv_rec.RULE_INFORMATION7 := 'UNDETERMINED'; -- set default status
      lp_rule2_rulv_rec.RULE_INFORMATION9 := l_function_id;
      lp_rule2_rulv_rec.RULE_INFORMATION10 := l_inst_checklist_type;
--end: 06-May-2005  cklee okl.h Lease App IA Authoring                            |

      okl_rule_pub.create_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_rule2_rulv_rec,
        x_rulv_rec       => lx_rule2_rulv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      End If;

    END LOOP;
    CLOSE c_grp_chk;

   END IF;


 END IF;

-------------------------------------------------------------
-- instance of funding checklist template at credit line level
--
--
-- create funding checklist template header
-------------------------------------------------------------
 IF (lp_rulv_rec.RULE_INFORMATION2 is not null AND
      lp_rulv_rec.RULE_INFORMATION2 <> OKL_API.G_MISS_CHAR) THEN

    lp_rule3_rulv_rec.RGP_ID := x_rgpv_rec.ID;
    lp_rule3_rulv_rec.DNZ_CHR_ID := lp_rgpv_rec.DNZ_CHR_ID;
    lp_rule3_rulv_rec.RULE_INFORMATION_CATEGORY := G_CREDIT_CHKLST_TPL_RULE4;
    lp_rule3_rulv_rec.STD_TEMPLATE_YN := 'N';
    lp_rule3_rulv_rec.WARN_YN := 'N';
--    lp_rule3_rulv_rec.RULE_INFORMATION1 := null; -- effective from
--    lp_rule3_rulv_rec.RULE_INFORMATION2 := null; -- effective to
    lp_rule3_rulv_rec.RULE_INFORMATION3 := G_STS_CODE;

    okl_rule_pub.create_rule(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_rulv_rec       => lp_rule3_rulv_rec,
      x_rulv_rec       => lx_rule3_rulv_rec);

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

-------------------------------------------------------------
--5. create rule3 : get the source of the checklist template lists
--6. create rules based on #5. cursor
--
-------------------------------------------------------------
--start: 06-May-2005  cklee okl.h Lease App IA Authoring
  OPEN c_is_grp(TO_NUMBER(lp_rulv_rec.RULE_INFORMATION2));
  FETCH c_is_grp INTO l_dummy;
  l_is_grp_found := c_is_grp%FOUND;
  CLOSE c_is_grp;
--end: 06-May-2005  cklee okl.h Lease App IA Authoring

  -- is not a group template
  IF l_is_grp_found = false THEN
--end: 06-May-2005  cklee okl.h Lease App IA Authoring

    open c_chk_tpl(to_number(lp_rulv_rec.RULE_INFORMATION2));
    LOOP

      fetch c_chk_tpl into l_todo_item_code,
--start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
                           l_function_id,
                           l_inst_checklist_type;
--end: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
      EXIT WHEN c_chk_tpl%NOTFOUND;


      lp_rule4_rulv_rec.RGP_ID := x_rgpv_rec.ID;

      lp_rule4_rulv_rec.OBJECT1_ID1 := lx_rule3_rulv_rec.ID; -- FK
      lp_rule4_rulv_rec.OBJECT1_ID2 := '#'; -- dummy one

      lp_rule4_rulv_rec.DNZ_CHR_ID := lp_rgpv_rec.DNZ_CHR_ID;
      lp_rule4_rulv_rec.RULE_INFORMATION_CATEGORY := G_CREDIT_CHKLST_TPL_RULE3;
      lp_rule4_rulv_rec.STD_TEMPLATE_YN := 'N';
      lp_rule4_rulv_rec.WARN_YN := 'N';
      lp_rule4_rulv_rec.RULE_INFORMATION1 := l_todo_item_code;
      lp_rule4_rulv_rec.RULE_INFORMATION2 := 'N';
--    lp_rule4_rulv_rec.RULE_INFORMATION3 := 'N'; -- not applicable
--start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
--      lp_rule2_rulv_rec.RULE_INFORMATION6 := l_function_id;
--      lp_rule2_rulv_rec.RULE_INFORMATION7 := l_inst_checklist_type;
-- START: typo 10/03/2005 cklee
      lp_rule4_rulv_rec.RULE_INFORMATION6 := l_function_id;
      lp_rule4_rulv_rec.RULE_INFORMATION7 := l_inst_checklist_type;
-- END: typo 10/03/2005 cklee
--end: 06-May-2005  cklee okl.h Lease App IA Authoring                            |

      okl_rule_pub.create_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_rule4_rulv_rec,
        x_rulv_rec       => lx_rule4_rulv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      End If;

    END LOOP;
    CLOSE c_chk_tpl;

  -- is not a group template
--  IF l_is_grp_found = false THEN
  ELSE

    open c_grp_chk(to_number(lp_rulv_rec.RULE_INFORMATION2));
    LOOP

      fetch c_grp_chk into l_todo_item_code,
--start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
                           l_function_id,
                           l_inst_checklist_type;
--end: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
      EXIT WHEN c_grp_chk%NOTFOUND;


      lp_rule4_rulv_rec.RGP_ID := x_rgpv_rec.ID;

      lp_rule4_rulv_rec.OBJECT1_ID1 := lx_rule3_rulv_rec.ID; -- FK
      lp_rule4_rulv_rec.OBJECT1_ID2 := '#'; -- dummy one

      lp_rule4_rulv_rec.DNZ_CHR_ID := lp_rgpv_rec.DNZ_CHR_ID;
      lp_rule4_rulv_rec.RULE_INFORMATION_CATEGORY := G_CREDIT_CHKLST_TPL_RULE3;
      lp_rule4_rulv_rec.STD_TEMPLATE_YN := 'N';
      lp_rule4_rulv_rec.WARN_YN := 'N';
      lp_rule4_rulv_rec.RULE_INFORMATION1 := l_todo_item_code;
      lp_rule4_rulv_rec.RULE_INFORMATION2 := 'N';
--    lp_rule4_rulv_rec.RULE_INFORMATION3 := 'N'; -- not applicable
--start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
--      lp_rule2_rulv_rec.RULE_INFORMATION6 := l_function_id;
--      lp_rule2_rulv_rec.RULE_INFORMATION7 := l_inst_checklist_type;
-- START: typo 10/03/2005 cklee
      lp_rule4_rulv_rec.RULE_INFORMATION6 := l_function_id;
      lp_rule4_rulv_rec.RULE_INFORMATION7 := l_inst_checklist_type;
-- END: typo 10/03/2005 cklee
--end: 06-May-2005  cklee okl.h Lease App IA Authoring                            |

      okl_rule_pub.create_rule(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_rule4_rulv_rec,
        x_rulv_rec       => lx_rule4_rulv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      End If;

    END LOOP;
    CLOSE c_grp_chk;

  END IF;

 END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

  EXCEPTION

    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);

end create_credit_chklst_tpl;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_credit_chklst_tpl
-- Description     : wrapper api for update credit checklist template FK associated
--                   with credit line contract ID.
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_credit_chklst_tpl(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rulv_rec                     IN  rulv_rec_type
   ,x_rulv_rec                     OUT NOCOPY rulv_rec_type
 )
is
  l_api_name          CONSTANT VARCHAR2(30) := 'update_credit_chklst_tpl';
  l_api_version       CONSTANT NUMBER       := 1.0;
  i                   NUMBER;
  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  lpcrt_rgpv_rec         rgpv_rec_type;
  lxcrt_rgpv_rec         rgpv_rec_type;
  lpcrt_rulv_rec         rulv_rec_type;
  lxcrt_rulv_rec         rulv_rec_type;

  lpcrt2_rulv_rec         rulv_rec_type;
  lxcrt2_rulv_rec         rulv_rec_type;

  lpcrt3_rulv_rec         rulv_rec_type;
  lxcrt3_rulv_rec         rulv_rec_type;

  lpcrt4_rulv_rec         rulv_rec_type;
  lxcrt4_rulv_rec         rulv_rec_type;

  lp_rulv_rec         rulv_rec_type := p_rulv_rec;
  lx_rulv_rec         rulv_rec_type := x_rulv_rec;

  l_rule_id           okc_rules_b.id%type;
  ldel_rulv_rec       rulv_rec_type;
  lcrt_rulv_rec       rulv_rec_type;

--  l_dummy             number;
  l_row_found         boolean := false;
  l_RULE_INFORMATION1 okc_rules_b.RULE_INFORMATION1%type;
  l_RULE_INFORMATION2 okc_rules_b.RULE_INFORMATION2%type;

  l_todo_item_code   okl_checklist_details.TODO_ITEM_CODE%type;
  l_fund_clist_hdr_id okc_rules_b.id%TYPE;
  l_fund_cl_hdr_notfound boolean := false;

--start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
  l_function_id         okl_checklist_details_uv.function_id%type;
  l_inst_checklist_type okl_checklists.checklist_type%type;
  l_dummy number;
  l_is_grp_found boolean;


cursor c_is_grp(p_ckl_id number) is
  select 1
  from   okl_checklists clist
  where  clist.checklist_purpose_code = 'CHECKLIST_TEMPLATE_GROUP'
  and    clist.id = p_ckl_id
  ;

-- group checklist template items
cursor c_grp_chk (p_ckl_id number) is
--start modified abhsaxen for performance SQLID 20562606
select cld.todo_item_code,
         cld.function_id,
         clh.checklist_type
from OKL_CHECKLIST_DTLS_ALL CLD, OKL_CHECKLISTS CLH
where cld.ckl_id = clh.id
 and exists (select 1
              from  okl_checklists chlidren
              where chlidren.id = cld.ckl_id
              and   chlidren.ckl_id = p_ckl_id)
--end modified abhsaxen for performance SQLID 20562606
;

---------------------------------------------------------
-- to do item lists from setup
---------------------------------------------------------
cursor c_chk_tpl (p_ckl_id okl_checklists.id%type) is
  select ckd.TODO_ITEM_CODE,
--start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
         ckd.FUNCTION_ID,
         ckd.CHECKLIST_TYPE
--from okl_checklist_details ckd
from okl_checklist_details_uv ckd
--end: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
where ckd.ckl_id = p_ckl_id
;

---------------------------------------------------------
-- to do item lists from instance of credit line
---------------------------------------------------------
cursor c_del (p_rgp_id         okc_rules_b.rgp_id%type,
              p_rule_category  okc_rules_b.RULE_INFORMATION_CATEGORY%type) is
  select rule.id
from okc_rules_b rule
where rule.RULE_INFORMATION_CATEGORY = p_rule_category
and   rule.RGP_ID = p_rgp_id
;

---------------------------------------------------------
-- existing FK for checklists
---------------------------------------------------------
cursor c_chk (p_rule_id okc_rules_b.id%type) is
  select rule.RULE_INFORMATION1,
         rule.RULE_INFORMATION2
from okc_rules_b rule
where rule.id = p_rule_id
;

---------------------------------------------------------
-- existing funding request checklist template header
---------------------------------------------------------
cursor c_chk_tpl_hdr (p_chr_id okc_rules_b.dnz_chr_id%type) is
  select hdr.ID
from okl_crd_fund_chklst_tpl_hdr_uv hdr
where hdr.khr_id = p_chr_id
;


begin
  -- Set API savepoint
  SAVEPOINT update_credit_chklst_tpl;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/
/*
-------------------------------------------------------------
1. create rule group if rule group doesn't exists
 (handle existing credit line contract or credit line doesn't have list)
 call create_credit_chklst_tpl()

2. check if credit template has been changed
3. update rule if changes
-- credit line checklist
 3.1.1 get the source of the checklist template lists from OKL link
 3.1.2 delete associated checklist

 3.2.1 get the source of the checklist template lists from NEW link
 3.2.2 create rules based on #3. cursor
-- instance of funding checklist template
 3.3.1 get the source of the checklist template lists from OKL link
 3.3.2 delete associated checklist

 3.4.1 get the source of the checklist template lists from NEW link
 3.4.2 create rules based on #3. cursor
-------------------------------------------------------------
*/

-------------------------------------------------------------
--1. create rule group if rule group doesn't exists
-- (handle existing credit line contract or credit line doesn't have list)
-- call create_credit_chklst_tpl()
-------------------------------------------------------------
  IF ( lp_rulv_rec.RGP_ID is null OR lp_rulv_rec.RGP_ID = OKC_API.G_MISS_NUM ) THEN

    -- rule group FK
    lpcrt_rgpv_rec.DNZ_CHR_ID := lp_rulv_rec.DNZ_CHR_ID;
    lpcrt_rgpv_rec.CHR_ID := lp_rulv_rec.DNZ_CHR_ID;

    lpcrt_rulv_rec.DNZ_CHR_ID := lp_rulv_rec.DNZ_CHR_ID;
    lpcrt_rulv_rec.RULE_INFORMATION1 := lp_rulv_rec.RULE_INFORMATION1;
    lpcrt_rulv_rec.RULE_INFORMATION2 := lp_rulv_rec.RULE_INFORMATION2;

    create_credit_chklst_tpl(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_rgpv_rec       => lpcrt_rgpv_rec,
      p_rulv_rec       => lpcrt_rulv_rec,
      x_rgpv_rec       => lxcrt_rgpv_rec,
      x_rulv_rec       => lxcrt_rulv_rec);

    -- assign new FK to local rule record

    lp_rulv_rec.RGP_ID := lxcrt_rgpv_rec.ID;

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

  ELSE -- Assume lp_rulv_rec.ID is available

-------------------------------------------------------------
--2. check if credit template has been changed
-------------------------------------------------------------
    open c_chk (lp_rulv_rec.ID);
    fetch c_chk into l_RULE_INFORMATION1,
                     l_RULE_INFORMATION2;
    close c_chk;
    ------------------------------------------------------------------------
    -- check credit checklist
    ------------------------------------------------------------------------
    ------------------------------------------------------------------------
    -- delete rule2
    -- 1. both old and new ID exist and there are different
    -- 2. old ID exists, but new ID missing
    ------------------------------------------------------------------------
    IF ( l_RULE_INFORMATION1 is not null AND
        (lp_rulv_rec.RULE_INFORMATION1 is not null AND
         lp_rulv_rec.RULE_INFORMATION1 <> l_RULE_INFORMATION1)
        OR
         lp_rulv_rec.RULE_INFORMATION1 is null
       ) THEN

      ------------------------------------------------------------------------
      -- 3.1.1 get the source of the checklist template lists from OKL link
      -- 3.1.2 delete associated checklist
      ------------------------------------------------------------------------
      open c_del (lp_rulv_rec.RGP_ID,G_CREDIT_CHKLST_TPL_RULE2);
      LOOP

        fetch c_del into l_rule_id;
        EXIT WHEN c_del%NOTFOUND;

        ldel_rulv_rec.ID := l_rule_id;

        okl_rule_pub.delete_rule(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_rec       => ldel_rulv_rec);

        If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
          raise OKC_API.G_EXCEPTION_ERROR;
        End If;

      END LOOP;
      close c_del;

    END IF;

    ------------------------------------------------------------------------
    -- create rule2
    ------------------------------------------------------------------------
    -- 1. both old and new ID exist and there are different
    -- 2. old ID missing, but new ID exists
    ------------------------------------------------------------------------
    IF (lp_rulv_rec.RULE_INFORMATION1 is not null AND
        (l_RULE_INFORMATION1 is not null AND
         lp_rulv_rec.RULE_INFORMATION1 <> l_RULE_INFORMATION1)
        OR
        l_RULE_INFORMATION1 is null
       ) THEN

      ------------------------------------------------------------------------
      -- 3.2.1 get the source of the checklist template lists from NEW link
      -- 3.2.2 create rules based on #3. cursor
      ------------------------------------------------------------------------
--start: 06-May-2005  cklee okl.h Lease App IA Authoring
      OPEN c_is_grp(TO_NUMBER(lp_rulv_rec.RULE_INFORMATION1));
      FETCH c_is_grp INTO l_dummy;
      l_is_grp_found := c_is_grp%FOUND;
      CLOSE c_is_grp;
--end: 06-May-2005  cklee okl.h Lease App IA Authoring

      -- is not a group template
      IF l_is_grp_found = false THEN
--end: 06-May-2005  cklee okl.h Lease App IA Authoring
        open c_chk_tpl(to_number(lp_rulv_rec.RULE_INFORMATION1));
        LOOP

          fetch c_chk_tpl into l_todo_item_code,
--start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
                               l_function_id,
                               l_inst_checklist_type;
--end: 06-May-2005  cklee okl.h Lease App IA Authoring                            |

          EXIT WHEN c_chk_tpl%NOTFOUND;

          lpcrt2_rulv_rec.RGP_ID := lp_rulv_rec.RGP_ID;
          lpcrt2_rulv_rec.DNZ_CHR_ID := lp_rulv_rec.DNZ_CHR_ID;

          lpcrt2_rulv_rec.RULE_INFORMATION_CATEGORY := G_CREDIT_CHKLST_TPL_RULE2;
          lpcrt2_rulv_rec.STD_TEMPLATE_YN := 'N';
          lpcrt2_rulv_rec.WARN_YN := 'N';
          lpcrt2_rulv_rec.RULE_INFORMATION1 := l_todo_item_code;
          lpcrt2_rulv_rec.RULE_INFORMATION2 := 'N';
          lpcrt2_rulv_rec.RULE_INFORMATION3 := 'N';
          lpcrt2_rulv_rec.RULE_INFORMATION5 := G_STS_CODE; -- set default status
--start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
          lpcrt2_rulv_rec.RULE_INFORMATION7 := 'UNDETERMINED'; -- set default status
          lpcrt2_rulv_rec.RULE_INFORMATION9 := l_function_id;
          lpcrt2_rulv_rec.RULE_INFORMATION10 := l_inst_checklist_type;
--end: 06-May-2005  cklee okl.h Lease App IA Authoring                            |

          okl_rule_pub.create_rule(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_rulv_rec       => lpcrt2_rulv_rec,
            x_rulv_rec       => lxcrt2_rulv_rec);

          If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
            raise OKC_API.G_EXCEPTION_ERROR;
          End If;

        END LOOP;
        CLOSE c_chk_tpl;

      -- is a group template
--      IF l_is_grp_found = false THEN
      ELSE

        open c_grp_chk(to_number(lp_rulv_rec.RULE_INFORMATION1));
        LOOP

          fetch c_grp_chk into l_todo_item_code,
--start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
                               l_function_id,
                               l_inst_checklist_type;
--end: 06-May-2005  cklee okl.h Lease App IA Authoring                            |

          EXIT WHEN c_grp_chk%NOTFOUND;

          lpcrt2_rulv_rec.RGP_ID := lp_rulv_rec.RGP_ID;
          lpcrt2_rulv_rec.DNZ_CHR_ID := lp_rulv_rec.DNZ_CHR_ID;

          lpcrt2_rulv_rec.RULE_INFORMATION_CATEGORY := G_CREDIT_CHKLST_TPL_RULE2;
          lpcrt2_rulv_rec.STD_TEMPLATE_YN := 'N';
          lpcrt2_rulv_rec.WARN_YN := 'N';
          lpcrt2_rulv_rec.RULE_INFORMATION1 := l_todo_item_code;
          lpcrt2_rulv_rec.RULE_INFORMATION2 := 'N';
          lpcrt2_rulv_rec.RULE_INFORMATION3 := 'N';
          lpcrt2_rulv_rec.RULE_INFORMATION5 := G_STS_CODE; -- set default status
--start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
          lpcrt2_rulv_rec.RULE_INFORMATION7 := 'UNDETERMINED'; -- set default status
          lpcrt2_rulv_rec.RULE_INFORMATION9 := l_function_id;
          lpcrt2_rulv_rec.RULE_INFORMATION10 := l_inst_checklist_type;
--end: 06-May-2005  cklee okl.h Lease App IA Authoring                            |

          okl_rule_pub.create_rule(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_rulv_rec       => lpcrt2_rulv_rec,
            x_rulv_rec       => lxcrt2_rulv_rec);

          If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
            raise OKC_API.G_EXCEPTION_ERROR;
          End If;

        END LOOP;
        CLOSE c_grp_chk;

      END IF;


    END IF;

    ------------------------------------------------------------------------
    -- check instance of funding checklist template at credit line level
    ------------------------------------------------------------------------
    ------------------------------------------------------------------------
    -- check if funding request checklist header already exists
    ------------------------------------------------------------------------
    open c_chk_tpl_hdr(lp_rulv_rec.DNZ_CHR_ID);
    fetch c_chk_tpl_hdr into l_fund_clist_hdr_id;
    l_fund_cl_hdr_notfound := c_chk_tpl_hdr%NOTFOUND;
    close c_chk_tpl_hdr;

    ------------------------------------------------------------------------
    -- delete rule3
    -- 1. both old and new ID exists and there are different
    -- 2. old ID exists, but new ID missing
    ------------------------------------------------------------------------
    IF ( l_RULE_INFORMATION2 is not null AND
        (lp_rulv_rec.RULE_INFORMATION2 is not null AND
         lp_rulv_rec.RULE_INFORMATION2 <> l_RULE_INFORMATION2)
        OR
         lp_rulv_rec.RULE_INFORMATION2 is null
       ) THEN

      ------------------------------------------------------------------------
      -- 3.3.1 get the source of the checklist template lists from OKL link
      -- 3.3.2 delete associated checklist
      ------------------------------------------------------------------------
      open c_del (lp_rulv_rec.RGP_ID,G_CREDIT_CHKLST_TPL_RULE3);
      LOOP

        fetch c_del into l_rule_id;
        EXIT WHEN c_del%NOTFOUND;

        ldel_rulv_rec.ID := l_rule_id;

        okl_rule_pub.delete_rule(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_rec       => ldel_rulv_rec);

        If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
          raise OKC_API.G_EXCEPTION_ERROR;
        End If;

      END LOOP;
      close c_del;

      ------------------------------------------------------------------------
      -- delete funding checklist template header
      ------------------------------------------------------------------------
      ldel_rulv_rec.ID := l_fund_clist_hdr_id;

      okl_rule_pub.delete_rule(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_rec       => ldel_rulv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

    END IF;

    ------------------------------------------------------------------------
    -- create rule3
    ------------------------------------------------------------------------
    -- 1. both old and new ID exist and there are different
    -- 2. old ID missing, but new ID exists
    ------------------------------------------------------------------------
    IF (lp_rulv_rec.RULE_INFORMATION2 is not null AND
        (l_RULE_INFORMATION2 is not null AND
         lp_rulv_rec.RULE_INFORMATION2 <> l_RULE_INFORMATION2)
        OR
        l_RULE_INFORMATION2 is null
       ) THEN

      ------------------------------------------------------------------------
      -- create funding checklist template header
      ------------------------------------------------------------------------
      open c_chk_tpl_hdr(lp_rulv_rec.DNZ_CHR_ID);
      fetch c_chk_tpl_hdr into l_fund_clist_hdr_id;
      l_fund_cl_hdr_notfound := c_chk_tpl_hdr%NOTFOUND;
      close c_chk_tpl_hdr;

      IF (l_fund_cl_hdr_notfound) THEN

        lpcrt3_rulv_rec.RGP_ID := lp_rulv_rec.RGP_ID;
        lpcrt3_rulv_rec.DNZ_CHR_ID := lp_rulv_rec.DNZ_CHR_ID;

        lpcrt3_rulv_rec.RULE_INFORMATION_CATEGORY := G_CREDIT_CHKLST_TPL_RULE4;
        lpcrt3_rulv_rec.STD_TEMPLATE_YN := 'N';
        lpcrt3_rulv_rec.WARN_YN := 'N';
--        lpcrt3_rulv_rec.RULE_INFORMATION1 := null -- effective from
--        lpcrt3_rulv_rec.RULE_INFORMATION2 := null; -- effective to
        lpcrt3_rulv_rec.RULE_INFORMATION3 := G_STS_CODE;

        okl_rule_pub.create_rule(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_rec       => lpcrt3_rulv_rec,
          x_rulv_rec       => lxcrt3_rulv_rec);

        If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
          raise OKC_API.G_EXCEPTION_ERROR;
        End If;

      -- assign to this variable for later
      l_fund_clist_hdr_id := lxcrt3_rulv_rec.ID;

      ------------------------------------------------------------------------
      -- update funding checklist template header
      ------------------------------------------------------------------------
      ELSE

        lpcrt3_rulv_rec.ID := l_fund_clist_hdr_id;
--        lpcrt3_rulv_rec.RGP_ID := lp_rulv_rec.RGP_ID;
--        lpcrt3_rulv_rec.DNZ_CHR_ID := lp_rulv_rec.DNZ_CHR_ID;

--        lpcrt3_rulv_rec.RULE_INFORMATION_CATEGORY := G_CREDIT_CHKLST_TPL_RULE4;
--        lpcrt3_rulv_rec.STD_TEMPLATE_YN := 'N';
--        lpcrt3_rulv_rec.WARN_YN := 'N';
        lpcrt3_rulv_rec.RULE_INFORMATION1 := null; -- effective from
        lpcrt3_rulv_rec.RULE_INFORMATION2 := null; -- effective to
        lpcrt3_rulv_rec.RULE_INFORMATION3 := G_STS_CODE;
        lpcrt3_rulv_rec.RULE_INFORMATION4 := null; -- note

        okl_rule_pub.update_rule(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_rec       => lpcrt3_rulv_rec,
          x_rulv_rec       => lxcrt3_rulv_rec);

        If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
          raise OKC_API.G_EXCEPTION_ERROR;
        End If;

      END IF;
      ------------------------------------------------------------------------
      -- 3.4.1 get the source of the checklist template lists from NEW link
      -- 3.4.2 create rules based on #3.3 cursor
      ------------------------------------------------------------------------
--start: 06-May-2005  cklee okl.h Lease App IA Authoring
      OPEN c_is_grp(TO_NUMBER(lp_rulv_rec.RULE_INFORMATION2));
      FETCH c_is_grp INTO l_dummy;
      l_is_grp_found := c_is_grp%FOUND;
      CLOSE c_is_grp;
--end: 06-May-2005  cklee okl.h Lease App IA Authoring

      -- is not a group template
      IF l_is_grp_found = false THEN
--end: 06-May-2005  cklee okl.h Lease App IA Authoring
        open c_chk_tpl(to_number(lp_rulv_rec.RULE_INFORMATION2));
        LOOP

          fetch c_chk_tpl into l_todo_item_code,
--start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
                               l_function_id,
                               l_inst_checklist_type;
--end: 06-May-2005  cklee okl.h Lease App IA Authoring                            |

          EXIT WHEN c_chk_tpl%NOTFOUND;

          lpcrt4_rulv_rec.RGP_ID := lp_rulv_rec.RGP_ID;
          lpcrt4_rulv_rec.DNZ_CHR_ID := lp_rulv_rec.DNZ_CHR_ID;

          lpcrt4_rulv_rec.OBJECT1_ID1 := l_fund_clist_hdr_id;--lpcrt3_rulv_rec.ID; -- FK
          lpcrt4_rulv_rec.OBJECT1_ID2 := '#'; -- dummy one

          lpcrt4_rulv_rec.RULE_INFORMATION_CATEGORY := G_CREDIT_CHKLST_TPL_RULE3;
          lpcrt4_rulv_rec.STD_TEMPLATE_YN := 'N';
          lpcrt4_rulv_rec.WARN_YN := 'N';
          lpcrt4_rulv_rec.RULE_INFORMATION1 := l_todo_item_code;
          lpcrt4_rulv_rec.RULE_INFORMATION2 := 'N';
--Commented by cklee 10-May-2005        lpcrt4_rulv_rec.RULE_INFORMATION3 := 'N';
--start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
          lpcrt4_rulv_rec.RULE_INFORMATION6 := l_function_id;
          lpcrt4_rulv_rec.RULE_INFORMATION7 := l_inst_checklist_type;
--end: 06-May-2005  cklee okl.h Lease App IA Authoring                            |

          okl_rule_pub.create_rule(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_rulv_rec       => lpcrt4_rulv_rec,
            x_rulv_rec       => lxcrt4_rulv_rec);

          If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
            raise OKC_API.G_EXCEPTION_ERROR;
          End If;

        END LOOP;
        CLOSE c_chk_tpl;

      -- is not a group template
--      IF l_is_grp_found = false THEN
     ELSE
      open c_grp_chk(to_number(lp_rulv_rec.RULE_INFORMATION2));
      LOOP

        fetch c_grp_chk into l_todo_item_code,
--start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
                             l_function_id,
                             l_inst_checklist_type;
--end: 06-May-2005  cklee okl.h Lease App IA Authoring                            |

        EXIT WHEN c_grp_chk%NOTFOUND;

        lpcrt4_rulv_rec.RGP_ID := lp_rulv_rec.RGP_ID;
        lpcrt4_rulv_rec.DNZ_CHR_ID := lp_rulv_rec.DNZ_CHR_ID;

        lpcrt4_rulv_rec.OBJECT1_ID1 := l_fund_clist_hdr_id;--lpcrt3_rulv_rec.ID; -- FK
        lpcrt4_rulv_rec.OBJECT1_ID2 := '#'; -- dummy one

        lpcrt4_rulv_rec.RULE_INFORMATION_CATEGORY := G_CREDIT_CHKLST_TPL_RULE3;
        lpcrt4_rulv_rec.STD_TEMPLATE_YN := 'N';
        lpcrt4_rulv_rec.WARN_YN := 'N';
        lpcrt4_rulv_rec.RULE_INFORMATION1 := l_todo_item_code;
        lpcrt4_rulv_rec.RULE_INFORMATION2 := 'N';
--Commented by cklee 10-May-2005        lpcrt4_rulv_rec.RULE_INFORMATION3 := 'N';
--start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
        lpcrt4_rulv_rec.RULE_INFORMATION6 := l_function_id;
        lpcrt4_rulv_rec.RULE_INFORMATION7 := l_inst_checklist_type;
--end: 06-May-2005  cklee okl.h Lease App IA Authoring                            |

        okl_rule_pub.create_rule(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_rec       => lpcrt4_rulv_rec,
          x_rulv_rec       => lxcrt4_rulv_rec);

        If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
          raise OKC_API.G_EXCEPTION_ERROR;
        End If;

      END LOOP;
      CLOSE c_grp_chk;
     END IF;

    END IF;

    ------------------------------------------------------------------------
    -- 4 update rule1 : always update with the new IDs
    ------------------------------------------------------------------------
    -- credit line checklist template
    -- 1. both old ID and new ID exist and there are different
    -- 2. old ID missing, new ID exists
    -- funding checklist template
    -- 3. both old ID and new ID exist and there are different
    -- 4. old ID missing, new ID exists
    ------------------------------------------------------------------------
    okl_rule_pub.update_rule(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_rec       => lp_rulv_rec,
          x_rulv_rec       => lx_rulv_rec);

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
      raise OKC_API.G_EXCEPTION_ERROR;
    End If;

  END IF; -- end of  IF ( lp_rulv_rec.RGP_ID is null...

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);

end update_credit_chklst_tpl;

  --------------------------------------------------------------------------
  -- Validate Credit Checklist
  -- Description: Check checklist templates when activate a credit line
  --
  --------------------------------------------------------------------------
  FUNCTION validate_credit_checklist(
    p_chrv_rec     OKL_OKC_MIGRATION_PVT.chrv_rec_type
    ,p_rulv_rec    okl_rule_pub.rulv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_req_row_found       boolean;
    l_grp_row_not_found   boolean;
    l_active_row_not_found   boolean;
    l_expired_row_found   boolean;
    l_chklist_sts_row_found   boolean;
    l_chklist_hdr_row_notfound   boolean;

    l_credit_checklist_tpl okc_rules_b.rule_information1%TYPE;
    l_funding_checklist_tpl okc_rules_b.rule_information2%TYPE;
    l_checklists_row_found boolean;

    l_dummy           number;

    l_status okl_crd_fund_chklst_tpl_hdr_uv.status%TYPE;
    l_effective_to okl_crd_fund_chklst_tpl_hdr_uv.effective_to%TYPE;

--------------------------------------------------------------------------------------------
--1 This is used for existing credit line and user try to activate credit line w/o activate
--  checklists
--------------------------------------------------------------------------------------------
CURSOR c_chklst_header(p_chr_id okc_k_headers_b.id%type)
IS
  select 1
from  okc_rule_groups_b rgp
where  rgp.dnz_chr_id = p_chr_id
and    rgp.RGD_CODE   = G_CREDIT_CHKLST_TPL
;

--------------------------------------------------------------------------------------------
--2. Credit line checklist must activated before activate credit line
--------------------------------------------------------------------------------------------
CURSOR c_chklst_sts (p_chr_id okc_k_headers_b.id%type)
IS
--start modified abhsaxen for performance SQLID 20562641
select 1
from  OKC_RULES_B RULT
where  rult.DNZ_CHR_ID = p_chr_id and
   nvl(rult.RULE_INFORMATION5, 'NEW') <> 'ACTIVE'and
   rult.rule_information_category = 'LACCLD'
--end modified abhsaxen for performance SQLID 20562641
;
--------------------------------------------------------------------------------------------
--3.1 Funding request checklist template must activated before activate credit line
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--3.2 Funding request checklist template must not expired before activate credit line
--------------------------------------------------------------------------------------------
CURSOR c_fund_chklst_sts (p_chr_id okc_k_headers_b.id%type)
IS
  select chk.status,
         chk.effective_to
from  okl_crd_fund_chklst_tpl_hdr_uv chk
where  chk.khr_id = p_chr_id
;

--------------------------------------------------------------------------------------------
--4. Credit line checklist has not met requirement before activate credit line
--------------------------------------------------------------------------------------------
CURSOR c_chklst (p_chr_id okc_k_headers_b.id%type)
IS
  select 1
from  okc_rules_b rult
where rult.rule_information_category = G_CREDIT_CHKLST_TPL_RULE2--'LACCLD'
and   rult.dnz_chr_id = p_chr_id
and   rult.RULE_INFORMATION2 = 'Y'
and   (rult.RULE_INFORMATION3 <> 'Y' or rult.RULE_INFORMATION3 is null)
;

--------------------------------------------------------------------------------------------
-- credit line status
--------------------------------------------------------------------------------------------
CURSOR c_active (p_chr_id okc_k_headers_b.id%type)
IS
  select 1
from  okc_k_headers_b k
where k.id = p_chr_id
and   k.sts_code = 'ACTIVE'
;

--------------------------------------------------------------------------------------------
-- Checklists link check
--------------------------------------------------------------------------------------------
CURSOR c_checklists (p_chr_id  NUMBER)
  IS
  select rule.rule_information1,
         rule.rule_information2
  from okc_rules_b rule
  where rule.dnz_chr_id = p_chr_id
  and   rule.rule_information_category = G_CREDIT_CHKLST_TPL_RULE1
  ;


  BEGIN

    OPEN c_checklists(p_chrv_rec.id);
    FETCH c_checklists INTO l_credit_checklist_tpl,
                            l_funding_checklist_tpl;
    l_checklists_row_found := c_checklists%FOUND;
    CLOSE c_checklists;

    OPEN c_active(p_chrv_rec.id);
    FETCH c_active INTO l_dummy;
    l_active_row_not_found := c_active%NOTFOUND;
    CLOSE c_active;

    -- check only when record becomes ACTIVE at 1st time. we don't check once sts_code becomes active
-- start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
    IF (p_chrv_rec.sts_code IN ('SUBMITTED', 'ACTIVE') AND l_active_row_not_found) THEN
-- end: 06-May-2005  cklee okl.h Lease App IA Authoring                            |

      --------------------------------------------------------------------------------------------
      --1 This is used for existing credit line and user try to activate credit line w/o activate
      --  checklists (user select all or one of the checklist template, but has not been updated credit line 1st)
      --------------------------------------------------------------------------------------------
      OPEN c_chklst_header(p_chrv_rec.id);
      FETCH c_chklst_header INTO l_dummy;
      l_chklist_hdr_row_notfound := c_chklst_header%NOTFOUND;
      CLOSE c_chklst_header;

      IF (l_chklist_hdr_row_notfound
          AND (p_rulv_rec.RULE_INFORMATION1 is not null OR
               p_rulv_rec.RULE_INFORMATION2 is not null)) THEN
        -- Credit line checklists not found. Please update credit line and setup checklists before activate credit line.
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_CREDIT_CHKLST1');

        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      --------------------------------------------------------------------------------------------
      --2. Credit line checklist must activated before activate credit line
      --------------------------------------------------------------------------------------------
      OPEN c_chklst_sts(p_chrv_rec.id);
      FETCH c_chklst_sts INTO l_dummy;
      l_chklist_sts_row_found := c_chklst_sts%FOUND;
      CLOSE c_chklst_sts;

      -- 2. checklist has not been activate yet
      IF (l_credit_checklist_tpl IS NOT NULL and l_chklist_sts_row_found) THEN
        -- Credit line checklist status is new. Please activate credit line checklist before activate credit line.
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_CREDIT_CHKLST3');

        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      --------------------------------------------------------------------------------------------
      --3.1 Funding request checklist template must activated before activate credit line
      --------------------------------------------------------------------------------------------
      OPEN c_fund_chklst_sts(p_chrv_rec.id);
      FETCH c_fund_chklst_sts INTO l_status,
                                   l_effective_to;
      CLOSE c_fund_chklst_sts;

      -- 3.1 funding checklist template has not been activate yet
      IF (l_funding_checklist_tpl IS NOT NULL and l_status <> 'ACTIVE') THEN
        -- Funding request checklist template status is new.
        -- Please activate Funding request checklist template before activate credit line.
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_FUND_CHKLST_CHECK5');

        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      --------------------------------------------------------------------------------------------
      --3.2 Funding request checklist template must not expired before activate credit line
      --------------------------------------------------------------------------------------------
      -- 3.2 funding checklist template expired.
      IF (l_funding_checklist_tpl IS NOT NULL and trunc(l_effective_to) < trunc(SYSDATE)) THEN
        -- Funding request checklist template expired. Please modify effective date of Funding request checklist template.
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_FUND_CHKLST_CHECK6');


        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

-- start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
/* check @ WF
      OPEN c_chklst(p_chrv_rec.id);
      FETCH c_chklst INTO l_dummy;
      l_req_row_found := c_chklst%FOUND;
      CLOSE c_chklst;

      --------------------------------------------------------------------------------------------
      --4. Credit line checklist has not met requirement before activate credit line
      --------------------------------------------------------------------------------------------
      -- 4. all required items have not met requirement
      IF (l_credit_checklist_tpl IS NOT NULL and l_req_row_found) THEN
        -- Credit line has not met all checklist items. Please check off all mandatory checklist items.
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_CREDIT_CHKLST');

        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
*/
-- end: 06-May-2005  cklee okl.h Lease App IA Authoring                            |

    END IF;


    RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;

---------------------------------------------------------------
-- validate credit nature after row have been insert or update
-- in DB
---------------------------------------------------------------
  FUNCTION validate_credit_limit_after(
    p_chr_id IN NUMBER,
    p_mode IN VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_msg_name  VARCHAR2(200);
    l_dummy_n number;
    l_dummy   VARCHAR2(1) := '?';
    l_dup     BOOLEAN := false;
    l_date_check1     BOOLEAN := false;
    l_date_check2     BOOLEAN := false;
    l_amount_check1     BOOLEAN := false;
    l_amount_check2     BOOLEAN := false;


    l_not_exists  BOOLEAN := false;

    l_api_version       NUMBER := 1.0;
    l_init_msg_list     VARCHAR2(1) := OKL_API.G_FALSE;
    x_return_status     VARCHAR2(1);
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(2000);
    x_value             NUMBER := 0;
    l_amount            NUMBER;


  -- line amount check 1: Can not be negative
  CURSOR c_amount_check1 (p_contract_id  NUMBER)
  IS
  select 1
  from OKL_K_LINES kln,
       OKC_K_LINES_B cln
  where kln.id = cln.id
  and   cln.dnz_chr_id = p_contract_id
  and   kln.amount < 0
  ;

  -- line amount check 2: Can not be Zero
  CURSOR c_amount_check2 (p_contract_id  NUMBER)
  IS
  select 1
  from OKL_K_LINES kln,
       OKC_K_LINES_B cln
  where kln.id = cln.id
  and   cln.dnz_chr_id = p_contract_id
  and   kln.amount = 0
  ;

  -- New limit exsiting check
  CURSOR c_not_exists (p_contract_id  NUMBER)
  IS
  select 'X'
  from OKL_K_LINES kln,
       OKC_K_LINES_B cln
  where kln.id = cln.id
  and   cln.dnz_chr_id = p_contract_id
  and   kln.CREDIT_NATURE = 'NEW'
  ;

  -- New limit duplication check
  CURSOR c_dup (p_contract_id  NUMBER)
  IS
  select cln.dnz_chr_id
  from OKL_K_LINES kln,
       OKC_K_LINES_B cln
  where kln.id = cln.id
  and   cln.dnz_chr_id = p_contract_id
  and   kln.CREDIT_NATURE = 'NEW'
  group by cln.dnz_chr_id
  having count(1) > 1
  ;

  -- line start date < header start date
  CURSOR c_date_check1 (p_chr_id NUMBER)
  IS
  SELECT 1
  FROM okc_k_headers_b chr,
       okc_k_lines_b cln
  WHERE chr.id = cln.dnz_chr_id
  AND   chr.start_date IS NOT NULL
  AND   trunc(cln.start_date) < trunc(chr.start_date)
  AND   chr.id = p_chr_id
    ;

  -- line start date > header end date
  CURSOR c_date_check2 (p_chr_id NUMBER)
  IS
  SELECT 1
  FROM okc_k_headers_b chr,
       okc_k_lines_b cln
  WHERE chr.id = cln.dnz_chr_id
  AND   chr.end_date IS NOT NULL
  AND   trunc(cln.start_date) > trunc(chr.end_date)
  AND   chr.id = p_chr_id
    ;

  BEGIN

    --------------------------------------------------
    -- duplication check
    --------------------------------------------------
    OPEN c_dup(p_chr_id);
    FETCH c_dup INTO l_dummy_n;
    l_dup := c_dup%FOUND;
    CLOSE c_dup;

    IF ( l_dup ) THEN

       OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_NOT_UNIQUE',
                          p_token1       => 'COL_NAME',
                          p_token1_value => 'New Limit');
       RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    --------------------------------------------------
    -- new limit check
    --------------------------------------------------
    OPEN c_not_exists(p_chr_id);
    FETCH c_not_exists INTO l_dummy;
    l_not_exists := c_not_exists%NOTFOUND;
    CLOSE c_not_exists;

    IF ( l_not_exists ) THEN

       IF (p_mode = 'NEW') THEN
         l_msg_name := 'OKL_LLA_CREDIT_LIMIT_CHECK1';
       ELSIF (p_mode = 'DELETE') THEN
         l_msg_name := 'OKL_LLA_CREDIT_LIMIT_CHECK2';
       ELSIF (p_mode = 'UPDATE') THEN
         l_msg_name := 'OKL_LLA_CREDIT_LIMIT_CHECK3';
       END IF;

       OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                           p_msg_name     => l_msg_name);
       RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    --------------------------------------------------
    -- date range check 1
    --------------------------------------------------
    OPEN c_date_check1(p_chr_id);
    FETCH c_date_check1 INTO l_dummy_n;
    l_date_check1 := c_date_check1%FOUND;
    CLOSE c_date_check1;

    IF ( l_date_check1 ) THEN

          OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_RANGE_CHECK2',
                          p_token1       => 'COL_NAME1',
                          p_token1_value => 'Effective From',
                          p_token2       => 'COL_NAME2',
                          p_token2_value => 'Effective From of Credit Line');
       RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    --------------------------------------------------
    -- date range check 2
    --------------------------------------------------
    OPEN c_date_check2(p_chr_id);
    FETCH c_date_check2 INTO l_dummy_n;
    l_date_check2 := c_date_check2%FOUND;
    CLOSE c_date_check2;

    IF ( l_date_check2 ) THEN

          OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LESS_THAN',
                          p_token1       => 'COL_NAME1',
                          p_token1_value => 'Effective From',
                          p_token2       => 'COL_NAME2',
                          p_token2_value => 'Effective To of Credit Line');
       RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    --------------------------------------------------
    -- line amount check 1: Can not be negative
    --------------------------------------------------
    OPEN c_amount_check1(p_chr_id);
    FETCH c_amount_check1 INTO l_dummy_n;
    l_amount_check1 := c_amount_check1%FOUND;
    CLOSE c_amount_check1;

    IF ( l_amount_check1 ) THEN

        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_POSITIVE_AMOUNT_ONLY',
                          p_token1       => 'COL_NAME',
                          p_token1_value => 'Amount');
       RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    --------------------------------------------------
    -- line amount check 2: Can not be zero
    --------------------------------------------------
    OPEN c_amount_check2(p_chr_id);
    FETCH c_amount_check2 INTO l_dummy_n;
    l_amount_check2 := c_amount_check2%FOUND;
    CLOSE c_amount_check2;

    IF ( l_amount_check2 ) THEN

        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_AMOUNT_CHECK');
       RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    --------------------------------------------------
    -- Credit limt Remaining check
    --------------------------------------------------
    OKL_EXECUTE_FORMULA_PUB.execute(
      p_api_version   => l_api_version,
      p_init_msg_list => l_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_formula_name  => 'CONTRACT_TOT_CRDT_LMT',
      p_contract_id   => p_chr_id,
      x_value         => x_value);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        --RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        x_value := 0;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        --RAISE OKL_API.G_EXCEPTION_ERROR;
        x_value := 0;
    END IF;

    l_amount := x_value;

    IF (l_amount < 0 ) THEN

      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_CREDIT_LIMIT_CHECK');
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;


    RETURN l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
  --------------------------------------------------------------------------
  ----- Validate credit nature: NEW LIMIT
  ----- only check @ create mode
  ----- UI will skip delete or modify the NEW LIMIT record
  --------------------------------------------------------------------------
  FUNCTION validate_credit_nature(
    p_clev_rec OKL_OKC_MIGRATION_PVT.clev_rec_type
    ,p_klev_rec OKL_CONTRACT_PVT.klev_rec_type
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_existing_status   VARCHAR2(1) := '?';

  CURSOR c (p_contract_id  NUMBER)
  IS
  select 'X'
  from OKL_K_LINES_FULL_V a
  where a.dnz_chr_id = p_contract_id
  and   a.CREDIT_NATURE = 'NEW'
  ;

  BEGIN

-- start: cklee 03/24/2004
    -- credit_nature is required:
    IF (p_klev_rec.credit_nature IS NULL) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Credit Nature');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
-- end: cklee 03/24/2004

    RETURN l_return_status;
  EXCEPTION

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;

  --------------------------------------------------------------------------
  ----- Validate credit limit amount
  --------------------------------------------------------------------------
  FUNCTION validate_amount(
    p_clev_rec OKL_OKC_MIGRATION_PVT.clev_rec_type
    ,p_klev_rec OKL_CONTRACT_PVT.klev_rec_type
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

-- start: cklee 03/24/2004
    -- amount is required:
    IF (p_klev_rec.amount IS NULL) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Amount');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
-- end: cklee 03/24/2004

    IF (p_klev_rec.amount IS NOT NULL AND
        p_klev_rec.amount <> OKL_API.G_MISS_NUM)
    THEN

      IF (p_klev_rec.amount < 0 ) THEN

        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_POSITIVE_AMOUNT_ONLY',
                          p_token1       => 'COL_NAME',
                          p_token1_value => 'Amount');

        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      IF (p_klev_rec.amount = 0 ) THEN

        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_AMOUNT_CHECK');

        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

    END IF;

    RETURN l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
  --------------------------------------------------------------------------
  ----- Validate Credit Limit start date
  --------------------------------------------------------------------------
  FUNCTION validate_start_date(
    p_clev_rec OKL_OKC_MIGRATION_PVT.clev_rec_type
    ,p_klev_rec OKL_CONTRACT_PVT.klev_rec_type
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_header_start_date DATE;
    l_header_end_date DATE;

    CURSOR c (p_chr_id NUMBER)
    IS
    SELECT k.start_date,
           k.end_date
      FROM okc_k_headers_b k
     WHERE k.id = p_chr_id
    ;

  BEGIN

-- start: cklee 03/24/2004
    -- start date is required:
    IF (p_clev_rec.start_date IS NULL) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Effective From');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
-- end: cklee 03/24/2004

    OPEN c(p_clev_rec.dnz_chr_id);
    FETCH c INTO l_header_start_date,
                 l_header_end_date;
    CLOSE c;

    IF (p_clev_rec.start_date IS NOT NULL AND
        p_clev_rec.start_date <> OKL_API.G_MISS_DATE)
    THEN

      IF (l_header_start_date IS NOT NULL) THEN
        IF (trunc(p_clev_rec.start_date) < trunc(l_header_start_date)) THEN

          OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_RANGE_CHECK2',
                          p_token1       => 'COL_NAME1',
                          p_token1_value => 'Effective From',
                          p_token2       => 'COL_NAME2',
                          p_token2_value => 'Effective From of Credit Line');
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      END IF;

      IF (l_header_end_date IS NOT NULL) THEN
        IF (trunc(p_clev_rec.start_date) > trunc(l_header_end_date)) THEN

          OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LESS_THAN',
                          p_token1       => 'COL_NAME1',
                          p_token1_value => 'Effective From',
                          p_token2       => 'COL_NAME2',
                          p_token2_value => 'Effective To of Credit Line');
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      END IF;

    END IF;

    RETURN l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;

  END;

  --------------------------------------------------------------------------
  ----- Validate Description
  --------------------------------------------------------------------------
  FUNCTION validate_description(
    p_chrv_rec     OKL_OKC_MIGRATION_PVT.chrv_rec_type
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (p_chrv_rec.description IS NOT NULL AND
        p_chrv_rec.description <> OKL_API.G_MISS_CHAR)
    THEN

      IF (length(p_chrv_rec.description) > 600) THEN

        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_EXCEED_MAXIMUM_LENGTH',
                          p_token1       => 'MAX_CHARS',
                          p_token1_value => '600',
                          p_token2       => 'COL_NAME',
                          p_token2_value => 'Description');

        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

    RETURN l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;

  --------------------------------------------------------------------------
  ----- Validate Credit Number uniqueness check
  --------------------------------------------------------------------------
  FUNCTION validate_credit_number(
    p_chrv_rec     OKL_OKC_MIGRATION_PVT.chrv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  VARCHAR2(1) := '?';

    CURSOR c (p_credit_number VARCHAR2)
    IS
    SELECT 'X'
      FROM okc_k_headers_b k
     WHERE k.contract_number = p_credit_number
-- bug fixed for creditline contarct sub-class
--     and k.scs_code = 'CREDITLINE_CONTRACT'
    ;


    CURSOR c2 (p_credit_number VARCHAR2, p_id NUMBER)
    IS
    SELECT 'X'
      FROM okc_k_headers_b k
     WHERE k.contract_number = p_credit_number
     AND   k.id <> p_id -- except itself
  ;

  BEGIN

    -- check only if credit number exists
    IF (p_chrv_rec.contract_number IS NOT NULL AND
        p_chrv_rec.contract_number <> OKL_API.G_MISS_CHAR)
    THEN

      IF (p_mode = 'C') THEN
        OPEN c(p_chrv_rec.contract_number);
        FETCH c INTO l_dummy;
        CLOSE c;
      ELSIF (p_mode = 'U') THEN
        OPEN c2(p_chrv_rec.contract_number, p_chrv_rec.id);
        FETCH c2 INTO l_dummy;
        CLOSE c2;
      END IF;

      IF (l_dummy = 'X')
      THEN
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_CONTRACT_EXISTS',
                          p_token1       => 'COL_NAME',
                          p_token1_value => p_chrv_rec.contract_number);

        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

    END IF;

    RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
  --------------------------------------------------------------------------
  ----- Validate Effective From
  --------------------------------------------------------------------------
  FUNCTION validate_start_date(
    p_chrv_rec     OKL_OKC_MIGRATION_PVT.chrv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_min_start_date  DATE;

    l_row_found boolean := false;

  CURSOR c (p_contract_id  NUMBER)
  IS
-- cklee 12-10-2003 fixed sql performance
  select min(start_date)
  from OKC_K_LINES_B a
  where a.dnz_chr_id = p_contract_id
  ;

  BEGIN

    -- start date is required:
    IF (p_chrv_rec.start_date IS NULL) OR
       (p_chrv_rec.start_date = OKL_API.G_MISS_DATE)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Effective From');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF (p_mode = 'U') THEN

      -- get credit limit minimum start date
      OPEN c(p_chrv_rec.id);
      FETCH c INTO l_min_start_date;
      l_row_found := c%FOUND;
      CLOSE c;

--
-- cklee 30-OCT-2002 check only when credit limit exists
--
      IF (l_row_found AND
          trunc(p_chrv_rec.start_date) > trunc(l_min_start_date))
      THEN
          OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LESS_THAN',
                          p_token1       => 'COL_NAME1',
                          p_token1_value => 'Effective From',
                          p_token2       => 'COL_NAME2',
                          p_token2_value => 'Effective From of Credit Limit');
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

    RETURN l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
  --------------------------------------------------------------------------
  ----- Validate Effective To
  --------------------------------------------------------------------------
  FUNCTION validate_end_date(
    p_chrv_rec     OKL_OKC_MIGRATION_PVT.chrv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_max_start_date  DATE;
    l_row_found boolean := false;

-- 11-19-2003   cklee fixed sql performance bug
  CURSOR c2 (p_contract_id  NUMBER)
  IS
  select max(start_date)
  from OKC_K_LINES_B a
  where a.dnz_chr_id = p_contract_id
  ;

  BEGIN

    -- end date is required:
    IF (p_chrv_rec.end_date IS NULL) OR
       (p_chrv_rec.end_date = OKL_API.G_MISS_DATE)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Effective To');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF (trunc(p_chrv_rec.end_date) < trunc(sysdate))
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_RANGE_CHECK',
                          p_token1       => 'COL_NAME1',
                          p_token1_value => 'Effective To',
                          p_token2       => 'COL_NAME2',
                          p_token2_value => 'today');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF (p_mode = 'U') THEN

      -- get credit limit maximum start date
      OPEN c2(p_chrv_rec.id);
      FETCH c2 INTO l_max_start_date;
      l_row_found := c2%FOUND;
      CLOSE c2;

--
-- cklee 30-OCT-2002 check only when credit limit exists
--
      IF (l_row_found AND
          trunc(p_chrv_rec.end_date) < trunc(l_max_start_date))
      THEN
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_RANGE_CHECK',
                          p_token1       => 'COL_NAME1',
                          p_token1_value => 'Effective To',
                          p_token2       => 'COL_NAME2',
                          p_token2_value => 'Effective From of Credit Limit');

        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

    RETURN l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
  --------------------------------------------------------------------------
  ----- Validate Effective From and Effective To
  --------------------------------------------------------------------------
  FUNCTION validate_start_end_date(

    p_chrv_rec     OKL_OKC_MIGRATION_PVT.chrv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_header_start_date DATE;

    CURSOR c (p_chr_id NUMBER)
    IS
    SELECT k.start_date
      FROM okc_k_headers_b k
     WHERE k.id = p_chr_id
    ;

  BEGIN

-- start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
    IF (p_mode = 'U' AND p_chrv_rec.sts_code IN ('SUBMITTED', 'ACTIVE')) THEN
-- end: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
      OPEN c(p_chrv_rec.id);
      FETCH c INTO l_header_start_date;
      CLOSE c;
    ELSE
      l_header_start_date := p_chrv_rec.start_date;
    END IF;

    IF (trunc(l_header_start_date) > trunc(p_chrv_rec.end_date))
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_RANGE_CHECK',
                          p_token1       => 'COL_NAME1',
                          p_token1_value => 'Effective To',
                          p_token2       => 'COL_NAME2',
                          p_token2_value => 'Effective From');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    RETURN l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN


      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
  --------------------------------------------------------------------------
  ----- Validate Credit Amount when status change to 'Active'
  --------------------------------------------------------------------------
  FUNCTION validate_credit_amount(
    p_chrv_rec     OKL_OKC_MIGRATION_PVT.chrv_rec_type
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_amount          NUMBER := 0;
    l_api_version       NUMBER := 1.0;
    l_init_msg_list     VARCHAR2(1) := OKL_API.G_FALSE;
    x_return_status     VARCHAR2(1);
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(2000);
    x_value             NUMBER := 0;

  BEGIN

-- start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
    IF (p_chrv_rec.sts_code IN ('SUBMITTED', 'ACTIVE')) THEN
-- end: 06-May-2005  cklee okl.h Lease App IA Authoring                            |

      --l_amount := OKL_SEEDED_FUNCTIONS_PVT.creditline_total_limit(p_chrv_rec.id);

      OKL_EXECUTE_FORMULA_PUB.execute(
      p_api_version   => l_api_version,
      p_init_msg_list => l_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_formula_name  => 'CONTRACT_TOT_CRDT_LMT',
      p_contract_id   => p_chrv_rec.id,
      x_value         => x_value);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        --RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        x_value := 0;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        --RAISE OKL_API.G_EXCEPTION_ERROR;
        x_value := 0;
      END IF;

      l_amount := x_value;

      -- check amount
      IF (l_amount = 0 ) THEN
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_AMOUNT_CHECK');
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

    RETURN l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;

  --------------------------------------------------------------------------
  ----- Validate currency code
  --------------------------------------------------------------------------
  FUNCTION validate_currency_code(
    p_chrv_rec     OKL_OKC_MIGRATION_PVT.chrv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy           VARCHAR2(1) := OKL_API.G_TRUE;
    l_currency_code   okc_k_headers_b.currency_code%TYPE;
    l_amount          OKL_K_LINES_FULL_V.AMOUNT%type;

  cursor c_old_curr
  is
  select khr.currency_code
  from okc_k_headers_b khr
  where khr.id = p_chrv_rec.id
  ;

  CURSOR c_limit_amt
  IS
  select nvl(sum(nvl(a.amount,0)),0)
  from OKL_K_LINES_FULL_V a
  where a.dnz_chr_id = p_chrv_rec.id
  ;

  BEGIN

  IF (p_mode = 'C') THEN
    IF (p_chrv_rec.currency_code IS NULL) OR
       (p_chrv_rec.currency_code = OKL_API.G_MISS_CHAR)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Currency Code');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  ELSE
    open c_old_curr;
    fetch c_old_curr into l_currency_code;
    close c_old_curr;

    open c_limit_amt;
    fetch c_limit_amt into l_amount;
    close c_limit_amt;

    -- check if no credit limit created then allow user to change the currency code
    -- message: You are not allow to change the currency if Total Credit Limit greater than 0
    IF l_amount > 0 AND l_currency_code <> p_chrv_rec.currency_code THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LA_CREDIT_CURRENCY_CHK');
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;
  END IF;

    RETURN l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
  --------------------------------------------------------------------------
  ----- Validate credit checklist template FK
  --------------------------------------------------------------------------
  FUNCTION validate_crd_chklst_tpl(
    p_rulv_rec    IN  rulv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy           VARCHAR2(1) := OKL_API.G_TRUE;
    l_dirty_row_found boolean;
    l_active_row_found boolean;

    l_credit_checklist_tpl okc_rules_b.rule_information1%TYPE;
    l_funding_checklist_tpl okc_rules_b.rule_information2%TYPE;
    l_checklists_row_found boolean;

--------------------------------------------------------------------------------------------
-- Checklists link check
--------------------------------------------------------------------------------------------
CURSOR c_checklists (p_chr_id  NUMBER)
  IS
  select rule.rule_information1,
         rule.rule_information2
  from okc_rules_b rule
  where rule.dnz_chr_id = p_chr_id
  and   rule.rule_information_category = G_CREDIT_CHKLST_TPL_RULE1
  ;

      --------------------------------------------------------------------
      --1.  read only if credit line checklist status is active
      --------------------------------------------------------------------
CURSOR c_checklist_active (p_chr_id okc_k_headers_b.id%type,
                         p_crd_chklst_id varchar2)
IS
  select 1
from  okc_rules_b rult
where rult.rule_information_category = G_CREDIT_CHKLST_TPL_RULE2--'LACCLD'
and   rult.dnz_chr_id = p_chr_id
and   rult.RULE_INFORMATION5 = 'ACTIVE'
and   exists (select null
              from   okc_rules_b rult1
              where  rult1.dnz_chr_id = rult.dnz_chr_id
              and    rult1.dnz_chr_id = p_chr_id -- impove performance
              and    rult1.rule_information_category = G_CREDIT_CHKLST_TPL_RULE1--'LACCLT'
              and    rult1.RULE_INFORMATION1 <> p_crd_chklst_id) -- id changes
;

      --------------------------------------------------------------------
      --2.  read only if credit line checklist have been touch by approver
      --------------------------------------------------------------------
CURSOR c_approver_dirty (p_chr_id okc_k_headers_b.id%type,
                         p_crd_chklst_id varchar2)
IS
  select 1
from  okc_rules_b rult
where rult.rule_information_category = G_CREDIT_CHKLST_TPL_RULE2--'LACCLD'
and   rult.dnz_chr_id = p_chr_id
and   rult.RULE_INFORMATION2 = 'Y' -- dirty bit check
and   exists (select null
              from   okc_k_headers_b khr
              where  khr.id = rult.dnz_chr_id
              and    khr.id = p_chr_id -- impove performance
              and    khr.sts_code = 'NEW')
and   exists (select null
              from   okc_rules_b rult1
              where  rult1.dnz_chr_id = rult.dnz_chr_id
              and    rult1.dnz_chr_id = p_chr_id -- impove performance
              and    rult1.rule_information_category = G_CREDIT_CHKLST_TPL_RULE1--'LACCLT'
              and    rult1.RULE_INFORMATION1 <> p_crd_chklst_id) -- id changes
;

  BEGIN

    IF (p_mode = 'U') THEN

      OPEN c_checklists(p_rulv_rec.dnz_chr_id);
      FETCH c_checklists INTO l_credit_checklist_tpl,
                              l_funding_checklist_tpl;
      l_checklists_row_found := c_checklists%FOUND;
      CLOSE c_checklists;

      --------------------------------------------------------------------
      --1.  read only if credit line checklist status is active
      --------------------------------------------------------------------
      OPEN c_checklist_active(p_rulv_rec.dnz_chr_id, p_rulv_rec.RULE_INFORMATION1);
      FETCH c_checklist_active INTO l_dummy;
      l_active_row_found := c_checklist_active%FOUND;
      CLOSE c_checklist_active;

      IF (l_credit_checklist_tpl IS NOT NULL and l_active_row_found) THEN
      -- You are not allow to change credit line checklist template if credit line checklist status is active.
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_CREDIT_CHKLST4');

        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      --------------------------------------------------------------------
      --2.  read only if credit line checklist have been touch by approver
      --------------------------------------------------------------------
      OPEN c_approver_dirty(p_rulv_rec.dnz_chr_id, p_rulv_rec.RULE_INFORMATION1);
      FETCH c_approver_dirty INTO l_dummy;
      l_dirty_row_found := c_approver_dirty%FOUND;
      CLOSE c_approver_dirty;

      IF (l_credit_checklist_tpl IS NOT NULL and l_dirty_row_found) THEN
    -- You are not allow to change credit line checklist template if credit line checklist mandatory flags have been check.
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_CREDIT_CHKLST2');

        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

    END IF;

    RETURN l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;

  --------------------------------------------------------------------------
  ----- Validate funding request checklist template FK
  --------------------------------------------------------------------------
  FUNCTION validate_fund_chklst_tpl(
    p_rulv_rec    IN  rulv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy           VARCHAR2(1) := OKL_API.G_TRUE;

    l_dirty_row_found boolean;
    l_active_row_found boolean;

    l_credit_checklist_tpl okc_rules_b.rule_information1%TYPE;

    l_funding_checklist_tpl okc_rules_b.rule_information2%TYPE;
    l_checklists_row_found boolean;

--------------------------------------------------------------------------------------------
-- Checklists link check
--------------------------------------------------------------------------------------------
CURSOR c_checklists (p_chr_id  NUMBER)
  IS
  select rule.rule_information1,
         rule.rule_information2
  from okc_rules_b rule
  where rule.dnz_chr_id = p_chr_id
  and   rule.rule_information_category = G_CREDIT_CHKLST_TPL_RULE1
  ;

      --------------------------------------------------------------------
      --1.  read only if funding requrest checklist template status is active
      --------------------------------------------------------------------
CURSOR c_checklist_active (p_chr_id okc_k_headers_b.id%type,
                         p_fund_chklst_id varchar2)
IS
  select 1
from  okc_rules_b rult
where rult.rule_information_category = G_CREDIT_CHKLST_TPL_RULE4--'LACLFM'
and   rult.dnz_chr_id = p_chr_id
and   rult.RULE_INFORMATION3 = 'ACTIVE'
and   exists (select null
              from   okc_rules_b rult1
              where  rult1.dnz_chr_id = rult.dnz_chr_id
              and    rult1.dnz_chr_id = p_chr_id -- impove performance
              and    rult1.rule_information_category = G_CREDIT_CHKLST_TPL_RULE1--'LACCLT'
              and    rult1.RULE_INFORMATION2 <> p_fund_chklst_id) -- id changes
;

      --------------------------------------------------------------------
      --2.  read only if funding requrest checklist template have been touch by approver
      --------------------------------------------------------------------
CURSOR c_approver_dirty (p_chr_id okc_k_headers_b.id%type,
                         p_fund_chklst_id varchar2)
IS
  select 1
from  okc_rules_b rult
where rult.rule_information_category = G_CREDIT_CHKLST_TPL_RULE3--'LACLFD'
and   rult.dnz_chr_id = p_chr_id
and   rult.RULE_INFORMATION2 = 'Y' -- dirty bit check
and   exists (select null
              from   okc_k_headers_b khr
              where  khr.id = rult.dnz_chr_id
              and    khr.id = p_chr_id -- impove performance
              and    khr.sts_code = 'NEW')
and   exists (select null
              from   okc_rules_b rult1
              where  rult1.dnz_chr_id = rult.dnz_chr_id
              and    rult1.dnz_chr_id = p_chr_id -- impove performance
              and    rult1.rule_information_category = G_CREDIT_CHKLST_TPL_RULE1--'LACCLT'
              and    rult1.RULE_INFORMATION2 <> p_fund_chklst_id) -- id changes
;


  BEGIN

    IF (p_mode = 'U') THEN

      OPEN c_checklists(p_rulv_rec.dnz_chr_id);
      FETCH c_checklists INTO l_credit_checklist_tpl,
                              l_funding_checklist_tpl;
      l_checklists_row_found := c_checklists%FOUND;
      CLOSE c_checklists;


      --------------------------------------------------------------------
      --1.  read only if funding requrest checklist template status is active
      --------------------------------------------------------------------
      OPEN c_checklist_active(p_rulv_rec.dnz_chr_id, p_rulv_rec.RULE_INFORMATION2);
      FETCH c_checklist_active INTO l_dummy;
      l_active_row_found := c_checklist_active%FOUND;
      CLOSE c_checklist_active;

      IF (l_funding_checklist_tpl IS NOT NULL and l_active_row_found) THEN
-- You are not allowed to change funding request checklist template if funding request checklist template status is Active.
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_FUND_CHKLST_CHECK8');

        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      --------------------------------------------------------------------
      --2.  read only if funding requrest checklist template have been touch by approver
      --------------------------------------------------------------------
      OPEN c_approver_dirty(p_rulv_rec.dnz_chr_id, p_rulv_rec.RULE_INFORMATION2);
      FETCH c_approver_dirty INTO l_dummy;
      l_dirty_row_found := c_approver_dirty%FOUND;
      CLOSE c_approver_dirty;

      IF (l_funding_checklist_tpl IS NOT NULL and l_dirty_row_found) THEN
--You are not allowed to change credit line checklist template if credit line checklist mandatory flags have been check.
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LLA_FUND_CHKLST_CHECK9');

        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

    END IF;

    RETURN l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
  --------------------------------------------------------------------------
  FUNCTION validate_header_attributes(
    p_chrv_rec     OKL_OKC_MIGRATION_PVT.chrv_rec_type
    ,p_khrv_rec    OKL_CONTRACT_PUB.khrv_rec_type
    ,p_rulv_rec    okl_rule_pub.rulv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    -- Do formal attribute validation:
    l_return_status := validate_credit_number(p_chrv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_description(p_chrv_rec);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_start_date(p_chrv_rec,p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_end_date(p_chrv_rec,p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_start_end_date(p_chrv_rec,p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_credit_amount(p_chrv_rec);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

-- multi-currency support

    l_return_status := validate_currency_code(p_chrv_rec,p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN

      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
-- funding checklist for 11.5.9.x

    l_return_status := validate_credit_checklist(p_chrv_rec,p_rulv_rec,p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

-- funding checklist for 11.5.9.x

    RETURN x_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN x_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END validate_header_attributes;

  --------------------------------------------------------------------------
  FUNCTION validate_status_is_active(
    p_chrv_rec     OKL_OKC_MIGRATION_PVT.chrv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    l_return_status := validate_description(p_chrv_rec);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_end_date(p_chrv_rec,p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_start_end_date(p_chrv_rec,p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    RETURN x_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN x_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END validate_status_is_active;

  --------------------------------------------------------------------------
  --------------------------------------------------------------------------
  ----- Validate customer name
  --------------------------------------------------------------------------
  FUNCTION validate_customer(
    p_cplv_rec OKC_CONTRACT_PARTY_PUB.cplv_rec_type
    ,p_customer_name VARCHAR2
  ) RETURN VARCHAR2
  IS

    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_existing_status   VARCHAR2(1) := '?';

  CURSOR c (p_customer_name  VARCHAR2)
  IS
  select 'X'
  from okx_parties_v a
  where a.name = p_customer_name
  ;

  BEGIN

-- start: cklee 03/24/2004
    IF (p_cplv_rec.object1_id1 IS NULL) OR
       (p_cplv_rec.object1_id1 = OKL_API.G_MISS_CHAR)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'object1_id1');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF (p_cplv_rec.object1_id2 IS NULL) OR
       (p_cplv_rec.object1_id2 = OKL_API.G_MISS_CHAR)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'object1_id2');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF (p_cplv_rec.jtot_object1_code IS NULL) OR
       (p_cplv_rec.jtot_object1_code = OKL_API.G_MISS_CHAR)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'jtot_object1_code');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
-- end: cklee 03/24/2004


    IF (p_customer_name IS NULL) OR
       (p_customer_name = OKL_API.G_MISS_CHAR)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Customer Name');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN c(p_customer_name);
    FETCH c INTO l_existing_status;
    CLOSE c;

    IF (l_existing_status = '?' ) THEN

        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_NO_DATA_FOUND',
                          p_token1       => 'COL_NAME',
                          p_token1_value => 'Customer Name ' || p_customer_name);
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    RETURN l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
  --------------------------------------------------------------------------
  ----- Validate customer acct number
  --------------------------------------------------------------------------
  FUNCTION validate_account_number(
    p_cust_acct_id     IN NUMBER,
    p_cust_acct_number IN VARCHAR2
  ) RETURN VARCHAR2
  IS

    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cust_acct_id number;
    l_notfound boolean;

  CURSOR c_acct(p_cust_acct_id      number)
  IS
  select a.id1
  from okx_customer_accounts_v a
  where a.id1 = p_cust_acct_id
  ;

  CURSOR c_acct_num(p_cust_acct_number  VARCHAR2)
  IS
  select a.id1
  from okx_customer_accounts_v a
  where a.description = p_cust_acct_number
  ;

  BEGIN

    -- customer account # is not required
    IF (p_cust_acct_number IS NOT NULL AND
        p_cust_acct_number <> OKL_API.G_MISS_CHAR)
    THEN

      OPEN c_acct_num(p_cust_acct_number);
      FETCH c_acct_num INTO l_cust_acct_id;
      l_notfound := c_acct_num%NOTFOUND;
      CLOSE c_acct_num;

      IF (l_notfound) THEN

        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_NO_DATA_FOUND',
                          p_token1       => 'COL_NAME',
                          p_token1_value => 'Customer Account '|| p_cust_acct_number);
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

    END IF;

    -- customer account # is not required
    IF (p_cust_acct_id IS NOT NULL AND
        p_cust_acct_id <> OKL_API.G_MISS_NUM)
    THEN

      OPEN c_acct(p_cust_acct_id);
      FETCH c_acct INTO l_cust_acct_id;
      l_notfound := c_acct%NOTFOUND;
      CLOSE c_acct;

      IF (l_notfound) THEN

        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_NO_DATA_FOUND',
                          p_token1       => 'COL_NAME',
                          p_token1_value => 'cust_acct_id '|| p_cust_acct_id);
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

    END IF;

    RETURN l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);

      RETURN l_return_status;
  END;
 --------------------------------------------------------------------------
  --------------------------------------------------------------------------
  FUNCTION validate_chklst_tpl(
    p_rulv_rec    IN  rulv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    -- Do formal attribute validation:
    l_return_status := validate_crd_chklst_tpl(p_rulv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- Do formal attribute validation:
    l_return_status := validate_fund_chklst_tpl(p_rulv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    RETURN x_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN x_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END validate_chklst_tpl;
----------------------------------------------------------------------------------
  PROCEDURE validate_credit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_contract_number              IN  VARCHAR2,
    p_description                  IN  VARCHAR2,
    p_customer_id1                 IN  VARCHAR2,
    p_customer_id2                 IN  VARCHAR2,
    p_customer_code                IN  VARCHAR2,
    p_customer_name                IN  VARCHAR2,
    p_effective_from               IN  DATE,
    p_effective_to                 IN  DATE,
    p_currency_code                IN  VARCHAR2,
-- multi-currency support
    p_currency_conv_type           IN  VARCHAR2,
    p_currency_conv_rate           IN  NUMBER,
    p_currency_conv_date           IN  DATE,
-- multi-currency support
-- funding checklist enhancement
    p_credit_ckl_id                IN  NUMBER,
    p_funding_ckl_id               IN  NUMBER,
-- funding checklist enhancement
    p_cust_acct_id                 IN  NUMBER, -- 11.5.10 rule migration project
    p_cust_acct_number             IN  VARCHAR2, -- 11.5.10 rule migration project
    p_sts_code                     IN  VARCHAR2)

  AS
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_api_name	VARCHAR2(30) := 'VALIDATE_CREDIT';
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    l_khrv_rec    OKL_CONTRACT_PUB.khrv_rec_type;

    lp_cplv_rec OKC_CONTRACT_PARTY_PUB.cplv_rec_type;

    l_sts_code  OKC_K_HEADERS_B.STS_CODE%TYPE;


-- funding checklist enhancement for 11.5.9
  lp_rulv_rec        rulv_rec_type;
  lx_rulv_rec        rulv_rec_type;
-- funding checklist enhancement for 11.5.9

  Cursor c_sts_code (p_chr_id NUMBER) is
select sts_code
from   okc_k_headers_b
where  id = p_chr_id
;

  BEGIN

    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,

			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- get sts_code from database
    OPEN c_sts_code(p_chr_id);
    FETCH c_sts_code INTO l_sts_code;
    CLOSE c_sts_code;


    l_chrv_rec.id := p_chr_id;
    l_chrv_rec.contract_number := p_contract_number;
    l_chrv_rec.description := p_description;

    l_chrv_rec.start_date := p_effective_from;
    l_chrv_rec.end_date := p_effective_to;
    l_chrv_rec.sts_code := p_sts_code;
--    l_chrv_rec.revolving_credit_yn := p_revolving_credit_yn;
    l_chrv_rec.currency_code := p_currency_code;

-- multi-currency support
    l_khrv_rec.currency_conversion_type := p_currency_conv_type;
    l_khrv_rec.currency_conversion_rate := p_currency_conv_rate;
    l_khrv_rec.currency_conversion_date := p_currency_conv_date;
-- multi-currency support

-- funding checklist enhancement
--
-- Credit header checklist template
--

    -- rule FKs
    lp_rulv_rec.DNZ_CHR_ID := p_chr_id;
    lp_rulv_rec.RULE_INFORMATION1 := p_credit_ckl_id;
    lp_rulv_rec.RULE_INFORMATION2 := p_funding_ckl_id;

    x_return_status := validate_chklst_tpl(lp_rulv_rec, 'U');
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

--
-- funding checklist enhancement

    IF (l_sts_code = 'ACTIVE')THEN -- check if status already active

      x_return_status := validate_status_is_active(l_chrv_rec, 'U');
      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      End If;

    ELSE -- check include status become active

      x_return_status := validate_header_attributes(l_chrv_rec, l_khrv_rec, lp_rulv_rec, 'U');
      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      End If;

-- 11.5.10 rule migration start
      x_return_status := validate_account_number(p_cust_acct_id     => p_cust_acct_id,
                                                 p_cust_acct_number => p_cust_acct_number);
      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      End If;
-- 11.5.10 rule migration end

    END IF;

    -- validate customer name only
    lp_cplv_rec.dnz_chr_id := p_chr_id;
    lp_cplv_rec.chr_id := p_chr_id;
    lp_cplv_rec.cle_id := null;
    lp_cplv_rec.object1_id1 := p_customer_id1;
    lp_cplv_rec.object1_id2 := p_customer_id2;
    lp_cplv_rec.jtot_object1_code := p_customer_code;
    lp_cplv_rec.rle_code := G_RLE_CODE;

    IF (l_sts_code <> 'ACTIVE')THEN
      x_return_status := validate_customer(lp_cplv_rec, p_customer_name);
      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      End If;
    END IF;

    x_return_status := l_return_status;

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,

			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END validate_credit;
  --------------------------------------------------------------------------

  PROCEDURE validate_account_number(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_account_number               IN  VARCHAR2)
  AS
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_api_name	VARCHAR2(30) := 'VALIDATE_ACCOUNT';
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

      x_return_status := validate_account_number(p_cust_acct_id     => NULL,
                                                 p_cust_acct_number => p_account_number);
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    x_return_status := l_return_status;

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END validate_account_number;

  --------------------------------------------------------------------------
  FUNCTION validate_line_attributes(
    p_mode                         IN  VARCHAR2,
    p_clev_rec                     IN  okl_okc_migration_pvt.clev_rec_type,
    p_klev_rec                     IN  klev_rec_type
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    -- Do formal attribute validation:
    IF (upper(p_mode) <> 'DELETE') THEN
      l_return_status := validate_start_date(p_clev_rec,p_klev_rec);
      --- Store the highest degree of error
      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
        END IF;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

    END IF;

    l_return_status := validate_amount(p_clev_rec, p_klev_rec);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

--un-comment by cklee 03/24/2004
    IF (upper(p_mode) = 'CREATE') THEN
      l_return_status := validate_credit_nature(p_clev_rec, p_klev_rec);
      --- Store the highest degree of error
      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
        END IF;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

    RETURN x_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN x_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);

      RETURN l_return_status;
  END validate_line_attributes;

  --------------------------------------------------------------------------
  PROCEDURE validate_credit_limit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mode                         IN  VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_cle_id                       IN  NUMBER,
    p_cle_start_date               IN  DATE,
    p_description                  IN  VARCHAR2,
    p_credit_nature                IN  VARCHAR2,
    p_amount                       IN  NUMBER)
  AS
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_api_name	VARCHAR2(30) := 'VALIDATE_CREDIT_LIMIT';
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_clev_rec OKL_OKC_MIGRATION_PVT.clev_rec_type;
    l_klev_rec OKL_CONTRACT_PVT.klev_rec_type;

  BEGIN
    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    l_clev_rec.id := p_cle_id;
    l_clev_rec.dnz_chr_id := p_chr_id;
    l_clev_rec.start_date := p_cle_start_date;
    l_clev_rec.item_description := p_description;
    l_klev_rec.amount := p_amount;
    l_klev_rec.credit_nature := p_credit_nature;

    -- Do formal attribute validation:
    x_return_status := validate_start_date(l_clev_rec,l_klev_rec);
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    x_return_status := validate_amount(l_clev_rec,l_klev_rec);
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    x_return_status := l_return_status;

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END validate_credit_limit;
  --------------------------------------------------------------------------
  PROCEDURE validate_credit_limit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mode                         IN  VARCHAR2,
    p_clev_rec                     IN  okl_okc_migration_pvt.clev_rec_type,
    p_klev_rec                     IN  klev_rec_type)
  AS
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_api_name	VARCHAR2(30) := 'VALIDATE_CREDIT_LIMIT1';
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN
    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    x_return_status := l_return_status;

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,

			p_api_type  => g_api_type);
  END validate_credit_limit;
  --------------------------------------------------------------------------
  PROCEDURE validate_credit_limit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mode                         IN  VARCHAR2,
    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type)
  AS
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_api_name	VARCHAR2(30) := 'VALIDATE_CREDIT_LIMIT2';
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_clev_tbl                 okl_okc_migration_pvt.clev_tbl_type := p_clev_tbl;
    l_klev_tbl                 klev_tbl_type := p_klev_tbl;
    i                          NUMBER;

  BEGIN

    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    IF (p_clev_tbl.COUNT > 0) THEN
      i := p_clev_tbl.FIRST;
      LOOP

        x_return_status := validate_line_attributes(p_mode, p_clev_tbl(i),p_klev_tbl(i));
        -- check if activity started successfully
        If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
          raise OKC_API.G_EXCEPTION_ERROR;
        End If;

        EXIT WHEN (i = p_clev_tbl.LAST);
        i := p_clev_tbl.NEXT(i);
      END LOOP;
    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END validate_credit_limit;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_credit_header
-- Description     : wrapper api for credit_credit
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
   PROCEDURE create_credit_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
-- funding checklist enhancement
    p_credit_ckl_id                IN  NUMBER,
    p_funding_ckl_id               IN  NUMBER,
-- funding checklist enhancement
    p_chrv_rec                     IN  okl_okc_migration_pvt.chrv_rec_type,
    p_khrv_rec                     IN  khrv_rec_type,
    x_chrv_rec                     OUT NOCOPY okl_okc_migration_pvt.chrv_rec_type,
    x_khrv_rec                     OUT NOCOPY khrv_rec_type)
is
  l_api_name         CONSTANT VARCHAR2(30) := 'create_credit_header_pub';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    lp_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lx_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lp_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
    lx_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;

begin
  -- Set API savepoint
  SAVEPOINT create_credit_header_pub;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;

	END IF;


  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/
/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO create_credit_header_pub;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_credit_header_pub;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO create_credit_header_pub;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_credit_header
-- Description     : wrapper api for update_contract_header
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE update_credit_header(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update            IN  VARCHAR2,
-- funding checklist enhancement
    p_chklst_tpl_rgp_id            IN  NUMBER, -- LACCLH
    p_chklst_tpl_rule_id           IN  NUMBER, -- LACCLT
    p_credit_ckl_id                IN  NUMBER,
    p_funding_ckl_id               IN  NUMBER,
-- funding checklist enhancement
    p_chrv_rec                     IN  okl_okc_migration_pvt.chrv_rec_type,
    p_khrv_rec                     IN  khrv_rec_type,
    x_chrv_rec                     OUT NOCOPY okl_okc_migration_pvt.chrv_rec_type,
    x_khrv_rec                     OUT NOCOPY khrv_rec_type)
is

-- vthiruva Code change to enable Business Event START
  CURSOR c_old_sts_code(p_chr_id okc_k_headers_b.id%TYPE) IS
  SELECT sts_code
  FROM okc_k_headers_b
  WHERE id = p_chr_id;

  l_old_status       okc_k_headers_b.sts_code%TYPE;
-- vthiruva Code change to enable Business Event END

  l_api_name         CONSTANT VARCHAR2(30) := 'update_credit_header_pub';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

-- multi-currency support
  lp_chrv_rec        okl_okc_migration_pvt.chrv_rec_type := p_chrv_rec;
  lp_khrv_rec        khrv_rec_type := p_khrv_rec;
-- multi-currency support

-- funding checklist enhancement for 11.5.9
  lp_rulv_rec        rulv_rec_type;
  lx_rulv_rec        rulv_rec_type;
-- funding checklist enhancement for 11.5.9

-- strat: bug#4218700
  l_cust_acct_id number;

  cursor l_cust_acct(p_chr_id number) is
    select chrb.cust_acct_id cust_acct_id
 from OKC_K_HEADERS_B CHRB
 where CHRB.id = p_chr_id;

-- end: bug#4218700

-- start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
  l_approval_option varchar2(10);
-- end: 06-May-2005  cklee okl.h Lease App IA Authoring                            |

begin
  -- Set API savepoint
  SAVEPOINT update_credit_header_pub;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success

  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/
    -- vthiruva Code change to enable Business Event START
    OPEN c_old_sts_code(lp_chrv_rec.id);
    FETCH c_old_sts_code INTO l_old_status;
    CLOSE c_old_sts_code;
    -- vthiruva Code change to enable Business Event END

-- strat: bug#4218700
    IF lp_chrv_rec.sts_code = 'ACTIVE' THEN

      open l_cust_acct(lp_chrv_rec.id);
      fetch l_cust_acct into l_cust_acct_id;
      close l_cust_acct;

      lp_chrv_rec.cust_acct_id := l_cust_acct_id;

    END IF;
-- end: bug#4218700

-- start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
    ------------------------------------------------------------------
    -- added for approval process
    ------------------------------------------------------------------
    l_approval_option := fnd_profile.value('OKL_CREDIT_LINE_APPROVAL_PROCESS');
    IF (lp_chrv_rec.sts_code = 'SUBMITTED' AND
-- start: cklee 07/13/2005
        (l_approval_option is null or l_approval_option = 'NONE')) THEN
--        l_approval_option not in ('WF', 'AME')) THEN
-- end: cklee 07/13/2005

      -- update item function validation results
      update_checklist_function(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_contract_id    => lp_chrv_rec.id);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      End If;

--      lp_chrv_rec.sts_code := 'APPROVED';
      lp_chrv_rec.sts_code := 'ACTIVE'; -- update to Active directly w/o WF implementation
      lp_chrv_rec.DATE_APPROVED := sysdate;

    END IF;
-- end: 06-May-2005  cklee okl.h Lease App IA Authoring                            |

--dbms_output.put_line('1: before OKL_CONTRACT_PUB.update_contract_header');

    OKL_CONTRACT_PUB.update_contract_header(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_chrv_rec       => lp_chrv_rec,
      p_khrv_rec       => lp_khrv_rec,
      x_chrv_rec       => x_chrv_rec,
      x_khrv_rec       => x_khrv_rec);

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

--dbms_output.put_line('2: after OKL_CONTRACT_PUB.update_contract_header');

-- funding checklist enhancement for 11.5.9

    IF lp_chrv_rec.sts_code = 'NEW' THEN
      -- rule FKs
      lp_rulv_rec.RGP_ID := p_chklst_tpl_rgp_id; -- reference purpose
      lp_rulv_rec.DNZ_CHR_ID := lp_chrv_rec.id; -- reference purpose
      lp_rulv_rec.ID := p_chklst_tpl_rule_id; -- MUST 'LACCLT'
      lp_rulv_rec.RULE_INFORMATION1 := p_credit_ckl_id;
      lp_rulv_rec.RULE_INFORMATION2 := p_funding_ckl_id;

--dbms_output.put_line('3: before update_credit_chklst_tpl');

      update_credit_chklst_tpl(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rulv_rec       => lp_rulv_rec,
        x_rulv_rec       => lx_rulv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      End If;

    END IF;
--dbms_output.put_line('4: after update_credit_chklst_tpl');


-- funding checklist enhancement for 11.5.9

   /*
   -- vthiruva, 08/31/2004
   -- START, Code change to enable Business Event
   */
-- start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
    IF(l_old_status IN ('NEW', 'SUBMITTED', 'PENDING_APPROVAL') AND lp_chrv_rec.sts_code = 'ACTIVE')THEN
-- end: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
    --raise business event for activate credit line
    --if sts_code is ACTIVE and old status is NEW
    	raise_business_event(p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
			     x_return_status  => x_return_status,
			     x_msg_count      => x_msg_count,
			     x_msg_data       => x_msg_data,
			     p_id             => lp_chrv_rec.id,
			     p_event_name     => G_WF_EVT_CR_LN_ACTIVATED);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    ELSE
    --raise business event for credit line update
    	raise_business_event(p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
			     x_return_status  => x_return_status,
			     x_msg_count      => x_msg_count,
			     x_msg_data       => x_msg_data,
			     p_id             => lp_chrv_rec.id,
			     p_event_name     => G_WF_EVT_CR_LN_UPDATED);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    END IF;

   /*
   -- vthiruva, 08/31/2004
   -- END, Code change to enable Business Event
   */

-- start: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
    -----------------------------------------------------------
    -- trigger WF event if l_tapv_rec.trx_status_code = 'SUBMITTED' and
    -- profile option is WF or AME
    -----------------------------------------------------------
    IF (lp_chrv_rec.sts_code = 'SUBMITTED' AND
        l_approval_option in ('WF', 'AME')) THEN
--dbms_output.put_line('5: OKL_CREDIT_LINE_WF.raise_approval_event');

      -- update item function validation results
      update_checklist_function(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_contract_id    => lp_chrv_rec.id);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      End If;

      OKL_CREDIT_LINE_WF.raise_approval_event(
                           p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_contract_id   => lp_chrv_rec.id);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;
-- end: 06-May-2005  cklee okl.h Lease App IA Authoring                            |
--dbms_output.put_line('6: OKL_CREDIT_LINE_WF.raise_approval_event');


/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_credit_header_pub;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);


  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_credit_header_pub;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO update_credit_header_pub;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end;
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : copy_clev_rec
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE copy_clev_rec(
    p_clev_rec                     IN  clev_rec_type,
    p_clev_migr_rec                OUT NOCOPY okl_okc_migration_pvt.clev_rec_type)
is
begin
    p_clev_migr_rec.id := p_clev_rec.id;
    p_clev_migr_rec.dnz_chr_id := p_clev_rec.dnz_chr_id;
    p_clev_migr_rec.chr_id := p_clev_rec.chr_id;
--    p_clev_migr_rec.credit_nature := p_clev_rec.credit_nature;
    p_clev_migr_rec.lse_id := p_clev_rec.lse_id;
    p_clev_migr_rec.line_number := p_clev_rec.line_number;
    p_clev_migr_rec.sts_code := p_clev_rec.sts_code;
    p_clev_migr_rec.display_sequence := p_clev_rec.display_sequence;
    p_clev_migr_rec.exception_yn := p_clev_rec.exception_yn;
    p_clev_migr_rec.start_date := p_clev_rec.start_date;
    p_clev_migr_rec.item_description := p_clev_rec.item_description;
--    popRecKlev.amount := new BigDecimal(sAmt);
end;
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : copy_clev_tbl
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE copy_clev_tbl(
    p_clev_tbl                     IN  clev_tbl_type,
    p_clev_migr_tbl                OUT NOCOPY okl_okc_migration_pvt.clev_tbl_type)
is
  i number;
begin

    IF (p_clev_tbl.COUNT > 0) THEN
      i := p_clev_tbl.FIRST;
      LOOP

        copy_clev_rec(
          p_clev_rec       => p_clev_tbl(i),
          p_clev_migr_rec  => p_clev_migr_tbl(i)
        );

        EXIT WHEN (i = p_clev_tbl.LAST);
        i := p_clev_tbl.NEXT(i);
      END LOOP;
    END IF;

end;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : copy_clmv_rec
-- Description     : copy from clmv_rec to x_clev_rec and x_klev_rec
--                   and set default attributes
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE copy_clmv_rec(
    p_chr_id             IN  NUMBER,
    p_clmv_rec           IN  clmv_rec_type,
    x_clev_rec           OUT NOCOPY clev_rec_type,
    x_klev_rec           OUT NOCOPY klev_rec_type)
is

  l_lse_id number;

  cursor c_lse_id is
select lse.id
from  okc_line_styles_b lse,
      okc_subclass_top_line sctl
where lse.lty_code = 'FREE_FORM'
and   sctl.lse_id = lse.id
and   sctl.scs_code = 'CREDITLINE_CONTRACT';


begin

    -------------------------------------------
    -- get lse_id
    -------------------------------------------
    open c_lse_id;
    Fetch c_lse_id into l_lse_id;
    close c_lse_id;

    -------------------------------------------
    -- assign ID
    -------------------------------------------
    x_clev_rec.id := NULLIF(p_clmv_rec.id, OKC_API.G_MISS_NUM);
    x_klev_rec.id := NULLIF(p_clmv_rec.id, OKC_API.G_MISS_NUM);

    x_clev_rec.dnz_chr_id := p_chr_id;
    x_clev_rec.chr_id := p_chr_id;

-- set default?
    x_clev_rec.lse_id := l_lse_id;
    x_clev_rec.line_number := '1';
    x_clev_rec.display_sequence := 1;
    x_clev_rec.sts_code := 'ENTERED';
    x_clev_rec.exception_yn := 'N';

    -------------------------------------------
    -- assign okc_k_lines_v
    -------------------------------------------
    x_clev_rec.start_date := NULLIF(p_clmv_rec.start_date, OKC_API.G_MISS_DATE);
    x_clev_rec.item_description := NULLIF(p_clmv_rec.item_description, OKC_API.G_MISS_CHAR);
    -------------------------------------------
    -- assign okl_k_lines
    -------------------------------------------
    x_klev_rec.credit_nature := NULLIF(p_clmv_rec.credit_nature, OKC_API.G_MISS_CHAR);
    x_klev_rec.amount := NULLIF(p_clmv_rec.amount, OKC_API.G_MISS_NUM);

exception
  when others then
    if c_lse_id%isopen then
      close c_lse_id;
    end if;

end;
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : copy_clmv_tbl
-- Description     : copy from clmv_tbl to x_clev_tbl and x_klev_tbl
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE copy_clmv_tbl(
    p_chr_id             IN  NUMBER,
    p_clmv_tbl           IN  clmv_tbl_type,
    x_clev_tbl           OUT NOCOPY clev_tbl_type,
    x_klev_tbl           OUT NOCOPY klev_tbl_type)
is
  i number;
begin

    IF (p_clmv_tbl.COUNT > 0) THEN
      i := p_clmv_tbl.FIRST;
      LOOP

        copy_clmv_rec(
          p_chr_id    => p_chr_id,
          p_clmv_rec  => p_clmv_tbl(i),
          x_clev_rec  => x_clev_tbl(i),
          x_klev_rec  => x_klev_tbl(i)
        );

        EXIT WHEN (i = p_clmv_tbl.LAST);
        i := p_clmv_tbl.NEXT(i);
      END LOOP;
    END IF;

end;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_credit_limit
-- Description     : wrapper api for create_contract_line
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE create_credit_limit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
--    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_clev_tbl                     IN  clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type,
--    x_clev_tbl                     OUT NOCOPY okl_okc_migration_pvt.clev_tbl_type,
    x_clev_tbl                     OUT NOCOPY clev_tbl_type,
    x_klev_tbl                     OUT NOCOPY klev_tbl_type)
is
  l_api_name         CONSTANT VARCHAR2(30) := 'create_credit_limit_pub';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_clev_tbl         okl_okc_migration_pvt.clev_tbl_type;
  lx_clev_tbl         okl_okc_migration_pvt.clev_tbl_type;

begin
  -- Set API savepoint
  SAVEPOINT create_credit_limit_pub;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

--DBMS_OUTPUT.PUT_LINE('before copy_clev_tbl');

    copy_clev_tbl(
          p_clev_tbl      => p_clev_tbl,
          p_clev_migr_tbl => lp_clev_tbl
    );

--DBMS_OUTPUT.PUT_LINE('after copy_clev_tbl');
    validate_credit_limit(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_mode           => G_CREATE_MODE,
      p_clev_tbl       => lp_clev_tbl,
      p_klev_tbl       => p_klev_tbl);

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;


    OKL_CONTRACT_PUB.create_contract_line(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_clev_tbl       => lp_clev_tbl,
      p_klev_tbl       => p_klev_tbl,
      x_clev_tbl       => lx_clev_tbl,
      x_klev_tbl       => x_klev_tbl);

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

-- check after record created
    x_return_status := validate_credit_limit_after(
                       p_chr_id       => lp_clev_tbl(lp_clev_tbl.FIRST).dnz_chr_id
                       ,p_mode         => 'NEW');

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
--    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
--       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO create_credit_limit_pub;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_credit_limit_pub;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO create_credit_limit_pub;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end;
-- rabhupat bug 4435390 start (cklee okl.h Bug 4506351 (okl.g bug#4435390))
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : is_updated
-- Description     : check if the text fields are updated
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
FUNCTION is_updated(p_old_val   IN  VARCHAR2,
                    p_new_val   IN  VARCHAR2) RETURN BOOLEAN IS
  l_return_val BOOLEAN;
BEGIN
   l_return_val := FALSE;
   -- if the value in the database is NULL and the value passed from UI is not null
   IF(p_old_val IS NULL AND (p_new_val IS NOT NULL AND p_new_val <> OKL_API.G_MISS_CHAR)) THEN
      l_return_val := TRUE;
   -- if the value in the database is not null and the value passed from UI is NULL
   ELSIF(p_old_val IS NOT NULL AND (p_new_val IS NULL OR p_new_val = OKL_API.G_MISS_CHAR)) THEN
      l_return_val := TRUE;
   -- if the value in the database and the value passed from the database are not null and not equal
   ELSIF(p_old_val IS NOT NULL AND (p_new_val IS NOT NULL AND p_new_val <> OKL_API.G_MISS_CHAR)) THEN
     IF(p_old_val <> p_new_val) THEN
      l_return_val := TRUE;
     END IF;
   END IF;

   RETURN l_return_val;

END is_updated;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : is_updated
-- Description     : check if the number fields are updated
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
FUNCTION is_updated(p_old_val   IN  NUMBER,
                    p_new_val   IN  NUMBER) RETURN BOOLEAN IS
  l_return_val BOOLEAN;
BEGIN
   l_return_val := FALSE;
   -- if the value in the database is NULL and the value passed from UI is not null
   IF(p_old_val IS NULL AND (p_new_val IS NOT NULL AND p_new_val <> OKL_API.G_MISS_NUM)) THEN
      l_return_val := TRUE;
   -- if the value in the database is not null and the value passed from UI is NULL
   ELSIF(p_old_val IS NOT NULL AND (p_new_val IS NULL OR p_new_val = OKL_API.G_MISS_NUM)) THEN
      l_return_val := TRUE;
   -- if the value in the database and the value passed from the database are not null and not equal
   ELSIF(p_old_val IS NOT NULL AND (p_new_val IS NOT NULL AND p_new_val <> OKL_API.G_MISS_NUM)) THEN
     IF(p_old_val <> p_new_val) THEN
        l_return_val := TRUE;
     END IF;
   END IF;

   RETURN l_return_val;

END is_updated;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : is_updated
-- Description     : check if the date fields are updated
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
FUNCTION is_updated(p_old_val   IN  DATE,
                    p_new_val   IN  DATE) RETURN BOOLEAN IS
  l_return_val BOOLEAN;
BEGIN
   l_return_val := FALSE;
   -- if the value in the database is NULL and the value passed from UI is not null
   IF(p_old_val IS NULL AND (p_new_val IS NOT NULL AND p_new_val <> OKL_API.G_MISS_DATE)) THEN
      l_return_val := TRUE;
   -- if the value in the database is not null and the value passed from UI is NULL
   ELSIF(p_old_val IS NOT NULL AND (p_new_val IS NULL OR p_new_val = OKL_API.G_MISS_DATE)) THEN
      l_return_val := TRUE;
   -- if the value in the database and the value passed from the database are not null and not equal
   ELSIF(p_old_val IS NOT NULL AND (p_new_val IS NOT NULL AND p_new_val <> OKL_API.G_MISS_DATE)) THEN
     IF(p_old_val <> p_new_val) THEN
        l_return_val := TRUE;
     END IF;
   END IF;

   RETURN l_return_val;

END is_updated;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_credit_limit
-- Description     : check if the record is actually updated or not
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
FUNCTION is_credit_limit_updated(p_clev_rec  IN   clev_rec_type,
                                 p_klev_rec  IN   klev_rec_type) RETURN BOOLEAN IS
  -- cursor to fetch the okc_k_lines fields which are updatable by user
  CURSOR c_clev_csr IS
    SELECT ITEM_DESCRIPTION,
           START_DATE
    FROM OKC_K_LINES_V
    WHERE ID = p_clev_rec.ID;
  -- cursor to fetch the okl_k_lines fields which are updatable by user
  CURSOR c_klev_csr IS
    SELECT AMOUNT,
           CREDIT_NATURE
    FROM OKL_K_LINES_V
    WHERE ID =  p_clev_rec.ID;

  l_return_val BOOLEAN;

BEGIN

    l_return_val := FALSE;
    -- fetch the okc_k_lines fields for the credit limit record
    FOR l_clev_csr_rec IN c_clev_csr
    LOOP
       -- if start date or item description is updated then return true
       IF((is_updated(l_clev_csr_rec.ITEM_DESCRIPTION, p_clev_rec.ITEM_DESCRIPTION)) OR
          (is_updated(l_clev_csr_rec.START_DATE, p_clev_rec.START_DATE))) THEN
          l_return_val := TRUE;
       END IF;
    END LOOP;
    -- fetch the okl_k_lines fields for the credit limit record
    FOR l_klev_csr_rec IN c_klev_csr
    LOOP
       -- if amount or credit nature is updated then return true
       IF((is_updated(l_klev_csr_rec.AMOUNT, p_klev_rec.AMOUNT)) OR
          (is_updated(l_klev_csr_rec.CREDIT_NATURE, p_klev_rec.CREDIT_NATURE))) THEN
          l_return_val := TRUE;
       END IF;
    END LOOP;

    RETURN l_return_val;

END is_credit_limit_updated;
-- rabhupat bug 4435390 end (cklee okl.h Bug 4506351 (okl.g bug#4435390))

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_credit_limit
-- Description     : wrapper api for update_contract_line
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE update_credit_limit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
--    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_clev_tbl                     IN  clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type,
--    x_clev_tbl                     OUT NOCOPY okl_okc_migration_pvt.clev_tbl_type,
    x_clev_tbl                     OUT NOCOPY clev_tbl_type,
    x_klev_tbl                     OUT NOCOPY klev_tbl_type)
is
  l_api_name         CONSTANT VARCHAR2(30) := 'update_credit_limit_pub';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_clev_tbl         okl_okc_migration_pvt.clev_tbl_type;
  lx_clev_tbl         okl_okc_migration_pvt.clev_tbl_type;

  -- rabhupat bug 4435390 start (cklee okl.h Bug 4506351 (okl.g bug#4435390))
  l_overall_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  -- rabhupat bug 4435390 end (cklee okl.h Bug 4506351 (okl.g bug#4435390))

begin
  -- Set API savepoint
  SAVEPOINT update_credit_limit_pub;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

    copy_clev_tbl(
          p_clev_tbl      => p_clev_tbl,
          p_clev_migr_tbl => lp_clev_tbl
    );

    validate_credit_limit(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_mode           => G_UPDATE_MODE,
      p_clev_tbl       => lp_clev_tbl,
      p_klev_tbl       => p_klev_tbl);

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;
/*comment out: cklee okl.h Bug 4506351 (okl.g bug#4435390)

    OKL_CONTRACT_PUB.update_contract_line(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_clev_tbl       => lp_clev_tbl,
      p_klev_tbl       => p_klev_tbl,
      x_clev_tbl       => lx_clev_tbl,
      x_klev_tbl       => x_klev_tbl);
*/
    -- rabhupat bug 4435390 start (cklee okl.h Bug 4506351 (okl.g bug#4435390))
    IF(p_clev_tbl.COUNT > 0) THEN
      i := p_clev_tbl.FIRST;
      LOOP
        -- check if the credit limit record is actually updated. Then only pass
        -- it to the update api
        IF(is_credit_limit_updated(p_clev_tbl(i),p_klev_tbl(i)))THEN
            OKL_CONTRACT_PUB.update_contract_line(
              p_api_version    => p_api_version,
              p_init_msg_list  => p_init_msg_list,
              x_return_status  => x_return_status,
              x_msg_count      => x_msg_count,
              x_msg_data       => x_msg_data,
              p_clev_rec       => lp_clev_tbl(i),
              p_klev_rec       => p_klev_tbl(i),
              x_clev_rec       => lx_clev_tbl(i),
              x_klev_rec       => x_klev_tbl(i));
		  If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
		     If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
			   l_overall_status := x_return_status;
		     End If;
		  End If;
        END IF;
        EXIT WHEN (i = p_clev_tbl.LAST);
		i := p_clev_tbl.NEXT(i);
	   END LOOP;
	   -- return overall status
	   x_return_status := l_overall_status;
    END IF;
    -- rabhupat bug 4435390 end (cklee okl.h Bug 4506351 (okl.g bug#4435390))

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

-- check after record created
    x_return_status := validate_credit_limit_after(
                       p_chr_id       => lp_clev_tbl(lp_clev_tbl.FIRST).dnz_chr_id
                       ,p_mode         => 'UPDATE');

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
--    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
--       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_credit_limit_pub;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_credit_limit_pub;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO update_credit_limit_pub;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : delete_credit_limit
-- Description     : wrapper api for delete_contract_line
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE delete_credit_limit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
--    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_clev_tbl                     IN  clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type)
is

  l_api_name         CONSTANT VARCHAR2(30) := 'delete_credit_limit_pub';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_clev_tbl         okl_okc_migration_pvt.clev_tbl_type;
--  lx_clev_tbl         okl_okc_migration_pvt.clev_tbl_type;

begin
  -- Set API savepoint
  SAVEPOINT delete_credit_limit_pub;


  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

    copy_clev_tbl(
          p_clev_tbl      => p_clev_tbl,
          p_clev_migr_tbl => lp_clev_tbl
    );

    validate_credit_limit(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_mode           => G_DELETE_MODE,
      p_clev_tbl       => lp_clev_tbl,
      p_klev_tbl       => p_klev_tbl);

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;


    OKL_CONTRACT_PUB.delete_contract_line(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_clev_tbl       => lp_clev_tbl,
      p_klev_tbl       => p_klev_tbl);

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

-- check after record created
    x_return_status := validate_credit_limit_after(
                       p_chr_id       => lp_clev_tbl(lp_clev_tbl.FIRST).dnz_chr_id
                       ,p_mode         => 'DELETE');

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
--    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
--       raise OKC_API.G_EXCEPTION_ERROR;
    End If;


/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);


EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO delete_credit_limit_pub;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_credit_limit_pub;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO delete_credit_limit_pub;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_credit
-- Description     : creates a credit line and credit limits

-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE create_credit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crdv_rec                     IN  crdv_rec_type,
    p_clmv_tbl                     IN  clmv_tbl_type,
    x_crdv_rec                     OUT NOCOPY crdv_rec_type,
    x_clmv_tbl                     OUT NOCOPY clmv_tbl_type)
As
  l_api_name         CONSTANT VARCHAR2(30) := 'create_credit_pub';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_effective_from   DATE;
  l_sts_code         VARCHAR2(30);

  lp_clev_tbl        clev_tbl_type;
  lp_klev_tbl        klev_tbl_type;
  x_clev_tbl         clev_tbl_type;
  x_klev_tbl         klev_tbl_type;

  cursor c_crd(p_chr_id number) is
--start modified abhsaxen for performance SQLID 20562820

SELECT
    chrb.contract_number contract_number,
    chrb.start_date start_date,
    chrb.end_date end_date,
    chrb.currency_code currency_code,
    chrb.sts_code sts_code,
    chrb.cust_acct_id cust_acct_id,
    chrt.description description,
    khr.currency_conversion_type currency_conversion_type,
    khr.currency_conversion_rate currency_conversion_rate,
    khr.currency_conversion_date currency_conversion_date,
    khr.revolving_credit_yn revolving_credit_yn,
    cpl.id party_roles_id,
    cpl.object1_id1 customer_id1,
    cpl.object1_id2 customer_id2,
    cpl.jtot_object1_code customer_jtot_object_code,
    party.name customer_name,
    rul.rule_information1 creditline_ckl_id,
    rul.rule_information2 funding_ckl_id,
    rul.rgp_id chklst_tpl_rgp_id,
    rul.id chklst_tpl_rule_id,
    CA.ACCOUNT_NUMBER  cust_acct_number
    FROM
    OKC_K_HEADERS_B CHRB,
    OKC_K_HEADERS_TL CHRT,
    OKL_K_HEADERS KHR,
    HZ_CUST_ACCOUNTS CA,
    OKC_RULES_B RUL,
    OKX_PARTIES_V PARTY,
    OKC_K_PARTY_ROLES_B CPL
    WHERE chrb.id = chrt.id
    AND chrt.language = USERENV('LANG')
    AND chrb.id = khr.id
    AND chrb.scs_code = 'CREDITLINE_CONTRACT'
    AND CA.CUST_ACCOUNT_ID(+) = chrb.cust_acct_id
    AND rul.rule_information_category(+) = 'LACCLT'
    AND rul.dnz_chr_id(+) = chrb.id
    AND party.id1 = cpl.object1_id1
    AND party.id2 = cpl.object1_id2
    AND cpl.rle_code = 'LESSEE'
    AND cpl.chr_id = chrb.id
    AND cpl.DNZ_CHR_ID = cpl.chr_id
    AND CHRB.ID = p_chr_id
--end modified abhsaxen for performance SQLID 20562820
;
  cursor c_clm(p_chr_id number) is
 select
  okc.id,
  okc.dnz_chr_id,
  okc.item_description,
  okc.start_date,
  okl.credit_nature,
  okl.amount
  from OKC_K_LINES_V okc,
       OKL_K_LINES okl
  where okc.id = okl.id
  and okc.dnz_chr_id = p_chr_id;

  r_crd c_crd%ROWTYPE;
  r_clm c_clm%ROWTYPE;

begin
  -- Set API savepoint
  SAVEPOINT create_credit_pub;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

    ----------------------------------------------------------------
    -- create credit line
    ----------------------------------------------------------------
    -- set default date for effective from
    IF (NULLIF(p_crdv_rec.effective_from,OKC_API.G_MISS_DATE) IS NULL) THEN
      l_effective_from := TRUNC(SYSDATE);
    ELSE
      l_effective_from := p_crdv_rec.effective_from;
    END IF;

    -- set default 'NEW' for sts_code
    IF (NULLIF(p_crdv_rec.sts_code,OKC_API.G_MISS_CHAR) IS NULL) THEN
      l_sts_code := 'NEW';
    ELSE
      l_sts_code := p_crdv_rec.sts_code;
    END IF;

    create_credit(
      p_api_version         => p_api_version,
      p_init_msg_list       => p_init_msg_list,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      p_contract_number     => NULLIF(p_crdv_rec.contract_number,OKC_API.G_MISS_CHAR),
      p_description         => NULLIF(p_crdv_rec.description,OKC_API.G_MISS_CHAR),
      p_customer_id1        => NULLIF(p_crdv_rec.customer_id1,OKC_API.G_MISS_CHAR),
      p_customer_id2        => NULLIF(p_crdv_rec.customer_id2,OKC_API.G_MISS_CHAR),
      p_customer_code       => NULLIF(p_crdv_rec.customer_code,OKC_API.G_MISS_CHAR),
      p_customer_name       => NULLIF(p_crdv_rec.customer_name,OKC_API.G_MISS_CHAR),
      p_effective_from      => l_effective_from,
      p_effective_to        => NULLIF(p_crdv_rec.effective_to,OKC_API.G_MISS_DATE),
      p_currency_code       => NULLIF(p_crdv_rec.currency_code,OKC_API.G_MISS_CHAR),
      p_currency_conv_type  => NULLIF(p_crdv_rec.currency_conv_type,OKC_API.G_MISS_CHAR),
      p_currency_conv_rate  => NULLIF(p_crdv_rec.currency_conv_rate,OKC_API.G_MISS_NUM),
      p_currency_conv_date  => NULLIF(p_crdv_rec.currency_conv_date,OKC_API.G_MISS_DATE),
      p_revolving_credit_yn => NULLIF(p_crdv_rec.revolving_credit_yn,OKC_API.G_MISS_CHAR),
      p_sts_code            => l_sts_code,
      p_credit_ckl_id       => NULLIF(p_crdv_rec.credit_ckl_id,OKC_API.G_MISS_NUM),
      p_funding_ckl_id      => NULLIF(p_crdv_rec.funding_ckl_id,OKC_API.G_MISS_NUM),
      p_cust_acct_id        => NULLIF(p_crdv_rec.cust_acct_id,OKC_API.G_MISS_NUM),
      p_cust_acct_number    => NULLIF(p_crdv_rec.cust_acct_number,OKC_API.G_MISS_CHAR),
      x_chr_id              => x_crdv_rec.id
    );

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    ----------------------------------------------------------------
    -- copy out record
    ----------------------------------------------------------------
    IF (NOT (x_crdv_rec.id IS NULL OR
        x_crdv_rec.id = OKC_API.G_MISS_NUM)) THEN

      OPEN  c_crd(x_crdv_rec.id);
      FETCH c_crd INTO r_crd;
      CLOSE c_crd;

      x_crdv_rec.contract_number      := r_crd.contract_number;
      x_crdv_rec.description          := r_crd.description;
      x_crdv_rec.party_roles_id       := r_crd.party_roles_id;
      x_crdv_rec.customer_id1         := r_crd.customer_id1;
      x_crdv_rec.customer_id2         := r_crd.customer_id2;
      x_crdv_rec.customer_code        := r_crd.customer_jtot_object_code;
      x_crdv_rec.customer_name        := r_crd.customer_name;
      x_crdv_rec.effective_from       := r_crd.start_date;
      x_crdv_rec.effective_to         := r_crd.end_date;
      x_crdv_rec.currency_code        := r_crd.currency_code;
      x_crdv_rec.currency_conv_type   := r_crd.currency_conversion_type;
      x_crdv_rec.currency_conv_rate   := r_crd.currency_conversion_rate;
      x_crdv_rec.currency_conv_date   := r_crd.currency_conversion_date;
      x_crdv_rec.revolving_credit_yn  := r_crd.revolving_credit_yn;
      x_crdv_rec.sts_code             := r_crd.sts_code;
      x_crdv_rec.credit_ckl_id        := TO_NUMBER(r_crd.creditline_ckl_id);
      x_crdv_rec.funding_ckl_id       := TO_NUMBER(r_crd.funding_ckl_id);
      x_crdv_rec.chklst_tpl_rgp_id    := r_crd.chklst_tpl_rgp_id;
      x_crdv_rec.chklst_tpl_rule_id   := r_crd.chklst_tpl_rule_id;
      x_crdv_rec.cust_acct_id         := r_crd.cust_acct_id;
      x_crdv_rec.cust_acct_number     := r_crd.cust_acct_number;

      ----------------------------------------------------------------
      -- create credit limits
      ----------------------------------------------------------------
      IF (p_clmv_tbl.COUNT > 0) THEN

        copy_clmv_tbl(
          p_chr_id       => x_crdv_rec.id,
          p_clmv_tbl     => p_clmv_tbl,
          x_clev_tbl     => lp_clev_tbl,
          x_klev_tbl     => lp_klev_tbl
        );

        create_credit_limit(
          p_api_version         => p_api_version,
          p_init_msg_list       => p_init_msg_list,
          x_return_status       => x_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data,
          p_clev_tbl            => lp_clev_tbl,
          p_klev_tbl            => lp_klev_tbl,
          x_clev_tbl            => x_clev_tbl,
          x_klev_tbl            => x_klev_tbl
        );

        If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
           raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
           raise OKC_API.G_EXCEPTION_ERROR;
        End If;

        ----------------------------------------------------------------
        -- copy out record
        ----------------------------------------------------------------
        OPEN  c_clm(x_crdv_rec.id);
        i := 1;
        LOOP
          FETCH c_clm INTO r_clm;
          EXIT WHEN c_clm%NOTFOUND;

          x_clmv_tbl(i).id               := r_clm.id;
          x_clmv_tbl(i).chr_id           := r_clm.dnz_chr_id;
          x_clmv_tbl(i).item_description := r_clm.item_description;
          x_clmv_tbl(i).start_date       := r_clm.start_date;
          x_clmv_tbl(i).credit_nature    := r_clm.credit_nature;
          x_clmv_tbl(i).amount           := r_clm.amount;

          i := i + 1;
        END LOOP;
        CLOSE c_clm;

      END IF;

    END IF;


/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO create_credit_pub;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_credit_pub;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO create_credit_pub;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end create_credit;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_credit
-- Description     : creates a credit

-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE create_credit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
--
    p_contract_number              IN  VARCHAR2,
    p_description                  IN  VARCHAR2,
--    p_version_no                   IN  VARCHAR2,
--    p_scs_code                     IN  VARCHAR2,
    p_customer_id1                 IN  VARCHAR2,
    p_customer_id2                 IN  VARCHAR2,
    p_customer_code                IN  VARCHAR2,
    p_customer_name                IN  VARCHAR2,
    p_effective_from               IN  DATE,
    p_effective_to                 IN  DATE,
    p_currency_code                IN  VARCHAR2,
-- multi-currency support
    p_currency_conv_type           IN  VARCHAR2,
    p_currency_conv_rate           IN  NUMBER,
    p_currency_conv_date           IN  DATE,
-- multi-currency support
    p_revolving_credit_yn          IN  VARCHAR2,
    p_sts_code                     IN  VARCHAR2,
--
-- funding checklist enhancement
    p_credit_ckl_id                IN  NUMBER,
    p_funding_ckl_id               IN  NUMBER,
-- funding checklist enhancement
    p_cust_acct_id                 IN  NUMBER, -- 11.5.10 rule migration project
    p_cust_acct_number             IN  VARCHAR2, -- 11.5.10 rule migration project
    p_org_id                       IN  NUMBER,
    p_organization_id              IN  NUMBER,
    p_source_chr_id                IN  NUMBER,
    x_chr_id                       OUT NOCOPY NUMBER)
AS
    lp_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;


    lx_chrv_rec OKL_OKC_MIGRATION_PVT.chrv_rec_type;
    lp_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;
    lx_khrv_rec OKL_CONTRACT_PUB.khrv_rec_type;

    lp_cplv_rec OKC_CONTRACT_PARTY_PUB.cplv_rec_type;
    lx_cplv_rec OKC_CONTRACT_PARTY_PUB.cplv_rec_type;

-- funding checklist enhancement for 11.5.9
  lp_rgpv_rec        rgpv_rec_type;
  lp_rulv_rec        rulv_rec_type;
  lx_rgpv_rec        rgpv_rec_type;
  lx_rulv_rec        rulv_rec_type;
-- funding checklist enhancement for 11.5.9

    l_api_version	CONSTANT NUMBER	  := 1.0;

    l_api_name	VARCHAR2(30) := 'CREATE_CREDIT';
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    CURSOR role_csr(p_rle_code VARCHAR2)  IS
    Select  access_level
    from    OKC_ROLE_SOURCES
    where rle_code = p_rle_code
    and     buy_or_sell = 'S';

    l_access_level OKC_ROLE_SOURCES.access_level%TYPE;


  BEGIN
    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

-- fix bug# for set_org_id
    okl_context.set_okc_org_context();
--
    lp_chrv_rec.sfwt_flag := 'N';
    lp_chrv_rec.object_version_number := 1.0;
    lp_chrv_rec.sts_code := G_STS_CODE; -- 'ENTERED';
    lp_chrv_rec.scs_code := G_SCS_CODE;--p_scs_code;
    lp_chrv_rec.contract_number := p_contract_number;

    lp_chrv_rec.sts_code := p_sts_code;
    lp_chrv_rec.description := p_description;
    lp_chrv_rec.short_description := p_description;
-- fixed bug # 2855402
    lp_chrv_rec.start_date := TRUNC(p_effective_from);
    lp_chrv_rec.end_date :=  TRUNC(p_effective_to);
-- fixed bug # 2855402
    -- to resolve the validation for sign_by_date
--    lp_chrv_rec.sign_by_date := lp_chrv_rec.end_date;
    lp_chrv_rec.sign_by_date := null;
    lp_chrv_rec.currency_code := p_currency_code;

-- Start bug fix 4148019 27-JAN-05 cklee
    If (p_org_id is null or p_org_id = OKC_API.G_MISS_NUM ) then
       lp_chrv_rec.authoring_org_id := OKL_CONTEXT.GET_OKC_ORG_ID;
    else
       lp_chrv_rec.authoring_org_id := p_org_id;
    end If;
    If (p_organization_id is null or p_organization_id = OKC_API.G_MISS_NUM ) then
       lp_chrv_rec.inv_organization_id := OKL_CONTEXT.get_okc_organization_id;
    else
       lp_chrv_rec.inv_organization_id := p_organization_id;
    End If;
-- End bug fix 4148019 27-JAN-05 cklee

--    lp_chrv_rec.currency_code := OKC_CURRENCY_API.GET_OU_CURRENCY(OKL_CONTEXT.GET_OKC_ORG_ID);
    lp_chrv_rec.currency_code_renewed := null;
    lp_chrv_rec.template_yn := 'N';
    lp_chrv_rec.chr_type := 'CYA';
    lp_chrv_rec.archived_yn := 'N';
    lp_chrv_rec.deleted_yn := 'N';
    lp_chrv_rec.buy_or_sell := 'S';
    lp_chrv_rec.issue_or_receive := 'I';

    lp_chrv_rec.cust_acct_id := p_cust_acct_id; -- 11.5.10 rule migration project

    lp_khrv_rec.object_version_number := 1.0;
--    lp_khrv_rec.khr_id := 1;
    lp_khrv_rec.generate_accrual_yn := 'Y';
    lp_khrv_rec.generate_accrual_override_yn := 'N';
    lp_khrv_rec.revolving_credit_yn := p_revolving_credit_yn;
-- multi-currency code support
    lp_khrv_rec.currency_conversion_type := p_currency_conv_type;
    lp_khrv_rec.currency_conversion_rate := p_currency_conv_rate;
    lp_khrv_rec.currency_conversion_date := p_currency_conv_date;
-- multi-currency code support

--
-- Credit header specific validation
--

    x_return_status := validate_header_attributes(lp_chrv_rec, lp_khrv_rec, lp_rulv_rec, 'C');
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;
-- 11.5.10 rule migration start
      x_return_status := validate_account_number(p_cust_acct_id     => p_cust_acct_id,
                                                 p_cust_acct_number => p_cust_acct_number);
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;
-- 11.5.10 rule migration start

    OKL_CONTRACT_PUB.create_contract_header(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_chrv_rec       => lp_chrv_rec,
      p_khrv_rec       => lp_khrv_rec,
      x_chrv_rec       => lx_chrv_rec,
      x_khrv_rec       => lx_khrv_rec);

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    x_chr_id := lx_chrv_rec.id;

    -- now we attach the party to the header
    lp_cplv_rec.object_version_number := 1.0;
    lp_cplv_rec.sfwt_flag := OKC_API.G_FALSE;
    lp_cplv_rec.dnz_chr_id := x_chr_id;
    lp_cplv_rec.chr_id := x_chr_id;
    lp_cplv_rec.cle_id := null;
    lp_cplv_rec.object1_id1 := p_customer_id1;
    lp_cplv_rec.object1_id2 := p_customer_id2;
    lp_cplv_rec.jtot_object1_code := p_customer_code;
    lp_cplv_rec.rle_code := G_RLE_CODE;

    x_return_status := validate_customer(lp_cplv_rec, p_customer_name);
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    OKC_CONTRACT_PARTY_PUB.validate_k_party_role(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_cplv_rec       => lp_cplv_rec);


    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

----- Changes by Kanti
----- Validate the JTOT Object code, ID1 and ID2

     OPEN role_csr(lp_cplv_rec.rle_code);
     FETCH role_csr INTO l_access_level;
     CLOSE role_csr;

     IF (l_access_level = 'S') THEN

         okl_la_validation_util_pvt.VALIDATE_ROLE_JTOT (p_api_version    => p_api_version,
                                                          p_init_msg_list  => OKC_API.G_FALSE,
                                                          x_return_status  => x_return_status,
                                                          x_msg_count	   => x_msg_count,
                                                          x_msg_data	   => x_msg_data,
                                                          p_object_name    => lp_cplv_rec.jtot_object1_code,
                                                          p_id1            => lp_cplv_rec.object1_id1,
                                                          p_id2            => lp_cplv_rec.object1_id2);
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

     END IF;

----  Changes End

    OKC_CONTRACT_PARTY_PUB.create_k_party_role(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_cplv_rec       => lp_cplv_rec,
      x_cplv_rec       => lx_cplv_rec);

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

-- funding checklist enhancement for 11.5.9
    -- rule group FK
    lp_rgpv_rec.DNZ_CHR_ID := lx_chrv_rec.id;
    lp_rgpv_rec.CHR_ID := lx_chrv_rec.id; -- MUST

    -- rule FKs
    lp_rulv_rec.DNZ_CHR_ID := lx_chrv_rec.id; -- MUST
    lp_rulv_rec.RULE_INFORMATION1 := p_credit_ckl_id;
    lp_rulv_rec.RULE_INFORMATION2 := p_funding_ckl_id;

--
-- Credit header checklist template
--

    x_return_status := validate_chklst_tpl(lp_rulv_rec, 'C');
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    create_credit_chklst_tpl(
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_rgpv_rec       => lp_rgpv_rec,
      p_rulv_rec       => lp_rulv_rec,
      x_rgpv_rec       => lx_rgpv_rec,
      x_rulv_rec       => lx_rulv_rec);

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

-- funding checklist enhancement for 11.5.9

   /*
   -- vthiruva, 08/31/2004
   -- START, Code change to enable Business Event
   */
   --raise business event for new credit line record
   --if sts_code is NEW
    IF(lp_chrv_rec.sts_code = 'NEW')THEN
    	raise_business_event(p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
			     x_return_status  => x_return_status,
			     x_msg_count      => x_msg_count,
			     x_msg_data       => x_msg_data,
			     p_id             => lx_chrv_rec.id,
			     p_event_name     => G_WF_EVT_CR_LN_CREATED);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    END IF;

   /*
   -- vthiruva, 08/31/2004
   -- END, Code change to enable Business Event
   */

    OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
		         x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END;
/*---------------------------------------------------------------------------+
|                                                                            |
|  FUNCTION: get_total_credit_limit                                          |

|  DESC   : Sum of all credit limit (contract line) for specfiic contract    |
|           scs_code = 'CREDITLINE_CONTRACT'                                 |
|  IN     : p_contract_id                                                    |
|  OUT    : amount                                                           |
|  HISTORY: 26-JAN-02 ChenKuang.Lee@oracle.com -- Created                    |
|                                                                            |

*-------------------------------------------------------------------------- */
 FUNCTION get_total_credit_limit(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER
 ) RETURN NUMBER
IS
  l_amount NUMBER := 0;
  l_amount_add NUMBER := 0;
  l_amount_new NUMBER := 0;
  l_amount_reduce NUMBER := 0;

BEGIN

  l_amount_add := nvl(OKL_CREDIT_PUB.get_total_credit_addition(p_contract_id),0);
  l_amount_new := nvl(OKL_CREDIT_PUB.get_total_credit_new_limit(p_contract_id),0);
  l_amount_reduce := nvl(OKL_CREDIT_PUB.get_total_credit_reduction(p_contract_id),0);

  l_amount := l_amount_new + l_amount_add - l_amount_reduce;

  RETURN l_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN null;

END;

/*---------------------------------------------------------------------------+
|                                                                            |
|  FUNCTION: get_credit_remaining                                            |
|  DESC   : Sum of all credit limit (contract line) for specfiic contract    |
|           scs_code = 'CREDITLINE_CONTRACT' and substract from Funding total|
|  IN     : p_contract_id                                                    |
|  OUT    : amount                                                           |
|  HISTORY: 26-JAN-02 ChenKuang.Lee@oracle.com -- Created                    |
|                                                                            |
*-------------------------------------------------------------------------- */
 FUNCTION get_credit_remaining(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER
 ) RETURN NUMBER
IS
  l_amount NUMBER := 0;
  l_amount_funded NUMBER := 0;
  l_amount_credit_limit NUMBER := 0;

BEGIN

  --l_amount_funded := nvl(OKL_FUNDING_PVT.get_total_funded(p_contract_id),0);
  l_amount_credit_limit := nvl(OKL_CREDIT_PUB.get_total_credit_limit(p_contract_id),0);

  l_amount := l_amount_credit_limit - l_amount_funded;

  RETURN l_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN null;

END;
/*---------------------------------------------------------------------------+
|                                                                            |
|  FUNCTION: get_total_credit_new_limit                                      |
|  DESC   : Sum of all credit new limit (contract line) for specfiic contract|
|           scs_code = 'CREDITLINE_CONTRACT'                                 |
|  IN     : p_contract_id                                                    |
|  OUT    : amount                                                           |
|  HISTORY: 26-JAN-02 ChenKuang.Lee@oracle.com -- Created                    |

|                                                                            |
*-------------------------------------------------------------------------- */
 FUNCTION get_total_credit_new_limit(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER
 ) RETURN NUMBER
IS
  l_amount NUMBER := 0;

  CURSOR c (p_contract_id  NUMBER)
  IS
  select nvl(sum(a.amount),0)
  from OKL_K_LINES_FULL_V a
  where a.dnz_chr_id = p_contract_id
  and   a.CREDIT_NATURE = 'NEW'
  and   nvl(a.start_date,sysdate) <= sysdate
  ;

BEGIN

  OPEN c (p_contract_id);
  FETCH c INTO l_amount;
  CLOSE c;

  RETURN l_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN null;

END;
/*---------------------------------------------------------------------------+
|                                                                            |
|  FUNCTION: get_total_credit_addition                                       |
|  DESC   : Sum of all credit addition (contract line) for specfiic contract |
|           scs_code = 'CREDITLINE_CONTRACT'                                 |
|  IN     : p_contract_id                                                    |
|  OUT    : amount                                                           |
|  HISTORY: 26-JAN-02 ChenKuang.Lee@oracle.com -- Created                    |
|                                                                            |
*-------------------------------------------------------------------------- */
 FUNCTION get_total_credit_addition(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER
 ) RETURN NUMBER
IS
  l_amount NUMBER := 0;

  CURSOR c (p_contract_id  NUMBER)
  IS
  select nvl(sum(a.amount),0)
  from OKL_K_LINES_FULL_V a
  where a.dnz_chr_id = p_contract_id
  and   a.CREDIT_NATURE = 'ADD'
  and   nvl(a.start_date,sysdate) <= sysdate
  ;

BEGIN

  OPEN c (p_contract_id);
  FETCH c INTO l_amount;
  CLOSE c;

  RETURN l_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN null;

END;

/*---------------------------------------------------------------------------+
|                                                                            |
|  FUNCTION: get_total_credit_reduction                                      |
|  DESC   : Sum of all credit reduction (contract line) for specfiic contract|
|           scs_code = 'CREDITLINE_CONTRACT'                                 |
|  IN     : p_contract_id                                                    |
|  OUT    : amount                                                           |
|  HISTORY: 26-JAN-02 ChenKuang.Lee@oracle.com -- Created                    |
|                                                                            |
*-------------------------------------------------------------------------- */
 FUNCTION get_total_credit_reduction(
 p_contract_id                   IN NUMBER
 ,p_contract_line_id             IN NUMBER
 ) RETURN NUMBER
IS
  l_amount NUMBER := 0;

  CURSOR c (p_contract_id  NUMBER)
  IS
  select nvl(sum(a.amount),0)
  from OKL_K_LINES_FULL_V a
  where a.dnz_chr_id = p_contract_id
  and   a.CREDIT_NATURE = 'REDUCE'
  and   nvl(a.start_date,sysdate) <= sysdate
  ;

BEGIN

  OPEN c (p_contract_id);
  FETCH c INTO l_amount;
  CLOSE c;

  RETURN l_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN null;

END;
/*---------------------------------------------------------------------------+
|                                                                            |
|  FUNCTION: get_checklist_number                                            |
|  IN     : p_ckl_id                                                         |
|  OUT    : checkist_number                                                  |
|  HISTORY: 26-JAN-02 ChenKuang.Lee@oracle.com -- Created                    |
|                                                                            |
*-------------------------------------------------------------------------- */
 FUNCTION get_checklist_number(
 p_chr_id                   IN NUMBER
 ,p_attr                    IN VARCHAR2
 ) RETURN VARCHAR2
IS
  l_number okl_checklists.CHECKLIST_NUMBER%type;
  l_ckl_id number;

  CURSOR c (p_ckl_id  NUMBER)
  IS
  select CHECKLIST_NUMBER
  from okl_checklists ckl
  where ckl.id = to_number(p_ckl_id)
  ;

  CURSOR c_fk (p_chr_id  NUMBER)
  IS
  select DECODE(p_attr, 'RULE_INFORMATION1', to_number(rule.rule_information1),
                        'RULE_INFORMATION2', to_number(rule.rule_information2))
  from okc_rules_b rule
  where rule.dnz_chr_id = p_chr_id
  and   rule.rule_information_category = G_CREDIT_CHKLST_TPL_RULE1
  ;

BEGIN

  OPEN c_fk (p_chr_id);
  FETCH c_fk INTO l_ckl_id;
  CLOSE c_fk;

  OPEN c (l_ckl_id);
  FETCH c INTO l_number;
  CLOSE c;

  RETURN l_number;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN null;

END;

/*---------------------------------------------------------------------------+
|                                                                            |
|  FUNCTION: fnd_profile_value                                               |
|  IN     : p_opt_name                                                       |
|  OUT    : profile option value                                             |
|  HISTORY: 26-JAN-02 ChenKuang.Lee@oracle.com -- Created                    |
|                                                                            |
*-------------------------------------------------------------------------- */
FUNCTION fnd_profile_value(
 p_opt_name                   IN VARCHAR2
) RETURN VARCHAR2
is
begin
 return fnd_profile.value(p_opt_name);
end;

/*---------------------------------------------------------------------------+
|                                                                            |
|  FUNCTION: get_func_curr_code                                              |
|  IN     :                                                                  |
|  OUT    : currency code                                                    |
|  HISTORY: 26-JAN-02 ChenKuang.Lee@oracle.com -- Created                    |
|                                                                            |
*-------------------------------------------------------------------------- */
FUNCTION get_func_curr_code
 RETURN VARCHAR2
is
begin
 return okl_accounting_util.get_func_curr_code;
end;

/*---------------------------------------------------------------------------+
|                                                                            |
|  FUNCTION: get_checklist_attr                                              |
|  IN     : p_ckl_id                                                         |
|  OUT    : checkist_number                                                  |
|  HISTORY: 26-JAN-02 ChenKuang.Lee@oracle.com -- Created                    |
|                                                                            |
*-------------------------------------------------------------------------- */
 FUNCTION get_checklist_attr(
 p_chr_id                   IN NUMBER
 ,p_attr                    IN VARCHAR2
 ) RETURN VARCHAR2
is
  l_rgp_id okc_rules_b.rgp_id%type;
  l_id okc_rules_b.id%type;
  l_rule_information1 okc_rules_b.rule_information1%type;
  l_rule_information2 okc_rules_b.rule_information2%type;


  CURSOR c (p_chr_id  NUMBER)
  IS
  select rule.id,
         rule.rgp_id,
         rule.rule_information1,
         rule.rule_information2
  from okc_rules_b rule
  where rule.dnz_chr_id = p_chr_id
  and   rule.rule_information_category = G_CREDIT_CHKLST_TPL_RULE1
  ;

BEGIN

  OPEN c (p_chr_id);
  FETCH c INTO l_id,
               l_rgp_id,
               l_rule_information1,
               l_rule_information2;
  CLOSE c;

  IF p_attr = 'ID' THEN
    RETURN to_char(l_id);
  ELSIF p_attr = 'RGP_ID' THEN
    RETURN to_char(l_rgp_id);
  ELSIF p_attr = 'RULE_INFORMATION1' THEN
    RETURN l_rule_information1;
  ELSIF p_attr = 'RULE_INFORMATION2' THEN
    RETURN l_rule_information2;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN null;
end;

-- start cklee bug# 2901495
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_creditline_by_chrid
-- Description     : search associated credit line by contract id
-- Business Rules  :

-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
FUNCTION get_creditline_by_chrid(
  p_contract_id                       IN NUMBER                 -- contract hdr
) RETURN NUMBER
IS
    l_credit_id okc_k_headers_b.id%TYPE := NULL;
    l_row_not_found boolean := false;

  CURSOR c_credit (p_contract_id  NUMBER)
  IS
  select a.ID
  from   OKC_K_HEADERS_B a,
         okc_Governances_v g
  where  a.id = g.chr_id_referred
  and    a.sts_code = 'ACTIVE'
  and    g.dnz_chr_id = p_contract_id
  and    a.scs_code = 'CREDITLINE_CONTRACT'
  ;
--cklee, fixed bug# 3149922
  CURSOR c_MLA_credit (p_contract_id  NUMBER)
  IS
  select a.ID
  from   OKC_K_HEADERS_B a,
         okc_Governances_v g
  where  a.id = g.chr_id_referred
  and    a.sts_code = 'ACTIVE'
  and    a.scs_code = 'CREDITLINE_CONTRACT'
  and    g.dnz_chr_id = (select a1.ID -- MLA chrid
              from   OKC_K_HEADERS_B a1,
                     okc_Governances_v g1
              where  a1.id = g1.chr_id_referred
              and    g1.dnz_chr_id = p_contract_id
              and    a1.scs_code = 'MASTER_LEASE')
  ;


BEGIN

    -- 1) get credit_id by associated contract
    OPEN c_credit(p_contract_id);
    FETCH c_credit INTO l_credit_id;
    l_row_not_found := c_credit%NOTFOUND;
    CLOSE c_credit;

    IF (l_row_not_found) THEN

      -- 2) get credit_id by associated MLA contract
      OPEN c_MLA_credit(p_contract_id);
      FETCH c_MLA_credit INTO l_credit_id;
      CLOSE c_MLA_credit;

    END IF;

    RETURN l_credit_id;

  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => OKL_API.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END get_creditline_by_chrid;
-- end cklee bug# 2901495

-- start: 06-May-2005  cklee okl.h Lease App IA Authoring
PROCEDURE update_credit_line_status(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    x_status_code                  OUT NOCOPY VARCHAR2,
    p_status_code                  IN  VARCHAR2,
    p_credit_line_id               IN  NUMBER)
is
  l_api_name         CONSTANT VARCHAR2(30) := 'update_credit_line_status';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  lp_chrv_rec           okl_okc_migration_pvt.chrv_rec_type;
  lp_khrv_rec           khrv_rec_type;
  lx_chrv_rec           okl_okc_migration_pvt.chrv_rec_type;
  lx_khrv_rec           khrv_rec_type;

begin
  -- Set API savepoint
  SAVEPOINT update_credit_line_status;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/
    -- set values
    lp_chrv_rec.ID := p_credit_line_id;
    lp_khrv_rec.ID := p_credit_line_id;
    lp_chrv_rec.sts_code := p_status_code;

    IF p_status_code = 'APPROVED' THEN

      -- trun to Active directly if Credit Line got approved
      lp_chrv_rec.sts_code := 'ACTIVE';

    ELSIF (p_status_code NOT IN ('SUBMITTED', 'APPROVED','PENDING_APPROVAL','DECLINED')) THEN

      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => p_status_code);

      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    update_credit_header(
          p_api_version        => p_api_version,
          p_init_msg_list      => p_init_msg_list,
          x_return_status      => x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data,
          p_chrv_rec           => lp_chrv_rec,
          p_khrv_rec           => lp_khrv_rec,
          x_chrv_rec           => lx_chrv_rec,
          x_khrv_rec           => lx_khrv_rec
          );

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

      x_status_code := lx_chrv_rec.sts_code;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_credit_line_status;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    x_status_code := lx_chrv_rec.sts_code;

    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_credit_line_status;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    x_status_code := lx_chrv_rec.sts_code;

    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO update_credit_line_status;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      x_status_code := lx_chrv_rec.sts_code;

      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);
end update_credit_line_status;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_checklist_function
-- Description     : This API will execute function for each item and
--                   update the execution results for the function.
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_checklist_function(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_contract_id                  IN  NUMBER
 ) is
  l_api_name         CONSTANT VARCHAR2(30) := 'update_checklist_function';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_dummy  number;

  l_row_not_found boolean := false;

  lp_rulv_tbl        okl_credit_checklist_pvt.rulv_tbl_type;
  lx_rulv_tbl        okl_credit_checklist_pvt.rulv_tbl_type;
  plsql_block        VARCHAR2(500);

  lp_return_status   okl_credit_checklists_uv.FUNCTION_VALIDATE_RSTS%type;
  lp_fund_rst        okl_credit_checklists_uv.FUNCTION_VALIDATE_RSTS%type;
  lp_msg_data        okl_credit_checklists_uv.FUNCTION_VALIDATE_MSG%type;

-- get checklist template attributes
cursor c_clist_funs (p_contract_id number) is
--start modified abhsaxen for performance SQLID 20562912
  SELECT
    rult.ID,
    fun.source function_source
  FROM OKC_RULES_B RULT,
    OKL_DATA_SRC_FNCTNS_b FUN
  WHERE rult.rule_information_category = 'LACCLD' and
    rult.RULE_INFORMATION9 = fun.ID and
    rult.DNZ_CHR_ID = p_contract_id
--end modified abhsaxen for performance SQLID 20562912
  ;

begin
  -- Set API savepoint
  SAVEPOINT update_checklist_function;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

    ------------------------------------------------------------------------
    -- execute function for each to do item and save the return to each row
    ------------------------------------------------------------------------
    i := 0;
    FOR r_this_row IN c_clist_funs (p_contract_id) LOOP

      BEGIN

        plsql_block := 'BEGIN :l_rtn := '|| r_this_row.FUNCTION_SOURCE ||'(:p_contract_id); END;';
        EXECUTE IMMEDIATE plsql_block USING OUT lp_return_status, p_contract_id;

        IF lp_return_status = 'P' THEN
          lp_fund_rst := 'PASSED';
          lp_msg_data := 'Passed';
        ELSIF lp_return_status = 'F' THEN
          lp_fund_rst := 'FAILED';
          lp_msg_data := 'Failed';
        ELSE
          lp_fund_rst := 'ERROR';
          lp_msg_data := r_this_row.FUNCTION_SOURCE || ' returns: ' || lp_return_status;
        END IF;

      EXCEPTION
        WHEN OKL_API.G_EXCEPTION_ERROR THEN
          lp_fund_rst := 'ERROR';
          FND_MSG_PUB.Count_And_Get
            (p_count         =>      x_msg_count,
             p_data          =>      x_msg_data);
          lp_msg_data := substr('Application error: ' || x_msg_data, 240);

        WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
          lp_fund_rst := 'ERROR';
          FND_MSG_PUB.Count_And_Get
            (p_count         =>      x_msg_count,
             p_data          =>      x_msg_data);
          lp_msg_data := substr('Unexpected application error: ' || x_msg_data, 240);

        WHEN OTHERS THEN
          lp_fund_rst := 'ERROR';
          lp_msg_data := substr('Unexpected system error: ' || SQLERRM, 240);

      END;

      lp_rulv_tbl(i).ID := r_this_row.ID;
      lp_rulv_tbl(i).RULE_INFORMATION7 := lp_fund_rst;
      lp_rulv_tbl(i).RULE_INFORMATION8 := lp_msg_data;
      i := i + 1;

    END LOOP;

    IF lp_rulv_tbl.count > 0 THEN

      okl_credit_checklist_pvt.update_credit_chklst(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_tbl       => lp_rulv_tbl,
          x_rulv_tbl       => lx_rulv_tbl);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

    END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_checklist_function;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_checklist_function;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN

	ROLLBACK TO update_checklist_function;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end update_checklist_function;
-- end: 06-May-2005  cklee okl.h Lease App IA Authoring

-- start: cklee 07/12/2005
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : activate_credit
-- Description     : activates a credit line
--
-- Business Rules  :  This procedure will validate credit line and then activate
--                    the credit line.
--                    It will return to the caller without raise error if credit
--                    has been activated already.
--
-- Parameters      :  p_chr_id   : Credit Line PK
--                    x_sts_code : Credit Line status code
--
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE activate_credit(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    x_sts_code                     OUT NOCOPY VARCHAR2)
is

  l_api_name         CONSTANT VARCHAR2(30) := 'activate_credit_pvt';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

cursor c_credit (p_chr_id number) is
--start modified abhsaxen for performance SQLID 20562919
SELECT
    chrb.contract_number contract_number,
    chrb.start_date start_date,
    chrb.end_date end_date,
    chrb.currency_code currency_code,
    chrb.sts_code sts_code,
    chrb.cust_acct_id cust_acct_id,
    chrt.description description,
    khr.currency_conversion_type currency_conversion_type,
    khr.currency_conversion_rate currency_conversion_rate,
    khr.currency_conversion_date currency_conversion_date,
    khr.revolving_credit_yn revolving_credit_yn,
    cpl.id party_roles_id,
    cpl.object1_id1 customer_id1,
    cpl.object1_id2 customer_id2,
    cpl.jtot_object1_code customer_jtot_object_code,
    party.name customer_name,
    rul.rule_information1 creditline_ckl_id,
    rul.rule_information2 funding_ckl_id,
    rul.rgp_id chklst_tpl_rgp_id,
    rul.id chklst_tpl_rule_id,
    CA.ACCOUNT_NUMBER  cust_acct_number
    FROM
    OKC_K_HEADERS_B CHRB,
    OKC_K_HEADERS_TL CHRT,
    OKL_K_HEADERS KHR,
    HZ_CUST_ACCOUNTS CA,
    OKC_RULES_B RUL,
    OKX_PARTIES_V PARTY,
    OKC_K_PARTY_ROLES_B CPL
    WHERE chrb.id = chrt.id
    AND chrt.language = USERENV('LANG')
    AND chrb.id = khr.id
    AND chrb.scs_code = 'CREDITLINE_CONTRACT'
    AND CA.CUST_ACCOUNT_ID(+) = chrb.cust_acct_id
    AND rul.rule_information_category(+) = 'LACCLT'
    AND rul.dnz_chr_id(+) = chrb.id
    AND party.id1 = cpl.object1_id1
    AND party.id2 = cpl.object1_id2
    AND cpl.rle_code = 'LESSEE'
    AND cpl.chr_id = chrb.id
    AND cpl.DNZ_CHR_ID = cpl.chr_id
    AND CHRB.ID = p_chr_id;
--end modified abhsaxen for performance SQLID 20562919


  l_credit_rec c_credit%ROWTYPE;

  lp_chrv_rec    okl_okc_migration_pvt.chrv_rec_type;
  lp_khrv_rec    khrv_rec_type;
  lx_chrv_rec    okl_okc_migration_pvt.chrv_rec_type;
  lx_khrv_rec    khrv_rec_type;


BEGIN
  -- Set API savepoint
  SAVEPOINT activate_credit_pvt;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

  OPEN c_credit(p_chr_id => p_chr_id);
  FETCH c_credit INTO l_credit_rec;
  CLOSE c_credit;

  validate_credit(
    p_api_version                  => p_api_version,
    p_init_msg_list                => p_init_msg_list,
    x_return_status                => x_return_status,
    x_msg_count                    => x_msg_count,
    x_msg_data                     => x_msg_data,
    p_chr_id                       => p_chr_id,
    p_contract_number              => l_credit_rec.CONTRACT_NUMBER,
    p_description                  => l_credit_rec.DESCRIPTION,
    p_customer_id1                 => l_credit_rec.CUSTOMER_ID1,
    p_customer_id2                 => l_credit_rec.CUSTOMER_ID2,
    p_customer_code                => l_credit_rec.CUSTOMER_JTOT_OBJECT_CODE,
    p_customer_name                => l_credit_rec.CUSTOMER_NAME,
    p_effective_from               => l_credit_rec.START_DATE,
    p_effective_to                 => l_credit_rec.END_DATE,
    p_currency_code                => l_credit_rec.CURRENCY_CODE,
-- multi-currency support
    p_currency_conv_type           => l_credit_rec.CURRENCY_CONVERSION_TYPE,
    p_currency_conv_rate           => l_credit_rec.CURRENCY_CONVERSION_RATE,
    p_currency_conv_date           => l_credit_rec.CURRENCY_CONVERSION_DATE,
-- multi-currency support
-- funding checklist enhancement
    p_credit_ckl_id                => l_credit_rec.CREDITLINE_CKL_ID,
    p_funding_ckl_id               => l_credit_rec.FUNDING_CKL_ID,
-- funding checklist enhancement
    p_cust_acct_id                 => l_credit_rec.CUST_ACCT_ID, -- 11.5.10 rule migration project
    p_cust_acct_number             => l_credit_rec.CUST_ACCT_NUMBER, -- 11.5.10 rule migration project
    p_sts_code                     => l_credit_rec.STS_CODE
    );

  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;


  lp_chrv_rec.id := p_chr_id;
  lp_chrv_rec.contract_number := l_credit_rec.CONTRACT_NUMBER;
  lp_chrv_rec.description := l_credit_rec.DESCRIPTION;
  lp_chrv_rec.short_description := l_credit_rec.DESCRIPTION;
  lp_chrv_rec.currency_code := l_credit_rec.CURRENCY_CODE;

  lp_khrv_rec.currency_conversion_type := l_credit_rec.CURRENCY_CONVERSION_TYPE;
  lp_khrv_rec.currency_conversion_rate := l_credit_rec.CURRENCY_CONVERSION_RATE;
  lp_khrv_rec.currency_conversion_date := l_credit_rec.CURRENCY_CONVERSION_DATE;

  lp_chrv_rec.sts_code := 'SUBMITTED';--'ACTIVE';
  lp_chrv_rec.start_date := l_credit_rec.START_DATE;
  lp_chrv_rec.end_date := l_credit_rec.END_DATE;
  lp_chrv_rec.sign_by_date := null;

  lp_khrv_rec.revolving_credit_yn := l_credit_rec.REVOLVING_CREDIT_YN;

  lp_chrv_rec.cust_acct_id := l_credit_rec.CUST_ACCT_ID;

  update_credit_header(
    p_api_version                  => p_api_version,
    p_init_msg_list                => p_init_msg_list,
    x_return_status                => x_return_status,
    x_msg_count                    => x_msg_count,
    x_msg_data                     => x_msg_data,
    p_restricted_update            => 'F',
-- funding checklist enhancement
    p_chklst_tpl_rgp_id            => l_credit_rec.CHKLST_TPL_RGP_ID,-- LACCLH
    p_chklst_tpl_rule_id           => l_credit_rec.CHKLST_TPL_RULE_ID,-- LACCLT
    p_credit_ckl_id                => l_credit_rec.CREDITLINE_CKL_ID,
    p_funding_ckl_id               => l_credit_rec.FUNDING_CKL_ID,
-- funding checklist enhancement
    p_chrv_rec                     => lp_chrv_rec,
    p_khrv_rec                     => lp_khrv_rec,
    x_chrv_rec                     => lx_chrv_rec,
    x_khrv_rec                     => lx_khrv_rec
    );

  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  x_sts_code := lx_chrv_rec.sts_code;
/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO activate_credit_pvt;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO activate_credit_pvt;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO activate_credit_pvt;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

END activate_credit;
-- end: cklee 07/12/2005


END OKL_CREDIT_PUB;

/
