--------------------------------------------------------
--  DDL for Package Body OKC_CONTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CONTRACT_PVT" AS
/* $Header: OKCCCHRB.pls 120.15.12010000.8 2011/10/25 10:06:01 spingali ship $ */

        l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

--  subtype control_rec_type is okc_util.okc_control_rec_type;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_NO_PARENT_RECORD CONSTANT   VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR CONSTANT   VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_PARENT_TABLE_TOKEN  CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN   CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_SQLERRM_TOKEN        CONSTANT       VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN        CONSTANT       VARCHAR2(200) := 'SQLcode';
  G_REQUIRED_VALUE       CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE        CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN       CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_TABLE_TOKEN      CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_EXCEPTION_HALT_VALIDATION exception;
  NO_CONTRACT_FOUND exception;
  G_NO_UPDATE_ALLOWED_EXCEPTION exception;
  G_NO_UPDATE_ALLOWED CONSTANT VARCHAR2(200) := 'OKC_NO_UPDATE_ALLOWED';
  G_EXCEPTION_HALT_PROCESS exception;
  G_CREATE_NA_EXCEPTION    exception;
  ---------------------------------------------------------------------------
-- /striping/
p_rule_code   OKC_RULE_DEFS_B.rule_code%TYPE;
p_appl_id     OKC_RULE_DEFS_B.application_id%TYPE;
p_dff_name    OKC_RULE_DEFS_B.descriptive_flexfield_name%TYPE;

-- Start of comments
-- BUG#4066428 HKAMDAR 29-Dec-2004 Part 1
-- Procedure Name  : is_rule_allowed
-- Description     : Checks if rules are allowed for contracts class,
-- Business Rules  :
-- Version         : 1.0
-- End of comments

Procedure is_rule_allowed(p_id number,
                          p_object          varchar2,
                          x_return       out NOCOPY varchar2,
                                         x_rule_meaning out NOCOPY varchar2) IS

cursor cur_k_appl_id is
Select application_id
from okc_k_headers_b
where id = p_id;

k_appl_id number;

Begin

     Open cur_k_appl_id;
     Fetch cur_k_appl_id into k_appl_id;
     Close cur_k_appl_id;

   --For OKS ks no rule/rule group allowed
     If k_appl_id =515 Then
        x_return :='N';
     Else
        x_return := 'Y';
     End If;

End Is_rule_allowed;
-- BUG#4066428 End Part 1
  --
  -- Function to check if a workflow is active for a contract
  -- Function Name: Is_Process_Active
  -- An item is considered active if its end_date is NULL
  --
  FUNCTION Is_Process_Active(p_chr_id IN NUMBER) RETURN VARCHAR2 Is

        l_wf_name               OKC_PROCESS_DEFS_B.WF_NAME%TYPE;
        l_item_key      OKC_K_PROCESSES.PROCESS_ID%TYPE;
        l_return_code   VARCHAR2(1) := 'N';
        l_end_date      DATE;

        -- cursor for item type and item key
        Cursor l_pdfv_csr Is
                SELECT pdfv.wf_name, cpsv.process_id
                FROM okc_process_defs_b pdfv,
                        okc_k_processes cpsv
                WHERE pdfv.id = cpsv.pdf_id
                  AND cpsv.chr_id = p_chr_id;

        -- cursor to check active process
        Cursor l_wfitems_csr Is
                SELECT end_date
                FROM wf_items
                WHERE item_type = l_wf_name
                  AND item_key = l_item_key;
  BEGIN

    -- get item type and item key
    Open l_pdfv_csr;
    Fetch l_pdfv_csr into l_wf_name, l_item_key;
    If (l_pdfv_csr%NOTFOUND or l_wf_name IS NULL or l_item_key IS NULL) Then
       Close l_pdfv_csr;
          return l_return_code;
    End If;
    Close l_pdfv_csr;

    -- check whether process is active or not
    Open l_wfitems_csr;
    Fetch l_wfitems_csr into l_end_date;
    If (l_wfitems_csr%NOTFOUND or l_end_date IS NOT NULL) Then
          l_return_code := 'N';
    Else
           l_return_code := 'Y';
    End If;
    Close l_wfitems_csr;

    return l_return_code;
  exception
    when NO_DATA_FOUND then
         return (l_return_code);
  END Is_Process_Active;

----------------------------------------------------------------------------------------------
---Funtion Returns 'Y' if  user has update access on a category
----------------------------------------------------------------------------------------------
   FUNCTION Validate_Access_level(p_scs_code IN VARCHAR2) RETURN VARCHAR2 IS

    Cursor Access_Level_csr is
     Select access_level
     from okc_subclass_resps_v
     where scs_code=p_scs_code
     and resp_id=fnd_global.resp_id
     and sysdate between start_date and nvl(end_date,sysdate);

    l_access_level VARCHAR2(1);
    l_return_val  VARCHAR2(1)  := 'N' ;

  BEGIN

    Open Access_Level_csr;
    Fetch Access_Level_csr into l_access_level;
    Close Access_Level_csr;

    If l_access_level = 'U' then
    l_return_val := 'Y';
    End If;
    return (l_return_val);

  EXCEPTION
    WHEN NO_DATA_FOUND then
    return(l_return_val);

  END Validate_Access_Level;


  PROCEDURE GENERATE_CONTRACT_NUMBER(
        p_scs_code          IN VARCHAR2,
        p_modifier          IN  VARCHAR2,
        x_return_status     OUT NOCOPY VARCHAR2,
        x_contract_number   IN OUT NOCOPY OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE) Is

    l_unique_number_found     BOOLEAN := FALSE;
    l_chrv_rec                OKC_CHR_PVT.chrv_rec_type;
    l_return_status           VARCHAR2(1);

  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('Generate Contract Number');
       okc_debug.log('1000: Entering generate contract number');
    END IF;
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- if contract number is null, polpulate default contract number
    If (x_contract_number = OKC_API.G_MISS_CHAR or
        x_contract_number is null)
    Then
      IF (l_debug = 'Y') THEN
         okc_debug.log('1010: x_contract_Number is null');
      END IF;
          -- Loop till a unique contract number + modifier found
          -- WHILE (NOT l_unique_number_found)
          -- LOOP
            IF (l_debug = 'Y') THEN
               okc_debug.log('1020: Before Get_K_Number');
            END IF;
            OKC_CONTRACT_SEQ_PUB.GET_K_NUMBER (
                      p_scs_code => p_scs_code,
                      p_contract_number_modifier => p_modifier,
                      x_contract_number => x_contract_number,
                      x_return_status => l_return_status );
            IF (l_debug = 'Y') THEN
               okc_debug.log('1030: After Get_K_Number');
               okc_debug.log('1040: x_contract_number ' || x_contract_number);
            END IF;

            x_return_status := l_return_status;
            If (l_return_status <> OKC_API.G_RET_STS_SUCCESS) Then
               Raise G_EXCEPTION_HALT_VALIDATION;
            End If;

            -- check for unique contract_number + modifier
            /* l_chrv_rec.contract_number := x_contract_number;
            l_chrv_rec.contract_number_modifier := p_modifier;

            l_return_status := OKC_CHR_PVT.Is_Unique(l_chrv_rec);
            If (l_return_status = OKC_API.G_RET_STS_SUCCESS) Then
               l_unique_number_found := TRUE;
            End If;
            x_return_status := l_return_status;
         END LOOP; */
    End If;
    IF (l_debug = 'Y') THEN
       okc_debug.log('1050: Exiting Generate Contract Number');
       okc_debug.reset_indentation;
    END IF;
  exception
    when G_EXCEPTION_HALT_VALIDATION then
      IF (l_debug = 'Y') THEN
         okc_debug.log('1060: Exiting Generate Contract Number');
         okc_debug.reset_indentation;
      END IF;
    when OTHERS then
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);
      IF (l_debug = 'Y') THEN
         okc_debug.log('1070: Exiting Generate Contract Number');
         okc_debug.reset_indentation;
      END IF;
  END GENERATE_CONTRACT_NUMBER;


  FUNCTION Update_Minor_Version(p_chr_id IN NUMBER) RETURN VARCHAR2 Is
        l_api_version                 NUMBER := 1;
        l_init_msg_list               VARCHAR2(1) := 'F';
        x_return_status               VARCHAR2(1);
        x_msg_count                   NUMBER;
        x_msg_data                    VARCHAR2(2000);
        x_out_rec                     OKC_CVM_PVT.cvmv_rec_type;
        l_cvmv_rec                    OKC_CVM_PVT.cvmv_rec_type;
  BEGIN

        -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        -- assign/populate contract header id
        l_cvmv_rec.chr_id := p_chr_id;

        OKC_CVM_PVT.update_contract_version(
                p_api_version    => l_api_version,
                p_init_msg_list  => l_init_msg_list,
                x_return_status  => x_return_status,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data,
                p_cvmv_rec       => l_cvmv_rec,
                x_cvmv_rec       => x_out_rec);

        -- Error handling....
        -- calls OTHERS exception
        return (x_return_status);
  EXCEPTION
    when OTHERS then
           -- notify caller of an error
           x_return_status := OKC_API.G_RET_STS_ERROR;

          -- store SQL error message on message stack
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_unexpected_error,
                                          p_token1              => g_sqlcode_token,
                                          p_token1_value        => sqlcode,
                                          p_token2              => g_sqlerrm_token,
                                          p_token2_value        => sqlerrm);

        return (x_return_status);
  END;

  -------------------------------------------------------------------
  -- This procedure overrides the trasaction-id check
  -- Use this only to increase the minor version by force
  -- called in authoring form when coming back from rule editor
  -- This function directly calls the Update_Row for version table
  ------------------------------------------------------------------
  FUNCTION Increment_Minor_Version(p_chr_id IN NUMBER) RETURN VARCHAR2 IS

    p_api_version                   NUMBER := 1;
    p_init_msg_list                VARCHAR2(1) := 'F';
    x_return_status                VARCHAR2(1);
    x_msg_count                    NUMBER;
    x_msg_data                     VARCHAR2(2000);
    x_cvmv_rec                     OKC_CVM_PVT.cvmv_rec_type;

    l_cvmv_rec OKC_CVM_PVT.cvmv_rec_type;
  BEGIN

        x_return_status := OKC_API.G_RET_STS_SUCCESS;

           l_cvmv_rec.chr_id := p_chr_id;

           -- Major version update is not allowed
           l_cvmv_rec.major_version := OKC_API.G_MISS_NUM;

           -- update contract version number
           OKC_CVM_PVT.update_row(
                        p_api_version,
                        p_init_msg_list,
                        x_return_status,
                        x_msg_count,
                        x_msg_data,
                        l_cvmv_rec,
                        x_cvmv_rec);

        -- assign current trasaction id to global_trans_id
           OKC_CVM_PVT.g_trans_id := dbms_transaction.local_transaction_id;
           return x_return_status;
  EXCEPTION
        WHEN OTHERS THEN
          -- store SQL error message on message stack
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_unexpected_error,
                                          p_token1              => g_sqlcode_token,
                                          p_token1_value        => sqlcode,
                                          p_token2              => g_sqlerrm_token,
                                          p_token2_value        => sqlerrm);

           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
           return x_return_status;
  END Increment_Minor_Version;

  FUNCTION Create_Version(p_chr_id IN NUMBER)  RETURN VARCHAR2 Is
        l_api_version                 NUMBER := 1;
        l_init_msg_list               VARCHAR2(1) := 'F';
        x_return_status               VARCHAR2(1);
        x_msg_count                   NUMBER;
        x_msg_data                    VARCHAR2(2000);
        x_out_rec                     OKC_CVM_PVT.cvmv_rec_type;
        l_cvmv_rec                    OKC_CVM_PVT.cvmv_rec_type;
  BEGIN

        -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        -- assign/populate contract header id
        l_cvmv_rec.chr_id := p_chr_id;

        OKC_CVM_PVT.create_contract_version(
                p_api_version    => l_api_version,
                p_init_msg_list  => l_init_msg_list,
                x_return_status  => x_return_status,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data,
                p_cvmv_rec       => l_cvmv_rec,
                x_cvmv_rec       => x_out_rec);

        -- Error handling....
        -- calls OTHERS exception
        return (x_return_status);
  EXCEPTION
    when OTHERS then
           -- notify caller of an error
           x_return_status := OKC_API.G_RET_STS_ERROR;

          -- store SQL error message on message stack
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_unexpected_error,
                                          p_token1              => g_sqlcode_token,
                                          p_token1_value        => sqlcode,
                                          p_token2              => g_sqlerrm_token,
                                          p_token2_value        => sqlerrm);

          return (x_return_status);
  END;

  FUNCTION Delete_Version(p_chr_id IN NUMBER) RETURN VARCHAR2 Is
        l_api_version                 NUMBER := 1;
        l_init_msg_list               VARCHAR2(1) := 'F';
        x_return_status               VARCHAR2(1);
        x_msg_count                   NUMBER;
        x_msg_data                    VARCHAR2(2000);
        l_cvmv_rec                    OKC_CVM_PVT.cvmv_rec_type;
  BEGIN

        -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        -- assign/populate contract header id
        l_cvmv_rec.chr_id := p_chr_id;

        OKC_CVM_PVT.delete_contract_version(
                p_api_version    => l_api_version,
                p_init_msg_list  => l_init_msg_list,
                x_return_status  => x_return_status,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data,
                p_cvmv_rec       => l_cvmv_rec);

        -- Error handling....
        -- calls OTHERS exception
        return (x_return_status);
  EXCEPTION
    when OTHERS then
           -- notify caller of an error
           x_return_status := OKC_API.G_RET_STS_ERROR;

          -- store SQL error message on message stack
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_unexpected_error,
                                          p_token1              => g_sqlcode_token,
                                          p_token1_value        => sqlcode,
                                          p_token2              => g_sqlerrm_token,
                                          p_token2_value        => sqlerrm);
        return (x_return_status);

  END;

  PROCEDURE create_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN  OKC_CHR_PVT.chrv_rec_type,
    x_chrv_rec                     OUT NOCOPY  OKC_CHR_PVT.chrv_rec_type,
    p_check_access                 IN VARCHAR2 ) IS

    l_chrv_rec          OKC_CHR_PVT.chrv_rec_type := p_chrv_rec;
    Cursor subclass_csr is
    Select meaning
    from okc_subclasses_v
    where code=p_chrv_rec.scs_code;
    l_scs_meaning VARCHAR2(30);
    l_hstv_rec  OKC_K_HISTORY_PVT.hstv_rec_type;
    x_hstv_rec  OKC_K_HISTORY_PVT.hstv_rec_type;
    l_version   VARCHAR2(255);

    CURSOR version_csr(p_chr_id NUMBER) IS
    SELECT to_char (major_version)||'.'||to_char(minor_version)
    FROM okc_k_vers_numbers
    WHERE chr_id=p_chr_id;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    --if p_check_access is 'Y' , check if user has update access on category

    If (p_check_access = 'Y' AND
          validate_access_level(p_chrv_rec.scs_code)<> 'Y')
    Then
          Open Subclass_csr;
          Fetch subclass_csr into l_scs_meaning;
          Close subclass_csr;
          RAISE G_CREATE_NA_EXCEPTION;
    End If;

    -- if contract number is null, polpulate default contract number
    If (l_chrv_rec.contract_number = OKC_API.G_MISS_CHAR or
           l_chrv_rec.contract_number is null)
    Then
          OKC_CONTRACT_PVT.GENERATE_CONTRACT_NUMBER(
                        p_scs_code        => l_chrv_rec.scs_code,
                        p_modifier        => l_chrv_rec.contract_number_modifier,
                        x_return_status   => x_return_status,
                        x_contract_number => l_chrv_rec.contract_number);

          /* If (x_return_status <> OKC_API.G_RET_STS_SUCCESS) Then
             OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                                             p_msg_name => g_unexpected_error,
                                             p_token1           => g_sqlcode_token,
                                             p_token1_value     => sqlcode,
                                             p_token2           => g_sqlerrm_token,
                                             p_token2_value     => sqlerrm);
          End If; */
    End If;

    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then

       OKC_CHR_PVT.Insert_Row(
               p_api_version    => p_api_version,
               p_init_msg_list  => p_init_msg_list,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_chrv_rec          => l_chrv_rec,
            x_chrv_rec          => x_chrv_rec);
    End If;

    -- Create version
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
          x_return_status := OKC_CONTRACT_PVT.Create_Version(x_chrv_rec.id);
    End If;

   -- Create record in OKC_K_HISTORY tables
   If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
       l_hstv_rec.chr_id := x_chrv_rec.id;
       l_hstv_rec.sts_code_from := NULL;
       l_hstv_rec.sts_code_to := x_chrv_rec.sts_code;
       l_hstv_rec.reason_code := 'CREATE';
       l_hstv_rec.opn_code := 'STS_CHG';
       l_hstv_rec.manual_yn := 'N';

       open version_csr(x_chrv_rec.id);
       fetch version_csr into l_version;
       close version_csr;

       l_hstv_rec.contract_version := l_version;

       OKC_K_HISTORY_PUB.create_k_history(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
         x_return_status        => x_return_status,
         x_msg_count            => x_msg_count,
         x_msg_data             => x_msg_data,
         p_hstv_rec             => l_hstv_rec,
         x_hstv_rec             => x_hstv_rec);
   End If;

  EXCEPTION
    When G_CREATE_NA_EXCEPTION Then
    OKC_API.SET_MESSAGE(p_app_name       => 'OKC',
                                    p_msg_name       => 'OKC_CREATE_NA',
                                    p_token1         => 'CATEGORY',
                                    p_token1_value   => l_scs_meaning);
    x_return_status:=OKC_API.G_RET_STS_ERROR;

  END create_contract_header;

  PROCEDURE create_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN  OKC_CHR_PVT.chrv_tbl_type,
    x_chrv_tbl                     OUT NOCOPY  OKC_CHR_PVT.chrv_tbl_type,
    p_check_access                 IN VARCHAR2 ) IS

  BEGIN
    OKC_CHR_PVT.Insert_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_chrv_tbl                => p_chrv_tbl,
      x_chrv_tbl                => x_chrv_tbl);
  END create_contract_header;


  PROCEDURE update_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update            IN VARCHAR2 ,
    p_chrv_rec                     IN OKC_CHR_PVT.chrv_rec_type,
    x_chrv_rec                     OUT NOCOPY OKC_CHR_PVT.chrv_rec_type) IS

    l_currency_code     VARCHAR2(5);
    l_hstv_rec      OKC_K_HISTORY_PVT.hstv_rec_type;
    x_hstv_rec      OKC_K_HISTORY_PVT.hstv_rec_type;
    l_version       VARCHAR2(255);
    l_status        VARCHAR2(30) := NULL;
    l_new_status    VARCHAR2(30) := NULL;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_old_ste_code  VARCHAR2(30) := NULL;
    l_new_ste_code  VARCHAR2(30) := NULL;

    Cursor l_chrv_csr Is
                SELECT currency_code
                --npalepu 26-10-2005 modified for bug # 4691662.
                --Replaced table okc_k_headers_b with headers_All_b table
                /* FROM okc_k_headers_b */
                FROM okc_k_headers_all_b
                --end npalepu
                WHERE ID = p_chrv_rec.id;

    CURSOR version_csr(p_chr_id NUMBER) IS
        SELECT to_char (major_version)||'.'||to_char(minor_version)
        FROM okc_k_vers_numbers
        WHERE chr_id=p_chr_id;

    Cursor l_status_csr Is
                SELECT sts_code
                --npalepu 26-10-2005 modified for bug # 4691662.
                --Replaced table okc_k_headers_b with headers_All_b table
                /* FROM okc_k_headers_b  */
                FROM okc_k_headers_all_b
                --end npalepu
                WHERE ID = p_chrv_rec.id;

    CURSOR ste_code_csr(p_status_code VARCHAR2) IS
               SELECT ste_code
               FROM okc_statuses_b
               WHERE code=p_status_code;

  BEGIN
    -- if the update is not a restricted update (restricted_update <> 'Y'),
    -- check whether update is allowed or not
    If (p_restricted_update <> OKC_API.G_TRUE) Then
       If (OKC_CONTRACT_PUB.Update_Allowed(p_chrv_rec.id) <> 'Y') Then
             raise G_NO_UPDATE_ALLOWED_EXCEPTION;
       End If;
    End If;

    -- If currency code is changed in header, all line's currency
    -- codes are to be changed. So retrieve and remember the old currency code.
    open l_chrv_csr;
    fetch l_chrv_csr into l_currency_code;
    close l_chrv_csr;

    -- To get the old status
    open l_status_csr;
    fetch l_status_csr into l_status;
    close l_status_csr;

    If (p_chrv_rec.sts_code = OKC_API.G_MISS_CHAR) Then
       l_new_status := NULL;
    Else
       l_new_status := p_chrv_rec.sts_code;
    End If;

    OKC_CHR_PVT.Update_Row(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data,
         p_restricted_update    => p_restricted_update,
      p_chrv_rec                        => p_chrv_rec,
      x_chrv_rec                        => x_chrv_rec);

    -- Update minor version
    /*fix for bug6688656*/
    If x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
        x_return_status := Update_Minor_Version(p_chrv_rec.id);
    End if;
   /*end of fix for bug6688656*/

   /*cgopinee bugfix for 6882512*/

    OPEN ste_code_csr(l_status);
    FETCH ste_code_csr INTO l_old_ste_code;
    CLOSE ste_code_csr;

    OPEN ste_code_csr(l_new_status);
    FETCH ste_code_csr INTO l_new_ste_code;
    CLOSE ste_code_csr;

   --Update contacts table status
   IF l_old_ste_code <> l_new_ste_code THEN
      OKC_CTC_PVT.update_contact_stecode(p_chr_id => p_chrv_rec.id,
                             x_return_status=>l_return_status);

      IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;
   /*end of bugfix 6882512*/

    -- Call action assembler if status is changed
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS AND
        p_chrv_rec.old_sts_code is not null AND
        p_chrv_rec.new_sts_code is not null AND
        p_chrv_rec.old_ste_code is not null AND
           p_chrv_rec.new_ste_code is not null AND
           (p_chrv_rec.old_sts_code <> p_chrv_rec.new_sts_code OR
            p_chrv_rec.old_ste_code <> p_chrv_rec.new_ste_code
           )
       )
    Then
        OKC_K_STS_CHG_ASMBLR_PVT.Acn_Assemble(
                 p_api_version   => p_api_version,
                 p_init_msg_list  => p_init_msg_list,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data,
              p_k_id           => x_chrv_rec.id,
              p_k_number       => x_chrv_rec.contract_number,
              p_k_nbr_mod      => x_chrv_rec.contract_number_modifier,
              p_k_cur_sts_code => p_chrv_rec.new_sts_code,
              p_k_cur_sts_type => p_chrv_rec.new_ste_code,
              p_k_pre_sts_code => p_chrv_rec.old_sts_code,
              p_k_pre_sts_type => p_chrv_rec.old_ste_code,
              p_k_source_system_code => p_chrv_rec.ORIG_SYSTEM_SOURCE_CODE);
    Else
        If ( ( (x_return_status = OKC_API.G_RET_STS_SUCCESS) AND (l_new_status is not null) AND (l_status is not null) )
             AND (l_status <> l_new_status) )  Then

              -- To insert record in history tables
              l_hstv_rec.chr_id := x_chrv_rec.id;
              l_hstv_rec.sts_code_from := l_status;
              l_hstv_rec.sts_code_to := l_new_status;
              l_hstv_rec.opn_code := 'STS_CHG';

              open version_csr(x_chrv_rec.id);
              fetch version_csr into l_version;
              close version_csr;

              l_hstv_rec.contract_version := l_version;

              OKC_K_HISTORY_PUB.create_k_history(
                        p_api_version          => p_api_version,
                        p_init_msg_list        => p_init_msg_list,
                        x_return_status        => x_return_status,
                        x_msg_count            => x_msg_count,
                        x_msg_data             => x_msg_data,
                        p_hstv_rec             => l_hstv_rec,
                        x_hstv_rec             => x_hstv_rec);
        End If;
    End If;

    -- Update Currency change
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
          -- If currency code changed, update all lines
          If (x_chrv_rec.currency_code <> l_currency_code) Then
                 UPDATE okc_k_lines_b
                 SET currency_code = x_chrv_rec.currency_code
                 WHERE dnz_chr_id = x_chrv_rec.id;
          End If;
          /*commented and written above for bug6688656
          x_return_status := Update_Minor_Version(p_chrv_rec.id);
          */
    End If;
  exception
    when G_NO_UPDATE_ALLOWED_EXCEPTION then
          x_return_status := OKC_API.G_RET_STS_ERROR;
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_no_update_allowed,
                                          p_token1              => 'VALUE1',
                                          p_token1_value        => 'Contract Header');
    when OTHERS then
          -- store SQL error message on message stack
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_unexpected_error,
                                          p_token1              => g_sqlcode_token,
                                          p_token1_value        => sqlcode,
                                          p_token2              => g_sqlerrm_token,
                                          p_token2_value        => sqlerrm);

           -- notify caller of an UNEXPETED error
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END update_contract_header;


  PROCEDURE update_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update                 IN VARCHAR2 ,
    p_chrv_tbl                     IN OKC_CHR_PVT.chrv_tbl_type,
    x_chrv_tbl                     OUT NOCOPY OKC_CHR_PVT.chrv_tbl_type) IS

  BEGIN
    OKC_CHR_PVT.Update_Row(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data,
      p_restricted_update       => p_restricted_update,
      p_chrv_tbl                        => p_chrv_tbl,
      x_chrv_tbl                        => x_chrv_tbl);
  END update_contract_header;

  PROCEDURE update_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update            IN VARCHAR2 ,
    p_chrv_rec                     IN OKC_CHR_PVT.chrv_rec_type,
    p_control_rec                  IN control_rec_type,
    x_chrv_rec                     OUT NOCOPY OKC_CHR_PVT.chrv_rec_type) IS

    l_currency_code     VARCHAR2(5);
    l_hstv_rec      OKC_K_HISTORY_PVT.hstv_rec_type;
    x_hstv_rec      OKC_K_HISTORY_PVT.hstv_rec_type;
    l_version       VARCHAR2(255);
    l_status        VARCHAR2(30) := NULL;
    l_new_status    VARCHAR2(30) := NULL;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_old_ste_code  VARCHAR2(30) := NULL;
    l_new_ste_code  VARCHAR2(30) := NULL;

    Cursor l_chrv_csr Is
                SELECT currency_code
                --npalepu 26-10-2005 modified for bug # 4691662.
                --Replaced table okc_k_headers_b with headers_All_b table
                /*  FROM okc_k_headers_b */
                FROM okc_k_headers_all_b
                --end npalepu
                WHERE ID = p_chrv_rec.id;

    CURSOR version_csr(p_chr_id NUMBER) IS
        SELECT to_char (major_version)||'.'||to_char(minor_version)
        FROM okc_k_vers_numbers
        WHERE chr_id=p_chr_id;

    Cursor l_status_csr Is
                SELECT sts_code
                --npalepu 26-10-2005 modified for bug # 4691662.
                --Replaced table okc_k_headers_b with headers_All_b table
                /*  FROM okc_k_headers_b */
                FROM okc_k_headers_all_b
                --end npalepu
                WHERE ID = p_chrv_rec.id;

    CURSOR ste_code_csr(p_status_code VARCHAR2) IS
                   SELECT ste_code
                   FROM okc_statuses_b
               WHERE code=p_status_code;

  BEGIN
    -- if the update is not a restricted update (restricted_update <> 'Y'),
    -- check whether update is allowed or not
    If (p_restricted_update <> OKC_API.G_TRUE) Then
       If (OKC_CONTRACT_PUB.Update_Allowed(p_chrv_rec.id) <> 'Y') Then
             raise G_NO_UPDATE_ALLOWED_EXCEPTION;
       End If;
    End If;

    -- If currency code is changed in header, all line's currency
    -- codes are to be changed. So retrieve and remember the old currency code.
    open l_chrv_csr;
    fetch l_chrv_csr into l_currency_code;
    close l_chrv_csr;

    -- To get the old status
    open l_status_csr;
    fetch l_status_csr into l_status;
    close l_status_csr;

    If (p_chrv_rec.sts_code = OKC_API.G_MISS_CHAR) Then
       l_new_status := NULL;
    Else
       l_new_status := p_chrv_rec.sts_code;
    End If;

    OKC_CHR_PVT.Update_Row(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data,
         p_restricted_update    => p_restricted_update,
      p_chrv_rec                        => p_chrv_rec,
      x_chrv_rec                        => x_chrv_rec);

    -- Update minor version
    /*fix for bug6688656*/
    If x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
        x_return_status := Update_Minor_Version(p_chrv_rec.id);
    End if;
    /*end of fix for bug6688656*/

    /*cgopinee bugfix for 6882512*/

     OPEN ste_code_csr(l_status);
     FETCH ste_code_csr INTO l_old_ste_code;
     CLOSE ste_code_csr;

     OPEN ste_code_csr(l_new_status);
     FETCH ste_code_csr INTO l_new_ste_code;
     CLOSE ste_code_csr;

     --Update contacts table status
     IF l_old_ste_code <> l_new_ste_code THEN
        OKC_CTC_PVT.update_contact_stecode(p_chr_id => p_chrv_rec.id,
                               x_return_status=>l_return_status);

        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

     END IF;
   /*end of bugfix 6882512*/

    -- Call action assembler if status is changed
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS AND
        p_chrv_rec.old_sts_code is not null AND
        p_chrv_rec.new_sts_code is not null AND
        p_chrv_rec.old_ste_code is not null AND
           p_chrv_rec.new_ste_code is not null AND
           (p_chrv_rec.old_sts_code <> p_chrv_rec.new_sts_code OR
            p_chrv_rec.old_ste_code <> p_chrv_rec.new_ste_code
           )
       )
    Then
        OKC_K_STS_CHG_ASMBLR_PVT.Acn_Assemble(
                 p_api_version   => p_api_version,
                 p_init_msg_list  => p_init_msg_list,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data,
              p_k_id           => x_chrv_rec.id,
              p_k_number       => x_chrv_rec.contract_number,
              p_k_nbr_mod      => x_chrv_rec.contract_number_modifier,
              p_k_cur_sts_code => p_chrv_rec.new_sts_code,
              p_k_cur_sts_type => p_chrv_rec.new_ste_code,
              p_k_pre_sts_code => p_chrv_rec.old_sts_code,
              p_k_pre_sts_type => p_chrv_rec.old_ste_code,
              p_k_source_system_code => p_chrv_rec.ORIG_SYSTEM_SOURCE_CODE,
              p_control_rec    => p_control_rec);
    Else
        If ( ( (x_return_status = OKC_API.G_RET_STS_SUCCESS) AND (l_new_status is not null) AND (l_status is not null) )
             AND (l_status <> l_new_status) )  Then

              -- To insert record in history tables
              l_hstv_rec.chr_id := x_chrv_rec.id;
              l_hstv_rec.sts_code_from := l_status;
              l_hstv_rec.sts_code_to := l_new_status;
              l_hstv_rec.opn_code := 'STS_CHG';

              open version_csr(x_chrv_rec.id);
              fetch version_csr into l_version;
              close version_csr;

              l_hstv_rec.contract_version := l_version;

              OKC_K_HISTORY_PUB.create_k_history(
                        p_api_version          => p_api_version,
                        p_init_msg_list        => p_init_msg_list,
                        x_return_status        => x_return_status,
                        x_msg_count            => x_msg_count,
                        x_msg_data             => x_msg_data,
                        p_hstv_rec             => l_hstv_rec,
                        x_hstv_rec             => x_hstv_rec);
        End If;
    End If;

    -- Update Currency change
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
          -- If currency code changed, update all lines
          If (x_chrv_rec.currency_code <> l_currency_code) Then
                 UPDATE okc_k_lines_b
                 SET currency_code = x_chrv_rec.currency_code
                 WHERE dnz_chr_id = x_chrv_rec.id;
          End If;
	  /*commented and written above for the bug6688656
          x_return_status := Update_Minor_Version(p_chrv_rec.id);
	  */
    End If;
  exception
    when G_NO_UPDATE_ALLOWED_EXCEPTION then
          x_return_status := OKC_API.G_RET_STS_ERROR;
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_no_update_allowed,
                                          p_token1              => 'VALUE1',
                                          p_token1_value        => 'Contract Header');
    when OTHERS then
          -- store SQL error message on message stack
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_unexpected_error,
                                          p_token1              => g_sqlcode_token,
                                          p_token1_value        => sqlcode,
                                          p_token2              => g_sqlerrm_token,
                                          p_token2_value        => sqlerrm);

           -- notify caller of an UNEXPETED error
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END update_contract_header;

  PROCEDURE delete_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN OKC_CHR_PVT.chrv_rec_type) IS

    l_dummy_val         NUMBER;
    l_major_version      FND_ATTACHED_DOCUMENTS.PK2_VALUE%TYPE;

    Cursor l_clev_csr Is
                select count(*)
                from OKC_K_LINES_B
                where chr_id = p_chrv_rec.id;

    Cursor l_crjv_csr Is
                SELECT id, object_version_number
                FROM OKC_K_REL_OBJS
                WHERE chr_id = p_chrv_rec.id;

    Cursor l_cvm_csr Is
                SELECT to_char(major_version)
                FROM okc_k_vers_numbers
                WHERE chr_id = p_chrv_rec.id;

    Cursor oie_csr Is
                 SELECT id
                 FROM okc_operation_instances
                 WHERE target_chr_id = p_chrv_rec.id;

    Cursor l_scrv_csr Is    --sales credit
                SELECT id, object_version_number, dnz_chr_id
                FROM okc_k_sales_credits
                WHERE chr_id = p_chrv_rec.id;
   Cursor cur_status Is
                SELECT ste_code from okc_statuses_b status, okc_k_headers_b header
                where status.code = header.sts_code
                AND header.id  = p_chrv_rec.id;



    l_crjv_rec  OKC_K_REL_OBJS_PUB.crjv_rec_type;
    l_oiev_tbl OKC_OPER_INST_PUB.oiev_tbl_type;
    i NUMBER := 0;

    l_scrv_rec  OKC_SALES_credit_PUB.scrv_rec_type;
    l_chr_status OKC_K_HEADERS_B.STS_CODE%TYPE;


  BEGIN
    -- check whether delete is allowed or not
    If (OKC_CONTRACT_PUB.Update_Allowed(p_chrv_rec.id) <> 'Y') Then
          raise G_NO_UPDATE_ALLOWED_EXCEPTION;
    End If;

    -- check whether detail records exists
    open l_clev_csr;
    fetch l_clev_csr into l_dummy_val;
    close l_clev_csr;

    -- delete only if there are no detail records
    If (l_dummy_val = 0) Then

          --
          -- Delete all related data that calls Update Minor Version procedure
          --
          -- Delete sales credits

       For c In l_scrv_csr
       Loop
                l_scrv_rec.id := c.id;
                l_scrv_rec.object_version_number := c.object_version_number;
                l_scrv_rec.dnz_chr_id := c.dnz_chr_id;

                OKC_SALES_credit_PUB.delete_Sales_credit(
                        p_api_version   => p_api_version,
                        p_init_msg_list => p_init_msg_list,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data,
                p_scrv_rec              => l_scrv_rec);

       End Loop;

       Open cur_status;
         Fetch cur_status into l_chr_status;
       Close cur_status;
       If  l_chr_status In ('ENTERED','CANCELLED')
       Then
         OKC_VERSION_PVT.delete_version (p_chr_id   => p_chrv_rec.id,
                                         p_major_version => 0,
                                         p_minor_version => 0,
                                         p_called_from =>  'RESTORE_VERSION');
       End if;

       OKC_CHR_PVT.Delete_Row(
                        p_api_version           => p_api_version,
                        p_init_msg_list => p_init_msg_list,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data,
                p_chrv_rec              => p_chrv_rec);
    Else
            OKC_API.SET_MESSAGE(p_app_name              => g_app_name,
                                            p_msg_name          => g_no_parent_record,
                                            p_token1            => g_child_table_token,
                                            p_token1_value      => 'OKC_K_LINES_V',
                                            p_token2            => g_parent_table_token,
                                            p_token2_value      => 'OKC_K_HEADERS_V');
            -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;
    End If;

    -- Delete operation instances (renewal links)
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
          FOR oie_rec IN oie_csr
          LOOP
                 i := i + 1;
           l_oiev_tbl(i).ID := oie_rec.ID;
          END LOOP;

       If (i > 0) Then
          OKC_OPER_INST_PUB.Delete_Operation_Instance (
                 p_api_version          => p_api_version,
                 p_init_msg_list             => p_init_msg_list,
              x_return_status   => x_return_status,
              x_msg_count       => x_msg_count,
              x_msg_data        => x_msg_data,
              p_oiev_tbl                     => l_oiev_tbl);
          End if;
    End if;

    -- Delete relationships with header and other objects
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
           For c In l_crjv_csr
           Loop
                l_crjv_rec.id := c.id;
                l_crjv_rec.object_version_number := c.object_version_number;

                OKC_K_REL_OBJS_PUB.delete_row(
                        p_api_version           => p_api_version,
                        p_init_msg_list => p_init_msg_list,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data,
                p_crjv_rec              => l_crjv_rec);

           End Loop;
    End If;



    -- get major version
    open l_cvm_csr;
    fetch l_cvm_csr into l_major_version;
    close l_cvm_csr;

    -- Delete any attachments assiciated
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
          If (fnd_attachment_util_pkg.get_atchmt_exists (
                                        l_entity_name => 'OKC_K_HEADERS_B',
                         l_pkey1 => p_chrv_rec.id,
                                        l_pkey2 => l_major_version) = 'Y')

                            -- The following line to be added to the code once
                         -- bug 1553916 completes
                   --    l_pkey2 => l_major_version) = 'Y')
                            -- also below remove the comments
                            -- in fnd_attached_documents2_pkg.delete_attachments call
       Then
           fnd_attached_documents2_pkg.delete_attachments(
                         x_entity_name => 'OKC_K_HEADERS_B',
                                        x_pk1_value   => p_chrv_rec.id,
                                     x_pk2_value   => l_major_version
                                        );
       End If;
    End If;

    -- Delete version
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
          x_return_status := Delete_Version(p_chrv_rec.id);
    End If;
  exception
    when G_NO_UPDATE_ALLOWED_EXCEPTION then
          x_return_status := OKC_API.G_RET_STS_ERROR;
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_no_update_allowed,
                                          p_token1              => 'VALUE1',
                                          p_token1_value        => 'Contract Header');
    when OTHERS then
          -- store SQL error message on message stack
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_unexpected_error,
                                          p_token1              => g_sqlcode_token,
                                          p_token1_value        => sqlcode,
                                          p_token2              => g_sqlerrm_token,
                                          p_token2_value        => sqlerrm);

           -- notify caller of an UNEXPETED error
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END delete_contract_header;

  PROCEDURE delete_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN OKC_CHR_PVT.chrv_tbl_type) IS

  BEGIN
    OKC_CHR_PVT.Delete_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_chrv_tbl                => p_chrv_tbl);
  END delete_contract_header;

  PROCEDURE lock_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN OKC_CHR_PVT.chrv_rec_type) IS

  BEGIN
    OKC_CHR_PVT.Lock_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_chrv_rec                => p_chrv_rec);
  END lock_contract_header;

  PROCEDURE lock_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN OKC_CHR_PVT.chrv_tbl_type) IS

  BEGIN
    OKC_CHR_PVT.Lock_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_chrv_tbl                => p_chrv_tbl);
  END lock_contract_header;

  PROCEDURE validate_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN OKC_CHR_PVT.chrv_rec_type) IS

  BEGIN
    OKC_CHR_PVT.Validate_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_chrv_rec                => p_chrv_rec);
  END validate_contract_header;

  PROCEDURE validate_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN OKC_CHR_PVT.chrv_tbl_type) IS

  BEGIN
    OKC_CHR_PVT.Validate_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_chrv_tbl                => p_chrv_tbl);
  END validate_contract_header;

  PROCEDURE create_ancestry(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  OKC_CLE_PVT.clev_rec_type) Is

    l_acyv_rec          OKC_ACY_PVT.acyv_rec_type;
    l_out_rec           OKC_ACY_PVT.acyv_rec_type;
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    -- cursor to get the next level_sequence
    Cursor l_acyv_csr Is
                select NVL(MAX(level_sequence),0) + 1
                from OKC_ANCESTRYS
                where cle_id = p_clev_rec.cle_id;

    -- cursor to get other ascendants
    Cursor l_acyv_csr2 Is
                select cle_id_ascendant, level_sequence
                from OKC_ANCESTRYS
                where cle_id = p_clev_rec.cle_id;

  BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
        -- insert ancestry, if line record has a parent line record
        If (p_clev_rec.cle_id <> OKC_API.G_MISS_NUM and
            p_clev_rec.cle_id is not null)
        Then
                -- get next level sequence
                open l_acyv_csr;
                fetch l_acyv_csr into l_acyv_rec.level_sequence;
                close l_acyv_csr;

                l_acyv_rec.cle_id                       := p_clev_rec.id;
                l_acyv_rec.cle_id_ascendant     := p_clev_rec.cle_id;

                -- insert currect record to ancestry
                OKC_ACY_PVT.insert_row(
                                p_api_version     => p_api_version,
                                p_init_msg_list   => p_init_msg_list,
                                x_return_status   => l_return_status,
                                x_msg_count       => x_msg_count,
                                x_msg_data        => x_msg_data,
                                p_acyv_rec        => l_acyv_rec,
                                x_acyv_rec        => l_out_rec);

                -- if the current insert is success,
                -- copy all other existing ancestry records of
                -- parent line (p_clev_rec.cle_id)
                If (l_return_status = OKC_API.G_RET_STS_SUCCESS) Then
                        open l_acyv_csr2;

                        -- fetch first record
                        fetch l_acyv_csr2 into l_acyv_rec.cle_id_ascendant,
                                                           l_acyv_rec.level_sequence;
                        while l_acyv_csr2%FOUND
                        loop
                                OKC_ACY_PVT.insert_row(
                                        p_api_version     => p_api_version,
                                        p_init_msg_list   => p_init_msg_list,
                                        x_return_status   => l_return_status,
                                        x_msg_count       => x_msg_count,
                                        x_msg_data        => x_msg_data,
                                        p_acyv_rec        => l_acyv_rec,
                                        x_acyv_rec        => l_out_rec);

                                -- fetch next record
                                fetch l_acyv_csr2 into l_acyv_rec.cle_id_ascendant,
                                                                   l_acyv_rec.level_sequence;
                        end loop;
                        close l_acyv_csr2;
                End If;
        End If;
  exception
    when OTHERS then
          -- store SQL error message on message stack
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_unexpected_error,
                                          p_token1              => g_sqlcode_token,
                                          p_token1_value        => sqlcode,
                                          p_token2              => g_sqlerrm_token,
                                          p_token2_value        => sqlerrm);

           -- notify caller of an UNEXPETED error
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursors were closed
        if l_acyv_csr%ISOPEN then
              close l_acyv_csr;
        end if;

        if l_acyv_csr2%ISOPEN then
              close l_acyv_csr2;
        end if;

  END create_ancestry;

  --
  -- This procedure returns the contract header id corresponding to the
  -- contract line record
  -- Called only if dnz_chr_id is null in clev_rec
  --
  PROCEDURE Get_Contract_Id(p_clev_rec          IN OKC_CLE_PVT.clev_rec_type,
                                        x_chr_id         OUT NOCOPY NUMBER,
                                        x_return_status OUT NOCOPY VARCHAR2) Is
    Cursor l_clev_csr Is
                SELECT dnz_chr_id
                FROM OKC_K_LINES_B
                WHERE id = p_clev_rec.id;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
  -- if dnz_chr_id is present, return it
  If (p_clev_rec.dnz_chr_id is not null and
           p_clev_rec.dnz_chr_id <> OKC_API.G_MISS_NUM)
  Then
             x_chr_id := p_clev_rec.dnz_chr_id;
  Else
    -- else if chr_id is present , return it
    If (p_clev_rec.chr_id is not null and
           p_clev_rec.chr_id <> OKC_API.G_MISS_NUM)
    Then
          x_chr_id := p_clev_rec.chr_id;
    Else
          -- else get header id from database
          Open l_clev_csr;
          Fetch l_clev_csr into x_chr_id;
          If (l_clev_csr%NOTFOUND) Then
                Close l_clev_csr;
                x_return_status := OKC_API.G_RET_STS_ERROR;
                RAISE OKC_API.G_EXCEPTION_ERROR;
          End If;
          Close l_clev_csr;
    End If;
  End If;
  exception
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_unexpected_error,
                                          p_token1              => g_sqlcode_token,
                                          p_token1_value        => sqlcode,
                                          p_token2              => g_sqlerrm_token,
                                          p_token2_value        => sqlerrm);
      x_return_status :=OKC_API.G_RET_STS_ERROR;

    when OTHERS then
          -- store SQL error message on message stack
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_unexpected_error,
                                          p_token1              => g_sqlcode_token,
                                          p_token1_value        => sqlcode,
                                          p_token2              => g_sqlerrm_token,
                                          p_token2_value        => sqlerrm);

           -- notify caller of an UNEXPETED error
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Get_Contract_Id;

  PROCEDURE create_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update                 IN VARCHAR2 ,
    p_clev_rec                     IN  OKC_CLE_PVT.clev_rec_type,
    x_clev_rec                     OUT NOCOPY  OKC_CLE_PVT.clev_rec_type) IS

    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_chr_id            NUMBER;
  BEGIN
    -- check whether the contract is updateable or not
    OKC_CONTRACT_PVT.Get_Contract_Id(
                p_clev_rec       => p_clev_rec,
                x_chr_id                 => l_chr_id,
                x_return_status => l_return_status);

    If (l_return_status = OKC_API.G_RET_STS_SUCCESS) Then
       -- if the update is not a restricted update (restricted_update <> 'Y'),
       -- check whether update is allowed or not
       If (p_restricted_update <> OKC_API.G_TRUE) Then
          If (OKC_CONTRACT_PUB.Update_Allowed(l_chr_id) <> 'Y') Then
                raise G_NO_UPDATE_ALLOWED_EXCEPTION;
          End If;
       End If;
    Else
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    End If;

    OKC_CLE_PVT.Insert_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_clev_rec                => p_clev_rec,
      x_clev_rec                => x_clev_rec);
         -- if the above process is success, create ancestry
         If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
         x_clev_rec.cle_id := p_clev_rec.cle_id;
            create_ancestry(
                        p_api_version           => p_api_version,
                        p_init_msg_list => p_init_msg_list,
                        x_return_status => l_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data,
                        p_clev_rec              => x_clev_rec);
        Else
           raise G_EXCEPTION_HALT_PROCESS;
        End If;

    -- Update minor version
    If (l_return_status = OKC_API.G_RET_STS_SUCCESS) Then
          x_return_status := Update_Minor_Version(x_clev_rec.dnz_chr_id);
    End If;
  exception
    when G_EXCEPTION_HALT_PROCESS then
         null;

    when G_NO_UPDATE_ALLOWED_EXCEPTION then
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_no_update_allowed,
                                          p_token1              => 'VALUE1',
                                          p_token1_value        => 'Contract Lines');

          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
    when OTHERS then
          -- store SQL error message on message stack
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_unexpected_error,
                                          p_token1              => g_sqlcode_token,
                                          p_token1_value        => sqlcode,
                                          p_token2              => g_sqlerrm_token,
                                          p_token2_value        => sqlerrm);

           -- notify caller of an UNEXPETED error
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END create_contract_line;

  PROCEDURE create_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  OKC_CLE_PVT.clev_tbl_type,
    x_clev_tbl                     OUT NOCOPY  OKC_CLE_PVT.clev_tbl_type) IS

  BEGIN
    OKC_CLE_PVT.Insert_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_clev_tbl                => p_clev_tbl,
      x_clev_tbl                => x_clev_tbl);
  END create_contract_line;

  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update                 IN VARCHAR2 ,
    p_clev_rec                     IN OKC_CLE_PVT.clev_rec_type,
    x_clev_rec                     OUT NOCOPY OKC_CLE_PVT.clev_rec_type) IS

    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_chr_id            NUMBER;
    l_api_name          CONSTANT        VARCHAR2(30) := 'Update_Contract_Line';

    l_contract_number VARCHAR2(120);
    l_modifier        VARCHAR2(120);
    Cursor l_chr_csr(p_id NUMBER) Is
                 SELECT contract_number,contract_number_modifier
                 --npalepu 26-10-2005 modified for bug # 4691662.
                 --Replaced table okc_k_headers_b with headers_All_b table
                 /*  FROM okc_k_headers_b */
                 FROM okc_k_headers_all_b
                 --end npalepu
                 where id = p_id;
  BEGIN
    -- check whether the contract is updateable or not
    OKC_CONTRACT_PVT.Get_Contract_Id(
                p_clev_rec       => p_clev_rec,
                x_chr_id                 => l_chr_id,
                x_return_status => l_return_status);

    If (l_return_status = OKC_API.G_RET_STS_SUCCESS) Then
       -- if the update is not a restricted update (restricted_update <> 'Y'),
       -- check whether update is allowed or not
       If (p_restricted_update <> OKC_API.G_TRUE) Then
          If (OKC_CONTRACT_PUB.Update_Allowed(l_chr_id) <> 'Y') Then
                raise G_NO_UPDATE_ALLOWED_EXCEPTION;
          End If;
       End If;
    Else
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    End If;
    OKC_CLE_PVT.Update_Row(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data,
         p_restricted_update    => p_restricted_update,
      p_clev_rec                        => p_clev_rec,
      x_clev_rec                        => x_clev_rec);

    -- Call action assembler if status is changed
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS AND
           NVL(p_clev_rec.Call_Action_Asmblr,'Y') = 'Y' AND
        p_clev_rec.old_sts_code is not null AND
        p_clev_rec.new_sts_code is not null AND
        p_clev_rec.old_ste_code is not null AND
           p_clev_rec.new_ste_code is not null AND
           (p_clev_rec.old_sts_code <> p_clev_rec.new_sts_code OR
            p_clev_rec.old_ste_code <> p_clev_rec.new_ste_code
           )
       )
    Then
           open l_chr_csr(x_clev_rec.dnz_chr_id);
           fetch l_chr_csr into l_contract_number,l_modifier;
           close l_chr_csr;

        OKC_KL_STS_CHG_ASMBLR_PVT.Acn_Assemble(
                 p_api_version    => p_api_version,
                 p_init_msg_list   => p_init_msg_list,
              x_return_status     => x_return_status,
              x_msg_count         => x_msg_count,
              x_msg_data          => x_msg_data,
              p_k_id            => x_clev_rec.dnz_chr_id,
                    p_kl_id           => x_clev_rec.id,
                    p_k_number        => l_contract_number,
                    p_k_nbr_mod       => l_modifier,
                    p_kl_number       => x_clev_rec.line_number,
                    p_kl_cur_sts_code => p_clev_rec.new_sts_code,
                    p_kl_cur_sts_type => p_clev_rec.new_ste_code,
                    p_kl_pre_sts_code => p_clev_rec.old_sts_code,
              p_kl_pre_sts_type => p_clev_rec.old_ste_code,
              p_kl_source_system_code => p_clev_rec.ORIG_SYSTEM_SOURCE_CODE);
    End If;

    -- Update minor version
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
          x_return_status := Update_Minor_Version(x_clev_rec.dnz_chr_id);
    End If;
  exception
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    when G_NO_UPDATE_ALLOWED_EXCEPTION then
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_no_update_allowed,
                                          p_token1              => 'VALUE1',
                                          p_token1_value        => 'Contract Lines');

          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
    when OTHERS then
          -- store SQL error message on message stack
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_unexpected_error,
                                          p_token1              => g_sqlcode_token,
                                          p_token1_value        => sqlcode,
                                          p_token2              => g_sqlerrm_token,
                                          p_token2_value        => sqlerrm);

           -- notify caller of an UNEXPETED error
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END update_contract_line;

  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update                 IN VARCHAR2 ,
    p_clev_tbl                     IN OKC_CLE_PVT.clev_tbl_type,
    x_clev_tbl                     OUT NOCOPY OKC_CLE_PVT.clev_tbl_type) IS

  BEGIN
    OKC_CLE_PVT.Update_Row(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data,
         p_restricted_update    => p_restricted_update,
      p_clev_tbl                        => p_clev_tbl,
      x_clev_tbl                        => x_clev_tbl);
  END update_contract_line;

  PROCEDURE delete_ancestry(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_id                       IN  NUMBER) Is

    l_acyv_rec          OKC_ACY_PVT.acyv_rec_type;
    l_out_rec           OKC_ACY_PVT.acyv_rec_type;
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    -- cursor to get ancestry records to delete
    Cursor l_acyv_csr Is
                select cle_id, cle_id_ascendant
                from OKC_ANCESTRYS
                where cle_id = p_cle_id;

  BEGIN
        -- delete all ancestry records if p_cle_id is not null
        If (p_cle_id <> OKC_API.G_MISS_NUM and
            p_cle_id is not null)
        Then
                open l_acyv_csr;

                -- fetch first record
                fetch l_acyv_csr into l_acyv_rec.cle_id,
                                                  l_acyv_rec.cle_id_ascendant;
                while l_acyv_csr%FOUND
                loop
                        OKC_ACY_PVT.delete_row(
                                p_api_version     => p_api_version,
                                p_init_msg_list   => p_init_msg_list,
                                x_return_status   => l_return_status,
                                x_msg_count       => x_msg_count,
                                x_msg_data        => x_msg_data,
                                p_acyv_rec        => l_acyv_rec);
                        If (l_return_status <> OKC_API.G_RET_STS_SUCCESS) Then
                           raise G_EXCEPTION_HALT_VALIDATION;
                        End If;
                        -- fetch next record
                        fetch l_acyv_csr into l_acyv_rec.cle_id,
                                                          l_acyv_rec.cle_id_ascendant;
                end loop;
                close l_acyv_csr;
                x_return_status := l_return_status;
        End If;
  exception
    when G_EXCEPTION_HALT_VALIDATION then
          -- store SQL error message on message stack
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_unexpected_error,
                                          p_token1              => g_sqlcode_token,
                                          p_token1_value        => sqlcode,
                                          p_token2              => g_sqlerrm_token,
                                          p_token2_value        => sqlerrm);
          x_return_status := l_return_status;

    when OTHERS then
          -- store SQL error message on message stack
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_unexpected_error,
                                          p_token1              => g_sqlcode_token,
                                          p_token1_value        => sqlcode,
                                          p_token2              => g_sqlerrm_token,
                                          p_token2_value        => sqlerrm);

           -- notify caller of an UNEXPETED error
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
        if l_acyv_csr%ISOPEN then
              close l_acyv_csr;
        end if;

  END delete_ancestry;

  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN OKC_CLE_PVT.clev_rec_type) IS

    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_chr_id            NUMBER;
    l_dummy_val NUMBER;
    l_major_version FND_ATTACHED_DOCUMENTS.PK2_VALUE%TYPE;

    Cursor l_clev_csr Is
                select count(*)
                from OKC_K_LINES_B
                where cle_id = p_clev_rec.id;

    Cursor l_cimv_csr Is
                select count(*)
                from OKC_K_ITEMS
                where cle_id = p_clev_rec.id;

    Cursor l_crjv_csr Is
                SELECT id, object_version_number
                FROM OKC_K_REL_OBJS
                WHERE cle_id = p_clev_rec.id;

    Cursor l_cvm_csr(p_chr_id NUMBER) Is
                SELECT to_char(major_version)
                FROM okc_k_vers_numbers
                WHERE chr_id = p_chr_id;


    Cursor l_scrv_csr Is
                SELECT id, object_version_number, dnz_chr_id
                FROM okc_k_sales_credits
                WHERE cle_id = p_clev_rec.id;

    Cursor l_okc_ph_line_breaks_v_csr Is
                SELECT id, object_version_number, cle_id
                FROM okc_ph_line_breaks
                WHERE cle_id = p_clev_rec.id;

    -- Bug #3358872; Added condition dnz_chr_id to improve the
    -- performance of the sql.

    Cursor l_gvev_csr Is
         SELECT id, object_version_number
         FROM   okc_governances
         WHERE  cle_id = p_clev_rec.id
         AND    dnz_chr_id = l_chr_id;


    l_crjv_rec  OKC_K_REL_OBJS_PUB.crjv_rec_type;
    i NUMBER := 0;

    l_scrv_rec  OKC_SALES_credit_PUB.scrv_rec_type;


    l_okc_ph_line_breaks_v_rec  OKC_PH_LINE_BREAKS_PUB.okc_ph_line_breaks_v_rec_type;
    l_lse_id            NUMBER;  --linestyle
    l_dnz_chr_id        NUMBER;
    l_ph_pricing_type   VARCHAR2(30);

    l_gvev_rec          OKC_GVE_PVT.gvev_rec_type;


  BEGIN
    -- check whether the contract is updateable or not
    OKC_CONTRACT_PVT.Get_Contract_Id(
                p_clev_rec       => p_clev_rec,
                x_chr_id                 => l_chr_id,
                x_return_status => l_return_status);

    If (l_return_status = OKC_API.G_RET_STS_SUCCESS) Then
       If (OKC_CONTRACT_PUB.Update_Allowed(l_chr_id) <> 'Y') Then
             raise G_NO_UPDATE_ALLOWED_EXCEPTION;
       End If;
    End If;

    -- check whether detail records exists
    open l_clev_csr;
    fetch l_clev_csr into l_dummy_val;
    close l_clev_csr;

    -- delete only if there are no detail records
    If (l_dummy_val = 0) Then
          -- check if there are any items exist for this contract line
          open l_cimv_csr;
          fetch l_cimv_csr into l_dummy_val;
          close l_cimv_csr;

          -- delete only if there are no items
          If (l_dummy_val = 0) Then
          OKC_CLE_PVT.Delete_Row(
                   p_api_version        => p_api_version,
                   p_init_msg_list      => p_init_msg_list,
           x_return_status      => x_return_status,
           x_msg_count          => x_msg_count,
           x_msg_data           => x_msg_data,
           p_clev_rec           => p_clev_rec);

             -- if the above process is success, delete all ancestrys
             If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
                   delete_ancestry(
                           p_api_version        => p_api_version,
                           p_init_msg_list      => p_init_msg_list,
                           x_return_status      => x_return_status,
                           x_msg_count          => x_msg_count,
                           x_msg_data           => x_msg_data,
                           p_cle_id             => p_clev_rec.id);
             End If;

          Else
             OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                                             p_msg_name => g_no_parent_record,
                                             p_token1           => g_child_table_token,
                                             p_token1_value     => 'OKC_K_ITEMS_V',
                                             p_token2           => g_parent_table_token,
                                             p_token2_value     => 'OKC_K_LINES_V');
             -- notify caller of an error
             x_return_status := OKC_API.G_RET_STS_ERROR;
          End If;
    Else
            OKC_API.SET_MESSAGE(p_app_name              => g_app_name,
                                            p_msg_name          => g_no_parent_record,
                                            p_token1            => g_child_table_token,
                                            p_token1_value      => 'OKC_K_LINES_V',
                                            p_token2            => g_parent_table_token,
                                            p_token2_value      => 'OKC_K_LINES_V');
            -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;
    End If;

    -- Delete relationships with line and other objects
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
           For c In l_crjv_csr
           Loop
                l_crjv_rec.id := c.id;
                l_crjv_rec.object_version_number := c.object_version_number;

                OKC_K_REL_OBJS_PUB.delete_row(
                        p_api_version           => p_api_version,
                        p_init_msg_list => p_init_msg_list,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data,
                p_crjv_rec              => l_crjv_rec);

           End Loop;
    End If;

    -- Delete sales credits
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
           For c In l_scrv_csr
           Loop
                l_scrv_rec.id := c.id;
                l_scrv_rec.object_version_number := c.object_version_number;
                l_scrv_rec.dnz_chr_id := c.dnz_chr_id;

                OKC_SALES_credit_PUB.delete_Sales_credit(
                        p_api_version   => p_api_version,
                        p_init_msg_list => p_init_msg_list,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data,
                p_scrv_rec              => l_scrv_rec);

           End Loop;
    End If;


    -- Delete price hold line breaks
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then

         /**********************************************
              don't need to do this for delete
         --added for price hold top lines
         IF l_lse_id = 61 THEN
              --if the contract line being deleted is a Price Hold top line,
              --we need to delete the corresponding entries in QP

              OKC_PHI_PVT.process_price_hold(
                      p_api_version    => p_api_version,
                      p_init_msg_list  => p_init_msg_list,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data,
                      p_chr_id         => l_dnz_chr_id,
                      p_operation_code => 'TERMINATE');
         END IF;
         ****************************************************/

         --added for price hold sublines
         IF l_ph_pricing_type = 'PRICE_BREAK' THEN
            --if the contract line being deleted is a Price Hold sub line with pricing type of 'Price Break'
            --we need to delete the price hold line breaks as well

            For c In l_okc_ph_line_breaks_v_csr
            Loop
                l_okc_ph_line_breaks_v_rec.id := c.id;
                l_okc_ph_line_breaks_v_rec.object_version_number := c.object_version_number;
                l_okc_ph_line_breaks_v_rec.cle_id := c.cle_id;

                OKC_PH_LINE_BREAKS_PUB.delete_Price_Hold_Line_Breaks(
                      p_api_version   => p_api_version,
                      p_init_msg_list => p_init_msg_list,
                      x_return_status => x_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      p_okc_ph_line_breaks_v_rec => l_okc_ph_line_breaks_v_rec
                );
            End Loop;
          End If;


    End If;


    -- Delete all contract governances information at the line level
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
       --(note: we do not have to write code to delete goverances in delete_contract_header because
       --that is already being done in okc_delete_contract_pvt.delete_contract where the delete is done
       --on the basis of dnz_chr_id so lines are deleted there as well)

        For c In l_gvev_csr
        Loop

            l_gvev_rec.id := c.id;
            l_gvev_rec.object_version_number := c.object_version_number;

            OKC_GVE_PVT.Delete_Row(
                     p_api_version      => p_api_version,
                     p_init_msg_list    => p_init_msg_list,
                     x_return_status    => x_return_status,
                     x_msg_count        => x_msg_count,
                     x_msg_data         => x_msg_data,
                     p_gvev_rec         => l_gvev_rec
            );

        End Loop;

    End If;


    -- get major version
    open l_cvm_csr(l_chr_id);
    fetch l_cvm_csr into l_major_version;
    close l_cvm_csr;

    -- Delete any attachments assiciated with this line
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
          If (fnd_attachment_util_pkg.get_atchmt_exists (
                                        l_entity_name => 'OKC_K_LINES_B',
                         l_pkey1 => p_clev_rec.id,
                         l_pkey2 => l_major_version) = 'Y')

                                        -- The following line to be added to the code once
                                        -- bug 1553916 completes
                         -- l_pkey2 => l_major_version) = 'Y')
                                        -- also below remove the comments
                                        -- in fnd_attached_documents2_pkg.delete_attachments call
       Then
           fnd_attached_documents2_pkg.delete_attachments(
                         x_entity_name => 'OKC_K_LINES_B',
                                        x_pk1_value   => p_clev_rec.id,
                                     x_pk2_value   => l_major_version
                                        );
       End If;
    End If;

    -- Update minor version
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
          x_return_status := Update_Minor_Version(l_chr_id);
    End If;
  exception
    when G_NO_UPDATE_ALLOWED_EXCEPTION then
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_no_update_allowed,
                                          p_token1              => 'VALUE1',
                                          p_token1_value        => 'Contract Lines');

          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
    when OTHERS then
          -- store SQL error message on message stack
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_unexpected_error,
                                          p_token1              => g_sqlcode_token,
                                          p_token1_value        => sqlcode,
                                          p_token2              => g_sqlerrm_token,
                                          p_token2_value        => sqlerrm);

           -- notify caller of an UNEXPETED error
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END delete_contract_line;

  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN OKC_CLE_PVT.clev_tbl_type) IS

  BEGIN
    OKC_CLE_PVT.Delete_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_clev_tbl                => p_clev_tbl);
  END delete_contract_line;

  PROCEDURE delete_contract_line(
      p_api_version         IN NUMBER,
      p_init_msg_list         IN VARCHAR2 ,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,
      p_line_id               IN NUMBER) IS

  l_Cov_cle_Id NUMBER;
  l_Item_id     NUMBER;
  l_contact_Id NUMBER;
  l_RGP_Id     NUMBER;
  l_Rule_Id    NUMBER;
  l_cle_Id     NUMBER;
  l_chr_id     NUMBER;
  v_Index   Binary_Integer;

  CURSOR DNZ_Cur(p_id NUMBER) IS
         SELECT dnz_chr_id
         FROM okc_k_lines_b
         WHERE id = p_id;
  CURSOR Child_Cur1(P_Parent_Id IN NUMBER)
   IS SELECT ID
      FROM   Okc_K_Lines_b
      WHERE  cle_Id=P_Parent_Id;
   CURSOR Child_Cur2(P_Parent_Id IN NUMBER)
   IS SELECT ID
      FROM   Okc_K_Lines_b
      WHERE  cle_Id=P_Parent_Id;
   CURSOR Child_Cur3(P_Parent_Id IN NUMBER)
   IS SELECT ID
      FROM   Okc_K_Lines_b
      WHERE  cle_Id=P_Parent_Id;
   CURSOR Child_Cur4(P_Parent_Id IN NUMBER)
   IS SELECT ID
      FROM   Okc_K_Lines_b
      WHERE  cle_Id=P_Parent_Id;
   CURSOR Child_Cur5(P_Parent_Id IN NUMBER)
   IS SELECT ID
      FROM   Okc_K_Lines_b
      WHERE  cle_Id=P_Parent_Id;

   CURSOR Item_Cur(P_Line_Id IN NUMBER)
   IS SELECT ID
      FROM   Okc_K_ITEMS
      WHERE  cle_Id=P_Line_Id;

   CURSOR  RT_Cur(P_Rule_Id IN NUMBER)
   IS SELECT Tve_ID
      FROM   OKC_React_Intervals
      WHERE  Rul_Id =P_Rule_Id;

   CURSOR Kprl_Cur(P_cle_Id IN NUMBER) IS
   SELECT ID FROM OKC_K_PARTY_ROLES_B
   WHERE  dnz_chr_id = l_chr_id
   AND    cle_Id=P_cle_Id;

   CURSOR Contact_Cur(P_cpl_Id IN NUMBER) IS
   SELECT ID FROM OKC_CONTACTS
   WHERE  cpl_Id=P_cpl_Id;

   CURSOR TRule_Cur( P_Rgp_Id IN NUMBER,
                     P_Rule_Type IN Varchar2) IS
    SELECT ID FROM OKC_RULES_B
    WHERE  Rgp_Id=P_Rgp_Id
    AND    Rule_Information_category=P_rule_Type;

   CURSOR Rl_Cur(P_Rgp_Id IN NUMBER) IS
    SELECT ID FROM OKC_RULES_B
    WHERE  Rgp_Id=P_Rgp_Id;

   CURSOR Rgp_Cur(P_cle_Id IN NUMBER) IS
    SELECT ID FROM OKC_RULE_GROUPS_B
    WHERE  cle_Id=P_Cle_Id;

   CURSOR  Relobj_Cur(P_Cle_Id IN NUMBER) IS
    SELECT Id FROM OKC_K_REL_OBJS
    WHERE  cle_Id = P_cle_Id;

    n NUMBER:=0;
    l_clev_tbl_in     okc_contract_pub.clev_tbl_type;
    l_clev_tbl_tmp    okc_contract_pub.clev_tbl_type;
    l_rgpv_tbl_in     okc_rule_pub.rgpv_tbl_type;
    l_rulv_tbl_in     okc_rule_pub.rulv_tbl_type;
    l_cimv_tbl_in     okc_Contract_Item_Pub.cimv_tbl_TYPE;
    l_ctcv_tbl_in       okc_contract_party_pub.ctcv_tbl_type;
    l_cplv_tbl_in       okc_contract_party_pub.cplv_tbl_type;
    l_crjv_tbl_in       okc_k_rel_objs_pub.crjv_tbl_type;
    l_api_version       CONSTANT        NUMBER          := 1.0;
    l_init_msg_list     CONSTANT        VARCHAR2(1) := 'T';
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000):=null;
    l_msg_index_out       Number;
    l_api_name            CONSTANT VARCHAR2(30) := 'Delete_Contract_Line';
    l_catv_tbl_in               okc_k_article_pub.catv_tbl_type;
    e_error               Exception;
    c_clev NUMBER:=1;
    c_rulv NUMBER:=1;
    c_rgpv NUMBER:=1;
    c_cimv NUMBER:=1;
    c_ctcv NUMBER:=1;
    c_catv NUMBER:=1;
    c_cplv NUMBER:=1;
    c_crjv NUMBER:=1;
    l_lse_Id NUMBER;

-- BUG#4066428 HKAMDAR 29-Dec-2004 Part 4
    l_meaning      VARCHAR2(80) ;
    lx_return_status     VARCHAR2(1) ;
-- BUG#4066428 HKAMDAR End Part 4
    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Line_id
    ---------------------------------------------------------------------------
    PROCEDURE Validate_Line_id(
      p_line_id          IN NUMBER,
      x_return_status   OUT NOCOPY VARCHAR2) IS
      l_return_status   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_Count   NUMBER;
      CURSOR Cur_Line(P_Line_Id IN NUMBER) IS
      SELECT COUNT(*) FROM OKC_K_LINES_B
      WHERE id=P_Line_Id;
    BEGIN
      IF P_Line_id = OKC_API.G_MISS_NUM OR
         P_Line_Id IS NULL
      THEN
        OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'P_Line_Id');

        l_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;

      OPEN Cur_Line(P_LIne_Id);
      FETCH Cur_Line INTO l_Count;
      CLOSE Cur_Line;
      IF NOT l_Count = 1
      THEN
        OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'P_Line_Id');

        l_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
      x_return_status := l_return_status;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME,
                         G_UNEXPECTED_ERROR,
                         G_SQLCODE_TOKEN,
                         SQLCODE,
                         G_SQLERRM_TOKEN,
                         SQLERRM);
        -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END Validate_Line_id;
  BEGIN
  x_return_status:=OKC_API.G_RET_STS_SUCCESS;
  Validate_Line_id(p_line_id,l_return_status);
  IF NOT l_Return_Status ='S'
  THEN RETURN;
  END IF;

  -- Get header id
  open DNZ_Cur(p_line_id);
  fetch DNZ_Cur into l_chr_id;
  close DNZ_Cur;

  l_clev_tbl_tmp(c_clev).ID:=P_Line_Id;
  c_clev:=c_clev+1;
  FOR Child_Rec1 IN Child_Cur1(P_Line_Id)
  LOOP
  l_clev_tbl_tmp(c_clev).ID:=Child_Rec1.ID;
  c_clev:=c_clev+1;
    FOR Child_Rec2 IN Child_Cur2(Child_Rec1.Id)
    LOOP
        l_clev_tbl_tmp(c_clev).ID:=Child_Rec2.Id;
          c_clev:=c_clev+1;
       FOR Child_Rec3 IN Child_Cur3(Child_Rec2.Id)
       LOOP
           l_clev_tbl_tmp(c_clev).ID:=Child_Rec3.Id;
             c_clev:=c_clev+1;
         FOR Child_Rec4 IN Child_Cur4(Child_Rec3.Id)
         LOOP
              l_clev_tbl_tmp(c_clev).ID:=Child_Rec4.Id;
                c_clev:=c_clev+1;
               FOR Child_Rec5 IN Child_Cur5(Child_Rec4.Id)
             LOOP
                l_clev_tbl_tmp(c_clev).ID:=Child_Rec5.Id;
                c_clev:=c_clev+1;
               END LOOP;
         END LOOP;
       END LOOP;
    END LOOP;
  END LOOP;
  c_clev:=1;
  FOR v_Index IN REVERSE l_clev_tbl_tmp.FIRST .. l_clev_tbl_tmp.LAST
  LOOP
  l_clev_tbl_in(c_clev).ID:= l_clev_tbl_tmp(v_Index).ID;
  c_clev:=c_Clev+1;
  END LOOP;
  -- Get Relational Objects Linked to the lines
  FOR v_Index IN l_clev_tbl_in.FIRST .. l_clev_tbl_in.LAST
  LOOP
    FOR RelObj_REC IN RelObj_Cur(l_clev_tbl_in(v_Index).ID)
    LOOP
        l_crjv_tbl_in(c_crjv).ID:= RelObj_Rec.Id;
        c_crjv:=c_crjv+1;
    END LOOP;
  END LOOP;

    -- Get Rule Groups and Rules
    FOR v_index IN l_clev_tbl_in.FIRST .. l_clev_tbl_In.LAST
    LOOP
        FOR rgp_rec IN Rgp_Cur(l_clev_tbl_in(v_index).id) LOOP
            l_Rgp_Id := rgp_rec.id;
         l_rgpv_tbl_in(c_rgpv).Id:=l_Rgp_Id;
         c_rgpv:=c_Rgpv+1;
           FOR Rl_Rec IN Rl_Cur(l_Rgp_Id)
           LOOP
              l_Rulv_tbl_in(c_rulv).ID:=Rl_Rec.ID;
              c_rulv:=c_rulv+1;
           END LOOP;
        END LOOP;
    END LOOP;

    -- Get Items
    FOR v_Index IN l_clev_tbl_in.FIRST .. l_clev_tbl_in.LAST
    LOOP
     FOR ITEM_REC IN Item_Cur(l_clev_tbl_in(v_Index).ID)
     LOOP
        l_cimv_tbl_in(c_cimv).ID:= Item_Rec.Id;
        c_cimv:=c_cimv+1;
     END LOOP;
    END LOOP;
  -- GET K Party Roles and Contacts
  FOR v_Index IN l_clev_tbl_in.FIRST .. l_clev_tbl_in.LAST
  LOOP
    FOR Kprl_REC IN Kprl_Cur(l_clev_tbl_in(v_Index).ID)
    LOOP
        l_cplv_tbl_in(c_cplv).id:=Kprl_Rec.ID;
        c_cplv:=c_cplv+1;
        FOR Contact_Rec IN Contact_Cur(Kprl_Rec.id)
        LOOP
         l_ctcv_tbl_in(c_ctcv).id:= Contact_Rec.Id;
         c_ctcv:=c_ctcv+1;
        END LOOP;
    END LOOP;
  END LOOP;

  IF NOT l_crjv_tbl_in.COUNT=0
  THEN

  OKC_K_REL_OBJS_PUB.Delete_Row(
          p_api_version                 => l_api_version,
          p_init_msg_list               => l_init_msg_list,
          x_return_status               => l_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => l_msg_data,
            p_crjv_tbl                  => l_crjv_tbl_in);

     if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
     then
        return;
     end if;
  END IF;
  IF NOT l_ctcv_tbl_in.COUNT=0
  THEN
  OKC_CONTRACT_PARTY_PUB.Delete_Contact(
          p_api_version                 => l_api_version,
          p_init_msg_list               => l_init_msg_list,
          x_return_status               => l_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => l_msg_data,
            p_ctcv_tbl                  => l_ctcv_tbl_in);

     if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
     then
        return;
     end if;
  END IF;
  IF NOT l_cplv_tbl_in.COUNT=0
  THEN
  OKC_CONTRACT_PARTY_PUB.Delete_k_Party_Role(
          p_api_version                 => l_api_version,
          p_init_msg_list               => l_init_msg_list,
          x_return_status               => l_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => l_msg_data,
            p_cplv_tbl                  => l_cplv_tbl_in);

     if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
     then
        return;
     end if;
  END IF;

  --BUG#4066428 HKAMDAR 29-Dec-2004 Part 2
   --/Rules Migration/
  Is_rule_allowed(l_chr_id,
                 'RUL',
                  lx_return_status,
                  l_meaning);

  IF lx_return_status = 'Y' Then
  -- End BUG#4066428 Part 2

    IF NOT l_rulv_tbl_in.COUNT=0
    THEN

      okc_Rule_pub.delete_Rule (
          p_api_version                 => l_api_version,
               p_init_msg_list          => l_init_msg_list,
          x_return_status               => l_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => l_msg_data,
            p_rulv_tbl                  => l_rulv_tbl_in);

      If not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
      THEN

        IF l_msg_count > 0
        THEN
         FOR i in 1..l_msg_count
         LOOP
          fnd_msg_pub.get (p_msg_index     => -1,
                           p_encoded       => 'T', -- OKC$APPLICATION.GET_FALSE,
                           p_data          => l_msg_data,
                           p_msg_index_out => l_msg_index_out);
         END LOOP;
        END IF;
        RAISE e_Error;
      End If;
    END IF;

    IF NOT l_rgpv_tbl_in.COUNT=0
    THEN
       okc_Rule_pub.delete_Rule_group (
          p_api_version         => l_api_version,
                  p_init_msg_list               => l_init_msg_list,
          x_return_status               => l_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => l_msg_data,
            p_rgpv_tbl                  => l_rgpv_tbl_in);

       if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
       then
         return;
       end if;
    END IF;

  END IF;  --BUG#4066428 HKAMDAR 29-Dec-2004 Part 3

   IF NOT l_cimv_tbl_in.COUNT=0
    THEN
       okc_contract_ITEM_pub.delete_Contract_ITEM (
          p_api_version                 => l_api_version,
               p_init_msg_list          => l_init_msg_list,
          x_return_status               => l_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => l_msg_data,
            p_cimv_tbl                  => l_cimv_tbl_in);

       IF nvl(l_return_status,'*') <> 'S'
       THEN
        IF l_msg_count > 0
          THEN
             FOR i in 1..l_msg_count
             LOOP
               fnd_msg_pub.get (p_msg_index     => -1,
                                p_encoded       => 'T', -- OKC$APPLICATION.GET_FALSE,
                                p_data          => l_msg_data,
                                p_msg_index_out => l_msg_index_out);
             END LOOP;
           END IF;

              RAISE e_Error;
       END IF;
     END IF;

  IF NOT l_clev_tbl_in.COUNT=0
  THEN
    okc_contract_pub.delete_contract_line (
          p_api_version                 => l_api_version,
          p_init_msg_list               => l_init_msg_list,
          x_return_status               => l_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => l_msg_data,
            p_clev_tbl                  => l_clev_tbl_in);

  IF nvl(l_return_status,'*') <> 'S'
  THEN
        IF l_msg_count > 0
        THEN
         FOR i in 1..l_msg_count
         LOOP
          fnd_msg_pub.get (p_msg_index     => -1,
                           p_encoded       => 'T', -- OKC$APPLICATION.GET_FALSE,
                           p_data          => l_msg_data,
                           p_msg_index_out => l_msg_index_out);
         END LOOP;
        END IF;
        RAISE e_Error;
  END IF;
  END IF;

  EXCEPTION
      WHEN e_Error THEN
      -- notify caller of an error as UNEXPETED error
      x_msg_count :=l_msg_count;
  x_msg_data:=l_msg_data;
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          'Delete_Contract_Line',
          'OKC_API.G_RET_STS_ERROR',
          l_msg_count,
          l_msg_data,
          '_PVT'
        );
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
  x_msg_count :=l_msg_count;
  x_msg_data:=l_msg_data;
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          'Delete_Contract_Line',
          'OKC_API.G_RET_STS_ERROR',
          l_msg_count,
          l_msg_data,
          '_PVT'
        );
      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
  x_msg_count :=l_msg_count;
  x_msg_data:=l_msg_data;
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          'Delete_Contract_Line',
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          l_msg_count,
          l_msg_data,
          '_PVT'
        );
      WHEN OTHERS THEN
  x_msg_count :=l_msg_count;
      OKC_API.SET_MESSAGE(
        p_app_name        => g_app_name,
        p_msg_name        => g_unexpected_error,
        p_token1                => g_sqlcode_token,
        p_token1_value    => sqlcode,
        p_token2          => g_sqlerrm_token,
        p_token2_value    => sqlerrm);
      -- notify caller of an error as UNEXPETED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END delete_contract_line;

PROCEDURE force_delete_contract_line(
  p_api_version     IN NUMBER,
  p_init_msg_list         IN VARCHAR2 ,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_line_id               IN NUMBER) IS

  l_Cov_cle_Id NUMBER;
  l_Item_id     NUMBER;
  l_contact_Id NUMBER;
  l_RGP_Id     NUMBER;
  l_Rule_Id    NUMBER;
  l_cle_Id     NUMBER;
  l_chr_id     NUMBER;
  v_Index   Binary_Integer;

  CURSOR DNZ_Cur(p_id NUMBER) IS
         SELECT dnz_chr_id
         FROM okc_k_lines_b
         WHERE id = p_id;
  CURSOR Child_Cur1(P_Parent_Id IN NUMBER)
   IS SELECT ID
      FROM   Okc_K_Lines_b
      WHERE  cle_Id=P_Parent_Id;
   CURSOR Child_Cur2(P_Parent_Id IN NUMBER)
   IS SELECT ID
      FROM   Okc_K_Lines_b
      WHERE  cle_Id=P_Parent_Id;
   CURSOR Child_Cur3(P_Parent_Id IN NUMBER)
   IS SELECT ID
      FROM   Okc_K_Lines_b
      WHERE  cle_Id=P_Parent_Id;
   CURSOR Child_Cur4(P_Parent_Id IN NUMBER)
   IS SELECT ID
      FROM   Okc_K_Lines_b
      WHERE  cle_Id=P_Parent_Id;
   CURSOR Child_Cur5(P_Parent_Id IN NUMBER)
   IS SELECT ID
      FROM   Okc_K_Lines_b
      WHERE  cle_Id=P_Parent_Id;

   CURSOR Item_Cur(P_Line_Id IN NUMBER)
   IS SELECT ID
      FROM   Okc_K_ITEMS
      WHERE  cle_Id=P_Line_Id;

   CURSOR  RT_Cur(P_Rule_Id IN NUMBER)
   IS SELECT Tve_ID
      FROM   OKC_React_Intervals
      WHERE  Rul_Id =P_Rule_Id;

   CURSOR Kprl_Cur(P_cle_Id IN NUMBER) IS
   SELECT ID FROM OKC_K_PARTY_ROLES_B
   WHERE  dnz_chr_id = l_chr_id
   AND    cle_Id=P_cle_Id;

   CURSOR Contact_Cur(P_cpl_Id IN NUMBER) IS
   SELECT ID FROM OKC_CONTACTS
   WHERE  cpl_Id=P_cpl_Id;

   CURSOR TRule_Cur( P_Rgp_Id IN NUMBER,
                     P_Rule_Type IN Varchar2) IS
    SELECT ID FROM OKC_RULES_B
    WHERE  Rgp_Id=P_Rgp_Id
    AND    Rule_Information_category=P_rule_Type;

   CURSOR Rl_Cur(P_Rgp_Id IN NUMBER) IS
    SELECT ID FROM OKC_RULES_B
    WHERE  Rgp_Id=P_Rgp_Id;

   CURSOR Rgp_Cur(P_cle_Id IN NUMBER) IS
    SELECT ID FROM OKC_RULE_GROUPS_B
    WHERE  cle_Id=P_Cle_Id;

   CURSOR  Relobj_Cur(P_Cle_Id IN NUMBER) IS
    SELECT Id FROM OKC_K_REL_OBJS
    WHERE  cle_Id = P_cle_Id;

    n NUMBER:=0;
    l_clev_tbl_in     okc_contract_pub.clev_tbl_type;
    l_clev_tbl_tmp    okc_contract_pub.clev_tbl_type;
    l_rgpv_tbl_in     okc_rule_pub.rgpv_tbl_type;
    l_rulv_tbl_in     okc_rule_pub.rulv_tbl_type;
    l_cimv_tbl_in     okc_Contract_Item_Pub.cimv_tbl_TYPE;
    l_ctcv_tbl_in       okc_contract_party_pub.ctcv_tbl_type;
    l_cplv_tbl_in       okc_contract_party_pub.cplv_tbl_type;
    l_crjv_tbl_in       okc_k_rel_objs_pub.crjv_tbl_type;
    l_api_version       CONSTANT        NUMBER          := 1.0;
    l_init_msg_list     CONSTANT        VARCHAR2(1) := 'T';
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000):=null;
    l_msg_index_out       Number;
    l_api_name            CONSTANT VARCHAR2(30) := 'Delete_Contract_Line';
    l_catv_tbl_in               okc_k_article_pub.catv_tbl_type;
    e_error               Exception;
    c_clev NUMBER:=1;
    c_rulv NUMBER:=1;
    c_rgpv NUMBER:=1;
    c_cimv NUMBER:=1;
    c_ctcv NUMBER:=1;
    c_catv NUMBER:=1;
    c_cplv NUMBER:=1;
    c_crjv NUMBER:=1;
    l_lse_Id NUMBER;

    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Line_id
    ---------------------------------------------------------------------------
    PROCEDURE Validate_Line_id(
      p_line_id          IN NUMBER,
      x_return_status   OUT NOCOPY VARCHAR2) IS
      l_return_status   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_Count   NUMBER;
      CURSOR Cur_Line(P_Line_Id IN NUMBER) IS
      SELECT COUNT(*) FROM OKC_K_LINES_B
      WHERE id=P_Line_Id;
    BEGIN

      IF (l_debug = 'Y') THEN
         okc_debug.log('100: Validate_Line_id starts', 2);
      END IF;
      IF P_Line_id = OKC_API.G_MISS_NUM OR
         P_Line_Id IS NULL
      THEN
        OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'P_Line_Id');

        l_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;

         IF (l_debug = 'Y') THEN
         okc_debug.log('200: l_return_status = ' || l_return_status, 2);
         END IF;

      OPEN Cur_Line(P_LIne_Id);
      FETCH Cur_Line INTO l_Count;
      CLOSE Cur_Line;
      IF NOT l_Count = 1
      THEN
        OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'P_Line_Id');

        l_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
      x_return_status := l_return_status;
         IF (l_debug = 'Y') THEN
         okc_debug.log('300: validate_line_id ends', 2);
         END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME,
                         G_UNEXPECTED_ERROR,
                         G_SQLCODE_TOKEN,
                         SQLCODE,
                         G_SQLERRM_TOKEN,
                         SQLERRM);
        -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
           IF (l_debug = 'Y') THEN
           okc_debug.log('300: WHEN OTHERS EXCEPTION', 2);
           END IF;
    END Validate_Line_id;

  PROCEDURE delete_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN  OKC_RULE_PUB.rulv_rec_type) IS


    --x_return_status VARCHAR2 := 'S';
    l_dummy_var VARCHAR(1) := NULL;
    i NUMBER := 0;
    CURSOR l_ctiv_csr IS
      SELECT *
        FROM OKC_COVER_TIMES_V ctiv
       WHERE ctiv.RUL_ID = p_rulv_rec.id;

    CURSOR l_atnv_csr IS
      SELECT 'x'
        FROM OKC_ARTICLE_TRANS_V atnv
       WHERE atnv.RUL_ID = p_rulv_rec.id;

    CURSOR l_rilv_csr IS
      SELECT *
        FROM OKC_REACT_INTERVALS_V rilv
       WHERE rilv.RUL_ID = p_rulv_rec.id;
    l_ctiv_tbl OKC_CTI_PVT.ctiv_tbl_type;
    l_rilv_tbl OKC_RIL_PVT.rilv_tbl_type;

  L_RIC OKC_RULES_V.RULE_INFORMATION_CATEGORY%TYPE;

  CURSOR l_ric_csr IS
    SELECT RULE_INFORMATION_CATEGORY
    FROM OKC_RULES_B
    WHERE ID = p_rulv_rec.id;
  l_col_vals  okc_time_util_pub.t_col_vals;

   --
   --l_proc varchar2(72) := g_package||'delete_rule';
   l_proc varchar2(72) := 'delete_rule';
   --
  BEGIN
IF (l_debug = 'Y') THEN
   okc_debug.log('10: starting delete rule', 2);
END IF;

     OPEN l_atnv_csr;
    FETCH l_atnv_csr into l_dummy_var;
    CLOSE l_atnv_csr;
    IF l_dummy_var = 'x' THEN
         IF (l_debug = 'Y') THEN
         okc_debug.log('G_EXCEPTION_CANNOT_DELETE');
         END IF;
      --RAISE G_EXCEPTION_CANNOT_DELETE;
    END IF;

    --populate the Foreign key of the detail
    FOR l_ctiv_rec in l_ctiv_csr LOOP
      i := i + 1;
      l_ctiv_tbl(i).rul_id := l_ctiv_rec.rul_id;
      l_ctiv_tbl(i).tve_id := l_ctiv_rec.tve_id;
    END LOOP;

    IF i > 0 THEN
    IF (l_debug = 'Y') THEN
       okc_debug.log('100: calling OKC_RULE_PUB.delete_cover_time', 2);
    END IF;
      --Delete the details
      -- call Public delete procedure
      OKC_RULE_PUB.delete_cover_time(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_ctiv_tbl      => l_ctiv_tbl);

      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         IF (l_debug = 'Y') THEN
         okc_debug.log('200: x_return_status = ' || x_return_status, 2);
         END IF;
        -- stop delete process
        RETURN;
      END IF;
    END IF;

    i := 0;
    --populate the Foreign key of the detail
    FOR l_rilv_rec in l_rilv_csr LOOP
      i := i + 1;
      l_rilv_tbl(i).rul_id := l_rilv_rec.rul_id;
      l_rilv_tbl(i).tve_id := l_rilv_rec.tve_id;
    END LOOP;

    IF i > 0 THEN
      --Delete the details
      -- call Public delete procedure
  IF (l_debug = 'Y') THEN
     okc_debug.log('300: calling OKC_RULE_PUB.delete_react_interval', 2);
  END IF;
      OKC_RULE_PUB.delete_react_interval(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_rilv_tbl      => l_rilv_tbl);

      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         IF (l_debug = 'Y') THEN
         okc_debug.log('300: x_return_status = ' || x_return_status, 2);
         END IF;
        -- stop delete process
        RETURN;
      END IF;
    END IF;
/*
--
-- added for tve_id
--
   open l_ric_csr;
   fetch l_ric_csr into L_RIC;
   close l_ric_csr;

-- /striping/
p_appl_id  := okc_rld_pvt.get_appl_id(L_RIC);
p_dff_name := okc_rld_pvt.get_dff_name(L_RIC);

--   okc_time_util_pub.get_dff_column_values( p_app_id => 510,    -- /striping/
   okc_time_util_pub.get_dff_column_values( p_app_id => p_appl_id,
--                      p_dff_name => 'OKC Rule Developer DF',    -- /striping/
                      p_dff_name => p_dff_name,
                      p_rdf_code => l_ric,
                      p_fvs_name =>'OKC_TIMEVALUES',
                      p_rule_id  =>p_rulv_rec.id,
                      p_col_vals => l_col_vals,
                      p_no_of_cols =>i );
   if (l_col_vals.COUNT>0) then
     i := l_col_vals.FIRST;
     LOOP
  IF (l_debug = 'Y') THEN
     okc_debug.log('600: calling okc_time_pub.delete_timevalues_n_tasks', 2);
  END IF;
       if (l_col_vals(i).col_value is not NULL) then
         okc_time_pub.delete_timevalues_n_tasks(
           p_api_version   => p_api_version,
           p_init_msg_list => p_init_msg_list,
           x_return_status => x_return_status,
           x_msg_count     => x_msg_count,
           x_msg_data      => x_msg_data,
             p_tve_id      => l_col_vals(i).col_value);
         IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         IF (l_debug = 'Y') THEN
         okc_debug.log('700: x_return_status = ' || x_return_status, 2);
         END IF;
           -- stop delete process
           RETURN;
         END IF;
     end if;
     EXIT WHEN (i=l_col_vals.LAST);
     i := l_col_vals.NEXT(i);
    END LOOP;
  end if;
  */
--
-- /tve_id
--
  IF (l_debug = 'Y') THEN
     okc_debug.log('800: calling OKC_RUL_PVT.delete_row', 2);
  END IF;
    OKC_RUL_PVT.delete_row(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rulv_rec      => p_rulv_rec);

         IF (l_debug = 'Y') THEN
         okc_debug.log('900: x_return_status = ' || x_return_status, 2);
         END IF;

  EXCEPTION
  /*
  WHEN G_EXCEPTION_CANNOT_DELETE THEN


    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_CANNOT_DELETE_MASTER);
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;

   */
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_ctiv_csr%ISOPEN THEN
      CLOSE l_ctiv_csr;
    END IF;
    IF l_atnv_csr%ISOPEN THEN
      CLOSE l_atnv_csr;
    END IF;
    IF l_rilv_csr%ISOPEN THEN
      CLOSE l_rilv_csr;
    END IF;
END delete_rule;

  BEGIN
IF (l_debug = 'Y') THEN
   okc_debug.log('100: starting force delete', 2);
   okc_debug.log('200: cle_id=' || to_char(p_line_id),2);
END IF;
  x_return_status:=OKC_API.G_RET_STS_SUCCESS;
  Validate_Line_id(p_line_id,l_return_status);
  IF NOT l_Return_Status ='S'
  THEN
         x_return_status := l_return_status;
IF (l_debug = 'Y') THEN
   okc_debug.log('300: Validate_Line_id failed', 2);
END IF;
         RETURN;
  END IF;

  -- Get header id
  open DNZ_Cur(p_line_id);
  fetch DNZ_Cur into l_chr_id;
  close DNZ_Cur;

  l_clev_tbl_tmp(c_clev).ID:=P_Line_Id;
  c_clev:=c_clev+1;
  FOR Child_Rec1 IN Child_Cur1(P_Line_Id)
  LOOP
  l_clev_tbl_tmp(c_clev).ID:=Child_Rec1.ID;
  c_clev:=c_clev+1;
    FOR Child_Rec2 IN Child_Cur2(Child_Rec1.Id)
    LOOP
        l_clev_tbl_tmp(c_clev).ID:=Child_Rec2.Id;
          c_clev:=c_clev+1;
       FOR Child_Rec3 IN Child_Cur3(Child_Rec2.Id)
       LOOP
           l_clev_tbl_tmp(c_clev).ID:=Child_Rec3.Id;
             c_clev:=c_clev+1;
         FOR Child_Rec4 IN Child_Cur4(Child_Rec3.Id)
         LOOP
              l_clev_tbl_tmp(c_clev).ID:=Child_Rec4.Id;
                c_clev:=c_clev+1;
               FOR Child_Rec5 IN Child_Cur5(Child_Rec4.Id)
             LOOP
                l_clev_tbl_tmp(c_clev).ID:=Child_Rec5.Id;
                c_clev:=c_clev+1;
               END LOOP;
         END LOOP;
       END LOOP;
    END LOOP;
  END LOOP;
  c_clev:=1;
  FOR v_Index IN REVERSE l_clev_tbl_tmp.FIRST .. l_clev_tbl_tmp.LAST
  LOOP
  l_clev_tbl_in(c_clev).ID:= l_clev_tbl_tmp(v_Index).ID;
  c_clev:=c_Clev+1;
  END LOOP;
  -- Get Relational Objects Linked to the lines
  FOR v_Index IN l_clev_tbl_in.FIRST .. l_clev_tbl_in.LAST
  LOOP
    FOR RelObj_REC IN RelObj_Cur(l_clev_tbl_in(v_Index).ID)
    LOOP
        l_crjv_tbl_in(c_crjv).ID:= RelObj_Rec.Id;
        c_crjv:=c_crjv+1;
    END LOOP;
  END LOOP;

  -- Get Rule Groups and Rules
  FOR v_index IN l_clev_tbl_in.FIRST .. l_clev_tbl_In.LAST
  LOOP
        FOR rgp_rec IN Rgp_Cur(l_clev_tbl_in(v_index).id) LOOP
            l_Rgp_Id := rgp_rec.id;
         l_rgpv_tbl_in(c_rgpv).Id:=l_Rgp_Id;
         c_rgpv:=c_Rgpv+1;
           FOR Rl_Rec IN Rl_Cur(l_Rgp_Id)
           LOOP
              l_Rulv_tbl_in(c_rulv).ID:=Rl_Rec.ID;
              c_rulv:=c_rulv+1;
           END LOOP;
        END LOOP;
  END LOOP;

  -- Get Items
  FOR v_Index IN l_clev_tbl_in.FIRST .. l_clev_tbl_in.LAST
  LOOP
    FOR ITEM_REC IN Item_Cur(l_clev_tbl_in(v_Index).ID)
    LOOP
        l_cimv_tbl_in(c_cimv).ID:= Item_Rec.Id;
        c_cimv:=c_cimv+1;
    END LOOP;
  END LOOP;
  -- GET K Party Roles and Contacts
  FOR v_Index IN l_clev_tbl_in.FIRST .. l_clev_tbl_in.LAST
  LOOP
    FOR Kprl_REC IN Kprl_Cur(l_clev_tbl_in(v_Index).ID)
    LOOP
        l_cplv_tbl_in(c_cplv).id:=Kprl_Rec.ID;
        c_cplv:=c_cplv+1;
        FOR Contact_Rec IN Contact_Cur(Kprl_Rec.id)
        LOOP
         l_ctcv_tbl_in(c_ctcv).id:= Contact_Rec.Id;
         c_ctcv:=c_ctcv+1;
        END LOOP;
    END LOOP;
  END LOOP;

IF (l_debug = 'Y') THEN
   okc_debug.log('400: calling OKC_K_REL_OBJS_PUB.Delete_Row', 2);
END IF;
  IF NOT l_crjv_tbl_in.COUNT=0
  THEN

  OKC_K_REL_OBJS_PUB.Delete_Row(
          p_api_version                 => l_api_version,
               p_init_msg_list          => l_init_msg_list,
          x_return_status               => l_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => l_msg_data,
            p_crjv_tbl                  => l_crjv_tbl_in);

IF (l_debug = 'Y') THEN
   okc_debug.log('500: l_return_status = ' || l_return_status, 2);
END IF;

     if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
     then
           x_return_status := l_return_status;
        return;
     end if;
  END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.log('600: calling OKC_CONTRACT_PARTY_PUB.Delete_Contact', 2);
  END IF;

  IF NOT l_ctcv_tbl_in.COUNT=0
  THEN
  OKC_CONTRACT_PARTY_PUB.Delete_Contact(
          p_api_version                 => l_api_version,
               p_init_msg_list          => l_init_msg_list,
          x_return_status               => l_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => l_msg_data,
            p_ctcv_tbl                  => l_ctcv_tbl_in);

         IF (l_debug = 'Y') THEN
         okc_debug.log('700: l_return_status = ' || l_return_status, 2);
         END IF;

     if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
     then
           x_return_status := l_return_status;
        return;
     end if;
  END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.log('800: calling OKC_CONTRACT_PARTY_PUB.Delete_k_Party_Role', 2);
  END IF;

  IF NOT l_cplv_tbl_in.COUNT=0
  THEN
  OKC_CONTRACT_PARTY_PUB.Delete_k_Party_Role(
          p_api_version                 => l_api_version,
               p_init_msg_list          => l_init_msg_list,
          x_return_status               => l_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => l_msg_data,
            p_cplv_tbl                  => l_cplv_tbl_in);

IF (l_debug = 'Y') THEN
   okc_debug.log('900: l_return_status = ' || l_return_status, 2);
END IF;
     if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
     then
           x_return_status := l_return_status;
        return;
     end if;
  END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('1000: calling okc_Rule_pub.delete_Rule', 2);
END IF;
  IF NOT l_rulv_tbl_in.COUNT=0
  THEN
    FOR i IN l_rulv_tbl_in.FIRST..l_rulv_tbl_in.LAST
    LOOP

    --okc_Rule_pub.delete_Rule (
    delete_Rule(
          p_api_version         => l_api_version,
               p_init_msg_list          => l_init_msg_list,
          x_return_status               => l_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => l_msg_data,
            p_rulv_rec                  => l_rulv_tbl_in(i));

         IF (l_debug = 'Y') THEN
         okc_debug.log('1050: l_return_status = ' || l_return_status, 2);
     okc_debug.log('1100: calling OKC_CONTRACT_PARTY_PUB.Delete_Contact', 2);
         END IF;

  if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
  THEN
 /*
        IF l_msg_count > 0
        THEN
         FOR i in 1..l_msg_count
         LOOP
          fnd_msg_pub.get (p_msg_index     => -1,
                           p_encoded       => 'T', -- OKC$APPLICATION.GET_FALSE,
                           p_data          => l_msg_data,
                           p_msg_index_out => l_msg_index_out);
         END LOOP;
        END IF;
        RAISE e_Error;
           */

           x_return_status := l_return_status;
        return;
  END IF;

  END LOOP;

  END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('1200: calling okc_Rule_pub.delete_Rule_group', 2);
END IF;

  IF NOT l_rgpv_tbl_in.COUNT=0
  THEN
    okc_Rule_pub.delete_Rule_group (
          p_api_version         => l_api_version,
                  p_init_msg_list               => l_init_msg_list,
          x_return_status               => l_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => l_msg_data,
            p_rgpv_tbl                  => l_rgpv_tbl_in);

IF (l_debug = 'Y') THEN
   okc_debug.log('1300: l_return_status = ' || l_return_status, 2);
END IF;

     if not (l_return_status = OKC_API.G_RET_STS_SUCCESS)
     then
           x_return_status := l_return_status;
        return;
     end if;
  END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('1400: calling okc_contract_ITEM_pub.delete_Contract_ITEM', 2);
END IF;

  IF NOT l_cimv_tbl_in.COUNT=0
  THEN
    okc_contract_ITEM_pub.delete_Contract_ITEM (
          p_api_version                 => l_api_version,
               p_init_msg_list          => l_init_msg_list,
          x_return_status               => l_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => l_msg_data,
            p_cimv_tbl                  => l_cimv_tbl_in);

IF (l_debug = 'Y') THEN
   okc_debug.log('1500: l_return_status = ' || l_return_status, 2);
END IF;

  IF nvl(l_return_status,'*') <> 'S'
  THEN
        IF l_msg_count > 0
        THEN
         FOR i in 1..l_msg_count
         LOOP
          fnd_msg_pub.get (p_msg_index     => -1,
                           p_encoded       => 'T', -- OKC$APPLICATION.GET_FALSE,
                           p_data          => l_msg_data,
                           p_msg_index_out => l_msg_index_out);
         END LOOP;
        END IF;
        RAISE e_Error;
  END IF;
  END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('1400: calling okc_cle_pvt.force_delete_row', 2);
END IF;

  IF NOT l_clev_tbl_in.COUNT=0
  THEN
    okc_cle_pvt.force_delete_row (
          p_api_version                 => l_api_version,
               p_init_msg_list          => l_init_msg_list,
          x_return_status               => l_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => l_msg_data,
            p_clev_tbl                  => l_clev_tbl_in);

IF (l_debug = 'Y') THEN
   okc_debug.log('1500: l_return_status = ' || l_return_status, 2);
END IF;

             -- if the above process is success, delete all ancestrys
             If (l_return_status = OKC_API.G_RET_STS_SUCCESS) Then

IF (l_debug = 'Y') THEN
   okc_debug.log('1600: calling delete_ancestry', 2);
END IF;
             FOR v_Index IN l_clev_tbl_in.FIRST .. l_clev_tbl_in.LAST
             LOOP
                     delete_ancestry(
                           p_api_version        => p_api_version,
                           p_init_msg_list      => p_init_msg_list,
                           x_return_status      => l_return_status,
                           x_msg_count          => l_msg_count,
                           x_msg_data           => l_msg_data,
                           p_cle_id             => l_clev_tbl_in(v_Index).id);

IF (l_debug = 'Y') THEN
   okc_debug.log('1700: l_return_status = ' || l_return_status, 2);
END IF;

                   If (l_return_status <> OKC_API.G_RET_STS_SUCCESS) Then
                       x_return_status := l_return_status;
                                exit;
                End If;
                   END LOOP;

             End If;

  IF nvl(l_return_status,'*') <> 'S'
  THEN
        IF l_msg_count > 0
        THEN
         FOR i in 1..l_msg_count
         LOOP
          fnd_msg_pub.get (p_msg_index     => -1,
                           p_encoded       => 'T', -- OKC$APPLICATION.GET_FALSE,
                           p_data          => l_msg_data,
                           p_msg_index_out => l_msg_index_out);
         END LOOP;
        END IF;
        RAISE e_Error;
  END IF;
  END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('1800: x_return_status = ' || x_return_status, 2);
END IF;

  EXCEPTION
      WHEN e_Error THEN
         IF (l_debug = 'Y') THEN
         okc_debug.log('1900: WHEN e_Error EXCEPTION', 2);
         END IF;
      -- notify caller of an error as UNEXPETED error
      x_msg_count :=l_msg_count;
  x_msg_data:=l_msg_data;
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          'Delete_Contract_Line',
          'OKC_API.G_RET_STS_ERROR',
          l_msg_count,
          l_msg_data,
          '_PVT'
        );
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
         IF (l_debug = 'Y') THEN
         okc_debug.log('1900: WHEN OKC_API.G_EXCEPTION_ERROR EXCEPTION', 2);
         END IF;
  x_msg_count :=l_msg_count;
  x_msg_data:=l_msg_data;
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          'Delete_Contract_Line',
          'OKC_API.G_RET_STS_ERROR',
          l_msg_count,
          l_msg_data,
          '_PVT'
        );
      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
         IF (l_debug = 'Y') THEN
         okc_debug.log('2000: WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR EXCEPTION', 2);
         END IF;
  x_msg_count :=l_msg_count;
  x_msg_data:=l_msg_data;
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          'Force_Delete_K_Line',
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          l_msg_count,
          l_msg_data,
          '_PVT'
        );
      WHEN OTHERS THEN
         IF (l_debug = 'Y') THEN
         okc_debug.log('2100: WHEN OTHERS EXCEPTION', 2);
         END IF;
  x_msg_count :=l_msg_count;
      OKC_API.SET_MESSAGE(
        p_app_name        => g_app_name,
        p_msg_name        => g_unexpected_error,
        p_token1                => g_sqlcode_token,
        p_token1_value    => sqlcode,
        p_token2          => g_sqlerrm_token,
        p_token2_value    => sqlerrm);
      -- notify caller of an error as UNEXPETED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END force_delete_contract_line;

  PROCEDURE lock_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN OKC_CLE_PVT.clev_rec_type) IS

  BEGIN
    OKC_CLE_PVT.Lock_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_clev_rec                => p_clev_rec);
  END lock_contract_line;

  PROCEDURE lock_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN OKC_CLE_PVT.clev_tbl_type) IS

  BEGIN
    OKC_CLE_PVT.Lock_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_clev_tbl                => p_clev_tbl);
  END lock_contract_line;

  PROCEDURE validate_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN OKC_CLE_PVT.clev_rec_type) IS

  BEGIN
    OKC_CLE_PVT.Validate_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_clev_rec                => p_clev_rec);
  END validate_contract_line;

  PROCEDURE validate_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN OKC_CLE_PVT.clev_tbl_type) IS

  BEGIN
    OKC_CLE_PVT.Validate_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_clev_tbl                => p_clev_tbl);
  END validate_contract_line;

  PROCEDURE create_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN OKC_GVE_PVT.gvev_rec_type,
    x_gvev_rec                     OUT NOCOPY OKC_GVE_PVT.gvev_rec_type) IS

  BEGIN
    OKC_GVE_PVT.Insert_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_gvev_rec                => p_gvev_rec,
      x_gvev_rec                => x_gvev_rec);

    -- Update minor version
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
          x_return_status := Update_Minor_Version(x_gvev_rec.dnz_chr_id);
    End If;
  END create_governance;

  PROCEDURE create_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN OKC_GVE_PVT.gvev_tbl_type,
    x_gvev_tbl                     OUT NOCOPY OKC_GVE_PVT.gvev_tbl_type) IS

  BEGIN
    OKC_GVE_PVT.Insert_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_gvev_tbl                => p_gvev_tbl,
      x_gvev_tbl                => x_gvev_tbl);
  END create_governance;

  PROCEDURE update_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN OKC_GVE_PVT.gvev_rec_type,
    x_gvev_rec                     OUT NOCOPY OKC_GVE_PVT.gvev_rec_type) IS

  BEGIN
    OKC_GVE_PVT.Update_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_gvev_rec                => p_gvev_rec,
      x_gvev_rec                => x_gvev_rec);

    -- Update minor version
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
          x_return_status := Update_Minor_Version(x_gvev_rec.dnz_chr_id);
    End If;
  END update_governance;

  PROCEDURE update_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN OKC_GVE_PVT.gvev_tbl_type,
    x_gvev_tbl                     OUT NOCOPY OKC_GVE_PVT.gvev_tbl_type) IS

  BEGIN
    OKC_GVE_PVT.Update_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_gvev_tbl                => p_gvev_tbl,
      x_gvev_tbl                => x_gvev_tbl);
  END update_governance;

  PROCEDURE delete_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN OKC_GVE_PVT.gvev_rec_type) IS

    l_chr_id NUMBER;
    Cursor l_gvev_csr Is
                SELECT dnz_chr_id
                FROM OKC_GOVERNANCES
                WHERE id = p_gvev_rec.id;
  BEGIN
          Open l_gvev_csr;
          Fetch l_gvev_csr into l_chr_id;
          Close l_gvev_csr;

    OKC_GVE_PVT.Delete_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_gvev_rec                => p_gvev_rec);

    -- Update minor version
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
          x_return_status := Update_Minor_Version(l_chr_id);
    End If;
  END delete_governance;

  PROCEDURE delete_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN OKC_GVE_PVT.gvev_tbl_type) IS

  BEGIN
    OKC_GVE_PVT.Delete_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_gvev_tbl                => p_gvev_tbl);
  END delete_governance;

  PROCEDURE lock_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN OKC_GVE_PVT.gvev_rec_type) IS

  BEGIN
    OKC_GVE_PVT.Lock_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_gvev_rec                => p_gvev_rec);
  END lock_governance;

  PROCEDURE lock_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN OKC_GVE_PVT.gvev_tbl_type) IS

  BEGIN
    OKC_GVE_PVT.Lock_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_gvev_tbl                => p_gvev_tbl);
  END lock_governance;

  PROCEDURE validate_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN OKC_GVE_PVT.gvev_rec_type) IS

  BEGIN
    OKC_GVE_PVT.Validate_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_gvev_rec                => p_gvev_rec);
  END validate_governance;

  PROCEDURE validate_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN OKC_GVE_PVT.gvev_tbl_type) IS

  BEGIN
    OKC_GVE_PVT.Validate_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_gvev_tbl                => p_gvev_tbl);
  END validate_governance;

  PROCEDURE create_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_rec                     IN OKC_CPS_PVT.cpsv_rec_type,
    x_cpsv_rec                     OUT NOCOPY OKC_CPS_PVT.cpsv_rec_type) IS

  BEGIN
    OKC_CPS_PVT.Insert_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_cpsv_rec                => p_cpsv_rec,
      x_cpsv_rec                => x_cpsv_rec);

    -- Update minor version
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
          If (p_cpsv_rec.chr_id is not null and
                 p_cpsv_rec.chr_id <> OKC_API.G_MISS_NUM) Then
             x_return_status := Update_Minor_Version(p_cpsv_rec.chr_id);
          End If;
    End If;
  END create_contract_process;

  PROCEDURE create_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_tbl                     IN OKC_CPS_PVT.cpsv_tbl_type,
    x_cpsv_tbl                     OUT NOCOPY OKC_CPS_PVT.cpsv_tbl_type) IS

  BEGIN
    OKC_CPS_PVT.Insert_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_cpsv_tbl                => p_cpsv_tbl,
      x_cpsv_tbl                => x_cpsv_tbl);
  END create_contract_process;

  PROCEDURE update_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_rec                     IN OKC_CPS_PVT.cpsv_rec_type,
    x_cpsv_rec                     OUT NOCOPY OKC_CPS_PVT.cpsv_rec_type) IS

    l_process_active_yn VARCHAR2(1) := 'N';
  BEGIN
    -- check whether the process is active or not
        l_process_active_yn := Is_Process_Active(p_cpsv_rec.chr_id);
        If (l_process_active_yn = 'Y') Then
           raise G_NO_UPDATE_ALLOWED_EXCEPTION;
        End If;

    OKC_CPS_PVT.Update_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_cpsv_rec                => p_cpsv_rec,
      x_cpsv_rec                => x_cpsv_rec);

    -- Update minor version
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
          If (p_cpsv_rec.chr_id is not null and
                 p_cpsv_rec.chr_id <> OKC_API.G_MISS_NUM) Then
             x_return_status := Update_Minor_Version(p_cpsv_rec.chr_id);
          End If;
    End If;
  exception
    when G_NO_UPDATE_ALLOWED_EXCEPTION then
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_no_update_allowed,
                                          p_token1              => 'VALUE1',
                                          p_token1_value        => 'Contract Processes');

          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
    when OTHERS then
          -- store SQL error message on message stack
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_unexpected_error,
                                          p_token1              => g_sqlcode_token,
                                          p_token1_value        => sqlcode,
                                          p_token2              => g_sqlerrm_token,
                                          p_token2_value        => sqlerrm);

           -- notify caller of an UNEXPETED error
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END update_contract_process;

  PROCEDURE update_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_tbl                     IN OKC_CPS_PVT.cpsv_tbl_type,
    x_cpsv_tbl                     OUT NOCOPY OKC_CPS_PVT.cpsv_tbl_type) IS

  BEGIN
    OKC_CPS_PVT.Update_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_cpsv_tbl                => p_cpsv_tbl,
      x_cpsv_tbl                => x_cpsv_tbl);
  END update_contract_process;

  PROCEDURE delete_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_rec                     IN OKC_CPS_PVT.cpsv_rec_type) IS

    l_process_active_yn VARCHAR2(1) := 'N';
    l_chr_id    NUMBER;
    l_not_found BOOLEAN;
    Cursor l_cpsv_csr(p_id IN NUMBER) Is
                SELECT CHR_ID
                FROM OKC_K_PROCESSES
                WHERE ID = p_id;
  BEGIN
    -- check whether the process is active or not
        l_process_active_yn := Is_Process_Active(p_cpsv_rec.chr_id);
        If (l_process_active_yn = 'Y') Then
           raise G_NO_UPDATE_ALLOWED_EXCEPTION;
        End If;

        open l_cpsv_csr(p_cpsv_rec.id);
        fetch l_cpsv_csr into l_chr_id;
        l_not_found := l_cpsv_csr%NOTFOUND;
        close l_cpsv_csr;
        If (l_not_found) Then
                x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
                -- store SQL error message on message stack
                OKC_API.SET_MESSAGE(
                        p_app_name      => g_app_name,
                        p_msg_name      => g_unexpected_error,
                        p_token1                => g_sqlcode_token,
                        p_token1_value  => sqlcode,
                        p_token2                => g_sqlerrm_token,
                        p_token2_value  => sqlerrm);
        End If;

    OKC_CPS_PVT.Delete_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_cpsv_rec                => p_cpsv_rec);

    -- Update minor version
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS and
           l_chr_id is not null)
    Then
        x_return_status := Update_Minor_Version(l_chr_id);
    End If;
  exception
    when G_NO_UPDATE_ALLOWED_EXCEPTION then
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_no_update_allowed,
                                          p_token1              => 'VALUE1',
                                          p_token1_value        => 'Contract Processes');

          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
    when OTHERS then
          -- store SQL error message on message stack
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_unexpected_error,
                                          p_token1              => g_sqlcode_token,
                                          p_token1_value        => sqlcode,
                                          p_token2              => g_sqlerrm_token,
                                          p_token2_value        => sqlerrm);

           -- notify caller of an UNEXPETED error
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END delete_contract_process;

  PROCEDURE delete_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_tbl                     IN OKC_CPS_PVT.cpsv_tbl_type) IS

  BEGIN
    OKC_CPS_PVT.Delete_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_cpsv_tbl                => p_cpsv_tbl);
  END delete_contract_process;

  PROCEDURE lock_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_rec                     IN OKC_CPS_PVT.cpsv_rec_type) IS

  BEGIN
    OKC_CPS_PVT.Lock_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_cpsv_rec                => p_cpsv_rec);
  END lock_contract_process;

  PROCEDURE lock_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_tbl                     IN OKC_CPS_PVT.cpsv_tbl_type) IS

  BEGIN
    OKC_CPS_PVT.Lock_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_cpsv_tbl                => p_cpsv_tbl);
  END lock_contract_process;

  PROCEDURE validate_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_rec                     IN OKC_CPS_PVT.cpsv_rec_type) IS

  BEGIN
    OKC_CPS_PVT.Validate_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_cpsv_rec                => p_cpsv_rec);
  END validate_contract_process;

  PROCEDURE validate_contract_process(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_tbl                     IN OKC_CPS_PVT.cpsv_tbl_type) IS

  BEGIN
    OKC_CPS_PVT.Validate_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_cpsv_tbl                => p_cpsv_tbl);
  END validate_contract_process;

  PROCEDURE create_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_rec                     IN OKC_CAC_PVT.cacv_rec_type,
    x_cacv_rec                     OUT NOCOPY OKC_CAC_PVT.cacv_rec_type) IS

  BEGIN
    OKC_CAC_PVT.Insert_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_cacv_rec                => p_cacv_rec,
      x_cacv_rec                => x_cacv_rec);

    -- Update minor version
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
          x_return_status := Update_Minor_Version(x_cacv_rec.chr_id);
    End If;
  END create_contract_access;

  PROCEDURE create_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_tbl                     IN OKC_CAC_PVT.cacv_tbl_type,
    x_cacv_tbl                     OUT NOCOPY OKC_CAC_PVT.cacv_tbl_type) IS

  BEGIN
    OKC_CAC_PVT.Insert_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_cacv_tbl                => p_cacv_tbl,
      x_cacv_tbl                => x_cacv_tbl);
  END create_contract_access;

  PROCEDURE update_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_rec                     IN OKC_CAC_PVT.cacv_rec_type,
    x_cacv_rec                     OUT NOCOPY OKC_CAC_PVT.cacv_rec_type) IS

  BEGIN
    OKC_CAC_PVT.Update_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_cacv_rec                => p_cacv_rec,
      x_cacv_rec                => x_cacv_rec);

    -- Update minor version
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
          x_return_status := Update_Minor_Version(x_cacv_rec.chr_id);
    End If;
  END update_contract_access;

  PROCEDURE update_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_tbl                     IN OKC_CAC_PVT.cacv_tbl_type,
    x_cacv_tbl                     OUT NOCOPY OKC_CAC_PVT.cacv_tbl_type) IS

  BEGIN
    OKC_CAC_PVT.Update_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_cacv_tbl                => p_cacv_tbl,
      x_cacv_tbl                => x_cacv_tbl);
  END update_contract_access;

  PROCEDURE delete_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_rec                     IN OKC_CAC_PVT.cacv_rec_type) IS

    l_chr_id NUMBER;
    l_not_found BOOLEAN;
    Cursor l_cacv_csr Is
                SELECT chr_id
                FROM OKC_K_ACCESSES
                WHERE id = p_cacv_rec.id;
  BEGIN
          Open l_cacv_csr;
          Fetch l_cacv_csr into l_chr_id;
          l_not_found := l_cacv_csr%NOTFOUND;
          Close l_cacv_csr;

        If (l_not_found) Then
                x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
                -- store SQL error message on message stack
                OKC_API.SET_MESSAGE(
                        p_app_name      => g_app_name,
                        p_msg_name      => g_unexpected_error,
                        p_token1                => g_sqlcode_token,
                        p_token1_value  => sqlcode,
                        p_token2                => g_sqlerrm_token,
                        p_token2_value  => sqlerrm);
                return;
        End If;

    OKC_CAC_PVT.Delete_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_cacv_rec                => p_cacv_rec);

    -- Update minor version
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
          x_return_status := Update_Minor_Version(l_chr_id);
    End If;
  END delete_contract_access;

  PROCEDURE delete_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_tbl                     IN OKC_CAC_PVT.cacv_tbl_type) IS

  BEGIN
    OKC_CAC_PVT.Delete_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_cacv_tbl                => p_cacv_tbl);
  END delete_contract_access;

  PROCEDURE lock_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_rec                     IN OKC_CAC_PVT.cacv_rec_type) IS

  BEGIN
    OKC_CAC_PVT.Lock_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_cacv_rec                => p_cacv_rec);
  END lock_contract_access;

  PROCEDURE lock_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_tbl                     IN OKC_CAC_PVT.cacv_tbl_type) IS

  BEGIN
    OKC_CAC_PVT.Lock_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_cacv_tbl                => p_cacv_tbl);
  END lock_contract_access;

  PROCEDURE validate_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_rec                     IN OKC_CAC_PVT.cacv_rec_type) IS

  BEGIN
    OKC_CAC_PVT.Validate_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_cacv_rec                => p_cacv_rec);
  END validate_contract_access;

  PROCEDURE validate_contract_access(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_tbl                     IN OKC_CAC_PVT.cacv_tbl_type) IS

  BEGIN
    OKC_CAC_PVT.Validate_Row(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_cacv_tbl                => p_cacv_tbl);
  END validate_contract_access;

  PROCEDURE add_language IS
  BEGIN
        OKC_CHR_PVT.add_language;
        OKC_CLE_PVT.add_language;
  END add_language;

  PROCEDURE Get_Active_Process (
                p_api_version                           IN NUMBER,
                p_init_msg_list                 IN VARCHAR2,
                x_return_status          OUT NOCOPY VARCHAR2,
                x_msg_count                      OUT NOCOPY NUMBER,
                x_msg_data                       OUT NOCOPY VARCHAR2,
                p_contract_number                       IN VARCHAR2,
                p_contract_number_modifier      IN VARCHAR2,
                x_wf_name                                OUT NOCOPY VARCHAR2,
                x_wf_process_name                OUT NOCOPY VARCHAR2,
                x_package_name                   OUT NOCOPY VARCHAR2,
                x_procedure_name                 OUT NOCOPY VARCHAR2,
                x_usage                          OUT NOCOPY VARCHAR2) Is

        l_chr_id        NUMBER;
        l_process_active_yn     VARCHAR2(1);
        Cursor l_chrv_csr Is
                SELECT id
                FROM OKC_K_HEADERS_B
                WHERE contract_number = p_contract_number
                AND contract_number_modifier = p_contract_number_modifier;

        Cursor l_chrv_csr2 Is
                SELECT id
                FROM OKC_K_HEADERS_B
                WHERE contract_number = p_contract_number
                AND contract_number_modifier is null;

        Cursor l_pdfv_csr Is
                SELECT
                        usage,
                        name,
                        wf_process_name,
                        procedure_name,
                        package_name
                FROM okc_process_defs_v pdfv,
                        okc_k_processes cpsv
                WHERE pdfv.id = cpsv.pdf_id
                  AND cpsv.chr_id = l_chr_id
                  AND cpsv.last_update_date = (SELECT MAX(last_update_date)
                                                                 FROM okc_k_processes
                                                                 WHERE chr_id = l_chr_id);
  BEGIN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        -- get id from header table
        If (p_contract_number_modifier is not null) Then
           Open l_chrv_csr;
           Fetch l_chrv_csr into l_chr_id;
           If l_chrv_csr%NOTFOUND Then
              raise NO_CONTRACT_FOUND;
           End If;
           close l_chrv_csr;
        Else
           Open l_chrv_csr2;
           Fetch l_chrv_csr2 into l_chr_id;
           If l_chrv_csr2%NOTFOUND Then
              raise NO_CONTRACT_FOUND;
           End If;
           close l_chrv_csr2;
     End If;

        l_process_active_yn := Is_Process_Active(l_chr_id);
        If (l_process_active_yn = 'Y') Then
           Open l_pdfv_csr;
           Fetch l_pdfv_csr Into x_usage,
                                          x_wf_name,
                                          x_wf_process_name,
                                          x_package_name,
                                          x_procedure_name;
           If l_pdfv_csr%NOTFOUND Then
              x_return_status := OKC_API.G_RET_STS_ERROR;
           End If;
           Close l_pdfv_csr;
        Else
           x_usage := NULL;
           x_wf_name := NULL;
           x_wf_process_name := NULL;
           x_package_name := NULL;
           x_procedure_name := NULL;
        End If;
  exception
    when NO_CONTRACT_FOUND Then
          If (l_chrv_csr%ISOPEN) Then
                close l_chrv_csr;
          Elsif (l_chrv_csr2%ISOPEN) Then
                close l_chrv_csr2;
          End If;

          -- pass NULLs to calling program
          x_usage := NULL;
          x_wf_name := NULL;
          x_wf_process_name := NULL;
          x_package_name := NULL;
          x_procedure_name := NULL;

--        OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
--                                        p_msg_name            => 'NO_CONTRACT_FOUND');
--         x_return_status := OKC_API.G_RET_STS_ERROR;
    when OTHERS then
          -- store SQL error message on message stack
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_unexpected_error,
                                          p_token1              => g_sqlcode_token,
                                          p_token1_value        => sqlcode,
                                          p_token2              => g_sqlerrm_token,
                                          p_token2_value        => sqlerrm);

           -- notify caller of an UNEXPETED error
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Get_Active_Process;

  --
  -- function that checkes whether a contract is updateable or not
  -- returns 'Y' if updateable, 'N' if not.
  -- returns OKC_API.G_RET_STS_ERROR or OKC_API.G_RET_STS_UNEXP_ERROR
  -- in case of error
  --
  FUNCTION Update_Allowed(p_chr_id IN NUMBER) RETURN VARCHAR2 Is
        l_sts_code      OKC_ASSENTS.STS_CODE%TYPE;
        l_scs_code      OKC_ASSENTS.SCS_CODE%TYPE;
        l_return_value  VARCHAR2(1) := 'Y';

        Cursor l_chrv_csr Is
                SELECT sts_code, scs_code
                --npalepu 26-10-2005 modified for bug # 4691662.
                --Replaced table okc_k_headers_b with headers_All_b table
                /*  FROM OKC_K_HEADERS_B  */
                FROM OKC_K_HEADERS_ALL_B
                --end npalepu
                WHERE id = p_chr_id;

        Cursor l_astv_csr Is
                SELECT upper(substr(allowed_yn,1,1))
                FROM okc_assents
                WHERE sts_code = l_sts_code
                AND scs_code = l_scs_code
                AND opn_code = 'UPDATE';
  BEGIN
        -- get status from contract headers
        Open l_chrv_csr;
        Fetch l_chrv_csr Into l_sts_code, l_scs_code;
        If l_chrv_csr%FOUND Then
           Close l_chrv_csr;
           Open l_astv_csr;
           Fetch l_astv_csr into l_return_value;
           If (l_return_value not in ('Y','N')) Then
                 l_return_value := OKC_API.G_RET_STS_UNEXP_ERROR;
           End If;
           Close l_astv_csr;
        Else
           Close l_chrv_csr;
        End If;
        return l_return_value;
  Exception
    when OTHERS then
          -- store SQL error message on message stack
          OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_unexpected_error,
                                          p_token1              => g_sqlcode_token,
                                          p_token1_value        => sqlcode,
                                          p_token2              => g_sqlerrm_token,
                                          p_token2_value        => sqlerrm);

           -- notify caller of an UNEXPETED error
           l_return_value := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Update_Allowed;

--------------------------------------------------------------------
-- Procedure to clear/relink renewal links
-- Added for renew, status related changes
-- Parameter: p_target_chr_id = target contract id
--            clean_relink_flag = 'CLEAN' (default) for cleaning
--                              = 'RELINK' for relinking
--
-- RELINK_RENEW procedure call this procedure with 'RELINK'
--------------------------------------------------------------------
  PROCEDURE CLEAN_REN_LINKS(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 ,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_target_chr_id     IN NUMBER,
    clean_relink_flag   VARCHAR2)

   IS
    l_api_name          VARCHAR2(30) := 'LINE_RENEWAL_LINKS';
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_active_yn         VARCHAR2(1) := 'N';
    l_no_of_lines      NUMBER;
    l_no_of_op_lines   NUMBER;

    --
    -- Cursor to get source contract ids
    -- to update minor version, if p_is_parent <> 'Y'
    --

--Fix for bug 4948793
    Cursor ole_csr Is

		  SELECT distinct ol.object_chr_id
          FROM okc_operation_instances op
               , okc_class_operations cls
               , okc_subclasses_b sl
               , okc_operation_lines ol
          WHERE ol.subject_chr_id = p_target_chr_id
          And   op.id = ol.oie_id
          AND   op.cop_id = cls.id
          And   cls.cls_code = sl.cls_code
          And   sl.code = 'SERVICE'
          And   cls.opn_code in ('RENEWAL','REN_CON');

         /*SELECT distinct object_chr_id
                 FROM okc_operation_lines
                 WHERE subject_chr_id = p_target_chr_id;
                 --AND active_yn = 'Y';
      */


    Cursor ole_csr2(p_subject_chr_id NUMBER, p_object_chr_id NUMBER) Is
                SELECT count(*)
                FROM okc_operation_lines
                WHERE SUBJECT_CHR_ID = p_subject_chr_id
                AND OBJECT_CHR_ID = p_object_chr_id
                AND SUBJECT_CLE_ID is not null;

    Cursor cle_csr(p_subject_chr_id NUMBER, p_object_chr_id NUMBER) Is
                SELECT count(*)
                FROM okc_k_lines_b
                WHERE id IN (SELECT OBJECT_CLE_ID
                                   FROM okc_operation_lines
                                   WHERE SUBJECT_CHR_ID = p_subject_chr_id
                             AND OBJECT_CHR_ID = p_object_chr_id)
                AND dnz_chr_id = p_object_chr_id;

  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_return_status := OKC_API.START_ACTIVITY
                        (l_api_name, p_init_msg_list, '_PVT', x_return_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- set flag to update
    IF (NVL(clean_relink_flag,'CLEAN') = 'RELINK') Then
          l_active_yn := 'Y';
    END IF;

    --
    -- Clean date_renewed in header (for CLEAN)
    --
    If (l_active_yn = 'N') Then
            -- Clear all source contract's date_renewed column
            UPDATE OKC_K_HEADERS_B
            SET date_renewed = null,
                   object_version_number = object_version_number + 1,
                   last_updated_by = FND_GLOBAL.USER_ID,
                   last_update_date = sysdate,
                   last_update_login = FND_GLOBAL.LOGIN_ID
            WHERE id in (
                        SELECT distinct object_chr_id
                        FROM okc_operation_lines
                        WHERE subject_chr_id = p_target_chr_id
                        AND active_yn = 'Y');
    --
    -- Set date renewed on all source contracts if all lines are renewed
    --
    Else
           FOR ole_rec IN ole_csr
           LOOP
            open ole_csr2(p_target_chr_id,ole_rec.object_chr_id);
                  fetch ole_csr2 into l_no_of_op_lines;
                  close ole_csr2;

                  open cle_csr(p_target_chr_id,ole_rec.object_chr_id);
                  fetch cle_csr into l_no_of_lines;
                  close cle_csr;

                  If ( l_no_of_op_lines = l_no_of_lines ) Then
                            UPDATE OKC_K_HEADERS_B
                            SET date_renewed = sysdate,
                                   object_version_number = object_version_number + 1,
                                   last_updated_by = FND_GLOBAL.USER_ID,
                                   last_update_date = sysdate,
                                   last_update_login = FND_GLOBAL.LOGIN_ID
                      WHERE id = ole_rec.object_chr_id;

                  End If;
           END LOOP;
    End If;

    --
    -- To clear renewal link of the target contract,
    -- set operation lines.active_yn = Y or N
    -- for the contract entry in operation lines table
    -- subject_chr_id is the child/renewed_to chr id
    --
    UPDATE okc_operation_lines ol
    SET active_yn = l_active_yn,
           object_version_number = object_version_number + 1,
           last_updated_by = FND_GLOBAL.USER_ID,
           last_update_date = sysdate,
           last_update_login = FND_GLOBAL.LOGIN_ID
    WHERE subject_chr_id = p_target_chr_id
    AND   subject_cle_id is null
    AND   object_cle_id is null
    And exists(Select 'x'	                   --Fix Bug 4948793
            FROM okc_operation_instances op
               , okc_class_operations cls
               , okc_subclasses_b sl
          WHERE op.id = ol.oie_id
          AND   op.cop_id = cls.id
          And   cls.cls_code = sl.cls_code
          And   sl.code = 'SERVICE'
          And   cls.opn_code in ('RENEWAL','REN_CON') );
    --
    -- clear date_renewed in source contact(s) lines
    -- only for those lines in target contract
    --
    UPDATE OKC_K_LINES_B
    SET date_renewed = decode(l_active_yn,'Y',sysdate,null),
           object_version_number = object_version_number + 1,
           last_updated_by = FND_GLOBAL.USER_ID,
           last_update_date = sysdate,
           last_update_login = FND_GLOBAL.LOGIN_ID
    WHERE id in (Select ol.object_cle_id		 --Fix Bug 4948793
            FROM okc_operation_instances op
               , okc_class_operations cls
               , okc_subclasses_b sl
               , okc_operation_lines ol
          WHERE ol.subject_chr_id = p_target_chr_id
          And   ol.object_cle_id is not null
          And   op.id = ol.oie_id
          AND   op.cop_id = cls.id
          And   cls.cls_code = sl.cls_code
          And   sl.code = 'SERVICE'
          And   cls.opn_code in ('RENEWAL','REN_CON') );

    --
    -- To set renewal link of contract lines,
    -- set operation lines.active_yn = Y or N
    -- for the contract line entries in operation lines table
    --
    UPDATE okc_operation_lines ol
    SET active_yn = l_active_yn,
           object_version_number = object_version_number + 1,
           last_updated_by = FND_GLOBAL.USER_ID,
           last_update_date = sysdate,
           last_update_login = FND_GLOBAL.LOGIN_ID
    WHERE subject_chr_id = p_target_chr_id
    AND subject_cle_id is not null
    AND object_cle_id is not null
    And exists(Select 'x'			 --Fix Bug 4948793
            FROM okc_operation_instances op
               , okc_class_operations cls
               , okc_subclasses_b sl
          WHERE op.id = ol.oie_id
          AND   op.cop_id = cls.id
          And   cls.cls_code = sl.cls_code
          And   sl.code = 'SERVICE'
          And   cls.opn_code in ('RENEWAL','REN_CON') );

    --
    --Set minor version for updated contracts
    --
            FOR ole_rec IN ole_csr
            LOOP
                   x_return_status := update_minor_version(ole_rec.object_chr_id);

                   IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                   ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                          raise OKC_API.G_EXCEPTION_ERROR;
                   END IF;
            END LOOP;

         --- Added for Bug# 2606251 --- to increment version for a renewed contract(when staus is changed)
         OKC_CVM_PVT.g_trans_id :=  'XX-XX';
         --- Added for Bug# 2606251 ---

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END CLEAN_REN_LINKS;

  PROCEDURE RELINK_RENEW(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_target_chr_id                IN number)
   IS
  BEGIN
      CLEAN_REN_LINKS(
           p_api_version       => p_api_version,
           p_init_msg_list     => p_init_msg_list,
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           p_target_chr_id     => p_target_chr_id,
           clean_relink_flag   => 'RELINK');

  END RELINK_RENEW;


--For Bug.No.1789860, Function Get_concat_line_no is added.
--The following procedure is added to display concatenated line nos.
--For Bug.No.3339185, Function Get_concat_line_no is modified.
------------------------------------------------------------------------
 FUNCTION Get_concat_line_no(
           p_cle_id IN NUMBER,
           x_return_status OUT NOCOPY Varchar2) RETURN VARCHAR2 IS

   l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

   CURSOR l_line_csr IS
     SELECT display_sequence from
     OKC_K_LINES_B
     connect by prior cle_id = id
     start with id = p_cle_id;

   CURSOR l_k_code_csr IS
     SELECT cls_code from
     OKC_SUBCLASSES_B WHERE code=(SELECT scs_code from OKC_K_HEADERS_B where id in
     (select dnz_chr_id from okc_k_lines_b where id =p_cle_id));

   CURSOR l_chk_cle_csr IS
           SELECT clev.cle_id,RTRIM(clev.line_number) line_number,clev.lse_id
           FROM OKC_K_LINES_V clev
           WHERE clev.id = p_cle_id;

   CURSOR l_get_top_line_number_csr (p_line_id NUMBER) IS
           SELECT line_number
           FROM   OKC_K_LINES_B
           WHERE id = p_line_id;

   CURSOR l_line_name_csr IS
           SELECT line_number "LINE_NAME"
           FROM   OKC_LINE_STYLES_V lsev,
                  OKC_K_LINES_V clev
           WHERE  lsev.id = clev.lse_id
           AND    clev.id = p_cle_id;

   l_line_number   Varchar2(2000);
   l_return        Varchar2(2000);
   l_code        Varchar2(2000);
   j               Number :=0;
   l_line_name_rec l_line_name_csr%ROWTYPE;
   l_chk_cle_rec   l_chk_cle_csr%ROWTYPE;
   l_line_name     VARCHAR2(1000);
   l_get_top_line_number_rec l_get_top_line_number_csr%ROWTYPE;

  BEGIN
   open  l_k_code_csr;
        FETCH l_k_code_csr INTO l_code;
   close l_k_code_csr;
   IF(l_code='SERVICE') THEN    --service contracts
    OPEN l_chk_cle_csr;
    FETCH l_chk_cle_csr INTO l_chk_cle_rec;
        IF  l_chk_cle_rec.cle_id IS NULL
        THEN
            OPEN l_line_name_csr;
            FETCH l_line_name_csr INTO l_line_name_rec;
            CLOSE l_line_name_csr;

            l_line_name := l_line_name_rec.line_name;

        ELSE
            OPEN l_get_top_line_number_csr (l_chk_cle_rec.cle_id);
            FETCH l_get_top_line_number_csr INTO l_get_top_line_number_rec;
            CLOSE l_get_top_line_number_csr;

            OPEN l_line_name_csr;
            FETCH l_line_name_csr INTO l_line_name_rec;
            CLOSE l_line_name_csr;

            if ((l_chk_cle_rec.lse_id >=2 and l_chk_cle_rec.lse_id <=6) or (l_chk_cle_rec.lse_id=15)or (l_chk_cle_rec.lse_id=16)
               or (l_chk_cle_rec.lse_id=17)or (l_chk_cle_rec.lse_id>=21 and l_chk_cle_rec.lse_id <=24)) then
              l_line_name := l_get_top_line_number_rec.line_number; --coverage lines
            else --sub lines
              l_line_name := l_get_top_line_number_rec.line_number||'.'||l_line_name_rec.line_name;
            end if;

        END IF; --IF  l_chk_cle_rec.cle_id IS NULL

    CLOSE l_chk_cle_csr;

    IF l_line_name_rec.line_name IS NULL THEN
      RETURN('No Line Name Found');
    ELSE
      RETURN(l_line_name);
    END IF;
  ELSE               --  other than service contracts
   open l_line_csr;
   Loop
     Fetch l_line_csr INTO l_line_number;
       Exit When l_line_csr%NOTFOUND;
        If j = 0 then
          l_return := l_line_number;
          j := j + 1;
        Else
          l_return := l_line_number || '.' || l_return ;
        End if;
   End Loop;
    close l_line_csr;
    return l_return;
   x_return_status := l_return_status;
  End if;
  EXCEPTION
      WHEN OTHERS then
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      OKC_API.SET_MESSAGE(p_app_name    => g_app_name,
                         p_msg_name     => g_unexpected_error,
                         p_token1       => g_sqlcode_token,
                         p_token1_value => sqlcode,
                         p_token2       => g_sqlerrm_token,
                         p_token2_value => sqlerrm);
      -- verify that cursor was closed
      IF l_line_name_csr%ISOPEN THEN
         CLOSE l_line_name_csr;
      END IF;
     return Null;

  END Get_concat_line_no;


---

--[llc] Update Contract Amount

/*
   The Header and Line Amounts should be updated when Change Status action is taken
   at the header/line/subline level. This is to ensure that the calualated amounts
   (price_negotiated, cancelled_amount, estimated_amount) ignores cancelled lines/sublines.

   A new procedure Update_Contract_Amount is created which is called
   when cancel actions is taken at header/line/subline level.

*/


PROCEDURE UPDATE_CONTRACT_AMOUNT (
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_id                IN NUMBER,
    p_from_ste_code     IN VARCHAR2,
    p_to_ste_code       IN VARCHAR2,
    p_cle_id            IN NUMBER,
    x_return_status     OUT NOCOPY    VARCHAR2,
    x_msg_count         OUT NOCOPY    NUMBER,
    x_msg_data          OUT NOCOPY    VARCHAR2 )

IS

        l_cle_id                Number := NULL;
        l_sub_line_amt          Number := NULL;
        l_lse_id                Number := NULL;
        l_hdr_estimated_amt     Number := NULL;
        l_hdr_cancelled_amt     Number := NULL;
        l_uncancelled_amt       Number := NULL;           /*Added for bug:8775250*/



        l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_AMOUNT';
        l_can_line_amt         Number :=Null;

--Cursor to get topline id for a particular subline; For a topline this will return NULL

    Cursor get_line_lvl_csr is
        Select  cle_id
        from    okc_k_lines_b
        where   id = p_cle_id
        and     dnz_chr_id = p_id;

--Cursor to fetch amount for a particular subline

    Cursor get_subline_amt_csr (p_cle_id NUMBER) IS
        Select  cle.price_negotiated
        from    okc_k_lines_b cle
        where   cle.id = p_cle_id
            and cle.dnz_chr_id = p_id;

--Cursor to add price_negotiated and cancelled_amount of all the toplines

    Cursor get_hdr_amts_csr IS
        select  nvl(sum(nvl(price_negotiated,0)),0), nvl(sum(nvl(cancelled_amount,0)),0)
        from    okc_k_lines_b cle
        where   cle.dnz_chr_id = p_id
        and     cle.lse_id in (1, 12, 14, 19, 46)
        and     cle.cle_id is null;

--Cursor to fectch lse_id of topline

    Cursor get_lse_id_csr (p_cle_id NUMBER)  IS
        select  lse_id
        from    okc_k_lines_b
        where   id=p_cle_id;


--Cursor to add price_negotiated for all the sublines of a topline which are not in cancelled status

    Cursor get_uncancelled_amt_csr(p_cle_id number, p_id number) IS
         select nvl(sum(nvl(price_negotiated,0)),0)
         from okc_k_lines_b
         where cle_id = p_cle_id
         and dnz_chr_id = p_id
         and date_cancelled is null;


-- Bug Fix 5026369 maanand 08-FEB-2006

-- Cursor to fetch all the toplines of a contract whose term_cancel_source is null
-- i.e. term_cancel_source is not ('IBTRANSFER', 'IBRETURN', 'IBTERMINATE', 'IBREPLACE')

    CURSOR get_topline_id_csr IS
	SELECT  id,lse_id,cancelled_amount
	FROM	okc_k_lines_b
	WHERE	dnz_chr_id = p_id
	and	cle_id is null
	and     term_cancel_source is null;

 /*Added for bug:8775250*/
    Cursor get_subline_canamt_csr(p_cle_id NUMBER) IS
        select  cle.cancelled_amount
        from    okc_k_lines_b cle
        where   cle.id = p_cle_id
          and   cle.dnz_chr_id = p_id
          and   cle.lse_id in (7, 8, 9, 10, 11, 13, 18, 25, 35) ;

    Cursor get_subline_price_csr(p_cle_id NUMBER) IS
        select   okslb.id,okslb.price_negotiated
          from   okc_k_lines_b cle,
                 okc_k_lines_b okslb
         where   cle.id = p_cle_id
           and   okslb.lse_id in (7, 8, 9, 10, 11, 13, 18, 25, 35)
           and   okslb.cle_id =cle.id
           and   okslb.term_cancel_source IN ('MANUAL','CUSTOMER')   ----Modified condition for bug 12956286
           and   okslb.date_cancelled is not null;

    Cursor get_subline_cancel_csr(p_cle_id NUMBER) IS
        select   okslb.id,okslb.cancelled_amount
          from   okc_k_lines_b cle,
                 okc_k_lines_b okslb
         where   cle.id = p_cle_id
           and   okslb.lse_id in (7, 8, 9, 10, 11, 13, 18, 25, 35)
           and   okslb.cle_id =cle.id
           and   okslb.date_cancelled is null;

   Cursor get_lines_id(p_id number) IS
       select oklb.id,oklb.price_negotiated
         from okc_k_lines_b oklb,
              okc_k_headers_all_b okhb
        where oklb.chr_id = okhb.id
          and okhb.id = p_id
          and oklb.lse_id in (1,12,14,19,46);

--

    BEGIN



     IF (l_debug = 'Y') THEN
             okc_debug.log('2200: Entered UPDATE_CONTRACT_AMOUNT');
      END IF;

      IF ((p_from_ste_code is NULL) OR  (p_to_ste_code is NULL) OR  (p_id is null)) THEN
        raise FND_API.G_EXC_ERROR;
      END IF;

      IF (l_debug = 'Y') THEN
             okc_debug.log('2210: Parameter Values ' ||
                            'p_id - '|| p_id ||
                            'p_from_ste_code - '||p_from_ste_code ||
                            'p_to_ste_code - '||p_to_ste_code ||
                            'p_cle_id- '||p_cle_id );
      END IF;

    IF (p_cle_id is NOT NULL) THEN -- implies line or subline level

	IF (l_debug = 'Y') THEN
             okc_debug.log('2300: p_cle_id is not null; Change Status called from line/subline level');
        END IF;

        Open    get_line_lvl_csr;
        Fetch   get_line_lvl_csr into l_cle_id;
        Close   get_line_lvl_csr;

        IF (l_cle_id is NOT NULL) THEN  --p_cle_id is a subline

           IF (l_debug = 'Y') THEN
		okc_debug.log('2310: Updating topline of the subline due to status change of the subline');
           END IF;

            Open get_subline_amt_csr(p_cle_id);
            Fetch get_subline_amt_csr into l_sub_line_amt;
            Close get_subline_amt_csr;

            IF ((p_from_ste_code = 'ENTERED' ) AND (p_to_ste_code = 'CANCELLED')) THEN

                IF (l_debug = 'Y') THEN
	             okc_debug.log('2320: ENTERED -> CANCELLED; Updating price_negotiated and cancelled_amount for the topline of the subline');
                END IF;

                Update  okc_k_lines_b
                set     price_negotiated = nvl(price_negotiated,0) - nvl(l_sub_line_amt,0),
                        cancelled_amount = nvl(cancelled_amount,0) + nvl(l_sub_line_amt,0)
                Where   id = l_cle_id     -- top line id
                and     dnz_chr_id = p_id;

                  /*Bug:6765336    Updating the subline when it is cancelled*/
 	                Update  okc_k_lines_b
 	                 set     price_negotiated = nvl(price_negotiated,0) - nvl(l_sub_line_amt,0),
 	                         cancelled_amount = nvl(cancelled_amount,0) + nvl(l_sub_line_amt,0)
 	                 Where   cle_id = l_cle_id
 	                  and     id=  p_cle_id
 	                 and     dnz_chr_id = p_id;
 	           /*Bug:6765336  */
            ELSIF ((p_from_ste_code = 'CANCELLED' ) AND (p_to_ste_code = 'ENTERED')) THEN

                IF (l_debug = 'Y') THEN
	             okc_debug.log('2330: CANCELLED -> ENTERED; Updating price_negotiated and cancelled_amount for the topline of the subline');
                END IF;
               /*Added for bug:8775250*/
               Open get_subline_canamt_csr(p_cle_id);
               Fetch get_subline_canamt_csr into l_can_line_amt;
               Close get_subline_canamt_csr;

                 Update  okc_k_lines_b
 	            set  price_negotiated = nvl(price_negotiated,0) + nvl(l_can_line_amt,0),
 	                 cancelled_amount = nvl(cancelled_amount,0) - nvl(l_can_line_amt,0)
 	           Where cle_id = l_cle_id
 	             and id=  p_cle_id
 	             and dnz_chr_id = p_id;

                Update okc_k_lines_b
                set price_negotiated = nvl(price_negotiated,0) + nvl(l_can_line_amt,0),         /*Changed for bug:8775250*/
                cancelled_amount = nvl(cancelled_amount,0) - nvl(l_can_line_amt,0)
                Where id = l_cle_id     -- top line id
                And dnz_chr_id = p_id;


            END IF;     -- p_to_ste_code ='CANCELLED'

        ELSE --l_cle_id is NULL  --p_cle_id is a top line

            IF (l_debug = 'Y') THEN
		okc_debug.log('2400: Updating the topline');
            END IF;

            IF ((p_from_ste_code = 'ENTERED') AND (p_to_ste_code = 'CANCELLED')) THEN

                IF (l_debug = 'Y') THEN
			okc_debug.log ('2410: ENTERED -> CANCELLED; Updating price_negotiated and cancelled_amount for topline');
                END IF;

                Update  okc_k_lines_b
                set     cancelled_amount = nvl(cancelled_amount, 0) + nvl(price_negotiated, 0),
                        price_negotiated =  0
                Where   id = p_cle_id
                and     dnz_chr_id = p_id;
              /*Added for bug:8775250*/
                FOR  get_subline_price_csr_rec IN get_subline_price_csr(p_cle_id)
                LOOP
                 Update  okc_k_lines_b
 	            set  price_negotiated = nvl(price_negotiated,0) - nvl(get_subline_price_csr_rec.price_negotiated,0),
 	                 cancelled_amount = nvl(cancelled_amount,0) + nvl(get_subline_price_csr_rec.price_negotiated,0)
 	           Where cle_id = p_cle_id
 	             and id= get_subline_price_csr_rec.id
 	             and dnz_chr_id = p_id;
               END LOOP;

           ELSIF ((p_from_ste_code = 'CANCELLED' ) AND (p_to_ste_code = 'ENTERED')) THEN

                -- Cursor to get the lse_id of the top line

                Open    get_lse_id_csr (p_cle_id);
                Fetch   get_lse_id_csr into l_lse_id;
                Close   get_lse_id_csr;

                IF (l_lse_id = 46 ) THEN  --Checking if line type is of SUBSCRIPTION

                    IF (l_debug = 'Y') THEN
			okc_debug.log ('2420: CANCELLED -> ENTERED; Updating price_negotiated and cancelled_amount for SUBSCRIPTION topline');
                    END IF;

                    --updating the topline price_negotiated and cancelled_amount for SUBSCRIPTION line type

                    Update  okc_k_lines_b
                    set     price_negotiated = nvl(cancelled_amount,0),
                            cancelled_amount = 0
                    Where   id = p_cle_id
                    and     dnz_chr_id = p_id;


                ELSE  -- line type is not of SUBSCRIPTION type

                    IF (l_debug = 'Y') THEN
			okc_debug.log('2430: CANCELLED -> ENTERED; Updating price_negotiated and cancelled_amount for NON-SUBSCRIPTION topline');
                    END IF;
                 /*Added for bug:8775250*/
                 FOR  get_subline_cancel_csr_rec IN get_subline_cancel_csr(p_cle_id)
                    LOOP
                 Update  okc_k_lines_b
 	            set  price_negotiated = nvl(price_negotiated,0) + nvl(get_subline_cancel_csr_rec.cancelled_amount,0),
 	                 cancelled_amount = nvl(cancelled_amount,0) - nvl(get_subline_cancel_csr_rec.cancelled_amount,0)
 	           Where cle_id = p_cle_id
 	             and id=  get_subline_cancel_csr_rec.id
 	             and dnz_chr_id = p_id;
                  END LOOP;
                    Open get_uncancelled_amt_csr(p_cle_id, p_id);
                    Fetch get_uncancelled_amt_csr Into l_uncancelled_amt;
                    Close get_uncancelled_amt_csr;

                -- updating price_negotiated and cancelled_amount for top line which are not of type SUBSCRIPTION

                    Update  okc_k_lines_b
                    set     price_negotiated = nvl(price_negotiated, 0) + nvl(l_uncancelled_amt,0),
                            cancelled_amount = nvl(cancelled_amount,0) - nvl(l_uncancelled_amt,0)
                    Where   id = p_cle_id
                    and     dnz_chr_id = p_id;


                END IF; -- l_lse_id = 46

           END IF; -- (p_from_ste_code = 'ENTERED') AND (p_to_ste_code = 'CANCELLED')

        END IF;  -- l_cle_id is NOT NULL


    ELSE -- p_cle_id is NULL   --implies action is taken on header

            IF (l_debug = 'Y') THEN
		okc_debug.log('2500: Updating Header');
            END IF;

            IF ((p_from_ste_code = 'ENTERED') AND (p_to_ste_code = 'CANCELLED')) THEN

                IF (l_debug = 'Y') THEN
			okc_debug.log('2510: ENTERED -> CANCELLED; Updating price_negotiated and cancelled_amount for all toplines of contract');
                END IF;

                -- updating price_negotiated and cancelled_amount for all the top lines of the contract

                  update okc_k_lines_b
                  set   cancelled_amount = nvl(cancelled_amount, 0) + nvl(price_negotiated, 0),
                        price_negotiated = 0
                   where dnz_chr_id = p_id
                   and  cle_id is NULL
                   and  lse_id in  (1, 12, 14, 19, 46);
            /*Added for bug:8775250*/
             FOR get_lines_id_rec IN get_lines_id(p_id)
                 LOOP
                FOR  get_subline_price_csr_rec IN get_subline_price_csr(get_lines_id_rec.ID)
                    LOOP
                  Update  okc_k_lines_b
 	            set price_negotiated = nvl(price_negotiated,0) - nvl(get_subline_price_csr_rec.price_negotiated,0),
 	                cancelled_amount = nvl(cancelled_amount,0) + nvl(get_subline_price_csr_rec.price_negotiated,0)
 	           Where cle_id = get_lines_id_rec.id
 	             and id= get_subline_price_csr_rec.id
 	             and dnz_chr_id = p_id;
                     END LOOP;
                 END LOOP;


            ELSIF ((p_from_ste_code = 'CANCELLED' ) AND (p_to_ste_code = 'ENTERED')) THEN

                IF (l_debug = 'Y') THEN
			okc_debug.log('2520: CANCELLED -> ENTERED; Updating price_negotiated and cancelled_amount for all toplines of contract');
                END IF;
         /*Added for bug:8775250*/
              FOR get_lines_id_rec IN get_lines_id(p_id)
                  LOOP
                FOR  get_subline_cancel_csr_rec IN get_subline_cancel_csr(get_lines_id_rec.ID)
                  LOOP
                  Update okc_k_lines_b
 	             set price_negotiated = nvl(price_negotiated,0) + nvl(get_subline_cancel_csr_rec.cancelled_amount,0),
 	                 cancelled_amount = nvl(cancelled_amount,0) - nvl(get_subline_cancel_csr_rec.cancelled_amount,0)
 	           Where cle_id = get_lines_id_rec.id
 	             and id=  get_subline_cancel_csr_rec.id
 	             and dnz_chr_id = p_id;
                  END LOOP;
               END LOOP;
               -- Bug Fix 5026369 maanand 08-FEB-2006
	For topline In get_topline_id_csr
                               Loop
                             /*Bug:8775250 Included to populate the line amount for the Subscription line */
                                   IF (topline.lse_id = 46 ) THEN
                                      Update okc_k_lines_b
 	                  set price_negotiated = nvl(price_negotiated,0) + nvl(topline.cancelled_amount,0),
 	                        cancelled_amount = nvl(cancelled_amount,0) - nvl(topline.cancelled_amount,0)
 	             Where id = topline.id
 	                   and dnz_chr_id = p_id;

                                     ELSE
                                        Open get_uncancelled_amt_csr(topline.id, p_id);
	             Fetch get_uncancelled_amt_csr Into l_uncancelled_amt;
	             Close get_uncancelled_amt_csr;

	       -- updating price_negotiated and cancelled_amount for selected top line

	                Update  okc_k_lines_b
                                                set     price_negotiated = nvl(price_negotiated, 0) + nvl(l_uncancelled_amt,0),
	                                 cancelled_amount = nvl(cancelled_amount,0) - nvl(l_uncancelled_amt,0)
	                  Where   id = topline.id
	                       and     dnz_chr_id = p_id;
                                      END IF;
	 End Loop;


	/**
		    -- updating price_negotiated and cancelled_amount for all the top lines of the contract

                   update okc_k_lines_b
                   set     price_negotiated = nvl(price_negotiated, 0) + nvl(cancelled_amount, 0),
                           cancelled_amount = 0
                   where  dnz_chr_id = p_id
                   and    cle_id is NULL
                   and    lse_id in  (1, 12, 14, 19, 46);

	**/

		-- Bug Fix 5026369 maanand

            END IF;     --(p_from_ste_code = 'ENTERED') AND (p_to_ste_code = 'CANCELLED')

    END IF; --p_cle_id is NULL

            IF (l_debug = 'Y') THEN
		okc_debug.log('2600: Updating header estimated_amount and cancelled_amount');
            END IF;

    -- updating estimated_amount, cancelled_amount for header level of the contract due to change in the status of line/subline/contract

                  Open  get_hdr_amts_csr;
                  Fetch get_hdr_amts_csr Into l_hdr_estimated_amt, l_hdr_cancelled_amt;
                  Close get_hdr_amts_csr;

                  Update okc_k_headers_b
                  set   estimated_amount = l_hdr_estimated_amt,
                        cancelled_amount = l_hdr_cancelled_amt
                  where id = p_id;

---

x_return_status := FND_API.G_RET_STS_SUCCESS;

---
Exception

 WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF (l_debug = 'Y') THEN
		okc_debug.log('2700: Leaving OKC_CONTRACT_PVT, one or more mandatory parameters missing :FND_API.G_EXC_ERROR');
      END IF;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF (l_debug = 'Y') THEN
		okc_debug.log('2710: Leaving OKC_CONTRACT_PVT: FND_API.G_EXC_UNEXPECTED_ERROR '|| SQLERRM);
      END IF;

 WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF (l_debug = 'Y') THEN
		okc_debug.log('2720: Leaving OKC_CONTRACT_PVT because of EXCEPTION: '||sqlerrm);
      END IF;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name, SQLERRM );
      END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );


END UPDATE_CONTRACT_AMOUNT;

--



--[llc] Cancelled Amount Calculation

/*
  These functions [ Get_hdr_cancelled_amount() and Get_line_cancelled_amount() ]
  calculates the cancelled amounts for a contract or a contract line.
  Cancellation amount is exclusive of the tax amount.

  These functions are called from post_query of oks_headers and oks_lines respectively.
  This will populate the appropriate fields on the form.
*/

FUNCTION Get_hdr_cancelled_amount (p_id Number) RETURN NUMBER IS

    l_hdr_cancelled_amt  number := 0;

        Cursor get_hdr_cancelled_amt IS
                SELECT  cancelled_amount
                FROM    okc_k_headers_b
                WHERE   id = p_id;


BEGIN

    open get_hdr_cancelled_amt;
    fetch get_hdr_cancelled_amt into l_hdr_cancelled_amt;
    close get_hdr_cancelled_amt;

RETURN l_hdr_cancelled_amt;

End Get_hdr_cancelled_amount;
--

FUNCTION Get_line_cancelled_amount (p_cle_id Number, p_id Number) RETURN NUMBER IS

    l_line_cancelled_amt        NUMBER := 0;
        l_cle_id                                NUMBER := NULL;


        Cursor get_top_line_cancelled_amt IS
        SELECT  nvl(cancelled_amount, 0)
        FROM    okc_k_lines_b
        WHERE   id = p_cle_id
        and     dnz_chr_id = p_id;

        Cursor get_sub_line_cancelled_amt IS
        SELECT  nvl(price_negotiated, 0)
        FROM    okc_k_lines_b
        WHERE   id = p_cle_id
        and     dnz_chr_id = p_id
        and     date_cancelled is not null;

        Cursor  get_line_lvl_csr IS
                SELECT  cle_id
                FROM    okc_k_lines_b
                WHERE   id = p_cle_id
                and     dnz_chr_id = p_id;


BEGIN

        Open    get_line_lvl_csr;
        Fetch   get_line_lvl_csr into l_cle_id;
        Close   get_line_lvl_csr;

        IF (l_cle_id is NOT NULL) THEN  -- p_cle_id is a subline

                Open    get_sub_line_cancelled_amt;
                Fetch   get_sub_line_cancelled_amt into l_line_cancelled_amt;
                Close   get_sub_line_cancelled_amt;

        ELSE    -- p_cle_id is a topline

                Open    get_top_line_cancelled_amt;
                Fetch   get_top_line_cancelled_amt into l_line_cancelled_amt;
                Close   get_top_line_cancelled_amt;

        END IF;

RETURN l_line_cancelled_amt;

End Get_line_cancelled_amount;

---


--[llc] Line_Renewal_links

/* Procedure to clear/relink renewal links */

Procedure Line_Renewal_links (
    p_api_version       IN NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_target_chr_id     IN NUMBER ,
    p_target_line_id    IN NUMBER ,
    clean_relink_flag   IN VARCHAR2)
is

l_source_code       VARCHAR2(30):= 'DUMMY';
l_api_name          VARCHAR2(30) := 'CLEAN_REN_LINKS';
l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_active_yn         VARCHAR2(1) := 'N';

l_object_cle_id	     NUMBER;


--Fix Bug#4927824   18-JAN-2006	maanand

cursor trn_source_code (p_target_line_id NUMBER) IS
Select term_cancel_source, object_cle_id
from okc_k_lines_b olb, okc_operation_lines opl
where olb.id= p_target_line_id
and ( ( opl.object_cle_id = olb.id )

      OR

      (opl.subject_cle_id= olb.id )
    );

BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- set flag to update
IF (NVL(clean_relink_flag,'CLEAN') = 'RELINK') Then
    l_active_yn := 'Y';
END IF;

-- Get the source code of the line (MANUAL, IBTRANSFER, IBRETURN, IBTERMINATE, IBREPLACE)
Open trn_source_code(p_target_line_id);
Fetch trn_source_code into l_source_code, l_object_cle_id;
Close trn_source_code;

--Fix Bug#4927824   18-JAN-2006	maanand

l_source_code := nvl(l_source_code, 'DUMMY');

IF ( (l_source_code NOT IN ('IBTRANSFER', 'IBRETURN', 'IBTERMINATE', 'IBREPLACE')) AND ( l_object_cle_id is not null) )
THEN

--Fix Bug#4927824   18-JAN-2006	maanand
--Made changes to this query to make is semanitically correct

  UPDATE okc_operation_lines
    SET active_yn = l_active_yn,
           object_version_number = object_version_number + 1,
           last_updated_by = FND_GLOBAL.USER_ID,
           last_update_date = sysdate,
           last_update_login = FND_GLOBAL.LOGIN_ID

    where subject_cle_id in (	select id
				from okc_k_lines_b kle1
				start with kle1.id = p_target_line_id
				connect by prior kle1.id = kle1.cle_id
				and kle1.dnz_chr_id = p_target_chr_id)

    and subject_chr_id = p_target_chr_id;


    -- clear date_renewed only for those lines in target top lines

    UPDATE OKC_K_LINES_B
    SET date_renewed = decode(l_active_yn,'Y',sysdate,null),
           object_version_number = object_version_number + 1,
           last_updated_by = FND_GLOBAL.USER_ID,
           last_update_date = sysdate,
           last_update_login = FND_GLOBAL.LOGIN_ID
    WHERE id in
                ( SELECT object_cle_id
                  FROM okc_operation_lines ol1
                  WHERE ol1.subject_cle_id = p_target_line_id );


  -- clear date_renewed only for those lines in target sub lines

 UPDATE OKC_K_LINES_B
    SET date_renewed = decode(l_active_yn,'Y',sysdate,null),
           object_version_number = object_version_number + 1,
           last_updated_by = FND_GLOBAL.USER_ID,
           last_update_date = sysdate,
           last_update_login = FND_GLOBAL.LOGIN_ID
    WHERE cle_id in
                ( SELECT object_cle_id
                  FROM okc_operation_lines ol1
                  WHERE ol1.subject_cle_id = p_target_line_id );


 END IF;

    --Set minor version for updated contracts
    --
                   x_return_status := update_minor_version(p_target_chr_id);

                   IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                   ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                          raise OKC_API.G_EXCEPTION_ERROR;
                   END IF;


         OKC_CVM_PVT.g_trans_id :=  'XX-XX';

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
END Line_Renewal_links;


END OKC_CONTRACT_PVT;

/
