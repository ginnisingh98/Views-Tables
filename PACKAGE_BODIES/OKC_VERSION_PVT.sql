--------------------------------------------------------
--  DDL for Package Body OKC_VERSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_VERSION_PVT" as
/* $Header: OKCRVERB.pls 120.2.12000000.2 2007/02/06 12:51:35 skgoud ship $ */

-- Bug# 1553916
-- Private procedure for taking care of attachments
-- 1. Version a Contract in any Status
-- 2. Saving a Contract as opening a contract for update in 'Active' Status
-- 3. Restore back to an old Version
--

PROCEDURE version_attachments(
    p_chr_id 			   IN NUMBER,
    p_action                       IN VARCHAR2,
    p_major_version                IN NUMBER,
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2) IS
    --
    --
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_version_attachments';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_major_version		   number(4);
    l_minor_version		   number ;
    l_minus_version		   number := -1;
    l_rest_to_major_ver		   number(4);
    l_curr_major_ver               number(4);
    l_ver_num                      number; -- Counter variable
    --
    --
  cursor c_major_ver is
    select major_version
      from okc_k_vers_numbers
     where chr_id = p_chr_id;
  --
  cursor c_lines is
    select id
      from okc_k_lines_b
     where dnz_chr_id = p_chr_id;
  --
  cursor c_rest_to_ver is
    select object_version_number
      from okc_k_vers_numbers_h
     where chr_id = p_chr_id
       and major_version = l_minus_version;

begin

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- added for Bug 3431701
  Set_Attach_Session_Vars(p_chr_id);

  if (p_action = 'CREATE_VERSION' or p_action = 'SAVE_VERSION') then

    if p_major_version = -1 then
      open c_major_ver;
      fetch c_major_ver into l_major_version;
      close c_major_ver;
    else
      l_major_version := p_major_version - 1;
    end if;
  --
  -- When a contract is opened for update, it creates a -1 version of the contract to keep its last
  -- stable ACTIVE state. This -1 version is deleted only if the contract is restored back to this version
  -- or when we open the same contract for update next time.
  --
  if p_action = 'SAVE_VERSION' then
    --
    -- Remove Header Level Attachment
    --
     if fnd_attachment_util_pkg.get_atchmt_exists (l_entity_name => 'OKC_K_HEADERS_B',
 						   l_pkey1 => p_chr_id,
                                 l_pkey2 => l_minus_version) = 'Y' then

       fnd_attached_documents2_pkg.delete_attachments(
						x_entity_name => 'OKC_K_HEADERS_B',
						x_pk1_value   => p_chr_id,
                              x_pk2_value   => l_minus_version,
                              x_delete_document_flag => 'Y'); --

     end if;
    --
    -- Remove Line Level Attachment
    --
     for c_lines_rec in c_lines loop
       --
       if fnd_attachment_util_pkg.get_atchmt_exists (l_entity_name => 'OKC_K_LINES_B',
 						     l_pkey1 => c_lines_rec.id,
						     l_pkey2 => l_minus_version) = 'Y' then

         fnd_attached_documents2_pkg.delete_attachments(
							x_entity_name => 'OKC_K_LINES_B',
							x_pk1_value   => c_lines_rec.id,
                                   x_pk2_value   => l_minus_version,
                                   x_delete_document_flag => 'Y');

       end if;
     end loop;
  end if;
  --
  -- Creating Attachments for -1 level version of the contract
  --
  -- version Header Level Attachments
  --
    if fnd_attachment_util_pkg.get_atchmt_exists (l_entity_name => 'OKC_K_HEADERS_B',
 						  l_pkey1 => p_chr_id,
						  l_pkey2 => l_major_version) = 'Y' then

        fnd_attached_documents2_pkg.copy_attachments(
						    x_from_entity_name => 'OKC_K_HEADERS_B',
						    x_from_pk1_value   => p_chr_id,
						    x_from_pk2_value   => l_major_version,
						    x_to_entity_name   => 'OKC_K_HEADERS_B',
						    x_to_pk1_value     => p_chr_id,
						    x_to_pk2_value     => p_major_version);
   end if;
  --
  -- Version Line Level Attachments
  --
   for c_lines_rec in c_lines loop
    --
    if fnd_attachment_util_pkg.get_atchmt_exists (l_entity_name => 'OKC_K_LINES_B',
 						  l_pkey1 => c_lines_rec.id,
						  l_pkey2 => l_major_version) = 'Y' then

        fnd_attached_documents2_pkg.copy_attachments(
						    x_from_entity_name => 'OKC_K_LINES_B',
						    x_from_pk1_value   => c_lines_rec.id,
						    x_from_pk2_value   => l_major_version,
						    x_to_entity_name   => 'OKC_K_LINES_B',
						    x_to_pk1_value     => c_lines_rec.id,
						    x_to_pk2_value     => p_major_version);
   end if;
   --
  end loop;
  --
  -- While restoring version all the attachments are removed up to the version that is to be restored.
  -- It is possible that when the user opens a contract for update, he may add, remove, update attachments.
  -- The attachments copied with version -1 are re-attached to the version that is restores.
  --
   elsif (p_action = 'RESTORE_VERSION') then
    --
      open  c_major_ver;
      fetch c_major_ver into l_curr_major_ver;
      close c_major_ver;
    --
      open  c_rest_to_ver;
      fetch c_rest_to_ver into l_rest_to_major_ver;
      close c_rest_to_ver;
    --
--
-- Delete Header Level Attachments with version
--
   for l_ver_num in l_rest_to_major_ver..l_curr_major_ver loop

     if fnd_attachment_util_pkg.get_atchmt_exists (l_entity_name => 'OKC_K_HEADERS_B',
 						   l_pkey1 => p_chr_id,
                                                   l_pkey2 => l_ver_num) = 'Y' then

       fnd_attached_documents2_pkg.delete_attachments(
						x_entity_name => 'OKC_K_HEADERS_B',
						x_pk1_value   => p_chr_id,
                                                x_pk2_value   => l_ver_num,
                                                x_delete_document_flag => 'Y');

     end if;
     --
     if l_ver_num = l_rest_to_major_ver then
       --
       if fnd_attachment_util_pkg.get_atchmt_exists (l_entity_name => 'OKC_K_HEADERS_B',
 						     l_pkey1 => p_chr_id,
						     l_pkey2 => l_minus_version) = 'Y' then

        fnd_attached_documents2_pkg.copy_attachments(
						    x_from_entity_name => 'OKC_K_HEADERS_B',
						    x_from_pk1_value   => p_chr_id,
						    x_from_pk2_value   => l_minus_version,
						    x_to_entity_name   => 'OKC_K_HEADERS_B',
						    x_to_pk1_value     => p_chr_id,
						    x_to_pk2_value     => l_ver_num);
       end if;
       --
     end if;
   end loop;
  --
  -- Remove Line Level Attachments
  --
   for c_lines_rec in c_lines loop
    --
     for l_ver_num in l_rest_to_major_ver..l_curr_major_ver loop
       if fnd_attachment_util_pkg.get_atchmt_exists (l_entity_name => 'OKC_K_LINES_B',
 						     l_pkey1 => c_lines_rec.id,
						     l_pkey2 => l_ver_num) = 'Y' then

         fnd_attached_documents2_pkg.delete_attachments(
							x_entity_name => 'OKC_K_LINES_B',
							x_pk1_value   => c_lines_rec.id,
                                   x_pk2_value   => l_ver_num,
                                   x_delete_document_flag => 'Y');

       end if;
       --
       --
       if l_ver_num = l_rest_to_major_ver then
       --
         if fnd_attachment_util_pkg.get_atchmt_exists (l_entity_name => 'OKC_K_LINES_B',
 						       l_pkey1 => c_lines_rec.id,
						       l_pkey2 => l_minus_version) = 'Y' then

            fnd_attached_documents2_pkg.copy_attachments(
						    x_from_entity_name => 'OKC_K_LINES_B',
						    x_from_pk1_value   => c_lines_rec.id,
						    x_from_pk2_value   => l_minus_version,
						    x_to_entity_name   => 'OKC_K_LINES_B',
						    x_to_pk1_value     => c_lines_rec.id,
						    x_to_pk2_value     => l_ver_num);
         end if;
         --
       end if;
       --
     end loop;
   end loop;
    --
    --
-- Added on 03/29/2001
-- following delete attachment statements are required to get rid of -1 version of attachments after a restore is made.
--
    --
    -- Remove Header Level Attachment
    --
     if fnd_attachment_util_pkg.get_atchmt_exists (l_entity_name => 'OKC_K_HEADERS_B',
 						   l_pkey1 => p_chr_id,
                                 l_pkey2 => l_minus_version) = 'Y' then

       fnd_attached_documents2_pkg.delete_attachments(
						x_entity_name => 'OKC_K_HEADERS_B',
						x_pk1_value   => p_chr_id,
                              x_pk2_value   => l_minus_version,
                              x_delete_document_flag => 'Y'); --

     end if;
    --
    -- Remove Line Level Attachment
    --
     for c_lines_rec in c_lines loop
       --
       if fnd_attachment_util_pkg.get_atchmt_exists (l_entity_name => 'OKC_K_LINES_B',
 						     l_pkey1 => c_lines_rec.id,
						     l_pkey2 => l_minus_version) = 'Y' then

         fnd_attached_documents2_pkg.delete_attachments(
							x_entity_name => 'OKC_K_LINES_B',
							x_pk1_value   => c_lines_rec.id,
                                   x_pk2_value   => l_minus_version,
                                   x_delete_document_flag => 'Y');

       end if;
     end loop;
-- Added on 03/29/2001
  end if;
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
end version_attachments;

--
-- p_pdf id is for Process Defn id for OKS seeded procedure
--
PROCEDURE OKC_VERSION_PLSQL (p_pdf_id IN  NUMBER,
                             x_string OUT NOCOPY VARCHAR2) IS
  l_string     VARCHAR2(2000);

  -- Cursor to get the package.procedure name from PDF
  CURSOR pdf_cur(l_pdf_id IN NUMBER) IS
   SELECT
   decode(pdf.pdf_type,'PPS',
          pdf.package_name||'.'||pdf.procedure_name,NULL) proc_name
   FROM okc_process_defs_v pdf
   WHERE pdf.id = l_pdf_id;

   pdf_rec pdf_cur%ROWTYPE;

   BEGIN
      OPEN pdf_cur(p_pdf_id);
      FETCH pdf_cur INTO pdf_rec;
      CLOSE pdf_cur;

      l_string := l_string||pdf_rec.proc_name;
      x_string := l_string ;

  END OKC_VERSION_PLSQL;

--
--Public procedure to version various components of a contract
--
PROCEDURE version_contract(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvmv_rec                     IN  cvmv_rec_type,
    x_cvmv_rec                     OUT NOCOPY cvmv_rec_type,
    p_commit			   IN  VARCHAR2 DEFAULT OKC_API.G_TRUE) IS


    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_Version_Contract';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_chr_id                       Number;
    l_major_version                Number;
    l_cvmv_rec			   cvmv_rec_type;
    l_cls_code 			   OKC_SUBCLASSES_B.CLS_CODE%TYPE:=OKC_API.G_MISS_CHAR;
    l_pdf_id                       NUMBER := NULL;
    l_string                       VARCHAR2(4000);
    proc_string                    VARCHAR2(4000);
    l_msg_data                     varchar2(2000);
    l_doc_type                     varchar2(30);
    l_doc_id                       Number;
    l_msg_count                    NUMBER;

    -- Cursor to get the class code
    CURSOR cur_scs(p_chr_id number) is
       SELECT cls_code
       FROM okc_k_headers_b, okc_subclasses_b
       WHERE id = p_chr_id and code = scs_code;

    -- Cursor created to get the PDF_ID for a particular Class
    CURSOR c_pdf(p_cls_code VARCHAR2) IS
    SELECT pdf_id
    FROM okc_class_operations
    WHERE opn_code = 'VERSIONING'
    AND   cls_code = p_cls_code;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -- Get the version number from okc_k_vers_numbers
    okc_cvm_pvt.version_contract_version(
    p_api_version                  =>p_api_version,
    p_init_msg_list                =>p_init_msg_list,
    x_return_status                =>l_return_status,
    x_msg_count                    =>x_msg_count,
    x_msg_data                     =>x_msg_data,
    p_cvmv_rec                     =>p_cvmv_rec,
    x_cvmv_rec                     =>l_cvmv_rec);

    --- If any errors happen abort API

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --
    l_chr_id:=l_cvmv_rec.chr_id;
    l_major_version:=l_cvmv_rec.major_version;

    OPEN cur_scs(l_chr_id);
    FETCH cur_scs into l_cls_code;
    CLOSE cur_scs;

    OPEN c_pdf(l_cls_code);
    FETCH c_pdf INTO l_pdf_id;
    CLOSE c_pdf;

    If l_pdf_id IS NOT NULL Then
       okc_version_plsql (p_pdf_id => l_pdf_id,
                          x_string => l_string) ;
    End If;

    IF l_string is NOT NULL THEN
       proc_string := 'begin '||l_string || ' (:b1,:b2); end ;';
        EXECUTE IMMEDIATE proc_string using l_chr_id, out l_return_status;

        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
    End If;
    --
    -- Version Attachments - CREATE_VERSION
    --
    version_attachments(p_chr_id        => l_chr_id,
                        p_action        => 'CREATE_VERSION',
                        p_major_version => l_major_version,
                        p_api_version   => p_api_version,
                        x_return_status =>l_return_status,
                        x_msg_count     =>x_msg_count,
                        x_msg_data      =>x_msg_data);
    --
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --
    --version contract header
    --
    l_return_status:=OKC_CHR_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version contract lines

    l_return_status:=OKC_CLE_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version contract items
    l_return_status:=OKC_CIM_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version contract party roles
    l_return_status:=OKC_CPL_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version RuleGroup party roles
    l_return_status:=OKC_RMP_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version Rule Groups
    l_return_status:=OKC_RGP_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version Rules
    l_return_status:=OKC_RUL_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    --version Contacts
    l_return_status:=OKC_CTC_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version cover times
    l_return_status:=OKC_CTI_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version contract accesses
    l_return_status:=OKC_CAC_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version outcome arguments
    l_return_status:=OKC_OAT_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version outcomes
    l_return_status:=OKC_OCE_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version react intervals
    l_return_status:=OKC_RIL_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    --version timevalues
    l_return_status:=OKC_TAV_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version contract processes
    l_return_status:=OKC_CPS_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version condition headers
    l_return_status:=OKC_CNH_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    --version condition lines
    l_return_status:=OKC_CNL_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version function_expr_params
    l_return_status:=OKC_FEP_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version governances
    l_return_status:=OKC_GVE_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


  ------VERSION_PRICE_ADJUSTMENTS
    l_return_status:=OKC_PAT_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

     --VERSION_PRICE_ADJ_ASSOCS
    l_return_status:=OKC_PAC_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    --VERSION_PRICE_ADJ_ATTRIBS
    l_return_status:=OKC_PAA_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --VERSION_PRICE_ATT_VALUES
    l_return_status:=OKC_PAV_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    --VERSION SALES CREDITS
    l_return_status:=OKC_SCR_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;


    --VERSION PRICE HOLD BREAK LINES
    l_return_status:=OKC_PHL_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;


      --VERSION TERMS and Condition and Deliverables
         okc_terms_util_grp.get_contract_document_type_id(
                                         p_api_version    => 1,
                                         p_init_msg_list  => FND_API.G_FALSE,
                                         x_return_status  => l_return_status,
                                         x_msg_data       => l_msg_data,
                                         x_msg_count      => l_msg_count,
                                         p_chr_id         => l_chr_id,
                                         x_doc_id         => l_doc_id,
                                         x_doc_type       => l_doc_type);

        --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         	 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

OKC_TERMS_VERSION_GRP.Version_doc(
                      p_api_version   => 1,
                      x_return_status => l_return_status,
                      x_msg_data      => l_msg_data,
                      x_msg_count     => l_msg_count,
                      p_doc_type      => l_doc_type,
                      p_doc_id        => l_doc_id,
                      p_version_number =>l_major_version,
                      p_clear_amendment =>'Y');

    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     	 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;



    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    x_cvmv_rec:=l_cvmv_rec;
    x_return_status:=l_return_status;

    if (p_commit = OKC_API.G_TRUE) then commit; end if;

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
END Version_Contract;

--Public procedure to save contract version
--Added parameter p_commit 11/09/200 02:00PM

PROCEDURE save_version(
    p_chr_id 				IN  NUMBER,
    p_api_version             IN  NUMBER,
    p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2,
    p_commit			     IN  VARCHAR2 DEFAULT OKC_API.G_TRUE) IS


    l_api_version             CONSTANT NUMBER := 1;
    l_api_name                CONSTANT VARCHAR2(30) := 'V_save_version';
    l_return_status           VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_major_version	      CONSTANT NUMBER := -1;
    l_major_version2	      CONSTANT NUMBER := -2;
    l_chr_id		      NUMBER := p_chr_id;
    l_code                    VARCHAR2(30);
    l_msg_data                varchar2(2000);
    l_doc_type                varchar2(30);
    l_doc_id                  number;
    l_msg_count               NUMBER;

cursor v_lock is
select '!' from okc_k_vers_numbers
where chr_id = p_chr_id
for update of MAJOR_VERSION, MINOR_VERSION
nowait;

cursor c_curs is
select b.cls_code
from okc_k_headers_b a,okc_subclasses_b b
where a.scs_code=b.code and a.id = p_chr_id;

l_dummy varchar2(1);


  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

  begin
    open v_lock;
    fetch v_lock into l_dummy;
    close v_lock;
  exception
    when others then
      OKC_API.set_message(OKC_API.G_FND_APP,OKC_API.G_FORM_UNABLE_TO_RESERVE_REC);
      RAISE OKC_API.G_EXCEPTION_ERROR;
  end;

    -- Version Attachments SAVE_VERSION
    --
  OPEN c_curs;             --added for bug 2765502
  FETCH c_curs into l_code;
  ClOSE c_curs;

  IF l_code = 'SERVICE' Or
     ((l_code <>'SERVICE') And
      (FND_PROFILE.VALUE_SPECIFIC('OKC_REVERT_OPTION') = 'ALLOW')) THEN
       version_attachments(p_chr_id        => p_chr_id,
                        p_action        => 'SAVE_VERSION',
                        p_major_version => -1,
                        p_api_version   => p_api_version,
                        x_return_status =>l_return_status,
                        x_msg_count     =>x_msg_count,
                        x_msg_data      =>x_msg_data);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
  END IF;
    --
    erase_saved_version(
    		p_chr_id => p_chr_id,
	    	p_api_version => p_api_version,
    		p_init_msg_list => p_init_msg_list,
    		x_return_status => l_return_status,
    		x_msg_count => x_msg_count,
    		x_msg_data => x_msg_data,
		p_commit => OKC_API.G_FALSE);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version contract header

  IF FND_PROFILE.VALUE_SPECIFIC('OKC_REVERT_OPTION') <> 'ALLOW' AND l_code<>'SERVICE'  THEN
    l_return_status:=OKC_CHR_PVT.Create_Version(l_chr_id,l_major_version2);

   --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

  ELSE

   l_return_status:=OKC_CHR_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version contract lines

    l_return_status:=OKC_CLE_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version contract items
    l_return_status:=OKC_CIM_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version contract party roles
    l_return_status:=OKC_CPL_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version RuleGroup party roles
    l_return_status:=OKC_RMP_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version Rule Groups
    l_return_status:=OKC_RGP_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version Rules
    l_return_status:=OKC_RUL_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version Contacts
    l_return_status:=OKC_CTC_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version cover times
    l_return_status:=OKC_CTI_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version contract accesses
    l_return_status:=OKC_CAC_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version outcome arguments
    l_return_status:=OKC_OAT_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version outcomes
    l_return_status:=OKC_OCE_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version react intervals
    l_return_status:=OKC_RIL_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    --version timevalues
    l_return_status:=OKC_TAV_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version contract processes
    l_return_status:=OKC_CPS_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version condition headers
    l_return_status:=OKC_CNH_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    --version condition lines
    l_return_status:=OKC_CNL_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version function_expr_params
    l_return_status:=OKC_FEP_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --version governances
    l_return_status:=OKC_GVE_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    ------VERSION_PRICE_ADJUSTMENTS
    l_return_status:=OKC_PAT_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

     --VERSION_PRICE_ADJ_ASSOCS
    l_return_status:=OKC_PAC_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    --VERSION_PRICE_ADJ_ATTRIBS
    l_return_status:=OKC_PAA_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --VERSION_PRICE_ATT_VALUES
    l_return_status:=OKC_PAV_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;


    --VERSION SALES CREDITS
    l_return_status:=OKC_SCR_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;


     --VERSION PRICE HOLD BREAK LINES
    l_return_status:=OKC_PHL_PVT.Create_Version(l_chr_id,l_major_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;



         okc_terms_util_grp.get_contract_document_type_id(
                                         p_api_version    => 1,
                                         p_init_msg_list  => FND_API.G_FALSE,
                                         x_return_status  => l_return_status,
                                         x_msg_data       => l_msg_data,
                                         x_msg_count      => l_msg_count,
                                         p_chr_id         => l_chr_id,
                                         x_doc_id         => l_doc_id,
                                         x_doc_type       => l_doc_type);

        --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         	 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

OKC_TERMS_VERSION_GRP.Version_doc(
                      p_api_version   => 1,
                      x_return_status => l_return_status,
                      x_msg_data      => l_msg_data,
                      x_msg_count     => l_msg_count,
                      p_doc_type      => l_doc_type,
                      p_doc_id        => l_doc_id,
                      p_version_number =>l_major_version,
                      p_clear_amendment =>'Y');

    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     	 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

-- just to save maj/min versions somewhere
    insert into okc_k_vers_numbers_h
    (
	CHR_ID
	,MAJOR_VERSION
	,MINOR_VERSION
	,OBJECT_VERSION_NUMBER
	,CREATED_BY
	,CREATION_DATE
	,LAST_UPDATED_BY
	,LAST_UPDATE_DATE
	,LAST_UPDATE_LOGIN
    ) select
	CHR_ID
	,-1 -- otherwise UK violation
	,MINOR_VERSION
	,MAJOR_VERSION -- comes here instead of OBJECT_VERSION_NUMBER
	,CREATED_BY
	,CREATION_DATE
	,FND_GLOBAL.USER_ID
	,sysdate
	,FND_GLOBAL.LOGIN_ID
    from okc_k_vers_numbers
    where chr_id = p_chr_id;

  END IF;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    x_return_status:=l_return_status;

    if (p_commit = OKC_API.G_TRUE) then commit; end if;

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
END save_version;

-- Private procedure for deleteting a version of the contract
-- Added as a part of Bug:
--

Procedure delete_version (p_chr_id 	  IN NUMBER,
					 p_major_version IN NUMBER,
					 p_minor_version IN NUMBER,
					 p_called_from   IN VARCHAR2) IS

l_major_version number := p_major_version;
l_minor_version number := p_minor_version;
l_msg_data                     varchar2(2000);
l_return_status                varchar2(1);
l_doc_type                     varchar2(30);
l_doc_id                       Number;
l_msg_count                    NUMBER;

begin
   DELETE FROM OKC_K_HEADERS_TLH
     WHERE id = p_chr_id
	  AND (MAJOR_VERSION = -2
	  AND p_called_from = 'ERASE_SAVED_VERSION');

    DELETE FROM OKC_K_HEADERS_BH
     WHERE id= p_chr_id
	  AND (MAJOR_VERSION = -2
	  AND p_called_from = 'ERASE_SAVED_VERSION');

IF SQL%NOTFOUND THEN

--
    delete FROM OKC_CONDITION_HEADERS_TLH
     WHERE id in (select id from OKC_CONDITION_HEADERS_BH
	 		WHERE dnz_chr_id= p_chr_id)
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));
--
    delete FROM OKC_CONDITION_HEADERS_BH
     WHERE dnz_chr_id= p_chr_id
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));
--
    delete FROM OKC_CONDITION_LINES_TLH
     WHERE id in (select id from OKC_CONDITION_LINES_BH
	 		WHERE dnz_chr_id= p_chr_id)
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));
--
    delete FROM OKC_CONDITION_LINES_BH
     WHERE dnz_chr_id= p_chr_id
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));
--
    delete FROM OKC_CONTACTS_H
     WHERE dnz_chr_id= p_chr_id
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));
--
    delete FROM OKC_COVER_TIMES_H
     WHERE dnz_chr_id= p_chr_id
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));
--
    delete FROM OKC_FUNCTION_EXPR_PARAMS_H
     WHERE dnz_chr_id= p_chr_id
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));
--
    delete FROM OKC_GOVERNANCES_H
     WHERE dnz_chr_id= p_chr_id
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));
--
    delete FROM OKC_K_ACCESSES_H
     WHERE chr_id= p_chr_id
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));
--
    delete FROM OKC_K_HEADERS_TLH
     WHERE id = p_chr_id
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));
--
    delete FROM OKC_K_HEADERS_BH
     WHERE id= p_chr_id
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));

    delete FROM OKS_K_HEADERS_BH
     WHERE chr_id= p_chr_id
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));
--
    delete FROM OKC_K_ITEMS_H
     WHERE dnz_chr_id= p_chr_id
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));
--
    delete FROM OKC_K_LINES_TLH
     WHERE id in (select id from OKC_K_LINES_BH
	 		WHERE dnz_chr_id= p_chr_id)
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));
--
    delete FROM OKC_K_LINES_BH
     WHERE dnz_chr_id= p_chr_id
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));

 delete FROM OKS_K_LINES_TLH
     WHERE id in (select id from OKS_K_LINES_BH
	 		WHERE dnz_chr_id= p_chr_id)
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));

    delete FROM OKS_K_LINES_BH
     WHERE dnz_chr_id= p_chr_id
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));

    delete FROM OKC_K_PARTY_ROLES_TLH
     WHERE id in (select id from OKC_K_PARTY_ROLES_BH
	 		WHERE dnz_chr_id= p_chr_id)
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));
--
    delete FROM OKC_K_PARTY_ROLES_BH
     WHERE dnz_chr_id= p_chr_id
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));
--
    delete FROM OKC_K_PROCESSES_H
     WHERE chr_id= p_chr_id
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));
--
    delete FROM OKC_OUTCOME_ARGUMENTS_H
     WHERE dnz_chr_id= p_chr_id
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));
--
    delete FROM OKC_OUTCOMES_TLH
     WHERE id in (select id from OKC_OUTCOMES_BH
	 		WHERE dnz_chr_id= p_chr_id)
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));
--
    delete FROM OKC_OUTCOMES_BH
     WHERE dnz_chr_id= p_chr_id
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));
--
    delete FROM OKC_REACT_INTERVALS_H
     WHERE dnz_chr_id= p_chr_id
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));
--
    delete FROM OKC_RG_PARTY_ROLES_H
     WHERE dnz_chr_id= p_chr_id
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));
--
    delete FROM OKC_RULE_GROUPS_TLH
     WHERE id in (select id from OKC_RULE_GROUPS_BH
	 		WHERE dnz_chr_id= p_chr_id)
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));
--
    delete FROM OKC_RULE_GROUPS_BH
     WHERE dnz_chr_id= p_chr_id
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));
--
--Bug 3055393
/*
    delete FROM OKC_RULES_TLH
     WHERE id in (select id from OKC_RULES_BH
	 		WHERE dnz_chr_id= p_chr_id)
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));

--
    delete FROM OKC_RULES_BH
     WHERE dnz_chr_id= p_chr_id
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));
--
*/
--Bug 3122962
/*
    delete FROM OKC_TIMEVALUES_TLH
     WHERE id in (select id from OKC_TIMEVALUES_BH
	 		WHERE dnz_chr_id= p_chr_id)
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));
*/
--
--Bug 3122962
    delete FROM OKC_TIMEVALUES_H
     WHERE dnz_chr_id= p_chr_id
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	   or major_version = -1)));
--

     delete FROM OKC_PRICE_ADJUSTMENTS_H
     WHERE chr_id= p_chr_id
          and ((MAJOR_VERSION = -1
          and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
          and (major_version > l_major_version
           or major_version = -1)));
--

    delete FROM OKC_PRICE_ADJ_ASSOCS_H
     WHERE pat_id  IN
        ( SELECT pat_id
          FROM OKC_PRICE_ADJUSTMENTS
          WHERE chr_id = p_chr_id
             )
          and ((MAJOR_VERSION = -1
          and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
          and (major_version > l_major_version
           or major_version = -1)));
--
    delete FROM OKC_PRICE_ADJ_ATTRIBS_H
     WHERE pat_id  IN
        ( SELECT pat_id
          FROM OKC_PRICE_ADJUSTMENTS
          WHERE chr_id = p_chr_id
             )
          and ((MAJOR_VERSION = -1
          and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
          and (major_version > l_major_version
           or major_version = -1)));

-- bug 5679233
-- decomposed the delete query into following two sub queries because of performance issues

    delete FROM OKC_PRICE_ATT_VALUES_H
     WHERE (chr_id= p_chr_id )
          and ((MAJOR_VERSION = -1
          and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
          and (major_version >= l_major_version
           or major_version = -1)));

    delete FROM OKC_PRICE_ATT_VALUES_H
     WHERE (CLE_ID IN (SELECT ID FROM OKC_K_LINES_B WHERE DNZ_CHR_ID=p_chr_id ) )
          and ((MAJOR_VERSION = -1
          and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
          and (major_version >= l_major_version
           or major_version = -1)));

-- bug 5679233 ends

    delete FROM OKC_PH_LINE_BREAKS_H       --price hold
     WHERE cle_id IN
         (SELECT id
          FROM okc_k_lines_b
          WHERE dnz_chr_id = p_chr_id        --price hold sub-line
             )
         and ((MAJOR_VERSION = -1
          and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
          and (major_version > l_major_version
           or major_version = -1)));



         okc_terms_util_grp.get_contract_document_type_id(
                                         p_api_version    => 1,
                                         p_init_msg_list  => FND_API.G_FALSE,
                                         x_return_status  => l_return_status,
                                         x_msg_data       => l_msg_data,
                                         x_msg_count      => l_msg_count,
                                         p_chr_id         => p_chr_id,
                                         x_doc_id         => l_doc_id,
                                         x_doc_type       => l_doc_type);

        --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         	 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

       	IF  p_called_from = 'ERASE_SAVED_VERSION' then

            OKC_TERMS_VERSION_GRP.delete_doc_version(
                      p_api_version   => 1,
                      x_return_status => l_return_status,
                      x_msg_data      => l_msg_data,
                      x_msg_count     => l_msg_count,
                      p_doc_type      => l_doc_type,
                      p_doc_id        => l_doc_id,
                      p_version_number =>-1);

          --- If any errors happen abort API
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     	         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;
      END IF;

      IF  p_called_from = 'RESTORE_VERSION'  then

          FOR CR in (Select major_version from okc_k_headers_hv where id=p_chr_id and (major_version > p_major_version or major_version=-1)) LOOP

            OKC_TERMS_VERSION_GRP.delete_doc_version(
                      p_api_version   => 1,
                      x_return_status => l_return_status,
                      x_msg_data      => l_msg_data,
                      x_msg_count     => l_msg_count,
                      p_doc_type      => l_doc_type,
                      p_doc_id        => l_doc_id,
                      p_version_number=> cr.major_version);

          --- If any errors happen abort API
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     	         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;
         END LOOP;
      END IF;
--
    delete FROM okc_k_vers_numbers_h
     WHERE chr_id= p_chr_id
	  and ((MAJOR_VERSION = -1
	  and p_called_from = 'ERASE_SAVED_VERSION')
        or (p_called_from = 'RESTORE_VERSION'
	  and (major_version > l_major_version
	  or  ((major_version = l_major_version
	  and minor_version >= l_minor_version))
	   or major_version = -1)));

END IF;

end delete_version;
--
--Public procedure just to erase saved contract version
PROCEDURE erase_saved_version(
    p_chr_id 				IN NUMBER,
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_commit 				IN VARCHAR2 DEFAULT OKC_API.G_TRUE) IS


    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_erase_saved_version';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_cls_code                     OKC_SUBCLASSES_B.CLS_CODE%TYPE:=OKC_API.G_MISS_CHAR;
    l_pdf_id                       NUMBER := NULL;
    l_string                       VARCHAR2(32000);
    proc_string                    VARCHAR2(32000);

    -- Cursor to get the class code
    CURSOR cur_scs(p_chr_id number) is
       SELECT cls_code
       FROM okc_k_headers_b, okc_subclasses_b
       WHERE id = p_chr_id and code = scs_code;

     -- Cursor created to get the PDF_ID for a particular Class
    CURSOR c_pdf(p_cls_code VARCHAR2) IS
    SELECT pdf_id
    FROM okc_class_operations
    WHERE opn_code = 'ERASE_VERSION'
    AND   cls_code = p_cls_code;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
--
-- All the delete lines from here are moved into private procedure delete_version
--
   delete_version(p_chr_id =>p_chr_id,
			   p_major_version => -1,
			   p_minor_version => null,
			   p_called_from => 'ERASE_SAVED_VERSION');
--
    OPEN cur_scs(p_chr_id);
    FETCH cur_scs into l_cls_code;
    CLOSE cur_scs;

    OPEN c_pdf(l_cls_code);
    FETCH c_pdf INTO l_pdf_id;
    CLOSE c_pdf;

    If l_pdf_id IS NOT NULL Then
       okc_version_plsql (p_pdf_id => l_pdf_id,
                          x_string => l_string) ;
    End If;

    IF l_string is NOT NULL THEN
       proc_string := 'begin '||l_string || ' (:b1,:b2); end ;';
        EXECUTE IMMEDIATE proc_string using p_chr_id, out l_return_status;

        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
    End If;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    x_return_status:=l_return_status;

    if (p_commit = OKC_API.G_TRUE) then commit; end if;

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
END erase_saved_version;


--Public procedure to restore contract version
-- Added parameter p_commit on 09/11/2000 02:00PM
--
PROCEDURE restore_version(
    p_chr_id 			   IN NUMBER,
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_commit			   IN VARCHAR2 DEFAULT OKC_API.G_TRUE) IS
--
--
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_restore_version';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_major_version		   number;
    l_minor_version		   number;
    l_minus_version		   number := -1;
    l_chr_id                       number := p_chr_id;
    l_msg_data                     varchar2(2000);
    l_doc_type                     varchar2(30);
    l_doc_id                       number;
    l_msg_count                    NUMBER;

cursor v is
	select object_version_number, minor_version
	from okc_k_vers_numbers_h
     	WHERE chr_id= p_chr_id
	and MAJOR_VERSION = -1;

cursor v_lock is
select '!' from okc_k_vers_numbers
where chr_id = p_chr_id
for update of MAJOR_VERSION, MINOR_VERSION
nowait;
/*Added for Bug 5175907 */
    Cursor l_status_csr Is
		SELECT sts_code
		FROM okc_k_headers_b
		WHERE ID = p_chr_id;

    CURSOR version_csr(p_chr_id NUMBER) IS
    	SELECT to_char (major_version)||'.'||to_char(minor_version)
    	FROM okc_k_vers_numbers
    	WHERE chr_id=p_chr_id;
l_dummy varchar2(1);
        l_version  Varchar2(240);
        l_contract_old_status Varchar2(30);
        l_contract_new_status Varchar2(30);
        l_hstv_rec      OKC_K_HISTORY_PVT.hstv_rec_type;
        x_hstv_rec      OKC_K_HISTORY_PVT.hstv_rec_type;


  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
--
    open v;
    fetch v into  l_major_version, l_minor_version;
    close v;
--

  begin
    open v_lock;
    fetch v_lock into l_dummy;
    close v_lock;
  exception
    when others then
      OKC_API.set_message(OKC_API.G_FND_APP,OKC_API.G_FORM_UNABLE_TO_RESERVE_REC);
      RAISE OKC_API.G_EXCEPTION_ERROR;
  end;

    -- Version Attachments - RESTORE_VERSION
    --
    version_attachments(p_chr_id        => l_chr_id,
                        p_action        => 'RESTORE_VERSION',
                        p_major_version => NULL,
                        p_api_version   => p_api_version,
                        x_return_status =>l_return_status,
                        x_msg_count     =>x_msg_count,
                        x_msg_data      =>x_msg_data);
    --
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --
    -- To get the old status
    open l_status_csr;
    fetch l_status_csr into l_Contract_old_status;
    close l_status_csr;


     delete from OKC_CONDITION_HEADERS_TL
	WHERE id in (select id from OKC_CONDITION_HEADERS_B
	 		WHERE dnz_chr_id= p_chr_id);

     delete from OKC_CONDITION_HEADERS_B where DNZ_CHR_ID = p_chr_id;

     delete from OKC_CONDITION_LINES_TL
	WHERE id in (select id from OKC_CONDITION_LINES_B
	 		WHERE dnz_chr_id= p_chr_id);

     delete from OKC_CONDITION_LINES_B where DNZ_CHR_ID = p_chr_id;

     delete from OKC_CONTACTS where DNZ_CHR_ID = p_chr_id;

     delete from OKC_COVER_TIMES where DNZ_CHR_ID = p_chr_id;

     delete from OKC_FUNCTION_EXPR_PARAMS where DNZ_CHR_ID = p_chr_id;

     delete from OKC_GOVERNANCES where DNZ_CHR_ID = p_chr_id;

     delete from OKC_K_ACCESSES where CHR_ID = p_chr_id;

     delete from OKC_K_HEADERS_TL
     WHERE id = p_chr_id;

     delete from OKC_K_HEADERS_B where ID = p_chr_id;

     delete from OKC_K_ITEMS where DNZ_CHR_ID = p_chr_id;
--
      delete from OKC_PRICE_ATT_VALUES  WHERE chr_id = p_chr_id or cle_id in (select id from okc_k_lines_b where dnz_chr_id=p_chr_id);
--

      delete from OKC_PH_LINE_BREAKS  WHERE cle_id IN
                                    (SELECT id
                                     FROM okc_k_lines_b
                                     WHERE dnz_chr_id = p_chr_id);
                                     --price hold line breaks are for a PRICE HOLD sub-line


     delete from OKC_K_LINES_TL
     WHERE id in (select id from OKC_K_LINES_B
	 		WHERE dnz_chr_id= p_chr_id);

     delete from OKC_K_LINES_B where DNZ_CHR_ID = p_chr_id;

     delete from OKC_K_PARTY_ROLES_TL
     WHERE id in (select id from OKC_K_PARTY_ROLES_B
	 		WHERE dnz_chr_id= p_chr_id);

     delete from OKC_K_PARTY_ROLES_B where DNZ_CHR_ID = p_chr_id;

     delete from OKC_K_PROCESSES where CHR_ID = p_chr_id;

     delete from OKC_OUTCOME_ARGUMENTS where DNZ_CHR_ID = p_chr_id;

     delete from OKC_OUTCOMES_TL
     WHERE id in (select id from OKC_OUTCOMES_B
	 		WHERE dnz_chr_id= p_chr_id);

     delete from OKC_OUTCOMES_B where DNZ_CHR_ID = p_chr_id;

     delete from OKC_REACT_INTERVALS where DNZ_CHR_ID = p_chr_id;

     delete from OKC_RG_PARTY_ROLES where DNZ_CHR_ID = p_chr_id;

     delete from OKC_RULE_GROUPS_TL
     WHERE id in (select id from OKC_RULE_GROUPS_B
	 		WHERE dnz_chr_id= p_chr_id);

     delete from OKC_RULE_GROUPS_B where DNZ_CHR_ID = p_chr_id;
--Bug 3055393
/*
     delete from OKC_RULES_TL
     WHERE id in (select id from OKC_RULES_B
	 		WHERE dnz_chr_id= p_chr_id);

     delete from OKC_RULES_B where DNZ_CHR_ID = p_chr_id;
*/
--Bug 3122962
/*
     delete from OKC_TIMEVALUES_TL
     WHERE id in (select id from OKC_TIMEVALUES_B
	 		WHERE dnz_chr_id= p_chr_id);
*/
--Bug 3122962
     delete from OKC_TIMEVALUES where DNZ_CHR_ID = p_chr_id;

     delete from OKC_PRICE_ADJUSTMENTS
         WHERE chr_id = p_chr_id;

     delete from OKC_PRICE_ADJ_ASSOCS
         WHERE pat_id_from in ( select pat_id
                           from OKC_PRICE_ADJUSTMENTS
                           where chr_id = p_chr_id);

     delete from OKC_PRICE_ADJ_ATTRIBS
         WHERE pat_id in ( select pat_id
                           from OKC_PRICE_ADJUSTMENTS
                           where chr_id = p_chr_id);

-- Incorrect location for this delete statement below
-- delete from OKC_PRICE_ATT_VALUES  WHERE chr_id = p_chr_id or cle_id in (select id from okc_k_lines_b where dnz_chr_id=p_chr_id);
--


      delete from OKC_K_SALES_CREDITS  WHERE dnz_chr_id = p_chr_id;



--Restore contract header

    l_return_status:=OKC_CHR_PVT.Restore_Version(l_chr_id,l_minus_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --Restore contract lines

    l_return_status:=OKC_CLE_PVT.Restore_Version(l_chr_id,l_minus_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --Restore  contract items
    l_return_status:=OKC_CIM_PVT.Restore_Version(l_chr_id,l_minus_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --Restore  contract party roles
    l_return_status:=OKC_CPL_PVT.Restore_Version(l_chr_id,l_minus_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --Restore  RuleGroup party roles
    l_return_status:=OKC_RMP_PVT.Restore_Version(l_chr_id,l_minus_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --Restore  Rule Groups
    l_return_status:=OKC_RGP_PVT.Restore_Version(l_chr_id,l_minus_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --Restore  Rules
    l_return_status:=OKC_RUL_PVT.Restore_Version(l_chr_id,l_minus_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --Restore  Contacts
    l_return_status:=OKC_CTC_PVT.Restore_Version(l_chr_id,l_minus_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --Restore  cover times
    l_return_status:=OKC_CTI_PVT.Restore_Version(l_chr_id,l_minus_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --Restore  contract accesses
    l_return_status:=OKC_CAC_PVT.Restore_Version(l_chr_id,l_minus_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --Restore  outcome arguments
    l_return_status:=OKC_OAT_PVT.Restore_Version(l_chr_id,l_minus_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --Restore  outcomes
    l_return_status:=OKC_OCE_PVT.Restore_Version(l_chr_id,l_minus_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --Restore  react intervals
    l_return_status:=OKC_RIL_PVT.Restore_Version(l_chr_id,l_minus_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    --Restore  timevalues
    l_return_status:=OKC_TAV_PVT.Restore_Version(l_chr_id,l_minus_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --Restore  contract processes
    l_return_status:=OKC_CPS_PVT.Restore_Version(l_chr_id,l_minus_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- condition headers
    l_return_status:=OKC_CNH_PVT.Restore_Version(l_chr_id,l_minus_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    --Restore  condition lines
    l_return_status:=OKC_CNL_PVT.Restore_Version(l_chr_id,l_minus_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --Restore  function_expr_params
    l_return_status:=OKC_FEP_PVT.Restore_Version(l_chr_id,l_minus_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --Restore  governances
    l_return_status:=OKC_GVE_PVT.Restore_Version(l_chr_id,l_minus_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

      --Restore _OKC_PRICE_ADJUSTMENTS
    l_return_status:=OKC_PAT_PVT.Restore_Version(l_chr_id,l_minus_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

     --Restore _OKC_PRICE_ADJ_ASSOCS
    l_return_status:=OKC_PAC_PVT.Restore_Version(l_chr_id,l_minus_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

     --Restore _OKC_PRICE_ADJ_ATTRIBS
    l_return_status:=OKC_PAA_PVT.Restore_Version(l_chr_id,l_minus_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --Restore _OKC_PRICE_ATT_VALUES
    l_return_status:=OKC_PAV_PVT.Restore_Version(l_chr_id,l_minus_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    --Restore OKC_K_SALES_CREDITS
    l_return_status:=OKC_SCR_PVT.Restore_Version(l_chr_id,l_minus_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --Restore PRICE HOLD BREAK LINES
    l_return_status:=OKC_PHL_PVT.Restore_Version(l_chr_id,l_minus_version);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

         okc_terms_util_grp.get_contract_document_type_id(
                                         p_api_version    => 1,
                                         p_init_msg_list  => FND_API.G_FALSE,
                                         x_return_status  => l_return_status,
                                         x_msg_data       => l_msg_data,
                                         x_msg_count      => l_msg_count,
                                         p_chr_id         => l_chr_id,
                                         x_doc_id         => l_doc_id,
                                         x_doc_type       => l_doc_type);
        --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         	 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

OKC_TERMS_VERSION_GRP.restore_doc_version(
                      p_api_version   => 1,
                      x_return_status => l_return_status,
                      x_msg_data      => l_msg_data,
                      x_msg_count     => l_msg_count,
                      p_doc_type      => l_doc_type,
                      p_doc_id        => l_doc_id,
                      p_version_number =>l_major_version);

    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     	 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

       oks_contract_hdr_pub.restore_version
                              ( 1 ,
                               'T',
                                l_return_status   ,
                                l_msg_count     ,
                                l_msg_data ,
                                l_chr_id );
      --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     	 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


     delete from okc_k_vers_numbers where CHR_ID = p_chr_id;
     INSERT INTO okc_k_vers_numbers(
	CHR_ID
	,MAJOR_VERSION
	,MINOR_VERSION
	,OBJECT_VERSION_NUMBER
	,CREATED_BY
	,CREATION_DATE
	,LAST_UPDATED_BY
	,LAST_UPDATE_DATE
	,LAST_UPDATE_LOGIN
	) select
	CHR_ID
	,OBJECT_VERSION_NUMBER
	,MINOR_VERSION
	,0
	,CREATED_BY
	,CREATION_DATE
	,FND_GLOBAL.USER_ID
	,sysdate
	,FND_GLOBAL.LOGIN_ID
	from okc_k_vers_numbers_h
	where chr_id = p_chr_id
	and MAJOR_VERSION = -1;
--
  delete_version( p_chr_id 	    => p_chr_id,
			   p_called_from   => 'RESTORE_VERSION',
			   p_major_version => l_major_version,
			   p_minor_version => l_minor_version);
--
--
/*Fix for bug 5175907*/
--Insert History

         open version_csr(p_chr_id);
         fetch version_csr into l_version;
         close version_csr;


             -- To get the new status
          open l_status_csr;
          fetch l_status_csr into l_Contract_new_status;
          close l_status_csr;



             -- To insert record in history tables
  	      l_hstv_rec.chr_id := p_chr_id;
  	      l_hstv_rec.sts_code_from := l_contract_old_status;
          l_hstv_rec.sts_code_to := l_Contract_new_status;
          l_hstv_rec.opn_code := 'STS_CHG';
  	      l_hstv_rec.contract_version := l_version;

              OKC_K_HISTORY_PUB.create_k_history(
         		p_api_version          => p_api_version,
         		p_init_msg_list        => p_init_msg_list,
         		x_return_status        => x_return_status,
         		x_msg_count            => x_msg_count,
         		x_msg_data             => x_msg_data,
         		p_hstv_rec             => l_hstv_rec,
         		x_hstv_rec             => x_hstv_rec);




    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    x_return_status:=l_return_status;

    if (p_commit = OKC_API.G_TRUE) then commit; end if;

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
END restore_version;

-- Procedure to set attachement session variables if they are null
  -- Currently set only set for OKCAUDET and OKSAUDET
  --
  -- If want to get rid of this hard coding, FORM should add
  -- parameters and user should pass attachement_funtion_name
  -- and attachment_funtion_type
  --
  -- added for Bug 3431701
  PROCEDURE Set_Attach_Session_Vars(p_chr_id NUMBER) IS
    l_app_id NUMBER;
    Cursor l_chr_csr Is
	      SELECT application_id
	      FROM okc_k_headers_b
	      WHERE id = p_chr_id;
  BEGIN
    If (p_chr_id IS NOT NULL AND
	   FND_ATTACHMENT_UTIL_PKG.function_name IS NULL
	  )
    Then
      open l_chr_csr;
      fetch l_chr_csr into l_app_id;
      close l_chr_csr;

       -- Added for Bug 2384423
      If (l_app_id = 515) Then
	    FND_ATTACHMENT_UTIL_PKG.function_name := 'OKSAUDET';
	    FND_ATTACHMENT_UTIL_PKG.function_type := 'O';
      Else
	    FND_ATTACHMENT_UTIL_PKG.function_name := 'OKCAUDET';
	    FND_ATTACHMENT_UTIL_PKG.function_type := 'O';
      End If;

    End If;
  END;

END okc_version_pvt;

/
