--------------------------------------------------------
--  DDL for Package Body OKC_RULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_RULE_PUB" AS
/* $Header: OKCPRULB.pls 120.0 2005/05/26 09:46:12 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

G_GEN_COMMENTS VARCHAR2(1) := 'T';
g_package  varchar2(33) := '  OKC_RULE_PUB.';

-- /striping/
p_rule_code   OKC_RULE_DEFS_B.rule_code%TYPE;
p_appl_id     OKC_RULE_DEFS_B.application_id%TYPE;
p_dff_name    OKC_RULE_DEFS_B.descriptive_flexfield_name%TYPE;

  ---------------------------------------------------------------------------
  -- FUNCTION migrate_rulv
  ---------------------------------------------------------------------------
  FUNCTION migrate_rulv (
    p_rulv_rec1 IN rulv_rec_type,
    p_rulv_rec2 IN rulv_rec_type
  ) RETURN rulv_rec_type IS
    l_rulv_rec rulv_rec_type;
   --
   l_proc varchar2(72) := g_package||'migrate_rulv';
   --

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
--Bug 3055393    l_rulv_rec.sfwt_flag             := p_rulv_rec2.sfwt_flag;
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
-- Bug 3055393    l_rulv_rec.text                  := p_rulv_rec2.text;
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
    l_rulv_rec.VALIDATE_YN               := NVL(p_rulv_rec2.VALIDATE_YN,'Y');

    RETURN (l_rulv_rec);
  END migrate_rulv;

  --------------------------------------
  -- PROCEDURE create_rule
  --------------------------------------
  PROCEDURE create_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN  rulv_rec_type,
    x_rulv_rec                     OUT NOCOPY rulv_rec_type,
    p_euro_conv_yn                 IN VARCHAR2) IS

    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_rule';
    l_rulv_rec                     rulv_rec_type := p_rulv_rec;
    l_clob clob;
   --
   l_proc varchar2(72) := g_package||'create_rule';
   --

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

    -- Call user hook for BEFORE
    g_rulv_rec := p_rulv_rec;
/*-- Bug 3055393
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
*/
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_rulv_rec := migrate_rulv(l_rulv_rec, g_rulv_rec);

    OKC_RULE_PVT.create_rule(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rulv_rec      => l_rulv_rec,
      x_rulv_rec      => x_rulv_rec,
      p_euro_conv_yn  => p_euro_conv_yn);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_rulv_rec := x_rulv_rec;
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




  END create_rule;

  --------------------------------------
  -- PROCEDURE create_rule
  --------------------------------------
  PROCEDURE create_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN  rulv_rec_type,
    x_rulv_rec                     OUT NOCOPY rulv_rec_type)
  IS
   --
   l_proc varchar2(72) := g_package||'create_rule';
   --

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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN  rulv_tbl_type,
    x_rulv_tbl                     OUT NOCOPY rulv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'create_rule';
   --

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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN  rulv_tbl_type,
    x_rulv_tbl                     OUT NOCOPY rulv_tbl_type,
    p_euro_conv_yn                 IN VARCHAR2)
  IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'create_rule';
   --

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

  --------------------------------------
  -- PROCEDURE update_rule
  --------------------------------------
  PROCEDURE update_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN  rulv_rec_type,
    x_rulv_rec                     OUT NOCOPY rulv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_rule';
    l_rulv_rec                     rulv_rec_type := p_rulv_rec;
    l_clob clob;
   --
   l_proc varchar2(72) := g_package||'update_rule';
   --

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

    -- Call user hook for BEFORE
    g_rulv_rec := p_rulv_rec;
/*    IF (DBMS_LOB.istemporary(p_rulv_rec.TEXT) = 1) THEN
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
*/
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_rulv_rec := migrate_rulv(l_rulv_rec, g_rulv_rec);

    OKC_RULE_PVT.update_rule(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rulv_rec      => l_rulv_rec,
      x_rulv_rec      => x_rulv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_rulv_rec := x_rulv_rec;
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




  END update_rule;

  --------------------------------------
  -- PROCEDURE update_rule
  --------------------------------------
  PROCEDURE update_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN  rulv_tbl_type,
    x_rulv_tbl                     OUT NOCOPY rulv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'update_rule';
   --

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
      p_token1	        => G_SQLCODE_TOKEN,
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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN  rulv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_rule';
    l_rulv_rec                     rulv_rec_type := p_rulv_rec;
   --
   l_proc varchar2(72) := g_package||'validate_rule';
   --

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
    -- Call user hook for BEFORE
    g_rulv_rec := p_rulv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_rulv_rec := migrate_rulv(l_rulv_rec, g_rulv_rec);

    OKC_RULE_PVT.validate_rule(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rulv_rec      => l_rulv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN  rulv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'validate_rule';
   --

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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN  rulv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_rule';
    l_rulv_rec                     rulv_rec_type := p_rulv_rec;
   --
   l_proc varchar2(72) := g_package||'delete_rule';
   --

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
    -- Call user hook for BEFORE
    g_rulv_rec := p_rulv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_RULE_PVT.delete_rule(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rulv_rec      => p_rulv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN  rulv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'delete_rule';
   --

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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_rec                     IN  rulv_rec_type) IS
   --
   l_proc varchar2(72) := g_package||'lock_rule';
   --

  BEGIN




    OKC_RULE_PVT.lock_rule(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_rulv_rec      => p_rulv_rec);




  END lock_rule;

  --------------------------------------
  -- PROCEDURE lock_rule
  --------------------------------------
  PROCEDURE lock_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rulv_tbl                     IN  rulv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'lock_rule';
   --

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
   --
   l_proc varchar2(72) := g_package||'migrate_rgpv';
   --

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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type,
    x_rgpv_rec                     OUT NOCOPY rgpv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_rule_group';
    l_rgpv_rec                     rgpv_rec_type := p_rgpv_rec;
   --
   l_proc varchar2(72) := g_package||'create_rule_group';
   --

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
    -- Call user hook for BEFORE
    g_rgpv_rec := p_rgpv_rec;

    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_rgpv_rec := migrate_rgpv(l_rgpv_rec, g_rgpv_rec);

    OKC_RULE_PVT.create_rule_group(
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

     -- Call user hook for AFTER
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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_tbl                     IN  rgpv_tbl_type,
    x_rgpv_tbl                     OUT NOCOPY rgpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'create_rule_group';
   --

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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type,
    x_rgpv_rec                     OUT NOCOPY rgpv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_rule_group';
    l_rgpv_rec                     rgpv_rec_type := p_rgpv_rec;
   --
   l_proc varchar2(72) := g_package||'update_rule_group';
   --

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
    -- Call user hook for BEFORE
    g_rgpv_rec := p_rgpv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_rgpv_rec := migrate_rgpv(l_rgpv_rec, g_rgpv_rec);

    OKC_RULE_PVT.update_rule_group(
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

     -- Call user hook for AFTER
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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_tbl                     IN  rgpv_tbl_type,
    x_rgpv_tbl                     OUT NOCOPY rgpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'update_rule_group';
   --

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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_rule_group';
    l_rgpv_rec                     rgpv_rec_type := p_rgpv_rec;
   --
   l_proc varchar2(72) := g_package||'delete_rule_group';
   --

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
    -- Call user hook for BEFORE
    g_rgpv_rec := p_rgpv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_RULE_PVT.delete_rule_group(
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

     -- Call user hook for AFTER
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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_tbl                     IN  rgpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'delete_rule_group';
   --

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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type) IS
   --
   l_proc varchar2(72) := g_package||'lock_rule_group';
   --

  BEGIN




    OKC_RULE_PVT.lock_rule_group(
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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_tbl                     IN  rgpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'lock_rule_group';
   --

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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_rule_group';
    l_rgpv_rec                     rgpv_rec_type := p_rgpv_rec;
   --
   l_proc varchar2(72) := g_package||'validate_rule_group';
   --

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
    -- Call user hook for BEFORE
    g_rgpv_rec := p_rgpv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_RULE_PVT.validate_rule_group(
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

     -- Call user hook for AFTER
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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_tbl                     IN  rgpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'validate_rule_group';
   --

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
   --
   l_proc varchar2(72) := g_package||'migrate_rmpv';
   --

  BEGIN

    l_rmpv_rec.id                    := p_rmpv_rec2.id;
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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type,
    x_rmpv_rec                     OUT NOCOPY rmpv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_rg_mode_pty_role';
    l_rmpv_rec                     rmpv_rec_type := p_rmpv_rec;
   --
   l_proc varchar2(72) := g_package||'create_rg_mode_pty_role';
   --

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
    -- Call user hook for BEFORE
    g_rmpv_rec := p_rmpv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_rmpv_rec := migrate_rmpv(l_rmpv_rec, g_rmpv_rec);

    OKC_RULE_PVT.create_rg_mode_pty_role(
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

     -- Call user hook for AFTER
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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_tbl                     IN  rmpv_tbl_type,
    x_rmpv_tbl                     OUT NOCOPY rmpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'create_rg_mode_pty_role';
   --

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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type,
    x_rmpv_rec                     OUT NOCOPY rmpv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_rg_mode_pty_role';
    l_rmpv_rec                     rmpv_rec_type := p_rmpv_rec;
   --
   l_proc varchar2(72) := g_package||'update_rg_mode_pty_role';
   --

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
    -- Call user hook for BEFORE
    g_rmpv_rec := p_rmpv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_rmpv_rec := migrate_rmpv(l_rmpv_rec, g_rmpv_rec);

    OKC_RULE_PVT.update_rg_mode_pty_role(
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

     -- Call user hook for AFTER
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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_tbl                     IN  rmpv_tbl_type,
    x_rmpv_tbl                     OUT NOCOPY rmpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'update_rg_mode_pty_role';
   --

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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_rg_mode_pty_role';
    l_rmpv_rec                     rmpv_rec_type := p_rmpv_rec;
   --
   l_proc varchar2(72) := g_package||'delete_rg_mode_pty_role';
   --

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
    -- Call user hook for BEFORE
    g_rmpv_rec := p_rmpv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_RULE_PVT.delete_rg_mode_pty_role(
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

     -- Call user hook for AFTER
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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_tbl                     IN  rmpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'delete_rg_mode_pty_role';
   --

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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type) IS
   --
   l_proc varchar2(72) := g_package||'lock_rg_mode_pty_role';
   --

  BEGIN




    OKC_RULE_PVT.lock_rg_mode_pty_role(
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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_tbl                     IN  rmpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'lock_rg_mode_pty_role';
   --

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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_rec                     IN  rmpv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_rg_mode_pty_role';
    l_rmpv_rec                     rmpv_rec_type := p_rmpv_rec;
   --
   l_proc varchar2(72) := g_package||'validate_rg_mode_pty_role';
   --

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
    -- Call user hook for BEFORE
    g_rmpv_rec := p_rmpv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_RULE_PVT.validate_rg_mode_pty_role(
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

     -- Call user hook for AFTER
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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rmpv_tbl                     IN  rmpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'validate_rg_mode_pty_role';
   --

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

  ---------------------------------------------------------------------------
  -- FUNCTION migrate_ctiv
  ---------------------------------------------------------------------------
  FUNCTION migrate_ctiv (
    p_ctiv_rec1 IN ctiv_rec_type,
    p_ctiv_rec2 IN ctiv_rec_type
  ) RETURN ctiv_rec_type IS
    l_ctiv_rec ctiv_rec_type;
   --
   l_proc varchar2(72) := g_package||'migrate_ctiv';
   --

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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_rec                     IN  ctiv_rec_type,
    x_ctiv_rec                     OUT NOCOPY ctiv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_cover_time';
    l_ctiv_rec                     ctiv_rec_type := p_ctiv_rec;
   --
   l_proc varchar2(72) := g_package||'create_cover_time';
   --

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
    -- Call user hook for BEFORE
    g_ctiv_rec := p_ctiv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_ctiv_rec := migrate_ctiv(l_ctiv_rec, g_ctiv_rec);

    OKC_RULE_PVT.create_cover_time(
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

     -- Call user hook for AFTER
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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_tbl                     IN  ctiv_tbl_type,
    x_ctiv_tbl                     OUT NOCOPY ctiv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'create_cover_time';
   --

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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_rec                     IN  ctiv_rec_type,
    x_ctiv_rec                     OUT NOCOPY ctiv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_cover_time';
    l_ctiv_rec                     ctiv_rec_type := p_ctiv_rec;
   --
   l_proc varchar2(72) := g_package||'update_cover_time';
   --

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
    -- Call user hook for BEFORE
    g_ctiv_rec := p_ctiv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_ctiv_rec := migrate_ctiv(l_ctiv_rec, g_ctiv_rec);

    OKC_RULE_PVT.update_cover_time(
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

     -- Call user hook for AFTER
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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_tbl                     IN  ctiv_tbl_type,
    x_ctiv_tbl                     OUT NOCOPY ctiv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'update_cover_time';
   --

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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_rec                     IN  ctiv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_cover_time';
    l_ctiv_rec                     ctiv_rec_type := p_ctiv_rec;
   --
   l_proc varchar2(72) := g_package||'delete_cover_time';
   --

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
    -- Call user hook for BEFORE
    g_ctiv_rec := p_ctiv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_RULE_PVT.delete_cover_time(
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

     -- Call user hook for AFTER
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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_tbl                     IN  ctiv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'delete_cover_time';
   --

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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_rec                     IN  ctiv_rec_type) IS
   --
   l_proc varchar2(72) := g_package||'lock_cover_time';
   --

  BEGIN




    OKC_RULE_PVT.lock_cover_time(
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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_tbl                     IN  ctiv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'lock_cover_time';
   --

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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_rec                     IN  ctiv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_cover_time';
    l_ctiv_rec                     ctiv_rec_type := p_ctiv_rec;
   --
   l_proc varchar2(72) := g_package||'validate_cover_time';
   --

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
    -- Call user hook for BEFORE
    g_ctiv_rec := p_ctiv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_RULE_PVT.validate_cover_time(
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

     -- Call user hook for AFTER
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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctiv_tbl                     IN  ctiv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'validate_cover_time';
   --

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
   --
   l_proc varchar2(72) := g_package||'migrate_rilv';
   --

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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_rec                     IN  rilv_rec_type,
    x_rilv_rec                     OUT NOCOPY rilv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_react_interval';
    l_rilv_rec                     rilv_rec_type := p_rilv_rec;
   --
   l_proc varchar2(72) := g_package||'create_react_interval';
   --

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
    -- Call user hook for BEFORE
    g_rilv_rec := p_rilv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_rilv_rec := migrate_rilv(l_rilv_rec, g_rilv_rec);

    OKC_RULE_PVT.create_react_interval(
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

     -- Call user hook for AFTER
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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_tbl                     IN  rilv_tbl_type,
    x_rilv_tbl                     OUT NOCOPY rilv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'create_react_interval';
   --

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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_rec                     IN  rilv_rec_type,
    x_rilv_rec                     OUT NOCOPY rilv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_react_interval';
    l_rilv_rec                     rilv_rec_type := p_rilv_rec;
   --
   l_proc varchar2(72) := g_package||'update_react_interval';
   --

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
    -- Call user hook for BEFORE
    g_rilv_rec := p_rilv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_rilv_rec := migrate_rilv(l_rilv_rec, g_rilv_rec);

    OKC_RULE_PVT.update_react_interval(
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

     -- Call user hook for AFTER
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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_tbl                     IN  rilv_tbl_type,
    x_rilv_tbl                     OUT NOCOPY rilv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'update_react_interval';
   --

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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_rec                     IN  rilv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_react_interval';
    l_rilv_rec                     rilv_rec_type := p_rilv_rec;
   --
   l_proc varchar2(72) := g_package||'delete_react_interval';
   --

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
    -- Call user hook for BEFORE
    g_rilv_rec := p_rilv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_RULE_PVT.delete_react_interval(
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

     -- Call user hook for AFTER
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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_tbl                     IN  rilv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'delete_react_interval';
   --

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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_rec                     IN  rilv_rec_type) IS
   --
   l_proc varchar2(72) := g_package||'lock_react_interval';
   --

  BEGIN




    OKC_RULE_PVT.lock_react_interval(
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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_tbl                     IN  rilv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'lock_react_interval';
   --

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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_rec                     IN  rilv_rec_type) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_react_interval';
    l_rilv_rec                     rilv_rec_type := p_rilv_rec;
   --
   l_proc varchar2(72) := g_package||'validate_react_interval';
   --

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
    -- Call user hook for BEFORE
    g_rilv_rec := p_rilv_rec;
    okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_RULE_PVT.validate_react_interval(
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

     -- Call user hook for AFTER
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
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rilv_tbl                     IN  rilv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := g_package||'validate_react_interval';
   --

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

  --------------------------------------
  -- PROCEDURE add_language
  --------------------------------------
  PROCEDURE add_language IS
   --
   l_proc varchar2(72) := g_package||'add_language';
   --

  BEGIN




    OKC_RULE_PVT.ADD_LANGUAGE;
  END add_language;

function rule_meaning(p_rle_code varchar2) return varchar2
is
/* -- /striping/
 cursor c1 is select meaning from fnd_lookups
 where lookup_type='OKC_RULE_DEF'
 and enabled_flag='Y'
 and lookup_code=p_rle_code;
*/
-- /striping/
cursor c1 is
SELECT meaning FROM okc_rule_defs_v, FND_DESCR_FLEX_CONTEXTS
WHERE RULE_CODE = p_rle_code
and DESCRIPTIVE_FLEX_CONTEXT_CODE = RULE_CODE
and ENABLED_FLAG = 'Y';

r varchar2(100);
   --
   l_proc varchar2(72) := g_package||'rule_meaning';
   --

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
   --
   l_proc varchar2(72) := g_package||'get_new_code';
   --

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
   --
   l_proc varchar2(72) := g_package||'uncomment';
   --

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
   --
   l_proc varchar2(72) := g_package||'get_object_sql';
   --

  begin




    if (p_object_code is NULL) then




      return
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
   --
   l_proc varchar2(72) := g_package||'get_object_sql';
   --

  begin




    if (p_object_code is NULL) then




      return
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

-- the function hierarchically looks for object1/2_id1 for current line (then for parent, then for contract)
  FUNCTION get_rule_val(
    p_chr_id in number,
    p_cle_id in number,
    p_rule_name VARCHAR2,
    p_ncol NUMBER
  ) RETURN VARCHAR2 IS
    CURSOR c1 IS
     SELECT Decode(p_ncol, 1, rul.object1_id1, 2, rul.object2_id1, NULL) retval
      from (SELECT id, level lvl from okc_k_lines_b
            start with id = p_cle_id
            connect by id = prior cle_id) cle,
            okc_rule_groups_v rgp, okc_rules_v rul
      where rul.rgp_id = rgp.id and rul.RULE_INFORMATION_CATEGORY=p_rule_name
        and rgp.dnz_chr_id=p_chr_id
        and (rgp.cle_id=cle.id or rgp.cle_id IS NULL)
      order by decode(rgp.cle_id,NULL,1,0), lvl;
    CURSOR c2 IS
     SELECT Decode(p_ncol, 1, rul.object1_id1, 2, rul.object2_id1, NULL) retval
      from  okc_rule_groups_v rgp, okc_rules_v rul
      where rul.rgp_id = rgp.id and rul.RULE_INFORMATION_CATEGORY=p_rule_name
        and rgp.dnz_chr_id=p_chr_id and rgp.cle_id IS NULL;
    l_retval VARCHAR2(250);
   begin
    IF p_cle_id IS NOT NULL THEN
      OPEN c1;
      FETCH c1 INTO l_retval;
      CLOSE c1;
     ELSE
      OPEN c2;
      FETCH c2 INTO l_retval;
      CLOSE c2;
    END IF;
    RETURN l_retval;
   EXCEPTION
    WHEN OTHERS THEN
    RETURN NULL;
  end get_rule_val;

-- next function created for bug#2632708 resolution
-- p_id - BTO/STO account id if p_rule=BTO/STO and p_ncol=1
--        current rule group id (RGP_ID) in other cases
  function get_object_sql(p_object_code in varchar2,p_id in number, p_rule VARCHAR2, p_ncol NUMBER) return varchar2 is

    CURSOR c1 IS
      select rgp.dnz_chr_id, rgp.cle_id, cpl.object1_id1, decode(p_rule,'BTO','BILL','STO','SHIP',NULL) rtype
       FROM  okc_rule_groups_v rgp, okc_rg_party_roles_v rpr ,okc_k_party_roles_v cpl ,OKC_RG_ROLE_DEFS_v rrd
       WHERE rgp.id = p_id AND rpr.rgp_id = p_id AND rpr.cpl_id = cpl.id and rpr.rrd_id = rrd.id and subject_object_flag='O';

    l_party_id varchar2(40) := NULL;
    l_cust_acc varchar2(40) := NULL;
    l_chr_id NUMBER;
    l_cle_id NUMBER;

    CURSOR l_csr IS
      SELECT
	'(select ''' || p_object_code || ''' object_code, id1, id2, name value, description from '
	||from_table|| ' where status = ''A''', where_clause
      FROM JTF_OBJECTS_VL
      WHERE object_code = p_object_code;

    l_sql varchar2(4000);
    l_where varchar2(4000);
    l_rule_cond VARCHAR2(200);
    l_flag VARCHAR2(10);

   --
   l_proc varchar2(72) := g_package||'get_object_sql';
   --

  begin


    if (p_object_code is NULL) then
      return
      '(select ''object_code'' object_code, ''id1'' id1, ''id2'' id2, ''value'' value, ''description'' description from dual where 0=1)';
    end if;

    open l_csr;
    fetch l_csr into l_sql, l_where;
    close l_csr;

    IF l_where IS NOT NULL THEN l_where := ' and '||l_where; END IF;

    IF (p_rule in ('BTO','STO') and p_ncol=1 ) THEN
      IF p_id IS NOT NULL THEN  -- CAN is mandatory for BTO, If it isnot defined BTO LOV should be null
        l_sql := l_sql ||' and CUST_ACCOUNT_ID='''|| To_Char( p_id )||'''' ||l_where|| ')';
       ELSE
        l_sql := '(select ''object_code'' object_code, ''id1'' id1, ''id2'' id2, ''value'' value, ''description'' description from dual where 0=1)';
      END IF;
     ELSE
      open c1;
      fetch c1 into l_chr_id, l_cle_id, l_party_id, l_flag;
      close c1;

      IF p_rule in ('BTO','STO') THEN
        l_cust_acc := get_rule_val( l_chr_id, l_cle_id, 'CAN', 1 );

        IF l_cust_acc IS NOT NULL THEN  -- CAN is mandatory for BTO, If it isnot defined BTO LOV should be null
          l_sql := l_sql ||' and (id1 in '
            ||' (SELECT REL.CUST_ACCOUNT_ID FROM HZ_CUST_ACCT_RELATE_ALL REL '
            ||' where '||l_flag||'_TO_FLAG=''Y'' AND REL.RELATED_CUST_ACCOUNT_ID='''||l_cust_acc
            ||''') or PARTY_ID='''||l_party_id||''')'||l_where|| ')';
         ELSE
          l_sql := '(select ''object_code'' object_code, ''id1'' id1, ''id2'' id2, ''value'' value, ''description'' description from dual where 0=1)';
--          l_sql := l_sql ||' and (id1 in '
--            ||' (SELECT REL.CUST_ACCOUNT_ID FROM HZ_CUST_ACCT_RELATE_ALL REL, HZ_CUST_ACCOUNTS CA '
--            ||' where REL.RELATED_CUST_ACCOUNT_ID=CA.CUST_ACCOUNT_ID AND '||l_flag||'_TO_FLAG=''Y'' AND CA.PARTY_ID='''||l_party_id
--            ||''') or PARTY_ID='''||l_party_id||''')'||l_where|| ')';
        END IF;
       ELSE
        l_sql := l_sql ||' and party_id = '||l_party_id||l_where|| ')';
      END IF;
    END IF;


    return l_sql;
  end get_object_sql;

  function get_object_sql(p_object_code in varchar2) return varchar2 is
   --
   l_proc varchar2(72) := g_package||'get_object_sql';
   --

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
   --
   l_proc varchar2(72) := g_package||'get_object_val';
   --

  begin




    if (p_object_code is NULL or p_object_id1 is NULL) then




      return NULL;
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
   --
   l_proc varchar2(72) := g_package||'get_object_dsc';
   --

  begin




    if (p_object_code is NULL or p_object_id1 is NULL) then




     return NULL;
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
   --
   l_proc varchar2(72) := g_package||'get_object_ids';
   --

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
   --
   l_proc varchar2(72) := g_package||'get_object_ids';
   --

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
--    CURSOR l_csr IS      -- /striping/
    CURSOR l_csr(appl_id number, dff_name varchar2) IS
	select 'select '||tbl.ID_COLUMN_NAME||' id, '
		||decode(col.END_USER_COLUMN_NAME,'TVE_ID',
'comments value, '''' description from ',
tbl.VALUE_COLUMN_NAME||' value, '||NVL(tbl.MEANING_COLUMN_NAME,'''''')||' description from ')
		||tbl.APPLICATION_TABLE_NAME sel,
	tbl.ADDITIONAL_WHERE_CLAUSE whr
	from fnd_descr_flex_col_usage_vl  col,
	  fnd_flex_validation_tables tbl
--	where col.application_id=510                                      -- /striping/
	where col.application_id= appl_id
--	and col.descriptive_flexfield_name='OKC Rule Developer DF'        -- /striping/
	and col.descriptive_flexfield_name= dff_name
	and col.descriptive_flex_context_code=p_rdf_code
	and col.application_column_name=p_col_name
	and col.FLEX_VALUE_SET_ID=tbl.FLEX_VALUE_SET_ID
	;
    l_sel varchar2(4000);
    l_whr varchar2(4000);
   --
   l_proc varchar2(72) := g_package||'get_flex_sql';
   --

  begin

-- /striping/
p_appl_id  := okc_rld_pvt.get_appl_id(p_rdf_code);
p_dff_name := okc_rld_pvt.get_dff_name(p_rdf_code);

--    open l_csr;    -- /striping/
    open l_csr(p_appl_id, p_dff_name);
    fetch l_csr into l_sel, l_whr;
    close l_csr;
    if (l_sel is null) then

     return null;
    end if;
    if (l_whr is null or p_clause_yn='N') then
      return '('||l_sel||')';
    end if;
    l_whr := upper(l_whr);
    if (substr(l_whr,1,6)='WHERE ') then l_whr:=substr(l_whr,7);
    end if;
    if (instr(l_whr,'ORDER BY')<>0) then l_whr:=substr(l_whr,1,instr(l_whr,'ORDER BY')-1);
    end if;
    if (l_whr is null) then

       return '('||l_sel||')';
    end if;
--+
    l_whr := uncomment(l_whr,p_clause_yn);
    if (l_whr is null) then




      return '('||l_sel||')';
    end if;
--+




    return '('||l_sel||' where '||l_whr||')';
  end get_flex_sql;

  function get_flex_sql(p_rdf_code in varchar2, p_col_name in varchar2) return varchar2 is
   --
   l_proc varchar2(72) := g_package||'get_flex_sql';
   --

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
   --
   l_proc varchar2(72) := g_package||'get_flex_val';
   --

  begin




    if (p_id is NULL) then




     return NULL;
    end if;
    l_sql := get_flex_sql(p_rdf_code, p_col_name,'Y');
    if (l_sql is null) then




      return NULL;
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
   --
   l_proc varchar2(72) := g_package||'get_flex_dsc';
   --

  begin




    if (p_id is NULL) then




     return NULL;
    end if;
    l_sql := get_flex_sql(p_rdf_code, p_col_name,'Y');
    if (l_sql is null) then




      return NULL;
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
   --
   l_proc varchar2(72) := g_package||'get_flex_ids';
   --

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
   --
   l_proc varchar2(72) := g_package||'get_flex_ids';
   --

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
   --
   l_proc varchar2(72) := g_package||'euro_YN';
   --

  begin




    if (rle_code='CVN') then
      if(okc_currency_api.get_ou_currency(p_chr_id)='EMU') then




        return 'Y';
       end if;
    end if;




    return 'N';
  end;

function gen_comments return varchar2 is
   --
   l_proc varchar2(72) := g_package||'gen_comments';
   --

begin








  return G_GEN_COMMENTS;
end;

procedure no_comments is
   --
   l_proc varchar2(72) := g_package||'no_comments';
   --

begin




  G_GEN_COMMENTS := 'F';




end;

function euro_yn(auth_org_id number) return varchar2 is
   --
   l_proc varchar2(72) := g_package||'euro_yn';
   --

begin




  if okc_currency_api.get_currency_type(
       okc_currency_api.get_ou_currency(
         nvl(auth_org_id,nvl(OKC_CONTEXT.get_okc_organization_id,-99))
       ),sysdate) like 'EMU%' then




    return 'Y';
  else




    return 'N';
  end if;
exception
  when others then




   return 'N';
end;

procedure issue_savepoint (sp varchar2) is
   --
   l_proc varchar2(72) := g_package||'issue_savepoint';
   --

begin




  dbms_transaction.savepoint(sp);




exception
  when others then




   NULL;
end;

procedure rollback_savepoint (sp varchar2) is
   --
   l_proc varchar2(72) := g_package||'rollback_savepoint';
   --

begin




  rollback to sp;




exception
 when others then




  NULL;
end;

procedure initialize(x out nocopy rulv_tbl_type) is
   --
   l_proc varchar2(72) := g_package||'initialize';
   --

begin




  x(1).last_update_date := sysdate;




end;

procedure initialize(x out nocopy rgpv_tbl_type) is
   --
   l_proc varchar2(72) := g_package||'initialize';
   --

begin




  x(1).last_update_date := sysdate;




end;

procedure initialize(x out nocopy rmpv_tbl_type) is
   --
   l_proc varchar2(72) := g_package||'initialize';
   --

begin




  x(1).last_update_date := sysdate;




end;

--
--  function get_contact
--
--  returns HZ_PARTIES related contacts points
--  otherwise (or if not found) returns contact description
--  through jtf_objects_vl
--
--  all parameters are regular jtf_objects related
--

function get_contact(
	p_object_code in varchar2,
	p_object_id1 in varchar2,
	p_object_id2 in varchar2
        )
return varchar2 is
begin
  return OKC_QUERY.get_contact(
	p_object_code,
	p_object_id1,
	p_object_id2);
end;

END OKC_RULE_PUB;

/
