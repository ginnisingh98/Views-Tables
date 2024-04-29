--------------------------------------------------------
--  DDL for Package Body OKL_RULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RULE_PUB" AS
/* $Header: OKLPRULB.pls 120.5 2006/12/18 12:49:27 nikshah noship $ */

G_GEN_COMMENTS VARCHAR2(1) := 'T';
subtype okc_rulv_rec_type is okc_rule_pub.rulv_rec_type;
TYPE okc_rulv_tbl_type    IS TABLE OF okc_rulv_rec_type INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- FUNCTION migrate_rulv out
  ---------------------------------------------------------------------------
  FUNCTION migrate_rulv_out
           (p_rulv_rec IN okc_rulv_rec_type) return rulv_rec_type IS
           l_rulv_rec rulv_rec_type;
  BEGIN
    l_rulv_rec.id                    := p_rulv_rec.id;
    l_rulv_rec.object_version_number := p_rulv_rec.object_version_number;
    l_rulv_rec.created_by            := p_rulv_rec.created_by;
    l_rulv_rec.creation_date         := p_rulv_rec.creation_date;
    l_rulv_rec.last_updated_by       := p_rulv_rec.last_updated_by;
    l_rulv_rec.last_update_date      := p_rulv_rec.last_update_date;
    l_rulv_rec.last_update_login     := p_rulv_rec.last_update_login;
    l_rulv_rec.object1_id1           := p_rulv_rec.object1_id1;
    l_rulv_rec.object2_id1           := p_rulv_rec.object2_id1;
    l_rulv_rec.object3_id1           := p_rulv_rec.object3_id1;
    l_rulv_rec.object1_id2           := p_rulv_rec.object1_id2;
    l_rulv_rec.object2_id2           := p_rulv_rec.object2_id2;
    l_rulv_rec.object3_id2           := p_rulv_rec.object3_id2;
    l_rulv_rec.jtot_object1_code     := p_rulv_rec.jtot_object1_code;
    l_rulv_rec.jtot_object2_code     := p_rulv_rec.jtot_object2_code;
    l_rulv_rec.jtot_object3_code     := p_rulv_rec.jtot_object3_code;
    l_rulv_rec.sfwt_flag             := p_rulv_rec.sfwt_flag;
    l_rulv_rec.rgp_id                := p_rulv_rec.rgp_id;
    l_rulv_rec.dnz_chr_id            := p_rulv_rec.dnz_chr_id;
    l_rulv_rec.priority              := p_rulv_rec.priority;
    l_rulv_rec.std_template_yn       := p_rulv_rec.std_template_yn;
    l_rulv_rec.warn_yn               := p_rulv_rec.warn_yn;
    l_rulv_rec.comments              := p_rulv_rec.comments;
    l_rulv_rec.attribute_category    := p_rulv_rec.attribute_category;
    l_rulv_rec.attribute1            := p_rulv_rec.attribute1;
    l_rulv_rec.attribute2            := p_rulv_rec.attribute2;
    l_rulv_rec.attribute3            := p_rulv_rec.attribute3;
    l_rulv_rec.attribute4            := p_rulv_rec.attribute4;
    l_rulv_rec.attribute5            := p_rulv_rec.attribute5;
    l_rulv_rec.attribute6            := p_rulv_rec.attribute6;
    l_rulv_rec.attribute7            := p_rulv_rec.attribute7;
    l_rulv_rec.attribute8            := p_rulv_rec.attribute8;
    l_rulv_rec.attribute9            := p_rulv_rec.attribute9;
    l_rulv_rec.attribute10           := p_rulv_rec.attribute10;
    l_rulv_rec.attribute11           := p_rulv_rec.attribute11;
    l_rulv_rec.attribute12           := p_rulv_rec.attribute12;
    l_rulv_rec.attribute13           := p_rulv_rec.attribute13;
    l_rulv_rec.attribute14           := p_rulv_rec.attribute14;
    l_rulv_rec.attribute15           := p_rulv_rec.attribute15;
    --l_rulv_rec.text                  := p_rulv_rec2.text;
    l_rulv_rec.rule_information_category := p_rulv_rec.rule_information_category;
    l_rulv_rec.rule_information1         := p_rulv_rec.rule_information1;
    l_rulv_rec.rule_information2         := p_rulv_rec.rule_information2;
    l_rulv_rec.rule_information3         := p_rulv_rec.rule_information3;
    l_rulv_rec.rule_information4         := p_rulv_rec.rule_information4;
    l_rulv_rec.rule_information5         := p_rulv_rec.rule_information5;
    l_rulv_rec.rule_information6         := p_rulv_rec.rule_information6;
    l_rulv_rec.rule_information7         := p_rulv_rec.rule_information7;
    l_rulv_rec.rule_information8         := p_rulv_rec.rule_information8;
    l_rulv_rec.rule_information9         := p_rulv_rec.rule_information9;
    l_rulv_rec.rule_information10        := p_rulv_rec.rule_information10;
    l_rulv_rec.rule_information11        := p_rulv_rec.rule_information11;
    l_rulv_rec.rule_information12        := p_rulv_rec.rule_information12;
    l_rulv_rec.rule_information13        := p_rulv_rec.rule_information13;
    l_rulv_rec.rule_information14        := p_rulv_rec.rule_information14;
    l_rulv_rec.rule_information15        := p_rulv_rec.rule_information15;
    l_rulv_rec.template_yn               := NVL(p_rulv_rec.template_yn,'N');
    l_rulv_rec.ans_set_jtot_object_code  := NVL(p_rulv_rec.ans_set_jtot_object_code,'');
    l_rulv_rec.ans_set_jtot_object_id1       := NVL(p_rulv_rec.ans_set_jtot_object_id1,'');
    l_rulv_rec.ans_set_jtot_object_id2       := NVL(p_rulv_rec.ans_set_jtot_object_id2,'');
    l_rulv_rec.display_sequence          := NVL(p_rulv_rec.display_sequence,'');

    RETURN (l_rulv_rec);
  END migrate_rulv_out;
  ---------------------------------------------------------------------------
  -- FUNCTION migrate_rulv
  ---------------------------------------------------------------------------
  FUNCTION migrate_rulv (
    p_rulv_rec1 IN rulv_rec_type,
    p_rulv_rec2 IN rulv_rec_type
  ) RETURN okc_rulv_rec_type IS
    l_rulv_rec okc_rulv_rec_type;
  BEGIN
    l_rulv_rec.id                    := p_rulv_rec1.id;
    l_rulv_rec.object_version_number := p_rulv_rec1.object_version_number;
    l_rulv_rec.created_by            := p_rulv_rec1.created_by;
    l_rulv_rec.creation_date         := p_rulv_rec1.creation_date;
    l_rulv_rec.last_updated_by       := p_rulv_rec1.last_updated_by;
    l_rulv_rec.last_update_date      := p_rulv_rec1.last_update_date;
    l_rulv_rec.last_update_login     := p_rulv_rec1.last_update_login;
    l_rulv_rec.object1_id1           := p_rulv_rec2.object1_id1;
    l_rulv_rec.object2_id1           := p_rulv_rec2.object2_id1;
    l_rulv_rec.object3_id1           := p_rulv_rec2.object3_id1;
    l_rulv_rec.object1_id2           := p_rulv_rec2.object1_id2;
    l_rulv_rec.object2_id2           := p_rulv_rec2.object2_id2;
    l_rulv_rec.object3_id2           := p_rulv_rec2.object3_id2;
    l_rulv_rec.jtot_object1_code     := p_rulv_rec2.jtot_object1_code;
    l_rulv_rec.jtot_object2_code     := p_rulv_rec2.jtot_object2_code;
    l_rulv_rec.jtot_object3_code     := p_rulv_rec2.jtot_object3_code;
    l_rulv_rec.sfwt_flag             := p_rulv_rec2.sfwt_flag;
    l_rulv_rec.rgp_id                := p_rulv_rec2.rgp_id;
    l_rulv_rec.dnz_chr_id            := p_rulv_rec2.dnz_chr_id;
    l_rulv_rec.priority              := p_rulv_rec2.priority;
    l_rulv_rec.std_template_yn       := p_rulv_rec2.std_template_yn;
    l_rulv_rec.warn_yn               := p_rulv_rec2.warn_yn;
    l_rulv_rec.comments              := p_rulv_rec2.comments;
    l_rulv_rec.attribute_category    := p_rulv_rec2.attribute_category;
    l_rulv_rec.attribute1            := p_rulv_rec2.attribute1;
    l_rulv_rec.attribute2            := p_rulv_rec2.attribute2;
    l_rulv_rec.attribute3            := p_rulv_rec2.attribute3;
    l_rulv_rec.attribute4            := p_rulv_rec2.attribute4;
    l_rulv_rec.attribute5            := p_rulv_rec2.attribute5;
    l_rulv_rec.attribute6            := p_rulv_rec2.attribute6;
    l_rulv_rec.attribute7            := p_rulv_rec2.attribute7;
    l_rulv_rec.attribute8            := p_rulv_rec2.attribute8;
    l_rulv_rec.attribute9            := p_rulv_rec2.attribute9;
    l_rulv_rec.attribute10           := p_rulv_rec2.attribute10;
    l_rulv_rec.attribute11           := p_rulv_rec2.attribute11;
    l_rulv_rec.attribute12           := p_rulv_rec2.attribute12;
    l_rulv_rec.attribute13           := p_rulv_rec2.attribute13;
    l_rulv_rec.attribute14           := p_rulv_rec2.attribute14;
    l_rulv_rec.attribute15           := p_rulv_rec2.attribute15;
    --l_rulv_rec.text                  := p_rulv_rec2.text;
    l_rulv_rec.rule_information_category := p_rulv_rec2.rule_information_category;
    l_rulv_rec.rule_information1         := p_rulv_rec2.rule_information1;
    l_rulv_rec.rule_information2         := p_rulv_rec2.rule_information2;
    l_rulv_rec.rule_information3         := p_rulv_rec2.rule_information3;
    l_rulv_rec.rule_information4         := p_rulv_rec2.rule_information4;
    l_rulv_rec.rule_information5         := p_rulv_rec2.rule_information5;
    l_rulv_rec.rule_information6         := p_rulv_rec2.rule_information6;
    l_rulv_rec.rule_information7         := p_rulv_rec2.rule_information7;
    l_rulv_rec.rule_information8         := p_rulv_rec2.rule_information8;
    l_rulv_rec.rule_information9         := p_rulv_rec2.rule_information9;
    l_rulv_rec.rule_information10        := p_rulv_rec2.rule_information10;
    l_rulv_rec.rule_information11        := p_rulv_rec2.rule_information11;
    l_rulv_rec.rule_information12        := p_rulv_rec2.rule_information12;
    l_rulv_rec.rule_information13        := p_rulv_rec2.rule_information13;
    l_rulv_rec.rule_information14        := p_rulv_rec2.rule_information14;
    l_rulv_rec.rule_information15        := p_rulv_rec2.rule_information15;
    l_rulv_rec.template_yn               := NVL(p_rulv_rec2.template_yn,'N');
    l_rulv_rec.ans_set_jtot_object_code  := NVL(p_rulv_rec2.ans_set_jtot_object_code,'');
    l_rulv_rec.ans_set_jtot_object_id1       := NVL(p_rulv_rec2.ans_set_jtot_object_id1,'');
    l_rulv_rec.ans_set_jtot_object_id2       := NVL(p_rulv_rec2.ans_set_jtot_object_id2,'');
    l_rulv_rec.display_sequence          := NVL(p_rulv_rec2.display_sequence,'');

    RETURN (l_rulv_rec);
  END migrate_rulv;

  --------------------------------------
  -- PROCEDURE create_rule
  --------------------------------------
  PROCEDURE create_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN  rulv_rec_type,
    x_rulv_rec                     OUT NOCOPY rulv_rec_type,
    p_euro_conv_yn                 IN VARCHAR2) IS

    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_rule';
    l_rulv_rec                     rulv_rec_type := p_rulv_rec;
    l_rulv_rec_okc                 okc_rulv_rec_type;
    l_rulv_rec_okc_out             okc_rulv_rec_type;
    l_clob clob;

    -- Start 14-Sep-2005 Manu
    CURSOR lc_category_csr (p_chr_id IN OKC_K_HEADERS_V.ID%TYPE) IS
    SELECT scs_code
    FROM OKC_K_HEADERS_V
    WHERE id = p_chr_id;
    l_scs_code                     OKC_K_HEADERS_V.SCS_CODE%TYPE;
    -- End 14-Sep-2005 Manu
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    g_rulv_rec := l_rulv_rec;
/************************************************************
    g_rulv_rec := p_rulv_rec;
    IF (DBMS_LOB.istemporary(p_rulv_rec.TEXT) = 1) THEN
      DBMS_LOB.CREATETEMPORARY(g_rulv_rec.TEXT,FALSE,DBMS_LOB.CALL);
      l_clob := p_rulv_rec.TEXT;
      DBMS_LOB.OPEN(l_clob, DBMS_LOB.LOB_READONLY);
      DBMS_LOB.OPEN(g_rulv_rec.TEXT, DBMS_LOB.LOB_READWRITE);
      DBMS_LOB.COPY(dest_lob => g_rulv_rec.TEXT,
                    src_lob => l_clob,
                    amount => dbms_lob.getlength(l_clob));
      DBMS_LOB.CLOSE(g_rulv_rec.TEXT);
      DBMS_LOB.CLOSE(l_clob);
      DBMS_LOB.freetemporary(l_clob);
    END IF;
************************************************************/
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --Bug 5697488 start by nikshah
    IF (g_rulv_rec.rule_information_category = 'LABACC') THEN
        g_rulv_rec.rule_information15 := '12.0';
    END IF;
    --Bug 5697488 end by nikshah

    l_rulv_rec_okc := migrate_rulv(l_rulv_rec, g_rulv_rec);

    OKC_RULE_PUB.create_rule(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rulv_rec      => l_rulv_rec_okc,
      x_rulv_rec      => l_rulv_rec_okc_out,
      p_euro_conv_yn  => p_euro_conv_yn);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     x_rulv_rec := migrate_rulv_out(l_rulv_rec_okc_out);

     g_rulv_rec := x_rulv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     --code to flip status to 'INCOMPLETE' for lease contract if this is an edit point
     -- edit points for lease contract are any modifications between statuses
     -- 'PASSED' and 'APPROVED'
     If (x_rulv_rec.dnz_chr_id is not NULL) AND (x_rulv_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) Then

          okl_contract_status_pub.cascade_lease_status_edit
            (p_api_version     => p_api_version,
             p_init_msg_list   => p_init_msg_list,
             x_return_status   => x_return_status,
             x_msg_count       => x_msg_count,
             x_msg_data        => x_msg_data,
             p_chr_id          => x_rulv_rec.dnz_chr_id);

        If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	        raise OKC_API.G_EXCEPTION_ERROR;
        End If;

     End If;

     -- Start 14-Sep-2005 Manu
     --Flip status of the PROGRAM agreement from 'PASSED' to  'INCOMPLETE'
     If (x_rulv_rec.dnz_chr_id is not NULL) AND (x_rulv_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) Then
       OPEN lc_category_csr (p_chr_id  => x_rulv_rec.dnz_chr_id);
       FETCH lc_category_csr INTO l_scs_code;
       CLOSE lc_category_csr;
       IF (l_scs_code = 'PROGRAM' ) THEN
          OKL_VENDOR_PROGRAM_PVT.passed_to_incomplete(
                          p_api_version    => p_api_version
                         ,p_init_msg_list  => p_init_msg_list
                         ,x_return_status  => x_return_status
                         ,x_msg_count      => x_msg_count
                         ,x_msg_data       => x_msg_data
                         ,p_program_id     => x_rulv_rec.dnz_chr_id
                        );

          If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	        raise OKC_API.G_EXCEPTION_ERROR;
          End If;
        END IF;
     End If;
     -- End 14-Sep-2005 Manu

     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END create_rule;

  --------------------------------------
  -- PROCEDURE create_rule
  --------------------------------------
  PROCEDURE create_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN  rulv_rec_type,
    x_rulv_rec                     OUT NOCOPY rulv_rec_type)
  IS
  BEGIN

    create_rule(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rulv_rec      => p_rulv_rec,
      x_rulv_rec      => x_rulv_rec,
      p_euro_conv_yn  => 'N');

  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END create_rule;

  --------------------------------------
  -- PROCEDURE create_rule
  --------------------------------------
  PROCEDURE create_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN  rulv_tbl_type,
    x_rulv_tbl                     OUT NOCOPY rulv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rulv_tbl.COUNT > 0 THEN
      i := p_rulv_tbl.FIRST;
      LOOP
        create_rule(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rulv_rec      => p_rulv_tbl(i),
          x_rulv_rec      => x_rulv_tbl(i),
          p_euro_conv_yn  => 'N');
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rulv_tbl.LAST);
        i := p_rulv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END create_rule;

  --------------------------------------
  -- PROCEDURE create_rule
  --------------------------------------
  PROCEDURE create_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN  rulv_tbl_type,
    x_rulv_tbl                     OUT NOCOPY rulv_tbl_type,
    p_euro_conv_yn                 IN VARCHAR2)
  IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rulv_tbl.COUNT > 0 THEN
      i := p_rulv_tbl.FIRST;
      LOOP
        create_rule(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rulv_rec      => p_rulv_tbl(i),
          x_rulv_rec      => x_rulv_tbl(i),
          p_euro_conv_yn  => p_euro_conv_yn);
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rulv_tbl.LAST);
        i := p_rulv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END create_rule;

  --Bug# 2981308 : overloaded procedure with p_edit_mode
  --------------------------------------
  -- PROCEDURE update_rule
  --------------------------------------
  PROCEDURE update_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN  rulv_rec_type,
    p_edit_mode                    IN  VARCHAR2,
    x_rulv_rec                     OUT NOCOPY rulv_rec_type) IS

    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_rule';
    l_rulv_rec                     rulv_rec_type := p_rulv_rec;
    l_rulv_rec_okc                 okc_rulv_rec_type;
    l_rulv_rec_okc_out             okc_rulv_rec_type;
    l_clob clob;

    -- Start 14-Sep-2005 Manu
    CURSOR lc_category_csr (p_chr_id IN OKC_K_HEADERS_V.ID%TYPE) IS
    SELECT scs_code
    FROM OKC_K_HEADERS_V
    WHERE id = p_chr_id;
    l_scs_code                     OKC_K_HEADERS_V.SCS_CODE%TYPE;
    -- End 14-Sep-2005 Manu
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    g_rulv_rec := p_rulv_rec;
/*******************************************************************
    IF (DBMS_LOB.istemporary(p_rulv_rec.TEXT) = 1) THEN
      DBMS_LOB.CREATETEMPORARY(g_rulv_rec.TEXT,FALSE,DBMS_LOB.CALL);
      l_clob := p_rulv_rec.TEXT;
      DBMS_LOB.OPEN(l_clob, DBMS_LOB.LOB_READONLY);
      DBMS_LOB.OPEN(g_rulv_rec.TEXT, DBMS_LOB.LOB_READWRITE);
      DBMS_LOB.COPY(dest_lob => g_rulv_rec.TEXT,
                    src_lob => l_clob,
                    amount => dbms_lob.getlength(l_clob));
      DBMS_LOB.CLOSE(g_rulv_rec.TEXT);
      DBMS_LOB.CLOSE(l_clob);
      DBMS_LOB.freetemporary(l_clob);
    END IF;
*********************************************************************/
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --Bug 5697488 start by nikshah
    IF (g_rulv_rec.rule_information_category = 'LABACC') THEN
        g_rulv_rec.rule_information15 := '12.0';
    END IF;
    --Bug 5697488 end by nikshah
    l_rulv_rec_okc := migrate_rulv(l_rulv_rec, g_rulv_rec);

    OKC_RULE_PUB.update_rule(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rulv_rec      => l_rulv_rec_okc,
      x_rulv_rec      => l_rulv_rec_okc_out);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     x_rulv_rec := migrate_rulv_out(l_rulv_rec_okc_out);

     g_rulv_rec := x_rulv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     --Bug# 3388812 : cascade status based on p_edit_mode parameter
     If p_edit_mode = 'Y' then
         --code to flip status to 'INCOMPLETE' for lease contract if this is an edit point
         -- edit points for lease contract are any modifications between statuses
         -- 'PASSED' and 'APPROVED'
         If (x_rulv_rec.dnz_chr_id is not NULL) AND (x_rulv_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) Then

             okl_contract_status_pub.cascade_lease_status_edit
               (p_api_version     => p_api_version,
                p_init_msg_list   => p_init_msg_list,
                x_return_status   => x_return_status,
                x_msg_count       => x_msg_count,
                x_msg_data        => x_msg_data,
                p_chr_id          => x_rulv_rec.dnz_chr_id);

            If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	        raise OKC_API.G_EXCEPTION_ERROR;
            End If;

         End If;

       -- Start 14-Sep-2005 Manu
       --Flip status of the PROGRAM agreement from 'PASSED' to  'INCOMPLETE'
       If (x_rulv_rec.dnz_chr_id is not NULL) AND (x_rulv_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) Then
         OPEN lc_category_csr (p_chr_id  => x_rulv_rec.dnz_chr_id);
         FETCH lc_category_csr INTO l_scs_code;
         CLOSE lc_category_csr;
         IF (l_scs_code = 'PROGRAM' ) THEN
            OKL_VENDOR_PROGRAM_PVT.passed_to_incomplete(
                          p_api_version    => p_api_version
                         ,p_init_msg_list  => p_init_msg_list
                         ,x_return_status  => x_return_status
                         ,x_msg_count      => x_msg_count
                         ,x_msg_data       => x_msg_data
                         ,p_program_id     => x_rulv_rec.dnz_chr_id
                        );

            If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	        raise OKC_API.G_EXCEPTION_ERROR;
            End If;
          END IF;
       End If;
     -- End 14-Sep-2005 Manu
     End If;

     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END update_rule;

 --------------------------------------
  -- PROCEDURE update_rule
  --------------------------------------
  PROCEDURE update_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN  rulv_rec_type,
    x_rulv_rec                     OUT NOCOPY rulv_rec_type) IS

    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_rule';
    l_rulv_rec                     rulv_rec_type := p_rulv_rec;
    l_rulv_rec_okc                 okc_rulv_rec_type;
    l_rulv_rec_okc_out             okc_rulv_rec_type;
    l_clob clob;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

     update_rule(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rulv_rec      => l_rulv_rec,
      p_edit_mode     => 'Y',
      x_rulv_rec      => x_rulv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;


     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END update_rule;


  --Bug# 3388812 : overloaded procedure with p_edit_mode parameter
  --------------------------------------
  -- PROCEDURE update_rule
  --------------------------------------
  PROCEDURE update_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN  rulv_tbl_type,
    p_edit_mode                    IN  VARCHAR2,
    x_rulv_tbl                     OUT NOCOPY rulv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rulv_tbl.COUNT > 0 THEN
      i := p_rulv_tbl.FIRST;
      LOOP
        update_rule(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rulv_rec      => p_rulv_tbl(i),
          p_edit_mode     => p_edit_mode,
          x_rulv_rec      => x_rulv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rulv_tbl.LAST);
        i := p_rulv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END update_rule;

  --------------------------------------
  -- PROCEDURE update_rule
  --------------------------------------
  PROCEDURE update_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN  rulv_tbl_type,
    x_rulv_tbl                     OUT NOCOPY rulv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rulv_tbl.COUNT > 0 THEN
      i := p_rulv_tbl.FIRST;
      LOOP
        update_rule(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rulv_rec      => p_rulv_tbl(i),
          x_rulv_rec      => x_rulv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rulv_tbl.LAST);
        i := p_rulv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
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
  END update_rule;

  --------------------------------------
  -- PROCEDURE validate_rule
  --------------------------------------
  PROCEDURE validate_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN  rulv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_rule';
    l_rulv_rec                     rulv_rec_type := p_rulv_rec;
    l_rulv_rec_okc                 okc_rulv_rec_type;
    l_rulv_rec_okc_out             okc_rulv_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    g_rulv_rec := p_rulv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_rulv_rec_okc := migrate_rulv(l_rulv_rec, g_rulv_rec);

    OKC_RULE_PUB.validate_rule(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rulv_rec      => l_rulv_rec_okc);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     g_rulv_rec := l_rulv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END validate_rule;

  --------------------------------------
  -- PROCEDURE validate_rule
  --------------------------------------
  PROCEDURE validate_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN  rulv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rulv_tbl.COUNT > 0 THEN
      i := p_rulv_tbl.FIRST;
      LOOP
        validate_rule(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rulv_rec      => p_rulv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rulv_tbl.LAST);
        i := p_rulv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_rule;

  --------------------------------------
  -- PROCEDURE delete_rule
  --------------------------------------
  PROCEDURE delete_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN  rulv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_rule';
    l_rulv_rec                     rulv_rec_type := p_rulv_rec;
    l_rulv_rec_okc                 okc_rulv_rec_type;
    l_rulv_rec_okc_out             okc_rulv_rec_type;

    --cursor to find out chr id required to flip status at edit point
    CURSOR chr_id_crs (p_rul_id IN NUMBER) is
    SELECT DNZ_CHR_ID
    FROM   OKC_RULES_B
    WHERE  ID = P_RUL_ID;

    l_dnz_chr_id   OKC_RULES_B.dnz_chr_id%TYPE;

    -- Start 14-Sep-2005 Manu
    CURSOR lc_category_csr (p_chr_id IN OKC_K_HEADERS_V.ID%TYPE) IS
    SELECT scs_code
    FROM OKC_K_HEADERS_V
    WHERE id = p_chr_id;
    l_scs_code                     OKC_K_HEADERS_V.SCS_CODE%TYPE;
    -- End 14-Sep-2005 Manu

  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    g_rulv_rec := p_rulv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

     --code to flip status to 'INCOMPLETE' for lease contract if this is an edit point
     -- edit points for lease contract are any modifications between statuses
     -- 'PASSED' and 'APPROVED'
     If (p_rulv_rec.dnz_chr_id is NULL OR p_rulv_rec.dnz_chr_id = OKL_API.G_MISS_NUM) THEN
         Open chr_id_crs(p_rul_id => p_rulv_rec.id);
         Fetch chr_id_crs into l_dnz_chr_id;
         If chr_id_crs%NOTFOUND THEN
            null;
         End If;
         Close chr_id_crs;
     Else
         l_dnz_chr_id := p_rulv_rec.dnz_chr_id;
     End If;

     If (l_dnz_chr_id is not NULL AND l_dnz_chr_id <> OKL_API.G_MISS_NUM)  Then

          okl_contract_status_pub.cascade_lease_status_edit
            (p_api_version     => p_api_version,
             p_init_msg_list   => p_init_msg_list,
             x_return_status   => x_return_status,
             x_msg_count       => x_msg_count,
             x_msg_data        => x_msg_data,
             p_chr_id          => l_dnz_chr_id);

        If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	        raise OKC_API.G_EXCEPTION_ERROR;
        End If;

     End If;

     -- Start 14-Sep-2005 Manu
     --Flip status of the PROGRAM agreement from 'PASSED' to  'INCOMPLETE'
     If (l_dnz_chr_id is not NULL) AND (l_dnz_chr_id <> OKL_API.G_MISS_NUM) Then
       OPEN lc_category_csr (p_chr_id  => l_dnz_chr_id);
       FETCH lc_category_csr INTO l_scs_code;
       CLOSE lc_category_csr;
       IF (l_scs_code = 'PROGRAM' ) THEN
          OKL_VENDOR_PROGRAM_PVT.passed_to_incomplete(
                          p_api_version    => p_api_version
                         ,p_init_msg_list  => p_init_msg_list
                         ,x_return_status  => x_return_status
                         ,x_msg_count      => x_msg_count
                         ,x_msg_data       => x_msg_data
                         ,p_program_id     => l_dnz_chr_id
                        );

          If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	        raise OKC_API.G_EXCEPTION_ERROR;
          End If;
        END IF;
     End If;
     -- End 14-Sep-2005 Manu

    l_rulv_rec_okc := migrate_rulv(l_rulv_rec, g_rulv_rec);
    OKC_RULE_PUB.delete_rule(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rulv_rec      => l_rulv_rec_okc);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     g_rulv_rec := l_rulv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END delete_rule;

  --------------------------------------
  -- PROCEDURE delete_rule
  --------------------------------------
  PROCEDURE delete_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN  rulv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rulv_tbl.COUNT > 0 THEN
      i := p_rulv_tbl.FIRST;
      LOOP
        delete_rule(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rulv_rec      => p_rulv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rulv_tbl.LAST);
        i := p_rulv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END delete_rule;

  --------------------------------------
  -- PROCEDURE lock_rule
  --------------------------------------
  PROCEDURE lock_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN  rulv_rec_type) IS
    l_rulv_rec                     rulv_rec_type := p_rulv_rec;
    l_rulv_rec_okc                 okc_rulv_rec_type;
    l_rulv_rec_okc_out             okc_rulv_rec_type;

  BEGIN
    g_rulv_rec := l_rulv_rec;
    l_rulv_rec_okc := migrate_rulv(l_rulv_rec, g_rulv_rec);

    OKC_RULE_PUB.lock_rule(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rulv_rec      => l_rulv_rec_okc);
  END lock_rule;

  --------------------------------------
  -- PROCEDURE lock_rule
  --------------------------------------
  PROCEDURE lock_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN  rulv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rulv_tbl.COUNT > 0 THEN
      i := p_rulv_tbl.FIRST;
      LOOP
        lock_rule(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rulv_rec      => p_rulv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rulv_tbl.LAST);
        i := p_rulv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END lock_rule;

  ---------------------------------------------------------------------------
  -- FUNCTION migrate_rgpv
  ---------------------------------------------------------------------------
  FUNCTION migrate_rgpv (
    p_rgpv_rec1 IN rgpv_rec_type,
    p_rgpv_rec2 IN rgpv_rec_type
  ) RETURN rgpv_rec_type IS
    l_rgpv_rec rgpv_rec_type;
  BEGIN
    l_rgpv_rec.id                    := p_rgpv_rec1.id;
    l_rgpv_rec.object_version_number := p_rgpv_rec1.object_version_number;
    l_rgpv_rec.created_by            := p_rgpv_rec1.created_by;
    l_rgpv_rec.creation_date         := p_rgpv_rec1.creation_date;
    l_rgpv_rec.last_updated_by       := p_rgpv_rec1.last_updated_by;
    l_rgpv_rec.last_update_date      := p_rgpv_rec1.last_update_date;
    l_rgpv_rec.last_update_login     := p_rgpv_rec1.last_update_login;
    l_rgpv_rec.rgd_code              := p_rgpv_rec2.rgd_code;
    l_rgpv_rec.sat_code              := p_rgpv_rec2.sat_code;
    l_rgpv_rec.rgp_type              := p_rgpv_rec2.rgp_type;
    l_rgpv_rec.cle_id                := p_rgpv_rec2.cle_id;
    l_rgpv_rec.chr_id                := p_rgpv_rec2.chr_id;
    l_rgpv_rec.dnz_chr_id            := p_rgpv_rec2.dnz_chr_id;
    l_rgpv_rec.parent_rgp_id         := p_rgpv_rec2.parent_rgp_id;
    l_rgpv_rec.sfwt_flag             := p_rgpv_rec2.sfwt_flag;
    l_rgpv_rec.comments              := p_rgpv_rec2.comments;
    l_rgpv_rec.attribute_category    := p_rgpv_rec2.attribute_category;
    l_rgpv_rec.attribute1            := p_rgpv_rec2.attribute1;
    l_rgpv_rec.attribute2            := p_rgpv_rec2.attribute2;
    l_rgpv_rec.attribute3            := p_rgpv_rec2.attribute3;
    l_rgpv_rec.attribute4            := p_rgpv_rec2.attribute4;
    l_rgpv_rec.attribute5            := p_rgpv_rec2.attribute5;
    l_rgpv_rec.attribute6            := p_rgpv_rec2.attribute6;
    l_rgpv_rec.attribute7            := p_rgpv_rec2.attribute7;
    l_rgpv_rec.attribute8            := p_rgpv_rec2.attribute8;
    l_rgpv_rec.attribute9            := p_rgpv_rec2.attribute9;
    l_rgpv_rec.attribute10           := p_rgpv_rec2.attribute10;
    l_rgpv_rec.attribute11           := p_rgpv_rec2.attribute11;
    l_rgpv_rec.attribute12           := p_rgpv_rec2.attribute12;
    l_rgpv_rec.attribute13           := p_rgpv_rec2.attribute13;
    l_rgpv_rec.attribute14           := p_rgpv_rec2.attribute14;
    l_rgpv_rec.attribute15           := p_rgpv_rec2.attribute15;

    RETURN (l_rgpv_rec);
  END migrate_rgpv;

  --------------------------------------
  -- PROCEDURE create_rule_group
  --------------------------------------
  PROCEDURE create_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type,
    x_rgpv_rec                     OUT NOCOPY rgpv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_rule_group';
    l_rgpv_rec                     rgpv_rec_type := p_rgpv_rec;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    g_rgpv_rec := p_rgpv_rec;

    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_rgpv_rec := migrate_rgpv(l_rgpv_rec, g_rgpv_rec);

    okl_okc_migration_pvt.create_rule_group(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rgpv_rec      => l_rgpv_rec,
      x_rgpv_rec      => x_rgpv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     g_rgpv_rec := x_rgpv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END create_rule_group;

  --------------------------------------
  -- PROCEDURE create_rule_group
  --------------------------------------
  PROCEDURE create_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_tbl                     IN  rgpv_tbl_type,
    x_rgpv_tbl                     OUT NOCOPY rgpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rgpv_tbl.COUNT > 0 THEN
      i := p_rgpv_tbl.FIRST;
      LOOP
        create_rule_group(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rgpv_rec      => p_rgpv_tbl(i),
          x_rgpv_rec      => x_rgpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rgpv_tbl.LAST);
        i := p_rgpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END create_rule_group;

  --------------------------------------
  -- PROCEDURE update_rule_group
  --------------------------------------
  PROCEDURE update_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type,
    x_rgpv_rec                     OUT NOCOPY rgpv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_rule_group';
    l_rgpv_rec                     rgpv_rec_type := p_rgpv_rec;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    g_rgpv_rec := p_rgpv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_rgpv_rec := migrate_rgpv(l_rgpv_rec, g_rgpv_rec);

    okl_okc_migration_pvt.update_rule_group(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rgpv_rec      => l_rgpv_rec,
      x_rgpv_rec      => x_rgpv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     g_rgpv_rec := x_rgpv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END update_rule_group;

  --------------------------------------
  -- PROCEDURE update_rule_group
  --------------------------------------
  PROCEDURE update_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_tbl                     IN  rgpv_tbl_type,
    x_rgpv_tbl                     OUT NOCOPY rgpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rgpv_tbl.COUNT > 0 THEN
      i := p_rgpv_tbl.FIRST;
      LOOP
        update_rule_group(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rgpv_rec      => p_rgpv_tbl(i),
          x_rgpv_rec      => x_rgpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rgpv_tbl.LAST);
        i := p_rgpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END update_rule_group;

  --------------------------------------
  -- PROCEDURE delete_rule_group
  --------------------------------------
  PROCEDURE delete_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_rule_group';
    l_rgpv_rec                     rgpv_rec_type := p_rgpv_rec;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    g_rgpv_rec := p_rgpv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    okl_okc_migration_pvt.delete_rule_group(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rgpv_rec      => p_rgpv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     g_rgpv_rec := l_rgpv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END delete_rule_group;

  --------------------------------------
  -- PROCEDURE delete_rule_group
  --------------------------------------
  PROCEDURE delete_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_tbl                     IN  rgpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rgpv_tbl.COUNT > 0 THEN
      i := p_rgpv_tbl.FIRST;
      LOOP
        delete_rule_group(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rgpv_rec      => p_rgpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rgpv_tbl.LAST);
        i := p_rgpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END delete_rule_group;

  --------------------------------------
  -- PROCEDURE lock_rule_group
  --------------------------------------
  PROCEDURE lock_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type) IS
  BEGIN
    okl_okc_migration_pvt.lock_rule_group(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rgpv_rec      => p_rgpv_rec);
  END lock_rule_group;

  --------------------------------------
  -- PROCEDURE lock_rule_group
  --------------------------------------
  PROCEDURE lock_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_tbl                     IN  rgpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rgpv_tbl.COUNT > 0 THEN
      i := p_rgpv_tbl.FIRST;
      LOOP
        lock_rule_group(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rgpv_rec      => p_rgpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rgpv_tbl.LAST);
        i := p_rgpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END lock_rule_group;

  --------------------------------------
  -- PROCEDURE validate_rule_group
  --------------------------------------
  PROCEDURE validate_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_rule_group';
    l_rgpv_rec                     rgpv_rec_type := p_rgpv_rec;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    g_rgpv_rec := p_rgpv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    okl_okc_migration_pvt.validate_rule_group(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rgpv_rec      => p_rgpv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     g_rgpv_rec := l_rgpv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END validate_rule_group;

  --------------------------------------
  -- PROCEDURE validate_rule_group
  --------------------------------------
  PROCEDURE validate_rule_group(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_tbl                     IN  rgpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rgpv_tbl.COUNT > 0 THEN
      i := p_rgpv_tbl.FIRST;
      LOOP
        validate_rule_group(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rgpv_rec      => p_rgpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rgpv_tbl.LAST);
        i := p_rgpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_rule_group;

  ---------------------------------------------------------------------------
  -- FUNCTION migrate_rmpv
  ---------------------------------------------------------------------------
  FUNCTION migrate_rmpv (
    p_rmpv_rec1 IN rmpv_rec_type,
    p_rmpv_rec2 IN rmpv_rec_type
  ) RETURN rmpv_rec_type IS
    l_rmpv_rec rmpv_rec_type;
  BEGIN
--added after similar okc fix
    l_rmpv_rec.id                    := p_rmpv_rec2.id;
--added after similar okc bug fix
    l_rmpv_rec.rgp_id                := p_rmpv_rec2.rgp_id;
    l_rmpv_rec.rrd_id                := p_rmpv_rec2.rrd_id;
    l_rmpv_rec.cpl_id                := p_rmpv_rec2.cpl_id;
    l_rmpv_rec.dnz_chr_id            := p_rmpv_rec2.dnz_chr_id;
    l_rmpv_rec.object_version_number := p_rmpv_rec1.object_version_number;
    l_rmpv_rec.created_by            := p_rmpv_rec1.created_by;
    l_rmpv_rec.creation_date         := p_rmpv_rec1.creation_date;
    l_rmpv_rec.last_updated_by       := p_rmpv_rec1.last_updated_by;
    l_rmpv_rec.last_update_date      := p_rmpv_rec1.last_update_date;
    l_rmpv_rec.last_update_login     := p_rmpv_rec1.last_update_login;

    RETURN (l_rmpv_rec);
  END migrate_rmpv;

  --------------------------------------
  -- PROCEDURE create_rg_mode_pty_role
  --------------------------------------
  PROCEDURE create_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type,
    x_rmpv_rec                     OUT NOCOPY rmpv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_rg_mode_pty_role';
    l_rmpv_rec                     rmpv_rec_type := p_rmpv_rec;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    g_rmpv_rec := p_rmpv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_rmpv_rec := migrate_rmpv(l_rmpv_rec, g_rmpv_rec);

    okl_okc_migration_pvt.create_rg_mode_pty_role(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rmpv_rec      => l_rmpv_rec,
      x_rmpv_rec      => x_rmpv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     g_rmpv_rec := x_rmpv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END create_rg_mode_pty_role;

  --------------------------------------
  -- PROCEDURE create_rg_mode_pty_role
  --------------------------------------
  PROCEDURE create_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_tbl                     IN  rmpv_tbl_type,
    x_rmpv_tbl                     OUT NOCOPY rmpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rmpv_tbl.COUNT > 0 THEN
      i := p_rmpv_tbl.FIRST;
      LOOP
        create_rg_mode_pty_role(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rmpv_rec      => p_rmpv_tbl(i),
          x_rmpv_rec      => x_rmpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rmpv_tbl.LAST);
        i := p_rmpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END create_rg_mode_pty_role;

  --------------------------------------
  -- PROCEDURE update_rg_mode_pty_role
  --------------------------------------
  PROCEDURE update_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type,
    x_rmpv_rec                     OUT NOCOPY rmpv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_rg_mode_pty_role';
    l_rmpv_rec                     rmpv_rec_type := p_rmpv_rec;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    g_rmpv_rec := p_rmpv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_rmpv_rec := migrate_rmpv(l_rmpv_rec, g_rmpv_rec);

    okl_okc_migration_pvt.update_rg_mode_pty_role(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rmpv_rec      => l_rmpv_rec,
      x_rmpv_rec      => x_rmpv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     g_rmpv_rec := x_rmpv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END update_rg_mode_pty_role;

  --------------------------------------
  -- PROCEDURE update_rg_mode_pty_role
  --------------------------------------
  PROCEDURE update_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_tbl                     IN  rmpv_tbl_type,
    x_rmpv_tbl                     OUT NOCOPY rmpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rmpv_tbl.COUNT > 0 THEN
      i := p_rmpv_tbl.FIRST;
      LOOP
        update_rg_mode_pty_role(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rmpv_rec      => p_rmpv_tbl(i),
          x_rmpv_rec      => x_rmpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rmpv_tbl.LAST);
        i := p_rmpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END update_rg_mode_pty_role;

  --------------------------------------
  -- PROCEDURE delete_rg_mode_pty_role
  --------------------------------------
  PROCEDURE delete_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_rg_mode_pty_role';
    l_rmpv_rec                     rmpv_rec_type := p_rmpv_rec;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    g_rmpv_rec := p_rmpv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    okl_okc_migration_pvt.delete_rg_mode_pty_role(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rmpv_rec      => p_rmpv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     g_rmpv_rec := l_rmpv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END delete_rg_mode_pty_role;

  --------------------------------------
  -- PROCEDURE delete_rg_mode_pty_role
  --------------------------------------
  PROCEDURE delete_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_tbl                     IN  rmpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rmpv_tbl.COUNT > 0 THEN
      i := p_rmpv_tbl.FIRST;
      LOOP
        delete_rg_mode_pty_role(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rmpv_rec      => p_rmpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rmpv_tbl.LAST);
        i := p_rmpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END delete_rg_mode_pty_role;

  --------------------------------------
  -- PROCEDURE lock_rg_mode_pty_role
  --------------------------------------
  PROCEDURE lock_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type) IS
  BEGIN
    okl_okc_migration_pvt.lock_rg_mode_pty_role(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rmpv_rec      => p_rmpv_rec);
  END lock_rg_mode_pty_role;

  --------------------------------------
  -- PROCEDURE lock_rg_mode_pty_role
  --------------------------------------
  PROCEDURE lock_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_tbl                     IN  rmpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rmpv_tbl.COUNT > 0 THEN
      i := p_rmpv_tbl.FIRST;
      LOOP
        lock_rg_mode_pty_role(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rmpv_rec      => p_rmpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rmpv_tbl.LAST);
        i := p_rmpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END lock_rg_mode_pty_role;

  --------------------------------------
  -- PROCEDURE validate_rg_mode_pty_role
  --------------------------------------
  PROCEDURE validate_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_rg_mode_pty_role';
    l_rmpv_rec                     rmpv_rec_type := p_rmpv_rec;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    g_rmpv_rec := p_rmpv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    okl_okc_migration_pvt.validate_rg_mode_pty_role(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rmpv_rec      => p_rmpv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     g_rmpv_rec := l_rmpv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END validate_rg_mode_pty_role;

  --------------------------------------
  -- PROCEDURE validate_rg_mode_pty_role
  --------------------------------------
  PROCEDURE validate_rg_mode_pty_role(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_tbl                     IN  rmpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rmpv_tbl.COUNT > 0 THEN
      i := p_rmpv_tbl.FIRST;
      LOOP
        validate_rg_mode_pty_role(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rmpv_rec      => p_rmpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rmpv_tbl.LAST);
        i := p_rmpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_rg_mode_pty_role;
/*
  ---------------------------------------------------------------------------
  -- FUNCTION migrate_ctiv
  ---------------------------------------------------------------------------
  FUNCTION migrate_ctiv (
    p_ctiv_rec1 IN ctiv_rec_type,
    p_ctiv_rec2 IN ctiv_rec_type
  ) RETURN ctiv_rec_type IS
    l_ctiv_rec ctiv_rec_type;
  BEGIN
    l_ctiv_rec.rul_id                := p_ctiv_rec2.rul_id;
    l_ctiv_rec.tve_id                := p_ctiv_rec2.tve_id;
    l_ctiv_rec.dnz_chr_id            := p_ctiv_rec2.dnz_chr_id;
    l_ctiv_rec.object_version_number := p_ctiv_rec1.object_version_number;
    l_ctiv_rec.created_by            := p_ctiv_rec1.created_by;
    l_ctiv_rec.creation_date         := p_ctiv_rec1.creation_date;
    l_ctiv_rec.last_updated_by       := p_ctiv_rec1.last_updated_by;
    l_ctiv_rec.last_update_date      := p_ctiv_rec1.last_update_date;
    l_ctiv_rec.last_update_login     := p_ctiv_rec1.last_update_login;

    RETURN (l_ctiv_rec);
  END migrate_ctiv;

  --------------------------------------
  -- PROCEDURE create_cover_time
  --------------------------------------
  PROCEDURE create_cover_time(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_rec                     IN  ctiv_rec_type,
    x_ctiv_rec                     OUT NOCOPY ctiv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_cover_time';
    l_ctiv_rec                     ctiv_rec_type := p_ctiv_rec;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    g_ctiv_rec := p_ctiv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_ctiv_rec := migrate_ctiv(l_ctiv_rec, g_ctiv_rec);

    OKC_RULE_PUB.create_cover_time(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_ctiv_rec      => l_ctiv_rec,
      x_ctiv_rec      => x_ctiv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     g_ctiv_rec := x_ctiv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END create_cover_time;

  --------------------------------------
  -- PROCEDURE create_cover_time
  --------------------------------------
  PROCEDURE create_cover_time(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_tbl                     IN  ctiv_tbl_type,
    x_ctiv_tbl                     OUT NOCOPY ctiv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_ctiv_tbl.COUNT > 0 THEN
      i := p_ctiv_tbl.FIRST;
      LOOP
        create_cover_time(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_ctiv_rec      => p_ctiv_tbl(i),
          x_ctiv_rec      => x_ctiv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_ctiv_tbl.LAST);
        i := p_ctiv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END create_cover_time;

  --------------------------------------
  -- PROCEDURE update_cover_time
  --------------------------------------
  PROCEDURE update_cover_time(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_rec                     IN  ctiv_rec_type,
    x_ctiv_rec                     OUT NOCOPY ctiv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_cover_time';
    l_ctiv_rec                     ctiv_rec_type := p_ctiv_rec;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    g_ctiv_rec := p_ctiv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_ctiv_rec := migrate_ctiv(l_ctiv_rec, g_ctiv_rec);

    OKC_RULE_PUB.update_cover_time(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_ctiv_rec      => l_ctiv_rec,
      x_ctiv_rec      => x_ctiv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     g_ctiv_rec := x_ctiv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END update_cover_time;

  --------------------------------------
  -- PROCEDURE update_cover_time
  --------------------------------------
  PROCEDURE update_cover_time(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_tbl                     IN  ctiv_tbl_type,
    x_ctiv_tbl                     OUT NOCOPY ctiv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_ctiv_tbl.COUNT > 0 THEN
      i := p_ctiv_tbl.FIRST;
      LOOP
        update_cover_time(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_ctiv_rec      => p_ctiv_tbl(i),
          x_ctiv_rec      => x_ctiv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_ctiv_tbl.LAST);
        i := p_ctiv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END update_cover_time;

  --------------------------------------
  -- PROCEDURE delete_cover_time
  --------------------------------------
  PROCEDURE delete_cover_time(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_rec                     IN  ctiv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_cover_time';
    l_ctiv_rec                     ctiv_rec_type := p_ctiv_rec;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    g_ctiv_rec := p_ctiv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_RULE_PUB.delete_cover_time(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_ctiv_rec      => p_ctiv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     g_ctiv_rec := l_ctiv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END delete_cover_time;

  --------------------------------------
  -- PROCEDURE delete_cover_time
  --------------------------------------
  PROCEDURE delete_cover_time(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_tbl                     IN  ctiv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_ctiv_tbl.COUNT > 0 THEN
      i := p_ctiv_tbl.FIRST;
      LOOP
        delete_cover_time(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_ctiv_rec      => p_ctiv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_ctiv_tbl.LAST);
        i := p_ctiv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END delete_cover_time;

  --------------------------------------
  -- PROCEDURE lock_cover_time
  --------------------------------------
  PROCEDURE lock_cover_time(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_rec                     IN  ctiv_rec_type) IS
  BEGIN
    OKC_RULE_PUB.lock_cover_time(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_ctiv_rec      => p_ctiv_rec);
  END lock_cover_time;

  --------------------------------------
  -- PROCEDURE lock_cover_time
  --------------------------------------
  PROCEDURE lock_cover_time(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_tbl                     IN  ctiv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_ctiv_tbl.COUNT > 0 THEN
      i := p_ctiv_tbl.FIRST;
      LOOP
        lock_cover_time(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_ctiv_rec      => p_ctiv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_ctiv_tbl.LAST);
        i := p_ctiv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END lock_cover_time;

  --------------------------------------
  -- PROCEDURE validate_cover_time
  --------------------------------------
  PROCEDURE validate_cover_time(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_rec                     IN  ctiv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_cover_time';
    l_ctiv_rec                     ctiv_rec_type := p_ctiv_rec;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    g_ctiv_rec := p_ctiv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_RULE_PUB.validate_cover_time(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_ctiv_rec      => p_ctiv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     g_ctiv_rec := l_ctiv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END validate_cover_time;

  --------------------------------------
  -- PROCEDURE validate_cover_time
  --------------------------------------
  PROCEDURE validate_cover_time(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_tbl                     IN  ctiv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_ctiv_tbl.COUNT > 0 THEN
      i := p_ctiv_tbl.FIRST;
      LOOP
        validate_cover_time(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_ctiv_rec      => p_ctiv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_ctiv_tbl.LAST);
        i := p_ctiv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_cover_time;

  ---------------------------------------------------------------------------
  -- FUNCTION migrate_rilv
  ---------------------------------------------------------------------------
  FUNCTION migrate_rilv (
    p_rilv_rec1 IN rilv_rec_type,
    p_rilv_rec2 IN rilv_rec_type
  ) RETURN rilv_rec_type IS
    l_rilv_rec rilv_rec_type;
  BEGIN
    l_rilv_rec.tve_id                := p_rilv_rec2.tve_id;
    l_rilv_rec.rul_id                := p_rilv_rec2.rul_id;
    l_rilv_rec.dnz_chr_id            := p_rilv_rec2.dnz_chr_id;
    l_rilv_rec.duration              := p_rilv_rec2.duration;
    l_rilv_rec.uom_code              := p_rilv_rec2.uom_code;
    l_rilv_rec.object_version_number := p_rilv_rec1.object_version_number;
    l_rilv_rec.created_by            := p_rilv_rec1.created_by;
    l_rilv_rec.creation_date         := p_rilv_rec1.creation_date;
    l_rilv_rec.last_updated_by       := p_rilv_rec1.last_updated_by;
    l_rilv_rec.last_update_date      := p_rilv_rec1.last_update_date;
    l_rilv_rec.last_update_login     := p_rilv_rec1.last_update_login;

    RETURN (l_rilv_rec);
  END migrate_rilv;

  --------------------------------------
  -- PROCEDURE create_react_interval
  --------------------------------------
  PROCEDURE create_react_interval(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_rec                     IN  rilv_rec_type,
    x_rilv_rec                     OUT NOCOPY rilv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_react_interval';
    l_rilv_rec                     rilv_rec_type := p_rilv_rec;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    g_rilv_rec := p_rilv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_rilv_rec := migrate_rilv(l_rilv_rec, g_rilv_rec);

    OKC_RULE_PUB.create_react_interval(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rilv_rec      => l_rilv_rec,
      x_rilv_rec      => x_rilv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     g_rilv_rec := x_rilv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END create_react_interval;

  --------------------------------------
  -- PROCEDURE create_react_interval
  --------------------------------------
  PROCEDURE create_react_interval(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_tbl                     IN  rilv_tbl_type,
    x_rilv_tbl                     OUT NOCOPY rilv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rilv_tbl.COUNT > 0 THEN
      i := p_rilv_tbl.FIRST;
      LOOP
        create_react_interval(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rilv_rec      => p_rilv_tbl(i),
          x_rilv_rec      => x_rilv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rilv_tbl.LAST);
        i := p_rilv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END create_react_interval;

  --------------------------------------
  -- PROCEDURE update_react_interval
  --------------------------------------
  PROCEDURE update_react_interval(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_rec                     IN  rilv_rec_type,
    x_rilv_rec                     OUT NOCOPY rilv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_react_interval';
    l_rilv_rec                     rilv_rec_type := p_rilv_rec;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    g_rilv_rec := p_rilv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_rilv_rec := migrate_rilv(l_rilv_rec, g_rilv_rec);

    OKC_RULE_PUB.update_react_interval(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rilv_rec      => l_rilv_rec,
      x_rilv_rec      => x_rilv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     g_rilv_rec := x_rilv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END update_react_interval;

  --------------------------------------
  -- PROCEDURE update_react_interval
  --------------------------------------
  PROCEDURE update_react_interval(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_tbl                     IN  rilv_tbl_type,
    x_rilv_tbl                     OUT NOCOPY rilv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rilv_tbl.COUNT > 0 THEN
      i := p_rilv_tbl.FIRST;
      LOOP
        update_react_interval(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rilv_rec      => p_rilv_tbl(i),
          x_rilv_rec      => x_rilv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rilv_tbl.LAST);
        i := p_rilv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END update_react_interval;

  --------------------------------------
  -- PROCEDURE delete_react_interval
  --------------------------------------
  PROCEDURE delete_react_interval(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_rec                     IN  rilv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_react_interval';
    l_rilv_rec                     rilv_rec_type := p_rilv_rec;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    g_rilv_rec := p_rilv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_RULE_PUB.delete_react_interval(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rilv_rec      => p_rilv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     g_rilv_rec := l_rilv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END delete_react_interval;

  --------------------------------------
  -- PROCEDURE delete_react_interval
  --------------------------------------
  PROCEDURE delete_react_interval(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_tbl                     IN  rilv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rilv_tbl.COUNT > 0 THEN
      i := p_rilv_tbl.FIRST;
      LOOP
        delete_react_interval(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rilv_rec      => p_rilv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rilv_tbl.LAST);
        i := p_rilv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END delete_react_interval;

  --------------------------------------
  -- PROCEDURE lock_react_interval
  --------------------------------------
  PROCEDURE lock_react_interval(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_rec                     IN  rilv_rec_type) IS
  BEGIN
    OKC_RULE_PUB.lock_react_interval(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rilv_rec      => p_rilv_rec);
  END lock_react_interval;

  --------------------------------------
  -- PROCEDURE lock_react_interval
  --------------------------------------
  PROCEDURE lock_react_interval(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_tbl                     IN  rilv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rilv_tbl.COUNT > 0 THEN
      i := p_rilv_tbl.FIRST;
      LOOP
        lock_react_interval(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rilv_rec      => p_rilv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rilv_tbl.LAST);
        i := p_rilv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END lock_react_interval;

  --------------------------------------
  -- PROCEDURE validate_react_interval
  --------------------------------------
  PROCEDURE validate_react_interval(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_rec                     IN  rilv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_react_interval';
    l_rilv_rec                     rilv_rec_type := p_rilv_rec;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    g_rilv_rec := p_rilv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_RULE_PUB.validate_react_interval(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rilv_rec      => p_rilv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     g_rilv_rec := l_rilv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OKC_API.G_RET_STS_UNEXP_ERROR'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (l_api_name
      ,G_PKG_NAME
      ,'OTHERS'
      ,x_msg_count
      ,x_msg_data
      ,'_PUB');
  END validate_react_interval;

  --------------------------------------
  -- PROCEDURE validate_react_interval
  --------------------------------------
  PROCEDURE validate_react_interval(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_tbl                     IN  rilv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_rilv_tbl.COUNT > 0 THEN
      i := p_rilv_tbl.FIRST;
      LOOP
        validate_react_interval(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_rilv_rec      => p_rilv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rilv_tbl.LAST);
        i := p_rilv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_react_interval;
*/
  --------------------------------------
  -- PROCEDURE add_language
  --------------------------------------
  PROCEDURE add_language IS
  BEGIN
    OKC_RULE_PUB.ADD_LANGUAGE;
  END add_language;

function rule_meaning(p_rle_code varchar2) return varchar2
is
-- cursor c1 is select meaning from fnd_lookups
-- where lookup_type='OKC_RULE_DEF'
-- and enabled_flag='Y'
-- and lookup_code=p_rle_code;

--rule striping
 cursor c1 is
 select meaning
 from   okc_rule_defs_v
 where  rule_code = p_rle_code;

r varchar2(100);
begin
  open c1;
  fetch c1 into r;
  close c1;
  return r;
end;

--
-- client call
--
  function get_new_code
    (p_rgd_code in varchar2, p_rdf_code in varchar2, p_intent varchar2, p_number number)
      return varchar2 is
    CURSOR l_csr IS
      SELECT JTOT_OBJECT_CODE
      FROM okc_rule_def_sources_v
      WHERE RGR_RGD_CODE = p_rgd_code
	and RGR_RDF_CODE = p_rdf_code
	and BUY_OR_SELL  = p_intent
	and OBJECT_ID_NUMBER = p_number
	and sysdate between start_date and nvl(end_date,sysdate)
    ;
    l_code varchar2(100);
  begin
    open l_csr;
    fetch l_csr into l_code;
    close l_csr;
    return l_code;
  end get_new_code;

function uncomment(p_where varchar2,p_what varchar2) return varchar2 is
  l_where varchar2(4000);
  l_rest varchar2(4000);
  pos number;
  pos1 number;
begin
    pos:= instr(p_where,'/*');
    if (pos=0) then
      return p_where;
    else
      l_where := substr(p_where,1,pos-1);
      l_rest := substr(p_where,pos);
    end if;
    if (p_what='Y') then
      return l_where;
    end if;
    pos:= instr(l_rest,'--LOV');
    if (pos<>0) then
      l_rest := substr(l_rest,pos);
      pos:= instr(l_rest,fnd_global.newline);
      l_rest := substr(l_rest,pos+length(fnd_global.newline));
      pos1:= instr(l_rest,'*/');
      l_where := l_where||' '||substr(l_rest,1,pos1-1);
      l_rest := substr(l_rest,pos1+2);
    end if;
    if (p_what='LOV') then
      return l_where;
    end if;
    pos:= instr(l_rest,'--'||p_what);
    if (pos<>0) then
      l_rest := substr(l_rest,pos+2+length(p_what));
      pos:= instr(l_rest,fnd_global.newline);
      l_rest := substr(l_rest,pos+length(fnd_global.newline));
      pos1:= instr(l_rest,'*/');
      l_where := l_where||' '||substr(l_rest,1,pos1-1);
    end if;
    return l_where;
end;

--
--for old code server function
--for new code usage on client with get_new_code combined
--
  --
  -- (select 'object_code' object_code,id1,id2,name value,description
  -- from 'from_table'
  -- where 'where_clause')
  --
  function get_object_sql(p_object_code in varchar2,p_clause_yn in varchar2) return varchar2 is
    CURSOR l_csr IS
      SELECT
	'(select ''' || p_object_code || ''' object_code, id1, id2, name value, description from '
	||from_table select_clause
--      ||decode(p_clause_yn,'Y',decode(where_clause,'','',' where '||where_clause))|| ')'
        ,where_clause
      FROM JTF_OBJECTS_VL
      WHERE object_code = p_object_code;
    l_sql varchar2(4000);
    l_where varchar2(4000);
  begin
    if (p_object_code is NULL) then return
      '(select ''object_code'' object_code, ''id1'' id1, ''id2'' id2, ''value'' value, ''description'' description from dual where 0=1)';
    end if;
    open l_csr;
    fetch l_csr into l_sql,l_where;
    close l_csr;
    if (p_clause_yn='N' or l_where is null) then
      return l_sql||')';
    else
--+
      l_where := uncomment(l_where,p_clause_yn);
      if (l_where is null) then
        return l_sql||')';
      else
        return l_sql||' where '||l_where||')';
      end if;
--+
    end if;
  end get_object_sql;

  function get_object_sql(p_object_code in varchar2,p_cpl_id in number) return varchar2 is
    CURSOR c1 IS
      SELECT object1_id1 from okc_k_party_roles_v
      where id = p_cpl_id;
    l1 varchar2(40);

    CURSOR l_csr IS
      SELECT
	'(select ''' || p_object_code || ''' object_code, id1, id2, name value, description from '
	||from_table||decode(where_clause,
		'',' where status = ''A'' and party_id = '''||l1||'''',
		' where status = ''A'' and party_id = '''||l1||''' and '||where_clause)|| ')'
      FROM JTF_OBJECTS_VL
      WHERE object_code = p_object_code;
    l_sql varchar2(4000);
  begin
    if (p_object_code is NULL) then return
      '(select ''object_code'' object_code, ''id1'' id1, ''id2'' id2, ''value'' value, ''description'' description from dual where 0=1)';
    end if;
    open c1;
    fetch c1 into l1;
    close c1;
    open l_csr;
    fetch l_csr into l_sql;
    close l_csr;
    return l_sql;
  end get_object_sql;

  function get_object_sql(p_object_code in varchar2) return varchar2 is
  begin
    return  get_object_sql(p_object_code,'N');
  end;

  function get_object_val
    (p_object_code in varchar2, p_object_id1 in varchar2, p_object_id2 in varchar2)
      return varchar2 is
--
--old data only, server call
--
    TYPE ref_type IS REF CURSOR;
    l_ref_csr ref_type;
    l_sql varchar2(4000);
    l_val varchar2(2000);
  begin
    if (p_object_code is NULL or p_object_id1 is NULL) then return NULL;
    end if;
    l_sql :=
	'select value from '||get_object_sql(p_object_code,'Y')
	||' where id1=:1 and id2=:2';
    OPEN l_ref_csr FOR l_sql
      USING p_object_id1,p_object_id2;
      FETCH l_ref_csr INTO l_val;
    CLOSE l_ref_csr;
    return l_val;
  end get_object_val;

  function get_object_dsc
    (p_object_code in varchar2, p_object_id1 in varchar2, p_object_id2 in varchar2)
      return varchar2 is
--
--old data only, server call
--
    TYPE ref_type IS REF CURSOR;
    l_ref_csr ref_type;
    l_sql varchar2(4000);
    l_val varchar2(2000);
  begin
    if (p_object_code is NULL or p_object_id1 is NULL) then return NULL;
    end if;
    l_sql :=
	'select description from '||get_object_sql(p_object_code,'Y')
	||' where id1=:1 and id2=:2';
    OPEN l_ref_csr FOR l_sql
      USING p_object_id1,p_object_id2;
      FETCH l_ref_csr INTO l_val;
    CLOSE l_ref_csr;
    return l_val;
  end get_object_dsc;

--
--new data, client call
--
  procedure get_object_ids(
		p_value in varchar2,
		p_sql in varchar2,
		x_object_code out nocopy varchar2,
		x_id1 out nocopy varchar2,
		x_id2 out nocopy varchar2,
		x_desc out nocopy varchar2
  ) is
    TYPE ref_type IS REF CURSOR;
    l_ref_csr ref_type;
    l_sql varchar2(4000);
    l_val varchar2(2000);
  begin
    if (p_value is NULL or p_sql is NULL) then return;
    end if;
    l_sql :=
	'select object_code, id1, id2, description from '||p_sql
	||' where value=:1';
    OPEN l_ref_csr FOR l_sql
      USING p_value;
      FETCH l_ref_csr INTO x_object_code, x_id1, x_id2, x_desc;
    CLOSE l_ref_csr;
  end get_object_ids;

  procedure get_object_ids(
		p_value in varchar2,
		p_desc in varchar2,
		p_sql in varchar2,
		x_object_code out nocopy varchar2,
		x_id1 out nocopy varchar2,
		x_id2 out nocopy varchar2,
		x_desc out nocopy varchar2
  ) is
    TYPE ref_type IS REF CURSOR;
    l_ref_csr ref_type;
    l_sql varchar2(4000);
    l_val varchar2(2000);
  begin
    if (p_value is NULL or p_sql is NULL) then return;
    end if;
    l_sql :=
	'select object_code, id1, id2, description from '||p_sql
	||' where value=:1 and ((:2 is null and description is null) or (:3 = description))';
    OPEN l_ref_csr FOR l_sql
      USING p_value, p_desc, p_desc;
      FETCH l_ref_csr INTO x_object_code, x_id1, x_id2, x_desc;
    CLOSE l_ref_csr;
  end get_object_ids;

--
--new on client
--old on server
--
  function get_flex_sql(p_rdf_code in varchar2, p_col_name in varchar2,p_clause_yn in varchar2) return varchar2 is
  --
  -- (select id, value, meaning description
  -- from 'application_table_name'
  -- where 'additional_where_clause'  --get rid of where and order by)
  --
    CURSOR l_csr IS
--	select 'select '||tbl.ID_COLUMN_NAME||' id, '
--		||decode(col.END_USER_COLUMN_NAME,'TVE_ID',
--'comments value, '''' description from ',
--tbl.VALUE_COLUMN_NAME||' value, '||NVL(tbl.MEANING_COLUMN_NAME,'''''')||' description from ')
--		||tbl.APPLICATION_TABLE_NAME sel,
--	tbl.ADDITIONAL_WHERE_CLAUSE whr
--	from fnd_descr_flex_col_usage_vl  col,
--	  fnd_flex_validation_tables tbl
--	where col.application_id=510
--	and col.descriptive_flexfield_name='OKC Rule Developer DF'
--	and col.descriptive_flex_context_code=p_rdf_code
--	and col.application_column_name=p_col_name
--	and col.FLEX_VALUE_SET_ID=tbl.FLEX_VALUE_SET_ID
--	;
--rule striping
    select 'select '||tbl.ID_COLUMN_NAME||' id, '
		||decode(col.END_USER_COLUMN_NAME,'TVE_ID',
'comments value, '''' description from ',
tbl.VALUE_COLUMN_NAME||' value, '||NVL(tbl.MEANING_COLUMN_NAME,'''''')||' description from ')
		||tbl.APPLICATION_TABLE_NAME sel,
	tbl.ADDITIONAL_WHERE_CLAUSE whr
	from fnd_descr_flex_col_usage_vl  col,
	     fnd_flex_validation_tables   tbl,
         okc_rule_defs_v              rdefv
	where col.application_id                = rdefv.application_id
	and   col.descriptive_flexfield_name    = rdefv.descriptive_flexfield_name
	and   col.descriptive_flex_context_code = rdefv.rule_code
	and   col.application_column_name       = p_col_name
    and   rdefv.rule_code                   = p_rdf_code
	and   col.FLEX_VALUE_SET_ID=tbl.FLEX_VALUE_SET_ID;

    l_sel varchar2(4000);
    l_whr varchar2(4000);
  begin
    open l_csr;
    fetch l_csr into l_sel, l_whr;
    close l_csr;
    if (l_sel is null) then return null;
    end if;
    if (l_whr is null or p_clause_yn='N') then return '('||l_sel||')';
    end if;
    l_whr := upper(l_whr);
    if (substr(l_whr,1,6)='WHERE ') then l_whr:=substr(l_whr,7);
    end if;
    if (instr(l_whr,'ORDER BY')<>0) then l_whr:=substr(l_whr,1,instr(l_whr,'ORDER BY')-1);
    end if;
    if (l_whr is null) then return '('||l_sel||')';
    end if;
--+
    l_whr := uncomment(l_whr,p_clause_yn);
    if (l_whr is null) then return '('||l_sel||')';
    end if;
--+
    return '('||l_sel||' where '||l_whr||')';
  end get_flex_sql;

  function get_flex_sql(p_rdf_code in varchar2, p_col_name in varchar2) return varchar2 is
  begin
    return  get_flex_sql(p_rdf_code, p_col_name,'N');
  end;

--
--old data only, server call
--
  function get_flex_val(p_rdf_code in varchar2, p_col_name in varchar2, p_id in varchar2)
	return varchar2 is
    TYPE ref_type IS REF CURSOR;
    l_ref_csr ref_type;
    l_sql varchar2(4000);
    l_val varchar2(2000);
  begin
    if (p_id is NULL) then return NULL;
    end if;
    l_sql := get_flex_sql(p_rdf_code, p_col_name,'Y');
    if (l_sql is null) then return NULL;
    end if;
    l_sql := 'select value from '||l_sql||' where id=:1';
    OPEN l_ref_csr FOR l_sql
      USING p_id;
      FETCH l_ref_csr INTO l_val;
    CLOSE l_ref_csr;
    return l_val;
  end get_flex_val;

--
--old data only, server call
--
  function get_flex_dsc(p_rdf_code in varchar2, p_col_name in varchar2, p_id in varchar2)
	return varchar2 is
    TYPE ref_type IS REF CURSOR;
    l_ref_csr ref_type;
    l_sql varchar2(4000);
    l_val varchar2(2000);
  begin
    if (p_id is NULL) then return NULL;
    end if;
    l_sql := get_flex_sql(p_rdf_code, p_col_name,'Y');
    if (l_sql is null) then return NULL;
    end if;
    l_sql := 'select description from '||l_sql||' where id=:1';
    OPEN l_ref_csr FOR l_sql
      USING p_id;
      FETCH l_ref_csr INTO l_val;
    CLOSE l_ref_csr;
    return l_val;
  end get_flex_dsc;

--
--new data only, client call
--
  procedure get_flex_ids(
		p_value varchar2,
		p_sql in varchar2,
		x_id out nocopy varchar2,
		x_desc out nocopy varchar2
  ) is
    TYPE ref_type IS REF CURSOR;
    l_ref_csr ref_type;
    l_sql varchar2(4000);
    l_val varchar2(2000);
  begin
    if (p_value is NULL or p_sql is NULL) then return;
    end if;
    l_sql :=
	'select id, description from '||p_sql
	||' where value=:1';
    OPEN l_ref_csr FOR l_sql
      USING p_value;
      FETCH l_ref_csr INTO x_id, x_desc;
    CLOSE l_ref_csr;
  end get_flex_ids;

  procedure get_flex_ids(
		p_value varchar2,
		p_desc varchar2,
		p_sql in varchar2,
		x_id out nocopy varchar2,
		x_desc out nocopy varchar2
  ) is
    TYPE ref_type IS REF CURSOR;
    l_ref_csr ref_type;
    l_sql varchar2(4000);
    l_val varchar2(2000);
  begin
    if (p_value is NULL or p_sql is NULL) then return;
    end if;
    l_sql :=
	'select id, description from '||p_sql
	||' where value=:1 and ((:2 is null and description is null) or (:3 = description))';
    OPEN l_ref_csr FOR l_sql
      USING p_value, p_desc, p_desc;
      FETCH l_ref_csr INTO x_id, x_desc;
    CLOSE l_ref_csr;
  end get_flex_ids;

  function euro_YN(rle_code varchar2, p_chr_id number) return varchar2 is
  begin
    if (rle_code='CVN') then
      if(okc_currency_api.get_ou_currency(p_chr_id)='EMU') then
        return 'Y';
       end if;
    end if;
    return 'N';
  end;

function gen_comments return varchar2 is
begin
  return G_GEN_COMMENTS;
end;

procedure no_comments is
begin
  G_GEN_COMMENTS := 'F';
end;

function euro_yn(auth_org_id number) return varchar2 is
begin
  if okc_currency_api.get_currency_type(
       okc_currency_api.get_ou_currency(
         nvl(auth_org_id,nvl(OKL_CONTEXT.get_okc_org_id,-99))    --dkagrawa changed for MOAC
       ),sysdate) like 'EMU%' then
    return 'Y';
  else return 'N';
  end if;
exception
  when others then return 'N';
end;

procedure issue_savepoint (sp varchar2) is
begin
  dbms_transaction.savepoint(sp);
exception when others then NULL;
end;

procedure rollback_savepoint (sp varchar2) is
begin
  rollback to sp;
exception when others then NULL;
end;

procedure initialize(x out nocopy rulv_tbl_type) is
begin
  x(1).last_update_date := sysdate;
end;

procedure initialize(x out nocopy rgpv_tbl_type) is
begin
  x(1).last_update_date := sysdate;
end;

procedure initialize(x out nocopy rmpv_tbl_type) is
begin
  x(1).last_update_date := sysdate;
end;

END OKL_RULE_PUB;

/
