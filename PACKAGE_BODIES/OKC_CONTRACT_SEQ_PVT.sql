--------------------------------------------------------
--  DDL for Package Body OKC_CONTRACT_SEQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CONTRACT_SEQ_PVT" as
/* $Header: OKCCKSQB.pls 120.2 2006/08/25 06:40:11 npalepu noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  --
  -- Procedure to create Sequence Header details
  --
  PROCEDURE create_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_rec                     IN ksqv_rec_type,
    x_ksqv_rec                     OUT NOCOPY ksqv_rec_type) IS
  BEGIN
    --
    -- Call Simple API
    --
    IF (l_debug = 'Y') THEN
       okc_debug.set_indentation('create_seq_header');
       okc_debug.log('100: Entering create_seq_header', 2);
    END IF;
    okc_ksq_pvt.insert_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ksqv_rec,
	    x_ksqv_rec);
    IF (l_debug = 'Y') THEN
       okc_debug.log('200: Exiting create_seq_header', 2);
       okc_debug.reset_indentation;
    END IF;
  END create_seq_header;

  PROCEDURE create_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_tbl                     IN ksqv_tbl_type,
    x_ksqv_tbl                     OUT NOCOPY ksqv_tbl_type) IS
  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.set_indentation('create_seq_header');
       okc_debug.log('300: Entering create_seq_header', 2);
    END IF;
    okc_ksq_pvt.insert_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ksqv_tbl,
	    x_ksqv_tbl);
    IF (l_debug = 'Y') THEN
       okc_debug.log('400: Exiting create_seq_header', 2);
       okc_debug.reset_indentation;
    END IF;
  END create_seq_header;

  PROCEDURE update_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_rec                     IN ksqv_rec_type,
    x_ksqv_rec                     OUT NOCOPY ksqv_rec_type) IS
  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.set_indentation('update_seq_header');
       okc_debug.log('500: Entering update_seq_header', 2);
    END IF;
    okc_ksq_pvt.update_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ksqv_rec,
	    x_ksqv_rec);
    IF (l_debug = 'Y') THEN
       okc_debug.log('600: Exiting update_seq_header', 2);
       okc_debug.reset_indentation;
    END IF;
  END update_seq_header;

  PROCEDURE update_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_tbl                     IN ksqv_tbl_type,
    x_ksqv_tbl                     OUT NOCOPY ksqv_tbl_type) IS
  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.set_indentation('update_seq_header');
       okc_debug.log('700: Entering update_seq_header', 2);
    END IF;
    okc_ksq_pvt.update_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ksqv_tbl,
	    x_ksqv_tbl);
    IF (l_debug = 'Y') THEN
       okc_debug.log('800: Exiting update_seq_header', 2);
       okc_debug.reset_indentation;
    END IF;
  END update_seq_header;

  PROCEDURE delete_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_rec                     IN ksqv_rec_type) IS
  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.set_indentation('delete_seq_header');
       okc_debug.log('900: Entering delete_seq_header', 2);
    END IF;
    okc_ksq_pvt.delete_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ksqv_rec);
    IF (l_debug = 'Y') THEN
       okc_debug.log('1000: Exiting delete_seq_header', 2);
       okc_debug.reset_indentation;
    END IF;
  END delete_seq_header;

  PROCEDURE delete_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_tbl                     IN ksqv_tbl_type) IS
  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.set_indentation('delete_seq_header');
       okc_debug.log('1100: Entering delete_seq_header', 2);
    END IF;
    okc_ksq_pvt.delete_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ksqv_tbl);
    IF (l_debug = 'Y') THEN
       okc_debug.log('1200: Exiting delete_seq_header', 2);
       okc_debug.reset_indentation;
    END IF;
  END delete_seq_header;

  PROCEDURE lock_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_rec                     IN ksqv_rec_type) IS
  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.set_indentation('lock_seq_header');
       okc_debug.log('1300: Entering lock_seq_header', 2);
    END IF;
    okc_ksq_pvt.lock_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ksqv_rec);
    IF (l_debug = 'Y') THEN
       okc_debug.log('1400: Exiting lock_seq_header', 2);
       okc_debug.reset_indentation;
    END IF;
  END lock_seq_header;

  PROCEDURE lock_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_tbl                     IN ksqv_tbl_type) IS
  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.set_indentation('lock_seq_header');
       okc_debug.log('1500: Entering lock_seq_header', 2);
    END IF;
    okc_ksq_pvt.lock_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ksqv_tbl);
    IF (l_debug = 'Y') THEN
       okc_debug.log('1600: Exiting lock_seq_header', 2);
       okc_debug.reset_indentation;
    END IF;
  END lock_seq_header;

  PROCEDURE validate_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_rec                     IN ksqv_rec_type) IS
  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.set_indentation('validate_seq_header');
       okc_debug.log('1700: Entering validate_seq_header', 2);
    END IF;
    okc_ksq_pvt.validate_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ksqv_rec);
    IF (l_debug = 'Y') THEN
       okc_debug.log('1800: Exiting validate_seq_header', 2);
       okc_debug.reset_indentation;
    END IF;
  END validate_seq_header;

  PROCEDURE validate_seq_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_tbl                     IN ksqv_tbl_type) IS
  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.set_indentation('validate_seq_header');
       okc_debug.log('1900: Entering validate_seq_header', 2);
    END IF;
    okc_ksq_pvt.validate_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_ksqv_tbl);
    IF (l_debug = 'Y') THEN
       okc_debug.log('2000: Exiting validate_seq_header', 2);
       okc_debug.reset_indentation;
    END IF;
  END validate_seq_header;

  PROCEDURE create_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_rec                     IN lsqv_rec_type,
    x_lsqv_rec                     OUT NOCOPY lsqv_rec_type) IS
    --
    l_lsqv_rec                     lsqv_rec_type := p_lsqv_rec;
    l_seq                          number;
    l_docseq_name                  fnd_document_sequences.name%TYPE;
    l_doc_sequence_id              fnd_document_sequences.doc_sequence_id%TYPE;
    l_set_of_books_id              okx_organization_defs_v.set_of_books_id%TYPE;
    l_return_status                VARCHAR2(1);
    l_row_notfound                 Boolean;
    --
    -- AOL sequence need not be created if the prefix and the suffix
    -- are already used bu some other detail. Use the same document
    -- sequence id in this case.
    --
    cursor c1(p_line_code okc_k_seq_lines.line_code%TYPE,
              p_prefix okc_k_seq_lines.contract_number_prefix%TYPE,
              p_suffix okc_k_seq_lines.contract_Number_suffix%TYPE) is
    select doc_sequence_id
      from okc_k_seq_lines
     where line_code = p_line_code
       and ((contract_number_prefix = p_prefix)
        or  (contract_number_prefix is null
       and   p_prefix is null))
       and ((contract_number_suffix = p_suffix)
        or  (contract_number_suffix is null
       and   p_suffix is null));
    --
    -- cursor to get the doc_sequence_id, used in the simple api
    --
    cursor c2 is
    select doc_sequence_id
      from fnd_document_sequences
     where name = l_docseq_name;
    --
    -- cursor to get the set of books id
    --
    cursor c3(p_id IN NUMBER) is
    select set_of_books_id
      from okx_organization_defs_v
     where id1= p_id
       and organization_type = 'OPERATING_UNIT'
       and information_type = 'Operating Unit Information';

    --NPALEPU ADDED ON 22-AUG-2006 FOR BUG # 5470760
    l_org_id NUMBER;
    --NPALEPU ADDED ON 25-AUG-2006 FOR BUG # 5488217
    CURSOR ORG_ID_CSR IS
    SELECT ou.organization_id
    FROM hr_operating_units ou
    WHERE mo_global.check_access(ou.organization_id) = 'Y';
    --END NPALEPU

  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.set_indentation('create_seq_lines');
       okc_debug.log('2100: Entering create_seq_lines', 2);
    END IF;
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- First check if the same prefix and suffix is already in use
    Open c1(l_lsqv_rec.line_code,
            l_lsqv_rec.contract_number_prefix,
            l_lsqv_rec.contract_number_suffix);
    Fetch c1 Into l_doc_sequence_id;
    l_row_notfound := c1%NotFound;
    Close c1;

    If l_row_notfound Then
      --
      -- If doc sequence does not exist, do the AOL setup here first
      -- First create the document sequence details.
      -- Populate fnd_document_sequences table
      --
      select okc_k_seq_lines_s1.nextval into l_seq from dual;
      l_docseq_name := Fnd_Profile.Value('OKC_DOC_SEQUENCE_NAME') ||
                       To_Char(l_seq);
      l_return_status := Fnd_Seqnum.Define_Doc_Seq
                              (app_id      => 510,
                               docseq_name => l_docseq_name,
                               docseq_type => 'A',
                               msg_flag    => 'N',
                               init_value  => l_lsqv_rec.start_seq_no,
                               p_startdate => sysdate);
      If l_return_status <> FND_SEQNUM.SEQSUCC Then
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      End If;
      -- Get the document sequence id just generated
      Open c2;
      Fetch c2 Into l_doc_sequence_id;
      Close c2;
    End If;
    --
    -- Next call simple api; however set the document sequence id first.
    --
    l_lsqv_rec.doc_sequence_id := l_doc_sequence_id;
    --
    okc_lsq_pvt.insert_row(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    l_lsqv_rec,
	    x_lsqv_rec);
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
      x_return_status := l_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    End If;
    --
    -- Continue with the AOL setup if not already done.
    --
    If l_row_notfound Then
      --
      -- Now create a document category.
      -- Populate the fnd_doc_sequence_categories table.
      --
      Fnd_Seq_Categories_Pkg.Insert_Cat(
            x_application_id    => 510,
            x_category_code     => l_docseq_name,
            x_category_name     => l_docseq_name,
            x_description       => l_docseq_name,
            x_table_name        => 'OKC_K_HEADERS_B',
            x_last_updated_by   => x_lsqv_rec.last_updated_by,
            x_created_by        => x_lsqv_rec.created_by,
            x_last_update_login => x_lsqv_rec.last_update_login);
      --
      -- Next create an intersection between category and sequence.
      -- Get the set of books for the current Org. To do that we
      -- will have to first set the org itself.
      --

      --npalepu modified the code for bug # 5470760
      /*okc_context.set_okc_org_context;
      Open c3(Sys_Context('OKC_CONTEXT', 'ORG_ID'));
      Fetch c3 Into l_set_of_books_id;
      Close c3; */
      /*If operating_unit_id is not null use it, else if business_group_id is not null use it else use default org_id */
      IF l_lsqv_rec.OPERATING_UNIT_ID IS NOT NULL THEN
        l_org_id := l_lsqv_rec.OPERATING_UNIT_ID;
     ELSIF l_lsqv_rec.BUSINESS_GROUP_ID IS NOT NULL THEN
        l_org_id := l_lsqv_rec.BUSINESS_GROUP_ID;
     --NPALEPU MODIFIED ON 25-AUG-2006 FOR BUG # 5488217
     ELSIF MO_UTILS.GET_DEFAULT_ORG_ID IS NOT NULL THEN
        l_org_id := MO_UTILS.GET_DEFAULT_ORG_ID;
     ELSE
        OPEN ORG_ID_CSR;
        FETCH ORG_ID_CSR INTO l_org_id;
        CLOSE ORG_ID_CSR;
     END IF;

     IF l_org_id IS NOT NULL THEN
        OPEN c3(l_org_id);
        FETCH c3 Into l_set_of_books_id;
        CLOSE c3;
     END IF;
     --END NPALEPU

      --
      -- Populate the fnd_doc_doc_sequence_assignment table.
      --
      l_return_status := Fnd_Seqnum.Assign_Doc_Seq
                              (app_id      => 510,
                               docseq_name => l_docseq_name,
                               cat_code    => l_docseq_name,
                               sob_id      => l_set_of_books_id,
                               met_code    => 'A',
                               p_startdate => x_lsqv_rec.creation_date,
                               p_enddate   => Null);
      If l_return_status <> FND_SEQNUM.SEQSUCC Then
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      End If;
    End If;
    IF (l_debug = 'Y') THEN
       okc_debug.log('2200: Exiting create_seq_lines', 2);
       okc_debug.reset_indentation;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('2300: Exiting create_seq_lines', 2);
         okc_debug.reset_indentation;
      END IF;
      --npalepu added on 25-AUG-2006 for bug # 5488217
      IF ORG_ID_CSR%ISOPEN THEN
        CLOSE ORG_ID_CSR;
      END IF;
      --end npalepu
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      IF (l_debug = 'Y') THEN
         okc_debug.log('2400: Exiting create_seq_lines', 2);
         okc_debug.reset_indentation;
      END IF;
      --npalepu added on 25-AUG-2006 for bug # 5488217
      IF ORG_ID_CSR%ISOPEN THEN
        CLOSE ORG_ID_CSR;
      END IF;
      --end npalepu
  END create_seq_lines;

  PROCEDURE create_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_tbl                     IN lsqv_tbl_type,
    x_lsqv_tbl                     OUT NOCOPY lsqv_tbl_type) IS
    i			           NUMBER := 0;
    l_return_status 		   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.set_indentation('create_seq_lines');
       okc_debug.log('2500: Entering create_seq_lines', 2);
    END IF;
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_lsqv_tbl.COUNT > 0) THEN
      i := p_lsqv_tbl.FIRST;
      LOOP
        create_seq_lines(
	       p_api_version,
	       p_init_msg_list,
	       l_return_status,
	       x_msg_count,
	       x_msg_data,
	       p_lsqv_tbl(i),
               x_lsqv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_lsqv_tbl.LAST);
        i := p_lsqv_tbl.NEXT(i);
      END LOOP;
    END IF;
    IF (l_debug = 'Y') THEN
       okc_debug.log('2600: Exiting create_seq_lines', 2);
       okc_debug.reset_indentation;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('2700: Exiting create_seq_lines', 2);
         okc_debug.reset_indentation;
      END IF;
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      IF (l_debug = 'Y') THEN
         okc_debug.log('2800: Exiting create_seq_lines', 2);
         okc_debug.reset_indentation;
      END IF;
  END create_seq_lines;

  PROCEDURE update_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_rec                     IN lsqv_rec_type,
    x_lsqv_rec                     OUT NOCOPY lsqv_rec_type) IS
  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.set_indentation('update_seq_lines');
       okc_debug.log('2900: Entering update_seq_lines', 2);
    END IF;
    okc_lsq_pvt.update_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lsqv_rec,
	    x_lsqv_rec);
    IF (l_debug = 'Y') THEN
       okc_debug.log('3000: Exiting update_seq_lines', 2);
       okc_debug.reset_indentation;
    END IF;
  END update_seq_lines;

  PROCEDURE update_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_tbl                     IN lsqv_tbl_type,
    x_lsqv_tbl                     OUT NOCOPY lsqv_tbl_type) IS
  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.set_indentation('update_seq_lines');
       okc_debug.log('3100: Entering update_seq_lines', 2);
    END IF;
    okc_lsq_pvt.update_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lsqv_tbl,
	    x_lsqv_tbl);
    IF (l_debug = 'Y') THEN
       okc_debug.log('3200: Exiting update_seq_lines', 2);
       okc_debug.reset_indentation;
    END IF;
  END update_seq_lines;

  PROCEDURE delete_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_rec                     IN lsqv_rec_type) IS
  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.set_indentation('delete_seq_lines');
       okc_debug.log('3300: Entering delete_seq_lines', 2);
    END IF;
    okc_lsq_pvt.delete_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lsqv_rec);
    IF (l_debug = 'Y') THEN
       okc_debug.log('3400: Exiting delete_seq_lines', 2);
       okc_debug.reset_indentation;
    END IF;
  END delete_seq_lines;

  PROCEDURE delete_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_tbl                     IN lsqv_tbl_type) IS
  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.set_indentation('delete_seq_lines');
       okc_debug.log('3500: Entering delete_seq_lines', 2);
    END IF;
    okc_lsq_pvt.delete_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lsqv_tbl);
    IF (l_debug = 'Y') THEN
       okc_debug.log('3600: Exiting delete_seq_lines', 2);
       okc_debug.reset_indentation;
    END IF;
  END delete_seq_lines;

  PROCEDURE lock_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_rec                     IN lsqv_rec_type) IS
  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.set_indentation('lock_seq_lines');
       okc_debug.log('3700: Entering lock_seq_lines', 2);
    END IF;
    okc_lsq_pvt.lock_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lsqv_rec);
    IF (l_debug = 'Y') THEN
       okc_debug.log('3800: Exiting lock_seq_lines', 2);
       okc_debug.reset_indentation;
    END IF;
  END lock_seq_lines;

  PROCEDURE lock_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_tbl                     IN lsqv_tbl_type) IS
  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.set_indentation('lock_seq_lines');
       okc_debug.log('3900: Entering lock_seq_lines', 2);
    END IF;
    okc_lsq_pvt.lock_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lsqv_tbl);
    IF (l_debug = 'Y') THEN
       okc_debug.log('4000: Exiting lock_seq_lines', 2);
       okc_debug.reset_indentation;
    END IF;
  END lock_seq_lines;

  PROCEDURE validate_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_rec                     IN lsqv_rec_type) IS
  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.set_indentation('validate_seq_lines');
       okc_debug.log('4100: Entering validate_seq_lines', 2);
    END IF;
    okc_lsq_pvt.validate_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lsqv_rec);
    IF (l_debug = 'Y') THEN
       okc_debug.log('4200: Exiting validate_seq_lines', 2);
       okc_debug.reset_indentation;
    END IF;
  END validate_seq_lines;

  PROCEDURE validate_seq_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_tbl                     IN lsqv_tbl_type) IS
  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.set_indentation('validate_seq_lines');
       okc_debug.log('4300: Entering validate_seq_lines', 2);
    END IF;
    okc_lsq_pvt.validate_row(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_lsqv_tbl);
    IF (l_debug = 'Y') THEN
       okc_debug.log('4400: Exiting validate_seq_lines', 2);
       okc_debug.reset_indentation;
    END IF;
  END validate_seq_lines;

  --
  -- Complex API to check whether or not the contract number
  -- can be generated
  --
  PROCEDURE Is_K_Autogenerated(
    p_scs_code Varchar2,
    x_return_status OUT NOCOPY Varchar2) IS
  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.set_indentation('Is_K_Autogenerated');
       okc_debug.log('4500: Entering Is_K_Autogenerated', 2);
    END IF;
    --
    -- Call Simple API
    --
    okc_ksq_pvt.Is_K_Autogenerated(
            p_scs_code,
            x_return_status);
    IF (l_debug = 'Y') THEN
       okc_debug.log('4600: Exiting Is_K_Autogenerated', 2);
       okc_debug.reset_indentation;
    END IF;
  END Is_K_Autogenerated;

  --
  -- Complex API to Get the Contract Number
  --
  PROCEDURE Get_K_Number(
    p_scs_code                     IN VARCHAR2,
    p_contract_number_modifier     IN VARCHAR2,
    x_contract_number              OUT NOCOPY VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2) IS
  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.set_indentation('Get_K_Number');
       okc_debug.log('4700: Entering Get_K_Number', 2);
    END IF;
    --
    -- Call Simple API
    --
    okc_ksq_pvt.Get_K_Number(
            p_scs_code,
            p_contract_number_modifier,
            x_contract_number,
            x_return_status);
    IF (l_debug = 'Y') THEN
       okc_debug.log('4800: Exiting Get_K_Number', 2);
       okc_debug.reset_indentation;
    END IF;
  END Get_K_Number;

END OKC_CONTRACT_SEQ_PVT;

/
